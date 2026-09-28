-- Plain-Lua regression tests for lib/cost/context-costs.lua (not loaded by the mod)
-- Run from the mod root: lua lib/cost/test-context-costs.lua
-- Each room prices with its own raw sources and recipes, and imports only fill gaps, so a route that only exists elsewhere doesn't set a room's costs

-- Stand-ins for the Factorio environment
defines = {
    prototypes = {
        item = {
            item = 0,
        },
    },
}

local gutils = require("lib/graph/graph-utils")
local graph_cost = require("lib/cost/graph-cost")
local context_costs = require("lib/cost/context-costs")

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local function near(a, b)
    return a ~= nil and b ~= nil and math.abs(a - b) < 1e-6
end

local function entry(name, amount)
    return {
        type = "item",
        name = name,
        amount = amount,
    }
end

-- Two rooms: A (the start) mines ore; B mines debris and gems, which can be shipped to A.
-- Ore smelts into plates (only in A), and debris recycles into many plates (anywhere with debris).
-- automatable (optional): room --> material id --> true, as graph_cost.automatable_by_room gives
local function world(automatable)
    data = {
        raw = {
            item = {},
            fluid = {},
            recipe = {
                smelt = {
                    name = "smelt",
                    ingredients = { entry("ore", 1) },
                    results = { entry("plate", 1) },
                },
                recycle = {
                    name = "recycle",
                    ingredients = { entry("debris", 1) },
                    results = { entry("plate", 10) },
                },
                ["cut-gem"] = {
                    name = "cut-gem",
                    ingredients = { entry("gem", 1) },
                    results = { entry("jewel", 1) },
                },
            },
        },
    }
    for _, name in pairs({ "ore", "debris", "gem", "plate", "jewel" }) do
        data.raw.item[name] = {
            type = "item",
            name = name,
        }
    end

    local graph = {
        nodes = {},
        edges = {},
    }
    local function add_node(node_key, op, extra)
        graph.nodes[node_key] = {
            op = op,
            type = (extra or {}).type or node_key,
            name = (extra or {}).name or node_key,
            cost = (extra or {}).cost,
            prot = (extra or {}).prot or node_key,
            pre = {},
            dep = {},
        }
    end
    local function add_edge(start, stop, amount)
        local edge_key = start .. " --> " .. stop
        graph.edges[edge_key] = {
            start = start,
            stop = stop,
            amount = amount,
        }
        graph.nodes[start].dep[edge_key] = true
        graph.nodes[stop].pre[edge_key] = true
    end
    add_node("room A", "AND", { type = "room-a" })
    add_node("room B", "AND", { type = "room-b" })
    local function mined(item_name, room, cost)
        local item_key = gutils.key("item", item_name)
        add_node(item_key, "OR", { type = "item", name = item_name, prot = item_key })
        add_node("mine " .. item_name, "AND", { cost = cost })
        add_edge(room, "mine " .. item_name, 0)
        add_edge("mine " .. item_name, item_key, 1)
    end
    mined("ore", "room A", 1)
    mined("debris", "room B", 0.1)
    mined("gem", "room B", 2)
    for _, name in pairs({ "plate", "jewel" }) do
        local item_key = gutils.key("item", name)
        add_node(item_key, "OR", { type = "item", name = name, prot = item_key })
    end
    local function transmit(node, incoming)
        if node.type == "room-a" then
            return { "A" }
        elseif node.type == "room-b" then
            return { "B" }
        end
        return { incoming }
    end
    local prices = graph_cost.compute(graph, { "A", "B" }, transmit)

    -- Where the sort reaches things (earlier index first): ore and smelting only in A; debris, gems and plates in both (shipped)
    local function at(contexts)
        return contexts
    end
    local sort_info = {
        node_to_context_inds = {
            [gutils.key("item", "ore")] = at({ A = 1 }),
            [gutils.key("item", "debris")] = at({ B = 1, A = 5 }),
            [gutils.key("item", "gem")] = at({ B = 2, A = 6 }),
            [gutils.key("item", "plate")] = at({ A = 3, B = 4 }),
            [gutils.key("item", "jewel")] = at({ B = 7, A = 8 }),
            [gutils.key("recipe", "smelt")] = at({ A = 2 }),
            [gutils.key("recipe", "recycle")] = at({ B = 3, A = 6 }),
            [gutils.key("recipe", "cut-gem")] = at({ B = 4 }),
        },
    }
    local info = context_costs.build(graph, sort_info, prices, "A", { A = true, B = true }, nil, nil, automatable)
    return info
end

local function game_set(info, track_resources)
    return context_costs.new_set(info, {
        ing_overrides = context_costs.data_overrides(),
        use_data = true,
        item_recipe_maps = require("lib/cost/flow-cost").construct_item_recipe_maps(),
        track_resources = track_resources or {},
    })
end

test("a room's raw costs come from its own sources", function()
    local info = world()
    assert(near(info.local_raw["A"]["item-ore"], 1))
    assert(info.local_raw["A"]["item-debris"] == nil)
    assert(near(info.local_raw["B"]["item-debris"], 0.1))
end)

test("imports fill gaps but don't undercut what a room makes itself", function()
    local info = world()
    local set = game_set(info)
    -- Smelting in A: 1 ore, plus flow_cost's time (0.07 per second, 0.5 s by default) and complexity (0.01)
    local smelted = 1 + 0.07 * 0.5 + 0.01
    assert(near(set:view("A").material_to_cost["item-plate"], smelted))
    -- B recycles its own debris into plates for far less
    assert(near(set:view("B").material_to_cost["item-plate"], (0.1 + 0.07 * 0.5 + 0.01) / 10))
    -- A doesn't mine gems, so they come in at B's cost
    assert(info.import_from["A"]["item-gem"] == "B")
    assert(near(set:view("A").material_to_cost["item-gem"], 2))
end)

test("away from its home room, a material costs no more than bringing it from home, even with a dearer local route", function()
    local info = world()
    -- A can grind ore into gems, but far dearer than B mines them
    data.raw.recipe.grind = {
        name = "grind",
        ingredients = { entry("ore", 100) },
        results = { entry("gem", 1) },
    }
    info.recipe_available["A"].grind = true
    local set = game_set(info)
    assert(set.tiers["A"]["local"].material_to_cost["item-gem"] > 100)
    assert(near(set:view("A").material_to_cost["item-gem"], 2))
end)

test("a recipe is judged on the starting planet if it's available there, else where the sort first reaches it", function()
    local info = world()
    assert(context_costs.judging_context(info, "smelt") == "A")
    assert(context_costs.judging_context(info, "recycle") == "A")
    assert(context_costs.judging_context(info, "cut-gem") == "B")
end)

test("resource bills follow the tier costs come from, and imports bring theirs along", function()
    local info = world()
    local set = game_set(info, { "item-ore", "item-gem" })
    assert(near(set:resource_view("A", "item-ore").material_to_cost["item-plate"], 1))
    assert(near(set:resource_view("A", "item-gem").material_to_cost["item-gem"], 1))
end)

test("a staged set prices a recipe once its ingredients are set and it's updated", function()
    local info = world()
    local overrides = context_costs.data_overrides()
    overrides.smelt = { "blacklisted" }
    local set = context_costs.new_set(info, {
        ing_overrides = overrides,
        use_data = true,
        item_recipe_maps = require("lib/cost/flow-cost").construct_item_recipe_maps(),
        track_resources = {},
    })
    -- Until smelting counts, A only has plates from recycled imported debris
    assert(near(set:view("A").material_to_cost["item-plate"], (0.1 + 0.07 * 0.5 + 0.01) / 10))
    overrides.smelt = data.raw.recipe.smelt.ingredients
    set:update("smelt")
    assert(near(set:view("A").material_to_cost["item-plate"], 1 + 0.07 * 0.5 + 0.01))
end)

test("a recipe that takes nothing (like the captive spawner's biter eggs) is priced at its time and complexity", function()
    world()
    data.raw.item.egg = {
        type = "item",
        name = "egg",
    }
    data.raw.recipe.hatch = {
        name = "hatch",
        energy_required = 10,
        results = { entry("egg", 5) },
    }
    local flow_cost = require("lib/cost/flow-cost")
    local costs = flow_cost.determine_recipe_item_cost({}, 0.07, 0.01)
    assert(near(costs.material_to_cost["item-egg"], (0.07 * 10 + 0.01) / 5))
end)

test("an automatable-only set prices only from what each room has automatably, so a cost still means automatable there", function()
    -- Gems are mined by hand in B, so they aren't automatable anywhere; ore and debris are
    local info = world({
        A = { ["item-ore"] = true, ["item-debris"] = true, ["item-plate"] = true },
        B = { ["item-debris"] = true, ["item-plate"] = true },
    })
    local set = context_costs.new_set(info, {
        ing_overrides = context_costs.data_overrides(),
        use_data = true,
        item_recipe_maps = require("lib/cost/flow-cost").construct_item_recipe_maps(),
        track_resources = {},
        automatable_only = true,
    })
    assert(set:view("A").material_to_cost["item-plate"] ~= nil)
    assert(set:view("A").material_to_cost["item-gem"] == nil)
    assert(set:view("B").material_to_cost["item-jewel"] == nil)
    -- Without it, gems and jewels are priced
    local all = game_set(info)
    assert(all:view("B").material_to_cost["item-jewel"] ~= nil)
end)

test("newer resources' share of a cost counts newer raw resources and imports", function()
    local info = world()
    local set = game_set(info)
    local maps = require("lib/cost/flow-cost").construct_item_recipe_maps()
    -- Debris is a newer resource; B makes plates from it, so they're mostly newer there
    local novelty_b = context_costs.novelty(info, "B", set, { ["item-debris"] = true }, maps)
    assert(near(novelty_b["item-debris"], 1))
    assert(novelty_b["item-plate"] > 0.5 and novelty_b["item-plate"] <= 1)
    -- A imports gems, so they're all newer there, while its ore isn't
    local novelty_a = context_costs.novelty(info, "A", set, { ["item-debris"] = true }, maps)
    assert(near(novelty_a["item-gem"], 1))
    assert(novelty_a["item-ore"] == nil)
end)

test("a fallback view reads the first table, then the second, then the default", function()
    local view = context_costs.fallback_view({ a = 1 }, { a = 2, b = 3 }, function(id)
        if id == "c" then
            return 4
        end
    end)
    assert(view.a == 1 and view.b == 3 and view.c == 4 and view.d == nil)
end)

print(num_passed .. " tests passed")

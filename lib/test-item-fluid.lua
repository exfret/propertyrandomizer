-- Plain-Lua regression tests for items and fluids trading positions (lib/item-fluid.lua) and machines taking fluids (lib/fluid-ports.lua), not loaded by the mod
-- Run from the mod root: lua lib/test-item-fluid.lua

-- Stand-ins for the Factorio environment
function table.deepcopy(tbl)
    if type(tbl) ~= "table" then
        return tbl
    end
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = table.deepcopy(v)
    end
    return copy
end
function log(msg) end
defines = {
    prototypes = {
        item = {
            item = 0,
        },
        entity = {
            kettle = 0,
            sprayer = 0,
            intake = 0,
        },
    },
    direction = {
        north = 0,
        east = 4,
        south = 8,
        west = 12,
    },
}
util = {
    parse_energy = function(energy)
        local number, prefix = string.match(energy, "^([%d%.]+)(%a?)[JW]$")
        local scale = { [""] = 1, k = 1e3, M = 1e6, G = 1e9, T = 1e12 }
        return (tonumber(number) or 0) * (scale[prefix] or 1)
    end,
}
data = {
    raw = {
        lab = {},
        item = {},
        fluid = {},
    },
}
-- The feature under test is on (config.lua turns it off while the user playtests)
config = {
    item_fluids = true,
}
randomization_info = {
    options = {
        first_pass = {
            blacklist = {},
        },
    },
}
package.loaded["lib/locale"] = {
    -- As lib/locale.lua: a prototype's own localised name, or its class's locale key
    find_localised_name = function(prot)
        return prot.localised_name or { prot.type .. "-name." .. prot.name }
    end,
}

local gutils = require("lib/graph/graph-utils")
local lutils = require("lib/logic/logic-utils")
local dutils = require("lib/data-utils")
local item_fluid = require("lib/item-fluid")
local fluid_ports = require("lib/fluid-ports")
local pipe_conns = require("lib/pipe-conns")

local key = gutils.key

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local function add_item(name, is_useless)
    data.raw.item[name] = {
        type = "item",
        name = name,
        stack_size = 50,
        place_result = (not is_useless) and name or nil,
    }
end
-- A useless fluid has no fuel value (and no entity in data.raw takes it by name)
local function add_fluid(name, is_useless)
    data.raw.fluid[name] = {
        type = "fluid",
        name = name,
        default_temperature = 15,
        base_color = { 0, 0, 1 },
        flow_color = { 0, 0, 1 },
        fuel_value = (is_useless == false) and "1MJ" or nil,
    }
end

----------------------------------------------------------------------------------------------------
-- Where reflection puts identities
----------------------------------------------------------------------------------------------------

test("a useless fluid has no fuel value, and no entity takes it by name", function()
    data.raw.fluid = {}
    add_fluid("brine", true)
    add_fluid("gas", true)
    add_fluid("oil", true)
    add_fluid("mist", true)
    add_fluid("fuel", false)
    data.raw.kettle = {
        kettle = {
            type = "kettle",
            name = "kettle",
            fluid_box = {
                volume = 200,
                filter = "gas",
                pipe_connections = {},
            },
            output_fluid_box = {
                volume = 200,
                filter = "mist",
                production_type = "output",
                pipe_connections = {},
            },
        },
    }
    data.raw.sprayer = {
        flamer = {
            type = "sprayer",
            name = "flamer",
            attack_parameters = {
                type = "stream",
                fluids = {
                    { type = "oil" },
                },
            },
        },
    }
    -- A filtered offshore pump makes its fluid, which is the fluid's position
    data.raw.intake = {
        intake = {
            type = "intake",
            name = "intake",
            fluid_box = {
                volume = 100,
                filter = "brine",
                production_type = "output",
                pipe_connections = {},
            },
        },
    }
    item_fluid.recalculate_entity_fluids()
    assert(item_fluid.is_useless_fluid(data.raw.fluid.brine), "only made")
    assert(item_fluid.is_useless_fluid(data.raw.fluid.mist), "only made by a kettle")
    assert(not item_fluid.is_useless_fluid(data.raw.fluid.gas), "a kettle takes gas")
    assert(not item_fluid.is_useless_fluid(data.raw.fluid.oil), "a turret fires oil")
    assert(not item_fluid.is_useless_fluid(data.raw.fluid.fuel), "a fuel")
    assert(item_fluid.is_useless_material(key("fluid", "brine")) and not item_fluid.is_useless_material(key("fluid", "gas")))
    data.raw.kettle = nil
    data.raw.sprayer = nil
    data.raw.intake = nil
    item_fluid.recalculate_entity_fluids()
end)

test("useless items only detour among item positions and useless fluids among fluid positions; everything else lands where it's assigned", function()
    math.randomseed(2)
    local num_fluid_detours = 0
    for trial = 1, 3000 do
        data.raw.item = {}
        data.raw.fluid = {}
        local materials = {}
        local n = math.random(2, 12)
        for i = 1, n do
            if math.random() < 0.35 then
                add_fluid("fluid-" .. i, math.random() < 0.5)
                table.insert(materials, key("fluid", "fluid-" .. i))
            else
                add_item("item-" .. i, math.random() < 0.5)
                table.insert(materials, key("item", "item-" .. i))
            end
        end
        local shuffled = {}
        for i = 1, n do
            shuffled[i] = materials[i]
        end
        for i = n, 2, -1 do
            local j = math.random(1, i)
            shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
        end
        local identity_at = {}
        for i = 1, n do
            identity_at[materials[i]] = shuffled[i]
        end

        local realized = item_fluid.realized_assignment(identity_at)
        local seen = {}
        for _, position in pairs(materials) do
            local identity = realized[position]
            assert(identity ~= nil and not seen[identity], "not a permutation")
            seen[identity] = true
            local assigned = identity_at[position]
            local position_form = gutils.deconstruct(position).type
            -- Non-useless identities, and identities changing form, land where they're assigned
            if gutils.deconstruct(assigned).type ~= position_form or not item_fluid.is_useless_material(assigned) then
                assert(identity == assigned, "an identity that isn't useless in its position's form moved")
            end
            -- Anything else here is a useless identity of the position's form: detoured, or kept at its own position
            if identity ~= assigned then
                assert(gutils.deconstruct(identity).type == position_form, "a detour changed an identity's form")
                assert(item_fluid.is_useless_material(identity), "a detour moved a non-useless identity")
                if position_form == "fluid" then
                    num_fluid_detours = num_fluid_detours + 1
                end
            end
        end
        -- Two useless materials of the same form never just trade names (ones of different forms can, since each changes form)
        for _, position in pairs(materials) do
            local identity = realized[position]
            if identity ~= position and gutils.deconstruct(identity).type == gutils.deconstruct(position).type and item_fluid.is_useless_material(identity) and item_fluid.is_useless_material(position) and realized[identity] == position then
                error("two useless materials swapped")
            end
        end
        -- Reflection applies the realized assignment as it is: every identity away from its own position is switched, and a useless one kept at its own isn't
        local positions = item_fluid.reflected_positions(realized)
        for _, position in pairs(materials) do
            local identity = realized[position]
            if identity ~= position or not item_fluid.is_useless_material(identity) then
                assert(positions[identity] == position)
            else
                assert(positions[identity] == nil)
            end
        end
    end
    assert(num_fluid_detours > 0, "the trials never detoured a fluid")
end)

test("with only items, the rule is item reflection's own", function()
    math.randomseed(3)
    for trial = 1, 500 do
        data.raw.item = {}
        local names = {}
        local n = math.random(2, 10)
        for i = 1, n do
            names[i] = "item-" .. i
            add_item(names[i], math.random() < 0.5)
        end
        local shuffled = {}
        for i = 1, n do
            shuffled[i] = names[i]
        end
        for i = n, 2, -1 do
            local j = math.random(1, i)
            shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
        end
        local by_name = {}
        local by_key = {}
        for i = 1, n do
            by_name[names[i]] = shuffled[i]
            by_key[key("item", names[i])] = key("item", shuffled[i])
        end
        local realized_names = dutils.realized_item_assignment(by_name)
        local realized_keys = item_fluid.realized_assignment(by_key)
        for i = 1, n do
            assert(realized_keys[key("item", names[i])] == key("item", realized_names[names[i]]))
        end
    end
end)

----------------------------------------------------------------------------------------------------
-- Positions and identities
----------------------------------------------------------------------------------------------------

-- A toy graph as first pass splits it: nodes by type and name, an orand on each edge into an OR node (as gutils.make_orands puts one), with the bookkeeping make_orand keeps
local function toy_graph()
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
        node_to_orands = {},
        orand_to_parent = {},
        orand_to_child = {},
    }
    local function node(node_type, name, op)
        local added = gutils.add_node(graph, node_type, name)
        added.op = op
        if op == "OR" then
            graph.node_to_orands[key(added)] = {}
        else
            graph.node_to_orands[key(added)] = { key(added) }
        end
        return added
    end
    local function edge(start, stop, extra)
        if stop.op == "OR" then
            local orand = node("orand", key(start) .. " --> " .. key(stop), "AND")
            graph.node_to_orands[key(stop)][key(orand)] = true
            graph.orand_to_parent[key(orand)] = key(stop)
            graph.orand_to_child[key(orand)] = key(start)
            gutils.add_edge(graph, key(start), key(orand), extra)
            gutils.add_edge(graph, key(orand), key(stop))
            return orand
        end
        return gutils.add_edge(graph, key(start), key(stop), extra)
    end
    return graph, node, edge
end

-- An item position as first pass leaves it on the slot: made by a recipe through item-craft, taken by a recipe, with its base to the trav
-- One of an item, as an ingredient or result list
local function one_item(name)
    return {
        {
            type = "item",
            name = name,
            amount = 1,
        },
    }
end

-- A hand-written recipe's categories in the recycling category and another one that isn't hand crafting's (like Space Age's scrap recycling, which the character can craft too)
local HAND_WRITTEN_RECYCLING_CATEGORIES = {
    "by-hand",
    item_fluid.RECYCLING_CATEGORY,
}

local function toy_item_slot(graph, node, edge, name)
    local slot = node("item", name, "OR")
    local craft = node("item-craft", name, "OR")
    edge(craft, slot)
    local make = node("recipe", name .. "-make", "AND")
    edge(make, craft)
    local use = node("recipe", name .. "-use", "AND")
    edge(slot, use)
    -- Its own connection: base --> head --> trav, as first pass cuts the slot --> trav edge
    local base = node("base", name, "AND")
    edge(slot, base)
    local head = node("head", name, "OR")
    base.old_head = key(head)
    head.old_base = key(base)
    local trav = node("item", name .. "-trav", "OR")
    trav.trav = true
    trav.old_slot = key(slot)
    edge(head, trav)
    return slot, craft, make, use
end

-- A fluid position as first pass leaves it on the slot: a fluid-temperature node made through fluid-create-temperature by a recipe (fluid-craft-temperature), held in pipes, taken by a recipe through a temperature range, with its base to the trav
local function toy_fluid_slot(graph, node, edge, name)
    local temp = key(name, "15")
    local slot = node("fluid-temperature", temp, "AND")
    local create = node("fluid-create-temperature", temp, "OR")
    edge(create, slot)
    edge(node("fluid-hold", name, "OR"), slot)
    local craft = node("fluid-craft-temperature", temp, "OR")
    edge(craft, create)
    local make = node("recipe", name .. "-make", "AND")
    edge(make, craft)
    local range = node("fluid-temperature-range", key(name, key("nil", "nil")), "OR")
    edge(slot, range)
    local use = node("recipe", name .. "-use", "AND")
    edge(range, use)
    local base = node("base", name, "AND")
    edge(slot, base)
    local head = node("head", name, "OR")
    base.old_head = key(head)
    head.old_base = key(base)
    local trav = node("fluid-temperature", temp .. "-trav", "AND")
    trav.trav = true
    trav.old_slot = key(slot)
    edge(head, trav)
    return slot, create, craft, make, range, use
end

-- A trav of a form, as first pass names one after its own slot (which has to exist for material_of_node)
local function toy_trav(graph, node, form, name)
    local slot_key
    if form == "item" then
        slot_key = key(node("item", name, "OR"))
    else
        slot_key = key(node("fluid-temperature", key(name, "15"), "AND"))
    end
    local trav = node(gutils.deconstruct(slot_key).type, gutils.deconstruct(slot_key).name .. "-trav", "OR")
    trav.old_slot = slot_key
    return trav
end

local function category_of(graph, node_of_recipe)
    for pre, _ in pairs(node_of_recipe.pre) do
        local prenode = gutils.prenode(graph, pre)
        if prenode.type == "recipe-category" or prenode.type == "resource-category" then
            return key(prenode)
        end
    end
    return nil
end

test("an item position takes a fluid when its roles are recipes and resource mining, and a fluid position takes an item when recipes and resources make it", function()
    data.raw.resource = {
        ore = {
            type = "resource",
            name = "ore",
            minable = {},
        },
    }
    local graph, node, edge = toy_graph()
    local slot = toy_item_slot(graph, node, edge, "gear")
    assert(item_fluid.position_takes(graph, slot, "item"))
    assert(item_fluid.position_takes(graph, slot, "fluid"))
    -- A resource mined into it is fine; a rock isn't, since mining it gives items by hand
    edge(node("entity-mine", "ore", "AND"), slot)
    assert(item_fluid.position_takes(graph, slot, "fluid"))
    edge(node("entity-mine", "rock", "AND"), slot)
    assert(not item_fluid.position_takes(graph, slot, "fluid"), "a rock can't give a fluid")
    -- Roles only an item fills: loot, being spoiled into, being a burnt result, being an asteroid chunk's, fueling burners like coal
    local function refuses(role_type, as_dep)
        local other_graph, other_node, other_edge = toy_graph()
        local other_slot = toy_item_slot(other_graph, other_node, other_edge, "gear")
        local role = other_node(role_type, "role", as_dep and "OR" or "AND")
        if as_dep then
            other_edge(other_slot, role)
        else
            other_edge(role, other_slot)
        end
        return not item_fluid.position_takes(other_graph, other_slot, "fluid")
    end
    assert(refuses("entity-kill"), "loot")
    assert(refuses("item"), "spoiled into")
    assert(refuses("item-burn"), "a burnt result")
    assert(refuses("asteroid-chunk-mine"), "an asteroid chunk")
    assert(refuses("fuel-category", true), "a fuel")
    -- A fluid position: made by recipes and resources, taken by recipes through temperature ranges
    local fluid_graph, fluid_node, fluid_edge = toy_graph()
    local fluid_slot, create = toy_fluid_slot(fluid_graph, fluid_node, fluid_edge, "brine")
    assert(item_fluid.position_takes(fluid_graph, fluid_slot, "item"))
    fluid_edge(fluid_node("entity-mine", "ore", "AND"), create)
    assert(item_fluid.position_takes(fluid_graph, fluid_slot, "item"))
    -- Made by operating an entity (like a boiler's steam) isn't
    fluid_edge(fluid_node("entity-operate", "heater", "AND"), create)
    assert(not item_fluid.position_takes(fluid_graph, fluid_slot, "item"))
    data.raw.resource = nil
end)

test("pumping a fluid and barreling it follow its identity: they feed a source the trav needs, and filling takes the trav", function()
    local graph, node, edge = toy_graph()
    local slot, create, craft, make, range, use = toy_fluid_slot(graph, node, edge, "brine")
    local trav = graph.nodes[key("fluid-temperature", key("brine", "15") .. "-trav")]
    local offshore = node("fluid-create-offshore-temperature", key("brine", "15"), "OR")
    edge(offshore, create)
    local empty = node("recipe", "empty-brine-keg", "AND")
    edge(empty, craft)
    local fill = node("recipe", "brine-keg", "AND")
    edge(range, fill)
    local recipes = item_fluid.container_recipes({
        {
            filled = "brine-keg",
            held = "brine",
            vessel = "keg",
            fill = "brine-keg",
            empty = "empty-brine-keg",
        },
    })
    local source_key = item_fluid.move_identity_sources(graph, key(slot), key(trav), recipes)
    assert(source_key ~= nil and graph.nodes[source_key].op == "OR")
    assert(graph.edges[gutils.ekey({ start = source_key, stop = key(trav) })] ~= nil and trav.op == "OR", "the source is another way to the trav")
    local function feeds(parent_key, child)
        for _, prenode in pairs(gutils.prenodes(graph, graph.nodes[parent_key])) do
            if prenode.type == "orand" and key(gutils.unique_prenode(graph, prenode)) == key(child) then
                return true
            end
        end
        return false
    end
    assert(feeds(source_key, offshore) and feeds(source_key, empty), "pumping and emptying feed the source")
    assert(not feeds(key(create), offshore) and not feeds(key(craft), empty), "and not the position")
    assert(feeds(key(craft), make), "the position keeps its recipe")
    assert(graph.node_to_orands[source_key] ~= nil and next(graph.node_to_orands[source_key]) ~= nil, "the orand bookkeeping follows")
    assert(graph.node_to_orands[key(create)][key(gutils.prenodes(graph, graph.nodes[source_key])[1])] == nil)
    assert(graph.edges[gutils.ekey({ start = key(trav), stop = key(fill) })] ~= nil, "filling takes the trav")
    assert(graph.edges[gutils.ekey({ start = key(range), stop = key(fill) })] == nil)
    assert(graph.edges[gutils.ekey({ start = key(range), stop = key(use) })] ~= nil, "other users still take the position")
    -- A fluid with no such makers gets no source, and an item slot is left alone
    local plain_graph, plain_node, plain_edge = toy_graph()
    local plain_slot = toy_fluid_slot(plain_graph, plain_node, plain_edge, "syrup")
    assert(item_fluid.move_identity_sources(plain_graph, key(plain_slot), key("fluid-temperature", key("syrup", "15") .. "-trav"), recipes) == nil)
    local item_slot = toy_item_slot(graph, node, edge, "gear")
    assert(item_fluid.move_identity_sources(graph, key(item_slot), key("item", "gear-trav"), recipes) == nil)
end)

test("a recipe's category node follows its fluid counts, trading hand crafting for the fluid category, and a resource's follows its results", function()
    data.raw["recipe-category"] = {
        [fluid_ports.HAND_CATEGORY_WITH_FLUID] = {},
    }
    local recipe = {
        type = "recipe",
        name = "r",
    }
    local function counts(input, output)
        return {
            input = input,
            output = output,
        }
    end
    assert(item_fluid.recipe_category_key(recipe, counts(0, 0)) == key("recipe-category", gutils.concat({ fluid_ports.HAND_CATEGORY, 0, 0 })))
    assert(item_fluid.recipe_category_key(recipe, counts(1, 0)) == key("recipe-category", gutils.concat({ fluid_ports.HAND_CATEGORY_WITH_FLUID, 1, 0 })))
    recipe.categories = { "other-category" }
    assert(item_fluid.recipe_category_key(recipe, counts(2, 1)) == key("recipe-category", gutils.concat({ "other-category", 2, 1 })))
    -- Without the fluid category, hand crafting's stays
    data.raw["recipe-category"] = nil
    recipe.categories = nil
    assert(item_fluid.recipe_category_key(recipe, counts(1, 0)) == key("recipe-category", gutils.concat({ fluid_ports.HAND_CATEGORY, 1, 0 })))
    local resource = {
        type = "resource",
        name = "ore",
        category = "deep",
    }
    assert(item_fluid.resource_category_key(resource, counts(0, 1)) == key("resource-category", gutils.concat({ "deep", 0, 1 })))
end)

test("amounts come whole for items and to two decimals for fluids", function()
    assert(item_fluid.round_amount("item", 0.2) == 1 and item_fluid.round_amount("item", 2.5) == 3 and item_fluid.round_amount("item", 2.49) == 2)
    assert(item_fluid.round_amount("fluid", 0.004) == 0.01 and item_fluid.round_amount("fluid", 7) == 7, "a fluid ingredient's amount can't be 0")
    assert(math.abs(item_fluid.round_amount("fluid", 12.346) - 12.35) < 1e-9)
end)

test("a fluid at an item position moves its recipes and resource to the categories of their new fluid counts, and its recycling leads nowhere", function()
    data.raw["recipe-category"] = {
        [fluid_ports.HAND_CATEGORY_WITH_FLUID] = {},
    }
    data.raw.resource = {
        ore = {
            type = "resource",
            name = "ore",
            category = "deep",
            minable = {
                results = {
                    { type = "item", name = "gear", amount = 1 },
                },
            },
        },
    }
    local function recipe(name, ingredients, results, cats)
        return {
            type = "recipe",
            name = name,
            categories = cats,
            ingredients = ingredients,
            results = results,
        }
    end
    -- A recipe of the shape the recycler generates (recycling.looks_generated), which lib/recycling.lua regenerates
    local function generated_recycling(name, ingredients, results)
        local generated = recipe(name, ingredients, results, { item_fluid.RECYCLING_CATEGORY })
        generated.hidden = true
        generated.unlock_results = false
        return generated
    end
    data.raw.recipe = {
        ["gear-make"] = recipe("gear-make", { { type = "item", name = "a", amount = 1 } }, { { type = "item", name = "gear", amount = 1 } }),
        ["gear-use"] = recipe("gear-use", { { type = "item", name = "gear", amount = 1 } }, { { type = "item", name = "b", amount = 1 } }),
        ["gear-recycling"] = generated_recycling("gear-recycling", one_item("gear"), {}),
        ["z-recycling"] = generated_recycling("z-recycling", one_item("z"), one_item("gear")),
        -- Hand-written, like Space Age's scrap recycling: no generated shape, so it changes category like any recipe
        ["junk-recycling"] = recipe("junk-recycling", one_item("junk"), one_item("gear"), HAND_WRITTEN_RECYCLING_CATEGORIES),
    }
    local graph, node, edge = toy_graph()
    local slot, craft, make, use = toy_item_slot(graph, node, edge, "gear")
    local ore = node("entity-mine", "ore", "AND")
    edge(ore, slot)
    local recycle_use = node("recipe", "gear-recycling", "AND")
    edge(slot, recycle_use)
    local recycle_make = node("recipe", "z-recycling", "AND")
    edge(recycle_make, craft)
    local junk_make = node("recipe", "junk-recycling", "AND")
    edge(junk_make, craft)
    local junk_hand = node("recipe-category", lutils.rcat_key(HAND_WRITTEN_RECYCLING_CATEGORIES, {
        input = 0,
        output = 0,
    }), "OR")
    edge(junk_hand, junk_make)
    local junk_fluid = node("recipe-category", lutils.rcat_key(HAND_WRITTEN_RECYCLING_CATEGORIES, {
        input = 0,
        output = 1,
    }), "OR")
    local hand = node("recipe-category", gutils.concat({ fluid_ports.HAND_CATEGORY, 0, 0 }), "OR")
    edge(hand, make)
    edge(hand, use)
    local recycling = node("recipe-category", gutils.concat({ item_fluid.RECYCLING_CATEGORY, 0, 0 }), "OR")
    edge(recycling, recycle_use)
    edge(recycling, recycle_make)
    local mining = node("resource-category", gutils.concat({ "deep", 0, 0 }), "OR")
    edge(mining, ore)
    local trav = toy_trav(graph, node, "fluid", "brine")
    -- Without category nodes for the new counts, the pair is out; an item identity needs none
    assert(not item_fluid.form_change_ok(graph, slot, trav))
    assert(item_fluid.form_change_ok(graph, slot, toy_trav(graph, node, "item", "cog")))
    local with_input = node("recipe-category", gutils.concat({ fluid_ports.HAND_CATEGORY_WITH_FLUID, 1, 0 }), "OR")
    local with_output = node("recipe-category", gutils.concat({ fluid_ports.HAND_CATEGORY_WITH_FLUID, 0, 1 }), "OR")
    assert(not item_fluid.form_change_ok(graph, slot, trav), "the resource still needs a category for a fluid result")
    local mining_fluid = node("resource-category", gutils.concat({ "deep", 0, 1 }), "OR")
    assert(item_fluid.form_change_ok(graph, slot, trav))

    item_fluid.rewire_form_change(graph, key(slot), key(trav))
    assert(category_of(graph, make) == key(with_output), "the maker makes a fluid now")
    assert(category_of(graph, use) == key(with_input), "the user takes a fluid now")
    assert(category_of(graph, ore) == key(mining_fluid), "the resource gives a fluid now")
    local false_key = key("false", "")
    assert(graph.edges[gutils.ekey({ start = false_key, stop = key(recycle_use) })] ~= nil, "recycling the fluid leads nowhere")
    local maker_feeds = false
    for _, prenode in pairs(gutils.prenodes(graph, craft)) do
        if prenode.type == "orand" and key(gutils.unique_prenode(graph, prenode)) == key(recycle_make) then
            maker_feeds = true
        end
    end
    assert(not maker_feeds and next(recycle_make.dep) == nil, "getting the fluid out of the recycler leads nowhere")
    assert(category_of(graph, recycle_use) == key(recycling), "recycling recipes keep their category")
    -- A hand-written recipe in the recycling category keeps making the position, now a fluid, in the category with a fluid result: the one hand crafting (its other category isn't hand crafting's, the one traded for the fluid one) can't serve, like the game's scrap recycling once a fluid takes one of its results
    local junk_feeds = false
    for _, prenode in pairs(gutils.prenodes(graph, craft)) do
        if prenode.type == "orand" and key(gutils.unique_prenode(graph, prenode)) == key(junk_make) then
            junk_feeds = true
        end
    end
    assert(junk_feeds, "a hand-written recycling recipe still makes the fluid")
    assert(category_of(graph, junk_make) == key(junk_fluid), "a hand-written recycling recipe needs the category of its new fluid counts")

    -- A second position of the same recipe adds up: the user also takes another item position that a fluid takes
    local other_slot = node("item", "cog", "OR")
    edge(other_slot, use)
    table.insert(data.raw.recipe["gear-use"].ingredients, { type = "item", name = "cog", amount = 1 })
    local both_inputs = node("recipe-category", gutils.concat({ fluid_ports.HAND_CATEGORY_WITH_FLUID, 2, 0 }), "OR")
    item_fluid.rewire_form_change(graph, key(other_slot), key(toy_trav(graph, node, "fluid", "syrup")))
    assert(category_of(graph, use) == key(both_inputs))

    -- An item at a fluid position goes the other way: its recipes lose a fluid
    local fluid_graph, fluid_node, fluid_edge = toy_graph()
    local fluid_slot, _, _, fluid_make, _, fluid_use = toy_fluid_slot(fluid_graph, fluid_node, fluid_edge, "brine")
    data.raw.recipe = {
        ["brine-make"] = recipe("brine-make", { { type = "item", name = "a", amount = 1 } }, { { type = "fluid", name = "brine", amount = 10 } }, { "other-category" }),
        ["brine-use"] = recipe("brine-use", { { type = "fluid", name = "brine", amount = 10 } }, { { type = "item", name = "b", amount = 1 } }, { "other-category" }),
    }
    fluid_edge(fluid_node("recipe-category", gutils.concat({ "other-category", 0, 1 }), "OR"), fluid_make)
    fluid_edge(fluid_node("recipe-category", gutils.concat({ "other-category", 1, 0 }), "OR"), fluid_use)
    local item_trav = toy_trav(fluid_graph, fluid_node, "item", "gear")
    assert(not item_fluid.form_change_ok(fluid_graph, fluid_slot, item_trav))
    local dry = fluid_node("recipe-category", gutils.concat({ "other-category", 0, 0 }), "OR")
    assert(item_fluid.form_change_ok(fluid_graph, fluid_slot, item_trav))
    item_fluid.rewire_form_change(fluid_graph, key(fluid_slot), key(item_trav))
    assert(category_of(fluid_graph, fluid_make) == key(dry) and category_of(fluid_graph, fluid_use) == key(dry))
    data.raw["recipe-category"] = nil
    data.raw.resource = nil
    data.raw.recipe = nil
end)

-- A fluid as the game's graph has it before first pass splits it: made by a recipe (through fluid-craft-temperature), held in pipes, and leading to its fluid node
test("a position's takers are the recipes taking it, the recycler's generated ones aside, which is all a fluid there is used through", function()
    data.raw.recipe = {
        ["gear-recycling"] = {
            type = "recipe",
            name = "gear-recycling",
            categories = { item_fluid.RECYCLING_CATEGORY },
            hidden = true,
            unlock_results = false,
            ingredients = one_item("gear"),
            results = {},
        },
        ["gear-sorting"] = {
            type = "recipe",
            name = "gear-sorting",
            categories = HAND_WRITTEN_RECYCLING_CATEGORIES,
            ingredients = one_item("gear"),
            results = {},
        },
    }
    local graph, node, edge = toy_graph()
    local slot = toy_item_slot(graph, node, edge, "gear")
    assert(item_fluid.position_takers(graph, slot) == 1)
    edge(slot, node("recipe", "gear-recycling", "AND"))
    assert(item_fluid.position_takers(graph, slot) == 1, "the recycler's generated recycling doesn't count")
    edge(slot, node("recipe", "gear-sorting", "AND"))
    assert(item_fluid.position_takers(graph, slot) == 2, "a hand-written recipe in the recycling category counts, since the game keeps it as it is")
    edge(slot, node("recipe", "gear-other-use", "AND"))
    assert(item_fluid.position_takers(graph, slot) == 3)
    -- An end product: made, never taken
    local lone = node("item", "pole", "OR")
    edge(node("recipe", "pole-make", "AND"), lone)
    assert(item_fluid.position_takers(graph, lone) == 0)
    data.raw.recipe = nil
end)

local function toy_fluid_graph(fluid_name)
    local graph, node, edge = toy_graph()
    local fluid_node = node("fluid", fluid_name, "OR")
    local temperature = node("fluid-temperature", key(fluid_name, "15"), "AND")
    edge(temperature, fluid_node)
    local create = node("fluid-create-temperature", key(fluid_name, "15"), "OR")
    edge(create, temperature)
    local craft = node("fluid-craft-temperature", key(fluid_name, "15"), "OR")
    edge(craft, create)
    edge(node("recipe", fluid_name .. "-make", "AND"), craft)
    edge(node("fluid-hold", fluid_name, "OR"), temperature)
    return graph, temperature, fluid_node, create, node, edge
end

test("fluid slots are single-temperature fluids made by recipes and mining, not pumped from tiles", function()
    data.raw.fluid = {}
    data.raw.resource = {
        well = {
            type = "resource",
            name = "well",
        },
    }
    add_fluid("gas")
    local graph, temperature, fluid_node, create, node, edge = toy_fluid_graph("gas")
    assert(item_fluid.fluid_slot_ok(graph, temperature))
    randomization_info.options.first_pass.blacklist[key("fluid", "gas")] = true
    assert(not item_fluid.fluid_slot_ok(graph, temperature), "blacklisted")
    randomization_info.options.first_pass.blacklist = {}
    -- Mined from a resource is fine
    edge(node("entity-mine", "well", "AND"), create)
    assert(item_fluid.fluid_slot_ok(graph, temperature))
    -- A fluid pumped from tiles keeps its position, even one recipes make too: pumping follows its identity, and nothing else could be made there early
    local pumped_graph, pumped_temperature, _, pumped_create, pumped_node, pumped_edge = toy_fluid_graph("brine")
    add_fluid("brine")
    assert(item_fluid.fluid_slot_ok(pumped_graph, pumped_temperature), "made by a recipe")
    pumped_edge(pumped_node("fluid-create-offshore-temperature", key("brine", "15"), "OR"), pumped_create)
    assert(not item_fluid.fluid_slot_ok(pumped_graph, pumped_temperature), "pumped")
    -- A second temperature (like steam's) isn't
    edge(node("fluid-temperature", key("gas", "500"), "AND"), fluid_node)
    assert(not item_fluid.fluid_slot_ok(graph, temperature))
    data.raw.resource = nil
end)

test("a fluid made by operating a machine (like a boiler's steam) isn't a slot", function()
    data.raw.fluid = {}
    add_fluid("gas")
    local graph, temperature, _, create, node, edge = toy_fluid_graph("gas")
    edge(node("entity-operate", "heater", "AND"), create)
    assert(not item_fluid.fluid_slot_ok(graph, temperature))
end)

test("checks find a material's nodes under the identity reflection put at its position, unless the identity is of the other form", function()
    data.raw.fluid = {}
    add_fluid("gas")
    data.raw.fluid.gas.default_temperature = 25
    add_fluid("rock-melt")
    -- Node types as logic's builder records them: the class each was built under is its canonical type
    local item_class = gutils.deconstruct(key("item", "x")).type
    local fluid_class = gutils.deconstruct(key("fluid", "x")).type
    local type_info = {
        ["thing"] = { canonical = item_class },
        ["thing-made"] = { canonical = item_class },
        ["liquid"] = { canonical = fluid_class },
        ["liquid-at"] = { canonical = fluid_class },
        ["liquid-in-range"] = { canonical = fluid_class },
        ["process"] = { canonical = "process" },
        ["machine-needing-liquid"] = { canonical = "machine" },
    }
    local renames = {
        [key("item", "gear")] = { type = "fluid", name = "oil" },
        [key("fluid", "oil")] = { type = "item", name = "gear" },
        [key("fluid", "sea")] = { type = "fluid", name = "gas" },
        [key("fluid", "lake")] = { type = "fluid", name = "rock-melt" },
        [key("item", "plate")] = { type = "item", name = "powder" },
    }
    -- Items: every node type built for the item follows it
    assert(item_fluid.final_node_key(key("thing", "plate"), renames, type_info) == key("thing", "powder"))
    assert(item_fluid.final_node_key(key("thing-made", "plate"), renames, type_info) == key("thing-made", "powder"))
    -- An identity of the other form: the position's nodes have no counterpart of their type, so their keys stay
    assert(item_fluid.final_node_key(key("thing", "gear"), renames, type_info) == key("thing", "gear"))
    assert(item_fluid.final_node_key(key("liquid", "oil"), renames, type_info) == key("liquid", "oil"))
    -- Fluids: by name, and with a temperature (the identity's own default) or a range (kept)
    assert(item_fluid.final_node_key(key("liquid", "sea"), renames, type_info) == key("liquid", "gas"))
    assert(item_fluid.final_node_key(key("liquid-at", key("sea", "15")), renames, type_info) == key("liquid-at", key("gas", "25")))
    assert(item_fluid.final_node_key(key("liquid-in-range", key("sea", key("nil", "nil"))), renames, type_info) == key("liquid-in-range", key("gas", key("nil", "nil"))))
    assert(item_fluid.final_node_key(key("liquid-at", key("lake", "15")), renames, type_info) == key("liquid-at", key("rock-melt", "15")))
    -- Other nodes, and everything without renames, keep their keys
    assert(item_fluid.final_node_key(key("process", "plate"), renames, type_info) == key("process", "plate"))
    assert(item_fluid.final_node_key(key("machine-needing-liquid", "heater"), renames, type_info) == key("machine-needing-liquid", "heater"))
    assert(item_fluid.final_node_key(key("thing", "plate"), nil, type_info) == key("thing", "plate"))
end)

----------------------------------------------------------------------------------------------------
-- Containers
----------------------------------------------------------------------------------------------------

local function entry(entry_type, name, amount)
    return {
        type = entry_type,
        name = name,
        amount = amount,
    }
end

test("containers are items a recipe fills with one fluid and another empties into that fluid again", function()
    local recipes = {
        ["brine-keg"] = {
            ingredients = {
                entry("fluid", "brine", 50),
                entry("item", "keg", 1),
            },
            results = {
                entry("item", "brine-keg", 1),
            },
        },
        ["empty-brine-keg"] = {
            ingredients = {
                entry("item", "brine-keg", 1),
            },
            results = {
                entry("fluid", "brine", 50),
                entry("item", "keg", 1),
            },
        },
        -- Emptying with a loss still counts
        ["oil-can"] = {
            ingredients = {
                entry("item", "can", 1),
                entry("fluid", "oil", 50),
            },
            results = {
                entry("item", "oil-can", 1),
            },
        },
        ["empty-oil-can"] = {
            ingredients = {
                entry("item", "oil-can", 1),
            },
            results = {
                entry("item", "can", 1),
                entry("fluid", "oil", 40),
            },
        },
        -- Emptying into another fluid, or without the container back, doesn't
        ["gas-can"] = {
            ingredients = {
                entry("fluid", "gas", 50),
                entry("item", "can", 1),
            },
            results = {
                entry("item", "gas-can", 1),
            },
        },
        ["vent-gas-can"] = {
            ingredients = {
                entry("item", "gas-can", 1),
            },
            results = {
                entry("fluid", "mist", 50),
                entry("item", "can", 1),
            },
        },
        ["burn-oil-can"] = {
            ingredients = {
                entry("item", "oil-can", 1),
            },
            results = {
                entry("fluid", "oil", 50),
            },
        },
        ["keg"] = {
            ingredients = {
                entry("item", "ingot", 1),
            },
            results = {
                entry("item", "keg", 1),
            },
        },
    }
    local containers = item_fluid.fluid_containers(recipes)
    assert(#containers == 2)
    assert(containers[1].filled == "brine-keg" and containers[1].held == "brine" and containers[1].vessel == "keg")
    assert(containers[1].fill == "brine-keg" and containers[1].empty == "empty-brine-keg")
    assert(containers[2].filled == "oil-can" and containers[2].held == "oil" and containers[2].vessel == "can")
    assert(containers[2].fill == "oil-can" and containers[2].empty == "empty-oil-can")
    -- The filled items stay put, and the recipes go by the fluid they hold
    local items = item_fluid.container_items(containers)
    assert(items["brine-keg"] and items["oil-can"] and items["keg"] == nil and items["gas-can"] == nil)
    local by_fluid = item_fluid.container_recipes(containers)
    assert(by_fluid.brine.fill["brine-keg"] and by_fluid.brine.empty["empty-brine-keg"] and by_fluid.oil.fill["oil-can"] and by_fluid.oil.empty["empty-oil-can"])
    assert(by_fluid.gas == nil)
end)

----------------------------------------------------------------------------------------------------
-- Machines taking fluids
----------------------------------------------------------------------------------------------------

local function count(list, value)
    local num = 0
    for _, entry in pairs(list) do
        if entry == value then
            num = num + 1
        end
    end
    return num
end

test("new fluid boxes cover the biggest recipe's ingredients and results first, then alternate", function()
    -- A machine with 1 in and 1 out whose biggest recipe takes 6 things and makes 2
    local directions = fluid_ports.box_directions(9, 1, 1, 6, 2, false)
    assert(#directions == 9)
    assert(count(directions, "input") == 7 and count(directions, "output") == 2, "5 inputs, 1 output, then 2 inputs and 1 output alternating")
    -- Shortfalls come first
    local first_six = { table.unpack(directions, 1, 6) }
    assert(count(first_six, "input") == 5 and count(first_six, "output") == 1)
end)

test("furnaces get one fluid input at most, since they pick recipes by one ingredient", function()
    local directions = fluid_ports.box_directions(5, 0, 0, 1, 1, true)
    assert(count(directions, "input") == 1 and count(directions, "output") == 4)
    local none_more = fluid_ports.box_directions(3, 1, 0, 1, 3, true)
    assert(count(none_more, "input") == 0)
end)

test("a recipe with a fluid leaves hand crafting's category and keeps its others", function()
    local hand = fluid_ports.HAND_CATEGORY
    local with_fluid = fluid_ports.HAND_CATEGORY_WITH_FLUID
    local recipe = {
        type = "recipe",
        name = "r",
        categories = { hand, "other-category" },
        ingredients = {
            { type = "item", name = "a", amount = 1 },
            { type = "fluid", name = "gas", amount = 10 },
        },
        results = {},
    }
    local cats = fluid_ports.categories_with_fluid(recipe)
    assert(cats[1] == with_fluid and cats[2] == "other-category" and #cats == 2)
    -- The engine's default category counts as hand crafting's
    recipe.categories = nil
    cats = fluid_ports.categories_with_fluid(recipe)
    assert(#cats == 1 and cats[1] == with_fluid)
    -- Fluid results count too, since the character has no fluid boxes at all
    recipe.ingredients = { { type = "item", name = "a", amount = 1 } }
    recipe.results = { { type = "fluid", name = "gas", amount = 10 } }
    assert(fluid_ports.categories_with_fluid(recipe) ~= nil)
    -- No fluid, or no hand crafting category: nothing changes
    recipe.results = { { type = "item", name = "b", amount = 1 } }
    assert(fluid_ports.categories_with_fluid(recipe) == nil)
    recipe.results = { { type = "fluid", name = "gas", amount = 10 } }
    recipe.categories = { "other-category" }
    assert(fluid_ports.categories_with_fluid(recipe) == nil)
    -- Already both: no duplicate
    recipe.categories = { hand, with_fluid }
    cats = fluid_ports.categories_with_fluid(recipe)
    assert(#cats == 1 and cats[1] == with_fluid)
end)

test("a pipe connection takes its whole tile, and a corner tile only offers its north or south side", function()
    local machine = {
        type = "assembling-machine",
        name = "m",
        collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
        fluid_boxes = {
            {
                production_type = "input",
                pipe_connections = {
                    {
                        flow_direction = "input",
                        direction = defines.direction.west,
                        position = { -1, -1 },
                    },
                },
            },
        },
    }
    local free = pipe_conns.get_available_pipe_connections(machine)
    -- A 3x3 machine has 8 connection points, one per edge tile; the taken corner tile is out, whichever way its connection faces
    assert(#free == 7, "expected 7 free points, got " .. #free)
    for _, point in pairs(free) do
        assert(not (point.position[1] == -1 and point.position[2] == -1), "the taken corner tile is free")
        assert(point.direction == defines.direction.north or point.direction == defines.direction.south or point.position[2] == 0, "a corner tile offers its east or west side")
    end
    -- A heat connection takes its whole tile
    machine.energy_source = {
        type = "heat",
        connections = {
            { position = { 1, 1 }, direction = defines.direction.south },
        },
    }
    assert(#pipe_conns.get_available_pipe_connections(machine) == 6)
    assert(#pipe_conns.get_available_pipe_connections(machine, true) == 7, "ignoring the energy source frees its tile")
end)

test("crafting machine ports go unseen until used: one connection per box, drawn only when connected, off without a fluid recipe", function()
    -- A 3x3 machine whose one input box connects on three tiles, the first through an underground connection
    local function machine(class, name)
        return {
            type = class,
            name = name,
            collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
            crafting_categories = { "other-category" },
            fluid_boxes = {
                {
                    production_type = "input",
                    volume = 200,
                    pipe_picture = {},
                    pipe_connections = {
                        {
                            flow_direction = "input",
                            direction = defines.direction.north,
                            position = { 0, -1 },
                            connection_type = "underground",
                            max_underground_distance = 2,
                        },
                        {
                            flow_direction = "input",
                            direction = defines.direction.south,
                            position = { 0, 1 },
                        },
                        {
                            flow_direction = "input",
                            direction = defines.direction.west,
                            position = { -1, 0 },
                        },
                    },
                },
            },
        }
    end
    -- The points the machine has free once its own box keeps one connection, which new boxes fill up to the reserved ones
    local trimmed = machine("assembling-machine", "trimmed")
    fluid_ports.hide_unused_ports(trimmed)
    local num_free = #pipe_conns.get_available_pipe_connections(trimmed)
    assert(num_free > #pipe_conns.get_available_pipe_connections(machine("assembling-machine", "untrimmed")), "dropped connections free their points")
    data.raw["assembling-machine"] = { m = machine("assembling-machine", "m") }
    data.raw.furnace = { f = machine("furnace", "f") }
    data.raw.recipe = {
        r = {
            type = "recipe",
            name = "r",
            categories = { "other-category" },
            ingredients = {
                { type = "item", name = "a", amount = 1 },
                { type = "fluid", name = "gas", amount = 10 },
            },
            results = {
                { type = "fluid", name = "brine", amount = 10 },
            },
        },
    }
    fluid_ports.add_crafting_machine_ports()
    local machines = {
        data.raw["assembling-machine"].m,
        data.raw.furnace.f,
    }
    for _, prot in pairs(machines) do
        local own = prot.fluid_boxes[1]
        assert(#own.pipe_connections == 1, prot.name .. ": the machine's own box keeps one connection, got " .. #own.pipe_connections)
        assert(own.pipe_connections[1].position[2] == 1 and own.pipe_connections[1].connection_type == nil, prot.name .. ": the first adjacent connection is the one kept")
        local num_expected = 1 + num_free - fluid_ports.RESERVED_POINTS
        assert(#prot.fluid_boxes == num_expected, prot.name .. ": expected " .. num_expected .. " boxes, got " .. #prot.fluid_boxes)
        local points = {}
        for _, box in pairs(prot.fluid_boxes) do
            assert(box.draw_only_when_connected == true, prot.name .. ": every box is drawn only when connected")
            assert(#box.pipe_connections == 1, prot.name .. ": every box has one connection")
            local connection = box.pipe_connections[1]
            local point = connection.position[1] .. "," .. connection.position[2] .. " facing " .. connection.direction
            assert(points[point] == nil, prot.name .. ": two boxes connect at " .. point)
            points[point] = true
        end
    end
    assert(data.raw["assembling-machine"].m.fluid_boxes_off_when_no_fluid_recipe == true, "an assembling machine's boxes are off without a fluid recipe")
    assert(data.raw.furnace.f.fluid_boxes_off_when_no_fluid_recipe == nil, "a furnace has no such property")
    -- A 1x1 machine whose own box connects twice on its only tile: no room for new boxes, but it still keeps one connection and hides it
    local function full_machine(name)
        local full = machine("assembling-machine", name)
        full.collision_box = { { -0.4, -0.4 }, { 0.4, 0.4 } }
        full.fluid_boxes[1].pipe_connections = {
            {
                flow_direction = "input",
                direction = defines.direction.north,
                position = { 0, 0 },
            },
            {
                flow_direction = "input",
                direction = defines.direction.south,
                position = { 0, 0 },
            },
        }
        return full
    end
    local full_trimmed = full_machine("full-trimmed")
    fluid_ports.hide_unused_ports(full_trimmed)
    local num_full_expected = 1 + math.max(#pipe_conns.get_available_pipe_connections(full_trimmed) - fluid_ports.RESERVED_POINTS, 0)
    local full = full_machine("full")
    data.raw["assembling-machine"].full = full
    fluid_ports.add_crafting_machine_ports()
    assert(#full.fluid_boxes == num_full_expected, "expected " .. num_full_expected .. " boxes on a full machine, got " .. #full.fluid_boxes)
    assert(#full.fluid_boxes[1].pipe_connections == 1)
    assert(full.fluid_boxes[1].draw_only_when_connected == true)
    assert(full.fluid_boxes_off_when_no_fluid_recipe == true)
    -- Running again changes nothing: the boxes already have one connection each
    local num_boxes = #data.raw["assembling-machine"].m.fluid_boxes
    fluid_ports.add_crafting_machine_ports()
    assert(#data.raw["assembling-machine"].m.fluid_boxes == num_boxes, "no new boxes on a second run")
    data.raw["assembling-machine"] = nil
    data.raw.furnace = nil
    data.raw.recipe = nil
end)

test("a recipe's fluids are numbered to one fluid box each: ingredients from 1, results from 1, items skipped", function()
    data.raw.recipe = {
        r = {
            type = "recipe",
            name = "r",
            ingredients = {
                { type = "item", name = "a", amount = 1 },
                { type = "fluid", name = "gas", amount = 10, fluidbox_index = 2 },
                { type = "fluid", name = "brine", amount = 5 },
            },
            results = {
                { type = "fluid", name = "syrup", amount = 1 },
                { type = "item", name = "b", amount = 1 },
                { type = "fluid", name = "mist", amount = 1 },
            },
        },
        dry = {
            type = "recipe",
            name = "dry",
            ingredients = {
                { type = "item", name = "a", amount = 1 },
            },
            results = {
                { type = "item", name = "b", amount = 1 },
            },
        },
    }
    assert(fluid_ports.index_recipe_fluids() == 1, "only the recipe with fluids changes")
    local recipe = data.raw.recipe.r
    assert(recipe.ingredients[1].fluidbox_index == nil, "items get no number")
    assert(recipe.ingredients[2].fluidbox_index == 1 and recipe.ingredients[3].fluidbox_index == 2, "ingredients count the input boxes from 1, whatever they had")
    assert(recipe.results[1].fluidbox_index == 1 and recipe.results[2].fluidbox_index == nil and recipe.results[3].fluidbox_index == 2, "results count the output boxes from 1")
    assert(fluid_ports.index_recipe_fluids() == 0, "numbering again changes nothing")
    data.raw.recipe = nil
end)

print(num_passed .. " tests passed")

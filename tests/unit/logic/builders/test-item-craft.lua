-- Plain-Lua regressions for folding recipe production and sharing trigger bases.
function table.deepcopy(object)
    local seen = {}
    local function copy(value)
        if type(value) ~= "table" then return value end
        if seen[value] ~= nil then return seen[value] end
        local result = {}
        seen[value] = result
        for k, v in pairs(value) do result[copy(k)] = copy(v) end
        return result
    end
    return copy(object)
end
function log(_) end
serpent = {
    block = tostring,
    line = tostring,
}
local seed = 1
package.loaded["src/lib/random/rng"] = {
    int = function(_, max)
        seed = (seed * 1103515245 + 12345) % 2147483648
        return math.floor(seed / 65536) % max + 1
    end,
}
local logic = {
    contexts = {},
    type_info = {
        start = {},
        room = { context = "room" },
        recipe = {},
        item = {},
        mine = {},
        ["item-craft"] = {},
        ["technology-trigger"] = { research_input = true },
        base = { relay = true },
        head = { relay = true },
        orand = { relay = true },
        sink = {},
    },
}
package.loaded["src/logic/state"] = logic
package.loaded["src/logic/init"] = logic
package.loaded["src/prototypes/data-utils"] = { get_prot = function() return nil end }
data = {
    raw = {
    planet = {},
    technology = {},
},
}
local gutils = require("src/lib/graph/graph-utils")
local top = require("src/lib/sort/context-sort")
local craft = require("src/logic/builders/item-craft")
local reductions = require("src/logic/analysis/reductions")
local costs = require("src/cost/graph-cost-core")
package.loaded["src/logic/builders/recycling-sources"] = { get = function() return { recycle = "maker" } end }
local promotion = require("src/randomizations/unified/skeleton/promotion")
local superpose = require("src/lib/graph/superpose")
local invariants = require("tests/graph-invariants")
local fx = require("tests/unit/logic/contexts/contexts-for-tests")
local key = gutils.key

local function node(graph, kind, name, op, extra)
    extra = extra or {}
    extra.op = op
    local result = key(gutils.add_node(graph, kind, name, extra))
    if op == "AND" then graph.sources[result] = true end
    return result
end
local function fixture()
    local g = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local start = node(g, "start", "", "AND")
    logic.contexts = {}
    for _, name in pairs({
        "A",
        "B",
        "C",
    }) do
        local room = node(g, "room", name, "OR")
        gutils.add_edge(g, start, room)
        logic.contexts[name] = true
    end
    local item = node(g, "item", "p", "OR", {
        prot = "item: p",
        class = "item",
        cost = 0.2,
    })
    local crafting = node(g, "item-craft", "p", "OR", {
        prot = "item: p",
        class = "item",
    })
    gutils.add_edge(g, crafting, item, { amount = 1 })
    for i, room in pairs({
        "A",
        "B",
    }) do
        local recipe = node(g, "recipe", room, "AND", {
            prot = "recipe: " .. room,
            cost = i * 2,
            slot_additional_cost = i,
        })
        gutils.add_edge(g, key("room", room), recipe)
        gutils.add_edge(g, recipe, crafting, {
            amount = i * 3,
            inds = { i },
        })
    end
    local mine = node(g, "mine", "C", "AND", {
        cost = 5,
        prot = "resource: C",
    })
    gutils.add_edge(g, key("room", "C"), mine)
    gutils.add_edge(g, mine, item, { amount = 2 })
    return g
end
local function same_contexts(a, b)
    for c, _ in pairs(a or {}) do assert((b or {})[c] ~= nil, "lost context " .. c) end
    for c, _ in pairs(b or {}) do assert((a or {})[c] ~= nil, "added context " .. c) end
end
local function structure(g)
    local lines = {}
    local function fields(object)
        local entries = {}
        for k, v in pairs(object) do
            if k ~= "pre" and k ~= "dep" and k ~= "num_pre" then
                local value = tostring(v)
                if type(v) == "table" then
                    local parts = {}
                    for i, part in pairs(v) do table.insert(parts, tostring(i) .. "=" .. tostring(part)) end
                    table.sort(parts)
                    value = table.concat(parts, ",")
                end
                table.insert(entries, k .. "=" .. value)
            end
        end
        table.sort(entries)
        return table.concat(entries, " ")
    end
    for k, n in pairs(g.nodes) do table.insert(lines, "node " .. k .. " " .. fields(n)) end
    for k, e in pairs(g.edges) do table.insert(lines, "edge " .. k .. " " .. fields(e)) end
    table.sort(lines)
    return table.concat(lines, "\n")
end
local passed = 0
local function test(name, fn)
    fn()
    passed = passed + 1
    print("ok - " .. name)
end
local function compare(full, reduced)
    for _, extra in pairs({
        {},
        {
        complex_contexts = true,
        home_contexts = true,
    },
    }) do
        local a = top.sort(full, nil, nil, extra)
        local b = top.sort(reduced, nil, nil, extra)
        for k, _ in pairs(reduced.nodes) do same_contexts(a.node_to_context_inds[k], b.node_to_context_inds[k]) end
        same_contexts(a.node_to_context_inds[key("item-craft", "p")], craft.context_inds(reduced, b, key("item-craft", "p")))
    end
    invariants.test(reduced)
end

test("several recipe alternatives fold, crafting queries exclude mining, and expansion restores all fields", function()
    local full = fixture()
    local reduced = table.deepcopy(full)
    assert(craft.contract(reduced) == 1)
    assert(reduced.nodes[key("item-craft", "p")] == nil)
    compare(full, reduced)
    local sorted = top.sort(reduced)
    assert(sorted.node_to_context_inds[key("item", "p")][top.simple_context("C")] ~= nil)
    assert(craft.context_inds(reduced, sorted, key("item-craft", "p"))[top.simple_context("C")] == nil)
    assert(reductions.expand_all(reduced) == 1)
    assert(structure(full) == structure(reduced))
end)

test("amounts and ordinary/slot prices stay the same; recipe-free prices still exclude production", function()
    local full = fixture()
    local reduced = table.deepcopy(full)
    craft.contract(reduced)
    for _, slot in pairs({
        false,
        true,
    }) do
        local a = costs.compute(full, { "anywhere" }, function(_, c) return { c } end, nil, slot)
        local b = costs.compute(reduced, { "anywhere" }, function(_, c) return { c } end, nil, slot)
        for k, _ in pairs(reduced.nodes) do
            assert(math.abs(a[k].anywhere - b[k].anywhere) < 1e-6, k)
        end
        local a_raw = costs.price_without_recipes(full, a, key("item", "p"), "anywhere", slot)
        local b_raw = costs.price_without_recipes(reduced, b, key("item", "p"), "anywhere", slot)
        assert(math.abs(a_raw - b_raw) < 1e-6)
        assert(math.abs(b_raw - 2.7) < 1e-6)
    end
end)

test("actual craft triggers keep their OR, and hidden-from-stats direct recipes do not enter craft queries", function()
    local g = fixture()
    local trigger = node(g, "technology-trigger", "t", "OR")
    gutils.add_edge(g, key("item-craft", "p"), trigger)
    assert(craft.contract(g) == 0)
    g = fixture()
    gutils.add_edge(g, key("recipe", "B"), key("item", "p"), { amount = 7 })
    -- A collision stays in its original shape rather than losing either edge.
    assert(craft.contract(g) == 0)
    g = fixture()
    local hidden = node(g, "recipe", "hidden", "AND")
    gutils.add_edge(g, key("room", "C"), hidden)
    gutils.add_edge(g, hidden, key("item", "p"), { amount = 1 })
    assert(craft.contract(g) == 1)
    local sorted = top.sort(g)
    assert(craft.context_inds(g, sorted, key("item-craft", "p"))[top.simple_context("C")] == nil)
end)

test("empty production groups stay unreachable, and costs, abilities and research barriers prevent folding", function()
    local g = fixture()
    for _, edge in pairs(craft.providers(g, "p")) do gutils.remove_edge(g, gutils.ekey(edge.edge)) end
    assert(craft.contract(g) == 1)
    assert(next(craft.context_inds(g, top.sort(g), key("item-craft", "p"))) == nil)
    craft.expand(g, "p")
    assert(g.nodes[key("item-craft", "p")].num_pre == 0)
    g = fixture()
    g.nodes[key("item-craft", "p")].cost = 1
    assert(craft.contract(g) == 0)
    g = fixture()
    craft.providers(g, "p")[1].edge.abilities = fx.edge({ [1] = true })
    assert(craft.contract(g) == 0)
    g = fixture()
    logic.type_info.recipe.research_input = true
    assert(craft.contract(g) == 0)
    logic.type_info.recipe.research_input = nil
    g = fixture()
    logic.type_info["item-craft"].context = true
    assert(craft.contract(g) == 0)
    logic.type_info["item-craft"].context = nil
    g = fixture()
    g.nodes[key("item-craft", "p")].op = "AND"
    assert(craft.contract(g) == 0)
end)

local function option_graph(reduced)
    local g = fixture()
    if reduced == true then craft.contract(g) end
    local source = craft.add_option(g, "p")
    local sink = node(g, "sink", "", "OR")
    local edge = gutils.add_edge(g, source, sink, {
        starts_detached = true,
        trigger_option = {
        kind = "craft-item",
        target = "p",
    },
    })
    gutils.make_orands(g)
    local orand_key = key("orand", gutils.ekey(edge))
    local conns = gutils.subdivide_base_head(g, gutils.ekey(gutils.unique_pre(g, g.nodes[orand_key])))
    if reduced == true then assert(craft.fuse_options(g) == 1) end
    return g, key(conns.base)
end

test("trigger bases share production connectors, preserve OR alternatives and stay smaller with multiple recipes", function()
    local full, full_base = option_graph(false)
    local reduced, reduced_base = option_graph(true)
    invariants.test(reduced)
    assert(reduced.nodes[reduced_base].op == "OR")
    assert(gutils.get_owner(reduced, reduced.nodes[reduced_base]).name == "p")
    assert(reduced.nodes[key("item-craft", "p")] == nil)
    for _, extra in pairs({
        {},
        {
        complex_contexts = true,
        home_contexts = true,
    },
    }) do
        local a = top.sort(full, nil, nil, extra)
        local b = top.sort(reduced, nil, nil, extra)
        same_contexts(a.node_to_context_inds[full_base], b.node_to_context_inds[reduced_base])
        same_contexts(a.node_to_context_inds[key("item", "p")], b.node_to_context_inds[key("item", "p")])
        assert((b.node_to_context_inds[reduced_base] or {})[top.simple_context("C")] == nil)
    end
    local a_count, b_count = 0, 0
    for _, _ in pairs(full.nodes) do a_count = a_count + 1 end
    for _, _ in pairs(reduced.nodes) do b_count = b_count + 1 end
    assert(a_count - b_count == 2, "candidate should save two nodes regardless of provider count")
    local disabled = table.deepcopy(reduced)
    local provider = craft.providers(disabled, "p")[1]
    for edge_key, _ in pairs(table.deepcopy(disabled.nodes[provider.branch_key].dep)) do
        gutils.remove_edge(disabled, edge_key)
    end
    local sorted = top.sort(disabled)
    assert(sorted.node_to_context_inds[reduced_base][top.simple_context("A")] == nil)
    assert(sorted.node_to_context_inds[reduced_base][top.simple_context("B")] ~= nil)
end)

test("derived recycling still pins ingredients through folded production and shared trigger branches", function()
    old_data_raw = {}
    for _, with_option in pairs({
        false,
        true,
    }) do
        local g = fixture()
        -- p is mined only in C; recycling salvaged q is its sole production route in A.
        for _, provider in pairs(craft.providers(g, "p")) do
            gutils.remove_edge(g, gutils.ekey(provider.edge))
        end
        g.nodes[key("item", "p")].mechanic = true
        local q = node(g, "item", "q", "OR")
        local salvage = node(g, "mine", "salvage", "AND")
        gutils.add_edge(g, key("room", "A"), salvage)
        gutils.add_edge(g, salvage, q)
        local maker = node(g, "recipe", "maker", "AND")
        local ingredient = gutils.add_edge(g, key("item", "p"), maker)
        gutils.add_edge(g, maker, q)
        local recycle = node(g, "recipe", "recycle", "AND")
        gutils.add_edge(g, q, recycle)
        gutils.add_edge(g, recycle, key("item-craft", "p"), { amount = 0.25 })
        assert(craft.contract(g) == 1)
        local option_edge
        if with_option == true then
            local source = craft.add_option(g, "p")
            option_edge = gutils.add_edge(g, source, node(g, "sink", "", "OR"), {
                starts_detached = true,
                trigger_option = {
                    kind = "craft-item",
                    target = "p",
                },
            })
        end
        gutils.make_orands(g)
        gutils.subdivide_base_head(g, gutils.ekey(ingredient))
        if option_edge ~= nil then
            local connector = g.nodes[key("orand", gutils.ekey(option_edge))]
            gutils.subdivide_base_head(g, gutils.ekey(gutils.unique_pre(g, connector)))
            craft.fuse_options(g)
        end
        local prom = promotion.new({ graph = g })
        prom.promise_mechanics()
        assert(prom.pins_for(maker)[key("item", "p")] == true, "the production role must still pin its inverted recipe's ingredient")
    end
end)

test("temporary claiming groups are discarded before first pass ranks physical positions", function()
    local g = fixture()
    craft.contract(g)
    local source = craft.add_option(g, "p")
    gutils.add_edge(g, source, node(g, "sink", "", "OR"), {
        starts_detached = true,
        trigger_option = {
            kind = "craft-item",
            target = "p",
        },
    })
    gutils.make_orands(g)
    gutils.detach_starting_heads(g)
    craft.discard_options(g)
    invariants.test(g)
    assert(g.nodes[source] == nil)
    local sorted = top.sort(g)
    for _, node_key in pairs(sorted.pebble_keys) do
        assert(g.nodes[node_key] ~= nil)
        assert(g.nodes[node_key].craft_option_only == nil)
    end
    assert(next(sorted.node_to_context_inds[key("sink", "")] or {}) == nil)
end)

test("80 generated games preserve surviving and virtual crafting contexts in different sort orders", function()
    for game = 1, 80 do
        local full = fixture()
        for i = 1, 8 do
            local name = "p" .. i
            local item = node(full, "item", name, "OR")
            local crafting = node(full, "item-craft", name, "OR")
            gutils.add_edge(full, crafting, item, { amount = 1 })
            for j = 1, 1 + (game + i) % 3 do
                local recipe = node(full, "recipe", name .. j, "AND")
                gutils.add_edge(full, key("room", ({
                    "A",
                    "B",
                    "C",
                })[1 + (game + i + j) % 3]), recipe)
                if i > 1 then gutils.add_edge(full, key("item", "p" .. (i - 1)), recipe) end
                gutils.add_edge(full, recipe, crafting, { amount = j })
            end
            if (game + i) % 2 == 0 then gutils.add_edge(full, key("mine", "C"), item) end
        end
        local reduced = table.deepcopy(full)
        assert(craft.contract(reduced) == 9)
        for _, extra in pairs({
            {},
            {
            complex_contexts = true,
            home_contexts = true,
            choose_randomly = true,
        },
        }) do
            seed = game
            local a = top.sort(full, nil, nil, extra)
            seed = game + 41
            local b = top.sort(reduced, nil, nil, extra)
            for node_key, _ in pairs(full.nodes) do
                same_contexts(a.node_to_context_inds[node_key], craft.context_inds(reduced, b, node_key))
            end
        end
        assert(reductions.expand_all(reduced) == 9)
        assert(structure(full) == structure(reduced))
    end
end)

test("combining worlds expands folded production before comparing their edges", function()
    local old = fixture()
    local new = table.deepcopy(old)
    local old_edge = craft.providers(new, "p")[1].edge
    gutils.remove_edge(new, gutils.ekey(old_edge))
    local expected = superpose.union(new, old)
    local folded_old = table.deepcopy(old)
    local folded_new = table.deepcopy(new)
    craft.contract(folded_old)
    craft.contract(folded_new)
    local result = superpose.union(folded_new, folded_old)
    invariants.test(result.graph)
    assert(structure(result.graph) == structure(expected.graph))
    assert(next(result.not_into_or) == nil)
    assert(folded_new.nodes[key("item-craft", "p")] == nil)
    assert(folded_old.nodes[key("item-craft", "p")] == nil)
end)

test("new recycled ingredients back both the folded item and its trigger candidate after an old producer is lost", function()
    old_data_raw = {}
    local g = fixture()
    local y = node(g, "item", "y", "OR")
    local y_craft = node(g, "item-craft", "y", "OR")
    gutils.add_edge(g, y_craft, y, { amount = 1 })
    local gate = key("room", "B")
    for i = 1, 6 do
        local step = node(g, "recipe", "step" .. i, "AND")
        gutils.add_edge(g, gate, step)
        gate = node(g, "item", "gate" .. i, "OR")
        gutils.add_edge(g, step, gate)
    end
    local original = node(g, "recipe", "original-y", "AND")
    gutils.add_edge(g, gate, original)
    gutils.add_edge(g, original, y_craft, { amount = 1 })
    local q = node(g, "item", "q", "OR")
    local salvage = node(g, "mine", "salvage", "AND")
    gutils.add_edge(g, key("room", "B"), salvage)
    gutils.add_edge(g, salvage, q)
    local maker = node(g, "recipe", "maker", "AND")
    local ingredient = gutils.add_edge(g, key("item", "p"), maker)
    gutils.add_edge(g, maker, q)
    local recycle = node(g, "recipe", "recycle", "AND")
    gutils.add_edge(g, q, recycle)
    gutils.add_edge(g, recycle, key("item-craft", "p"), { amount = 0.25 })
    craft.contract(g)
    local source = craft.add_option(g, "y")
    local option = gutils.add_edge(g, source, node(g, "sink", "", "OR"), {
        starts_detached = true,
        trigger_option = {
            kind = "craft-item",
            target = "y",
        },
    })
    local false_key = node(g, "false", "", "OR")
    logic.type_info["false"] = {}
    gutils.make_orands(g)
    gutils.subdivide_base_head(g, gutils.ekey(ingredient))
    local option_connector = g.nodes[key("orand", gutils.ekey(option))]
    local base = gutils.subdivide_base_head(g, gutils.ekey(gutils.unique_pre(g, option_connector))).base
    craft.fuse_options(g)
    local production_branch = craft.providers(g, "y")[1].branch_key
    local prom = promotion.new({ graph = g })
    prom.record_ingredients(maker, { y })
    local context = top.simple_context("B")
    assert(prom.try_rewires({
        {
            node_key = production_branch,
            remove = prom.pre_keys_of(production_branch),
            add = false_key,
        },
    }, false, function()
        return prom.is_solvent(y, context) and prom.is_solvent(key(base), context)
    end), "the new recycled ingredient must back the item and the craft option without its old production branch")
end)

print(passed .. " tests passed")

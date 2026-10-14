-- Plain-Lua regressions for ingredient uses represented by shared pool sources.
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
local pool = require("src/randomizations/unified/handler-helpers/ingredient-pool")
local customization = require("src/config/customization")
local policy = require("src/config/graph-customization")
local rules_module = require("src/randomizations/unified/ingredient-blacklists")
local costs = require("src/cost/graph-cost-core")
local invariants = require("tests/graph-invariants")
local key = gutils.key
logic.type_info["fluid-temperature-range"] = {}
logic.type_info["recipe-ingredient-kept-spot"] = {}
local function node(g, kind, name, op, extra)
    extra = extra or {}
    extra.op = op
    local k = key(gutils.add_node(g, kind, name, extra))
    if op == "AND" then g.sources[k] = true end
    return k
end
local function material(source)
    if source.type == "fluid-temperature-range" then
        return {
            type = "fluid",
            name = gutils.deconstruct(source.name).type,
        }
    end
    return source
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
    }) do
        local room = node(g, "room", name, "OR")
        gutils.add_edge(g, start, room)
        logic.contexts[name] = true
    end
    local ore = node(g, "item", "ore", "OR", { cost = 3 })
    gutils.add_edge(g, key("room", "A"), ore)
    local blocked = node(g, "item", "blocked", "OR")
    local unreachable = node(g, "item", "unreachable", "OR")
    local early = node(g, "fluid-temperature-range", "liquid: 10", "OR", { cost = 2 })
    local late = node(g, "fluid-temperature-range", "liquid: 20", "OR", { cost = 7 })
    gutils.add_edge(g, key("room", "A"), early)
    gutils.add_edge(g, key("room", "B"), late)
    local recipes = {}
    for i, name in pairs({
        "r1",
        "r2",
        "r3",
        "r4",
        "hidden",
        "no-count",
    }) do
        local recipe = node(g, "recipe", name, "AND", { prot = key("recipe", name) })
        recipes[name] = {
            name = name,
            hidden = name == "hidden",
            ingredients = {},
        }
        gutils.add_edge(g, key("room", "A"), recipe)
        gutils.add_edge(g, ore, recipe, {
            amount = 8,
            inds = { [1] = true },
            self_loop = true,
        })
        local range = i % 2 == 0 and late or early
        gutils.add_edge(g, range, recipe, {
            amount = 5,
            inds = { [2] = true },
        })
        gutils.add_edge(g, blocked, recipe)
        gutils.add_edge(g, unreachable, recipe)
    end
    local rules = rules_module.of({
        kept_pre = {
            [ore] = true,
            [unreachable] = true,
        },
        kept_dep = {
            [key("recipe", "r3")] = true,
            [key("recipe", "r4")] = true,
        },
        blacklisted_pre = { [blocked] = true },
        blacklisted_dep = { [key("recipe", "no-count")] = true },
    })
    return g, recipes, rules
end
local passed = 0
local function test(name, fn)
    fn()
    passed = passed + 1
    print("ok - " .. name)
end
local function copies(m) return m.type == "fluid" and 4 or 1 end
local function same(a, b)
    for c, _ in pairs(a or {}) do assert((b or {})[c] ~= nil, "lost " .. c) end
    for c, _ in pairs(b or {}) do assert((a or {})[c] ~= nil, "added " .. c) end
end
local function expanded(g, spots, sorted, can_claim)
    local entries = {}
    for _, spot in pairs(spots) do
        local source = g.nodes[spot.source_key]
        local dep = node(g, "recipe-ingredient-kept-spot", gutils.concat({
            spot.recipe_name,
            spot.source_key,
        }), "AND", {
            prot = key("recipe", spot.recipe_name),
            spoof = true,
        })
        local edge = gutils.add_edge(g, spot.source_key, dep)
        if next(sorted.node_to_context_inds[spot.source_key] or {}) ~= nil and can_claim(source, g.nodes[dep]) then
            local conns = gutils.subdivide_base_head(g, gutils.ekey(edge))
            table.insert(entries, {
                base_key = key(conns.base),
                num_copies = copies(material(source)),
            })
        end
    end
    return entries
end
local function counted(g, entries)
    local counts = {}
    for _, entry in pairs(entries) do
        local source = key(gutils.get_owner(g, g.nodes[entry.base_key]))
        counts[source] = (counts[source] or 0) + entry.num_copies
    end
    return counts
end

test("collection is stable metadata, excludes hidden/non-counting/blocked uses, and keeps real edges", function()
    local g, recipes, rules = fixture()
    local before = 0
    for _, _ in pairs(g.nodes) do before = before + 1 end
    local spots = pool.collect(g, recipes, rules, material)
    assert(#spots == 10)
    for _, spot in pairs(spots) do
        assert(spot.recipe_name ~= "hidden" and spot.recipe_name ~= "no-count")
        assert(spot.source_key ~= key("item", "blocked"))
    end
    local after = 0
    for _, _ in pairs(g.nodes) do after = after + 1 end
    assert(before == after)
    local edge = g.edges[gutils.ekey({
        start = key("item", "ore"),
        stop = key("recipe", "r1"),
    })]
    assert(edge.amount == 8 and edge.inds[1] == true and edge.self_loop)
    invariants.test(g)
end)

test("selected reachable uses preserve multiplicities and distinct ranges while sharing bases", function()
    local g, recipes, rules = fixture()
    local spots = pool.collect(g, recipes, rules, material)
    local sorted = top.sort(g)
    local function can_claim(source, dep)
        assert(dep.type == "recipe-ingredient-kept-spot" and dep.spoof == true)
        assert(dep.prot == key("recipe", gutils.deconstruct(dep.prot).name))
        return dep.prot ~= key("recipe", "r2")
    end
    local full = table.deepcopy(g)
    local old_entries = expanded(full, spots, sorted, can_claim)
    local entries, num_bases = pool.add(g, spots, sorted, can_claim, copies, material)
    assert(#entries == 5 and num_bases == 3)
    local a, b = counted(full, old_entries), counted(g, entries)
    for source, count in pairs(a) do assert(b[source] == count) end
    for source, count in pairs(b) do assert(a[source] == count) end
    assert(b[key("item", "ore")] == 3)
    assert(b[key("fluid-temperature-range", "liquid: 10")] == 4)
    assert(b[key("fluid-temperature-range", "liquid: 20")] == 4)
    for _, entry in pairs(entries) do
        local base = g.nodes[entry.base_key]
        assert(base.pool_only == true and base.old_head == nil and next(base.dep) == nil and base.num_pre == 1)
    end
    for _, n in pairs(g.nodes) do assert(n.type ~= "recipe-ingredient-kept-spot" and n.type ~= "head") end
    invariants.test(g)
end)

test("surviving contexts, supply witnesses and ordinary/slot costs agree with expanded pool routes", function()
    local original, recipes, rules = fixture()
    local spots = pool.collect(original, recipes, rules, material)
    local full, reduced = table.deepcopy(original), table.deepcopy(original)
    local can_claim = function() return true end
    local sorted = top.sort(original)
    local old_entries = expanded(full, spots, sorted, can_claim)
    local entries = pool.add(reduced, spots, sorted, can_claim, copies, material)
    for _, extra in pairs({
        {},
        {
            complex_contexts = true,
            home_contexts = true,
        },
    }) do
        local a, b = top.sort(full, nil, nil, extra), top.sort(reduced, nil, nil, extra)
        for k, _ in pairs(original.nodes) do same(a.node_to_context_inds[k], b.node_to_context_inds[k]) end
        for i, entry in pairs(old_entries) do
            same(a.node_to_context_inds[entry.base_key], b.node_to_context_inds[entries[i].base_key])
        end
        for _, entry in pairs(entries) do
            for _, rank in pairs(b.node_to_context_inds[entry.base_key] or {}) do
                assert(b.pebble_keys[rank] == entry.base_key)
                local path = top.path(reduced, { rank }, b)
                assert(path ~= nil)
            end
        end
        assert(#b.pebble_keys < #a.pebble_keys)
    end
    for _, slot in pairs({
        false,
        true,
    }) do
        local a = costs.compute(full, { "anywhere" }, function(_, c) return { c } end, nil, slot)
        local b = costs.compute(reduced, { "anywhere" }, function(_, c) return { c } end, nil, slot)
        for k, _ in pairs(original.nodes) do
            if a[k].anywhere ~= nil then assert(math.abs(a[k].anywhere - b[k].anywhere) < 1e-6, k) end
        end
        for i, entry in pairs(old_entries) do
            assert(math.abs(a[entry.base_key].anywhere - b[entries[i].base_key].anywhere) < 1e-6)
        end
    end
end)

test("pool candidates need no old head or bounds; ordinary candidates retain their original bounds", function()
    local g, recipes, rules = fixture()
    local entries = pool.add(g, pool.collect(g, recipes, rules, material), top.sort(g), function() return true end, copies, material)
    for _, entry in pairs(entries) do
        local base = g.nodes[entry.base_key]
        local m = material(gutils.get_owner(g, base))
        local ing = pool.ingredient(g, base, m, recipes)
        assert(ing.name == m.name and ing.type == m.type and ing.amount == 1)
        assert(ing.minimum_temperature == nil and ing.maximum_temperature == nil)
    end
    local source = key("fluid-temperature-range", "liquid: 10")
    local dep = node(g, "recipe", "ordinary", "AND")
    local ing = {
        type = "fluid",
        name = "liquid",
        amount = 15,
        minimum_temperature = 10,
        maximum_temperature = 20,
    }
    recipes.ordinary = { ingredients = { ing } }
    local edge = gutils.add_edge(g, source, dep, {
        amount = 15,
        inds = { [1] = true },
    })
    local conns = gutils.subdivide_base_head(g, gutils.ekey(edge))
    assert(pool.ingredient(g, conns.base, material(g.nodes[source]), recipes) == ing)
    local spoof = node(g, "recipe-shape-fluid-slot", "liquid", "AND", { spoof = true })
    local edge = gutils.add_edge(g, source, spoof)
    local conns = gutils.subdivide_base_head(g, gutils.ekey(edge))
    assert(pool.ingredient(g, conns.base, material(g.nodes[source]), recipes).amount == 1)
end)

test("rejected, zero-weight, missing and unreachable sources create no new nodes", function()
    local g, recipes, rules = fixture()
    local spots = pool.collect(g, recipes, rules, material)
    local entries, count = pool.add(g, spots, top.sort(g), function() return false end, copies, material)
    assert(#entries == 0 and count == 0)
    entries, count = pool.add(g, spots, top.sort(g), function() return true end, function() return 0 end, material)
    assert(#entries == 0 and count == 0)
    entries, count = pool.add(g, {}, top.sort(g), function() error("empty pool must not select") end, copies, material)
    assert(#entries == 0 and count == 0)
end)
test("real customization selects metadata destinations with the original recipe prototype", function()
    local original, recipes, rules = fixture()
    local spots = pool.collect(original, recipes, rules, material)
    local raw = {
        recipe = recipes,
        item = {},
    }
    for _, n in pairs(original.nodes) do
        if n.type == "item" then raw.item[n.name] = {
            type = "item",
            name = n.name,
        } end
    end
    for _, recipe in pairs(recipes) do recipe.type = "recipe" end
    local classes = {
        item = { item = true },
        recipe = { recipe = true },
    }
    for _, instruction in pairs({
        "PARAM:graph/recipe-ingredients.amount=0",
        "PARAM:graph/recipe-ingredients.amount=50",
        "PARAM:graph/recipe-ingredients.amount=100",
        "EXCLUDE:graph/recipe-ingredients:prototype/recipe/r3",
        "EXCLUDE:graph/recipe-ingredients:prototype/item/ore",
    }) do
        local state = customization.parse(instruction)
        local function can_claim(source, dep)
            return policy.selected("recipe-ingredients", dep) and not policy.excluded("recipe-ingredients", source)
        end
        policy.initialize(state, raw, classes, 1)
        local full = table.deepcopy(original)
        local old_entries = expanded(full, spots, top.sort(original), can_claim)
        policy.initialize(state, raw, classes, 1)
        local reduced = table.deepcopy(original)
        local entries = pool.add(reduced, spots, top.sort(original), can_claim, copies, material)
        local a, b = counted(full, old_entries), counted(reduced, entries)
        for source, count in pairs(a) do assert(b[source] == count, instruction) end
        for source, count in pairs(b) do assert(a[source] == count, instruction) end
    end
end)

print(passed .. " tests passed")

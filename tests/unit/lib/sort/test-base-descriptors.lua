-- Source witnesses replace ordinary-base sorting state while connector metadata remains available.
-- Honor deterministic sort requests in these fixtures.
DO_FRODO_FIXES = true
function table.deepcopy(object)
    local seen = {}
    local function copy(value)
        if type(value) ~= "table" then return value end
        if seen[value] ~= nil then return seen[value] end
        local result = {}
        seen[value] = result
        for key, child in pairs(value) do result[copy(key)] = copy(child) end
        return setmetatable(result, getmetatable(value))
    end
    return copy(object)
end
function log(_) end
serpent = { block = tostring }
data = { raw = { technology = {} } }
local logic = {
    contexts = { A = true, B = true },
    type_info = {
        start = {}, room = { context = "room" }, item = {}, recipe = {},
        base = { relay = true }, head = { relay = true }, orand = { relay = true },
        research = { research_input = true }, technology = { context = true, home_carrier = true },
    },
}
package.loaded["src/logic/state"] = logic
package.loaded["src/logic/init"] = logic
package.loaded["src/lib/random/rng"] = { int = function(_, max) return max end }
package.loaded["src/prototypes/data-utils"] = { get_prot = function() return nil end }
local gutils = require("src/lib/graph/graph-utils")
local top = require("src/lib/sort/context-sort")
local promotion = require("src/randomizations/unified/skeleton/promotion")
local fx = require("tests/unit/logic/contexts/contexts-for-tests")

local passed = 0
local function test(name, run)
    run()
    passed = passed + 1
    print("ok - " .. name)
end
local function node(graph, node_type, name, op, extra)
    extra = extra or {}
    extra.op = op
    return gutils.key(gutils.add_node(graph, node_type, name, extra))
end
local function fixture()
    local graph = { nodes = {}, edges = {}, sources = {} }
    local start = node(graph, "start", "", "AND")
    graph.sources[start] = true
    local room = node(graph, "room", "A", "OR")
    gutils.add_edge(graph, start, room)
    local source = node(graph, "item", "x", "OR")
    gutils.add_edge(graph, room, source)
    local recipe = node(graph, "recipe", "r", "AND")
    local edge = gutils.add_edge(graph, source, recipe, { amount = 3, abilities = fx.edge({ [2] = false }), inds = { [2] = true } })
    local pair = gutils.subdivide_base_head(graph, gutils.ekey(edge))
    local output = node(graph, "item", "y", "OR", { mechanic = true })
    gutils.add_edge(graph, recipe, output)
    return graph, source, recipe, gutils.key(pair.base), gutils.key(pair.head), output
end
local function sort(graph, sharing, homes)
    homes = homes or { ids = { 1 }, sets = { [1] = { rooms = { A = true, B = true }, discovered = {} } }, of = {} }
    top.share_base_contexts = sharing
    return top.sort(graph, nil, nil, { complex_contexts = true, home_contexts = homes ~= nil, home_sets = homes, choose_randomly = false })
end
local function same_sets(before, after, label)
    assert((before == nil) == (after == nil), "missing set " .. label)
    for key, _ in pairs(before or {}) do assert((after or {})[key] ~= nil, "lost requirement " .. label) end
    for key, _ in pairs(after or {}) do assert((before or {})[key] ~= nil, "gained requirement " .. label) end
end
local function same_requirements(graph, watched)
    top.share_base_contexts = false
    local rooms_before = top.rooms_needed(graph)
    local watched_before = top.watched_needed(graph, watched)
    top.share_base_contexts = true
    local rooms_after = top.rooms_needed(graph)
    local watched_after = top.watched_needed(graph, watched)
    for node_key, _ in pairs(graph.nodes) do
        for room, _ in pairs(logic.contexts) do
            same_sets(rooms_before(node_key, top.simple_context(room)), rooms_after(node_key, top.simple_context(room)), node_key)
        end
        same_sets(watched_before(node_key), watched_after(node_key), node_key)
    end
end
local function same_contexts(graph, before, after)
    for node_key, _ in pairs(graph.nodes) do
        local a, b = before.node_to_context_inds[node_key], after.node_to_context_inds[node_key]
        for context, _ in pairs(a) do assert(b[context] ~= nil, "lost " .. node_key) end
        for context, _ in pairs(b) do assert(a[context] ~= nil, "gained " .. node_key) end
    end
end

test("base queries share source storage and point at real witnesses", function()
    local graph, source, _, base, _, output = fixture()
    local before, after = sort(graph, false), sort(graph, true)
    same_contexts(graph, before, after)
    assert(top.num_contexts(before) == top.num_contexts(after), "descriptor contexts count as represented contexts")
    assert(rawget(after.node_to_context_inds, base) == nil)
    assert(after.node_to_context_inds[base] == after.node_to_context_inds[source])
    assert(graph.nodes[base].amount == 3 and graph.nodes[base].inds[2])
    for _, node_key in pairs(after.pebble_keys) do assert(node_key ~= base) end
    for _, ind in pairs(after.node_to_context_inds[base]) do assert(after.pebble_keys[ind] == source) end
    local context, ind = next(after.node_to_context_inds[output])
    local path = top.path(graph, { ind }, after)
    assert(#path.path > 0 and context ~= nil)
end)
test("simple sorts also share source witnesses without changing reachability", function()
    local graph, source, _, base = fixture()
    top.share_base_contexts = false
    local before = top.sort(graph, nil, nil, { choose_randomly = false })
    top.share_base_contexts = true
    local after = top.sort(graph, nil, nil, { choose_randomly = false })
    same_contexts(graph, before, after)
    assert(top.num_contexts(before) == top.num_contexts(after), "descriptor contexts count as represented contexts")
    assert(rawget(after.node_to_context_inds, base) == nil)
    assert(after.node_to_context_inds[base] == after.node_to_context_inds[source])
end)
test("complex sorts without home contexts keep explicit base state", function()
    local graph, _, _, base = fixture()
    top.share_base_contexts = false
    local before = top.sort(graph, nil, nil, { complex_contexts = true, choose_randomly = false })
    top.share_base_contexts = true
    local after = top.sort(graph, nil, nil, { complex_contexts = true, choose_randomly = false })
    same_contexts(graph, before, after)
    assert(rawget(after.node_to_context_inds, base) ~= nil)
    assert(next(after.base_aliases) == nil)
end)
test("a detached head stays unreachable and cached reconnection restores it", function()
    local graph, _, recipe, base, head = fixture()
    gutils.remove_edge(graph, next(graph.nodes[head].pre))
    local before, after = sort(graph, false), sort(graph, true)
    assert(next(after.node_to_context_inds[recipe]) == nil)
    same_contexts(graph, before, after)
    gutils.connect_base_head(graph, base, head, graph.nodes[base].abilities)
    top.share_base_contexts = false
    before = top.sort(graph, before, { graph.nodes[base], graph.nodes[head] }, { choose_randomly = false })
    top.share_base_contexts = true
    after = top.sort(graph, after, { graph.nodes[base], graph.nodes[head] }, { choose_randomly = false })
    same_contexts(graph, before, after)
    assert(next(after.node_to_context_inds[recipe]) ~= nil)
end)
test("cached normal edges receive contexts their aliased source gains later", function()
    local graph, source = fixture()
    local room_b = node(graph, "room", "B", "OR")
    local output = node(graph, "item", "new-output", "OR")
    gutils.add_edge(graph, room_b, source)
    local before, after = sort(graph, false), sort(graph, true)
    gutils.add_edge(graph, source, output)
    top.share_base_contexts = false
    before = top.sort(graph, before, { graph.nodes[source], graph.nodes[output] }, { choose_randomly = false })
    top.share_base_contexts = true
    after = top.sort(graph, after, { graph.nodes[source], graph.nodes[output] }, { choose_randomly = false })
    local start = gutils.key("start", "")
    gutils.add_edge(graph, start, room_b)
    top.share_base_contexts = false
    before = top.sort(graph, before, { graph.nodes[start], graph.nodes[room_b] }, { choose_randomly = false })
    top.share_base_contexts = true
    after = top.sort(graph, after, { graph.nodes[start], graph.nodes[room_b] }, { choose_randomly = false })
    same_contexts(graph, before, after)
end)
test("aliases preserve their relay home filter and share filtered source views", function()
    local graph = { nodes = {}, edges = {}, sources = {} }
    local start = node(graph, "start", "", "AND")
    graph.sources[start] = true
    local room = node(graph, "room", "A", "OR")
    local research = node(graph, "research", "r", "AND")
    local tech = node(graph, "technology", "t", "AND")
    gutils.add_edge(graph, start, room)
    gutils.add_edge(graph, room, research)
    gutils.add_edge(graph, research, tech)
    local bases = {}
    for index = 1, 2 do
        local sink = node(graph, "item", tostring(index), "OR")
        local edge = gutils.add_edge(graph, tech, sink)
        local pair = gutils.subdivide_base_head(graph, gutils.ekey(edge))
        bases[index] = gutils.key(pair.base)
    end
    local homes = { ids = { 1, 2 }, sets = {
        [1] = { rooms = { A = true }, discovered = {} },
        [2] = { rooms = { A = true, B = true }, discovered = {} },
    }, of = {}, }
    local before, after = sort(graph, false, homes), sort(graph, true, homes)
    same_contexts(graph, before, after)
    assert(after.node_to_context_inds[bases[1]] == after.node_to_context_inds[bases[2]])
    assert(after.node_to_context_inds[bases[1]] ~= after.node_to_context_inds[tech])
end)
test("actual aggregators, transformed inputs and mechanic bases retain sorting state", function()
    local graph, source, _, base = fixture()
    graph.nodes[base].op = "OR"
    assert(rawget(sort(graph, true).node_to_context_inds, base) ~= nil)
    graph.nodes[base].op = "AND"
    graph.edges[next(graph.nodes[base].pre)].abilities = fx.edge({ [1] = false })
    assert(rawget(sort(graph, true).node_to_context_inds, base) ~= nil)
    graph.edges[next(graph.nodes[base].pre)].abilities = nil
    graph.nodes[base].mechanic = true
    assert(rawget(sort(graph, true).node_to_context_inds, base) ~= nil)
    assert(source ~= nil)
end)
test("promotion resolves new bases using real source promises", function()
    local graph, source, recipe, base, head = fixture()
    local unused = node(graph, "recipe", "unused", "AND")
    local edge = gutils.add_edge(graph, source, unused)
    local pair = gutils.subdivide_base_head(graph, gutils.ekey(edge))
    gutils.remove_edge(graph, next(graph.nodes[head].pre))
    top.share_base_contexts = true
    local prom = promotion.new({ graph = graph, complex = true })
    prom.promise_mechanics()
    local required = prom.required_contexts(recipe)
    assert(#required > 0)
    assert(prom.head_candidate_ok(head, gutils.key(pair.base), required))
    prom.resolve_head(head, gutils.key(pair.base), required)
    assert(graph.nodes[base].old_head == head)
end)
test("random dependency graphs keep every node context in simple and home-aware sorts", function()
    local homes = { ids = { 1, 2 }, sets = {
        [1] = { rooms = { A = true }, discovered = {} },
        [2] = { rooms = { A = true, B = true }, discovered = {} },
    }, of = {}, }
    for seed = 1, 40 do
        local value = seed
        local function random(max)
            value = (value * 48271) % 2147483647
            return value % max + 1
        end
        local graph = { nodes = {}, edges = {}, sources = {} }
        local start = node(graph, "start", "", "AND")
        graph.sources[start] = true
        local previous = {}
        for _, name in pairs({ "A", "B" }) do
            local room = node(graph, "room", name, "OR")
            gutils.add_edge(graph, start, room)
            table.insert(previous, room)
        end
        for index = 1, 16 do
            local kind = index % 5 == 0 and "research" or index % 7 == 0 and "technology" or index % 2 == 0 and "item" or "recipe"
            local dependent = node(graph, kind, tostring(index), index % 2 == 0 and "OR" or "AND")
            local taken = {}
            for input = 1, random(3) do
                local source = previous[random(#previous)]
                if not taken[source] then
                    taken[source] = true
                    local edge = gutils.add_edge(graph, source, dependent, { abilities = random(2) == 1 and fx.edge({ [random(2)] = false }) or nil })
                    gutils.subdivide_base_head(graph, gutils.ekey(edge))
                end
            end
            table.insert(previous, dependent)
        end
        top.share_base_contexts = false
        local before_simple = top.sort(graph, nil, nil, { choose_randomly = false })
        top.share_base_contexts = true
        local after_simple = top.sort(graph, nil, nil, { choose_randomly = false })
        same_contexts(graph, before_simple, after_simple)
        same_contexts(graph, sort(graph, false, homes), sort(graph, true, homes))
        -- Requirements must include every physical base even when its witness belongs to another node.
        same_requirements(graph, { previous[3], previous[4] })
        if seed % 2 == 0 then
            local edge = gutils.add_edge(graph, previous[#previous], previous[3])
            gutils.subdivide_base_head(graph, gutils.ekey(edge))
            same_requirements(graph, { previous[3], previous[4] })
            same_contexts(graph, sort(graph, false, homes), sort(graph, true, homes))
        end
    end
end)
test("room and watched requirements include descriptor-only bases", function()
    local graph, source, _, base, _, output = fixture()
    local context = top.simple_context("A")
    top.share_base_contexts = false
    local before = top.rooms_needed(graph)
    local watched_before = top.watched_needed(graph, { source, base })
    top.share_base_contexts = true
    local after = top.rooms_needed(graph)
    local watched_after = top.watched_needed(graph, { source, base })
    for _, node_key in pairs({ source, base, output }) do
        local a, b = before(node_key, context), after(node_key, context)
        assert(a ~= nil and b ~= nil, "missing requirements for " .. node_key)
        for room, _ in pairs(a) do assert(b[room] ~= nil, "lost room for " .. node_key) end
        for room, _ in pairs(b) do assert(a[room] ~= nil, "gained room for " .. node_key) end
        local wa, wb = watched_before(node_key), watched_after(node_key)
        for watched, _ in pairs(wa) do assert(wb[watched] ~= nil, "lost watched requirement for " .. node_key) end
        for watched, _ in pairs(wb) do assert(wa[watched] ~= nil, "gained watched requirement for " .. node_key) end
    end
end)
print(passed .. " base descriptor tests passed")

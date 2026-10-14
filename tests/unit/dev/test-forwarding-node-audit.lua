-- The footprint audit must identify forwarding links without changing the graph.
function table.deepcopy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for k, v in pairs(value) do result[k] = table.deepcopy(v) end
    return result
end
local logic = { type_info = {} }
package.loaded["src/logic/state"] = logic
local gutils = require("src/lib/graph/graph-utils")
local audit = require("dev/experiments/forwarding-node-audit")

local function fixture(kind, source_kind, amount)
    local graph = { nodes = {}, edges = {}, sources = {} }
    local function node(t, name, op)
        logic.type_info[t] = logic.type_info[t] or {}
        return gutils.add_node(graph, t, name, { op = op or "OR" })
    end
    local source = node(source_kind, "example")
    local forward = node(kind, "example")
    local target = node("target", "example", "AND")
    gutils.add_edge(graph, gutils.key(source), gutils.key(forward), amount and { amount = amount } or nil)
    gutils.add_edge(graph, gutils.key(forward), gutils.key(target), { amount = kind == "entity-own-operable" and 0.02 or nil, abilities = 2, used_payback = 50 })
    return graph, source, forward, target, node
end

for _, spec in pairs({
    { "entity-own-operable", "entity-own", 1 },
    { "recipe-unlock", "recipe-tech-unlock" },
}) do
    local graph, source, forward, target, node = fixture(spec[1], spec[2], spec[3])
    local info = audit.inspect(graph, forward)
    assert(info.reason == "forwarding" and info.source_key == gutils.key(source))
    assert(info.source_inputs == 0)
    gutils.make_orands(graph)
    info = audit.inspect(graph, forward)
    assert(info.reason == "forwarding" and graph.nodes[info.connector_key].type == "orand")
    -- An output transformation belongs downstream and must not disqualify the identity input.
    assert(graph.edges[gutils.ekey({ start = gutils.key(forward), stop = gutils.key(target) })].abilities == 2)
    local incoming = graph.edges[next(graph.nodes[info.connector_key].pre)]
    incoming.abilities = 1
    assert(audit.inspect(graph, forward).reason == "input-transform")
    incoming.abilities = nil
    local extra = node("extra", "gate")
    gutils.add_edge(graph, gutils.key(extra), gutils.key(forward))
    assert(audit.inspect(graph, forward).reason == "alternatives")
end

do
    local graph, source, forward, target = fixture("recipe-unlock", "recipe-tech-unlock")
    local edge = graph.edges[gutils.ekey({ start = gutils.key(forward), stop = gutils.key(target) })]
    edge.amount = 1
    assert(audit.inspect(graph, forward).reason == "consuming-output")
    gutils.subdivide_base_head(graph, gutils.ekey(edge))
    assert(audit.inspect(graph, forward).reason == "consuming-output")
end

do
    local graph, source, forward, target = fixture("entity-own-operable", "entity-own", 1)
    gutils.add_edge(graph, gutils.key(source), gutils.key(target))
    assert(audit.inspect(graph, forward).reason == "output-collision")
    gutils.make_orands(graph)
    assert(audit.inspect(graph, forward).reason == "output-collision")
end

do
    local graph, source, forward = fixture("entity-own-operable", "entity-own", 1)
    forward.cost = 1
    assert(audit.inspect(graph, forward).reason == "node-metadata")
    forward.cost = nil
    logic.type_info[source.type].home_carrier = true
    assert(audit.inspect(graph, forward).reason == "source-metadata")
    logic.type_info[source.type].home_carrier = nil
    gutils.make_orands(graph)
    local info = audit.inspect(graph, forward)
    local edge = graph.edges[next(graph.nodes[info.connector_key].pre)]
    gutils.subdivide_base_head(graph, gutils.ekey(edge))
    assert(audit.inspect(graph, forward).reason == "source-shape")
end

do
    local graph, source, forward = fixture("recipe-unlock", "recipe-tech-unlock")
    gutils.make_orands(graph)
    local info = audit.inspect(graph, forward)
    local k, s, c = gutils.key(forward), gutils.key(source), info.connector_key
    local messages = {}
    function log(message) table.insert(messages, message) end
    local sort_info = { pebble_keys = { k, k, c }, node_to_context_inds = { [k] = { A = 1, B = 2 }, [s] = { A = 4 }, [c] = { A = 3 } } }
    local in_key = next(forward.pre)
    local out_key = next(forward.dep)
    audit.report(graph, sort_info, "test")
    assert(#messages == 1 and messages[1]:find("forwarding%-empty nodes=1 stored=2 represented=2 connector_stored=1 connector_represented=1 differing=1"))
    assert(graph.nodes[k] == forward and forward.num_pre == 1 and next(forward.pre) == in_key and next(forward.dep) == out_key)
    assert(#sort_info.pebble_keys == 3 and sort_info.node_to_context_inds[k].B == 2)
end

print("forwarding node audit tests passed")

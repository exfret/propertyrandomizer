-- The real salvage scaffold must deliver a collected item without making it local to a planet.
function table.deepcopy(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for k, v in pairs(value) do copy[k] = table.deepcopy(v) end
    return copy
end
log = function() end
serpent = {block = tostring, line = tostring}
package.loaded["src/lib/random/rng"] = {int = function() return 1 end}
local state = {
    contexts = {ground = true, orbit = true},
    type_info = {
        start = {}, room = {context = "room"}, item = {},
        ["entity-kill"] = {}, ["asteroid-collector"] = {}, ["asteroid-chunk-mine"] = {},
        ["item-launch"] = {context = true}, ["item-deliver"] = {},
        deliver = {}, ["reachable-room"] = {},
    },
}
package.loaded["src/logic/state"] = state
local death = require("src/prototypes/entities/death-slots")
local gutils = require("src/lib/graph/graph-utils")
local top = require("src/lib/sort/context-sort")
local ctx = require("src/logic/contexts/contexts")
local function fixture(killable, collector_ready, delivery_ready)
    local graph = {nodes = {}, edges = {}, sources = {}}
    local function node(kind, name, op)
        return gutils.key(gutils.add_node(graph, kind, name, {op = op}))
    end
    local start = node("start", "", "AND")
    graph.sources[start] = true
    local ground, orbit = node("room", "ground", "OR"), node("room", "orbit", "OR")
    gutils.add_edge(graph, start, ground)
    gutils.add_edge(graph, start, orbit)
    local reach = node("reachable-room", "", "OR")
    gutils.add_edge(graph, ground, reach)
    gutils.add_edge(graph, orbit, reach)
    local kill = node("entity-kill", "host", "OR")
    local collector = node("asteroid-collector", "", "OR")
    local deliver = node("deliver", "", "OR")
    if killable then gutils.add_edge(graph, orbit, kill) end
    if collector_ready then gutils.add_edge(graph, orbit, collector) end
    if delivery_ready then gutils.add_edge(graph, orbit, deliver, {abilities = ctx.LOSES_ISOLATABILITY}) end
    local available = death.salvage_source(graph, "host", 1)
    local sorted = top.sort(graph, nil, nil, {complex_contexts = true})
    local contexts = sorted.node_to_context_inds[gutils.key(available)] or {}
    return function(room, mask) return contexts[ctx.complex(room, mask)] ~= nil end
end
local ready = fixture(true, true, true)
assert(ready("orbit", ctx.ALL_ABILITIES))
assert(ready("ground", ctx.AUTOMATED), "collected salvage must retain automation on delivery")
assert(not ready("ground", ctx.ALL_ABILITIES), "imported salvage must not become locally obtainable")
assert(not fixture(false, true, true)("ground", 0), "the asteroid must be killable")
assert(not fixture(true, false, true)("ground", 0), "a collector is required")
local no_delivery = fixture(true, true, false)
assert(no_delivery("orbit", ctx.AUTOMATED))
assert(not no_delivery("ground", 0), "collection alone cannot bypass delivery")
print("Asteroid salvage: collection, delivery, automation, and local-supply boundaries passed")

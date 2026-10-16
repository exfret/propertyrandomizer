-- Regression: automatic firing can prove damage while projectile-created buildings cannot prove bulk supply.
table.deepcopy = function(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for k, v in pairs(value) do copy[k] = table.deepcopy(v) end
    return copy
end
log = function() end
serpent = {
    block = tostring,
    line = tostring,
}
package.loaded["src/lib/random/rng"] = {int = function(_, max) return 1 end}
local state = {
    contexts = {
        A = true,
        B = true,
    },
    type_info = {
        start = {},
        room = {context = "room"},
        item = {},
        base = {},
        head = {},
        orand = {},
        ["entity-build-item"] = {},
        ["group-supply"] = {},
        ["damage-type"] = {},
        ["projectile-package"] = {},
    },
}
package.loaded["src/logic/init"] = state
package.loaded["src/logic/state"] = state
local gutils = require("src/lib/graph/graph-utils")
local promotion = require("src/randomizations/unified/skeleton/promotion")
local acquisition = require("src/logic/builders/acquisition")
local ctx = require("src/logic/contexts/contexts")
local top = require("src/lib/sort/context-sort")
local key = gutils.key

local function setup()
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local function node(kind, name, op, extra)
        extra = extra or {}
        extra.op = op
        return key(gutils.add_node(graph, kind, name, extra))
    end
    local start = node("start", "", "AND")
    graph.sources[start] = true
    for _, name in pairs({
        "A",
        "B",
    }) do
        local room = node("room", name, "OR")
        gutils.add_edge(graph, start, room)
        gutils.add_edge(graph, room, node("item", name, "OR"))
    end
    local fire = node("base", "firing", "AND", {
        acq_kind = "ammo",
        ours = true,
    })
    gutils.add_edge(graph, start, fire)
    local supply = node("group-supply", "belts", "OR", {mechanic = true})
    for _, name in pairs({
        "first",
        "second",
    }) do
        local base = node("base", name, "AND", {acq_kind = "build"})
        gutils.add_edge(graph, start, base)
        local head = node("head", name, "OR", {
            acq_kind = "build",
            old_base = base,
        })
        graph.nodes[base].old_head = head
        local building = node("entity-build-item", name, "OR")
        gutils.add_edge(graph, head, building)
        gutils.add_edge(graph, building, supply)
    end
    local payload = node("head", "payload", "OR", {
        acq_kind = "ammo",
        projectile_package = "test",
        ours = true,
        old_base = fire,
    })
    graph.nodes[fire].old_head = payload
    local package_node = node("projectile-package", "test", "OR")
    gutils.add_edge(graph, payload, package_node)
    gutils.add_edge(graph, package_node, node("damage-type", "test", "OR", {mechanic = true}))
    local prom = promotion.new({
        graph = graph,
        complex = true,
        connection_abilities = function(base, head) return acquisition.pairing(base, head).abilities end,
    })
    assert(#prom.promise_mechanics() == 0)
    return prom, graph, fire
end

local prom, graph, fire = setup()
local function move(name)
    return {
        node_key = key("head", name),
        remove = {key("base", name)},
        add = fire,
    }
end
-- The real matcher is one-to-one; using the same firing source here isolates the output ability rule.
-- Either belt is optional, but the class must retain one automatically supplied member.
assert(not prom.try_rewires({
    move("first"),
    move("second"),
}, true), "all belt variants must not move into manual deployment")
local first = prom.try_rewires({move("first")}, true)
local second = first or prom.try_rewires({move("second")}, true)
assert(second, "one optional bulk member must be allowed without a quantity veto")
local found = false
for _, pebble in pairs(prom.promised_pebbles()) do
    if pebble.node_key == key("damage-type", "test") then
        local mask = top.context_mask(pebble.context)
        if mask ~= nil and ctx.has_ability(mask, ctx.AUTOMATABILITY) then
            assert(prom.is_solvent(pebble.node_key, pebble.context))
            found = true
        end
    end
end
assert(found, "automatic projectile damage survives the separate construction restriction")
print("Projectile supply protection passed: optional bulk member allowed, last automatic supplier protected, automatic damage retained")

local death_base = {acq_kind = "dying"}
local damage_head = {acq_kind = "ammo", projectile_package = "fixture", ours = true}
assert(acquisition.pairing(death_base, damage_head) ~= nil, "a death can supply a payload without owning its host")
assert(acquisition.pairing(death_base, damage_head).abilities == nil, "automatic death damage retains source abilities")
local building_pair = acquisition.pairing(death_base, {acq_kind = "build"})
assert(ctx.edge_loses_ability(building_pair.abilities, ctx.AUTOMATABILITY), "death salvage does not prove automatic construction")
print("Death source automation stays separate from building acquisition")
local collected = acquisition.pairing({acq_kind = "dying", salvage_source = "asteroid"}, {acq_kind = "build"})
assert(collected and collected.abilities == nil, "collecting a placement item preserves automatic supply")

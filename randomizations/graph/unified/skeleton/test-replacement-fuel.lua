-- Plain-Lua regression tests for coal's fuel in first pass (replacement-fuel.lua; not loaded by the mod)
-- Run from the mod root: lua randomizations/graph/unified/skeleton/test-replacement-fuel.lua
-- Coal's fuel belongs to coal's slot; coal's identity has its own fuel edge only away from that slot, since with it on the slot too, proofs pinned coal to Nauvis's starting patches (user, 2026-10-07)

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
package.loaded["lib/random/rng"] = {
    int = function(_, max)
        return 1
    end,
    shuffle = function(_, tbl) end,
}
-- Two rooms: A mines coal, B burns fuel, and delivery forgets the room it starts in (like the logic's item-deliver)
package.loaded["lib/logic/init"] = {
    contexts = {
        A = true,
        B = true,
    },
    type_info = {
        start = {},
        room = { context = "room" },
        mine = {},
        item = {},
        base = {},
        head = {},
        orand = {},
        ["item-launch"] = {},
        ["item-deliver"] = { context = true },
        ["fuel-category"] = {},
        burner = {},
    },
}
package.loaded["lib/logic/state"] = package.loaded["lib/logic/init"]
package.loaded["randomizations/graph/unified/skeleton/protection"] = {}

local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")
local matching = require("randomizations/graph/unified/skeleton/monotone-matching")
local replacement_fuel = require("randomizations/graph/unified/skeleton/replacement-fuel")

local key = gutils.key

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local fuel_key = key("fuel-category", "chemical__0")
local coal_slot = key("item", "coal")
local coal_trav = key("item", "coal-trav")

-- First pass's split graph for coal, stone and a widget: each item slot with its own trav, and coal's fuel edge kept on coal's slot (as first-pass.lua splits it)
local function split_graph()
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    gutils.add_node(graph, "fuel-category", "chemical__0", {
        op = "OR",
    })
    for _, name in pairs({
        "coal",
        "stone",
        "widget",
    }) do
        local slot = gutils.add_node(graph, "item", name, {
            op = "OR",
        })
        local trav = gutils.add_node(graph, "item", name .. "-trav", {
            op = "OR",
        })
        slot.old_trav = key(trav)
        trav.old_slot = key(slot)
    end
    gutils.add_edge(graph, coal_slot, fuel_key)
    local identity_fuel = {
        [coal_trav] = fuel_key,
    }
    return graph, identity_fuel
end

local function fuel_providers(graph)
    local providers = {}
    for pre, _ in pairs(graph.nodes[fuel_key].pre) do
        table.insert(providers, graph.edges[pre].start)
    end
    table.sort(providers)
    return table.concat(providers, ", ")
end

local function connect(graph, identity_fuel, assignment)
    for slot_name, trav_name in pairs(assignment) do
        replacement_fuel.connect(graph, key("item", slot_name), key("item", trav_name .. "-trav"), identity_fuel)
    end
end

test("coal's identity on coal's slot gets its fuel only through the slot", function()
    local graph, identity_fuel = split_graph()
    connect(graph, identity_fuel, {
        coal = "coal",
        stone = "stone",
        widget = "widget",
    })
    assert(fuel_providers(graph) == coal_slot, fuel_providers(graph))
end)

test("coal's identity away from coal's slot is still a fuel, and whatever replaces it gets the fuel through coal's slot", function()
    local graph, identity_fuel = split_graph()
    connect(graph, identity_fuel, {
        coal = "widget",
        stone = "coal",
        widget = "stone",
    })
    assert(fuel_providers(graph) == coal_slot .. ", " .. coal_trav, fuel_providers(graph))
    assert(graph.nodes[key("item", "widget-trav")].dep[gutils.ekey({
        start = key("item", "widget-trav"),
        stop = fuel_key,
    })] == nil)
end)

-- The game as first pass connects the identity matching: coal mined in room A, delivered to every room by rocket, and a burner in room B that needs fuel
-- with_own_edge adds coal's identity its own fuel edge on coal's slot too, as first pass did before 2026-10-07
local function delivery_game(with_own_edge)
    local graph, identity_fuel = split_graph()
    local function node(node_type, name, op)
        return key(gutils.add_node(graph, node_type, name, {
            op = op,
        }))
    end
    local start = node("start", "", "AND")
    graph.sources[start] = true
    local room_a = node("room", "A", "OR")
    local room_b = node("room", "B", "OR")
    gutils.add_edge(graph, start, room_a)
    gutils.add_edge(graph, start, room_b)
    local mine = node("mine", "coal", "AND")
    gutils.add_edge(graph, room_a, mine)
    gutils.add_edge(graph, mine, coal_slot)
    -- Slot --> base --> head --> trav, and trav --> slot, as monotone matching connects a pair
    local base = node("base", "coal", "AND")
    local head = node("head", "coal-trav", "AND")
    gutils.add_edge(graph, coal_slot, base)
    gutils.add_edge(graph, base, head)
    gutils.add_edge(graph, head, coal_trav)
    gutils.add_edge(graph, coal_trav, coal_slot)
    graph.nodes[coal_trav].trav = true
    -- The identity's launch chain: trav --> item-launch --> item-deliver --> orand --> trav
    local launch = node("item-launch", "coal", "AND")
    local deliver = node("item-deliver", "coal", "AND")
    local arrival = node("orand", "coal-delivered", "AND")
    gutils.add_edge(graph, coal_trav, launch)
    gutils.add_edge(graph, launch, deliver)
    gutils.add_edge(graph, deliver, arrival)
    gutils.add_edge(graph, arrival, coal_trav)
    local burner = node("burner", "boiler", "AND")
    gutils.add_edge(graph, fuel_key, burner)
    gutils.add_edge(graph, room_b, burner)
    if with_own_edge == true then
        gutils.add_edge(graph, coal_trav, fuel_key)
    else
        replacement_fuel.connect(graph, coal_slot, coal_trav, identity_fuel)
    end
    return graph, burner
end

-- What proving the burner in room B asks of coal's identity and slot (monotone matching's needs_from_proof)
local function burner_needs(with_own_edge)
    local graph, burner = delivery_game(with_own_edge)
    local sort_info = top.sort(graph, nil, nil, {
        complex_contexts = true,
    })
    local goal_inds = {}
    for context, ind in pairs(sort_info.node_to_context_inds[burner] or {}) do
        if string.find(context, "B", 1, true) == 1 then
            table.insert(goal_inds, ind)
        end
    end
    assert(#goal_inds > 0, "the burner is reachable in room B")
    local closure, support, failed = matching.make_prover(graph, sort_info).prove(goal_inds)
    assert(#failed == 0, "the burner's pebbles are proven")
    local assignment = {
        [coal_slot] = coal_trav,
    }
    local chain_of = matching.launch_chains(graph, { coal_trav })
    return matching.needs_from_proof(graph, sort_info, closure, support, assignment, chain_of)
end

test("fuel shipped from coal's slot asks the slot for a launchable identity, not coal itself", function()
    local needs, requires_launchable = burner_needs(false)
    assert(needs[coal_trav] == nil, "coal's identity isn't needed")
    assert(requires_launchable[coal_slot] == true)
end)

test("with its own fuel edge on coal's slot too, coal's identity would be needed where it's mined, which pinned it to the starting patches", function()
    local needs = burner_needs(true)
    assert(needs[coal_trav] ~= nil and next(needs[coal_trav]) ~= nil)
end)

print(num_passed .. " tests passed")

-- Plain-Lua regression tests for lib/cost/graph-cost.lua (not loaded by the mod)
-- Run from the mod root: lua lib/cost/test-graph-cost.lua
-- Prices follow the logic graph's cost model: AND nodes are actions, OR nodes are materials, and edges carry how much is made or used

local graph_cost = require("lib/cost/graph-cost")

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local function near(a, b)
    return a ~= nil and b ~= nil and math.abs(a - b) < 1e-6
end

-- A small logic graph: nodes by key with op, type and cost; edges with amounts
local function new_graph()
    return {
        nodes = {},
        edges = {},
    }
end

local function add_node(graph, node_key, op, extra)
    local node = {
        op = op,
        type = (extra or {}).type or node_key,
        name = node_key,
        cost = (extra or {}).cost,
        prot = (extra or {}).prot,
        pre = {},
        dep = {},
    }
    graph.nodes[node_key] = node
    return node
end

local function add_edge(graph, start, stop, amount)
    local edge_key = start .. " --> " .. stop
    graph.edges[edge_key] = {
        start = start,
        stop = stop,
        amount = amount,
    }
    graph.nodes[start].dep[edge_key] = true
    graph.nodes[stop].pre[edge_key] = true
end

-- Every node sends on the context that arrives, like simple contexts without rooms
local function keep_context(node, incoming)
    return { incoming }
end

test("an action's price is its cost plus what it uses; a material's is the cheapest action per unit it makes", function()
    local g = new_graph()
    add_node(g, "mine", "AND", { cost = 1 })
    add_node(g, "ore", "OR")
    add_edge(g, "mine", "ore", 2)
    add_node(g, "smelt", "AND", { cost = 0.5 })
    add_edge(g, "ore", "smelt", 3)
    add_node(g, "plate", "OR", { cost = 0.1 })
    add_edge(g, "smelt", "plate", 1)
    -- A dearer way to the same plate doesn't set its price
    add_node(g, "dear", "AND", { cost = 10 })
    add_edge(g, "dear", "plate", 1)
    local prices = graph_cost.compute(g, { "here" }, keep_context)
    assert(near(prices["ore"]["here"], 0.5))
    assert(near(prices["smelt"]["here"], 0.5 + 3 * 0.5))
    assert(near(prices["plate"]["here"], 0.1 + 2))
end)

test("an OR made from another OR takes amount of it per unit, and a missing amount makes it free", function()
    local g = new_graph()
    add_node(g, "mine", "AND", { cost = 1 })
    add_node(g, "ore", "OR")
    add_edge(g, "mine", "ore", 1)
    add_node(g, "crushed", "OR")
    add_edge(g, "ore", "crushed", 4)
    add_node(g, "known", "OR")
    add_edge(g, "ore", "known", nil)
    local prices = graph_cost.compute(g, { "here" }, keep_context)
    assert(near(prices["crushed"]["here"], 4))
    assert(near(prices["known"]["here"], 0))
end)

test("an action with a missing amount on what it makes (autoplace, unlocks) makes it free once the action can happen", function()
    local g = new_graph()
    add_node(g, "planet", "AND", { cost = 5 })
    add_node(g, "tree", "OR")
    add_edge(g, "planet", "tree", 0)
    local prices = graph_cost.compute(g, { "here" }, keep_context)
    assert(near(prices["tree"]["here"], 0))
end)

test("an action needs everything it has an edge from, even what it doesn't use up, but only pays for what it uses", function()
    local g = new_graph()
    add_node(g, "mine", "AND", { cost = 1 })
    add_node(g, "ore", "OR")
    add_edge(g, "mine", "ore", 1)
    add_node(g, "unlock", "OR")
    add_node(g, "craft", "AND")
    add_edge(g, "ore", "craft", 2)
    add_edge(g, "unlock", "craft", nil)
    local prices = graph_cost.compute(g, { "here" }, keep_context)
    -- The unlock is never had, so the craft can't happen
    assert(prices["craft"]["here"] == nil)
    add_node(g, "research", "AND", { cost = 100 })
    add_edge(g, "research", "unlock", nil)
    prices = graph_cost.compute(g, { "here" }, keep_context)
    assert(near(prices["craft"]["here"], 2))
end)

test("prices are per context, and a node moving contexts (like a room) only sends its own", function()
    local g = new_graph()
    add_node(g, "start", "AND", { cost = 1 })
    add_node(g, "ship", "OR", { type = "room" })
    add_edge(g, "start", "ship", 1)
    add_node(g, "mine", "AND", { cost = 2 })
    add_edge(g, "ship", "mine", 1)
    add_node(g, "ore", "OR")
    add_edge(g, "mine", "ore", 1)
    local function transmit(node, incoming)
        if node.type == "room" then
            return { "away" }
        end
        return { incoming }
    end
    local prices = graph_cost.compute(g, { "home", "away" }, transmit)
    assert(prices["ore"]["home"] == nil)
    assert(near(prices["ore"]["away"], 3))
end)

test("a loop that gains material converges instead of running forever", function()
    local g = new_graph()
    add_node(g, "mine", "AND", { cost = 1 })
    add_node(g, "seed", "OR")
    add_edge(g, "mine", "seed", 1)
    add_node(g, "grow", "AND", { cost = 0 })
    add_edge(g, "seed", "grow", 1)
    add_edge(g, "grow", "seed", 2)
    local prices = graph_cost.compute(g, { "here" }, keep_context)
    assert(prices["seed"]["here"] ~= nil and prices["seed"]["here"] < 1e-5)
end)

test("a loop that gains material, like Kovarex enrichment, is priced at its limit (its net output) rather than approached step by step", function()
    local g = new_graph()
    add_node(g, "mine", "AND", { cost = 1 })
    add_node(g, "u238", "OR")
    add_edge(g, "mine", "u238", 1)
    -- Centrifuging: 10 u238 for 0.007 u235 on average
    add_node(g, "centrifuge", "AND")
    add_edge(g, "u238", "centrifuge", 10)
    -- Made materials come through a craft node, and here a one-input step like a fluid's temperature node, as in the logic graph
    add_node(g, "u235 craft", "OR")
    add_node(g, "u235 step", "AND")
    add_node(g, "u235", "OR")
    add_edge(g, "centrifuge", "u235 craft", 0.007)
    add_edge(g, "u235 craft", "u235 step", 1)
    add_edge(g, "u235 step", "u235", 1)
    -- Enrichment: 40 u235 and 5 u238 make 41 u235, so each run nets one u235 for 5 u238
    add_node(g, "enrich", "AND")
    add_edge(g, "u235", "enrich", 40)
    add_edge(g, "u238", "enrich", 5)
    add_edge(g, "enrich", "u235 craft", 41)
    local prices = graph_cost.compute(g, { "here" }, keep_context)
    assert(near(prices["u235"]["here"], 5))
end)

test("a material's price without recipes skips its craft nodes, and only counts what the world gives, not what we placed", function()
    local g = new_graph()
    add_node(g, "item: stone", "OR", { type = "material", prot = "item: stone", cost = 0.1 })
    add_node(g, "item-craft: stone", "OR", { type = "item-craft", prot = "item: stone" })
    add_edge(g, "item-craft: stone", "item: stone", 1)
    add_node(g, "recipe", "AND", { cost = 0.5 })
    add_edge(g, "recipe", "item-craft: stone", 1)
    -- Mining a rock the world places
    add_node(g, "autoplace", "AND")
    add_node(g, "entity: rock", "OR", { type = "entity", prot = "rock" })
    add_edge(g, "autoplace", "entity: rock", 0)
    add_node(g, "entity-mine: rock", "AND", { type = "entity-mine", prot = "rock" })
    add_edge(g, "entity: rock", "entity-mine: rock", 1)
    add_edge(g, "entity-mine: rock", "item: stone", 20)
    local prices = graph_cost.compute(g, { "here" }, keep_context)
    assert(near(graph_cost.price_without_recipes(g, prices, "item: stone", "here"), 0.1))
    -- A fence we build from stone and can mine back isn't a source of stone
    add_node(g, "entity: fence", "OR", { type = "entity", prot = "fence" })
    add_node(g, "entity-own: fence", "OR", { type = "entity-own", prot = "fence" })
    add_edge(g, "item: stone", "entity-own: fence", 5)
    add_edge(g, "entity-own: fence", "entity: fence", 1)
    add_node(g, "entity-mine: fence", "AND", { type = "entity-mine", prot = "fence" })
    add_edge(g, "entity: fence", "entity-mine: fence", 1)
    add_node(g, "item: fence", "OR", { type = "material", prot = "item: fence", cost = 0.1 })
    add_edge(g, "entity-mine: fence", "item: fence", 1)
    prices = graph_cost.compute(g, { "here" }, keep_context)
    assert(graph_cost.price_without_recipes(g, prices, "item: fence", "here") == nil)
    -- Only a recipe makes bricks
    add_node(g, "item: brick", "OR", { type = "material", prot = "item: brick" })
    add_node(g, "item-craft: brick", "OR", { type = "item-craft", prot = "item: brick" })
    add_edge(g, "item-craft: brick", "item: brick", 1)
    add_edge(g, "recipe", "item-craft: brick", 1)
    prices = graph_cost.compute(g, { "here" }, keep_context)
    assert(prices["item: brick"]["here"] ~= nil)
    assert(graph_cost.price_without_recipes(g, prices, "item: brick", "here") == nil)
end)

test("whole-game raw costs are only for what the game gives automatably, since callers take a cost as usable in automated recipes", function()
    local g = new_graph()
    for _, name in pairs({ "ore", "timber", "plate" }) do
        local node = add_node(g, "item: " .. name, "OR", { type = "item" })
        node.name = name
    end
    local raw_costs = {
        ["item-ore"] = 1,
        ["item-timber"] = 8,
    }
    local automatable_names = {
        ore = true,
        plate = true,
    }
    local costs = graph_cost.automatable_raw_costs(g, raw_costs, function(node_key)
        return automatable_names[g.nodes[node_key].name] == true
    end)
    assert(costs["item-ore"] == 1)
    -- Timber only comes from trees by hand, so it stays unpriced, and a material without a raw cost doesn't get one
    assert(costs["item-timber"] == nil)
    assert(costs["item-plate"] == nil)
end)

test("with slot costs, the player's time is charged dearly: hand mining costs more than a drill", function()
    local g = new_graph()
    add_node(g, "character", "AND", { cost = 1 })
    g.nodes["character"].slot_additional_cost = 30
    add_node(g, "drill", "AND", { cost = 0.1 })
    add_node(g, "rock", "OR")
    add_node(g, "hand-mine", "AND")
    add_edge(g, "character", "hand-mine", 2)
    add_edge(g, "hand-mine", "rock", 1)
    add_node(g, "ore", "OR")
    add_node(g, "drill-mine", "AND")
    add_edge(g, "drill", "drill-mine", 2)
    add_edge(g, "drill-mine", "ore", 1)
    -- An OR --> OR edge charges its own slot cost per unit (like spoiling)
    add_node(g, "spoiled", "OR")
    add_edge(g, "ore", "spoiled", 1)
    g.edges["ore --> spoiled"].slot_additional_cost = 5
    local plain = graph_cost.compute(g, { "here" }, keep_context)
    local slot = graph_cost.compute(g, { "here" }, keep_context, nil, true)
    assert(near(plain["rock"]["here"], 2))
    assert(near(slot["rock"]["here"], 62))
    assert(near(slot["ore"]["here"], 0.2))
    assert(near(plain["spoiled"]["here"], 0.2))
    assert(near(slot["spoiled"]["here"], 5.2))
end)

print(num_passed .. " tests passed")

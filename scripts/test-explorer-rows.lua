-- Plain-Lua regression tests for scripts/explorer-rows.lua (not loaded by the mod)
-- Run from the mod root: lua scripts/test-explorer-rows.lua
--
-- The toy graphs follow how lib/logic/concrete.lua builds an entity's ownership and operation nodes

function log(msg) end

local gutils = require("lib/graph/graph-utils")
local explorer_rows = require("scripts/explorer-rows")

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local function new_graph()
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
        type_info = {},
    }
    -- Nodes get their op from their type, as in lib/logic/graph-setup.lua; canonical is the builder's class
    local function add(node_type, name, op, canonical)
        graph.type_info[node_type] = {
            op = op,
            canonical = canonical or node_type,
        }
        return gutils.add_node(graph, node_type, name, {op = op})
    end
    local function connect(start, stop, extra)
        gutils.add_edge(graph, start, stop, extra)
    end
    return graph, add, connect
end

-- The shown rows under node, as sorted keys
local function rows(graph, node)
    local keys = {}
    for _, leaf in pairs(explorer_rows.leaves(graph, node).leaves) do
        table.insert(keys, gutils.key(leaf))
    end
    table.sort(keys)
    return table.concat(keys, ", ")
end

local function assert_rows(graph, node, expected)
    local actual = rows(graph, node)
    if actual ~= expected then
        error("rows under " .. gutils.key(node) .. ": expected " .. expected .. ", got " .. actual)
    end
end

-- A building an item places, with power, and the space and bootstrap ways to count a delivered one as local
-- extra_ways_to_own adds other ways to have it (like a capsule that makes it)
local function building(options)
    options = options or {}
    local graph, add, connect = new_graph()
    local operate = add("entity-operate", "machine", "AND", "entity")
    local operable = add("entity-own-operable", "machine", "OR", "entity")
    local own = add("entity-own", "machine", "OR", "entity")
    local build = add("entity-build", "machine", "AND", "entity")
    local architecture = add("entity-build-architecture", "machine", "OR", "entity")
    local build_item = add("entity-build-item", "machine", "OR", "entity")
    local build_tile = add("entity-build-tile", "machine", "OR", "entity")
    local own_space = add("entity-own-space", "machine", "AND", "entity")
    local space = add("space-surface", "", "OR")
    local power = add("energy-source-electric", "", "AND")
    local machine_item = add("item", "machine-item", "OR")
    local ground = add("tile", "ground", "OR")

    connect(operable, operate)
    connect(power, operate)
    connect(own, operable)
    connect(own_space, operable)
    connect(build, own)
    connect(build, own_space)
    connect(space, own_space)
    connect(architecture, build)
    connect(build_tile, build)
    connect(build_item, architecture)
    connect(machine_item, build_item)
    connect(ground, build_tile)
    if options.has_bootstrap then
        local own_bootstrap = add("entity-own-bootstrap", "machine", "AND", "entity")
        local bootstrap_rooms = add("entity-own-bootstrap-rooms", "machine", "OR", "entity")
        connect(build, own_bootstrap)
        connect(bootstrap_rooms, own_bootstrap)
        connect(own_bootstrap, operable)
    end
    if options.has_capsule then
        local capsule = add("item-capsule", "machine-capsule", "AND")
        connect(capsule, own)
    end
    if options.has_other_way_to_operate then
        local other = add("some-other-way", "machine", "AND", "entity")
        connect(other, operable)
    end
    return graph, operate, own
end

test("an ordinary building shows Build under Operate, without ownership levels or the space way", function()
    local graph, operate = building()
    assert_rows(graph, operate, "energy-source-electric: , entity-build: machine")
end)

test("the bootstrap way is left out like the space one", function()
    local graph, operate = building({has_bootstrap = true})
    assert_rows(graph, operate, "energy-source-electric: , entity-build: machine")
end)

test("Build keeps its own row rather than listing the item and tile under Operate", function()
    local graph, operate = building()
    local build = graph.nodes[gutils.key("entity-build", "machine")]
    -- Opening Build itself still lists what building needs
    assert_rows(graph, build, "item: machine-item, tile: ground")
    assert_rows(graph, operate, "energy-source-electric: , entity-build: machine")
end)

test("an entity with several ways to own it shows one Own row listing them", function()
    local graph, operate, own = building({has_capsule = true})
    assert_rows(graph, operate, "energy-source-electric: , entity-own: machine")
    assert_rows(graph, own, "entity-build: machine, item-capsule: machine-capsule")
end)

test("a skipped node with several ways left is shown itself", function()
    local graph, operate = building({has_other_way_to_operate = true})
    assert_rows(graph, operate, "energy-source-electric: , entity-own-operable: machine")
end)

test("an entity that isn't built shows its one way to own it", function()
    local graph, add, connect = new_graph()
    local operate = add("entity-operate", "hero", "AND", "entity")
    local operable = add("entity-own-operable", "hero", "OR", "entity")
    local own = add("entity-own", "hero", "OR", "entity")
    local playing_as = add("entity-character", "hero", "AND")
    connect(operable, operate)
    connect(own, operable)
    connect(playing_as, own)
    assert_rows(graph, operate, "entity-character: hero")
end)

test("the entity itself still merges in its ways to own it and to find it", function()
    local graph, add, connect = new_graph()
    local entity = add("entity", "rock", "OR", "entity")
    local own = add("entity-own", "rock", "OR", "entity")
    local build = add("entity-build", "rock", "AND", "entity")
    local build_tile = add("entity-build-tile", "rock", "OR", "entity")
    local build_item = add("entity-build-item", "rock", "OR", "entity")
    local autoplace = add("room-autoplace", "home", "AND")
    connect(own, entity)
    connect(autoplace, entity)
    connect(build, own)
    connect(build_tile, build)
    connect(build_item, build)
    assert_rows(graph, entity, "entity-build: rock, room-autoplace: home")
end)

test("operating starts the explorer only when it needs more than having the entity", function()
    local graph, add, connect = new_graph()
    local operate = add("entity-operate", "box", "AND", "entity")
    local operable = add("entity-own-operable", "box", "OR", "entity")
    local warmth = add("warmth", "", "OR")
    local lightning_safe = add("lightning-safe", "", "OR")
    connect(operable, operate)
    connect(warmth, operate)
    connect(lightning_safe, operate)
    assert(not explorer_rows.operate_needs_more(graph, operate), "a box that only needs to be ours, warm and safe from lightning opened at Operate")
    local power = add("energy-source-electric", "", "AND")
    connect(power, operate)
    assert(explorer_rows.operate_needs_more(graph, operate), "a machine that needs power didn't open at Operate")
end)

test("amounts follow recipe edges, and a stand-in row gets the amount of the node it stands in for", function()
    local graph, add, connect = new_graph()
    local plate = add("item", "plate", "OR")
    local smelting = add("recipe", "smelting", "AND")
    connect(smelting, plate, {inds = {}})
    local leaves = explorer_rows.leaves(graph, plate, function(curr_node, prenode)
        return 0.5
    end)
    assert(leaves.node_to_amount_modifier[gutils.key(smelting)] == 0.5, "recipe edge factor wasn't applied")

    local building_graph, operate = building()
    local building_leaves = explorer_rows.leaves(building_graph, operate)
    assert(building_leaves.node_to_amount_modifier[gutils.key("entity-build", "machine")] == 1, "the Build row standing in under Operate has no amount")
end)

print(num_passed .. " tests passed")

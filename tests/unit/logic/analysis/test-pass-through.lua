-- Plain-Lua regression tests for left-out pass-through nodes (src/logic/analysis/pass-through.lua, not loaded by the mod)
-- Run from the mod root: lua tests/unit/logic/analysis/test-pass-through.lua
--
-- Only nodes that pass on exactly one plain way in are left out, chains of them join into one edge, every node left gets the same contexts in every sort that doesn't depend on order, and expanding gives the full graph back exactly

-- Stand-ins for the Factorio environment
-- Like the game's (core/lualib/util.lua), a table reachable twice is copied once, so a graph's nodes stay the same tables under graph.nodes and under their keys
function table.deepcopy(object)
    local lookup = {}
    local function copy(value)
        if type(value) ~= "table" then
            return value
        elseif lookup[value] ~= nil then
            return lookup[value]
        end
        local new_table = {}
        lookup[value] = new_table
        for k, v in pairs(value) do
            new_table[copy(k)] = copy(v)
        end
        return new_table
    end
    return copy(object)
end
function log(msg) end
serpent = {
    block = tostring,
    line = tostring,
}

-- A seeded stand-in for the mod's rng, so that sorts choosing randomly can be run in different orders
local rng_state = 1
package.loaded["src/lib/random/rng"] = {
    int = function(_, max)
        rng_state = (rng_state * 1103515245 + 12345) % 2147483648
        return math.floor(rng_state / 65536) % max + 1
    end,
}

-- Node types: rooms emit their context, technologies and forgetters forget the room, pass-through types are declared, and the rest pass contexts on unchanged
-- Research home contexts (top.research_home_contexts) go only to technologies (home_carrier), research inputs and unified's edge parts (relay)
local logic = {
    contexts = {},
    type_info = {
        start = {},
        room = { context = "room" },
        stuff = {},
        make = {},
        forget = { context = true },
        technology = {
            context = true,
            home_carrier = true,
        },
        research = { research_input = true },
        ["edge-part"] = { relay = true },
        ["pass-through"] = { pass_through = true },
        ["pass-through-and"] = { pass_through = true },
        -- Declared pass-through but forgetting the room, which a pass-through node never may: it stays
        ["pass-through-forget"] = {
            pass_through = true,
            context = true,
        },
        -- Declared pass-through but a research input, which the sort treats as research: it stays
        ["pass-through-research"] = {
            pass_through = true,
            research_input = true,
        },
    },
}
package.loaded["src/logic/init"] = logic
package.loaded["src/logic/state"] = logic

-- Space locations techs discover (read by top.discovered_rooms)
data = {
    raw = {
        planet = {},
        technology = {},
    },
}
package.loaded["src/prototypes/data-utils"] = {
    get_prot = function(_, name)
        return data.raw["planet"][name]
    end,
}

local gutils = require("src/lib/graph/graph-utils")
local top = require("src/lib/sort/context-sort")
local superpose = require("src/lib/graph/superpose")
local pass_through = require("src/logic/analysis/pass-through")
-- Edge abilities are written as the logic builders used to write them, like { [2] = true }, and edges have them as a code (tests/unit/logic/contexts/contexts-for-tests.lua)
local fx = require("tests/unit/logic/contexts/contexts-for-tests")

local key = gutils.key

local function new_graph()
    return {
        nodes = {},
        edges = {},
        sources = {},
    }
end

-- Adds a node with extra fields and its prerequisites (keys), and returns its key
local function add(graph, node_type, name, op, pres, extra)
    local fields = {
        op = op,
    }
    for k, v in pairs(extra or {}) do
        fields[k] = v
    end
    local node = gutils.add_node(graph, node_type, name, fields)
    local node_key = key(node)
    if op == "AND" then
        graph.sources[node_key] = true
    end
    for _, pre in pairs(pres or {}) do
        gutils.add_edge(graph, pre, node_key)
    end
    return node_key
end

local function edge_key(start, stop)
    return gutils.ekey({
        start = start,
        stop = stop,
    })
end

local function set_rooms(rooms)
    logic.contexts = {}
    for _, room in pairs(rooms) do
        logic.contexts[room] = true
    end
end

-- num_pre, pre and dep agree with the edges, edges have both ends, and nothing removed is left under its key in the graph table itself
local function check_invariants(graph, label)
    for node_key, node in pairs(graph.nodes) do
        local num_pre = 0
        for pre, _ in pairs(node.pre) do
            num_pre = num_pre + 1
            assert(graph.edges[pre] ~= nil and graph.edges[pre].stop == node_key, label .. ": " .. node_key .. " has a stale prerequisite " .. pre)
        end
        assert(num_pre == node.num_pre, label .. ": " .. node_key .. " counts " .. node.num_pre .. " prerequisites but has " .. num_pre)
        for dep, _ in pairs(node.dep) do
            assert(graph.edges[dep] ~= nil and graph.edges[dep].start == node_key, label .. ": " .. node_key .. " has a stale dependent " .. dep)
        end
        assert(graph[node_key] == node, label .. ": " .. node_key .. " isn't under its key")
    end
    for k, edge in pairs(graph.edges) do
        assert(graph.nodes[edge.start] ~= nil and graph.nodes[edge.stop] ~= nil, label .. ": edge " .. k .. " lost an end")
        assert(graph.nodes[edge.start].dep[k] and graph.nodes[edge.stop].pre[k], label .. ": edge " .. k .. " isn't in its ends' sets")
    end
    for k, object in pairs(graph) do
        if type(object) == "table" and object.object_type == "node" then
            assert(graph.nodes[k] == object, label .. ": removed node " .. k .. " is still under its key")
        elseif type(object) == "table" and object.object_type == "edge" then
            assert(graph.edges[k] == object, label .. ": removed edge " .. k .. " is still under its key")
        end
    end
end

-- Every node and edge with its fields, as one string
local function structure(graph)
    local lines = {}
    for node_key, node in pairs(graph.nodes) do
        local fields = {}
        for k, v in pairs(node) do
            if k ~= "pre" and k ~= "dep" and type(v) ~= "table" then
                table.insert(fields, k .. "=" .. tostring(v))
            end
        end
        table.sort(fields)
        table.insert(lines, "n " .. node_key .. " " .. table.concat(fields, " "))
    end
    for k, edge in pairs(graph.edges) do
        local fields = {}
        for field, v in pairs(edge) do
            if type(v) ~= "table" then
                table.insert(fields, field .. "=" .. tostring(v))
            end
        end
        table.sort(fields)
        table.insert(lines, "e " .. k .. " " .. table.concat(fields, " "))
    end
    table.sort(lines)
    return table.concat(lines, "\n")
end

-- The first line where two strings differ, for messages
local function first_difference(a, b)
    local a_lines = {}
    for line in string.gmatch(a, "[^\n]+") do
        table.insert(a_lines, line)
    end
    local i = 0
    for line in string.gmatch(b, "[^\n]+") do
        i = i + 1
        if a_lines[i] ~= line then
            return tostring(a_lines[i]) .. "  vs  " .. line
        end
    end
    return "(lengths differ)"
end

-- The contexts of every node of keep_graph in a sort, as one string
local function contexts_of(sort_info, keep_graph)
    local lines = {}
    for node_key, _ in pairs(keep_graph.nodes) do
        local names = {}
        for context, _ in pairs(sort_info.node_to_context_inds[node_key] or {}) do
            table.insert(names, top.context_name(context))
        end
        table.sort(names)
        table.insert(lines, node_key .. ": " .. table.concat(names, ", "))
    end
    table.sort(lines)
    return table.concat(lines, "\n")
end

-- Sorts both graphs the same ways that don't depend on order (see src/logic/analysis/reduction-check.lua) and checks every node the contracted graph has gets the same contexts; returns the pebbles saved
local function check_same_contexts(full, contracted, home_sets, seed, label)
    local implied = top.implied_home_contexts
    top.implied_home_contexts = false
    local options = {
        {},
        {
            complex_contexts = true,
            home_contexts = true,
            home_sets = home_sets,
        },
        {
            choose_randomly = true,
            complex_contexts = true,
            home_contexts = true,
            home_sets = home_sets,
        },
    }
    if next(top.room_discoverers(full)) == nil then
        table.insert(options, {
            complex_contexts = true,
        })
    end
    local saved = 0
    for i, extra in pairs(options) do
        rng_state = seed
        local full_sort = top.sort(full, nil, nil, table.deepcopy(extra))
        rng_state = seed + 7
        local contracted_sort = top.sort(contracted, nil, nil, table.deepcopy(extra))
        local a = contexts_of(full_sort, contracted)
        local b = contexts_of(contracted_sort, contracted)
        assert(a == b, label .. ", sort " .. i .. ": contexts differ: " .. first_difference(a, b))
        saved = saved + #full_sort.pebble_keys - #contracted_sort.pebble_keys
    end
    top.implied_home_contexts = implied
    return saved
end

----------------------------------------------------------------------
-- One of each: what's left out and what stays
----------------------------------------------------------------------

local HOME = "planet: home"

do
    set_rooms({ HOME })
    data.raw.planet = {}
    data.raw.technology = {}
    local graph = new_graph()
    local home = add(graph, "room", HOME, "OR", { add(graph, "start", "", "AND", {}) })
    local ore = add(graph, "stuff", "ore", "OR", { add(graph, "make", "mine", "AND", { home }) })
    local plate = add(graph, "stuff", "plate", "OR", { add(graph, "make", "smelt", "AND", { ore }) })
    -- A chain of two pass-through nodes joins into one edge
    local chain2 = add(graph, "pass-through", "chain-2", "OR", { add(graph, "pass-through-and", "chain-1", "AND", { ore }) })
    add(graph, "make", "after-chain", "AND", { chain2, plate })
    -- Two ways in: it chooses between them, so it stays
    add(graph, "make", "after-choice", "AND", { add(graph, "pass-through", "choice", "OR", { ore, plate }) })
    -- Two ways out: no single edge can stand for it
    local fork = add(graph, "pass-through", "fork", "OR", { ore })
    add(graph, "make", "fork-a", "AND", { fork })
    add(graph, "make", "fork-b", "AND", { fork })
    -- An edge with abilities, an edge with an amount, a node with a cost and a mechanic goal: each stays
    local with_abilities = add(graph, "pass-through", "abilities", "OR", {})
    gutils.add_edge(graph, ore, with_abilities, {
        abilities = fx.edge({ [2] = true }),
    })
    add(graph, "make", "after-abilities", "AND", { with_abilities })
    local with_amount = add(graph, "pass-through", "amount", "OR", {})
    gutils.add_edge(graph, ore, with_amount, {
        amount = 2,
    })
    add(graph, "make", "after-amount", "AND", { with_amount })
    add(graph, "make", "after-cost", "AND", { add(graph, "pass-through", "cost", "OR", { ore }, { cost = 3 }) })
    add(graph, "make", "after-mechanic", "AND", { add(graph, "pass-through", "mechanic", "OR", { ore }, { mechanic = true }) })
    -- A type declared pass-through that forgets the room stays
    add(graph, "make", "after-forget", "AND", { add(graph, "pass-through-forget", "forgetter", "AND", { ore }) })
    -- Joining would duplicate an edge that's already there
    local both = add(graph, "make", "after-both", "AND", { plate })
    gutils.add_edge(graph, add(graph, "pass-through", "beside", "OR", { plate }), both)
    -- An undeclared type in the same spot stays
    add(graph, "make", "after-plain", "AND", { add(graph, "stuff", "not-declared", "OR", { ore }) })
    -- On a loop: joining would make an edge from a node to itself
    local loop = add(graph, "make", "loop", "OR", { plate })
    gutils.add_edge(graph, add(graph, "pass-through", "on-loop", "OR", { loop }), loop)
    -- Between a technology and research it's needed for, which both pass research home contexts on, it stays; before research from anything else it goes
    local tech = add(graph, "technology", "t1", "AND", { plate })
    add(graph, "research", "needs-t1", "AND", { add(graph, "pass-through", "after-tech", "OR", { tech }), add(graph, "pass-through", "before-research", "OR", { ore }) })
    add(graph, "make", "after-research-type", "AND", { add(graph, "pass-through-research", "research-itself", "AND", { ore }) })
    check_invariants(graph, "one of each, full")

    local contracted = table.deepcopy(graph)
    local num = pass_through.contract(contracted)
    check_invariants(contracted, "one of each, contracted")
    assert(num == 3, "left out chain-1, chain-2 and before-research, not " .. num)
    for _, name in pairs({ "choice", "fork", "abilities", "amount", "cost", "mechanic", "beside", "on-loop", "after-tech" }) do
        assert(contracted.nodes[key("pass-through", name)] ~= nil, name .. " stays")
    end
    assert(contracted.nodes[key("pass-through", "before-research")] == nil, "before-research goes")
    assert(contracted.nodes[key("pass-through-forget", "forgetter")] ~= nil, "a forgetter stays")
    assert(contracted.nodes[key("pass-through-research", "research-itself")] ~= nil, "a research input stays")
    local joined = contracted.edges[edge_key(ore, key("make", "after-chain"))]
    assert(joined ~= nil and #joined.through == 2 and joined.through[1].name == "chain-1" and joined.through[2].name == "chain-2", "the chain joins into one edge going through both, in order")
    assert(#pass_through.joined_edges(contracted) == 2, "two joined edges")
    assert(check_same_contexts(graph, contracted, nil, 1, "one of each") > 0, "fewer pebbles")

    local expanded = table.deepcopy(contracted)
    assert(pass_through.expand_all(expanded) == 2, "two joined edges expand")
    check_invariants(expanded, "one of each, expanded")
    assert(structure(expanded) == structure(graph), "expanding gives the full graph back: " .. first_difference(structure(graph), structure(expanded)))
    assert(#pass_through.joined_edges(expanded) == 0, "nothing joined after expanding")
end
print("ok - one of each: only plain pass-through nodes with one way in and out are left out, none where research home contexts would cross, chains join in order and expand back")

----------------------------------------------------------------------
-- Superposing two games where a pass-through node is left out in one and not the other
----------------------------------------------------------------------

do
    set_rooms({ HOME })
    local function game(both_ways_in)
        local graph = new_graph()
        local home = add(graph, "room", HOME, "OR", { add(graph, "start", "", "AND", {}) })
        local ore = add(graph, "stuff", "ore", "OR", { add(graph, "make", "mine", "AND", { home }) })
        local wood = add(graph, "stuff", "wood", "OR", { add(graph, "make", "chop", "AND", { home }) })
        add(graph, "make", "build", "AND", { add(graph, "pass-through", "way", "OR", both_ways_in and { ore, wood } or { wood }) })
        pass_through.contract(graph)
        return graph
    end
    -- The old game reaches the pass-through node through ore or wood, the new one only through wood, where it's left out
    local old = game(true)
    local new = game(false)
    assert(old.nodes[key("pass-through", "way")] ~= nil and new.nodes[key("pass-through", "way")] == nil, "the pass-through node is left out only in the new game")
    local union = superpose.union(new, old)
    assert(#union.not_into_or == 0, "the old way in is debt into the pass-through node, an OR node: " .. table.concat(union.not_into_or, ", "))
    -- With wood blocked, the old way through ore still builds
    local blocked = table.deepcopy(union.graph)
    gutils.add_edge(blocked, add(blocked, "stuff", "never", "OR", {}), key("make", "chop"))
    local reached = top.sort(blocked).node_to_context_inds
    assert(next(reached[key("make", "chop")] or {}) == nil, "wood is blocked")
    assert(next(reached[key("make", "build")] or {}) ~= nil, "building comes through the old way")
end
print("ok - superposed games line up where a pass-through node was left out in only one of them")

----------------------------------------------------------------------
-- Random games
----------------------------------------------------------------------

local function random_abilities()
    local choices = {
        false,
        false,
        { [1] = false },
        { [1] = true },
        { [2] = true },
        { [2] = false },
    }
    local choice = choices[math.random(#choices)]
    if choice == false then
        return nil
    end
    return choice
end

-- Rooms, items, makers and forgetters with random AND/OR nodes and cycles, technologies (some discovering rooms, some after research inputs), unified's edge parts, and pass-through nodes (some chained, some with several ways in or out, some with abilities, amounts or fields that keep them) on random edges
local function random_game(num_rooms, num_nodes, num_techs, num_pass_through)
    local rooms = {}
    data.raw.planet = {}
    data.raw.technology = {}
    for i = 1, num_rooms do
        table.insert(rooms, "planet: r" .. tostring(i))
        data.raw.planet["r" .. tostring(i)] = {
            type = "planet",
            name = "r" .. tostring(i),
        }
    end
    set_rooms(rooms)
    local graph = new_graph()
    local function try_edge(start, stop, extra)
        if start ~= stop and graph.edges[edge_key(start, stop)] == nil then
            gutils.add_edge(graph, start, stop, extra)
            return true
        end
        return false
    end
    local start = add(graph, "start", "", "AND", {})
    local room_keys = {}
    for i = 1, num_rooms do
        room_keys[i] = add(graph, "room", rooms[i], "OR", {})
    end
    try_edge(start, room_keys[1])
    local keys = { start }
    local node_types = { "stuff", "make", "forget" }
    for i = 1, num_nodes do
        local op = math.random() < 0.5 and "OR" or "AND"
        local node_key = add(graph, node_types[math.random(#node_types)], "n" .. tostring(i), op, {})
        for _ = 1, math.random(1, 3) do
            local abilities = random_abilities()
            local extra = abilities ~= nil and { abilities = fx.edge(abilities) } or nil
            if math.random() < 0.3 then
                try_edge(room_keys[math.random(num_rooms)], node_key, extra)
            else
                try_edge(keys[math.random(#keys)], node_key, extra)
            end
        end
        table.insert(keys, node_key)
    end
    for i = 1, num_techs do
        local name = "t" .. tostring(i)
        if math.random() < 0.3 then
            data.raw.technology[name] = {
                effects = {
                    {
                        type = "unlock-space-location",
                        space_location = "r" .. tostring(math.random(num_rooms)),
                    },
                },
            }
        end
        local tech_key = add(graph, "technology", name, "AND", {})
        for _ = 1, math.random(1, 2) do
            try_edge(keys[math.random(2, #keys)], tech_key, {
                abilities = fx.edge({ [2] = true }),
            })
        end
        -- What its research needs, from anything before it
        if math.random() < 0.7 then
            local research_key = add(graph, "research", "for-" .. name, "AND", {})
            for _ = 1, math.random(1, 2) do
                try_edge(keys[math.random(2, #keys)], research_key)
            end
            try_edge(research_key, tech_key)
            table.insert(keys, research_key)
        end
        table.insert(keys, tech_key)
    end
    -- Unified's edge parts go into random edges too
    do
        local edge_keys = {}
        for k, _ in pairs(graph.edges) do
            table.insert(edge_keys, k)
        end
        table.sort(edge_keys)
        for i = 1, math.random(0, 4) do
            local k = edge_keys[math.random(#edge_keys)]
            local edge = graph.edges[k]
            if edge ~= nil and edge.abilities == nil then
                gutils.remove_edge(graph, k)
                graph[k] = nil
                local part_key = add(graph, "edge-part", "e" .. tostring(i), "OR", {})
                try_edge(edge.start, part_key)
                try_edge(part_key, edge.stop)
            end
        end
    end
    -- Pass-through nodes go into random edges: an edge start --> stop becomes start --> pass-through node(s) --> stop
    local edge_keys = {}
    for k, _ in pairs(graph.edges) do
        table.insert(edge_keys, k)
    end
    table.sort(edge_keys)
    for i = 1, num_pass_through do
        local k = edge_keys[math.random(#edge_keys)]
        local edge = graph.edges[k]
        if edge ~= nil then
            local extra = {}
            for field, v in pairs(edge) do
                if field ~= "object_type" and field ~= "start" and field ~= "stop" then
                    extra[field] = v
                end
            end
            gutils.remove_edge(graph, k)
            graph[k] = nil
            local previous = edge.start
            for j = 1, math.random(1, 3) do
                local fields = {}
                if math.random() < 0.08 then
                    fields.mechanic = true
                end
                local through_type = math.random() < 0.7 and "pass-through" or "pass-through-and"
                local through_key = add(graph, through_type, "r" .. tostring(i) .. "-" .. tostring(j), through_type == "pass-through" and "OR" or "AND", {}, fields)
                -- The first edge keeps the old edge's abilities or amount, if any
                try_edge(previous, through_key, j == 1 and next(extra) ~= nil and extra or nil)
                if math.random() < 0.08 then
                    try_edge(keys[math.random(2, #keys)], through_key)
                end
                if math.random() < 0.05 then
                    try_edge(through_key, keys[math.random(2, #keys)])
                end
                previous = through_key
            end
            try_edge(previous, edge.stop, math.random() < 0.05 and { amount = 1 } or nil)
        end
    end
    -- Rooms after the first come from random nodes, and back edges make cycles
    for i = 2, num_rooms do
        for _ = 1, math.random(1, 2) do
            try_edge(keys[math.random(2, #keys)], room_keys[i])
        end
    end
    for _ = 1, math.floor(num_nodes / 4) do
        local abilities = random_abilities()
        try_edge(keys[math.random(2, #keys)], keys[math.random(2, #keys)], abilities ~= nil and { abilities = fx.edge(abilities) } or nil)
    end
    return graph, rooms
end

do
    local num_spliced = 0
    local saved = 0
    for seed = 1, 150 do
        math.randomseed(seed)
        local full, rooms = random_game(math.random(2, 4), math.random(8, 30), math.random(2, 6), math.random(2, 12))
        check_invariants(full, "seed " .. seed .. " full")
        local contracted = table.deepcopy(full)
        num_spliced = num_spliced + pass_through.contract(contracted)
        check_invariants(contracted, "seed " .. seed .. " contracted")
        local home_sets = {
            ids = { 1, 2 },
            sets = {
                [1] = {
                    rooms = {
                        [rooms[1]] = true,
                    },
                    discovered = {},
                },
                [2] = {
                    rooms = {
                        [rooms[1]] = true,
                        [rooms[math.random(2, #rooms)]] = true,
                    },
                    discovered = {},
                },
            },
            of = {},
        }
        saved = saved + check_same_contexts(full, contracted, home_sets, seed, "seed " .. seed)
        local expanded = table.deepcopy(contracted)
        pass_through.expand_all(expanded)
        check_invariants(expanded, "seed " .. seed .. " expanded")
        assert(structure(expanded) == structure(full), "seed " .. seed .. ": expanding gives the full graph back: " .. first_difference(structure(full), structure(expanded)))
        -- Contracting again leaves out the same nodes
        pass_through.contract(expanded)
        assert(structure(expanded) == structure(contracted), "seed " .. seed .. ": contracting again gives the same graph: " .. first_difference(structure(contracted), structure(expanded)))
    end
    assert(num_spliced > 300, "the random games leave pass-through nodes out (" .. num_spliced .. ")")
    assert(saved > 0, "the random games' contracted sorts have fewer pebbles")
    print("ok - 150 random games: " .. num_spliced .. " pass-through nodes left out, same contexts in every sort, " .. saved .. " pebbles saved, expanded back exactly")
end

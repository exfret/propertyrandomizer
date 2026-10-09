-- Plain-Lua regression tests for contracted recipe unlocks (lib/logic/unlock-contraction.lua, not loaded by the mod)
-- Run from the mod root: lua lib/logic/test-unlock-contraction.lua
--
-- A contracted graph must give every node it keeps the same contexts as the full graph in every kind of sort, expanding must give the full graph back, and finding or adding unlocks must work in both shapes

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
package.loaded["lib/random/rng"] = {
    int = function(_, max)
        rng_state = (rng_state * 1103515245 + 12345) % 2147483648
        return math.floor(rng_state / 65536) % max + 1
    end,
}

-- Node types as lib/logic/concrete.lua declares them: rooms emit their context, technologies forget the room, the rest pass contexts on
local logic = {
    contexts = {},
    type_info = {
        start = {},
        room = { context = "room" },
        stuff = {},
        make = {},
        forget = { context = true },
        technology = { context = true },
        recipe = {},
        ["recipe-unlock"] = {},
        ["recipe-tech-unlock"] = {},
        ["entity-operate"] = {},
    },
}
package.loaded["lib/logic/init"] = logic
package.loaded["lib/logic/state"] = logic

-- Space locations techs discover (read by top.discovered_rooms)
data = {
    raw = {
        planet = {},
        technology = {},
    },
}
package.loaded["lib/data-utils"] = {
    get_prot = function(_, name)
        return data.raw["planet"][name]
    end,
}

local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")
local superpose = require("lib/graph/superpose")
local pass_through = require("lib/logic/pass-through")
local unlock_contraction = require("lib/logic/unlock-contraction")
-- Edge abilities are written as the logic builders used to write them, like { [2] = true }, and edges have them as a code (lib/graph/contexts-for-tests.lua)
local fx = require("lib/graph/contexts-for-tests")

local key = gutils.key

local function new_graph()
    return {
        nodes = {},
        edges = {},
        sources = {},
    }
end

-- Adds a node with its prerequisites (keys), each edge with abilities (or nil) as given by abilities_of(pre), and returns its key
local function add(graph, node_type, name, op, pres, abilities_of)
    local node = gutils.add_node(graph, node_type, name, {
        op = op,
        class = node_type == "recipe-tech-unlock" and "recipe" or node_type == "recipe-unlock" and "recipe" or node_type,
        prot = "prot: " .. name,
    })
    if op == "AND" and graph.sources ~= nil then
        graph.sources[key(node)] = true
    end
    local node_key = key(node)
    for _, pre in pairs(pres or {}) do
        local abilities = abilities_of ~= nil and abilities_of(pre) or nil
        gutils.add_edge(graph, pre, node_key, abilities ~= nil and { abilities = fx.edge(abilities) } or nil)
    end
    return node_key
end

-- A recipe as concrete.lua builds it: locked ones get recipe-unlock (fixed-recipe machines too) over recipe-tech-unlock (its technologies)
local function add_recipe(graph, name, ingredients, techs, machines, tech_abilities)
    local pres = {}
    for _, ingredient in pairs(ingredients) do
        table.insert(pres, ingredient)
    end
    if techs ~= nil then
        local tech_unlock = add(graph, "recipe-tech-unlock", name, "OR", techs, function()
            return tech_abilities
        end)
        local unlock_pres = { tech_unlock }
        for _, machine in pairs(machines or {}) do
            table.insert(unlock_pres, machine)
        end
        table.insert(pres, add(graph, "recipe-unlock", name, "OR", unlock_pres))
    end
    return add(graph, "recipe", name, "AND", pres)
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
        if node.op == "AND" and node.num_pre == 0 then
            assert(graph.sources[node_key], label .. ": " .. node_key .. " is an AND node without prerequisites but not a source")
        end
    end
    for edge_key, edge in pairs(graph.edges) do
        assert(graph.nodes[edge.start] ~= nil and graph.nodes[edge.stop] ~= nil, label .. ": edge " .. edge_key .. " lost an end")
        assert(graph.nodes[edge.start].dep[edge_key] and graph.nodes[edge.stop].pre[edge_key], label .. ": edge " .. edge_key .. " isn't in its ends' sets")
    end
    for k, object in pairs(graph) do
        if type(object) == "table" and object.object_type == "node" then
            assert(graph.nodes[k] == object, label .. ": removed node " .. k .. " is still under its key")
        elseif type(object) == "table" and object.object_type == "edge" then
            assert(graph.edges[k] == object, label .. ": removed edge " .. k .. " is still under its key")
        end
    end
end

-- Node keys, edge keys (with abilities), and the restored nodes' fields, as one string
local function structure(graph)
    local lines = {}
    for node_key, node in pairs(graph.nodes) do
        table.insert(lines, "n " .. node_key .. " " .. tostring(node.op) .. " " .. tostring(node.class) .. " " .. tostring(node.prot))
    end
    for edge_key, edge in pairs(graph.edges) do
        table.insert(lines, "e " .. edge_key .. " " .. tostring(edge.abilities))
    end
    table.sort(lines)
    return table.concat(lines, "\n")
end

-- The contexts of every node of keep_graph in a sort, as one string, to compare sorts of two shapes regardless of order
local function contexts_of(sort_info, keep_graph)
    local lines = {}
    for node_key, _ in pairs(keep_graph.nodes) do
        local contexts = {}
        for context, _ in pairs(sort_info.node_to_context_inds[node_key] or {}) do
            table.insert(contexts, top.context_name(context))
        end
        table.sort(contexts)
        table.insert(lines, node_key .. ": " .. table.concat(contexts, ", "))
    end
    table.sort(lines)
    return table.concat(lines, "\n")
end

local function count_pebbles(sort_info)
    return #sort_info.pebble_keys
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

-- Sorts the full and the contracted graph the same ways and checks every node the contracted graph has gets the same contexts
-- The shapes reach things in different orders, so only what doesn't depend on order can be compared:
--   * Complex contexts without home contexts use the discovery rule that makes every tech reached so far isolatable in a room when it's discovered (discover_space_locations in top.sort), so they're compared only without discoverers; every data-stage sort with complex contexts has home contexts, whose rule doesn't depend on order
--   * Home contexts are recorded without letting a smaller set's context stand for a bigger one's (top.implied_home_contexts), since which of those gets recorded depends on the order pebbles arrive in
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
        table.insert(options, { complex_contexts = true })
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
        saved = saved + count_pebbles(full_sort) - count_pebbles(contracted_sort)
    end
    top.implied_home_contexts = implied
    return saved
end

----------------------------------------------------------------------
-- Toy game: one recipe of each kind
----------------------------------------------------------------------

local HOME = "planet: home"
local AWAY = "planet: away"

local function toy_graph()
    set_rooms({ HOME, AWAY })
    data.raw.planet = {
        away = {
            type = "planet",
            name = "away",
        },
    }
    data.raw.technology = {
        ["t-find"] = {
            effects = {
                {
                    type = "unlock-space-location",
                    space_location = "away",
                },
            },
        },
    }
    local graph = new_graph()
    local start = add(graph, "start", "", "AND", {})
    local home = add(graph, "room", HOME, "OR", { start })
    local ore = add(graph, "stuff", "ore", "OR", { add(graph, "make", "mine", "AND", { home }) })
    -- Every edge into a tech asks for automatability (lib/logic/concrete.lua)
    local function automatable()
        return { [2] = true }
    end
    local t1 = add(graph, "technology", "t1", "AND", { ore }, automatable)
    local t2 = add(graph, "technology", "t2", "AND", { ore, t1 }, automatable)
    local find = add(graph, "technology", "t-find", "AND", { t2 }, automatable)
    local away = add(graph, "room", AWAY, "OR", { add(graph, "make", "fly", "AND", { find }) })
    local rock = add(graph, "stuff", "rock", "OR", { add(graph, "make", "mine-rock", "AND", { away }) })
    local machine = add(graph, "entity-operate", "fixed-machine", "AND", { rock })
    -- One technology: contracted
    add_recipe(graph, "r-one", { ore }, { t1 })
    -- Several technologies: they need their OR node
    add_recipe(graph, "r-two", { ore }, { t1, find })
    -- No technology: the empty OR keeps it locked
    add_recipe(graph, "r-none", { ore }, {})
    -- A fixed-recipe machine is another way in
    add_recipe(graph, "r-fixed", { rock }, { t2 }, { machine })
    -- Unlocked from the start
    add_recipe(graph, "r-free", { ore })
    -- An unlock edge with abilities isn't plain, so its unlock nodes can't be left out
    add_recipe(graph, "r-abilities", { ore }, { t2 }, nil, { [1] = false })
    -- Made on the other planet, after its discovery
    add_recipe(graph, "r-away", { rock }, { find })
    return graph
end

do
    local full = toy_graph()
    check_invariants(full, "toy full")
    local contracted = table.deepcopy(full)
    local num = unlock_contraction.contract(contracted)
    check_invariants(contracted, "toy contracted")
    assert(num == 2, "contracted r-one and r-away, not " .. num)
    for _, name in pairs({ "r-one", "r-away" }) do
        assert(contracted.nodes[key("recipe-tech-unlock", name)] == nil and contracted.nodes[key("recipe-unlock", name)] == nil, name .. " loses both unlock nodes")
    end
    assert(contracted.edges[gutils.ekey({ start = key("technology", "t1"), stop = key("recipe", "r-one") })] ~= nil, "r-one's technology unlocks it directly")
    for _, name in pairs({ "r-two", "r-none", "r-fixed", "r-abilities" }) do
        assert(contracted.nodes[key("recipe-tech-unlock", name)] ~= nil and contracted.nodes[key("recipe-unlock", name)] ~= nil, name .. " keeps both unlock nodes")
    end

    -- The same contexts everywhere, and the unlock nodes' pebbles saved
    -- Home set ids are numbers (top.home_sets)
    local home_sets = {
        ids = { 1 },
        sets = {
            [1] = {
                rooms = {
                    [HOME] = true,
                },
                discovered = {},
            },
        },
        of = {},
    }
    local saved = check_same_contexts(full, contracted, home_sets, 1, "toy")
    assert(saved > 0, "the contracted sorts have fewer pebbles")
    local sort_info = top.sort(contracted, nil, nil, {
        complex_contexts = true,
    })
    assert(next(sort_info.node_to_context_inds[key("recipe", "r-none")] or {}) == nil, "a recipe nothing unlocks stays unreachable")
    assert(next(sort_info.node_to_context_inds[key("recipe", "r-one")] or {}) ~= nil, "r-one is reachable")

    -- Finding unlocks in either shape
    local function starts(graph, edge_keys)
        local names = {}
        for _, edge_key in pairs(edge_keys) do
            table.insert(names, gutils.deconstruct(graph.edges[edge_key].start).name .. ">" .. gutils.deconstruct(graph.edges[edge_key].stop).type)
        end
        return table.concat(names, " ")
    end
    for _, graph in pairs({ full, contracted }) do
        assert(starts(graph, unlock_contraction.tech_edges(graph, "r-two")) == "t-find>recipe-tech-unlock t1>recipe-tech-unlock", "r-two's technologies: " .. starts(graph, unlock_contraction.tech_edges(graph, "r-two")))
        assert(#unlock_contraction.tech_edges(graph, "r-none") == 0, "nothing unlocks r-none")
        assert(#unlock_contraction.tech_edges(graph, "r-free") == 0, "nothing unlocks r-free")
        assert(starts(graph, unlock_contraction.tech_edges(graph, "r-fixed")) == "t2>recipe-tech-unlock", "r-fixed's technology")
    end
    assert(starts(full, unlock_contraction.tech_edges(full, "r-one")) == "t1>recipe-tech-unlock", "r-one's technology, full")
    assert(starts(contracted, unlock_contraction.tech_edges(contracted, "r-one")) == "t1>recipe", "r-one's technology, contracted")
    local function edge(graph, start, stop)
        return graph.edges[gutils.ekey({ start = start, stop = stop })]
    end
    assert(unlock_contraction.is_unlock_edge(contracted, edge(contracted, key("technology", "t1"), key("recipe", "r-one"))), "a contracted unlock is an unlock")
    assert(unlock_contraction.is_unlock_edge(contracted, edge(contracted, key("technology", "t1"), key("recipe-tech-unlock", "r-two"))), "an unlock into recipe-tech-unlock is an unlock")
    assert(not unlock_contraction.is_unlock_edge(contracted, edge(contracted, key("technology", "t1"), key("technology", "t2"))), "a tech prerequisite isn't an unlock")
    assert(not unlock_contraction.is_unlock_edge(contracted, edge(contracted, key("stuff", "ore"), key("recipe", "r-one"))), "an ingredient isn't an unlock")
    assert(unlock_contraction.unlocked_recipe(contracted, contracted.nodes[key("recipe", "r-one")]) == "r-one", "a contracted recipe's pebble stands for its unlock")
    assert(unlock_contraction.unlocked_recipe(contracted, contracted.nodes[key("recipe-tech-unlock", "r-two")]) == "r-two", "a recipe-tech-unlock pebble stands for its recipe's unlock")
    assert(unlock_contraction.unlocked_recipe(contracted, contracted.nodes[key("recipe", "r-two")]) == nil, "a recipe with its unlock node doesn't stand for it itself")
    assert(unlock_contraction.unlocked_recipe(contracted, contracted.nodes[key("recipe", "r-free")]) == nil, "a recipe unlocked from the start has no unlock")
    assert(unlock_contraction.unlocked_recipe(contracted, contracted.nodes[key("technology", "t1")]) == nil, "a tech isn't an unlock")
    assert(#unlock_contraction.contracted_recipes(contracted) == 2 and #unlock_contraction.contracted_recipes(full) == 0, "contracted recipes are counted")

    -- Expanding gives the full graph back
    local expanded = table.deepcopy(contracted)
    assert(pass_through.expand_all(expanded) == 2, "both contracted recipes expand")
    check_invariants(expanded, "toy expanded")
    assert(structure(expanded) == structure(full), "expanding gives the full graph back: " .. first_difference(structure(full), structure(expanded)))
    assert(unlock_contraction.expand(expanded, "r-free") == nil, "a recipe unlocked from the start has nothing to expand")
    assert(unlock_contraction.expand(expanded, "r-two") == key("recipe-tech-unlock", "r-two"), "a recipe with its unlock node keeps it")

    -- A second technology added after expanding is another way in, not another requirement
    local one = table.deepcopy(contracted)
    local unlock_key = unlock_contraction.expand(one, "r-one")
    assert(unlock_key == key("recipe-tech-unlock", "r-one"), "expand returns the recipe-tech-unlock node")
    -- t2 and t-find need t1, so the second technology needs only ore
    gutils.add_edge(one, add(one, "technology", "t-other", "AND", { key("stuff", "ore") }), unlock_key)
    check_invariants(one, "toy second unlock")
    -- An OR node with no way in never gets a pebble, so t1 needing it is blocked
    gutils.add_edge(one, add(one, "stuff", "never", "OR", {}), key("technology", "t1"))
    local reached = top.sort(one).node_to_context_inds
    assert(next(reached[key("technology", "t1")] or {}) == nil, "t1 is blocked")
    assert(next(reached[key("recipe", "r-one")] or {}) ~= nil, "r-one comes through its second technology")
end
print("ok - toy game: contraction keeps every context, finds unlocks in both shapes and expands back")

----------------------------------------------------------------------
-- Superposing two games whose technology for a recipe differs
----------------------------------------------------------------------

do
    set_rooms({ HOME })
    data.raw.planet = {}
    data.raw.technology = {}
    local function game(tech_name)
        local graph = new_graph()
        local home = add(graph, "room", HOME, "OR", { add(graph, "start", "", "AND", {}) })
        local ore = add(graph, "stuff", "ore", "OR", { home })
        local t1 = add(graph, "technology", "t1", "AND", { ore })
        local t2 = add(graph, "technology", "t2", "AND", { ore })
        add_recipe(graph, "r", { ore }, { tech_name == "t1" and t1 or t2 })
        unlock_contraction.contract(graph)
        return graph
    end
    local old = game("t1")
    local new = game("t2")
    assert(#unlock_contraction.contracted_recipes(old) == 1 and #unlock_contraction.contracted_recipes(new) == 1, "both games are contracted")
    local old_copy = table.deepcopy(old)
    local union = superpose.union(new, old)
    assert(structure(old) == structure(old_copy), "the union leaves the old game alone")
    assert(#union.not_into_or == 0, "the old unlock is an edge into an OR node: " .. table.concat(union.not_into_or, ", "))
    local debt_into_unlock = false
    for edge_key, _ in pairs(union.debt_edges) do
        local edge = union.graph.edges[edge_key]
        if edge.start == key("technology", "t1") and edge.stop == key("recipe-tech-unlock", "r") then
            debt_into_unlock = true
        end
    end
    assert(debt_into_unlock, "the old technology's unlock is debt into the recipe-tech-unlock node")
    -- Either technology unlocks the recipe in the superposition
    for _, blocked in pairs({ "t1", "t2" }) do
        local graph = table.deepcopy(union.graph)
        gutils.add_edge(graph, add(graph, "stuff", "never", "OR", {}), key("technology", blocked))
        local reached = top.sort(graph).node_to_context_inds
        assert(next(reached[key("technology", blocked)] or {}) == nil, blocked .. " is blocked")
        assert(next(reached[key("recipe", "r")] or {}) ~= nil, "the recipe comes through the other technology with " .. blocked .. " blocked")
    end
    -- A graph of the new game taking the debt, expanded like unified's (see unified.execute), gets the old unlock as another way in
    local target = table.deepcopy(new)
    pass_through.expand_all(target)
    local added = superpose.add_debt(target, union)
    local found = false
    for _, added_edge in pairs(added) do
        if added_edge.start == key("technology", "t1") and added_edge.stop == key("recipe-tech-unlock", "r") then
            found = true
        end
    end
    assert(found, "the debt's unlock fits the expanded graph")
end
print("ok - superposed games unlock a recipe by either technology")

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

-- Rooms, items, makers and forgetters with random AND/OR nodes and cycles, technologies (some discovering rooms) and recipes with every kind of unlock
local function random_game(num_rooms, num_nodes, num_techs, num_recipes)
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
    local function try_edge(start, stop, abilities)
        if start ~= stop and graph.edges[gutils.ekey({ start = start, stop = stop })] == nil then
            gutils.add_edge(graph, start, stop, abilities ~= nil and { abilities = fx.edge(abilities) } or nil)
        end
    end
    local start = add(graph, "start", "", "AND", {})
    local room_keys = {}
    for i = 1, num_rooms do
        room_keys[i] = add(graph, "room", rooms[i], "OR", {})
    end
    try_edge(start, room_keys[1])
    local keys = { start }
    -- What recipes can take as ingredients: anything but technologies, which only unlock them (concrete.lua builds no other technology --> recipe edges)
    local materials = {}
    local node_types = { "stuff", "make", "forget" }
    for i = 1, num_nodes do
        local op = math.random() < 0.5 and "OR" or "AND"
        local node_key = add(graph, node_types[math.random(#node_types)], "n" .. tostring(i), op, {})
        for _ = 1, math.random(1, 3) do
            if math.random() < 0.3 then
                try_edge(room_keys[math.random(num_rooms)], node_key, random_abilities())
            else
                try_edge(keys[math.random(#keys)], node_key, random_abilities())
            end
        end
        table.insert(keys, node_key)
        table.insert(materials, node_key)
    end
    local tech_keys = {}
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
            try_edge(keys[math.random(2, #keys)], tech_key, { [2] = true })
        end
        if #tech_keys > 0 and math.random() < 0.5 then
            try_edge(tech_keys[math.random(#tech_keys)], tech_key, { [2] = true })
        end
        table.insert(tech_keys, tech_key)
        table.insert(keys, tech_key)
    end
    local machine_keys = {}
    for i = 1, math.max(1, math.floor(num_recipes / 4)) do
        local machine_key = add(graph, "entity-operate", "m" .. tostring(i), "AND", {})
        try_edge(keys[math.random(2, #keys)], machine_key)
        table.insert(machine_keys, machine_key)
    end
    for i = 1, num_recipes do
        local ingredients = {}
        for _ = 1, math.random(0, 2) do
            local ingredient = materials[math.random(#materials)]
            local duplicate = false
            for _, other in pairs(ingredients) do
                duplicate = duplicate or other == ingredient
            end
            if not duplicate then
                table.insert(ingredients, ingredient)
            end
        end
        local roll = math.random()
        local techs
        local machines
        local tech_abilities
        if roll < 0.15 then
            -- Unlocked from the start
            techs = nil
        else
            techs = {}
            local num_techs_here = roll < 0.25 and 0 or roll < 0.75 and 1 or math.random(2, 3)
            for _ = 1, num_techs_here do
                local tech_key = tech_keys[math.random(#tech_keys)]
                local duplicate = false
                for _, other in pairs(techs) do
                    duplicate = duplicate or other == tech_key
                end
                if not duplicate then
                    table.insert(techs, tech_key)
                end
            end
            if math.random() < 0.15 then
                machines = { machine_keys[math.random(#machine_keys)] }
            end
            if math.random() < 0.1 then
                tech_abilities = random_abilities()
            end
        end
        local recipe_key = add_recipe(graph, "r" .. tostring(i), ingredients, techs, machines, tech_abilities)
        -- Its product feeds later nodes, and sometimes rooms (like a rocket part)
        local product = add(graph, "stuff", "p" .. tostring(i), "OR", { recipe_key })
        table.insert(keys, product)
        table.insert(materials, product)
        if math.random() < 0.1 then
            try_edge(product, room_keys[math.random(2, math.max(2, num_rooms))])
        end
    end
    -- Rooms after the first come from random nodes, and back edges make cycles
    for i = 2, num_rooms do
        for _ = 1, math.random(1, 2) do
            try_edge(keys[math.random(2, #keys)], room_keys[i])
        end
    end
    for _ = 1, math.floor(num_nodes / 4) do
        try_edge(keys[math.random(2, #keys)], keys[math.random(2, #keys)], random_abilities())
    end
    return graph, rooms
end

do
    local num_games = 0
    local num_contracted = 0
    local saved = 0
    for seed = 1, 150 do
        math.randomseed(seed)
        local full, rooms = random_game(math.random(2, 4), math.random(8, 30), math.random(2, 8), math.random(4, 16))
        check_invariants(full, "seed " .. seed .. " full")
        local contracted = table.deepcopy(full)
        num_contracted = num_contracted + unlock_contraction.contract(contracted)
        check_invariants(contracted, "seed " .. seed .. " contracted")
        -- Home sets: the first room, and the first room with a random other one
        local nested = {
            [rooms[1]] = true,
            [rooms[math.random(2, #rooms)]] = true,
        }
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
                    rooms = nested,
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
        num_games = num_games + 1
    end
    assert(num_contracted > 100, "the random games contract recipes (" .. num_contracted .. ")")
    assert(saved > 0, "the random games' contracted sorts have fewer pebbles")
    print("ok - " .. num_games .. " random games: " .. num_contracted .. " recipes contracted, same contexts in every sort, " .. saved .. " pebbles saved, expanded back exactly")
end

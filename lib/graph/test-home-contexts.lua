-- Plain-Lua regression tests for home contexts and rooms needed in context-sort.lua (not loaded by the mod)
-- Run from the mod root: lua lib/graph/test-home-contexts.lua
--
-- The toy graph is a small solar system: a home planet, a station (a space surface), two planets discovered from home, and a far planet whose discovery needs both of those
-- Random graphs check rooms needed and home contexts against removing rooms and sorting again

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
serpent = {
    block = tostring,
    line = tostring,
}

-- A seeded stand-in for the mod's rng, so that sorts choosing randomly can be run in different orders
local rng_state = 1
package.loaded["lib/random/rng"] = {
    int = function(_, max)
        rng_state = (rng_state * 1103515245 + 12345) % 2147483648
        -- The low bits of this generator repeat quickly, so use the high ones
        return math.floor(rng_state / 65536) % max + 1
    end,
}

local logic = {
    contexts = {},
    type_info = {
        start = {},
        -- Emitter: sends the context named by the node
        room = { context = "room" },
        stuff = {},
        make = {},
        spaceship = {},
        -- Forgetters
        technology = { context = true },
        reach = { context = true },
        forget = { context = true },
    },
}
package.loaded["lib/logic/init"] = logic
package.loaded["lib/logic/state"] = package.loaded["lib/logic/init"]

-- Space locations the toy techs discover (read by top.discovered_rooms)
data = {
    raw = {},
}
package.loaded["lib/data-utils"] = {
    get_prot = function(_, name)
        return data.raw["planet"][name]
    end,
}

local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")

local key = gutils.key

local NO_ABILITIES = string.rep("0", string.len(top.ability_strs[1]))

local function set_rooms(rooms)
    logic.contexts = {}
    for _, room in pairs(rooms) do
        logic.contexts[room] = true
    end
end

local function new_graph()
    return {
        nodes = {},
        edges = {},
        sources = {},
    }
end

local function add_edge(graph, start, stop, abilities)
    local extra
    if abilities ~= nil then
        extra = {
            abilities = abilities,
        }
    end
    gutils.add_edge(graph, start, stop, extra)
end

-- Takes away every way into a room's node, like removing the room
local function remove_room(graph, room)
    local room_key = key("room", room)
    for pre, _ in pairs(table.deepcopy(graph.nodes[room_key].pre)) do
        gutils.remove_edge(graph, pre)
    end
end

-- The home context of a room for a home set id
local function home_context(room, home_id, complex)
    local base = room
    if complex then
        base = top.context_key(room, NO_ABILITIES)
    end
    return top.home_context_key(base, home_id)
end

----------------------------------------------------------------------
-- Toy solar system
----------------------------------------------------------------------

local HOME = "planet: home"
local ROCK = "planet: rock"
local MOSS = "planet: moss"
local FROST = "planet: frost"
local STATION = "surface: station"

-- Returns the graph and its node keys by short name
local function toy_graph()
    set_rooms({ HOME, ROCK, MOSS, FROST, STATION })
    data.raw["planet"] = {}
    data.raw["technology"] = {}
    for _, planet in pairs({ "rock", "moss", "frost" }) do
        data.raw["planet"][planet] = {
            type = "planet",
            name = planet,
        }
        data.raw["technology"]["find-" .. planet] = {
            effects = {
                {
                    type = "unlock-space-location",
                    space_location = planet,
                },
            },
        }
    end

    local graph = new_graph()
    local nodes = {}
    local function node(name, node_type, op, pres, node_name)
        gutils.add_node(graph, node_type, node_name or name, {
            op = op,
        })
        nodes[name] = key(node_type, node_name or name)
        for _, pre in pairs(pres) do
            add_edge(graph, nodes[pre], nodes[name])
        end
    end

    node("start", "start", "AND", {})
    node("home", "room", "OR", { "start" }, HOME)
    node("mine-ore", "make", "AND", { "home" })
    node("ore", "stuff", "OR", { "mine-ore" })
    node("t-basic", "technology", "AND", { "ore" })
    node("t-platform", "technology", "AND", { "t-basic" })
    node("launch", "make", "AND", { "ore", "t-platform" })
    node("create-station", "make", "AND", { "launch" })
    node("station", "room", "OR", { "create-station" }, STATION)
    node("grab-chunk", "make", "AND", { "station" })
    node("chunk", "stuff", "OR", { "grab-chunk" })
    node("craft-pack", "make", "AND", { "chunk" })
    -- Space packs are made on the station and delivered anywhere (a forgetter), which loses isolatability
    node("space-pack", "stuff", "OR", { "craft-pack" })
    node("ship-pack", "forget", "AND", { "space-pack" })
    add_edge(graph, nodes["ship-pack"], nodes["space-pack"], {
        [1] = false,
    })
    node("t-space", "technology", "AND", { "space-pack", "t-platform" })
    node("spaceship", "spaceship", "AND", { "station", "t-space" })
    for _, planet in pairs({ "rock", "moss" }) do
        node("find-" .. planet, "technology", "AND", { "t-space" })
    end
    node("reach-rock", "reach", "AND", { "find-rock", "spaceship" })
    node("rock", "room", "OR", { "reach-rock" }, ROCK)
    node("mine-rock", "make", "AND", { "rock" })
    node("rock-ore", "stuff", "OR", { "mine-rock" })
    -- Like a trigger tech on the rock planet
    node("t-rock", "technology", "AND", { "find-rock", "rock-ore" })
    node("t-cross", "technology", "AND", { "t-rock" })
    node("reach-moss", "reach", "AND", { "find-moss", "spaceship" })
    node("moss", "room", "OR", { "reach-moss" }, MOSS)
    node("grow", "make", "AND", { "moss" })
    node("goo", "stuff", "OR", { "grow" })
    node("t-moss", "technology", "AND", { "find-moss", "goo" })
    -- A chain of techs that only need home, starting where the discoverers do, so that sorts usually reach its end after the rock and moss planets are discovered
    -- Each also needs an item made at home (like a science pack), so its isolatability on other planets can only come from the discovery rule, not from the tech before it
    node("t-late1", "technology", "AND", { "t-space", "ore" })
    for i = 2, 6 do
        node("t-late" .. tostring(i), "technology", "AND", { "t-late" .. tostring(i - 1), "ore" })
    end
    node("smelt-rock", "make", "AND", { "rock-ore", "t-late6" })
    node("rock-plate", "stuff", "OR", { "smelt-rock" })
    -- An item with a quick way from the rock planet and a slow way from home, so a tech needing it usually gets its home context after its other contexts
    node("mine-alt", "make", "AND", { "rock" })
    node("make-alt", "make", "AND", { "t-late6", "ore" })
    node("alt", "stuff", "OR", { "mine-alt", "make-alt" })
    node("t-alt", "technology", "AND", { "alt" })
    node("find-frost", "technology", "AND", { "t-rock", "t-moss" })
    node("reach-frost", "reach", "AND", { "find-frost", "spaceship" })
    node("frost", "room", "OR", { "reach-frost" }, FROST)
    return graph, nodes
end

-- Every pebble of a sort, as one sorted string, to compare sorts regardless of order
local function pebble_set(sort_info, keep)
    local pebbles = {}
    for node_key, inds in pairs(sort_info.node_to_context_inds) do
        for context, _ in pairs(inds) do
            if keep == nil or keep(context) then
                table.insert(pebbles, node_key .. " @@ " .. context)
            end
        end
    end
    table.sort(pebbles)
    return table.concat(pebbles, "\n")
end

local function complex_home_sort(graph, seed)
    rng_state = seed
    return top.sort(graph, nil, nil, {
        choose_randomly = true,
        complex_contexts = true,
        home_contexts = true,
    })
end

----------------------------------------------------------------------
-- Random graphs
----------------------------------------------------------------------

local function random_abilities(complex)
    if not complex then
        return nil
    end
    local choices = {
        false,
        {
            [1] = false,
        },
        {
            [1] = true,
        },
        {
            [2] = true,
        },
        {
            [2] = false,
        },
        {
            [1] = true,
            [2] = false,
        },
    }
    local choice = choices[math.random(#choices)]
    if choice == false then
        return nil
    end
    return choice
end

-- Rooms, emitters, transmitters and forgetters with random AND/OR nodes and cycles (no techs, so no discovery rule)
local function random_graph(seed, num_rooms, num_nodes, complex)
    math.randomseed(seed)
    local rooms = {}
    for i = 1, num_rooms do
        table.insert(rooms, "planet: r" .. tostring(i))
    end
    set_rooms(rooms)

    local graph = new_graph()
    local function try_add_edge(start, stop)
        if start ~= stop and graph.edges[gutils.ekey({ start = start, stop = stop })] == nil then
            add_edge(graph, start, stop, random_abilities(complex))
        end
    end
    gutils.add_node(graph, "start", "", {
        op = "AND",
    })
    local start = key("start", "")
    local keys = { start }
    local room_keys = {}
    for i = 1, num_rooms do
        gutils.add_node(graph, "room", rooms[i], {
            op = "OR",
        })
        room_keys[i] = key("room", rooms[i])
    end
    gutils.add_edge(graph, start, room_keys[1])
    local node_types = { "stuff", "make", "forget" }
    for i = 1, num_nodes do
        local op = "AND"
        if math.random() < 0.5 then
            op = "OR"
        end
        local node_type = node_types[math.random(#node_types)]
        gutils.add_node(graph, node_type, "n" .. tostring(i), {
            op = op,
        })
        local node_key = key(node_type, "n" .. tostring(i))
        for _ = 1, math.random(1, 3) do
            if math.random() < 0.3 then
                try_add_edge(room_keys[math.random(num_rooms)], node_key)
            else
                try_add_edge(keys[math.random(#keys)], node_key)
            end
        end
        table.insert(keys, node_key)
    end
    -- Rooms after the first come from random nodes, and back edges make cycles
    for i = 2, num_rooms do
        for _ = 1, math.random(1, 2) do
            try_add_edge(keys[math.random(2, #keys)], room_keys[i])
        end
    end
    for _ = 1, math.floor(num_nodes / 4) do
        try_add_edge(keys[math.random(2, #keys)], keys[math.random(2, #keys)])
    end
    return graph
end

-- rooms_needed against removing each room and sorting again
local function check_rooms_needed(graph)
    local needed = top.rooms_needed(graph)
    local full_inds = top.sort(graph).node_to_context_inds
    for node_key, inds in pairs(full_inds) do
        for context, _ in pairs(inds) do
            assert(needed(node_key, context) ~= nil, "reached pebble " .. node_key .. " in " .. context .. " has no rooms needed")
        end
    end
    for room, _ in pairs(logic.contexts) do
        local without = table.deepcopy(graph)
        remove_room(without, room)
        local without_inds = top.sort(without).node_to_context_inds
        for node_key, inds in pairs(full_inds) do
            for context, _ in pairs(inds) do
                local is_needed = without_inds[node_key][context] == nil
                local says_needed = needed(node_key, context)[room] ~= nil
                assert(is_needed == says_needed, node_key .. " in " .. context .. ": removing " .. room .. " loses it " .. tostring(is_needed) .. ", but rooms_needed says " .. tostring(says_needed))
            end
        end
    end
end

-- Home contexts against removing every room outside the home set and sorting again, and the other contexts against a sort without home contexts
local function check_home_contexts(graph, complex, home_rooms, seed)
    local home_sets = {
        ids = { "h" },
        sets = {
            h = {
                rooms = home_rooms,
                discovered = {},
            },
        },
        of = {},
    }
    rng_state = seed
    local sort_info = top.sort(graph, nil, nil, {
        choose_randomly = true,
        complex_contexts = complex,
        home_contexts = true,
        home_sets = home_sets,
    })
    local restricted = table.deepcopy(graph)
    for room, _ in pairs(logic.contexts) do
        if home_rooms[room] == nil then
            remove_room(restricted, room)
        end
    end
    local restricted_inds = top.sort(restricted).node_to_context_inds
    for node_key, _ in pairs(graph.nodes) do
        for room, _ in pairs(logic.contexts) do
            local has_home = sort_info.node_to_context_inds[node_key][home_context(room, "h", complex)] ~= nil
            local has_restricted = restricted_inds[node_key][room] ~= nil
            assert(has_home == has_restricted, node_key .. " in " .. room .. ": home context " .. tostring(has_home) .. ", sort without other rooms " .. tostring(has_restricted))
        end
    end
    -- With complex contexts, home contexts also switch the discovery rule, so the other contexts only stay the same without discoverers
    local has_discoverer = false
    for _, node in pairs(graph.nodes) do
        if top.is_discoverer(node) then
            has_discoverer = true
        end
    end
    if not complex or not has_discoverer then
        local without_home = top.sort(graph, nil, nil, {
            complex_contexts = complex,
        })
        local function is_not_home(context)
            return top.context_home(context) == nil
        end
        assert(pebble_set(sort_info, is_not_home) == pebble_set(without_home), "home contexts changed the other contexts")
    end
end

----------------------------------------------------------------------
-- Tests
----------------------------------------------------------------------

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

test("home context keys parse back into room, abilities and home set", function()
    local complex_context = top.home_context_key(top.context_key(ROCK, NO_ABILITIES), "home1")
    assert(top.context_room(complex_context) == ROCK)
    assert(top.context_abilities(complex_context) == NO_ABILITIES)
    assert(top.context_home(complex_context) == "home1")
    local simple_context = top.home_context_key(ROCK, "home1")
    assert(top.context_room(simple_context) == ROCK)
    assert(top.context_abilities(simple_context) == nil)
    assert(top.context_home(simple_context) == "home1")
    assert(top.context_home(top.context_key(ROCK, NO_ABILITIES)) == nil)
    assert(top.context_home(ROCK) == nil)
end)

test("rooms needed match removing each room and sorting again, on the toy graph", function()
    check_rooms_needed(toy_graph())
end)

test("rooms needed match removing each room and sorting again, on random graphs", function()
    for seed = 1, 60 do
        check_rooms_needed(random_graph(seed, 2 + seed % 4, 10 + seed % 30, false))
    end
end)

test("home sets are the rooms each room's discoverers can't be reached without", function()
    local graph = toy_graph()
    local home_sets = top.home_sets(graph)
    assert(#home_sets.ids == 2)
    local near = home_sets.of[ROCK]
    assert(near ~= nil and home_sets.of[MOSS] == near and home_sets.of[STATION] == near)
    local near_rooms = home_sets.sets[near].rooms
    assert(near_rooms[HOME] ~= nil and near_rooms[STATION] ~= nil and near_rooms[ROCK] == nil and near_rooms[MOSS] == nil and near_rooms[FROST] == nil)
    local far = home_sets.of[FROST]
    assert(far ~= nil and far ~= near)
    local far_rooms = home_sets.sets[far].rooms
    assert(far_rooms[HOME] ~= nil and far_rooms[STATION] ~= nil and far_rooms[ROCK] ~= nil and far_rooms[MOSS] ~= nil and far_rooms[FROST] == nil)
    -- The start planet has no discoverer
    assert(home_sets.of[HOME] == nil)
end)

test("home sets report the rooms none of whose discoverers is reachable", function()
    local graph, nodes = toy_graph()
    local _, undiscovered = top.home_sets(graph)
    assert(#undiscovered == 0)
    -- Discovering the far planet now needs something nothing makes, like a world whose rockets need what only a debt would give
    gutils.add_node(graph, "stuff", "nothing", {
        op = "OR",
    })
    add_edge(graph, key("stuff", "nothing"), nodes["find-frost"])
    local home_sets
    home_sets, undiscovered = top.home_sets(graph)
    assert(#undiscovered == 1 and undiscovered[1] == FROST)
    assert(home_sets.of[FROST] == nil and home_sets.of[ROCK] ~= nil)
end)

test("home contexts match removing the other rooms and sorting again, on random graphs", function()
    for seed = 1, 60 do
        local complex = seed % 2 == 0
        local num_rooms = 2 + seed % 4
        local graph = random_graph(seed, num_rooms, 10 + seed % 30, complex)
        -- A random home set, which always has the first room so that something is reachable
        local home_rooms = {}
        for room, _ in pairs(logic.contexts) do
            if room == "planet: r1" or math.random() < 0.5 then
                home_rooms[room] = true
            end
        end
        check_home_contexts(graph, complex, home_rooms, seed)
    end
end)

test("home contexts match removing the other rooms and sorting again, on the toy graph", function()
    local graph = toy_graph()
    local home_sets = top.home_sets(graph)
    for _, complex in pairs({ false, true }) do
        for _, home_id in pairs(home_sets.ids) do
            check_home_contexts(graph, complex, home_sets.sets[home_id].rooms, 7)
        end
    end
end)

test("with home contexts, the discovery rule gives isolatability to home techs and nothing else, in any order", function()
    local graph, nodes = toy_graph()
    local first_pebbles
    for seed = 1, 60 do
        local sort_info = complex_home_sort(graph, seed)
        local inds = sort_info.node_to_context_inds
        local rock_isolated = top.context_key(ROCK, "10")
        local moss_isolated = top.context_key(MOSS, "10")
        -- The discoverer, and home techs however late the sort reaches them
        assert(inds[nodes["find-rock"]][rock_isolated] ~= nil)
        assert(inds[nodes["t-late6"]][rock_isolated] ~= nil and inds[nodes["t-late6"]][moss_isolated] ~= nil)
        -- So a recipe on the rock planet that needs a late home tech stays isolatable there
        assert(inds[nodes["rock-plate"]][rock_isolated] ~= nil)
        -- A tech that needs the rock planet is isolatable there, but never on the moss planet
        assert(inds[nodes["t-cross"]][rock_isolated] ~= nil)
        assert(inds[nodes["t-cross"]][moss_isolated] == nil and inds[nodes["t-cross"]][top.context_key(MOSS, "11")] == nil)
        -- The far planet's home set has the near planets, so their techs count there
        assert(inds[nodes["t-cross"]][top.context_key(FROST, "10")] ~= nil)
        local pebbles = pebble_set(sort_info)
        first_pebbles = first_pebbles or pebbles
        assert(pebbles == first_pebbles, "sort " .. tostring(seed) .. " has different pebbles")
    end
end)

test("without home contexts, a sort has no home contexts and keeps the old discovery rule", function()
    local graph, nodes = toy_graph()
    local num_leaks = 0
    local num_misses = 0
    for seed = 1, 60 do
        rng_state = seed
        local sort_info = top.sort(graph, nil, nil, {
            choose_randomly = true,
            complex_contexts = true,
        })
        assert(sort_info.home_sets == nil)
        for _, context in pairs(sort_info.contexts) do
            assert(top.context_home(context) == nil)
        end
        local inds = sort_info.node_to_context_inds
        assert(inds[nodes["find-rock"]][top.context_key(ROCK, "10")] ~= nil)
        if inds[nodes["t-cross"]][top.context_key(MOSS, "10")] ~= nil then
            num_leaks = num_leaks + 1
        end
        if inds[nodes["t-late6"]][top.context_key(ROCK, "10")] == nil then
            num_misses = num_misses + 1
        end
    end
    -- Not checked, since they depend on the order: how often the old rule was too generous or too strict here
    print("    (old rule, of 60 orders: rock-only tech isolatable on the moss planet in " .. tostring(num_leaks) .. ", late home tech not isolatable on the rock planet in " .. tostring(num_misses) .. ")")
end)

test("a cached sort with a new edge gets the same pebbles as a fresh sort", function()
    local graph, nodes = toy_graph()
    -- The last home tech also needs an OR node with no prerequisites, so it can't be reached until the new edge feeds that node
    gutils.add_node(graph, "stuff", "blocker", {
        op = "OR",
    })
    local blocker = key("stuff", "blocker")
    add_edge(graph, blocker, nodes["t-late6"])
    local state = complex_home_sort(graph, 3)
    assert(next(state.node_to_context_inds[nodes["t-late6"]]) == nil)
    add_edge(graph, nodes["ore"], blocker)
    local cached = top.sort(graph, state, {
        graph.nodes[nodes["ore"]],
        graph.nodes[blocker],
    }, {
        choose_randomly = true,
    })
    assert(cached.node_to_context_inds[nodes["t-late6"]][top.context_key(ROCK, "10")] ~= nil)
    assert(pebble_set(cached) == pebble_set(complex_home_sort(graph, 3)))
end)

test("the path to a granted pebble goes through the tech's own home pebble and a discoverer", function()
    local graph, nodes = toy_graph()
    local home_way = gutils.ekey({
        start = nodes["make-alt"],
        stop = nodes["alt"],
    })
    for seed = 1, 10 do
        -- The alt item's slow way from home is only added once the sort is done, so the tech's home contexts come after its others
        local partial = table.deepcopy(graph)
        gutils.remove_edge(partial, home_way)
        local state = complex_home_sort(partial, seed)
        add_edge(partial, nodes["make-alt"], nodes["alt"])
        local sort_info = top.sort(partial, state, {
            partial.nodes[nodes["make-alt"]],
            partial.nodes[nodes["alt"]],
        }, {
            choose_randomly = true,
        })
        -- The alt item never reaches the moss planet, so the tech's isolatability there only comes from the discovery rule
        local goal = sort_info.node_to_context_inds[nodes["t-alt"]][top.context_key(MOSS, "10")]
        assert(goal ~= nil)
        local path_info = top.path(partial, { goal }, sort_info)
        local has_discoverer = false
        local has_own_home = false
        -- The rock way already gives the tech the far planet's home context (its home set has the rock planet), which doesn't count for the moss planet
        local moss_home_id = sort_info.home_sets.of[MOSS]
        for _, ind in pairs(path_info.path) do
            local pebble = sort_info.sorted[ind]
            if pebble.node_key == nodes["find-moss"] then
                has_discoverer = true
            end
            if pebble.node_key == nodes["t-alt"] and top.context_home(pebble.context) == moss_home_id then
                has_own_home = true
            end
        end
        assert(has_discoverer and has_own_home, "sort " .. tostring(seed))
    end
    -- The path to a recipe that needs a granted tech works too
    local sort_info = complex_home_sort(graph, 5)
    top.path(graph, { sort_info.node_to_context_inds[nodes["rock-plate"]][top.context_key(ROCK, "10")] }, sort_info)
end)

test("discovery candidates are the tech's pebbles in the room's home set and the room's discoverers' pebbles", function()
    local graph, nodes = toy_graph()
    local sort_info = complex_home_sort(graph, 4)
    local room_discoverers = top.room_discoverers(graph)
    local late_tech = graph.nodes[nodes["t-late6"]]
    local rock_isolated = top.context_key(ROCK, "10")
    local candidates = top.discovery_candidates(sort_info, room_discoverers, late_tech, rock_isolated)
    assert(candidates ~= nil and #candidates.own > 0 and #candidates.discoverers > 0)
    local home_id = sort_info.home_sets.of[ROCK]
    for i, ind in pairs(candidates.own) do
        local pebble = sort_info.sorted[ind]
        assert(pebble.node_key == nodes["t-late6"] and top.context_home(pebble.context) == home_id)
        assert(i == 1 or candidates.own[i - 1] < ind)
    end
    for _, ind in pairs(candidates.discoverers) do
        assert(sort_info.sorted[ind].node_key == nodes["find-rock"])
    end
    -- The rule only gives techs their isolatable contexts
    assert(top.discovery_candidates(sort_info, room_discoverers, graph.nodes[nodes["rock-plate"]], rock_isolated) == nil)
    assert(top.discovery_candidates(sort_info, room_discoverers, late_tech, top.context_key(ROCK, "01")) == nil)
    assert(top.discovery_candidates(sort_info, room_discoverers, late_tech, home_context(ROCK, home_id, true)) == nil)
    -- Without home contexts, any of the tech's pebbles counts (the old rule)
    rng_state = 4
    local old_sort = top.sort(graph, nil, nil, {
        choose_randomly = true,
        complex_contexts = true,
    })
    local old_candidates = top.discovery_candidates(old_sort, room_discoverers, late_tech, rock_isolated)
    local num_pebbles = 0
    for _, _ in pairs(old_sort.node_to_context_inds[nodes["t-late6"]]) do
        num_pebbles = num_pebbles + 1
    end
    assert(#old_candidates.own == num_pebbles)
end)

test("a discoverer reached in several contexts only needs what they need in common", function()
    local dock_a = "surface: dock-a"
    local dock_b = "surface: dock-b"
    set_rooms({ HOME, dock_a, dock_b })
    local graph = new_graph()
    gutils.add_node(graph, "start", "", {
        op = "AND",
    })
    local start = key("start", "")
    local home = key("room", HOME)
    gutils.add_node(graph, "room", HOME, {
        op = "OR",
    })
    add_edge(graph, start, home)
    local surface = key("stuff", "any-surface")
    gutils.add_node(graph, "stuff", "any-surface", {
        op = "OR",
    })
    -- Either dock is made at home, and a spaceship can be built on either one
    for _, dock in pairs({ dock_a, dock_b }) do
        gutils.add_node(graph, "make", dock, {
            op = "AND",
        })
        add_edge(graph, home, key("make", dock))
        gutils.add_node(graph, "room", dock, {
            op = "OR",
        })
        add_edge(graph, key("make", dock), key("room", dock))
        add_edge(graph, key("room", dock), surface)
    end
    gutils.add_node(graph, "spaceship", "", {
        op = "AND",
    })
    add_edge(graph, surface, key("spaceship", ""))
    local home_sets = top.home_sets(graph)
    local home_id = home_sets.of[dock_a]
    assert(home_id ~= nil and home_sets.of[dock_b] == home_id)
    local rooms = home_sets.sets[home_id].rooms
    assert(rooms[HOME] ~= nil and rooms[dock_a] == nil and rooms[dock_b] == nil)
end)

test("a room with several discoverers only needs what they all need", function()
    local far = "planet: far"
    local via_a = "planet: via-a"
    local via_b = "planet: via-b"
    set_rooms({ HOME, far, via_a, via_b })
    data.raw["planet"] = {
        far = {
            type = "planet",
            name = "far",
        },
    }
    data.raw["technology"] = {}
    local graph = new_graph()
    gutils.add_node(graph, "start", "", {
        op = "AND",
    })
    gutils.add_node(graph, "room", HOME, {
        op = "OR",
    })
    add_edge(graph, key("start", ""), key("room", HOME))
    -- Two techs discover the far planet, each needing a different planet reached from home
    for _, via in pairs({ via_a, via_b }) do
        gutils.add_node(graph, "room", via, {
            op = "OR",
        })
        add_edge(graph, key("room", HOME), key("room", via))
        local tech_name = "find-far-from-" .. gutils.deconstruct(via).name
        gutils.add_node(graph, "technology", tech_name, {
            op = "AND",
        })
        add_edge(graph, key("room", via), key("technology", tech_name))
        data.raw["technology"][tech_name] = {
            effects = {
                {
                    type = "unlock-space-location",
                    space_location = "far",
                },
            },
        }
    end
    local home_sets = top.home_sets(graph)
    local rooms = home_sets.sets[home_sets.of[far]].rooms
    assert(rooms[HOME] ~= nil and rooms[via_a] == nil and rooms[via_b] == nil)
end)

print(tostring(num_passed) .. " tests passed")

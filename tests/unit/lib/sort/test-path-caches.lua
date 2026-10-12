-- Plain-Lua regression tests for the caches top.path can keep between paths of one sort (src/lib/sort/context-sort.lua), not loaded by the mod
-- Run from the mod root: lua tests/unit/lib/sort/test-path-caches.lua
--
-- On random graphs with two rooms, every path from every pebble comes out the same with the caches as without them: with tie ranks at forgetters, and with a preference whose pebbles aren't cached

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
package.loaded["src/lib/random/rng"] = {
    int = function(_, max)
        return 1
    end,
}

local logic = {
    contexts = {
        home = true,
        away = true,
    },
    type_info = {
        start = {},
        -- Sends the context of the room named by the node
        room = { context = "room" },
        stuff = {},
        recipe = {},
        -- Forgets its context, like a technology
        research = { context = true },
    },
}
package.loaded["src/logic/init"] = logic
package.loaded["src/logic/state"] = package.loaded["src/logic/init"]
data = {
    raw = {
        technology = {},
    },
}
package.loaded["src/prototypes/data-utils"] = {
    get_prot = function(_, name)
        return nil
    end,
}

local gutils = require("src/lib/graph/graph-utils")
local top = require("src/lib/sort/context-sort")
local fx = require("tests/unit/logic/contexts/contexts-for-tests")
local key = gutils.key
-- Numbers the rooms, as a game's contexts are
fx.C("home")
fx.C("away")

local function random_graph()
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local has_edge = {}
    local function edge(start, stop)
        if start ~= stop and has_edge[start .. "/" .. stop] == nil then
            has_edge[start .. "/" .. stop] = true
            gutils.add_edge(graph, start, stop)
        end
    end
    gutils.add_node(graph, "start", "start", { op = "AND" })
    gutils.add_node(graph, "room", "home", { op = "OR" })
    gutils.add_node(graph, "room", "away", { op = "OR" })
    edge(key("start", "start"), key("room", "home"))
    local num_stuff = math.random(4, 14)
    local num_recipes = math.random(4, 18)
    local num_research = math.random(1, 4)
    for i = 1, num_stuff do
        gutils.add_node(graph, "stuff", "s" .. i, { op = "OR" })
    end
    for i = 1, num_recipes do
        gutils.add_node(graph, "recipe", "r" .. i, { op = "AND" })
    end
    for i = 1, num_research do
        gutils.add_node(graph, "research", "t" .. i, { op = "AND" })
    end
    -- Mining in either room, and travel to the other room needing some stuff
    for i = 1, num_stuff do
        if i == 1 or math.random() < 0.25 then
            edge(key("room", "home"), key("stuff", "s" .. i))
        end
        if math.random() < 0.25 then
            edge(key("room", "away"), key("stuff", "s" .. i))
        end
    end
    edge(key("stuff", "s" .. math.random(1, num_stuff)), key("room", "away"))
    -- Recipes take one to three things, maybe a research, and make one or two things; loops are allowed
    for i = 1, num_recipes do
        for _ = 1, math.random(1, 3) do
            edge(key("stuff", "s" .. math.random(1, num_stuff)), key("recipe", "r" .. i))
        end
        if math.random() < 0.3 then
            edge(key("research", "t" .. math.random(1, num_research)), key("recipe", "r" .. i))
        end
        for _ = 1, math.random(1, 2) do
            edge(key("recipe", "r" .. i), key("stuff", "s" .. math.random(1, num_stuff)))
        end
    end
    for i = 1, num_research do
        for _ = 1, math.random(1, 2) do
            edge(key("stuff", "s" .. math.random(1, num_stuff)), key("research", "t" .. i))
        end
    end
    return graph
end

local function same_list(a, b)
    if #a ~= #b then
        return false
    end
    for i = 1, #a do
        if a[i] ~= b[i] then
            return false
        end
    end
    return true
end
local function same_set(a, b)
    for k, v in pairs(a or {}) do
        if (b or {})[k] ~= v then
            return false
        end
    end
    for k, v in pairs(b or {}) do
        if (a or {})[k] ~= v then
            return false
        end
    end
    return true
end
local function same_path(a, b)
    if not (same_list(a.path, b.path) and same_set(a.in_path, b.in_path) and same_set(a.preferred, b.preferred) and a.num_tie_moves == b.num_tie_moves) then
        return false
    end
    if (a.chosen == nil) ~= (b.chosen == nil) then
        return false
    end
    for ind, list in pairs(a.chosen or {}) do
        if b.chosen[ind] == nil or not same_list(list, b.chosen[ind]) then
            return false
        end
    end
    for ind, _ in pairs(b.chosen or {}) do
        if a.chosen[ind] == nil then
            return false
        end
    end
    return true
end

local num_paths = 0
local num_preferred = 0
local num_tie_moves = 0
math.randomseed(7)
for _ = 1, 600 do
    local graph = random_graph()
    local sort_info = top.sort(graph)
    local pebble_keys = sort_info.pebble_keys
    local pebble_contexts = sort_info.pebble_contexts
    -- Stop at odd recipes, like recipes that get a tech
    local function stop_if(node_key)
        local node = graph.nodes[node_key]
        return node.type == "recipe" and tonumber(string.sub(node.name, 2)) % 2 == 1
    end
    -- Away first, so ranking ties moves choices off the order the sort listed them in
    local function tie_rank(context)
        if top.context_room(context) == "away" then
            return 1
        end
        return 2
    end
    local expansions = {}
    local preferring_expansions = {}
    local options = {}
    for ind = 1, #pebble_keys do
        local plain = top.path(graph, { ind }, sort_info, {
            stop_if = stop_if,
            tie_rank = tie_rank,
        })
        local cached = top.path(graph, { ind }, sort_info, {
            stop_if = stop_if,
            tie_rank = tie_rank,
            expansions = expansions,
            options = options,
        })
        assert(same_path(plain, cached), "a cached path differs")
        num_tie_moves = num_tie_moves + plain.num_tie_moves
        -- A preference in the root's room only, which can pick later pebbles: those pebbles aren't cached
        local room = top.context_room(pebble_contexts[ind])
        local function prefer(pre_ind, curr_ind)
            return top.context_room(pebble_contexts[curr_ind]) == room and (pre_ind * 7 + curr_ind) % 3 == 0
        end
        local function cacheable(curr_ind)
            local node = graph.nodes[pebble_keys[curr_ind]]
            return node.op ~= "OR" or logic.type_info[node.type].context ~= nil or top.context_room(pebble_contexts[curr_ind]) ~= room
        end
        local prefer_before = math.min(#pebble_keys + 1, ind + 3)
        local plain_preferring = top.path(graph, { ind }, sort_info, {
            stop_if = stop_if,
            tie_rank = tie_rank,
            prefer = prefer,
            prefer_before = prefer_before,
        })
        local cached_preferring = top.path(graph, { ind }, sort_info, {
            stop_if = stop_if,
            tie_rank = tie_rank,
            prefer = prefer,
            prefer_before = prefer_before,
            expansions = preferring_expansions,
            options = options,
            cacheable = cacheable,
        })
        assert(same_path(plain_preferring, cached_preferring), "a cached path with a preference differs")
        if next(plain_preferring.preferred) ~= nil then
            num_preferred = num_preferred + 1
        end
        num_paths = num_paths + 2
    end
end
-- The random graphs have to exercise what the caches skip; how many tie moves there are depends on stock Lua's table order, which changes from run to run
assert(num_preferred > 100, "too few preferred choices: " .. num_preferred)
assert(num_tie_moves > 10, "too few tie moves: " .. num_tie_moves)
print("Path cache tests passed (" .. num_paths .. " paths, " .. num_preferred .. " with preferred choices, " .. num_tie_moves .. " tie moves)")

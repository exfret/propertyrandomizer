-- Plain-Lua regression tests for where research triggers' technologies are needed (not loaded by the mod)
-- Run from the mod root: lua randomizations/graph/unified/handlers/test-tech-triggers.lua
-- A new trigger keeps its technology isolatable wherever the technology is needed (user, 2026-10-08), not wherever its old trigger could be met
--
-- The toy game has rooms A and B, and a gem is mined in both
-- Technology t is researched by its trigger, crafting a gem, so it's isolatable in both rooms
-- Recipe r, unlocked by t, makes item p, and with its surface condition it can only be made in B

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
config = {}
data = {
    raw = {
        lab = {},
        -- The sort reads what technologies discover (context-sort.lua's discovery rule); t discovers nothing
        technology = {
            t = {
                type = "technology",
                name = "t",
                effects = {},
            },
        },
    },
}
package.loaded["helper-tables/constants"] = {
    starting_planet = "A",
    keep_isolatability = false,
}
package.loaded["lib/random/rng"] = {
    int = function(_, max)
        return 1
    end,
}
package.loaded["lib/logic/init"] = {
    contexts = {
        A = true,
        B = true,
    },
    type_info = {
        start = {},
        -- Emitter: sends the context named by the node
        room = { context = "room" },
        mine = {},
        item = {},
        recipe = {},
        ["recipe-surface-condition"] = {},
        -- Forgetter: a technology is had everywhere once researched, but isolatably only where it was researched from that room's own resources
        technology = { context = true },
        base = {},
        head = {},
    },
}
package.loaded["lib/logic/state"] = package.loaded["lib/logic/init"]
package.loaded["lib/cost/context-costs"] = {}

local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")
local tech_triggers = require("randomizations/graph/unified/handlers/tech-triggers")

local key = gutils.key

local function build_graph(is_locked_to_b)
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local function node(node_type, name, op, extra)
        extra = extra or {}
        extra.op = op
        gutils.add_node(graph, node_type, name, extra)
        return key(node_type, name)
    end
    local start = node("start", "", "AND")
    graph.sources[start] = true
    local rooms = {
        A = node("room", "A", "OR"),
        B = node("room", "B", "OR"),
    }
    gutils.add_edge(graph, start, rooms.A)
    gutils.add_edge(graph, start, rooms.B)
    local gem = node("item", "gem", "OR")
    for name, room in pairs(rooms) do
        local mine = node("mine", "gem-" .. name, "AND")
        gutils.add_edge(graph, room, mine)
        gutils.add_edge(graph, mine, gem)
    end
    -- t's trigger slot: crafting a gem, through a subdivided edge as in first pass's graph
    local base = node("base", "gem-t", "AND")
    local head = node("head", "gem-t", "OR", { old_base = base })
    gutils.add_edge(graph, gem, base)
    gutils.add_edge(graph, base, head)
    local tech = node("technology", "t", "AND")
    gutils.add_edge(graph, head, tech)
    local condition = node("recipe-surface-condition", "r", "OR")
    gutils.add_edge(graph, rooms.B, condition)
    if not is_locked_to_b then
        gutils.add_edge(graph, rooms.A, condition)
    end
    local recipe = node("recipe", "r", "AND")
    gutils.add_edge(graph, tech, recipe)
    gutils.add_edge(graph, condition, recipe)
    gutils.add_edge(graph, recipe, node("item", "p", "OR"))
    return graph
end

-- Rooms (as names) of a node's contexts with isolatability, among the given contexts
local function isolatable_rooms(contexts)
    local rooms = {}
    for context, _ in pairs(contexts or {}) do
        local abilities = top.context_abilities(context)
        if top.context_home(context) == nil and abilities ~= nil and string.sub(abilities, top.ISOLATABILITY, top.ISOLATABILITY) == "1" then
            rooms[top.context_room(context)] = true
        end
    end
    return rooms
end

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local tech = key("technology", "t")
local head = key("head", "gem-t")
local recipe = key("recipe", "r")

test("the technology's old trigger makes it isolatable in both rooms", function()
    local graph = build_graph(true)
    local sort_info = top.sort(graph, nil, nil, { complex_contexts = true })
    local rooms = isolatable_rooms(sort_info.node_to_context_inds[tech])
    assert(rooms.A and rooms.B, "t should be isolatable in A and B")
end)

test("a technology whose recipe is locked to one room is needed isolatably there, not everywhere its trigger was", function()
    local graph = build_graph(true)
    local sort_info = top.sort(graph, nil, nil, { complex_contexts = true })
    -- r is locked to B, so every context it has there is kept (protection.planet_locked_recipe_contexts)
    local planet_locked = {
        [recipe] = {},
    }
    for context, _ in pairs(sort_info.node_to_context_inds[recipe]) do
        planet_locked[recipe][context] = true
    end
    local needed = tech_triggers.needed_contexts(graph, sort_info, planet_locked, {
        [tech] = true,
    })
    local tech_rooms = isolatable_rooms(needed[tech])
    assert(tech_rooms.B, "t should be needed isolatably in B, where r is")
    assert(not tech_rooms.A, "t shouldn't be needed isolatably in A, where nothing kept rests on it")
    local head_rooms = isolatable_rooms(needed[head])
    assert(head_rooms.B and not head_rooms.A, "t's trigger slot should be needed isolatably in B only")
end)

test("a technology nothing kept rests on isolatably is needed only to stay researchable", function()
    local graph = build_graph(false)
    local sort_info = top.sort(graph, nil, nil, { complex_contexts = true })
    local needed = tech_triggers.needed_contexts(graph, sort_info, {}, {
        [tech] = true,
    })
    assert(next(needed[tech] or {}) ~= nil, "t should still be needed somewhere, so it stays researchable")
    assert(next(isolatable_rooms(needed[tech])) == nil, "t shouldn't be needed isolatably anywhere")
end)

print(num_passed .. " tests passed")

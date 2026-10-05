-- Run from the mod root: lua randomizations/planetary/test-resource-repairs.lua
-- Real staged sorts, with a small world whose recipe requirements change when edits are undone.

function table.deepcopy(value)
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for k, v in pairs(value) do
        copy[k] = table.deepcopy(v)
    end
    return copy
end
function log(message) end
data = { raw = {} }
data.raw.technology = {}
serpent = {
    block = tostring,
    line = tostring,
}
package.loaded["lib/random/rng"] = {
    int = function(_, maximum) return 1 end,
}
package.loaded["lib/data-utils"] = {
    get_prot = function() end,
}
local logic = {
    contexts = {},
    type_info = {},
}
logic.type_info.room = { context = "room" }
logic.type_info.head = {}
logic.type_info.base = {}
package.loaded["lib/logic/init"] = logic
package.loaded["lib/logic/state"] = logic
local active = {}
local check = {
    num_sorts = 0,
    home_sets = {
        ids = {},
        sets = {},
        of = {},
    },
}
package.loaded["randomizations/planetary/check"] = check
package.loaded["randomizations/planetary/resources"] = {
    add_repair = function(repair) active[repair.resource_name] = true end,
    remove_repair = function(repair) active[repair.resource_name] = nil end,
}

local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")
local repairs = require("randomizations/planetary/resource-repairs")

local room_key = gutils.key("planet", "test-planet")
local goal_key = gutils.key("recipe", "test-goal")
logic.contexts[room_key] = true
local needed = {}
local ordinary = {}
local candidates = {}
for i = 1, 37 do
    local repair = {
        planet_name = "test-planet",
        resource_name = "test-resource-" .. i,
    }
    candidates[i] = repair
    needed[repair.resource_name] = true
end

logic.build = function()
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local function add(class, name, op)
        logic.type_info[class] = logic.type_info[class] or {}
        return gutils.add_node(graph, class, name, { op = op })
    end
    local room = add("room", room_key, "AND")
    local autoplace = add("room-autoplace", room_key, "AND")
    gutils.add_edge(graph, room, autoplace)
    local goal = add("recipe", "test-goal", "AND")
    for _, repair in pairs(candidates) do
        local entity = add("entity", repair.resource_name, "OR")
        if active[repair.resource_name] ~= nil or ordinary[repair.resource_name] ~= nil then
            gutils.add_edge(graph, autoplace, entity)
        end
        if needed[repair.resource_name] ~= nil then
            gutils.add_edge(graph, entity, goal)
        end
    end
    logic.graph = graph
end
check.sort = function()
    logic.build()
    return {
        graph = logic.graph,
        sort_info = top.sort(logic.graph, nil, nil, {
            complex_contexts = true,
            home_contexts = true,
            home_sets = check.home_sets,
        }),
    }
end
check.required_failures = function(_, after)
    if next(after.sort_info.node_to_context_inds[goal_key] or {}) == nil then
        return { { keys = { goal_key } } }
    end
    return {}
end
check.goal_inds = function(failures, after)
    local inds = {}
    for _, failure in pairs(failures) do
        for _, key in pairs(failure.keys) do
            for _, ind in pairs(after.sort_info.node_to_context_inds[key] or {}) do
                table.insert(inds, ind)
            end
        end
    end
    return inds
end

local state = {
    before = {},
    variants_of = {},
}
local kept = repairs.select(logic, state, candidates, check.sort())
assert(#kept == 37)
assert(#check.required_failures(state.before, check.sort()) == 0)

-- The edited goal used all 37 resources. The restored recipe only needs the first.
needed = { [candidates[1].resource_name] = true }
active = {}
kept = repairs.select(logic, state, candidates, check.sort())
assert(#kept == 1 and kept[1] == candidates[1])
assert(#check.required_failures(state.before, check.sort()) == 0)
assert(active[candidates[37].resource_name] == nil)
print("ok - restoring recipes reselects the needed repair instead of keeping all 37 candidates")

-- A resource supplied by an ordinary placement needs no repair even if it was a candidate earlier.
ordinary[candidates[1].resource_name] = true
active = {}
kept = repairs.select(logic, state, candidates, check.sort())
assert(#kept == 0 and next(active) == nil)
assert(#check.required_failures(state.before, check.sort()) == 0)
print("ok - existing placements satisfy the final goal without creating extra patches")

-- Run from the mod root: lua lib/test-technology-prerequisites.lua
local prerequisites = require("lib/technology-prerequisites")

local function reachable(graph, start)
    local seen = {}
    local pending = { start }
    while #pending > 0 do
        local name = table.remove(pending)
        if not seen[name] then
            seen[name] = true
            for _, parent in pairs(graph[name].prerequisites or {}) do
                pending[#pending + 1] = parent
            end
        end
    end
    return seen
end

local graph = {
    a = {},
    b = { prerequisites = { "a" } },
    c = {
        prerequisites = {
            "a",
            "b",
        },
    },
    d = { prerequisites = { "a" } },
    e = {
        prerequisites = {
            "a",
            "b",
            "c",
            "d",
            "d",
        },
    },
}
local before = {}
for name, _ in pairs(graph) do
    before[name] = reachable(graph, name)
end
prerequisites.reduce(graph)
assert(graph.a.prerequisites == nil)
assert(table.concat(graph.c.prerequisites, ",") == "b")
assert(table.concat(graph.e.prerequisites, ",") == "c,d")
for name, _ in pairs(graph) do
    local after = reachable(graph, name)
    for other, _ in pairs(graph) do
        assert(before[name][other] == after[other], "reachability changed")
    end
end
prerequisites.reduce(graph)
assert(table.concat(graph.e.prerequisites, ",") == "c,d")

-- Cyclic input must terminate and must not remove both alternative paths.
local cyclic = {
    a = {
        prerequisites = {
            "b",
            "c",
        },
    },
    b = { prerequisites = { "c" } },
    c = { prerequisites = { "b" } },
}
prerequisites.reduce(cyclic)
assert(#cyclic.a.prerequisites == 1)
assert(reachable(cyclic, "a").b and reachable(cyclic, "a").c)
print("Technology prerequisite reduction tests passed")

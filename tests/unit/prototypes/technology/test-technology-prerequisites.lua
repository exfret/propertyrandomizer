-- Run from the mod root: lua tests/unit/prototypes/technology/test-technology-prerequisites.lua
local prerequisites = require("src/prototypes/technology/technology-prerequisites")

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

-- Reduce searches once per tech, where reduce_each searches once per prerequisite; on random trees with repeated prerequisites and ones naming no tech, both leave the same lists in the same order
-- With a cycle, reduce uses reduce_each, whose answer then depends on the order (both copies are built the same way, so they iterate alike)
local function random_specs(num, with_cycles)
    local specs = {}
    for i = 1, num do
        local list = {}
        for _ = 1, math.random(0, 5) do
            local roll = math.random()
            if roll < 0.05 then
                table.insert(list, "missing-" .. math.random(1, 3))
            elseif with_cycles == true then
                table.insert(list, "t" .. math.random(1, num))
            elseif i > 1 then
                table.insert(list, "t" .. math.random(1, i - 1))
            end
        end
        specs[i] = list
    end
    return specs
end
local function build(specs)
    local technologies = {}
    for i, list in pairs(specs) do
        local copy = {}
        for j, prereq in pairs(list) do
            copy[j] = prereq
        end
        technologies["t" .. i] = { prerequisites = copy }
    end
    return technologies
end
math.randomseed(11)
local num_removed = 0
for round = 1, 400 do
    local specs = random_specs(math.random(2, 40), round % 4 == 0)
    local fast = build(specs)
    local each = build(specs)
    prerequisites.reduce(fast)
    prerequisites.reduce_each(each)
    for name, tech in pairs(each) do
        assert(table.concat(fast[name].prerequisites, ",") == table.concat(tech.prerequisites, ","), "reduce and reduce_each differ on " .. name)
        num_removed = num_removed + #specs[tonumber(string.sub(name, 2))] - #tech.prerequisites
    end
end
assert(num_removed > 1000, "too few prerequisites left out: " .. num_removed)
print("Technology prerequisite reduction tests passed")

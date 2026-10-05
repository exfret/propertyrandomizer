-- Run from the mod root: lua lib/graph/test-weighted-matching.lua
local matching = require("lib/graph/weighted-matching")

local function optimum(costs, n)
    local used = {}
    local function visit(row, total)
        if row > n then
            return total
        end
        local best
        for column, cost in pairs(costs[row]) do
            if used[column] == nil then
                used[column] = true
                local candidate = visit(row + 1, total + cost)
                used[column] = nil
                if candidate ~= nil and (best == nil or candidate < best) then
                    best = candidate
                end
            end
        end
        return best
    end
    return visit(1, 0)
end

local state = 31
local function random(n)
    state = state * 48271 % 2147483647
    return state % n
end

-- Compare to exhaustive enumeration, including impossible matchings, missing edges, negative costs, ties, and paths that displace earlier assignments.
for n = 1, 6 do
    for trial = 1, 100 do
        local costs = {}
        for row = 1, n do
            costs[row] = {}
            for column = 1, n do
                if random(4) ~= 0 then
                    costs[row][column] = random(21) - 10
                end
            end
        end
        local expected = optimum(costs, n)
        local result = matching.solve(costs, n)
        if expected == nil then
            assert(result == nil)
        else
            assert(result ~= nil)
            local used = {}
            local total = 0
            for column = 1, n do
                local row = assert(result[column])
                assert(used[row] == nil)
                used[row] = true
                total = total + assert(costs[row][column])
            end
            assert(total == expected, "matching did not achieve the exhaustive optimum")
        end
    end
end
print("ok - 600 weighted matchings agree with exhaustive enumeration")

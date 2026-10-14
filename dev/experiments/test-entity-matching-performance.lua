-- Standalone Lua instruction benchmark; run from the checkout/snapshot to measure.
-- lua dev/experiments/test-entity-matching-performance.lua
-- Counts exclude setup and use 1,000-instruction sampling (not the Factorio VM).
local search = require("src/lib/graph/augmenting-search")

print("runtime,scenario,heads,instruction_estimate,path_checks,allowed_checks,seconds")
for _, scenario in pairs({"accept-first", "reject-all", "no-closing-edge"}) do
    for n = 4, 10 do
        local heads, candidates = {}, {}
        for i = 1, n do heads[i] = i end
        for i = 2, n do table.insert(candidates, i) end
        table.insert(candidates, 1)
        local paths, edges, instructions = 0, 0, 0
        local state = search.new({
            heads = heads,
            detached = "detached",
            initial = function(head) return head end,
            candidates = function() return candidates end,
            allowed = function(head, base)
                edges = edges + 1
                return scenario ~= "no-closing-edge" or base ~= 1
            end,
            can_detach = function() return false end,
            commit = function()
                paths = paths + 1
                return scenario == "accept-first"
            end,
        })
        local start = os.clock()
        debug.sethook(function() instructions = instructions + 1000 end, "", 1000)
        state.try(1)
        debug.sethook()
        for head = 1, n do
            local expected = scenario == "accept-first" and (head % n + 1) or head
            assert(state.assigned[head] == expected, "unexpected final assignment")
        end
        print(string.format("%s,%s,%d,%d,%d,%d,%.6f", _VERSION, scenario, n, instructions, paths, edges, os.clock() - start))
    end
end

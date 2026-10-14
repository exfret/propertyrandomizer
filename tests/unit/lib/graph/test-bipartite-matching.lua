local matching = require("src/lib/graph/bipartite-matching")
local refinement = require("src/lib/graph/matching-refinement")

-- The pre-extraction Kuhn implementation, with deterministic candidate ordering.
local function original(order, candidates, fixed)
    local occupants, fixed_heads = {}, {}
    for slot, head in pairs(fixed) do
        occupants[slot], fixed_heads[head] = head, true
    end
    local visit
    visit = function(head, visited)
        for _, slot in pairs(candidates(head)) do
            if not visited[slot] and fixed[slot] == nil then
                visited[slot] = true
                if occupants[slot] == nil or visit(occupants[slot], visited) then
                    occupants[slot] = head
                    return true
                end
            end
        end
        return false
    end
    for _, head in pairs(order) do
        if not fixed_heads[head] and not visit(head, {}) then return nil end
    end
    return occupants
end

-- Independent enumeration oracle: try all injective head->slot assignments.
local function possible(order, pools, fixed)
    local taken, fixed_heads = {}, {}
    for slot, head in pairs(fixed) do taken[slot], fixed_heads[head] = true, true end
    local visit
    visit = function(i)
        local head = order[i]
        if head == nil then return true end
        if fixed_heads[head] then return visit(i + 1) end
        for _, slot in pairs(pools[head]) do
            if not taken[slot] then
                taken[slot] = true
                if visit(i + 1) then return true end
                taken[slot] = nil
            end
        end
        return false
    end
    return visit(1)
end

local cases = 0
for mask = 0, 4095 do
    local order, pools = {1, 2, 3}, {{}, {}, {}}
    for head = 1, 3 do
        for slot = 1, 4 do
            if math.floor(mask / 2 ^ ((head - 1) * 4 + slot - 1)) % 2 == 1 then
                table.insert(pools[head], slot)
            end
        end
    end
    for fixed_slot = 0, 4 do
        local fixed = {}
        if fixed_slot > 0 then fixed[fixed_slot] = 1 end
        local old_calls, new_calls = {}, {}
        local before = original(order, function(head)
            table.insert(old_calls, head)
            return pools[head]
        end, fixed)
        local after = matching.complete({
            order = order,
            fixed = fixed,
            candidates = function(head)
                table.insert(new_calls, head)
                return pools[head]
            end,
        })
        assert((after ~= nil) == possible(order, pools, fixed), "oracle disagreement")
        assert((before ~= nil) == (after ~= nil), "extraction changed success")
        assert(table.concat(old_calls, ",") == table.concat(new_calls, ","), "candidate/RNG call order changed")
        if after ~= nil then
            for slot = 1, 4 do assert(after[slot] == before[slot], "extraction changed assignment") end
        end
        cases = cases + 1
    end
end

-- Rejection/fallback and retry boundaries are shared by both users.
local current, current_result = {}, {}
for _, limit in pairs({1, 3, 10}) do
    local checks, additions = 0, 0
    local chosen, result, stats = refinement.run({
        current = current,
        current_result = current_result,
        max_refinements = limit,
        propose = function() return {} end,
        validate = function()
            checks = checks + 1
            return false, "witness"
        end,
        refine = function(_, failure)
            assert(failure == "witness")
            additions = additions + 1
            return 1
        end,
    })
    assert(chosen == current and result == current_result and not stats.accepted)
    assert(checks == limit and additions == limit and stats.refinements == limit)
end
local checks = 0
local candidate = {}
local chosen, result, stats = refinement.run({
    current = current,
    max_refinements = 10,
    propose = function() return candidate end,
    validate = function()
        checks = checks + 1
        return checks == 2, "witness"
    end,
    refine = function() return 1 end,
})
assert(chosen == candidate and result == "witness" and stats.accepted and stats.refinements == 1)
local fallback, _, failed = refinement.run({
    current = current,
    max_refinements = 10,
    propose = function() return nil end,
    validate = function() error("No candidate") end,
    refine = function() error("No witness") end,
})
assert(fallback == current and not failed.accepted and failed.trials == 0)
print(cases .. " exhaustive matching cases agree with the oracle and original search; refinement boundaries passed")

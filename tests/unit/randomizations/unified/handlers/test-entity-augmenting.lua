local search = require("src/lib/graph/augmenting-search")

local heads = {"a", "b", "c", "d"}
local function fixture(candidates, commit, can_detach, extra)
    extra = extra or {}
    return search.new({
        heads = heads,
        detached = "detached",
        initial = function(head) return head end,
        candidates = function(head) return candidates[head] or {} end,
        allowed = extra.allowed or function() return true end,
        refine = extra.refine,
        can_end = extra.can_end,
        can_detach = can_detach or function() return false end,
        commit = commit or function() return true end,
    })
end
local function unique(state)
    local seen = {}
    for _, head in pairs(heads) do
        local base = state.assigned[head]
        if base ~= "detached" then
            assert(seen[base] == nil, "duplicate physical base")
            seen[base] = true
        end
    end
end

local kept = fixture({a = {"a", "b"}, b = {"a"}}, function()
    error("Keeping the current assignment needs no rewire")
end)
assert(kept.try("a") and kept.assigned.a == "a" and kept.assigned.b == "b")

-- No reciprocal exchange is legal. Only a three-way reroute can move A.
local cycle = fixture({
    a = {"b"},
    b = {"c"},
    c = {"a"},
})
assert(cycle.try("a"))
assert(cycle.assigned.a == "b" and cycle.assigned.b == "c" and cycle.assigned.c == "a")
unique(cycle)

-- An earlier assigned head can be displaced again by a later root.
local pools = {
    a = {"b", "c"},
    b = {"c", "a"},
    c = {"a", "d"},
    d = {"b"},
}
local reroute = fixture(pools)
assert(reroute.try("a"))
assert(reroute.try("d"))
assert(reroute.assigned.d == "b" and reroute.assigned.a == "c")
assert(reroute.assigned.b == "a" and reroute.assigned.c == "d")
unique(reroute)

-- A failed obligation refines stable edge eligibility before a fresh search.
local learned = false
local checked = 0
local retried
retried = fixture({
    a = {"b"},
    b = {"c"},
    c = {"a", "d"},
    d = {"a"},
}, function(path)
    checked = checked + 1
    for _, head in pairs(heads) do assert(retried.assigned[head] == head, "failed path leaked an assignment") end
    return #path == 4, {head = "c", base = "a"}
end, nil, {
    allowed = function(head, base) return not (learned and head == "c" and base == "a") end,
    refine = function(_, failure)
        assert(failure.head == "c" and failure.base == "a")
        learned = true
        return 1
    end,
})
assert(retried.try("a") and checked == 2)
assert(retried.assigned.c == "d" and retried.assigned.d == "a")
unique(retried)

local refusals = 0
local refused = fixture(pools, function()
    refusals = refusals + 1
    return false
end)
assert(not refused.try("a") and refusals == 1, "no new constraint must retain the valid assignment")
for _, head in pairs(heads) do assert(refused.assigned[head] == head) end

-- An augmenting path may terminate at an unused placement slot.
local open = fixture({
    a = {"b"},
    b = {"c"},
    c = {"free"},
})
assert(open.try("a") and open.assigned.c == "free")
unique(open)

local optional = fixture({a = {"b"}}, nil, function(head) return head == "b" end)
assert(optional.try("a") and optional.assigned.b == "detached")
unique(optional)
local required = fixture({a = {"b"}})
assert(not required.try("a") and required.assigned.b == "b")
-- A mining obligation can require the root's old position to remain filled.
local needs_mining = false
local protected = fixture({a = {"b"}, b = {"free", "a"}}, function(path)
    return path[#path].base == "a", "mining"
end, nil, {
    can_end = function() return not needs_mining end,
    refine = function(_, failure)
        assert(failure == "mining")
        needs_mining = true
        return 1
    end,
})
assert(protected.try("a") and protected.assigned.b == "a")
unique(protected)

-- A dense graph without a closing edge used to explore nearly a million paths.
local dense_heads, dense_candidates = {}, {}
for i = 1, 10 do dense_heads[i] = i end
for i = 2, 10 do table.insert(dense_candidates, i) end
local edges = 0
local dense = search.new({
    heads = dense_heads,
    detached = "detached",
    initial = function(head) return head end,
    candidates = function() return dense_candidates end,
    allowed = function()
        edges = edges + 1
        return true
    end,
    can_detach = function() return false end,
    commit = function() error("No augmenting path exists") end,
})
assert(not dense.try(1) and edges <= 100)
for i = 1, 10 do assert(dense.assigned[i] == i) end

print("Entity augmenting search passed: non-reciprocal cycles, rerouted earlier choices, refined retries, bounded rejection, atomic rollback, free slots and protected occupants")

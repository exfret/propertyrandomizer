-- Matching on opaque head/slot keys. Candidate order is the caller's policy.
-- A search visits each slot at most once; validation of a whole proposal belongs
-- outside this module, since a rejected proposal is not a missing graph edge.
local matching = {}

-- Find a path without changing occupants. The root's current slot is treated as
-- free. fixed slots cannot move; allowed is an optional, stable edge predicate;
-- can_end optionally restricts which free slots may terminate this search.
matching.find_path = function(params)
    local visited, path = {}, {}
    local fixed = params.fixed or {}
    local visit
    visit = function(head)
        for _, slot in pairs(params.candidates(head)) do
            if not visited[slot] and not fixed[slot]
                    and (params.allowed == nil or params.allowed(head, slot)) then
                visited[slot] = true
                local occupant = params.occupants[slot]
                if occupant == params.head then occupant = nil end
                if (occupant == nil and (params.can_end == nil or params.can_end(slot)))
                        or (occupant ~= nil and visit(occupant)) then
                    table.insert(path, {head = head, base = slot})
                    return true
                end
            end
        end
        return false
    end
    if not visit(params.head) then return nil end
    -- The recursion unwinds tail first; callers apply the proposal root first.
    for i = 1, math.floor(#path / 2) do
        path[i], path[#path + 1 - i] = path[#path + 1 - i], path[i]
    end
    return path
end

-- Cover every head, preserving prefilled slot->head pairs. Extra slots may stay
-- empty. Returns slot->head, or nil if no complete matching exists.
matching.complete = function(params)
    local occupants, fixed_heads = {}, {}
    for slot, head in pairs(params.fixed or {}) do
        assert(not fixed_heads[head], "A fixed head occupies multiple slots")
        occupants[slot], fixed_heads[head] = head, true
    end
    for _, head in pairs(params.order) do
        if not fixed_heads[head] then
            local path = matching.find_path({
                head = head,
                occupants = occupants,
                fixed = params.fixed,
                candidates = params.candidates,
                allowed = params.allowed,
            })
            if path == nil then return nil end
            for _, move in pairs(path) do occupants[move.base] = move.head end
        end
    end
    return occupants
end

return matching

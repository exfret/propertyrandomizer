local technology_prerequisites = {}

-- Whether a prerequisite of some tech leads back to that tech through prerequisites
local function has_cycle(technologies)
    -- Tech name --> 1 while its prerequisites are being searched, 2 once done
    local state = {}
    for name, _ in pairs(technologies) do
        if state[name] == nil then
            state[name] = 1
            -- The techs being searched, each with the position of its next prerequisite
            local names = { name }
            local positions = { 1 }
            while #names > 0 do
                local current = names[#names]
                local position = positions[#positions]
                local prereq = (technologies[current].prerequisites or {})[position]
                if prereq == nil then
                    state[current] = 2
                    names[#names] = nil
                    positions[#positions] = nil
                else
                    positions[#positions] = position + 1
                    if state[prereq] == 1 then
                        return true
                    elseif state[prereq] == nil and technologies[prereq] ~= nil then
                        state[prereq] = 1
                        table.insert(names, prereq)
                        table.insert(positions, 1)
                    end
                end
            end
        end
    end
    return false
end

-- Remove an edge only when another path still supplies the same prerequisite.
-- Checks each prerequisite with its own search, from the others left at that point, so on a cycle the order decides which stays
local function reduce_each(technologies)
    for name, tech in pairs(technologies) do
        local prereqs = tech.prerequisites
        for i = #(prereqs or {}), 1, -1 do
            local target = prereqs[i]
            local visited = { [name] = true }
            local pending = {}
            for j, prereq in pairs(prereqs) do
                if j ~= i then
                    pending[#pending + 1] = prereq
                end
            end
            local redundant = false
            while #pending > 0 do
                local current = table.remove(pending)
                if current == target then
                    redundant = true
                    break
                end
                if not visited[current] then
                    visited[current] = true
                    local parent = technologies[current]
                    for _, prereq in pairs(parent and parent.prerequisites or {}) do
                        pending[#pending + 1] = prereq
                    end
                end
            end
            if redundant then
                table.remove(prereqs, i)
            end
        end
    end
end

-- Remove an edge only when another path still supplies the same prerequisite.
-- Without cycles that's a prerequisite that another one needs through its prerequisites, or a later copy of an earlier one, as reduce_each finds, so one search per tech from its prerequisites' prerequisites does
-- Leaving those out doesn't change what any tech needs, so techs reduced earlier don't change the answer for later ones
function technology_prerequisites.reduce(technologies)
    if has_cycle(technologies) then
        reduce_each(technologies)
        return
    end
    for _, tech in pairs(technologies) do
        local prereqs = tech.prerequisites
        if prereqs ~= nil and #prereqs > 1 then
            -- What the prerequisites need through their own prerequisites
            local needed = {}
            local pending = {}
            for _, prereq in pairs(prereqs) do
                local parent = technologies[prereq]
                for _, further in pairs(parent and parent.prerequisites or {}) do
                    pending[#pending + 1] = further
                end
            end
            while #pending > 0 do
                local current = table.remove(pending)
                if needed[current] == nil then
                    needed[current] = true
                    local parent = technologies[current]
                    for _, further in pairs(parent and parent.prerequisites or {}) do
                        pending[#pending + 1] = further
                    end
                end
            end
            -- The same list, keeping the order of what's left
            local num_kept = 0
            local seen = {}
            local num_prereqs = #prereqs
            for i = 1, num_prereqs do
                local prereq = prereqs[i]
                if needed[prereq] == nil and seen[prereq] == nil then
                    seen[prereq] = true
                    num_kept = num_kept + 1
                    prereqs[num_kept] = prereq
                end
            end
            for i = num_prereqs, num_kept + 1, -1 do
                prereqs[i] = nil
            end
        end
    end
end

-- The search each prerequisite used to get, for checking the faster one against
technology_prerequisites.reduce_each = reduce_each

return technology_prerequisites

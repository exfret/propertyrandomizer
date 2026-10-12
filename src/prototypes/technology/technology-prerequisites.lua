local technology_prerequisites = {}

-- Remove an edge only when another path still supplies the same prerequisite.
function technology_prerequisites.reduce(technologies)
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

return technology_prerequisites

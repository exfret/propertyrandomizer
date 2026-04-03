local gutils = require("new-lib/graph/graph-utils")

local tech_prereqs = {}

tech_prereqs.id = "tech_prereqs"

tech_prereqs.with_replacement = true

-- Check if we've already added bonus prereqs to a technology
local is_added_tech = {}
local bonus_times = 1

tech_prereqs.claim = function(graph, prereq, dep, edge)
    if prereq.type == "technology" and dep.type == "technology" then
        local count = 1
        if not is_added_tech[prereq.name] then
            count = count + bonus_times
        end
        return count
    end
end

tech_prereqs.validate = function(graph, base, head, extra)
    -- Any tech-tech connection is fine
    if gutils.get_owner(graph, base).type == "technology" then
        return true
    end
end

tech_prereqs.reflect = function(graph, head_to_base, head_to_handler)
    -- First, remove .upgrade property so that techs don't become hidden unnecessarily
    for _, tech in pairs(data.raw.technology) do
        tech.upgrade = false
    end

    -- Now, since we claimed all tech prereqs, we should be safe to just clear them
    for _, tech in pairs(data.raw.technology) do
        tech.prerequisites = {}
    end

    -- Finally, add prerequisites corresponding to base for each head
    -- already_added just safeguards us against accidentally adding a prereq twice, which isn't checked in validate right now
    -- CRITICAL TODO: Need to double check head_to_base just does heads with this handler
    local already_added = {}
    for head_key, base_key in pairs(head_to_base) do
        if head_to_handler[head_key].id == "tech_prereqs" then
            local base = graph.nodes[base_key]
            local dep_tech = gutils.get_owner(graph, graph.nodes[head_key]).name
            local pre_tech = gutils.get_owner(graph, base).name
            already_added[dep_tech] = already_added[dep_tech] or {}
            if not already_added[dep_tech][pre_tech] then
                already_added[dep_tech][pre_tech] = true
                local tech_prot = data.raw.technology[dep_tech]
                table.insert(tech_prot.prerequisites, pre_tech)
            end
        end
    end
end

return tech_prereqs
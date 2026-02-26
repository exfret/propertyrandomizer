-- TODO: Technologies are still too linear

local gutils = require("new-lib/graph/graph-utils")

local tech_prereqs = {}

tech_prereqs.id = "tech_prereqs"

-- Check if we've already added bonus prereqs to a technology
local is_added_tech = {}
local bonus_times = 1

tech_prereqs.claim = function(graph, prereq, dep, trav)
    if prereq.type == "technology" and dep.type == "technology" then
        local count = 1
        if not is_added_tech[prereq.name] then
            count = count + bonus_times
        end
        return count
    end
end

tech_prereqs.validate = function(graph, slot, trav, extra)
    -- Any tech-tech connection is fine
    if gutils.get_conn_owner(graph, slot).type == "technology" then
        return true
        -- This was causing problems and I have another idea for solving linearity issue
        -- That idea is to do several sorts and take intersection
        --[[
        -- Actually, let's also check that the tech is definitely before in vanilla
        local tech1 = gutils.get_conn_owner(graph, slot)
        local tech2 = gutils.get_conn_owner(graph, trav)
        local init_sort = extra.init_sort
        local earliest_ind1
        for ind, _ in pairs(init_sort.node_to_open_inds[gutils.key(tech1)]) do
            if earliest_ind1 == nil or ind < earliest_ind1 then
                earliest_ind1 = ind
            end
        end
        local earliest_ind2
        for ind, _ in pairs(init_sort.node_to_open_inds[gutils.key(tech2)]) do
            if earliest_ind2 == nil or ind < earliest_ind2 then
                earliest_ind2 = ind
            end
        end
        if init_sort.ind_to_ind[earliest_ind2] >= earliest_ind1 then
            return true
        end]]
    end
end

tech_prereqs.reflect = function(graph, trav_to_new_slot, trav_to_handler)
    -- First, remove .upgrade property so that techs don't become hidden unnecessarily
    for _, tech in pairs(data.raw.technology) do
        tech.upgrade = false
    end

    -- Now, since we claimed all tech prereqs, we should be safe to just clear them
    for _, tech in pairs(data.raw.technology) do
        tech.prerequisites = {}
    end

    -- Finally, add prerequisites corresponding to slot for each traveler
    -- already_added just safeguards us against accidentally adding a prereq twice, which isn't checked in validate right now
    -- CRITICAL TODO: Need to double check trav_to_new_slot just does travs with this handler
    local already_added = {}
    for trav_key, slot in pairs(trav_to_new_slot) do
        if trav_to_handler[trav_key].id == "tech_prereqs" then
            local dep_tech = gutils.get_conn_owner(graph, graph.nodes[trav_key]).name
            local pre_tech = gutils.get_conn_owner(graph, slot).name
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
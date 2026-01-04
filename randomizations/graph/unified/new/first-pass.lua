-- WIP: Ran out of time before finishing

-- This file currently does an extremely basic proposed sort order through the graph with randomized edges removed
-- There is some "prereq management" via not adding a dependent if there are not enough prereqs for it according to some heuristic
-- Other than that, it will be quite minimal until it is tested with the second pass algorithm
-- It simply returns a map from nodes to arrays, with each position in the array corresponding to a context, and for each node that position being the first time the context was reached
-- Actually... that means I need to simulate a whole top sort here, not just order the dependents, right? Because I need at which points things got context, not just the order of first unlock

local rng = require("lib/random/rng")
local logic = require("new-lib/logic/init")
-- We use the extended contexts version here
local top = require("new-lib/graph/extended-sort")

local first_pass = {}

-- Extra number of estimated prereqs required in each pool past 1
local PREREQ_REQUIREMENT_BONUS = 0

-- Shuffle the open list of the sort info given in sort from the graph while attempting to keep prereq pool healthy
-- Need to check "reachability" of an element of open... what does that mean?
-- I guess we activate the contexts we've been given along the edges
-- Wait, we just need to shuffle the deps, the others will follow naturally
-- Wait no, we shuffle open, then pick out the deps
-- dep_map should not be a list, but a map from dep node key to dependent
-- I think sort needs to be with the extended contexts version

-- graph should be cut_graph
-- node_to_random_travs is mostly for convenience; takes our dep node and produces the travs to check
-- prereqs is just a list of node_key for slots; it can have duplicates if a slot is allowed to be used multiple times
first_pass.shuffle = function(graph, sort, dep_map, prereqs, node_to_random_travs)
    local dep_to_context_sequence = {}
    for _, open_info in pairs(sort.open) do
        local node_key = open_info.node
        if dep_map[node_key] ~= nil then
            dep_to_context_sequence[node_key] = dep_to_context_sequence[node_key] or {}
            table.insert(dep_to_context_sequence[node_key], table.deepcopy(open_info.contexts))
        end
    end

    local shuffled_open = rng.shuffle(rng.key({id = "unified"}), table.deepcopy(sort.open))
    local deps_shuffled = {}
    local dep_to_inds_in_shuffled = {}
    for open_ind, open_info in pairs(shuffled_open) do
        local node_key = open_info.node
        if dep_map[node_key] ~= nil then
            -- Contexts need to be decided by deck method, so just insert node_key
            table.insert(deps_shuffled, node_key)
            dep_to_inds_in_shuffled[node_key] = dep_to_inds_in_shuffled[node_key] or {}
            dep_to_inds_in_shuffled[node_key][open_ind] = true
        end
    end

    -- dep --> number representing how many times it's been put in new_order
    -- This is used to determine which context from dep_to_context_sequence to use
    local num_times_dep_used = {}
    for dep_key, _ in pairs(dep_map) do
        num_times_dep_used[dep_key] = 0
    end
    -- node_type --> number of times that node type was used
    local node_type_to_consumed = {}
    for node_type, type_info in pairs(logic.type_info) do
        node_type_to_consumed[node_type] = 0
    end

    -- This is for finding what slots/prereqs are currently reachable
    local slot_sort = top.sort(graph)

    local ind_to_used = {}
    local new_order = {}

    for i = 1, #deps_shuffled do
        local found_next_dep = false
        for dep_ind, dep_key in pairs(deps_shuffled) do
            -- An immediate check for ind used is efficient and gets that out of the way
            if not ind_to_used[dep_ind] then
                -- Check prereq pools with respect to context (then propagate with new reachable - will need to deal with "edge still not being there")
                -- I think the edge not being there problem can be solved by just using the traveler --> owner connection
                local context_to_use = dep_to_context_sequence[dep_key][num_times_dep_used[dep_key] + 1]

                local all_travs_satisfied = false
                for _, trav in pairs(node_to_random_travs[dep_key]) do
                    -- Strategy: Find number of slots that transmit at least context_to_use on a transmit_dep (need to do this in case the edge modifies context)
                    --   And also check validity for each one
                    --   Then, multiply by the the fraction of the total number of slots reachable by some context that are not consumed
                    --   Finally, check if the final result is at least 1 + PREREQ_REQUIREMENT_BONUS

                    local total_num_reachable_slots = 0
                    local total_num_valid_slots = 0
                    -- It's really slow to keep iterating over every slot each time, but this is good enough for now
                    for slot_key, _ in pairs(prereqs) do
                        -- Check dep context transmission
                    end
                end
            end
        end
    end
end

return first_pass
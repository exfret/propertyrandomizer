-- Prevent the first satisfier of certain required nodes from participating in first pass, to maintain game balance
-- This includes things like transport belts and assembling machines, which should be relatively early

local gutils = require("new-lib/graph/graph-utils")
local logic = require("new-lib/logic/init")

local balance = {}

balance.find_balance_blacklist = function(graph, init_sort)
    local in_blacklist = {}

    for _, node in pairs(graph.nodes) do
        if node.class == "groups" and node.type ~= "orand" then
            local sorted_prenodes = table.deepcopy(gutils.prenodes(graph, node))

            table.sort(sorted_prenodes, function(a, b)
                -- Copied code from execute-new.lua's context reachable function
                local key1 = gutils.key(a)
                local key2 = gutils.key(b)

                local smallest_ind1
                local smallest_ind2

                for context, _ in pairs(logic.contexts) do
                    local index1 = init_sort.node_to_context_inds[key1][context]
                    local index2 = init_sort.node_to_context_inds[key2][context]
                    if index1 ~= nil and (smallest_ind1 == nil or index1 < smallest_ind1) then
                        smallest_ind1 = index1
                    end
                    if index2 ~= nil and (smallest_ind2 == nil or index2 < smallest_ind2) then
                        smallest_ind2 = index2
                    end
                end
                if smallest_ind1 == nil then
                    return false
                end
                if smallest_ind2 == nil then
                    return true
                end
                if smallest_ind1 < smallest_ind2 then
                    return true
                else
                    return false
                end
            end)

            -- The first way to satisfy this node becomes blacklisted from first pass
            local first_node = sorted_prenodes[1]
            in_blacklist[gutils.key(first_node)] = true
            -- CRITICAL TODO: Better methods!
            -- Hotfix: do anything based on same name as well
            in_blacklist[first_node.name] = true
            if first_node.type == "orand" then
                in_blacklist[gutils.key(gutils.unique_prenode(graph, first_node))] = true
                in_blacklist[gutils.unique_prenode(graph, first_node).name] = true
            end
        end
    end

    log(serpent.block(in_blacklist))

    return in_blacklist
end

return balance
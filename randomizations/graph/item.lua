-- CRITICAL TODO: Exclude plants like Jellystem!
-- Also iron/copper bacteria?
-- TODO: Think about maybe how to give more things mine results, like spaceship
-- TODO: Revise algorithm to allow things to appear earlier, like lithium on nauvis even

local constants = require("helper-tables/constants")
-- build_graph is used for its utility functions, not the graph building (graph is assumed global)
local build_graph = require("lib/graph/build-graph")
local flow_cost = require("lib/graph/flow-cost")
local top_sort = require("lib/graph/top-sort")
local rng = require("lib/random/rng")

-- TODO:
--   * Somehow preserve planet stuffs?
--   * Preserve place_as_tile as well

-- NEW
-- Randomizes from where misc. items can be gotten besides from recipes (like mining rocks)
randomizations.non_recipe_item = function(id)
    ----------------------------------------------------------------------
    -- Setup
    ----------------------------------------------------------------------

    -- Get costs of items
    local costs = flow_cost.determine_recipe_item_cost(flow_cost.get_default_raw_resource_table(), constants.cost_params.time, constants.cost_params.complexity)

    local function find_cost_in_conn(conn)
        local old_entity_prot
        for entity_class, _ in pairs(defines.prototypes.entity) do
            if data.raw[entity_class] ~= nil then
                if data.raw[entity_class][conn[1].name] ~= nil then
                    old_entity_prot = data.raw[entity_class][conn[1].name]
                end
            end
        end
        local old_amount = 0
        if old_entity_prot.minable.results ~= nil then
            -- Technically, find_amount_in_ing_or_prod takes the actual item prototype, but type and name is enough for it
            old_amount = flow_cost.find_amount_in_ing_or_prod(old_entity_prot.minable.results, {type = "item", name = conn[2].name})
        else
            if old_entity_prot.minable.count ~= nil then
                old_amount = old_entity_prot.minable.count
            else
                old_amount = 1
            end
        end
        local old_cost
        if costs.material_to_cost["item-" .. conn[2].name] ~= nil then
            old_cost = old_amount * costs.material_to_cost["item-" .. conn[2].name]
        end

        return old_cost
    end

    ----------------------------------------------------------------------
    -- Prereq shuffle
    ----------------------------------------------------------------------

    -- Look at each node incoming connection to randomize, and node outgoing connection to randomize

    -- Sort the graph
    local sort_info = top_sort.sort(dep_graph)
    local graph_sort = sort_info.sorted

    -- Find the connections
    -- Just try autoplace for now
    local out_conns_shuffle = {}
    local in_conns_sort = {}
    local blacklist = {}
    for _, prereq in pairs(graph_sort) do
        if prereq.type == "mine-entity" then
            local prereq_prot
            for entity_class, _ in pairs(defines.prototypes.entity) do
                if data.raw[entity_class] ~= nil and data.raw[entity_class][prereq.name] ~= nil then
                    prereq_prot = data.raw[entity_class][prereq.name]
                end
            end

            if prereq_prot.minable ~= nil then
                local dep_nodes = {}
                if prereq_prot.minable.results ~= nil then
                    for _, result in pairs(prereq_prot.minable.results) do
                        table.insert(dep_nodes, {
                            type = "item",
                            name = result.name
                        })
                    end
                else
                    dep_nodes = {{
                        type = "item",
                        name = prereq_prot.minable.result
                    }}
                end

                -- Since items are OR nodes, we don't have to worry about extra reachability concerns
                for _, dep_node in pairs(dep_nodes) do
                    -- Check that this isn't a resource entity (don't randomize mine results of those)
                    local is_resource = false
                    if data.raw.resource[prereq.name] ~= nil then
                        is_resource = true
                    end
                    local is_asteroid_chunk = false
                    if data.raw["asteroid-chunk"][prereq.name] ~= nil then
                        is_asteroid_chunk = true
                    end
                    -- Check that this isn't the item used to make this entity
                    local dep_prot
                    for item_class, _ in pairs(defines.prototypes.item) do
                        if data.raw[item_class] ~= nil then
                            if data.raw[item_class][dep_node.name] ~= nil then
                                dep_prot = data.raw[item_class][dep_node.name]
                            end
                        end
                    end
                    if not is_resource and not is_asteroid_chunk and dep_prot.place_result == nil then
                        table.insert(out_conns_shuffle, {prereq, dep_node})
                        table.insert(in_conns_sort, {prereq, dep_node})
                        blacklist[build_graph.conn_key({prereq, dep_node})] = true
                    end
                end
            end
        end
    end

    -- Perform the shuffle
    rng.shuffle(rng.key({id = id}), out_conns_shuffle)

    local used_out_indices = {}
    local new_in_conns = table.deepcopy(in_conns_sort)
    local old_out_conns_order = {}
    local sort_state = top_sort.sort(dep_graph, blacklist)
    for in_conn_ind, in_conn in pairs(in_conns_sort) do
        local reachable = sort_state.reachable

        local found_prereq = false
        for out_conn_ind, out_conn in pairs(out_conns_shuffle) do
            if not used_out_indices[out_conn_ind] then
                if reachable[build_graph.key(out_conn[1].type, out_conn[1].name)] then
                    -- Add this prerequisite
                    new_in_conns[in_conn_ind][1].type = out_conn[1].type
                    new_in_conns[in_conn_ind][1].name = out_conn[1].name
                    -- Remember old item
                    table.insert(old_out_conns_order, out_conn)
                    
                    -- Extra key for keeping track of cost of the replaced out_conn
                    new_in_conns[in_conn_ind][1].cost = find_cost_in_conn(out_conn)
                    used_out_indices[out_conn_ind] = true
                    found_prereq = true
                    break
                end
            end
        end

        -- Error if we didn't find a valid prereq
        if not found_prereq then
            error()
        end

        -- Take this connection off the blacklist
        blacklist[build_graph.conn_key(in_conn)] = false
        -- Update reachable
        sort_state = top_sort.sort(dep_graph, blacklist, sort_state, in_conn)
    end

    -- Just hope that two of the same item doesn't go to the same prereq for now
    -- TODO: Remove this assumption
    -- We would need to keep track of the index in the minable results that this corresponds to
    for ind, in_conn in pairs(in_conns_sort) do
        local new_cost = find_cost_in_conn(in_conn)
        local old_cost = new_in_conns[ind][1].cost

        -- Replace results for in_conn[1] with in_conn[2]
        local new_entity_prot
        for entity_class, _ in pairs(defines.prototypes.entity) do
            if data.raw[entity_class] ~= nil then
                if data.raw[entity_class][new_in_conns[ind][1].name] ~= nil then
                    new_entity_prot = data.raw[entity_class][new_in_conns[ind][1].name]
                end
            end
        end
        local old_item_prot
        for item_class, _ in pairs(defines.prototypes.item) do
            if data.raw[item_class] ~= nil then
                if data.raw[item_class][old_out_conns_order[ind][2].name] ~= nil then
                    old_item_prot = data.raw[item_class][old_out_conns_order[ind][2].name]
                end
            end
        end
        -- If old_cost or new_cost is nil, just use the same/old amount for new_amount
        -- Otherwise, scale numbers up/down by ratio with ceil
        if new_entity_prot.minable.results ~= nil then
            for _, result in pairs(new_entity_prot.minable.results) do
                if result.name == old_item_prot.name then
                    result.name = in_conn[2].name

                    if new_cost ~= 0 and old_cost ~= nil and new_cost ~= nil then
                        if result.amount ~= nil then
                            result.amount = math.ceil(result.amount * old_cost / new_cost)
                        end
                        if result.amount_min ~= nil then
                            result.amount_min = math.ceil(result.amount_min * old_cost / new_cost)
                        end
                        if result.amount_max ~= nil then
                            result.amount_max = math.ceil(result.amount_max * old_cost / new_cost)
                        end
                    end
                end
            end
        else
            -- Note: this if statement should always be true
            if new_entity_prot.minable.result == old_item_prot.name then
                new_entity_prot.minable.result = in_conn[2].name
                if new_cost ~= 0 and old_cost ~= nil and new_cost ~= nil then
                    local count = new_entity_prot.minable.count
                    if count == nil then
                        count = 1
                    end
                    new_entity_prot.minable.count = math.ceil(count * old_cost / new_cost)
                end
            end
        end
    end
end
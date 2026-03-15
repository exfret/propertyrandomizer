local gutils = require("new-lib/graph/graph-utils")
local top = require("new-lib/graph/consistent-sort")
-- Used for getting contexts
local logic = require("new-lib/logic/init")

local test = {}

local test_graph
local sort_info
local sort_info_unoptimized

-- With automation science edge severed
local severed_graph
local severed_sort_info

local no_platform_graph
local no_platform_info

test.init = function(graph)
    test_graph = table.deepcopy(graph)
    sort_info = top.sort(test_graph)
    sort_info_unoptimized = top.sort(test_graph, nil, nil, { choose_randomly = true })
    
    severed_graph = table.deepcopy(graph)
    gutils.sever_node(severed_graph, gutils.key("item", "automation-science-pack"))
    severed_sort_info = top.sort(severed_graph)

    if mods["space-age"] then
        no_platform_graph = table.deepcopy(graph)
        gutils.sever_node(no_platform_graph, gutils.key("launch", ""))
        no_platform_info = top.sort(no_platform_graph)
    end
end

test.validate_all_techs_reachable = function()
    for _, node in pairs(test_graph.nodes) do
        if node.type == "technology" then
            local tech = data.raw.technology[node.name]
            -- Ignore infinite techs for now since I don't have rocket launch products implemented
            -- TODO: Implement those!
            if tech.max_level ~= "infinite" then
                local has_context = false
                for context, _ in pairs(logic.contexts) do
                    if sort_info.node_to_context_inds[gutils.key(node)][context] ~= nil then
                        has_context = true
                        break
                    end
                end
                if not has_context then
                    log(serpent.block(node))
                    error()
                end
            end
        end
    end
end

-- When automation science packs are made unreachable, no science-pack-based tech should be reachable
test.validate_no_techs_reachable = function()
    for _, node in pairs(severed_graph.nodes) do
        if node.type == "technology" then
            local tech = data.raw.technology[node.name]
            if tech.unit ~= nil then
                local has_context = false
                for context, _ in pairs(logic.contexts) do
                    if severed_sort_info.node_to_context_inds[gutils.key(node)][context] ~= nil then
                        has_context = true
                        break
                    end
                end
                if has_context then
                    log(serpent.block(node))
                    error()
                end
            end
        end
    end
end

-- Make sure rooms aren't reachable without launch node
test.validate_launch_first = function()
    if mods["space-age"] then
        for _, pebble in pairs(no_platform_info.sorted) do
            local node = no_platform_graph.nodes[pebble.node_key]
            if node.type == "room" and node.name ~= gutils.key("planet", "nauvis") then
                log(serpent.block(pebble))
                error("Non-nauvis context possible to get to without launch.")
            end
        end
    end
end

-- Test that lava is only available on vulcanus
test.lava_only_on_vulcanus = function()
    if mods["space-age"] then
        for context, _ in pairs(sort_info.node_to_context_inds[gutils.key("fluid", "lava")]) do
            if context ~= gutils.key("planet", "vulcanus") then
                log(serpent.block(pebble))
                error("Non-vulcanus context produces lava!")
            end
        end
    end
end

test.path_contains_chemical_science = function()
    local silo_node = test_graph.nodes[gutils.key("entity-operate", "rocket-silo")]
    local nauvis_context = gutils.key("planet", "nauvis")
    local silo_ind = sort_info.node_to_context_inds[gutils.key(silo_node)][nauvis_context]
    local path_info = top.path(test_graph, { silo_ind }, sort_info)

    local science_node = test_graph.nodes[gutils.key("item", "chemical-science-pack")]
    local science_ind = sort_info.node_to_context_inds[gutils.key(science_node)][nauvis_context]
    if not path_info.in_path[science_ind] then
        error()
    end
end

test.path_not_contains_defender = function()
    local silo_node = test_graph.nodes[gutils.key("entity-operate", "rocket-silo")]
    local nauvis_context = gutils.key("planet", "nauvis")
    local silo_ind = sort_info.node_to_context_inds[gutils.key(silo_node)][nauvis_context]
    local path_info = top.path(test_graph, { silo_ind }, sort_info)

    local capsule_node = test_graph.nodes[gutils.key("item", "defender-capsule")]
    local capsule_ind = sort_info.node_to_context_inds[gutils.key(capsule_node)][nauvis_context]
    if path_info.in_path[capsule_ind] then
        error()
    end
end

test.path_contains_gleba_biochamber = function()
    if mods["space-age"] then
        local science_node = test_graph.nodes[gutils.key("item", "promethium-science-pack")]
        local nauvis_context = gutils.key("planet", "nauvis")
        local science_ind = sort_info.node_to_context_inds[gutils.key(science_node)][nauvis_context]
        local path_info = top.path(test_graph, { science_ind }, sort_info)

        for _, ind in pairs(path_info.path) do
            log(serpent.block(sort_info.sorted[ind]))
        end

        local chamber_node = test_graph.nodes[gutils.key("entity-operate", "biochamber")]
        local gleba_context = gutils.key("planet", "gleba")
        local chamber_ind = sort_info.node_to_context_inds[gutils.key(chamber_node)][gleba_context]
        if not path_info.in_path[chamber_ind] then
            error()
        end
    end
end

test.path_not_contains_nauvis_biochamber = function()
    if mods["space-age"] then
        local science_node = test_graph.nodes[gutils.key("item", "promethium-science-pack")]
        local nauvis_context = gutils.key("planet", "nauvis")
        local science_ind = sort_info.node_to_context_inds[gutils.key(science_node)][nauvis_context]
        local path_info = top.path(test_graph, { science_ind }, sort_info)

        for _, ind in pairs(path_info.path) do
            log(serpent.block(sort_info.sorted[ind]))
        end

        local chamber_node = test_graph.nodes[gutils.key("entity-operate", "biochamber")]
        local chamber_ind = sort_info.node_to_context_inds[gutils.key(chamber_node)][nauvis_context]
        if path_info.in_path[chamber_ind] then
            error()
        end
    end
end

-- Finds number of pairs of nodes X,Y in sort_info where X is before Y in one context and vice versa in the other
test.profile_num_switches = function()
    local function find_num_switches(sort_info_to_use, path_info_to_use)
        local num_switches = 0
        local switch_counted = {}

        local function counted_switch(pebble_a, pebble_b)
            if switch_counted[pebble_a.node_key] ~= nil and switch_counted[pebble_a.node_key][pebble_b.node_key] then
                return true
            end
            return false
        end
        local function two_way_counted(pebble_a, pebble_b)
            return counted_switch(pebble_a, pebble_b) or counted_switch(pebble_b, pebble_a)
        end
        local function add_counted(pebble_a, pebble_b)
            switch_counted[pebble_a] = switch_counted[pebble_a] or {}
            switch_counted[pebble_a][pebble_b] = true
        end
        local function add_two_way_counted(pebble_a, pebble_b)
            add_counted(pebble_a, pebble_b)
            add_counted(pebble_b, pebble_a)
        end
        local function node_context_a_cant_rely_on_b(node_key_a, node_key_b, context)
            local ind_a = sort_info_to_use.node_to_context_inds[node_key_a][context]
            local ind_b = sort_info_to_use.node_to_context_inds[node_key_b][context]
            --[[if ind_a == nil or ind_b == nil then
                return false
            end
            return ind_b > ind_a]]
            if path_info_to_use ~= nil and not (path_info_to_use.in_path[ind_a] and path_info_to_use.in_path[ind_b]) then
                return false
            end
            return (ind_b or (#sort_info_to_use.sorted + 1)) >= (ind_a or (#sort_info_to_use.sorted + 2))
        end

        local progress = 0
        local all_nodes = {}
        for _, node in pairs(test_graph.nodes) do
            table.insert(all_nodes, node)
        end
        for i, node1 in pairs(all_nodes) do
            if 100 * i / #all_nodes >= progress + 1 then
                progress = progress + 1
                log(tostring(progress) .. "% Done")
            end
            for _, node2 in pairs(all_nodes) do
                local imply = false
                local impliedby = false
                for context, _ in pairs(logic.contexts) do
                    if node_context_a_cant_rely_on_b(gutils.key(node1), gutils.key(node2), context) then
                        imply = true
                    elseif node_context_a_cant_rely_on_b(gutils.key(node2), gutils.key(node1), context) then
                        impliedby = true
                    end
                end
                if imply and impliedby then
                    num_switches = num_switches + 1
                end
            end
        end
        --[[for i, pebble1 in pairs(sort_info_to_use.sorted) do
            if 100 * i / #sort_info_to_use.sorted >= progress + 1 then
                progress = progress + 1
                log(tostring(progress) .. "% Done")
            end
            for _, pebble2 in pairs(sort_info_to_use.sorted) do
                if pebble1.node_key ~= pebble2.node_key and not two_way_counted(pebble1, pebble2) then
                    add_two_way_counted(pebble1, pebble2)
                    local imply = false
                    local impliedby = false
                    for context, _ in pairs(logic.contexts) do
                        if node_context_a_cant_rely_on_b(pebble1.node_key, pebble2.node_key, context) then
                            imply = true
                        elseif node_context_a_cant_rely_on_b(pebble2.node_key, pebble1.node_key, context) then
                            impliedby = true
                        end
                    end
                    if imply and impliedby then
                        num_switches = num_switches + 1
                    end
                end
            end
        end]]

        return num_switches
    end

    --log("Optimized: " .. tostring(find_num_switches(sort_info)) .. "\n")
    --log("Unoptimized: " .. tostring(find_num_switches(sort_info_unoptimized)) .. "\n")

    -- Just do all items on nauvis
    local goal_inds = {}
    for ind, pebble in pairs(sort_info.sorted) do
        local node = test_graph.nodes[pebble.node_key]
        if node.type == "item" and pebble.context == gutils.key("planet", "vulcanus") then
            table.insert(goal_inds, ind)
        end
    end
    local path_info = top.path(test_graph, goal_inds, sort_info)

    local goal_inds_unoptimized = {}
    for ind, pebble in pairs(sort_info_unoptimized.sorted) do
        local node = test_graph.nodes[pebble.node_key]
        if node.type == "item" and pebble.context == gutils.key("planet", "vulcanus") then
            table.insert(goal_inds_unoptimized, ind)
        end
    end
    local path_info_unoptimized = top.path(test_graph, goal_inds_unoptimized, sort_info_unoptimized)

    log("Optimized w/ path: " .. tostring(find_num_switches(sort_info, path_info)) .. "\n")
    log("Unoptimized w/ path: " .. tostring(find_num_switches(sort_info_unoptimized, path_info_unoptimized)) .. "\n")
end

return test
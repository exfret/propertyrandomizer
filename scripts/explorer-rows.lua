-- Which nodes the explorer shows under a node
-- Pure functions of the graph, so plain Lua can test them (scripts/test-explorer-rows.lua)

local gutils = require("lib/graph/graph-utils")

local explorer_rows = {}

-- Ways to count a delivered building as made in the room (space platforms, bootstrap rooms), which only matter for isolatability
-- Each needs the building built, which entity-own already shows, so the explorer leaves them out
local is_folded_type = {
    ["entity-own-space"] = true,
    ["entity-own-bootstrap"] = true,
}
-- Nodes the explorer skips through: each is shown as its one way left (entity-own), and that as its own way if it has only one
-- So operating a building shows Build under Operate, instead of two levels of ownership
local is_skipped_type = {
    ["entity-own-operable"] = true,
}
-- Needs of operating an entity that don't make the explorer start from operating it: being ours, and conditions of where it's placed (warmth, lightning safety)
local is_root_ignored_type = {
    ["entity-own-operable"] = true,
    ["warmth"] = true,
    ["lightning-safe"] = true,
}

local function shown_ways(graph, node)
    local ways = {}
    for _, prenode in pairs(gutils.prenodes(graph, node)) do
        if not is_folded_type[prenode.type] then
            table.insert(ways, prenode)
        end
    end
    return ways
end

-- The node to show for prenode: nil to leave it out, prenode itself to follow the usual rules, or a stand-in that's always its own row
local function shown_node(graph, prenode)
    if is_folded_type[prenode.type] then
        return nil
    end
    if not is_skipped_type[prenode.type] then
        return prenode
    end
    -- With several ways, they can't be listed in its place, since the node under it may need all of its prereqs
    local ways = shown_ways(graph, prenode)
    if #ways ~= 1 then
        return prenode
    end
    local ways_of_way = shown_ways(graph, ways[1])
    if #ways_of_way == 1 then
        return ways_of_way[1]
    end
    return ways[1]
end

-- The rows under node, with each row's amount modifier (for recipe amounts)
-- A prereq of the same thing (same canonical and name) with the same op, or with only one prereq, is expanded into its own prereqs
-- edge_factor(curr_node, prenode) is the amount modifier's factor for an edge with inds (nil in plain Lua, where there are no prototypes)
explorer_rows.leaves = function(graph, node, edge_factor)
    local open = {node}
    local leaves = {}
    local seen = {}
    local node_to_amount_modifier = {[gutils.key(node)] = 1}
    local open_ind = 1
    while open_ind <= #open do
        local curr_node = open[open_ind]
        for pre, _ in pairs(curr_node.pre) do
            local prekey = graph.edges[pre].start
            if not seen[prekey] then
                seen[prekey] = true
                local prenode = graph.nodes[prekey]
                local shown = shown_node(graph, prenode)

                if shown ~= nil and shown ~= prenode then
                    local shown_key = gutils.key(shown)
                    if not seen[shown_key] then
                        seen[shown_key] = true
                        node_to_amount_modifier[shown_key] = node_to_amount_modifier[gutils.key(curr_node)]
                        table.insert(leaves, shown)
                    end
                elseif shown ~= nil then
                    node_to_amount_modifier[prekey] = node_to_amount_modifier[gutils.key(curr_node)]
                    if graph.edges[pre].inds ~= nil and edge_factor ~= nil then
                        node_to_amount_modifier[prekey] = node_to_amount_modifier[prekey] * edge_factor(curr_node, prenode)
                    end

                    -- Test for whether to propagate more (same op and same canonical)
                    -- Don't check op if there is one prereq (AND/OR equivalent then)
                    -- Also make sure it's not a source (must be included as leaf then!)
                    -- Finally, needs to be the same sort of thing (same node name)
                    if prenode.num_pre ~= 0 and (((prenode.op == node.op or prenode.num_pre == 1) and (graph.type_info[prenode.type].canonical == graph.type_info[node.type].canonical and prenode.name == node.name)) or (node.num_pre == 1 and prenode.type == "fluid-temperature")) then
                        table.insert(open, prenode)
                    else
                        table.insert(leaves, prenode)
                    end
                end
            end
        end

        open_ind = open_ind + 1
    end

    return {
        leaves = leaves,
        node_to_amount_modifier = node_to_amount_modifier,
    }
end

-- Whether operating the entity needs more than having it, so the explorer starts from its entity-operate node
explorer_rows.operate_needs_more = function(graph, operate_node)
    for _, prenode in pairs(gutils.prenodes(graph, operate_node)) do
        if not is_root_ignored_type[prenode.type] then
            return true
        end
    end
    return false
end

return explorer_rows

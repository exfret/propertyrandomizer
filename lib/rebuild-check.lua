-- Checks a rebuilt tech tree against the game before the rebuild, and leaves out the prerequisites behind anything it lost (randomizations.rebuild_tech_tree in randomizations/fixes.lua)
-- The rebuild checks a prerequisite only where the tech's own recipe can be made, so what other techs then need from that tech only shows in the rebuilt game

local gutils = require("lib/graph/graph-utils")
local logic = require("lib/logic/init")
local top = require("lib/graph/context-sort")
local technology_prerequisites = require("lib/technology-prerequisites")

local rebuild_check = {}

-- Times the rebuilt game is sorted again after leaving out prerequisites, before what it still lost is only logged
rebuild_check.MAX_ROUNDS = 3

-- Whether the rebuilt game must keep a node's contexts: techs are what the rebuild replaces, and a recipe's unlock nodes only matter through the recipe, which also needs the rest of what it needs where it's made
local function is_kept(node)
    return node.type ~= "technology" and node.type ~= "recipe-tech-unlock" and node.type ~= "recipe-unlock"
end

-- The pebbles of before_sort's game that the rebuilt game (after_graph, sorted as after_sort) lost, as a list of { node_key, context }
-- Home contexts don't count on their own: they only back isolatability (see skeleton/protection.lua), which the contexts they ride on show
rebuild_check.lost = function(before_sort, after_graph, after_sort)
    local lost = {}
    for node_key, contexts in pairs(before_sort.node_to_context_inds) do
        local node = after_graph.nodes[node_key]
        if node ~= nil and is_kept(node) then
            local after_contexts = after_sort.node_to_context_inds[node_key] or {}
            for context, _ in pairs(contexts) do
                if top.context_home(context) == nil and after_contexts[context] == nil then
                    table.insert(lost, {
                        node_key = node_key,
                        context = context,
                    })
                end
            end
        end
    end
    table.sort(lost, function(a, b)
        if a.node_key ~= b.node_key then
            return a.node_key < b.node_key
        end
        return a.context < b.context
    end)
    return lost
end

-- The prerequisites to leave out for the lost pebbles, as tech name --> prerequisite name --> true
-- Each lost pebble is backed in flat_sort, the sort of flat_graph (the game without tech prerequisites); a tech on that backing which the rebuilt game lacks the context of loses each prerequisite that can't send it the context
-- A tech on the backing shows up as itself (the second rebuild, and techs kept for the logic), or as the unlock of a recipe whose rebuilt tech takes its place, whose research it copies
-- flat_tech_of(tech name) is the tech of flat_graph whose research the tech has, or nil if the rebuild didn't choose its prerequisites; a tech whose research doesn't reach the context there keeps them, since leaving them out can't bring the context back
-- after_graph has the prerequisites technology_prerequisites.reduce keeps, and full_prerequisites (tech name --> list) all of them, which the ones left out come from: a prerequisite reduce left out is needed by one it kept, so it can be the reason that one can't send the context
rebuild_check.cuts = function(lost, flat_graph, flat_sort, after_graph, after_sort, flat_tech_of, full_prerequisites)
    local cuts = {}
    local goal_inds = {}
    for _, pebble in pairs(lost) do
        local ind = (flat_sort.node_to_context_inds[pebble.node_key] or {})[pebble.context]
        if ind ~= nil then
            table.insert(goal_inds, ind)
        end
    end
    if #goal_inds == 0 then
        return cuts
    end
    local after_inds = after_sort.node_to_context_inds
    -- Whether the tech at prereq_key sends context through an edge like edge
    local function sends(edge, prereq_key, context)
        for _, source in pairs(top.edge_source_contexts(after_sort, edge, context)) do
            if (after_inds[prereq_key] or {})[source] ~= nil then
                return true
            end
        end
        return false
    end
    local function cut_blocked(tech_key, context)
        local tech = after_graph.nodes[tech_key]
        if tech == nil or tech.type ~= "technology" or (after_inds[tech_key] or {})[context] ~= nil then
            return
        end
        local flat_name = flat_tech_of(tech.name)
        if flat_name == nil or (flat_sort.node_to_context_inds[gutils.key("technology", flat_name)] or {})[context] == nil then
            return
        end
        for pre, _ in pairs(tech.pre) do
            local edge = after_graph.edges[pre]
            if after_graph.nodes[edge.start].type == "technology" and not sends(edge, edge.start, context) then
                -- Every prerequisite of a tech gets the same edge (lib/logic/concrete.lua), so this one also tells which of the full list can't send the context
                for _, prereq_name in pairs(full_prerequisites[tech.name] or {}) do
                    local prereq_key = gutils.key("technology", prereq_name)
                    if after_graph.nodes[prereq_key] ~= nil and not sends(edge, prereq_key, context) then
                        cuts[tech.name] = cuts[tech.name] or {}
                        cuts[tech.name][prereq_name] = true
                    end
                end
                return
            end
        end
    end
    local path_info = top.path(flat_graph, goal_inds, flat_sort)
    -- The techs unlocking the backing's recipes, by the tech of flat_graph whose research they have: each needs the backing's contexts of that tech too, like the home context the discovery rule makes a tech isolatable on a discovered planet with (see top.discovery_candidates)
    local rebuilt_of = {}
    for ind, _ in pairs(path_info.in_path) do
        local pebble = flat_sort.sorted[ind]
        local unlock = after_graph.nodes[pebble.node_key]
        if flat_graph.nodes[pebble.node_key].type == "recipe-tech-unlock" and unlock ~= nil then
            for pre, _ in pairs(unlock.pre) do
                local tech_key = after_graph.edges[pre].start
                local tech = after_graph.nodes[tech_key]
                local flat_name = tech ~= nil and tech.type == "technology" and flat_tech_of(tech.name) or nil
                if flat_name ~= nil then
                    local flat_key = gutils.key("technology", flat_name)
                    rebuilt_of[flat_key] = rebuilt_of[flat_key] or {}
                    rebuilt_of[flat_key][tech_key] = true
                end
            end
        end
    end
    for ind, _ in pairs(path_info.in_path) do
        local pebble = flat_sort.sorted[ind]
        local node = flat_graph.nodes[pebble.node_key]
        if node.type == "technology" then
            cut_blocked(pebble.node_key, pebble.context)
            for tech_key, _ in pairs(rebuilt_of[pebble.node_key] or {}) do
                cut_blocked(tech_key, pebble.context)
            end
        elseif node.type == "recipe-tech-unlock" then
            local unlock = after_graph.nodes[pebble.node_key]
            for pre, _ in pairs(unlock ~= nil and unlock.pre or {}) do
                local edge = after_graph.edges[pre]
                for _, source in pairs(top.edge_source_contexts(after_sort, edge, pebble.context)) do
                    cut_blocked(edge.start, source)
                end
            end
        end
    end
    return cuts
end

-- Sorts the game as the rebuild left it in technologies (data.raw.technology, with the prerequisites technology_prerequisites.reduce keeps), and leaves out prerequisites until it keeps every pebble before_sort has, sorting again after each round
-- full_prerequisites (tech name --> list) are the prerequisites before reduce; the ones left out come out of these lists, and technologies get them reduced again
-- Returns the number of prerequisites left out, the number of rounds that left some out, and the pebbles still lost (see rebuild_check.lost)
rebuild_check.run = function(before_sort, flat_graph, flat_sort, technologies, full_prerequisites, flat_tech_of)
    local num_cut = 0
    local num_rounds = 0
    local lost
    while true do
        logic.build()
        local after_sort = top.sort(logic.graph, nil, nil, {
            complex_contexts = true,
            home_contexts = true,
        })
        lost = rebuild_check.lost(before_sort, logic.graph, after_sort)
        if #lost == 0 or num_rounds == rebuild_check.MAX_ROUNDS then
            break
        end
        local num_round = 0
        for tech_name, prereqs in pairs(rebuild_check.cuts(lost, flat_graph, flat_sort, logic.graph, after_sort, flat_tech_of, full_prerequisites)) do
            local kept = {}
            for _, prereq in pairs(full_prerequisites[tech_name]) do
                if prereqs[prereq] == nil then
                    table.insert(kept, prereq)
                else
                    num_round = num_round + 1
                end
            end
            full_prerequisites[tech_name] = kept
        end
        -- Nothing left to leave out: what's lost doesn't come from prerequisites
        if num_round == 0 then
            break
        end
        num_cut = num_cut + num_round
        num_rounds = num_rounds + 1
        -- A prerequisite reduce left out may be needed again once the one that needed it is left out
        for tech_name, prereqs in pairs(full_prerequisites) do
            technologies[tech_name].prerequisites = table.deepcopy(prereqs)
        end
        technology_prerequisites.reduce(technologies)
    end
    return num_cut, num_rounds, lost
end

return rebuild_check

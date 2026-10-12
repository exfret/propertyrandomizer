-- The both-ways check of graph reductions (src/logic/analysis/reductions.lua), with the hidden test-reductions setting: logic.build makes every graph twice from the same data.raw, full and reduced, and this compares them
-- A REDUCTIONCHECK line per build says ok or FAILED, which dev/run-tests.py fails a run for:
--   * The full graph, with each spoofed recipe category's node renamed to its group's (lutils.group_rcats), is the reduced graph with its reductions expanded: the same nodes, edges and fields.
--   * Every surviving node and every crafting query gets the same contexts in a simple sort and in one with complex and home contexts; left-out pass-through nodes have no query to compare.
-- Home contexts are recorded without letting a smaller set's context stand for a bigger one's (top.implied_home_contexts), since which of those gets recorded depends on the order pebbles arrive in, and the two graphs reach things in different orders
-- (Complex contexts without home contexts aren't compared: their discovery rule depends on the order too, and no data-stage sort uses them)

local gutils = require("src/lib/graph/graph-utils")
local top = require("src/lib/sort/context-sort")
local lutils = require("src/logic/logic-utils")
local reductions = require("src/logic/analysis/reductions")
local item_craft = require("src/logic/builders/item-craft")

local reduction_check = {}

local num_builds = 0

-- The key of the node standing for node_key in the reduced graph (the current one): its group's recipe-category node, or itself
local function stand_in(node_key)
    local node = gutils.deconstruct(node_key)
    if node.type == "recipe-category" then
        return gutils.key("recipe-category", lutils.rcat_node_name(node.name))
    end
    return node_key
end

-- Every node and edge with its fields, as a set of lines, with nodes renamed to their stand-ins (several renamed alike become one)
local function structure(graph)
    local lines = {}
    for node_key, node in pairs(graph.nodes) do
        local fields = {}
        for k, v in pairs(node) do
            if k ~= "pre" and k ~= "dep" and k ~= "name" and type(v) ~= "table" then
                table.insert(fields, k .. "=" .. tostring(v))
            end
        end
        table.sort(fields)
        lines["node " .. stand_in(node_key) .. " " .. table.concat(fields, " ")] = true
    end
    for _, edge in pairs(graph.edges) do
        local fields = {}
        for k, v in pairs(edge) do
            if k ~= "start" and k ~= "stop" and type(v) ~= "table" then
                table.insert(fields, k .. "=" .. tostring(v))
            end
        end
        table.sort(fields)
        lines["edge " .. stand_in(edge.start) .. " --> " .. stand_in(edge.stop) .. " " .. table.concat(fields, " ")] = true
    end
    return lines
end

-- Lines only one of a and b has, marked - and +, sorted
local function differences(a, b)
    local found = {}
    for line, _ in pairs(a) do
        if b[line] == nil then
            table.insert(found, "-" .. line)
        end
    end
    for line, _ in pairs(b) do
        if a[line] == nil then
            table.insert(found, "+" .. line)
        end
    end
    table.sort(found)
    return found
end

-- A node's contexts' names, as one string
local function contexts_text(graph, sort_info, node_key)
    local names = {}
    for context, _ in pairs(item_craft.context_inds(graph, sort_info, node_key)) do
        table.insert(names, top.context_name(context))
    end
    table.sort(names)
    return table.concat(names, ", ")
end

-- Compares the full and the reduced graph of one logic build (made from the same data.raw with home_sets) and logs a REDUCTIONCHECK line; where says which call built them
-- Returns whether they agree
reduction_check.compare = function(full, reduced, home_sets, where)
    num_builds = num_builds + 1
    local problems = {}

    local expanded = table.deepcopy(reduced)
    local num_joined = reductions.expand_all(expanded)
    local structure_differences = differences(structure(full), structure(expanded))
    if #structure_differences > 0 then
        table.insert(problems, #structure_differences .. " differences (first: " .. structure_differences[1] .. ")")
    end

    local implied = top.implied_home_contexts
    top.implied_home_contexts = false
    local sizes = {}
    for _, option in pairs({
        {
            name = "simple",
            extra = {},
        },
        {
            name = "complex+home",
            extra = {
                complex_contexts = true,
                home_contexts = true,
                home_sets = home_sets or top.home_sets(reduced),
            },
        },
    }) do
        -- Copies, so these sorts never take a sort bootstrap offered for reuse (top.offer_reusable_sort)
        local full_sort = top.sort(table.deepcopy(full), nil, nil, table.deepcopy(option.extra))
        local reduced_sort = top.sort(table.deepcopy(reduced), nil, nil, table.deepcopy(option.extra))
        local differing = {}
        for node_key, _ in pairs(full.nodes) do
            local reduced_key = stand_in(node_key)
            if reduced.nodes[reduced_key] ~= nil or (reduced.item_craft_nodes or {})[reduced_key] ~= nil then
                local full_text = contexts_text(full, full_sort, node_key)
                local reduced_text = contexts_text(reduced, reduced_sort, reduced_key)
                if full_text ~= reduced_text then
                    table.insert(differing, node_key .. (reduced_key ~= node_key and (" (as " .. reduced_key .. ")") or "") .. " [" .. full_text .. "] vs [" .. reduced_text .. "]")
                end
            end
        end
        table.sort(differing)
        if #differing > 0 then
            table.insert(problems, option.name .. " sort: " .. #differing .. " nodes differ (first: " .. differing[1] .. ")")
        end
        table.insert(sizes, option.name .. " pebbles " .. #full_sort.pebble_keys .. " -> " .. #reduced_sort.pebble_keys)
    end
    top.implied_home_contexts = implied

    local num_full_nodes = 0
    for _, _ in pairs(full.nodes) do
        num_full_nodes = num_full_nodes + 1
    end
    local num_nodes = 0
    for _, _ in pairs(reduced.nodes) do
        num_nodes = num_nodes + 1
    end
    local summary = num_joined .. " joined edges, nodes " .. num_full_nodes .. " -> " .. num_nodes .. ", " .. table.concat(sizes, ", ")
    if #problems == 0 then
        log("REDUCTIONCHECK build " .. num_builds .. " (" .. where .. "): ok, " .. summary)
    else
        log("REDUCTIONCHECK build " .. num_builds .. " (" .. where .. "): FAILED, " .. table.concat(problems, "; ") .. "; " .. summary)
    end
    return #problems == 0
end

return reduction_check

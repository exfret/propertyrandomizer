local gutils = require("new-lib/graph/graph-utils")
local top = require("new-lib/graph/consistent-sort")
-- Used for getting contexts
local logic = require("new-lib/logic/init")

local test = {}

local test_graph
local sort_info

-- With automation science edge severed
local severed_graph
local severed_sort_info

test.init = function(graph)
    test_graph = table.deepcopy(graph)
    sort_info = top.sort(test_graph)
    
    severed_graph = table.deepcopy(graph)
    for _, edge in pairs(gutils.pres(graph, graph.nodes[gutils.key("item", "automation-science-pack")])) do
        gutils.sever(severed_graph, gutils.ekey(edge))
    end
    severed_sort_info = top.sort(severed_graph)
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
                    if sort_info.node_to_contexts[gutils.key(node)][context] then
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
    for _, node in pairs(test_graph.nodes) do
        if node.type == "technology" then
            local tech = data.raw.technology[node.name]
            if tech.unit ~= nil then
                local has_context = false
                for context, _ in pairs(logic.contexts) do
                    if sort_info.node_to_contexts[gutils.key(node)][context] then
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

-- TODO: Test for one context coming before another? (Like, some nauvis contexts coming before others)
-- TODO: Profiling/testing how well it puts things in a consistent manner

return test
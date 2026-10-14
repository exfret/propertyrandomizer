-- Keep branch nodes only where claiming or another consumer needs their independent identity.
local logic = require("src/logic/state")

local policy = {}

-- No claim calls here: they can consume copies, mark recipes or draw randomness.
-- Selection is checked without blacklists: ordinary claiming applies blacklists after its side effects.
policy.precheck = function(handlers, selected)
    return function(graph, edge)
        local prereq = graph.nodes[edge.start]
        local dep = graph.nodes[edge.stop]
        local info = logic.type_info[dep.type] or {}
        -- Production promises and temporary crafting options still query branch identities.
        -- Research inputs generate home contexts from the transformed branch, not the original source.
        if edge.item_craft == true or dep.type == "item-craft" or dep.craft_option_only == true or info.context ~= nil or info.research_input == true or info.home_carrier == true or info.relay == true then
            return true
        end
        for handler_id, handler in pairs(handlers) do
            if selected == nil or selected(handler_id, prereq, dep) then
                if handler.may_claim == nil or handler.may_claim(graph, prereq, dep, edge) then
                    return true
                end
            end
        end
        return false
    end
end

return policy

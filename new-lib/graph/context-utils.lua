-- Required for type info (this should probably be reorganized at some point)
local logic = require("new-lib/logic/init")

local contutils = {}

contutils.full_context = function()
    local contexts = {}
    for context, _ in pairs(logic.contexts) do
        contexts[context] = true
    end
    return contexts
end

contutils.context_list = function()
    local context_list = {}
    for context, _ in pairs(logic.contexts) do
        table.insert(context_list, context)
    end
    return context_list
end

-- Calculates what contexts are transmitted through a node when a given context is passed in
contutils.transmit = function(node, context)
    local context_type = logic.type_info[node.type].context
    if context_type == nil then
        return { context }
    elseif context_type == true then
        return contutils.context_list()
    elseif type(context_type) == "string" then
        -- Case of a room/set type context
        return { context_type }
    else
        -- Unhandled
        error()
    end
end

return contutils
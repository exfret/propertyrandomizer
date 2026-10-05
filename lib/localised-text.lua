-- Text construction shared by the data and control stages. Names are resolved by lib/locale.
local text = {}

text.get = function(key, ...)
    local result = {key}
    for index = 1, select("#", ...) do
        local value = select(index, ...)
        if type(value) ~= "table" and type(value) ~= "string" then
            value = tostring(value)
        end
        table.insert(result, value)
    end
    return result
end

-- Group wide lists without exceeding LocalisedString's 20-parameter limit.
text.join = function(parts, separator)
    local pieces = {}
    for index = 1, #parts do
        local part = parts[index]
        if index > 1 then
            table.insert(pieces, separator or "")
        end
        table.insert(pieces, part)
    end
    while #pieces > 20 do
        local groups = {}
        for index = 1, #pieces, 20 do
            local group = {""}
            for offset = index, math.min(index + 19, #pieces) do
                table.insert(group, pieces[offset])
            end
            table.insert(groups, group)
        end
        pieces = groups
    end
    local result = {""}
    for index = 1, #pieces do
        table.insert(result, pieces[index])
    end
    return result
end

-- Reasons retain readable English diagnostics for logs, alongside the player-facing locale.
text.reason = function(key, diagnostic, ...)
    return {
        diagnostic = diagnostic,
        message = text.get("propertyrandomizer-reason." .. key, ...),
    }
end

text.diagnostic = function(value)
    return type(value) == "table" and value.diagnostic or tostring(value)
end

text.message = function(value)
    return type(value) == "table" and value.message or value
end

return text

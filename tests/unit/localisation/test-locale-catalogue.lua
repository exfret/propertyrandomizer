-- Shared by standalone GUI tests. Unknown keys and raw prose must fail, even in English.
local catalogue = {}
local keys = {}
for _, path in pairs({"locale/en/locale.cfg", "locale/en/core.cfg"}) do
    local section
    for line in io.lines(path) do
        local heading = string.match(line, "^%[([^%]]+)%]$")
        if heading ~= nil then
            section = heading
        elseif not string.match(line, "^[#;]") then
            local key, value = string.match(line, "^([^=]+)=(.*)$")
            if key ~= nil then
                local name = section .. "." .. key
                assert(keys[name] == nil, "duplicate locale key: " .. name)
                keys[name] = value
            end
        end
    end
end

catalogue.keys = keys
catalogue.validate = function(value, depth)
    depth = depth or 0
    assert(depth <= 20, "GUI locale exceeds nesting limit")
    if type(value) == "table" then
        assert(type(value[1]) == "string" and #value <= 21, "invalid GUI locale")
        if value[1] == "" then
            for index = 2, #value do
                catalogue.validate(value[index], depth + 1)
            end
        elseif value[1] == "?" then
            -- Missing native tooltip entries are allowed when a translated fallback exists.
            local found = false
            for index = 2, #value do
                local branch = value[index]
                if type(branch) == "table" and keys[branch[1]] ~= nil then
                    catalogue.validate(branch, depth + 1)
                    found = true
                end
            end
            assert(found, "locale fallback has no translated branch")
        else
            assert(keys[value[1]] ~= nil, "missing locale key: " .. value[1])
            for parameter in string.gmatch(keys[value[1]], "__(%d+)__") do
                assert(value[tonumber(parameter) + 1] ~= nil, "missing locale parameter: " .. value[1])
            end
            for index = 2, #value do
                if type(value[index]) == "table" then
                    catalogue.validate(value[index], depth + 1)
                else
                    assert(type(value[index]) == "string" or type(value[index]) == "number", "invalid locale parameter")
                end
            end
        end
    else
        assert(type(value) == "string" and not string.match(value, "[%a\128-\255]"), "unlocalized GUI text: " .. tostring(value))
    end
end

catalogue.gui = function(element)
    if element.caption ~= nil then catalogue.validate(element.caption) end
    if element.tooltip ~= nil then catalogue.validate(element.tooltip) end
    for _, item in pairs(element.items or {}) do catalogue.validate(item) end
    for _, child in pairs(element.children) do catalogue.gui(child) end
end

return catalogue

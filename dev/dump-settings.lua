-- Prints the setting prototypes from settings.lua, one per line, for dev/run-tests.py
-- Fields are tab-separated: name, type, default_value, hidden, allowed_values (comma-separated), minimum_value, maximum_value
-- A field that isn't set is left empty
-- Run from the root of the mod copy whose settings you want: lua <path to>/dev/dump-settings.lua

local prototypes = {}
data = {
    extend = function(_, new_prototypes)
        for i = 1, #new_prototypes do
            table.insert(prototypes, new_prototypes[i])
        end
    end,
}
mods = {}

dofile("settings.lua")

local function field(value)
    if value == nil then
        return ""
    end
    return tostring(value)
end

for i = 1, #prototypes do
    local prototype = prototypes[i]
    local allowed_values = ""
    if prototype.allowed_values ~= nil then
        allowed_values = table.concat(prototype.allowed_values, ",")
    end
    print(table.concat({
        prototype.name,
        prototype.type,
        field(prototype.default_value),
        tostring(prototype.hidden == true),
        allowed_values,
        field(prototype.minimum_value),
        field(prototype.maximum_value),
    }, "\t"))
end

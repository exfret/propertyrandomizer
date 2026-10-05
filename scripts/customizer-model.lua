-- Serializable per-player drafts; no GUI objects or data-stage globals.
local customization = require("lib/customization")
local spec = require("helper-tables/spec")
local tuning = require("lib/random/tuning")
local constants = require("helper-tables/constants")

local model = {}

model.new = function(text)
    return {
        configuration = customization.parse(text),
        scope = "settings",
        group = "",
        query = "",
        import_text = "",
        import_open = false,
    }
end

local function target_entries(draft, target)
    local setting = string.match(target, "^setting/(.+)$")
    if setting ~= nil then
        return draft.configuration.settings, setting
    end
    return draft.configuration.randomizations, target
end

model.fields = function(draft, target)
    local entries, name = target_entries(draft, target)
    return entries[name] or {}
end

model.set = function(draft, target, field, value)
    if field == "enabled" then
        assert(value == nil or type(value) == "boolean")
    else
        assert(value == nil or tuning.valid_value(field, value))
    end
    local entries, name = target_entries(draft, target)
    entries[name] = entries[name] or {}
    entries[name][field] = value
    if next(entries[name]) == nil then
        entries[name] = nil
    end
end

model.reset = function(draft, target)
    if target == nil then
        draft.configuration.settings = {}
        draft.configuration.randomizations = {}
    else
        local entries, name = target_entries(draft, target)
        entries[name] = nil
    end
end

model.import = function(draft, text)
    local parsed = customization.parse(text)
    if #parsed.warnings > 0 then
        return false, parsed.warnings, parsed.localised_warnings
    end
    draft.configuration = parsed
    return true
end

model.export = function(draft)
    return customization.serialize(draft.configuration)
end

model.targets = function(draft, translated_name)
    local targets = {}
    local query = string.lower(draft.query)
    local function matches(id)
        local translated = translated_name ~= nil and translated_name(id) or ""
        return string.find(string.lower(id), query, 1, true) ~= nil
            or string.find(string.gsub(string.lower(id), "_", " "), query, 1, true) ~= nil
            or string.find(string.lower(translated), query, 1, true) ~= nil
    end
    if draft.scope == "settings" then
        for name, _ in pairs(customization.groups) do
            if matches(name) then
                table.insert(targets, "setting/" .. name)
            end
        end
    else
        for id, info in pairs(spec) do
            local setting = customization.setting_name(info)
            if info.category == "numerical" and (draft.group == "" or setting == draft.group or (draft.group == "ungrouped" and setting == nil)) and matches(id) then
                table.insert(targets, id)
            end
        end
    end
    table.sort(targets)
    return targets
end

-- The inherited value comes from the group or the currently loaded startup settings.
-- Built-in range and variance can differ between properties within one randomization.
model.inherited = function(draft, target, field, startup)
    local setting = string.match(target, "^setting/(.+)$")
    if setting == nil then
        local info = spec[target]
        setting = customization.setting_name(info)
        local group = draft.configuration.settings[setting] or {}
        if group[field] ~= nil then
            return group[field], "group"
        end
        if field == "enabled" then
            if setting == nil then
                return false, "startup"
            elseif type(info.setting) == "table" then
                return constants.setting_values[startup[setting].value] >= constants.setting_values[info.setting.val], "startup"
            end
            return startup[setting].value, "startup"
        end
    end
    if field == "bias" or field == "chaos" then
        return startup["propertyrandomizer-" .. field].value, "startup"
    end
    return nil, field == "enabled" and "startup" or "builtin"
end

return model

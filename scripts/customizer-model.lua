-- Serializable per-player drafts; no GUI objects or data-stage globals.
local customization = require("lib/customization")
local spec = require("helper-tables/spec")
local tuning = require("lib/random/tuning")
local graph_tuning = require("lib/graph-tuning")
local prototype_exclusions = require("lib/prototype-exclusions")
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
    local graph = string.match(target, "^graph/(.+)$")
    if graph ~= nil then
        draft.configuration.graph = draft.configuration.graph or {}
        return draft.configuration.graph, graph
    end
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
    local graph = graph_tuning.valid_target(target)
    if graph == true then
        assert(field ~= "enabled" and graph_tuning.supports(string.sub(target, 7), field))
        assert(value == nil or graph_tuning.valid_value(field, value))
    elseif field == "enabled" then
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
        draft.configuration.graph = {}
        draft.configuration.exclusions = {}
        draft.configuration.prototype_exclusions = {}
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
    if draft.scope == "exclusions" then
        for _, scope in pairs({
            "all",
            "numerical/all",
            "graph/all",
        }) do
            if matches(scope) then table.insert(targets, scope) end
        end
        for id, _ in pairs(prototype_exclusions.graph_targets) do
            if matches("graph/" .. id) then table.insert(targets, "graph/" .. id) end
        end
        for id, info in pairs(spec) do
            if info.category ~= "unified" and matches("randomization/" .. id) then table.insert(targets, "randomization/" .. id) end
        end
    elseif draft.scope == "graph" then
        for id, _ in pairs(graph_tuning.targets) do
            if matches(id) then
                table.insert(targets, "graph/" .. id)
            end
        end
        if matches("all") then
            table.insert(targets, "graph/all")
        end
    elseif draft.scope == "settings" then
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
    if graph_tuning.valid_target(target) then
        if target ~= "graph/all" and ((draft.configuration.graph or {}).all or {})[field] ~= nil then
            return draft.configuration.graph.all[field], "graph"
        end
        return graph_tuning.default(field), "builtin"
    end
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

model.exclude = function(draft, target, selector, enabled)
    assert(prototype_exclusions.valid_scope(target) and graph_tuning.valid_selector(selector))
    local graph = string.match(target, "^graph/(.+)$")
    local key = graph ~= nil and "exclusions" or "prototype_exclusions"
    local id = graph or target
    draft.configuration[key] = draft.configuration[key] or {}
    draft.configuration[key][id] = draft.configuration[key][id] or {}
    draft.configuration[key][id][selector] = enabled == true and true or nil
end

model.exclusions = function(draft, scope)
    local graph = string.match(scope or "", "^graph/(.+)$")
    return graph ~= nil and ((draft.configuration.exclusions or {})[graph] or {})
        or ((draft.configuration.prototype_exclusions or {})[scope] or {})
end

model.reset_exclusions = function(draft, scope)
    assert(prototype_exclusions.valid_scope(scope))
    local graph = string.match(scope, "^graph/(.+)$")
    if graph ~= nil then
        (draft.configuration.exclusions or {})[graph] = nil
    else
        (draft.configuration.prototype_exclusions or {})[scope] = nil
    end
end

return model

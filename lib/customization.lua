-- Engine-independent override parsing and per-field inheritance.
local spec = require("helper-tables/spec")
local localised_text = require("lib/localised-text")
local tuning = require("lib/random/tuning")
local graph_tuning = require("lib/graph-tuning")
local prototype_exclusions = require("lib/prototype-exclusions")

local customization = {}

customization.setting_name = function(info)
    if type(info.setting) == "table" then
        return info.setting.name
    elseif type(info.setting) == "string" and info.setting ~= "none" then
        return info.setting
    end
end

customization.groups = {}
for id, info in pairs(spec) do
    local name = customization.setting_name(info)
    if info.category == "numerical" and name ~= nil then
        customization.groups[name] = customization.groups[name] or {}
        table.insert(customization.groups[name], id)
    end
end
for _, members in pairs(customization.groups) do
    table.sort(members)
end

local function target_info(state, target)
    local name = string.match(target, "^setting/(.+)$")
    if name ~= nil then
        if customization.groups[name] == nil then
            return nil, "Unknown randomization setting group: " .. target, localised_text.get("propertyrandomizer-warning.unknown-group", target)
        end
        return state.settings, name
    end
    if spec[target] == nil or spec[target].category ~= "numerical" then
        return nil, "Unknown or unsupported numerical randomization: " .. target, localised_text.get("propertyrandomizer-warning.unknown-randomization", target)
    end
    return state.randomizations, target
end

local function parse_graph(state, instruction, target)
    local field, value
    local warning
    if instruction == "PARAM" then
        target, field, value = string.match(target, "^([^.=]+)%.([%w_]+)=([^=]+)$")
        if target == nil or not graph_tuning.valid_value(field, value) and value ~= "inherit" then
            warning = "Invalid graph parameter"
        end
    elseif instruction ~= "INHERIT" then
        warning = "Graph controls use PARAM, EXCLUDE, INCLUDE or INHERIT"
    end
    if not graph_tuning.valid_target(target) and not (instruction == "INHERIT" and prototype_exclusions.valid_scope(target)) then
        warning = "Unknown graph randomization target"
    end
    local id = target ~= nil and string.match(target, "^graph/(.+)$") or nil
    if field ~= nil and (graph_tuning.parameters[field] == nil or not graph_tuning.supports(id, field)) then
        warning = "Unsupported graph parameter for this target"
    end
    if warning ~= nil then
        return warning
    end
    if instruction == "INHERIT" then
        state.graph[id] = nil
        state.exclusions[id] = nil
    else
        state.graph[id] = state.graph[id] or {}
        state.graph[id][field] = value ~= "inherit" and value or nil
    end
end

customization.parse = function(text)
    local state = {
        settings = {},
        randomizations = {},
        graph = {},
        exclusions = {},
        prototype_exclusions = {},
        warnings = {},
        localised_warnings = {},
        postfixes = {},
        unrecognized = {},
    }
    for raw in string.gmatch(text, "[^;]+") do
        local instruction, target = string.match(raw, "^([^:]+):(.*)$")
        if instruction == nil then
            instruction = "ON"
            target = raw
            if string.sub(raw, 1, 1) == "!" then
                instruction = "OFF"
                target = string.sub(raw, 2)
            end
        end
        -- Prototype post-processing stays in config.lua, after randomization.
        if instruction == "SET" or instruction == "RESET" then
            table.insert(state.postfixes, raw)
        elseif instruction == "EXCLUDE" or instruction == "INCLUDE" then
            local scope, selector = string.match(target, "^([^:]+):(.+)$")
            if not prototype_exclusions.valid_scope(scope) or not graph_tuning.valid_selector(selector) then
                table.insert(state.warnings, "Invalid prototype exclusion; override skipped: " .. raw)
                table.insert(state.localised_warnings, {
                    "propertyrandomizer-warning.exclusion-override",
                    raw,
                })
                table.insert(state.unrecognized, raw)
            else
                local entries = state.prototype_exclusions
                local graph = string.match(scope, "^graph/(.+)$")
                if graph ~= nil then
                    entries = state.exclusions
                    scope = graph
                end
                entries[scope] = entries[scope] or {}
                entries[scope][selector] = instruction == "EXCLUDE" and true or nil
            end
        elseif string.sub(target, 1, 6) == "graph/" then
            local warning = parse_graph(state, instruction, target)
            if warning ~= nil then
                table.insert(state.warnings, warning .. "; override skipped: " .. raw)
                table.insert(state.localised_warnings, {
                    "propertyrandomizer-warning.graph-override",
                    raw,
                })
                table.insert(state.unrecognized, raw)
            end
        else
            local parameter, value
            local warning
            local warning_locale
            if instruction == "PARAM" then
                target, parameter, value = string.match(target, "^([^.=]+)%.([%w_]+)=([^=]+)$")
                if target == nil then
                    warning = "Expected PARAM:target.parameter=value"
                    warning_locale = localised_text.get("propertyrandomizer-warning.parameter-syntax")
                elseif not tuning.valid_value(parameter, value) and value ~= "inherit" then
                    warning = "Unknown parameter or invalid value: " .. parameter .. "=" .. value
                    warning_locale = localised_text.get("propertyrandomizer-warning.parameter-value", parameter, value)
                elseif tuning.parameters[parameter] == nil then
                    warning = "Unknown parameter: " .. parameter
                    warning_locale = localised_text.get("propertyrandomizer-warning.parameter-unknown", parameter)
                end
            elseif instruction ~= "ON" and instruction ~= "OFF" and instruction ~= "INHERIT" then
                warning = "Unrecognized instruction: " .. instruction
                warning_locale = localised_text.get("propertyrandomizer-warning.instruction-unknown", instruction)
            end
            local entries, name
            if warning == nil then
                entries, name, warning_locale = target_info(state, target)
                if entries == nil then
                    warning = name
                elseif parameter ~= nil and entries == state.randomizations and spec[name].tuning == false then
                    warning = "This randomization has no numerical tuning parameters: " .. name
                    warning_locale = localised_text.get("propertyrandomizer-warning.tuning-unsupported", name)
                end
            end
            if warning ~= nil then
                table.insert(state.warnings, warning .. "; override skipped: " .. raw)
                table.insert(state.localised_warnings, {"propertyrandomizer-warning.override-skipped", warning_locale, raw})
                table.insert(state.unrecognized, raw)
            elseif instruction == "INHERIT" then
                entries[name] = nil
            else
                entries[name] = entries[name] or {}
                if instruction == "PARAM" then
                    if value == "inherit" then
                        entries[name][parameter] = nil
                    else
                        entries[name][parameter] = value
                    end
                else
                    entries[name].enabled = instruction == "ON"
                end
            end
        end
    end
    return state
end

customization.resolve = function(state, id)
    local resolved = {}
    local info = spec[id]
    if state == nil or info == nil then
        return resolved
    end
    local setting = customization.setting_name(info)
    local group = state.settings[setting] or {}
    local individual = state.randomizations[id] or {}
    for key, value in pairs(group) do
        if key == "enabled" or info.tuning ~= false then
            resolved[key] = value
        end
    end
    for key, value in pairs(individual) do
        resolved[key] = value
    end
    return resolved
end

-- Canonical order keeps exports stable when a dropdown is changed and restored.
-- Post-processing retains its original relative order, and existing rejected instructions are preserved.
customization.serialize = function(state)
    local instructions = {}
    local parameters = tuning.parameter_order
    local function emit(entries, prefix, fields_to_emit)
        local names = {}
        for name, _ in pairs(entries) do
            table.insert(names, name)
        end
        table.sort(names)
        for _, name in pairs(names) do
            local target = prefix .. name
            local fields = entries[name]
            if fields.enabled ~= nil then
                table.insert(instructions, (fields.enabled == true and "ON:" or "OFF:") .. target)
            end
            for _, field in pairs(fields_to_emit or parameters) do
                if fields[field] ~= nil then
                    table.insert(instructions, "PARAM:" .. target .. "." .. field .. "=" .. fields[field])
                end
            end
        end
    end
    emit(state.settings, "setting/")
    emit(state.randomizations, "")
    emit(state.graph or {}, "graph/", graph_tuning.parameter_order)
    local exclusions = {}
    for id, selectors in pairs(state.exclusions or {}) do
        for selector, enabled in pairs(selectors) do
            if enabled == true then
                table.insert(exclusions, "EXCLUDE:graph/" .. id .. ":" .. selector)
            end
        end
    end
    for scope, selectors in pairs(state.prototype_exclusions or {}) do
        for selector, enabled in pairs(selectors) do
            if enabled == true then
                table.insert(exclusions, "EXCLUDE:" .. scope .. ":" .. selector)
            end
        end
    end
    table.sort(exclusions)
    for _, instruction in pairs(exclusions) do
        table.insert(instructions, instruction)
    end
    for _, raw in pairs(state.postfixes or {}) do
        table.insert(instructions, raw)
    end
    for _, raw in pairs(state.unrecognized or {}) do
        table.insert(instructions, raw)
    end
    return table.concat(instructions, ";")
end

return customization

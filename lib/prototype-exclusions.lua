-- Exclusion scopes are independent of parameter overrides and derive targets from the mod's registry.
local spec = require("helper-tables/spec")
local graph_tuning = require("lib/graph-tuning")
local catalog = require("lib/prototype-catalog")
local handler_ids = require("helper-tables/handler-ids")

local exclusions = {}
local state = {}
local raw = {}
local entries = {}
local cache = {}
local classes = {}
local class_by_kind = {}
local active

exclusions.graph_targets = {}
for id, _ in pairs(graph_tuning.targets) do exclusions.graph_targets[id] = true end
for _, id in pairs(handler_ids) do exclusions.graph_targets[id] = true end
for _, info in pairs(spec) do
    if info.handler ~= nil then exclusions.graph_targets[info.handler] = true end
end

-- Public spec names and the older graph entry points differ.
local legacy_ids = {
    recipe_ingredients = "recipe_ingredients",
    recipe_tech_unlock = "recipe_unlocks",
    technology_tree_insnipping = "technology_prerequisites",
    all_icons = "icons",
    all_sounds = "sounds",
    all_names = "localised_names",
}

exclusions.valid_scope = function(scope)
    if scope == "all" or scope == "numerical/all" or scope == "graph/all" then
        return true
    end
    local graph = string.match(scope or "", "^graph/(.+)$")
    if graph ~= nil and exclusions.graph_targets[graph] == true then
        return true
    end
    local id = string.match(scope or "", "^randomization/(.+)$")
    return id ~= nil and spec[id] ~= nil
end

exclusions.selectors = function(configuration, id, category)
    local result = {}
    local scopes = configuration.prototype_exclusions or {}
    local function add(selectors)
        for selector, enabled in pairs(selectors or {}) do
            if enabled == true then result[selector] = true end
        end
    end
    add(scopes.all)
    add(scopes[category .. "/all"])
    local canonical = legacy_ids[id] or id
    add(scopes["randomization/" .. canonical])
    if category == "graph" then
        add((configuration.exclusions or {}).all)
        add((configuration.exclusions or {})[id])
        add(scopes["graph/" .. id])
        for name, info in pairs(spec) do
            if info.handler == id then add(scopes["randomization/" .. name]) end
        end
    end
    return result
end

exclusions.initialize = function(configuration, data_raw, prototype_classes, baseline_raw)
    state = configuration or {}
    raw = data_raw or {}
    entries = catalog.build(baseline_raw or raw, prototype_classes)
    cache = {}
    classes = prototype_classes or {}
    class_by_kind = {}
    for class, kinds in pairs(classes) do
        for kind, _ in pairs(kinds) do class_by_kind[kind] = class end
    end
    active = nil
end

exclusions.unmatched = function(configuration, catalogue)
    local result = {}
    local function check(scope, selectors)
        for selector, _ in pairs(selectors) do
            local found = false
            for _, entry in pairs(catalogue) do
                if catalog.matches(entry, selector) then found = true; break end
            end
            if not found then table.insert(result, scope .. ":" .. selector) end
        end
    end
    for scope, selectors in pairs((configuration or state).prototype_exclusions or {}) do check(scope, selectors) end
    for id, selectors in pairs((configuration or state).exclusions or {}) do check("graph/" .. id, selectors) end
    table.sort(result)
    return result
end

local function blocked(id, category)
    local cache_key = category .. "/" .. id
    if cache[cache_key] ~= nil then return cache[cache_key] end
    local result = {}
    local selectors = exclusions.selectors(state, id, category)
    if next(selectors) ~= nil then
        for _, entry in pairs(entries) do
            for selector, _ in pairs(selectors) do
                if catalog.matches(entry, selector) then
                    result[entry.key] = entry
                    result[entry.class .. ": " .. entry.name] = entry
                end
            end
        end
    end
    cache[cache_key] = result
    return result
end

exclusions.excluded = function(id, category, prototype)
    if prototype == nil then return false end
    local keys = blocked(id, category)
    if prototype.prot ~= nil and keys[prototype.prot] ~= nil then return true end
    local kind, name = string.match(prototype.prot or "", "^([^:]+): (.+)$")
    kind, name = prototype.type or prototype.class or kind, prototype.name or name
    if kind == nil or name == nil then return false end
    return keys[kind .. ": " .. name] ~= nil or keys[(class_by_kind[kind] or kind) .. ": " .. name] ~= nil
end

exclusions.active_excluded = function(prototype)
    return active ~= nil and exclusions.excluded(active.id, active.category, prototype)
end

-- Numerical and cosmetic passes have direct and indirect writes, not only randnum calls.
-- Preserve only matching prototypes from immediately before each pass, retaining earlier graph changes.
exclusions.run = function(id, category, callback)
    local saved = {}
    for prototype_key, entry in pairs(blocked(id, category)) do
        if prototype_key == entry.key then
            local kind = entry.kind
            if raw[kind] == nil or raw[kind][entry.name] == nil then
                for candidate, _ in pairs(classes[entry.class] or {}) do
                    if raw[candidate] ~= nil and raw[candidate][entry.name] ~= nil then kind = candidate; break end
                end
            end
            if raw[kind] ~= nil and raw[kind][entry.name] ~= nil then
                table.insert(saved, {
                    entry = entry,
                    kind = kind,
                    prototype = raw[kind][entry.name],
                    value = table.deepcopy(raw[kind][entry.name]),
                })
            end
        end
    end
    local previous = active
    active = {
        id = id,
        category = category,
    }
    local result = callback()
    active = previous
    for _, snapshot in pairs(saved) do
        local entry = snapshot.entry
        local prototype = snapshot.prototype
        for kind, _ in pairs(classes[entry.class] or {}) do
            if kind ~= snapshot.kind and raw[kind] ~= nil then raw[kind][entry.name] = nil end
        end
        for property, _ in pairs(prototype) do prototype[property] = nil end
        for property, value in pairs(snapshot.value) do prototype[property] = value end
        raw[snapshot.kind][entry.name] = prototype
    end
    return result
end

return exclusions

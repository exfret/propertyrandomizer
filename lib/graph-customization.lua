-- Graph policy uses prototype metadata, never a list of vanilla prototype names.
local tuning = require("lib/graph-tuning")
local constants = require("helper-tables/constants")
local prototype_catalog = require("lib/prototype-catalog")
local prototype_exclusions = require("lib/prototype-exclusions")

local policy = {}
local state = {}
local raw = {}
local seed = 0
local catalog = {}
local blocked = {}
local resolved = {}
local statistics = {}
local prototype_lookup = {}

local function key(kind, name)
    return kind .. ": " .. name
end

policy.catalog = prototype_catalog.build

policy.initialize = function(configuration, data_raw, prototype_classes, random_seed, prototype_metadata)
    state = configuration or {}
    raw = data_raw or {}
    seed = random_seed or 0
    catalog = prototype_metadata or policy.catalog(raw, prototype_classes)
    blocked = {}
    resolved = {}
    statistics = {}
    prototype_lookup = {}
    for _, entry in pairs(catalog) do
        prototype_lookup[entry.key] = entry
        prototype_lookup[key(entry.class, entry.name)] = entry
    end
end

policy.unmatched = function()
    return prototype_exclusions.unmatched(state, catalog)
end

policy.fields = function(id)
    if resolved[id] == nil then
        resolved[id] = tuning.resolve(state, id)
    end
    return resolved[id]
end


local function exclusions(id)
    if blocked[id] ~= nil then
        return blocked[id]
    end
    local result = {}
    local selectors = prototype_exclusions.selectors(state, id, "graph")
    if next(selectors) == nil then
        blocked[id] = result
        return result
    end
    for _, entry in pairs(catalog) do
        for selector, _ in pairs(selectors) do
            if prototype_catalog.matches(entry, selector) then
                result[entry.key] = true
                result[key(entry.class, entry.name)] = true
            end
        end
    end
    -- Protect the identities referred to by a fixed recipe and the placing relationship of a fixed item or entity, without freezing supply chains.
    local additions = {}
    for _, entry in pairs(catalog) do
        local prototype = (raw[entry.kind] or {})[entry.name]
        if prototype ~= nil and result[entry.key] == true then
            if entry.class == "recipe" then
                for _, ingredient in pairs(prototype.ingredients or {}) do
                    additions[key(ingredient.type or "item", ingredient.name or ingredient[1])] = true
                end
                for _, product in pairs(prototype.results or {}) do
                    additions[key(product.type or "item", product.name or product[1])] = true
                end
            elseif entry.class == "item" and prototype.place_result ~= nil then
                additions[key("entity", prototype.place_result)] = true
            end
        end
        if prototype ~= nil and entry.class == "item" and prototype.place_result ~= nil and result[key("entity", prototype.place_result)] == true then
            additions[entry.key] = true
            additions[key(entry.class, entry.name)] = true
        end
    end
    for name, _ in pairs(additions) do
        result[name] = true
    end
    -- Include every placing item when a protected item introduced its entity above.
    for _, entry in pairs(catalog) do
        local prototype = (raw[entry.kind] or {})[entry.name]
        if prototype ~= nil and entry.class == "item" and prototype.place_result ~= nil and result[key("entity", prototype.place_result)] == true then
            result[entry.key] = true
            result[key(entry.class, entry.name)] = true
        end
    end
    -- Metadata names both concrete prototype types and their top-level class.
    for _, entry in pairs(catalog) do
        if result[key(entry.class, entry.name)] == true then
            result[entry.key] = true
        end
    end
    blocked[id] = result
    return result
end

policy.excluded = function(id, node)
    if node == nil then
        return false
    end
    local entries = exclusions(id)
    return entries[node.prot or key(node.type, node.name)] == true
        or entries[key(node.class or node.type, node.name)] == true
end

-- A fixed prototype's material references must not be renamed by item reflection.
-- The graph declares ownership with node.prot, covering operating inputs, mining products, recipe outputs and research inputs without type lists.
policy.protect_references = function(graph, id)
    id = id or "item"
    local entries = exclusions(id)
    if next(entries) == nil then
        return
    end
    local material_keys = {}
    for _, entry in pairs(catalog) do
        if entry.class == "item" or entry.class == "fluid" then
            material_keys[entry.key] = key(entry.class, entry.name)
        end
    end
    local additions = {}
    for _, edge in pairs(graph.edges) do
        local start = graph.nodes[edge.start]
        local stop = graph.nodes[edge.stop]
        if policy.excluded(id, start) and stop.prot ~= nil and material_keys[stop.prot] ~= nil then
            additions[stop.prot] = true
            additions[material_keys[stop.prot]] = true
        end
        if policy.excluded(id, stop) and start.prot ~= nil and material_keys[start.prot] ~= nil then
            additions[start.prot] = true
            additions[material_keys[start.prot]] = true
        end
    end
    for prototype_key, _ in pairs(additions) do
        entries[prototype_key] = true
    end
end

-- Sampling has its own stable seed and does not consume existing RNG streams.
-- A dependent's edges share one draw, and the decision survives unified retries.
policy.selected = function(id, node)
    local name = node.prot or key(node.type, node.name)
    name = prototype_lookup[name] ~= nil and prototype_lookup[name].key or name
    statistics[id] = statistics[id] or {}
    if statistics[id][name] ~= nil then
        return statistics[id][name]
    end
    local selected = not policy.excluded(id, node)
    local amount = tonumber(policy.fields(id).amount) or 100
    if amount == 0 then
        selected = false
    elseif selected and amount < 100 then
        local selection_key = id .. "/" .. name
        local hash = 0
        for char in string.gmatch(tostring(seed) .. "/" .. selection_key, ".") do
            hash = (hash * 131 + string.byte(char)) % 1000003
        end
        selected = hash % 10000 < amount * 100
    end
    statistics[id][name] = selected
    return selected
end

policy.report = function()
    local lines = {}
    for id, targets in pairs(statistics) do
        local count, total = 0, 0
        for _, selected in pairs(targets) do
            total = total + 1
            if selected then count = count + 1 end
        end
        table.insert(lines, "GRAPHCUSTOM " .. id .. " selected=" .. count .. " total=" .. total .. " amount=" .. (policy.fields(id).amount or "100"))
    end
    table.sort(lines)
    return lines
end

-- Reflection must never rename a protected material or a target not selected for item randomization; both sides of each assignment have to stay selected.
policy.check_material_renames = function(renames)
    local failures = {}
    for position, identity in pairs(renames or {}) do
        local kind, name = string.match(position, "^([^:]+): (.+)$")
        if name ~= identity.name or kind ~= identity.type then
            if not policy.selected("item", {
                type = kind,
                name = name,
            }) or not policy.selected("item", identity) then
                table.insert(failures, position)
            end
        end
    end
    table.sort(failures)
    return failures
end

policy.shape = function()
    local result = {}
    for field, value in pairs(constants.recipe_shape) do
        result[field] = value
    end
    local fields = policy.fields("recipe-ingredients")
    result.count_range = fields.ingredient_count or result.count_range
    if fields.fluids == "preserve" then
        result.fluid_gain_chance = 0
        result.fluid_loss_chance = 0
    elseif fields.fluids == "less" then
        result.fluid_gain_chance = result.fluid_gain_chance / 4
        result.fluid_loss_chance = math.min(1 - result.fluid_gain_chance, result.fluid_loss_chance * 3)
    elseif fields.fluids == "more" then
        result.fluid_gain_chance = math.min(0.8, result.fluid_gain_chance * 2)
        result.fluid_loss_chance = result.fluid_loss_chance / 2
    end
    return result
end

return policy

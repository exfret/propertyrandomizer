-- Resistance arrays and rows may be shared by several prototypes.
-- Connected ownership groups are mutated together, retaining the original table identities.

local damage = require("src/prototypes/combat/combat-damage")
local targets = require("src/prototypes/combat/combat-targets")
local experimental_flags = require("src/config/experimental-flags")

local resistances = {}

local function finite(value)
    return type(value) == "number" and value > -math.huge and value < math.huge
end

local function keys(values)
    local result = {}
    for key, _ in pairs(values or {}) do
        table.insert(result, key)
    end
    table.sort(result)
    return result
end

-- This conservative implementation supports nonnegative flat / 0..100 percentage values.
-- Resistance components default to zero; type is required.
-- https://lua-api.factorio.com/latest/types/Resistance.html
resistances.collect = function(entities, damage_types, selected, raw)
    if experimental_flags.military_resistances ~= true then return {} end
    local arrays, ordered, row_owner = {}, {}, {}
    local owners, primary, seen_owners = {}, {}, {}
    local function add_owner(prototype)
        if type(prototype) == "table" and type(prototype.resistances) == "table" and seen_owners[prototype] == nil then
            seen_owners[prototype] = true
            table.insert(owners, prototype)
        end
    end
    for _, prototype in pairs(entities or {}) do
        primary[prototype] = true
        add_owner(prototype)
    end
    -- Other prototype classes can own Resistance arrays too, such as ArmorPrototype.
    -- Discover them from the registry so an out-of-scope alias protects its entire shared component.
    for _, prototypes in pairs(raw or {}) do
        for _, prototype in pairs(prototypes) do
            add_owner(prototype)
        end
    end
    table.sort(owners, function(a, b)
        return a.type .. ": " .. a.name < b.type .. ": " .. b.name
    end)
    local function root(node)
        if node.parent ~= node then
            node.parent = root(node.parent)
        end
        return node.parent
    end
    for _, prototype in pairs(owners) do
        local array = prototype.resistances
        local node = arrays[array]
        if node == nil then
            node = {
                array = array,
                prototypes = {},
                order = #ordered + 1,
            }
            node.parent = node
            arrays[array] = node
            table.insert(ordered, node)
            local seen_types = {}
            for index, row in pairs(array) do
                if type(index) ~= "number" or index < 1 or index % 1 ~= 0 or type(row) ~= "table" then
                    node.blocked = true
                else
                    local previous = row_owner[row]
                    if previous ~= nil then
                        local a, b = root(node), root(previous)
                        if a.order < b.order then b.parent = a else a.parent = b end
                    else
                        row_owner[row] = node
                    end
                    local decrease, percent = row.decrease, row.percent
                    if decrease == nil then decrease = 0 end
                    if percent == nil then percent = 0 end
                    if type(row.type) ~= "string" or damage_types[row.type] == nil or seen_types[row.type]
                        or not finite(decrease) or decrease < 0 or not finite(percent) or percent < 0 or percent > 100 then
                        node.blocked = true
                    end
                    if type(row.type) == "string" then
                        seen_types[row.type] = true
                    end
                end
            end
        end
        table.insert(node.prototypes, prototype)
        if primary[prototype] ~= true or (selected ~= nil and selected(prototype) ~= true) then
            node.blocked = true
        end
    end
    local by_root, groups = {}, {}
    for _, node in pairs(ordered) do
        local leader = root(node)
        local group = by_root[leader]
        if group == nil then
            group = {
                prototype = node.prototypes[1],
                prototypes = {},
                entries = {},
                entry_set = {},
                immune_types = {},
            }
            by_root[leader] = group
            table.insert(groups, group)
        end
        group.blocked = group.blocked or node.blocked
        for _, prototype in pairs(node.prototypes) do
            table.insert(group.prototypes, prototype)
        end
        for _, row in pairs(node.array) do
            if type(row) == "table" and group.entry_set[row] == nil then
                group.entry_set[row] = true
                table.insert(group.entries, row)
                if row.percent == 100 and type(row.type) == "string" then
                    group.immune_types[row.type] = true
                end
            end
        end
    end
    local result = {}
    for _, group in pairs(groups) do
        if not group.blocked and #group.entries > 0 then
            group.types = {}
            for _, name in pairs(keys(damage_types)) do
                if group.immune_types[name] == nil then
                    table.insert(group.types, name)
                end
            end
            group.can_permute = false
            for _, row in pairs(group.entries) do
                if #group.types > 1 and group.immune_types[row.type] == nil and ((row.decrease or 0) > 0 or (row.percent or 0) > 0) then
                    group.can_permute = true
                end
            end
            group.entry_set = nil
            table.insert(result, group)
        end
    end
    return result
end

-- Include descendants and shared-health body parts, not only the visible roots of each roster.
-- A failure leaves classification unknown; callers keep every group independent in that case.
resistances.target_set = function(definitions, entities, raw)
    if experimental_flags.military_resistances ~= true then return {} end
    raw = raw or {}
    local by_name, names = {}, {}
    for key, prototype in pairs(entities or {}) do
        local name = prototype.name or key
        if type(name) ~= "string" then return nil, "unnamed-target-prototype" end
        by_name[name], names[prototype] = prototype, name
    end
    local function entity_of(name) return by_name[name] end
    local resolver = damage.new({
        entity_of = entity_of,
        particle_of = function(name) return (raw["optimized-particle"] or {})[name] end,
        impact_effects = raw["deliver-impact-combination"],
        tile_effects = raw.tile,
        decorative_effects = raw["optimized-decorative"],
    })
    local workload_resolver = targets.new(by_name, {
        entity_of = entity_of,
        visual_effect = resolver.visual_effect,
        visual_entity = resolver.visual_entity,
    })
    local result = {}
    for _, definition in pairs(definitions or {}) do
        local workload, reason = workload_resolver.workload(definition.targets)
        if workload == nil then return nil, reason end
        for _, target in pairs(workload) do
            result[target.entity] = true
            for _, part in pairs(target.parts) do result[names[part]] = true end
        end
    end
    return result
end

-- These are randomization priorities, not a replacement for the engine's military-target defaults.
-- Wall/gate membership comes from their actual registries; optional graphics cannot identify every barrier.
resistances.partition = function(groups, options)
    if experimental_flags.military_resistances ~= true then
        return {
            sensitive = {},
            ordinary = {},
        }
    end
    options = options or {}
    local raw = options.raw or {}
    local sensitive_entities = options.sensitive_entities or {}
    local barriers = {}
    for _, prototype in pairs(raw.wall or {}) do barriers[prototype] = true end
    for _, prototype in pairs(raw.gate or {}) do barriers[prototype] = true end
    local result = {
        sensitive = {},
        ordinary = {},
    }
    local batches = {}
    for _, group in pairs(groups) do
        local sensitive = options.all_sensitive == true
        for _, prototype in pairs(group.prototypes) do
            sensitive = sensitive or barriers[prototype] == true
                or sensitive_entities[prototype] == true or sensitive_entities[prototype.name] == true
                or prototype.is_military_target == true or prototype.attack_parameters ~= nil
                or prototype.revenge_attack_parameters ~= nil or prototype.gun ~= nil
                or prototype.result_units ~= nil
                or type(prototype.guns) == "table" and next(prototype.guns) ~= nil
        end
        if sensitive then
            table.insert(result.sensitive, group)
        else
            local signature = ""
            for _, name in pairs(keys(group.immune_types)) do
                signature = signature .. #name .. ":" .. name
            end
            local batch = batches[signature]
            if batch == nil then
                batch = {
                    prototype = group.prototype,
                    prototypes = {},
                    entries = {},
                    immune_types = group.immune_types,
                    types = group.types,
                    can_permute = false,
                    groups = {},
                }
                batches[signature] = batch
                table.insert(result.ordinary, batch)
            end
            table.insert(batch.groups, group)
            batch.can_permute = batch.can_permute or group.can_permute
            for _, prototype in pairs(group.prototypes) do table.insert(batch.prototypes, prototype) end
            for _, row in pairs(group.entries) do table.insert(batch.entries, row) end
        end
    end
    return result
end

local function mapping_for(group, permutation)
    if not group.can_permute or #permutation ~= #group.types then
        return nil
    end
    local allowed, assigned, mapping = {}, {}, {}
    for _, name in pairs(group.types) do allowed[name] = true end
    for index, name in pairs(permutation) do
        if allowed[name] ~= true or assigned[name] ~= nil or group.types[index] == nil then
            return nil
        end
        assigned[name] = true
        mapping[group.types[index]] = name
    end
    return mapping
end

-- Several ordinary batches share one promotion transaction, while their different immune labels stay fixed.
resistances.attempt_batch = function(proposals, evaluate, commit)
    if experimental_flags.military_resistances ~= true then return false end
    local previous, assigned, differs = {}, {}, false
    for _, proposal in pairs(proposals) do
        local mapping = mapping_for(proposal.group, proposal.permutation)
        if mapping == nil then return false end
        for _, row in pairs(proposal.group.entries) do
            local new_type = mapping[row.type] or row.type
            if assigned[row] ~= nil and assigned[row] ~= new_type then return false end
            previous[row] = row.type
            assigned[row] = new_type
            differs = differs or new_type ~= row.type
        end
    end
    if not differs then
        return false
    end
    for row, new_type in pairs(assigned) do
        row.type = new_type
    end
    local okay, accepted = pcall(function()
        return commit(evaluate()) == true
    end)
    if okay ~= true or accepted ~= true then
        for row, old_type in pairs(previous) do row.type = old_type end
    end
    if okay ~= true then error(accepted) end
    return accepted
end

-- Apply a bijection to every shared row. Immune type labels are outside the permutation.
resistances.attempt = function(group, permutation, evaluate, commit)
    return resistances.attempt_batch({
        {
            group = group,
            permutation = permutation,
        },
    }, evaluate, commit)
end

return resistances

-- Shared resources get a separate entity for each planet placement, including the planets made by dupes.
-- Each copy uses the placement's existing settings and noise expressions; no items or patch sets are added.

local constants = require("helper-tables/constants")
local locale = require("lib/locale")
local lutils = require("lib/logic/logic-utils")
local wild = require("lib/wild-entities")

local variants = {}

local function sorted_keys(tbl)
    local keys = {}
    for name, _ in pairs(tbl or {}) do
        table.insert(keys, name)
    end
    table.sort(keys)
    return keys
end

variants.execute = function()
    local planets = sorted_keys(data.raw.planet)
    -- Keep the original entity on the starting planet when it occurs there.
    for i, name in pairs(planets) do
        if name == constants.starting_planet then
            table.remove(planets, i)
            table.insert(planets, 1, name)
            break
        end
    end
    local copies = {}
    for _, resource_name in pairs(sorted_keys(data.raw.resource)) do
        local resource = data.raw.resource[resource_name]
        local homes = {}
        if resource.autoplace ~= nil then
            for _, planet_name in pairs(planets) do
                local planet = data.raw.planet[planet_name]
                if lutils.check_in_room(planet, resource) then
                    table.insert(homes, planet_name)
                end
            end
        end
        for i = 2, #homes do
            local planet = data.raw.planet[homes[i]]
            local copy = table.deepcopy(resource)
            local stem = resource_name .. "-propertyrandomizer-" .. planet.name .. "-resource-copy"
            copy.name = stem
            local suffix = 1
            while data.raw.resource[copy.name] ~= nil do
                suffix = suffix + 1
                copy.name = stem .. "-" .. suffix
            end
            copy.localised_name = locale.find_localised_name(resource)
            data:extend({ copy })
            copies[resource_name] = copies[resource_name] or {}
            table.insert(copies[resource_name], copy.name)

            local map = planet.map_gen_settings
            map.autoplace_settings = map.autoplace_settings or {}
            map.autoplace_settings.entity = map.autoplace_settings.entity or {}
            local placement = map.autoplace_settings.entity
            placement.settings = placement.settings or {}
            placement.settings[copy.name] = placement.settings[resource_name] or {}
            placement.settings[resource_name] = nil
            wild.set_overrides(planet, copy.name, wild.overrides(planet, resource_name))
            wild.keep_off(planet, resource_name)
            for _, other_name in pairs(planets) do
                local other = data.raw.planet[other_name]
                if other_name ~= planet.name and other.map_gen_settings ~= nil then
                    wild.keep_off(other, copy.name)
                end
            end
        end
    end
    -- Mining any version fulfills the same trigger as mining the original did (MineEntityTechnologyTrigger.entities).
    for _, tech in pairs(data.raw.technology or {}) do
        local trigger = tech.research_trigger
        if trigger ~= nil and trigger.type == "mine-entity" then
            local added = {}
            for _, name in pairs(trigger.entities) do
                for _, copy_name in pairs(copies[name] or {}) do
                    table.insert(added, copy_name)
                end
            end
            for _, name in pairs(added) do
                table.insert(trigger.entities, name)
            end
        end
    end
    local count = 0
    for _, names in pairs(copies) do
        count = count + #names
    end
    log("Resource variants: " .. count .. " planet placements given their own resource entities")
    return copies
end

return variants

-- Maintenance-wise, it's easiest to keep this exact header for all stage 2 lookups, even if not all these are used
-- START repeated header

local collision_mask_util
if not offline then
    collision_mask_util = require("__core__/lualib/collision-mask-util")
else
    collision_mask_util = require("offline/lualib/collision-mask-util")
end

local categories = require("helper-tables/categories")
local gutils = require("new-lib/graph/graph-utils")
local lutils = require("new-lib/logic/logic-utils")
local dutils = require("new-lib/data-utils")
local tutils = require("lib/trigger")

local prots = dutils.prots

local stage = {}

local lu
stage.link = function(lu_to_link)
    lu = lu_to_link
end

-- END repeated header

-- Maps damage types to sources that can deal that damage type
stage.damage_type_sources = function()
    local damage_type_sources = {}

    for _, damage in pairs(prots("damage-type")) do
        damage_type_sources[damage.name] = {}
    end

    local function add_damage_source(damage_type, source_key, amount, source_type)
        if damage_type_sources[damage_type] == nil then
            damage_type_sources[damage_type] = {}
        end
        if damage_type_sources[damage_type][source_key] == nil or
           damage_type_sources[damage_type][source_key].amount < amount then
            damage_type_sources[damage_type][source_key] = {
                amount = amount,
                source_type = source_type,
            }
        end
    end

    local function extract_damage_from_structs(structs, source_key, source_type)
        if structs["damage-parameters"] ~= nil then
            for _, dp in pairs(structs["damage-parameters"]) do
                if dp.type ~= nil and dp.amount ~= nil and dp.amount > 0 then
                    add_damage_source(dp.type, source_key, dp.amount, source_type)
                end
            end
        end
    end

    -- 1. AMMO ITEMS
    for item_name, item in pairs(lu.items) do
        if item.type == "ammo" then
            local structs = {}
            tutils.gather_ammo_structs(structs, item, nil)
            extract_damage_from_structs(structs, gutils.key("item", item_name), "ammo")
        end
    end

    -- 2. TURRETS WITH BUILT-IN DAMAGE
    for _, turret_class in pairs({"electric-turret", "fluid-turret"}) do
        for _, turret in pairs(prots(turret_class)) do
            if lu.entities[turret.name] ~= nil then
                local structs = {}
                local gather_func = tutils.type_to_gather_struct_func[turret_class]
                if gather_func ~= nil then
                    gather_func(structs, turret, nil)
                    extract_damage_from_structs(structs, gutils.key("entity", turret.name), "turret")
                end
            end
        end
    end

    -- 3. COMBAT ROBOTS
    for entity_name, entity in pairs(lu.entities) do
        if entity.type == "combat-robot" then
            local structs = {}
            tutils.gather_combat_robot_structs(structs, entity, nil)
            extract_damage_from_structs(structs, gutils.key("entity", entity_name), "entity")
        end
    end

    -- 4. EQUIPMENT WITH ATTACK
    for equip_name, equip in pairs(lu.equipment) do
        if equip.type == "active-defense-equipment" then
            local structs = {}
            tutils.gather_active_defense_equipment_structs(structs, equip, nil)
            extract_damage_from_structs(structs, gutils.key("equipment", equip_name), "equipment")
        end
    end

    lu.damage_type_sources = damage_type_sources
end

-- A table for entities to resistance groups
stage.entity_resistance_groups = function()
    local entity_resistance_groups = {
        to_resistance = {},
        to_entity = {},
        groups = {},
    }

    -- Reusable table for immunities (optimization)
    local immunities = {}

    for _, entity in pairs(lu.entities) do
        if not categories.without_health[entity.type] then
            -- Clear and reuse immunities table
            for k in pairs(immunities) do immunities[k] = nil end
            local is_immune = {}
            local count = 0

            if entity.resistances ~= nil then
                for _, resistance in pairs(entity.resistances) do
                    if resistance.percentage ~= nil and resistance.percentage >= 100 then
                        count = count + 1
                        immunities[count] = resistance.type
                        is_immune[resistance.type] = true
                    end
                end
            end

            -- Sort only the used portion
            if count > 1 then
                table_sort(immunities, function(a, b)
                    if a == nil then return false end
                    if b == nil then return true end
                    return a < b
                end)
            end

            -- Build key from sorted immunities
            local key_parts = {}
            for i = 1, count do
                key_parts[i] = immunities[i]
            end
            local immunities_key = gutils.concat(key_parts)

            entity_resistance_groups.to_resistance[entity.name] = immunities_key
            if entity_resistance_groups.to_entity[immunities_key] == nil then
                entity_resistance_groups.to_entity[immunities_key] = {}
            end
            entity_resistance_groups.to_entity[immunities_key][entity.name] = true
            if entity_resistance_groups.groups[immunities_key] == nil then
                entity_resistance_groups.groups[immunities_key] = is_immune
            end
        end
    end

    lu.entity_resistance_groups = entity_resistance_groups
end

-- Maps ammo categories to things that can shoot that category
stage.ammo_category_sources = function()
    local ammo_category_sources = {}

    for _, cat in pairs(prots("ammo-category")) do
        ammo_category_sources[cat.name] = {}
    end

    local function add_sources(attack_parameters, source_key, source_type)
        local cats = dutils.get_ammo_categories(attack_parameters)
        if cats ~= nil then
            for _, cat in pairs(cats) do
                if ammo_category_sources[cat] == nil then
                    ammo_category_sources[cat] = {}
                end
                ammo_category_sources[cat][source_key] = source_type
            end
        end
    end

    for _, turret in pairs(prots("ammo-turret")) do
        if lu.entities[turret.name] ~= nil then
            add_sources(turret.attack_parameters, gutils.key("entity", turret.name), "turret")
        end
    end

    for _, gun in pairs(prots("gun")) do
        add_sources(gun.attack_parameters, gutils.key("item", gun.name), "gun")
    end

    lu.ammo_category_sources = ammo_category_sources
end

return stage
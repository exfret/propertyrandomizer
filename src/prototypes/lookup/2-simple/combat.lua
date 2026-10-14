-- Maintenance-wise, it's easiest to keep this exact header for all stage 2 lookups, even if not all these are used
-- START repeated header

local collision_mask_util = require("__core__/lualib/collision-mask-util")

local categories = require("src/prototypes/categories")
local gutils = require("src/lib/graph/graph-utils")
local lutils = require("src/logic/logic-utils")
local dutils = require("src/prototypes/data-utils")
local impact = require("src/prototypes/entities/projectile-impact")
local tutils = require("src/prototypes/entities/trigger")

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
        if damage_type_sources[damage_type][source_key] == nil or damage_type_sources[damage_type][source_key].amount < amount then
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

    -- Directly placed impacts and thrown payloads are manual damage sources. Their use is separate from manufacturing the item.
    for item_name, item in pairs(lu.items) do
        local structs = {}
        if item.type == "capsule" and item.capsule_action ~= nil and item.capsule_action.type == "throw" then
            tutils.gather_capsule_structs(structs, item, nil)
            extract_damage_from_structs(structs, gutils.key("item", item_name), "capsule")
        end
        local placed = item.place_result ~= nil and (data.raw.explosion or {})[item.place_result] or nil
        if placed ~= nil and impact.at_position(placed.created_effect) then
            local effects = {}
            tutils.gather_trigger_structs(effects, placed.created_effect, nil)
            extract_damage_from_structs(effects, gutils.key("entity", placed.name), "placed-effect")
            for _, sources in pairs(damage_type_sources) do
                local source = sources[gutils.key("entity", placed.name)]
                if source ~= nil then source.item_name = item_name end
            end
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

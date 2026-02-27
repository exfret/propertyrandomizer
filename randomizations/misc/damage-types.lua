
local rng = require("lib/random/rng")
local indirect = require("randomizations/helper/indirect")
local locale_utils = require("lib/locale")
local trigger_utils = require("lib/trigger")

local damage_type_names = {}
for name, _ in pairs(data.raw["damage-type"]) do
    table.insert(damage_type_names, name)
end

local add_damage_type_description = function (prototype)
    prototype.localised_description = {"", locale_utils.find_localised_description(prototype), "\n[color=red](Damage type augment)[/color]"}
end

local damage_type_randomization = function (prototype, parents, structs, id)
    local changed = false
    local rng_key = rng.key({ id = id, prototype = prototype })

    for _, damage_parameters in pairs(structs["damage-parameters"] or {}) do
        local old_type = damage_parameters.type
        damage_parameters.type = damage_type_names[rng.int(rng_key, #damage_type_names)]
        if damage_parameters.type ~= old_type then
            changed = true
        end
    end

    if changed then
        for _, parent in pairs(parents) do
            add_damage_type_description(parent)
        end
    end
end

-- New
randomizations.ammo_damage_types = function (id)
    -- exfret: This is clobbering the issue with an unnecessarily large hammer, but there have been asteroid softlocks without warnings from the randomizer due to resistance randomization
    -- This is just damage type rando, but I still worry, so I'm not allowing it to be randomized right now unless chaos is ultimate
    -- This should at least allow for overrides to overcome it, but in reality this should just get done properly some other time
    -- Ammo from turrets and projectiles from rockets are the only things that *really* need to be blacklisted, so those are the only functions I've touched
    if config.chaos_idx < 4 then
        return
    end

    for _, ammo in pairs(data.raw.ammo) do
        local structs = {}
        trigger_utils.gather_ammo_structs(structs, ammo, true)
        damage_type_randomization(ammo, {ammo}, structs, id)
    end
end

-- New
randomizations.artillery_projectile_damage_types = function (id)
    indirect.iterate_child_prototypes("artillery-projectile", function (prototype, parents, structs, is_enemy)
        damage_type_randomization(prototype, parents, structs, id)
    end)
end

-- New
randomizations.beam_damage_types = function (id)
    indirect.iterate_child_prototypes("beam", function (prototype, parents, structs, is_enemy)
        damage_type_randomization(prototype, parents, structs, id)
    end)
end

-- New
randomizations.capsule_damage_types = function (id)
    for _, capsule in pairs(data.raw.capsule) do
        local structs = {}
        trigger_utils.gather_capsule_structs(structs, capsule, true)
        damage_type_randomization(capsule, {capsule}, structs, id)
    end
end

-- New
randomizations.combat_robot_damage_types = function (id)
    for _, robot in pairs(data.raw["combat-robot"]) do
        local structs = {}
        trigger_utils.gather_combat_robot_structs(structs, robot, true)
        damage_type_randomization(robot, {robot}, structs, id)
    end
end

-- New
randomizations.fire_damage_types = function (id)
    indirect.iterate_child_prototypes("fire", function (prototype, parents, structs, is_enemy)
        damage_type_randomization(prototype, parents, structs, id)
    end)
end

-- New
randomizations.fluid_stream_damage_types = function (id)
    indirect.iterate_child_prototypes("stream", function (prototype, parents, structs, is_enemy)
        damage_type_randomization(prototype, parents, structs, id)
    end)
end

-- New
randomizations.landmine_damage_types = function(id)
    for _, landmine in pairs(data.raw["land-mine"]) do
        local structs = {}
        trigger_utils.gather_land_mine_structs(structs, landmine, true)
        damage_type_randomization(landmine, {landmine}, structs, id)
    end
end

-- New
randomizations.projectile_damage_types = function (id)
    -- exfret: Disabled on non-ultimate chaos
    -- See comments in ammo_damage_types for more information
    if config.chaos_idx < 4 then
        return
    end
    
    indirect.iterate_child_prototypes("projectile", function (prototype, parents, structs, is_enemy)
        damage_type_randomization(prototype, parents, structs, id)
    end)
end

-- New
randomizations.smoke_damage_types = function (id)
    indirect.iterate_child_prototypes("smoke-with-trigger", function (prototype, parents, structs, is_enemy)
        damage_type_randomization(prototype, parents, structs, id)
    end)
end

-- New
randomizations.sticker_damage_types = function (id)
    indirect.iterate_child_prototypes("sticker", function (prototype, parents, structs, is_enemy)
        damage_type_randomization(prototype, parents, structs, id)
    end)
end

-- New
randomizations.unit_damage_types = function (id)
    for _, unit in pairs(data.raw.unit or {}) do
        local structs = {}
        trigger_utils.gather_unit_structs(structs, unit, true)
        damage_type_randomization(unit, {unit}, structs, id)
    end
end
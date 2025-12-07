
local rng = require("lib/random/rng")
local locale_utils = require("lib/locale")
local trigger_utils = require("lib/trigger")

local damage_type_names = {}
for name, _ in pairs(data.raw["damage-type"]) do
    table.insert(damage_type_names, name)
end

local add_damage_type_description = function (prototype)
    prototype.localised_description = {"", locale_utils.find_localised_description(prototype), "\n[color=red](Damage type augment)[/color]"}
end

-- New
randomizations.ammo_damage_types = function (id)
    for _, ammo in pairs(data.raw.ammo) do
        local structs = {}
        trigger_utils.gather_ammo_structs(structs, ammo, true)
        local rng_key = rng.key({ id = id, prototype = ammo })
        local changed = false

        for _, damage_parameters in pairs(structs["damage-parameters"] or {}) do
            local old_type = damage_parameters.type
            damage_parameters.type = damage_type_names[rng.int(rng_key, #damage_type_names)]
            if damage_parameters.type ~= old_type then
                changed = true
            end
        end

        if changed then
            add_damage_type_description(ammo)
        end
    end
end

-- New
randomizations.artillery_projectile_damage_types = function (id)
    local projectiles = trigger_utils.get_creator_table("artillery-projectile")

    local target_classes = {
        ["ammo"] = true,
    }

    for projectile_name, creators in pairs(projectiles) do
        local affected_prototypes = {}

        for _, prototype in pairs(creators) do
            if target_classes[prototype.type] ~= nil then
                affected_prototypes[#affected_prototypes+1] = prototype
            end
        end

        if #affected_prototypes > 0 then
            local projectile = data.raw["artillery-projectile"][projectile_name]
            local structs = {}
            trigger_utils.gather_projectile_structs(structs, projectile, true)
            local changed = false
            local rng_key = rng.key({ id = id, prototype = projectile })

            for _, damage_parameters in pairs(structs["damage-parameters"] or {}) do
                local old_type = damage_parameters.type
                damage_parameters.type = damage_type_names[rng.int(rng_key, #damage_type_names)]
                if damage_parameters.type ~= old_type then
                    changed = true
                end
            end

            if changed then
                for _, prototype in pairs(affected_prototypes) do
                    add_damage_type_description(prototype)
                end
            end
        end
    end
end

-- New
randomizations.beam_damage_types = function (id)
    local beams = trigger_utils.get_creator_table("beam")

    local target_classes = {
        ["ammo"] = true,
        ["combat-robot"] = true,
        ["active-defense-equipment"] = true,
    }

    for beam_name, creators in pairs(beams) do
        local affected_prototypes = {}

        for _, prototype in pairs(creators) do
            if target_classes[prototype.type] ~= nil then
                affected_prototypes[#affected_prototypes+1] = prototype
            end
        end

        if #affected_prototypes > 0 then
            local beam = data.raw.beam[beam_name]
            local structs = {}
            trigger_utils.gather_beam_structs(structs, beam, true)
            local changed = false
            local rng_key = rng.key({ id = id, prototype = beam })

            for _, damage_parameters in pairs(structs["damage-parameters"] or {}) do
                local old_type = damage_parameters.type
                damage_parameters.type = damage_type_names[rng.int(rng_key, #damage_type_names)]
                if damage_parameters.type ~= old_type then
                    changed = true
                end
            end
            if changed then
                for _, prototype in pairs(affected_prototypes) do
                    add_damage_type_description(prototype)
                end
            end
        end
    end
end

-- New
randomizations.capsule_damage_types = function (id)
    for _, capsule in pairs(data.raw.capsule) do
        local structs = {}
        trigger_utils.gather_capsule_structs(structs, capsule, true)
        local rng_key = rng.key({ id = id, prototype = capsule })
        local changed = false

        for _, damage_parameters in pairs(structs["damage-parameters"] or {}) do
            local old_type = damage_parameters.type
            damage_parameters.type = damage_type_names[rng.int(rng_key, #damage_type_names)]
            if damage_parameters.type ~= old_type then
                changed = true
            end
        end

        if changed then
            add_damage_type_description(capsule)
        end
    end
end

-- New
randomizations.combat_robot_damage_types = function (id)
    for _, robot in pairs(data.raw["combat-robot"]) do
        local structs = {}
        trigger_utils.gather_combat_robot_structs(structs, robot, true)
        local rng_key = rng.key({ id = id, prototype = robot })
        local changed = false

        for _, damage_parameters in pairs(structs["damage-parameters"] or {}) do
            local old_type = damage_parameters.type
            damage_parameters.type = damage_type_names[rng.int(rng_key, #damage_type_names)]
            if damage_parameters.type ~= old_type then
                changed = true
            end
        end

        if changed then
            add_damage_type_description(robot)
        end
    end
end

-- New
randomizations.fire_damage_types = function (id)
    local fires = trigger_utils.get_creator_table("fire")

    local target_classes = {
        ["ammo"] = true,
    }

    for fire_name, creators in pairs(fires) do
        local affected_prototypes = {}

        for _, prototype in pairs(creators) do
            if target_classes[prototype.type] ~= nil then
                affected_prototypes[#affected_prototypes+1] = prototype
            end
        end

        if #affected_prototypes > 0 then
            local fire = data.raw.fire[fire_name]
            local structs = {}
            trigger_utils.gather_fire_structs(structs, fire, true)
            local changed = false
            local rng_key = rng.key({ id = id, prototype = fire })

            for _, damage_parameters in pairs(structs["damage-parameters"] or {}) do
                local old_type = damage_parameters.type
                damage_parameters.type = damage_type_names[rng.int(rng_key, #damage_type_names)]
                if damage_parameters.type ~= old_type then
                    changed = true
                end
            end
            if changed then
                for _, prototype in pairs(affected_prototypes) do
                    add_damage_type_description(prototype)
                end
            end
        end
    end
end

-- New
randomizations.projectile_damage_types = function (id)
    local projectiles = trigger_utils.get_creator_table("projectile")

    local target_classes = {
        ["ammo"] = true,
        ["capsule"] = true,
    }

    for projectile_name, creators in pairs(projectiles) do
        local affected_prototypes = {}

        for _, prototype in pairs(creators) do
            if target_classes[prototype.type] ~= nil then
                affected_prototypes[#affected_prototypes+1] = prototype
            end
        end

        if #affected_prototypes > 0 then
            local projectile = data.raw.projectile[projectile_name]
            local structs = {}
            trigger_utils.gather_projectile_structs(structs, projectile, true)
            local changed = false
            local rng_key = rng.key({ id = id, prototype = projectile })

            for _, damage_parameters in pairs(structs["damage-parameters"] or {}) do
                local old_type = damage_parameters.type
                damage_parameters.type = damage_type_names[rng.int(rng_key, #damage_type_names)]
                if damage_parameters.type ~= old_type then
                    changed = true
                end
            end

            if changed then
                for _, prototype in pairs(affected_prototypes) do
                    add_damage_type_description(prototype)
                end
            end
        end
    end
end

-- New
randomizations.smoke_damage_types = function (id)
    local smokes = trigger_utils.get_creator_table("smoke-with-trigger")

    local target_classes = {
        ["capsule"] = true,
    }

    for smoke_name, creators in pairs(smokes) do
        local affected_prototypes = {}

        for _, prototype in pairs(creators) do
            if target_classes[prototype.type] ~= nil then
                affected_prototypes[#affected_prototypes+1] = prototype
            end
        end

        if #affected_prototypes > 0 then
            local smoke = data.raw["smoke-with-trigger"][smoke_name]
            local structs = {}
            trigger_utils.gather_smoke_with_trigger_structs(structs, smoke, true)
            local changed = false
            local rng_key = rng.key({ id = id, prototype = smoke })

            for _, damage_parameters in pairs(structs["damage-parameters"] or {}) do
                local old_type = damage_parameters.type
                damage_parameters.type = damage_type_names[rng.int(rng_key, #damage_type_names)]
                if damage_parameters.type ~= old_type then
                    changed = true
                end
            end
            if changed then
                for _, prototype in pairs(affected_prototypes) do
                    add_damage_type_description(prototype)
                end
            end
        end
    end
end

-- New
randomizations.sticker_damage_types = function (id)
    local stickers = trigger_utils.get_creator_table("sticker")

    local target_classes = {
        ["capsule"] = true,
        ["ammo"] = true,
    }

    for sticker_name, creators in pairs(stickers) do
        local affected_prototypes = {}

        for _, prototype in pairs(creators) do
            if target_classes[prototype.type] ~= nil then
                affected_prototypes[#affected_prototypes+1] = prototype
            end
        end

        if #affected_prototypes > 0 then
            local sticker = data.raw.sticker[sticker_name]
            local structs = {}
            trigger_utils.gather_sticker_structs(structs, sticker, true)
            local changed = false
            local rng_key = rng.key({ id = id, prototype = sticker })

            for _, damage_parameters in pairs(structs["damage-parameters"] or {}) do
                local old_type = damage_parameters.type
                damage_parameters.type = damage_type_names[rng.int(rng_key, #damage_type_names)]
                if damage_parameters.type ~= old_type then
                    changed = true
                end
            end
            if changed then
                for _, prototype in pairs(affected_prototypes) do
                    add_damage_type_description(prototype)
                end
            end
        end
    end
end
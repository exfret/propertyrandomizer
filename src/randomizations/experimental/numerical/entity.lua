-- Parked military/resistance experiment. Installed only by the explicit experimental flag.
local categories = require("src/prototypes/categories")
local randnum = require("src/lib/random/randnum")
local randprob = require("src/lib/random/randprob")
local rng = require("src/lib/random/rng")
local indirect = require("src/randomizations/helpers/indirect")
local locale_utils = require("src/localisation/locale")
local trigger_utils = require("src/prototypes/entities/trigger")
local resistance_utils = require("src/prototypes/combat/combat-resistances")
local prototype_exclusions = require("src/config/prototype-exclusions")
local combat_adapters = require("src/lib/random/combat-adapters")
local combat_encounters = require("src/logic/builders/combat-encounters")
local randomize = randnum.rand
local round = function (n)
    return math.floor(n + 0.5)
end
local damage_randomization = function (prototype, parents, structs, is_enemy, id, variance)
    local dir = 1
    if is_enemy then
        dir = -1
    end

    local rng_key = rng.key({ id = id, prototype = prototype })
    local fields = combat_adapters.fields(structs["damage-parameters"], "amount")
    local rounding_params = {
        key = rng_key,
        rounding = "discrete_float",
    }
    local factor = randomize({
        id = id,
        key = rng_key,
        dummy = 1,
        combat = combat_adapters.factor(fields, combat_adapters.rounding(rounding_params), "increasing"),
        rounding = "none",
        variance = variance,
        dir = dir,
    })
    if #fields > 0 then
        for _, parent in pairs(parents) do
            locale_utils.create_localised_description(parent, factor, id, { flipped = dir < 0, variance = variance })
        end
    end
end
local effect_radius_randomization = function (prototype, parents, structs, is_enemy, id, variance)
    local dir = 1
    if is_enemy then
        dir = -1
    end

    local rng_key = rng.key({ id = id, prototype = prototype })
    local fields = combat_adapters.fields(structs["trigger-effect"], "radius")
    for _, field in pairs(combat_adapters.fields(structs["trigger"], "radius")) do
        table.insert(fields, field)
    end
    local rounded = combat_adapters.rounding({
        key = rng_key,
        rounding = "discrete_float",
    })
    local factor = randomize({
        id = id,
        key = rng_key,
        dummy = 1,
        combat = combat_adapters.factor(fields, rounded, false),
        rounding = "none",
        variance = variance,
        dir = dir,
    })
    if #fields > 0 then
        for _, parent in pairs(parents) do
            locale_utils.create_localised_description(parent, factor, id, { flipped = dir < 0, variance = variance })
        end
    end
end

local experimental = { randomizations = {} }

experimental.randomizations.artillery_projectile_damage = function (id)
    indirect.iterate_child_prototypes("artillery-projectile", function (prototype, parents, structs, is_enemy)
        damage_randomization(prototype, parents, structs, is_enemy, id, "big")
    end)
end

experimental.randomizations.artillery_projectile_effect_radius = function (id)
    indirect.iterate_child_prototypes("artillery-projectile", function (prototype, parents, structs, is_enemy)
        effect_radius_randomization(prototype, parents, structs, is_enemy, id, "medium")
    end)
end

experimental.randomizations.beam_damage = function (id)
    indirect.iterate_child_prototypes("beam", function (prototype, parents, structs, is_enemy)
        damage_randomization(prototype, parents, structs, is_enemy, id, "medium")
    end)
end

experimental.randomizations.combat_robot_damage = function (id)
    for _, robot in pairs(data.raw["combat-robot"]) do
        local structs = {}
        trigger_utils.gather_combat_robot_structs(structs, robot, true)
        damage_randomization(robot, { robot }, structs, false, id, "big")
    end
end

experimental.randomizations.combat_robot_shooting_speed = function (id)
    for _, robot in pairs(data.raw["combat-robot"]) do
        if robot.attack_parameters.cooldown > 0 then
            local old_value = robot.attack_parameters.cooldown

            local adapter = combat_adapters.reciprocal(robot.attack_parameters, "cooldown", 60)
            randomize({
                id = id,
                prototype = robot,
                dummy = adapter.read(),
                combat = adapter,
                rounding = "discrete_float",
                variance = "big",
            })

            local factor = old_value / robot.attack_parameters.cooldown

            locale_utils.create_localised_description(robot, factor, id, { variance = "big" })
        end
    end
end

experimental.randomizations.fire_damage = function (id)
    indirect.iterate_child_prototypes("fire", function (prototype, parents, structs, is_enemy)
        damage_randomization(prototype, parents, structs, is_enemy, id, "medium")
    end)
end

experimental.randomizations.fluid_stream_damage = function (id)
    indirect.iterate_child_prototypes("stream", function (prototype, parents, structs, is_enemy)
        damage_randomization(prototype, parents, structs, is_enemy, id, "medium")
    end)
end

experimental.randomizations.fluid_stream_effect_radius = function (id)
    indirect.iterate_child_prototypes("stream", function (prototype, parents, structs, is_enemy)
        effect_radius_randomization(prototype, parents, structs, is_enemy, id, "small")
    end)
end

experimental.health_regeneration = function (id, enemy_classes, tree_classes)
    for entity_class, _ in pairs(defines.prototypes.entity) do
        if data.raw[entity_class] ~= nil then
            for _, entity in pairs(data.raw[entity_class]) do
                if entity.healing_per_tick == nil and tree_classes[entity_class] ~= nil then
                    entity.healing_per_tick = 0.1 / 60
                end

                if entity.healing_per_tick ~= nil and entity.healing_per_tick ~= 0 then
                    local dir = -1
                    local old_value = entity.healing_per_tick
                    if enemy_classes[entity_class] == nil then
                        dir = 1
                    end
                    if old_value < 0 then
                        dir = dir * -1
                    end
                    local multiplier = old_value < 0 and -1 / 60 or 1 / 60
                    local adapter = combat_adapters.scaled(entity, "healing_per_tick", multiplier, old_value < 0 and "increasing" or "decreasing")
                    randomize({
                        id = id,
                        prototype = entity,
                        dummy = adapter.read(),
                        combat = adapter,
                        rounding = "discrete_float",
                        dir = dir,
                    })

                    local factor = entity.healing_per_tick / old_value
                    locale_utils.create_localised_description(entity, factor, id, { flipped = dir < 0 })
                end
            end
        end
    end
end

experimental.randomizations.landmine_damage = function(id)
    for _, landmine in pairs(data.raw["land-mine"]) do
        local structs = {}
        trigger_utils.gather_land_mine_structs(structs, landmine, true)
        damage_randomization(landmine, { landmine }, structs, false, id, "big")
    end
end

experimental.machine_energy_usage = function(id, crafting_machine_classes)

    for entity_class, energy_keys in pairs(categories.machine_energy_usage_keys) do
        if data.raw[entity_class] ~= nil then
            for _, entity in pairs(data.raw[entity_class]) do
                local energy_properties = {}
                local ind_to_is_power = {}
                for energy_key, energy_or_power in pairs(energy_keys) do
                    if entity[energy_key] ~= nil and util.parse_energy(entity[energy_key]) > 0 then
                        table.insert(energy_properties, energy_key)
                        if energy_or_power == "power" then
                            table.insert(ind_to_is_power, true)
                        elseif energy_or_power == "energy" then
                            table.insert(ind_to_is_power, false)
                        else
                            -- In this case, I made a typo
                            error()
                        end
                    end
                end

                if #energy_properties >= 1 then
                    local old_first_energy_val = util.parse_energy(entity[energy_properties[1]])
                    local fields = {}
                    for index, property in pairs(energy_properties) do
                        table.insert(fields, {
                            object = entity,
                            key = property,
                            multiplier = ind_to_is_power[index] and 60 or 1,
                            suffix = ind_to_is_power[index] and "W" or "J",
                        })
                    end
                    if entity.energy_source ~= nil and entity.energy_source.buffer_capacity ~= nil then
                        table.insert(fields, {
                            object = entity.energy_source,
                            key = "buffer_capacity",
                            rounded = false,
                        })
                    end
                    if crafting_machine_classes[entity_class] == true and entity.energy_source ~= nil
                        and entity.energy_source.type == "electric" and entity.energy_source.drain == nil then
                        table.insert(fields, {
                            object = entity.energy_source,
                            key = "drain",
                            value = 60 * util.parse_energy(entity.energy_usage) / 30,
                            suffix = "W",
                        })
                    elseif entity.energy_source ~= nil and entity.energy_source.type == "electric" and entity.energy_source.drain ~= nil then
                        table.insert(fields, {
                            object = entity.energy_source,
                            key = "drain",
                            multiplier = 60,
                            suffix = "W",
                        })
                    end
                    local rounded = combat_adapters.rounding({
                        key = rng.key({
                            id = id,
                            prototype = entity,
                        }),
                        rounding = "discrete_float",
                    })
                    local adapter = combat_adapters.energy(fields, rounded)
                    randomize({
                        id = id,
                        prototype = entity,
                        dummy = adapter.read(),
                        combat = adapter,
                        dir = -1,
                        rounding = "discrete_float",
                    })
                    local factor = util.parse_energy(entity[energy_properties[1]]) / old_first_energy_val
                    locale_utils.create_localised_description(entity, factor, id, {flipped = true})
                end
            end
        end
    end

    for _, electric_turret in pairs(data.raw["electric-turret"]) do
        local shot_energy_consumption = electric_turret.attack_parameters.ammo_type.energy_consumption
        if shot_energy_consumption ~= nil then
            local old_energy_consumption = util.parse_energy(electric_turret.attack_parameters.ammo_type.energy_consumption)
            local fields = {
                {
                    object = electric_turret.attack_parameters.ammo_type,
                    key = "energy_consumption",
                },
            }
            if electric_turret.energy_source ~= nil and electric_turret.energy_source.buffer_capacity ~= nil then
                table.insert(fields, {
                    object = electric_turret.energy_source,
                    key = "buffer_capacity",
                    rounded = false,
                })
            end
            local adapter = combat_adapters.energy(fields)
            randomize({
                id = id,
                prototype = electric_turret,
                dummy = adapter.read(),
                combat = adapter,
                dir = -1,
                rounding = "discrete_float",
            })

            local factor = util.parse_energy(electric_turret.attack_parameters.ammo_type.energy_consumption) / old_energy_consumption
            locale_utils.create_localised_description(electric_turret, factor, id, {flipped = true})
        end
    end
end

experimental.randomizations.projectile_cluster_size = function (id)
    indirect.iterate_child_prototypes("projectile", function(projectile, parents, structs, is_enemy)
        local dir = 1
        if is_enemy then
            dir = -1
        end

        local rng_key = rng.key({ id = id, prototype = projectile })
        local fields = combat_adapters.fields(structs["trigger"], "cluster_count")
        local rounded = combat_adapters.rounding({
            key = rng_key,
            rounding = "discrete",
            abs_min = 2,
        })
        local factor = randomize({
            id = id,
            key = rng_key,
            dummy = 1,
            combat = combat_adapters.factor(fields, rounded, false),
            variance = "big",
            rounding = "none",
            dir = dir,
        })
        if #fields > 0 then
            for _, prototype in pairs(parents) do
                locale_utils.create_localised_description(prototype, factor, id, { flipped = dir < 0, variance = "big" })
            end
        end
    end)
end

experimental.randomizations.projectile_damage = function (id)
    indirect.iterate_child_prototypes("projectile", function (prototype, parents, structs, is_enemy)
        damage_randomization(prototype, parents, structs, is_enemy, id, "medium")
    end)
end

experimental.randomizations.projectile_effect_radius = function (id)
    indirect.iterate_child_prototypes("projectile", function (prototype, parents, structs, is_enemy)
        effect_radius_randomization(prototype, parents, structs, is_enemy, id, "small")
    end)
end

experimental.randomizations.projectile_projectile_count = function (id)
    indirect.iterate_child_prototypes("projectile", function (projectile, parents, structs, is_enemy)
        local dir = 1
        if is_enemy then
            dir = -1
        end

        local rng_key = rng.key({ id = id, prototype = projectile })
        local fields = combat_adapters.fields(structs["trigger"], "repeat_count", function(value) return value > 1 end)
        local rounded = combat_adapters.rounding({
            key = rng_key,
            rounding = "discrete",
            abs_min = 2,
        })
        local factor = randomize({
            id = id,
            key = rng_key,
            dummy = 1,
            combat = combat_adapters.factor(fields, rounded, "increasing"),
            variance = "big",
            rounding = "none",
            dir = dir,
        })
        if #fields > 0 then
            for _, prototype in pairs(parents) do
                locale_utils.create_localised_description(prototype, factor, id, { flipped = dir < 0, variance = "big" })
            end
        end
    end)
end

experimental.randomizations.resistances = function(id)
    -- Use cached graph rosters only to keep encounter targets in independent roll groups.
    local entities = {}
    for entity_class, _ in pairs(defines.prototypes.entity) do
        for _, entity in pairs(data.raw[entity_class] or {}) do
            table.insert(entities, entity)
        end
    end
    local groups = resistance_utils.collect(entities, data.raw["damage-type"] or {}, function(entity)
        return not prototype_exclusions.active_excluded(entity)
    end, data.raw)
    local definitions = combat_encounters.definitions ~= nil and combat_encounters.definitions() or {}
    local sensitive = resistance_utils.target_set(definitions, entities, data.raw)
    local partition = resistance_utils.partition(groups, {
        raw = data.raw,
        sensitive_entities = sensitive,
        all_sensitive = sensitive == nil,
    })
    local function describe(group)
        for _, owner in pairs(group.prototypes) do
            owner.localised_description = {
                "",
                locale_utils.find_localised_description(owner),
                {"propertyrandomizer-status.random-damage-resistances-red"},
            }
        end
    end
    for _, group in pairs(partition.sensitive) do
        local entity = group.prototype
        local key = rng.key({
            id = id,
            prototype = entity,
        })
        local dir = 1
        for _, owner in pairs(group.prototypes) do
            if categories.enemy_health_classes[owner.type] == true then dir = -1 end
        end
        local changed = false
        for _, resistance in pairs(group.entries) do
            -- Keep original immunities fixed, including their flat component and categorical type.
            if resistance.percent ~= 100 then
                if resistance.decrease ~= nil and resistance.decrease > 0 then
                    local previous = resistance.decrease
                    randomize({
                        id = id,
                        key = key,
                        prototype = entity,
                        tbl = resistance,
                        property = "decrease",
                        abs_min = 0,
                        rounding = "discrete_float",
                        variance = "medium",
                        dir = dir,
                    })
                    changed = changed or resistance.decrease ~= previous
                end
                if resistance.percent ~= nil and resistance.percent > 0 then
                    local previous = resistance.percent
                    randprob.rand({
                        id = id,
                        key = key,
                        prototype = entity,
                        tbl = resistance,
                        property = "percent",
                        abs_min = 0,
                        -- Remain below immunity even after the prototype's float conversion.
                        abs_max = 99.999,
                        rounding = "discrete_float",
                        variance = "medium",
                        dir = dir,
                        probability_scale = 100,
                    })
                    changed = changed or resistance.percent ~= previous
                end
            end
        end
        if changed then
            describe(group)
        end
    end
    -- Ordinary entities share per-damage-type rolls, preserving each original amount.
    -- Immunity-compatible batches keep immune rows and excluded aliases untouched.
    for _, batch in pairs(partition.ordinary) do
        local by_type, types, before = {}, {}, {}
        for _, row in pairs(batch.entries) do
            before[row] = {
                decrease = row.decrease,
                percent = row.percent,
            }
            if row.percent ~= 100 then
                if by_type[row.type] == nil then
                    by_type[row.type] = {}
                    table.insert(types, row.type)
                end
                table.insert(by_type[row.type], row)
            end
        end
        table.sort(types)
        local key = rng.key({
            id = id,
            prototype = batch.prototype,
        })
        for _, damage_type in pairs(types) do
            local rows = by_type[damage_type]
            for _, property in pairs({
                "decrease",
                "percent",
            }) do
                local fields = combat_adapters.fields(rows, property)
                if #fields > 0 then
                    local rounded = combat_adapters.rounding({
                        id = id,
                        key = key,
                        rounding = "discrete_float",
                        abs_min = 0,
                        abs_max = property == "percent" and 99.999 or nil,
                    })
                    local adapter
                    if property == "percent" then
                        -- Match probability sampling: round the smaller tail before restoring the percentage.
                        local function round_percent(value)
                            local high = value > 50
                            if high then value = 100 - value end
                            value = rounded(value)
                            if high then value = 100 - value end
                            return math.max(0, math.min(99.999, value))
                        end
                        adapter = combat_adapters.odds(fields, 100, round_percent, "decreasing")
                    else
                        adapter = combat_adapters.factor(fields, rounded, "decreasing")
                    end
                    randomize({
                        id = id,
                        key = key,
                        prototype = batch.prototype,
                        dummy = 1,
                        rounding = "none",
                        variance = "medium",
                        combat = adapter,
                    })
                end
            end
        end
        -- A shared roll can round back to the original for some owners.
        for _, group in pairs(batch.groups) do
            local changed = false
            for _, row in pairs(group.entries) do
                changed = changed or row.decrease ~= before[row].decrease or row.percent ~= before[row].percent
            end
            if changed then
                describe(group)
            end
        end
    end
end

experimental.randomizations.smoke_damage = function (id)
    indirect.iterate_child_prototypes("smoke-with-trigger", function (prototype, parents, structs, is_enemy)
        damage_randomization(prototype, parents, structs, is_enemy, id, "big")
    end)
end

experimental.randomizations.smoke_effect_radius = function (id)
    indirect.iterate_child_prototypes("smoke-with-trigger", function (prototype, parents, structs, is_enemy)
        effect_radius_randomization(prototype, parents, structs, is_enemy, id, "medium")
    end)
end

experimental.randomizations.spider_unit_projectile_range = function(id)
    for _, spider in pairs(data.raw["spider-unit"] or {}) do
        local structs = {}
        trigger_utils.gather_spider_unit_structs(structs, spider, true)
        local rng_key = rng.key({ id = id, prototype = spider })
        local fields = combat_adapters.fields(structs["trigger-delivery"], "max_range")
        local rounded = combat_adapters.rounding({
            key = rng_key,
            rounding = "discrete_float",
        })
        local factor = randomize({
            id = id,
            key = rng_key,
            dummy = 1,
            combat = combat_adapters.factor(fields, rounded, false),
            variance = "medium",
            rounding = "none",
            dir = -1,
        })
        if #fields > 0 then
            locale_utils.create_localised_description(spider, factor, id, { variance = "medium" })
        end
    end
end

experimental.randomizations.sticker_damage = function (id)
    indirect.iterate_child_prototypes("sticker", function (prototype, parents, structs, is_enemy)
        damage_randomization(prototype, parents, structs, is_enemy, id, "medium")
    end)
end

experimental.randomizations.sticker_healing = function (id)
    indirect.iterate_child_prototypes("sticker", function (sticker, parents, structs, is_enemy)
        local dir = 1
        if is_enemy then
            dir = -1
        end

        local rng_key = rng.key({ id = id, prototype = sticker })
        local fields = combat_adapters.fields(structs["damage-parameters"], "amount", function(value) return value < 0 end)
        local intervals_per_sec = 60 / (sticker.damage_interval or 1)
        local rounded = combat_adapters.rounding({
            key = rng_key,
            rounding = "discrete_float",
        })
        local factor = randomize({
            id = id,
            key = rng_key,
            dummy = 1,
            combat = combat_adapters.factor(fields, function(value) return rounded(value * intervals_per_sec) / intervals_per_sec end, false),
            rounding = "none",
            variance = "big",
            dir = dir,
        })
        if #fields > 0 then
            for _, prototype in pairs(parents) do
                locale_utils.create_localised_description(prototype, factor, id, { flipped = dir < 0, variance = "big" })
            end
        end
    end)
end

experimental.randomizations.turret_min_range = function(id)
    for turret_class, _ in pairs(categories.turrets) do
        for _, turret in pairs(data.raw[turret_class]) do
            local attack_parameters = turret.attack_parameters

            if attack_parameters.min_range ~= nil and attack_parameters.min_range ~= 0 then
                local old_min_range = attack_parameters.min_range
                local old_range = attack_parameters.range
                local old_prepare_range = turret.prepare_range
                local old_min_attack_distance = attack_parameters.min_attack_distance

                -- Don't randomize to more than, say, 2/3 of the range value
                -- Or we could scale max range whenever min range is changed, then randomize the diff between them instead of the max range directly?
                randomize({
                    id = id,
                    prototype = turret,
                    dummy = old_min_range,
                    combat = {
                        read = function() return old_min_range end,
                        apply = function(value)
                            local delta = value - old_min_range
                            attack_parameters.min_range = value
                            if old_range ~= nil then
                                attack_parameters.range = old_range + delta
                            end
                            if old_prepare_range ~= nil then
                                turret.prepare_range = old_prepare_range * (old_range + delta) / old_range
                            end
                            if old_min_attack_distance ~= nil then
                                attack_parameters.min_attack_distance = old_min_attack_distance + delta
                            end
                        end,
                        direction = false,
                        fields = {
                            {
                                object = attack_parameters,
                                key = "min_range",
                            },
                            {
                                object = attack_parameters,
                                key = "range",
                            },
                            {
                                object = turret,
                                key = "prepare_range",
                            },
                            {
                                object = attack_parameters,
                                key = "min_attack_distance",
                            },
                        },
                    },
                    variance = "small",
                    rounding = "discrete_float",
                })

                locale_utils.create_localised_description(turret, attack_parameters.min_range / old_min_range, id, { variance = "small" })
            end
        end
    end
end

experimental.randomizations.turret_range = function(id)
    for turret_class, _ in pairs(categories.turrets) do
        for _, turret in pairs(data.raw[turret_class]) do
            local attack_parameters = turret.attack_parameters
            local min_range = 0
            if attack_parameters.min_range ~= nil then
                min_range = attack_parameters.min_range
            end

            local old_range = attack_parameters.range
            local old_delta_range = attack_parameters.range - min_range
            local old_prepare_range = turret.prepare_range

            randomize({
                id = id,
                prototype = turret,
                dummy = old_delta_range,
                combat = {
                    read = function() return old_delta_range end,
                    apply = function(value)
                        attack_parameters.range = value + min_range
                        if old_prepare_range ~= nil then
                            turret.prepare_range = old_prepare_range * (value + min_range) / old_range
                        end
                    end,
                    direction = false,
                    fields = {
                        {
                            object = attack_parameters,
                            key = "range",
                        },
                        {
                            object = turret,
                            key = "prepare_range",
                        },
                    },
                },
                variance = "small",
                range = "small",
                rounding = "discrete_float",
            })

            local factor = attack_parameters.range / old_range

            locale_utils.create_localised_description(turret, factor, id, { variance = "small" })
        end
    end
end

experimental.randomizations.turret_shooting_speed = function(id)
    for turret_class, _ in pairs(categories.turrets) do
        for _, turret in pairs(data.raw[turret_class]) do
            local old_shooting_speed = 1 / turret.attack_parameters.cooldown
            local adapter = combat_adapters.reciprocal(turret.attack_parameters, "cooldown", 60)
            local old_fluid_consumption = turret.attack_parameters.fluid_consumption
            if old_fluid_consumption ~= nil then
                local set_cooldown = adapter.apply
                local coordinate = adapter.read()
                local rounded = combat_adapters.rounding({
                    key = rng.key({
                        id = id,
                        prototype = turret,
                    }),
                    rounding = "discrete_float",
                })
                table.insert(adapter.fields, {
                    object = turret.attack_parameters,
                    key = "fluid_consumption",
                })
                adapter.apply = function(value)
                    set_cooldown(value)
                    if value == coordinate then
                        turret.attack_parameters.fluid_consumption = old_fluid_consumption
                    else
                        local cooldown = turret.attack_parameters.cooldown
                        turret.attack_parameters.fluid_consumption = rounded(old_fluid_consumption * 60 / cooldown) * cooldown / 60
                    end
                end
            end
            randomize({
                id = id,
                prototype = turret,
                dummy = adapter.read(),
                combat = adapter,
                range = "small",
                rounding = "discrete_float",
            })
            local new_shooting_speed = 1 / turret.attack_parameters.cooldown
            local factor = new_shooting_speed / old_shooting_speed
            locale_utils.create_localised_description(turret, factor, id)
        end
    end
end

experimental.unit_attack_speed = function(id, unit_class)
        if data.raw[unit_class] ~= nil then
            for _, unit in pairs(data.raw[unit_class]) do
                if unit.attack_parameters.cooldown ~= 0 and unit.attack_parameters.cooldown ~= nil then
                    local old_attack_speed = 1 / unit.attack_parameters.cooldown

                    local adapter = combat_adapters.reciprocal(unit.attack_parameters, "cooldown", 60)
                    randomize({
                        id = id,
                        prototype = unit,
                        dummy = adapter.read(),
                        combat = adapter,
                        rounding = "discrete_float",
                        range = "small",
                        dir = -1,
                    })
                    local new_attack_speed = 1 / unit.attack_parameters.cooldown
                    locale_utils.create_localised_description(unit, new_attack_speed / old_attack_speed, id, {flipped = true})
                end
            end
        end
end

experimental.randomizations.unit_damage = function(id)
    for _, unit in pairs(data.raw["unit"] or {}) do
        local structs = {}
        trigger_utils.gather_unit_structs(structs, unit, true)
        damage_randomization(unit, { unit }, structs, true, id, "medium")
    end
end

return experimental

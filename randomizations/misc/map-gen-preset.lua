local randnum = require("lib/random/randnum")
local fleish = require("lib/random/fleishman")
local rng = require("lib/random/rng")

local round = function (n)
    return math.floor(n + 0.5)
end

randomizations.map_gen_preset = function (id)
    local preset = {
        order = "randomized",
        basic_settings = {
            autoplace_controls = {},
            property_expression_names = {},
        },
        advanced_settings = {
            asteroids = {},
            pollution = {},
            enemy_evolution = {},
            enemy_expansion = {},
            difficulty_settings = {},
        },
    }
    local mgp = data.raw["map-gen-presets"].default
    mgp["propertyrandomizer"] = preset
    local rng_key = rng.key({ id = id, prototype = mgp })

    local negative_frequency = {
        ["enemy-base"] = true,
        ["fulgora_cliff"] = true,
        ["gleba_cliff"] = true,
        ["gleba_enemy_base"] = true,
        ["nauvis_cliff"] = true,
    }

    local negative_size = {
        ["enemy-base"] = true,
        ["fulgora_cliff"] = true,
        ["gleba_cliff"] = true,
        ["gleba_enemy_base"] = true,
        ["gleba_plants"] = true,
        ["gleba_water"] = true,
        ["nauvis_cliff"] = true,
        ["rocks"] = true,
        ["vulcanus_volcanism"] = true,
        ["water"] = true,
    }

    for ac_name, ac in pairs(data.raw["autoplace-control"]) do
        local fsr = {}
        local dir = 1
        if negative_frequency[ac_name] ~= nil then
            dir = -1
        end
        fsr.frequency = randnum.rand({
            key = rng_key,
            dummy = 1,
            dir = dir,
            variance = "medium",
            rounding = "none",
        })
        dir = 1
        if negative_size[ac_name] ~= nil then
            dir = -1
        end
        fsr.size = randnum.rand({
            key = rng_key,
            dummy = 1,
            dir = dir,
            variance = "medium",
            rounding = "none",
        })
        if ac.richness == true then
            fsr.richness = randnum.rand({
                key = rng_key,
                dummy = 1,
                dir = 1,
                variance = "medium",
                rounding = "none",
            })
        end
        preset.basic_settings.autoplace_controls[ac_name] = fsr
    end

    local pen = preset.basic_settings.property_expression_names
    pen["control:moisture:frequency"] = randnum.rand({
        key = rng_key,
        dummy = 1,
        dir = 1,
        variance = "medium",
        rounding = "none",
    })
    pen["control:moisture:bias"] = fleish.randomize(rng_key, 0, 0.2, global_bias_idx, global_chaos)
    pen["control:aux:frequency"] = randnum.rand({
        key = rng_key,
        dummy = 1,
        dir = 0,
        variance = "medium",
        rounding = "none",
    })
    pen["control:aux:bias"] = fleish.randomize(rng_key, 0, 0.2, 2, global_chaos)

    preset.basic_settings.starting_area = randnum.rand({
        key = rng_key,
        dummy = 1,
        dir = 1,
        variance = "medium",
        rounding = "none",
    })

    local map_settings = data.raw["map-settings"]["map-settings"]
    local enemy_expansion_defaults = map_settings.enemy_expansion
    local enemy_expansion = preset.advanced_settings.enemy_expansion

    enemy_expansion.max_expansion_distance = randnum.rand({
        key = rng_key,
        dummy = enemy_expansion_defaults.max_expansion_distance,
        dir = -1,
        variance = "medium",
        rounding = "discrete",
    })
    enemy_expansion.settler_group_max_size = enemy_expansion_defaults.settler_group_max_size - enemy_expansion_defaults.settler_group_min_size
    enemy_expansion.settler_group_min_size = randnum.rand({
        key = rng_key,
        dummy = enemy_expansion_defaults.settler_group_min_size,
        dir = -1,
        variance = "medium",
        rounding = "discrete",
    })
    enemy_expansion.settler_group_max_size = randnum.rand({
        key = rng_key,
        dummy = enemy_expansion.settler_group_max_size,
        dir = -1,
        variance = "medium",
        rounding = "discrete",
    })
    enemy_expansion.settler_group_max_size = enemy_expansion.settler_group_max_size + enemy_expansion.settler_group_min_size
    local ticks_per_minute = 3600
    enemy_expansion.max_expansion_cooldown = (enemy_expansion_defaults.max_expansion_cooldown - enemy_expansion_defaults.min_expansion_cooldown) / ticks_per_minute
    enemy_expansion.min_expansion_cooldown = enemy_expansion_defaults.min_expansion_cooldown / ticks_per_minute
    enemy_expansion.min_expansion_cooldown = randnum.rand({
        key = rng_key,
        dummy = enemy_expansion.min_expansion_cooldown,
        dir = 1,
        variance = "medium",
        rounding = "discrete_float",
    })
    enemy_expansion.max_expansion_cooldown = randnum.rand({
        key = rng_key,
        dummy = enemy_expansion.max_expansion_cooldown,
        dir = 1,
        variance = "medium",
        rounding = "discrete_float",
    })
    enemy_expansion.max_expansion_cooldown = round((enemy_expansion.max_expansion_cooldown + enemy_expansion.min_expansion_cooldown) * ticks_per_minute)
    enemy_expansion.min_expansion_cooldown = round(enemy_expansion.min_expansion_cooldown * ticks_per_minute)

    local enemy_evolution_defaults = map_settings.enemy_evolution
    local enemy_evolution = preset.advanced_settings.enemy_evolution
    enemy_evolution.time_factor = randnum.rand({
        key = rng_key,
        dummy = enemy_evolution_defaults.time_factor,
        dir = -1,
        variance = "medium",
        rounding = "discrete_float",
    })
    enemy_evolution.destroy_factor = randnum.rand({
        key = rng_key,
        dummy = enemy_evolution_defaults.destroy_factor,
        dir = -1,
        variance = "medium",
        rounding = "discrete_float",
    })
    enemy_evolution.pollution_factor = randnum.rand({
        key = rng_key,
        dummy = enemy_evolution_defaults.pollution_factor,
        dir = -1,
        variance = "medium",
        rounding = "discrete_float",
    })

    local difficulty_settings_defaults = map_settings.difficulty_settings
    local difficulty_settings = preset.advanced_settings.difficulty_settings
    difficulty_settings.technology_price_multiplier = randnum.rand({
        key = rng_key,
        dummy = difficulty_settings_defaults.technology_price_multiplier or 1,
        dir = -1,
        variance = "medium",
        rounding = "discrete_float",
        abs_min = 0.001,
        abs_max = 1000,
    })
    --[[ Turns out this property doesn't exist when it should?
    https://lua-api.factorio.com/latest/types/DifficultySettings.html
    https://lua-api.factorio.com/latest/types/MapGenPresetDifficultySettings.html
    difficulty_settings.spoil_time_modifier = randnum.rand({
        key = rng_key,
        dummy = difficulty_settings_defaults.spoil_time_modifier or 1,
        dir = 1,
        variance = "medium",
        rounding = "discrete_float",
        abs_min = 0.01,
        abs_max = 100,
    })]]

    local pollution_defaults = map_settings.pollution
    local pollution = preset.advanced_settings.pollution
    pollution.ageing = randnum.rand({
        key = rng_key,
        dummy = pollution_defaults.ageing,
        dir = 1,
        variance = "medium",
        rounding = "discrete_float",
        abs_min = 0.1,
    })
    pollution.enemy_attack_pollution_consumption_modifier = randnum.rand({
        key = rng_key,
        dummy = pollution_defaults.enemy_attack_pollution_consumption_modifier,
        dir = 1,
        variance = "medium",
        rounding = "discrete_float",
        abs_min = 0.1,
    })
    pollution.min_pollution_to_damage_trees = randnum.rand({
        key = rng_key,
        dummy = pollution_defaults.min_pollution_to_damage_trees,
        dir = 1,
        variance = "medium",
        rounding = "discrete_float",
    })
    pollution.pollution_restored_per_tree_damage = randnum.rand({
        key = rng_key,
        dummy = pollution_defaults.pollution_restored_per_tree_damage,
        dir = 1,
        variance = "medium",
        rounding = "discrete_float",
    })
    pollution.diffusion_ratio = randnum.rand({
        key = rng_key,
        dummy = pollution_defaults.diffusion_ratio,
        dir = -1,
        variance = "medium",
        rounding = "discrete_float",
        abs_max = 0.25,
    })

    preset.advanced_settings.asteroids.spawning_rate = randnum.rand({
        key = rng_key,
        dummy = map_settings.asteroids.spawning_rate,
        dir = -1,
        variance = "medium",
        rounding = "discrete_float",
    })
end
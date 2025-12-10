local randnum = require("lib/random/randnum")
local fleish = require("lib/random/fleishman")
local rng = require("lib/random/rng")

randomizations.map_gen_preset = function (id)
    local preset = {
        order = "randomized",
        basic_settings = {
            autoplace_controls = {},
            property_expression_names = {},
        },
        advanced_settings = {},
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
end
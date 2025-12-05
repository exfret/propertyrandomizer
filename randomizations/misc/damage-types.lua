
local rng = require("lib/random/rng")
local locale_utils = require("lib/locale")
local trigger_utils = require("lib/trigger")

-- New
randomizations.capsule_damage_types = function (id)
    local damage_type_names = {}
    for name, _ in pairs(data.raw["damage-type"]) do
        table.insert(damage_type_names, name)
    end

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
            capsule.localised_description = {"", locale_utils.find_localised_description(capsule), "\n[color=red](Damage type augment)[/color]"}
        end
    end
end
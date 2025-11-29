local randnum = require("lib/random/randnum")
local rng = require("lib/random/rng")
local locale_utils = require("lib/locale")

local randomize = randnum.rand

-- TODO: Research trigger amounts
-- TODO: Research bonus amounts (like extra bullet damage)

randomizations.tech_costs = function(id)
    for _, tech in pairs(data.raw.technology) do
        if tech.unit ~= nil then
            if tech.unit.count ~= nil then
                local old_count = tech.unit.count

                randomize({
                    id = id,
                    prototype = tech,
                    tbl = tech.unit,
                    property = "count",
                    abs_min = 1,
                    dir = -1,
                    rounding = "discrete"
                })

                locale_utils.create_localised_description(tech, tech.unit.count / old_count, id, {flipped = true})
            else
                -- In this case, we have a count formula
                local key = rng.key({id = id, prototype = tech})
                local formula_multiplier = randomize({
                    key = key,
                    dummy = 1,
                    dir = -1,
                    rounding = "discrete_float"
                })
                tech.unit.count_formula = formula_multiplier .. "*(" .. tech.unit.count_formula .. ")"

                locale_utils.create_localised_description(tech, formula_multiplier, id, {flipped = true})
            end
        end
    end
end

randomizations.tech_times = function(id)
    for _, tech in pairs(data.raw.technology) do
        if tech.unit ~= nil then
            local old_time = tech.unit.time

            randomize({
                id = id,
                prototype = tech,
                tbl = tech.unit,
                property = "time",
                abs_min = 1,
                dir = -1,
                rounding = "discrete_float"
            })

            locale_utils.create_localised_description(tech, tech.unit.time / old_time, id, {flipped = true})
        end
    end
end

randomizations.tech_upgrades = function(id)

    local ignore_modifiers = {
        ["give-item"] = true,
        ["unlock-recipe"] = true,
        ["deconstruction-time-to-live"] = true,
        ["max-failed-attempts-per-tick-per-construction-queue"] = true,
        ["max-successful-attempts-per-tick-per-construction-queue"] = true,
        ["nothing"] = true,
        ["character-logistic-requests"] = true,
        ["unlock-space-location"] = true,
        ["vehicle-logistics"] = true,
        ["unlock-quality"] = true,
        ["unlock-space-platforms"] = true,
        ["unlock-circuit-network"] = true,
        ["cliff-deconstruction-enabled"] = true,
        ["mining-with-fluid"] = true,
        ["rail-support-on-deep-oil-ocean"] = true,
        ["rail-planner-allow-elevated-rails"] = true,
        ["create-ghost-on-entity-death"] = true,
    }

    local integer_modifiers = {
        ["inserter-stack-size-bonus"] = true,
        ["bulk-inserter-capacity-bonus"] = true,
        ["character-logistic-trash-slots"] = true,
        ["maximum-following-robots-count"] = true,
        ["worker-robot-storage"] = true,
        ["character-inventory-slots-bonus"] = true,
        ["character-health-bonus"] = true,
        ["cargo-landing-pad-count"] = true,
        ["belt-stack-size-bonus"] = true,
    }

    local change_property = {
        ["change-recipe-productivity"] = true
    }

    local modifier_names = {
        ["inserter-stack-size-bonus"] = "Inserter stack size bonus",
        ["bulk-inserter-capacity-bonus"] = "Bulk inserter stack size bonus",
        ["laboratory-speed"] = "Research speed bonus",
        ["character-logistic-trash-slots"] = "Trash slot bonus",
        ["maximum-following-robots-count"] = "Robot count bonus",
        ["worker-robot-speed"] = "Robot speed bonus",
        ["worker-robot-storage"] = "Robot cargo size bonus",
        ["turret-attack"] = "Turret damage bonus",
        ["ammo-damage"] = "Ammo damage bonus",
        ["gun-speed"] = "Turret speed bonus",
        ["character-crafting-speed"] = "Crafting speed bonus",
        ["character-mining-speed"] = "Mining speed bonus",
        ["character-running-speed"] = "Walking speed bonus",
        ["character-build-distance"] = "Build distance bonus",
        ["character-item-drop-distance"] = "Item drop distance bonus",
        ["character-reach-distance"] = "Reach distance bonus",
        ["character-resource-reach-distance"] = "Resource reach distance bonus",
        ["character-item-pickup-distance"] = "Item pickup distance bonus",
        ["character-loot-pickup-distance"] = "Loot pickup distance bonus",
        ["character-inventory-slots-bonus"] = "Inventory slot bonus",
        ["character-health-bonus"] = "Health bonus",
        ["mining-drill-productivity-bonus"] = "Mining productivity bonus",
        ["train-braking-force-bonus"] = "Braking force bonus",
        ["worker-robot-battery"] = "Robot battery capacity bonus",
        ["laboratory-productivity"] = "Research productivity bonus",
        ["follower-robot-lifetime"] = "Robot lifetime bonus",
        ["artillery-range"] = "Artillery range bonus",
        ["cargo-landing-pad-count"] = "Cargo landing pad count bonus",
        ["change-recipe-productivity"] = "Productivity bonus",
        ["beacon-distribution"] = "Beacon distribution bonus",
        ["belt-stack-size-bonus"] = "Belt stack size bonus",
    }

    for _, tech in pairs(data.raw.technology) do
        if tech.effects ~= nil then
            for _, modifier in pairs(tech.effects) do
                local target_property = "modifier"
                local abs_max = nil
                if change_property[modifier.type] then
                    target_property = "change"
                    abs_max = 327.66
                end
                if ignore_modifiers[modifier.type] == nil and modifier[target_property] > 0 then
                    local old_value = modifier[target_property]

                    local rounding = "discrete_float"
                    if integer_modifiers[modifier.type] then
                        rounding = "discrete"
                    end

                    randomize({
                        id = id,
                        prototype = tech,
                        tbl = modifier,
                        property = target_property,
                        rounding = rounding,
                        variance = "big",
                        abs_max = abs_max,
                    })

                    local name = modifier_names[modifier.type]
                    local factor = modifier[target_property] / old_value
                    locale_utils.create_localised_description(tech, factor, id, {addons = name})
                end
            end
        end
    end
end
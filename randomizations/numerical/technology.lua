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
                    bias = 0.05,
                    dir = -1,
                    rounding = "discrete",
                    data_type = "uint64",
                })

                locale_utils.create_localised_description(tech, tech.unit.count / old_count, id, {flipped = true})
            else
                -- In this case, we have a count formula
                local key = rng.key({id = id, prototype = tech})
                local formula_multiplier = randomize({
                    id = id,
                    key = key,
                    dummy = 1,
                    bias = 0.05,
                    dir = -1,
                    rounding = "discrete_float"
                })
                tech.unit.count_formula = formula_multiplier .. "*(" .. tech.unit.count_formula .. ")"

                locale_utils.create_localised_description(tech, formula_multiplier, id, {flipped = true})
            end
        end
    end
end

randomizations.tech_craft_requirement = function (id)
    for _, tech in pairs(data.raw.technology or {}) do
        if tech.research_trigger ~= nil
        and tech.research_trigger.count ~= nil
        and tech.research_trigger.count > 1 then
            local rounding = "discrete_float"
            -- A craft-item trigger's count is a whole number (CraftItemTechnologyTrigger::count is an ItemCountType, a uint32)
            if tech.research_trigger.type == "craft-item" then
                rounding = "discrete"
            end

            local old_value = tech.research_trigger.count

            randomize({
                id = id,
                prototype = tech,
                tbl = tech.research_trigger,
                property = "count",
                rounding = rounding,
                variance = "medium",
                dir = -1,
                abs_min = 2,
                data_type = "uint32",
            })

            local factor = tech.research_trigger.count / old_value
            locale_utils.create_localised_description(tech, factor, id, {flipped = true})
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
                bias = 0.05,
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
        ["inserter-stack-size-bonus"] = {"propertyrandomizer-modifier.inserter-stack-size-bonus"},
        ["bulk-inserter-capacity-bonus"] = {"propertyrandomizer-modifier.bulk-inserter-capacity-bonus"},
        ["laboratory-speed"] = {"propertyrandomizer-modifier.laboratory-speed"},
        ["character-logistic-trash-slots"] = {"propertyrandomizer-modifier.character-logistic-trash-slots"},
        ["maximum-following-robots-count"] = {"propertyrandomizer-modifier.maximum-following-robots-count"},
        ["worker-robot-speed"] = {"propertyrandomizer-modifier.worker-robot-speed"},
        ["worker-robot-storage"] = {"propertyrandomizer-modifier.worker-robot-storage"},
        ["turret-attack"] = {"propertyrandomizer-modifier.turret-attack"},
        ["ammo-damage"] = {"propertyrandomizer-modifier.ammo-damage"},
        ["gun-speed"] = {"propertyrandomizer-modifier.gun-speed"},
        ["character-crafting-speed"] = {"propertyrandomizer-modifier.character-crafting-speed"},
        ["character-mining-speed"] = {"propertyrandomizer-modifier.character-mining-speed"},
        ["character-running-speed"] = {"propertyrandomizer-modifier.character-running-speed"},
        ["character-build-distance"] = {"propertyrandomizer-modifier.character-build-distance"},
        ["character-item-drop-distance"] = {"propertyrandomizer-modifier.character-item-drop-distance"},
        ["character-reach-distance"] = {"propertyrandomizer-modifier.character-reach-distance"},
        ["character-resource-reach-distance"] = {"propertyrandomizer-modifier.character-resource-reach-distance"},
        ["character-item-pickup-distance"] = {"propertyrandomizer-modifier.character-item-pickup-distance"},
        ["character-loot-pickup-distance"] = {"propertyrandomizer-modifier.character-loot-pickup-distance"},
        ["character-inventory-slots-bonus"] = {"propertyrandomizer-modifier.character-inventory-slots-bonus"},
        ["character-health-bonus"] = {"propertyrandomizer-modifier.character-health-bonus"},
        ["mining-drill-productivity-bonus"] = {"propertyrandomizer-modifier.mining-drill-productivity-bonus"},
        ["train-braking-force-bonus"] = {"propertyrandomizer-modifier.train-braking-force-bonus"},
        ["worker-robot-battery"] = {"propertyrandomizer-modifier.worker-robot-battery"},
        ["laboratory-productivity"] = {"propertyrandomizer-modifier.laboratory-productivity"},
        ["follower-robot-lifetime"] = {"propertyrandomizer-modifier.follower-robot-lifetime"},
        ["artillery-range"] = {"propertyrandomizer-modifier.artillery-range"},
        ["cargo-landing-pad-count"] = {"propertyrandomizer-modifier.cargo-landing-pad-count"},
        ["change-recipe-productivity"] = {"propertyrandomizer-modifier.change-recipe-productivity"},
        ["beacon-distribution"] = {"propertyrandomizer-modifier.beacon-distribution"},
        ["belt-stack-size-bonus"] = {"propertyrandomizer-modifier.belt-stack-size-bonus"},
    }

    for _, tech in pairs(data.raw.technology) do
        if tech.effects ~= nil then
            for _, modifier in pairs(tech.effects) do
                local target_property = "modifier"
                local abs_max = nil
                if change_property[modifier.type] then
                    target_property = "change"
                    abs_max = 300
                end
                if ignore_modifiers[modifier.type] == nil and type(modifier[target_property]) == "number" and modifier[target_property] > 0 then
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
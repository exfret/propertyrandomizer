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
            if tech.research_trigger == "craft-item" then
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

    -- TODO: Use locale for this
    local modifier_names = {
        ["inserter-stack-size-bonus"] = "Inserter stack size bonus effectiveness",
        ["bulk-inserter-capacity-bonus"] = "Bulk inserter stack size bonus effectiveness",
        ["laboratory-speed"] = "Research speed bonus effectiveness",
        ["character-logistic-trash-slots"] = "Trash slot bonus effectiveness",
        ["maximum-following-robots-count"] = "Robot count bonus effectiveness",
        ["worker-robot-speed"] = "Robot speed bonus effectiveness",
        ["worker-robot-storage"] = "Robot cargo size bonus effectiveness",
        ["turret-attack"] = "Turret damage bonus effectiveness",
        ["ammo-damage"] = "Ammo damage bonus effectiveness",
        ["gun-speed"] = "Turret speed bonus effectiveness",
        ["character-crafting-speed"] = "Crafting speed bonus effectiveness",
        ["character-mining-speed"] = "Mining speed bonus effectiveness",
        ["character-running-speed"] = "Walking speed bonus effectiveness",
        ["character-build-distance"] = "Build distance bonus effectiveness",
        ["character-item-drop-distance"] = "Item drop distance bonus effectiveness",
        ["character-reach-distance"] = "Reach distance bonus effectiveness",
        ["character-resource-reach-distance"] = "Resource reach distance bonus effectiveness",
        ["character-item-pickup-distance"] = "Item pickup distance bonus effectiveness",
        ["character-loot-pickup-distance"] = "Loot pickup distance bonus effectiveness",
        ["character-inventory-slots-bonus"] = "Inventory slot bonus effectiveness",
        ["character-health-bonus"] = "Health bonus effectiveness",
        ["mining-drill-productivity-bonus"] = "Mining productivity bonus effectiveness",
        ["train-braking-force-bonus"] = "Braking force bonus effectiveness",
        ["worker-robot-battery"] = "Robot battery capacity bonus effectiveness",
        ["laboratory-productivity"] = "Research productivity bonus effectiveness",
        ["follower-robot-lifetime"] = "Robot lifetime bonus effectiveness",
        ["artillery-range"] = "Artillery range bonus effectiveness",
        ["cargo-landing-pad-count"] = "Cargo landing pad count bonus effectiveness",
        ["change-recipe-productivity"] = "Productivity bonus effectiveness",
        ["beacon-distribution"] = "Beacon distribution bonus effectiveness",
        ["belt-stack-size-bonus"] = "Belt stack size bonus effectiveness",
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
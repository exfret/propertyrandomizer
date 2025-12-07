local randnum = require("lib/random/randnum")
local randprob = require("lib/random/randprob")
local trigger_utils = require("lib/trigger")
local locale_utils = require("lib/locale")


-- New
randomizations.chain_max_jumps = function (id)
    local chains = trigger_utils.get_creator_table("chain-active-trigger")

    local target_classes = {
        ["ammo"] = true,
    }

    for chain_name, creators in pairs(chains) do
        local affected_prototypes = {}

        for _, prototype in pairs(creators) do
            if target_classes[prototype.type] ~= nil then
                affected_prototypes[#affected_prototypes+1] = prototype
            end
        end

        if #affected_prototypes > 0 then
            local chain = data.raw["chain-active-trigger"][chain_name]
            if chain.max_jumps == nil then
                chain.max_jumps = 5
            end

            local old_value = chain.max_jumps

            randnum.rand({
                id = id,
                prototype = chain,
                property = "max_jumps",
                rounding = "discrete",
                variance = "small",
            })

            local factor = chain.max_jumps / old_value

            for _, prototype in pairs(affected_prototypes) do
                locale_utils.create_localised_description(prototype, factor, id, { variance = "small" })
            end
        end
    end
end

-- New
randomizations.chain_fork_chance = function (id)
    local chains = trigger_utils.get_creator_table("chain-active-trigger")

    local target_classes = {
        ["ammo"] = true,
    }

    for chain_name, creators in pairs(chains) do
        local affected_prototypes = {}

        for _, prototype in pairs(creators) do
            if target_classes[prototype.type] ~= nil then
                affected_prototypes[#affected_prototypes+1] = prototype
            end
        end

        if #affected_prototypes > 0 then
            local chain = data.raw["chain-active-trigger"][chain_name]
            if chain.fork_chance ~= nil and chain.fork_chance > 0 then
                local old_value = chain.fork_chance

                randprob.rand({
                    id = id,
                    prototype = chain,
                    property = "fork_chance",
                    rounding = "discrete_float",
                    variance = "small",
                })

                local factor = randprob.calc_odds_factor(old_value, chain.fork_chance)

                for _, prototype in pairs(affected_prototypes) do
                    locale_utils.create_localised_description(prototype, factor, id, { variance = "small" })
                end
            end
        end
    end
end
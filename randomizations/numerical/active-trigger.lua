local randnum = require("lib/random/randnum")
local randprob = require("lib/random/randprob")
local indirect = require("randomizations/helper/indirect")
local locale_utils = require("lib/locale")


-- New
randomizations.chain_max_jumps = function (id)
    indirect.iterate_child_prototypes("chain-active-trigger", function (chain, parents, structs, is_enemy)
        local dir = 1
        if is_enemy then
            dir = -1
        end

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
            dir = dir,
            data_type = "uint32",
        })

        local factor = chain.max_jumps / old_value

        for _, parent in pairs(parents) do
            locale_utils.create_localised_description(parent, factor, id, { flipped = dir < 0, variance = "small" })
        end
    end)
end

-- New
randomizations.chain_fork_chance = function (id)
    indirect.iterate_child_prototypes("chain-active-trigger", function (chain, parents, structs, is_enemy)
        if chain.fork_chance ~= nil and chain.fork_chance > 0 then
            local dir = 1
            if is_enemy then
                dir = -1
            end

            local old_value = chain.fork_chance

            randprob.rand({
                id = id,
                prototype = chain,
                property = "fork_chance",
                rounding = "discrete_float",
                variance = "small",
                dir = dir,
            })

            local factor = randprob.calc_odds_factor(old_value, chain.fork_chance)

            for _, prototype in pairs(parents) do
                locale_utils.create_localised_description(prototype, factor, id, { flipped = dir < 0, variance = "small" })
            end
        end
    end)
end
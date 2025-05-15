local randnum = require("lib/random/randnum")
local rng = require("lib/random/rng")

local randomize = randnum.rand

-- In params is also included "prototypes" and "tbls", which is all tbls to be rando'd
-- Also has "separated" argument, which if set does not randomize prototypes with same property value to same amount
randomizations.linked = function(params)
    if params.tbls == nil then
        params.tbls = params.prototypes
    end

    local prototype_tier_groups = {}
    local prototype_tier_numbers = {}
    for ind, tbl in pairs(params.tbls) do
        if not params.separated then
            if prototype_tier_groups[tbl[params.property]] == nil then
                prototype_tier_groups[tbl[params.property]] = {}
                table.insert(prototype_tier_numbers, tbl[params.property])
            end

            table.insert(prototype_tier_groups[tbl[params.property]], tbl)
        else
            table.insert(prototype_tier_numbers, tbl[params.property])
            table.insert(prototype_tier_groups, tbl)
        end
    end
    table.sort(prototype_tier_numbers)

    local new_prototype_tier_numbers = {}
    for _, number in pairs(prototype_tier_numbers) do
        local params_to_pass = table.deepcopy(params)
        params_to_pass.key = rng.key({linked = true, id = params.id, tier = number})
        params_to_pass.dummy = number

        table.insert(new_prototype_tier_numbers, randomize(params_to_pass))
    end
    table.sort(new_prototype_tier_numbers)

    for ind, orig_number in pairs(prototype_tier_numbers) do
        if not params.separated then
            for _, tbl in pairs(prototype_tier_groups[orig_number]) do
                tbl[params.property] = new_prototype_tier_numbers[ind]
            end
        else
            prototype_tier_groups[ind][params.property] = new_prototype_tier_numbers[ind]
        end
    end
end
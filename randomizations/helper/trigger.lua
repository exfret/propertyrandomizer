local randnum = require("lib/random/randnum")

local randomize = randnum.rand

randomizations.trigger_effect_item = function(params, tbl, target)
    local targets = {}

    -- Testing for >0 makes sure it's not healing
    if tbl.type == "damage" and tbl.damage.amount > 0 and target == "damage" then
        params.tbl = tbl.damage
        params.property = "amount"
        randomize(params)
    end
    if tbl.type == "damage" and tbl.damage.amount < 0 and target == "healing" then
        params.tbl = tbl.damage
        params.property = "amount"
        -- Make this positive temporarily so that it randomizes correctly
        tbl.damage.amount = -tbl.damage.amount
        randomize(params)
        -- Now revert back to negative
        tbl.damage.amount = -tbl.damage.amount
    end
    if tbl.type == "damage" and tbl.damage.amount > 0 and target == "gather-damage" then
        table.insert(targets, tbl.damage)
    end
    if tbl.type == "damage" and tbl.damage.amount < 0 and target == "gather-healing" then
        table.insert(targets, tbl.damage)
    end

    if tbl.type == "create-sticker" and target == "gather-stickers" then
        table.insert(targets, tbl.sticker)
    end

    if tbl.type == "nested-result" then
        local new_targets = randomizations.trigger(params, tbl.action, target)
        for _, target in pairs(new_targets) do
            table.insert(targets, target)
        end
    end

    return targets
end

randomizations.trigger_delivery = function(params, tbl, target)
    local targets = {}

    if tbl.type == "artillery" and target == "gather-artillery-projectiles" then
        table.insert(targets, tbl.projectile)
    end
    if tbl.type == "projectile" and target == "gather-projectiles" then
        table.insert(targets, tbl.projectile)
    end

    for _, effect_property in pairs({"source_effects", "target_effects"}) do
        local trigger_effect = tbl[effect_property]

        if trigger_effect ~= nil then
            if trigger_effect.type ~= nil then
                local new_targets = randomizations.trigger_effect_item(params, trigger_effect, target)
                for _, target in pairs(new_targets) do
                    table.insert(targets, target)
                end
            else
                for _, trigger_effect_item in pairs(trigger_effect) do
                    local new_targets = randomizations.trigger_effect_item(params, trigger_effect_item, target)
                    for _, target in pairs(new_targets) do
                        table.insert(targets, target)
                    end
                end
            end
        end
    end

    return targets
end

randomizations.trigger_item = function(params, tbl, target)
    local targets = {}

    if tbl.type == "area" and target == "effect-radius" then
        params.tbl = tbl
        params.property = "radius"
        randomize(params)
    end

    if tbl.action_delivery ~= nil then
        if tbl.action_delivery.type ~= nil then
            local new_targets = randomizations.trigger_delivery(params, tbl.action_delivery, target)
            for _, target in pairs(new_targets) do
                table.insert(targets, target)
            end
        else
            for _, trigger_delivery in pairs(tbl.action_delivery) do
                local new_targets = randomizations.trigger_delivery(params, trigger_delivery, target)
                for _, target in pairs(new_targets) do
                    table.insert(targets, target)
                end
            end
        end
    end

    return targets
end

randomizations.trigger = function(params, tbl, target)
    local targets = {}

    if tbl.type ~= nil then
        local new_targets = randomizations.trigger_item(params, tbl, target)
        for _, target in pairs(new_targets) do
            table.insert(targets, target)
        end
    else
        for _, val in pairs(tbl) do
            local new_targets = randomizations.trigger_item(params, val, target)
            for _, target in pairs(new_targets) do
                table.insert(targets, target)
            end
        end
    end

    return targets
end
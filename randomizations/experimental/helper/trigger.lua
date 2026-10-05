-- Parked military/resistance experiment. Installed only by the explicit experimental flag.
local randnum = require("lib/random/randnum")
local combat_adapters = require("lib/random/combat-adapters")
local randomize = randnum.rand

local experimental = {}

experimental.trigger_effect_item = function(params, tbl, target)
    local targets = {}

    -- Testing for >0 makes sure it's not healing
    if tbl.type == "damage" and tbl.damage.amount > 0 and target == "damage" then
        params.tbl = tbl.damage
        params.property = "amount"
        randomize(params)
    end
    if tbl.type == "damage" and tbl.damage.amount < 0 and target == "healing" then
        local adapter = combat_adapters.scaled(tbl.damage, "amount", -1, false)
        params.dummy = adapter.read()
        params.combat = adapter
        randomize(params)
        params.dummy = nil
        params.combat = nil
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

return experimental

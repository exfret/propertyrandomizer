-- Whether an extracted impact can run at a position without a hit entity.
-- Runtime probe (2026-10-12): a placed grenade's area damage hit a chest, while a rocket's direct damage did not, even at the chest's position.
-- Direct damage and stickers require a hit target; nested area triggers provide their own targets.
local impact = {}

impact.at_position = function(action)
    if action == nil then return false end
    for _, entry in pairs(action.type ~= nil and {action} or action) do
        local sent = entry.action_delivery
        for _, delivery in pairs(sent ~= nil and (sent.type ~= nil and {sent} or sent) or {}) do
            local effects = delivery.target_effects
            for _, effect in pairs(effects ~= nil and (effects.type ~= nil and {effects} or effects) or {}) do
                if entry.type == "direct" and (effect.type == "damage" or effect.type == "create-sticker") then return false end
                if effect.action ~= nil and entry.type == "direct" and not impact.at_position(effect.action) then return false end
            end
        end
    end
    return true
end

return impact

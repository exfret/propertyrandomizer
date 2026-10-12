local claim_tool = {}

claim_tool.on_selected = function(event)
    if event.item ~= "propertyrandomizer-claim" then
        return
    end
    local player = game.get_player(event.player_index)
    if player == nil then
        return
    end
    for _, entity in pairs(event.entities) do
        if entity.valid and entity.force == game.forces.neutral then
            entity.force = player.force
        end
    end
end

return claim_tool

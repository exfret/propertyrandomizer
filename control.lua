script.on_init(function(event)
    storage.printed_change_surface_message = false
    storage.player_ind_to_last_return_attempt_ticks = {}
end)

script.on_event("return-to-nauvis", function(event)
    if game.players[event.player_index].get_inventory(defines.inventory.character_main).is_empty() then
        -- 5 seconds to press again
        if storage.player_ind_to_last_return_attempt_ticks[event.player_index] == nil or event.tick - storage.player_ind_to_last_return_attempt_ticks[event.player_index] > 5 * 60 then
            game.players[event.player_index].print("[img=item.propertyrandomizer-gear] [color=red]exfret's Randomizer:[/color] Respawn key sequence entered. Enter again within 5 seconds to confirm.")
        else
            game.players[event.player_index].teleport(game.surfaces.nauvis.find_non_colliding_position("character", {0, 0}, 0, 1), "nauvis")
        end

        storage.player_ind_to_last_return_attempt_ticks[event.player_index] = event.tick
    else
        game.players[event.player_index].print("[img=item.propertyrandomizer-gear] [color=red]exfret's Randomizer:[/color] Respawn key sequence entered, but your inventory was not empty. Empty your inventory and try again.")
    end
end)

script.on_event(defines.events.on_player_changed_surface, function(event)
    if not storage.printed_change_surface_message then
        storage.printed_change_surface_message = true
        game.print("[img=item.propertyrandomizer-gear] [color=red]exfret's Randomizer:[/color] To prevent softlocks, you can use the respawn key sequence (by default, CTRL + SHIFT + R) to return home at any time. You must have an empty inventory.")
    end
end)

script.on_nth_tick(1, function(event)
    -- Print warnings on 10th tick
    if event.tick == 10 then
        if settings.startup["propertyrandomizer-seed"].value == 23 then
            -- CRITICAL TODO: Add back in?
            game.print("[img=item.propertyrandomizer-gear] [color=red]exfret's Randomizer:[/color] You are on the default seed. If you want things randomized in another way for a new experience, change the \"seed\" setting under mod settings in the menu.")
        end

        local table_to_load = prototypes.item["propertyrandomizer-warnings"].get_entity_type_filters(defines.selection_mode.select)
        for data, _ in pairs(table_to_load) do
            local _, warnings = serpent.load(data)
            for _, warning in pairs(warnings) do
                game.print(warning)
            end
        end
    end
end)
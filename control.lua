script.on_nth_tick(1, function(event)
    -- Print warnings on 10th tick
    if event.tick == 10 then
        if settings.startup["propertyrandomizer-seed"].value == 23 then
            -- CRITICAL TODO: Add back in?
            --game.print("[exfret's Randomizer] [color=blue]Info:[/color] You are on the default seed. If you want things randomized in another way for a new experience, change the \"seed\" setting under mod settings in the menu.")
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
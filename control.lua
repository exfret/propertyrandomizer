-- TODO: Split off explorer panel into seperate file.

local gui = require("scripts/gui")
local constants = require("helper-tables/constants")
local top = require("lib/graph/consistent-sort")
-- Used for getting key
local gutils = require("lib/graph/graph-utils")

local function load_dep_graph()
    for data, _ in pairs(prototypes.item["propertyrandomizer-graph"].get_entity_type_filters(defines.selection_mode.select)) do
        local _, graph = serpent.load(data)
        storage.graph = graph
        break
    end
    storage.sort_info = top.sort(storage.graph)

    storage.tech_graph = storage.graph
    local tech_graph = storage.tech_graph
    for _, node in pairs(tech_graph.nodes) do
        if node.type == "technology" and not game.forces.player.technologies[node.name].researched then
            gutils.add_edge(tech_graph, gutils.key("false", ""), node)
        end
    end
    storage.tech_sort_info = top.sort(tech_graph)
end

script.on_init(function(event)
    storage.printed_change_surface_message = false
    storage.player_ind_to_last_return_attempt_ticks = {}

    -- Give ability to mine fluid immediately to make things easier
    game.forces.player.mining_with_fluid = true

    load_dep_graph()

    for data, _ in pairs(prototypes.item["propertyrandomizer-slot-to-trav"].get_entity_type_filters(defines.selection_mode.select)) do
        local _, slot_to_trav = serpent.load(data)
        storage.slot_to_trav = slot_to_trav
        break
    end

    if script.active_mods["pyalternativeenergy"] and slot_to_trav ~= nil then
        if remote.interfaces["freeplay"] ~= nil and remote.interfaces["freeplay"]["get_created_items"] ~= nil and remote.interfaces["freeplay"]["set_created_items"] ~= nil then
            local items = remote.call("freeplay", "get_created_items")
            local ship_items = remote.call("freeplay", "get_ship_items")
            local debris_items = remote.call("freeplay", "get_debris_items")
            local respawn_items = remote.call("freeplay", "get_respawn_items")

            for _, item_list in pairs({items, ship_items, debris_items, respawn_items}) do
                local new_item_list = {}
                local old_item_names = {}
                for item_name, amount in pairs(item_list) do
                    local new_item_name
                    local slot_key = gutils.key("item", item_name)
                    local trav_key = storage.slot_to_trav[slot_key]
                    -- Excluded from first pass
                    if trav_key == nil then
                        new_item_name = item_name
                    else
                        local trav = gutils.deconstruct(trav_key)
                        local suffix = "-trav"
                        new_item_name = string.sub(trav.name, 1, -(string.len(suffix) + 1))
                    end
                    new_item_list[new_item_name] = amount
                    table.insert(old_item_names, item_name)
                end
                for _, item_name in pairs(old_item_names) do
                    item_list[item_name] = nil
                end
                for k, v in pairs(new_item_list) do
                    item_list[k] = v
                end
            end

            remote.call("freeplay", "set_created_items", items)
            remote.call("freeplay", "set_ship_items", ship_items)
            remote.call("freeplay", "set_debris_items", debris_items)
            remote.call("freeplay", "set_respawn_items", respawn_items)
        end
    end
end)

script.on_configuration_changed(function(event)
    game.print("[img=item.propertyrandomizer-gear] [color=red]exfret's Randomizer:[/color] Mod configuration was changed; keep in mind that updates may break pre-existing runs.\nYou can sync the exact versions of mods by Ctrl + Left Click on the \"Sync mods\" button on the top right when selecting a save to load.\nIf you need any help, message exfret on discord or on the mod's website - mods.factorio.com/mod/propertyrandomizer")

    load_dep_graph()
end)

script.on_event(defines.events.on_research_finished, function(event)
    local research = event.research
    local tech_graph = storage.tech_graph
    local node_key = gutils.key("technology", research.name)
    local node = tech_graph.nodes[node_key]
    local remove_edge_key = gutils.ekey({start = gutils.key("false", ""), stop = node_key})
    if tech_graph.edges[remove_edge_key] ~= nil then
        gutils.remove_edge(tech_graph, remove_edge_key)
        local new_edge = gutils.add_edge(tech_graph, gutils.key("true", ""), node)
        storage.tech_sort_info = top.sort(tech_graph, storage.tech_sort_info, {tech_graph.nodes[new_edge.start], tech_graph.nodes[new_edge.stop]})
    end
end)

script.on_event("return-to-starting-planet", function(event)
    local inventories_to_be_empty = {
        defines.inventory.character_main,
        defines.inventory.character_ammo,
        defines.inventory.character_guns,
        defines.inventory.character_trash
    }

    local all_empty = true
    for _, inv in pairs(inventories_to_be_empty) do
        -- Was getting nil error so double check this inventory exists
        local player = game.players[event.player_index]
        local inventory = game.players[event.player_index].get_inventory(inv)
        if inventory ~= nil and inventory.valid then
            if not inventory.is_empty() then
                all_empty = false
            end
        end
    end

    if all_empty then
        -- 5 seconds to press again
        if storage.player_ind_to_last_return_attempt_ticks[event.player_index] == nil or event.tick - storage.player_ind_to_last_return_attempt_ticks[event.player_index] > 5 * 60 then
            game.players[event.player_index].print("[img=item.propertyrandomizer-gear] [color=red]exfret's Randomizer:[/color] Respawn key sequence entered. Enter again within 5 seconds to confirm.")
        else
            game.players[event.player_index].teleport(game.surfaces[constants.starting_planet].find_non_colliding_position("character", {0, 0}, 0, 1), constants.starting_planet)
        end

        storage.player_ind_to_last_return_attempt_ticks[event.player_index] = event.tick
    else
        game.players[event.player_index].print("[img=item.propertyrandomizer-gear] [color=red]exfret's Randomizer:[/color] Respawn key sequence entered, but your inventory was not empty. Empty your inventory and try again.")
    end
end)

script.on_event(defines.events.on_cargo_pod_finished_descending, function(event)
    if event.player_index ~= nil and not storage.printed_change_surface_message then
        storage.printed_change_surface_message = true
        game.print("[img=item.propertyrandomizer-gear] [color=red]exfret's Randomizer:[/color] To prevent softlocks, you can use the respawn key sequence (by default, CTRL + SHIFT + R) to return home at any time. You must have an empty inventory.")
    end
end)

script.on_event(defines.events.on_script_trigger_effect, function(event)
    if event.effect_id == "teleport-player" then
        local position_to_teleport_to = game.surfaces[event.surface_index].find_non_colliding_position(event.source_entity.name, event.target_position, 5, 0.1)
        if position_to_teleport_to ~= nil then
            event.source_entity.teleport(position_to_teleport_to)
        end
    end
end)

script.on_event(defines.events.on_built_entity, function(event)
    -- I used to make built biters etc. into enemies but actually I think I prefer them as on the player force
end)

script.on_event(defines.events.on_script_trigger_effect, function(event)
    if event.effect_id == "randomizer-follower-robot-created" then
        local nearest_player
        local nearest_player_dist
        for _, player in pairs(game.players) do
            if player.character ~= nil then
                local player_pos = player.character.position
                local offset_x = player_pos.x - event.source_entity.position.x
                local offset_y = player_pos.y - event.source_entity.position.y
                local player_dist = offset_x * offset_x + offset_y * offset_y
                if nearest_player_dist == nil or player_dist < nearest_player_dist then
                    nearest_player = player
                    nearest_player_dist = player_dist
                end
            end
        end
        storage.combat_robot_entity_to_assign = storage.entity_to_assign or {}
        table.insert(storage.combat_robot_entity_to_assign, {event.source_entity, nearest_player.character})
        --event.source_entity.combat_robot_owner = nearest_player.character
    end
end)

script.on_event(defines.events.on_post_entity_died, function(event)
    if string.find(event.prototype.name, "exfret%-unit") ~= nil then
        for _, corpse in pairs(event.corpses) do
            corpse.force = "player"
        end
    end
end)

script.on_nth_tick(1, function(event)
    if storage.combat_robot_entity_to_assign ~= nil then
        for _, spec in pairs(storage.combat_robot_entity_to_assign) do
            spec[1].combat_robot_owner = spec[2]
        end
        storage.combat_robot_entity_to_assign = nil
    end

    -- Print warnings on 10th tick
    if event.tick == 10 then
        -- Check seed to see whether to print info message
        if settings.startup["propertyrandomizer-seed"].value == 0 then
            game.print("[img=item.propertyrandomizer-gear] [color=red]exfret's Randomizer:[/color] You are on the default seed. See mod settings for customization. Note that some randomizations like recipes are off by default due to slow load times. Also consider turning on prototype caching for faster load times on future game startups (ctrl + shift + click settings, click \"The Rest\", then search for prototype caching).")
        end

        local table_to_load = prototypes.item["propertyrandomizer-warnings"].get_entity_type_filters(defines.selection_mode.select)
        for data, _ in pairs(table_to_load) do
            local _, warnings = serpent.load(data)
            for _, warning in pairs(warnings) do
                if type(warning) == "string" then
                    storage.there_was_warning = true
                    game.print(warning)
                end
            end
        end
    elseif event.tick >= 60 and game.connected_players ~= nil and #game.connected_players >= 1 and game.connected_players[1].controller_type ~= defines.controllers.cutscene and not storage.gave_warning_flying_text and storage.there_was_warning then
        storage.gave_warning_flying_text = true
        for _, player in pairs(game.players) do
            player.create_local_flying_text({text="Hm... I should check randomizer warnings in chat.", position={player.position.x, player.position.y - 1.5}, time_to_live=300, speed = 0.7})
        end
    end
end)
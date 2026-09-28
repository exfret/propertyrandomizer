-- TODO: Check collision masks!

local gutils = require("lib/graph/graph-utils")
local dutils = require("lib/data-utils")

local entity_autoplace = {}

-- TODO: What to do about vulcanus chimneys being so awful to mine?
-- TODO: Add back ability to build etc. turrets; right now they're too strong against their biter brethren and are needed for defending the nests
local autoplace_blacklist_types = {
    ["resource"] = true,
    ["unit-spawner"] = true,
    ["plant"] = true, -- Includes yumako/jellynut
    ["turret"] = true,
    -- TODO: Maybe special compatibility for fish by changing collision masks and such?
    ["fish"] = true,
}

entity_autoplace.id = "entity_autoplace"

entity_autoplace.with_replacement = false

entity_autoplace.ignore_nil_contexts = true

-- Used to make sure we only zero out an autoplace once
local processed_autoplaces
local processed_entity_autoplace
entity_autoplace.initialize = function()
    processed_autoplaces = {}
    processed_entity_autoplace = {}
end

entity_autoplace.spoof = function(graph)
    local spoof_autoplace = gutils.add_node(graph, "room-autoplace", "entity-autoplace-spoofed-room")
    spoof_autoplace.op = "OR"
    spoof_autoplace.spoof = true
    for _, node in pairs(graph.nodes) do
        if node.type == "entity" then
            local entity = dutils.get_prot("entity", node.name)
            if entity.autoplace == nil then
                gutils.add_edge(graph, spoof_autoplace, node)
            end
        end
    end
end

entity_autoplace.claim = function(graph, prereq, dep, edge)
    if dep.type == "entity" then
        local orand_parent = dep--graph.nodes[graph.orand_to_parent[gutils.key(dep)]]
        if prereq.type == "room-autoplace" and orand_parent.type == "entity" then
            local entity = dutils.get_prot("entity", orand_parent.name)
            -- If autoplace is mysteriously nil, return
            if entity.autoplace == nil then
                -- I'll just fix the issue now instead of having this check
                --return false
            end
            if autoplace_blacklist_types[entity.type] then
                return false
            end
            -- Don't allow sensitive things that unlock techs from being mined to be randomized, since we can't guarantee they'll actually show up due to collision box issues
            if lookups.entities_with_mine_tech_unlocks[entity.name] then
                return false
            end

            -- Prereq limited rando
            return 1
        end
    end
end

entity_autoplace.validate = function(graph, base, head, extra)
    local base_owner = gutils.get_owner(graph, base)

    if base_owner.type ~= "room-autoplace" then
        return false
    end

    return true
end

entity_autoplace.reflect = function(graph, head_to_base, head_to_handler)
    for head_key, base_key in pairs(head_to_base) do
        if head_to_handler[head_key].id == "entity_autoplace" then
            local base = graph.nodes[base_key]
            local base_owner = gutils.get_owner(graph, base)
            local head = graph.nodes[head_key]
            local head_owner = graph.nodes[graph.orand_to_parent[gutils.key(gutils.get_owner(graph, head))]]

            -- Only need to worry about base spoofs
            if base_owner.spoof then
                local head_entity = dutils.get_prot("entity", head_owner.name)
                head_entity.autoplace = nil
            else
                local base_entity = dutils.get_prot("entity", base.entity)
                base_entity = unified_starting_data_raw[base_entity.type][base_entity.name]
                local head_entity = dutils.get_prot("entity", head_owner.name)
                if not processed_entity_autoplace[base_entity.name] then
                    data.raw[base_entity.type][base_entity.name].autoplace = nil
                end
                head_entity.autoplace = table.deepcopy(base_entity.autoplace)
                -- Change forces so it can be decon'd
                head_entity.autoplace.force = "neutral"
                -- Make sure we don't set head_entity's autoplace to nil later
                processed_entity_autoplace[head_entity.name] = true

                -- Switch autoplace settings
                for _, planet in pairs(unified_starting_data_raw.planet) do
                    local map_gen_settings = planet.map_gen_settings
                    if map_gen_settings ~= nil then
                        -- TODO: Account for autoplace controls as well
                        local autoplace_settings = map_gen_settings.autoplace_settings
                        if autoplace_settings ~= nil then
                            local entity_settings = autoplace_settings.entity.settings
                            if entity_settings[base_entity.name] ~= nil then
                                local data_raw_settings = data.raw.planet[planet.name].map_gen_settings.autoplace_settings.entity.settings
                                data_raw_settings[head_entity.name] = entity_settings[base_entity.name]
                                processed_autoplaces[planet.name] = processed_autoplaces[planet.name] or {}
                                if not processed_autoplaces[planet.name][base_entity.name] then
                                    processed_autoplaces[planet.name][base_entity.name] = true
                                    data_raw_settings[base_entity.name] = nil
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

return entity_autoplace
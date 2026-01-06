local gutils = require("new-lib/graph/graph-utils")

local tech_science_packs = {}

-- Claim edges from science-pack-set-science to technology
tech_science_packs.claim = function(graph, prereq, dep, trav)
    if prereq.type == "science-pack-set-science" and dep.type == "technology" then
        return 1
    end
end

-- Accept any match for now
tech_science_packs.validate = function(graph, slot, trav, extra)
    local slot_owner = gutils.get_conn_owner(graph, slot)
    if slot_owner.type == "science-pack-set-science" then
        return true
    end
end

-- Apply science pack changes to data.raw
tech_science_packs.reflect = function(graph, trav_to_new_slot, trav_to_old_slot)
    for trav_key, slot in pairs(trav_to_new_slot) do
        local trav = graph.nodes[trav_key]
        local trav_owner = gutils.get_conn_owner(graph, trav)
        local slot_owner = gutils.get_conn_owner(graph, slot)

        -- Only process our edge type
        if trav_owner.type == "technology" and slot_owner.type == "science-pack-set-science" then
            local tech_name = trav_owner.name
            local pack_set_name = slot_owner.name
            local tech = data.raw.technology[tech_name]

            if tech and tech.unit then
                -- TODO: Get science packs properly
                -- Parse the pack set name (packs joined with "__")
                local packs = {}
                for pack in string.gmatch(pack_set_name, "[^_]+") do
                    -- Skip empty strings from double underscores
                    if pack ~= "" then
                        table.insert(packs, pack)
                    end
                end

                -- Build new ingredients list
                local new_ingredients = {}
                for _, pack in ipairs(packs) do
                    table.insert(new_ingredients, {pack, 1})
                end

                tech.unit.ingredients = new_ingredients
            end
        end
    end
end

return tech_science_packs

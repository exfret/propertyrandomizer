local gutils = require("new-lib/graph/graph-utils")

local tech_science_packs = {}

tech_science_packs.id = "tech_science_packs"

tech_science_packs.claim = function(graph, prereq, dep, trav)
    if prereq.type == "science-pack-set-science" and dep.type == "technology" then
        local tech = data.raw.technology[dep.name]
        if tech.unit ~= nil then
            return 2
        end
    end
end

tech_science_packs.validate = function(graph, slot, trav, extra)
    if gutils.get_conn_owner(graph, slot).type ~= "science-pack-set-science" then
        return false
    end

    return true
end

tech_science_packs.reflect = function(graph, trav_to_new_slot, trav_to_handler)
    -- We could clear, but that would just make the points of failure more obvious

    for trav_key, slot in pairs(trav_to_new_slot) do
        if trav_to_handler[trav_key].id == "tech_science_packs" then
            local tech_name = gutils.get_conn_owner(graph, graph.nodes[trav_key]).name
            local packs = {}
            for pack_prereq_key, _ in pairs(gutils.get_conn_owner(graph, slot).pre) do
                local pack_prereq = graph.nodes[graph.edges[pack_prereq_key].start]
                -- Need to cross all across the edge from this (should-be) trav
                table.insert(packs, gutils.get_conn_owner(graph, gutils.get_conn_buddy(graph, pack_prereq)))
            end
            local new_ings = {}
            for _, pack in pairs(packs) do
                table.insert(new_ings, {pack.name, 1})
            end
            data.raw.technology[tech_name].unit.ingredients = new_ings
        end
    end
end

return tech_science_packs
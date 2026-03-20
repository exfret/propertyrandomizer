local gutils = require("new-lib/graph/graph-utils")

local tech_science_packs = {}

tech_science_packs.id = "tech_science_packs"

tech_science_packs.claim = function(graph, prereq, dep, edge)
    if prereq.type == "science-pack-set-science" and dep.type == "technology" then
        local tech = data.raw.technology[dep.name]
        if tech.unit ~= nil then
            return 2
        end
    end
end

tech_science_packs.validate = function(graph, base, head, extra)
    if gutils.get_owner(graph, base).type ~= "science-pack-set-science" then
        return false
    end

    return true
end

tech_science_packs.reflect = function(graph, head_to_base, head_to_handler)
    -- We could clear, but that would just make the points of failure more obvious

    for head_key, base_key in pairs(head_to_base) do
        if head_to_handler[head_key].id == "tech_science_packs" then
            -- TODO: Could this use more of the new gutils functions?
            local tech_name = gutils.get_owner(graph, graph.nodes[head_key]).name
            local packs = {}
            local base = graph.nodes[base_key]
            for pack_prereq_key, _ in pairs(gutils.get_owner(graph, base).pre) do
                local pack_prereq = graph.nodes[graph.edges[pack_prereq_key].start]
                -- Need to traverse all across the edge from this (should-be) head
                -- Let's assume we haven't subdivided the pack prereq edges too...
                table.insert(packs, pack_prereq)
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
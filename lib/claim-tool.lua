local claim_tool = {}

-- An omitted autoplace force already defaults to neutral.
-- Preserve explicit hostile ownership while making natural buildings neutral by default.
claim_tool.prepare = function(raw, entity_types)
    for entity_type, _ in pairs(entity_types) do
        for _, entity in pairs(raw[entity_type] or {}) do
            if entity.autoplace ~= nil and entity.autoplace.force == "player" then
                entity.autoplace.force = "neutral"
            end
        end
    end
end

claim_tool.add_prototypes = function()
    local selection = {
        border_color = {
            r = 0.25,
            g = 0.85,
            b = 0.35,
        },
        cursor_box_type = "entity",
        mode = {
            "any-entity",
            "not-same-force",
        },
    }
    data:extend({
        {
            type = "selection-tool",
            name = "propertyrandomizer-claim",
            icon = "__propertyrandomizer__/graphics/gear-icon.png",
            icon_size = 127,
            flags = {
                "only-in-cursor",
                "spawnable",
                "not-stackable",
            },
            stack_size = 1,
            select = selection,
            alt_select = table.deepcopy(selection),
            skip_fog_of_war = true,
        },
        {
            type = "shortcut",
            name = "propertyrandomizer-claim",
            localised_name = {"shortcut-name.propertyrandomizer-claim"},
            action = "spawn-item",
            item_to_spawn = "propertyrandomizer-claim",
            icon = "__propertyrandomizer__/graphics/gear-icon.png",
            icon_size = 127,
            small_icon = "__propertyrandomizer__/graphics/gear-icon.png",
            small_icon_size = 127,
            style = "green",
            order = "z[propertyrandomizer]-claim",
        },
    })
end

return claim_tool

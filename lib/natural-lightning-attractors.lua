local natural_lightning = {}

-- Natural attractors are map-generated entities that no item can place.
-- Read all item classes, including hidden items, so player buildings stay buildings.
natural_lightning.names = function(raw, item_types)
    local buildable = {}
    for item_type, _ in pairs(item_types) do
        for _, item in pairs(raw[item_type] or {}) do
            if item.place_result ~= nil then
                buildable[item.place_result] = true
            end
        end
    end
    local names = {}
    for name, attractor in pairs(raw["lightning-attractor"] or {}) do
        if attractor.autoplace ~= nil and buildable[name] ~= true then
            table.insert(names, name)
        end
    end
    table.sort(names)
    return names
end

natural_lightning.prepare = function(raw, item_types)
    local names = natural_lightning.names(raw, item_types)
    for _, name in pairs(names) do
        local attractor = raw["lightning-attractor"][name]
        attractor.autoplace.force = "neutral"
        attractor.alert_when_damaged = false
    end
    return names
end

-- Prototype changes affect new map generation; existing entities retain their force.
natural_lightning.migrate = function()
    -- Migration is one-time: later configuration changes must preserve claims.
    if storage.natural_lightning_migrated == true then
        return
    end
    local metadata = prototypes.mod_data["propertyrandomizer-natural-lightning-attractors"]
    if metadata ~= nil and #metadata.data.names > 0 then
        for _, surface in pairs(game.surfaces) do
            for _, entity in pairs(surface.find_entities_filtered({name = metadata.data.names})) do
                if entity.force ~= game.forces.neutral then
                    entity.force = game.forces.neutral
                end
            end
        end
    end
    storage.natural_lightning_migrated = true
end

return natural_lightning

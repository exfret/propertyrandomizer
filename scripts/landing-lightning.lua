-- Final prototype metadata supplies fields the 2.1 runtime API doesn't expose.
local landing_lightning = {}

landing_lightning.catalog = function(raw, item_types)
    local lightning_planets = {}
    for name, planet in pairs(raw.planet or {}) do
        if planet.lightning_properties ~= nil then
            lightning_planets[name] = true
        end
    end

    local buildable = {}
    for item_type, _ in pairs(item_types) do
        for _, item in pairs(raw[item_type] or {}) do
            if item.place_result ~= nil and item.hidden ~= true then
                buildable[item.place_result] = true
            end
        end
    end
    local ranges = {}
    local candidates = {}
    for name, attractor in pairs(raw["lightning-attractor"] or {}) do
        local range = attractor.range_elongation or 0
        if range > 0 then
            ranges[name] = range
            if buildable[name] == true and attractor.hidden ~= true then
                table.insert(candidates, {
                    name = name,
                    range = range,
                    conversion_efficiency = attractor.efficiency or 0,
                })
            end
        end
    end
    -- Prefer the basic buildable attractor; names only break ties deterministically.
    table.sort(candidates, function(a, b)
        if a.conversion_efficiency ~= b.conversion_efficiency then
            return a.conversion_efficiency < b.conversion_efficiency
        end
        if a.range ~= b.range then
            return a.range < b.range
        end
        return a.name < b.name
    end)
    return {
        lightning_planets = lightning_planets,
        ranges = ranges,
        candidates = candidates,
    }
end

landing_lightning.on_landing = function(event)
    if event.player_index == nil or not event.cargo_pod.valid then
        return
    end
    local surface = event.cargo_pod.surface
    local metadata = prototypes.mod_data["propertyrandomizer-landing-lightning"].data
    if surface.planet == nil or metadata.lightning_planets[surface.planet.name] ~= true then
        return
    end
    storage.landing_lightning = storage.landing_lightning or {}
    if storage.landing_lightning[surface.index] == true then
        return
    end

    local center = event.cargo_pod.position
    local names = {}
    local radius = 0
    for name, range in pairs(metadata.ranges) do
        table.insert(names, name)
        radius = math.max(radius, range)
    end
    if #names > 0 then
        for _, entity in pairs(surface.find_entities_filtered({
            name = names,
            position = center,
            radius = radius,
        })) do
            local dx = entity.position.x - center.x
            local dy = entity.position.y - center.y
            local range = metadata.ranges[entity.name]
            if dx * dx + dy * dy <= range * range then
                storage.landing_lightning[surface.index] = true
                return
            end
        end
    end

    for _, candidate in pairs(metadata.candidates) do
        local position = surface.find_non_colliding_position(candidate.name, center, math.min(8, candidate.range), 0.5, true)
        if position ~= nil then
            local dx = position.x - center.x
            local dy = position.y - center.y
            if dx * dx + dy * dy <= candidate.range * candidate.range then
                local entity = surface.create_entity({
                    name = candidate.name,
                    position = position,
                    force = game.players[event.player_index].force,
                    preserve_ghosts_and_corpses = true,
                })
                if entity ~= nil then
                    storage.landing_lightning[surface.index] = true
                    return
                end
            end
        end
    end
    -- If terrain is blocked, a later landing can retry instead of recording success.
end

return landing_lightning

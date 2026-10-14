local manifest = require("src/randomizations/planetary/biome-profile-manifest")

local profiles = {}

profiles.order = {
    "artificial",
    "foundation",
    "forest",
    "sandy",
    "tundra",
    "volcanic",
    "normal",
    "everything",
    "fluid",
    "water",
}

-- Normal remains an internal native-placement sentinel, never a selectable biome.
profiles.choices = {}
for _, profile in pairs(profiles.order) do
    if profile ~= "normal" then
        table.insert(profiles.choices, profile)
    end
end

profiles.layer = function(profile)
    return "propertyrandomizer_biome_" .. profile
end

profiles.blocking_layer = function(profile)
    return "propertyrandomizer_biome_block_" .. profile
end

-- The semantic families are user-defined. Construction and starter-pack membership come from prototypes.
-- Call before changing appearances, then pass the captured membership when classifying appearance clones.
profiles.classify = function(raw, prototype_types, sources)
    local memberships, platform = {}, {}
    for name, _ in pairs(raw.tile or {}) do
        memberships[name] = {}
    end
    for item_type, _ in pairs(prototype_types.item) do
        for _, item in pairs(raw[item_type] or {}) do
            if item.place_as_tile ~= nil and memberships[item.place_as_tile.result] ~= nil then
                memberships[item.place_as_tile.result].artificial = true
            end
            if item.surface ~= nil then
                for _, entry in pairs(item.tiles or {}) do
                    if memberships[entry.tile] ~= nil then
                        platform[entry.tile] = true
                        memberships[entry.tile].foundation = true
                        memberships[entry.tile].artificial = true
                    end
                end
            end
        end
    end
    for _, planet in pairs(raw.planet or {}) do
        local family = manifest.planets[planet.orig_name or planet.name]
        local settings = planet.map_gen_settings or {}
        settings = (settings.autoplace_settings or {}).tile or {}
        for name, _ in pairs(settings.settings or {}) do
            local tile = (raw.tile or {})[name]
            if family ~= nil and tile ~= nil and tile.fluid == nil and tile.autoplace ~= nil then
                memberships[name][family] = true
            end
        end
    end
    for name, tile in pairs(raw.tile or {}) do
        local family = manifest.tiles[tile.orig_name or name]
        if family ~= nil and tile.fluid == nil then
            memberships[name][family] = true
        end
    end
    -- Frozen/thawed construction variants remain artificial, including variants supplied by other mods.
    local changed = true
    while changed do
        changed = false
        for name, tile in pairs(raw.tile or {}) do
            if memberships[name].artificial then
                for _, target in pairs({tile.frozen_variant, tile.thawed_variant}) do
                    if memberships[target] ~= nil and not memberships[target].artificial then
                        memberships[target].artificial = true
                        changed = true
                    end
                end
            end
        end
    end
    local report = (raw["mod-data"] or {})["propertyrandomizer-biomes"]
    for name, tile in pairs(raw.tile or {}) do
        local membership = memberships[name]
        local donor = report and (report.data.clone_to_appearance or {})[name]
        if donor ~= nil and sources ~= nil then
            membership = table.deepcopy(sources[donor] or {})
            memberships[name] = membership
        end
        if tile.fluid ~= nil then
            membership.forest, membership.sandy, membership.tundra, membership.volcanic = nil, nil, nil, nil
            membership.fluid = true
            membership.water = manifest.fluids[tile.fluid] == "water" or nil
        end
        membership.everything = tile.autoplace ~= nil or tile.fluid ~= nil or membership.artificial or platform[name] or nil
    end
    -- Compatibility registration: a mod-data prototype with data.tiles[tile_name] = {profile_id = boolean}.
    -- False explicitly removes a derived family; unknown tile names are harmless.
    local registrations = (raw["mod-data"] or {})["propertyrandomizer-biome-registrations"]
    for name, values in pairs(registrations and registrations.data.tiles or {}) do
        if memberships[name] ~= nil then
            for _, profile in pairs(profiles.order) do
                if values[profile] ~= nil then
                    memberships[name][profile] = values[profile] or nil
                end
            end
        end
    end
    return memberships, platform
end

-- Resolve presentation copies to their visible donor, then to the original tile for links.
profiles.tile_sources = function(raw)
    local report = (raw["mod-data"] or {})["propertyrandomizer-biomes"]
    local donors = report ~= nil and report.data.clone_to_appearance or {}
    local result = {}
    for name, _ in pairs(raw.tile or {}) do
        local source, seen = name, {}
        while raw.tile[source] ~= nil and not seen[source] do
            seen[source] = true
            local tile = raw.tile[source]
            local next_source = donors[source] or tile.orig_name or tile.factoriopedia_alternative
            if next_source == nil or raw.tile[next_source] == nil then
                break
            end
            source = next_source
        end
        result[name] = source
    end
    return result
end

profiles.mark = function(raw, memberships, platform)
    for name, tile in pairs(raw.tile) do
        for _, profile in pairs(profiles.order) do
            if profile ~= "normal" then
                tile.collision_mask.layers[profiles.layer(profile)] = memberships[name][profile] or nil
                tile.collision_mask.layers[profiles.blocking_layer(profile)] = not (memberships[name][profile] or platform[name]) or nil
            end
        end
        tile.collision_mask.layers[profiles.layer("platform")] = platform[name] or nil
    end
end

return profiles

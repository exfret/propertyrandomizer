-- Decorative palettes for the land-biome mixer: entities, resources and agricultural plants stay under their existing randomizers.
-- Placement does not import a donor planet's noise graph; a shared region selector and the destination's cloned land tiles keep each palette local.

local rng = require("lib/random/rng")

local decoratives = {}

local function sorted_keys(values)
    local keys = {}
    for key, _ in pairs(values or {}) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

-- Hex encoding keeps prototype names distinct and safe as noise identifiers.
local function identifier(name)
    return (string.gsub(name, ".", function(char)
        return string.format("%02x", string.byte(char))
    end))
end

-- Read before any target is changed: donor planet -> its declared decorative palette.
-- Prototype category and decorative placement settings: DecorativePrototype and PlanetPrototypeMapGenSettings (installed 2.1 docs).
decoratives.capture = function(raw)
    local snapshot = {}
    local prototypes = raw["optimized-decorative"] or {}
    for _, planet_name in pairs(sorted_keys(raw.planet)) do
        local planet = raw.planet[planet_name]
        if planet.hidden ~= true and planet.orig_name == nil then
            local autoplace = (planet.map_gen_settings or {}).autoplace_settings or {}
            local settings = (autoplace.decorative or {}).settings or {}
            local palette = {}
            for _, name in pairs(sorted_keys(settings)) do
                local prototype = prototypes[name]
                local values = settings[name]
                if prototype ~= nil and prototype.autoplace ~= nil and prototype.hidden ~= true
                    and values.frequency ~= 0 and values.size ~= 0 and values.richness ~= 0 then
                    table.insert(palette, table.deepcopy(prototype))
                end
            end
            snapshot[planet_name] = palette
        end
    end
    return snapshot
end

local function add(raw, prototype)
    raw[prototype.type] = raw[prototype.type] or {}
    raw[prototype.type][prototype.name] = prototype
end

local function collision_area(prototype)
    local box = prototype.collision_box
    if box == nil then
        return 1
    end
    local low = box.left_top or box[1]
    local high = box.right_bottom or box[2]
    return math.max(1, ((high.x or high[1]) - (low.x or low[1])) * ((high.y or high[2]) - (low.y or low[2])))
end

-- Keep the host's original decoration outside mixed land, including per-planet overrides and the original autoplace's local definitions.
-- PropertyExpressionNames supports decorative:<name>:probability overrides.
local function mask_host(raw, planet, land_mask, originals)
    local settings = planet.map_gen_settings
    settings.property_expression_names = settings.property_expression_names or {}
    local overrides = settings.property_expression_names
    for i, name in pairs(originals) do
        local prototype = raw["optimized-decorative"][name]
        local autoplace = prototype.autoplace
        if autoplace ~= nil then
            local property = "decorative:" .. name .. ":probability"
            local override = overrides[property]
            local source_name = "propertyrandomizer_biome_original_decorative_" .. identifier(planet.name) .. "_" .. i
            if override ~= nil then
                -- Property overrides name expressions or give literal numeric/boolean values.
                -- Do not attach the original's local scope to an override expression.
                local expression = override
                if type(override) == "string" then
                    expression = tonumber(override) or ("var(" .. string.format("%q", override) .. ")")
                end
                add(raw, {
                    type = "noise-expression",
                    name = source_name,
                    expression = expression,
                })
            else
                add(raw, {
                    type = "noise-expression",
                    name = source_name,
                    expression = table.deepcopy(autoplace.probability_expression),
                    local_expressions = table.deepcopy(autoplace.local_expressions),
                    local_functions = table.deepcopy(autoplace.local_functions),
                })
            end
            local masked_name = source_name .. "_masked"
            add(raw, {
                type = "noise-expression",
                name = masked_name,
                expression = "if(" .. land_mask .. ", 0, " .. source_name .. ")",
            })
            overrides[property] = masked_name
        end
    end
end

-- regions: {source = donor planet name, index = selector value,
--           selector = shared named expression, tiles = destination land tile names}.
-- options: {snapshot = capture(raw), land_mask = named expression true on mixed land}.
-- Returns clone -> donor decorative and clone -> region index for diagnostics and focused checks.
decoratives.apply = function(raw, planet, regions, options)
    local settings = planet.map_gen_settings
    if settings == nil or options.land_mask == nil then
        return {}, {}
    end
    local snapshot = options.snapshot
    local key = rng.key({
        id = "planetary-biome-decoratives",
        prototype = planet,
    })
    settings.autoplace_settings = settings.autoplace_settings or {}
    settings.autoplace_settings.decorative = settings.autoplace_settings.decorative or {settings = {}}
    local placement = settings.autoplace_settings.decorative
    placement.settings = placement.settings or {}

    -- Snapshot original candidates before registering the new per-target clones.
    local originals = {}
    for _, name in pairs(sorted_keys(raw["optimized-decorative"])) do
        local prototype = raw["optimized-decorative"][name]
        if prototype.autoplace ~= nil and (placement.settings[name] ~= nil
            or (placement.treat_missing_as_default ~= false and prototype.autoplace.default_enabled ~= false)) then
            table.insert(originals, name)
        end
    end

    local clone_sources = {}
    local clone_regions = {}
    for _, region in pairs(regions) do
        local palette = snapshot[region.source] or {}
        if #region.tiles > 0 then
            for _, original in pairs(palette) do
                local clone = table.deepcopy(original)
                clone.name = "propertyrandomizer-biome-decorative-" .. identifier(planet.name) .. "-" .. region.index .. "-" .. identifier(original.name)
                clone.localised_name = clone.localised_name or {"decorative-name." .. original.name}

                -- Share a conservative total density across the palette, with fewer attempts for decoratives whose collision boxes are large.
                -- This is a visual tuning choice, not inferred donor density.
                local probability = 0.3 / (#palette * collision_area(original))
                clone.autoplace = {
                    default_enabled = false,
                    order = original.autoplace.order,
                    placement_density = 1,
                    tile_restriction = table.deepcopy(region.tiles),
                    probability_expression = "(" .. region.selector .. " == " .. region.index .. ") * " .. probability
                        .. " * clamp(0.5 + basis_noise{x = x, y = y, seed0 = map_seed, seed1 = " .. rng.int(key, 1000000)
                        .. ", input_scale = 1 / 16, output_scale = 1}, 0, 1)",
                    richness_expression = 1,
                }
                add(raw, clone)
                placement.settings[clone.name] = {}
                clone_sources[clone.name] = original.name
                clone_regions[clone.name] = region.index
            end
        end
    end

    if next(clone_sources) ~= nil then
        mask_host(raw, planet, options.land_mask, originals)
    end
    return clone_sources, clone_regions
end

return decoratives

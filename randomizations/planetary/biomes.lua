-- Regional ground appearances and decorative vegetation. Capture before gameplay randomization, then apply after it so tile mechanics stay final.
-- The starting planet (original Nauvis) is explicitly exempt (user, 2026-10-05); its copies may change.
-- Noise/placement API: https://lua-api.factorio.com/latest/types/AutoplaceSpecification.html
-- Only presentation fields travel. Every clone keeps its host's collision, mining, fluids, covering rules and placement expression; name-based rules follow clones.

local constants = require("helper-tables/constants")
local rng = require("lib/random/rng")
local tile_references = require("randomizations/planetary/biome-tile-references")
local decoratives = require("randomizations/planetary/biome-decoratives")

local biomes = {}
local snapshot = nil

local appearance_fields = {
    "variants",
    "transition_merges_with_tile",
    "transition_overlay_layer_offset",
    "map_color",
    "tint",
    "effect",
    "effect_color",
    "effect_color_secondary",
    "effect_is_opaque",
    "particle_tints",
    "scorch_mark_color",
    "walking_sound",
    "landing_steps_sound",
    "driving_sound",
    "ambient_sounds",
    "ambient_sounds_group",
    "sprite_usage_surface",
}

local function sorted_keys(tbl)
    local keys = {}
    for key, _ in pairs(tbl or {}) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

-- Restrict this first pass to non-fluid natural ground. Oceans have their own stage; tiles with a dropped-item hazard remain visually identifiable.
local function ground(tile)
    return tile ~= nil and tile.autoplace ~= nil and tile.variants ~= nil
        and tile.fluid == nil and tile.destroys_dropped_items ~= true
end

local function tile_settings(planet)
    return (((planet.map_gen_settings or {}).autoplace_settings or {}).tile or {}).settings
end

biomes.capture = function()
    snapshot = {
        palettes = {},
        decoratives = decoratives.capture(data.raw),
    }
    for _, name in pairs(sorted_keys(data.raw.planet)) do
        local planet = data.raw.planet[name]
        if planet.hidden ~= true and planet.orig_name == nil then
            local palette = {}
            for _, tile_name in pairs(sorted_keys(tile_settings(planet))) do
                local tile = data.raw.tile[tile_name]
                if ground(tile) then
                    table.insert(palette, table.deepcopy(tile))
                end
            end
            if #palette > 0 then
                snapshot.palettes[name] = palette
            end
        end
    end
end

local function named_expression(name, expression, autoplace)
    local node = {}
    node.type = "noise-expression"
    node.name = name
    node.expression = expression
    if autoplace ~= nil then
        node.local_expressions = table.deepcopy(autoplace.local_expressions)
        node.local_functions = table.deepcopy(autoplace.local_functions)
    end
    data:extend({ node })
    return name
end

local function variable(name)
    -- Noise identifiers containing punctuation are accessed through var().
    -- Quotes cannot be escaped by the noise parser; generated names never have them.
    assert(string.find(name, "'", 1, true) == nil, "Unsupported quote in noise expression name")
    return "var('" .. name .. "')"
end

local function probability_key(name)
    return "tile:" .. name .. ":probability"
end

-- Save the effective expression, including local definitions, before hiding the original tile on this planet. Global tile prototypes stay untouched.
local function save_probability(planet, tile, name)
    local overrides = planet.map_gen_settings.property_expression_names or {}
    local override = overrides[probability_key(tile.name)]
    local expression = tile.autoplace.probability_expression
    local locals = tile.autoplace
    if override ~= nil then
        expression = override
        locals = nil
        if type(override) == "string" then
            expression = tonumber(override) or variable(override)
        end
    end
    local saved = named_expression(name .. "_raw", expression, locals)
    -- Select explicitly rather than multiplying by zero: native expressions can include infinities. The ocean stage uses the same NaN exclusion.
    local ref = variable(saved)
    return named_expression(name, "if(" .. ref .. " == " .. ref .. ", " .. ref .. ", -inf)")
end

local function maximum(names)
    if #names == 0 then
        return "-inf"
    end
    local value = variable(names[1])
    for i = 2, #names do
        value = "max(" .. value .. ", " .. variable(names[i]) .. ")"
    end
    return value
end

local function choose_sources(planet, key)
    local names = sorted_keys(snapshot.palettes)
    if #names < 2 then
        return nil
    end
    local family = planet.orig_name or planet.name
    local alternatives = {}
    for _, name in pairs(names) do
        if name ~= family then
            table.insert(alternatives, name)
        end
    end
    if #alternatives >= 2 then
        names = alternatives
    end
    rng.shuffle(key, names)
    return {
        names[1],
        names[2],
    }
end

-- Equal tile scores retain their native name ordering (verified by the generated-map comparison).
-- Insert clone names immediately after their host, including before names such as host-2.
local function ordered_clone_names(hosts, all_tiles, prefix, count)
    local result = {}
    for _, host in pairs(hosts) do
        local successor = nil
        for _, name in pairs(all_tiles) do
            if name > host then
                successor = name
                break
            end
        end
        local separator = "--"
        if successor ~= nil and string.sub(successor, 1, #host) == host then
            local suffix = string.sub(successor, #host + 1)
            separator = string.rep("-", #string.match(suffix, "^-*") + 1)
        end
        result[host] = {}
        for region = 1, count do
            local name = host .. separator .. prefix .. "_" .. region
            -- PrototypeBase.name permits 200 characters. Some custom names leave no valid insertion interval.
            if #name > 200 or (successor ~= nil and name >= successor) then
                return nil
            end
            result[host][region] = name
        end
    end
    return result
end

-- Exposed for tests and the development harness. No runtime behavior is added.
biomes.assignments = {}
biomes.clone_to_slot = {}

biomes.execute = function()
    if snapshot == nil then
        biomes.capture()
    end
    biomes.assignments = {}
    biomes.clone_to_slot = {}
    local clones_of = {}
    local original_tile_names = sorted_keys(data.raw.tile)
    local sequence = 0
    local never = named_expression("propertyrandomizer_biome_never", "-inf")
    for _, planet_name in pairs(sorted_keys(data.raw.planet)) do
        local planet = data.raw.planet[planet_name]
        local settings = tile_settings(planet)
        if planet_name ~= constants.starting_planet and planet.hidden ~= true and settings ~= nil then
            local key = rng.key({
                id = "planetary-biomes",
                prototype = planet,
            })
            local sources = choose_sources(planet, key)
            local hosts = {}
            for _, tile_name in pairs(sorted_keys(settings)) do
                if ground(data.raw.tile[tile_name]) then
                    table.insert(hosts, tile_name)
                end
            end
            local prefix = "propertyrandomizer_biome_" .. (sequence + 1)
            local clone_names = ordered_clone_names(hosts, original_tile_names, prefix, #(sources or {}))
            if clone_names == nil then
                log("Planetary biomes: skipped " .. planet_name .. " because tile names leave no room for ordered appearance clones")
            end
            if sources ~= nil and #hosts > 0 and clone_names ~= nil then
                sequence = sequence + 1
                local noise = "multioctave_noise{x=x, y=y, seed0=map_seed, seed1=" .. rng.int(key, 1000000)
                    .. ", octaves=3, persistence=0.55, input_scale=" .. (1 / rng.range(key, 160, 384)) .. "}"
                local selector = named_expression(prefix .. "_region", "if(" .. noise .. " > " .. rng.float_range(key, -0.12, 0.12) .. ", 1, 2)")
                local assignment = {
                    selector = selector,
                    sources = sources,
                    clones = {},
                    clone_regions = {},
                    original_probabilities = {},
                }
                local regions = {}
                local palettes = {}
                for i, source in pairs(sources) do
                    palettes[i] = table.deepcopy(snapshot.palettes[source])
                    rng.shuffle(key, palettes[i])
                    regions[i] = {
                        source = source,
                        index = i,
                        selector = selector,
                        tiles = {},
                    }
                end
                local ground_scores = {}
                local other_scores = {}
                local scores = {}
                -- Read all scores before writing overrides or adding clones.
                for i, tile_name in pairs(sorted_keys(settings)) do
                    local tile = data.raw.tile[tile_name]
                    if tile ~= nil and tile.autoplace ~= nil then
                        local score = save_probability(planet, tile, prefix .. "_score_" .. i)
                        scores[tile_name] = score
                        if ground(tile) then
                            table.insert(ground_scores, score)
                        else
                            table.insert(other_scores, score)
                        end
                    end
                end
                local best_ground = maximum(ground_scores)
                local land_mask = named_expression(prefix .. "_land", "(" .. best_ground .. " > -inf) * (" .. best_ground .. " > " .. maximum(other_scores) .. ")")
                local map_gen = planet.map_gen_settings
                map_gen.property_expression_names = map_gen.property_expression_names or {}
                for host_index, host_name in pairs(hosts) do
                    local host = data.raw.tile[host_name]
                    local original_override = map_gen.property_expression_names[probability_key(host_name)]
                    assignment.original_probabilities[host_name] = {
                        present = original_override ~= nil,
                        value = original_override,
                    }
                    for i, _ in pairs(sources) do
                        local look = palettes[i][(host_index - 1) % #palettes[i] + 1]
                        local clone = table.deepcopy(host)
                        clone.name = clone_names[host_name][i]
                        clone.hidden_in_factoriopedia = true
                        -- Keep the mechanical tile's name/description: fertile soil remains fertile soil when its appearance changes.
                        clone.localised_name = host.localised_name or { "tile-name." .. host.name }
                        for _, field in pairs(appearance_fields) do
                            clone[field] = table.deepcopy(look[field])
                        end
                        -- Ocean swaps rewrite the donor's shoreline targets after capture, including ocean clones.
                        -- Read the finished transition bundle so the old lava edges don't return on a replaced ocean.
                        local shore = data.raw.tile[look.name] or look
                        clone.transitions = table.deepcopy(shore.transitions)
                        clone.transitions_between_transitions = table.deepcopy(shore.transitions_between_transitions)
                        clone.bound_decoratives = nil
                        clone.autoplace = table.deepcopy(host.autoplace)
                        clone.autoplace.default_enabled = false
                        clone.autoplace.probability_expression = "if(" .. variable(selector) .. " == " .. i .. ", " .. variable(scores[host_name]) .. ", -inf)"
                        data:extend({ clone })
                        settings[clone.name] = table.deepcopy(settings[host_name])
                        clones_of[host_name] = clones_of[host_name] or {}
                        table.insert(clones_of[host_name], clone.name)
                        table.insert(regions[i].tiles, clone.name)
                        biomes.clone_to_slot[clone.name] = host_name
                        assignment.clones[clone.name] = host_name
                        assignment.clone_regions[clone.name] = i
                    end
                    map_gen.property_expression_names[probability_key(host_name)] = never
                end
                assignment.decorative_sources, assignment.decorative_regions = decoratives.apply(data.raw, planet, regions, {
                    snapshot = snapshot.decoratives,
                    land_mask = land_mask,
                })
                biomes.assignments[planet_name] = assignment
                log("Planetary biomes: " .. planet_name .. " uses " .. table.concat(sources, " + ") .. " on " .. #hosts .. " ground tiles")
            end
        end
    end
    tile_references.extend(data.raw, clones_of)
    local report = {}
    report.type = "mod-data"
    report.name = "propertyrandomizer-biomes"
    report.data = {
        planets = biomes.assignments,
        clone_to_slot = biomes.clone_to_slot,
        protected_planet = constants.starting_planet,
    }
    data:extend({ report })
end

return biomes

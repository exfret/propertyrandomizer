-- Planetary ocean swaps (vanilla Space Age only for now)
-- Each planet's ocean is a slot: its ocean tiles keep their names, where they generate, collision, which tiles landfill/foundation/ice platforms/soils go on, neighbor rules, pollution absorption, and walking and vehicle speed.
-- Each planet's family of ocean tiles is a traveler: its look and the fluid offshore pumps get from it.
-- Ocean tiles drawn as water only get looks drawn as water, so no ocean looks like land.
-- A permutation moves travelers onto slots by reskinning the slot tiles, so map gen keeps its vanilla shape and every slot keeps its own rules.
-- Planets whose ocean fluid changed get scaffolding recipes (randomizations/planetary/scaffolds.lua) so their progression still works from local resources.

local constants = require("helper-tables/constants")
local rng = require("lib/random/rng")

local oceans = {}

-- Ocean tiles per planet, split by depth so that shallow tiles replace shallow tiles and deep tiles replace deep tiles
-- A slot with fewer tiles than the traveler has looks gets clones of its tiles so every look shows up
oceans.families = {
    nauvis = {
        fluid = "water",
        shallow = { "water" },
        deep = { "deepwater" },
    },
    vulcanus = {
        fluid = "lava",
        shallow = { "lava" },
        deep = { "lava-hot" },
    },
    gleba = {
        fluid = "water",
        shallow = {
            "wetland-blue-slime",
            "wetland-light-green-slime",
            "wetland-green-slime",
            "wetland-light-dead-skin",
            "wetland-dead-skin",
            "wetland-pink-tentacle",
            "wetland-red-tentacle",
            "wetland-yumako",
            "wetland-jellynut",
        },
        deep = { "gleba-deep-lake" },
    },
    fulgora = {
        fluid = "heavy-oil",
        shallow = {
            "oil-ocean-shallow",
            "oil-ocean-shallow-2",
        },
        deep = {
            "oil-ocean-deep",
            "oil-ocean-deep-2",
        },
    },
    aquilo = {
        fluid = "ammoniacal-solution",
        shallow = { "brash-ice" },
        deep = {
            "ammoniacal-ocean",
            "ammoniacal-ocean-2",
        },
    },
}
oceans.planet_order = {
    "nauvis",
    "vulcanus",
    "gleba",
    "fulgora",
    "aquilo",
}
local depths = {
    "shallow",
    "deep",
}

-- Planet --> planet whose ocean family it gets
-- Every ocean moves; Nauvis and Gleba trade water for water, and lava, heavy oil and ammoniacal solution go around in a cycle
oceans.fixed_assignment = {
    nauvis = "gleba",
    gleba = "nauvis",
    vulcanus = "fulgora",
    fulgora = "aquilo",
    aquilo = "vulcanus",
}

-- The starting planet keeps a family with its own fluid, since its early game needs it before any conversion is possible (so Nauvis keeps water)
-- Every other planet gets a different ocean than its own, since the point is swaps
local function valid_assignment(assignment)
    local start = constants.starting_planet
    if oceans.families[start] ~= nil and oceans.families[assignment[start]].fluid ~= oceans.families[start].fluid then
        return false
    end
    for planet, family in pairs(assignment) do
        if planet ~= start and planet == family then
            return false
        end
    end
    return true
end

oceans.random_assignment = function(id)
    local families = {}
    for _, planet in pairs(oceans.planet_order) do
        table.insert(families, planet)
    end
    local key = rng.key({ id = id })
    for _ = 1, 100 do
        rng.shuffle(key, families)
        local assignment = {}
        for i, planet in pairs(oceans.planet_order) do
            assignment[planet] = families[i]
        end
        if valid_assignment(assignment) then
            return assignment
        end
    end
    -- Only reachable if no valid assignment exists, in which case nothing moves
    local identity = {}
    for _, planet in pairs(oceans.planet_order) do
        identity[planet] = planet
    end
    return identity
end

-- Why ocean swaps can't run on the current prototypes, or nil if they can
-- They're written for vanilla Space Age, so every ocean tile has to be where vanilla puts it
oceans.problem = function()
    for _, planet_name in pairs(oceans.planet_order) do
        local planet = data.raw.planet[planet_name]
        if planet == nil or planet.map_gen_settings == nil or planet.map_gen_settings.autoplace_settings == nil or planet.map_gen_settings.autoplace_settings.tile == nil then
            return "planet " .. planet_name .. " is missing or has no tile autoplace settings"
        end
        local tile_settings = planet.map_gen_settings.autoplace_settings.tile.settings or {}
        for _, depth in pairs(depths) do
            for _, tile_name in pairs(oceans.families[planet_name][depth]) do
                local tile = data.raw.tile[tile_name]
                if tile == nil or tile.autoplace == nil or tile_settings[tile_name] == nil or tile.fluid ~= oceans.families[planet_name].fluid then
                    return "ocean tile " .. tile_name .. " isn't set up like vanilla on " .. planet_name
                end
                if tile.autoplace.local_expressions ~= nil then
                    return "ocean tile " .. tile_name .. " has autoplace local expressions, which ocean swaps don't handle"
                end
            end
        end
    end
    return nil
end

-- Tile fields that come from the traveler: its look, its fluid, and what it does to things dropped in it
-- Everything else (name, autoplace, collision, neighbor rules, pollution absorption, speed modifiers) stays with the slot tile
local traveler_fields = {
    "variants",
    "transitions",
    "transitions_between_transitions",
    "transition_merges_with_tile",
    "transition_overlay_layer_offset",
    "layer",
    "layer_group",
    "needs_correction",
    "effect",
    "effect_color",
    "effect_color_secondary",
    "effect_is_opaque",
    "map_color",
    "tint",
    "icon",
    "icons",
    "icon_size",
    "particle_tints",
    "scorch_mark_color",
    "lowland_fog",
    "sprite_usage_surface",
    "walking_sound",
    "driving_sound",
    "landing_steps_sound",
    "build_sound",
    "mined_sound",
    "ambient_sounds",
    "ambient_sounds_group",
    "fluid",
    "destroys_dropped_items",
    "default_destroyed_dropped_item_trigger",
    "trigger_effect",
    "localised_name",
    "localised_description",
}

-- Whether a tile is drawn in the water render layers (TileRenderLayer "water" and "water-overlay", which draw under the ground layers) rather than as ground
local function drawn_as_water(tile)
    return tile.layer_group == "water" or tile.layer_group == "water-overlay"
end

-- Noise names get referenced inside other expressions, so they need underscores (hyphens would parse as subtraction)
local function noise_name(prefix, tile_name)
    return "propertyrandomizer_ocean_" .. prefix .. "_" .. string.gsub(tile_name, "-", "_")
end

-- Some vanilla ocean probabilities are NaN in places (like -inf * 0 on Fulgora's land), which vanilla never places
-- On a new tile or inside another expression NaN can win instead, so it's turned into -inf (NaN is the only value not equal to itself)
local function not_nan(name)
    return "if(" .. name .. " == " .. name .. ", " .. name .. ", -inf)"
end

-- Index (1 to #candidates) of the highest candidate expression, preferring earlier ones on ties (so 1 when everything is -inf)
local function argmax_expression(candidates)
    local suffix_max = { [#candidates] = candidates[#candidates] }
    for i = #candidates - 1, 1, -1 do
        suffix_max[i] = "max(" .. candidates[i] .. ", " .. suffix_max[i + 1] .. ")"
    end
    local expression = tostring(#candidates)
    for i = #candidates - 1, 1, -1 do
        expression = "if(" .. candidates[i] .. " >= " .. suffix_max[i + 1] .. ", " .. i .. ", " .. expression .. ")"
    end
    return expression
end

oceans.apply = function(assignment)
    local tiles = data.raw.tile

    -- Tiles are both slots and travelers, so read everything from a snapshot
    local original = {}
    for _, family in pairs(oceans.families) do
        for _, depth in pairs(depths) do
            for _, tile_name in pairs(family[depth]) do
                original[tile_name] = table.deepcopy(tiles[tile_name])
                data:extend({
                    {
                        type = "noise-expression",
                        name = noise_name("original", tile_name),
                        expression = original[tile_name].autoplace.probability_expression,
                    },
                })
            end
        end
    end

    local function reskin(tile, look_name)
        for _, field in pairs(traveler_fields) do
            tile[field] = table.deepcopy(original[look_name][field])
        end
        if tile.localised_name == nil then
            tile.localised_name = { "tile-name." .. look_name }
        end
        if tile.localised_description == nil then
            tile.localised_description = { "?", { "tile-description." .. look_name }, "" }
        end
    end

    -- The traveler tiles whose looks a slot depth shows: the traveler family's tiles of the same depth
    -- A slot drawn as water only shows looks drawn as water, taken from the family's other depth if needed, so it never looks like land where offshore pumps work (Fulgora's shallow oil is drawn as ground)
    local function looks_for(slot_planet, depth)
        local family = oceans.families[assignment[slot_planet]]
        local slot_is_water = false
        for _, slot_tile in pairs(oceans.families[slot_planet][depth]) do
            if drawn_as_water(original[slot_tile]) then
                slot_is_water = true
            end
        end
        if not slot_is_water then
            return family[depth]
        end
        -- The family's looks drawn as water at these depths, or nil if there are none
        local function water_looks(look_depths)
            local looks = {}
            for _, look_depth in pairs(look_depths) do
                for _, look in pairs(family[look_depth]) do
                    if drawn_as_water(original[look]) then
                        table.insert(looks, look)
                    end
                end
            end
            if #looks == 0 then
                return nil
            end
            return looks
        end
        return water_looks({ depth }) or water_looks(depths) or family[depth]
    end

    -- Slot tile --> the traveler tiles whose looks it shows
    -- Looks are dealt out over the slot tiles; if there are fewer looks than slot tiles, they repeat
    local looks_of = {}
    for _, slot_planet in pairs(oceans.planet_order) do
        for _, depth in pairs(depths) do
            local slots = oceans.families[slot_planet][depth]
            local looks = looks_for(slot_planet, depth)
            for _, slot_tile in pairs(slots) do
                looks_of[slot_tile] = {}
            end
            for j, look in pairs(looks) do
                table.insert(looks_of[slots[(j - 1) % #slots + 1]], look)
            end
            for i, slot_tile in pairs(slots) do
                if #looks_of[slot_tile] == 0 then
                    table.insert(looks_of[slot_tile], looks[(i - 1) % #looks + 1])
                end
            end
        end
    end

    -- A slot tile showing several looks is split into clones, one per extra look
    -- Each point of the slot's footprint goes to the look whose own home-planet probability is highest there, so the outline comes from the slot's planet and the texture from the traveler's
    local clones_of = {}
    for _, slot_planet in pairs(oceans.planet_order) do
        local tile_settings = data.raw.planet[slot_planet].map_gen_settings.autoplace_settings.tile.settings
        for _, depth in pairs(depths) do
            for _, slot_tile in pairs(oceans.families[slot_planet][depth]) do
                local looks = looks_of[slot_tile]
                clones_of[slot_tile] = {}
                if #looks > 1 then
                    local candidates = {}
                    for _, look in pairs(looks) do
                        table.insert(candidates, not_nan(noise_name("original", look)))
                    end
                    local chooser_name = noise_name("look", slot_tile)
                    data:extend({
                        {
                            type = "noise-expression",
                            name = chooser_name,
                            expression = argmax_expression(candidates),
                        },
                    })
                    local footprint = not_nan(noise_name("original", slot_tile))
                    for j, look in pairs(looks) do
                        local probability = "if(" .. chooser_name .. " == " .. j .. ", " .. footprint .. ", -inf)"
                        if j == 1 then
                            tiles[slot_tile].autoplace.probability_expression = probability
                        else
                            local clone = table.deepcopy(original[slot_tile])
                            clone.name = "propertyrandomizer-" .. slot_tile .. "-" .. look
                            clone.hidden_in_factoriopedia = true
                            clone.autoplace = {
                                probability_expression = probability,
                            }
                            reskin(clone, look)
                            data:extend({
                                clone,
                            })
                            tile_settings[clone.name] = {}
                            table.insert(clones_of[slot_tile], clone.name)
                        end
                    end
                end
                reskin(tiles[slot_tile], looks[1])
            end
        end
    end

    -- Clones follow every name-based rule their slot tile is in: tile placement (landfill, foundation, ice platform, soils), neighbor rules, transitions and autoplace tile restrictions
    local function add_clones(names)
        if names == nil then
            return
        end
        local additions = {}
        for _, name in pairs(names) do
            if type(name) == "string" then
                for _, clone_name in pairs(clones_of[name] or {}) do
                    table.insert(additions, clone_name)
                end
            end
        end
        for _, clone_name in pairs(additions) do
            table.insert(names, clone_name)
        end
    end
    for _, item in pairs(data.raw.item) do
        if item.place_as_tile ~= nil then
            add_clones(item.place_as_tile.tile_condition)
        end
    end
    for _, tile in pairs(tiles) do
        add_clones(tile.allowed_neighbors)
        for _, transition in pairs(tile.transitions or {}) do
            add_clones(transition.to_tiles)
        end
    end
    for _, group in pairs(data.raw) do
        for _, prototype in pairs(group) do
            if type(prototype) == "table" and type(prototype.autoplace) == "table" then
                add_clones(prototype.autoplace.tile_restriction)
            end
        end
    end

    -- Clone tile --> the slot tile it was cloned from, so checks can hold clones to their slot tile's rules
    local clone_to_slot = {}
    for slot_tile, clone_names in pairs(clones_of) do
        for _, clone_name in pairs(clone_names) do
            clone_to_slot[clone_name] = slot_tile
        end
    end
    return clone_to_slot
end

-- mode is "fixed" or "random"
oceans.execute = function(mode, id)
    local assignment
    if mode == "fixed" then
        assignment = oceans.fixed_assignment
    else
        assignment = oceans.random_assignment(id)
    end
    log("Planetary oceans (planet <-- family): " .. serpent.line(assignment))
    local clone_to_slot = oceans.apply(assignment)
    return assignment, clone_to_slot
end

return oceans

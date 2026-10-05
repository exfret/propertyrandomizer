-- Runtime map checks for the isolated development helper, never loaded by the playable mod.
-- API signatures: installed 2.1 docs, LuaGameScript.create_surface and LuaSurface map generation methods.
local biomes = {}

local function copy(value)
    if type(value) ~= "table" then
        return value
    end
    local result = {}
    for key, child in pairs(value) do
        result[key] = copy(child)
    end
    return result
end

local function sorted_keys(values)
    local names = {}
    for name, _ in pairs(values) do
        names[#names + 1] = name
    end
    table.sort(names)
    return names
end

biomes.prepare_surface = function(surface)
    local prototype = prototypes.mod_data["propertyrandomizer-biomes"]
    if prototype == nil or prototype.data.planets[surface.name] == nil then
        return
    end
    assert(surface.name ~= prototype.data.protected_planet, "PRTEST biomes refusing to seed protected planet")
    for chunk in surface.get_chunks() do
        assert(surface.is_chunk_generated(chunk) ~= true, "PRTEST biomes cannot reseed generated surface " .. surface.name)
    end
    -- A fresh planet test surface gets a stable map seed before the helper requests any chunks.
    local seed = settings.startup["propertyrandomizer-seed"].value % 4294967296
    for index = 1, #surface.name do
        seed = (seed * 33 + string.byte(surface.name, index)) % 4294967296
    end
    local map = surface.map_gen_settings
    map.seed = seed
    surface.map_gen_settings = map
    log("PRTEST biomes map-seed " .. surface.name .. "=" .. seed)
end

-- Probe the actual engine convention instead of assuming which point inside a tile is sampled.
-- PropertyExpressionNames selects named expressions; the helper data stage wraps the built-in x/y variables.
local function coordinate_probe(report)
    local first, second, source
    for _, name in pairs(sorted_keys(report.planets)) do
        local hosts = {}
        for _, clone in pairs(sorted_keys(report.planets[name].clones)) do
            local tile = prototypes.tile[clone]
            local host = report.planets[name].clones[clone]
            if tile.needs_correction == false and tile.frozen_variant == nil and tile.thawed_variant == nil then
                if hosts[host] == nil then
                    hosts[host] = clone
                else
                    first, second, source = hosts[host], clone, game.planets[name].create_surface()
                    break
                end
            end
        end
        if source ~= nil then
            break
        end
    end
    if source == nil then
        assert(next(report.planets) == nil, "PRTEST biomes no suitable tiles for coordinate probe")
        return nil
    end
    local offsets = {}
    for axis, _ in pairs({
        x = true,
        y = true,
    }) do
        local map = copy(source.map_gen_settings)
        map.autoplace_settings.entity = {
            treat_missing_as_default = false,
            settings = {},
        }
        map.autoplace_settings.decorative = {
            treat_missing_as_default = false,
            settings = {},
        }
        map.autoplace_settings.tile = {
            treat_missing_as_default = false,
            settings = {
                [first] = {},
                [second] = {},
            },
        }
        map.property_expression_names = {
            ["tile:" .. first .. ":probability"] = "propertyrandomizer-biome-probe-" .. axis,
            ["tile:" .. second .. ":probability"] = "0.25",
        }
        local probe = game.create_surface("propertyrandomizer-biome-coordinate-" .. axis, map)
        local ok, problem = pcall(function()
            probe.request_to_generate_chunks({
                0,
                0,
            }, 0)
            probe.request_to_generate_chunks({
                -1,
                -1,
            }, 0)
            probe.force_generate_chunk_requests()
            log("PRTEST biomes coordinate-probe " .. axis .. " first=" .. first .. " second=" .. second
                .. " negative=" .. probe.get_tile(-1, -1).name .. " origin=" .. probe.get_tile(0, 0).name
                .. " positive=" .. probe.get_tile(1, 1).name)
            local points = {
                {
                    x = -1,
                    y = -1,
                },
                {
                    x = 0,
                    y = 0,
                },
                {
                    x = 1,
                    y = 1,
                },
            }
            local properties = {
                "tile:" .. first .. ":probability",
                "tile:" .. second .. ":probability",
            }
            local scores = probe.calculate_tile_properties(properties, points)
            for _, property in pairs(properties) do
                log("PRTEST biomes coordinate-probe scores " .. property .. "=" .. table.concat(scores[property] or {}, ","))
            end
            assert(probe.get_tile(-1, -1).name == second and probe.get_tile(1, 1).name == first,
                "PRTEST biomes coordinate probe did not follow " .. axis .. " probability")
            local tile = probe.get_tile(0, 0).name
            assert(tile == first or tile == second, "PRTEST biomes unexpected coordinate probe tile")
            offsets[axis] = tile == first and 0.5 or 0
        end)
        game.delete_surface(probe)
        assert(ok == true, problem)
    end
    log("PRTEST biomes tile-sample-offset x=" .. offsets.x .. " y=" .. offsets.y)
    return offsets
end

-- Read creation chains from runtime prototypes, including created entities' own effects.
-- TriggerItem/TriggerEffectItem and LuaEntityPrototype.created_effect: installed 2.1 runtime docs.
local function created_tile_sources()
    local sources = {}
    local maximum_reach = 0
    local function vector_reach(vector)
        return math.abs(vector.x or vector[1]) + math.abs(vector.y or vector[2])
    end
    local function walk(value, reach, targets, active)
        if type(value) ~= "table" then
            return
        end
        local extra = math.abs(value.distance or 0) + math.abs(value.distance_deviation or 0) + math.abs(value.radius or 0)
        local offset = 0
        for _, vector in pairs(value.offsets or {}) do
            offset = math.max(offset, vector_reach(vector))
        end
        if value.offset_deviation ~= nil then
            local box = value.offset_deviation
            offset = offset + math.max(vector_reach(box.left_top or box[1]), vector_reach(box.right_bottom or box[2]))
        end
        local bound = reach + extra + offset
        if value.type == "set-tile" then
            -- Include the tile's extent in the conservative enclosing bound.
            targets[value.tile_name] = math.max(targets[value.tile_name] or 0, bound + 1)
        end
        if type(value.entity_name) == "string" and active[value.entity_name] ~= true then
            local prototype = prototypes.entity[value.entity_name]
            if prototype ~= nil then
                active[value.entity_name] = true
                walk(prototype.created_effect, bound, targets, active)
                active[value.entity_name] = nil
            end
        end
        for _, child in pairs(value) do
            if type(child) == "table" then
                walk(child, bound, targets, active)
            end
        end
    end
    for name, prototype in pairs(prototypes.entity) do
        if prototype.autoplace_specification ~= nil and prototype.created_effect ~= nil then
            local targets = {}
            walk(prototype.created_effect, 0, targets, {[name] = true})
            if next(targets) ~= nil then
                sources[name] = targets
                for _, reach in pairs(targets) do
                    maximum_reach = math.max(maximum_reach, reach)
                end
            end
        end
    end
    return sources, maximum_reach
end

local function created_tile_nearby(position, name, entities, sources)
    for _, entity in pairs(entities) do
        local reach = sources[entity.name][name]
        if reach ~= nil and math.abs(entity.position.x - position.x) <= reach and math.abs(entity.position.y - position.y) <= reach then
            return true
        end
    end
    return false
end

local function terrain_settings(surface)
    local map = copy(surface.map_gen_settings)
    map.autoplace_settings.entity = {
        treat_missing_as_default = false,
        settings = {},
    }
    map.autoplace_settings.decorative = {
        treat_missing_as_default = false,
        settings = {},
    }
    return map
end

local function baseline_settings(surface, assignment, report)
    local map = terrain_settings(surface)
    local tile_settings = map.autoplace_settings.tile.settings
    for clone, _ in pairs(report.clone_to_slot) do
        tile_settings[clone] = nil
        map.property_expression_names["tile:" .. clone .. ":probability"] = nil
        map.property_expression_names["tile:" .. clone .. ":richness"] = nil
    end
    for host, original in pairs(assignment.original_probabilities) do
        local property = "tile:" .. host .. ":probability"
        if original.present == true then
            map.property_expression_names[property] = original.value
        else
            map.property_expression_names[property] = nil
        end
    end
    return map
end

local function sample_positions(surface, assignment)
    local positions = {}
    local map = surface.map_gen_settings
    -- A fixed, bounded search sees independent regions without generating all the searched chunks.
    for x = -4, 4 do
        for y = -4, 4 do
            local position = {
                x = x * 512 + 16,
                y = y * 512 + 16,
            }
            if (map.width == 0 or math.abs(position.x) < map.width / 2)
                and (map.height == 0 or math.abs(position.y) < map.height / 2) then
                positions[#positions + 1] = position
            end
        end
    end
    local values = surface.calculate_tile_properties({assignment.selector}, positions)[assignment.selector]
    assert(values ~= nil, "PRTEST biomes missing selector on " .. surface.name)
    local samples = {
        {
            x = 16,
            y = 16,
        },
    }
    local selected = {}
    for index, position in pairs(positions) do
        local region = values[index]
        assert(region == 1 or region == 2, "PRTEST biomes invalid selector on " .. surface.name)
        if selected[region] == nil then
            selected[region] = position
            samples[#samples + 1] = position
        end
    end
    assert(selected[1] ~= nil and selected[2] ~= nil, "PRTEST biomes did not sample both regions on " .. surface.name)
    return samples
end

local function chunk_positions(position)
    local left = math.floor(position.x / 32) * 32
    local top = math.floor(position.y / 32) * 32
    local positions = {}
    for x = left, left + 31 do
        for y = top, top + 31 do
            positions[#positions + 1] = {
                x = x,
                y = y,
            }
        end
    end
    return positions, {
        {
            left,
            top,
        },
        {
            left + 32,
            top + 32,
        },
    }
end

local function diagnose(surface, baseline, position, actual, expected, assignment, report)
    log("PRTEST biomes diagnostic " .. surface.name .. " at " .. position.x .. "," .. position.y
        .. " actual=" .. actual .. " expected=" .. expected .. " seed=" .. surface.map_gen_settings.seed
        .. " baseline-seed=" .. baseline.map_gen_settings.seed .. " actual-planet=" .. tostring(surface.planet and surface.planet.name)
        .. " baseline-planet=" .. tostring(baseline.planet and baseline.planet.name))
    local names = {}
    names[actual] = true
    names[expected] = true
    names[report.clone_to_slot[actual] or actual] = true
    for clone, host in pairs(assignment.clones) do
        if host == expected or host == report.clone_to_slot[actual] then
            names[clone] = true
        end
    end
    local properties = {assignment.selector}
    for _, name in pairs(sorted_keys(names)) do
        properties[#properties + 1] = "tile:" .. name .. ":probability"
        local tile = prototypes.tile[name]
        local autoplace = tile.autoplace_specification
        if autoplace ~= nil then
            log("PRTEST biomes diagnostic tile " .. name .. " correction=" .. tostring(tile.needs_correction)
                .. " frozen=" .. tostring(tile.frozen_variant and tile.frozen_variant.name)
                .. " thawed=" .. tostring(tile.thawed_variant and tile.thawed_variant.name)
                .. " expression=" .. autoplace.probability_expression)
            for score in string.gmatch(autoplace.probability_expression, "propertyrandomizer_biome_%d+_score_%d+") do
                properties[#properties + 1] = score
                properties[#properties + 1] = score .. "_raw"
            end
        end
    end
    local current = surface.calculate_tile_properties(properties, {position})
    local original = baseline.calculate_tile_properties(properties, {position})
    for _, name in pairs(properties) do
        log("PRTEST biomes diagnostic score " .. name .. " actual=" .. tostring(current[name] and current[name][1])
            .. " baseline=" .. tostring(original[name] and original[name][1]))
    end
    for _, name in pairs(sorted_keys(prototypes.surface_property)) do
        log("PRTEST biomes diagnostic property " .. name .. " actual=" .. surface.get_property(name) .. " baseline=" .. baseline.get_property(name))
    end
end

-- Tile correction runs after raw noise and can move a visual boundary; mechanical host identity stays strict below.
-- Factorio staff explanation: https://forums.factorio.com/viewtopic.php?t=135286
local function region_matches(surface, selector, position, actual, expected, counts)
    if actual == expected then
        return true
    end
    local neighbors = {}
    for dx = -1, 1 do
        for dy = -1, 1 do
            neighbors[#neighbors + 1] = {
                x = position.x + dx,
                y = position.y + dy,
            }
        end
    end
    local values = surface.calculate_tile_properties({selector}, neighbors)[selector]
    for _, value in pairs(values) do
        if value == actual then
            if counts ~= nil then
                if counts.boundary_corrections == 0 then
                    log("PRTEST biomes visual boundary correction at " .. position.x .. "," .. position.y
                        .. " actual=" .. actual .. " expected=" .. expected .. " neighborhood=" .. table.concat(values, ","))
                end
                counts.boundary_corrections = counts.boundary_corrections + 1
            end
            return true
        end
    end
    return false
end

local function check_patch(surface, appearance, baseline, position, assignment, report, decorative_owners, counts, created_sources, maximum_reach, tile_offsets)
    surface.request_to_generate_chunks(position, 0)
    appearance.request_to_generate_chunks(position, 0)
    baseline.request_to_generate_chunks(position, 0)
    surface.force_generate_chunk_requests()
    appearance.force_generate_chunk_requests()
    baseline.force_generate_chunk_requests()
    local positions, area = chunk_positions(position)
    local noise_positions = {}
    for _, tile_position in pairs(positions) do
        noise_positions[#noise_positions + 1] = {
            x = tile_position.x + tile_offsets.x,
            y = tile_position.y + tile_offsets.y,
        }
    end
    local regions = surface.calculate_tile_properties({assignment.selector}, noise_positions)[assignment.selector]
    local creators = {}
    if next(created_sources) ~= nil then
        creators = surface.find_entities_filtered({
            name = sorted_keys(created_sources),
            area = {
                {
                    area[1][1] - maximum_reach,
                    area[1][2] - maximum_reach,
                },
                {
                    area[2][1] + maximum_reach,
                    area[2][2] + maximum_reach,
                },
            },
        })
    end
    for index, tile_position in pairs(positions) do
        local actual = appearance.get_tile(tile_position).name
        local expected = baseline.get_tile(tile_position).name
        local host = report.clone_to_slot[actual]
        if (host or actual) ~= expected or (assignment.original_probabilities[expected] ~= nil and host == nil) then
            diagnose(appearance, baseline, tile_position, actual, expected, assignment, report)
        end
        assert(host == nil or assignment.clones[actual] ~= nil,
            "PRTEST biomes tile clone leaked onto " .. surface.name .. ": " .. actual)
        assert((host or actual) == expected,
            "PRTEST biomes terrain changed on " .. surface.name .. " at " .. tile_position.x .. "," .. tile_position.y
                .. ": " .. actual .. " maps to " .. tostring(host or actual) .. ", expected " .. expected)
        if assignment.original_probabilities[expected] ~= nil then
            assert(host ~= nil, "PRTEST biomes unpainted host tile on " .. surface.name .. ": " .. expected)
        end
        if host ~= nil then
            local region = assignment.clone_regions[actual]
            assert(region_matches(appearance, assignment.selector, noise_positions[index], region, regions[index], counts),
                "PRTEST biomes tile in wrong donor region interior on " .. surface.name .. ": " .. actual
                .. " at " .. tile_position.x .. "," .. tile_position.y)
            counts.tiles[region] = (counts.tiles[region] or 0) + 1
        end
        -- Real planets also run entity creation effects, which may deliberately write tiles after autoplace.
        local final = surface.get_tile(tile_position).name
        local final_host = report.clone_to_slot[final]
        assert(final_host == nil or assignment.clones[final] ~= nil,
            "PRTEST biomes tile clone leaked onto " .. surface.name .. ": " .. final)
        if final_host ~= nil then
            assert(region_matches(surface, assignment.selector, noise_positions[index], assignment.clone_regions[final], regions[index]),
                "PRTEST biomes final tile in wrong donor region interior on " .. surface.name .. ": " .. final)
        end
        if (final_host or final) ~= expected or (assignment.original_probabilities[final] ~= nil and final_host == nil) then
            assert(final_host == nil and created_tile_nearby(tile_position, final, creators, created_sources),
                "PRTEST biomes unexplained post-generation tile on " .. surface.name .. ": " .. final .. " expected " .. expected)
            counts.created_tiles = counts.created_tiles + 1
        end
    end
    local decorations = surface.find_decoratives_filtered({area = area})
    local decorative_positions = {}
    for _, decoration in pairs(decorations) do
        decorative_positions[#decorative_positions + 1] = decoration.position
    end
    local decorative_regions = surface.calculate_tile_properties({assignment.selector}, decorative_positions)[assignment.selector]
    for index, decoration in pairs(decorations) do
        local name = decoration.decorative.name
        local owner = decorative_owners[name]
        if owner ~= nil then
            assert(owner == surface.name, "PRTEST biomes decorative clone leaked onto " .. surface.name .. ": " .. name)
            local region = assignment.decorative_regions[name]
            assert(region == decorative_regions[index], "PRTEST biomes decorative in wrong donor region on " .. surface.name .. ": " .. name)
            counts.decoratives[region] = (counts.decoratives[region] or 0) + decoration.amount
        end
    end
    counts.patches = counts.patches + 1
end

local function check_unmodified(surface, report, decorative_owners)
    local positions, area = chunk_positions({
        x = 16,
        y = 16,
    })
    for _, position in pairs(positions) do
        local name = surface.get_tile(position).name
        assert(report.clone_to_slot[name] == nil, "PRTEST biomes clone on excluded planet " .. surface.name .. ": " .. name)
    end
    for _, decoration in pairs(surface.find_decoratives_filtered({area = area})) do
        local name = decoration.decorative.name
        assert(decorative_owners[name] == nil, "PRTEST biomes decorative on excluded planet " .. surface.name .. ": " .. name)
    end
    log("PRTEST biomes excluded " .. surface.name .. " unchanged")
end

biomes.check = function()
    local prototype = prototypes.mod_data["propertyrandomizer-biomes"]
    assert(prototype ~= nil, "PRTEST biomes metadata missing")
    local report = prototype.data
    assert(report.planets[report.protected_planet] == nil, "PRTEST biomes protected planet was randomized")
    local tile_offsets = coordinate_probe(report)
    local decorative_owners = {}
    local created_sources, maximum_reach = created_tile_sources()
    for name, assignment in pairs(report.planets) do
        for clone, _ in pairs(assignment.decorative_sources or {}) do
            decorative_owners[clone] = name
        end
    end
    for _, name in pairs(sorted_keys(game.planets)) do
        local surface = game.planets[name].create_surface()
        local assignment = report.planets[name]
        if assignment == nil then
            check_unmodified(surface, report, decorative_owners)
        else
            -- Compare terrain before entity creation effects; their random offsets can differ between independent surfaces.
            local appearance = game.create_surface("propertyrandomizer-biome-appearance-" .. name, terrain_settings(surface))
            local baseline = game.create_surface("propertyrandomizer-biome-baseline-" .. name, baseline_settings(surface, assignment, report))
            -- Surface properties are separate from MapGenSettings; preserve them before generating the baseline too.
            -- LuaSurface.get_property/set_property and prototypes.surface_property: installed 2.1 runtime docs.
            for property, _ in pairs(prototypes.surface_property) do
                appearance.set_property(property, surface.get_property(property))
                baseline.set_property(property, surface.get_property(property))
            end
            local counts = {
                tiles = {},
                decoratives = {},
                patches = 0,
                created_tiles = 0,
                boundary_corrections = 0,
            }
            local ok, problem = pcall(function()
                for _, position in pairs(sample_positions(surface, assignment)) do
                    check_patch(surface, appearance, baseline, position, assignment, report, decorative_owners, counts, created_sources, maximum_reach, tile_offsets)
                end
            end)
            game.delete_surface(appearance)
            game.delete_surface(baseline)
            assert(ok == true, problem)
            log("PRTEST biomes " .. name .. " patches=" .. counts.patches
                .. " region1-tiles=" .. (counts.tiles[1] or 0) .. " region2-tiles=" .. (counts.tiles[2] or 0)
                .. " created-tiles=" .. counts.created_tiles
                .. " boundary-corrections=" .. counts.boundary_corrections
                .. " region1-decoratives=" .. (counts.decoratives[1] or 0) .. " region2-decoratives=" .. (counts.decoratives[2] or 0))
        end
    end
end

return biomes

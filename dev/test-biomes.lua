-- Run from the mod root: lua dev/test-biomes.lua
function table.deepcopy(value)
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for key, child in pairs(value) do
        copy[key] = table.deepcopy(child)
    end
    return copy
end

local function same(a, b)
    if type(a) ~= "table" or type(b) ~= "table" then
        return a == b
    end
    for key, value in pairs(a) do
        if not same(value, b[key]) then
            return false
        end
    end
    for key, _ in pairs(b) do
        if a[key] == nil then
            return false
        end
    end
    return true
end

function log(message) end
config = { seed = 73 }
bit32 = {
    bxor = function(a, b) return (a ~ b) & 0xffffffff end,
    lshift = function(a, b) return (a << b) & 0xffffffff end,
    rshift = function(a, b) return (a & 0xffffffff) >> b end,
}
local rng = require("lib/random/rng")
local biomes = require("randomizations/planetary/biomes")
-- The shoreline remapper needs no starting-planet constants or Factorio environment.
package.loaded["helper-tables/constants"] = {}
local oceans = require("randomizations/planetary/oceans")

local function tile(name, color, fluid)
    local result = {
        name = name,
        variants = { main = color },
        map_color = color,
        collision_mask = { layers = { footing = true } },
        walking_speed_modifier = 0.7,
        vehicle_friction_modifier = 1.3,
        absorptions_per_second = { dust = 0.01 },
        minable = {
            mining_time = 1,
            result = "local-yield",
        },
        fluid = fluid,
        default_cover_tile = "cover-result",
        frozen_variant = "frozen-result",
        allows_being_covered = false,
        needs_correction = true,
        autoplace = {
            probability_expression = "local_field",
            richness_expression = "local_field",
            local_expressions = { local_field = "basis_noise{x=x,y=y,seed0=map_seed,seed1=1}" },
        },
    }
    result.type = "tile"
    return result
end

local function planet(name, ground_name)
    local result = {
        name = name,
        map_gen_settings = {
            property_expression_names = {},
            autoplace_settings = {
                tile = {
                    settings = {
                        [ground_name] = {},
                        liquid_slot = {},
                    },
                },
                decorative = { settings = {} },
            },
            cliff_settings = { name = "native-ridge" },
        },
    }
    result.type = "planet"
    return result
end

local function fixture()
    local raw = {
        planet = {
            nauvis = planet("nauvis", "home-ground"),
            alpha = planet("alpha", "alpha-ground"),
            beta = planet("beta", "beta-ground"),
            ["nauvis-copy"] = planet("nauvis-copy", "home-ground"),
        },
        tile = {
            ["home-ground"] = tile("home-ground", "home-look"),
            ["alpha-ground"] = tile("alpha-ground", "alpha-look"),
            ["alpha-ground-2"] = tile("alpha-ground-2", "neighbor-look"),
            ["beta-ground"] = tile("beta-ground", "beta-look"),
            liquid_slot = tile("liquid_slot", "liquid-look", "native-fluid"),
        },
        ["noise-expression"] = {},
        ["optimized-decorative"] = {},
        plant = {
            crop = {
                minable = {
                    mining_time = 1,
                    result = "native-fruit",
                },
                autoplace = {
                    probability_expression = "native_growth",
                    tile_restriction = { "alpha-ground" },
                },
            },
        },
        item = {
            paving = {
                place_as_tile = {
                    result = "cover-result",
                    tile_condition = { "alpha-ground" },
                },
            },
        },
    }
    raw.planet["nauvis-copy"].orig_name = "nauvis"
    raw.tile.other_liquid = tile("other_liquid", "other-liquid-look", "other-fluid")
    for _, prototype in pairs(raw.tile) do
        if prototype.fluid == nil then
            prototype.transitions = {
                {
                    to_tiles = { "liquid_slot" },
                    spritesheet = "warm-shore",
                    transition_group = 1,
                },
                {
                    to_tiles = { "other_liquid" },
                    spritesheet = "cold-shore",
                    transition_group = 2,
                },
            }
            prototype.transitions_between_transitions = {
                {
                    transition_group1 = 1,
                    transition_group2 = 2,
                    spritesheet = "shore-junction",
                },
            }
        end
    end
    raw.planet.beta.map_gen_settings.property_expression_names["tile:beta-ground:probability"] = "a-named-override"
    raw.planet["nauvis-copy"].map_gen_settings.property_expression_names["tile:home-ground:probability"] = "0.42"
    raw["noise-expression"]["a-named-override"] = { expression = 0.5 }
    return raw
end

local function run(swap_oceans)
    rng.prgs = {}
    data = { raw = fixture() }
    function data:extend(prototypes)
        for _, prototype in pairs(prototypes) do
            self.raw[prototype.type] = self.raw[prototype.type] or {}
            assert(self.raw[prototype.type][prototype.name] == nil, "duplicate prototype name")
            self.raw[prototype.type][prototype.name] = prototype
        end
    end
    local before = table.deepcopy(data.raw)
    biomes.capture()
    -- The appearance snapshot survives later changes; mechanical copies use the final host.
    data.raw.tile["alpha-ground"].walking_speed_modifier = 0.4
    data.raw.tile["alpha-ground"].variants.main = "later-alpha-look"
    if swap_oceans == true then
        -- Ocean splitting can add a target after biome capture; use the real ocean-stage remapper.
        local extra = table.deepcopy(data.raw.tile.liquid_slot)
        extra.name = "expanded_liquid"
        data:extend({ extra })
        oceans.follow_looks_in_transitions(data.raw.tile, {
            liquid_slot = "other_liquid",
            other_liquid = "liquid_slot",
            expanded_liquid = "other_liquid",
        })
    end
    local before_biomes = table.deepcopy(data.raw)
    biomes.execute()
    assert(same(data.raw.planet.nauvis, before.planet.nauvis), "original Nauvis changed")
    assert(same(data.raw.tile["home-ground"], before_biomes.tile["home-ground"]), "shared source tile changed")
    for tile_name, prototype in pairs(before_biomes.tile) do
        if prototype.fluid ~= nil then
            assert(same(data.raw.tile[tile_name], prototype), "ocean mechanics/appearance changed")
        end
    end
    assert(biomes.assignments.nauvis == nil)
    assert(biomes.assignments["nauvis-copy"] ~= nil, "Nauvis copy was incorrectly exempted")
    assert(same(data.raw.plant.crop.minable, before.plant.crop.minable), "harvest yield changed")
    assert(data.raw.plant.crop.autoplace.probability_expression == "native_growth")
    assert(#data.raw.plant.crop.autoplace.tile_restriction == 3, "crop did not accept both soil appearances")
    assert(#data.raw.item.paving.place_as_tile.tile_condition == 3, "paving did not accept both appearances")

    for planet_name, assignment in pairs(biomes.assignments) do
        assert(#assignment.sources == 2 and assignment.sources[1] ~= assignment.sources[2])
        local original = before.planet[planet_name]
        assert(same(original.map_gen_settings.cliff_settings, data.raw.planet[planet_name].map_gen_settings.cliff_settings))
        for _, source in pairs(assignment.sources) do
            assert(source ~= (original.orig_name or planet_name), "home palette chosen with two alternatives")
            assert(source ~= "nauvis-copy", "duplicate biased the donor pool")
        end
        for clone_name, host_name in pairs(assignment.clones) do
            local clone = data.raw.tile[clone_name]
            local host = data.raw.tile[host_name]
            assert(clone.autoplace.default_enabled == false, "clone can leak to other planets")
            assert(same(clone.collision_mask, host.collision_mask))
            assert(same(clone.minable, host.minable))
            assert(same(clone.absorptions_per_second, host.absorptions_per_second))
            assert(clone.walking_speed_modifier == host.walking_speed_modifier)
            assert(clone.vehicle_friction_modifier == host.vehicle_friction_modifier)
            assert(clone.default_cover_tile == host.default_cover_tile)
            assert(clone.frozen_variant == host.frozen_variant)
            assert(clone.allows_being_covered == host.allows_being_covered)
            assert(clone.needs_correction == host.needs_correction)
            assert(same(clone.autoplace.local_expressions, host.autoplace.local_expressions), "richness scope changed")
            for other_name, _ in pairs(before.tile) do
                if other_name ~= host_name then
                    assert((host_name < other_name) == (clone_name < other_name), "native probability tie ordering changed")
                end
            end
            assert(string.find(clone.autoplace.probability_expression, assignment.selector, 1, true) ~= nil)
            assert(assignment.clone_regions[clone_name] == 1 or assignment.clone_regions[clone_name] == 2)
            assert(data.raw.planet[planet_name].map_gen_settings.autoplace_settings.tile.settings[clone_name] ~= nil)
            local donor_planet = before.planet[assignment.sources[assignment.clone_regions[clone_name]]]
            for donor_name, _ in pairs(donor_planet.map_gen_settings.autoplace_settings.tile.settings) do
                local donor = before.tile[donor_name]
                if donor.fluid == nil then
                    assert(same(clone.variants, donor.variants), "captured ground appearance changed")
                    assert(same(clone.transitions, before_biomes.tile[donor_name].transitions), "biome restored stale ocean shorelines")
                    assert(same(clone.transitions_between_transitions, before_biomes.tile[donor_name].transitions_between_transitions), "shoreline junctions no longer match their transitions")
                    if swap_oceans == true then
                        assert(same(clone.transitions[1].to_tiles, { "other_liquid" }), "warm shore still targets its old ocean")
                        assert(same(clone.transitions[2].to_tiles, {
                            "expanded_liquid",
                            "liquid_slot",
                        }), "cold shore lost the replacement ocean or its extra clone")
                    end
                end
            end
        end
    end
    local found_locals = false
    local found_override = false
    local found_number = false
    for _, expression in pairs(data.raw["noise-expression"]) do
        if expression.local_expressions ~= nil then
            found_locals = true
            assert(expression.local_expressions.local_field ~= nil)
        end
        if expression.expression == "var('a-named-override')" then
            found_override = true
        end
        if expression.expression == 0.42 then
            found_number = true
        end
    end
    assert(found_locals and found_override and found_number, "host expression context was lost")
    return table.deepcopy(data.raw)
end

local first = run(false)
local second = run(false)
assert(same(first, second), "same seed produced different regions/prototypes")
local with_oceans = run(true)
assert(same(with_oceans, run(true)), "same seed with ocean swaps produced different regions/prototypes")
print("Biomes: Nauvis exclusion, copy mixing, deterministic palettes, final shorelines, host mechanics and agricultural restrictions passed")

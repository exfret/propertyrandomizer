function table.deepcopy(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for key, child in pairs(value) do copy[key] = table.deepcopy(child) end
    return copy
end
package.loaded["__core__/lualib/collision-mask-util"] = {
    get_mask = function(entity) return entity.collision_mask or {layers = {water = true, shared = true}} end,
    masks_collide = function(a, b)
        for layer, _ in pairs(a.layers) do if b.layers[layer] then return true end end
        return false
    end,
}
local masks = require("__core__/lualib/collision-mask-util")
local profiles = require("src/randomizations/planetary/biome-profiles")
local collision = require("src/randomizations/planetary/biome-collision")
local types = {entity = {container = true, character = true}, item = {item = true, ["space-platform-starter-pack"] = true}}
local function tile(name, layers, fluid)
    return {name = name, collision_mask = {layers = layers or {ground = true}}, autoplace = {}, fluid = fluid}
end
local function fixture()
    return {
        ["collision-layer"] = {ground = {}, water = {}, shared = {}},
        tile = {
            ["grass-1"] = tile("grass-1"),
            ["sand-1"] = tile("sand-1"),
            lava = tile("lava", {water = true, shared = true}, "lava"),
            wet = tile("wet", {water = true, shared = true}, "water"),
            alien = tile("alien"),
            paved = tile("paved"),
            platform = tile("platform"),
            foundation = tile("foundation"),
            soil = tile("soil"),
            void = {name = "void", collision_mask = {layers = {water = true}}},
        },
        item = {paving = {place_as_tile = {result = "paved"}}, soil = {place_as_tile = {result = "soil"}}},
        ["space-platform-starter-pack"] = {pack = {surface = "orbit", tiles = {{tile = "platform"}}}},
        planet = {gleba = {name = "gleba", map_gen_settings = {autoplace_settings = {tile = {settings = {alien = {}, lava = {}}}}}}},
        container = {building = {name = "building", type = "container", collision_box = {{-0.9, -0.4}, {0.9, 0.4}}, tile_width = 2, tile_height = 1}},
        character = {player = {name = "player", type = "character", collision_mask = {layers = {shared = true}}}},
        projectile = {projectile = {hit_collision_mask = {layers = {shared = true}}}},
    }
end
local count = 0
local function test(name, run) run(); count = count + 1; print("PASS " .. name) end

test("semantic families, liquids, construction, platform and void", function()
    local raw = fixture()
    raw.tile.soil.is_foundation = true
    local membership, platform = profiles.classify(raw, types)
    assert(membership["grass-1"].forest and membership["sand-1"].sandy)
    assert(membership.alien.forest and not membership.lava.forest)
    assert(membership.wet.water and membership.wet.fluid and not membership.lava.water)
    assert(membership.soil.artificial and not membership.soil.foundation)
    assert(membership.foundation.foundation and membership.platform.foundation and platform.platform)
    assert(not membership.void.everything)
end)

test("visible appearance and mod registration override mechanical host", function()
    local raw = fixture()
    local original = profiles.classify(raw, types)
    raw.tile.clone = tile("clone")
    raw.planet.gleba.map_gen_settings.autoplace_settings.tile.settings.clone = {}
    raw["mod-data"] = {
        ["propertyrandomizer-biomes"] = {data = {clone_to_appearance = {clone = "sand-1"}}},
        ["propertyrandomizer-biome-registrations"] = {data = {tiles = {alien = {forest = false, tundra = true}}}},
    }
    local membership = profiles.classify(raw, types, original)
    assert(membership.clone.sandy and not membership.clone.forest)
    assert(membership.alien.tundra and not membership.alien.forest)
end)

local function prepare(raw)
    return collision.prepare(raw, types, function(entries)
        for _, entry in pairs(entries) do raw[entry.type][entry.name] = entry end
    end)
end

test("planet families include every Vulcanus copy and named terrain copies", function()
    local raw = fixture()
    for i = 1, 3 do
        local name = "volcanic-land-" .. i
        raw.tile[name] = tile(name)
        raw.planet["vulcanus-copy-" .. i] = {
            name = "vulcanus-copy-" .. i,
            orig_name = "vulcanus",
            map_gen_settings = {autoplace_settings = {tile = {settings = {[name] = {}, lava = {}}}}},
        }
    end
    raw.tile.sand_copy = tile("sand_copy")
    raw.tile.sand_copy.orig_name = "sand-1"
    local sources = profiles.classify(raw, types)
    for i = 1, 3 do assert(sources["volcanic-land-" .. i].volcanic) end
    assert(not sources.lava.volcanic and sources.sand_copy.sandy)
    raw.tile.appearance_copy = tile("appearance_copy")
    raw["mod-data"] = { ["propertyrandomizer-biomes"] = {data = {clone_to_appearance = {appearance_copy = "volcanic-land-3"}}} }
    assert(profiles.classify(raw, types, sources).appearance_copy.volcanic)
    local links = profiles.tile_sources(raw)
    assert(links.sand_copy == "sand-1" and links.appearance_copy == "volcanic-land-3")
    for _, profile in pairs(profiles.choices) do assert(profile ~= "normal") end
end)

test("fluid placement retains entity collision and prototype hit filters", function()
    local raw = fixture()
    local membership, platform = profiles.classify(raw, types)
    local aliases = assert(prepare(raw))
    profiles.mark(raw, membership, platform)
    local entity = raw.container.building
    local native = {{area = {{-0.1, -0.1}, {0.1, 0.1}}, colliding_tiles = {layers = {native_blocker = true}}}}
    entity.tile_buildability_rules = table.deepcopy(native)
    entity.surface_conditions = {{property = "gravity", min = 1}}
    assert(collision.supported(entity, raw, platform))
    collision.apply(entity, "water", aliases)
    assert(not masks.masks_collide(entity.collision_mask, raw.tile.wet.collision_mask))
    assert(masks.masks_collide(entity.collision_mask, raw.character.player.collision_mask))
    assert(masks.masks_collide(entity.collision_mask, raw.projectile.projectile.hit_collision_mask))
    assert(entity.tile_buildability_rules[1].colliding_tiles.layers.native_blocker)
    assert(entity.tile_buildability_rules[2].required_tiles.layers[profiles.layer("platform")])
    assert(entity.surface_conditions[1].min == 1)
    for _, alias in pairs(aliases) do assert(raw.tile.wet.collision_mask.layers[alias] == nil) end
end)

test("Normal keeps native mask and rules; unsupported platform masks stay native", function()
    local raw = fixture()
    local _, platform = profiles.classify(raw, types)
    local aliases = assert(prepare(raw))
    local entity = raw.container.building
    local original_mask = entity.collision_mask
    collision.apply(entity, "normal", aliases)
    assert(entity.collision_mask == original_mask and entity.tile_buildability_rules == nil)
    entity.collision_mask.layers.ground = true
    assert(not collision.supported(entity, raw, platform))
    entity.collision_mask.layers.ground = nil
    entity.collision_mask.not_colliding_with_itself = true
    assert(not collision.supported(entity, raw, platform))
end)

test("profile collision masks enforce terrain and distinguish upgrade targets", function()
    local raw = fixture()
    local membership, platform = profiles.classify(raw, types)
    local aliases = assert(prepare(raw))
    profiles.mark(raw, membership, platform)
    local original = raw.container.building
    original.fast_replaceable_group = "fixture-group"
    local forest = table.deepcopy(original)
    local water = table.deepcopy(original)
    collision.apply(forest, "forest", aliases)
    collision.apply(water, "water", aliases)
    assert(forest.fast_replaceable_group == water.fast_replaceable_group)
    assert(forest.collision_mask.layers[profiles.blocking_layer("forest")])
    assert(water.collision_mask.layers[profiles.blocking_layer("forest")] == nil)
    assert(not masks.masks_collide(forest.collision_mask, raw.tile["grass-1"].collision_mask))
    assert(masks.masks_collide(forest.collision_mask, raw.tile.wet.collision_mask))
    assert(masks.masks_collide(water.collision_mask, raw.tile["grass-1"].collision_mask))
    assert(not masks.masks_collide(water.collision_mask, raw.tile.wet.collision_mask))
    assert(not masks.masks_collide(water.collision_mask, raw.tile.platform.collision_mask))
    assert(masks.masks_collide(water.collision_mask, raw.tile.void.collision_mask))
end)

test("layer capacity failure makes no partial edits", function()
    local raw = fixture()
    for i = 1, 256 do raw["collision-layer"]["mod_" .. i] = {} end
    local aliases, problem = prepare(raw)
    assert(aliases == nil and problem ~= nil)
    assert(raw.container.building.collision_mask == nil)
end)

test("modded default masks and shared tile dictionaries are respected", function()
    local raw = fixture()
    raw["utility-constants"] = {default = {default_collision_masks = {container = {layers = {water = true}}}}}
    raw.character.player.collision_mask.layers = raw.tile.wet.collision_mask.layers
    local aliases = assert(prepare(raw))
    assert(raw.container.building.collision_mask.layers[aliases.water])
    assert(not raw.container.building.collision_mask.layers.shared)
    assert(raw.tile.wet.collision_mask.layers[aliases.water] == nil)
    assert(raw.character.player.collision_mask.layers[aliases.water])
end)
print(count .. " biome placement tests passed")

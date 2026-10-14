local descriptions = require("src/randomizations/planetary/biome-descriptions")
defines = {prototypes = {entity = {container = true}, item = {item = true}}}
local entity = {
    type = "container",
    name = "fixture",
    localised_description = "Existing entity text",
    tile_buildability_rules = {
        {required_tiles = {layers = {propertyrandomizer_biome_sandy = true}}},
        {required_tiles = {layers = {propertyrandomizer_biome_sandy = true}}},
        {colliding_tiles = {layers = {water_tile = true}}},
    },
}
local raw = {
    container = {
        fixture = entity,
        ["old-fixture"] = {type = "container", name = "old-fixture", tile_buildability_rules = entity.tile_buildability_rules},
        ordinary = {type = "container", name = "ordinary", localised_description = "Unchanged"},
    },
    item = {
        described = {type = "item", name = "described", place_result = "fixture", localised_description = "Existing item text"},
        inherited = {type = "item", name = "inherited", place_result = "fixture"},
        ordinary = {type = "item", name = "ordinary", place_result = "ordinary"},
    },
}
descriptions.apply(raw, defines.prototypes)
local function count(value, key)
    if type(value) ~= "table" then return 0 end
    local result = value[1] == key and 1 or 0
    for _, child in pairs(value) do result = result + count(child, key) end
    return result
end
for _, prototype in pairs({entity, raw.item.described, raw.item.inherited}) do
    assert(count(prototype.localised_description, "propertyrandomizer-biomes.description") == 1)
    assert(count(prototype.localised_description, "propertyrandomizer-biome-profile.sandy") == 1)
    assert(count(prototype.localised_description, "propertyrandomizer-biome-summary.sandy") == 0, "tooltips stay concise")
end
assert(entity.localised_description[2] == "Existing entity text")
assert(raw.item.described.localised_description[2] == "Existing item text")
assert(raw.item.inherited.localised_description[2][3] == "Existing entity text")
assert(raw.container["old-fixture"].localised_description == nil)
assert(raw.container.ordinary.localised_description == "Unchanged")
assert(raw.item.ordinary.localised_description == nil)
print("PASS biome descriptions preserve text and annotate entities and placing items once")

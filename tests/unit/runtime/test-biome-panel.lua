local biomes = require("src/runtime/panel/biomes")
local entities = {
    rectangular = {
        name = "rectangular", tile_width = 2, tile_height = 1,
        tile_buildability_rules = {
            {
                area = {left_top = {x = -0.9, y = -0.4}, right_bottom = {x = 0.9, y = 0.4}},
                required_tiles = {layers = {propertyrandomizer_biome_water = true, propertyrandomizer_biome_platform = true}},
            },
        },
    },
    ordinary = {name = "ordinary", tile_width = 1, tile_height = 1},
}
entities["old-rectangular"] = entities.rectangular
entities.hidden = {name = "hidden", hidden = true, tile_buildability_rules = entities.rectangular.tile_buildability_rules}
local rows = biomes.rows(entities)
assert(#rows == 1 and rows[1].profile == "water")
assert(rows[1].width == nil and rows[1].height == nil)
defines = {rich_text_setting = {highlight = "highlight"}}
local captions, specs = {}, {}
local function element(spec, parent)
    spec = spec or {}
    local result = {
        name = spec.name,
        parent = parent,
        style = {},
        children = {},
        tabs = {},
        selected_index = spec.selected_index,
        tags = spec.tags or {},
    }
    result.add = function(child_spec)
        table.insert(specs, child_spec)
        if child_spec.type == "scroll-pane" then assert(child_spec.direction == nil) end
        if child_spec.caption ~= nil then table.insert(captions, child_spec.caption) end
        assert(child_spec.tooltip == nil or child_spec.tooltip[1] ~= "", "tile lists must not be tooltips")
        local child = element(child_spec, result)
        table.insert(result.children, child)
        if child.name ~= nil then result[child.name] = child end
        return child
    end
    result.add_tab = function(tab, content)
        table.insert(result.tabs, {tab = tab, content = content})
    end
    result.clear = function() result.children = {} end
    return result
end
prototypes = {
    entity = entities,
    tile = {
        wet = {name = "wet", localised_name = "Wet"},
        wet_copy = {name = "wet_copy", localised_name = "Wet copy"},
    },
    mod_data = {
        ["propertyrandomizer-biome-placement"] = {data = {memberships = {wet = {water = true}, wet_copy = {water = true}}}},
        ["propertyrandomizer-biomes"] = {data = {clone_to_appearance = {wet_copy = "wet"}}},
    },
}
assert(#biomes.tiles("water") == 1, "appearance copies share one tile entry")
local page = biomes.create(element())
biomes.resize(page, 700)
local pane = page["randomizer-biome-tabs"]
assert(#pane.tabs == 2 and pane.selected_tab_index == 1)
local selector = pane["randomizer-biome-tiles"]["randomizer-biome-tile-choice"]
assert(#selector.children == 9)
assert(biomes.on_click({element = selector.children[9]}))
assert(selector.children[9].toggled and not selector.children[1].toggled)
local body = selector.parent["randomizer-biome-tile-body"]
assert(body["randomizer-biome-tile-summary"].caption[1] == "propertyrandomizer-biome-summary.water")
assert(#body["randomizer-biome-tile-list"].children == 1)
assert(body["randomizer-biome-tile-list"].children[1].style.rich_text_setting == defines.rich_text_setting.highlight)
local found_profile, found_tooltip = false, false
for _, caption in pairs(captions) do
    if type(caption) == "table" then
        assert(caption[1] ~= "propertyrandomizer-biome-profile.normal")
        assert(caption[1] ~= "propertyrandomizer-biomes.size")
        found_profile = found_profile or caption[1] == "propertyrandomizer-biome-profile.water"
    end
end
for _, spec in pairs(specs) do
    if spec.type == "table" then assert(spec.column_count == 2) end
    found_tooltip = found_tooltip or (spec.tooltip ~= nil and spec.tooltip[1] == "propertyrandomizer-biome-summary.water")
end
assert(found_profile and found_tooltip)
local opened
game = {players = {[1] = {open_factoriopedia_gui = function(prototype) opened = prototype end}}}
assert(biomes.on_click({element = body["randomizer-biome-tile-list"].children[1], player_index = 1}))
assert(opened == prototypes.tile.wet)
assert(biomes.on_click({element = {tags = {biome_entity = "rectangular"}}, player_index = 1}))
assert(opened == entities.rectangular)
assert(not biomes.on_click({element = {tags = {}}}))
prototypes.tile.wet_variant = {name = "wet_variant", localised_name = "Wet"}
prototypes.mod_data["propertyrandomizer-biome-placement"].data.memberships.wet_variant = {water = true}
assert(#biomes.tiles("water") == 1, "cosmetic variants with the same displayed name share one entry")
prototypes.tile.wet_copy.localised_name = "Distinct copy name"
prototypes.mod_data["propertyrandomizer-biome-placement"].data.tile_sources = {wet_copy = "wet"}
assert(#biomes.tiles("water") == 1, "prototype copies resolve to their original tile")
print("PASS biome panel deduplicates tiles, links prototypes and shows summary tooltips without footprints or Normal")

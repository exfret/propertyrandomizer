-- Run from the mod root: lua tests/unit/dev/test-biome-tile-references.lua
local tile_references = require("src/randomizations/planetary/biome-tile-references")

local function same_values(actual, expected)
    assert(#actual == #expected, "Unexpected list length: " .. #actual .. " ~= " .. #expected)
    local function key(value)
        if type(value) == "table" then
            return value[1] .. "/" .. value[2]
        end
        return value
    end
    local counts = {}
    for _, value in pairs(expected) do
        local value_key = key(value)
        counts[value_key] = (counts[value_key] or 0) + 1
    end
    for _, value in pairs(actual) do
        local value_key = key(value)
        assert(counts[value_key] ~= nil and counts[value_key] > 0, "Unexpected entry: " .. value_key)
        counts[value_key] = counts[value_key] - 1
    end
end

local soil_names = {
    "soil-slot",
    "soil-copy-a",
}
local transition = {
    "soil-slot",
    "shore-slot",
}
local restrictions = {
    "soil-slot",
    transition,
    {
        "soil-copy-a",
        "shore-slot",
    },
}
local rule = {
    required_tiles = { layers = { soil_mask = true } },
    colliding_tiles = { layers = { water_mask = true } },
    remove_on_collision = true,
}
local graphics_names = {
    "soil-slot",
    "shore-slot",
}
local raw = {
    fabricated_group = {
        paving_item = {
            place_as_tile = {
                tile_condition = soil_names,
                result = "soil-slot",
                invert = true,
            },
        },
        planted_entity = {
            autoplace = {
                tile_restriction = restrictions,
                probability_expression = "host-noise",
            },
            tile_buildability_rules = { rule },
        },
        wild_decoration = { autoplace = { tile_restriction = restrictions } },
        neighboring_tile = {
            allowed_neighbors = soil_names,
            transitions = { { to_tiles = graphics_names } },
            frozen_variant = "soil-slot",
            thawed_variant = "shore-slot",
            next_direction = "soil-slot",
            default_cover_tile = "shore-slot",
            transition_merges_with_tile = "soil-slot",
        },
        selector = {
            select = {
                mode = { "any-tile" },
                tile_filters = { "soil-slot" },
            },
            alt_select = {
                mode = { "any-tile" },
                tile_filters = { "shore-slot" },
                tile_filter_mode = "blacklist",
            },
        },
        unrelated = { description = "soil-slot" },
        unrestricted = { autoplace = { probability_expression = "other-noise" } },
    },
}
local clones_of = {
    ["soil-slot"] = {
        "soil-copy-a",
        "soil-copy-b",
        "soil-copy-b",
    },
    ["shore-slot"] = { "shore-copy" },
}

local function verify()
    same_values(soil_names, {
        "soil-slot",
        "soil-copy-a",
        "soil-copy-b",
    })
    same_values(restrictions, {
        "soil-slot",
        "soil-copy-a",
        "soil-copy-b",
        {
            "soil-slot",
            "shore-slot",
        },
        {
            "soil-slot",
            "shore-copy",
        },
        {
            "soil-copy-a",
            "shore-slot",
        },
        {
            "soil-copy-a",
            "shore-copy",
        },
        {
            "soil-copy-b",
            "shore-slot",
        },
        {
            "soil-copy-b",
            "shore-copy",
        },
    })
    same_values(transition, {
        "soil-slot",
        "shore-slot",
    })
    local group = raw.fabricated_group
    assert(group.paving_item.place_as_tile.tile_condition == group.neighboring_tile.allowed_neighbors)
    assert(group.planted_entity.autoplace.tile_restriction == group.wild_decoration.autoplace.tile_restriction)
    assert(group.paving_item.place_as_tile.result == "soil-slot")
    assert(group.paving_item.place_as_tile.invert == true)
    assert(group.planted_entity.autoplace.probability_expression == "host-noise")
    assert(group.planted_entity.tile_buildability_rules[1] == rule)
    assert(rule.required_tiles.layers.soil_mask and rule.colliding_tiles.layers.water_mask)
    assert(rule.required_tiles[1] == nil and rule.colliding_tiles[1] == nil)
    assert(rule.remove_on_collision == true)
    assert(group.neighboring_tile.frozen_variant == "soil-slot")
    assert(group.neighboring_tile.thawed_variant == "shore-slot")
    assert(group.neighboring_tile.next_direction == "soil-slot")
    assert(group.neighboring_tile.default_cover_tile == "shore-slot")
    assert(group.neighboring_tile.transition_merges_with_tile == "soil-slot")
    same_values(graphics_names, {
        "soil-slot",
        "shore-slot",
    })
    same_values(group.selector.select.tile_filters, {
        "soil-slot",
        "soil-copy-a",
        "soil-copy-b",
    })
    same_values(group.selector.alt_select.tile_filters, {
        "shore-slot",
        "shore-copy",
    })
    assert(group.selector.alt_select.tile_filter_mode == "blacklist")
    assert(group.unrelated.description == "soil-slot")
    assert(group.unrestricted.autoplace.tile_restriction == nil)
    assert(group.unrestricted.allowed_neighbors == nil)
end

tile_references.extend(raw, clones_of)
verify()
-- Repeated calls and shared lists must not accumulate duplicates or change pair ordering.
tile_references.extend(raw, clones_of)
verify()
print("Biome tile references: placement, plant autoplace, transition pairs, selection filters and shared lists passed")

-- Engine fixtures are added after the randomizer's graph so they cannot affect progression.
local fixtures = {}

fixtures.run = function()
    for name, layer in pairs({ground = "ground_tile", water = "water_tile"}) do
        local tile = table.deepcopy(data.raw.tile["grass-1"])
        tile.name = "prtest-tile-" .. name
        tile.autoplace = nil
        tile.minable = nil
        tile.allowed_neighbors = nil
        tile.fluid = nil
        tile.collision_mask = {layers = {[layer] = true}}
        data:extend({tile})
    end
    local area = {{-0.9, -0.4}, {0.9, 0.4}}
    local cases = {
        required = {{area = area, required_tiles = {layers = {water_tile = true}}}},
        forbidden = {{area = area, colliding_tiles = {layers = {water_tile = true}}}},
        empty = {{area = area, required_tiles = {layers = {}}}},
        overlap = {
            {area = area, required_tiles = {layers = {water_tile = true}}},
            {area = area, required_tiles = {layers = {ground_tile = true}}},
        },
        conflict = {{area = area, required_tiles = {layers = {water_tile = true}}, colliding_tiles = {layers = {water_tile = true}}}},
        collision = {{area = area, required_tiles = {layers = {water_tile = true}}}},
        adjacent = {
            {area = {{-0.9, -0.4}, {-0.1, 0.4}}, required_tiles = {layers = {ground_tile = true}}},
            {area = {{0.1, -0.4}, {0.9, 0.4}}, required_tiles = {layers = {water_tile = true}}},
        },
        shared_cell = {
            {area = {{-0.4, -0.4}, {-0.1, 0.4}}, required_tiles = {layers = {ground_tile = true}}},
            {area = {{0.1, -0.4}, {0.4, 0.4}}, required_tiles = {layers = {water_tile = true}}},
        },
    }
    for name, rules in pairs(cases) do
        local entity = table.deepcopy(data.raw.container["wooden-chest"])
        entity.name = "prtest-tile-rule-" .. name
        entity.hidden = true
        entity.minable = nil
        entity.next_upgrade = nil
        entity.placeable_by = nil
        entity.surface_conditions = nil
        entity.tile_width = 2
        entity.tile_height = 1
        entity.collision_box = area
        entity.collision_mask = {layers = {}}
        if name == "collision" then
            entity.collision_mask = {layers = {water_tile = true}}
        elseif name == "shared_cell" then
            entity.tile_width = 1
        end
        entity.tile_buildability_rules = rules
        data:extend({entity})
    end
end

return fixtures

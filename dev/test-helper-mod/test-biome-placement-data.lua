local compiler = require("__propertyrandomizer__/src/randomizations/planetary/biome-collision")
local profiles = require("__propertyrandomizer__/src/randomizations/planetary/biome-profiles")
local compatibility = require("__propertyrandomizer__/src/randomizations/unified/handler-helpers/entity")

local tests = {}

tests.run = function()
    for kind, _ in pairs(defines.prototypes.entity) do
        for _, entity in pairs(data.raw[kind] or {}) do
            assert(compatibility.next_upgrade_problem(entity) == nil, "PRTEST incompatible automatic upgrade target on " .. entity.name)
        end
    end
    local report = (data.raw["mod-data"] or {})["propertyrandomizer-biome-placement"]
    if report == nil then return end
    local aliases = report.data.aliases
    for name, layers in pairs({
        forest = {ground_tile = true, propertyrandomizer_biome_forest = true, propertyrandomizer_biome_everything = true},
        water = {water_tile = true, propertyrandomizer_biome_water = true, propertyrandomizer_biome_fluid = true, propertyrandomizer_biome_everything = true},
        platform = {ground_tile = true, propertyrandomizer_biome_platform = true, propertyrandomizer_biome_foundation = true, propertyrandomizer_biome_everything = true},
        void = {water_tile = true},
    }) do
        local tile = table.deepcopy(data.raw.tile["prtest-tile-ground"])
        tile.name = "prtest-biome-" .. name
        tile.collision_mask = {layers = layers}
        for _, profile in pairs(profiles.order) do
            if profile ~= "normal" then
                layers[profiles.blocking_layer(profile)] = not (layers[profiles.layer(profile)] or layers[profiles.layer("platform")]) or nil
            end
        end
        data:extend({tile})
    end
    for _, profile in pairs({"normal", "forest", "water", "everything"}) do
        local entity = table.deepcopy(data.raw.container["prtest-tile-rule-required"])
        entity.name = "prtest-biome-" .. profile
        entity.tile_buildability_rules = nil
        entity.collision_mask = {layers = {water_tile = true, player = true, object = true}}
        for layer, alias in pairs(aliases) do
            if entity.collision_mask.layers[layer] then entity.collision_mask.layers[alias] = true end
        end
        compiler.apply(entity, profile, aliases)
        data:extend({entity})
        local mask_only = table.deepcopy(entity)
        mask_only.name = "prtest-mask-only-" .. profile
        mask_only.tile_buildability_rules = nil
        data:extend({mask_only})
    end

    -- Different biome profiles retain the group name but cannot form upgrade-planner pairs.
    for _, profile in pairs({"normal", "forest", "water", "everything"}) do
        local entity = table.deepcopy(data.raw.container["prtest-biome-" .. profile])
        entity.name = "prtest-upgrade-" .. profile
        entity.hidden = false
        entity.fast_replaceable_group = "prtest-biome-upgrades"
        entity.next_upgrade = nil
        entity.minable = {mining_time = 0.1, result = entity.name}
        local item = table.deepcopy(data.raw.item["wooden-chest"])
        item.name = entity.name
        item.hidden = false
        item.place_result = entity.name
        data:extend({entity, item})
    end
    local forest = data.raw.container["prtest-upgrade-forest"]
    forest.next_upgrade = "prtest-upgrade-water"
    assert(compatibility.next_upgrade_problem(forest) == "upgrade target has a different collision mask")
    forest.next_upgrade = nil
    local twin = table.deepcopy(forest)
    twin.name = "prtest-upgrade-forest-twin"
    twin.minable.result = twin.name
    local item = table.deepcopy(data.raw.item[forest.name])
    item.name = twin.name
    item.place_result = twin.name
    data:extend({twin, item})
    forest.next_upgrade = twin.name
    assert(compatibility.next_upgrade_problem(forest) == nil)
end

return tests

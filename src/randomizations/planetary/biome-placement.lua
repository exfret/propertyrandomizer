-- Prepare terrain metadata once; gameplay choices belong to the unified biome-placement handler.
local appearances = require("src/randomizations/planetary/biomes")
local profiles = require("src/randomizations/planetary/biome-profiles")
local collision = require("src/randomizations/planetary/biome-collision")
local check = require("src/randomizations/planetary/check")
local policy = require("src/randomizations/planetary/biome-entity-policy")

local placement = {}

placement.prepare = function()
    local sources = profiles.classify(data.raw, defines.prototypes)
    local aliases, problem = collision.prepare(data.raw, defines.prototypes, function(values) data:extend(values) end)
    if aliases == nil then
        return problem
    end
    if config.planetary_biomes then
        appearances.execute()
    end
    local memberships, platform = profiles.classify(data.raw, defines.prototypes, sources)
    profiles.mark(data.raw, memberships, platform)
    -- Collision-group identities changed; the existing planetary audit already tracks this feature.
    check.moved_features["biome-placement"] = true
    local entities = {}
    for kind, _ in pairs(defines.prototypes.entity) do
        if policy.randomized[kind] == true then
            for name, entity in pairs(data.raw[kind] or {}) do
                if collision.supported(entity, data.raw, platform) then
                    entities[name] = "randomized"
                end
            end
        end
    end
    data:extend({
        {
            type = "mod-data",
            name = "propertyrandomizer-biome-placement",
            data = {
                assignments = {},
                entities = entities,
                aliases = aliases,
                memberships = memberships,
                tile_sources = profiles.tile_sources(data.raw),
                platform = platform,
            },
        },
    })
end

return placement

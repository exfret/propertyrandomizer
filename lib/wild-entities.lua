-- Entities found in the wild: which of the entities map generation places can move to another's spot (entity randomization, randomizations/graph/unified/handlers/entity.lua), and the placement overrides a planet can have for a single entity
-- An entity has one autoplace, so entity randomization only moves an entity found in the wild on one planet; planet copies (lib/dupe-planets.lua) clone their original's movable ones, so each copy has its own
-- A planet's map gen can override an entity's placement probability and richness there (PropertyExpressionNames, entity:<name>:probability), which keeps an entity off a planet whose settings or sliders would place it

local dutils = require("lib/data-utils")

local wild = {}

-- The noise expression a planet names as an entity's probability to never place it there (with underscores, like the mod's other noise expression names)
wild.never_name = "propertyrandomizer_never_placed"

-- The placement properties a planet can override for a single entity
local PROPERTIES = {
    "probability",
    "richness",
}

local function property_key(entity_name, property)
    return "entity:" .. entity_name .. ":" .. property
end

-- Whether a property expression is a constant at most 0: a number, a number written as a string, or the name of a noise expression that's one
local function is_nothing(value)
    local number = tonumber(value)
    if number == nil and type(value) == "string" then
        local expression = (data.raw["noise-expression"] or {})[value]
        if expression ~= nil then
            number = tonumber(expression.expression)
        end
    end
    return number ~= nil and number <= 0
end

-- Whether the planet's map generation never places the entity: it overrides the entity's probability there with a constant at most 0
wild.never_placed = function(planet, entity_name)
    local overrides = (planet.map_gen_settings or {}).property_expression_names
    return overrides ~= nil and is_nothing(overrides[property_key(entity_name, "probability")])
end

-- Makes the planet's map generation never place the entity, whatever its settings and sliders say
wild.keep_off = function(planet, entity_name)
    if (data.raw["noise-expression"] or {})[wild.never_name] == nil then
        data:extend({
            {
                type = "noise-expression",
                name = wild.never_name,
                expression = "0",
            },
        })
    end
    planet.map_gen_settings.property_expression_names = planet.map_gen_settings.property_expression_names or {}
    planet.map_gen_settings.property_expression_names[property_key(entity_name, "probability")] = wild.never_name
end

-- The planet's placement overrides for the entity: property --> what overrides it (an expression name or a constant)
wild.overrides = function(planet, entity_name)
    local overrides = {}
    local names = (planet.map_gen_settings or {}).property_expression_names or {}
    for _, property in pairs(PROPERTIES) do
        overrides[property] = names[property_key(entity_name, property)]
    end
    return overrides
end

-- Gives the entity these placement overrides on the planet (another entity's wild.overrides, say) in place of its own
wild.set_overrides = function(planet, entity_name, overrides)
    local map_gen_settings = planet.map_gen_settings
    if map_gen_settings == nil or (map_gen_settings.property_expression_names == nil and next(overrides) == nil) then
        return
    end
    map_gen_settings.property_expression_names = map_gen_settings.property_expression_names or {}
    for _, property in pairs(PROPERTIES) do
        map_gen_settings.property_expression_names[property_key(entity_name, property)] = overrides[property]
    end
end

-- Entities whose autoplace stays where it is, as a set of names:
--   * resources, which are placed and mined their own way (logic mines them by resource category, lib/logic/concrete.lua)
--   * cliffs that a planet's cliff_settings name
--   * planted entities (some item's plant_result), whose autoplace tile_restriction is what agricultural tower plots use (space-age/prototypes/entity/plants.lua)
--   * entities a technology's research trigger has you mine, which might not show up anymore once moved
wild.kept_in_place = function()
    local kept = {}
    for _, resource in pairs(data.raw.resource or {}) do
        kept[resource.name] = true
    end
    for _, planet in pairs(data.raw.planet or {}) do
        local cliff_settings = (planet.map_gen_settings or {}).cliff_settings
        if cliff_settings ~= nil and cliff_settings.name ~= nil then
            kept[cliff_settings.name] = true
        end
    end
    for _, item in pairs(dutils.get_all_prots("item")) do
        if item.plant_result ~= nil then
            kept[item.plant_result] = true
        end
    end
    for _, tech in pairs(data.raw.technology or {}) do
        if tech.research_trigger ~= nil and tech.research_trigger.type == "mine-entity" then
            for _, entity_name in pairs(tech.research_trigger.entities or {}) do
                kept[entity_name] = true
            end
        end
    end
    return kept
end

-- Whether map generation's placement of the entity can go to another entity, and the entity take another's (kept: wild.kept_in_place())
-- Only ones placed for the neutral force (the default, AutoplaceSpecification.force): the player's are ours (see entity-own in lib/logic/concrete.lua), and enemies (like spawners and worms) wait for spawn slots
wild.movable = function(entity, kept)
    if entity == nil or entity.hidden or entity.autoplace == nil then
        return false
    end
    return kept[entity.name] == nil and (entity.autoplace.force or "neutral") == "neutral"
end

return wild

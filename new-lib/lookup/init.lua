-- Lookup tables for commonly used correspondences
-- Lookups can depend on other lookups, so they're defined in stages
--   1. (raw)      We gather raw prototypes (all recipes, all items, all entities), ignoring any that are irrelevant (e.g.- hidden non-smelting recipes)
--   2. (simple)   We create "simple" mappings between them (tiles to fluids they produce, entities to items that build them, etc.)
--                 These are split up into different files since there are a lot, but the order here shouldn't matter
--   3. (compound) We create mappings that potentially rely on the simpler mappings
--   4. (weight)   We calculate item weights, which rely on compound lookups and are sufficiently complex to get their own file
--   
-- TODO: Some lookups done check that everything they put into the lookup table is from the raw prototypes in stage 1, so maybe add those checks

-- Load stage modules
local stage_names = {}
-- Insert stage 1
table.insert(stage_names, "1-raw")
-- Insert stage 2
local second_stage_names = {
    "combat",
    "entity-create",
    "entity-property",
    "equipment",
    "fuel",
    "item",
    "mining",
    "recipe",
    "room",
    "science",
    "tile",
}
for _, name in pairs(second_stage_names) do
    table.insert(stage_names, "2-simple/" .. name)
end
-- Insert stage 3
table.insert(stage_names, "3-compound")
-- Insert stage 4
table.insert(stage_names, "4-weight")
-- Get stages from stage names
local stages = {}
for _, name in pairs(stage_names) do
    table.insert(stages, require("new-lib/lookup/" .. name))
end

local lu = {}

lu.load_lookups = function()
    for stage_num = 1, #stages do
        stages[stage_num].link(lu)

        for lookup_name, lookup in pairs(stages[stage_num]) do
            -- "link" is the only special lookup stage name now; all others are loaders
            if lookup_name ~= "link" then
                lookup()
            end
        end
    end
end

return lu
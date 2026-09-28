-- Lookup tables for commonly used correspondences
-- Lookups can depend on other lookups, so they're defined in stages
--   1. (raw)      We gather raw prototypes (all recipes, all items, all entities), ignoring any that are irrelevant (e.g.- hidden non-smelting recipes)
--   2. (simple)   We create "simple" mappings between them (tiles to fluids they produce, entities to items that build them, etc.)
--                 These are split up into different files since there are a lot, but the order here shouldn't matter
--   3. (compound) We create mappings that potentially rely on the simpler mappings
--   4. (weight)   We calculate item weights, which rely on compound lookups and are sufficiently complex to get their own file
--   
-- TODO: Some lookups done check that everything they put into the lookup table is from the raw prototypes in stage 1, so maybe add those checks

-- Load stages in dependency order.
local stages = {
    require("lib/lookup/1-raw"),
    require("lib/lookup/2-simple/combat"),
    require("lib/lookup/2-simple/entity-create"),
    require("lib/lookup/2-simple/entity-property"),
    require("lib/lookup/2-simple/equipment"),
    require("lib/lookup/2-simple/fluid"),
    require("lib/lookup/2-simple/fuel"),
    require("lib/lookup/2-simple/item"),
    require("lib/lookup/2-simple/mining"),
    require("lib/lookup/2-simple/recipe"),
    require("lib/lookup/2-simple/room"),
    require("lib/lookup/2-simple/science"),
    require("lib/lookup/2-simple/tile"),
    require("lib/lookup/3-compound"),
    require("lib/lookup/4-weight"),
}

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
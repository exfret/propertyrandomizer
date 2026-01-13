-- No overlapping ingredients for smelting categories
-- Smelting categories don't involve fuel
-- Account for limited fluidboxes
-- CRITICAL TODO: Later, also account for costs maybe

local recipe_category = {}

-- TODO: In the future, maybe consider machines with multiple categories
-- For now, let's just check each vanilla category doesn't get multiple of the same single ingredient
local smelting_cat_to_ings = {}

recipe_category.id = "recipe_category"

recipe_category.claim = function(graph, prereq, dep, trav)
    -- Any category --> recipe we shouldn't claim? Probably fixed recipes. Need to make a list/lookup for those.

    
end

recipe_category.validate = function(graph, slot, trav, extra)
    -- TODO NEXT: Get recipe category of trav, then check if it's in smelting_cat_to_ings for that category
    -- Then do other checks (smelting fuel and limited fluidboxes)
end

recipe_category.reflect = function(graph, trav_to_new_slot, trav_to_old_slot)
end

return recipe_category
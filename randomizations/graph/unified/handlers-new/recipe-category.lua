-- No overlapping ingredients for smelting categories
-- Account for limited fluidboxes
-- CRITICAL TODO: Later, also account for costs maybe
-- This is currently very sensitive for some reason

-- Furnaces don't get many recipes; I tried fixing but was unsuccessful
-- TODO: Maybe weird context things are happening based on when something is available on another planet...

local gutils = require("new-lib/graph/graph-utils")
local lutils = require("new-lib/logic/logic-utils")
local lu = require("new-lib/lookup/init")

local recipe_category = {}

-- TODO: In the future, maybe consider machines with multiple categories
-- For now, let's just check each vanilla category doesn't get multiple of the same single ingredient
local smelting_cat_to_ings = {}

recipe_category.id = "recipe_category"

-- Keep track of whether we've claimed a category so we only give it a bonus the first time
local claimed_category = {}
local normal_claims = 3
local bonus_claims_first_time = 20
recipe_category.claim = function(graph, prereq, dep, edge)
    -- Just don't claim fixed recipes, or hidden recipes

    if prereq.type == "recipe-category" and dep.type == "recipe" then
        -- If this is a spoof, add it always
        if dep.spoof then
            return normal_claims
        elseif not (lu.fixed_recipes[dep.name] ~= nil and next(lu.fixed_recipes[dep.name]) ~= nil) then
            local recipe_prot = lu.recipes[dep.name]
            if not recipe_prot.hidden then
                if claimed_category[prereq.name] then
                    -- I didn't like 3 claims each time, but it was failing a lot before then for some reason
                    return normal_claims
                else
                    claimed_category[prereq.name] = true
                    return normal_claims + bonus_claims_first_time
                end
            end
        end
    end
end

recipe_category.validate = function(graph, base, head, extra)
    local base_owner = gutils.get_owner(graph, base)

    -- We already know via virtue of being in this handler that head is a recipe node
    if base_owner.type == "recipe-category" then
        local head_owner = gutils.get_owner(graph, head)
        -- If this is a spoof, always accept
        if head_owner.spoof then
            return true
        end

        local base_rcat = lu.rcats[base_owner.name]
        local vanilla_rcat = base_rcat.cat
        local recipe_prot = lu.recipes[head_owner.name]

        -- First, if it's a smelting rcat, make sure the recipe has exactly one ingredient and output
        -- This is technically incorrect, but I don't keep track of input/output bases of furnaces in logic now, so I'll leave that as a later problem
        -- TODO: Fix this problem later
        if lu.smelting_rcats[base_owner.name] then
            if recipe_prot.ingredients == nil or #recipe_prot.ingredients ~= 1 or recipe_prot.results == nil or #recipe_prot.results ~= 1 then
                return false
            end

            -- Also check that this one ingredient isn't used in another recipe for this category
            local unique_ing = recipe_prot.ingredients[1]
            if smelting_cat_to_ings[vanilla_rcat] ~= nil and smelting_cat_to_ings[vanilla_rcat][gutils.key(unique_ing)] then
                return false
            end
        end

        -- Check if there are the appropriate fluid connections
        -- We don't need to check equality exactly because we have a lot of duplicates
        local recipe_fluids = lutils.find_recipe_fluids(recipe_prot)
        if recipe_fluids.input > base_rcat.input or recipe_fluids.output > base_rcat.output then
            return false
        end

        -- And I think that's all the check we'll do for now
        return true
    else
        return false
    end
end

recipe_category.process = function(graph, base, head)
    local head_owner = gutils.get_owner(graph, head)
    -- If this is a spoof, do nothing
    if head_owner.spoof then
        return
    end

    local base_owner = gutils.get_owner(graph, base)

    if lu.smelting_rcats[base_owner.name] then
        local vanilla_rcat = lu.rcats[base_owner.name].cat
        local recipe_prot = lu.recipes[head_owner.name]
        local unique_ing = recipe_prot.ingredients[1]
        smelting_cat_to_ings[base_owner.name] = smelting_cat_to_ings[base_owner.name] or {}
        smelting_cat_to_ings[base_owner.name][gutils.key(unique_ing)] = true
    end
end

recipe_category.reflect = function(graph, head_to_base, head_to_handler)
    for head_key, base_key in pairs(head_to_base) do
        if head_to_handler[head_key].id == "recipe_category" then
            local head = graph.nodes[head_key]
            local recipe_node = gutils.get_owner(graph, head)
            -- Check for spoof nodes
            if not recipe_node.spoof then
                local base = graph.nodes[base_key]
                local cat_node = gutils.get_owner(graph, base)
                local rcat = lu.rcats[cat_node.name]
                local recipe_prot = lu.recipes[recipe_node.name]
                recipe_prot.category = rcat.cat
            end
        end
    end
end

return recipe_category
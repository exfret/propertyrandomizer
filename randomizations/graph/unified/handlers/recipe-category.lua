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

-- This strategy didn't work
-- This is maybe not the best way to do this, but let's flood the graph with fake furnace recipes so that furnaces get more recipes
-- Due to their tight restrictions, they were previously underfavored
--[[local num_spoofs = 1000
recipe_category.spoof = function(graph)
    for _, node in pairs(graph.nodes) do
        -- TODO: Do a better way to check against recycling recipes here
        if node.type == "recipe-category" and lu.smelting_rcats[node.name] and string.find(node.name, "recycling") == nil then
            for i = 1, num_spoofs do
                local spoof_node = gutils.add_node(graph, "recipe", node.name .. "-spoof-" .. tostring(i))
                spoof_node.op = "AND"
                gutils.add_edge(graph, gutils.key(node), gutils.key(spoof_node))
                -- Also attach to the end of the graph so the spoofs don't just reclaim the smelting cates
                -- TODO: Stop hardcoding promethium science
                gutils.add_edge(graph, gutils.key("item", "promethium-science-pack"), gutils.key(spoof_node))
            end
        end
    end
end]]

-- Keep track of whether we've claimed a category so we only give it a bonus the first time
local claimed_category = {}
local normal_claims = 3
local bonus_claims_first_time = 20
recipe_category.claim = function(graph, prereq, dep, trav)
    -- Just don't claim fixed recipes, or hidden recipes

    if prereq.type == "recipe-category" and dep.type == "recipe" then
        -- If this is a spoof, add it always
        if string.find(dep.name, "spoof") ~= nil then
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

recipe_category.validate = function(graph, slot, trav, extra)
    local slot_owner = gutils.get_conn_owner(graph, slot)

    -- We already know via virtue of being in this handler that trav is a recipe node
    if slot_owner.type == "recipe-category" then
        local trav_owner = gutils.get_conn_owner(graph, trav)
        -- If this is a spoof, always accept
        if string.find(trav_owner.name, "spoof") then
            return true
        end

        local slot_rcat = lu.rcats[slot_owner.name]
        local vanilla_rcat = slot_rcat.cat
        local recipe_prot = lu.recipes[trav_owner.name]

        -- First, if it's a smelting rcat, make sure the recipe has exactly one ingredient and output
        -- This is technically incorrect, but I don't keep track of input/output slots of furnaces in logic now, so I'll leave that as a later problem
        -- TODO: Fix this problem later
        if lu.smelting_rcats[slot_owner.name] then
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
        local recipe_fluids = lutils.find_recipe_fluids(recipe_prot)
        if recipe_fluids.input > slot_rcat.input or recipe_fluids.output > slot_rcat.output then
            return false
        end

        -- And I think that's all the check we'll do for now
        return true
    else
        return false
    end
end

recipe_category.process = function(graph, slot, trav)
    local trav_owner = gutils.get_conn_owner(graph, trav)
    -- If this is a spoof, do nothing
    if string.find(trav_owner.name, "spoof") ~= nil then
        return
    end

    local slot_owner = gutils.get_conn_owner(graph, slot)

    if lu.smelting_rcats[slot_owner.name] then
        local vanilla_rcat = lu.rcats[slot_owner.name].cat
        local recipe_prot = lu.recipes[trav_owner.name]
        local unique_ing = recipe_prot.ingredients[1]
        smelting_cat_to_ings[slot_owner.name] = smelting_cat_to_ings[slot_owner.name] or {}
        smelting_cat_to_ings[slot_owner.name][gutils.key(unique_ing)] = true
    end
end

recipe_category.reflect = function(graph, trav_to_new_slot, trav_to_handler)
    for trav_key, slot in pairs(trav_to_new_slot) do
        if trav_to_handler[trav_key].id == "recipe_category" then
            local trav = graph.nodes[trav_key]
            local recipe_node = gutils.get_conn_owner(graph, trav)
            -- Check for spoof nodes
            if string.find(recipe_node.name, "spoof") == nil then
                local cat_node = gutils.get_conn_owner(graph, slot)
                local rcat = lu.rcats[cat_node.name]
                local recipe_prot = lu.recipes[recipe_node.name]
                recipe_prot.category = rcat.cat
            end
        end
    end
end

return recipe_category
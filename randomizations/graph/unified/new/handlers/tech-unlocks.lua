-- TODO: Review and fix

local gutils = require("new-lib/graph/graph-utils")
local rng = require("lib/random/rng")

local tech_unlocks = {}

-- Track which recipes were originally starting (no tech unlock)
local original_starting_recipes = {}

-- Preprocess: identify starting recipes
tech_unlocks.preprocess = function()
    for _, recipe in pairs(data.raw.recipe) do
        -- Skip recycling recipes
        if string.match(recipe.name, "%-recycling$") then
            goto continue
        end
        -- Skip parameter recipes (internal)
        if string.match(recipe.name, "^parameter%-") then
            goto continue
        end
        -- Skip if explicitly disabled
        if recipe.enabled == false then
            goto continue
        end
        -- Check if any tech unlocks this recipe
        local is_unlocked_by_tech = false
        for _, tech in pairs(data.raw.technology) do
            if tech.effects then
                for _, effect in pairs(tech.effects) do
                    if effect.type == "unlock-recipe" and effect.recipe == recipe.name then
                        is_unlocked_by_tech = true
                        break
                    end
                end
            end
            if is_unlocked_by_tech then break end
        end
        -- If no tech unlocks it and it's enabled, it's a starting recipe
        if not is_unlocked_by_tech then
            original_starting_recipes[recipe.name] = true
        end
        ::continue::
    end

    local count = 0
    for _ in pairs(original_starting_recipes) do count = count + 1 end
    log("Identified " .. count .. " starting recipes for potential shuffling")
end

-- Graph spoofing: create a spoofed technology that starting recipes connect to
-- This is an AND node with no prereqs = truthy/source
-- The randomizer may move starting recipes to real techs or vice versa
tech_unlocks.spoof = function(graph)
    -- Create spoofed starting technology (AND node with no prereqs = truthy source)
    local spoof_tech_key = gutils.key({type = "technology", name = "spoof-starting"})
    if not graph.nodes[spoof_tech_key] then
        gutils.add_node(graph, "technology", "spoof-starting", {op = "AND"})
        -- Add to sources since it's an AND node with no prereqs
        graph.sources[spoof_tech_key] = true
    end

    -- For each starting recipe, create a recipe-tech-unlock node and connect
    local added_count = 0
    for recipe_name, _ in pairs(original_starting_recipes) do
        -- Check if recipe-tech-unlock node exists (it shouldn't for starting recipes)
        local unlock_key = gutils.key({type = "recipe-tech-unlock", name = recipe_name})
        if not graph.nodes[unlock_key] then
            -- Create the unlock node (OR - needs one tech to unlock it)
            gutils.add_node(graph, "recipe-tech-unlock", recipe_name, {op = "OR"})
        end

        -- Add edge: spoof-starting technology -> recipe-tech-unlock
        local edge = gutils.add_edge(graph, spoof_tech_key, unlock_key)
        if edge then
            added_count = added_count + 1
        end
    end

    log("Spoofed " .. added_count .. " starting recipes with spoof-starting technology")
end

-- Claim edges from technology to recipe-tech-unlock
tech_unlocks.claim = function(graph, prereq, dep, trav)
    if prereq.type == "technology" and dep.type == "recipe-tech-unlock" then
        return 1
    end
end

-- Stub validate - accept any match for now
tech_unlocks.validate = function(graph, slot, trav, extra)
    local slot_owner = gutils.get_conn_owner(graph, slot)
    if slot_owner.type == "technology" then
        return true
    end
end

-- Apply recipe unlock changes to data.raw
tech_unlocks.reflect = function(graph, trav_to_new_slot, trav_to_old_slot)
    -- First, clear all unlock-recipe effects from all technologies
    for _, tech in pairs(data.raw.technology) do
        if tech.effects then
            local new_effects = {}
            for _, effect in pairs(tech.effects) do
                if effect.type ~= "unlock-recipe" then
                    table.insert(new_effects, effect)
                end
            end
            tech.effects = new_effects
        end
    end

    -- Track recipes that end up on spoof-starting (stay unlocked from start)
    local recipes_staying_unlocked = {}
    -- Track recipes that move to real techs (become locked)
    local recipes_becoming_locked = {}

    -- Now add unlock-recipe effects based on new assignments
    for trav_key, slot in pairs(trav_to_new_slot) do
        local trav = graph.nodes[trav_key]
        local trav_owner = gutils.get_conn_owner(graph, trav)
        local slot_owner = gutils.get_conn_owner(graph, slot)

        -- Only process our edge type
        if trav_owner.type == "recipe-tech-unlock" and slot_owner.type == "technology" then
            local recipe_name = trav_owner.name
            local tech_name = slot_owner.name

            -- Handle spoof-starting: recipe stays unlocked from start
            if tech_name == "spoof-starting" then
                recipes_staying_unlocked[recipe_name] = true
                -- Make sure recipe is enabled (no tech needed)
                local recipe = data.raw.recipe[recipe_name]
                if recipe then
                    recipe.enabled = true
                end
            else
                -- Real technology - add unlock effect
                local tech = data.raw.technology[tech_name]
                local recipe = data.raw.recipe[recipe_name]

                if tech and recipe then
                    tech.effects = tech.effects or {}
                    table.insert(tech.effects, {
                        type = "unlock-recipe",
                        recipe = recipe_name,
                    })

                    -- If this was originally a starting recipe, lock it
                    if original_starting_recipes[recipe_name] then
                        recipe.enabled = false
                        recipes_becoming_locked[recipe_name] = true
                    end
                end
            end
        end
    end

    -- Log summary
    local locked_count = 0
    local unlocked_count = 0
    for _ in pairs(recipes_becoming_locked) do locked_count = locked_count + 1 end
    for _ in pairs(recipes_staying_unlocked) do unlocked_count = unlocked_count + 1 end

    if locked_count > 0 then
        log("Locked " .. locked_count .. " formerly-starting recipes behind technologies")
    end
    if unlocked_count > 0 then
        log("Kept " .. unlocked_count .. " recipes unlocked from start (assigned to spoof-starting)")
    end
end

return tech_unlocks

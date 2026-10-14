-- Choose missing prerequisite ingredients without the ordinary shuffle's eligibility or cost policy.
local ingredient_pool = require("src/randomizations/unified/handler-helpers/ingredient-pool")
local gutils = require("src/lib/graph/graph-utils")
local furnace_selection = require("src/prototypes/entities/furnace-selection")
local lu = require("src/prototypes/lookup/init")

local prerequisite_ingredients = {}
local key = gutils.key

local function material_of(owner)
    if owner.type == "fluid-temperature-range" then
        return {
            type = "fluid",
            name = gutils.deconstruct(owner.name).type,
        }
    end
    return owner
end

prerequisite_ingredients.choose = function(params)
    local graph = params.random_graph
    local prom = params.promotion
    local final_categories = {}
    for head_key, base_key in pairs(params.head_to_base or {}) do
        local head = gutils.get_owner(graph, graph.nodes[head_key])
        local base = gutils.get_owner(graph, graph.nodes[base_key])
        if head.type == "recipe" and base.type == "recipe-category" then
            final_categories[head.name] = lu.rcats[base.name].cats
        end
    end
    local furnaces = furnace_selection.tracker(function(recipe)
        return final_categories[recipe.name]
    end)
    local pending = {}
    for _, dep in pairs(params.sorted_deps) do
        local node = graph.nodes[dep]
        if node.type == "recipe" then
            pending[node.name] = true
        end
    end
    for recipe_name, recipe in pairs(data.raw.recipe) do
        for _, ing in pairs(recipe.ingredients or {}) do
            if pending[recipe_name] == true then
                furnaces.reserve(recipe, ing)
            else
                furnaces.take(recipe, ing)
            end
        end
    end

    -- Entries come from the same subdivided edges as ordinary unified selection.
    local candidates = {}
    local seen = {}
    for _, base_key in pairs(params.shuffled_prereqs) do
        if not seen[base_key] then
            seen[base_key] = true
            local base = graph.nodes[base_key]
            local owner = gutils.get_owner(graph, base)
            local material = material_of(owner)
            local entry
            if base.pool_only == true then
                entry = ingredient_pool.ingredient(graph, base, material, data.raw.recipe)
            else
                local old_recipe = gutils.get_owner(graph, graph.nodes[base.old_head])
                if old_recipe.spoof == true then
                    entry = {
                        type = material.type,
                        name = material.name,
                        amount = 1,
                    }
                else
                    for index, _ in pairs(base.inds) do
                        entry = data.raw.recipe[old_recipe.name].ingredients[index]
                        break
                    end
                end
            end
            table.insert(candidates, {
                owner = key(owner),
                material = material,
                entry = assert(entry),
            })
        end
    end

    local overrides = {}
    local changed = 0
    local unfilled = 0
    for _, dep in pairs(params.sorted_deps) do
        local node = graph.nodes[dep]
        if node.type == "recipe" then
            local required = prom.required_contexts(dep)
            local unpaid = prom.recipe_boundary_contexts(dep, required)
            if #unpaid > 0 then
                local recipe = data.raw.recipe[node.name]
                local pins = prom.pins_for(dep)
                local ingredients = table.deepcopy(recipe.ingredients or {})
                local used = {}
                local missing = {}
                local owners = {}
                local pools = furnaces.pools_of(recipe)
                for index, ing in pairs(ingredients) do
                    local owner = prom.vanilla_owner(dep, ing)
                    owners[index] = owner
                    if owner == nil or pins[key(ing)] == true or prom.pays(dep, owner, unpaid) then
                        used[key(ing)] = true
                    else
                        table.insert(missing, index)
                    end
                end
                local recipe_changed = false
                for _, index in pairs(missing) do
                    local old = ingredients[index]
                    local chosen
                    for _, candidate in pairs(candidates) do
                        -- Keep the existing item/fluid slots so the chosen category still serves them.
                        if candidate.material.type == old.type and used[key(candidate.material)] == nil
                            and not furnaces.is_taken(pools, candidate.material, recipe)
                            and prom.candidate_ok(dep, candidate.owner, required)
                            and prom.pays(dep, candidate.owner, unpaid) then
                            chosen = candidate
                            break
                        end
                    end
                    if chosen ~= nil then
                        local ing = table.deepcopy(old)
                        ing.name = chosen.material.name
                        -- Temperature bounds describe the candidate's proven fluid route.
                        if ing.type == "fluid" then
                            ing.minimum_temperature = chosen.entry.minimum_temperature
                            ing.maximum_temperature = chosen.entry.maximum_temperature
                        end
                        ingredients[index] = ing
                        owners[index] = chosen.owner
                        used[key(chosen.material)] = true
                        recipe_changed = true
                        changed = changed + 1
                        log("FIXPASS ingredient: " .. node.name .. " takes " .. key(chosen.material) .. " instead of " .. key(old))
                    else
                        used[key(old)] = true
                        unfilled = unfilled + 1
                        log("FIXPASS ingredient: no available replacement for " .. key(old) .. " in " .. node.name)
                    end
                end
                local owner_keys = {}
                for _, owner in pairs(owners) do
                    table.insert(owner_keys, owner)
                end
                prom.resolve(dep, owner_keys, required)
                if recipe_changed then
                    overrides[node.name] = ingredients
                end
                furnaces.release(recipe)
                for _, ing in pairs(ingredients) do
                    furnaces.take(recipe, ing)
                end
            end
        end
    end
    log("FIXPASS ingredients: " .. changed .. " replacements chosen; " .. unfilled .. " prerequisites have no available replacement")
    return overrides
end

return prerequisite_ingredients

-- Recipe merges in the game (lib/recipe-merges.lua says which recipes merge and how): after each unified attempt, once independent deposits' copies are their materials again, so recycling, the attempt's checks and the tech tree rebuild see the merged game
-- A merged recipe made in more rooms than the recipe it keeps gets exact surface conditions for them on surface properties of its own (surface_sets.MERGE_POOL), apart from the planet locks' (randomizations/planetary/locks.lua)
-- Nothing realizes the locks again after this outside superposed mode, where merges don't run (config.recipe_merges), and a retried attempt starts from the game before it, so merges and their properties go with it
-- Logs a RECIPEMERGES line for each merge, one more for each merge whose amounts were RADICAL_RATIO or more apart (flagged), and a summary

local constants = require("helper-tables/constants")
local flow_cost = require("lib/cost/flow-cost")
local gutils = require("lib/graph/graph-utils")
local locale_utils = require("lib/locale")
local merges = require("lib/recipe-merges")
local surface_sets = require("lib/surface-sets")

local stage = {}

local PREFIX = "RECIPEMERGES "

local function sorted_keys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

local function same_set(a, b)
    for key, _ in pairs(a) do
        if b[key] == nil then
            return false
        end
    end
    for key, _ in pairs(b) do
        if a[key] == nil then
            return false
        end
    end
    return true
end

-- Localised names of recipes named after one planet: scaffolds.variant_name's, and lib/recipe-renames.lua's and lib/dupe-intermediates.lua's, each { key, the recipe's name, the planet's name }
local PLANET_NAME_KEYS = {
    ["propertyrandomizer-name.planet-variant"] = true,
    ["propertyrandomizer.recipe_planet_variant"] = true,
}

-- A localised list of things, "a, b, c", nested so no localised string has more than 20 parameters
local function list_label(labels)
    local parts = {}
    for i, label in pairs(labels) do
        if i > 1 then
            table.insert(parts, ", ")
        end
        table.insert(parts, label)
    end
    local function nest(first, last)
        local nested = {
            "",
        }
        if last - first < 20 then
            for i = first, last do
                table.insert(nested, parts[i])
            end
        else
            local middle = math.floor((first + last) / 2)
            table.insert(nested, nest(first, middle))
            table.insert(nested, nest(middle + 1, last))
        end
        return nested
    end
    return nest(1, #parts)
end

-- The localised name a kept recipe named after one planet gets once it's made on several: its name with every one of those planets', or nil when it keeps its name
local function new_label(recipe, rooms)
    local name = recipe.localised_name
    if recipe.intermediate_planet == nil or type(name) ~= "table" or PLANET_NAME_KEYS[name[1]] == nil or #name ~= 3 then
        return nil
    end
    local planet_labels = {}
    for _, room_key in pairs(sorted_keys(rooms)) do
        local room = gutils.deconstruct(room_key)
        local planet = room.type == "planet" and (data.raw.planet or {})[room.name] or nil
        if planet ~= nil then
            table.insert(planet_labels, locale_utils.find_localised_name(planet))
        end
    end
    if #planet_labels < 2 then
        return nil
    end
    return {
        name[1],
        name[2],
        list_label(planet_labels),
    }
end

-- A recipe's ingredients for the log, like "1 pipe-to-ground, 20 sulfuric-acid (fluid)"
local function ingredients_text(recipe)
    local texts = {}
    for _, ingredient in pairs(recipe.ingredients or {}) do
        table.insert(texts, tostring(ingredient.amount) .. " " .. ingredient.name .. (ingredient.type == "fluid" and " (fluid)" or ""))
    end
    table.sort(texts)
    return table.concat(texts, ", ")
end

local function rooms_text(rooms)
    local names = {}
    for _, room_key in pairs(sorted_keys(rooms)) do
        table.insert(names, gutils.deconstruct(room_key).name)
    end
    return table.concat(names, ", ")
end

-- Merges data.raw's recipes (see the top of this file)
-- Returns how many recipes were taken into others
stage.execute = function()
    -- Material costs on the game as it is, found at most once and only when a merge needs prices to tell the cheapest amounts apart (merges.cheapest)
    local material_to_cost
    local function price_of(ingredient)
        if material_to_cost == nil then
            local maps = flow_cost.construct_item_recipe_maps()
            local raw_costs = flow_cost.present_raw_costs(flow_cost.get_default_raw_resource_table(), maps)
            material_to_cost = flow_cost.determine_recipe_item_cost(raw_costs, constants.cost_params.time, constants.cost_params.complexity, {
                item_recipe_maps = maps,
            }).material_to_cost
        end
        return material_to_cost[flow_cost.get_prot_id(ingredient)]
    end
    local plan = merges.plan(data.raw.recipe, {
        rooms_of = surface_sets.accepted,
        price_of = price_of,
    })
    if #plan == 0 then
        log(PREFIX .. "no recipe has a version taking and making the same things")
        return 0
    end

    -- New conditions for the kept recipes made in more rooms now, all planned together, and new names for those named after one planet
    local requests = {}
    local label_of = {}
    for _, merge in pairs(plan) do
        local keeper = data.raw.recipe[merge.keeper]
        if not same_set(surface_sets.accepted(keeper), merge.rooms) then
            table.insert(requests, {
                id = merge.keeper,
                rooms = merge.rooms,
            })
        end
        label_of[merge.keeper] = new_label(keeper, merge.rooms)
    end
    local conditions_of = {}
    local num_properties = 0
    if #requests > 0 then
        local pool = table.deepcopy(surface_sets.MERGE_POOL)
        local properties = surface_sets.plan_growing(requests, surface_sets.room_keys(), pool)
        surface_sets.apply_properties(properties, pool)
        num_properties = #properties.properties
        for _, request in pairs(requests) do
            conditions_of[request.id] = properties.conditions[request.id]
        end
    end

    -- Logged before the merges change the recipes
    local num_absorbed = 0
    local num_flagged = 0
    for _, merge in pairs(plan) do
        num_absorbed = num_absorbed + #merge.absorbed
        local keeper = data.raw.recipe[merge.keeper]
        local grown = conditions_of[merge.keeper] ~= nil and ("; now made on " .. rooms_text(merge.rooms)) or ""
        log(PREFIX .. merge.keeper .. " takes in " .. table.concat(merge.absorbed, ", ") .. " (" .. ingredients_text(keeper) .. "; machines " .. table.concat(merge.categories, ", ") .. grown .. ")")
        if merge.is_flagged then
            num_flagged = num_flagged + 1
            local amounts = {}
            for _, name in pairs(merge.members) do
                table.insert(amounts, name .. ": " .. ingredients_text(data.raw.recipe[name]))
            end
            local ratio = merge.ratio == math.huge and "infinitely" or (string.format("%.3g", merge.ratio) .. "x")
            log(PREFIX .. "flagged " .. merge.keeper .. ": amounts " .. ratio .. " apart (" .. table.concat(amounts, "; ") .. "), so it takes the cheapest, " .. merge.amounts_from .. "'s (" .. merge.told_apart_by .. ")")
        end
    end

    merges.apply(data.raw, plan, conditions_of, label_of)
    log(PREFIX .. num_absorbed .. " recipes merged into " .. #plan .. " others, " .. num_flagged .. " of those merges flagged for amounts " .. merges.RADICAL_RATIO .. "x apart or more; " .. #requests .. " merged recipes made in more rooms than before, on " .. num_properties .. " new surface properties")
    return num_absorbed
end

return stage

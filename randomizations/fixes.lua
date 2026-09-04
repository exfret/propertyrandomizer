-- File for any last-minute fixes in the randomization process that may be needed

local locale_utils = require("lib/locale")
local dutils = require("lib/data-utils")
local gutils = require("lib/graph/graph-utils")
local logic = require("lib/logic/init")
local top = require("lib/graph/consistent-sort")
-- Needed for recipe icons logic
local dupe = require("lib/dupe")
local cutils = require("lib/cost/cost-utils")

randomizations.rebuild_tech_tree = function()
    -- Special py fixes
    if mods["pyalternativeenergy"] then
        -- Force icons of recipes to be their sole result
        --[[for _, recipe in pairs(data.raw.recipe) do
            if recipe.results ~= nil and #recipe.results == 1 then
                local item_or_fluid
                if recipe.results[1].type == "item" then
                for item_class, _ in pairs(defines.prototypes.item) do
                    if (data.raw[item_class] or {})[recipe.results[1].name] ~= nil then
                        item_or_fluid = data.raw[item_class][recipe.results[1].name]
                    end
                end
                elseif recipe.results[1].type == "fluid" then
                    item_or_fluid = data.raw.fluid[recipe.results[1].name]
                end

                recipe.icon = item_or_fluid.icon
                recipe.icons = item_or_fluid.icons
                recipe.icon_size = item_or_fluid.icon_size
            end
        end]]
    end

    -- Find science packs (used for determine "essential" techs)
    local is_science_pack = {}
    for _, lab in pairs(data.raw.lab) do
        for _, input in pairs(lab.inputs) do
            is_science_pack[input] = true
        end
    end

    -- Average tech costs across recipes in a technology
    -- Nvm, a recipe can just take the whole unit from its first found tech
    --[[local recipe_to_tech_cost = {}
    for _, recipe in pairs(data.raw.recipe) do
        recipe_to_tech_cost[recipe.name] = 0
    end
    for _, tech in pairs(data.raw.technology) do
        if tech.unit ~= nil and tech.unit.count_formula == nil then
            -- First pass finds number of recipe unlocks, second adds cost to them
            local num_recipe_unlocks = 0
            for _, effect in pairs(tech.effects or {}) do
                if effect.type == "unlock-recipe" then
                    num_recipe_unlocks = 1 + num_recipe_unlocks
                end
            end
            if num_recipe_unlocks > 0 then
                -- TODO: Support py's different ing amounts per pack
                local cost_for_each = tech.unit.count / num_recipe_unlocks
                for _, effect in pairs(tech.effects or {}) do
                    if effect.type == "unlock-recipe" then
                        recipe_to_tech_cost[effect.recipe] = cost_for_each + recipe_to_tech_cost[effect.recipe]
                    end
                end
            end
        end
    end]]

    logic.build(true)
    local graph = logic.graph

    -- Note that the below can fail if the tech associated via recipe_to_unit is different from the one found in top.path
    -- It might be useful to check this actually happens in the future

    -- Initial top sort for determining science packs for recipes
    -- Also determines recipes for science packs (i.e.- what recipe techs will be marked essential)
    local recipe_to_unit = {}
    local recipe_to_research_trigger = {}
    local with_tech_sort_info = top.sort(graph)
    local science_pack_marked = {}
    local is_essential_recipe = {}
    for _, node_info in pairs(with_tech_sort_info.sorted) do
        local node = graph.nodes[node_info.node_key]
        if node.type == "technology" then
            local tech = data.raw.technology[node.name]
            -- CRITICAL TODO: Ignore techs right now with levels; we'll need to nuke them completely later
            --local isdigit = {["0"] = true, ["1"] = true, ["2"] = true, ["3"] = true, ["4"] = true, ["5"] = true, ["6"] = true, ["7"] = true, ["8"] = true, ["9"] = true}
            if tech.unit ~= nil and tech.unit.count ~= nil then
                local num_recipe_unlocks = 0
                for _, effect in pairs(tech.effects or {}) do
                    if effect.type == "unlock-recipe" then
                        num_recipe_unlocks = 1 + num_recipe_unlocks
                    end
                end
                for _, effect in pairs(tech.effects or {}) do
                    if effect.type == "unlock-recipe" then
                        if recipe_to_unit[effect.recipe] == nil and recipe_to_research_trigger[effect.recipe] == nil then
                            recipe_to_unit[effect.recipe] = table.deepcopy(tech.unit)
                            recipe_to_unit[effect.recipe].count = math.ceil(1 / num_recipe_unlocks * recipe_to_unit[effect.recipe].count)
                        end
                    end
                end
            elseif tech.research_trigger ~= nil then
                for _, effect in pairs(tech.effects or {}) do
                    if effect.type == "unlock-recipe" then
                        if recipe_to_unit[effect.recipe] == nil and recipe_to_research_trigger[effect.recipe] == nil then
                            recipe_to_research_trigger[effect.recipe] = table.deepcopy(tech.research_trigger)
                        end
                    end
                end
            end
        end
        if node.type == "recipe" then
            local recipe = data.raw.recipe[node.name]
            for _, result in pairs(recipe.results or {}) do
                if result.type == "item" and is_science_pack[result.name] and not science_pack_marked[result.name] then
                    is_essential_recipe[recipe.name] = true
                    science_pack_marked[result.name] = true
                end
            end
        end
    end

    -- Remove all tech prereqs so that they are reachable, do a top sort, then use short path
    -- Since we're preserving tech research packs/triggers anyways, just keep those on
    for _, node in pairs(graph.nodes) do
        if node.type == "technology" then
            local pres_to_remove = {}
            for pre, _ in pairs(node.pre) do
                local prenode = graph.nodes[graph.edges[pre].start]
                if prenode.type == "technology" then
                    pres_to_remove[pre] = true
                end
            end
            for pre, _ in pairs(pres_to_remove) do
                gutils.remove_edge(graph, pre)
            end
        end
    end
    local no_tech_sort_info = top.sort(graph)

    local recipe_to_prev = {}
    for ind, node_info in pairs(no_tech_sort_info.sorted) do
        local node = graph.nodes[node_info.node_key]
        if node.type == "recipe" and recipe_to_prev[node.name] == nil then
            local path_info = top.path(graph, {ind}, no_tech_sort_info, {
                stop_if = function(pebble)
                    local node = graph.nodes[pebble.node_key]
                    if node.type == "recipe" then
                        return true
                    end
                end
            })
            recipe_to_prev[node.name] = {}
            for other_node_ind, _ in pairs(path_info.in_path) do
                -- Don't count ind itself
                if other_node_ind < ind then
                    local other_node_key = no_tech_sort_info.sorted[other_node_ind].node_key
                    local other_node = graph.nodes[other_node_key]
                    if other_node.type == "recipe" then
                        recipe_to_prev[node.name][other_node.name] = true
                    end
                end
            end
        end
    end

    for _, tech in pairs(data.raw.technology) do
        local new_effects = {}
        for _, effect in pairs(tech.effects or {}) do
            if effect.type ~= "unlock-recipe" then
                table.insert(new_effects, effect)
            end
        end
        if (#new_effects == 0 or tech.name == "cliff-explosives" or tech.name == "construction-robotics" or tech.name == "logistic-robotics" or tech.name == "logistic-system" or tech.name == "bulk-inserter") and tech.name ~= "pyrrhic" then
            tech.hidden = true
            tech.hidden_in_factoriopedia = true
        end
        tech.effects = new_effects
        tech.prerequisites = {}
        -- TODO: Figure out how to assign new prereqs (future issue)

        -- TODO: Delete techs from potentially rebuilding it earlier?
    end

    local new_techs_with_unit = {}
    local is_new_tech = {}
    for recipe_name, prev_recipes in pairs(recipe_to_prev) do
        local recipe = data.raw.recipe[recipe_name]

        if recipe.enabled == false then
            local prereqs = {}
            for prev_recipe_name, _ in pairs(prev_recipes) do
                local prev_recipe = data.raw.recipe[prev_recipe_name]
                -- Check that this will get a tech
                if prev_recipe.enabled == false and (recipe_to_unit[prev_recipe_name] ~= nil or recipe_to_research_trigger[prev_recipe_name] ~= nil) then
                    table.insert(prereqs, "exfret-rebuilt-" .. prev_recipe_name .. "-suffix")
                end
            end

            if recipe_to_unit[recipe_name] then
                table.insert(new_techs_with_unit, "exfret-rebuilt-" .. recipe_name .. "-suffix")
            end
            is_new_tech["exfret-rebuilt-" .. recipe_name .. "-suffix"] = true
            local new_tech = {
                type = "technology",
                name = "exfret-rebuilt-" .. recipe_name .. "-suffix",
                localised_name = locale_utils.find_localised_name(data.raw.recipe[recipe_name]),
                icons = table.deepcopy(dupe.get_recipe_icons(recipe)),
                prerequisites = prereqs,
                essential = is_essential_recipe[recipe_name],
                effects = {
                    {
                        type = "unlock-recipe",
                        recipe = recipe_name
                    },
                },
            }
            if recipe_to_unit[recipe_name] ~= nil then
                new_tech.unit = recipe_to_unit[recipe_name]
            elseif recipe_to_research_trigger[recipe_name] ~= nil then
                new_tech.research_trigger = recipe_to_research_trigger[recipe_name]
            else
                -- This should only happen if the recipe is gotten first through a tech with count formula, which is kind of dumb, but let's just enable the recipe then
                recipe.enabled = true
            end

            -- Check if we just enabled recipe (see above), and if so we no longer need the tech
            -- (Or if it was enabled from the start)
            if recipe.enabled == false then
                data:extend({
                    new_tech
                })
            end
        end
    end

    -- Add prereqs back to non-unlock recipes
    for _, tech in pairs(data.raw.technology) do
        if not is_new_tech[tech.name] and tech.name ~= "pyrrhic" then
            local prereq = data.raw.technology[new_techs_with_unit[math.random(1, #new_techs_with_unit)]]
            tech.prerequisites = { prereq.name }
            if tech.unit ~= nil then
                tech.unit.ingredients = prereq.unit.ingredients
            end
        end
    end

    if mods["pyalternativeenergy"] then
        -- Make pyrrhic come after each later thing with some probability
        local has_dependent = {}
        for _, tech in pairs(data.raw.technology) do
            for _, prereq in pairs(tech.prerequisites or {}) do
                has_dependent[prereq] = true
            end
        end
        data.raw.technology.pyrrhic.prerequisites = {}
        for _, tech in pairs(data.raw.technology) do
            if not has_dependent[tech.name] and is_new_tech[tech.name] then
                if math.random() < 0.01 then
                    table.insert(data.raw.technology.pyrrhic.prerequisites, tech.name)
                end
            end
        end
    end
end

randomizations.fix_recycling_recipes = function()
    ----------------------------------------------------------------------
    -- Fix recycling recipes
    ----------------------------------------------------------------------

    -- First, some constants
    local recycling_category_name = "recycling"
    local type_item = "item"

    -- Create lookup table for recycling recipes
    local item_to_recycling_recipe = {}
    for _, recipe in pairs(data.raw.recipe) do
        local has_recycling = false
        for _, category in pairs(recipe.categories or {"crafting"}) do
            if category == recycling_category_name then
                has_recycling = true
            end
        end
        if has_recycling and recipe.ingredients ~= nil and #recipe.ingredients == 1 then
            item_to_recycling_recipe[recipe.ingredients[1].name] = recipe
        end
    end

    -- A little helper function
    --[[local amount_expected_value = function (product_or_ingredient)
        local expected_value = product_or_ingredient.amount
        if product_or_ingredient.amount == nil then
            local amount_max = product_or_ingredient.amount_max
            if product_or_ingredient.amount_max < product_or_ingredient.amount_min then
                amount_max = product_or_ingredient.amount_min
            end
            expected_value = (product_or_ingredient.amount_min + amount_max) / 2
        end
        if product_or_ingredient.extra_count_fraction ~= nil then
            expected_value = expected_value + product_or_ingredient.extra_count_fraction
        end
        if product_or_ingredient.ignored_by_stats ~= nil then
            expected_value = expected_value - product_or_ingredient.ignored_by_stats
        end
        -- CRITICAL TODO: Implement shared probabilities too...
        if product_or_ingredient.independent_probability ~= nil then
            expected_value = expected_value * product_or_ingredient.independent_probability
        end
        return expected_value
    end]]

    -- Define some lists to define what recipes recyclers can reverse
    local reversible_category_blacklist = {
        ["recycling"] = true,
        ["smelting"] = true,
        ["chemistry-or-cryogenics"] = true,
        ["crushing"] = true,
        ["metallurgy"] = true,
        ["organic"] = true,
        ["cryogenics"] = true,
    }
    local reversible_subgroup_blacklist = {
        ["empty-barrel"] = true,
    }
    local reversible_name_blacklist = {
        ["tungsten-carbide"] = true,
        ["superconductor"] = true,
        ["biolab"] = true,
    }
    local reversible_name_keyword_blacklist = {
        "science", "pack"
    }
    local reversible_name_exceptions = {
        ["battery"] = true,
        ["big-mining-drill"] = true,
        ["turbo-transport-belt"] = true,
        ["turbo-underground-belt"] = true,
        ["turbo-splitter"] = true,
        ["railgun-turret"] = true,
        ["railgun"] = true,
        ["cryogenic-plant"] = true,
        ["fusion-reactor"] = true,
        ["fusion-generator"] = true,
    }

    local default_can_recycle = function(recipe)
        if reversible_name_exceptions[recipe.name] then return true end
        if recipe.auto_recycle == false then return false end

        local in_category_blacklist = false
        for _, category in pairs(recipe.categories or {"crafting"}) do
            if reversible_category_blacklist[category] then
                in_category_blacklist = true
            end
        end

        if in_category_blacklist then return false end
        if reversible_subgroup_blacklist[recipe.subgroup] then return false end
        if reversible_name_blacklist[recipe.name] then return false end
        local match = true
        for _, keyword in pairs(reversible_name_keyword_blacklist) do
            if not string.find(recipe.name, keyword) then
                match = false
            end
        end
        if match then return false end
        return true
    end

    -- Go through all recipes looking for reversible ones to modify recycling recipes based on
    local reversed_items = {}
    for _, recipe in pairs(data.raw.recipe) do
        -- Use rules defined by quality mod to decide if a recipe is worth considering, also exclude recipes without results or ingredients
        if default_can_recycle(recipe) and recipe.results ~= nil and recipe.ingredients ~= nil then
            local elegible_recipe = true
            -- Check the recipe products to see if it's elegible for reversing into a recycling recipe
            local elegible_results = {}
            for _, product in pairs(recipe.results) do
                if product.type == type_item and cutils.find_amount_in_entry(product) > 0 then
                    elegible_results[#elegible_results+1] = product
                end
                -- Recycling recipes don't take fluids as ingredients
                if product.type ~= type_item and cutils.find_amount_in_entry(product) > 0 then
                    elegible_recipe = false
                end
            end
            local elegible_ingredients = {}
            -- Check the ingredients to see if any can be the product of recycling
            for _, ingredient in pairs(recipe.ingredients) do
                -- Fluid ingredients don't affect anything, so ignore
                if ingredient.type == type_item
                and (ingredient.ignored_by_stats == nil or ingredient.ignored_by_stats < ingredient.amount) then
                    elegible_ingredients[#elegible_ingredients+1] = ingredient
                end
            end
            -- Recycling recipes always have 1 ingredient and at least one product
            if #elegible_results ~= 1 or #elegible_ingredients < 1 then
                elegible_recipe = false
            end
            if elegible_recipe then
                local product = elegible_results[1]
                -- Find the corresponding recycling recipe that has this product as ingredient
                local recycling_recipe = item_to_recycling_recipe[product.name]
                if recycling_recipe ~= nil then
                    -- Find out how many products to account for
                    -- Adjust in case of increased maximum_productivity
                    local max_productivity_factor = 4
                    if recipe.maximum_productivity ~= nil then
                        max_productivity_factor = 1 + recipe.maximum_productivity
                    end
                    local max_products = cutils.find_amount_in_entry(product) * max_productivity_factor
                    local recycling_yield_factor = 1 / max_products
                    -- Create new set of recycling results
                    local new_recycling_results = {}
                    for _, ingredient in pairs(elegible_ingredients) do
                        local recycle_product_yield = cutils.find_amount_in_entry(ingredient) * recycling_yield_factor
                        local consistent_amount = math.floor(recycle_product_yield)
                        local extra_count_fraction = recycle_product_yield - consistent_amount
                        -- I added this checking for stackability, but then realized it's only really needed if there was an oopsie in the ingredients
                        -- So, it can probably get taken down at a later date
                        local ing_as_item
                        for item_class, _ in pairs(defines.prototypes.item) do
                            if data.raw[item_class] ~= nil then
                                if data.raw[item_class][ingredient.name] ~= nil then
                                    ing_as_item = data.raw[item_class][ingredient.name]
                                    break
                                end
                            end
                        end
                        local not_stackable = false
                        if ing_as_item.flags ~= nil then
                            for _, flag in pairs(ing_as_item.flags) do
                                if flag == "not-stackable" then
                                    not_stackable = true
                                    break
                                end
                            end
                        end
                        if ing_as_item.type == "armor" and ing_as_item.equipment_grid ~= nil then
                            not_stackable = true
                        end
                        local new_recycling_result = {
                            type = type_item,
                            name = ingredient.name,
                        }
                        if consistent_amount > 0 and not_stackable then
                            consistent_amount = 1
                        end
                        if not_stackable then
                            extra_count_fraction = 0
                        end
                        -- Define probability instead of extra_count_fraction if amount is low. Looks nicer in-game
                        if consistent_amount < 1 then
                            new_recycling_result.amount = 1
                            new_recycling_result.independent_probability = extra_count_fraction
                        else
                            new_recycling_result.amount = consistent_amount
                            new_recycling_result.extra_count_fraction = extra_count_fraction
                        end
                        new_recycling_results[#new_recycling_results+1] = new_recycling_result
                    end
                    recycling_recipe.results = new_recycling_results
                    -- Also remove main product, because that sometimes needs to be fixed for some reason
                    recycling_recipe.main_product = nil
                    -- Remove number from recycling recipe name (removed in 2.1)
                    --recycling_recipe.show_amount_in_title = false
                    -- Keep track of what items we have fixed the recycling recipes for
                    reversed_items[product.name] = true
                end
            end
        end
    end

    -- Go through all items to look for items that weren't reversible
    for class_name, _ in pairs(defines.prototypes.item) do
        if data.raw[class_name] ~= nil then
            for _, item in pairs(data.raw[class_name]) do
                if reversed_items[item.name] == nil then
                    local recycling_recipe = item_to_recycling_recipe[item.name]
                    if recycling_recipe ~= nil and default_can_recycle(recycling_recipe) then
                        -- Create new set of recycling results only containing 25% chance of getting the sole ingredient back
                        recycling_recipe.results = {
                            {
                                type = type_item,
                                name = item.name,
                                amount = 1,
                                independent_probability = 1 / 4,
                                ignored_by_stats = 1,
                            },
                        }
                        -- Also remove main product, because that sometimes needs to be fixed for some reason
                        recycling_recipe.main_product = nil
                    end
                end
            end
        end
    end
end

randomizations.fixes = function()
    -- Fix electric pole supply area to be at least as large as distribution range
    --[[ only a RATIONAL INDIVIDUAL would resort to such PRACTICAL CONVENIENCE in the face of ANGUISH AND TURMOIL
    for _, electric_pole in pairs(data.raw["electric-pole"]) do
        if electric_pole.maximum_wire_distance == nil then
            electric_pole.maximum_wire_distance = 0
        end

        electric_pole.maximum_wire_distance = math.min(64, math.max(electric_pole.maximum_wire_distance, 2 * electric_pole.supply_area_distance))
    end
    ]]

    -- Add the placeable entity/etc.'s localised description to every item so stats show up all at once
    for item_class, _ in pairs(defines.prototypes.item) do
        if data.raw[item_class] ~= nil then
            for _, item in pairs(data.raw[item_class]) do
                if item.localised_description ~= nil then
                    if item.place_result ~= nil then
                        -- Get the entity
                        local entity
                        for entity_class, _ in pairs(defines.prototypes.entity) do
                            if data.raw[entity_class] ~= nil then
                                if data.raw[entity_class][item.place_result] ~= nil then
                                    entity = data.raw[entity_class][item.place_result]
                                end
                            end
                        end
                        local desc = locale_utils.find_localised_description(entity, {with_newline = true})
                        item.localised_description = {"", desc, item.localised_description}
                    end
                    if item.place_as_equipment_result ~= nil then
                        -- Get the equipment
                        local equipment
                        for equipment_class, _ in pairs(defines.prototypes.equipment) do
                            if data.raw[equipment_class] ~= nil then
                                if data.raw[equipment_class][item.place_as_equipment_result] ~= nil then
                                    equipment = data.raw[equipment_class][item.place_as_equipment_result]
                                end
                            end
                        end
                        local desc = locale_utils.find_localised_description(equipment, {with_newline = true})
                        item.localised_description = {"", desc, item.localised_description}
                    end
                    if item.place_as_tile ~= nil then
                        local tile = data.raw.tile[item.place_as_tile.result]
                        local desc = locale_utils.find_localised_description(tile, {with_newline = true})
                        item.localised_description = {"", desc, item.localised_description}
                    end
                end
            end
        end
    end

    -- Remove duplicate ingredients (needed for watch the world burn mode)

    for _, recipe in pairs(data.raw.recipe) do
        if recipe.ingredients ~= nil then
            local item_ing_seen = {}
            local new_ings = {}
            for _, ing in pairs(recipe.ingredients) do
                if ing.type ~= "item" or not item_ing_seen[ing.name] then
                    item_ing_seen[ing.name] = true
                    table.insert(new_ings, ing)
                else
                    for _, new_ing in pairs(new_ings) do
                        if new_ing.type == "item" and new_ing.name == ing.name then
                            new_ing.amount = new_ing.amount + ing.amount
                        end
                    end
                end
            end
            recipe.ingredients = new_ings
        end
    end

    -- Delimit belt stack size so that the upgrade research can take it past 4
    local uint8_max = 255
    for _, inserter in pairs(data.raw.inserter) do
        if inserter.max_belt_stack_size ~= nil and inserter.max_belt_stack_size > 1 then
            inserter.max_belt_stack_size = uint8_max
        end
    end
    data.raw["utility-constants"].default.max_belt_stack_size = uint8_max

    -- Factoriopedia annoyingly hides barrel recipes; why didn't the devs think about what if they were randomized?
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.subgroup == "fill-barrel" or recipe.subgroup == "empty-barrel" or recipe.subgroup == "barrel" then
            recipe.factoriopedia_alternative = nil
            recipe.subgroup = "fluid-recipes"
        end
    end
    -- In fact, let's make sure nothing is hidden in factoriopedia; information wants to be free!
    -- Actually, I think that was a bit extreme
    --[[for _, class in pairs(data.raw) do
        for _, prototype in pairs(class) do
            if prototype.hidden == true or prototype.hidden_in_factoriopedia == true then
                prototype.hidden_in_factoriopedia = false
            end
        end
    end]]

    -- Add fluid connections to assembling machines and remove recipes with fluids from crafting category
    -- TODO: Add fluid connections!
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.ingredients ~= nil then
            for _, ing in pairs(recipe.ingredients) do
                if ing.type == "fluid" then
                    if recipe.categories == nil or (#recipe.categories == 1 and recipe.categories[1] == "crafting") then
                        -- TODO: Properly fix!
                        -- This is a hotfix for the categories change
                        --recipe.categories = {"crafting-with-fluid"}
                    end
                    break
                end
            end
        end
    end

    -- Make all segments of a segmented unit have the same max health
    for _, unit in pairs(data.raw["segmented-unit"] or {}) do
        for _, segment_specification in pairs(unit.segment_engine.segments) do
            local segment = data.raw["segment"][segment_specification.segment]
            segment.max_health = unit.max_health
        end
    end

    -- Set solar panel weight to what it is in vanilla
    -- It sucks but this is the easiest hotfix to prevent them from not being launchable until the new logic is finished
    -- (Note: item weight rando directly doesn't cause this, but item rando combined with automatic weight calculation can)
    -- TODO: Remove this once I can do that
    data.raw.item["solar-panel"].weight = 20000

    -- Set weights so that you can't have more than 20 stacks of something needed for launch
    local rocket_silo_inventory_size = 20
    if data.raw["rocket-silo"]["rocket-silo"] ~= nil then
        rocket_silo_inventory_size = data.raw["rocket-silo"]["rocket-silo"].to_be_inserted_to_rocket_inventory_size or 20
    end
    for class_name, _ in pairs(defines.prototypes.item) do
        if data.raw[class_name] ~= nil then
            for _, item in pairs(data.raw[class_name]) do
                if item.weight == nil then
                    -- TODO: Make an error message probably
                    --log(item.name)
                else
                    if item.weight < data.raw["utility-constants"].default.default_rocket_lift_weight / (item.stack_size * rocket_silo_inventory_size) then
                        item.weight = math.ceil(data.raw["utility-constants"].default.default_rocket_lift_weight / (item.stack_size * rocket_silo_inventory_size))
                    end
                end
            end
        end
    end

    -- Fix technology names to indicate what sciences they require
    --[=[for _, tech in pairs(data.raw.technology) do
        local prereqs = {tech.name}
        local is_prereq = {[tech.name] = true}
        local index = 1
        while index <= #prereqs do
            local curr = prereqs[index]

            local curr_tech = data.raw.technology[curr]
            for _, prereq in pairs(curr_tech.prerequisites or {}) do
                if not is_prereq[prereq] then
                    is_prereq[prereq] = true
                    table.insert(prereqs, prereq)
                end
            end

            index = index + 1
        end
        local pack_required = {}
        for _, prereq in pairs(prereqs) do
            local tech = data.raw.technology[prereq]
            if tech.unit ~= nil then
                for _, ing in pairs(tech.unit.ingredients) do
                    pack_required[ing[1]] = true
                end
            end
        end
        local packs_as_list = {}
        for pack, _ in pairs(pack_required) do
            table.insert(packs_as_list, pack)
        end
        table.sort(packs_as_list, function(a, b)
            local tool_a = data.raw.tool[a]
            local tool_b = data.raw.tool[b]
            if tool_a ~= nil and tool_b ~= nil then
                return tool_a.order < tool_b.order
            end
            if tool_a == nil and tool_b ~= nil then
                return false
            end
            return true
        end)
        local tech_localised_name = locale_utils.find_localised_name(tech)
        local suffix = " "
        for _, pack in pairs(packs_as_list) do
            suffix = suffix .. "[item=" .. pack .. "]"
        end
        -- TODO: Include something like this again
        -- Note: Maybe not now that I just reconstruct the tech tree graph
        -- Was causing localised string to be too large
        --tech.localised_name = {"", tech_localised_name, suffix}
    end]=]

    if mods["pypostprocessing"] then
        -- Hotfix: Turn burner inserter energy sources back to void in py
        for _, inserter in pairs(data.raw.inserter) do
            if inserter.energy_source.type == "burner" then
                inserter.energy_source.type = "void"
            end
        end

        if DO_FRODO_FIXES then
            -- Change roboport to earlier since it was placed too late (I think it put a construction extender in the normal place)
            data.raw.recipe["bio-reactor-mk03"].ingredients = {{type = "item", name = "iron-plate", amount = 10}}
            data.raw.recipe["bio-reactor-mk03"].enabled = true
            data.raw.recipe["bio-reactor-mk03"].categories = nil
            -- Change local radar to be earlier since not having radar so long isn't really an interesting challenge
            data.raw.recipe["earth-wolf-sample"].ingredients = {{type = "item", name = "iron-plate", amount = 10}}
            data.raw.recipe["earth-wolf-sample"].enabled = true
            data.raw.recipe["earth-wolf-sample"].categories = nil
            -- Sap automation earlier
            data.raw.recipe["sap-01"].enabled = true
            data.raw.recipe["sap-01"].categories = {"sap-extractor"}
            data.raw.recipe["sap-01"].hide_from_player_crafting = true
            data.raw.recipe["charged-auog"].ingredients = {{type = "item", name = "iron-plate", amount = 10}}
            data.raw.recipe["charged-auog"].enabled = true
            data.raw.recipe["charged-auog"].categories = nil
            data.raw.recipe["filtration-media"].ingredients = {{type = "item", name = "iron-plate", amount = 10}}
            data.raw.recipe["filtration-media"].enabled = true
            data.raw.recipe["filtration-media"].categories = nil
            -- Moss
            data.raw.recipe["Moss-1"].enabled = true
            data.raw.recipe["Moss-1"].ingredients = {{type = "item", name = "wooden-chest", amount = 1}}
            data.raw.recipe["Moss-1"].categories = {"wpu"}
            -- Seaweed
            data.raw.recipe["seaweed-1"].enabled = true
            data.raw.recipe["seaweed-1"].categories = {"soil-extraction"}
            -- 50% chance for something that used to be a crafting recipe to return to one, to reduce the number of things that can't be handcrafted
            for _, recipe in pairs(data.raw.recipe) do

                -- I think there are mysterious reference problems, so let's do a deepcopy to get rid of those
                recipe.categories = table.deepcopy(recipe.categories)

                local old_recipe = old_data_raw.recipe[recipe.name]
                local has_crafting = false
                for _, cat in pairs(old_recipe.categories or {"crafting"}) do
                    if cat == "crafting" then
                        has_crafting = true
                    end
                end
                if has_crafting then
                    local already_crafting = false
                    for _, cat in pairs(recipe.categories or {"crafting"}) do
                        if cat == "crafting" then
                            already_crafting = true
                        end
                    end
                    if not already_crafting then
                        local has_fluid_ing = false
                        for _, ing in pairs(recipe.ingredients or {}) do
                            if ing.type == "fluid" then
                                has_fluid_ing = true
                                break
                            end
                        end
                        if not has_fluid_ing then
                            -- 50% chance
                            if math.random() < 0.5 then
                                -- categories is non-nil here
                                table.insert(recipe.categories, "crafting")
                            end
                        end
                    end
                end
            end
            -- Remove fish equivalent in logistic bots
            for _, ing in pairs(data.raw.recipe["planter-box"].ingredients) do
                if ing.name == "incubator-mk01" then
                    ing.name = "anemometer-mk01"
                    ing.amount = 1
                end
            end
            -- Reduce nexelit amounts
            for _, recipe in pairs(data.raw.recipe) do
                for _, ing in pairs(recipe.ingredients or {}) do
                    if ing.name == "nexelit-ore" then
                        ing.amount = math.ceil((ing.amount or 0) / 10)
                    end
                end
                for _, result in pairs(recipe.results or {}) do
                    if result.name == "nexelit-ore" then
                        result.amount = math.ceil((result.amount or 0) / 10)
                        result.amount_min = math.ceil((result.amount_min or 0) / 10)
                        result.amount_max = math.ceil((result.amount_max or 0) / 10)
                    end
                end
            end
        end
    end
end

randomizations.post_fixes = function()
    if DO_FRODO_FIXES then
    -- Reduce large amounts of ingredients
        for _, recipe in pairs(data.raw.recipe) do
            for _, ing in pairs(recipe.ingredients or {}) do
                if ing.amount >= 500 then
                    ing.amount = math.floor(ing.amount / 10)
                elseif ing.amount >= 150 then
                    ing.amount = math.floor(ing.amount / 5)
                elseif ing.amount >= 30 then
                    ing.amount = math.floor(ing.amount / 2)
                end
            end
        end
    end
end

randomizations.add_old_versions = function()
    -- old_data_raw_for_derandomization is a global

    -- Add any entity with a crafting recipe of the same name
    for entity_class, _ in pairs(defines.prototypes.entity) do
        for _, entity in pairs(old_data_raw_for_derandomization[entity_class] or {}) do
            if old_data_raw_for_derandomization.recipe[entity.name] ~= nil and old_data_raw_for_derandomization.recipe[entity.name].results ~= nil and #old_data_raw_for_derandomization.recipe[entity.name].results == 1 and old_data_raw.recipe[entity.name].results[1].name == entity.name then
                local copy = table.deepcopy(entity)
                copy.name = "old-" .. entity.name
                copy.localised_name = {"", locale_utils.find_localised_name(entity), " [color=154,61,0](Original!)[/color]"}
                copy.localised_description = "Just like old."
                local old_item
                local old_data_item
                for item_class, _ in pairs(defines.prototypes.item) do
                    if old_data_raw_for_derandomization[item_class] ~= nil and old_data_raw_for_derandomization[item_class][entity.name] ~= nil then
                        old_item = old_data_raw_for_derandomization[item_class][entity.name]
                    end
                    if data.raw[item_class] ~= nil and data.raw[item_class][entity.name] ~= nil then
                        old_data_item = data.raw[item_class][entity.name]
                    end
                end
                local item_copy = table.deepcopy(old_item)
                item_copy.name = copy.name
                item_copy.localised_name = {"", locale_utils.find_localised_name(entity), " [color=154,61,0](Original!)[/color]"}
                item_copy.localised_description = "Just like old."
                if item_copy.place_result == entity.name then
                    item_copy.place_result = copy.name
                end
                if copy.minable ~= nil then
                    if copy.minable.result == old_item.name then
                        copy.minable.result = copy.name
                    elseif copy.minable.results ~= nil then
                        for _, result in pairs(copy.minable.results) do
                            if result.name == old_item.name then
                                result.name = copy.name
                            end
                        end
                    end
                end
                if copy.placeable_by ~= nil then
                    if copy.placeable_by.item == entity.name then
                        copy.placeable_by.item = copy.name
                    elseif copy.placeable_by.item == nil then
                        for _, placeable in pairs(copy.placeable_by) do
                            if placeable.item == entity.name then
                                placeable.item = copy.name
                            end
                        end
                    end
                end
                -- Apply gray tint
                if copy.icons ~= nil then
                    for _, layer in pairs(copy.icons) do
                        layer.tint = {r = 0.5, g = 0.5, b = 0.5, a = 1}
                    end
                elseif copy.icon ~= nil then
                    copy.icons = {
                        {
                            icon = copy.icon,
                            icon_size = copy.icon_size or 64,
                            tint = {r = 0.5, g = 0.5, b = 0.5, a = 1},
                        }
                    }
                    copy.icon = nil
                end
                if item_copy.icons ~= nil then
                    for _, layer in pairs(item_copy.icons) do
                        layer.tint = {r = 0.5, g = 0.5, b = 0.5, a = 1}
                    end
                else
                    item_copy.icons = {
                        {
                            icon = item_copy.icon,
                            icon_size = item_copy.icon_size or 64,
                            tint = {r = 0.5, g = 0.5, b = 0.5, a = 1},
                        }
                    }
                    item_copy.icon = nil
                end
                local curr_entity = dutils.get_prot("entity", entity.name)
                if curr_entity.fast_replaceable_group == nil then
                    curr_entity.fast_replaceable_group = "old-" .. entity.name
                    copy.fast_replaceable_group = "old-" .. entity.name
                end
                item_copy.order = (data.raw[old_data_item.type][old_data_item.name].order or "") .. "z"
                item_copy.subgroup = data.raw[old_data_item.type][old_data_item.name].subgroup
                copy.order = (curr_entity.order or "z-" .. data.raw[old_data_item.type][old_data_item.name].order or "") .. "z"
                copy.subgroup = curr_entity.subgroup

                copy.hidden_in_factoriopedia = true
                item_copy.hidden_in_factoriopedia = true
                data:extend({
                    copy,
                    item_copy,
                    {
                        type = "recipe",
                        name = "derandomized-" .. "entity" .. "--" .. entity.name, -- We can't use gutils.key because colons aren't allowed
                        localised_name = {"", locale_utils.find_localised_name(entity), " [color=154,61,0](Original!)[/color]"},
                        ingredients = {{type = "item", name = entity.name, amount = 1}},
                        results = {{type = "item", name = item_copy.name, amount = 1}},
                        main_product = item_copy.name,
                        energy_required = 0.5,
                        enabled = false,
                        subgroup = old_data_raw_for_derandomization.recipe[entity.name].subgroup,
                        order = (old_data_raw_for_derandomization.recipe[entity.name].order or data.raw[old_data_item.type][old_data_item.name].order or "") .. "z",
                        hidden_in_factoriopedia = true,
                    },
                })
            end
        end
    end

    -- Special recipe fixes for Frodo; changes back time AND category
    if DO_FRODO_FIXES then
        for _, recipe in pairs(old_data_raw_for_derandomization.recipe) do
            local copy = table.deepcopy(recipe)
            copy.name = "derandomized-" .. "recipe" .. "--" .. recipe.name
            copy.localised_name = {"", locale_utils.find_localised_name(recipe), " [color=254,20,101](Old Recipe)[/color]"}
            copy.enabled = false
            -- Apply tint
            if copy.icons ~= nil then
                for _, layer in pairs(copy.icons) do
                    layer.tint = {r = 1, g = 0, b = 0, a = 1}
                end
            elseif copy.icon ~= nil then
                copy.icons = {
                    {
                        icon = copy.icon,
                        icon_size = copy.icon_size or 64,
                        tint = {r = 1, g = 0, b = 0, a = 1},
                    }
                }
                copy.icon = nil
            end
            -- Get the old old category
            copy.categories = table.deepcopy(old_data_raw.recipe[recipe.name].categories)
            -- Hide in factoriopedia
            copy.hidden_in_factoriopedia = true
            data:extend({
                copy,
            })
        end
        -- Free item samples crafting recipe
        for item_class, _ in pairs(defines.prototypes.item) do
            for _, item in pairs(data.raw[item_class] or {}) do
                local subgroup = item.subgroup
                local order = item.order
                if item.place_result ~= nil then
                    local entity = dutils.get_prot("entity", item.place_result)
                    subgroup = subgroup or entity.subgroup
                    order = order or entity.order
                end
                -- Apply tint
                local icons = table.deepcopy(item.icons or {})
                if next(icons) ~= nil then
                    for _, layer in pairs(icons) do
                        layer.tint = {r = 0, g = 1, b = 0, a = 1}
                    end
                elseif item.icon ~= nil then
                    icons = {
                        {
                            icon = item.icon,
                            icon_size = item.icon_size or 64,
                            tint = {r = 0, g = 1, b = 0, a = 1},
                        }
                    }
                end
                local new_recipe = {
                    type = "recipe",
                    name = "derandomized-" .. "item" .. "--" .. item.name,
                    localised_name = {"", locale_utils.find_localised_name(item), " [color=61,154,0](Free!)[/color]"},
                    icons = icons,
                    ingredients = {},
                    results = {{type = "item", name = item.name, amount = 1}},
                    main_product = item.name,
                    energy_required = 10,
                    categories = {"hand-crafting"},
                    enabled = false,
                    subgroup = subgroup,
                    order = (order or "") .. "z",
                    hidden_in_factoriopedia = true,
                }
                data:extend({
                    new_recipe,
                })
            end
        end
    end
end
-- Preserve costs in the original recipe's local production tier, or its import-enabled tier when imports are needed.

local constants = require("helper-tables/constants")
local logic = require("lib/logic/init")
local gutils = require("lib/graph/graph-utils")
local lutils = require("lib/logic/logic-utils")
local dutils = require("lib/data-utils")
local lu = require("lib/lookup/init")
-- Used for getting trav name
local first_pass = require("randomizations/graph/unified/first-pass")
-- Later, I will want a refactored cost library
local flow_cost = require("lib/cost/flow-cost")
local cost_lib = require("randomizations/graph/recipe-cost")
local furnace_selection = require("lib/furnace-selection")
local context_costs = require("lib/cost/context-costs")
local staged_recipes = require("lib/cost/staged-recipes")
local recipe_shape = require("lib/recipe-shape")
local item_fluid = require("lib/item-fluid")
local rng = require("lib/random/rng")
local categories = require("helper-tables/categories")


local key = gutils.key

-- Recipe shapes: the spoofed slot a fluid no recipe takes gets, so it has pool entries too (see spoof)
local FLUID_SLOT_TYPE = "recipe-shape-fluid-slot"

-- Reprice imports lazily once per batch of recipe decisions. Local costs still update after every recipe (including its generated reverse recipes).
local IMPORT_BATCH_SIZE = 16

local recipe_ingredients = {}

recipe_ingredients.id = "recipe_ingredients"

recipe_ingredients.with_replacement = true
-- With recipe shapes, claim's copies go straight into the pool (fluids few recipes take get more, see claim); without, a handler with replacement has its extra copies dropped (execute.lua's shuffle), so nothing changes there
recipe_ingredients.uniform_copies = config.recipe_shapes == true

-- Include 10 copies first time, 3 copies each one after
local already_duped
local dependent_to_new_ings
local claimed_recipes
-- Recipe shapes (config.recipe_shapes, lib/recipe-shape.lua): how many recipes take each material and the median over fluids (for claim's copies), the cap on fluid amounts, and what the plans and searches did (the RECIPESHAPES lines)
local ingredient_uses
local fluid_use_median
local fluid_amount_cap
local shape_stats
recipe_ingredients.initialize = function()
    already_duped = {}
    claimed_recipes = {}
    ingredient_uses = nil
    fluid_use_median = nil
    fluid_amount_cap = nil
    shape_stats = nil
    recipe_shape.reset()
    if config.recipe_shapes then
        ingredient_uses = recipe_shape.ingredient_uses(data.raw.recipe, key, item_fluid.is_recycling_recipe)
        local fluid_uses = {}
        for material_key, uses in pairs(ingredient_uses) do
            if gutils.deconstruct(material_key).type == "fluid" then
                table.insert(fluid_uses, uses)
            end
        end
        fluid_use_median = recipe_shape.median(fluid_uses)
        fluid_amount_cap = recipe_shape.largest_fluid_amount(data.raw.recipe)
    end
end

-- Fluid ingredients enter recipes through fluid-temperature-range nodes, so report those as the fluid itself
local function as_material(node)
    if node.type == "fluid-temperature-range" then
        return { type = "fluid", name = gutils.deconstruct(node.name).type }
    end
    return node
end

-- Like gutils.get_owner, but with fluid-temperature-range owners reported as their fluid
local function get_material_owner(graph, conn_node)
    return as_material(gutils.get_owner(graph, conn_node))
end

-- Recipe shapes (config.recipe_shapes): a fluid no recipe takes (the thruster fuels and fusion plasma in vanilla) gets a spoofed slot fed by its temperature-range node at a temperature it's made at, whose claimed edge puts entries for it in the pool like any ingredient edge (see claim)
-- The slot is a spoof, so it's never a dependent to randomize, first pass doesn't count it as a recipe taking the fluid (lib/item-fluid.lua only counts recipes), and the search makes the ingredient up with no temperature bounds (custom_prereq_search), which the single-temperature node models pessimistically
recipe_ingredients.spoof = function(graph)
    if not config.recipe_shapes then
        return
    end
    logic.type_info[FLUID_SLOT_TYPE] = logic.type_info[FLUID_SLOT_TYPE] or {
        op = "AND",
        canonical = FLUID_SLOT_TYPE,
    }
    local names = {}
    for fluid_name, fluid in pairs(data.raw.fluid or {}) do
        if fluid.hidden ~= true and fluid.parameter ~= true and ingredient_uses[key("fluid", fluid_name)] == nil then
            -- At its default temperature when it's made at that, else the first temperature it's made at
            local temps = lu.fluid_temperatures_ordered[fluid_name] or {}
            local temp = temps[1]
            for _, made_at in pairs(temps) do
                if made_at == fluid.default_temperature then
                    temp = made_at
                end
            end
            local range_key = temp ~= nil and key("fluid-temperature-range", key(fluid_name, key(tostring(temp), tostring(temp)))) or nil
            if range_key ~= nil and graph.nodes[range_key] ~= nil then
                local slot = gutils.add_node(graph, FLUID_SLOT_TYPE, fluid_name, {
                    op = "AND",
                    spoof = true,
                })
                gutils.add_edge(graph, range_key, key(slot))
                table.insert(names, fluid_name)
            end
        end
    end
    table.sort(names)
    log("RECIPESHAPES pool: " .. #names .. " fluids no recipe takes got a spoofed slot each: " .. table.concat(names, ", "))
end

recipe_ingredients.claim = function(graph, prereq, dep, edge)
    -- A spoofed slot of a fluid no recipe takes (see spoof): as many entries as a fluid one recipe takes would get
    if prereq.type == "fluid-temperature-range" and dep.type == FLUID_SLOT_TYPE and dep.spoof == true then
        return recipe_shape.copies_for(1, fluid_use_median, constants.recipe_shape.max_fluid_copies)
    end
    if (prereq.type == "item" or prereq.type == "fluid" or prereq.type == "fluid-temperature-range") and dep.type == "recipe" then
        prereq = as_material(prereq)
        local recipe = data.raw.recipe[dep.name]
        if recipe.hidden then
            return false
        end
        -- Having a cost doesn't decide what's randomized (automatability does, through promotion's contexts); a recipe without a vanilla cost keeps its ingredients when processed
        -- Need to check this here due to doing custom prereq search
        if randomization_info.options.unified["recipe-ingredients"].blacklisted_pre[key(prereq)] then
            return false
        end
        if randomization_info.options.unified["recipe-ingredients"].blacklisted_dep[key(dep)] then
            return false
        end

        claimed_recipes[dep.name] = true
        -- With recipe shapes, one pool entry per item edge and more for the edges of fluids few recipes take, so every fluid is proposed about as often as the median one (recipe_shape.copies_for); they go straight into the pool (uniform_copies)
        if config.recipe_shapes then
            if prereq.type == "fluid" then
                return recipe_shape.copies_for(ingredient_uses[key(prereq)], fluid_use_median, constants.recipe_shape.max_fluid_copies)
            end
            return 1
        end
        -- TODO: Other checks
        -- TODO: Better claim logic (not sure what that would entail yet)
        -- TODO: Things are delicate right now... I should really decrease this from 6 or at least add ways to encourage lesser-used intermediates
        if already_duped[key(prereq)] then
            return 2
        else
            already_duped[key(prereq)] = true
            return 50
        end
    end
end

-- Ingredients the current recipe must keep because promised recycling relies on them (see promotion.lua), as material key --> true
local current_pins = {}

local function is_unrandomized_ing(ind, is_result_of_this_recipe, recipe)
    -- If this is special in any way, don't randomize

    local ing = recipe.ingredients[ind]

    if current_pins[key(ing)] ~= nil then
        return true
    end

    if is_result_of_this_recipe[ing.type .. "-" .. ing.name] then
        return true
    end
    if randomization_info.options.unified["recipe-ingredients"].blacklisted_pre[key(ing)] then
        return true
    end

    return false
end

-- TODO: Recipe rando should probably go based on all planets, not just first surface
-- This is motivated by preserving the isolated context in the future, which needs to be done on multiple planets
-- In particular, spoilage comes first on nauvis and otherwise might need to be manually assigned to Gleba

-- Recipe shapes (config.recipe_shapes): plans how many ingredients each claimed recipe takes and how many are fluids before any head is randomized (lib/recipe-shape.lua, notes/recipe-shape-plan.md)
-- A plan that gains fluids needs the category node serving them (item_fluid.recipe_category_key, the rule first pass uses), which promotion has to accept as a further prerequisite of the recipe before anything is promised on top of it (require_recipe_category: the recipe keeps every context it can be established in, so nothing downstream loses one); refused, the plan backs off one fluid at a time, since vanilla's count needs nothing
-- The recipe-category handler reads the plans (recipe_shape.planned) for its furnace and fluid box checks, and the search fills the planned slots (custom_prereq_search)
recipe_ingredients.before_heads = function(params)
    if not config.recipe_shapes then
        return
    end
    local prom = params.promotion
    if prom == nil then
        log("Recipe shapes: no promotion state to check plans against, so recipes keep their shapes")
        return
    end
    local random_graph = params.random_graph
    local split_graph = params.split_graph
    local largest_count = recipe_shape.largest_count(data.raw.recipe)
    local pools = furnace_selection.pools()
    local blacklisted_pre = randomization_info.options.unified["recipe-ingredients"].blacklisted_pre
    -- Crafting machines by name, for their item ingredient caps
    local machines = {}
    for class, _ in pairs(categories.crafting_machines) do
        for name, machine in pairs(dutils.prots(class)) do
            machines[name] = machine
        end
    end
    -- The most input fluid boxes among the crafters of the recipe's categories with this many results (the logic's category nodes that have a crafter, keyed as item_fluid.recipe_category_key keys them), or -1 without any, and the fewest item ingredients those crafters take
    local function crafter_caps(recipe, num_results)
        local caps = {
            count = largest_count,
            num_fluids = -1,
            num_items = 65535,
        }
        for input = 0, math.min(largest_count, constants.recipe_shape.max_fluids) do
            local rcat_name = gutils.deconstruct(item_fluid.recipe_category_key(recipe, {
                input = input,
                output = num_results,
            })).name
            local crafters = lu.rcat_to_crafters[rcat_name]
            if crafters ~= nil and next(crafters) ~= nil then
                caps.num_fluids = input
                for machine_name, _ in pairs(crafters) do
                    local machine = machines[machine_name]
                    if machine ~= nil and machine.ingredient_count ~= nil then
                        caps.num_items = math.min(caps.num_items, machine.ingredient_count)
                    end
                end
            end
        end
        return caps
    end
    -- Ingredients the search leaves alone as far as is known now: the recipe's own results and blacklisted materials (pins come later, and the search raises a shape to hold them)
    local function kept_counts(recipe)
        local is_result = {}
        for _, result in pairs(recipe.results or {}) do
            is_result[key(result)] = true
        end
        local kept = {}
        for _, ing in pairs(recipe.ingredients or {}) do
            if is_result[key(ing)] ~= nil or blacklisted_pre[key(ing)] ~= nil then
                table.insert(kept, ing)
            end
        end
        return recipe_shape.count_forms(kept)
    end
    shape_stats = {
        planned = 0,
        unplannable = 0,
        gained = 0,
        cut_back = 0,
        planned_counts = {},
        planned_fluids = {},
        rungs_fallen = 0,
        before_counts = {},
        before_fluids = {},
        after_counts = {},
        after_fluids = {},
        slots_before = 0,
        fluid_slots_before = 0,
        slots_after = 0,
        fluid_slots_after = 0,
        with_fluid_before = 0,
        with_fluid_after = 0,
        fluid_uses = {},
    }
    for _, dep in pairs(params.sorted_deps) do
        local node = random_graph.nodes[dep]
        if node.type == "recipe" and claimed_recipes[node.name] ~= nil then
            local recipe = data.raw.recipe[node.name]
            -- First pass's fluids on the model's node (item_fluid.rewire_form_change), which the crafters' boxes must serve too
            local model_node = (split_graph ~= nil and split_graph.nodes[dep]) or node
            local delta = {
                input = (model_node.fluid_delta or {}).input or 0,
                output = (model_node.fluid_delta or {}).output or 0,
            }
            local num_results = #(recipe.results or {}) + delta.output
            local plan = recipe_shape.plan({
                vanilla = recipe_shape.count_forms(recipe.ingredients or {}),
                kept = kept_counts(recipe),
                caps = crafter_caps(recipe, num_results),
                delta = delta,
                furnace = #furnace_selection.pools_for(pools, furnace_selection.recipe_categories(recipe)) > 0,
                chances = constants.recipe_shape,
                rng_key = rng.key({
                    id = "recipe-shapes",
                    prototype = recipe,
                }),
            })
            if plan == nil then
                shape_stats.unplannable = shape_stats.unplannable + 1
            else
                -- Promotion keeps the recipe establishable wherever it is now, so nothing that takes its products loses a context
                while plan.gain > 0 do
                    local target = item_fluid.recipe_category_key(recipe, {
                        input = plan.model_fluids + delta.input,
                        output = num_results,
                    })
                    if prom.require_recipe_category(dep, target) then
                        shape_stats.gained = shape_stats.gained + 1
                        break
                    end
                    shape_stats.cut_back = shape_stats.cut_back + 1
                    plan = recipe_shape.back_off(plan)
                end
                recipe_shape.set_plan(recipe.name, plan)
                shape_stats.planned = shape_stats.planned + 1
                shape_stats.planned_counts[plan.count] = (shape_stats.planned_counts[plan.count] or 0) + 1
                shape_stats.planned_fluids[plan.num_fluids] = (shape_stats.planned_fluids[plan.num_fluids] or 0) + 1
            end
        end
    end
    log("RECIPESHAPES plans: " .. shape_stats.planned .. " recipes planned, " .. shape_stats.gained .. " gained fluid slots in the model, " .. shape_stats.cut_back .. " plans cut back by a fluid where promotion refused the category, " .. shape_stats.unplannable .. " with no crafter; planned counts " .. recipe_shape.describe(shape_stats.planned_counts) .. "; planned fluids " .. recipe_shape.describe(shape_stats.planned_fluids))
end

-- Attempt with usual cost analysis
recipe_ingredients.custom_prereq_search = function(params)
    local random_graph = params.random_graph
    local sorted_deps = params.sorted_deps
    local shuffled_prereqs = params.shuffled_prereqs
    local sort_for_pool = params.sort_for_pool
    local trav_to_slot = params.trav_to_slot
    local do_first_pass = params.do_first_pass

    -- With items and fluids trading positions (lib/item-fluid.lua), a candidate's form in the game is its identity's, not its position's: a recipe given a fluid identity at an item position takes a fluid
    -- So the search fills each slot by the identity's form (the candidate's form field, see search_for_ings), and the game's fluid count never exceeds what the model's category serves: the recipe's own fluid counts plus first pass's on it, which the recipe-category handler checks
    -- Without this (seen on base seed 4, 2026-09-30), early hand-crafted recipes took heavy oil at copper plate's position as an item and lost hand crafting in the game
    local identity_form = {}
    if do_first_pass and config.item_fluids and params.split_graph ~= nil then
        for trav_key, slot_key in pairs(trav_to_slot) do
            local slot_node = params.split_graph.nodes[slot_key]
            local trav_node = params.split_graph.nodes[trav_key]
            if slot_node ~= nil and trav_node ~= nil then
                local position = item_fluid.material_of_node(params.split_graph, slot_node)
                local identity = item_fluid.material_of_node(params.split_graph, trav_node)
                if position ~= nil and identity ~= nil then
                    identity_form[key(position)] = identity.type
                end
            end
        end
    end
    -- A candidate ingredient entry for a position, with the form it has in the game
    local function candidate_entry(entry, position)
        local candidate = {}
        for field, value in pairs(entry) do
            candidate[field] = value
        end
        candidate.form = identity_form[key(position)] or position.type
        return candidate
    end

    local used_mats = {}
    for _, recipe in pairs(data.raw.recipe) do
        local has_recycling = false
        for _, category in pairs(furnace_selection.recipe_categories(recipe)) do
            if category == "recycling" then
                has_recycling = true
            end
        end
        if recipe.ingredients ~= nil and not has_recycling then
            for _, ing in pairs(recipe.ingredients) do
                used_mats[key(ing)] = true
            end
        end
    end

    -- Helper function to determine if a recipe is used in any other recipes
    -- I think we might not need this?
    local function produces_final_products(recipe)
        if recipe.results ~= nil then
            for _, result in pairs(recipe.results) do
                if used_mats[flow_cost.get_prot_id(result)] ~= nil then
                    return false
                end
            end

            return true
        end
    end

    -- Ingredient overrides make unprocessed recipes unavailable to staged pricing.
    dependent_to_new_ings = {}
    local dependent_to_old_ings = context_costs.data_overrides()
    for _, dep in pairs(sorted_deps) do
        local node = random_graph.nodes[dep]
        if node.type == "recipe" and claimed_recipes[node.name] then
            local recipe_name = node.name
            dependent_to_new_ings[recipe_name] = {"blacklisted"}
            local slot_node = (do_first_pass and random_graph.nodes[trav_to_slot[key(node.type, first_pass.make_trav_name(node.name))] ]) or node
            dependent_to_old_ings[slot_node.name] = {"blacklisted"}
        end
    end
    -- Add sensitive recipes back to dependent_to_new_ings
    for node_key, _ in pairs(randomization_info.options.unified["recipe-ingredients"].blacklisted_dep) do
        if random_graph.nodes[node_key] ~= nil then
            local recipe_name = random_graph.nodes[node_key].name
            assert(recipe_name ~= "")
            local recipe = data.raw.recipe[recipe_name]
            dependent_to_new_ings[recipe_name] = {}
            local slot_node = (do_first_pass and random_graph.nodes[trav_to_slot[key("recipe", first_pass.make_trav_name(recipe_name))] or node_key]) or random_graph.nodes[node_key]
            dependent_to_old_ings[slot_node.name] = data.raw.recipe[slot_node.name].ingredients or {}

            if recipe.ingredients ~= nil then
                for _, ing in pairs(recipe.ingredients) do
                    table.insert(dependent_to_new_ings[recipe_name], ing)
                end
            end
        end
    end
    -- Keep unchanged recipes, including hidden routes. The staged world below blocks generated recycling
    -- while its source is pending; each room's availability still filters which recipes it can use.
    for recipe_name, recipe in pairs(data.raw.recipe) do
        if dependent_to_new_ings[recipe_name] == nil then
            dependent_to_new_ings[recipe_name] = {}
            for _, ing in pairs(recipe.ingredients or {}) do
                table.insert(dependent_to_new_ings[recipe_name], ing)
            end
        end
    end
    local major_raw_resources = randomization_info.options.cost.major_raw_resources
    local vanilla_item_recipe_maps = flow_cost.construct_item_recipe_maps()
    local original_world = staged_recipes.new(data.raw, dependent_to_old_ings)
    local original_item_recipe_maps = flow_cost.construct_item_recipe_maps(dependent_to_old_ings, false, original_world.recipes)
    local staged_world = staged_recipes.new(data.raw, dependent_to_new_ings)
    local randomized_item_recipe_maps = flow_cost.construct_item_recipe_maps(dependent_to_new_ings, false, staged_world.recipes)
    -- Both sides admit recipes in processing order, so later cheap routes cannot lower an earlier target.
    -- Each recipe keeps one pricing tier in its room, so its ingredients and outputs use the same production network.
    local rooms = context_costs.current
    -- Record the rooms recipes are judged in. Dynamic imports also keep their supplying rooms up to date.
    local judged_contexts = {}
    for _, dep in pairs(sorted_deps) do
        local node = random_graph.nodes[dep]
        if node.type == "recipe" and claimed_recipes[node.name] then
            local slot_node = (do_first_pass and random_graph.nodes[trav_to_slot[key(node.type, first_pass.make_trav_name(node.name))] ]) or node
            judged_contexts[context_costs.judging_context(rooms, slot_node.name) or rooms.starting_context] = true
        end
    end
    -- Original prices stay fixed across retries and supply initial quotes for imports whose source recipes have not been processed.
    local full_sets = context_costs.set_views(context_costs.game_set(rooms, major_raw_resources), major_raw_resources)
    local function staged_sets(set_params)
        set_params.batch_imports = true
        set_params.track_resources = major_raw_resources
        set_params.updated_contexts = judged_contexts
        set_params.imports_from = full_sets.set
        return context_costs.set_views(context_costs.new_set(rooms, set_params), major_raw_resources)
    end
    local vanilla_sets = staged_sets({
        ing_overrides = dependent_to_old_ings,
        use_data = false,
        item_recipe_maps = original_item_recipe_maps,
        recipe_prototypes = original_world.recipes,
        dynamic_imports = true,
    })
    local randomized_sets = staged_sets({
        ing_overrides = dependent_to_new_ings,
        use_data = false,
        item_recipe_maps = randomized_item_recipe_maps,
        recipe_prototypes = staged_world.recipes,
        dynamic_imports = true,
    })
    local function update_staged(world, maps, sets, overrides, recipe_name)
        local updated_recipes = world.update(recipe_name)
        flow_cost.update_item_recipe_maps(maps, updated_recipes, overrides, true)
        for _, updated_recipe in pairs(updated_recipes) do
            sets.update(updated_recipe.name)
        end
    end
    -- Unprocessed ingredients use their original quote in the same tier.
    -- Promotion determines availability independently; an ingredient without a quote in that tier cannot be selected.
    local fallback_view = context_costs.fallback_view
    local recipe_cost_in = context_costs.recipe_cost_in
    local function no_cost()
        return 0
    end

    -- How much of each material's cost in a room comes from newer resources, for the search's bonus that gets them used (context_costs.novelty)
    local newer_resources = context_costs.newer_resources(major_raw_resources)
    local function novelty_in(context, tier_name)
        return context_costs.novelty(rooms, context, full_sets.set, newer_resources, vanilla_item_recipe_maps, tier_name)
    end

    -- Furnaces (the recycler too) pick their recipe by ingredient, so recipes one furnace can craft mustn't share one (lib/furnace-selection.lua's tracker)
    -- Categories are where recipe-category randomization put them, which it decided before this search
    local final_categories = {}
    for head_key, base_key in pairs(params.head_to_base or {}) do
        local head_owner = gutils.get_owner(random_graph, random_graph.nodes[head_key])
        local base_owner = gutils.get_owner(random_graph, random_graph.nodes[base_key])
        if head_owner.type == "recipe" and not head_owner.spoof and base_owner.type == "recipe-category" and lu.rcats[base_owner.name] ~= nil then
            final_categories[head_owner.name] = lu.rcats[base_owner.name].cats
        end
    end
    local furnaces = furnace_selection.tracker(function(recipe)
        return final_categories[recipe.name]
    end)
    local furnace_pools_of = furnaces.pools_of
    local take = furnaces.take
    local is_taken = furnaces.is_taken
    local reserve = furnaces.reserve
    local release = furnaces.release
    -- The recipe whose slot a dependent fills, which sets its budget and what it falls back to
    local function slot_recipe_of(node)
        -- The original slot recipe sets the budget even when first pass changes which recipe fills it.
        local slot_node = (do_first_pass and random_graph.nodes[trav_to_slot[key(node.type, first_pass.make_trav_name(node.name))] ]) or node
        return data.raw.recipe[slot_node.name], slot_node
    end
    -- Ingredients that won't change: all of those in recipes this search leaves alone, and those kept in recipes it randomizes
    local to_process = {}
    for _, dep in pairs(sorted_deps) do
        local node = random_graph.nodes[dep]
        if node.type == "recipe" and claimed_recipes[node.name] then
            to_process[node.name] = true
        end
    end
    for recipe_name, recipe in pairs(data.raw.recipe) do
        for _, ing in pairs(recipe.ingredients or {}) do
            if to_process[recipe_name] == nil or randomization_info.options.unified["recipe-ingredients"].blacklisted_pre[key(ing)] then
                take(recipe, ing)
            else
                for _, result in pairs(recipe.results or {}) do
                    if result.type == ing.type and result.name == ing.name then
                        take(recipe, ing)
                    end
                end
            end
        end
    end
    -- A recipe whose search fails falls back to its slot's vanilla ingredients without asking the tracker, so those are held for it until it's done
    -- Otherwise a recipe searched earlier could take one as a new ingredient in the same furnace (copper cable falling back to copper plate after firearm magazines took it in smelting, base preview seed 1 on 2026-09-30)
    for _, dep in pairs(sorted_deps) do
        local node = random_graph.nodes[dep]
        if node.type == "recipe" and to_process[node.name] ~= nil then
            local dependent_recipe = data.raw.recipe[node.name]
            local slot_recipe = slot_recipe_of(node)
            if dependent_recipe ~= nil and slot_recipe ~= nil then
                for _, ing in pairs(slot_recipe.ingredients or {}) do
                    reserve(dependent_recipe, ing)
                end
            end
        end
    end

    -- Shared promotion state from execute.lua (nil means use the old every-context ordering check)
    local prom = params.promotion
    local num_fallbacks = 0
    -- Recipes at chunk boundaries (debt mode) whose new ingredients pay for them
    local num_paying = 0

    local num_processed = 0
    local total_valid_prereqs = 0
    local num_changed_ings = 0
    -- Newer resources in the ingredients chosen (see novelty_in), before and after, summed over ingredients
    local old_newer_share = 0
    local new_newer_share = 0
    -- How far chosen ingredients' aggregate cost is from the slot recipe's (mean absolute log ratio, over searched recipes)
    local cost_drift = 0
    local num_drift = 0
    local num_ings = 0
    local ind_to_used = {}
    for _, dep in pairs(sorted_deps) do
        local node = random_graph.nodes[dep]
        if node.type == "recipe" and claimed_recipes[node.name] then
            if num_processed % IMPORT_BATCH_SIZE == 0 then
                vanilla_sets.set:invalidate_imports()
                randomized_sets.set:invalidate_imports()
            end
            log("Processing " .. node.name)
            current_pins = prom ~= nil and prom.pins_for(dep) or {}
            local required_contexts
            if prom ~= nil then
                required_contexts = prom.required_contexts(dep)
                if #required_contexts == 0 then
                    if prom.initially_reachable(dep) then
                        -- Every recipe must stay reachable, so this is a failure
                        log("Promotion: " .. dep .. " can no longer be reached in any context")
                        return false
                    end
                    log("Promotion: " .. dep .. " was already unreachable before recipe randomization")
                end
            end
            local dependent_recipe = data.raw.recipe[node.name]
            assert(dependent_recipe ~= nil)
            -- Ignore the heads etc., just find good ings via search

            local slot_recipe, slot_node = slot_recipe_of(node)
            assert(slot_recipe ~= nil)
            log("Old context: " .. slot_node.name)

            -- Use one production tier for both sides of the comparison in the slot recipe's room.
            local context = context_costs.judging_context(rooms, slot_recipe.name) or rooms.starting_context
            -- Without a vanilla cost for the slot's recipe there's nothing to compare ingredients against, so it keeps the slot's ingredients like after a failed search
            local tier_name = "local"
            if recipe_cost_in(full_sets.aggregate(context, tier_name), slot_recipe) == nil then
                tier_name = "full"
            end
            -- Preserve the staged reference. The full game's quote is only the existing fallback
            -- when this processing order reaches a slot before the recipes making its ingredients.
            local slot_is_staged = recipe_cost_in(vanilla_sets.aggregate(context, tier_name), slot_recipe) ~= nil
            dependent_to_old_ings[slot_recipe.name] = slot_recipe.ingredients or {}
            update_staged(original_world, original_item_recipe_maps, vanilla_sets, dependent_to_old_ings, slot_recipe.name)
            local slot_vanilla
            if slot_is_staged then
                slot_vanilla = vanilla_sets.in_room(context, tier_name)
            else
                log("Staged vanilla costs don't reach " .. slot_recipe.name .. " yet; comparing against full vanilla costs")
                slot_vanilla = full_sets.in_room(context, tier_name)
            end
            local slot_cost = recipe_cost_in(slot_vanilla.aggregate, slot_recipe)
            local slot_cost_known = slot_cost ~= nil
            do
                -- Gather information about this recipe
                local dependent_pools = furnace_pools_of(dependent_recipe)
                local is_smelting_recipe = #dependent_pools > 0
                -- Pinned ingredients stay, so this search can't help if another recipe here took them already; the built-game check reports it
                for material_key, _ in pairs(current_pins) do
                    local material = gutils.deconstruct(material_key)
                    local pin_is_own = false
                    for _, ing in pairs(dependent_recipe.ingredients or {}) do
                        if key(ing) == material_key then
                            pin_is_own = true
                        end
                    end
                    if not pin_is_own and is_taken(dependent_pools, material, dependent_recipe) then
                        log("Furnace selection: pinned ingredient " .. material_key .. " of " .. dependent_recipe.name .. " is already used by another recipe its furnaces craft")
                    end
                end
                local is_result_of_this_recipe = {}
                if dependent_recipe.results ~= nil then
                    for _, result in pairs(dependent_recipe.results) do
                        is_result_of_this_recipe[result.type .. "-" .. result.name] = true
                    end
                end

                local candidate_costs = fallback_view(randomized_sets.aggregate(context, tier_name).material_to_cost, full_sets.aggregate(context, tier_name).material_to_cost)

                local function find_valid_prereq_list(shuffled_prereqs)
                    -- Only include each prereq once
                    local already_included = {}

                    local valid_prereq_list = {}
                    local valid_prereq_inds = {}
                    for prereq_index, prereq in pairs(shuffled_prereqs) do
                        -- Make sure this prereq has currently calculable costs
                        local prereq_node = random_graph.nodes[prereq]
                        local prereq_owner = get_material_owner(random_graph, prereq_node)
                        local prereq_prot = dutils.get_prot(prereq_owner.type, prereq_owner.name)
                        local prereq_prot_id = flow_cost.get_prot_id(prereq_owner)
                        local has_costs = candidate_costs[prereq_prot_id] ~= nil

                        local function do_recipe_checks()
                            if prom ~= nil and #required_contexts > 0 then
                                -- Must be promotable in each context the recipe is required in
                                if not prom.candidate_ok(dep, key(gutils.get_owner(random_graph, prereq_node)), required_contexts) then
                                    return false
                                end
                            end
                            -- Test for reachability at all contexts
                            local key1 = prereq
                            local key2 = dep
                            for context, _ in pairs(prom ~= nil and {} or logic.contexts) do
                                local index1 = sort_for_pool.node_to_context_inds[key1][context]
                                local index2 = sort_for_pool.node_to_context_inds[key2][context]
                                -- TODO: Should I ignore nil contexts?
                                --[[if ignore_nil_contexts and (index1 == nil or index2 == nil) then
                                    return true
                                end]]
                                index1 = index1 or (#sort_for_pool.sorted + 1)
                                index2 = index2 or (#sort_for_pool.sorted + 2)
                                if not (index1 < index2) then
                                    return false
                                end
                            end

                            -- Test for prereqs already used for other dependents
                            if ind_to_used[prereq_index] then
                                return false
                            end

                            -- Make sure this ingredient isn't in the results of the recipe
                            if is_result_of_this_recipe[prereq_prot_id] then
                                return false
                            end

                            -- Make sure we don't have fuels as ingredients of smelting recipes
                            if is_smelting_recipe and prereq_prot.fuel_value ~= nil and util.parse_energy(prereq_prot.fuel_value) > 0 then
                                return false
                            end

                            -- Don't share an ingredient with another recipe the same furnace crafts
                            if is_taken(dependent_pools, prereq_owner, dependent_recipe) then
                                return false
                            end

                            -- Make sure we can find a cost for it
                            if not has_costs then
                                return false
                            end

                            -- If the cost is too high, return false
                            if candidate_costs[prereq_prot_id] > slot_cost then
                                return false
                            end

                            -- Check if we already included this as a prereq for this recipe
                            if already_included[key(prereq_owner)] then
                                return false
                            end

                            -- Make sure the ingredient isn't too cheap, but don't worry about it for very expensive recipes
                            local should_check_costs = true
                            if constants.unified_recipe_ingredients_cost_threshold < slot_cost then
                                should_check_costs = false
                            end
                            if should_check_costs then
                                local largeness_okay_multiplier = 1
                                if prereq_owner.type == "fluid" then
                                    largeness_okay_multiplier = 0.1
                                end
                                if candidate_costs[prereq_owner.type .. "-" .. prereq_owner.name] < largeness_okay_multiplier * 0.001 * slot_cost then
                                    return false
                                end
                            end

                            return true
                        end

                        if do_recipe_checks() then
                            table.insert(valid_prereq_list, prereq)
                            table.insert(valid_prereq_inds, prereq_index)
                            already_included[key(prereq_owner)] = true
                        end
                    end

                    return {prereq_list = valid_prereq_list, prereq_inds = valid_prereq_inds}
                end

                -- Extract material_to_costs
                local vanilla_material_to_costs = {}
                vanilla_material_to_costs.aggregate_cost = slot_vanilla.aggregate.material_to_cost
                vanilla_material_to_costs.complexity_cost = slot_vanilla.complexity.material_to_cost
                vanilla_material_to_costs.resource_costs = {}
                for _, resource_id in pairs(major_raw_resources) do
                    vanilla_material_to_costs.resource_costs[resource_id] = slot_vanilla.resources[resource_id].material_to_cost
                end
                local vanilla_recipe_costs = slot_cost_known and cost_lib.get_costs_from_ings(vanilla_material_to_costs, slot_recipe.ingredients) or nil
                -- Ingredients (candidates, and kept ones whose recipes come later in this run) are priced with fallbacks, like candidate_costs
                -- The search reads the same prices many times over, and they can't change until this recipe's own update_staged below, so each is worked out once
                local function cached(costs)
                    return setmetatable({}, {
                        __index = function(cache, id)
                            local cost = costs[id]
                            rawset(cache, id, cost)
                            return cost
                        end,
                    })
                end
                local randomized_material_costs = {}
                randomized_material_costs.aggregate_cost = cached(candidate_costs)
                randomized_material_costs.complexity_cost = context_costs.NO_COMPLEXITY.material_to_cost
                randomized_material_costs.resource_costs = {}
                for _, resource_id in pairs(major_raw_resources) do
                    randomized_material_costs.resource_costs[resource_id] = cached(fallback_view(randomized_sets.resource(context, resource_id, tier_name).material_to_cost, full_sets.resource(context, resource_id, tier_name).material_to_cost, no_cost))
                end

                local potential_ings = {}
                local valid_prereq_list_info = {
                    prereq_list = {},
                    prereq_inds = {},
                }
                if slot_cost_known then
                    valid_prereq_list_info = find_valid_prereq_list(shuffled_prereqs)
                end
                num_processed = num_processed + 1
                total_valid_prereqs = total_valid_prereqs + #valid_prereq_list_info.prereq_list
                for _, prereq in pairs(valid_prereq_list_info.prereq_list) do
                    local prereq_node = random_graph.nodes[prereq]
                    local prereq_owner = get_material_owner(random_graph, prereq_node)
                    local ing_recipe_node = gutils.get_owner(random_graph, random_graph.nodes[prereq_node.old_head])
                    if ing_recipe_node.spoof == true then
                        -- A spoofed slot of a fluid no recipe takes (see spoof): the fluid at any temperature, its amount the search's to pick
                        table.insert(potential_ings, candidate_entry({
                            type = "fluid",
                            name = prereq_owner.name,
                            amount = 1,
                        }, prereq_owner))
                    else
                        -- TODO: In the future, maybe some less painful way of getting the actual ings?
                        -- Since ingredients can't be repeated, prereq.inds should only have one element
                        local ind_of_ing
                        for ind, _ in pairs(prereq_node.inds) do
                            if ind_of_ing == nil then
                                ind_of_ing = ind
                            else
                                error()
                            end
                        end
                        assert(ind_of_ing ~= nil)
                        -- Now go to the vanilla recipe to fetch the ingredient
                        local ing_recipe = data.raw.recipe[ing_recipe_node.name]
                        table.insert(potential_ings, candidate_entry(ing_recipe.ingredients[ind_of_ing], prereq_owner))
                    end
                end

                -- Find ingredients to not switch out, and put them last
                local unrandomized_ings = {}
                local reordered_ings_randomized = {}
                local reordered_ings_unrandomized = {}
                for ind, ing in pairs(dependent_recipe.ingredients or {}) do
                    if is_unrandomized_ing(ind, is_result_of_this_recipe, dependent_recipe) then
                        table.insert(unrandomized_ings, ing)
                        table.insert(reordered_ings_unrandomized, ing)
                    else
                        table.insert(reordered_ings_randomized, ing)
                    end
                end
                -- Find new fluid indices
                local is_fluid_index = {}
                for ing_ind, ing in pairs(reordered_ings_randomized) do
                    if ing.type == "fluid" then
                        is_fluid_index[ing_ind] = true
                    end
                end
                for ing_ind, ing in pairs(reordered_ings_unrandomized) do
                    if ing.type == "fluid" then
                        is_fluid_index[#reordered_ings_randomized + ing_ind] = true
                    end
                end

                -- TODO: Should I put in part about not preserving resource costs post-nauvis or for final products?
                -- I decided to leave that part out here

                -- Finally, search for the best ingredients
                -- forms: the slots to fill as a list of "item"/"fluid" (recipe shapes, see lib/recipe-shape.lua), or nil for vanilla's own slots
                local function search(ings, forms)
                    return cost_lib.search_for_ings(table.deepcopy(ings), #reordered_ings_randomized, vanilla_recipe_costs, randomized_material_costs, {
                        unrandomized_ings = table.deepcopy(unrandomized_ings),
                        is_fluid_index = is_fluid_index,
                        slot_forms = forms,
                        fluid_amount_cap = fluid_amount_cap,
                        dont_preserve_resource_costs = dont_preserve_resource_costs,
                        starting_planet_reachable = starting_planet_reachable,
                        novelty = novelty_in(context, tier_name),
                    })
                end
                -- At a chunk boundary (debt mode: the recipe owes something only through its ingredients, see skeleton/promotion.lua), first search among ingredients that pay for it
                local paying_contexts = (prom ~= nil and #required_contexts > 0) and prom.recipe_boundary_contexts(dep, required_contexts) or {}
                local paying_info = {
                    prereq_list = {},
                    prereq_inds = {},
                }
                local paying_ings = {}
                if #paying_contexts > 0 then
                    for i, prereq in pairs(valid_prereq_list_info.prereq_list) do
                        if prom.pays(dep, key(gutils.get_owner(random_graph, random_graph.nodes[prereq])), paying_contexts) then
                            table.insert(paying_info.prereq_list, prereq)
                            table.insert(paying_info.prereq_inds, valid_prereq_list_info.prereq_inds[i])
                            table.insert(paying_ings, potential_ings[i])
                        end
                    end
                end
                -- The search for one set of slots: its result (or the failure's reason), the candidate list it came from, and whether the paying ingredients gave it
                local all_info = valid_prereq_list_info
                local function search_slots(forms)
                    if #paying_ings > 0 then
                        local paying_search_info = search(paying_ings, forms)
                        if type(paying_search_info) ~= "string" then
                            return paying_search_info, paying_info, true
                        end
                    end
                    return search(potential_ings, forms), all_info, false
                end
                local best_search_info
                -- The slots the result filled when the recipe has a planned shape: the search falls down the plan's ladder to vanilla's shape (recipe_shape.ladder) before giving up
                local used_forms
                local plan = recipe_shape.planned(dependent_recipe.name)
                if not slot_cost_known then
                    best_search_info = "No vanilla cost to compare ingredients against."
                elseif plan ~= nil then
                    local kept = recipe_shape.count_forms(unrandomized_ings)
                    local rungs = recipe_shape.ladder(plan)
                    for rung_ind = 1, #rungs do
                        local forms = recipe_shape.slot_forms(rungs[rung_ind], kept)
                        if forms ~= nil then
                            local info, list_info, paid = search_slots(forms)
                            if type(info) ~= "string" then
                                best_search_info = info
                                valid_prereq_list_info = list_info
                                used_forms = forms
                                if paid then
                                    num_paying = num_paying + 1
                                end
                                if rung_ind > 1 then
                                    shape_stats.rungs_fallen = shape_stats.rungs_fallen + 1
                                end
                                break
                            end
                            best_search_info = info
                        end
                    end
                    if best_search_info == nil then
                        best_search_info = "No shape holds the kept ingredients."
                    end
                else
                    local info, list_info, paid = search_slots(nil)
                    best_search_info = info
                    if type(info) ~= "string" then
                        valid_prereq_list_info = list_info
                        if paid then
                            num_paying = num_paying + 1
                        end
                    end
                end
                -- Test for failure
                local is_fallback = false
                if type(best_search_info) == "string" then
                    if prom == nil then
                        log("Recipe randomization failed")
                        return false
                    end
                    -- Fall back to vanilla ingredients, which promotion guarantees are valid in every promised context
                    log("Recipe randomization failed (" .. best_search_info .. "); falling back to vanilla ingredients")
                    num_fallbacks = num_fallbacks + 1
                    is_fallback = true
                    best_search_info = {
                        ings = table.deepcopy(slot_recipe.ingredients or {}),
                        inds = {},
                    }
                end

                -- How many of the result's ingredients the search chose, the kept ones coming after them
                local num_randomized = #reordered_ings_randomized
                if used_forms ~= nil then
                    num_randomized = #used_forms
                end

                -- Update dependencies
                local new_owner_keys = {}
                for index_in_best_search_info, ing in pairs(best_search_info.ings) do
                    -- In this case, this is an unrandomized ing
                    if is_fallback or index_in_best_search_info > num_randomized then
                        table.insert(dependent_to_new_ings[dependent_recipe.name], ing)
                        take(dependent_recipe, ing)
                        -- Unrandomized ings that aren't randomized edges (e.g. blacklisted) stay as fixed prereqs, so have no owner here
                        if prom ~= nil then
                            local owner_key = prom.vanilla_owner(dep, ing)
                            if owner_key ~= nil then
                                table.insert(new_owner_keys, owner_key)
                            end
                        end
                    else
                        local prereq_ind_of_ing = valid_prereq_list_info.prereq_inds[best_search_info.inds[index_in_best_search_info]]
                        local prereq_of_ing = shuffled_prereqs[prereq_ind_of_ing]
                        local prereq_owner = get_material_owner(random_graph, random_graph.nodes[prereq_of_ing])

                        -- The form was the search's; the game's ingredient carries the position, which item reflection renames
                        ing.form = nil
                        table.insert(dependent_to_new_ings[dependent_recipe.name], ing)
                        table.insert(new_owner_keys, key(gutils.get_owner(random_graph, random_graph.nodes[prereq_of_ing])))
                        ind_to_used[prereq_ind_of_ing] = true
                        -- Add prereq to end of shuffled_prereqs (doing with replacement)
                        table.insert(shuffled_prereqs, prereq_of_ing)
                        take(dependent_recipe, prereq_owner)
                    end
                end
                -- Its ingredients are taken now, so what was held for its fallback is free again
                release(dependent_recipe)

                if prom ~= nil and #required_contexts > 0 then
                    prom.resolve(dep, new_owner_keys, required_contexts)
                elseif prom ~= nil then
                    prom.record_ingredients(dep, new_owner_keys)
                end
                -- Pins on fixed prereqs (not randomized edges) are kept anyway
                for material_key, _ in pairs(current_pins) do
                    local kept = prom.vanilla_owner(dep, gutils.deconstruct(material_key)) == nil
                    for _, owner_key in pairs(new_owner_keys) do
                        if owner_key == material_key then
                            kept = true
                        end
                    end
                    if not kept then
                        error("Recipe " .. dep .. " dropped pinned ingredient " .. material_key)
                    end
                end
                current_pins = {}

                do
                    local is_old_ing = {}
                    for _, ing in pairs(slot_recipe.ingredients or {}) do
                        is_old_ing[key(ing)] = true
                    end
                    for _, ing in pairs(best_search_info.ings) do
                        num_ings = num_ings + 1
                        if is_old_ing[key(ing)] == nil then
                            num_changed_ings = num_changed_ings + 1
                        end
                        new_newer_share = new_newer_share + (novelty_in(context, tier_name)[flow_cost.get_prot_id(ing)] or 0)
                    end
                    for _, ing in pairs(slot_recipe.ingredients or {}) do
                        old_newer_share = old_newer_share + (novelty_in(context, tier_name)[flow_cost.get_prot_id(ing)] or 0)
                    end
                    if not is_fallback and vanilla_recipe_costs ~= nil then
                        local new_costs = cost_lib.get_costs_from_ings(randomized_material_costs, best_search_info.ings)
                        if new_costs.aggregate_cost > 0 and vanilla_recipe_costs.aggregate_cost > 0 then
                            cost_drift = cost_drift + math.abs(math.log(new_costs.aggregate_cost / vanilla_recipe_costs.aggregate_cost))
                            num_drift = num_drift + 1
                        end
                    end
                end

                -- How the shapes came out, for the RECIPESHAPES lines
                if shape_stats ~= nil then
                    local before = recipe_shape.count_forms(slot_recipe.ingredients or {})
                    local after = recipe_shape.count_forms(best_search_info.ings)
                    shape_stats.before_counts[before.count] = (shape_stats.before_counts[before.count] or 0) + 1
                    shape_stats.before_fluids[before.num_fluids] = (shape_stats.before_fluids[before.num_fluids] or 0) + 1
                    shape_stats.after_counts[after.count] = (shape_stats.after_counts[after.count] or 0) + 1
                    shape_stats.after_fluids[after.num_fluids] = (shape_stats.after_fluids[after.num_fluids] or 0) + 1
                    shape_stats.slots_before = shape_stats.slots_before + before.count
                    shape_stats.fluid_slots_before = shape_stats.fluid_slots_before + before.num_fluids
                    shape_stats.slots_after = shape_stats.slots_after + after.count
                    shape_stats.fluid_slots_after = shape_stats.fluid_slots_after + after.num_fluids
                    if before.num_fluids > 0 then
                        shape_stats.with_fluid_before = shape_stats.with_fluid_before + 1
                    end
                    if after.num_fluids > 0 then
                        shape_stats.with_fluid_after = shape_stats.with_fluid_after + 1
                    end
                    for _, ing in pairs(best_search_info.ings) do
                        if ing.type == "fluid" then
                            shape_stats.fluid_uses[ing.name] = (shape_stats.fluid_uses[ing.name] or 0) + 1
                        end
                    end
                end

                -- No need to update reachability
                -- Get rid of blacklisted property
                table.remove(dependent_to_new_ings[dependent_recipe.name], 1)
                -- Generated recycling becomes available with the current ingredients of its source recipe.
                update_staged(staged_world, randomized_item_recipe_maps, randomized_sets, dependent_to_new_ings, dependent_recipe.name)
            end
        end
    end

    log(string.format("RECIPESTATS recipes=%d mean_valid_prereqs=%.1f changed_ings=%d/%d", num_processed, total_valid_prereqs / math.max(num_processed, 1), num_changed_ings, num_ings))
    do
        local judged = {}
        for context, _ in pairs(judged_contexts) do
            table.insert(judged, context)
        end
        table.sort(judged)
        log("RECIPESTATS judged in rooms: " .. table.concat(judged, ", "))
        log(string.format("RECIPESTATS newer resources in ingredients: %.1f before, %.1f after (summed shares); ingredient cost drift %.3f (mean abs log ratio over %d recipes)", old_newer_share, new_newer_share, cost_drift / math.max(num_drift, 1), num_drift))
    end
    if shape_stats ~= nil then
        log(string.format("RECIPESHAPES result: fluid slots %d of %d (vanilla %d of %d); recipes with a fluid %d (vanilla %d); counts vanilla %s, now %s; fluids vanilla %s, now %s; %d searches fell down their ladder",
            shape_stats.fluid_slots_after, shape_stats.slots_after, shape_stats.fluid_slots_before, shape_stats.slots_before,
            shape_stats.with_fluid_after, shape_stats.with_fluid_before,
            recipe_shape.describe(shape_stats.before_counts), recipe_shape.describe(shape_stats.after_counts),
            recipe_shape.describe(shape_stats.before_fluids), recipe_shape.describe(shape_stats.after_fluids),
            shape_stats.rungs_fallen))
        local names = {}
        for name, _ in pairs(shape_stats.fluid_uses) do
            table.insert(names, name)
        end
        table.sort(names, function(a, b)
            if shape_stats.fluid_uses[a] ~= shape_stats.fluid_uses[b] then
                return shape_stats.fluid_uses[a] > shape_stats.fluid_uses[b]
            end
            return a < b
        end)
        local parts = {}
        for _, name in pairs(names) do
            table.insert(parts, name .. " " .. shape_stats.fluid_uses[name])
        end
        log("RECIPESHAPES fluid uses: " .. table.concat(parts, ", "))
    end
    if prom ~= nil then
        prom.log_pins()
        local unreachable = prom.anchor_remaining_recipes()
        -- For skeleton/check.lua: what promotion claims will be reachable
        UNIFIED_PROMISED_PEBBLES = prom.promised_pebbles()
        log("Promotion: done; promised " .. prom.num_promised .. " pebbles total; " .. num_fallbacks .. " recipes fell back to vanilla ingredients; " .. #unreachable .. " other recipes can no longer be reached; " .. num_paying .. " recipes at chunk boundaries took ingredients that pay for them")
        for _, recipe_key in pairs(unreachable) do
            log("Promotion: unreachable recipe " .. recipe_key)
        end
        if #unreachable > 0 then
            return false
        end
    end
end

recipe_ingredients.validate = function(graph, base, head, extra)
    local base_owner = get_material_owner(graph, base)
    if base_owner.type ~= "fluid" and base_owner.type ~= "item" then
        return false
    end

    -- Only allow fluids in fluid bases and items in item bases for now
    local old_prereq = get_material_owner(graph, graph.nodes[head.old_base])
    if old_prereq.type ~= base_owner.type then
        return false
    end

    -- Otherwise, we're probably okay for now
    return true
end

recipe_ingredients.reflect = function(graph, head_to_base, head_to_handler)
    for recipe_name, ings in pairs(dependent_to_new_ings) do
        local recipe = data.raw.recipe[recipe_name]

        -- Remove blacklisted for recipes without cost
        if ings[1] == "blacklisted" then
            table.remove(ings, 1)
        end

        -- TODO: Maybe investigate whether the deepcopy is necessary
        recipe.ingredients = table.deepcopy(ings)
    end

    -- Final check to remove duplicate ingredients
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.ingredients ~= nil then
            local already_seen = {}
            for i = #recipe.ingredients, 1, -1 do
                local ing = recipe.ingredients[i]
                if already_seen[ing.type .. "-" .. ing.name] then
                    table.remove(recipe.ingredients, i)
                else
                    already_seen[ing.type .. "-" .. ing.name] = true
                end
            end
        end
    end
    -- Now go through and make ingredient amounts 1 if thing isn't stackable
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.ingredients ~= nil then
            for _, ing in pairs(recipe.ingredients) do
                if ing.type == "item" then
                    local item = dutils.get_prot("item", ing.name)
                    if not dutils.is_stackable(item) then
                        ing.amount = 1
                    end
                end
            end
        end
    end
end

return recipe_ingredients

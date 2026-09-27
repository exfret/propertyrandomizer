-- File for any last-minute fixes in the randomization process that may be needed

local locale_utils = require("lib/locale")
local dutils = require("lib/data-utils")
local gutils = require("lib/graph/graph-utils")
local logic = require("lib/logic/init")
local top = require("lib/graph/context-sort")
-- Needed for recipe icons logic
local dupe = require("lib/dupe")
local recycling_lib = require("lib/recycling")
local recycling_sources_lib = require("lib/logic/recycling-sources")

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
    if mods["pyalternativeenergy"] then
        with_tech_sort_info = nil
        -- For py specifically, sort based on sciences now, since tiers are very important in py
        local packs_in_order = {
            "automation-science-pack",
            "py-science-pack-1",
            "logistic-science-pack",
            "military-science-pack",
            "py-science-pack-2",
            "chemical-science-pack",
            "py-science-pack-3",
            "production-science-pack",
            "py-science-pack-4",
            "utility-science-pack",
            "space-science-pack",
            "full-pyrrhic-victory",
        }
        local graph_for_init_sort = table.deepcopy(graph)
        local packs_to_deps = {}
        local deps_to_falses = {}
        for i = 1, #packs_in_order - 1 do
            local science_node = graph_for_init_sort.nodes[gutils.key("item", packs_in_order[i])]
            packs_to_deps[packs_in_order[i]] = {}
            local deps_to_remove = {}
            for dep, _ in pairs(science_node.dep) do
                table.insert(deps_to_remove, dep)
                local edge = graph_for_init_sort.edges[dep]
                table.insert(packs_to_deps[packs_in_order[i]], {edge.start, edge.stop, dep})
            end
            for _, dep in pairs(deps_to_remove) do
                local false_node = graph_for_init_sort.nodes[gutils.key("false", science_node.name)]
                if false_node == nil then
                    false_node = gutils.add_node(graph_for_init_sort, "false", science_node.name)
                    false_node.op = "OR"
                end
                deps_to_falses[dep] = gutils.add_edge(graph_for_init_sort, gutils.key(false_node), graph_for_init_sort.edges[dep].stop)
                gutils.remove_edge(graph_for_init_sort, dep)
            end
        end
        with_tech_sort_info = top.sort(graph_for_init_sort, nil, nil, { choose_randomly = true })
        for i = 1, #packs_in_order - 1 do
            for _, edge_info in pairs(packs_to_deps[packs_in_order[i]]) do
                local false_edge = deps_to_falses[edge_info[3]]
                gutils.remove_edge(graph_for_init_sort, gutils.ekey(false_edge))
                gutils.add_edge(graph_for_init_sort, edge_info[1], edge_info[2])
                with_tech_sort_info = top.sort(graph_for_init_sort, with_tech_sort_info, {graph_for_init_sort.nodes[edge_info[1]], graph_for_init_sort.nodes[edge_info[2]]}, { choose_randomly = true, do_new_edge_processing = true })
            end
        end
    end
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
    -- A recipe the sort above never reached an unlocking tech for (its tech is unreachable, or only unlocked through a count_formula tech) still costs what some tech unlocking it costs, so it doesn't start enabled
    -- A count_formula unit is copied as is: the rebuilt tech's name doesn't end in a level number, so the formula is taken at level 1 (TechnologyUnit.count_formula)
    local tech_names = {}
    for tech_name, _ in pairs(data.raw.technology) do
        table.insert(tech_names, tech_name)
    end
    table.sort(tech_names)
    for _, tech_name in pairs(tech_names) do
        local tech = data.raw.technology[tech_name]
        local num_recipe_unlocks = 0
        for _, effect in pairs(tech.effects or {}) do
            if effect.type == "unlock-recipe" then
                num_recipe_unlocks = 1 + num_recipe_unlocks
            end
        end
        for _, effect in pairs(tech.effects or {}) do
            if effect.type == "unlock-recipe" and recipe_to_unit[effect.recipe] == nil and recipe_to_research_trigger[effect.recipe] == nil then
                if tech.unit ~= nil then
                    recipe_to_unit[effect.recipe] = table.deepcopy(tech.unit)
                    if tech.unit.count ~= nil then
                        recipe_to_unit[effect.recipe].count = math.ceil(1 / num_recipe_unlocks * tech.unit.count)
                    end
                elseif tech.research_trigger ~= nil then
                    recipe_to_research_trigger[effect.recipe] = table.deepcopy(tech.research_trigger)
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
    if mods["pyalternativeenergy"] then
        no_tech_sort_info = nil
        -- For py specifically, sort based on sciences now, since tiers are very important in py
        local packs_in_order = {
            "automation-science-pack",
            "py-science-pack-1",
            "logistic-science-pack",
            "military-science-pack",
            "py-science-pack-2",
            "chemical-science-pack",
            "py-science-pack-3",
            "production-science-pack",
            "py-science-pack-4",
            "utility-science-pack",
            "space-science-pack",
            "full-pyrrhic-victory",
        }
        local graph_for_init_sort = table.deepcopy(graph)
        local packs_to_deps = {}
        local deps_to_falses = {}
        for i = 1, #packs_in_order - 1 do
            local science_node = graph_for_init_sort.nodes[gutils.key("item", packs_in_order[i])]
            packs_to_deps[packs_in_order[i]] = {}
            local deps_to_remove = {}
            for dep, _ in pairs(science_node.dep) do
                table.insert(deps_to_remove, dep)
                local edge = graph_for_init_sort.edges[dep]
                table.insert(packs_to_deps[packs_in_order[i]], {edge.start, edge.stop, dep})
            end
            for _, dep in pairs(deps_to_remove) do
                local false_node = graph_for_init_sort.nodes[gutils.key("false", science_node.name)]
                if false_node == nil then
                    false_node = gutils.add_node(graph_for_init_sort, "false", science_node.name)
                    false_node.op = "OR"
                end
                deps_to_falses[dep] = gutils.add_edge(graph_for_init_sort, gutils.key(false_node), graph_for_init_sort.edges[dep].stop)
                gutils.remove_edge(graph_for_init_sort, dep)
            end
        end
        no_tech_sort_info = top.sort(graph_for_init_sort, nil, nil, { choose_randomly = true })
        for i = 1, #packs_in_order - 1 do
            for _, edge_info in pairs(packs_to_deps[packs_in_order[i]]) do
                local false_edge = deps_to_falses[edge_info[3]]
                gutils.remove_edge(graph_for_init_sort, gutils.ekey(false_edge))
                gutils.add_edge(graph_for_init_sort, edge_info[1], edge_info[2])
                no_tech_sort_info = top.sort(graph_for_init_sort, no_tech_sort_info, {graph_for_init_sort.nodes[edge_info[1]], graph_for_init_sort.nodes[edge_info[2]]}, { choose_randomly = true, do_new_edge_processing = true })
            end
        end
    end

    -- The recipes the pebble at ind directly needs: the recipes on its witness, not looking past them
    local function prev_recipes_of(ind)
        local path_info = top.path(graph, {ind}, no_tech_sort_info, {
            stop_if = function(pebble)
                local node = graph.nodes[pebble.node_key]
                if node.type == "recipe" then
                    return true
                end
            end,
        })
        local prev_recipes = {}
        for other_node_ind, _ in pairs(path_info.in_path) do
            -- Don't count ind itself
            if other_node_ind < ind then
                local other_node_key = no_tech_sort_info.sorted[other_node_ind].node_key
                local other_node = graph.nodes[other_node_key]
                if other_node.type == "recipe" then
                    prev_recipes[other_node.name] = true
                end
            end
        end
        return prev_recipes
    end

    -- Techs that unlock a space location (planet discovery), which keep their place in progression instead of getting a random prereq below
    local function unlocks_space_location(tech)
        for _, effect in pairs(tech.effects or {}) do
            if effect.type == "unlock-space-location" then
                return true
            end
        end
        return false
    end

    local recipe_to_prev = {}
    local space_location_tech_to_prev = {}
    for ind, node_info in pairs(no_tech_sort_info.sorted) do
        local node = graph.nodes[node_info.node_key]
        if node.type == "recipe" and recipe_to_prev[node.name] == nil then
            recipe_to_prev[node.name] = prev_recipes_of(ind)
        elseif node.type == "technology" and space_location_tech_to_prev[node.name] == nil and data.raw.technology[node.name] ~= nil and unlocks_space_location(data.raw.technology[node.name]) then
            space_location_tech_to_prev[node.name] = prev_recipes_of(ind)
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
            -- A recipe no tech unlocks at all gets no tech and stays disabled, as it was (enabling it would hand the player something the game never gave)
            if recipe_to_unit[recipe_name] ~= nil then
                new_tech.unit = recipe_to_unit[recipe_name]
            elseif recipe_to_research_trigger[recipe_name] ~= nil then
                new_tech.research_trigger = recipe_to_research_trigger[recipe_name]
            end
            if new_tech.unit ~= nil or new_tech.research_trigger ~= nil then
                data:extend({
                    new_tech
                })
            end
        end
    end

    -- Add prereqs back to non-unlock recipes
    for _, tech in pairs(data.raw.technology) do
        if not is_new_tech[tech.name] and tech.name ~= "pyrrhic" then
            if space_location_tech_to_prev[tech.name] ~= nil then
                -- A planet unlock comes as early as it can be researched: right after the rebuilt techs of the recipes it needs (its science packs), keeping its own science packs
                -- A random prereq could need the planet itself (like one of its science packs), which would make the planet undiscoverable
                local prereqs = {}
                for prev_recipe_name, _ in pairs(space_location_tech_to_prev[tech.name]) do
                    if data.raw.technology["exfret-rebuilt-" .. prev_recipe_name .. "-suffix"] ~= nil then
                        table.insert(prereqs, "exfret-rebuilt-" .. prev_recipe_name .. "-suffix")
                    end
                end
                table.sort(prereqs)
                tech.prerequisites = prereqs
            else
                local prereq = data.raw.technology[new_techs_with_unit[math.random(1, #new_techs_with_unit)]]
                tech.prerequisites = { prereq.name }
                if tech.unit ~= nil then
                    tech.unit.ingredients = prereq.unit.ingredients
                end
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

        if DO_FRODO_FIXES then
            -- Make things with lower tech cost not depend on things with higher tech cost
            -- This fixes some of how recipe category rando puts automation in later science packs than it should
            local tech_to_deps = {}
            for _, tech in pairs(data.raw.technology) do
                tech_to_deps[tech.name] = tech_to_deps[tech.name] or {}
                for _, prereq in pairs(tech.prerequisites or {}) do
                    tech_to_deps[prereq] = tech_to_deps[prereq] or {}
                    tech_to_deps[prereq][tech.name] = true
                end
            end
            logic.build(true)
            local sort_for_tech_pack_fixes = top.sort(logic.graph, nil, nil, { choose_randomly = true })
            for i = #sort_for_tech_pack_fixes.sorted, 1, -1 do
                local pebble = sort_for_tech_pack_fixes.sorted[i]
                local node = logic.graph.nodes[pebble.node_key]
                if node.type == "technology" then
                    local tech = data.raw.technology[node.name]
                    if tech.unit ~= nil then
                        -- Take intersection of ingredients of this tech and deps
                        local is_ing = {}
                        for _, ing in pairs(tech.unit.ingredients) do
                            is_ing[ing[1]] = true
                        end
                        for dep, _ in pairs(tech_to_deps[tech.name]) do
                            local dep_tech = data.raw.technology[dep]
                            if dep_tech.unit ~= nil then
                                local dep_ings = {}
                                for _, dep_ing in pairs(dep_tech.unit.ingredients) do
                                    dep_ings[dep_ing[1]] = true
                                end
                                local new_is_ing = {}
                                for ing, _ in pairs(is_ing) do
                                    if dep_ings[ing] then
                                        new_is_ing[ing] = true
                                    end
                                end
                                is_ing = new_is_ing
                            end
                        end
                        local new_tech_ings = {}
                        for _, ing in pairs(tech.unit.ingredients) do
                            if is_ing[ing[1]] then
                                table.insert(new_tech_ings, ing)
                            end
                        end
                        tech.unit.ingredients = new_tech_ings
                    end
                end
            end
        end
    end
end

-- Recycling recipes as the recycler would generate them from the game as it is now (see lib/recycling.lua)
-- Which recipe each one inverts stays the vanilla one while it still makes the item (lib/logic/recycling-sources.lua), the same mapping promotion uses for derived recycling edges
randomizations.fix_recycling_recipes = function()
    recycling_lib.regenerate(old_data_raw)
end

-- Vanilla names and draws a recycling recipe after the item it recycles, so one whose ingredient item randomization changed follows its new item
-- Item randomization leaves these recipes' names alone (see recycling_sources.named_after_ingredient), so this runs after all of it
randomizations.fix_recycling_names = function()
    -- The recycler's icon generator (recycler/recycling.lua), a global in the prototype stage's shared Lua state
    local generate_icons = generate_recycling_recipe_icons_from_item
    for recipe_name, recipe in pairs(data.raw.recipe) do
        local old_ingredient = recycling_sources_lib.named_after_ingredient(old_data_raw.recipe, recipe_name)
        if old_ingredient ~= nil and recipe.ingredients ~= nil and #recipe.ingredients == 1 and recipe.ingredients[1].type == "item" and recipe.ingredients[1].name ~= old_ingredient then
            local item = dutils.get_prot("item", recipe.ingredients[1].name)
            -- Same name as the recycler gives its recycling recipes
            recipe.localised_name = {"recipe-name.recycling", locale_utils.find_localised_name(item)}
            if generate_icons ~= nil then
                recipe.icon = nil
                recipe.icons = generate_icons(item)
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

    -- Recipes with fluids leave hand crafting's category, and mining drills can put out what their resources give (see lib/fluid-ports.lua), with items and fluids trading positions
    if config.item_fluids then
        local fluid_ports = require("lib/fluid-ports")
        local num_recategorized = fluid_ports.fix_fluid_crafting_categories()
        local num_drills_fitted = fluid_ports.fit_mining_drills()
        if num_recategorized > 0 or num_drills_fitted > 0 then
            log("Fluid fixes: " .. num_recategorized .. " recipes with fluids left hand crafting's category, " .. num_drills_fitted .. " mining drills fitted to what their resources give")
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
            -- Change radar to be earlier since not having radar so long isn't really an interesting challenge
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

            -- Make new reproductive complexes to avoid the scripting things for them I didn't account for
            for _, machine in pairs(data.raw["assembling-machine"]) do
                local is_reproductive_complex = false
                for _, cat in pairs(machine.crafting_categories) do
                    if cat == "rc" then
                        is_reproductive_complex = true
                    end
                end
                if is_reproductive_complex then
                    local new_complex = table.deepcopy(machine)
                    new_complex.name = "new-" .. machine.name
                    new_complex.localised_name = locale_utils.find_localised_name(machine)
                    new_complex.crafting_categories = {"parameters", "new-rc"}
                    -- Check for items placing this
                    for item_class, _ in pairs(defines.prototypes.item) do
                        for _, item in pairs(data.raw[item_class] or {}) do
                            if item.place_result == machine.name then
                                item.place_result = new_complex.name
                            end
                        end
                    end
                    machine.next_upgrade = nil
                    -- Modify the old data raw version too for the derandomization feature
                    old_data_raw_for_derandomization[machine.type][machine.name].next_upgrade = nil
                    if new_complex.next_upgrade ~= nil then
                        new_complex.next_upgrade = "new-" .. new_complex.next_upgrade
                    end
                    data:extend({
                        new_complex
                    })
                end
            end
            local rc_cat_copy = table.deepcopy(data.raw["recipe-category"].rc)
            rc_cat_copy.name = "new-" .. rc_cat_copy.name
            for _, recipe in pairs(data.raw.recipe) do
                local has_reproductive_cat = false
                for _, cat in pairs(recipe.categories or {}) do
                    if cat == "rc" then
                        has_reproductive_cat = true
                    end
                end
                if has_reproductive_cat then
                    table.insert(recipe.categories, rc_cat_copy.name)
                end
            end
            data:extend({
                rc_cat_copy
            })
            -- Signals
            data.raw.recipe["grade-4-chromite"].ingredients = {{type = "item", name = "iron-plate", amount = 10}}
            data.raw.recipe["grade-4-chromite"].enabled = true
            data.raw.recipe["grade-4-chromite"].categories = nil
            data.raw.recipe["quartz-crucible"].ingredients = {{type = "item", name = "iron-plate", amount = 10}}
            data.raw.recipe["quartz-crucible"].enabled = true
            data.raw.recipe["quartz-crucible"].categories = nil
            -- Locomotive
            data.raw.recipe["gobachov"].ingredients = {{type = "item", name = "iron-plate", amount = 10}}
            data.raw.recipe["gobachov"].enabled = true
            data.raw.recipe["gobachov"].categories = nil
            -- Wagons
            data.raw.recipe["zipir-improved-5"].ingredients = {{type = "item", name = "iron-plate", amount = 10}}
            data.raw.recipe["zipir-improved-5"].enabled = true
            data.raw.recipe["zipir-improved-5"].categories = nil
            data.raw.recipe["moondrop-seeds-mk04"].ingredients = {{type = "item", name = "iron-plate", amount = 10}}
            data.raw.recipe["moondrop-seeds-mk04"].enabled = true
            data.raw.recipe["moondrop-seeds-mk04"].categories = nil
            -- Train stop
            data.raw.recipe["ammonium-oxalate"].ingredients = {{type = "item", name = "iron-plate", amount = 10}}
            data.raw.recipe["ammonium-oxalate"].enabled = true
            data.raw.recipe["ammonium-oxalate"].categories = nil
            -- Rail
            data.raw.recipe["simik-tin"].ingredients = {{type = "item", name = "iron-plate", amount = 10}}
            data.raw.recipe["simik-tin"].enabled = true
            data.raw.recipe["simik-tin"].categories = nil
            -- Car
            data.raw.recipe["py-heat-exchanger-mk02"].ingredients = {{type = "item", name = "iron-plate", amount = 10}}
            data.raw.recipe["py-heat-exchanger-mk02"].enabled = true
            data.raw.recipe["py-heat-exchanger-mk02"].categories = nil
            -- Caravan outposts
            data.raw.recipe["cottongut-mk03"].ingredients = {{type = "item", name = "iron-plate", amount = 10}}
            data.raw.recipe["cottongut-mk03"].enabled = true
            data.raw.recipe["cottongut-mk03"].categories = nil
            data.raw.recipe["inductor3"].ingredients = {{type = "item", name = "iron-plate", amount = 10}}
            data.raw.recipe["inductor3"].enabled = true
            data.raw.recipe["inductor3"].categories = nil
            -- Caravans
            data.raw.recipe["arthurian-11"].ingredients = {{type = "item", name = "iron-plate", amount = 10}}
            data.raw.recipe["arthurian-11"].enabled = true
            data.raw.recipe["arthurian-11"].categories = nil
            data.raw.recipe["gearbox-mk01"].ingredients = {{type = "item", name = "iron-plate", amount = 10}}
            data.raw.recipe["gearbox-mk01"].enabled = true
            data.raw.recipe["gearbox-mk01"].categories = nil
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

    -- An item in a copy of data.raw (from), or nil
    local function item_in(from, item_name)
        for item_class, _ in pairs(defines.prototypes.item) do
            local item = (from[item_class] or {})[item_name]
            if item ~= nil then
                return item
            end
        end
        return nil
    end

    -- Whether graph randomization left alone what the item named like an entity places
    local function placement_unchanged(entity_name)
        local item = item_in(old_data_raw_for_derandomization, entity_name)
        if item == nil then
            return false
        end
        local unrandomized_item = item_in(old_data_raw, entity_name)
        return unrandomized_item ~= nil and item.place_result == unrandomized_item.place_result
    end

    -- Entity name --> names of the items that place it after graph randomization
    local placers_of = {}
    for item_class, _ in pairs(defines.prototypes.item) do
        for _, item in pairs(old_data_raw_for_derandomization[item_class] or {}) do
            if item.place_result ~= nil then
                placers_of[item.place_result] = placers_of[item.place_result] or {}
                placers_of[item.place_result][item.name] = true
            end
        end
    end

    -- The item that places an entity after graph randomization (entity randomization can give it to another item), or nil if none does
    -- Prefers the item the entity names in placeable_by or mines into, since entity randomization points those at the entity's main placer
    local function current_placer(entity)
        local placers = placers_of[entity.name] or {}
        local preferred = {}
        local placeable_by = entity.placeable_by
        if placeable_by ~= nil and placeable_by.item ~= nil then
            placeable_by = {
                placeable_by,
            }
        end
        for _, item_to_place in pairs(placeable_by or {}) do
            table.insert(preferred, item_to_place.item)
        end
        if entity.minable ~= nil then
            if entity.minable.result ~= nil then
                table.insert(preferred, entity.minable.result)
            end
            for _, product in pairs(entity.minable.results or {}) do
                table.insert(preferred, product.name)
            end
        end
        for _, item_name in pairs(preferred) do
            if placers[item_name] ~= nil then
                return item_name
            end
        end
        local names = {}
        for item_name, _ in pairs(placers) do
            table.insert(names, item_name)
        end
        table.sort(names)
        return names[1]
    end

    -- The item an entity's old version copies, and the item its recipe turns into the old version, or nil if it has no old version
    -- Usually both are the item named like the entity
    -- If entity randomization changed what that item places, the old version copies the item as it was before graph randomization instead, so it doesn't take on the change
    local function old_version_items(entity)
        if placement_unchanged(entity.name) then
            return item_in(old_data_raw_for_derandomization, entity.name), entity.name
        end
        local unrandomized_item = item_in(old_data_raw, entity.name)
        if unrandomized_item == nil then
            return nil
        end
        -- The item placed the entity, which something else places now, so the recipe takes that
        if unrandomized_item.place_result == entity.name then
            local placer_name = current_placer(entity)
            if placer_name == nil then
                return nil
            end
            return unrandomized_item, placer_name
        end
        -- The entity was never placed (like a grenade's projectile, whose item places something else now as a spoof placer), so the recipe takes the item as usual
        return unrandomized_item, entity.name
    end

    -- Add any entity with a crafting recipe of the same name
    for entity_class, _ in pairs(defines.prototypes.entity) do
        for _, entity in pairs(old_data_raw_for_derandomization[entity_class] or {}) do
            local old_item
            local placer_name
            if old_data_raw_for_derandomization.recipe[entity.name] ~= nil and old_data_raw_for_derandomization.recipe[entity.name].results ~= nil and #old_data_raw_for_derandomization.recipe[entity.name].results == 1 and old_data_raw.recipe[entity.name].results[1].name == entity.name then
                old_item, placer_name = old_version_items(entity)
            end
            if old_item ~= nil then
                local copy = table.deepcopy(entity)
                copy.name = "old-" .. entity.name
                copy.localised_name = {"", locale_utils.find_localised_name(entity), " [color=154,61,0](Original!)[/color]"}
                copy.localised_description = "Just like old."
                -- Entity randomization can have the entity found in the wild (salvage), but its old version is only ever built
                copy.autoplace = nil
                local old_data_item
                for item_class, _ in pairs(defines.prototypes.item) do
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
                if item_copy.plant_result == entity.name then
                    item_copy.plant_result = copy.name
                end
                -- Mining the old version and blueprints of it give its own item instead of the entity's
                local function is_entity_item(item_name)
                    return item_name == old_item.name or item_name == placer_name
                end
                if copy.minable ~= nil then
                    if is_entity_item(copy.minable.result) then
                        copy.minable.result = copy.name
                    elseif copy.minable.results ~= nil then
                        for _, result in pairs(copy.minable.results) do
                            if is_entity_item(result.name) then
                                result.name = copy.name
                            end
                        end
                    end
                end
                if copy.placeable_by ~= nil then
                    if is_entity_item(copy.placeable_by.item) then
                        copy.placeable_by.item = copy.name
                    elseif copy.placeable_by.item == nil then
                        for _, placeable in pairs(copy.placeable_by) do
                            if is_entity_item(placeable.item) then
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
                        ingredients = {{type = "item", name = placer_name, amount = 1}},
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
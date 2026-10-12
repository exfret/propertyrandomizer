-- File for any last-minute fixes in the randomization process that may be needed

local locale_utils = require("lib/locale")
local fluid_ports = require("lib/fluid-ports")
local dutils = require("lib/data-utils")
local gutils = require("lib/graph/graph-utils")
local logic = require("lib/logic/init")
local top = require("lib/graph/context-sort")
-- Needed for recipe icons logic
local dupe = require("lib/dupe")
local surface_sets = require("lib/surface-sets")
local recycling_lib = require("lib/recycling")
local recycling_sources_lib = require("lib/logic/recycling-sources")
local crafter_slots = require("lib/crafter-slots")
-- The recipes a rebuilt tech's prerequisites come from
local witness_recipes = require("lib/logic/witness-recipes")
local technology_abilities = require("lib/technology-abilities")
local operation_unlocks = require("lib/logic/operation-unlocks")
local technology_prerequisites = require("lib/technology-prerequisites")
local rebuild_unlocks = require("lib/rebuild-unlocks")
local trigger_promises = require("lib/technology-trigger-promises")
local rebuild_check = require("lib/rebuild-check")
-- A recipe one technology unlocks has that technology as a prerequisite, without unlock nodes in between
local unlock_contraction = require("lib/logic/unlock-contraction")
-- What each planet needs to get going from its own resources, which its discovery brings
local starting_recipes = require("lib/starting-recipes")

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

    logic.build()
    local graph = logic.graph
    -- The game before this rebuild, which the rebuilt one must keep (see rebuild_check below)
    -- Py's sorts have no room/ability contexts (see context_sort_info below), so py isn't checked
    local before_sort_info
    if not mods["pyalternativeenergy"] then
        before_sort_info = top.sort(graph, nil, nil, {
            complex_contexts = true,
            home_contexts = true,
        })
    end

    -- Initial top sort for determining science packs for recipes
    -- Also determines recipes for science packs (i.e.- what recipe techs will be marked essential)
    local recipe_to_unit = {}
    local recipe_to_research_trigger = {}
    -- The tech each recipe's unit or trigger comes from, whose contexts its rebuilt tech keeps (see covers below)
    local recipe_to_source_tech = {}
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
    -- Each recipe's research is copied from a technology unlocking it: the first one the sort reaches (then by name, for those it never reaches), except that a recipe only one planet makes takes it from that planet's own technologies (its discovery or those after it) when one unlocks it
    -- With planet copies, a copy's technologies unlock its family's recipes too (lib/dupe-planets.lua), so the first one reached can be another planet's: the original Gleba's lava scaffold (randomizations/planetary/scaffolds.lua) got Gleba 3's biochamber research, and once unified randomization had changed what that research needs, the recipe lost its isolatable contexts on Gleba, which leaving out prerequisites can't bring back
    local science_pack_marked = {}
    local is_essential_recipe = {}
    -- Recipe name --> the technologies unlocking it that have research to copy, in the order above
    local unlockers = {}
    local function add_unlocker(recipe_name, tech)
        unlockers[recipe_name] = unlockers[recipe_name] or {}
        for _, other in pairs(unlockers[recipe_name]) do
            if other == tech then
                return
            end
        end
        table.insert(unlockers[recipe_name], tech)
    end
    for _, pebble_key in pairs(with_tech_sort_info.pebble_keys) do
        local node = graph.nodes[pebble_key]
        if node.type == "technology" then
            local tech = data.raw.technology[node.name]
            -- CRITICAL TODO: Ignore techs right now with levels; we'll need to nuke them completely later
            --local isdigit = {["0"] = true, ["1"] = true, ["2"] = true, ["3"] = true, ["4"] = true, ["5"] = true, ["6"] = true, ["7"] = true, ["8"] = true, ["9"] = true}
            if (tech.unit ~= nil and tech.unit.count ~= nil) or tech.research_trigger ~= nil then
                for _, effect in pairs(tech.effects or {}) do
                    if effect.type == "unlock-recipe" then
                        add_unlocker(effect.recipe, tech)
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
        if tech.unit ~= nil or tech.research_trigger ~= nil then
            for _, effect in pairs(tech.effects or {}) do
                if effect.type == "unlock-recipe" and unlockers[effect.recipe] == nil then
                    add_unlocker(effect.recipe, tech)
                end
            end
        end
    end
    -- The planet's discovery technologies, and whether a technology is one or comes after one (its prerequisites, all the way down)
    local discoverers_of = {}
    for _, tech_name in pairs(tech_names) do
        for _, effect in pairs(data.raw.technology[tech_name].effects or {}) do
            if effect.type == "unlock-space-location" then
                discoverers_of[effect.space_location] = discoverers_of[effect.space_location] or {}
                discoverers_of[effect.space_location][tech_name] = true
            end
        end
    end
    local closure = {}
    local function needs(tech_name)
        if closure[tech_name] == nil then
            local needed = {}
            -- Stored first, so a prerequisite cycle ends here
            closure[tech_name] = needed
            for _, prerequisite in pairs((data.raw.technology[tech_name] or {}).prerequisites or {}) do
                needed[prerequisite] = true
                for further, _ in pairs(needs(prerequisite)) do
                    needed[further] = true
                end
            end
        end
        return closure[tech_name]
    end
    local function follows_discovery(tech_name, planet_name)
        for discoverer, _ in pairs(discoverers_of[planet_name] or {}) do
            if tech_name == discoverer or needs(tech_name)[discoverer] ~= nil then
                return true
            end
        end
        return false
    end
    -- The one planet that makes a recipe, or nil (a recipe several rooms make, or none); one without surface conditions is made everywhere
    local function only_planet(recipe)
        if next(recipe.surface_conditions or {}) == nil then
            return nil
        end
        local rooms = {}
        for room_key, _ in pairs(surface_sets.accepted(recipe)) do
            table.insert(rooms, room_key)
        end
        if #rooms ~= 1 then
            return nil
        end
        local room = gutils.deconstruct(rooms[1])
        if room.type ~= "planet" then
            return nil
        end
        return room.name
    end
    local num_research_from_own_planet = 0
    local unlocked_names = {}
    for recipe_name, _ in pairs(unlockers) do
        table.insert(unlocked_names, recipe_name)
    end
    table.sort(unlocked_names)
    for _, recipe_name in pairs(unlocked_names) do
        local candidates = unlockers[recipe_name]
        local source = candidates[1]
        local recipe = data.raw.recipe[recipe_name]
        local planet_name = recipe ~= nil and only_planet(recipe) or nil
        if planet_name ~= nil and not follows_discovery(source.name, planet_name) then
            for _, candidate in pairs(candidates) do
                if follows_discovery(candidate.name, planet_name) then
                    source = candidate
                    num_research_from_own_planet = num_research_from_own_planet + 1
                    break
                end
            end
        end
        local num_recipe_unlocks = 0
        for _, effect in pairs(source.effects or {}) do
            if effect.type == "unlock-recipe" then
                num_recipe_unlocks = 1 + num_recipe_unlocks
            end
        end
        if source.unit ~= nil then
            recipe_to_unit[recipe_name] = table.deepcopy(source.unit)
            if source.unit.count ~= nil then
                recipe_to_unit[recipe_name].count = math.ceil(1 / num_recipe_unlocks * source.unit.count)
            end
        else
            recipe_to_research_trigger[recipe_name] = table.deepcopy(source.research_trigger)
        end
        recipe_to_source_tech[recipe_name] = source.name
    end
    log("Tech tree rebuild: " .. num_research_from_own_planet .. " recipes only one planet makes take their research from that planet's technologies rather than the first one reached")

    -- A second rebuild keeps the existing per-recipe technology as its primary source.
    -- Otherwise that technology could be retained as an alternate and then overwritten below.
    for recipe_name, _ in pairs(recipe_to_source_tech) do
        local name = "exfret-rebuilt-" .. recipe_name .. "-suffix"
        local technology = data.raw.technology[name]
        for _, effect in pairs(technology and technology.effects or {}) do
            if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
                recipe_to_source_tech[recipe_name] = name
                recipe_to_unit[recipe_name] = table.deepcopy(technology.unit)
                recipe_to_research_trigger[recipe_name] = table.deepcopy(technology.research_trigger)
                break
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

    -- A tech needs all its prerequisites, so a prerequisite without some context the tech has takes that context away
    -- Like a Fulgora-only tech under one every planet's discovery makes isolatable: the lightning rod's tech lost isolatability on Fulgora that way
    -- So a prerequisite is only kept if its tech has the contexts that matter in the sort without tech prerequisites, and then each rebuilt tech keeps the contexts its unit or trigger gives it
    -- Witnesses still come from the earliest pebbles above, so prerequisites never wait on anything the recipe isn't already reached without; a witness of a later pebble (like an isolatable one) can need a tech whose own science packs need the recipe
    -- Py's sorts have no room/ability contexts, so there every prerequisite is kept
    local context_sort_info
    if not mods["pyalternativeenergy"] then
        context_sort_info = top.sort(graph, nil, nil, {
            complex_contexts = true,
            home_contexts = true,
        })
    end
    -- Whether prereq_tech_name's tech can be a prerequisite of tech_name's without taking away a context that matters
    -- For a rebuilt tech (recipe_name given), those are the contexts where its recipe can be made: elsewhere the tech unlocks nothing, so it can wait there, and what other techs need from it there is checked in the rebuilt game (rebuild_check below)
    -- Otherwise (techs the logic needs, see logic_needs below) every context of the tech counts
    -- Only the prerequisite's tech is compared, not its recipe: the tech waits for that tech, and the recipe can come later (in vanilla's logic, sulfur is automatable on Nauvis before the chemical plant recipe is)
    -- Whether a tech's research gives it a context by itself in the sort without tech prerequisites, rather than only through the discovery rule's home context (see top.discovery_candidates)
    local gives_directly_memo = {}
    local function gives_directly(tech_name, context)
        local memo_key = tech_name .. " / " .. context
        if gives_directly_memo[memo_key] == nil then
            local node = graph.nodes[gutils.key("technology", tech_name)]
            local direct = node ~= nil
            for pre, _ in pairs(node ~= nil and node.pre or {}) do
                local edge = graph.edges[pre]
                local sends = false
                for _, source in pairs(top.edge_source_contexts(context_sort_info, edge, context)) do
                    if (context_sort_info.node_to_context_inds[edge.start] or {})[source] ~= nil then
                        sends = true
                    end
                end
                direct = direct and sends
            end
            gives_directly_memo[memo_key] = direct
        end
        return gives_directly_memo[memo_key]
    end
    -- The home context of a tech's contexts that the discovery rule gives an isolatable context through: the one for the home set of the context's room, or nil
    -- Techs send home contexts to every room, so the first by number stands for them all
    local function rule_home_context(tech_contexts, context)
        local home_sets = context_sort_info.home_sets
        local mask = top.context_mask(context)
        if home_sets == nil or mask == nil or top.context_home(context) ~= nil or not top.has_ability(mask, top.ISOLATABILITY) then
            return nil
        end
        local home_id = home_sets.of[top.context_room(context)]
        local found
        for tech_context, _ in pairs(tech_contexts) do
            if home_id ~= nil and top.context_home(tech_context) == home_id and (found == nil or tech_context < found) then
                found = tech_context
            end
        end
        return found
    end
    -- With counted (context --> index), only those contexts count, and a prerequisite only has to come before the index there, like the contexts a kept alternate path is kept for and when its recipes are made there (see counted_contexts below)
    local function covers(prereq_tech_name, tech_name, recipe_name, counted)
        if context_sort_info == nil then
            return true
        end
        local nci = context_sort_info.node_to_context_inds
        local prereq_contexts = nci[gutils.key("technology", prereq_tech_name)] or {}
        local tech_contexts = nci[gutils.key("technology", tech_name)] or {}
        local target_recipes
        if recipe_name ~= nil then
            target_recipes = nci[gutils.key("recipe", recipe_name)] or {}
        end
        for context, ind in pairs(tech_contexts) do
            if (target_recipes == nil or target_recipes[context] ~= nil) and (counted == nil or counted[context] ~= nil) then
                if prereq_contexts[context] == nil then
                    return false
                end
                -- The witness may unlock this prerequisite through an alternate technology.
                -- Substituting a later primary can create a cycle even though it has the same contexts.
                -- A copied research method can legitimately arrive after an alternate recipe unlock.
                local target_ind = math.max((target_recipes or counted or {})[context] or ind, ind)
                if prereq_contexts[context] >= target_ind then
                    return false
                end
                -- A tech with an isolatable context only through the discovery rule keeps it only with its home context, which a prerequisite with that context from the room's own resources can lack (every context of the tech counts without a recipe, home contexts too)
                -- Like the original Fulgora's water scaffold for electrolyte on sa/dupes-preview seed 1: its tech was researched before reaching Fulgora, and scrap recycling's tech, researched by mining Fulgoran ruins, took that away as a prerequisite
                if target_recipes ~= nil and not gives_directly(tech_name, context) then
                    local home_context = rule_home_context(tech_contexts, context)
                    if home_context ~= nil and prereq_contexts[home_context] == nil then
                        return false
                    end
                end
            end
        end
        return true
    end
    -- Keep research paths supplying recipe contexts the primary source cannot supply.
    -- Their technologies keep their research methods and receive the same context guards below.
    local retained_unlocks = rebuild_unlocks.retained(data.raw.technology, recipe_to_source_tech, context_sort_info, graph)
    -- How many recipes each tech unlocks before the rebuild, which divides the research of the kept paths' own techs (rebuild_unlocks.split below) as for the rebuilt techs
    local recipe_unlocks_before = {}
    for tech_name, tech in pairs(data.raw.technology) do
        local num_unlocks = 0
        for _, effect in pairs(tech.effects or {}) do
            if effect.type == "unlock-recipe" then
                num_unlocks = num_unlocks + 1
            end
        end
        recipe_unlocks_before[tech_name] = num_unlocks
    end
    local num_retained = 0
    for _, recipes in pairs(retained_unlocks) do
        for _, _ in pairs(recipes) do
            num_retained = num_retained + 1
        end
    end
    log("Tech tree rebuild: " .. num_retained .. " alternate recipe unlock paths kept to preserve contexts")
    local num_kept = 0
    local num_left_out = 0

    -- Whether a recipe gets a rebuilt tech below: it's locked, and a tech unlocking it has a unit or trigger to copy
    local function gets_tech(recipe_name)
        return data.raw.recipe[recipe_name].enabled == false and (recipe_to_unit[recipe_name] ~= nil or recipe_to_research_trigger[recipe_name] ~= nil)
    end

    -- Whether the logic needs a tech for something other than its recipe unlocks and as a prerequisite (like a planet's discovery)
    local function needed_for_more(tech_node)
        for dep, _ in pairs(tech_node.dep) do
            local edge = graph.edges[dep]
            if graph.nodes[edge.stop].type ~= "technology" and not unlock_contraction.is_unlock_edge(graph, edge) then
                return true
            end
        end
        return false
    end
    -- Techs the logic needs for something other than their recipe unlocks and as prerequisites (like planet discovery), which keep their place in progression instead of getting a random prereq below
    -- A random prereq could need what the tech itself gives (like one of the discovered planet's science packs), which would make it unresearchable, and shifted worlds (randomizations/planetary) move which techs those are
    local function logic_needs(tech_node)
        return retained_unlocks[tech_node.name] ~= nil or needed_for_more(tech_node)
    end
    -- The contexts that count for the prerequisites of a tech kept only as an alternate unlock path: those it's kept for, with when its recipes are made there (rebuild_unlocks.kept_for), or nil for every context of the tech (see covers)
    -- Elsewhere its recipe's own tech unlocks the recipe, so it can wait there, and what other techs need from it is checked in the rebuilt game (rebuild_check below), as for a rebuilt tech outside where its recipe is made
    -- Like Coal synthesis (Unlock 2) in the user's 2026-10-10 game, researched by crafting iron ore and kept for Fulgora: cannon shells, the earliest way to craft iron ore, can be had on Fulgora from its own resources, but not on Gleba 2, where the recipe's own tech unlocks it anyway, and the tech got no prerequisite at all
    local kept_for = rebuild_unlocks.kept_for(recipe_to_source_tech, context_sort_info, retained_unlocks)
    local function counted_contexts(tech_name)
        local node = graph.nodes[gutils.key("technology", tech_name)]
        if kept_for[tech_name] == nil or node == nil or needed_for_more(node) then
            return nil
        end
        return kept_for[tech_name]
    end

    -- Whether a tech on the witness of recipe_name (nil for a tech's witness) is needed as itself: it keeps its place (see logic_needs), so like a planet's discovery it stays in the tree, and what needs it should need it rather than only what its research needs
    -- Without this, a recipe made only on one planet came right after the science packs that planet's discovery takes, not after the discovery
    -- Not a kept alternate path that still unlocks recipe_name itself (see retained_unlocks): that's the recipe's own unlock, which its rebuilt tech stands for
    local function needed_tech_for(recipe_name)
        return function(tech_name)
            if recipe_name ~= nil and (retained_unlocks[tech_name] or {})[recipe_name] ~= nil then
                return false
            end
            return data.raw.technology[tech_name] ~= nil and logic_needs(graph.nodes[gutils.key("technology", tech_name)])
        end
    end

    -- The recipes with techs that the pebble at ind directly needs, going on through recipes without one (see lib/logic/witness-recipes.lua), and second the techs the logic needs on the way (see needed_tech_for)
    -- For a recipe's tech, where the witness has a choice on the recipe's planet it takes what that planet can make from its own resources, even if that comes a bit later (context_sort_info is the sort without tech prerequisites that has those contexts)
    -- Like a planet's own version of a boiler recipe over another planet's version it would have to import boilers from, so a planet's recipes come after that planet's own unlocks
    -- Techs the logic needs (logic_needs above) and research methods (witness_recipes.research below) keep the earliest witness
    -- Every witness researches a tech or launches an item in the starting planet or a room before its own, of the rooms just as early, using the home sets of context_sort_info (see witness_recipes.of)
    local preference_stats = {}
    local home_sets = context_sort_info ~= nil and context_sort_info.home_sets or nil
    local function prev_recipes_of(ind, prefer_local)
        local node = graph.nodes[no_tech_sort_info.pebble_keys[ind]]
        local needed_tech = needed_tech_for(node.type == "recipe" and node.name or nil)
        if prefer_local == true then
            return witness_recipes.of(graph, no_tech_sort_info, ind, gets_tech, context_sort_info, preference_stats, needed_tech, home_sets)
        end
        return witness_recipes.of(graph, no_tech_sort_info, ind, gets_tech, nil, preference_stats, needed_tech, home_sets)
    end

    -- When the sort without tech prerequisites first reached room (a context of it), as an index in it, or nil
    local function room_reached(room)
        local first
        for _, ind in pairs(no_tech_sort_info.node_to_context_inds[gutils.key("room", room)] or {}) do
            if first == nil or ind < first then
                first = ind
            end
        end
        return first
    end
    -- The pebble a recipe's witness starts from: its first one, or one the sort added in the same step in a room it reached sooner
    -- The sort adds a node's pebbles from one step next to each other, in whatever order it lists their contexts, so which of those comes first says nothing about the recipe
    -- Like a recipe whose tech comes once both Nauvis and Vulcanus can make it: its witness on Vulcanus would make it need Vulcanus's discovery (see needed_tech_for)
    local num_sooner_rooms = 0
    local function witness_ind(first_ind)
        local pebble_keys = no_tech_sort_info.pebble_keys
        local pebble_contexts = no_tech_sort_info.pebble_contexts
        local best_ind = first_ind
        -- The sort has plain room contexts (simple contexts, lib/graph/contexts.lua), each standing for its room
        local best_reached = room_reached(top.context_room(pebble_contexts[first_ind]))
        local ind = first_ind + 1
        while pebble_keys[ind] ~= nil and pebble_keys[ind] == pebble_keys[first_ind] do
            local reached = room_reached(top.context_room(pebble_contexts[ind]))
            if reached ~= nil and (best_reached == nil or reached < best_reached) then
                best_ind = ind
                best_reached = reached
            end
            ind = ind + 1
        end
        if best_ind ~= first_ind then
            num_sooner_rooms = num_sooner_rooms + 1
        end
        return best_ind
    end

    -- The techs the logic needs that each pebble of the sort without tech prerequisites can't be reached without (top.watched_needed): every way to it passes them
    -- Of those a witness passes, only these become prerequisites below: the others it passes because of its choices between ways that are just as early, which are arbitrary
    -- Like Fulbis's recipes in the user's 2026-10-10 game: their witnesses researched Fulbis's discovery on Vulgora, or flew in from a planet Fulbis doesn't come after, and their techs needed that planet's discovery too
    -- Ones past a recipe with a tech, where the witness stops, still come through that tech's prerequisites
    -- Py's sort without tech prerequisites is of another graph (see above), so py keeps every tech the witness passes
    local needed_of
    if context_sort_info ~= nil then
        local watched = {}
        for node_key, node in pairs(graph.nodes) do
            if node.type == "technology" and data.raw.technology[node.name] ~= nil and logic_needs(node) then
                table.insert(watched, node_key)
            end
        end
        needed_of = top.watched_needed(graph, watched, no_tech_sort_info)
    end
    -- Of the techs a witness passed (passed, from witness_recipes), those every way there passes too (node_keys, a set from needed_of); the others are counted for the log
    local num_passed_unneeded = 0
    local function needed_techs(passed, node_keys)
        local techs = {}
        for tech_name, _ in pairs(passed or {}) do
            if (node_keys or {})[gutils.key("technology", tech_name)] ~= nil then
                techs[tech_name] = true
            else
                num_passed_unneeded = num_passed_unneeded + 1
            end
        end
        return techs
    end

    local recipe_to_prev = {}
    local needed_tech_to_prev = {}
    -- The techs the logic needs that each recipe's or needed tech's witness passes and it can't be had without (see needed_tech_for, needed_of), which become prerequisites below
    local recipe_to_needed = {}
    local needed_tech_to_needed = {}
    for ind, pebble_key in pairs(no_tech_sort_info.pebble_keys) do
        local node = graph.nodes[pebble_key]
        if node.type == "recipe" and recipe_to_prev[node.name] == nil then
            local root = witness_ind(ind)
            recipe_to_prev[node.name], recipe_to_needed[node.name] = prev_recipes_of(root, true)
            if needed_of ~= nil then
                recipe_to_needed[node.name] = needed_techs(recipe_to_needed[node.name], needed_of(pebble_key, no_tech_sort_info.pebble_contexts[root]))
            end
        elseif node.type == "technology" and needed_tech_to_prev[node.name] == nil and data.raw.technology[node.name] ~= nil and logic_needs(node) then
            needed_tech_to_prev[node.name], needed_tech_to_needed[node.name] = prev_recipes_of(ind, false)
            if needed_of ~= nil then
                needed_tech_to_needed[node.name] = needed_techs(needed_tech_to_needed[node.name], needed_of(pebble_key))
            end
            -- A kept alternate path also takes what its recipes need where it's kept for (see counted_contexts), as a recipe's own tech takes what the recipe needs: the recipes on the witness of each recipe's first pebble in those contexts in context_sort_info, whose context says which room and abilities, within the room (witness_recipes.in_room)
            -- There the recipe is unlocked through a kept path, so its witness also takes what the path's research needs in that room
            -- Like Electrolyte (Unlock 2) in the user's 2026-10-10 game, researched by crafting a crusher and kept for Vulcanus and Fulgora 2: the earliest way to craft one anywhere was Fulgora 2's own holmium plate recipe, which Vulcanus can't make, so it couldn't be a prerequisite (covers), while the plain holmium plate recipe that Vulcanus crafts crushers with can; and electrolyte's ingredients on Vulcanus come before it, as they come before Electrolyte (Unlock 1)
            -- Not how to get to the room: that's the room's discovery and travel, which a recipe's own tech doesn't wait for either
            local counted = counted_contexts(node.name)
            if counted ~= nil then
                local kept_recipes = {}
                for recipe_name, _ in pairs(retained_unlocks[node.name]) do
                    table.insert(kept_recipes, recipe_name)
                end
                table.sort(kept_recipes)
                for _, recipe_name in pairs(kept_recipes) do
                    local recipe_inds = context_sort_info.node_to_context_inds[gutils.key("recipe", recipe_name)] or {}
                    local first
                    for context, _ in pairs(counted) do
                        if recipe_inds[context] ~= nil and (first == nil or recipe_inds[context] < first) then
                            first = recipe_inds[context]
                        end
                    end
                    if first ~= nil then
                        -- A context a listed pebble stands for has that pebble's rank (top.implied_ability_contexts), which is where its witness starts
                        for prev_recipe_name, _ in pairs(witness_recipes.in_room(graph, context_sort_info, math.ceil(first), gets_tech)) do
                            -- Not the recipe's own tech, which another of its pebbles there can stand for
                            if prev_recipe_name ~= recipe_name then
                                needed_tech_to_prev[node.name][prev_recipe_name] = true
                            end
                        end
                    end
                end
            end
        end
    end
    -- Preserve the research method actually copied, including its crafting/mining triggers.
    local research_recipes = {}
    for recipe_name, _ in pairs(recipe_to_prev) do
        if gets_tech(recipe_name) then
            table.insert(research_recipes, recipe_name)
        end
    end
    table.sort(research_recipes)
    local research_requirements = {}
    local research_needed = {}
    for _, recipe_name in pairs(research_recipes) do
        local source = recipe_to_source_tech[recipe_name]
        if research_requirements[source] == nil then
            research_requirements[source], research_needed[source] = witness_recipes.research(graph, no_tech_sort_info, source, gets_tech, needed_tech_for(nil), home_sets, preference_stats)
            if needed_of ~= nil then
                research_needed[source] = needed_techs(research_needed[source], needed_of(gutils.key("technology", source)))
            end
        end
        local requirements = research_requirements[source]
        if requirements == nil or not witness_recipes.extend(recipe_to_prev, recipe_name, requirements, function(pre, target)
            return covers(recipe_to_source_tech[pre], recipe_to_source_tech[target], target)
        end) then
            log("Research tech: couldn't add research prerequisites for " .. recipe_name .. " without a missing witness, dependency cycle, or lost context")
        end
        -- The techs the logic needs on the research (like the discovery of the planet a trigger happens on) go in with the others below, whether or not its recipes could
        local is_needed = needed_tech_for(recipe_name)
        for tech_name, _ in pairs(research_needed[source] or {}) do
            if is_needed(tech_name) then
                recipe_to_needed[recipe_name][tech_name] = true
            end
        end
    end

    local rebuilt_recipes = {}
    for recipe_name, _ in pairs(recipe_to_prev) do
        if gets_tech(recipe_name) then
            rebuilt_recipes[recipe_name] = true
        end
    end
    local recipe_abilities = technology_abilities.bundle(data.raw.technology, rebuilt_recipes)
    if mods["space-age"] and mods["quality"] then
        technology_abilities.bundle_quality(data.raw.technology, rebuilt_recipes, data.raw, recipe_abilities)
    end

    for _, tech in pairs(data.raw.technology) do
        local new_effects = {}
        for _, effect in pairs(tech.effects or {}) do
            if effect.type ~= "unlock-recipe" or (retained_unlocks[tech.name] or {})[effect.recipe] ~= nil then
                table.insert(new_effects, effect)
            end
        end
        if retained_unlocks[tech.name] == nil and (#new_effects == 0 or tech.name == "cliff-explosives" or tech.name == "construction-robotics" or tech.name == "logistic-robotics" or tech.name == "logistic-system" or tech.name == "bulk-inserter") and tech.name ~= "pyrrhic" then
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
    -- Rebuilt tech --> the tech whose research it copies, for the check of the rebuilt game
    local new_tech_sources = {}
    -- Rebuilt tech --> the recipe it unlocks
    local new_tech_recipes = {}
    local copied_trigger_sources = {}
    for recipe_name, prev_recipes in pairs(recipe_to_prev) do
        local recipe = data.raw.recipe[recipe_name]

        if recipe.enabled == false then
            local prereqs = {}
            -- Each of these gets a tech (see prev_recipes_of)
            for prev_recipe_name, _ in pairs(prev_recipes) do
                -- Only if it can't take away a context (see covers); leaving one out only lets this tech be researched sooner
                if recipe_to_source_tech[recipe_name] == nil or covers(recipe_to_source_tech[prev_recipe_name], recipe_to_source_tech[recipe_name], recipe_name) then
                    table.insert(prereqs, "exfret-rebuilt-" .. prev_recipe_name .. "-suffix")
                    num_kept = num_kept + 1
                else
                    num_left_out = num_left_out + 1
                end
            end

            if recipe_to_unit[recipe_name] then
                table.insert(new_techs_with_unit, "exfret-rebuilt-" .. recipe_name .. "-suffix")
            end
            is_new_tech["exfret-rebuilt-" .. recipe_name .. "-suffix"] = true
            new_tech_sources["exfret-rebuilt-" .. recipe_name .. "-suffix"] = recipe_to_source_tech[recipe_name]
            new_tech_recipes["exfret-rebuilt-" .. recipe_name .. "-suffix"] = recipe_name
            local new_tech = {
                type = "technology",
                name = "exfret-rebuilt-" .. recipe_name .. "-suffix",
                localised_name = locale_utils.find_localised_name(data.raw.recipe[recipe_name]),
                icons = dupe.technology_icons(dupe.get_recipe_icons(recipe)),
                prerequisites = prereqs,
                essential = is_essential_recipe[recipe_name],
                effects = {
                    {
                        type = "unlock-recipe",
                        recipe = recipe_name
                    },
                },
            }
            for _, effect in pairs(recipe_abilities[recipe_name] or {}) do
                table.insert(new_tech.effects, effect)
            end
            -- A recipe no tech unlocks at all gets no tech and stays disabled, as it was (enabling it would hand the player something the game never gave)
            if recipe_to_unit[recipe_name] ~= nil then
                new_tech.unit = recipe_to_unit[recipe_name]
            elseif recipe_to_research_trigger[recipe_name] ~= nil then
                new_tech.research_trigger = recipe_to_research_trigger[recipe_name]
                copied_trigger_sources[new_tech.name] = recipe_to_source_tech[recipe_name]
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
            if needed_tech_to_prev[tech.name] ~= nil then
                -- A tech the logic needs comes as early as it can be researched: right after the rebuilt techs of the recipes it needs (its science packs), keeping its own science packs
                local prereqs = {}
                for prev_recipe_name, _ in pairs(needed_tech_to_prev[tech.name]) do
                    if data.raw.technology["exfret-rebuilt-" .. prev_recipe_name .. "-suffix"] ~= nil then
                        -- Like the rebuilt techs, only if it can't take away a context (see covers)
                        if recipe_to_source_tech[prev_recipe_name] == nil or covers(recipe_to_source_tech[prev_recipe_name], tech.name, nil, counted_contexts(tech.name)) then
                            table.insert(prereqs, "exfret-rebuilt-" .. prev_recipe_name .. "-suffix")
                            num_kept = num_kept + 1
                        else
                            num_left_out = num_left_out + 1
                        end
                    end
                end
                table.sort(prereqs)
                tech.prerequisites = prereqs
            elseif #new_techs_with_unit > 0 then
                -- A world whose sort reaches no locked recipe with a unit leaves nothing to pick, and math.random(1, 0) would stop the game from loading
                local prereq = data.raw.technology[new_techs_with_unit[math.random(1, #new_techs_with_unit)]]
                tech.prerequisites = { prereq.name }
                if tech.unit ~= nil then
                    tech.unit.ingredients = prereq.unit.ingredients
                end
            end
        end
    end
    log("Tech tree rebuild: " .. num_kept .. " prerequisites kept, " .. num_left_out .. " left out because they would take away a context")

    -- The techs the logic needs on each witness (see needed_tech_for) go in last, like a planet's discovery for a recipe made only there
    -- Each only if it can't take away a context (see covers) or make a cycle: what a needed tech needs comes before it, but a research witness above can add a prerequisite reached after its tech, and the needed tech's own prerequisites can need that one
    -- Whether tech_name's tech needs target_name's, through prerequisites
    local function needs(tech_name, target_name)
        local seen = {}
        local pending = { tech_name }
        while #pending > 0 do
            local current = table.remove(pending)
            if current == target_name then
                return true
            end
            if not seen[current] then
                seen[current] = true
                for _, prereq in pairs((data.raw.technology[current] or {}).prerequisites or {}) do
                    table.insert(pending, prereq)
                end
            end
        end
        return false
    end
    local num_needed_added = 0
    local num_needed_left_out = 0
    local num_needed_cycles = 0
    -- Tech name --> needed tech name --> why it isn't a prerequisite ("context" or "cycle"), or "added", for saying below why a tech still doesn't need its recipe's discovery
    local needed_outcomes = {}
    -- Adds needed tech prereq_name to tech_name's prerequisites, if covered(prereq_name) and it makes no cycle
    local function add_needed(tech_name, prereq_name, covered)
        local tech = data.raw.technology[tech_name]
        if tech == nil or prereq_name == tech_name then
            return
        end
        for _, prereq in pairs(tech.prerequisites or {}) do
            if prereq == prereq_name then
                return
            end
        end
        needed_outcomes[tech_name] = needed_outcomes[tech_name] or {}
        if not covered(prereq_name) then
            num_needed_left_out = num_needed_left_out + 1
            needed_outcomes[tech_name][prereq_name] = "context"
        elseif needs(prereq_name, tech_name) then
            num_needed_cycles = num_needed_cycles + 1
            needed_outcomes[tech_name][prereq_name] = "cycle"
        else
            tech.prerequisites = tech.prerequisites or {}
            table.insert(tech.prerequisites, prereq_name)
            num_needed_added = num_needed_added + 1
            needed_outcomes[tech_name][prereq_name] = "added"
        end
    end
    local function sorted_names(set)
        local list = {}
        for name, _ in pairs(set or {}) do
            table.insert(list, name)
        end
        table.sort(list)
        return list
    end
    for _, recipe_name in pairs(sorted_names(recipe_to_needed)) do
        local tech_name = "exfret-rebuilt-" .. recipe_name .. "-suffix"
        if is_new_tech[tech_name] then
            for _, needed_name in pairs(sorted_names(recipe_to_needed[recipe_name])) do
                add_needed(tech_name, needed_name, function(prereq_name)
                    return recipe_to_source_tech[recipe_name] == nil or covers(prereq_name, recipe_to_source_tech[recipe_name], recipe_name)
                end)
            end
        end
    end
    for _, tech_name in pairs(sorted_names(needed_tech_to_needed)) do
        if not is_new_tech[tech_name] then
            for _, needed_name in pairs(sorted_names(needed_tech_to_needed[tech_name])) do
                add_needed(tech_name, needed_name, function(prereq_name)
                    return covers(prereq_name, tech_name, nil, counted_contexts(tech_name))
                end)
            end
        end
    end
    log("Tech tree rebuild: " .. num_needed_added .. " prerequisites on techs the logic needs (like planet discoveries) added, " .. num_needed_left_out .. " left out because they would take away a context, " .. num_needed_cycles .. " because they would make a cycle; " .. num_passed_unneeded .. " more that witnesses passed never became candidates, as there's a way without them; " .. num_sooner_rooms .. " recipes' prerequisites come from a room reached sooner than their first pebble's, which the sort reached in the same step")

    -- Each planet's starting recipes (lib/starting-recipes.lua) come with its discovery, so a player who discovers a planet can get it going from its own resources (user, 2026-10-10)
    --   * A starting recipe's tech becomes a prerequisite of the discovery when it can be researched before it: it doesn't need the discovery, it can't take away a context of the discovery's (covers), and it makes the discovery wait for no other planet's discovery
    --     Not when only that planet makes the recipe, which comes after the planet's discovery (see needed_tech_for)
    --   * Otherwise a tech researched by a trigger the planet meets from its own resources stays: the player meets it there, and the route to the trigger is part of the start too
    --   * Otherwise (science packs, or a trigger the planet can't meet itself) the discovery unlocks the recipe
    --     Its own tech goes when it came after the discovery anyway (see can_drop below); otherwise it stays as another way to unlock the recipe
    -- The check of the rebuilt game below still leaves out a prerequisite added here that takes a context away
    local starting_counts = {
        prerequisite = 0,
        trigger = 0,
        packaged = 0,
        kept_too = 0,
    }
    local starting_lines = {}
    -- The starting recipes' techs made prerequisites of discoveries, as { discovery, tech }, to say below how many of them the check of the rebuilt game left out
    local starting_prerequisites = {}
    if context_sort_info ~= nil then
        local is_discoverer = {}
        for _, techs in pairs(discoverers_of) do
            for discoverer, _ in pairs(techs) do
                is_discoverer[discoverer] = true
            end
        end
        -- The discoveries tech_name needs through prerequisites, itself included
        local function discoveries_of(tech_name)
            local found = {}
            local seen = {}
            local pending = { tech_name }
            while #pending > 0 do
                local current = table.remove(pending)
                if not seen[current] then
                    seen[current] = true
                    if is_discoverer[current] then
                        found[current] = true
                    end
                    for _, prereq in pairs((data.raw.technology[current] or {}).prerequisites or {}) do
                        table.insert(pending, prereq)
                    end
                end
            end
            return found
        end
        -- Whether tech lists prereq_name among its own prerequisites
        local function has_prerequisite(tech, prereq_name)
            for _, prereq in pairs(tech.prerequisites or {}) do
                if prereq == prereq_name then
                    return true
                end
            end
            return false
        end
        -- Whether recipe_name's tech can be a prerequisite of discovery (see above), and if not why, for the log: "needs the discovery", "would take a context" or the other discovery it needs
        local function can_precede(tech_name, recipe_name, discovery)
            if needs(tech_name, discovery) then
                return false, "needs the discovery"
            end
            if not covers(recipe_to_source_tech[recipe_name], discovery) then
                return false, "would take a context"
            end
            local allowed = discoveries_of(discovery)
            local others = {}
            for other, _ in pairs(discoveries_of(tech_name)) do
                if allowed[other] == nil then
                    table.insert(others, other)
                end
            end
            if #others > 0 then
                table.sort(others)
                return false, "needs " .. others[1]
            end
            return true
        end
        -- The rooms where a recipe can be made, as a set (the sort without tech prerequisites has simple contexts, each standing for its room)
        local function made_in(recipe_name)
            local rooms = {}
            for context, _ in pairs(no_tech_sort_info.node_to_context_inds[gutils.key("recipe", recipe_name)] or {}) do
                rooms[top.context_room(context)] = true
            end
            return rooms
        end
        -- Whether only rooms discovery discovers make the recipe
        local function made_only_where(recipe_name, discovery)
            local discovered = {}
            for _, found in pairs(top.discovered_rooms({
                type = "technology",
                name = discovery,
            })) do
                discovered[found.room] = true
            end
            local rooms = made_in(recipe_name)
            if next(rooms) == nil then
                return false
            end
            for room, _ in pairs(rooms) do
                if discovered[room] == nil then
                    return false
                end
            end
            return true
        end
        -- Has discovery unlock recipe_name, with the abilities its rebuilt tech has for it (technology_abilities above)
        -- An unlock the discovery kept as an alternate path (retained_unlocks) is now its own, so rebuild_unlocks.split below doesn't move it to a copy
        local function package(recipe_name, discovery)
            if (retained_unlocks[discovery] or {})[recipe_name] ~= nil then
                retained_unlocks[discovery][recipe_name] = nil
            end
            local target = data.raw.technology[discovery]
            target.effects = target.effects or {}
            local added = {
                {
                    type = "unlock-recipe",
                    recipe = recipe_name,
                },
            }
            for _, effect in pairs(recipe_abilities[recipe_name] or {}) do
                table.insert(added, table.deepcopy(effect))
            end
            for _, effect in pairs(added) do
                local present = false
                for _, existing in pairs(target.effects) do
                    if existing.type == effect.type and existing.recipe == effect.recipe and existing.modifier == effect.modifier and existing.quality == effect.quality then
                        present = true
                    end
                end
                if not present then
                    table.insert(target.effects, effect)
                end
            end
        end
        -- Whether recipe_name's tech can go once discovery unlocks the recipe (see above)
        -- That's when it comes after the discovery: it needs it, or it researches what the discovery researches (vanilla's lightning rod), or its recipe is made only where the discovery and the others of its room (all_handled: they unlock it too) discover, so nothing makes it before
        -- Like a recipe only Vulcanus makes, whose tech's research is reached before Vulcanus's discovery, so the discovery couldn't be its prerequisite without taking away a context (covers)
        local function can_drop(tech_name, recipe_name, discovery, all_handled)
            if needs(tech_name, discovery) then
                return true
            end
            if recipe_to_source_tech[recipe_name] ~= discovery and not (all_handled and made_only_where(recipe_name, discovery)) then
                return false
            end
            -- The techs that needed it will need the discovery, which mustn't need them
            for other_name, other in pairs(data.raw.technology) do
                if has_prerequisite(other, tech_name) and needs(discovery, other_name) then
                    return false
                end
            end
            return true
        end
        -- Takes recipe_name's tech out of the tree: the techs that needed it need what it needed and discovery instead, which unlocks its recipe now
        local function drop(tech_name, discovery)
            local tech = data.raw.technology[tech_name]
            local replacement = { discovery }
            for _, prereq in pairs(tech.prerequisites or {}) do
                table.insert(replacement, prereq)
            end
            for other_name, other in pairs(data.raw.technology) do
                if has_prerequisite(other, tech_name) then
                    local prereqs = {}
                    for _, prereq in pairs(other.prerequisites) do
                        if prereq ~= tech_name then
                            table.insert(prereqs, prereq)
                        end
                    end
                    other.prerequisites = prereqs
                    for _, prereq in pairs(replacement) do
                        if prereq ~= other_name and not has_prerequisite(other, prereq) then
                            table.insert(other.prerequisites, prereq)
                        end
                    end
                end
            end
            if tech.essential then
                data.raw.technology[discovery].essential = true
            end
            data.raw.technology[tech_name] = nil
            is_new_tech[tech_name] = nil
            new_tech_sources[tech_name] = nil
            new_tech_recipes[tech_name] = nil
            copied_trigger_sources[tech_name] = nil
        end
        -- Recipe name --> the discoveries unlocking it now that its own tech is gone
        local packaged_into = {}
        local targets = starting_recipes.targets(graph)
        local room_discoverers = rebuild_check.discoverers(graph)
        for _, room in pairs(sorted_names(room_discoverers)) do
            -- The discoveries the rebuild keeps in place (see logic_needs), which are the ones it gave prerequisites
            local discoveries = {}
            local all_handled = true
            for _, discovery in pairs(sorted_names(room_discoverers[room])) do
                if data.raw.technology[discovery] ~= nil and needed_tech_to_prev[discovery] ~= nil then
                    table.insert(discoveries, discovery)
                else
                    all_handled = false
                end
            end
            local found = {}
            local room_outcomes = {}
            local goals = {}
            if #discoveries > 0 then
                goals = starting_recipes.goals(graph, context_sort_info, room, targets)
            end
            while #goals > 0 do
                local recipes = starting_recipes.route(graph, context_sort_info, room, goals, gets_tech)
                goals = {}
                for _, recipe_name in pairs(sorted_names(recipes)) do
                    if found[recipe_name] == nil then
                        found[recipe_name] = true
                        local tech_name = "exfret-rebuilt-" .. recipe_name .. "-suffix"
                        for _, discovery in pairs(discoveries) do
                            local tech = data.raw.technology[tech_name]
                            local outcome
                            -- Why its tech isn't a prerequisite of the discovery, for the log of recipes that keep their own tech too
                            local reason
                            if tech == nil or not is_new_tech[tech_name] then
                                -- Its tech is gone: other discoveries unlock it, and this one does too unless it needs one of them
                                local before = false
                                for _, other in pairs(packaged_into[recipe_name] or {}) do
                                    if other == discovery or needs(discovery, other) then
                                        before = true
                                    end
                                end
                                if packaged_into[recipe_name] ~= nil and not before then
                                    package(recipe_name, discovery)
                                    table.insert(packaged_into[recipe_name], discovery)
                                    outcome = "packaged"
                                end
                            else
                                local precedes = false
                                if made_only_where(recipe_name, discovery) then
                                    reason = "made only there"
                                else
                                    precedes, reason = can_precede(tech_name, recipe_name, discovery)
                                end
                                local trigger_rank
                                if not precedes and tech.research_trigger ~= nil then
                                    trigger_rank = starting_recipes.goal(context_sort_info, starting_recipes.trigger_key(recipe_to_source_tech[recipe_name]), room)
                                end
                                if precedes then
                                    local target = data.raw.technology[discovery]
                                    target.prerequisites = target.prerequisites or {}
                                    if not has_prerequisite(target, tech_name) then
                                        table.insert(target.prerequisites, tech_name)
                                    end
                                    table.insert(starting_prerequisites, {
                                        discovery = discovery,
                                        tech = tech_name,
                                    })
                                    outcome = "prerequisite"
                                elseif trigger_rank ~= nil then
                                    table.insert(goals, trigger_rank)
                                    outcome = "trigger"
                                else
                                    package(recipe_name, discovery)
                                    if can_drop(tech_name, recipe_name, discovery, all_handled) then
                                        drop(tech_name, discovery)
                                        packaged_into[recipe_name] = { discovery }
                                        outcome = "packaged"
                                    else
                                        outcome = "kept_too"
                                    end
                                end
                            end
                            if outcome ~= nil then
                                starting_counts[outcome] = starting_counts[outcome] + 1
                                room_outcomes[outcome] = room_outcomes[outcome] or {}
                                if outcome == "kept_too" then
                                    table.insert(room_outcomes[outcome], recipe_name .. " [" .. reason .. "]")
                                else
                                    table.insert(room_outcomes[outcome], recipe_name)
                                end
                            end
                        end
                    end
                end
            end
            if next(room_outcomes) ~= nil then
                local parts = {}
                local outcomes = {
                    "packaged",
                    "kept_too",
                    "trigger",
                    "prerequisite",
                }
                for _, outcome in pairs(outcomes) do
                    local names = room_outcomes[outcome]
                    if names ~= nil then
                        table.sort(names)
                        local shown = {}
                        for i = 1, math.min(#names, 12) do
                            table.insert(shown, names[i])
                        end
                        table.insert(parts, outcome .. " " .. #names .. " (" .. table.concat(shown, ", ") .. (#names > #shown and ", ..." or "") .. ")")
                    end
                end
                table.insert(starting_lines, "Tech tree rebuild: starting recipes of " .. room .. " (" .. table.concat(discoveries, ", ") .. "): " .. table.concat(parts, "; "))
            end
        end
    end
    log("Tech tree rebuild: planets' starting recipes: " .. starting_counts.prerequisite .. " techs made prerequisites of the discovery, " .. starting_counts.trigger .. " left as triggers the planet meets, " .. starting_counts.packaged .. " recipes unlocked by the discovery instead of a tech of their own, " .. starting_counts.kept_too .. " unlocked by the discovery and still by their own tech")
    for _, line in pairs(starting_lines) do
        log(line)
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
            logic.build()
            local sort_for_tech_pack_fixes = top.sort(logic.graph, nil, nil, { choose_randomly = true })
            for i = #sort_for_tech_pack_fixes.pebble_keys, 1, -1 do
                local pebble_key = sort_for_tech_pack_fixes.pebble_keys[i]
                local node = logic.graph.nodes[pebble_key]
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
    -- The prerequisites above were checked only where each tech's own recipe can be made, so what other techs need from them is checked in the rebuilt game, which must keep everything the game had before
    -- The check sorts the game with the prerequisites reduce keeps: one that another prerequisite already needs changes no tech's contexts, and the sort is several times faster without them
    local full_prerequisites
    if before_sort_info ~= nil then
        full_prerequisites = {}
        for tech_name, tech in pairs(data.raw.technology) do
            full_prerequisites[tech_name] = table.deepcopy(tech.prerequisites)
        end
    end
    technology_prerequisites.reduce(data.raw.technology)
    if before_sort_info ~= nil then
        local num_cut, num_rounds, still_lost = rebuild_check.run(before_sort_info, graph, context_sort_info, data.raw.technology, full_prerequisites, function(tech_name)
            if is_new_tech[tech_name] then
                return new_tech_sources[tech_name]
            elseif needed_tech_to_prev[tech_name] ~= nil then
                return tech_name
            end
            return nil
        end)
        local message = "Tech tree rebuild check: " .. num_cut .. " more prerequisites left out over " .. num_rounds .. " rounds"
        if #still_lost == 0 and num_cut == 0 then
            log("Tech tree rebuild check: the rebuilt game keeps everything the game had")
        elseif #still_lost == 0 then
            log(message .. ", so the rebuilt game keeps everything the game had")
        else
            local examples = {}
            for i = 1, math.min(10, #still_lost) do
                table.insert(examples, still_lost[i].node_key .. " @ " .. top.context_name(still_lost[i].context))
            end
            log(message .. "; the rebuilt game still lost " .. #still_lost .. " contexts the game had, which leaving out prerequisites doesn't bring back (e.g. " .. table.concat(examples, "; ") .. ")")
        end
    end
    -- Starting recipes' techs the check left out of their discovery's prerequisites (directly and through others), which a player can then reach the planet without
    local cut_starting = {}
    for _, pair in pairs(starting_prerequisites) do
        if data.raw.technology[pair.tech] ~= nil and not needs(pair.discovery, pair.tech) then
            table.insert(cut_starting, new_tech_recipes[pair.tech] .. " for " .. pair.discovery)
        end
    end
    if #starting_prerequisites > 0 then
        local message = "Tech tree rebuild: " .. #cut_starting .. " of " .. #starting_prerequisites .. " starting recipes' techs made prerequisites of their discovery were left out by the check"
        if #cut_starting > 0 then
            table.sort(cut_starting)
            local examples = {}
            for i = 1, math.min(5, #cut_starting) do
                table.insert(examples, cut_starting[i])
            end
            message = message .. " (e.g. " .. table.concat(examples, ", ") .. ")"
        end
        log(message)
    end
    -- The kept paths become techs of their own, so that each tech unlocks one recipe; the check above holds for them, since each has its original's research and prerequisites
    local split_copies, split_originals = rebuild_unlocks.split(data.raw.technology, retained_unlocks, recipe_unlocks_before, function(recipe_name)
        local recipe = data.raw.recipe[recipe_name]
        return {
            localised_name = locale_utils.find_localised_name(recipe),
            icons = dupe.technology_icons(dupe.get_recipe_icons(recipe)),
        }
    end)
    local num_split = 0
    for copy_name, copy in pairs(split_copies) do
        num_split = num_split + 1
        new_tech_recipes[copy_name] = copy.recipe
        if data.raw.technology[copy.original].research_trigger ~= nil then
            copied_trigger_sources[copy_name] = copy.original
        end
    end
    log("Tech tree rebuild: " .. num_split .. " kept alternate unlock paths got techs of their own (Unlock 2 and up), copied from " .. #split_originals .. " original techs" .. (#split_originals > 0 and (": " .. table.concat(split_originals, ", ")) or ""))
    -- Techs a player sees at the start of the tree, with no prerequisites, though their recipe or research needs recipes other techs unlock (like crafting an item no starting recipe makes)
    -- The recipes are from the witnesses above: a rebuilt tech's recipe and research (recipe_to_prev, research_requirements), a kept tech's own (needed_tech_to_prev), or a numbered copy's original's
    local num_unplaced = 0
    local unplaced_examples = {}
    for _, tech_name in pairs(sorted_names(data.raw.technology)) do
        local tech = data.raw.technology[tech_name]
        if not tech.hidden and #(tech.prerequisites or {}) == 0 then
            local requirements
            if is_new_tech[tech_name] then
                requirements = {}
                for prev_recipe_name, _ in pairs(recipe_to_prev[new_tech_recipes[tech_name]] or {}) do
                    requirements[prev_recipe_name] = true
                end
                for prev_recipe_name, _ in pairs(research_requirements[new_tech_sources[tech_name]] or {}) do
                    requirements[prev_recipe_name] = true
                end
            elseif split_copies[tech_name] ~= nil then
                requirements = needed_tech_to_prev[split_copies[tech_name].original]
            else
                requirements = needed_tech_to_prev[tech_name]
            end
            if next(requirements or {}) ~= nil then
                num_unplaced = num_unplaced + 1
                if #unplaced_examples < 5 then
                    table.insert(unplaced_examples, tech_name .. " (needs " .. sorted_names(requirements)[1] .. ")")
                end
            end
        end
    end
    log("Tech tree rebuild: " .. num_unplaced .. " techs have no prerequisites though their recipe or research needs recipes other techs unlock" .. (num_unplaced > 0 and (" (e.g. " .. table.concat(unplaced_examples, ", ") .. ")") or ""))

    -- How preferring a planet's own recipes worked out (see prev_recipes_of), and the prerequisites left that unlock a recipe for elsewhere
    if context_sort_info ~= nil then
        -- Rooms a recipe can be made in, as the sort without tech prerequisites' contexts (simple contexts, each standing for its room)
        local function rooms_of(recipe_name)
            return no_tech_sort_info.node_to_context_inds[gutils.key("recipe", recipe_name)] or {}
        end
        local num_elsewhere = 0
        local examples = {}
        local tech_names_sorted = {}
        for tech_name, _ in pairs(new_tech_recipes) do
            table.insert(tech_names_sorted, tech_name)
        end
        table.sort(tech_names_sorted)
        for _, tech_name in pairs(tech_names_sorted) do
            local recipe_name = new_tech_recipes[tech_name]
            local rooms = rooms_of(recipe_name)
            for _, prereq in pairs((data.raw.technology[tech_name] or {}).prerequisites or {}) do
                local prereq_recipe = new_tech_recipes[prereq]
                if prereq_recipe ~= nil then
                    local shares_room = false
                    for room, _ in pairs(rooms_of(prereq_recipe)) do
                        if rooms[room] ~= nil then
                            shares_room = true
                            break
                        end
                    end
                    if not shares_room then
                        num_elsewhere = num_elsewhere + 1
                        if #examples < 5 then
                            table.insert(examples, recipe_name .. " after " .. prereq_recipe)
                        end
                    end
                end
            end
        end
        local message = "Tech tree rebuild: " .. (preference_stats.preferred or 0) .. " techs took a prerequisite their recipe's planet makes itself over an earlier one from elsewhere"
        message = message .. ", " .. (preference_stats.dropped or 0) .. " passed over a planet's own way that needs what it was picked for or something from elsewhere"
        message = message .. " (" .. (preference_stats.gave_up or 0) .. " gave up and took the earliest everywhere)"
        message = message .. "; " .. (preference_stats.tied or 0) .. " witnesses researched a tech or launched an item in the starting planet or a room before their own, rather than in another room the sort listed first at the same step"
        message = message .. "; " .. num_elsewhere .. " prerequisites unlock a recipe that can't be made anywhere their tech's recipe can"
        if #examples > 0 then
            message = message .. " (e.g. " .. table.concat(examples, "; ") .. ")"
        end
        log(message)
    end
    -- Rebuilt techs a player could research before reaching anywhere their recipe is made (see rebuild_check.undiscovered): the techs the logic needs above leave only those whose discovery would have taken away a context or made a cycle
    -- As room --> index: the sort has plain room contexts (simple contexts, lib/graph/contexts.lua), each standing for its room
    local function recipe_rooms(recipe_name)
        local rooms = {}
        for context, ind in pairs(no_tech_sort_info.node_to_context_inds[gutils.key("recipe", recipe_name)] or {}) do
            rooms[top.context_room(context)] = ind
        end
        return rooms
    end
    local undiscovered = rebuild_check.undiscovered(graph, data.raw.technology, new_tech_recipes, recipe_rooms)
    -- Why, for the examples: the discovery wasn't on the recipe's witness, or it was left out above (to keep a context or for a cycle), or the check of the rebuilt game left it out
    local undiscovered_examples = {}
    for i = 1, math.min(5, #undiscovered) do
        local rooms = recipe_rooms(undiscovered[i].recipe)
        local reasons = {}
        for needed_name, outcome in pairs(needed_outcomes[undiscovered[i].tech] or {}) do
            local discovers_room = false
            for _, discovered in pairs(top.discovered_rooms({
                type = "technology",
                name = needed_name,
            })) do
                if rooms[discovered.room] ~= nil then
                    discovers_room = true
                end
            end
            if discovers_room then
                if outcome == "added" then
                    outcome = "left out by the check"
                elseif outcome == "context" then
                    outcome = "left out to keep a context"
                elseif outcome == "cycle" then
                    outcome = "left out for a cycle"
                end
                table.insert(reasons, needed_name .. " " .. outcome)
            end
        end
        table.sort(reasons)
        if #reasons == 0 then
            table.insert(reasons, "no discovery on its witness")
        end
        table.insert(undiscovered_examples, undiscovered[i].recipe .. " (" .. table.concat(reasons, ", ") .. ")")
    end
    local undiscovered_message = "Tech tree rebuild: " .. #undiscovered .. " techs unlock a recipe made only on planets they don't need the discovery of"
    if #undiscovered_examples > 0 then
        undiscovered_message = undiscovered_message .. " (e.g. " .. table.concat(undiscovered_examples, ", ") .. ")"
    end
    log(undiscovered_message)
    trigger_promises.rebuild(data.raw.technology, copied_trigger_sources)
    if config.operation_readiness == true then
        operation_unlocks.run()
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
    -- Entries are duplicates when they have the same type and name, since a fluid can have an item's name and one recipe can take both (probe, 2026-10-09)
    -- A duplicate's amount goes to the first entry, which keeps its other fields, like a fluid's temperature limits (as in old recipe randomization's merge)

    for _, recipe in pairs(data.raw.recipe) do
        if recipe.ingredients ~= nil then
            -- The first entry of each type and name
            local first_ings = {}
            local new_ings = {}
            for _, ing in pairs(recipe.ingredients) do
                local ing_key = ing.type .. "-" .. ing.name
                local first_ing = first_ings[ing_key]
                if first_ing == nil then
                    first_ings[ing_key] = ing
                    table.insert(new_ings, ing)
                else
                    first_ing.amount = first_ing.amount + ing.amount
                    -- An item that doesn't stack is used one at a time (lib/recipe-item-amounts.lua), and this merge runs after that module's last correction
                    if ing.type == "item" then
                        local item = dutils.get_prot("item", ing.name)
                        if item ~= nil and not dutils.is_stackable(item) then
                            first_ing.amount = 1
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

    -- Recipes use one fluid box per fluid whenever unified randomization runs (config.dev_unified), so ports go unseen until used (see lib/fluid-ports.lua)
    if config.dev_unified then
        local num_indexed = fluid_ports.index_recipe_fluids()
        if num_indexed > 0 then
            log("Fluid fixes: " .. num_indexed .. " recipes had their fluids numbered to one fluid box each")
        end
    end

    -- Recipes with fluids leave hand crafting's category (see lib/fluid-ports.lua) whenever randomization can give a recipe a fluid: items and fluids trading positions, or recipe shapes (lib/recipe-shape.lua), whose models both assume it
    -- With items and fluids trading positions, mining drills can also put out what their resources give
    if config.item_fluids or config.recipe_shapes then
        local num_recategorized = fluid_ports.fix_fluid_crafting_categories()
        local num_drills_fitted = 0
        if config.item_fluids then
            num_drills_fitted = fluid_ports.fit_mining_drills()
        end
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
    -- Crafting machines and labs get the trash slots and furnaces the output slots their recipes need (lib/crafter-slots.lua), the old versions add_old_versions just made included
    local num_trash_raised, num_results_raised = crafter_slots.apply()
    log("Crafter slots: " .. num_trash_raised .. " crafting machines and labs got more trash slots, " .. num_results_raised .. " furnaces more output slots")

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
                copy.localised_name = {"propertyrandomizer-name.original", locale_utils.find_localised_name(entity)}
                copy.localised_description = {"propertyrandomizer-description.original"}
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
                item_copy.localised_name = {"propertyrandomizer-name.original", locale_utils.find_localised_name(entity)}
                item_copy.localised_description = {"propertyrandomizer-description.original"}
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
                -- Recipe and resource tooltips leave the old version out of their "made in" and "mined by" lists
                copy.flags = copy.flags or {}
                local hiding_flags = {
                    "not-in-made-in",
                    "not-in-mined-by",
                }
                for _, hiding_flag in pairs(hiding_flags) do
                    local has_flag = false
                    for _, flag in pairs(copy.flags) do
                        has_flag = has_flag or flag == hiding_flag
                    end
                    if not has_flag then
                        table.insert(copy.flags, hiding_flag)
                    end
                end
                data:extend({
                    copy,
                    item_copy,
                    {
                        type = "recipe",
                        name = "derandomized-" .. "entity" .. "--" .. entity.name, -- We can't use gutils.key because colons aren't allowed
                        localised_name = {"propertyrandomizer-name.original", locale_utils.find_localised_name(entity)},
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
            copy.localised_name = {"propertyrandomizer-name.old-recipe", locale_utils.find_localised_name(recipe)}
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
                    localised_name = {"propertyrandomizer-name.free", locale_utils.find_localised_name(item)},
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

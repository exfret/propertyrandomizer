-- The tech tree rebuild (randomizations.rebuild_tech_tree in src/randomizations/rebuild/init.lua): every locked recipe gets technologies of their own, each unlocking only it, placed along one walk of the game's timeline (src/randomizations/rebuild/timeline.lua; user 2026-10-13: rewrite the core so each prerequisite is checked as it's added, and "a new algorithm altogether is warranted" for speed)
-- It reads the game as randomization left it, without the tech prerequisites unified randomization cleared, and builds a tree in which
--   * a recipe gets a technology where a room first has everything else it takes, and another room gets one of its own only where none it has gives the recipe what it had there before (reachable, and makeable from the room's own resources where it was; user's rules for merged recipes, 2026-10-12)
--   * prerequisites are the technologies the room's way to the recipe's ingredients went through, and what the research needs, never the recipe's own old unlock's research
--   * a recipe made only on planets needing discovery comes after their discovery (the way there goes through the planet), and a discovery comes after the route there and the starting recipes it can (user, 2026-10-10), bringing the rest of them with it
--   * research is copied from a technology that unlocked the recipe, taking the packs of every discovery it comes after where a lab takes them all (user, 2026-10-12: "Also consume later science"), and becomes a trigger the room meets where research from home couldn't come after what the room needs (user, 2026-10-13)
-- Everything goes in through one sort of the game being built, so nothing taken in can take away what the game had; the rebuilt game is still checked against the game before (the unified rules, as REBUILDCONTEXTS) and against the user's rules for the tree (src/randomizations/rebuild/tree-checks.lua), all logged as REBUILDCHECK lines that dev/run-tests.py fails a run on

local gutils = require("src/lib/graph/graph-utils")
local top = require("src/lib/sort/context-sort")
local logic = require("src/logic/init")
local locale_utils = require("src/localisation/locale")
local dupe = require("src/prototypes/duplicates/dupe")
local surface_sets = require("src/prototypes/surfaces/surface-sets")
local technology_abilities = require("src/prototypes/technology/technology-abilities")
local technology_prerequisites = require("src/prototypes/technology/technology-prerequisites")
local trigger_promises = require("src/prototypes/technology/technology-trigger-promises")
local unlock_contraction = require("src/logic/analysis/unlock-contraction")
local rebuild_check = require("src/randomizations/rebuild/rebuild-check")
local rebuild_unlocks = require("src/randomizations/rebuild/rebuild-unlocks")
local starting_recipes = require("src/randomizations/rebuild/starting-recipes")
local timeline = require("src/randomizations/rebuild/timeline")
local tree_checks = require("src/randomizations/rebuild/tree-checks")
local unified_check = require("src/randomizations/unified/skeleton/check")

local tree = {}

local function sorted_keys(tbl)
    local keys = {}
    for key, _ in pairs(tbl or {}) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

local function complex_sort(graph)
    return top.sort(graph, nil, nil, {
        complex_contexts = true,
        home_contexts = true,
    })
end

-- Whether the logic needs a tech for something other than its recipe unlocks and as a prerequisite (like a planet's discovery): it keeps its research and gets prerequisites from what that research needs
local function needed_for_more(graph, tech_node)
    for dep, _ in pairs(tech_node.dep) do
        local edge = graph.edges[dep]
        if graph.nodes[edge.stop].type ~= "technology" and not unlock_contraction.is_unlock_edge(graph, edge) then
            return true
        end
    end
    return false
end

-- opts (optional; the offline replays of a dumped game pass them, notes/logs/2026-10-12-rebuild-redesign/): { graph, sort, validate }: the logic graph of the game as it is and a complex sort of it with home contexts
-- With them, the rebuild works on that graph and returns its checks, check(after_graph, after_sort), for the caller to run on its own build and sort of the rebuilt game; validate also works out every technology's timing from its inputs and logs how that compares with the sort's
-- Without them (the game and the unit tests), it builds the logic itself and checks with a logic build of its own at the end
tree.run = function(opts)
    local technologies = data.raw.technology
    local recipes = data.raw.recipe

    local graph
    local before_sort
    if opts ~= nil and opts.graph ~= nil then
        graph = opts.graph
        before_sort = opts.sort or complex_sort(graph)
    else
        logic.build()
        graph = logic.graph
        -- The game as it is, which the rebuilt game is checked against at the end
        before_sort = complex_sort(graph)
    end

    -- The rooms needing discovery (not the starting planet), as room --> set of the techs discovering it
    local discoverers = rebuild_check.discoverers(graph)
    -- Tech name --> the rooms it discovers, sorted
    local discovers = {}
    for _, room in pairs(sorted_keys(discoverers)) do
        for name, _ in pairs(discoverers[room]) do
            discovers[name] = discovers[name] or {}
            table.insert(discovers[name], room)
        end
    end

    -- Gates the game has now: prerequisites that are discoveries, like the discovery of the planet copy whose parallel tree a copied item's technology is in, which unified randomization keeps (src/randomizations/unified/execute.lua)
    -- Every other prerequisite edge goes: the rebuild places every technology by what it needs
    local input_gates = {}
    local num_dropped_edges = 0
    for _, tech_name in pairs(sorted_keys(technologies)) do
        local node = graph.nodes[gutils.key("technology", tech_name)]
        local to_remove = {}
        for pre, _ in pairs(node ~= nil and node.pre or {}) do
            local start = graph.nodes[graph.edges[pre].start]
            if start.type == "technology" then
                if discovers[start.name] ~= nil and start.name ~= tech_name then
                    input_gates[tech_name] = input_gates[tech_name] or {}
                    input_gates[tech_name][start.name] = true
                else
                    table.insert(to_remove, pre)
                end
            end
        end
        table.sort(to_remove)
        for _, pre in pairs(to_remove) do
            gutils.remove_edge(graph, pre)
            num_dropped_edges = num_dropped_edges + 1
        end
    end
    -- The game without those prerequisites, which starting recipes are read from
    local flat_sort = before_sort
    if num_dropped_edges > 0 then
        flat_sort = complex_sort(graph)
    end
    local nci = flat_sort.node_to_context_inds

    -- When each tech is first had in the game as it is (any context but home contexts), which orders choices between techs like the old tree did
    local before_rank = {}
    for _, tech_name in pairs(sorted_keys(technologies)) do
        for context, rank in pairs(before_sort.node_to_context_inds[gutils.key("technology", tech_name)] or {}) do
            if top.context_home(context) == nil and (before_rank[tech_name] == nil or rank < before_rank[tech_name]) then
                before_rank[tech_name] = rank
            end
        end
    end
    local function by_rank(a, b)
        local rank_a = before_rank[a]
        local rank_b = before_rank[b]
        if rank_a ~= rank_b then
            if rank_a == nil then
                return false
            end
            if rank_b == nil then
                return true
            end
            return rank_a < rank_b
        end
        return a < b
    end
    -- The discovery of a room that's had first, or nil for a room needing none
    local function gate_of(room)
        local names = sorted_keys(discoverers[room])
        table.sort(names, by_rank)
        return names[1]
    end

    -- Techs the logic needs for more than their recipe unlocks (like planet discoveries), which keep their research
    local kept = {}
    for _, tech_name in pairs(sorted_keys(technologies)) do
        local node = graph.nodes[gutils.key("technology", tech_name)]
        if node ~= nil and needed_for_more(graph, node) then
            kept[tech_name] = true
        end
    end

    -- Recipe name --> the techs unlocking it that have research to copy (a unit or a trigger), reached first first
    local unlockers = {}
    for _, tech_name in pairs(sorted_keys(technologies)) do
        local tech = technologies[tech_name]
        if tech.unit ~= nil or tech.research_trigger ~= nil then
            for _, effect in pairs(tech.effects or {}) do
                if effect.type == "unlock-recipe" and recipes[effect.recipe] ~= nil then
                    unlockers[effect.recipe] = unlockers[effect.recipe] or {}
                    local listed = false
                    for _, other in pairs(unlockers[effect.recipe]) do
                        listed = listed or other == tech_name
                    end
                    if not listed then
                        table.insert(unlockers[effect.recipe], tech_name)
                    end
                end
            end
        end
    end
    for _, list in pairs(unlockers) do
        table.sort(list, by_rank)
    end
    -- How many recipes each tech unlocks, which divides the count of the unit a rebuilt technology copies from it
    local num_recipe_unlocks = {}
    for tech_name, tech in pairs(technologies) do
        local num = 0
        for _, effect in pairs(tech.effects or {}) do
            if effect.type == "unlock-recipe" then
                num = num + 1
            end
        end
        num_recipe_unlocks[tech_name] = num
    end

    -- Where a recipe is made in the game as it is: the rooms of its pebbles, home contexts aside
    local places_memo = {}
    local function places_of(recipe_name)
        local places = places_memo[recipe_name]
        if places == nil then
            places = {}
            for context, rank in pairs(nci[gutils.key("recipe", recipe_name)] or {}) do
                if top.context_home(context) == nil then
                    local room = top.context_room(context)
                    if places[room] == nil or rank < places[room].rank then
                        places[room] = {
                            rank = rank,
                        }
                    end
                end
            end
            places_memo[recipe_name] = places
        end
        return places
    end
    -- Recipes that are locked and have a tech with research to copy, which get technologies of their own
    local function gets_tech(recipe_name)
        local recipe = recipes[recipe_name]
        return recipe ~= nil and recipe.enabled == false and unlockers[recipe_name] ~= nil
    end

    -- Each planet's starting recipes (src/randomizations/rebuild/starting-recipes.lua): room --> set of recipe names
    -- A starting recipe whose tech the planet researches by a trigger it meets itself is left for after the discovery, and its route goes to that trigger too
    local targets = starting_recipes.targets(graph)
    local starting = {}
    local starting_trigger = {}
    for _, room in pairs(sorted_keys(discoverers)) do
        local found = {}
        local goals = starting_recipes.goals(graph, flat_sort, room, targets)
        while #goals > 0 do
            local route = starting_recipes.route(graph, flat_sort, room, goals, gets_tech)
            goals = {}
            for _, recipe_name in pairs(sorted_keys(route)) do
                if found[recipe_name] == nil then
                    found[recipe_name] = true
                    for _, source in pairs(unlockers[recipe_name] or {}) do
                        if technologies[source].research_trigger ~= nil and starting_trigger[room .. "\n" .. recipe_name] == nil then
                            local rank = starting_recipes.goal(flat_sort, starting_recipes.trigger_key(source), room)
                            if rank ~= nil then
                                starting_trigger[room .. "\n" .. recipe_name] = true
                                table.insert(goals, rank)
                            end
                        end
                    end
                end
            end
        end
        starting[room] = found
    end

    -- Recipes enabled from the start that only planets needing discovery make, which now come with those discoveries
    local enabled_to_lock = {}
    local num_enabled_to_lock = 0
    for _, recipe_name in pairs(sorted_keys(recipes)) do
        local recipe = recipes[recipe_name]
        if recipe.enabled ~= false and recipe.hidden ~= true then
            local rooms = sorted_keys(places_of(recipe_name))
            local all_gated = #rooms > 0
            for _, room in pairs(rooms) do
                all_gated = all_gated and discoverers[room] ~= nil
            end
            if all_gated then
                enabled_to_lock[recipe_name] = {}
                for _, room in pairs(rooms) do
                    for _, discovery in pairs(sorted_keys(discoverers[room])) do
                        enabled_to_lock[recipe_name][discovery] = true
                    end
                end
                num_enabled_to_lock = num_enabled_to_lock + 1
            end
        end
    end

    -- Labs: the packs each takes, and which take every pack of a set
    local labs = {}
    local lab_inputs = {}
    for _, lab_name in pairs(sorted_keys(data.raw.lab)) do
        local inputs = {}
        for _, input in pairs(data.raw.lab[lab_name].inputs or {}) do
            inputs[input] = true
        end
        table.insert(labs, inputs)
        lab_inputs[lab_name] = inputs
    end
    local function labs_taking(packs)
        local taking = {}
        for lab_name, inputs in pairs(lab_inputs) do
            local takes = true
            for _, pack in pairs(packs) do
                takes = takes and inputs[pack] ~= nil
            end
            if takes then
                taking[lab_name] = true
            end
        end
        return taking
    end


    local rebuilt = {}
    for _, recipe_name in pairs(sorted_keys(recipes)) do
        if gets_tech(recipe_name) then
            rebuilt[recipe_name] = true
        end
    end

    -- Places the tree along the timeline (src/randomizations/rebuild/timeline.lua), which reads the graph and sort and changes neither
    -- What the rebuilt game must give is read off the game without tech prerequisites (gates aside): the rebuild replaces them all, so what they held back isn't something to keep holding back (the same game as before_sort once unified randomization cleared them)
    local plan = timeline.run({
        graph = graph,
        sort = flat_sort,
        technologies = technologies,
        recipes = recipes,
        rebuilt = rebuilt,
        unlockers = unlockers,
        kept = kept,
        discovers = discovers,
        discoverers = discoverers,
        gate_of = gate_of,
        input_gates = input_gates,
        starting = starting,
        starting_trigger = starting_trigger,
        num_recipe_unlocks = num_recipe_unlocks,
        research_key = tree_checks.research_key,
        before_rank = function(tech_name)
            return before_rank[tech_name]
        end,
        labs_taking = labs_taking,
        own_tech_of = function(recipe_name)
            local name = rebuild_unlocks.rebuilt_name(recipe_name)
            return technologies[name] ~= nil and name or nil
        end,
        validate = opts ~= nil and opts.validate or nil,
    })
    if plan.validation ~= nil then
        log("Tech tree rebuild: timing of " .. plan.validation.checked .. " technologies worked out from their inputs: " .. plan.validation.lenient .. " too lenient, " .. plan.validation.strict .. " too strict")
        for _, line in pairs(plan.validation.examples) do
            log("Tech tree rebuild: timing " .. line)
        end
    end
    -- The discoveries a recipe's other inputs in a room needed on the timeline (the served rule allows them, user: recipes "depend on all the unlocks they need")
    local inherent_discoveries = plan.inherent_discoveries

    -- Names: a recipe's technologies in the order they went in are its technology, then its numbered unlocks (src/randomizations/rebuild/rebuild-unlocks.lua)
    local units_of = {}
    for _, unit in pairs(plan.units) do
        units_of[unit.recipe] = units_of[unit.recipe] or {}
        table.insert(units_of[unit.recipe], unit)
    end
    local unit_names = {}
    for _, recipe_name in pairs(sorted_keys(units_of)) do
        local list = units_of[recipe_name]
        for i, unit in pairs(list) do
            unit.name = i == 1 and rebuild_unlocks.rebuilt_name(recipe_name) or rebuild_unlocks.numbered_name(recipe_name, i)
            unit.number = #list > 1 and i or nil
            table.insert(unit_names, unit.name)
        end
    end
    -- A prerequisite's name from its key in the plan: a unit's technology, or a kept tech
    local function name_of_key(node_key)
        local unit = plan.unit_of_key[node_key]
        if unit ~= nil then
            return unit.name
        end
        local name = gutils.deconstruct(node_key).name
        if kept[name] ~= nil then
            return name
        end
        return nil
    end

    -- The first recipe making each science pack, in the order the game has them, marks its technologies essential
    local is_science_pack = {}
    for _, lab in pairs(data.raw.lab or {}) do
        for _, input in pairs(lab.inputs or {}) do
            is_science_pack[input] = true
        end
    end
    local first_maker = {}
    for _, recipe_name in pairs(sorted_keys(recipes)) do
        for _, result in pairs(recipes[recipe_name].results or {}) do
            if result.type == "item" and is_science_pack[result.name] then
                local rank
                for _, place in pairs(places_of(recipe_name)) do
                    rank = math.min(rank or place.rank, place.rank)
                end
                local current = first_maker[result.name]
                if rank ~= nil and (current == nil or rank < current.rank or (rank == current.rank and recipe_name < current.recipe)) then
                    first_maker[result.name] = {
                        recipe = recipe_name,
                        rank = rank,
                    }
                end
            end
        end
    end
    local is_essential = {}
    for _, maker in pairs(first_maker) do
        is_essential[maker.recipe] = true
    end

    -- Recipes the kept techs bring: starting recipes (timeline.lua's add_kept) and recipes enabled from the start that only planets needing discovery make
    local packaged = {}
    for tech_name, info in pairs(plan.kept) do
        for recipe_name, _ in pairs(info.packaged) do
            packaged[tech_name] = packaged[tech_name] or {}
            packaged[tech_name][recipe_name] = true
        end
    end
    for recipe_name, discoveries in pairs(enabled_to_lock) do
        for discovery, _ in pairs(discoveries) do
            packaged[discovery] = packaged[discovery] or {}
            packaged[discovery][recipe_name] = true
        end
    end

    -- Abilities rebuilt technologies carry for their recipes (like elevated rails), taken off the originals first, as the old rebuild did
    local rebuilt_recipes = {}
    for recipe_name, _ in pairs(units_of) do
        rebuilt_recipes[recipe_name] = true
    end
    for _, recipe_set in pairs(packaged) do
        for recipe_name, _ in pairs(recipe_set) do
            rebuilt_recipes[recipe_name] = true
        end
    end
    local recipe_abilities = technology_abilities.bundle(technologies, rebuilt_recipes)
    if mods["space-age"] and mods["quality"] then
        technology_abilities.bundle_quality(technologies, rebuilt_recipes, data.raw, recipe_abilities)
    end

    -- The originals lose their recipe unlocks and prerequisites; those left with nothing to give are hidden
    -- A technology an earlier rebuild named for a recipe a kept tech now brings goes instead, as in the old rebuild: unified randomization may have promised its trigger, which retires with it (src/prototypes/technology/technology-trigger-promises.lua)
    local unit_name_set = {}
    for _, name in pairs(unit_names) do
        unit_name_set[name] = true
    end
    local brought_names = {}
    for _, recipe_set in pairs(packaged) do
        for recipe_name, _ in pairs(recipe_set) do
            brought_names[rebuild_unlocks.rebuilt_name(recipe_name)] = true
        end
    end
    local retired_trigger_takers = {}
    for _, tech_name in pairs(sorted_keys(technologies)) do
        local tech = technologies[tech_name]
        if unit_name_set[tech_name] == nil and brought_names[tech_name] ~= nil and kept[tech_name] == nil then
            technologies[tech_name] = nil
            retired_trigger_takers[tech_name] = true
        elseif unit_name_set[tech_name] == nil then
            local new_effects = {}
            for _, effect in pairs(tech.effects or {}) do
                if effect.type ~= "unlock-recipe" then
                    table.insert(new_effects, effect)
                end
            end
            if kept[tech_name] == nil and (#new_effects == 0 or tech.name == "cliff-explosives" or tech.name == "construction-robotics" or tech.name == "logistic-robotics" or tech.name == "logistic-system" or tech.name == "bulk-inserter") then
                tech.hidden = true
                tech.hidden_in_factoriopedia = true
            end
            tech.effects = new_effects
            tech.prerequisites = {}
        end
    end

    -- The units become technologies
    local copied_trigger_sources = {}
    local repurposed_trigger_takers = {}
    local num_fitted = 0
    local num_fitted_packs = 0
    local num_later_science = 0
    for _, unit in pairs(plan.units) do
        local recipe = recipes[unit.recipe]
        local localised_name = locale_utils.find_localised_name(recipe)
        if unit.number ~= nil then
            localised_name = {
                "propertyrandomizer-name.unlock-number",
                localised_name,
                tostring(unit.number),
            }
        end
        local new_tech = {
            type = "technology",
            name = unit.name,
            localised_name = localised_name,
            icons = dupe.technology_icons(dupe.get_recipe_icons(recipe)),
            prerequisites = {},
            essential = is_essential[unit.recipe] and unit.number == nil or nil,
        }
        -- It unlocks its recipe, with the abilities a rebuilt technology carries for it
        local unlock_effects = {
            {
                type = "unlock-recipe",
                recipe = unit.recipe,
            },
        }
        for _, effect in pairs(recipe_abilities[unit.recipe] or {}) do
            table.insert(unlock_effects, table.deepcopy(effect))
        end
        new_tech.effects = unlock_effects
        local research = unit.research
        if research.unit ~= nil then
            new_tech.unit = table.deepcopy(research.unit)
            if new_tech.unit.count ~= nil then
                new_tech.unit.count = math.ceil(new_tech.unit.count / math.max(1, research.num_unlocks or 1))
            end
            if research.fitted_packs == true then
                num_fitted_packs = num_fitted_packs + 1
            end
            if research.added_packs ~= nil then
                for _, pack in pairs(research.added_packs) do
                    table.insert(new_tech.unit.ingredients, {
                        pack,
                        1,
                    })
                end
                num_later_science = num_later_science + 1
            end
        else
            new_tech.research_trigger = table.deepcopy(research.research_trigger)
            if research.fitted then
                num_fitted = num_fitted + 1
            else
                copied_trigger_sources[unit.name] = research.source
            end
        end
        -- A technology unified randomization named so already (its own one for the recipe) whose research this one doesn't copy no longer carries what it promised for it
        if technologies[unit.name] ~= nil and (research.source ~= unit.name or research.fitted) then
            repurposed_trigger_takers[unit.name] = true
        end
        technologies[unit.name] = new_tech
    end

    -- Prerequisites by name, and why each is there; then a prerequisite another one already needs goes (technology_prerequisites.reduce)
    local reasons = {}
    local reduced = {}
    local num_unnamed = 0
    local function set_prereqs(name, prereqs)
        local names = {}
        local listed = {}
        reasons[name] = {}
        for _, key in pairs(prereqs.keys) do
            local prereq_name = name_of_key(key)
            if prereq_name == nil then
                num_unnamed = num_unnamed + 1
            elseif prereq_name ~= name and listed[prereq_name] == nil then
                listed[prereq_name] = true
                table.insert(names, prereq_name)
                reasons[name][prereq_name] = prereqs.reason[key]
            end
        end
        table.sort(names)
        reduced[name] = {
            prerequisites = names,
        }
    end
    for _, unit in pairs(plan.units) do
        set_prereqs(unit.name, unit.prereqs)
    end
    for _, tech_name in pairs(sorted_keys(plan.kept)) do
        set_prereqs(tech_name, plan.kept[tech_name].prereqs)
    end
    technology_prerequisites.reduce(reduced)
    for name, entry in pairs(reduced) do
        local names = {}
        for _, prereq in pairs(entry.prerequisites) do
            table.insert(names, prereq)
        end
        table.sort(names)
        technologies[name].prerequisites = names
    end

    -- Kept techs unlock the recipes they bring
    for _, tech_name in pairs(sorted_keys(packaged)) do
        local tech = technologies[tech_name]
        tech.effects = tech.effects or {}
        for _, recipe_name in pairs(sorted_keys(packaged[tech_name])) do
            table.insert(tech.effects, {
                type = "unlock-recipe",
                recipe = recipe_name,
            })
            for _, effect in pairs(recipe_abilities[recipe_name] or {}) do
                local present = false
                for _, existing in pairs(tech.effects) do
                    present = present or (existing.type == effect.type and existing.modifier == effect.modifier and existing.quality == effect.quality)
                end
                if not present then
                    table.insert(tech.effects, table.deepcopy(effect))
                end
            end
        end
    end
    for recipe_name, _ in pairs(enabled_to_lock) do
        recipes[recipe_name].enabled = false
    end

    -- Techs that unlock no recipe and that the logic doesn't need (like upgrades) follow a random rebuilt technology with packs and research with its packs, as before
    local with_unit = {}
    for _, name in pairs(unit_names) do
        if technologies[name] ~= nil and technologies[name].unit ~= nil then
            table.insert(with_unit, name)
        end
    end
    for _, tech_name in pairs(sorted_keys(technologies)) do
        local tech = technologies[tech_name]
        if unit_name_set[tech_name] == nil and kept[tech_name] == nil and tech.hidden ~= true and tech.name ~= "pyrrhic" and #with_unit > 0 then
            local prereq = technologies[with_unit[math.random(1, #with_unit)]]
            tech.prerequisites = { prereq.name }
            if tech.unit ~= nil then
                tech.unit.ingredients = table.deepcopy(prereq.unit.ingredients)
            end
        end
    end

    trigger_promises.rebuild(technologies, copied_trigger_sources, retired_trigger_takers, repurposed_trigger_takers)

    local counts = plan.counts
    log("Tech tree rebuild: " .. #unit_names .. " technologies for " .. #sorted_keys(units_of) .. " recipes placed along the timeline (" .. counts.needs .. " needs of recipes, " .. counts.evaluations .. " evaluations); " .. num_fitted_packs .. " researches changed to their room's discovery packs and " .. num_fitted .. " to a trigger their room meets; " .. num_later_science .. " take later science; " .. counts.left_out .. " prerequisites left out to keep what a technology had, " .. (counts.not_needed or 0) .. " left out as their discoveries aren't needed for the recipe there; " .. (counts.covered or 0) .. " technologies dropped as another of the recipe's covers them; " .. (counts.served_missed or 0) .. " placed waiting for discoveries the recipe doesn't need there, nothing better giving its contexts; " .. counts.packaged_start .. " starting recipes and " .. counts.packaged_own .. " a discovery unlocked come with the discovery, " .. counts.starting_prerequisites .. " starting recipes researched before their discovery, " .. (counts.route_prerequisites or 0) .. " technologies on the way to a planet made prerequisites of its discovery once it was reached (" .. counts.route_left_out .. " left out to keep what a discovery had), " .. num_enabled_to_lock .. " recipes made only on planets needing discovery no longer start enabled; " .. counts.given_up .. " recipes couldn't get what they had" .. (#plan.given_up > 0 and (" (e.g. " .. table.concat(plan.given_up, "; ") .. ")") or "") .. "; " .. plan.num_waiting .. " never got a technology" .. (#plan.waiting > 0 and (" (e.g. " .. table.concat(plan.waiting, "; ") .. ")") or "") .. "; kept techs never in: " .. (#plan.kept_never > 0 and table.concat(plan.kept_never, ", ") or "none") .. "; " .. num_dropped_edges .. " prerequisites the game had dropped, " .. #sorted_keys(input_gates) .. " techs kept discoveries they came after" .. (num_unnamed > 0 and ("; " .. num_unnamed .. " prerequisites with no name left out") or "") .. ((counts.unjoined or 0) > 0 and ("; " .. counts.unjoined .. " derivations found no context all of a node's inputs share and took each input's earliest pebble") or ""))

    -- The checks: the rebuilt game keeps what the game had (the unified rules), and the tree follows the user's rules
    -- after_graph and after_sort are the rebuilt game's logic and a complex sort of it with home contexts
    local function check(after_graph, after_sort)
        local verdict = unified_check.run(after_graph, before_sort, after_sort, "REBUILDCONTEXTS", {
            furnaces = false,
        })
        local rooms_memo = {}
        local results = tree_checks.run({
            technologies = technologies,
            recipes = recipes,
            rooms_of = function(recipe_name)
                local rooms = rooms_memo[recipe_name]
                if rooms == nil then
                    rooms = {}
                    for room, _ in pairs(places_of(recipe_name)) do
                        rooms[room] = true
                    end
                    rooms_memo[recipe_name] = rooms
                end
                return rooms
            end,
            discoverers = discoverers,
            copy_number = surface_sets.copy_number,
            labs = labs,
            reasons = reasons,
            inherent_discoveries = inherent_discoveries,
        })
        local context_violations = {}
        if verdict.ok ~= true then
            table.insert(context_violations, (verdict.unreachable or 0) .. " unreachable recipes, " .. (verdict.lost or 0) .. " lost contexts, " .. (verdict.missing or 0) .. " missing promised pebbles (see the REBUILDCONTEXTS lines)")
        end
        table.insert(results, 1, {
            name = "contexts",
            violations = context_violations,
            info = false,
        })
        tree_checks.report(results, log)
    end
    if opts ~= nil and opts.graph ~= nil then
        return check
    end
    logic.build({
        bootstrap_from_last = true,
    })
    check(logic.graph, complex_sort(logic.graph))
end

return tree

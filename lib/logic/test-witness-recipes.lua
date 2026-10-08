-- Plain-Lua regression tests for the recipes a rebuilt tech's prerequisites come from (lib/logic/witness-recipes.lua), not loaded by the mod
-- Run from the mod root: lua lib/logic/test-witness-recipes.lua
--
-- The toy graph is the captive spawner: smelting (locked) makes plates, plates make fuel (locked), the spawner burns the fuel, and its fixed recipe (enabled, so no tech) makes eggs that breeding needs

-- Stand-ins for the Factorio environment
function table.deepcopy(tbl)
    if type(tbl) ~= "table" then
        return tbl
    end
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = table.deepcopy(v)
    end
    return copy
end
function log(msg) end
serpent = {
    block = tostring,
    line = tostring,
}
package.loaded["lib/random/rng"] = {
    int = function(_, max)
        return 1
    end,
}

local HOME = "room: home"

local logic = {
    contexts = {
        [HOME] = true,
    },
    type_info = {
        start = {},
        -- Emitter: sends the context named by the node
        room = { context = "room" },
        stuff = {},
        -- The node type witness_recipes looks for
        recipe = {},
        operate = {},
    },
}
package.loaded["lib/logic/init"] = logic
package.loaded["lib/logic/state"] = package.loaded["lib/logic/init"]

data = {
    raw = {
        technology = {},
    },
}
package.loaded["lib/data-utils"] = {
    get_prot = function(_, name)
        return nil
    end,
}

local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")
local witness_recipes = require("lib/logic/witness-recipes")

local key = gutils.key

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

-- Recipes that get a tech; the fixed egg recipe is enabled, so it doesn't
local locked = {
    smelt = true,
    ["make-fuel"] = true,
    breed = true,
    gear = true,
}
local function gets_tech(recipe_name)
    return locked[recipe_name] == true
end

local function toy_graph()
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local function node(node_type, name, op, pres)
        gutils.add_node(graph, node_type, name, {
            op = op,
        })
        for _, pre in pairs(pres) do
            gutils.add_edge(graph, pre, key(node_type, name))
        end
    end
    node("start", "start", "AND", {})
    node("room", "home", "OR", { key("start", "start") })
    node("stuff", "ore", "OR", { key("room", "home") })
    node("recipe", "smelt", "AND", { key("stuff", "ore") })
    node("stuff", "plate", "OR", { key("recipe", "smelt") })
    node("recipe", "make-fuel", "AND", { key("stuff", "plate") })
    node("stuff", "fuel", "OR", { key("recipe", "make-fuel") })
    node("operate", "spawner", "AND", { key("stuff", "fuel") })
    node("recipe", "eggs", "AND", { key("operate", "spawner") })
    node("stuff", "egg", "OR", { key("recipe", "eggs") })
    node("recipe", "breed", "AND", { key("stuff", "egg") })
    node("recipe", "gear", "AND", { key("stuff", "plate") })
    return graph
end

-- The recipes the first pebble of a recipe directly needs
local function recipes_needed_by(recipe_name, tech_rule)
    local graph = toy_graph()
    local sort_info = top.sort(graph)
    local ind
    for _, context_ind in pairs(sort_info.node_to_context_inds[key("recipe", recipe_name)]) do
        if ind == nil or context_ind < ind then
            ind = context_ind
        end
    end
    return witness_recipes.of(graph, sort_info, ind, tech_rule or gets_tech)
end

local function names(set)
    local list = {}
    for name, _ in pairs(set) do
        table.insert(list, name)
    end
    table.sort(list)
    return table.concat(list, ",")
end

test("a recipe needs the recipes with techs on its witness, and not what those need", function()
    assert(names(recipes_needed_by("gear")) == "smelt")
    assert(names(recipes_needed_by("make-fuel")) == "smelt")
end)

test("the witness goes on through a recipe without a tech, like a fixed recipe, to the fuel its machine burns", function()
    -- Stopping at the egg recipe gave breeding nothing, so its tech had no prerequisites
    assert(names(recipes_needed_by("breed")) == "make-fuel")
end)

test("only recipes that get a tech are returned", function()
    for name, _ in pairs(recipes_needed_by("breed")) do
        assert(gets_tech(name))
    end
    -- If every recipe got a tech, the egg recipe's tech would carry the fuel, so the witness stops there
    local all_get_tech = function()
        return true
    end
    assert(names(recipes_needed_by("breed", all_get_tech)) == "eggs")
end)

test("copied research keeps its crafting witness when the recipe has another unlock path", function()
    local graph = toy_graph()
    local trigger_key = key("technology-trigger", "copied-research")
    local tech_key = key("technology", "copied-research")
    gutils.add_node(graph, "technology-trigger", "copied-research", { op = "OR" })
    gutils.add_node(graph, "technology", "copied-research", { op = "AND" })
    gutils.add_edge(graph, key("recipe", "make-fuel"), trigger_key)
    gutils.add_edge(graph, trigger_key, tech_key)
    for _, node in pairs(graph.nodes) do
        logic.type_info[node.type] = logic.type_info[node.type] or {}
    end
    local sort_info = top.sort(graph)
    -- Gear's ordinary witness only needs smelting. Its copied trigger also needs fuel.
    assert(names(recipes_needed_by("gear")) == "smelt")
    assert(names(witness_recipes.research(graph, sort_info, "copied-research", gets_tech)) == "make-fuel")
    -- An enabled trigger-producing recipe must be traversed to its locked ingredients.
    local function only_smelt(name)
        return name == "smelt"
    end
    assert(names(witness_recipes.research(graph, sort_info, "copied-research", only_smelt)) == "smelt")
    assert(witness_recipes.research(graph, sort_info, "unreachable-research", gets_tech) == nil)
end)

test("a tech the rebuild keeps on the witness comes back too, and the witness goes on through it", function()
    -- A tool made in a workshop that only a discovery opens, researched with plates (like a recipe made only on a planet)
    local graph = toy_graph()
    logic.type_info.technology = logic.type_info.technology or {}
    gutils.add_node(graph, "technology", "discover", { op = "AND" })
    gutils.add_edge(graph, key("stuff", "plate"), key("technology", "discover"))
    gutils.add_node(graph, "stuff", "workshop", { op = "OR" })
    gutils.add_edge(graph, key("technology", "discover"), key("stuff", "workshop"))
    gutils.add_node(graph, "recipe", "tool", { op = "AND" })
    gutils.add_edge(graph, key("stuff", "workshop"), key("recipe", "tool"))
    local sort_info = top.sort(graph)
    local ind
    for _, context_ind in pairs(sort_info.node_to_context_inds[key("recipe", "tool")]) do
        if ind == nil or context_ind < ind then
            ind = context_ind
        end
    end
    local function keeps_place(tech_name)
        return tech_name == "discover"
    end
    local recipes, techs = witness_recipes.of(graph, sort_info, ind, gets_tech, nil, nil, keeps_place)
    -- The plates the discovery is researched with still count, since the witness goes on through it
    assert(names(recipes) == "smelt")
    assert(names(techs) == "discover")
    -- Without keeps_place, or for a tech that doesn't keep its place, only the recipes
    local plain_recipes, plain_techs = witness_recipes.of(graph, sort_info, ind, gets_tech)
    assert(names(plain_recipes) == "smelt" and next(plain_techs) == nil)
    local _, other_techs = witness_recipes.of(graph, sort_info, ind, gets_tech, nil, nil, function()
        return false
    end)
    assert(next(other_techs) == nil)
end)

test("research prerequisites reject cycles and lost contexts without partially adding a witness", function()
    local prerequisites = {
        a = {},
        b = { a = true },
        c = {},
    }
    local function covers()
        return true
    end
    assert(not witness_recipes.extend(prerequisites, "a", { b = true }, covers))
    assert(next(prerequisites.a) == nil)
    assert(not witness_recipes.extend(prerequisites, "a", { c = true }, function() return false end))
    assert(next(prerequisites.a) == nil)
    assert(witness_recipes.extend(prerequisites, "a", { c = true }, covers))
    assert(prerequisites.a.c == true)
end)

-- A planet's own recipes over imports: the away room can import boilers from home early on, or make its own a few steps later
-- Rooms send the context named by the node, so the room nodes are named like the contexts
-- options.own_boiler_steps: how many steps the away room's own boilers take after its plates (default 6)
-- options.pickup: the away room can also get a boiler back by picking up a placed one, which needs a boiler first (like mining a built entity in the logic)
-- options.kit: the away room can also craft boilers from a boiler, without a tech, so the witness looks past it
-- options.lossy: what's crafted isn't the room's own once it's a boiler (the edge loses isolatability), so the away room never has its own boilers
-- options.scrap: the away room can also make boilers by recycling scrap imported from home, after the import of boilers but before fuel
-- Like the logic's items, a boiler is crafted (an OR over the recipes making it) or delivered
local function two_room_graph(options)
    options = options or {}
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local function node(node_type, name, op, pres, abilities)
        gutils.add_node(graph, node_type, name, {
            op = op,
        })
        for _, pre in pairs(pres) do
            gutils.add_edge(graph, pre, key(node_type, name), {
                abilities = abilities,
            })
        end
    end
    node("start", "start", "AND", {})
    node("room", "home", "OR", { key("start", "start") })
    node("room", "away", "OR", { key("start", "start") })
    node("stuff", "ore", "OR", { key("room", "home") })
    node("recipe", "home-boiler", "AND", { key("stuff", "ore") })
    node("stuff", "away-ore", "OR", { key("room", "away") })
    node("recipe", "away-smelt", "AND", { key("stuff", "away-ore") })
    node("stuff", "away-plate", "OR", { key("recipe", "away-smelt") })
    local last = key("stuff", "away-plate")
    for i = 1, options.own_boiler_steps or 6 do
        node("stuff", "away-part-" .. i, "OR", { last })
        last = key("stuff", "away-part-" .. i)
    end
    node("recipe", "away-boiler", "AND", { last })
    node("craft", "boiler", "OR", { key("recipe", "home-boiler"), key("recipe", "away-boiler") })
    local lossy
    if options.lossy == true then
        lossy = { [1] = false }
    end
    node("stuff", "boiler", "OR", { key("craft", "boiler") }, lossy)
    -- Moving boilers between rooms: launching forgets the room, and what arrives isn't the room's own
    node("launch", "boiler", "AND", { key("stuff", "boiler") })
    node("deliver", "boiler", "AND", { key("launch", "boiler") }, { [1] = false })
    gutils.add_edge(graph, key("deliver", "boiler"), key("stuff", "boiler"))
    if options.kit == true then
        node("recipe", "boiler-kit", "AND", { key("stuff", "away-plate"), key("stuff", "boiler") })
        gutils.add_edge(graph, key("recipe", "boiler-kit"), key("craft", "boiler"))
    end
    if options.pickup == true then
        node("placed", "boiler", "AND", { key("stuff", "boiler") })
        node("pickup", "boiler", "AND", { key("placed", "boiler") })
        gutils.add_edge(graph, key("pickup", "boiler"), key("stuff", "boiler"))
    end
    if options.scrap == true then
        node("stuff", "scrap", "OR", { key("room", "home") })
        node("launch", "scrap", "AND", { key("stuff", "scrap") })
        node("deliver", "scrap", "AND", { key("launch", "scrap") }, { [1] = false })
        gutils.add_edge(graph, key("deliver", "scrap"), key("stuff", "scrap"))
        last = key("stuff", "away-plate")
        for i = 1, 6 do
            node("stuff", "away-sorter-" .. i, "OR", { last })
            last = key("stuff", "away-sorter-" .. i)
        end
        node("recipe", "recycle", "AND", { key("stuff", "scrap"), last })
        gutils.add_edge(graph, key("recipe", "recycle"), key("craft", "boiler"))
    end
    -- Needs a boiler in the away room, well after both ways of getting one there
    last = key("stuff", "away-plate")
    for i = 1, 12 do
        node("stuff", "away-wait-" .. i, "OR", { last })
        last = key("stuff", "away-wait-" .. i)
    end
    node("recipe", "fuel", "AND", { key("stuff", "boiler"), last })
    -- Needs a boiler in the away room as soon as there is one
    node("recipe", "early-fuel", "AND", { key("stuff", "boiler"), key("stuff", "away-ore") })
    return graph
end

local two_room_locked = {
    recycle = true,
    ["home-boiler"] = true,
    ["away-boiler"] = true,
    ["away-smelt"] = true,
    fuel = true,
    ["early-fuel"] = true,
}
local function two_room_gets_tech(recipe_name)
    return two_room_locked[recipe_name] == true
end

-- A sort with simple contexts like top.sort's, reaching pebbles a step at a time: each round adds every pebble the earlier rounds allow, by node key
-- So a pebble's index follows how many steps it is from the start, while top.sort's order between nodes opened together follows pairs order, which plain Lua varies from run to run
local function breadth_first_sort(graph)
    local node_keys = {}
    for node_key, _ in pairs(graph.nodes) do
        table.insert(node_keys, node_key)
    end
    table.sort(node_keys)
    local contexts = {}
    for context, _ in pairs(logic.contexts) do
        table.insert(contexts, context)
    end
    table.sort(contexts)
    local sort_info = {
        sorted = {},
        node_to_context_inds = {},
    }
    for _, node_key in pairs(node_keys) do
        sort_info.node_to_context_inds[node_key] = {}
    end
    -- Whether the prereq along pre has a pebble in context, or in any context if any_context
    local function pre_has(pre, context, any_context)
        local inds = sort_info.node_to_context_inds[graph.edges[pre].start]
        return (any_context and next(inds) ~= nil) or inds[context] ~= nil
    end
    while true do
        local reached = {}
        for _, node_key in pairs(node_keys) do
            local node = graph.nodes[node_key]
            local context_type = logic.type_info[node.type].context
            for _, context in pairs(contexts) do
                -- Rooms only send their own context, and they and forgetters take any context in
                local any_context = context_type ~= nil
                if sort_info.node_to_context_inds[node_key][context] == nil and (type(context_type) ~= "string" or context == node.name) then
                    local ok = node.op == "AND"
                    for pre, _ in pairs(node.pre) do
                        if node.op == "AND" and not pre_has(pre, context, any_context) then
                            ok = false
                        elseif node.op == "OR" and pre_has(pre, context, any_context) then
                            ok = true
                        end
                    end
                    if ok then
                        table.insert(reached, { node_key = node_key, context = context })
                    end
                end
            end
        end
        if #reached == 0 then
            return sort_info
        end
        for _, pebble in pairs(reached) do
            table.insert(sort_info.sorted, pebble)
            sort_info.node_to_context_inds[pebble.node_key][pebble.context] = #sort_info.sorted
        end
    end
end

-- Runs fn(graph, sort_info, local_sort_info, first_ind) with the two rooms as the logic's contexts
local function with_two_rooms(options, fn)
    local old_contexts = logic.contexts
    local old_type_info = logic.type_info
    logic.contexts = {
        home = true,
        away = true,
    }
    logic.type_info = {
        start = {},
        room = { context = "room" },
        stuff = {},
        craft = {},
        recipe = {},
        placed = {},
        pickup = {},
        launch = { context = true },
        deliver = {},
    }
    local graph = two_room_graph(options)
    local sort_info = breadth_first_sort(graph)
    -- Which contexts a node gets doesn't depend on the order, so this one can be top.sort's
    local local_sort_info = top.sort(graph, nil, nil, {
        complex_contexts = true,
    })
    local function first_ind(recipe_name)
        local first
        for _, ind in pairs(sort_info.node_to_context_inds[key("recipe", recipe_name)] or {}) do
            if first == nil or ind < first then
                first = ind
            end
        end
        return first
    end
    local ok, err = pcall(fn, graph, sort_info, local_sort_info, first_ind)
    logic.contexts = old_contexts
    logic.type_info = old_type_info
    if not ok then
        error(err, 0)
    end
end

test("a recipe's tech takes its room's own recipe for what it needs over an earlier import", function()
    with_two_rooms({}, function(graph, sort_info, local_sort_info, first_ind)
        local ind = first_ind("fuel")
        -- Without the preference, the boiler comes from home, since the import arrives first
        assert(names(witness_recipes.of(graph, sort_info, ind, two_room_gets_tech)) == "away-smelt,home-boiler")
        local stats = {}
        assert(names(witness_recipes.of(graph, sort_info, ind, two_room_gets_tech, local_sort_info, stats)) == "away-boiler,away-smelt")
        assert(stats.preferred == 1 and stats.dropped == nil and stats.gave_up == nil)
    end)
end)

test("the room's own recipe is only taken if it comes before the recipe", function()
    with_two_rooms({}, function(graph, sort_info, local_sort_info, first_ind)
        local ind = first_ind("early-fuel")
        assert(first_ind("away-boiler") > ind)
        -- Taking it would let the tech wait on something reached only after its recipe, which can loop
        local stats = {}
        assert(names(witness_recipes.of(graph, sort_info, ind, two_room_gets_tech, local_sort_info, stats)) == "home-boiler")
        assert(stats.preferred == nil)
    end)
end)

test("an own way that needs what it gets isn't taken, but the room's own recipe after it is", function()
    with_two_rooms({ pickup = true }, function(graph, sort_info, local_sort_info, first_ind)
        local ind = first_ind("fuel")
        -- Picking a boiler back up in the away room needs a boiler there first, so it comes after the import, and before the room's own boiler recipe
        assert(sort_info.node_to_context_inds[key("pickup", "boiler")].away < first_ind("away-boiler"))
        local stats = {}
        assert(names(witness_recipes.of(graph, sort_info, ind, two_room_gets_tech, local_sort_info, stats)) == "away-boiler,away-smelt")
        -- It can't be the room's first own boiler, so it's never tried
        assert(stats.dropped == nil and stats.preferred == 1 and stats.gave_up == nil)
    end)
end)

test("crafting in the room is dropped when its only way early enough needs what it makes, and the import stays", function()
    -- The away room's own boiler recipe comes after fuel, so the only way to craft boilers there before fuel is the kit, which needs a boiler first
    -- Crafting there is the room's first own way to get a boiler, so it's taken, and then the kit leads back to the boiler
    with_two_rooms({ kit = true, own_boiler_steps = 24 }, function(graph, sort_info, local_sort_info, first_ind)
        local ind = first_ind("fuel")
        assert(first_ind("away-boiler") > ind and first_ind("boiler-kit") < ind)
        local stats = {}
        assert(names(witness_recipes.of(graph, sort_info, ind, two_room_gets_tech, local_sort_info, stats)) == "away-smelt,home-boiler")
        assert(stats.dropped == 1 and stats.preferred == nil and stats.gave_up == nil)
    end)
end)

test("the room's own way is only taken if it stays on the room's own resources down to the recipes with techs", function()
    -- The away room's own boiler recipe comes after fuel, so the earliest way to craft boilers there before fuel is recycling imported scrap
    with_two_rooms({ scrap = true, own_boiler_steps = 24 }, function(graph, sort_info, local_sort_info, first_ind)
        local ind = first_ind("fuel")
        assert(first_ind("away-boiler") > ind and first_ind("recycle") < ind)
        assert(sort_info.node_to_context_inds[key("deliver", "boiler")].away < sort_info.node_to_context_inds[key("craft", "boiler")].away)
        -- Crafting boilers in the away room is the room's own eventually, but taking it now would make fuel wait on scrap recycling: the import stays
        local stats = {}
        assert(names(witness_recipes.of(graph, sort_info, ind, two_room_gets_tech, local_sort_info, stats)) == "away-smelt,home-boiler")
        assert(stats.dropped == 1 and stats.preferred == nil and stats.gave_up == nil)
    end)
end)

test("an option that's the room's own doesn't make a choice that never is the room's own", function()
    with_two_rooms({ lossy = true }, function(graph, sort_info, local_sort_info, first_ind)
        -- The away room can craft boilers from its own resources, but no boiler there counts as its own
        local stats = {}
        assert(names(witness_recipes.of(graph, sort_info, first_ind("fuel"), two_room_gets_tech, local_sort_info, stats)) == "away-smelt,home-boiler")
        assert(stats.preferred == nil and stats.dropped == nil and stats.gave_up == nil)
    end)
end)

test("a choice in a room the witness only passes through takes the earliest", function()
    -- The away room imports gears from home, where gears first come from ore imported from away (with an anvil only home has), and later from home's own ore
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local function node(node_type, name, op, pres, abilities)
        gutils.add_node(graph, node_type, name, {
            op = op,
        })
        for _, pre in pairs(pres) do
            gutils.add_edge(graph, pre, key(node_type, name), {
                abilities = abilities,
            })
        end
    end
    node("start", "start", "AND", {})
    node("room", "home", "OR", { key("start", "start") })
    node("room", "away", "OR", { key("start", "start") })
    node("stuff", "away-ore", "OR", { key("room", "away") })
    node("launch", "away-ore", "AND", { key("stuff", "away-ore") })
    node("deliver", "away-ore", "AND", { key("launch", "away-ore") }, { [1] = false })
    gutils.add_edge(graph, key("deliver", "away-ore"), key("stuff", "away-ore"))
    node("stuff", "anvil", "OR", { key("room", "home") })
    node("recipe", "gear-from-away-ore", "AND", { key("stuff", "away-ore"), key("stuff", "anvil") })
    node("stuff", "ore", "OR", { key("room", "home") })
    local last = key("stuff", "ore")
    for i = 1, 5 do
        node("stuff", "home-part-" .. i, "OR", { last })
        last = key("stuff", "home-part-" .. i)
    end
    node("recipe", "gear-from-ore", "AND", { last })
    node("stuff", "gear", "OR", { key("recipe", "gear-from-away-ore"), key("recipe", "gear-from-ore") })
    node("launch", "gear", "AND", { key("stuff", "gear") })
    node("deliver", "gear", "AND", { key("launch", "gear") }, { [1] = false })
    gutils.add_edge(graph, key("deliver", "gear"), key("stuff", "gear"))
    node("recipe", "machine", "AND", { key("stuff", "gear"), key("stuff", "away-ore") })
    local old_contexts = logic.contexts
    local old_type_info = logic.type_info
    logic.contexts = {
        home = true,
        away = true,
    }
    logic.type_info = {
        start = {},
        room = { context = "room" },
        stuff = {},
        recipe = {},
        launch = { context = true },
        deliver = {},
    }
    local ok, err = pcall(function()
        local sort_info = breadth_first_sort(graph)
        local local_sort_info = top.sort(graph, nil, nil, {
            complex_contexts = true,
        })
        local machine_ind = sort_info.node_to_context_inds[key("recipe", "machine")].away
        local home_gears = sort_info.node_to_context_inds[key("stuff", "gear")].home
        -- Home's own gears come after home's first gears, but before the machine, so preferring them at home would take them
        local own_gears = sort_info.node_to_context_inds[key("recipe", "gear-from-ore")].home
        assert(own_gears > home_gears and own_gears < machine_ind)
        local function locked(recipe_name)
            return recipe_name ~= "machine"
        end
        local stats = {}
        assert(names(witness_recipes.of(graph, sort_info, machine_ind, locked, local_sort_info, stats)) == "gear-from-away-ore")
        assert(stats.preferred == nil)
    end)
    logic.contexts = old_contexts
    logic.type_info = old_type_info
    if not ok then
        error(err, 0)
    end
end)

test("without a sort with complex contexts nothing is preferred", function()
    with_two_rooms({}, function(graph, sort_info, local_sort_info, first_ind)
        local stats = {}
        assert(names(witness_recipes.of(graph, sort_info, first_ind("fuel"), two_room_gets_tech, nil, stats)) == "away-smelt,home-boiler")
        assert(next(stats) == nil)
    end)
end)

print(num_passed .. " tests passed")

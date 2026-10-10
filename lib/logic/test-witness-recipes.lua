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

-- The room of the toy graph's room node (named "home"), as the logic names a room node after its room
-- Contexts are numbered rooms (lib/graph/contexts.lua), so a room node only sends a context for a room the sort numbers; this was "room: home" while contexts were strings, which any room node's name could stand for
local HOME = "home"

local logic = {
    contexts = {
        [HOME] = true,
    },
    type_info = {
        start = {},
        -- Emitter: sends the context of the room named by the node
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
local ctx = require("lib/graph/contexts")
-- Contexts are numbers (lib/graph/contexts.lua); fixtures write them as their names, like a room's simple context "away", and edge abilities as the logic builders used to (lib/graph/contexts-for-tests.lua)
local fx = require("lib/graph/contexts-for-tests")
local C = fx.C

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
-- Rooms send the context of the room named by the node, so the room nodes are named like the rooms
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
        lossy = fx.edge({ [1] = false })
    end
    node("stuff", "boiler", "OR", { key("craft", "boiler") }, lossy)
    -- Moving boilers between rooms: launching forgets the room, and what arrives isn't the room's own
    node("launch", "boiler", "AND", { key("stuff", "boiler") })
    node("deliver", "boiler", "AND", { key("launch", "boiler") }, fx.edge({ [1] = false }))
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
        node("deliver", "scrap", "AND", { key("launch", "scrap") }, fx.edge({ [1] = false }))
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
    -- The rooms' simple contexts, in the order of the rooms' names
    local rooms = {}
    for room, _ in pairs(logic.contexts) do
        table.insert(rooms, room)
    end
    table.sort(rooms)
    local contexts = {}
    for _, room in pairs(rooms) do
        table.insert(contexts, C(room))
    end
    local sort_info = {
        pebble_keys = {},
        pebble_contexts = {},
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
                if sort_info.node_to_context_inds[node_key][context] == nil and (type(context_type) ~= "string" or top.context_room(context) == node.name) then
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
            table.insert(sort_info.pebble_keys, pebble.node_key)
            table.insert(sort_info.pebble_contexts, pebble.context)
            sort_info.node_to_context_inds[pebble.node_key][pebble.context] = #sort_info.pebble_keys
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
        assert(sort_info.node_to_context_inds[key("pickup", "boiler")][C("away")] < first_ind("away-boiler"))
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
        assert(sort_info.node_to_context_inds[key("deliver", "boiler")][C("away")] < sort_info.node_to_context_inds[key("craft", "boiler")][C("away")])
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
    node("deliver", "away-ore", "AND", { key("launch", "away-ore") }, fx.edge({ [1] = false }))
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
    node("deliver", "gear", "AND", { key("launch", "gear") }, fx.edge({ [1] = false }))
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
        local machine_ind = sort_info.node_to_context_inds[key("recipe", "machine")][C("away")]
        local home_gears = sort_info.node_to_context_inds[key("stuff", "gear")][C("home")]
        -- Home's own gears come after home's first gears, but before the machine, so preferring them at home would take them
        local own_gears = sort_info.node_to_context_inds[key("recipe", "gear-from-ore")][C("home")]
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

-- Where a tech is researched: a widget made in the target room needs a tech researched with a pack from each of two rooms (near-a, near-b), so the packs are shipped to one lab
-- Each room but home (the starting room) is discovered by a tech researched at home; away is one the target doesn't come after, discovered soonest
-- The sort ships both packs to every reached room in the same step, and lists the rooms by name, so away comes first, like Vulgora for Fulbis's discovery in the user's 2026-10-10 game
-- options.home_lab = false: home has no lab; options.near_a_makes_both: near-a makes both packs, so it can research before anything is shipped
local RESEARCH_ROOMS = {
    "away",
    "home",
    "near-a",
    "near-b",
    "target",
}
local function research_graph(options)
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
    node("stuff", "plate", "OR", { key("room", "home") })
    local discovery_steps = {
        away = 1,
        ["near-a"] = 2,
        ["near-b"] = 2,
        target = 3,
    }
    for room, steps in pairs(discovery_steps) do
        local last = key("stuff", "plate")
        for i = 1, steps do
            node("stuff", room .. "-step-" .. i, "OR", { last })
            last = key("stuff", room .. "-step-" .. i)
        end
        node("technology", "discover-" .. room, "AND", { last })
        node("room", room, "OR", { key("technology", "discover-" .. room) })
    end
    -- Somewhere reached, and somewhere a lab can be
    local reached = {}
    local lab_rooms = {}
    for _, room in pairs(RESEARCH_ROOMS) do
        table.insert(reached, key("room", room))
        if room ~= "home" or options.home_lab ~= false then
            table.insert(lab_rooms, key("room", room))
        end
    end
    node("here", "here", "OR", reached)
    node("stuff", "lab", "OR", lab_rooms)
    for _, pack in pairs({
        "a",
        "b",
    }) do
        local makers = { key("room", "near-" .. pack) }
        if options.near_a_makes_both == true then
            makers = { key("room", "near-a") }
        end
        node("recipe", "make-pack-" .. pack, "AND", makers)
        node("stuff", "pack-" .. pack, "OR", { key("recipe", "make-pack-" .. pack) })
        node("launch", "pack-" .. pack, "AND", { key("stuff", "pack-" .. pack) })
        node("deliver", "pack-" .. pack, "AND", {
            key("launch", "pack-" .. pack),
            key("here", "here"),
        })
        gutils.add_edge(graph, key("deliver", "pack-" .. pack), key("stuff", "pack-" .. pack))
    end
    node("research", "packs", "AND", {
        key("stuff", "pack-a"),
        key("stuff", "pack-b"),
        key("stuff", "lab"),
    })
    node("technology", "goal", "AND", { key("research", "packs") })
    node("stuff", "target-ore", "OR", { key("room", "target") })
    node("recipe", "widget", "AND", {
        key("stuff", "target-ore"),
        key("technology", "goal"),
    })
    return graph
end

-- Runs fn(graph, sort_info, widget_ind) with the research graph's rooms as the logic's contexts and home as the starting room
local function with_research_rooms(options, fn)
    local old_contexts = logic.contexts
    local old_type_info = logic.type_info
    local old_start = ctx.start_room
    logic.contexts = {}
    for _, room in pairs(RESEARCH_ROOMS) do
        logic.contexts[room] = true
    end
    logic.type_info = {
        start = {},
        room = { context = "room" },
        stuff = {},
        recipe = {},
        here = {},
        research = {},
        technology = { context = true },
        launch = { context = true },
        deliver = {},
    }
    ctx.start_room = "home"
    local ok, err = pcall(function()
        local graph = research_graph(options)
        local sort_info = breadth_first_sort(graph)
        -- Paths read a sort's contexts from its context info, and one cached for another test's rooms would lack these
        sort_info.context_info = top.sort(graph).context_info
        fn(graph, sort_info, sort_info.node_to_context_inds[key("recipe", "widget")][C("target")])
    end)
    logic.contexts = old_contexts
    logic.type_info = old_type_info
    ctx.start_room = old_start
    if not ok then
        error(err, 0)
    end
end

-- The room the path researches the goal in
local function research_room(sort_info, path_info)
    for ind, _ in pairs(path_info.in_path) do
        if sort_info.pebble_keys[ind] == key("research", "packs") then
            return top.context_room(sort_info.pebble_contexts[ind])
        end
    end
end

local function discovers(tech_name)
    return string.find(tech_name, "^discover%-") ~= nil
end

-- The target's home set: the rooms it comes after
local TARGET_HOME_SETS = {
    ids = { 1 },
    sets = {
        [1] = {
            rooms = {
                home = true,
                ["near-a"] = true,
                ["near-b"] = true,
            },
            discovered = {
                target = true,
            },
        },
    },
    of = {
        target = 1,
    },
}

test("a tech whose packs are shipped is researched in the starting room, not in whichever room the sort listed first at that step", function()
    with_research_rooms({}, function(graph, sort_info, widget_ind)
        -- The sort itself goes to away, which the widget doesn't need
        local earliest = top.path(graph, { widget_ind }, sort_info)
        assert(research_room(sort_info, earliest) == "away")
        local stats = {}
        local _, techs = witness_recipes.of(graph, sort_info, widget_ind, function() return false end, nil, stats, discovers, TARGET_HOME_SETS)
        assert(names(techs) == "discover-near-a,discover-near-b,discover-target")
        assert(stats.tied == 1)
        -- Without home sets too
        local _, plain_techs = witness_recipes.of(graph, sort_info, widget_ind, function() return false end, nil, nil, discovers)
        assert(names(plain_techs) == "discover-near-a,discover-near-b,discover-target")
    end)
end)

test("without a lab in the starting room, research goes to a room the witness's room comes after", function()
    with_research_rooms({ home_lab = false }, function(graph, sort_info, widget_ind)
        assert(research_room(sort_info, top.path(graph, { widget_ind }, sort_info)) == "away")
        local _, techs = witness_recipes.of(graph, sort_info, widget_ind, function() return false end, nil, nil, discovers, TARGET_HOME_SETS)
        assert(names(techs) == "discover-near-a,discover-near-b,discover-target")
        -- Without home sets, the target's own room
        local _, plain_techs = witness_recipes.of(graph, sort_info, widget_ind, function() return false end, nil, nil, discovers)
        assert(names(plain_techs) == "discover-near-a,discover-near-b,discover-target")
    end)
end)

test("a room that can research earlier keeps it: the rule only picks among rooms just as early", function()
    with_research_rooms({ near_a_makes_both = true }, function(graph, sort_info, widget_ind)
        assert(research_room(sort_info, top.path(graph, { widget_ind }, sort_info)) == "near-a")
        local stats = {}
        local _, techs = witness_recipes.of(graph, sort_info, widget_ind, function() return false end, nil, stats, discovers, TARGET_HOME_SETS)
        assert(names(techs) == "discover-near-a,discover-target")
        assert(stats.tied == nil)
    end)
end)

test("a discovery's own witness researches it in the starting room too", function()
    with_research_rooms({}, function(graph, sort_info)
        -- The target's discovery needs the goal tech here, so its research is the same choice
        gutils.add_edge(graph, key("technology", "goal"), key("technology", "discover-target"))
        local re_sorted = breadth_first_sort(graph)
        re_sorted.context_info = sort_info.context_info
        local goal_ind
        for _, ind in pairs(re_sorted.node_to_context_inds[key("technology", "goal")]) do
            if goal_ind == nil or ind < goal_ind then
                goal_ind = ind
            end
        end
        assert(research_room(re_sorted, top.path(graph, { goal_ind }, re_sorted)) == "away")
        local _, techs = witness_recipes.of(graph, re_sorted, goal_ind, function() return false end, nil, nil, discovers, TARGET_HOME_SETS)
        assert(names(techs) == "discover-near-a,discover-near-b")
    end)
end)

print(num_passed .. " tests passed")

-- Plain-Lua regression tests for ability contexts standing for weaker ones in context-sort.lua (top.implied_ability_contexts; not loaded by the mod)
-- Run from the mod root: lua lib/graph/test-implied-ability-contexts.lua
--
-- Sorts with the switch on are compared with sorts with it off that take the same node out of open at every step (top.choose_open)
-- Then every node should get the same contexts at the same step, so only ranks within a step can change, with fewer pebbles
-- The random worlds have rooms, forgetters, edges gaining and losing abilities, cycles, techs that discover planets (their edges gain automatability, like the logic's), research inputs and a spaceship

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

-- A seeded stand-in for the mod's rng, so that sorts choosing randomly can be run in different orders
local rng_state = 1
package.loaded["lib/random/rng"] = {
    int = function(_, max)
        rng_state = (rng_state * 1103515245 + 12345) % 2147483648
        -- The low bits of this generator repeat quickly, so use the high ones
        return math.floor(rng_state / 65536) % max + 1
    end,
}

local logic = {
    contexts = {},
    type_info = {
        start = {},
        -- Emitter: sends the context named by the node
        room = { context = "room" },
        stuff = {},
        make = {},
        spaceship = {},
        -- What research needs, like the logic's science pack sets and the labs for them
        ["science-set"] = { research_input = true },
        ["lab-set"] = { research_input = true },
        trigger = { research_input = true },
        -- Forgetters
        technology = { context = true, home_carrier = true },
        reach = { context = true },
        forget = { context = true },
    },
}
package.loaded["lib/logic/init"] = logic
package.loaded["lib/logic/state"] = package.loaded["lib/logic/init"]

-- Space locations the techs discover (read by top.discovered_rooms)
data = {
    raw = {},
}
package.loaded["lib/data-utils"] = {
    get_prot = function(_, name)
        return data.raw["planet"][name]
    end,
}

local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")
local ctx = require("lib/graph/contexts")
local fx = require("lib/graph/contexts-for-tests")
-- Contexts are numbers (lib/graph/contexts.lua), which the tests write as their names, like C(HOME .. " | 10") (lib/graph/contexts-for-tests.lua)
local C = fx.C

local key = gutils.key

local HOME = "planet: home"
local STATION = "surface: station"

local function new_graph()
    return {
        nodes = {},
        edges = {},
        sources = {},
    }
end

-- abilities are written as the logic builders used to write them, like { [1] = false }, and edges have them as a code (lib/graph/contexts.lua)
local function add_edge(graph, start, stop, abilities)
    if start == stop or graph.edges[gutils.ekey({ start = start, stop = stop })] ~= nil then
        return
    end
    local extra
    if abilities ~= nil then
        extra = {
            abilities = fx.edge(abilities),
        }
    end
    gutils.add_edge(graph, start, stop, extra)
end

local function random_abilities()
    local choices = {
        false,
        false,
        {
            [1] = false,
        },
        {
            [1] = true,
        },
        {
            [2] = true,
        },
        {
            [2] = false,
        },
        {
            [1] = true,
            [2] = false,
        },
        {
            [1] = false,
            [2] = true,
        },
    }
    local choice = choices[math.random(#choices)]
    if choice == false then
        return nil
    end
    return choice
end

----------------------------------------------------------------------
-- Random worlds
----------------------------------------------------------------------

-- A random world: home, a station reached by launching, planets found by techs and reached by spaceship, things made from rooms with edges gaining and losing abilities, forgetters shipping things, techs with science sets and labs, and back edges making cycles
local function random_world(seed)
    math.randomseed(seed)
    local num_planets = 1 + seed % 4
    local rooms = { HOME, STATION }
    for i = 1, num_planets do
        table.insert(rooms, "planet: p" .. i)
    end
    logic.contexts = {}
    for _, room in pairs(rooms) do
        logic.contexts[room] = true
    end
    data.raw["planet"] = {}
    data.raw["technology"] = {}

    local graph = new_graph()
    -- Things the random nodes can take, and techs
    local things = {}
    local techs = {}
    local function node(node_type, name, op)
        gutils.add_node(graph, node_type, name, {
            op = op,
        })
        return key(node_type, name)
    end
    -- A tech needing a science set of random things, labs and an earlier tech, all through edges gaining automatability as in the logic (lib/logic/concrete.lua)
    local function tech(name, needs)
        local tech_key = node("technology", name, "AND")
        local set_key = node("science-set", name, "AND")
        for _, need in pairs(needs) do
            add_edge(graph, need, set_key)
        end
        add_edge(graph, set_key, tech_key, { [2] = true })
        local labs_key = node("lab-set", name, "OR")
        add_edge(graph, things[1], labs_key)
        add_edge(graph, labs_key, tech_key, { [2] = true })
        if #techs > 0 then
            add_edge(graph, techs[math.random(#techs)], tech_key, { [2] = true })
        end
        table.insert(techs, tech_key)
        return tech_key
    end
    -- A thing made from what a room or a few things give, through edges with random abilities, sometimes shipped anywhere by a forgetter that loses isolatability
    local function thing(name, from)
        local make_key = node("make", name, math.random() < 0.7 and "AND" or "OR")
        for _, pre in pairs(from) do
            add_edge(graph, pre, make_key, random_abilities())
        end
        local thing_key = node("stuff", name, "OR")
        add_edge(graph, make_key, thing_key, random_abilities())
        if math.random() < 0.4 then
            local ship_key = node("forget", "ship-" .. name, "AND")
            add_edge(graph, thing_key, ship_key)
            add_edge(graph, ship_key, thing_key, { [1] = false })
        end
        table.insert(things, thing_key)
        return thing_key
    end

    local start = node("start", "", "AND")
    local home = node("room", HOME, "OR")
    add_edge(graph, start, home)
    thing("ore", { home })
    thing("plate", { things[1] })
    tech("t-basic", { things[2] })
    local t_platform = tech("t-platform", { things[1], things[2] })
    local launch = node("make", "launch", "AND")
    add_edge(graph, things[2], launch)
    add_edge(graph, t_platform, launch)
    local station = node("room", STATION, "OR")
    add_edge(graph, launch, station)
    thing("chunk", { station })
    local t_space = tech("t-space", { things[2], things[#things] })
    local spaceship = node("spaceship", "", "AND")
    add_edge(graph, station, spaceship)
    add_edge(graph, t_space, spaceship)
    for i = 1, num_planets do
        local planet = "p" .. i
        data.raw["planet"][planet] = {
            type = "planet",
            name = planet,
        }
        data.raw["technology"]["find-" .. planet] = {
            effects = {
                {
                    type = "unlock-space-location",
                    space_location = planet,
                },
            },
        }
        tech("find-" .. planet, { things[math.random(#things)], things[math.random(#things)] })
        local reach = node("reach", planet, "AND")
        add_edge(graph, techs[#techs], reach)
        add_edge(graph, spaceship, reach)
        local room = node("room", "planet: " .. planet, "OR")
        add_edge(graph, reach, room)
        thing("ore-" .. planet, { room })
    end
    -- Random things and techs, some needing a room directly
    local room_keys = {}
    for _, room in pairs(rooms) do
        table.insert(room_keys, key("room", room))
    end
    for i = 1, 6 + seed % 10 do
        if math.random() < 0.25 then
            tech("t-extra-" .. i, { things[math.random(#things)], things[math.random(#things)] })
        else
            local from = {}
            for _ = 1, math.random(1, 3) do
                if math.random() < 0.2 then
                    table.insert(from, room_keys[math.random(#room_keys)])
                elseif math.random() < 0.2 then
                    table.insert(from, techs[math.random(#techs)])
                else
                    table.insert(from, things[math.random(#things)])
                end
            end
            thing("x" .. i, from)
        end
    end
    -- Back edges, making cycles
    for _ = 1, 2 + seed % 4 do
        local a = things[math.random(#things)]
        local b = things[math.random(#things)]
        local make_b = key("make", gutils.deconstruct(b).name)
        add_edge(graph, a, make_b, random_abilities())
    end
    return graph
end

----------------------------------------------------------------------
-- Random solar systems (from lib/graph/test-research-home-contexts.lua)
----------------------------------------------------------------------

-- Packs from several planets reach the labs through shipping, which takes the sort longer than research home contexts, which count research without deliveries
-- So a tech can have the home context the discovery rule asks for before its plain contexts reach it, which is what these check

local RANDOM_HOME = "planet: home"
local RANDOM_STATION = "surface: station"

-- A random solar system with per-planet discovery: planets in tiers, each discovered with the packs of one or two planets in the tier before, shipping packs and some ores anywhere, extra techs needing random packs or met by triggers on a planet, an item made from two planets' ores, and things made on planets with techs
-- Shipping always works here, so research home contexts should count exactly what full ones do but for packs made from several planets
local function random_system(seed)
    math.randomseed(seed)
    local num_planets = 3 + seed % 5
    local planets = {}
    for i = 1, num_planets do
        table.insert(planets, "p" .. i)
    end
    local rooms = { RANDOM_HOME, RANDOM_STATION }
    for _, planet in pairs(planets) do
        table.insert(rooms, "planet: " .. planet)
    end
    logic.contexts = {}
    for _, room in pairs(rooms) do
        logic.contexts[room] = true
    end
    data.raw["planet"] = {}
    data.raw["technology"] = {}

    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local nodes = {}
    local function edge(start, stop, abilities)
        local extra
        if abilities ~= nil then
            extra = {
                abilities = fx.edge(abilities),
            }
        end
        gutils.add_edge(graph, nodes[start], nodes[stop], extra)
    end
    local function node(name, node_type, op, pres, node_name)
        gutils.add_node(graph, node_type, node_name or name, {
            op = op,
        })
        nodes[name] = key(node_type, node_name or name)
        for _, pre in pairs(pres) do
            edge(pre, name)
        end
    end
    local function shippable(item)
        node("ship-" .. item, "forget", "AND", { item })
        edge("ship-" .. item, item, {
            [1] = false,
        })
    end
    local techs = {}
    local function tech(name, packs, prereqs)
        node("set-" .. name, "science-set", "AND", packs)
        node("labs-" .. name, "lab-set", "OR", { "lab" })
        local pres = { "set-" .. name, "labs-" .. name }
        for _, prereq in pairs(prereqs) do
            table.insert(pres, prereq)
        end
        node(name, "technology", "AND", pres)
        table.insert(techs, name)
    end

    node("start", "start", "AND", {})
    node("home", "room", "OR", { "start" }, RANDOM_HOME)
    node("mine-ore", "make", "AND", { "home" })
    node("ore", "stuff", "OR", { "mine-ore" })
    node("make-red", "make", "AND", { "ore" })
    node("red", "stuff", "OR", { "make-red" })
    node("build-lab", "make", "AND", { "ore" })
    node("lab", "stuff", "OR", { "build-lab" })
    tech("t-basic", { "red" }, {})
    tech("t-platform", { "red" }, { "t-basic" })
    node("launch", "make", "AND", { "ore", "t-platform" })
    node("create-station", "make", "AND", { "launch" })
    node("station", "room", "OR", { "create-station" }, RANDOM_STATION)
    node("grab-chunk", "make", "AND", { "station" })
    node("chunk", "stuff", "OR", { "grab-chunk" })
    node("make-space", "make", "AND", { "chunk" })
    node("space", "stuff", "OR", { "make-space" })
    shippable("space")
    tech("t-space", { "red", "space" }, { "t-platform" })
    node("spaceship", "spaceship", "AND", { "station", "t-space" })

    -- The map: tiers, each planet with one or two neighbors in the tier before (home for the first tier)
    local tier_of = {}
    local by_tier = { [0] = { "home" } }
    local preds = {}
    for i, planet in pairs(planets) do
        local tier = 1
        if i > 1 then
            tier = math.random(1, math.min(3, #by_tier + 1))
            if by_tier[tier - 1] == nil then
                tier = #by_tier + 1
            end
        end
        tier_of[planet] = tier
        by_tier[tier] = by_tier[tier] or {}
        table.insert(by_tier[tier], planet)
        local before = by_tier[tier - 1]
        preds[planet] = { before[math.random(#before)] }
        if #before > 1 and math.random() < 0.5 then
            local other = before[math.random(#before)]
            if other ~= preds[planet][1] then
                table.insert(preds[planet], other)
            end
        end
    end
    for _, planet in pairs(planets) do
        data.raw["planet"][planet] = {
            type = "planet",
            name = planet,
        }
        data.raw["technology"]["find-" .. planet] = {
            effects = {
                {
                    type = "unlock-space-location",
                    space_location = planet,
                },
            },
        }
    end
    -- Planets in tier order, each with its ore and pack (shipped anywhere)
    local ordered = {}
    for tier = 1, #by_tier do
        for _, planet in pairs(by_tier[tier] or {}) do
            table.insert(ordered, planet)
        end
    end
    for _, planet in pairs(ordered) do
        local packs = { "red", "space" }
        local prereqs = { "t-space" }
        for _, pred in pairs(preds[planet]) do
            if pred ~= "home" then
                table.insert(packs, "pack-" .. pred)
                table.insert(prereqs, "find-" .. pred)
            end
        end
        tech("find-" .. planet, packs, prereqs)
        node("reach-" .. planet, "reach", "AND", { "find-" .. planet, "spaceship" })
        node(planet, "room", "OR", { "reach-" .. planet }, "planet: " .. planet)
        node("mine-" .. planet, "make", "AND", { planet })
        node("ore-" .. planet, "stuff", "OR", { "mine-" .. planet })
        node("make-pack-" .. planet, "make", "AND", { "ore-" .. planet })
        node("pack-" .. planet, "stuff", "OR", { "make-pack-" .. planet })
        shippable("pack-" .. planet)
        if math.random() < 0.5 then
            shippable("ore-" .. planet)
        end
    end
    -- Extra techs needing random packs (some from several planets), random prerequisites, and some research triggers
    local all_packs = { "red" }
    for _, planet in pairs(ordered) do
        table.insert(all_packs, "pack-" .. planet)
    end
    for i = 1, 6 + seed % 6 do
        local name = "t-extra-" .. i
        if math.random() < 0.3 then
            local planet = ordered[math.random(#ordered)]
            node("trig-" .. name, "trigger", "OR", { "ore-" .. planet })
            node(name, "technology", "AND", { "trig-" .. name, techs[math.random(#techs)] })
            table.insert(techs, name)
        else
            local packs = { "red" }
            for _ = 1, math.random(1, 3) do
                local pack = all_packs[math.random(#all_packs)]
                local seen = false
                for _, p in pairs(packs) do
                    if p == pack then
                        seen = true
                    end
                end
                if not seen then
                    table.insert(packs, pack)
                end
            end
            tech(name, packs, { techs[math.random(#techs)] })
        end
    end
    -- Items made from two planets' ores (where the ores ship), and packs made from them, which only full home contexts count
    local shipped_ores = {}
    for _, planet in pairs(ordered) do
        if nodes["ship-ore-" .. planet] ~= nil then
            table.insert(shipped_ores, planet)
        end
    end
    if #shipped_ores >= 2 then
        local a = shipped_ores[1]
        local b = shipped_ores[2]
        node("make-mix", "make", "AND", { "ore-" .. a, "ore-" .. b })
        node("mix", "stuff", "OR", { "make-mix" })
        shippable("mix")
        tech("t-mix", { "red", "mix" }, { techs[math.random(#techs)] })
    end
    -- Things made on planets with techs, so the discovery rule's isolatability flows on
    for _, planet in pairs(ordered) do
        local t = techs[math.random(#techs)]
        node("use-" .. planet, "make", "AND", { "ore-" .. planet, t })
        node("thing-" .. planet, "stuff", "OR", { "use-" .. planet })
    end
    return graph, nodes
end


----------------------------------------------------------------------
-- Comparing sorts
----------------------------------------------------------------------

-- A picker for top.choose_open taking the open node first in an order the seed shuffles (a hash of the node key), so both sorts of a pair take the same node at every step while different seeds try different orders, as random picks do
local function seeded_picker(seed, run)
    local priority = {}
    local function priority_of(node_key)
        local value = priority[node_key]
        if value == nil then
            value = (seed * 2654435761) % 4294967296
            for i = 1, #node_key do
                value = (value * 31 + string.byte(node_key, i)) % 4294967296
            end
            priority[node_key] = value
        end
        return value
    end
    return function(open, num_pebbles)
        local chosen
        local chosen_priority
        for node_key, _ in pairs(open) do
            local value = priority_of(node_key)
            if chosen == nil or value < chosen_priority or (value == chosen_priority and node_key < chosen) then
                chosen = node_key
                chosen_priority = value
            end
        end
        table.insert(run.keys, chosen)
        table.insert(run.starts, num_pebbles)
        return chosen
    end
end

-- Sorts a graph with the switch off and on, taking the same open node at every step (seeded_picker)
-- Returns a run for each: { sort_info, keys = node key taken at each step, starts = how many pebbles there were before each step, pop_of = pebble index --> its step }
local function lockstep(graph, extra, order_seed)
    local runs = {}
    for _, implied in pairs({ false, true }) do
        local run = {
            keys = {},
            starts = {},
        }
        top.choose_open = seeded_picker(order_seed or 0, run)
        top.implied_ability_contexts = implied
        local ok, result = pcall(top.sort, graph, nil, nil, table.deepcopy(extra))
        top.choose_open = nil
        top.implied_ability_contexts = true
        if not ok then
            error(result)
        end
        run.sort_info = result
        run.pop_of = {}
        local num_pebbles = #result.pebble_keys
        for step = 1, #run.starts do
            for ind = run.starts[step] + 1, run.starts[step + 1] or num_pebbles do
                run.pop_of[ind] = step
            end
        end
        runs[implied] = run
    end
    return runs[false], runs[true]
end

local function is_ability_context(context)
    return top.context_home(context) == nil and top.context_mask(context) ~= nil
end

-- Whether every node's contexts in a room are downward closed: each context's weaker ones in its room are there too
local function closed(sort_info)
    for node_key, inds in pairs(sort_info.node_to_context_inds) do
        for context, _ in pairs(inds) do
            if is_ability_context(context) then
                local room = top.context_room(context)
                for _, mask in pairs(top.weaker_masks(top.context_mask(context))) do
                    if inds[top.context_key(room, mask)] == nil then
                        return false, node_key .. " has " .. top.context_name(context) .. " but not " .. top.context_name(top.context_key(room, mask))
                    end
                end
            end
        end
    end
    return true
end

-- The step a rank was reached at: its pebble's, for the rank of a context a pebble stands for
local function step_of(run, rank)
    return run.pop_of[math.ceil(rank)]
end

-- Checks a lockstep pair: the same steps, every context at the same step, the contexts pebbles stand for ranked just below them and read through the lists, each own pebble of a weaker context earlier than every stronger one of its room, and top.each_rank going through every rank once in order
-- Returns the number of pebbles of each
local function compare(old, new, what)
    assert(#old.keys == #new.keys, what .. ": " .. #old.keys .. " steps without, " .. #new.keys .. " with")
    for step = 1, #old.keys do
        assert(old.keys[step] == new.keys[step], what .. ": step " .. step .. " took " .. old.keys[step] .. " without, " .. new.keys[step] .. " with")
    end
    local old_inds = old.sort_info.node_to_context_inds
    local new_inds = new.sort_info.node_to_context_inds
    local new_keys = new.sort_info.pebble_keys
    local new_contexts = new.sort_info.pebble_contexts
    local ok, problem = closed(old.sort_info)
    assert(ok, what .. ": the sort without the switch isn't downward closed: " .. tostring(problem))
    for node_key, inds in pairs(old_inds) do
        for context, ind in pairs(inds) do
            local new_rank = new_inds[node_key][context]
            assert(new_rank ~= nil, what .. ": " .. node_key .. " lost " .. top.context_name(context))
            assert(step_of(old, ind) == step_of(new, new_rank), what .. ": " .. node_key .. " got " .. top.context_name(context) .. " at step " .. tostring(step_of(old, ind)) .. " without, " .. tostring(step_of(new, new_rank)) .. " with")
        end
    end
    -- Ranks of contexts that aren't bigger home sets' standing in for a smaller one's pebble (top.implied_home_contexts), which share its index
    local own_ranks = {}
    for node_key, inds in pairs(new_inds) do
        for context, rank in pairs(inds) do
            assert(old_inds[node_key][context] ~= nil, what .. ": " .. node_key .. " gained " .. top.context_name(context))
            assert(new_keys[rank] == node_key, what .. ": " .. node_key .. " @ " .. top.context_name(context) .. " has another node's rank")
            if rank ~= math.floor(rank) then
                -- Stood for by the stronger pebble of its room just after it
                local own = new_contexts[math.ceil(rank)]
                assert(is_ability_context(context) and is_ability_context(own) and top.context_room(own) == top.context_room(context) and own ~= context and top.mask_covers(top.context_mask(own), top.context_mask(context)), what .. ": " .. node_key .. " @ " .. top.context_name(context) .. " ranks below " .. top.context_name(own))
            end
            if new_contexts[rank] == context then
                own_ranks[rank] = node_key .. " @@ " .. context
            else
                assert(top.context_home(context) ~= nil and top.context_home(new_contexts[rank]) ~= nil, what .. ": " .. node_key .. " @ " .. top.context_name(context) .. " has the rank of " .. top.context_name(new_contexts[rank]))
            end
            if is_ability_context(context) and rank == math.floor(rank) then
                -- A pebble of its own means no stronger context of its room came at its step or before, but for a tech's context the discovery rule gave in its step, which comes after its others
                local room = top.context_room(context)
                for _, stronger_mask in pairs(ctx.masks) do
                    local stronger = top.context_key(room, stronger_mask)
                    if stronger ~= context and top.mask_covers(stronger_mask, top.context_mask(context)) and inds[stronger] ~= nil then
                        local later = step_of(new, inds[stronger]) > step_of(new, rank)
                        local discovered_after = step_of(new, inds[stronger]) == step_of(new, rank) and gutils.deconstruct(node_key).type == "technology" and inds[stronger] > rank and top.has_ability(stronger_mask, top.ISOLATABILITY)
                        assert(later or discovered_after, what .. ": " .. node_key .. " @ " .. top.context_name(context) .. " is a pebble though " .. top.context_name(stronger) .. " came at its step or before")
                    end
                end
            end
        end
    end
    -- top.each_rank goes through those ranks once each, in order
    local last
    local num_given = 0
    for rank in top.each_rank(new.sort_info) do
        assert(last == nil or rank > last, what .. ": each_rank went from " .. tostring(last) .. " to " .. tostring(rank))
        last = rank
        assert(own_ranks[rank] ~= nil, what .. ": each_rank gave rank " .. rank .. ", which no context has as its own")
        num_given = num_given + 1
    end
    local num_own = 0
    for _, _ in pairs(own_ranks) do
        num_own = num_own + 1
    end
    assert(num_given == num_own, what .. ": each_rank gave " .. num_given .. " ranks of " .. num_own)
    return #old.sort_info.pebble_keys, #new.sort_info.pebble_keys
end

-- Like lockstep, for a sort continued through a new edge from start to stop (as unified's debt and staged sorts continue theirs)
-- The processing argument is do_new_edge_processing: whether the stop node is checked like any dependent, rather than given everything start has
local function lockstep_continued(graph, extra, start, stop, processing, order_seed)
    local runs = {}
    for _, implied in pairs({ false, true }) do
        local run = {
            keys = {},
            starts = {},
        }
        top.choose_open = seeded_picker(order_seed or 0, run)
        top.implied_ability_contexts = implied
        local copy = table.deepcopy(graph)
        local ok, result = pcall(function()
            local sort_info = top.sort(copy, nil, nil, table.deepcopy(extra))
            add_edge(copy, start, stop)
            return top.sort(copy, sort_info, { copy.nodes[start], copy.nodes[stop] }, {
                choose_randomly = true,
                do_new_edge_processing = processing,
            })
        end)
        top.choose_open = nil
        top.implied_ability_contexts = true
        if not ok then
            error(result)
        end
        run.graph = copy
        run.sort_info = result
        run.pop_of = {}
        local num_pebbles = #result.pebble_keys
        for step = 1, #run.starts do
            for ind = run.starts[step] + 1, run.starts[step + 1] or num_pebbles do
                run.pop_of[ind] = step
            end
        end
        runs[implied] = run
    end
    return runs[false], runs[true]
end

-- Every pebble's path in a sort, from its own index and from the indices of the contexts it stands for (top.path checks each backing is earlier)
local function check_paths(graph, sort_info, what)
    for node_key, inds in pairs(sort_info.node_to_context_inds) do
        for context, ind in pairs(inds) do
            local ok, problem = pcall(top.path, graph, { ind }, sort_info)
            assert(ok, what .. ": no path for " .. node_key .. " @ " .. top.context_name(context) .. ": " .. tostring(problem))
        end
    end
end

----------------------------------------------------------------------
-- Tests
----------------------------------------------------------------------

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

test("the mask an edge makes of a mask stands for every mask the edge gives from it and the masks it stands for", function()
    for code, _ in pairs(ctx.FORWARD_MASKS) do
        for _, mask in pairs(ctx.masks) do
            local given = {}
            local sources = { mask }
            for _, weaker in pairs(top.weaker_masks(mask)) do
                table.insert(sources, weaker)
            end
            for _, source in pairs(sources) do
                for _, out in pairs(ctx.forward_masks(code, source)) do
                    given[out] = true
                end
            end
            local strongest = top.strongest_forward(code, mask)
            local stood_for = { [strongest] = true }
            for _, weaker in pairs(top.weaker_masks(strongest)) do
                stood_for[weaker] = true
            end
            for _, out in pairs(ctx.masks) do
                assert((given[out] == true) == (stood_for[out] == true), "edge code " .. code .. ", mask " .. top.mask_name(mask) .. ": " .. top.mask_name(out) .. " given " .. tostring(given[out] == true) .. ", stood for " .. tostring(stood_for[out] == true))
            end
        end
    end
end)

test("a weaker context reached before any stronger one keeps its own earlier pebble, like wood picked by hand before it's grown", function()
    logic.contexts = {
        [HOME] = true,
    }
    data.raw["planet"] = {}
    data.raw["technology"] = {}
    local graph = new_graph()
    gutils.add_node(graph, "start", "", { op = "AND" })
    gutils.add_node(graph, "room", HOME, { op = "OR" })
    add_edge(graph, key("start", ""), key("room", HOME))
    -- Picking loses automatability; growing needs a tech
    gutils.add_node(graph, "make", "pick", { op = "AND" })
    add_edge(graph, key("room", HOME), key("make", "pick"), { [2] = false })
    gutils.add_node(graph, "stuff", "ore", { op = "OR" })
    add_edge(graph, key("room", HOME), key("stuff", "ore"))
    gutils.add_node(graph, "technology", "t-grow", { op = "AND" })
    add_edge(graph, key("stuff", "ore"), key("technology", "t-grow"), { [2] = true })
    gutils.add_node(graph, "make", "grow", { op = "AND" })
    add_edge(graph, key("room", HOME), key("make", "grow"))
    add_edge(graph, key("technology", "t-grow"), key("make", "grow"))
    gutils.add_node(graph, "stuff", "wood", { op = "OR" })
    add_edge(graph, key("make", "pick"), key("stuff", "wood"))
    add_edge(graph, key("make", "grow"), key("stuff", "wood"))
    local fewer = false
    local picked_first = false
    for seed = 1, 20 do
        rng_state = seed
        local old, new = lockstep(graph, {
            choose_randomly = true,
            complex_contexts = true,
        }, seed)
        local num_old, num_new = compare(old, new, "wood, seed " .. seed)
        fewer = fewer or num_new < num_old
        local inds = new.sort_info.node_to_context_inds[key("stuff", "wood")]
        assert(inds[C(HOME .. " | 00")] < inds[C(HOME .. " | 01")], "wood is automatable no later than reachable")
        local wood_pebbles = {}
        for ind = 1, #new.sort_info.pebble_keys do
            if new.sort_info.pebble_keys[ind] == key("stuff", "wood") then
                table.insert(wood_pebbles, top.context_name(new.sort_info.pebble_contexts[ind]))
            end
        end
        -- Picked in an earlier step than grown: "10" stands for "00", and "11" comes later for "01"; picked and grown in one step: "11" alone
        local old_inds = old.sort_info.node_to_context_inds[key("stuff", "wood")]
        if old.pop_of[old_inds[C(HOME .. " | 00")]] < old.pop_of[old_inds[C(HOME .. " | 01")]] then
            picked_first = true
            assert(table.concat(wood_pebbles, ", ") == HOME .. " | 10, " .. HOME .. " | 11", "wood's pebbles: " .. table.concat(wood_pebbles, ", "))
        else
            assert(table.concat(wood_pebbles, ", ") == HOME .. " | 11", "wood's pebbles: " .. table.concat(wood_pebbles, ", "))
        end
        check_paths(graph, new.sort_info, "wood, seed " .. seed)
    end
    assert(fewer, "no pebbles saved")
    assert(picked_first, "no order picked wood before growing it")
end)

test("on random worlds, every node gets the same contexts at the same step with fewer pebbles, without home contexts", function()
    local saved = 0
    local total = 0
    for seed = 1, 60 do
        local graph = random_world(seed)
        local old, new = lockstep(graph, {
            choose_randomly = true,
            complex_contexts = true,
        }, seed)
        local num_old, num_new = compare(old, new, "seed " .. seed)
        saved = saved + num_old - num_new
        total = total + num_old
        check_paths(graph, new.sort_info, "seed " .. seed)
    end
    assert(saved > 0, "no pebbles saved")
    print("  " .. saved .. " of " .. total .. " pebbles saved")
end)

test("on random worlds, the same with home contexts, full or kept to research", function()
    for seed = 1, 60 do
        local graph = random_world(seed)
        for _, research in pairs({ false, true }) do
            local was = top.research_home_contexts
            top.research_home_contexts = research
            local old, new = lockstep(graph, {
                choose_randomly = true,
                complex_contexts = true,
                home_contexts = true,
            }, seed)
            top.research_home_contexts = was
            local what = "seed " .. seed .. (research and ", research home contexts" or ", full home contexts")
            compare(old, new, what)
            check_paths(graph, new.sort_info, what)
        end
    end
end)

test("sorts without complex contexts are unchanged", function()
    for seed = 1, 20 do
        local graph = random_world(seed)
        local old, new = lockstep(graph, {
            choose_randomly = true,
        }, seed)
        assert(#old.sort_info.pebble_keys == #new.sort_info.pebble_keys, "seed " .. seed .. ": the number of pebbles changed")
        for ind = 1, #old.sort_info.pebble_keys do
            assert(old.sort_info.pebble_keys[ind] == new.sort_info.pebble_keys[ind] and old.sort_info.pebble_contexts[ind] == new.sort_info.pebble_contexts[ind], "seed " .. seed .. ": pebble " .. ind .. " changed")
        end
    end
end)

test("a cached sort with a new edge gets every context a fresh sort does", function()
    for seed = 1, 30 do
        local graph = random_world(seed)
        -- A new edge from a random thing into a random OR node, like a debt edge (a cached sort only gains contexts, so an edge into an AND node isn't one it can take)
        math.randomseed(seed * 7)
        local starts = {}
        local stops = {}
        for node_key, node in pairs(graph.nodes) do
            if node.type == "stuff" then
                table.insert(starts, node_key)
            end
            if node.op == "OR" and (node.type == "make" or node.type == "stuff") then
                table.insert(stops, node_key)
            end
        end
        table.sort(starts)
        table.sort(stops)
        local start = starts[math.random(#starts)]
        local stop = stops[math.random(#stops)]
        if graph.edges[gutils.ekey({ start = start, stop = stop })] == nil then
            rng_state = seed
            -- The same home sets for both, though the new edge may change what the graph's own would be
            local extra = {
                choose_randomly = true,
                complex_contexts = true,
                home_contexts = true,
                home_sets = top.home_sets(graph),
            }
            local cached = top.sort(graph, nil, nil, table.deepcopy(extra))
            add_edge(graph, start, stop)
            cached = top.sort(graph, cached, { graph.nodes[start], graph.nodes[stop] }, {
                choose_randomly = true,
            })
            rng_state = seed
            local fresh = top.sort(graph, nil, nil, table.deepcopy(extra))
            for node_key, inds in pairs(fresh.node_to_context_inds) do
                for context, _ in pairs(inds) do
                    assert(cached.node_to_context_inds[node_key][context] ~= nil, "seed " .. seed .. ": the cached sort lacks " .. node_key .. " @ " .. top.context_name(context))
                end
                for context, _ in pairs(cached.node_to_context_inds[node_key]) do
                    assert(inds[context] ~= nil, "seed " .. seed .. ": the cached sort has " .. node_key .. " @ " .. top.context_name(context) .. " the fresh one lacks")
                end
            end
            local ok, problem = closed(cached)
            assert(ok, "seed " .. seed .. ": " .. tostring(problem))
        end
    end
end)

test("sorts continued through a new edge get the same contexts at the same steps, checking the edge's stop like any dependent", function()
    for seed = 1, 40 do
        local graph = random_world(seed)
        math.randomseed(seed * 13)
        local keys = {}
        for node_key, node in pairs(graph.nodes) do
            if node.type == "stuff" or node.type == "make" or node.type == "technology" then
                table.insert(keys, node_key)
            end
        end
        table.sort(keys)
        local start = keys[math.random(#keys)]
        local stop = keys[math.random(#keys)]
        if start ~= stop and graph.edges[gutils.ekey({ start = start, stop = stop })] == nil then
            for _, home in pairs({ false, true }) do
                local what = "seed " .. seed .. (home and ", home contexts" or "") .. ", new edge " .. start .. " --> " .. stop
                local extra = {
                    choose_randomly = true,
                    complex_contexts = true,
                    home_contexts = home,
                }
                if home then
                    extra.home_sets = top.home_sets(graph)
                end
                local old, new = lockstep_continued(graph, extra, start, stop, true, seed)
                compare(old, new, what)
                -- A new edge into an AND node leaves the node's earlier pebbles without a backing through it, with the switch off too, so paths are only checked for OR nodes
                if graph.nodes[stop].op == "OR" then
                    check_paths(new.graph, new.sort_info, what)
                end
            end
        end
    end
end)

test("sorts continued through a new edge that gives its stop everything get the same contexts, keeping the ranks of those it had", function()
    for seed = 1, 40 do
        local graph = random_world(seed)
        math.randomseed(seed * 17)
        local starts = {}
        local stops = {}
        for node_key, node in pairs(graph.nodes) do
            if node.type == "stuff" then
                table.insert(starts, node_key)
            end
            if node.op == "OR" and (node.type == "make" or node.type == "stuff") then
                table.insert(stops, node_key)
            end
        end
        table.sort(starts)
        table.sort(stops)
        local start = starts[math.random(#starts)]
        local stop = stops[math.random(#stops)]
        if start ~= stop and graph.edges[gutils.ekey({ start = start, stop = stop })] == nil then
            local what = "seed " .. seed .. ", new edge " .. start .. " --> " .. stop
            local old, new = lockstep_continued(graph, {
                choose_randomly = true,
                complex_contexts = true,
            }, start, stop, false, seed)
            local old_inds = old.sort_info.node_to_context_inds
            local new_inds = new.sort_info.node_to_context_inds
            for node_key, inds in pairs(old_inds) do
                for context, _ in pairs(inds) do
                    assert(new_inds[node_key][context] ~= nil, what .. ": " .. node_key .. " lost " .. top.context_name(context))
                end
                for context, _ in pairs(new_inds[node_key]) do
                    assert(inds[context] ~= nil, what .. ": " .. node_key .. " gained " .. top.context_name(context))
                end
            end
            check_paths(new.graph, new.sort_info, what)
        end
    end
end)

test("on random solar systems, where research counts before deliveries reach the labs, the same contexts come at the same steps and every rank has a path", function()
    for seed = 1, 40 do
        local graph = random_system(seed)
        local home_sets = top.home_sets(graph)
        for _, research in pairs({ true, false }) do
            local was = top.research_home_contexts
            top.research_home_contexts = research
            local old, new = lockstep(graph, {
                choose_randomly = true,
                complex_contexts = true,
                home_contexts = true,
                home_sets = home_sets,
            }, seed)
            top.research_home_contexts = was
            local what = "system " .. seed .. (research and ", research home contexts" or ", full home contexts")
            compare(old, new, what)
            check_paths(graph, new.sort_info, what)
        end
    end
end)

test("the discovery rule makes a tech isolatable in a room only once it's had there at all", function()
    local num_waited = 0
    for seed = 1, 40 do
        local graph = random_system(seed)
        rng_state = seed
        local sort_info = top.sort(graph, nil, nil, {
            choose_randomly = true,
            complex_contexts = true,
            home_contexts = true,
            home_sets = top.home_sets(graph),
        })
        for node_key, inds in pairs(sort_info.node_to_context_inds) do
            if graph.nodes[node_key].type == "technology" then
                for context, rank in pairs(inds) do
                    if top.context_home(context) == nil and top.has_ability(top.context_mask(context), top.ISOLATABILITY) then
                        local plain = top.context_key(top.context_room(context), top.without_ability(top.context_mask(context), top.ISOLATABILITY))
                        assert(inds[plain] ~= nil and inds[plain] < rank, "system " .. seed .. ": " .. node_key .. " has " .. top.context_name(context) .. " before " .. top.context_name(plain))
                    end
                end
            end
        end
        for _, rooms in pairs(sort_info.pending_discovery) do
            for _, _ in pairs(rooms) do
                num_waited = num_waited + 1
            end
        end
    end
    -- Every wait ends once the tech's plain contexts come, which in these systems they always do
    assert(num_waited == 0, num_waited .. " discoveries still wait at the end")
end)

print(num_passed .. " tests passed")

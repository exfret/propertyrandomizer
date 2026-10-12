-- Plain-Lua regression tests for research home contexts in context-sort.lua (top.research_home_contexts; not loaded by the mod)
-- Run from the mod root: lua tests/unit/lib/sort/test-research-home-contexts.lua
--
-- The toy graph is a small solar system: a home planet with the only labs, a station (a space surface) making space packs, two planets discovered from home that each make a pack, and a far planet whose discovery takes both of their packs
-- Packs are shipped to the labs by forgetters that lose isolatability, like the logic's deliveries
-- Full home contexts (removing the other rooms and sorting again, test-home-contexts.lua) are the reference: research home contexts give techs the same home sets as long as each pack is made from its own planet's resources or the core's
-- The core is the rooms in every home set: here home and the station, which is the inner planets' home set, so that one keeps full home contexts

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
package.loaded["src/lib/random/rng"] = {
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
        -- What research needs, like the logic's science pack sets, the labs for them and research triggers
        ["science-set"] = { research_input = true },
        ["lab-set"] = { research_input = true },
        trigger = { research_input = true },
        -- Like the logic's deliver and item-launch: research inputs too, since a send-item-to-orbit trigger needs them
        deliver = { research_input = true },
        launch = { context = true, research_input = true },
        -- Relays standing for parts of an edge, like unified's bases and heads
        base = { relay = true },
        head = { relay = true },
        -- Forgetters
        technology = { context = true, home_carrier = true },
        reach = { context = true },
        forget = { context = true },
    },
}
package.loaded["src/logic/init"] = logic
package.loaded["src/logic/state"] = package.loaded["src/logic/init"]

-- Space locations the toy techs discover (read by top.discovered_rooms)
data = {
    raw = {},
}
package.loaded["src/prototypes/data-utils"] = {
    get_prot = function(_, name)
        return data.raw["planet"][name]
    end,
}

local gutils = require("src/lib/graph/graph-utils")
local top = require("src/lib/sort/context-sort")
local fx = require("tests/unit/logic/contexts/contexts-for-tests")
-- Contexts are numbers (src/logic/contexts/contexts.lua), which the tests write as their names, like C(ROCK .. " | 10") (tests/unit/logic/contexts/contexts-for-tests.lua)
local C = fx.C

local key = gutils.key

local function set_rooms(rooms)
    logic.contexts = {}
    for _, room in pairs(rooms) do
        logic.contexts[room] = true
    end
end

local function add_edge(graph, start, stop, abilities)
    local extra
    if abilities ~= nil then
        extra = {
            abilities = fx.edge(abilities),
        }
    end
    gutils.add_edge(graph, start, stop, extra)
end

----------------------------------------------------------------------
-- Toy solar system
----------------------------------------------------------------------

local HOME = "planet: home"
local ROCK = "planet: rock"
local MOSS = "planet: moss"
local FROST = "planet: frost"
local STATION = "surface: station"

-- Returns the graph and its node keys by short name
-- options.mixed adds a pack made on the moss planet from the rock planet's ore, which only full home contexts count
-- options.built_back adds ice from the far planet placed on the station once and taken back, isolatable there by the one-time grant, and a tech triggered by it
local function toy_graph(options)
    options = options or {}
    set_rooms({ HOME, ROCK, MOSS, FROST, STATION })
    data.raw["planet"] = {}
    data.raw["technology"] = {}
    for _, planet in pairs({ "rock", "moss", "frost" }) do
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

    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local nodes = {}
    local function node(name, node_type, op, pres, node_name)
        gutils.add_node(graph, node_type, node_name or name, {
            op = op,
        })
        nodes[name] = key(node_type, node_name or name)
        for _, pre in pairs(pres) do
            add_edge(graph, nodes[pre], nodes[name])
        end
    end
    -- Shipped anywhere by a forgetter, which loses isolatability (like the logic's item-launch and item-deliver)
    local function shippable(item)
        node("ship-" .. item, "forget", "AND", { item })
        add_edge(graph, nodes["ship-" .. item], nodes[item], {
            [1] = false,
        })
    end
    -- A tech researched with these packs in a lab, after these prerequisites
    local function tech(name, packs, prereqs)
        node("set-" .. name, "science-set", "AND", packs)
        node("labs-" .. name, "lab-set", "OR", { "lab" })
        local pres = { "set-" .. name, "labs-" .. name }
        for _, prereq in pairs(prereqs) do
            table.insert(pres, prereq)
        end
        node(name, "technology", "AND", pres)
    end

    node("start", "start", "AND", {})
    node("home", "room", "OR", { "start" }, HOME)
    node("mine-ore", "make", "AND", { "home" })
    node("ore", "stuff", "OR", { "mine-ore" })
    node("make-red", "make", "AND", { "ore" })
    node("red", "stuff", "OR", { "make-red" })
    -- Labs are only built at home
    node("build-lab", "make", "AND", { "ore" })
    node("lab", "stuff", "OR", { "build-lab" })
    tech("t-basic", { "red" }, {})
    tech("t-platform", { "red" }, { "t-basic" })
    node("launch", "make", "AND", { "ore", "t-platform" })
    node("create-station", "make", "AND", { "launch" })
    node("station", "room", "OR", { "create-station" }, STATION)
    node("grab-chunk", "make", "AND", { "station" })
    node("chunk", "stuff", "OR", { "grab-chunk" })
    node("make-space", "make", "AND", { "chunk" })
    node("space", "stuff", "OR", { "make-space" })
    shippable("space")
    -- Packs from two rooms meet in home's labs
    tech("t-space", { "red", "space" }, { "t-platform" })
    node("spaceship", "spaceship", "AND", { "station", "t-space" })
    tech("find-rock", { "red", "space" }, { "t-space" })
    tech("find-moss", { "red", "space" }, { "t-space" })
    node("reach-rock", "reach", "AND", { "find-rock", "spaceship" })
    node("rock", "room", "OR", { "reach-rock" }, ROCK)
    node("mine-rock", "make", "AND", { "rock" })
    node("rock-ore", "stuff", "OR", { "mine-rock" })
    node("make-rock-pack", "make", "AND", { "rock-ore" })
    node("rock-pack", "stuff", "OR", { "make-rock-pack" })
    shippable("rock-pack")
    node("reach-moss", "reach", "AND", { "find-moss", "spaceship" })
    node("moss", "room", "OR", { "reach-moss" }, MOSS)
    node("grow", "make", "AND", { "moss" })
    node("goo", "stuff", "OR", { "grow" })
    node("make-moss-pack", "make", "AND", { "goo" })
    node("moss-pack", "stuff", "OR", { "make-moss-pack" })
    shippable("moss-pack")
    tech("t-rock", { "red", "rock-pack" }, { "find-rock" })
    tech("t-moss", { "red", "moss-pack" }, { "find-moss" })
    -- Like a mine-entity trigger on the rock planet
    node("trig-rock", "trigger", "OR", { "rock-ore" })
    node("t-trig", "technology", "AND", { "trig-rock", "find-rock" })
    -- Per-planet discovery: the far planet takes the packs of both planets before it
    tech("find-frost", { "red", "space", "rock-pack", "moss-pack" }, { "find-rock", "find-moss" })
    node("reach-frost", "reach", "AND", { "find-frost", "spaceship" })
    node("frost", "room", "OR", { "reach-frost" }, FROST)
    -- Something on the far planet that needs a tech only home's research gives, so its isolatability there comes from the discovery rule
    node("frost-ice", "make", "AND", { "frost" })
    node("ice", "stuff", "OR", { "frost-ice" })
    node("melt", "make", "AND", { "ice", "t-rock" })
    node("water", "stuff", "OR", { "melt" })
    -- A tech researched by sending a satellite made at home into orbit, like Space Age's space science: launching loses isolatability (like the logic's deliver), but shipping is taken to work
    node("silo", "make", "AND", { "ore", "t-platform" })
    node("deliver", "deliver", "OR", {})
    add_edge(graph, nodes["silo"], nodes["deliver"], {
        [1] = false,
    })
    node("make-satellite", "make", "AND", { "ore" })
    node("satellite", "stuff", "OR", { "make-satellite" })
    node("launch-satellite", "launch", "AND", { "satellite", "deliver" })
    node("orbit", "trigger", "OR", { "launch-satellite" })
    node("t-orbit", "technology", "AND", { "orbit", "t-platform" })
    -- A launch that no research needs, which takes no home contexts
    node("launch-ore", "launch", "AND", { "ore", "deliver" })
    node("receive-ore", "make", "AND", { "launch-ore" })
    -- A tech researched by building something on the station that's made at home and shipped up, like Space Age's asteroid collector: never isolatable on the station, but the core's home set has it
    node("make-collector", "make", "AND", { "ore" })
    node("collector", "stuff", "OR", { "make-collector" })
    shippable("collector")
    node("build-collector", "make", "AND", { "collector", "station" })
    node("built-collector", "trigger", "OR", { "build-collector" })
    node("t-collector", "technology", "AND", { "built-collector", "t-platform" })
    -- A tech with no prerequisites at all, which research home contexts give every home set
    node("t-free", "technology", "AND", {})
    -- Relays between two techs carry home contexts, and relays to anything else don't
    node("b-tech", "base", "AND", { "t-basic" })
    node("h-tech", "head", "OR", { "b-tech" })
    tech("t-relayed", { "red" }, { "h-tech" })
    node("b-make", "base", "AND", { "t-basic" })
    node("h-make", "head", "OR", { "b-make" })
    node("use-tech", "make", "AND", { "h-make", "ore" })
    if options.mixed then
        shippable("rock-ore")
        node("make-mixed", "make", "AND", { "goo", "rock-ore" })
        node("mixed", "stuff", "OR", { "make-mixed" })
        shippable("mixed")
        tech("t-mixed", { "red", "mixed" }, { "find-moss" })
        node("melt-mixed", "make", "AND", { "ice", "t-mixed" })
        node("mixed-water", "stuff", "OR", { "melt-mixed" })
    end
    if options.built_back then
        -- Shipped up and placed on the station, which counts as isolatable there since it's built once (like a platform's tiles: tile-build-space in src/logic/builders/concrete.lua), then taken back: isolatable on the station, though only the far planet makes it
        shippable("ice")
        node("place-ice", "make", "AND", { "ice", "station" })
        node("placed-ice", "stuff", "OR", {})
        add_edge(graph, nodes["place-ice"], nodes["placed-ice"], {
            [1] = true,
        })
        node("take-back", "make", "AND", { "placed-ice" })
        node("ice-back", "stuff", "OR", { "take-back" })
        node("trig-ice", "trigger", "OR", { "ice-back" })
        node("t-ice", "technology", "AND", { "trig-ice", "t-platform" })
    end
    return graph, nodes
end

-- Sorts with complex and home contexts, research ones or full ones
local function home_sort(graph, research, seed, home_sets)
    local was = top.research_home_contexts
    top.research_home_contexts = research
    rng_state = seed or 1
    local sort_info = top.sort(graph, nil, nil, {
        choose_randomly = seed ~= nil,
        complex_contexts = true,
        home_contexts = true,
        home_sets = home_sets,
    })
    top.research_home_contexts = was
    return sort_info
end

-- Every pebble of a sort, as one sorted string, to compare sorts regardless of order
local function pebble_set(sort_info, keep)
    local pebbles = {}
    for node_key, inds in pairs(sort_info.node_to_context_inds) do
        for context, _ in pairs(inds) do
            if keep == nil or keep(node_key, context) then
                table.insert(pebbles, node_key .. " @@ " .. context)
            end
        end
    end
    table.sort(pebbles)
    return table.concat(pebbles, "\n")
end

local function is_not_home(_, context)
    return top.context_home(context) == nil
end

-- node key --> the home set ids it has a home context of, sorted and joined with commas
local function home_ids_of(sort_info, node_key)
    local ids = {}
    local seen = {}
    for context, _ in pairs(sort_info.node_to_context_inds[node_key] or {}) do
        local home_id = top.context_home(context)
        if home_id ~= nil and seen[home_id] == nil then
            seen[home_id] = true
            table.insert(ids, home_id)
        end
    end
    table.sort(ids)
    return table.concat(ids, ",")
end

-- Whether a comma-separated list of home set ids (from home_ids_of) has one
local function set_has(ids, home_id)
    for id in string.gmatch(ids, "[^,]+") do
        if id == tostring(home_id) then
            return true
        end
    end
    return false
end

local function has_isolatable(sort_info, node_key, room)
    return top.isolatable_in(sort_info.node_to_context_inds[node_key], room)
end

-- The core's home set id: the one whose rooms are in every home set
local function core_id_of(home_sets)
    for _, home_id in pairs(home_sets.ids) do
        local in_all = true
        for room, _ in pairs(home_sets.sets[home_id].rooms) do
            for _, other_id in pairs(home_sets.ids) do
                if home_sets.sets[other_id].rooms[room] == nil then
                    in_all = false
                end
            end
        end
        if in_all then
            return home_id
        end
    end
end


----------------------------------------------------------------------
-- Random solar systems
----------------------------------------------------------------------

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


-- A random system's sort with research home contexts or full ones, the latter with smaller home sets standing for bigger ones (implied) or not
local function random_sort(graph, home_sets, research, implied, seed)
    local was_research = top.research_home_contexts
    local was_implied = top.implied_home_contexts
    top.research_home_contexts = research
    top.implied_home_contexts = implied
    rng_state = seed
    local sort_info = top.sort(graph, nil, nil, {
        choose_randomly = true,
        complex_contexts = true,
        home_contexts = true,
        home_sets = home_sets,
    })
    top.research_home_contexts = was_research
    top.implied_home_contexts = was_implied
    return sort_info
end

-- Whether a random system's home sets don't all nest
local function non_nested(home_sets)
    for _, a in pairs(home_sets.ids) do
        for _, b in pairs(home_sets.ids) do
            local a_in_b = true
            local b_in_a = true
            for room, _ in pairs(home_sets.sets[a].rooms) do
                if home_sets.sets[b].rooms[room] == nil then
                    a_in_b = false
                end
            end
            for room, _ in pairs(home_sets.sets[b].rooms) do
                if home_sets.sets[a].rooms[room] == nil then
                    b_in_a = false
                end
            end
            if not a_in_b and not b_in_a then
                return true
            end
        end
    end
    return false
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

test("the toy graph's home sets are the station's and inner planets' set and the far planet's", function()
    local graph = toy_graph()
    local home_sets = top.home_sets(graph)
    local function rooms_of(room)
        local list = {}
        for set_room, _ in pairs(home_sets.sets[home_sets.of[room]].rooms) do
            table.insert(list, set_room)
        end
        table.sort(list)
        return table.concat(list, ",")
    end
    assert(rooms_of(ROCK) == HOME .. "," .. STATION, rooms_of(ROCK))
    assert(home_sets.of[ROCK] == home_sets.of[MOSS] and home_sets.of[ROCK] == home_sets.of[STATION])
    assert(rooms_of(FROST) == table.concat({ HOME, MOSS, ROCK, STATION }, ","), rooms_of(FROST))
end)

test("research home contexts are only on research, techs and relays leading to them, and the core's are everywhere", function()
    local graph, nodes = toy_graph({ mixed = true })
    local sort_info = home_sort(graph, true)
    local core = core_id_of(sort_info.home_sets)
    local far = sort_info.home_sets.of[FROST]
    assert(core == sort_info.home_sets.of[ROCK])
    for node_key, inds in pairs(sort_info.node_to_context_inds) do
        local info = logic.type_info[graph.nodes[node_key].type]
        for context, _ in pairs(inds) do
            local home_id = top.context_home(context)
            if home_id ~= nil and home_id ~= core then
                assert(info.research_input or info.home_carrier or info.relay, node_key .. " has home context " .. context)
            end
        end
    end
    local function has_home(node_key, home_id)
        return set_has(home_ids_of(sort_info, node_key), home_id)
    end
    assert(has_home(nodes["ore"], core), "the core's home contexts are on everything")
    assert(has_home(nodes["h-tech"], far), "a relay between techs carries home contexts")
    assert(not has_home(nodes["b-make"], far) and not has_home(nodes["h-make"], far), "relays to a machine carry research home contexts")
    assert(home_ids_of(sort_info, nodes["t-relayed"]) == home_ids_of(sort_info, nodes["t-basic"]))
    assert(not has_home(nodes["launch-ore"], far), "a launch no research needs carries research home contexts")
    assert(has_home(nodes["launch-satellite"], far))
end)

test("each home set but the core has a single research home context, and the core one per room of it", function()
    local graph = toy_graph()
    local sort_info = home_sort(graph, true)
    local core = core_id_of(sort_info.home_sets)
    local counts = {}
    for _, context in pairs(sort_info.contexts) do
        local home_id = top.context_home(context)
        if home_id ~= nil then
            counts[home_id] = (counts[home_id] or 0) + 1
        end
    end
    for _, home_id in pairs(sort_info.home_sets.ids) do
        if home_id == core then
            assert(counts[home_id] == 2, "the core has " .. tostring(counts[home_id]) .. " home contexts")
        else
            assert(counts[home_id] == 1, home_id .. " has " .. tostring(counts[home_id]) .. " home contexts")
        end
    end
end)

test("a tech whose packs come from different rooms of a home set gets that set's context", function()
    local graph, nodes = toy_graph()
    local sort_info = home_sort(graph, true)
    local home_sets = sort_info.home_sets
    local inner = home_sets.of[ROCK]
    local far = home_sets.of[FROST]
    -- Red packs from home and space packs from the station
    assert(home_ids_of(sort_info, nodes["t-space"]) == table.concat({ inner, far }, ","), home_ids_of(sort_info, nodes["t-space"]))
    -- The far planet's discovery takes the rock and moss planets' packs, which only the far planet's home set holds
    assert(home_ids_of(sort_info, nodes["find-frost"]) == tostring(far), home_ids_of(sort_info, nodes["find-frost"]))
    assert(home_ids_of(sort_info, nodes["t-rock"]) == tostring(far))
    -- A trigger met on the rock planet counts for the home sets holding it
    assert(home_ids_of(sort_info, nodes["t-trig"]) == tostring(far))
    -- A tech that needs nothing has every home set's context
    assert(home_ids_of(sort_info, nodes["t-free"]) == table.concat({ inner, far }, ","))
end)

test("a tech researched by building on the station with what home ships up counts, through the core", function()
    local graph, nodes = toy_graph()
    local sort_info = home_sort(graph, true)
    local home_sets = sort_info.home_sets
    assert(not has_isolatable(sort_info, nodes["build-collector"], STATION), "the toy's station builds should need shipping")
    assert(home_ids_of(sort_info, nodes["t-collector"]) == table.concat({ home_sets.of[ROCK], home_sets.of[FROST] }, ","), home_ids_of(sort_info, nodes["t-collector"]))
    assert(has_isolatable(sort_info, nodes["t-collector"], FROST))
end)

test("a tech researched by launching something counts, though launches are never isolatable", function()
    local graph, nodes = toy_graph()
    local sort_info = home_sort(graph, true)
    local home_sets = sort_info.home_sets
    assert(not has_isolatable(sort_info, nodes["launch-satellite"], HOME), "the toy's launches should lose isolatability")
    assert(home_ids_of(sort_info, nodes["t-orbit"]) == table.concat({ home_sets.of[ROCK], home_sets.of[FROST] }, ","), home_ids_of(sort_info, nodes["t-orbit"]))
    -- And so it's isolatable on the planets those home sets discover
    assert(has_isolatable(sort_info, nodes["t-orbit"], ROCK))
end)

test("the discovery rule makes home techs isolatable on the planets their home set discovers", function()
    local graph, nodes = toy_graph()
    local sort_info = home_sort(graph, true)
    -- Researched at home with the rock planet's packs, so isolatable on the far planet once it's discovered, and so is what it lets the far planet make
    assert(has_isolatable(sort_info, nodes["t-rock"], FROST))
    assert(has_isolatable(sort_info, nodes["water"], FROST))
    assert(not has_isolatable(sort_info, nodes["t-rock"], ROCK), "the rock planet's own home set doesn't hold it")
    assert(has_isolatable(sort_info, nodes["t-space"], ROCK))
end)

test("research home contexts give techs the same home sets and the sort the same other pebbles as full home contexts, when every pack is made from its own room's resources", function()
    for _, seed in pairs({ 1, 2, 3, 4, 5 }) do
        local graph = toy_graph()
        local home_sets = top.home_sets(graph)
        local research = home_sort(graph, true, seed, home_sets)
        local full = home_sort(graph, false, seed + 100, home_sets)
        assert(pebble_set(research, is_not_home) == pebble_set(full, is_not_home), "research home contexts changed other pebbles (seed " .. seed .. ")")
        for node_key, node in pairs(graph.nodes) do
            if node.type == "technology" then
                assert(home_ids_of(research, node_key) == home_ids_of(full, node_key), node_key .. ": research " .. home_ids_of(research, node_key) .. ", full " .. home_ids_of(full, node_key))
            end
        end
    end
end)

test("a pack made from another planet's item counts for full home contexts but not research ones", function()
    local graph, nodes = toy_graph({ mixed = true })
    local home_sets = top.home_sets(graph)
    local research = home_sort(graph, true, nil, home_sets)
    local full = home_sort(graph, false, nil, home_sets)
    local far = home_sets.of[FROST]
    assert(home_ids_of(full, nodes["t-mixed"]) == tostring(far), home_ids_of(full, nodes["t-mixed"]))
    assert(home_ids_of(research, nodes["t-mixed"]) == "", home_ids_of(research, nodes["t-mixed"]))
    assert(has_isolatable(full, nodes["mixed-water"], FROST))
    assert(not has_isolatable(research, nodes["mixed-water"], FROST))
    -- Everything else stays the same
    local function not_mixed(node_key, context)
        return is_not_home(node_key, context) and node_key ~= nodes["t-mixed"] and node_key ~= nodes["melt-mixed"] and node_key ~= nodes["mixed-water"]
    end
    assert(pebble_set(research, not_mixed) == pebble_set(full, not_mixed))
end)

test("what's isolatable on the station only through something built there once doesn't give research, which only the core's home context does there", function()
    local graph, nodes = toy_graph({ built_back = true })
    local home_sets = top.home_sets(graph)
    local research = home_sort(graph, true, nil, home_sets)
    local full = home_sort(graph, false, nil, home_sets)
    local far = home_sets.of[FROST]
    assert(has_isolatable(research, nodes["trig-ice"], STATION), "the toy's ice should be isolatable on the station")
    assert(not set_has(home_ids_of(full, nodes["t-ice"]), far), home_ids_of(full, nodes["t-ice"]))
    assert(not set_has(home_ids_of(research, nodes["t-ice"]), far), home_ids_of(research, nodes["t-ice"]))
    -- So research home contexts are exact here again
    assert(pebble_set(research, is_not_home) == pebble_set(full, is_not_home))
    for node_key, node in pairs(graph.nodes) do
        if node.type == "technology" then
            assert(home_ids_of(research, node_key) == home_ids_of(full, node_key), node_key .. ": research " .. home_ids_of(research, node_key) .. ", full " .. home_ids_of(full, node_key))
        end
    end
end)

test("research home contexts don't depend on the order of the sort", function()
    local graph = toy_graph({ mixed = true })
    local home_sets = top.home_sets(graph)
    local first = pebble_set(home_sort(graph, true, nil, home_sets))
    for _, seed in pairs({ 3, 7, 11, 19, 23, 29 }) do
        assert(pebble_set(home_sort(graph, true, seed, home_sets)) == first, "seed " .. seed .. " gave other pebbles")
    end
end)

test("a cached sort with a new edge gets the same pebbles as a fresh sort", function()
    local graph, nodes = toy_graph()
    local home_sets = top.home_sets(graph)
    -- The rock pack's edge into the far planet's discovery comes last
    local edge_key = gutils.ekey({ start = nodes["rock-pack"], stop = nodes["set-find-frost"] })
    local without = table.deepcopy(graph)
    gutils.remove_edge(without, edge_key)
    local was = top.research_home_contexts
    top.research_home_contexts = true
    local state = top.sort(without, nil, nil, {
        complex_contexts = true,
        home_contexts = true,
        home_sets = home_sets,
    })
    add_edge(without, nodes["rock-pack"], nodes["set-find-frost"])
    local cached = top.sort(without, state, { without.nodes[nodes["rock-pack"]], without.nodes[nodes["set-find-frost"]] }, {
        do_new_edge_processing = true,
    })
    top.research_home_contexts = was
    local fresh = home_sort(graph, true, nil, home_sets)
    assert(pebble_set(cached) == pebble_set(fresh))
end)

test("what reasons about backings finds a research input's home context in its prerequisites' isolatable contexts", function()
    local graph, nodes = toy_graph()
    local was = top.research_home_contexts
    top.research_home_contexts = true
    local sort_info = home_sort(graph, true)
    local far = sort_info.home_sets.of[FROST]
    local far_context
    for _, context in pairs(sort_info.contexts) do
        if top.context_home(context) == far then
            far_context = context
        end
    end
    -- The rock pack's own isolatable contexts on the rock planet give the far planet's discovery's pack set its home context
    local edge = graph.edges[gutils.ekey({ start = nodes["rock-pack"], stop = nodes["set-find-frost"] })]
    local sources = {}
    for _, source in pairs(top.edge_source_contexts(sort_info, edge, far_context)) do
        sources[source] = true
    end
    assert(sources[far_context] ~= nil)
    assert(sources[C(ROCK .. " | 10")] ~= nil and sources[C(ROCK .. " | 11")] ~= nil)
    assert(sources[C(MOSS .. " | 10")] ~= nil, "every room of the home set counts")
    assert(sources[C(FROST .. " | 10")] == nil, "the far planet isn't in its own home set")
    -- So callers can't take an edge without abilities to only pass its own context there, but can elsewhere
    assert(not top.edge_keeps_context(sort_info, edge, far_context))
    assert(top.edge_keeps_context(sort_info, edge, C(ROCK .. " | 10")))
    local tech_edge = graph.edges[gutils.ekey({ start = nodes["set-find-frost"], stop = nodes["find-frost"] })]
    assert(top.edge_keeps_context(sort_info, tech_edge, far_context))
    -- Stand-ins for edges with no stop (like promotion's chosen bases, which carry their connection's abilities) never end at research
    local stand_in = {
        abilities = {
            [2] = true,
        },
    }
    assert(top.edge_keeps_context(sort_info, stand_in, far_context))
    local stand_in_sources = top.edge_source_contexts(sort_info, stand_in, far_context)
    assert(#stand_in_sources == 1 and stand_in_sources[1] == far_context)
    -- The path to the discovery's home pebble goes back through the rock pack's isolatable pebble
    local goal = sort_info.node_to_context_inds[nodes["find-frost"]][far_context]
    assert(goal ~= nil)
    local path = top.path(graph, { goal }, sort_info)
    local through_rock_pack = false
    for _, ind in pairs(path.path) do
        if sort_info.pebble_keys[ind] == nodes["rock-pack"] and top.isolatable_in({ [sort_info.pebble_contexts[ind]] = true }, ROCK) then
            through_rock_pack = true
        end
    end
    assert(through_rock_pack, "the path doesn't use the rock pack's isolatable pebble")
    -- And the path to the water's isolatable pebble on the far planet goes through the discovery rule
    local water_goal
    for context, ind in pairs(sort_info.node_to_context_inds[nodes["water"]]) do
        if top.isolatable_in({ [context] = true }, FROST) then
            water_goal = ind
        end
    end
    assert(water_goal ~= nil)
    top.path(graph, { water_goal }, sort_info)
    top.research_home_contexts = was
end)

test("full home contexts are still there when research home contexts are off", function()
    local graph, nodes = toy_graph()
    local sort_info = home_sort(graph, false)
    local far = sort_info.home_sets.of[FROST]
    -- Full home contexts are on every node, like the ore made at home
    assert(set_has(home_ids_of(sort_info, nodes["ore"]), far))
    local research = home_sort(graph, true)
    assert(not set_has(home_ids_of(research, nodes["ore"]), far))
end)

test("research home contexts never count more than full ones, on random solar systems with per-planet discovery", function()
    local num_non_nested = 0
    for seed = 1, 60 do
        local graph = random_system(seed)
        local home_sets = top.home_sets(graph)
        if non_nested(home_sets) then
            num_non_nested = num_non_nested + 1
        end
        local research = random_sort(graph, home_sets, true, true, seed)
        local exact = random_sort(graph, home_sets, false, false, seed + 1000)
        for node_key, inds in pairs(research.node_to_context_inds) do
            local exact_inds = exact.node_to_context_inds[node_key] or {}
            local exact_homes = {}
            for context, _ in pairs(exact_inds) do
                if top.context_home(context) ~= nil then
                    exact_homes[top.context_home(context)] = true
                end
            end
            for context, _ in pairs(inds) do
                local home_id = top.context_home(context)
                if home_id == nil then
                    assert(exact_inds[context] ~= nil, "seed " .. seed .. ": research home contexts give " .. node_key .. " @ " .. top.context_name(context))
                elseif graph.nodes[node_key].type == "technology" then
                    assert(exact_homes[home_id] ~= nil, "seed " .. seed .. ": research home contexts count " .. node_key .. " in " .. top.home_name(home_id))
                end
            end
        end
    end
    assert(num_non_nested > 0, "no random system had home sets that don't nest")
end)

test("a smaller home set's context standing for those containing it gives full home contexts exactly, with discovery and home sets that don't nest", function()
    for seed = 1, 60 do
        local graph = random_system(seed)
        local home_sets = top.home_sets(graph)
        local implied = random_sort(graph, home_sets, false, true, seed)
        local separate = random_sort(graph, home_sets, false, false, seed + 1000)
        assert(pebble_set(implied) == pebble_set(separate), "seed " .. seed .. ": the pebbles differ")
    end
end)

print(num_passed .. " tests passed")

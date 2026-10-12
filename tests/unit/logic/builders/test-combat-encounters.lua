-- Plain-Lua tests for the combat check: what attack groups, territories and routes have, and the nodes the builder makes of it.
-- Run from the mod root: lua tests/unit/logic/builders/test-combat-encounters.lua

local logged = {}
function log(message)
    table.insert(logged, message)
end
serpent = { block = tostring }

-- A small game: a turret and a gun in hand firing one magazine, a spawner sending a small unit early and a big one late, a territory unit, and a route whose big asteroid splits into small ones
local function instant(amount)
    return {
        action = {
            type = "direct",
            action_delivery = {
                type = "instant",
                target_effects = {
                    type = "damage",
                    damage = {
                        type = "test-damage",
                        amount = amount,
                    },
                },
            },
        },
    }
end

local items = {
    ["test-gun"] = {
        type = "gun",
        name = "test-gun",
        attack_parameters = {
            type = "projectile",
            cooldown = 60,
            range = 20,
            ammo_category = "test-ammo",
        },
    },
    ["test-magazine"] = {
        type = "ammo",
        name = "test-magazine",
        ammo_category = "test-ammo",
        ammo_type = instant(10),
    },
}
local entities = {
    ["test-turret"] = {
        type = "ammo-turret",
        name = "test-turret",
        attack_parameters = {
            type = "projectile",
            cooldown = 6,
            range = 20,
            ammo_category = "test-ammo",
        },
    },
    ["test-unbuildable-turret"] = {
        type = "ammo-turret",
        name = "test-unbuildable-turret",
        attack_parameters = {
            type = "projectile",
            cooldown = 1,
            range = 20,
            ammo_category = "test-ammo",
        },
    },
    ["test-spawner"] = {
        type = "unit-spawner",
        name = "test-spawner",
        max_health = 100,
        test_room = "test-planet",
        result_units = {
            {
                "test-small",
                {
                    { 0, 1 },
                    { 0.5, 0 },
                },
            },
            {
                "test-big",
                {
                    { 0.5, 0 },
                    { 1, 1 },
                },
            },
        },
    },
    ["test-small"] = {
        type = "unit",
        name = "test-small",
        max_health = 10,
    },
    ["test-big"] = {
        type = "unit",
        name = "test-big",
        max_health = 5000,
    },
    ["test-worm"] = {
        type = "unit",
        name = "test-worm",
        max_health = 50,
    },
    ["test-asteroid-big"] = {
        type = "asteroid",
        name = "test-asteroid-big",
        max_health = 100,
        dying_trigger_effect = {
            type = "create-entity",
            entity_name = "test-asteroid-small",
        },
    },
    ["test-asteroid-small"] = {
        type = "asteroid",
        name = "test-asteroid-small",
        max_health = 10,
    },
    ["test-asteroid-endpoint"] = {
        type = "asteroid",
        name = "test-asteroid-endpoint",
        max_health = 10,
    },
    -- A segmented unit whose segment shares its health and leaves something behind when it dies
    ["test-crawler"] = {
        type = "segmented-unit",
        name = "test-crawler",
        max_health = 100,
        segment_engine = {
            segments = {
                { segment = "test-crawler-segment" },
            },
        },
    },
    ["test-crawler-segment"] = {
        type = "segment",
        name = "test-crawler-segment",
        max_health = 100000,
    },
    -- Ten turrets do 1000 a second against 1200 of regeneration
    ["test-regenerator"] = {
        type = "unit",
        name = "test-regenerator",
        max_health = 1000,
        healing_per_tick = 20,
    },
}
local planet = {
    type = "planet",
    name = "test-planet",
    map_gen_settings = {
        territory_settings = {
            units = { "test-worm" },
        },
    },
}
local moon = {
    type = "space-location",
    name = "test-moon",
    asteroid_spawn_influence = 0.1,
    asteroid_spawn_definitions = {
        {
            asteroid = "test-asteroid-endpoint",
            probability = 0.01,
        },
        {
            type = "asteroid-chunk",
            asteroid = "test-chunk",
            probability = 0.01,
        },
    },
}
local route = {
    type = "space-connection",
    name = "test-route",
    from = "test-planet",
    to = "test-moon",
    asteroid_spawn_definitions = {
        {
            asteroid = "test-asteroid-big",
            spawn_points = {
                {
                    distance = 0.5,
                    probability = 0.1,
                },
            },
        },
        {
            asteroid = "test-asteroid-small",
            spawn_points = {
                {
                    distance = 0.5,
                    probability = 0,
                },
            },
        },
    },
}
local by_class = {
    ["planet"] = { ["test-planet"] = planet },
    ["space-location"] = { ["test-moon"] = moon },
    ["space-connection"] = { ["test-route"] = route },
}
package.loaded["src/prototypes/data-utils"] = {
    get_prot = function(_, name) return entities[name] end,
    prots = function(class) return by_class[class] or {} end,
    get_all_prots = function()
        return {
            ["test-planet"] = planet,
            ["test-moon"] = moon,
        }
    end,
}
package.loaded["src/logic/logic-utils"] = {
    check_in_room = function(room, prototype) return prototype.test_room == room.name end,
}
local logic = {
    contexts = {},
    type_info = {},
    edge_info = {},
}
package.loaded["src/logic/state"] = logic

local model = require("src/prototypes/combat/combat-encounters")
local combat = require("src/logic/builders/combat-encounters")
local builder = require("src/logic/builders/builder")
local setup = require("src/logic/builders/graph-setup")
local gutils = require("src/lib/graph/graph-utils")
local ctx = require("src/logic/contexts/contexts")

local key = gutils.key
local passed = 0
local function test(name, run)
    run()
    passed = passed + 1
    print("ok - " .. name)
end

local lu = {
    entities = entities,
    items = items,
    rooms = {
        ["planet-test"] = {
            type = "planet",
            name = "test-planet",
        },
    },
}

-- The nodes the rest of logic.build would have made by the time the combat check runs
local function base_graph()
    local graph = {}
    local type_info = {}
    builder.init(graph, type_info, {})
    builder.set_class("test")
    builder.set_prot(nil)
    for _, node in pairs({
        { "room", "planet-test" },
        { "planet", "" },
        { "item-gun", "test-gun" },
        { "entity-operate", "test-turret" },
        { "item", "test-magazine" },
        { "entity", "test-small" },
        { "entity-spawn", "test-spawner__test-small" },
        { "space-connection-asteroids", "test-route" },
    }) do
        builder.add_node(node[1], node[1] == "space-connection-asteroids" and "AND" or "OR", nil, node[2])
    end
    for _, name in pairs({ "test-big", "test-crawler-segment", "test-regenerator" }) do
        builder.add_node("entity", "OR", nil, name)
        builder.add_node("entity-kill", "AND", nil, name)
        builder.add_edge("combat-target", name)
        builder.add_edge("entity", name)
    end
    gutils.add_edge(graph, key("entity-spawn", "test-spawner__test-small"), key("entity", "test-small"), { acq_kind = "spawn" })
    return graph, type_info
end

local function build(params)
    config = {
        military_difficulty = "normal",
        military_time_multiplier = 1,
    }
    local graph, type_info = base_graph()
    local definitions = combat.build(graph, lu, params)
    setup.build({
        graph = graph,
        type_info = type_info,
    })
    return graph, definitions
end

local function edge(graph, start, stop)
    for _, object in pairs(graph.edges) do
        if object.start == start and object.stop == stop then
            return object
        end
    end
end

local turret_weapon = key("combat-weapon", gutils.concat({ key("entity-operate", "test-turret"), "test-magazine" }))
local hand_weapon = key("combat-weapon", gutils.concat({ key("item-gun", "test-gun"), "test-magazine" }))

test("the policy scales the 20 second default and No Cap skips enemies", function()
    local policy = model.policy()
    assert(policy.clear_seconds == 20 and policy.turret_count == 10 and policy.manual_count == 1 and policy.check_enemies)
    assert(model.policy({ time_multiplier = 3 }).clear_seconds == 60)
    assert(model.policy({ difficulty = "no-cap" }).check_enemies == false)
    assert(not pcall(model.policy, { time_multiplier = 0 }))
end)

test("a spawner's mix has every unit with a positive weight at that evolution", function()
    assert(table.concat(model.spawn_mix(entities["test-spawner"], 0), ",") == "test-small")
    assert(table.concat(model.spawn_mix(entities["test-spawner"], 0.5), ",") == "")
    assert(table.concat(model.spawn_mix(entities["test-spawner"], 1), ",") == "test-big")
end)

test("a route has its own asteroids with a positive probability and its endpoints' entity asteroids", function()
    local asteroids = model.route_asteroids(route, {
        ["test-planet"] = planet,
        ["test-moon"] = moon,
    })
    assert(asteroids["test-asteroid-big"] and asteroids["test-asteroid-endpoint"])
    assert(asteroids["test-asteroid-small"] == nil and asteroids["test-chunk"] == nil)
    moon.asteroid_spawn_influence = 0
    assert(model.route_asteroids(route, { ["test-moon"] = moon })["test-asteroid-endpoint"] == nil)
    moon.asteroid_spawn_influence = 0.1
end)

test("every target gets a node with the weapons that kill it on its own in time", function()
    local graph = build()
    for _, name in pairs({ "test-big", "test-small", "test-worm", "test-asteroid-big", "test-asteroid-small", "test-asteroid-endpoint" }) do
        assert(graph.nodes[key("combat-target", name)] ~= nil, name)
    end
    -- Ten turrets kill the big unit in 5 s, the gun in hand would take 500 s
    assert(edge(graph, turret_weapon, key("combat-target", "test-big")) ~= nil)
    assert(edge(graph, hand_weapon, key("combat-target", "test-big")) == nil)
    local manual = edge(graph, hand_weapon, key("combat-target", "test-small"))
    assert(manual ~= nil and manual.abilities == ctx.LOSES_AUTOMATABILITY)
    assert(edge(graph, turret_weapon, key("combat-target", "test-small")).abilities == nil)
    assert(edge(graph, key("combat-target", "test-big"), key("entity-kill", "test-big")) ~= nil)
end)

test("a weapon needs its turret or gun and its ammo, and one whose turret the logic lacks isn't used", function()
    local graph = build()
    assert(edge(graph, key("entity-operate", "test-turret"), turret_weapon) ~= nil)
    assert(edge(graph, key("item", "test-magazine"), turret_weapon) ~= nil)
    assert(edge(graph, key("item-gun", "test-gun"), hand_weapon) ~= nil)
    for node_key, _ in pairs(graph.nodes) do
        assert(not string.find(node_key, "test-unbuildable-turret", 1, true), node_key)
    end
end)

test("a route needs every asteroid on it and what those split into", function()
    local graph = build()
    for _, name in pairs({ "test-asteroid-big", "test-asteroid-small", "test-asteroid-endpoint" }) do
        assert(edge(graph, key("combat-target", name), key("space-connection-asteroids", "test-route")) ~= nil, name)
    end
end)

test("attack groups and territories are mechanics needing their planet and their units' targets", function()
    local graph, definitions = build()
    -- Six evolution steps of the spawner (the small unit until 0.4, the big one from 0.6) and one territory
    assert(#definitions == 7)
    local early = key("combat-encounter", gutils.concat({ "planet-test", "spawn", "test-spawner", 0 }))
    local late = key("combat-encounter", gutils.concat({ "planet-test", "spawn", "test-spawner", 5 }))
    local territory = key("combat-encounter", gutils.concat({ "planet-test", "territory", "test-worm" }))
    for _, node_key in pairs({ early, late, territory }) do
        assert(graph.nodes[node_key] ~= nil and graph.nodes[node_key].mechanic == true, node_key)
        assert(edge(graph, key("room", "planet-test"), node_key) ~= nil)
    end
    assert(edge(graph, key("combat-target", "test-small"), early) ~= nil)
    assert(edge(graph, key("combat-target", "test-big"), early) == nil)
    assert(edge(graph, key("combat-target", "test-big"), late) ~= nil)
    assert(edge(graph, key("combat-target", "test-worm"), territory) ~= nil)
end)

test("the final check drops the time limit and logs the kills over it", function()
    logged = {}
    local graph = build({ time_limit = false })
    assert(edge(graph, hand_weapon, key("combat-target", "test-big")) ~= nil)
    local found = false
    for _, message in pairs(logged) do
        found = found or (string.find(message, "test-big", 1, true) ~= nil and string.find(message, "over the 20 s limit", 1, true) ~= nil)
    end
    assert(not found, "ten turrets kill test-big within the limit")
    entities["test-turret"].attack_parameters.cooldown = 60
    logged = {}
    graph = build({ time_limit = false })
    entities["test-turret"].attack_parameters.cooldown = 6
    found = false
    for _, message in pairs(logged) do
        found = found or (string.find(message, "test-big", 1, true) ~= nil and string.find(message, "over the 20 s limit", 1, true) ~= nil)
    end
    assert(found)
    assert(edge(graph, turret_weapon, key("combat-target", "test-big")) ~= nil)
end)

test("a longer clear time lets slower weapons count", function()
    local graph = build({ time_multiplier = 30 })
    assert(edge(graph, hand_weapon, key("combat-target", "test-big")) ~= nil)
end)

test("No Cap leaves out attack groups and territories but keeps every unit's target", function()
    local graph, definitions = build({ difficulty = "no-cap" })
    assert(#definitions == 0)
    for _, node in pairs(graph.nodes) do
        assert(node.type ~= "combat-encounter")
    end
    assert(graph.nodes[key("combat-target", "test-big")] ~= nil and graph.nodes[key("combat-target", "test-small")] ~= nil)
end)

test("a segment is killed with a unit it's part of, not scored on its own", function()
    local graph = build()
    local segment = key("combat-target", "test-crawler-segment")
    assert(graph.nodes[segment] ~= nil and graph.nodes[key("combat-target", "test-crawler")] ~= nil)
    assert(edge(graph, key("combat-target", "test-crawler"), segment) ~= nil)
    for edge_key, _ in pairs(graph.nodes[segment].pre) do
        assert(graph.edges[edge_key].start == key("combat-target", "test-crawler"))
    end
end)

test("the final check counts more turrets of a weapon that does damage, but not more weapons in hand", function()
    local graph = build()
    assert(next(graph.nodes[key("combat-target", "test-regenerator")].pre) == nil)
    logged = {}
    graph = build({ time_limit = false })
    assert(edge(graph, turret_weapon, key("combat-target", "test-regenerator")) ~= nil)
    assert(edge(graph, hand_weapon, key("combat-target", "test-regenerator")) == nil)
    local found = false
    for _, message in pairs(logged) do
        found = found or (string.find(message, "test-regenerator", 1, true) ~= nil and string.find(message, "more of them would", 1, true) ~= nil)
    end
    assert(found)
end)

print("combat encounters: " .. passed .. " tests passed")

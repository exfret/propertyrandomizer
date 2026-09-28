-- lua lib/old-logic/test-dying-spawns.lua
-- Exercise generated dependencies with the real legacy topological sort.
local build = {
    key = function(t, n) return t .. ":" .. n end,
    compound_key = function(parts) return table.concat(parts, "_") end,
    ops = {
        ["source"] = "AND",
        ["unavailable"] = "OR",
        ["space-location"] = "OR",
        ["space-connection"] = "OR",
        ["space-connection-reverse"] = "OR",
        ["deal-damage-surface"] = "OR",
        ["spaceship-military-surface"] = "OR",
        ["spawn-entity-surface"] = "OR",
        ["spawn-asteroid-chunk"] = "OR",
        ["spawn-asteroid-chunk-surface"] = "OR",
        ["kill-entity-surface"] = "AND",
    },
}
build.conn_key = function(conn)
    return build.key(conn[1].type, conn[1].name) .. "_" .. build.key(conn[2].type, conn[2].name)
end
package.loaded["lib/old-logic/build-graph"] = build
package.loaded["lib/random/rng"] = { key = function() return "test" end }
local sort = require("lib/old-logic/top-sort")
local spawns = require("lib/old-logic/dying-spawns")
local surfaces = {
    orbit = { type = "space-surface" },
    ground = { type = "planet" },
}
local function effect(kind, name)
    return { type = kind, entity_name = name, asteroid_name = name }
end
local function fixture(entities, locations, connections, travel, weapons, reverse)
    local graph = {}
    local function node(t, n, pre)
        graph[build.key(t, n)] = {type = t, name = n, prereqs = pre or {}}
    end
    node("unavailable", "never")
    local function source(name, ready)
        node("source", name, ready and {} or {{type = "unavailable", name = "never"}})
        return {{type = "source", name = name}}
    end
    for _, location in pairs(locations) do
        node("space-location", location.name, source(location.name, travel))
    end
    for _, connection in pairs(connections) do
        node("space-connection", connection.name, source("forward", travel))
        node("space-connection-reverse", connection.name, source("reverse", reverse))
    end
    node("spaceship-military-surface", "orbit", source("space weapon", weapons))
    node("deal-damage-surface", "ground", source("ground weapon", true))
    for _, entity in pairs(entities) do
        node("spawn-entity-surface", entity.name .. "_orbit")
        node("spawn-entity-surface", entity.name .. "_ground", entity.on_ground and source(entity.name, true) or {})
    end
    spawns.add(graph, build, entities, {{name = "fragment"}}, surfaces, locations, connections)
    for _, n in pairs(graph) do n.dependents = {} end
    for _, n in pairs(graph) do
        for _, pre in pairs(n.prereqs) do
            local parent = assert(graph[build.key(pre.type, pre.name)], "dangling prerequisite")
            table.insert(parent.dependents, {type = n.type, name = n.name})
        end
    end
    return sort.sort(graph).reachable
end
local chain = {
    {name = "large", dying_trigger_effect = effect("create-entity", "small")},
    {name = "small", dying_trigger_effect = {effect("create-asteroid-chunk", "fragment")}},
}
local orbit = {{name = "destination", asteroid_spawn_definitions = {{asteroid = "large", probability = 1}}}}
local count = 0
local function test(name, fn)
    fn()
    count = count + 1
    print("ok - " .. name)
end

test("death chains require both access to the parent and a weapon", function()
    assert(fixture(chain, orbit, {}, true, true)["spawn-asteroid-chunk:fragment"])
    assert(not fixture(chain, orbit, {}, false, true)["spawn-asteroid-chunk:fragment"])
    assert(not fixture(chain, orbit, {}, true, false)["spawn-asteroid-chunk:fragment"])
end)

test("positive route spawn points work in either travel direction, including tuple definitions", function()
    local routes = {{name = "route", asteroid_spawn_definitions = {{"large", {{probability = 0}, {probability = 1}}}}}}
    assert(fixture(chain, {}, routes, false, true, true)["spawn-asteroid-chunk:fragment"])
    assert(not fixture(chain, {}, routes, false, true, false)["spawn-asteroid-chunk:fragment"])
end)

test("zero probability locations and routes supply nothing", function()
    local locations = {{name = "destination", asteroid_spawn_definitions = {{asteroid = "large", probability = 0}}}}
    local routes = {{name = "route", asteroid_spawn_definitions = {{asteroid = "large", spawn_points = {{probability = 0}}}}}}
    assert(not fixture(chain, locations, routes, true, true, true)["spawn-asteroid-chunk:fragment"])
end)

test("direct chunks do not require a kill", function()
    local locations = {{name = "destination", asteroid_spawn_definitions = {{type = "asteroid-chunk", asteroid = "fragment", probability = 1}}}}
    assert(fixture({}, locations, {}, true, false)["spawn-asteroid-chunk:fragment"])
end)

test("nested death actions and effect arrays are followed", function()
    local parents = {{name = "large", dying_trigger_effect = {
        type = "nested-result", action = {{type = "direct", action_delivery = {
            type = "instant", target_effects = {effect("create-asteroid-chunk", "fragment")},
        }}},
    }}}
    assert(fixture(parents, orbit, {}, true, true)["spawn-asteroid-chunk:fragment"])
end)

test("other prototype actions and zero-repeat effects do not become death spawns", function()
    local disabled = effect("create-asteroid-chunk", "fragment")
    disabled.repeat_count = 0
    local parents = {{name = "large", dying_trigger_effect = disabled, action = effect("create-asteroid-chunk", "fragment")}}
    assert(not fixture(parents, orbit, {}, true, true)["spawn-asteroid-chunk:fragment"])
end)

test("a ground death cannot supply chunks on a space surface", function()
    local parents = {{name = "large", on_ground = true, dying_trigger_effect = effect("create-asteroid-chunk", "fragment")}}
    assert(not fixture(parents, {}, {}, true, true)["spawn-asteroid-chunk:fragment"])
end)

test("ground death spawns stay on the ground", function()
    local parents = {
        {name = "large", on_ground = true, dying_trigger_effect = effect("create-entity", "small")},
        {name = "small"},
    }
    local reachable = fixture(parents, {}, {}, true, true)
    assert(reachable["spawn-entity-surface:small_ground"])
    assert(not reachable["spawn-entity-surface:small_orbit"])
end)

test("zero probability death effects are ignored", function()
    local disabled = effect("create-asteroid-chunk", "fragment")
    disabled.probability = 0
    local parents = {{name = "large", dying_trigger_effect = disabled}}
    assert(not fixture(parents, orbit, {}, true, true)["spawn-asteroid-chunk:fragment"])
end)

test("death cycles without an original source stay unreachable", function()
    local parents = {
        {name = "large", dying_trigger_effect = effect("create-entity", "small")},
        {name = "small", dying_trigger_effect = {effect("create-entity", "large"), effect("create-asteroid-chunk", "fragment")}},
    }
    assert(not fixture(parents, {}, {}, true, true)["spawn-asteroid-chunk:fragment"])
end)
print(count .. " tests passed")

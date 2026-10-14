-- Plain-Lua placement graph regressions; engine semantics are checked by the test helper mod.
package.loaded["__core__/lualib/collision-mask-util"] = {
    get_mask = function(entity)
        return entity.collision_mask or {layers = {blocked = true}}
    end,
    masks_collide = function(a, b)
        for layer, enabled in pairs(a.layers) do
            if enabled == true and b.layers[layer] == true then
                return true
            end
        end
        return false
    end,
}
package.loaded["src/lib/random/rng"] = {}
local state = {contexts = {home = true, away = true, platform = true}, type_info = {}}
package.loaded["src/logic/state"] = state
local gutils = require("src/lib/graph/graph-utils")
local builder = require("src/logic/builders/builder")
local requirements = require("src/logic/builders/tile-requirements")
local graph_setup = require("src/logic/builders/graph-setup")
local top = require("src/lib/sort/context-sort")
local fx = require("tests/unit/logic/contexts/contexts-for-tests")
local groups = {
    ground = {ground = true},
    water = {water = true},
    ice = {ground = true, ice = true},
    platform = {ground = true, platform = true},
    blocked = {blocked = true},
}
local area = {{-0.4, -0.4}, {0.4, 0.4}}
local function entity(rules)
    return {name = "fixture", type = "container", collision_box = area, collision_mask = {layers = {}}, tile_buildability_rules = rules}
end
local function possible(prototype, available, tile_groups)
    for _, layout in pairs(requirements.compile(prototype, tile_groups or groups)) do
        local accepted = true
        for _, clause in pairs(layout) do
            local found = false
            for _, group in pairs(clause.groups) do
                if available[group] == true then
                    found = true
                end
            end
            accepted = accepted and found
        end
        if accepted then
            return true
        end
    end
    return false
end
local count = 0
local function test(name, run)
    run()
    count = count + 1
    print("ok - " .. name)
end

test("required masks accept any matching layer, but reject incompatible terrain", function()
    local fixture = entity({{area = area, required_tiles = {layers = {water = true, ice = true}}}})
    assert(possible(fixture, {water = true}))
    assert(possible(fixture, {ice = true}))
    assert(not possible(fixture, {ground = true}))
end)

test("missing and empty required masks differ", function()
    assert(possible(entity({{area = area, colliding_tiles = {layers = {water = true}}}}), {ground = true}))
    assert(not possible(entity({{area = area, required_tiles = {layers = {}}}}), {ground = true}))
end)

test("forbidden masks and original collisions intersect required tiles", function()
    local fixture = entity({{area = area, required_tiles = {layers = {ground = true}}, colliding_tiles = {layers = {ice = true}}}})
    assert(possible(fixture, {ground = true}))
    assert(not possible(fixture, {ice = true}))
    fixture.collision_mask = {layers = {ground = true}}
    assert(not possible(fixture, {ground = true}))
    fixture.collision_mask = nil
    fixture.tile_buildability_rules = {{area = area, required_tiles = {layers = {blocked = true}}}}
    assert(not possible(fixture, {blocked = true}))
end)

test("overlapping rules must be satisfied by the same tile", function()
    local fixture = entity({
        {area = area, required_tiles = {layers = {water = true}}},
        {area = area, required_tiles = {layers = {ground = true}}},
    })
    assert(not possible(fixture, {ground = true, water = true}))
end)

test("separate areas allow shoreline and platform-edge layouts", function()
    local fixture = entity({
        {area = area, required_tiles = {layers = {ground = true}}},
        {area = {{-0.4, -1.4}, {0.4, -0.6}}, required_tiles = {layers = {water = true}}},
    })
    fixture.collision_mask = {layers = {water = true}}
    assert(possible(fixture, {ground = true, water = true}))
    assert(not possible(fixture, {ground = true}))
    assert(not possible(fixture, {water = true}))
    assert(possible(fixture, {platform = true, water = true}))
end)

test("disjoint rectangles touching the same tile cannot contradict each other", function()
    local fixture = entity({
        {area = {{-0.4, -0.4}, {-0.1, 0.4}}, required_tiles = {layers = {water = true}}},
        {area = {{0.1, -0.4}, {0.4, 0.4}}, required_tiles = {layers = {ground = true}}},
    })
    assert(not possible(fixture, {ground = true, water = true}))
    fixture.flags = {"placeable-off-grid"}
    assert(possible(fixture, {ground = true, water = true}), "off-grid placement can straddle the tile boundary")
end)

test("named boxes and explicit grid dimensions are supported", function()
    local fixture = entity({
        {area = {{-0.9, -0.4}, {-0.1, 0.4}}, required_tiles = {layers = {water = true}}},
        {area = {{0.1, -0.4}, {0.9, 0.4}}, required_tiles = {layers = {ground = true}}},
    })
    fixture.collision_box = {left_top = {x = -0.4, y = -0.4}, right_bottom = {x = 0.4, y = 0.4}}
    assert(not possible(fixture, {ground = true, water = true}))
    fixture.tile_width = 2
    assert(possible(fixture, {ground = true, water = true}))
end)

test("empty collision-layer groups are not confused with impossible regions", function()
    local fixture = entity({
        {area = area, required_tiles = {layers = {water = true}}},
        {area = {{-0.4, -1.4}, {0.4, -0.6}}, colliding_tiles = {layers = {water = true}}},
    })
    assert(not possible(fixture, {[""] = true}, {[""] = {}}))
end)

test("large rule areas are compressed rather than expanded tile by tile", function()
    local fixture = entity({{area = {{-10000, -10000}, {10000, 10000}}, required_tiles = {layers = {water = true}}}})
    local layouts = requirements.compile(fixture, groups)
    assert(#layouts == 1 and #layouts[1] == 1)
end)

local function graph_fixture(prototype, water_rooms, allow_platform)
    local graph = {}
    state.type_info = {}
    builder.init(graph, state.type_info, {})
    builder.set_class("entity")
    builder.set_prot(prototype)
    builder.add_node("entity-build", "AND")
    builder.add_edge("entity-build-tile-rules")
    builder.add_edge("surface-condition", "fixture")
    builder.add_edge("item", "kit")
    requirements.build(prototype, {tile_collision_group_to_layers = groups})
    builder.set_prot(nil)
    builder.add_node("start", "AND", nil, "")
    builder.add_node("surface-condition", "OR", nil, "fixture")
    for _, room in pairs({"home", "away", "platform"}) do
        builder.add_node("room", "AND", "room", room)
        builder.add_edge("start", "")
        builder.add_edge("room", room, nil, "item", "kit")
        if room ~= "platform" or allow_platform == true then
            builder.add_edge("room", room, nil, "surface-condition", "fixture")
        end
    end
    builder.add_node("item", "OR", nil, "kit")
    for name, _ in pairs(groups) do
        builder.add_node("tile-collision-group", "OR", nil, name)
        if name == "ground" then
            builder.add_edge("room", "home")
        elseif name == "platform" then
            builder.add_edge("room", "platform")
        elseif name == "water" then
            for _, room in pairs(water_rooms) do
                builder.add_edge("room", room)
            end
        end
    end
    state.graph = graph
    graph_setup.build(state)
    return graph
end
local function reached(graph, room)
    return (top.sort(graph).node_to_context_inds[gutils.key("entity-build", "fixture")] or {})[fx.C(room)] ~= nil
end

test("all placement requirements must be reachable on the same surface", function()
    local fixture = entity({
        {area = area, required_tiles = {layers = {ground = true}}},
        {area = {{-0.4, -1.4}, {0.4, -0.6}}, required_tiles = {layers = {water = true}}},
    })
    local graph = graph_fixture(fixture, {"away"}, true)
    assert(not reached(graph, "home"))
    assert(not reached(graph, "away"))
    assert(not reached(graph, "platform"))
    assert(reached(graph_fixture(fixture, {"home"}, true), "home"))
    assert(reached(graph_fixture(fixture, {"platform"}, true), "platform"))
    assert(not reached(graph_fixture(fixture, {"platform"}, false), "platform"), "terrain cannot bypass surface conditions")
end)

test("constructed terrain cannot bootstrap its own required building", function()
    local fixture = entity({{area = area, required_tiles = {layers = {water = true}}}})
    local graph = graph_fixture(fixture, {}, true)
    gutils.add_edge(graph, gutils.key("entity-build", "fixture"), gutils.key("tile-collision-group", "water"))
    graph_setup.build(state)
    assert(not reached(graph, "home"))
end)

print(count .. " placement tests passed")

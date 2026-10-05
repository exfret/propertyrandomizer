#!/usr/bin/env python3
"""Exercise randomized drill outputs in Factorio through dev/run-tests.py.

A temporary test helper places a belt and then a receiving chest at each solid
mining drill's output in all four directions, and checks that mining fills it.
Prototype names, resources, fuels, and terrain are derived from loaded data.
Run: python3 dev/test-mining-drill-offsets.py
"""
import importlib.util
from pathlib import Path
import shutil
import tempfile

REPO = Path(__file__).resolve().parent.parent
spec = importlib.util.spec_from_file_location("run_tests", REPO / "dev/run-tests.py")
runner = importlib.util.module_from_spec(spec)
spec.loader.exec_module(runner)

PROBE = r'''
local function small_receiver(kind)
    for name, prototype in pairs(prototypes.entity) do
        if prototype.type == kind then
            local box = prototype.collision_box
            if box.right_bottom.x - box.left_top.x <= 1 and box.right_bottom.y - box.left_top.y <= 1 then
                return name, prototype
            end
        end
    end
    error("No one-tile receiver for " .. kind)
end

local function ground_for(drill, chest, belt)
    for name, tile in pairs(prototypes.tile) do
        local overlaps = false
        for layer in pairs(tile.collision_mask.layers) do
            if drill.collision_mask.layers[layer] or chest.collision_mask.layers[layer] or belt.collision_mask.layers[layer] then
                overlaps = true
            end
        end
        if not overlaps then
            return name
        end
    end
    error("No compatible ground tile")
end

local function resource_for(drill)
    for name, resource in pairs(prototypes.entity) do
        if resource.type == "resource" and drill.resource_categories[resource.resource_category] then
            local mining = resource.mineable_properties
            if mining.required_fluid == nil then
                for _, product in pairs(mining.products or {}) do
                    if product.type == "item" then
                        return name
                    end
                end
            end
        end
    end
end

local function prepare_outputs()
    local chest_name, chest_prototype = small_receiver("container")
    local belt_name, belt_prototype = small_receiver("transport-belt")
    local surface = game.create_surface("offset-output-test", {
        width = 1024,
        height = 256,
        autoplace_settings = { entity = { treat_missing_as_default = false, settings = {} } },
    })
    storage.offset_probes = {}
    for name, prototype in pairs(prototypes.entity) do
        if prototype.type == "mining-drill" then
            local vector = prototype.vector_to_place_result
            local resource = resource_for(prototype)
            if resource ~= nil and (vector.x ~= 0 or vector.y ~= 0) then
                local tile = ground_for(prototype, chest_prototype, belt_prototype)
                for _, direction in pairs({defines.direction.north, defines.direction.east, defines.direction.south, defines.direction.west}) do
                    local index = #storage.offset_probes
                    local width, height = prototype.tile_width, prototype.tile_height
                    if direction == defines.direction.east or direction == defines.direction.west then
                        width, height = height, width
                    end
                    local position = { x = -400 + index * 40 + width % 2 / 2, y = height % 2 / 2 }
                    local tiles = {}
                    for x = math.floor(position.x) - 15, math.floor(position.x) + 15 do
                        for y = -15, 15 do
                            tiles[#tiles + 1] = {name = tile, position = {x, y}}
                        end
                    end
                    surface.set_tiles(tiles)
                    local resource_entity = surface.create_entity{
                        name = resource,
                        position = {math.floor(position.x) + 0.5, math.floor(position.y) + 0.5},
                        amount = 10000,
                    }
                    assert(resource_entity ~= nil, "Couldn't create mining target")
                    local drill = surface.create_entity{name = name, position = position, direction = direction, force = game.forces.player}
                    assert(drill ~= nil, "Couldn't create drill " .. name)
                    local drop = drill.drop_position
                    local receiver_position = {math.floor(drop.x) + 0.5, math.floor(drop.y) + 0.5}
                    assert(surface.can_place_entity{name = belt_name, position = receiver_position, force = game.forces.player},
                        "Belt collides with " .. name .. " at its output, direction " .. direction)
                    assert(surface.can_place_entity{name = chest_name, position = receiver_position, force = game.forces.player},
                        "Chest collides with " .. name .. " at its output, direction " .. direction)
                    local chest = surface.create_entity{name = chest_name, position = receiver_position, force = game.forces.player}
                    assert(chest ~= nil, "Couldn't create output chest")
                    if drill.burner ~= nil then
                        local fueled = false
                        for item_name, item in pairs(prototypes.item) do
                            for _, category in pairs(item.fuel_categories or {}) do
                                if drill.burner.fuel_categories[category] and item.fuel_value > 0 then
                                    drill.burner.inventory.insert{name = item_name, count = 10}
                                    fueled = true
                                    break
                                end
                            end
                            if fueled then break end
                        end
                        assert(fueled, "Couldn't fuel " .. name)
                    end
                    storage.offset_probes[#storage.offset_probes + 1] = {drill = drill, chest = chest, direction = direction}
                end
            end
        end
    end
    assert(#storage.offset_probes > 0, "No solid mining drills exercised")
    log("OFFSETTEST placed " .. #storage.offset_probes .. " receivers without collisions")
end

script.on_init(function()
    log_settings()
    log_reachability()
    prepare_outputs()
end)

script.on_event(defines.events.on_tick, function(event)
    for _, probe in pairs(storage.offset_probes) do
        probe.drill.energy = 1000000000
    end
    if event.tick == 599 then
        for _, probe in pairs(storage.offset_probes) do
            assert(probe.chest.get_output_inventory().get_item_count() > 0,
                "No mined output from " .. probe.drill.name .. " direction " .. probe.direction .. " status " .. tostring(probe.drill.status))
        end
        log("OFFSETTEST mined into all " .. #storage.offset_probes .. " receivers")
    end
end)
'''


def main():
    original_run_one = runner.run_one

    def checked_run_one(run, ctx):
        result = original_run_one(run, ctx)
        control_log = Path(result["dir"]) / "control.log"
        if result["ok"] and "OFFSETTEST mined into all " not in control_log.read_text():
            result["problems"].append("mining output check did not run")
            result["ok"] = False
        return result

    runner.run_one = checked_run_one
    with tempfile.TemporaryDirectory(prefix="propertyrandomizer-offset-test-") as tmp:
        helper = Path(tmp) / runner.HELPER_NAME
        shutil.copytree(runner.HELPER_MOD, helper)
        with (helper / "control.lua").open("a") as control:
            control.write(PROBE)
        runner.HELPER_MOD = str(helper)
        return runner.main([
            "settings", "--only", "mining-drill-offsets", "--modset", "base",
            "--modset", "sa", "--jobs", "2",
        ])


if __name__ == "__main__":
    raise SystemExit(main())

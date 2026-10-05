#!/usr/bin/env python3
"""Exercise randomized drill outputs in Factorio through dev/run-tests.py.

A temporary test helper places a belt and then a receiving chest at each solid
mining drill's output in all four directions, and checks that mining fills it.
Checks that item offsets actually change, both with and without the extra fluid
ports used by preview preparation. Names, resources, fuels, and terrain are derived.
Run: python3 dev/test-mining-drill-offsets.py
Full preview dispatch check: python3 dev/test-mining-drill-offsets.py --preview
"""
import argparse
import importlib.util
from pathlib import Path
import shutil
import tempfile

REPO = Path(__file__).resolve().parent.parent
spec = importlib.util.spec_from_file_location("run_tests", REPO / "dev/run-tests.py")
runner = importlib.util.module_from_spec(spec)
spec.loader.exec_module(runner)

BASELINE = r'''
local fluid_ports = require("__propertyrandomizer__/lib/fluid-ports")
if OFFSET_TEST_MIXED_PORTS then
    fluid_ports.fit_mining_drills(true)
end
local baseline = {}
for name, drill in pairs(data.raw["mining-drill"]) do
    local vector = drill.vector_to_place_result
    local x, y = vector.x or vector[1], vector.y or vector[2]
    if x ~= 0 or y ~= 0 then
        baseline[name] = {x = x, y = y}
    end
end
data:extend({{
    type = "mod-data",
    name = "propertyrandomizer-offset-test-baseline",
    data = baseline,
}})
'''

CHECK_CHANGES = r'''
local checked = 0
for name, original in pairs(data.raw["mod-data"]["propertyrandomizer-offset-test-baseline"].data) do
    local drill = data.raw["mining-drill"][name]
    assert(drill ~= nil, "Missing drill " .. name)
    local vector = drill.vector_to_place_result
    local x, y = vector.x or vector[1], vector.y or vector[2]
    assert(x ~= original.x or y ~= original.y, "Item offset was not randomized for " .. name)
    checked = checked + 1
end
assert(checked > 0, "No item offsets compared against baseline")
log("OFFSETTEST changed all " .. checked .. " item offsets")
'''

PREVIEW_CHECK = r'''
local randomize_offsets = randomizations.mining_drill_offsets
randomizations.mining_drill_offsets = function(id)
    local before = {}
    for name, drill in pairs(data.raw["mining-drill"]) do
        local vector = drill.vector_to_place_result
        local x, y = vector.x or vector[1], vector.y or vector[2]
        if drill.output_fluid_box ~= nil and (x ~= 0 or y ~= 0) then
            before[name] = {x = x, y = y, fluid_box = drill.output_fluid_box}
        end
    end
    randomize_offsets(id)
    local changed = 0
    for name, original in pairs(before) do
        local drill = data.raw["mining-drill"][name]
        assert(drill.output_fluid_box == original.fluid_box, "Changed fluid output connections for " .. name)
        local vector = drill.vector_to_place_result
        if (vector.x or vector[1]) ~= original.x or (vector.y or vector[2]) ~= original.y then
            changed = changed + 1
        end
    end
    assert(changed > 0, "Preview skipped every mixed-output drill's item offset")
    log("OFFSETTEST preview changed " .. changed .. " mixed-output item offsets")
end
'''

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


def run_preview():
    original_snapshot = runner.snapshot
    original_run_one = runner.run_one

    def snapshot_with_check(dest, ref, staged, source_dir):
        original_snapshot(dest, ref, staged, source_dir)
        with (Path(dest) / "randomizations/misc/offsets.lua").open("a") as offsets:
            offsets.write(PREVIEW_CHECK)

    def checked_run_one(run, ctx):
        result = original_run_one(run, ctx)
        create_log = Path(result["dir"]) / "create.log"
        if "OFFSETTEST preview changed " not in create_log.read_text():
            problem = "preview offset change check did not pass"
            result["problems"].append(problem)
            result["hard_problems"].append(problem)
            result["ok"] = False
        return result

    runner.snapshot = snapshot_with_check
    runner.run_one = checked_run_one
    return runner.main([
        "unified", "--only", "/mining-drill-offsets-preview@", "--modset", "base",
        "--modset", "sa", "--jobs", "2",
    ])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--preview", action="store_true", help="check offset changes during full unified preview")
    args = parser.parse_args()
    if args.preview:
        return run_preview()
    original_run_one = runner.run_one

    def checked_run_one(run, ctx):
        result = original_run_one(run, ctx)
        control_log = Path(result["dir"]) / "control.log"
        create_log = Path(result["dir"]) / "create.log"
        if result["ok"] and "OFFSETTEST changed all " not in create_log.read_text():
            result["problems"].append("offset change check did not run")
            result["ok"] = False
        if result["ok"] and "OFFSETTEST mined into all " not in control_log.read_text():
            result["problems"].append("mining output check did not run")
            result["ok"] = False
        return result

    runner.run_one = checked_run_one
    original_helper = runner.HELPER_MOD
    outcome = 0
    for mixed_ports in (False, True):
        print("Testing item offsets with " + ("preview-style fluid ports" if mixed_ports else "original ports"), flush=True)
        with tempfile.TemporaryDirectory(prefix="propertyrandomizer-offset-test-") as tmp:
            helper = Path(tmp) / runner.HELPER_NAME
            shutil.copytree(original_helper, helper)
            with (helper / "control.lua").open("a") as control:
                control.write(PROBE)
            with (helper / "data-updates.lua").open("a") as data_updates:
                data_updates.write(BASELINE.replace("OFFSET_TEST_MIXED_PORTS", "true" if mixed_ports else "false"))
            with (helper / "data-final-fixes.lua").open("a") as data_final:
                data_final.write(CHECK_CHANGES)
            runner.HELPER_MOD = str(helper)
            outcome |= runner.main([
                "settings", "--only", "mining-drill-offsets", "--modset", "base",
                "--modset", "sa", "--jobs", "2",
            ])
    return outcome


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Validate final shared profiles and sample each eligible resource with Factorio's noise engine.

Uses the normal runner and its process limit. Baselines are the final swapped/repaired
placements immediately before profiles, with the same map seed, terrain and resource expressions.
Run: python3 dev/test-planet-resource-profiles.py [--seed-offset N] [--modset base|sa]
"""
import argparse
import importlib.util
import shutil
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
spec = importlib.util.spec_from_file_location("runner", REPO / "dev/run-tests.py")
runner = importlib.util.module_from_spec(spec)
spec.loader.exec_module(runner)

DATA_CHECK = r'''
local profile_execute = planet_resource_profiles.execute
planet_resource_profiles.execute = function()
    local baseline = table.deepcopy(data.raw.planet)
    local entries = {}
    for name, planet in pairs(baseline) do
        entries[name] = planet_resource_profiles.eligible(planet)
    end
    local results = profile_execute()
    local report = {}
    for name, profile in pairs(results) do
        local before = baseline[name].map_gen_settings
        local after = data.raw.planet[name].map_gen_settings
        local resource_names = {}
        for _, entry in pairs(entries[name]) do
            table.insert(resource_names, entry.resource_name)
            local low, high = planet_resource_profiles.total_range(entry, profile, before)
            assert(low >= 0.75 and high <= 4/3, "Profile estimate out of bounds for " .. name .. "/" .. entry.resource_name)
            for control in pairs(entry.controls) do
                for _, dimension in pairs({"size", "frequency", "richness"}) do
                    local property = "control:" .. control .. ":" .. dimension
                    local old = before.property_expression_names and before.property_expression_names[property]
                    local current = after.property_expression_names and after.property_expression_names[property]
                    if old == nil then
                        old = (before.autoplace_controls[control] or {})[dimension] or 1
                        current = after.autoplace_controls[control][dimension]
                    end
                    assert(math.abs(current / old - profile[dimension]) < 1e-10, "Resources do not share " .. dimension)
                end
            end
        end
        local description = data.raw.planet[name].localised_description[4]
        assert(description[5] == string.format("%.2f", profile.size))
        assert(description[6] == string.format("%.2f", profile.frequency))
        assert(description[7] == string.format("%.2f", profile.richness))
        report[name] = {baseline = before, resources = resource_names}
    end
    assert(next(report) ~= nil, "No eligible planet profiles tested")
    data:extend({{type = "mod-data", name = "propertyrandomizer-test-resource-profiles", data = report}})
    log("RESOURCEPROFILETEST data checks passed")
    return results
end
'''

CONTROL_CHECK = r'''
local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, child in pairs(value) do result[key] = copy(child) end
    return result
end
local function check_profiles()
    local report = prototypes.mod_data["propertyrandomizer-test-resource-profiles"]
    assert(report ~= nil)
    local total_checked = 0
    -- Dense near-start points and a broad regular-patch grid; identical points on both maps.
    local positions = {}
    for x = -256, 256, 4 do
        for y = -256, 256, 4 do positions[#positions + 1] = {x + 0.5, y + 0.5} end
    end
    for x = -4096, 4096, 16 do
        for y = -4096, 4096, 16 do
            if math.abs(x) > 256 or math.abs(y) > 256 then
                positions[#positions + 1] = {x + 0.5, y + 0.5}
            end
        end
    end
    for name, entry in pairs(report.data) do
        local surface = game.planets[name].create_surface()
        local seed_map = copy(surface.map_gen_settings)
        seed_map.seed = settings.startup["propertyrandomizer-seed"].value
        surface.map_gen_settings = seed_map
        local map = copy(surface.map_gen_settings)
        local original = entry.baseline
        map.autoplace_controls = copy(original.autoplace_controls or {})
        map.property_expression_names = copy(original.property_expression_names or {})
        map.autoplace_settings = copy(original.autoplace_settings or {})
        local baseline = game.create_surface("propertyrandomizer-resource-baseline-" .. name, map)
        local properties = {}
        for _, resource in pairs(entry.resources) do
            properties[#properties + 1] = "entity:" .. resource .. ":probability"
            properties[#properties + 1] = "entity:" .. resource .. ":richness"
        end
        local before = baseline.calculate_tile_properties(properties, positions)
        local after = surface.calculate_tile_properties(properties, positions)
        for _, resource in pairs(entry.resources) do
            local p = "entity:" .. resource .. ":probability"
            local r = "entity:" .. resource .. ":richness"
            local old, new = 0, 0
            local hits = 0
            for i = 1, #positions do
                local a = math.min(1, math.max(0, before[p][i]))
                local b = math.min(1, math.max(0, after[p][i]))
                if a > 0 then hits = hits + 1 end
                -- Account for the finer starting grid's area weight.
                local weight = i <= 129 * 129 and 16 or 256
                old = old + a * math.max(0, before[r][i]) * weight
                new = new + b * math.max(0, after[r][i]) * weight
            end
            -- Sparse placements need a finer grid before a ratio is meaningful.
            local step = 8
            while hits < 20 and step >= 4 do
                old, new, hits = 0, 0, 0
                local finer = {}
                local function flush()
                    if #finer == 0 then return end
                    local a_values = baseline.calculate_tile_properties({p, r}, finer)
                    local b_values = surface.calculate_tile_properties({p, r}, finer)
                    for i = 1, #finer do
                        local a = math.min(1, math.max(0, a_values[p][i]))
                        local b = math.min(1, math.max(0, b_values[p][i]))
                        if a > 0 then hits = hits + 1 end
                        old = old + a * math.max(0, a_values[r][i])
                        new = new + b * math.max(0, b_values[r][i])
                    end
                    finer = {}
                end
                for x = -4096, 4096, step do
                    for y = -4096, 4096, step do
                        finer[#finer + 1] = {x + 0.5, y + 0.5}
                        if #finer == 8192 then flush() end
                    end
                end
                flush()
                step = step / 2
            end
            if old > 0 and hits >= 20 then
                local ratio = new / old
                log("RESOURCEPROFILETEST total " .. name .. "/" .. resource .. " ratio=" .. ratio .. " baseline-hits=" .. hits)
                assert(ratio >= 0.65 and ratio <= 1.55, "Generated resource total out of balance: " .. name .. "/" .. resource .. " ratio=" .. ratio)
                total_checked = total_checked + 1
            else
                error("Insufficient balance sample: " .. name .. "/" .. resource .. " baseline-hits=" .. hits)
            end
        end
        game.delete_surface(baseline)
    end
    assert(total_checked > 0)
    log("RESOURCEPROFILETEST sampled " .. total_checked .. " resources")
end
'''


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--seed-offset", type=int, default=0)
    parser.add_argument("--modset", choices=["base", "sa"], default="sa")
    args = parser.parse_args()
    original_snapshot = runner.snapshot
    original_run = runner.run_one
    original_plan = runner.Plan

    def snapshot(dest, ref, staged, source_dir):
        original_snapshot(dest, ref, staged, source_dir)
        final = Path(dest) / "src/pipeline/data-final-fixes.lua"
        text = final.read_text()
        gate = 'if config.planetary_resources == true then\n    planet_resource_profiles.execute()\nend'
        assert text.count(gate) == 1
        final.write_text(text.replace(gate, DATA_CHECK + "\n" + gate))
        # The runner copies its helper separately; patch its source path to a temporary sibling.
        helper = Path(dest).parent / "resource-profile-helper"
        shutil.copytree(REPO / "dev/test-helper-mod", helper)
        control = helper / "control.lua"
        text = control.read_text()
        control.write_text(CONTROL_CHECK + "\n" + text.replace("    log_settings()", "    check_profiles()\n    log_settings()"))
        runner.HELPER_MOD = str(helper)

    class ProfilePlan(original_plan):
        def __init__(self, *params):
            super().__init__(*params)
            # Define the fixture here so this test does not depend on an unrelated hand-picked config.
            self.configs = []
            self.add("settings", "dupes-resources", {
                "dupes": True,
                "planetary-resources": True,
                "logistic": "none",
                "production": "none",
                "military": "none",
                "misc": "none",
            }, seeds=[1])

    def checked_run(run, ctx):
        result = original_run(run, ctx)
        # on_init runs when the save is created; the benchmark reloads that save.
        log = Path(result["dir"]) / "create.log"
        if not log.exists() or "RESOURCEPROFILETEST sampled " not in log.read_text():
            result["ok"] = False
            problem = "resource profile map sampling did not pass"
            result["problems"].append(problem)
            result.setdefault("hard_problems", []).append(problem)
        return result

    runner.snapshot = snapshot
    runner.Plan = ProfilePlan
    runner.run_one = checked_run
    return runner.main(["settings", "--modset", args.modset, "--jobs", "1", "--seed-offset", str(args.seed_offset)])


if __name__ == "__main__":
    raise SystemExit(main())

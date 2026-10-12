#!/usr/bin/env python3
"""Load planet audio randomization with Space Age through the normal test runner.

Adds music selector fixtures derived from loaded tracks to a temporary snapshot.
Checks donor bundles and effective playlists before/after the production call,
then lets Factorio validate the prototypes and run the control-stage benchmark.
This is data/load validation, not a listening test.
Run: python3 dev/test-planet-sounds.py
Isolated audio/copy load, also checking that the normal gate stays off:
python3 dev/test-planet-sounds.py --isolated
"""
import argparse
import importlib.util
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
spec = importlib.util.spec_from_file_location("run_tests", REPO / "dev/run-tests.py")
runner = importlib.util.module_from_spec(spec)
spec.loader.exec_module(runner)

SELECTOR_FIXTURES = r'''
local names = {}
for name, planet in pairs(data.raw.planet) do
    if planet.hidden ~= true then table.insert(names, name) end
end
table.sort(names)
local track_names = {}
for name, track in pairs(data.raw["ambient-sound"]) do
    if track.track_type == "main-track" then table.insert(track_names, name) end
end
table.sort(track_names)
local source = data.raw["ambient-sound"][track_names[1]]
assert(source ~= nil and #names > 1)
local surface = table.deepcopy(source)
surface.name = "propertyrandomizer-test-surface-music"
surface.planets = nil
surface.surface_names = {names[1]}
surface.play_on_all_surfaces = nil
surface.exclude_planets = nil
surface.exclude_surface_names = {"propertyrandomizer-test-laboratory"}
local mixed = table.deepcopy(surface)
mixed.name = "propertyrandomizer-test-mixed-music"
mixed.planets = {names[2]}
local broad = table.deepcopy(surface)
broad.name = "propertyrandomizer-test-broad-music"
broad.surface_names = nil
broad.play_on_all_surfaces = true
broad.exclude_planets = {names[2]}
data:extend({surface, mixed, broad})
'''

CHECK = r'''
local audio_execute = planet_sounds.execute
planet_sounds.execute = function()
    local before_planets = table.deepcopy(data.raw.planet)
    local before_tracks = table.deepcopy(data.raw["ambient-sound"])
    local function equal(a, b)
        if type(a) ~= "table" or type(b) ~= "table" then return a == b end
        for k, v in pairs(a) do if not equal(v, b[k]) then return false end end
        for k in pairs(b) do if a[k] == nil then return false end end
        return true
    end
    local function has(list, name, substring)
        for _, value in pairs(list or {}) do
            if value == name or (substring and string.find(name, value, 1, true)) then return true end
        end
        return false
    end
    local function playlist(tracks, name)
        local result = {}
        for _, track in pairs(tracks) do
            if (track.track_type == "main-track" or track.track_type == "hero-track" or track.track_type == "interlude")
                and (track.play_on_all_surfaces or has(track.planets, name) or has(track.surface_names, name, true))
                and not has(track.exclude_planets, name) and not has(track.exclude_surface_names, name, true) then
                local copy = table.deepcopy(track)
                copy.name = nil
                copy.planets = nil
                copy.surface_names = nil
                copy.play_on_all_surfaces = nil
                copy.exclude_planets = nil
                copy.exclude_surface_names = nil
                local key = serpent.line(copy, {sortkeys = true})
                result[key] = (result[key] or 0) + 1
            end
        end
        return result
    end
    local original_names = {}
    local can_shuffle = true
    for name, planet in pairs(before_planets) do
        if planet.hidden ~= true and planet.orig_name == nil and name ~= constants.starting_planet then
            if planet.persistent_ambient_sounds == nil then can_shuffle = false end
            for other in pairs(original_names) do
                if equal(planet.persistent_ambient_sounds, before_planets[other].persistent_ambient_sounds) then
                    can_shuffle = false
                end
            end
            original_names[name] = true
        end
    end
    local original_count = 0
    for _ in pairs(original_names) do original_count = original_count + 1 end
    can_shuffle = can_shuffle and original_count > 1
    audio_execute()
    local checked, copies = 0, 0
    local original_sources = {}
    for name, source in pairs(planet_sounds.sources) do
        local planet = data.raw.planet[name]
        assert(source ~= (planet.orig_name or name), "Audio kept original family: " .. name)
        assert(equal(planet.persistent_ambient_sounds, before_planets[source].persistent_ambient_sounds), "Split ambience on " .. name)
        assert(equal(playlist(data.raw["ambient-sound"], name), playlist(before_tracks, source)), "Wrong music on " .. name)
        checked = checked + 1
        if planet.orig_name ~= nil then
            copies = copies + 1
        elseif can_shuffle then
            assert(original_names[source], "Original shuffle used an identity outside its pool")
            assert(original_sources[source] == nil, "Distinct loaded original profiles did not form a permutation")
            original_sources[source] = true
        end
    end
    assert(checked > 0 and copies > 0, "Production gate did not randomize copies")
    assert(equal(data.raw.planet[constants.starting_planet], before_planets[constants.starting_planet]), "Starting planet changed")
    for _, name in pairs({constants.starting_planet, "propertyrandomizer-test-laboratory", "unrelated-test-surface"}) do
        assert(equal(playlist(data.raw["ambient-sound"], name), playlist(before_tracks, name)), "Unrelated music changed")
    end
    log("PLANETSOUNDTEST checked " .. checked .. " profiles including " .. copies .. " copies")
end
'''


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--isolated", action="store_true", help="test audio directly after verifying the ordinary dupes config leaves it disabled")
    args = parser.parse_args()
    original_snapshot = runner.snapshot
    original_run_one = runner.run_one

    def snapshot_with_check(dest, ref, staged, source_dir):
        original_snapshot(dest, ref, staged, source_dir)
        with (Path(dest) / "data-updates.lua").open("a") as updates:
            updates.write(SELECTOR_FIXTURES)
        module = Path(dest) / "src/randomizations/planetary/planet-sounds.lua"
        module.write_text(module.read_text().replace("return planet_sounds\n", CHECK + "\nreturn planet_sounds\n"))
        if args.isolated:
            final = Path(dest) / "src/pipeline/data-final-fixes.lua"
            gate = "if config.planet_names == true then\n    planet_sounds.execute()\nend\n"
            text = final.read_text()
            assert text.count(gate) == 1, "Production audio gate was not found"
            final.write_text(text.replace(gate, gate + r'''
assert(config.planet_names == false, "Isolated fixture unexpectedly enabled identity randomization")
assert(next(planet_sounds.sources) == nil, "Production gate randomized audio while disabled")
planet_sounds.execute()
'''))

    def checked_run_one(run, ctx):
        result = original_run_one(run, ctx)
        if "PLANETSOUNDTEST checked " not in (Path(result["dir"]) / "create.log").read_text():
            problem = "production planet audio assertions did not pass"
            result["problems"].append(problem)
            result.setdefault("hard_problems", []).append(problem)
            result["ok"] = False
        return result

    runner.snapshot = snapshot_with_check
    runner.run_one = checked_run_one
    if args.isolated:
        original_plan = runner.Plan

        class AudioPlan(original_plan):
            def __init__(self, *params):
                super().__init__(*params)
                self.configs = [config for config in self.configs if config.name == "dupes"]

        runner.Plan = AudioPlan
        return runner.main(["settings", "--modset", "sa", "--jobs", "1"])
    return runner.main(["unified", "--only", "/dupes-preview@1", "--modset", "sa", "--jobs", "1"])


if __name__ == "__main__":
    raise SystemExit(main())

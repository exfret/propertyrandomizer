#!/usr/bin/env python3
"""The performance gate must reject commits that make loads run more Lua, not just collect counts."""
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location("runner", ROOT / "dev/run-tests.py")
runner = importlib.util.module_from_spec(spec)
spec.loader.exec_module(runner)


def setting(name, default="false", kind="bool-setting", allowed="", minimum="", maximum=""):
    return runner.Setting([runner.PREFIX + name, kind, default, "false", allowed, minimum, maximum])


M = 1000000


def result(count, ok=True, control=M):
    return {"ok": ok, "instructions": {"create": count, "control": control}, "timings": {"create": 30.0, "control": 1.0},
            "dir": "/tmp/fixture", "problems": [] if ok else ["load failed"]}


class ComparisonTests(unittest.TestCase):
    def compare(self, before, after, phase="create"):
        calls = []
        def sample(side, attempt):
            calls.append((side, attempt))
            count = before if side == "baseline" else after
            return result(10 * M, control=count) if phase == "control" else result(count)
        report, error = runner.timing_compare.compare(sample, ["create", "control"])
        return report, error, calls

    def test_hundredfold_regression_blocks_from_one_pair(self):
        # Counts repeat exactly for the same code and game, so nothing is run again
        report, error, calls = self.compare(10 * M, 1000 * M)
        self.assertIn("Lua instruction regression", error)
        self.assertEqual(report["phases"]["create"]["ratio"], 100)
        self.assertEqual(calls, [("baseline", 1), ("candidate", 1)])

    def test_both_thresholds_must_be_exceeded(self):
        # Under 25% more; a large ratio under 200 million more; exactly 25% more; fewer
        for before, after in [(1000 * M, 1200 * M), (100 * M, 250 * M), (800 * M, 1000 * M), (10 * M, 9 * M)]:
            with self.subTest(before=before, after=after):
                _, error, calls = self.compare(before, after)
                self.assertIsNone(error)
                self.assertEqual(len(calls), 2)

    def test_two_hundred_million_more_at_a_large_enough_ratio_blocks(self):
        _, error, _ = self.compare(400 * M, 600 * M)
        self.assertIn("Lua instruction regression", error)

    def test_control_regression_cannot_hide_behind_creation(self):
        _, error, _ = self.compare(10 * M, 1000 * M, "control")
        self.assertIn("control:", error)

    def test_counts_of_nothing_compare(self):
        # A control stage that never reaches one hook interval counts 0 on both sides
        report, error, _ = self.compare(0, 0, "control")
        self.assertIsNone(error)
        self.assertEqual(report["phases"]["control"]["ratio"], 1.0)

    def test_runtime_is_reported_next_to_the_counts(self):
        report, _, _ = self.compare(10 * M, 11 * M)
        line = runner.timing_compare.describe("create", report["phases"]["create"])
        self.assertIn("10.0M -> 11.0M Lua instructions", line)
        self.assertIn("runtime 30.00s -> 30.00s", line)

    def test_invalid_or_failed_samples_block(self):
        for side in ("baseline", "candidate"):
            for bad in (result(10 * M, False), result(None), result(float("nan")), result(-1), result(1.5)):
                with self.subTest(side=side, bad=bad):
                    _, error = runner.timing_compare.compare(lambda current, _: bad if current == side else result(10 * M), ["create"])
                    self.assertIn("timing comparison failed", error)


class RunnerTests(unittest.TestCase):
    def test_missing_baseline_and_invalid_threshold_fail_before_starting_game(self):
        with mock.patch.object(runner, "game_version") as game, contextlib.redirect_stderr(io.StringIO()):
            with self.assertRaises(SystemExit) as error:
                runner.main(["--baseline-ref", "refs/heads/nonexistent-timing-test-baseline"])
            self.assertEqual(error.exception.code, 2)
            for threshold in ("nan", "inf", "-1"):
                with self.assertRaises(SystemExit) as error:
                    runner.main(["--timing-percent", threshold])
                self.assertEqual(error.exception.code, 2)
            game.assert_not_called()

    def test_queue_time_is_not_measured(self):
        now = [0]
        proc = mock.Mock()
        def wait(**kwargs):
            now[0] += 3
            return 0
        proc.wait.side_effect = wait
        @contextlib.contextmanager
        def started(*args, **kwargs):
            now[0] += 1000  # Waiting for a session slot.
            yield proc
        with tempfile.TemporaryDirectory() as folder:
            path = os.path.join(folder, "create.log")
            with mock.patch.object(runner.factorio_launch, "started", started), mock.patch.object(runner.time, "monotonic", lambda: now[0]):
                processes = runner.Processes()
                self.assertEqual(processes.run([], path), 0)
            self.assertEqual(processes.seconds[path], 3)

    def test_configs_are_matched_even_with_default_changes_or_new_feature(self):
        shared = setting("shared", "true")
        feature = setting("biome", "true")
        candidate = {"shared": shared, "biome": feature}
        baseline = {"shared": setting("shared"), "old": setting("old")}
        run = runner.Run(runner.Config("settings", "fixture", {}, 42, set(), False), "sa")
        current, previous, notes = runner.timing_runs(run, candidate, baseline)
        self.assertTrue(previous.config.settings["shared"])
        self.assertTrue(current.config.settings["biome"])
        self.assertNotIn("biome", previous.config.settings)
        self.assertEqual(previous.config.seed, current.config.seed)
        self.assertEqual(len(notes), 2)
        self.assertIn("comparison still runs", notes[0])

    def test_incompatible_shared_settings_block(self):
        run = runner.Run(runner.Config("settings", "fixture", {}, 42, set(), False), "sa")
        for candidate, baseline in [
            (setting("x"), setting("x", "0", "int-setting")),
            (setting("x", "new", "string-setting", "old,new"), setting("x", "old", "string-setting", "old")),
            (setting("x", "5", "int-setting"), setting("x", "0", "int-setting", minimum="0", maximum="4")),
        ]:
            with self.subTest(candidate=candidate.type), self.assertRaises(ValueError):
                runner.timing_runs(run, {"x": candidate}, {"x": baseline})

    def test_shared_float_defaults_are_not_rounded(self):
        run = runner.Run(runner.Config("settings", "fixture", {}, 42, set(), False), "sa")
        settings = {"x": setting("x", "0.123456789", "double-setting")}
        current, previous, _ = runner.timing_runs(run, settings, settings)
        self.assertEqual(current.config.settings, previous.config.settings)

    def test_wip_performance_failure_blocks_summary(self):
        run = runner.Run(runner.Config("unified", "fixture", {}, 42, {"control"}, False), "sa")
        with tempfile.TemporaryDirectory() as folder:
            ctx = runner.Context(folder, folder, {}, {}, (), False, False)
            base = runner.Context(os.path.join(folder, "baseline"), folder, {}, {}, (), False, False)
            def measured(picked, context):
                sample = result(10 * M if "baseline" in context.root else 1000 * M)
                sample.update(run=picked, hard_problems=[])
                return sample
            with mock.patch.object(runner, "run_one_safely", measured), contextlib.redirect_stdout(io.StringIO()):
                measured_result = runner.run_timed(run, ctx, base, 25, 200 * M)
            summary, passed = runner.summarize([measured_result], runner.TestFile(), 0)
            self.assertFalse(passed)
            self.assertIn("[hard failure]", summary)
            self.assertIn("Lua instruction regression", summary)

    def test_parallel_configs_share_the_helper_link(self):
        # Configs run two at a time and share each side's folder: a side whose helper link another config made after this one would have checked still runs
        runs = [runner.Run(runner.Config("settings", name, {}, 42, {"control"}, False), "sa") for name in ("first", "second")]
        with tempfile.TemporaryDirectory() as folder:
            ctx = runner.Context(folder, folder, {}, {}, (), False, False)
            base = runner.Context(os.path.join(folder, "baseline"), folder, {}, {}, (), False, False)
            def measured(picked, context):
                sample = result(10 * M)
                sample.update(run=picked, hard_problems=[])
                return sample
            # Every link looks missing, as it does to two sides that check at the same time
            with mock.patch.object(runner, "run_one_safely", measured), mock.patch.object(runner.os.path, "islink", lambda path: False), contextlib.redirect_stdout(io.StringIO()):
                results = [runner.run_timed(run, ctx, base, 25, 200 * M) for run in runs]
            for measured_result in results:
                self.assertTrue(measured_result["ok"], measured_result["problems"])

    def test_log_counts(self):
        # The data stage's line, plus each mod's last control-stage line; a mod that never reached one interval counts 0
        text = "\n".join([
            "PRCOUNT data samples=12 interval=100000",
            "PRCOUNT control propertyrandomizer start interval=100000",
            "PRCOUNT control propertyrandomizer-test-helper start interval=100000",
            "PRCOUNT control propertyrandomizer samples=1",
            "PRCOUNT control propertyrandomizer samples=2",
        ])
        self.assertEqual(runner.lua_instructions(text), 14 * 100000)
        self.assertEqual(runner.lua_instructions("PRCOUNT control base start interval=100000"), 0)
        self.assertIsNone(runner.lua_instructions("no counter here"))

    def test_counted_runs_load_the_counter_in_both_stages(self):
        with tempfile.TemporaryDirectory() as folder:
            modsets = {"sa": {"links": [], "list": {"mods": []}, "settings": {}}}
            ctx = runner.Context(folder, os.path.join(folder, "mod"), {}, modsets, (2, 1, 0), False, False)
            ctx.counter = os.path.join(folder, runner.COUNTER_NAME)
            commands = []

            class Processes:
                seconds = {}

                def run(self, args, log_path):
                    commands.append(args)
                    lines = ["PRCOUNT control propertyrandomizer start interval=100000"]
                    if "--benchmark" in args:
                        lines += ["Performed " + str(runner.CONTROL_TICKS) + " updates", "PRCOUNT control propertyrandomizer samples=2"]
                    else:
                        lines += ["PRCOUNT data samples=10 interval=100000", "PRCOUNT control propertyrandomizer samples=3"]
                    with open(log_path, "w") as f:
                        f.write("\n".join(lines) + "\n")
                    return 0

            ctx.processes = Processes()
            run = runner.Run(runner.Config("settings", "fixture", {}, 42, set(), False), "sa")
            measured = runner.run_one(run, ctx)
            mods_dir = os.path.join(folder, "runs", run.slug, "mods")
            self.assertEqual(os.readlink(os.path.join(mods_dir, runner.COUNTER_NAME)), ctx.counter)
            with open(os.path.join(mods_dir, "mod-list.json")) as f:
                self.assertIn({"name": runner.COUNTER_NAME, "enabled": True}, json.load(f)["mods"])
            self.assertEqual(len(commands), 2)
            for args in commands:
                self.assertIn("--enable-unsafe-lua-debug-api", args)
                self.assertEqual(args[args.index("--instrument-mod") + 1], runner.COUNTER_NAME)
            self.assertEqual(measured["instructions"], {"create": 13 * 100000, "control": 2 * 100000})

    def test_biome_configs_are_in_precommit(self):
        definitions = runner.TestFile()
        plan = runner.Plan(runner.load_settings(str(ROOT)), definitions, 0)
        picked = [config for config in plan.configs if any(pattern in "sa/" + config.name for pattern in definitions.tiers["precommit"])]
        for name in ("biome-placement@1", "biome-placement-dupes@1"):
            selected = next(config for config in picked if config.name == name)
            self.assertTrue(selected.settings["planetary-biome-placement"])
        self.assertTrue(next(config for config in picked if config.name == "biome-placement-dupes@1").settings["dupes"])

    def test_hook_requests_head_comparison_and_propagates_failure(self):
        with tempfile.TemporaryDirectory() as folder:
            # Stub git/python, so testing the installed hook needs no real commit or game.
            root = Path(folder)
            (root / "git").write_text('#!/bin/sh\nif [ "$1" = rev-parse ]; then pwd; else echo src/example.lua; fi\n')
            (root / "python3").write_text('#!/bin/sh\ncase "$1" in */run-tests.py) printf "%s\\n" "$@" > arguments; exit 23;; esac\n')
            for name in ("git", "python3"):
                (root / name).chmod(0o755)
            completed = subprocess.run(["bash", str(ROOT / "dev/git-hooks/pre-commit")], cwd=folder,
                                       env=dict(os.environ, PATH=folder + os.pathsep + os.environ["PATH"]), capture_output=True, text=True)
            self.assertEqual(completed.returncode, 23, completed.stderr)
            self.assertEqual((root / "arguments").read_text().splitlines()[1:],
                             ["--tier", "precommit", "--staged", "--baseline-ref", "HEAD"])


if __name__ == "__main__":
    unittest.main()

#!/usr/bin/env python3
"""The performance gate must reject slow commits, not just collect durations."""
import contextlib
import importlib.util
import io
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


def result(seconds, ok=True):
    return {"ok": ok, "timings": {"create": seconds, "control": 1}, "dir": "/tmp/fixture",
            "problems": [] if ok else ["load failed"]}


class ComparisonTests(unittest.TestCase):
    def compare(self, baseline, candidate, phase="create"):
        calls = []
        def sample(side, attempt):
            calls.append((side, attempt))
            measured = result((baseline if side == "baseline" else candidate)[attempt - 1])
            if phase == "control":
                measured["timings"]["control"] = measured["timings"]["create"]
                measured["timings"]["create"] = 10
            return measured
        report, error = runner.timing_compare.compare(sample, ["create", "control"])
        return report, error, calls

    def test_hundredfold_regression_blocks_after_confirmation(self):
        report, error, calls = self.compare([10, 10, 10], [1000, 1000, 1000])
        self.assertIn("timing regression", error)
        self.assertEqual(report["phases"]["create"]["ratio"], 100)
        self.assertEqual(calls, [("baseline", 1), ("candidate", 1), ("candidate", 2),
                                 ("baseline", 2), ("baseline", 3), ("candidate", 3)])

    def test_both_thresholds_must_be_exceeded(self):
        for before, after in [(100, 120), (1, 2), (8, 10), (10, 9)]:
            with self.subTest(before=before, after=after):
                _, error, calls = self.compare([before], [after])
                self.assertIsNone(error)
                self.assertEqual(len(calls), 2)

    def test_two_seconds_at_large_enough_ratio_blocks(self):
        _, error, _ = self.compare([4] * 3, [6] * 3)
        self.assertIn("timing regression", error)

    def test_initial_outlier_does_not_block(self):
        report, error, _ = self.compare([10, 10, 10], [1000, 10, 11])
        self.assertIsNone(error)
        self.assertEqual(report["phases"]["create"]["candidate"], 11)

    def test_control_regression_cannot_hide_behind_creation(self):
        _, error, _ = self.compare([10] * 3, [20] * 3, "control")
        self.assertIn("control:", error)

    def test_invalid_or_failed_samples_block(self):
        for side in ("baseline", "candidate"):
            for bad in (result(10, False), result(None), result(float("nan")), result(0)):
                with self.subTest(side=side, bad=bad):
                    _, error = runner.timing_compare.compare(lambda current, _: bad if current == side else result(10), ["create"])
                    self.assertIn("timing comparison failed", error)

    def test_failed_confirmation_is_not_discarded(self):
        def sample(side, attempt):
            return result(10 if side == "baseline" else 1000, attempt != 2)
        _, error = runner.timing_compare.compare(sample, ["create"])
        self.assertIn("attempt 2", error)


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
                sample = result(10 if "baseline" in context.root else 1000)
                sample.update(run=picked, hard_problems=[])
                return sample
            with mock.patch.object(runner, "run_one_safely", measured), contextlib.redirect_stdout(io.StringIO()):
                measured_result = runner.run_timed(run, ctx, base, 25, 2)
            summary, passed = runner.summarize([measured_result], runner.TestFile(), 0)
            self.assertFalse(passed)
            self.assertIn("[hard failure]", summary)
            self.assertIn("timing regression", summary)

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

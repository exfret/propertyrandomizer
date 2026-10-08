#!/usr/bin/env python3
"""Hard acceptance limits must fail even experimental suites."""
import importlib.util
from pathlib import Path
from types import SimpleNamespace
import unittest

spec = importlib.util.spec_from_file_location("runner", Path(__file__).with_name("run-tests.py"))
runner = importlib.util.module_from_spec(spec)
spec.loader.exec_module(runner)


class HardLimitTests(unittest.TestCase):
    def summarize(self, text):
        hard = runner.check_hard_limits(text)
        run = SimpleNamespace(name="fixture", config=SimpleNamespace(suite="unified", describe=lambda: "fixture"))
        result = {"run": run, "ok": not hard, "problems": hard, "hard_problems": hard, "dir": "/tmp/fixture"}
        return runner.summarize([result], SimpleNamespace(wip={"unified"}), 1)

    def test_resource_limit_is_hard_in_wip_suite(self):
        summary, ok = self.summarize("PLANETCHECK extra patches: 9 on 15 planets: fixture")
        self.assertFalse(ok)
        self.assertIn("1 TESTS FAILED", summary)
        self.assertNotIn("ALL TESTS PASSED", summary)

    def test_single_operation_gap_is_hard_in_wip_suite(self):
        summary, ok = self.summarize("OPERATIONCHECK checked 87 building items; 1 precede operation readiness")
        self.assertFalse(ok)
        self.assertIn("1 of 87", summary)

    def test_both_failures_are_preserved(self):
        errors = runner.check_hard_limits("PLANETCHECK extra patches: 9 on 15 planets\nOPERATIONCHECK checked 87 building items; 1 precede operation readiness")
        self.assertEqual(len(errors), 2)

    def test_boundary_and_clean_audit_pass(self):
        _, ok = self.summarize("PLANETCHECK extra patches: 7 on 15 planets\nOPERATIONCHECK checked 213 building items; 0 precede operation readiness")
        self.assertTrue(ok)

    def test_logged_limit_decides(self):
        # The mod logs the limit it holds the game to, which wins over the runner's own rule
        self.assertEqual(len(runner.check_extra_patches("PLANETCHECK extra patches: 16 on 15 planets (at most 7): a, b")), 1)
        self.assertEqual(runner.check_extra_patches("PLANETCHECK extra patches: 7 on 15 planets (at most 7): a"), [])
        self.assertEqual(len(runner.check_extra_patches("PLANETCHECK extra patches: 3 on 15 planets (at most 2)")), 1)
        problem = runner.check_extra_patches("PLANETCHECK extra patches: 16 on 15 planets (at most 7): fixture-a, fixture-b")[0]
        self.assertIn("(at most 7): fixture-a, fixture-b", problem)
        self.assertEqual(runner.check_conversions("PLANETCHECK conversions: 1 in the game (at most 1): fixture"), [])
        self.assertEqual(len(runner.check_conversions("PLANETCHECK conversions: 2 in the game (at most 1): fixture")), 1)
        self.assertEqual(runner.check_conversions("PLANETCHECK conversions: 0 in the game (at most 1)"), [])

    def test_disabled_audit_is_optional(self):
        self.assertEqual(runner.check_operation_readiness(""), [])

    def test_last_operation_audit_decides(self):
        self.assertEqual(runner.check_operation_readiness("OPERATIONCHECK checked 87 building items; 1 precede operation readiness\nOPERATIONCHECK checked 87 building items; 0 precede operation readiness"), [])


if __name__ == "__main__":
    unittest.main()

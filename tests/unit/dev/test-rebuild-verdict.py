#!/usr/bin/env python3
"""A run fails when the tech tree rebuild's checks of its tree fail (REBUILDCHECK, src/randomizations/rebuild/tree-checks.lua), or ran without a verdict."""
import importlib.util
from pathlib import Path
import unittest

spec = importlib.util.spec_from_file_location("runner", Path(__file__).resolve().parents[3] / "dev/run-tests.py")
runner = importlib.util.module_from_spec(spec)
spec.loader.exec_module(runner)

SUMMARY = "12.5 Script @__propertyrandomizer__/src/randomizations/rebuild/tree.lua:1: Tech tree rebuild: 1200 technologies for 1100 recipes (1150 planned for rooms, 3 for recipes no room makes); ...\n"


class RebuildVerdictTests(unittest.TestCase):
    def test_passing_verdict(self):
        self.assertEqual(runner.check_rebuild(SUMMARY + "REBUILDCHECK gates: 0\nREBUILDCHECK verdict: ok\n"), [])

    def test_failing_rules_are_named(self):
        text = SUMMARY + "REBUILDCHECK gates: 3 (e.g. a; b)\nREBUILDCHECK served: 0\nREBUILDCHECK fan-out (information): 5 (x 9)\nREBUILDCHECK verdict: FAILED (gates 3)\n"
        problems = runner.check_rebuild(text)
        self.assertEqual(len(problems), 1)
        self.assertIn("REBUILDCHECK verdict FAILED (gates 3)", problems[0])
        self.assertIn("REBUILDCHECK gates: 3", problems[0])
        self.assertNotIn("fan-out", problems[0])

    def test_rebuild_without_verdict_fails(self):
        self.assertEqual(len(runner.check_rebuild(SUMMARY)), 1)

    def test_no_rebuild_or_py_needs_none(self):
        self.assertEqual(runner.check_rebuild("nothing about the rebuild\n"), [])
        self.assertEqual(runner.check_rebuild("REBUILDCHECK verdict: skipped (py keeps the rebuild from before the 2026-10-12 redesign)\n"), [])


if __name__ == "__main__":
    unittest.main()

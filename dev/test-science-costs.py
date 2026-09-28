#!/usr/bin/env python3
"""Regression checks for science cost thresholds and incomplete measurements."""
import importlib.util
from pathlib import Path
import unittest

spec = importlib.util.spec_from_file_location("runner", Path(__file__).with_name("run-tests.py"))
runner = importlib.util.module_from_spec(spec)
spec.loader.exec_module(runner)


def measurements(before, after):
    return "\n".join("SCIENCECOST\t" + stage + "\t" + pack + "\t" + str(cost)
                     for stage, prices in [("before", before), ("after", after)]
                     for pack, cost in prices.items())


class ScienceCostTests(unittest.TestCase):
    def check(self, before, after):
        return runner.check_science_costs(measurements(before, after))

    def test_limits_are_independent_and_exact_four_is_allowed(self):
        errors, _ = self.check({"a": 1, "b": 1, "c": 1}, {"a": 4, "b": .5, "c": .5})
        self.assertEqual(errors, [])
        errors, _ = self.check({"a": 1, "b": 1, "c": 1}, {"a": 4.01, "b": .5, "c": .5})
        self.assertEqual(len(errors), 1)
        self.assertIn("maximum 4x", errors[0])

    def test_mean_is_unweighted_ratio_and_exact_two_fails(self):
        errors, _ = self.check({"cheap": 1, "expensive": 100}, {"cheap": 3, "expensive": 100})
        self.assertEqual(len(errors), 1)
        self.assertIn("mean pack ratio 2.000x", errors[0])

    def test_both_limits_reported(self):
        errors, _ = self.check({"a": 1, "b": 1}, {"a": 5, "b": 1})
        self.assertEqual(len(errors), 2)

    def test_unpriced_baseline_fails_coverage_and_is_not_averaged(self):
        errors, summary = self.check({"a": 1, "b": "unpriced"}, {"a": 1, "b": "unpriced"})
        self.assertEqual(len(errors), 1)
        self.assertIn("b has no baseline price", errors[0])
        self.assertIn("1 packs", summary)
        self.assertIn("no baseline price: b", summary)
        self.assertIn("INCOMPLETE", summary)

    def test_losing_price_or_measurement_fails(self):
        for after in [{"a": "unpriced", "b": 1}, {"b": 1}]:
            errors, _ = self.check({"a": 1, "b": 1}, after)
            self.assertEqual(len(errors), 1)

    def test_empty_or_entirely_unpriced_does_not_pass(self):
        for before, after in [({}, {}), ({"a": 1}, {}), ({"a": "unpriced"}, {"a": "unpriced"})]:
            self.assertTrue(self.check(before, after)[0])

    def test_zero_baseline_and_invalid_numbers(self):
        self.assertEqual(self.check({"a": 0}, {"a": 0})[0], [])
        self.assertTrue(self.check({"a": 0}, {"a": 1})[0])
        for value in ["nan", "inf", -1, "broken"]:
            self.assertTrue(self.check({"a": 1, "b": 1}, {"a": value, "b": 1})[0])

    def test_duplicate_measurements_fail(self):
        text = measurements({"a": 1}, {"a": 1}) + "\nSCIENCECOST\tafter\ta\t1"
        self.assertIn("duplicate", runner.check_science_costs(text)[0][0])


if __name__ == "__main__":
    unittest.main()

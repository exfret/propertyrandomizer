#!/usr/bin/env python3
"""Check unit-test selection, working directories, failures, and timeouts."""
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

RUNNER = Path(__file__).resolve().parents[3] / "dev/run-unit-tests.py"


class UnitRunnerTests(unittest.TestCase):
    def run_fixture(self, sources, *arguments):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            (root / "root-marker").write_text("fixture")
            for name, source in sources.items():
                path = root / "tests/unit" / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(source)
            return subprocess.run([sys.executable, str(RUNNER), "--root", folder, *arguments],
                                  cwd=root.parent, capture_output=True, text=True, timeout=20)

    def test_selection_lists_only_tests_and_does_not_execute_them(self):
        sources = {
            "lib/test-one.py": "raise RuntimeError('must not run')",
            "lib/test-two.lua": "error('must not run')",
            "lib/contexts-for-tests.lua": "error('fixture helper')",
        }
        result = self.run_fixture(sources, "--list", "--only", "test-one")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.splitlines(), ["tests/unit/lib/test-one.py"])
        result = self.run_fixture(sources, "--list", "--only", "misspelled-selection")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("no unit tests match", result.stderr)

    def test_files_run_at_the_selected_root_and_failures_do_not_skip_later_tests(self):
        result = self.run_fixture({
            "test-a.py": "raise RuntimeError('expected failure')",
            "test-b.py": "from pathlib import Path\nassert Path('root-marker').read_text() == 'fixture'\nprint('later test ran')",
        }, "--verbose")
        self.assertEqual(result.returncode, 1)
        self.assertIn("later test ran", result.stdout)
        self.assertIn("1 passed, 1 failed", result.stdout)

    def test_a_timeout_fails_the_file_and_keeps_running(self):
        result = self.run_fixture({
            "test-a.py": "import time\ntime.sleep(10)",
            "test-b.py": "print('finished')",
        }, "--timeout", "0.5", "--verbose")
        self.assertEqual(result.returncode, 1)
        self.assertIn("Timed out after 0.5 seconds", result.stdout)
        self.assertIn("finished", result.stdout)
        self.assertIn("1 passed, 1 failed", result.stdout)


if __name__ == "__main__":
    unittest.main()

#!/usr/bin/env python3
"""Existing table approvals follow moves without approving new name sets."""
import importlib.util
import json
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest
from unittest import mock

spec = importlib.util.spec_from_file_location("hardcoded_names", Path(__file__).resolve().parents[3] / "dev/hardcoded-names.py")
checker = importlib.util.module_from_spec(spec)
spec.loader.exec_module(checker)


class MovedApprovalTests(unittest.TestCase):
    def test_unchanged_tables_follow_moves_but_new_tables_and_edits_are_checked(self):
        previous = "lib/fixture.lua"
        current = "src/prototypes/fixture.lua"
        original = 'local existing = {["first"] = true, module = "lib/fixture"}\n'
        formatted = 'local existing = {\n    -- moved without changing the table\n    ["first"] = true,\n    module = "src/prototypes/fixture",\n}\n'
        names = SimpleNamespace(kind=lambda value: "type" if value in {"first", "second"} else None)
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            (root / "dev").mkdir()
            (root / "dev/module-moves.json").write_text(json.dumps({previous: current}))
            target = root / current
            target.parent.mkdir(parents=True)
            result = SimpleNamespace(returncode=0, stdout=original)
            with mock.patch.object(checker, "REPO", folder), mock.patch.object(checker, "changed_rows", return_value={current: None}), mock.patch.object(checker, "git", return_value=result):
                for source, count in ((formatted, 0),
                                      (formatted + 'local added = {["first"] = true, module = "src/prototypes/fixture"}\n', 1),
                                      (formatted.replace('true', 'false'), 1),
                                      (formatted.replace('["first"]', '["second"]'), 1)):
                    with self.subTest(source=source):
                        target.write_text(source)
                        self.assertEqual(len(checker.changed_tables("HEAD", names)), count)
                target.write_text(formatted)
                # Copies and files absent from the Git baseline retain the full audit.
                source = root / previous
                source.parent.mkdir(parents=True)
                source.write_text(original)
                self.assertEqual(len(checker.changed_tables("HEAD", names)), 1)
                source.write_text('require("src/prototypes/fixture")\n')
                self.assertEqual(len(checker.changed_tables("HEAD", names)), 0)
                source.write_text('require("src/prototypes/fixture")\nlocal extra = true\n')
                self.assertEqual(len(checker.changed_tables("HEAD", names)), 1)
                source.unlink()
                result.returncode = 1
                self.assertEqual(len(checker.changed_tables("HEAD", names)), 1)

    def test_move_preserves_exact_approval_without_writing_the_store(self):
        previous = "lib/fixture.lua"
        current = "src/prototypes/fixture.lua"
        original = checker.Table(previous, 0, [(0, "alpha", "name")], [])
        relocated = checker.Table(current, 0, original.matches, [])
        expanded = checker.Table(current, 0, original.matches + [(0, "beta", "name")], [])
        unrelated = checker.Table("src/prototypes/unrelated.lua", 0, original.matches, [])
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            store = root / "approvals.json"
            stored = {original.id: {"file": previous, "names": original.names, "approved": "fixture"}}
            store.write_text(json.dumps(stored))
            (root / "dev").mkdir()
            (root / "dev/module-moves.json").write_text(json.dumps({previous: current}))
            target = root / current
            target.parent.mkdir(parents=True)
            target.write_text("")
            with mock.patch.object(checker, "REPO", folder), mock.patch.object(checker, "approvals_path", return_value=str(store)):
                approved = checker.load_approvals()
                self.assertEqual(checker.unapproved([relocated], approved), [])
                self.assertEqual(checker.unapproved([expanded, unrelated], approved), [expanded, unrelated])
                self.assertEqual(json.loads(store.read_text()), stored)
                # A copy does not inherit another file's approval while the original exists.
                source = root / previous
                source.parent.mkdir(parents=True)
                source.write_text("")
                self.assertEqual(checker.unapproved([relocated], checker.load_approvals()), [relocated])
                source.write_text('require("src/prototypes/fixture")\n')
                self.assertEqual(checker.unapproved([relocated], checker.load_approvals()), [])
                source.write_text('require("src/prototypes/fixture")\nlocal extra = true\n')
                self.assertEqual(checker.unapproved([relocated], checker.load_approvals()), [relocated])


if __name__ == "__main__":
    unittest.main()

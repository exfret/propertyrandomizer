#!/usr/bin/env python3
"""Negative regression tests for the localisation guard, including staged-file reading."""
import importlib.util
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest import mock

spec = importlib.util.spec_from_file_location("localisation", Path(__file__).with_name("check-localisation.py"))
check = importlib.util.module_from_spec(spec)
spec.loader.exec_module(check)


class LocalisationGuardTests(unittest.TestCase):
    keys = {"propertyrandomizer-test.label": "Label __1__", "propertyrandomizer-customizer.tab": "Customizer"}

    def findings(self, source, path="scripts/fixture.lua"):
        return check.check_source(source, path, self.keys)

    def test_rejects_player_facing_literals(self):
        for source in (
            'root.add({type="label", caption="New English caption"})',
            'root.add({type="button", tooltip="New tooltip"})',
            'root.caption = "Later caption"',
            'root.caption = string.format("English %d", count)',
            'root.caption = table.concat({"Raw", "labels"}, " ")',
            'root["tooltip"] = "Later tooltip"',
            'label(root, "Helper label")',
            'player.print("New message")',
            'game.print({"", "New warning"})',
            'item.localised_description = "New description"',
            'item.localised_name = "Generated name"',
            'root.add({type="drop-down", items={"New choice"}})',
            'root.items = {"New choice"}',
            'root.caption = {"", {"propertyrandomizer-test.label", "id"}, " and more English"}',
        ):
            with self.subTest(source=source):
                self.assertTrue(self.findings(source))

    def test_accepts_localised_strings_and_technical_parameters(self):
        for source in (
            'root.caption = {"propertyrandomizer-test.label", "prototype-id"}',
            'root.caption = {"", "\\n[color=red]", {"propertyrandomizer-test.label", "id"}, "[/color]"}',
            'root.add({items={{"propertyrandomizer-test.label", "id"}}})',
            'player.print({"propertyrandomizer-test.label", 12})',
            'root.caption = {"?", {"entity-name.external"}, prototype.name}',
            'root.caption = ""',
            '-- caption = "comment"\nlog("English diagnostic")',
            'local example = [[caption = "documentation"]]',
            'local text = "propertyrandomizer-test." .. id',
        ):
            with self.subTest(source=source):
                self.assertEqual([], self.findings(source))

    def test_missing_literal_and_helper_keys(self):
        self.assertTrue(self.findings('root.caption = {"propertyrandomizer-test.missing"}'))
        self.assertTrue(self.findings('label(root, text("missing"))', "scripts/customizer.lua"))
        self.assertEqual([], self.findings('label(root, text("tab"))', "scripts/customizer.lua"))

    def test_duplicate_catalogue_keys(self):
        _, errors = check.catalogue({"locale/en/a.cfg": "[section]\nkey=First\n", "locale/en/b.cfg": "[section]\nkey=Second\n"})
        self.assertTrue(errors)

    def test_staged_sources_and_catalogue_are_authoritative(self):
        # A commit hook exports repository-specific Git variables. The fixture must
        # use its own index and object database, even when run from that hook.
        environment = {key: value for key, value in os.environ.items() if not key.startswith("GIT_")}
        with tempfile.TemporaryDirectory() as directory, mock.patch.dict(os.environ, environment, clear=True):
            root = Path(directory)
            subprocess.run(["git", "init", "-q", str(root)], check=True)
            (root / "scripts").mkdir()
            (root / "locale/en").mkdir(parents=True)
            source = root / "scripts/fixture.lua"
            locale = root / "locale/en/test.cfg"
            source.write_text('root.caption = {"propertyrandomizer-test.label", "id"}')
            locale.write_text('[propertyrandomizer-test]\nlabel=Localized __1__\n')
            subprocess.run(["git", "add", "."], cwd=root, check=True)
            source.write_text('root.caption = "Unstaged English"')
            self.assertEqual([], check.audit(check.read_files(root, staged=True)))
            self.assertTrue(check.audit(check.read_files(root)))
            subprocess.run(["git", "add", "."], cwd=root, check=True)
            source.write_text('root.caption = {"propertyrandomizer-test.label", "id"}')
            self.assertTrue(check.audit(check.read_files(root, staged=True)))

    def test_staged_fixture_preserves_inherited_git_environment(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            index = root / "outer.index"
            original = b"Caller index must remain untouched"
            index.write_bytes(original)
            environment = dict(os.environ, GIT_INDEX_FILE=str(index), GIT_DIR=str(root / "outer.git"), GIT_WORK_TREE=str(root))
            result = subprocess.run(
                [sys.executable, str(Path(__file__).resolve()), "LocalisationGuardTests.test_staged_sources_and_catalogue_are_authoritative"],
                env=environment, capture_output=True, text=True,
            )
            self.assertEqual(0, result.returncode, result.stdout + result.stderr)
            self.assertEqual(original, index.read_bytes())
            self.assertFalse((root / "outer.git").exists())


if __name__ == "__main__":
    unittest.main()

#!/usr/bin/env python3
"""Run with a Python containing tree-sitter==0.25.2 and tree-sitter-lua."""

import importlib.util
import contextlib
import io
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("style_check", Path(__file__).with_name("style-check.py"))
style = importlib.util.module_from_spec(spec)
spec.loader.exec_module(style)


class RequirePlacementTests(unittest.TestCase):
    def findings(self, source):
        return style.check_source(source.encode(), requires_only=True)

    def test_allowed(self):
        examples = [
            'local x = require("x")',
            'require("x")',
            'local x = require("x").value',
            'do local x = require("x") end',
            'if mods["x"] then require("x") end',
            'if not mods.x then require("fallback") end',
            'if (mods.x ~= nil) and not (mods["y"] == nil) then require("x") end',
            'if nil ~= mods.x or script.active_mods.y then require("x") end',
            'if (script . active_mods)["x"] then require("x") end',
            'if mods.x then f() elseif mods.y then require("y") else require("z") end',
            'if mods.x then require("x") elseif arbitrary_flag then f() end',
            'if mods.x then if mods.y then require("x") end end',
            'local x = mods.x and require("x")',
            'local x = not mods.x or require("x")',
            'local x = mods.x and require("x") or nil',
            '-- if flag then require("x") end\nlocal s = [[require("y")]]',
            'local object = {require = true}; object.require()',
            'object:require()',
        ]
        for source in examples:
            with self.subTest(source=source):
                self.assertEqual([], self.findings(source))

    def test_rejected(self):
        examples = [
            'if flag then require("x") end',
            'if flag then f() elseif mods.x then require("x") end',
            'if mods.x then f() elseif flag then f() else require("x") end',
            'if mods.x and flag then require("x") end',
            'if mods.x or flag then require("x") end',
            'if mods.x == "2.0" then require("x") end',
            'if mods[get_name()] then require("x") end',
            'if flag then if mods.x then require("x") end end',
            'local x = flag and require("x")',
            'local x = flag or require("x")',
            'local x = mods.x and flag and require("x")',
            'local x = f(require("x"))',
            'require("x").run()',
            'require("x"):run()',
            'require("x")()',
            '(require("x"))()',
            'pcall(require, "x")',
            'local loader = require',
            'local loaders = {require}',
            'local loaders = {loader = require}',
            'local loaders = {[require] = true}',
            'local function f() require("x") end',
            'function t.f() require("x") end',
            'local f = function() require("x") end',
            'f(function() require("x") end)',
            'for k, v in pairs(t) do require("x") end',
            'for i = 1, 2 do require("x") end',
            'while mods.x do require("x") end',
            'repeat require("x") until mods.x',
            'if mods.x then f(require("x")) end',
        ]
        for source in examples:
            with self.subTest(source=source):
                self.assertTrue(self.findings(source))

    def test_guard_and_scope_edits_are_checked(self):
        source = 'if flag then\n    local x = require("x")\nend'
        finding, = self.findings(source)
        self.assertEqual(1, finding.row)
        self.assertTrue(finding.touches({0}))
        source = 'local function f()\n    local x = require("x")\nend'
        finding, = self.findings(source)
        self.assertTrue(finding.touches({0}))

    def test_staged_source_and_changed_rows(self):
        with patch.object(style, "read_source", return_value=b'if flag then\nrequire("x")\nend') as read:
            with patch.object(style, "changed_rows", return_value={0}):
                findings = style.check_file("x.lua", staged=True, requires_only=True)
            read.assert_called_once_with("x.lua", True)
        self.assertEqual(1, len(findings))

    def test_old_logic_is_checked_without_unrelated_style_rules(self):
        path = "lib/old-logic/example.lua"
        self.assertTrue(style.is_checked(path))
        with patch.object(style, "read_source", return_value=b"local function f() require('x') end"):
            findings = style.check_file(path, all_rows=True)
        self.assertEqual(["require-context"], [f.rule for f in findings])

    def test_syntax_errors_cannot_pass_audit(self):
        self.assertIn("syntax", [f.rule for f in self.findings('if flag then require("x")')])

    def test_index_is_checked_instead_of_working_copy(self):
        with tempfile.TemporaryDirectory() as directory:
            subprocess.run(["git", "init", "-q", directory], check=True)
            source = Path(directory) / "example.lua"
            allowed = 'local x = require("x")\n'
            forbidden = 'local function f() require("x") end\n'
            with patch.object(style, "REPO", directory):
                for staged, working, expected in [(allowed, forbidden, 0), (forbidden, allowed, 1)]:
                    source.write_text(staged)
                    subprocess.run(["git", "-C", directory, "add", "example.lua"], check=True)
                    source.write_text(working)
                    self.assertEqual(expected, len(style.check_file("example.lua", staged=True, requires_only=True)))

    def test_existing_hooks_block_violations(self):
        with patch.object(style, "read_source", return_value=b'if flag then\nrequire("x")\nend'):
            with patch.object(style, "changed_rows", return_value={0}):
                with patch.object(style.os.path, "exists", return_value=True):
                    with contextlib.redirect_stderr(io.StringIO()) as output:
                        result = style.hook_post_edit({"tool_input": {"file_path": str(Path(style.REPO) / "example.lua")}})
                    self.assertEqual(2, result)
                    self.assertIn("require-context", output.getvalue())
                with patch.object(style, "changed_files", return_value=["example.lua"]):
                    with contextlib.redirect_stderr(io.StringIO()):
                        self.assertEqual(2, style.hook_stop({}))


if __name__ == "__main__":
    unittest.main()

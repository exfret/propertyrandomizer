#!/usr/bin/env python3
"""Human review cannot silently carry over to edited or partially staged text."""
from contextlib import redirect_stdout
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location("player_text_review", ROOT / "dev/review-player-text.py")
review = importlib.util.module_from_spec(spec)
spec.loader.exec_module(review)


class PlayerTextReviewTests(unittest.TestCase):
    def setUp(self):
        self.folder = tempfile.TemporaryDirectory()
        self.addCleanup(self.folder.cleanup)
        self.root = Path(self.folder.name)
        self.environment = mock.patch.dict(os.environ, {key: value for key, value in os.environ.items()
                                                      if not key.startswith("GIT_")}, clear=True)
        self.environment.start()
        self.addCleanup(self.environment.stop)
        patch = mock.patch.object(review, "state_path", return_value=self.root / "receipts/state.json")
        patch.start()
        self.addCleanup(patch.stop)
        self.git("init", "-q")
        self.git("config", "user.email", "fixture@example.invalid")
        self.git("config", "user.name", "Test fixture")
        self.git("config", "core.hooksPath", "/dev/null")
        self.write("locale/en/test.cfg", "[test]\nname=Original\n")
        self.write("src/name.lua", 'item.localised_name = {"",\n    "Original",\n}\n')
        self.write("src/logic.lua", "local number = 1\n")
        self.git("add", ".")
        self.git("commit", "-qm", "baseline")

    def git(self, *args):
        return subprocess.run(["git", *args], cwd=self.root, check=True, capture_output=True)

    def write(self, path, source):
        full = self.root / path
        full.parent.mkdir(parents=True, exist_ok=True)
        full.write_text(source)

    def hook(self, function, payload):
        output = io.StringIO()
        with redirect_stdout(output):
            function(payload, self.root)
        return json.loads(output.getvalue()) if output.getvalue() else None

    def approve(self, ids, staged=False):
        with redirect_stdout(io.StringIO()):
            review.approve(self.root, ids, staged)

    def test_locale_and_multiline_lua_edits_require_review(self):
        self.write("locale/en/test.cfg", "[test]\nname=New wording\n")
        self.write("src/name.lua", 'item.localised_name = {"",\n    "New wording",\n}\n')
        self.write("src/logic.lua", "local number = 2\n")
        items = review.pending(self.root)
        self.assertEqual(["locale/en/test.cfg", "src/name.lua"], [item["path"] for item in items])
        self.assertIn("-name=Original", items[0]["diff"])
        self.assertIn("+name=New wording", items[0]["diff"])
        self.assertIn('+    "New wording",', items[1]["diff"])

    def test_approval_is_specific_to_contents_and_path(self):
        self.write("locale/en/test.cfg", "First draft\n")
        first = review.pending(self.root)[0]["id"]
        self.approve([first])
        self.assertEqual([], review.pending(self.root))
        self.write("locale/en/test.cfg", "Second draft\n")
        self.assertNotEqual(first, review.pending(self.root)[0]["id"])
        with self.assertRaises(ValueError):
            self.approve([first])
        self.write("locale/en/other.cfg", "First draft\n")
        self.assertEqual(2, len(review.pending(self.root)))

    def test_staged_and_working_text_have_separate_receipts(self):
        self.write("locale/en/test.cfg", "Staged draft\n")
        self.git("add", "locale")
        self.write("locale/en/test.cfg", "Unstaged correction\n")
        self.approve([review.pending(self.root)[0]["id"]])
        self.assertEqual([], review.pending(self.root))
        staged = review.pending(self.root, staged=True)
        self.assertEqual(1, len(staged))
        self.assertIn("+Staged draft", staged[0]["diff"])
        self.assertNotIn("Unstaged correction", staged[0]["diff"])
        self.approve([staged[0]["id"]], staged=True)
        self.assertEqual([], review.pending(self.root, staged=True))

    def test_matching_staged_snapshot_reuses_working_review(self):
        self.write("locale/en/test.cfg", "Reviewed\n")
        self.approve([review.pending(self.root)[0]["id"]])
        self.git("add", "locale")
        self.assertEqual([], review.pending(self.root, staged=True))

    def test_deleted_lua_and_untracked_translations_are_reviewed(self):
        (self.root / "src/name.lua").unlink()
        self.write("locale/zz/new.cfg", "[test]\nname=Translation\n")
        self.write("src/new.lua", 'prototype["localised_description"] = description\n')
        self.write("tests/test-fixture.lua", 'item.localised_name = "Fixture"\n')
        self.assertEqual(["locale/zz/new.cfg", "src/name.lua", "src/new.lua"],
                         [item["path"] for item in review.pending(self.root)])
        self.assertIn('-item.localised_name', review.pending(self.root)[1]["diff"])

    def test_captions_tooltips_and_locale_helpers_are_reviewed(self):
        for source in ('gui.caption = value', 'gui.tooltip = value',
                       'return {"propertyrandomizer-panel.title"}'):
            with self.subTest(source=source):
                self.write("src/new.lua", source)
                self.assertEqual(["src/new.lua"], [item["path"] for item in review.pending(self.root)])

    def test_unrelated_configuration_edits_do_not_require_wording_review(self):
        before = '''local config = {}
config.planetary = config.biomes or config.resources
config.names = config.planetary
local function warn()
    return {"propertyrandomizer-warning.preview-incompatible"}
end
'''
        self.write("src/config.lua", before)
        self.git("add", ".")
        self.git("commit", "-qm", "localized warning alongside configuration")
        self.write("src/config.lua", before.replace("config.biomes or config.resources", "config.resources")
                   .replace("config.names = config.planetary", "config.names = config.planetary or config.biomes"))
        self.assertEqual([], review.pending(self.root))
        self.git("add", ".")
        self.assertEqual([], review.pending(self.root, staged=True))

    def test_unrelated_edits_inside_same_function_or_prototype_are_ignored(self):
        for before in (
            'local function run()\n local number = 1\n gui.caption = "Unchanged"\nend\n',
            'data:extend({{cost = 1, localised_name = {"", "Unchanged"}}})\n',
            'local config = {}\nconfig.cost = 1\nconfig.label = "Unchanged"\ngui.caption = config.label\n',
        ):
            with self.subTest(source=before):
                self.assertEqual(review.localized_snapshot(before), review.localized_snapshot(before.replace("= 1", "= 2")))

    def test_multiline_values_helpers_and_indirect_suppliers_are_reviewed(self):
        for before in (
            'item.localised_name = {"",\n "Original",\n}\n',
            'local text = "Original"\nitem.localised_name = text\n',
            'local function label()\n return "Original"\nend\nitem.localised_name = label()\n',
            'local function first()\n return "Original"\nend\nlocal function label()\n return first()\nend\ngui.caption = label()\n',
            'local text = "Original"\nlocal function label()\n return text\nend\ngui.caption = label()\n',
            'local config = {}\nconfig.label = "Original"\ngui.tooltip = config.label\n',
            'local parts = {}\ntable.insert(parts, "Original")\nitem.localised_description = parts\n',
            'local parts = {}\nparts[1] = "Original"\nitem.localised_description = parts\n',
            'local parts = {}\nparts["label"] = "Original"\nitem.localised_description = parts\n',
            'local helper = function() return "Original" end\ngui.caption = helper()\n',
            'local text\nlocal function prepare()\n text = "Original"\nend\nprepare()\ngui.caption = text\n',
            'local options = {label = "Original"}\nlocal function draw()\n if enabled then options.label = "Alternate" end\n gui.caption = options.label\nend\n',
        ):
            with self.subTest(source=before):
                self.assertNotEqual(review.localized_snapshot(before), review.localized_snapshot(before.replace("Original", "Revised")))

    def test_suppliers_respect_function_boundaries_and_parameter_shadowing(self):
        for before in (
            'local function other()\n local text = "Original"\n return text\nend\nlocal function draw()\n local text = "Unchanged"\n gui.caption = text\nend\n',
            'local text = "Original"\nlocal function draw(text)\n gui.caption = text\nend\n',
            'local caption = "Original"\ngui.add {caption = "Unchanged"}\n',
        ):
            with self.subTest(source=before):
                self.assertEqual(review.localized_snapshot(before), review.localized_snapshot(before.replace("Original", "Revised")))

    def test_guards_are_ignored_but_removed_wording_requires_review(self):
        before = 'if enabled then\n item["localised_description"] = {"", "Description"}\nend\n'
        snapshot = review.localized_snapshot(before)
        self.assertEqual(snapshot, review.localized_snapshot(before.replace("enabled", "other_flag")))
        self.assertNotEqual(snapshot, review.localized_snapshot(""))

    def test_four_reported_gameplay_diffs_do_not_require_wording_review(self):
        cases = {
            "src/pipeline/data-final-fixes.lua": (
                '''local biome_placement = require("placement")
for i = 1, 2 do
    local problem = "Diagnostic text for logs only"
    log(problem)
end
''',
                '''local biome_placement = require("placement")
for i = 1, 2 do
    local problem = "Diagnostic text for logs only"
    log(problem)
end
if config.planetary_biome_placement == true then
    local problem = biome_placement.prepare()
    if problem ~= nil then
        table.insert(randomization_info.warnings, localised_text.get("propertyrandomizer-warning.planetary-skipped", problem))
    end
end
'''),
            "src/randomizations/numerical/entity.lua": (
                '''randomizations.speed = function(id)
    if collector.arm_speed_base ~= nil then
        collector.arm_speed_base = 0.1
    end
    local factor = collector.arm_speed_base / old_arm_speed
    locale_utils.create_localised_description(collector, factor, id)
end
''', None),
            "src/randomizations/numerical/tile.lua": (
                '''randomize({prototype = tile, variance = "big"})
locale_utils.create_localised_description(tile, tile.walking_speed_modifier / old_value, id, {variance = "big"})
''', None),
            "src/randomizations/planetary/execute.lua": (
                '''local function message(graph)
    local after = {graph = graph, sort_info = top.sort(graph, nil, nil, {complex_contexts = true})}
    local passes, failures = check.required(before, after)
    warn(localised_text.get("propertyrandomizer-warning.planetary-skipped", failures))
end
''',
                '''local function message(graph, sort_info)
    if sort_info == nil then
        sort_info = top.sort(graph, nil, nil, {complex_contexts = true})
    end
    local after = {graph = graph, sort_info = sort_info}
    local passes, failures = check.required(before, after)
    warn(localised_text.get("propertyrandomizer-warning.planetary-skipped", failures))
end
'''),
        }
        for path, (before, _) in cases.items():
            self.write(path, before)
        self.git("add", ".")
        self.git("commit", "-qm", "gameplay code with unchanged text")
        for path, (before, after) in cases.items():
            if path.endswith("entity.lua"):
                after = before.replace("arm_speed_base ~= nil", "arm_speed_base == nil")
            elif path.endswith("tile.lua"):
                after = before.replace('"big"', '"small"')
            self.write(path, after)
        self.assertEqual([], review.pending(self.root))
        self.git("add", ".")
        self.assertEqual([], review.pending(self.root, staged=True))

    def test_dynamic_values_options_and_helper_internals_are_not_wording(self):
        for before, after in (
            ('local amount = 1\ngui.caption = {"", "Count: ", amount}\n',
             'local amount = 2\ngui.caption = {"", "Count: ", amount}\n'),
            ('local function label()\n local mode = "big"\n return "Unchanged"\nend\ngui.caption = label()\n',
             'local function label()\n local mode = "small"\n return "Unchanged"\nend\ngui.caption = label()\n'),
            ('local options = {label = "Unchanged", mode = "big"}\ngui.caption = options.label\n',
             'local options = {label = "Unchanged", mode = "small"}\ngui.caption = options.label\n'),
            ('describe(tile, {variance = "big"})\ngui.caption = "Unchanged"\n',
             'describe(tile, {variance = "small"})\ngui.caption = "Unchanged"\n'),
        ):
            with self.subTest(source=before):
                self.assertEqual(review.localized_snapshot(before), review.localized_snapshot(after))

    def test_literal_placeholder_wording_in_locale_calls_still_requires_review(self):
        before = 'warn(localised_text.get("propertyrandomizer-warning.planetary-skipped", "Original wording"))\n'
        self.assertNotEqual(review.localized_snapshot(before), review.localized_snapshot(before.replace("Original wording", "Revised wording")))

    def test_reading_existing_localized_text_does_not_define_new_wording(self):
        self.assertEqual((), review.localized_snapshot('return prototype.localised_description\n'))

    def test_all_direct_localized_field_expression_edits_require_review(self):
        for field in ("localised_name", "localised_description", "caption", "tooltip"):
            for target in ("prototype." + field, 'prototype["' + field + '"]'):
                for old, new in (
                    ('"Original"', '"Revised"'),
                    ("first_value", "second_value"),
                    ('{"key", first_value}', '{"key", second_value}'),
                    ("helper(first_value)", "helper(second_value)"),
                ):
                    with self.subTest(target=target, old=old, new=new):
                        self.assertNotEqual(review.localized_snapshot(target + " = " + old),
                                            review.localized_snapshot(target + " = " + new))
                        self.assertNotEqual(review.localized_snapshot("prototype = {" + field + " = " + old + "}"),
                                            review.localized_snapshot("prototype = {" + field + " = " + new + "}"))

    def test_every_locale_file_change_requires_review(self):
        for contents in (
            "[test]\nname=Revised\n",
            "[test]\nname=Original\n# Comment only\n",
            "[test]\nname=Original\n\n",
            "",
        ):
            with self.subTest(contents=contents):
                self.write("locale/en/test.cfg", contents)
                self.assertEqual(["locale/en/test.cfg"], [item["path"] for item in review.pending(self.root)])
                self.git("add", "locale")
                self.assertEqual(["locale/en/test.cfg"], [item["path"] for item in review.pending(self.root, staged=True)])
        (self.root / "locale/en/test.cfg").unlink()
        self.write("locale/en/empty.cfg", "")
        self.assertEqual(["locale/en/empty.cfg", "locale/en/test.cfg"],
                         [item["path"] for item in review.pending(self.root)])
        self.git("add", "locale")
        self.assertEqual(["locale/en/empty.cfg", "locale/en/test.cfg"],
                         [item["path"] for item in review.pending(self.root, staged=True)])

    def test_formatting_comments_and_movement_do_not_require_lua_review(self):
        before = 'local number = 1\nitem.localised_name = {"", "Description"}\n'
        after = '-- localised_description = "Comment only"\nitem.localised_name={ "", "Description" }\nlocal number = 1\n'
        self.assertEqual(review.localized_snapshot(before), review.localized_snapshot(after))
        self.assertEqual((), review.localized_snapshot('-- item.localised_name = "Comment only"\n'))
        self.assertNotEqual(review.localized_snapshot(before), review.localized_snapshot(before.replace("Description", "Description ")))

    def test_invalid_lua_with_localization_is_not_silently_exempted(self):
        before = 'item.localised_name = {"Original"\n'
        self.assertNotEqual(review.localized_snapshot(before), review.localized_snapshot(before.replace("Original", "Revised")))

    def test_unrelated_edits_still_invalidate_exact_file_approval(self):
        source = 'item.localised_name = "Reviewed"\nlocal number = 1\n'
        self.write("src/name.lua", source)
        first = review.pending(self.root)[0]["id"]
        self.approve([first])
        self.write("src/name.lua", source.replace("= 1", "= 2"))
        self.assertNotEqual(first, review.pending(self.root)[0]["id"])

    def test_stop_requests_review_once_then_allows_asking_the_user(self):
        self.write("locale/en/test.cfg", "Draft\n")
        payload = {"session_id": "one"}
        notice = self.hook(review.hook_stop, payload)
        self.assertEqual("block", notice["decision"])
        self.assertIn("wait for their approval", notice["reason"])
        self.assertIn("systemMessage", self.hook(review.hook_stop, {**payload, "stop_hook_active": True}))
        self.assertTrue(review.pending(self.root))
        self.write("locale/en/test.cfg", "Different draft\n")
        self.assertEqual("block", self.hook(review.hook_stop, payload)["decision"])

    def test_approval_permission_prompt_contains_the_complete_diff(self):
        self.write("locale/en/test.cfg", "[test]\nname=Read this wording\n")
        item = review.pending(self.root)[0]
        command = f'python3 "{self.root}/dev/review-player-text.py" --approve {item["id"]}'
        notice = self.hook(review.hook_pre_bash, {"tool_input": {"command": command}})["hookSpecificOutput"]
        self.assertEqual("ask", notice["permissionDecision"])
        self.assertIn(item["diff"], notice["permissionDecisionReason"])
        self.assertTrue(review.pending(self.root))  # Asking is not approving.
        for unsafe in (command + " && echo done", command + " stale", command + " >receipt"):
            with self.subTest(command=unsafe):
                notice = self.hook(review.hook_pre_bash, {"tool_input": {"command": unsafe}})
                self.assertEqual("deny", notice["hookSpecificOutput"]["permissionDecision"])

    def test_receipts_cannot_be_edited_directly_through_claude_tools(self):
        payload = {"tool_input": {"file_path": "/tmp/" + review.STATE_NAME + "/receipt.json"}}
        self.assertEqual("deny", self.hook(review.hook_pre_edit, payload)["hookSpecificOutput"]["permissionDecision"])
        payload = {"tool_input": {"command": f"echo approved > /tmp/{review.STATE_NAME}/receipt.json"}}
        self.assertEqual("deny", self.hook(review.hook_pre_bash, payload)["hookSpecificOutput"]["permissionDecision"])
        self.assertIsNone(self.hook(review.hook_pre_bash, {"tool_input": {"command": "git diff -- locale"}}))

    def test_precommit_gate_blocks_unreviewed_staged_text(self):
        self.write("locale/en/test.cfg", "Unreviewed\n")
        self.git("add", "locale")
        # The real pre-commit hook invokes this same checker against the index.
        with mock.patch.object(review.sys, "argv", ["review-player-text.py", "--staged"]), \
                mock.patch.object(review, "ROOT", self.root), \
                redirect_stdout(io.StringIO()) as output:
            self.assertEqual(1, review.main())
        self.assertIn("+Unreviewed", output.getvalue())

    def test_real_precommit_hook_runs_the_review_gate(self):
        self.write("dev/review-player-text.py", (ROOT / "dev/review-player-text.py").read_text())
        self.write("dev/style-check.py", (ROOT / "dev/style-check.py").read_text())
        self.write("locale/en/test.cfg", "Must be read before committing\n")
        self.git("add", "locale")
        result = subprocess.run(["bash", str(ROOT / "dev/git-hooks/pre-commit")], cwd=self.root,
                                capture_output=True, text=True,
                                env={**os.environ, "PATH": str(Path(sys.executable).parent) + os.pathsep + os.environ.get("PATH", "")})
        self.assertEqual(1, result.returncode, result.stdout + result.stderr)
        self.assertIn("+Must be read before committing", result.stdout)
        self.assertIn("awaiting human review", result.stdout)

    def test_first_commit_includes_already_staged_locale(self):
        fresh = self.root / "fresh"
        fresh.mkdir()
        subprocess.run(["git", "init", "-q", str(fresh)], check=True)
        (fresh / "locale/en").mkdir(parents=True)
        (fresh / "locale/en/new.cfg").write_text("Initial text\n")
        subprocess.run(["git", "add", "."], cwd=fresh, check=True)
        self.assertEqual(1, len(review.changes(fresh)))
        self.assertEqual(1, len(review.changes(fresh, staged=True)))


if __name__ == "__main__":
    unittest.main()

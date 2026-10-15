"""Architecture guard: regressions for the biome failure and future new graph runners."""
from contextlib import redirect_stdout
import importlib.util
import io
import json
from pathlib import Path
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location('architecture', ROOT / 'dev/check-progression-architecture.py')
guard = importlib.util.module_from_spec(spec)
spec.loader.exec_module(guard)


class ArchitectureTests(unittest.TestCase):
    def test_new_planetary_algorithm_is_rejected(self):
        source = 'local check = require("src/randomizations/planetary/check"); check.sort(logic)'
        self.assertTrue(guard.check({'src/randomizations/planetary/new-feature': source}, []))

    def test_handler_and_helper_cannot_build_or_sort(self):
        for owner in ['src/randomizations/unified/handlers/new-feature', 'src/prototypes/helper']:
            for module, member in [('src/logic/init', 'build'), ('src/lib/sort/context-sort', 'sort')]:
                source = f'local api = require("{module}"); local alias = api; alias.{member}()'
                self.assertTrue(guard.check({owner: source}, []))

    def test_existing_site_does_not_authorize_a_copy(self):
        source = 'local check = require("src/randomizations/planetary/check"); check.sort(logic)'
        old = 'src/randomizations/planetary/existing'
        copied = 'src/randomizations/planetary/copied'
        baseline = [(old, 'src/randomizations/planetary/check', 'sort')]
        self.assertEqual([(copied, 'src/randomizations/planetary/check', 'sort', 1)], guard.check({old: source, copied: source}, baseline))

    def test_new_call_in_existing_module_is_rejected(self):
        owner = 'src/randomizations/planetary/existing'
        source = 'local check = require("src/randomizations/planetary/check"); check.sort(logic); check.sort(logic)'
        baseline = [(owner, 'src/randomizations/planetary/check', 'sort', 1)]
        self.assertEqual([(owner, 'src/randomizations/planetary/check', 'sort', 1)], guard.check({owner: source}, baseline))

    def test_central_runner_and_context_metadata_are_allowed(self):
        source = 'local top = require("src/lib/sort/context-sort"); top.sort(graph)'
        self.assertFalse(guard.check({'src/randomizations/unified/execute': source}, []))
        source = 'local top = require("src/lib/sort/context-sort"); top.context_room(context)'
        self.assertFalse(guard.check({'src/randomizations/unified/handlers/example': source}, []))

    def test_staged_mode_checks_index_content(self):
        path = 'src/randomizations/planetary/new-feature.lua'
        source = b'local check = require("src/randomizations/planetary/check"); check.sort(logic)'
        output = io.StringIO()
        with patch.object(guard.sys, 'argv', ['guard', '--staged']), patch.object(guard.subprocess, 'check_output', side_effect=[(path + '\0').encode(), source, b'{"existing_execution_sites": []}']) as git, patch.object(guard, 'repository_sources', side_effect=AssertionError('must use index')), redirect_stdout(output):
            self.assertTrue(guard.main())
        self.assertIn('new whole-graph execution', output.getvalue())
        self.assertEqual(['git', 'show', ':' + path], git.call_args_list[1].args[0])

    def test_repository(self):
        baseline = json.loads((ROOT / 'dev/progression-architecture.json').read_text())
        self.assertEqual([], guard.check(guard.repository_sources(), baseline['existing_execution_sites']))

    def test_biome_is_a_handler_and_has_no_custom_search(self):
        source = (ROOT / 'src/randomizations/unified/handlers/biome-placement.lua').read_text()
        _, uses = guard.inspect(source)
        self.assertFalse(any(guard.execution(target, member) for target, member in uses))
        self.assertNotIn('custom_prereq_search', source)
        self.assertIn('placement.first_pass = false', source)
        runner = (ROOT / 'src/randomizations/unified/execute.lua').read_text()
        self.assertIn('["biome-placement"] = require("src/randomizations/unified/handlers/biome-placement")', runner)
        planetary = (ROOT / 'src/randomizations/planetary/execute.lua').read_text()
        self.assertNotIn('biome_placement', planetary)


if __name__ == '__main__':
    unittest.main()

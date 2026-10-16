"""Architecture regression plus self-tests for the static dependency-graph guard."""
import importlib.util
from pathlib import Path
import unittest

spec = importlib.util.spec_from_file_location("graph_boundary", Path(__file__).resolve().parents[3] / "dev/check-randomization-graph.py")
guard = importlib.util.module_from_spec(spec)
spec.loader.exec_module(guard)

ENTRY = "src/randomizations/misc/example"
STATE = "src/logic/state"


class GraphBoundaryTests(unittest.TestCase):
    def check_source(self, code, others=None, baseline=None):
        return guard.check({ENTRY: code, **(others or {})}, baseline or {})

    def test_build_and_sort_imports(self):
        for module in ["src/logic/init", "src/legacy/logic/build-graph", "src/lib/sort/top-sort", "src/lib/sort/context-sort"]:
            with self.subTest(module=module):
                self.assertTrue(self.check_source(f'local api = require("{module}")'))

    def test_aliased_import_and_function(self):
        self.assertTrue(self.check_source('local renamed = require("src/logic/init"); local alias = renamed; local build = alias.build; build()'))

    def test_helper_indirection_and_cycles(self):
        self.assertTrue(self.check_source('local h = require("src/helper"); h.run()', {
            "src/helper": 'local nested = require("src/other-helper")',
            "src/other-helper": 'local h = require("src/helper"); local sort = require("src/lib/sort/top-sort"); sort.sort({})',
        }))

    def test_direct_graph_state_access(self):
        for expression in ['s.graph', 's["graph"]', '(s).graph']:
            with self.subTest(expression=expression):
                self.assertTrue(self.check_source(f'local s = require("{STATE}"); use({expression})'))

    def test_metadata_exception_is_member_specific(self):
        baseline = {(ENTRY, STATE): {"rcat_canonical"}}
        self.assertFalse(self.check_source(f'local s = require("{STATE}"); use(s.rcat_canonical)', baseline=baseline))
        for code in ['local alias = s; use(alias.graph)', 'local build = s.build; build()', 's:build()', 'use(s[key])', 'local rcat_canonical = "graph"; use(s[rcat_canonical])', 'use(s)', 'return s', 'local box = {owner = s}']:
            with self.subTest(code=code):
                self.assertTrue(self.check_source(f'local s = require("{STATE}"); {code}', baseline=baseline))

    def test_metadata_exception_is_caller_specific(self):
        baseline = {(ENTRY, STATE): {"rcat_canonical"}}
        self.assertTrue(self.check_source('local h = require("src/helper")', {
            "src/helper": f'local s = require("{STATE}"); use(s.rcat_canonical)',
        }, baseline))

    def test_unused_metadata_alias_is_allowed(self):
        self.assertFalse(self.check_source(f'local s = require("{STATE}"); local alias = s; use(alias.rcat_canonical)', baseline={(ENTRY, STATE): {"rcat_canonical"}}))

    def test_comments_and_string_examples_are_ignored(self):
        self.assertFalse(self.check_source('''
-- require("src/logic/init").build()
--[=[ local graph = require("src/logic/state").graph ]=]
local example = [[require("src/logic/state")]]
local quoted = 'require("src/lib/sort/top-sort")'
'''))

    def test_generic_utilities_and_customizer_state(self):
        self.assertFalse(self.check_source('''
local g = require("src/lib/graph/graph-utils")
local amounts = require("src/prototypes/recipes/recipe-item-amounts")
local helper = require("src/logic/plain-helper")
g.key("item", "x")
local state = {}; state.graph = {}
''', {"src/logic/plain-helper": 'return { amount = function(x) return x.amount end }'}))

    def test_helper_in_logic_folder_is_still_followed(self):
        self.assertTrue(self.check_source('local h = require("src/logic/plain-helper")', {
            "src/logic/plain-helper": f'local s = require("{STATE}"); use(s.graph)',
        }))

    def test_exempt_infrastructure(self):
        for folder in ["graph", "unified", "planetary"]:
            with self.subTest(folder=folder):
                self.assertFalse(guard.check({f"src/randomizations/{folder}/example": f'local s = require("{STATE}"); use(s.graph)'}))

    def test_exempt_infrastructure_cannot_be_used_as_helper(self):
        for folder in ["graph", "unified", "planetary"]:
            with self.subTest(folder=folder):
                self.assertTrue(self.check_source(f'local h = require("src/randomizations/{folder}/execute")'))

    def test_rebuild_is_not_blanket_exempt(self):
        self.assertTrue(guard.check({"src/randomizations/rebuild/new-pass": f'local s = require("{STATE}"); use(s.graph)'}))

    def test_existing_rebuild_exceptions_remain_narrow(self):
        owner = "src/randomizations/rebuild/needs"
        self.assertFalse(guard.check({owner: f'local s = require("{STATE}"); use(s.type_info)'}))
        self.assertTrue(guard.check({owner: f'local s = require("{STATE}"); use(s.graph)'}))
        self.assertTrue(guard.check({owner: f'local s = require("{STATE}"); use(s)'}))
        self.assertTrue(guard.check({"src/randomizations/rebuild/new-pass": f'local s = require("{STATE}"); use(s.type_info)'}))

    def test_registration_root_is_not_a_pass(self):
        self.assertFalse(guard.check({"src/randomizations/init": 'require("src/randomizations/unified/execute")'}))

    def test_parse_failure_cannot_silently_pass(self):
        self.assertTrue(self.check_source('local broken = function('))

    def test_repository_boundary(self):
        findings = guard.check(guard.repository_sources())
        self.assertEqual([], findings, "New graph access outside graph/unified/planetary: " + repr(findings))


if __name__ == "__main__":
    unittest.main()

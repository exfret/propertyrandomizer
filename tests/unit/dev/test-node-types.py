#!/usr/bin/env python3
"""Every node type the dependency graphs can contain was approved by the user (dev/node-types.py).

A node type nobody approved puts its nodes into every graph the randomizer builds and sorts.
On 2026-10-12 a module-effects builder did that and doubled the user's load time.
"""
from contextlib import redirect_stderr, redirect_stdout
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location("node_types", ROOT / "dev/node-types.py")
checker = importlib.util.module_from_spec(spec)
spec.loader.exec_module(checker)

GRAPH_UTILS = '''
local gutils = {}
gutils.add_node = function(graph, node_type, node_name, extra)
    local node = {object_type = "node", type = node_type, name = node_name, pre = {}, dep = {}, num_pre = 0}
    graph.nodes[gutils.key(node_type, node_name)] = node
    return node
end
return gutils
'''

BUILDER = '''
local gutils = require("src/lib/graph/graph-utils")
local helpers = {}
function helpers.add_node(node_type, op, context, node_name, extra)
    curr = gutils.add_node(graph, node_type, node_name, extra)
end
return helpers
'''

# The builder from the 2026-10-12 incident, cut down to how it created nodes
MODULE_EFFECTS_BUILDER = '''
local builder = require("src/logic/builders/builder")
local modules = {}
function modules.build(lu)
    builder.add_node("module-quality-unlock", "OR", nil, "")
    for _, field in pairs(catalog.fields) do
        builder.add_node("module-benefit", "OR", nil, field, {mechanic = true})
    end
    for _, name in pairs(names) do
        builder.add_node("module-use", "AND", nil, name)
        builder.add_node("module-consumers", "OR", nil, name)
        builder.add_node("module-consumer", "AND", nil, name)
        builder.add_node("module-work", "OR", nil, name)
        builder.add_node("module-operation", "AND", nil, name)
    end
end
return modules
'''


def scan(extra):
    sources = {"src/lib/graph/graph-utils.lua": GRAPH_UTILS, "src/logic/builders/builder.lua": BUILDER, **extra}
    return checker.scan({path: source.encode() for path, source in sources.items()})


def found(sites):
    return sorted({(site.kind, site.value) for site in sites})


def run_hook(hook, payload):
    output = io.StringIO()
    with redirect_stdout(output):
        hook(payload)
    return json.loads(output.getvalue()) if output.getvalue() else None


class ApprovedNodeTypesTests(unittest.TestCase):
    def test_every_node_type_in_src_is_approved(self):
        sites = checker.scan(checker.working_tree_sources(str(ROOT)))
        pending = checker.unapproved(sites, checker.load_registry(str(ROOT)), checker.moved_from(str(ROOT)))
        if len(pending) > 0:
            self.fail("Unapproved dependency graph node types:\n" + "\n".join(checker.describe(pending)) + "\n" + checker.INSTRUCTIONS)

    def test_the_module_effects_builder_would_have_been_caught(self):
        sites = scan({"src/logic/builders/module-effects.lua": MODULE_EFFECTS_BUILDER})
        pending = checker.unapproved(sites, checker.load_registry(str(ROOT)), {})
        self.assertEqual(["module-benefit", "module-consumer", "module-consumers", "module-operation", "module-quality-unlock", "module-use", "module-work"],
                         checker.pending_names(pending))


class ScanTests(unittest.TestCase):
    def test_wrappers_and_aliases_are_followed_to_each_literal(self):
        sites = scan({
            "src/logic/builders/abstract.lua": '''
                local builder = require("src/logic/builders/builder")
                local add_node = builder.add_node
                add_node("item", "OR")
                builder.add_node("recipe", "AND", nil, "iron-plate")
            ''',
            "src/logic/builders/logic-group.lua": '''
                local gutils = require("src/lib/graph/graph-utils")
                local function add_node(node_type, op, context, node_name)
                    curr = gutils.add_node(group_graph, node_type, node_name or "")
                end
                add_node("group", "OR")
            ''',
            "src/lib/sort/staged-sort.lua": '''
                local graph_utils = require("src/lib/graph/graph-utils")
                local G = graph_utils
                local OR_TYPE = "head"
                local function add_connector(graph, node_type, name)
                    return G.add_node(graph, node_type, name)
                end
                add_connector(graph, OR_TYPE, "gate")
            ''',
        })
        self.assertEqual([("type", "group"), ("type", "head"), ("type", "item"), ("type", "recipe")], found(sites))

    def test_graph_utils_takes_the_type_second_and_constants_must_be_constant(self):
        sites = scan({"src/randomizations/unified/handlers/example.lua": '''
            local gutils = require("src/lib/graph/graph-utils")
            local SINK_TYPE = "example-sink"
            local SLOT_TYPE = "example-slot"
            gutils.add_node(graph, SINK_TYPE, "sink")
            gutils.add_node(graph, SLOT_TYPE, "slot")
            SLOT_TYPE = "other-slot"
        '''})
        self.assertEqual([("dynamic", "SLOT_TYPE"), ("type", "example-sink")], found(sites))

    def test_types_the_checker_cannot_read_fail_closed(self):
        sites = scan({"src/randomizations/unified/example.lua": '''
            local gutils = require("src/lib/graph/graph-utils")
            local handler = get_handler()
            for _, node in pairs(graph.nodes) do
                gutils.add_node(graph, node.type .. "-copy", node.name)
            end
            for _, node_type in pairs({"listed-a", "listed-b"}) do
                gutils.add_node(graph, node_type, "x")
            end
            each(function(callback_type) gutils.add_node(graph, callback_type, "y") end)
            handler.add_node("hidden", "OR")
        '''})
        self.assertEqual([("dynamic", "callback_type"), ("dynamic", "node.type .. \"-copy\""), ("dynamic", "node_type"), ("dynamic", "unresolved call handler.add_node")], found(sites))

    def test_node_tables_built_without_a_helper_count(self):
        sites = scan({
            "src/legacy/logic/build-graph.lua": '''
                local function add_to_graph(node_type, node_name, prereqs)
                    graph[key(node_type, node_name)] = {type = node_type, name = node_name, prereqs = prereqs}
                end
                add_to_graph("technology", "automation", {})
            ''',
            "src/legacy/logic/build-graph-compat.lua": '''
                graph[build_graph.key("mining-drill", "canonical")] = {type = "mining-drill", name = "canonical", prereqs = {}}
            ''',
        })
        self.assertEqual([("type", "mining-drill"), ("type", "technology")], found(sites))

    def test_comments_strings_and_other_tables_do_not_count(self):
        sites = scan({"src/prototypes/example.lua": '''
            local gutils = require("src/lib/graph/graph-utils")
            -- gutils.add_node(graph, "commented-out", "x")
            local text = [[gutils.add_node(graph, "in-a-string", "x")]]
            data:extend({{type = "recipe", name = "example", ingredients = {}}})
            local PLAIN_NODE_FIELDS = {type = true, name = true, pre = true, dep = true}
            local panel = gui.add({type = "flow", name = "row"})
        '''})
        self.assertEqual([], found(sites))

    def test_unparsable_files_fail_closed(self):
        sites = scan({"src/broken.lua": 'gutils.add_node(graph, "x"'})
        self.assertTrue(any(site.path == "src/broken.lua" and "syntax errors" in site.value for site in sites))

    def test_copies_without_their_own_git_checkout_are_walked(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            (root / "src/logic").mkdir(parents=True)
            (root / "src/logic/example.lua").write_text('builder.add_node("x", "OR")\n')
            (root / "src/notes.txt").write_text("not Lua\n")
            self.assertEqual({"src/logic/example.lua": b'builder.add_node("x", "OR")\n'}, checker.working_tree_sources(str(root)))

    def test_staged_sources_come_from_the_index(self):
        # Under a git hook, GIT_DIR and GIT_INDEX_FILE point at the real repository; the fixture's git commands must not follow them
        fixture_environment = {key: value for key, value in os.environ.items() if not key.startswith("GIT_")}
        with tempfile.TemporaryDirectory() as folder, mock.patch.dict(os.environ, fixture_environment, clear=True):
            root = Path(folder)
            subprocess.run(["git", "init", "-q"], cwd=root, check=True)
            (root / "src/cost/material-costs").mkdir(parents=True)
            (root / "src/a.lua").write_text("staged\n")
            (root / "src/b.lua").write_text("also staged, and longer\n")
            (root / "src/cost/material-costs/table.lua").write_text("generated\n")
            subprocess.run(["git", "add", "src"], cwd=root, check=True)
            (root / "src/a.lua").write_text("changed after staging\n")
            self.assertEqual({"src/a.lua": b"staged\n", "src/b.lua": b"also staged, and longer\n"}, checker.staged_sources(str(root)))


class ApprovalTests(unittest.TestCase):
    SOURCES = {
        "src/lib/graph/graph-utils.lua": GRAPH_UTILS.encode(),
        "src/logic/builders/builder.lua": BUILDER.encode(),
        "src/logic/builders/example.lua": b'local builder = require("src/logic/builders/builder")\nbuilder.add_node("new-type", "OR")\n',
    }

    def setUp(self):
        self.folder = tempfile.TemporaryDirectory()
        self.root = self.folder.name
        Path(self.root, "dev").mkdir()
        Path(self.root, checker.REGISTRY).write_text(json.dumps({"types": {"existing": {"approved": "baseline"}}, "dynamic_sites": {}}))
        patches = [
            mock.patch.object(checker, "working_tree_sources", return_value=self.SOURCES),
            mock.patch.object(checker, "REPO", self.root),
            mock.patch.object(checker, "STATE_DIR", str(Path(self.root, "state"))),
        ]
        for patch in patches:
            patch.start()
            self.addCleanup(patch.stop)

    def tearDown(self):
        self.folder.cleanup()

    def test_approve_records_the_type_and_note(self):
        with redirect_stdout(io.StringIO()):
            self.assertEqual(0, checker.approve(["--note", "What it models", "new-type"], root=self.root))
        registry = checker.load_registry(self.root)
        self.assertEqual("What it models", registry["types"]["new-type"]["note"])
        self.assertIn("existing", registry["types"])

    def test_approve_refuses_names_nothing_creates(self):
        with redirect_stderr(io.StringIO()):
            self.assertEqual(1, checker.approve(["made-up"], root=self.root))
        self.assertNotIn("made-up", checker.load_registry(self.root)["types"])

    def test_claude_gets_a_permission_prompt_for_approvals(self):
        decision = run_hook(checker.hook_pre_bash, {"tool_input": {"command": "cd x && python3 dev/node-types.py --approve --note 'Rooms for X' new-type"}})["hookSpecificOutput"]
        self.assertEqual("ask", decision["permissionDecision"])
        self.assertIn("new-type: src/logic/builders/example.lua:2", decision["permissionDecisionReason"])
        self.assertIn("Rooms for X", decision["permissionDecisionReason"])
        decision = run_hook(checker.hook_pre_bash, {"tool_input": {"command": "python3 dev/node-types.py --approve made-up"}})["hookSpecificOutput"]
        self.assertEqual("deny", decision["permissionDecision"])

    def test_claude_cannot_write_the_registry_directly(self):
        for command in ("sed -i '' 's/a/b/' dev/node-types.json", "python3 -c \"open('dev/node-types.json', 'w')\"", "cp /tmp/x dev/node-types.json"):
            with self.subTest(command=command):
                decision = run_hook(checker.hook_pre_bash, {"tool_input": {"command": command}})["hookSpecificOutput"]
                self.assertEqual("deny", decision["permissionDecision"])
        self.assertIsNone(run_hook(checker.hook_pre_bash, {"tool_input": {"command": "git diff dev/node-types.json"}}))
        decision = run_hook(checker.hook_pre_edit, {"tool_input": {"file_path": str(Path(self.root, checker.REGISTRY))}})["hookSpecificOutput"]
        self.assertEqual("deny", decision["permissionDecision"])
        self.assertIsNone(run_hook(checker.hook_pre_edit, {"tool_input": {"file_path": str(Path(self.root, "dev/other.json"))}}))

    def test_stop_hook_blocks_each_session_once_then_tells_the_user(self):
        with redirect_stderr(io.StringIO()) as message:
            self.assertEqual(2, checker.hook_stop({"session_id": "first"}))
        self.assertIn("node type new-type", message.getvalue())
        notice = run_hook(checker.hook_stop, {"session_id": "first", "stop_hook_active": True})
        self.assertIn("--approve new-type", notice["systemMessage"])
        # Later turns of the same session aren't blocked again for it, but another session is told once
        self.assertEqual(0, checker.hook_stop({"session_id": "first"}))
        with redirect_stderr(io.StringIO()):
            self.assertEqual(2, checker.hook_stop({"session_id": "second"}))

    def test_a_moved_files_dynamic_site_keeps_its_approval(self):
        site = checker.Site("src/new/place.lua", 3, "dynamic", "node.type", "gutils.add_node")
        registry = {"types": {}, "dynamic_sites": {checker.site_id("old/place.lua", "node.type"): {"approved": "earlier"}}}
        self.assertTrue(checker.is_approved(site, registry, {"src/new/place.lua": "old/place.lua"}))
        self.assertFalse(checker.is_approved(site, registry, {}))


if __name__ == "__main__":
    unittest.main()

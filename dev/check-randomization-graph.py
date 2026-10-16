#!/usr/bin/env python3
"""Guard ordinary randomizations and their helpers against dependency-graph access.

Run directly with python3, or through test-randomization-graph.py in the normal
unit suite. This is a conservative static import/member check, not a Lua runtime
or whole-program call graph. It follows literal requires and local aliases;
dynamic requires are outside its scope (require placement has its own checker).
"""
import importlib.util
import os
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent
if __name__ == "__main__" and any(importlib.util.find_spec(name) is None for name in ("tree_sitter", "tree_sitter_lua")):
    python = ROOT / ".venv/release/bin/python"
    if python.is_file() and str(python) != sys.executable:
        os.execv(str(python), [str(python), str(Path(__file__).resolve()), *sys.argv[1:]])
spec = importlib.util.spec_from_file_location("style_check", ROOT / "dev/style-check.py")
style = importlib.util.module_from_spec(spec)
spec.loader.exec_module(style)

# Protect the graph owners, builders/analyses and dependency sort entry points.
# Other modules are followed transitively, not forbidden by their folder name:
# generic graph keys, prototype amounts, and customization's state.graph are OK.
GRAPH_MODULES = {
    "src/logic/init", "src/logic/state",
    "src/logic/builders/builder", "src/logic/builders/graph-setup",
    "src/logic/builders/abstract", "src/logic/builders/concrete",
    "src/logic/builders/bootstrap", "src/logic/builders/witness-recipes",
    "src/logic/builders/acquisition", "src/logic/analysis/unlock-contraction",
    "src/logic/analysis/analysis", "src/logic/analysis/blockify",
    "src/logic/analysis/reductions", "src/logic/analysis/reduction-check",
    "src/legacy/logic/build-graph", "src/legacy/logic/build-graph-compat",
    "src/legacy/logic/top-sort", "src/legacy/logic/path",
    *(f"src/lib/sort/{name}" for name in (
        "top-sort", "context-sort", "block-sort", "staged-sort", "consistent-sort")),
}
GRAPH_FOLDERS = ("src/randomizations/graph/", "src/randomizations/unified/", "src/randomizations/planetary/")

# Existing graph execution debt; do not expand this to a whole-file exception.
BASELINE = {
    ("src/randomizations/misc/capsule-actions", "src/legacy/logic/build-graph"): {"graph"},
    ("src/randomizations/misc/capsule-actions", "src/legacy/logic/top-sort"): {"sort"},
    # Shared lookup metadata: none of these accesses builds/sorts a graph.
    ("src/logic/logic-utils", "src/logic/state"): {"rcat_canonical"},
    ("src/prototypes/lookup/3-compound", "src/logic/analysis/reductions"): {"enabled"},
    ("src/prototypes/lookup/2-simple/entity-create", "src/logic/builders/acquisition"): {"read_spawn_definition", "spawn_class"},
    # Existing rebuild infrastructure is outside the exempt folders, so keep
    # its graph accesses explicit too. New callers/members still fail.
    ("src/randomizations/rebuild/init", "src/logic/builders/witness-recipes"): {"extend", "in_room", "of", "research"},
    ("src/randomizations/rebuild/init", "src/logic/analysis/unlock-contraction"): {"is_unlock_edge"},
    ("src/randomizations/rebuild/rebuild-check", "src/logic/analysis/unlock-contraction"): {"tech_edges", "unlocked_recipe"},
    ("src/randomizations/rebuild/starting-recipes", "src/logic/builders/bootstrap"): {"justifications"},
    ("src/randomizations/rebuild/init", "src/lib/sort/context-sort"): {"ISOLATABILITY", "context_home", "context_mask", "context_name", "context_room", "discovered_rooms", "edge_source_contexts", "has_ability", "sort", "watched_needed"},
    ("src/randomizations/rebuild/init", "src/logic/init"): {"build", "graph"},
    ("src/randomizations/rebuild/rebuild-check", "src/lib/sort/context-sort"): {"context_home", "discovered_rooms", "edge_source_contexts", "path", "pebble_order", "room_discoverers", "sort"},
    ("src/randomizations/rebuild/rebuild-check", "src/logic/init"): {"build", "graph"},
    ("src/randomizations/rebuild/rebuild-unlocks", "src/lib/sort/context-sort"): {"path"},
    ("src/randomizations/rebuild/starting-recipes", "src/lib/sort/context-sort"): {"ISOLATABILITY", "context_home", "context_mask", "context_room", "has_ability", "path"},
    # The timeline rebuild landed in c82d230 before this guard. These exact
    # caller/member pairs are existing accesses, not folder-wide exemptions.
    ("src/randomizations/rebuild/needs", "src/lib/sort/context-sort"): {"context_room", "discovery_candidates", "path"},
    ("src/randomizations/rebuild/needs", "src/logic/builders/witness-recipes"): {"expansions_for", "tie_rank"},
    ("src/randomizations/rebuild/needs", "src/logic/state"): {"type_info"},
    ("src/randomizations/rebuild/timeline", "src/lib/sort/context-sort"): {"context_name", "edge_source_contexts", "room_discoverers"},
    ("src/randomizations/rebuild/timeline", "src/logic/analysis/unlock-contraction"): {"import"},
    ("src/randomizations/rebuild/timeline", "src/logic/state"): {"type_info"},
    ("src/randomizations/rebuild/tree", "src/lib/sort/context-sort"): {"context_home", "context_room", "sort"},
    ("src/randomizations/rebuild/tree", "src/logic/analysis/unlock-contraction"): {"is_unlock_edge"},
    ("src/randomizations/rebuild/tree", "src/logic/init"): {"build", "graph"},
    ("src/randomizations/rebuild/tree", "src/randomizations/unified/skeleton/check"): {"run"},
}


def entrypoint(module):
    # init only registers passes; it is not itself an ordinary randomization.
    return (module.startswith("src/randomizations/") and module != "src/randomizations/init"
            and not module.startswith(GRAPH_FOLDERS))


def walk(node):
    yield node
    for child in node.named_children:
        yield from walk(child)


def inspect(source):
    tree = style.PARSER.parse(source.encode())
    if tree.root_node.has_error:
        raise ValueError("Lua parse error")
    nodes = list(walk(tree.root_node))
    aliases = {}

    def text(node):
        return node.text.decode() if node is not None else ""

    def resolve(node):
        if node is None:
            return None
        if node.type == "identifier":
            return aliases.get(text(node))
        if node.type == "function_call" and text(node.child_by_field_name("name")) == "require":
            args = node.child_by_field_name("arguments")
            if args and args.named_children and args.named_children[0].type == "string":
                contents = args.named_children[0].child_by_field_name("content")
                return (text(contents).replace(".", "/"), ())
        if node.type in {"dot_index_expression", "bracket_index_expression", "method_index_expression"}:
            base = resolve(node.child_by_field_name("table"))
            field = node.child_by_field_name("field") or node.named_children[-1]
            name = text(field.child_by_field_name("content")) if field.type == "string" else text(field)
            if node.type == "bracket_index_expression" and field.type != "string":
                name = "<dynamic member>"
            if base:
                return (base[0], base[1] + (name,))
        if node.type == "parenthesized_expression" and node.named_children:
            return resolve(node.named_children[0])
        return None

    # Fixed point handles renamed module imports and aliases of functions/state.
    for _ in range(len(nodes) + 1):
        previous = aliases.copy()
        for node in nodes:
            if node.type == "assignment_statement" and len(node.named_children) >= 2:
                names, values = node.named_children[:2]
                for name, value in zip(names.named_children, values.named_children):
                    resolved = resolve(value)
                    if name.type == "identifier" and resolved:
                        aliases[text(name)] = resolved
        if aliases == previous:
            break
    imports, uses = set(), set()
    for node in nodes:
        resolved = resolve(node)
        if resolved:
            module, members = resolved
            imports.add(module)
            if members:
                uses.add((module, members[0]))
            elif node.type == "identifier":
                parent = node.parent
                # A metadata exception cannot pass/return the whole graph owner.
                indexing = parent.type in {"dot_index_expression", "bracket_index_expression", "method_index_expression"}
                assignment = parent.type == "variable_list" or (parent.type == "expression_list" and parent.parent.type == "assignment_statement")
                if not indexing and not assignment:
                    uses.add((module, "<module escape>"))
    return imports, uses


def check(sources, baseline=BASELINE):
    pending = [module for module in sources if entrypoint(module)]
    visited, findings = set(), set()
    while pending:
        owner = pending.pop()
        if owner in visited or owner not in sources:
            continue
        visited.add(owner)
        try:
            imports, uses = inspect(sources[owner])
        except ValueError as error:
            findings.add((owner, "<parse>", str(error)))
            continue
        for target in imports:
            allowed = baseline.get((owner, target))
            if target in GRAPH_MODULES or target.startswith(GRAPH_FOLDERS) or allowed is not None:
                members = {member for module, member in uses if module == target}
                if allowed is None or members - allowed:
                    findings.add((owner, target, ", ".join(sorted(members - (allowed or set()))) or "import"))
            else:
                pending.append(target)
    return sorted(findings)


def repository_sources(root=ROOT):
    return {path.relative_to(root).with_suffix("").as_posix(): path.read_text() for path in (root / "src").rglob("*.lua")}


if __name__ == "__main__":
    findings = check(repository_sources())
    for owner, target, member in findings:
        print(f"{owner}: dependency-graph access via {target}: {member}")
    print(f"Graph boundary: {len(findings)} new violation(s). Existing capsule-actions and rebuild accesses are documented in BASELINE.")
    sys.exit(bool(findings))

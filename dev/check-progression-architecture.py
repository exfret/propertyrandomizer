#!/usr/bin/env python3
"""Reject new whole-graph execution outside the established pipeline/runner.

Existing call sites are recorded as migration debt in progression-architecture.json.
Changing that baseline requires explicit user approval, as described in CLAUDE.md.
The inspector uses the existing Lua parser to resolve literal imports and local aliases. Scanning
all src helpers catches an indirect call even when its randomizer imports only
a harmless-looking helper. This does not replace review of algorithm/design.
"""
import argparse
from collections import Counter
import importlib.util
import json
import os
from pathlib import Path
import sys
import subprocess

ROOT = Path(__file__).resolve().parent.parent
if __name__ == "__main__" and any(importlib.util.find_spec(name) is None for name in ("tree_sitter", "tree_sitter_lua")):
    python = ROOT / ".venv/release/bin/python"
    if python.is_file() and str(python) != sys.executable:
        os.execv(str(python), [str(python), str(Path(__file__).resolve()), *sys.argv[1:]])
spec = importlib.util.spec_from_file_location("style_check", ROOT / "dev/style-check.py")
style = importlib.util.module_from_spec(spec)
spec.loader.exec_module(style)

# These are the owners of whole-game execution, not feature modules.
RUNNERS = {
    "src/pipeline/data-final-fixes",
    "src/randomizations/unified/execute",
}


def execution(target, member):
    if target in {"src/logic/init", "src/legacy/logic/build-graph"}:
        return member in {"build", "<dynamic member>", "<module escape>"}
    if target.startswith("src/lib/sort/") or target == "src/legacy/logic/top-sort":
        return member in {"sort", "<dynamic member>", "<module escape>"}
    if target == "src/randomizations/planetary/check":
        return member in {"sort", "<dynamic member>", "<module escape>"}
    if target in {"src/randomizations/unified/execute", "src/randomizations/unified/first-pass", "src/randomizations/planetary/execute"}:
        return member in {"execute", "run_pending", "<dynamic member>", "<module escape>"}
    return False



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
    imports, uses = set(), []
    for node in nodes:
        resolved = resolve(node)
        if resolved:
            module, members = resolved
            imports.add(module)
            if members:
                uses.append((module, members[0]))
            elif node.type == "identifier":
                parent = node.parent
                # A metadata exception cannot pass/return the whole graph owner.
                indexing = parent.type in {"dot_index_expression", "bracket_index_expression", "method_index_expression"}
                assignment = parent.type == "variable_list" or (parent.type == "expression_list" and parent.parent.type == "assignment_statement")
                if not indexing and not assignment:
                    uses.append((module, "<module escape>"))
    return imports, uses



def repository_sources():
    return {path.relative_to(ROOT).with_suffix("").as_posix(): path.read_text() for path in (ROOT / "src").rglob("*.lua")}

def sites(sources):
    result = Counter()
    for owner, source in sources.items():
        if owner in RUNNERS:
            continue
        _, uses = inspect(source)
        for target, member in uses:
            if execution(target, member):
                result[(owner, target, member)] += 1
    return result


def check(sources, baseline):
    allowed = {tuple(site[:3]): site[3] if len(site) > 3 else 1 for site in baseline}
    return sorted((*site, count - allowed.get(site, 0)) for site, count in sites(sources).items() if count > allowed.get(site, 0))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--staged", action="store_true", help="check staged source changes and the staged baseline")
    args = parser.parse_args()
    if args.staged:
        paths = subprocess.check_output(["git", "diff", "--cached", "--name-only", "--diff-filter=ACMR", "-z", "--", "src"], cwd=ROOT).decode().split("\0")
        sources = {Path(path).with_suffix("").as_posix(): subprocess.check_output(["git", "show", ":" + path], cwd=ROOT).decode()
                   for path in paths if path.endswith(".lua")}
        baseline_text = subprocess.check_output(["git", "show", ":dev/progression-architecture.json"], cwd=ROOT).decode()
    else:
        sources = repository_sources()
        baseline_text = (ROOT / "dev/progression-architecture.json").read_text()
    baseline = json.loads(baseline_text)
    findings = check(sources, baseline["existing_execution_sites"])
    for owner, target, member, additional in findings:
        print(f"{owner}: {additional} new whole-graph execution use(s) via {target}.{member}; use the unified handler/promotion path")
    print(f"Progression architecture: {len(findings)} new execution site(s)")
    return bool(findings)


if __name__ == "__main__":
    sys.exit(main())

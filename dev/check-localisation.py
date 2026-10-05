#!/usr/bin/env python3
"""Reject literal player-facing Lua text and missing mod-owned English locale keys.

Run from the mod root. --staged checks Git's index for the pre-commit hook.
Dynamic captions are covered by the GUI regression tests, not data-flow inference.
"""
import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parent.parent
try:
    from tree_sitter import Language, Parser
    import tree_sitter_lua
except ImportError:
    python = ROOT / ".venv/release/bin/python"
    if python.is_file() and str(python) != sys.executable:
        os.execv(str(python), [str(python), *sys.argv])
    raise

PARSER = Parser(Language(tree_sitter_lua.language()))
TEXT_FIELDS = {"caption", "tooltip", "localised_name", "localised_description"}


def walk(node):
    yield node
    for child in node.named_children:
        yield from walk(child)


def literal(node):
    if node is None or node.type != "string":
        return None
    raw = node.text.decode()
    if raw.startswith('"'):
        try:
            return json.loads(raw)
        except ValueError:
            pass
    if raw.startswith("["):
        return re.sub(r"^\[=*\[|\]=*\]$", "", raw)
    return raw[1:-1].replace(r"\n", "\n").replace(r"\t", "\t")


def field_name(node):
    if node is None:
        return None
    if node.type == "identifier":
        return node.text.decode()
    if node.type in ("dot_index_expression", "method_index_expression"):
        return field_name(node.child_by_field_name("field") or node.child_by_field_name("method"))
    if node.type == "bracket_index_expression":
        return literal(node.child_by_field_name("field"))
    return literal(node)


def formatting(value):
    # Rich-text tags, whitespace, quantities and punctuation aren't translated prose.
    stripped = re.sub(r"\[[^]]*\]", "", value)
    stripped = re.sub(r"\[(?:/?color|/?font|img|entity|item|fluid|recipe|technology|tile|space-location)=?$", "", stripped)
    return not any(character.isalpha() for character in stripped)


def catalogue(files):
    keys, errors = {}, []
    for path, source in files.items():
        if not path.startswith("locale/en/") or not path.endswith(".cfg"):
            continue
        section = ""
        for row, line in enumerate(source.splitlines(), 1):
            if line.startswith("[") and line.endswith("]"):
                section = line[1:-1]
            elif "=" in line and not line.startswith(("#", ";")):
                key, value = line.split("=", 1)
                key = section + "." + key
                if key in keys:
                    errors.append(f"{path}:{row}: duplicate English locale key {key}")
                keys[key] = value
    return keys, errors


def check_source(source, path, keys):
    tree = PARSER.parse(source.encode())
    errors = []
    if tree.root_node.has_error:
        return [f"{path}: invalid Lua syntax"]

    def report(node, message):
        errors.append(f"{path}:{node.start_point.row + 1}: {message}")

    def check_items(node):
        if node is not None and node.type == "table_constructor":
            for field in node.named_children:
                if field.type == "field":
                    check_text(field.child_by_field_name("value"))

    def check_text(node):
        if node is None:
            return
        value = literal(node)
        if value is not None:
            if not formatting(value):
                report(node, "unlocalized player-facing literal " + repr(value))
        elif node.type == "table_constructor":
            values = [child.child_by_field_name("value") for child in node.named_children if child.type == "field"]
            if values and literal(values[0]) == "":
                for part in values[1:]:
                    check_text(part)
            elif values and literal(values[0]) == "?":
                for part in values[1:]:
                    # A literal fallback may be a technical identifier; translated branches are checked.
                    if part.type != "string":
                        check_text(part)
        elif node.type == "function_call":
            function = node.child_by_field_name("name")
            arguments = node.child_by_field_name("arguments")
            args = arguments.named_children if arguments is not None else []
            call = function.text.decode() if function is not None else ""
            if call.startswith("string.") or call == "tostring":
                for argument in args:
                    check_text(argument)
            elif call == "table.concat" and args:
                check_items(args[0])
                for argument in args[1:]:
                    check_text(argument)
        elif node.type in ("binary_expression", "parenthesized_expression", "unary_expression"):
            for child in node.named_children:
                check_text(child)

    for node in walk(tree.root_node):
        if node.type == "field":
            name = field_name(node.child_by_field_name("name"))
            if name in TEXT_FIELDS:
                check_text(node.child_by_field_name("value"))
            elif name == "items":
                # Only GUI constructors: prototype inventories also have fields called items.
                ancestor = node.parent
                while ancestor is not None and ancestor.type != "function_call":
                    ancestor = ancestor.parent
                if ancestor is not None and field_name(ancestor.child_by_field_name("name")) == "add":
                    value = node.child_by_field_name("value")
                    if value.type == "table_constructor":
                        for item in value.named_children:
                            if item.type == "field":
                                check_text(item.child_by_field_name("value"))
        elif node.type == "assignment_statement":
            variables = next((c for c in node.named_children if c.type == "variable_list"), None)
            values = next((c for c in node.named_children if c.type == "expression_list"), None)
            if variables is not None and values is not None:
                for variable, value in zip(variables.named_children, values.named_children):
                    if variable.type != "identifier" and field_name(variable) in TEXT_FIELDS:
                        check_text(value)
                    elif variable.type != "identifier" and field_name(variable) == "items":
                        check_items(value)
        elif node.type == "function_call":
            function = node.child_by_field_name("name")
            arguments = node.child_by_field_name("arguments")
            args = arguments.named_children if arguments is not None else []
            name = field_name(function)
            if name == "print" and function.type != "identifier" and args:
                check_text(args[0])
            elif name == "label" and len(args) > 1:
                check_text(args[1])
            if path == "scripts/customizer.lua" and name == "text" and args:
                key = literal(args[0])
                if key is not None and "propertyrandomizer-customizer." + key not in keys:
                    report(args[0], "missing English locale key propertyrandomizer-customizer." + key)
        elif node.type == "string":
            key = literal(node)
            if key is not None and re.match(r"propertyrandomizer-[^.]+\..+", key):
                # Constructed key prefixes need metadata/GUI coverage rather than literal lookup.
                if node.parent.type == "binary_expression":
                    continue
                if key not in keys:
                    report(node, "missing English locale key " + key)
    return sorted(set(errors))


def active_lua(path):
    parts = Path(path).parts
    return path.endswith(".lua") and not any(
        part in {"dev", "tests", "unused", "old-logic"} or part.startswith("test-")
        for part in parts
    ) and not path.startswith(("lib/cost/recipe-randomizations/", "lib/cost/material-costs", "lib/cost/science-flows/"))


def read_files(root, staged=False):
    if staged:
        names = subprocess.check_output(["git", "ls-files", "--cached", "-z"], cwd=root).decode().split("\0")
        return {
            name: subprocess.check_output(["git", "show", ":" + name], cwd=root).decode()
            for name in names if active_lua(name) or name.startswith("locale/en/") and name.endswith(".cfg")
        }
    files = {}
    for directory in ("lib", "scripts", "randomizations", "locale/en"):
        for path in (root / directory).rglob("*"):
            relative = path.relative_to(root).as_posix()
            if path.is_file() and (active_lua(relative) or relative.endswith(".cfg")):
                files[relative] = path.read_text()
    for path in root.glob("*.lua"):
        files[path.name] = path.read_text()
    return files


def audit(files):
    keys, errors = catalogue(files)
    for path, source in files.items():
        if active_lua(path):
            errors.extend(check_source(source, path, keys))
    return sorted(errors)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--staged", action="store_true")
    parser.add_argument("--root", type=Path, default=ROOT, help="audit a snapshot or other mod folder")
    args = parser.parse_args()
    errors = audit(read_files(args.root, args.staged))
    for error in errors:
        print(error)
    print(f"localisation: {len(errors)} error(s)")
    return bool(errors)


if __name__ == "__main__":
    sys.exit(main())

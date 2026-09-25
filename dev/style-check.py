#!/usr/bin/env python3
# Lua style checker for this mod
# Only lines changed relative to git are checked, so old code gets cleaned up as it's touched
#
# Errors block (agent hook / commit); warnings are shown but it's up to whoever's editing to decide
#
# Usage:
#   dev/style-check.py                 check uncommitted changes (vs HEAD)
#   dev/style-check.py --staged        check staged changes (pre-commit)
#   dev/style-check.py --all FILE...   check every line of the given files
#   dev/style-check.py --hook post-edit|stop    Claude Code hook mode (reads hook JSON on stdin)

import importlib.metadata
import json
import os
import re
import subprocess
import sys

import tree_sitter_lua
from tree_sitter import Language, Parser

# 0.26.0 segfaults when walking trees (seen on control.lua); 0.25.2 is known good
if importlib.metadata.version("tree-sitter").startswith("0.26."):
    print('style-check: tree-sitter 0.26 crashes on this codebase; run: pip3 install "tree-sitter==0.25.2"', file=sys.stderr)
    sys.exit(1)

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Generated data and dead code
EXCLUDE_PREFIXES = (
    "lib/cost/recipe-randomizations/",
    "lib/cost/material-costs",
    "lib/cost/science-flows/",
    "lib/unused/",
    "lib/old-logic/",
)

# Names treated as booleans for the explicit nil check rule
BOOLEAN_NAME_RE = re.compile(r"^(is|has|should|can|do|does|use|allow|needs?|was|did|include|skip|force)_|^[A-Z][A-Z0-9_]*$|^valid$")
# Tables whose entries are true-or-nil, so "if tbl[key] then" is fine
BOOLEAN_TABLE_RE = re.compile(r"^(is|has|in|already|seen|visited|mods|active_mods)(_|$)")
COMPARISON_OPS = {"==", "~=", "<", ">", "<=", ">="}

PARSER = Parser(Language(tree_sitter_lua.language()))


class Finding:
    def __init__(self, severity, rule, row, message):
        self.severity = severity
        self.rule = rule
        # 0-indexed
        self.row = row
        self.message = message


def walk(node):
    # Cursor-based since collecting node.children across a whole tree segfaults in py-tree-sitter 0.26
    cursor = node.walk()
    while True:
        yield cursor.node
        if cursor.goto_first_child():
            continue
        while not cursor.goto_next_sibling():
            if not cursor.goto_parent():
                return


# Source of the file being checked; node.text segfaults in py-tree-sitter 0.26, so slice this instead
current_source = b""


def node_text(node):
    return current_source[node.start_byte:node.end_byte]


def last_name(node):
    # x -> x, a.b.c -> c, anything else -> nil
    if node.type == "identifier":
        return node_text(node).decode()
    if node.type == "dot_index_expression":
        field = node.child_by_field_name("field")
        if field is not None:
            return node_text(field).decode()
    return None


def is_boolean_expression(node):
    if node.type in ("true", "false"):
        return True
    if node.type == "unary_expression":
        return node.child_by_field_name("operator").type == "not"
    if node.type == "parenthesized_expression":
        return is_boolean_expression(node.named_children[0])
    if node.type == "binary_expression":
        op = node.child_by_field_name("operator").type
        if op in COMPARISON_OPS:
            return True
        if op in ("and", "or"):
            return is_boolean_expression(node.child_by_field_name("left")) and is_boolean_expression(node.child_by_field_name("right"))
    return False


def collect_boolean_names(root):
    # Names that are assigned a boolean somewhere in the file, so "if name then" is fine
    names = set()
    for node in walk(root):
        if node.type != "assignment_statement":
            continue
        variables = node.named_children[0].named_children
        values = node.named_children[1].named_children if len(node.named_children) > 1 else []
        for variable, value in zip(variables, values):
            name = last_name(variable)
            if name is not None and is_boolean_expression(value):
                names.add(name)
    return names


def truthiness_operands(node):
    # Yields the operands of a condition that are used for truthiness rather than compared explicitly
    if node.type in ("identifier", "dot_index_expression", "bracket_index_expression"):
        yield node
    elif node.type == "parenthesized_expression":
        yield from truthiness_operands(node.named_children[0])
    elif node.type == "unary_expression":
        if node.child_by_field_name("operator").type == "not":
            yield from truthiness_operands(node.child_by_field_name("operand"))
    elif node.type == "binary_expression":
        if node.child_by_field_name("operator").type in ("and", "or"):
            yield from truthiness_operands(node.child_by_field_name("left"))
            yield from truthiness_operands(node.child_by_field_name("right"))


def check_source(source):
    global current_source
    current_source = source
    findings = []
    tree = PARSER.parse(source)
    root = tree.root_node
    lines = source.decode(errors="replace").split("\n")
    boolean_names = collect_boolean_names(root)

    for row, line in enumerate(lines):
        if re.search(r"[ \t]+$", line):
            findings.append(Finding("error", "trailing-whitespace", row, "Trailing whitespace"))
        if line.startswith("\t"):
            findings.append(Finding("error", "indent", row, "Indent with 4 spaces, not tabs"))

    for node in walk(root):
        if node.type == "ERROR" or node.is_missing:
            findings.append(Finding("error", "syntax", node.start_point.row, "Syntax error"))

        elif node.type == "table_constructor":
            fields = [child for child in node.children if child.type == "field"]
            if len(fields) == 0:
                continue
            open_row = node.start_point.row
            close_row = node.end_point.row
            if any(child.type == ";" for child in node.children):
                findings.append(Finding("error", "table-separator", open_row, "Use commas, not semicolons, to separate table entries"))
            if open_row == close_row:
                if len(fields) >= 2:
                    findings.append(Finding("warning", "table-one-line", open_row, "Table with multiple entries on one line; usually each entry gets its own line"))
            else:
                last = fields[-1]
                after = last.next_sibling
                if after is None or after.type not in (",", ";"):
                    findings.append(Finding("error", "trailing-comma", last.end_point.row, "Multi-line table is missing a trailing comma after its last entry"))
                for prev, field in zip(fields, fields[1:]):
                    if prev.end_point.row == field.start_point.row:
                        findings.append(Finding("warning", "table-shared-line", field.start_point.row, "Multi-line table has several entries on this line; usually each entry gets its own line"))
                        break
                if fields[0].start_point.row == open_row:
                    findings.append(Finding("warning", "table-shared-line", open_row, "Multi-line table has an entry on the same line as its opening brace"))

        elif node.type in ("if_statement", "elseif_statement", "while_statement", "repeat_statement"):
            condition = node.child_by_field_name("condition")
            if condition is None:
                continue
            for operand in truthiness_operands(condition):
                name = last_name(operand)
                if name is not None and (name in boolean_names or BOOLEAN_NAME_RE.search(name)):
                    continue
                if operand.type == "bracket_index_expression":
                    table_name = last_name(operand.child_by_field_name("table"))
                    if table_name is not None and BOOLEAN_TABLE_RE.search(table_name):
                        continue
                text = node_text(operand).decode()
                findings.append(Finding("warning", "explicit-nil", operand.start_point.row, "Truthiness check on `" + text + "`; use `" + text + " ~= nil` / `" + text + " == nil` unless it's really a boolean"))

        elif node.type == "for_generic_clause":
            variables = node.named_children[0].named_children
            values = node.named_children[1].named_children
            if len(values) == 1 and values[0].type == "function_call":
                func = values[0].child_by_field_name("name")
                func_name = node_text(func).decode() if func is not None else ""
                if func_name == "pairs" and len(variables) == 1:
                    findings.append(Finding("error", "pairs-underscore", node.start_point.row, "Write `for k, _ in pairs(...)` rather than omitting the value variable"))
                elif func_name == "ipairs":
                    findings.append(Finding("warning", "ipairs", node.start_point.row, "This codebase uses pairs rather than ipairs"))

        elif node.type == "function_call":
            func = node.child_by_field_name("name")
            if func is not None and node_text(func) == b"require":
                args = node.child_by_field_name("arguments")
                arg_text = node_text(args).decode() if args is not None else ""
                match = re.fullmatch(r'\("([^"]*)"\)', arg_text)
                if not arg_text.startswith("("):
                    findings.append(Finding("error", "require", node.start_point.row, 'Write requires with parentheses: require("path/to/module")'))
                elif match is not None and "." in match.group(1) and "/" not in match.group(1) and not match.group(1).startswith("__"):
                    findings.append(Finding("error", "require", node.start_point.row, 'Use slashes in require paths: require("lib/foo") rather than require("lib.foo")'))

        elif node.type == "binary_expression":
            if node.child_by_field_name("operator").type == "..":
                left = node.child_by_field_name("left")
                right = node.child_by_field_name("right")
                op = node.child_by_field_name("operator")
                if left.end_byte == op.start_byte or op.end_byte == right.start_byte:
                    findings.append(Finding("error", "concat-spacing", op.start_point.row, "Put spaces around `..`"))

        elif node.type == "string":
            if node_text(node).startswith(b"'"):
                findings.append(Finding("error", "quotes", node.start_point.row, "Use double quotes for strings"))

        elif node.type in ("function_declaration", "variable_declaration", "assignment_statement"):
            if node.type == "function_declaration":
                name_node = node.child_by_field_name("name")
                names = [name_node] if name_node is not None else []
            elif node.type == "variable_declaration":
                inner = node.named_children[0]
                names = inner.named_children[0].named_children if inner.type == "assignment_statement" else inner.named_children
            else:
                continue
            for name_node in names:
                name = last_name(name_node)
                if name is not None and re.search(r"[a-z][A-Z]", name):
                    findings.append(Finding("error", "snake-case", name_node.start_point.row, "Use snake_case for `" + name + "`"))

    return findings


def git(*args):
    return subprocess.run(["git", *args], cwd=REPO, capture_output=True, text=True).stdout


def changed_rows(path, staged):
    # 0-indexed rows added/modified relative to HEAD (or the index when staged), or None for untracked files (all rows)
    if not staged and git("ls-files", "--", path).strip() == "":
        return None
    diff = git("diff", "--cached" if staged else "HEAD", "-U0", "--", path)
    rows = set()
    for match in re.finditer(r"^@@ -\S+ \+(\d+)(?:,(\d+))? @@", diff, re.M):
        start = int(match.group(1))
        count = int(match.group(2)) if match.group(2) is not None else 1
        rows.update(range(start - 1, start - 1 + count))
    return rows


def changed_files(staged):
    if staged:
        names = git("diff", "--cached", "--name-only", "--diff-filter=ACMR").split("\n")
    else:
        names = git("diff", "HEAD", "--name-only", "--diff-filter=ACMR").split("\n") + git("ls-files", "--others", "--exclude-standard").split("\n")
    return [name for name in names if is_checked(name)]


def is_checked(path):
    return path.endswith(".lua") and not path.startswith(EXCLUDE_PREFIXES)


def read_source(path, staged):
    if staged:
        return subprocess.run(["git", "show", ":" + path], cwd=REPO, capture_output=True).stdout
    with open(os.path.join(REPO, path), "rb") as f:
        return f.read()


def check_file(path, staged=False, all_rows=False):
    source = read_source(path, staged)
    findings = check_source(source)
    if all_rows:
        return findings
    rows = changed_rows(path, staged)
    if rows is None:
        return findings
    # Syntax errors are always relevant
    return [finding for finding in findings if finding.row in rows or finding.rule == "syntax"]


def format_findings(path, findings):
    return "\n".join(path + ":" + str(finding.row + 1) + ": [" + finding.rule + "] " + finding.message for finding in sorted(findings, key=lambda f: f.row))


def edit_rows(source, tool_input):
    # Rows touched by an Edit tool call, found by locating each new_string in the edited file
    text = source.decode(errors="replace")
    new_strings = [tool_input.get("new_string")] + [edit.get("new_string") for edit in tool_input.get("edits", [])]
    rows = set()
    for new_string in new_strings:
        if new_string is None or new_string == "":
            continue
        start = text.find(new_string)
        while start != -1:
            first = text.count("\n", 0, start)
            rows.update(range(first, first + new_string.count("\n") + 1))
            start = text.find(new_string, start + 1)
    return rows


def hook_post_edit(payload):
    tool_input = payload.get("tool_input", {})
    path = os.path.relpath(os.path.abspath(tool_input.get("file_path", "")), REPO)
    if path.startswith("..") or not is_checked(path) or not os.path.exists(os.path.join(REPO, path)):
        return 0

    source = read_source(path, False)
    findings = check_source(source)
    rows = changed_rows(path, False)
    errors = [f for f in findings if f.severity == "error" and (rows is None or f.row in rows or f.rule == "syntax")]
    # Warnings only for what this edit touched, so they aren't repeated on every later edit to the file
    warning_rows = edit_rows(source, tool_input) if "new_string" in tool_input or "edits" in tool_input else rows
    warnings = [f for f in findings if f.severity == "warning" and (warning_rows is None or f.row in warning_rows)]

    warning_text = ""
    if len(warnings) > 0:
        warning_text = "Style warnings (non-blocking). These are usually wrong in this codebase; fix each one, or leave it if you judge it intentional (e.g. the variable really is a boolean):\n" + format_findings(path, warnings)

    if len(errors) > 0:
        message = "Style errors on changed lines; fix these before continuing:\n" + format_findings(path, errors)
        if warning_text != "":
            message += "\n\n" + warning_text
        print(message, file=sys.stderr)
        return 2
    if warning_text != "":
        print(json.dumps({"hookSpecificOutput": {"hookEventName": "PostToolUse", "additionalContext": warning_text}}))
    return 0


def hook_stop(payload):
    # Only errors here; warnings were already surfaced per edit
    reports = []
    for path in changed_files(False):
        errors = [f for f in check_file(path) if f.severity == "error"]
        if len(errors) > 0:
            reports.append(format_findings(path, errors))
    if len(reports) == 0:
        return 0
    message = "Style errors remain in changed Lua files:\n" + "\n".join(reports)
    # Don't loop forever if they couldn't be fixed on the first retry
    if payload.get("stop_hook_active"):
        print(json.dumps({"systemMessage": message}))
        return 0
    print(message, file=sys.stderr)
    return 2


def main(argv):
    if len(argv) >= 2 and argv[0] == "--hook":
        payload = json.load(sys.stdin)
        if argv[1] == "post-edit":
            return hook_post_edit(payload)
        if argv[1] == "stop":
            return hook_stop(payload)
        print("Unknown hook: " + argv[1], file=sys.stderr)
        return 1

    staged = "--staged" in argv
    all_rows = "--all" in argv
    paths = [arg for arg in argv if not arg.startswith("--")]
    if len(paths) == 0:
        paths = changed_files(staged)

    error_count = 0
    warning_count = 0
    for path in paths:
        path = os.path.relpath(os.path.abspath(path), REPO)
        findings = check_file(path, staged, all_rows)
        if len(findings) > 0:
            print(format_findings(path, findings))
        error_count += sum(1 for f in findings if f.severity == "error")
        warning_count += sum(1 for f in findings if f.severity == "warning")

    if error_count > 0 or warning_count > 0:
        print(str(error_count) + " error(s), " + str(warning_count) + " warning(s)")
    return 1 if error_count > 0 else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

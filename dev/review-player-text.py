#!/usr/bin/env python3
"""Require human review of exact locale and localized Lua changes against HEAD.

Run without arguments to read the pending diffs, then --approve ID... only after
the user approves those exact diffs. --staged reviews the index, not the worktree.
Receipts live locally in the temporary directory; they never approve future text.
This is a workflow guard, not a security boundary against an agent bypassing it.
"""
import argparse
import difflib
import fcntl
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import shlex
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parent.parent
if __name__ == "__main__" and any(importlib.util.find_spec(name) is None for name in ("tree_sitter", "tree_sitter_lua")):
    python = ROOT / ".venv/release/bin/python"
    if python.is_file() and str(python) != sys.executable:
        os.execv(str(python), [str(python), str(Path(__file__).resolve()), *sys.argv[1:]])
# Share the parser and version guard already used by the other Lua checks.
spec = importlib.util.spec_from_file_location("player_text_style", ROOT / "dev/style-check.py")
style = importlib.util.module_from_spec(spec)
spec.loader.exec_module(style)

STATE_NAME = "propertyrandomizer-player-text"
# Detect localization sites in syntax, rather than matching unrelated file edits.
TEXT = re.compile(r"locali[sz]ed_(?:name|description)|\b(?:caption|tooltip)\b|propertyrandomizer-[\w-]+\.")
WRITE = re.compile(r"--approve|write|open\s*\(|dump|\b(?:cp|mv|rm|tee|touch|truncate|patch)\b|[>]|\s-[a-z]*i\b")
INSTRUCTIONS = (
    "The user must read and explicitly approve the exact player-facing text. "
    "Run python3 dev/review-player-text.py to see every pending diff; show the complete "
    "diffs to the user (including locale keys and Lua expressions), and wait for their "
    "approval of specific IDs before running --approve ID... . A request to implement "
    "a feature is not approval of its wording. Never approve on the user's behalf, "
    "edit receipts, or bypass the check. Leave unapproved drafts pending and say so."
)


def git(root, *args, optional=False):
    result = subprocess.run(["git", *args], cwd=root, capture_output=True)
    if result.returncode and not optional:
        raise RuntimeError(result.stderr.decode(errors="replace").strip())
    return result.stdout if result.returncode == 0 else None


def candidate(path):
    return path.startswith("locale/") or (
        path.endswith(".lua") and not path.startswith(("tests/", "dev/", "research/", "archive/"))
    )


def localized_snapshot(source):
    """Fingerprint wording definitions, not the gameplay which uses them.

    Follow string/table values and helper return values feeding localized fields.
    Ignore guards, numerical inputs, helper options, and bare uses of locale keys:
    the wording behind those keys is reviewed in locale/ itself. Approvals still
    cover exact file contents, and relevant files still display complete diffs.
    """
    source = source.encode("utf-8")
    tree = style.PARSER.parse(source)
    if tree.root_node.has_error:
        # Never silently exempt text in syntax we cannot analyze.
        return (source,) if TEXT.search(source.decode()) else ()
    nodes = list(style.walk(tree.root_node))
    functions = {"function_declaration", "function_definition"}

    def text(node):
        return source[node.start_byte:node.end_byte]

    def syntax(node):
        # Direct localized-field edits are always relevant, including changes to
        # variables/parameters in a localized table. Ignore formatting/comments.
        if node.type == "comment":
            return ()
        if node.type == "string" or not node.children:
            return ((node.type, text(node)),)
        return tuple(token for child in node.children for token in syntax(child))

    def scope(node):
        parent = node.parent
        while parent is not None and parent.type not in functions | {"block", "chunk"}:
            parent = parent.parent
        return parent if parent is not None else tree.root_node

    def symbol(node):
        if node.type == "identifier":
            return (text(node),)
        if node.type in {"dot_index_expression", "method_index_expression", "bracket_index_expression"}:
            owner = symbol(node.child_by_field_name("table"))
            member = node.child_by_field_name("field") or node.child_by_field_name("method")
            if owner is not None and member.type == "identifier" and node.type != "bracket_index_expression":
                return owner + (text(member),)
            if owner is not None and member.type == "string":
                return owner + (text(member)[1:-1],)
            return owner
        return None

    bindings = {}
    for node in nodes:
        names = []
        owner = scope(node)
        if node.type == "variable_declaration":
            variables = node.named_children[0]
            if variables.type == "assignment_statement":
                variables = variables.named_children[0]
            names = variables.named_children
        elif node.type == "parameters":
            names = node.named_children
        elif node.type == "for_generic_clause":
            names = node.named_children[0].named_children
            owner = node.parent.child_by_field_name("body") or owner
        elif node.type == "for_numeric_clause":
            names = node.named_children[:1]
            owner = node.parent.child_by_field_name("body") or owner
        elif node.type == "function_declaration" and text(node).startswith(b"local "):
            names = [node.child_by_field_name("name")]
        for name in names:
            if name.type == "identifier":
                bindings.setdefault(owner.id, set()).add(text(name))

    providers = {}

    def provide(node, name, value):
        if name is not None:
            owner = scope(node)
            while owner != tree.root_node and name[0] not in bindings.get(owner.id, ()):
                owner = scope(owner)
            providers.setdefault((owner.id, name), []).append(value)

    def provide_value(node, name, value):
        provide(node, name, value)
        if name is not None and value.type == "table_constructor":
            for field in value.named_children:
                member = field.child_by_field_name("name")
                item = field.child_by_field_name("value")
                if member is not None and item is not None and member.type in {"identifier", "string"}:
                    provide_value(node, name + (text(member).strip(b"\"'"),), item)

    for node in nodes:
        if node.type == "assignment_statement":
            variables, *values = node.named_children
            if values:
                for index, variable in enumerate(variables.named_children):
                    expressions = values[0].named_children
                    if expressions:
                        provide_value(node, symbol(variable), expressions[min(index, len(expressions) - 1)])
        elif node.type == "function_declaration":
            provide(node, symbol(node.child_by_field_name("name")), node)
        elif node.type == "function_call" and symbol(node.child_by_field_name("name")) in {(b"table", b"insert"), (b"table", b"remove")}:
            arguments = node.child_by_field_name("arguments").named_children
            if arguments:
                provide(node, symbol(arguments[0]), node)

    fields = {b"localised_name", b"localized_name", b"localised_description", b"localized_description", b"caption", b"tooltip"}
    roots, sites = [], []
    for node in nodes:
        if node.type == "assignment_statement":
            variables, *values = node.named_children
            for index, variable in enumerate(variables.named_children):
                name = symbol(variable)
                if name is not None and len(name) > 1 and name[-1] in fields and values:
                    expressions = values[0].named_children
                    if expressions:
                        value = expressions[min(index, len(expressions) - 1)]
                        sites.append((syntax(variable), syntax(value)))
                        roots.append(value)
        elif node.type == "field":
            name = node.child_by_field_name("name")
            value = node.child_by_field_name("value")
            if name is not None and text(name).strip(b"\"'") in fields and value is not None:
                sites.append((syntax(name), syntax(value)))
                roots.append(value)
        elif node.type == "string" and re.search(rb"propertyrandomizer-[\w-]+\.", text(node)):
            parent = node.parent
            if parent.type == "field" and parent.child_by_field_name("name") is None:
                roots.append(parent.parent)
            elif parent.type == "arguments" and parent.named_children[0] == node:
                # Existing locale-key calls are consumers, not wording. Literal
                # placeholder text can still introduce wording of its own.
                roots.extend(parent.named_children[1:])

    def output_children(node):
        """Only expressions contributing text, not a helper's entire body."""
        if node.type in functions:
            for child in style.walk(node):
                if child.type == "return_statement":
                    owner = child.parent
                    while owner is not None and owner.type not in functions:
                        owner = owner.parent
                    if owner == node:
                        yield from child.named_children
        elif node.type == "field":
            name = node.child_by_field_name("name")
            if name is None or name.type == "number":
                value = node.child_by_field_name("value")
                if value is not None:
                    yield value
        elif node.type == "function_call":
            callee = node.child_by_field_name("name")
            if symbol(callee) == (b"require",):
                return
            yield callee
            arguments = node.child_by_field_name("arguments").named_children
            if symbol(callee) in {(b"table", b"insert"), (b"table", b"remove")}:
                arguments = arguments[1:]
            yield from arguments
        elif node.type == "binary_expression":
            operator = text(node.child_by_field_name("operator"))
            if operator in {b"..", b"or"}:
                yield node.child_by_field_name("left")
                yield node.child_by_field_name("right")
            elif operator == b"and":
                yield node.child_by_field_name("right")
        elif node.type not in {"comment", "dot_index_expression", "method_index_expression", "bracket_index_expression", "unary_expression"}:
            yield from node.named_children

    def references(node):
        name = symbol(node)
        if name is not None:
            yield node, name
            return
        for child in output_children(node):
            yield from references(child)

    def suppliers(node, name):
        current = scope(node)
        while True:
            yield from providers.get((current.id, name), ())
            for (owner, member), values in providers.items():
                if owner == current.id and len(member) > len(name) and member[:len(name)] == name:
                    yield from values
            if name[0] in bindings.get(current.id, ()) or current == tree.root_node:
                return
            current = scope(current)

    selected = {}
    while roots:
        node = roots.pop()
        if node.id in selected:
            continue
        selected[node.id] = node
        for reference, name in references(node):
            roots.extend(suppliers(reference, name))

    def tokens(node):
        if node.type == "string":
            return ((node.type, text(node)),)
        return tuple(token for child in output_children(node) for token in tokens(child))

    # Reusing wording, moving it, or changing a displayed number is not new text.
    wording = {value for node in selected.values() if (value := tokens(node))}
    return (tuple(sorted(sites)), tuple(sorted(wording))) if sites or wording else ()


def changes(root=ROOT, staged=False):
    head = git(root, "rev-parse", "--verify", "HEAD", optional=True)
    args = ["diff", "--name-only", "--no-renames", "-z"]
    if staged:
        args.append("--cached")
    if head:
        args.append("HEAD")
    paths = set(git(root, *args).decode().split("\0"))
    if not staged:
        paths.update(git(root, "ls-files", "--others", "--exclude-standard", "-z").decode().split("\0"))
        if not head:
            paths.update(git(root, "diff", "--cached", "--name-only", "-z").decode().split("\0"))
    result = []
    for path in sorted(filter(candidate, paths)):
        before = git(root, "show", "HEAD:" + path, optional=True) if head else None
        if staged:
            after = git(root, "show", ":" + path, optional=True)
        else:
            full = root / path
            after = full.read_bytes() if full.is_file() else None
        if before == after:
            continue
        old, new = (value.decode("utf-8") if value is not None else "" for value in (before, after))
        if not path.startswith("locale/") and localized_snapshot(old) == localized_snapshot(new):
            continue
        # Include absent-vs-empty and all bytes, even text outside diff context.
        identity = json.dumps([path, before.hex() if before is not None else None,
                               after.hex() if after is not None else None]).encode()
        review_id = hashlib.sha256(identity).hexdigest()[:16]
        lines = difflib.unified_diff(old.splitlines(keepends=True), new.splitlines(keepends=True),
                                     fromfile="a/" + path, tofile="b/" + path)
        diff = "".join(line if line.endswith("\n") else line + "\n\\ No newline at end of file\n" for line in lines)
        if not diff:
            diff = f"{path}: file added or removed (empty text)\n"
        result.append({"id": review_id, "path": path, "diff": diff})
    return result


def state_path(root=ROOT):
    key = hashlib.sha256(str(root.resolve()).encode()).hexdigest()
    return Path(tempfile.gettempdir()) / STATE_NAME / (key + ".json")


def state_update(root, update):
    path = state_path(root)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a+") as stream:
        fcntl.flock(stream, fcntl.LOCK_EX)
        stream.seek(0)
        raw = stream.read()
        state = json.loads(raw) if raw else {"approved": [], "notified": {}}
        result = update(state)
        stream.seek(0)
        stream.truncate()
        json.dump(state, stream)
        return result


def pending(root=ROOT, staged=False):
    current = changes(root, staged)
    path = state_path(root)
    if not path.exists():
        return current
    approved = state_update(root, lambda state: set(state["approved"]))
    return [change for change in current if change["id"] not in approved]


def describe(items, summary=False):
    return "\n".join(f"[{item['id']}] {item['path']}\n" + ("" if summary else item["diff"]) for item in items)


def approve(root, ids, staged=False):
    current = {item["id"]: item for item in changes(root, staged)}
    missing = set(ids) - current.keys()
    if missing:
        raise ValueError("Unknown or stale review IDs: " + ", ".join(sorted(missing)))
    state_update(root, lambda state: state.update(approved=sorted(set(state["approved"]) | set(ids))))
    print("Recorded human text review: " + " ".join(ids))


def decide(decision, reason):
    print(json.dumps({"hookSpecificOutput": {"hookEventName": "PreToolUse",
                     "permissionDecision": decision, "permissionDecisionReason": reason}}))


def hook_pre_bash(payload, root=ROOT):
    command = payload.get("tool_input", {}).get("command", "")
    if STATE_NAME in command and WRITE.search(command):
        decide("deny", "Player-text review receipts must only be written by review-player-text.py after human approval.")
        return
    if "review-player-text.py" not in command or "--approve" not in command:
        return
    # Only a standalone invocation: no redirects, substitutions, or commands that
    # can mutate the reviewed content between this prompt and recording approval.
    try:
        words = shlex.split(command)
        if any(char in command for char in ";&|<>`$\n"):
            raise ValueError("Use a standalone command without shell substitutions or operators.")
        if len(words) < 4 or Path(words[0]).name not in ("python", "python3") or Path(words[1]).resolve() != (root / "dev/review-player-text.py").resolve():
            raise ValueError("Use python3 dev/review-player-text.py [--staged] --approve ID...")
        args = words[2:]
        staged = args[:1] == ["--staged"]
        if staged:
            args = args[1:]
        if not args or args[0] != "--approve" or len(args) < 2:
            raise ValueError("Put --staged before --approve, then pass the exact review IDs.")
        current = {item["id"]: item for item in changes(root, staged)}
        selected = [current[review_id] for review_id in args[1:]]
    except (ValueError, KeyError) as error:
        decide("deny", "Invalid or stale player-text review request: " + str(error))
        return
    decide("ask", "Read all of these exact diffs. Approve only if this wording should reach players.\n\n" + describe(selected))


def hook_pre_edit(payload, root=ROOT):
    path = payload.get("tool_input", {}).get("file_path", "")
    if STATE_NAME in Path(path).parts:
        decide("deny", "Player-text review receipts are human approvals; do not edit them directly.")


def hook_stop(payload, root=ROOT):
    items = pending(root)
    if not items:
        return
    session = payload.get("session_id", "unknown")
    ids = sorted(item["id"] for item in items)

    def first_notice(state):
        previous = state["notified"].get(session)
        state["notified"][session] = ids
        return previous != ids

    # Block once per exact pending set, then let the assistant ask the user and
    # end the turn. Pending changes still cannot pass the Git pre-commit check.
    if state_update(root, first_notice):
        print(json.dumps({"decision": "block", "reason": INSTRUCTIONS + "\n\n" + describe(items, summary=True)}))
    else:
        print(json.dumps({"systemMessage": "Player-facing text still awaits human review:\n" + describe(items, summary=True)}))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--staged", action="store_true")
    parser.add_argument("--summary", action="store_true", help="list pending IDs and paths without their diffs")
    parser.add_argument("--approve", nargs="+")
    parser.add_argument("--hook", choices=("pre-bash", "pre-edit", "stop"))
    args = parser.parse_args()
    try:
        if args.hook:
            {"pre-bash": hook_pre_bash, "pre-edit": hook_pre_edit, "stop": hook_stop}[args.hook](json.load(sys.stdin))
            return 0
        if args.approve:
            approve(ROOT, args.approve, args.staged)
            return 0
        items = pending(ROOT, args.staged)
        if items:
            print(describe(items, args.summary))
            print("\n" + INSTRUCTIONS)
        print(f"player-text: {len(items)} file(s) awaiting human review")
        return int(bool(items))
    except (OSError, RuntimeError, ValueError) as error:
        print("player-text: " + str(error), file=sys.stderr)
        # Claude command hooks use exit 2 to block rather than silently fail open.
        return 2 if args.hook else 1


if __name__ == "__main__":
    sys.exit(main())

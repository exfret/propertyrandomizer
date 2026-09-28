#!/usr/bin/env python3
# Flags Lua tables that hardcode Factorio API names or vanilla (base/Space Age) prototype names, so the user can approve each one
# Hardcoded names break with other mods; deriving from data.raw or declaring flags where nodes are built is preferred
#
# A table is flagged when a changed line holds one of its matching entries:
#   - a string key or value that's a prototype type ("assembling-machine"), API class ("LuaEntity") or vanilla prototype name ("iron-plate")
#   - an identifier key that's a vanilla prototype name ({nauvis = ...}), or two or more that are prototype types ({furnace = true, lab = true})
# The type of a table that also has a name isn't counted, since prototype definitions and ingredient specs need it
# Presentation-only prototypes (fonts, sounds, shortcuts, achievements, ...) are ignored, since their names are ordinary words like "default"
#
# Changed means since the start of the current Claude turn (so commits made during the turn still count), plus uncommitted changes
# An approval covers a file + the set of names one of its tables hardcodes, so edits that don't add names don't need approving again
# Approvals live in the git dir so they aren't committed: <git-common-dir>/claude-hardcoded-approvals.json
# Names come from the installed game (API docs JSON and a data.raw dump of the vanilla mods), cached per game version
#
# Usage:
#   dev/hardcoded-names.py                     list unapproved tables in uncommitted changes
#   dev/hardcoded-names.py --all FILE...       list every matching table in the given files
#   dev/hardcoded-names.py --approve ID...     approve tables by id (when Claude runs it, the pre-bash hook asks the user first)
#   dev/hardcoded-names.py --hook prompt|stop|pre-bash    Claude Code hook mode (reads hook JSON on stdin)

import datetime
import fcntl
import hashlib
import importlib.metadata
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

try:
    import tree_sitter_lua
    from tree_sitter import Language, Parser
except ImportError:
    # As in dev/style-check.py: python3 may be a Python without the parser (the hooks' PATH has one that has it, other shells may not), so reuse the release tools' environment when it's there
    parser_python = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), ".venv", "release", "bin", "python")
    if __name__ == "__main__" and os.path.isfile(parser_python) and os.path.abspath(sys.executable) != parser_python:
        os.execv(parser_python, [parser_python, os.path.abspath(__file__), *sys.argv[1:]])
    raise

# Also when another script loads this file by path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import factorio_launch

# Same known-bad version as dev/style-check.py
if importlib.metadata.version("tree-sitter").startswith("0.26."):
    print('hardcoded-names: tree-sitter 0.26 crashes on this codebase; run: pip3 install "tree-sitter==0.25.2"', file=sys.stderr)
    sys.exit(1)

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GAME = "/Applications/factorio.app/Contents"
FACTORIO = os.path.join(GAME, "MacOS", "factorio")
CACHE_DIR = os.path.join(tempfile.gettempdir(), "propertyrandomizer-hardcoded-names")

# As in dev/style-check.py: generated data and dead code
# Old logic is checked, since the mod still uses it while it's phased out
EXCLUDE_PREFIXES = (
    "lib/cost/recipe-randomizations/",
    "lib/cost/material-costs",
    "lib/cost/science-flows/",
    "lib/unused/",
)

# Prototype classes (with their subclasses) that are presentation or engine config rather than game content
IGNORED_CLASSES = {
    "AchievementPrototype",
    "AmbientSound",
    "AnimationPrototype",
    "CustomInputPrototype",
    "EditorControllerPrototype",
    "FontPrototype",
    "GodControllerPrototype",
    "GuiStyle",
    "ImpactCategory",
    "MapGenPresets",
    "MapSettings",
    "MouseCursor",
    "RemoteControllerPrototype",
    "ShortcutPrototype",
    "SoundPrototype",
    "SpectatorControllerPrototype",
    "SpritePrototype",
    "TipsAndTricksItem",
    "TipsAndTricksItemCategory",
    "UtilityConstants",
    "UtilitySounds",
    "UtilitySprites",
}

KIND_LABELS = {"type": "prototype types", "class": "API classes", "name": "vanilla names"}
# Keeps hook messages and permission prompts readable for big tables
MAX_LISTED_NAMES = 12
MAX_SNIPPET_LINES = 6

APPROVE_RE = re.compile(r"hardcoded-names\.py[\"']?\s+--approve\b([^;&|]*)")
ID_RE = re.compile(r"\b[0-9a-f]{8}\b")
STRING_RE = re.compile(r"^([\"'])([^\"'\\]*)\1$")
HUNK_RE = re.compile(r"^@@ -\S+ \+(\d+)(?:,(\d+))? @@")

PARSER = Parser(Language(tree_sitter_lua.language()))


def git(*args):
    return subprocess.run(["git", *args], cwd=REPO, capture_output=True, text=True)


# ---------------------------------------------------------------------------
# Names from the installed game
# ---------------------------------------------------------------------------


def game_version():
    with open(os.path.join(GAME, "data", "base", "info.json")) as f:
        return json.load(f)["version"]


def dump_data_raw(work_dir):
    # Runs the data stage with only the vanilla mods, in its own directories so it works while Factorio is open
    mods_dir = os.path.join(work_dir, "mods")
    data_dir = os.path.join(work_dir, "data")
    os.makedirs(mods_dir)
    os.makedirs(data_dir)
    game_data = os.path.join(GAME, "data")
    vanilla = [name for name in sorted(os.listdir(game_data)) if name != "core" and os.path.exists(os.path.join(game_data, name, "info.json"))]
    with open(os.path.join(mods_dir, "mod-list.json"), "w") as f:
        json.dump({"mods": [{"name": name, "enabled": True} for name in vanilla]}, f)
    config_path = os.path.join(work_dir, "config.ini")
    with open(config_path, "w") as f:
        f.write("[path]\nread-data=__PATH__executable__/../data\nwrite-data=" + data_dir + "\n")
    factorio_launch.run([FACTORIO, "-c", config_path, "--mod-directory", mods_dir, "--dump-data"], capture_output=True, check=True, timeout=300)
    with open(os.path.join(data_dir, "script-output", "data-raw-dump.json")) as f:
        return json.load(f)


def build_names():
    with open(os.path.join(GAME, "doc-html", "prototype-api.json")) as f:
        prototype_api = json.load(f)
    with open(os.path.join(GAME, "doc-html", "runtime-api.json")) as f:
        runtime_api = json.load(f)
    work_dir = tempfile.mkdtemp(prefix="dump-", dir=CACHE_DIR)
    try:
        data_raw = dump_data_raw(work_dir)
    finally:
        shutil.rmtree(work_dir, ignore_errors=True)
    return {
        "classes": {prototype["name"]: {"parent": prototype.get("parent"), "typename": prototype.get("typename")} for prototype in prototype_api["prototypes"]},
        "runtime_classes": [runtime_class["name"] for runtime_class in runtime_api["classes"]],
        "prototypes": {prototype_type: sorted(prototypes) for prototype_type, prototypes in data_raw.items()},
    }


class Names:
    def __init__(self, raw):
        classes = raw["classes"]

        def is_ignored(class_name):
            while class_name is not None:
                if class_name in IGNORED_CLASSES:
                    return True
                class_name = classes.get(class_name, {}).get("parent")
            return False

        ignored_types = {info["typename"] for class_name, info in classes.items() if info["typename"] is not None and is_ignored(class_name)}
        self.types = {info["typename"] for info in classes.values() if info["typename"] is not None} | set(raw["prototypes"])
        self.types -= ignored_types
        self.classes = {class_name for class_name in classes if not is_ignored(class_name)} | set(raw["runtime_classes"])
        self.prototypes = set()
        for prototype_type, prototype_names in raw["prototypes"].items():
            if prototype_type not in ignored_types:
                self.prototypes.update(prototype_names)

    def kind(self, text):
        if text in self.types:
            return "type"
        if text in self.classes:
            return "class"
        if text in self.prototypes:
            return "name"
        return None


def load_names():
    os.makedirs(CACHE_DIR, exist_ok=True)
    cache_path = os.path.join(CACHE_DIR, "names-" + game_version() + ".json")
    # Sessions share the cache; one build at a time
    with open(os.path.join(CACHE_DIR, "lock"), "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        if not os.path.exists(cache_path):
            raw = build_names()
            with open(cache_path + ".tmp", "w") as f:
                json.dump(raw, f)
            os.replace(cache_path + ".tmp", cache_path)
    with open(cache_path) as f:
        return Names(json.load(f))


# ---------------------------------------------------------------------------
# Scanning Lua tables
# ---------------------------------------------------------------------------


class Table:
    def __init__(self, path, row, matches, lines):
        self.path = path
        # 0-indexed row of the opening brace
        self.row = row
        # (row, text, kind) for each matching entry
        self.matches = matches
        self.lines = lines
        self.names = sorted({text for _, text, _ in matches})
        self.id = hashlib.sha1((path + "\n" + "\n".join(self.names)).encode()).hexdigest()[:8]

    def touches(self, rows):
        return rows is None or any(row in rows for row, _, _ in self.matches)


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


def node_text(source, node):
    # node.text segfaults in py-tree-sitter 0.26, so slice the source instead
    return source[node.start_byte:node.end_byte].decode(errors="replace")


def string_value(source, node):
    if node is None or node.type != "string":
        return None
    match = STRING_RE.match(node_text(source, node))
    return match.group(2) if match is not None else None


def table_matches(source, node, names):
    fields = [child for child in node.named_children if child.type == "field"]
    keys = [field.child_by_field_name("name") for field in fields]
    key_texts = [node_text(source, key) if key is not None and key.type == "identifier" else None for key in keys]
    has_name = "name" in key_texts
    matches = []
    type_keys = []
    for field, key, key_text in zip(fields, keys, key_texts):
        if key_text is not None:
            kind = names.kind(key_text)
            if kind == "type":
                type_keys.append((key.start_point.row, key_text, kind))
            elif kind == "name":
                matches.append((key.start_point.row, key_text, kind))
        else:
            text = string_value(source, key)
            if text is not None and names.kind(text) is not None:
                matches.append((key.start_point.row, text, names.kind(text)))
        value = field.child_by_field_name("value")
        text = string_value(source, value)
        if text is not None and names.kind(text) is not None and not (key_text == "type" and has_name):
            matches.append((value.start_point.row, text, names.kind(text)))
    # A single type-named identifier key is usually an ordinary field like `recipe = ...`
    if len(type_keys) >= 2:
        matches.extend(type_keys)
    return matches


def scan_file(path, names):
    # Nested matching tables are folded into their nearest matching ancestor, so one data table is one approval
    with open(os.path.join(REPO, path), "rb") as f:
        source = f.read()
    lines = source.decode(errors="replace").split("\n")
    # Node id of each matching table -> node id of the outermost matching table it's folded into
    owner = {}
    groups = {}
    # Pre-order, so ancestors are seen before their descendants
    for node in walk(PARSER.parse(source).root_node):
        if node.type != "table_constructor":
            continue
        matches = table_matches(source, node, names)
        if len(matches) == 0:
            continue
        ancestor = node.parent
        while ancestor is not None and ancestor.id not in owner:
            ancestor = ancestor.parent
        if ancestor is None:
            owner[node.id] = node.id
            groups[node.id] = (node.start_point.row, matches)
        else:
            owner[node.id] = owner[ancestor.id]
            groups[owner[node.id]][1].extend(matches)
    return [Table(path, row, matches, lines) for row, matches in groups.values()]


def is_checked(path):
    return path.endswith(".lua") and not path.startswith(EXCLUDE_PREFIXES)


def all_files():
    listed = git("ls-files", "-co", "--exclude-standard", "--", "*.lua").stdout.split("\n")
    return [path for path in listed if is_checked(path) and os.path.exists(os.path.join(REPO, path))]


def changed_rows(base):
    # {path: 0-indexed rows added/modified relative to base} for changed Lua files, with None for untracked files (all rows)
    # One diff for everything, since a git call per file adds up to seconds
    changed = {}
    path = None
    diff = git("diff", base, "-U0", "--no-renames", "--diff-filter=ACMR", "--", "*.lua").stdout
    for line in diff.split("\n"):
        if line.startswith("+++ "):
            path = line[len("+++ b/"):] if line.startswith("+++ b/") else None
            if path is not None:
                changed[path] = set()
            continue
        match = HUNK_RE.match(line)
        if match is not None and path is not None:
            start = int(match.group(1))
            count = int(match.group(2)) if match.group(2) is not None else 1
            changed[path].update(range(start - 1, start - 1 + count))
    for path in git("ls-files", "--others", "--exclude-standard", "--", "*.lua").stdout.split("\n"):
        changed[path] = None
    return {path: rows for path, rows in changed.items() if is_checked(path) and os.path.exists(os.path.join(REPO, path))}


def changed_tables(base, names):
    tables = []
    for path, rows in sorted(changed_rows(base).items()):
        tables.extend(table for table in scan_file(path, names) if table.touches(rows))
    return tables


def find_tables(ids, names):
    found = {}
    for path in all_files():
        for table in scan_file(path, names):
            if table.id in ids and table.id not in found:
                found[table.id] = table
    return found


# ---------------------------------------------------------------------------
# Approvals
# ---------------------------------------------------------------------------


def approvals_path():
    common_dir = git("rev-parse", "--git-common-dir").stdout.strip()
    return os.path.join(REPO, common_dir, "claude-hardcoded-approvals.json")


class Approvals:
    # Locked read-modify-write, since sessions run hooks concurrently
    def __enter__(self):
        self.lock = open(approvals_path() + ".lock", "w")
        fcntl.flock(self.lock, fcntl.LOCK_EX)
        try:
            with open(approvals_path()) as f:
                self.entries = json.load(f)
        except FileNotFoundError:
            self.entries = {}
        return self

    def save(self):
        tmp = approvals_path() + ".tmp"
        with open(tmp, "w") as f:
            json.dump(self.entries, f, indent=1, sort_keys=True)
        os.replace(tmp, approvals_path())

    def __exit__(self, *exc):
        fcntl.flock(self.lock, fcntl.LOCK_UN)
        self.lock.close()


def load_approvals():
    with Approvals() as approvals:
        return dict(approvals.entries)


def unapproved(tables, approved):
    seen = set()
    result = []
    for table in tables:
        if table.id not in approved and table.id not in seen:
            seen.add(table.id)
            result.append(table)
    return result


# ---------------------------------------------------------------------------
# Reporting
# ---------------------------------------------------------------------------


def listed(names):
    if len(names) <= MAX_LISTED_NAMES:
        return ", ".join(names)
    return ", ".join(names[:MAX_LISTED_NAMES]) + ", ... (+" + str(len(names) - MAX_LISTED_NAMES) + " more)"


def describe(table, approved):
    by_kind = {}
    for _, text, kind in table.matches:
        by_kind.setdefault(kind, set()).add(text)
    parts = [KIND_LABELS[kind] + ": " + listed(sorted(by_kind[kind])) for kind in ("type", "class", "name") if kind in by_kind]
    line = table.path + ":" + str(table.row + 1) + " [" + table.id + "] " + "; ".join(parts)
    # When names were added to an approved table, say which ones are new
    earlier = [entry["names"] for entry in approved.values() if entry["file"] == table.path and set(entry["names"]) < set(table.names)]
    if len(earlier) > 0:
        line += " (new since approval: " + listed(sorted(set(table.names) - set(max(earlier, key=len)))) + ")"
    return line


def snippet(table):
    rows = sorted({row for row, _, _ in table.matches})
    text = ["    " + str(row + 1) + ": " + table.lines[row].strip() for row in rows[:MAX_SNIPPET_LINES]]
    if len(rows) > MAX_SNIPPET_LINES:
        text.append("    ... (+" + str(len(rows) - MAX_SNIPPET_LINES) + " more lines)")
    return "\n".join(text)


# ---------------------------------------------------------------------------
# Hooks
# ---------------------------------------------------------------------------


def turn_base_path(session_id):
    return os.path.join(CACHE_DIR, "turn-base", re.sub(r"[^A-Za-z0-9_-]", "_", session_id))


def diff_base(session_id):
    # HEAD at the start of this turn if it's still an ancestor (so commits made during the turn are checked), else HEAD
    head = git("rev-parse", "HEAD").stdout.strip()
    if session_id is None or not os.path.exists(turn_base_path(session_id)):
        return head
    with open(turn_base_path(session_id)) as f:
        base = f.read().strip()
    if git("merge-base", "--is-ancestor", base, head).returncode != 0:
        return head
    return base


def hook_prompt(payload):
    session_id = payload.get("session_id")
    head = git("rev-parse", "HEAD")
    if session_id is None or head.returncode != 0:
        return 0
    os.makedirs(os.path.dirname(turn_base_path(session_id)), exist_ok=True)
    with open(turn_base_path(session_id), "w") as f:
        f.write(head.stdout.strip() + "\n")
    return 0


def hook_stop(payload):
    names = load_names()
    approved = load_approvals()
    flagged = unapproved(changed_tables(diff_base(payload.get("session_id")), names), approved)
    if len(flagged) == 0:
        return 0
    listing = "\n".join("  " + describe(table, approved) for table in flagged)
    ids = " ".join(table.id for table in flagged)
    # Block once so the agent handles it; after that, let it stop but make sure the user sees what's pending
    if payload.get("stop_hook_active"):
        message = "Tables with hardcoded Factorio names still awaiting your approval (dev/hardcoded-names.py):\n" + listing
        message += "\nApprove with: ! python3 dev/hardcoded-names.py --approve " + ids
        print(json.dumps({"systemMessage": message}))
        return 0
    message = "These tables hardcode Factorio API names or vanilla (base/Space Age) prototype names, and each needs the user's approval (dev/hardcoded-names.py):\n" + listing
    message += "\n\nFor each one, either stop hardcoding the names (derive them from data.raw or lab inputs, identify by node type, or declare a flag where the node is built), or keep it and get approval."
    message += " To get approval, show the user each kept table (file:line, the code, and why the names can't be derived), then run `python3 dev/hardcoded-names.py --approve <ids>`, which asks them in a permission prompt."
    message += " If they decline, rework the code. Never edit the approvals file yourself."
    print(message, file=sys.stderr)
    return 2


def ask(decision, reason):
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": decision,
        "permissionDecisionReason": reason,
    }}))


def hook_pre_bash(payload):
    match = APPROVE_RE.search(payload.get("tool_input", {}).get("command", ""))
    if match is None:
        return 0
    ids = ID_RE.findall(match.group(1))
    if len(ids) == 0:
        ask("deny", "hardcoded-names: pass the ids of the tables to approve, e.g. --approve 1a2b3c4d 5e6f7a8b")
        return 0
    found = find_tables(set(ids), load_names())
    missing = [table_id for table_id in ids if table_id not in found]
    if len(missing) > 0:
        ask("deny", "hardcoded-names: no current table has id " + ", ".join(missing) + " (ids change when a table's names change; run python3 dev/hardcoded-names.py to list current ones)")
        return 0
    approved = load_approvals()
    entries = [describe(found[table_id], approved) + "\n" + snippet(found[table_id]) for table_id in ids]
    ask("ask", "Approve these tables that hardcode Factorio names?\n" + "\n".join(entries))
    return 0


# ---------------------------------------------------------------------------
# Command line
# ---------------------------------------------------------------------------


def approve(ids):
    found = find_tables(set(ids), load_names())
    missing = [table_id for table_id in ids if table_id not in found]
    if len(missing) > 0:
        print("No current table has id " + ", ".join(missing), file=sys.stderr)
        return 1
    now = datetime.datetime.now().isoformat(timespec="seconds")
    with Approvals() as approvals:
        for table_id in ids:
            table = found[table_id]
            approvals.entries[table_id] = {"file": table.path, "names": table.names, "approved": now}
        approvals.save()
    for table_id in ids:
        print("approved " + found[table_id].path + ":" + str(found[table_id].row + 1) + " [" + table_id + "]")
    return 0


def main(argv):
    if len(argv) >= 2 and argv[0] == "--hook":
        payload = json.load(sys.stdin)
        hooks = {"prompt": hook_prompt, "stop": hook_stop, "pre-bash": hook_pre_bash}
        if argv[1] not in hooks:
            print("Unknown hook: " + argv[1], file=sys.stderr)
            return 1
        return hooks[argv[1]](payload)

    if len(argv) >= 1 and argv[0] == "--approve":
        return approve(argv[1:])

    names = load_names()
    approved = load_approvals()
    if len(argv) >= 1 and argv[0] == "--all":
        paths = [os.path.relpath(os.path.abspath(path), REPO) for path in argv[1:]]
        for path in paths:
            for table in scan_file(path, names):
                print(describe(table, approved) + (" (approved)" if table.id in approved else ""))
        return 0

    flagged = unapproved(changed_tables("HEAD", names), approved)
    for table in flagged:
        print(describe(table, approved))
        print(snippet(table))
    print(str(len(flagged)) + " unapproved table(s)")
    return 1 if len(flagged) > 0 else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

#!/usr/bin/env python3
# Lists the dependency graph node types the mod's code can create, so that each new one is approved by the user
# A node type adds nodes, and contexts for each of them, to every graph the randomizer builds and sorts, so a new one changes load time and what the logic models
# On 2026-10-12 a module-effects builder put "module use" nodes into every logic build without that; the user's 8-minute load took 16
#
# Nodes are tables with type and name fields plus prereqs, pre, dep or object_type = "node" (gutils.add_node and the old logic's add_to_graph build them)
# A function whose parameter becomes such a type creates nodes, and so does every function that passes its own parameter on to one (builder.add_node, ...)
# A creation's type is a string literal, or a name assigned only that string literal in the same file
# Anything else (node.type, a concatenation, a loop variable) makes it a dynamic site, approved by its file and expression
# Only src/ is scanned, minus generated data; tests/ holds fixtures
#
# Approvals are committed in dev/node-types.json, and only --approve adds to them
# When Claude runs --approve, the pre-bash hook asks the user first; the hooks also stop Claude from editing the file itself
#
# Usage:
#   dev/node-types.py                                   list unapproved node types and dynamic sites in the working tree (exit 1 if any)
#   dev/node-types.py --staged                          the same for what's staged (pre-commit hook)
#   dev/node-types.py --list                            list every node type and dynamic site, with where each is created
#   dev/node-types.py --approve [--note TEXT] NAME...   approve node types by name and dynamic sites by id
#   dev/node-types.py --hook pre-bash|pre-edit|stop     Claude Code hook mode (reads hook JSON on stdin)

import datetime
import hashlib
import importlib.metadata
import json
import os
import re
import shlex
import subprocess
import sys
import tempfile

try:
    import tree_sitter_lua
    from tree_sitter import Language, Parser
except ImportError:
    # As in dev/style-check.py: python3 may be a Python without the parser, so reuse the release tools' environment when it's there
    parser_python = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), ".venv", "release", "bin", "python")
    if __name__ == "__main__" and os.path.isfile(parser_python) and os.path.abspath(sys.executable) != parser_python:
        os.execv(parser_python, [parser_python, os.path.abspath(__file__), *sys.argv[1:]])
    raise

# Same known-bad version as dev/style-check.py
if importlib.metadata.version("tree-sitter").startswith("0.26."):
    print('node-types: tree-sitter 0.26 crashes on this codebase; run: pip3 install "tree-sitter==0.25.2"', file=sys.stderr)
    sys.exit(1)

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REGISTRY = "dev/node-types.json"
# What the stop hook already told each session about
STATE_DIR = os.path.join(tempfile.gettempdir(), "propertyrandomizer-node-types")
# Generated cost tables: big, and never build nodes
EXCLUDE_PREFIXES = ("src/cost/material-costs",)
# Fields that make a table with type and name a graph node rather than, say, a prototype
NODE_FIELDS = {"prereqs", "pre", "dep"}
MAX_LISTED_PLACES = 4

APPROVE_RE = re.compile(r"node-types\.py[\"']?\s+--approve\b([^;&|]*)")
SITE_ID_RE = re.compile(r"^[0-9a-f]{8}$")
STRING_RE = re.compile(r"^([\"'])([^\"'\\]*)\1$")
REGISTRY_MENTION_RE = re.compile(r"node-types\.json")
# As in dev/protect-changelog.py: something that writes files
WRITE_RE = re.compile(r"(sed\s+-[a-zA-Z]*i|perl\s+-[a-zA-Z]*i|>>?|\btee\b|\bopen\(|\bmv\b|\bcp\b|\brm\b|git\s+(checkout|restore|stash)|\bpatch\b|\btruncate\b|\bapply\b|write_text|json\.dump)")

PARSER = Parser(Language(tree_sitter_lua.language()))


def git(*args, root=None):
    return subprocess.run(["git", *args], cwd=root or REPO, capture_output=True, text=True)


# ---------------------------------------------------------------------------
# Sources
# ---------------------------------------------------------------------------


def is_scanned(path):
    return path.startswith("src/") and path.endswith(".lua") and not path.startswith(EXCLUDE_PREFIXES)


def working_tree_sources(root=None):
    root = root or REPO
    top = git("rev-parse", "--show-toplevel", root=root)
    if top.returncode == 0 and os.path.realpath(top.stdout.strip()) == os.path.realpath(root):
        listed = git("ls-files", "-co", "--exclude-standard", "-z", "--", "src", root=root).stdout.split("\0")
    else:
        # A copy that isn't its own Git checkout, like a dev/run-tests.py snapshot: every file under src/
        listed = []
        for folder, _, names in os.walk(os.path.join(root, "src")):
            for name in names:
                listed.append(os.path.relpath(os.path.join(folder, name), root).replace(os.sep, "/"))
    sources = {}
    for path in listed:
        full = os.path.join(root, path)
        if is_scanned(path) and os.path.isfile(full):
            with open(full, "rb") as f:
                sources[path] = f.read()
    return sources


def staged_sources(root=None):
    root = root or REPO
    entries = git("ls-files", "-s", "-z", "--", "src", root=root).stdout.split("\0")
    blobs = {}
    for entry in entries:
        if entry == "":
            continue
        info, path = entry.split("\t", 1)
        if is_scanned(path):
            blobs[path] = info.split()[1]
    # One cat-file for every blob, since a git call per file adds up to seconds
    batch = subprocess.run(["git", "cat-file", "--batch"], cwd=root, input="\n".join(blobs.values()).encode() + b"\n", capture_output=True).stdout
    contents = []
    offset = 0
    for _ in blobs:
        header_end = batch.index(b"\n", offset)
        size = int(batch[offset:header_end].split()[2])
        contents.append(batch[header_end + 1:header_end + 1 + size])
        offset = header_end + 1 + size + 1
    return dict(zip(blobs.keys(), contents))


# ---------------------------------------------------------------------------
# Scanning
# ---------------------------------------------------------------------------


class Function:
    def __init__(self, key, params):
        # ("local", module, name), ("export", module, name), ("global", name) or ("anonymous", module, row)
        self.key = key
        self.params = params


class Site:
    def __init__(self, path, row, kind, value, via):
        self.path = path
        # 1-based line
        self.row = row
        # "type" (value is the node type) or "dynamic" (value is the type expression)
        self.kind = kind
        self.value = value
        # What creates the node: the called function, or "node table"
        self.via = via
        self.id = site_id(path, value) if kind == "dynamic" else None

    def place(self):
        return self.path + ":" + str(self.row)


def site_id(path, expression):
    return hashlib.sha1((path + "\n" + expression).encode()).hexdigest()[:8]


def text(source, node):
    # node.text segfaults in some py-tree-sitter versions, so slice the source instead
    return source[node.start_byte:node.end_byte].decode(errors="replace")


def code_children(node):
    return [child for child in node.named_children if child.type != "comment"]


def string_value(source, node):
    if node is None or node.type != "string":
        return None
    match = STRING_RE.match(text(source, node))
    return match.group(2) if match is not None else None


def module_of(path):
    return path[:-len(".lua")] if path.endswith(".lua") else path


def required_module(source, node):
    # The module a require("...") call names, if node is one
    if node is None or node.type != "function_call":
        return None
    callee = node.child_by_field_name("name")
    if callee is None or callee.type != "identifier" or text(source, callee) != "require":
        return None
    arguments = code_children(node.child_by_field_name("arguments"))
    if len(arguments) != 1:
        return None
    target = string_value(source, arguments[0])
    if target is None:
        return None
    return module_of(target.removeprefix("__propertyrandomizer__/"))


def assignments(node):
    # (target, value) pairs of an assignment or local declaration; values may be None
    if node.type == "variable_declaration":
        inner = [child for child in code_children(node) if child.type == "assignment_statement"]
        if len(inner) == 0:
            return []
        node = inner[0]
    if node.type != "assignment_statement":
        return []
    targets = []
    values = []
    for child in code_children(node):
        if child.type == "variable_list":
            targets = code_children(child)
        elif child.type == "expression_list":
            values = code_children(child)
    return [(target, values[index] if index < len(values) else None) for index, target in enumerate(targets)]


class FileScan:
    def __init__(self, path, source):
        self.path = path
        self.module = module_of(path)
        self.source = source
        self.tree = PARSER.parse(source)
        # Local name -> required module
        self.requires = {}
        # Local name -> (local name of a module, field), for local f = X.g
        self.aliases = {}
        # Name -> every value assigned to it, to find names that only ever hold one string
        self.assigned = {}
        # Function node id -> Function
        self.functions = {}
        # Keys of the functions this file defines
        self.defined = set()
        # (row, type expression, scope) of each node table
        self.tables = []
        # (row, callee key, callee text, argument nodes, scope) of each call
        self.calls = []
        self.collect()

    def function_key(self, node):
        row = node.start_point.row + 1
        if node.type == "function_declaration":
            name = node.child_by_field_name("name")
            is_local = any(child.type == "local" for child in node.children)
            if name is not None and name.type == "identifier":
                return ("local", self.module, text(self.source, name)) if is_local else ("global", text(self.source, name))
            if name is not None and name.type == "dot_index_expression":
                return ("export", self.module, text(self.source, name.child_by_field_name("field")))
            return ("anonymous", self.module, row)
        # A function value: named by what it's assigned to, when it's the only value there
        expression_list = node.parent
        statement = expression_list.parent if expression_list is not None else None
        if expression_list is None or expression_list.type != "expression_list" or statement is None or statement.type != "assignment_statement":
            return ("anonymous", self.module, row)
        for target, value in assignments(statement.parent if statement.parent.type == "variable_declaration" else statement):
            if value is not None and value.id == node.id:
                if target.type == "identifier":
                    return ("local", self.module, text(self.source, target))
                if target.type == "dot_index_expression":
                    return ("export", self.module, text(self.source, target.child_by_field_name("field")))
        return ("anonymous", self.module, row)

    def collect(self):
        source = self.source
        stack = [(self.tree.root_node, ())]
        while len(stack) > 0:
            node, scope = stack.pop()
            if node.type in ("function_declaration", "function_definition"):
                parameters = node.child_by_field_name("parameters")
                params = [text(source, param) for param in code_children(parameters)] if parameters is not None else []
                function = Function(self.function_key(node), params)
                self.functions[node.id] = function
                self.defined.add(function.key)
                scope = scope + (function,)
            elif node.type in ("variable_declaration", "assignment_statement") and not (node.type == "assignment_statement" and node.parent.type == "variable_declaration"):
                for target, value in assignments(node):
                    if target.type != "identifier":
                        continue
                    name = text(source, target)
                    self.assigned.setdefault(name, []).append(value)
                    module = required_module(source, value)
                    if module is not None:
                        self.requires[name] = module
                    elif value is not None and value.type == "dot_index_expression":
                        table = value.child_by_field_name("table")
                        if table.type == "identifier":
                            self.aliases[name] = (text(source, table), text(source, value.child_by_field_name("field")))
                    elif value is not None and value.type == "identifier":
                        # local G = gutils: another name for the same module
                        self.aliases[name] = (text(source, value), None)
            elif node.type == "table_constructor":
                fields = {}
                for field in code_children(node):
                    if field.type == "field":
                        name = field.child_by_field_name("name")
                        if name is not None and name.type == "identifier":
                            fields[text(source, name)] = field.child_by_field_name("value")
                # A set of field names ({type = true, name = true, pre = true, ...}) isn't a node
                is_node = fields.get("type") is not None and fields["type"].type not in ("true", "false", "nil", "number") and "name" in fields
                if is_node and (NODE_FIELDS & fields.keys() or string_value(source, fields.get("object_type")) == "node"):
                    self.tables.append((node.start_point.row + 1, fields["type"], scope))
            elif node.type == "function_call":
                callee = node.child_by_field_name("name")
                arguments = node.child_by_field_name("arguments")
                if callee is not None and arguments is not None:
                    argument_nodes = code_children(arguments) if arguments.type == "arguments" else [arguments]
                    self.calls.append((node.start_point.row + 1, self.callee_key(callee), text(self.source, callee), argument_nodes, scope))
            for child in reversed(code_children(node)):
                stack.append((child, scope))

    def module_named(self, name):
        # The module a local name stands for, following local G = gutils
        seen = set()
        while name not in seen:
            seen.add(name)
            if name in self.requires:
                return self.requires[name]
            alias = self.aliases.get(name)
            if alias is None or alias[1] is not None:
                return None
            name = alias[0]
        return None

    def callee_key(self, callee):
        # The last element is always the function's own name, so unresolved calls can be matched against creators' names
        source = self.source
        if callee.type == "identifier":
            name = text(source, callee)
            alias = self.aliases.get(name)
            if alias is not None and alias[1] is not None:
                module = self.module_named(alias[0])
                if module is not None:
                    return ("export", module, alias[1])
                return ("unresolved", alias[1])
            return ("named", self.module, name)
        if callee.type == "dot_index_expression":
            table = callee.child_by_field_name("table")
            field = text(source, callee.child_by_field_name("field"))
            module = self.module_named(text(source, table)) if table.type == "identifier" else None
            if module is not None:
                return ("export", module, field)
            # The file's own module table (gutils.add_node inside graph-utils) or something unknown
            return ("own", self.module, field)
        if callee.type == "method_index_expression":
            method = callee.child_by_field_name("method")
            return ("unresolved", text(source, method) if method is not None else text(source, callee))
        if callee.type == "bracket_index_expression":
            field = string_value(source, callee.child_by_field_name("field"))
            return ("unresolved", field if field is not None else text(source, callee))
        return ("unresolved", text(source, callee))

    def constant(self, name):
        values = self.assigned.get(name, [])
        strings = {string_value(self.source, value) for value in values}
        if len(values) > 0 and len(strings) == 1 and None not in strings:
            return strings.pop()
        return None

    def resolve(self, node, scope):
        # ("type", name), ("param", function, index) or ("dynamic", expression)
        while node is not None and node.type == "parenthesized_expression":
            node = code_children(node)[0]
        if node is None:
            return ("dynamic", "(no type)")
        literal = string_value(self.source, node)
        if literal is not None:
            return ("type", literal)
        if node.type == "identifier":
            name = text(self.source, node)
            for function in reversed(scope):
                if name in function.params:
                    return ("param", function, function.params.index(name))
            value = self.constant(name)
            if value is not None:
                return ("type", value)
        return ("dynamic", " ".join(text(self.source, node).split()))


def resolve_callee(key, defined):
    # The key of the function a call reaches, or None
    if key[0] == "named":
        local = ("local", key[1], key[2])
        if local in defined:
            return local
        return ("global", key[2])
    if key[0] == "own":
        export = ("export", key[1], key[2])
        return export if export in defined else None
    if key[0] == "export":
        return key
    return None


def scan(sources):
    files = []
    errors = []
    for path in sorted(sources):
        file_scan = FileScan(path, sources[path])
        files.append(file_scan)
        if file_scan.tree.root_node.has_error:
            errors.append(Site(path, 1, "dynamic", "(file has syntax errors, so its node types can't be checked)", "parser"))
    defined = set()
    for file_scan in files:
        defined |= file_scan.defined

    # Functions that create nodes -> the argument positions holding the type; grows until nothing new passes a parameter on
    creators = {}

    def creations(file_scan):
        for row, expression, scope in file_scan.tables:
            yield row, expression, scope, "node table"
        for row, key, callee, arguments, scope in file_scan.calls:
            target = resolve_callee(key, defined)
            for index in sorted(creators.get(target, ())):
                yield row, arguments[index] if index < len(arguments) else None, scope, callee

    changed = True
    while changed:
        changed = False
        for file_scan in files:
            for _, expression, scope, _ in creations(file_scan):
                resolved = file_scan.resolve(expression, scope)
                if resolved[0] == "param" and resolved[1].key[0] != "anonymous":
                    positions = creators.setdefault(resolved[1].key, set())
                    if resolved[2] not in positions:
                        positions.add(resolved[2])
                        changed = True

    # Only creators other files can call; a file's local ones are always resolved
    creator_names = {key[-1] for key in creators if key[0] in ("export", "global")}
    sites = list(errors)
    for file_scan in files:
        for row, expression, scope, via in creations(file_scan):
            resolved = file_scan.resolve(expression, scope)
            if resolved[0] == "type":
                sites.append(Site(file_scan.path, row, "type", resolved[1], via))
            elif resolved[0] == "dynamic":
                sites.append(Site(file_scan.path, row, "dynamic", resolved[1], via))
            elif resolved[1].key[0] == "anonymous":
                # A callback's parameter: its callers can't be followed
                sites.append(Site(file_scan.path, row, "dynamic", text(file_scan.source, expression), via))
        # A call named like a node-creating function that can't be followed could create anything
        for row, key, callee, arguments, scope in file_scan.calls:
            target = resolve_callee(key, defined)
            if (target is None or target not in defined) and key[-1] in creator_names:
                sites.append(Site(file_scan.path, row, "dynamic", "unresolved call " + callee, callee))
    return sites


# ---------------------------------------------------------------------------
# Approvals
# ---------------------------------------------------------------------------


def registry_path(root=None):
    root = root or REPO
    return os.path.join(root, REGISTRY)


def load_registry(root=None, staged=False):
    root = root or REPO
    if staged:
        result = git("show", ":" + REGISTRY, root=root)
        if result.returncode != 0:
            return {"types": {}, "dynamic_sites": {}}
        registry = json.loads(result.stdout)
    else:
        try:
            with open(registry_path(root)) as f:
                registry = json.load(f)
        except FileNotFoundError:
            registry = {}
    registry.setdefault("types", {})
    registry.setdefault("dynamic_sites", {})
    return registry


def save_registry(registry, root=None):
    root = root or REPO
    path = registry_path(root)
    with open(path + ".tmp", "w") as f:
        json.dump(registry, f, indent=1, sort_keys=True)
        f.write("\n")
    os.replace(path + ".tmp", path)


def moved_from(root=None):
    root = root or REPO
    # Current path -> earlier path, so a dynamic site's approval survives its file moving (dev/module-moves.json)
    try:
        with open(os.path.join(root, "dev", "module-moves.json")) as f:
            return {current: previous for previous, current in json.load(f).items()}
    except FileNotFoundError:
        return {}


def is_approved(site, registry, moves):
    if site.kind == "type":
        return site.value in registry["types"]
    if site.id in registry["dynamic_sites"]:
        return True
    previous = moves.get(site.path)
    return previous is not None and site_id(previous, site.value) in registry["dynamic_sites"]


def unapproved(sites, registry, moves):
    return [site for site in sites if not is_approved(site, registry, moves)]


# ---------------------------------------------------------------------------
# Reporting
# ---------------------------------------------------------------------------


def places(sites):
    listed = sorted({site.place() + " (" + site.via + ")" for site in sites})
    if len(listed) > MAX_LISTED_PLACES:
        return ", ".join(listed[:MAX_LISTED_PLACES]) + ", ... (+" + str(len(listed) - MAX_LISTED_PLACES) + " more)"
    return ", ".join(listed)


def describe(pending):
    # One line per node type and per dynamic site
    by_type = {}
    by_id = {}
    for site in pending:
        if site.kind == "type":
            by_type.setdefault(site.value, []).append(site)
        else:
            by_id.setdefault(site.id, []).append(site)
    lines = ["node type " + name + ": " + places(sites) for name, sites in sorted(by_type.items())]
    lines += ["dynamic site [" + site_id_value + "] " + sites[0].value + ": " + places(sites) for site_id_value, sites in sorted(by_id.items())]
    return lines


def pending_names(pending):
    return sorted({site.value if site.kind == "type" else site.id for site in pending})


INSTRUCTIONS = (
    "Each new dependency graph node type needs the user's approval, since every graph the randomizer builds and sorts gets its nodes (dev/node-types.py)."
    " Either build the logic from node types that already exist, or show the user each new type (where it's created, what it models, and roughly how many nodes it adds),"
    " then run `python3 dev/node-types.py --approve --note \"<what it models>\" <names>`, which asks them in a permission prompt. A dynamic site is one whose type isn't a"
    " string the checker can read; make it one if you can. If the user declines, rework the code. Never edit dev/node-types.json yourself."
)


# ---------------------------------------------------------------------------
# Hooks
# ---------------------------------------------------------------------------


def decide(decision, reason):
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": decision,
        "permissionDecisionReason": reason,
    }}))


def approval_request(arguments):
    # (note, names) from the arguments after --approve
    try:
        words = shlex.split(arguments)
    except ValueError:
        return None, None
    note = None
    names = []
    index = 0
    while index < len(words):
        if words[index] == "--note" and index + 1 < len(words):
            note = words[index + 1]
            index += 2
            continue
        names.append(words[index])
        index += 1
    return note, names


def match_names(names, sites):
    # name -> its sites, plus the names nothing in the code matches
    found = {}
    missing = []
    for name in names:
        matching = [site for site in sites if (site.kind == "dynamic" and site.id == name) or (site.kind == "type" and site.value == name)]
        if len(matching) == 0:
            missing.append(name)
        else:
            found[name] = matching
    return found, missing


def hook_pre_bash(payload):
    command = payload.get("tool_input", {}).get("command", "")
    match = APPROVE_RE.search(command)
    if match is None:
        if REGISTRY_MENTION_RE.search(command) and WRITE_RE.search(command):
            decide("deny", "node-types: this command looks like it writes dev/node-types.json. Only `python3 dev/node-types.py --approve` adds to it, after asking the user.")
        return 0
    note, names = approval_request(match.group(1))
    if names is None or len(names) == 0:
        decide("deny", "node-types: pass the node types (or dynamic site ids) to approve, e.g. --approve --note \"what it models\" module-use")
        return 0
    sites = scan(working_tree_sources())
    found, missing = match_names(names, sites)
    if len(missing) > 0:
        decide("deny", "node-types: nothing in src/ creates " + ", ".join(missing) + " (run python3 dev/node-types.py to list unapproved ones)")
        return 0
    lines = []
    for name in names:
        kind = "dynamic site [" + name + "] " + found[name][0].value if found[name][0].kind == "dynamic" else "node type " + name
        lines.append(kind + ": " + places(found[name]))
    reason = "Approve new dependency graph node types? Every graph the randomizer builds and sorts gets their nodes.\n" + "\n".join(lines)
    if note is not None:
        reason += "\nWhat they model: " + note
    decide("ask", reason)
    return 0


def hook_pre_edit(payload):
    file_path = payload.get("tool_input", {}).get("file_path", "")
    if file_path and os.path.realpath(file_path) == os.path.realpath(registry_path()):
        decide("deny", "node-types: dev/node-types.json holds the user's approvals. Only `python3 dev/node-types.py --approve` adds to it, after asking the user.")
    return 0


def reported_path(session_id):
    return os.path.join(STATE_DIR, "reported", re.sub(r"[^A-Za-z0-9_-]", "_", session_id or "nosession") + ".json")


def hook_stop(payload):
    pending = unapproved(scan(working_tree_sources()), load_registry(), moved_from())
    names = pending_names(pending)
    listing = "\n".join("  " + line for line in describe(pending))
    # After a block, let the agent stop, but make sure the user sees what's pending
    if payload.get("stop_hook_active"):
        if len(pending) > 0:
            message = "Dependency graph node types awaiting your approval (dev/node-types.py):\n" + listing
            message += "\nApprove with: ! python3 dev/node-types.py --approve " + " ".join(names)
            print(json.dumps({"systemMessage": message}))
        return 0
    # Block a session once per pending name, so parallel sessions aren't stopped on every turn by one that's waiting for the user
    path = reported_path(payload.get("session_id"))
    try:
        with open(path) as f:
            reported = set(json.load(f))
    except (FileNotFoundError, ValueError):
        reported = set()
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        json.dump(names, f)
    if all(name in reported for name in names):
        return 0
    print("Unapproved dependency graph node types in the working tree (dev/node-types.py):\n" + listing + "\n\n" + INSTRUCTIONS, file=sys.stderr)
    return 2


# ---------------------------------------------------------------------------
# Command line
# ---------------------------------------------------------------------------


def approve(arguments, root=None):
    root = root or REPO
    note, names = approval_request(" ".join(shlex.quote(argument) for argument in arguments))
    if not names:
        print("Pass the node types (or dynamic site ids) to approve", file=sys.stderr)
        return 1
    sites = scan(working_tree_sources(root))
    found, missing = match_names(names, sites)
    if len(missing) > 0:
        print("Nothing in src/ creates " + ", ".join(missing), file=sys.stderr)
        return 1
    registry = load_registry(root)
    now = datetime.datetime.now().isoformat(timespec="seconds")
    for name in names:
        entry = {"approved": now}
        if note is not None:
            entry["note"] = note
        first = found[name][0]
        if first.kind == "dynamic":
            entry["file"] = first.path
            entry["expression"] = first.value
            registry["dynamic_sites"][name] = entry
        else:
            registry["types"][name] = entry
        print("approved " + ("dynamic site [" + name + "] " + first.value if first.kind == "dynamic" else "node type " + name) + ": " + places(found[name]))
    save_registry(registry, root)
    return 0


def main(argv):
    if len(argv) >= 2 and argv[0] == "--hook":
        payload = json.load(sys.stdin)
        hooks = {"pre-bash": hook_pre_bash, "pre-edit": hook_pre_edit, "stop": hook_stop}
        if argv[1] not in hooks:
            print("Unknown hook: " + argv[1], file=sys.stderr)
            return 1
        return hooks[argv[1]](payload)

    if len(argv) >= 1 and argv[0] == "--approve":
        return approve(argv[1:])

    staged = len(argv) >= 1 and argv[0] == "--staged"
    sites = scan(staged_sources() if staged else working_tree_sources())
    registry = load_registry(staged=staged)
    moves = moved_from()
    if len(argv) >= 1 and argv[0] == "--list":
        approved = [site for site in sites if is_approved(site, registry, moves)]
        lines = describe(approved)
        lines += [line + "  (UNAPPROVED)" for line in describe(unapproved(sites, registry, moves))]
        print("\n".join(sorted(lines)))
        return 0

    pending = unapproved(sites, registry, moves)
    for line in describe(pending):
        print(line)
    print(str(len(pending_names(pending))) + " unapproved node type(s) or dynamic site(s)")
    if len(pending) > 0:
        print(INSTRUCTIONS)
    return 1 if len(pending) > 0 else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

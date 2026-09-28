#!/usr/bin/env python3
# Lists the files a release of the mod ships, for prepare-release.sh
#
# A release has
#   - the files and folders the game reads by name (auxiliary/mod-structure.html in the API docs): info.json, changelog.txt, thumbnail.png, locale, migrations, scenarios, campaigns, tutorials
#   - the docs players are pointed to: README.md (the overrides setting's description points there) and OVERRIDES.md (README.md points there)
#   - the Lua files the stage files (settings.lua, data.lua, control.lua and their -updates and -final-fixes) can require
#   - the files the shipped Lua names as __propertyrandomizer__/..., like graphics
# Everything else (dev tools, notes, test configs, cost research data in lib/cost, dead code) stays out without being listed anywhere
# Files git ignores never ship
#
# Requires are followed with a Lua parser:
#   - require("a/b") or require("a.b"), looked up from the mod root and next to the requiring file (either counts)
#   - require(name .. "/a/b"), where name is a local set to a string once in the same file
#   - require("a/b/" .. anything) ships every Lua file under a/b/
#   - other mods' files (__base__/...) and the game's lualib (util, ...) are skipped
# Any other use of require is an error, since the scan can't tell what it loads; so is a require of a file that isn't there
# A __propertyrandomizer__/... name that matches no file is only a warning, since unfinished features have some
#
# Usage:
#   .venv/release/bin/python dev/release-files.py            print the release's files, one per line
#   .venv/release/bin/python dev/release-files.py --report   also print what's left out, by folder, largest first
# prepare-release.sh sets up this environment automatically.

import importlib.metadata
import os
import re
import subprocess
import sys

try:
    import tree_sitter_lua
    from tree_sitter import Language, Parser
except ImportError:
    print("release-files: missing Lua parser dependencies. Run prepare-release.sh to set up .venv/release, or install dev/release-requirements.txt with this Python's pip.", file=sys.stderr)
    sys.exit(1)

# Same known-bad version as dev/style-check.py
if importlib.metadata.version("tree-sitter").startswith("0.26."):
    print("release-files: tree-sitter 0.26 crashes on this codebase; use prepare-release.sh's .venv/release environment, or install dev/release-requirements.txt with this Python's pip.", file=sys.stderr)
    sys.exit(1)

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MOD_NAME = "propertyrandomizer"
LUALIB = "/Applications/factorio.app/Contents/data/core/lualib"
STAGE_FILES = ["settings.lua", "settings-updates.lua", "settings-final-fixes.lua", "data.lua", "data-updates.lua", "data-final-fixes.lua", "control.lua"]
GAME_FILES = ["info.json", "changelog.txt", "thumbnail.png"]
GAME_FOLDERS = ["locale/", "migrations/", "scenarios/", "campaigns/", "tutorials/"]
DOCS = ["README.md", "OVERRIDES.md"]
ASSET_NAME = re.compile(r"__" + re.escape(MOD_NAME) + r"__/(.*)")

PARSER = Parser(Language(tree_sitter_lua.language()))


def walk(node):
    # Cursor-based, as in dev/style-check.py
    cursor = node.walk()
    while True:
        yield cursor.node
        if cursor.goto_first_child():
            continue
        while not cursor.goto_next_sibling():
            if not cursor.goto_parent():
                return


class LuaFile:
    def __init__(self, path):
        self.path = path
        with open(os.path.join(REPO, path), "rb") as f:
            self.source = f.read()
        self.root = PARSER.parse(self.source).root_node
        self.constants = self.string_constants()

    def text(self, node):
        return self.source[node.start_byte:node.end_byte].decode("utf-8", errors="replace")

    def string_value(self, node):
        content = node.child_by_field_name("content")
        return self.text(content) if content is not None else ""

    def string_constants(self):
        # Names assigned a string literal exactly once in this file (local or not), so require(name .. "/x") can be followed
        values = {}
        counts = {}
        for node in walk(self.root):
            if node.type != "assignment_statement":
                continue
            variables = node.named_children[0].named_children
            expressions = node.named_children[1].named_children if len(node.named_children) > 1 else []
            for i, variable in enumerate(variables):
                if variable.type != "identifier":
                    continue
                name = self.text(variable)
                counts[name] = counts.get(name, 0) + 1
                if i < len(expressions) and expressions[i].type == "string":
                    values[name] = self.string_value(expressions[i])
        return {name: value for name, value in values.items() if counts[name] == 1}

    def concat_parts(self, node):
        # A string expression as a list of parts: literal text, or None for a part only known at runtime
        if node.type == "binary_expression" and node.child_by_field_name("operator").type == "..":
            return self.concat_parts(node.child_by_field_name("left")) + self.concat_parts(node.child_by_field_name("right"))
        if node.type == "parenthesized_expression":
            return self.concat_parts(node.named_children[0])
        if node.type == "string":
            return [self.string_value(node)]
        if node.type == "identifier" and self.text(node) in self.constants:
            return [self.constants[self.text(node)]]
        return [None]

    def requires(self):
        # Yields (line, name, is_prefix) for each require; name is None when the scan can't follow it
        for node in walk(self.root):
            if node.type != "identifier" or self.text(node) != "require":
                continue
            line = node.start_point[0] + 1
            call = node.parent
            if call.type != "function_call" or call.child_by_field_name("name") != node:
                yield line, None, False
                continue
            arguments = call.child_by_field_name("arguments").named_children
            if len(arguments) != 1:
                yield line, None, False
                continue
            parts = self.concat_parts(arguments[0])
            if None not in parts:
                yield line, "".join(parts), False
                continue
            prefix = "".join(parts[:parts.index(None)])
            yield line, (prefix if prefix != "" else None), True

    def asset_names(self):
        # Yields (line, path) for each string that names a file of this mod, like "__propertyrandomizer__/graphics/"
        for node in walk(self.root):
            if node.type == "string":
                match = ASSET_NAME.match(self.string_value(node))
                if match is not None:
                    yield node.start_point[0] + 1, match.group(1)


def candidates():
    # Files in the working tree git doesn't ignore
    listed = subprocess.run(["git", "ls-files", "-co", "--exclude-standard", "-z"], cwd=REPO, capture_output=True, check=True).stdout.decode()
    return set(path for path in listed.split("\0") if path != "" and os.path.isfile(os.path.join(REPO, path)))


def module_path(name):
    # Where require looks for a module name, relative to a folder, or None if it's another mod's file
    match = re.fullmatch(r"__(.+?)__[/.](.*)", name)
    if match is not None:
        if match.group(1) != MOD_NAME:
            return None
        name = match.group(2)
    if name.endswith(".lua"):
        name = name[:-len(".lua")]
    if "/" not in name:
        name = name.replace(".", "/")
    return name


def lookup_folders(lua_file, name):
    # A name of this mod's form (__propertyrandomizer__/x) is from the mod root; any other is tried there and next to the requiring file
    if name.startswith("__"):
        return [""]
    here = os.path.dirname(lua_file.path)
    return [""] if here == "" else ["", here + "/"]


def release_files():
    files = candidates()
    shipped = set(path for path in GAME_FILES + DOCS if path in files)
    shipped |= set(path for path in files if any(path.startswith(folder) for folder in GAME_FOLDERS))
    to_scan = [path for path in STAGE_FILES if path in files] + [path for path in shipped if path.endswith(".lua")]
    lua_paths = set(path for path in files if path.endswith(".lua"))
    errors = []
    warnings = []
    scanned = set()
    while len(to_scan) > 0:
        path = to_scan.pop()
        if path in scanned:
            continue
        scanned.add(path)
        shipped.add(path)
        lua_file = LuaFile(path)
        for line, name, is_prefix in lua_file.requires():
            where = path + ":" + str(line)
            if name is None:
                errors.append(where + ": can't tell what this require loads; use a string, or a string prefix like require(\"folder/\" .. name)")
                continue
            module = module_path(name)
            if module is None:
                continue
            folders = lookup_folders(lua_file, name)
            if is_prefix:
                found = [lua for lua in lua_paths for folder in folders if lua.startswith(os.path.normpath(folder + module) + ("/" if module.endswith("/") else ""))]
            else:
                found = [os.path.normpath(folder + module + ".lua") for folder in folders]
                found = [lua for lua in found if lua in lua_paths]
            if len(found) == 0:
                if not is_prefix and not name.startswith("__") and "/" not in module and os.path.isfile(os.path.join(LUALIB, module + ".lua")):
                    continue
                errors.append(where + ": require(\"" + name + "\"" + (" .. ..." if is_prefix else "") + ") matches no file in the mod")
            to_scan.extend(found)
        for line, asset in lua_file.asset_names():
            if asset.strip("/") == "":
                continue
            if asset in files:
                found = [asset]
            else:
                found = [other for other in files if other.startswith(asset.rstrip("/") + "/")]
            if len(found) == 0:
                warnings.append(path + ":" + str(line) + ": __" + MOD_NAME + "__/" + asset + " matches no file")
            shipped |= set(found)
            to_scan.extend(other for other in found if other.endswith(".lua"))
    return files, shipped, errors, warnings


def report(files, shipped):
    def size(paths):
        return sum(os.path.getsize(os.path.join(REPO, path)) for path in paths)

    def group(path):
        # Two folders deep: lib/cost/, notes/, CLAUDE.md
        parts = path.split("/")[:-1]
        return "/".join(parts[:2]) + "/" if len(parts) > 0 else path

    left_out = files - shipped
    groups = {}
    for path in left_out:
        groups.setdefault(group(path), []).append(path)
    print("Left out of the release:", file=sys.stderr)
    for name, paths in sorted(groups.items(), key=lambda item: -size(item[1])):
        print("  " + ("%.1f MB" % (size(paths) / 1e6)).rjust(10) + "  " + str(len(paths)).rjust(4) + " files  " + name, file=sys.stderr)
    print("Shipping " + str(len(shipped)) + " files (" + "%.1f MB" % (size(shipped) / 1e6) + "), leaving out " + str(len(left_out)) + " (" + "%.1f MB" % (size(left_out) / 1e6) + ")", file=sys.stderr)


def main(argv):
    files, shipped, errors, warnings = release_files()
    for warning in warnings:
        print("release-files: warning: " + warning, file=sys.stderr)
    if len(errors) > 0:
        for error in errors:
            print("release-files: error: " + error, file=sys.stderr)
        return 1
    if "--report" in argv:
        report(files, shipped)
    for path in sorted(shipped):
        print(path)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

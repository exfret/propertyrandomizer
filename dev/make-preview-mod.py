#!/usr/bin/env python3
# Makes a preview mod from one finished randomization: a mod that loads that game's data.raw instead of randomizing again, like py-randomized-preview
#
# The randomizer writes the finished data.raw to the log when the propertyrandomizer-dump-data-raw setting is on (the end of data-final-fixes.lua)
# The preview mod gets
#   - that data.raw, which its data-final-fixes.lua puts in place of the game's, with the randomizer's files (__propertyrandomizer__/...) pointing into the preview mod
#   - the randomizer's files that data.raw uses (its graphics)
#   - the randomizer's control stage (control.lua and every file it requires) and locale, so the randomizer panel and the on_init unlocks work
#     The startup settings the control stage reads become the values the game was made with, since the preview mod has no settings of its own
#   - every other mod whose data stage ran in that game as a dependency at its exact version (their files and prototypes are in data.raw)
#   - the randomizer as incompatible, since with both on it would randomize again and run its control stage twice
#
# Usage:
#   dev/make-preview-mod.py [options]
#     --log PATH            the log with the dump (default: factorio-current.log, else factorio-previous.log, in the folder above the mods directory)
#     --settings PATH       the mod-settings.dat the game was made with (default: the mods directory's)
#     --name NAME           the mod's name (default propertyrandomizer-duplicated-planets-preview)
#     --title TEXT          its title
#     --version X.Y.Z       its version (default 0.0.1)
#     --description TEXT    its description
#     --out DIR             where it goes (default: the mods directory)
#     --zip                 write NAME_VERSION.zip instead of a NAME folder
#     --force               replace a copy that's already there
#     --check               then create a map with it in headless Factorio (through dev/factorio_launch.py) and run some ticks

import argparse
import datetime
import importlib.util
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile

# Also when another script loads this file by path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import factorio_launch

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
USER_MODS = os.path.dirname(REPO)
USER_DIR = os.path.dirname(USER_MODS)
FACTORIO = "/Applications/factorio.app/Contents/MacOS/factorio"
GAME_DATA = "/Applications/factorio.app/Contents/data"
CHECK_DIR = os.path.join(tempfile.gettempdir(), "propertyrandomizer-preview-check")
CHECK_TICKS = 600
CHECK_TIMEOUT_SECONDS = 30 * 60

DEFAULT_NAME = "propertyrandomizer-duplicated-planets-preview"
DEFAULT_TITLE = "Duplicated Planets Randomized Preview"
DUMP_BEGIN = "__DATA_RAW_BEGIN__"
DUMP_END = "__DATA_RAW_END__"
# The dump's file in the preview mod, as its data-final-fixes.lua requires it
DUMP_MODULE = "data-raw"

with open(os.path.join(REPO, "info.json")) as f:
    SOURCE = json.load(f)
SOURCE_NAME = SOURCE["name"]
SOURCE_PREFIX = SOURCE_NAME + "-"

spec = importlib.util.spec_from_file_location("mod_settings", os.path.join(REPO, "dev", "mod-settings.py"))
mod_settings = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod_settings)

# A mod's data stage file loading, as the log has it (the settings stage's lines say "Loading mod settings NAME ...", which this skips)
LOAD_LINE = re.compile(r"Loading mod (\S+) (\d+\.\d+\.\d+) \(data(?:-updates|-final-fixes)?\.lua\)")
GAME_LINE = re.compile(r"(\d{4}-\d\d-\d\d \d\d:\d\d:\d\d); Factorio (\d+\.\d+\.\d+) \(build")
REQUIRE = re.compile(r"""\brequire\(\s*["']([^"']+)["']\s*\)""")
SETTING_READ = re.compile(r"""settings\.startup\[\s*"([^"]+)"\s*\]\.value""")
ANY_SETTING_READ = re.compile(r"""settings\.(startup|global|player)\b\s*(\[\s*(.)|.)""")
SOURCE_PATH = re.compile(r'__' + re.escape(SOURCE_NAME) + r'__/([^"\\]+)')


def read_log(path):
    # The last data.raw dump in a log, the mods whose data stage ran (name --> version, in load order) and the game's start time and version
    # The dump is None if the log has no whole one
    mods = {}
    started = None
    game = None
    dump = None
    parts = None
    # Bytes that aren't UTF-8 go through unchanged, so strings in data.raw keep their exact bytes
    with open(path, encoding="utf-8", errors="surrogateescape") as f:
        for line in f:
            if parts is not None:
                if DUMP_END in line:
                    parts.append(line.split(DUMP_END, 1)[0])
                    dump = "".join(parts).strip()
                    parts = None
                else:
                    parts.append(line)
                continue
            if DUMP_BEGIN in line:
                parts = [line.split(DUMP_BEGIN, 1)[1]]
                continue
            match = LOAD_LINE.search(line)
            if match is not None:
                mods.setdefault(match.group(1), match.group(2))
                continue
            match = GAME_LINE.search(line)
            if match is not None and game is None:
                started = match.group(1)
                game = match.group(2)
    return dump, mods, started, game


def find_dump(log_path):
    # (log path, dump, mods, start time, game version) from the given log, or from the newest of the game's logs with a dump
    candidates = [log_path] if log_path is not None else [os.path.join(USER_DIR, "factorio-current.log"), os.path.join(USER_DIR, "factorio-previous.log")]
    for path in candidates:
        if not os.path.isfile(path):
            continue
        dump, mods, started, game = read_log(path)
        if dump is not None:
            return path, dump, mods, started, game
    raise SystemExit("No data.raw dump in " + " or ".join(candidates) + ": load the game with the setting " + SOURCE_PREFIX + "dump-data-raw on, then run this before Factorio starts twice more (each start moves the log to factorio-previous.log)")


def read_settings(path):
    # Startup setting name --> value from a mod-settings.dat
    _, tree = mod_settings.load(path)
    return {name: mod_settings.setting_value(setting)[1] for name, setting in mod_settings.startup_settings(tree)}


def lua_literal(value):
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, int):
        return str(value)
    if isinstance(value, float):
        if value != value:
            return "(0/0)"
        if value in (float("inf"), float("-inf")):
            return "(1/0)" if value > 0 else "(-1/0)"
        return repr(value)
    if isinstance(value, str):
        escaped = []
        for char in value:
            if char in "\\\"":
                escaped.append("\\" + char)
            elif char == "\n":
                escaped.append("\\n")
            elif ord(char) < 32 or ord(char) == 127:
                escaped.append("\\" + format(ord(char), "03d"))
            else:
                escaped.append(char)
        return '"' + "".join(escaped) + '"'
    raise SystemExit("Can't write " + repr(value) + " as Lua")


def module_path(module):
    # The file a require of this module name loads, relative to its mod
    if module.endswith(".lua"):
        module = module[:-4]
    return module.replace(".", "/") + ".lua"


def control_files():
    # control.lua and every file of this mod it requires, directly or through others (requires are literal, see CLAUDE.md)
    seen = set()
    stack = ["control.lua"]
    while stack:
        rel = stack.pop()
        if rel in seen:
            continue
        seen.add(rel)
        with open(os.path.join(REPO, rel), encoding="utf-8") as f:
            text = f.read()
        for module in REQUIRE.findall(text):
            if module.startswith("__"):
                if module.startswith("__" + SOURCE_NAME + "__"):
                    raise SystemExit(rel + " requires " + module + " by mod name, which the preview mod would need rewritten")
                continue
            path = module_path(module)
            if os.path.isfile(os.path.join(REPO, path)):
                stack.append(path)
            elif not os.path.isfile(os.path.join(GAME_DATA, "core", "lualib", path)):
                raise SystemExit(rel + " requires " + module + ", which is neither in " + REPO + " nor in core's lualib")
    return sorted(seen)


def bake_settings(rel, text, values, baked):
    # The text with each read of this mod's startup settings replaced by the value the game was made with
    def replace(match):
        name = match.group(1)
        if not name.startswith(SOURCE_PREFIX):
            return match.group(0)
        if name not in values:
            raise SystemExit(rel + " reads the startup setting " + name + ", which the settings file doesn't have")
        baked[name] = values[name]
        return lua_literal(values[name])
    text = SETTING_READ.sub(replace, text)
    # Any read left is one the preview mod can't answer: a runtime setting, or a startup one by a name built at runtime or read without .value
    for match in ANY_SETTING_READ.finditer(text):
        kind, key_start = match.group(1), match.group(3)
        line = text.count("\n", 0, match.start()) + 1
        if kind != "startup" or key_start != '"':
            raise SystemExit(rel + ":" + str(line) + " reads a setting the preview mod can't fix in place: " + text[match.start():match.start() + 80].split("\n")[0])
        key = text[match.end():].split('"', 1)[0]
        if key.startswith(SOURCE_PREFIX):
            raise SystemExit(rel + ":" + str(line) + " reads " + key + " in a form this script doesn't replace: " + text[match.start():match.start() + 80].split("\n")[0])
    return text


def git_description():
    try:
        commit = subprocess.run(["git", "-C", REPO, "rev-parse", "--short", "HEAD"], capture_output=True, text=True, check=True).stdout.strip()
        dirty = subprocess.run(["git", "-C", REPO, "status", "--porcelain", "--untracked-files=no"], capture_output=True, text=True, check=True).stdout.strip() != ""
    except (OSError, subprocess.CalledProcessError):
        return "an unknown commit"
    return "commit " + commit + (" with uncommitted changes" if dirty else "")


def is_builtin(name):
    return os.path.isfile(os.path.join(GAME_DATA, name, "info.json"))


def build(staging, args, log_path, dump, mods, started, values):
    # Writes the preview mod's files into staging; returns what goes in the summary
    referenced = sorted(set(SOURCE_PATH.findall(dump)))
    missing = [rel for rel in referenced if not os.path.isfile(os.path.join(REPO, rel))]
    if missing:
        raise SystemExit("data.raw uses " + str(len(missing)) + " files that aren't in " + REPO + ", e.g. " + ", ".join(missing[:10]))
    dump = dump.replace("__" + SOURCE_NAME + "__/", "__" + args.name + "__/")
    num_left = dump.count("__" + SOURCE_NAME + "__")
    if num_left > 0:
        index = dump.index("__" + SOURCE_NAME + "__")
        raise SystemExit("data.raw names " + SOURCE_NAME + " by its mod name " + str(num_left) + " times outside file paths, e.g. ..." + dump[max(0, index - 80):index + 80] + "...")

    # data.raw and what puts it in place
    with open(os.path.join(staging, DUMP_MODULE + ".lua"), "w", encoding="utf-8", errors="surrogateescape") as f:
        f.write(dump + "\n")
    with open(os.path.join(staging, "data-final-fixes.lua"), "w") as f:
        f.write("-- Made by " + SOURCE_NAME + "'s dev/make-preview-mod.py: the finished data.raw of one randomization (" + DUMP_MODULE + ".lua), put in place of the game's, so this game loads without randomizing again\n")
        f.write("-- Data-final-fixes, after every other mod's data stage, since data.raw already has what they added\n")
        f.write("data.raw = require(\"" + DUMP_MODULE + "\")\n")

    # The randomizer's files that data.raw uses
    num_bytes = 0
    for rel in referenced:
        os.makedirs(os.path.join(staging, os.path.dirname(rel)), exist_ok=True)
        shutil.copy2(os.path.join(REPO, rel), os.path.join(staging, rel))
        num_bytes += os.path.getsize(os.path.join(REPO, rel))

    # The control stage, with its startup settings fixed to the game's
    baked = {}
    files = control_files()
    for rel in files:
        with open(os.path.join(REPO, rel), encoding="utf-8") as f:
            text = f.read()
        text = bake_settings(rel, text, values, baked)
        os.makedirs(os.path.join(staging, os.path.dirname(rel)), exist_ok=True)
        with open(os.path.join(staging, rel), "w", encoding="utf-8") as f:
            f.write(text)
    shutil.copytree(os.path.join(REPO, "locale"), os.path.join(staging, "locale"))
    if os.path.isfile(os.path.join(REPO, "thumbnail.png")):
        shutil.copy2(os.path.join(REPO, "thumbnail.png"), os.path.join(staging, "thumbnail.png"))

    dependencies = [name + " = " + version for name, version in mods.items() if name not in ("core", SOURCE_NAME)]
    description = args.description or ("Hardcoded results of one randomization made with " + SOURCE["title"] + " " + SOURCE["version"] + ", loaded as it was made instead of randomizing again.")
    info = {
        "name": args.name,
        "version": args.version,
        "title": args.title,
        "author": SOURCE.get("author", ""),
        "factorio_version": SOURCE["factorio_version"],
        "description": description,
        "dependencies": dependencies + ["! " + SOURCE_NAME],
    }
    with open(os.path.join(staging, "info.json"), "w") as f:
        json.dump(info, f, indent="\t")
        f.write("\n")

    with open(os.path.join(staging, "README.md"), "w") as f:
        f.write("# " + args.title + "\n\n")
        f.write(description + "\n\n")
        f.write("Made by " + SOURCE_NAME + "'s dev/make-preview-mod.py on " + datetime.date.today().isoformat() + " from " + os.path.basename(log_path) + " (the game started " + str(started) + "), with " + SOURCE["title"] + " " + SOURCE["version"] + " at " + git_description() + ".\n\n")
        f.write(DUMP_MODULE + ".lua is that game's finished data.raw, and data-final-fixes.lua puts it in place of the game's. The randomizer's control stage and locale come along for the randomizer panel; the startup settings it reads are fixed to the values below.\n\n")
        f.write("## Settings it was made with\n\n")
        for name in sorted(values):
            if name.startswith(SOURCE_PREFIX):
                f.write("- " + name + " = " + json.dumps(values[name]) + "\n")
    return {"dependencies": dependencies, "baked": baked, "num_files": len(referenced), "num_bytes": num_bytes, "num_control": len(files), "dump_bytes": len(dump)}


def write_zip(staging, target, top):
    with zipfile.ZipFile(target, "w", zipfile.ZIP_DEFLATED) as archive:
        for root, _, names in os.walk(staging):
            for name in sorted(names):
                path = os.path.join(root, name)
                archive.write(path, os.path.join(top, os.path.relpath(path, staging)))


def find_installed(name, version):
    # A copy of a mod at exactly this version in the user's mods directory: NAME_VERSION.zip, a NAME_VERSION folder, or a NAME folder whose info.json has the version
    for candidate in (name + "_" + version + ".zip", name + "_" + version, name):
        path = os.path.join(USER_MODS, candidate)
        if candidate.endswith(".zip"):
            if os.path.isfile(path):
                return path
            continue
        try:
            with open(os.path.join(path, "info.json")) as f:
                if json.load(f).get("version") == version:
                    return path
        except (OSError, ValueError):
            continue
    return None


def run_factorio(args, log_path):
    with open(log_path, "w") as log_file:
        with factorio_launch.started(args, stdout=log_file, stderr=subprocess.STDOUT) as proc:
            try:
                return proc.wait(timeout=CHECK_TIMEOUT_SECONDS)
            except subprocess.TimeoutExpired:
                proc.kill()
                proc.wait()
                return "timeout after " + str(CHECK_TIMEOUT_SECONDS // 60) + " minutes"


def error_lines(log_path):
    with open(log_path, encoding="utf-8", errors="replace") as f:
        return [line.rstrip("\n")[:300] for line in f if re.search(r"\b(Error|error|failed)\b", line)][:20]


def check(mod_path, name, mods):
    # Creates a map with the preview mod and runs some ticks, in a headless Factorio with its own mod and write-data directories; returns whether both worked
    os.makedirs(CHECK_DIR, exist_ok=True)
    run_dir = tempfile.mkdtemp(prefix="run-" + datetime.datetime.now().strftime("%Y%m%d-%H%M%S") + "-", dir=CHECK_DIR)
    mods_dir = os.path.join(run_dir, "mods")
    data_dir = os.path.join(run_dir, "data")
    os.makedirs(mods_dir)
    os.makedirs(data_dir)
    os.symlink(mod_path, os.path.join(mods_dir, os.path.basename(mod_path)))
    mod_list = [{"name": "base", "enabled": True}]
    for dep_name, dep_version in mods.items():
        if dep_name in ("core", "base", SOURCE_NAME):
            continue
        if not is_builtin(dep_name):
            path = find_installed(dep_name, dep_version)
            if path is None:
                raise SystemExit("The check needs " + dep_name + " " + dep_version + ", which isn't in " + USER_MODS)
            os.symlink(path, os.path.join(mods_dir, os.path.basename(path)))
        mod_list.append({"name": dep_name, "enabled": True})
    # Built-in mods the game didn't load stay off
    for builtin in sorted(os.listdir(GAME_DATA)):
        if builtin not in mods and builtin != "core" and is_builtin(builtin):
            mod_list.append({"name": builtin, "enabled": False})
    mod_list.append({"name": name, "enabled": True})
    with open(os.path.join(mods_dir, "mod-list.json"), "w") as f:
        json.dump({"mods": mod_list}, f, indent=2)
    config_path = os.path.join(run_dir, "config.ini")
    with open(config_path, "w") as f:
        f.write("[path]\nread-data=__PATH__executable__/../data\nwrite-data=" + data_dir + "\n")
    base_args = [FACTORIO, "-c", config_path, "--mod-directory", mods_dir]
    save = os.path.join(run_dir, "save.zip")

    print("Checking in " + run_dir + ": creating a map")
    create_log = os.path.join(run_dir, "create.log")
    code = run_factorio(base_args + ["--create", save], create_log)
    ok = code == 0
    if not ok:
        print("Map creation failed (exit " + str(code) + "), see " + create_log)
        for line in error_lines(create_log):
            print("  " + line)
    else:
        print("Running " + str(CHECK_TICKS) + " ticks")
        control_log = os.path.join(run_dir, "control.log")
        code = run_factorio(base_args + ["--benchmark", save, "--benchmark-ticks", str(CHECK_TICKS)], control_log)
        with open(control_log, encoding="utf-8", errors="replace") as f:
            ran = re.search(r"Performed " + str(CHECK_TICKS) + r" updates", f.read()) is not None
        ok = code == 0 and ran
        if not ok:
            print("The control stage failed (exit " + str(code) + (", no tick report" if not ran else "") + "), see " + control_log)
            for line in error_lines(control_log):
                print("  " + line)
    # Keep the logs; the write-data directory holds caches and a copy of the log
    shutil.rmtree(data_dir, ignore_errors=True)
    if ok:
        os.remove(save)
        print("Check passed (logs in " + run_dir + ")")
    return ok


def main():
    parser = argparse.ArgumentParser(description="Makes a mod that loads one finished randomization's data.raw instead of randomizing again")
    parser.add_argument("--log", help="the log with the dump (default: factorio-current.log, else factorio-previous.log)")
    parser.add_argument("--settings", default=os.path.join(USER_MODS, "mod-settings.dat"), help="the mod-settings.dat the game was made with")
    parser.add_argument("--name", default=DEFAULT_NAME, help="the mod's name")
    parser.add_argument("--title", default=DEFAULT_TITLE, help="its title")
    parser.add_argument("--version", default="0.0.1", help="its version")
    parser.add_argument("--description", help="its description")
    parser.add_argument("--out", default=USER_MODS, help="where it goes")
    parser.add_argument("--zip", action="store_true", help="write NAME_VERSION.zip instead of a NAME folder")
    parser.add_argument("--force", action="store_true", help="replace a copy that's already there")
    parser.add_argument("--check", action="store_true", help="then create a map with it in headless Factorio and run some ticks")
    args = parser.parse_args()
    if re.fullmatch(r"\d+\.\d+\.\d+", args.version) is None:
        raise SystemExit("The version must be X.Y.Z")
    if args.name == SOURCE_NAME:
        raise SystemExit("The preview mod needs a name of its own")

    os.makedirs(args.out, exist_ok=True)
    target = os.path.join(args.out, args.name + "_" + args.version + ".zip" if args.zip else args.name)
    if os.path.lexists(target) and not args.force:
        raise SystemExit(target + " is already there (--force replaces it)")

    log_path, dump, mods, started, game = find_dump(args.log)
    if not (dump.startswith("do local _=") and dump.endswith("return _;end")):
        raise SystemExit("The dump in " + log_path + " doesn't look like serpent.dump's output (do local _=... return _;end)")
    if SOURCE_NAME not in mods:
        raise SystemExit("The game in " + log_path + " didn't load " + SOURCE_NAME)
    if mods[SOURCE_NAME] != SOURCE["version"]:
        print("Note: the game was made with " + SOURCE_NAME + " " + mods[SOURCE_NAME] + ", and its control stage comes from this folder's " + SOURCE["version"])
    values = read_settings(args.settings)
    print("Dump from " + log_path + " (Factorio " + str(game) + ", started " + str(started) + "): " + format(len(dump) / 1e6, ".1f") + " MB")

    staging = tempfile.mkdtemp(prefix=".preview-", dir=args.out if not args.zip else None)
    try:
        summary = build(staging, args, log_path, dump, mods, started, values)
        if args.zip:
            partial = target + ".partial"
            write_zip(staging, partial, args.name + "_" + args.version)
            if os.path.lexists(target):
                os.remove(target)
            os.replace(partial, target)
        else:
            if os.path.lexists(target):
                shutil.rmtree(target)
            os.replace(staging, target)
            staging = None
    finally:
        if staging is not None:
            shutil.rmtree(staging, ignore_errors=True)

    print("Wrote " + target)
    print("  data.raw: " + format(summary["dump_bytes"] / 1e6, ".1f") + " MB; " + str(summary["num_files"]) + " of " + SOURCE_NAME + "'s files it uses (" + format(summary["num_bytes"] / 1e6, ".1f") + " MB)")
    print("  control stage: " + str(summary["num_control"]) + " files; startup settings fixed: " + ", ".join(name + " = " + json.dumps(value) for name, value in sorted(summary["baked"].items())))
    print("  dependencies: " + ", ".join(summary["dependencies"]) + "; incompatible with " + SOURCE_NAME)
    print("  Enable it with " + SOURCE_NAME + " off (they're incompatible), and every dependency above at that exact version")
    if args.check and not check(target, args.name, mods):
        sys.exit(1)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
# Headless test suites: runs Factorio over many settings configs and mod sets, and checks each run
#
# A run passes when
#   - creating a map works (the data stage, randomization included, then on_init)
#   - the game used the settings the config asked for
#   - the randomizer panel wouldn't warn about a softlock: every science pack reachable before randomization still is (the check at the end of data-final-fixes.lua)
#   - the MECHCHECK verdict (randomizations/graph/unified/skeleton/check.lua) is ok: no recipe became unreachable and no mechanic context was lost beyond isolatability
#   - the new map runs some ticks without errors (the control stage)
# Configs matching an oldlogic line in tests/configs.txt (for now, old item randomization) are judged by the old logic's check of the built game (OLDLOGICCHECK) instead of the two reachability checks
# Both reachability checks compare against the game after planetary randomization, whose own changes are checked by PLANETCHECK (randomizations/planetary/check.lua)
#
# Configs and suites are described in tests/configs.txt, and mod sets are the mod lists in tests/mod-configs; every config runs on every mod set, unless a limit line in tests/configs.txt narrows a mod set
# A mod set's file can also give other mods' startup settings, as "settings": {"aps-planet": "gleba"} next to "mods" (a double setting's value needs a decimal point, like 1.0); the runner checks the game used them
# Other mods a mod set enables are the newest copies in the user's mods directory made for this game version
# The mod is snapshotted when the run starts, so edits made during a long run don't mix in
# Each Factorio process gets its own mod and write-data directories, so this works while the game or other runs are open
# The test helper mod (dev/test-helper-mod) unhides hidden settings and logs what the checks read
# With recipe randomization on, science costs are checked immediately before/after
# recipes and recycling, before item/numerical changes: each pack <=4x, mean ratio <2x.
# Both measurements use the old randomizer's global production-cost model.
# Every science pack needs a baseline price; missing prices fail coverage.
#
# Usage:
#   dev/run-tests.py [SUITE...]      run these suites (smoke, settings, unified); all of them by default
#     --list                         print the planned runs without running anything
#     --only TEXT                    only runs whose name (mod set/config) contains TEXT (can repeat; any match)
#     --modset NAME                  only this mod set, e.g. base or sa (can repeat); a mod set named here runs every config, even with a limit line
#     --jobs N                       parallel Factorio processes (default 3; a Space Age run takes a couple GB of memory; an agent session runs at most 2 at once, see dev/factorio_launch.py)
#     --tier NAME                    only the runs in this tier from tests/configs.txt (e.g. precommit)
#     --ref GIT_REF                  test a committed version (e.g. v0.5.5) instead of the working tree
#     --staged                       test the staged files, which is what a commit would contain (for dev/git-hooks/pre-commit)
#     --dir PATH                     test a mod folder outside git, like the release prepare-release.sh builds
#     --seed-offset N                shift every seed, to try the same configs on other seeds
#     --profile                      sample the Lua stack while each map is created (dev/profiler-mod in Instrument Mode) and write where the time went to profile.txt in its log folder (dev/profile-report.py); loads run a little slower
#     --dump-data                    also dump each run's data.raw (Factorio's --dump-data, one more load) to data-raw-dump.json in its log folder, and print its SHA-256, to check that two versions build the same game

import argparse
import concurrent.futures
import ctypes
import ctypes.util
import fcntl
import fnmatch
import hashlib
import importlib.util
import itertools
import json
import math
import os
import random
import re
import shutil
import subprocess
import sys
import tempfile
import threading
import time
import zipfile
import zlib

# Also when another script loads this file by path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import factorio_launch

REPO =os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FACTORIO = "/Applications/factorio.app/Contents/MacOS/factorio"
GAME_DATA = "/Applications/factorio.app/Contents/data"
# Other mods a mod set enables are linked from the user's mods directory
USER_MODS = os.path.dirname(REPO)
MOD_NAME = "propertyrandomizer"
PREFIX = MOD_NAME + "-"
HELPER_MOD = os.path.join(REPO, "dev", "test-helper-mod")
HELPER_NAME = "propertyrandomizer-test-helper"
PROFILER_MOD = os.path.join(REPO, "dev", "profiler-mod")
PROFILER_NAME = "propertyrandomizer-profiler"
CONFIGS = os.path.join(REPO, "tests", "configs.txt")
MOD_CONFIGS = os.path.join(REPO, "tests", "mod-configs")
DUMP_SETTINGS = os.path.join(REPO, "dev", "dump-settings.lua")
CACHE_DIR = os.path.join(tempfile.gettempdir(), "propertyrandomizer-run-tests")
# Lock on this process's run directory, so another run doesn't prune it
ROOT_LOCK = None

SUITES = ["smoke", "settings", "unified"]
# Checks a hand-picked config can turn off with nocheck=
OPTIONAL_CHECKS = ["reachability", "mechcheck", "control", "science-cost"]
UNIFIED_SEEDS = [1, 2, 3, 4]
CONTROL_TICKS = 600
# A run with every setting on takes about 5 minutes on an unloaded machine
TIMEOUT_SECONDS = 45 * 60
# Candidate configs tried for each pairwise config; more gives fewer configs but plans slower
PAIRWISE_CANDIDATES = 30

# The user's guidance on failures, as in dev/check-seeds.py and CLAUDE.md
FAILURE_GUIDANCE = (
    "Some failing seeds and configs are expected while the randomizer is in development; up to 30-50% of seeds failing is acceptable."
    " But a seed whose MECHCHECK verdict FAILED (an unreachable recipe, or a mechanic context lost beyond isolatability) is a softlock, which is never acceptable on any seed: fix the model that allowed it."
    " Don't overfit on making every run pass. Look into a failure when your change could have caused it (compare with --ref HEAD if unsure), and fix it only at its root cause."
    " Don't add hotfixes or special cases to get a run through: a patch that quietly breaks something else is worse than a failing run."
)

# The end-of-load check's verdict, which leaves out losses that only affect isolatability (those are acceptable)
VERDICT = re.compile(r"MECHCHECK verdict: (ok|FAILED) (\(.*\))")
SETTING_LINE = re.compile(r"PRTEST setting (\S+) = (.*)$", re.MULTILINE)
REACHABILITY = re.compile(r"PRTEST reachability (\d+) of (\d+)")
OLD_LOGIC_CHECK = re.compile(r"OLDLOGICCHECK science packs reachable (\d+) of (\d+)(?:; lost (.*))?")
SCIENCE_COST = re.compile(r"SCIENCECOST\t(before|after)\t([^\t\r\n]+)\t([^\r\n]+)")
GAME_VERSION = re.compile(r"Factorio (\d+)\.(\d+)\.(\d+) \(build")

spec = importlib.util.spec_from_file_location("mod_settings", os.path.join(REPO, "dev", "mod-settings.py"))
mod_settings = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod_settings)
spec = importlib.util.spec_from_file_location("profile_report", os.path.join(REPO, "dev", "profile-report.py"))
profile_report = importlib.util.module_from_spec(spec)
spec.loader.exec_module(profile_report)

DAT_TYPES = {
    "bool-setting": mod_settings.BOOL,
    "int-setting": mod_settings.SIGNED,
    "double-setting": mod_settings.NUMBER,
    "string-setting": mod_settings.STRING,
}
# For other mods' settings in a mod set file, from the JSON value's type (bool before int, since a bool is an int in Python)
JSON_DAT_TYPES = [(bool, mod_settings.BOOL), (int, mod_settings.SIGNED), (float, mod_settings.NUMBER), (str, mod_settings.STRING)]


def fmt(value):
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, float):
        return "%g" % value
    return str(value)


class Setting:
    # One of the mod's settings, from a line of dev/dump-settings.lua; name is without the prefix
    def __init__(self, fields):
        full_name, self.type, default, hidden, allowed, minimum, maximum = fields
        self.name = full_name[len(PREFIX):]
        self.hidden = hidden == "true"
        self.allowed = allowed.split(",") if allowed != "" else None
        self.minimum = self.parse(minimum) if minimum != "" else None
        self.maximum = self.parse(maximum) if maximum != "" else None
        self.default = self.parse(default)

    def parse(self, text):
        if self.type == "bool-setting":
            if text not in ("true", "false"):
                raise ValueError(self.name + " is a bool setting; expected true or false, got " + repr(text))
            return text == "true"
        if self.type == "int-setting":
            return int(float(text))
        if self.type == "double-setting":
            return float(text)
        if self.allowed is not None and text not in self.allowed:
            raise ValueError(self.name + " must be one of " + ",".join(self.allowed) + ", got " + repr(text))
        return text

    def values(self):
        # The finite set of values generated configs pick from, or None if there isn't one
        if self.type == "bool-setting":
            return [False, True]
        if self.allowed is not None:
            return list(self.allowed)
        if self.minimum is None or self.maximum is None:
            return None
        if self.type == "double-setting":
            values = [self.minimum, (self.minimum + self.maximum) / 2, self.maximum]
        else:
            values = [self.minimum, self.maximum]
        return list(dict.fromkeys(values))


class TestFile:
    # tests/configs.txt
    def __init__(self):
        self.wip = set()
        self.skip = set()
        self.requires = {}
        # (setting, value text, suite or config names): configs in one of these suites or with one of these names get this setting's value
        self.pins = []
        self.configs = []
        # Tier name -> run name patterns
        self.tiers = {}
        # (mod set pattern, config name patterns): mod sets matching the first only run configs matching one of the others
        self.limits = []
        # (setting, value text): configs with one of these are judged by the old logic's check instead of the reachability checks
        self.old_logic = []
        with open(CONFIGS) as f:
            for number, raw in enumerate(f, 1):
                line = re.sub(r"(^|\s)#.*$", "", raw).strip()
                if line == "":
                    continue
                words = line.split()
                if words[0] == "wip" and len(words) == 2:
                    self.wip.add(words[1])
                elif words[0] == "skip" and len(words) == 2:
                    self.skip.add(words[1])
                elif words[0] == "tier" and len(words) >= 3:
                    self.tiers[words[1]] = words[2:]
                elif words[0] == "limit" and len(words) >= 3:
                    self.limits.append((words[1], words[2:]))
                elif words[0] == "oldlogic" and len(words) == 2 and "=" in words[1]:
                    self.old_logic.append(tuple(words[1].split("=", 1)))
                elif words[0] == "requires" and len(words) == 3 and "=" in words[2]:
                    self.requires[words[1]] = tuple(words[2].split("=", 1))
                elif words[0] == "pin" and len(words) >= 3 and "=" in words[1]:
                    name, text = words[1].split("=", 1)
                    self.pins.append((name, text, set(words[2:])))
                elif words[0] == "config" and len(words) >= 3:
                    seeds = None
                    nocheck = set()
                    assignments = {}
                    for word in words[3:]:
                        if "=" not in word:
                            raise SystemExit(CONFIGS + ":" + str(number) + ": expected SETTING=VALUE, got " + word)
                        name, text = word.split("=", 1)
                        if name == "seeds":
                            seeds = [int(seed) for seed in text.split(",")]
                        elif name == "nocheck":
                            nocheck = set(text.split(","))
                            if not nocheck <= set(OPTIONAL_CHECKS):
                                raise SystemExit(CONFIGS + ":" + str(number) + ": nocheck takes " + ", ".join(OPTIONAL_CHECKS))
                        else:
                            assignments[name] = text
                    self.configs.append({"name": words[1], "suite": words[2], "seeds": seeds, "nocheck": nocheck, "settings": assignments, "line": number})
                else:
                    raise SystemExit(CONFIGS + ":" + str(number) + ": can't read this line: " + line)

    def runs_config(self, modset, config_name):
        # Whether a limit line keeps this mod set from running this config
        limits = [patterns for pattern, patterns in self.limits if fnmatch.fnmatchcase(modset, pattern)]
        return len(limits) == 0 or any(fnmatch.fnmatchcase(config_name, pattern) for patterns in limits for pattern in patterns)


class Config:
    def __init__(self, suite, name, settings, seed, nocheck, old_logic):
        self.suite = suite
        self.name = name
        # Setting name -> value, only for settings that aren't at their default
        self.settings = settings
        self.seed = seed
        # Checks from OPTIONAL_CHECKS this config skips
        self.nocheck = nocheck
        # Whether it's judged by the old logic's check instead of the reachability checks (an oldlogic line in tests/configs.txt)
        self.old_logic = old_logic

    def describe(self):
        parts = ["seed=" + str(self.seed)] + [name + "=" + fmt(value) for name, value in self.settings.items()]
        if len(self.nocheck) > 0:
            parts.append("nocheck=" + ",".join(sorted(self.nocheck)))
        if self.old_logic:
            parts.append("check=old-logic")
        return " ".join(parts)


class Plan:
    # Every config, from the mod copy's settings and tests/configs.txt
    def __init__(self, settings, test_file, seed_offset):
        self.settings = settings
        self.test_file = test_file
        self.seed_offset = seed_offset
        self.notes = []
        coverable = [setting for setting in settings.values() if setting.name not in test_file.skip and setting.values() is not None]
        self.visible = [setting for setting in coverable if not setting.hidden]
        self.unified = [setting for setting in coverable if setting.hidden and setting.name.startswith("unified-")]
        covered = set(setting.name for setting in self.visible + self.unified)
        self.skipped = [name for name in settings if name in test_file.skip]
        self.no_values = [name for name, setting in settings.items() if name not in test_file.skip and setting.values() is None]
        self.left_out = [name for name, setting in settings.items() if name not in covered and name not in self.skipped and name not in self.no_values]
        self.configs = []
        self.generate()
        self.add_hand_picked()

    def seed(self, name):
        # Stable per config name, so a config keeps its seed when others are added
        return zlib.crc32(name.encode()) % 1000 + self.seed_offset

    def add(self, suite, name, values, seeds=None, nocheck=frozenset()):
        values = self.with_requirements(values)
        for pinned, text, names in self.test_file.pins:
            if suite in names or name in names:
                if pinned not in self.settings:
                    self.notes.append("didn't pin " + pinned + " in " + name + ": this version has no such setting")
                    continue
                values[pinned] = self.settings[pinned].parse(text)
        values = {key: value for key, value in values.items() if value != self.settings[key].default}
        old_logic = any(setting in values and values[setting] == self.settings[setting].parse(text) for setting, text in self.test_file.old_logic if setting in self.settings)
        for seed in seeds if seeds is not None else [None]:
            if seed is None:
                self.configs.append(Config(suite, name, values, self.seed(name), nocheck, old_logic))
            else:
                self.configs.append(Config(suite, name + "@" + str(seed), values, seed + self.seed_offset, nocheck, old_logic))

    def forced(self, name, value):
        # The (setting, value) that choosing this value forces through a requires line, or None
        if name not in self.test_file.requires or value == self.settings[name].default:
            return None
        other, text = self.test_file.requires[name]
        if other not in self.settings:
            return None
        return other, self.settings[other].parse(text)

    def with_requirements(self, values):
        result = dict(values)
        for name, value in values.items():
            forced = self.forced(name, value)
            if forced is not None:
                result[forced[0]] = forced[1]
        return result

    def generate(self):
        self.add("smoke", "defaults", {})
        top = {setting.name: setting.values()[-1] for setting in self.visible}
        self.add("smoke", "max", top)
        for setting in self.visible:
            for value in setting.values():
                if value != setting.default:
                    self.add("settings", "single-" + setting.name + "=" + fmt(value), {setting.name: value})
        rows = self.pairwise(self.visible, random.Random(23))
        for i, row in enumerate(rows):
            self.add("settings", "pairwise-" + str(i + 1).zfill(2), row)
        # No single-setting unified configs: while dev-unified is on, randomizations/graph/unified/execute.lua runs its own handler list whatever the unified-* settings say, so they'd only repeat unified-all on other seeds
        all_unified = {setting.name: True for setting in self.unified if setting.type == "bool-setting"}
        if len(all_unified) > 0:
            self.add("unified", "unified-all", all_unified, seeds=UNIFIED_SEEDS)

    def pairwise(self, settings, rng):
        # Greedy covering array: configs until every pair of values of two different settings is in some config
        names = [setting.name for setting in settings]
        values = {setting.name: setting.values() for setting in settings}
        index = {name: i for i, name in enumerate(names)}

        def key(a, value_a, b, value_b):
            if index[a] < index[b]:
                return (a, value_a, b, value_b)
            return (b, value_b, a, value_a)

        def possible(a, value_a, b, value_b):
            for x, value_x, y, value_y in ((a, value_a, b, value_b), (b, value_b, a, value_a)):
                forced = self.forced(x, value_x)
                if forced is not None and forced[0] == y and forced[1] != value_y:
                    return False
            return True

        uncovered = set()
        for a, b in itertools.combinations(names, 2):
            for value_a in values[a]:
                for value_b in values[b]:
                    if possible(a, value_a, b, value_b):
                        uncovered.add(key(a, value_a, b, value_b))
        rows = []
        while len(uncovered) > 0:
            # Sets of mixed values iterate in a per-process order, so sort for the same configs every time
            pool = sorted(uncovered, key=repr)
            best_row = None
            best_new = set()
            for _ in range(PAIRWISE_CANDIDATES):
                a, value_a, b, value_b = rng.choice(pool)
                row = {a: value_a, b: value_b}
                rest = [name for name in names if name not in row]
                rng.shuffle(rest)
                for name in rest:
                    best_score = -1
                    choices = []
                    for value in values[name]:
                        score = sum(1 for other, other_value in row.items() if key(name, value, other, other_value) in uncovered)
                        if score > best_score:
                            best_score = score
                            choices = [value]
                        elif score == best_score:
                            choices.append(value)
                    # On a tie, the default keeps configs cheap: every setting on is slower to randomize
                    default = self.settings[name].default
                    row[name] = default if default in choices else rng.choice(choices)
                row = self.with_requirements(row)
                new = set(key(a, row[a], b, row[b]) for a, b in itertools.combinations(names, 2)) & uncovered
                if len(new) > len(best_new):
                    best_row = row
                    best_new = new
            if len(best_new) == 0:
                break
            rows.append(best_row)
            uncovered -= best_new
        return rows

    def add_hand_picked(self):
        for config in self.test_file.configs:
            values = {}
            unknown = [name for name in config["settings"] if name not in self.settings]
            if len(unknown) > 0:
                self.notes.append("skipped config " + config["name"] + ": this version has no setting " + ", ".join(unknown))
                continue
            for name, text in config["settings"].items():
                try:
                    values[name] = self.settings[name].parse(text)
                except ValueError as error:
                    raise SystemExit(CONFIGS + ":" + str(config["line"]) + ": " + str(error))
            self.add(config["suite"], config["name"], values, seeds=config["seeds"], nocheck=config["nocheck"])


class Run:
    def __init__(self, config, modset):
        self.config = config
        self.modset = modset
        self.name = modset + "/" + config.name
        self.slug = re.sub(r"[^A-Za-z0-9._@=+-]+", "_", modset + "--" + config.name)


class Processes:
    # Running Factorio processes, so Ctrl-C can stop all of them
    # (factorio_launch kills them if this script is killed some other way, and limits how many an agent session runs)
    def __init__(self):
        self.lock = threading.Lock()
        self.running = set()
        self.stopping = False

    def run(self, args, log_path):
        with open(log_path, "w") as log_file:
            with factorio_launch.started(args, cancelled=lambda: self.stopping, stdout=log_file, stderr=subprocess.STDOUT) as proc:
                with self.lock:
                    if proc is None or self.stopping:
                        return "stopped"
                    self.running.add(proc)
                try:
                    return proc.wait(timeout=TIMEOUT_SECONDS)
                except subprocess.TimeoutExpired:
                    proc.kill()
                    proc.wait()
                    return "timeout after " + str(TIMEOUT_SECONDS // 60) + " minutes"
                finally:
                    with self.lock:
                        self.running.discard(proc)

    def stop(self):
        with self.lock:
            self.stopping = True
            for proc in self.running:
                proc.kill()


def libc_clonefile():
    path = ctypes.util.find_library("c")
    if path is None:
        return None
    return getattr(ctypes.CDLL(path), "clonefile", None)


CLONEFILE = libc_clonefile()


def copy_file(src, dst):
    # APFS clones are instant and share storage until changed; the repo has hundreds of MB of cost data
    if CLONEFILE is not None and CLONEFILE(src.encode(), dst.encode(), 0) == 0:
        return
    shutil.copy2(src, dst)


def snapshot(dest, ref, staged, source_dir):
    if source_dir is not None:
        shutil.copytree(source_dir, dest, copy_function=copy_file)
        return
    os.makedirs(dest)
    if staged:
        # Uses GIT_INDEX_FILE when git sets it, as it does for hooks during git commit -a or git commit PATHS
        subprocess.run(["git", "checkout-index", "-a", "--prefix=" + dest + "/"], cwd=REPO, check=True)
        return
    if ref is not None:
        archive = subprocess.Popen(["git", "archive", ref], cwd=REPO, stdout=subprocess.PIPE)
        subprocess.run(["tar", "-x", "-C", dest], stdin=archive.stdout, check=True)
        if archive.wait() != 0:
            raise SystemExit("git archive " + ref + " failed")
        return
    listed = subprocess.run(["git", "ls-files", "-co", "--exclude-standard", "-z"], cwd=REPO, capture_output=True, check=True).stdout.decode()
    for path in listed.split("\0"):
        src = os.path.join(REPO, path)
        # Tracked files deleted from the working tree are still listed
        if path == "" or not os.path.isfile(src):
            continue
        dst = os.path.join(dest, path)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        copy_file(src, dst)


def load_settings(mod_dir):
    lua = shutil.which("lua")
    if lua is None:
        raise SystemExit("run-tests needs a lua interpreter on PATH to read settings.lua")
    output = subprocess.run([lua, DUMP_SETTINGS], cwd=mod_dir, capture_output=True, text=True, check=True).stdout
    settings = {}
    for line in output.splitlines():
        fields = line.split("\t")
        if fields[0].startswith(PREFIX):
            setting = Setting(fields)
            settings[setting.name] = setting
    return settings


def mod_version(file_name, name):
    match = re.fullmatch(re.escape(name) + r"(?:_(\d+)\.(\d+)\.(\d+))?(?:\.zip)?", file_name)
    if match is None:
        return None
    return tuple(int(part) for part in match.groups()) if match.group(1) is not None else (0, 0, 0)


def mod_factorio_version(path):
    # The factorio_version in a mod folder's or zip's info.json (the zip's is one folder down), or None if it can't be read
    try:
        if os.path.isdir(path):
            with open(os.path.join(path, "info.json")) as f:
                return json.load(f).get("factorio_version")
        with zipfile.ZipFile(path) as archive:
            for member in archive.namelist():
                if member.count("/") == 1 and member.endswith("/info.json"):
                    return json.loads(archive.read(member)).get("factorio_version")
    except (OSError, ValueError, zipfile.BadZipFile):
        return None
    return None


def find_user_mod(name, game):
    # The newest copy of a mod in the user's mods directory made for this game version (the mods directory keeps old copies too)
    wanted = str(game[0]) + "." + str(game[1])
    best = None
    for file_name in os.listdir(USER_MODS):
        version = mod_version(file_name, name)
        path = os.path.join(USER_MODS, file_name)
        if version is not None and (best is None or version > best[0]) and mod_factorio_version(path) == wanted:
            best = (version, path)
    if best is None:
        raise SystemExit("mod set needs mod " + name + " for Factorio " + wanted + ", which isn't in " + USER_MODS)
    return best[1]


def load_modsets():
    # Each mod set's other mods are found later by find_links, only for mod sets with runs, so a missing mod only stops runs that need it
    modsets = {}
    for file_name in sorted(os.listdir(MOD_CONFIGS)):
        if not file_name.endswith(".json"):
            continue
        with open(os.path.join(MOD_CONFIGS, file_name)) as f:
            mod_list = json.load(f)
        # Not part of Factorio's mod-list.json format, so it's taken out before the list is written for a run
        settings = mod_list.pop("settings", {})
        for setting_name, value in settings.items():
            if setting_name.startswith(PREFIX) or not any(isinstance(value, kind) for kind, _ in JSON_DAT_TYPES):
                raise SystemExit(os.path.join(MOD_CONFIGS, file_name) + ": settings are other mods' startup settings, each a bool, number or string; " + setting_name + " isn't")
        enabled = [mod["name"] for mod in mod_list["mods"] if mod["enabled"]]
        builtin = [name for name in enabled if os.path.isfile(os.path.join(GAME_DATA, name, "info.json"))]
        others = [name for name in enabled if name != MOD_NAME and name not in builtin]
        modsets[file_name[:-len(".json")]] = {"list": mod_list, "settings": settings, "others": others, "links": None, "weight": len(enabled)}
    return modsets


def find_links(modsets, runs, game):
    for name in set(run.modset for run in runs):
        modsets[name]["links"] = [find_user_mod(other, game) for other in modsets[name]["others"]]


def game_version():
    output = subprocess.run([FACTORIO, "--version"], capture_output=True, text=True).stdout
    match = re.search(r"Version: (\d+)\.(\d+)\.(\d+)", output)
    if match is None:
        raise SystemExit("couldn't read the game version from factorio --version")
    return tuple(int(part) for part in match.groups())


def read(path):
    with open(path, errors="replace") as f:
        return f.read()


def error_lines(text, limit=6):
    lines = [line.strip() for line in text.splitlines()]
    for i, line in enumerate(lines):
        if "Error" in line:
            picked = [part for part in lines[i:i + 10] if part != "" and "-----" not in part and not part.startswith("Please report")]
            return picked[:limit]
    return []


class Context:
    def __init__(self, root, snapshot_dir, settings, modsets, version, profile, dump_data):
        self.root = root
        self.snapshot = snapshot_dir
        self.settings = settings
        self.modsets = modsets
        self.version = version
        # Whether map creation runs the profiler (--profile)
        self.profile = profile
        # Whether each run also dumps its data.raw (--dump-data)
        self.dump_data = dump_data
        self.processes = Processes()


def same_value(text, value):
    # Whether the test helper's text for a setting (Lua's tostring) is this value from a mod set file
    if isinstance(value, bool) or isinstance(value, str):
        return text == fmt(value)
    try:
        return float(text) == value
    except ValueError:
        return False


def check_settings(text, run, ctx):
    problems = []
    reported = {match.group(1): match.group(2).strip() for match in SETTING_LINE.finditer(text)}
    expected = dict(run.config.settings, seed=run.config.seed)
    for name, value in expected.items():
        if PREFIX + name not in reported:
            problems.append("setting " + name + " wasn't reported by the test helper")
            continue
        try:
            actual = ctx.settings[name].parse(reported[PREFIX + name])
        except ValueError:
            actual = reported[PREFIX + name]
        if actual != value:
            problems.append("setting " + name + " was " + reported[PREFIX + name] + " in game, but the config set " + fmt(value))
    for name, value in ctx.modsets[run.modset]["settings"].items():
        if name not in reported:
            problems.append("setting " + name + " (from mod set " + run.modset + ") wasn't reported by the test helper; is its mod enabled?")
        elif not same_value(reported[name], value):
            problems.append("setting " + name + " was " + reported[name] + " in game, but mod set " + run.modset + " set " + fmt(value))
    return problems


def check_game_version(text, ctx):
    # A game update during a long run makes later runs test something else
    match = GAME_VERSION.search(text)
    if match is None:
        return []
    version = tuple(int(part) for part in match.groups())
    if version != ctx.version:
        return ["the game changed from " + ".".join(map(str, ctx.version)) + " to " + ".".join(map(str, version)) + " during the test run; rerun this"]
    return []


def check_reachability(text):
    if "PRTEST reachability missing" in text:
        return ["the randomizer recorded no reachability data (propertyrandomizer-reachability-data), so the panel's softlock check can't be read"]
    match = REACHABILITY.search(text)
    if match is None:
        return ["the test helper didn't report reachability (its on_init didn't run)"]
    reachable, total = int(match.group(1)), int(match.group(2))
    if reachable < total:
        return ["softlock warning: only " + str(reachable) + " of " + str(total) + " science packs are reachable"]
    return []


def check_old_logic(text):
    # The old logic's check of the built game (data-final-fixes.lua logs it with old item randomization on)
    match = OLD_LOGIC_CHECK.search(text)
    if match is None:
        return ["the old logic's check (OLDLOGICCHECK) is missing from the log"]
    reachable, total = int(match.group(1)), int(match.group(2))
    if reachable < total:
        return ["old logic: only " + str(reachable) + " of " + str(total) + " science packs are reachable (lost " + (match.group(3) or "?") + ")"]
    return []


def check_verdict(text):
    # The last verdict is the end-of-load one; unified randomization also logs one per attempt, under another label
    verdicts = VERDICT.findall(text)
    if len(verdicts) == 0:
        return ["the MECHCHECK verdict is missing from the log (the check didn't run)"]
    if verdicts[-1][0] != "ok":
        return ["MECHCHECK verdict " + verdicts[-1][0] + " " + verdicts[-1][1]]
    return []


def check_science_costs(text):
    # Every pack has equal weight: arithmetic mean of after/before ratios.
    # At most 4x per pack; the mean must stay below 2x.
    prices = {"before": {}, "after": {}}
    problems = []
    for stage, pack, raw in SCIENCE_COST.findall(text):
        if pack in prices[stage]:
            problems.append("science cost: duplicate " + stage + " price for " + pack)
        try:
            value = None if raw == "unpriced" else float(raw)
            if value is not None and (not math.isfinite(value) or value < 0):
                raise ValueError()
        except ValueError:
            problems.append("science cost: invalid " + stage + " price for " + pack + ": " + raw)
            value = None
        prices[stage][pack] = value
    if not prices["before"] or not prices["after"]:
        return problems + ["science cost: missing before/after SCIENCECOST measurements"], ""
    ratios = {}
    skipped = []
    for pack in sorted(prices["before"].keys() | prices["after"].keys()):
        if pack not in prices["before"] or pack not in prices["after"]:
            problems.append("science cost: missing before/after measurement for " + pack)
            continue
        before, after = prices["before"][pack], prices["after"][pack]
        if before is None:
            problems.append("science cost: " + pack + " has no baseline price; cannot verify its cost limits")
            skipped.append(pack)
            continue
        if after is None:
            problems.append("science cost: " + pack + " lost its price after randomization")
            continue
        ratio = after / before if before > 0 else (1.0 if after == 0 else math.inf)
        ratios[pack] = ratio
        if ratio > 4:
            problems.append("science cost: " + pack + " increased to " + format(ratio, ".3f") + "x (maximum 4x)")
    if not ratios:
        problems.append("science cost: no science packs have comparable prices")
        summary = "no comparable packs"
    else:
        mean = sum(ratios.values()) / len(ratios)
        if mean >= 2:
            problems.append("science cost: mean pack ratio " + format(mean, ".3f") + "x (must be below 2x)")
        summary = str(len(ratios)) + " packs, max " + format(max(ratios.values()), ".3f") + "x, mean " + format(mean, ".3f") + "x"
    if skipped:
        summary += "; INCOMPLETE, no baseline price: " + ", ".join(skipped)
    return problems, summary


def run_one(run, ctx):
    start = time.time()
    run_dir = os.path.join(ctx.root, "runs", run.slug)
    mods_dir = os.path.join(run_dir, "mods")
    data_dir = os.path.join(run_dir, "data")
    os.makedirs(mods_dir)
    os.makedirs(data_dir)
    modset = ctx.modsets[run.modset]
    os.symlink(ctx.snapshot, os.path.join(mods_dir, MOD_NAME))
    os.symlink(os.path.join(ctx.root, HELPER_NAME), os.path.join(mods_dir, HELPER_NAME))
    for path in modset["links"]:
        os.symlink(path, os.path.join(mods_dir, os.path.basename(path)))
    mod_list = json.loads(json.dumps(modset["list"]))
    mod_list["mods"].append({"name": HELPER_NAME, "enabled": True})
    if ctx.profile:
        os.symlink(os.path.join(ctx.root, PROFILER_NAME), os.path.join(mods_dir, PROFILER_NAME))
        mod_list["mods"].append({"name": PROFILER_NAME, "enabled": True})
    with open(os.path.join(mods_dir, "mod-list.json"), "w") as f:
        json.dump(mod_list, f, indent=2)
    values = [(PREFIX + "seed", mod_settings.SIGNED, run.config.seed)]
    for name, value in run.config.settings.items():
        values.append((PREFIX + name, DAT_TYPES[ctx.settings[name].type], value))
    for name, value in modset["settings"].items():
        values.append((name, next(dat_type for kind, dat_type in JSON_DAT_TYPES if isinstance(value, kind)), value))
    mod_settings.build(os.path.join(mods_dir, "mod-settings.dat"), ctx.version, values)
    config_path = os.path.join(run_dir, "config.ini")
    with open(config_path, "w") as f:
        # The prototype cache lets the control stage run reuse the data stage from map creation instead of randomizing again
        f.write("[path]\nread-data=__PATH__executable__/../data\nwrite-data=" + data_dir + "\n[other]\ncache-prototype-data=true\n")

    base_args = [FACTORIO, "-c", config_path, "--mod-directory", mods_dir]
    save = os.path.join(run_dir, "save.zip")
    problems = []
    science_cost_summary = ""
    create_log = os.path.join(run_dir, "create.log")
    # Instrument Mode loads the profiler before every mod's data stage, and the profiler needs the full Lua debug library to sample
    profile_args = ["--instrument-mod", PROFILER_NAME, "--enable-unsafe-lua-debug-api"] if ctx.profile else []
    code = ctx.processes.run(base_args + profile_args + ["--create", save], create_log)
    text = read(create_log)
    if ctx.profile:
        profile_report.write_report(create_log, os.path.join(run_dir, "profile.txt"), source=ctx.snapshot)
    problems.extend(check_game_version(text, ctx))
    if code != 0:
        problems.append("map creation failed (exit " + str(code) + ")")
        problems.extend(error_lines(text))
    else:
        problems.extend(check_settings(text, run, ctx))
        reported = dict(SETTING_LINE.findall(text))
        if reported.get(PREFIX + "recipe") == "true" and reported.get(PREFIX + "test-unit") != "true" and "science-cost" not in run.config.nocheck:
            cost_problems, science_cost_summary = check_science_costs(text)
            problems.extend(cost_problems)
        if run.config.old_logic:
            problems.extend(check_old_logic(text))
        else:
            if "reachability" not in run.config.nocheck:
                problems.extend(check_reachability(text))
            if "mechcheck" not in run.config.nocheck:
                problems.extend(check_verdict(text))
        if "control" not in run.config.nocheck:
            control_log = os.path.join(run_dir, "control.log")
            code = ctx.processes.run(base_args + ["--benchmark", save, "--benchmark-ticks", str(CONTROL_TICKS)], control_log)
            control_text = read(control_log)
            problems.extend(check_game_version(control_text, ctx))
            if code != 0:
                problems.append("control stage failed (exit " + str(code) + ")")
                problems.extend(error_lines(control_text))
            elif re.search(r"Performed " + str(CONTROL_TICKS) + r" updates", control_text) is None:
                problems.append("control stage didn't report running " + str(CONTROL_TICKS) + " ticks")
    dump_hash = None
    if ctx.dump_data:
        # Factorio writes the dump to the write-data directory's script-output and exits; it's kept next to the logs
        code = ctx.processes.run(base_args + ["--dump-data"], os.path.join(run_dir, "dump.log"))
        dump = os.path.join(data_dir, "script-output", "data-raw-dump.json")
        if code != 0 or not os.path.exists(dump):
            problems.append("data.raw dump failed (exit " + str(code) + ")")
        else:
            shutil.move(dump, os.path.join(run_dir, "data-raw-dump.json"))
            digest = hashlib.sha256()
            with open(os.path.join(run_dir, "data-raw-dump.json"), "rb") as f:
                for block in iter(lambda: f.read(1 << 20), b""):
                    digest.update(block)
            dump_hash = digest.hexdigest()
    # Keep logs; the write-data directory holds the prototype cache and a copy of the log
    shutil.rmtree(data_dir, ignore_errors=True)
    if len(problems) == 0 and os.path.exists(save):
        os.remove(save)
    return {"run": run, "ok": len(problems) == 0, "problems": problems, "dir": run_dir, "seconds": time.time() - start, "science_costs": science_cost_summary, "dump_hash": dump_hash}


def run_one_safely(run, ctx):
    # A bug in the runner itself fails this run instead of stopping the whole suite
    start = time.time()
    try:
        return run_one(run, ctx)
    except Exception as error:
        return {"run": run, "ok": False, "problems": ["the test runner failed: " + repr(error)], "dir": os.path.join(ctx.root, "runs", run.slug), "seconds": time.time() - start}


def duration(seconds):
    seconds = int(seconds)
    if seconds < 60:
        return str(seconds) + "s"
    if seconds < 3600:
        return str(seconds // 60) + "m" + str(seconds % 60).zfill(2) + "s"
    return str(seconds // 3600) + "h" + str(seconds // 60 % 60).zfill(2) + "m"


def print_plan(plan, runs):
    print("Covered visible settings: " + ", ".join(setting.name for setting in plan.visible))
    print("Covered unified settings: " + ", ".join(setting.name for setting in plan.unified))
    print("Skipped in tests/configs.txt: " + ", ".join(plan.skipped))
    print("No finite values to pick from: " + ", ".join(plan.no_values))
    print("Hidden and not unified (unfinished): " + ", ".join(plan.left_out))
    for note in plan.notes:
        print(note)
    print()
    for run in runs:
        print(run.config.suite.ljust(9) + run.name.ljust(52) + run.config.describe())
    print()
    counts = {}
    for run in runs:
        counts[run.config.suite] = counts.get(run.config.suite, 0) + 1
    print(str(len(runs)) + " runs: " + ", ".join(suite + " " + str(count) for suite, count in counts.items()))


def summarize(results, test_file, elapsed):
    lines = []
    suites = []
    for result in results:
        if result["run"].config.suite not in suites:
            suites.append(result["run"].config.suite)
    for suite in suites:
        in_suite = [result for result in results if result["run"].config.suite == suite]
        passed = sum(1 for result in in_suite if result["ok"])
        label = suite + (" (work in progress, not counted)" if suite in test_file.wip else "")
        lines.append(label + ": " + str(passed) + " of " + str(len(in_suite)) + " passed")
    cost_results = [result for result in results if result.get("science_costs")]
    if cost_results:
        lines.extend(["", "Science costs (after/before recipe randomization, global prices):"])
        for result in cost_results:
            lines.append("  " + result["run"].name + ": " + result["science_costs"])
    failures = [result for result in results if not result["ok"]]
    if len(failures) > 0:
        lines.append("")
        lines.append("Failures:")
        for result in failures:
            run = result["run"]
            wip = " [wip]" if run.config.suite in test_file.wip else ""
            lines.append("  " + run.name + wip + " (" + run.config.describe() + ")")
            for problem in result["problems"]:
                lines.append("      " + problem)
            lines.append("      logs in " + result["dir"])
    counted = [result for result in failures if result["run"].config.suite not in test_file.wip]
    lines.append("")
    if len(counted) == 0:
        lines.append("ALL TESTS PASSED in " + duration(elapsed) + (" (work-in-progress failures above)" if len(failures) > 0 else ""))
    else:
        lines.append(str(len(counted)) + " TESTS FAILED in " + duration(elapsed))
        lines.append(FAILURE_GUIDANCE)
    return "\n".join(lines), len(counted) == 0


def in_use(root):
    # A run holds a lock on its directory while it's going
    try:
        with open(os.path.join(root, "lock"), "a") as lock:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        return True
    except OSError:
        return False
    return False


def new_root():
    os.makedirs(CACHE_DIR, exist_ok=True)
    # Keep the last few runs around for their logs, and never delete one that's still going
    old_roots = sorted((os.path.join(CACHE_DIR, name) for name in os.listdir(CACHE_DIR) if name.startswith("run-")), key=os.path.getmtime)
    for old_root in old_roots[:-2]:
        if not in_use(old_root):
            shutil.rmtree(old_root, ignore_errors=True)
    root = tempfile.mkdtemp(prefix="run-" + time.strftime("%Y%m%d-%H%M%S") + "-", dir=CACHE_DIR)
    # Held until the process exits
    global ROOT_LOCK
    ROOT_LOCK = open(os.path.join(root, "lock"), "w")
    fcntl.flock(ROOT_LOCK, fcntl.LOCK_EX)
    return root


def point_latest(root):
    latest = os.path.join(CACHE_DIR, "latest")
    if os.path.islink(latest):
        os.remove(latest)
    os.symlink(root, latest)


def main(argv):
    parser = argparse.ArgumentParser(description="Headless test suites for the randomizer (see the comment at the top of this file)")
    parser.add_argument("suites", nargs="*", help="suites to run: " + ", ".join(SUITES) + " (default: all)")
    parser.add_argument("--list", action="store_true", help="print the planned runs without running anything")
    parser.add_argument("--only", action="append", help="only runs whose name contains this text (can repeat)")
    parser.add_argument("--modset", action="append", help="only this mod set (can repeat); it runs every config, even with a limit line")
    parser.add_argument("--jobs", type=int, default=3, help="parallel Factorio processes")
    parser.add_argument("--tier", help="only the runs in this tier from tests/configs.txt")
    parser.add_argument("--ref", help="test this git ref instead of the working tree")
    parser.add_argument("--staged", action="store_true", help="test the staged files instead of the working tree")
    parser.add_argument("--dir", help="test this mod folder instead of the working tree")
    parser.add_argument("--seed-offset", type=int, default=0, help="shift every seed")
    parser.add_argument("--profile", action="store_true", help="sample the Lua stack while each map is created, and write profile.txt in its log folder")
    parser.add_argument("--dump-data", action="store_true", help="also dump each run's data.raw to data-raw-dump.json in its log folder and print its SHA-256")
    args = parser.parse_args(argv)
    suites = args.suites if len(args.suites) > 0 else SUITES
    if sum(1 for picked in (args.ref is not None, args.staged, args.dir is not None) if picked) > 1:
        raise SystemExit("--ref, --staged and --dir each pick what to test; use one")
    if args.dir is not None and not os.path.isfile(os.path.join(args.dir, "info.json")):
        raise SystemExit("--dir " + args.dir + " isn't a mod folder (no info.json)")

    start = time.time()
    version = game_version()
    test_file = TestFile()
    if args.tier is not None and args.tier not in test_file.tiers:
        raise SystemExit("no tier " + args.tier + " in tests/configs.txt (have " + ", ".join(test_file.tiers) + ")")
    modsets = load_modsets()
    unknown = [name for name in args.modset or [] if name not in modsets]
    if len(unknown) > 0:
        raise SystemExit("no mod set " + ", ".join(unknown) + " in tests/mod-configs (have " + ", ".join(modsets) + ")")
    unknown = [pattern for pattern, _ in test_file.limits if not any(fnmatch.fnmatchcase(modset, pattern) for modset in modsets)]
    if len(unknown) > 0:
        raise SystemExit("limit lines in tests/configs.txt match no mod set: " + ", ".join(unknown))
    root = new_root()
    snapshot_dir = os.path.join(root, MOD_NAME)
    snapshot(snapshot_dir, args.ref, args.staged, args.dir)
    shutil.copytree(HELPER_MOD, os.path.join(root, HELPER_NAME))
    if args.profile:
        shutil.copytree(PROFILER_MOD, os.path.join(root, PROFILER_NAME))
    settings = load_settings(snapshot_dir)
    plan = Plan(settings, test_file, args.seed_offset)
    unknown = [suite for suite in suites if suite not in set(config.suite for config in plan.configs)]
    if len(unknown) > 0:
        shutil.rmtree(root, ignore_errors=True)
        raise SystemExit("no configs in suite " + ", ".join(unknown))
    runs = []
    for config in plan.configs:
        for modset in modsets:
            run = Run(config, modset)
            if config.suite not in suites or (args.modset is not None and modset not in args.modset):
                continue
            if args.modset is None and not test_file.runs_config(modset, config.name):
                continue
            if args.only is not None and not any(text in run.name for text in args.only):
                continue
            if args.tier is not None and not any(text in run.name for text in test_file.tiers[args.tier]):
                continue
            runs.append(run)
    slugs = [run.slug for run in runs]
    shared = sorted(set(run.name for run in runs if slugs.count(run.slug) > 1))
    if len(shared) > 0:
        shutil.rmtree(root, ignore_errors=True)
        raise SystemExit("these runs would share a log folder (two configs with the same name?): " + ", ".join(shared))
    # Longest first, so a slow run doesn't start last and leave the other jobs idle
    runs.sort(key=lambda run: -modsets[run.modset]["weight"] * (1 + len(run.config.settings)))
    if args.list:
        print_plan(plan, runs)
        shutil.rmtree(root, ignore_errors=True)
        return 0
    if len(runs) == 0:
        shutil.rmtree(root, ignore_errors=True)
        raise SystemExit("no runs match")
    try:
        find_links(modsets, runs, version)
    except SystemExit:
        shutil.rmtree(root, ignore_errors=True)
        raise

    point_latest(root)
    ctx = Context(root, snapshot_dir, settings, modsets, version, args.profile, args.dump_data)
    source = "the working tree"
    if args.ref is not None:
        source = "git ref " + args.ref
    elif args.staged:
        source = "the staged files"
    elif args.dir is not None:
        source = "the folder " + args.dir
    jobs_note = str(args.jobs) + " at a time"
    session, kind, limit = factorio_launch.session_limit()
    if session is not None and limit < args.jobs:
        jobs_note = str(limit) + " at a time (this " + kind + "'s limit, see dev/factorio_launch.py)"
    print("Testing " + source + " (snapshot in " + root + "): " + str(len(runs)) + " runs, " + jobs_note)
    for note in plan.notes:
        print(note)
    print_lock = threading.Lock()
    results = []

    def report(result):
        with print_lock:
            results.append(result)
            run = result["run"]
            if result["ok"]:
                status = "ok  "
            elif run.config.suite in test_file.wip:
                status = "wip-FAIL"
            else:
                status = "FAIL"
            line = "[" + str(len(results)).rjust(len(str(len(runs)))) + "/" + str(len(runs)) + "] " + status.ljust(8) + " " + run.name + " (" + duration(result["seconds"]) + ")"
            if not result["ok"]:
                line += ": " + result["problems"][0]
            if ctx.profile and os.path.exists(os.path.join(result["dir"], "profile.txt")):
                line += "\n    profile in " + os.path.join(result["dir"], "profile.txt")
            if result.get("dump_hash") is not None:
                line += "\n    data.raw dump SHA-256 " + result["dump_hash"]
            print(line, flush=True)

    pool = concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs)
    try:
        futures = [pool.submit(run_one_safely, run, ctx) for run in runs]
        for future in concurrent.futures.as_completed(futures):
            report(future.result())
    except KeyboardInterrupt:
        ctx.processes.stop()
        pool.shutdown(wait=True, cancel_futures=True)
        print("Stopped; logs so far in " + root)
        return 130
    pool.shutdown()

    order = {run.name: i for i, run in enumerate(sorted(runs, key=lambda run: (SUITES.index(run.config.suite) if run.config.suite in SUITES else len(SUITES), run.name)))}
    results.sort(key=lambda result: order[result["run"].name])
    summary, ok = summarize(results, test_file, time.time() - start)
    with open(os.path.join(root, "summary.txt"), "w") as f:
        f.write(summary + "\n")
    print()
    print(summary)
    print("Full summary in " + os.path.join(root, "summary.txt"))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

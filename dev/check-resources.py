#!/usr/bin/env python3
# Runs non-unified recipe randomization headless on the base game over several seeds and checks its local resource balance:
# for each recipe choice that preserves resource costs, the vanilla-priced raw resource bill of the new ingredients versus
# the old ones (RECIPEBILL lines, from randomizations/graph/recipe.lua)
# Fails if, summed over those choices, any major raw resource leaves [1 / MAX_LOCAL_RATIO, MAX_LOCAL_RATIO] times its old amount
#
# Also prints, for information only, the raw resources in one unit of an all-science-pack research before and after
# (RESOURCEREPORT lines, from lib/cost/resource-report.lua); these drift in ways a local measure can't control
#
# Runs from a copy of the mod with unified randomization skipped, so only non-unified recipe randomization is measured
# Settings come from the main mod-settings.dat with the seed changed, recipe randomization on, and numerical randomization off
#
# Usage:
#   dev/check-resources.py             run the default seeds
#   dev/check-resources.py 5 17 42     run specific seeds (values of the propertyrandomizer-seed setting)

import concurrent.futures
import os
import re
import shutil
import statistics
import subprocess
import sys
import tempfile
import time

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FACTORIO = "/Applications/factorio.app/Contents/MacOS/factorio"
BASE_SETTINGS = os.path.join(os.path.dirname(REPO), "mod-settings.dat")
MOD_LIST = os.path.join(REPO, "tests", "mod-configs", "base.json")
SETTINGS_TOOL = os.path.join(REPO, "dev", "mod-settings.py")
CACHE_DIR = os.path.join(tempfile.gettempdir(), "propertyrandomizer-check-resources")

DEFAULT_SEEDS = [1, 2, 3, 4, 5, 6, 7, 8]
JOBS = 4
TIMEOUT_SECONDS = 300
MAX_LOCAL_RATIO = 1.5
SETTINGS = [
    "propertyrandomizer-recipe=true",
    "propertyrandomizer-logistic=none",
    "propertyrandomizer-production=none",
    "propertyrandomizer-military=none",
    "propertyrandomizer-misc=none",
]
UNIFIED_CALL = "unified_info = unified.execute()"

REPORT = re.compile(r"RESOURCEREPORT (before|after) bom (\S+) (.*)")
RECIPE_BILL = re.compile(r"RECIPEBILL (\S+) (preserved|unpreserved) (.*)")


def make_mod_copy(root):
    copy = os.path.join(root, "propertyrandomizer")
    shutil.copytree(REPO, copy, ignore=shutil.ignore_patterns(".git"))
    path = os.path.join(copy, "data-final-fixes.lua")
    with open(path) as f:
        text = f.read()
    if UNIFIED_CALL not in text:
        sys.exit("Couldn't find '" + UNIFIED_CALL + "' in data-final-fixes.lua to skip unified randomization")
    with open(path, "w") as f:
        f.write(text.replace(UNIFIED_CALL, "unified_info = {}"))
    return copy


def run_seed(seed, root, mod_copy):
    run_dir = os.path.join(root, "seed-" + str(seed))
    mods_dir = os.path.join(run_dir, "mods")
    os.makedirs(mods_dir)
    os.makedirs(os.path.join(run_dir, "data"))
    os.symlink(mod_copy, os.path.join(mods_dir, "propertyrandomizer"))
    shutil.copy(MOD_LIST, os.path.join(mods_dir, "mod-list.json"))
    subprocess.run([sys.executable, SETTINGS_TOOL, "set", BASE_SETTINGS, os.path.join(mods_dir, "mod-settings.dat"), "propertyrandomizer-seed=" + str(seed)] + SETTINGS, check=True)
    config_path = os.path.join(run_dir, "config.ini")
    with open(config_path, "w") as f:
        f.write("[path]\nread-data=__PATH__executable__/../data\nwrite-data=" + os.path.join(run_dir, "data") + "\n")

    log_path = os.path.join(run_dir, "factorio.log")
    with open(log_path, "w") as log_file:
        try:
            exit_code = subprocess.run([FACTORIO, "-c", config_path, "--mod-directory", mods_dir, "--create", os.path.join(run_dir, "save.zip")], stdout=log_file, stderr=subprocess.STDOUT, timeout=TIMEOUT_SECONDS).returncode
        except subprocess.TimeoutExpired:
            exit_code = "timeout"
    # {stage -> {pack or "total" -> {resource -> amount}}}
    report = {"before": {}, "after": {}}
    # [(recipe, preserved, {resource -> (old, new)})]
    bills = []
    with open(log_path, errors="replace") as f:
        for line in f:
            match = RECIPE_BILL.search(line)
            if match is not None:
                amounts = {}
                for pair in match.group(3).split():
                    resource, amount = pair.split("=")
                    old, new = amount.split("/")
                    amounts[resource] = (float(old), float(new))
                bills.append((match.group(1), match.group(2) == "preserved", amounts))
            match = REPORT.search(line)
            if match is not None:
                amounts = {}
                for pair in match.group(3).split():
                    resource, amount = pair.split("=")
                    amounts[resource] = float(amount)
                report[match.group(1)][match.group(2)] = amounts
    return {"seed": seed, "exit": exit_code, "log": log_path, "report": report, "bills": bills}


def short(resource):
    return resource.split("-", 1)[1]


def main(argv):
    seeds = [int(arg) for arg in argv] if len(argv) > 0 else DEFAULT_SEEDS
    os.makedirs(CACHE_DIR, exist_ok=True)
    old_runs = sorted((os.path.join(CACHE_DIR, name) for name in os.listdir(CACHE_DIR) if name.startswith("run-")), key=os.path.getmtime)
    for old_run in old_runs[:-2]:
        shutil.rmtree(old_run, ignore_errors=True)
    root = tempfile.mkdtemp(prefix="run-", dir=CACHE_DIR)
    mod_copy = make_mod_copy(root)
    start = time.time()
    with concurrent.futures.ThreadPoolExecutor(max_workers=JOBS) as pool:
        results = list(pool.map(lambda seed: run_seed(seed, root, mod_copy), seeds))

    problems = []
    for result in results:
        if result["exit"] != 0 or "total" not in result["report"]["after"]:
            problems.append("seed " + str(result["seed"]) + ": run failed (exit " + str(result["exit"]) + "), log at " + result["log"])
    good = [result for result in results if "total" in result["report"]["after"]]
    if len(good) == 0:
        print("\n".join(problems))
        return 1

    vanilla = good[0]["report"]["before"]["total"]
    resources = list(vanilla.keys())
    print("Local bills: summed new / old over recipe choices (all seeds), and median per-choice ratio where old > 0")
    all_bills = [bill for result in good for bill in result["bills"]]
    science_packs = set(pack for pack in good[0]["report"]["before"] if pack != "total")
    groups = [
        ("preserved", [bill for bill in all_bills if bill[1]]),
        ("science packs", [bill for bill in all_bills if bill[0] in science_packs]),
    ]
    for label, group in groups:
        print("  " + label + " (" + str(len(group)) + " choices)")
        for resource in (group[0][2].keys() if len(group) > 0 else []):
            old = sum(bill[2][resource][0] for bill in group)
            new = sum(bill[2][resource][1] for bill in group)
            ratios = [bill[2][resource][1] / bill[2][resource][0] for bill in group if bill[2][resource][0] > 0]
            if old == 0:
                continue
            ratio = new / old
            print("    " + short(resource).ljust(10) + " %.2f  (median %.2f over %d)" % (ratio, statistics.median(ratios), len(ratios)))
            if label == "preserved" and (ratio > MAX_LOCAL_RATIO or ratio < 1 / MAX_LOCAL_RATIO):
                problems.append("preserved choices use %.2fx the old " % ratio + short(resource))

    print("For information: raw resources per all-pack research unit (vanilla -> each seed; ratio min / median / max)")
    for resource in resources:
        afters = [result["report"]["after"]["total"][resource] for result in good]
        line = "  " + short(resource).ljust(10) + " " + ("%.1f" % vanilla[resource]).rjust(7) + " |" + "".join(("%.1f" % amount).rjust(8) for amount in afters)
        if vanilla[resource] > 0:
            ratios = [amount / vanilla[resource] for amount in afters]
            line += "  | %.2f / %.2f / %.2f" % (min(ratios), statistics.median(ratios), max(ratios))
        print(line)

    print("Per pack, median ratio over seeds [min-max]")
    for pack in sorted(vanilla_pack for vanilla_pack in good[0]["report"]["before"] if vanilla_pack != "total"):
        parts = []
        for resource in resources:
            before = good[0]["report"]["before"][pack][resource]
            afters = [result["report"]["after"][pack][resource] for result in good]
            if before > 0:
                ratios = [amount / before for amount in afters]
                parts.append(short(resource) + " %.2f[%.2f-%.2f]" % (statistics.median(ratios), min(ratios), max(ratios)))
            else:
                parts.append(short(resource) + " 0->[%.1f-%.1f]" % (min(afters), max(afters)))
        print("  " + pack.replace("-science-pack", "").ljust(11) + " " + "  ".join(parts))

    print("\n".join(problems))
    ok = len(problems) == 0
    print(("Local bills within " + str(MAX_LOCAL_RATIO) + "x over " + str(len(seeds)) + " seeds" if ok else "FAILED") + " (" + str(round(time.time() - start)) + "s); runs in " + root)
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

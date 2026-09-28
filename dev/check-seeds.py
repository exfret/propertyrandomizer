#!/usr/bin/env python3
# Runs the randomizer headless on several seeds and fails if the logic check (MECHCHECK, from
# randomizations/graph/unified/skeleton/check.lua) finds any unreachable recipe or lost mechanic context
# The logic graph is the source of truth, so this is the correctness gate for randomization changes
#
# Each run uses its own mod and write-data directories, so it works while Factorio or other runs are open
# Settings come from the main mod-settings.dat (what's being playtested) with only the seed changed
#
# Usage:
#   dev/check-seeds.py                 run the default seeds
#   dev/check-seeds.py 5 17 42         run specific seeds (values of the propertyrandomizer-seed setting)
#   dev/check-seeds.py --hook stop     Claude Code Stop hook mode (reads hook JSON on stdin; no longer wired up, seeds are tested before commits); skipped if no Lua changed since the last run

import concurrent.futures
import fcntl
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time

# Also when another script loads this file by path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import factorio_launch

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FACTORIO = "/Applications/factorio.app/Contents/MacOS/factorio"
BASE_SETTINGS = os.path.join(os.path.dirname(REPO), "mod-settings.dat")
MOD_LIST = os.path.join(REPO, "tests", "mod-configs", "sa.json")
SETTINGS_TOOL = os.path.join(REPO, "dev", "mod-settings.py")
CACHE_DIR = os.path.join(tempfile.gettempdir(), "propertyrandomizer-check-seeds")
STAMP = os.path.join(CACHE_DIR, "last-run.json")
# Full failure report from the last hook run, for the agent to read; the hook message itself stays short
REPORT = os.path.join(CACHE_DIR, "last-report.txt")

# As many seeds as parallel jobs, so the Stop hook takes about one run's time; dev/run-tests.py and its pre-commit tier cover more
DEFAULT_SEEDS = [1, 2, 3]
# Each Space Age data stage run takes a couple GB of memory
JOBS = 3
TIMEOUT_SECONDS = 600

# The user's guidance on seed failures, repeated in dev/run-tests.py and CLAUDE.md
FAILURE_GUIDANCE = (
    "Some seeds failing is expected while the randomizer is in development; up to 30-50% of seeds failing is acceptable."
    " But a seed whose MECHCHECK verdict FAILED (an unreachable recipe, or a mechanic context lost beyond isolatability) is a softlock, which is never acceptable on any seed: fix the model that allowed it."
    " Don't overfit on making every seed pass. Look into a failure when your change could have caused it (compare with a run before your change if unsure), and fix it only at its root cause."
    " Don't add hotfixes or special cases to get a seed through: a patch that quietly breaks something else is worse than a failing seed."
)

# The end-of-load check's verdict, which leaves out losses that only affect isolatability (those are acceptable)
VERDICT = re.compile(r"MECHCHECK verdict: (ok|FAILED) (\(.*\))")
DETAIL = re.compile(r"MECHCHECK (unreachable recipe|lost|root\?|furnace collision) .*")


def run_seed(seed, root):
    run_dir = os.path.join(root, "seed-" + str(seed))
    mods_dir = os.path.join(run_dir, "mods")
    os.makedirs(mods_dir)
    os.makedirs(os.path.join(run_dir, "data"))
    os.symlink(REPO, os.path.join(mods_dir, "propertyrandomizer"))
    shutil.copy(MOD_LIST, os.path.join(mods_dir, "mod-list.json"))
    subprocess.run([sys.executable, SETTINGS_TOOL, "set", BASE_SETTINGS, os.path.join(mods_dir, "mod-settings.dat"), "propertyrandomizer-seed=" + str(seed)], check=True)
    config_path = os.path.join(run_dir, "config.ini")
    with open(config_path, "w") as f:
        f.write("[path]\nread-data=__PATH__executable__/../data\nwrite-data=" + os.path.join(run_dir, "data") + "\n")

    log_path = os.path.join(run_dir, "factorio.log")
    start = time.time()
    with open(log_path, "w") as log_file:
        try:
            proc = factorio_launch.run([FACTORIO, "-c", config_path, "--mod-directory", mods_dir, "--create", os.path.join(run_dir, "save.zip")], stdout=log_file, stderr=subprocess.STDOUT, timeout=TIMEOUT_SECONDS)
            exit_code = proc.returncode
        except subprocess.TimeoutExpired:
            exit_code = "timeout"
    with open(log_path, errors="replace") as f:
        text = f.read()

    problems = []
    if exit_code != 0:
        problems.append("Factorio exited with " + str(exit_code))
        errors = [line.strip() for line in text.splitlines() if "Error" in line]
        problems.extend(errors[:5])
    verdicts = VERDICT.findall(text)
    if len(verdicts) == 0:
        problems.append("MECHCHECK verdict missing from log (check didn't run)")
    elif verdicts[-1][0] != "ok":
        problems.append("MECHCHECK verdict " + verdicts[-1][0] + " " + verdicts[-1][1])
    if len(problems) > 0:
        problems.extend(match.group(0) for match in DETAIL.finditer(text))
    return {"seed": seed, "ok": len(problems) == 0, "problems": problems, "log": log_path, "seconds": round(time.time() - start)}


def run_seeds(seeds):
    os.makedirs(CACHE_DIR, exist_ok=True)
    # Keep the last few runs' logs around for inspection
    old_runs = sorted((os.path.join(CACHE_DIR, name) for name in os.listdir(CACHE_DIR) if name.startswith("run-")), key=os.path.getmtime)
    for old_run in old_runs[:-2]:
        shutil.rmtree(old_run, ignore_errors=True)
    root = tempfile.mkdtemp(prefix="run-", dir=CACHE_DIR)
    with concurrent.futures.ThreadPoolExecutor(max_workers=JOBS) as pool:
        results = list(pool.map(lambda seed: run_seed(seed, root), seeds))
    return root, results


def format_results(results, limit=25):
    lines = []
    for result in results:
        if result["ok"]:
            lines.append("seed " + str(result["seed"]) + ": ok (" + str(result["seconds"]) + "s)")
        else:
            lines.append("seed " + str(result["seed"]) + ": FAILED, log at " + result["log"])
            for problem in result["problems"][:limit]:
                lines.append("    " + problem)
    return "\n".join(lines)


def format_summary(results):
    # One line per seed, with the first problem (usually the MECHCHECK counts)
    lines = []
    for result in results:
        if result["ok"]:
            lines.append("seed " + str(result["seed"]) + ": ok")
        else:
            lines.append("seed " + str(result["seed"]) + ": FAILED, " + result["problems"][0])
    return "\n".join(lines)


def input_hash():
    # Everything that can change the result: Lua sources, mod info, base settings, mod list, and this script
    listed = subprocess.run(["git", "ls-files", "-co", "--exclude-standard", "--", "*.lua", "info.json"], cwd=REPO, capture_output=True, text=True, check=True).stdout.split("\n")
    paths = sorted(os.path.join(REPO, path) for path in listed if path != "")
    paths += [BASE_SETTINGS, MOD_LIST, os.path.abspath(__file__)]
    digest = hashlib.sha256()
    for path in paths:
        if os.path.exists(path):
            digest.update(path.encode())
            with open(path, "rb") as f:
                digest.update(hashlib.sha256(f.read()).digest())
    digest.update(json.dumps(DEFAULT_SEEDS).encode())
    return digest.hexdigest()


def lua_changed():
    status = subprocess.run(["git", "status", "--porcelain", "--", "*.lua"], cwd=REPO, capture_output=True, text=True, check=True).stdout
    return status.strip() != ""


def hook_stop(payload):
    if not lua_changed():
        return 0
    os.makedirs(CACHE_DIR, exist_ok=True)
    # Sessions share this hook; one run at a time, and a waiting session reuses the result if nothing changed
    with open(os.path.join(CACHE_DIR, "lock"), "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        current = input_hash()
        stamp = None
        if os.path.exists(STAMP):
            with open(STAMP) as f:
                stamp = json.load(f)
        if stamp is not None and stamp["hash"] == current and "summary" in stamp:
            ok, report, summary = stamp["ok"], stamp["report"], stamp["summary"]
        else:
            _, results = run_seeds(DEFAULT_SEEDS)
            ok = all(result["ok"] for result in results)
            report = format_results(results, limit=None)
            summary = format_summary(results)
            with open(STAMP, "w") as f:
                json.dump({"hash": current, "ok": ok, "report": report, "summary": summary}, f)
        with open(REPORT, "w") as f:
            f.write(report + "\n")
    if ok:
        return 0
    # Hook messages are shown to the user too, so only a summary goes in them; the agent reads the full report from REPORT
    # Block once so the agent sees it; after that, let it stop but make sure the user sees a one-line notice
    if payload.get("stop_hook_active"):
        print(json.dumps({"systemMessage": "Multi-seed logic check (dev/check-seeds.py) still fails; full report in " + REPORT}))
        return 0
    message = "Multi-seed logic check (dev/check-seeds.py) FAILED on the current code:\n" + summary
    message += "\n\nRead the full report (every lost context/unreachable recipe and each seed's log path) at " + REPORT + " before doing anything else."
    message += "\n\n" + FAILURE_GUIDANCE
    message += " In your reply, say plainly which seeds fail, with a short summary of the failures rather than the full list."
    print(message, file=sys.stderr)
    return 2


def main(argv):
    if len(argv) >= 2 and argv[0] == "--hook":
        payload = json.load(sys.stdin)
        if argv[1] == "stop":
            return hook_stop(payload)
        print("Unknown hook: " + argv[1], file=sys.stderr)
        return 1

    seeds = [int(arg) for arg in argv] if len(argv) > 0 else DEFAULT_SEEDS
    root, results = run_seeds(seeds)
    print(format_results(results))
    ok = all(result["ok"] for result in results)
    print(("All " + str(len(seeds)) + " seeds passed" if ok else "FAILED") + "; runs in " + root)
    if seeds == DEFAULT_SEEDS:
        os.makedirs(CACHE_DIR, exist_ok=True)
        with open(STAMP, "w") as f:
            json.dump({"hash": input_hash(), "ok": ok, "report": format_results(results)}, f)
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

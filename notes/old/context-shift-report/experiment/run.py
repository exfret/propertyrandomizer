#!/usr/bin/env python3
# Usage: run.py OUTDIR SEED... ; runs the scratch mod copy (at most JOBS at once) and keeps only the CONTRA lines of each log
import concurrent.futures, os, re, shutil, subprocess, sys, tempfile, time

HERE = os.path.dirname(os.path.abspath(__file__))
R = "/Users/kylehess/Library/Application Support/factorio/mods/propertyrandomizer"
FACTORIO = "/Applications/factorio.app/Contents/MacOS/factorio"
BASE_SETTINGS = os.path.join(os.path.dirname(R), "mod-settings.dat")
JOBS = int(os.environ.get("JOBS", "2"))
out = os.path.abspath(sys.argv[1])
seeds = [int(a) for a in sys.argv[2:]]
os.makedirs(out, exist_ok=True)

def run(seed):
    d = tempfile.mkdtemp(prefix="%sseed-%d-" % (os.environ.get("PREFIX", ""), seed), dir=HERE)
    mods = os.path.join(d, "mods"); os.makedirs(mods); os.makedirs(os.path.join(d, "data"))
    os.symlink(os.path.join(HERE, os.environ.get("MODDIR", "mod"), "propertyrandomizer"), os.path.join(mods, "propertyrandomizer"))
    shutil.copy(os.path.join(R, "tests", "mod-configs", "sa.json"), os.path.join(mods, "mod-list.json"))
    subprocess.run([sys.executable, os.path.join(R, "dev", "mod-settings.py"), "set", BASE_SETTINGS, os.path.join(mods, "mod-settings.dat"), "propertyrandomizer-seed=%d" % seed], check=True, stdout=subprocess.DEVNULL)
    cfg = os.path.join(d, "config.ini")
    open(cfg, "w").write("[path]\nread-data=__PATH__executable__/../data\nwrite-data=%s\n" % os.path.join(d, "data"))
    start = time.time()
    log = os.path.join(d, "factorio.log")
    with open(log, "w") as f:
        try:
            subprocess.run([FACTORIO, "-c", cfg, "--mod-directory", mods, "--create", os.path.join(d, "save.zip")], stdout=f, stderr=subprocess.STDOUT, timeout=3600)
        except subprocess.TimeoutExpired:
            pass
    text = open(log, errors="replace").read()
    keep = []
    for l in text.splitlines():
        m = re.search(r"CONTRA (.*)$", l)
        if m:
            t = re.match(r"\s*([\d.]+)", l)
            keep.append(("[%s] " % t.group(1) if t else "") + m.group(1))
        elif ("Error" in l or "error" in l) and "QUICKSTOP" not in l:
            keep.append("ERRLINE " + l.strip())
    with open(os.path.join(out, "seed-%d.txt" % seed), "w") as f:
        f.write("\n".join(keep) + "\n")
    secs = round(time.time() - start)
    ok = any("done in" in l for l in keep)
    if ok:
        shutil.rmtree(d, ignore_errors=True)
    return seed, secs, ok, d

with concurrent.futures.ThreadPoolExecutor(max_workers=JOBS) as pool:
    for seed, secs, ok, d in pool.map(run, seeds):
        print("seed %d: %ds %s %s" % (seed, secs, "ok" if ok else "FAILED", "" if ok else d), flush=True)

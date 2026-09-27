#!/usr/bin/env python3
# LaTeX tables for the report from out-v3/summary.json and out-u/summary.json
import json, os, sys, statistics, collections

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = sys.argv[1]
v3 = json.load(open(os.path.join(HERE, "out-v3", "summary.json")))
up = os.path.join(HERE, "out-u", "summary.json")
vu = json.load(open(up)) if os.path.exists(up) else {}
seeds = sorted(int(s) for s in v3)
SCEN = ["oceans", "resources", "both"]
NAME = {"oceans": "oceans", "resources": "resources", "both": "both"}

def get(d, s, sc, k, default=None):
    return d.get(str(s), {}).get(sc, {}).get(k, default)

# ---------------------------------------------------------------- counts table: per seed, per scenario
lines = []
lines.append(r"\begin{table}[t]")
lines.append(r"\centering\footnotesize")
lines.append(r"\setlength{\tabcolsep}{3.2pt}")
lines.append(r"\begin{tabular}{@{}r " + " ".join(["rrrrr"] * 3) + r"@{}}")
lines.append(r"\toprule")
lines.append(r" & \multicolumn{5}{c}{ocean swap} & \multicolumn{5}{c}{resource swap} & \multicolumn{5}{c}{both} \\")
lines.append(r"\cmidrule(lr){2-6}\cmidrule(lr){7-11}\cmidrule(l){12-16}")
lines.append(r"seed & goals & causes & rep. & in & debt & goals & causes & rep. & in & debt & goals & causes & rep. & in & debt \\")
lines.append(r"\midrule")
for s in seeds:
    row = [str(s)]
    for sc in SCEN:
        kept = get(v3, s, sc, "repairs_kept", [])
        ins = sum(1 for r in kept if r["unified"])
        irr = get(v3, s, sc, "irreducible")
        none = get(v3, s, sc, "classes", {}).get("none", 0)
        fail = get(v3, s, sc, "failures")
        cell_rep = "--" if irr is None else str(irr)
        if none:
            cell_rep += r"$^{\dagger}$"
        row += [str(fail), str(get(v3, s, sc, "causes")), cell_rep, "--" if irr is None else str(ins), str(get(v3, s, sc, "debt_edges"))]
    lines.append(" & ".join(row) + r" \\")
lines.append(r"\bottomrule")
lines.append(r"\end{tabular}")
lines.append(r"\caption{Contradictions of raw shifts, seeds 1--8. \emph{goals}: failing goal pebbles (PLANETCHECK's rules). \emph{causes}: distinct lost feature pebbles on their vanilla witnesses. \emph{rep.}: irreducible root-first repair set (ingredient slots). \emph{in}: how many of those unified's recipe-ingredients handler may randomize. \emph{debt}: debt edges on the superposition's solvency-first witness, i.e.\ what settling by addition would take. $\dagger$: some goals are not reachable with \emph{any} ingredient repair (Section~\ref{sec:where}); the repair set covers the others.}")
lines.append(r"\label{tab:counts}")
lines.append(r"\end{table}")
open(os.path.join(OUT, "tab-counts.tex"), "w").write("\n".join(lines) + "\n")

# ---------------------------------------------------------------- where table: root-first vs unified-space, medians and ranges
def rng(vals):
    vals = [v for v in vals if v is not None]
    if not vals:
        return "--"
    lo, hi = min(vals), max(vals)
    med = statistics.median(vals)
    return ("%g" % med) + (" (%d--%d)" % (lo, hi) if lo != hi else "")

lines = []
lines.append(r"\begin{table}[t]")
lines.append(r"\centering\small")
lines.append(r"\begin{tabular}{@{}l ccc@{}}")
lines.append(r"\toprule")
lines.append(r" & ocean swap & resource swap & both \\")
lines.append(r"\midrule")
def row(label, fn):
    cells = [rng([fn(s, sc) for s in seeds]) for sc in SCEN]
    lines.append(label + " & " + " & ".join(cells) + r" \\")
row(r"goals fixable by root repairs", lambda s, sc: get(v3, s, sc, "classes", {}).get("root", 0))
row(r"\quad needing other unified slots too", lambda s, sc: get(v3, s, sc, "classes", {}).get("unified", 0))
row(r"\quad needing any other slot", lambda s, sc: get(v3, s, sc, "classes", {}).get("all", 0))
row(r"\quad not fixable by any ingredient repair", lambda s, sc: get(v3, s, sc, "classes", {}).get("none", 0))
row(r"irreducible repairs, root first", lambda s, sc: get(v3, s, sc, "irreducible"))
row(r"\quad of which unified may randomize", lambda s, sc: (sum(1 for r in get(v3, s, sc, "repairs_kept", []) if r["unified"]) if get(v3, s, sc, "irreducible") is not None else None))
if vu:
    row(r"goals fixable within unified's move space", lambda s, sc: get(vu, s, sc, "classes", {}).get("uspace") if get(vu, s, sc, "classes") else None)
    row(r"irreducible repairs, unified's space first", lambda s, sc: get(vu, s, sc, "irreducible"))
    row(r"\quad of which outside unified's space", lambda s, sc: (sum(1 for r in get(vu, s, sc, "repairs_kept", []) if not r["unified"]) if get(vu, s, sc, "irreducible") is not None else None))
row(r"debt edges (superposition witness)", lambda s, sc: get(v3, s, sc, "debt_edges"))
lines.append(r"\bottomrule")
lines.append(r"\end{tabular}")
lines.append(r"\caption{Where the repairs are: medians over seeds 1--8 with ranges in parentheses. Root repairs change a lost material's slot in a recipe the losing planet made. ``Unified's move space'' is every slot the recipe-ingredients handler may randomize.}")
lines.append(r"\label{tab:where}")
lines.append(r"\end{table}")
open(os.path.join(OUT, "tab-where.tex"), "w").write("\n".join(lines) + "\n")

# ---------------------------------------------------------------- recurring repairs (both scenario, root-first)
freq = collections.Counter()
info = {}
for s in seeds:
    for r in get(v3, s, "both", "repairs_kept", []):
        k = (r["recipe"], r["material"])
        freq[k] += 1
        info[k] = r
lines = []
lines.append(r"\begin{table}[t]")
lines.append(r"\centering\footnotesize")
lines.append(r"\begin{tabular}{@{}l l r l l l@{}}")
lines.append(r"\toprule")
lines.append(r"recipe & slot & seeds & kind & vanilla rooms & unified \\")
lines.append(r"\midrule")
for (recipe, mat), n in sorted(freq.items(), key=lambda kv: (-kv[1], kv[0])):
    r = info[(recipe, mat)]
    lines.append(r"\code{%s} & \code{%s} & %d & %s & %s & %s \\" % (recipe, mat.split(": ")[1], n, "root" if r["class"] == "root" else "leaf", "one" if r["locality"] == "local" else "several", "yes" if r["unified"] else "no"))
lines.append(r"\bottomrule")
lines.append(r"\end{tabular}")
lines.append(r"\caption{Irreducible repairs for the combined shift (oceans and resources, root slots ordered first), with the number of seeds (of 8) each appears in. \emph{kind}: a root slot, or a leaf slot that the calcite seeds need on top. \emph{vanilla rooms}: ``one'' marks recipes that today's planetary rule edits in place. \emph{unified}: whether unified's recipe-ingredients handler may randomize the slot.}")
lines.append(r"\label{tab:recurring}")
lines.append(r"\end{table}")
open(os.path.join(OUT, "tab-recurring.tex"), "w").write("\n".join(lines) + "\n")

# ---------------------------------------------------------------- summary numbers for prose
def allvals(key, sc=None):
    out = []
    for s in seeds:
        for c in ([sc] if sc else SCEN):
            v = get(v3, s, c, key)
            if v is not None:
                out.append(v)
    return out
fails = allvals("failures")
causes = allvals("causes")
with open(os.path.join(OUT, "results-macros.tex"), "w") as f:
    f.write("\\newcommand{\\CountsFailRange}{%d--%d}\n" % (min(fails), max(fails)))
    f.write("\\newcommand{\\CountsCauseRange}{%d--%d per scenario}\n" % (min(causes), max(causes)))
    unions = allvals("union_after")
    f.write("\\newcommand{\\UnionLossMax}{%d}\n" % max(unions))
    f.write("\\newcommand{\\NumRuns}{%d}\n" % len(unions))
    # unified-space variant: irreducible repair counts next to root-first ones
    def med_range(vals):
        vals = [v for v in vals if v is not None]
        if not vals:
            return "?"
        lo, hi = min(vals), max(vals)
        return "%d" % lo if lo == hi else "%d--%d" % (lo, hi)
    u_seeds = [s for s in seeds if get(vu, s, "oceans", "irreducible") is not None]
    def pair(sc):
        a = med_range([get(vu, s, sc, "irreducible") for s in seeds])
        b = med_range([get(v3, s, sc, "irreducible") for s in seeds if get(vu, s, sc, "irreducible") is not None])
        return a, b
    uo, ro = pair("oceans")
    ur, rr = pair("resources")
    ub, rb = pair("both")
    f.write("\\newcommand{\\USpaceOceans}{%s}\n" % uo)
    f.write("\\newcommand{\\USpaceSeeds}{%d}\n" % len(u_seeds))
    f.write("\\newcommand{\\USpaceSentence}{over the %d seeds measured this way, %s slots instead of %s for the ocean swap, %s instead of %s for the resource swap, and %s instead of %s for the combined shift.}\n" % (len(u_seeds), uo, ro, ur, rr, ub, rb))
print(open(os.path.join(OUT, "tab-where.tex")).read())
print(open(os.path.join(OUT, "tab-recurring.tex")).read())

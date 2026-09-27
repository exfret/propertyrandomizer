#!/usr/bin/env python3
# Charts for the report from out-v3/summary.json (and out-u/summary.json when present)
import json, os, sys, statistics
import matplotlib
matplotlib.use("pdf")
import matplotlib.pyplot as plt
from matplotlib.ticker import FixedLocator, NullLocator, FuncFormatter

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, "figs")
os.makedirs(OUT, exist_ok=True)

# Reference palette (dataviz skill, validated: first three slots pass all-pairs in light mode)
S1, S2, S3 = "#2a78d6", "#eb6834", "#1baf7a"
SURFACE, INK, INK2, MUTED, GRID, AXIS = "#fcfcfb", "#0b0b0b", "#52514e", "#898781", "#e1e0d9", "#c3c2b7"

plt.rcParams.update({
    "font.family": "sans-serif", "font.size": 9, "axes.edgecolor": AXIS, "axes.labelcolor": INK2,
    "xtick.color": INK2, "ytick.color": INK2, "text.color": INK, "axes.linewidth": 0.8,
    "figure.facecolor": SURFACE, "axes.facecolor": SURFACE, "savefig.facecolor": SURFACE,
})

v3 = json.load(open(os.path.join(HERE, "out-v3", "summary.json")))
seeds = sorted(int(s) for s in v3)
SCEN = ["oceans", "resources", "both"]
SCEN_LABEL = {"oceans": "ocean swap", "resources": "resource swap", "both": "both"}

def style(ax, log=False):
    for side in ("top", "right", "left"):
        ax.spines[side].set_visible(False)
    ax.spines["bottom"].set_color(AXIS)
    ax.tick_params(axis="y", length=0)
    ax.tick_params(axis="x", length=0)
    ax.grid(axis="y", color=GRID, linewidth=0.6)
    ax.set_axisbelow(True)

def rounded_bar(ax, x, h, w, color, bottom=0.0, log=False):
    # thin bar; 2px surface gap comes from width < slot
    ax.bar(x, h, w, bottom=bottom, color=color, linewidth=0, zorder=2)

# ---------------------------------------------------------------- counts (log)
measures = [("failures", "failing goal pebbles", S1), ("causes", "root causes", S2), ("irreducible", "irreducible repairs", S3)]
fig, ax = plt.subplots(figsize=(6.6, 3.1))
style(ax)
w = 0.24
for i, sc in enumerate(SCEN):
    for j, (key, label, color) in enumerate(measures):
        vals = [v3[str(s)][sc][key] for s in seeds if sc in v3[str(s)] and key in v3[str(s)][sc]]
        if not vals:
            continue
        med = statistics.median(vals)
        x = i + (j - 1) * (w + 0.03)
        ax.bar(x, med, w, color=color, linewidth=0, zorder=2, label=label if i == 0 else None)
        # per-seed values as small dots just right of the bar; the median value above the bar
        ax.scatter([x + w * 0.62] * len(vals), vals, s=8, color=INK2, zorder=3, linewidths=0, alpha=0.6)
        ax.text(x, med * 1.07, "%g" % med, ha="center", va="bottom", fontsize=8, color=INK)
ax.set_yscale("log")
ax.set_ylim(1, 400)
ax.yaxis.set_major_locator(FixedLocator([1, 3, 10, 30, 100, 300]))
ax.yaxis.set_minor_locator(NullLocator())
ax.yaxis.set_major_formatter(FuncFormatter(lambda v, _: "%d" % v))
ax.set_xticks(range(len(SCEN)))
ax.set_xticklabels([SCEN_LABEL[s] for s in SCEN])
ax.set_ylabel("count per seed (log scale)")
leg = ax.legend(frameon=False, ncol=3, loc="upper center", bbox_to_anchor=(0.5, 1.16), fontsize=8.5, handlelength=1.2)
fig.tight_layout()
fig.savefig(os.path.join(OUT, "counts.pdf"))
plt.close(fig)

# ---------------------------------------------------------------- where: irreducible root-first repairs inside/outside unified's move space
fig, axes = plt.subplots(1, 3, figsize=(6.6, 2.5), sharey=True)
ymax = 0
for sc in SCEN:
    for s in seeds:
        ymax = max(ymax, len(v3[str(s)].get(sc, {}).get("repairs_kept", [])))
for ax, sc in zip(axes, SCEN):
    style(ax)
    ins, outs = [], []
    for s in seeds:
        kept = v3[str(s)].get(sc, {}).get("repairs_kept", [])
        ins.append(sum(1 for r in kept if r["unified"]))
        outs.append(sum(1 for r in kept if not r["unified"]))
    xs = list(range(len(seeds)))
    ax.bar(xs, ins, 0.62, color=S1, linewidth=0, zorder=2, label="inside unified's move space")
    # 2px-ish surface gap between stacked segments
    ax.bar(xs, outs, 0.62, bottom=[i + 0.12 for i in ins], color=S2, linewidth=0, zorder=2, label="outside (blacklisted slot or recipe)")
    # dagger: some goals of this run can't be fixed by any ingredient repair (Section 6.5)
    for x, s in zip(xs, seeds):
        if v3[str(s)].get(sc, {}).get("classes", {}).get("none", 0) > 0:
            ax.text(x, ins[x] + outs[x] + 0.5, "\u2020", ha="center", va="bottom", fontsize=9, color=INK)
    ax.set_xticks(xs)
    ax.set_xticklabels([str(s) for s in seeds], fontsize=7.5)
    ax.set_title(SCEN_LABEL[sc], fontsize=9, color=INK)
    ax.set_xlabel("seed", fontsize=8)
    ax.set_ylim(0, ymax + 3)
axes[0].set_ylabel("irreducible repairs")
handles, labels = axes[0].get_legend_handles_labels()
fig.legend(handles, labels, frameon=False, ncol=2, loc="upper center", bbox_to_anchor=(0.5, 1.03), fontsize=8.5, handlelength=1.2)
fig.tight_layout(rect=(0, 0, 1, 0.9))
fig.savefig(os.path.join(OUT, "where.pdf"))
plt.close(fig)

# ---------------------------------------------------------------- root-first vs unified-space repairs (if measured)
upath = os.path.join(HERE, "out-u", "summary.json")
if os.path.exists(upath):
    vu = json.load(open(upath))
    fig, axes = plt.subplots(1, 3, figsize=(6.6, 2.5), sharey=True)
    ymax = 0
    rows = {}
    for sc in SCEN:
        a, b = [], []
        for s in seeds:
            a.append(v3[str(s)].get(sc, {}).get("irreducible"))
            b.append(vu.get(str(s), {}).get(sc, {}).get("irreducible"))
        rows[sc] = (a, b)
        ymax = max([ymax] + [x for x in a + b if x is not None])
    for ax, sc in zip(axes, SCEN):
        style(ax)
        a, b = rows[sc]
        xs = list(range(len(seeds)))
        ax.bar([x - 0.19 for x in xs], [v or 0 for v in a], 0.34, color=S1, linewidth=0, zorder=2, label="root repairs first")
        ax.bar([x + 0.19 for x in xs], [v or 0 for v in b], 0.34, color=S2, linewidth=0, zorder=2, label="unified's move space first")
        for x, v in zip(xs, b):
            if v is None:
                ax.text(x + 0.19, 0.5, "n/a", ha="center", fontsize=6, color=MUTED, rotation=90)
        ax.set_xticks(xs)
        ax.set_xticklabels([str(s) for s in seeds], fontsize=7.5)
        ax.set_title(SCEN_LABEL[sc], fontsize=9, color=INK)
        ax.set_xlabel("seed", fontsize=8)
        ax.set_ylim(0, ymax * 1.12 + 1)
    axes[0].set_ylabel("irreducible repairs")
    handles, labels = axes[0].get_legend_handles_labels()
    fig.legend(handles, labels, frameon=False, ncol=2, loc="upper center", bbox_to_anchor=(0.5, 1.03), fontsize=8.5, handlelength=1.2)
    fig.tight_layout(rect=(0, 0, 1, 0.9))
    fig.savefig(os.path.join(OUT, "uspace.pdf"))
    plt.close(fig)
print("charts written to", OUT)

"""Paired performance gate on Lua instruction counts (dev/counter-mod).

A count repeats exactly for the same code and game, whatever else the machine is running, so one baseline/candidate pair decides.
Game runtime is kept next to it for information only.
"""

import math


def millions(count):
    return f"{count / 1e6:.1f}M"


def describe(phase, values):
    line = f"{phase}: {millions(values['baseline'])} -> {millions(values['candidate'])} Lua instructions ({values['ratio']:.2f}x)"
    before, after = values.get("baseline_seconds"), values.get("candidate_seconds")
    if before is not None and after is not None:
        line += f"; runtime {before:.2f}s -> {after:.2f}s"
    return line


def compare(run_sample, phases, percent=25, instructions=200e6):
    samples = {"baseline": [], "candidate": []}
    report = {"samples": samples, "percent": percent, "instructions": instructions, "phases": {}}
    for side in ("baseline", "candidate"):
        result = run_sample(side, 1)
        sample = {"instructions": result.get("instructions", {}), "timings": result.get("timings", {}), "dir": result["dir"],
                  "ok": result["ok"], "problems": result["problems"][:]}
        samples[side].append(sample)
        if not sample["ok"]:
            return report, f"timing comparison failed: {side}: " + "; ".join(sample["problems"]) + f" (logs: {sample['dir']})"
        for phase in phases:
            value = sample["instructions"].get(phase)
            if not isinstance(value, int) or value < 0:
                return report, f"timing comparison failed: missing/invalid {side} {phase} instruction count (logs: {sample['dir']})"

    slow = []
    for phase in phases:
        before = samples["baseline"][0]["instructions"][phase]
        after = samples["candidate"][0]["instructions"][phase]
        ratio = after / before if before > 0 else (1.0 if after == 0 else math.inf)
        regression = after > before * (1 + percent / 100) and after - before >= instructions
        report["phases"][phase] = {"baseline": before, "candidate": after, "ratio": ratio, "regression": regression,
                                   "baseline_seconds": samples["baseline"][0]["timings"].get(phase),
                                   "candidate_seconds": samples["candidate"][0]["timings"].get(phase)}
        if regression:
            slow.append(f"{phase}: {millions(before)} -> {millions(after)} Lua instructions ({ratio:.2f}x)")
    if slow:
        return report, "Lua instruction regression: " + "; ".join(slow) + f"; limit is >{percent:g}% and >= {millions(instructions)} more"
    return report, None

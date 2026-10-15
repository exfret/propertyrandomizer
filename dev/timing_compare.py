"""Paired performance gate. Callbacks run fresh, isolated baseline/candidate samples."""

import math
import statistics


def compare(run_sample, phases, percent=25, seconds=2):
    samples = {"baseline": [], "candidate": []}
    report = {"samples": samples, "percent": percent, "seconds": seconds, "phases": {}}

    def measure(attempt):
        # Reverse the order on the confirmation run to reduce cache/order bias.
        order = ("candidate", "baseline") if attempt == 2 else ("baseline", "candidate")
        for side in order:
            result = run_sample(side, attempt)
            sample = {"timings": result.get("timings", {}), "dir": result["dir"],
                      "ok": result["ok"], "problems": result["problems"][:]}
            samples[side].append(sample)
            if not sample["ok"]:
                return f"timing comparison failed: {side} attempt {attempt}: " + "; ".join(sample["problems"]) + f" (logs: {sample['dir']})"
            for phase in phases:
                value = sample["timings"].get(phase)
                if value is None or not math.isfinite(value) or value <= 0:
                    return f"timing comparison failed: missing/invalid {side} {phase} timing (logs: {sample['dir']})"
        return None

    def evaluate():
        slow = []
        for phase in phases:
            before = statistics.median(sample["timings"][phase] for sample in samples["baseline"])
            after = statistics.median(sample["timings"][phase] for sample in samples["candidate"])
            regression = after > before * (1 + percent / 100) and after - before >= seconds
            report["phases"][phase] = {"baseline": before, "candidate": after, "ratio": after / before,
                                       "regression": regression}
            if regression:
                slow.append(f"{phase}: {before:.2f}s -> {after:.2f}s ({after / before:.2f}x)")
        return slow

    error = measure(1)
    if error:
        return report, error
    if evaluate():
        for attempt in (2, 3):
            error = measure(attempt)
            if error:
                return report, error
        slow = evaluate()
        if slow:
            return report, "timing regression (median of 3 pairs): " + "; ".join(slow) + f"; limit is >{percent:g}% and >= {seconds:g}s slower"
    return report, None

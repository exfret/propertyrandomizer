#!/usr/bin/env python3
# Reads a Factorio log from a profiled load (dev/run-tests.py --profile, which runs dev/profiler-mod in Instrument Mode) and reports where the data stage's time went
#
# The profiler logs "PRPROF <stack id>" every so many Lua instructions; each sample gets the wall time since the sample before, from the log's timestamps
# So the times include C functions and garbage collection, attributed to the Lua code running around them; the profiler's own overhead (a few percent) is spread the same way
# Times are wall time on a machine that may be busy with other runs, so compare shares more than seconds
#
# Usage:
#   dev/profile-report.py LOG [--source DIR] [--top N] [--tree-min PERCENT]
#     LOG            a run's create.log
#     --source DIR   the mod folder the run used, for function names (default: this repo)

import argparse
import collections
import os
import re
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GAME_DATA = "/Applications/factorio.app/Contents/data"
LINE = re.compile(r"^\s*(\d+\.\d+) (.*)$")
SAMPLE = re.compile(r"PRPROF (\d+)$")
START = re.compile(r"PRPROF start interval=(\d+)")
STOP = re.compile(r"PRPROF stop samples=(\d+)")
DEFINITIONS = re.compile(r"(PRPROFFN|PRPROFST) (.*)$")
# The data stage's phases, from the randomizer's own log lines; a phase lasts until the next one starts
PHASES = [
    ("data stage before the randomizer's data-final-fixes", re.compile(r"PRPROF start")),
    ("randomizer: reformat, shared references", re.compile(r"Loading mod propertyrandomizer .*\(data-final-fixes\.lua\)")),
    ("randomizer: config, compat, prefixes, planetary", re.compile(r"data-final-fixes\.lua:\d+: Gathering config")),
    ("randomizer: copy of data.raw", re.compile(r"data-final-fixes\.lua:\d+: Loading in new dependency graph file")),
    ("randomizer: initial logic, sorts and costs", re.compile(r"data-final-fixes\.lua:\d+: Initial reachability check")),
    ("unified: graph prep", re.compile(r"execute\.lua:\d+: GRAPH PREP")),
    ("unified: claiming", re.compile(r"execute\.lua:\d+: CLAIMING")),
    ("unified: pools", re.compile(r"execute\.lua:\d+: CALCULATE POOLS")),
    ("unified: first pass", re.compile(r"execute\.lua:\d+: FIRST PASS")),
    ("unified: context reachability", re.compile(r"execute\.lua:\d+: CONTEXT REACHABILITY")),
    ("unified: shuffle", re.compile(r"execute\.lua:\d+: SHUFFLE")),
    ("unified: reflect, recycling, UNIFIEDCHECK", re.compile(r"execute\.lua:\d+: REFLECT")),
    ("randomizer: old logic graph", re.compile(r"data-final-fixes\.lua:\d+: Building dependency graph")),
    ("randomizer: old graph randomizations", re.compile(r"data-final-fixes\.lua:\d+: Applying graph-based randomizations")),
    ("randomizer: numerical", re.compile(r"data-final-fixes\.lua:\d+: Applying numerical/misc randomizations")),
    ("randomizer: recycling, extra randomizations", re.compile(r"data-final-fixes\.lua:\d+: Done applying numerical/misc randomizations")),
    ("randomizer: fixes, final checks", re.compile(r"data-final-fixes\.lua:\d+: Applying fixes")),
    ("randomizer: control stage info", re.compile(r"data-final-fixes\.lua:\d+: Smuggling control info")),
    ("after the randomizer", re.compile(r"data-final-fixes\.lua:\d+: Done!")),
]
NAME_PATTERNS = [
    re.compile(r"function\s+([\w.:\[\]\"'-]+)\s*\("),
    re.compile(r"([\w.\[\]\"'-]+)\s*=\s*function\s*\("),
]


class Profile:
    def __init__(self, log_path):
        self.functions = {}
        self.stacks = {}
        # (stack id, seconds, phase) per sample
        self.samples = []
        self.phase_seconds = collections.OrderedDict()
        self.interval = None
        self.total = 0.0
        self.end = 0.0
        last_sample = None
        phase = None
        phase_start = None
        with open(log_path, errors="replace") as f:
            for raw in f:
                match = LINE.match(raw.rstrip("\n"))
                if match is None:
                    continue
                time = float(match.group(1))
                text = match.group(2)
                sample = SAMPLE.search(text)
                if sample is not None and last_sample is not None:
                    self.samples.append((int(sample.group(1)), time - last_sample, phase))
                    last_sample = time
                    continue
                start = START.search(text)
                if start is not None:
                    self.interval = int(start.group(1))
                    last_sample = time
                if STOP.search(text) is not None:
                    last_sample = None
                definitions = DEFINITIONS.search(text)
                if definitions is not None:
                    target = self.functions if definitions.group(1) == "PRPROFFN" else self.stacks
                    for part in definitions.group(2).split("\t"):
                        number, _, value = part.partition("=")
                        target[int(number)] = value
                    continue
                for name, pattern in PHASES:
                    if pattern.search(text):
                        if phase is not None:
                            self.phase_seconds[phase] = self.phase_seconds.get(phase, 0.0) + time - phase_start
                        phase = name
                        phase_start = time
                        break
                self.end = time
        if phase is not None:
            self.phase_seconds[phase] = self.phase_seconds.get(phase, 0.0) + self.end - phase_start
        self.total = sum(seconds for _, seconds, _ in self.samples)
        # Stack id -> (function ids from the outermost call inwards, running line)
        self.parsed = {}
        for stack_id, text in self.stacks.items():
            frames, _, line = text.partition(";")
            ids = [int(part) for part in frames.split(",") if part != ""]
            ids.reverse()
            self.parsed[stack_id] = (ids, line)


class Names:
    # Readable names for function ids, from the source files the run loaded
    def __init__(self, functions, source):
        self.functions = functions
        self.roots = {
            "propertyrandomizer": source,
            "propertyrandomizer-test-helper": os.path.join(REPO, "dev", "test-helper-mod"),
            "propertyrandomizer-profiler": os.path.join(REPO, "dev", "profiler-mod"),
        }
        self.files = {}
        self.cache = {}

    def lines(self, path):
        if path not in self.files:
            try:
                with open(path, errors="replace") as f:
                    self.files[path] = f.read().splitlines()
            except OSError:
                self.files[path] = None
        return self.files[path]

    def location(self, function_id):
        key = self.functions.get(function_id, "?")
        if key.startswith("=[C]:"):
            return None, None, "[C] " + key[len("=[C]:"):]
        source, _, line = key.rpartition(":")
        match = re.match(r"@__(.+?)__/(.*)$", source)
        if match is None:
            return None, None, key
        mod, relative = match.groups()
        root = self.roots.get(mod, os.path.join(GAME_DATA, mod))
        short = relative if mod == "propertyrandomizer" else "__" + mod + "__/" + relative
        return os.path.join(root, relative), int(line), short

    def name(self, function_id):
        if function_id in self.cache:
            return self.cache[function_id]
        path, line, short = self.location(function_id)
        if path is None:
            result = short
        elif line == 0:
            result = short + " (main chunk)"
        else:
            label = "(anonymous)"
            lines = self.lines(path)
            if lines is not None and 0 < line <= len(lines):
                text = lines[line - 1].strip()
                for pattern in NAME_PATTERNS:
                    match = pattern.search(text)
                    if match is not None:
                        label = match.group(1)
                        break
                else:
                    label = "(anonymous: " + text[:60] + ")"
            result = short + ":" + str(line) + " " + label
        self.cache[function_id] = result
        return result


def percent(seconds, total):
    return (100 * seconds / total) if total > 0 else 0.0


def report(profile, names, top, tree_min):
    out = []
    total = profile.total
    count = len(profile.samples)
    if count == 0:
        return "No PRPROF samples in this log (was the profiler mod loaded with --instrument-mod and --enable-unsafe-lua-debug-api?)\n"
    longest = max(seconds for _, seconds, _ in profile.samples)
    out.append("Sampled %.1f s of Lua in %d samples (every %s instructions; %.2f ms per sample on average, longest %.0f ms)" % (total, count, profile.interval, 1000 * total / count, 1000 * longest))
    out.append("Times are wall time, including C functions and garbage collection around the sampled Lua, and the profiler's own overhead")
    out.append("")

    out.append("Phases (wall time from the log, including time outside Lua)")
    load_total = sum(profile.phase_seconds.values())
    for phase, seconds in profile.phase_seconds.items():
        out.append("  %7.2f s %5.1f%%  %s" % (seconds, percent(seconds, load_total), phase))
    out.append("")

    self_time = collections.Counter()
    inclusive = collections.Counter()
    line_time = collections.Counter()
    for stack_id, seconds, _ in profile.samples:
        ids, line = profile.parsed.get(stack_id, ([], "?"))
        if len(ids) == 0:
            continue
        self_time[ids[-1]] += seconds
        line_time[(ids[-1], line)] += seconds
        for function_id in set(ids):
            inclusive[function_id] += seconds

    def table(title, counter, label):
        out.append(title)
        for item, seconds in counter.most_common(top):
            out.append("  %7.2f s %5.1f%%  %s" % (seconds, percent(seconds, total), label(item)))
        out.append("")

    table("Self time: the function that was running", self_time, names.name)
    table("Inclusive time: the function was running or on the stack", inclusive, names.name)

    def line_label(item):
        function_id, line = item
        path, _, short = names.location(function_id)
        text = ""
        lines = names.lines(path) if path is not None else None
        if lines is not None and line.isdigit() and 0 < int(line) <= len(lines):
            text = "  " + lines[int(line) - 1].strip()[:90]
        return short.split(":")[0] + ":" + line + text

    table("Lines: the line that was running", line_time, line_label)

    # Call tree: inclusive time along each call path, outermost first; direct recursion is folded into one node
    root = {"seconds": 0.0, "children": {}}
    for stack_id, seconds, _ in profile.samples:
        ids, _ = profile.parsed.get(stack_id, ([], "?"))
        node = root
        node["seconds"] += seconds
        previous = None
        for function_id in ids:
            if function_id == previous:
                continue
            previous = function_id
            children = node["children"]
            if function_id not in children:
                children[function_id] = {"seconds": 0.0, "children": {}}
            node = children[function_id]
            node["seconds"] += seconds
    out.append("Call tree (inclusive time, paths with at least %g%% of the sampled time)" % tree_min)

    def walk(node, depth):
        for function_id, child in sorted(node["children"].items(), key=lambda item: -item[1]["seconds"]):
            if percent(child["seconds"], total) < tree_min:
                continue
            out.append("  %7.2f s %5.1f%%  %s%s" % (child["seconds"], percent(child["seconds"], total), "  " * depth, names.name(function_id)))
            walk(child, depth + 1)

    walk(root, 0)
    out.append("")
    return "\n".join(out) + "\n"


def write_report(log_path, out_path, source=REPO, top=40, tree_min=1.0):
    profile = Profile(log_path)
    text = report(profile, Names(profile.functions, source), top, tree_min)
    with open(out_path, "w") as f:
        f.write(text)
    return text


def main(argv):
    parser = argparse.ArgumentParser(description="Where a profiled load's data stage spent its time (see the comment at the top of this file)")
    parser.add_argument("log", help="a run's create.log from dev/run-tests.py --profile")
    parser.add_argument("--source", default=REPO, help="the mod folder the run used, for function names")
    parser.add_argument("--top", type=int, default=40, help="rows in each table")
    parser.add_argument("--tree-min", type=float, default=1.0, help="leave call paths under this percent of the time out of the tree")
    args = parser.parse_args(argv)
    profile = Profile(args.log)
    sys.stdout.write(report(profile, Names(profile.functions, args.source), args.top, args.tree_min))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

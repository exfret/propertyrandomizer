#!/usr/bin/env python3
# Parses CONTRA logs (out-v3/seed-N.txt) into summary.json for the report's tables and charts
import json, os, re, sys, glob, collections

d = sys.argv[1] if len(sys.argv) > 1 else "out-v3"
seeds = {}
for path in sorted(glob.glob(os.path.join(d, "seed-*.txt")), key=lambda p: int(re.search(r"seed-(\d+)", p).group(1))):
    seed = int(re.search(r"seed-(\d+)", path).group(1))
    S = {}
    for raw in open(path):
        line = re.sub(r"^\[[\d.]+\] ", "", raw.rstrip("\n"))
        m = re.match(r"(oceans|resources|both) (.*)$", line)
        if not m:
            continue
        sc, rest = m.group(1), m.group(2)
        s = S.setdefault(sc, {"repairs_kept": [], "repairs_witness": [], "debts": [], "cause_list": [], "classes": collections.Counter(), "failure_kinds": {}})
        if rest.startswith("applied: "):
            s["applied"] = rest[len("applied: "):]
        elif rest.startswith("failures "):
            m2 = re.match(r"failures (\d+) \{(.*)\}", rest)
            s["failures"] = int(m2.group(1))
            for part in m2.group(2).split(", "):
                if part:
                    k, v = part.rsplit(" ", 1)
                    s["failure_kinds"][k] = int(v)
        elif rest.startswith("distinct causes "):
            m2 = re.match(r"distinct causes (\d+), distinct cause sets (\d+)", rest)
            s["causes"] = int(m2.group(1)); s["cause_sets"] = int(m2.group(2))
        elif rest.startswith("cause ") and " on " in rest and "failure witnesses" in rest:
            m2 = re.match(r"cause (.*) on (\d+) failure witnesses", rest)
            s["cause_list"].append((m2.group(1), int(m2.group(2))))
        elif rest.startswith("ingredient slots by class"):
            m2 = re.match(r"ingredient slots by class: root (\d+) \((\d+) of them unified-randomizable\), unified (\d+), all (\d+)", rest)
            if m2:
                s["root_slots"], s["root_slots_unified"], s["unified_slots"], s["other_slots"] = map(int, m2.groups())
            else:
                m2 = re.match(r"ingredient slots by class: uspace (\d+), rest (\d+)", rest)
                s["uspace_slots"], s["rest_slots"] = map(int, m2.groups())
        elif rest.startswith("fixed at stage"):
            for part in re.match(r"fixed at stage \{(.*)\}", rest).group(1).split(", "):
                k, v = part.rsplit(" ", 1)
                s["classes"][k] = int(v)
        elif rest.startswith("repair witness"):
            m2 = re.match(r"repair witness (\d+) pebbles; repairs used \{root (\d+) slots/(\d+) recipes, unified (\d+) slots/(\d+) recipes, all (\d+) slots/(\d+) recipes\}", rest)
            if m2:
                g = list(map(int, m2.groups()))
                s["witness_pebbles"] = g[0]
                s["witness_repairs"] = {"root": g[1], "unified": g[3], "all": g[5]}
            else:
                m2 = re.match(r"repair witness (\d+) pebbles; repairs used \{uspace (\d+) slots/(\d+) recipes, rest (\d+) slots/(\d+) recipes\}", rest)
                g = list(map(int, m2.groups()))
                s["witness_pebbles"] = g[0]
                s["witness_repairs"] = {"uspace": g[1], "rest": g[3]}
        elif rest.startswith("repair "):
            m2 = re.match(r"repair (\S+) (\S+) recipe: (\S+) slot (\S+: \S+) @ \{(.*)\}", rest)
            if m2:
                s["repairs_witness"].append({"class": m2.group(1), "locality": m2.group(2), "recipe": m2.group(3), "material": m2.group(4), "contexts": m2.group(5)})
        elif rest.startswith("irreducible repairs"):
            m2 = re.match(r"irreducible repairs (\d+) slots on (\d+) recipes", rest)
            s["irreducible"] = int(m2.group(1)); s["irreducible_recipes"] = int(m2.group(2))
        elif rest.startswith("kept repair"):
            m2 = re.match(r"kept repair (\S+) (\S+) recipe: (\S+) slot (\S+: \S+) \((.*)\)", rest)
            s["repairs_kept"].append({"class": m2.group(1), "locality": m2.group(2), "recipe": m2.group(3), "material": m2.group(4), "unified": m2.group(5) == "unified-randomizable"})
        elif rest.startswith("prune"):
            s.setdefault("prune_notes", []).append(rest)
        elif rest.startswith("union: "):
            m2 = re.match(r"union: (\d+) vanilla-only edges \(into (.*) nodes\); failures before gate (\d+), after (\d+)", rest)
            s["union_edges"] = int(m2.group(1)); s["union_ops"] = m2.group(2)
            s["union_before"] = int(m2.group(3)); s["union_after"] = int(m2.group(4))
        elif rest.startswith("union witness uses"):
            s["debt_edges"] = int(re.match(r"union witness uses (\d+)", rest).group(1))
        elif rest.startswith("debt edge "):
            s["debts"].append(rest[len("debt edge "):])
        elif rest.startswith("class "):
            pass
    seeds[seed] = S
json.dump(seeds, open(os.path.join(d, "summary.json"), "w"), indent=1, default=list)

# Console table
for sc in ["oceans", "resources", "both"]:
    print("== " + sc)
    print("seed fails  causes sets  rootslots(unif)  fixed_at  witness  irreducible(unif/not)  union_after debt_edges")
    for seed, S in sorted(seeds.items()):
        s = S.get(sc)
        if not s or "failures" not in s:
            continue
        kept = s["repairs_kept"]
        nu = sum(1 for r in kept if r["unified"])
        print("%4d %5d  %6s %4s  %4s(%s)  %-20s %3s  %3s (%d/%d)  %s %s" % (
            seed, s["failures"], s.get("causes"), s.get("cause_sets"), s.get("root_slots"), s.get("root_slots_unified"),
            dict(s["classes"]), s.get("witness_repairs", {}).get("root"), s.get("irreducible"), nu, len(kept) - nu,
            s.get("union_after"), s.get("debt_edges")))

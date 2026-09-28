# Turns the FPREPORT lines in logs/seed-*.txt into the rows of tab-rounds.tex and prints summary ranges
import re, glob, os, statistics
here = os.path.dirname(os.path.abspath(__file__))
rows = []
for path in sorted(glob.glob(os.path.join(here, "logs", "seed-*.txt"))):
    seed = re.search(r"seed-(\d+)", path).group(1)
    attempt = 0
    cur = {}
    for line in open(path):
        if "hard pebbles kept exactly" in line:
            attempt += 1
        m = re.search(r"FPREPORT round=(\d+) .*closure=(\d+) closure_trav_pebbles=(\d+) needy_travs=(\d+) needs=(\d+) .*launchable_slots=(\d+) unproven=(\d+)", line)
        if m:
            cur = {"seed": seed, "attempt": attempt, "round": int(m.group(1)), "closure": int(m.group(2)), "closure_trav": int(m.group(3)), "needy": int(m.group(4)), "needs": int(m.group(5)), "launch": int(m.group(6)), "unproven": int(m.group(7))}
        m = re.search(r"FPREPORT admissible buckets\(0,1-5,6-20,21-50,>50\)=(\d+),(\d+),(\d+),(\d+),(\d+) needy_n=\d+ needy_mean=([\d.]+) free_n=\d+ free_mean=([\d.]+)", line)
        if m:
            cur.update({"pinned": int(m.group(1)), "adm_needy": float(m.group(6)), "adm_free": float(m.group(7))})
        m = re.search(r"round (\d+) done with (\d+) refinements; (\d+) identities moved; (\d+) of (\d+) resource", line)
        if m:
            cur.update({"refinements": int(m.group(2)), "moved": int(m.group(3)), "res": int(m.group(4)), "res_total": int(m.group(5))})
        m = re.search(r"FPREPORT moves round=\d+ changed_vs_prev=(\d+) moved_vs_vanilla=\d+ needy_moved=(\d+) needy_earlier=(\d+) needy_mean_shift=(-?[\d.]+) free_moved=(\d+) free_earlier=(\d+) free_mean_shift=(-?[\d.]+)", line)
        if m:
            cur.update({"changed": int(m.group(1)), "nm": int(m.group(2)), "ne": int(m.group(3)), "ns": float(m.group(4)), "fm": int(m.group(5)), "fe": int(m.group(6)), "fs": float(m.group(7))})
            rows.append(cur)
            cur = {}
with open(os.path.join(here, "..", "tab-rounds.tex"), "w") as out:
    out.write(open(os.path.join(here, "tab-rounds-header.tex.txt")).read())
    for r in rows:
        out.write("{seed} & {attempt} & {round} & {needy} & {needs} & {launch} & {pinned} & {adm_needy:.0f} & {adm_free:.0f} & {moved} & {changed} & {ne}/{nm} ({ns:+.2f}) & {fe}/{fm} ({fs:+.2f}) & {res}/{res_total} & {refinements}\\\\\n".format(**r))
    out.write(open(os.path.join(here, "tab-rounds-footer.tex.txt")).read())
def rng(k):
    vals = [r[k] for r in rows]
    return min(vals), max(vals)
for k in ["closure", "closure_trav", "needy", "needs", "launch", "pinned", "adm_needy", "adm_free", "moved", "changed", "refinements", "unproven", "nm", "fm"]:
    print(k, rng(k))
r1 = [r for r in rows if r["round"] == 1]
print("round1 needy earlier frac", sum(r["ne"] for r in r1) / sum(r["nm"] for r in r1), "free earlier frac", sum(r["fe"] for r in r1) / sum(r["fm"] for r in r1))
print("round1 needy shift", [r["ns"] for r in r1], "free shift", [r["fs"] for r in r1])
print("all needy earlier frac", sum(r["ne"] for r in rows) / sum(r["nm"] for r in rows), "free", sum(r["fe"] for r in rows) / sum(r["fm"] for r in rows))
print("rows", len(rows))

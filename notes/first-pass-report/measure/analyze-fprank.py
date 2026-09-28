# Reads FPRANK lines (see patch-fprank.py) from the given logs and reports whether late identities end up early
import re, sys, statistics
LINE = re.compile(r"FPRANK trav=(.+?) old=(.+?) new=(.+?) van=(\S+) van2=(\S+) fin=(\S+) vanN=(\S+) van2N=(\S+) finN=(\S+) newslot_van=(\S+) early_ok=(\d+) early_type=(\d+)")

def num(x):
    return None if x == "-" else float(x)

def spearman(pairs):
    # Inputs are already percentiles among the same set, but re-rank to handle missing values
    pairs = [p for p in pairs if p[0] is not None and p[1] is not None]
    def ranks(v):
        order = sorted(range(len(v)), key=lambda i: v[i])
        r = [0] * len(v)
        for pos, i in enumerate(order):
            r[i] = pos
        return r
    a = ranks([p[0] for p in pairs])
    b = ranks([p[1] for p in pairs])
    n = len(pairs)
    d2 = sum((x - y) ** 2 for x, y in zip(a, b))
    return 1 - 6 * d2 / (n * (n * n - 1)), n

def third(x):
    return 0 if x < 1 / 3 else (1 if x < 2 / 3 else 2)

def matrix(pairs):
    m = [[0] * 3 for _ in range(3)]
    for a, b in pairs:
        if a is not None and b is not None:
            m[third(a)][third(b)] += 1
    return m

runs = []
for path in sys.argv[1:]:
    attempt = 0
    rows = {}
    for line in open(path, errors="replace"):
        if "hard pebbles kept exactly" in line:
            attempt += 1
        m = LINE.search(line)
        if m:
            g = m.groups()
            rows.setdefault(attempt, []).append({"trav": g[0], "old": g[1], "new": g[2], "van": num(g[3]), "van2": num(g[4]), "fin": num(g[5]), "vanN": num(g[6]), "van2N": num(g[7]), "finN": num(g[8]), "newslot": num(g[9]), "early_ok": int(g[10]), "early_type": int(g[11])})
    for attempt, r in sorted(rows.items()):
        runs.append((path, attempt, r))

for path, attempt, r in runs:
    print("==", path.split("/")[-2], "attempt", attempt, "identities", len(r))
    for label, a, b in [("vanilla vs final (any room)", "van", "fin"), ("vanilla vs 2nd vanilla sort (noise)", "van", "van2"), ("vanilla vs final (starting planet)", "vanN", "finN"), ("vanilla vs 2nd vanilla (starting planet)", "vanN", "van2N")]:
        pairs = [(x[a], x[b]) for x in r]
        rho, n = spearman(pairs)
        m = matrix(pairs)
        late = sum(m[2])
        print("  %-42s spearman %.2f (n=%d)  late->early %d/%d  early->late %d/%d  thirds %s" % (label, rho, n, m[2][0], late, m[0][2], sum(m[0]), m))
    late = [x for x in r if x["van"] is not None and x["van"] >= 2 / 3]
    oks = [x["early_ok"] for x in late]
    print("  late identities: %d; early slots their cost allows: median %s, zero for %d; early slots of their type: median %s" % (len(late), statistics.median(oks), sum(1 for o in oks if o == 0), statistics.median([x["early_type"] for x in late])))
    moved_late = [x for x in late if x["newslot"] is not None]
    print("  late identities now in an early position (by the position's vanilla rank): %d/%d" % (sum(1 for x in moved_late if x["newslot"] <= 1 / 3), len(moved_late)))
    jumps = sorted([x for x in r if x["vanN"] is not None and x["finN"] is not None], key=lambda x: x["finN"] - x["vanN"])
    print("  biggest moves earlier on the starting planet (vanilla pct -> final pct, new position):")
    for x in jumps[:12]:
        print("    %-34s %.2f -> %.2f  at %s" % (x["trav"].replace("item: ", "").replace("-trav", ""), x["vanN"], x["finN"], x["new"].replace("item: ", "")))

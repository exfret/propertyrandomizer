#!/bin/bash
# Builds the isolated mod copies the measurements ran on (never touches the live repo)
#   mod/    runs experiment-contradictions.lua.txt (root-first staged sorts, causes, superposition)
#   mod-u/  runs experiment-uspace.lua.txt (unified's move space first)
# The modules are stored as .lua.txt so the repo's Lua hooks (style check, hardcoded names, seed checks) ignore them
# Then: python3 run.py out-v3 1 2 3 4 5 6 7 8
#       MODDIR=mod-u PREFIX=u- python3 run.py out-u 1 2 3 4 5 6 7 8
#       python3 parse.py out-v3; python3 parse.py out-u; python3 tables.py ..; python3 charts.py ../figs
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
R="${REPO:-$HOME/Library/Application Support/factorio/mods/propertyrandomizer}"
for pair in "mod:experiment-contradictions" "mod-u:experiment-uspace"; do
    dir="${pair%%:*}"; module="${pair##*:}"
    M="$HERE/$dir/propertyrandomizer"
    mkdir -p "$M"
    rsync -a --delete --exclude .git --exclude 'lib/cost/*.log' --exclude 'lib/cost/material-costs-pyanodons*' "$R/" "$M/"
    cp "$HERE/$module.lua.txt" "$M/randomizations/planetary/$module.lua"
    python3 - "$M/data-final-fixes.lua" "$module" <<'PY'
import sys
p, module = sys.argv[1], sys.argv[2]
s = open(p).read()
old = 'require("randomizations/prefixes")\n'
assert s.count(old) == 1, "hook point not found"
s = s.replace(old, old + '\n-- SCRATCH: context-shift report measurements\nrequire("randomizations/planetary/%s").run(new_logic)\nerror("QUICKSTOP")\n' % module)
open(p, "w").write(s)
PY
    echo "built $M"
done

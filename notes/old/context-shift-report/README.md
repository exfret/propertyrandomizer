# Contexts that move: report

Moved to notes/old/ on 2026-10-01: superposed mode, which this report is the theory of, is off and retired from the plans (its code stays until it's removed). The current planetary approach is in notes/planetary-approach.md.

A theory of references, debts and repairs for multipass randomization with planetary context shifts (26 September 2026).

- `main.pdf`: the compiled report.
- `main.tex`: the source. It inputs `macros.tex`, the `sec-*.tex` sections, the generated tables `tab-*.tex`, and `results-macros.tex` / `results-text.tex`.
- `figs/`: the charts (`counts.pdf`, `where.pdf`, `uspace.pdf`). All diagrams are TikZ, inline in the sections.
- `experiment/`: the measurements from Section 6 and Appendix A.
  - `experiment-contradictions.lua.txt` and `experiment-uspace.lua.txt`: the data-stage measurement modules. They are stored as `.lua.txt` so the repo's Lua hooks don't pick them up; `make-copy.sh` installs them into the scratch mod copies as `.lua`.
  - `make-copy.sh`: builds the isolated mod copies they run in (the live repo is never modified).
  - `run.py`: runs seeds headless.
  - `parse.py`, `tables.py`, `charts.py`: turn the logs into `summary.json`, the tables and the charts.
  - `out-v3/` and `out-u/`: the per-seed logs (only the `CONTRA` lines) and their summaries.

Build: run `pdflatex main.tex` twice. TinyTeX's default packages are enough; the report avoids tcolorbox, algorithm packages, cleveref and pgfplots.

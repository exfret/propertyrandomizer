# From greedy fill to monotone matching: report

An explainer of the new first pass (monotone matching) and how it differs from the old greedy forward fill (26 September 2026).

- `main.pdf`: the compiled report.
- `main.tex`: the source. It inputs `macros.tex`, the `sec-*.tex` sections and the generated table `tab-rounds.tex`. All diagrams are TikZ, inline in the sections.
- `measure/`: the measurements behind Section 5.
  - `overlay.py`: builds an overlay mod directory that symlinks every repo file except the patched one, so the live repo is never modified.
  - `monotone-matching-measured.lua.txt`: the working tree's `monotone-matching.lua` at 19:19 with three `FPREPORT` log lines added. It's stored as `.lua.txt` so the repo's Lua hooks skip it.
  - `run.sh`: runs one seed headless on the overlay, with its own write-data directory.
  - `logs/seed-*.txt`: the extracted `FPREPORT`, monotone matching and check lines from seeds 1-3.
  - `parse.py`: turns the logs into `../tab-rounds.tex` (with `tab-rounds-header.tex.txt` and `tab-rounds-footer.tex.txt`) and prints the summary ranges.

Build: run `pdflatex main.tex` twice. TinyTeX's default packages are enough.

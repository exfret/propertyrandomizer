# Research and experiments

Offline solvers, datasets, and exploratory implementations live here. Maintained pricing code and cost tables imported by the randomizer remain under `lib/cost/` during the source migration. See [Directory structure](../docs/directory-structure.md) for the target layout.

- `cost/` contains the Python LP and science-flow solvers, saved matrices and results, recipe variants, semantic inputs, and unused material-cost datasets formerly mixed into `lib/cost/`.
- `wip/` contains unfinished Lua experiments formerly in `lib/wip/`.

The Python solvers still resolve relative input and output arguments from the current working directory. Run them from `research/cost/` to keep generated research output here, or pass explicit paths. Their shared Python modules remain together. Use an explicit output path when intentionally regenerating a table used by maintained code.

These files are excluded from ordinary source guards. Before promoting an experiment into maintained code, update its imports, add appropriate validation, and run the project's checks at its new location.

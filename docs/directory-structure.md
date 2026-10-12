# Directory structure

Propertyrandomizer stays in one repository and one mod. Maintained code lives in `src/`, grouped by responsibility; development tools, research, and inactive implementations have separate homes. Internal modules can share tested algorithms without becoming separately published libraries.

## Layout

```text
propertyrandomizer/
├── info.json
├── settings.lua
├── data.lua
├── data-updates.lua
├── data-final-fixes.lua
├── control.lua
├── changelog.txt
├── thumbnail.png
├── src/
│   ├── config/
│   ├── pipeline/
│   ├── lib/
│   │   ├── graph/
│   │   ├── sort/
│   │   └── random/
│   ├── logic/
│   │   ├── builders/
│   │   ├── contexts/
│   │   ├── analysis/
│   │   ├── compat/
│   │   ├── state.lua
│   │   └── init.lua
│   ├── prototypes/
│   │   ├── lookup/
│   │   ├── combat/
│   │   ├── entities/
│   │   ├── recipes/
│   │   ├── technology/
│   │   ├── surfaces/
│   │   └── duplicates/
│   ├── cost/
│   ├── randomizations/
│   │   ├── unified/
│   │   │   ├── handlers/
│   │   │   ├── handler-helpers/
│   │   │   └── skeleton/
│   │   ├── planetary/
│   │   ├── numerical/
│   │   ├── misc/
│   │   └── rebuild/
│   ├── runtime/
│   │   ├── panel/
│   │   ├── explorer/
│   │   └── customizer/
│   ├── localisation/
│   ├── compat/
│   └── legacy/
│       ├── logic/
│       └── randomizations/
├── graphics/
├── locale/
├── tests/
│   ├── unit/                    # Mirrors maintained module paths
│   ├── configs.txt
│   └── mod-configs/
├── dev/
├── research/
├── docs/
├── notes/
└── archive/
```

The root entry files remain in place as one-line loaders. Their implementations live in `src/config/settings.lua`, `src/runtime/control.lua`, and the corresponding stage files in `src/pipeline/`. Factorio's named entry files are documented in the installed `doc-html/auxiliary/mod-structure.html` and the [mod structure reference](https://lua-api.factorio.com/latest/auxiliary/mod-structure.html).

## Module boundaries

- `src/lib/` owns shared graph operations, sorting, paths, and random algorithms. Graph meanings and model policies belong in `src/logic/`. Current sorts import logic state; directory moves do not remove that coupling by themselves.
- `src/logic/` builds and analyzes the dependency model, including contexts, reductions, and model-specific compatibility.
- `src/prototypes/` owns reusable prototype queries, construction, and edits. Choosing a randomized result belongs in `src/randomizations/`; a helper used by only one randomization stays beside that feature.
- `src/cost/` owns maintained pricing and balance models and the generated inputs they actually import. Offline solvers and exploratory output belong in `research/cost/`.
- `src/pipeline/` owns sequencing, retries, and final checks. `src/runtime/` owns the panel, explorer, customizer, and other control helpers. Shared text helpers belong in `src/localisation/`.
- `src/legacy/` holds older implementations with active consumers. `archive/` holds inactive implementations retained for reference. An experimental folder can contain active code, so imports decide its status.

Keep small directories flat until grouping improves navigation. Avoid general `common/` and `helpers/` collections. Unit tests move to `tests/unit/` with `test-*.lua` filenames so their fixtures retain the existing hardcoded-name exemption.

## Migration progress

The directory migration is complete. Maintained modules live under `src/`, standalone tests under `tests/unit/`, offline work under `research/`, and inactive code under `archive/`. The former `lib/`, `randomizations/`, `scripts/`, `helper-tables/`, and root `compat/` directories have been removed. The five root entrypoints delegate to their relocated implementations.

| Previous location | Current location |
| --- | --- |
| Offline Python solvers in `lib/cost/` | `research/cost/` |
| `lib/cost/dependency-lp/`, `lower-bounder/`, `semantics/` | Corresponding directories in `research/cost/` |
| `lib/cost/recipe-randomizations/`, `science-flows/` | Corresponding directories in `research/cost/` |
| `lib/cost/material-costs-pyanodons/`, `material-costs-pyanodons-randomized/` | Corresponding directories in `research/cost/` |
| Unimported `lib/cost/material-costs.lua` and `material_costs.json` | `research/cost/` |
| `lib/wip/` | `research/wip/` |
| `lib/unused/` | `archive/unused/` |
| Standalone `test-*.lua` files under `lib/`, `scripts/`, `randomizations/`, and `dev/` | Mirrored paths under `tests/unit/` |
| `lib/graph/contexts-for-tests.lua` | `tests/unit/logic/contexts/contexts-for-tests.lua` |
| Python unit tests of development tools | `tests/unit/dev/` |
| Flat combat modules | `src/prototypes/combat/` |
| Entity, recipe, technology, surface, and duplicate helpers | Corresponding groups under `src/prototypes/` |
| `lib/data-utils.lua`, `prototype-catalog.lua`, `looks.lua` | `src/prototypes/` |
| Override parsing, graph policy/tuning, prototype exclusions | `src/config/` |
| `lib/locale.lua`, `localised-text.lua` | `src/localisation/` |
| Planet naming, sounds, tints, resource profiles | `src/randomizations/planetary/` |
| Item/fluid, military, ingredient, and recipe-shape helpers | `src/randomizations/unified/` |
| Rebuild checks, retained unlocks, starting recipes | `src/randomizations/rebuild/` |
| `lib/science-rooms.lua` | `src/logic/` |
| `lib/reformat.lua`, `result-summary.lua` | `src/pipeline/` |
| Offline `lib/export.lua` | `research/graph/export.lua` |
| Graph representation and superposition | `src/lib/graph/` |
| Topological, context, staged, consistent, and block sorts | `src/lib/sort/` |
| Context representation and transmission helpers | `src/logic/contexts/` |
| Dependency-model construction and acquisition/operation rules | `src/logic/builders/` |
| Model reductions, pass-throughs, contraction, analysis | `src/logic/analysis/` |
| Logic entrypoint, shared state, utilities, model compatibility | `src/logic/` and `src/logic/compat/` |
| Staged prototype lookup tables | `src/prototypes/lookup/` |
| Random algorithms and their active experiments | `src/lib/random/` |
| Maintained cost models and imported material-cost tables | `src/cost/` |
| Offline loop finder and LP exporter | `research/cost/` |
| Active older graph/model implementation | `src/legacy/logic/` |
| `randomizations/graph/unified/` | `src/randomizations/unified/` |
| Other older graph randomizations | `src/legacy/randomizations/` |
| `randomizations/master.lua`, `fixes.lua` | `src/randomizations/init.lua`, `rebuild/init.lua` |
| Remaining feature randomizations and helpers | Corresponding groups under `src/randomizations/` |
| `scripts/` | `src/runtime/`, grouped by panel, explorer, and customizer |
| `config.lua`, registry tables, flags, settings implementation | `src/config/` |
| `helper-tables/categories.lua` | `src/prototypes/categories.lua` |
| Root `compat/` | `src/compat/` |
| Data-stage entrypoint implementations | `src/pipeline/` |

The corresponding standalone tests occupy the same responsibility groups under `tests/unit/`. `dev/module-moves.json` records source path history. The hardcoded-name guard uses that history to recognize existing approvals for exactly the same name sets after a move, while keeping the original approval store intact. It also compares a moved table's syntax tree with its original Git baseline, ignoring comments, formatting, and recorded path substitutions. Unchanged relocated tables are not additions; extra tables, added names, and substantive table edits remain checked. A copy with its original implementation still present does not inherit relocation treatment. An exact one-line entrypoint loader is recognized as a relocation; adding extra code to that loader prevents this exemption.

Imported generated tables now live under `src/cost/material-costs/`; they retain their existing source-guard exemptions. Offline export utilities live under `research/`. Local benchmark evidence remains in the ignored `benchmark-logs/` directory, preserving the paths in existing session reports.

Ordinary style, hardcoded-name, localisation, and pass-through-name checks exclude `research/` and `archive/`. The explicit full require-placement audit can still inspect excluded Lua files. Active older logic keeps its existing checks.

Run standalone tests with `python3 dev/run-unit-tests.py`; use `--list` to inspect the suite or repeated `--only` selections to run a subset. The runner keeps each test in a separate process, uses the mod root as the working directory, and uses the release Python environment when available. The headless runner uses the relocated localisation tests and retains fallback paths for older snapshots. The actively imported in-game test modules under `tests/` and profiler probe under `dev/profiler-mod/` stay in place.

The migration preserves the existing module interfaces and execution order. Future interface changes can be considered independently; this structure does not require publishing separate libraries. Release tooling follows the root loaders and patches the copied settings implementation, while development probes that inspect stage code target `src/pipeline/`.

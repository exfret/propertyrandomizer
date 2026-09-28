# Require placement audit — 2026-09-28

## Follow-up: violations fixed

The working tree now passes `python3 dev/style-check.py --requires-only --all` with zero violations. The historical commit findings below are retained as the audit record.

- Requires now use module-scope bindings; optional external mod imports retain pure mod-existence guards.
- Lookup stages, Py farm modules, and unified handlers have explicit module lists instead of imports inside loops.
- `lib/logic/state.lua` holds shared metadata so context sorting and bootstrap logic can load without requiring the logic builder recursively.
- `lib/cost/graph-cost-core.lua` holds the unchanged numerical pricing functions, breaking the dependency cycle between graph costs and context costs.
- Standalone tests load their dependencies after installing their fixtures, at module scope. A new module-loading regression verifies eager imports and shared runtime metadata.

Validation: zero require violations across the full repository; syntax and require checks pass for all 29 Lua files changed in this follow-up; all 8 checker regression tests and 15 relevant standalone Lua test files pass. The extracted `compute` and `price_without_recipes` functions were compared byte-for-byte with their pre-refactor definitions and are unchanged. Release-file enumeration includes both new production modules.

All six headless smoke configurations passed (base and Space Age defaults, maximum settings, and unit tests). Logs and the full summary are in `/var/folders/g1/mv1c5tvx42v1974c7d004hf40000gn/T/propertyrandomizer-run-tests/run-20260928-185521-281i35_v/summary.txt`. These runs use isolated snapshots; unrelated edits made concurrently afterward are not included.

The additional base `unified-all@1` run passed. The Space Age `unified-all@1` stress run loaded successfully and progressed through recipe generation, but was stopped before completion after the focused regressions and smoke suite had passed; its full result is unverified. The runner confirmed shutdown with exit status 130, including cleanup of its game process. Logs are in `/var/folders/g1/mv1c5tvx42v1974c7d004hf40000gn/T/propertyrandomizer-run-tests/run-20260928-185745-8kqmayzw`.

## Original audit

Audited HEAD `eb60f4849f08f4f4c0557aac5b0fa75da5daa963` and all 56 commits reachable from local Git refs whose messages contain a `Co-Authored-By: Claude` trailer. 54 are ancestors of HEAD; the other two are snapshot commits on other refs. This identifies recorded Claude contributions, not untagged work.

**Claude did violate the requested rules.** 15 tagged commits added or changed violating code compared with their first parent. The audited HEAD contains 41 violating require sites; `git blame` attributes the latest line change at 35 of those sites to tagged commits. The working tree at the end of the original audit contained 36 sites, including uncommitted changes.

Other workspace edits landed during this audit: the initial working-tree scan found 47 sites, and the final full scan found 36. Committed results use immutable Git blobs and are unaffected by those edits.

## Method

- Parse Lua using the same tree-sitter based `require-context` rule as `dev/style-check.py`.
- Inspect all tracked Lua blobs, including tests, old logic, unused code, and generated code; compare changed blobs against each commit’s first parent. Compare multisets of source-line text plus violation reason across changed files so pure file moves are not counted as additions. Counts describe added or changed violating code, not unique violations across the entire history.
- Audit HEAD independently and use `git blame` for the latest line change. Blame attribution alone does not prove who originally introduced the surrounding control flow.
- Audit the working tree separately, including untracked Lua files. The scan is structural: it recognizes literal mod lookups and surrounding Lua syntax, not arbitrary execution paths or symbol/data-flow equivalence.
- Reject function bodies, nested calls (including `require("x").run()`), loops, non-mod guards, mixed conditions, and loader aliases. Allow literal `mods` / `script.active_mods` existence tests with negation, boolean combinations, and nil comparisons. Every enclosing and preceding branch must qualify.

## Violations at committed HEAD

Line numbers below refer to HEAD, not the modified working tree. Multiple requires on one line count as separate sites.

| Location at HEAD | Latest line change | Violation |
| --- | --- | --- |
| `data-final-fixes.lua:103` | `a34b1c0` (Claude-tagged) | inside another function call; under a condition other than mod existence |
| `data-final-fixes.lua:119` | `324c7e4` (Claude-tagged) | inside another function call; under a condition other than mod existence |
| `data-final-fixes.lua:128` | `3a26519` (Claude-tagged) | inside another function call |
| `data-final-fixes.lua:171` | `46204fa` (Claude-tagged) | inside another function call; under a condition other than mod existence |
| `data-final-fixes.lua:271` | `b15eac4` (Claude-tagged) | under a condition other than mod existence |
| `data-final-fixes.lua:371` | `8814ada` (Claude-tagged) | inside another function call |
| `data-final-fixes.lua:374` | `46204fa` (Claude-tagged) | inside another function call; under a condition other than mod existence |
| `lib/cost/context-costs.lua:17` | `3a26519` (Claude-tagged) | inside a function |
| `lib/cost/context-costs.lua:97` | `3a26519` (Claude-tagged) | inside a function |
| `lib/cost/context-costs.lua:427` | `eb60f48` (Claude-tagged) | inside a function |
| `lib/cost/context-costs.lua:493` | `eb60f48` (Claude-tagged) | inside a function |
| `lib/cost/graph-cost.lua:359` | `3a26519` (Claude-tagged) | inside a function |
| `lib/cost/graph-cost.lua:360` | `3a26519` (Claude-tagged) | inside a function |
| `lib/cost/graph-cost.lua:509` | `3a26519` (Claude-tagged) | inside a function |
| `lib/cost/graph-cost.lua:510` | `3a26519` (Claude-tagged) | inside a function |
| `lib/cost/graph-cost.lua:537` | `3a26519` (Claude-tagged) | inside a function |
| `lib/cost/graph-cost.lua:555` | `eb60f48` (Claude-tagged) | inside a function |
| `lib/cost/graph-cost.lua:608` | `3a26519` (Claude-tagged) | inside a function |
| `lib/cost/graph-cost.lua:609` | `eb60f48` (Claude-tagged) | inside a function; inside another function call |
| `lib/cost/test-context-costs.lua:146` | `3a26519` (Claude-tagged) | inside a function; inside another function call |
| `lib/cost/test-context-costs.lua:206` | `3a26519` (Claude-tagged) | inside a function; inside another function call |
| `lib/cost/test-context-costs.lua:227` | `3a26519` (Claude-tagged) | inside a function; inside another function call |
| `lib/cost/test-context-costs.lua:241` | `eb60f48` (Claude-tagged) | inside a function; inside another function call |
| `lib/cost/test-context-costs.lua:256` | `eb60f48` (Claude-tagged) | inside a function; inside another function call |
| `lib/logic/bootstrap.lua:55` | `324c7e4` (Claude-tagged) | inside a function |
| `lib/logic/compat/pyfull.lua:21` | `07f6659` (not Claude-tagged) | inside a loop; inside another function call |
| `lib/logic/init.lua:61` | `9f776db` (not Claude-tagged) | under a condition other than mod existence |
| `lib/lookup/init.lua:40` | `9f776db` (not Claude-tagged) | inside a loop; inside another function call |
| `lib/test-item-reflection.lua:228` | `dc8dd54` (Claude-tagged) | inside a function; inside another function call |
| `lib/test-item-reflection.lua:283` | `89534d2` (Claude-tagged) | inside a function; inside another function call |
| `lib/test-item-reflection.lua:284` | `89534d2` (Claude-tagged) | inside a function; inside another function call |
| `lib/test-item-reflection.lua:285` | `89534d2` (Claude-tagged) | inside a function; inside another function call |
| `randomizations/fixes.lua:635` | `ef36bcd` (Claude-tagged) | inside a function; under a condition other than mod existence |
| `randomizations/graph/unified/execute.lua:113` | `9f776db` (not Claude-tagged) | inside a loop |
| `randomizations/graph/unified/execute.lua:134` | `eb60f48` (Claude-tagged) | inside a function; under a condition other than mod existence |
| `randomizations/graph/unified/execute.lua:312` | `eb60f48` (Claude-tagged) | inside a function; inside another function call; under a condition other than mod existence |
| `randomizations/planetary/execute.lua:513` | `301fd09` (Claude-tagged) | inside a function |
| `randomizations/prefixes.lua:217` | `ef36bcd` (Claude-tagged) | inside another function call; under a condition other than mod existence |
| `tests/execute.lua:8` | `8814ada` (Claude-tagged) | inside a function; inside another function call |
| `tests/execute.lua:10` | `9f776db` (not Claude-tagged) | inside a function |
| `tests/execute.lua:15` | `9f776db` (not Claude-tagged) | inside a function |

## Additional uncommitted violations

These require sites differ from HEAD. They are not attributed to Claude’s commits. Locations are working-tree line numbers.

| Working-tree location | Source | Violation |
| --- | --- | --- |
| `lib/old-logic/build-graph.lua:3715` | `require("lib/old-logic/dying-spawns").add(graph, build_graph, build_graph.prototypes.entities, get_prototypes("asteroid-chunk"), surfaces, space_locations, get_prototypes("space-connection"))` | inside a function; inside another function call |

## Commit-by-commit audit

A zero means no added/changed violation was found in that commit; it does not mean its entire snapshot was free of inherited violations.

| Commit | Added/changed violating sites | Subject |
| --- | ---: | --- |
| `0a75218` | 0 | Add Lua style checker with Claude Code and pre-commit hooks |
| `349b13e` | 0 | Add multi-seed logic check as a Claude Code stop hook |
| `910fa2f` | 0 | Exclude log files from release builds |
| `b15eac4` | 1 | Use per-resource bills for recipe cost balancing and add a local resource gate |
| `76d91c0` | 1 | Promotion for unified randomization, working item first pass, logic fixes |
| `e806a00` | 1 | Add context-sort, a consistent sort that can track ability contexts |
| `014b8be` | 0 | Keep mechanic contexts through first pass and recycling, protect isolatability per node |
| `34a2c65` | 0 | Style checker: flag wrapped comments, make ipairs an error |
| `b717eda` | 0 | Make monotone matching the only first pass and delete the dead greedy paths |
| `4fd5ad5` | 0 | Count starter pack contents as isolatable on space platforms |
| `1f7c217` | 0 | Add ai-files hook: ask for approval when Claude's commits touch non-AI files |
| `5472d3a` | 0 | Multi-seed check hook: short summary in the message, full report in a file |
| `17b3e7f` | 0 | Changelog: resource balancing, multipass randomization, pure intermediates; drop fixed platform tile bug |
| `7c207dc` | 0 | Explorer contexts popup and GUI sizing that follows UI scale |
| `a34b1c0` | 1 | Add planetary ocean swaps behind a startup setting |
| `2538966` | 0 | Use the logic's room list for planet-locking planetary duplicates |
| `da3db4a` | 0 | Support Factorio 2.1.20 fuel_categories |
| `1588e01` | 0 | Add planetary resource swaps behind a startup setting |
| `85efe29` | 0 | Mechanics-aware first pass, with a model that matches item reflection |
| `8f5e55d` | 0 | Home contexts: an order-independent tech discovery rule, used by unified randomization |
| `13e206f` | 0 | Headless test suites with settings coverage, and lighter test hooks |
| `c936e31` | 0 | Judge test runs by the MECHCHECK verdict |
| `dc8dd54` | 1 | Name randomized recipes by their real main product, and number shared ones |
| `86362b2` | 0 | Starting ores almost always mine something new; coal's fuel stays with its position |
| `d5995ab` | 0 | Planetary checks follow protection rules and verify once; tech tree rebuild fixes |
| `8814ada` | 2 | Entity randomization and never-silent softlock checks |
| `c186f0f` | 0 | Project guidance, hardcoded-names checker and its hooks, smaller randomizer panel |
| `3e3af38` | 0 | Ocean tiles drawn as water only get looks drawn as water |
| `91d6dc2` | 0 | Generate recycling recipes from the randomized game, as the recycler would |
| `9057d36` | 0 | Test seeds only before commits, not after every reply |
| `fe064cb` | 0 | Derive recipe-ingredient blacklists from data; any planet start loads |
| `9d9a300` | 0 | Test unified randomizations in development only on their own, and fix spoil results in item randomization |
| `d926371` | 0 | Furnace recipe selection: recycling stays out of category randomization, and collisions fail the built-game check |
| `6b5fa97` | 0 | Mining fluids need a drill with a fluid input, so resources gaining one can't be mined by hand |
| `d0cd9a2` | 0 | Swap freeplay starting items for their first-pass replacements without py too |
| `2dc8be0` | 0 | Deprecate the Fleishman numerical algorithm, randomize values with no better direction, and strengthen bias |
| `3a26519` | 13 | Derive recipe costs from the logic graph, per room, and price it fast enough to load |
| `ef36bcd` | 2 | Fluids in unified item rando, switched off as work to come back to, plus two fixes |
| `7dec93d` | 5 | Snapshot of the whole working tree (every session's pending work) for safekeeping |
| `9fd85d6` | 0 | Spoiling in both directions, spoil times gating delivery, and platform building counting only for operation |
| `1639646` | 0 | Note that the spoiling work in progress is committed |
| `8109acd` | 1 | Snapshot of the whole working tree again, with the Gleba start behind a flag |
| `46204fa` | 4 | Superposed planetary changes, planet-locked recipes kept through unified, and a tech tree rebuild that keeps isolatability |
| `e0fcce2` | 0 | Rebuilt techs get the prerequisites of recipes on their witness that have no tech, like the captive spawner's |
| `324c7e4` | 2 | Planet locks, lightning and freezing moves, and bootstrap infrastructure for planetary randomization |
| `9dbd97f` | 0 | Platforms get no free foundation from the hub, and built tiles cost their item |
| `301fd09` | 1 | Start swap behind SWAP_START_WITH, superposed mode with entity randomization, and a rebuild guard |
| `a891227` | 0 | Old logic refills its prototype lists on each load, so items unified randomization adds don't stop loading |
| `53553f9` | 0 | First pass report: how monotone matching differs from the old greedy fill |
| `c71ee03` | 0 | Entity randomization: trigger, spoil and dying slots, moving capsule effects, carriers that need a kill, and first pass positions behind a flag |
| `369c77e` | 0 | A tile-build comment, feature list updates, and a dead stub removed |
| `89534d2` | 3 | Old item randomization names recipes like unified: new item's name, icon and menu place, numbered when shared |
| `1616f95` | 0 | Barreling recipes unlocked at the start, for now only with the unified randomizations in development |
| `36181bf` | 0 | Extra starting items in the base game or Space Age, on by default |
| `6b233e2` | 0 | Roll a failed ocean swap again, up to 3 times, before undoing it |
| `eb60f48` | 6 | Recipe randomization outside unified gets unified's recipe improvements, and the new unified pipeline is now just unified |

## Historical violation details

Locations refer to the named commit. The same code may occur in multiple commits; removed and snapshot-only violations are included.

### b15eac4 — Use per-resource bills for recipe cost balancing and add a local resource gate

- `data-final-fixes.lua:229` — under a condition other than mod existence. Source: `local resource_report = require("lib/cost/resource-report")`

### 76d91c0 — Promotion for unified randomization, working item first pass, logic fixes

- `data-final-fixes.lua:317` — inside another function call. Source: `require("randomizations/graph/unified/skeleton/check").run(new_logic.graph, init_sort_info, final_sort_info)`

### e806a00 — Add context-sort, a consistent sort that can track ability contexts

- `data-final-fixes.lua:320` — inside another function call. Source: `require("randomizations/graph/unified/skeleton/check").run(new_logic.graph, init_complex_sort_info, final_complex_sort_info)`

### a34b1c0 — Add planetary ocean swaps behind a startup setting

- `data-final-fixes.lua:103` — inside another function call; under a condition other than mod existence. Source: `require("randomizations/planetary/execute").execute(new_logic)`

### dc8dd54 — Name randomized recipes by their real main product, and number shared ones

- `lib/test-item-reflection.lua:170` — inside a function; inside another function call. Source: `local recycling_sources = require("lib/logic/recycling-sources")`

### 8814ada — Entity randomization and never-silent softlock checks

- `data-final-fixes.lua:359` — inside another function call. Source: `local final_check_ok = require("randomizations/graph/unified/skeleton/check").run(new_logic.graph, init_complex_sort_info, final_complex_sort_info).ok`
- `tests/execute.lua:8` — inside a function; inside another function call. Source: `require("tests/entity-acquisition").run(logic.graph)`

### 3a26519 — Derive recipe costs from the logic graph, per room, and price it fast enough to load

- `data-final-fixes.lua:126` — inside another function call. Source: `require("lib/cost/graph-cost").derive_cost_options(new_logic.graph, init_sort_info, gutils.key("planet", constants.starting_planet), init_complex_sort_info)`
- `lib/cost/context-costs.lua:17` — inside a function. Source: `return require("lib/cost/flow-cost")`
- `lib/cost/context-costs.lua:84` — inside a function. Source: `local graph_cost = require("lib/cost/graph-cost")`
- `lib/cost/graph-cost.lua:359` — inside a function. Source: `local top = require("lib/graph/context-sort")`
- `lib/cost/graph-cost.lua:360` — inside a function. Source: `local logic = require("lib/logic/init")`
- `lib/cost/graph-cost.lua:509` — inside a function. Source: `local dutils = require("lib/data-utils")`
- `lib/cost/graph-cost.lua:510` — inside a function. Source: `local gutils = require("lib/graph/graph-utils")`
- `lib/cost/graph-cost.lua:536` — inside a function. Source: `local top = require("lib/graph/context-sort")`
- `lib/cost/graph-cost.lua:584` — inside a function. Source: `local context_costs = require("lib/cost/context-costs")`
- `lib/cost/graph-cost.lua:585` — inside a function; inside another function call. Source: `context_costs.current = context_costs.build(graph, sort_info, prices, starting_context, require("lib/logic/init").contexts, true, major)`
- `lib/cost/test-context-costs.lua:145` — inside a function; inside another function call. Source: `item_recipe_maps = require("lib/cost/flow-cost").construct_item_recipe_maps(),`
- `lib/cost/test-context-costs.lua:205` — inside a function; inside another function call. Source: `item_recipe_maps = require("lib/cost/flow-cost").construct_item_recipe_maps(),`
- `lib/cost/test-context-costs.lua:226` — inside a function; inside another function call. Source: `local flow_cost = require("lib/cost/flow-cost")`

### ef36bcd — Fluids in unified item rando, switched off as work to come back to, plus two fixes

- `randomizations/fixes.lua:604` — inside a function; under a condition other than mod existence. Source: `local fluid_ports = require("lib/fluid-ports")`
- `randomizations/prefixes.lua:213` — inside another function call; under a condition other than mod existence. Source: `require("lib/fluid-ports").add_crafting_machine_ports()`

### 7dec93d — Snapshot of the whole working tree (every session's pending work) for safekeeping

- `data-final-fixes.lua:119` — inside another function call; under a condition other than mod existence. Source: `local planetary_home_sets = config.planetary and require("randomizations/planetary/execute").home_sets()`
- `data-final-fixes.lua:171` — inside another function call; under a condition other than mod existence. Source: `require("randomizations/planetary/execute").settle(new_logic)`
- `data-final-fixes.lua:374` — inside another function call; under a condition other than mod existence. Source: `require("randomizations/planetary/execute").check_final(new_logic.graph)`
- `lib/logic/bootstrap.lua:55` — inside a function. Source: `local top = require("lib/graph/context-sort")`
- `randomizations/graph/unified/execute-new.lua:134` — inside a function; under a condition other than mod existence. Source: `return require("randomizations/planetary/execute").superposed`

### 8109acd — Snapshot of the whole working tree again, with the Gleba start behind a flag

- `randomizations/planetary/execute.lua:502` — inside a function. Source: `local dutils = require("lib/data-utils")`

### 46204fa — Superposed planetary changes, planet-locked recipes kept through unified, and a tech tree rebuild that keeps isolatability

- `data-final-fixes.lua:119` — inside another function call; under a condition other than mod existence. Source: `local planetary_home_sets = (config.planetary_oceans or config.planetary_resources) and require("randomizations/planetary/execute").home_sets()`
- `data-final-fixes.lua:171` — inside another function call; under a condition other than mod existence. Source: `require("randomizations/planetary/execute").settle(new_logic)`
- `data-final-fixes.lua:374` — inside another function call; under a condition other than mod existence. Source: `require("randomizations/planetary/execute").check_final(new_logic.graph)`
- `randomizations/graph/unified/execute-new.lua:134` — inside a function; under a condition other than mod existence. Source: `return require("randomizations/planetary/execute").superposed`

### 324c7e4 — Planet locks, lightning and freezing moves, and bootstrap infrastructure for planetary randomization

- `data-final-fixes.lua:119` — inside another function call; under a condition other than mod existence. Source: `local planetary_home_sets = config.planetary and require("randomizations/planetary/execute").home_sets()`
- `lib/logic/bootstrap.lua:55` — inside a function. Source: `local top = require("lib/graph/context-sort")`

### 301fd09 — Start swap behind SWAP_START_WITH, superposed mode with entity randomization, and a rebuild guard

- `randomizations/planetary/execute.lua:491` — inside a function. Source: `local dutils = require("lib/data-utils")`

### 89534d2 — Old item randomization names recipes like unified: new item's name, icon and menu place, numbered when shared

- `lib/test-item-reflection.lua:283` — inside a function; inside another function call. Source: `local constants = require("helper-tables/constants")`
- `lib/test-item-reflection.lua:284` — inside a function; inside another function call. Source: `local locale_utils = require("lib/locale")`
- `lib/test-item-reflection.lua:285` — inside a function; inside another function call. Source: `local recipe_renames = require("lib/recipe-renames")`

### eb60f48 — Recipe randomization outside unified gets unified's recipe improvements, and the new unified pipeline is now just unified

- `lib/cost/context-costs.lua:427` — inside a function. Source: `local cutils = require("lib/cost/cost-utils")`
- `lib/cost/graph-cost.lua:509` — inside a function. Source: `local dutils = require("lib/data-utils")`
- `lib/cost/graph-cost.lua:555` — inside a function. Source: `local top = require("lib/graph/context-sort")`
- `lib/cost/graph-cost.lua:609` — inside a function; inside another function call. Source: `context_costs.current = context_costs.build(graph, sort_info, prices, starting_context, require("lib/logic/init").contexts, true, major, graph_cost.automatable_by_room(graph, complex_sort_info))`
- `lib/cost/test-context-costs.lua:241` — inside a function; inside another function call. Source: `item_recipe_maps = require("lib/cost/flow-cost").construct_item_recipe_maps(),`
- `lib/cost/test-context-costs.lua:256` — inside a function; inside another function call. Source: `local maps = require("lib/cost/flow-cost").construct_item_recipe_maps()`

## Enforcement and verification

- Added the blocking `require-context` rule to the existing style checker, so existing post-edit, stop, and pre-commit hooks run it on changed code. Edits to an enclosing guard or function scope also count as touching its requires.
- Extended require enforcement to active `lib/old-logic/` files without applying unrelated formatting rules to those files. Ordinary style exclusions otherwise remain unchanged; the full audit mode scans every Lua file.
- Documented the rule in `CLAUDE.md`.
- Eight regression tests pass, covering permitted mod guards, nested branches, mixed conditions, functions, calls, loops, aliases, syntax errors, guard-only edits, actual staged-vs-working-tree reads, and blocking hook exit codes.
- The default `python3` here lacks tree-sitter. The checker now falls back to the existing `.venv/release` interpreter when its parser imports fail, and that entry point was verified to report violations and exit with status 1.
- The original audit left Lua violations in place; the follow-up above fixes them.

Commands:

```sh
.venv/release/bin/python dev/test-style-check.py
python3 dev/style-check.py --requires-only --all
python3 dev/style-check.py --staged
```

The complete working-tree audit now succeeds. Historical commit snapshots still contain the violations recorded above.

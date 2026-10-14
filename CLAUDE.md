# propertyrandomizer

## Require placement

- Keep `require` at module scope, outside function bodies, loops, and other function calls. Bind the module to a local before calling its methods; do not write `require("module").run(...)`, pass `require(...)` as an argument, alias `require`, or pass it to `pcall`.
- The only allowed conditional loading is a pure mod-existence check: literal `mods["mod-name"]` / `mods.mod_name` or `script.active_mods` lookups, optionally combined with `not`, `and`, `or`, or comparisons to `nil`. Every enclosing condition and preceding `if`/`elseif` branch must satisfy this rule. Settings, feature flags, version checks, and mixed conditions do not qualify.
- `dev/style-check.py` enforces this as the blocking `require-context` rule through the existing edit, stop, and pre-commit hooks, including active `src/legacy/logic/` code. Run `python3 dev/style-check.py --requires-only --all` for a complete working-tree audit, including files excluded from ordinary style checks. Run `python3 dev/run-unit-tests.py --only test-style-check` for its regression tests; the runner uses the existing release Python environment when available. Both need the checker's existing tree-sitter dependencies.

## Game facts: verify or ask, never assume

- Before relying on how Factorio works (engine rules and limits, Lua API behavior, prototype properties and their defaults, what vanilla base/Space Age data contains, how mechanics interact), check the 2.1 docs at lua-api.factorio.com/latest (local copies are in `/Applications/factorio.app/Contents/doc-html`) or the installed game data under `/Applications/factorio.app/Contents/data`. Read neighbouring fields too; a default can be overridden right next to where you looked.
- If the docs and data don't settle it, or the question is what a game concept should mean for the randomizer, ask the user instead of picking an interpretation. A question costs less than a wrong assumption built into the logic.
- When a reply states a game fact, say where it was verified (a doc link or a game data path). A Stop hook reviews each final reply and sends unsourced game facts back to you.

## Design conflicts: stop and ask

- When an engine constraint or implementation obstacle requires choosing a different player-facing behavior, stop work on that behavior and ask the user what to do. Verify and explain the constraint, describe the concrete tradeoff, and wait for their decision before implementing a workaround. Independent investigation may continue.
- Technical compatibility does not authorize changing the design. In particular, do not silently couple independent randomization choices, change the unit being randomized (for example, entities into upgrade chains), exclude candidates, reduce a feature's scope, or remove another feature to satisfy a constraint. Routine implementation choices that preserve the requested behavior do not need approval.
- A user rejecting your choice does not approve its opposite or another workaround. Acknowledge the mismatch and ask how to proceed; do not announce or implement a replacement decision. For biome placement, neither grouping upgrade chains nor removing upgrade links is authorized merely by learning that independent restrictions can conflict with upgrade compatibility.
- Passing tests do not establish user authorization. Do not write a test asserting an unapproved compromise and then treat it as the intended specification. Behavioral regression scenarios for this boundary are in `tests/agent/design-conflicts.json`; these are evaluation cases, not an automatically enforced hook.

## No hardcoded vanilla assumptions

- Don't identify prototypes by name or by hardcoded type lists, since other mods add their own. Derive the property from data.raw, identify by node type, or declare a flag where the node is built.
- Files whose basenames contain "test" may hardcode tables as testing fixtures; these tables do not need individual approval.
- `dev/hardcoded-names.py` flags Lua tables that hardcode API class/type names or vanilla prototype names. Each flagged table needs the user's approval: show them the table and why the names can't be derived, then run `python3 dev/hardcoded-names.py --approve <ids>`, which asks them in a permission prompt.
- `dev/module-moves.json` records relocation history. The checker preserves existing approvals for the exact same name sets and compares moved tables with their original Git baseline, so unchanged tables are not treated as additions. New tables, added names, and substantive table edits remain checked; copies with their originals still present do not inherit relocation treatment.

## New node types need the user's approval

- Every dependency graph node type adds nodes, and contexts for each of them, to every graph the randomizer builds and sorts, so a new one changes load time and what the logic models. Model with the node types that exist where you can.
- `dev/node-types.py` finds every node type `src/` can create, including through wrappers like `builder.add_node`; `dev/node-types.json` holds the approved ones. For each new type, show the user where it's created, what it models and roughly how many nodes it adds, then run `python3 dev/node-types.py --approve --note "<what it models>" <types>`, which asks them in a permission prompt. Never edit `dev/node-types.json` yourself.
- A type the checker can't read (`node.type .. "-x"`, a loop variable) is a dynamic site, approved by its id; prefer string literals or names assigned one.
- The Stop and pre-commit hooks and `tests/unit/dev/test-node-types.py` enforce this.

## Test failures: don't overfit

- Some failing seeds (`dev/check-seeds.py`) and failing configs (`dev/run-tests.py`, also run by the pre-commit hook) are expected while the randomizer is in development; up to 30-50% of seeds failing is acceptable.
- A failing seed is fine only when unified randomization notices and retries. A built game that lost something a player needs (an unreachable recipe, or a mechanic context lost beyond isolatability) is a softlock, and that's never acceptable on any seed. It means the randomizer's model was wrong about the game it built: fix the model. `data-final-fixes.lua` checks the built game after each unified attempt (UNIFIEDCHECK; a failure retries) and at the end (MECHCHECK). If it still fails there, the game loads and the randomizer panel's home tab warns the player (warnings go in the panel, not chat), never a startup error, since that would make them reset their settings.
- Look into a failure when your change could have caused it, and fix it only at its root cause. Don't add hotfixes or special cases to get a seed through: a patch that quietly breaks something else is worse than a failing seed.
- Report failures plainly with a short summary instead of chasing every one.

## Factorio processes

- Start Factorio only through the dev scripts (`dev/run-tests.py`, `dev/check-seeds.py`, `dev/check-resources.py`), not by running the binary directly. They go through `dev/factorio_launch.py`, which lets one agent session (a Claude Code session or a Codex thread) run at most 2 Factorio processes at once across all its scripts (extra jobs wait), and kills a script's Factorio processes when the script dies, however it's killed.
- Set `PROPERTYRANDOMIZER_FACTORIO_LIMIT` (a higher number, or 0 for no limit) only when the user explicitly allows more for that run.

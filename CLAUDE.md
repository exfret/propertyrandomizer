# propertyrandomizer

## Require placement

- Keep `require` at module scope, outside function bodies, loops, and other function calls. Bind the module to a local before calling its methods; do not write `require("module").run(...)`, pass `require(...)` as an argument, alias `require`, or pass it to `pcall`.
- The only allowed conditional loading is a pure mod-existence check: literal `mods["mod-name"]` / `mods.mod_name` or `script.active_mods` lookups, optionally combined with `not`, `and`, `or`, or comparisons to `nil`. Every enclosing condition and preceding `if`/`elseif` branch must satisfy this rule. Settings, feature flags, version checks, and mixed conditions do not qualify.
- `dev/style-check.py` enforces this as the blocking `require-context` rule through the existing edit, stop, and pre-commit hooks, including active `lib/old-logic/` code. Run `python3 dev/style-check.py --requires-only --all` for a complete working-tree audit, including files excluded from ordinary style checks. Run `python3 dev/test-style-check.py` for its regression tests. Both need the checker's existing tree-sitter dependencies.

## Game facts: verify or ask, never assume

- Before relying on how Factorio works (engine rules and limits, Lua API behavior, prototype properties and their defaults, what vanilla base/Space Age data contains, how mechanics interact), check the 2.1 docs at lua-api.factorio.com/latest (local copies are in `/Applications/factorio.app/Contents/doc-html`) or the installed game data under `/Applications/factorio.app/Contents/data`. Read neighbouring fields too; a default can be overridden right next to where you looked.
- If the docs and data don't settle it, or the question is what a game concept should mean for the randomizer, ask the user instead of picking an interpretation. A question costs less than a wrong assumption built into the logic.
- When a reply states a game fact, say where it was verified (a doc link or a game data path). A Stop hook reviews each final reply and sends unsourced game facts back to you.

## No hardcoded vanilla assumptions

- Don't identify prototypes by name or by hardcoded type lists, since other mods add their own. Derive the property from data.raw, identify by node type, or declare a flag where the node is built.
- `dev/hardcoded-names.py` flags Lua tables that hardcode API class/type names or vanilla prototype names. Each flagged table needs the user's approval: show them the table and why the names can't be derived, then run `python3 dev/hardcoded-names.py --approve <ids>`, which asks them in a permission prompt.

## Test failures: don't overfit

- Some failing seeds (`dev/check-seeds.py`) and failing configs (`dev/run-tests.py`, also run by the pre-commit hook) are expected while the randomizer is in development; up to 30-50% of seeds failing is acceptable.
- A failing seed is fine only when unified randomization notices and retries. A built game that lost something a player needs (an unreachable recipe, or a mechanic context lost beyond isolatability) is a softlock, and that's never acceptable on any seed. It means the randomizer's model was wrong about the game it built: fix the model. `data-final-fixes.lua` checks the built game after each unified attempt (UNIFIEDCHECK; a failure retries) and at the end (MECHCHECK). If it still fails there, the game loads and the randomizer panel's home tab warns the player (warnings go in the panel, not chat), never a startup error, since that would make them reset their settings.
- Look into a failure when your change could have caused it, and fix it only at its root cause. Don't add hotfixes or special cases to get a seed through: a patch that quietly breaks something else is worse than a failing seed.
- Report failures plainly with a short summary instead of chasing every one.

## Factorio processes

- Start Factorio only through the dev scripts (`dev/run-tests.py`, `dev/check-seeds.py`, `dev/check-resources.py`), not by running the binary directly. They go through `dev/factorio_launch.py`, which lets one agent session (a Claude Code session or a Codex thread) run at most 2 Factorio processes at once across all its scripts (extra jobs wait), and kills a script's Factorio processes when the script dies, however it's killed.
- Set `PROPERTYRANDOMIZER_FACTORIO_LIMIT` (a higher number, or 0 for no limit) only when the user explicitly allows more for that run.

# propertyrandomizer

This project's instructions for coding agents are in `CLAUDE.md`, next to this file. Read it before starting work and follow all of it; it applies to you as much as to Claude.

`CLAUDE.md` mentions hooks that enforce some of its rules. Apart from the git pre-commit hook (`dev/git-hooks/pre-commit`), those are Claude Code hooks and don't run for you, so do their checks yourself before you finish:

- Run `python3 dev/style-check.py` and fix its errors in your changes (it checks require placement, among other Lua style).
- Run `python3 dev/review-player-text.py`. If your changes affect player-facing wording, show the complete diffs and wait for explicit human approval of the exact review IDs before running `--approve ID...`. Claude's permission prompt does not run for Codex: ask in chat and wait for the answer. Existing pending drafts are not approved by a new coding task; report them without approving them. Never edit review receipts directly or bypass the pre-commit check.
- Run `python3 dev/hardcoded-names.py`. Files whose basenames contain "test" are exempt as testing fixtures. Each table it lists needs the user's approval: show them the table and why the names can't be derived, and run `--approve <ids>` only after they approve those ids.
- Run `python3 dev/node-types.py`. Each dependency graph node type it lists is new and needs the user's approval: show them where it's created, what it models and roughly how many nodes it adds, and run `--approve --note "<what it models>" <types>` only after they approve those types. Never edit `dev/node-types.json` yourself.
- Nothing reviews your replies for game facts, so check each one yourself: every fact about how Factorio works says where you verified it, or is a question to the user.

# propertyrandomizer

This project's instructions for coding agents are in `CLAUDE.md`, next to this file. Read it before starting work and follow all of it; it applies to you as much as to Claude.

`CLAUDE.md` mentions hooks that enforce some of its rules. Apart from the git pre-commit hook (`dev/git-hooks/pre-commit`), those are Claude Code hooks and don't run for you, so do their checks yourself before you finish:

- Run `python3 dev/style-check.py` and fix its errors in your changes (it checks require placement, among other Lua style).
- Run `python3 dev/hardcoded-names.py`. Each table it lists needs the user's approval: show them the table and why the names can't be derived, and run `--approve <ids>` only after they approve those ids.
- Nothing reviews your replies for game facts, so check each one yourself: every fact about how Factorio works says where you verified it, or is a question to the user.

# Tests

Standalone Lua and Python tests live in `tests/unit/`, mirroring the current source paths. Keep the `test-` filename prefix so the runner discovers tests and the hardcoded-name guard recognizes their fixtures. Shared fixture modules, such as `unit/logic/contexts/contexts-for-tests.lua`, have separate names and are imported by tests rather than executed by the runner.

From the mod root, run the suite with `dev/run-unit-tests.py`:

```sh
python3 dev/run-unit-tests.py
python3 dev/run-unit-tests.py --list
python3 dev/run-unit-tests.py --only lib/sort
python3 dev/run-unit-tests.py --only test-style-check --only localisation
```

Each test runs in a fresh process from the mod root, so fixture globals and module stubs do not leak into another test. Python tests use `.venv/release/bin/python` when available. `--lua` selects the Lua interpreter, `--root` selects a checkout or snapshot, `--timeout` sets the limit for each file, and `--verbose` also prints successful test output. An empty selection, failure, or timeout returns a nonzero exit status.

The in-game test entrypoint remains `tests/execute.lua`, with its imported test modules beside it. Run those through `python3 dev/run-tests.py --only unit-tests`. Headless configurations remain in `configs.txt` and `mod-configs/`; the development helper and profiler mods stay under `dev/`.

When moving a maintained subsystem, move its corresponding unit-test directory too. Update source imports, fixture imports, and any tests that inspect source files; test paths should continue to mirror the source layout.

Unit tests mirror `src/lib/`, `src/logic/`, `src/cost/`, `src/prototypes/lookup/`, `src/randomizations/`, `src/runtime/`, `src/config/`, and `src/legacy/`. The pass-through-name check reads declarations from `src/logic/builders/` and still checks maintained consumers outside those builders. Legacy logic retains its require-placement audit.

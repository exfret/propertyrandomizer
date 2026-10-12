#!/usr/bin/env python3
"""Run standalone Lua and Python tests, each in its own process at the mod root.

python3 dev/run-unit-tests.py
python3 dev/run-unit-tests.py --list
python3 dev/run-unit-tests.py --only lib/graph --only test-style-check
"""
import argparse
from pathlib import Path
import shutil
import subprocess
import sys
import time

REPO = Path(__file__).resolve().parent.parent


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=REPO, help="mod checkout or snapshot to test")
    parser.add_argument("--only", action="append", default=[], help="path substring to select (repeat for alternatives)")
    parser.add_argument("--list", action="store_true", help="list selected tests without running them")
    parser.add_argument("--lua", default="lua", help="Lua interpreter executable")
    parser.add_argument("--timeout", type=float, default=120, help="maximum seconds per test file")
    parser.add_argument("--verbose", action="store_true", help="print successful test output too")
    args = parser.parse_args()
    root = args.root.resolve()
    if args.timeout <= 0:
        parser.error("--timeout must be positive")
    tests = sorted(path for path in (root / "tests/unit").rglob("test-*")
                   if path.is_file() and path.suffix in {".lua", ".py"})
    if args.only:
        tests = [path for path in tests if any(part in path.relative_to(root).as_posix() for part in args.only)]
    if not tests:
        parser.error("no unit tests match the requested selection")
    if args.list:
        for path in tests:
            print(path.relative_to(root).as_posix())
        return 0
    lua = shutil.which(args.lua)
    if any(path.suffix == ".lua" for path in tests) and lua is None:
        parser.error("Lua interpreter not found: " + args.lua)
    python = REPO / ".venv/release/bin/python"
    if not python.is_file():
        python = Path(sys.executable)
    print(f"Running {len(tests)} unit-test files in {root}", flush=True)
    started = time.monotonic()
    failed = []
    for index, path in enumerate(tests, 1):
        name = path.relative_to(root).as_posix()
        command = [lua if path.suffix == ".lua" else str(python), name]
        try:
            result = subprocess.run(command, cwd=root, capture_output=True, text=True, timeout=args.timeout)
            output = result.stdout + result.stderr
            passed = result.returncode == 0
        except subprocess.TimeoutExpired:
            output = f"Timed out after {args.timeout:g} seconds\n"
            passed = False
        if not passed:
            failed.append(name)
        if args.verbose or not passed:
            print(f"{'PASS' if passed else 'FAIL'} {name}", flush=True)
            if output:
                print(output, end="" if output.endswith("\n") else "\n", flush=True)
        elif index % 25 == 0:
            print(f"Completed {index}/{len(tests)} test files", flush=True)
    print(f"Unit tests: {len(tests) - len(failed)} passed, {len(failed)} failed in {time.monotonic() - started:.1f}s", flush=True)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env bash
# Runs the headless test suites; see dev/run-tests.py for what they check and its options (e.g. ./run-tests.sh smoke, ./run-tests.sh --list)
exec python3 "$(dirname "$0")/dev/run-tests.py" "$@"

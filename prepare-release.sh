#!/usr/bin/env bash
# Full disclosure: The following is the work of ChatGPT 5.2 Thinking, not my own
# I don't like writing bash scripts and this seems to be one of the few things it was able to do without excessive babysitting
# Trust the below code at your own risk

# Builds propertyrandomizer_VERSION (a folder and a zip) next to this folder, with VERSION from the first changelog entry
# The release ships only what dev/release-files.py lists (files the game reads, the docs players are pointed to, and the Lua the mod can require), so dev tools, notes and cost research data stay out
# The release is built in a temporary folder and tested there first (the smoke and settings suites of dev/run-tests.py); nothing is written next to this folder unless the tests pass
#
# Usage: ./prepare-release.sh [dev/run-tests.py options], e.g. ./prepare-release.sh --jobs 4, or --tier precommit for a quick check
# Parser dependencies are installed in .venv/release on first use. Set PYTHON to choose the Python used to create it.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"
PROJECT_NAME="$(basename "$PROJECT_DIR")"
CHANGELOG_FILE="$PROJECT_DIR/changelog.txt"

# -------------------------------------------------------------------
# 1. Extract version from the most recent changelog entry
#    Requires a line like: Version: 0.5.0
# -------------------------------------------------------------------
if [[ ! -f "$CHANGELOG_FILE" ]]; then
    echo "Error: changelog.txt not found at $CHANGELOG_FILE"
    exit 1
fi

VERSION="$(awk '/^[[:space:]]*Version:/ { print $2; exit }' "$CHANGELOG_FILE" | tr -d '\r')"

if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: could not extract a valid version from the first changelog entry (got '$VERSION')."
    echo "Expected a line like:"
    echo "  Version: 0.5.0"
    exit 1
fi

DATE_STR="$(date '+%Y.%m.%d')"
PARENT_DIR="$(dirname "$PROJECT_DIR")"
RELEASE_BASENAME="${PROJECT_NAME}_${VERSION}"
RELEASE_PATH="$PARENT_DIR/$RELEASE_BASENAME"
ZIP_FILE="$PARENT_DIR/${RELEASE_BASENAME}.zip"

# Keep release dependencies separate from global Python and other development tools.
RELEASE_PYTHON="$PROJECT_DIR/.venv/release/bin/python"
if [[ ! -x "$RELEASE_PYTHON" ]]; then
    echo "Creating release Python environment..."
    "${PYTHON:-python3}" -m venv "$PROJECT_DIR/.venv/release"
fi
if ! "$RELEASE_PYTHON" - "$PROJECT_DIR/dev/release-requirements.txt" <<'PY'
import importlib.metadata
import sys

with open(sys.argv[1], encoding="utf-8") as requirements:
    for line in requirements:
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        name, version = line.split("==")
        try:
            installed = importlib.metadata.version(name)
        except importlib.metadata.PackageNotFoundError:
            sys.exit(1)
        if installed != version:
            sys.exit(1)
PY
then
    echo "Installing release parser dependencies..."
    "$RELEASE_PYTHON" -m pip install --disable-pip-version-check --no-cache-dir -r "$PROJECT_DIR/dev/release-requirements.txt"
fi

# Built here, and moved next to this folder once it passes the tests
STAGE_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/propertyrandomizer-release.XXXXXX")"
trap 'rm -rf "$STAGE_ROOT"' EXIT
STAGE_PATH="$STAGE_ROOT/$RELEASE_BASENAME"

echo "Preparing release for version $VERSION"

# -------------------------------------------------------------------
# 2. Copy the release's files (dev/release-files.py prints what's left out)
# -------------------------------------------------------------------
echo "Listing release files..."
"$RELEASE_PYTHON" dev/release-files.py --report > "$STAGE_ROOT/files.txt"
mkdir -p "$STAGE_PATH"
rsync -a --files-from="$STAGE_ROOT/files.txt" "$PROJECT_DIR/" "$STAGE_PATH/"

# -------------------------------------------------------------------
# 3. Turn off the unified randomizations still in development
#    (the hidden setting propertyrandomizer-dev-unified, in the copied settings.lua)
# -------------------------------------------------------------------
"$RELEASE_PYTHON" - "$STAGE_PATH/settings.lua" <<'PY'
import re
import sys

path = sys.argv[1]
with open(path, "r", encoding="utf-8") as f:
    text = f.read()

# forced_value makes sure it's off: for a hidden bool setting it forces the value (https://wiki.factorio.com/Tutorial:Mod_settings)
pattern = r'(name = "propertyrandomizer-dev-unified",(?:[^{}])*?)default_value = true,'
new_text, count = re.subn(pattern, r"\g<1>default_value = false,\n        forced_value = false,", text)
if count != 1:
    print("Error: could not turn off propertyrandomizer-dev-unified in settings.lua", file=sys.stderr)
    sys.exit(1)

with open(path, "w", encoding="utf-8") as f:
    f.write(new_text)
PY
echo "Turned off development unified randomizations in the release"

# -------------------------------------------------------------------
# 4. Update info.json version in the release
# -------------------------------------------------------------------
"$RELEASE_PYTHON" - "$STAGE_PATH/info.json" "$VERSION" <<'PY'
import json
import sys

path = sys.argv[1]
version = sys.argv[2]

with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

data["version"] = version

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=4, ensure_ascii=False)
    f.write("\n")
PY
echo "Updated info.json version to $VERSION"

# -------------------------------------------------------------------
# 5. Add date to most recent changelog entry in the release
#    Replaces the Date line in the first entry only
# -------------------------------------------------------------------
RELEASE_CHANGELOG="$STAGE_PATH/changelog.txt"
"$RELEASE_PYTHON" - "$RELEASE_CHANGELOG" "$VERSION" "$DATE_STR" <<'PY'
import re
import sys

path = sys.argv[1]
version = sys.argv[2]
date_str = sys.argv[3]

with open(path, "r", encoding="utf-8") as f:
    text = f.read()

pattern = rf"(Version:[ \t]*{re.escape(version)}[ \t]*\r?\nDate:[ \t]*)(.*)"
new_text, count = re.subn(pattern, rf"\g<1>{date_str}", text, count=1)

if count == 0:
    print(f"Error: could not find the Date line of the changelog entry for version {version}", file=sys.stderr)
    sys.exit(1)

with open(path, "w", encoding="utf-8") as f:
    f.write(new_text)
PY
echo "Updated changelog date to $DATE_STR"

# -------------------------------------------------------------------
# 6. Test the release itself, so a file it needs but doesn't ship shows up here
#    The unified suite is left out: it tests the randomizations still in development, which the release turns off
# -------------------------------------------------------------------
echo ""
echo "Testing the release..."
if "$RELEASE_PYTHON" dev/run-tests.py smoke settings --dir "$STAGE_PATH" "$@"; then
    echo "Tests passed."
else
    EXIT_CODE=$?
    echo "Error: tests failed with exit code $EXIT_CODE; nothing was written next to $PROJECT_DIR"
    exit "$EXIT_CODE"
fi

# -------------------------------------------------------------------
# 7. Replace any earlier build of this version with the tested one
# -------------------------------------------------------------------
rm -rf "$RELEASE_PATH"
rm -f "$ZIP_FILE"
mv "$STAGE_PATH" "$RELEASE_PATH"
echo "Release folder: $RELEASE_PATH"

# -------------------------------------------------------------------
# 8. Show Lua line counts by file/folder in tree form
#    Counts all lines in .lua files in the release folder
# -------------------------------------------------------------------
echo ""
echo "Lua lines by file/folder:"
"$RELEASE_PYTHON" - "$RELEASE_PATH" <<'PY'
import os
import sys

root = sys.argv[1]

class Node:
    def __init__(self, name, is_file=False):
        self.name = name
        self.is_file = is_file
        self.children = {}
        self.lines = 0

tree = Node("Total", is_file=False)

def count_lines(path):
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        return sum(1 for _ in f)

# Build tree from lua files only
for dirpath, dirnames, filenames in os.walk(root):
    dirnames.sort()
    filenames.sort()

    rel_dir = os.path.relpath(dirpath, root)
    parts = [] if rel_dir == "." else rel_dir.split(os.sep)

    current = tree
    for part in parts:
        if part not in current.children:
            current.children[part] = Node(part, is_file=False)
        current = current.children[part]

    for filename in filenames:
        if not filename.endswith(".lua"):
            continue

        full_path = os.path.join(dirpath, filename)
        line_count = count_lines(full_path)

        file_node = Node(filename, is_file=True)
        file_node.lines = line_count
        current.children[filename] = file_node

# Post-order aggregation
def compute_lines(node):
    if node.is_file:
        return node.lines
    total = 0
    for child in node.children.values():
        total += compute_lines(child)
    node.lines = total
    return total

compute_lines(tree)

# Sort: larger line counts first, then directories before files on ties, then alphabetically
def sorted_children(node):
    return sorted(
        node.children.values(),
        key=lambda n: (-n.lines, n.is_file, n.name.lower())
    )

def print_tree(node, prefix=""):
    # Folders without Lua files (locale, graphics) are left out
    children = [child for child in sorted_children(node) if child.lines > 0]
    for i, child in enumerate(children):
        is_last = (i == len(children) - 1)
        branch = "└─ " if is_last else "├─ "
        print(f"{prefix}{branch}{child.lines} {child.name}")
        if not child.is_file:
            extension = "   " if is_last else "│  "
            print_tree(child, prefix + extension)

print(f"{tree.lines} {tree.name}")
print_tree(tree)
PY
echo ""

# -------------------------------------------------------------------
# 9. Show final changelog entry for this version
# -------------------------------------------------------------------
echo "Changelog entry for this version:"
echo "---"
awk -v version="$VERSION" '
    $0 == "Version: " version {
        printing = 1
    }

    printing {
        if ($0 ~ /^-+$/) {
            exit
        }
        print
    }
' "$RELEASE_PATH/changelog.txt"
echo "---"

# -------------------------------------------------------------------
# 10. Zip the release folder
# -------------------------------------------------------------------
echo "Creating zip archive..."
(
    cd "$PARENT_DIR"
    zip -rq "${RELEASE_BASENAME}.zip" "$RELEASE_BASENAME"
)

# -------------------------------------------------------------------
# 11. Show size comparison
# -------------------------------------------------------------------
ORIG_SIZE=$(du -sh "$PROJECT_DIR" | cut -f1)
RELEASE_SIZE=$(du -sh "$RELEASE_PATH" | cut -f1)
ZIP_SIZE=$(du -sh "$ZIP_FILE" | cut -f1)

echo ""
echo "Size comparison:"
echo "  Original:  $ORIG_SIZE"
echo "  Release:   $RELEASE_SIZE"
echo "  Zip file:  $ZIP_SIZE"

echo ""
echo "Done."
echo "Release folder: $RELEASE_PATH"
echo "Zip file:       $ZIP_FILE"

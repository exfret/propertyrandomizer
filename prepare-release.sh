# Full disclosure: The following is the work of ChatGPT 5.2 Thinking, not my own
# I don't like writing bash scripts and this seems to be one of the few things it was able to do without excessive babysitting
# Trust the below code at your own risk

#!/usr/bin/env bash
set -euo pipefail

# Run this script from inside the propertyrandomizer folder.

IGNORE_ITEMS=(
    ".git"
    ".gitignore"
    ".DS_Store"
    ".vscode"
    "offline"
    "notes"
    "node-docs"
    "tests"
    "run-tests.sh"
    "prepare-release.sh"
)

PROJECT_DIR="$(pwd)"
PROJECT_NAME="$(basename "$PROJECT_DIR")"
CHANGELOG_FILE="$PROJECT_DIR/changelog.txt"
INFO_JSON="$PROJECT_DIR/info.json"

# -------------------------------------------------------------------
# 1. Run tests first
# -------------------------------------------------------------------
echo "Running test suite..."
if ./run-tests.sh; then
    echo "Tests passed."
else
    EXIT_CODE=$?
    echo "Error: tests failed with exit code $EXIT_CODE"
    exit "$EXIT_CODE"
fi

# -------------------------------------------------------------------
# 2. Extract version from the most recent changelog entry
#    Requires a line like: Version: 0.5.0
# -------------------------------------------------------------------
if [[ ! -f "$CHANGELOG_FILE" ]]; then
    echo "Error: changelog.txt not found at $CHANGELOG_FILE"
    exit 1
fi

VERSION="$(
    sed -nE 's/^[[:space:]]*Version:[[:space:]]*([0-9]+\.[0-9]+\.[0-9]+)[[:space:]]*$/\1/p' "$CHANGELOG_FILE" \
    | tr -d '\r' \
    | head -n1
)"

if [[ -z "${VERSION:-}" ]]; then
    echo "Error: could not extract a valid version from the first changelog entry."
    echo "Expected a line like:"
    echo "  Version: 0.5.0"
    exit 1
fi

if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: extracted version is invalid: '$VERSION'"
    exit 1
fi

DATE_STR="$(date '+%Y.%m.%d')"
PARENT_DIR="$(dirname "$PROJECT_DIR")"
RELEASE_BASENAME="${PROJECT_NAME}_${VERSION}"
RELEASE_PATH="$PARENT_DIR/$RELEASE_BASENAME"
ZIP_FILE="$PARENT_DIR/${RELEASE_BASENAME}.zip"

echo "Preparing release for version $VERSION"
echo "Release folder: $RELEASE_PATH"

# -------------------------------------------------------------------
# 3. Remove any pre-existing release artifacts
# -------------------------------------------------------------------
rm -rf "$RELEASE_PATH"
rm -f "$ZIP_FILE"

# -------------------------------------------------------------------
# 4. Copy project to release folder, recursively excluding ignored items
#    rsync excludes matching names anywhere in the tree
# -------------------------------------------------------------------
RSYNC_EXCLUDES=()
for item in "${IGNORE_ITEMS[@]}"; do
    RSYNC_EXCLUDES+=(--exclude="$item")
done

mkdir -p "$RELEASE_PATH"

echo "Copying release files..."
rsync -a "${RSYNC_EXCLUDES[@]}" "$PROJECT_DIR/" "$RELEASE_PATH/"

# Safety check
if [[ ! -d "$RELEASE_PATH" ]]; then
    echo "Error: failed to create release directory"
    exit 1
fi

# -------------------------------------------------------------------
# 4.5. Show Lua line counts by file/folder in tree form
#      Counts all lines in .lua files in the copied release folder
# -------------------------------------------------------------------
echo ""
echo "Lua lines by file/folder:"
python3 - "$RELEASE_PATH" <<'PY'
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
    children = sorted_children(node)
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
# 5. Update info.json version in the copied release folder
# -------------------------------------------------------------------
RELEASE_INFO_JSON="$RELEASE_PATH/info.json"
if [[ ! -f "$RELEASE_INFO_JSON" ]]; then
    echo "Error: info.json not found in release folder"
    exit 1
fi

python3 - "$RELEASE_INFO_JSON" "$VERSION" <<'PY'
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
# 6. Add date to most recent changelog entry in copied release folder
#    Replaces the Date line in the first entry only
# -------------------------------------------------------------------
RELEASE_CHANGELOG="$RELEASE_PATH/changelog.txt"
python3 - "$RELEASE_CHANGELOG" "$VERSION" "$DATE_STR" <<'PY'
import re
import sys

path = sys.argv[1]
version = sys.argv[2]
date_str = sys.argv[3]

with open(path, "r", encoding="utf-8") as f:
    text = f.read()

pattern = rf"(Version:\s*{re.escape(version)}\s*\nDate:\s*)(.*)"
new_text, count = re.subn(pattern, rf"\g<1>{date_str}", text, count=1)

if count == 0:
    print(f"Error: could not find changelog entry for version {version}", file=sys.stderr)
    sys.exit(1)

with open(path, "w", encoding="utf-8") as f:
    f.write(new_text)
PY

echo "Updated changelog date to $DATE_STR"

# -------------------------------------------------------------------
# 7. Show final changelog entry for this version
# -------------------------------------------------------------------
echo ""
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
' "$RELEASE_CHANGELOG"
echo "---"

# -------------------------------------------------------------------
# 8. Zip the release folder
# -------------------------------------------------------------------
echo "Creating zip archive..."
(
    cd "$PARENT_DIR"
    zip -rq "${RELEASE_BASENAME}.zip" "$RELEASE_BASENAME"
)

# -------------------------------------------------------------------
# 9. Show size comparison
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
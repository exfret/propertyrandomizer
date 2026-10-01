#!/usr/bin/env python3
"""Keeps Claude from editing changelog.txt: the user writes the changelog themselves.

Claude Code hook modes (hook JSON on stdin):
  --hook pre-edit    PreToolUse for Write/Edit/MultiEdit/NotebookEdit: denies the call when it targets changelog.txt
  --hook pre-bash    PreToolUse for Bash: denies commands that look like they write changelog.txt, and snapshots the file
  --hook post-bash   PostToolUse for Bash: if the command changed changelog.txt anyway, restores the snapshot and tells Claude
"""
import hashlib
import json
import os
import re
import shutil
import sys
import tempfile

REPO = os.environ.get("CLAUDE_PROJECT_DIR") or os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROTECTED = "changelog.txt"
PATH = os.path.join(REPO, PROTECTED)
# Anything that mentions the file next to something that writes files
MENTION_RE = re.compile(r"changelog\.txt", re.IGNORECASE)
WRITE_RE = re.compile(r"(sed\s+-[a-zA-Z]*i|perl\s+-[a-zA-Z]*i|>>?|\btee\b|\bopen\(|\bmv\b|\bcp\b|\brm\b|git\s+(checkout|restore|stash)|\bpatch\b|\btruncate\b|\bapply\b)")


def snapshot_path(payload):
    session = re.sub(r"[^A-Za-z0-9_-]", "", payload.get("session_id", "nosession"))
    return os.path.join(tempfile.gettempdir(), f"propertyrandomizer-changelog-{session}.snapshot")


def file_hash():
    if not os.path.isfile(PATH):
        return None
    with open(PATH, "rb") as f:
        return hashlib.sha256(f.read()).hexdigest()


def decide(decision, reason):
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": decision,
        "permissionDecisionReason": reason,
    }}))


def targets_changelog(file_path):
    if not file_path:
        return False
    return os.path.realpath(file_path) == os.path.realpath(PATH)


def pre_edit(payload):
    if targets_changelog(payload.get("tool_input", {}).get("file_path", "")):
        decide("deny", "protect-changelog: changelog.txt is written by the user, not by Claude. Leave it alone and mention in your reply what would go in it.")


def pre_bash(payload):
    command = payload.get("tool_input", {}).get("command", "")
    if MENTION_RE.search(command) and WRITE_RE.search(command):
        decide("deny", "protect-changelog: this command looks like it writes changelog.txt, which the user writes themselves. Read it if you need to, but never change it.")
        return
    snap = snapshot_path(payload)
    if os.path.isfile(PATH):
        shutil.copyfile(PATH, snap)
    elif os.path.exists(snap):
        os.remove(snap)


def post_bash(payload):
    snap = snapshot_path(payload)
    if not os.path.isfile(snap):
        return
    with open(snap, "rb") as f:
        before = hashlib.sha256(f.read()).hexdigest()
    if file_hash() != before:
        shutil.copyfile(snap, PATH)
        print(json.dumps({
            "decision": "block",
            "reason": "protect-changelog: your command changed changelog.txt, which the user writes themselves. It has been restored to its previous content; don't try again, and tell the user what you wanted to add.",
        }))


def main(argv):
    if len(argv) != 2 or argv[0] != "--hook" or argv[1] not in ("pre-edit", "pre-bash", "post-bash"):
        print("usage: protect-changelog.py --hook pre-edit|pre-bash|post-bash", file=sys.stderr)
        return 2
    payload = json.load(sys.stdin)
    {"pre-edit": pre_edit, "pre-bash": pre_bash, "post-bash": post_bash}[argv[1]](payload)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

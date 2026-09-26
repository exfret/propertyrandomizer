#!/usr/bin/env python3
# Tracks which files were created purely by Claude, and makes Claude's commits ask for approval when they touch anything else
#
# A file counts as AI-only if Claude created it with Write and every change since came through Claude's Write/Edit
# Once anything else changes it (a human, a Bash command, a formatter), it's non-AI for good
# The manifest lives in the git dir so it isn't committed: <git-common-dir>/claude-ai-files.json, path -> blob hash
#
# Usage:
#   dev/ai-files.py --hook pre-edit|post-edit|pre-bash    Claude Code hook mode (reads hook JSON on stdin)
#   dev/ai-files.py --list                               print tracked AI-only files and whether they're still clean

import fcntl
import json
import os
import re
import subprocess
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

GIT_COMMIT_RE = re.compile(r"\bgit\s+(?:-[cC]\s+\S+\s+)*commit\b")
# Commands that change what gets committed, so they can't be chained with the commit (the check runs before any of it)
STAGING_RE = re.compile(r"\bgit\s+(?:-[cC]\s+\S+\s+)*(add|rm|mv|stash|reset|restore|checkout|switch|apply|am|cherry-pick|merge|rebase|revert|pull)\b")
# Commit flags that pull in unstaged changes to tracked files
WIDE_COMMIT_RE = re.compile(r"\scommit\b.*?\s(-[A-Za-z]*a[A-Za-z]*|--all|-i|--include|-o|--only|--)(\s|$)", re.DOTALL)


def git(*args):
    return subprocess.run(["git", "-C", REPO, *args], capture_output=True, text=True, check=True).stdout


def manifest_path():
    common_dir = git("rev-parse", "--git-common-dir").strip()
    return os.path.join(REPO, common_dir, "claude-ai-files.json")


class Manifest:
    # Locked read-modify-write, since parallel tool calls fire hooks concurrently
    def __enter__(self):
        self.lock = open(manifest_path() + ".lock", "w")
        fcntl.flock(self.lock, fcntl.LOCK_EX)
        try:
            with open(manifest_path()) as f:
                self.files = json.load(f)
        except FileNotFoundError:
            self.files = {}
        return self

    def save(self):
        tmp = manifest_path() + ".tmp"
        with open(tmp, "w") as f:
            json.dump(self.files, f, indent=1, sort_keys=True)
        os.replace(tmp, manifest_path())

    def __exit__(self, *exc):
        fcntl.flock(self.lock, fcntl.LOCK_UN)
        self.lock.close()


def repo_relative(file_path):
    rel = os.path.relpath(os.path.realpath(file_path), os.path.realpath(REPO))
    if rel.startswith(".."):
        return None
    return rel


def worktree_hash(rel):
    if not os.path.isfile(os.path.join(REPO, rel)):
        return None
    return git("hash-object", "--", rel).strip()


def pre_edit(payload):
    rel = repo_relative(payload.get("tool_input", {}).get("file_path", ""))
    if rel is None:
        return
    with Manifest() as m:
        if not os.path.exists(os.path.join(REPO, rel)):
            if payload.get("tool_name") == "Write":
                # Pending until post-edit fills in the hash; a denied Write leaves None, which never matches
                m.files[rel] = None
                m.save()
        elif rel in m.files and m.files[rel] != worktree_hash(rel):
            # Changed since Claude last wrote it, so a human (or Bash) has touched it
            del m.files[rel]
            m.save()


def post_edit(payload):
    rel = repo_relative(payload.get("tool_input", {}).get("file_path", ""))
    if rel is None:
        return
    with Manifest() as m:
        if rel in m.files:
            m.files[rel] = worktree_hash(rel)
            m.save()


def commit_changes(wide):
    # (status, path, blob hash of the content that would be committed)
    changes = []
    out = git("diff", "--cached", "--name-status", "--no-renames", "-z")
    parts = out.split("\0")
    staged = {}
    for i in range(0, len(parts) - 1, 2):
        staged[parts[i + 1]] = parts[i]
    for path, status in staged.items():
        blob = None if status == "D" else git("rev-parse", ":" + path).strip()
        changes.append((status, path, blob))
    if wide:
        out = git("diff", "HEAD", "--name-status", "--no-renames", "-z")
        parts = out.split("\0")
        for i in range(0, len(parts) - 1, 2):
            status, path = parts[i], parts[i + 1]
            if path in staged:
                continue
            changes.append((status, path, None if status == "D" else worktree_hash(path)))
    return changes


def ask(decision, reason):
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": decision,
        "permissionDecisionReason": reason,
    }}))


def pre_bash(payload):
    command = payload.get("tool_input", {}).get("command", "")
    if not GIT_COMMIT_RE.search(command):
        return
    if STAGING_RE.search(command):
        ask("deny", "ai-files: run git add/rm/etc. as its own command, then git commit separately, so the approval check sees exactly what's being committed")
        return
    wide = WIDE_COMMIT_RE.search(command) is not None
    with Manifest() as m:
        ai_files = dict(m.files)
    flagged = []
    for status, path, blob in commit_changes(wide):
        if path not in ai_files:
            flagged.append(f"  {status} {path}")
        elif status != "D" and ai_files[path] != blob:
            flagged.append(f"  {status} {path}  (AI-created, but changed outside Claude's Write/Edit)")
    if flagged:
        scope = "staged + unstaged tracked changes" if wide else "staged changes"
        ask("ask", f"Commit touches {len(flagged)} non-AI file(s) ({scope}):\n" + "\n".join(flagged))


def list_files():
    with Manifest() as m:
        files = dict(m.files)
    for rel in sorted(files):
        state = "clean" if files[rel] is not None and files[rel] == worktree_hash(rel) else "tainted"
        print(f"{state:8} {rel}")


def main(argv):
    if argv == ["--list"]:
        list_files()
        return 0
    if len(argv) != 2 or argv[0] != "--hook":
        print("usage: ai-files.py --hook pre-edit|post-edit|pre-bash | --list", file=sys.stderr)
        return 2
    payload = json.load(sys.stdin)
    {"pre-edit": pre_edit, "post-edit": post_edit, "pre-bash": pre_bash}[argv[1]](payload)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

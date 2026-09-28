# Starts headless Factorio for the dev scripts (run-tests.py, check-seeds.py, check-resources.py, hardcoded-names.py), with two guards:
#   - An agent session (a Claude Code session or a Codex thread) runs at most DEFAULT_LIMIT Factorio processes at once, across all its scripts; more wait for a slot
#     Runs from a plain terminal have no limit
#     PROPERTYRANDOMIZER_FACTORIO_LIMIT=N changes the limit (0 for none); agents set it only when the user explicitly allows more
#   - Factorio dies with the script that started it, even when the script is killed outright: a watchdog process kills what's left
#
# A slot is an flock on a file in SLOTS_DIR; Factorio inherits it, so even a Factorio that outlives its script keeps its slot until it exits

import contextlib
import fcntl
import os
import re
import signal
import subprocess
import sys
import tempfile
import threading
import time

DEFAULT_LIMIT = 2
LIMIT_VARIABLE = "PROPERTYRANDOMIZER_FACTORIO_LIMIT"
# Environment variables naming the agent session a command runs in, with a name for messages
SESSION_VARIABLES = [("CLAUDE_CODE_SESSION_ID", "Claude Code session"), ("CODEX_THREAD_ID", "Codex thread")]
SLOTS_DIR = os.path.join(tempfile.gettempdir(), "propertyrandomizer-factorio-slots")

_lock = threading.Lock()
_watchdog = None
_warned = False

# Read on import, so a bad value stops the script up front rather than inside a worker thread
LIMIT = DEFAULT_LIMIT
if os.environ.get(LIMIT_VARIABLE, "") != "":
    try:
        LIMIT = int(os.environ[LIMIT_VARIABLE])
    except ValueError:
        raise SystemExit(LIMIT_VARIABLE + " must be a whole number (0 for no limit), not " + repr(os.environ[LIMIT_VARIABLE]))


def session_limit():
    # (session id, what it is, limit), or (None, None, None) with no limit
    for variable, kind in SESSION_VARIABLES:
        session = os.environ.get(variable, "")
        if session != "" and LIMIT > 0:
            return session, kind, LIMIT
    return None, None, None


def _acquire_slot(cancelled):
    # An open file holding a slot's lock, None with no limit, or False if cancelled() came true while waiting
    global _warned
    session, kind, limit = session_limit()
    if session is None:
        return None
    directory = os.path.join(SLOTS_DIR, re.sub(r"[^A-Za-z0-9._-]+", "_", session))
    os.makedirs(directory, exist_ok=True)
    while True:
        for i in range(limit):
            # Each open is its own lock owner, so threads of one script compete like separate scripts
            fd = os.open(os.path.join(directory, "slot-" + str(i)), os.O_RDWR | os.O_CREAT, 0o644)
            try:
                fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
                return fd
            except BlockingIOError:
                os.close(fd)
        if cancelled is not None and cancelled():
            return False
        with _lock:
            if not _warned:
                _warned = True
                print("This " + kind + " already runs " + str(limit) + " Factorio processes, so more wait for one to finish."
                      " Only with the user's explicit permission, set " + LIMIT_VARIABLE + " to allow more (0 for no limit).", file=sys.stderr, flush=True)
        time.sleep(1)


def _tell_watchdog(line):
    global _watchdog
    with _lock:
        if _watchdog is None:
            # Its own session, so it outlives a kill of this script's process group; its stdin reaches EOF when this script dies
            # No stdout, so it never holds open the pipe of whoever reads this script's output
            _watchdog = subprocess.Popen([sys.executable, os.path.abspath(__file__), "--watchdog"], stdin=subprocess.PIPE, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, text=True, start_new_session=True)
        _watchdog.stdin.write(line + "\n")
        _watchdog.stdin.flush()


@contextlib.contextmanager
def started(args, cancelled=None, **popen_args):
    # Starts Factorio once this session has a free slot, and yields its Popen (None if cancelled() came true first)
    # On leaving, kills it if it's still running
    slot = _acquire_slot(cancelled)
    if slot is False:
        yield None
        return
    try:
        proc = subprocess.Popen(args, pass_fds=() if slot is None else (slot,), **popen_args)
        _tell_watchdog("+" + str(proc.pid) + " " + args[0])
        try:
            yield proc
        finally:
            if proc.poll() is None:
                proc.kill()
                proc.communicate()
            _tell_watchdog("-" + str(proc.pid))
    finally:
        if slot is not None:
            os.close(slot)


def run(args, timeout=None, check=False, capture_output=False, **popen_args):
    # Like subprocess.run, for a Factorio command
    if capture_output:
        popen_args["stdout"] = subprocess.PIPE
        popen_args["stderr"] = subprocess.PIPE
    with started(args, **popen_args) as proc:
        try:
            stdout, stderr = proc.communicate(timeout=timeout)
        except subprocess.TimeoutExpired:
            proc.kill()
            proc.communicate()
            raise
    if check and proc.returncode != 0:
        raise subprocess.CalledProcessError(proc.returncode, args, stdout, stderr)
    return subprocess.CompletedProcess(args, proc.returncode, stdout, stderr)


def watchdog():
    # Reads "+PID EXECUTABLE" and "-PID" lines until the script that started it dies, then kills the processes still listed
    running = {}
    for line in sys.stdin:
        if line.startswith("+"):
            pid, executable = line[1:].rstrip("\n").split(" ", 1)
            running[int(pid)] = executable
        elif line.startswith("-"):
            running.pop(int(line[1:]), None)
    for pid, executable in running.items():
        # Only if the pid still runs that executable, not a process that reused it
        command = subprocess.run(["ps", "-o", "command=", "-p", str(pid)], capture_output=True, text=True).stdout
        if command.startswith(executable):
            try:
                os.kill(pid, signal.SIGKILL)
            except ProcessLookupError:
                pass


if __name__ == "__main__" and sys.argv[1:] == ["--watchdog"]:
    watchdog()

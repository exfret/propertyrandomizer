# Builds a mod dir that symlinks every repo entry except the patched files, which are real copies
import os, sys, shutil
repo, out, patched = sys.argv[1], sys.argv[2], sys.argv[3:]
def build(src, dst, rel):
    os.makedirs(dst, exist_ok=True)
    for name in os.listdir(src):
        r = os.path.join(rel, name) if rel else name
        s, d = os.path.join(src, name), os.path.join(dst, name)
        if any(p == r for p in patched):
            shutil.copy(s, d)
        elif any(p.startswith(r + "/") for p in patched):
            build(s, d, r)
        else:
            os.symlink(s, d)
build(repo, out, "")

#!/usr/bin/env python3
"""Snapshot the working tree and run a read-only two-dupe node footprint probe.

Uses dev/run-tests.py and its Factorio process limiter. No production file changes.
The source snapshot and test logs are retained at the printed locations.
"""
import argparse
import importlib.util
import pathlib
import sys
import tempfile
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--check', action='store_true', help='run the both-ways smoke audit without unified handlers')
parser.add_argument('--without-rebuild', action='store_true', help='diagnose unified pool changes with preview features explicitly enabled and the later tree rebuild disabled')
parser.add_argument('--source', type=pathlib.Path, help='probe a retained source snapshot')
parser.add_argument('--matching-only', action='store_true', help='intentionally stop the isolated load once the split matching footprint is logged')
args = parser.parse_args()
check = args.check
root = pathlib.Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('node_footprint_run_tests', root / 'dev/run-tests.py')
runner = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = runner
spec.loader.exec_module(runner)
folder = pathlib.Path(tempfile.mkdtemp(prefix='node-footprint-'))
# Other chats also run this harness; keep probe logs outside their shared cache cleanup.
runner.CACHE_DIR = str(folder / 'test-runs')
snapshot = folder / 'source'
runner.snapshot(str(snapshot), None, False, str(args.source) if args.source is not None else None)
# Keep the test helper at the same version as the frozen source it validates.
runner.HELPER_MOD = str(snapshot / 'dev/test-helper-mod')
(snapshot / "dev/experiments/node-footprint-probe.lua").write_text((root / "dev/experiments/node-footprint-probe.lua").read_text())
(snapshot / "dev/experiments/forwarding-node-audit.lua").write_text((root / "dev/experiments/forwarding-node-audit.lua").read_text())
p = snapshot / 'data-final-fixes.lua'
source = p.read_text()
if source.startswith('local node_probe = require("dev/experiments/node-footprint-probe")\n'):
    source = '\n'.join(source.split('\n')[2:])
install = 'true' if args.matching_only else 'false'
p.write_text('local node_probe = require("dev/experiments/node-footprint-probe")\nnode_probe.install(' + install + ')\n' + source)
configs = folder / 'configs.txt'
suite = 'smoke' if check else 'unified'
options = 'unified-preview=false dev-unified=false test-reductions=true logistic=none production=none military=none misc=none' if check else 'unified-preview=true dev-unified=true'
if args.without_rebuild:
    options = 'unified-preview=false dev-unified=true unified-entity=true unified-entity-biters=true planetary-oceans=true planetary-resources=true planetary-locks=true tech-tree-rebuild=false technology=false recipe=false item=false recipe-tech-unlock=false recipe-science-pack=false'
configs.write_text(pathlib.Path(runner.CONFIGS).read_text() + '\nconfig node-footprint-probe ' + suite + ' seeds=1 dupes=true dupe-count=2 ' + options + '\n')
runner.CONFIGS = str(configs)
sys.argv = ['dev/run-tests.py', suite, '--modset', 'sa', '--only', 'node-footprint-probe', '--jobs', '1', '--dir', str(snapshot)]
print('Isolated source:', snapshot, flush=True)
sys.exit(runner.main(sys.argv[1:]))

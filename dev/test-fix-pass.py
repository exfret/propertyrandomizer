#!/usr/bin/env python3
# Stress the complete planetary resource pipeline, including specialized repairs and the fix pass.
# Run: python3 dev/test-fix-pass.py
# The normal run-tests launcher enforces the shared Factorio process limit.
import importlib.util
from pathlib import Path
import tempfile
repo = Path(__file__).resolve().parent.parent
spec = importlib.util.spec_from_file_location('fixpass_runner', str(repo / 'dev/run-tests.py'))
runner = importlib.util.module_from_spec(spec)
spec.loader.exec_module(runner)
base = Path(tempfile.mkdtemp(prefix='fixpass-pipeline-', dir='/private/tmp'))
mod = base / 'propertyrandomizer'
runner.snapshot(str(mod), None, False, None)
source = mod / 'src/pipeline/data-final-fixes.lua'
text = source.read_text()
fixture = '''
-- Keep the stress assignment, but let the normal planetary pipeline repair it.
local stress_resources = require("src/randomizations/planetary/resources")
local stress_check = require("src/randomizations/planetary/check")
local stress_execute = stress_resources.execute
local stress_lost
stress_resources.execute = function()
    local before = stress_check.sort(new_logic)
    local slots, assignment, lost = stress_execute("fixpass-chooser-stress")
    local after = stress_check.sort(new_logic)
    stress_lost = stress_check.required_failures(before, after, {})
    log("FIXPASS STRESS initial failures: " .. #stress_lost)
    assert(#stress_lost > 0, "The fixture needs unpaid resource requirements")
    return slots, assignment, lost
end
'''
verification = '''
-- Inspect the completed pipeline before the rest of unified randomization starts.
assert(stress_lost ~= nil, "The stress resource stage must run")
assert(stress_check.moved_features.resources == true and planetary.before ~= nil,
    "The pipeline must keep the resource swap, not skip or undo it")
local stress_after = stress_check.sort(new_logic)
local stress_remaining = stress_check.required_failures(
    planetary.before.sort, stress_after, planetary.before.variants_of)
for _, failure in pairs(stress_remaining) do
    log("FIXPASS STRESS remaining: " .. failure.text)
end
assert(#stress_remaining == 0, "The complete planetary pipeline must restore every required goal")
log("FIXPASS STRESS final failures: " .. #stress_remaining)
'''
# Require and instrument resources before planetary.execute; verify after run_pending.
setup_marker = 'local mining_fluids = require("src/prototypes/entities/mining-fluids")\n'
verify_marker = '-- Independent deposits (src/randomizations/unified/deposit-copies.lua):'
assert text.count(setup_marker) == 1, 'Planetary setup insertion point changed'
assert text.count(verify_marker) == 1, 'Planetary verification insertion point changed'
text = text.replace(setup_marker, setup_marker + fixture, 1)
text = text.replace(verify_marker, verification + '\n' + verify_marker, 1)
source.write_text(text)
cfg = base / 'configs.txt'
cfg.write_text((repo / 'tests/configs.txt').read_text().replace('wip unified\n', '') + '\nconfig fix-pass-pipeline-stress unified seeds=1 dev-unified=true planetary-fix-pass=true planetary-resources=true\n')
runner.CONFIGS = str(cfg)
print('Stress fixture snapshot: ' + str(mod), flush=True)
raise SystemExit(runner.main(['unified', '--modset', 'sa', '--only', 'fix-pass-pipeline-stress', '--jobs', '1', '--dir', str(mod)]))

#!/usr/bin/env python3
# Test the fix pass on unpaid resource requirements in a temporary mod snapshot.
# Run: python3 dev/test-fix-pass.py
# The normal run-tests launcher enforces the shared Factorio process limit.
import importlib.util
from pathlib import Path
import tempfile
repo = Path(__file__).resolve().parent.parent
spec = importlib.util.spec_from_file_location('fixpass_runner', str(repo / 'dev/run-tests.py'))
runner = importlib.util.module_from_spec(spec)
spec.loader.exec_module(runner)
base = Path(tempfile.mkdtemp(prefix='fixpass-chooser-', dir='/private/tmp'))
mod = base / 'propertyrandomizer'
runner.snapshot(str(mod), None, False, None)
source = mod / 'data-final-fixes.lua'
text = source.read_text()
fixture = '''
-- Verification fixture in the temporary snapshot only: make unpaid resource requirements.
local stress_resources = require("randomizations/planetary/resources")
local stress_check = require("randomizations/planetary/check")
local stress_saved = table.deepcopy(data.raw)
local stress_before = stress_check.sort(new_logic)
stress_resources.execute("fixpass-chooser-stress")
local stress_after = stress_check.sort(new_logic)
local stress_lost = stress_check.required_failures(stress_before, stress_after, {})
log("FIXPASS STRESS initial failures: " .. #stress_lost)
assert(#stress_lost > 0, "The fixture needs unpaid prerequisites")
local stress_remaining = fix_pass.run({
    logic = new_logic,
    unified = unified,
    before = stress_before,
    after = stress_after,
    variants_of = {},
})
local stress_old_failures = {}
for _, failure in pairs(stress_lost) do
    stress_old_failures[failure.text] = true
end
for _, failure in pairs(stress_remaining) do
    log("FIXPASS STRESS remaining: " .. failure.text)
    assert(stress_old_failures[failure.text] ~= nil, "Chooser introduced a new failure: " .. failure.text)
end
assert(#stress_remaining == 0, "Chooser must restore every required goal in the fixture")
log("FIXPASS STRESS final failures: " .. #stress_remaining)
-- Restore the normal world so the runner can complete all its ordinary checks.
data.raw = stress_saved
prepare_world()
'''
text = text.replace('prepare_world()\n\n----------------------------------------------------------------------', 'prepare_world()\n'+fixture+'\n----------------------------------------------------------------------', 1)
source.write_text(text)
cfg = base / 'configs.txt'
cfg.write_text((repo / 'tests/configs.txt').read_text().replace('wip unified\n', '') + '\nconfig fix-pass-chooser-stress unified seeds=1 dev-unified=true planetary-fix-pass=true operation-readiness=false\n')
runner.CONFIGS = str(cfg)
print('Stress fixture snapshot: ' + str(mod), flush=True)
raise SystemExit(runner.main(['unified', '--modset', 'sa', '--only', 'fix-pass-chooser-stress', '--jobs', '1', '--dir', str(mod)]))

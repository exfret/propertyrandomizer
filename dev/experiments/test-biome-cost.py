#!/usr/bin/env python3
"""Measure biome work in isolated snapshots through the existing headless runner.

Run with --instructions for a count-only Lua hook (no stack sampling), or without
it for wall times. Run serial pairs; instruction-mode wall times are diagnostic.
The counter excludes native code and GC work; intervals have <1000 instruction
boundary uncertainty. Only the disposable snapshot is instrumented.
"""
import argparse
from collections import defaultdict
import importlib.util
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[2]

MEASURE = '''local measure = {}
measure.counts = {}
measure.calls = {}
measure.active = {}
measure.begin = function(name)
    log("BIOMECOST begin " .. name)
    return prbiome_instructions or 0
end
measure.finish = function(name, before)
    local instructions = (prbiome_instructions or 0) - before
    log("BIOMECOST end " .. name .. " instructions=" .. instructions)
end
measure.record = function(name, before)
    measure.counts[name] = (measure.counts[name] or 0) + (prbiome_instructions or 0) - before
    measure.calls[name] = (measure.calls[name] or 0) + 1
end
measure.wrap = function(name, fn)
    return function(...)
        local before = prbiome_instructions or 0
        local results = table.pack(fn(...))
        measure.counts[name] = (measure.counts[name] or 0) + (prbiome_instructions or 0) - before
        measure.calls[name] = (measure.calls[name] or 0) + 1
        return table.unpack(results, 1, results.n)
    end
end
measure.phase = function(name, fn)
    return function(...)
        local before = measure.begin(name)
        local results = table.pack(fn(...))
        measure.finish(name, before)
        return table.unpack(results, 1, results.n)
    end
end
measure.summary = function()
    for name, instructions in pairs(measure.counts) do
        log("BIOMECOST aggregate " .. name .. " instructions=" .. instructions .. " calls=" .. measure.calls[name])
    end
end
return measure
'''


def instrument(snapshot):
    (snapshot / 'dev/experiments/biome-cost.lua').write_text(MEASURE)
    def edit(module, transform):
        path = snapshot / (module + '.lua')
        source = path.read_text()
        source = 'local biome_cost = require("dev/experiments/biome-cost")\n' + source
        path.write_text(transform(source))
    def wrap(module, owner, methods):
        def transform(source):
            additions = '\n'.join(f'{owner}.{method} = biome_cost.phase("{label}", {owner}.{method})'
                                  for method, label in methods)
            # Only the final module return, not an early function return.
            index = source.rfind('return ' + owner)
            return source[:index] + additions + '\n\n' + source[index:]
        edit(module, transform)
    wrap('src/randomizations/planetary/biome-placement', 'placement', [('prepare', 'biome.prepare')])
    wrap('src/randomizations/unified/handlers/biome-placement', 'placement', [
        ('spoof', 'biome.compile'), ('pool_entries', 'biome.pool'), ('reflect', 'biome.reflect')])
    wrap('src/randomizations/planetary/biome-collision', 'collision', [('refresh', 'biome.refresh')])
    wrap('src/logic/init', 'logic', [('build', 'graph.build')])
    wrap('src/lib/sort/context-sort', 'top', [('sort', 'graph.sort')])
    def promotion(source):
        index = source.rfind('    return state')
        methods = ['required_contexts', 'head_boundary_contexts', 'head_pays', 'head_candidate_ok', 'resolve_head']
        additions = '\n'.join(f'    state.{method} = biome_cost.wrap("promotion.{method}", state.{method})'
                              for method in methods)
        phases = ['promise_mechanics', 'promise_single_context_recipes']
        additions += '\n' + '\n'.join(f'    state.{method} = biome_cost.phase("promotion.{method}", state.{method})'
                                      for method in phases)
        return source[:index] + additions + '\n' + source[index:]
    edit('src/randomizations/unified/skeleton/promotion', promotion)
    wrap('src/randomizations/unified/skeleton/promotion', 'promotion', [('new', 'promotion.setup')])
    def runner(source):
        source = source.replace('\n    for dep_ind, dep in pairs(sorted_deps) do',
                                '\n    local biome_cost_before = biome_cost.begin("generic.search")\n    for dep_ind, dep in pairs(sorted_deps) do')
        source = source.replace('        for _, head_key in pairs(dep_to_heads[dep]) do\n            local head = random_graph.nodes[head_key]',
                                '        for _, head_key in pairs(dep_to_heads[dep]) do\n            local head_cost_before = prbiome_instructions or 0\n            local head = random_graph.nodes[head_key]')
        source = source.replace('            end\n        end\n    end\n    for handler_id, stats in pairs(handler_to_search_stats) do',
                                '            end\n            biome_cost.record("handler." .. handler_id, head_cost_before)\n        end\n    end\n    biome_cost.finish("generic.search", biome_cost_before)\n    biome_cost.summary()\n    for handler_id, stats in pairs(handler_to_search_stats) do')
        return source
    edit('src/randomizations/unified/execute', runner)
    # Count only: no per-tick stack capture or logs, and no changed GC policy.
    (snapshot / 'dev/profiler-mod/instrument-data.lua').write_text('''prbiome_instructions = 0
local function count()
    prbiome_instructions = prbiome_instructions + 1000
end
debug.sethook(count, "", 1000)
log("BIOMECOST counter interval=1000")
''')
    (snapshot / 'dev/profiler-mod/instrument-after-data.lua').write_text('''debug.sethook()
log("BIOMECOST total instructions=" .. prbiome_instructions)
''')


def parse(log):
    phases = defaultdict(lambda: {'seconds': 0., 'instructions': 0, 'calls': 0})
    active = defaultdict(list)
    aggregates = {}
    for line in log.splitlines():
        match = re.match(r'\s*([\d.]+).*BIOMECOST (begin|end) (\S+)(?: instructions=(\d+))?', line)
        if match:
            stamp, action, name, instructions = match.groups()
            if action == 'begin':
                active[name].append(float(stamp))
            else:
                phases[name]['seconds'] += float(stamp) - active[name].pop()
                phases[name]['instructions'] += int(instructions or 0)
                phases[name]['calls'] += 1
        match = re.search(r'BIOMECOST aggregate (\S+) instructions=(\d+) calls=(\d+)', line)
        if match:
            name, instructions, calls = match.groups()
            aggregates[name] = {'instructions': int(instructions), 'calls': int(calls)}
    return {'phases': dict(phases), 'aggregates': aggregates,
            'search': re.findall(r'SEARCH biome_placement:.*', log),
            'assignments': re.findall(r'Biome second pass:.*', log),
            'total_instructions': [int(n) for n in re.findall(r'BIOMECOST total instructions=(\d+)', log)]}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--instructions', action='store_true')
    parser.add_argument('--pairs', type=int, default=1)
    parser.add_argument('--modset', default='sa')
    parser.add_argument('--preview', action='store_true')
    parser.add_argument('--dupes', action='store_true')
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    sys.path.insert(0, str(ROOT / 'dev'))
    spec = importlib.util.spec_from_file_location('biome_cost_runner', ROOT / 'dev/run-tests.py')
    runner = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = runner
    spec.loader.exec_module(runner)
    scratch = Path(tempfile.mkdtemp(prefix='propertyrandomizer-biome-cost-'))
    snapshot = scratch / 'mod'
    runner.snapshot(str(snapshot), None, False, None)
    instrument(snapshot)
    settings = 'logistic=none production=none military=none misc=none'
    if args.preview:
        # Match the repository's existing preview configuration exactly.
        lines = (snapshot / 'tests/configs.txt').read_text().splitlines()
        line = next(line for line in lines if line.startswith('config biome-placement-preview '))
        settings = line.split('seeds=1 ', 1)[-1]
        settings = re.sub(r'planetary-biome-placement=\S+', '', settings)
    if args.dupes:
        settings += ' dupes=true'
    configs = []
    for pair in range(args.pairs):
        for offset, enabled in enumerate(([False, True] if pair % 2 == 0 else [True, False])):
            label = f'biome-cost-{pair:02}-{offset}-' + ('on' if enabled else 'off')
            configs.append(f'config {label} settings seeds=1 {settings} planetary-biome-placement={str(enabled).lower()}')
    with (snapshot / 'tests/configs.txt').open('a') as file:
        file.write('\n' + '\n'.join(configs) + '\n')
    launcher = scratch / 'runner.py'
    launcher.write_text(
        "import importlib.util, sys\n"
        + f"sys.path.insert(0, {str(ROOT / 'dev')!r})\n"
        + f"spec = importlib.util.spec_from_file_location('runner', {str(ROOT / 'dev/run-tests.py')!r})\n"
        + "runner = importlib.util.module_from_spec(spec)\n"
        + "sys.modules[spec.name] = runner\n"
        + "spec.loader.exec_module(runner)\n"
        + f"runner.PROFILER_MOD = {str(snapshot / 'dev/profiler-mod')!r}\n"
        + "raise SystemExit(runner.main(sys.argv[1:]))\n")
    command = [sys.executable, str(launcher), 'settings', '--dir', str(snapshot),
               '--modset', args.modset, '--only', 'biome-cost-', '--jobs', '1']
    if args.instructions:
        command.append('--profile')
    args.output.mkdir(parents=True, exist_ok=True)
    print('Snapshot:', snapshot, flush=True)
    result = subprocess.run(command, cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    print(result.stdout, end='', flush=True)
    (args.output / 'runner.txt').write_text(result.stdout)
    match = re.search(r'Full summary in (.+)/summary.txt', result.stdout)
    if match is None:
        raise SystemExit(result.returncode or 1)
    logs = Path(match.group(1))
    report = {'snapshot': str(snapshot), 'instructions': args.instructions, 'modset': args.modset,
              'seed': 1, 'settings': settings, 'counter_interval': 1000 if args.instructions else None, 'runs': {}}
    for run in sorted((logs / 'runs').iterdir()):
        if not (run / 'create.log').is_file():
            continue
        destination = args.output / run.name
        destination.mkdir(exist_ok=True)
        for filename in ('create.log', 'control.log', 'profile.txt'):
            if (run / filename).is_file():
                shutil.copy2(run / filename, destination / filename)
        report['runs'][run.name] = parse((run / 'create.log').read_text())
    if args.instructions and any(not run['total_instructions'] or not all(run['total_instructions'])
                                 for run in report['runs'].values()):
        raise SystemExit('Instruction hook did not run; measurements are invalid')
    (args.output / 'measurements.json').write_text(json.dumps(report, indent=2) + '\n')
    print('Measurements:', args.output / 'measurements.json', flush=True)
    raise SystemExit(result.returncode)


if __name__ == '__main__':
    main()

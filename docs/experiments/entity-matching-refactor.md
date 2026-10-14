# Shared matching refactor, 2026-10-13

The entity prerequisite search and monotone matching now share ordinary Kuhn
augmentation (`src/lib/graph/bipartite-matching.lua`) and an outer
proposal/validation/refinement driver (`src/lib/graph/matching-refinement.lua`).
Entity policy remains in its handler: dependency order, the 50% category coin,
shuffled candidates, physical compatibility, progression contexts, and atomic
mining-return rewires. Monotone matching retains its shuffled traversal order,
current-slot fallback, fixed resource pairs, resource repair, proofs and gate.

The old entity search validated each complete path inside recursive backtracking.
A failed validation could enumerate factorially many paths. The shared search
visits each slot once per proposal; whole-path validation happens afterward.
Entity eligibility/context checks are cached only while the assignment is
unchanged. Failed promises identify their node/context; newly discovered mining
obligations constrain the next proposal. A rejection with no new requirement, or
10 failed refinements, retains the previous valid assignment. This follows
monotone matching's fallback rule; it does not blindly blacklist an edge because
a whole path failed.

## Correctness

- Before: 10 selected unit-test files passed. After: 11 passed.
- All 20,480 three-head/four-slot graphs and fixed-slot variants agree with an
  independent enumeration oracle and the pre-extraction Kuhn implementation;
  assignments and candidate callback order are identical.
- All 2,600 seeded calls in the existing monotone-matching fixture suite produce
  exactly the same assignments before and after extraction.
- Regression coverage includes non-reciprocal cycles, displacement of earlier
  choices, free slots, optional/protected detachment, no leaked assignment on
  rejection, learned constraints, no-information fallback and retry limits.
- A real entity-handler fixture verifies that learning mining-return obligations
  keeps both promised returns and sends a friendly head to an unused item slot.
- Promotion tests verify failed normal/solvent promises report a context and roll
  back without losing the previous backing.

## Method

Frozen source snapshots: `/tmp/entity-matching-refactor/before` and
`/tmp/entity-matching-refactor/after`. After is a clone of before with only these
six production files overlaid: the two shared modules, the entity matching
adapter, entity handler, promotion and monotone matching. Concurrent unrelated
working-tree edits are excluded. The same profiler/helper sources and config
are used on both sides.

Each snapshot is tested with:

```sh
python3 dev/run-tests.py unified --only entity-effects --modset base --modset sa --jobs 2 --profile --profile-interval 100000 --dir SNAPSHOT
```

Instruction estimates count stack samples inclusively, once per sample, at
100,000 Lua instructions/sample. These are instruction estimates, not timings;
wall times varied substantially. The runner's optional RSS sampler could not
run `ps` in the sandbox; instruction sampling and test completion are independent
of it. No memory comparison is claimed.

Standalone benchmark:

```sh
lua dev/experiments/test-entity-matching-performance.lua
```

This uses Lua 5.4 with a 1,000-instruction hook and excludes setup. These counts
are comparable before/after within that runtime, not directly to Factorio's VM.
The old matcher is loaded from the frozen baseline for the before measurement.

## Synthetic instruction counts

| Ten-head scenario | Before | After | Whole-path validations before → after |
| --- | ---: | ---: | ---: |
| Accept first path | ~1,000 | ~2,000 | 1 → 1 |
| Reject every path | 199,064,000 | ~1,000 | 986,409 → 1 |
| No closing edge | 164,401,000 | ~2,000 | 0 → 0 |

The first-path case pays a small abstraction/cache setup cost. The two failure
cases no longer enumerate permutations. The standalone monotone fixture suite
rises from 6,017,000 to 6,968,000 sampled instructions (+15.8%) across 2,600 small
matching calls; full-game matching counts are reported separately below.

Raw snapshots, runner output, profiles, differential assignment transcripts,
synthetic CSVs, and comparison scripts are in `/tmp/entity-matching-refactor`.

## Full-game results

All four runs passed before and after (base and Space Age, seeds 1 and 2).
Each reported zero unreachable recipes, lost protected contexts, missing
promised pebbles and furnace collisions. All four prototype checksums, logged
entity assignments and monotone round summaries are identical. All game trials
accepted their proposed paths: rejection/refinement behavior is covered by the
isolated regressions rather than by these four seeds.

Entity prerequisite search, inclusive (millions of sampled instructions):

| Run | Before | After | Reduction |
| --- | ---: | ---: | ---: |
| base--entity-effects@1 | 22.0M | 18.6M | 15.5% |
| base--entity-effects@2 | 35.7M | 28.9M | 19.0% |
| sa--entity-effects@1 | 238.1M | 176.4M | 25.9% |
| sa--entity-effects@2 | 285.5M | 174.0M | 39.1% |

The four runs together use **31.5% fewer entity-search instructions**. Total
sampled data-stage instructions fall from 7,684.4M to 7,503.4M (2.4%). This is
not a claim about wall time or every seed.

Full-game `random_matching`, inclusive (the shared-core extraction's overhead):

| Run | Before | After | Increase |
| --- | ---: | ---: | ---: |
| base--entity-effects@1 | 90.6M | 90.9M | 0.33% |
| base--entity-effects@2 | 92.8M | 93.1M | 0.32% |
| sa--entity-effects@1 | 248.9M | 249.8M | 0.36% |
| sa--entity-effects@2 | 243.9M | 244.7M | 0.33% |

The profiler has a 150-frame stack limit. No entity-search samples reach it.
Some deep monotone recursion does: those samples are attributed through the
operation's still-visible nested helper/candidate frames, counting each sample
only once. This avoids understating the shared-core extraction's overhead by
losing its outer frame.

Final audits: `dev/style-check.py` reports zero errors (warnings remain);
`dev/hardcoded-names.py` reports zero unapproved tables;
`dev/node-types.py` reports zero unapproved types/sites. `git diff --check` passes.

Profile roots:

- before: `/var/folders/g1/mv1c5tvx42v1974c7d004hf40000gn/T/propertyrandomizer-run-tests/run-20261013-220846-_a3vm4kq`
- after: `/var/folders/g1/mv1c5tvx42v1974c7d004hf40000gn/T/propertyrandomizer-run-tests/run-20261013-222618-jnxd4ddi`


## Entity-search budget follow-up

The original Space Age seed 2 entity search consumed 285.5M of 2,887.9M
instructions (9.9%). The shared matching refactor reduced that to 174.0M of
2,777.3M (6.3%), still expensive relative to a roughly 1% reference. The 199M-to-1K
synthetic rejection case above does not describe either real seed.

Further profiling found repeated static compatibility/prototype work and
progression proofs discarded after unrelated rewires. The follow-up keeps the
same candidate order and progression obligations while:

- filtering cheap category incompatibilities after shuffling and caching expensive
  physical checks lazily, retaining the current-slot fallback and checking
  changing progression requirements during search;
- caching prototype/owner lookups, fixed context transmission and connection ranks;
- collecting category pools once, preserving their original shuffled order;
- invalidating cached progression proofs through their recorded dependencies
  when edges change, including failed proofs and rejected-trial rollback, while
  retaining successful-trial proofs after commit;
- avoiding candidate-list copies when no detached endpoint is appended, and
  removing redundant per-proposal memoization from the Kuhn adapter.

Proof-cache retention is explicitly enabled only during the entity rewire
series. Other callers retain full invalidation. Connection metadata must remain
fixed during that series; cached ranks do not replace reachability checks.

The instruction comparison uses the same frozen source as the earlier report,
with only the matching adapter, entity handler, its geometry helper and
promotion overlaid. Full
entity-disabled runs are measured separately: enabling entities changes the
graph and subsequent choices, so their total difference is not the inclusive
cost of the search function. Search percentages must not be described as the
cost of the entire entity feature.

Additional regression coverage replays the promotion transaction/debt/context
suite with selective invalidation enabled and explicitly tests transitive true
and false cache invalidation across committed changes and rejected trials.


The final code also retains immutable removed edges during internal rewire
trials instead of deep-copying them. Trials with an external validation callback
retain the original defensive copy. The normal non-caching promotion path is
unchanged apart from shared lookup optimizations.

The final four-seed validation uses `/tmp/entity-search-budget/pool-cache`.
Space Age entity-disabled baselines are from `budget-cache`, before the final
entity-only lookup/pool changes and successful-trial cache retention (disabled
entity search never enables that cache). Both disabled runs keep their original
prototype checksums and pass MECHCHECK.

### Final instruction measurements

| Run | Refactor-only search | Optimized search | Optimized total | Search share |
| --- | ---: | ---: | ---: | ---: |
| base--entity-effects@1 | 18.6M | 6.2M | 643.3M | 0.96% |
| base--entity-effects@2 | 28.9M | 7.4M | 625.2M | 1.18% |
| sa--entity-effects@1 | 176.4M | 23.0M | 3185.6M | 0.72% |
| sa--entity-effects@2 | 174.0M | 23.8M | 2548.4M | 0.93% |

All four final runs pass map creation, MECHCHECK, reachability and control-stage
checks. All four prototype checksums and complete entity assignment transcripts
match the refactor-only baseline exactly. Twelve selected unit-test files pass,
including the cached-rewire promotion replay. Final audits report zero style
errors, unapproved name tables or unapproved node types; `git diff --check` passes.

The direct entity-search measurement includes its preparation, physical and
progression predicates, matching, rewire validation and reporting. The two
Space Age disabled baselines total 2,434.2M and 2,397.3M instructions. Enabling
the whole entity feature still costs more than the direct search measurement,
because it changes the graph and subsequent choices; the search's percentage
is not a claim that the entire feature adds only that percentage.

Machine-readable counts and checksum comparisons are in
`docs/experiments/entity-search-instructions.json`. Sampling remains at 100,000
instructions; small differences of that magnitude should not be overinterpreted.

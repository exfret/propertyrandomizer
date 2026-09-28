# Unified local recipe costs

The unified recipe ingredient handler still uses local pricing. The old recipe
randomizer continues to use global pricing.

## Why costs drifted

The original handler mixed several different production networks in one comparison:

- Its ingredient view could use an ingredient's cheaper home-room quote even when
  the resulting product was valued using local production in the judging room.
- Imports retained their original prices after their supplying recipes changed.
- Generated recycling could retain the original outputs during the search, then
  return different ingredients when recycling was regenerated for the built game.

These are pricing inconsistencies, rather than a reason to abandon local costs.

The reference graph also deliberately excludes unprocessed recipes. That can make
its target higher than the completed game's price, but this is not itself a bug:
it preserves the cost of production before later cheap routes are admitted. An
earlier revision removed this staging and was evaluated using lower final prices.
That did not demonstrate a better progression experience, so staging was restored
following the user's clarification.

## Changes

Both original and randomized worlds admit recipes in processing order. Each recipe
uses the staged original world as its reference, retaining the previous fallback
to complete original prices when its original ingredients cannot yet be priced.
It uses the local tier if the complete original local tier can price its original
ingredients; otherwise it uses the import-enabled tier. Candidate costs, resource
bills, fallback quotes, and the newer-resource bonus all use that same tier.

Both staged worlds retain unchanged recipes, including hidden ones. Generated
recycling is blocked while its source ingredients are pending, then regenerated
in a virtual prototype table as those ingredients become known. Both the initial
and incremental flow solvers read that table. Game prototypes are not changed by
the cost model.

Imports update from their supplying rooms. Changed import seeds rebuild the
affected full tier, because the incremental solver can propagate cheaper routes
but cannot retract an outdated cheap quote. Original import prices remain a
fallback for sources not yet priced in the staged world. Incremental propagation
uses the same iteration budget as a full flow solve.

## Assessment and limits

The user's acceptable bounds are up to 4x on any individual science pack and up
to 2x generally, interpreted here as the arithmetic mean of per-pack cost ratios.
A 10% increase is comfortably acceptable. The search still trades total cost
against resource composition, ingredient constraints, and its novelty bonus, so
these are validation bounds rather than enforced price ceilings.

The staged room topology comes from the original game. Other unified handlers can
change machines, categories, and item identities. Original fallback quotes also
remain necessary for forward dependencies. Consequently the completed world's
prices can differ from the quotes used during ingredient selection.

When measuring a finished unified world, rebuild its logic graph, recipe
availability, raw costs, and import sources first. Reusing the original rooms'
recipe availability produced misleading inflation measurements in the initial
diagnostic. Compare in the same original room and tier, and report a missing local
price separately rather than excluding it without explanation. Also compare
import-enabled prices, which can behave differently from local prices.

## Focused regression checks

Run from the mod root:

```sh
lua lib/cost/test-context-costs.lua
lua lib/cost/test-staged-recipes.lua
lua lib/test-recycling.lua
```

These cover consistent tier selection, matching resource bills, import-price
increases, tier-specific novelty, pending recycling, regenerated outputs in both
full and incremental flow solves, dependency-map replacement, and preservation
of the original prototypes.

## Current staged-reference validation, 2026-09-28

Space Age seed 750, `dev-unified=true`, tested with one Factorio process after
restoring reference staging. All 12 packs had prices, UNIFIEDCHECK and MECHCHECK
passed, and runtime reported 12/12 reachable. The run completed in 92 seconds.

| Comparison | Largest ratio | Mean ratio | Within 4x individual / 2x mean? |
| --- | ---: | ---: | --- |
| Original local tier, or full where originally necessary | 5.594 | 1.346 | No |
| Import-enabled tier for every pack | 5.485 | 1.521 | No |

Agricultural science exceeds the individual limit in both comparisons. Its
selection-time ingredient quote was 0.8045 against a staged original budget of
0.7128 (about 13% higher), so the 5.59x finished-world ratio cannot be explained
simply by calling the staged target too generous. The selected ingredients were
one pentapod egg quoted at 0.2111 and one iron gear wheel quoted at 0.5934.
The remaining discrepancy needs to be traced from those quotes to the completed
world's production routes. The average passes the user's tolerance, but the
individual bound is not currently satisfied even on this one checked seed.

Log:
`/tmp/propertyrandomizer-unified-costs/staged-current-dev/run-20260928-194103-1k2xata3/runs/sa--cost-probe@750/create.log`.

## Superseded unstaged-reference sample, 2026-09-28

Before restoration of reference staging: Space Age, seed 750, `dev-unified=true`, all handlers that
setting enables. The diagnostic rebuilt the completed world's graph before
pricing. Both UNIFIEDCHECK and MECHCHECK passed; runtime reported 12/12 science
packs reachable. All 12 packs had comparable prices, with no missing original
pricing tiers.

| Comparison against original game | Largest ratio | Mean ratio |
| --- | ---: | ---: |
| Original local tier, or full tier where originally necessary | 1.101 | 0.861 |
| Full/import-enabled tier for every pack | 2.168 | 1.011 |

The local-tier maximum was logistic science. Utility science was the full-tier
outlier (2.168x), while its local cost decreased to 0.772x. Keeping local targets
does not guarantee preservation of the original cheapest import route.

Promethium science also illustrates why the comparison must keep its tier fixed:
it had no original local price in its original room. The finished world gained a
local price, so the legacy home-price view jumped to 10.034x by switching from
full to local pricing. Comparing full to full gives 0.983x. That 10x number is not
a tenfold increase in the cost of the same production model.

These measurements do not validate the current implementation with reference
staging restored, nor do they establish that lower final prices improve progression.
The updated focused Lua suites pass 31 checks, including a regression showing that
an available expensive route keeps its staged reference price until the later
cheap route is admitted. Syntax and require-placement checks pass. No new headless
run was started for this correction.

Diagnostic log:
`/tmp/propertyrandomizer-unified-costs/complete-dev/run-20260928-190359-o06b9gp4/runs/sa--cost-probe@750/create.log`.
The temporary runner, capture, and summary scripts are in
`/tmp/propertyrandomizer-unified-costs/`. Extra diagnostic processes were stopped;
the final run completed and no Factorio test processes remained afterward.

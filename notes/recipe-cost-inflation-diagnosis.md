# Recipe cost inflation diagnosis — September 28, 2026

Follow-up: the user requested global pricing for the old randomizer. The implementation and validation below supersede the original investigation's statement that gameplay code was unchanged; the original measurements remain historical evidence.

## Implemented follow-up: global prices for ordinary recipe randomization

`randomizations/graph/recipe.lua` now uses one whole-game flow-cost table, with complete original recipes setting the target and processed randomized recipes setting candidate prices. It no longer builds per-room staged price sets or freezes imported ingredient prices from the original game. Resource bills and the newer-resource bonus use global prices too. Surface reachability, isolatability, furnace selection, and explicit automation eligibility still restrict which ingredients can be chosen. Unified's pricing implementation is unchanged.

The ordinary randomizer's science regression helper now also measures global costs, freshly before recipes and after recycling regeneration. The individual 4× and mean-below-2× limits, missing-price failures, and reachability checks are unchanged. These global ratios are not interchangeable with the earlier per-room ratios.

Initial global-price validation, before the concurrent raw-cost coverage update:

| Mod set / seed | Maximum priced-pack ratio | Mean priced-pack ratio |
|---|---:|---:|
| Base 749 | 1.109× | 0.988× |
| Base 750 | 1.001× | 0.938× |
| Base 751 | 1.321× | 1.077× |
| Space Age 749 | 3.223× | 1.302× |
| Space Age 750 | 1.659× | 1.205× |
| Space Age 751 | 1.826× | 1.030× |

Science-only mode also stays within the limits (base maximum 1.351×, Space Age maximum 1.577×). All eight maps retain their checked reachability. The four Space Age configurations still report incomplete coverage in this snapshot because agricultural science is unpriced; these are not clean suite passes.

The latest workspace snapshot includes a separate raw-cost coverage change. Seed 750 then prices **all 12 Space Age packs**, with maximum **1.661×** and mean **0.997×**; base seed 750 has maximum **1.029×** and mean **0.987×**. Both retain checked reachability. Default base and Space Age configurations were also checked after moving the test helper's imports to module scope. The eight science-cost parser tests and ten context-cost tests pass, and the edited Lua files parse successfully.

Logs: `/tmp/propertyrandomizer-global-pricing/runs/run-20260928-181442-sv9jjbnk/` (eight configurations) and `/tmp/propertyrandomizer-global-pricing/runs/run-20260928-181644-ohyg_mif/` (latest defaults and seed 750). This change removes local pricing from the old randomizer; it does not synchronize generated recycling during selection or guarantee that every seed preserves every price.

## Original investigation

The main cause of the repeated Space Age science inflation is a mismatch between the prices the search preserves and the prices of the finished recipes. The search mostly preserves staged, home/local ingredient costs. The finished science check measures the import-enabled production network, after recycling is regenerated. A close search match does not preserve that network's costs.

This investigation ran recipe-only randomization, with development unified disabled, on Space Age seeds 749–751. All instrumentation and experimental behavior changes were in temporary snapshots. No gameplay source was changed.

## 1. The target can already be several times the finished-game baseline

`lib/cost/context-costs.lua:321–336` deliberately prefers local costs at a material's home, even when its import-enabled cost is much lower. Away from home it can instead return the home price. Both target and candidate costs use this view. `randomizations/graph/recipe.lua:434–454` additionally prefers staged vanilla prices whenever all original ingredients have any price; availability does not mean the cheapest original production route has been processed.

Measured ingredient batches in seed 750 (excluding the recipe's own time/complexity charge):

| Recipe | Original ingredients, full/import tier | Search target | Selected ingredients, search prices |
|---|---:|---:|---:|
| Chemical science | 22.086 | 82.779 | 107.864 |
| Utility science | 58.425 | 413.031 | 402.581 |
| Cryogenic science | 20.063 | 55.839 | 56.032 |

Utility science demonstrates the dominant effect particularly clearly: its new ingredient batch matches the target to within 3%, but that target is **7.07×** the original import-enabled batch. Original processing units cost 100.139 in the home/local view versus 4.829 in the full tier; low-density structures cost 51.866 versus 9.658. The full tier's cheapest recipe for both is scrap recycling. Replacing these ingredients with a similarly expensive local batch need not retain their large scrap-derived discount.

The final utility pack price rises from 19.968 to 80.231, or **4.018×**, despite that close target match. Chemical science rises from 11.888 to 49.000, or **4.122×**.

Staging adds further inflation in some recipes. Chemical science's original batch costs 69.723 even in the complete home/local view, versus the staged target of 82.779. Cryogenic science prices its three original ice at 2.872 each during the search, although the complete original Aquilo view prices ice at 0.0203. The fallback only checks whether a price exists.

## 2. Search prices mix sources that the output's pricing tier does not use

`Set:cost_and_tier` chooses a source separately for each ingredient. The flow solver propagates recipe outputs separately in its local and full tiers. Thus summing the search's ingredient view does not necessarily reproduce either tier's price for the resulting product.

Seed 750 cryogenic science chooses 55 solid fuel, 5 plastic, and 6 cold fluoroketone. Plastic is priced at its Nauvis home cost of **1.288**, even when judging the recipe on Aquilo. After all changes, the Aquilo local solver prices plastic at **392.932**, while the full tier prices it at **2.170**. The local pack price rises from 24.347 to 1,006.368 (**41.33×**); its full-tier price rises from 10.737 to 29.464 (**2.744×**). The 41× value is not a mandatory import-enabled expense.

The solver splits the cryogenic recipe cost between the pack and hot-fluoroketone coproduct (`lib/cost/flow-cost.lua:267–284`). Its unchanged recipe outputs and time were verified in `/Applications/factorio.app/Contents/data/space-age/prototypes/recipe.lua:853`. Chemical and utility recipe amounts/time were verified in `/Applications/factorio.app/Contents/data/base/prototypes/recipe.lua:1963` and `:2020`.

## 3. Recycling changes after the search has committed its choices

`randomizations/graph/recipe.lua:296–303` includes unrandomized recipes in both staged worlds from the beginning. This includes the old generated recycling recipes. The source recipes are randomized while those reverse recipes still return their original ingredients. `data-final-fixes.lua:295` regenerates recycling only after recipe randomization finishes.

Freshly repricing the exact same selected recipes immediately before and after that regeneration isolates its contribution in seed 750:

| Measurement | Before recycling regeneration | After regeneration |
|---|---:|---:|
| Chemical pack, Nauvis full tier | 43.401 | 49.000 |
| Utility pack, Nauvis full tier | 56.084 | 80.231 |
| Cryogenic pack, Aquilo full tier | 27.240 | 29.464 |
| Cryogenic pack, Aquilo local tier | 46.770 | 1,006.368 |
| Plastic, Aquilo local tier | 9.093 | 392.932 |

Utility's price rises another **43%** solely across this regeneration step. Aquilo's cheap local plastic route also disappears. Recycling regeneration is necessary; the problem is evaluating selected recipes against reverse recipes that will subsequently change.

## 4. Imports are frozen, and the search has no hard price ceiling

Both staged sets use `imports_from = full_sets.set` (`randomizations/graph/recipe.lua:323`). Imported seed costs and resource bills therefore come from the original game (`lib/cost/context-costs.lua:237–265`). `Set:update` reuses those seed tables and does not refresh imports when their source recipes change. This is another reason staged search prices need not equal final prices; it is not needed to explain utility's oversized original target.

The aggregate penalty is approximately `max(new/old, old/new) - 1`. Search stops at a combined score of 1.5, with novelty bonuses of up to 0.5 per ingredient and a 3-point bonus for a qualifying nonstarting-planet swap (`helper-tables/constants.lua:79–85`, `randomizations/graph/recipe-cost.lua:330,412,428`). A low or negative score does not certify a close cost match, and reaching the end of the search returns a candidate even if it missed that score threshold. These bonuses can worsen individual selections but are not the primary cause of repeated utility inflation.

## Controlled experiments

Ratios below compare freshly measured final import-enabled pack prices to the same model's original prices, in each pack's original home room.

| Seed | Current utility ratio | Both ingredient bonuses disabled | Consistent full-tier search and unstaged target |
|---|---:|---:|---:|
| 749 | 3.772× | 3.232× | 0.956× |
| 750 | 4.018× | 2.779× | 0.981× |
| 751 | 2.367× | 3.938× | 1.001× |

The consistent-search experiment switches target and candidate aggregate/resource views to each room's full tier after the staged sets are initialized, and uses complete original prices for the target. It preserves the original measurement policy and import initialization. It changes neither the ingredient bonuses nor recycling regeneration. This is evidence for the diagnosis, not a proposed production patch: other packs still reach 2.998×, agricultural/promethium science remain unpriced, and seed 751 reports a lost mechanic context.

An additional broader experiment made `cost_and_tier` return the full tier everywhere and used unstaged targets. Utility ratios were likewise 0.956×, 0.981×, and 1.001×, but seeds 749 and 751 reported lost contexts. Disabling bonuses alone retained the repeated utility inflation. Neither experimental implementation was applied to the working tree.

All experimental maps completed creation and 600 control ticks. They are not clean suite passes: the later snapshots' runner treats missing agricultural/promethium baselines as failures. The initial baseline reproduced the preexisting seed-750 lost-context warning and both numeric cost-limit breaches. These are modeled costs, not factory optimization or measured gameplay effort; the sample establishes mechanisms and repeatability on these seeds, not an overall failure frequency.

## Fix direction

Choose the intended cost contract explicitly: early/local production, finished import-enabled production, or separate constraints on both. Use that same contract to price original ingredients, candidate ingredients, and finished products. Keep progression eligibility separate from the cost target so merely encountering an expensive original route first does not inflate the budget. Refresh affected imports and generated reverse recipes as their sources change, or exclude unstable routes from both sides of a consistently defined objective and validate the final network afterward. Recompute when costs can increase; the flow updater primarily propagates decreases. Apply any hard cost tolerance independently of diversity bonuses.

Simply reducing bonuses or tightening the existing search threshold cannot repair a target based on different economics from the final measurement.

Evidence and reproduction scripts: `/tmp/propertyrandomizer-cost-diagnosis/`. `results.json` contains the numeric results and resolved log paths. `run.py` patches temporary runner snapshots; `search.lua`, `end.lua`, and `capture.lua` supply instrumentation. Run from the repository root, for example:

```sh
DIAG_MODE=baseline python3 /tmp/propertyrandomizer-cost-diagnosis/run.py settings --modset sa --only science-cost --jobs 2
DIAG_MODE=no-bonus python3 /tmp/propertyrandomizer-cost-diagnosis/run.py settings --modset sa --only science-cost --jobs 2
DIAG_MODE=consistent-search python3 /tmp/propertyrandomizer-cost-diagnosis/run.py settings --modset sa --only science-cost --jobs 2
DIAG_MODE=recycling-detail python3 /tmp/propertyrandomizer-cost-diagnosis/run.py settings --modset sa --only science-cost@750 --jobs 1
```

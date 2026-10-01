# Planetary changes: the current approach

Written 2026-10-01, when superposed mode was retired from the plans. The user (2026-09-30) turned superposed mode off for now; its code stays until there's been more use. This is the reference for how planetary changes work now.

The older documents are in `notes/old/`:
- `context-shift-report/`: the theory of references, debts and repairs behind superposed mode.
- `planet-features-plan.md`: the plan for moving planet features, written around superposed mode. Its section 10 started the approach below.

## 1. The idea

Planetary changes move what makes planets different, then repair what the move broke, all before unified randomization runs. What moves: oceans, resources, lightning, freezing, which planets accept a recipe or building, and a planet's special machine. Unified then treats the changed and repaired world as its starting point, and keeps what section 5 says it must.

A change is kept only if the game after it, with its repairs, passes its check. A change that can't be repaired is undone, never the whole load. No planetary problem stops the game from loading, and what still goes wrong is warned about in the randomizer panel.

Repairs are fixes, not content: edits to recipes, categories, triggers, prerequisites and locks, recipe variants for one planet, and in a few places a delivered start (section 7). Unified randomizes the repaired recipes like any others afterwards.

## 2. The pipeline

All in `data-final-fixes.lua` and `randomizations/planetary/execute.lua`:

1. **Planet copies** (setting `propertyrandomizer-dupes`): copies of the planets, their science packs and their duplicated buildings, made before anything reads the prototypes (section 8). The code is in `lib/dupe-planets.lua`, `lib/dupe.lua` and `lib/dupe-planet-locks.lua`.
2. **The star map first** (`draw_map_first`): the connection graph (`connections.lua`), checked against the game before it. Its game becomes the one the other stages are checked against (`state.before`). That game gets its own home sets, since the map can change which planets come before which.
3. **The stages** (`run_stages`), in this order, each checked against `state.before`:
   - ocean swaps (`oceans.lua`, repaired by `scaffolds.lua`)
   - resource swaps (`resources.lua`)
   - lightning moves (`lightning.lua`)
   - freezing moves (`freezing.lua`)
   - planet locks and rewards (`locks.lua`, `rewards.lua`)
4. **The end of the stages** (`finish`): home sets are checked again if the changes moved them, and the game before the changes is kept for the checks after randomization (`planetary.before`).
5. **Unified randomization** (`randomizations/graph/unified/execute.lua`), which keeps what section 5 says.
6. **The per-attempt check** (`planetary.check_attempt`, logged as PLANETCHECK attempt). An attempt that loses planet goals first gets the items those goals lack made shippable (`transport.lua`). If goals are still lost, it's retried, at most twice per load (`PLANETARY_LOSS_RETRIES` in data-final-fixes.lua). After that the attempt is kept.
7. **The final checks**: MECHCHECK (unified's own), and PLANETCHECK final (`planetary.check_final`), which warns in the randomizer panel about planet goals the finished game lost.

The unified preview turns on ocean swaps, resource swaps and locks. Planet copies bring the connection graph with them. Lightning, freezing, rewards and the fix pass have settings of their own.

With the planetary fix pass on (section 4), the stages wait until unified is loaded (`planetary.pending`, `planetary.run_pending`), since the fix pass repairs with unified's handlers.

## 3. What a planet must keep: the planetary check

`check.required` in `randomizations/planetary/check.lua` compares a game against the one before the changes:

1. Every recipe that was reachable stays reachable somewhere.
2. Recipes locked to one planet by surface conditions keep every context they had there, isolatable and automatable included, as themselves or as a planet variant. Examples: its science pack, pentapod eggs, soils, the foundry. A spare version of a duplicated building is exempt (`check.spare_building_recipes`, `check.given_up`).
3. Every mechanic keeps its rooms and automatability (`protection.planetary_kept_context`). Rocket building and electricity keep their isolatability too. A moved feature (like an offshore fluid) is the exception: its goals follow the feature.
4. The starting planet's science packs keep every context they had there.

**Goal transport** (`check.transport`): the goals of something a change moved to another room follow it there. A moved lock's recipe, for example, must then be automatable on its new planet, with imports allowed.

With the fix pass on, two rules relax. Rocket building may use machines delivered once (`check.rocket_machines_importable`), and recipe categories aren't goals of their own (`check.skip_recipe_categories`).

## 4. Repairs: each stage's own, and the fix pass

**Each stage's own repairs:**
- **Oceans.** The recipes that took the old ocean fluid get variants that take the new one, in the same machine, and a plain conversion from the new fluid to the old one is a last resort. A variant is kept only where a lost goal's witness needs it, and becomes an edit of the original where only that planet used it (`scaffolds.execute`). Each variant is locked to its planet. A swap that still fails is rolled again a few times (`OCEAN_TRIES`).
- **Resources.** Recipes and mining triggers that belong to one planet follow its swap, as edits or as planet variants where the recipe is shared. Extra resource patches then cover what's still missing, chosen through a staged sort.
- **Lightning.** What builds lightning attractors follows lightning (locks and unlocks). A planet that loses lightning may start from delivered buildings (section 7). A planet that still can't do without lightning keeps it as well (`lightning.keep_old`).
- **Freezing.** The research for heat sources follows freezing to the new frozen planet: its discovery becomes the prerequisite, and mining something only that planet's family has becomes the trigger. If a planet that now freezes loses something, the stage is undone.
- **Locks.** A lock that breaks what its old planet must keep accepts that planet again ("widen") or goes back. Rewards move whole bundles and re-home the old planet's science.

**The planetary fix pass** (setting `propertyrandomizer-planetary-fix-pass`, `randomizations/planetary/fix-pass.lua`; work in progress, off by default):
- It covers resource swaps, lightning and freezing. The stage first moves without its own repairs. The fix pass then repairs it by changing what unified's handlers change: recipe ingredients and categories, energy sources, science packs, research triggers and prerequisites. It prefers what replaced the old thing on that planet, and makes a planet copy of a shared recipe when nothing fits everywhere.
- If it can't repair everything, the stage is undone with its random streams rewound, and runs the old way with its own repairs (`run_fix_first`).
- Ocean swaps always use their scaffolds (user, 2026-10-01). Scaffolds are a few targeted variants made in seconds, while the fix pass made broader changes, took much longer, and still left goals.
- It prices materials once per load, on the game before the moves, and stops after a round that makes no progress (2026-10-01).

## 5. What unified keeps

`randomizations/graph/unified/skeleton/protection.lua` names what unified must keep. Promotion promises it, monotone matching treats it as hard, and UNIFIEDCHECK and MECHCHECK check it:
- Mechanic contexts: rooms and automatability always, and isolatability where a node is built with `keep_isolatability`.
- Recipes locked to one planet family keep every context they have there.
- Transported goals (`PROTECT_TRANSPORTED` in execute.lua, on since 2026-10-01): a moved lock's recipe stays automatable on its new planet.
- What each kept bootstrap grant needs (`bootstrap.justifications`, section 7). The logic checks those grants when it's built, not in the graph, so unified must keep their reasons.

Promotion keeps a recipe's earliest context as well as its promised ones when they all come later (`state.required_contexts` in `skeleton/promotion.lua`). Before 2026-10-01, a recipe promised only on its new planet gave up the planet it started on. Its item's early pebbles then broke, and the item's recycling recipe was left unreachable, which ended attempts.

## 6. After unified

- PLANETCHECK attempt runs on each unified attempt. When lost planet goals only lack a shippable item, that item gets made shippable (`transport.blockers`, `transport.apply`: lighter or slower to spoil, only where needed). Otherwise the attempt is retried, at most twice per load.
- PLANETCHECK final warns in the panel about what the kept game lost.
- Known gap: the tech tree rebuild runs after the attempt check. What it loses (like bacteria cultivation's isolatability on Gleba with planet copies) only reaches PLANETCHECK final, as a warning with no retry.

## 7. Delivered starts (bootstrap)

A finite delivered start is fine when the planet can then make the thing itself (user, 2026-09-26). The code is `lib/logic/bootstrap.lua`; details are in `notes/bootstrap-infrastructure.txt`.
- On a planet a change made freeze, a delivered heat source counts as local if the planet can then make it. The room counts as warm if heat, once started by hand, keeps itself going.
- On a planet a lightning move left without lightning, any delivered building counts as local once the planet can make it (user, 2026-10-01, for Fulgora).
- The logic builds these as candidate grants and prunes them to a greatest fixpoint. Unified keeps what each kept grant needs.

## 8. Planet copies

- A planet and its copies are one family (`surface_sets.family_of`). No surface condition can tell them apart, so planet-locked recipes and locks count by family.
- Copy n has its own science packs, a parallel technology tree for them, and its own discovery chain.
- Duplicate n of a planet-locked building lives on planet copy n, and the original on the original planets (per-copy home locks). Buildings every planet accepts, like the heating tower, stay usable everywhere.

## 9. Settings and tests

- Settings: `propertyrandomizer-planetary-oceans`, `-resources`, `-lightning`, `-freezing`, `-locks`, `-rewards` (with `-rewards-rehome` and `-rewards-only`), `-connections` and `-fix-pass`. `-superposed` is off and stays until superposed mode is removed.
- Test configs in `tests/configs.txt`, all in the unified suite: `preview`, `dupes-preview`, `rewards`, `rewards-foundry`, `preview-rewards`, `fix-pass`, `fix-pass-climate`, `fix-pass-preview`, and the superposed ones. The settings suite also has single-stage configs: `planetary-resources`, `dupes-resources`, `dupes-oceans`, `planetary-connections` and `dupes-connections`.

## 10. Open work

- Freezing with planet copies: every frozen planet's move shares one heating research, so moves can't stand alone, and with several moves the research only follows the last one. Parked on 2026-10-01 (user, out of usage) as `notes/sessions/freezing-per-move.patch`, made against commit 867a968.
  - What the patch does: research by trigger gets one copy per dupe number, made only after the planet copies (`lib/dupe.lua`). Each move takes its own copy of the heating research, preferring its new planet's copy number. A move that breaks something goes back by itself, and moves are recorded from the planet that actually stops freezing. It adds `randomizations/planetary/test-freezing.lua` (26 checks).
  - Tested before the last two changes (moves put back in rounds, and the move recording): seed 1 of planet copies with freezing passed UNIFIEDCHECK, MECHCHECK and PLANETCHECK final, though all of its moves went back. On the user's seed the fix pass kept all three moves in about 5 minutes; that load then hit the test harness's 45-minute limit in unified on a busy machine. Seed 2 kept three moves in its second round. Neither change has had a load yet.
  - Moves onto Fulgora's family always go back, since heat can't be started there without power. So did a Gleba copy whose ocean became heavy oil. A failed move could try another target instead.
- Load time on large games (two copies per planet, 17 locations): the rewards draw took about 20 minutes on the user's seed.
- Rocket building and electricity keep their isolatability through the stages, but unified doesn't protect it.
- Mixing the fix pass with the stages' own repairs more generally (user, 2026-10-01: "in the future a more mixed combination might be good").
- Removing superposed mode's code: next week, after more use.

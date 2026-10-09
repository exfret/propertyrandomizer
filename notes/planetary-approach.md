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
   - Discovery then follows the map in tiers (`discovery.lua`, `DISCOVERY_FOLLOWS_MAP` in execute.lua, user 2026-10-08): a planet's tier is its hops from the start, and its discovery techs take the packs of every planet in the tier before. Tier 1 keeps its cost, the start gives nothing, and the Aquilo family gives like any other planet (user, 2026-10-09).
   - A planet holds back a pack whose making needs the discovery of a later tier (logged as "doesn't give").
   - Every planet of a tier needs the same planets, so home sets come one per tier, which makes sorts slower. On sa/dupes-preview seed 1 there were 5 instead of 2, and a load took 24.5 min instead of 14.7. Keeping home contexts only in their set's rooms (`top.home_contexts_in_set_rooms`) brought it to 20.6.
   - The tiers' home sets nest, so a smaller set's home context stands for the bigger ones' in the same room, and those aren't passed on (`top.implied_home_contexts`, user 2026-10-09). Sorts give the same results (`lib/graph/test-home-contexts.lua`). Not yet timed headless against the version without it.
   - A full check of the discovery stage, with only discoverers counting as gotten on their planet, undid the tiers on seed 1 (98 losses), so it was dropped (2026-10-09).
3. **The stages** (`run_stages`), in this order, each checked against `state.before`:
   - ocean swaps (`oceans.lua`, repaired by `scaffolds.lua`)
   - resource swaps (`resources.lua`)
   - lightning moves (`lightning.lua`)
   - freezing moves (`freezing.lua`)
   - demolisher moves, then biter moves (`enemies.lua`), each its own stage
   - planet locks and rewards (`locks.lua`, `rewards.lua`)
4. **The end of the stages** (`finish`): home sets are checked again if the changes moved them, and the game before the changes is kept for the checks after randomization (`planetary.before`).
5. **Unified randomization** (`randomizations/graph/unified/execute.lua`), which keeps what section 5 says.
6. **The per-attempt check** (`planetary.check_attempt`, logged as PLANETCHECK attempt). An attempt that loses planet goals first gets the items those goals lack made shippable (`transport.lua`). If goals are still lost, it's retried, at most twice per load (`PLANETARY_LOSS_RETRIES` in data-final-fixes.lua). After that the attempt is kept.
7. **The final checks**: MECHCHECK (unified's own), and PLANETCHECK final (`planetary.check_final`), which warns in the randomizer panel about planet goals the finished game lost.

The unified preview turns on ocean swaps, resource swaps and locks. Planet copies bring the connection graph with them. Lightning, freezing, enemy moves, rewards and the fix pass have settings of their own.

With the planetary fix pass on (section 4), the stages wait until unified is loaded (`planetary.pending`, `planetary.run_pending`), since the fix pass repairs with unified's handlers.

## 3. What a planet must keep: the planetary check

`check.required` in `randomizations/planetary/check.lua` compares a game against the one before the changes:

1. Every recipe that was reachable stays reachable somewhere.
2. Recipes locked to one planet by surface conditions keep every context they had there, isolatable and automatable included, as themselves or as a planet variant. Examples: its science pack, pentapod eggs, soils, the foundry. A spare version of a duplicated building is exempt (`check.spare_building_recipes`, `check.given_up`).
   - A variant's own variants count too (`check.versions`). On seed 0 with planet copies, Vulcanus's acid neutralisation was the resource swap's variant, and independent deposits made versions of that variant. Only one of those versions was local on Vulcanus, so counting one level lost the goal in most attempts (2026-10-09).
3. Every mechanic keeps its rooms and automatability (`protection.planetary_kept_context`). Rocket building and electricity keep their isolatability too. A moved feature (like an offshore fluid) is the exception: its goals follow the feature.
4. The starting planet's science packs keep every context they had there.

**Goal transport** (`check.transport`): the goals of something a change moved to another room follow it there. A moved lock's recipe, for example, must then be makeable on its new planet from that planet's own resources, isolatable and automatable like on its old planet (user, 2026-10-08; before, imports were allowed).

With the fix pass on, two rules relax. Rocket building may use machines delivered once (`check.rocket_machines_importable`), and recipe categories aren't goals of their own (`check.skip_recipe_categories`).

## 4. Repairs: each stage's own, and the fix pass

**Each stage's own repairs:**
- **Oceans.** The recipes that took the old ocean fluid get variants that take the new one, in the same machine. A variant is kept only where a lost goal's witness needs it, and becomes an edit of the original where only that planet used it (`scaffolds.execute`). Each planet gets its own variants, named after it and locked to it.
  - A plain conversion from the new fluid to the old one is a last resort. A game keeps at most `scaffolds.MAX_CONVERSIONS` (1, user, 2026-10-01); planets that would need more get their own oceans back, with a panel warning.
  - A swap that still fails is rolled again a few times (`OCEAN_TRIES`).
- **Resources.** The starting planet keeps its starting-area resources and its wells (`resources.in_starting_area`, user, 2026-10-01). In vanilla that keeps Nauvis's iron, copper, coal and stone (starting-area placement, `base/prototypes/entity/resources.lua`) and its crude oil (a well); uranium still swaps. Recipes and mining triggers that belong to one planet follow its swap, as edits or as planet variants where the recipe is shared. Extra resource patches then cover what's still missing, chosen through a staged sort. If a planet still fails with every extra patch, only the planets the failures are on get their original recipes and mining triggers back, without planet variants, and the patches are chosen again (user, 2026-10-08). Taking every planet's changes back left the user's seed 0 with 16 extra patches, over Nauvis copy 2's grenade and plastic edits, which took tungsten ore in place of coal. A run with more than half as many extra patches as planets fails in `dev/run-tests.py`, and the randomizer panel lists it in red. Idea for later (user, 2026-10-08): where a swap brings an ore only a later drill can mine (like tungsten ore and the big mining drill), make that drill available there instead of undoing the planet's edits.
- **Lightning.** What builds lightning attractors follows lightning (locks and unlocks). A planet that loses lightning may start from delivered buildings (section 7). A planet that still can't do without lightning keeps it as well (`lightning.keep_old`).
- **Freezing.** The research for heat sources follows freezing to the new frozen planet: its discovery becomes the prerequisite, and mining something only that planet's family has becomes the trigger. If a planet that now freezes loses something, the stage is undone.
- **Locks.** A moved recipe its new planet can't make from its own resources gets a version for that planet first (`lock-repairs.lua`, user 2026-10-08): ingredients the planet can't make are swapped for close ones it can, and the version is unlocked by research doable there (a technology unlocking the recipe that's researchable there already, or a copy of it with a trigger the planet meets, the planet's own science pack in place of other planets' packs, and its discovery as a prerequisite). The original stays beside it. A moved recipe still failing then goes back. A lock that breaks what its old planet must keep accepts that planet again ("widen"). Rewards move whole bundles and re-home the old planet's science.
  - A moved machine takes its ocean recipes along (follow the machine, user 2026-10-08): each new planet of the foundry gets its own version of the recipes only machines like it craft that took its old planet's ocean, taking the new planet's ocean instead (`lock_repairs.follow_machines`). With lava and the foundry both moved to Fulgora, Fulgora makes molten metals from lava again, while Vulcanus keeps its heavy-oil edit from the ocean stage.
- **Enemies** (work in progress, user, 2026-10-01: a quick shuffle). Demolisher territories (`map_gen_settings.territory_settings`) go to random planets other than the start, one per planet. The start's enemies come with their map gen slider (`enemy-base`), so each copy's slider goes to a random planet other than the start and other than planets with another pollutant (Gleba). A planet that gets biters gets the start's pollutant if it has none. The start keeps its own biters, since its captured spawners make biter eggs. Capturing a spawner is then a goal only on the start (the capture-spawner node's `planetary_feature = "biters"` with `feature_stays_on_start`). There are no repairs and no fix pass: a stage that still loses something is undone on its own.

**The planetary fix pass** (setting `propertyrandomizer-planetary-fix-pass`, `randomizations/planetary/fix-pass.lua`; work in progress, off by default):
- It covers resource swaps, lightning and freezing. Each stage moves and completes its specialized repairs first. Only remaining required failures invoke unified's prerequisite chooser, with first pass disabled (user, 2026-10-05).
- It can change recipe ingredients and categories, energy sources, mining fluids and research triggers. Satisfied prerequisites stay unchanged. Promotion requires replacements to have an actual backing before their dependent, so a borrowed old-world route cannot justify a circular replacement.
- It makes no repair plans or additional recipe variants. If required failures remain, the existing stage check undoes that planetary change.
- Ocean swaps always use their scaffolds (user, 2026-10-01). Scaffolds are a few targeted variants made in seconds, while the fix pass made broader changes, took much longer, and still left goals.
- Fix pass ignores the ordinary randomization pass's blacklists, customization exclusions and cost targets (user, 2026-10-05). Its ingredient chooser changes missing inputs directly, including raw resources; it keeps prerequisites that already have actual backing and checks replacements through promotion. Generated recycling follows the edited source recipes rather than being edited independently. `dev/test-fix-pass.py` exercises remaining failures using a temporary resource-swap fixture and rejects any newly lost goals.
- Each choice is checked in the actual rebuilt graph. If requirements remain and goals or availability improved, another choice uses refreshed ranks, so it can select prerequisites made available by the previous choices. Seed 1 of the resource-swap fixture went from 83 required failures to 7, then 0 (2026-10-05); its test requires zero remaining failures.

## 5. What unified keeps

`randomizations/graph/unified/skeleton/protection.lua` names what unified must keep. Promotion promises it, monotone matching treats it as hard, and UNIFIEDCHECK and MECHCHECK check it:
- Mechanic contexts: rooms and automatability always, and isolatability where a node is built with `keep_isolatability`.
- Recipes locked to one planet family keep every context they have there.
- Transported goals (`PROTECT_TRANSPORTED` in execute.lua, on since 2026-10-01): a moved lock's recipe stays makeable on its new planet. Versions the lock stage made are locked to their planet, so they're kept like any planet-locked recipe.
- Research triggers keep each technology isolatable wherever it's needed, not wherever its old trigger was (user, 2026-10-08): where something unified keeps rests on researching it from that planet's own resources (`tech_triggers.needed_contexts`). So a moved recipe's research stays doable on its new planet.
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
- Sharing a copy number doesn't tie planets together (user, 2026-10-08). A copy's technologies keep only prerequisites from their own planet's branch, and copied recipes take the start planet's ingredients as the ordinary items. Unified's ingredient search can still use anything from planets earlier on the map.
- Duplicate n of a planet-locked building lives on planet copy n, and the original on the original planets (per-copy home locks). Buildings every planet accepts, like the heating tower, stay usable everywhere.
- Copy n has its own wild entities: clones of the trees, rocks, ruins and other movable wild entities of its original (`lib/wild-entities.lua`; not resources, cliffs, planted entities, enemies, or ones a research trigger has you mine). Entity randomization only moves an entity found in the wild on one planet, so before this (2026-10-01) planet copies stopped every autoplace swap. A clone looks the same to the player and is placed the way its original was, listed or by the same slider. The original is kept off the copy, and a slider clone off the other planets with its slider, by a probability override in the planet's map gen (`entity:<name>:probability` named to a constant 0 expression), which the logic's room check honors. An entity taking another's wild spot takes its placement overrides along with its autoplace.

## 9. Settings and tests

- **Biome appearances** (`propertyrandomizer-planetary-biomes`, `randomizations/planetary/biomes.lua`; work in progress, off by default): the first regional biome mixer changes terrain appearances and decorative vegetation while preserving the host's land/water layout and gameplay properties. Harvestable plants and trees keep their existing appearances (user, 2026-10-05). Original Nauvis is excluded; cliffs remain independent. Appearance donors are captured after duplicates exist and before gameplay randomization. The final appearance pass runs after gameplay checks, planet tints and sounds, before the result summary and data dump. It has its own gate and does not enable the planetary gameplay stages or unified preview.
- Each affected planet draws two distinct original-planet palettes; when possible both differ from its own family. A shared broad noise mask chooses terrain appearances and decorative palettes together. Tiles retain their original scores and mechanical fields; clone names preserve native ordering for equal scores. Planting, covering and other tile-name restrictions accept equivalent appearances. Fluid and dropped-item-destroying tiles are outside this pass. Tiles written later by creation effects or frozen/thawed transformations may retain their original appearance (installed `space-age/prototypes/entity/resources.lua`, `entity/explosions.lua` and `tile/tiles-aquilo.lua`).
- Shoreline transitions are read from the finished donor tile, after ocean swaps have remapped their targets; other appearance fields use the early snapshot. Reading the old shoreline targets reintroduced lava graphics around an ammoniacal ocean on `vulcanus-exfret-2-copy` (user's 2026-10-05 prototype dump: its ocean fluids were correct, but biome clones still listed those tiles in the lava transition). `dev/test-biomes.lua` covers swaps, extra ocean appearances and unchanged shores; `dupes-oceans-biomes` combines both stages in the game harness.
- Settings: `propertyrandomizer-planetary-oceans`, `-resources`, `-lightning`, `-freezing`, `-locks`, `-rewards` (with `-rewards-rehome` and `-rewards-only`), `-connections`, `-enemies` (off by default, not in superposed mode) and `-fix-pass`. `-superposed` is off and stays until superposed mode is removed.
- Test configs in `tests/configs.txt`, all in the unified suite: `preview`, `dupes-preview`, `rewards`, `rewards-foundry`, `preview-rewards`, `fix-pass`, `fix-pass-climate`, `fix-pass-preview`, and the superposed ones. The settings suite also has single-stage configs: `planetary-resources`, `dupes-resources`, `dupes-oceans`, `planetary-connections` and `dupes-connections`.
- `planetary-biomes` and `dupes-biomes` in the settings suite isolate the appearance pass with numerical randomization off; duplicates retain their usual connection randomization.
- The biome runtime helper uses fixed map seeds and compares paired terrain surfaces before entity creation effects, requiring exact original-tile identities after mapping appearance clones back to their hosts. It permits visual palette corrections only beside a region boundary and checks actual planets for clone leaks and explicitly derived creation-effect patches. Seeds 1 and 2 passed with and without duplicates on 2026-10-05, using the current biome modules in an isolated earlier workspace snapshot while concurrent customizer edits blocked the shared workspace's localisation tests.
- The shoreline fix also passed a replay of all 448 biome appearances from the user's prototype dump, including 34 on the reported planet. The combined `dupes-oceans-biomes` seed 1 run in the current workspace passed its recipe/planetary checks and generated-map comparisons on all 14 eligible planets; original Nauvis stayed excluded.

## 10. Open work

- Freezing with planet copies: every frozen planet's move shares one heating research, so moves can't stand alone, and with several moves the research only follows the last one. Parked on 2026-10-01 (user, out of usage) as `notes/sessions/freezing-per-move.patch`, made against commit 867a968.
  - What the patch does: research by trigger gets one copy per dupe number, made only after the planet copies (`lib/dupe.lua`). Each move takes its own copy of the heating research, preferring its new planet's copy number. A move that breaks something goes back by itself, and moves are recorded from the planet that actually stops freezing. It adds `randomizations/planetary/test-freezing.lua` (26 checks).
  - Tested before the last two changes (moves put back in rounds, and the move recording): seed 1 of planet copies with freezing passed UNIFIEDCHECK, MECHCHECK and PLANETCHECK final, though all of its moves went back. On the user's seed the fix pass kept all three moves in about 5 minutes; that load then hit the test harness's 45-minute limit in unified on a busy machine. Seed 2 kept three moves in its second round. Neither change has had a load yet.
  - Moves onto Fulgora's family always go back, since heat can't be started there without power. So did a Gleba copy whose ocean became heavy oil. A failed move could try another target instead.
- Load time on large games (two copies per planet, 17 locations): the rewards draw took about 20 minutes on the user's seed.
- Rocket building and electricity keep their isolatability through the stages, but unified doesn't protect it.
- Removing superposed mode's code: next week, after more use.

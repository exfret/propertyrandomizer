# Recoloring duplicated entities (plan 2026-09-29, built the same day)

Goal: `lib/dupe.lua` copies of ~48 machines must look distinct without tinting the whole sprite.
Sources: Space Age data.raw dump (dev/run-tests.py --dump-data, sa/defaults), the sheets under
/Applications/factorio.app/Contents/data/{base,space-age}/graphics/entity/, prototype Lua next to them,
and the 2.1 docs (types/SpriteParameters.html, prototypes/RollingStockPrototype.html, classes/LuaEntity.html).

## How vanilla does it
Vanilla's own recolorable entities (turrets, car, spidertron, trains) use a separate greyscale
"mask" sheet drawn over the body with `apply_runtime_tint = true`. The mask covers only the flat
housing plates; barrels, lights, glass and rust stay untinted. The color comes from the entity at
runtime (LuaEntity.color lists rolling stock, car and spider-vehicle; turrets are not listed, so
their source is presumably the force, unverified). Locomotive and cargo wagon set a default
`color` in trains.lua:607 and :870; RollingStockPrototype also has `allow_manual_color`.

## Technique
1. A mask sheet per body sheet: same pixel layout as the body, but only the chosen region kept,
   and its pixels turned to luminance (grey) so `tint` multiplies into an even paint colour with the
   original shading. Everything else transparent.
2. In `dupe.entity`, for every animation/sprite that has a mask: insert a copy of the body layer
   right after it in `layers` (wrap non-layered sprites in `{layers = {body, mask}}`), swap the
   filename(s) for the mask path, set `tint = <dupe colour>`. All other params (frame_count,
   line_length, direction_count, shift, scale, stripes, filenames, frame_sequence, run_mode) are
   copied unchanged, so 4-way sheets, stripes and per-direction sheets need no special code.
   Shadow, glow, light, frozen, remnant, integration-patch and fluid/recipe-tinted layers are never masked.
3. Masks are generated offline by a dev script (dev/make-masks.py) from the installed game
   sheets, per entity recipe: sheet list + selection rule (hue band / saturation floor, or a
   low-saturation luminance band inside a polygon for grey shells). Output committed under
   graphics/masks/<entity>/. Prototype (pumpjack horsehead, hue 60-150, sat > 0.25): clean result,
   mask 418 KB as quantised grey+alpha vs 1.9 MB source. Half-resolution masks (scale doubled in
   the layer) would cut that by ~4x more; worth testing whether the soft edge is visible.
4. Colour palette: one fixed colour per dupe number (1..9, matching the number badges), bright and
   distinct, shared across all entities so "the blue variant" means the same thing everywhere.
   Keep the number badge on icons; optionally also mask the 64px icon with the same rule.
5. Entities with vanilla runtime masks: in the dupe, set `apply_runtime_tint = false` and
   `tint = <dupe colour>` on the existing mask layers (turrets, car, spidertron), or set `color` and
   `allow_manual_color = false` on the dupe (locomotive, cargo wagon). No new sheets needed.

## Per-entity classification
A = vanilla mask exists, B = clean paint hue (auto segmentation), C = no clean paint (polygon +
low-saturation luminance mask, or fall back to the number badge). "sheets" = mask sheets to generate.

| entity | class | region / colour | sheets | notes |
|---|---|---|---|---|
| gun turret | A | grey receiver + base ring | 0 | 6 vanilla masks |
| flamethrower turret | A | grey tank shell + base | 0 | 11 vanilla masks, 8 per-direction bases |
| laser turret | A | white housing shells | 0 | 2 masks; base has none |
| rocket turret | A | dome/cowl + base rim | 0 | 5 masks |
| railgun turret | A | barrel housing, breech, base | 0 | 17 masks, per octant |
| locomotive | A | cab + hull panels | 0 | set `color`, `allow_manual_color=false`; masks use tint_as_overlay |
| cargo wagon | A | roof + side panels | 0 | same as locomotive |
| car | A | fenders + hull sides | 0 | fixed tint replaces player colour |
| spidertron | A | dome shell (not eyes) | 0 | legs are separate spider-leg entities with their own tinted rows |
| bulk inserter | B | lime green legs/ring/arm plates | 4 | platform sheet has baked shadow |
| stack inserter | B | yellow arm + claw | 3-4 | platform nearly unpainted |
| solar panel | B | cyan cells | 1 | cells are "glass": decide cells vs grey frame |
| roboport | B | blue wing panels | 1 (4 with doors) | |
| construction robot | B | beige hull | 2 | keep red light, cyan working glow |
| logistic robot | B- | red leg tips (tiny) | 1 | may not read; fallback luminance on grey shell |
| pump | B- | copper ribbed housings | 4 | copper close to brass; liquid layer is fluid-tinted |
| pumpjack | B | lime horsehead | 1 | prototype done |
| electric mining drill | B | orange top bars | 8 (16 with wet) | drill head stays rust |
| big mining drill | B | brick-red drum + gantry | 8 (20 full) | per-direction folders |
| fusion reactor | B | powder-blue ring | 9 | main + 8 connection sheets |
| fusion generator | B | powder-blue cone | 12 | 4 dirs x body + 2 inputs |
| foundry | B | red-orange tower/hoppers | 2 | anim sheet 2704x2832 |
| agricultural tower | B | yellow-green column + crane boxes | ~10 | crane sheets up to 3248x2640; existing mask is the plant, recipe-tinted |
| biochamber | B- | olive side boxes | 1-2 | dome is same hue: select by sheet, not colour |
| assembling machine 3 | B | mossy green panels | 2 | weathered edges |
| chemical plant | B | yellow tank shells | 5 (12 full) | best hue in the set |
| electromagnetic plant | B | slate-blue armour | 5 | body lives in warm-up/rotate/cool-down sheets |
| cryogenic plant | B- | muted teal dome | 1-3 | its mask files are recipe tints, not paint |
| centrifuge | B- | yellow ladder frames (small) | 1 | subtle |
| heating tower | B- | mauve shell | 1 | |
| artillery turret | B | yellow hazard stripes on base | 1 | cannon sheets shared with artillery wagon |
| pipe | C | grey tube body | 18 | covers are shared: never mask |
| pipe to ground | C | grey tube body | 4 | |
| boiler | C | grey-green tank | 4 | |
| steam engine | C | three cylinder tanks | 2 | tanks static across 32 frames |
| accumulator | C | grey cylinders | 1 | charge/discharge reuse the same file |
| nuclear reactor | C | cream dome | 1 | |
| heat exchanger | C | maroon grille panels | 4 | |
| steam turbine | C | cream shroud | 2 | |
| electric furnace | C | blue-grey tanks | 1 | |
| oil refinery | C | rust tank shells | 4 | all rust |
| biolab | C | pink flesh dome | 1 | uncertain |
| lightning collector | C | lower housing | 1 | keep battery window |
| beacon | C | bottom frame | 2 | module masks are module tints |
| rocket silo | C | 06 + 14 body sheets | 2 | many light layers to skip |
| asteroid collector | C | off-white top housing | 6-10 | |
| crusher | C | beige frame plates | 2 | |
| thruster | C | bone-white top plates | 2 | |

## Open questions
1. Palette and count: how many dupes per entity, and one shared colour per dupe number?
2. Solar panel: recolor the cells or the frame?
3. Trains: fixed colour with manual recolor disabled, or keep player recolor and rely on the badge?
4. Spidertron: dupe the legs too so they match?
5. Half-resolution masks acceptable for size?
6. Class C: worth the polygon work now, or badge-only for a first version?

## What was built (2026-09-29)
User decisions after the plan: no in-game tint layers and no hand-made masks; the recolor happens offline on the pixels
(dev/make-dupe-graphics.py). After wrong turns (whole-sprite colorize, whole-sprite multiply tint, a bare saturation
mask, then a pixel-wise hue mask that left weathered paint patchy) the rule that holds: colorize ONLY the painted
parts, as solid panels. Per entity, dev/dupe-entities.txt says where the paint is and which colors the dupes get:
- paint (hue=..): pixels near the paint hue that are clearly paint seed the mask, it grows through connected duller or
  shaded pixels of that hue (hysteresis), then it is filled BY PANEL: where paint pixels are dense (win x win window,
  dens fraction) the highlights, rivets and weathering between them count too, a closing (close radius) bridges gaps,
  specks go, holes fill, the edge is feathered; inside, each pixel becomes 85% its brightness times the dupe color.
- grey: for machines with no paint (steam engine, thruster, crusher, asteroid collector, electric furnace casing,
  locomotive, cargo wagon, spidertron legs): the light unsaturated metal plates are the mask, like vanilla's own
  turret/vehicle masks; rust and shadow stay.
- dupes=C2,C3: the dupe colors, chosen per machine from red 355, orange 30, yellow 50, green 130, teal 185 so they
  make sense next to the original and its relatives (no red/blue inserter, no blue assembler); no purple, no blue
  (frozen look). Colors are muted (saturation 0.55, brightness gain capped) and applied at 70% (strength=, lower
  where a mask has to be large): a highlight, not a fluorescent coat (user, 2026-09-29). Grey-mode masks take only
  the brightest plates (val 0.6-0.72) so a machine like the crusher gets an accent rather than a coat. Icons get the
  same mask, so they match.
- whole: fallback only, unused.
Tune a line with `--inspect DIR --only NAME` (mask drawn magenta over grey, next to original and dupe 2, at 2x);
every one of the 48 was checked that way, several three times.
Body sheets come from the data.raw dump: shadows, glows, lights, runtime/recipe/module-tinted layers, working
visualisations flagged as effects (apply_tint, apply_recipe_tint, synced_fadeout, constant_speed, effect, scorch marks)
and effect-named sheets (smoke, dust, particles, fire, flame, sparks) are left alone; runtime-tinted rectangles that
share a sheet with the body (spider legs) keep their pixels. Output is 256-colour PNG (vanilla ships those too).
Dupes 2 and 3 of 48 entities: 478 sheets and icons, about 120 MB, untracked (never committed: the pre-commit hook
refuses graphics/dupes/) but shipped, since the release list takes untracked files.
Which entities are duplicated is derived: an entity is duplicated when its placing item's icon has a recolored copy
(lib/dupe-graphics-manifest.lua), so the curated list lives only in dev data. The dupes setting is visible again
(default off, "work in progress") and does only the entities for now.

## Items (2026-09-29, later the same day)
The user asked for item dupes next: every module, nutrients (as a fuel), the uranium and fusion fuel cells, the submachine
gun, rocket launcher and tesla gun, tesla ammo, mech armor, and the solar panel, portable fusion reactor, exoskeleton,
personal roboport and toolbelt equipment. Built on the same machinery:
- dev/dupe-items.txt lists them in the entity file's format; the generator (--items) recolors the item's icon and belt
  pictures, the icons of the recipes that make it (the five nutrients-from-* icons), the grid sprite of the equipment it
  places and, for an armor, the sheets of the character's animations for it (the mech armor's 11 body sheets; its mask,
  shadow and light sheets stay). A line's dupes= list now also says how many dupes the thing gets (one color, one dupe);
  the manifest stores the highest dupe number per file and lib/dupe.lua checks per number.
- lib/dupe.lua: after the entities, dupe.execute dupes every non-hidden item whose own icon has a recolor and that no
  entity brought along (collected first, since duplicating adds to the tables being read). dupe.item now dupes every
  non-hidden recipe whose main product is the item (was: only the recipe named like the item; nutrients has five, pipe
  has casting-pipe too), keeps the result amounts (was: amount 1, wrong for the 10-cell recipe), names the copy
  "<recipe> (Dupe n)", dupes the equipment the item places (place_as_equipment_result and take_result linked; recolored
  grid sprite, else a number badge) and, for an armor, copies the character animations that list it (armors = {copy})
  with recolored sheets, or adds the copy's name to the original animation's list when nothing is recolored.
  dupe.recipe now collects the unlocking technologies before adding effects (it added to effects while reading them).
- Colors: saturated parts (module bodies, the cells, solar cells) take the color at full strength (strength=1): a 70%
  blend of opposite hues (blue body toward orange) came out grey-tan. Module dupes avoid the other kinds' colors
  (speed orange/yellow, productivity teal/yellow, efficiency orange/teal, quality teal/orange; bulbs keep theirs).
  The two cells are green and cyan, so their dupes are warm (uranium yellow/red, fusion orange/pale gold). Guns, the
  quality module, nutrients and the portable fusion reactor (white, not orange) use grey mode; the mech armor mask is
  the orange plates only (low=0.3 val=0.35), the grey limbs stay.
- Not done: a module dupe keeps the original's beacon_tint (a speed module dupe still tints machines blue); the manifest
  could carry the dupe colors for that later. Personal roboport mk2 and the other battery/shield equipment aren't in
  the list; one line each would add them.

## Planets (2026-09-29, night)

What was built (lib/dupe-planets.lua, run before the other duplicates):
- One copy of every planet whose icon has a recolor (dev/dupe-planets.txt: hue rotations of the icon, the star map icon and
  the discovery technology's image, chosen by eye from three-angle previews). The copy is the planet prototype under a new
  name, so it keeps map generation (its own terrain from the name-derived seed), surface properties, pollutant, lightning
  and freezing. It sits beside its original on the star map (orientation nudged by 0.035 turns).
- Ocean tiles: clones of the handwritten family in oceans.lua (dupe.tile keeps the clone in every name-based rule:
  landfill and other tile conditions, neighbors, transitions, autoplace restrictions), registered as the copy's family, so
  an ocean swap can treat the copy as its own slot. The user chose duplicating the handwritten table over deriving it.
- Connections: each connection of the original again to the copy, and one between copies where both ends have copies
  (31 connections from 9 in vanilla Space Age).
- Discovery: a copy of each technology discovering the original; Nauvis (nothing discovers it) gets one modeled on the
  cheapest discovery technology (Fulgora's in vanilla, first by name among the 1000-unit ones), with only the discovery
  and platform-travel effects.
- Science: a planet's own packs are the lab inputs whose recipes only it accepts; for the starting planet, whose packs have
  no conditions, those its recipes let it make at all. Of those, the ones with recolors (dev/dupe-items.txt: the four
  planet packs; military, production and utility for Nauvis, the user's pick) are copied, added to every lab taking the
  original, and locked to the copy. Locks use the new properties through locks.fixed (never drawn, transported or reverted
  with moved locks): the original's recipe is fixed to its planet, the copy's to the copy. Nauvis's originals stay
  unlocked (vanilla).
- Parallel tree: every technology whose research takes a copied pack (no infinite or leveled research, no discovery
  technologies) gets a copy taking the copies instead, prerequisites mapped to copies where they exist, no effects of its
  own. Duplicated recipes are unlocked there instead of in the original technology (dupe.recipe), unless the copy's
  research takes what the recipe makes. Split: each copied pack in an original technology becomes the copy with
  probability 1/3. A plain sort before and after the split checks that everything reachable stays reachable, else the
  split is undone.
- Numbers on vanilla Space Age: 5 planets, 21 ocean tiles, 22 connections, 5 discovery technologies, 7 packs with 11
  locks, 117 parallel technologies (0 unreachable), 78 pack flips in 60 technologies; the stage takes about a second,
  and the dupes load went from 15.4 s to 18.1 s in the settings suite (the graph has 11 rooms instead of 6).
- Base game: no technology discovers a space location, so no planet is copied (and science packs are never copied on
  their own).

First preview runs (sa seeds 1-2, unified preview with the planetary stages) found two things the copies exposed:
- Scaffold variants (oceans.lua's planet variants) locked themselves with "a property whose value is unique to the planet".
  With copies no vanilla property is unique, so they took the new property my science locks had introduced, whose values
  the lock stage reassigns whenever it realizes its plan; the variants then pointed at the wrong room, Aquilo lost its
  ammonia route, the lock stage failed even with every lock widened, and first pass lost the variants' protected contexts
  on every attempt of seed 1. Fix: variants are fixed locks now (locks.fix in scaffolds.add, locks.unfix in remove), so
  every realize plans for them; realize also forgets locks whose prototype is gone (a restored data.raw).
- The careful rerun of the resource stage crashed in the game's resource-autoplace helper: it caches each autoplace set
  and the two count noise expressions it made, and a restored data.raw had lost the expressions. Fix: add_repair puts
  them back before calling the helper. Latent before the copies, since it needs a failed fast run after repairs.
- Load time before the fixes, seed 2: 543 s against 110 s for the same preview without dupes on the same busy machine
  (unified 377 s against 86 s, fixes and rebuild 87 s against 9 s, planetary 43 s against 9 s including the failed rerun).

After the fixes (sa seeds 1-2, preview with dupes, on a machine running eight Factorio processes): both pass. No
planetary stage undone, 47-48 locks moved among originals and copies, UNIFIEDCHECK ok, MECHCHECK ok (12.7-12.8k mechanic
contexts, 0 lost beyond isolatability). PLANETCHECK final: seed 2 0 failures, seed 1 40, all isolatable rocket building
on Fulgora and its copy (unified doesn't protect keep_planetary_isolatability; a known gap the copies make likelier).
Loads took 20 and 26 minutes there; seed 1 needed the careful planetary rerun, whose one-at-a-time scaffold pruning
alone took 12 minutes with 11 rooms. The user keeps one copy per planet; speed is the next job.

The user's first game with the copies crashed on arriving at Vulcanus 2 (2026-09-30, 00:00): "double value not in
range for fixed point number: inf" in the game's spot noise while generating the planet's entities. Cause: my
resource-repair fix above recreated the helper's patch count expressions at zero after the put-back data.raw, and the
helper, which remembers each autoplace set and its patch set indexes for the whole load, doesn't bump a count for a
patch set it already knows, so the careful run's repeated repairs (coal and sulfuric acid on Vulcanus 2) divided by a
zero count. Fix: the repairs' autoplace sets are named per run of the resource stage (resources.run), a set that meets
a put-back data.raw gets a fresh name, and a zero count is an error at load. The test helper now generates one chunk on
every planet when dupes, the preview or a planetary setting is on (PRTEST generated lines), so this class of crash
fails a test run; it costs about 0.1 s per planet. Plain-Lua reproduction of the helper's behavior: scratchpad
helper-repro.lua (count 1, then 0 after the put-back with the old fix, then 1 with a fresh set).

Not done: the planetary rule for locks over several planets (another session), a random star map graph, unique science
for modded planets without recolors (they'd share their original's packs), per-copy tuning of the parallel tree's size,
load time with 11 rooms (sorts in monotone matching, promotion, the rebuild and the slow scaffold pruning), showing the
resource swaps in the map settings screen (its rows are autoplace controls, which the swap leaves on their slots) or in
the randomizer panel.

## Random connection graph (2026-09-30, after midnight)

The user asked for a random space connection graph with vanilla's shape, no hop levels. Built as its own planetary
stage, randomizations/planetary/connections.lua (setting propertyrandomizer-planetary-connections, off by default and
not in the preview, but always on with Duplicates at the user's request; a game without connections skips it quietly;
skipped with the old graph randomizations like the other stages):
- Each location wants as many connections as its original has among original locations now (a planet copy counts
  as its original): in vanilla Nauvis 3, Gleba 4, Fulgora and Aquilo 3, Vulcanus and the edge 2, the shattered planet 1.
- A spanning tree grows outward from the start, locations taken in order of distance from the sun with a jitter of 8,
  each joining an already placed location with room; then more connections between locations with room until none is
  left. Pairs weigh exp(-|gap - typical| / 10), gap being the orbit gap and typical the median gap of the current
  original connections (10 in vanilla), so twins on one orbit and jumps across the system are both unlikely.
- A new connection copies the original connection between the most similar pair of orbits (length, asteroids, icons
  with the ends' icons swapped, from on the same side). Connections already joining a drawn pair stay; the rest go, and
  fields naming a removed one (the shattered planet distance achievements) point at a drawn connection to the same
  farther end. Orbits and star map positions stay.
- Checked like the other stages (rule 1 and rule 3 of the planetary check); undone if it fails.
- Sample draws: vanilla alone gave 8 connections, vanilla's with gleba-edge in place of aquilo-edge and fulgora-aquilo
  kept; with the copies 16 among 12 locations, three twin links, one Nauvis-edge jump. Both pass MECHCHECK with 0 lost,
  and every planet generates a chunk. Configs: planetary-connections and dupes-connections (settings suite).

## The starting planet in the resource swap (2026-09-30, after midnight)

The user asked for Nauvis's resources to enter the resource permutation too (the start keeps its water ocean). Done in
resources.slots (the start's placements are slots like the others, except in superposed mode, where a start without its
ores would be a whole-game debt), with a new rule 4 in check.required: the starting planet's science packs keep every
context they had there, so the repairs give the start back what its own science needs. Resource swaps alone on sa seeds
1-2: Nauvis's six slots took other planets' resources, its recipes specific to it followed the swap (the oil recipes
took the geyser's sulfuric acid, uranium processing took calcite on seed 2), and the repairs put copper, crude oil, iron
and uranium patches back near the crash site as the check demanded; MECHCHECK ok. In the base game the six slots
permute among themselves (iron in copper's footprint and so on), with no edits and no patches. Worth revisiting: an
in-place edit and a repair of the same resource can both happen (uranium processing takes calcite while an extra uranium
patch comes back for the mining mechanic), which is the pre-existing interplay of edits and repairs, now visible on the
start.

## Star map layout (2026-09-30, afternoon)

The user asked for a more planar map with the copies not beside their originals. connections.lua now lays the map out
after drawing the graph: every location but the starting planet gets a new orientation on its own orbit. Of 20 layouts,
each spreading the locations evenly (with jitter) over a fan around the old layout's middle (a quarter turn for seven
locations, wider for more) in the order of a random depth-first walk of the graph, improved by 60 place swaps and one
pass moving each location to the best of 8 spots along the fan, the cheapest wins: a crossing pair of routes costs 10,
two locations drawn within 4 map units of each other 5 plus the overlap, a route passing within 2.5 units of a location
it doesn't end at 3 plus the gap, and route length a little. Routes are drawn as straight lines (shape = "line") so what
the search judges is what the map shows. About 0.7 s in plain Lua 5.4 for 12 locations (a harness in the scratchpad,
layout-harness.lua and layout-sweep.lua, times connections.layout outside the game). Results: vanilla alone 0 crossings;
with the copies one crossing on every seed tried, which looks like the floor for that graph with orbits fixed. The
copies land wherever the graph reads best. Not done: orbits (distances) don't change; the start stays put.

## The old logic and planetary rerolls (2026-09-30, afternoon)

The user's game failed to load at lib/old-logic/build-graph-compat.lua:22 (a nil connection node) after the planetary
changes were rolled three times in superposed mode: each roll drew a new connection graph with new route names, but the
old logic's graph is built once, when its file is first required (at "Loading in new dependency graph file", after the
first planetary run), and the compat step then looked the latest roll's routes to Aquilo up in it by their current names.
Fix: data-final-fixes.lua rebuilds the old graph (build_graph.load()) right before the custom nodes, and the compat's
Aquilo rule skips connections the graph doesn't have. Costs one old-graph build (about a second). My test loads never
rerolled, which is why they passed; the reroll path itself still has no dedicated test.

## Superposed mode and the connection graph (2026-09-30, late afternoon)

The user plays with planetary-superposed on. Two findings from their loads:
- Their load before the old-logic crash owed about 13,500 goals on each of 3 unified attempts (so it rerolled twice, then
  would have undone the planetary changes). 40 of the starting debt's goals were space-connection-asteroids mechanics of
  routes my graph had replaced: nodes only the reference world had, which no attempt can pay. Most of the rest were
  science-pack-set mechanic contexts that the raw swaps break (PLANETCHECK superposed: 13,418 failures on the first roll),
  many more than without the copies because the split creates many science sets.
- Their next load crashed at unified/execute.lua:242 (a nil node): another session's new, uncommitted with-debt
  dependents sort (sort_for_deps, 2e) includes old-world-only nodes that superpose.add_debt adds, and its loop read every
  node from subdiv_graph. The replaced routes' nodes were the first old-only nodes to reach it.
Fixes: in superposed mode the connection graph is drawn before the reference sort (draw_connections_first in
planetary/execute.lua), so routes are part of the reference world and never debt; the claiming loop skips nodes the
game's graph doesn't have (a guard inside 2e's hunk, 2e told). New config dupes-superposed (unified suite).
- Root cause of the ~13,600 owed goals (found 2026-09-30, evening): session 2e made check.specific_to and check.only_on
  count a planet and its copies as one family (right for locks). The resource stage's in-place recipe edits used
  specific_to, so Nauvis 2 losing crude oil to a fluorine vent edited basic and advanced oil processing to take fluorine,
  for Nauvis too, which had kept its crude oil: no plastics on Nauvis, nothing after them, no space platform. The old
  crude-oil edge was a debt edge into the recipe (an AND node), which the superposition leaves out, so the debt reached
  nothing more than the game: promotion owed 0, unified paid nothing, and the settlement's fixes (patches, lock
  widening) can't undo a recipe edit. Fix: exact-room tests (check.only_on_room, check.specific_to_room and their node_
  versions) for the three in-place edits (resource recipe edits, resource trigger edits, scaffolds' edited original);
  test randomizations/planetary/test-in-place-edits.lua. Planetary stage on sa/dupes-superposed@1: in-place edits 23 to
  2, debt edges into AND nodes 23 to 2, raw-world failures 13,418 to 6,123 (mostly science-set contexts, now behind debt
  edges unified and the settlement can act on). Full load not yet run.
- 2026-09-30, evening: superposed mode is off for now (flag off in the user's game, per b2 relaying the user's decision);
  its code stays. My superposed-only pieces stay too (the connection draw before the reference sort, the start kept out of
  the resource swap in superposed mode), so it still works if turned back on; only the dupes-superposed test config went.
  The exact-room in-place edit fix stays either way: the same family-test bug hits normal mode's edits.

## Resource swaps follow through planet variants (2026-09-30, evening)

The user saw 17 extra resource patches on one load and asked why recipes weren't following the swap (their 2026-09-26
rule). With the copies almost every recipe is shared, so in-place edits couldn't follow two swaps; patches covered it.
User decision: duplicate recipes per planet ("I'm more okay with duplicating the recipes this way now that we're doing
duplication anyways"). Built in randomizations/planetary/resources.lua and execute.lua's run_resources:
- A recipe only one room made is still edited in place. Any other recipe a planet made from its own resources (or as one
  of the only planets making it) that takes a resource it lost gets a planned variant for that planet: "Iron plate
  (Nauvis)" taking scrap, named and badged like the ocean variants, unlocked like the original, locked to the planet
  (locks.fix). Barrels are left out (a hidden conversion otherwise).
- A lost resource whose slot chain loops back to the planet's own resources takes the first new resource of its kind.
  A replacement that a furnace-type machine already takes (furnaces pick recipes by input, FurnacePrototype in
  doc-html/prototype-api.json) gives way to another new resource of the same form; edits and variants of one pass claim
  their ingredients there.
- Mining triggers of shared resources (oil processing: crude oil, uranium processing, calcite processing) keep the
  resource and add each losing planet's replacement (a mine-entity trigger is met by any listed entity).
- Patches are chosen with a staged sort: each patch's autoplace edge sits behind a gate, so a patch stays only where no
  edit, variant or new resource can do it (the plain sort kept whatever its witnesses happened to use).
Results, sa/dupes-resources seeds 1-2: patches 17 and 16 before, 3 and 4 after, with 41 and 48 variants; MECHCHECK ok.
The remaining patches serve rocket building and electricity isolatability on that planet (like coal as fuel).
- Variants replace their originals (user, 2026-09-30, later): after the patches are chosen, each original without surface
  conditions of its own stops accepting its variants' planets (a fixed lock on every other room, locks.fix with
  depends_on, so the lock goes when data.raw is put back without the variants). Excluding every original broke
  isolatable rocket building and power on some planets, where the variant's new ingredient is harder to get locally
  (uranium ore is mined with sulfuric acid, base/prototypes/entity/resources.lua), so a staged sort with one "include"
  gate per original and planet gives an original back only where a failing goal's witness needs it, and all exclusions
  go if a goal fails even with every original back. Rule 1 (recipes stay reachable) counts variants now.
  Results: with the copies, seed 1 replaced 22 originals on 34 planets, kept 5 beside their variants, 3 patches; seed 2
  replaced 20 on 26, kept 20, 4 patches. Without copies: 6 replaced, 0 kept, 1 patch; 11 replaced, 3 kept, 2 patches.
  MECHCHECK ok on all four.

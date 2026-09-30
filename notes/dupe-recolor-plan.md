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

Not done: the planetary rule for locks over several planets (another session), a random star map graph, unique science
for modded planets without recolors (they'd share their original's packs), per-copy tuning of the parallel tree's size,
load time with 11 rooms (sorts in monotone matching, promotion, the rebuild and the slow scaffold pruning).

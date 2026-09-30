# Planet feature moves, with duplicated planets

Plan written 2026-09-29 for the request: move things like Vulcanus giving big mining drills, Gleba having a spoiling theme and Aquilo's lithium processing chain, mixed in with duplicated planets, in ways superposed randomization can repair. Nothing below is implemented yet. It builds on the planetary stages in `randomizations/planetary/` and on superposed mode (`notes/context-shift-report`, `lib/graph/settlement.lua`).

## 1. The idea

Everything a planet "has" enters the logic graph through a few kinds of edges that start at its room, or at something only its room provides, and end in OR nodes. A **feature** is a bundle of those edges with one home planet. Moving a feature re-homes each edge in `data.raw`, transports the feature's goals to the new planet (`check.transport`), and leaves each old edge as a debt edge into an OR node. That is exactly what superposed mode repairs: promotion keeps the transported goals while unified's choices pay what they can, settlement runs the feature's settler (repair, duplicate, addition, revert), and an attempt that still owes goals is rolled again, then undone with a panel warning.

So the rule for every move in this plan: **replace only OR-node inputs, root-repair whatever else has to change, and ship a goal transport and a settler with it.**

Duplicated planets are copies of a vanilla planet made before the planetary "before" sort, so they exist in both worlds and are never debts. A copy has its original's anchors: the same surface properties (so every lock that accepts the original accepts the copy), the same map generation (so the same resources, harvestables, oceans and enemies, on different terrain via `map_seed_offset`). Feature moves are what make copies differ from their originals. The **family** (original plus copies) replaces "the planet" wherever a rule says "one planet".

## 2. Facts this rests on

Game data (`/Applications/factorio.app/Contents/data`):
- Big mining drill: recipe locked to pressure 4000, category metallurgy, takes molten iron and tungsten carbide among others (`space-age/prototypes/recipe.lua:1781-1803`). Its technology is triggered by crafting a foundry, with prerequisites foundry and electric-mining-drill (`space-age/prototypes/technology.lua:687-705`). The foundry technology is triggered by crafting tungsten carbide, prerequisites calcite-processing and tungsten-carbide (`technology.lua:706-780`); the foundry recipe is itself locked to pressure 4000.
- Lithium chain: lithium takes holmium plate, lithium brine and ammonia in chemistry or cryogenics (`recipe.lua:2382-2404`); lithium plate is smelted from lithium (`recipe.lua:2405-2417`); lithium-processing has prerequisite planet-discovery-aquilo and is triggered by mining lithium-iceberg-big or -huge (`technology.lua:1702-1728`); lithium brine is a basic-fluid resource (`space-age/prototypes/entity/resources.lua:260-290`); cryogenic science needs lithium plate and is locked to pressure 300 (`recipe.lua:851-885`).
- Gleba's spoiling: spoil times in `space-age/prototypes/item.lua` (agricultural science pack 1 h at line 79; yumako and jellynut 60 min at 669-695; bacteria 1 min into ores at 717-740; nutrients 5 min, mash 3, jelly 4, bioflux 2 h at 809-863; biter and pentapod eggs spoil into units through spoil_to_trigger_result at 1044-1179). Gleba-locked recipes (pressure 2000): bacteria and their cultivation, the four soils, pentapod egg, agricultural science pack, biochamber. Yumako and jellynut trees only grow on Gleba soils (`space-age/prototypes/entity/plants.lua:816, 877`, tile_restriction).
- Every vanilla lock, from a scan of base and Space Age recipes and entities: pressure 4000 (Vulcanus): acid neutralisation, foundry, turbo belt/underground/splitter, big mining drill, metallurgic science pack. Pressure 2000 (Gleba): the list above. Magnetic field 99 (Fulgora): lightning rod and collector, electromagnetic science pack; electromagnetic plant is magnetic field 99 and up. Pressure 100..600 (Aquilo alone among vanilla planets: Fulgora is 800, Nauvis 1000, Gleba 2000, Vulcanus 4000, the platform 0): cryogenic plant, fusion reactor, fusion generator; quantum processor is pressure up to 600; cryogenic science pack exactly 300. Pressure 1000 (Nauvis): fish breeding, tree seed, captive biter spawner, biolab; agricultural tower 1000..2000. Gravity 0 or pressure 0 (space): the thruster fuels, space and promethium science, the hub, asteroid collector, crusher, thruster. Planet surface properties are in `space-age/prototypes/planet/planet.lua` (lines 42-48, 144-150, 312-318, 637-644); the platform's are in `space-age/prototypes/surface.lua:11-13`; defaults in `base/prototypes/planet/surface-property.lua`.
- Planet discovery: planet-discovery-* are unit technologies (1000 of automation, logistic, chemical and space science) with prerequisite space-platform-thruster, plus landfill for Gleba and accumulators for Fulgora (`technology.lua:360-480`). Space connections have from, to, length and asteroid_spawn_definitions (`planet.lua:743` on).
- Prototype fields, from the 2.1 docs in `/Applications/factorio.app/Contents/doc-html/prototypes/`: PlanetPrototype has map_seed_offset, entities_require_heating, pollutant_type, map_gen_settings, surface_properties, lightning_properties; SpaceLocationPrototype has distance, orientation, magnitude, starmap_icon(s), asteroid_spawn_definitions and the procession catalogues; SpaceConnectionPrototype has from, to, length, asteroid_spawn_definitions.

Mod code:
- Rooms are every planet and surface prototype (`lib/lookup/1-raw.lua:15-44`); a planet room is fed by its space-location, which is reached through connections or discovered through technologies with an unlock-space-location effect (`lib/logic/abstract.lua:44-72`, `lib/logic/concrete.lua:1800-1848`, `lib/lookup/2-simple/science.lua:78-95`). Home sets come from discoverers (`lib/graph/context-sort.lua:377-440`). None of this names a planet, so a copied planet with a copied discovery technology and copied connections is a room like any other.
- Anchor edges: autoplace `room-autoplace --> entity` (`concrete.lua:190-200`) and `--> tile` (1990); locks `room --> recipe-surface-condition` (1637-1647) and `room --> entity-build-surface-condition` (372-381); unlocks `technology --> recipe-tech-unlock` (1622-1630); triggers `item-craft / entity-mine / ... --> technology`, an AND node, and only the first entity of a mine-entity trigger (1910-1955); spoiling `item --> item` (1325) and `item --> entity` (219-224); deliveries between rooms only for items that last a trip (`dutils.survives_trip`, 1318 and 1427; the trip is 30 min, `helper-tables/constants.lua:116`); lightning and warmth are OR nodes over rooms (`abstract.lua:250-320`).
- The planet-locked rule keeps a recipe's contexts only when all its pebbles are in one planet room (`randomizations/graph/unified/skeleton/protection.lua:61-83`); "specific to a planet" is only-there or every isolatable context there (`randomizations/planetary/check.lua:96-130`). Both say "one room", which copies break (section 5).
- Superposition adds an old edge as a debt only into an OR node or an old-only node (`lib/graph/superpose.lua`, `lib/graph/settlement.lua:47-60`). Today's debt edges into AND nodes are the resource stage's in-place ingredient edits, 11-13 per seed on 2026-09-29, and promotion skips them.
- The lightning stage is the template for a group move: `locks.move` for the attractor recipes, unlocks moved between discovery technologies, a transport for the lightning power nodes, and a settler with an addition (`lightning.keep_old`) and a revert (`randomizations/planetary/lightning.lua`, settlers in `execute.lua:800-990`).
- The tech tree rebuild recomputes prerequisites from witnesses and keeps technologies the logic needs for more than unlocks (discoveries) in place (`randomizations/fixes.lua:276-330`), so a moved technology's prerequisites are rebuilt whenever that setting is on.
- The entity handler's autoplace slots exclude resources, cliffs, plants, spawners, worms, fish and entities whose mining triggers a technology (`randomizations/graph/unified/handlers.md`), so those are free for planetary moves.
- The recipe-tech-unlocks handler doesn't run: it's commented out of the enabled handlers under dev-unified (`randomizations/graph/unified/execute.lua:60-95`) and its own setting is hidden and forced off (`settings.lua:214-222`). The tech tree rebuild (on in the preview, `config.lua:76`) strips every unlock-recipe effect, gives each locked recipe its own technology that copies the unit or trigger of the first technology found unlocking it, and takes prerequisites from the recipe's witnesses, never from discovery technologies (`randomizations/fixes.lua:150-215, 342-420`). Under the rebuild a reward's planet tie is its lock plus its trigger.

## 3. Anchors: how planet content enters the logic

| # | anchor | data | logic edge | into OR? | moved today by |
|---|---|---|---|---|---|
| 1 | lock | recipe/entity `surface_conditions` | room --> `*-surface-condition` | yes | `locks.lua` (random), `lightning.lua` (attractors) |
| 2 | unlock | `technology.effects` unlock-recipe | technology --> `recipe-tech-unlock` | yes | `lightning.lua` (between discovery techs) |
| 3 | trigger | `technology.research_trigger` | trigger source --> technology | **no** (AND) | `resources.lua` trigger edits, as a root repair |
| 4 | discovery prerequisite | `technology.prerequisites` | technology --> technology | **no** (AND) | nobody; the rebuild recomputes |
| 5 | autoplace | `planet.map_gen_settings.autoplace_settings` | `room-autoplace` --> entity / tile | yes | `resources.lua` (resource slots), `oceans.lua` (tiles), entity handler (the rest) |
| 6 | spoiling | `item.spoil_ticks`, `spoil_result`, `spoil_to_trigger_result` | item --> item, item --> entity | yes | spoiling handler (unified); no planetary stage |
| 7 | climate | `lightning_properties`, `entities_require_heating` | room --> lightning nodes, room --> warmth | yes | `lightning.lua`, `freezing.lua` (parked) |
| 8 | ingredients | `recipe.ingredients` | item / fluid --> recipe | **no** (AND) | `resources.lua`, `scaffolds.lua` (root repairs); unified |
| 9 | delivery | derived from spoil time | item in one room --> item in another | yes | nobody |

Rules that follow:
- A move that changes only anchors 1, 2, 5, 6, 7 and 9 is repairable by superposition as it stands.
- Anchor 3 becomes repairable with one logic change: a `technology-trigger` OR node between the technology and its trigger sources, one edge per source (which also fixes the mine-entity "first entity only" gap, and only adds routes). Every trigger edit then leaves a debt edge into an OR node, and the addition rung for a mine-entity trigger is "keep the old entity in the list".
- Anchor 4 is never a debt. A move replaces the old family's discovery technology by the new planet's or drops it; it never adds a prerequisite alone, since a new AND input can make the union unreachable where the old world reached it. Other prerequisites stay (a progression tie to the old planet's research is acceptable; the rebuild recomputes them anyway).
- Anchor 8 is never a debt either. Ingredient edits are root repairs in the report's sense: fixes, not content, allowed to use what random choices may not (water, lava, the old fluid's replacement), made only where a goal fails. Moved recipes' goals allow imports, so most moves need none.

## 4. Features: bundles of anchors with one home

Derived from data, never from names. For a family P, S(P) is the set of nodes specific to P in the before sort (`check.node_specific_to`: only there, or every isolatable context there). Three bundle kinds:

**Reward** (a planet gives a building): for each technology T that unlocks a planet-locked recipe or entity R in S(P) that isn't a science pack: the locks of every such R of T, T's trigger if T is in S(P), and T's prerequisite on P's discovery. Recipes of one technology move together. Vanilla examples: big mining drill (lock plus the "craft a foundry" trigger), foundry (lock plus "craft tungsten carbide"), the three turbo belts, acid neutralisation, biochamber, electromagnetic plant, cryogenic plant, quantum processor, fusion reactor and generator, the agricultural tower entity. Lightning rod and collector stay the lightning stage's group.

**Chain** (a processing chain): rooted at a resource or harvestable entity E autoplaced only on P. Members: E's autoplace, the recipes in S(P) that consume E's products (transitively within S(P)), the technologies unlocking those recipes, and the entities or items those technologies' triggers need when they are in S(P). Vanilla examples: lithium brine with lithium and lithium plate, lithium-processing and the icebergs its trigger mines; calcite with calcite-processing and the lava recipes; tungsten ore with tungsten carbide, plate, and the volcanic rocks that trigger tungsten-carbide; holmium ore with the holmium recipes; the Gleba fruit trees with their processing (plants; see the limitation below).

**Theme** (spoiling): the spoiling of every item in S(P) that has a spoil result and no spoil_to_trigger_result (eggs are hazards and stay). Moved to a planet Q by rank matching onto items of S(Q): Q's science pack takes the science pack's time (an hour lasts a trip), and the k other spoilers' times and results go to k items of S(Q) that stack, aren't hidden and aren't already spoil results. Items delivered to other rooms in the before sort only get times that last a trip; times under the trip go only to items whose contexts are all in Q's room. The old items stop spoiling. Spoil results keep their sinks through `lib/item-sinks.lua` (spoilage burns as fuel, so it has a sink wherever burners are).

Everything else specific to P stays: its science pack and whatever only its science pack needs (the user's "each planet crafts its own science"), its discovery technology, its climate.

Targets: each bundle draws, with the feature stage's move chance, a uniform random movable planet other than its home, copies included. The starting planet and the platform keep their memberships (approved 2026-09-26). With copies this splits a family's content among its members by itself; no separate "split" mode is needed.

## 5. Duplicated planets

**Stage.** `randomizations/planetary/dupes.lua`, setting `propertyrandomizer-planet-dupes` (copies per planet, default 0; the user wants 1 for now, 2026-09-29). Every planet is copied that many times, the starting planet included; a copy is never the start. It runs in `data-final-fixes.lua` right before `planetary.execute` (after the prefixes, where the planetary stage already sits), so copies are in the before sort and in both worlds.

**Data.** A deep copy of the planet through `dupe.prototype` (which records `orig_name` and `dupe_number`, the family record), with: `map_seed_offset` set so the terrain differs; `distance`/`orientation` next to the original; the original's starmap icon with the number badge (`dupe.recipe_number_icon`); a copy of each discovery technology of the original with `unlock-space-location` pointing at the copy and the original's prerequisites (a parallel destination; the rebuild may reorder it); a copy of every space connection touching the original with the endpoint substituted (same length and asteroid definitions); procession and ambient catalogues shared; `pollutant_type`, lightning and heating as the original's. Locale through `propertyrandomizer.dupe` as for other dupes.

**Logic.** No change: rooms, space locations, connections, discoverers and home sets are derived from data (section 2). `compat/vanilla.lua:137-150` names planets for the old logic only.

**Families.** `planetary_check.family_of(room_key)` from the dupe records. Every rule that says "one planet" reads "one family": `protection.planet_locked_recipe_contexts` (all pebbles in one family, goals per member), `check.node_only_on` / `node_specific_to` (used by resource edits and bundle derivation), `locks.candidates` (a lock accepting exactly one family isn't "all planets"). Without this, a copy of Vulcanus makes metallurgic science "not locked" and "not specific to Vulcanus", and the resource stage stops following the swap.

**Copies in the existing stages.** Oceans, resources and locks read planets from data, so a copy gets its own tile slots, resource slots and lock memberships, and can end up with a different ocean and different ores than its original with no further work. Lightning and freezing see one more planet with or without them.

**Goals with copies.** Before any move, a copy has every context its original has (same resources), and rule 2 keeps them on both members. That is right for identity (science packs stay makeable on every member) and too strict for features, so a bundle move transports the moved goals from the member they leave to the target, exactly as lock moves do today. The baseline the user should see first: copies on, no moves, MECHCHECK ok, the copy on the starmap with its connections and discoverable.

**Cost.** Each room multiplies contexts, so every sort grows. Expect on the order of 15-20% per extra planet, to be measured against the two-minute rule before the setting goes on by default.

## 6. Moving a bundle

Realization, per anchor kind:
- lock: `locks.move(kind, name, map)`, as lightning does; the realizer (`lib/surface-sets.lua`) gives the exact new set with new properties, copies separated from originals.
- unlock: unchanged when the technology moves with the bundle; when a bundle takes one recipe of a technology that stays, that recipe's unlock moves to the target's discovery technology (lightning's `remove_unlock`/`add_unlock`). Under the tech tree rebuild this only decides whose unit or trigger the rebuilt technology copies, so the trigger is what carries the planet tie into the rebuilt tree.
- trigger: after the `technology-trigger` node exists, a moved technology keeps its trigger when the trigger's item or entity is in the bundle (the foundry for the big mining drill isn't, so that trigger gets a substitute: an item or entity specific to the target, chosen like `resources.trigger_edits` chooses replacements); a mine-entity trigger whose entity moves with the bundle stays as it is.
- discovery prerequisite: P's discovery replaced by Q's; nothing else added (user, 2026-09-29: no other prerequisites). Only matters with the rebuild off, since the rebuild recomputes prerequisites.
- autoplace (chains): the resource takes a same-kind slot on the target (a well for a well, an ore for an ore) with the slot's footprint, through the resource stage's slot machinery; a harvestable takes the target's same-kind harvestable's footprint. First version: chains rooted at wells, ores and rock-like entities. Plants carry `tile_restriction` to their home soils, so plant chains wait until tile restrictions can be rewritten to the target's tiles.
- spoiling (theme): as in section 4; `dutils.survives_trip` is respected by construction.
- root repairs, only when a goal fails: ingredient substitution with `resources.lua`'s `substituted_ingredients` (same kind, furnace-category rule), or a planned "R (Planet)" variant from `scaffolds.lua` when the recipe has a context conflict (must keep working on P with the old ingredients and on Q with new ones).

Goal transport: `check.transport[node] = { map = { P --> Q } }` for the bundle's recipes, entities and technologies, without isolatability (imports allowed on the new planet, as decided for locks). Chains transport their consuming recipes' goals too; science packs never.

Simplest chain realization for the first version: the chain option changes what the resource stage does with a chain-rooted resource. Today Aquilo's lithium recipe is edited to take whatever replaced lithium brine on Aquilo. With the chain option, the recipe isn't edited: its goals follow lithium brine to wherever the swap put it, the lithium-processing technology's prerequisite follows, and the icebergs swap footprints with the target's rock-like harvestable (whose own trigger gets today's trigger edit). So the chain stage is a mode of the resource stage plus two new anchor moves, not a separate randomizer of where resources go.

Debt shape audit (superposed mode): every old anchor edge of a moved bundle ends in an OR node (locks, unlocks, autoplace, spoil sources, deliveries, and triggers once the trigger node exists). Prerequisite replacements and ingredient repairs are the only AND-side changes, and both are fixes by construction, as today. `run_superposed` logs "debt edge into a node that isn't an OR node" for each exception, which is the acceptance check for this section.

## 7. Settlers

One settler per bundle kind, added to `settlers` in `execute.lua`, owning debt edges by shape. Rungs, cheapest first:
- reward: (repair) substitute one more P-specific ingredient of the moved recipe with a Q-specific product; (duplicate) an "R (Q)" variant on Q while the original goes back to P; (addition) the lock accepts P again, the trigger lists the old entity as well; (revert) the bundle back to P.
- chain: (addition) extra patches of the resource on P (`resources.repair`, already the resource settler's fix), or the harvestable autoplaced on P as well; (revert) the chain back.
- theme: (repair) the item's spoil time lengthened to the trip for an owed delivery edge; (addition) the old item spoils again as well, for an owed spoil-source edge; (revert) the theme back.

Reverts undo the whole bundle, as the lightning settler does, and share the "several debt edges, one fix" bookkeeping.

## 8. Order of work, each step testable

A. **Trigger OR node** in `lib/logic/concrete.lua` (tech AND --> `technology-trigger` OR --> one edge per trigger source, every mine-entity entity). Tests: MECHCHECK on seeds 1-3, base and Space Age, no new losses; PLANETCHECK counts unchanged; a plain-Lua test of the node shape if the stub graph allows.
B. **Families and planet copies**: the dupes stage, `family_of`, the family-aware rules in protection, check, locks and resources. Tests: copies on with no planetary stage (MECHCHECK ok, copy discoverable and on the starmap in a real load); copies with oceans, resources and locks in superposed mode (settlement paid, PLANETCHECK final 0).
C. **Bundle derivation and dry run**: a PLANETFEATURES log listing each family's bundles, their anchors and the targets drawn, with no edits. This is where the user settles which things count as features, against real data rather than the vanilla examples above.
D. **Reward bundles**: realization, transport, settler; normal mode (careful run, own check, undo) and superposed mode; seeds 1-3 both games.
E. **Chain bundles**: wells and ores through the resource stage's chain option, then rock-like harvestables; plants excluded.
F. **Theme bundle**: after the spoiling handler lands in the main tree (another session owns it); the theme stage sets the spoilers before unified, and the handler keeps vanilla spoilers spoiling, so the theme survives it.
G. **Presentation**: a description line "Moved from [planet=vulcanus]" on moved recipes and technologies (the lock stage's `propertyrandomizer.planet_lock` line is the model), copies' names and badges, panel lines for what moved.
H. **Measurement**: load time with one and two copies on a quiet machine; per-seed counts of leftovers, rungs used and reverts.

Dependencies and risks:
- `PROTECT_TRANSPORTED` in `execute.lua` is off and not root-caused (recycling recipes of moved locks' items became unreachable under it). Feature goals are protected through promotion's owed goals in superposed mode only; in normal mode PLANETCHECK final just logs. Root-causing it is worth doing before rewards go on by default.
- Unified's recipe-tech-unlocks handler is off and the rebuild makes it moot (section 2), so a moved reward's unlock isn't re-randomized; the rebuilt technology keeps the trigger the move gave it.
- Mods that reference vanilla planets by name won't know the copies; the copies only carry what data derives.

## 9. Decisions for the user

Rewards go first (user, 2026-09-29); chains and the theme need more defining. The user plans to copy science packs so each copy keeps its own, and duplicated buildings like the foundry can take per-copy locks; families stay for shared locks.

1. Target rule: uniform random target per bundle, copies included (recommended), or moves only within a family first?
2. Resolved 2026-09-29 (user): a moved reward's technology keeps only the target's discovery, no other home-specific prerequisites.
3. Movable bundles: every locked recipe and entity except science packs, chains rooted at wells, ores and rock-like harvestables, and the spoiling theme; plants, lightning and freezing not now. Anything to add or hold back?
4. Resolved 2026-09-29 (user): one copy of each planet for now (changed from two copies in all, for load time); their discovery technologies parallel to the original's with no other prerequisites.
5. Resolved 2026-09-29: no unlock pin is needed, the tech-unlock handler is off and the rebuild copies the moved trigger (section 2).
6. The spoiling theme's shape: rank-matched times onto the target's chain items with the delivery rule above, or a smaller version that only moves which planet's science pack spoils.

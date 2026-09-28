# Glossary (working vocabulary)

New terms from ongoing design work on unified randomization. Established terms (*pebble*, *context*, *emitter*, *forgetter*, *transmitter*, *prereq shuffle*, *first pass*, etc.) are defined in the [wiki glossary](https://github.com/exfret/propertyrandomizer/wiki/Glossary); terms here may graduate there once they settle.

**Acquisition edge / acquisition kind:** A logic edge for one way an entity comes to exist (built from an item, autoplaced, spawned by a spawner, hatched from a spoiling item, ...), tagged with its kind as `acq_kind`. These are the slots entity randomization moves entities between. Kinds and the tagging helper are in `lib/logic/acquisition.lua`.

**Anchor context:** The one context a recipe with no promised pebbles is required in, chosen just before its ingredients are randomized: the earliest context where it's currently *established* with its vanilla ingredients. All its new ingredients must be established there, and the recipe is then promised there, which keeps every originally reachable recipe reachable.

**Backing:** The set of earlier *pebbles* that justify a *promised* pebble. A recipe pebble `(r, c)` is backed by every ingredient pebble `(i, c)`; an item/fluid pebble is backed by one producer pebble. A backing is only valid if every pebble in it is *earlier* in the *sort* and itself backed (see *well-founded*).

**Carrier:** A unit that entity randomization puts in a spawner's slot in place of the unit it spawned, or in an egg's spoil slot in place of the unit it hatched, looking like a built entity, and dropping a new item that places that entity when killed (loot). It keeps the slot's unit's size, stats and behavior, and picking up loot can't be automated (see *connection abilities*). Eggs hatch carriers even with enemies turned off (`ignore_no_enemies_mode`), since logic counts on their loot. In the model, a carried entity connects to its slot's *carrier base*, a spoofed base fed by an AND of the slot's source (the spawner's spawn node or the egg) and the unit's resistance group, so it's only carried where killing the carrier comes before the entity is needed (logic doesn't count the starting pistol, since only the freeplay scenario gives it, so on Nauvis that's after a turret or gun is researched).

**Connection abilities:** The abilities (what a path gains or loses, like automatability) on the edge that connects a *base* to a *head*. A vanilla pair keeps the abilities of the edge it was cut from, and a new pair gets whatever the head's handler says (`connection_abilities`). For entity randomization that's the *pairing table* in `lib/logic/acquisition.lua`: getting a built entity from a slot that gives the entity itself (by salvaging or looting it) can't be automated. Promotion reasons with them, so a base is only accepted where its connection gets the head's required contexts through.

**Debt:** A *pending constraint* with no known *fallback bundle*. Arises when the sort is not a sort of the vanilla graph (e.g. *multipass*), so vanilla ingredients can't be assumed to satisfy it. Currently out of scope.

**Demand tier:** How many of an entity a base needs: *bulk* (hundreds: belts, inserters, pipes, poles and other classes in acquisition.bulk_entity_types, or anything whose item stacks to 100 or more), *few* (whose item stacks to 5 or less) or *some*. Entity randomization only gives an entity slots that can supply that many (acquisition.can_supply).

**Discovery rule:** How a tech gets isolatable contexts in a room other than the one it's researched with. Research is global, so once a room is discovered, a tech that can be had using only the room's *home set* counts as isolatable there. The rule is order-independent through *home contexts*. Without them, `lib/graph/context-sort.lua` falls back to the old rule: techs reached before the room's discoverer in that sort count. The rule lives in `top.discovery_candidates` for code that reasons about *backings*.

**Earliest-provider rule:** When tracing a *witness* or *backing* backward through an OR node, choose the provider whose pebble comes first in the sort. Guarantees every step goes strictly earlier (no loops) and tends to produce small witnesses. Implemented by `path` in `lib/graph/consistent-sort.lua`.

**Established:** A pebble that has a *backing* in the current random graph, where resolved recipes use their new ingredients, unresolved recipes use their vanilla ingredients, and generic handlers' heads use their chosen bases. Promised pebbles are established by construction. Implemented as `establish` in `randomizations/graph/unified/skeleton/promotion.lua`.

**Fallback bundle:** An ingredient list known to satisfy all of a recipe's *pending constraints*. When the sort is a random sort of the vanilla graph, the recipe's vanilla ingredients are always a fallback bundle, which is what makes *promotion* safe and guarantees completion.

**Group supply:** A mechanic per bulk entity class, only with entity randomization on (lib/logic/entity-supply.lua): some member of the class can be gotten to build, with automatability kept wherever vanilla had it. It lets single members become farm-only without the class ever being.

**Home context / home set:** A room's *home set* is the rooms its discoverers can't be reached without (Nauvis and space platforms for Vulcanus). It's computed once from the vanilla graph (`top.home_sets`) and kept fixed. A pebble's *home context* for a home set (written like `planet: vulcanus | 00 @ home1`) means it can be had using only those rooms: what removing every other room and sorting again would give, tracked within the same sort (`extra.home_contexts`). Home contexts only matter as backings for the *discovery rule*, so they aren't *mechanic contexts* of their own.

**Mechanic context:** A *pebble* for a mechanic node whose context must be preserved by randomization (e.g. being able to operate a certain entity on a certain planet). Mechanic contexts are *promised* from the start.

**Ours (entity-own):** Logic's node for an entity being ours to operate, as opposed to just present (the entity node). Building it, capturing it, playing as it, or creating it with a capsule or ammo makes an entity ours; finding it in the wild (autoplaced for a force other than the player's) or having an enemy spawn it doesn't. entity-operate needs entity-own, so a machine found in the wild isn't counted as usable where it stands. Acquisition edges into entity-own are tagged `ours`, and entity randomization only gives an entity that has to be ours a slot that makes it ours (the *pairing table*).

**Pending constraint:** The requirement placed on a not-yet-randomized recipe when one of its pebbles `(r, c)` is *promised*: its eventual ingredients must be promised in `c` and earlier than `(r, c)`.

**Promise / promised pebble:** A pebble the final randomized graph is required to reach. The promised set starts as the *skeleton* and grows through *promotion*. Promises are reference counted so ones nothing depends on anymore can be released.

**Promotion:** Adding a not-yet-promised pebble (typically an item/fluid a randomized recipe wants as an ingredient) to the promised set by finding a *backing* for it that lies entirely before the position that needs it. Lets candidates come from outside the skeleton without losing correctness.

**Rank:** A pebble's position in the sort. "Earlier" always means lower rank.

**Salvage:** Getting a built entity by finding it in the wild and mining it for an item that places it, when entity randomization moves the entity into another entity's autoplace slot. It's finite and manual, so the connection can't be automated (see *connection abilities*). A built entity made by a *trigger slot* is mined for a salvage item the same way.

**Skeleton:** The union of the *witnesses* for all *mechanic contexts*; the initial promised set. Only skeleton (and later promoted) pebbles impose ordering constraints on randomization, instead of every node in every context.

**Sort:** Here, a randomized contextual topological sort of the vanilla graph (e.g. `sort` in `lib/graph/consistent-sort.lua`), used to assign *ranks*.

**Spawn class:** When a unit spawner spawns something, from its spawn points: *persistent* (at every evolution), *transient* (from evolution 0 but not always, like small biters), or *late* (not at evolution 0, like big biters). Logic never counts on late spawns, since evolution can be turned off.

**Spoof placer:** An item that places nothing in vanilla (a plain item, module, ammo or science pack) that entity randomization made place an entity, on top of everything it already does. Never a capsule or anything else used by clicking, since placing would take over the click (players can bind using capsules to left click). It keeps its own name and look, with the entity's item icon as a badge in its icon's top left corner, and its description says what it places. In logic, each such item has a build edge to a spoofed `entity-build-item` node, which is where its base comes from.

**Survives a trip / trip line:** Whether an item lasts long enough to be sent to another room: it doesn't spoil, or it spoils after at least `constants.spoil_trip_ticks` (30 minutes, a safe buffer for modded space connections; vanilla trips are often under 5). Logic only gives items that survive a trip an item-deliver node, so an item that spoils sooner is only in rooms that can make it. It's one-way: no randomization may make an item that survived a trip stop surviving (numerical spoil time randomization rerolls), but lengthening a spoil time so something can be delivered is fine, since it only adds routes. The shared helper is `dutils.survives_trip`.

**Trigger slot:** A slot where using an item (throwing a capsule, firing ammo) or capturing a spawner makes an entity for us, like the combat robot capsules, the capture robot rocket, and spawners turning into the captive biter spawner. Entity randomization moves what they make among them (rewriting the item's create-entity effects on renamed copies of what it sends, like its projectile, or the spawner's `captured_spawner_entity`), and can have one make a built entity instead, which is ours where it's made and is mined for a *salvage* item. A slot nothing took keeps making what it did.

**Wreck:** A rock-like simple entity that looks like a darkened built entity, which entity randomization has a dying enemy leave behind in place of what it left in vanilla (a *dying slot*, like a stomper's shell), mined for a *salvage* item that places the entity. It's a simple entity rather than the entity itself because an enemy's dying trigger makes entities for the enemy's force, while a simple entity is always neutral.

**Effect capsule:** A capsule thrown for an effect: its use is aimed at a spot (its attack has a range), where it does something other than make an entity with health (a grenade exploding, a poison cloud, cliff explosives). Entity randomization can have one make an entity instead (a *maker base*), and moves effects between these capsules, *Vestiges* and combat robot capsules. See the entity handler in randomizations/graph/unified/handlers.md.

**Entity position:** With `constants.entity_first_pass` (off for now), a way an entity is acquired, as first pass sees it: one claimed acquisition edge (an item placing it, a spot in the wild, a spawner's slot, a trigger, an egg, a death), or an item or capsule that makes nothing in vanilla, or a *nowhere position*. The entity acquired there in vanilla is its identity. First pass matches identities to positions like item identities to item positions, by entity randomization's rules, so a building can land in a spot in the wild (salvage) or a spawner's slot (a *carrier*). See "Entity positions" in randomizations/graph/unified/handlers.md.

**Nowhere position:** With `constants.entity_first_pass`, an *entity position* nothing reaches, where an identity stops being acquired (detached), like an entity no longer found in the wild. Its vanilla identity is nothing. Units' placing slots are nowhere positions too, since no item places a unit in vanilla, so their identity moves only when first pass gives it an item (a friendly biter).

**Vestige:** An item that placed an entity in vanilla but places nothing after entity randomization, because its entity went to another item, and the chain of items taking each other's entities ended at a *spoof placer* or at an entity gotten another way (salvaged, carried, made by a trigger slot, or left as a wreck). When that chain ends at an *effect capsule* making an entity instead, the Vestige sets off the capsule's effect where it's placed. It stays an ingredient wherever it was one, and looks like a darkened copy of the own item of the entity at the chain's end, named "<entity> (Vestige)", with a description saying where that entity comes from now.

**Well-founded:** The correctness condition for promises: every promised pebble has a backing of promised pebbles with strictly lower rank. Induction on rank then shows every promised pebble, including every mechanic context, is reachable in the final graph.

**Witness:** A backward derivation of a pebble through the graph (all prereqs for AND, one provider for OR via the *earliest-provider rule*, one shared context for *forgetters*), showing how it is reached.

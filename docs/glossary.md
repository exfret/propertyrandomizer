# Glossary (working vocabulary)

New terms from ongoing design work on unified randomization. Established terms (*pebble*, *context*, *emitter*, *forgetter*, *transmitter*, *prereq shuffle*, *first pass*, etc.) are defined in the [wiki glossary](https://github.com/exfret/propertyrandomizer/wiki/Glossary); terms here may graduate there once they settle.

**Acquisition edge / acquisition kind:** A logic edge for one way an entity comes to exist (built from an item, autoplaced, spawned by a spawner, hatched from a spoiling item, ...), tagged with its kind as `acq_kind`. These are the slots entity randomization moves entities between. Kinds and the tagging helper are in `lib/logic/acquisition.lua`.

**Anchor context:** The one context a recipe with no promised pebbles is required in, chosen just before its ingredients are randomized: the earliest context where it's currently *established* with its vanilla ingredients. All its new ingredients must be established there, and the recipe is then promised there, which keeps every originally reachable recipe reachable.

**Backing:** The set of earlier *pebbles* that justify a *promised* pebble. A recipe pebble `(r, c)` is backed by every ingredient pebble `(i, c)`; an item/fluid pebble is backed by one producer pebble. A backing is only valid if every pebble in it is *earlier* in the *sort* and itself backed (see *well-founded*).

**Carrier:** A unit that entity randomization puts in a spawner's slot in place of the unit it spawned, looking like a built entity, and dropping a new item that places that entity when killed (loot). It keeps the slot's unit's size, stats and behavior, and picking up loot can't be automated (see *connection abilities*).

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

**Ours (entity-own):** Logic's node for an entity being ours to operate, as opposed to just present (the entity node). Building it, capturing it, playing as it, or creating it with a capsule or ammo makes an entity ours; finding it in the wild (autoplaced for a force other than the player's) or having an enemy spawn it doesn't. entity-operate needs entity-own, so a machine found in the wild isn't counted as usable where it stands.

**Pending constraint:** The requirement placed on a not-yet-randomized recipe when one of its pebbles `(r, c)` is *promised*: its eventual ingredients must be promised in `c` and earlier than `(r, c)`.

**Promise / promised pebble:** A pebble the final randomized graph is required to reach. The promised set starts as the *skeleton* and grows through *promotion*. Promises are reference counted so ones nothing depends on anymore can be released.

**Promotion:** Adding a not-yet-promised pebble (typically an item/fluid a randomized recipe wants as an ingredient) to the promised set by finding a *backing* for it that lies entirely before the position that needs it. Lets candidates come from outside the skeleton without losing correctness.

**Rank:** A pebble's position in the sort. "Earlier" always means lower rank.

**Salvage:** Getting a built entity by finding it in the wild and mining it for an item that places it, when entity randomization moves the entity into another entity's autoplace slot. It's finite and manual, so the connection can't be automated (see *connection abilities*).

**Skeleton:** The union of the *witnesses* for all *mechanic contexts*; the initial promised set. Only skeleton (and later promoted) pebbles impose ordering constraints on randomization, instead of every node in every context.

**Sort:** Here, a randomized contextual topological sort of the vanilla graph (e.g. `sort` in `lib/graph/consistent-sort.lua`), used to assign *ranks*.

**Spawn class:** When a unit spawner spawns something, from its spawn points: *persistent* (at every evolution), *transient* (from evolution 0 but not always, like small biters), or *late* (not at evolution 0, like big biters). Logic never counts on late spawns, since evolution can be turned off.

**Spoof placer:** An item that places nothing in vanilla (a plain item, module, ammo or science pack) that entity randomization made place an entity, on top of everything it already does. It keeps its own name and look, with the entity's item icon as a badge in its icon's top left corner, and its description says what it places. In logic, each such item has a build edge to a spoofed `entity-build-item` node, which is where its base comes from.

**Vestige:** An item that placed an entity in vanilla but places nothing after entity randomization, because its entity went to another item, and the chain of items taking each other's entities ended at a *spoof placer*. It stays an ingredient wherever it was one, and looks like a darkened copy of the item whose entity the spoof placer took, named "<entity> (Vestige)", with a description pointing to the spoof placer.

**Well-founded:** The correctness condition for promises: every promised pebble has a backing of promised pebbles with strictly lower rank. Induction on rank then shows every promised pebble, including every mechanic context, is reachable in the final graph.

**Witness:** A backward derivation of a pebble through the graph (all prereqs for AND, one provider for OR via the *earliest-provider rule*, one shared context for *forgetters*), showing how it is reached.

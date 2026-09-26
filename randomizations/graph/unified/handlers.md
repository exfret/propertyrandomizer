A list of handlers and info about them.

Make sure when adding a handler to also do the following:
1. Add an entry for it here
2. Add it to the list helper-tables/handler-ids
3. Add a setting for it

# entity

Not ready for release

Changes how entities are acquired (see lib/logic/acquisition.lua). So far build slots (which item places which entity) and autoplace slots (which entity map generation puts where), matched one to one: a random matching of admissible bases, committed through promotion's try_rewires a cycle or chain of slots at a time.

Pairings between slot kinds follow `acquisition.pairing` (lib/logic/acquisition.lua), which also gives each connection's abilities (`entity.connection_abilities`, see "Connection abilities" in docs/glossary.md).

Autoplace slots: autoplaced entities found in exactly one room (except resources, cliffs, plants, spawners, worms, fish, and ones mining which unlocks a technology) trade slots, taking the whole autoplace spec of the entity they replace and its place in the planet's map generation settings. An autoplaced entity nothing promised needs can stop being autoplaced (its head is detached). Built entities can instead take an autoplace slot and be salvaged: found in the wild for the neutral force, which can't be used there, and mined for a new item that places them (only entities with one placer, not needed in bulk, that fit where the slot's entity was). Logic's entity-own node keeps this honest: only what's ours can be operated (see docs/glossary.md).

Spawn slots (only with the biters setting, propertyrandomizer-unified-entity-biters): what a unit spawner spawns. Units trade spawn slots (a traveler keeps the slot's spawn points), a built entity can instead be carried by biters (a carrier: the slot's unit with the entity's look, dropping a new item that places it as loot), and a unit can also be placed by an item (a friendly biter). Units' placing slots are spoofed edges whose heads start detached (starts_detached, see promotion.new), so logic never counts on friendly biters: the pool graph and promotion don't connect them, and first pass gets its graphs with them cut (gutils.detach_starting_heads). Moving a slot never drops what else mining the entity gave, like a plant's fruit (common.swap_mining_items), since logic keeps those edges. A slot whose unit stopped spawning at some evolution (transient) keeps spawning its new unit at every evolution, at no less than a tenth of its highest weight; late slots are gated by enemy-evolution, so only travelers nothing needs end up there.

Balance (step 6): each built entity has a demand tier (acquisition.demand_tier: bulk for the classes in acquisition.bulk_entity_types or an item stacking to 100 or more, few for one stacking to 5 or less, some otherwise). Bulk entities are never salvaged, but can be carried by biters, since with entity randomization on, logic has a group-supply mechanic per bulk class (lib/logic/entity-supply.lua) that keeps some member of the class suppliable automatically wherever vanilla had one. Carriers keep their unit's health, only carry items worth killing them for, and drop more of cheap and bulk items (acquisition.loot_amount). Salvage is never worth more than 25 times what mining the slot's entity gave (acquisition.worth_salvaging); a pairing over that is refused, not scaled down. Items without a known cost are never carried or salvaged, since neither can be balanced without it. Each seed logs FARMREPORT lines: what's only gotten by hand, from where, and for bulk classes with such members, which members items still place.

Items that place nothing in vanilla (plain items, modules, ammo, science packs, and other item types that aren't used by clicking) can also take a build slot, as spoof placers: they keep their look, with a badge of the entity's icon. Every item still places at most one entity, so the chain of items taking each other's entities that ends at a spoof placer starts at an item that now places nothing (a Vestige, darkened and pointing to the spoof placer). See docs/glossary.md.

With first pass and item randomization: which entity an item places belongs to the item's identity, so build edges are tagged identity_base (first pass moves them with the trav), and first pass doesn't split build slots (they're on its blacklist). It reflects before item randomization, which copies item names and icons into recipes.

# entity-operation-fluid

Not ready for release

# mining-fluid-required

# recipe-category

Not ready for release

# recipe-ingredients

Not ready for release

# recipe-tech-unlocks

# spoiling

Assumes vanilla space age, has manual blacklist for iron bacteria and copper bacteria.

# starting-planet

Not ready for release

# tech-prereqs

# tech-science-packs
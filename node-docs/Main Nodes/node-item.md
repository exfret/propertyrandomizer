---
description: Access to hold a given item in a player-owned inventory.
type: OR
---
One node for each item prototype. Notabely, these are surface-agnostic, so it's assumed that being able to get items on one surface allows you access to them on another.

Prereqs
- A [[node-craft-material]] for this item
- A [[node-mine-entity]] for an entity that results in this item when mined
- A [[node-mine-tile]] for a tile that results in this item when mined
- A [[node-loot-entity]] for an entity that has this item as loot
- A [[node-item]] for an item that spoils into this item
- A [[node-burn-item]] for an item with this as a burnt fuel result
- A [[node-send-item-to-orbit]] for an item with this as a rocket launch product
- A [[node-equipment]] that has this as a take_result
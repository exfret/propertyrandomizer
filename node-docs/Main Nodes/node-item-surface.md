---
description: Access to a given item on a given surface.
type: OR
---
There is one of these per item-surface combo.

Prereqs:
- A [[node-craft-material-surface]] that corresponds to crafting this item on this surface
- A [[node-mine-entity-surface]] for an entity on this surface that results in this item when mined
- A [[node-mine-tile-surface]]  for a tile on this surface that results in this item when mined
- A [[node-mine-asteroid-chunk-surface]] for an asteroid chunk that results in this item when mined
- A [[node-loot-entity-surface]] for an entity on this surface that has this item as loot
- A [[node-item-surface]] for an item on this surface that spoils into this item
- A [[node-burn-item-surface]] for an item on this surface with this as a burnt fuel result
- A [[node-send-item-to-orbit-planet]] for an item with this as a rocket launch product, if this surface is a planet
- A [[node-equipment]] with this as a take_result
- This item/surface's [[node-transport-item-to-surface]]
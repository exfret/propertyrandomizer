---
description: Access to a certain entity on a certain surface, either via building it or it naturally spawning (or even some other means).
type: OR
tags:
  - entity
---
There is one of these per entity-surface combination. Notably, this does not directly require the surface, but all its prerequisites should have a requirement for the surface one way or another.

Prereqs:
- The [[node-build-entity-surface]] for this entity-surface combination
- Any [[node-plant-entity-surface]] for this enitity-surface combination
- The corresponding [[node-surface]] if it has an autoplace for this entity, or for space locations for which this is an asteroid chunk or asteroid
- A [[node-capture-spawner-surface]] for an enemy spawner resulting in this entity when captured
- A [[node-capsule-surface]] for a capsule creating this entity (such as how destroyer robots are made)
- (Not coded) If this is a corpse, a corresponding [[node-loot-entity]] for an entity having this as its corpse (this is probably not necessary, but mentioned anyways)
- Entities can also be created by cargo pods, but this is something that can likely be ignored
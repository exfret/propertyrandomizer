---
description: Access to building this entity on a given surface.
type: AND
tags:
  - entity
---
One node for each buildable entity-surface combination such that the surface's conditions allow the entity to be placed.

Prereqs:
- The [[node-entity-buildability-surface]] for this entity-surface combination
- The [[node-build-entity-item]] for this entity combination
- The [[node-surface]] itself (this might be redundant with the enitity-buildability-surface requirement, but better safe than sorry)
- If this entity requires rails to place (such as a locomotive), the [[node-spawn-rail-surface]] for this surface
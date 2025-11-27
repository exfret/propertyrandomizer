---
description: Access to mining an entity on a certain surface.
type: AND
tags:
  - entity
---
One node for each mineable entity and surface combination, also including asteroid chunks.

Prereqs:
- The [[node-spawn-entity-surface]] for this entity-surface combination
- If this requires fluid, the [[node-fluid-surface]] that this requires
- If this requires fluid, the [[node-mining-with-fluid-unlock]]
- The [[node-resource-category-surface]] for this entity if it's a resource
- The [[node-asteroid-collection-surface]] for this surface if this is an asteroid chunk
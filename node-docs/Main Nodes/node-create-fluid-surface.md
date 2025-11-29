---
description: Access to creation of a given fluid on a given surface. This is separate from the fluid node itself due to the additional need to have a way of storing/transporting the fluid.
type: OR
---
One node for each fluid-surface combination.

Prereqs:
- The [[node-craft-material-surface]] for this fluid-surface combination
- All [[node-create-fluid-offshore-surface]] giving this fluid
- Any [[node-operate-entity-surface]] corresponding to a boiler for this entity
- Any [[node-mine-entity-surface]] for a resource entity on this surface with this as a mining result
- The [[node-operate-entity-surface]] for some fusion reactor on this surface producing this fluid
- The [[node-operate-entity-surface]] for a fusion generator on this surface
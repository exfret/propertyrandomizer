---
description: Access to satisfiability of a particular energy source's power requirements on a certain surface.
type: OR
---
One node for each node-operate-entity-surface with non-void energy source.

Prereqs
- If applicable, the [[node-electricity-surface]]
- If applicable, the [[node-fuel-category]] for this entity
- Either the specific [[node-fluid-surface]] specified by the energy source's fluid box, or if no filter is set, just every [[node-fluid-surface]] with fuel value
- If applicable, the [[node-heat-surface]]
- If applicable, the [[node-void-energy]]
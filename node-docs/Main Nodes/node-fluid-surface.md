---
description: Access to the creation of a fluid, and ability to store it, on a given surface.
type: AND
---
One node for each fluid-surface combination. Fluids may be additionally split up based on temperature requirements, because otherwise tracking temperature without discrete nodes would be a pain.

Prereqs:
- The [[node-create-fluid-surface]] for this fluid
- The [[node-hold-fluid-surface]] for this fluid
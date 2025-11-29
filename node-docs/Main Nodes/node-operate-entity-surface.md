---
description: Access to the ability to operate an entity on a given surface, including the ability to power it among other things.
type: AND
tags:
  - entity
---
One for each entity that can be "operated" in some way, and each surface.

Prereqs
- This entity's [[node-energy-source-surface]], if it's a powered building
- The [[node-spawn-entity-surface]] for this entity-surface combination
- The [[node-operate-entity-surface-fluid]] for this entity, if applicable, which includes:
	- The fluid for powering steam engines
	- The fluid for boilers (which may need to be separated out for boilers that don't have a filter if that's possible)
	- The input fluid for fusion generators
	- The input fluid for fusion reactors
- The [[node-heat-surface]] for this surface if there are aquilo-like freezing effects and this is not an entity immune to them
	- Immune entities include burner entities and heat-producing entities, according to the wiki
- The [[node-entity-operation-items]] if this is something like a PyAL building that additionally needs some certain type of item to operate
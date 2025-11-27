---
description: Access to creation of a certain damage-dealing effect with gun and ammo/fluid on a certain surface.
type: AND
---
Since the damage can differ based off the source due to damage bonuses, there is one of these for each source and for each projectile/other effect shootable by that gun, so for example gun and piercing magazine together make up one node.

Prereqs:
- A [[node-item]] that is ammo creating this projectile, or the [[node-fluid-surface]] needed for making the flame that deals damage (for example, if this is a flamethrower turret)
- Either a [[node-gun-surface]] that is a gun capable of shooting the said ammo, or a [[node-operate-entity-surface]] for a turret capable of shooting this
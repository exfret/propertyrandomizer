---
description: Access to crafting a certain recipe on a certain surface.
type: AND
---
One node for each recipe-surface combination.

Prereqs
- All [[node-item-surface]]'s for items on this surface that are ingredients of this recipe
- All [[node-fluid-surface]]'s for fluids on this surface that are ingredients of this recipe
- A [[node-recipe-category-surface]] or, if there are fluids involved or other crafting constraints such as limited ingredients, the corresponding version of the recipe category with these constraints
- The [[node-recipe-tech-unlock]] for this recipe, if applicable
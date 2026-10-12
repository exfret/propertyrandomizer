# Multi-result Givens POC v2

## Changes from the previous reachability-primed version

- **Three** Givens mixing rounds instead of two, with 25–65° rotations.
- Pairing is biased toward recipes with dissimilar pre-randomization raw-resource profiles.
- Ingredient selection has a strong **anti-hub** penalty plus a local raw-resource-diversity penalty.
- Same original reachability rank is allowed, so local cycles can form.
- Every original result is retained. Originally single-result recipes may gain up to two **same-rank local byproducts**, capped to 10% of the original result's pre-randomization value.
- After generation, the script performs a hypergraph-style reachability repair. It repeatedly picks the earliest unreachable material and rewrites one producer to use only already-reachable, strictly earlier ingredients. This needed **18 repairs** and restored all **195/195** originally reachable materials.

### Result counts

- 1 result: **133** recipes
- 2 results: **63** recipes
- 3 results: **6** recipes

The transformed material-dependency graph contains **13 cyclic SCCs**; the largest have sizes `11, 8, 7, 7, 7, 5, 3, 2, 2, 2`. These are allowed because the post-pass reachability repair guarantees enough bootstrap structure for the exported production graph.

## Why the strict priming looked more iron-heavy

- `item: iron-plate` occurs as an ingredient in **42** original recipes, **54** strict-primed recipes, and **13** v2 recipes.
- `item: steel-plate` occurs as an ingredient in **60** original recipes, **78** strict-primed recipes, and **28** v2 recipes.
- `item: electronic-circuit` occurs as an ingredient in **46** original recipes, **48** strict-primed recipes, and **23** v2 recipes.
- `item: iron-gear-wheel` occurs as an ingredient in **42** original recipes, **48** strict-primed recipes, and **18** v2 recipes.
- `item: copper-plate` occurs as an ingredient in **17** original recipes, **23** strict-primed recipes, and **14** v2 recipes.

The strict `< output-rank` filter makes the candidate pool disproportionately consist of early vanilla intermediates, especially the iron/steel/circuit backbone. V2 still uses topology, but permits same-rank ingredients and explicitly penalizes globally overused ingredient nodes.

## Offline raw-resource cost check

For analysis only, I solved the resulting production LP after each transformation. This is **not** required by the proposed runtime/randomizer algorithm; it is just an oracle for checking what the generated graph actually did. Percentages below are shares of the acquisition-cost contribution from the six mined/pumped raw sources, excluding crafting/time overhead and water.

| System | Target | Iron | Copper | Coal | Stone | Uranium | Crude oil | Largest share | HHI |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Original | Production science | 55.5% | 20.3% | 3.5% | 12.3% | 0.0% | 8.3% | 55.5% | 0.373 |
| Original | Utility science | 33.7% | 50.4% | 3.9% | -0.0% | 0.0% | 12.1% | 50.4% | 0.383 |
| Unprimed 2-round POC | Production science | 0.0% | 4.3% | 0.3% | 24.8% | 32.6% | 38.0% | 38.0% | 0.314 |
| Unprimed 2-round POC | Utility science | 0.0% | 4.8% | 0.1% | 14.2% | 27.3% | 53.6% | 53.6% | 0.384 |
| Strict-primed 2-round POC | Production science | 29.4% | 17.0% | 1.1% | 35.5% | 0.0% | 17.0% | 35.5% | 0.271 |
| Strict-primed 2-round POC | Utility science | 19.1% | 18.6% | 1.2% | 24.5% | 0.0% | 36.6% | 36.6% | 0.266 |
| Multi-result v2 | Production science | 13.0% | 2.5% | 15.2% | 37.5% | 0.0% | 31.8% | 37.5% | 0.282 |
| Multi-result v2 | Utility science | 13.1% | 4.6% | 18.0% | 30.8% | 0.0% | 33.5% | 33.5% | 0.259 |

### Interpretation

V2 does what we wanted to the **iron hub**: iron plate usage as a direct ingredient falls dramatically, and iron is no longer the dominant raw source in either test target. The resource mix is also less concentrated than vanilla by the maximum-share metric.

It does **not** magically become perfectly uniform. In this seed, the imbalance moves toward **stone and crude oil**, while copper becomes unusually light. That is useful evidence: node-level anti-hub pressure is effective, but pre-randomization resource-vector balancing is only a heuristic for the post-randomization economy. The next iteration should probably maintain a coarse global resource-pressure budget during support selection, but not try to preserve any specific original vector.

The multi-result addition is intentionally conservative. Extra products are local in the sense that they must have the same original reachability rank as the recipe's original output, and their total pre-randomization value is capped. This allows local loops/byproduct webs without turning every recipe into a global coproduct generator.

## Fractional amounts

No integerization was applied in this version, per the request. A later repair can treat the selected support as fixed and solve a tiny integer/rational approximation problem for ingredient amounts and result multipliers/probabilities.

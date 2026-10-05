# Overrides

Overrides provide an extra level of customization, at the cost of a higher complexity to input. Here, I do my best to document how to input the override settings.

**Important:** The tooltip values are not corrected after any overrides that modify prototype properties. I may fix this in the future, but keep it in mind that any overrides you set that change the property values could lead to incorrect tooltip info for that specific property, as it is still reporting based on the original non-overrided value.

## Basic Form

Overrides are separated by semicolons, with no spaces. At their most basic, an override simply turns a specific randomization on or off (overriding what any previous settings do, hence the name). To turn a randomization on, simply type it in (remembering to separate different overrides with semicolons). To turn it off, preface it with an exclamation mark. The names of all randomizations can be found under `helper-tables/spec.lua`. For example, if you turned off logistics randomization, but still wanted specifically belt speeds randomized, and were fine with production randomization except for assembling machine crafting speeds being randomized, you could use the following override:

`belt_speed;!crafting_machine_speed`

New instructions are all of the form `INSTR:PARAMS`, where `INSTR` is an "instruction" to the randomizer about what to do differently. Right now, there are the following allowed instructions:

1. `ON:PARAMS` where `PARAMS` is a randomization to do. This just does the same thing as typing in the randomization on its own, just in the more complex instruction form.
2. `OFF:PARAMS` where `PARAMS` is a randomization to *not* do. This is just the same as typing `!PARAMS`.
3. `RESET:PARAMS` where `PARAMS` is a prototype property (see section below on prototype properties). This resets the prototype property to its original (pre-randomization) value after the randomization process.
4. `SET:PARAMS` where `PARAMS` is a set statement for a prototype property (see section below on expressions). This sets a prototype property to a specific value.
5. `PARAM:TARGET.PARAMETER=VALUE` changes numerical or supported unified graph tuning before randomization. The target can be an individual randomization or a setting group (see below).
6. `INHERIT:TARGET` clears all toggle and parameter overrides previously specified for that target, restoring its fallback configuration. Graph targets also clear their exclusions.
7. `EXCLUDE:SCOPE:SELECTOR` excludes a prototype/type/group/subgroup from all normal randomizers, graph randomizers, numerical randomizers, or one randomization.
8. `INCLUDE:SCOPE:SELECTOR` removes that exact rule from its scope. Other matching rules continue to apply.

## Numerical Tuning and Setting Groups

The existing `propertyrandomizer-overrides` startup setting accepts these instructions. You can build them with the **Customizer** tab in the Randomizer Panel, beside Home and Explorer:

1. Choose **Setting groups** or **Individual randomizations**. Search names, or filter individuals by their setting group.
2. Set the on/off choice and the tuning fields you want to override. **Inherit** removes that field's override; hover over a choice for its meaning and fallback. Individual choices win per field.
3. Use **Select string**, copy the generated text, and paste it into **Custom overrides** in the mod startup settings for your next setup.

Drafts are stored separately for each player. **Import / reload a string** accepts a pasted override string or reloads the current startup string. Invalid customization imports leave the draft intact. Existing `SET` and `RESET` instructions keep their relative order; unrecognized instructions in an initially loaded startup string are preserved with a warning. **Reset this target** removes one target's overrides, while **Clear customization overrides** removes numerical and graph choices/exclusions and preserves those other instructions.

An individual target is an active numerical randomization ID from `helper-tables/spec.lua`, such as `belt_speed`. A group target starts with `setting/` and uses the exact startup setting name, such as `setting/propertyrandomizer-logistic`. Group membership is derived from the spec's setting references, including randomizations above the currently selected setting level. Entries whose setting is `none` have no group and can still be targeted individually.

`ON` and `OFF` work with either target. A group toggle enables or disables every numerical randomization tied to that setting. Changing a tuning parameter does **not** enable a randomization.

```text
OFF:setting/propertyrandomizer-logistic;ON:belt_speed
```

For each field independently, an individual override wins over a setting-group override regardless of their order in the string. Missing fields fall back to the group, then the randomization's built-in tuning and global settings. When the same field is repeated at the same scope, the last valid instruction wins. For example:

```text
PARAM:belt_speed.variance=big;PARAM:setting/propertyrandomizer-logistic.range=small;PARAM:setting/propertyrandomizer-logistic.variance=very_small
```

Belt speed gets `range=small` and `variance=big`; other enabled members of the logistics group get `range=small` and `variance=very_small`.

| Parameter | Allowed values | Meaning |
| --- | --- | --- |
| `range` | `very_small`, `small`, `medium`, `big`, `very_big`, `same` | Overall relative range. |
| `range_min`, `range_max` | Same values as `range` | Separate lower and upper ranges. `same` uses the effective overall range. |
| `variance` | Same values as `range` | Walk variability. `same` uses the effective range. |
| `bias` | `worst`, `worse`, `default`, `better`, `best` | Replaces the global bias setting for this randomization, retaining its implementation-specific adjustment and direction. |
| `chaos` | `light`, `less`, `default`, `more`, `ultimate` | Replaces the global chaos setting for this randomization, including its effect on relative ranges. |

If both `range` and `variance` resolve to `same`, they use `medium`. Unspecified asymmetric ranges retain the implementation's defaults; use `range_min=same` or `range_max=same` to make that side follow your overall range.

Use `PARAM:TARGET.PARAMETER=inherit` to remove just that field at that scope. This differs from `same`: `inherit` falls back to the less specific configuration, while `same` links related parameters within the effective configuration. `INHERIT:TARGET` removes all fields at that scope, including its toggle. These instructions act on earlier entries in the same string.

```text
PARAM:setting/propertyrandomizer-logistic.variance=small;PARAM:belt_speed.variance=big;PARAM:belt_speed.variance=inherit
```

Belt speed inherits `variance=small` again. For bias and chaos, `default` explicitly selects the existing default preset; omit the override or use `inherit` to follow the fallback setting.

Absolute limits, rounding, RNG identity, data types, and better/worse directions remain implementation-controlled. Some numerical randomizations apply tuning to intermediate multipliers rather than final properties. Only named tuning levels are supported in this pass. Overrides for graph, unified, and miscellaneous-category entries are not supported by this numerical backend; use their startup settings. Unknown targets, unsupported parameters, and invalid values produce warnings and are skipped, without discarding later valid instructions. `SET` and `RESET` retain their separate post-randomization behavior.

Some entries in the numerical category choose locations or colors directly instead of using a numerical walk. They support toggle overrides, but expose no tuning controls and ignore group tuning. Beacon-profile tuning applies to the noisy profile's numerical multiplier; it does not change the choice of profile family.

## Unified Graph Controls

Choose **Unified graph randomizations** in the Customizer scope dropdown. **All graph randomizations** supplies defaults for each supported field; a handler's own value wins independently of instruction order. These controls customize active unified handlers and do not turn them on. Item cost similarity is unchanged. The older graph algorithms, planetary stages and technology-tree rebuild are separate from these controls.

| Field | Values | Meaning |
| --- | --- | --- |
| `amount` | Whole percentages from `0` to `100` | Select this share of eligible targets to attempt changing. The editor offers 0, 25, 50, 75 and 100. Selection is stable across retries; actual changes can be fewer. |
| `keep_category` | Whole percentages from `0` to `100` | Chance of trying the original crafting category first. A preference with fallback, not a guarantee of a particular machine. Recipe-category handler only. |
| `ingredient_count` | `preserve`, `very_small`, `small`, `medium`, `big`, `very_big` | Variation in distinct recipe ingredient count. Shapes remain bounded by available crafters and may fall back. Recipe-ingredients handler only. |
| `fluids` | `preserve`, `less`, `default`, `more` | Preference for recipe shapes to gain or lose fluid ingredients. `preserve` prevents shape-driven fluid changes; item/fluid swaps are separate. Recipe-ingredients handler only. |
| `resource_balance` | `on`, `off` | Include or omit the existing raw-resource-distribution score. Estimated aggregate cost is still considered. Recipe-ingredients handler only. |

```text
PARAM:graph/all.amount=50;PARAM:graph/recipe-ingredients.amount=75;PARAM:graph/recipe-category.keep_category=100;PARAM:graph/recipe-ingredients.ingredient_count=preserve;PARAM:graph/recipe-ingredients.fluids=less;PARAM:graph/recipe-ingredients.resource_balance=off
```

Supported targets are `graph/all`, `graph/item`, `graph/recipe-ingredients`, `graph/recipe-category`, `graph/entity`, `graph/entity-energy-source`, `graph/mining-fluid-required`, `graph/mining-results`, `graph/spoiling` and `graph/tech-triggers`. Unsupported parameters are rejected. `PARAM:graph/TARGET.FIELD=inherit` restores the field's fallback.

## Prototype Exclusions

Choose **Prototype exclusions** in the Customizer scope dropdown. This is independent of numerical and graph parameter controls. Select a scope on the left, then choose an individual prototype, concrete type, group or subgroup and add it. The individual prototype picker uses the same native selectors as the Explorer for its supported classes; other classes use searchable catalogue choices. Existing `EXCLUDE:graph/...` strings remain supported and appear in this section.

| Scope | What it excludes |
| --- | --- |
| `all` | All normal graph, numerical and cosmetic randomizers |
| `graph/all` | Unified and older graph randomizers |
| `numerical/all` | Every randomization in the numerical category, including its direct edits |
| `graph/HANDLER` | One unified handler, such as `graph/entity` or `graph/recipe-ingredients` |
| `randomization/ID` | One spec randomization, such as `randomization/belt_speed`, `randomization/recipe_ingredients` (older recipe randomization) or `randomization/icons` |

Rules combine across scopes. An individual rule adds to broader rules; `INCLUDE` removes an exact rule rather than overriding a different broad rule. **Clear exclusions for this scope** removes only that scope's rules. Parameter resets in the editor leave exclusions intact. **Clear customization overrides** clears numerical/graph parameters and all exclusion rules while preserving explicit `SET`, `RESET` and unrecognized instructions. The legacy `INHERIT:graph/HANDLER` instruction still clears that handler's parameters and exclusions.

Selectors are:

- `prototype/CLASS/NAME`: a specific prototype, with either its top-level class or concrete prototype type.
- `type/TYPE`: every prototype of this concrete type.
- `group/NAME`: prototypes belonging to this existing group.
- `subgroup/NAME`: prototypes belonging to this existing subgroup.

```text
EXCLUDE:all:prototype/entity/assembling-machine-1;EXCLUDE:graph/all:group/logistics;EXCLUDE:numerical/all:type/inserter;EXCLUDE:randomization/belt_speed:type/transport-belt;EXCLUDE:graph/recipe-ingredients:prototype/recipe/iron-gear-wheel
```

The catalogue comes from loaded prototypes and their type/group/subgroup metadata before normal graph randomization. Scope membership stays tied to that metadata even when an earlier permitted pass moves a prototype to another group. Recipes inherit a singular/main product's subgroup when they do not declare one, following `RecipePrototype.main_product` in the installed prototype API. Entities without a declared subgroup are grouped with their placing items. A valid selector that matches no loaded prototypes produces a panel warning.

Graph exclusions remove candidates before claiming/matching, preserving material references and placing relationships where needed. Numerical/cosmetic exclusions preserve matching prototypes from immediately before each affected pass, including direct writes that bypass the numerical helper. Indirect numerical edits to a shared child are skipped when an affected parent is excluded, so shared children can also stay unchanged for other parents. Earlier allowed graph changes are retained by a numerical-only exclusion.

Exclusions concern the selected prototypes and normal randomization passes. They do not freeze upstream production chains, planetary transformations, technology-tree rebuilding, required repairs/fixes, recycling regeneration or explicit `SET`/`RESET` instructions.

Graph-parameter validation configurations in `tests/configs.txt` start with duplicates and numerical categories off. The standalone-exclusion configurations also exercise numerical and older graph passes; compare retries, elapsed time, identity changes, recipe shape fallbacks and final `MECHCHECK` verdicts. `GRAPHCUSTOM` log lines report selection counts per handler.

## Prototype Properties

To select a prototype property, you first need to type the prototype. Luckily, Factorio already has a built-in method for this. It goes `[top-level-class=prototype-name]`. You might not know what the top level class/prototype name of a thing is (or even what that means), but no fear! If you have something pipetted, you can open chat and click it to paste a string in exactly this format. You can also google "Factorio rich text" for more information. Beware that there is a difference between, say, the *entity* inserter, the *item* inserter, and the *recipe* inserter. From the engine's perspective, these are different things. Here's an overview of the biggest top-level classes:

* Entities (`entity=`) are all in-world objects (with a few exceptions). That's what you'd use for setting most properties like rotation speed or health.
* Items (`item=`) are the things in your inventory. This is what you'd focus on if, say, the stack size was unbearable.
* Recipes (`recipe=`) are the processes for getting items.

Now, if you use `RESET`, you don't need to do anything else. In that case, it will reset *all* properties of the original thing (or prototype, in modding terminology) back to original. This could cause unexpected results in some cases, so I've also included a special property, `NUMERICAL`, if you just want to reset numerical properties (mining time, crafting speed, etc., rather than crafting categories or mining results).

Properties in general are specified with `.` notation. So to reset all numerical properties of an inserter entity, you'd do `RESET:[entity=inserter].NUMERICAL`. If you wanted to reset just the rotation speed, you could do `RESET:[entity=inserter].rotation_speed`. See the API docs [online](https://lua-api.factorio.com/stable/index-prototype.html) or in your local installation for information about the different properties, or you can ask on exfret's discord server (link on main mod page) for help if there is something specific you want to do.

Some properties are nested, like the mining time of an inserter, which is specified by `[entity=inserter].minable.mining_time` (there is a table for inserters specifying how they're mined, called `minable`, and in this is the time it takes to mine them, `mining_time`). This syntax is supported, and the randomizer will attempt to recurse into tables to get to the actual property when possible.

## Expressions

When using the `SET` instruction, it is not enough to simply specify a prototype property like `SET:[entity=inserter].rotation_speed`. You must also specify the new value, like `SET:[entity=inserter].rotation_speed=2`. In general, try not to include spaces, but the expression parsing uses a helper function provided by Factorio itself, so it's more flexible. Most standard math operations are supported, so you could do things like `SET:[entity=inserter].rotation_speed=2*3-5^2`. There are also two special provided variables, `X`, which is the original value of that property before randomization, and `Y`, which is the new value. So if you thought the new value for rotation speed was just a bit much, and wanted to average it with the old value, you could do `SET:[entity=inserter].rotation_speed=(X+Y)/2`. See [here](https://lua-api.factorio.com/stable/concepts/MathExpression.html) for more information about math expression format.

You can also include a Lua table where an expression would go in order to set a table-valued property. Thus, one could do `SET:[entity=inserter].minable={mining_time=0.1,result="transport-belt"}`. Try not to include any spaces while doing this. This is mostly for those more experienced with the modding API. Also note that you must type in numeric keys manually (apologies). So you would do `ingredients={1={type="item",name="iron-plate",amount=1}}`.

## Limitations

Numerical parameters/toggles, supported unified graph controls and prototype exclusion scopes are configurable before randomization. Prototype-property `SET` and `RESET` instructions still run afterward; use `EXCLUDE` to exclude normal randomization passes.

## Risks

Turning numerical randomizations on or off with ON or OFF shouldn't have an affect on the rest of the randomization process, as each one uses a separate random number generator. However, there have been reports of this still breaking, so toggle randomizations mid-run at your own risk.

On the other hand, prototype value fixes with SET and RESET are done after all randomizations are already complete, so they are completely safe to use, and are particularly useful if a randomization botched something, like making a number so high or low that the run is effectively unplayable.

That being said, the override system was recently expanded with new features, so make sure to report any bugs or issues you find.

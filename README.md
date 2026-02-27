# Introduction

A mod that randomizes everything in the game Factorio.

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

Currently, randomization parameters are not yet configurable. Additionally, nothing can be excluded before randomization begins, meaning this is not useful for the prevention of startup crashes during the randomization process. Still, I hope this is a useful feature for future debugging and dealing with softlocks.

## Risks

Turning numerical randomizations on or off with ON or OFF shouldn't have an affect on the rest of the randomization process, as each one uses a separate random number generator. However, there have been reports of this still breaking, so toggle randomizations mid-run at your own risk.

On the other hand, prototype value fixes with SET and RESET are done after all randomizations are already complete, so they are completely safe to use, and are particularly useful if a randomization botched something, like making a number so high or low that the run is effectively unplayable.

That being said, the override system was recently expanded with new features, so make sure to report any bugs or issues you find.
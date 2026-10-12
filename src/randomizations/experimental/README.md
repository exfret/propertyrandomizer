# Parked military resistance experiment

`src/config/experimental-flags.lua` sets `military_resistances = false`.
This source flag is independent of the unified preview, Military More and damage-type settings.

With the flag off:

- The graph damage-type handler and automatic encounter scoring are disabled even if preview and their startup setting are enabled.
- Numerical samplers and affected entity, item, equipment, energy and trigger routines use their pre-experiment implementations.
- The numerical resistance pass is absent from the randomization spec.
- The resistance helper returns no candidates or groups and refuses mutation attempts before evaluating callbacks. This also disables resistance permutations when called by the graph damage-type handler.
- Experimental functions can be loaded at module scope, as required by the project's require-placement rules, but are not installed or called.

The experimental implementations are retained here for later redesign. The sampler versions are in `lib/random/experimental/`. Explicitly setting the source flag to true selects them. This does not mark the current sensitive-entity grouping design as accepted.

Run `lua tests/unit/prototypes/combat/test-resistance-experiment-flag.lua` to verify the default-off dispatch and inert resistance helper. The experiment's numerical and resistance unit tests explicitly enable the flag in their isolated Lua process.

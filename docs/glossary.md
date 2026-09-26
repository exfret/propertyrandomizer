# Glossary (working vocabulary)

New terms from ongoing design work on unified randomization. Established terms (*pebble*, *context*, *emitter*, *forgetter*, *transmitter*, *prereq shuffle*, *first pass*, etc.) are defined in the [wiki glossary](https://github.com/exfret/propertyrandomizer/wiki/Glossary); terms here may graduate there once they settle.

**Anchor context:** The one context a recipe with no promised pebbles is required in, chosen just before its ingredients are randomized: the earliest context where it's currently *established* with its vanilla ingredients. All its new ingredients must be established there, and the recipe is then promised there, which keeps every originally reachable recipe reachable.

**Backing:** The set of earlier *pebbles* that justify a *promised* pebble. A recipe pebble `(r, c)` is backed by every ingredient pebble `(i, c)`; an item/fluid pebble is backed by one producer pebble. A backing is only valid if every pebble in it is *earlier* in the *sort* and itself backed (see *well-founded*).

**Debt:** A *pending constraint* with no known *fallback bundle*. Arises when the sort is not a sort of the vanilla graph (e.g. *multipass*), so vanilla ingredients can't be assumed to satisfy it. Currently out of scope.

**Earliest-provider rule:** When tracing a *witness* or *backing* backward through an OR node, choose the provider whose pebble comes first in the sort. Guarantees every step goes strictly earlier (no loops) and tends to produce small witnesses. Implemented by `path` in `lib/graph/consistent-sort.lua`.

**Established:** A pebble that has a *backing* in the current random graph, where resolved recipes use their new ingredients, unresolved recipes use their vanilla ingredients, and generic handlers' heads use their chosen bases. Promised pebbles are established by construction. Implemented as `establish` in `randomizations/graph/unified/skeleton/promotion.lua`.

**Fallback bundle:** An ingredient list known to satisfy all of a recipe's *pending constraints*. When the sort is a random sort of the vanilla graph, the recipe's vanilla ingredients are always a fallback bundle, which is what makes *promotion* safe and guarantees completion.

**Mechanic context:** A *pebble* for a mechanic node whose context must be preserved by randomization (e.g. being able to operate a certain entity on a certain planet). Mechanic contexts are *promised* from the start.

**Pending constraint:** The requirement placed on a not-yet-randomized recipe when one of its pebbles `(r, c)` is *promised*: its eventual ingredients must be promised in `c` and earlier than `(r, c)`.

**Promise / promised pebble:** A pebble the final randomized graph is required to reach. The promised set starts as the *skeleton* and grows through *promotion*. Promises are reference counted so ones nothing depends on anymore can be released.

**Promotion:** Adding a not-yet-promised pebble (typically an item/fluid a randomized recipe wants as an ingredient) to the promised set by finding a *backing* for it that lies entirely before the position that needs it. Lets candidates come from outside the skeleton without losing correctness.

**Rank:** A pebble's position in the sort. "Earlier" always means lower rank.

**Skeleton:** The union of the *witnesses* for all *mechanic contexts*; the initial promised set. Only skeleton (and later promoted) pebbles impose ordering constraints on randomization, instead of every node in every context.

**Sort:** Here, a randomized contextual topological sort of the vanilla graph (e.g. `sort` in `lib/graph/consistent-sort.lua`), used to assign *ranks*.

**Well-founded:** The correctness condition for promises: every promised pebble has a backing of promised pebbles with strictly lower rank. Induction on rank then shows every promised pebble, including every mechanic context, is reachable in the final graph.

**Witness:** A backward derivation of a pebble through the graph (all prereqs for AND, one provider for OR via the *earliest-provider rule*, one shared context for *forgetters*), showing how it is reached.

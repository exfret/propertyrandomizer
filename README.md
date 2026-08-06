<p align="center">
  <img src="https://i.imgur.com/UAIppMC.png" width="180" alt="exfret's Randomizer logo">
</p>

<h1 align="center">exfret's Randomizer</h1>

<p align="center">
  <strong>A Factorio overhaul built around an algorithmic question:</strong><br>
  how much of a game's progression can be rewired while keeping it completable and interesting?
</p>

<p align="center">
  <a href="https://mods.factorio.com/mod/propertyrandomizer">Mod Portal</a>
  ·
  <a href="https://github.com/exfret/propertyrandomizer">Source</a>
  ·
  <a href="https://github.com/exfret/propertyrandomizer/wiki">Technical Wiki</a>
  ·
  <a href="https://discord.gg/ebHX7Yek9T">Discord</a>
</p>

exfret's Randomizer changes almost every aspect of a Factorio playthrough. Recipes, technologies, machines, resources, logistics, combat properties, visuals, and many other systems can all change from one seed to the next. Over one hundred different properties are now randomized on game startup.

But the number of randomizations is only the tip of the iceberg. Factorio is a densely interconnected game: an item may have several recipes, a recipe may require a particular machine on a particular planet, a machine may require certain resources like electricity to work, and any "loop" in any of these dependencies could result in a genuine softlock (i.e.- a situation preventing a game from being finished, such as if a necessary item required itself in its own crafting recipe). A naive implementation almost always causes the entire game to become unplayable.

This project treats randomization as an algorithmic problem. It constructs a rich "dependency graph" model of game progression, implements efficient reachability algorithms for that model, applies those algorithms to structurally scramble it in ways that inherently produce no softlocks, and then reflects the transformed graph back into Factorio's prototype data.

The goal is to generate new gameplay experiences without procedural content generation. Maybe burner drills are suddenly better than electric drills. Maybe inserters pick up items from three tiles away. Maybe an atomic bomb is now something you mine from the ground. The pieces are still Factorio's; their relationships are not.

## How does it stay playable?

Changing one number at a time is easy. Rewiring Factorio’s progression is not.

Recipes, technologies, machines, resources, planets, power systems, and alternate production routes all depend on one another. A careless shuffle can make an important item require itself, place a required machine behind the technology that needs it, or move an ingredient somewhere the player cannot yet reach.

exfret’s Randomizer builds a model of these relationships before changing them. This lets it do several things that simpler randomizers generally cannot:

* **Restructure progression without relying on pure luck.** Major randomizations are designed to preserve at least one route through the game instead of repeatedly shuffling until a seed happens not to be broken.
* **Change several connected systems together.** A recipe, its technology unlock, its required machine, and the resources used to craft it can be changed at once rather than in isolation.
* **Understand alternate routes.** Other randomizers can change things like the ingredients to produce an electronic circuit, but this mod can change how they're obtained altogether (maybe you mine them instead of crafting them).
* **Handle Space Age’s location constraints.** Something can be obtainable on one planet but inaccessible or impractical on another. Context-based logic tracks not just what you can do, but how and where.
* **Avoid technically valid but miserable seeds.** Production-cost estimates calculated with "flow cost" and simplex solver methods help prevent early essentials from becoming absurdly expensive even when the game would still be completable in principle.
* **Apply the result directly to Factorio.** The model is not only used to test a seed. Its transformed relationships are converted back into real recipes, technologies, machines, resources, effects, and other prototype data.

This is what allows the mod to produce changes larger than ordinary stat randomization or one-to-one recipe swaps. The game still uses Factorio’s existing content, but familiar objects can occupy genuinely different roles in the progression.

The full algorithms, diagrams, design history, and experimental systems are documented in the [technical wiki](https://github.com/exfret/propertyrandomizer/wiki).

## Installation and use

The easiest way to install the mod is through Factorio's in-game mod browser. The latest stable release (and older releases) can also be manually downloaded from the [Factorio Mod Portal](https://mods.factorio.com/mod/propertyrandomizer) and placed in your mod folder. Note that the version on this repo is a work-in-progress version and may not be ready for actual play.

Configuration is available through changing the mod settings in-game. A seed controls deterministic generation, while category, chaos, bias, and advanced override settings control what may change and how aggressively.

The advanced override language can enable or disable individual randomizations and reset or replace specific prototype properties after randomization. **See OVERRIDES.md for override documentation.**

## Repository map

For a more complete map and more details, see the corresponding [page on the wiki](https://github.com/exfret/propertyrandomizer/wiki/Directory-structure).

```text
root
|- helper-tables
|  |- spec.lua .................... List of all randomizations
|- lib
|  |- graph
|  |  |- build-graph.lua .......... Old game logic
|  |  |- top-sort.lua ............. Old topological sort logic
|  |- random
|  |  |- rng.lua .................. Random number generation library
|- lib
|  |- graph ....................... Includes new topological sort
|  |- logic ....................... New game logic
|- randomizations
|  |- graph ....................... Graph randomizations (change fundamental game progression)
|  |  |- unified .................. New unified graph randomizations (run all at once); use new logic/lib
|  |- misc ........................ Silly randomizations that aren't just changing a number
|  |- numerical ................... Simply numerical randomizations
|- config.lua ..................... Settings parsing
|- data-final-fixes.lua ........... Entry point for randomization
```

## Development and testing

exfret's Randomizer is written primarily in Lua and runs mostly during Factorio's data stage.

The repository includes:

* a startup-test harness that launches Factorio across multiple mod-list and settings configurations;
* pedagogical implementations of selected algorithms under `docs/algorithms/`;
* release scripts for testing, pruning development files, and packaging the mod.

## Contributing

There are several fairly different ways to contribute:

* implement or polish numerical and structural randomizations;
* expand the dependency model for game features or other mods;
* improve reflection, compatibility, and user-facing diagnostics;
* investigate graph-randomization algorithms, cost models, and context-aware reachability;
* report reproducible bad seeds, softlocks, or compatibility failures.

For graph work, start with the wiki's recommended reading order:

1. [Graph randomization algorithms](https://github.com/exfret/propertyrandomizer/wiki/Graph-randomization-algorithms)
2. [Encoding dependencies](https://github.com/exfret/propertyrandomizer/wiki/Encoding-dependencies)
3. [Sorting](https://github.com/exfret/propertyrandomizer/wiki/Sorting)
4. [Prereq shuffle](https://github.com/exfret/propertyrandomizer/wiki/Prereq-shuffle)
5. [Logic with contexts](https://github.com/exfret/propertyrandomizer/wiki/Logic-with-contexts)
6. [Slot scramble](https://github.com/exfret/propertyrandomizer/wiki/Slot-scramble)
7. [Multipass methods](https://github.com/exfret/propertyrandomizer/wiki/Multipass-methods)

Bug reports can be made here, on the mod portal, or in my Discord. The last option is the most preferable, as it allows me to interact with you to narrow the issue more carefully, and I am fairly responsive on that platform. The recent log file and screenshot of the exact error message or issue are also helpful for debugging (and savefile if possible/applicable).

## Credits

exfret's Randomizer was created and is maintained by **exfret**.

Nifyr has made major code and algorithmic contributions, including ideas that shaped the multipass architecture. Protocol_1903 contributed code; Osmo contributed graphics; Kotrenn contributed dependency-graph visualizations; and many players have provided testing, examples, and delightfully cursed seeds.

See the [mod portal page](https://mods.factorio.com/mod/propertyrandomizer) and repository history for additional credits and community showcases.

## License

MIT

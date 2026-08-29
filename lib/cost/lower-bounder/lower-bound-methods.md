# What is this?

This is a project for lower-bounding the amount of time it takes to finish Factorio, a factory-building simulation game.

I tried to use as few assumptions as possible, but ultimately needed to make some. Most importantly, the program doesn't factor in modules, except for pretending there are built-in productivity module 3's in the silo.

## Motivation

While working on cost calculations for my randomizer, I kept getting into a situation where I had to come up with an arbitrary cost for something. How much should I charge for the space a builing takes up, if anything? What about complexity of a recipe? What about time it takes to complete an action? And that last point stuck with me, particularly as I am an impatient person. What if *all* we cared about was the time it took? What's the minimum time to craft a recipe, to builing a rocket silo, or even to launch a rocket?

This is something I've been wondering for a few years: how long does it take to beat Factorio? What is the minimum time, even for a TAS? I never had a good method for measuring it. Anything I could think of either made a bunch of assumptions about what you could do in Factorio, would have been computationally infeasible to figure out, or gave stupid estimates like "at least a minute". But after all the conditioning of my brain with the randomizer, I think I finally have a way to get a lower bound: 7 minutes... with qualifications (covered below).

## What we are trying to measure

This may sound quite low, but it's important to keep in mind the sort of statement being made here. The lower bound is absolute; there is no way to beat it (given the assumptions I cover in the next section). It isn't just a "well, someone worked thousands of hours trying to figure out how to do better and couldn't improve it that much". The statement being made is that it is *mathematically impossible* to do any better. To make such a statement requires not just overwhelming evidence, but demonstration that all of the combinatorially massive number of possibilities of playing the game on any seed in any way will not get you a faster result.

Moreover, I didn't code in any logic for movement or player building speed or even the fact that recipes/buildings etc. only exist in integer quantities. So technically these same bounds apply for a super-TAS that can instantly teleportation, build more than one thing a tick, and craft/build fractions of things at a time as needed. If we factor in actual movement/building/discreteness restrictions, perhaps we could push the lower bound up even more. But that was out of scope for what I was trying to accomplish.

## Qualifications

This project does make some assumptions, and a few of them are fairly large. Most importantly, I did not factor in modules, except for productivity module 3's on the rocket silo. Unfortunately, the complexity of the problem explodes once modules are considered. I hope the time bounds given are still informative and satisfy some curiosity. If someone else wants to pick it up and factor in modules, that would be great.

I also rely on some facts about the linear relaxation of Factorio production that I use, which I find clear from a mathematical perspect, but not rigorously proven.

Finally, I make some small assumptions that I feel should be reasonable to any Factorio veteran: I don't use coal liquefaction, assume that solid fuel is made from light oil, etc. These seemed more like annoyances to prove rigorously rather than actual constraints.

# Methods

## Initial approaches

TODO: linear relaxations, exponential methods, simplex, matrix for production, etc.
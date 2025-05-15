# propertyrandomizer

## Overrides

To use the overrides setting, simply type in each randomization you'd like on, separated by semicolons without spaces. For example "belt_speed;cliff_sizes" is a valid string. If you don't want a randomization on, then put an exclamation mark before the randomization. For example "belt_speed;!cliff_sizes" forces belt speeds to be randomized, and also forces cliff sizes not to be randomized. Overrides take precedence over all other settings.

See "helper-tables/spec.lua" for the list of all overrides and information about specific ones.
data:extend({
    {
        setting_type = "startup",
        type = "int-setting",
        name = "propertyrandomizer-seed",
        localised_name = "Random seed",
        localised_description = "Changing this will change how everything is randomized.",
        default_value = 0,
        minimum_value = -9007199254740992,
        maximum_value = 9007199254740992,
        order = "a[seed]"
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-watch-the-world-burn",
        localised_name = "Watch the world burn",
        localised_description = "Sets bias to worst, chaos to ultimate, adds tons of duplicates for a longer game, and turns on every randomization. Also includes a couple... \"tweaks\". Takes precedence over all below settings. Not necessarily compatible with mods other than Space Age, or with those who are faint of heart.",
        default_value = false,
        order = "az[burn]",
        hidden = true
    },
    {
        setting_type = "startup",
        type = "string-setting",
        name = "propertyrandomizer-bias",
        localised_name = "Bias",
        localised_description = "How much the randomization process should try to make things in your favor.",
        allowed_values = {
            "worst",
            "worse",
            "default",
            "better",
            "best"
        },
        default_value = "default",
        order = "b-a[bias]"
    },
    {
        setting_type = "startup",
        type = "string-setting",
        name = "propertyrandomizer-chaos",
        localised_name = "Chaos",
        localised_description = "How random to make things. Play higher values at your own risk.",
        allowed_values = {
            "light",
            "less",
            "default",
            "more",
            "ultimate"
        },
        default_value = "default",
        order = "b-ba[chaos]"
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-dupes",
        localised_name = "Duplicates (beta)",
        localised_description = "Whether to include duplicates of important recipes/entities/etc.",
        default_value = false,
        order = "b-z[dupes]"
    },
    {
        setting_type = "startup",
        type = "string-setting",
        name = "propertyrandomizer-logistic",
        allowed_values = {
            "none",
            "less",
            "default",
            "more"
        },
        localised_name = "Logistics",
        localised_description = "Randomize speeds of belts/inserters, lengths of underground belts, supply area of electric poles, and other logistical things.",
        default_value = "default",
        order = "c-a[logistic]"
    },
    {
        setting_type = "startup",
        type = "string-setting",
        name = "propertyrandomizer-production",
        allowed_values = {
            "none",
            "less",
            "default",
            "more"
        },
        localised_name = "Production",
        localised_description = "Randomize production capabilities of machines, like machine crafting speeds and module slots.",
        default_value = "default",
        order = "c-b[production]"
    },
    {
        setting_type = "startup",
        type = "string-setting",
        name = "propertyrandomizer-military",
        allowed_values = {
            "none",
            "less",
            "default",
            "more"
        },
        localised_name = "Military",
        localised_description = "Randomize gun shooting speeds, bonus damage, etc. Turn this down or off if you're having troubles with biter difficulty.",
        default_value = "default",
        order = "c-c[military]"
    },
    {
        setting_type = "startup",
        type = "string-setting",
        name = "propertyrandomizer-misc",
        allowed_values = {
            "none",
            "less",
            "default",
            "more"
        },
        localised_name = "Extras",
        localised_description = "Randomizes most other things that don't fit in another category. 'Most' randomizes basically every other property in the game except for those touched by other settings.",
        default_value = "default",
        order = "c-z[misc]"
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-simultaneous",
        localised_name = "Simultaneous (beta)",
        localised_description = "Performs randomizations simultaneously rather than all at once. Currently a WIP.",
        default_value = false,
        order = "d-a[simultaneous]",
        hidden = true
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-unified",
        localised_name = "Unified (beta)",
        localised_description = "Randomizes everything all at once. Not recommended with the other major randomizations below.",
        default_value = false,
        order = "d-b[unified]",
        hidden = true
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-technology",
        localised_name = "Technologies",
        localised_description = "Randomizes the technology tree (which techs are prerequisites to which other ones).",
        default_value = false,
        order = "d-c[technology]"
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-recipe",
        localised_name = "Recipes",
        localised_description = "Randomizes all recipe ingredients (not just the amounts).",
        default_value = false,
        order = "d-d[recipe]"
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-recipe-tech-unlock",
        localised_name = "Recipe unlocks",
        localised_description = "Randomizes which tech a recipe is unlocked by.",
        default_value = false,
        order = "d-e[recipe-tech-unlock]"
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-item",
        localised_name = "Items",
        localised_description = "Randomizes where items are in the game. For example, instead of mining coal you might mine fish, or furnaces could replace circuits as one of the most common intermediates.",
        default_value = false,
        order = "d-f[item]"
    },
    {
        setting_type = "startup",
        type = "double-setting",
        name = "propertyrandomizer-item-percent",
        localised_name = "Percent of items randomized",
        localised_description = "What percentage of non-resource items should be randomized (raw resources are always randomized for increased fun). 100% shuffles every item in the game while still preventing softlocks.",
        default_value = 30,
        minimum_value = 0,
        maximum_value = 100,
        order = "d-fa[item]"
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-icon",
        localised_name = "Icons",
        localised_description = "Every icon in the game is randomized. Are you crazy?",
        default_value = false,
        order = "e-a[icon]"
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-sound",
        localised_name = "Sounds",
        localised_description = "Every sound in the game is randomized. Who are you?",
        default_value = false,
        order = "e-b[sound]"
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-gui",
        localised_name = "GUI",
        localised_description = "Positions of recipes in the GUI are randomized. What the heck?",
        default_value = false,
        order = "e-c[gui]"
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-locale",
        localised_name = "Names",
        localised_description = "Shuffles the names of everything in the game. Why?",
        default_value = false,
        order = "e-d[locale]"
    },
    {
        setting_type = "startup",
        type = "string-setting",
        name = "propertyrandomizer-colors",
        localised_name = "Colors",
        localised_description = "Each color value is randomized. How?..",
        allowed_values = {
            "no",
            "little",
            "crazy",
        },
        default_value = "no",
        order = "e-e[colors]"
    },
    {
        setting_type = "startup",
        type = "string-setting",
        name = "propertyrandomizer-numerical-algorithm",
        localised_name = "Algorithm",
        localised_description = "I'm trying out a new randomization algorithm for numerical randomizations; switch to 'Safeguarded' for the old version, and be sure to provide feedback on the change!",
        allowed_values = {
            "fleishman",
            "exfret-random-walk"
        },
        default_value = "fleishman",
        order = "f-a[algorithm]"
    },
    {
        setting_type = "startup",
        type = "string-setting",
        name = "propertyrandomizer-softlock-prevention",
        localised_name = "Soflock errors",
        localised_description = "How strict to be about error-ing on application startup if potential softlocks are found. Errors are always reported when starting a new game.",
        allowed_values = {
            "control-only",
            "critical",
            --"all"
        },
        default_value = "control-only",
        order = "f-b[softlock]",
        hidden = true
    },
    {
        setting_type = "startup",
        type = "string-setting",
        name = "propertyrandomizer-overrides",
        localised_name = "Custom overrides [See Tooltip]",
        localised_description = "For extra fancy customization. See README for more information. README can be found in the mod folder locally or online here: github.com/exfret/propertyrandomizer",
        default_value = "",
        allow_blank = true,
        order = "z-custom-override"
    }
})
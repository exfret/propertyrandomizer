data:extend({
    {
        setting_type = "startup",
        type = "int-setting",
        name = "propertyrandomizer-seed",
        localised_name = "Random seed",
        localised_description = "Changing this will change how everything is randomized.",
        default_value = 23,
        minimum_value = -9007199254740992,
        maximum_value = 9007199254740992,
        order = "a[seed]"
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
        order = "b-a[chaos]"
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-dupes",
        localised_name = "Duplicates (beta/not recommended)",
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
        localised_name = "Logistics randomization",
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
        localised_name = "Production randomization",
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
        localised_name = "Military randomization",
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
        localised_name = "Extra Randomizations",
        localised_description = "Randomizes most other things that don't fit in another category. 'Most' randomizes basically every other property in the game except for those touched by other settings.",
        default_value = "default",
        order = "c-z[misc]"
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-technology",
        localised_name = "Randomized tech tree",
        localised_description = "Randomizes the technology tree (which techs are prerequisites to which other ones).",
        default_value = true,
        order = "d-a[technology]"
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-recipe",
        localised_name = "Randomized recipes",
        localised_description = "Randomizes all recipe ingredients (not just the amounts).",
        default_value = true,
        order = "d-b[recipe]"
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-item",
        localised_name = "Randomized items",
        localised_description = "Randomizes where items are in the game. For example, instead of mining coal you might mine fish, or furnaces could replace circuits as one of the most common intermediates.",
        default_value = true,
        order = "d-c[item]"
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
        order = "d-ca[item]"
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-icon",
        localised_name = "Randomized icons (not recommended)",
        localised_description = "Every icon in the game is randomized. Are you crazy?",
        default_value = false,
        order = "e-a[icon]"
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-sound",
        localised_name = "Randomized sound (not recommended)",
        localised_description = "Every sound in the game is randomized. Who are you?",
        default_value = false,
        order = "e-b[sound]"
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-gui",
        localised_name = "Randomized GUI (not recommended)",
        localised_description = "Positions of recipes in the GUI are randomized. What the heck?",
        default_value = false,
        order = "e-c[gui]"
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-locale",
        localised_name = "Randomized names (not recommended)",
        localised_description = "Shuffles the names of everything in the game. Why?",
        default_value = false,
        order = "e-d[locale]"
    },
    {
        setting_type = "startup",
        type = "string-setting",
        name = "propertyrandomizer-overrides",
        localised_name = "Custom overrides [See Tooltip]",
        localised_description = "For extra fancy customization. See README for more information. README can be found in the mod folder locally or here online: github.com/exfret/propertyrandomizer",
        default_value = "",
        allow_blank = true,
        order = "z-custom-override"
    }
})
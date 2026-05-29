data:extend({
    {
        setting_type = "startup",
        type = "int-setting",
        name = "propertyrandomizer-seed",
        default_value = 0,
        minimum_value = -9007199254740992,
        maximum_value = 9007199254740992,
        order = "a[seed]"
    },
    {
        setting_type = "startup",
        type = "string-setting",
        name = "propertyrandomizer-preset",
        allowed_values = {
            "default",
        },
        default_value = "default",
        order = "ab[preset]",
        hidden = true
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-watch-the-world-burn",
        default_value = false,
        order = "az[burn]",
        hidden = true,
        forced_value = false,
    },
    {
        setting_type = "startup",
        type = "string-setting",
        name = "propertyrandomizer-bias",
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
        default_value = false,
        order = "b-z[dupes]",
        -- Hidden while broken
        hidden = true
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
        default_value = "default",
        order = "c-z[misc]"
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-technology",
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
        default_value = false,
        order = "d-e[recipe-tech-unlock]"
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-recipe-tech-unlock-duplicates",
        default_value = true,
        order = "d-ea[recipe-tech-unlock-duplicates]"
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-item",
        default_value = true,
        order = "d-f[item]"
    },
    {
        setting_type = "startup",
        type = "double-setting",
        name = "propertyrandomizer-item-percent",
        default_value = 100,
        minimum_value = 0,
        maximum_value = 100,
        order = "d-fa[item]"
    },
    {
        setting_type = "startup",
        type = "int-setting",
        name = "propertyrandomizer-item-retries",
        default_value = 10,
        minimum_value = 1,
        order = "d-fb[item]"
    },
    {
        setting_type = "startup",
        type = "int-setting",
        name = "propertyrandomizer-unified-retries",
        default_value = 10,
        minimum_value = 1,
        order = "e-[unified]"
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-unified-tech-prereqs",
        default_value = false,
        order = "e-a[tech-prereqs]"
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-unified-recipe-tech-unlocks",
        default_value = false,
        order = "e-b[recipe-tech-unlocks]"
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-unified-spoiling",
        default_value = false,
        order = "e-c[spoiling]"
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-unified-tech-science-packs",
        default_value = false,
        order = "e-d[tech-science-packs]"
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-unified-entity-operation-fluid",
        default_value = false,
        order = "e-e[entity-operation-fluid]",
        hidden = true,
        forced_value = false,
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-unified-mining-fluid-required",
        default_value = false,
        order = "e-f[mining-fluid-required]",
        hidden = true
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-unified-entity-autoplace",
        default_value = false,
        order = "e-g[entity-autoplace]",
        hidden = true
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-unified-recipe-ingredients",
        default_value = false,
        order = "e-h[recipe-ingredients]",
        hidden = true
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-unified-item-ingredients",
        default_value = false,
        order = "e-i[item-ingredients]",
        hidden = true
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-unified-item",
        default_value = false,
        order = "e-j[item]",
        hidden = true
    },
    {
        setting_type = "startup",
        type = "string-setting",
        name = "propertyrandomizer-unified-technology-delinearization",
        allowed_values = {
            "none",
            "some",
            --"lots",
        },
        default_value = "some",
        order = "f-a[tech-delinearization]",
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-icon",
        default_value = false,
        order = "g-a[icon]"
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-sound",
        default_value = false,
        order = "g-b[sound]"
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-gui",
        default_value = false,
        order = "g-c[gui]"
    },
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-locale",
        localised_name = "Names",
        localised_description = "Shuffles the names of everything in the game. Why?",
        default_value = false,
        order = "g-d[locale]"
    },
    {
        setting_type = "startup",
        type = "string-setting",
        name = "propertyrandomizer-colors",
        allowed_values = {
            "no",
            "little",
            "crazy",
        },
        default_value = "no",
        order = "g-e[colors]"
    },
    {
        setting_type = "startup",
        type = "string-setting",
        name = "propertyrandomizer-numerical-algorithm",
        allowed_values = {
            "fleishman",
            "exfret-random-walk",
        },
        default_value = "exfret-random-walk",
        order = "h-a[algorithm]"
    },
    {
        setting_type = "startup",
        type = "string-setting",
        name = "propertyrandomizer-overrides",
        default_value = "",
        allow_blank = true,
        order = "z-custom-override"
    },
    -- Hidden settings for testing purposes
    {
        setting_type = "startup",
        type = "bool-setting",
        name = "propertyrandomizer-test-unit",
        default_value = false,
        hidden = true
    },
})
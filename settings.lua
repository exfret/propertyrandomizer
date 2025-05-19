data:extend({
    {
        setting_type = "startup",
        type = "int-setting",
        name = "propertyrandomizer-seed",
        localised_name = "Random seed",
        localised_description = "Changing this will change how everything is randomized.",
        default_value = 23,
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
        order = "b[bias]"
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
      order = "b[chaos]"
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
      type = "string-setting",
      name = "propertyrandomizer-overrides",
      localised_name = "Custom overrides [See Tooltip]",
      localised_description = "For extra fancy customization. See README for more information. README can be found in the mod folder locally or here online: github.com/exfret/propertyrandomizer",
      default_value = "",
      allow_blank = true,
      order = "z-custom-override"
    }
})
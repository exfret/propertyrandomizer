data:extend({
    -- Key sequence for returning to nauvis
    {
        type = "custom-input",
        name = "return-to-nauvis",
        key_sequence = "CONTROL + SHIFT + R",
        localised_name = "Return Home"
    },
    -- Key sequence for randomizer info panel
    {
        type = "custom-input",
        name = "randomizer-panel",
        key_sequence = "CONTROL + P",
        localised_name = "Open Randomizer Panel"
    },
    -- Special item for images
    {
        type = "item",
        name = "propertyrandomizer-gear",
        localised_name = "exfret's randomizer",
        localised_description = "FUN!",
        stack_size = 23,
        icon = "__propertyrandomizer__/graphics/gear-icon.png",
        icon_size = 127
    },
})

-- Turn settings off that I made hidden so that players aren't stuck with them on
settings.startup["propertyrandomizer-softlock-prevention"].value = false
settings.startup["propertyrandomizer-watch-the-world-burn"].value = false
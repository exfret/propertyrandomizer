-- Global table for mods to say changes they want to be executed or extra data for the randomizer
RANDOMIZER_HOOK = {
    -- Modifications executed for the dependency graph
    -- pass in functions that take params = { logic = logic, lookups = lookups }
    GRAPH_FIXES = {},
}

data:extend({
    -- Key sequence for returning to starting planet
    {
        type = "custom-input",
        name = "return-to-starting-planet",
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
        icon_size = 127,
        hidden = true,
    }
})
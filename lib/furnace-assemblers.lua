-- Furnaces made assembling machines, all but the ones crafting recycling (user, 2026-10-09)
-- A furnace picks its recipe by its ingredient, and only takes recipes with one item ingredient, one fluid ingredient, or one of each (auxiliary/furnace-recipe-selection.html in the 2.1 API docs), so randomization had to keep every recipe a furnace crafts to that shape with no ingredient shared
-- As assembling machines they craft whatever recipe the player picks, so any recipe can go to their categories; Krastorio 2 makes the same change (furnace_to_assembler in its data-util.lua)
-- The recycler stays a furnace: it picks among the recycling recipes generated for every item (lib/recycling.lua), which nobody could pick by hand
-- In a save from before, the migrations docs say an entity whose type changes gets a new unit_number, and its ghosts can be removed (auxiliary/migrations.html)

local recycling = require("lib/recycling")

local furnace_assemblers = {}

-- Properties only a furnace has (FurnacePrototype in the 2.1 prototype docs); an assembling machine has no fixed slot counts, since its recipe sets them
local FURNACE_ONLY_PROPERTIES = {
    "result_inventory_size",
    "source_inventory_size",
    "cant_insert_at_source_message_key",
    "custom_input_slot_tooltip_key",
}

-- Turns every furnace in raw (a prototype table, like data.raw) that doesn't craft recycling into an assembling machine of the same name, which keeps everything else it had
-- A furnace whose name an assembling machine already has stays a furnace
-- Returns the names it turned, sorted
furnace_assemblers.convert = function(raw)
    local names = {}
    for name, furnace in pairs(raw.furnace or {}) do
        if not recycling.crafts_recycling(furnace) and (raw["assembling-machine"] or {})[name] == nil then
            table.insert(names, name)
        end
    end
    table.sort(names)
    if #names > 0 and raw["assembling-machine"] == nil then
        raw["assembling-machine"] = {}
    end
    for _, name in pairs(names) do
        local machine = raw.furnace[name]
        raw.furnace[name] = nil
        machine.type = "assembling-machine"
        for _, property in pairs(FURNACE_ONLY_PROPERTIES) do
            machine[property] = nil
        end
        raw["assembling-machine"][name] = machine
    end
    return names
end

return furnace_assemblers

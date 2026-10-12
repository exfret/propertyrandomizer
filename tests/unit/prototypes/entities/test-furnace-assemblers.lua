-- Plain-Lua regression test for src/prototypes/entities/furnace-assemblers.lua (not loaded by the mod)
-- Run from the mod root: lua tests/unit/prototypes/entities/test-furnace-assemblers.lua
--
-- Every furnace but the ones crafting recycling becomes an assembling machine of the same name, without the properties only furnaces have

local furnace_assemblers = require("src/prototypes/entities/furnace-assemblers")

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local function new_raw()
    return {
        furnace = {
            ["test-smelter"] = {
                type = "furnace",
                name = "test-smelter",
                crafting_categories = { "test-smelting" },
                crafting_speed = 2,
                result_inventory_size = 1,
                source_inventory_size = 1,
                cant_insert_at_source_message_key = "test.cant-smelt",
                custom_input_slot_tooltip_key = "test.smelt-input",
                next_upgrade = "test-better-smelter",
                fast_replaceable_group = "test-smelters",
                energy_source = {
                    type = "burner",
                },
            },
            ["test-better-smelter"] = {
                type = "furnace",
                name = "test-better-smelter",
                crafting_categories = { "test-smelting", "test-roasting" },
                result_inventory_size = 2,
                source_inventory_size = 1,
            },
            ["test-recycler"] = {
                type = "furnace",
                name = "test-recycler",
                crafting_categories = { "recycling" },
                result_inventory_size = 12,
                source_inventory_size = 1,
            },
        },
        ["assembling-machine"] = {
            ["test-assembler"] = {
                type = "assembling-machine",
                name = "test-assembler",
                crafting_categories = { "test-crafting" },
            },
        },
    }
end

test("furnaces become assembling machines of the same name, and the recycler stays a furnace", function()
    local raw = new_raw()
    local names = furnace_assemblers.convert(raw)
    assert(#names == 2 and names[1] == "test-better-smelter" and names[2] == "test-smelter", "turned " .. table.concat(names, ", "))
    assert(raw.furnace["test-smelter"] == nil and raw.furnace["test-better-smelter"] == nil, "the turned furnaces are no longer furnaces")
    assert(raw.furnace["test-recycler"] ~= nil and raw.furnace["test-recycler"].result_inventory_size == 12, "the recycler keeps its furnace prototype")
    assert(raw["assembling-machine"]["test-assembler"] ~= nil, "existing assembling machines stay")
    local smelter = raw["assembling-machine"]["test-smelter"]
    assert(smelter ~= nil and smelter.type == "assembling-machine" and smelter.name == "test-smelter", "the smelter is an assembling machine now")
    for _, property in pairs({ "result_inventory_size", "source_inventory_size", "cant_insert_at_source_message_key", "custom_input_slot_tooltip_key" }) do
        assert(smelter[property] == nil, property .. " is gone")
    end
    assert(smelter.crafting_speed == 2 and smelter.crafting_categories[1] == "test-smelting" and smelter.energy_source.type == "burner", "everything else stays")
    assert(smelter.next_upgrade == "test-better-smelter" and raw["assembling-machine"]["test-better-smelter"] ~= nil, "its upgrade is an assembling machine too")
end)

test("turning again changes nothing", function()
    local raw = new_raw()
    furnace_assemblers.convert(raw)
    local names = furnace_assemblers.convert(raw)
    assert(#names == 0, "nothing left to turn")
    assert(raw.furnace["test-recycler"] ~= nil, "the recycler is still a furnace")
end)

test("a furnace whose name an assembling machine has stays a furnace", function()
    local raw = new_raw()
    raw["assembling-machine"]["test-smelter"] = {
        type = "assembling-machine",
        name = "test-smelter",
        crafting_categories = { "test-crafting" },
    }
    local names = furnace_assemblers.convert(raw)
    assert(#names == 1 and names[1] == "test-better-smelter", "only the other one turns")
    assert(raw.furnace["test-smelter"] ~= nil and raw["assembling-machine"]["test-smelter"].crafting_categories[1] == "test-crafting", "neither is overwritten")
end)

test("a game without furnaces or assembling machines", function()
    local raw = {}
    assert(#furnace_assemblers.convert(raw) == 0 and raw["assembling-machine"] == nil, "nothing happens")
end)

print(num_passed .. " tests passed")

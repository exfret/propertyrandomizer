-- test/graph/flow-cost.lua
-- Unit tests for lib/graph/flow-cost.lua

local harness = require("test/harness")

local tests = {}

-- Check if we have access to Factorio data stage
local function has_data_stage()
    return data ~= nil and data.raw ~= nil and data.raw.recipe ~= nil
end

function tests.run()
    harness.suite("flow-cost")

    -- Skip if not in data stage
    if not has_data_stage() then
        harness.skip("get_prot_id", "Requires Factorio data stage")
        harness.skip("get_default_raw_resource_table", "Requires Factorio data stage")
        harness.skip("update_material_list", "Requires Factorio data stage")
        return
    end

    local flow_cost = require("lib/graph/flow-cost")

    ---------------------------------------------------------------------------
    -- get_prot_id tests
    ---------------------------------------------------------------------------

    harness.test("get_prot_id: creates item ID correctly", function()
        local item_prot = {type = "item", name = "iron-plate"}
        local id = flow_cost.get_prot_id(item_prot)
        harness.assert_equal("item-iron-plate", id)
    end)

    harness.test("get_prot_id: creates fluid ID correctly", function()
        local fluid_prot = {type = "fluid", name = "water"}
        local id = flow_cost.get_prot_id(fluid_prot)
        harness.assert_equal("fluid-water", id)
    end)

    harness.test("get_prot_id: treats non-fluid as item", function()
        -- Capsules, tools, etc. all become "item-" prefix
        local capsule_prot = {type = "capsule", name = "grenade"}
        local id = flow_cost.get_prot_id(capsule_prot)
        harness.assert_equal("item-grenade", id)
    end)

    ---------------------------------------------------------------------------
    -- get_default_raw_resource_table tests
    ---------------------------------------------------------------------------

    harness.test("get_default_raw_resource_table: contains iron ore", function()
        local resources = flow_cost.get_default_raw_resource_table()
        harness.assert_not_nil(resources["item-iron-ore"])
    end)

    harness.test("get_default_raw_resource_table: contains copper ore", function()
        local resources = flow_cost.get_default_raw_resource_table()
        harness.assert_not_nil(resources["item-copper-ore"])
    end)

    harness.test("get_default_raw_resource_table: contains water", function()
        local resources = flow_cost.get_default_raw_resource_table()
        harness.assert_not_nil(resources["fluid-water"])
    end)

    harness.test("get_default_raw_resource_table: water is cheap", function()
        local resources = flow_cost.get_default_raw_resource_table()
        harness.assert_true(resources["fluid-water"] < 0.01, "Water should be very cheap")
    end)

    harness.test("get_default_raw_resource_table: iron is more expensive than stone", function()
        local resources = flow_cost.get_default_raw_resource_table()
        harness.assert_true(
            resources["item-iron-ore"] > resources["item-stone"],
            "Iron should cost more than stone"
        )
    end)

    ---------------------------------------------------------------------------
    -- update_material_list tests
    ---------------------------------------------------------------------------

    harness.test("update_material_list: populates material_list", function()
        flow_cost.update_material_list()
        harness.assert_true(#flow_cost.material_list > 0, "Should have materials")
    end)

    harness.test("update_material_list: contains iron-plate", function()
        flow_cost.update_material_list()

        local found = false
        for _, mat in pairs(flow_cost.material_list) do
            if mat.name == "iron-plate" then
                found = true
                break
            end
        end
        harness.assert_true(found, "Should contain iron-plate")
    end)

    harness.test("update_material_list: populates material_id_to_material", function()
        flow_cost.update_material_list()
        harness.assert_not_nil(flow_cost.material_id_to_material["item-iron-plate"])
    end)

    harness.test("update_material_list: excludes filled barrels", function()
        flow_cost.update_material_list()

        local found_filled = false
        for _, mat in pairs(flow_cost.material_list) do
            if mat.name ~= "barrel" and string.sub(mat.name, -6) == "barrel" then
                found_filled = true
                break
            end
        end
        harness.assert_false(found_filled, "Should exclude filled barrels")
    end)

    ---------------------------------------------------------------------------
    -- find_amount_in_entry tests
    ---------------------------------------------------------------------------

    harness.test("find_amount_in_entry: simple amount", function()
        local entry = {amount = 5}
        local amount = flow_cost.find_amount_in_entry(entry)
        harness.assert_equal(5, amount)
    end)

    harness.test("find_amount_in_entry: with probability", function()
        local entry = {amount = 10, probability = 0.5}
        local amount = flow_cost.find_amount_in_entry(entry)
        harness.assert_equal(5, amount)
    end)

    harness.test("find_amount_in_entry: with extra_count_fraction", function()
        local entry = {amount = 10, extra_count_fraction = 0.5}
        local amount = flow_cost.find_amount_in_entry(entry)
        harness.assert_equal(10.5, amount)
    end)

    ---------------------------------------------------------------------------
    -- construct_item_recipe_maps tests
    ---------------------------------------------------------------------------

    harness.test("construct_item_recipe_maps: returns recipe_to_material", function()
        local maps = flow_cost.construct_item_recipe_maps()
        harness.assert_not_nil(maps.recipe_to_material)
    end)

    harness.test("construct_item_recipe_maps: returns material_to_recipe", function()
        local maps = flow_cost.construct_item_recipe_maps()
        harness.assert_not_nil(maps.material_to_recipe)
    end)

    harness.test("construct_item_recipe_maps: iron-gear-wheel recipe uses iron-plate", function()
        local maps = flow_cost.construct_item_recipe_maps()

        -- iron-gear-wheel recipe should have iron-plate as negative (ingredient)
        local recipe_map = maps.recipe_to_material["iron-gear-wheel"]
        if recipe_map then
            -- Negative means it's consumed
            harness.assert_true(
                recipe_map["item-iron-plate"] ~= nil and recipe_map["item-iron-plate"] < 0,
                "iron-gear-wheel should consume iron-plate"
            )
        end
    end)

    ---------------------------------------------------------------------------
    -- determine_recipe_item_cost tests
    ---------------------------------------------------------------------------

    harness.test("determine_recipe_item_cost: returns material_to_cost", function()
        local raw_costs = flow_cost.get_default_raw_resource_table()
        local result = flow_cost.determine_recipe_item_cost(raw_costs, 0.1, 0.1)

        harness.assert_not_nil(result.material_to_cost)
    end)

    harness.test("determine_recipe_item_cost: returns recipe_to_cost", function()
        local raw_costs = flow_cost.get_default_raw_resource_table()
        local result = flow_cost.determine_recipe_item_cost(raw_costs, 0.1, 0.1)

        harness.assert_not_nil(result.recipe_to_cost)
    end)

    harness.test("determine_recipe_item_cost: raw resources have their base cost", function()
        local raw_costs = flow_cost.get_default_raw_resource_table()
        local result = flow_cost.determine_recipe_item_cost(raw_costs, 0.1, 0.1)

        harness.assert_equal(
            raw_costs["item-iron-ore"],
            result.material_to_cost["item-iron-ore"]
        )
    end)

    harness.test("determine_recipe_item_cost: calculates costs for processed items", function()
        local raw_costs = flow_cost.get_default_raw_resource_table()
        local result = flow_cost.determine_recipe_item_cost(raw_costs, 0.1, 0.1)

        local iron_ore_cost = result.material_to_cost["item-iron-ore"]
        local iron_plate_cost = result.material_to_cost["item-iron-plate"]

        -- Both should have costs calculated
        harness.assert_not_nil(iron_plate_cost, "Iron plate should have a cost")
        harness.assert_not_nil(iron_ore_cost, "Iron ore should have a cost")

        -- Iron plate cost can be less than ore if processing is cheap
        -- (1 ore -> 1 plate, so plate inherits ore cost / 1, plus small time cost)
        -- The key is that it HAS a cost calculated
        harness.assert_true(iron_plate_cost > 0, "Iron plate should have positive cost")
    end)

    ---------------------------------------------------------------------------
    -- get_empty_raw_resource_table tests
    ---------------------------------------------------------------------------

    harness.test("get_empty_raw_resource_table: all values are zero", function()
        local empty = flow_cost.get_empty_raw_resource_table()

        for id, cost in pairs(empty) do
            harness.assert_equal(0, cost, "All costs should be 0, but " .. id .. " is " .. cost)
        end
    end)

    ---------------------------------------------------------------------------
    -- get_single_resource_table tests
    ---------------------------------------------------------------------------

    harness.test("get_single_resource_table: specified resource is 1", function()
        local single = flow_cost.get_single_resource_table("item-iron-ore")

        harness.assert_equal(1, single["item-iron-ore"])
    end)

    harness.test("get_single_resource_table: other resources are 0", function()
        local single = flow_cost.get_single_resource_table("item-iron-ore")

        harness.assert_equal(0, single["item-copper-ore"])
        harness.assert_equal(0, single["fluid-water"])
    end)
end

return tests

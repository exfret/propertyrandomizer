-- test/logic/lookup.lua
-- Unit tests for new-lib/logic/lookup/

local harness = require("test/harness")

local tests = {}

-- Check if we have access to Factorio data stage
local function has_data_stage()
    return data ~= nil and data.raw ~= nil and data.raw.item ~= nil
end

function tests.run()
    harness.suite("logic/lookup")

    -- Skip if not in data stage
    if not has_data_stage() then
        harness.skip("load_lookups", "Requires Factorio data stage")
        harness.skip("items lookup", "Requires Factorio data stage")
        harness.skip("recipes lookup", "Requires Factorio data stage")
        return
    end

    local lu = require("new-lib/logic/lookup/init")

    ---------------------------------------------------------------------------
    -- load_lookups tests
    ---------------------------------------------------------------------------

    harness.test("load_lookups: completes without error", function()
        harness.assert_no_error(function()
            lu.load_lookups()
        end)
    end)

    ---------------------------------------------------------------------------
    -- Stage 1: Raw prototype collections
    ---------------------------------------------------------------------------

    harness.test("stage1: rooms is populated", function()
        harness.assert_not_nil(lu.rooms)

        -- Rooms are keyed by gutils.key(prot) = "type: name"
        -- Check we have at least one room
        local count = 0
        for _ in pairs(lu.rooms) do count = count + 1 end
        harness.assert_true(count > 0, "Should have at least one room")

        -- Check for nauvis (keyed as "planet: nauvis")
        local found_nauvis = false
        for key, room in pairs(lu.rooms) do
            if room.name == "nauvis" then
                found_nauvis = true
                break
            end
        end
        harness.assert_true(found_nauvis, "Should have nauvis room")
    end)

    harness.test("stage1: items is populated", function()
        harness.assert_not_nil(lu.items)

        -- Check for common items
        local count = 0
        for _ in pairs(lu.items) do count = count + 1 end
        harness.assert_true(count > 50, "Should have many items")
    end)

    harness.test("stage1: items contains iron-plate", function()
        harness.assert_not_nil(lu.items["iron-plate"])
    end)

    harness.test("stage1: fluids is populated", function()
        harness.assert_not_nil(lu.fluids)
        harness.assert_not_nil(lu.fluids["water"])
    end)

    harness.test("stage1: recipes is populated", function()
        harness.assert_not_nil(lu.recipes)

        local count = 0
        for _ in pairs(lu.recipes) do count = count + 1 end
        harness.assert_true(count > 50, "Should have many recipes")
    end)

    harness.test("stage1: recipes contains iron-gear-wheel", function()
        harness.assert_not_nil(lu.recipes["iron-gear-wheel"])
    end)

    harness.test("stage1: techs is populated", function()
        harness.assert_not_nil(lu.techs)

        local count = 0
        for _ in pairs(lu.techs) do count = count + 1 end
        harness.assert_true(count > 20, "Should have many technologies")
    end)

    harness.test("stage1: entities is populated", function()
        harness.assert_not_nil(lu.entities)
    end)

    ---------------------------------------------------------------------------
    -- Stage 2: Filtered/processed collections
    ---------------------------------------------------------------------------

    harness.test("stage2: recipe_to_techs maps recipes to unlocking techs", function()
        harness.assert_not_nil(lu.recipe_to_techs)
    end)

    harness.test("stage2: rcats (recipe categories) is populated", function()
        harness.assert_not_nil(lu.rcats)
    end)

    harness.test("stage2: buildables is populated", function()
        harness.assert_not_nil(lu.buildables)
    end)

    harness.test("stage2: materials is populated", function()
        harness.assert_not_nil(lu.materials)
    end)

    ---------------------------------------------------------------------------
    -- Stage 3: Complex lookups
    ---------------------------------------------------------------------------

    harness.test("stage3: rcat_to_crafters maps categories to machines", function()
        harness.assert_not_nil(lu.rcat_to_crafters)
    end)

    harness.test("stage3: mat_recipe_map exists", function()
        harness.assert_not_nil(lu.mat_recipe_map)
    end)

    ---------------------------------------------------------------------------
    -- Stage 4: Derived calculations
    ---------------------------------------------------------------------------

    harness.test("stage4: weight calculations exist", function()
        harness.assert_not_nil(lu.weight)
    end)

    ---------------------------------------------------------------------------
    -- Lookup integrity tests
    ---------------------------------------------------------------------------

    harness.test("integrity: all items have names", function()
        for name, item in pairs(lu.items) do
            harness.assert_equal(name, item.name, "Item key should match item.name")
        end
    end)

    harness.test("integrity: all recipes have names", function()
        for name, recipe in pairs(lu.recipes) do
            harness.assert_equal(name, recipe.name, "Recipe key should match recipe.name")
        end
    end)

    harness.test("integrity: all fluids have names", function()
        for name, fluid in pairs(lu.fluids) do
            harness.assert_equal(name, fluid.name, "Fluid key should match fluid.name")
        end
    end)

    harness.test("integrity: techs have prerequisites field", function()
        for name, tech in pairs(lu.techs) do
            -- prerequisites can be nil (for starting techs) but if present should be a table
            if tech.prerequisites ~= nil then
                harness.assert_type("table", tech.prerequisites)
            end
        end
    end)
end

return tests

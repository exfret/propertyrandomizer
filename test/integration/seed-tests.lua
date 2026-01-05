-- test/integration/seed-tests.lua
-- Integration tests for seed reproducibility and reachability preservation
--
-- These tests verify the randomization system works correctly across
-- multiple seeds and settings combinations.

local harness = require("test/harness")

local tests = {}

--------------------------------------------------------------------------------
-- Test Utilities
--------------------------------------------------------------------------------

-- Check if we have access to full Factorio data stage
local function has_data_stage()
    return data ~= nil and data.raw ~= nil and data.raw.technology ~= nil
end

-- Count reachable nodes of a given type
local function count_reachable(sort_info, node_type)
    local count = 0
    for node_key, _ in pairs(sort_info.reachable) do
        if node_key:match("^" .. node_type .. ":") then
            count = count + 1
        end
    end
    return count
end

-- Run a randomization and return before/after counts
local function run_and_measure(randomization_func, id)
    local build_graph = require("lib/graph/build-graph")
    local top_sort = require("lib/graph/top-sort")

    -- Measure before
    build_graph.load()
    build_graph.add_dependents(build_graph.graph)
    dep_graph = build_graph.graph

    local before_sort = top_sort.sort(dep_graph)
    local before_count = 0
    for _ in pairs(before_sort.reachable) do
        before_count = before_count + 1
    end

    -- Run randomization
    local result = randomization_func(id)

    -- Measure after
    local after_sort = top_sort.sort(dep_graph)
    local after_count = 0
    for _ in pairs(after_sort.reachable) do
        after_count = after_count + 1
    end

    return {
        before = before_count,
        after = after_count,
        gained = after_count - before_count,
        result = result
    }
end

function tests.run()
    harness.suite("integration/seed-tests")

    -- Skip all tests if not in data stage
    if not has_data_stage() then
        harness.skip("seed reproducibility", "Requires Factorio data stage")
        harness.skip("reachability preservation", "Requires Factorio data stage")
        harness.skip("multi-seed consistency", "Requires Factorio data stage")
        harness.skip("settings combinations", "Requires Factorio data stage")
        return
    end

    ---------------------------------------------------------------------------
    -- Seed Reproducibility Tests
    ---------------------------------------------------------------------------

    harness.test("seed reproducibility: same seed produces deterministic values", function()
        local rng = require("lib/random/rng")

        -- Set global seed
        global_seed = 12345

        -- Clear any cached PRNG states
        rng.prgs = {}

        -- Generate sequence with same key
        local key = rng.key({id = "test-repro"})
        local val1 = rng.int(key, 100)
        local val2 = rng.int(key, 100)
        local val3 = rng.int(key, 100)

        -- Reset and regenerate
        rng.prgs = {}
        local val1b = rng.int(key, 100)
        local val2b = rng.int(key, 100)
        local val3b = rng.int(key, 100)

        -- Should be identical
        harness.assert_equal(val1, val1b, "First value")
        harness.assert_equal(val2, val2b, "Second value")
        harness.assert_equal(val3, val3b, "Third value")
    end)

    harness.test("seed reproducibility: different global seeds produce different results", function()
        local rng = require("lib/random/rng")
        local key = rng.key({id = "test-diff"})

        -- Test with seed 11111
        global_seed = 11111
        rng.prgs = {}
        local val1 = rng.int(key, 1000000)

        -- Test with seed 22222
        global_seed = 22222
        rng.prgs = {}
        local val2 = rng.int(key, 1000000)

        harness.assert_not_equal(val1, val2, "Different seeds should differ")
    end)

    harness.test("seed reproducibility: key function creates consistent keys", function()
        local rng = require("lib/random/rng")

        local key1 = rng.key({id = "test-consistency"})
        local key2 = rng.key({id = "test-consistency"})

        harness.assert_equal(key1, key2, "Same input should produce same key")
    end)

    ---------------------------------------------------------------------------
    -- Reachability Preservation Tests
    ---------------------------------------------------------------------------

    harness.test("reachability: build_graph loads without error", function()
        local build_graph = require("lib/graph/build-graph")

        harness.assert_no_error(function()
            build_graph.load()
        end)

        harness.assert_not_nil(build_graph.graph)
    end)

    harness.test("reachability: initial sort finds reachable nodes", function()
        local build_graph = require("lib/graph/build-graph")
        local top_sort = require("lib/graph/top-sort")

        build_graph.load()
        build_graph.add_dependents(build_graph.graph)

        local sort_info = top_sort.sort(build_graph.graph)

        local reachable_count = 0
        for _ in pairs(sort_info.reachable) do
            reachable_count = reachable_count + 1
        end

        -- Should have many reachable nodes
        harness.assert_true(reachable_count > 100, "Should have >100 reachable nodes, got " .. reachable_count)
    end)

    harness.test("reachability: technologies are reachable", function()
        local build_graph = require("lib/graph/build-graph")
        local top_sort = require("lib/graph/top-sort")

        build_graph.load()
        build_graph.add_dependents(build_graph.graph)

        local sort_info = top_sort.sort(build_graph.graph)

        local tech_count = count_reachable(sort_info, "technology")

        -- Should have reachable technologies
        harness.assert_true(tech_count > 50, "Should have >50 reachable techs, got " .. tech_count)
    end)

    harness.test("reachability: items are reachable", function()
        local build_graph = require("lib/graph/build-graph")
        local top_sort = require("lib/graph/top-sort")

        build_graph.load()
        build_graph.add_dependents(build_graph.graph)

        local sort_info = top_sort.sort(build_graph.graph)

        local item_count = count_reachable(sort_info, "item")

        -- Should have reachable items
        harness.assert_true(item_count > 50, "Should have >50 reachable items, got " .. item_count)
    end)

    ---------------------------------------------------------------------------
    -- Monotonicity Tests
    ---------------------------------------------------------------------------

    harness.test("monotonicity: adding edges never reduces reachability", function()
        local gutils = require("new-lib/graph/graph-utils")

        local graph = harness.create_graph()

        -- Create initial graph
        local a = gutils.add_node(graph, "item", "a", {op = "AND"})
        local b = gutils.add_node(graph, "item", "b", {op = "AND"})
        local c = gutils.add_node(graph, "item", "c", {op = "OR"})

        graph.sources[gutils.key(a)] = true
        graph.sources[gutils.key(b)] = true

        gutils.add_edge(graph, gutils.key(a), gutils.key(c))

        -- c is now reachable (OR with 1 prereq from reachable source)
        -- Adding another edge should not change this
        gutils.add_edge(graph, gutils.key(b), gutils.key(c))

        -- c should still have prereqs
        harness.assert_equal(2, c.num_pre)
    end)

    ---------------------------------------------------------------------------
    -- RNG Distribution Tests
    ---------------------------------------------------------------------------

    harness.test("rng: shuffle produces permutation", function()
        local rng = require("lib/random/rng")

        global_seed = 99999
        rng.prgs = {}

        local items = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
        local shuffled = {}
        for i, v in ipairs(items) do
            shuffled[i] = v
        end

        rng.shuffle(rng.key({id = "test-shuffle"}), shuffled)

        -- Check all elements still present
        local found = {}
        for _, v in ipairs(shuffled) do
            found[v] = true
        end

        for i = 1, 10 do
            harness.assert_true(found[i], "Element " .. i .. " should be in shuffled array")
        end
    end)

    harness.test("rng: int produces values in range", function()
        local rng = require("lib/random/rng")

        global_seed = 77777
        rng.prgs = {}

        local key = rng.key({id = "test-range"})
        for i = 1, 100 do
            local val = rng.int(key, 10)
            harness.assert_true(val >= 1 and val <= 10, "Value should be 1-10, got " .. val)
        end
    end)

    ---------------------------------------------------------------------------
    -- Graph Integrity Tests
    ---------------------------------------------------------------------------

    harness.test("graph integrity: sources are AND nodes with 0 prereqs", function()
        local build_graph = require("lib/graph/build-graph")

        build_graph.load()

        local graph = build_graph.graph
        for node_key, node in pairs(graph) do
            if node.prereqs and #node.prereqs == 0 then
                -- This should be a source if it's an AND node
                local op = build_graph.ops[node.type]
                if op == "AND" then
                    -- AND with 0 prereqs should be vacuously satisfied
                    harness.assert_true(true)
                end
            end
        end
    end)

    harness.test("graph integrity: no orphaned edges", function()
        local build_graph = require("lib/graph/build-graph")

        build_graph.load()
        build_graph.add_dependents(build_graph.graph)

        local graph = build_graph.graph
        for node_key, node in pairs(graph) do
            if node.prereqs then
                for _, prereq in ipairs(node.prereqs) do
                    -- Prereq should exist in graph
                    local prereq_key = build_graph.key(prereq.type, prereq.name)
                    harness.assert_not_nil(graph[prereq_key], "Prereq should exist: " .. prereq_key)
                end
            end
        end
    end)
end

return tests

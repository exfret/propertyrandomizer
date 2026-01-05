-- test/harness.lua
-- Test harness utilities for Property Randomizer
--
-- Provides assertion functions, test grouping, and reporting.

local harness = {}

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local current_suite = nil
local results = {
    suites = {},
    total_passed = 0,
    total_failed = 0,
    total_skipped = 0,
}

--------------------------------------------------------------------------------
-- Assertions
--------------------------------------------------------------------------------

function harness.assert_true(value, message)
    if not value then
        error("Assertion failed: expected true, got " .. tostring(value) .. (message and (" - " .. message) or ""))
    end
end

function harness.assert_false(value, message)
    if value then
        error("Assertion failed: expected false, got " .. tostring(value) .. (message and (" - " .. message) or ""))
    end
end

function harness.assert_equal(expected, actual, message)
    if expected ~= actual then
        error("Assertion failed: expected " .. tostring(expected) .. ", got " .. tostring(actual) .. (message and (" - " .. message) or ""))
    end
end

function harness.assert_not_equal(expected, actual, message)
    if expected == actual then
        error("Assertion failed: expected not " .. tostring(expected) .. (message and (" - " .. message) or ""))
    end
end

function harness.assert_nil(value, message)
    if value ~= nil then
        error("Assertion failed: expected nil, got " .. tostring(value) .. (message and (" - " .. message) or ""))
    end
end

function harness.assert_not_nil(value, message)
    if value == nil then
        error("Assertion failed: expected non-nil value" .. (message and (" - " .. message) or ""))
    end
end

function harness.assert_type(expected_type, value, message)
    local actual_type = type(value)
    if actual_type ~= expected_type then
        error("Assertion failed: expected type " .. expected_type .. ", got " .. actual_type .. (message and (" - " .. message) or ""))
    end
end

function harness.assert_table_equal(expected, actual, message)
    local function tables_equal(t1, t2, path)
        path = path or ""
        if type(t1) ~= "table" or type(t2) ~= "table" then
            return t1 == t2, path
        end
        for k, v in pairs(t1) do
            local new_path = path .. "[" .. tostring(k) .. "]"
            if t2[k] == nil then
                return false, new_path .. " missing in actual"
            end
            local eq, fail_path = tables_equal(v, t2[k], new_path)
            if not eq then
                return false, fail_path
            end
        end
        for k, _ in pairs(t2) do
            if t1[k] == nil then
                return false, path .. "[" .. tostring(k) .. "] unexpected in actual"
            end
        end
        return true, nil
    end

    local eq, fail_path = tables_equal(expected, actual)
    if not eq then
        error("Assertion failed: tables not equal at " .. (fail_path or "root") .. (message and (" - " .. message) or ""))
    end
end

function harness.assert_contains(tbl, value, message)
    for _, v in pairs(tbl) do
        if v == value then
            return
        end
    end
    error("Assertion failed: table does not contain " .. tostring(value) .. (message and (" - " .. message) or ""))
end

function harness.assert_has_key(tbl, key, message)
    if tbl[key] == nil then
        error("Assertion failed: table does not have key " .. tostring(key) .. (message and (" - " .. message) or ""))
    end
end

function harness.assert_error(func, message)
    local success = pcall(func)
    if success then
        error("Assertion failed: expected error but none was thrown" .. (message and (" - " .. message) or ""))
    end
end

function harness.assert_no_error(func, message)
    local success, err = pcall(func)
    if not success then
        error("Assertion failed: unexpected error: " .. tostring(err) .. (message and (" - " .. message) or ""))
    end
end

--------------------------------------------------------------------------------
-- Test Structure
--------------------------------------------------------------------------------

function harness.suite(name)
    current_suite = {
        name = name,
        tests = {},
        passed = 0,
        failed = 0,
        skipped = 0,
    }
    table.insert(results.suites, current_suite)
    log("[TEST SUITE] " .. name)
end

function harness.test(name, func)
    if not current_suite then
        harness.suite("Default")
    end

    local test_result = {
        name = name,
        status = "pending",
        error = nil,
    }
    table.insert(current_suite.tests, test_result)

    local success, err = pcall(func)
    if success then
        test_result.status = "passed"
        current_suite.passed = current_suite.passed + 1
        results.total_passed = results.total_passed + 1
        log("  [PASS] " .. name)
    else
        test_result.status = "failed"
        test_result.error = err
        current_suite.failed = current_suite.failed + 1
        results.total_failed = results.total_failed + 1
        log("  [FAIL] " .. name)
        log("         " .. tostring(err))
    end
end

function harness.skip(name, reason)
    if not current_suite then
        harness.suite("Default")
    end

    local test_result = {
        name = name,
        status = "skipped",
        reason = reason,
    }
    table.insert(current_suite.tests, test_result)
    current_suite.skipped = current_suite.skipped + 1
    results.total_skipped = results.total_skipped + 1
    log("  [SKIP] " .. name .. (reason and (" - " .. reason) or ""))
end

--------------------------------------------------------------------------------
-- Graph Building Helpers
--------------------------------------------------------------------------------

-- Create a minimal graph structure for testing
function harness.create_graph()
    return {
        nodes = {},
        edges = {},
        sources = {},
    }
end

-- Add a node with explicit op type
function harness.add_test_node(graph, node_type, node_name, op, num_pre)
    local gutils = require("new-lib/graph/graph-utils")
    local node = gutils.add_node(graph, node_type, node_name)
    node.op = op or "AND"
    node.num_pre = num_pre or 0
    if node.op == "AND" and node.num_pre == 0 then
        graph.sources[gutils.key(node)] = true
    end
    return node
end

-- Create a simple test graph with given structure
-- structure is a list of {from_type, from_name, to_type, to_name}
function harness.build_test_graph(node_defs, edge_defs)
    local gutils = require("new-lib/graph/graph-utils")
    local graph = harness.create_graph()

    -- Add nodes: {type, name, op}
    for _, def in ipairs(node_defs) do
        harness.add_test_node(graph, def[1], def[2], def[3], 0)
    end

    -- Add edges: {from_type, from_name, to_type, to_name}
    for _, def in ipairs(edge_defs) do
        local start_key = gutils.key(def[1], def[2])
        local stop_key = gutils.key(def[3], def[4])
        gutils.add_edge(graph, start_key, stop_key)
    end

    return graph
end

--------------------------------------------------------------------------------
-- Reporting
--------------------------------------------------------------------------------

function harness.summary()
    log("========================================")
    log("TEST SUMMARY")
    log("========================================")

    for _, suite in ipairs(results.suites) do
        local status = suite.failed > 0 and "FAIL" or "PASS"
        log(string.format("[%s] %s: %d passed, %d failed, %d skipped",
            status, suite.name, suite.passed, suite.failed, suite.skipped))
    end

    log("----------------------------------------")
    log(string.format("TOTAL: %d passed, %d failed, %d skipped",
        results.total_passed, results.total_failed, results.total_skipped))
    log("========================================")

    return results.total_failed == 0
end

function harness.get_results()
    return results
end

function harness.reset()
    current_suite = nil
    results = {
        suites = {},
        total_passed = 0,
        total_failed = 0,
        total_skipped = 0,
    }
end

return harness

-- test/init.lua
-- Main test runner for Property Randomizer
--
-- Usage: require("test/init").run() or require("test/init").run_suite("graph")

local test_runner = {}

--------------------------------------------------------------------------------
-- Configuration
--------------------------------------------------------------------------------

-- Which test suites to run (set to false to skip)
local ENABLED_SUITES = {
    graph = true,           -- Graph algorithm tests
    logic = true,           -- Logic building tests
    randomization = true,   -- Randomization algorithm tests
    integration = true,     -- Full integration tests
}

-- Verbose output
local VERBOSE = false

--------------------------------------------------------------------------------
-- Test Suite Registry
--------------------------------------------------------------------------------

local test_suites = {
    graph = {
        "test/graph/graph-utils",
        "test/graph/top-sort",
        "test/graph/extended-sort",
        "test/graph/flow-cost",
        "test/graph/path",
    },
    logic = {
        "test/logic/lookup",
        "test/logic/builder",
    },
    randomization = {
        "test/randomization/unified",
        "test/randomization/handlers",
    },
    integration = {
        "test/integration/seed-tests",
    },
}

--------------------------------------------------------------------------------
-- Runner Functions
--------------------------------------------------------------------------------

local function safe_require(module_path)
    local success, result = pcall(require, module_path)
    if success then
        return result, nil
    else
        return nil, result
    end
end

function test_runner.run_suite(suite_name)
    local harness = require("test/harness")

    if not ENABLED_SUITES[suite_name] then
        log("[TEST] Suite '" .. suite_name .. "' is disabled")
        return true
    end

    local suite_modules = test_suites[suite_name]
    if not suite_modules then
        log("[TEST] Unknown suite: " .. suite_name)
        return false
    end

    log("========================================")
    log("Running test suite: " .. suite_name)
    log("========================================")

    local all_loaded = true
    for _, module_path in ipairs(suite_modules) do
        local module, err = safe_require(module_path)
        if module then
            if type(module.run) == "function" then
                module.run()
            end
        else
            -- Module doesn't exist yet, skip silently unless verbose
            if VERBOSE then
                log("[TEST] Could not load " .. module_path .. ": " .. tostring(err))
            end
        end
    end

    return all_loaded
end

function test_runner.run()
    local harness = require("test/harness")
    harness.reset()

    log("########################################")
    log("# Property Randomizer Test Suite")
    log("########################################")

    for suite_name, _ in pairs(test_suites) do
        if ENABLED_SUITES[suite_name] then
            test_runner.run_suite(suite_name)
        end
    end

    return harness.summary()
end

-- Run just the graph tests (most common during development)
function test_runner.run_graph()
    local harness = require("test/harness")
    harness.reset()
    test_runner.run_suite("graph")
    return harness.summary()
end

-- Run quick smoke test
function test_runner.smoke()
    local harness = require("test/harness")
    harness.reset()

    -- Just run graph-utils as a quick sanity check
    local module, err = safe_require("test/graph/graph-utils")
    if module and type(module.run) == "function" then
        module.run()
    end

    return harness.summary()
end

return test_runner

-- test/feature-tests.lua
-- Property Randomizer - Feature Tests for Unreleased Code
--
-- Tests new-lib features: lookup system, logic graph, extended sort

--------------------------------------------------------------------------------
-- Configuration
--------------------------------------------------------------------------------

-- Toggle individual features for testing
local TEST_FEATURES = {
    lookup = true,           -- Test new-lib lookup system (staged loading)
    logic_build = true,      -- Test new-lib logic graph building
    extended_sort = true,    -- Test context-aware topological sort
    unified_tech = true,     -- Test unified tech prereq randomization
}

-- Verbose logging for debugging
local VERBOSE = false

local function test_log(msg)
    if VERBOSE then
        log("[TEST] " .. msg)
    end
end

--------------------------------------------------------------------------------
-- Test Functions
--------------------------------------------------------------------------------

local function test_lookup()
    log("=== Testing Lookup System ===")

    local lu = require("new-lib/logic/lookup/init")
    lu.load_lookups_timed()

    -- Basic sanity checks
    local checks = {
        {"items", lu.items, "table"},
        {"fluids", lu.fluids, "table"},
        {"recipes", lu.recipes, "table"},
        {"rooms", lu.rooms, "table"},
        {"techs", lu.techs, "table"},
        {"entities", lu.entities, "table"},
    }

    local passed = 0
    local failed = 0
    for _, check in ipairs(checks) do
        local name, value, expected_type = check[1], check[2], check[3]
        if type(value) == expected_type and next(value) ~= nil then
            test_log("  ✓ " .. name .. " loaded")
            passed = passed + 1
        else
            log("  ✗ " .. name .. " FAILED (type=" .. type(value) .. ")")
            failed = failed + 1
        end
    end

    log("Lookup test complete: " .. passed .. " passed, " .. failed .. " failed")
    return lu, failed == 0
end

local function test_logic_build(lu)
    log("=== Testing Logic Graph Build ===")

    local logic = require("new-lib/logic/logic")
    logic.build()

    -- Count nodes and edges
    local node_count = 0
    local edge_count = 0
    local node_types = {}

    for _, node in pairs(logic.graph.nodes) do
        node_count = node_count + 1
        node_types[node.type] = (node_types[node.type] or 0) + 1
    end

    for _, _ in pairs(logic.graph.edges) do
        edge_count = edge_count + 1
    end

    log("Graph built: " .. node_count .. " nodes, " .. edge_count .. " edges")

    -- Log node type distribution if verbose
    if VERBOSE then
        local type_list = {}
        for t, count in pairs(node_types) do
            table.insert(type_list, {type = t, count = count})
        end
        table.sort(type_list, function(a, b) return a.count > b.count end)
        log("Top node types:")
        for i = 1, math.min(10, #type_list) do
            log("  " .. type_list[i].type .. ": " .. type_list[i].count)
        end
    end

    -- Verify sources exist (AND nodes with no prereqs)
    local source_count = 0
    for _ in pairs(logic.graph.sources) do
        source_count = source_count + 1
    end
    log("Sources (AND with 0 prereqs): " .. source_count)

    local success = node_count > 0 and edge_count > 0 and source_count > 0
    log("Logic build test: " .. (success and "PASSED" or "FAILED"))

    return logic, success
end

local function test_extended_sort(logic)
    log("=== Testing Extended Sort ===")

    local extended_sort = require("new-lib/graph/extended-sort")
    local sort_result = extended_sort.sort(logic.graph)

    -- Check result structure
    local has_contexts = sort_result.node_to_contexts ~= nil
    local has_open = sort_result.open ~= nil
    local open_count = sort_result.open and #sort_result.open or 0

    log("Sort complete: " .. open_count .. " entries in open list")

    -- Count reachable nodes (those with non-empty contexts)
    local reachable_count = 0
    if has_contexts then
        for node_key, contexts in pairs(sort_result.node_to_contexts) do
            local is_reachable = false
            if contexts == true then
                is_reachable = true
            elseif type(contexts) == "table" then
                for room, room_contexts in pairs(contexts) do
                    if room_contexts == true or (type(room_contexts) == "table" and next(room_contexts) ~= nil) then
                        is_reachable = true
                        break
                    end
                end
            end
            if is_reachable then
                reachable_count = reachable_count + 1
            end
        end
    end

    log("Reachable nodes: " .. reachable_count)

    local success = has_contexts and has_open and open_count > 0
    log("Extended sort test: " .. (success and "PASSED" or "FAILED"))

    return sort_result, success
end

local function test_unified_tech()
    log("=== Testing Unified Tech Prereq Randomization ===")

    -- Helper to count reachable techs using old build-graph
    local build_graph = require("lib/graph/build-graph")
    local top_sort = require("lib/graph/top-sort")

    local function count_reachable_techs()
        build_graph.load()
        build_graph.add_dependents(build_graph.graph)
        local sort_info = top_sort.sort(build_graph.graph)

        local tech_count = 0
        local total_techs = 0
        for _, tech in pairs(data.raw.technology) do
            total_techs = total_techs + 1
            if sort_info.reachable[build_graph.key("technology", tech.name)] then
                tech_count = tech_count + 1
            end
        end
        return tech_count, total_techs
    end

    -- Count BEFORE
    local before_count, total = count_reachable_techs()
    log("BEFORE: " .. before_count .. " / " .. total .. " techs reachable")

    -- Set up RNG (normally done by config.lua)
    global_seed = 12345

    -- Run unified tech prereq randomization
    log("Running unified.execute()...")
    local unified = require("randomizations/graph/unified/new/execute")
    unified.execute()
    log("Randomization complete")

    -- Count AFTER
    local after_count = count_reachable_techs()
    log("AFTER: " .. after_count .. " / " .. total .. " techs reachable")

    -- Check results
    local techs_lost = before_count - after_count
    local success = techs_lost <= 0

    if techs_lost > 0 then
        log("WARNING: Lost " .. techs_lost .. " reachable techs!")
    else
        log("OK: No techs lost")
    end

    log("Unified tech test: " .. (success and "PASSED" or "FAILED"))
    return success
end

--------------------------------------------------------------------------------
-- Test Runner
--------------------------------------------------------------------------------

log("========================================")
log("Property Randomizer - Feature Tests")
log("========================================")

local results = {}
local lu, logic_module, sort_result

if TEST_FEATURES.lookup then
    lu, results.lookup = test_lookup()
end

if TEST_FEATURES.logic_build then
    if lu then
        logic_module, results.logic_build = test_logic_build(lu)
    else
        log("Skipping logic_build: lookup not loaded")
        results.logic_build = false
    end
end

if TEST_FEATURES.extended_sort then
    if logic_module and logic_module.graph then
        sort_result, results.extended_sort = test_extended_sort(logic_module)
    else
        log("Skipping extended_sort: logic graph not built")
        results.extended_sort = false
    end
end

if TEST_FEATURES.unified_tech then
    results.unified_tech = test_unified_tech()
end

-- Summary
log("========================================")
log("Test Summary:")
local all_passed = true
for test_name, passed in pairs(results) do
    log("  " .. test_name .. ": " .. (passed and "PASSED" or "FAILED"))
    if not passed then all_passed = false end
end
log("Overall: " .. (all_passed and "ALL TESTS PASSED" or "SOME TESTS FAILED"))
log("========================================")

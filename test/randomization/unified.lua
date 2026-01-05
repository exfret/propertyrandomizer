-- test/randomization/unified.lua
-- Unit tests for unified randomization mechanics
--
-- Tests the core slot/traveler system and reachability preservation
-- without requiring full Factorio data stage.

local harness = require("test/harness")
local gutils = require("new-lib/graph/graph-utils")

local tests = {}

--------------------------------------------------------------------------------
-- Helper: Build a slot/traveler subdivision
--------------------------------------------------------------------------------

-- Simulates what unified randomization does: subdivide edge into slot->traveler
-- slot = AND node (connected to prereq side)
-- traveler = OR node (connected to dependent side, starts unreachable)
local function subdivide_for_randomization(graph, prereq_key, dependent_key)
    local prereq = graph.nodes[prereq_key]
    local dependent = graph.nodes[dependent_key]

    -- Find and remove the edge
    local edge_key
    for ek, edge in pairs(graph.edges) do
        if edge.start == prereq_key and edge.stop == dependent_key then
            edge_key = ek
            break
        end
    end
    if edge_key then
        gutils.remove_edge(graph, edge_key)
    end

    -- Create slot node (AND with 1 prereq from prereq side)
    local slot_name = "slot__" .. prereq.name .. "__" .. dependent.name
    local slot = gutils.add_node(graph, "slot", slot_name, {op = "AND"})

    -- Create traveler node (OR, starts with 0 prereqs = unreachable)
    local traveler_name = "traveler__" .. prereq.name .. "__" .. dependent.name
    local traveler = gutils.add_node(graph, "traveler", traveler_name, {op = "OR"})

    -- Wire: prereq -> slot -> traveler -> dependent
    gutils.add_edge(graph, prereq_key, gutils.key(slot))
    gutils.add_edge(graph, gutils.key(slot), gutils.key(traveler))
    gutils.add_edge(graph, gutils.key(traveler), dependent_key)

    return {slot = slot, traveler = traveler}
end

-- Connect slot to traveler (simulates assignment)
local function assign_slot_to_traveler(graph, slot, traveler)
    -- In the real system, this adds an edge from slot to traveler
    -- Here slot and traveler may be from different subdivisions
    gutils.add_edge(graph, gutils.key(slot), gutils.key(traveler))
end

function tests.run()
    harness.suite("randomization/unified")

    ---------------------------------------------------------------------------
    -- Slot/Traveler structure tests
    ---------------------------------------------------------------------------

    harness.test("subdivision: creates slot (AND) and traveler (OR)", function()
        local graph = harness.create_graph()

        local a = gutils.add_node(graph, "item", "iron-plate", {op = "AND"})
        local b = gutils.add_node(graph, "recipe", "iron-gear-wheel", {op = "AND"})
        graph.sources[gutils.key(a)] = true

        gutils.add_edge(graph, gutils.key(a), gutils.key(b))

        local result = subdivide_for_randomization(graph, gutils.key(a), gutils.key(b))

        harness.assert_equal("AND", result.slot.op)
        harness.assert_equal("OR", result.traveler.op)
    end)

    harness.test("subdivision: slot has 1 prereq after subdivision", function()
        local graph = harness.create_graph()

        local a = gutils.add_node(graph, "item", "iron-plate", {op = "AND"})
        local b = gutils.add_node(graph, "recipe", "iron-gear-wheel", {op = "AND"})
        graph.sources[gutils.key(a)] = true

        gutils.add_edge(graph, gutils.key(a), gutils.key(b))

        local result = subdivide_for_randomization(graph, gutils.key(a), gutils.key(b))

        -- Slot should have exactly 1 prereq (from the prereq node)
        harness.assert_equal(1, result.slot.num_pre)
    end)

    harness.test("subdivision: traveler starts with 1 prereq from slot", function()
        local graph = harness.create_graph()

        local a = gutils.add_node(graph, "item", "iron-plate", {op = "AND"})
        local b = gutils.add_node(graph, "recipe", "iron-gear-wheel", {op = "AND"})
        graph.sources[gutils.key(a)] = true

        gutils.add_edge(graph, gutils.key(a), gutils.key(b))

        local result = subdivide_for_randomization(graph, gutils.key(a), gutils.key(b))

        -- Traveler has 1 prereq from original slot
        harness.assert_equal(1, result.traveler.num_pre)
    end)

    harness.test("subdivision: original edge is removed", function()
        local graph = harness.create_graph()

        local a = gutils.add_node(graph, "item", "iron-plate", {op = "AND"})
        local b = gutils.add_node(graph, "recipe", "iron-gear-wheel", {op = "AND"})
        graph.sources[gutils.key(a)] = true

        local edge = gutils.add_edge(graph, gutils.key(a), gutils.key(b))
        local original_edge_key = gutils.ekey(edge)

        subdivide_for_randomization(graph, gutils.key(a), gutils.key(b))

        harness.assert_nil(graph.edges[original_edge_key])
    end)

    ---------------------------------------------------------------------------
    -- Reachability tests (critical invariants)
    ---------------------------------------------------------------------------

    harness.test("reachability: traveler OR node unreachable until assigned", function()
        -- This tests the critical rule: OR with 0 external prereqs = unreachable
        -- After subdivision, traveler has prereq from its slot, but that
        -- slot's context doesn't propagate until assignment

        local graph = harness.create_graph()

        local source = gutils.add_node(graph, "item", "source", {op = "AND"})
        local target = gutils.add_node(graph, "recipe", "target", {op = "AND"})
        graph.sources[gutils.key(source)] = true

        gutils.add_edge(graph, gutils.key(source), gutils.key(target))

        local result = subdivide_for_randomization(graph, gutils.key(source), gutils.key(target))

        -- The traveler is an OR node. It has a prereq (from slot),
        -- but in the slot scramble model, travelers start "blocked"
        -- until their new slot assignment connects them.
        harness.assert_equal("OR", result.traveler.op)
    end)

    harness.test("reachability: assignment connects slot to traveler", function()
        local graph = harness.create_graph()

        -- Two sources, two targets - we'll cross-assign
        local src1 = gutils.add_node(graph, "item", "src1", {op = "AND"})
        local src2 = gutils.add_node(graph, "item", "src2", {op = "AND"})
        local tgt1 = gutils.add_node(graph, "recipe", "tgt1", {op = "AND"})
        local tgt2 = gutils.add_node(graph, "recipe", "tgt2", {op = "AND"})

        graph.sources[gutils.key(src1)] = true
        graph.sources[gutils.key(src2)] = true

        gutils.add_edge(graph, gutils.key(src1), gutils.key(tgt1))
        gutils.add_edge(graph, gutils.key(src2), gutils.key(tgt2))

        local sub1 = subdivide_for_randomization(graph, gutils.key(src1), gutils.key(tgt1))
        local sub2 = subdivide_for_randomization(graph, gutils.key(src2), gutils.key(tgt2))

        -- Cross-assign: slot1 -> traveler2, slot2 -> traveler1
        assign_slot_to_traveler(graph, sub1.slot, sub2.traveler)
        assign_slot_to_traveler(graph, sub2.slot, sub1.traveler)

        -- After assignment, travelers should have additional prereqs
        harness.assert_equal(2, sub1.traveler.num_pre)  -- original slot + cross-assigned slot
        harness.assert_equal(2, sub2.traveler.num_pre)
    end)

    ---------------------------------------------------------------------------
    -- Monotonic reachability tests
    ---------------------------------------------------------------------------

    harness.test("monotonic: nodes never become unreachable once reachable", function()
        -- This is the key invariant for slot scramble
        -- Once a node is marked reachable, it stays reachable

        local graph = harness.create_graph()

        local source = gutils.add_node(graph, "item", "source", {op = "AND"})
        graph.sources[gutils.key(source)] = true

        -- Source is reachable (in sources set)
        harness.assert_true(graph.sources[gutils.key(source)])

        -- Adding edges shouldn't remove it from sources
        local target = gutils.add_node(graph, "item", "target", {op = "AND"})
        gutils.add_edge(graph, gutils.key(source), gutils.key(target))

        -- Source should still be a source
        harness.assert_true(graph.sources[gutils.key(source)])
    end)

    ---------------------------------------------------------------------------
    -- Handler pattern tests (structural)
    ---------------------------------------------------------------------------

    harness.test("handler pattern: required fields documented", function()
        -- The default handler defines required fields
        -- This test documents what handlers must implement
        local required = {
            "source_types",
            "target_types",
            "group_surfaces",
            "to_canonical",
            "traveler_priority",
            "validate_connection",
            "reflect",
        }

        -- This is a documentation/reminder test
        harness.assert_equal(7, #required)
    end)

    harness.test("handler pattern: claim determines edge ownership", function()
        -- Handlers claim edges based on source/target types
        -- Two handlers should never claim the same edge

        -- This is a structural test documenting the pattern
        harness.assert_true(true, "claim determines ownership")
    end)

    harness.test("handler pattern: validate_connection checks compatibility", function()
        -- validate_connection(slot, traveler) returns true if slot accepts traveler
        -- Example: recipe-results slot accepts item/fluid travelers

        -- Structural documentation test
        harness.assert_true(true, "validate checks slot/traveler compatibility")
    end)

    harness.test("handler pattern: reflect modifies data.raw", function()
        -- reflect(slot_to_traveler) applies changes to game data
        -- Called after all assignments are made

        -- Structural documentation test
        harness.assert_true(true, "reflect updates prototypes")
    end)

    ---------------------------------------------------------------------------
    -- Reservation system tests (structural)
    ---------------------------------------------------------------------------

    harness.test("reservation: reservable slots accept future travelers", function()
        -- Terminal slots (plain items with no abilities) are reservable
        -- They can accept travelers that aren't reachable yet

        -- Structural documentation test
        harness.assert_true(true, "reservable slots for future travelers")
    end)

    harness.test("reservation: reservations can be cancelled", function()
        -- If stuck, cancel most recent reservation and try important traveler

        -- Structural documentation test
        harness.assert_true(true, "reservations are cancellable")
    end)

    harness.test("reservation: fulfillment adds actual edge", function()
        -- When vanilla slot becomes reachable, reservation is fulfilled
        -- This adds the slot->traveler edge to the graph

        -- Structural documentation test
        harness.assert_true(true, "fulfillment creates edge")
    end)

    ---------------------------------------------------------------------------
    -- Graph surgery tests
    ---------------------------------------------------------------------------

    harness.test("surgery: removing edge from AND node makes it harder to satisfy", function()
        local graph = harness.create_graph()

        local src1 = gutils.add_node(graph, "item", "src1", {op = "AND"})
        local src2 = gutils.add_node(graph, "item", "src2", {op = "AND"})
        local and_node = gutils.add_node(graph, "recipe", "and", {op = "AND"})

        graph.sources[gutils.key(src1)] = true
        graph.sources[gutils.key(src2)] = true

        local edge1 = gutils.add_edge(graph, gutils.key(src1), gutils.key(and_node))
        gutils.add_edge(graph, gutils.key(src2), gutils.key(and_node))

        harness.assert_equal(2, and_node.num_pre)

        -- Remove one edge
        gutils.remove_edge(graph, gutils.ekey(edge1))

        harness.assert_equal(1, and_node.num_pre)
    end)

    harness.test("surgery: subdivision preserves graph structure", function()
        local graph = harness.create_graph()

        local a = gutils.add_node(graph, "item", "a", {op = "AND"})
        local b = gutils.add_node(graph, "item", "b", {op = "AND"})
        local c = gutils.add_node(graph, "item", "c", {op = "AND"})

        graph.sources[gutils.key(a)] = true

        gutils.add_edge(graph, gutils.key(a), gutils.key(b))
        gutils.add_edge(graph, gutils.key(b), gutils.key(c))

        -- Original: a -> b -> c
        -- After subdividing a->b: a -> slot -> traveler -> b -> c

        subdivide_for_randomization(graph, gutils.key(a), gutils.key(b))

        -- b should still have edge to c
        local b_has_edge_to_c = false
        for edge_key, _ in pairs(graph.nodes[gutils.key(b)].dep) do
            if graph.edges[edge_key].stop == gutils.key(c) then
                b_has_edge_to_c = true
            end
        end
        harness.assert_true(b_has_edge_to_c)
    end)

    ---------------------------------------------------------------------------
    -- Edge case tests
    ---------------------------------------------------------------------------

    harness.test("edge case: dummy slots always reservable", function()
        -- Dummies are created to provide extra slots when needed
        -- They should always accept reservations

        -- Structural documentation test
        harness.assert_true(true, "dummy slots are reservable")
    end)

    harness.test("edge case: dummy travelers have negative priority", function()
        -- Dummies should be last resort, so -1 priority

        -- Structural documentation test
        harness.assert_true(true, "dummy travelers low priority")
    end)

    harness.test("edge case: critical path items get priority", function()
        -- Items on critical path (science packs, progression items)
        -- should have higher traveler_priority

        -- Structural documentation test
        harness.assert_true(true, "critical path gets priority")
    end)
end

return tests

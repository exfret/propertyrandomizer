-- test/graph/graph-utils.lua
-- Unit tests for new-lib/graph/graph-utils.lua

local harness = require("test/harness")
local gutils = require("new-lib/graph/graph-utils")

local tests = {}

function tests.run()
    harness.suite("graph-utils")

    ---------------------------------------------------------------------------
    -- key() tests
    ---------------------------------------------------------------------------

    harness.test("key: creates correct key from type and name", function()
        local k = gutils.key("technology", "automation")
        harness.assert_equal("technology: automation", k)
    end)

    harness.test("key: creates key from node table", function()
        local node = {type = "item", name = "iron-plate"}
        local k = gutils.key(node)
        harness.assert_equal("item: iron-plate", k)
    end)

    harness.test("key: handles special characters in names", function()
        local k = gutils.key("recipe", "iron-gear-wheel")
        harness.assert_equal("recipe: iron-gear-wheel", k)
    end)

    ---------------------------------------------------------------------------
    -- deconstruct() tests
    ---------------------------------------------------------------------------

    harness.test("deconstruct: extracts type and name from key", function()
        local result = gutils.deconstruct("technology: automation")
        harness.assert_equal("technology", result.type)
        harness.assert_equal("automation", result.name)
    end)

    harness.test("deconstruct: handles names with hyphens", function()
        local result = gutils.deconstruct("recipe: iron-gear-wheel")
        harness.assert_equal("recipe", result.type)
        harness.assert_equal("iron-gear-wheel", result.name)
    end)

    harness.test("deconstruct: roundtrip with key", function()
        local original_type = "fluid"
        local original_name = "crude-oil"
        local k = gutils.key(original_type, original_name)
        local result = gutils.deconstruct(k)
        harness.assert_equal(original_type, result.type)
        harness.assert_equal(original_name, result.name)
    end)

    ---------------------------------------------------------------------------
    -- concat() tests
    ---------------------------------------------------------------------------

    harness.test("concat: joins strings with separator", function()
        local result = gutils.concat({"a", "b", "c"})
        harness.assert_equal("a__b__c", result)
    end)

    harness.test("concat: works with second separator level", function()
        local result = gutils.concat({"a", "b"}, 2)
        harness.assert_equal("a_2_b", result)
    end)

    harness.test("concat: handles single element", function()
        local result = gutils.concat({"single"})
        harness.assert_equal("single", result)
    end)

    ---------------------------------------------------------------------------
    -- ekey() tests
    ---------------------------------------------------------------------------

    harness.test("ekey: creates edge key from edge table", function()
        local edge = {start = "node: a", stop = "node: b"}
        local k = gutils.ekey(edge)
        harness.assert_equal("node: a --> node: b", k)
    end)

    ---------------------------------------------------------------------------
    -- add_node() tests
    ---------------------------------------------------------------------------

    harness.test("add_node: creates node with correct structure", function()
        local graph = harness.create_graph()
        local node = gutils.add_node(graph, "test", "mynode")

        harness.assert_equal("node", node.object_type)
        harness.assert_equal("test", node.type)
        harness.assert_equal("mynode", node.name)
        harness.assert_type("table", node.pre)
        harness.assert_type("table", node.dep)
        harness.assert_equal(0, node.num_pre)
    end)

    harness.test("add_node: adds to graph.nodes", function()
        local graph = harness.create_graph()
        gutils.add_node(graph, "test", "mynode")

        local key = gutils.key("test", "mynode")
        harness.assert_not_nil(graph.nodes[key])
    end)

    harness.test("add_node: accepts extra properties", function()
        local graph = harness.create_graph()
        local node = gutils.add_node(graph, "test", "mynode", {custom = "value", op = "AND"})

        harness.assert_equal("value", node.custom)
        harness.assert_equal("AND", node.op)
    end)

    ---------------------------------------------------------------------------
    -- add_edge() tests
    ---------------------------------------------------------------------------

    harness.test("add_edge: creates edge with correct structure", function()
        local graph = harness.create_graph()
        gutils.add_node(graph, "node", "a", {op = "AND"})
        gutils.add_node(graph, "node", "b", {op = "AND"})

        local start_key = gutils.key("node", "a")
        local stop_key = gutils.key("node", "b")
        local edge = gutils.add_edge(graph, start_key, stop_key)

        harness.assert_equal("edge", edge.object_type)
        harness.assert_equal(start_key, edge.start)
        harness.assert_equal(stop_key, edge.stop)
    end)

    harness.test("add_edge: updates node pre/dep sets", function()
        local graph = harness.create_graph()
        gutils.add_node(graph, "node", "a", {op = "AND"})
        gutils.add_node(graph, "node", "b", {op = "AND"})

        local start_key = gutils.key("node", "a")
        local stop_key = gutils.key("node", "b")
        local edge = gutils.add_edge(graph, start_key, stop_key)
        local edge_key = gutils.ekey(edge)

        -- Check start node has edge in dep
        harness.assert_has_key(graph.nodes[start_key].dep, edge_key)
        -- Check stop node has edge in pre
        harness.assert_has_key(graph.nodes[stop_key].pre, edge_key)
    end)

    harness.test("add_edge: increments num_pre on stop node", function()
        local graph = harness.create_graph()
        gutils.add_node(graph, "node", "a", {op = "AND"})
        gutils.add_node(graph, "node", "b", {op = "AND"})

        local start_key = gutils.key("node", "a")
        local stop_key = gutils.key("node", "b")

        harness.assert_equal(0, graph.nodes[stop_key].num_pre)
        gutils.add_edge(graph, start_key, stop_key)
        harness.assert_equal(1, graph.nodes[stop_key].num_pre)
    end)

    harness.test("add_edge: removes stop node from sources", function()
        local graph = harness.create_graph()
        local node_a = gutils.add_node(graph, "node", "a", {op = "AND"})
        local node_b = gutils.add_node(graph, "node", "b", {op = "AND"})

        -- Manually add b as source (simulating AND with 0 prereqs)
        graph.sources[gutils.key(node_b)] = true

        gutils.add_edge(graph, gutils.key(node_a), gutils.key(node_b))

        -- b should no longer be a source
        harness.assert_nil(graph.sources[gutils.key(node_b)])
    end)

    harness.test("add_edge: accepts extra properties", function()
        local graph = harness.create_graph()
        gutils.add_node(graph, "node", "a", {op = "AND"})
        gutils.add_node(graph, "node", "b", {op = "AND"})

        local edge = gutils.add_edge(graph, gutils.key("node", "a"), gutils.key("node", "b"), {abilities = {[1] = true}})

        harness.assert_not_nil(edge.abilities)
        harness.assert_equal(true, edge.abilities[1])
    end)

    ---------------------------------------------------------------------------
    -- remove_edge() tests
    ---------------------------------------------------------------------------

    harness.test("remove_edge: removes edge from graph", function()
        local graph = harness.create_graph()
        gutils.add_node(graph, "node", "a", {op = "AND"})
        gutils.add_node(graph, "node", "b", {op = "AND"})

        local edge = gutils.add_edge(graph, gutils.key("node", "a"), gutils.key("node", "b"))
        local edge_key = gutils.ekey(edge)

        harness.assert_not_nil(graph.edges[edge_key])
        gutils.remove_edge(graph, edge_key)
        harness.assert_nil(graph.edges[edge_key])
    end)

    harness.test("remove_edge: decrements num_pre", function()
        local graph = harness.create_graph()
        gutils.add_node(graph, "node", "a", {op = "AND"})
        gutils.add_node(graph, "node", "b", {op = "AND"})

        local edge = gutils.add_edge(graph, gutils.key("node", "a"), gutils.key("node", "b"))
        local edge_key = gutils.ekey(edge)
        local stop_key = gutils.key("node", "b")

        harness.assert_equal(1, graph.nodes[stop_key].num_pre)
        gutils.remove_edge(graph, edge_key)
        harness.assert_equal(0, graph.nodes[stop_key].num_pre)
    end)

    harness.test("remove_edge: restores AND node to sources when num_pre becomes 0", function()
        local graph = harness.create_graph()
        gutils.add_node(graph, "node", "a", {op = "AND"})
        gutils.add_node(graph, "node", "b", {op = "AND"})

        local stop_key = gutils.key("node", "b")
        local edge = gutils.add_edge(graph, gutils.key("node", "a"), stop_key)
        local edge_key = gutils.ekey(edge)

        gutils.remove_edge(graph, edge_key)

        -- AND node with 0 prereqs should be added back to sources
        harness.assert_true(graph.sources[stop_key])
    end)

    ---------------------------------------------------------------------------
    -- subdivide() tests
    ---------------------------------------------------------------------------

    harness.test("subdivide: creates slot and traveler nodes", function()
        local graph = harness.create_graph()
        gutils.add_node(graph, "node", "a", {op = "AND"})
        gutils.add_node(graph, "node", "b", {op = "AND"})
        local edge = gutils.add_edge(graph, gutils.key("node", "a"), gutils.key("node", "b"))
        local edge_key = gutils.ekey(edge)

        local result = gutils.subdivide(graph, edge_key)

        harness.assert_not_nil(result.slot)
        harness.assert_not_nil(result.traveler)
        harness.assert_equal("slot", result.slot.type)
        harness.assert_equal("traveler", result.traveler.type)
    end)

    harness.test("subdivide: slot is AND, traveler is OR", function()
        local graph = harness.create_graph()
        gutils.add_node(graph, "node", "a", {op = "AND"})
        gutils.add_node(graph, "node", "b", {op = "AND"})
        local edge = gutils.add_edge(graph, gutils.key("node", "a"), gutils.key("node", "b"))
        local edge_key = gutils.ekey(edge)

        local result = gutils.subdivide(graph, edge_key)

        harness.assert_equal("AND", result.slot.op)
        harness.assert_equal("OR", result.traveler.op)
    end)

    harness.test("subdivide: removes original edge", function()
        local graph = harness.create_graph()
        gutils.add_node(graph, "node", "a", {op = "AND"})
        gutils.add_node(graph, "node", "b", {op = "AND"})
        local edge = gutils.add_edge(graph, gutils.key("node", "a"), gutils.key("node", "b"))
        local edge_key = gutils.ekey(edge)

        gutils.subdivide(graph, edge_key)

        harness.assert_nil(graph.edges[edge_key])
    end)

    harness.test("subdivide: creates correct edge chain A->slot->traveler->B", function()
        local graph = harness.create_graph()
        gutils.add_node(graph, "node", "a", {op = "AND"})
        gutils.add_node(graph, "node", "b", {op = "AND"})
        local edge = gutils.add_edge(graph, gutils.key("node", "a"), gutils.key("node", "b"))
        local edge_key = gutils.ekey(edge)

        local result = gutils.subdivide(graph, edge_key)
        local slot_key = gutils.key(result.slot)
        local traveler_key = gutils.key(result.traveler)
        local a_key = gutils.key("node", "a")
        local b_key = gutils.key("node", "b")

        -- A should have edge to slot
        local found_a_to_slot = false
        for dep_key, _ in pairs(graph.nodes[a_key].dep) do
            if graph.edges[dep_key].stop == slot_key then
                found_a_to_slot = true
            end
        end
        harness.assert_true(found_a_to_slot, "A->slot edge exists")

        -- slot should have edge to traveler
        local found_slot_to_traveler = false
        for dep_key, _ in pairs(graph.nodes[slot_key].dep) do
            if graph.edges[dep_key].stop == traveler_key then
                found_slot_to_traveler = true
            end
        end
        harness.assert_true(found_slot_to_traveler, "slot->traveler edge exists")

        -- traveler should have edge to B
        local found_traveler_to_b = false
        for dep_key, _ in pairs(graph.nodes[traveler_key].dep) do
            if graph.edges[dep_key].stop == b_key then
                found_traveler_to_b = true
            end
        end
        harness.assert_true(found_traveler_to_b, "traveler->B edge exists")
    end)

    harness.test("subdivide: copies edge properties to slot and traveler", function()
        local graph = harness.create_graph()
        gutils.add_node(graph, "node", "a", {op = "AND"})
        gutils.add_node(graph, "node", "b", {op = "AND"})
        local edge = gutils.add_edge(graph, gutils.key("node", "a"), gutils.key("node", "b"), {custom_prop = "test_value"})
        local edge_key = gutils.ekey(edge)

        local result = gutils.subdivide(graph, edge_key)

        harness.assert_equal("test_value", result.slot.custom_prop)
        harness.assert_equal("test_value", result.traveler.custom_prop)
    end)

    ---------------------------------------------------------------------------
    -- get_conn_owner() tests
    ---------------------------------------------------------------------------

    harness.test("get_conn_owner: returns prereq node for slot", function()
        local graph = harness.create_graph()
        gutils.add_node(graph, "node", "a", {op = "AND"})
        gutils.add_node(graph, "node", "b", {op = "AND"})
        local edge = gutils.add_edge(graph, gutils.key("node", "a"), gutils.key("node", "b"))
        local edge_key = gutils.ekey(edge)

        local result = gutils.subdivide(graph, edge_key)
        local owner = gutils.get_conn_owner(graph, result.slot)

        harness.assert_equal("node", owner.type)
        harness.assert_equal("a", owner.name)
    end)

    harness.test("get_conn_owner: returns dependent node for traveler", function()
        local graph = harness.create_graph()
        gutils.add_node(graph, "node", "a", {op = "AND"})
        gutils.add_node(graph, "node", "b", {op = "AND"})
        local edge = gutils.add_edge(graph, gutils.key("node", "a"), gutils.key("node", "b"))
        local edge_key = gutils.ekey(edge)

        local result = gutils.subdivide(graph, edge_key)
        local owner = gutils.get_conn_owner(graph, result.traveler)

        harness.assert_equal("node", owner.type)
        harness.assert_equal("b", owner.name)
    end)

    ---------------------------------------------------------------------------
    -- get_conn_buddy() tests
    ---------------------------------------------------------------------------

    harness.test("get_conn_buddy: slot returns traveler", function()
        local graph = harness.create_graph()
        gutils.add_node(graph, "node", "a", {op = "AND"})
        gutils.add_node(graph, "node", "b", {op = "AND"})
        local edge = gutils.add_edge(graph, gutils.key("node", "a"), gutils.key("node", "b"))
        local edge_key = gutils.ekey(edge)

        local result = gutils.subdivide(graph, edge_key)
        local buddy = gutils.get_conn_buddy(graph, result.slot)

        harness.assert_equal("traveler", buddy.type)
    end)

    harness.test("get_conn_buddy: traveler returns slot", function()
        local graph = harness.create_graph()
        gutils.add_node(graph, "node", "a", {op = "AND"})
        gutils.add_node(graph, "node", "b", {op = "AND"})
        local edge = gutils.add_edge(graph, gutils.key("node", "a"), gutils.key("node", "b"))
        local edge_key = gutils.ekey(edge)

        local result = gutils.subdivide(graph, edge_key)
        local buddy = gutils.get_conn_buddy(graph, result.traveler)

        harness.assert_equal("slot", buddy.type)
    end)
end

return tests

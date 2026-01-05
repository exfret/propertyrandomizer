-- test/logic/builder.lua
-- Unit tests for new-lib/logic/builder.lua

local harness = require("test/harness")
local gutils = require("new-lib/graph/graph-utils")

local tests = {}

function tests.run()
    harness.suite("logic/builder")

    local helpers = require("new-lib/logic/builder")

    ---------------------------------------------------------------------------
    -- init tests
    ---------------------------------------------------------------------------

    harness.test("init: accepts graph and info tables", function()
        local graph = harness.create_graph()
        local type_info = {}
        local edge_info = {}

        harness.assert_no_error(function()
            helpers.init(graph, type_info, edge_info)
        end)
    end)

    ---------------------------------------------------------------------------
    -- set_class / set_prot tests
    ---------------------------------------------------------------------------

    harness.test("set_class: sets current class context", function()
        harness.assert_no_error(function()
            helpers.set_class("technology")
        end)
    end)

    harness.test("set_prot: sets current prototype context", function()
        local mock_prot = {type = "technology", name = "automation"}

        harness.assert_no_error(function()
            helpers.set_prot(mock_prot)
        end)

        harness.assert_equal(mock_prot, helpers.get_curr_prot())
    end)

    ---------------------------------------------------------------------------
    -- add_node tests
    ---------------------------------------------------------------------------

    harness.test("add_node: creates node in graph", function()
        local graph = harness.create_graph()
        local type_info = {}
        local edge_info = {}

        helpers.init(graph, type_info, edge_info)
        helpers.set_class("technology")
        helpers.set_prot({type = "technology", name = "automation"})

        helpers.add_node("technology", "AND", nil)

        local node_key = gutils.key("technology", "automation")
        harness.assert_not_nil(graph.nodes[node_key])
    end)

    harness.test("add_node: populates type_info", function()
        local graph = harness.create_graph()
        local type_info = {}
        local edge_info = {}

        helpers.init(graph, type_info, edge_info)
        helpers.set_class("item")
        helpers.set_prot({type = "item", name = "iron-plate"})

        helpers.add_node("item", "AND", nil)

        harness.assert_not_nil(type_info["item"])
        harness.assert_equal("AND", type_info["item"].op)
    end)

    harness.test("add_node: sets curr to created node", function()
        local graph = harness.create_graph()
        local type_info = {}
        local edge_info = {}

        helpers.init(graph, type_info, edge_info)
        helpers.set_class("recipe")
        helpers.set_prot({type = "recipe", name = "iron-gear-wheel"})

        helpers.add_node("recipe", "AND", nil)

        local curr = helpers.get_curr()
        harness.assert_not_nil(curr)
        harness.assert_equal("recipe", curr.type)
        harness.assert_equal("iron-gear-wheel", curr.name)
    end)

    harness.test("add_node: with explicit name", function()
        local graph = harness.create_graph()
        local type_info = {}
        local edge_info = {}

        helpers.init(graph, type_info, edge_info)
        helpers.set_class("special")
        helpers.set_prot({type = "dummy", name = "ignored"})

        helpers.add_node("special", "OR", nil, "custom-name")

        local node_key = gutils.key("special", "custom-name")
        harness.assert_not_nil(graph.nodes[node_key])
    end)

    harness.test("add_node: with context parameter", function()
        local graph = harness.create_graph()
        local type_info = {}
        local edge_info = {}

        helpers.init(graph, type_info, edge_info)
        helpers.set_class("room")
        helpers.set_prot({type = "room", name = "nauvis"})

        helpers.add_node("room", "AND", "nauvis")

        harness.assert_equal("nauvis", type_info["room"].context)
    end)

    ---------------------------------------------------------------------------
    -- add_edge tests
    ---------------------------------------------------------------------------

    harness.test("add_edge: creates edge between nodes", function()
        local graph = harness.create_graph()
        local type_info = {}
        local edge_info = {}

        helpers.init(graph, type_info, edge_info)

        -- Create start node
        helpers.set_class("item")
        helpers.set_prot({type = "item", name = "iron-plate"})
        helpers.add_node("item", "AND", nil)

        -- Create end node (curr)
        helpers.set_class("recipe")
        helpers.set_prot({type = "recipe", name = "iron-gear-wheel"})
        helpers.add_node("recipe", "AND", nil)

        -- Add edge from iron-plate to iron-gear-wheel
        helpers.add_edge("item", "iron-plate")

        -- Check edge exists
        local start_key = gutils.key("item", "iron-plate")
        local stop_key = gutils.key("recipe", "iron-gear-wheel")
        local edge_key = start_key .. " --> " .. stop_key

        harness.assert_not_nil(graph.edges[edge_key])
    end)

    harness.test("add_edge: populates edge_info", function()
        local graph = harness.create_graph()
        local type_info = {}
        local edge_info = {}

        helpers.init(graph, type_info, edge_info)

        helpers.set_class("item")
        helpers.set_prot({type = "item", name = "copper-plate"})
        helpers.add_node("item", "AND", nil)

        helpers.set_class("recipe")
        helpers.set_prot({type = "recipe", name = "copper-cable"})
        helpers.add_node("recipe", "AND", nil)

        helpers.add_edge("item", "copper-plate")

        local edge_type_key = gutils.concat({"item", "recipe"})
        harness.assert_not_nil(edge_info[edge_type_key])
    end)

    harness.test("add_edge: with abilities", function()
        local graph = harness.create_graph()
        local type_info = {}
        local edge_info = {}

        helpers.init(graph, type_info, edge_info)

        helpers.set_class("entity")
        helpers.set_prot({type = "entity", name = "iron-ore"})
        helpers.add_node("entity", "AND", nil)

        helpers.set_class("item")
        helpers.set_prot({type = "item", name = "iron-ore"})
        helpers.add_node("item", "AND", nil)

        helpers.add_edge("entity", "iron-ore", {abilities = {[1] = true}})

        local edge_type_key = gutils.concat({"entity", "item"})
        harness.assert_not_nil(edge_info[edge_type_key].abilities)
    end)

    ---------------------------------------------------------------------------
    -- Context handling tests
    ---------------------------------------------------------------------------

    harness.test("context: nil means default transmit", function()
        local graph = harness.create_graph()
        local type_info = {}
        local edge_info = {}

        helpers.init(graph, type_info, edge_info)
        helpers.set_class("item")
        helpers.set_prot({type = "item", name = "test"})

        helpers.add_node("item", "AND", nil)

        harness.assert_nil(type_info["item"].context)
    end)

    harness.test("context: true means FORGET (all contexts)", function()
        local graph = harness.create_graph()
        local type_info = {}
        local edge_info = {}

        helpers.init(graph, type_info, edge_info)
        helpers.set_class("technology")
        helpers.set_prot({type = "technology", name = "test-tech"})

        helpers.add_node("technology", "AND", true)

        harness.assert_equal(true, type_info["technology"].context)
    end)

    harness.test("context: string means specific context", function()
        local graph = harness.create_graph()
        local type_info = {}
        local edge_info = {}

        helpers.init(graph, type_info, edge_info)
        helpers.set_class("room")
        helpers.set_prot({type = "room", name = "vulcanus"})

        helpers.add_node("room", "AND", "vulcanus")

        harness.assert_equal("vulcanus", type_info["room"].context)
    end)
end

return tests

-- Plain-Lua regression tests for items and fluids trading positions (lib/item-fluid.lua) and machines taking fluids (lib/fluid-ports.lua), not loaded by the mod
-- Run from the mod root: lua lib/test-item-fluid.lua

-- Stand-ins for the Factorio environment
function table.deepcopy(tbl)
    if type(tbl) ~= "table" then
        return tbl
    end
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = table.deepcopy(v)
    end
    return copy
end
function log(msg) end
defines = {
    prototypes = {
        item = {
            item = 0,
        },
    },
    direction = {
        north = 0,
        east = 4,
        south = 8,
        west = 12,
    },
}
util = {
    parse_energy = function(energy)
        local number, prefix = string.match(energy, "^([%d%.]+)(%a?)[JW]$")
        local scale = { [""] = 1, k = 1e3, M = 1e6, G = 1e9, T = 1e12 }
        return (tonumber(number) or 0) * (scale[prefix] or 1)
    end,
}
data = {
    raw = {
        lab = {},
        item = {},
        fluid = {},
    },
}
-- The feature under test is on (config.lua turns it off while the user playtests)
config = {
    item_fluids = true,
}
randomization_info = {
    options = {
        first_pass = {
            blacklist = {},
        },
    },
}
package.loaded["lib/locale"] = {
    find_localised_name = function(prot)
        return { prot.type .. "-name." .. prot.name }
    end,
}

local gutils = require("lib/graph/graph-utils")
local dutils = require("lib/data-utils")
local item_fluid = require("lib/item-fluid")
local fluid_ports = require("lib/fluid-ports")
local pipe_conns = require("lib/pipe-conns")

local key = gutils.key

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local function add_item(name, is_useless)
    data.raw.item[name] = {
        type = "item",
        name = name,
        stack_size = 50,
        place_result = (not is_useless) and name or nil,
    }
end
local function add_fluid(name)
    data.raw.fluid[name] = {
        type = "fluid",
        name = name,
        default_temperature = 15,
        base_color = { 0, 0, 1 },
        flow_color = { 0, 0, 1 },
    }
end

----------------------------------------------------------------------------------------------------
-- Where reflection puts identities
----------------------------------------------------------------------------------------------------

test("fluids and items becoming fluids land where they're assigned; useless items only detour among item positions", function()
    math.randomseed(2)
    for trial = 1, 3000 do
        data.raw.item = {}
        data.raw.fluid = {}
        local materials = {}
        local n = math.random(2, 12)
        for i = 1, n do
            if math.random() < 0.35 then
                add_fluid("fluid-" .. i)
                table.insert(materials, key("fluid", "fluid-" .. i))
            else
                add_item("item-" .. i, math.random() < 0.5)
                table.insert(materials, key("item", "item-" .. i))
            end
        end
        local shuffled = {}
        for i = 1, n do
            shuffled[i] = materials[i]
        end
        for i = n, 2, -1 do
            local j = math.random(1, i)
            shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
        end
        local identity_at = {}
        for i = 1, n do
            identity_at[materials[i]] = shuffled[i]
        end

        local is_useless = item_fluid.useless_predicate(identity_at)
        local realized = dutils.realized_item_assignment(identity_at, is_useless)
        local seen = {}
        for _, position in pairs(materials) do
            local identity = realized[position]
            assert(identity ~= nil and not seen[identity], "not a permutation")
            seen[identity] = true
            local assigned = identity_at[position]
            local assigned_changes_form = gutils.deconstruct(assigned).type ~= gutils.deconstruct(position).type
            if gutils.deconstruct(assigned).type == "fluid" or assigned_changes_form or not item_fluid.is_useless_material(assigned) then
                assert(identity == assigned, "an identity that isn't a useless item at an item position moved")
            end
            -- Anything that changes form was assigned there (first pass allowed that pair)
            if gutils.deconstruct(identity).type ~= gutils.deconstruct(position).type then
                assert(identity == assigned, "a detour changed an identity's form")
            end
        end
        local again = dutils.realized_item_assignment(realized, item_fluid.useless_predicate(realized))
        for _, position in pairs(materials) do
            assert(again[position] == realized[position], "realizing a realized assignment changed it")
        end
    end
end)

test("with only items, the rule is item reflection's own", function()
    math.randomseed(3)
    for trial = 1, 500 do
        data.raw.item = {}
        local names = {}
        local n = math.random(2, 10)
        for i = 1, n do
            names[i] = "item-" .. i
            add_item(names[i], math.random() < 0.5)
        end
        local shuffled = {}
        for i = 1, n do
            shuffled[i] = names[i]
        end
        for i = n, 2, -1 do
            local j = math.random(1, i)
            shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
        end
        local by_name = {}
        local by_key = {}
        for i = 1, n do
            by_name[names[i]] = shuffled[i]
            by_key[key("item", names[i])] = key("item", shuffled[i])
        end
        local realized_names = dutils.realized_item_assignment(by_name)
        local realized_keys = dutils.realized_item_assignment(by_key, item_fluid.useless_predicate(by_key))
        for i = 1, n do
            assert(realized_keys[key("item", names[i])] == key("item", realized_names[names[i]]))
        end
    end
end)

----------------------------------------------------------------------------------------------------
-- Which identities can change form
----------------------------------------------------------------------------------------------------

test("only plain items can become fluids, and only fluids that aren't fuels can become items", function()
    data.raw.item = {}
    data.raw.fluid = {}
    local plain = {
        type = "item",
        name = "widget",
        stack_size = 100,
    }
    assert(item_fluid.item_can_be_fluid(plain))
    for _, field in pairs({ "place_result", "plant_result", "place_as_equipment_result", "spoil_result", "burnt_result" }) do
        local item = table.deepcopy(plain)
        item[field] = "something"
        assert(not item_fluid.item_can_be_fluid(item), field)
    end
    local fuel = table.deepcopy(plain)
    fuel.fuel_value = "4MJ"
    assert(not item_fluid.item_can_be_fluid(fuel))
    local spoiling = table.deepcopy(plain)
    spoiling.spoil_ticks = 600
    assert(not item_fluid.item_can_be_fluid(spoiling))
    -- Other item types (like modules, which go in module slots) are used as what they are, which a fluid can't be
    assert(not item_fluid.item_can_be_fluid({ type = "gizmo-type", name = "gizmo", stack_size = 50 }))
    data.raw.lab.lab = { inputs = { "widget" } }
    assert(not item_fluid.item_can_be_fluid(plain), "a lab input")
    data.raw.lab = {}

    assert(item_fluid.fluid_can_be_item({ type = "fluid", name = "gas" }))
    assert(not item_fluid.fluid_can_be_item({ type = "fluid", name = "burnable-gas", fuel_value = "1MJ" }))
    assert(not item_fluid.fluid_can_be_item({ type = "fluid", name = "p", parameter = true }))
end)

-- A toy split graph: an item slot and trav with a delivery chain, a fluid slot (a fluid-temperature node) and trav, and their base/head connectors as first pass makes them
local function toy_split_graph(item_name, fluid_name)
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local function node(node_type, name, op)
        local added = gutils.add_node(graph, node_type, name)
        added.op = op
        return added
    end
    local function orand_edge(start, stop)
        -- Edges into OR nodes go through an orand (gutils.make_orand)
        local orand = node("orand", start.type .. start.name .. stop.type .. stop.name, "AND")
        gutils.add_edge(graph, key(start), key(orand))
        gutils.add_edge(graph, key(orand), key(stop))
        return orand
    end

    local item_slot = node("item", item_name, "OR")
    item_slot.old_trav = key("item", item_name .. "-trav")
    local item_trav = node("item", item_name .. "-trav", "OR")
    item_trav.old_slot = key(item_slot)
    local item_head = node("head", item_name, "OR")
    orand_edge(item_head, item_trav)
    local launch = node("item-launch", item_name, "AND")
    gutils.add_edge(graph, key(item_trav), key(launch))
    local deliver = node("item-deliver", item_name, "AND")
    gutils.add_edge(graph, key(launch), key(deliver))
    orand_edge(deliver, item_trav)

    local fluid_node = node("fluid", fluid_name, "OR")
    local fluid_slot = node("fluid-temperature", key(fluid_name, "15"), "AND")
    fluid_slot.old_trav = key("fluid-temperature", key(fluid_name, "15") .. "-trav")
    local fluid_trav = node("fluid-temperature", key(fluid_name, "15") .. "-trav", "AND")
    fluid_trav.old_slot = key(fluid_slot)
    local fluid_head = node("head", fluid_name, "OR")
    gutils.add_edge(graph, key(fluid_head), key(fluid_trav))
    orand_edge(fluid_trav, fluid_node)
    local create = node("fluid-create-temperature", key(fluid_name, "15"), "OR")
    gutils.add_edge(graph, key(create), key(fluid_slot))
    local craft = node("fluid-craft-temperature", key(fluid_name, "15"), "OR")
    orand_edge(craft, create)
    local hold = node("fluid-hold", fluid_name, "OR")
    gutils.add_edge(graph, key(hold), key(fluid_slot))
    return graph, item_trav, fluid_trav, fluid_node, fluid_slot, launch
end

test("an item trav with only its delivery can become a fluid; one with anything else can't", function()
    data.raw.item = {}
    data.raw.fluid = {}
    add_item("widget", true)
    add_fluid("gas")
    local graph, item_trav, fluid_trav = toy_split_graph("widget", "gas")
    assert(item_fluid.can_change_form(graph, item_trav))
    assert(item_fluid.can_change_form(graph, fluid_trav))
    -- An identity role (say it fuels something) keeps it an item
    local burner = gutils.add_node(graph, "fuel-category", "chemical")
    burner.op = "OR"
    gutils.add_edge(graph, key(item_trav), key(burner))
    assert(not item_fluid.can_change_form(graph, item_trav))
end)

test("a launch leading to something besides delivery keeps an item from becoming a fluid", function()
    data.raw.item = {}
    data.raw.fluid = {}
    add_item("widget", true)
    add_fluid("gas")
    local graph, item_trav, _, _, _, launch = toy_split_graph("widget", "gas")
    local product = gutils.add_node(graph, "item", "space-science")
    product.op = "OR"
    gutils.add_edge(graph, key(launch), key(product))
    assert(not item_fluid.can_change_form(graph, item_trav))
end)

test("a fluid whose node leads somewhere (a boiler, a turret) can't become an item", function()
    data.raw.item = {}
    data.raw.fluid = {}
    add_item("widget", true)
    add_fluid("gas")
    local graph, _, fluid_trav, fluid_node = toy_split_graph("widget", "gas")
    local boiler = gutils.add_node(graph, "entity-operate-fluid", "boiler")
    boiler.op = "OR"
    gutils.add_edge(graph, key(fluid_node), key(boiler))
    assert(not item_fluid.can_change_form(graph, fluid_trav))
end)

test("a name taken in the other form keeps an identity in its own", function()
    data.raw.item = {}
    data.raw.fluid = {}
    add_item("widget", true)
    add_fluid("gas")
    add_fluid("widget")
    local graph, item_trav = toy_split_graph("widget", "gas")
    assert(not item_fluid.can_change_form(graph, item_trav))
end)

-- A fluid as the game's graph has it before first pass splits it: made by a recipe (through fluid-craft-temperature), held in pipes, and leading to its fluid node
local function toy_fluid_graph(fluid_name)
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local function node(node_type, name, op)
        local added = gutils.add_node(graph, node_type, name)
        added.op = op
        return added
    end
    local function orand_edge(start, stop)
        local orand = node("orand", start.type .. start.name .. stop.type .. stop.name, "AND")
        gutils.add_edge(graph, key(start), key(orand))
        gutils.add_edge(graph, key(orand), key(stop))
    end
    local fluid_node = node("fluid", fluid_name, "OR")
    local temperature = node("fluid-temperature", key(fluid_name, "15"), "AND")
    orand_edge(temperature, fluid_node)
    local create = node("fluid-create-temperature", key(fluid_name, "15"), "OR")
    gutils.add_edge(graph, key(create), key(temperature))
    local craft = node("fluid-craft-temperature", key(fluid_name, "15"), "OR")
    orand_edge(craft, create)
    local hold = node("fluid-hold", fluid_name, "OR")
    gutils.add_edge(graph, key(hold), key(temperature))
    return graph, temperature, fluid_node, create
end

test("fluid slots are single-temperature fluids made by recipes, mining and pumping", function()
    data.raw.fluid = {}
    data.raw.resource = {
        well = {
            type = "resource",
            name = "well",
        },
    }
    add_fluid("gas")
    local graph, temperature, fluid_node, create = toy_fluid_graph("gas")
    assert(item_fluid.fluid_slot_ok(graph, temperature, {}))
    assert(not item_fluid.fluid_slot_ok(graph, temperature, { ["fluid-gas"] = { type = "fluid", name = "gas" } }), "a round trip material")
    randomization_info.options.first_pass.blacklist[key("fluid", "gas")] = true
    assert(not item_fluid.fluid_slot_ok(graph, temperature, {}), "blacklisted")
    randomization_info.options.first_pass.blacklist = {}
    -- Mined from a resource is fine
    local well = gutils.add_node(graph, "entity-mine", "well")
    well.op = "AND"
    local orand = gutils.add_node(graph, "orand", "well")
    orand.op = "AND"
    gutils.add_edge(graph, key(well), key(orand))
    gutils.add_edge(graph, key(orand), key(create))
    assert(item_fluid.fluid_slot_ok(graph, temperature, {}))
    -- A second temperature (like steam's) isn't
    local hot = gutils.add_node(graph, "fluid-temperature", key("gas", "500"))
    hot.op = "AND"
    local hot_orand = gutils.add_node(graph, "orand", "hot")
    hot_orand.op = "AND"
    gutils.add_edge(graph, key(hot), key(hot_orand))
    gutils.add_edge(graph, key(hot_orand), key(fluid_node))
    assert(not item_fluid.fluid_slot_ok(graph, temperature, {}))
end)

test("a fluid made by operating a machine (like a boiler's steam) isn't a slot", function()
    data.raw.fluid = {}
    data.raw.resource = {}
    add_fluid("gas")
    local graph, temperature, _, create = toy_fluid_graph("gas")
    local boiler = gutils.add_node(graph, "entity-operate", "boiler")
    boiler.op = "AND"
    local orand = gutils.add_node(graph, "orand", "boiler")
    orand.op = "AND"
    gutils.add_edge(graph, key(boiler), key(orand))
    gutils.add_edge(graph, key(orand), key(create))
    assert(not item_fluid.fluid_slot_ok(graph, temperature, {}))
end)

test("an item at a fluid position loses what delivery brings it, and nothing else", function()
    data.raw.item = {}
    data.raw.fluid = {}
    add_item("widget", true)
    add_fluid("gas")
    local graph, item_trav = toy_split_graph("widget", "gas")
    item_fluid.cut_delivery(graph, key(item_trav))
    local sources = {}
    for _, prenode in pairs(gutils.prenodes(graph, item_trav)) do
        if prenode.type == "orand" then
            prenode = gutils.unique_prenode(graph, prenode)
        end
        table.insert(sources, prenode.type)
    end
    assert(#sources == 1 and sources[1] == "head", "delivery still feeds the trav")
    assert(graph.nodes[key("item-launch", "widget")] ~= nil and next(item_trav.dep) ~= nil, "the chain's nodes stay")
end)

test("mining that needs a fluid moves from the fluid's node to its position", function()
    data.raw.item = {}
    data.raw.fluid = {}
    add_item("widget", true)
    add_fluid("gas")
    local graph, _, _, fluid_node, fluid_slot = toy_split_graph("widget", "gas")
    local ore = gutils.add_node(graph, "entity-mine", "ore")
    ore.op = "AND"
    gutils.add_edge(graph, key(fluid_node), key(ore))
    local boiler = gutils.add_node(graph, "entity-operate-fluid", "boiler")
    boiler.op = "OR"
    gutils.add_edge(graph, key(fluid_node), key(boiler))
    item_fluid.move_position_deps(graph, key(fluid_slot))
    assert(graph.edges[gutils.ekey({ start = key(fluid_slot), stop = key(ore) })] ~= nil)
    assert(graph.edges[gutils.ekey({ start = key(fluid_node), stop = key(ore) })] == nil)
    assert(graph.edges[gutils.ekey({ start = key(fluid_node), stop = key(boiler) })] ~= nil, "an identity role stays")
end)

test("converted prototypes take the identity's name and look, and the position's flow and stacking", function()
    local item = {
        type = "item",
        name = "widget",
        icon = "widget.png",
        icon_size = 64,
        order = "w",
        stack_size = 100,
    }
    local position_fluid = {
        type = "fluid",
        name = "gas",
        default_temperature = 25,
        max_temperature = 100,
        base_color = { 1, 0, 0 },
        flow_color = { 1, 0, 0 },
        fuel_value = "1MJ",
        icon = "gas.png",
    }
    local fluid = item_fluid.fluid_from_item(item, position_fluid)
    assert(fluid.type == "fluid" and fluid.name == "widget" and fluid.icon == "widget.png")
    assert(fluid.default_temperature == 25 and fluid.max_temperature == 100)
    assert(fluid.fuel_value == nil and fluid.auto_barrel == false)
    local position_item = {
        type = "item",
        name = "gear",
        subgroup = "intermediate",
        order = "g",
        stack_size = 200,
        weight = 1000,
    }
    local new_item = item_fluid.item_from_fluid(position_fluid, position_item)
    assert(new_item.type == "item" and new_item.name == "gas" and new_item.icon == "gas.png")
    assert(new_item.stack_size == 200 and new_item.weight == 1000 and new_item.subgroup == "intermediate")
end)

test("checks find a material's nodes under the identity reflection put at its position", function()
    data.raw.fluid = {}
    add_fluid("gas")
    data.raw.fluid.gas.default_temperature = 25
    add_fluid("rock-melt")
    -- Node types as logic's builder records them: the class each was built under is its canonical type
    local item_class = gutils.deconstruct(key("item", "x")).type
    local fluid_class = gutils.deconstruct(key("fluid", "x")).type
    local type_info = {
        ["thing"] = { canonical = item_class },
        ["thing-made"] = { canonical = item_class },
        ["liquid"] = { canonical = fluid_class },
        ["liquid-at"] = { canonical = fluid_class },
        ["liquid-in-range"] = { canonical = fluid_class },
        ["process"] = { canonical = "process" },
        ["machine-needing-liquid"] = { canonical = "machine" },
    }
    local renames = {
        [key("item", "gear")] = { type = "fluid", name = "oil" },
        [key("fluid", "oil")] = { type = "item", name = "gear" },
        [key("fluid", "sea")] = { type = "fluid", name = "gas" },
        [key("fluid", "lake")] = { type = "fluid", name = "rock-melt" },
        [key("item", "plate")] = { type = "item", name = "powder" },
    }
    -- Items: every node type built for the item follows it
    assert(item_fluid.final_node_key(key("thing", "plate"), renames, type_info) == key("thing", "powder"))
    assert(item_fluid.final_node_key(key("thing-made", "plate"), renames, type_info) == key("thing-made", "powder"))
    -- Changing form: gear's position has an item named after the fluid now, and oil's position a fluid named after the item
    assert(item_fluid.final_node_key(key("thing", "gear"), renames, type_info) == key("thing", "oil"))
    assert(item_fluid.final_node_key(key("liquid", "oil"), renames, type_info) == key("liquid", "gear"))
    -- Fluids: by name, and with a temperature (the identity's own default) or a range (kept)
    assert(item_fluid.final_node_key(key("liquid", "sea"), renames, type_info) == key("liquid", "gas"))
    assert(item_fluid.final_node_key(key("liquid-at", key("sea", "15")), renames, type_info) == key("liquid-at", key("gas", "25")))
    assert(item_fluid.final_node_key(key("liquid-in-range", key("sea", key("nil", "nil"))), renames, type_info) == key("liquid-in-range", key("gas", key("nil", "nil"))))
    -- A fluid an item became takes its position's temperature (it's a copy of the position's fluid)
    assert(item_fluid.final_node_key(key("liquid-at", key("lake", "15")), renames, type_info) == key("liquid-at", key("rock-melt", "15")))
    -- Other nodes, and everything without renames, keep their keys
    assert(item_fluid.final_node_key(key("process", "plate"), renames, type_info) == key("process", "plate"))
    assert(item_fluid.final_node_key(key("machine-needing-liquid", "boiler"), renames, type_info) == key("machine-needing-liquid", "boiler"))
    assert(item_fluid.final_node_key(key("thing", "plate"), nil, type_info) == key("thing", "plate"))
end)

----------------------------------------------------------------------------------------------------
-- Machines taking fluids
----------------------------------------------------------------------------------------------------

local function count(list, value)
    local num = 0
    for _, entry in pairs(list) do
        if entry == value then
            num = num + 1
        end
    end
    return num
end

test("new fluid boxes cover the biggest recipe's ingredients and results first, then alternate", function()
    -- A machine with 1 in and 1 out whose biggest recipe takes 6 things and makes 2
    local directions = fluid_ports.box_directions(9, 1, 1, 6, 2, false)
    assert(#directions == 9)
    assert(count(directions, "input") == 7 and count(directions, "output") == 2, "5 inputs, 1 output, then 2 inputs and 1 output alternating")
    -- Shortfalls come first
    local first_six = { table.unpack(directions, 1, 6) }
    assert(count(first_six, "input") == 5 and count(first_six, "output") == 1)
end)

test("furnaces get one fluid input at most, since they pick recipes by one ingredient", function()
    local directions = fluid_ports.box_directions(5, 0, 0, 1, 1, true)
    assert(count(directions, "input") == 1 and count(directions, "output") == 4)
    local none_more = fluid_ports.box_directions(3, 1, 0, 1, 3, true)
    assert(count(none_more, "input") == 0)
end)

test("a recipe with a fluid leaves hand crafting's category and keeps its others", function()
    local hand = fluid_ports.HAND_CATEGORY
    local with_fluid = fluid_ports.HAND_CATEGORY_WITH_FLUID
    local recipe = {
        type = "recipe",
        name = "r",
        categories = { hand, "other-category" },
        ingredients = {
            { type = "item", name = "a", amount = 1 },
            { type = "fluid", name = "gas", amount = 10 },
        },
        results = {},
    }
    local cats = fluid_ports.categories_with_fluid(recipe)
    assert(cats[1] == with_fluid and cats[2] == "other-category" and #cats == 2)
    -- The engine's default category counts as hand crafting's
    recipe.categories = nil
    cats = fluid_ports.categories_with_fluid(recipe)
    assert(#cats == 1 and cats[1] == with_fluid)
    -- Fluid results count too, since the character has no fluid boxes at all
    recipe.ingredients = { { type = "item", name = "a", amount = 1 } }
    recipe.results = { { type = "fluid", name = "gas", amount = 10 } }
    assert(fluid_ports.categories_with_fluid(recipe) ~= nil)
    -- No fluid, or no hand crafting category: nothing changes
    recipe.results = { { type = "item", name = "b", amount = 1 } }
    assert(fluid_ports.categories_with_fluid(recipe) == nil)
    recipe.results = { { type = "fluid", name = "gas", amount = 10 } }
    recipe.categories = { "other-category" }
    assert(fluid_ports.categories_with_fluid(recipe) == nil)
    -- Already both: no duplicate
    recipe.categories = { hand, with_fluid }
    cats = fluid_ports.categories_with_fluid(recipe)
    assert(#cats == 1 and cats[1] == with_fluid)
end)

test("a pipe connection takes one side of its tile, so a corner keeps its other side", function()
    local machine = {
        type = "assembling-machine",
        name = "m",
        collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
        fluid_boxes = {
            {
                production_type = "input",
                pipe_connections = {
                    { flow_direction = "input", direction = defines.direction.north, position = { -1, -1 } },
                },
            },
        },
    }
    local free = pipe_conns.get_available_pipe_connections(machine)
    -- A 3x3 machine has 12 connection points: 3 tiles on each side, corners counted once per side
    assert(#free == 11, "expected 11 free points, got " .. #free)
    local corner_west_free = false
    for _, point in pairs(free) do
        assert(not (point.position[1] == -1 and point.position[2] == -1 and point.direction == defines.direction.north), "the taken side is free")
        if point.position[1] == -1 and point.position[2] == -1 and point.direction == defines.direction.west then
            corner_west_free = true
        end
    end
    assert(corner_west_free, "the corner's other side isn't free")
    -- A heat connection takes its whole tile
    machine.energy_source = {
        type = "heat",
        connections = {
            { position = { 1, 1 }, direction = defines.direction.south },
        },
    }
    assert(#pipe_conns.get_available_pipe_connections(machine) == 9)
    assert(#pipe_conns.get_available_pipe_connections(machine, true) == 11, "ignoring the energy source frees its tile")
end)

print(num_passed .. " tests passed")

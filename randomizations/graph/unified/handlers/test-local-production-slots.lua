-- Run from the mod root: lua randomizations/graph/unified/handlers/test-local-production-slots.lua
-- Local production positions must preserve separate planet chains while sharing physical item supplies.

function table.deepcopy(value)
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for k, v in pairs(value) do
        copy[k] = table.deepcopy(v)
    end
    return copy
end
local stalled = 0
local reported_resources
function log(message)
    if string.find(message, "added 0 needs", 1, true) then stalled = stalled + 1 end
    reported_resources = tonumber(string.match(message, "of (%d+) resource slots")) or reported_resources
end
serpent = { block = tostring }
util = {
    parse_energy = function(value)
        return assert(tonumber(string.match(value, "^[%d.]+")))
    end,
}
mods = {}
ITEM_ENABLED = true
config = { item_fluids = false }
defines = {
    prototypes = {
        item = {},
        entity = {},
    },
}
data = { raw = {} }
data.raw.item = {}
data.raw.recipe = {}
data.raw.resource = {}
data.raw.lab = {}
data.raw.planet = {}
data.raw["surface-property"] = {}
data.raw.fluid = {}
data.raw.technology = {}
data.raw["mining-drill"] = {}
local logic = {
    type_info = setmetatable({}, {
        __index = function(types, class)
            local info = {}
            rawset(types, class, info)
            return info
        end,
    }),
    contexts = {},
}
logic.type_info.room = { context = "room" }
package.loaded["lib/logic/init"] = logic
package.loaded["lib/logic/state"] = logic
package.loaded["lib/lookup/init"] = {}
package.loaded["lib/old-logic/build-graph"] = {}
package.loaded["lib/logic/bootstrap"] = {
    justifications = function() return {} end,
}
local excluded = {}
local selected_items = true
package.loaded["lib/graph-customization"] = {
    selected = function(id, node)
        return (id ~= "item" or selected_items == true) and excluded[node.name] == nil
    end,
    excluded = function(_, node) return excluded[node.name] ~= nil end,
}
local rng_states = {}
local rng = {}
rng.value = function(key)
    rng_states[key] = ((rng_states[key] or 17) * 48271) % 2147483647
    return rng_states[key] / 2147483647
end
rng.int = function(key, n) return math.floor(rng.value(key) * n) + 1 end
rng.key = function(params) return params.id end
rng.shuffle = function(key, list)
    for i = #list, 2, -1 do
        local j = rng.int(key, i)
        list[i], list[j] = list[j], list[i]
    end
end
package.loaded["lib/random/rng"] = rng
package.loaded["resource-autoplace"] = {}
randomization_info = {
    options = {
        cost = { major_raw_resources = {} },
        first_pass = {
            blacklist = {},
            always_slot_pre = {},
            always_slot_dep = {},
        },
    },
}

local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")
local first_pass = require("randomizations/graph/unified/first-pass")
local mining = require("randomizations/graph/unified/handlers/mining-results")
local item = require("randomizations/graph/unified/handlers/item")
local item_fluid = require("lib/item-fluid")
local invariants = require("tests/graph-invariants")
local recycling = require("lib/recycling")
local recipe_ingredients = require("randomizations/graph/unified/handlers/recipe-ingredients")
local staged_recipes = require("lib/cost/staged-recipes")

local key = gutils.key
randomization_info.options.first_pass.always_slot_pre[key("recipe", "item")] = true
randomization_info.options.first_pass.always_slot_pre[key("item-craft", "item")] = true
randomization_info.options.first_pass.always_slot_pre[key("item", "item")] = true
randomization_info.options.first_pass.always_slot_pre[key("entity-mine", "item")] = true
randomization_info.options.first_pass.always_slot_dep[key("item", "recipe")] = true
local function prototype(class, name, fields)
    local result = fields or {}
    result.type = class
    result.name = name
    data.raw[class] = data.raw[class] or {}
    data.raw[class][name] = result
    return result
end

local surface_sets = require("lib/surface-sets")
local local_slots = require("randomizations/graph/unified/handler-helpers/local-production-slots")
local lutils = require("lib/logic/logic-utils")
local dupe = require("lib/dupe")
local locks = require("randomizations/planetary/locks")
surface_sets.room_keys = function()
    local rooms = {}
    for name, _ in pairs(data.raw.planet) do table.insert(rooms, key("planet", name)) end
    table.sort(rooms)
    return rooms
end
surface_sets.accepted = function(recipe)
    if recipe.recycling_rooms ~= nil then return recipe.recycling_rooms end
    if recipe.intermediate_planet ~= nil then return { [key("planet", recipe.intermediate_planet)] = true } end
    local rooms = {}
    for _, room in pairs(surface_sets.room_keys()) do rooms[room] = true end
    return rooms
end
function data:extend(prototypes)
    for _, value in pairs(prototypes) do
        self.raw[value.type] = self.raw[value.type] or {}
        self.raw[value.type][value.name] = value
    end
end

local crossed_planets = false
local crossed_shared = false
for trial = 1, 8 do
    data.raw.item = {}
    data.raw.recipe = {}
    data.raw.resource = {}
    data.raw.planet = {}
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local rooms = {}
    for i = 1, 2 do
        local room_name = key("planet", "test-world-" .. i)
        prototype("planet", "test-world-" .. i, { dupe_number = i == 2 and 2 or nil })
        logic.contexts[room_name] = true
        rooms[i] = gutils.add_node(graph, "room", room_name, { op = "AND" })
        local root = gutils.add_node(graph, "true", "test-root-" .. i, { op = "AND" })
        gutils.add_edge(graph, root, rooms[i])
    end
    for i = 1, 4 do
        local product = prototype("item", "test-item-" .. i, {
            stack_size = 100,
            place_result = i > 2 and "test-place-" .. i or nil,
        })
        defines.prototypes.item[product.type] = 0
        local material = gutils.add_node(graph, product.type, product.name, { op = "OR" })
        local craft = gutils.add_node(graph, "item-craft", product.name, { op = "OR" })
        gutils.add_edge(graph, craft, material)
    end
    for world = 1, 2 do
        for i = 1, 2 do
            local resource = prototype("resource", "test-deposit-" .. world .. "-" .. i, {
                minable = {
                    result = "test-item-" .. i,
                    count = 1,
                },
            })
            defines.prototypes.entity[resource.type] = 0
            local mine = gutils.add_node(graph, "entity-mine", resource.name, { op = "AND" })
            gutils.add_edge(graph, rooms[world], mine)
            gutils.add_edge(graph, mine, key("item", resource.minable.result), { inds = { [1] = true } })
        end
        for i = 3, 4 do
            if i - 2 == world then
                local name = "test-make-" .. world .. "-" .. i
                local ingredients = {
                    {
                        type = "item",
                        name = "test-item-" .. ((i % 2) + 1),
                        amount = 1,
                    },
                }
                local recipe = prototype("recipe", name, {
                    intermediate_planet = "test-world-" .. world,
                    dupe_number = world == 2 and 2 or nil,
                    ingredients = ingredients,
                    main_product = "test-item-" .. i,
                    results = {
                        {
                            type = "item",
                            name = "test-item-" .. i,
                            amount = 1,
                        },
                    },
                })
                local maker = gutils.add_node(graph, recipe.type, recipe.name, { op = "AND" })
                gutils.add_edge(graph, rooms[world], maker)
                gutils.add_edge(graph, key("item", ingredients[1].name), maker)
                gutils.add_edge(graph, maker, key("item-craft", recipe.results[1].name), { inds = { [1] = true } })
                if trial > 4 then
                    local reverse = recycling.recipe_from_source(data.raw, recipe)
                    assert(reverse ~= nil)
                    data.raw.recipe[reverse.name] = reverse

                end
            end
        end
    end
    if trial > 4 then
        recycling.prepare_planetary()
        for name, recipe in pairs(data.raw.recipe) do
            if recipe.recycling_origin ~= nil then
                local recycler = gutils.add_node(graph, "recipe", name, { op = "AND" })
                local condition = gutils.add_node(graph, "recipe-surface-condition", name, { op = "OR" })
                gutils.add_edge(graph, condition, recycler)
                for room, _ in pairs(recipe.recycling_rooms) do
                    gutils.add_edge(graph, key("room", room), condition)
                end
                gutils.add_edge(graph, key("item", recipe.ingredients[1].name), recycler)
                for _, product in pairs(recipe.results) do
                    gutils.add_edge(graph, recycler, key("item-craft", product.name), { inds = { [1] = true } })
                end
            end
        end
    end
    for i = 3, 4 do
        local goal = gutils.add_node(graph, "entity-build-item", "test-use-" .. i, {
            op = "OR",
            mechanic = true,
            keep_isolatability = true,
        })
        gutils.add_edge(graph, key("item", "test-item-" .. i), goal)
    end
    old_data_raw = table.deepcopy(data.raw)
    local before_spoof = top.sort(graph, nil, nil, { complex_contexts = true, home_contexts = true })
    mining.initialize()
    mining.spoof(graph)
    first_pass.spoof(graph)
    local after_spoof = top.sort(graph, nil, nil, { complex_contexts = true, home_contexts = true })
    for node_key, contexts in pairs(before_spoof.node_to_context_inds) do
        for context, _ in pairs(contexts) do
            assert(top.provides_context(after_spoof.node_to_context_inds[node_key] or {}, context), "local preparation lost baseline supply: " .. node_key .. " @ " .. context)
        end
    end
    gutils.make_orands(graph)
    local result = first_pass.execute({
        spoofed_graph = graph,
        subdiv_graph = graph,
    })
    assert(result)
    invariants.test(result.graph)
    assert(reported_resources == 4, "the counter must count deposits, not shared material positions")
    local changed = 0
    for slot_key, trav_key in pairs(result.slot_to_trav) do
        local node = result.graph.nodes[slot_key]
        if node.production_slot ~= nil then
            local original = result.graph.nodes[result.graph.nodes[trav_key].old_slot]
            if original.production_slot == nil then
                crossed_shared = true
            elseif original.production_slot.planet ~= node.production_slot.planet then
                crossed_planets = true
            end
            if node.mining_slot ~= nil and item_fluid.material_of_node(result.graph, result.graph.nodes[trav_key]).name ~= node.mining_slot.material.name then
                changed = changed + 1
            end
        end
    end
    assert(changed == 4, "all four deposits have compatible replacements: changed " .. changed)
    mining.custom_prereq_search({
        split_graph = result.graph,
        slot_to_trav = result.slot_to_trav,
    })
    changes = {}
    mining.reflect()
    item.initialize()
    item.custom_prereq_search({
        split_graph = result.graph,
        slot_to_trav = result.slot_to_trav,
        trav_to_slot = result.trav_to_slot,
        mechanics_sets_to_ordered = result.mechanics_sets_to_ordered,
        mechanics_sets_to_nodes = result.mechanics_sets_to_nodes,
        trav_to_mechanics_key = result.trav_to_mechanics_key,
    })
    item.reflect({}, {}, {})
    for _, change in pairs(changes) do
        if change.multiplier ~= nil then
            change.tbl[change.prop] = change.tbl[change.prop] * change.multiplier
        else
            change.tbl[change.prop] = change.new_val
        end
    end
    for world = 1, 2 do
        local name = "test-make-" .. world .. "-" .. (world + 2)
        local recipe = data.raw.recipe[name]
        local old_ing = "test-item-" .. (((world + 2) % 2) + 1)
        local position_key = result.graph.local_recipe_positions[name][key("item", old_ing)]
        local expected = item_fluid.material_of_node(result.graph, result.graph.nodes[result.slot_to_trav[position_key]])
        assert(recipe.ingredients[1].name == expected.name, "local ingredient reflection disagrees with first pass")
        local output_position = result.graph.local_recipe_positions[name][key("item", "test-item-" .. (world + 2))]
        local output = item_fluid.material_of_node(result.graph, result.graph.nodes[result.slot_to_trav[output_position]])
        assert(recipe.results[1].name == output.name, "local result reflection disagrees with first pass")
        assert(recipe.main_product == output.name, "main product must follow the local result")
        if trial > 4 then
            local reverse = data.raw.recipe["test-item-" .. (world + 2) .. "-recycling"]
            assert(reverse.ingredients[1].name == recipe.results[1].name, "recycling must consume the local source's new output")
            assert(reverse.results[1].name == recipe.ingredients[1].name, "recycling must return the local source's new input")
        end
    end
    if trial > 4 then
        recycling.regenerate(old_data_raw)
    end
    -- Rebuild solely from the reflected prototypes, without any of first pass's synthetic aliases.
    local built = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local built_rooms = {}
    for world = 1, 2 do
        local root = gutils.add_node(built, "true", "test-built-root-" .. world, { op = "AND" })
        built_rooms[world] = gutils.add_node(built, "room", key("planet", "test-world-" .. world), { op = "AND" })
        gutils.add_edge(built, root, built_rooms[world])
    end
    local function material(name)
        return built.nodes[key("item", name)] or gutils.add_node(built, "item", name, { op = "OR" })
    end
    for world = 1, 2 do
        for i = 1, 2 do
            local resource = data.raw.resource["test-deposit-" .. world .. "-" .. i]
            local maker = gutils.add_node(built, "entity-mine", resource.name, { op = "AND" })
            gutils.add_edge(built, built_rooms[world], maker)
            gutils.add_edge(built, maker, material(resource.minable.result))
        end
        local recipe = data.raw.recipe["test-make-" .. world .. "-" .. (world + 2)]
        local maker = gutils.add_node(built, "recipe", recipe.name, { op = "AND" })
        gutils.add_edge(built, built_rooms[world], maker)
        gutils.add_edge(built, material(recipe.ingredients[1].name), maker)
        gutils.add_edge(built, maker, material(recipe.results[1].name))
        local craft_key = key("item-craft", recipe.results[1].name)
        local craft = built.nodes[craft_key] or gutils.add_node(built, "item-craft", recipe.results[1].name, { op = "OR" })
        gutils.add_edge(built, maker, craft)
    end
    if trial > 4 then
        for name, recipe in pairs(data.raw.recipe) do
            if recycling.looks_generated(recipe) then
                local maker = gutils.add_node(built, "recipe", name, { op = "AND" })
                gutils.add_edge(built, material(recipe.ingredients[1].name), maker)
                local condition = gutils.add_node(built, "recipe-surface-condition", name, { op = "OR" })
                gutils.add_edge(built, condition, maker)
                for world, room in pairs(built_rooms) do
                    if (recipe.recycling_rooms or {})[key("planet", "test-world-" .. world)] ~= nil then
                        gutils.add_edge(built, room, condition)
                    end
                end
                for _, product in pairs(recipe.results) do
                    gutils.add_edge(built, maker, material(product.name))
                    local craft_key = key("item-craft", product.name)
                    local craft = built.nodes[craft_key] or gutils.add_node(built, "item-craft", product.name, { op = "OR" })
                    gutils.add_edge(built, maker, craft)
                end
            end
        end
    end
    local actual = top.sort(built, nil, nil, {
        complex_contexts = true,
        home_contexts = true,
    })
    for slot_key, trav_key in pairs(result.slot_to_trav) do
        local physical = item_fluid.material_of_node(result.graph, result.graph.nodes[trav_key])
        for context, _ in pairs(result.sort.node_to_context_inds[trav_key] or {}) do
            assert(top.provides_context(actual.node_to_context_inds[key(physical)] or {}, context), "trial " .. trial .. ": modeled " .. key(physical) .. " at " .. slot_key .. " @ " .. context .. " is absent from the reflected world")
        end
    end
    for node_key, node in pairs(result.graph.nodes) do
        if node.craft_identity == true then
            local physical = gutils.deconstruct(node.name)
            for context, _ in pairs(result.sort.node_to_context_inds[node_key] or {}) do
                assert(top.provides_context(actual.node_to_context_inds[key("item-craft", physical.name)] or {}, context), "mining or delivery was mistaken for crafting in the reflected world")
            end
        end
    end
end
assert(crossed_planets, "local production identities never crossed planets")
assert(crossed_shared, "local production positions never exchanged with shared positions")
assert(stalled == 0, "local first pass fell back through stalled refinements")
print("ok - all four deposits change, including cross-planet and shared-position swaps, with reflected local chains across eight trials")

-- A local producer may be blocked while an imported copy still supplies the local consumer.
do
    data.raw.item = {}
    data.raw.recipe = {}
    data.raw.resource = {}
    data.raw.planet = {}
    local world = "test-import-world"
    prototype("planet", world, { dupe_number = 2 })
    logic.contexts[key("planet", world)] = true
    local graph = { nodes = {}, edges = {}, sources = {} }
    local root = gutils.add_node(graph, "true", "import-root", { op = "AND" })
    local room = gutils.add_node(graph, "room", key("planet", world), { op = "AND" })
    local blocked = gutils.add_node(graph, "false", "blocked-producer", { op = "OR" })
    gutils.add_edge(graph, root, room)
    for _, name in pairs({ "import-input", "import-output" }) do
        prototype("item", name, { stack_size = 100 })
        local material = gutils.add_node(graph, "item", name, { op = "OR" })
        local craft = gutils.add_node(graph, "item-craft", name, { op = "OR" })
        gutils.add_edge(graph, craft, material)
    end
    gutils.add_edge(graph, room, key("item", "import-input"))
    local producer = prototype("recipe", "blocked-local-producer", {
        intermediate_planet = world,
        dupe_number = 2,
        results = { { type = "item", name = "import-input", amount = 1 } },
    })
    local consumer = prototype("recipe", "local-import-consumer", {
        intermediate_planet = world,
        dupe_number = 2,
        ingredients = { { type = "item", name = "import-input", amount = 1 } },
        results = { { type = "item", name = "import-output", amount = 1 } },
    })
    local make = gutils.add_node(graph, "recipe", producer.name, { op = "AND" })
    local use = gutils.add_node(graph, "recipe", consumer.name, { op = "AND" })
    gutils.add_edge(graph, blocked, make)
    gutils.add_edge(graph, make, key("item-craft", "import-input"))
    gutils.add_edge(graph, room, use)
    gutils.add_edge(graph, key("item", "import-input"), use)
    gutils.add_edge(graph, use, key("item-craft", "import-output"))
    old_data_raw = table.deepcopy(data.raw)
    local before = top.sort(graph, nil, nil, { complex_contexts = true })
    local_slots.spoof(graph)
    invariants.test(graph)
    local after = top.sort(graph, nil, nil, { complex_contexts = true })
    assert(next(before.node_to_context_inds[key(use)] or {}) ~= nil)
    for context, _ in pairs(before.node_to_context_inds[key(use)]) do
        assert(top.provides_context(after.node_to_context_inds[key(use)] or {}, context), "preparation must preserve imports even when local production is blocked")
    end
end
print("ok - preparing local positions preserves shared supplies before matching")

-- Fluids use local creation/holding positions and local ingredient ranges too.
data.raw.item = {}
data.raw.recipe = {}
data.raw.resource = {}
data.raw.fluid = {}
data.raw.planet = {}
config.item_fluids = true
randomization_info.options.first_pass.always_slot_pre[key("fluid-create-temperature", "fluid-temperature")] = true
randomization_info.options.first_pass.always_slot_pre[key("fluid-hold", "fluid-temperature")] = true
randomization_info.options.first_pass.always_slot_dep[key("fluid-temperature", "fluid-temperature-range")] = true
local graph = { nodes = {}, edges = {}, sources = {} }
local rooms = {}
for world = 1, 2 do
    local name = "test-fluid-world-" .. world
    prototype("planet", name, { dupe_number = world == 2 and 2 or nil })
    logic.contexts[key("planet", name)] = true
    local root = gutils.add_node(graph, "true", "test-fluid-root-" .. world, { op = "AND" })
    rooms[world] = gutils.add_node(graph, "room", key("planet", name), { op = "AND" })
    gutils.add_edge(graph, root, rooms[world])
end
for i = 1, 4 do
    local fluid = prototype("fluid", "test-fluid-" .. i, { default_temperature = i * 10 })
    local aggregate = gutils.add_node(graph, fluid.type, fluid.name, { op = "OR" })
    local temperature_name = key(fluid.name, tostring(fluid.default_temperature))
    local temperature = gutils.add_node(graph, "fluid-temperature", temperature_name, { op = "AND" })
    local create = gutils.add_node(graph, "fluid-create-temperature", temperature_name, { op = "OR" })
    local craft = gutils.add_node(graph, "fluid-craft-temperature", temperature_name, { op = "OR" })
    local hold = gutils.add_node(graph, "fluid-hold", fluid.name, { op = "OR" })
    local range = gutils.add_node(graph, "fluid-temperature-range", key(fluid.name, key("nil", "nil")), { op = "OR" })
    for _, room in pairs(rooms) do gutils.add_edge(graph, room, hold) end
    gutils.add_edge(graph, craft, create)
    gutils.add_edge(graph, create, temperature)
    gutils.add_edge(graph, hold, temperature)
    gutils.add_edge(graph, temperature, aggregate)
    gutils.add_edge(graph, temperature, range)
end
for world = 1, 2 do
    for i = 1, 2 do
        local name = "test-fluid-deposit-" .. world .. "-" .. i
        local product = {
            type = "fluid",
            name = "test-fluid-" .. i,
            amount = 3,
        }
        product.temperature = i * 10
        local resource = prototype("resource", name, {
            minable = { results = { product } },
        })
        local mine = gutils.add_node(graph, "entity-mine", name, { op = "AND" })
        gutils.add_edge(graph, rooms[world], mine)
        gutils.add_edge(graph, mine, key("fluid-create-temperature", key(resource.minable.results[1].name, tostring(i * 10))), { inds = { [1] = true } })
    end
    local name = "test-fluid-process-" .. world
    local recipe = prototype("recipe", name, {
        intermediate_planet = "test-fluid-world-" .. world,
        dupe_number = world == 2 and 2 or nil,
        ingredients = { { type = "fluid", name = "test-fluid-" .. world, amount = 2 } },
        results = {
            {
                type = "fluid",
                name = "test-fluid-" .. (world + 2),
                amount = 1,
            },
        },
    })
    recipe.results[1].temperature = (world + 2) * 10
    local maker = gutils.add_node(graph, recipe.type, name, { op = "AND" })
    gutils.add_edge(graph, rooms[world], maker)
    gutils.add_edge(graph, key("fluid-temperature-range", key(recipe.ingredients[1].name, key("nil", "nil"))), maker)
    gutils.add_edge(graph, maker, key("fluid-craft-temperature", key(recipe.results[1].name, tostring((world + 2) * 10))), { inds = { [1] = true } })
    local goal = gutils.add_node(graph, "fluid-use", name, { op = "OR", mechanic = true, keep_isolatability = true })
    gutils.add_edge(graph, key("fluid", recipe.results[1].name), goal)
end
old_data_raw = table.deepcopy(data.raw)
mining.initialize()
mining.spoof(graph)
first_pass.spoof(graph)
gutils.make_orands(graph)
local result = first_pass.execute({ spoofed_graph = graph, subdiv_graph = graph })
assert(result)
invariants.test(result.graph)
local changed = 0
for slot_key, trav_key in pairs(result.slot_to_trav) do
    local node = result.graph.nodes[slot_key]
    if node.production_slot ~= nil and node.type == "fluid-temperature" then
        local original = result.graph.nodes[result.graph.nodes[trav_key].old_slot]
        assert(item_fluid.material_of_node(result.graph, original).type == "fluid")
        if node.mining_slot ~= nil and item_fluid.material_of_node(result.graph, result.graph.nodes[trav_key]).name ~= node.mining_slot.material.name then
            changed = changed + 1
        end
    end
end
assert(changed == 4, "every duplicate fluid deposit should change when its planet admits a complete derangement")
changes = {}
mining.custom_prereq_search({ split_graph = result.graph, slot_to_trav = result.slot_to_trav })
mining.reflect()
item.initialize()
item.custom_prereq_search({
    split_graph = result.graph,
    slot_to_trav = result.slot_to_trav,
    trav_to_slot = result.trav_to_slot,
    mechanics_sets_to_ordered = result.mechanics_sets_to_ordered,
    mechanics_sets_to_nodes = result.mechanics_sets_to_nodes,
    trav_to_mechanics_key = result.trav_to_mechanics_key,
})
item.reflect({}, {}, {})
for _, change in pairs(changes) do
    if change.multiplier ~= nil then
        change.tbl[change.prop] = change.tbl[change.prop] * change.multiplier
    else
        change.tbl[change.prop] = change.new_val
    end
end
for world = 1, 2 do
    local name = "test-fluid-process-" .. world
    local recipe = data.raw.recipe[name]
    local position = result.graph.local_recipe_positions[name][key("fluid", "test-fluid-" .. world)]
    local ingredient = item_fluid.material_of_node(result.graph, result.graph.nodes[result.slot_to_trav[position]])
    assert(recipe.ingredients[1].name == ingredient.name)
    position = result.graph.local_recipe_positions[name][key("fluid", "test-fluid-" .. (world + 2))]
    local product = item_fluid.material_of_node(result.graph, result.graph.nodes[result.slot_to_trav[position]])
    assert(recipe.results[1].name == product.name)
    assert(recipe.results[1].temperature == product.temperature)
end
local built = { nodes = {}, edges = {}, sources = {} }
local physical_rooms = {}
for world = 1, 2 do
    local root = gutils.add_node(built, "true", "test-fluid-built-root-" .. world, { op = "AND" })
    local room = gutils.add_node(built, "room", key("planet", "test-fluid-world-" .. world), { op = "AND" })
    physical_rooms[world] = room
    gutils.add_edge(built, root, room)
end
local function physical_fluid(name)
    return built.nodes[key("fluid", name)] or gutils.add_node(built, "fluid", name, { op = "OR" })
end
for world = 1, 2 do
    for i = 1, 2 do
        local name = "test-fluid-deposit-" .. world .. "-" .. i
        local product = data.raw.resource[name].minable.results[1]
        local mine = gutils.add_node(built, "entity-mine", name, { op = "AND" })
        gutils.add_edge(built, physical_rooms[world], mine)
        gutils.add_edge(built, mine, physical_fluid(product.name))
    end
    local name = "test-fluid-process-" .. world
    local recipe = data.raw.recipe[name]
    local maker = gutils.add_node(built, recipe.type, name, { op = "AND" })
    gutils.add_edge(built, physical_rooms[world], maker)
    gutils.add_edge(built, physical_fluid(recipe.ingredients[1].name), maker)
    gutils.add_edge(built, maker, physical_fluid(recipe.results[1].name))
end
local actual = top.sort(built, nil, nil, { complex_contexts = true, home_contexts = true })
for _, trav_key in pairs(result.slot_to_trav) do
    local material = item_fluid.material_of_node(result.graph, result.graph.nodes[trav_key])
    for context, _ in pairs(result.sort.node_to_context_inds[trav_key] or {}) do
        assert(top.provides_context(actual.node_to_context_inds[key(material)] or {}, context), "local fluid aliases promised a supply absent from the reflected prototypes")
    end
end
assert(stalled == 0, "local fluid first pass fell back through stalled refinements")
print("ok - all four local fluid deposits change and processing recipes keep the chosen fluid and temperature")
config.item_fluids = false

-- Placement still owns a deposit whose mining prerequisites are unavailable.
data.raw.item = {}
data.raw.recipe = {}
data.raw.resource = {}
data.raw.planet = {}
local owner = prototype("planet", "test-unreachable-world", { dupe_number = 2 })
local resource = prototype("resource", "test-unreachable-deposit", {
    autoplace = {},
    minable = { result = "test-unreachable-ore" },
})
local ore = prototype("item", resource.minable.result, { stack_size = 100 })
local output = prototype("item", "test-unreachable-product", { stack_size = 100 })
local recipe = prototype("recipe", "test-unreachable-process", {
    dupe_number = 2,
    intermediate_planet = owner.name,
    ingredients = { { type = "item", name = ore.name, amount = 1 } },
    results = { { type = "item", name = output.name, amount = 1 } },
})
local graph = { nodes = {}, edges = {}, sources = {} }
local blocked = gutils.add_node(graph, "false", "test-unavailable-mining", { op = "OR" })
local mine = gutils.add_node(graph, "entity-mine", resource.name, { op = "AND" })
local material = gutils.add_node(graph, ore.type, ore.name, { op = "OR" })
local product = gutils.add_node(graph, output.type, output.name, { op = "OR" })
local maker = gutils.add_node(graph, recipe.type, recipe.name, { op = "AND" })
gutils.add_edge(graph, blocked, mine)
gutils.add_edge(graph, mine, material, { inds = { [1] = true } })
gutils.add_edge(graph, material, maker)
gutils.add_edge(graph, maker, product, { inds = { [1] = true } })
lutils.check_in_room = function(planet, entity)
    return planet.name == owner.name and entity.name == resource.name
end
mining.spoof(graph)
local_slots.spoof(graph)
local found = false
for _, node in pairs(graph.nodes) do
    if node.mining_slot ~= nil then
        assert(node.production_slot.planet == owner.name)
        found = true
    end
end
assert(found, "unreachable deposits still need local production positions")
print("ok - placement determines deposit ownership even before mining is reachable")

-- A shared boundary recipe must be split before the starting-world proof is captured.
data.raw.recipe = {}
data.raw.resource = {}
data.raw.planet = {}
data.raw.technology = {}
local base_room = key("planet", "test-base")
local copy_room = key("planet", "test-copy")
prototype("planet", "test-base", {})
prototype("planet", "test-copy", { dupe_number = 2 })
prototype("resource", "test-boundary-deposit", {
    autoplace = {},
    minable = { result = "test-boundary-ore" },
})
local boundary_recipe = prototype("recipe", "test-boundary-process", {
    categories = { "test-boundary-category" },
    ingredients = {
        {
            type = "item",
            name = "test-boundary-ore",
            amount = 1,
        },
    },
    results = {
        {
            type = "item",
            name = "test-boundary-plate",
            amount = 1,
        },
    },
})
local discovery = prototype("technology", "test-discover-copy", {})
-- These use the deposit item too, but represent a fluid's fixed container identity.
prototype("recipe", "test-fill-container", {
    ingredients = {
        { type = "fluid", name = "test-held-fluid", amount = 50 },
        { type = "item", name = "test-boundary-ore", amount = 1 },
    },
    results = { { type = "item", name = "test-filled-container", amount = 1 } },
})
prototype("recipe", "test-empty-container", {
    ingredients = { { type = "item", name = "test-filled-container", amount = 1 } },
    results = {
        { type = "fluid", name = "test-held-fluid", amount = 50 },
        { type = "item", name = "test-boundary-ore", amount = 1 },
    },
})
discovery.effects = {
    {
        type = "unlock-space-location",
        space_location = "test-copy",
    },
}
surface_sets.accepted = function() return { [base_room] = true, [copy_room] = true } end
lutils.check_in_room = function() return true end
data.raw.furnace = {}
prototype("furnace", "test-local-furnace", { crafting_categories = table.deepcopy(boundary_recipe.categories) })
prototype("furnace", "test-other-furnace", { crafting_categories = { "test-other-category" } })
function data:extend(prototypes)
    for _, entry in pairs(prototypes) do
        prototype(entry.type, entry.name, entry)
    end
end
local prepared = {}
dupe.recipe = function(recipe, options)
    assert(options.dupe_number == nil or options.dupe_number == 2)
    assert(options.home_discovery == (options.dupe_number == 2 and discovery or nil))
    local copy = table.deepcopy(recipe)
    copy.name = recipe.name .. "-" .. options.suffix
    copy.dupe_number = options.dupe_number
    copy.orig_name = recipe.name
    data.raw.recipe[copy.name] = copy
    table.insert(prepared, copy)
    return copy
end
local fixed = {}
locks.fix = function(_, name, rooms) fixed[name] = rooms end
locks.realize = function() end
first_pass.prepare()
assert(#prepared == 2)
assert(fixed["test-fill-container"] == nil and fixed["test-empty-container"] == nil)
for _, recipe in pairs(prepared) do
    assert(recipe.results[1].name == "test-boundary-plate")
    assert(fixed[recipe.name][key("planet", recipe.intermediate_planet)] == true)
end
assert(fixed["test-boundary-process"][copy_room] == nil)
assert(fixed["test-boundary-process"][base_room] == nil)
assert(data.raw.furnace["test-local-furnace"] == nil)
assert(data.raw["assembling-machine"]["test-local-furnace"].crafting_categories[1] == boundary_recipe.categories[1])
assert(data.raw.furnace["test-other-furnace"] ~= nil)
print("ok - original and copied planets get independent resource-processing variants with appropriate unlocks")

recipe_ingredients.initialize()
assert(recipe_ingredients.claim({}, { type = "fluid-temperature-range", name = key("test-held-fluid", key("nil", "nil")) },
    { type = "recipe", name = "test-fill-container" }, {}) == false)
print("ok - filling a container keeps the held fluid edge available to first pass's identity handling")

-- A source changed to fluid-only ingredients leaves a pending reverse in staged pricing.
-- That pricing marker must never erase the generated recipe's physical input.
data.raw.item = {
    ["test-return"] = { type = "item", name = "test-return", stack_size = 100 },
    ["test-recycle-input"] = { type = "item", name = "test-recycle-input", stack_size = 100 },
}
data.raw.recipe = {}
local source = prototype("recipe", "test-recycle-source", {
    ingredients = { { type = "item", name = "test-return", amount = 4 } },
    results = { { type = "item", name = "test-recycle-input", amount = 1 } },
})
local reverse = recycling.recipe_from_source(data.raw, source)
data.raw.recipe[reverse.name] = reverse
data.raw = table.deepcopy(data.raw)
source = data.raw.recipe[source.name]
reverse = data.raw.recipe[reverse.name]
local overrides = { [source.name] = { "blacklisted" } }
local staged = staged_recipes.new(data.raw, overrides)
overrides[source.name] = { { type = "fluid", name = "test-held-fluid", amount = 20 } }
staged.update(source.name)
assert(overrides[reverse.name][1] == "blacklisted")
-- Supply the handler's private search result, without running unrelated cost searches.
local injected = false
for i = 1, 100 do
    local name = debug.getupvalue(recipe_ingredients.reflect, i)
    if name == nil then break end
    if name == "dependent_to_new_ings" then
        debug.setupvalue(recipe_ingredients.reflect, i, overrides)
        injected = true
        break
    end
end
assert(injected)
recipe_ingredients.reflect({}, {}, {})
assert(source.ingredients[1].type == "fluid")
assert(reverse.ingredients[1].name == "test-recycle-input")
assert(overrides[reverse.name][1] == "blacklisted", "reflection must not consume staged recycling markers")
print("ok - staged recycling markers cannot erase generated recycling inputs during reflection")

-- Exercise cross-form assignments through real first pass, local recipes, and mining reflection.
surface_sets.accepted = function(recipe)
    if recipe.intermediate_planet ~= nil then return { [key("planet", recipe.intermediate_planet)] = true } end
    local rooms = {}
    for _, room in pairs(surface_sets.room_keys()) do rooms[room] = true end
    return rooms
end
local cross_form_deposits = 0
local fluid_deposits_to_items = 0
local item_deposits_to_fluids = 0
local cross_form_recipes = 0
for trial = 1, 4 do
    data.raw.item, data.raw.fluid, data.raw.recipe, data.raw.resource, data.raw.planet = {}, {}, {}, {}, {}
    config.item_fluids = true
    local graph = { nodes = {}, edges = {}, sources = {} }
    local materials = {}
    for i = 1, 4 do
        local form = i % 2 == 0 and "fluid" or "item"
        local name = "form-material-" .. i
        prototype(form, name, { stack_size = form == "item" and 100 or nil, default_temperature = form == "fluid" and 25 or nil })
        local material = gutils.add_node(graph, form, name, { op = "OR" })
        local craft = gutils.add_node(graph, form == "item" and "item-craft" or "fluid-craft-temperature", form == "item" and name or key(name, "25"), { op = "OR" })
        materials[i] = { form = form, name = name, craft = craft, use = material, make = material }
        if form == "fluid" then
            local temperature = gutils.add_node(graph, "fluid-temperature", key(name, "25"), { op = "AND" })
            local create = gutils.add_node(graph, "fluid-create-temperature", temperature.name, { op = "OR" })
            local hold = gutils.add_node(graph, "fluid-hold", name, { op = "AND" })
            local range = gutils.add_node(graph, "fluid-temperature-range", key(name, key("nil", "nil")), { op = "OR" })
            gutils.add_edge(graph, craft, create)
            gutils.add_edge(graph, create, temperature)
            gutils.add_edge(graph, hold, temperature)
            gutils.add_edge(graph, temperature, material)
            gutils.add_edge(graph, temperature, range)
            materials[i].use, materials[i].make = range, create
        else
            gutils.add_edge(graph, craft, material)
        end
    end
    for input = 0, 1 do
        for output = 0, 1 do
            local category = item_fluid.recipe_category_key({}, { input = input, output = output })
            local parts = gutils.deconstruct(category)
            gutils.add_node(graph, parts.type, parts.name, { op = "AND" })
        end
        local category = item_fluid.resource_category_key({}, { input = 0, output = input })
        local parts = gutils.deconstruct(category)
        gutils.add_node(graph, parts.type, parts.name, { op = "AND" })
    end
    for world = 1, 2 do
        local planet = "form-world-" .. world
        prototype("planet", planet, { dupe_number = world == 2 and 2 or nil })
        logic.contexts[key("planet", planet)] = true
        local root = gutils.add_node(graph, "true", planet, { op = "AND" })
        local room = gutils.add_node(graph, "room", key("planet", planet), { op = "AND" })
        gutils.add_edge(graph, root, room)
        for i = 1, 2 do
            local material = materials[i]
            local resource = prototype("resource", "form-deposit-" .. world .. "-" .. i, {
                minable = { results = { { type = material.form, name = material.name, amount = 3, temperature = material.form == "fluid" and 25 or nil } } },
            })
            local mine = gutils.add_node(graph, "entity-mine", resource.name, { op = "AND" })
            gutils.add_edge(graph, room, mine)
            gutils.add_edge(graph, item_fluid.resource_category_key(resource, lutils.find_mining_fluids(resource)), mine)
            gutils.add_edge(graph, mine, material.make, { inds = { [1] = true } })
            local product = materials[i + 2]
            local recipe = prototype("recipe", "form-process-" .. world .. "-" .. i, {
                intermediate_planet = planet,
                ingredients = { { type = material.form, name = material.name, amount = 2 } },
                results = { { type = product.form, name = product.name, amount = 1 } },
            })
            local maker = gutils.add_node(graph, "recipe", recipe.name, { op = "AND" })
            gutils.add_edge(graph, room, maker)
            gutils.add_edge(graph, material.use, maker)
            gutils.add_edge(graph, item_fluid.recipe_category_key(recipe, lutils.find_recipe_fluids(recipe)), maker)
            gutils.add_edge(graph, maker, product.craft, { inds = { [1] = true } })
        end
    end
    old_data_raw = table.deepcopy(data.raw)
    mining.initialize()
    mining.spoof(graph)
    first_pass.spoof(graph)
    gutils.make_orands(graph)
    local result = assert(first_pass.execute({ spoofed_graph = graph, subdiv_graph = graph }))
    invariants.test(result.graph)
    result.split_graph = result.graph
    changes = {}
    mining.custom_prereq_search(result)
    mining.reflect()
    item.initialize()
    item.custom_prereq_search(result)
    item.reflect({}, {}, {})
    for _, change in pairs(changes) do
        if change.multiplier ~= nil then
            change.tbl[change.prop] = change.tbl[change.prop] * change.multiplier
        else
            change.tbl[change.prop] = change.new_val
        end
    end
    for slot_key, trav_key in pairs(result.slot_to_trav) do
        local slot = result.graph.nodes[slot_key]
        local identity = item_fluid.material_of_node(result.graph, result.graph.nodes[trav_key])
        if slot.mining_slot ~= nil then
            local resource = data.raw.resource[slot.mining_slot.resource_name]
            local reflected = resource.minable.results[1]
            assert(reflected.name == identity.name and reflected.type == identity.type, "mining reflection must preserve a cross-form assignment")
            if slot.mining_slot.material.type ~= identity.type then
                cross_form_deposits = cross_form_deposits + 1
                if identity.type == "item" then fluid_deposits_to_items = fluid_deposits_to_items + 1 end
                if identity.type == "fluid" then item_deposits_to_fluids = item_deposits_to_fluids + 1 end
            end
            if identity.type == "item" then assert(reflected.temperature == nil) end
            local modeled = result.graph.nodes[key("entity-mine", resource.name)]
            local old_counts = lutils.find_mining_fluids(old_data_raw.resource[resource.name])
            assert(lutils.find_mining_fluids(resource).output == old_counts.output + ((modeled.fluid_delta or {}).output or 0), "modeled mining ports must match reflected output")
        end
    end
    for name, recipe in pairs(data.raw.recipe) do
        local old_counts = lutils.find_recipe_fluids(old_data_raw.recipe[name])
        local counts = lutils.find_recipe_fluids(recipe)
        local delta = result.graph.nodes[key("recipe", name)].fluid_delta or {}
        assert(counts.input == old_counts.input + (delta.input or 0), "modeled input ports must match reflected local recipe")
        assert(counts.output == old_counts.output + (delta.output or 0), "modeled output ports must match reflected local recipe")
        for _, field in pairs({ "ingredients", "results" }) do
            for index, entry in pairs(recipe[field]) do
                local previous = old_data_raw.recipe[name][field][index]
                local position = local_slots.position(result.graph, name, previous, field)
                assert(position ~= nil and result.slot_to_trav[position] ~= nil, name .. " " .. field .. " missing slot " .. tostring(position))
                local identity = item_fluid.material_of_node(result.graph, result.graph.nodes[result.slot_to_trav[position]])
                assert(entry.type == identity.type and entry.name == identity.name, "local recipe reflection must preserve the assigned form")
                if previous.type ~= entry.type then cross_form_recipes = cross_form_recipes + 1 end
                if entry.type == "item" then assert(entry.temperature == nil and entry.fluidbox_index == nil) end
            end
        end
    end
end
assert(cross_form_deposits > 0, "independent deposits must participate in item/fluid trades")
assert(fluid_deposits_to_items > 0 and item_deposits_to_fluids > 0, "independent deposits must trade in both directions")
assert(cross_form_recipes > 0, "local production chains must participate in item/fluid trades")
print("ok - independent deposits and local recipes trade item/fluid forms and reflect the modeled types")

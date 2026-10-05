-- Run from the mod root: lua randomizations/graph/unified/handlers/test-mining-results.lua
-- Real first-pass matching and item/mining reflection; the ore copies start with the same product.

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
function log(message) end
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

local key = gutils.key
randomization_info.options.first_pass.always_slot_pre[key("recipe", "item")] = true
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
local function fixture(only_mining)
    data.raw.item = {}
    data.raw.recipe = {}
    data.raw.resource = {}
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local room_name = key("planet", "test-world")
    logic.contexts[room_name] = true
    local room = gutils.add_node(graph, "room", room_name, { op = "AND" })
    local root = gutils.add_node(graph, "true", "test-root", { op = "AND" })
    gutils.add_edge(graph, root, room)
    for i = 1, 8 do
        local product = prototype("item", "test-item-" .. i, {
            place_result = "test-place-" .. i,
            stack_size = 100,
            icon = "test.png",
            icon_size = 64,
        })
        defines.prototypes.item[product.type] = 0
        local material = gutils.add_node(graph, product.type, product.name, { op = "OR" })
        if only_mining ~= true or i ~= 1 then
            local recipe = prototype("recipe", "test-make-" .. i, {
                results = {
                    {
                        type = product.type,
                        name = product.name,
                        amount = 1,
                    },
                },
            })
            local maker = gutils.add_node(graph, recipe.type, recipe.name, { op = "AND" })
            gutils.add_edge(graph, room, maker)
            gutils.add_edge(graph, maker, material)
            if only_mining == true then
                recipe.ingredients = {
                    {
                        type = product.type,
                        name = "test-item-1",
                        amount = 1,
                    },
                }
                gutils.add_edge(graph, key("item", "test-item-1"), maker)
            end
        end
    end
    for i = 1, 3 do
        local resource = prototype("resource", "test-deposit-" .. i, {
            minable = {
                result = "test-item-1",
                count = i,
            },
        })
        defines.prototypes.entity[resource.type] = 0
        local mine = gutils.add_node(graph, "entity-mine", resource.name, { op = "AND" })
        gutils.add_edge(graph, room, mine)
        gutils.add_edge(graph, mine, key("item", resource.minable.result), { inds = { [1] = true } })
    end
    return graph
end

local function exercise(only_mining)
    local graph = fixture(only_mining)
    old_data_raw = table.deepcopy(data.raw)
    mining.initialize()
    mining.spoof(graph)
    gutils.make_orands(graph)
    local result = assert(first_pass.execute({
        spoofed_graph = graph,
        subdiv_graph = graph,
    }))
    invariants.test(result.graph)
    local choices = {}
    local unique = {}
    local deposits = 0
    for slot_key, trav_key in pairs(result.slot_to_trav) do
        local source = result.graph.nodes[slot_key].mining_slot
        if source ~= nil then
            local material = item_fluid.material_of_node(result.graph, result.graph.nodes[trav_key])
            assert(material.name ~= source.material.name)
            assert(unique[material.name] == nil)
            unique[material.name] = true
            choices[source.resource_name] = material.name
            deposits = deposits + 1
        end
    end
    assert(deposits == 3)
    print("ok - copies of one ore get distinct first-pass slots and choose items no deposit originally produced")

    -- Apply both handlers and the queued item edits, exactly as unified reflection does.
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
            if change.tbl[change.prop] ~= nil then
                change.tbl[change.prop] = change.tbl[change.prop] * change.multiplier
            end
        else
            change.tbl[change.prop] = change.new_val
        end
    end
    for i = 1, 3 do
        local resource = data.raw.resource["test-deposit-" .. i]
        assert(resource.minable.result == choices[resource.name])
        assert(resource.minable.count == i)
    end
    local prototypes = 0
    for _, _ in pairs(data.raw.item) do prototypes = prototypes + 1 end
    assert(prototypes == 8)
    print("ok - final mining results survive global item reflection, keep their amounts, and add no item prototypes")

    -- Shared identities must share their supplies: compare the model with a fresh graph of reflected materials.
    local built = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local world = gutils.add_node(built, "room", key("planet", "test-world"), { op = "AND" })
    local root = gutils.add_node(built, "true", "test-root", { op = "AND" })
    gutils.add_edge(built, root, world)
    local function material_node(name)
        return built.nodes[key("item", name)] or gutils.add_node(built, "item", name, { op = "OR" })
    end
    for _, resource in pairs(data.raw.resource) do
        local maker = gutils.add_node(built, "entity-mine", resource.name, { op = "AND" })
        gutils.add_edge(built, world, maker)
        gutils.add_edge(built, maker, material_node(resource.minable.result))
    end
    for _, recipe in pairs(data.raw.recipe) do
        local maker = gutils.add_node(built, recipe.type, recipe.name, { op = "AND" })
        gutils.add_edge(built, world, maker)
        gutils.add_edge(built, maker, material_node(recipe.results[1].name))
    end
    local sorted = top.sort(built, nil, nil, {
        complex_contexts = true,
        home_contexts = true,
    })
    for slot_key, trav_key in pairs(result.slot_to_trav) do
        local physical = item_fluid.material_of_node(result.graph, result.graph.nodes[trav_key])
        local modeled = result.sort.node_to_context_inds[trav_key] or {}
        local actual = sorted.node_to_context_inds[key(physical)] or {}
        for context, _ in pairs(modeled) do assert(actual[context] ~= nil) end
    end
    print("ok - every modeled material context exists in the rebuilt reflected world")

    if only_mining == true then
        local primaries = 0
        for slot_key, _ in pairs(result.slot_to_trav) do
            local source = result.graph.nodes[slot_key].mining_slot
            if source ~= nil and source.primary == true then
                primaries = primaries + 1
                for _, recipe in pairs(data.raw.recipe) do
                    assert(recipe.ingredients[1].name == choices[source.resource_name])
                end
            end
        end
        assert(primaries == 1)
        print("ok - a material produced only by deposits reuses one source position and its recipe inputs follow that source")
    end
end
exercise(false)
exercise(true)

-- Fluid copies share their identity's producers while each mining position still needs pipes in its own room.
config.item_fluids = true
data.raw.item = {}
data.raw.recipe = {}
data.raw.resource = {}
data.raw.fluid = {}
local fluid_graph = {
    nodes = {},
    edges = {},
    sources = {},
}
local home_name = key("planet", "test-fluid-world")
local dry_name = key("planet", "test-without-pipes")
local remote_name = key("planet", "test-remote-fluid-world")
logic.contexts[home_name] = true
logic.contexts[dry_name] = true
logic.contexts[remote_name] = true
local home = gutils.add_node(fluid_graph, "room", home_name, { op = "AND" })
local dry = gutils.add_node(fluid_graph, "room", dry_name, { op = "AND" })
local remote = gutils.add_node(fluid_graph, "room", remote_name, { op = "AND" })
local absent = gutils.add_node(fluid_graph, "false", "test-absent-mine", { op = "OR" })
local root = gutils.add_node(fluid_graph, "true", "test-root", { op = "AND" })
gutils.add_edge(fluid_graph, root, home)
gutils.add_edge(fluid_graph, root, dry)
gutils.add_edge(fluid_graph, root, remote)
local pipes = gutils.add_node(fluid_graph, "fluid-hold", "test-pipes", { op = "OR" })
gutils.add_edge(fluid_graph, home, pipes)
gutils.add_edge(fluid_graph, remote, pipes)
randomization_info.options.first_pass.always_slot_pre[key("fluid-create-temperature", "fluid-temperature")] = true
randomization_info.options.first_pass.always_slot_pre[key("fluid-hold", "fluid-temperature")] = true
for i = 1, 3 do
    local fluid = prototype("fluid", "test-fluid-" .. i, {
        default_temperature = 25,
        fuel_value = "1MJ",
    })
    local name = key(fluid.name, "25")
    local create = gutils.add_node(fluid_graph, "fluid-create-temperature", name, { op = "OR" })
    local temperature = gutils.add_node(fluid_graph, "fluid-temperature", name, { op = "AND" })
    local material = gutils.add_node(fluid_graph, fluid.type, fluid.name, { op = "OR" })
    gutils.add_edge(fluid_graph, create, temperature)
    gutils.add_edge(fluid_graph, pipes, temperature)
    gutils.add_edge(fluid_graph, temperature, material)
end
for i = 1, 5 do
    local fluid_name = "test-fluid-" .. math.min(i, 3)
    local resource = prototype("resource", "test-fluid-deposit-" .. i, {
        minable = {
            results = {
                {
                    type = "fluid",
                    name = fluid_name,
                    amount = i * 10,
                },
            },
        },
    })
    local maker = gutils.add_node(fluid_graph, "entity-mine", resource.name, { op = "AND" })
    gutils.add_edge(fluid_graph, i == 5 and absent or (i == 4 and remote or home), maker)
    gutils.add_edge(fluid_graph, maker, key("fluid-create-temperature", key(fluid_name, "25")), { inds = { [1] = true } })
end
mining.initialize()
mining.spoof(fluid_graph)
gutils.make_orands(fluid_graph)
-- Keep identity pairings for this test, so the remote copy must supply the original fluid position.
selected_items = false
local fluid_result = assert(first_pass.execute({
    spoofed_graph = fluid_graph,
    subdiv_graph = fluid_graph,
}))
selected_items = true
invariants.test(fluid_result.graph)
local fluid_slots = 0
local shared_positions = 0
for slot_key, trav_key in pairs(fluid_result.slot_to_trav) do
    local position = fluid_result.graph.nodes[slot_key]
    assert(position.mining_slot ~= nil)
    assert(item_fluid.material_of_node(fluid_result.graph, fluid_result.graph.nodes[trav_key]).type == "fluid")
    fluid_slots = fluid_slots + 1
    if position.mining_slot.resource_name == "test-fluid-deposit-5" then
        assert(next(fluid_result.sort.node_to_context_inds[slot_key] or {}) == nil)
    end
    local contexts = fluid_result.sort.node_to_context_inds[trav_key] or {}
    for context, _ in pairs(contexts) do
        if position.mining_slot.primary == true and top.context_room(context) == remote_name then
            assert(top.provides_context(fluid_result.sort.node_to_context_inds[slot_key] or {}, context))
            shared_positions = shared_positions + 1
        end
        local abilities = top.context_abilities(context)
        if top.context_room(context) == dry_name and abilities ~= nil then
            assert(string.sub(abilities, 1, 1) ~= "1", trav_key .. " reached " .. context)
        end
    end
end
assert(fluid_slots == 5)
assert(shared_positions > 0)
print("ok - recipes using a fluid position can receive its chosen identity from deposits on another planet")
print("ok - all fluid deposits get slots, including an unreachable deposit, and copied sources cannot bypass holding")
mining.custom_prereq_search({
    split_graph = fluid_result.graph,
    slot_to_trav = fluid_result.slot_to_trav,
})
mining.reflect()
for i = 1, 5 do
    local result = data.raw.resource["test-fluid-deposit-" .. i].minable.results[1]
    assert(mining.manages_result("test-fluid-deposit-" .. i, 1))
    assert(result.temperature == 25)
    assert(result.amount == i * 10)
    assert(data.raw.fluid[result.name] ~= nil)
end
print("ok - fluid reflection preserves amounts and writes the chosen fluid's explicit temperature")

-- Explicit reflection coverage for both prototype encodings and both form directions.
prototype("item", "form-solid", { stack_size = 100 })
prototype("fluid", "form-liquid", { default_temperature = 45 })
prototype("resource", "form-solid-deposit", { minable = { result = "form-solid", count = 7 } })
prototype("resource", "form-fluid-deposit", { minable = { results = { { type = "fluid", name = "form-liquid", amount = 2.5, temperature = 45 } } } })
local conversion_graph = { nodes = {}, edges = {}, sources = {} }
local solid_slot = gutils.add_node(conversion_graph, "item", "form-solid-slot", {
    mining_slot = { resource_name = "form-solid-deposit", material = { type = "item", name = "form-solid" } },
})
local fluid_slot = gutils.add_node(conversion_graph, "fluid-temperature", "form-fluid-slot", {
    mining_slot = { resource_name = "form-fluid-deposit", material = { type = "fluid", name = "form-liquid", temperature = 45 } },
})
local solid_trav = gutils.add_node(conversion_graph, "item", "form-solid-trav", { old_slot = key(solid_slot) })
local fluid_trav = gutils.add_node(conversion_graph, "fluid-temperature", "form-fluid-trav", { old_slot = key(fluid_slot) })
mining.initialize()
mining.custom_prereq_search({ split_graph = conversion_graph, slot_to_trav = { [key(solid_slot)] = key(fluid_trav), [key(fluid_slot)] = key(solid_trav) } })
mining.reflect()
local liquid = data.raw.resource["form-solid-deposit"].minable
assert(liquid.result == nil and liquid.count == nil and liquid.results[1].type == "fluid")
assert(liquid.results[1].name == "form-liquid" and liquid.results[1].amount == 7 and liquid.results[1].temperature == 45)
local solid = data.raw.resource["form-fluid-deposit"].minable.results[1]
assert(solid.type == "item" and solid.name == "form-solid" and solid.amount == 3 and solid.temperature == nil)
print("ok - independent mining changes both forms, clears fluid fields, and expands shorthand results")

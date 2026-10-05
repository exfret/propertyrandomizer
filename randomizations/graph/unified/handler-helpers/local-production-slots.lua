-- Planets share materials, but their production positions and recipe inputs are local.
local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")
local dutils = require("lib/data-utils")
local surface_sets = require("lib/surface-sets")
local graph_customization = require("lib/graph-customization")
local lutils = require("lib/logic/logic-utils")
local dupe = require("lib/dupe")
local locks = require("randomizations/planetary/locks")
local locale = require("lib/locale")
local item_fluid = require("lib/item-fluid")
local furnace_selection = require("lib/furnace-selection")
local recycling = require("lib/recycling")

local slots = {}
local key = gutils.key

local function sorted_keys(set)
    local keys = {}
    for k, _ in pairs(set) do
        table.insert(keys, k)
    end
    table.sort(keys)
    return keys
end

local function recipe_planet(recipe)
    if recipe.dupe_number == nil and recipe.intermediate_planet == nil then
        return nil
    end
    local planet
    for room, _ in pairs(surface_sets.accepted(recipe)) do
        local parts = gutils.deconstruct(room)
        local prototype = parts.type == "planet" and data.raw.planet[parts.name] or nil
        if prototype == nil or planet ~= nil then
            return nil
        end
        planet = parts.name
    end
    return planet
end

-- Containers belong to the held fluid's identity, as in item_fluid.move_identity_sources.
-- Their fixed fluid must not become a planet's independently chosen production material.
local function container_recipes()
    local recipes = {}
    for _, container in pairs(item_fluid.fluid_containers(data.raw.recipe)) do
        recipes[container.fill] = true
        recipes[container.empty] = true
    end
    return recipes
end

-- Give shared boundary recipes local variants before first pass captures its starting world.
-- Otherwise a local deposit still feeds a shared smelting/processing position on every planet.
slots.prepare = function()
    local containers = container_recipes()
    local deposits = {}
    for planet_name, planet in pairs(data.raw.planet or {}) do
        for _, resource in pairs(data.raw.resource or {}) do
            if resource.autoplace ~= nil and lutils.check_in_room(planet, resource) then
                deposits[planet_name] = deposits[planet_name] or {}
                local minable = resource.minable or {}
                if minable.result ~= nil then
                    deposits[planet_name][key("item", minable.result)] = true
                end
                for _, result in pairs(minable.results or {}) do
                    deposits[planet_name][key(result.type or "item", result.name)] = true
                end
            end
        end
    end
    local discoveries = {}
    for _, technology in pairs(data.raw.technology or {}) do
        for _, effect in pairs(technology.effects or {}) do
            if effect.type == "unlock-space-location" then
                discoveries[effect.space_location] = technology
            end
        end
    end
    local count = 0
    local local_categories = {}
    local names = sorted_keys(data.raw.recipe)
    for _, name in pairs(names) do
        local recipe = data.raw.recipe[name]
        if recipe.orig_name == nil and recipe.hidden ~= true and containers[name] == nil and not graph_customization.excluded("item", recipe) then
            local accepted = surface_sets.accepted(recipe)
            local remaining = table.deepcopy(accepted)
            local variants = {}
            for _, planet_name in pairs(sorted_keys(deposits)) do
                local room = key("planet", planet_name)
                local uses_deposit = false
                for _, ingredient in pairs(recipe.ingredients or {}) do
                    if deposits[planet_name][key(ingredient.type or "item", ingredient.name)] ~= nil then
                        uses_deposit = true
                    end
                end
                if accepted[room] ~= nil and uses_deposit then
                    local planet = data.raw.planet[planet_name]
                    local variant = dupe.recipe(recipe, {
                        suffix = "resource-chain-" .. planet_name,
                        dupe_number = planet.dupe_number,
                        home_discovery = discoveries[planet_name],
                    })
                    variant.intermediate_planet = planet_name
                    for _, category in pairs(furnace_selection.recipe_categories(variant)) do
                        local_categories[category] = true
                    end
                    variant.localised_name = {
                        "propertyrandomizer.recipe_planet_variant",
                        locale.find_localised_name(recipe),
                        locale.find_localised_name(planet),
                    }
                    locks.fix("recipe", variant.name, { [room] = true })
                    table.insert(variants, variant.name)
                    remaining[room] = nil
                    count = count + 1
                end
            end
            if #variants > 0 then
                locks.fix("recipe", name, remaining, variants)
            end
        end
    end
    if count > 0 then
        -- Local chains may select different recipes from the same ingredient after first pass.
        -- Give their automatic crafters explicit recipe selection before capturing the starting world.
        local converted = 0
        for _, name in pairs(sorted_keys(data.raw.furnace or {})) do
            local furnace = data.raw.furnace[name]
            local affected = false
            for _, category in pairs(furnace.crafting_categories or {}) do
                if local_categories[category] ~= nil then
                    affected = true
                end
            end
            if affected then
                data.raw.furnace[name] = nil
                furnace.type = "assembling-machine"
                data:extend({ furnace })
                converted = converted + 1
            end
        end
        if converted > 0 then
            log("First pass: " .. converted .. " local-chain furnaces use explicit recipe selection")
        end
        locks.realize()
        log("First pass: " .. count .. " planet-local resource-chain recipes prepared")
    end
    recycling.prepare_planetary()
end

slots.spoof = function(graph)
    local recipes = {}
    local containers = container_recipes()
    for name, recipe in pairs(data.raw.recipe) do
        local planet = recipe_planet(recipe)
        if planet ~= nil and containers[name] == nil and graph.nodes[key("recipe", name)] ~= nil then
            recipes[name] = planet
        end
    end
    if next(recipes) == nil then
        return
    end
    -- Regenerated recycling follows its source recipe's product and reversed ingredients.
    -- A shared recycling recipe must therefore use those same local positions too.
    local recycling_sources = recycling.vanilla(old_data_raw or data.raw)
    local consumers = table.deepcopy(recipes)
    for name, source in pairs(recycling_sources) do
        local input_planet = recipes[source.source]
        local output_planet = recipes[source.reversed]
        if graph.nodes[key("recipe", name)] ~= nil and (input_planet ~= nil or output_planet ~= nil) then
            consumers[name] = input_planet or false
            recipes[name] = output_planet
        end
    end
    local positions = {}
    graph.local_craft_slots = {}
    graph.local_fluid_positions = {}
    local fluid_positions = {}
    for node_key, node in pairs(graph.nodes) do
        local mining_fluid = node.mining_slot ~= nil and node.mining_slot.primary == true and node.mining_slot.material.type == "fluid"
        if mining_fluid or item_fluid.fluid_slot_ok(graph, node) then
            local material = item_fluid.material_of_node(graph, node)
            fluid_positions[key(material)] = node_key
            graph.local_fluid_positions[node_key] = true
        end
    end
    local function register(planet, material, node)
        node.production_slot = {
            planet = planet,
            node_type = node.type,
            material = table.deepcopy(material),
        }
        positions[planet] = positions[planet] or {}
        positions[planet][key(material)] = positions[planet][key(material)] or key(node)
        -- Before splitting identities, local inputs still consume the same physical material as shared inputs.
        -- Remove this temporary supply when the assignment connects each position to its replacement identity.
        local original_key = material.type == "fluid" and fluid_positions[key(material)] or key(material)
        local provider = material.type == "fluid" and graph.nodes[key("fluid-create-temperature", node.name)] or node
        if original_key ~= nil and graph.nodes[original_key] ~= nil and original_key ~= key(node) and provider ~= nil then
            local edge_key = gutils.ekey({ start = original_key, stop = key(provider) })
            if graph.edges[edge_key] == nil then
                gutils.add_edge(graph, original_key, provider, { local_identity_supply = true, identity_supply = true })
            end
        end
    end
    local function fluid_node(planet, material, name)
        local original_key = fluid_positions[key(material)]
        if original_key == nil then
            return nil
        end
        local original = graph.nodes[original_key]
        material.temperature = tonumber(gutils.deconstruct(original.name).name)
        local node = gutils.add_node(graph, original.type, key(name, tostring(material.temperature)), { op = "AND" })
        local create = gutils.add_node(graph, "fluid-create-temperature", node.name, { op = "OR" })
        gutils.add_edge(graph, create, node)
        for pre, _ in pairs(original.pre) do
            local provider = gutils.prenode(graph, pre)
            if provider.type == "fluid-hold" then
                gutils.add_edge(graph, provider, node)
            end
        end
        register(planet, material, node)
        gutils.add_edge(graph, node, key(material))
        return node, create
    end

    -- Ownership comes from placement, even when this world's mining prerequisites are not reachable yet.
    -- Sources without map placement use their own graph contexts, before identity links can lend them another deposit's supply.
    local sorted = top.sort(graph, nil, nil, { complex_contexts = true })
    for _, node_key in pairs(sorted_keys(graph.nodes)) do
        local node = graph.nodes[node_key]
        local source = node.mining_slot
        if source ~= nil then
            local planet
            local unique = true
            local resource = data.raw.resource[source.resource_name]
            if resource.autoplace ~= nil then
                for name, prototype in pairs(data.raw.planet or {}) do
                    if lutils.check_in_room(prototype, resource) then
                        if planet ~= nil then
                            unique = false
                            break
                        end
                        planet = name
                    end
                end
            else
                for context, _ in pairs(sorted.node_to_context_inds[key("entity-mine", source.resource_name)] or {}) do
                    local room = gutils.deconstruct(top.context_room(context))
                    if room.type ~= "planet" or (planet ~= nil and planet ~= room.name) then
                        unique = false
                        break
                    end
                    planet = room.name
                end
            end
            local prototype = planet ~= nil and data.raw.planet[planet] or nil
            if unique and prototype ~= nil then
                if source.primary == true then
                    local name = "propertyrandomizer-local-deposit-" .. source.resource_name
                    local local_node
                    local provider
                    if source.material.type == "fluid" then
                        local_node, provider = fluid_node(planet, table.deepcopy(source.material), name)
                    else
                        local_node = gutils.add_node(graph, node.type, name, { op = "OR" })
                        provider = local_node
                    end
                    if local_node ~= nil then
                        local_node.mining_slot = table.deepcopy(source)
                        local_node.mining_slot.primary = nil
                        local mine_key = key("entity-mine", source.resource_name)
                        local old_provider = source.material.type == "fluid" and graph.nodes[key("fluid-create-temperature", node.name)] or node
                        for pre, _ in pairs(table.deepcopy(old_provider.pre)) do
                            if graph.edges[pre].start == mine_key then
                                gutils.redirect_edge_stop(graph, pre, key(provider))
                            end
                        end
                        if source.material.type == "fluid" then
                            gutils.add_edge(graph, provider, old_provider, { local_craft_slot = key(local_node), identity_supply = true })
                        else
                            gutils.add_edge(graph, local_node, node)
                        end
                        node.mining_slot = nil
                        node = local_node
                    end
                elseif source.material.type == "fluid" then
                    -- Mining positions need a separate creation OR for the identity's other sources.
                    local create = gutils.add_node(graph, "fluid-create-temperature", node.name, { op = "OR" })
                    for pre, _ in pairs(table.deepcopy(node.pre)) do
                        if graph.edges[pre].start == key("entity-mine", source.resource_name) then
                            gutils.redirect_edge_stop(graph, pre, key(create))
                        end
                    end
                    gutils.add_edge(graph, create, node)
                end
                register(planet, source.material, node)
            end
        end
    end
    local labs = dutils.lab_inputs()
    -- Group alternative local recipes for one material into the same position.
    for _, name in pairs(sorted_keys(recipes)) do
        local recipe = data.raw.recipe[name]
        local planet = recipes[name]
        for _, result in pairs(recipe.results or {}) do
            local material = {
                type = result.type or "item",
                name = result.name,
            }
            local original_key = key(material)
            if material.type == "fluid" then
                original_key = fluid_positions[key(material)]
            end
            local original = original_key ~= nil and graph.nodes[original_key] or nil
            if original ~= nil and labs[material.name] == nil and graph_customization.selected("item", original)
                and randomization_info.options.first_pass.blacklist[key(material)] == nil then
                positions[planet] = positions[planet] or {}
                local position_key = positions[planet][key(material)]
                if position_key == nil then
                    local name = "propertyrandomizer-local-production-" .. gutils.concat({ planet, material.name })
                    local node
                    if material.type == "fluid" then
                        node = fluid_node(planet, material, name)
                    else
                        node = gutils.add_node(graph, material.type, name, { op = "OR" })
                        register(planet, material, node)
                        gutils.add_edge(graph, node, original)
                    end
                    position_key = key(node)
                end
                -- Logic routes ordinary results through item-craft; hidden results may link directly.
                for dep, _ in pairs(table.deepcopy(graph.nodes[key("recipe", name)].dep)) do
                    local stop = graph.nodes[graph.edges[dep].stop]
                    local craft_type = material.type == "fluid" and "fluid-craft-temperature" or "item-craft"
                    local create_type = material.type == "fluid" and "fluid-create-temperature" or material.type
                    if stop.type == craft_type and stop.name == original.name then
                        local craft_key = graph.local_craft_slots[position_key]
                        if craft_key == nil then
                            local craft = gutils.add_node(graph, stop.type, graph.nodes[position_key].name, { op = "OR" })
                            craft_key = key(craft)
                            graph.local_craft_slots[position_key] = craft_key
                            local provider = material.type == "fluid" and key(create_type, graph.nodes[position_key].name) or position_key
                            gutils.add_edge(graph, craft, provider)
                            -- Preserve the original crafting trigger during preparation; first pass reconnects it to the chosen identity.
                            gutils.add_edge(graph, craft, stop, { local_craft_slot = position_key, identity_supply = true })
                        end
                        gutils.redirect_edge_stop(graph, dep, craft_key)
                    elseif stop.type == create_type and stop.name == original.name then
                        local provider = material.type == "fluid" and key(create_type, graph.nodes[position_key].name) or position_key
                        gutils.redirect_edge_stop(graph, dep, provider)
                    end
                end
            end
        end
    end
    graph.local_recipe_positions = {}
    graph.local_recipe_result_positions = {}
    for name, planet in pairs(consumers) do
        graph.local_recipe_positions[name] = positions[planet] or {}
        if recycling_sources[name] ~= nil then
            graph.local_recipe_result_positions[name] = positions[recipes[name]] or {}
        end
        local recipe_key = key("recipe", name)
        for pre, _ in pairs(table.deepcopy(graph.nodes[recipe_key].pre)) do
            local start = graph.nodes[graph.edges[pre].start]
            local material_key = key(start)
            if start.type == "fluid-temperature-range" then
                material_key = key("fluid", gutils.deconstruct(start.name).type)
            end
            local local_key = (positions[planet] or {})[material_key]
            if local_key ~= nil then
                if start.type == "fluid-temperature-range" then
                    local node = graph.nodes[local_key]
                    local range_name = key(node.name, gutils.deconstruct(start.name).name)
                    local range = graph.nodes[key(start.type, range_name)]
                    if range == nil then
                        range = gutils.add_node(graph, start.type, range_name, {
                            op = "OR",
                            production_slot = table.deepcopy(node.production_slot),
                        })
                        range.production_slot.position_key = local_key
                        gutils.add_edge(graph, node, range)
                    end
                    local_key = key(range)
                end
                gutils.redirect_edge_start(graph, pre, local_key)
            end
        end
    end
end

-- Subdivision puts the preparation links through ORAND gates; remove the whole gate too.
slots.disconnect_crafts = function(graph)
    for edge_key, edge in pairs(table.deepcopy(graph.edges)) do
        if edge.local_craft_slot ~= nil or edge.local_identity_supply == true then
            local gate = graph.nodes[edge.stop]
            gutils.remove_edge(graph, edge_key)
            if gate.type == "orand" then
                for dep, _ in pairs(table.deepcopy(gate.dep)) do
                    gutils.remove_edge(graph, dep)
                end
                local gate_key = key(gate)
                local parent = graph.orand_to_parent[gate_key]
                graph.node_to_orands[parent][gate_key] = nil
                graph.orand_to_parent[gate_key] = nil
                graph.orand_to_child[gate_key] = nil
                graph.nodes[gate_key] = nil
                graph[gate_key] = nil
                graph.sources[gate_key] = nil
            end
        end
    end
end

-- Craft availability shares physical identities too, but mining and delivery do not satisfy it.
-- Keep a separate identity node for it, connected in parallel with the item/fluid matching.
slots.prepare_crafts = function(graph)
    graph.craft_positions = {}
    local identities = {}
    for node_key, node in pairs(graph.nodes) do
        if node.slot == true then
            local material = item_fluid.material_of_node(graph, node)
            if material ~= nil then
                local original_key = key(material)
                local craft_type = "item-craft"
                local craft_name = material.name
                if material.type == "fluid" then
                    material.temperature = material.temperature or tonumber(gutils.deconstruct(node.name).name)
                    craft_type = "fluid-craft-temperature"
                    craft_name = key(material.name, tostring(material.temperature))
                    original_key = key("fluid-temperature", craft_name)
                end
                local craft_key = node.production_slot ~= nil and (graph.local_craft_slots or {})[node_key] or key(craft_type, node.name)
                if craft_key ~= nil and graph.nodes[craft_key] ~= nil then
                    graph.craft_positions[node_key] = craft_key
                    graph.nodes[craft_key].craft_position = node_key
                end
                local identity_key = identities[original_key]
                if identity_key == nil and graph.nodes[key(craft_type, craft_name)] ~= nil then
                    local identity = gutils.add_node(graph, "material-craft-identity", original_key, {
                        op = "OR",
                        craft_identity = true,
                    })
                    identity_key = key(identity)
                    identities[original_key] = identity_key
                end
                graph.nodes[node.old_trav].craft_identity_key = identity_key
            end
        end
    end
end

slots.connect_craft = function(graph, slot_key, trav_key)
    local craft_key = (graph.craft_positions or {})[slot_key]
    local identity_key = graph.nodes[trav_key].craft_identity_key
    if craft_key == nil or identity_key == nil then
        return
    end
    gutils.add_edge(graph, craft_key, identity_key, { craft_supplier = trav_key })
    if graph.nodes[slot_key].production_slot == nil then
        gutils.add_edge(graph, identity_key, craft_key, { identity_supply = true })
    end
end

-- Explicit choices made by the ingredient handler keep their source position through reflection.
slots.position = function(graph, recipe_name, entry, field)
    if entry.first_pass_position ~= nil then
        return entry.first_pass_position or nil
    end
    local positions = (graph.local_recipe_positions or {})[recipe_name]
    if field == "results" and (graph.local_recipe_result_positions or {})[recipe_name] ~= nil then
        positions = graph.local_recipe_result_positions[recipe_name]
    end
    return (positions or {})[key(entry.type or "item", entry.name)]
end

-- Selection depends on the complete assignment because several logical positions can share one physical item.
slots.connect_recycling = function(graph, assignment)
    local has_candidates = false
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.recycling_origin ~= nil then
            has_candidates = true
            break
        end
    end
    if not has_candidates then
        return
    end
    local function material_for(recipe, field, entry)
        local position = slots.position(graph, recipe.name, entry, field) or key(entry.type or "item", entry.name)
        local traveller = assignment[position]
        if traveller ~= nil then
            return item_fluid.material_of_node(graph, graph.nodes[traveller])
        end
        return entry
    end
    local scopes = recycling.planetary_scopes(data.raw, material_for, surface_sets.accepted)
    graph.recycling_scopes = scopes
    for name, rooms in pairs(scopes) do
        local condition = graph.nodes[key("recipe-surface-condition", name)]
        if condition ~= nil then
            for edge, _ in pairs(table.deepcopy(condition.pre)) do
                gutils.remove_edge(graph, edge)
            end
            for room, _ in pairs(rooms) do
                local provider = graph.nodes[key("room", room)]
                if provider ~= nil then
                    gutils.add_edge(graph, provider, condition)
                end
            end
        end
    end
end

return slots

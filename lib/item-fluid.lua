-- Items and fluids in first pass (config.item_fluids): they trade positions, and an identity takes its new position's form
-- User, 2026-09-26: "an item taking a fluid slot *becomes* a fluid. A fluid taking an item slot *becomes* an item."
-- A position (slot) keeps everything it does in the game in its own form (recipes, mining, pumping, loot, ...), so recipes and machines keep their shape
-- An identity (trav) keeps what it is (what it places, burns, fuels, ...), so only identities with nothing that needs their old form change form (see can_change_form)
-- Shared by first pass (the model) and item reflection (the game), which must agree

local gutils = require("lib/graph/graph-utils")
local dutils = require("lib/data-utils")
local locale_utils = require("lib/locale")

local item_fluid = {}

-- Node types a fluid's own node leads to that are part of its position: mining that needs the fluid (a resource's required fluid, and its spoofed mining-fluid bases, see handlers/mining-fluid-required.lua)
-- Item reflection renames required fluids by position, so whatever fluid is made at the position is what the resource needs
item_fluid.POSITION_DEPS_OF_FLUID = {
    ["entity-mine"] = true,
    ["mining-fluid"] = true,
}

-- Prenodes and depnodes, looking through orands (gutils.make_orands puts one on each edge into an OR node)
local function real_prenodes(graph, node)
    local prenodes = {}
    for _, prenode in pairs(gutils.prenodes(graph, node)) do
        if prenode.type == "orand" then
            prenode = gutils.unique_prenode(graph, prenode)
        end
        table.insert(prenodes, prenode)
    end
    return prenodes
end
local function real_deps(graph, node)
    local deps = {}
    for dep, _ in pairs(node.dep) do
        local depnode = gutils.depnode(graph, dep)
        if depnode.type == "orand" then
            depnode = gutils.unique_depnode(graph, depnode)
        end
        table.insert(deps, { edge_key = dep, node = depnode })
    end
    return deps
end

-- The material a first pass slot or trav stands for, as {type = "item" or "fluid", name}, or nil for other slots (like entity positions)
-- Item slots are item nodes, fluid slots are fluid-temperature nodes (a fluid at its only temperature), and a trav is named after its slot (old_slot)
item_fluid.material_of_node = function(graph, node)
    if node.old_slot ~= nil then
        node = graph.nodes[node.old_slot]
    end
    if node.type == "item" then
        return { type = "item", name = node.name }
    elseif node.type == "fluid-temperature" then
        return { type = "fluid", name = gutils.deconstruct(node.name).type }
    end
    return nil
end

-- "item: name" or "fluid: name", as the material cost tables key them
item_fluid.material_key = function(material)
    return gutils.key(material.type, material.name)
end

-- The prototype of a material, or nil
item_fluid.prot = function(material)
    if material.type == "fluid" then
        return (data.raw.fluid or {})[material.name]
    end
    return dutils.get_prot("item", material.name)
end

-- Whether a material is a useless item (dutils.is_useless_item); fluids never are
item_fluid.is_useless_material = function(material_key)
    local material = gutils.deconstruct(material_key)
    if material.type ~= "item" then
        return false
    end
    local item = dutils.get_prot("item", material.name)
    return item ~= nil and dutils.is_useless_item(item)
end

-- Item reflection's useless-item rule for items and fluids (see dutils.reflected_item_position), given identity_at: position material key --> identity material key
-- An identity only counts as useless if it's a useless item assigned to an item position; a fluid, or an item becoming a fluid, lands where it's assigned
-- So the rule's detours stay among item positions, and only pairs first pass allowed (pair_ok and cross_type_ok) change form
-- It's still a property of each identity (through the position it's assigned), so the rule's realized assignment is still a permutation
item_fluid.useless_predicate = function(identity_at)
    local position_of = {}
    for position_key, identity_key in pairs(identity_at) do
        position_of[identity_key] = position_key
    end
    return function(identity_key)
        local position_key = position_of[identity_key]
        if position_key == nil or gutils.deconstruct(position_key).type ~= "item" then
            return false
        end
        return item_fluid.is_useless_material(identity_key)
    end
end

-- Whether first pass takes a fluid's position (its fluid-temperature node): a fluid at a single temperature that only recipes, mining a resource and pumping from tiles make, and that isn't carried around a round trip (dutils.round_trips)
-- Other fluids (like steam, which boilers heat to several temperatures) keep their positions and identities
-- round_trip_materials: dutils.round_trips().materials
item_fluid.fluid_slot_ok = function(graph, node, round_trip_materials)
    if node.type ~= "fluid-temperature" then
        return false
    end
    local fluid_name = gutils.deconstruct(node.name).type
    local fluid = (data.raw.fluid or {})[fluid_name]
    if fluid == nil or fluid.hidden or fluid.parameter then
        return false
    end
    if round_trip_materials["fluid-" .. fluid_name] ~= nil then
        return false
    end
    if randomization_info.options.first_pass.blacklist[gutils.key("fluid", fluid_name)] ~= nil then
        return false
    end
    local fluid_node = graph.nodes[gutils.key("fluid", fluid_name)]
    if fluid_node == nil then
        return false
    end
    -- A single temperature: this is the fluid's only way in
    local prenodes = real_prenodes(graph, fluid_node)
    if #prenodes ~= 1 or gutils.key(prenodes[1]) ~= gutils.key(node) then
        return false
    end
    for _, prenode in pairs(real_prenodes(graph, node)) do
        if prenode.type == "fluid-create-temperature" then
            for _, maker in pairs(real_prenodes(graph, prenode)) do
                local is_resource = maker.type == "entity-mine" and (data.raw.resource or {})[maker.name] ~= nil
                if maker.type ~= "fluid-craft-temperature" and maker.type ~= "fluid-create-offshore-temperature" and not is_resource then
                    return false
                end
            end
        elseif prenode.type ~= "fluid-hold" then
            return false
        end
    end
    return true
end

-- Whether nothing about an item needs it to be an item, so it can become a fluid
-- It has to be a plain item (other item types, like modules, ammo and science packs, are used as what they are) that places nothing, isn't a fuel, doesn't spoil, launches into nothing, isn't a lab input and isn't in a space platform starter pack
item_fluid.item_can_be_fluid = function(item)
    if item == nil or item.type ~= "item" or item.hidden then
        return false
    end
    if item.fuel_value ~= nil and util.parse_energy(item.fuel_value) ~= 0 then
        return false
    end
    if item.place_result ~= nil or item.plant_result ~= nil or item.place_as_tile ~= nil or item.place_as_equipment_result ~= nil then
        return false
    end
    if item.spoil_result ~= nil or item.spoil_to_trigger_result ~= nil or (item.spoil_ticks or 0) > 0 then
        return false
    end
    if item.burnt_result ~= nil and item.burnt_result ~= "" then
        return false
    end
    if item.rocket_launch_products ~= nil and next(item.rocket_launch_products) ~= nil then
        return false
    end
    if dutils.lab_inputs()[item.name] ~= nil then
        return false
    end
    for _, starter_pack in pairs(data.raw["space-platform-starter-pack"] or {}) do
        for _, entry in pairs(starter_pack.initial_items or {}) do
            if entry.name == item.name then
                return false
            end
        end
    end
    return true
end

-- Whether nothing about a fluid needs it to be a fluid, so it can become an item: it isn't a fuel (fluid energy sources burn fluids)
-- Machines, turrets and thrusters taking it are in logic, which can_change_form checks
item_fluid.fluid_can_be_item = function(fluid)
    if fluid == nil or fluid.hidden or fluid.parameter then
        return false
    end
    if fluid.fuel_value ~= nil and util.parse_energy(fluid.fuel_value) ~= 0 then
        return false
    end
    return true
end

-- Whether first pass may put a trav in a position of the other form, checked in its split graph with no slot/trav connections
-- Its prototype has to pass item_can_be_fluid or fluid_can_be_item, and its name mustn't be taken in the new form, since the new prototype gets the identity's name
-- Its own edges in logic (what moved to the trav) have to be ones a form change doesn't break
-- An item's may only be its delivery: from its item-deliver node, and to an item-launch node leading nowhere else (a fluid can't be launched, so first pass cuts them, see cut_delivery)
-- A fluid's may only be to its fluid node, which leads nowhere (its position deps moved to the slot, see POSITION_DEPS_OF_FLUID)
item_fluid.can_change_form = function(graph, trav)
    local material = item_fluid.material_of_node(graph, trav)
    if material == nil then
        return false
    end
    local prot = item_fluid.prot(material)
    if material.type == "item" then
        if not item_fluid.item_can_be_fluid(prot) or (data.raw.fluid or {})[material.name] ~= nil then
            return false
        end
        for _, prenode in pairs(real_prenodes(graph, trav)) do
            if prenode.type ~= "head" and prenode.type ~= "item-deliver" then
                return false
            end
        end
        for _, dep in pairs(real_deps(graph, trav)) do
            if dep.node.type ~= "base" then
                if dep.node.type ~= "item-launch" then
                    return false
                end
                for _, launch_dep in pairs(real_deps(graph, dep.node)) do
                    if launch_dep.node.type ~= "item-deliver" then
                        return false
                    end
                end
            end
        end
        return true
    end
    if not item_fluid.fluid_can_be_item(prot) or dutils.get_prot("item", material.name) ~= nil then
        return false
    end
    for _, prenode in pairs(real_prenodes(graph, trav)) do
        if prenode.type ~= "head" then
            return false
        end
    end
    for _, dep in pairs(real_deps(graph, trav)) do
        if dep.node.type ~= "base" then
            if dep.node.type ~= "fluid" or next(dep.node.dep) ~= nil then
                return false
            end
        end
    end
    return true
end

-- Moves the position deps of a fluid slot's fluid node to the slot (see POSITION_DEPS_OF_FLUID); call after the split
item_fluid.move_position_deps = function(graph, slot_key)
    local material = item_fluid.material_of_node(graph, graph.nodes[slot_key])
    local fluid_node = graph.nodes[gutils.key("fluid", material.name)]
    local to_move = {}
    for _, dep in pairs(real_deps(graph, fluid_node)) do
        if item_fluid.POSITION_DEPS_OF_FLUID[dep.node.type] ~= nil then
            table.insert(to_move, dep.edge_key)
        end
    end
    for _, edge_key in pairs(to_move) do
        gutils.redirect_edge_start(graph, edge_key, slot_key)
    end
end

-- An item identity at a fluid position is a fluid, which rockets can't carry, so the contexts its delivery brings don't come back to it
-- Removes the edges from its delivery chain into the trav (trav --> item-launch --> item-deliver --> orand --> trav, see monotone matching's launch_chains)
-- The chain's own nodes lead nowhere else (see can_change_form)
item_fluid.cut_delivery = function(graph, trav_key)
    local trav = graph.nodes[trav_key]
    local to_remove = {}
    for pre, _ in pairs(trav.pre) do
        local prenode = gutils.prenode(graph, pre)
        if prenode.type == "orand" then
            prenode = gutils.unique_prenode(graph, prenode)
        end
        if prenode.type == "item-deliver" then
            table.insert(to_remove, pre)
        end
    end
    for _, pre in pairs(to_remove) do
        gutils.remove_edge(graph, pre)
    end
end

-- The key a node of the original game's logic has in the final game's, given renames: position material key --> the identity reflection put there, as {type, name} (UNIFIED_MATERIAL_RENAMES, set by item reflection)
-- A node named after a material is named after the identity at its position in the final game, which is how checks compare the two games (see skeleton/check.lua)
-- Which nodes those are comes from where logic builds them: a node type built for items or fluids has that class as its canonical type (type_info, see lib/logic/builder.lua), and its name is the material's name, maybe followed by a temperature or temperature range
-- A fluid is made at its own default temperature wherever it goes (reflection drops the position's fixed temperatures), and a fluid an item became takes its position's
item_fluid.final_node_key = function(node_key, renames, type_info)
    if renames == nil then
        return node_key
    end
    local node = gutils.deconstruct(node_key)
    local material_type = (type_info[node.type] or {}).canonical
    if material_type ~= "item" and material_type ~= "fluid" then
        return node_key
    end
    local material_name = node.name
    local suffix
    if string.find(node.name, ": ", 1, true) ~= nil then
        local parts = gutils.deconstruct(node.name)
        material_name = parts.type
        suffix = parts.name
    end
    local identity = renames[gutils.key(material_type, material_name)]
    if identity == nil then
        return node_key
    end
    if suffix == nil then
        return gutils.key(node.type, identity.name)
    end
    -- A single temperature (a number, unlike a range) is the identity's own
    if tonumber(suffix) ~= nil and identity.name ~= material_name then
        local fluid = (data.raw.fluid or {})[identity.name]
        if fluid ~= nil and fluid.default_temperature ~= nil then
            suffix = tostring(fluid.default_temperature)
        end
    end
    return gutils.key(node.type, gutils.key(identity.name, suffix))
end

local function copy_icons(from, to)
    to.icon = from.icon
    to.icon_size = from.icon_size
    to.icons = table.deepcopy(from.icons)
end

-- The fluid an item identity becomes at a fluid position: the position's fluid as it flows (temperatures, heat capacity, colors), with the item's name, look and description
-- What the position's fluid is as an identity (a fuel value) stays with that fluid, and no barrels are made for it (base's barrels are made in data-updates, before randomization)
item_fluid.fluid_from_item = function(item, position_fluid)
    local fluid = table.deepcopy(position_fluid)
    fluid.name = item.name
    fluid.localised_name = locale_utils.find_localised_name(item)
    fluid.localised_description = item.localised_description or { "?", { "item-description." .. item.name }, "" }
    copy_icons(item, fluid)
    fluid.fuel_value = nil
    fluid.emissions_multiplier = nil
    fluid.hidden = nil
    fluid.hidden_in_factoriopedia = nil
    fluid.parameter = nil
    fluid.factoriopedia_simulation = nil
    fluid.auto_barrel = false
    fluid.order = item.order
    return fluid
end

-- The item a fluid identity becomes at an item position: a plain item with the fluid's name, look and description, stacking and weighing like the position's item
item_fluid.item_from_fluid = function(fluid, position_item)
    local item = {
        type = "item",
        name = fluid.name,
        localised_name = locale_utils.find_localised_name(fluid),
        localised_description = fluid.localised_description or { "?", { "fluid-description." .. fluid.name }, "" },
        subgroup = position_item.subgroup,
        order = fluid.order or position_item.order,
        stack_size = math.max(1, position_item.stack_size or 50),
        weight = position_item.weight,
        default_import_location = position_item.default_import_location,
    }
    copy_icons(fluid, item)
    return item
end

return item_fluid

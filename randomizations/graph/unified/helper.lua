local constants = require("helper-tables/constants")
local build_graph = require("lib/graph/build-graph")
local graph_utils = require("lib/graph/graph-utils")

-- Defines helper functions for unified randomization
-- A lot of these 

local helper = {}

----------------------------------------------------------------------------------------------------
-- Initializations
----------------------------------------------------------------------------------------------------

helper.conn_handlers = {}
local function init_handlers(conn_handlers)
    helper.conn_handlers = conn_handlers
end
helper.init_handlers = init_handlers

----------------------------------------------------------------------------------------------------
-- Lookup tables
----------------------------------------------------------------------------------------------------

-- Item lookup
helper.items = {}
local function construct_items()
    local items = {}
    for item_class, _ in pairs(defines.prototypes.item) do
        if data.raw[item_class] ~= nil then
            for _, item in pairs(data.raw[item_class]) do
                items[item.name] = item
            end
        end
    end
    helper.items = items
end

helper.entities = {}
local function construct_entities()
    local entities = {}
    for entity_class, _ in pairs(defines.prototypes.entity) do
        if data.raw[entity_class] ~= nil then
            for _, entity in pairs(data.raw[entity_class]) do
                entities[entity.name] = entity
            end
        end
    end
    helper.entities = entities
end

helper.material_to_prot = {}
local function construct_material_to_prot()
    local material_to_prot = {}
    for _, item in pairs(helper.items) do
        material_to_prot["item-" .. item.name] = item
    end
    for _, fluid in pairs(data.raw.fluid) do
        material_to_prot["fluid-" .. fluid.name] = fluid
    end
    helper.material_to_prot = material_to_prot
end

-- Not every node type has a surface-agnostic form!
-- CRITICAL TODO: Account for this!
helper.surface_to_agnostic = {}
local function construct_surface_to_agnostic()
    helper.surface_to_agnostic = {}
    for _, node in pairs(dep_graph) do
        if build_graph.ops[node.type .. "-surface"] ~= nil then
            for surface_name, surface in pairs(build_graph.surfaces) do
                if helper.specify_node_to_surface(node, surface_name) ~= nil then
                    helper.surface_to_agnostic[graph_utils.get_node_key(helper.specify_node_to_surface(node, surface_name))] = node
                end
            end
        end
    end
end

helper.init = function()
    construct_items()
    construct_entities()
    construct_material_to_prot()
    construct_surface_to_agnostic()
end

----------------------------------------------------------------------------------------------------
-- Misc. helper functions
----------------------------------------------------------------------------------------------------

local function get_material_type(material_name)
    if material_name == "dummy" then
        return "dummy"
    end

    local material_prot = helper.material_to_prot[material_name]
    if material_prot.type == "fluid" then
        return "fluid"
    else
        return "item"
    end
end
helper.get_material_type = get_material_type

local function get_material_name(material_name)
    if material_name == "dummy" then
        return "dummy"
    end

    return helper.material_to_prot[material_name].name
end
helper.get_material_name = get_material_name

-- Turns a slot or traveler into its "canonical" node
local function to_canonical(slot_or_traveler)
    return helper.conn_handlers[slot_or_traveler.handler_id].to_canonical(slot_or_traveler)
end
helper.to_canonical = to_canonical

local function specify_node_to_surface(node, surface_name)
    return graph_utils.getk(node.type .. "-surface", build_graph.compound_key({node.name, surface_name}))
end
helper.specify_node_to_surface = specify_node_to_surface

local function get_surface_variants(node)
    local nodes = {}
    for surface_name, surface in pairs(build_graph.surfaces) do
        local surface_node = specify_node_to_surface(node, surface_name)
        table.insert(nodes, surface_node)
    end
    return nodes
end
helper.get_surface_variants = get_surface_variants

-- Copies a collection of nodes to create new dummy nodes, then rewires connections so that any copied nodes only point to copies if applicable
-- Also copies corresponding -surface nodes if applicable
local function copy_node_set(node_set, suffix)
    local function orig_to_copy_key(orig_node)
        if orig_node.surface ~= nil then
            local surface_agnostic_name = helper.surface_to_agnostic[graph_utils.get_node_key(orig_node)].name
            return build_graph.compound_key({build_graph.compound_key({surface_agnostic_name, build_graph.compound_key({"dupe", suffix})}), orig_node.surface})
        else
            return build_graph.compound_key({orig_node.name, build_graph.compound_key({"dupe", suffix})})
        end
    end

    local orig_to_new = {}

    local function copy_node(node)
        local new_node = table.deepcopy(node)
        new_node.dummy = true
        new_node.original = graph_utils.get_node_key(node)
        new_node.name = orig_to_copy_key(node)
        -- Set special keys to "dummy"
        local normal_keys = {
            ["type"] = true,
            ["name"] = true,
            ["prereqs"] = true,
            ["dependents"] = true,
            ["original"] = true,
            ["dummy"] = true,
            -- Surface is technically special, but not something we want to set to dummy
            ["surface"] = true,
        }
        for k, v in pairs(new_node) do
            if not normal_keys[k] then
                new_node[k] = "dummy"
            end
        end
        orig_to_new[graph_utils.get_node_key(node)] = new_node
        dep_graph[graph_utils.get_node_key(new_node)] = new_node
    end

    for _, node in pairs(node_set) do
        copy_node(node)
        if build_graph.ops[node.type .. "-surface"] ~= nil then
            for surface_name, _ in pairs(build_graph.surfaces) do
                copy_node(specify_node_to_surface(node, surface_name))
            end
        end
    end

    -- Fix edges (prereqs/dependents)
    for _, new_node in pairs(orig_to_new) do
        for _, edge_type in pairs({"prereqs", "dependents"}) do
            local new_deps_or_prereqs = {}
            for _, dep_or_prereq in pairs(new_node[edge_type]) do
                local other_node = graph_utils.get(dep_or_prereq)
                local other_node_copy = orig_to_new[graph_utils.get_node_key(other_node)]
                -- Check if this was a just-copied node
                if other_node_copy ~= nil then
                    -- If so, connect to the new copy instead
                    table.insert(new_deps_or_prereqs, {
                        type = other_node_copy.type,
                        name = other_node_copy.name,
                    })
                else
                    -- Otherwise, go to the other node and add this to its prereqs/dependents
                    local other_key_to_modify
                    if edge_type == "prereqs" then
                        other_key_to_modify = "dependents"
                    elseif edge_type == "dependents" then
                        other_key_to_modify = "prereqs"
                    end
                    table.insert(new_deps_or_prereqs, dep_or_prereq)
                    table.insert(other_node[other_key_to_modify], {
                        type = new_node.type,
                        name = new_node.name,
                    })
                end
            end
            new_node[edge_type] = new_deps_or_prereqs
        end
    end

    return orig_to_new
end
helper.copy_node_set = copy_node_set

local function create_dummy_node(node_type, node_name)
    local new_node = {
        type = node_type,
        name = node_name,
        prereqs = {},
        dependents = {},
        dummy = true,
    }
    dep_graph[graph_utils.get_node_key(new_node)] = new_node
    return new_node
end
helper.create_dummy_node = create_dummy_node

----------------------------------------------------------------------------------------------------
-- Prototype helpers (these should probably get put into a dedicated file)
----------------------------------------------------------------------------------------------------

local function remove_recipe_tech_unlock(recipe_name)
    -- We can get the tech unlock from the graph!
    local tech_unlock_node = graph_utils.getk("recipe-tech-unlock", recipe_name)
    for _, prereq in pairs(tech_unlock_node.prereqs) do
        -- The only prereqs of a tech unlock node should be technologies
        local tech_prot = data.raw.technology[prereq.name]
        if tech_prot.effects ~= nil then
            local ind_to_remove
            for ind, effect in pairs(tech_prot.effects) do
                if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
                    ind = ind_to_remove
                end
            end
            table.remove(tech_prot, ind_to_remove)
        end
    end
end
helper.remove_recipe_tech_unlock = remove_recipe_tech_unlock

----------------------------------------------------------------------------------------------------
-- Priority calculations
----------------------------------------------------------------------------------------------------

-- Constants for balance can be found in helper-tables/constants.lua

local function is_boring_item(item_prototype)
    return not (item_prototype.type ~= "item" or item_prototype.place_result ~= nil or item_prototype.place_as_equipment_result ~= nil or (item_prototype.fuel_category ~= nil and item_prototype.fuel_category ~= "chemical") or item_prototype.plant_result ~= nil or item_prototype.place_as_tile ~= nil)
end
helper.is_boring_item = is_boring_item

local function find_base_priority(traveler, state)
    if traveler.dummy then
        return -1
    end

    local priority = 0

    local traveler_node = to_canonical(traveler)
    for _, criticality_table_key in pairs({"is_critical", "is_significant"}) do
        local criticality_table = state[criticality_table_key]
        if criticality_table[graph_utils.get_node_key(traveler_node)] then
            priority = priority + constants.unified_randomization_bonus_priority_criticality[criticality_table_key]
        elseif helper.conn_handlers[traveler.handler_id].group_surfaces then
            local surface_variant_nodes = get_surface_variants(traveler_node)
            for _, node in pairs(surface_variant_nodes) do
                if criticality_table[graph_utils.get_node_key(node)] then
                    priority = priority + constants.unified_randomization_bonus_priority_criticality[criticality_table_key]
                    break
                end
            end
        end
    end

    if state.node_to_surface[graph_utils.get_node_key(traveler_node)] ~= build_graph.compound_key({"planet", "nauvis"}) then
        priority = priority + constants.unified_randomization_bonus_priority_surface
    end

    return priority
end

local function find_priority(traveler, state)
    local priority = 0

    priority = priority + find_base_priority(traveler, state)
    
    return priority
end
helper.find_priority = find_priority

return helper
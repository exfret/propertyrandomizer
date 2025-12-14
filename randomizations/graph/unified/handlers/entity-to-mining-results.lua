local build_graph = require("lib/graph/build-graph")
local graph_utils = require("lib/graph/graph-utils")
local helper = require("randomizations/graph/unified/helper")

-- Randomize what entities given when you mine them

local entity_to_mining_results = {}

entity_to_mining_results.source_types = {
    ["mine-entity-surface"] = true,
}
entity_to_mining_results.target_types = {
    ["item-surface"] = true,
    ["create-fluid-surface"] = true,
}
entity_to_mining_results.group_surfaces = true

entity_to_mining_results.add_dummies = function()
    -- For all simple entities, add an extra dummy item mining result
    -- Unfortunately, we can't really add dummy fluid mining results
    for _, probably_a_rock in pairs(data.raw["simple-entity"]) do
        if probably_a_rock.minable ~= nil then
            local minable = probably_a_rock.minable
            -- TODO: This could probably be moved to reformat.lua
            if minable.results == nil and minable.result ~= nil then
                minable.results = {
                    {
                        type = "item",
                        name = minable.result,
                        amount = minable.count or 1
                    }
                }
            end
            -- Still need to check in case minable.result was also nil
            if minable.results ~= nil then
                -- Add a dummy item
                -- TODO: There's probably a way to make this into a helper function; I seem to be doing this a lot
                local dummy_mine_item = helper.create_dummy_node("item", build_graph.compound_key({probably_a_rock.name, "entity-mining-dummy"}))
                dummy_mine_item.item = "dummy"
                for surface_name, surface in pairs(build_graph.surfaces) do
                    local surface_dummy_mine_item = helper.create_dummy_node("item-surface", build_graph.compound_key({build_graph.compound_key({probably_a_rock.name, "entity-mining-dummy"}), surface_name}))
                    surface_dummy_mine_item.surface = surface_name
                    surface_dummy_mine_item.item = "dummy"
                    local surface_entity_node = graph_utils.getk("mine-entity-surface", build_graph.compound_key({probably_a_rock.name, surface_name}))
                    graph_utils.add_prereq(surface_entity_node, surface_dummy_mine_item)
                    graph_utils.add_prereq(surface_dummy_mine_item, dummy_mine_item)
                end
            end
        end
    end
end

entity_to_mining_results.create_slot = function(edge)
    -- build_graph entity nodes don't have an "entity = entity_name" property and I don't feel like spending an hour or two adding one at this point, so we need to be a little more creative about getting the entity name
    local entity_name = edge[1].name
    -- Check where in the minable results this is
    local entity = helper.entities[entity_name]
    -- Keep track of all inds that have that have this result
    local inds = {}
    if entity.minable.results == nil and entity.minable.result ~= nil then
        entity.minable.results = {
            {
                type = "item",
                name = entity.minable.result,
                amount = entity.minable.count or 1
            }
        }
    end
    if entity.minable == nil or entity.minable.results == nil then
        return false
    end
    -- Check for non-resource entities that return their item; don't randomize those
    if entity.type ~= "resource" and entity.minable.results[1].name == entity.name then
        return false
    end
    for ind, result in pairs(entity.minable.results) do
        if result.type == "item" and edge[2].item == result.name then
            table.insert(inds, ind)
        elseif result.type == "fluid" and edge[2].fluid == result.name then
            table.insert(inds, ind)
        end
    end

    if edge[2].dummy then
        inds = "dummy"
    end

    return {
        entity = entity_name,
        inds = inds,
        item = edge[2].item,
        fluid = edge[2].fluid,
    }
end

entity_to_mining_results.create_traveler = function(edge)
    local material_type
    local material_name
    if edge[2].item ~= nil then
        material_type = "item"
        material_name = edge[2].item
    elseif edge[2].fluid ~= nil then
        material_type = "fluid"
        material_name = edge[2].fluid
    end
    return {
        item = edge[2].item,
        fluid = edge[2].fluid,
        material_type = material_type,
        material_name = material_name,
    }
end

entity_to_mining_results.to_canonical = function(slot_or_traveler)
    if slot_or_traveler.dummy then
        -- The slots still correspond to real entities
        if slot_or_traveler.connector_type == "slot" then
            return graph_utils.getk("mine-entity", slot_or_traveler.entity)
        end

        return "dummy"
    end

    if slot_or_traveler.connector_type == "slot" then
        return graph_utils.getk("mine-entity", slot_or_traveler.entity)
    elseif slot_or_traveler.connector_type == "traveler" then
        local material_type = slot_or_traveler.material_type
        local material_name = slot_or_traveler.material_name
        return graph_utils.getk(material_type, material_name)
    end
end

-- I think resources are our only trouble here
entity_to_mining_results.is_reservable = function(slot)
    if slot.dummy then
        return true
    end

    -- Wait let's try with even resources being reservable
    -- Didn't work well
    if data.raw.resource[slot.entity] == nil and slot.entity ~= "crude-oil" then
        return false
    end

    return true
end

entity_to_mining_results.traveler_priority = function(traveler)
    return helper.find_priority(traveler, entity_to_mining_results.state)
end

entity_to_mining_results.validate_connection = function(slot, traveler)
    -- CRITICAL TODO: Need to check that this slot supports fluid mining (is a resource with a mining category with mining drills having fluid outputs
    if traveler.item == nil and traveler.fluid == nil then
        return false
    end

    if slot.fluid ~= nil and traveler.fluid == nil then
        return false
    end
    if slot.item ~= nil and traveler.item == nil then
        return false
    end

    -- It's boring if crude oil patches make crude oil
    -- CRITICAL TODO: Change this back
    --[=[if slot.fluid == "crude-oil" and (helper.to_canonical(traveler).fluid == "crude-oil" --[[or helper.to_canonical(traveler).fluid == "water"]]) then
        return false
    end]=]

    return true
end

entity_to_mining_results.reflect = function(sorted_slots, slot_to_traveler)
    -- First turn all mining results into improper tables: indices may not be in order
    -- This is so that we know where to remove the mining results
    for _, slot in pairs(sorted_slots) do
        if slot.handler_id == "entity-to-mining-results" then
            local entity = helper.entities[slot.entity]

            local traveler = slot_to_traveler[graph_utils.get_node_key(slot)]
            if traveler ~= nil then
                if not traveler.dummy then
                    if slot.inds == "dummy" then
                        if traveler.item ~= nil then
                            table.insert(entity.minable.results, {
                                type = "item",
                                name = traveler.item,
                                amount = 1,
                            })
                        else
                            table.insert(entity.minable.results, {
                                type = "fluid",
                                name = traveler.fluid,
                                amount = 1,
                            })
                        end
                    else
                        for _, ind in pairs(slot.inds) do
                            if traveler.item ~= nil then
                                entity.minable.results[ind].type = "item"
                                entity.minable.results[ind].name = traveler.item
                            else
                                entity.minable.results[ind].type = "fluid"
                                entity.minable.results[ind].name = traveler.fluid
                            end
                        end
                    end
                else
                    for _, ind in pairs(slot.inds) do
                        entity.minable.results[ind] = nil
                    end
                end
            end
        end
    end

    -- Now, put indices back in order
    for _, entity in pairs(helper.entities) do
        if entity.minable ~= nil and entity.minable.results ~= nil then
            local new_minable_results = {}
            for _, result in pairs(entity.minable.results) do
                table.insert(new_minable_results, result)
            end
            entity.minable.results = new_minable_results
        end
    end
end

return entity_to_mining_results
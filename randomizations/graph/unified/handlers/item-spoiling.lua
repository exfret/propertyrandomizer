local build_graph = require("lib/graph/build-graph")
local graph_utils = require("lib/graph/graph-utils")
local helper = require("randomizations/graph/unified/helper")

-- TODO:
--  * Account for long spoilage times (it would suck to require what fish spoil into in order to proceed early on

local item_spoiling = {}

item_spoiling.state = {}
item_spoiling.init = function(state)
    for k, v in pairs(state) do
        item_spoiling.state[k] = v
    end
end

item_spoiling.source_types = {
    ["item-surface"] = true
}
item_spoiling.target_types = {
    ["item-surface"] = true
}
item_spoiling.group_surfaces = true

item_spoiling.add_dummies = function()
    -- dummies here can be just be some extra items that are valid to spoil, mainly non-surface-locked things (not sure if any other things shouldn't spoil)
    for _, item in pairs(helper.items) do
        -- Check that this doesn't already spoil
        -- Check all spoil properties just in case
        if item.spoil_result == nil and item.spoil_to_trigger_result == nil and item.spoil_ticks == nil then
            local item_node = graph_utils.getk("item", item.name)
            -- Right now, I just do a rudimentary "is this reachable on nauvis" check
            if item_spoiling.state.pre_dummy_sort_info.reachable[helper.specify_node_to_surface(item_node, build_graph.compound_key({"planet", "nauvis"}))] then
                -- We don't need to create a copy of this node, just a completely blank dummy node for something that this spoils into
                local item_spoil_node = helper.create_dummy_node("item", build_graph.compound_key({item_node.name, "item-spoiling-dummy"}))
                item_spoil_node.item = "dummy"
                for surface_name, surface in pairs(build_graph.surfaces) do
                    local surface_item_spoil_node = helper.create_dummy_node("item-surface", build_graph.compound_key({build_graph.compound_key({item_node.name, "item-spoiling-dummy"}), surface_name}))
                    surface_item_spoil_node.surface = surface_name
                    surface_item_spoil_node.item = "dummy"
                    local surface_item_node = specify_node_to_surface(item_node, surface_name)
                    graph_utils.add_prereq(surface_item_node, surface_item_spoil_node)
                    graph_utils.add_prereq(surface_item_spoil_node, item_spoil_node)
                end
            end
        end
    end
end

-- Note: I don't currently have item-surface --> item-surface nodes other than spoiling, but I should probably still check that this is a "spoils to this" connection for the future in case
-- TODO: Do this!
item_spoiling.create_slot = function(edge)
    -- The starting edge will never be a dummy (and must be an item-surface), so we can rely on its item
    return {
        item = edge[1].item
    }
end

item_spoiling.create_traveler = function(edge)
    -- The ending edge might be a dummy, but actually it will still have a .item field (set to dummy), so we're still good in that case
    return {
        item = edge[2].item
    }
end

item_spoiling.to_canonical = function(slot_or_traveler)
    -- Note: It doesn't matter too much, but slots should never be dummies
    if slot_or_traveler.dummy then
        return "dummy"
    end

    return graph_utils.getk("item", slot_or_traveler.item)
end

item_spoiling.is_reservable = function(slot)
    if slot.dummy then
        return tre
    end

    local slot_node = item_spoiling.to_canonical(slot)
    local corresponding_nodes = helper.get_surface_variants(slot_node)
    table.insert(corresponding_nodes, slot_node)
    for _, node in pairs(corresponding_nodes) do
        if item_spoiling.state.is_critical[graph_utils.get_node_key(node)] then
            return false
        end
    end
    return true
end

item_spoiling.traveler_priority = function(traveler)
    return helper.find_priority(traveler, item_spoiling.state)
end

item_spoiling.validate_connection = function(slot, traveler)
    if traveler.item == nil then
        return false
    end

    return true
end

item_spoiling.reflect = function(sorted_slots, slot_to_traveler)
    for _, slot in pairs(sorted_slots) do
        if slot.handler_id == "item-spoiling" then
            local item_prot = helper.items[slot.item]
            local traveler = slot_to_traveler[graph_utils.get_node_key(slot)]
            if traveler ~= nil then
                if not traveler.dummy then
                    item_prot.spoil_result = traveler.item

                    -- If this was a dummy slot, i.e.- the spoil ticks aren't set yet, then just set them to 20 minutes for now
                    if item_prot.spoil_ticks == nil then
                        item_prot.spoil_ticks = 20 * 60 * 60
                    end
                else
                    -- dummy traveler means "does not spoil"
                    -- Don't set spoil-ticks to nil because that could still be used for spoil_to_trigger_result, which is not covered by this randomization
                    item_prot.spoil_result = nil
                end
            end
        end
    end
end

return item_spoiling
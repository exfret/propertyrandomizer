-- TODO: When we get into caring about automatability, especially when adding recipe ingredients, we might want to give a closer eye to this
-- Since spoiling has item ins/outs along with recipe ingredients/results, they can share prereqs, so when we get there we'd want to keep an eye on making sure the automatable things stay with the recipes
-- TODO: Need to make sure you can also get rid of spoilage (maybe also a future problem)
-- Prevent rocket parts/blueprints and some special items (what counts as special other than rocket parts?)
-- TODO: Do a quick look through item subgroups/spawnables just to see anything that might need to be blacklisted

local gutils = require("new-lib/graph/graph-utils")
local dutils = require("new-lib/data-utils")
local top = require("new-lib/graph/top-sort")

local spoiling = {}

spoiling.id = "spoiling"

local function shouldnt_spoil(item)
    if item.hidden == true then
        return true
    end

    if item.spoil_result ~= nil or item.spoil_to_trigger_result ~= nil then
        return true
    end

    -- Problem: The iron bacteria --> iron ore connection seems extremely undesirable to mess with
    -- Solution: Added to blacklist
end

-- We'll probably need spoofing? I'll leave it here because it might become relevant sooner rather than later.
spoiling.spoof = function(graph)
    local spoof_node = gutils.add_node(graph, "item", "anything-could-spoil-spoof")
    spoof_node.op = "OR"

    -- Do a sort so we only consider reachable nodes
    local sort_info = top.sort(graph)

    local already_checked = {}
    for _, node_info in pairs(sort_info.open) do
        local node = graph.nodes[node_info.node]
        if node.type == "item" and not already_checked[node.name] then
            already_checked[node.name] = true
            local node_prot = gutils.deconstruct(node.prot)
            local item_prot = data.raw[node_prot.type][node_prot.name]

            if not shouldnt_spoil(item_prot) then
                gutils.add_edge(graph, node, spoof_node)
            end
        end
    end
end

spoiling.claim = function(graph, prereq, dep, trav)
    -- Spoiling is the only item --> item connection right now
    if prereq.type == "item" and dep.type == "item" then
        return 1
    end
end

spoiling.validate = function(graph, slot, trav, extra)
    -- Just allow anything for now
    local slot_owner = gutils.get_conn_owner(graph, slot)
    if slot_owner.type == "item" then
        return true
    else
        return false
    end
end

spoiling.reflect = function(graph, trav_to_new_slot, trav_to_handler)
    -- Remove old spoil effects
    for _, item in pairs(dutils.get_all_prots("item")) do
        -- Make sure not to clear blacklisted spoil results
        local is_blacklisted = randomization_info.options.unified["spoiling"].blacklisted_pre[gutils.key("item", item.name)]
        if item.spoil_result ~= nil and not is_blacklisted then
            item.spoil_result = nil
            item.spoil_ticks = nil
        end
    end

    -- A map from items to their new spoil results (if any)
    local item_new_spoil = {}

    for trav_key, slot in pairs(trav_to_new_slot) do
        if trav_to_handler[trav_key].id == "spoiling" then
            local trav = graph.nodes[trav_key]
            local trav_owner = gutils.get_conn_owner(graph, trav)
            -- Check that the spoil result is not a spoof
            if not string.find(trav_owner.name, "spoof") then
                local slot_owner = gutils.get_conn_owner(graph, slot)
                local item = dutils.get_prot("item", slot_owner.name)
                local spoil_result = trav_owner.name
                log(serpent.block({
                    item = item,
                    spoil_result = spoil_result,
                    spoil_ticks = trav.spoil_ticks
                }))
                table.insert(item_new_spoil, {
                    item = item,
                    spoil_result = spoil_result,
                    spoil_ticks = trav.spoil_ticks
                })
            end
        end
    end

    for _, spoil_info in pairs(item_new_spoil) do
        spoil_info.item.spoil_result = spoil_info.spoil_result
        spoil_info.item.spoil_ticks = spoil_info.spoil_ticks
    end
end

return spoiling
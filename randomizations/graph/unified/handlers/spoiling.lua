-- Spoiling: which items spoil (spoil_result) and what they spoil into, in both directions
-- Like mining-fluid-required, spoofs give both sides slots vanilla doesn't have: bases for items that could start spoiling, and heads for items that could become spoil results
-- A spoil result is an OR prerequisite of the item it makes, so an empty result slot is a detached head (never a base fed by true, which would make the item free)
-- So the search is custom, committing each choice through promotion's try_rewires like the entity handler's slots
-- Spoiling into an entity (spoil_to_trigger_result, like a biter egg hatching) is the entity handler's; an item can have both
-- Spoil times belong to the item (its base), and nothing here makes an item stop lasting a trip to another room (see dutils.survives_trip)

local gutils = require("lib/graph/graph-utils")
local dutils = require("lib/data-utils")
local top = require("lib/graph/context-sort")
local rng = require("lib/random/rng")
local logic = require("lib/logic/init")
local constants = require("helper-tables/constants")

local key = gutils.key

local spoiling = {}

spoiling.id = "spoiling"

-- An item has one spoil result, so each base is used once
spoiling.with_replacement = false

-- New result slots copy the counts of vanilla's spoil results (like spoilage's 8 spoilers) onto this many sets of random items
local NEW_RESULT_COPIES = 2
-- About twice as many spoilers as vanilla: every result slot, vanilla or new, is filled with this chance, and every vanilla spoiler keeps spoiling with it
local FILL_CHANCE = 2 / (1 + NEW_RESULT_COPIES)

-- Spoof node types (only in this graph)
local SINK_TYPE = "spoil-sink"
local SLOT_TYPE = "spoil-slot"
local SINK_NAME = "nothing"

local function rng_key()
    return rng.key({ id = "unified-spoiling" })
end

-- Vanilla item spoilers whose edge was claimed (item name --> true), so reflect only changes those
local claimed_spoilers
-- Spoil times of vanilla spoilers that last a trip, which new spoilers draw from
local new_spoil_ticks

spoiling.initialize = function()
    claimed_spoilers = {}
    new_spoil_ticks = {}
end

local function has_flag(item, flag)
    for _, item_flag in pairs(item.flags or {}) do
        if item_flag == flag then
            return true
        end
    end
    return false
end

-- Items that only exist in the cursor (blueprints, planners, remotes) aren't really items to hold, so they neither spoil nor are spoiled into
local function is_holdable(item)
    return item.hidden ~= true and not has_flag(item, "only-in-cursor") and not has_flag(item, "spawnable")
end

-- Whether an item that doesn't spoil into an item could start to
local function can_start_spoiling(item)
    -- Armor with an equipment grid never spoils (it would take the equipment with it)
    if item.type == "armor" and item.equipment_grid ~= nil then
        return false
    end
    return is_holdable(item) and (item.spoil_result == nil or (item.spoil_ticks or 0) <= 0)
end

-- Whether an item could become a spoil result it isn't in vanilla
-- A stack spoils into a stack of its result, so the result has to stack
local function can_be_new_result(item)
    return is_holdable(item) and dutils.is_stackable(item)
end

spoiling.spoof = function(graph)
    local spoof_types = {
        SINK_TYPE,
        SLOT_TYPE,
    }
    for _, spoof_type in pairs(spoof_types) do
        logic.type_info[spoof_type] = logic.type_info[spoof_type] or {
            op = "OR",
            canonical = spoof_type,
        }
    end
    local rng_k = rng_key()

    -- What an item spoils into belongs to the item, so first pass moves its spoil base with it (the spoiled-into side is a position, see always_slot_pre in compat/vanilla.lua)
    -- Count how many items spoil into each vanilla result
    local vanilla_result_counts = {}
    for _, edge in pairs(graph.edges) do
        if edge.spoils_into ~= nil then
            edge.identity_base = true
            local result = graph.nodes[edge.stop].name
            vanilla_result_counts[result] = (vanilla_result_counts[result] or 0) + 1
            local spoiler = dutils.get_prot("item", graph.nodes[edge.start].name)
            if dutils.survives_trip(spoiler) and (spoiler.spoil_ticks or 0) > 0 then
                table.insert(new_spoil_ticks, spoiler.spoil_ticks)
            end
        end
    end
    for _, item in pairs(dutils.get_all_prots("item")) do
        -- Items spoiling into entities (like eggs) also show what spoil times are like
        if item.spoil_to_trigger_result ~= nil and (item.spoil_ticks or 0) > 0 and dutils.survives_trip(item) then
            table.insert(new_spoil_ticks, item.spoil_ticks)
        end
    end
    table.sort(new_spoil_ticks)

    -- Only reachable items can spoil or be spoiled into
    local sort_info = top.sort(graph)
    local reachable_items = {}
    local already_checked = {}
    for _, pebble in pairs(sort_info.sorted) do
        local node = graph.nodes[pebble.node_key]
        if node.type == "item" and not already_checked[node.name] then
            already_checked[node.name] = true
            table.insert(reachable_items, node.name)
        end
    end
    table.sort(reachable_items)

    -- Each item that could start spoiling gets a base, from an edge into a sink nothing needs (its head starts detached, so it's only there to be claimed)
    local sink = gutils.add_node(graph, SINK_TYPE, SINK_NAME, {
        op = "OR",
        spoof = true,
    })
    for _, item_name in pairs(reachable_items) do
        if can_start_spoiling(dutils.get_prot("item", item_name)) then
            gutils.add_edge(graph, key("item", item_name), key(sink), {
                spoils_into = true,
                identity_base = true,
                starts_detached = true,
            })
        end
    end

    -- New result slots: vanilla's result counts, copied onto random items that aren't vanilla results
    -- Each slot is an edge from its own spoof node fed by true, whose head starts detached, so it's empty unless the search fills it
    local new_result_candidates = {}
    for _, item_name in pairs(reachable_items) do
        if vanilla_result_counts[item_name] == nil and can_be_new_result(dutils.get_prot("item", item_name)) then
            table.insert(new_result_candidates, item_name)
        end
    end
    rng.shuffle(rng_k, new_result_candidates)
    local counts = {}
    for result_name, count in pairs(vanilla_result_counts) do
        table.insert(counts, {
            name = result_name,
            count = count,
        })
    end
    table.sort(counts, function(a, b)
        return a.name < b.name
    end)
    local true_key = key("true", "")
    local next_candidate = 1
    for _ = 1, NEW_RESULT_COPIES do
        for _, vanilla_result in pairs(counts) do
            local result_name = new_result_candidates[next_candidate]
            if result_name ~= nil then
                next_candidate = next_candidate + 1
                for i = 1, vanilla_result.count do
                    local slot_name = gutils.concat({
                        result_name,
                        i,
                    })
                    local slot = gutils.add_node(graph, SLOT_TYPE, slot_name, {
                        op = "OR",
                        spoof = true,
                    })
                    gutils.add_edge(graph, true_key, key(slot))
                    gutils.add_edge(graph, key(slot), key("item", result_name), {
                        spoils_into = true,
                        starts_detached = true,
                    })
                end
            end
        end
    end
end

spoiling.claim = function(graph, prereq, dep, edge)
    -- Spoil edges are tagged where logic builds them (lib/logic/concrete.lua) and in spoof above, since other item --> item edges exist
    if edge.spoils_into ~= nil then
        if prereq.type == "item" and dep.type == "item" and edge.starts_detached == nil then
            claimed_spoilers[prereq.name] = true
        end
        return 1
    end
end

-- The search is custom, so the generic loop never asks
spoiling.validate = function(graph, base, head, extra)
    return false
end

-- The item a spoil base spoils (nil for a spoofed slot's base)
local function base_item(graph, base)
    local owner = gutils.get_owner(graph, base)
    if owner.type == "item" then
        return owner.name
    end
    return nil
end

-- The node a spoil head feeds: the item spoiled into, or the sink
local function head_target(graph, head)
    local orand = gutils.get_owner(graph, head)
    return graph.nodes[graph.orand_to_parent[key(orand)]]
end

spoiling.custom_prereq_search = function(params)
    local graph = params.random_graph
    local prom = params.promotion
    local rng_k = rng_key()

    -- The item first pass put at a position, so nothing is made to spoil into itself
    local function identity_at(position_name)
        if params.slot_to_trav == nil then
            return position_name
        end
        local trav_key = params.slot_to_trav[key("item", position_name)]
        if trav_key == nil then
            return position_name
        end
        return gutils.deconstruct(params.split_graph.nodes[trav_key].old_slot).name
    end

    -- Result heads (into items, vanilla or new) and spoiler bases (vanilla spoilers and items that could start spoiling)
    local vanilla_heads = {}
    local new_heads = {}
    local vanilla_spoiler_bases = {}
    local new_spoiler_bases = {}
    local head_keys = {}
    for node_key, node in pairs(graph.nodes) do
        if node.spoils_into ~= nil and node.type == "head" then
            table.insert(head_keys, node_key)
        end
    end
    table.sort(head_keys)
    for _, head_key in pairs(head_keys) do
        local head = graph.nodes[head_key]
        if head_target(graph, head).type == "item" then
            if head.starts_detached == nil then
                table.insert(vanilla_heads, head_key)
                table.insert(vanilla_spoiler_bases, head.old_base)
            else
                table.insert(new_heads, head_key)
            end
        end
    end
    for _, base_key in pairs(params.shuffled_prereqs) do
        local base = graph.nodes[base_key]
        if base.starts_detached ~= nil and base_item(graph, base) ~= nil then
            table.insert(new_spoiler_bases, base_key)
        end
    end
    rng.shuffle(rng_k, vanilla_heads)
    rng.shuffle(rng_k, new_heads)
    rng.shuffle(rng_k, vanilla_spoiler_bases)

    local used = {}
    local head_to_base = params.head_to_base
    local function rewire(head_key, base_key, should_commit)
        if prom == nil then
            return true
        end
        local change = {
            node_key = head_key,
            remove = prom.pre_keys_of(head_key),
        }
        if base_key == nil then
            change.detach = true
        else
            change.add = base_key
        end
        return prom.try_rewires({ change }, should_commit)
    end
    local function keep_vanilla(head_key)
        local base_key = graph.nodes[head_key].old_base
        if used[base_key] ~= nil then
            return false
        end
        used[base_key] = true
        head_to_base[head_key] = base_key
        return true
    end

    -- Vanilla slots a promise needs (like bacteria spoiling into Gleba's only ore) can't be emptied, so they're always filled, by their vanilla spoiler if nothing else keeps the promise
    -- Their vanilla spoilers are reserved for them until they're filled
    local open_vanilla_heads = {}
    local must_fill = {}
    local reserved = {}
    for _, head_key in pairs(vanilla_heads) do
        if rewire(head_key, nil, false) then
            table.insert(open_vanilla_heads, head_key)
        else
            table.insert(must_fill, head_key)
            reserved[graph.nodes[head_key].old_base] = true
        end
    end

    -- Every other slot is filled with FILL_CHANCE, and every vanilla spoiler keeps spoiling with it (into whatever slot it gets)
    local to_fill = {}
    local num_emptied = 0
    for _, head_key in pairs(open_vanilla_heads) do
        if rng.value(rng_k) < FILL_CHANCE then
            table.insert(to_fill, head_key)
        elseif rewire(head_key, nil, true) then
            num_emptied = num_emptied + 1
        elseif not keep_vanilla(head_key) then
            log("Spoiling: " .. head_key .. " can neither be emptied nor keep its vanilla spoiler")
            return false
        end
    end
    for _, head_key in pairs(new_heads) do
        if rng.value(rng_k) < FILL_CHANCE then
            table.insert(to_fill, head_key)
        end
    end
    rng.shuffle(rng_k, to_fill)
    -- Slots that must be filled go first, so their vanilla spoilers are still free to fall back on
    for i = #must_fill, 1, -1 do
        table.insert(to_fill, 1, must_fill[i])
    end
    local candidates = {}
    for _, base_key in pairs(vanilla_spoiler_bases) do
        if rng.value(rng_k) < FILL_CHANCE then
            table.insert(candidates, base_key)
        end
    end
    for _, base_key in pairs(new_spoiler_bases) do
        table.insert(candidates, base_key)
    end

    local num_filled = 0
    local num_kept = 0
    for _, head_key in pairs(to_fill) do
        local head = graph.nodes[head_key]
        reserved[head.old_base] = nil
        local result = identity_at(head_target(graph, head).name)
        local filled = false
        for _, base_key in pairs(candidates) do
            if used[base_key] == nil and reserved[base_key] == nil and base_item(graph, graph.nodes[base_key]) ~= result and rewire(head_key, base_key, true) then
                used[base_key] = true
                head_to_base[head_key] = base_key
                filled = true
                num_filled = num_filled + 1
                log("Spoiling: " .. base_item(graph, graph.nodes[base_key]) .. " spoils into position " .. head_target(graph, head).name)
                break
            end
        end
        -- A vanilla slot nothing could fill keeps its vanilla spoiler, or is emptied
        if not filled and head.starts_detached == nil then
            if keep_vanilla(head_key) then
                num_kept = num_kept + 1
            elseif rewire(head_key, nil, true) then
                num_emptied = num_emptied + 1
            else
                log("Spoiling: " .. head_key .. " can't be filled, emptied, or keep its vanilla spoiler")
                return false
            end
        end
    end
    log("Spoiling: " .. num_filled .. " slots filled, " .. num_kept .. " kept their vanilla spoiler, " .. num_emptied .. " vanilla slots emptied, " .. #must_fill .. " had to be filled for promises (" .. #vanilla_heads .. " vanilla and " .. #new_heads .. " new slots)")
end

spoiling.reflect = function(graph, head_to_base, head_to_handler)
    -- What each item spoils into now, as a position name (item randomization then renames it to the item at that position, so this reflects first)
    local new_result = {}
    for head_key, base_key in pairs(head_to_base) do
        if head_to_handler[head_key] ~= nil and head_to_handler[head_key].id == spoiling.id then
            local target = head_target(graph, graph.nodes[head_key])
            local spoiler = base_item(graph, graph.nodes[base_key])
            if target.type == "item" and spoiler ~= nil then
                new_result[spoiler] = target.name
            end
        end
    end

    -- Vanilla spoilers that got no slot stop spoiling into items; their spoil time stays if they also spoil into an entity
    for item_name, _ in pairs(claimed_spoilers) do
        if new_result[item_name] == nil then
            local item = dutils.get_prot("item", item_name)
            item.spoil_result = nil
            if item.spoil_to_trigger_result == nil then
                item.spoil_ticks = nil
            end
        end
    end
    for item_name, result_name in pairs(new_result) do
        local item = dutils.get_prot("item", item_name)
        item.spoil_result = result_name
        -- A new spoiler takes the spoil time of a vanilla one that lasts a trip, so it stays deliverable
        if (item.spoil_ticks or 0) <= 0 then
            if #new_spoil_ticks > 0 then
                item.spoil_ticks = new_spoil_ticks[rng.int(rng_key(), #new_spoil_ticks)]
            else
                item.spoil_ticks = constants.spoil_trip_ticks
            end
        end
    end
    dutils.recalculate_spoil_burnt_results()
end

return spoiling

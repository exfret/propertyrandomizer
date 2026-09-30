-- Spoiling: which items spoil (spoil_result) and what they spoil into, in both directions
-- Like mining-fluid-required, spoofs give both sides slots vanilla doesn't have: bases for items that could start spoiling, and heads for items that could become spoil results
-- A spoil result is an OR prerequisite of the item it makes, so an empty result slot is a detached head (never a base fed by true, which would make the item free)
-- So the search is custom, committing each choice through promotion's try_rewires like the entity handler's slots
-- Spoiling into an entity (spoil_to_trigger_result, like a biter egg hatching) is the entity handler's; an item can have both
-- Spoil times belong to the item (its base), and nothing here makes an item stop lasting a trip to another room (see dutils.survives_trip)
-- Spoil results need a sink, a way machines can use them up on the way to research (see lib/item-sinks.lua): new results prefer items with one, and after_changes gives chemical fuel to any spoil result without one

local gutils = require("lib/graph/graph-utils")
local dutils = require("lib/data-utils")
local item_sinks = require("lib/item-sinks")
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
-- The search picks each of those items among this many random ones, preferring one with a sink (see lib/item-sinks.lua)
-- Only the search knows which identity first pass put at each position, and whether a path ends at an item moves with its identity
local NEW_RESULT_CHOICES = 3
-- About twice as many spoilers as vanilla: every result slot, vanilla or new, is filled with this chance, and every vanilla spoiler keeps spoiling with it
local FILL_CHANCE = 2 / (1 + NEW_RESULT_COPIES)

-- An item's fuel, as ItemPrototype's fields; burnt_result is left out, so burning a spoil result gives nothing
local FUEL_FIELDS = {
    "fuel_value",
    "fuel_categories",
    "fuel_acceleration_multiplier",
    "fuel_top_speed_multiplier",
    "fuel_emissions_multiplier",
    "fuel_glow_color",
    "fuel_acceleration_multiplier_quality_bonus",
    "fuel_top_speed_multiplier_quality_bonus",
}

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
-- The fuel spoil results with no sink get (see after_changes), as {source = item name, fields = FUEL_FIELDS' values}, or nil if no vanilla spoil result burns as chemical fuel
local fallback_fuel

spoiling.initialize = function()
    claimed_spoilers = {}
    new_spoil_ticks = {}
    fallback_fuel = nil
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

    -- Spoil results with no sink burn like the vanilla spoil result that burns as chemical fuel and that the most items spoil into (spoilage in Space Age)
    local sinks_context = item_sinks.context(data.raw)
    local fuel_source
    for result_name, count in pairs(vanilla_result_counts) do
        if item_sinks.burns_chemical(sinks_context, dutils.get_prot("item", result_name)) then
            local source_count = vanilla_result_counts[fuel_source] or 0
            if count > source_count or (count == source_count and result_name < fuel_source) then
                fuel_source = result_name
            end
        end
    end
    if fuel_source ~= nil then
        local source_prot = dutils.get_prot("item", fuel_source)
        fallback_fuel = {
            source = fuel_source,
            fields = {},
        }
        for _, field in pairs(FUEL_FIELDS) do
            fallback_fuel.fields[field] = table.deepcopy(source_prot[field])
        end
    end

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
    -- Each copy of a count is a group with NEW_RESULT_CHOICES items to choose from, whose slots the search fills for only one of them
    -- Each slot is an edge from its own spoof node fed by true, whose head starts detached, so it's empty unless the search fills it
    -- Items with a sink in the game as it is come first (most final products have none), since the search prefers results with one, and a position's recipes keep leading where they did whatever identity first pass puts there
    local sinkable = item_sinks.sinkable(data.raw, old_data_raw)
    local candidates_with_sink = {}
    local candidates_without_sink = {}
    for _, item_name in pairs(reachable_items) do
        if vanilla_result_counts[item_name] == nil and can_be_new_result(dutils.get_prot("item", item_name)) then
            if item_sinks.has_sink(sinkable, item_name) then
                table.insert(candidates_with_sink, item_name)
            else
                table.insert(candidates_without_sink, item_name)
            end
        end
    end
    rng.shuffle(rng_k, candidates_with_sink)
    rng.shuffle(rng_k, candidates_without_sink)
    local new_result_candidates = candidates_with_sink
    for _, item_name in pairs(candidates_without_sink) do
        table.insert(new_result_candidates, item_name)
    end
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
    for copy = 1, NEW_RESULT_COPIES do
        for _, vanilla_result in pairs(counts) do
            local group = gutils.concat({
                copy,
                vanilla_result.name,
            })
            for choice = 1, NEW_RESULT_CHOICES do
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
                            spoil_group = group,
                            spoil_choice = choice,
                        })
                    end
                end
            end
        end
    end

    -- This handler matches spoil slots itself (custom_prereq_search), so first pass mustn't split the orands of its edges (make_orands names each orand after the edge it splits), like the entity handler's slots
    -- Otherwise first pass would trade what spoil edges lead to among themselves, which reflect never applies, and its model would lose what the game keeps, like Gleba's bacteria spoiling into ore
    for edge_key, edge in pairs(graph.edges) do
        if edge.spoils_into ~= nil then
            randomization_info.options.first_pass.blacklist[key("orand", edge_key)] = true
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
    -- New result heads by group, then by choice (see spoof)
    local new_head_choices = {}
    for _, head_key in pairs(head_keys) do
        local head = graph.nodes[head_key]
        if head_target(graph, head).type == "item" then
            if head.starts_detached == nil then
                table.insert(vanilla_heads, head_key)
                table.insert(vanilla_spoiler_bases, head.old_base)
            else
                new_head_choices[head.spoil_group] = new_head_choices[head.spoil_group] or {}
                new_head_choices[head.spoil_group][head.spoil_choice] = new_head_choices[head.spoil_group][head.spoil_choice] or {}
                table.insert(new_head_choices[head.spoil_group][head.spoil_choice], head_key)
            end
        end
    end

    -- Each group's slots are those of its first choice with a sink, or else of its first choice that can be a new result at all (after_changes gives that one a fuel value)
    -- Reflect hasn't built the game yet, so sinks are judged on the game it will build: recipes stay with positions, while ending a path and what an item spoils into move with the identity first pass put there (see lib/item-sinks.lua)
    local sinkable = item_sinks.sinkable(data.raw, old_data_raw, function(position_name)
        return dutils.get_prot("item", identity_at(position_name))
    end)
    local groups = {}
    for group, _ in pairs(new_head_choices) do
        table.insert(groups, group)
    end
    table.sort(groups)
    local num_without_sink = 0
    for _, group in pairs(groups) do
        local chosen
        local does_chosen_sink = false
        for choice = 1, NEW_RESULT_CHOICES do
            local choice_heads = new_head_choices[group][choice]
            if choice_heads ~= nil and not does_chosen_sink then
                local position_name = head_target(graph, graph.nodes[choice_heads[1]]).name
                local identity = dutils.get_prot("item", identity_at(position_name))
                if identity ~= nil and can_be_new_result(identity) then
                    local has_sink = item_sinks.has_sink(sinkable, position_name)
                    if chosen == nil or has_sink then
                        chosen = choice
                        does_chosen_sink = has_sink
                    end
                end
            end
        end
        if chosen ~= nil then
            for _, head_key in pairs(new_head_choices[group][chosen]) do
                table.insert(new_heads, head_key)
            end
            if not does_chosen_sink then
                num_without_sink = num_without_sink + 1
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
    log("Spoiling: " .. num_filled .. " slots filled, " .. num_kept .. " kept their vanilla spoiler, " .. num_emptied .. " vanilla slots emptied, " .. #must_fill .. " had to be filled for promises (" .. #vanilla_heads .. " vanilla and " .. #new_heads .. " new slots, " .. num_without_sink .. " of " .. #groups .. " new results without a sink)")
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

-- Makes an item burn as chemical fuel and returns how, for the log
-- An item that isn't a fuel yet burns like fallback_fuel's source; a fuel of other categories keeps its energy and gains the chemical category, since an item can have several (see dutils.fuel_categories)
local function give_chemical_fuel(item)
    if item.fuel_value ~= nil and util.parse_energy(item.fuel_value) > 0 then
        if not dutils.has_fuel_category(item, item_sinks.CHEMICAL_FUEL_CATEGORY) then
            -- A copy, since a mod can share one category list between prototypes
            local fuel_categories = table.deepcopy(item.fuel_categories or {})
            table.insert(fuel_categories, item_sinks.CHEMICAL_FUEL_CATEGORY)
            item.fuel_categories = fuel_categories
        end
        return "keeps its fuel value and burns as chemical fuel"
    end
    if fallback_fuel ~= nil then
        for _, field in pairs(FUEL_FIELDS) do
            item[field] = table.deepcopy(fallback_fuel.fields[field])
        end
        return "burns like " .. fallback_fuel.source
    end
    dutils.give_replacement_fuel(item)
    return "burns as chemical fuel (no vanilla spoil result burns as chemical fuel to copy)"
end

-- Spoil results need a sink (see lib/item-sinks.lua), so any without one burns as chemical fuel, even one the recycler takes (user, 2026-09-27 and 2026-09-29)
-- It judges the game every handler built, since item, recipe and entity randomization change sinks after the search, and a vanilla result's position can hold another identity by then
-- Burning is only added, so logic built from this game (the unified check) can only reach more than the model counted on
spoiling.after_changes = function()
    local sinkable = item_sinks.sinkable(data.raw, old_data_raw)
    local sinks_context = item_sinks.context(data.raw)
    local is_result = {}
    for _, item in pairs(dutils.get_all_prots("item")) do
        -- ItemPrototype::spoil_result is only loaded with a spoil time above 0
        if item.spoil_result ~= nil and (item.spoil_ticks or 0) > 0 then
            is_result[item.spoil_result] = true
        end
    end
    local result_names = {}
    for result_name, _ in pairs(is_result) do
        table.insert(result_names, result_name)
    end
    table.sort(result_names)
    for _, result_name in pairs(result_names) do
        local result = dutils.get_prot("item", result_name)
        if result ~= nil and not item_sinks.has_sink(sinkable, result_name) then
            log("Spoiling: " .. result_name .. " is a spoil result without a sink, so it " .. give_chemical_fuel(result))
            if not item_sinks.is_end_point(sinks_context, result) then
                log("Spoiling: " .. result_name .. " still has no sink, since no burner can burn it (a fuel with a burnt result needs a burner with a burnt result inventory)")
            end
        end
    end
end

return spoiling

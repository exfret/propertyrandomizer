-- Research triggers (on with the unified randomizations in development): a technology researched by a trigger gets a new one (user, 2026-10-07)
-- A technology's trigger is one slot, the edge from its technology-trigger node (an OR over what meets the trigger, lib/logic/concrete.lua) into the technology
-- New triggers are spoofed bases (see spoof), one off each node of something a trigger can ask for: crafting an item or a fluid, mining an entity map generation places, building an entity an item places, capturing a spawner, creating a space platform (lib/research-triggers.lua says which qualify)
-- Sending an item to orbit isn't offered: the docs don't say whether a Space Age rocket carrying an item to a platform counts, and only items with a send_to_orbit_mode can go on their own (ItemPrototype::send_to_orbit_mode), which the logic's item-launch node doesn't model; a technology with such a trigger can still get a new one
-- With first pass and promotion, triggers are chosen up front and checked on the whole game (choose_up_front below), so a new trigger may come after the old one, favoring what became doable near it (user, 2026-10-08)
-- A technology not chosen there goes to the custom search: a technology forgets its room once researched (context-sort.lua), so the generic shuffle's per-context check doesn't fit it (the technology is had on the platform while no trigger can be met there), and each choice is committed through promotion's try_rewires like the spoiling and entity handlers, which re-establishes the trigger slot's own promised pebbles (where the old trigger was met) with the new trigger
-- With the tech tree rebuild, trigger technologies are split per recipe before unified randomization (research_triggers.split_technologies, called from data-final-fixes.lua), so each recipe's technology gets its own trigger
-- A technology keeps its own trigger only when no new one fits (user, 2026-10-07); new kinds come up about as often as the game's own triggers use them (research_triggers.kind_weights)
-- A craft trigger asks for about as much as the old trigger cost in raw materials (user, 2026-10-07), from the logic graph's prices of the game before randomization (graph_cost.material_costs_anywhere)
-- A craft trigger names a position, which item randomization renames to the identity first pass put there (handlers/item.lua), since that's what the model's item-craft node is about

local gutils = require("lib/graph/graph-utils")
local dutils = require("lib/data-utils")
local top = require("lib/graph/context-sort")
local rng = require("lib/random/rng")
local logic = require("lib/logic/init")
local context_costs = require("lib/cost/context-costs")
local research_triggers = require("lib/research-triggers")

local tech_triggers = {}

tech_triggers.id = "tech_triggers"

tech_triggers.with_replacement = true

-- How many new triggers a technology tries through promotion before it keeps its own; candidates that can't be met before the old trigger was are left out without trying (could_back below)
local MAX_TRIES = 40

-- Spoofed sink the new triggers' edges go into (only in this graph); nothing needs it, and each edge's head starts detached, so its base is only there to be claimed, like spoiling's sink
local SINK_TYPE = "technology-trigger-sink"
local SINK_NAME = "options"

-- Technology name --> its research trigger before any change
local old_triggers
-- Entity name --> items that place it, in the game before reflect (research_triggers.placers), for build triggers' costs
local placers

tech_triggers.initialize = function()
    -- Which technologies have each technology's old trigger after reflect, for checks comparing the final game with the model, or nil if it didn't run
    UNIFIED_TRIGGER_TAKERS = nil
    old_triggers = {}
    for _, tech in pairs(data.raw.technology) do
        if tech.research_trigger ~= nil then
            old_triggers[tech.name] = table.deepcopy(tech.research_trigger)
        end
    end
    placers = {}
end

-- The new trigger a logic node can be (see research_triggers.make), or nil
local function option_of(node, items, entities)
    if node.type == "item-craft" then
        if items[node.name] ~= nil and research_triggers.item_ok(items[node.name]) then
            return {
                kind = "craft-item",
                target = node.name,
            }
        end
    elseif node.type == "fluid-craft" then
        local fluid = (data.raw.fluid or {})[node.name]
        if fluid ~= nil and research_triggers.fluid_ok(fluid) then
            return {
                kind = "craft-fluid",
                target = node.name,
            }
        end
    elseif node.type == "entity-mine" then
        if entities[node.name] ~= nil and research_triggers.mine_ok(entities[node.name]) then
            return {
                kind = "mine-entity",
                target = node.name,
            }
        end
    elseif node.type == "entity-build" then
        if entities[node.name] ~= nil and research_triggers.build_ok(entities[node.name], placers[node.name]) then
            return {
                kind = "build-entity",
                target = node.name,
            }
        end
    elseif node.type == "entity-capture-spawner" then
        if entities[node.name] ~= nil then
            return {
                kind = "capture-spawner",
                target = node.name,
            }
        end
    elseif node.type == "capture-spawner" then
        -- Capturing any spawner (lib/logic/abstract.lua)
        return {
            kind = "capture-spawner",
        }
    elseif node.type == "create-platform" then
        return {
            kind = "create-space-platform",
        }
    end
    return nil
end

tech_triggers.spoof = function(graph)
    logic.type_info[SINK_TYPE] = logic.type_info[SINK_TYPE] or {
        op = "OR",
        canonical = SINK_TYPE,
    }
    local items = dutils.get_all_prots("item")
    local entities = dutils.get_all_prots("entity")
    placers = research_triggers.placers(items, entities)

    local sink = gutils.add_node(graph, SINK_TYPE, SINK_NAME, {
        op = "OR",
        spoof = true,
    })
    -- Every option gets a base, from an edge into the sink whose head starts detached; claiming only reaches the edges of what's reachable, so only that gets one
    local option_keys = {}
    local options = {}
    for node_key, node in pairs(graph.nodes) do
        local option = option_of(node, items, entities)
        if option ~= nil then
            table.insert(option_keys, node_key)
            options[node_key] = option
        end
    end
    table.sort(option_keys)
    for _, node_key in pairs(option_keys) do
        gutils.add_edge(graph, node_key, gutils.key(sink), {
            starts_detached = true,
            trigger_option = options[node_key],
        })
    end
end

tech_triggers.claim = function(graph, prereq, dep, edge)
    if dep == nil then
        return
    end
    if prereq.type == "technology-trigger" and dep.type == "technology" and old_triggers[dep.name] ~= nil then
        return 1
    end
    if dep.type == SINK_TYPE and edge ~= nil and edge.trigger_option ~= nil then
        return 1
    end
end

-- A technology's own trigger, or a new one
tech_triggers.validate = function(graph, base, head, extra)
    return base.trigger_option ~= nil or gutils.get_owner(graph, base).type == "technology-trigger"
end

-- Researching a technology adds automatability (tech_abilities in lib/logic/concrete.lua) whichever trigger it takes, so the connection gets its trigger edge's abilities
tech_triggers.connection_abilities = function(base, head)
    return head.abilities
end

-- The technology whose trigger slot a head is, or nil for an option's detached head
local function slot_technology(graph, head_key)
    local node = graph.nodes[head_key]
    if node == nil or node.type ~= "head" or node.old_base == nil or graph.nodes[node.old_base] == nil then
        return nil
    end
    local owner = gutils.get_owner(graph, graph.nodes[node.old_base])
    local dep = gutils.unique_depnode(graph, node)
    if owner.type == "technology-trigger" and dep ~= nil and dep.type == "technology" then
        return dep
    end
    return nil
end

-- How many whole-game sorts choosing up front may take (each took about 23 seconds in a game with planet copies on 2026-10-08), and in how many of them technologies whose choice failed pick again
local MAX_CHECKS = 3
local PICK_ROUNDS = 2
-- How much an option another technology took already counts, so technologies spread over what's near them
local USED_WEIGHT = 0.1
-- How much an option first doable on another planet than the old trigger counts: what's new on arriving somewhere is what that planet has, not what became doable elsewhere at about the same time, like late-game items from the starting planet (2026-10-08: a destroyer capsule for metallurgic science)
local OTHER_ROOM_WEIGHT = 0.25

-- Chooses every technology's new trigger before promotion ranks anything (see choose_up_front in handlers/default.lua), checked on the whole game, so a new trigger may come after the old one: promotion's fixed ranks only take one that came before it, and for the first thing on a planet almost nothing does (2026-10-08: 2-8 options for tungsten carbide, calcite processing or jellynut, against about 300 doable on their planets at all)
-- Each technology draws a kind like the game's own triggers, then an option of that kind near when its old trigger first became doable anywhere, preferring ones first doable on the same planet (research_triggers.nearness_weights, user 2026-10-08: favor what's newly available), from options had wherever its trigger slot was (keeping isolatability, user 2026-10-08) and first reached without it (sort_deferring), so no choice makes a cycle
-- A sort of the game with all the choices then checks that every technology keeps every context it had. Technologies that lose one pick again from options before their old trigger, then a last sort checks what's left, and if that still loses something every choice is dropped
-- Technologies not chosen here get the custom search's choice through promotion as before
tech_triggers.choose_up_front = function(params)
    local graph = params.random_graph
    local baseline_sort = params.baseline_sort
    local baseline = baseline_sort.node_to_context_inds
    local key = rng.key({
        id = "tech-triggers",
    })

    -- Option bases (the pool repeats some) and trigger slots, sorted
    local option_bases = {}
    local kinds = {}
    local seen = {}
    for _, base_key in pairs(params.pool) do
        local base = graph.nodes[base_key]
        if seen[base_key] == nil and base ~= nil and base.trigger_option ~= nil then
            seen[base_key] = true
            table.insert(option_bases, base_key)
            kinds[base.trigger_option.kind] = true
        end
    end
    table.sort(option_bases)
    local heads = {}
    for _, head_key in pairs(params.heads) do
        if slot_technology(graph, head_key) ~= nil then
            table.insert(heads, head_key)
        end
    end
    table.sort(heads)
    local kind_weights = research_triggers.kind_weights(old_triggers, kinds)

    -- Contexts of a base that get a context to a trigger slot through its connection (see top.edge_source_contexts), cached by context since every slot's connection has the same abilities
    local sources_of = {}
    local function sources(head, context)
        if sources_of[context] == nil then
            sources_of[context] = top.edge_source_contexts(baseline_sort, {
                abilities = head.abilities,
            }, context)
        end
        return sources_of[context]
    end

    -- A sort that connects the trigger slots one at a time once nothing else is left to reach (sort_deferring): an option sorted before a slot's entry needs neither that technology nor any connected after it, so options taken from there make no cycle, however late they come
    -- A trigger needing its own technology would cut off everything after it, so the check below would fail nearly every choice at once (it did, 2026-10-08: 1 of 93 kept their contexts)
    local deferred, entry = params.sort_deferring(heads)
    local deferred_rooms = deferred.node_to_context_inds
    -- A plain sort of the game in the order things become doable, by room: how early something is, for favoring options near the old trigger (the deferring sort can't say, since everything after a slot waits there until nothing else is left, putting old triggers next to late-game things)
    local in_order = params.sort_deferring({}).node_to_context_inds

    -- Per technology: its anchor (when its old trigger was first doable anywhere), and the options had wherever its slot was and somewhere before its entry, by kind, with when they were first doable anywhere
    local plans = {}
    local num_planned = 0
    for _, head_key in pairs(heads) do
        local head = graph.nodes[head_key]
        local tech = slot_technology(graph, head_key)
        local head_contexts = baseline[head_key] or {}
        local anchor
        local anchor_room
        for room, ind in pairs(in_order[head.old_base] or {}) do
            if anchor == nil or ind < anchor then
                anchor = ind
                anchor_room = room
            end
        end
        if anchor ~= nil and entry[head_key] ~= nil then
            local old_trigger = old_triggers[tech.name]
            local by_kind = {}
            -- Options first doable on another planet than the old trigger
            local elsewhere = {}
            for _, base_key in pairs(option_bases) do
                local option = graph.nodes[base_key].trigger_option
                local base_contexts = baseline[base_key]
                local before_entry = deferred_rooms[base_key] or {}
                if base_contexts ~= nil and not research_triggers.matches(option, old_trigger) then
                    -- Had wherever the slot was (some of it may come later, like isolatability on another planet, which the check below judges), and in one of those rooms before the slot's entry, so researching the technology at all never needs itself
                    local covers = true
                    local reaches_first = false
                    for context, _ in pairs(head_contexts) do
                        local had = false
                        for _, source in pairs(sources(head, context)) do
                            if base_contexts[source] ~= nil then
                                had = true
                                break
                            end
                        end
                        local room_ind = before_entry[top.context_room(context)]
                        if room_ind ~= nil and room_ind < entry[head_key] then
                            reaches_first = true
                        end
                        if not had then
                            covers = false
                            break
                        end
                    end
                    covers = covers and reaches_first
                    if covers then
                        -- When the option first became doable anywhere, since what's newly available is what nothing could do before, not what just became doable on the planet (on a new planet everything brought along does at once)
                        local index
                        local first_room
                        for room, ind in pairs(in_order[base_key] or {}) do
                            if index == nil or ind < index then
                                index = ind
                                first_room = room
                            end
                        end
                        if index ~= nil then
                            by_kind[option.kind] = by_kind[option.kind] or {}
                            by_kind[option.kind][base_key] = index
                            if first_room ~= anchor_room then
                                elsewhere[base_key] = true
                            end
                        end
                    end
                end
            end
            local weights = {}
            for kind, indices in pairs(by_kind) do
                weights[kind] = research_triggers.nearness_weights(indices, anchor)
                for base_key, _ in pairs(indices) do
                    if elsewhere[base_key] ~= nil then
                        weights[kind][base_key] = weights[kind][base_key] * OTHER_ROOM_WEIGHT
                    end
                end
            end
            plans[head_key] = {
                tech_key = gutils.key(tech),
                anchor = anchor,
                by_kind = by_kind,
                weights = weights,
            }
            num_planned = num_planned + 1
        end
    end

    -- Base key --> how many technologies took it
    local used = {}
    -- Head key --> base key --> true for choices that lost a context
    local rejected = {}
    local function pick(head_key, before_only)
        local plan = plans[head_key]
        local excluded = rejected[head_key] or {}
        local function allowed(base_key)
            return excluded[base_key] == nil and (not before_only or plan.by_kind[graph.nodes[base_key].trigger_option.kind][base_key] < plan.anchor)
        end
        local function has_options(kind)
            for base_key, _ in pairs(plan.by_kind[kind] or {}) do
                if allowed(base_key) then
                    return true
                end
            end
            return false
        end
        local kind = research_triggers.pick_kind(kind_weights, has_options, rng.value(key))
        if kind == nil then
            return nil
        end
        local weights = {}
        for base_key, weight in pairs(plan.weights[kind]) do
            if allowed(base_key) then
                weights[base_key] = weight * ((used[base_key] or 0) > 0 and USED_WEIGHT or 1)
            end
        end
        return research_triggers.pick_weighted(weights, rng.value(key))
    end

    local chosen = {}
    local to_pick = {}
    for _, head_key in pairs(heads) do
        if plans[head_key] ~= nil then
            table.insert(to_pick, head_key)
        end
    end
    local verified = false
    local num_checks = 0
    for check = 1, MAX_CHECKS do
        if check <= PICK_ROUNDS then
            for _, head_key in pairs(to_pick) do
                local base_key = pick(head_key, check > 1)
                if base_key ~= nil then
                    chosen[head_key] = base_key
                    used[base_key] = (used[base_key] or 0) + 1
                end
            end
        end
        if next(chosen) == nil then
            verified = true
            break
        end
        local sort_info = params.sort_without({}, chosen)
        num_checks = num_checks + 1
        local chosen_heads = {}
        for head_key, _ in pairs(chosen) do
            table.insert(chosen_heads, head_key)
        end
        table.sort(chosen_heads)
        to_pick = {}
        local failed_names = {}
        for _, head_key in pairs(chosen_heads) do
            local tech_key = plans[head_key].tech_key
            local after = sort_info.node_to_context_inds[tech_key] or {}
            local keeps = true
            for context, _ in pairs(baseline[tech_key] or {}) do
                if after[context] == nil then
                    keeps = false
                    break
                end
            end
            if not keeps then
                local base_key = chosen[head_key]
                rejected[head_key] = rejected[head_key] or {}
                rejected[head_key][base_key] = true
                used[base_key] = used[base_key] - 1
                chosen[head_key] = nil
                table.insert(to_pick, head_key)
                table.insert(failed_names, gutils.deconstruct(tech_key).name)
            end
        end
        log("Research triggers up front, check " .. num_checks .. ": " .. (#chosen_heads - #to_pick) .. " of " .. #chosen_heads .. " choices keep their technology's contexts" .. (#failed_names > 0 and ("; lost some: " .. table.concat(failed_names, ", ")) or ""))
        if #to_pick == 0 then
            verified = true
            break
        end
    end
    if not verified then
        log("Research triggers up front: the last check still lost contexts, so every technology is left to promotion's search")
        chosen = {}
    end
    local num_chosen = 0
    for _, _ in pairs(chosen) do
        num_chosen = num_chosen + 1
    end
    log("Research triggers up front: " .. num_chosen .. " of " .. #heads .. " technologies chose a new trigger (" .. num_planned .. " had options) in " .. num_checks .. " whole-game sorts; the rest go to promotion's search")
    return chosen
end

tech_triggers.custom_prereq_search = function(params)
    local graph = params.random_graph
    local prom = params.promotion
    local head_to_base = params.head_to_base
    local repair_only = params.repair_only == true
    local key = rng.key({
        id = "tech-triggers",
    })
    -- This handler's heads (a technology's trigger slot) and the new triggers' bases, sorted
    local heads = {}
    local option_bases = {}
    local kinds = {}
    for node_key, node in pairs(graph.nodes) do
        if node.type == "head" and node.old_base ~= nil and graph.nodes[node.old_base] ~= nil then
            local owner = gutils.get_owner(graph, graph.nodes[node.old_base])
            local dep = gutils.unique_depnode(graph, node)
            if owner.type == "technology-trigger" and dep ~= nil and dep.type == "technology" then
                table.insert(heads, node_key)
            end
        elseif node.type == "base" and node.trigger_option ~= nil then
            table.insert(option_bases, node_key)
            kinds[node.trigger_option.kind] = true
        end
    end
    table.sort(heads)
    table.sort(option_bases)
    local weights = research_triggers.kind_weights(old_triggers, kinds)

    local function rewire(head_key, base_key, should_commit)
        if prom == nil then
            return true
        end
        return prom.try_rewires({
            {
                node_key = head_key,
                remove = prom.pre_keys_of(head_key),
                add = base_key,
            },
        }, should_commit)
    end

    -- Earliest rank of a node's pebbles that could get a context to a head through the trigger connection, or false if it has none
    -- A connection only changes the abilities it names (edge.abilities, see context-sort.lua), and a technology's names only automatability (tech_abilities in lib/logic/concrete.lua), so they're the pebbles in the same room with the same isolatability unless the connection names that too; a home context goes through unchanged, and a simple context is its room
    local earliest_ranks = {}
    local function earliest_source(node_key, context, keeps_isolatability)
        local abilities = top.context_abilities(context)
        local group = context
        if top.context_home(context) == nil and abilities ~= nil then
            group = top.context_room(context) .. "|" .. (keeps_isolatability and string.sub(abilities, top.ISOLATABILITY, top.ISOLATABILITY) or "any")
        end
        earliest_ranks[node_key] = earliest_ranks[node_key] or {}
        local by_group = earliest_ranks[node_key]
        if by_group[group] == nil then
            local earliest = false
            if group == context then
                earliest = prom.rank(node_key, context) or false
            else
                for _, ability_str in pairs(top.ability_strs) do
                    if not keeps_isolatability or string.sub(ability_str, top.ISOLATABILITY, top.ISOLATABILITY) == string.sub(abilities, top.ISOLATABILITY, top.ISOLATABILITY) then
                        local rank = prom.rank(node_key, top.context_key(top.context_room(context), ability_str))
                        if rank ~= nil and (earliest == false or rank < earliest) then
                            earliest = rank
                        end
                    end
                end
            end
            by_group[group] = earliest
        end
        return by_group[group]
    end
    -- Whether a base could back the head's pebble in each context: it has a pebble that could get the context to the head before the head's, which re-establishing the head needs (promotion's base_backing), so a base without one isn't tried
    local function could_back(base_key, head_key, contexts)
        local abilities = graph.nodes[head_key].abilities
        local keeps_isolatability = abilities == nil or abilities[top.ISOLATABILITY] == nil
        for _, context in pairs(contexts) do
            local head_rank = prom.rank(head_key, context)
            local earliest = earliest_source(base_key, context, keeps_isolatability)
            if head_rank == nil or earliest == false or earliest >= head_rank then
                return false
            end
        end
        return true
    end

    -- Base key --> true once a technology took it, so another technology tries the rest first
    local used = {}
    local num_new = 0
    local num_kept_nothing_fits = 0
    local num_kept_unpromised = 0
    local num_tries = 0
    local kind_counts = {}
    -- Technologies that kept their own trigger, for the log
    local kept = {}
    -- Technologies whose trigger was chosen up front (choose_up_front) already have it, and count as taking it
    local num_up_front = 0
    local search_heads = {}
    for _, head_key in pairs(heads) do
        local up_front_base = head_to_base[head_key]
        if up_front_base ~= nil then
            used[up_front_base] = true
            num_up_front = num_up_front + 1
            local option = graph.nodes[up_front_base].trigger_option
            if option ~= nil then
                kind_counts[option.kind] = (kind_counts[option.kind] or 0) + 1
            end
        else
            table.insert(search_heads, head_key)
        end
    end
    for _, head_key in pairs(search_heads) do
        local head = graph.nodes[head_key]
        local tech_name = gutils.get_owner(graph, head).name
        local old_trigger = old_triggers[tech_name]

        -- The contexts the new trigger must back the head in, and in repair mode the ones it must pay for
        local contexts
        local paying_contexts = {}
        local consider = true
        -- Whether the head is anchored (see below), so a new trigger is checked and promised the generic handlers' way instead of through try_rewires
        local anchored = false
        if prom ~= nil then
            if repair_only then
                contexts = prom.required_contexts(head_key)
                paying_contexts = prom.recipe_boundary_contexts(head_key, contexts)
                consider = #paying_contexts > 0
            else
                contexts = prom.promised_contexts(head_key)
                -- Nothing promised rests on this technology's trigger yet (like a bonus technology's, which unlocks no recipe): like a recipe without promises, it's anchored in the earliest context it can be had, where the new trigger must come before the old one did, and promotion then keeps it there
                if #contexts == 0 then
                    -- resolve_head promises the technology there too, so only contexts it has a pebble in (one with prerequisites kept, see REMOVE_TECH_PREREQS in execute.lua, might not)
                    local tech_key = gutils.key(gutils.unique_depnode(graph, head))
                    contexts = {}
                    for _, context in pairs(prom.required_contexts(head_key)) do
                        if prom.rank(tech_key, context) ~= nil then
                            table.insert(contexts, context)
                        end
                    end
                    anchored = true
                    if #contexts == 0 then
                        consider = false
                        num_kept_unpromised = num_kept_unpromised + 1
                    end
                end
            end
        end

        -- Candidates by kind, the ones no technology took yet first
        local by_kind = {}
        for _, base_key in pairs(consider and option_bases or {}) do
            local option = graph.nodes[base_key].trigger_option
            if not research_triggers.matches(option, old_trigger) and (prom == nil or repair_only or could_back(base_key, head_key, contexts)) then
                by_kind[option.kind] = by_kind[option.kind] or {
                    fresh = {},
                    used = {},
                }
                if used[base_key] ~= nil then
                    table.insert(by_kind[option.kind].used, base_key)
                else
                    table.insert(by_kind[option.kind].fresh, base_key)
                end
            end
        end
        local function has_options(kind)
            local lists = by_kind[kind]
            return lists ~= nil and (#lists.fresh > 0 or #lists.used > 0)
        end

        local chosen
        local tries = 0
        while chosen == nil and tries < MAX_TRIES do
            local kind = research_triggers.pick_kind(weights, has_options, rng.value(key))
            if kind == nil then
                break
            end
            local lists = by_kind[kind]
            local list = #lists.fresh > 0 and lists.fresh or lists.used
            local base_key = table.remove(list, rng.int(key, #list))
            if repair_only then
                if prom.head_candidate_ok(head_key, base_key, contexts) and prom.head_pays(head_key, base_key, paying_contexts) then
                    tries = tries + 1
                    if rewire(head_key, base_key, true) then
                        chosen = base_key
                    end
                end
            elseif anchored then
                tries = tries + 1
                if prom.head_candidate_ok(head_key, base_key, contexts) then
                    prom.resolve_head(head_key, base_key, contexts)
                    chosen = base_key
                end
            else
                tries = tries + 1
                if rewire(head_key, base_key, true) then
                    chosen = base_key
                end
            end
        end
        num_tries = num_tries + tries
        if chosen == nil then
            -- The old trigger always works where it did
            chosen = head.old_base
            rewire(head_key, chosen, true)
            if consider then
                num_kept_nothing_fits = num_kept_nothing_fits + 1
                table.insert(kept, tech_name .. " (nothing fits)")
            elseif not repair_only then
                table.insert(kept, tech_name .. " (can't be had anywhere)")
            end
        else
            used[chosen] = true
            num_new = num_new + 1
            local kind = graph.nodes[chosen].trigger_option.kind
            kind_counts[kind] = (kind_counts[kind] or 0) + 1
        end
        head_to_base[head_key] = chosen
    end
    local kind_texts = {}
    for kind, count in pairs(kind_counts) do
        table.insert(kind_texts, kind .. " " .. count)
    end
    table.sort(kind_texts)
    log("Research triggers: " .. (num_up_front + num_new) .. " of " .. #heads .. " technologies got a new trigger (" .. table.concat(kind_texts, ", ") .. "), " .. num_up_front .. " chosen up front and " .. num_new .. " by promotion's search from " .. #option_bases .. " options in " .. num_tries .. " tries; kept their own: " .. num_kept_nothing_fits .. " with nothing that fits, " .. num_kept_unpromised .. " that can't be had anywhere" .. (repair_only and " (repairs only)" or ""))
    if #kept > 0 then
        log("Research triggers kept: " .. table.concat(kept, ", "))
    end
    return true
end

-- Also sets UNIFIED_TRIGGER_TAKERS: technology name --> sorted names of the technologies whose trigger is now its old one (empty if none kept it), for each technology whose trigger was a slot
-- A technology-trigger node is named after its technology, so in the model it's the old trigger, and the final game's node of a technology that kept it is the same; a new trigger's model is its base's own node (an item-craft node, say), which the checks compare as they do any other node
tech_triggers.reflect = function(graph, head_to_base, head_to_handler)
    UNIFIED_TRIGGER_TAKERS = {}
    local prices = (context_costs.current or {}).anywhere_costs or {}
    for head_key, base_key in pairs(head_to_base) do
        if head_to_handler[head_key].id == "tech_triggers" then
            local tech_name = gutils.get_owner(graph, graph.nodes[head_key]).name
            local tech = data.raw.technology[tech_name]
            local base = graph.nodes[base_key]
            UNIFIED_TRIGGER_TAKERS[tech_name] = UNIFIED_TRIGGER_TAKERS[tech_name] or {}
            if tech ~= nil then
                if base.trigger_option ~= nil then
                    tech.research_trigger = research_triggers.make(base.trigger_option, old_triggers[tech_name], prices, placers)
                    log("Research trigger: " .. tech_name .. ": " .. research_triggers.describe(old_triggers[tech_name]) .. " -> " .. research_triggers.describe(tech.research_trigger))
                else
                    local source = gutils.get_owner(graph, base).name
                    if old_triggers[source] ~= nil then
                        tech.research_trigger = table.deepcopy(old_triggers[source])
                        UNIFIED_TRIGGER_TAKERS[source] = UNIFIED_TRIGGER_TAKERS[source] or {}
                        table.insert(UNIFIED_TRIGGER_TAKERS[source], tech_name)
                    end
                end
            end
        end
    end
    for _, takers in pairs(UNIFIED_TRIGGER_TAKERS) do
        table.sort(takers)
    end
end

return tech_triggers

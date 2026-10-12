-- A copy of consistent-sort.lua that can optionally also track the ability contexts (isolatability/automatability) from extended-sort.lua
-- Kept as close to consistent-sort.lua as possible so that callers can be ported over by just swapping the require
-- Differences from consistent-sort.lua:
--   1. Pass extra.complex_contexts = true to make each context a room with an ability mask rather than just a room
--      Contexts are numbers (see src/logic/contexts/contexts.lua), a simple context standing for its room, so the rest of the sort treats them all alike
--   2. Contexts are now also transmitted through edges, since edges can add/remove abilities (edge.abilities)
--   3. Random selection from open is O(1) using a list of open keys, rather than rebuilding that list every step
--   4. Pass extra.home_contexts = true to also track home contexts (see Home contexts below), with or without complex contexts
--      Their home sets come from extra.home_sets if given (see top.home_sets), then logic.home_sets (the vanilla ones, stored by data-final-fixes.lua before randomization), and otherwise from the graph being sorted
-- Without complex contexts, this should behave exactly like consistent-sort.lua except for which random node is picked
-- I kept the pebble terminology: a *pebble* is a node_key/context pair

local ctx = require("src/logic/contexts/contexts")
local dutils = require("src/prototypes/data-utils")
local gutils = require("src/lib/graph/graph-utils")
local rng = require("src/lib/random/rng")
-- Used for contexts and such; actual logic dependency graph is passed in
local logic = require("src/logic/state")

-- Shortcuts
local key = gutils.key

-- Ability indices, matching edge.abilities (see src/logic/builders/builder.lua)
local ISOLATABILITY = ctx.ISOLATABILITY
local AUTOMATABILITY = ctx.AUTOMATABILITY
-- Edge abilities code --> mask + 1 --> the masks coming out of the edge, and those going in that make a mask come out (see contexts.forward_masks and contexts.inverse_masks)
local FORWARD_MASKS = ctx.FORWARD_MASKS
local INVERSE_MASKS = ctx.INVERSE_MASKS

local top = {}

top.ISOLATABILITY = ISOLATABILITY
-- Whether home contexts are kept to their home set's own rooms (see Home contexts above), rather than every room; false only to compare with how sorts used to be
top.home_contexts_in_set_rooms = true
-- Whether a smaller home set's home context stands for those of the home sets containing it in the same room (see Home contexts above), rather than each being passed on; false only to compare with how sorts used to be
top.implied_home_contexts = true
-- Whether home contexts are kept to research (see Home contexts above), with complex contexts; false only to compare with how sorts used to be
top.research_home_contexts = true
-- Whether an ability context stands for the weaker ones of its room that come with it or after it (see Ability contexts standing for weaker ones below), rather than each being recorded and passed on; false only to compare with how sorts used to be
top.implied_ability_contexts = true
-- Only for tests: when set, function(open, number of pebbles so far) --> the node key top.sort takes out of open next, in place of a random or earliest pick, so sorts with different switches can be compared step by step
top.choose_open = nil
top.AUTOMATABILITY = AUTOMATABILITY

-- Every ability mask, in the order sorts go through them (see src/logic/contexts/contexts.lua)
local masks = ctx.masks
top.ability_masks = masks
-- The weakest mask: no edge takes it away, so a node with any context in a room also has this one there
local NO_ABILITIES = ctx.NO_ABILITIES
top.NO_ABILITIES = NO_ABILITIES
-- The masks with isolatability, whose contexts give research home contexts (see top.research_home_contexts)
local ISOLATED_MASKS = {}
for _, mask in pairs(masks) do
    if ctx.has_ability(mask, ISOLATABILITY) then
        table.insert(ISOLATED_MASKS, mask)
    end
end
-- The strongest mask, which stands for every other (top.implied_ability_contexts)
local ALL_ABILITIES = ctx.ALL_ABILITIES

local has_ability = ctx.has_ability
local with_ability = ctx.with_ability
local without_ability = ctx.without_ability

-- For ability contexts standing for weaker ones (top.implied_ability_contexts): mask + 1 --> the masks with fewer abilities, the most abilities first, and the masks with more
local WEAKER_MASKS = {}
local STRONGER_MASKS = {}
for _, mask in pairs(masks) do
    WEAKER_MASKS[mask + 1] = {}
    STRONGER_MASKS[mask + 1] = {}
end
for _, mask in pairs(masks) do
    for _, other in pairs(masks) do
        if other ~= mask and ctx.mask_covers(mask, other) then
            table.insert(WEAKER_MASKS[mask + 1], other)
            table.insert(STRONGER_MASKS[other + 1], mask)
        end
    end
end
local function num_abilities(mask)
    local count = 0
    for ability = 1, ctx.NUM_ABILITIES do
        if has_ability(mask, ability) then
            count = count + 1
        end
    end
    return count
end
for _, mask in pairs(masks) do
    table.sort(WEAKER_MASKS[mask + 1], function(a, b)
        if num_abilities(a) ~= num_abilities(b) then
            return num_abilities(a) > num_abilities(b)
        end
        return a < b
    end)
end
-- Edge abilities code --> mask + 1 --> the one mask the edge makes of it, which stands for every mask FORWARD_MASKS gives from it and from its weaker masks
-- An edge gaining an ability adds it, and one losing an ability takes it away: FORWARD_MASKS drops a mask with an ability the edge loses, but the weaker mask without it comes through
local STRONGEST_FORWARD = {}
for code, _ in pairs(FORWARD_MASKS) do
    STRONGEST_FORWARD[code] = {}
    local gains = ctx.edge_gains(code)
    local loses = ctx.edge_loses(code)
    for _, mask in pairs(masks) do
        local result = mask
        for ability = 1, ctx.NUM_ABILITIES do
            -- Gaining wins over losing, as in FORWARD_MASKS
            if has_ability(gains, ability) then
                result = with_ability(result, ability)
            elseif has_ability(loses, ability) then
                result = without_ability(result, ability)
            end
        end
        STRONGEST_FORWARD[code][mask + 1] = result
    end
end
top.weaker_masks = function(mask)
    return WEAKER_MASKS[mask + 1]
end
top.strongest_forward = function(code, mask)
    return STRONGEST_FORWARD[code][mask + 1]
end

-- The rank of the weaker context with mask that the ind-th pebble stands for (top.implied_ability_contexts): between the pebble before it and this one, the weaker masks first
-- Exact in floating point, since NUM_MASKS is a power of two
local NUM_MASKS = ctx.NUM_MASKS
local function stood_for_rank(ind, mask)
    return ind - 1 + (mask + 1) / NUM_MASKS
end

-- The pebble lists of a sort with complex contexts give the node and context of a rank stood_for_rank made, as if they listed it
-- (Factorio doesn't save these metatables in storage, doc-html/auxiliary/storage.html, so a sort kept there gets them again when top.sort carries it on)
local function stood_for_ind(rank)
    if type(rank) ~= "number" then
        return nil
    end
    local below = math.floor(rank)
    if below == rank then
        return nil
    end
    return below + 1
end
local PEBBLE_KEYS_META = {
    __index = function(pebble_keys, rank)
        local ind = stood_for_ind(rank)
        return ind ~= nil and rawget(pebble_keys, ind) or nil
    end,
}
local PEBBLE_CONTEXTS_META = {
    __index = function(pebble_contexts, rank)
        local ind = stood_for_ind(rank)
        local own = ind ~= nil and rawget(pebble_contexts, ind) or nil
        if own == nil then
            return nil
        end
        return ctx.with_mask(own, math.floor((rank - ind + 1) * NUM_MASKS + 0.5) - 1)
    end,
}

-- How many node contexts a sort made by top.sort has, counting the contexts pebbles stand for (the pebble lists don't list them)
top.num_contexts = function(sort_info)
    local count = 0
    for _, inds in pairs(sort_info.node_to_context_inds) do
        for _, _ in pairs(inds) do
            count = count + 1
        end
    end
    return count
end

-- Every rank of a sort made by top.sort, in order, for going through each pebble's node and context (pebble_keys[rank] and pebble_contexts[rank]) as `for rank in top.each_rank(sort_info) do`
-- That's each pebble's index, after the ranks of the weaker contexts it stands for (top.implied_ability_contexts), which the pebble lists don't list
top.each_rank = function(sort_info)
    local pebble_keys = sort_info.pebble_keys
    local pebble_contexts = sort_info.pebble_contexts
    local node_to_context_inds = sort_info.node_to_context_inds
    local num_pebbles = #pebble_keys
    local ind = 0
    -- The current pebble's stood-for ranks, and how many of them are left before its own index
    local ranks = {}
    local num_ranks = 0
    local next_rank = 1
    return function()
        if next_rank <= num_ranks then
            next_rank = next_rank + 1
            return ranks[next_rank - 1]
        end
        if num_ranks > 0 then
            num_ranks = 0
            return ind
        end
        ind = ind + 1
        if ind > num_pebbles then
            return nil
        end
        local context = rawget(pebble_contexts, ind)
        local mask = ctx.mask(context)
        if mask == nil or ctx.home_of(context) ~= nil or mask == NO_ABILITIES then
            return ind
        end
        local inds = node_to_context_inds[rawget(pebble_keys, ind)]
        -- Weaker masks first, as their ranks go
        for weaker_mask = 0, mask - 1 do
            if ctx.mask_covers(mask, weaker_mask) then
                local rank = stood_for_rank(ind, weaker_mask)
                if inds[ctx.with_mask(context, weaker_mask)] == rank then
                    num_ranks = num_ranks + 1
                    ranks[num_ranks] = rank
                end
            end
        end
        if num_ranks == 0 then
            return ind
        end
        next_rank = 2
        return ranks[1]
    end
end

top.has_ability = has_ability
top.with_ability = with_ability
top.without_ability = without_ability
-- Whether a mask has every ability another has
top.mask_covers = ctx.mask_covers
-- How a mask is written in logs, like "10"
top.mask_name = ctx.mask_name
-- Whether edge abilities (an edge's or a connection's, or nil for none) gain or lose an ability
top.edge_changes = ctx.edge_changes

-- Context helpers (see src/logic/contexts/contexts.lua for how contexts are numbered)

-- Complex context of a room with an ability mask, or nil for a room that isn't a context
top.context_key = ctx.complex
-- Simple context of a room (a sort without complex contexts), or nil for a room that isn't a context
top.simple_context = ctx.simple

-- Home contexts
-- A home set is a set of rooms (see top.home_sets), and a pebble's home context for it means the pebble can be had using only those rooms
-- This is what removing every other room's node and sorting again would give, but for every home set in the same sort
-- Home contexts ride on each room's weakest context (the room's simple context for simple contexts, the room with no abilities for complex ones), and are named like "planet: vulcanus | 00 @ home1"
-- Only the home set's own rooms have its home contexts (with top.home_contexts_in_set_rooms): no other room's node sends them, so all another room could get is what forgetters send every room, and the set's rooms get that too
-- With complex contexts, they replace the order-dependent discovery rule: once a room is discovered, techs with a home context of its home set are isolatable there (see discover_home_rooms in top.sort)
-- What can be had using only a home set's rooms can be had using only the rooms of any home set containing it, so with top.implied_home_contexts a smaller home set's context stands for the bigger ones' in the same room: those aren't passed on, and looking for one counts the other
-- Discovery tiers make every home set hold the ones before it (src/randomizations/planetary/discovery.lua), so each pebble then needs only its earliest tier's home context instead of one per later tier (user, 2026-10-09)
-- Forgetters and rooms send the bigger ones' contexts to rooms the smaller one has none in, and the end of a sort writes out the ones that stood in, so what reads a sort finds every home context as before
-- Research home contexts (top.research_home_contexts, with complex contexts): only the discovery rule reads home contexts, and only techs', so beyond the core they're kept to research (user, 2026-10-09)
--   * The core is the rooms in every home set, like the start and its space platforms, which every discovery needs (the user's "tier 1.5": the platform comes between the start and the first planets, built from what the start ships up); its home set keeps full home contexts, which only take its few rooms
--   * What a tech's research needs (its packs' set, the labs for it, its trigger, and the launches a send-item-to-orbit trigger needs: node types the logic declares research_input) gets another home set's context from any prerequisite whose own pebble is isolatable in one of the set's rooms beyond the core, or is in the core's home context (every home set holds the core)
--   * In the core's rooms only the core's home context counts, not isolatability, which can rest on buildings or tiles brought in once from anywhere (a platform builds what it's sent); beyond the core that can happen too (bootstrap.lua's grants on planets), but only for buildings the planet then makes itself
--   * So each pack only has to be made on one of the set's planets from that planet's own resources, or from the core's, and the packs can come from different planets: shipping between the set's planets is taken to work, so an edge losing isolatability on the way (like a delivery's) doesn't stop it (every Space Age pack lasts longer than a trip, src/prototypes/data-utils.lua's survives_trip)
--   * Techs (home_carrier) pass those home contexts on to the techs after them, research inputs and relays (unified's slots, heads and such) carry them where they lead to a tech, and nothing else takes them; sources only give them to research
--   * A pack made from another of the set's planets' items (beyond the core's), or with a tech only the set's other planets research, doesn't count, though removing the other rooms and sorting again would count it; late techs needing several planets (biter eggs, biolabs) get none, which leaves them free to go anywhere (user, 2026-10-09)
--   * Each of those home sets has a single home context, riding on one room's weakest context (the room in the most home sets), since techs send them to every room anyway

-- Ability contexts standing for weaker ones (top.implied_ability_contexts, with complex contexts)
-- A node with a context in a room also has that room's contexts with fewer abilities, so "11" stands for "10", "01" and "00", and "10" or "01" for "00" (user, 2026-10-09: "01 should always imply 00")
-- So of a node's batch from open, only the strongest contexts of each room become pebbles in the pebble lists, and the weaker ones the node didn't have yet are neither listed nor sent to dependents
-- A weaker context coming in a batch before any stronger one keeps its own pebble and index, since ranks are read (wood on Nauvis is reachable early and automatable only later, user, 2026-10-09)
-- What's passed on stands for the rest too: an edge sends the one mask it makes of a pebble's (STRONGEST_FORWARD, so one losing an ability sends the context without it), a forgetter also sends an isolatable context's mask without isolatability to the other rooms, a room sends its strongest context, the discovery rule adds a tech's strongest isolatable context, and an AND node that doesn't get a mask checks the weaker ones
-- Each weaker context a pebble stands for still gets a rank of its own in node_to_context_inds, just below the pebble's index (stood_for_rank), which the pebble lists give its node and context for, as if it were listed
-- So what reads ranks is unchanged; only going through the pebble lists misses those contexts, so that goes through top.each_rank instead

-- The home context riding on a context (home sets are numbered, see top.home_sets)
top.home_context_key = ctx.home

-- The context a home context rides on, or the context itself if it isn't one
local without_home = ctx.without_home
top.context_without_home = without_home

top.context_room = ctx.room

-- Ability mask of a complex context, nil for simple ones
top.context_mask = ctx.mask

-- Home set number of a home context, or nil for other contexts
top.context_home = ctx.home_of

-- How a context is written in logs and on the panel, like "planet: nauvis | 11" (from lookup tables, see src/logic/contexts/contexts.lua)
top.context_name = ctx.name
top.home_name = ctx.home_name
-- Names of a list of contexts, for logs
top.context_names = ctx.names

-- Sorts a list of contexts by name, for logs (decisions order contexts by number)
local function by_name(a, b)
    return ctx.name(a) < ctx.name(b)
end
top.sort_by_name = function(list)
    table.sort(list, by_name)
end

-- Orders pebbles (tables with node_key and context) by node key, then context, for table.sort
top.pebble_order = function(a, b)
    if a.node_key ~= b.node_key then
        return a.node_key < b.node_key
    end
    return a.context < b.context
end

-- The context in the same room asking for automatability on top of what this one asks for, or nil for one that already does, a simple context or a home context
top.automatable_counterpart = function(context)
    local mask = ctx.mask(context)
    if mask == nil or ctx.home_of(context) ~= nil or has_ability(mask, AUTOMATABILITY) then
        return nil
    end
    return ctx.with_mask(context, with_ability(mask, AUTOMATABILITY))
end

-- Whether a node's contexts in a sort (context --> anything) provide a goal context: the context itself, or its isolatable counterpart when the goal isn't isolatable, since whatever can be had isolatably can be had without isolatability too (a sort records the contexts of its routes, so the weaker one needn't be there on its own)
-- Nothing else is implied: automatability must match, and home contexts and simple contexts are looked up unchanged
-- The checks of what randomization must keep compare goal contexts through this (src/randomizations/planetary/check.lua), like the mechanic context check's kept parts (skeleton/protection.lua)
top.provides_context = function(contexts, context)
    if contexts[context] ~= nil then
        return true
    end
    local mask = ctx.mask(context)
    if mask == nil or ctx.home_of(context) ~= nil or has_ability(mask, ISOLATABILITY) then
        return false
    end
    return contexts[ctx.with_mask(context, with_ability(mask, ISOLATABILITY))] ~= nil
end

-- Whether a node's contexts in a sort with complex contexts (context --> anything) include an isolatable one in a room: it can be had there from the room's own resources, without bringing anything in (src/logic/builders/builder.lua)
-- Home contexts and simple contexts never count
top.isolatable_in = function(contexts, room)
    if contexts == nil then
        return false
    end
    for _, mask in pairs(masks) do
        if has_ability(mask, ISOLATABILITY) then
            local context = ctx.complex(room, mask)
            if context ~= nil and contexts[context] ~= nil then
                return true
            end
        end
    end
    return false
end

-- Gets the lookup tables for the contexts used in a sort
-- For simple contexts, the contexts are just the rooms' simple contexts, like the rooms in consistent-sort.lua
-- home_sets (from top.home_sets) adds home contexts, or is nil for none, and research keeps them to research (top.research_home_contexts) with complex contexts
local function build_context_info(complex, home_sets, research)
    ctx.number_rooms(logic.contexts)
    local context_info = {
        complex = complex,
        -- Every context
        list = {},
        -- The rooms' simple contexts, in room order (simple contexts only)
        simple_list = {},
        -- context --> room (complex and home contexts only)
        room = {},
        -- context --> ability mask (complex contexts only)
        mask = {},
        -- room --> ability mask + 1 --> context (complex contexts only)
        of = {},
        -- context --> home set id (home contexts only)
        home = {},
        -- room --> home set id --> context (home contexts only)
        home_of = {},
        -- home set id --> room --> true for the rooms in it (home contexts only)
        home_rooms = {},
        -- home set id --> the other home sets containing it, and those inside it (home contexts only, see top.implied_home_contexts)
        home_supersets = {},
        home_subsets = {},
        -- home set id --> how many rooms it has (home contexts only)
        home_size = {},
        -- Whether home contexts are kept to research (see top.research_home_contexts)
        research_homes = complex and home_sets ~= nil and research == true,
        -- With research home contexts: the core's home set id (the rooms in every home set, with full home contexts), and home set id --> true for it
        core_id = nil,
        home_full = {},
        -- room --> the research home contexts of the home sets holding it, which its isolatable contexts give research
        room_home_contexts = {},
        -- The research home contexts the core's home contexts give research (every home set holds the core)
        core_research_contexts = {},
        -- Home set id --> the contexts a prerequisite's pebble gives research its research home context from: the isolatable ones of its rooms beyond the core, and the core's home contexts
        research_sources = {},
    }
    -- The home sets, plus a core of its own (numbered after them) when no home set is just the rooms in all of them
    local ids = {}
    local sets = {}
    if home_sets ~= nil then
        for _, home_id in pairs(home_sets.ids) do
            table.insert(ids, home_id)
            sets[home_id] = home_sets.sets[home_id].rooms
        end
    end
    local carrier
    if context_info.research_homes then
        local core_rooms
        local last_id = 0
        for _, home_id in pairs(ids) do
            last_id = math.max(last_id, home_id)
            if core_rooms == nil then
                core_rooms = {}
                for room, _ in pairs(sets[home_id]) do
                    core_rooms[room] = true
                end
            else
                for room, _ in pairs(core_rooms) do
                    if sets[home_id][room] == nil then
                        core_rooms[room] = nil
                    end
                end
            end
        end
        if core_rooms ~= nil and next(core_rooms) ~= nil then
            for _, home_id in pairs(ids) do
                local same = true
                for room, _ in pairs(sets[home_id]) do
                    if core_rooms[room] == nil then
                        same = false
                        break
                    end
                end
                if same then
                    context_info.core_id = home_id
                    break
                end
            end
            if context_info.core_id == nil then
                context_info.core_id = last_id + 1
                table.insert(ids, context_info.core_id)
                sets[context_info.core_id] = core_rooms
            end
            context_info.home_full[context_info.core_id] = true
        end
        -- The other home sets' contexts all ride on one room: the one in the most home sets, the first by key of those
        local rooms = {}
        for room, _ in pairs(logic.contexts) do
            table.insert(rooms, room)
        end
        table.sort(rooms)
        local most
        for _, room in pairs(rooms) do
            local count = 0
            for _, home_id in pairs(ids) do
                if sets[home_id][room] ~= nil then
                    count = count + 1
                end
            end
            if most == nil or count > most then
                carrier = room
                most = count
            end
        end
    end
    for room, _ in pairs(logic.contexts) do
        if complex then
            context_info.of[room] = {}
            for _, mask in pairs(masks) do
                local context = ctx.complex(room, mask)
                table.insert(context_info.list, context)
                context_info.room[context] = room
                context_info.mask[context] = mask
                context_info.of[room][mask + 1] = context
            end
        else
            table.insert(context_info.list, ctx.simple(room))
            table.insert(context_info.simple_list, ctx.simple(room))
        end
        if home_sets ~= nil then
            -- Home contexts ride on the room's weakest context
            local base = ctx.simple(room)
            if complex then
                base = context_info.of[room][NO_ABILITIES + 1]
            end
            context_info.home_of[room] = {}
            for _, home_id in pairs(ids) do
                -- A home set with no rooms at all keeps its home contexts everywhere, so what needs no room still gets one
                local set_rooms = sets[home_id]
                local keeps
                if context_info.research_homes and context_info.home_full[home_id] == nil then
                    keeps = room == carrier
                else
                    keeps = not top.home_contexts_in_set_rooms or set_rooms[room] ~= nil or next(set_rooms) == nil
                end
                if keeps then
                    local context = ctx.home(base, home_id)
                    table.insert(context_info.list, context)
                    context_info.room[context] = room
                    if complex then
                        context_info.mask[context] = NO_ABILITIES
                    end
                    context_info.home[context] = home_id
                    context_info.home_of[room][home_id] = context
                end
            end
        end
    end
    if home_sets ~= nil then
        for _, home_id in pairs(ids) do
            context_info.home_rooms[home_id] = sets[home_id]
            local count = 0
            for _, _ in pairs(sets[home_id]) do
                count = count + 1
            end
            context_info.home_size[home_id] = count
        end
        if context_info.research_homes then
            -- The core's home contexts, one per room of it
            local core_contexts = {}
            local core_rooms = {}
            if context_info.core_id ~= nil then
                core_rooms = sets[context_info.core_id]
                local core_list = {}
                for room, _ in pairs(sets[context_info.core_id]) do
                    if context_info.of[room] ~= nil then
                        table.insert(core_list, room)
                    end
                end
                table.sort(core_list)
                for _, room in pairs(core_list) do
                    table.insert(core_contexts, context_info.home_of[room][context_info.core_id])
                end
            end
            for _, home_id in pairs(ids) do
                if context_info.home_full[home_id] == nil then
                    local list = {}
                    for room, _ in pairs(sets[home_id]) do
                        if context_info.of[room] ~= nil then
                            table.insert(list, room)
                        end
                    end
                    table.sort(list)
                    local context = context_info.home_of[carrier][home_id]
                    local sources = {}
                    for _, room in pairs(list) do
                        -- A core room's isolatable pebbles don't count: isolatability can rest on buildings or tiles brought in once from anywhere (like a platform's, see entity-own-space and tile-build-space in src/logic/builders/concrete.lua), and what the core makes alone has the core's home context
                        if core_rooms[room] == nil then
                            context_info.room_home_contexts[room] = context_info.room_home_contexts[room] or {}
                            table.insert(context_info.room_home_contexts[room], context)
                            for _, mask in pairs(ISOLATED_MASKS) do
                                table.insert(sources, context_info.of[room][mask + 1])
                            end
                        end
                    end
                    for _, core_context in pairs(core_contexts) do
                        table.insert(sources, core_context)
                    end
                    context_info.research_sources[home_id] = sources
                    table.insert(context_info.core_research_contexts, context)
                end
            end
            -- From the smallest home set up, so that what a smaller one stands for is there first (top.implied_home_contexts)
            local function by_size(a, b)
                local a_id = context_info.home[a]
                local b_id = context_info.home[b]
                if context_info.home_size[a_id] ~= context_info.home_size[b_id] then
                    return context_info.home_size[a_id] < context_info.home_size[b_id]
                end
                return a_id < b_id
            end
            for _, home_contexts in pairs(context_info.room_home_contexts) do
                table.sort(home_contexts, by_size)
            end
            table.sort(context_info.core_research_contexts, by_size)
        end
        -- A home set stands for the contexts of those containing it, and those inside it stand for its own (top.implied_home_contexts)
        -- Only between home sets of the same kind: the core's contexts are everywhere and the others' only on research, which the core's give through research's edges instead (see edge_transmit)
        for _, home_id in pairs(ids) do
            context_info.home_supersets[home_id] = {}
            context_info.home_subsets[home_id] = {}
        end
        if top.implied_home_contexts then
            for _, inner_id in pairs(ids) do
                for _, outer_id in pairs(ids) do
                    if inner_id ~= outer_id and context_info.home_full[inner_id] == context_info.home_full[outer_id] then
                        local inside = true
                        for room, _ in pairs(context_info.home_rooms[inner_id]) do
                            if context_info.home_rooms[outer_id][room] == nil then
                                inside = false
                                break
                            end
                        end
                        if inside then
                            table.insert(context_info.home_supersets[inner_id], outer_id)
                            table.insert(context_info.home_subsets[outer_id], inner_id)
                        end
                    end
                end
            end
            -- From the smallest containing home set up, which is the order process_depnode in top.sort tries them in
            for _, home_id in pairs(ids) do
                table.sort(context_info.home_supersets[home_id], function(a, b)
                    if context_info.home_size[a] ~= context_info.home_size[b] then
                        return context_info.home_size[a] < context_info.home_size[b]
                    end
                    return a < b
                end)
            end
        end
    end
    return context_info
end

-- The earliest index of a home context among a node's pebbles, counting those of the home sets inside it in the same room, which stand for it (top.implied_home_contexts), or nil if none
local function implied_ind(context_info, inds, context)
    local earliest = inds[context]
    local subsets = context_info.home_subsets[context_info.home[context]]
    if subsets ~= nil and subsets[1] ~= nil then
        local room_homes = context_info.home_of[context_info.room[context]]
        for _, subset_id in pairs(subsets) do
            local subset_context = room_homes[subset_id]
            local ind = subset_context ~= nil and inds[subset_context] or nil
            if ind ~= nil and (earliest == nil or ind < earliest) then
                earliest = ind
            end
        end
    end
    return earliest
end

-- An empty table for defaults that are only read, so a missing list doesn't make a new table each time (writing to it is an error)
local EMPTY = setmetatable({}, {
    __newindex = function()
        error("EMPTY is read-only")
    end,
})

-- The lists the transmit functions below give, kept by one sort (top.sort) so each is built once rather than at every arrival; the sort only reads them
-- Each function keeps its own, since they give different lists for the same context
local function new_transmit_cache()
    return {
        -- context --> { context }
        just = {},
        -- strongest_transmit: context --> what a forgetter sends, and room --> what a room sends
        strongest_forget = {},
        strongest_room = {},
        -- node_transmit with complex contexts: ability mask --> what a forgetter sends, and room --> what a room sends
        forget_mask = {},
        room_all = {},
        -- node_transmit with simple contexts: what a forgetter sends, and room --> what a room sends
        simple_forget = nil,
        simple_room = {},
        -- home_transmit: home set id --> what a forgetter sends, and room --> home set id --> what a room sends
        home_forget = {},
        home_room = {},
    }
end

-- { incoming }, kept in cache (from new_transmit_cache) when there is one
local function just_incoming(incoming, cache)
    if cache == nil then
        return { incoming }
    end
    local list = cache.just[incoming]
    if list == nil then
        list = { incoming }
        cache.just[incoming] = list
    end
    return list
end

-- The contexts of the smallest home sets containing home_id that a room's home contexts (room --> home set id --> context) have, for a room without home_id's, or nil for none
-- member_room, when given, has to be in those home sets too (a room's own node only sends the home sets holding it)
local function smallest_containing(context_info, room_homes, home_id, member_room)
    local candidates = {}
    for _, superset_id in pairs(context_info.home_supersets[home_id] or EMPTY) do
        if room_homes[superset_id] ~= nil and (member_room == nil or context_info.home_rooms[superset_id][member_room] ~= nil) then
            candidates[superset_id] = true
        end
    end
    local contexts
    for superset_id, _ in pairs(candidates) do
        -- Not one containing another candidate; of home sets with the same rooms, the first by id
        local smallest = true
        for _, inner_id in pairs(context_info.home_subsets[superset_id]) do
            if candidates[inner_id] ~= nil and (context_info.home_size[inner_id] < context_info.home_size[superset_id] or inner_id < superset_id) then
                smallest = false
                break
            end
        end
        if smallest then
            contexts = contexts or {}
            table.insert(contexts, room_homes[superset_id])
        end
    end
    return contexts
end

-- Whether a node is a research input (see top.research_home_contexts), found from the node type in its key and memoized per type info table
-- Callers reasoning about backings pass stand-ins for edges with no stop, like promotion's chosen bases, which never end at research
local research_input_of = {}
local research_input_info
local function is_research_input(node_key)
    if node_key == nil then
        return false
    end
    if research_input_info ~= logic.type_info then
        research_input_of = {}
        research_input_info = logic.type_info
    end
    local known = research_input_of[node_key]
    if known == nil then
        local info = logic.type_info[gutils.deconstruct(node_key).type]
        known = info ~= nil and info.research_input == true
        research_input_of[node_key] = known
    end
    return known
end

-- The research home contexts a research input gets from a prerequisite's pebble in context (see top.research_home_contexts), or nil
-- An isolatable pebble gives those of the home sets holding its room (none in the core's rooms), and a pebble in the core's home context gives every one
-- The pebble's own context counts, not what arrives through the edge, since shipping is taken to work
-- From the smallest home set up, so that what a smaller one stands for is there first (top.implied_home_contexts)
local function research_home_contexts(context_info, context)
    local home_id = context_info.home[context]
    if home_id ~= nil then
        if context_info.home_full[home_id] ~= nil then
            return context_info.core_research_contexts
        end
        return nil
    end
    local mask = context_info.mask[context]
    if mask == nil or not has_ability(mask, ISOLATABILITY) then
        return nil
    end
    return context_info.room_home_contexts[context_info.room[context]]
end

-- Whether a context is a research home context (see top.research_home_contexts): one only research has, rather than the core's, which are everywhere
local function is_research_home(context_info, context)
    local home_id = context_info.home[context]
    return home_id ~= nil and context_info.research_homes and context_info.home_full[home_id] == nil
end

-- Contexts arriving at edge.stop when context leaves edge.start
-- Home contexts go through edges unchanged: they have no abilities to lose, and abilities an edge adds come from the context they ride on
-- An isolatable context beyond the core's rooms, or a core home context, leaving for a research input brings research home contexts along (top.research_home_contexts)
local function edge_transmit(context_info, edge, context)
    local arriving
    if not context_info.complex or edge.abilities == nil or context_info.home[context] ~= nil then
        arriving = { context }
    else
        local room_contexts = context_info.of[context_info.room[context]]
        arriving = {}
        for _, mask in pairs(FORWARD_MASKS[edge.abilities][context_info.mask[context] + 1]) do
            table.insert(arriving, room_contexts[mask + 1])
        end
    end
    if context_info.research_homes and is_research_input(edge.stop) then
        for _, home_context in pairs(research_home_contexts(context_info, context) or {}) do
            table.insert(arriving, home_context)
        end
    end
    return arriving
end

-- Contexts leaving edge.start that would make context arrive at edge.stop
-- For a research home context at a research input, that's also every isolatable context in one of its home set's rooms, and the core's home contexts (top.research_home_contexts)
local function edge_sources(context_info, edge, context)
    if context_info.research_homes and is_research_home(context_info, context) and is_research_input(edge.stop) then
        local sources = { context }
        for _, source in pairs(context_info.research_sources[context_info.home[context]]) do
            table.insert(sources, source)
        end
        return sources
    end
    if not context_info.complex or edge.abilities == nil or context_info.home[context] ~= nil then
        return { context }
    end
    local room_contexts = context_info.of[context_info.room[context]]
    local sources = {}
    for _, mask in pairs(INVERSE_MASKS[edge.abilities][context_info.mask[context] + 1]) do
        table.insert(sources, room_contexts[mask + 1])
    end
    return sources
end

-- Earliest index in the pebble lists of a pebble on edge.start that gets context to edge.stop, or nil if none
local function edge_ind(context_info, node_to_context_inds, edge, context)
    local start_inds = node_to_context_inds[edge.start]
    local home_id = context_info.home[context]
    if home_id ~= nil then
        local earliest_ind = implied_ind(context_info, start_inds, context)
        -- A research home context also comes from the prerequisite's isolatable pebbles in its home set's rooms and its core pebbles (top.research_home_contexts)
        if context_info.research_homes and context_info.home_full[home_id] == nil and is_research_input(edge.stop) then
            for _, source in pairs(context_info.research_sources[home_id]) do
                local ind = start_inds[source]
                if ind ~= nil and (earliest_ind == nil or ind < earliest_ind) then
                    earliest_ind = ind
                end
            end
        end
        return earliest_ind
    end
    if not context_info.complex or edge.abilities == nil then
        return start_inds[context]
    end
    -- The same sources as edge_sources, without building the list
    local room_contexts = context_info.of[context_info.room[context]]
    local earliest_ind
    for _, mask in pairs(INVERSE_MASKS[edge.abilities][context_info.mask[context] + 1]) do
        local ind = start_inds[room_contexts[mask + 1]]
        if ind ~= nil and (earliest_ind == nil or ind < earliest_ind) then
            earliest_ind = ind
        end
    end
    return earliest_ind
end

-- Whether a pebble on edge.start gets context to edge.stop (edge_ind ~= nil), for callers that don't need the index: it stops at the first source found
local function edge_sends(context_info, node_to_context_inds, edge, context)
    local start_inds = node_to_context_inds[edge.start]
    local home_id = context_info.home[context]
    if home_id ~= nil then
        if implied_ind(context_info, start_inds, context) ~= nil then
            return true
        end
        if context_info.research_homes and context_info.home_full[home_id] == nil and is_research_input(edge.stop) then
            for _, source in pairs(context_info.research_sources[home_id]) do
                if start_inds[source] ~= nil then
                    return true
                end
            end
        end
        return false
    end
    if not context_info.complex or edge.abilities == nil then
        return start_inds[context] ~= nil
    end
    local room_contexts = context_info.of[context_info.room[context]]
    for _, mask in pairs(INVERSE_MASKS[edge.abilities][context_info.mask[context] + 1]) do
        if start_inds[room_contexts[mask + 1]] ~= nil then
            return true
        end
    end
    return false
end

-- The home contexts a room node sends when a home context of home_id arrives at it (see home_transmit)
local function home_room_transmit(context_info, node, home_id)
    -- Rooms aren't research, so they don't carry research home contexts (top.research_home_contexts)
    if context_info.research_homes and context_info.home_full[home_id] == nil then
        return {}
    end
    -- Rooms use node.name for the room (type_info names one room for every room node)
    local room_contexts = context_info.home_of[node.name]
    if room_contexts == nil then
        error("Room node " .. node.name .. " is not a context")
    end
    if context_info.home_rooms[home_id][node.name] ~= nil then
        return { room_contexts[home_id] }
    end
    -- The room can still be in home sets containing this one, which it stands for (top.implied_home_contexts)
    return smallest_containing(context_info, room_contexts, home_id, node.name) or {}
end

-- Contexts leaving node when a home context arrives at it
-- Home contexts go through nodes like the contexts they ride on, except that a room only sends them for the home sets containing it
-- A pebble has a home context exactly when it can be had using only the rooms in that home set
-- With a cache from new_transmit_cache, each list is built once for the sort asking and kept there
local function home_transmit(context_info, node, incoming, home_id, cache)
    local context_type = logic.type_info[node.type].context
    if context_type == nil then
        return just_incoming(incoming, cache)
    elseif context_type == true then
        local outgoing = cache ~= nil and cache.home_forget[home_id] or nil
        if outgoing ~= nil then
            return outgoing
        end
        -- Home sets aren't tied to a room, so forgetters send them to every room that has them (like automatability)
        -- A room without them gets those of the smallest home sets containing it that it has, which this one stands for elsewhere (top.implied_home_contexts)
        outgoing = {}
        for _, room_homes in pairs(context_info.home_of) do
            if room_homes[home_id] ~= nil then
                table.insert(outgoing, room_homes[home_id])
            else
                for _, context in pairs(smallest_containing(context_info, room_homes, home_id) or EMPTY) do
                    table.insert(outgoing, context)
                end
            end
        end
        if cache ~= nil then
            cache.home_forget[home_id] = outgoing
        end
        return outgoing
    elseif type(context_type) == "string" then
        if cache == nil then
            return home_room_transmit(context_info, node, home_id)
        end
        local by_home = cache.home_room[node.name]
        if by_home == nil then
            by_home = {}
            cache.home_room[node.name] = by_home
        end
        local outgoing = by_home[home_id]
        if outgoing == nil then
            outgoing = home_room_transmit(context_info, node, home_id)
            by_home[home_id] = outgoing
        end
        return outgoing
    else
        -- Unhandled
        error()
    end
end

-- Contexts leaving node when incoming arrives at it
-- For simple contexts, as consistent-sort.lua's contutils.transmit does with rooms: forgetters send every room's simple context, and a room sends its own
-- For complex contexts this follows extended-sort.lua's transmit_through_node
-- With a cache from new_transmit_cache, each list is built once for the sort asking and kept there
local function node_transmit(context_info, node, incoming, cache)
    local home_id = context_info.home[incoming]
    if home_id ~= nil then
        return home_transmit(context_info, node, incoming, home_id, cache)
    end
    local context_type = logic.type_info[node.type].context
    if not context_info.complex then
        if context_type == nil then
            return just_incoming(incoming, cache)
        elseif context_type == true then
            if cache ~= nil and cache.simple_forget ~= nil then
                return cache.simple_forget
            end
            local outgoing = {}
            for _, context in pairs(context_info.simple_list) do
                table.insert(outgoing, context)
            end
            if cache ~= nil then
                cache.simple_forget = outgoing
            end
            return outgoing
        elseif type(context_type) == "string" then
            -- Rooms use node.name for the room (type_info names one room for every room node)
            -- A room the logic doesn't list still gets a context, as the room's own name did when contexts were names
            if ctx.simple(node.name) == nil then
                ctx.number_rooms({ [node.name] = true })
            end
            local outgoing = cache ~= nil and cache.simple_room[node.name] or nil
            if outgoing == nil then
                outgoing = { ctx.simple(node.name) }
                if cache ~= nil then
                    cache.simple_room[node.name] = outgoing
                end
            end
            return outgoing
        else
            -- Unhandled
            error()
        end
    end

    local mask = context_info.mask[incoming]
    if context_type == nil then
        return just_incoming(incoming, cache)
    elseif context_type == true then
        -- Forgetters forget the room, but isolatability is tied to the room so it isn't shared with other rooms
        if has_ability(mask, ISOLATABILITY) then
            return just_incoming(incoming, cache)
        end
        local outgoing = cache ~= nil and cache.forget_mask[mask] or nil
        if outgoing == nil then
            outgoing = {}
            for _, room_contexts in pairs(context_info.of) do
                table.insert(outgoing, room_contexts[mask + 1])
            end
            if cache ~= nil then
                cache.forget_mask[mask] = outgoing
            end
        end
        return outgoing
    elseif type(context_type) == "string" then
        -- Rooms use node.name for the room (type_info names one room for every room node)
        -- Like extended-sort.lua, rooms emit every ability mask no matter what came in
        local room_contexts = context_info.of[node.name]
        if room_contexts == nil then
            error("Room node " .. node.name .. " is not a context")
        end
        local outgoing = cache ~= nil and cache.room_all[node.name] or nil
        if outgoing == nil then
            outgoing = {}
            for _, room_mask in pairs(masks) do
                table.insert(outgoing, room_contexts[room_mask + 1])
            end
            if cache ~= nil then
                cache.room_all[node.name] = outgoing
            end
        end
        return outgoing
    else
        -- Unhandled
        error()
    end
end

-- The strongest of the contexts node_transmit gives when incoming and the contexts it stands for arrive at a forgetter or a room, which stand for the rest (top.implied_ability_contexts)
-- Only for complex contexts that aren't home contexts
-- A forgetter keeps an isolatable context in its room and sends the mask without isolatability to the other rooms, and a room sends its strongest context
-- With a cache from new_transmit_cache, each list is built once for the sort asking and kept there
local function strongest_transmit(context_info, node, incoming, cache)
    local context_type = logic.type_info[node.type].context
    local mask = context_info.mask[incoming]
    if context_type == true then
        local outgoing = cache ~= nil and cache.strongest_forget[incoming] or nil
        if outgoing ~= nil then
            return outgoing
        end
        outgoing = {}
        if has_ability(mask, ISOLATABILITY) then
            table.insert(outgoing, incoming)
            local room = context_info.room[incoming]
            local shared = without_ability(mask, ISOLATABILITY)
            for other_room, room_contexts in pairs(context_info.of) do
                if other_room ~= room then
                    table.insert(outgoing, room_contexts[shared + 1])
                end
            end
        else
            for _, room_contexts in pairs(context_info.of) do
                table.insert(outgoing, room_contexts[mask + 1])
            end
        end
        if cache ~= nil then
            cache.strongest_forget[incoming] = outgoing
        end
        return outgoing
    elseif type(context_type) == "string" then
        local room_contexts = context_info.of[node.name]
        if room_contexts == nil then
            error("Room node " .. node.name .. " is not a context")
        end
        local outgoing = cache ~= nil and cache.strongest_room[node.name] or nil
        if outgoing == nil then
            outgoing = { room_contexts[ALL_ABILITIES + 1] }
            if cache ~= nil then
                cache.strongest_room[node.name] = outgoing
            end
        end
        return outgoing
    end
    return just_incoming(incoming, cache)
end

-- Rooms (as context keys) whose space locations this tech unlocks
-- Nodes that discover rooms for the isolatability discovery rule (see discover_space_locations and discover_home_rooms in top.sort)
-- Techs discover the space locations they unlock, and a spaceship discovers space platforms (the platform's techs count from when it can fly, not from when platforms are unlocked)
top.is_discoverer = function(node)
    return node.type == "technology" or node.type == "spaceship"
end

-- Rooms a discoverer node discovers, as { location, room }, where location identifies the discovery (so it only happens once)
top.discovered_rooms = function(tech_node)
    local rooms = {}
    if tech_node.type == "spaceship" then
        for room, _ in pairs(logic.contexts) do
            if gutils.deconstruct(room).type == "surface" then
                table.insert(rooms, {
                    location = room,
                    room = room,
                })
            end
        end
        return rooms
    end
    if tech_node.type ~= "technology" then
        return rooms
    end
    -- Control stage (the explorer's complex sorts) reads the runtime prototypes, which have the same effect fields
    local tech_prot
    if data ~= nil then
        tech_prot = data.raw.technology[tech_node.name]
    else
        tech_prot = prototypes.technology[tech_node.name]
    end
    if tech_prot == nil or tech_prot.effects == nil then
        return rooms
    end
    for _, effect in pairs(tech_prot.effects) do
        if effect.type == "unlock-space-location" then
            local loc_prot
            if data ~= nil then
                loc_prot = dutils.get_prot("space-location", effect.space_location)
            else
                loc_prot = prototypes.space_location[effect.space_location]
            end
            table.insert(rooms, {
                location = effect.space_location,
                room = key(loc_prot.type, loc_prot.name),
            })
        end
    end
    return rooms
end

-- Room --> node keys of the room's discoverers in the graph
top.room_discoverers = function(graph)
    local room_discoverers = {}
    for node_key, node in pairs(graph.nodes) do
        if top.is_discoverer(node) then
            for _, discovered in pairs(top.discovered_rooms(node)) do
                room_discoverers[discovered.room] = room_discoverers[discovered.room] or {}
                table.insert(room_discoverers[discovered.room], node_key)
            end
        end
    end
    return room_discoverers
end

-- The discovery rule for callers that reason about backings (like promotion), so that it lives only in this file
-- A tech pebble in an isolatable context can come from the rule, backed by an earlier pebble of the tech itself and an earlier pebble of a discoverer of the context's room
-- Returns the ranks of those candidates as { own = sorted list, discoverers = sorted list }, or nil if the rule can't give the pebble
-- With home contexts, the tech's own pebble has to be in a home context of the room's home set (see discover_home_rooms in top.sort); without them, any of its pebbles counts (see discover_space_locations)
-- room_discoverers comes from top.room_discoverers
top.discovery_candidates = function(sort_info, room_discoverers, tech_node, context)
    if sort_info.complex ~= true or tech_node.type ~= "technology" or top.context_home(context) ~= nil then
        return nil
    end
    local mask = ctx.mask(context)
    if mask == nil or not has_ability(mask, ISOLATABILITY) then
        return nil
    end
    local room = ctx.room(context)
    local home_id
    if sort_info.home_sets ~= nil then
        home_id = sort_info.home_sets.of[room]
        if home_id == nil then
            return nil
        end
    end
    local nci = sort_info.node_to_context_inds
    local own = {}
    for own_context, ind in pairs(nci[key(tech_node)] or {}) do
        if home_id == nil or top.context_home(own_context) == home_id then
            table.insert(own, ind)
        end
    end
    local discoverers = {}
    for _, discoverer_key in pairs(room_discoverers[room] or {}) do
        for _, ind in pairs(nci[discoverer_key] or {}) do
            table.insert(discoverers, ind)
        end
    end
    table.sort(own)
    table.sort(discoverers)
    return {
        own = own,
        discoverers = discoverers,
    }
end

-- Rooms needed: for every pebble of a sort without complex contexts, the rooms it can't be reached without, all found in one pass rather than a sort per room
-- They follow the sort's own rules, where a room's node is the only way to use that room:
--   * Sources need no rooms, and a room's node needs its own room on top of what satisfied it
--   * An incoming context satisfies an OR node needing what all its satisfying prerequisites need in common, and an AND node needing what any of its prerequisites needs
--   * Forgetters and rooms send the same contexts whichever incoming context satisfied them, so they need what all those incoming contexts need in common
-- Starting every pebble at all rooms and shrinking until nothing changes gives exactly the rooms each pebble can't be reached without
-- (The true answer follows these rules, and by induction along a sort without the room, any answer that follows them is contained in it; so it's the largest one, which is where shrinking ends up)
-- Sets of rooms are strings with a "0" or "1" per room, like ability strings, so that they're cheap to compare and memoize
-- Given watched (a list of node keys), those nodes go in the sets as if they were rooms: each needs itself on top of what satisfied it, so the sets also say which of them a pebble can't be reached without
-- sort_info is a sort of graph without complex contexts, made here if not given
local function compute_rooms_needed(graph, watched, sort_info)
    sort_info = sort_info or top.sort(graph)

    -- Rooms in a fixed order, then the watched nodes, so that sets of them can be strings
    local rooms = {}
    for room, _ in pairs(logic.contexts) do
        table.insert(rooms, room)
    end
    table.sort(rooms)
    -- The contexts a pebble can have are the rooms' simple contexts, as a set
    local context_set = {}
    for _, room in pairs(rooms) do
        context_set[ctx.simple(room)] = true
    end
    local watched_keys = {}
    for _, node_key in pairs(watched or {}) do
        table.insert(watched_keys, node_key)
    end
    table.sort(watched_keys)
    for _, node_key in pairs(watched_keys) do
        table.insert(rooms, node_key)
    end
    local room_ind = {}
    for i = 1, #rooms do
        room_ind[rooms[i]] = i
    end
    local is_watched = {}
    for _, node_key in pairs(watched_keys) do
        is_watched[node_key] = true
    end
    local all_rooms = string.rep("1", #rooms)
    local no_rooms = string.rep("0", #rooms)

    -- Memoized, since there are only a few distinct sets
    local memos = {
        intersection = {},
        union = {},
    }
    local function combine(op, set1, set2)
        if set1 == set2 then
            return set1
        end
        local memo = memos[op]
        memo[set1] = memo[set1] or {}
        local result = memo[set1][set2]
        if result == nil then
            local chars = {}
            for i = 1, #rooms do
                local in_set1 = string.sub(set1, i, i) == "1"
                local in_set2 = string.sub(set2, i, i) == "1"
                if (op == "intersection" and in_set1 and in_set2) or (op == "union" and (in_set1 or in_set2)) then
                    chars[i] = "1"
                else
                    chars[i] = "0"
                end
            end
            result = table.concat(chars)
            memo[set1][set2] = result
        end
        return result
    end
    -- nil stands for no set yet, so that this can fold over alternatives
    local function intersect(set1, set2)
        if set1 == nil then
            return set2
        end
        return combine("intersection", set1, set2)
    end
    local function with_room(set, room)
        local i = room_ind[room]
        return combine("union", set, string.rep("0", i - 1) .. "1" .. string.rep("0", #rooms - i))
    end

    -- node_key --> context --> rooms needed, for every pebble the sort reached
    -- Pebbles start at all rooms (sources at their final sets), so a prerequisite pebble has a set exactly when the sort reached it
    local needed = {}
    for node_key, inds in pairs(sort_info.node_to_context_inds) do
        if next(inds) ~= nil then
            local node = graph.nodes[node_key]
            local start_set = all_rooms
            if gutils.is_source(graph, node) then
                start_set = no_rooms
                if type(logic.type_info[node.type].context) == "string" then
                    start_set = with_room(no_rooms, node.name)
                end
                if is_watched[node_key] then
                    start_set = with_room(start_set, node_key)
                end
            end
            needed[node_key] = {}
            for context, _ in pairs(inds) do
                needed[node_key][context] = start_set
            end
        end
    end

    -- Node key --> the sets in needed of its prerequisites the sort reached, found once rather than through the edges on every update, or false for an AND node with one it never reached (never satisfied)
    local pre_needed_of = {}
    local function pre_needed_tables(node_key, node)
        local tables = pre_needed_of[node_key]
        if tables == nil then
            tables = {}
            for pre, _ in pairs(node.pre) do
                local pre_needed = needed[graph.edges[pre].start]
                if pre_needed ~= nil then
                    table.insert(tables, pre_needed)
                elseif node.op == "AND" then
                    tables = false
                    break
                end
            end
            pre_needed_of[node_key] = tables
        end
        return tables
    end

    -- Recomputes a node's sets from its prerequisites' sets, and returns whether any shrank
    local function update(node_key)
        local node = graph.nodes[node_key]
        local node_needed = needed[node_key]
        if node_needed == nil or gutils.is_source(graph, node) then
            return false
        end

        -- Rooms needed by each incoming context that satisfies the node (edges don't change simple contexts)
        -- A node that keeps its context is satisfied in just the contexts the sort gave it, so only those are looked at; forgetters and rooms take any context in
        local context_type = logic.type_info[node.type].context
        local pre_tables = pre_needed_tables(node_key, node)
        local is_or = node.op == "OR"
        local incoming = {}
        for context, _ in pairs(pre_tables and (context_type == nil and node_needed or context_set) or {}) do
            local set
            local is_satisfied = not is_or
            for i = 1, #pre_tables do
                local pre_set = pre_tables[i][context]
                if is_or then
                    if pre_set ~= nil then
                        is_satisfied = true
                        set = intersect(set, pre_set)
                    end
                elseif pre_set == nil then
                    is_satisfied = false
                    break
                else
                    set = combine("union", set or no_rooms, pre_set)
                end
            end
            if is_satisfied then
                incoming[context] = set
            end
        end

        local new_needed = {}
        if context_type == nil then
            new_needed = incoming
        else
            local common
            for _, set in pairs(incoming) do
                common = intersect(common, set)
            end
            if common ~= nil then
                if context_type == true then
                    for context, _ in pairs(node_needed) do
                        new_needed[context] = common
                    end
                else
                    -- Rooms use node.name for the room, see node_transmit
                    new_needed[ctx.simple(node.name)] = with_room(common, node.name)
                end
            end
        end
        if is_watched[node_key] then
            for context, set in pairs(new_needed) do
                new_needed[context] = with_room(set, node_key)
            end
        end
        local has_shrunk = false
        for context, set in pairs(new_needed) do
            if node_needed[context] ~= set then
                node_needed[context] = set
                has_shrunk = true
            end
        end
        return has_shrunk
    end

    -- Going in sort order first means most nodes see their prerequisites' final sets on the first visit
    local queue = {}
    local is_queued = {}
    local function push(node_key)
        if is_queued[node_key] == nil then
            is_queued[node_key] = true
            table.insert(queue, node_key)
        end
    end
    for _, node_key in pairs(sort_info.pebble_keys) do
        push(node_key)
    end
    local queue_pos = 1
    while queue_pos <= #queue do
        local node_key = queue[queue_pos]
        queue_pos = queue_pos + 1
        is_queued[node_key] = nil
        if update(node_key) then
            for dep, _ in pairs(graph.nodes[node_key].dep) do
                push(graph.edges[dep].stop)
            end
        end
    end

    return {
        needed = needed,
        intersect = intersect,
        -- The rooms in either set
        union = function(set1, set2)
            return combine("union", set1, set2)
        end,
        -- The set without one room
        without = function(set, room)
            local i = room_ind[room]
            if i == nil or string.sub(set, i, i) ~= "1" then
                return set
            end
            return string.sub(set, 1, i - 1) .. "0" .. string.sub(set, i + 1)
        end,
        -- Set string --> room --> true
        decode = function(set)
            local decoded = {}
            for i = 1, #rooms do
                if string.sub(set, i, i) == "1" then
                    decoded[rooms[i]] = true
                end
            end
            return decoded
        end,
    }
end

-- For every pebble of a sort without complex contexts, the rooms it can't be reached without (see compute_rooms_needed)
-- Returns a function (node_key, context) --> { room --> true }, which gives nil for a pebble that can't be reached at all (context is a simple context, see top.simple_context)
top.rooms_needed = function(graph)
    local info = compute_rooms_needed(graph)
    return function(node_key, context)
        local set = (info.needed[node_key] or {})[context]
        if set == nil then
            return nil
        end
        return info.decode(set)
    end
end

-- For every node a sort without complex contexts reaches, which of the watched nodes (a list of node keys) it can't be reached without in any context (see compute_rooms_needed)
-- Returns a function (node_key, context) --> { watched node key --> true }, which gives nil for a node that can't be reached at all; with context (a simple context), for the node's pebble in it rather than for the node in whichever context
-- sort_info is a sort of graph without complex contexts, which saves making one
top.watched_needed = function(graph, watched, sort_info)
    local info = compute_rooms_needed(graph, watched, sort_info)
    local is_watched = {}
    for _, node_key in pairs(watched) do
        is_watched[node_key] = true
    end
    return function(node_key, context)
        local common
        if context ~= nil then
            common = (info.needed[node_key] or {})[context]
        else
            for _, set in pairs(info.needed[node_key] or {}) do
                common = info.intersect(common, set)
            end
        end
        if common == nil then
            return nil
        end
        local needed = {}
        for name, _ in pairs(info.decode(common)) do
            if is_watched[name] then
                needed[name] = true
            end
        end
        return needed
    end
end

-- Keys of a set, sorted, for logging
local function sorted_keys(set)
    local keys = {}
    for set_key, _ in pairs(set) do
        table.insert(keys, set_key)
    end
    table.sort(keys)
    return keys
end

-- Home sets: a room's home set is the rooms its discoverers (see top.is_discoverer) can't be reached without, like Nauvis and space platforms for Vulcanus, and the rooms the room itself can't be reached without (the route there: the locations on the way, which have to be discovered, and the asteroid defense along it)
-- Those rooms have been used by the time the room is discovered and reached, so with home contexts, a tech that can be had using only them is isolatable there once it's discovered (see discover_home_rooms in top.sort); isolatable contexts there only matter once it's reached
-- The route mostly needs no more than the discovery, but where discoveries follow the star map (src/randomizations/planetary/discovery.lua), a far planet's route passes planets that need other planets' packs, and isolatability may use the techs gotten by the time the room is reached (src/logic/builders/builder.lua)
-- Returns { ids = list of home set ids, sets = id --> { rooms = room --> true, discovered = room --> true for the rooms it's the home set of }, of = room --> home set id }
-- Home set ids are the numbers 1, 2, ..., named home1, home2, ... in logs (top.home_name)
-- Rooms with the same home set share it, and rooms with no reachable discoverer have none
-- Home sets are meant to come from the vanilla graph, so a sort of a randomized graph should pass the vanilla ones as extra.home_sets
-- Also returns the rooms the graph has discoverers of but reaches none of (sorted, and logged): nothing is isolatable in them by discovery, so they mean the graph isn't one to take home sets from (like a planetary change's world before unified pays its debt)
top.home_sets = function(graph)
    local info = compute_rooms_needed(graph)

    -- Room --> rooms that all its discoverers need
    local needs_of_room = {}
    for node_key, node in pairs(graph.nodes) do
        if top.is_discoverer(node) and info.needed[node_key] ~= nil then
            -- A discoverer counts once it's reached in any context
            local node_needs
            for _, set in pairs(info.needed[node_key]) do
                node_needs = info.intersect(node_needs, set)
            end
            for _, discovered in pairs(top.discovered_rooms(node)) do
                if logic.contexts[discovered.room] ~= nil then
                    -- Any one of a room's discoverers discovers it
                    needs_of_room[discovered.room] = info.intersect(needs_of_room[discovered.room], node_needs)
                end
            end
        end
    end
    -- And what reaching the room needs (its room node's rooms, the room itself aside)
    for room, needs in pairs(needs_of_room) do
        local reach = (info.needed[gutils.key("room", room)] or {})[ctx.simple(room)]
        if reach ~= nil then
            needs_of_room[room] = info.union(needs, info.without(reach, room))
        end
    end

    -- Group rooms with the same home set, and number the sets in a fixed order
    local rooms_with_needs = {}
    local needs_list = {}
    for room, needs in pairs(needs_of_room) do
        if rooms_with_needs[needs] == nil then
            rooms_with_needs[needs] = {}
            table.insert(needs_list, needs)
        end
        rooms_with_needs[needs][room] = true
    end
    table.sort(needs_list)
    local home_sets = {
        ids = {},
        sets = {},
        of = {},
    }
    for i = 1, #needs_list do
        local needs = needs_list[i]
        local home_id = i
        table.insert(home_sets.ids, home_id)
        home_sets.sets[home_id] = {
            rooms = info.decode(needs),
            discovered = rooms_with_needs[needs],
        }
        for room, _ in pairs(rooms_with_needs[needs]) do
            home_sets.of[room] = home_id
        end
        log("Home set " .. ctx.home_name(home_id) .. " of " .. table.concat(sorted_keys(rooms_with_needs[needs]), ", ") .. ": " .. table.concat(sorted_keys(home_sets.sets[home_id].rooms), ", "))
    end

    local undiscovered = {}
    for room, _ in pairs(top.room_discoverers(graph)) do
        if logic.contexts[room] ~= nil and needs_of_room[room] == nil then
            table.insert(undiscovered, room)
        end
    end
    table.sort(undiscovered)
    if #undiscovered > 0 then
        log("Home sets: no discoverer of " .. table.concat(undiscovered, ", ") .. " is reachable, so nothing is isolatable there by discovery; home sets should come from a game that can discover every room")
    end
    return home_sets, undiscovered
end

-- Home sets both given home sets agree on: each room's home set is the rooms in both (a room only one of them has keeps that one's)
-- A smaller home set grants less (see discover_home_rooms), so after a change to the game (like a planetary one) that may change which rooms discoveries need, this is the careful choice (notes/old/context-shift-report, the remark on home sets)
-- Returns home sets like top.home_sets does
top.intersect_home_sets = function(a, b)
    local needs_of_room = {}
    local rooms = {}
    for room, _ in pairs(a.of) do
        rooms[room] = true
    end
    for room, _ in pairs(b.of) do
        rooms[room] = true
    end
    for room, _ in pairs(rooms) do
        local a_rooms = a.of[room] ~= nil and a.sets[a.of[room]].rooms or nil
        local b_rooms = b.of[room] ~= nil and b.sets[b.of[room]].rooms or nil
        local needs = {}
        for needed, _ in pairs(a_rooms or b_rooms) do
            if a_rooms == nil or b_rooms == nil or (a_rooms[needed] ~= nil and b_rooms[needed] ~= nil) then
                needs[needed] = true
            end
        end
        needs_of_room[room] = needs
    end
    -- Group rooms with the same needs, numbered in a fixed order (by their needs, then their rooms)
    local rooms_with_needs = {}
    local needs_of_text = {}
    for room, needs in pairs(needs_of_room) do
        local text = table.concat(sorted_keys(needs), "\n")
        if rooms_with_needs[text] == nil then
            rooms_with_needs[text] = {}
            needs_of_text[text] = needs
        end
        rooms_with_needs[text][room] = true
    end
    local texts = sorted_keys(rooms_with_needs)
    local home_sets = {
        ids = {},
        sets = {},
        of = {},
    }
    for i, text in pairs(texts) do
        local home_id = i
        table.insert(home_sets.ids, home_id)
        home_sets.sets[home_id] = {
            rooms = needs_of_text[text],
            discovered = rooms_with_needs[text],
        }
        for room, _ in pairs(rooms_with_needs[text]) do
            home_sets.of[room] = home_id
        end
    end
    return home_sets
end

-- Whether two home sets give every room the same rooms (ids aside)
top.same_home_sets = function(a, b)
    for _, sets in pairs({
        {
            a,
            b,
        },
        {
            b,
            a,
        },
    }) do
        local x = sets[1]
        local y = sets[2]
        for room, home_id in pairs(x.of) do
            if y.of[room] == nil then
                return false
            end
            local x_rooms = x.sets[home_id].rooms
            local y_rooms = y.sets[y.of[room]].rooms
            for needed, _ in pairs(x_rooms) do
                if y_rooms[needed] == nil then
                    return false
                end
            end
        end
    end
    return true
end

-- What a sort reads of home sets, in the order it reads them, so home sets with the same signature give the same sorts (top.same_home_sets also counts other ids and orders as the same)
top.home_sets_signature = function(home_sets)
    local parts = {}
    for _, home_id in pairs(home_sets.ids) do
        table.insert(parts, "id " .. home_id)
        for room, _ in pairs(home_sets.sets[home_id].rooms) do
            table.insert(parts, "room " .. room)
        end
        for room, _ in pairs(home_sets.sets[home_id].discovered or {}) do
            table.insert(parts, "discovered " .. room)
        end
    end
    for room, home_id in pairs(home_sets.of) do
        table.insert(parts, "of " .. room .. " " .. home_id)
    end
    return table.concat(parts, "\n")
end

-- What a sort reads besides its options and home sets, in the order it reads it: the graph's nodes with their op and edges, how it treats their types (logic.type_info), the rooms its discoverers discover (top.discovered_rooms reads data.raw), its edges with their abilities, the rooms (logic.contexts) and this file's switches
-- Graphs with the same fingerprint give the same sorts, so whatever else top.sort comes to read has to go in here too
top.graph_fingerprint = function(graph)
    local parts = {}
    local n = 0
    local types = {}
    for node_key, node in pairs(graph.nodes) do
        n = n + 1
        parts[n] = "n " .. node_key .. " " .. tostring(node.op)
        if types[node.type] == nil then
            types[node.type] = true
            n = n + 1
            local info = logic.type_info[node.type] or {}
            -- With what research home contexts read of a type (top.research_home_contexts)
            parts[n] = "t " .. node.type .. " " .. tostring(info.context) .. " " .. tostring(info.research_input) .. " " .. tostring(info.home_carrier) .. " " .. tostring(info.relay)
        end
        for pre, _ in pairs(node.pre) do
            n = n + 1
            parts[n] = "p " .. pre
        end
        for dep, _ in pairs(node.dep) do
            n = n + 1
            parts[n] = "d " .. dep
        end
        if top.is_discoverer(node) then
            for _, discovered in pairs(top.discovered_rooms(node)) do
                n = n + 1
                parts[n] = "r " .. discovered.location .. " " .. discovered.room
            end
        end
    end
    for edge_key, edge in pairs(graph.edges) do
        n = n + 1
        parts[n] = "e " .. edge_key .. " " .. (edge.abilities ~= nil and tostring(edge.abilities) or "")
    end
    for room, _ in pairs(logic.contexts) do
        n = n + 1
        parts[n] = "c " .. room
    end
    n = n + 1
    parts[n] = "s " .. tostring(top.home_contexts_in_set_rooms) .. " " .. tostring(top.implied_home_contexts) .. " " .. tostring(top.research_home_contexts) .. " " .. tostring(top.implied_ability_contexts)
    return table.concat(parts, "\n")
end

-- A sort bootstrap.prune made of a graph it then left alone (top.offer_reusable_sort): the next from-scratch sort of that graph, still unchanged, with the same options and home sets takes it instead of sorting again
-- It's taken once, so no two callers share one sort's tables
local reusable = nil

top.offer_reusable_sort = function(graph, sort_info, home_sets)
    reusable = {
        graph = graph,
        sort_info = sort_info,
        home_sets = home_sets,
        home_signature = top.home_sets_signature(home_sets),
        fingerprint = top.graph_fingerprint(graph),
    }
end

-- The offered sort, if a from-scratch sort of graph with extra would make the same one, or nil
local function take_reusable_sort(graph, extra)
    local offer = reusable
    if extra == nil or extra.complex_contexts ~= true or extra.home_contexts ~= true then
        return nil
    end
    -- A sort like it of another graph means the work has moved on from the offered graph (like unified randomization sorting its copies of it), so the offer doesn't stay in memory waiting
    if offer.graph ~= graph then
        reusable = nil
        return nil
    end
    for option, _ in pairs(extra) do
        if option ~= "complex_contexts" and option ~= "home_contexts" and option ~= "home_sets" then
            return nil
        end
    end
    -- Home sets the sort would have to work out itself are left to it
    local home_sets = extra.home_sets or logic.home_sets
    if home_sets == nil or (home_sets ~= offer.home_sets and top.home_sets_signature(home_sets) ~= offer.home_signature) then
        return nil
    end
    reusable = nil
    if top.graph_fingerprint(graph) ~= offer.fingerprint then
        return nil
    end
    -- The same contents, so the caller's own table, as a sort of its own would have
    offer.sort_info.home_sets = home_sets
    return offer.sort_info
end

-- Transmission rules for callers that reason about backings (like promotion), so the rules live only in this file
-- A sort keeps the context info it was made with (sort_info.context_info); others are cached as complex --> home sets (false for none) --> whether home contexts were kept to research --> context info
local context_info_cache = {}
local function cached_context_info(sort_info)
    if sort_info.context_info ~= nil then
        return sort_info.context_info
    end
    local complex = sort_info.complex == true
    local home_key = sort_info.home_sets or false
    local research = sort_info.research_homes == true
    context_info_cache[complex] = context_info_cache[complex] or {}
    context_info_cache[complex][home_key] = context_info_cache[complex][home_key] or {}
    if context_info_cache[complex][home_key][research] == nil then
        context_info_cache[complex][home_key][research] = build_context_info(complex, sort_info.home_sets, research)
    end
    return context_info_cache[complex][home_key][research]
end

-- Whether context arrives at edge.stop only from the same context leaving edge.start, as it always does for an edge without abilities but a research home context reaching research (see top.research_home_contexts), for a sort made by top.sort
-- Callers that look up a pebble's own context on such an edge without asking top.edge_source_contexts check this first
top.edge_keeps_context = function(sort_info, edge, context)
    if sort_info.complex ~= true then
        return true
    end
    local context_info = cached_context_info(sort_info)
    if context_info.home[context] ~= nil then
        return not is_research_home(context_info, context) or not is_research_input(edge.stop)
    end
    return edge.abilities == nil
end

-- Contexts leaving edge.start that would make context arrive at edge.stop, for a sort made by top.sort
top.edge_source_contexts = function(sort_info, edge, context)
    return edge_sources(cached_context_info(sort_info), edge, context)
end

-- Contexts leaving node when incoming arrives at it, for a sort made by top.sort
top.node_transmit = function(sort_info, node, incoming)
    return node_transmit(cached_context_info(sort_info), node, incoming)
end

top.sort = function(graph, state, new_conn, extra)
    -- state should be passed in if and only if we're doing a cached sort with a new_conn
    if (state ~= nil and new_conn == nil) or (state == nil and new_conn ~= nil) then
        error("Ambiguous signals for whether this is a cached sort!")
    end
    if state == nil and reusable ~= nil then
        local taken = take_reusable_sort(graph, extra)
        if taken ~= nil then
            return taken
        end
    end

    -- Initialize state vars
    state = state or {}
    extra = extra or {}
    -- A cached sort keeps whatever kind of contexts it was started with
    local complex = extra.complex_contexts == true
    if state.complex ~= nil then
        if extra.complex_contexts ~= nil and complex ~= state.complex then
            error("Cached sort was made with a different complex_contexts setting")
        end
        complex = state.complex
    end
    -- Home sets for home contexts, or nil for none, which a cached sort also keeps
    local home_sets
    if state.complex ~= nil then
        if extra.home_contexts ~= nil and extra.home_contexts ~= (state.home_sets ~= nil) then
            error("Cached sort was made with a different home_contexts setting")
        end
        home_sets = state.home_sets
    elseif extra.home_contexts == true then
        home_sets = extra.home_sets or logic.home_sets or top.home_sets(graph)
    end
    -- Whether home contexts are kept to research (top.research_home_contexts), which a cached sort keeps too
    local research = top.research_home_contexts
    if state.complex ~= nil then
        research = state.research_homes == true
    end
    local context_info = build_context_info(complex, home_sets, research)
    -- The pebbles (node/context combos) in the order the sort reaches them, as two lists: pebble_keys[ind] is the ind-th pebble's node key and pebble_contexts[ind] its context
    -- Lists rather than a { node_key, context } table per pebble, which cost about 0.5 GB per big sort with planet copies
    -- A sort kept from before these lists (the control stage keeps sorts in storage) still has its pebbles as such tables in sorted, so it's changed over here
    if state.sorted ~= nil and state.pebble_keys == nil then
        state.pebble_keys = {}
        state.pebble_contexts = {}
        for ind = 1, #state.sorted do
            state.pebble_keys[ind] = state.sorted[ind].node_key
            state.pebble_contexts[ind] = state.sorted[ind].context
        end
        state.sorted = nil
    end
    -- node_to_context_inds goes node_key --> { context --> index | nil }, where index is the pebble's place in the pebble lists, nil if nonexistent
    -- Represents the OUTGOING contexts
    -- To check incoming, check node_to_context_inds on the prerequisite nodes (through the edge, which could change abilities)
    -- This is updated when processed from open (not when added to it)
    local node_to_context_inds = state.node_to_context_inds or {}
    local pebble_keys = state.pebble_keys or {}
    local pebble_contexts = state.pebble_contexts or {}
    -- Ranks of the weaker contexts that pebbles stand for are read through the lists like listed pebbles (top.implied_ability_contexts)
    if complex then
        setmetatable(pebble_keys, PEBBLE_KEYS_META)
        setmetatable(pebble_contexts, PEBBLE_CONTEXTS_META)
    end
    -- Table of node_key --> nil, or the first context the node waits with; open_sets has node_key --> { context --> true } once it waits with more
    -- Most nodes wait with one context, so a set is only made for a second one, and filled in the order the contexts came (as when every node had a set)
    local open = state.open or {}
    local open_sets = {}
    -- A sort ends with open empty, but a state from before open_sets would keep sets in open; they move to open_sets, with open holding one of their contexts
    for node_key, waiting in pairs(open) do
        if type(waiting) == "table" then
            open_sets[node_key] = waiting
            open[node_key] = next(waiting)
        end
    end
    -- open's keys as a list, plus each key's position in that list, so random selection doesn't need to scan open
    local open_list = state.open_list or {}
    local open_pos = state.open_pos or {}
    -- Space locations whose discovery has already been handled (complex contexts only)
    local discovered_space_locations = state.discovered_space_locations or {}
    -- With home contexts instead: rooms discovered so far, and home set id --> techs with a pebble in one of its home contexts (see discover_home_rooms)
    local home_discovered = state.home_discovered or {}
    local home_techs = state.home_techs or {}
    -- Tech key --> room --> true for rooms whose isolatable contexts the discovery rule gives the tech once it's had there at all (see add_isolatable_contexts)
    local pending_discovery = state.pending_discovery or {}
    -- Nodes that got a home context in this sort, whose home contexts standing for others are written out at the end (top.implied_home_contexts)
    local home_touched = {}
    -- Whether ability contexts stand for the weaker ones of their room (top.implied_ability_contexts), and mask + 1 --> true for the masks process_depnode's check of weaker masks has found so far (emptied after each check)
    local implied_abilities = complex and top.implied_ability_contexts
    local masks_found = {}
    -- The lists the transmit functions give, each built once in this sort (see new_transmit_cache)
    local transmit_cache = new_transmit_cache()
    -- A table process_depnode's AND checks reuse for the home set ids found so far, empty between checks
    local found_scratch = {}
    -- The one context of a node that waited in open with one, as the main loop's batch for it, emptied after its batches (see open)
    local single_batch = {}
    -- Discoverer key --> what top.discovered_rooms gives for it, found once per sort (it reads only data.raw and logic.contexts)
    local discovered_rooms_memo = {}
    local function rooms_discovered_by(node, node_key)
        local rooms = discovered_rooms_memo[node_key]
        if rooms == nil then
            rooms = top.discovered_rooms(node)
            discovered_rooms_memo[node_key] = rooms
        end
        return rooms
    end
    -- With them, node key --> { context --> true } for the contexts the discovery rule put in open for a tech, which its batch records after its others (see the main loop)
    local discovery_added = {}
    -- With research home contexts (top.research_home_contexts): whether they're on, and node key --> whether it's a research input (is_research_input), filled in when first read so the main loop needs no call
    local research_on = context_info.research_homes
    local research_stops = setmetatable({}, {
        __index = function(stops, node_key)
            local known = is_research_input(node_key)
            stops[node_key] = known
            return known
        end,
    })
    -- With research home contexts: node key --> whether it takes them, found when first asked
    -- Techs do, and so do research inputs and relays leading to one (a launch only for the triggers it meets); found again in each sort, since a cached sort's new edge can change where a relay leads
    local carries_home_memo = {}
    local function carries_home(node_key)
        local known = carries_home_memo[node_key]
        if known == nil then
            local node = graph.nodes[node_key]
            local info = node ~= nil and logic.type_info[node.type] or nil
            known = false
            if info ~= nil and info.home_carrier == true then
                known = true
            elseif info ~= nil and (info.research_input == true or info.relay == true) then
                -- Stored first, so a cycle of relays ends here
                carries_home_memo[node_key] = false
                for dep, _ in pairs(node.dep) do
                    if carries_home(graph.edges[dep].stop) then
                        known = true
                        break
                    end
                end
            end
            carries_home_memo[node_key] = known
        end
        return known
    end
    -- Don't choose randomly for backwards compatibility with Frodo version
    if not DO_FRODO_FIXES and extra.choose_randomly == false then
        extra.choose_randomly = true
    end

    -- Without choose_randomly, the next node is the open node with the earliest pebble (lowest index in the pebble lists), or the last one pairs(open) gives if no open node has a pebble yet
    -- A node's earliest pebble can't change while it's in open (only the node taken out of open gets new pebbles, and they come after its old ones), so the open nodes with one wait in a heap ordered by it
    -- Indices are unique, so the heap never has to break a tie
    local use_heap = not extra.choose_randomly
    local heap_inds = {}
    local heap_keys = {}
    local heap_size = 0

    local function heap_push(ind, node_key)
        heap_size = heap_size + 1
        local pos = heap_size
        while pos > 1 do
            local parent = math.floor(pos / 2)
            if heap_inds[parent] < ind then
                break
            end
            heap_inds[pos] = heap_inds[parent]
            heap_keys[pos] = heap_keys[parent]
            pos = parent
        end
        heap_inds[pos] = ind
        heap_keys[pos] = node_key
    end

    local function heap_pop()
        local earliest_key = heap_keys[1]
        local last_ind = heap_inds[heap_size]
        local last_key = heap_keys[heap_size]
        heap_inds[heap_size] = nil
        heap_keys[heap_size] = nil
        heap_size = heap_size - 1
        if heap_size > 0 then
            local pos = 1
            while true do
                local child = 2 * pos
                if child > heap_size then
                    break
                end
                if child < heap_size and heap_inds[child + 1] < heap_inds[child] then
                    child = child + 1
                end
                if last_ind < heap_inds[child] then
                    break
                end
                heap_inds[pos] = heap_inds[child]
                heap_keys[pos] = heap_keys[child]
                pos = child
            end
            heap_inds[pos] = last_ind
            heap_keys[pos] = last_key
        end
        return earliest_key
    end

    -- Puts a node that just entered open in the heap, if it has a pebble
    -- node_key --> index of the node's earliest pebble, once it has one
    -- New pebbles come after the old ones (and the contexts they stand for rank just below them, after the old ones too), so it doesn't change during a sort once found
    local earliest_inds = {}
    local function heap_add(node_key)
        local earliest = earliest_inds[node_key]
        if earliest == nil then
            for _, ind in pairs(node_to_context_inds[node_key]) do
                if earliest == nil or ind < earliest then
                    earliest = ind
                end
            end
            earliest_inds[node_key] = earliest
        end
        if earliest ~= nil then
            heap_push(earliest, node_key)
        end
    end

    -- Initialize node_to_context_inds on *all* nodes, etc.
    -- Only do this on new sorts
    -- We'll actually populate initial "open" list later
    if new_conn == nil then
        for node_key, _ in pairs(graph.nodes) do
            node_to_context_inds[node_key] = {}
        end
    end
    -- A sort always empties open, but whatever a state still has open goes in the heap too
    if use_heap then
        for node_key, _ in pairs(open) do
            heap_add(node_key)
        end
    end

    -- node_key is key(node), when the caller has it
    local function add_to_open(node, context, node_key)
        node_key = node_key or key(node)
        local waiting = open[node_key]
        if waiting == nil then
            open[node_key] = context
            table.insert(open_list, node_key)
            open_pos[node_key] = #open_list
            if use_heap then
                heap_add(node_key)
            end
        elseif waiting ~= context then
            local contexts = open_sets[node_key]
            if contexts ~= nil then
                contexts[context] = true
            else
                -- A second context: the set gets both in the order they came
                contexts = {}
                contexts[waiting] = true
                contexts[context] = true
                open_sets[node_key] = contexts
            end
        end
    end

    -- Swap-remove from open_list so this is O(1)
    local function remove_from_open(node_key)
        local pos = open_pos[node_key]
        local last_key = open_list[#open_list]
        open_list[pos] = last_key
        open_pos[last_key] = pos
        open_list[#open_list] = nil
        open_pos[node_key] = nil
        open[node_key] = nil
        open_sets[node_key] = nil
    end

    -- Whether a node has a context already or about to (in open), counting for a home context those of the home sets inside it in the same room, which stand for it (top.implied_home_contexts)
    local function already_has(node_key, context)
        local inds = node_to_context_inds[node_key]
        if inds[context] ~= nil then
            return true
        end
        local subsets = context_info.home_subsets[context_info.home[context]]
        if subsets == nil or subsets[1] == nil then
            return false
        end
        local room_homes = context_info.home_of[context_info.room[context]]
        -- What waits for the node in open: its first context, and the set of them once there are more (see open)
        local waiting = open[node_key]
        local waiting_set = open_sets[node_key]
        for _, subset_id in pairs(subsets) do
            local subset_context = room_homes[subset_id]
            if subset_context ~= nil and (inds[subset_context] ~= nil or waiting == subset_context or (waiting_set ~= nil and waiting_set[subset_context] ~= nil)) then
                return true
            end
        end
        return false
    end

    -- Whether every prerequisite of an AND node sends it context
    -- A context that isn't a home context, through an edge that doesn't change abilities (or any edge, for simple contexts), is read straight from the prerequisite's pebbles, as edge_sends would
    local function all_pres_send(depnode, context)
        local plain = context_info.home[context] == nil
        for pre, _ in pairs(depnode.pre) do
            local edge = graph.edges[pre]
            if plain and (not complex or edge.abilities == nil) then
                if node_to_context_inds[edge.start][context] == nil then
                    return false
                end
            elseif not edge_sends(context_info, node_to_context_inds, edge, context) then
                return false
            end
        end
        return true
    end

    -- Puts what the depnode sends when context arrives at it in open, skipping contexts it already has
    local function add_arrived(depnode, context, depnode_key)
        -- Nodes that aren't rooms or forgetters send every context on unchanged (see node_transmit), which needs no list
        if logic.type_info[depnode.type].context == nil then
            if not already_has(depnode_key, context) then
                add_to_open(depnode, context, depnode_key)
            end
        elseif implied_abilities and context_info.home[context] == nil then
            for _, outgoing in pairs(strongest_transmit(context_info, depnode, context, transmit_cache)) do
                if not already_has(depnode_key, outgoing) then
                    add_to_open(depnode, outgoing, depnode_key)
                end
            end
        else
            for _, outgoing in pairs(node_transmit(context_info, depnode, context, transmit_cache)) do
                if not already_has(depnode_key, outgoing) then
                    add_to_open(depnode, outgoing, depnode_key)
                end
            end
        end
    end

    -- Checks if this depnode *newly* has context
    -- incoming is the context as it arrives at depnode (after going through the edge)
    -- depnode_key is key(depnode), and edge_key the edge incoming came through, when the caller has them
    -- incoming_sends says edge_key's prerequisite has just got the pebble incoming came from, as in the main loop, so that edge sends incoming
    local function process_depnode(depnode, incoming, depnode_key, edge_key, incoming_sends)
        depnode_key = depnode_key or key(depnode)

        -- Research home contexts only go to research, techs and the relays leading to them, and a node that has one already gets nothing new from it (top.research_home_contexts)
        local incoming_home = context_info.home[incoming]
        if incoming_home ~= nil and context_info.research_homes and context_info.home_full[incoming_home] == nil and (not carries_home(depnode_key) or already_has(depnode_key, incoming)) then
            return
        end

        local check
        if depnode.op == "OR" then
            -- OR is false until proven true
            -- Any prereq with a pebble proves it, and the one incoming came through usually has one, so it's tried first
            if edge_key ~= nil and depnode.pre[edge_key] ~= nil and (incoming_sends or edge_sends(context_info, node_to_context_inds, graph.edges[edge_key], incoming)) then
                check = true
            else
                check = false
                for pre, _ in pairs(depnode.pre) do
                    if edge_sends(context_info, node_to_context_inds, graph.edges[pre], incoming) then
                        check = true
                        break
                    end
                end
            end
        elseif depnode.op == "AND" then
            check = all_pres_send(depnode, incoming)
        else
            error("Invalid node op: " .. tostring(depnode.op))
        end

        if check then
            add_arrived(depnode, incoming, depnode_key)
        elseif depnode.op == "AND" then
            -- The prerequisite incoming came from also stands for the home sets containing incoming's, which the others may all send already, though not incoming itself (top.implied_home_contexts)
            -- Those home contexts weren't passed on, so their check is here: the smallest containing home sets the depnode can have, each standing for the ones containing it
            -- They go in open after all of them are checked, since open is part of what already_has reads
            local arrived
            local home_id = context_info.home[incoming]
            if home_id ~= nil then
                local room_homes = context_info.home_of[context_info.room[incoming]]
                local found = found_scratch
                local found_any = false
                for _, superset_id in pairs(context_info.home_supersets[home_id]) do
                    local superset_context = room_homes[superset_id]
                    local covered = false
                    for _, inner_id in pairs(context_info.home_subsets[superset_id]) do
                        if found[inner_id] ~= nil then
                            covered = true
                            break
                        end
                    end
                    if superset_context ~= nil and not covered then
                        if already_has(depnode_key, superset_context) then
                            found[superset_id] = true
                            found_any = true
                        elseif all_pres_send(depnode, superset_context) then
                            found[superset_id] = true
                            found_any = true
                            arrived = arrived or {}
                            table.insert(arrived, superset_context)
                        end
                    end
                end
                if found_any then
                    for superset_id, _ in pairs(found) do
                        found[superset_id] = nil
                    end
                end
            elseif implied_abilities then
                -- Likewise the prerequisite incoming came from also stands for the weaker masks of incoming's room, which the others may all send though not incoming itself (top.implied_ability_contexts)
                -- So they're checked here from the strongest down, each one the depnode has, is about to have or now gets standing for the ones below it
                local inds = node_to_context_inds[depnode_key]
                local waiting = open[depnode_key]
                local waiting_set = open_sets[depnode_key]
                if inds[incoming] == nil and waiting ~= incoming and (waiting_set == nil or waiting_set[incoming] == nil) then
                    local room_contexts = context_info.of[context_info.room[incoming]]
                    for _, mask in pairs(WEAKER_MASKS[context_info.mask[incoming] + 1]) do
                        local covered = false
                        for _, stronger in pairs(STRONGER_MASKS[mask + 1]) do
                            if masks_found[stronger + 1] then
                                covered = true
                                break
                            end
                        end
                        if not covered then
                            local weaker = room_contexts[mask + 1]
                            if inds[weaker] ~= nil or waiting == weaker or (waiting_set ~= nil and waiting_set[weaker] ~= nil) then
                                masks_found[mask + 1] = true
                            elseif all_pres_send(depnode, weaker) then
                                masks_found[mask + 1] = true
                                arrived = arrived or {}
                                table.insert(arrived, weaker)
                            end
                        end
                    end
                    for _, mask in pairs(masks) do
                        masks_found[mask + 1] = nil
                    end
                end
            end
            if arrived ~= nil then
                for _, context in pairs(arrived) do
                    add_arrived(depnode, context, depnode_key)
                end
            end
        end
    end

    -- If a node discovers a room (a tech unlocking a space location, or a spaceship for space platforms), every tech so far is considered isolatable there (ported from extended-sort.lua)
    local function discover_space_locations(tech_node, tech_key)
        for _, discovered in pairs(rooms_discovered_by(tech_node, tech_key)) do
            local loc = discovered.location
            if discovered_space_locations[loc] == nil then
                discovered_space_locations[loc] = true
                local room_contexts = context_info.of[discovered.room]
                if room_contexts ~= nil then
                    for node_key, node in pairs(graph.nodes) do
                        if node.type == "technology" and (next(node_to_context_inds[node_key]) ~= nil or open[node_key] ~= nil) then
                            for i, context in pairs(room_contexts) do
                                if has_ability(i - 1, ISOLATABILITY) and (not implied_abilities or i - 1 == ALL_ABILITIES) and node_to_context_inds[node_key][context] == nil then
                                    add_to_open(node, context, node_key)
                                    if implied_abilities then
                                        discovery_added[node_key] = discovery_added[node_key] or {}
                                        discovery_added[node_key][context] = true
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Gives a tech the isolatable contexts of a room that it doesn't have yet, each where the tech has the same context without isolatability in that room: a tech isn't isolatable where the sort doesn't have it at all yet
    -- With research home contexts, a tech can get the home context this rule asks for before its plain contexts reach it (research counts without deliveries), so the rest waits for them (pending_discovery), and the tech's batch that brings them gives it
    -- With ability contexts standing for weaker ones, the strongest of them stands for the others (top.implied_ability_contexts), which is only right because the weaker ones without isolatability came first
    local function add_isolatable_contexts(tech_node, room, tech_key)
        tech_key = tech_key or key(tech_node)
        local inds = node_to_context_inds[tech_key]
        local room_contexts = context_info.of[room]
        local strongest
        local waits = false
        for _, mask in pairs(ISOLATED_MASKS) do
            local context = room_contexts[mask + 1]
            if inds[context] == nil then
                if inds[room_contexts[without_ability(mask, ISOLATABILITY) + 1]] == nil then
                    waits = true
                elseif not implied_abilities then
                    add_to_open(tech_node, context, tech_key)
                elseif strongest == nil or ctx.mask_covers(mask, strongest) then
                    strongest = mask
                end
            end
        end
        if strongest ~= nil then
            local context = room_contexts[strongest + 1]
            add_to_open(tech_node, context, tech_key)
            discovery_added[tech_key] = discovery_added[tech_key] or {}
            discovery_added[tech_key][context] = true
        end
        if waits then
            pending_discovery[tech_key] = pending_discovery[tech_key] or {}
            pending_discovery[tech_key][room] = true
        end
    end

    -- The discovery rule with home contexts, which doesn't depend on order: once a room is discovered, every tech that can be had using only its home set is isolatable there
    -- This half runs when a discoverer is reached, and add_home_tech when a tech gets a home context, so the rule applies whichever comes first
    local function discover_home_rooms(discoverer, discoverer_key)
        for _, discovered in pairs(rooms_discovered_by(discoverer, discoverer_key)) do
            local room = discovered.room
            local home_id = home_sets.of[room]
            if home_id ~= nil and home_discovered[room] == nil then
                home_discovered[room] = true
                for tech_key, _ in pairs(home_techs[home_id] or EMPTY) do
                    add_isolatable_contexts(graph.nodes[tech_key], room, tech_key)
                end
            end
        end
    end

    local function add_home_tech(tech_node, home_id, tech_key)
        tech_key = tech_key or key(tech_node)
        home_techs[home_id] = home_techs[home_id] or {}
        if home_techs[home_id][tech_key] == nil then
            home_techs[home_id][tech_key] = true
            for room, _ in pairs(home_sets.sets[home_id].discovered) do
                if home_discovered[room] ~= nil then
                    add_isolatable_contexts(tech_node, room, tech_key)
                end
            end
        end
    end

    -- Now we can add starting nodes in open
    if new_conn == nil then
        for _, node in pairs(gutils.sources(graph)) do
            local node_key = key(node)
            -- With research home contexts, only research sources get research home contexts (top.research_home_contexts)
            local gets_home = not context_info.research_homes or carries_home(node_key)
            for _, context in pairs(context_info.list) do
                local is_home = context_info.home[context] ~= nil
                -- With ability contexts standing for weaker ones, each room's strongest context stands for the room's others (top.implied_ability_contexts)
                if (gets_home or not is_research_home(context_info, context)) and (is_home or not implied_abilities or context_info.mask[context] == ALL_ABILITIES) then
                    add_to_open(node, context, node_key)
                end
            end
        end
    else
        -- Otherwise, add the dependent of the new_conn to open with the prereq's contexts (sent through the edge)
        local start_key = key(new_conn[1])
        local stop_key = key(new_conn[2])
        local new_edge
        if complex then
            new_edge = graph.edges[gutils.ekey({
                start = start_key,
                stop = stop_key,
            })]
        end
        for context, _ in pairs(node_to_context_inds[start_key]) do
            local arriving_contexts = { context }
            if new_edge ~= nil then
                arriving_contexts = edge_transmit(context_info, new_edge, context)
            end
            for _, arriving in pairs(arriving_contexts) do
                if extra.do_new_edge_processing then
                    process_depnode(new_conn[2], arriving, stop_key)
                elseif not is_research_home(context_info, arriving) or carries_home(stop_key) then
                    add_to_open(new_conn[2], arriving, stop_key)
                end
            end
        end
    end

    -- Repeat until open is empty
    while #open_list > 0 do
        -- Find the next candidate to remove from open
        -- This is the node, if any, with lowest value in the node_to_context_inds table
        local node_key
        if top.choose_open ~= nil then
            node_key = top.choose_open(open, #pebble_keys)
        elseif extra.choose_randomly then
            -- Use the mod's rng so the sort follows the seed setting
            node_key = open_list[rng.int("context-sort", #open_list)]
        elseif heap_size > 0 then
            node_key = heap_pop()
        else
            -- No open node has a pebble yet (see use_heap above)
            for candidate_node_key, _ in pairs(open) do
                node_key = candidate_node_key
            end
        end

        -- A node that waited with more than one context has them in open_sets; one that waited with one gets it in single_batch, emptied again after its batches (see open)
        local contexts = open_sets[node_key]
        local single
        if contexts == nil then
            single = open[node_key]
            if single ~= nil then
                single_batch[single] = true
                contexts = single_batch
            end
        end
        remove_from_open(node_key)
        -- Transmit contexts to each dependent
        local node = graph.nodes[node_key]
        -- Home sets that this node got a home context of, with the home sets containing them (top.implied_home_contexts)
        local new_home_ids
        -- The contexts the discovery rule added for a tech go in a second batch after its others, which they don't stand for, so its own earlier pebble a path backs them with (find_discovery_preinds) comes first (top.implied_ability_contexts)
        local batch = contexts
        local discovered_batch
        if discovery_added[node_key] ~= nil then
            local discovered = discovery_added[node_key]
            discovery_added[node_key] = nil
            batch = {}
            discovered_batch = {}
            for context, _ in pairs(contexts) do
                if discovered[context] ~= nil then
                    discovered_batch[context] = true
                else
                    batch[context] = true
                end
            end
        end
        while batch ~= nil do
            for context, _ in pairs(batch) do
                local home_id = context_info.home[context]
                local room_contexts = complex and context_info.of[context_info.room[context]] or nil
                -- A context that a stronger one of its room in the same batch stands for gets a rank of its own below that pebble's, without being listed (top.implied_ability_contexts)
                -- One the node has already, like one a continued sort's new edge brings again, isn't listed again either, and keeps its rank (as home contexts do)
                local stood_for = false
                if implied_abilities and home_id == nil then
                    stood_for = node_to_context_inds[node_key][context] ~= nil
                    for _, mask in pairs(STRONGER_MASKS[context_info.mask[context] + 1]) do
                        if batch[room_contexts[mask + 1]] ~= nil then
                            stood_for = true
                            break
                        end
                    end
                end
                -- A home context that one of a home set inside it already stands for isn't passed on (it came in before that one did)
                if not stood_for and (home_id == nil or implied_ind(context_info, node_to_context_inds[node_key], context) == nil) then
                    -- Add this node-context pebble to the pebble lists
                    local ind = #pebble_keys + 1
                    pebble_keys[ind] = node_key
                    pebble_contexts[ind] = context
                    -- Add the context
                    local inds = node_to_context_inds[node_key]
                    inds[context] = ind
                    -- And the weaker contexts of its room it stands for, at their own ranks just below it, unless the node had them already (top.implied_ability_contexts)
                    if implied_abilities and home_id == nil then
                        for _, mask in pairs(WEAKER_MASKS[context_info.mask[context] + 1]) do
                            local weaker = room_contexts[mask + 1]
                            if inds[weaker] == nil then
                                inds[weaker] = stood_for_rank(ind, mask)
                            end
                        end
                    end

                    -- Edges without abilities (and every edge, for simple and home contexts) pass the context on unchanged, as edge_transmit would, without making a list for it
                    -- An edge that changes abilities sends the masks its table gives, in edge_transmit's order, also without a list, or with ability contexts standing for weaker ones the one mask standing for them (top.implied_ability_contexts)
                    -- Either way the pebble just recorded is where incoming comes from, so the edge sends it (process_depnode's incoming_sends)
                    local passes_unchanged = not complex or home_id ~= nil
                    -- What an isolatable pebble beyond the core's rooms, or a core one, gives research (top.research_home_contexts), found when an edge to research first asks
                    local gives_research
                    for dep, _ in pairs(node.dep) do
                        local edge = graph.edges[dep]
                        local depnode = graph.nodes[edge.stop]
                        if passes_unchanged or edge.abilities == nil then
                            process_depnode(depnode, context, edge.stop, dep, true)
                        elseif implied_abilities then
                            process_depnode(depnode, room_contexts[STRONGEST_FORWARD[edge.abilities][context_info.mask[context] + 1] + 1], edge.stop, dep, true)
                        else
                            for _, mask in pairs(FORWARD_MASKS[edge.abilities][context_info.mask[context] + 1]) do
                                process_depnode(depnode, room_contexts[mask + 1], edge.stop, dep, true)
                            end
                        end
                        -- Such a pebble leaving for a research input brings research home contexts along (see edge_transmit), and this pebble is where they come from
                        if research_on and research_stops[edge.stop] then
                            if gives_research == nil then
                                gives_research = research_home_contexts(context_info, context) or false
                            end
                            if gives_research then
                                for _, home_context in pairs(gives_research) do
                                    process_depnode(depnode, home_context, edge.stop, dep, true)
                                end
                            end
                        end
                    end

                    if home_id ~= nil then
                        new_home_ids = new_home_ids or {}
                        new_home_ids[home_id] = true
                        for _, superset_id in pairs(context_info.home_supersets[home_id]) do
                            new_home_ids[superset_id] = true
                        end
                        home_touched[node_key] = true
                    end
                end
            end
            batch = discovered_batch
            discovered_batch = nil
        end
        if single ~= nil then
            single_batch[single] = nil
        end

        -- The discovery rules run after the whole batch, so a context they add isn't one this node is still processing
        if complex then
            if home_sets ~= nil then
                if node.type == "technology" then
                    -- Rooms whose discovery waited for this tech to be had there (see add_isolatable_contexts)
                    local waiting = pending_discovery[node_key]
                    if waiting ~= nil then
                        pending_discovery[node_key] = nil
                        for room, _ in pairs(waiting) do
                            add_isolatable_contexts(node, room, node_key)
                        end
                    end
                    for home_id, _ in pairs(new_home_ids or EMPTY) do
                        add_home_tech(node, home_id, node_key)
                    end
                end
                if top.is_discoverer(node) then
                    discover_home_rooms(node, node_key)
                end
            elseif top.is_discoverer(node) then
                discover_space_locations(node, node_key)
            end
        end
    end

    -- The home contexts that a smaller home set's context stood for, written out with its index, so what reads the sort finds every home context as before (top.implied_home_contexts)
    for node_key, _ in pairs(home_touched) do
        local inds = node_to_context_inds[node_key]
        local implied = {}
        for context, ind in pairs(inds) do
            local home_id = context_info.home[context]
            if home_id ~= nil then
                local room_homes = context_info.home_of[context_info.room[context]]
                for _, superset_id in pairs(context_info.home_supersets[home_id]) do
                    local superset_context = room_homes[superset_id]
                    if superset_context ~= nil and inds[superset_context] == nil and (implied[superset_context] == nil or ind < implied[superset_context]) then
                        implied[superset_context] = ind
                    end
                end
            end
        end
        for context, ind in pairs(implied) do
            inds[context] = ind
        end
    end

    return {
        node_to_context_inds = node_to_context_inds,
        pebble_keys = pebble_keys,
        pebble_contexts = pebble_contexts,
        open = open,
        open_list = open_list,
        open_pos = open_pos,
        complex = complex,
        -- Every context this sort uses, for iterating over in place of logic.contexts
        contexts = context_info.list,
        discovered_space_locations = discovered_space_locations,
        home_sets = home_sets,
        home_discovered = home_discovered,
        home_techs = home_techs,
        pending_discovery = pending_discovery,
        -- Whether its home contexts were kept to research (top.research_home_contexts), and the context info it was made with, for what reasons about its backings
        research_homes = context_info.research_homes == true,
        context_info = context_info,
    }
end

-- For a tech pebble in an isolatable context that it could have gotten by discovery (see top.discovery_candidates): the earliest earlier pebble of the tech itself and of a discoverer of the room, or nil
local function find_discovery_preinds(sort_info, room_discoverers, tech_node, context, curr_ind)
    local candidates = top.discovery_candidates(sort_info, room_discoverers, tech_node, context)
    if candidates == nil then
        return nil
    end
    local own_ind = candidates.own[1]
    local discoverer_ind = candidates.discoverers[1]
    if own_ind == nil or own_ind >= curr_ind or discoverer_ind == nil or discoverer_ind >= curr_ind then
        return nil
    end
    return { own_ind, discoverer_ind }
end

-- Of the contexts in latest_of (context --> the index of its latest prereq) whose latest prereq the sort reached in the same step as earliest_ind, the one tie_rank ranks lowest, or chosen (earliest_ind's) if none ranks lower; the earlier one where two rank the same
-- A step is a node's batch of pebbles, which top.sort lists next to each other in whatever order it took their contexts (see its main loop), so which of them comes first says nothing about the game
-- A rank that a listed pebble stands for (top.implied_ability_contexts) belongs to that pebble's batch
-- A forgetter's, a room's or a source's batch is one thing happening, the same whichever of its contexts the path goes on from, so there's nothing to choose
local function tied_choice(graph, pebble_keys, latest_of, earliest_ind, chosen, tie_rank)
    local first = math.ceil(earliest_ind)
    local batch_key = pebble_keys[first]
    local batch_node = graph.nodes[batch_key]
    if logic.type_info[batch_node.type].context ~= nil or next(batch_node.pre) == nil then
        return chosen
    end
    local last = first
    while pebble_keys[last + 1] ~= nil and pebble_keys[last + 1] == batch_key do
        last = last + 1
    end
    local best = chosen
    local best_rank = tie_rank(chosen)
    local best_ind = latest_of[chosen]
    for context, latest_ind in pairs(latest_of) do
        local listed = math.ceil(latest_ind)
        if listed >= first and listed <= last then
            local rank = tie_rank(context)
            if rank < best_rank or (rank == best_rank and latest_ind < best_ind) then
                best = context
                best_rank = rank
                best_ind = latest_ind
            end
        end
    end
    return best
end

-- This is taken mainly from top-sort.lua
-- Creates a path of inds within the sort's pebble lists starting from the goal and going backwards for how to get there
-- goal_inds is a list of inds in the pebble lists of the pebbles we are hoping to achieve
-- extra_params.stop_if(node_key, context): when it's true for a pebble other than the first goal, the path doesn't go on past that pebble
-- extra_params.prefer(pre_ind, curr_ind) picks which prereq an OR node that keeps its context takes: a preferred one goes before the earliest, and may even come after the OR node's own pebble as long as it's before extra_params.prefer_before (default: the OR node's pebble)
-- A later prereq can lead back to the OR node, so with prefer the result also has chosen (ind --> the inds it went on to), for checking that the path is still a derivation (see src/logic/builders/witness-recipes.lua), and preferred (OR pebble --> the preferred prereq it took over an earlier one)
-- extra_params.tie_rank(context) ranks the contexts a forgetter or room takes in (lower first): of those the sort finished in the same step as the earliest one, it takes the lowest ranked instead of whichever the sort listed first (see tied_choice)
-- Like where a tech is researched: the sort ships its packs to every room in the same step, so the room listed first is arbitrary; the result's num_tie_moves counts the choices the rank changed
top.path = function(graph, goal_inds, sort_info, extra_params)
    local pebble_keys = sort_info.pebble_keys
    local pebble_contexts = sort_info.pebble_contexts
    local node_to_context_inds = sort_info.node_to_context_inds
    extra_params = extra_params or {}
    local context_info = cached_context_info(sort_info)
    local stop_if = extra_params.stop_if or function(node_key, context) return false end
    local prefer = extra_params.prefer
    local tie_rank = extra_params.tie_rank
    local num_tie_moves = 0
    local chosen
    local preferred
    if prefer ~= nil then
        chosen = {}
        preferred = {}
    end
    -- Only needed for the discovery rule, so found when first used
    local room_discoverers

    local path = goal_inds
    -- Whether an index is in the path yet
    local in_path = {}
    for _, ind in pairs(path) do
        in_path[ind] = true
    end

    local path_ind = 1
    while path_ind <= #path do
        local curr_ind = path[path_ind]
        local curr_key = pebble_keys[curr_ind]
        local curr_context = pebble_contexts[curr_ind]
        local curr_node = graph.nodes[curr_key]

        -- context is the context arriving at node
        local function find_preinds(node, context)
            local preinds = {}

            if node.op == "OR" then
                -- Just try earliest prereq (could be suboptimal, but this is a good heuristic)
                -- Start at curr_ind to more easily do error checking on indeed getting an earlier pebble
                local first_occurrence_ind = curr_ind
                -- Only nodes that keep their context: a forgetting node's prereqs are compared across contexts below
                local can_prefer = prefer ~= nil and logic.type_info[node.type].context == nil
                local prefer_before = extra_params.prefer_before or curr_ind
                local preferred_ind
                for pre, _ in pairs(node.pre) do
                    -- Need to check that context is non-nil since OR nodes can depend on later things/with different contexts
                    local pre_ind = edge_ind(context_info, node_to_context_inds, graph.edges[pre], context)
                    if pre_ind ~= nil and pre_ind < first_occurrence_ind then
                        first_occurrence_ind = pre_ind
                    end
                    if can_prefer and pre_ind ~= nil and pre_ind < prefer_before and (preferred_ind == nil or pre_ind < preferred_ind) and prefer(pre_ind, curr_ind) then
                        preferred_ind = pre_ind
                    end
                end
                -- Make sure we found something/didn't loop
                if first_occurrence_ind == curr_ind then
                    return false
                end
                if preferred_ind ~= nil and preferred_ind ~= first_occurrence_ind then
                    preferred[curr_ind] = preferred_ind
                    table.insert(preinds, preferred_ind)
                else
                    table.insert(preinds, first_occurrence_ind)
                end
            elseif node.op == "AND" then
                -- Add all previous pebbles to the path
                for pre, _ in pairs(node.pre) do
                    local prev_ind = edge_ind(context_info, node_to_context_inds, graph.edges[pre], context)
                    -- If this is nil, then not satisfiable, so abandon this context
                    if prev_ind == nil then
                        return false
                    end
                    -- prev_ind >= curr_ind can happen in a valid manner, it just means this is an invalid context
                    table.insert(preinds, prev_ind)
                end
            end

            return preinds
        end

        -- Whether incoming arriving at curr_node would send out curr_context
        local function transmits_curr_context(incoming)
            if not context_info.complex then
                return true
            end
            -- Test membership directly: constructing every outgoing context here repeats the room expansion for every candidate of every witness.
            local context_type = logic.type_info[curr_node.type].context
            local home = context_info.home[incoming]
            if home ~= context_info.home[curr_context] then
                return false
            end
            if context_type == true then
                if home ~= nil then
                    return true
                end
                local mask = context_info.mask[incoming]
                if has_ability(mask, ISOLATABILITY) then
                    return incoming == curr_context
                end
                return mask == context_info.mask[curr_context]
            elseif type(context_type) == "string" then
                return context_info.room[curr_context] == curr_node.name
                    and (home == nil or context_info.home_rooms[home][curr_node.name] ~= nil)
            end
            return incoming == curr_context
        end

        local discovery_preinds
        if logic.type_info[curr_node.type].context ~= nil then
            -- In this case, we assume just the forgetting contexts for now (true or string type)
            -- We then lost the context info, so we just choose the earliest context that appears earlier in the sort
            -- We'll choose that context and then do the rest with that
            local earliest_context_ind = curr_ind
            local outgoing_context = curr_context
            -- With tie_rank, each possible context's latest prereq, for choosing among those as early as the earliest below
            local latest_of
            for _, context in pairs(context_info.list) do
                local preinds = false
                if transmits_curr_context(context) then
                    preinds = find_preinds(curr_node, context)
                end
                if preinds ~= false then
                    local latest_ind
                    for _, ind in pairs(preinds) do
                        if latest_ind == nil or ind > latest_ind then
                            latest_ind = ind
                        end
                    end
                    if latest_ind == nil then
                        if curr_node.op == "OR" then
                            -- This means no prereqs and it's an OR, so shouldn't have been found in the first place
                            -- Oh that's fine we just ignore the context
                        else
                            -- In this case, we're satisfiable immediately anyways due to having no prereqs, and the exact context doesn't matter
                            -- Give earliest_context_ind a 0 so that later sanity checks don't complain
                            earliest_context_ind = 0
                            curr_context = context
                            break
                        end
                    else
                        if tie_rank ~= nil and latest_ind < curr_ind then
                            latest_of = latest_of or {}
                            latest_of[context] = latest_ind
                        end
                        if latest_ind < earliest_context_ind then
                            earliest_context_ind = latest_ind
                            curr_context = context
                        end
                    end
                end
            end
            if latest_of ~= nil and earliest_context_ind ~= 0 and earliest_context_ind < curr_ind then
                local tied = tied_choice(graph, pebble_keys, latest_of, earliest_context_ind, curr_context, tie_rank)
                if tied ~= curr_context then
                    num_tie_moves = num_tie_moves + 1
                    curr_context = tied
                end
            end
            -- Isolatable contexts of techs can also come from discovering their space location (see discover_space_locations and discover_home_rooms in top.sort)
            -- Then the path goes through the tech itself in an earlier context (a home context of the location with home contexts) and an earlier pebble of a tech that unlocks the location
            if earliest_context_ind == curr_ind and context_info.complex and curr_node.type == "technology" then
                room_discoverers = room_discoverers or top.room_discoverers(graph)
                discovery_preinds = find_discovery_preinds(sort_info, room_discoverers, curr_node, outgoing_context, curr_ind)
            end
            -- If nothing was earlier, that's a contradiction
            if earliest_context_ind == curr_ind and discovery_preinds == nil then
                log(serpent.block(curr_node))
                log(ctx.name(outgoing_context))
                error("No earlier contexts possible.")
            end
        end

        -- Now, either way, we go from curr_context
        local preinds = discovery_preinds or find_preinds(curr_node, curr_context)
        -- preinds should always be valid by here
        if preinds == false then
            log(curr_key .. " @ " .. ctx.name(curr_context))
            error()
        end
        if path_ind == 1 or not stop_if(curr_key, curr_context) then
            if chosen ~= nil then
                chosen[curr_ind] = preinds
            end
            for _, ind in pairs(preinds) do
                if not in_path[ind] then
                    in_path[ind] = true
                    table.insert(path, ind)
                end
            end
        end

        path_ind = path_ind + 1
    end

    return {
        path = path,
        in_path = in_path,
        chosen = chosen,
        preferred = preferred,
        num_tie_moves = num_tie_moves,
    }
end

-- Trims unnecessary contexts out of state's sorted list, starting from the back
-- Might not be necessary with top.path now
top.trim = function(graph, state)
    -- TODO
end

return top

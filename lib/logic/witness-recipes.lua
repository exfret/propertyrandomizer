-- The recipes a pebble directly needs, for giving rebuilt techs their prerequisites (randomizations.rebuild_tech_tree in randomizations/fixes.lua)
-- These are the recipes on its witness that get a tech, not looking past them, since that tech's own prerequisites cover what they need
-- The witness goes on through a recipe that gets no tech, since no tech's prerequisites would carry what that recipe needs
-- Like a machine's fixed recipe (enabled in randomizations/prefixes.lua): the captive spawner's burns bioflux, and stopping there left a recipe needing its biter eggs a tech without prerequisites

local top = require("lib/graph/context-sort")
local gutils = require("lib/graph/graph-utils")

local witness_recipes = {}

-- How many times to drop preferred choices that didn't work out before giving up on preferring (see witness_recipes.of)
local MAX_ROUNDS = 10

-- Ability strings with isolatability, for looking up a node's isolatable contexts in a room directly
local isolatable_strs = {}
for _, ability_str in pairs(top.ability_strs) do
    if string.sub(ability_str, top.ISOLATABILITY, top.ISOLATABILITY) == "1" then
        table.insert(isolatable_strs, ability_str)
    end
end

-- When node_key can first be had in room from the room's own resources in local_sort_info, a sort with complex contexts, as an index in it, or nil if never (like top.isolatable_in, for one room)
local function isolatable_ind(local_sort_info, node_key, room)
    local contexts = local_sort_info.node_to_context_inds[node_key]
    if contexts == nil then
        return nil
    end
    local first
    for _, ability_str in pairs(isolatable_strs) do
        local ind = contexts[top.context_key(room, ability_str)]
        if ind ~= nil and (first == nil or ind < first) then
            first = ind
        end
    end
    return first
end

-- The choices of later pebbles on loops of a path's choices (from top.path with prefer), as OR pebble --> the pebble it chose
-- Only a choice of a later pebble can close a loop, since every other choice goes to an earlier pebble
local function loop_choices(chosen, root_ind)
    local found = {}
    local on_stack = {}
    local done = {}
    -- Iterative depth-first search: each frame is { ind, next position in chosen[ind] }
    local stack = { { root_ind, 1 } }
    on_stack[root_ind] = 1
    while #stack > 0 do
        local frame = stack[#stack]
        local ind = frame[1]
        local nexts = chosen[ind] or {}
        local next_ind = nexts[frame[2]]
        if next_ind == nil then
            on_stack[ind] = nil
            done[ind] = true
            table.remove(stack)
        else
            frame[2] = frame[2] + 1
            if on_stack[next_ind] ~= nil then
                -- A loop: everything on the stack from next_ind up to ind
                for i = on_stack[next_ind], #stack do
                    local loop_ind = stack[i][1]
                    for _, pre_ind in pairs(chosen[loop_ind] or {}) do
                        if pre_ind > loop_ind then
                            found[loop_ind] = pre_ind
                        end
                    end
                end
            elseif done[next_ind] == nil then
                table.insert(stack, { next_ind, 1 })
                on_stack[next_ind] = #stack
            end
        end
    end
    return found
end

-- The preferred choices of a path (from top.path with prefer) whose route doesn't stay in room on things the room can make from its own resources, as OR pebble --> the pebble it chose
-- Like an item the room makes itself only after the recipe at the root, so that preferring it took the room's earliest way of making it, recycling imported scrap
-- Only for choices that make no loop (see loop_choices), so the routes end
local function nonlocal_choices(path_info, sorted, room, local_sort_info)
    local chosen = path_info.chosen
    -- Pebble --> whether its route stays local, filled in children first
    local stays = {}
    local function check(start_ind)
        local stack = { { start_ind, 1 } }
        while #stack > 0 do
            local frame = stack[#stack]
            local ind = frame[1]
            local next_ind = (chosen[ind] or {})[frame[2]]
            if next_ind == nil then
                local pebble = sorted[ind]
                local ok = top.context_room(pebble.context) == room and isolatable_ind(local_sort_info, pebble.node_key, room) ~= nil
                for _, pre_ind in pairs(chosen[ind] or {}) do
                    ok = ok and stays[pre_ind]
                end
                stays[ind] = ok
                table.remove(stack)
            else
                frame[2] = frame[2] + 1
                if stays[next_ind] == nil then
                    table.insert(stack, { next_ind, 1 })
                end
            end
        end
    end
    local found = {}
    for chooser, choice in pairs(path_info.preferred) do
        check(choice)
        if stays[choice] == false then
            found[chooser] = choice
        end
    end
    return found
end

-- The names of the recipes the pebble at ind in sort_info directly needs, as a set; gets_tech(recipe_name) says whether a recipe gets a tech
-- With local_sort_info (a sort of the same graph with complex contexts), where the witness has a choice in the room of the pebble at ind, it takes what that room can make from its own resources, rather than what comes earliest
-- Like a planet's own version of a recipe over another planet's version the planet would have to import from, so a tech for a recipe made on one planet comes after that planet's recipes
-- Only that room: elsewhere (what an import or a tech's research needs) the earliest is still taken, since another room's own recipes are no closer to the recipe at ind (Fulgora's scrap recycling made casting on Vulcanus wait for it)
-- And only an option that can be the room's first own way of getting the choice's thing, so never one that needs that thing itself (like picking up a placed pipe to get a pipe)
-- That choice can come later than the earliest one, as long as it comes before the pebble at ind: then whatever the recipes need is reached before the recipe at ind, as without the preference
-- A later choice can need what it was chosen for (like a recipe that needs the item it makes), and then the witness isn't a way to get there; and its route can leave the room's own resources after all (see nonlocal_choices)
-- Such a choice is dropped, and the witness found again with the next option there
-- Counts go in stats if it's given: witnesses that took a room's own option over an earlier one somewhere (stats.preferred), that dropped a choice (stats.dropped), and that still had one to drop after MAX_ROUNDS and so took the earliest options everywhere (stats.gave_up)
witness_recipes.of = function(graph, sort_info, ind, gets_tech, local_sort_info, stats)
    local function has_tech(node_key)
        local node = graph.nodes[node_key]
        return node.type == "recipe" and gets_tech(node.name)
    end

    local params = {
        stop_if = function(pebble)
            return has_tech(pebble.node_key)
        end,
    }
    local path_info
    if local_sort_info ~= nil then
        local sorted = sort_info.sorted
        local room = top.context_room(sorted[ind].context)
        -- OR pebble --> its preferred choices that were dropped
        local banned = {}
        params.prefer = function(pre_ind, curr_ind)
            if top.context_room(sorted[curr_ind].context) ~= room then
                return false
            end
            if banned[curr_ind] ~= nil and banned[curr_ind][pre_ind] ~= nil then
                return false
            end
            local own_ind = isolatable_ind(local_sort_info, sorted[pre_ind].node_key, room)
            -- The choice's own first way comes from an option reached before it, and an option needing the choice's thing comes after it
            -- An edge can lose the room's own resources (like a delivery), so the choice may have no own way at all even when the option has one
            local choice_own_ind = isolatable_ind(local_sort_info, sorted[curr_ind].node_key, room)
            return own_ind ~= nil and choice_own_ind ~= nil and own_ind < choice_own_ind
        end
        params.prefer_before = ind
        for _ = 1, MAX_ROUNDS do
            path_info = top.path(graph, {ind}, sort_info, params)
            local choices = loop_choices(path_info.chosen, ind)
            if next(choices) == nil then
                choices = nonlocal_choices(path_info, sorted, room, local_sort_info)
            end
            if next(choices) == nil then
                break
            end
            for chooser, choice in pairs(choices) do
                banned[chooser] = banned[chooser] or {}
                banned[chooser][choice] = true
            end
            path_info = nil
        end
        if stats ~= nil then
            if next(banned) ~= nil then
                stats.dropped = (stats.dropped or 0) + 1
            end
            if path_info == nil then
                stats.gave_up = (stats.gave_up or 0) + 1
            elseif next(path_info.preferred) ~= nil then
                stats.preferred = (stats.preferred or 0) + 1
            end
        end
        if path_info == nil then
            params.prefer = nil
            params.prefer_before = nil
        end
    end
    if path_info == nil then
        path_info = top.path(graph, {ind}, sort_info, params)
    end
    local recipes = {}
    for other_ind, _ in pairs(path_info.in_path) do
        -- Don't count ind itself
        if other_ind < ind then
            local other_key = sort_info.sorted[other_ind].node_key
            if has_tech(other_key) then
                recipes[graph.nodes[other_key].name] = true
            end
        end
    end
    return recipes
end

-- Use the research method actually copied onto the rebuilt technology.
-- A recipe's earliest witness can use another unlocking technology or a fixed recipe instead.
-- Technology prerequisites have already been removed from this graph, leaving the recipes needed for the science packs or the research trigger itself.
witness_recipes.research = function(graph, sort_info, tech_name, gets_tech)
    local first
    for _, ind in pairs(sort_info.node_to_context_inds[gutils.key("technology", tech_name)] or {}) do
        if first == nil or ind < first then
            first = ind
        end
    end
    if first == nil then
        return nil
    end
    return witness_recipes.of(graph, sort_info, first, gets_tech)
end

-- Add a research witness only if its prerequisites preserve contexts and cannot lead back to the recipe being unlocked.
witness_recipes.extend = function(recipe_to_prev, recipe_name, requirements, covers)
    local function reaches(start, seen)
        if start == recipe_name then
            return true
        end
        if seen[start] ~= nil then
            return false
        end
        seen[start] = true
        for pre, _ in pairs(recipe_to_prev[start] or {}) do
            if reaches(pre, seen) then
                return true
            end
        end
        return false
    end
    for pre, _ in pairs(requirements) do
        if not covers(pre, recipe_name) or reaches(pre, {}) then
            return false
        end
    end
    for pre, _ in pairs(requirements) do
        recipe_to_prev[recipe_name][pre] = true
    end
    return true
end

return witness_recipes

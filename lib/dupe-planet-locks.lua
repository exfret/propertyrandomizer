-- Duplicates belong to their planet copies (setting propertyrandomizer-dupes; run from data-final-fixes.lua after lib/dupe-planets.lua and lib/dupe.lua)
-- Dupe number n goes with planet copy n, and an original with the original planets (user, 2026-09-30: "foundry dupe 2 is locked to planet dupe 2, that way a lot of things are still per-planet"; the original only on its original planet)
-- A duplicated recipe or entity whose original's surface conditions accept some planets but not all (a planet and its copies count as one, surface_sets.family_of) gets a home lock (locks.fix_home):
--   * the original accepts the original planets among those, and each duplicate the copies with its dupe number (surface_sets.copy_number)
--   * rooms that aren't planets (like space platforms) stay as they were
-- Planetary randomization's lock stage can still move a home lock, keeping its copy numbers (randomizations/planetary/locks.lua)
-- Left alone: what every planet accepts (an assembling machine, a heating tower), and science packs, whose copies lib/dupe-planets.lua locks itself
-- Checked with the logic graph: if a home lock makes something unreachable, every home lock goes and the duplicates stay usable on all copies

local dutils = require("lib/data-utils")
local gutils = require("lib/graph/graph-utils")
local surface_sets = require("lib/surface-sets")
local top = require("lib/graph/context-sort")
local new_logic = require("lib/logic/init")
local locks = require("randomizations/planetary/locks")

local dupe_planet_locks = {}

local function sorted_keys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

-- The recipe and technology nodes reachable in the current game, by a plain sort of the logic graph (also loads the lookups the locks need)
local function reachable_nodes()
    new_logic.build(true)
    local sort_info = top.sort(new_logic.graph)
    local reachable = {}
    for node_key, contexts in pairs(sort_info.node_to_context_inds or {}) do
        local node = new_logic.graph.nodes[node_key]
        if next(contexts) ~= nil and node ~= nil and (node.type == "recipe" or node.type == "technology") then
            reachable[node_key] = true
        end
    end
    return reachable
end

-- Whether a recipe makes a science pack (a lab input)
local function makes_science(recipe, lab_inputs)
    for _, result in pairs(recipe.results or {}) do
        if result.type == "item" and lab_inputs[result.name] ~= nil then
            return true
        end
    end
    return false
end

-- The duplicated recipes and entities, by original: target id of the original --> { kind, original, copies = dupe number --> prototype }
-- A duplicate is a prototype dupe.prototype made with a dupe number, which it records with its original's name (orig_name)
local function duplicated()
    local groups = {}
    local function add(kind, original, copy)
        local id = kind .. "/" .. original.name
        groups[id] = groups[id] or {
            kind = kind,
            original = original,
            copies = {},
        }
        groups[id].copies[copy.dupe_number] = copy
    end
    local lab_inputs = dutils.lab_inputs()
    for _, recipe in pairs(data.raw.recipe) do
        local original = data.raw.recipe[recipe.orig_name or ""]
        if type(recipe.dupe_number) == "number" and original ~= nil and not makes_science(original, lab_inputs) then
            add("recipe", original, recipe)
        end
    end
    for _, entity in pairs(dutils.get_all_prots("entity")) do
        local original = entity.orig_name ~= nil and dutils.get_prot("entity", entity.orig_name) or nil
        if type(entity.dupe_number) == "number" and original ~= nil then
            add("entity", original, entity)
        end
    end
    return groups
end

-- The rooms of accepted with this copy number, along with every accepted room that isn't a planet
local function rooms_of_copy(accepted, number)
    local rooms = {}
    for room_key, _ in pairs(accepted) do
        if gutils.deconstruct(room_key).type ~= "planet" or surface_sets.copy_number(room_key) == number then
            rooms[room_key] = true
        end
    end
    return rooms
end

local function size(set)
    local num = 0
    for _, _ in pairs(set) do
        num = num + 1
    end
    return num
end

dupe_planet_locks.execute = function()
    local before = reachable_nodes()
    local planet_families = {}
    for _, room_key in pairs(surface_sets.room_keys()) do
        if gutils.deconstruct(room_key).type == "planet" then
            planet_families[surface_sets.family_of(room_key)] = true
        end
    end
    local num_families = size(planet_families)

    local groups = duplicated()
    local homed = {}
    local names = {}
    for _, id in pairs(sorted_keys(groups)) do
        local group = groups[id]
        local accepted = surface_sets.accepted(group.original)
        local accepted_families = {}
        for room_key, _ in pairs(accepted) do
            if gutils.deconstruct(room_key).type == "planet" then
                accepted_families[surface_sets.family_of(room_key)] = true
            end
        end
        local num_accepted = size(accepted_families)
        if num_accepted > 0 and num_accepted < num_families and locks.fixed[id] == nil then
            local members = {
                [1] = group.original,
            }
            for number, copy in pairs(group.copies) do
                members[number] = copy
            end
            local is_homed = false
            for _, number in pairs(sorted_keys(members)) do
                local rooms = rooms_of_copy(accepted, number)
                local has_planet = false
                for room_key, _ in pairs(rooms) do
                    if gutils.deconstruct(room_key).type == "planet" then
                        has_planet = true
                    end
                end
                -- A copy number no accepted planet has (no planet was copied that often) leaves its member as it is
                if has_planet and size(rooms) < size(accepted) and locks.fixed[group.kind .. "/" .. members[number].name] == nil then
                    local target_id = locks.fix_home(group.kind, members[number].name, rooms)
                    if target_id ~= nil then
                        table.insert(homed, target_id)
                        is_homed = true
                    end
                end
            end
            if is_homed then
                table.insert(names, id)
            end
        end
    end
    if #homed == 0 then
        return
    end
    local unrealized = locks.realize()
    for _, target_id in pairs(unrealized) do
        log("Planet copies: no surface properties left for " .. target_id .. ", so it stays on all copies")
    end

    local after = reachable_nodes()
    local lost = {}
    for node_key, _ in pairs(before) do
        if after[node_key] == nil then
            table.insert(lost, node_key)
        end
    end
    table.sort(lost)
    if #lost > 0 then
        for _, target_id in pairs(homed) do
            local lock = locks.fixed[target_id]
            if lock ~= nil then
                locks.release(lock.kind, lock.name)
            end
        end
        locks.realize()
        log("Planet copies: locking the duplicates to their planet copies made " .. #lost .. " things unreachable (" .. table.concat(lost, ", ", 1, math.min(#lost, 10)) .. "), so they stay on all copies")
        return
    end
    log("Planet copies: " .. #homed .. " home locks for " .. #names .. " duplicated recipes and entities, each version on its own copy of the planets (" .. table.concat(names, ", ") .. ")")
end

return dupe_planet_locks

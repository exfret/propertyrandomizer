-- Planet locks (setting propertyrandomizer-planetary-locks)
-- A lock is the set of rooms (planets and surfaces) whose surface properties a recipe's or entity's surface conditions accept
-- This stage chooses new sets, then gives each moved recipe or entity conditions for exactly its set (lib/surface-sets.lua), replacing its old ones; it never reasons about conditions themselves
-- The planets of a lock other than the starting planet are redrawn among the planets other than the starting planet, as many as before; the starting planet and surfaces (like space platforms) keep their places in it
-- Science packs (lab inputs) keep their locks, since each planet makes its own science
-- A moved recipe's goals follow it (check.transport): on its new planet it must be automatable, imports allowed
-- What a planet must keep otherwise (its science, planet-locked recipes that didn't move, mechanics) stays where it was, so a lock can get its old planet back as well (widening), or its old set back (reverting)

local constants = require("helper-tables/constants")
local dutils = require("lib/data-utils")
local gutils = require("lib/graph/graph-utils")
local locale_utils = require("lib/locale")
local rng = require("lib/random/rng")
local surface_sets = require("lib/surface-sets")

local locks = {}

local function sorted_keys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

local function copy_set(set)
    local copy = {}
    for key, _ in pairs(set) do
        copy[key] = true
    end
    return copy
end

local function same_set(a, b)
    for key, _ in pairs(a) do
        if b[key] == nil then
            return false
        end
    end
    for key, _ in pairs(b) do
        if a[key] == nil then
            return false
        end
    end
    return true
end

-- Target id --> moved lock:
--   * kind ("recipe" or "entity") and name
--   * node_key: the logic node whose in-edges from rooms are the lock (recipe-surface-condition or entity-build-surface-condition)
--   * original: the prototype's surface conditions before this stage, and original_description its localised_description
--   * old: rooms that accepted it before, and new: rooms drawn for it
--   * map: old room --> new room, for each old planet that isn't in the new set (which new planet took its place)
--   * rooms: rooms that accept it now (new, plus whatever widening gave back)
locks.moved = {}
-- Target id --> fixed lock, in the same form: a lock given exactly these rooms on purpose (a planet copy's science packs, see lib/dupe-planets.lua)
-- Fixed locks are realized together with the moved ones, but never drawn again, transported, reverted or forgotten with them
locks.fixed = {}

local function prototype_of(lock)
    if lock.kind == "recipe" then
        return data.raw.recipe[lock.name]
    end
    return dutils.get_prot("entity", lock.name)
end

-- Planets whose place in locks can change: every planet but the starting one, as room keys
local function movable_planets()
    local planets = {}
    for _, room_key in pairs(surface_sets.room_keys()) do
        local room = gutils.deconstruct(room_key)
        if room.type == "planet" and room.name ~= constants.starting_planet then
            planets[room_key] = true
        end
    end
    return planets
end

-- Recipes and entities whose lock can move: they have surface conditions, aren't science packs, and accept some but not all movable planets
-- Returns a list of { id, kind, name, node_key, accepted } sorted by id
locks.candidates = function()
    local planets = movable_planets()
    local num_planets = 0
    for _, _ in pairs(planets) do
        num_planets = num_planets + 1
    end
    local lab_inputs = dutils.lab_inputs()
    local candidates = {}
    local function consider(kind, prototype, node_type)
        if prototype.hidden or prototype.surface_conditions == nil or next(prototype.surface_conditions) == nil then
            return
        end
        if locks.fixed[kind .. "/" .. prototype.name] ~= nil then
            return
        end
        local accepted = surface_sets.accepted(prototype)
        local num_movable = 0
        for room_key, _ in pairs(accepted) do
            if planets[room_key] ~= nil then
                num_movable = num_movable + 1
            end
        end
        if num_movable == 0 or num_movable == num_planets then
            return
        end
        table.insert(candidates, {
            id = kind .. "/" .. prototype.name,
            kind = kind,
            name = prototype.name,
            node_key = gutils.key(node_type, prototype.name),
            accepted = accepted,
        })
    end
    for _, recipe in pairs(data.raw.recipe) do
        local makes_science = false
        for _, result in pairs(recipe.results or {}) do
            if result.type == "item" and lab_inputs[result.name] ~= nil then
                makes_science = true
            end
        end
        if not makes_science then
            consider("recipe", recipe, "recipe-surface-condition")
        end
    end
    for _, entity in pairs(dutils.get_all_prots("entity")) do
        consider("entity", entity, "entity-build-surface-condition")
    end
    table.sort(candidates, function(a, b)
        return a.id < b.id
    end)
    return candidates
end

-- Draws a new set for each candidate: its movable planets are replaced by as many random movable planets, different ones if it can
-- Returns target id --> moved lock (see locks.moved), without changing the game
locks.draw = function(candidates, id)
    local key = rng.key({ id = id })
    local movable = movable_planets()
    local planets = sorted_keys(movable)
    local drawn = {}
    for _, candidate in pairs(candidates) do
        local old_movable = {}
        local fixed = {}
        for room_key, _ in pairs(candidate.accepted) do
            if movable[room_key] ~= nil then
                old_movable[room_key] = true
            else
                fixed[room_key] = true
            end
        end
        local num = #sorted_keys(old_movable)
        local new_movable
        -- A few tries for a set that isn't the old one; the last draw is kept either way
        for _ = 1, 10 do
            local shuffled = table.deepcopy(planets)
            rng.shuffle(key, shuffled)
            new_movable = {}
            for i = 1, num do
                new_movable[shuffled[i]] = true
            end
            if not same_set(new_movable, old_movable) then
                break
            end
        end
        -- Which new planet takes each old planet's place: planets in both stay, and the rest pair up at random
        local leaving = {}
        local arriving = {}
        for _, room_key in pairs(sorted_keys(old_movable)) do
            if new_movable[room_key] == nil then
                table.insert(leaving, room_key)
            end
        end
        for _, room_key in pairs(sorted_keys(new_movable)) do
            if old_movable[room_key] == nil then
                table.insert(arriving, room_key)
            end
        end
        rng.shuffle(key, arriving)
        local map = {}
        for i, room_key in pairs(leaving) do
            map[room_key] = arriving[i]
        end
        local new = copy_set(fixed)
        for room_key, _ in pairs(new_movable) do
            new[room_key] = true
        end
        if next(map) ~= nil then
            local prototype = prototype_of(candidate)
            drawn[candidate.id] = {
                kind = candidate.kind,
                name = candidate.name,
                node_key = candidate.node_key,
                original = table.deepcopy(prototype.surface_conditions),
                original_description = table.deepcopy(prototype.localised_description),
                old = copy_set(candidate.accepted),
                new = new,
                map = map,
                rooms = copy_set(new),
            }
        end
    end
    return drawn
end

-- A description line naming the rooms a lock accepts, like "Works only on: [planet=gleba] [planet=vulcanus]"
local function rooms_text(rooms)
    local text = { "" }
    for _, room_key in pairs(sorted_keys(rooms)) do
        local room = gutils.deconstruct(room_key)
        if #text > 1 then
            table.insert(text, " ")
        end
        if room.type == "planet" then
            table.insert(text, "[planet=" .. room.name .. "]")
        else
            table.insert(text, {
                "?",
                {
                    room.type .. "-name." .. room.name,
                },
                room.name,
            })
        end
    end
    return text
end

-- Puts every moved and fixed lock's current rooms in the game: new surface properties for all of them (lib/surface-sets.lua), their conditions, and their description lines
-- A lock the planner couldn't realize (the pool of new properties ran out) goes back to its original conditions
-- Returns the ids of locks that went back
locks.realize = function()
    local lists = {
        locks.moved,
        locks.fixed,
    }
    local requests = {}
    for _, list in pairs(lists) do
        for _, id in pairs(sorted_keys(list)) do
            if prototype_of(list[id]) ~= nil then
                table.insert(requests, {
                    id = id,
                    rooms = list[id].rooms,
                })
            end
        end
    end
    local plan = surface_sets.plan(requests, surface_sets.room_keys(), surface_sets.POOL)
    surface_sets.apply_properties(plan, surface_sets.POOL)
    local unrealized = {}
    for _, id in pairs(plan.unrealized) do
        unrealized[id] = true
    end
    for _, list in pairs(lists) do
        for _, id in pairs(sorted_keys(list)) do
            local lock = list[id]
            local prototype = prototype_of(lock)
            if prototype == nil then
                -- The prototype is gone (data.raw was put back to a state from before it, like a scaffold variant after a rolled-again ocean swap), so the lock is forgotten
                list[id] = nil
            elseif unrealized[id] ~= nil then
                prototype.surface_conditions = table.deepcopy(lock.original)
                prototype.localised_description = table.deepcopy(lock.original_description)
                list[id] = nil
            else
                local conditions = plan.conditions[id]
                if next(conditions) == nil then
                    prototype.surface_conditions = nil
                else
                    prototype.surface_conditions = conditions
                end
                -- The description line goes after the original description (found from its locale key if the prototype had none of its own)
                prototype.localised_description = table.deepcopy(lock.original_description)
                prototype.localised_description = {
                    "",
                    locale_utils.find_localised_description(prototype, {
                        with_newline = true,
                    }),
                    {
                        "propertyrandomizer.planet_lock",
                        rooms_text(lock.rooms),
                    },
                }
            end
        end
    end
    return sorted_keys(unrealized)
end

-- Moves locks: draws new sets for every candidate that hasn't moved yet (another stage may have moved some on purpose, see locks.move) and puts them in the game
-- kept_recipes (recipe name --> true, optional) keep their locks, like planet variants another stage made for one planet on purpose (scaffolds.lua)
-- Returns the moved locks (target id --> lock, also locks.moved)
locks.execute = function(id, kept_recipes)
    kept_recipes = kept_recipes or {}
    local candidates = {}
    for _, candidate in pairs(locks.candidates()) do
        if locks.moved[candidate.id] == nil and not (candidate.kind == "recipe" and kept_recipes[candidate.name] ~= nil) then
            table.insert(candidates, candidate)
        end
    end
    for target_id, lock in pairs(locks.draw(candidates, id)) do
        locks.moved[target_id] = lock
    end
    local unrealized = locks.realize()
    for _, target_id in pairs(unrealized) do
        log("Planet locks: no surface properties left for " .. target_id .. ", so it keeps its old lock")
    end
    return locks.moved
end

-- Moves one lock on purpose, for a group that moves together (like what builds lightning attractors following lightning, see lightning.lua)
-- The kind is "recipe" or "entity", and each room the prototype accepts now that's in map (old room --> new room) is replaced by where it goes
-- Returns the lock's target id, or nil if it accepts no room in map
locks.move = function(kind, name, map)
    local prototype
    local node_type
    if kind == "recipe" then
        prototype = data.raw.recipe[name]
        node_type = "recipe-surface-condition"
    else
        prototype = dutils.get_prot("entity", name)
        node_type = "entity-build-surface-condition"
    end
    -- Only a prototype with surface conditions has a lock (like the lightning collector's recipe, not its recycling recipe, which gives a rod back)
    if prototype == nil or prototype.surface_conditions == nil or next(prototype.surface_conditions) == nil then
        return nil
    end
    local target_id = kind .. "/" .. name
    local accepted = surface_sets.accepted(prototype)
    local new = {}
    local used_map = {}
    for room_key, _ in pairs(accepted) do
        if map[room_key] ~= nil then
            new[map[room_key]] = true
            used_map[room_key] = map[room_key]
        else
            new[room_key] = true
        end
    end
    if next(used_map) == nil or locks.moved[target_id] ~= nil then
        return nil
    end
    locks.moved[target_id] = {
        kind = kind,
        name = name,
        node_key = gutils.key(node_type, name),
        original = table.deepcopy(prototype.surface_conditions),
        original_description = table.deepcopy(prototype.localised_description),
        old = accepted,
        new = new,
        map = used_map,
        rooms = copy_set(new),
    }
    locks.realize()
    return target_id
end

-- Fixes a lock to exactly these rooms on purpose (a planet copy's science pack recipes, see lib/dupe-planets.lua): every later realize keeps it, and it's never drawn, transported or reverted
-- The kind is "recipe" or "entity"; the prototype needn't have surface conditions yet (a starting planet's science pack has none)
-- Doesn't realize, so a caller can fix several locks and realize once (locks.realize needs the logic's lookups loaded)
-- Returns the lock's target id, or nil if there's no such prototype
locks.fix = function(kind, name, rooms)
    local prototype
    local node_type
    if kind == "recipe" then
        prototype = data.raw.recipe[name]
        node_type = "recipe-surface-condition"
    else
        prototype = dutils.get_prot("entity", name)
        node_type = "entity-build-surface-condition"
    end
    if prototype == nil then
        return nil
    end
    local target_id = kind .. "/" .. name
    locks.fixed[target_id] = {
        kind = kind,
        name = name,
        node_key = gutils.key(node_type, name),
        original = table.deepcopy(prototype.surface_conditions or {}),
        original_description = table.deepcopy(prototype.localised_description),
        old = copy_set(rooms),
        new = copy_set(rooms),
        map = {},
        rooms = copy_set(rooms),
    }
    return target_id
end

-- Forgets a fixed lock (the prototype keeps whatever conditions it has until the next realize, which no longer plans for it)
locks.unfix = function(kind, name)
    locks.fixed[kind .. "/" .. name] = nil
end

-- Gives a moved lock these rooms and puts every lock in the game again (other locks' conditions may change, but not their rooms)
locks.set_rooms = function(target_id, rooms)
    locks.moved[target_id].rooms = copy_set(rooms)
    locks.realize()
end

-- Gives a moved lock its old rooms back as well as its new ones
locks.widen = function(target_id, extra_rooms)
    local rooms = copy_set(locks.moved[target_id].rooms)
    for room_key, _ in pairs(extra_rooms) do
        rooms[room_key] = true
    end
    locks.set_rooms(target_id, rooms)
end

-- Puts locks back as they were (target ids), and forgets they moved
-- Returns the moved locks it forgot, target id --> lock, so locks.restore can bring them back
locks.revert = function(target_ids)
    local reverted = {}
    for _, target_id in pairs(target_ids) do
        local lock = locks.moved[target_id]
        if lock ~= nil then
            local prototype = prototype_of(lock)
            prototype.surface_conditions = table.deepcopy(lock.original)
            prototype.localised_description = table.deepcopy(lock.original_description)
            reverted[target_id] = lock
            locks.moved[target_id] = nil
        end
    end
    locks.realize()
    return reverted
end

-- Moves locks that locks.revert put back again
locks.restore = function(reverted)
    for target_id, lock in pairs(reverted) do
        locks.moved[target_id] = lock
    end
    locks.realize()
end

-- Where the goals of moved locks go, as check.transport entries: node key --> { map = old room --> new room }
-- Only recipes have goals of their own in a room (planet-locked recipes keep their contexts, rule 2 of check.required), and they may use imports on their new planet, so they don't keep isolatability
locks.transport = function()
    local transport = {}
    for _, lock in pairs(locks.moved) do
        if lock.kind == "recipe" then
            transport[gutils.key("recipe", lock.name)] = {
                map = table.deepcopy(lock.map),
            }
        end
    end
    return transport
end

-- The moved lock (and its id) whose rooms a logic node's in-edges from rooms are, or nil
locks.lock_of_node = function(node_key)
    for id, lock in pairs(locks.moved) do
        if lock.node_key == node_key then
            return lock, id
        end
    end
    return nil
end

-- The moved lock (and its id) of a recipe, by the recipe's logic node key, or nil
locks.lock_of_recipe = function(recipe_key)
    for id, lock in pairs(locks.moved) do
        if lock.kind == "recipe" and gutils.key("recipe", lock.name) == recipe_key then
            return lock, id
        end
    end
    return nil
end

-- One line per moved or fixed lock for the log
locks.describe = function(target_id)
    local lock = locks.moved[target_id] or locks.fixed[target_id]
    local function names(rooms)
        local list = {}
        for _, room_key in pairs(sorted_keys(rooms)) do
            table.insert(list, gutils.deconstruct(room_key).name)
        end
        return "{" .. table.concat(list, ", ") .. "}"
    end
    local conditions = {}
    for _, condition in pairs(prototype_of(lock).surface_conditions or {}) do
        table.insert(conditions, condition.property .. " " .. tostring(condition.min) .. ".." .. tostring(condition.max))
    end
    return target_id .. ": " .. names(lock.old) .. " --> " .. names(lock.rooms) .. " (" .. table.concat(conditions, ", ") .. ")"
end

return locks

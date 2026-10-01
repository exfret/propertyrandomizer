-- Planetary lightning moves (setting propertyrandomizer-planetary-lightning)
-- Lightning (a planet's lightning_properties) trades places among the planets other than the starting planet, so a planet with lightning gives it to one without
-- It moves as a group with what builds lightning attractors: their recipes' planet locks (locks.lua) follow it, and so do their unlocks in the technologies discovering the planet
-- That way the planet lightning moves to can protect its buildings (lightning-safe, see lib/logic/abstract.lua) and use its power
-- Lightning power (logic nodes built with planetary_feature = "lightning") follows lightning: on its new planet it must be automatable, imports allowed (check.transport)
-- Every planet still must be safe from lightning and make electricity where it could (rule 3 of the planetary check), so a planet losing lightning needs other power, or else keeps its lightning as well (lightning.keep_old)
-- Other power may start from delivered buildings the planet can then make itself (user, 2026-09-30): the logic counts operating them there as local (lightning.lost_rooms, lib/logic/bootstrap.lua), like Fulgora starting from a recycler and solar panels, whose scrap then makes more of both

local constants = require("helper-tables/constants")
local dutils = require("lib/data-utils")
local gutils = require("lib/graph/graph-utils")
local rng = require("lib/random/rng")
local locks = require("randomizations/planetary/locks")
local lutils = require("lib/logic/logic-utils")

local lightning = {}

local function sorted_keys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

local function planet_room(planet_name)
    return gutils.key("planet", planet_name)
end

-- Names of the planets other than the starting planet, sorted
local function movable_planets()
    local names = {}
    for name, _ in pairs(data.raw.planet or {}) do
        if name ~= constants.starting_planet then
            table.insert(names, name)
        end
    end
    table.sort(names)
    return names
end

-- Why lightning can't move, or nil if it can
lightning.problem = function()
    local num_with = 0
    local num_without = 0
    for _, name in pairs(movable_planets()) do
        if data.raw.planet[name].lightning_properties ~= nil then
            num_with = num_with + 1
        else
            num_without = num_without + 1
        end
    end
    if num_with == 0 then
        return "no planet but the starting planet has lightning"
    end
    if num_without == 0 then
        return "every planet but the starting planet has lightning"
    end
    return nil
end

-- Names of recipes making an item that places a lightning attractor (like the lightning rod and collector), sorted
local function attractor_recipes()
    local attractor_items = {}
    for _, item in pairs(dutils.get_all_prots("item")) do
        if item.place_result ~= nil and (data.raw["lightning-attractor"] or {})[item.place_result] ~= nil then
            attractor_items[item.name] = true
        end
    end
    local names = {}
    for _, recipe in pairs(data.raw.recipe) do
        for _, result in pairs(recipe.results or {}) do
            if result.type == "item" and attractor_items[result.name] ~= nil then
                names[recipe.name] = true
            end
        end
    end
    return sorted_keys(names)
end

-- Names of technologies that discover a planet (an unlock-space-location effect for it), sorted
local function discoverers(planet_name)
    local names = {}
    for _, tech in pairs(data.raw.technology) do
        for _, effect in pairs(tech.effects or {}) do
            if effect.type == "unlock-space-location" and effect.space_location == planet_name then
                names[tech.name] = true
            end
        end
    end
    return sorted_keys(names)
end

-- The last move, for lightning.keep_old and lightning.revert:
--   * map: old planet room --> new planet room
--   * old_properties: planet name --> its lightning_properties before the move (nil entries for planets without)
--   * lock_ids: target ids of the attractor recipes' moved locks
--   * unlocks: list of { recipe, from (technology name), to (technology name) } for attractor recipe unlocks moved between discovery technologies
lightning.last = nil

local function remove_unlock(tech, recipe_name)
    for i = #(tech.effects or {}), 1, -1 do
        local effect = tech.effects[i]
        if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
            table.remove(tech.effects, i)
        end
    end
end

local function add_unlock(tech, recipe_name)
    tech.effects = tech.effects or {}
    for _, effect in pairs(tech.effects) do
        if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
            return
        end
    end
    table.insert(tech.effects, {
        type = "unlock-recipe",
        recipe = recipe_name,
    })
end

-- Moves lightning among the planets other than the starting planet, with its group (see the top of this file)
-- Returns the map of where it went (old planet room --> new planet room), empty if it didn't move
lightning.execute = function(id)
    local key = rng.key({ id = id })
    local planets = movable_planets()
    local old_properties = {}
    local properties = {}
    for i, name in pairs(planets) do
        properties[i] = data.raw.planet[name].lightning_properties
        old_properties[name] = table.deepcopy(properties[i])
    end
    -- Planet i gets planet order[i]'s lightning; a few tries for an order where every planet with lightning gives it away, the last one is kept either way
    local order = {}
    for i = 1, #planets do
        order[i] = i
    end
    for _ = 1, 20 do
        rng.shuffle(key, order)
        local moves_all = true
        for i, j in pairs(order) do
            if properties[j] ~= nil and i == j then
                moves_all = false
            end
        end
        if moves_all then
            break
        end
    end
    local map = {}
    for i, j in pairs(order) do
        if properties[j] ~= nil and i ~= j then
            map[planet_room(planets[j])] = planet_room(planets[i])
        end
    end
    for i, name in pairs(planets) do
        data.raw.planet[name].lightning_properties = table.deepcopy(properties[order[i]])
    end

    -- What builds attractors follows: its locks, and its unlocks from the old planet's discovery to the new one's
    local lock_ids = {}
    local unlocks = {}
    for _, recipe_name in pairs(attractor_recipes()) do
        local lock_id = locks.move("recipe", recipe_name, map)
        if lock_id ~= nil then
            table.insert(lock_ids, lock_id)
        end
        for old_room, new_room in pairs(map) do
            local to = discoverers(gutils.deconstruct(new_room).name)[1]
            if to ~= nil then
                for _, from in pairs(discoverers(gutils.deconstruct(old_room).name)) do
                    local tech = data.raw.technology[from]
                    local unlocks_it = false
                    for _, effect in pairs(tech.effects or {}) do
                        if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
                            unlocks_it = true
                        end
                    end
                    if unlocks_it then
                        remove_unlock(tech, recipe_name)
                        add_unlock(data.raw.technology[to], recipe_name)
                        table.insert(unlocks, {
                            recipe = recipe_name,
                            from = from,
                            to = to,
                        })
                    end
                end
            end
        end
    end
    lightning.last = {
        map = map,
        old_properties = old_properties,
        lock_ids = lock_ids,
        unlocks = unlocks,
    }
    return map
end

-- Check transport entries (see check.transport) for lightning power, the nodes of graph built with planetary_feature = "lightning": node key --> { map }
lightning.transport = function(graph, map)
    local transport = {}
    for node_key, node in pairs(graph.nodes) do
        if node.planetary_feature == "lightning" then
            transport[node_key] = {
                map = table.deepcopy(map),
            }
        end
    end
    return transport
end

-- A smaller repair: what builds attractors is accepted again where lightning was, as well as where it went (lightning itself stays moved)
-- Like on Aquilo, a planet that gets lightning may not be able to make its own attractors (its buildings need both warmth and an attractor, and crafting there needs warmth), so it gets them made elsewhere
lightning.widen_locks = function()
    local last = lightning.last
    local old_rooms = {}
    for old_room, _ in pairs(last.map) do
        old_rooms[old_room] = true
    end
    for _, lock_id in pairs(last.lock_ids) do
        if locks.moved[lock_id] ~= nil then
            locks.widen(lock_id, old_rooms)
        end
    end
end

-- The addition: each planet that gave its lightning away has it again as well, its attractor recipes accept it again, and their unlocks are back in its discovery (they stay in the new planet's too)
lightning.keep_old = function()
    local last = lightning.last
    if last.kept_old then
        return
    end
    last.kept_old = true
    for old_room, _ in pairs(last.map) do
        local name = gutils.deconstruct(old_room).name
        data.raw.planet[name].lightning_properties = table.deepcopy(last.old_properties[name])
        for _, lock_id in pairs(last.lock_ids) do
            if locks.moved[lock_id] ~= nil then
                locks.widen(lock_id, {
                    [old_room] = true,
                })
            end
        end
    end
    for _, unlock in pairs(last.unlocks) do
        add_unlock(data.raw.technology[unlock.from], unlock.recipe)
    end
end

-- Undoes lightning.keep_old
lightning.give_away_again = function()
    local last = lightning.last
    if not last.kept_old then
        return
    end
    last.kept_old = false
    for old_room, _ in pairs(last.map) do
        local name = gutils.deconstruct(old_room).name
        local gets = nil
        for from_room, to_room in pairs(last.map) do
            if to_room == old_room then
                gets = gutils.deconstruct(from_room).name
            end
        end
        data.raw.planet[name].lightning_properties = table.deepcopy(gets ~= nil and last.old_properties[gets] or nil)
        for _, lock_id in pairs(last.lock_ids) do
            local lock = locks.moved[lock_id]
            if lock ~= nil then
                local rooms = {}
                for room_key, _ in pairs(lock.rooms) do
                    if room_key ~= old_room then
                        rooms[room_key] = true
                    end
                end
                locks.set_rooms(lock_id, rooms)
            end
        end
    end
    for _, unlock in pairs(last.unlocks) do
        remove_unlock(data.raw.technology[unlock.from], unlock.recipe)
    end
end

-- Puts everything the last move changed back: lightning, the attractor recipes' locks and their unlocks
lightning.revert = function()
    local last = lightning.last
    for name, properties in pairs(last.old_properties) do
        data.raw.planet[name].lightning_properties = table.deepcopy(properties)
    end
    for name, _ in pairs(data.raw.planet) do
        if last.old_properties[name] == nil and name ~= constants.starting_planet then
            data.raw.planet[name].lightning_properties = nil
        end
    end
    locks.revert(last.lock_ids)
    for _, unlock in pairs(last.unlocks) do
        remove_unlock(data.raw.technology[unlock.to], unlock.recipe)
        add_unlock(data.raw.technology[unlock.from], unlock.recipe)
    end
end

-- The planets the last move left without the lightning they had, as room key --> true, in the game as it is now (none after lightning.keep_old or lightning.revert, or once the game is put back)
-- The logic lets them start from delivered buildings they can then make themselves (lutils.lightning_lost_rooms, lib/logic/bootstrap.lua), since lightning was their power
lightning.lost_rooms = function()
    local rooms = {}
    if lightning.last == nil then
        return rooms
    end
    for name, _ in pairs(lightning.last.old_properties) do
        local planet = data.raw.planet[name]
        if planet ~= nil and planet.lightning_properties == nil then
            rooms[planet_room(name)] = true
        end
    end
    return rooms
end
lutils.lightning_lost_rooms = lightning.lost_rooms

-- One line for the log
lightning.describe = function()
    local parts = {}
    for _, old_room in pairs(sorted_keys(lightning.last.map)) do
        table.insert(parts, gutils.deconstruct(old_room).name .. " --> " .. gutils.deconstruct(lightning.last.map[old_room]).name)
    end
    local moved_unlocks = {}
    for _, unlock in pairs(lightning.last.unlocks) do
        table.insert(moved_unlocks, unlock.recipe .. " (" .. unlock.from .. " --> " .. unlock.to .. ")")
    end
    return table.concat(parts, ", ") .. "; unlocks moved: " .. (#moved_unlocks > 0 and table.concat(moved_unlocks, ", ") or "none")
end

return lightning

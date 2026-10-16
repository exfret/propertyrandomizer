-- Death-slot eligibility and bounded payload measurements shared by graph construction and reflection.
local categories = require("src/prototypes/categories")
local gutils = require("src/lib/graph/graph-utils")
local dutils = require("src/prototypes/data-utils")
local military = require("src/randomizations/unified/military")
local ctx = require("src/logic/contexts/contexts")

local death = {}

death.creature = function(prototype)
    return prototype ~= nil and (prototype.ai_settings ~= nil or prototype.run_animation ~= nil or prototype.spider_engine ~= nil or prototype.segment_engine ~= nil)
end

death.host = function(prototype, lookups, kept)
    if prototype.hidden or categories.without_health[prototype.type] or prototype.max_health == 0 then return false end
    if prototype.type == "asteroid" then return true end
    if config.entity_biters and ((death.creature(prototype) and lookups.buildables[gutils.key("entity", prototype.name)] == nil) or (prototype.autoplace and prototype.autoplace.force == "enemy")) then return true end
    return prototype.autoplace ~= nil and (prototype.autoplace.force or "neutral") == "neutral"
        and prototype.minable ~= nil and not kept[prototype.name]
        and lookups.buildables[gutils.key("entity", prototype.name)] == nil
end

-- Upper estimate per affected target, counting repeated and probabilistic effects at their maximum.
-- Cycles and unmeasured hazards return nil, never zero. Area is reported separately from target damage.
death.measure = function(trigger, lookup)
    local active, visited = {}, 0
    local walk
    walk = function(value)
        if type(value) ~= "table" then return 0, 0 end
        visited = visited + 1
        if active[value] or visited > 8192 then return nil end
        active[value] = true
        local amount, radius = 0, value.type == "area" and (value.radius or 0) or 0
        local kind = value.type
        if kind == "damage" then amount = math.max(0, value.damage.amount or 0) end
        if kind == "create-fire" or kind == "create-sticker" or kind == "create-smoke" then active[value] = nil; return nil end
        local reference = kind == "projectile" and value.projectile or kind == "stream" and value.stream or kind == "beam" and value.beam or nil
        if kind == "create-entity" or kind == "create-explosion" then reference = value.entity_name end
        if reference ~= nil then
            local prototype = lookup(reference)
            if prototype == nil or categories.without_health[prototype.type] == nil then active[value] = nil; return nil end
            local extra, area = walk({prototype.action, prototype.final_action, prototype.created_effect, prototype.initial_action, prototype.explosion_effect})
            if extra == nil then active[value] = nil; return nil end
            amount, radius = amount + extra, math.max(radius, area)
        end
        for _, child in pairs(value) do
            if type(child) == "table" then
                local extra, area = walk(child)
                if extra == nil then active[value] = nil; return nil end
                amount, radius = amount + extra, math.max(radius, area)
            end
        end
        active[value] = nil
        local repeats = (value.repeat_count or 1) + (value.repeat_count_deviation or 0)
        local offsets = value.offsets and #value.offsets or 1
        local clusters = kind == "cluster" and value.cluster_count or 1
        if kind == "cluster" then radius = radius + (value.distance or 0) + (value.distance_deviation or 0) end
        return amount * repeats * offsets * clusters, radius
    end
    return walk(trigger)
end

death.attack_damage = function(host, lookup)
    local attack = host and host.attack_parameters
    if attack == nil then return nil end
    return military.trigger_damage(attack.ammo_type, function(_, name) return lookup(name) end) * (attack.damage_modifier or 1)
end

death.payload_fits = function(host, action, lookup, local_budget, damage_modifier)
    local damage, radius = death.measure(action, lookup)
    if damage == nil then return false end
    local reference = death.attack_damage(host, lookup) or (local_budget and local_budget.damage) or 0
    -- A death burst can deal at most two ordinary hits; wide-area bursts also spend that budget.
    return damage * (damage_modifier or 1) * math.max(1, radius * radius / 9) <= reference * 2
end

death.acyclic = function(edges)
    local active, done = {}, {}
    local visit
    visit = function(name)
        if active[name] then return false end
        if done[name] then return true end
        active[name] = true
        for child, _ in pairs(edges[name] or {}) do
            if not visit(child) then return false end
        end
        active[name], done[name] = nil, true
        return true
    end
    for name, _ in pairs(edges) do if not visit(name) then return false end end
    return true
end

-- Compile collection and ordinary item delivery into the current graph before matching.
-- This source represents a portable reward; candidate validation checks the item's transport eligibility.
death.salvage_source = function(graph, host_name, collection_time)
    local key = gutils.key
    local name = "propertyrandomizer-salvage-" .. host_name
    local collected = gutils.add_node(graph, "asteroid-chunk-mine", name, {op = "AND", spoof = true})
    gutils.add_edge(graph, key("entity-kill", host_name), key(collected), {abilities = ctx.GAINS_AUTOMATABILITY})
    gutils.add_edge(graph, key("asteroid-collector", ""), key(collected), {amount = collection_time})
    local launch = gutils.add_node(graph, "item-launch", name, {op = "AND", spoof = true})
    local delivered = gutils.add_node(graph, "item-deliver", name, {op = "AND", spoof = true})
    local available = gutils.add_node(graph, "item", name, {op = "OR", spoof = true})
    gutils.add_edge(graph, key(collected), key(launch))
    gutils.add_edge(graph, key("deliver", ""), key(launch))
    gutils.add_edge(graph, key(launch), key(delivered))
    gutils.add_edge(graph, key("reachable-room", ""), key(delivered))
    gutils.add_edge(graph, key(collected), key(available))
    gutils.add_edge(graph, key(delivered), key(available), {abilities = ctx.LOSES_ISOLATABILITY})
    return available
end

-- Engine placeholder chunks can be hidden and have no world graphics.
death.salvage_template = function(chunks)
    local selected
    for name, chunk in pairs(chunks or {}) do
        if not chunk.hidden and chunk.graphics_set ~= nil and (selected == nil or name < selected.name) then
            selected = chunk
        end
    end
    return selected
end

death.salvage_chunk = function(template, name, item_name, icons)
    local chunk = table.deepcopy(template)
    chunk.name = name
    chunk.minable = {mining_time = 0.2, result = item_name}
    chunk.dying_trigger_effect = nil
    -- IconData uses a 32-pixel canvas; Sprite shifts use tiles (32 pixels per tile).
    local layers = {}
    for _, icon in pairs(icons) do
        local size = icon.icon_size or 64
        local shift = icon.shift or {}
        table.insert(layers, {
            filename = icon.icon,
            size = size,
            scale = icon.scale or 32 / size,
            shift = {(shift.x or shift[1] or 0) / 32, (shift.y or shift[2] or 0) / 32},
            tint = table.deepcopy(icon.tint),
        })
    end
    assert(#layers > 0, "Asteroid salvage requires an entity icon")
    chunk.graphics_set = {sprite = {layers = layers}}
    return chunk
end

death.append = function(prototype, effect)
    local previous = prototype.dying_trigger_effect
    if previous == nil then previous = {} elseif previous.type ~= nil then previous = {previous} end
    previous = table.deepcopy(previous)
    table.insert(previous, effect)
    prototype.dying_trigger_effect = previous
end

death.create = function(name)
    local prototype = dutils.get_prot("entity", name)
    return {
        type = "create-entity",
        entity_name = name,
        find_non_colliding_position = true,
        non_colliding_search_radius = 4,
        as_enemy = death.creature(prototype) or nil,
        ignore_no_enemies_mode = death.creature(prototype) or nil,
        show_in_tooltip = true,
    }
end

return death

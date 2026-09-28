-- Unit tests for entity acquisition in logic (see lib/logic/acquisition.lua), run from tests/execute.lua
-- Also logs an inventory of acquisition edges with the prefix ENTSTATS, which is what entity randomization has to work with

local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")
local acquisition = require("lib/logic/acquisition")
local cutils = require("lib/cost/cost-utils")
local dutils = require("lib/data-utils")

local key = gutils.key
local concat = gutils.concat

local test = {}

local function fail(message, object)
    if object ~= nil then
        log(serpent.block(object))
    end
    error("Entity acquisition test failed: " .. message)
end

local function count(tbl)
    local num = 0
    for _, _ in pairs(tbl) do
        num = num + 1
    end
    return num
end

-- Every edge into an entity node (or its entity-own node, for ways that make it ours) is a way of acquiring it
-- The exceptions link those nodes: entity-own --> entity, and entity-build --> entity-own, whose acquisition edges are the item edges into entity-build-item
local function is_acquisition_edge(graph, edge)
    local start_type = graph.nodes[edge.start].type
    local stop_type = graph.nodes[edge.stop].type
    if stop_type == "entity" then
        return start_type ~= "entity-own"
    end
    if stop_type == "entity-own" then
        return start_type ~= "entity-build"
    end
    return stop_type == "entity-build-item"
end

local function contexts_of(sort_info, node_key)
    return sort_info.node_to_context_inds[node_key] or {}
end

local function is_reachable(sort_info, node_key)
    return next(contexts_of(sort_info, node_key)) ~= nil
end

test.run = function(graph)
    -- Material-producing loot edges must carry yield, or pricing treats them as free capabilities.
    for item_name, sources in pairs(lookups.loot_to_entities) do
        local item = graph.nodes[key("item", item_name)]
        if item ~= nil then
            for entity_name, _ in pairs(sources) do
                local entity = dutils.get_prot("entity", entity_name)
                local expected = cutils.find_amount_in_ing_or_prod(entity.loot, { type = "item", name = item_name })
                local found = false
                for edge_key, _ in pairs(item.pre) do
                    local edge = graph.edges[edge_key]
                    if edge.start == key("entity-kill", entity_name) then
                        if edge.amount == nil or expected <= 0 or math.abs(edge.amount - expected) > 1e-9 then
                            fail("loot edge missing its expected output quantity", edge)
                        end
                        found = true
                    end
                end
                if not found then
                    fail("missing loot edge from " .. entity_name .. " to " .. item_name)
                end
            end
        end
    end
    -- Harvesting must retain the operating cost through the generic tower capability.
    local tower = graph.nodes[key("agricultural-tower", "")]
    if tower ~= nil then
        for edge_key, _ in pairs(tower.pre) do
            local edge = graph.edges[edge_key]
            if graph.nodes[edge.start].type == "entity-operate" and edge.amount ~= 1 then
                fail("agricultural tower operation is not included in harvest costs", edge)
            end
        end
    end

    -- Operating an entity needs it to be ours, not just present, since a machine found in the wild (neutral force) has to be mined and placed again
    for _, edge in pairs(graph.edges) do
        if graph.nodes[edge.stop].type == "entity-operate" and graph.nodes[edge.start].type == "entity" then
            fail("entity-operate depends on the entity being present rather than ours (entity-own)", edge)
        end
    end

    -- Every acquisition edge has a known kind, and no other edge has one
    local edges_by_kind = {}
    for kind, _ in pairs(acquisition.kinds) do
        edges_by_kind[kind] = {}
    end
    for _, edge in pairs(graph.edges) do
        if is_acquisition_edge(graph, edge) then
            if acquisition.kinds[edge.acq_kind] == nil then
                fail("acquisition edge without a known acq_kind", edge)
            end
            table.insert(edges_by_kind[edge.acq_kind], edge)
            -- Exactly the ways that make the entity ours are tagged ours, since entity randomization only gives an entity that has to be ours a slot that makes it ours (acquisition.pairing)
            if (graph.nodes[edge.stop].type == "entity-own") ~= (edge.ours ~= nil) then
                fail("acquisition edge whose ours tag doesn't match whether it goes into entity-own", edge)
            end
        elseif edge.acq_kind ~= nil then
            fail("acq_kind on an edge that isn't an acquisition edge", edge)
        end
    end

    local sort_info = top.sort(graph)

    -- Spawns at evolution 0 make their entity reachable wherever the spawner is, and spawns that need evolution are never reachable
    for spawner_name, spawns in pairs(lookups.unit_spawns) do
        for unit_name, spawn in pairs(spawns) do
            local spawn_key = key("entity-spawn", concat({spawner_name, unit_name}))
            if graph.nodes[spawn_key] == nil then
                fail("missing entity-spawn node", spawn)
            end
            if spawn.class == "late" then
                if is_reachable(sort_info, spawn_key) then
                    fail("spawn that needs evolution is reachable", spawn)
                end
            else
                for context, _ in pairs(contexts_of(sort_info, key("entity", spawner_name))) do
                    if contexts_of(sort_info, key("entity", unit_name))[context] == nil then
                        fail("spawned entity isn't reachable in its spawner's context " .. context, spawn)
                    end
                end
            end
        end
    end

    -- Hatching (spoil spawns) makes the entity reachable wherever the item is
    for item_name, entity_names in pairs(lookups.spoil_spawns) do
        for entity_name, _ in pairs(entity_names) do
            if graph.nodes[key("entity", entity_name)] ~= nil then
                for context, _ in pairs(contexts_of(sort_info, key("item", item_name))) do
                    if contexts_of(sort_info, key("entity", entity_name))[context] == nil then
                        fail("entity " .. entity_name .. " hatched from " .. item_name .. " isn't reachable in context " .. context)
                    end
                end
            end
        end
    end

    -- ENTSTATS: acquisition edges of each kind, and how many are usable (their start is reachable)
    local kinds = {}
    for kind, _ in pairs(acquisition.kinds) do
        table.insert(kinds, kind)
    end
    table.sort(kinds)
    local usable_kinds_of_entity = {}
    local usable_by_room = {}
    for _, kind in pairs(kinds) do
        local entities = {}
        local usable_entities = {}
        local num_usable = 0
        for _, edge in pairs(edges_by_kind[kind]) do
            -- The stop is an entity node, or for build, the entity-build-item node of the same name
            local entity_name = graph.nodes[edge.stop].name
            entities[entity_name] = true
            if is_reachable(sort_info, edge.start) then
                num_usable = num_usable + 1
                usable_entities[entity_name] = true
                usable_kinds_of_entity[entity_name] = usable_kinds_of_entity[entity_name] or {}
                usable_kinds_of_entity[entity_name][kind] = true
                for context, _ in pairs(contexts_of(sort_info, edge.start)) do
                    usable_by_room[context] = usable_by_room[context] or {}
                    usable_by_room[context][kind] = (usable_by_room[context][kind] or 0) + 1
                end
            end
        end
        log("ENTSTATS " .. kind .. ": " .. #edges_by_kind[kind] .. " edges (" .. num_usable .. " usable) for " .. count(entities) .. " entities (" .. count(usable_entities) .. " usable)")
    end

    local rooms = {}
    for room, _ in pairs(usable_by_room) do
        table.insert(rooms, room)
    end
    table.sort(rooms)
    for _, room in pairs(rooms) do
        local parts = {}
        for _, kind in pairs(kinds) do
            if usable_by_room[room][kind] ~= nil then
                table.insert(parts, kind .. " " .. usable_by_room[room][kind])
            end
        end
        log("ENTSTATS usable in " .. room .. ": " .. table.concat(parts, ", "))
    end

    local class_counts = {}
    for _, spawns in pairs(lookups.unit_spawns) do
        for _, spawn in pairs(spawns) do
            class_counts[spawn.class] = (class_counts[spawn.class] or 0) + 1
        end
    end
    log("ENTSTATS spawns by class: persistent " .. (class_counts.persistent or 0) .. ", transient " .. (class_counts.transient or 0) .. ", late " .. (class_counts.late or 0))

    -- Entities reachable only through spawning or hatching, i.e. the ones these edges newly model
    local only_spawned = {}
    for entity_name, entity_kinds in pairs(usable_kinds_of_entity) do
        local only_spawn_or_spoil = true
        for kind, _ in pairs(entity_kinds) do
            if kind ~= "spawn" and kind ~= "spoil" then
                only_spawn_or_spoil = false
            end
        end
        if only_spawn_or_spoil then
            table.insert(only_spawned, entity_name)
        end
    end
    table.sort(only_spawned)
    log("ENTSTATS reachable only by spawning or hatching (" .. #only_spawned .. "): " .. table.concat(only_spawned, ", "))
end

return test

-- Death-created entities and asteroid chunks in the legacy graph.
-- Read only death effects, not attacks/created effects elsewhere on the prototype.
local dying_spawns = {}

local function collect(effect, entities, chunks)
    if effect == nil then
        return
    end
    if effect.type == nil then
        for _, entry in pairs(effect) do
            collect(entry, entities, chunks)
        end
        return
    end
    if (effect.probability or 1) <= 0 or (effect.repeat_count or 1) + (effect.repeat_count_deviation or 0) <= 0 then
        return
    end
    if effect.type == "create-entity" and effect.entity_name ~= nil then
        entities[effect.entity_name] = true
    elseif effect.type == "create-asteroid-chunk" and effect.asteroid_name ~= nil then
        chunks[effect.asteroid_name] = true
    end
    collect(effect.action, entities, chunks)
    collect(effect.action_delivery, entities, chunks)
    collect(effect.source_effects, entities, chunks)
    collect(effect.target_effects, entities, chunks)
end

-- Called once all ordinary spawn-entity-surface nodes have been built.
dying_spawns.add = function(graph, build, entities, chunks, surfaces, locations, connections)
    local key = build.key
    local name = build.compound_key
    local function add(node_type, node_name, prereqs, surface)
        graph[key(node_type, node_name)] = {
            type = node_type,
            name = node_name,
            prereqs = prereqs,
            surface = surface,
        }
    end
    local function link(node_type, node_name, prereq_type, prereq_name)
        local node = graph[key(node_type, node_name)]
        if node ~= nil then
            table.insert(node.prereqs, { type = prereq_type, name = prereq_name })
        end
    end

    for _, chunk in pairs(chunks) do
        local prereqs = {}
        for surface_key, surface in pairs(surfaces) do
            if surface.type == "space-surface" then
                local node_name = name({chunk.name, surface_key})
                add("spawn-asteroid-chunk-surface", node_name, {}, surface_key)
                table.insert(prereqs, { type = "spawn-asteroid-chunk-surface", name = node_name })
            end
        end
        add("spawn-asteroid-chunk", chunk.name, prereqs)
    end

    local function direct_spawn(definition, prereq_type, prereq_name, probability)
        if probability <= 0 then
            return
        end
        local spawned_name = definition.asteroid or definition[1]
        local node_type = "spawn-entity-surface"
        if definition.type == "asteroid-chunk" then
            node_type = "spawn-asteroid-chunk-surface"
        end
        for surface_key, surface in pairs(surfaces) do
            if surface.type == "space-surface" then
                link(node_type, name({spawned_name, surface_key}), prereq_type, prereq_name)
            end
        end
    end
    for _, location in pairs(locations) do
        for _, definition in pairs(location.asteroid_spawn_definitions or {}) do
            direct_spawn(definition, "space-location", location.name, definition.probability or 0)
        end
    end
    for _, connection in pairs(connections) do
        for _, definition in pairs(connection.asteroid_spawn_definitions or {}) do
            local points = definition.spawn_points or definition[2] or {}
            for _, point in pairs(points) do
                if (point.probability or 0) > 0 then
                    direct_spawn(definition, "space-connection", connection.name, point.probability)
                    direct_spawn(definition, "space-connection-reverse", connection.name, point.probability)
                    break
                end
            end
        end
    end

    for _, entity in pairs(entities) do
        local spawned_entities = {}
        local spawned_chunks = {}
        collect(entity.dying_trigger_effect, spawned_entities, spawned_chunks)
        if next(spawned_entities) ~= nil or next(spawned_chunks) ~= nil then
            for surface_key, surface in pairs(surfaces) do
                local kill_name = name({entity.name, surface_key})
                local damage_type = "deal-damage-surface"
                if surface.type == "space-surface" then
                    damage_type = "spaceship-military-surface"
                end
                add("kill-entity-surface", kill_name, {
                    { type = "spawn-entity-surface", name = kill_name },
                    { type = damage_type, name = surface_key },
                }, surface_key)
                for spawned_name, _ in pairs(spawned_entities) do
                    link("spawn-entity-surface", name({spawned_name, surface_key}), "kill-entity-surface", kill_name)
                end
                for spawned_name, _ in pairs(spawned_chunks) do
                    link("spawn-asteroid-chunk-surface", name({spawned_name, surface_key}), "kill-entity-surface", kill_name)
                end
            end
        end
    end
end

return dying_spawns

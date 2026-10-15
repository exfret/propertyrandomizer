local collision_mask_util = require("__core__/lualib/collision-mask-util")

local builder = require("src/logic/builders/builder")
local gutils = require("src/lib/graph/graph-utils")

local requirements = {}

-- TileBuildabilityRule and EntityPrototype.tile_width/tile_height: installed 2.1 prototype API.
-- The engine fixtures in dev/test-helper-mod/test-tile-buildability.lua verify that every covered tile must match every overlapping rule.
-- This models terrain availability, not the existence of a contiguous natural patch at a particular map coordinate.
local function box(area)
    local first = area.left_top or area[1]
    local last = area.right_bottom or area[2]
    return {
        first.x or first[1],
        first.y or first[2],
        last.x or last[1],
        last.y or last[2],
    }
end

local function sorted_keys(values)
    local result = {}
    for value, _ in pairs(values) do
        table.insert(result, value)
    end
    table.sort(result)
    return result
end

local function signature(values)
    local parts = {}
    for _, value in pairs(values) do
        value = tostring(value)
        table.insert(parts, #value .. ":" .. value)
    end
    return table.concat(parts)
end

-- Off-grid placement can change which rules share a tile; boundaries and the intervals between them cover every rasterization.
local function phases(areas, axis)
    local boundaries = {[0] = true}
    for _, area in pairs(areas) do
        for index = axis, axis + 2, 2 do
            local value = -area[index]
            boundaries[value - math.floor(value)] = true
        end
    end
    local ordered = sorted_keys(boundaries)
    local result = {}
    for index, value in pairs(ordered) do
        table.insert(result, value)
        table.insert(result, (value + (ordered[index + 1] or 1)) / 2)
    end
    return result
end

local function accepts(layers, constraint)
    if constraint.required ~= nil and not collision_mask_util.masks_collide({layers = layers}, constraint.required) then
        return false
    end
    return constraint.forbidden == nil or not collision_mask_util.masks_collide({layers = layers}, constraint.forbidden)
end

requirements.compile = function(entity, tile_groups)
    local collision_box = entity.collision_box ~= nil and box(entity.collision_box) or {
        0,
        0,
        0,
        0,
    }
    local areas = {collision_box}
    local constraints = {{forbidden = collision_mask_util.get_mask(entity)}}
    for _, rule in pairs(entity.tile_buildability_rules or {}) do
        table.insert(areas, box(rule.area))
        table.insert(constraints, {
            required = rule.required_tiles,
            forbidden = rule.colliding_tiles,
        })
    end
    local x_phases = {(entity.tile_width or math.ceil(collision_box[3] - collision_box[1])) % 2 / 2}
    local y_phases = {(entity.tile_height or math.ceil(collision_box[4] - collision_box[2])) % 2 / 2}
    for _, flag in pairs(entity.flags or {}) do
        if flag == "placeable-off-grid" then
            x_phases = phases(areas, 1)
            y_phases = phases(areas, 2)
        end
    end

    local layouts = {}
    local seen_layouts = {}
    local domain_cache = {}
    for _, offset_x in pairs(x_phases) do
        for _, offset_y in pairs(y_phases) do
            local rectangles = {}
            local xs, ys = {}, {}
            for index, area in pairs(areas) do
                if area[1] < area[3] and area[2] < area[4] then
                    local rectangle = {
                        math.floor(area[1] + offset_x),
                        math.floor(area[2] + offset_y),
                        math.ceil(area[3] + offset_x),
                        math.ceil(area[4] + offset_y),
                    }
                    rectangles[index] = rectangle
                    xs[rectangle[1]], xs[rectangle[3]] = true, true
                    ys[rectangle[2]], ys[rectangle[4]] = true, true
                end
            end
            xs, ys = sorted_keys(xs), sorted_keys(ys)
            local clauses = {}
            local seen_clauses = {}
            for xi = 1, #xs - 1 do
                for yi = 1, #ys - 1 do
                    local active = {}
                    for index, rectangle in pairs(rectangles) do
                        if xs[xi] >= rectangle[1] and xs[xi] < rectangle[3] and ys[yi] >= rectangle[2] and ys[yi] < rectangle[4] then
                            table.insert(active, index)
                        end
                    end
                    table.sort(active)
                    if #active > 0 then
                        local active_key = signature(active)
                        local domain = domain_cache[active_key]
                        if domain == nil then
                            domain = {}
                            for group, layers in pairs(tile_groups) do
                                local allowed = true
                                for _, index in pairs(active) do
                                    if not accepts(layers, constraints[index]) then
                                        allowed = false
                                        break
                                    end
                                end
                                if allowed then
                                    table.insert(domain, group)
                                end
                            end
                            table.sort(domain)
                            domain_cache[active_key] = domain
                        end
                        local domain_key = signature(domain)
                        if seen_clauses[domain_key] == nil then
                            seen_clauses[domain_key] = true
                            table.insert(clauses, {
                                groups = domain,
                                key = domain_key,
                            })
                        end
                    end
                end
            end
            table.sort(clauses, function(a, b) return a.key < b.key end)
            local keys = {}
            for _, clause in pairs(clauses) do
                table.insert(keys, clause.key)
            end
            local layout_key = signature(keys)
            if seen_layouts[layout_key] == nil then
                seen_layouts[layout_key] = true
                table.insert(layouts, clauses)
            end
        end
    end
    return layouts
end

requirements.build = function(entity, lu, biome_terrain)
    builder.add_node("entity-build-tile-rules", "OR", nil, nil, {
        pass_through = true,
        biome_terrain = biome_terrain,
    })
    local layouts = requirements.compile(entity, lu.tile_collision_group_to_layers)
    for index, clauses in pairs(layouts) do
        local layout_key = gutils.concat({
            entity.name,
            index,
        })
        builder.add_edge("entity-build-tile-layout", layout_key, nil, "entity-build-tile-rules", entity.name)
        builder.add_node("entity-build-tile-layout", "AND", nil, layout_key, {pass_through = true})
        for clause_index, clause in pairs(clauses) do
            local region_key = gutils.concat({
                layout_key,
                clause_index,
            })
            builder.add_edge("entity-build-tile-region", region_key, nil, "entity-build-tile-layout", layout_key)
            builder.add_node("entity-build-tile-region", "OR", nil, region_key, {pass_through = true})
            for _, group in pairs(clause.groups) do
                builder.add_edge("tile-collision-group", group)
            end
        end
    end
end

-- The unified placement handler uses the same terrain compiler as the real-game builder.
-- Reuse the existing node types, with private names; no prototype mutation or graph rebuild is needed.
requirements.option = function(graph, entity, tile_groups, name, cache)
    local layouts = requirements.compile(entity, tile_groups)
    local layout_keys = {}
    for _, clauses in pairs(layouts) do
        local keys = {}
        for _, clause in pairs(clauses) do
            table.insert(keys, clause.key)
        end
        table.insert(layout_keys, signature(keys))
    end
    table.sort(layout_keys)
    local cache_key = signature(layout_keys)
    if cache ~= nil and cache[cache_key] ~= nil then
        return cache[cache_key]
    end
    local root = gutils.add_node(graph, "entity-build-tile-rules", name, {
        op = "OR",
        spoof = true,
    })
    for index, clauses in pairs(layouts) do
        local layout = gutils.add_node(graph, "entity-build-tile-layout", gutils.concat({
            name,
            index,
        }), {
            op = "AND",
            spoof = true,
        })
        gutils.add_edge(graph, layout, root)
        for clause_index, clause in pairs(clauses) do
            local region = gutils.add_node(graph, "entity-build-tile-region", gutils.concat({
                layout.name,
                clause_index,
            }), {
                op = "OR",
                spoof = true,
            })
            gutils.add_edge(graph, region, layout)
            for _, group in pairs(clause.groups) do
                gutils.add_edge(graph, gutils.key("tile-collision-group", group), region)
            end
        end
    end
    if cache ~= nil then
        cache[cache_key] = root
    end
    return root
end

-- Bundle the existing collision and native tile-rule prerequisites into one claimable requirement.
requirements.native = function(graph, entity, build)
    local root = gutils.add_node(graph, "entity-build-tile-layout", "biome-native: " .. entity.name, {
        op = "AND",
        spoof = true,
    })
    local edges = {}
    for edge_key, _ in pairs(build.pre) do
        if graph.nodes[graph.edges[edge_key].start].biome_terrain == true then
            table.insert(edges, edge_key)
        end
    end
    assert(#edges > 0, "building has no terrain requirement: " .. entity.name)
    for _, edge_key in pairs(edges) do
        gutils.redirect_edge_stop(graph, edge_key, gutils.key(root))
    end
    gutils.add_edge(graph, root, build, {
        biome_native = true,
        second_pass_only = true,
    })
    return root
end

return requirements

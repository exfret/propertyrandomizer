-- Planetary connection graph (setting propertyrandomizer-planetary-connections)
-- Draws a new random graph of space connections with the shape of the current one, without tiers or levels:
--   * every location keeps about as many connections as its original has now (a planet copy from lib/dupe-planets.lua counts as its original),
--   * connections favor pairs of orbits about as far apart as the current connections' typical pair (vanilla Space Age's join orbits 5 to 15 apart), so neither twins on one orbit nor jumps across the system are the rule,
--   * the graph stays connected from the starting planet: a spanning tree grows outward from the sun (each location joins one nearer the sun that's already placed, orbits taken in order with some jitter), then the rest of the connections go in until nobody has room left.
-- A new connection takes its length, asteroids and icons from the current connection between the most similar pair of orbits, so a route between two orbits is about as long and as dangerous as vanilla's between those orbits.
-- Connections that already join the right two locations stay as they are; the rest are new prototypes, and old ones go. What names a removed connection (like a distance achievement's tracked connection) names a new connection to the same place instead.
-- Orbits and positions on the star map don't change.

local constants = require("helper-tables/constants")
local rng = require("lib/random/rng")

local connections = {}

-- How sharply pairs of orbits are favored by their gap: a pair weighs exp(-|gap - typical| / GAP_SCALE), gap being the difference of the two distances from the sun and typical the median gap of the current connections between original locations (10 in vanilla Space Age, where the planets' connections span 5 to 15 and the shattered planet's 30)
local GAP_SCALE = 10
-- How far, in distance from the sun, the order the tree grows in may shuffle locations (so equal and near orbits come in a random order)
local ORDER_JITTER = 8

local function sorted_keys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

-- A space location's prototype (planets are space locations too)
local function location(name)
    return data.raw.planet[name] or (data.raw["space-location"] or {})[name]
end

-- The location a copy was made from (lib/dupe.lua keeps the original's name on a copy), or the location itself
local function origin(name)
    local prototype = location(name)
    if prototype ~= nil and prototype.orig_name ~= nil then
        return prototype.orig_name
    end
    return name
end

local function distance(name)
    local prototype = location(name)
    return (prototype ~= nil and prototype.distance) or 0
end

local function location_name(name)
    local prototype = location(name)
    if prototype ~= nil and prototype.localised_name ~= nil then
        return prototype.localised_name
    end
    return {"space-location-name." .. name}
end

local function pair_key(a, b)
    if a < b then
        return a .. "|" .. b
    end
    return b .. "|" .. a
end

local function pair_weight(a, b, typical_gap)
    local gap = math.abs(distance(a) - distance(b))
    return math.exp(-math.abs(gap - typical_gap) / GAP_SCALE)
end

-- One of the items, each as likely as its weight
local function weighted_pick(key, items, weights)
    local total = 0
    for _, weight in pairs(weights) do
        total = total + weight
    end
    local roll = rng.value(key) * total
    for i, item in pairs(items) do
        roll = roll - weights[i]
        if roll < 0 then
            return item
        end
    end
    return items[#items]
end

-- The current graph: its locations (sorted), which pairs are joined (pair key --> connection name), each location's connections among original locations only, and the typical (median) orbit gap of those connections
local function current_graph()
    local nodes = {}
    local joined = {}
    local original_degree = {}
    local gaps = {}
    for _, name in pairs(sorted_keys(data.raw["space-connection"] or {})) do
        local connection = data.raw["space-connection"][name]
        nodes[connection.from] = true
        nodes[connection.to] = true
        joined[pair_key(connection.from, connection.to)] = name
        if origin(connection.from) == connection.from and origin(connection.to) == connection.to then
            original_degree[connection.from] = (original_degree[connection.from] or 0) + 1
            original_degree[connection.to] = (original_degree[connection.to] or 0) + 1
            table.insert(gaps, math.abs(distance(connection.from) - distance(connection.to)))
        end
    end
    if location(constants.starting_planet) ~= nil then
        nodes[constants.starting_planet] = true
    end
    table.sort(gaps)
    return {
        nodes = sorted_keys(nodes),
        joined = joined,
        original_degree = original_degree,
        typical_gap = gaps[math.ceil(#gaps / 2)] or 0,
    }
end

-- Whether there's no graph to draw again (the base game has no space connections), which isn't worth a warning
connections.nothing_to_do = function()
    return next(data.raw["space-connection"] or {}) == nil
end

-- Why the graph can't be drawn now, or nil if it can
connections.problem = function()
    if connections.nothing_to_do() then
        return "there are no space connections"
    end
    if location(constants.starting_planet) == nil then
        return "there's no starting planet to connect from"
    end
    return nil
end

-- The new connections as a list of { from, to } (from on the nearer orbit), and each location's number of connections wanted
local function draw(graph, key)
    local start = constants.starting_planet
    local target = {}
    for _, node in pairs(graph.nodes) do
        target[node] = math.max(1, graph.original_degree[origin(node)] or 1)
    end
    local used = {}
    local adjacent = {}
    for _, node in pairs(graph.nodes) do
        used[node] = 0
        adjacent[node] = {}
    end
    local edges = {}
    local function join(a, b)
        if distance(b) < distance(a) then
            a, b = b, a
        end
        table.insert(edges, {
            from = a,
            to = b,
        })
        adjacent[a][b] = true
        adjacent[b][a] = true
        used[a] = used[a] + 1
        used[b] = used[b] + 1
    end

    -- A spanning tree grown from the start outward: locations come in order of their distance from the sun (with some jitter), and each joins one already placed, preferring nearby orbits and locations with room left
    local order = {}
    local jittered = {}
    for _, node in pairs(graph.nodes) do
        if node ~= start then
            table.insert(order, node)
            jittered[node] = distance(node) + rng.float_range(key, -ORDER_JITTER, ORDER_JITTER)
        end
    end
    table.sort(order, function(a, b)
        if jittered[a] ~= jittered[b] then
            return jittered[a] < jittered[b]
        end
        return a < b
    end)
    local placed = {
        start,
    }
    for _, node in pairs(order) do
        local candidates = {}
        local weights = {}
        for _, other in pairs(placed) do
            if used[other] < target[other] then
                table.insert(candidates, other)
                table.insert(weights, pair_weight(node, other, graph.typical_gap))
            end
        end
        if #candidates == 0 then
            for _, other in pairs(placed) do
                table.insert(candidates, other)
                table.insert(weights, pair_weight(node, other, graph.typical_gap))
            end
        end
        join(node, weighted_pick(key, candidates, weights))
        table.insert(placed, node)
    end

    -- The rest of the connections, between locations that both have room left, nearby orbits first, until no such pair is left
    while true do
        local candidates = {}
        local weights = {}
        for i, a in pairs(graph.nodes) do
            for j, b in pairs(graph.nodes) do
                if i < j and used[a] < target[a] and used[b] < target[b] and adjacent[a][b] == nil then
                    table.insert(candidates, {
                        a,
                        b,
                    })
                    table.insert(weights, pair_weight(a, b, graph.typical_gap))
                end
            end
        end
        if #candidates == 0 then
            break
        end
        local pair = weighted_pick(key, candidates, weights)
        join(pair[1], pair[2])
    end
    return edges, target
end

-- The current connections between original locations, sorted by name: the templates for new connections
local function original_connections()
    local list = {}
    for _, name in pairs(sorted_keys(data.raw["space-connection"])) do
        local connection = data.raw["space-connection"][name]
        if origin(connection.from) == connection.from and origin(connection.to) == connection.to then
            table.insert(list, connection)
        end
    end
    return list
end

-- The template whose pair of orbits is most like the new connection's (nearer orbit with nearer, farther with farther), the first by name among equals
local function template_for(edge, templates)
    local lo = distance(edge.from)
    local hi = distance(edge.to)
    local best = nil
    local best_score = nil
    for _, connection in pairs(templates) do
        local a = math.min(distance(connection.from), distance(connection.to))
        local b = math.max(distance(connection.from), distance(connection.to))
        local score = (a - lo) * (a - lo) + (b - hi) * (b - hi)
        if best_score == nil or score < best_score then
            best = connection
            best_score = score
        end
    end
    return best
end

-- Points every field of another prototype that names the connection (like a distance achievement's tracked connection) at the replacement instead; returns how many fields changed
local function retarget_references(connection_name, replacement_name)
    local num_changed = 0
    for class, prototypes in pairs(data.raw) do
        if class ~= "space-connection" and type(prototypes) == "table" then
            for _, prototype in pairs(prototypes) do
                if type(prototype) == "table" then
                    for field, value in pairs(prototype) do
                        if value == connection_name then
                            prototype[field] = replacement_name
                            num_changed = num_changed + 1
                        end
                    end
                end
            end
        end
    end
    return num_changed
end

-- A new connection prototype for the edge, after its template: the template's from end is its nearer orbit or its farther one, and the new connection's ends follow suit, so the asteroids along the route lie the same way
local function new_connection(edge, template)
    local connection = table.deepcopy(template)
    local from = edge.from
    local to = edge.to
    if distance(template.from) > distance(template.to) then
        from, to = to, from
    end
    connection.name = "propertyrandomizer-connection-" .. from .. "-" .. to
    connection.from = from
    connection.to = to
    connection.localised_name = {
        "",
        location_name(from),
        " - ",
        location_name(to),
    }
    -- The template's icons show its ends' icons; the new connection shows its own ends'
    local end_swaps = {
        {
            template.from,
            from,
        },
        {
            template.to,
            to,
        },
    }
    for _, icon in pairs(connection.icons or {}) do
        for _, swap in pairs(end_swaps) do
            local old_end = location(swap[1])
            local new_end = location(swap[2])
            if old_end ~= nil and new_end ~= nil and old_end.icon ~= nil and icon.icon == old_end.icon and new_end.icon ~= nil then
                icon.icon = new_end.icon
            end
        end
    end
    return connection
end

-- Draws and puts the new graph in the game; returns a line for the log
connections.execute = function(id)
    local key = rng.key({
        id = id,
    })
    local graph = current_graph()
    local edges, target = draw(graph, key)
    local wanted = {}
    for _, edge in pairs(edges) do
        wanted[pair_key(edge.from, edge.to)] = edge
    end
    local templates = original_connections()
    local kept = {}
    local created = {}
    for _, edge in pairs(edges) do
        local existing = graph.joined[pair_key(edge.from, edge.to)]
        if existing ~= nil then
            kept[existing] = true
        else
            local template = template_for(edge, templates)
            local connection = new_connection(edge, template)
            data:extend({
                connection,
            })
            table.insert(created, connection.name .. " (like " .. template.name .. ")")
        end
    end
    -- The old connections that weren't drawn again go; whatever named one names a drawn connection to the same place (the farther end first) instead
    local function drawn_connection_touching(location_name_wanted)
        for _, name in pairs(sorted_keys(data.raw["space-connection"])) do
            local connection = data.raw["space-connection"][name]
            if wanted[pair_key(connection.from, connection.to)] ~= nil and (connection.from == location_name_wanted or connection.to == location_name_wanted) then
                return name
            end
        end
        return nil
    end
    local removed = {}
    local retargeted = {}
    for _, name in pairs(sorted_keys(data.raw["space-connection"])) do
        local connection = data.raw["space-connection"][name]
        if kept[name] == nil and wanted[pair_key(connection.from, connection.to)] == nil then
            local farther = connection.to
            local nearer = connection.from
            if distance(farther) < distance(nearer) then
                farther, nearer = nearer, farther
            end
            local replacement = drawn_connection_touching(farther) or drawn_connection_touching(nearer)
            if replacement ~= nil and retarget_references(name, replacement) > 0 then
                table.insert(retargeted, name .. " --> " .. replacement)
            end
            data.raw["space-connection"][name] = nil
            table.insert(removed, name)
        end
    end
    local degrees = {}
    for _, node in pairs(graph.nodes) do
        local num = 0
        for _, edge in pairs(edges) do
            if edge.from == node or edge.to == node then
                num = num + 1
            end
        end
        table.insert(degrees, node .. " " .. num .. "/" .. target[node])
    end
    connections.edges = edges
    local routes = {}
    for _, edge in pairs(edges) do
        table.insert(routes, edge.from .. " - " .. edge.to .. " (orbits " .. distance(edge.from) .. " and " .. distance(edge.to) .. ")")
    end
    return #edges .. " connections among " .. #graph.nodes .. " locations, typical orbit gap " .. graph.typical_gap .. " (" .. table.concat(degrees, ", ") .. "); routes: " .. table.concat(routes, ", ") .. "; kept " .. #sorted_keys(kept) .. ", new " .. #created .. " [" .. table.concat(created, ", ") .. "], removed " .. #removed .. (#retargeted > 0 and ("; what named a removed connection now names: " .. table.concat(retargeted, ", ")) or "")
end

return connections

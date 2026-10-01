-- Planetary connection graph (setting propertyrandomizer-planetary-connections)
-- Draws a new random graph of space connections with the shape of the current one, without tiers or levels:
--   * every location keeps about as many connections as its original has now (a planet copy from lib/dupe-planets.lua counts as its original),
--   * connections favor pairs of orbits about as far apart as the current connections' typical pair (vanilla Space Age's join orbits 5 to 15 apart), so neither twins on one orbit nor jumps across the system are the rule,
--   * the graph stays connected from the starting planet: a spanning tree grows outward from the sun (each location joins one nearer the sun that's already placed, orbits taken in order with some jitter), then the rest of the connections go in until nobody has room left.
-- A new connection takes its length, asteroids and icons from the current connection between the most similar pair of orbits, so a route between two orbits is about as long and as dangerous as vanilla's between those orbits.
-- Connections that already join the right two locations stay as they are; the rest are new prototypes, and old ones go. What names a removed connection (like a distance achievement's tracked connection) names a new connection to the same place instead.
-- Orbits stay, but every location except the starting planet gets a new place on its orbit: of many random layouts across a fan of the map (wider with more locations), each improved by swapping places, the one with the fewest crossing routes, no locations drawn on top of each other and no route passing through a location is kept. Planet copies land wherever the graph reads best, not beside their originals.
-- Space locations past every planet that aren't planets themselves (in Space Age, the solar system edge and the shattered planet beyond it) are the end of the game rather than stops on the way (user, 2026-09-30), so the graph isn't drawn through them: they keep the connections they have (the edge to the outermost planets and their copies, the shattered planet right after the edge), which the layout and the arcs below still place.
-- Each route is then drawn as a gentle arc between its ends rather than a straight line: a circle's arc (a space connection's "arc" shape around the circle's center as its origin) bulging by a random share of the route's length, to whichever side makes the drawn routes cross and graze locations the least.

local constants = require("helper-tables/constants")
local rng = require("lib/random/rng")

local connections = {}

-- How sharply pairs of orbits are favored by their gap: a pair weighs exp(-|gap - typical| / GAP_SCALE), gap being the difference of the two distances from the sun and typical the median gap of the current connections between original locations (10 in vanilla Space Age, where the planets' connections span 5 to 15 and the shattered planet's 30)
local GAP_SCALE = 10
-- How far, in distance from the sun, the order the tree grows in may shuffle locations (so equal and near orbits come in a random order)
local ORDER_JITTER = 8
-- The star map layout: layouts tried, place swaps tried on each, then passes moving each location to the best of LAYOUT_SPOTS spots along the fan; how far apart locations are drawn (map units; a location's apparent size is about 1 to 1.5) and routes kept from locations they don't end at
local LAYOUT_TRIES = 20
local LAYOUT_SWAPS = 60
local LAYOUT_PASSES = 1
local LAYOUT_SPOTS = 8
local MIN_GAP = 4
-- The fan's widest span (turns), unless one orbit needs more: an orbit's locations (a planet and its duplicates' copies share one) get SPAN_ROOM map units of arc each, since the fan places locations in walk order rather than by orbit (fan_span)
local MAX_SPAN = 0.6
local SPAN_ROOM = 1.5 * MIN_GAP
local ROUTE_GAP = 2.5
-- How far a route's arc bulges from the straight line between its ends, as a share of that line's length (a random share between these per route), how many straight pieces an arc is taken as when drawn routes are compared, and from how many random starts the arcs' sides are chosen
local BEND_MIN = 0.08
local BEND_MAX = 0.16
local ARC_PIECES = 12
local SIDE_TRIES = 8

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

-- The locations at the end of the game (see the top): not planets, and farther from the sun than every planet, as a set
local function outer_locations(names)
    local farthest_planet = nil
    for _, planet in pairs(data.raw.planet or {}) do
        if planet.hidden ~= true and (farthest_planet == nil or (planet.distance or 0) > farthest_planet) then
            farthest_planet = planet.distance or 0
        end
    end
    local outer = {}
    for name, _ in pairs(names) do
        if farthest_planet ~= nil and data.raw.planet[name] == nil and distance(name) > farthest_planet then
            outer[name] = true
        end
    end
    return outer
end

-- The current graph: its locations (sorted; nodes all of them, drawn those the new graph is drawn among, without the end of the game), which pairs are joined (pair key --> connection name), each location's connections among original locations only (those to the end of the game aside), the typical (median) orbit gap of those connections, and the connections to the end of the game (links, as { from, to } with from on the nearer orbit, and how many each location has)
local function current_graph()
    local nodes = {}
    for _, name in pairs(sorted_keys(data.raw["space-connection"] or {})) do
        local connection = data.raw["space-connection"][name]
        nodes[connection.from] = true
        nodes[connection.to] = true
    end
    if location(constants.starting_planet) ~= nil then
        nodes[constants.starting_planet] = true
    end
    local outer = outer_locations(nodes)
    local joined = {}
    local original_degree = {}
    local gaps = {}
    local outer_links = {}
    local num_outer_links = {}
    for _, name in pairs(sorted_keys(data.raw["space-connection"] or {})) do
        local connection = data.raw["space-connection"][name]
        joined[pair_key(connection.from, connection.to)] = name
        if outer[connection.from] ~= nil or outer[connection.to] ~= nil then
            local from = connection.from
            local to = connection.to
            if distance(to) < distance(from) then
                from, to = to, from
            end
            table.insert(outer_links, {
                from = from,
                to = to,
            })
            num_outer_links[connection.from] = (num_outer_links[connection.from] or 0) + 1
            num_outer_links[connection.to] = (num_outer_links[connection.to] or 0) + 1
        elseif origin(connection.from) == connection.from and origin(connection.to) == connection.to then
            original_degree[connection.from] = (original_degree[connection.from] or 0) + 1
            original_degree[connection.to] = (original_degree[connection.to] or 0) + 1
            table.insert(gaps, math.abs(distance(connection.from) - distance(connection.to)))
        end
    end
    local drawn = {}
    for _, name in pairs(sorted_keys(nodes)) do
        if outer[name] == nil then
            table.insert(drawn, name)
        end
    end
    table.sort(gaps)
    return {
        nodes = sorted_keys(nodes),
        drawn = drawn,
        joined = joined,
        original_degree = original_degree,
        typical_gap = gaps[math.ceil(#gaps / 2)] or 0,
        outer_links = outer_links,
        num_outer_links = num_outer_links,
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

-- The new connections among the drawn locations as a list of { from, to } (from on the nearer orbit), and each location's number of connections wanted (its original's, which leaves out those to the end of the game, kept on top)
local function draw(graph, key)
    local start = constants.starting_planet
    local target = {}
    for _, node in pairs(graph.drawn) do
        target[node] = math.max(1, graph.original_degree[origin(node)] or 1)
    end
    local used = {}
    local adjacent = {}
    for _, node in pairs(graph.drawn) do
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
    for _, node in pairs(graph.drawn) do
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
        for i, a in pairs(graph.drawn) do
            for j, b in pairs(graph.drawn) do
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

-- Star map geometry: a location's point for an orientation (RealOrientation: 0 north, clockwise; distance in map units from the location's origin, the sun unless it sets another)
-- The game puts vanilla Space Age's locations at exactly these points (LuaSpaceLocationPrototype::position, read in a probe on 2.1.20)
local function point(node, orientation)
    local angle = orientation * 2 * math.pi
    local center = (location(node) or {}).origin or {}
    return {
        x = (center.x or center[1] or 0) + distance(node) * math.sin(angle),
        y = (center.y or center[2] or 0) - distance(node) * math.cos(angle),
    }
end

local function side(o, a, b)
    return (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x)
end

-- Whether the segments p1-p2 and p3-p4 cross properly
local function segments_cross(p1, p2, p3, p4)
    local d1 = side(p3, p4, p1)
    local d2 = side(p3, p4, p2)
    local d3 = side(p1, p2, p3)
    local d4 = side(p1, p2, p4)
    return ((d1 > 0 and d2 < 0) or (d1 < 0 and d2 > 0)) and ((d3 > 0 and d4 < 0) or (d3 < 0 and d4 > 0))
end

local function distance2(a, b)
    return (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y)
end

-- Squared distance from p to the segment a-b
local function segment_distance2(p, a, b)
    local dx = b.x - a.x
    local dy = b.y - a.y
    local length2 = dx * dx + dy * dy
    local t = 0
    if length2 > 0 then
        t = math.max(0, math.min(1, ((p.x - a.x) * dx + (p.y - a.y) * dy) / length2))
    end
    local qx = a.x + t * dx - p.x
    local qy = a.y + t * dy - p.y
    return qx * qx + qy * qy
end

-- How bad a layout is: crossing routes weigh most, then locations drawn on top of each other, then routes through locations, then a little for long routes
-- points[i] is location i's point; edges are pairs of location indexes (index_edges below), so the inner loops touch numbers only
local MIN_GAP2 = MIN_GAP * MIN_GAP
local ROUTE_GAP2 = ROUTE_GAP * ROUTE_GAP
local function layout_cost(num_nodes, index_edges, points)
    local cost = 0
    for i, edge in pairs(index_edges) do
        local from = points[edge[1]]
        local to = points[edge[2]]
        for j = i + 1, #index_edges do
            local other = index_edges[j]
            if edge[1] ~= other[1] and edge[1] ~= other[2] and edge[2] ~= other[1] and edge[2] ~= other[2] and segments_cross(from, to, points[other[1]], points[other[2]]) then
                cost = cost + 10
            end
        end
        for node = 1, num_nodes do
            if node ~= edge[1] and node ~= edge[2] then
                local gap2 = segment_distance2(points[node], from, to)
                if gap2 < ROUTE_GAP2 then
                    cost = cost + 3 + (ROUTE_GAP2 - gap2) / ROUTE_GAP2
                end
            end
        end
        cost = cost + distance2(from, to) / 40000
    end
    for a = 1, num_nodes do
        for b = a + 1, num_nodes do
            local gap2 = distance2(points[a], points[b])
            if gap2 < MIN_GAP2 then
                cost = cost + 5 + (MIN_GAP2 - gap2) / MIN_GAP2
            end
        end
    end
    return cost
end

-- The locations in the order of a depth-first walk of the graph from the start, neighbors in a random order each time: a layout that spreads them out in this order has most routes between neighbors along the fan
local function walk_order(nodes, edges, key)
    local neighbors = {}
    for _, node in pairs(nodes) do
        neighbors[node] = {}
    end
    for _, edge in pairs(edges) do
        table.insert(neighbors[edge.from], edge.to)
        table.insert(neighbors[edge.to], edge.from)
    end
    local order = {}
    local seen = {}
    local function visit(node)
        seen[node] = true
        table.insert(order, node)
        local around = {}
        for _, other in pairs(neighbors[node]) do
            table.insert(around, other)
        end
        rng.shuffle(key, around)
        for _, other in pairs(around) do
            if seen[other] == nil then
                visit(other)
            end
        end
    end
    local start = constants.starting_planet
    if neighbors[start] ~= nil then
        visit(start)
    end
    for _, node in pairs(nodes) do
        if seen[node] == nil then
            visit(node)
        end
    end
    return order
end

-- How wide a fan the locations are spread over (turns): a quarter turn for seven locations, wider for more, up to MAX_SPAN, or as wide as the most crowded orbit needs for SPAN_ROOM per location (many planet copies on one orbit), up to a whole turn
local function fan_span(nodes)
    local per_orbit = {}
    for _, node in pairs(nodes) do
        local orbit = distance(node)
        if orbit > 0 then
            per_orbit[orbit] = (per_orbit[orbit] or 0) + 1
        end
    end
    local widest = MAX_SPAN
    for orbit, count in pairs(per_orbit) do
        widest = math.max(widest, math.min(1, count * SPAN_ROOM / (2 * math.pi * orbit)))
    end
    return math.min(widest, math.max(0.25, 0.25 * #nodes / 7))
end

-- New orientations for every location but the starting planet: the best of LAYOUT_TRIES layouts, each spreading the locations evenly (with jitter) over a fan around the current layout's middle (fan_span) in the order of a random depth-first walk, then improved by LAYOUT_SWAPS place swaps
-- Returns orientation per node and the cost of the layout
local function layout(nodes, edges, key)
    local start = constants.starting_planet
    local index_of = {}
    for i, node in pairs(nodes) do
        index_of[node] = i
    end
    local index_edges = {}
    for _, edge in pairs(edges) do
        table.insert(index_edges, {
            index_of[edge.from],
            index_of[edge.to],
        })
    end
    local movable = {}
    local sin_sum = 0
    local cos_sum = 0
    for _, node in pairs(nodes) do
        if node ~= start then
            table.insert(movable, node)
        end
        local current = (location(node) or {}).orientation or 0
        sin_sum = sin_sum + math.sin(current * 2 * math.pi)
        cos_sum = cos_sum + math.cos(current * 2 * math.pi)
    end
    local center = math.atan2(sin_sum, cos_sum) / (2 * math.pi)
    local span = fan_span(nodes)
    local lo = center - span / 2
    local start_orientation = (location(start) or {}).orientation or 0
    local best = nil
    local best_cost = nil
    for _ = 1, LAYOUT_TRIES do
        local orientation = {}
        local points = {}
        orientation[start] = start_orientation
        local order = {}
        for _, node in pairs(walk_order(nodes, edges, key)) do
            if node ~= start then
                table.insert(order, node)
            end
        end
        for i, node in pairs(order) do
            orientation[node] = lo + span * (i - 0.5 + rng.float_range(key, -0.4, 0.4)) / #order
        end
        for i, node in pairs(nodes) do
            points[i] = point(node, orientation[node])
        end
        local cost = layout_cost(#nodes, index_edges, points)
        for _ = 1, LAYOUT_SWAPS do
            local a = movable[rng.int(key, #movable)]
            local b = movable[rng.int(key, #movable)]
            if a ~= b then
                orientation[a], orientation[b] = orientation[b], orientation[a]
                local old_a = points[index_of[a]]
                local old_b = points[index_of[b]]
                points[index_of[a]] = point(a, orientation[a])
                points[index_of[b]] = point(b, orientation[b])
                local swapped_cost = layout_cost(#nodes, index_edges, points)
                if swapped_cost <= cost then
                    cost = swapped_cost
                else
                    orientation[a], orientation[b] = orientation[b], orientation[a]
                    points[index_of[a]] = old_a
                    points[index_of[b]] = old_b
                end
            end
        end
        -- Each location in turn moves to the best of a few spots along the fan (its own place among them), a couple of times over
        for _ = 1, LAYOUT_PASSES do
            for _, node in pairs(movable) do
                local index = index_of[node]
                local best_spot = orientation[node]
                local best_point = points[index]
                for spot = 1, LAYOUT_SPOTS do
                    local candidate = lo + span * (spot - 0.5 + rng.float_range(key, -0.3, 0.3)) / LAYOUT_SPOTS
                    orientation[node] = candidate
                    points[index] = point(node, candidate)
                    local moved_cost = layout_cost(#nodes, index_edges, points)
                    if moved_cost < cost then
                        cost = moved_cost
                        best_spot = candidate
                        best_point = points[index]
                    end
                end
                orientation[node] = best_spot
                points[index] = best_point
            end
        end
        if best_cost == nil or cost < best_cost then
            best = orientation
            best_cost = cost
        end
    end
    return best, best_cost
end

-- A route's arc from a to b: the circle through both whose arc between them bulges by bend times their distance, to the left of the way from a to b for side 1 and to the right for side -1
-- Returns the circle's center (what the connection's origin is) and the arc as ARC_PIECES straight pieces (its ends exactly a and b, so routes sharing an end meet there without crossing), or nil when a and b are the same point
-- The game draws an "arc" connection around its origin, the shorter way (boskid on the forums for 2.1.20: "origin is only used by shape="arc" as a center point"); both ends being as far from the center, that's this arc
local function arc(a, b, bend, side)
    local dx = b.x - a.x
    local dy = b.y - a.y
    local chord = math.sqrt(dx * dx + dy * dy)
    if chord < 1e-6 then
        return nil
    end
    local sagitta = bend * chord
    local radius = (chord * chord / 4 + sagitta * sagitta) / (2 * sagitta)
    -- The left of the way from a to b, and the center: across the straight line from the bulge
    local left_x = -dy / chord
    local left_y = dx / chord
    local center = {
        x = (a.x + b.x) / 2 - side * left_x * (radius - sagitta),
        y = (a.y + b.y) / 2 - side * left_y * (radius - sagitta),
    }
    local start_angle = math.atan2(a.y - center.y, a.x - center.x)
    local sweep = math.atan2(b.y - center.y, b.x - center.x) - start_angle
    if sweep > math.pi then
        sweep = sweep - 2 * math.pi
    elseif sweep < -math.pi then
        sweep = sweep + 2 * math.pi
    end
    local pieces = {
        a,
    }
    for i = 1, ARC_PIECES - 1 do
        local angle = start_angle + sweep * i / ARC_PIECES
        table.insert(pieces, {
            x = center.x + radius * math.cos(angle),
            y = center.y + radius * math.sin(angle),
        })
    end
    table.insert(pieces, b)
    return center, pieces
end

-- The box around a list of points, to skip pairs of arcs that can't meet
local function bounds(points)
    local box = {
        min_x = math.huge,
        min_y = math.huge,
        max_x = -math.huge,
        max_y = -math.huge,
    }
    for _, p in pairs(points) do
        box.min_x = math.min(box.min_x, p.x)
        box.min_y = math.min(box.min_y, p.y)
        box.max_x = math.max(box.max_x, p.x)
        box.max_y = math.max(box.max_y, p.y)
    end
    return box
end

-- How many times two drawn routes (as their pieces) cross
local function arc_crossings(p, q, p_box, q_box)
    if p_box.max_x < q_box.min_x or q_box.max_x < p_box.min_x or p_box.max_y < q_box.min_y or q_box.max_y < p_box.min_y then
        return 0
    end
    local num = 0
    for i = 1, #p - 1 do
        for j = 1, #q - 1 do
            if segments_cross(p[i], p[i + 1], q[j], q[j + 1]) then
                num = num + 1
            end
        end
    end
    return num
end

-- The way a drawn route leaves its end at the given point (its first piece's direction, or its last piece's backwards), as a unit vector
local function leaving(pieces, at)
    local near = pieces[2]
    if pieces[1] ~= at then
        near = pieces[#pieces - 1]
    end
    local dx = near.x - at.x
    local dy = near.y - at.y
    local length = math.sqrt(dx * dx + dy * dy)
    return {
        x = dx / length,
        y = dy / length,
    }
end

-- Arcs for the routes on the laid-out map: each route bends by a random share, to one side or the other, and the sides are chosen for the drawing with the fewest crossings, then fewest routes grazing a location (weighed as in layout_cost), then fewest routes leaving an end almost the same way (under 10 degrees apart)
-- The best of SIDE_TRIES random starts, each improved by turning one route's bulge to its other side while that helps
-- Returns per edge (by index) its bend and { center, pieces } for the side chosen (nil for a route whose ends are drawn on one point, which stays a straight line), and the drawing's cost and crossings
local function bend_routes(nodes, edges, orientation, key)
    local points = {}
    for _, node in pairs(nodes) do
        points[node] = point(node, orientation[node])
    end
    local SIDES = {
        1,
        -1,
    }
    local shapes = {}
    for i, edge in pairs(edges) do
        shapes[i] = {
            bend = rng.float_range(key, BEND_MIN, BEND_MAX),
        }
        for s, side in pairs(SIDES) do
            local center, pieces = arc(points[edge.from], points[edge.to], shapes[i].bend, side)
            if center ~= nil then
                -- What this arc costs on its own: grazing the locations it doesn't end at
                local own = 0
                for _, node in pairs(nodes) do
                    if node ~= edge.from and node ~= edge.to then
                        local gap2 = math.huge
                        for k = 1, #pieces - 1 do
                            gap2 = math.min(gap2, segment_distance2(points[node], pieces[k], pieces[k + 1]))
                        end
                        if gap2 < ROUTE_GAP2 then
                            own = own + 3 + (ROUTE_GAP2 - gap2) / ROUTE_GAP2
                        end
                    end
                end
                shapes[i][s] = {
                    center = center,
                    pieces = pieces,
                    box = bounds(pieces),
                    own = own,
                }
            end
        end
    end
    -- What each pair of arcs costs together, per pair of sides: 10 per crossing, and 2 for leaving a shared end almost the same way
    local ALMOST_SAME_WAY = math.cos(math.rad(10))
    local pair_cost = {}
    local pair_crossings = {}
    for i = 1, #edges do
        pair_cost[i] = {}
        pair_crossings[i] = {}
        for j = i + 1, #edges do
            pair_cost[i][j] = {}
            pair_crossings[i][j] = {}
            for si = 1, 2 do
                pair_cost[i][j][si] = {}
                pair_crossings[i][j][si] = {}
                for sj = 1, 2 do
                    local cost = 0
                    local num = 0
                    local p = shapes[i][si]
                    local q = shapes[j][sj]
                    if p ~= nil and q ~= nil then
                        num = arc_crossings(p.pieces, q.pieces, p.box, q.box)
                        cost = 10 * num
                        for _, a in pairs({
                            edges[i].from,
                            edges[i].to,
                        }) do
                            if a == edges[j].from or a == edges[j].to then
                                local u = leaving(p.pieces, points[a])
                                local v = leaving(q.pieces, points[a])
                                if u.x * v.x + u.y * v.y > ALMOST_SAME_WAY then
                                    cost = cost + 2
                                end
                            end
                        end
                    end
                    pair_cost[i][j][si][sj] = cost
                    pair_crossings[i][j][si][sj] = num
                end
            end
        end
    end
    local function own_cost(i, s)
        local shape = shapes[i][s]
        return shape ~= nil and shape.own or 0
    end
    local function together(i, si, j, sj)
        if i < j then
            return pair_cost[i][j][si][sj]
        end
        return pair_cost[j][i][sj][si]
    end
    local best = nil
    local best_cost = nil
    for _ = 1, SIDE_TRIES do
        local sides = {}
        for i = 1, #edges do
            sides[i] = rng.int(key, 2)
        end
        local improved = true
        local passes = 0
        while improved and passes < 20 do
            improved = false
            passes = passes + 1
            for i = 1, #edges do
                local other = 3 - sides[i]
                local change = own_cost(i, other) - own_cost(i, sides[i])
                for j = 1, #edges do
                    if j ~= i then
                        change = change + together(i, other, j, sides[j]) - together(i, sides[i], j, sides[j])
                    end
                end
                if change < 0 then
                    sides[i] = other
                    improved = true
                end
            end
        end
        local cost = 0
        for i = 1, #edges do
            cost = cost + own_cost(i, sides[i])
            for j = i + 1, #edges do
                cost = cost + pair_cost[i][j][sides[i]][sides[j]]
            end
        end
        if best_cost == nil or cost < best_cost then
            best = sides
            best_cost = cost
        end
    end
    local routes = {}
    local num_crossings = 0
    for i = 1, #edges do
        routes[i] = {
            bend = shapes[i].bend,
            shape = shapes[i][best[i]],
        }
        for j = i + 1, #edges do
            num_crossings = num_crossings + pair_crossings[i][j][best[i]][best[j]]
        end
    end
    return routes, best_cost, num_crossings
end

-- Draws and puts the new graph in the game; returns a line for the log
connections.execute = function(id)
    local key = rng.key({
        id = id,
    })
    local graph = current_graph()
    local edges, target = draw(graph, key)
    -- The end of the game keeps its connections, which the layout and the arcs still see
    for _, link in pairs(graph.outer_links) do
        table.insert(edges, link)
    end
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
        table.insert(degrees, node .. " " .. num .. "/" .. (target[node] ~= nil and tostring(target[node] + (graph.num_outer_links[node] or 0)) or "end of the game"))
    end
    -- The star map layout
    local orientation, layout_score = layout(graph.nodes, edges, key)
    local places = {}
    for _, node in pairs(graph.nodes) do
        local prototype = location(node)
        if prototype ~= nil and node ~= constants.starting_planet then
            prototype.orientation = orientation[node] % 1
            prototype.parked_platforms_orientation = nil
        end
        table.insert(places, node .. " @ " .. string.format("%.3f", orientation[node] % 1))
    end
    -- Every route is drawn as an arc around its own center, bulging to the side chosen on the laid-out map (a route whose ends are drawn on one point stays a straight line)
    local routes_drawn, drawing_cost, num_crossings = bend_routes(graph.nodes, edges, orientation, key)
    local route_of = {}
    for i, edge in pairs(edges) do
        route_of[pair_key(edge.from, edge.to)] = routes_drawn[i]
    end
    local num_straight = 0
    for _, name in pairs(sorted_keys(data.raw["space-connection"])) do
        local connection = data.raw["space-connection"][name]
        local route = route_of[pair_key(connection.from, connection.to)]
        if route ~= nil and route.shape ~= nil then
            connection.shape = "arc"
            connection.origin = {
                x = route.shape.center.x,
                y = route.shape.center.y,
            }
        elseif route ~= nil then
            connection.shape = "line"
            connection.origin = nil
            num_straight = num_straight + 1
        end
    end
    connections.edges = edges
    local routes = {}
    for _, edge in pairs(edges) do
        table.insert(routes, edge.from .. " - " .. edge.to .. " (orbits " .. distance(edge.from) .. " and " .. distance(edge.to) .. ")")
    end
    return #edges .. " connections among " .. #graph.nodes .. " locations, typical orbit gap " .. graph.typical_gap .. " (" .. table.concat(degrees, ", ") .. "); routes: " .. table.concat(routes, ", ") .. "; star map (orientation per location, layout cost " .. string.format("%.1f", layout_score) .. "): " .. table.concat(places, ", ") .. "; routes drawn as arcs (drawing cost " .. string.format("%.1f", drawing_cost) .. ", crossings " .. num_crossings .. (num_straight > 0 and (", straight " .. num_straight) or "") .. "); kept " .. #sorted_keys(kept) .. ", new " .. #created .. " [" .. table.concat(created, ", ") .. "], removed " .. #removed .. (#retargeted > 0 and ("; what named a removed connection now names: " .. table.concat(retargeted, ", ")) or "")
end

-- For timing and tests outside the game (scratch harnesses): the layout search on given nodes and edges, and the routes' arcs on a layout
connections.layout = layout
connections.bend_routes = bend_routes

return connections

-- Real shared-promotion regression: independent biome choices cannot close a construction cycle.
function table.deepcopy(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for key, child in pairs(value) do copy[key] = table.deepcopy(child) end
    return copy
end
function log(_) end
serpent = {block = tostring, line = tostring}
config = {planetary_biomes = false, planetary_biome_placement = true}
mods = {}
defines = {prototypes = {entity = {furnace = true, container = true}, item = {item = true}}}
package.loaded["__core__/lualib/collision-mask-util"] = {
    get_mask = function(entity) return entity.collision_mask or {layers = {water = true, object = true}} end,
    masks_collide = function(a, b)
        for layer, enabled in pairs(a.layers) do if enabled and b.layers[layer] then return true end end
        return false
    end,
}
local draws = {}
package.loaded["src/lib/random/rng"] = {
    key = function(values)
        if values.prototype ~= nil then
            draws[values.prototype.name] = (draws[values.prototype.name] or 0) + 1
            return values.prototype.name
        end
        return "unified"
    end,
    value = function(_) return 0 end,
    int = function(_, count) return count end,
}
package.loaded["src/randomizations/planetary/biomes"] = {execute = function() error("appearance mixer should stay off") end}
local logic = {contexts = {home = true}, type_info = {room = {context = "room"}}}
package.loaded["src/logic/state"] = logic
package.loaded["src/logic/init"] = logic
local gutils = require("src/lib/graph/graph-utils")
local setup = require("src/logic/builders/graph-setup")
local top = require("src/lib/sort/context-sort")
local promotion = require("src/randomizations/unified/skeleton/promotion")
package.loaded["src/randomizations/planetary/check"] = {moved_features = {}}
local preparation = require("src/randomizations/planetary/biome-placement")
local lookups = {tile_collision_group_to_layers = {}}
package.loaded["src/prototypes/lookup/init"] = lookups
local handler = require("src/randomizations/unified/handlers/biome-placement")
local invariants = require("tests/graph-invariants")
local panel = require("src/runtime/panel/biomes")
local key = gutils.key
local area = {{-0.4, -0.4}, {0.4, 0.4}}
local function entity(name, kind)
    return {name = name, type = kind or "furnace", collision_box = area}
end
data = {
    raw = {
        ["collision-layer"] = {ground = {}, water = {}, object = {}},
        tile = {
            land = {name = "land", autoplace = {}, collision_mask = {layers = {ground = true}}},
            wet = {name = "wet", fluid = "water", collision_mask = {layers = {water = true}}},
        },
        furnace = {alpha = entity("alpha"), alpha2 = entity("alpha2"), beta = entity("beta")},
        container = {circuit = entity("circuit", "container")},
        item = {},
    },
    extend = function(self, entries)
        for _, entry in pairs(entries) do
            self.raw[entry.type] = self.raw[entry.type] or {}
            self.raw[entry.type][entry.name] = entry
        end
    end,
}
local infrastructure = {circuit = "container"}
for _, kind in pairs({"transport-belt", "inserter", "electric-pole", "pipe", "arithmetic-combinator", "roboport"}) do
    local name = "infrastructure-" .. kind
    defines.prototypes.entity[kind] = true
    data.raw[kind] = {[name] = entity(name, kind)}
    infrastructure[name] = kind
end
for name, kind in pairs(infrastructure) do
    data.raw[kind][name].tile_buildability_rules = {{area = area, required_tiles = {layers = {ground = true}}}}
end
data.raw.furnace.alpha.next_upgrade = "alpha2"
data.raw.furnace.alpha2.tile_buildability_rules = {{area = area, required_tiles = {layers = {ground = true}}}}
assert(preparation.prepare() == nil)
local native_raw = table.deepcopy(data.raw)
local graph = {nodes = {}, edges = {}, sources = {}}
local function node(kind, name, op, extra)
    extra = extra or {}
    extra.op = op
    logic.type_info[kind] = logic.type_info[kind] or {}
    logic.type_info[kind].op = op
    return gutils.add_node(graph, kind, name, extra)
end
local start = node("start", "", "AND")
local home = node("room", "home", "OR")
gutils.add_edge(graph, start, home)
local groups = {}
for name, tile in pairs(data.raw.tile) do
    local layers = {}
    for layer, _ in pairs(tile.collision_mask.layers) do table.insert(layers, layer) end
    table.sort(layers)
    local group_key = gutils.concat(layers)
    lookups.tile_collision_group_to_layers[group_key] = tile.collision_mask.layers
    groups[name] = node("tile-collision-group", group_key, "OR")
end
gutils.add_edge(graph, home, groups.land)
local builds = {}
for kind, _ in pairs(defines.prototypes.entity) do
    for name, prototype in pairs(data.raw[kind] or {}) do
        local build = node("entity-build", name, "AND", {prot = key(prototype)})
        builds[name] = build
        local terrain = node("fixture-terrain", name, "OR", {biome_terrain = true})
        gutils.add_edge(graph, groups.land, terrain)
        gutils.add_edge(graph, terrain, build)
        -- The kit takes longer than terrain; alpha's kit depends on beta, which the water also needs.
        local previous = home
        if name == "alpha" then previous = builds.beta or node("fixture-alpha-kit", "", "OR") end
        for index = 1, 8 do
            local delay = node("fixture-delay", name .. index, "AND")
            gutils.add_edge(graph, previous, delay)
            previous = delay
        end
        gutils.add_edge(graph, previous, build)
    end
end
-- Keep the kit dependency independent of table iteration order.
local alpha_kit = graph.nodes[key("fixture-alpha-kit", "")]
if alpha_kit ~= nil then gutils.add_edge(graph, builds.beta, alpha_kit) end
gutils.add_edge(graph, builds.beta, groups.wet)
logic.graph = graph
setup.build(logic)
local initial_graph = table.deepcopy(graph)
handler.initialize()
handler.spoof(graph)
-- Spoofing must leave prototypes unchanged until reflection.
assert(data.raw.furnace.alpha.tile_buildability_rules == nil)
assert(data.raw.furnace.alpha2.tile_buildability_rules[1].required_tiles.layers.ground)
for _, value in pairs(graph.nodes) do
    logic.type_info[value.type] = logic.type_info[value.type] or {}
    logic.type_info[value.type].op = value.op
end
setup.build(logic)
invariants.test(graph)
local baseline = top.sort(graph)
local edges = {}
for edge_key, edge in pairs(graph.edges) do
    if handler.may_claim(graph, graph.nodes[edge.start], graph.nodes[edge.stop], edge) then
        assert(handler.claim(graph, graph.nodes[edge.start], graph.nodes[edge.stop], edge) == 0)
        table.insert(edges, edge_key)
    end
end
local heads = {}
for _, edge_key in pairs(edges) do
    local build = graph.nodes[graph.edges[edge_key].stop]
    heads[build.name] = gutils.subdivide_base_head(graph, edge_key).head
end
local entries = handler.pool_entries(graph, baseline, function() return true end)
local candidates = {}
for _, entry in pairs(entries) do
    local base = graph.nodes[entry.base_key]
    candidates[base.biome_entity] = entry.base_key
end
logic.type_info.base = {op = "AND"}
logic.type_info.head = {op = "OR"}
local prom = promotion.new({graph = graph})
prom.promise_mechanics()
local choices, owners = {}, {}
for _, name in pairs({"beta", "alpha", "alpha2"}) do
    local head = heads[name]
    local needs = prom.required_contexts(key(builds[name]))
    assert(#needs > 0, "optional building must have an anchor context: " .. name)
    local candidate = candidates[name]
    assert(handler.validate(graph, graph.nodes[candidate], head))
    assert(not handler.validate(graph, graph.nodes[candidates[name == "alpha" and "beta" or "alpha"]], head))
    local pool = {}
    for _, entry in pairs(entries) do table.insert(pool, entry.base_key) end
    local indices = handler.candidate_indices(graph, head, pool)
    assert(#indices == 1, "ten identical proposals must share one prerequisite check")
    assert(pool[indices[1]] == candidate, "only this building's proposals may be checked")
    local chosen = prom.head_candidate_ok(key(head), candidate, needs) and candidate or head.old_base
    choices[key(head)] = chosen
    owners[key(head)] = handler
    prom.resolve_head(key(head), chosen, needs)
end
handler.reflect(graph, choices, owners)
local metadata = data.raw["mod-data"]["propertyrandomizer-biome-placement"].data
assert(metadata.assignments.beta == nil, "a building cannot require terrain it creates itself")
assert(metadata.assignments.alpha2 == nil, "overlapping native rules must intersect the drawn biome")
assert(graph.nodes[candidates.alpha].biome_entity == "alpha")
assert(graph.nodes[candidates.alpha2].biome_entity == "alpha2")
assert(metadata.assignments.alpha == nil or metadata.assignments.alpha == "water", "an upgrade sibling keeps its own draw or native fallback")
local function same(first, second)
    if type(first) ~= type(second) then return false end
    if type(first) ~= "table" then return first == second end
    for field, value in pairs(first) do if not same(value, second[field]) then return false end end
    for field, _ in pairs(second) do if first[field] == nil then return false end end
    return true
end
local visible = {}
for kind, _ in pairs(defines.prototypes.entity) do
    for name, prototype in pairs(data.raw[kind] or {}) do visible[name] = prototype end
end
for name, kind in pairs(infrastructure) do
    assert(metadata.entities[name] == nil, "infrastructure must be outside eligibility: " .. name)
    assert(draws[name] == nil and heads[name] == nil and candidates[name] == nil, "infrastructure must never roll or be claimed: " .. name)
    assert(metadata.assignments[name] == nil, "infrastructure must not receive any forced profile: " .. name)
    assert(same(data.raw[kind][name], native_raw[kind][name]), "infrastructure must retain native masks and rules: " .. name)
end
for _, row in pairs(panel.rows(visible)) do
    assert(infrastructure[row.entity.name] == nil, "untouched infrastructure must not appear as a biome assignment")
end
assert(data.raw.furnace.alpha.next_upgrade == "alpha2", "matching must not couple or edit upgrade links")
assert(data.raw.furnace.alpha2.tile_buildability_rules[1].required_tiles.layers.ground)
assert(data.raw.furnace.beta.collision_mask.layers.water)
assert(metadata.statistics.eligible == 3 and metadata.statistics.selected == 3)
assert(metadata.statistics.restrictive_kept == (metadata.assignments.alpha ~= nil and 1 or 0))
assert(metadata.rejected >= 2)
assert(metadata.statistics.proposals == 30 and metadata.statistics.restrictive_proposed == 30)
assert(gutils.get_owner(graph, graph.nodes[candidates.alpha]) == gutils.get_owner(graph, graph.nodes[candidates.beta]), "identical terrain domains must share their dependency nodes")
local sorted = top.sort(graph)
for _, name in pairs({"alpha", "alpha2", "beta", "circuit"}) do
    assert(next(sorted.node_to_context_inds[key(builds[name])] or {}) ~= nil)
end
handler.release()
print("PASS shared promotion keeps optional buildings, rejects construction cycles and preserves independent draws")

-- A retry starts with the original report/prototypes; no choices or statistics leak between attempts.
data.raw = table.deepcopy(native_raw)
handler.initialize()
assert(data.raw["mod-data"]["propertyrandomizer-biome-placement"].data.statistics == nil)
-- First nine proposals fail for beta/alpha2; proposal ten must still be tried.
local counts = {}
package.loaded["src/lib/random/rng"].int = function(name, count)
    counts[name] = (counts[name] or 0) + 1
    return counts[name] == 10 and 1 or count
end
logic.graph = table.deepcopy(initial_graph)
graph = logic.graph
setup.build(logic)
handler.spoof(graph)
for name, count in pairs(counts) do assert(count == 10 and infrastructure[name] == nil) end
for _, value in pairs(graph.nodes) do
    logic.type_info[value.type] = logic.type_info[value.type] or {}
    logic.type_info[value.type].op = value.op
end
setup.build(logic)
local retry_baseline = top.sort(graph)
local native_edges = {}
for edge_key, edge in pairs(graph.edges) do
    if handler.may_claim(graph, graph.nodes[edge.start], graph.nodes[edge.stop], edge) then
        handler.claim(graph, graph.nodes[edge.start], graph.nodes[edge.stop], edge)
        table.insert(native_edges, edge_key)
    end
end
heads = {}
for _, edge_key in pairs(native_edges) do
    local build = graph.nodes[graph.edges[edge_key].stop]
    heads[build.name] = gutils.subdivide_base_head(graph, edge_key).head
end
entries = handler.pool_entries(graph, retry_baseline, function() return true end)
local pool = {}
for _, entry in pairs(entries) do
    table.insert(pool, entry.base_key)
    local base = graph.nodes[entry.base_key]
    if base.biome_profile == "everything" then
        -- Fix availability before each kit, rather than relying on unrelated ties in promotion's fixed ranks.
        gutils.add_edge(graph, gutils.get_owner(graph, base), graph.nodes[key("fixture-delay", base.biome_entity .. 8)])
    end
end
prom = promotion.new({graph = graph})
prom.promise_mechanics()
choices, owners = {}, {}
for _, name in pairs({"beta", "alpha", "alpha2"}) do
    local head = heads[name]
    local needs = prom.required_contexts(key(builds[name]))
    local indices = handler.candidate_indices(graph, head, pool)
    assert(#indices == 2, "repeated proposals must be skipped without losing the tenth draw")
    assert(graph.nodes[pool[indices[1]]].biome_profile == "water")
    assert(graph.nodes[pool[indices[2]]].biome_profile == "everything")
    local chosen = head.old_base
    for _, index in pairs(indices) do
        local base_key = pool[index]
        assert(handler.validate(graph, graph.nodes[base_key], head))
        if prom.head_candidate_ok(key(head), base_key, needs) then
            chosen = base_key
            break
        end
    end
    choices[key(head)], owners[key(head)] = chosen, handler
    prom.resolve_head(key(head), chosen, needs)
end
handler.reflect(graph, choices, owners)
metadata = data.raw["mod-data"]["propertyrandomizer-biome-placement"].data
assert(metadata.assignments.beta == "everything", "the tenth proposal must recover from a terrain construction cycle")
assert(metadata.assignments.alpha2 == "everything", "the tenth proposal must recover from incompatible native tile rules")
assert(metadata.statistics.everything_draws == 3 and metadata.statistics.everything_kept >= 2)
assert(metadata.rejected == 0)
for name, _ in pairs(infrastructure) do
    assert(draws[name] == nil and metadata.assignments[name] == nil)
end
invariants.test(graph)
handler.release()
print("PASS ten random proposals, repeated-domain reuse, first feasible proposal and clean retries")

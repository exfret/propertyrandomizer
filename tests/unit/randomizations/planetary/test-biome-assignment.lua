function table.deepcopy(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for key, child in pairs(value) do copy[key] = table.deepcopy(child) end
    return copy
end
function log(_) end
config = {planetary_biomes = false}
defines = {prototypes = {entity = {furnace = true}, item = {item = true}}}
package.loaded["__core__/lualib/collision-mask-util"] = {
    get_mask = function(entity) return entity.collision_mask or {layers = {water_tile = true, object = true}} end,
    masks_collide = function(a, b)
        for layer, _ in pairs(a.layers) do if b.layers[layer] then return true end end
        return false
    end,
}
package.loaded["src/lib/random/rng"] = {
    key = function(values) return values.prototype.name end,
    value = function(_) return 0 end,
    int = function(_, count) return count end,
}
package.loaded["src/randomizations/planetary/biomes"] = {}
local gutils = require("src/lib/graph/graph-utils")
local sorts = 0
local function restricted(name)
    return data.raw.furnace[name].tile_buildability_rules ~= nil
end
local check = {
    moved_features = {},
    sort = function(_)
        sorts = sorts + 1
        -- A fixture where each group is safe alone, but accepting both closes a construction cycle.
        local contexts = {}
        for name, _ in pairs(data.raw.furnace) do
            contexts[gutils.key("entity-build", name)] = {home = true}
        end
        return {alpha = restricted("alpha"), alpha2 = restricted("alpha2"), beta = restricted("beta"), sort_info = {node_to_context_inds = contexts}}
    end,
    required = function(_, after)
        return not (after.alpha and after.beta)
    end,
}
package.loaded["src/randomizations/planetary/check"] = check
local placement = require("src/randomizations/planetary/biome-placement")
local function entity(name, upgrade)
    return {name = name, type = "furnace", next_upgrade = upgrade, collision_box = {{-0.4, -0.4}, {0.4, 0.4}}}
end
data = {
    raw = {
        ["collision-layer"] = {water_tile = {}, object = {}},
        tile = {wet = {name = "wet", fluid = "water", collision_mask = {layers = {water_tile = true}}}},
        furnace = {alpha = entity("alpha", "alpha2"), alpha2 = entity("alpha2"), beta = entity("beta")},
        item = {a = {place_result = "alpha"}, a2 = {place_result = "alpha2"}, b = {place_result = "beta"}},
    },
    extend = function(self, entries)
        for _, entry in pairs(entries) do
            self.raw[entry.type] = self.raw[entry.type] or {}
            self.raw[entry.type][entry.name] = entry
        end
    end,
}
local initial_raw = table.deepcopy(data.raw)
local state = {before = {}, variants_of = {}}
placement.execute({}, state)
local report = data.raw["mod-data"]["propertyrandomizer-biome-placement"].data
assert(report.assignments.alpha == "water" and report.assignments.alpha2 == "water")
assert(report.assignments.beta == nil and report.rejected == 1)
assert(report.statistics.eligible == 3 and report.statistics.selected == 3)
assert(report.statistics.restrictive_proposed == 3 and report.statistics.restrictive_kept == 2)
assert(restricted("alpha") and restricted("alpha2") and not restricted("beta"))
assert(data.raw.furnace.beta.collision_mask.layers.water_tile)
assert(state.after.alpha and not state.after.beta)
assert(sorts >= 4)
print("PASS biome batches roll back jointly unsafe assignments")

-- Recipe/mechanic preservation alone can miss an optional building becoming impossible everywhere.
data.raw = table.deepcopy(initial_raw)
check.required = function(_, _) return true end
check.sort = function(_)
    local contexts = {}
    for name, _ in pairs(data.raw.furnace) do
        if name ~= "alpha2" or not restricted(name) then
            contexts[gutils.key("entity-build", name)] = {home = true}
        end
    end
    return {sort_info = {node_to_context_inds = contexts}}
end
placement.execute({}, {before = {}, variants_of = {}})
report = data.raw["mod-data"]["propertyrandomizer-biome-placement"].data
assert(report.assignments.alpha == "water" and report.assignments.alpha2 == nil, "an upgrade target must not couple independent assignments")
assert(report.assignments.beta == "water")
print("PASS optional buildings retain at least one construction context")

-- Support entities bypass the random draw, even when linked to a different policy.
defines.prototypes.entity["arithmetic-combinator"] = true
defines.prototypes.entity["transport-belt"] = true
defines.prototypes.entity["mining-drill"] = true
defines.prototypes.entity["modded-machine"] = true
data.raw = table.deepcopy(initial_raw)
local function add_entity(kind, name, upgrade)
    local value = entity(name, upgrade)
    value.type = kind
    data.raw[kind] = data.raw[kind] or {}
    data.raw[kind][name] = value
    data.raw.item[name] = {place_result = name}
    return value
end
local combinator = add_entity("arithmetic-combinator", "circuit")
combinator.surface_conditions = {{property = "test-surface", min = 1}}
combinator.tile_buildability_rules = {{area = combinator.collision_box, colliding_tiles = {layers = {native_rule = true}}}}
add_entity("transport-belt", "belt", "belt2")
add_entity("transport-belt", "belt2")
add_entity("mining-drill", "drill")
add_entity("modded-machine", "unknown")
add_entity("furnace", "mixed-machine", "mixed-support")
add_entity("arithmetic-combinator", "mixed-support")
local checked_infrastructure = false
check.sort = function(_)
    local contexts = {}
    for kind, _ in pairs(defines.prototypes.entity) do
        for name, value in pairs(data.raw[kind] or {}) do
            contexts[gutils.key("entity-build", name)] = {home = true}
        end
    end
    return {sort_info = {node_to_context_inds = contexts}}
end
check.required = function(_, _)
    if #combinator.tile_buildability_rules > 1 then checked_infrastructure = true end
    return true
end
package.loaded["src/lib/random/rng"].value = function(_) return 1 end
placement.execute({}, {before = {}, variants_of = {}})
report = data.raw["mod-data"]["propertyrandomizer-biome-placement"].data
for _, name in pairs({"circuit", "belt", "belt2", "mixed-support"}) do
    assert(report.assignments[name] == "everything", "infrastructure must not depend on the random draw: " .. name)
end
for _, name in pairs({"alpha", "beta", "drill", "unknown", "mixed-machine"}) do
    assert(report.assignments[name] == nil, "unselected or unsupported groups keep their native rules: " .. name)
end
assert(checked_infrastructure)
assert(report.statistics.eligible == 4 and report.statistics.selected == 0)
assert(report.statistics.restrictive_proposed == 0 and report.statistics.restrictive_kept == 0)
assert(combinator.collision_mask.layers.water_tile == nil)
assert(combinator.collision_mask.layers.object == true)
assert(combinator.surface_conditions[1].property == "test-surface")
assert(combinator.tile_buildability_rules[1].colliding_tiles.layers.native_rule)
assert(combinator.tile_buildability_rules[2].required_tiles.layers.propertyrandomizer_biome_everything)
assert(data.raw["mining-drill"].drill.collision_mask.layers.water_tile)
assert(data.raw["arithmetic-combinator"]["mixed-support"].collision_mask.layers.water_tile == nil)
print("PASS approved infrastructure is unrestricted while native rules and unlisted types are preserved")

-- Upgrade links and shared group names must not change the unit of randomization.
data.raw = table.deepcopy(initial_raw)
for _, value in pairs(data.raw.furnace) do value.fast_replaceable_group = "fixture-upgrades" end
package.loaded["src/lib/random/rng"].value = function(name) return name == "alpha" and 0 or 1 end
check.required = function(_, _) return true end
placement.execute({}, {before = {}, variants_of = {}})
report = data.raw["mod-data"]["propertyrandomizer-biome-placement"].data
assert(report.assignments.alpha == "water")
assert(report.assignments.alpha2 == nil, "each linked prototype must receive its own random draw")
assert(data.raw.furnace.alpha.fast_replaceable_group == "fixture-upgrades")
assert(data.raw.furnace.alpha2.fast_replaceable_group == "fixture-upgrades")
print("PASS independent draws preserve fast-replaceable groups")

-- A mod can supply terrain that has no registered profile; removing Normal must not create an empty random draw.
data.raw = table.deepcopy(initial_raw)
data.raw.tile.wet.fluid = nil
placement.execute({}, {before = {}, variants_of = {}})
report = data.raw["mod-data"]["propertyrandomizer-biome-placement"].data
assert(next(report.assignments) == nil and report.statistics.selected == 0)
print("PASS unclassified terrain keeps original placement without a Normal entry")

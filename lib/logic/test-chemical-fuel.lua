-- Plain-Lua regression test: lua lib/logic/test-chemical-fuel.lua
-- The protected fuel mechanic must accept the replacement fuel attached to a resource position in first pass.

package.loaded["lib/random/rng"] = {}
package.loaded["__core__/lualib/collision-mask-util"] = {}
package.loaded["lib/trigger"] = {}
local state = {
    contexts = { home = true },
    type_info = {},
}
package.loaded["lib/logic/state"] = state
local gutils = require("lib/graph/graph-utils")
local dutils = require("lib/data-utils")
local fcat_name = gutils.concat({
    dutils.REPLACEMENT_FUEL_CATEGORY,
    0,
})
-- The original fuel identity is deliberately unavailable in the replacement case.
package.loaded["lib/lookup/init"] = {
    fcat_to_items = {
        [fcat_name] = { ["original-fuel-trav"] = true },
    },
}
local logic_group = require("lib/logic/logic-group")
local graph_setup = require("lib/logic/graph-setup")
local builder = require("lib/logic/builder")
local abstract = require("lib/logic/abstract")
local categories = require("helper-tables/categories")
local lutils = require("lib/logic/logic-utils")
local fuel_lookups = require("lib/lookup/2-simple/fuel")
local top = require("lib/graph/context-sort")
local key = gutils.key
local mechanic_key = key("chemical-fuel", "")

-- Derive the burner combinations through the production lookup, using an entity type that supports an energy source.
local entity_type, energy_properties = next(categories.energy_sources_input)
local energy_property = dutils.tablize(energy_properties)[1]
local burner_lookups = { entities = {} }
local burner_names = {}
for index, burnt_size in pairs({
    0,
    1,
}) do
    local energy_source = {
        type = "burner",
        fuel_categories = { dutils.REPLACEMENT_FUEL_CATEGORY },
        burnt_inventory_size = burnt_size,
    }
    burner_lookups.entities[index] = {
        type = entity_type,
        [energy_property] = energy_source,
    }
    burner_names[index] = lutils.fcat_combo_name(energy_source)
end
fuel_lookups.link(burner_lookups)
fuel_lookups.fcat_combos()

local function fixture(has_category)
    local graph = {}
    state.type_info = {}
    local function node(kind, name, op)
        state.type_info[kind] = { op = op }
        return gutils.add_node(graph, kind, name, { op = op })
    end
    local source = node("source", "mine", "AND")
    local position = node("item", "fuel-position", "OR")
    local original = node("item", "original-fuel-trav", "OR")
    local replacement = node("item", "replacement-trav", "OR")
    gutils.add_edge(graph, source, position)
    gutils.add_edge(graph, position, replacement)
    if has_category then
        local category = node("fuel-category", fcat_name, "OR")
        -- First pass keeps the position's fuel edge and gives the original identity its own fuel edge.
        gutils.add_edge(graph, position, category)
        gutils.add_edge(graph, original, category)
    end
    local fuels = has_category and { [fcat_name] = {} } or {}
    builder.init(graph, state.type_info, {})
    builder.set_class("energy-source")
    builder.set_prot(nil)
    abstract.build_burners({
        fcat_combos = burner_lookups.fcat_combos,
        fcat_to_items = fuels,
    })
    logic_group.build(graph, state.type_info)
    state.graph = graph
    graph_setup.build(state)
    return graph, position, original, replacement
end

local function reached(sorted, node_key)
    return (sorted.node_to_context_inds[node_key] or {}).home ~= nil
end

local graph, position, original, replacement = fixture(true)
local sorted = top.sort(graph)
assert(reached(sorted, key(replacement)), "the resource position must provide the replacement identity")
assert(not reached(sorted, key(original)), "the original fuel identity must remain unavailable in this fixture")
assert(reached(sorted, mechanic_key), "the replacement fuel must satisfy the protected fuel mechanic")
assert(graph.nodes[mechanic_key].mechanic == true, "fuel availability must remain protected")
local clean_burner = key("energy-source-burner", burner_names[1])
local residue_burner = key("energy-source-burner", burner_names[2])
assert(reached(sorted, clean_burner), "replacement fuel must power burners without requiring its original identity")
assert(reached(sorted, residue_burner), "burners with residue capacity must also accept clean fuel")

-- Without the position's fuel edge, an ordinary fuel identity can still satisfy the same mechanic.
local category_key = key("fuel-category", fcat_name)
gutils.remove_edge(graph, gutils.ekey({
    start = key(position),
    stop = category_key,
}))
assert(not reached(top.sort(graph), mechanic_key), "a non-fuel replacement must not satisfy the mechanic")
assert(not reached(top.sort(graph), clean_burner), "a non-fuel replacement must not power burners")
gutils.add_edge(graph, key("source", "mine"), key(original))
assert(reached(top.sort(graph), mechanic_key), "an available original fuel must still satisfy the mechanic")
assert(reached(top.sort(graph), clean_burner), "original fuel must still power burners")

-- Games without the category retain an unsatisfied mechanic instead of a dangling prerequisite.
local no_fuel = fixture(false)
assert(no_fuel.nodes[mechanic_key].num_pre == 0)
assert(not reached(top.sort(no_fuel), mechanic_key), "no fuel must not become a free mechanic")
assert(not reached(top.sort(no_fuel), clean_burner), "no fuel must not provide burner power")

-- A residue-producing fuel works only for a burner that accepts burnt results.
local burnt_name = gutils.concat({
    dutils.REPLACEMENT_FUEL_CATEGORY,
    1,
})
local residue_only = {}
local residue_types = {}
gutils.add_node(residue_only, "fuel-category", burnt_name)
residue_types["fuel-category"] = { op = "AND" }
builder.init(residue_only, residue_types, {})
abstract.build_burners({
    fcat_combos = burner_lookups.fcat_combos,
    fcat_to_items = { [burnt_name] = {} },
})
state.graph = residue_only
state.type_info = residue_types
graph_setup.build(state)
local residue_sort = top.sort(residue_only)
assert(not reached(residue_sort, clean_burner), "clean-only burners must reject fuels with burnt results")
assert(reached(residue_sort, residue_burner), "burners with residue capacity must accept those fuels")
local fuel_edge = residue_only.edges[next(residue_only.nodes[residue_burner].pre)]
assert(fuel_edge.amount == 1, "burner costs must still consume one MJ through the category node")
print("ok - replacement fuel powers burners and satisfies the fuel mechanic; absent and incompatible fuels do not")

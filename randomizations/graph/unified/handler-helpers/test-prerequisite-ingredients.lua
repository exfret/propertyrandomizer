-- Run from the mod root: lua randomizations/graph/unified/handler-helpers/test-prerequisite-ingredients.lua
local gutils = require("lib/graph/graph-utils")
package.loaded["lib/lookup/init"] = { rcats = {} }
local chooser = require("randomizations/graph/unified/handler-helpers/prerequisite-ingredients")

function table.deepcopy(value)
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for k, v in pairs(value) do
        copy[k] = table.deepcopy(v)
    end
    return copy
end
function log(message) end

local material_type = "item"
local function ing(name, amount)
    return {
        type = material_type,
        name = name,
        amount = amount,
    }
end

local function run(has_candidate)
    data = { raw = { recipe = {} } }
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local owners = {}
    local candidates = {}
    local function recipe(name, ingredients, in_pool)
        data.raw.recipe[name] = {
            name = name,
            ingredients = ingredients,
        }
        local dep = gutils.add_node(graph, "recipe", name, { op = "AND" })
        for index, ingredient in pairs(ingredients) do
            local material_key = gutils.key(ingredient)
            if graph.nodes[material_key] == nil then
                gutils.add_node(graph, ingredient.type, ingredient.name, { op = "OR" })
            end
            local edge = gutils.add_edge(graph, material_key, gutils.key(dep), { inds = { [index] = true } })
            local connection = gutils.subdivide_base_head(graph, gutils.ekey(edge))
            if in_pool == true then
                table.insert(candidates, gutils.key(connection.base))
            end
            owners[material_key] = material_key
        end
        return gutils.key(dep)
    end
    local target = recipe("target", {
        ing("missing", 7),
        ing("healthy", 3),
    })
    recipe("candidate-source", { ing("unpriced-resource", 200) }, true)
    recipe("cycle-source", { ing("circular", 1) }, true)
    -- Circular first: selection must skip it rather than relying on pool order.
    candidates[1], candidates[2] = candidates[2], candidates[1]
    local resolved
    local prom = {}
    prom.required_contexts = function() return { "A" } end
    prom.recipe_boundary_contexts = function() return { "A" } end
    prom.pins_for = function() return {} end
    prom.vanilla_owner = function(_, material) return owners[gutils.key(material)] end
    prom.pays = function(_, owner)
        return owner == gutils.key(material_type, "healthy") or (has_candidate and owner == gutils.key(material_type, "unpriced-resource"))
    end
    prom.candidate_ok = function(_, owner)
        return has_candidate and owner == gutils.key(material_type, "unpriced-resource")
    end
    prom.resolve = function(_, owner_keys) resolved = owner_keys end
    local overrides = chooser.choose({
        random_graph = graph,
        promotion = prom,
        head_to_base = {},
        sorted_deps = { target },
        shuffled_prereqs = candidates,
    })
    assert(resolved ~= nil)
    assert(data.raw.recipe.target.ingredients[1].name == "missing", "Selection must wait for reflection")
    return overrides
end

local chosen = run(true).target
assert(chosen[1].name == "unpriced-resource", "A valid resource must be allowed without any production-cost quote")
assert(chosen[1].amount == 7, "A replacement keeps the dependent's amount")
assert(chosen[2].name == "healthy" and chosen[2].amount == 3, "A satisfied ingredient stays unchanged")
print("ok - repair chooses an unpriced resource, skips a circular candidate and preserves satisfied ingredients")
assert(run(false).target == nil, "An unavailable candidate must not produce a reflected change")
print("ok - no available replacement preserves the original ingredients")

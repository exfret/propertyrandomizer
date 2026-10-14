-- Kept ingredient uses contribute pool entries without destination or head nodes.
-- Uses of the same input share one terminal base; fluid temperature ranges remain distinct inputs.
local gutils = require("src/lib/graph/graph-utils")

local pool = {}

-- This descriptor preserves the old destination's customization and explicit blacklist keys.
local function destination(recipe_name, source_key)
    return {
        type = "recipe-ingredient-kept-spot",
        name = gutils.concat({
            recipe_name,
            source_key,
        }),
        prot = gutils.key("recipe", recipe_name),
        spoof = true,
    }
end

pool.collect = function(graph, recipes, rules, as_material)
    local spots = {}
    for _, node in pairs(graph.nodes) do
        local recipe = node.type == "recipe" and recipes[node.name] or nil
        if recipe ~= nil and recipe.hidden ~= true then
            for edge_key, _ in pairs(node.pre) do
                local source = graph.nodes[graph.edges[edge_key].start]
                if source.type == "item" or source.type == "fluid" or source.type == "fluid-temperature-range" then
                    local material = as_material(source)
                    if rules.kept_use(material, recipe.name) then
                        table.insert(spots, {
                            source_key = gutils.key(source),
                            material_key = gutils.key(material),
                            recipe_name = recipe.name,
                        })
                    end
                end
            end
        end
    end
    table.sort(spots, function(a, b)
        if a.recipe_name ~= b.recipe_name then
            return a.recipe_name < b.recipe_name
        end
        return a.source_key < b.source_key
    end)
    return spots
end

-- Called after ordinary claiming, before any pool or first-pass sort.
-- Selection still applies per use, and each selected reachable use retains its own multiplicity.
pool.add = function(graph, spots, sort_info, can_claim, copies_for, as_material)
    local entries = {}
    local bases = {}
    for _, spot in pairs(spots) do
        local source = graph.nodes[spot.source_key]
        local contexts = sort_info.node_to_context_inds[spot.source_key] or {}
        if source ~= nil and next(contexts) ~= nil and can_claim(source, destination(spot.recipe_name, spot.source_key)) then
            local num_copies = copies_for(as_material(source))
            if num_copies > 0 then
                local base_key = bases[spot.source_key]
                if base_key == nil then
                    base_key = gutils.key("base", gutils.concat({
                        "recipe-ingredient-pool",
                        spot.source_key,
                    }))
                    assert(graph.nodes[base_key] == nil, "ingredient pool base already exists")
                    gutils.add_node(graph, "base", gutils.deconstruct(base_key).name, {
                        op = "AND",
                        pool_only = true,
                    })
                    gutils.add_edge(graph, spot.source_key, base_key)
                    bases[spot.source_key] = base_key
                end
                table.insert(entries, {
                    base_key = base_key,
                    num_copies = num_copies,
                })
            end
        end
    end
    local num_bases = 0
    for _, _ in pairs(bases) do
        num_bases = num_bases + 1
    end
    return entries, num_bases
end

-- Pool-only candidates let the chooser pick amounts, without looking up an old head.
-- Ordinary candidates retain their original ingredient bounds and other fields.
pool.ingredient = function(graph, base, material, recipes)
    local owner
    if base.pool_only ~= true then
        owner = gutils.get_owner(graph, assert(graph.nodes[base.old_head]))
    end
    if base.pool_only == true or owner.spoof == true then
        return {
            type = material.type,
            name = material.name,
            amount = 1,
        }
    end
    local ingredient_ind
    for ind, _ in pairs(base.inds) do
        assert(ingredient_ind == nil, "ingredient base has multiple indices")
        ingredient_ind = ind
    end
    assert(ingredient_ind ~= nil, "ingredient base has no index")
    return recipes[owner.name].ingredients[ingredient_ind]
end

return pool

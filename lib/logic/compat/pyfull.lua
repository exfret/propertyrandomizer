local lib_name = "lib"
local categories = require("helper-tables/categories")
local cutils = require("lib/cost/cost-utils")
local dutils = require(lib_name .. "/data-utils")
local gutils = require(lib_name .. "/graph/graph-utils")
local lutils = require(lib_name .. "/logic/logic-utils")
local builder = require(lib_name .. "/logic/builder")

local prots = dutils.prots
local key = gutils.key
local concat = gutils.concat
local add_node = builder.add_node
local add_edge = builder.add_edge
local set_class = builder.set_class
local set_prot = builder.set_prot

-- Py smart farm files
local farm_specs = {}
for _, farm_file in pairs({"arum", "bioreserve", "grod", "kicalk", "ralesia", "rennea", "tuuphra", "yotoi-fruit", "yotoi"}) do
    table.insert(farm_specs, require("__pyalienlife__/scripts/smart-farm/farm-" .. farm_file))
end

local compat = {}

function compat.build(graph, lu)
    set_class("compat")
    set_prot(nil)

    -- Smart farms

    for _, spec in pairs(farm_specs) do
        local node_name = "smart-farm-" .. spec.crop
        
        add_edge("logic-and", node_name, { amount = 1 }, "entity", spec.crop)

        ----------------------------------------
        add_node("logic-and", "AND", nil, node_name)
        ----------------------------------------
        -- Can we provide what's needed to make a smart farm output this resource?

        -- Reduces to an entity-operate because there is no fixed_recipe
        add_edge("entity-rocket-silo", "mega-farm")
        add_edge("logic-or", node_name .. "-recipe", { amount = 1 })

        ----------------------------------------
        add_node("logic-or", "OR", nil, node_name .. "-recipe")
        ----------------------------------------
        -- Can we craft a recipe in a smart farm creating this resource? (Just consider the ingredients).

        for _, recipe_data in pairs(spec.recipes) do
            local recipe = data.raw.recipe[recipe_data.recipe_name]
            -- All smart farm recipes should have just one result, with amount giving the amount of entities
            add_edge("logic-and", node_name .. "-recipe-" .. recipe_data.recipe_name, { amount = cutils.find_amount_in_entry(recipe.results[1]) })
        end

        for _, recipe_data in pairs(spec.recipes) do
            ----------------------------------------
            add_node("logic-and", "AND", nil, node_name .. "-recipe-" .. recipe_data.recipe_name)
            ----------------------------------------
            -- Can we get the ingredients for this specific smart farm recipe

            local recipe = data.raw.recipe[recipe_data.recipe_name]
            local ingredient_map = lu.mat_recipe_map.recipe[recipe.name].ingredients
            for mat_key, inds in pairs(ingredient_map) do
                local mat = gutils.deconstruct(mat_key)
                local mat_type = mat.type
                local mat_name = mat.name
                if mat.type == "fluid" then
                    mat_type = "fluid-temperature-range"
                end
                local result_amount = cutils.find_amount_in_ing_or_prod(recipe.ingredients, {type = mat.type, name = mat.name})
                add_edge(mat_type, mat_name, {
                    inds = inds,
                    amount = result_amount,
                })
            end
        end
    end

    -- Nexelit mines

    -- Nexelit crafts 4000 at once, so to make it reasonably priced, make it require a lot of food
    add_edge("logic-or", "workers-food-or-meat", { amount = 4000 }, "recipe", "digosaurus-hidden-recipe")
    add_edge("logic-or", "nexelit-animal", nil, "recipe", "digosaurus-hidden-recipe")
    ----------------------------------------
    add_node("logic-or", "OR", nil, "nexelit-animal")
    ----------------------------------------
    -- Can we provide this biopyanoport with an animal to work in it?
    for _, mod in pairs(data.raw.module) do
        if mod.category == "digosaurus" then
            add_edge("item", mod.name)
        end
    end
    -- Extra cost for mining since nexelit is a pain
    add_edge("cost-unit", "", { amount = 4000 * 5 }, "recipe", "digosaurus-hidden-recipe")
    -- Dig site already required through crafting machine

    -- biopyanoport/guano

    add_edge("logic-or",  "workers-food", { amount = 1 }, "recipe", "bioport-hidden-recipe")

    add_edge("logic-or", "bioport-hidden-recipe-animal", nil, "recipe", "bioport-hidden-recipe")
    ----------------------------------------
    add_node("logic-or", "OR", nil, "bioport-hidden-recipe-animal")
    ----------------------------------------
    -- Can we provide this biopyanoport with an animal to work in it?
    add_edge("item", "chorkok")
    add_edge("item", "huzu")
    add_edge("item", "gobachov")

    add_edge("logic-and", "bioport-hidden-recipe-logistic-component", nil, "recipe", "bioport-hidden-recipe")
    ----------------------------------------
    add_node("logic-and", "AND", nil, "bioport-hidden-recipe-logistic-component")
    ----------------------------------------
    -- Can we provide this biopyanoport with the provider and requester to allow animals to actually work?
    add_edge("entity-operate", "provider-tank")
    add_edge("entity-operate", "requester-tank")

    -- Worker's food (used in several spots)

    ----------------------------------------
    add_node("logic-or", "OR", nil, "workers-food-or-meat")
    ----------------------------------------
    -- Can we provide this biopyanoport with food?
    add_edge("item", "dried-meat", { amount = 1 })
    add_edge("item", "guts", { amount = 1 })
    add_edge("item", "meat", { amount = 1 })
    add_edge("logic-or", "workers-food")

    ----------------------------------------
    add_node("logic-or", "OR", nil, "workers-food")
    ----------------------------------------
    -- Can we provide this biopyanoport with food?
    add_edge("item", "workers-food", { amount = 1 })
    add_edge("item", "workers-food-02", { amount = 1 })
    add_edge("item", "workers-food-03", { amount = 1 })
end

return compat
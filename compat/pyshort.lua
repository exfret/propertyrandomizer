local gutils = require("lib/graph/graph-utils")
local dutils = require("lib/data-utils")

local key = gutils.key

-- Blacklist canisters
for _, recipe in pairs(data.raw.recipe) do
    if string.find(recipe.name, "canister") ~= nil then
        randomization_info.options.first_pass.blacklist[key("recipe", recipe.name)] = true
    end
end
for class, _ in pairs(defines.prototypes.item) do
    if data.raw[class] ~= nil then
        for _, item in pairs(data.raw[class]) do
            if string.find(item.name, "canister") ~= nil then
                randomization_info.options.first_pass.blacklist[key("item", item.name)] = true
            end
        end
    end
end
-- Blacklist productivity modules in py; too sensitive
--[[randomization_info.options.first_pass.blacklist[key("item", "productivity-module")] = true
randomization_info.options.first_pass.blacklist[key("item", "productivity-module-2")] = true
randomization_info.options.first_pass.blacklist[key("item", "productivity-module-3")] = true]]

local short_py_cost_table_additions = {
    ["fluid-bitumen"] = 0.2,
    ["fluid-bitumen-froth"] = 0.2,
    ["fluid-naphtha"] = 0.2,
    ["fluid-pressured-air"] = 0.05,
    ["item-oil-sand"] = 1,
}
for k, v in pairs(short_py_cost_table_additions) do
    randomization_info.options.cost.default_cost_table[k] = v
end

for _, machine_name in pairs({"barrel-machine-mk01", "slaughterhouse-mk01", "py-burner", "py-gas-vent", "py-sinkhole", "compost-plant-mk01"}) do
    local machine = dutils.get_prot("entity", machine_name)
    if machine ~= nil then
        local machine_cats = machine.crafting_categories or {"crafting"}
        for _, recipe in pairs(data.raw.recipe) do
            -- Don't check for fluids, just do a dumb check for some matching category
            local compatible = false
            for _, cat in pairs(recipe.categories or {"crafting"}) do
                for _, cat2 in pairs(machine_cats) do
                    if cat == cat2 then
                        compatible = true
                    end
                end
            end
            if compatible then
                -- Just assume there are at most 4 input/output fluids
                -- If we need to blacklist a category with a recipe having more, increase this number
                for input_fluids = 0, 4 do
                    for output_fluids = 0, 4 do
                        local recipe_categories = table.deepcopy(recipe.categories)
                        table.sort(recipe_categories);
                        ((randomization_info.options.unified["recipe-category"] or {}).blacklisted_pre or {})[key("recipe-category", gutils.concat({gutils.concat(recipe_categories), tostring(input_fluids), tostring(output_fluids)}))] = true
                    end
                end
            end
        end
    end
end
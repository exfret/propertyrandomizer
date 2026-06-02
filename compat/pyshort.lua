local gutils = require("new-lib/graph/graph-utils")

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
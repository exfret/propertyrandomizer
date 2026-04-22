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
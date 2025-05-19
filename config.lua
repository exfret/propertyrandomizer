local spec = require("helper-tables/spec")

global_seed = settings.startup["propertyrandomizer-seed"].value

local bias_string_to_num = {
    ["worst"] = -0.06,
    ["worse"] = -0.03,
    ["default"] = 0,
    ["better"] = 0.03,
    ["best"] = 0.06
}

global_bias = bias_string_to_num[settings.startup["propertyrandomizer-bias"].value]

local chaos_string_to_num = {
    ["light"] = 0.3,
    ["less"] = 0.7,
    ["default"] = 1,
    ["more"] = 1.75,
    ["ultimate"] = 3.5
}

global_chaos = chaos_string_to_num[settings.startup["propertyrandomizer-chaos"].value]

local setting_values = {
    none = 0,
    less = 1,
    default = 2,
    more = 3,
    most = 4
}

randomizations_to_perform = {}
for id, rand_info in pairs(spec) do
    if rand_info.setting == "none" then
        randomizations_to_perform[id] = false
    elseif type(rand_info.setting) == "table" then

        if setting_values[settings.startup[rand_info.setting.name].value] >= setting_values[rand_info.setting.val] then
            randomizations_to_perform[id] = true
        else
            randomizations_to_perform[id] = false
        end
    elseif type(rand_info.setting) == "string" then
        if settings.startup[rand_info.setting].value then
            randomizations_to_perform[id] = true
        else
            randomizations_to_perform[id] = false
        end
    else
        -- Setting key not set by mistake
        error()
    end
end

-- Overrides
for override in string.gmatch(settings.startup["propertyrandomizer-overrides"].value, "([^;]+)") do
    local new_val = true
    if string.sub(override, 1, 1) == "!" then
        new_val = false
        override = string.sub(override, 2, -1)
    end

    -- Check if the override was in the spec
    if spec[override] ~= nil then
        randomizations_to_perform[override] = new_val
    else
        table.insert(randomization_info.warnings, "[img=item.propertyrandomizer-gear] [color=red]exfret's Randomizer:[/color] Override randomization with ID \"[color=blue]" .. override .. "[/color]\" does not exist; this override was skipped.\nMake sure the overrides are spelled and formatted correctly without spaces and separated by semicolons ;")
    end
end

-- Should we build the dependency graph?
randomization_info.options.build_graph = true
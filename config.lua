local constants = require("helper-tables/constants")
local spec = require("helper-tables/spec")

global_seed = settings.startup["propertyrandomizer-seed"].value

if settings.startup["propertyrandomizer-watch-the-world-burn"].value then
    settings.startup["propertyrandomizer-bias"].value = "worst"
    settings.startup["propertyrandomizer-chaos"].value = "ultimate"
    settings.startup["propertyrandomizer-dupes"].value = true
    settings.startup["propertyrandomizer-logistic"].value = "more"
    settings.startup["propertyrandomizer-production"].value = "more"
    settings.startup["propertyrandomizer-military"].value = "more"
    settings.startup["propertyrandomizer-misc"].value = "more"
    settings.startup["propertyrandomizer-technology"].value = true
    settings.startup["propertyrandomizer-recipe"].value = true
    settings.startup["propertyrandomizer-recipe-tech-unlock"].value = true
    settings.startup["propertyrandomizer-item"].value = true
    settings.startup["propertyrandomizer-item-percent"].value = 100
end

local bias_string_to_num = {
    ["worst"] = -0.05,
    ["worse"] = -0.025,
    ["default"] = 0,
    ["better"] = 0.025,
    ["best"] = 0.05
}

local bias_string_to_idx = {
    ["worst"] = 0,
    ["worse"] = 1,
    ["default"] = 2,
    ["better"] = 3,
    ["best"] = 4,
}

global_bias = bias_string_to_num[settings.startup["propertyrandomizer-bias"].value]
global_bias_idx = bias_string_to_idx[settings.startup["propertyrandomizer-bias"].value]

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

-- Valid levels are "none", "minimal", "default", and "verbose"
-- Currently not implemented yet
randomization_info.options.logging = "default"
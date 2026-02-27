local constants = require("helper-tables/constants")
local spec = require("helper-tables/spec")

global_seed = settings.startup["propertyrandomizer-seed"].value + 23

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

local bias_string_to_num = constants.bias_string_to_num
local bias_string_to_idx = constants.bias_string_to_idx
global_bias = bias_string_to_num[settings.startup["propertyrandomizer-bias"].value]
global_bias_idx = bias_string_to_idx[settings.startup["propertyrandomizer-bias"].value]

local chaos_string_to_num = constants.chaos_string_to_num
local chaos_string_to_idx = constants.chaos_string_to_idx
local chaos_string_to_range_num = constants.chaos_string_to_range_num
global_chaos = chaos_string_to_num[settings.startup["propertyrandomizer-chaos"].value]
global_chaos_idx = chaos_string_to_idx[settings.startup["propertyrandomizer-chaos"].value]
global_chaos_range = chaos_string_to_range_num[settings.startup["propertyrandomizer-chaos"].value]

local setting_values = constants.setting_values

randomizations_to_perform = {}
for id, rand_info in pairs(spec) do
    local order = 10
    if rand_info.order ~= nil then
        order = rand_info.order
    end

    if randomizations_to_perform[order] == nil then
        randomizations_to_perform[order] = {}
    end
    local order_group = randomizations_to_perform[order]

    if rand_info.setting == "none" then
        order_group[id] = false
    elseif type(rand_info.setting) == "table" then

        if setting_values[settings.startup[rand_info.setting.name].value] >= setting_values[rand_info.setting.val] then
            order_group[id] = true
        else
            order_group[id] = false
        end
    elseif type(rand_info.setting) == "string" then
        if settings.startup[rand_info.setting].value then
            order_group[id] = true
        else
            order_group[id] = false
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
        for _, order_group in pairs(randomizations_to_perform) do
            if order_group[override] ~= nil then
                order_group[override] = new_val
            end
        end
    else
        table.insert(randomization_info.warnings, "[img=item.propertyrandomizer-gear] [color=red]exfret's Randomizer:[/color] Override randomization with ID \"[color=blue]" .. override .. "[/color]\" does not exist; this override was skipped.\nMake sure the overrides are spelled and formatted correctly without spaces and separated by semicolons ;")
    end
end

-- Valid levels are "none", "minimal", "default", and "verbose"
-- Currently not implemented yet
randomization_info.options.logging = "default"
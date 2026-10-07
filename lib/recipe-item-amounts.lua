-- Recipe amounts must follow the final physical item, after reflection changes identities.
local dutils = require("lib/data-utils")

local amounts = {}

amounts.apply = function(raw)
    local items = {}
    for item_class, _ in pairs(defines.prototypes.item) do
        for name, item in pairs(raw[item_class] or {}) do
            items[name] = item
        end
    end
    local corrected = 0
    for _, recipe in pairs(raw.recipe or {}) do
        for _, field in pairs({
            "ingredients",
            "results",
        }) do
            for _, entry in pairs(recipe[field] or {}) do
                local item = entry.type == "item" and items[entry.name] or nil
                if item ~= nil and not dutils.is_stackable(item) then
                    local changed = false
                    for _, amount_field in pairs({
                        "amount",
                        "amount_min",
                        "amount_max",
                    }) do
                        if entry[amount_field] ~= nil and entry[amount_field] > 1 then
                            entry[amount_field] = 1
                            changed = true
                        end
                    end
                    -- A fractional extra product added to one guaranteed item can yield two.
                    local maximum = entry.amount or math.max(entry.amount_min or 0, entry.amount_max or 0)
                    if field == "results" and maximum >= 1 and (entry.extra_count_fraction or 0) > 0 then
                        entry.extra_count_fraction = 0
                        changed = true
                    end
                    if changed then
                        corrected = corrected + 1
                    end
                end
            end
        end
    end
    return corrected
end

return amounts

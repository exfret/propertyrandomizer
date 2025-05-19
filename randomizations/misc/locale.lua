local rng = require("lib/random/rng")
local locale_utils = require("lib/locale")

randomizations.all_names = function(id)
    local type_names = {}
    local localised_names = {}
    for _, class in pairs(data.raw) do
        for _, prototype in pairs(class) do
            if locale_utils.find_localised_name(prototype) ~= nil then
                table.insert(type_names, {type = prototype.type, name = prototype.name})
                table.insert(localised_names, {"?", locale_utils.find_localised_name(prototype), locale_utils.capitalize(prototype.name)})
            end
        end
    end

    rng.shuffle(rng.key({id = id}), localised_names)

    for ind, type_name in pairs(type_names) do
        data.raw[type_name.type][type_name.name].localised_name = localised_names[ind]
    end
end
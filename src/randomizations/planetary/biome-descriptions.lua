local locale = require("src/localisation/locale")
local profiles = require("src/randomizations/planetary/biome-profiles")
local text = require("src/localisation/localised-text")

local descriptions = {}

-- Use finished rules, including copies and postfixes, rather than the initial assignment report.
descriptions.apply = function(raw, prototype_types)
    local changed = {}
    for kind, _ in pairs(prototype_types.entity) do
        for name, entity in pairs(raw[kind] or {}) do
            local parts, seen = {}, {}
            if entity.hidden ~= true and string.sub(name, 1, 4) ~= "old-" then
                for _, rule in pairs(entity.tile_buildability_rules or {}) do
                    for _, profile in pairs(profiles.order) do
                        if ((rule.required_tiles or {}).layers or {})[profiles.layer(profile)] == true and not seen[profile] then
                            seen[profile] = true
                            table.insert(parts, {"propertyrandomizer-biomes.description", {"propertyrandomizer-biome-profile." .. profile}})
                        end
                    end
                end
            end
            if #parts > 0 then
                changed[name] = {entity = entity, summary = text.join(parts, "\n")}
            end
        end
    end
    -- Items with their own descriptions do not automatically inherit an entity's added text.
    for kind, _ in pairs(prototype_types.item) do
        for _, item in pairs(raw[kind] or {}) do
            local entry = changed[item.place_result]
            if entry ~= nil and item.hidden ~= true and string.sub(item.name, 1, 4) ~= "old-" then
                local prior = locale.find_localised_description(item)
                if item.localised_description == nil then
                    prior = {"?", {"item-description." .. item.name}, locale.find_localised_description(entry.entity)}
                end
                item.localised_description = {"", prior, "\n", entry.summary}
            end
        end
    end
    for _, entry in pairs(changed) do
        entry.entity.localised_description = {"", locale.find_localised_description(entry.entity), "\n", entry.summary}
    end
end

return descriptions

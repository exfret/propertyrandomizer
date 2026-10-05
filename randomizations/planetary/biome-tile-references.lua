-- Visual tile clones must remain interchangeable with their source in name-based rules.
-- Verified against the installed 2.1.20 prototype API: PlaceAsTile.tile_condition, AutoplaceSpecification.tile_restriction, TilePrototype.allowed_neighbors and SelectionModeData.tile_filters.
-- TileBuildabilityRule uses collision layers, not names.
local tile_references = {}

tile_references.extend = function(raw, clones_of)
    local extended = {}

    local function extend_names(names)
        if type(names) ~= "table" or extended[names] == true then
            return
        end
        extended[names] = true
        local seen_names = {}
        local seen_pairs = {}
        local original = {}
        for _, entry in pairs(names) do
            table.insert(original, entry)
            if type(entry) == "string" then
                seen_names[entry] = true
            elseif type(entry) == "table" then
                local first, second = entry[1], entry[2]
                if type(first) == "string" and type(second) == "string" then
                    seen_pairs[first] = seen_pairs[first] or {}
                    seen_pairs[first][second] = true
                end
            end
        end

        for _, entry in pairs(original) do
            if type(entry) == "string" then
                for _, clone_name in pairs(clones_of[entry] or {}) do
                    if seen_names[clone_name] ~= true then
                        table.insert(names, clone_name)
                        seen_names[clone_name] = true
                    end
                end
            elseif type(entry) == "table" then
                local first, second = entry[1], entry[2]
                if type(first) == "string" and type(second) == "string" then
                    local first_names = { first }
                    local second_names = { second }
                    for _, clone_name in pairs(clones_of[first] or {}) do
                        table.insert(first_names, clone_name)
                    end
                    for _, clone_name in pairs(clones_of[second] or {}) do
                        table.insert(second_names, clone_name)
                    end
                    for _, first_name in pairs(first_names) do
                        seen_pairs[first_name] = seen_pairs[first_name] or {}
                        for _, second_name in pairs(second_names) do
                            if seen_pairs[first_name][second_name] ~= true then
                                table.insert(names, {
                                    first_name,
                                    second_name,
                                })
                                seen_pairs[first_name][second_name] = true
                            end
                        end
                    end
                end
            end
        end
    end

    for _, group in pairs(raw) do
        for _, prototype in pairs(group) do
            if type(prototype) == "table" then
                if type(prototype.place_as_tile) == "table" then
                    extend_names(prototype.place_as_tile.tile_condition)
                end
                if type(prototype.autoplace) == "table" then
                    extend_names(prototype.autoplace.tile_restriction)
                end
                extend_names(prototype.allowed_neighbors)
                -- Selection modes may whitelist or blacklist tiles. Both must include clones.
                for _, property in pairs(prototype) do
                    if type(property) == "table" and property.mode ~= nil then
                        extend_names(property.tile_filters)
                    end
                end
            end
        end
    end
end

return tile_references

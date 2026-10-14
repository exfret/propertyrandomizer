local tests = {}

tests.run = function()
    local setting = settings.startup["propertyrandomizer-planetary-biome-placement"]
    if setting == nil or not setting.value then return end
    local report = prototypes.mod_data["propertyrandomizer-biome-placement"]
    assert(report ~= nil, "PRTEST biome-placement stage unexpectedly rolled back")
    local changed = false
    for _, profile in pairs(report.data.assignments) do
        changed = changed or profile ~= "normal"
    end
    assert(changed, "PRTEST biome-placement made no non-Normal assignments")
    local surface = game.create_surface("prtest-biome-placement", {width = 32, height = 32})
    surface.request_to_generate_chunks({0, 0}, 1)
    surface.force_generate_chunk_requests()
    for _, entity in pairs(surface.find_entities()) do entity.destroy() end
    local layouts = {
        forest = {"forest", "forest"},
        water = {"water", "water"},
        mixed = {"forest", "water"},
        platform = {"platform", "platform"},
        void = {"void", "void"},
    }
    local expected = {
        forest = {normal = true, forest = true, water = false, everything = true},
        water = {normal = false, forest = false, water = true, everything = true},
        mixed = {normal = false, forest = false, water = false, everything = true},
        platform = {normal = true, forest = true, water = true, everything = true},
        void = {normal = false, forest = false, water = false, everything = false},
    }
    for layout, tiles in pairs(layouts) do
        local entries = {}
        for x = -4, 3 do
            for y = -4, 3 do
                table.insert(entries, {name = "prtest-biome-" .. tiles[x < 0 and 1 or 2], position = {x, y}})
            end
        end
        surface.set_tiles(entries, false)
        for profile, wanted in pairs(expected[layout]) do
            local allowed = surface.can_place_entity({name = "prtest-biome-" .. profile, position = {0, 0.5}, force = "player"})
            assert(allowed == wanted, "PRTEST biome-placement " .. profile .. " on " .. layout .. " unexpectedly " .. tostring(allowed))
            local mask_allowed = surface.can_place_entity({name = "prtest-mask-only-" .. profile, position = {0, 0.5}, force = "player"})
            assert(mask_allowed == wanted, "PRTEST primary biome mask " .. profile .. " on " .. layout .. " unexpectedly " .. tostring(mask_allowed))
        end
        if layout == "water" then
            local placed = surface.create_entity({name = "prtest-biome-water", position = {0, 0.5}, force = "player"})
            assert(placed ~= nil)
            assert(not surface.can_place_entity({name = "prtest-biome-everything", position = {0, 0.5}, force = "player"}), "biome buildings must still collide with each other")
            placed.destroy()
        end
    end
    game.delete_surface(surface)
    log("PRTEST biome-placement 41 engine placement checks passed")

end

return tests

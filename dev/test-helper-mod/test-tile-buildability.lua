local tests = {}

tests.run = function()
    local surface = game.create_surface("prtest-tile-buildability", {width = 32, height = 32})
    surface.request_to_generate_chunks({0, 0}, 1)
    surface.force_generate_chunk_requests()
    for _, entity in pairs(surface.find_entities()) do
        entity.destroy()
    end
    local layouts = {
        land = {"prtest-tile-ground", "prtest-tile-ground"},
        mixed = {"prtest-tile-ground", "prtest-tile-water"},
        water = {"prtest-tile-water", "prtest-tile-water"},
    }
    local expected = {
        land = {required = false, forbidden = true, empty = false, overlap = false, conflict = false, collision = false, adjacent = false, shared_cell = false},
        mixed = {required = false, forbidden = false, empty = false, overlap = false, conflict = false, collision = false, adjacent = true, shared_cell = false},
        water = {required = true, forbidden = false, empty = false, overlap = false, conflict = false, collision = false, adjacent = false, shared_cell = false},
    }
    for layout, tiles in pairs(layouts) do
        local entries = {}
        for x = -4, 3 do
            for y = -4, 3 do
                table.insert(entries, {name = tiles[x < 0 and 1 or 2], position = {x, y}})
            end
        end
        surface.set_tiles(entries, false)
        for name, wanted in pairs(expected[layout]) do
            local allowed = surface.can_place_entity({name = "prtest-tile-rule-" .. name, position = {name == "shared_cell" and 0.5 or 0, 0.5}, force = "player"})
            assert(allowed == wanted, "PRTEST tile-buildability " .. layout .. " " .. name .. " unexpected " .. tostring(allowed))
        end
    end
    game.delete_surface(surface)
    log("PRTEST tile-buildability 24 engine placement checks passed")
end

return tests

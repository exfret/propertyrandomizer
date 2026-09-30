-- Logs lines for dev/run-tests.py to read, all starting with PRTEST

-- The randomizer panel's softlock warning (scripts/gui.lua) reads this mod data, so the test reads the same numbers
local function log_reachability()
    local reachability = prototypes.mod_data["propertyrandomizer-reachability-data"]
    if reachability == nil then
        log("PRTEST reachability missing")
        return
    end
    log("PRTEST reachability " .. tostring(reachability.data["reachable"]) .. " of " .. tostring(reachability.data["total"]))
end

-- The startup settings the game actually used (other mods' too, for mod sets that set them), so the runner can check they match what the test asked for
local function log_settings()
    for name, setting in pairs(settings.startup) do
        log("PRTEST setting " .. name .. " = " .. tostring(setting.value))
    end
end

-- Whether the randomizer changed planets in this game (its dupes, planetary or preview settings are on), so every planet's map generation is worth a look
local function planets_changed()
    for name, setting in pairs(settings.startup) do
        if setting.value == true and (name == "propertyrandomizer-dupes" or name == "propertyrandomizer-unified-preview" or string.sub(name, 1, 26) == "propertyrandomizer-planeta") then
            return true
        end
    end
    return false
end

-- Generates one chunk on every planet, so a planet whose noise can't be evaluated (like an extra resource patch set with no patches, which crashed the game on arrival) fails the run here
local function generate_planets()
    for name, planet in pairs(game.planets) do
        local surface = planet.create_surface()
        surface.request_to_generate_chunks({
            0,
            0,
        }, 0)
        surface.force_generate_chunk_requests()
        log("PRTEST generated " .. name)
    end
end

script.on_init(function()
    log_settings()
    log_reachability()
    if planets_changed() then
        generate_planets()
    end
end)

script.on_nth_tick(60, function(event)
    log("PRTEST tick " .. tostring(event.tick))
end)

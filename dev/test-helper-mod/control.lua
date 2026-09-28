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

script.on_init(function()
    log_settings()
    log_reachability()
end)

script.on_nth_tick(60, function(event)
    log("PRTEST tick " .. tostring(event.tick))
end)

-- Counts each mod's Lua instructions in the control stage for the pre-commit performance gate (dev/run-tests.py --baseline-ref)
-- Instrument Mode loads this in every mod's Lua state before that mod's control.lua (see Instrument Mode in the Factorio auxiliary docs), so each state counts its own instructions
-- dev/run-tests.py reads the counts from the log after the game exits, so each time the hook fires it logs the state's count so far, and the runner keeps each mod's last line

local INTERVAL = 100000
local mod_name = script.mod_name
local samples = 0

log("PRCOUNT control " .. mod_name .. " start interval=" .. INTERVAL)
debug.sethook(function()
    samples = samples + 1
    log("PRCOUNT control " .. mod_name .. " samples=" .. samples)
end, "", INTERVAL)

-- Counts Lua instructions in the data stage for the pre-commit performance gate (dev/run-tests.py --baseline-ref), which compares HEAD's count with the staged files' count
-- Instrument Mode (--instrument-mod) loads this before every other mod's data stage, and debug.sethook needs --enable-unsafe-lua-debug-api (see Instrument Mode and Libraries in the Factorio auxiliary docs)
-- The hook fires every INTERVAL instructions, like dev/profiler-mod's sampling, but only counts; instrument-after-data.lua logs the count

local INTERVAL = 100000

-- Global, so instrument-after-data.lua can read it
prcount = {
    interval = INTERVAL,
    samples = 0,
}

debug.sethook(function()
    prcount.samples = prcount.samples + 1
end, "", INTERVAL)

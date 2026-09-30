-- Samples the Lua stack during the data stage, for dev/run-tests.py --profile (read by dev/profile-report.py)
-- Instrument Mode (--instrument-mod) loads this before every other mod's data stage, and debug.sethook needs --enable-unsafe-lua-debug-api (see Instrument Mode and Libraries in the Factorio auxiliary docs)
-- Every INTERVAL Lua instructions, a sample logs "PRPROF <stack id>"; the log's timestamps then give each sample the wall time since the sample before, so time in C functions and garbage collection counts too
-- instrument-after-data.lua stops sampling and logs what the ids stand for

local INTERVAL = 100000
local MAX_DEPTH = 150

-- Global, so instrument-after-data.lua can read it
prprofile = {
    -- Function id -> "source:linedefined" (or "=[C]:name" for a C function)
    functions = {},
    function_ids = {},
    -- Stack id -> function ids from the running function outwards, then ";" and the running line
    stacks = {},
    stack_ids = {},
    samples = 0,
}

local functions = prprofile.functions
local function_ids = prprofile.function_ids
local stacks = prprofile.stacks
local stack_ids = prprofile.stack_ids
local getinfo = debug.getinfo
local concat = table.concat
local frames = {}

local function function_id(info, level)
    local key
    if info.what == "C" then
        key = "=[C]:" .. tostring(getinfo(level, "n").name)
    else
        key = info.source .. ":" .. info.linedefined
    end
    local id = function_ids[key]
    if id == nil then
        id = #functions + 1
        functions[id] = key
        function_ids[key] = id
    end
    return id
end

local function sample()
    -- Level 1 is this hook, level 2 the function that was running
    local leaf = getinfo(2, "Sl")
    if leaf == nil then
        return
    end
    frames[1] = function_id(leaf, 2)
    local depth = 1
    for level = 3, MAX_DEPTH + 1 do
        local info = getinfo(level, "S")
        if info == nil then
            break
        end
        depth = depth + 1
        frames[depth] = function_id(info, level)
    end
    local key = concat(frames, ",", 1, depth) .. ";" .. leaf.currentline
    local id = stack_ids[key]
    if id == nil then
        id = #stacks + 1
        stacks[id] = key
        stack_ids[key] = id
    end
    prprofile.samples = prprofile.samples + 1
    log("PRPROF " .. id)
end

log("PRPROF start interval=" .. INTERVAL)
debug.sethook(sample, "", INTERVAL)

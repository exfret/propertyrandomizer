-- Stops the sampling instrument-data.lua started, and logs what its function and stack ids stand for (dev/profile-report.py reads them)
debug.sethook()

local BATCH = 200

local function log_all(tag, list)
    for first = 1, #list, BATCH do
        local parts = {}
        for id = first, math.min(first + BATCH - 1, #list) do
            table.insert(parts, id .. "=" .. list[id])
        end
        log(tag .. " " .. table.concat(parts, "\t"))
    end
end

log("PRPROF stop samples=" .. prprofile.samples .. " functions=" .. #prprofile.functions .. " stacks=" .. #prprofile.stacks)
log_all("PRPROFFN", prprofile.functions)
log_all("PRPROFST", prprofile.stacks)

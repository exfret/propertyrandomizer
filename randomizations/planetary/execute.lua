-- Planetary randomization stage (setting propertyrandomizer-planetary-oceans)
-- Runs before the rest of randomization, so everything after it, including the mechanic context check, treats the changed world as the starting point.
-- For now it swaps oceans between planets (oceans.lua), then adds only the scaffolding recipes each planet needs to keep its requirements possible locally (scaffolds.lua), checked with the logic graph (check.lua).
-- It never stops the game from loading: anything that goes wrong (including errors, for mod compatibility) undoes the whole stage instead.

local planetary_check = require("randomizations/planetary/check")
local oceans = require("randomizations/planetary/oceans")
local scaffolds = require("randomizations/planetary/scaffolds")

local planetary = {}

local function warn(message)
    log("Planetary oceans: " .. message)
    table.insert(randomization_info.warnings, "[img=item.propertyrandomizer-gear] [color=yellow]exfret's Randomizer:[/color] Planetary ocean swaps " .. message)
end

-- Returns nil if the swap worked, or else why it has to be undone
local function run(logic, old_raw)
    local before = planetary_check.sort(logic)
    local assignment, clone_to_slot = oceans.execute("random", "planetary-oceans")
    local variants_of, after = scaffolds.execute(assignment, oceans, logic, before)
    -- Tile collision staying exactly as it was is part of how the swap works, so a difference means something unexpected happened
    local tile_problems = planetary_check.tiles_unchanged(old_raw, clone_to_slot)
    if #tile_problems > 0 then
        return "tile collision changed (" .. table.concat(tile_problems, "; ") .. ")"
    end
    if after == nil then
        after = planetary_check.sort(logic)
    end
    planetary_check.run(before, after)
    if not planetary_check.required(before, after, variants_of) then
        return "a planet lost something it must keep (see PLANETCHECK in the log)"
    end
    return nil
end

-- logic is the logic module (lib/logic/init), rebuilt from data.raw for each check
planetary.execute = function(logic)
    local problem = oceans.problem()
    if problem ~= nil then
        warn("were skipped, since " .. problem .. ".")
        return
    end
    local old_raw = table.deepcopy(data.raw)
    local is_ok, reason = pcall(run, logic, old_raw)
    if not is_ok then
        reason = "of an error: " .. tostring(reason)
    end
    if reason ~= nil then
        data.raw = old_raw
        scaffolds.kept = {}
        warn("were undone, since " .. reason .. ".")
    end
end

return planetary

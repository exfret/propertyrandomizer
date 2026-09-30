-- Plain-Lua regression test for which planet an in-place edit may follow (randomizations/planetary/check.lua), not loaded by the mod
-- Run from the mod root: lua randomizations/planetary/test-in-place-edits.lua
--
-- Locks may count a planet and its copies as one family, but an in-place edit changes a recipe for every planet.
-- So the edits (resource swaps' recipe and trigger edits, the ocean stage's edited originals) use the exact-room tests (check.specific_to_room, check.only_on_room).
-- A recipe the original still makes from its own resources must not follow the copy's lost resource: the user's superposed game lost oil processing on Nauvis that way.

-- Stand-ins for the Factorio environment
function table.deepcopy(tbl)
    if type(tbl) ~= "table" then
        return tbl
    end
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = table.deepcopy(v)
    end
    return copy
end
function log(msg) end
serpent = {
    block = tostring,
    line = tostring,
}
-- The sorts here are given, so the random number generator (which needs Factorio's bit32) is never used
package.loaded["lib/random/rng"] = {
    int = function(_, max)
        return 1
    end,
}
settings = {
    startup = {},
}
mods = {}
data = {
    raw = {
        planet = {
            rocky = {},
            ["rocky-exfret-2-copy"] = {
                orig_name = "rocky",
            },
            mossy = {},
        },
    },
}
lookups = {
    rooms = {
        ["planet: rocky"] = {
            type = "planet",
            name = "rocky",
        },
        ["planet: rocky-exfret-2-copy"] = {
            type = "planet",
            name = "rocky-exfret-2-copy",
        },
        ["planet: mossy"] = {
            type = "planet",
            name = "mossy",
        },
    },
}

local check_lib = require("randomizations/planetary/check")

local num_checks = 0
local function check(condition, message)
    num_checks = num_checks + 1
    if condition ~= true then
        error("test-in-place-edits: " .. message)
    end
end

-- A sort as the check reads it: node key --> context --> index
local function sort_with(contexts_by_node)
    local node_to_context_inds = {}
    for node_key, contexts in pairs(contexts_by_node) do
        node_to_context_inds[node_key] = {}
        for i, context in pairs(contexts) do
            node_to_context_inds[node_key][context] = i
        end
    end
    return {
        sort_info = {
            node_to_context_inds = node_to_context_inds,
        },
    }
end

local copy = "rocky-exfret-2-copy"

-- Made from local resources on the original and on its copy (like oil processing on Nauvis and Nauvis 2)
local shared = sort_with({
    ["recipe: refine"] = {
        "planet: rocky | 10",
        "planet: rocky | 11",
        "planet: rocky-exfret-2-copy | 10",
        "planet: mossy | 00",
    },
})
check(check_lib.specific_to(shared, "refine", copy), "the family test counts the original as the copy's own")
check(not check_lib.specific_to_room(shared, "refine", copy), "a recipe the original makes from its own resources doesn't belong to the copy alone")
check(not check_lib.specific_to_room(shared, "refine", "rocky"), "nor to the original alone")

-- Made from local resources only on the copy (other planets import)
local own = sort_with({
    ["recipe: refine"] = {
        "planet: rocky | 00",
        "planet: rocky-exfret-2-copy | 10",
        "planet: rocky-exfret-2-copy | 11",
    },
})
check(check_lib.specific_to_room(own, "refine", copy), "a recipe only the copy makes from its own resources belongs to the copy")
check(not check_lib.specific_to_room(own, "refine", "rocky"), "and not to the original, which only imports")

-- Reachable at all only on the original and its copy
local both_only = sort_with({
    ["recipe: melt"] = {
        "planet: rocky | 00",
        "planet: rocky-exfret-2-copy | 00",
    },
})
check(check_lib.only_on(both_only, "melt", "rocky"), "the family test says the original's family alone makes it")
check(not check_lib.only_on_room(both_only, "melt", "rocky"), "an original its copy also makes isn't only its own")
local copy_only = sort_with({
    ["recipe: melt"] = {
        "planet: rocky-exfret-2-copy | 00",
        "planet: rocky-exfret-2-copy | 01",
    },
})
check(check_lib.only_on_room(copy_only, "melt", copy), "a recipe only the copy makes is the copy's own")
check(not check_lib.only_on_room(sort_with({}), "melt", copy), "a recipe nothing makes isn't anyone's")

print("test-in-place-edits: " .. num_checks .. " checks passed")

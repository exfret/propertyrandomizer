-- Run from the mod root: lua tests/unit/prototypes/technology/test-technology-trigger-promises.lua
local trigger_promises = require("src/prototypes/technology/technology-trigger-promises")

local technologies = {}
technologies["test-hidden"] = { hidden = true }
technologies["test-kept"] = {}
technologies["test-copy-a"] = {}
technologies["test-copy-b"] = {}
UNIFIED_TRIGGER_TAKERS = {
    ["test-original"] = {
        "test-hidden",
        "test-kept",
        "test-missing",
    },
    ["test-unused"] = {},
}
local copied_from = {
    ["test-copy-a"] = "test-hidden",
    ["test-copy-b"] = "test-hidden",
}
trigger_promises.rebuild(technologies, copied_from)
assert(table.concat(UNIFIED_TRIGGER_TAKERS["test-original"], ",") == "test-copy-a,test-copy-b,test-kept,test-missing")
assert(#UNIFIED_TRIGGER_TAKERS["test-unused"] == 0)
print("ok - copies inherit trigger promises, hidden originals retire, and missing carriers remain checked")

-- The second rebuild copies from an existing per-recipe technology, often back into its own name.
copied_from = {
    ["test-copy-a"] = "test-copy-a",
    ["test-copy-b"] = "test-copy-b",
}
trigger_promises.rebuild(technologies, copied_from)
assert(table.concat(UNIFIED_TRIGGER_TAKERS["test-original"], ",") == "test-copy-a,test-copy-b,test-kept,test-missing")
print("ok - repeated rebuilding preserves provenance without duplicate promises")

technologies["test-copy-a"].hidden = true
technologies["test-next-copy"] = {}
trigger_promises.rebuild(technologies, { ["test-next-copy"] = "test-copy-a" })
assert(table.concat(UNIFIED_TRIGGER_TAKERS["test-original"], ",") == "test-copy-b,test-kept,test-missing,test-next-copy")
print("ok - promises follow a further copy after its source is hidden")

-- Packaging a recipe into discovery deletes its old trigger carrier explicitly, even when a previous rebuild already used its rebuilt name.
UNIFIED_TRIGGER_TAKERS = {
    ["test-retired-only"] = { "test-retired-only" },
    ["test-shared-source"] = {
        "test-retired-carrier",
        "test-kept",
        "test-missing",
    },
}
technologies["test-descendant"] = {}
local retired_takers = {
    ["test-retired-only"] = true,
    ["test-retired-carrier"] = true,
}
trigger_promises.rebuild(technologies, { ["test-descendant"] = "test-retired-carrier" }, retired_takers)
assert(#UNIFIED_TRIGGER_TAKERS["test-retired-only"] == 0)
assert(table.concat(UNIFIED_TRIGGER_TAKERS["test-shared-source"], ",") == "test-descendant,test-kept,test-missing")
trigger_promises.rebuild(technologies, {})
assert(#UNIFIED_TRIGGER_TAKERS["test-retired-only"] == 0)
assert(table.concat(UNIFIED_TRIGGER_TAKERS["test-shared-source"], ",") == "test-descendant,test-kept,test-missing")
print("ok - explicit removal retires only its carrier, preserves descendants and unknown missing carriers, and stays retired")

UNIFIED_TRIGGER_TAKERS = { ["test-kept"] = { "test-kept" } }
trigger_promises.rebuild(technologies, {}, { ["test-kept"] = true })
assert(UNIFIED_TRIGGER_TAKERS["test-kept"][1] == "test-kept")
print("ok - a still-present carrier remains checked even if its name was recorded as removed")

UNIFIED_TRIGGER_TAKERS = nil
trigger_promises.rebuild(technologies, copied_from)
assert(UNIFIED_TRIGGER_TAKERS == nil)
print("ok - rebuilding without trigger randomization leaves tracking disabled")

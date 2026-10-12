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

UNIFIED_TRIGGER_TAKERS = nil
trigger_promises.rebuild(technologies, copied_from)
assert(UNIFIED_TRIGGER_TAKERS == nil)
print("ok - rebuilding without trigger randomization leaves tracking disabled")

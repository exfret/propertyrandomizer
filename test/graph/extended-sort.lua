-- test/graph/extended-sort.lua
-- Unit tests for new-lib/graph/extended-sort.lua
-- TODO: Implement tests for context transmission with abilities

local harness = require("test/harness")

local tests = {}

function tests.run()
    harness.suite("extended-sort")

    harness.skip("ability context transmission", "Not yet implemented")
    harness.skip("room context isolation", "Not yet implemented")
    harness.skip("binary string context handling", "Not yet implemented")
end

return tests

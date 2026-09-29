-- Run from the mod root: lua dev/test-preview.lua
-- Check source defaults, stale saved dev values, the feature flag, and that control.lua's real init callback grants the start-of-game unlocks in every game (preview or not)
local setting_prototypes = {}
data = {
    extend = function(_, entries)
        for _, entry in pairs(entries) do
            setting_prototypes[entry.name] = entry
        end
    end,
}
mods = {}
dofile("settings.lua")
local dev_setting = setting_prototypes["propertyrandomizer-dev-unified"]
assert(dev_setting.default_value == false)
assert(dev_setting.hidden == true and dev_setting.forced_value == false)

-- Keep control.lua's real callback; stop at the graph-loading boundary after the force setup.
local init
local boundary = {}
local force
script = {
    active_mods = {},
    on_init = function(callback) init = callback end,
    on_configuration_changed = function() end,
    on_nth_tick = function() end,
}
defines = {
    events = {},
    selection_mode = { select = 1 },
}
prototypes = { item = {} }
prototypes.item["propertyrandomizer-graph"] = {
    get_entity_type_filters = function() error(boundary) end,
}
package.loaded["__core__.lualib.mod-gui"] = {}
package.loaded["util"] = {}
package.loaded["scripts/events"] = { on_event = function() end }
package.loaded["scripts/gui"] = {}
package.loaded["helper-tables/constants"] = {}
package.loaded["lib/graph/context-sort"] = {}
package.loaded["scripts/explorer-sorts"] = {}
package.loaded["lib/graph/graph-utils"] = {}

local function check(preview, saved_dev, test_helper, expected)
    settings = { startup = {} }
    settings.startup["propertyrandomizer-unified-preview"] = { value = preview }
    -- Hidden forced_value overrides saved settings; the test helper removes that restriction.
    local dev_value = saved_dev
    if not test_helper then
        dev_value = dev_setting.forced_value
    end
    settings.startup["propertyrandomizer-dev-unified"] = { value = dev_value }
    local features = dofile("helper-tables/feature-flags.lua")
    assert(features.dev_unified == expected)
    package.loaded["helper-tables/feature-flags"] = features
    dofile("control.lua")
    force = {}
    local platform_calls = 0
    force.unlock_space_platforms = function() platform_calls = platform_calls + 1 end
    -- Any force access observes the same spy; no vanilla force name is needed.
    game = { forces = setmetatable({}, { __index = function() return force end }) }
    storage = {}
    local ok, err = pcall(init)
    assert(not ok and err == boundary, "init failed before graph boundary: " .. tostring(err))
    force.unlock_space_platforms = nil
    -- The unlocks are granted at the start of every game, not just in the preview (the user's decision, 2026-09-28)
    assert(platform_calls == 1, "space platforms not unlocked at the start")
    assert(force.mining_with_fluid == true, "mining with fluid not granted at the start")
    assert(force.bulk_inserter_capacity_bonus == 3, "bulk inserter bonus not granted at the start")
end

check(false, false, false, false)
check(false, true, false, false)
check(true, false, false, true)
check(false, true, true, true)
print("Preview isolation: source defaults, stale dev settings, preview and explicit dev mode passed, and the start-of-game unlocks are granted in every game")

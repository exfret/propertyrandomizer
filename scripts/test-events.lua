-- Plain-Lua regression test for scripts/events.lua (not loaded by the mod)
-- Run from the mod root: lua scripts/test-events.lua

-- Stand-in for LuaBootstrap, which like the real one keeps only one handler per event
local handlers = {}
script = {
    get_event_handler = function(event_id)
        return handlers[event_id]
    end,
    on_event = function(event_id, handler)
        handlers[event_id] = handler
    end,
}

local events = require("scripts/events")

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local function first_handler(event)
end

local function second_handler(event)
end

test("first registration of an event goes through", function()
    events.on_event(1, first_handler)
    assert(handlers[1] == first_handler)
end)

test("registering an event again errors instead of silently replacing its handler", function()
    local succeeded = pcall(events.on_event, 1, second_handler)
    assert(not succeeded)
    assert(handlers[1] == first_handler)
end)

test("custom input names are guarded too", function()
    events.on_event("return-to-starting-planet", first_handler)
    local succeeded = pcall(events.on_event, "return-to-starting-planet", second_handler)
    assert(not succeeded)
    assert(handlers["return-to-starting-planet"] == first_handler)
end)

print(num_passed .. " tests passed")

-- Control stage event registration
-- script.on_event keeps only one handler per event for each mod, so registering an event twice silently drops the first handler
-- Registering through here turns that into an error at load instead

local events = {}

-- Registers handler for event_id (a defines.events value or a custom input name), erroring if the event already has a handler
-- To handle more cases of an event that's already registered, extend its existing handler (like the dispatch table for on_script_trigger_effect in control.lua)
events.on_event = function(event_id, handler)
    if script.get_event_handler(event_id) ~= nil then
        error("Event " .. tostring(event_id) .. " already has a handler; extend that handler instead of registering the event again")
    end
    script.on_event(event_id, handler)
end

return events

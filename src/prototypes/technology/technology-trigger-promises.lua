-- Track which final technologies carry each trigger from the unified model.
-- Rebuilding the tree copies research methods to per-recipe technologies and hides emptied originals.
local trigger_promises = {}

trigger_promises.rebuild = function(technologies, copied_from, retired_takers)
    if UNIFIED_TRIGGER_TAKERS == nil then
        return
    end
    retired_takers = retired_takers or {}
    local sources_of = {}
    for source, takers in pairs(UNIFIED_TRIGGER_TAKERS) do
        for _, taker in pairs(takers) do
            sources_of[taker] = sources_of[taker] or {}
            sources_of[taker][source] = true
        end
    end
    local updated = {}
    for source, takers in pairs(UNIFIED_TRIGGER_TAKERS) do
        updated[source] = {}
        for _, taker in pairs(takers) do
            local technology = technologies[taker]
            -- Deliberately hidden or removed carriers retire; an unexpectedly missing technology still fails the check.
            if (technology == nil and retired_takers[taker] ~= true) or (technology ~= nil and technology.hidden ~= true) then
                updated[source][taker] = true
            end
        end
    end
    for name, copied_source in pairs(copied_from) do
        for source, _ in pairs(sources_of[copied_source] or {}) do
            updated[source][name] = true
        end
    end
    for source, takers in pairs(updated) do
        local names = {}
        for name, _ in pairs(takers) do
            table.insert(names, name)
        end
        table.sort(names)
        UNIFIED_TRIGGER_TAKERS[source] = names
    end
end

return trigger_promises

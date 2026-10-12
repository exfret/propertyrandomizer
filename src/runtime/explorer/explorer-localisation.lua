-- Translated search text is per player; graph keys always remain the selector identities.
local search = {}

local function cache_for(player)
    storage.explorer_translations = storage.explorer_translations or {}
    local cache = storage.explorer_translations[player.index]
    if cache == nil or cache.locale ~= player.locale then
        cache = {
            locale = player.locale,
            values = {},
            pending = {},
            requests = {},
        }
        storage.explorer_translations[player.index] = cache
    end
    return cache
end

search.value = function(player, key, caption, fallback)
    local cache = cache_for(player)
    if cache.values[key] ~= nil then
        return cache.values[key]
    end
    if cache.pending[key] == nil then
        local request = player.request_translation(caption)
        if request ~= nil then
            cache.pending[key] = request
            cache.requests[request] = {
                key = key,
                fallback = fallback,
            }
        end
    end
    return fallback
end

search.matches = function(query, translated, identity)
    query = string.lower(query)
    return string.find(string.lower(translated), query, 1, true) ~= nil
        or string.find(string.lower(identity), query, 1, true) ~= nil
end

search.on_translated = function(event)
    local cache = (storage.explorer_translations or {})[event.player_index]
    local player = game.players[event.player_index]
    if cache == nil or player == nil or cache.locale ~= player.locale then
        return
    end
    local request = cache.requests[event.id]
    if request == nil then
        return
    end
    cache.requests[event.id] = nil
    -- Remember failed translations too, rather than requesting them every time the list refreshes.
    cache.values[request.key] = event.translated and event.result or request.fallback
    storage.explorer_translation_dirty = storage.explorer_translation_dirty or {}
    storage.explorer_translation_dirty[event.player_index] = true
end

search.invalidate = function(player_index)
    if storage.explorer_translations ~= nil then
        storage.explorer_translations[player_index] = nil
    end
    storage.explorer_translation_dirty = storage.explorer_translation_dirty or {}
    storage.explorer_translation_dirty[player_index] = true
end

return search

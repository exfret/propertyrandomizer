-- Context numbers for plain-Lua test fixtures (not loaded by the mod)
-- Fixtures write contexts as their names, like "planet: rock | 11", "planet: rock" (a room's simple context) or "planet: rock | 00 @ home1", and these turn them into the numbers sorts use (src/logic/contexts/contexts.lua)
-- A room is numbered the first time a fixture names it

local ctx = require("src/logic/contexts/contexts")

local fixtures = {}

local function number_room(room)
    if ctx.simple(room) == nil then
        ctx.number_rooms({ [room] = true })
    end
end

-- Ability mask of the way masks used to be written, like "10"
fixtures.mask = function(mask_name)
    for _, mask in pairs(ctx.masks) do
        if ctx.mask_name(mask) == mask_name then
            return mask
        end
    end
    error("not an ability mask: " .. tostring(mask_name))
end

-- Context number of a context's name
fixtures.C = function(name)
    local base, home = string.match(name, "^(.-) @ home(%d+)$")
    if base == nil then
        base = name
    end
    local room, mask_name = string.match(base, "^(.-) | ([01]+)$")
    local context
    if room ~= nil then
        number_room(room)
        context = ctx.complex(room, fixtures.mask(mask_name))
    else
        number_room(base)
        context = ctx.simple(base)
    end
    if home ~= nil then
        context = ctx.home(context, tonumber(home))
    end
    return context
end

-- Name of a context number
fixtures.N = ctx.name

-- A table keyed by context names, keyed by their numbers instead
fixtures.keyed = function(by_name)
    local by_context = {}
    for name, value in pairs(by_name) do
        by_context[fixtures.C(name)] = value
    end
    return by_context
end

-- A table keyed by context numbers, keyed by their names instead (for assertions)
fixtures.named = function(by_context)
    local by_name = {}
    for context, value in pairs(by_context) do
        by_name[ctx.name(context)] = value
    end
    return by_name
end

-- A list of context names as numbers
fixtures.list = function(names)
    local contexts = {}
    for _, name in pairs(names) do
        table.insert(contexts, fixtures.C(name))
    end
    return contexts
end

-- Edge abilities as the logic builders used to write them, like { [2] = false }, as a code (see contexts.edge_abilities)
fixtures.edge = function(abilities)
    local code
    for ability, gained in pairs(abilities) do
        code = ctx.edge_with(code, ability, gained)
    end
    return code
end

return fixtures

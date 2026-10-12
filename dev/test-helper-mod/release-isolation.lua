-- These checks compare actual prototypes across the randomizer's stages, without vanilla names.
local isolation = {}
local before
local prerequisites

-- Whether a technology discovers a space location (UnlockSpaceLocationModifier)
local function discovers_location(tech)
    for _, effect in pairs(tech.effects or {}) do
        if effect.type == "unlock-space-location" then
            return true
        end
    end
    return false
end

local function same(left, right)
    if type(left) ~= type(right) then
        return false
    end
    if type(left) ~= "table" then
        return left == right
    end
    for key, value in pairs(left) do
        if not same(value, right[key]) then
            return false
        end
    end
    for key, _ in pairs(right) do
        if left[key] == nil then
            return false
        end
    end
    return true
end

function isolation.capture()
    if config.dev_unified then
        return
    end
    if next(config.graph) == nil then
        before = table.deepcopy(data.raw)
    end
    -- Planetary stages that move technologies with what they move (rewards, freezing) change prerequisites on purpose
    if not config.graph.technology and not config.tech_tree_rebuild and not config.planetary_rewards and not config.planetary_freezing then
        prerequisites = {}
        for name, tech in pairs(data.raw.technology) do
            -- The star map's discovery order (planetary connections, which dupes turn on) gives the technologies discovering a space location new prerequisites on purpose (src/randomizations/planetary/discovery.lua)
            if not (config.planetary_connections and discovers_location(tech)) then
                prerequisites[name] = table.deepcopy(tech.prerequisites or {})
            end
        end
    end
end

function isolation.check_prefixes()
    if before ~= nil then
        assert(same(before, data.raw), "Release isolation: development prefixes changed prototypes without preview")
        before = nil
        log("PRTEST release prefixes unchanged")
    end
end

function isolation.check_prerequisites()
    if prerequisites ~= nil then
        for name, original in pairs(prerequisites) do
            local tech = data.raw.technology[name]
            assert(tech ~= nil and same(original, tech.prerequisites or {}), "Release isolation: prerequisites changed for " .. name)
        end
        log("PRTEST release prerequisites unchanged")
    end
end

return isolation

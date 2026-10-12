-- Mining fluids before randomization: with the unified randomizations in development, the mining fluid randomization (src/randomizations/unified/handlers/mining-fluid-required.lua) chooses which resources need a fluid, so no resource needs one from the start (user, 2026-10-09: randomized into ores rather than included at the start)
-- The stages before it (planetary changes, independent deposits) then never depend on a vanilla mining fluid they can't keep: independent deposits gave Vulcanus its own copy of sulfuric acid, while the uranium ore its molten metals took still needed the original, so nothing made from that uranium could be made on Vulcanus from its own resources (seed 0, 2026-10-08)
-- A resource whose mining uses up fluid (MinableProperties::fluid_amount > 0) can't be mined by hand, so one without can be again until randomization gives it a fluid
-- The fluid input variants of resource categories stay in the logic either way, since they come from what the drills can serve (src/prototypes/lookup/2-simple/mining.lua), so the randomization can still give any resource a fluid

local mining_fluids = {}

-- Takes the mining fluid off every resource that needs one (resources: name --> resource prototype, like data.raw.resource)
-- Returns what each needed, as sorted "resource (fluid)" texts for the log
mining_fluids.strip = function(resources)
    local stripped = {}
    for resource_name, resource in pairs(resources) do
        local minable = resource.minable
        if minable ~= nil and minable.required_fluid ~= nil then
            table.insert(stripped, resource_name .. " (" .. minable.required_fluid .. ")")
            minable.required_fluid = nil
            minable.fluid_amount = nil
        end
    end
    table.sort(stripped)
    return stripped
end

return mining_fluids

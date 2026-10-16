-- Loaded only into frozen experiment copies by test-recipe-search.py.
local rng = require("src/lib/random/rng")

local probe = {}
local search
local fit
local amounts

local function json(value)
    if type(value) == "table" then
        local entries = {}
        for k, v in pairs(value) do
            entries[#entries + 1] = string.format("%q", tostring(k)) .. ":" .. json(v)
        end
        table.sort(entries)
        return "{" .. table.concat(entries, ",") .. "}"
    elseif type(value) == "string" then
        return string.format("%q", value):gsub("\\\n", "\\n")
    elseif type(value) == "number" then
        if value ~= value or math.abs(value) == math.huge then return "null" end
        return string.format("%.17g", value)
    elseif type(value) == "boolean" then
        return tostring(value)
    end
    return "null"
end

local function increment(name)
    if search ~= nil then search[name] = (search[name] or 0) + 1 end
    if fit ~= nil then fit[name] = (fit[name] or 0) + 1 end
end

probe.begin_search = function(pool, count, target, costs, params)
    search = {
        recipe = probe.recipe,
        slot = probe.slot,
        pool_size = #pool,
        slots = params.slot_forms or count,
        pool = pool,
        target = target,
        fits = 0,
        rounds = 0,
        stops = {},
        worst = {rounds = -1},
        candidate_attempts = 0,
        accepted_swaps = 0,
    }
end
probe.finish_search = function(result)
    search.result = result
    search.stop = search.stop or "exhausted"
    log("RECIPESEARCH " .. json(search))
    search = nil
end
probe.fit_begin = function(target, costs, ings, count, params)
    local unit_costs = {
        aggregate_cost = {},
        resource_costs = {},
    }
    for _, ing in pairs(ings) do
        local id = ing.type .. "-" .. ing.name
        unit_costs.aggregate_cost[id] = costs.aggregate_cost[id]
        for resource, values in pairs(costs.resource_costs) do
            unit_costs.resource_costs[resource] = unit_costs.resource_costs[resource] or {}
            unit_costs.resource_costs[resource][id] = values[id]
        end
    end
    fit = {
        rounds = 0,
        target = target,
        costs = unit_costs,
        initial = table.deepcopy(ings),
        count = count,
        params = params,
        rng = table.deepcopy(rng.prgs["recipe-ingredients-calculate-optimal-amounts"]),
        trace = {},
    }
    if search ~= nil then search.fits = search.fits + 1 end
end
probe.fit_end = function(points, ings, reason)
    fit.points = points
    fit.result = table.deepcopy(ings)
    fit.stop = reason
    if search ~= nil then
        search.stops[reason] = (search.stops[reason] or 0) + 1
        if fit.rounds > search.worst.rounds then search.worst = fit end
    end
    fit = nil
end
probe.round = function()
    increment("rounds")
    probe.seen = {}
end
probe.proposal = function(index)
    increment("proposals")
    if probe.seen[index] then increment("duplicate_proposals") end
    probe.seen[index] = true
end
probe.round_end = function(before, after, allocation, ings)
    if after < before then increment("improving_rounds") end
    if fit.rounds <= 3 or fit.rounds % 1000 == 0 or after == before then
        fit.trace[#fit.trace + 1] = {
            round = fit.rounds,
            before = before,
            after = after,
            allocation = allocation,
            ings = table.deepcopy(ings),
        }
    end
end
probe.points = function() increment("point_evaluations") end
probe.single = function() increment("coordinate_optimizations"); amounts = {} end
probe.amount = function(amount)
    increment("cost_evaluations")
    if amounts[amount] ~= nil then increment("duplicate_amounts") end
    amounts[amount] = true
end
probe.candidate = function() increment("candidate_attempts") end
probe.accepted = function() increment("accepted_swaps") end
probe.stop = function(reason) search.stop = reason end

return probe

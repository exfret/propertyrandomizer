-- A prerequisite shuffle for goals the specialized planetary repairs still couldn't restore.
-- It uses unified's chooser and promotion ranks, with first pass disabled.
-- Borrowed old-world edges describe missing requirements; every replacement must have an actual earlier backing.
local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")
local superpose = require("lib/graph/superpose")
local recycling = require("lib/recycling")
local planetary_check = require("randomizations/planetary/check")
local protection = require("randomizations/graph/unified/skeleton/protection")

local fix_pass = {}

-- Prerequisite handlers; identity moves and recipe shapes belong to the subsequent first pass.
local HANDLER_KEYS = {
    "recipe-category",
    "recipe-ingredients",
    "entity-energy-source",
    "mining-fluid-required",
    "tech-triggers",
}

local function choose_once(params)
    local before = params.before
    local variants_of = params.variants_of or {}
    local after = params.after or planetary_check.sort(params.logic)
    local failures = planetary_check.required_failures(before, after, variants_of)
    if #failures == 0 then
        log("FIXPASS: nothing to choose; all requirements are satisfied")
        return failures, after
    end
    log("FIXPASS: choosing prerequisites for " .. #failures .. " remaining failures")

    local union = superpose.union(after.graph, before.graph)
    -- Science packs' goals in the rooms they belong to are mechanic goals (protection.planetary_kept_context)
    local goals = planetary_check.transported_goals(before)
    -- Existing variants already meet their original recipe's requirements.
    for recipe_name, names in pairs(variants_of) do
        local node_key = gutils.key("recipe", recipe_name)
        for context, _ in pairs(goals[node_key] or {}) do
            for _, name in pairs(names) do
                if (after.sort_info.node_to_context_inds[gutils.key("recipe", name)] or {})[context] ~= nil then
                    goals[node_key][context] = nil
                end
            end
        end
    end
    local debt = {
        graph = union.graph,
        debt_edges = union.debt_edges,
        old_nodes = union.old_nodes,
        is_goal = function(node_key, context)
            local contexts = goals[node_key] or {}
            return contexts[context] ~= nil or (top.context_home(context) == nil and protection.is_isolatable_context(context) and contexts[protection.without_isolatability(context)] ~= nil)
        end,
        goals = goals,
    }
    local old_raw = table.deepcopy(data.raw)
    local old_promises = UNIFIED_PROMISED_PEBBLES
    local old_triggers = UNIFIED_TRIGGER_TAKERS
    local ok, result = pcall(params.unified.execute, {
        repair_only = true,
        handler_keys = HANDLER_KEYS,
        debt = debt,
    })
    UNIFIED_PROMISED_PEBBLES = old_promises
    UNIFIED_TRIGGER_TAKERS = old_triggers
    if ok == false or result == false then
        data.raw = old_raw
        log("FIXPASS: prerequisite chooser couldn't finish" .. (ok == false and (": " .. tostring(result)) or ""))
        return failures, after
    end
    recycling.regenerate(old_raw)
    after = planetary_check.sort(params.logic)
    failures = planetary_check.required_failures(before, after, variants_of)
    log("FIXPASS: " .. #failures .. " failures remain after choosing prerequisites")
    return failures, after
end

fix_pass.run = function(params)
    local after = params.after or planetary_check.sort(params.logic)
    local failures = planetary_check.required_failures(params.before, after, params.variants_of or {})
    if #failures == 0 then
        return failures, after
    end
    while #failures > 0 do
        local previous_failures = #failures
        local previous_available = top.num_contexts(after.sort_info)
        failures, after = choose_once({
            logic = params.logic,
            unified = params.unified,
            before = params.before,
            variants_of = params.variants_of,
            after = after,
        })
        if #failures > previous_failures or (#failures == previous_failures and top.num_contexts(after.sort_info) <= previous_available) then
            break
        end
        -- Newly backed prerequisites must rank before the remaining dependents in the next choice.
        -- The actual graph was rebuilt above; repeat only while goals or availability improve.
    end
    return failures, after
end

return fix_pass

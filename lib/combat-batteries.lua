-- Bounded two-profile turret batteries with fixed cohort sizes.
-- Each returned time describes a conservative schedule, not an optimal assignment.
-- Different cohorts and target types work concurrently; death generations remain serialized.

local targets = require("lib/combat-targets")

local batteries = {}

local function finite(value)
    return type(value) == "number" and value > -math.huge and value < math.huge
end

local function integer(value)
    return finite(value) and value >= 1 and value % 1 == 0
end

-- Profile entries retain the provider's original indexes; only mode="turret" entries participate.
-- Root sources and all descendants are expanded once, before assigning any target to a cohort.
-- An optional pair_allowed(left_entry, right_entry) filters pairs before spending either search budget.
-- Feasibility-only checks retain the first complete schedule meeting max_seconds for each allowed pair.
batteries.evaluate = function(profiles, roster, entities, options)
    options = options or {}
    local deployment_count = options.deployment_count or 10
    local max_pairs = options.max_pairs or 128
    -- Aggregate schedules charge every assigned type. The 2.1.20 native route probe used at most
    -- 387178 units for all 21 pairs; retain bounded headroom without weakening that accounting.
    local max_work = options.max_work or 500000
    local max_seconds = options.max_seconds or math.huge
    assert(integer(deployment_count) and deployment_count <= 10, "Invalid mixed battery deployment limit")
    assert(integer(max_pairs), "Invalid mixed battery pair limit")
    assert(integer(max_work), "Invalid mixed battery work limit")
    assert(type(max_seconds) == "number" and max_seconds > 0, "Invalid mixed battery duration limit")
    local diagnostics = {
        pairs_attempted = 0,
        allocations_attempted = 0,
        work = 0,
        truncated = false,
        rejected = {},
    }
    local result = {}
    local eligible = {}
    for index, source in pairs(profiles or {}) do
        if source.mode == "turret" then
            table.insert(eligible, index)
        end
    end
    if deployment_count < 2 or #eligible < 2 then
        return result, diagnostics
    end

    local function reject(reason)
        reason = reason or "unsupported-mixed-workload"
        diagnostics.rejected[reason] = (diagnostics.rejected[reason] or 0) + 1
    end
    local function spend(amount)
        if diagnostics.work + amount > max_work then
            diagnostics.truncated = true
            diagnostics.work_limit_reached = true
            return false
        end
        diagnostics.work = diagnostics.work + amount
        return true
    end
    local first = profiles[eligible[1]].profile
    local target_options = options.target_options or (first and first.target_options)
    local resolver = targets.new(entities, target_options)
    local workload, reason = resolver.workload(roster)
    if workload == nil then
        diagnostics.reason = reason
        return result, diagnostics
    end
    local phases = {}
    local phase_numbers = {}
    local preparation_work = 0
    for _, target in pairs(workload) do
        preparation_work = preparation_work + #(target.parts or {})
        for phase, amount in pairs(target.phases) do
            if phases[phase] == nil then
                phases[phase] = {}
                table.insert(phase_numbers, phase)
            end
            table.insert(phases[phase], {
                entity = target.entity,
                amount = amount,
            })
        end
    end
    table.sort(phase_numbers)
    local evaluators, costs = {}, {}
    local function evaluator(index)
        local memo = evaluators[index]
        if memo == nil then
            local profile = profiles[index].profile
            if not spend(preparation_work * math.max(1, #(profile.packets or {}))) then
                return nil, "mixed-work-budget"
            end
            local value, failure = targets.prepare(profile, workload, profile.target_options or target_options)
            memo = {
                value = value,
                reason = failure,
            }
            evaluators[index] = memo
        end
        return memo.value, memo.reason
    end

    local function assigned_schedule(index, prepared, counts, count)
        local names = {}
        for name, amount in pairs(counts) do
            if amount > 0 then
                table.insert(names, name)
            end
        end
        if #names == 0 then
            return 0
        end
        table.sort(names)
        local key_parts = {}
        for _, name in pairs(names) do
            -- Length prefixes keep prototype names containing separators unambiguous.
            table.insert(key_parts, #name .. ":" .. name .. "=" .. counts[name])
        end
        local key = table.concat(key_parts, ";")
        costs[index] = costs[index] or {}
        costs[index][count] = costs[index][count] or {}
        local by_count = costs[index][count]
        local memo = by_count[key]
        -- Charge every assigned type: a new schedule searches up to count team sizes and count teams.
        if not spend(#names * (memo ~= nil and 1 or 1 + count * count)) then
            return nil, "mixed-work-budget"
        end
        if memo == nil then
            local seconds, failure = prepared.schedule(counts, count)
            memo = {
                seconds = seconds,
                reason = failure,
            }
            by_count[key] = memo
        end
        return memo.seconds, memo.reason
    end

    local function batch(index, prepared, name, amount, count)
        return assigned_schedule(index, prepared, {[name] = amount}, count)
    end

    local function allocation(left, right, a, b, left_count, right_count)
        local total = 0
        for _, phase in pairs(phase_numbers) do
            local jobs = {}
            for _, target in pairs(phases[phase]) do
                local a_seconds = batch(left, a, target.entity, target.amount, left_count)
                local b_seconds = batch(right, b, target.entity, target.amount, right_count)
                if diagnostics.work_limit_reached then
                    return nil, "mixed-work-budget"
                end
                if a_seconds == nil and b_seconds == nil then
                    return nil, "mixed-uncovered-target"
                end
                table.insert(jobs, {
                    entity = target.entity,
                    amount = target.amount,
                    flexible = a_seconds ~= nil and b_seconds ~= nil,
                    priority = math.min(a_seconds or math.huge, b_seconds or math.huge),
                })
            end
            table.sort(jobs, function(x, y)
                if x.flexible ~= y.flexible then
                    return not x.flexible
                elseif x.priority ~= y.priority then
                    return x.priority > y.priority
                end
                return x.entity < y.entity
            end)
            local left_finish, right_finish = 0, 0
            local left_assigned, right_assigned = {}, {}
            for _, job in pairs(jobs) do
                local function finish(left_amount)
                    left_assigned[job.entity] = left_amount > 0 and left_amount or nil
                    right_assigned[job.entity] = left_amount < job.amount and job.amount - left_amount or nil
                    local a_seconds = assigned_schedule(left, a, left_assigned, left_count)
                    local b_seconds = assigned_schedule(right, b, right_assigned, right_count)
                    return a_seconds or math.huge, b_seconds or math.huge
                end
                -- Search the crossing and its neighbor without enumerating individual bodies or all partitions.
                -- Every considered split schedules the cohort's complete assignment, including its earlier target types.
                local low, high = 0, job.amount
                while low < high do
                    local middle = math.floor((low + high) / 2)
                    local a_finish, b_finish = finish(middle)
                    if diagnostics.work_limit_reached then
                        return nil, "mixed-work-budget"
                    end
                    if a_finish >= b_finish then
                        high = middle
                    else
                        low = middle + 1
                    end
                end
                local best, best_left, best_right, best_amount
                for amount = math.max(0, low - 1), low do
                    local a_finish, b_finish = finish(amount)
                    if diagnostics.work_limit_reached then
                        return nil, "mixed-work-budget"
                    end
                    local duration = math.max(a_finish, b_finish)
                    if finite(duration) and (best == nil or duration < best) then
                        best, best_left, best_right = duration, a_finish, b_finish
                        best_amount = amount
                    end
                end
                if best == nil then
                    return nil, "mixed-uncovered-target"
                end
                left_assigned[job.entity] = best_amount > 0 and best_amount or nil
                right_assigned[job.entity] = best_amount < job.amount and job.amount - best_amount or nil
                left_finish, right_finish = best_left, best_right
            end
            total = total + math.max(left_finish, right_finish)
            if not finite(total) then
                return nil, "invalid-mixed-clear-time"
            elseif total > max_seconds then
                return nil, "mixed-too-slow"
            end
        end
        return total
    end

    for position = 1, #eligible - 1 do
        for other = position + 1, #eligible do
            local left, right = eligible[position], eligible[other]
            if options.pair_allowed == nil or options.pair_allowed(profiles[left], profiles[right]) == true then
                if diagnostics.pairs_attempted >= max_pairs then
                    diagnostics.truncated = true
                    diagnostics.pair_limit_reached = true
                    return result, diagnostics
                end
                diagnostics.pairs_attempted = diagnostics.pairs_attempted + 1
                local a, a_reason = evaluator(left)
                local b, b_reason = evaluator(right)
                local best
                if a == nil or b == nil then
                    reject(a_reason or b_reason)
                else
                    for left_count = 1, deployment_count - 1 do
                        diagnostics.allocations_attempted = diagnostics.allocations_attempted + 1
                        local right_count = deployment_count - left_count
                        local seconds, failure = allocation(left, right, a, b, left_count, right_count)
                        if seconds ~= nil and (best == nil or seconds < best.clear_seconds) then
                            best = {
                                left = left,
                                right = right,
                                left_count = left_count,
                                right_count = right_count,
                                clear_seconds = seconds,
                            }
                        elseif seconds == nil then
                            reject(failure)
                        end
                        if diagnostics.work_limit_reached or (options.feasibility_only == true and best ~= nil) then
                            break
                        end
                    end
                end
                if best ~= nil then
                    table.insert(result, best)
                end
                if diagnostics.work_limit_reached then
                    return result, diagnostics
                end
            end
        end
    end
    return result, diagnostics
end

return batteries

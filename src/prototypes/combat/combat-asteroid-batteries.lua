-- Bounded three-profile batteries for asteroid encounters only; the caller chooses that scope.
-- Every candidate is an actual fixed-turret schedule, not an average-DPS estimate.
-- Each gun fires independently, retaining its load across target materials within a generation.

local targets = require("src/prototypes/combat/combat-targets")

local batteries = {}

local function finite(value)
    return type(value) == "number" and value > -math.huge and value < math.huge
end

local function integer(value)
    return finite(value) and value >= 1 and value % 1 == 0
end

-- Feasibility-only checks retain the first complete schedule meeting max_seconds for each allowed triple.
batteries.evaluate = function(profiles, roster, entities, options)
    options = options or {}
    local deployment_count = options.deployment_count or 10
    local max_triples = options.max_triples or 64
    local max_scanned = options.max_scanned_triples or 4096
    local max_work = options.max_work or 1000000
    local max_seconds = options.max_seconds or math.huge
    assert(integer(deployment_count) and deployment_count <= 10, "Invalid asteroid battery deployment limit")
    assert(integer(max_triples) and integer(max_scanned), "Invalid asteroid battery triple limit")
    assert(integer(max_work), "Invalid asteroid battery work limit")
    assert(type(max_seconds) == "number" and max_seconds > 0, "Invalid asteroid battery duration limit")
    local result = {}
    local diagnostics = {
        triples_scanned = 0,
        triples_attempted = 0,
        triples_pruned = 0,
        allocations_attempted = 0,
        allocations_pruned = 0,
        duplicate_sources_skipped = 0,
        work = 0,
        truncated = false,
        rejected = {},
    }
    local eligible = {}
    for index, source in pairs(profiles or {}) do
        if integer(index) and source.mode == "turret" then
            table.insert(eligible, index)
        end
    end
    table.sort(eligible)
    if #eligible < 3 or deployment_count < 3 then
        return result, diagnostics
    end
    local function reject(reason)
        reason = reason or "unsupported-asteroid-mixture"
        diagnostics.rejected[reason] = (diagnostics.rejected[reason] or 0) + 1
    end
    local function spend(amount)
        if diagnostics.work + amount > max_work then
            diagnostics.truncated = true
            diagnostics.work_limit_reached = true
            diagnostics.reason = "asteroid-mixed-work-budget"
            return false
        end
        diagnostics.work = diagnostics.work + amount
        return true
    end
    local first = profiles[eligible[1]].profile
    local target_options = options.target_options or (first and first.target_options)
    local workload, phases, phase_numbers, preparation_work
    local function prepare_workload()
        if workload ~= nil then
            return true
        end
        local resolver = targets.new(entities, target_options)
        local reason
        workload, reason = resolver.workload(roster)
        if workload == nil then
            diagnostics.reason = reason
            return false
        end
        phases, phase_numbers, preparation_work = {}, {}, 0
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
        return true
    end
    local prepared = {}
    local function costs(index)
        if prepared[index] == nil then
            local profile = profiles[index].profile
            if not spend(preparation_work * math.max(1, #(profile.packets or {}))) then
                return nil, "asteroid-mixed-work-budget"
            end
            local evaluator, reason = targets.prepare(profile, workload, profile.target_options or target_options)
            local memo = {reason = reason}
            if evaluator ~= nil then
                memo.times = {}
                for _, target in pairs(workload) do
                    if not spend(1) then
                        return nil, "asteroid-mixed-work-budget"
                    end
                    -- Single-gun jobs conservatively omit targets requiring simultaneous focused fire to beat regeneration.
                    memo.times[target.entity] = evaluator.seconds(target.entity, 1)
                end
            end
            prepared[index] = memo
        end
        return prepared[index].times, prepared[index].reason
    end
    local function phase_jobs(times)
        local jobs, bounds = {}, {}
        for _, phase in pairs(phase_numbers) do
            jobs[phase] = {}
            local bound = {
                work = 0,
                longest = 0,
                exclusive_work = {},
            }
            bounds[phase] = bound
            for _, target in pairs(phases[phase]) do
                if not spend(3) then
                    return nil, "asteroid-mixed-work-budget"
                end
                local flexibility, fastest = 0, math.huge
                local only_cohort
                local seconds = {}
                for cohort = 1, 3 do
                    seconds[cohort] = times[cohort][target.entity]
                    if seconds[cohort] ~= nil then
                        flexibility = flexibility + 1
                        only_cohort = cohort
                        fastest = math.min(fastest, seconds[cohort])
                    end
                end
                if flexibility == 0 then
                    return nil, "asteroid-mixed-uncovered-target"
                end
                bound.work = bound.work + fastest * target.amount
                bound.longest = math.max(bound.longest, fastest)
                if flexibility == 1 then
                    bound.exclusive_work[only_cohort] = (bound.exclusive_work[only_cohort] or 0) + fastest * target.amount
                end
                table.insert(jobs[phase], {
                    entity = target.entity,
                    amount = target.amount,
                    seconds = seconds,
                    flexibility = flexibility,
                    priority = fastest * target.amount,
                })
            end
            table.sort(jobs[phase], function(a, b)
                if a.flexibility ~= b.flexibility then
                    return a.flexibility < b.flexibility
                elseif a.priority ~= b.priority then
                    return a.priority > b.priority
                end
                return a.entity < b.entity
            end)
        end
        return jobs, nil, bounds
    end
    local function phase_lower_bound(jobs, bound, counts)
        local duration = math.max(bound.work / deployment_count, bound.longest)
        if counts ~= nil then
            if not spend(3 * #jobs + 3) then
                return nil
            end
            for cohort = 1, 3 do
                duration = math.max(duration, (bound.exclusive_work[cohort] or 0) / counts[cohort])
            end
            for _, job in pairs(jobs) do
                local throughput = 0
                for cohort = 1, 3 do
                    if job.seconds[cohort] ~= nil then
                        throughput = throughput + counts[cohort] / job.seconds[cohort]
                    end
                end
                duration = math.max(duration, job.amount / throughput)
            end
        end
        return duration
    end
    local function assign(guns, job, deadline)
        local low, high = math.huge, math.huge
        local deadline_capacity = 0
        if not spend(#guns) then
            return nil, "asteroid-mixed-work-budget"
        end
        for _, gun in pairs(guns) do
            local seconds = job.seconds[gun.cohort]
            if seconds ~= nil then
                low = math.min(low, gun.seconds)
                high = math.min(high, gun.seconds + seconds * job.amount)
                deadline_capacity = deadline_capacity + math.min(job.amount, math.max(0, math.floor((deadline - gun.seconds) / seconds)))
            end
        end
        if deadline_capacity < job.amount then
            return nil, "asteroid-mixed-too-slow"
        end
        if not finite(high) then
            return nil, "invalid-asteroid-mixed-time"
        end
        -- At a trial deadline, each gun has an integer capacity after finishing its already assigned jobs.
        -- Search the batch deadline; this is bounded independently of the number of asteroid bodies.
        high = math.min(high, deadline)
        for _ = 1, 32 do
            local middle = low / 2 + high / 2
            if middle == low or middle == high then
                break
            end
            if not spend(#guns) then
                return nil, "asteroid-mixed-work-budget"
            end
            local capacity = 0
            for _, gun in pairs(guns) do
                local seconds = job.seconds[gun.cohort]
                if seconds ~= nil then
                    capacity = capacity + math.min(job.amount, math.max(0, math.floor((middle - gun.seconds) / seconds)))
                end
            end
            if capacity >= job.amount then
                high = middle
            else
                low = middle
            end
        end
        local remaining = job.amount
        for _, gun in pairs(guns) do
            local seconds = job.seconds[gun.cohort]
            if seconds ~= nil then
                local amount = math.min(remaining, math.max(0, math.floor((high - gun.seconds) / seconds)))
                gun.seconds = gun.seconds + amount * seconds
                gun.counts[job.entity] = amount
                remaining = remaining - amount
            end
        end
        if remaining > 0 then
            -- Floating-point boundary residue goes to a real gun and is fully charged, even if that exceeds the estimated deadline.
            local chosen, finish
            for _, gun in pairs(guns) do
                local seconds = job.seconds[gun.cohort]
                if seconds ~= nil then
                    local candidate = gun.seconds + remaining * seconds
                    if finish == nil or candidate < finish then
                        chosen, finish = gun, candidate
                    end
                end
            end
            if chosen == nil or not finite(finish) then
                return nil, "invalid-asteroid-mixed-time"
            end
            chosen.seconds = finish
            chosen.counts[job.entity] = (chosen.counts[job.entity] or 0) + remaining
        end
        return true
    end
    local function allocation(indices, counts, jobs, bounds, deadline)
        local minimums, minimum_total = {}, 0
        for _, phase in pairs(phase_numbers) do
            local minimum = phase_lower_bound(jobs[phase], bounds[phase], counts)
            if minimum == nil then
                return nil, "asteroid-mixed-work-budget"
            end
            minimums[phase] = minimum
            minimum_total = minimum_total + minimum
        end
        -- Fractional throughput is used only to reject impossible allocations, never to certify one.
        if minimum_total > deadline + 1e-12 * deadline then
            diagnostics.allocations_pruned = diagnostics.allocations_pruned + 1
            return nil, "asteroid-mixed-too-slow"
        end
        local total, schedule = 0, {}
        for _, phase in pairs(phase_numbers) do
            minimum_total = math.max(0, minimum_total - minimums[phase])
            -- Roundoff in a lower bound may make an exactly feasible deadline appear slightly short.
            -- The completed schedule is still checked against the original deadline without this search allowance.
            local phase_deadline = deadline - total - minimum_total + 1e-12 * deadline
            local guns = {}
            for cohort = 1, 3 do
                for _ = 1, counts[cohort] do
                    table.insert(guns, {
                        cohort = cohort,
                        profile = indices[cohort],
                        seconds = 0,
                        counts = {},
                    })
                end
            end
            for _, job in pairs(jobs[phase]) do
                local okay, reason = assign(guns, job, phase_deadline)
                if okay ~= true then
                    return nil, reason
                end
            end
            local duration = 0
            for _, gun in pairs(guns) do
                duration = math.max(duration, gun.seconds)
            end
            total = total + duration
            if not finite(total) then
                return nil, "invalid-asteroid-mixed-time"
            elseif total > deadline then
                return nil, "asteroid-mixed-too-slow"
            end
            table.insert(schedule, {
                generation = phase,
                seconds = duration,
                guns = guns,
            })
        end
        return total, nil, schedule
    end
    for a = 1, #eligible - 2 do
        for b = a + 1, #eligible - 1 do
            for c = b + 1, #eligible do
                if diagnostics.triples_scanned >= max_scanned then
                    diagnostics.truncated = true
                    diagnostics.scan_limit_reached = true
                    diagnostics.reason = "asteroid-mixed-scan-budget"
                    return result, diagnostics
                end
                diagnostics.triples_scanned = diagnostics.triples_scanned + 1
                local left, middle, right = eligible[a], eligible[b], eligible[c]
                local left_key = profiles[left].source_key or profiles[left].name or left
                local middle_key = profiles[middle].source_key or profiles[middle].name or middle
                local right_key = profiles[right].source_key or profiles[right].name or right
                local distinct = left_key ~= middle_key and left_key ~= right_key and middle_key ~= right_key
                if not distinct then
                    diagnostics.duplicate_sources_skipped = diagnostics.duplicate_sources_skipped + 1
                elseif options.triple_allowed == nil or options.triple_allowed(profiles[left], profiles[middle], profiles[right]) == true then
                    if diagnostics.triples_attempted >= max_triples then
                        diagnostics.truncated = true
                        diagnostics.triple_limit_reached = true
                        diagnostics.reason = "asteroid-mixed-triple-budget"
                        return result, diagnostics
                    end
                    diagnostics.triples_attempted = diagnostics.triples_attempted + 1
                    if prepare_workload() ~= true then
                        return result, diagnostics
                    end
                    local x, x_reason = costs(left)
                    local y, y_reason = costs(middle)
                    local z, z_reason = costs(right)
                    local jobs, reason, bounds
                    if x ~= nil and y ~= nil and z ~= nil then
                        jobs, reason, bounds = phase_jobs({
                            x,
                            y,
                            z,
                        })
                    else
                        reason = x_reason or y_reason or z_reason
                    end
                    if jobs ~= nil then
                        local minimum = 0
                        for _, phase in pairs(phase_numbers) do
                            minimum = minimum + phase_lower_bound(jobs[phase], bounds[phase])
                        end
                        if minimum > max_seconds + 1e-12 * max_seconds then
                            diagnostics.triples_pruned = diagnostics.triples_pruned + 1
                            jobs, reason = nil, "asteroid-mixed-too-slow"
                        end
                    end
                    local best
                    if jobs == nil then
                        reject(reason)
                    else
                        local indices = {
                            left,
                            middle,
                            right,
                        }
                        for left_count = 1, deployment_count - 2 do
                            for middle_count = 1, deployment_count - left_count - 1 do
                                local right_count = deployment_count - left_count - middle_count
                                diagnostics.allocations_attempted = diagnostics.allocations_attempted + 1
                                local deadline = best and math.min(max_seconds, best.clear_seconds) or max_seconds
                                local seconds, failure, schedule = allocation(indices, {
                                    left_count,
                                    middle_count,
                                    right_count,
                                }, jobs, bounds, deadline)
                                if seconds ~= nil and (best == nil or seconds < best.clear_seconds) then
                                    best = {
                                        left = left,
                                        middle = middle,
                                        right = right,
                                        left_count = left_count,
                                        middle_count = middle_count,
                                        right_count = right_count,
                                        clear_seconds = seconds,
                                        schedule = schedule,
                                    }
                                elseif seconds == nil then
                                    reject(failure)
                                end
                                if diagnostics.work_limit_reached or (options.feasibility_only == true and best ~= nil) then
                                    break
                                end
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
    end
    return result, diagnostics
end

return batteries

local categories = require("src/prototypes/categories")
local rng = require("src/lib/random/rng")
local gutils = require("src/lib/graph/graph-utils")
local check = require("src/randomizations/planetary/check")
local appearances = require("src/randomizations/planetary/biomes")
local profiles = require("src/randomizations/planetary/biome-profiles")
local collision = require("src/randomizations/planetary/biome-collision")
local policy = require("src/randomizations/planetary/biome-entity-policy")

local placement = {}

local function sorted_keys(values)
    local result = {}
    for name, _ in pairs(values) do
        table.insert(result, name)
    end
    table.sort(result)
    return result
end

placement.execute = function(logic, state)
    check.moved_features["biome-placement"] = true
    local sources = profiles.classify(data.raw, defines.prototypes)
    if config.planetary_biomes then
        appearances.execute()
    end
    local memberships, platform = profiles.classify(data.raw, defines.prototypes, sources)
    local aliases, problem = collision.prepare(data.raw, defines.prototypes, function(values) data:extend(values) end)
    if aliases == nil then
        error(problem)
    end
    profiles.mark(data.raw, memberships, platform)
    local after = check.sort(logic)
    if not check.required(state.before, after, state.variants_of, true) then
        error("earlier planetary changes or appearance changes need to be retried before biome placement")
    end

    local entities, buildable = {}, {}
    for kind, _ in pairs(defines.prototypes.entity) do
        for name, entity in pairs(data.raw[kind] or {}) do
            entities[name] = entity
        end
    end
    for kind, _ in pairs(defines.prototypes.item) do
        for _, item in pairs(data.raw[kind] or {}) do
            if item.place_result ~= nil then
                buildable[item.place_result] = true
            end
        end
    end
    -- Optional machines still need somewhere to be built even when another machine can make every recipe.
    local placement_goals = {}
    for name, _ in pairs(buildable) do
        local node_key = gutils.key("entity-build", name)
        if next(after.sort_info.node_to_context_inds[node_key] or {}) ~= nil then
            placement_goals[node_key] = true
        end
    end
    local function keeps_buildings(trial)
        for node_key, _ in pairs(placement_goals) do
            if next(trial.sort_info.node_to_context_inds[node_key] or {}) == nil then
                return false
            end
        end
        return true
    end
    local available = {}
    for _, profile in pairs(profiles.choices) do
        for _, membership in pairs(memberships) do
            if membership[profile] then
                table.insert(available, profile)
                break
            end
        end
    end
    local proposed, infrastructure, assignments = {}, {}, {}
    local statistics = {
        eligible = 0,
        selected = 0,
        everything_draws = 0,
        restrictive_proposed = 0,
        restrictive_kept = 0,
    }
    -- Each prototype gets its own draw, regardless of upgrade links or fast-replaceable group.
    for _, name in pairs(sorted_keys(entities)) do
        local entity = entities[name]
        local mode
        if policy.unrestricted[entity.type] == true or (policy.unrestricted_belts and categories.belts[entity.type] == true) then
            mode = "everything"
        elseif policy.randomized[entity.type] == true then
            mode = "randomized"
        end
        local supported = mode ~= nil and buildable[name] == true
            and placement_goals[gutils.key("entity-build", name)] == true
            and collision.supported(entity, data.raw, platform)
        if supported then
            if mode == "randomized" then
                statistics.eligible = statistics.eligible + 1
            end
            local key = rng.key({id = "planetary-biome-placement", prototype = entity})
            -- Infrastructure always gets Everything; only the approved machines participate in the random draw.
            if mode == "everything" or (#available > 0 and rng.value(key) < 0.5) then
                local profile = mode == "everything" and "everything" or available[rng.int(key, #available)]
                if mode == "randomized" then
                    statistics.selected = statistics.selected + 1
                    if profile == "everything" then
                        statistics.everything_draws = statistics.everything_draws + 1
                    else
                        statistics.restrictive_proposed = statistics.restrictive_proposed + 1
                    end
                end
                table.insert(mode == "everything" and infrastructure or proposed, {
                    profile = profile,
                    candidates = {
                        {
                            entity = entity,
                            mask = table.deepcopy(entity.collision_mask),
                            rules = table.deepcopy(entity.tile_buildability_rules),
                        },
                    },
                })
            end
        end
    end

    -- Check combinations, not just individual assignments: two constructible-terrain requirements can form a cycle.
    -- Split rejected batches until every accepted change has passed against all changes kept so far.
    local rejected = 0
    local function try_batch(batch, first, last)
        if first > last then
            return
        end
        for index = first, last do
            for _, candidate in pairs(batch[index].candidates) do
                collision.apply(candidate.entity, batch[index].profile, aliases)
            end
        end
        local trial = check.sort(logic)
        if keeps_buildings(trial) and check.required(state.before, trial, state.variants_of, true) then
            after = trial
            for index = first, last do
                for _, candidate in pairs(batch[index].candidates) do
                    assignments[candidate.entity.name] = batch[index].profile
                end
            end
            return
        end
        for index = first, last do
            for _, candidate in pairs(batch[index].candidates) do
                candidate.entity.collision_mask = table.deepcopy(candidate.mask)
                candidate.entity.tile_buildability_rules = table.deepcopy(candidate.rules)
            end
        end
        if first == last then
            rejected = rejected + 1
            return
        end
        local middle = math.floor((first + last) / 2)
        try_batch(batch, first, middle)
        try_batch(batch, middle + 1, last)
    end
    -- Validate broader infrastructure access before evaluating machines that may need it.
    try_batch(infrastructure, 1, #infrastructure)
    try_batch(proposed, 1, #proposed)
    -- Count restrictive machine assignments separately from broadened infrastructure access.
    for _, proposal in pairs(proposed) do
        if proposal.profile ~= "everything" then
            for _, candidate in pairs(proposal.candidates) do
                if assignments[candidate.entity.name] == proposal.profile then
                    statistics.restrictive_kept = statistics.restrictive_kept + 1
                end
            end
        end
    end
    state.after = after
    local report = {
        statistics = statistics,
        assignments = assignments,
        aliases = aliases,
        memberships = memberships,
        tile_sources = profiles.tile_sources(data.raw),
        platform = platform,
        rejected = rejected,
    }
    data:extend({
        {
            type = "mod-data",
            name = "propertyrandomizer-biome-placement",
            data = report,
        },
    })
    log("Planetary biome placement: kept " .. (#proposed + #infrastructure - rejected) .. " entities; " .. rejected .. " restored to original placement to preserve progression")
    log("Biome machine selection: eligible=" .. statistics.eligible .. ", selected=" .. statistics.selected
        .. ", restrictive-proposed=" .. statistics.restrictive_proposed .. ", restrictive-kept=" .. statistics.restrictive_kept
        .. ", everything-draws=" .. statistics.everything_draws)
end

return placement

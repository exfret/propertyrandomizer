-- Building terrain requirements use the ordinary second-pass claim/validate/reflect path.
local lookups = require("src/prototypes/lookup/init")
local rng = require("src/lib/random/rng")
local gutils = require("src/lib/graph/graph-utils")
local requirements = require("src/logic/builders/tile-requirements")
local collision = require("src/randomizations/planetary/biome-collision")
local profiles = require("src/randomizations/planetary/biome-profiles")

local placement = {}
placement.id = "biome_placement"
placement.with_replacement = false
placement.first_pass = false

local proposals
local statistics
local claimed
local pool_indices
local MAX_PROPOSALS = 10
placement.initialize = function()
    proposals = {}
    claimed = {}
    pool_indices = nil
    statistics = {
        eligible = 0,
        selected = 0,
        proposals = 0,
        everything_draws = 0,
        everything_kept = 0,
        restrictive_proposed = 0,
        restrictive_kept = 0,
    }
end

local function report()
    local prototype = (data.raw["mod-data"] or {})["propertyrandomizer-biome-placement"]
    return prototype ~= nil and prototype.data or nil
end

placement.spoof = function(graph)
    local metadata = report()
    if metadata == nil then
        return
    end
    local available = {}
    for _, profile in pairs(profiles.choices) do
        for _, membership in pairs(metadata.memberships) do
            if membership[profile] == true then
                table.insert(available, profile)
                break
            end
        end
    end
    local names, entities = {}, {}
    for kind, _ in pairs(defines.prototypes.entity) do
        for name, entity in pairs(data.raw[kind] or {}) do
            if graph.nodes[gutils.key("entity-build", name)] ~= nil then
                entities[name] = entity
                table.insert(names, name)
            end
        end
    end
    table.sort(names)
    local terrain_cache = {}
    for _, name in pairs(names) do
        local entity = entities[name]
        if metadata.entities[name] == "randomized" then
            local key = rng.key({
                id = "planetary-biome-placement",
                prototype = entity,
            })
            if #available > 0 and rng.value(key) < 0.5 then
                local build = graph.nodes[gutils.key("entity-build", name)]
                requirements.native(graph, entity, build)
                local proposal = {
                    build_key = gutils.key(build),
                    options = {},
                    draws = {},
                }
                for index = 1, MAX_PROPOSALS do
                    local profile = available[rng.int(key, #available)]
                    table.insert(proposal.draws, profile)
                    if proposal.options[profile] == nil then
                        local candidate = table.deepcopy(entity)
                        collision.apply(candidate, profile, metadata.aliases)
                        local option = requirements.option(graph, candidate, lookups.tile_collision_group_to_layers,
                            "biome-option: " .. name .. ": " .. profile, terrain_cache)
                        proposal.options[profile] = gutils.key(option)
                    end
                end
                proposals[name] = proposal
            else
                -- Eligibility counts only buildings ordinary claiming can reach, not unsupported or unreachable ones.
                proposals[name] = {
                    unselected = true,
                    build_key = gutils.key("entity-build", name),
                }
            end
        end
    end
end

placement.claim = function(graph, prereq, dep, edge)
    if edge.biome_native == true and dep.type == "entity-build" then
        claimed[dep.name] = true
        -- The native connection is a fallback, never a profile offered to another building.
        return 0
    end
end

placement.may_claim = function(graph, prereq, dep, edge)
    return edge.biome_native == true and dep.type == "entity-build"
end

placement.pool_entries = function(graph, sort_info, can_claim)
    local entries = {}
    for name, proposal in pairs(proposals) do
        local build = graph.nodes[proposal.build_key]
        if next(sort_info.node_to_context_inds[proposal.build_key] or {}) ~= nil then
            if proposal.unselected == true then
                statistics.eligible = statistics.eligible + 1
            elseif claimed[name] == true then
                statistics.eligible = statistics.eligible + 1
                statistics.selected = statistics.selected + 1
                for _, profile in pairs(proposal.draws) do
                    statistics.proposals = statistics.proposals + 1
                    if profile == "everything" then
                        statistics.everything_draws = statistics.everything_draws + 1
                    else
                        statistics.restrictive_proposed = statistics.restrictive_proposed + 1
                    end
                end
                for profile, option_key in pairs(proposal.options) do
                    local option = graph.nodes[option_key]
                    if can_claim({
                        type = option.type,
                        name = option.name,
                        prot = build.prot,
                    }, build) then
                        local base = gutils.add_node(graph, "base", "biome-option: " .. name .. ": " .. profile, {
                            op = "AND",
                            pool_only = true,
                            biome_entity = name,
                            biome_profile = profile,
                        })
                        gutils.add_edge(graph, option, base)
                        proposal.options[profile] = gutils.key(base)
                        table.insert(entries, {
                            base_key = gutils.key(base),
                            num_copies = 1,
                        })
                    else
                        proposal.options[profile] = nil
                    end
                end
            end
        end
    end
    return entries
end

-- Draws are with replacement, capped at ten; repeated failed profiles need only one check.
-- Promotion is unchanged until a proposal succeeds, at which point the shared runner stops.
placement.candidate_indices = function(graph, head, pool)
    if pool_indices == nil then
        pool_indices = {}
        for index, base_key in pairs(pool) do
            pool_indices[base_key] = index
        end
    end
    local build = gutils.get_owner(graph, head)
    local proposal = proposals[build.name]
    local indices, seen = {}, {}
    for _, profile in pairs(proposal.draws) do
        local index = pool_indices[proposal.options[profile]]
        if index ~= nil and not seen[index] then
            table.insert(indices, index)
            seen[index] = true
        end
    end
    return indices
end

placement.validate = function(graph, base, head)
    local build = gutils.get_owner(graph, head)
    return base.biome_entity == build.name and base.biome_profile ~= nil
end

placement.reflect = function(graph, head_to_base, head_to_handler)
    local metadata = report()
    if metadata == nil then
        return
    end
    metadata.assignments = {}
    metadata.rejected = 0
    for head_key, base_key in pairs(head_to_base) do
        if head_to_handler[head_key].id == placement.id then
            local build = gutils.get_owner(graph, graph.nodes[head_key])
            local option = graph.nodes[base_key]
            if option.biome_profile ~= nil then
                local prototype = gutils.deconstruct(build.prot)
                collision.apply(data.raw[prototype.type][prototype.name], option.biome_profile, metadata.aliases)
                metadata.assignments[build.name] = option.biome_profile
                if option.biome_profile ~= "everything" then
                    statistics.restrictive_kept = statistics.restrictive_kept + 1
                else
                    statistics.everything_kept = statistics.everything_kept + 1
                end
            else
                metadata.rejected = metadata.rejected + 1
            end
        end
    end
    metadata.statistics = statistics
    log("Biome second pass: eligible=" .. statistics.eligible .. ", selected=" .. statistics.selected
        .. ", restrictive-kept=" .. statistics.restrictive_kept .. ", everything-kept=" .. statistics.everything_kept
        .. ", restored=" .. metadata.rejected)
end

placement.release = function()
    proposals, statistics, claimed, pool_indices = nil, nil, nil, nil
end

return placement

-- TODO: Cost checking (just reject very expensive fluids)

-- Bases are mining-fluid nodes: a fluid together with the resource category variant that takes a fluid input (lutils.mcat_name), since only machines with an input fluid box mine a resource needing a fluid, never the character (fluid_amount > 0 means it can't be mined by hand, see MinableProperties in the API docs)
-- prefixes.lua gives every mining drill an input fluid box, so this mostly takes hand mining away
-- A resource can only gain a fluid if its category's fluid input variant has a resource-category node in logic (some resource of that category needed a fluid)
-- With first pass and promotion, every resource's fluid is chosen up front (choose_up_front below), and the shuffle only chooses them without those

local gutils = require("lib/graph/graph-utils")
local lutils = require("lib/logic/logic-utils")
local top = require("lib/graph/context-sort")
local rng = require("lib/random/rng")
local logic = require("lib/logic/init")

local mining_fluid_required = {}

mining_fluid_required.id = "mining_fluid_required"

mining_fluid_required.with_replacement = true

mining_fluid_required.initialize = function()
end

-- Name of the base meaning "no fluid needed"
local NO_FLUID = "no-fluid-spoof"

-- Resource category variant (lutils.mcat_name) for mining this resource with a fluid input
local function fluid_mcat(resource)
    local fluids = lutils.find_mining_fluids(resource)
    return gutils.concat({resource.category or "basic-solid", 1, fluids.output})
end

mining_fluid_required.spoof = function(graph)
    -- Spoofed type, only in this graph; transmits contexts like fluids do
    logic.type_info["mining-fluid"] = logic.type_info["mining-fluid"] or {
        op = "AND",
        canonical = "mining-fluid",
    }

    -- Dummy base so that resources can lose required fluids
    local no_fluid = gutils.add_node(graph, "mining-fluid", NO_FLUID, {
        op = "OR",
        spoof = true,
    })
    gutils.add_edge(graph, graph.nodes[gutils.key("true", "")], no_fluid)

    -- Fluid input category variants logic can mine with
    local fluid_mcats = {}
    for mcat_key, mcat in pairs(lookups.mcats) do
        if mcat.input == 1 and graph.nodes[gutils.key("resource-category", mcat_key)] ~= nil then
            fluid_mcats[mcat_key] = true
        end
    end

    -- Base for mining with this fluid in this category variant, and a dummy head so it can go unused
    local function get_mining_fluid(fluid_name, mcat_key)
        local name = gutils.concat({fluid_name, mcat_key}, 2)
        local node_key = gutils.key("mining-fluid", name)
        if graph.nodes[node_key] == nil then
            local node = gutils.add_node(graph, "mining-fluid", name, {
                op = "AND",
                spoof = true,
                fluid = fluid_name,
                mcat = mcat_key,
            })
            gutils.add_edge(graph, graph.nodes[gutils.key("fluid", fluid_name)], node)
            gutils.add_edge(graph, graph.nodes[gutils.key("resource-category", mcat_key)], node)

            local spoof_resource = gutils.add_node(graph, "entity-mine", "entity-mine-fluid-spoof-" .. name, {
                op = "AND",
                spoof = true,
            })
            gutils.add_edge(graph, node, spoof_resource)
        end
        return graph.nodes[node_key]
    end

    -- Resources needing a fluid now need it through their mining-fluid node
    local fluid_edges = {}
    for edge_key, edge in pairs(graph.edges) do
        local start = graph.nodes[edge.start]
        local stop = graph.nodes[edge.stop]
        if start.type == "fluid" and stop.type == "entity-mine" and data.raw.resource[stop.name] ~= nil then
            table.insert(fluid_edges, edge_key)
        end
    end
    for _, edge_key in pairs(fluid_edges) do
        local edge = graph.edges[edge_key]
        local fluid_name = graph.nodes[edge.start].name
        local mcat_key = fluid_mcat(data.raw.resource[graph.nodes[edge.stop].name])
        if graph.nodes[gutils.key("resource-category", mcat_key)] ~= nil then
            gutils.redirect_edge_start(graph, edge_key, gutils.key(get_mining_fluid(fluid_name, mcat_key)))
        end
    end

    -- Do a sort so we only consider reachable nodes
    local sort_info = top.sort(graph)

    local already_checked_fluid = {}
    local already_checked_resource = {}
    for _, pebble in pairs(sort_info.sorted) do
        local node = graph.nodes[pebble.node_key]
        if node.type == "fluid" and not already_checked_fluid[node.name] then
            already_checked_fluid[node.name] = true

            for mcat_key, _ in pairs(fluid_mcats) do
                get_mining_fluid(node.name, mcat_key)
            end
        end
        if node.type == "entity-mine" and not node.spoof and not already_checked_resource[node.name] then
            already_checked_resource[node.name] = true

            local resource = data.raw.resource[node.name]
            if resource ~= nil and resource.minable ~= nil and resource.minable.required_fluid == nil then
                gutils.add_edge(graph, no_fluid, node)
            end
        end
    end
end

-- How many resources need a mining fluid, when the game allows that many (user, 2026-09-30: "about 2-3 ores with fluids per game")
local MIN_WITH_FLUID = 2
local MAX_WITH_FLUID = 3
-- How many resources' fluids are tried on the whole game at most, one sort each (a failing one is cheap when it's an early resource, since cutting it off leaves little to sort)
local MAX_CHECKS = 8

-- Chooses every resource's mining fluid before promotion ranks anything (see choose_up_front in handlers/default.lua)
-- A resource needing no fluid has a free vanilla base, so promotion's ranks put its head near the start, and a fluid could only pass if it happened to sort before the resource's mining, which one random order rarely shows (logged on sa/preview seeds 1 to 4 on 2026-09-29: of about 22 fluids each, none passed for any resource but uranium, and once for tungsten)
-- So random resources each get a random fluid, one at a time, and one keeps it only if with it and the ones kept so far unmineable, each of their fluids is still had wherever its resource was mined
-- Then no fluid needs any of them, so each is mined wherever it was before and the game reaches everything it did; one that fails (like iron ore needing water on Nauvis, when pumping water takes iron) gives way to the next, and the ones kept so far stay
-- Every other resource needs no fluid, and a resource that needs one in vanilla keeps it if too few others could take one
mining_fluid_required.choose_up_front = function(params)
    local graph = params.random_graph
    local baseline = params.baseline_sort.node_to_context_inds
    local unified_key = rng.key({ id = "unified" })

    -- The pool's fluid bases, and a base meaning no fluid
    local fluid_bases = {}
    local no_fluid_base
    local seen = {}
    for _, base_key in pairs(params.pool) do
        if seen[base_key] == nil then
            seen[base_key] = true
            if gutils.get_owner(graph, graph.nodes[base_key]).name == NO_FLUID then
                no_fluid_base = no_fluid_base or base_key
            else
                table.insert(fluid_bases, base_key)
            end
        end
    end

    local function mine_key(head_key)
        return gutils.key(gutils.unique_depnode(graph, graph.nodes[head_key]))
    end
    local function owner_of(base_key)
        return gutils.get_owner(graph, graph.nodes[base_key])
    end
    -- Whether a sort has the fluid of a fluid base in every one of these contexts (its connection to a head adds or removes no abilities, see below)
    local function had_in(node_to_context_inds, base_key, contexts)
        local had = node_to_context_inds[gutils.key(owner_of(base_key))] or {}
        for context, _ in pairs(contexts) do
            if had[context] == nil then
                return false
            end
        end
        return true
    end

    -- Resources that could take a fluid, in random order, each with a random fluid had wherever it's mined in first pass's sort (which could still need the resource itself; the check below settles that)
    local candidates = {}
    for _, head_key in pairs(params.heads) do
        local contexts = baseline[mine_key(head_key)] or {}
        local options = {}
        if next(contexts) ~= nil then
            for _, base_key in pairs(fluid_bases) do
                local base = graph.nodes[base_key]
                if base.abilities == nil and mining_fluid_required.validate(graph, base, graph.nodes[head_key]) and had_in(baseline, base_key, contexts) then
                    table.insert(options, base_key)
                end
            end
        end
        if #options > 0 then
            table.insert(candidates, {
                head_key = head_key,
                base_key = options[rng.int(unified_key, #options)],
            })
        end
    end
    rng.shuffle(unified_key, candidates)
    -- Last, a resource that needs a fluid in vanilla keeps it
    for _, head_key in pairs(params.heads) do
        local old_base = graph.nodes[head_key].old_base
        if owner_of(old_base).name ~= NO_FLUID then
            table.insert(candidates, {
                head_key = head_key,
                base_key = old_base,
            })
        end
    end
    local target = MIN_WITH_FLUID - 1 + rng.int(unified_key, MAX_WITH_FLUID - MIN_WITH_FLUID + 1)

    local function describe(head_keys, fluids)
        local names = {}
        for _, head_key in pairs(head_keys) do
            table.insert(names, gutils.get_owner(graph, graph.nodes[head_key]).name .. " <- " .. tostring(owner_of(fluids[head_key]).fluid))
        end
        return #names > 0 and table.concat(names, ", ") or "none"
    end

    -- head key --> fluid base, for the resources with a fluid (in order, the order they got it)
    local fluids = {}
    local order = {}
    local num_checks = 0
    local next_candidate = 1
    while #order < target and next_candidate <= #candidates and num_checks < MAX_CHECKS do
        local candidate = candidates[next_candidate]
        next_candidate = next_candidate + 1
        if fluids[candidate.head_key] == nil then
            fluids[candidate.head_key] = candidate.base_key
            local trial = table.deepcopy(order)
            table.insert(trial, candidate.head_key)
            local cut_off = {}
            for _, head_key in pairs(trial) do
                table.insert(cut_off, mine_key(head_key))
            end
            local sort_info = params.sort_without(cut_off)
            num_checks = num_checks + 1
            local passes = true
            for _, head_key in pairs(trial) do
                if not had_in(sort_info.node_to_context_inds, fluids[head_key], baseline[mine_key(head_key)] or {}) then
                    passes = false
                    break
                end
            end
            log("Mining fluids up front, check " .. num_checks .. ": " .. describe({ candidate.head_key }, fluids) .. (passes and " kept" or " dropped"))
            if passes then
                order = trial
            else
                fluids[candidate.head_key] = nil
            end
        end
    end

    -- Every head's base: its fluid, no fluid, or for a resource that needs none in vanilla, its own base
    local chosen = {}
    for _, head_key in pairs(params.heads) do
        local old_base = graph.nodes[head_key].old_base
        if fluids[head_key] ~= nil then
            chosen[head_key] = fluids[head_key]
        elseif owner_of(old_base).name == NO_FLUID then
            chosen[head_key] = old_base
        else
            chosen[head_key] = no_fluid_base or old_base
        end
    end
    log("Mining fluids up front (aiming for " .. target .. "): " .. describe(order, fluids) .. "; every other resource needs none")
    return chosen
end

mining_fluid_required.claim = function(graph, prereq, dep, edge)
    if prereq.type == "mining-fluid" and dep.type == "entity-mine" then
        return 1
    end
end

mining_fluid_required.validate = function(graph, base, head, extra)
    local base_owner = gutils.get_owner(graph, base)
    if base_owner.type ~= "mining-fluid" then
        return false
    end

    local head_owner = gutils.get_owner(graph, head)
    local resource = data.raw.resource[head_owner.name]
    if resource == nil then
        -- Dummy heads take any fluid
        return base_owner.name ~= NO_FLUID
    end
    if base_owner.name == NO_FLUID then
        return true
    end
    return base_owner.mcat == fluid_mcat(resource)
end

-- This is actually a tenth of the actual fluid used amount it seems, so about 40 is a good median
local possible_fluid_amounts = {
    10,
    20,
    40,
    50,
    100,
}
mining_fluid_required.reflect = function(graph, head_to_base, head_to_handler)
    for head_key, base_key in pairs(head_to_base) do
        if head_to_handler[head_key].id == "mining_fluid_required" then
            local head = graph.nodes[head_key]
            local resource_node = gutils.get_owner(graph, head)
            -- Check for dummies
            if not resource_node.spoof then
                local resource = data.raw.resource[resource_node.name]
                local base = graph.nodes[base_key]
                local base_owner = gutils.get_owner(graph, base)
                if base_owner.name == NO_FLUID then
                    resource.minable.required_fluid = nil
                    resource.minable.fluid_amount = 0
                else
                    resource.minable.required_fluid = base_owner.fluid
                    if resource.minable.fluid_amount == nil or resource.minable.fluid_amount == 0 then
                        resource.minable.fluid_amount = possible_fluid_amounts[rng.int(rng.key({ id = "unified" }), #possible_fluid_amounts)]
                    end
                end
            end
        end
    end
end

return mining_fluid_required

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

-- How many resources the user first wanted needing a mining fluid: about 2 or 3 per game in Space Age (2026-09-30), which the tries are counted from
local MIN_GOAL = 2
local MAX_GOAL = 3
-- Resources tried on average beyond 2 * goal, leaving room for tries that fail: 3 or 4 resources with a fluid would be more fun, where that many can take one (user, 2026-10-08: "no need to fret if it stays near 2-3"), and the goal is a goal rather than a bound
local EXTRA_TRIES = 6
-- How many sorts of the whole game the checks take at most (up to a few seconds each in Space Age and a minute with planet copies and deposits, though one cutting off an early resource is cheap, since little is left to sort)
local MAX_CHECKS = 8

-- Chooses every resource's mining fluid before promotion ranks anything (see choose_up_front in handlers/default.lua)
-- A resource needing no fluid has a free vanilla base, so promotion's ranks put its head near the start, and a fluid could only pass if it happened to sort before the resource's mining, which one random order rarely shows (logged on sa/preview seeds 1 to 4 on 2026-09-29: of about 22 fluids each, none passed for any resource but uranium, and once for tungsten)
-- So each resource that could take a fluid (one that's automatable before its mining is, see automatable_before) is tried on a coin flip weighted so that EXTRA_TRIES + 2 * goal are tried on average (user, 2026-10-08)
-- A tried resource keeps a random fluid among those that work: with the resource unmineable, the fluid is still had wherever it was mined, while the resources kept so far need their fluids and are still mined wherever they were
-- Then no fluid needs its own resource, so each is mined wherever it was before and the game reaches everything it did; a resource no fluid works for (like iron ore when every fluid it could take needs pumps made of iron) gets none
-- The first check cuts every tried resource off at once, and each that has a fluid working then keeps it, since cutting off fewer only reaches more; the rest are checked one at a time after, since a resource cut off with them may be what their fluids needed
-- Every other resource needs no fluid, including one that needs one in vanilla
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
    -- Whether a sort has a node in every one of these contexts
    local function node_had_in(node_to_context_inds, node_key, contexts)
        local had = node_to_context_inds[node_key] or {}
        for context, _ in pairs(contexts) do
            if had[context] == nil then
                return false
            end
        end
        return true
    end
    -- Whether a sort has the fluid of a fluid base in every one of these contexts (its connection to a head adds or removes no abilities, see below)
    local function had_in(node_to_context_inds, base_key, contexts)
        return node_had_in(node_to_context_inds, gutils.key(owner_of(base_key)), contexts)
    end
    -- Whether first pass's sort has mining with the fluid of a fluid base automatable before the resource's own mining, wherever that's automatable
    -- Otherwise the resource would wait on the fluid with only hand work to stand in, like stone from rocks for as long as sulfuric acid took (user, 2026-10-07)
    local function automatable_before(base_key, contexts)
        local had = baseline[gutils.key(owner_of(base_key))] or {}
        for context, ind in pairs(contexts) do
            local abilities = top.context_abilities(context)
            if abilities ~= nil and top.context_home(context) == nil and string.sub(abilities, top.AUTOMATABILITY, top.AUTOMATABILITY) == "1" then
                if had[context] == nil or had[context] >= ind then
                    return false
                end
            end
        end
        return true
    end

    -- Resources that could take a fluid, in random order, each with every fluid had wherever it's mined in first pass's sort and automatable before it is (which could still need the resource itself; the checks below settle that)
    local candidates = {}
    for _, head_key in pairs(params.heads) do
        local contexts = baseline[mine_key(head_key)] or {}
        local options = {}
        if next(contexts) ~= nil then
            for _, base_key in pairs(fluid_bases) do
                local base = graph.nodes[base_key]
                if base.abilities == nil and mining_fluid_required.validate(graph, base, graph.nodes[head_key]) and had_in(baseline, base_key, contexts) and automatable_before(base_key, contexts) then
                    table.insert(options, base_key)
                end
            end
        end
        if #options > 0 then
            table.insert(candidates, {
                head_key = head_key,
                options = options,
            })
        end
    end
    rng.shuffle(unified_key, candidates)

    -- The ones tried, each on the same coin flip
    local goal = MIN_GOAL - 1 + rng.int(unified_key, MAX_GOAL - MIN_GOAL + 1)
    local num_tries = EXTRA_TRIES + 2 * goal
    local chance = math.min(1, num_tries / math.max(1, #candidates))
    local tried = {}
    for _, candidate in pairs(candidates) do
        if rng.value(unified_key) < chance then
            table.insert(tried, candidate)
        end
    end

    local function name_of(head_key)
        return gutils.get_owner(graph, graph.nodes[head_key]).name
    end
    local function describe(head_key, base_key)
        return name_of(head_key) .. " <- " .. tostring(owner_of(base_key).fluid)
    end

    -- head key --> fluid base, for the resources with a fluid, and those resources in the order they got it
    local fluids = {}
    local order = {}
    local num_checks = 0
    -- A random one of the candidate's fluids that the sort has wherever its resource was mined, or nil if there's none
    local function working_fluid(sort_info, candidate)
        local contexts = baseline[mine_key(candidate.head_key)]
        local working = {}
        for _, base_key in pairs(candidate.options) do
            if had_in(sort_info.node_to_context_inds, base_key, contexts) then
                table.insert(working, base_key)
            end
        end
        if #working == 0 then
            return nil
        end
        return working[rng.int(unified_key, #working)]
    end

    -- First every tried resource at once
    local left = {}
    if #tried > 0 then
        local cut_off = {}
        for _, candidate in pairs(tried) do
            table.insert(cut_off, mine_key(candidate.head_key))
        end
        local sort_info = params.sort_without(cut_off)
        num_checks = num_checks + 1
        local kept_names = {}
        local left_names = {}
        for _, candidate in pairs(tried) do
            local base_key = working_fluid(sort_info, candidate)
            if base_key ~= nil then
                fluids[candidate.head_key] = base_key
                table.insert(order, candidate.head_key)
                table.insert(kept_names, describe(candidate.head_key, base_key))
            else
                table.insert(left, candidate)
                table.insert(left_names, name_of(candidate.head_key))
            end
        end
        log("Mining fluids up front, check 1 (" .. #tried .. " at once): " .. (#kept_names > 0 and table.concat(kept_names, ", ") .. " kept" or "none kept") .. (#left_names > 0 and "; none works yet for " .. table.concat(left_names, ", ") or ""))
    end
    -- Then each of the rest on its own, with the ones kept so far needing their fluids (with one tried, that would be the same sort again)
    for i, candidate in pairs(#tried > 1 and left or {}) do
        if num_checks >= MAX_CHECKS then
            log("Mining fluids up front: out of checks, so " .. (#left - i + 1) .. " tried resources stay without a fluid")
            break
        end
        local sort_info = params.sort_without({ mine_key(candidate.head_key) }, fluids)
        num_checks = num_checks + 1
        local base_key = working_fluid(sort_info, candidate)
        -- A resource kept so far that isn't mined everywhere it was without this one
        local lost
        if base_key ~= nil then
            for _, head_key in pairs(order) do
                if not node_had_in(sort_info.node_to_context_inds, mine_key(head_key), baseline[mine_key(head_key)]) then
                    lost = head_key
                    break
                end
            end
        end
        if base_key == nil then
            log("Mining fluids up front, check " .. num_checks .. ": " .. name_of(candidate.head_key) .. " dropped, since no fluid works without it")
        elseif lost ~= nil then
            log("Mining fluids up front, check " .. num_checks .. ": " .. name_of(candidate.head_key) .. " dropped, since without it " .. name_of(lost) .. " isn't mined everywhere it was")
        else
            fluids[candidate.head_key] = base_key
            table.insert(order, candidate.head_key)
            log("Mining fluids up front, check " .. num_checks .. ": " .. describe(candidate.head_key, base_key) .. " kept")
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
    local names = {}
    for _, head_key in pairs(order) do
        table.insert(names, describe(head_key, fluids[head_key]))
    end
    log("Mining fluids up front: tried " .. #tried .. " of " .. #candidates .. " resources that could take a fluid (chance " .. string.format("%.2f", chance) .. ", aiming to try " .. num_tries .. "), " .. num_checks .. " checks; " .. #order .. " need one: " .. (#names > 0 and table.concat(names, ", ") or "none") .. "; every other resource needs none")
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

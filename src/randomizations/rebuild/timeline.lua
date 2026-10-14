-- Places the rebuilt tech tree along one walk of the game's timeline (src/randomizations/rebuild/tree.lua runs it; an earlier core that sorted the game again at every step took 40-90 s, user 2026-10-13: "a new algorithm altogether is warranted")
-- The timeline is one sort of the game without tech prerequisites (gates aside): the order the sort reached each recipe in each room, isolatable or not, and in each home context
-- Walking it once, in that order:
--   * A recipe gets a technology where nothing it has yet gives it what it had there in time; a room needing discovery gets one of its own where the recipe's other ones make it wait for discoveries the recipe doesn't need there (user's rules, 2026-10-12)
--   * Its prerequisites are the technologies behind the recipe's other inputs on that walk, the room's discovery, and what its research needs; its research is copied from a technology that unlocked the recipe in time, takes the packs of every discovery it comes after, and changes to fit the room where it has to (user, 2026-10-13: "Change its research to fit")
--   * A kept technology (like a planet's discovery) gets the technologies of the route there and of its starting recipes as prerequisites, and brings the starting recipes it can
-- The rule that keeps the game whole: everything a technology waits for was reached earlier on the timeline than every pebble it has to give in time, in the context it has to give it (computed here with the sort's own context rules for technologies)
-- By induction along the timeline, every pebble the sort had is then reached in the rebuilt game too, so nothing is lost and nothing deadlocks, without sorting the game again; the final check still sorts the rebuilt game

local gutils = require("src/lib/graph/graph-utils")
local top = require("src/lib/sort/context-sort")
local ctx = require("src/logic/contexts/contexts")
local logic = require("src/logic/state")
local unlock_contraction = require("src/logic/analysis/unlock-contraction")

local timeline = {}

local SLOTS = ctx.SLOTS
local HOME_STRIDE = ctx.HOME_STRIDE
local ISOLATED = ctx.ISOLATED
local floor = math.floor

-- Keys of the technologies the walk places, which the tree names afterwards (tree.lua); nothing in the game has such names
local UNIT_PREFIX = "propertyrandomizer-rebuild-"

local function sorted_keys(tbl)
    local keys = {}
    for key, _ in pairs(tbl or {}) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

local function subset(set, of)
    for key, _ in pairs(set or {}) do
        if of[key] == nil then
            return false
        end
    end
    return true
end

local function union_into(target, set)
    for key, _ in pairs(set or {}) do
        target[key] = true
    end
    return target
end

local function max_or_nil(a, b)
    if a == nil or b == nil then
        return nil
    end
    return a > b and a or b
end

local function min_or_other(a, b)
    if a == nil then
        return b
    end
    if b == nil then
        return a
    end
    return a < b and a or b
end

-- params (tree.lua builds them):
--   graph: the logic graph of the game as it is, without tech prerequisites other than gates; read only
--   sort: a complex sort of it with home contexts, the timeline
--   technologies, recipes: data.raw's
--   rebuilt: set of the recipes that get technologies of their own
--   unlockers: recipe name --> the techs unlocking it with research to copy, in the order to prefer them
--   kept: set of the techs the logic needs for more than recipe unlocks, which keep their research and get prerequisites here
--   discovers: tech name --> sorted list of the rooms it discovers; discoverers: room --> set of the techs discovering it (rooms needing discovery)
--   gate_of: room --> the discovery a room's recipes come after, or nil for a room needing none
--   input_gates: tech name --> set of the discoveries it came after in the game (like a planet copy's), which whatever copies its research comes after too
--   starting: room --> set of its starting recipes (src/randomizations/rebuild/starting-recipes.lua); starting_trigger: room .. "\n" .. recipe --> true where the room meets that recipe's trigger itself
--   num_recipe_unlocks: tech name --> how many recipes it unlocks; research_key: tree_checks.research_key; labs_taking(packs) --> set of the labs taking them all
-- Returns the plan: { units = list, unit_of_key, kept = tech name --> { prereqs, packaged }, counts, given_up, waiting, num_waiting, kept_never, inherent_discoveries(recipe, room) }
timeline.run = function(params)
    local graph = params.graph
    local sort = params.sort
    local technologies = params.technologies
    local nci = sort.node_to_context_inds
    local pebble_keys = sort.pebble_keys
    local pebble_contexts = sort.pebble_contexts
    local context_info = sort.context_info
    local home_sets = sort.home_sets or {}

    local counts = {
        units = 0,
        evaluations = 0,
        changed_research = 0,
        changed_to_packs = 0,
        left_out = 0,
        given_up = 0,
        packaged_start = 0,
        packaged_own = 0,
        starting_prerequisites = 0,
        later_science = 0,
        not_needed = 0,
        served_missed = 0,
        route_left_out = 0,
        needs = 0,
        needs_otherwise = 0,
        no_needs = 0,
        -- Derivations through a forgetter or a research with no context all its inputs share, which took each input's earliest pebble (not expected)
        unjoined = 0,
    }
    local given_up = {}

    ----------------------------------------------------------------------
    -- Contexts
    ----------------------------------------------------------------------

    -- Rooms as numbers (contexts are room number * SLOTS + ability mask, src/logic/contexts/contexts.lua), and their keys
    local room_nums = {}
    local room_key_of = {}
    local num_of_room = {}
    for room, _ in pairs(context_info.of or {}) do
        local num = floor(ctx.complex(room, 0) / SLOTS)
        table.insert(room_nums, num)
        room_key_of[num] = room
        num_of_room[room] = num
    end
    table.sort(room_nums)
    -- Home set id --> the home contexts of it (one per room of the core's home set, else one on the carrier room), see build_context_info in context-sort.lua
    local home_ids = {}
    local home_contexts = {}
    for _, room_homes in pairs(context_info.home_of or {}) do
        for home_id, context in pairs(room_homes) do
            if home_contexts[home_id] == nil then
                home_contexts[home_id] = {}
                table.insert(home_ids, home_id)
            end
            table.insert(home_contexts[home_id], context)
        end
    end
    table.sort(home_ids)
    for _, list in pairs(home_contexts) do
        table.sort(list)
    end
    local function home_of(context)
        if context >= HOME_STRIDE then
            return floor(context / HOME_STRIDE)
        end
        return nil
    end
    local function room_num_of(context)
        return floor((context % HOME_STRIDE) / SLOTS)
    end
    local function mask_of(context)
        return (context % HOME_STRIDE) % SLOTS
    end
    local function is_iso(context)
        return context < HOME_STRIDE and floor(mask_of(context) / ISOLATED) % 2 == 1
    end
    -- The class of a context a technology has to give: "p" and a room number for one without isolatability (a technology gives those in every room at once), "i" and a room number for an isolatable one, "h" and a home set id for a home context
    local function class_of(context)
        local home_id = home_of(context)
        if home_id ~= nil then
            return "h", home_id
        end
        if is_iso(context) then
            return "i", room_num_of(context)
        end
        return "p", room_num_of(context)
    end
    local function class_key(kind, id)
        return kind .. id
    end
    -- Room number --> its home set id, for the discovery rule (top.home_sets)
    local home_id_of_room = {}
    for room, home_id in pairs(home_sets.of or {}) do
        if num_of_room[room] ~= nil then
            home_id_of_room[num_of_room[room]] = home_id
        end
    end
    -- Room number --> when the timeline discovered it: the first pebble of any of its discoverers (top.room_discoverers), as the sort's discovery rule runs once a discoverer is processed
    local discovered_at = {}
    for room, discoverer_keys in pairs(top.room_discoverers(graph)) do
        local num = num_of_room[room]
        if num ~= nil then
            for _, discoverer_key in pairs(discoverer_keys) do
                for _, rank in pairs(nci[discoverer_key] or {}) do
                    discovered_at[num] = min_or_other(discovered_at[num], rank)
                end
            end
        end
    end

    ----------------------------------------------------------------------
    -- What the timeline gives technologies and their research inputs
    ----------------------------------------------------------------------

    -- A technology's timing, as the sort gives it: P when it's had without isolatability (in every room at once, as technologies forget the room), I[room] when it's isolatable in a room, and H[home id] when it's had in a home set's home context
    -- Research inputs and other nodes keep the room: auto[room] and iso[room] when they're had there (any context without and with isolatability: edges into technologies add automatability), hctx[home context] in each home context
    local summary_memo = {}
    local function summary_of(node_key)
        local summary = summary_memo[node_key]
        if summary ~= nil then
            return summary
        end
        summary = {
            auto = {},
            iso = {},
            hctx = {},
            I = {},
            H = {},
        }
        for context, rank in pairs(nci[node_key] or {}) do
            local home_id = home_of(context)
            if home_id ~= nil then
                summary.hctx[context] = rank
                summary.H[home_id] = min_or_other(summary.H[home_id], rank)
            else
                local num = room_num_of(context)
                local mask = mask_of(context)
                -- The context without abilities is there whenever any is (a pebble stands for the weaker contexts of its room), at the earliest of them
                if mask == 0 then
                    summary.auto[num] = rank
                    summary.P = min_or_other(summary.P, rank)
                elseif mask == ISOLATED then
                    summary.iso[num] = rank
                    summary.I[num] = rank
                end
            end
        end
        summary_memo[node_key] = summary
        return summary
    end

    -- When a technology with these inputs would have each context, by the sort's rules for technologies (top.sort, node_transmit and strongest_transmit in context-sort.lua):
    --   * every input reaches it through an edge adding automatability, and it needs all of them in one context, which it then gives every room (isolatability only in its own room)
    --   * in a home context, it needs all of them in it, and gives it everywhere the home set has one
    --   * the discovery rule: once a room is discovered, a technology had in the room's home set's home context (and in the room at all) is isolatable there
    -- prereqs are summaries of technologies (forgetters), research those of the research's inputs; returns { P, I, H }, P nil if it never would be
    local function evaluate(prereq_summaries, research_summaries)
        counts.evaluations = counts.evaluations + 1
        local result = {
            I = {},
            H = {},
            -- Room number --> when the discovery rule makes it isolatable there, which can come late (see late_ok)
            IR = {},
        }
        -- Without isolatability: the research in its best room, after every prerequisite
        local research_p
        if #research_summaries == 0 then
            research_p = 0
        else
            for _, num in pairs(room_nums) do
                local arrival = 0
                for _, research in pairs(research_summaries) do
                    local rank = research.auto[num]
                    if rank == nil then
                        arrival = nil
                        break
                    end
                    if rank > arrival then
                        arrival = rank
                    end
                end
                if arrival ~= nil and (research_p == nil or arrival < research_p) then
                    research_p = arrival
                end
            end
        end
        local p = research_p
        for _, prereq in pairs(prereq_summaries) do
            p = max_or_nil(p, prereq.P)
        end
        result.P = p
        if p == nil then
            return result
        end
        -- Home contexts
        for _, home_id in pairs(home_ids) do
            local best
            for _, context in pairs(home_contexts[home_id]) do
                local arrival = 0
                for _, research in pairs(research_summaries) do
                    local rank = research.hctx[context]
                    if rank == nil then
                        arrival = nil
                        break
                    end
                    if rank > arrival then
                        arrival = rank
                    end
                end
                if arrival ~= nil and (best == nil or arrival < best) then
                    best = arrival
                end
            end
            for _, prereq in pairs(prereq_summaries) do
                best = max_or_nil(best, prereq.H[home_id])
            end
            result.H[home_id] = best
        end
        -- Isolatability: all inputs isolatable in the room, or the discovery rule
        for _, num in pairs(room_nums) do
            local direct = 0
            for _, research in pairs(research_summaries) do
                direct = max_or_nil(direct, research.iso[num])
            end
            for _, prereq in pairs(prereq_summaries) do
                direct = max_or_nil(direct, prereq.I[num])
            end
            local rule
            local home_id = home_id_of_room[num]
            if home_id ~= nil and result.H[home_id] ~= nil and discovered_at[num] ~= nil then
                rule = math.max(result.H[home_id], discovered_at[num], p)
            end
            result.IR[num] = rule
            result.I[num] = min_or_other(direct, rule)
        end
        return result
    end
    -- For offline checks (params.validate): every technology's timing worked out from its inputs, against the sort's
    -- Too lenient (a context the sort didn't give, or earlier than it gave it) would break the rule that keeps the game whole; too strict only costs prerequisites
    local validation
    if params.validate then
        validation = {
            lenient = 0,
            strict = 0,
            checked = 0,
            examples = {},
        }
        local function note(kind, line)
            validation[kind] = validation[kind] + 1
            if #validation.examples < 30 then
                table.insert(validation.examples, kind .. ": " .. line)
            end
        end
        for node_key, node in pairs(graph.nodes) do
            if node.type == "technology" then
                local prereqs = {}
                local research = {}
                for pre, _ in pairs(node.pre) do
                    local start = graph.edges[pre].start
                    if graph.nodes[start].type == "technology" then
                        table.insert(prereqs, summary_of(start))
                    else
                        table.insert(research, summary_of(start))
                    end
                end
                local own = summary_of(node_key)
                local result = evaluate(prereqs, research)
                validation.checked = validation.checked + 1
                local function compare(label, evaluated, actual)
                    if evaluated ~= nil and (actual == nil or evaluated >= actual) then
                        note("lenient", node_key .. " " .. label .. " evaluated " .. tostring(evaluated) .. ", sort " .. tostring(actual))
                    elseif evaluated == nil and actual ~= nil then
                        note("strict", node_key .. " " .. label .. " sort " .. tostring(actual) .. ", evaluated none")
                    end
                end
                compare("P", result.P, own.P)
                for _, num in pairs(room_nums) do
                    compare("I " .. room_key_of[num], result.I[num], own.I[num])
                end
                for _, home_id in pairs(home_ids) do
                    compare("H " .. home_id, result.H[home_id], own.H[home_id])
                end
            end
        end
    end

    -- When a technology gives a class of context (class_of), or nil
    local function anchor(tech, kind, id)
        if kind == "p" then
            return tech.P
        elseif kind == "i" then
            return tech.I[id]
        end
        return tech.H[id]
    end

    ----------------------------------------------------------------------
    -- Research inputs
    ----------------------------------------------------------------------

    -- The logic nodes a tech's research needs: its prerequisites other than technologies (its packs' set and the labs for it, or its trigger, src/logic/builders/concrete.lua)
    local function research_inputs(tech_name)
        local keys = {}
        local node = graph.nodes[gutils.key("technology", tech_name)]
        for pre, _ in pairs(node ~= nil and node.pre or {}) do
            local start = graph.edges[pre].start
            if graph.nodes[start].type ~= "technology" then
                table.insert(keys, start)
            end
        end
        table.sort(keys)
        return keys
    end
    -- Research nodes the walk makes up (a new pack set, a trigger fitting a room) aren't in the graph or the sort: key --> { summary, sources = list of { key, research edge sources } } for deriving what they need
    local virtual_inputs = {}
    local function input_summary(key)
        local virtual = virtual_inputs[key]
        if virtual ~= nil then
            return virtual.summary
        end
        return summary_of(key)
    end
    -- What a new research node gets from its inputs: in each context, the earliest of them (OR) or the latest (AND), each through a research edge (top.edge_source_contexts gives research home contexts their sources)
    local research_sources_memo = {}
    local function research_edge_sources(context)
        local sources = research_sources_memo[context]
        if sources == nil then
            -- A stand-in edge into a research node: what's read is the stop's type, and an edge with no abilities
            sources = top.edge_source_contexts(sort, {
                start = "",
                stop = gutils.key("technology-trigger", ""),
            }, context)
            research_sources_memo[context] = sources
        end
        return sources
    end
    local function make_research_node(key, op, input_keys)
        -- Each input as the research node sees it: its contexts in rooms pass straight through, and its home contexts come through a research edge
        local per_input = {}
        for _, input_key in pairs(input_keys) do
            local input = summary_of(input_key)
            local inds = nci[input_key] or {}
            local hctx = {}
            for _, home_id in pairs(home_ids) do
                for _, context in pairs(home_contexts[home_id]) do
                    local best
                    for _, source in pairs(research_edge_sources(context)) do
                        best = min_or_other(best, inds[source])
                    end
                    hctx[context] = best
                end
            end
            table.insert(per_input, {
                auto = input.auto,
                iso = input.iso,
                hctx = hctx,
            })
        end
        local summary = {
            auto = {},
            iso = {},
            hctx = {},
            I = {},
            H = {},
        }
        -- AND: the latest input, where every input has the context; OR: the earliest
        for _, field in pairs({ "auto", "iso", "hctx" }) do
            local slots = {}
            for _, input in pairs(per_input) do
                for slot, _ in pairs(input[field]) do
                    slots[slot] = true
                end
            end
            for slot, _ in pairs(slots) do
                local value
                local missing = false
                for _, input in pairs(per_input) do
                    local rank = input[field][slot]
                    if op == "AND" then
                        if rank == nil then
                            missing = true
                        elseif value == nil or rank > value then
                            value = rank
                        end
                    else
                        value = min_or_other(value, rank)
                    end
                end
                if not missing then
                    summary[field][slot] = value
                end
            end
        end
        virtual_inputs[key] = {
            summary = summary,
            op = op,
            input_keys = input_keys,
        }
        return summary
    end

    -- A science pack set's nodes, as src/logic/builders/abstract.lua makes them; made up where the graph doesn't have the set
    local function pack_set_keys(packs)
        local set = {}
        for _, pack in pairs(packs) do
            table.insert(set, pack)
        end
        table.sort(set)
        local set_name = gutils.concat(set)
        local science_key = gutils.key("science-pack-set-science", set_name)
        local lab_key = gutils.key("science-pack-set-lab", set_name)
        if graph.nodes[science_key] == nil and virtual_inputs[science_key] == nil then
            local item_keys = {}
            for _, pack in pairs(set) do
                table.insert(item_keys, gutils.key("item", pack))
            end
            make_research_node(science_key, "AND", item_keys)
            local lab_keys = {}
            for _, lab_name in pairs(sorted_keys(params.labs_taking(set))) do
                table.insert(lab_keys, gutils.key("entity-operate", lab_name))
            end
            make_research_node(lab_key, "OR", lab_keys)
        end
        return {
            science_key,
            lab_key,
        }
    end

    -- A research: { unit or research_trigger (copies), num_unlocks, key (tree_checks.research_key), source, input_keys, packs }
    local research_memo = {}
    local function research_of(tech_name)
        local research = research_memo[tech_name]
        if research ~= nil then
            return research
        end
        local tech = technologies[tech_name]
        research = {
            unit = tech.unit ~= nil and table.deepcopy(tech.unit) or nil,
            research_trigger = tech.research_trigger ~= nil and table.deepcopy(tech.research_trigger) or nil,
            num_unlocks = params.num_recipe_unlocks[tech_name],
            key = params.research_key(tech),
            source = tech_name,
            input_keys = research_inputs(tech_name),
        }
        if tech.unit ~= nil then
            local packs = {}
            for _, ingredient in pairs(tech.unit.ingredients or {}) do
                table.insert(packs, ingredient[1] or ingredient.name)
            end
            research.packs = packs
            -- Research with other packs is wired like this research: through a pack set's nodes (pack_set_keys), or straight from the packs' items where the research takes them so
            local is_input = {}
            for _, input_key in pairs(research.input_keys) do
                is_input[input_key] = true
                if graph.nodes[input_key].type == "science-pack-set-science" then
                    research.pack_sets = true
                end
            end
            local direct = #packs > 0
            for _, pack in pairs(packs) do
                direct = direct and is_input[gutils.key("item", pack)] ~= nil
            end
            research.direct_packs = direct or nil
        end
        research_memo[tech_name] = research
        return research
    end
    local function research_summaries(research)
        local list = {}
        for _, key in pairs(research.input_keys) do
            table.insert(list, input_summary(key))
        end
        return list
    end
    -- The logic nodes research with these packs needs, wired like research's, or nil where research isn't wired either way
    local function inputs_for_packs(research, packs)
        if research.pack_sets == true then
            return pack_set_keys(packs)
        end
        if research.direct_packs == true then
            local keys = {}
            for _, pack in pairs(packs) do
                if graph.nodes[gutils.key("item", pack)] == nil then
                    return nil
                end
                table.insert(keys, gutils.key("item", pack))
            end
            table.sort(keys)
            return keys
        end
        return nil
    end

    ----------------------------------------------------------------------
    -- Derivations: what the timeline went through to reach a pebble
    ----------------------------------------------------------------------

    -- A room's own node, whose context names the room (src/logic/builders/abstract.lua)
    local function is_room(node)
        return type(logic.type_info[node.type].context) == "string"
    end
    local function is_forgetter(node)
        return logic.type_info[node.type].context == true
    end
    -- The earliest pebble of an edge's start that sends context through it, ranked below a rank, or nil
    local sources_memo = {}
    local function sending_rank(edge, context, below)
        local inds = nci[edge.start]
        if inds == nil then
            return nil
        end
        if edge.abilities == nil and (home_of(context) == nil or not logic.type_info[graph.nodes[edge.stop].type].research_input) then
            local rank = inds[context]
            if rank ~= nil and rank < below then
                return rank
            end
            return nil
        end
        local memo_key = tostring(edge.abilities) .. "/" .. context .. "/" .. tostring(logic.type_info[graph.nodes[edge.stop].type].research_input == true)
        local sources = sources_memo[memo_key]
        if sources == nil then
            sources = top.edge_source_contexts(sort, edge, context)
            sources_memo[memo_key] = sources
        end
        local best
        for _, source in pairs(sources) do
            local rank = inds[source]
            if rank ~= nil and rank < below and (best == nil or rank < best) then
                best = rank
            end
        end
        return best
    end
    -- The earliest pebble of a node in any context but home contexts, ranked below a rank, or nil (for forgetters, whose inputs can come from any room)
    local function earliest_below(node_key, below)
        local best
        for context, rank in pairs(nci[node_key] or {}) do
            if rank < below and context < HOME_STRIDE and (best == nil or rank < best) then
                best = rank
            end
        end
        return best
    end

    -- The contexts a forgetter's pebble in a context can have arrived in (node_transmit and home_transmit in context-sort.lua): a home context in its home set's context in any room (forgetters send those to every room having them), an isolatable one in itself (isolatability stays in its room), any other in the same mask in any room (forgetters send that to every room, and a pebble with a stronger mask stands for it)
    local forgetter_sources_memo = {}
    local function forgetter_sources(context)
        local home_id = home_of(context)
        if home_id ~= nil then
            return home_contexts[home_id] or {}
        end
        if is_iso(context) then
            return { context }
        end
        local mask = mask_of(context)
        local sources = forgetter_sources_memo[mask]
        if sources == nil then
            sources = {}
            for _, num in pairs(room_nums) do
                table.insert(sources, num * SLOTS + mask)
            end
            forgetter_sources_memo[mask] = sources
        end
        return sources
    end
    -- A forgetter's inputs on its pebble's derivation: every input's pebble sending one context they all send (AND), or the one input's sending one first (OR), in the earliest context that has them, as the sort only takes what arrives in one context (process_depnode in context-sort.lua)
    -- Each input's own earliest pebble wherever it is would join routes from different rooms that never met, like launching an item made in one room with another room's rocket
    -- Returns nil where no context has them (not expected; the caller then takes each input's earliest)
    local function forgetter_parts(node, context, rank)
        local best_joint
        local best_parts
        for _, source in pairs(forgetter_sources(context)) do
            if node.op == "AND" then
                local joint = -1
                local parts = {}
                for pre, _ in pairs(node.pre) do
                    local input_rank = sending_rank(graph.edges[pre], source, rank)
                    if input_rank == nil then
                        parts = nil
                        break
                    end
                    table.insert(parts, input_rank)
                    if input_rank > joint then
                        joint = input_rank
                    end
                end
                if parts ~= nil and (best_joint == nil or joint < best_joint) then
                    best_joint = joint
                    best_parts = parts
                end
            else
                for pre, _ in pairs(node.pre) do
                    local input_rank = sending_rank(graph.edges[pre], source, rank)
                    if input_rank ~= nil and (best_joint == nil or input_rank < best_joint) then
                        best_joint = input_rank
                        best_parts = { input_rank }
                    end
                end
            end
        end
        return best_parts
    end

    -- A pebble's frontier: the rebuilt recipes, technologies and rooms its derivation went through, stopping at those (a recipe's technology covers what the recipe needs, a technology's prerequisites what's behind it, and getting to a room is its discovery's business)
    -- As a set whose keys are pebble ranks (rebuilt recipes, with their context), "T" .. node key (technologies) and "R" .. room key (rooms)
    -- The derivation takes every input of an AND node and the earliest one of an OR node, each at its earliest pebble sending the context (the earliest-provider rule), so every step goes earlier and it ends; a forgetter's inputs come from one context (forgetter_parts)
    -- Shared by every derivation: a pebble's frontier depends only on earlier pebbles
    local frontier_memo = {}
    local EMPTY = {}
    local rebuilt = params.rebuilt
    local function frontier(rank)
        local found = frontier_memo[rank]
        if found ~= nil then
            return found
        end
        local node_key = pebble_keys[rank]
        local node = graph.nodes[node_key]
        if node.type == "technology" then
            found = {
                ["T" .. node_key] = true,
            }
        elseif is_room(node) then
            found = {
                ["R" .. node.name] = true,
            }
        elseif node.type == "recipe" and rebuilt[node.name] ~= nil then
            found = {
                [rank] = true,
            }
        else
            local context = pebble_contexts[rank]
            local parts = {}
            if is_forgetter(node) then
                local joined = forgetter_parts(node, context, rank)
                if joined ~= nil then
                    parts = joined
                else
                    counts.unjoined = counts.unjoined + 1
                    local best_rank
                    for pre, _ in pairs(node.pre) do
                        local input_rank = earliest_below(graph.edges[pre].start, rank)
                        if node.op == "AND" then
                            if input_rank ~= nil then
                                table.insert(parts, input_rank)
                            end
                        elseif input_rank ~= nil and (best_rank == nil or input_rank < best_rank) then
                            best_rank = input_rank
                        end
                    end
                    if best_rank ~= nil then
                        table.insert(parts, best_rank)
                    end
                end
            elseif node.op == "AND" then
                for pre, _ in pairs(node.pre) do
                    local input_rank = sending_rank(graph.edges[pre], context, rank)
                    if input_rank ~= nil then
                        table.insert(parts, input_rank)
                    end
                end
            else
                local best_rank
                for pre, _ in pairs(node.pre) do
                    local input_rank = sending_rank(graph.edges[pre], context, rank)
                    if input_rank ~= nil and (best_rank == nil or input_rank < best_rank) then
                        best_rank = input_rank
                    end
                end
                if best_rank ~= nil then
                    table.insert(parts, best_rank)
                end
            end
            if timeline.parts ~= nil then
                timeline.parts[rank] = parts
            end
            if #parts == 0 then
                found = EMPTY
            elseif #parts == 1 then
                found = frontier(parts[1])
            else
                found = {}
                for _, part in pairs(parts) do
                    for atom, _ in pairs(frontier(part)) do
                        found[atom] = true
                    end
                end
            end
        end
        frontier_memo[rank] = found
        return found
    end

    ----------------------------------------------------------------------
    -- The recipes and what each must get again
    ----------------------------------------------------------------------

    -- A rebuilt recipe's unlock: the edges into its node that bring the unlock (from its recipe-unlock node, or its technology's straight in where contracted), and the other ways that unlock it (fixed-recipe machines into its recipe-unlock node)
    local unlock_edges_of = {}
    local other_unlocks_of = {}
    for _, recipe_name in pairs(sorted_keys(rebuilt)) do
        local recipe_key = gutils.key("recipe", recipe_name)
        local node = graph.nodes[recipe_key]
        if node ~= nil then
            local edges = {}
            local others = {}
            for pre, _ in pairs(node.pre) do
                local start = graph.nodes[graph.edges[pre].start]
                if start.type == "recipe-unlock" then
                    edges[pre] = true
                    for unlock_pre, _ in pairs(start.pre) do
                        local unlock_start = graph.edges[unlock_pre].start
                        if graph.nodes[unlock_start].type ~= "recipe-tech-unlock" then
                            table.insert(others, unlock_start)
                        end
                    end
                elseif start.type == "technology" then
                    edges[pre] = true
                end
            end
            unlock_edges_of[recipe_name] = edges
            table.sort(others)
            other_unlocks_of[recipe_name] = others
        end
    end

    -- Needs: what a recipe must get in time, one per class of context (class_of) it had: { recipe, kind, id, rank, context }
    -- A context of a class that the recipe gets through another way (a fixed-recipe machine) in time needs nothing from a technology
    local needs = {}
    local needs_of = {}
    local needs_by_key = {}
    for _, recipe_name in pairs(sorted_keys(unlock_edges_of)) do
        local by_class = {}
        for context, rank in pairs(nci[gutils.key("recipe", recipe_name)] or {}) do
            local kind, id = class_of(context)
            local key = class_key(kind, id)
            local need = by_class[key]
            if need == nil or rank < need.rank then
                by_class[key] = {
                    recipe = recipe_name,
                    kind = kind,
                    id = id,
                    key = key,
                    rank = rank,
                    context = context,
                }
            end
        end
        local list = {}
        for _, key in pairs(sorted_keys(by_class)) do
            local need = by_class[key]
            local otherwise = false
            for _, other_key in pairs(other_unlocks_of[recipe_name]) do
                local other = summary_of(other_key)
                local rank
                if need.kind == "p" then
                    rank = other.auto[need.id]
                elseif need.kind == "i" then
                    rank = other.iso[need.id]
                else
                    for _, context in pairs(home_contexts[need.id] or {}) do
                        rank = min_or_other(rank, other.hctx[context])
                    end
                end
                if rank ~= nil and rank < need.rank then
                    otherwise = true
                end
            end
            if otherwise then
                counts.needs_otherwise = counts.needs_otherwise + 1
            else
                table.insert(list, need)
                table.insert(needs, need)
            end
        end
        needs_of[recipe_name] = list
        needs_by_key[recipe_name] = {}
        for _, need in pairs(list) do
            needs_by_key[recipe_name][need.key] = need
        end
        if #list == 0 then
            counts.no_needs = counts.no_needs + 1
        end
    end
    counts.needs = #needs

    -- Whether a recipe is made only in rooms needing discovery: then each of them gets an unlock that waits for nothing its own discovery doesn't need (user's issue 3; the served rule of tree-checks.lua)
    local all_gated = {}
    for recipe_name, _ in pairs(unlock_edges_of) do
        local gated
        for context, _ in pairs(nci[gutils.key("recipe", recipe_name)] or {}) do
            if context < HOME_STRIDE then
                gated = (gated ~= false) and params.discoverers[room_key_of[room_num_of(context)]] ~= nil
            end
        end
        all_gated[recipe_name] = gated == true
    end

    ----------------------------------------------------------------------
    -- Technologies placed so far
    ----------------------------------------------------------------------

    -- Tech handle: { key, summary = { P, I, H }, discoveries = set of names, unit or kept name }
    -- Units are the technologies the walk places; kept techs are handles too once their turn on the walk came
    local units = {}
    local unit_of_key = {}
    local handle_of_key = {}
    -- Recipe name --> the handles unlocking it so far, in the order they came
    local unlocking = {}
    -- Recipe name --> class key --> the handle that gave it that class in time
    local server = {}
    local is_discovery = {}
    for tech_name, _ in pairs(params.discovers) do
        is_discovery[tech_name] = true
    end
    -- Kept tech name --> { prereqs = { keys, reason }, packaged = set of recipe names }, once its turn came
    local kept_in = {}

    local function handle_of(key)
        return handle_of_key[key]
    end
    local function discoveries_of(keys)
        local found = {}
        for _, key in pairs(keys) do
            local handle = handle_of(key)
            if handle ~= nil then
                union_into(found, handle.discoveries)
            end
        end
        return found
    end

    local function new_prereqs()
        return {
            keys = {},
            reason = {},
        }
    end
    local function copy_prereqs(prereqs)
        local copy = new_prereqs()
        for _, key in pairs(prereqs.keys) do
            table.insert(copy.keys, key)
            copy.reason[key] = prereqs.reason[key]
        end
        return copy
    end
    -- The rank of the event the walk is at
    local current_rank
    -- The class of context the need the walk is at must get (class_key), or nil at a kept technology's turn, whose every context can rest on its prerequisites'
    local current_class
    -- A kept technology's first uses (deadlines), by the class of context they rest on: class key --> the earliest rank a need of that class took it as a prerequisite or was served by it, and ANY_CLASS --> the earliest a kept technology took it
    -- The route to its room, added once the room is reached (add_route), must leave each of its contexts before the first use resting on that one
    local ANY_CLASS = "*"
    local function used(handle, rank, class)
        if handle.kept ~= nil and rank ~= nil then
            handle.deadlines = handle.deadlines or {}
            class = class or ANY_CLASS
            if handle.deadlines[class] == nil or rank < handle.deadlines[class] then
                handle.deadlines[class] = rank
            end
        end
    end
    local function add_prereq(prereqs, key, reason)
        if key ~= nil and prereqs.reason[key] == nil and handle_of(key) ~= nil then
            prereqs.reason[key] = reason
            table.insert(prereqs.keys, key)
            used(handle_of(key), current_rank, current_class)
        end
    end
    local function without(prereqs, drop)
        local kept_list = new_prereqs()
        for _, key in pairs(prereqs.keys) do
            if drop[key] == nil then
                table.insert(kept_list.keys, key)
                kept_list.reason[key] = prereqs.reason[key]
            end
        end
        return kept_list
    end
    local function gate_key_of(room)
        local gate = params.gate_of(room)
        if gate == nil then
            return nil
        end
        return gutils.key("technology", gate)
    end

    -- What a frontier needs as prerequisites: the handle that gave each recipe there in time, each technology (kept ones, once in), and each room's discovery
    -- own is the recipe the prerequisites are for, which doesn't need another of its own technologies
    local function add_frontier(prereqs, found, why, own)
        local recipe_ranks = {}
        local tech_keys = {}
        local rooms = {}
        for atom, _ in pairs(found) do
            if type(atom) == "number" then
                table.insert(recipe_ranks, atom)
            elseif string.sub(atom, 1, 1) == "T" then
                table.insert(tech_keys, string.sub(atom, 2))
            else
                table.insert(rooms, string.sub(atom, 2))
            end
        end
        table.sort(recipe_ranks)
        table.sort(tech_keys)
        table.sort(rooms)
        for _, rank in pairs(recipe_ranks) do
            local recipe_name = graph.nodes[pebble_keys[rank]].name
            if recipe_name ~= own then
                local kind, id = class_of(pebble_contexts[rank])
                local handle = (server[recipe_name] or {})[class_key(kind, id)]
                if handle ~= nil then
                    add_prereq(prereqs, handle.key, why .. " needs " .. recipe_name)
                end
            end
        end
        for _, tech_key in pairs(tech_keys) do
            add_prereq(prereqs, tech_key, why .. " needs " .. gutils.deconstruct(tech_key).name)
        end
        for _, room in pairs(rooms) do
            add_prereq(prereqs, gate_key_of(room), why .. " is on " .. room)
        end
    end
    -- The frontier of a recipe's inputs (all but its unlock) in a context, from the pebbles sending it below a rank
    local function inputs_frontier(recipe_name, context, below)
        local node = graph.nodes[gutils.key("recipe", recipe_name)]
        local found = {}
        for pre, _ in pairs(node.pre) do
            if unlock_edges_of[recipe_name][pre] == nil then
                local rank = sending_rank(graph.edges[pre], context, below)
                if rank ~= nil then
                    union_into(found, frontier(rank))
                end
            end
        end
        return found
    end
    -- The discoveries a recipe's other inputs in a room needed on the timeline: those its prerequisites from them bring (the served rule allows these, user: recipes "depend on all the unlocks they need")
    local inherent_memo = {}
    local function inherent(need)
        local memo_key = need.recipe .. "\n" .. need.key
        local found = inherent_memo[memo_key]
        if found == nil then
            local prereqs = new_prereqs()
            add_frontier(prereqs, inputs_frontier(need.recipe, need.context, need.rank), "the recipe", need.recipe)
            found = discoveries_of(prereqs.keys)
            inherent_memo[memo_key] = found
        end
        return found
    end
    -- Room key --> the discoveries a room's own technology may wait for: its discovery and what that needs
    local function room_allowed(room)
        local allowed = {}
        local gate_key = gate_key_of(room)
        local handle = gate_key ~= nil and handle_of(gate_key) or nil
        if handle ~= nil then
            union_into(allowed, handle.discoveries)
        end
        local gate = params.gate_of(room)
        if gate ~= nil then
            allowed[gate] = true
        end
        return allowed
    end
    -- What the served rule lets a technology for a need wait for, or nil where it doesn't apply (a recipe made somewhere needing no discovery, a home context)
    local function allowed_for(need)
        if need.kind == "h" or not all_gated[need.recipe] then
            return nil
        end
        local room = room_key_of[need.id]
        if params.discoverers[room] == nil then
            return nil
        end
        local allowed = room_allowed(room)
        union_into(allowed, inherent(need))
        return allowed
    end

    ----------------------------------------------------------------------
    -- Research for a need
    ----------------------------------------------------------------------

    -- A research input's pebbles giving a context, and when it has it: its own pebble there, or for one the walk made up, the pebbles of its inputs it has the context from as make_research_node times it (every input's for AND, the earliest one's for OR); nil where it doesn't have it
    local function input_pebbles(key, context)
        local virtual = virtual_inputs[key]
        if virtual == nil then
            local rank = (nci[key] or {})[context]
            if rank == nil then
                return nil
            end
            return { rank }, rank
        end
        local is_home = home_of(context) ~= nil
        local ranks = {}
        local joint
        for _, input_key in pairs(virtual.input_keys) do
            local inds = nci[input_key] or {}
            local rank
            if is_home then
                for _, source in pairs(research_edge_sources(context)) do
                    rank = min_or_other(rank, inds[source])
                end
            else
                rank = inds[context]
            end
            if virtual.op == "AND" then
                if rank == nil then
                    return nil
                end
                table.insert(ranks, rank)
                if joint == nil or rank > joint then
                    joint = rank
                end
            elseif rank ~= nil and (joint == nil or rank < joint) then
                joint = rank
                ranks = { rank }
            end
        end
        if joint == nil then
            return nil
        end
        return ranks, joint
    end
    -- A research's derivation: its inputs' pebbles in the earliest of these contexts that they all have, since a technology is a forgetter, researched in one context all its research inputs share (see forgetter_parts); nil where none has them all
    local function research_route(input_keys, contexts)
        local best_joint
        local best_ranks
        for _, context in pairs(contexts) do
            local ranks = {}
            local joint = -1
            for _, input_key in pairs(input_keys) do
                local input_ranks, input_joint = input_pebbles(input_key, context)
                if input_ranks == nil then
                    ranks = nil
                    break
                end
                for _, rank in pairs(input_ranks) do
                    table.insert(ranks, rank)
                end
                if input_joint > joint then
                    joint = input_joint
                end
            end
            if ranks ~= nil and (best_joint == nil or joint < best_joint) then
                best_joint = joint
                best_ranks = ranks
            end
        end
        return best_ranks, best_joint
    end
    -- Each room's context without abilities: where research without isolatability can be done (evaluate)
    local plain_contexts = {}
    for _, num in pairs(room_nums) do
        table.insert(plain_contexts, num * SLOTS)
    end
    -- Where no context has every research input (not expected): each input's earliest pebble anywhere, and of an input the walk made up, those of every input for AND and the earliest one's for OR
    local function unjoined_research(input_keys)
        counts.unjoined = counts.unjoined + 1
        local ranks = {}
        local function add(rank)
            if rank ~= nil then
                table.insert(ranks, rank)
            end
        end
        for _, input_key in pairs(input_keys) do
            local virtual = virtual_inputs[input_key]
            if virtual == nil then
                add(earliest_below(input_key, math.huge))
            elseif virtual.op == "AND" then
                for _, key in pairs(virtual.input_keys) do
                    add(earliest_below(key, math.huge))
                end
            else
                local best
                for _, key in pairs(virtual.input_keys) do
                    best = min_or_other(best, earliest_below(key, math.huge))
                end
                add(best)
            end
        end
        return ranks
    end
    -- The pebbles a research's inputs give a need from, all in one context (research_route): the need's own where they're all had there before it, else for an isolatable need its room's home set's home contexts (the discovery rule) and for a home context its home set's, else the room where the research comes first
    -- A route that comes after the need would bring only what the walk hasn't placed yet, and so no prerequisites for what the research needs
    local function research_pebbles(research, need)
        local ranks, joint = research_route(research.input_keys, { need.context })
        if ranks ~= nil and joint < need.rank then
            return ranks
        end
        local home_id = need.kind == "h" and need.id or (need.kind == "i" and home_id_of_room[need.id] or nil)
        if home_id ~= nil then
            local by_home = research_route(research.input_keys, home_contexts[home_id] or {})
            if by_home ~= nil then
                return by_home
            end
        end
        return research_route(research.input_keys, plain_contexts) or ranks or unjoined_research(research.input_keys)
    end
    local function add_research_needs(prereqs, research, need)
        local found = {}
        for _, rank in pairs(research_pebbles(research, need)) do
            union_into(found, frontier(rank))
        end
        add_frontier(prereqs, found, "its research", need.recipe)
        for _, gate in pairs(sorted_keys(params.input_gates[research.source or ""])) do
            add_prereq(prereqs, gutils.key("technology", gate), "its research comes after " .. gate)
        end
    end

    -- A research with packs that also takes the packs of the discoveries it comes after, where some lab takes them all ("Also consume later science", user 2026-10-12), or nil if it takes them already or none can
    local function with_later_science(research, prereq_keys)
        if research.unit == nil or (research.pack_sets ~= true and research.direct_packs ~= true) then
            return nil
        end
        local has = {}
        for _, pack in pairs(research.packs) do
            has[pack] = true
        end
        local added = {}
        for _, discovery in pairs(sorted_keys(discoveries_of(prereq_keys))) do
            for _, ingredient in pairs((technologies[discovery].unit or {}).ingredients or {}) do
                local pack = ingredient[1] or ingredient.name
                if has[pack] == nil then
                    has[pack] = true
                    table.insert(added, pack)
                end
            end
        end
        if #added == 0 then
            return nil
        end
        local all = sorted_keys(has)
        if next(params.labs_taking(all)) == nil then
            return nil
        end
        local input_keys = inputs_for_packs(research, all)
        if input_keys == nil then
            return nil
        end
        local later = {}
        for field, value in pairs(research) do
            later[field] = value
        end
        later.packs = all
        later.added_packs = added
        later.input_keys = input_keys
        return later
    end

    -- Research with packs fitting a room: the packs of the room's discovery, with the copied research's count and time, where some lab takes them all
    local function packs_to_fit(room, research)
        if research.unit == nil or (research.pack_sets ~= true and research.direct_packs ~= true) then
            return nil
        end
        local gate = params.gate_of(room)
        local gate_tech = gate ~= nil and technologies[gate] or nil
        if gate_tech == nil or gate_tech.unit == nil then
            return nil
        end
        local packs = {}
        local listed = {}
        for _, ingredient in pairs(gate_tech.unit.ingredients or {}) do
            local pack = ingredient[1] or ingredient.name
            if listed[pack] == nil then
                listed[pack] = true
                table.insert(packs, pack)
            end
        end
        table.sort(packs)
        if #packs == 0 or next(params.labs_taking(packs)) == nil then
            return nil
        end
        local input_keys = inputs_for_packs(research, packs)
        if input_keys == nil then
            return nil
        end
        local fitted = {}
        for field, value in pairs(research) do
            fitted[field] = value
        end
        fitted.unit = table.deepcopy(research.unit)
        fitted.unit.ingredients = {}
        for _, pack in pairs(packs) do
            table.insert(fitted.unit.ingredients, {
                pack,
                1,
            })
        end
        fitted.packs = packs
        fitted.added_packs = nil
        fitted.input_keys = input_keys
        fitted.key = params.research_key({
            unit = fitted.unit,
        })
        fitted.fitted = true
        fitted.fitted_packs = true
        return fitted
    end

    -- How a craft-item trigger is wired in this logic: the node type a trigger node takes the crafted item from, read off a tech the game researches by crafting an item (src/logic/builders/concrete.lua gives item-craft)
    local craft_trigger_type
    for _, tech_name in pairs(sorted_keys(technologies)) do
        local trigger = technologies[tech_name].research_trigger
        local trigger_node = graph.nodes[gutils.key("technology-trigger", tech_name)]
        if trigger ~= nil and trigger.type == "craft-item" and trigger_node ~= nil then
            local pre = next(trigger_node.pre)
            if pre ~= nil then
                craft_trigger_type = graph.nodes[graph.edges[pre].start].type
                break
            end
        end
    end
    if craft_trigger_type == nil then
        craft_trigger_type = "item"
        for _, node in pairs(graph.nodes) do
            if node.type == "item-craft" then
                craft_trigger_type = "item-craft"
                break
            end
        end
    end
    -- A trigger a need's room meets, for research that has to fit the room: crafting one of the recipe's items there (from the room's own resources, for an isolatable need) before the need's rank
    -- The one made last there goes first, since it's the closest to what made the trigger necessary
    local num_fitted_triggers = 0
    local function trigger_to_fit(need)
        if need.kind == "h" then
            return nil
        end
        local best
        local best_rank
        local item_names = {}
        for pre, _ in pairs(graph.nodes[gutils.key("recipe", need.recipe)].pre) do
            local start = graph.nodes[graph.edges[pre].start]
            if start.type == "item" then
                table.insert(item_names, start.name)
            end
        end
        table.sort(item_names)
        for _, item_name in pairs(item_names) do
            local craft_key = gutils.key(craft_trigger_type, item_name)
            if graph.nodes[craft_key] ~= nil then
                local summary = summary_of(craft_key)
                local rank = need.kind == "i" and summary.iso[need.id] or summary.auto[need.id]
                if rank ~= nil and rank < need.rank and (best_rank == nil or rank > best_rank) then
                    best = item_name
                    best_rank = rank
                end
            end
        end
        if best == nil then
            return nil
        end
        num_fitted_triggers = num_fitted_triggers + 1
        local trigger_key = gutils.key("technology-trigger", UNIT_PREFIX .. "trigger-" .. num_fitted_triggers)
        make_research_node(trigger_key, "OR", {
            gutils.key(craft_trigger_type, best),
        })
        local research_trigger = {
            type = "craft-item",
            item = best,
        }
        return {
            research_trigger = research_trigger,
            num_unlocks = 1,
            key = params.research_key({
                research_trigger = research_trigger,
            }),
            input_keys = {
                trigger_key,
            },
            fitted = true,
        }
    end

    ----------------------------------------------------------------------
    -- Placing a technology for a need
    ----------------------------------------------------------------------

    local function prereq_summaries(keys)
        local list = {}
        for _, key in pairs(keys) do
            table.insert(list, handle_of(key).summary)
        end
        return list
    end
    -- Whether a handle gives a need in time
    local function in_time(summary, need)
        local rank = anchor(summary, need.kind, need.id)
        return rank ~= nil and rank < need.rank
    end
    -- Whether a handle gives an isolatable need late but still keeps it: through the discovery rule, with the recipe had in time in the room without isolatability
    -- Isolatable pebbles of a room coming later can't hold back what the rule waits for: the room's discovery, the technology without isolatability (the recipe's own such pebble comes in time), and its home set's home context (a room isn't in its own home set, and a pebble in a home context needs only that set's rooms)
    -- Nor anything else outside the room's isolatable contexts but research home contexts of home sets holding the room, which only lead to rooms later in discovery order the same way
    -- So everything the timeline had is still reached, the room's isolatable pebbles after what the rule waits for (the final check sorts the game again anyway)
    local function late_ok(summary, need)
        if need.kind ~= "i" or summary.IR == nil or summary.IR[need.id] == nil then
            return false
        end
        local plain = (needs_by_key[need.recipe] or {})["p" .. need.id]
        return plain == nil or (server[need.recipe] or {})[plain.key] ~= nil
    end
    -- A candidate technology's timing and discoveries
    local function try(research, prereqs)
        local summary = evaluate(prereq_summaries(prereqs.keys), research_summaries(research))
        return summary, discoveries_of(prereqs.keys)
    end

    local function new_unit(need, research, prereqs, summary, discoveries)
        local id = #units + 1
        local key = gutils.key("technology", UNIT_PREFIX .. id)
        local unit = {
            id = id,
            key = key,
            recipe = need.recipe,
            room = room_key_of[need.id] or "",
            context = need.context,
            research = research,
            prereqs = prereqs,
        }
        table.insert(units, unit)
        unit_of_key[key] = unit
        local handle = {
            key = key,
            summary = summary,
            discoveries = discoveries,
            unit = unit,
        }
        handle_of_key[key] = handle
        unlocking[need.recipe] = unlocking[need.recipe] or {}
        table.insert(unlocking[need.recipe], handle)
        counts.units = counts.units + 1
        return handle
    end

    -- The old unlockers whose research could give a need in time (they gave it on the timeline), in the order the tree prefers them (the game as it was, by_rank in tree.lua)
    -- Which of them the timeline reached first can depend on the order the sort takes ties in, as with a technology whose prerequisite the rebuild took away
    -- For a recipe made only on planets needing discovery, an unlocker that came after the need's planet's discovery (the planet's own technology) goes first (the old rebuild's "recipes only one planet makes take their research from that planet's technology")
    -- The technology unified randomization gave the recipe itself (named as its rebuilt technology, src/randomizations/unified/handlers/tech-triggers.lua) goes first of all: its research is the one unified randomized and promised for the recipe (UNIFIED_TRIGGER_TAKERS)
    local function research_candidates(need)
        local candidates = {}
        local own_tech = params.own_tech_of ~= nil and params.own_tech_of(need.recipe) or nil
        local room = need.kind ~= "h" and room_key_of[need.id] or nil
        local discoverers = all_gated[need.recipe] and room ~= nil and params.discoverers[room] or nil
        for position, source in pairs(params.unlockers[need.recipe] or {}) do
            local rank = anchor(summary_of(gutils.key("technology", source)), need.kind, need.id)
            if rank ~= nil and rank < need.rank then
                local own = false
                for gate, _ in pairs(discoverers ~= nil and params.input_gates[source] or {}) do
                    own = own or discoverers[gate] ~= nil
                end
                table.insert(candidates, {
                    research = research_of(source),
                    rank = rank,
                    position = position,
                    own = own,
                    unified = source == own_tech,
                })
            end
        end
        table.sort(candidates, function(a, b)
            if a.unified ~= b.unified then
                return a.unified
            end
            if a.own ~= b.own then
                return a.own
            end
            return a.position < b.position
        end)
        return candidates
    end

    -- Places a technology for a need nothing gives in time: the first of these that gives it in time and, where the served rule applies, waits for nothing it allows not:
    --   1. the copied research taking later science, then without it (unless the plan has to fit the room), then the other unlockers' research
    --   2. research fitting the room: its discovery's packs (with later science first), then a trigger it meets
    --   3. failing the served rule, the first of those in time (logged)
    --   4. for an isolatable need, the copied research without the prerequisites having neither the room's isolatability nor its home set's context
    --   5. the copied research with only what it needs itself, which the timeline had in time
    local function place(need)
        local recipe_name = need.recipe
        local candidates = research_candidates(need)
        if #candidates == 0 then
            -- Nothing unlocked it in time on the timeline: it isn't a need a technology gave (shouldn't happen, logged)
            counts.given_up = counts.given_up + 1
            if #given_up < 20 then
                table.insert(given_up, recipe_name .. " @ " .. top.context_name(need.context) .. " (no unlocker in time)")
            end
            return nil
        end
        local room = room_key_of[need.id]
        local allowed = allowed_for(need)
        local recipe_prereqs = new_prereqs()
        if need.kind ~= "h" and room ~= nil then
            add_prereq(recipe_prereqs, gate_key_of(room), "made on " .. room)
        end
        add_frontier(recipe_prereqs, inputs_frontier(recipe_name, need.context, need.rank), "the recipe", recipe_name)
        local recipe_discoveries = discoveries_of(recipe_prereqs.keys)

        local chosen
        local fallback
        -- Isolatable needs the discovery rule gives late (late_ok), with and without the served rule
        local late_chosen
        local late_fallback
        -- The recipe's need from its room's own resources, which comes later on the timeline: the technology given this need gives that one too where some research can (user, 2026-10-13: "Change its research to fit"), rather than a second technology for it with research that fits
        -- single is the first choice that gives only this need, taken if nothing gives both
        local own_need = need.kind == "p" and (needs_by_key[recipe_name] or {})["i" .. need.id] or nil
        if own_need ~= nil and (server[recipe_name] or {})[own_need.key] ~= nil then
            own_need = nil
        end
        local own_allowed = own_need ~= nil and allowed_for(own_need) or nil
        local single
        local stage = "copied"
        local function consider(research, prereqs, on_choose)
            if chosen ~= nil then
                return
            end
            local summary, discoveries = try(research, prereqs)
            local late = false
            if not in_time(summary, need) then
                if not late_ok(summary, need) then
                    return
                end
                late = true
            end
            local entry = {
                research = research,
                prereqs = prereqs,
                summary = summary,
                discoveries = discoveries,
                on_choose = on_choose,
                stage = stage,
            }
            local fits = allowed == nil or subset(discoveries, allowed)
            if late then
                entry.stage = "late " .. stage
                if fits and late_chosen == nil then
                    late_chosen = entry
                elseif not fits and late_fallback == nil then
                    late_fallback = entry
                end
            elseif fits then
                local gives_own = own_need == nil or ((in_time(summary, own_need) or late_ok(summary, own_need)) and (own_allowed == nil or subset(discoveries, own_allowed)))
                if gives_own then
                    chosen = entry
                elseif single == nil then
                    single = entry
                end
            elseif fallback == nil then
                fallback = entry
            end
        end
        local function with_research(research)
            local prereqs = copy_prereqs(recipe_prereqs)
            add_research_needs(prereqs, research, need)
            return prereqs
        end

        local first = candidates[1].research
        local first_prereqs = with_research(first)
        local function try_copied()
            stage = "copied"
            local later = with_later_science(first, first_prereqs.keys)
            if later ~= nil then
                consider(later, first_prereqs, function()
                    counts.later_science = counts.later_science + 1
                end)
            end
            consider(first, first_prereqs)
            for i = 2, #candidates do
                consider(candidates[i].research, with_research(candidates[i].research))
            end
        end
        -- Research waiting for discoveries the recipe doesn't need where the served rule applies has to fit the room; the copied research is then only what's kept if nothing fits
        local fit = allowed ~= nil and not subset(discoveries_of(first_prereqs.keys), allowed)
        if not fit then
            try_copied()
        end
        stage = "fitted packs"
        if chosen == nil and room ~= nil then
            local fitted = packs_to_fit(room, first)
            if fitted ~= nil then
                local fitted_prereqs = with_research(fitted)
                local later = with_later_science(fitted, fitted_prereqs.keys)
                if later ~= nil then
                    later.fitted = true
                    later.fitted_packs = true
                    consider(later, fitted_prereqs, function()
                        counts.changed_to_packs = counts.changed_to_packs + 1
                        counts.later_science = counts.later_science + 1
                    end)
                end
                consider(fitted, fitted_prereqs, function()
                    counts.changed_to_packs = counts.changed_to_packs + 1
                end)
            end
        end
        stage = "fitted trigger"
        if chosen == nil then
            local fitted = trigger_to_fit(need)
            if fitted ~= nil then
                consider(fitted, with_research(fitted), function()
                    counts.changed_research = counts.changed_research + 1
                end)
            end
        end
        if chosen == nil and fit then
            try_copied()
        end
        if chosen == nil and single ~= nil then
            chosen = single
        elseif chosen ~= nil and own_need ~= nil and chosen.stage ~= "copied" then
            counts.fitted_for_own = (counts.fitted_for_own or 0) + 1
        end
        if chosen == nil and late_chosen ~= nil then
            chosen = late_chosen
            counts.late_isolatable = (counts.late_isolatable or 0) + 1
        end
        if chosen == nil and fallback ~= nil then
            chosen = fallback
            chosen.stage = "fallback (" .. chosen.stage .. ")"
            counts.served_missed = counts.served_missed + 1
        end
        if chosen == nil and late_fallback ~= nil then
            chosen = late_fallback
            chosen.stage = "fallback (" .. chosen.stage .. ")"
            counts.served_missed = counts.served_missed + 1
            counts.late_isolatable = (counts.late_isolatable or 0) + 1
        end
        if chosen == nil and need.kind == "i" then
            local home_id = home_id_of_room[need.id]
            local drop = {}
            local num_drop = 0
            for _, key in pairs(first_prereqs.keys) do
                local handle = handle_of(key)
                local is_gate = is_discovery[gutils.deconstruct(key).name] == true
                if not is_gate and handle.summary.I[need.id] == nil and (home_id == nil or handle.summary.H[home_id] == nil) then
                    drop[key] = true
                    num_drop = num_drop + 1
                end
            end
            if num_drop > 0 then
                local fewer = without(first_prereqs, drop)
                local summary, discoveries = try(first, fewer)
                if in_time(summary, need) then
                    chosen = {
                        research = first,
                        prereqs = fewer,
                        summary = summary,
                        discoveries = discoveries,
                        stage = "dropped",
                    }
                    counts.left_out = counts.left_out + num_drop
                end
            end
        end
        if chosen == nil then
            -- The research the timeline had in time, with only its own gates (in time by construction), and the room's discovery where that's in time too
            local minimal = new_prereqs()
            for _, gate in pairs(sorted_keys(params.input_gates[first.source or ""])) do
                add_prereq(minimal, gutils.key("technology", gate), "its research comes after " .. gate)
            end
            local summary, discoveries = try(first, minimal)
            if need.kind ~= "h" and room ~= nil and gate_key_of(room) ~= nil and handle_of(gate_key_of(room)) ~= nil then
                local with_gate = copy_prereqs(minimal)
                add_prereq(with_gate, gate_key_of(room), "made on " .. room)
                local gated_summary, gated_discoveries = try(first, with_gate)
                if in_time(gated_summary, need) then
                    minimal = with_gate
                    summary = gated_summary
                    discoveries = gated_discoveries
                end
            end
            counts.left_out = counts.left_out + #first_prereqs.keys - #minimal.keys
            chosen = {
                research = first,
                prereqs = minimal,
                summary = summary,
                discoveries = discoveries,
                stage = "minimal",
            }
            if not in_time(summary, need) then
                counts.given_up = counts.given_up + 1
                if #given_up < 20 then
                    table.insert(given_up, recipe_name .. " @ " .. top.context_name(need.context))
                end
            end
        end
        if chosen.on_choose ~= nil then
            chosen.on_choose()
        end
        local stage_key = "placed " .. need.kind .. " " .. chosen.stage
        counts.stages = counts.stages or {}
        counts.stages[stage_key] = (counts.stages[stage_key] or 0) + 1
        if timeline.trace ~= nil then
            timeline.trace(need, chosen, first_prereqs, recipe_prereqs, {
                handle_of = handle_of,
                anchor = anchor,
                research = research_summaries(first),
                evaluate = evaluate,
                prereq_summaries = prereq_summaries,
                first = first,
            })
        end
        return new_unit(need, chosen.research, chosen.prereqs, chosen.summary, chosen.discoveries)
    end

    ----------------------------------------------------------------------
    -- Kept technologies
    ----------------------------------------------------------------------

    -- A starting recipe whose only unlocker is its room's discovery waits for it everywhere, as on the timeline (user, 2026-10-12: "collapsed to the discovery tech")
    local will_bring = {}
    for _, tech_name in pairs(sorted_keys(params.kept)) do
        for _, room in pairs(params.discovers[tech_name] or {}) do
            for recipe_name, _ in pairs(params.starting[room] or {}) do
                local list = params.unlockers[recipe_name] or {}
                if #list == 1 and list[1] == tech_name and will_bring[recipe_name] == nil then
                    will_bring[recipe_name] = tech_name
                end
            end
        end
    end
    -- Recipe name --> set of the kept techs bringing it
    local packaged_into = {}

    -- The route to a room on the timeline: the frontier of the room's first pebble, through the room's own node (its discovery's own part aside)
    local function route_frontier(room)
        local room_key = gutils.key("room", room)
        local node = graph.nodes[room_key]
        local first
        for context, rank in pairs(nci[room_key] or {}) do
            if context < HOME_STRIDE and (first == nil or rank < first) then
                first = rank
            end
        end
        local found = {}
        if node == nil or first == nil then
            return found
        end
        -- A room's node takes any one of its ways in (an OR node): the earliest
        local best
        for pre, _ in pairs(node.pre) do
            local rank = earliest_below(graph.edges[pre].start, first)
            if rank ~= nil and (best == nil or rank < best) then
                best = rank
            end
        end
        if best ~= nil then
            union_into(found, frontier(best))
        end
        return found
    end

    local function add_kept(tech_name)
        local tech_key = gutils.key("technology", tech_name)
        local summary = summary_of(tech_key)
        local research = {
            input_keys = research_inputs(tech_name),
            source = tech_name,
        }
        local prereqs = new_prereqs()
        local first_rank = summary.P
        -- What its research needs: its inputs' pebbles in the room its research comes first in, as its timing without isolatability goes (research_route)
        local research_found = {}
        for _, rank in pairs(research_route(research.input_keys, plain_contexts) or unjoined_research(research.input_keys)) do
            union_into(research_found, frontier(rank))
        end
        research_found["T" .. tech_key] = nil
        add_frontier(prereqs, research_found, "its research")
        for _, gate in pairs(sorted_keys(params.input_gates[tech_name])) do
            if gate ~= tech_name then
                add_prereq(prereqs, gutils.key("technology", gate), "it came after " .. gate)
            end
        end
        local packaged = {}
        -- The recipes it brings that it unlocked in the game before (the rest are starting recipes it brings)
        local own_packaged = {}
        -- Prerequisite key --> the starting recipes it would bring before the discovery: one left out to keep the discovery's timing (it would make the discovery wait for another planet's, say) comes with the discovery instead
        local starting_of_key = {}
        for _, room in pairs(params.discovers[tech_name] or {}) do
            -- The route to the room comes once the room is reached (add_route): its technologies can come later on the timeline than the discovery's research (user's issue 6, 2026-10-12)
            -- Starting recipes: one a technology already gives the room's home set comes before the discovery; the rest it brings, unless the room meets their trigger itself
            local home_id = (home_sets.of or {})[room]
            for _, recipe_name in pairs(sorted_keys(params.starting[room])) do
                if unlock_edges_of[recipe_name] ~= nil then
                    local before
                    for _, handle in pairs(unlocking[recipe_name] or {}) do
                        if before == nil and handle.unit ~= nil and home_id ~= nil and handle.summary.H[home_id] ~= nil then
                            before = handle
                        end
                    end
                    local own = false
                    for _, unlocker in pairs(params.unlockers[recipe_name] or {}) do
                        own = own or unlocker == tech_name
                    end
                    if own then
                        packaged[recipe_name] = true
                        own_packaged[recipe_name] = true
                        counts.packaged_own = counts.packaged_own + 1
                    elseif before ~= nil and not subset(before.discoveries, discoveries_of(prereqs.keys)) then
                        -- Its technology would make the discovery wait for another planet's discovery (like one first made on that planet): the recipe comes with the discovery instead, and the technology stays for where it is
                        packaged[recipe_name] = true
                        counts.packaged_start = counts.packaged_start + 1
                    elseif before ~= nil then
                        if prereqs.reason[before.key] == nil then
                            add_prereq(prereqs, before.key, "a starting recipe of " .. room)
                            counts.starting_prerequisites = counts.starting_prerequisites + 1
                            starting_of_key[before.key] = starting_of_key[before.key] or {}
                            table.insert(starting_of_key[before.key], recipe_name)
                        end
                    else
                        local first = (params.unlockers[recipe_name] or {})[1]
                        local by_packs = first ~= nil and technologies[first].unit ~= nil
                        if by_packs or params.starting_trigger[room .. "\n" .. recipe_name] == nil then
                            packaged[recipe_name] = true
                            counts.packaged_start = counts.packaged_start + 1
                        end
                    end
                end
            end
        end
        -- Every prerequisite has to come before what the tech had on the timeline, in each context: one that would make it later anywhere is left out
        local own_research = research_summaries(research)
        -- The contexts to keep: those its research alone gives it before its pebble there (all of them, unless the evaluation misses a way the sort found)
        local gate_keys = {}
        for _, gate in pairs(sorted_keys(params.input_gates[tech_name])) do
            if gate ~= tech_name and handle_of(gutils.key("technology", gate)) ~= nil then
                table.insert(gate_keys, gutils.key("technology", gate))
            end
        end
        local base = evaluate(prereq_summaries(gate_keys), own_research)
        local function before(result_rank, rank)
            return result_rank ~= nil and result_rank < rank
        end
        local function keeps_timing(keys)
            local result = evaluate(prereq_summaries(keys), own_research)
            if summary.P ~= nil and before(base.P, summary.P) and not before(result.P, summary.P) then
                return false
            end
            for num, rank in pairs(summary.I) do
                if before(base.I[num], rank) and not before(result.I[num], rank) then
                    return false
                end
            end
            for home_id, rank in pairs(summary.H) do
                if before(base.H[home_id], rank) and not before(result.H[home_id], rank) then
                    return false
                end
            end
            return true
        end
        local chosen = new_prereqs()
        for _, key in pairs(prereqs.keys) do
            table.insert(chosen.keys, key)
            if keeps_timing(chosen.keys) then
                chosen.reason[key] = prereqs.reason[key]
            else
                table.remove(chosen.keys)
                counts.route_left_out = counts.route_left_out + 1
                for _, recipe_name in pairs(starting_of_key[key] or {}) do
                    packaged[recipe_name] = true
                    counts.packaged_start = counts.packaged_start + 1
                    counts.starting_prerequisites = counts.starting_prerequisites - 1
                end
            end
        end
        -- A starting recipe a discovery it needs brings already isn't brought again (it would be an unlock another one makes pointless)
        local discoveries = discoveries_of(chosen.keys)
        for _, recipe_name in pairs(sorted_keys(packaged)) do
            for discovery, _ in pairs(packaged_into[recipe_name] or {}) do
                if discoveries[discovery] ~= nil then
                    packaged[recipe_name] = nil
                end
            end
        end
        if is_discovery[tech_name] then
            discoveries[tech_name] = true
        end
        -- Its timing as evaluate works it out from what it now takes, where that's earlier than the sort's: the sort makes technologies isolatable in a room one at a time once the room is discovered, a discovery among the last, while the discovery rule frees them all at once (user's issue with starting recipes getting technologies of their own)
        local final = evaluate(prereq_summaries(chosen.keys), own_research)
        local timing = {
            P = min_or_other(final.P, summary.P),
            I = {},
            H = {},
            IR = final.IR,
        }
        for _, num in pairs(room_nums) do
            timing.I[num] = min_or_other(final.I[num], summary.I[num])
        end
        for _, home_id in pairs(home_ids) do
            timing.H[home_id] = min_or_other(final.H[home_id], summary.H[home_id])
        end
        local handle = {
            key = tech_key,
            summary = timing,
            discoveries = discoveries,
            kept = tech_name,
        }
        handle_of_key[tech_key] = handle
        for recipe_name, _ in pairs(packaged) do
            packaged_into[recipe_name] = packaged_into[recipe_name] or {}
            packaged_into[recipe_name][tech_name] = true
            unlocking[recipe_name] = unlocking[recipe_name] or {}
            table.insert(unlocking[recipe_name], handle)
        end
        kept_in[tech_name] = {
            prereqs = chosen,
            packaged = packaged,
            own_packaged = own_packaged,
            own_research = own_research,
        }
    end

    -- The route to a room its kept discovery came before: once the room is reached, the technologies on the way there become the discovery's prerequisites (user's issue 6, 2026-10-12: the route to a planet, like thrusters, is its discovery's prerequisite, not every recipe's made there)
    -- Each is taken only while the discovery still comes before its first use (the deadline), before the room, and keeps every context it had: the room's own recipes come after the room, so they take it as it is then
    local function add_route(tech_name, room, route_rank)
        local tech_key = gutils.key("technology", tech_name)
        local handle = handle_of(tech_key)
        local info = kept_in[tech_name]
        if handle == nil or info == nil then
            -- The room was reached before its discovery's turn: the route isn't the discovery's to bring
            return
        end
        local found = route_frontier(room)
        found["T" .. tech_key] = nil
        found["R" .. room] = nil
        local candidates = new_prereqs()
        add_frontier(candidates, found, "the route to " .. room)
        -- When each context may come at the latest: before the first use resting on it (evaluate: a need without isolatability rests on P, an isolatable one on I in its room or on P and its room's home set's H through the discovery rule, a home context on H), and P before the room too (the room's first pebble needs the discovery)
        local deadlines = handle.deadlines or {}
        local any = deadlines[ANY_CLASS] or math.huge
        local p_deadline = math.min(route_rank, any)
        local i_deadlines = {}
        local h_deadlines = {}
        for class, rank in pairs(deadlines) do
            local kind = string.sub(class, 1, 1)
            local id = tonumber(string.sub(class, 2))
            if (kind == "p" or kind == "i") and rank < p_deadline then
                p_deadline = rank
            end
            if kind == "i" then
                i_deadlines[id] = math.min(i_deadlines[id] or math.huge, rank)
                local home_id = home_id_of_room[id]
                if home_id ~= nil then
                    h_deadlines[home_id] = math.min(h_deadlines[home_id] or math.huge, rank)
                end
            elseif kind == "h" then
                h_deadlines[id] = math.min(h_deadlines[id] or math.huge, rank)
            end
        end
        local function i_deadline(num)
            return math.min(any, i_deadlines[num] or math.huge)
        end
        local function h_deadline(home_id)
            return math.min(any, h_deadlines[home_id] or math.huge)
        end
        local keys = {}
        for _, key in pairs(info.prereqs.keys) do
            table.insert(keys, key)
        end
        local result
        local num_added = 0
        for _, key in pairs(candidates.keys) do
            if info.prereqs.reason[key] == nil and key ~= tech_key then
                table.insert(keys, key)
                local trial = evaluate(prereq_summaries(keys), info.own_research)
                local ok = trial.P ~= nil and trial.P < p_deadline
                for num, _ in pairs(handle.summary.I) do
                    ok = ok and trial.I[num] ~= nil and trial.I[num] < i_deadline(num)
                end
                for home_id, _ in pairs(handle.summary.H) do
                    ok = ok and trial.H[home_id] ~= nil and trial.H[home_id] < h_deadline(home_id)
                end
                if ok then
                    info.prereqs.reason[key] = candidates.reason[key]
                    result = trial
                    num_added = num_added + 1
                else
                    table.remove(keys)
                    counts.route_left_out = counts.route_left_out + 1
                    if timeline.route_refusals ~= nil then
                        local why = {}
                        if trial.P == nil or trial.P >= p_deadline then
                            table.insert(why, "P " .. tostring(trial.P) .. " vs " .. tostring(p_deadline) .. (p_deadline < route_rank and " (used)" or " (the room)"))
                        end
                        for num, _ in pairs(handle.summary.I) do
                            if trial.I[num] == nil then
                                table.insert(why, "loses I " .. room_key_of[num])
                            elseif trial.I[num] >= i_deadline(num) then
                                table.insert(why, "I " .. room_key_of[num] .. " late")
                            end
                        end
                        for home_id, _ in pairs(handle.summary.H) do
                            if trial.H[home_id] == nil then
                                table.insert(why, "loses H " .. home_id)
                            elseif trial.H[home_id] >= h_deadline(home_id) then
                                table.insert(why, "H " .. home_id .. " late")
                            end
                        end
                        table.insert(timeline.route_refusals, tech_name .. " <- " .. key .. ": " .. table.concat(why, "; "))
                    end
                end
            end
        end
        if num_added > 0 then
            info.prereqs.keys = keys
            result.IR = result.IR or {}
            handle.summary = result
            local discoveries = discoveries_of(keys)
            union_into(discoveries, handle.discoveries)
            handle.discoveries = discoveries
            counts.route_prerequisites = (counts.route_prerequisites or 0) + num_added
        end
    end

    ----------------------------------------------------------------------
    -- The walk
    ----------------------------------------------------------------------

    local events = {}
    for _, need in pairs(needs) do
        table.insert(events, {
            rank = need.rank,
            need = need,
            name = need.recipe .. "\n" .. need.key,
        })
    end
    local kept_never = {}
    for _, tech_name in pairs(sorted_keys(params.kept)) do
        local first = summary_of(gutils.key("technology", tech_name)).P
        if first ~= nil then
            table.insert(events, {
                rank = first,
                kept = tech_name,
                name = tech_name,
            })
        else
            table.insert(kept_never, tech_name)
        end
    end
    for _, tech_name in pairs(sorted_keys(params.kept)) do
        for _, room in pairs(params.discovers[tech_name] or {}) do
            local first
            for context, rank in pairs(nci[gutils.key("room", room)] or {}) do
                if context < HOME_STRIDE and (first == nil or rank < first) then
                    first = rank
                end
            end
            if first ~= nil then
                table.insert(events, {
                    rank = first,
                    route = room,
                    kept = tech_name,
                    name = tech_name .. "\n" .. room,
                })
            end
        end
    end
    table.sort(events, function(a, b)
        if a.rank ~= b.rank then
            return a.rank < b.rank
        end
        return a.name < b.name
    end)

    local function process(need)
        local recipe_name = need.recipe
        -- A starting recipe its discovery alone unlocked waits for the discovery everywhere (will_bring), which gives it in time where the timeline had it
        local allowed = will_bring[recipe_name] == nil and allowed_for(need) or nil
        for pass = 1, 2 do
            for _, handle in pairs(unlocking[recipe_name] or {}) do
                local timing = pass == 1 and in_time(handle.summary, need) or pass == 2 and late_ok(handle.summary, need)
                if timing and (allowed == nil or subset(handle.discoveries, allowed)) then
                    server[recipe_name] = server[recipe_name] or {}
                    server[recipe_name][need.key] = handle
                    used(handle, need.rank, need.key)
                    if pass == 2 then
                        counts.late_isolatable_served = (counts.late_isolatable_served or 0) + 1
                    end
                    return
                end
            end
        end
        local handle = place(need)
        if handle ~= nil then
            server[recipe_name] = server[recipe_name] or {}
            server[recipe_name][need.key] = handle
        end
    end

    for _, event in pairs(events) do
        current_rank = event.rank
        current_class = event.need ~= nil and event.need.key or nil
        if event.route ~= nil then
            add_route(event.kept, event.route, event.rank)
        elseif event.kept ~= nil then
            add_kept(event.kept)
        else
            process(event.need)
        end
    end
    current_rank = nil
    current_class = nil

    -- A rebuilt recipe the timeline never needed a technology for still gets one, with the research of its first unlocker, so it stays unlockable
    local num_waiting = 0
    local waiting = {}
    for _, recipe_name in pairs(sorted_keys(unlock_edges_of)) do
        if unlocking[recipe_name] == nil and #(other_unlocks_of[recipe_name] or {}) == 0 then
            local source = (params.unlockers[recipe_name] or {})[1]
            if source ~= nil then
                local research = research_of(source)
                local prereqs = new_prereqs()
                for _, gate in pairs(sorted_keys(params.input_gates[source])) do
                    add_prereq(prereqs, gutils.key("technology", gate), "its research comes after " .. gate)
                end
                local summary, discoveries = try(research, prereqs)
                new_unit({
                    recipe = recipe_name,
                    id = -1,
                    context = 0,
                }, research, prereqs, summary, discoveries)
                num_waiting = num_waiting + 1
                if #waiting < 20 then
                    table.insert(waiting, recipe_name)
                end
            end
        end
    end

    ----------------------------------------------------------------------
    -- Technologies another of the same recipe makes pointless
    ----------------------------------------------------------------------

    -- The same research, only prerequisites the first needs anyway, and in time wherever the first is: the pointless one goes, and what needed it needs the other instead (user's issue 2; the superfluous rule of tree-checks.lua)
    local function prereq_keys_of(key)
        local unit = unit_of_key[key]
        if unit ~= nil then
            return unit.prereqs.keys
        end
        local handle = handle_of(key)
        local info = handle ~= nil and handle.kept ~= nil and kept_in[handle.kept] or nil
        return info ~= nil and info.prereqs.keys or {}
    end
    local function research_signature(unit)
        local research = unit.research
        local added = {}
        for _, pack in pairs(research.added_packs or {}) do
            table.insert(added, pack)
        end
        table.sort(added)
        return tostring(research.key) .. "/" .. tostring(research.num_unlocks) .. "/" .. table.concat(added, ",")
    end
    local function no_later(a, b)
        local sa = handle_of(a.key).summary
        local sb = handle_of(b.key).summary
        if sa.P ~= nil and (sb.P == nil or sb.P > sa.P) then
            return false
        end
        for num, rank in pairs(sa.I) do
            if sb.I[num] == nil or sb.I[num] > rank then
                return false
            end
        end
        for home_id, rank in pairs(sa.H) do
            if sb.H[home_id] == nil or sb.H[home_id] > rank then
                return false
            end
        end
        return true
    end
    local dropped = {}
    local changed = true
    while changed do
        changed = false
        local closure_memo = {}
        local function closure(key)
            local found = closure_memo[key]
            if found ~= nil then
                return found
            end
            found = {}
            closure_memo[key] = found
            for _, pre in pairs(prereq_keys_of(key)) do
                if dropped[pre] == nil then
                    found[pre] = true
                    for other, _ in pairs(closure(pre)) do
                        found[other] = true
                    end
                end
            end
            return found
        end
        local by_recipe = {}
        for _, unit in pairs(units) do
            if dropped[unit.key] == nil then
                by_recipe[unit.recipe] = by_recipe[unit.recipe] or {}
                table.insert(by_recipe[unit.recipe], unit)
            end
        end
        for _, recipe_name in pairs(sorted_keys(by_recipe)) do
            local list = by_recipe[recipe_name]
            for _, a in pairs(list) do
                if dropped[a.key] == nil then
                    for _, b in pairs(list) do
                        if b ~= a and dropped[b.key] == nil and dropped[a.key] == nil and research_signature(a) == research_signature(b) and no_later(a, b) then
                            local a_needs = closure(a.key)
                            local inside = true
                            for _, pre in pairs(b.prereqs.keys) do
                                inside = inside and (a_needs[pre] ~= nil or dropped[pre] ~= nil)
                            end
                            local mutual = no_later(b, a)
                            local b_needs = closure(b.key)
                            for _, pre in pairs(a.prereqs.keys) do
                                mutual = mutual and (b_needs[pre] ~= nil or dropped[pre] ~= nil)
                            end
                            if inside and not (mutual and a.id < b.id) then
                                dropped[a.key] = b.key
                                changed = true
                            end
                        end
                    end
                end
            end
        end
        if changed then
            local function cover_of(key)
                while dropped[key] ~= nil do
                    key = dropped[key]
                end
                return key
            end
            local function rewire(prereqs, own_key)
                local new_keys = {}
                local listed = {}
                for _, key in pairs(prereqs.keys) do
                    local target = cover_of(key)
                    if listed[target] == nil and target ~= own_key then
                        listed[target] = true
                        table.insert(new_keys, target)
                        if target ~= key then
                            prereqs.reason[target] = prereqs.reason[target] or ((prereqs.reason[key] or "needed") .. ", through the technology covering it")
                        end
                    end
                end
                prereqs.keys = new_keys
            end
            for _, unit in pairs(units) do
                if dropped[unit.key] == nil then
                    rewire(unit.prereqs, unit.key)
                end
            end
            for tech_name, info in pairs(kept_in) do
                rewire(info.prereqs, gutils.key("technology", tech_name))
            end
        end
    end
    local kept_units = {}
    for _, unit in pairs(units) do
        if dropped[unit.key] == nil then
            table.insert(kept_units, unit)
        else
            unit_of_key[unit.key] = nil
            counts.covered = (counts.covered or 0) + 1
        end
    end
    units = kept_units

    -- A recipe a kept technology brings that one of its prerequisites unlocks already isn't brought (an unlock another one makes pointless, the superfluous rule of tree-checks.lua)
    -- The route to its planet, added once the planet was reached (add_route), can bring the recipe's own technology along after the discovery's turn decided to bring the recipe
    local function final_key(key)
        while dropped[key] ~= nil do
            key = dropped[key]
        end
        return key
    end
    local needs_memo = {}
    local function needs_of_key(key)
        local found = needs_memo[key]
        if found ~= nil then
            return found
        end
        found = {}
        needs_memo[key] = found
        for _, pre in pairs(prereq_keys_of(key)) do
            found[pre] = true
            for other, _ in pairs(needs_of_key(pre)) do
                found[other] = true
            end
        end
        return found
    end
    for _, tech_name in pairs(sorted_keys(kept_in)) do
        local info = kept_in[tech_name]
        local tech_key = gutils.key("technology", tech_name)
        local needed = needs_of_key(tech_key)
        for _, recipe_name in pairs(sorted_keys(info.packaged)) do
            for _, handle in pairs(unlocking[recipe_name] or {}) do
                local key = final_key(handle.key)
                if key ~= tech_key and needed[key] ~= nil then
                    info.packaged[recipe_name] = nil
                    if info.own_packaged[recipe_name] ~= nil then
                        counts.packaged_own = counts.packaged_own - 1
                    else
                        counts.packaged_start = counts.packaged_start - 1
                    end
                    break
                end
            end
        end
    end

    return {
        units = units,
        unit_of_key = unit_of_key,
        kept = kept_in,
        counts = counts,
        given_up = given_up,
        waiting = waiting,
        num_waiting = num_waiting,
        kept_never = kept_never,
        num_rounds = 1,
        validation = validation,
        -- For the served rule's check: the discoveries a recipe's other inputs in a room needed on the timeline
        inherent_discoveries = function(recipe_name, room)
            local found = {}
            for _, need in pairs(needs_of[recipe_name] or {}) do
                if need.kind ~= "h" and room_key_of[need.id] == room then
                    union_into(found, inherent(need))
                end
            end
            return found
        end,
        -- For offline checks: each unit's timing as the walk worked it out
        summary_of_unit = function(key)
            local handle = handle_of(key)
            return handle ~= nil and handle.summary or nil
        end,
    }
end

return timeline

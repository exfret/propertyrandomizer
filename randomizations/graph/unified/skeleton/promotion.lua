-- Promotion keeps mechanic contexts and recipe reachability during randomization
-- See docs/glossary.md for terminology (promised pebble, backing, rank, promotion, fallback bundle)
--
-- A pebble is identified by its index (rank) in the sort, and it's *established* if it has a backing of established pebbles with strictly lower rank in the current random graph
-- In that graph, resolved recipes use their new ingredients and unresolved recipes use their vanilla ingredients (their fallback bundle)
-- Promised pebbles are established by construction, so the search stops at them
-- Promising an unresolved recipe pebble (r, c) promises its vanilla ingredient pebbles in c too (they're in its backing), which keeps r's vanilla ingredients a valid fallback when r is finally resolved
-- Since ranks strictly decrease along backings, induction on rank shows every promised pebble is reachable at the end
--
-- Derived recycling: recycling X returns the current ingredients of the recipe it inverts (lib/logic/recycling-sources.lua, also used by fixes.lua)
-- So an edge "X-recycling --> item-craft Y" only exists while Y is still an ingredient of that recipe
-- Promising something that uses such an edge before that recipe is resolved pins Y to it, and recipe randomization keeps pinned ingredients (vanilla ingredients contain every pin, so the fallback still works)
-- Mechanics that don't need derived recycling are promised first, so pins only come from ones that really do

local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")
local logic = require("lib/logic/init")
local protection = require("randomizations/graph/unified/skeleton/protection")
local recycling_sources = require("lib/logic/recycling-sources")

local key = gutils.key

local promotion = {}

local function is_ingredient_owner_type(node_type)
    return node_type == "item" or node_type == "fluid-temperature-range"
end

-- params: graph (the random graph, or first pass's split graph when first pass ran), head_to_base (generic handlers' choices), pool_sort_info (optional, for reporting), complex (use complex room/ability contexts, with home contexts for the discovery rule)
-- params.connection_abilities (optional) is function(base, head) giving the abilities of the edge that connects a base to a head (see gutils.connect_base_head); by default a base keeps its original edge's abilities
-- Which mechanic contexts are promised follows protection.lua
-- With first pass, the split graph must be used: it's the model reflection builds (e.g. item identities swapped), so reasoning over the unsplit graph would be about a different game
promotion.new = function(params)
    local head_to_base = params.head_to_base or {}

    local graph = table.deepcopy(params.graph)

    -- Abilities of the edge connecting base_key to head_key, like a spawn slot's loot not being automatable
    local function connection_abilities(base_key, head_key)
        local base = graph.nodes[base_key]
        if base.type ~= "base" then
            return nil
        end
        if params.connection_abilities ~= nil then
            return params.connection_abilities(base, graph.nodes[head_key])
        end
        return base.abilities
    end

    -- Heads a rewire left without a base (see try_rewires), which are unreachable rather than falling back to their vanilla base
    -- Heads whose edge says starts_detached begin this way: their vanilla base is only there so the edge could be claimed, like a unit's placing slot no item fills in vanilla
    local detached = {}

    -- Ranks come from a random sort of the current hybrid graph: generic handlers' choices applied, recipe ingredients still vanilla
    -- The pool sort is of the vanilla graph, which generic handlers have already rewired, so its ranks don't fit
    -- Heads chosen by a generic handler get that base, other cut heads get their vanilla base (unless they start detached), and connected heads that no handler reassigned (like first pass's own slot/trav heads) stay as they are
    for node_key, node in pairs(graph.nodes) do
        if node.type == "head" and node.name ~= "" then
            local new_base = head_to_base[node_key]
            if new_base ~= nil then
                for pre, _ in pairs(table.deepcopy(node.pre)) do
                    gutils.remove_edge(graph, pre)
                end
                gutils.connect_base_head(graph, new_base, node_key, connection_abilities(new_base, node_key))
            elseif node.starts_detached ~= nil then
                for pre, _ in pairs(table.deepcopy(node.pre)) do
                    gutils.remove_edge(graph, pre)
                end
                detached[node_key] = true
            elseif next(node.pre) == nil then
                gutils.connect_base_head(graph, node.old_base, node_key, connection_abilities(node.old_base, node_key))
            end
        end
    end
    local complex = params.complex == true
    -- With complex contexts, home contexts give the order-independent discovery rule (see context-sort.lua), using the vanilla home sets
    local sort_info = top.sort(graph, nil, nil, {
        choose_randomly = true,
        complex_contexts = complex,
        home_contexts = complex,
    })
    local sorted = sort_info.sorted
    local nci = sort_info.node_to_context_inds

    local state = {
        -- ind --> true
        is_promised = {},
        num_promised = 0,
        -- recipe node key --> list of ingredient owner node keys
        resolved = {},
    }

    -- recipe node key --> { fixed = list of non-ingredient prereqs ({ key, edge }), vanilla_owners = list of ingredient owner keys }
    -- Ingredient heads are the subdivided item/fluid --> recipe edges; they are cut in the random graph
    local recipe_info = {}
    local function get_recipe_info(recipe_key)
        if recipe_info[recipe_key] == nil then
            local info = {
                fixed = {},
                vanilla_owners = {},
                vanilla_owner_by_material = {},
            }
            for pre, _ in pairs(graph.nodes[recipe_key].pre) do
                local prenode = gutils.prenode(graph, pre)
                local owner
                if prenode.type == "head" and prenode.old_base ~= nil then
                    local base = graph.nodes[prenode.old_base]
                    local base_pre = gutils.prenodes(graph, base)[1]
                    if base_pre ~= nil and is_ingredient_owner_type(base_pre.type) then
                        owner = base_pre
                    end
                end
                if owner ~= nil then
                    table.insert(info.vanilla_owners, key(owner))
                    local material_key
                    if owner.type == "fluid-temperature-range" then
                        material_key = key("fluid", gutils.deconstruct(owner.name).type)
                    else
                        material_key = key(owner)
                    end
                    info.vanilla_owner_by_material[material_key] = key(owner)
                else
                    table.insert(info.fixed, {
                        key = key(prenode),
                        edge_key = pre,
                    })
                end
            end
            recipe_info[recipe_key] = info
        end
        return recipe_info[recipe_key]
    end

    -- Derived recycling edges, as orand key --> { source = key of the inverted recipe R, material = key of the returned item Y, recycling = key of the recycling recipe }
    local derived_orand = {}
    -- recipe key --> set of keys of the recycling recipes that invert it
    local recycling_of = {}
    local num_derived_edges = 0
    for node_key, node in pairs(graph.nodes) do
        if node.type == "orand" then
            local child_key = graph.orand_to_child[node_key]
            local parent_key = graph.orand_to_parent[node_key]
            local child = child_key ~= nil and graph.nodes[child_key] or nil
            local parent = parent_key ~= nil and graph.nodes[parent_key] or nil
            if child ~= nil and parent ~= nil and child.type == "recipe" and parent.type == "item-craft" then
                local source_name = recycling_sources.get(old_data_raw)[child.name]
                local source_key = source_name ~= nil and key("recipe", source_name) or nil
                if source_key ~= nil and graph.nodes[source_key] ~= nil then
                    derived_orand[node_key] = {
                        source = source_key,
                        material = key("item", parent.name),
                        recycling = child_key,
                    }
                    recycling_of[source_key] = recycling_of[source_key] or {}
                    recycling_of[source_key][child_key] = true
                    num_derived_edges = num_derived_edges + 1
                end
            end
        end
    end
    log("Promotion: " .. num_derived_edges .. " derived recycling edges")

    -- recipe key --> material key --> true: ingredients a recipe must keep because a promise relies on its recycling returning them
    local pins = {}
    local num_pins = 0
    -- item-craft key --> list of recycling recipe keys that return it only because of a resolved recipe's new ingredients
    local new_providers = {}
    -- Turned off while promising mechanics that don't need derived recycling
    local allow_derived = true

    local function recipe_has_material(recipe_key, material_key)
        local owners = state.resolved[recipe_key]
        if owners == nil then
            return true
        end
        for _, owner_key in pairs(owners) do
            if owner_key == material_key then
                return true
            end
        end
        for _, pre in pairs(get_recipe_info(recipe_key).fixed) do
            if pre.key == material_key then
                return true
            end
        end
        return false
    end

    -- Whether node_key isn't a derived recycling edge that has been lost (or is currently disallowed)
    local function derived_valid(node_key)
        local d = derived_orand[node_key]
        if d == nil then
            return true
        end
        if not allow_derived then
            return false
        end
        return recipe_has_material(d.source, d.material)
    end

    -- New ingredients of a recipe are now returned by the recycling recipes that invert it
    local function note_new_ingredients(recipe_key, owner_keys)
        for recycling_key, _ in pairs(recycling_of[recipe_key] or {}) do
            for _, owner_key in pairs(owner_keys) do
                local owner = gutils.deconstruct(owner_key)
                if owner.type == "item" then
                    local item_craft_key = key("item-craft", owner.name)
                    local item_craft = graph.nodes[item_craft_key]
                    if item_craft ~= nil then
                        local exists = false
                        for pre, _ in pairs(item_craft.pre) do
                            if graph.orand_to_child[graph.edges[pre].start] == recycling_key then
                                exists = true
                            end
                        end
                        if not exists then
                            new_providers[item_craft_key] = new_providers[item_craft_key] or {}
                            table.insert(new_providers[item_craft_key], recycling_key)
                        end
                    end
                end
            end
        end
    end

    -- Establishability cache; only valid until the next resolve/commit
    local memo = {}
    local support = {}
    local function clear_cache()
        memo = {}
        support = {}
    end

    -- Ranks of the pebbles of prereq pre that get context to its dependent, earliest first
    -- pre is { key, edge_key }; with complex contexts the edge can add or remove abilities (see top.edge_source_contexts)
    -- Substituted prereqs have no edge_key: ingredient owners never carry abilities, and chosen bases carry their connection's as pre.abilities
    local function pre_inds(pre, context)
        local context_inds = nci[pre.key]
        if context_inds == nil then
            return {}
        end
        local edge = pre
        if pre.edge_key ~= nil then
            edge = graph.edges[pre.edge_key]
        end
        if not complex or edge == nil or edge.abilities == nil then
            return { context_inds[context] }
        end
        local inds = {}
        for _, source in pairs(top.edge_source_contexts(sort_info, edge, context)) do
            if context_inds[source] ~= nil then
                table.insert(inds, context_inds[source])
            end
        end
        table.sort(inds)
        return inds
    end

    -- Earliest such pebble, or nil
    local function pre_ind(pre, context)
        return pre_inds(pre, context)[1]
    end

    -- Rank of a node's own pebble in context (for ingredient owners and heads, which have no edge abilities)
    local function node_ind(node_key, context)
        return pre_ind({ key = node_key }, context)
    end

    -- A base as a prereq of a head, carrying the abilities of the edge connecting them
    local function base_pre(base_key, head_key)
        return {
            key = base_key,
            abilities = connection_abilities(base_key, head_key),
        }
    end

    -- Prereqs ({ key, edge_key }) of a node in the current random graph
    -- Recipe ingredient heads are replaced by ingredient owners (new if resolved, vanilla otherwise)
    -- Other cut heads get the base chosen by their generic handler, or their vanilla base if none was chosen
    local function get_pres(node)
        local pres = {}
        if node.type == "recipe" then
            local info = get_recipe_info(key(node))
            for _, pre in pairs(info.fixed) do
                table.insert(pres, pre)
            end
            for _, owner_key in pairs(state.resolved[key(node)] or info.vanilla_owners) do
                table.insert(pres, { key = owner_key })
            end
        elseif node.type == "head" and next(node.pre) == nil then
            if detached[key(node)] == nil then
                table.insert(pres, base_pre(head_to_base[key(node)] or node.old_base, key(node)))
            end
        else
            for pre, _ in pairs(node.pre) do
                table.insert(pres, {
                    key = graph.edges[pre].start,
                    edge_key = pre,
                })
            end
            for _, recycling_key in pairs(new_providers[key(node)] or {}) do
                table.insert(pres, { key = recycling_key })
            end
        end
        return pres
    end

    -- Nodes that discover each room (for the isolatability discovery rule in context-sort.lua), found when first needed
    local room_discoverers

    local establish

    -- Tries to find a backing for pebble ind among the given prereq keys in the given context
    -- Returns the list of support inds, or nil if there's none (op is "AND" or "OR")
    local function back_with(ind, pres, op, context)
        if op == "AND" then
            local inds = {}
            for _, pre in pairs(pres) do
                local found
                for _, i in pairs(pre_inds(pre, context)) do
                    if i < ind and establish(i) then
                        found = i
                        break
                    end
                end
                if found == nil then
                    return nil
                end
                table.insert(inds, found)
            end
            return inds
        else
            -- Earliest provider first, falling back to later providers
            local candidates = {}
            for _, pre in pairs(pres) do
                for _, i in pairs(pre_inds(pre, context)) do
                    if i < ind then
                        table.insert(candidates, i)
                    end
                end
            end
            table.sort(candidates)
            for _, i in pairs(candidates) do
                if establish(i) then
                    return { i }
                end
            end
            return nil
        end
    end

    local function compute_support(ind)
        local pebble = sorted[ind]
        local node = graph.nodes[pebble.node_key]
        if not derived_valid(pebble.node_key) then
            return nil
        end

        local pres = get_pres(node)

        if #pres == 0 then
            -- Sources: AND with no prereqs is vacuously satisfied, OR with none never is
            if node.op == "AND" then
                return {}
            end
            return nil
        end

        if logic.type_info[node.type].context == nil then
            return back_with(ind, pres, node.op, pebble.context)
        end

        -- Forgetters and emitters can send out this pebble's context from other incoming contexts (see top.node_transmit)
        -- Try those incoming contexts in order of how early their prereqs are (mirrors top.path)
        local contexts = {}
        for _, context in pairs(sort_info.contexts) do
            -- Only plain room contexts send every context to forgetters and emitters
            local transmits = not complex and sort_info.home_sets == nil
            if not transmits then
                for _, outgoing in pairs(top.node_transmit(sort_info, node, context)) do
                    if outgoing == pebble.context then
                        transmits = true
                        break
                    end
                end
            end
            local score
            for _, pre in pairs(transmits and pres or {}) do
                local i = pre_ind(pre, context)
                if node.op == "AND" then
                    if i == nil then
                        score = nil
                        break
                    end
                    score = math.max(score or 0, i)
                elseif i ~= nil and (score == nil or i < score) then
                    score = i
                end
            end
            if score ~= nil and score < ind then
                table.insert(contexts, {
                    context = context,
                    score = score,
                })
            end
        end
        table.sort(contexts, function(a, b) return a.score < b.score end)
        for _, entry in pairs(contexts) do
            local inds = back_with(ind, pres, node.op, entry.context)
            if inds ~= nil then
                return inds
            end
        end

        -- Isolatable tech contexts can also come from the discovery rule (see top.discovery_candidates): the backing is then an earlier pebble of the tech itself (in a home context of the room's home set) and an earlier pebble of a discoverer of the room
        room_discoverers = room_discoverers or top.room_discoverers(graph)
        local candidates = top.discovery_candidates(sort_info, room_discoverers, node, pebble.context)
        if candidates ~= nil then
            local own_ind
            for _, i in pairs(candidates.own) do
                if i < ind and establish(i) then
                    own_ind = i
                    break
                end
            end
            if own_ind ~= nil then
                for _, i in pairs(candidates.discoverers) do
                    if i < ind and establish(i) then
                        return { own_ind, i }
                    end
                end
            end
        end
        return nil
    end

    establish = function(ind)
        if state.is_promised[ind] then
            return true
        end
        if memo[ind] ~= nil then
            return memo[ind]
        end
        -- Ranks strictly decrease along backings, so there are no cycles; this is just a guard
        memo[ind] = false
        local inds = compute_support(ind)
        if inds ~= nil then
            memo[ind] = true
            support[ind] = inds
        end
        return memo[ind]
    end

    -- Contexts in the same room asking for strictly fewer abilities (e.g. "room | 00" and "room | 01" for "room | 11")
    -- A home context also asks for more than the context it rides on (being able to do something with only the home set's rooms means being able to do it at all)
    local function weaker_contexts(context)
        local base = top.context_without_home(context)
        local weaker = {}
        if base ~= context then
            table.insert(weaker, base)
        end
        local abilities = top.context_abilities(base)
        if abilities == nil then
            return weaker
        end
        local room = top.context_room(base)
        for _, ability_str in pairs(top.ability_strs) do
            if ability_str ~= abilities then
                local is_subset = true
                for i = 1, #ability_str do
                    if string.sub(ability_str, i, i) == "1" and string.sub(abilities, i, i) ~= "1" then
                        is_subset = false
                    end
                end
                if is_subset then
                    table.insert(weaker, top.context_key(room, ability_str))
                end
            end
        end
        return weaker
    end

    -- Promise ind and its whole (cached) backing
    -- Promises are downward closed: something promised with some abilities is also promised with fewer (being able to do something isolatably means being able to do it at all), since things that need it may not need those abilities
    local function commit(ind)
        local stack = { ind }
        while #stack > 0 do
            local curr = table.remove(stack)
            if not state.is_promised[curr] then
                if support[curr] == nil then
                    error("Committing pebble without a backing")
                end
                state.is_promised[curr] = true
                state.num_promised = state.num_promised + 1
                local d = derived_orand[sorted[curr].node_key]
                if d ~= nil and state.resolved[d.source] == nil then
                    pins[d.source] = pins[d.source] or {}
                    if pins[d.source][d.material] == nil then
                        pins[d.source][d.material] = true
                        num_pins = num_pins + 1
                    end
                end
                for _, i in pairs(support[curr]) do
                    table.insert(stack, i)
                end
                local pebble = sorted[curr]
                for _, context in pairs(weaker_contexts(pebble.context)) do
                    local i = nci[pebble.node_key][context]
                    if i ~= nil and not state.is_promised[i] then
                        if establish(i) then
                            table.insert(stack, i)
                        else
                            log("Promotion: " .. pebble.node_key .. " @ " .. pebble.context .. " is promised but can't be established @ " .. context)
                        end
                    end
                end
            end
        end
    end

    ----------------------------------------------------------------------------------------------------
    -- Public interface
    ----------------------------------------------------------------------------------------------------

    -- Whether the node has a pebble in the room of pool_context (the pool sort and this sort may use different kinds of contexts)
    local function has_room(node_key, pool_context)
        local room = top.context_room(pool_context)
        for context, _ in pairs(nci[node_key] or {}) do
            if top.context_room(context) == room then
                return true
            end
        end
        return false
    end

    -- Promise every mechanic pebble that can currently be established; returns list of pebble inds that couldn't be
    state.promise_mechanics = function()
        -- Report mechanic contexts the generic handlers already lost (reachable in the pool sort but not the hybrid graph)
        if params.pool_sort_info ~= nil then
            local num_lost = 0
            for node_key, context_inds in pairs(params.pool_sort_info.node_to_context_inds) do
                local node = graph.nodes[node_key]
                if node ~= nil and node.mechanic and node.type ~= "orand" then
                    for context, _ in pairs(context_inds) do
                        if not has_room(node_key, context) then
                            num_lost = num_lost + 1
                            log("Promotion: mechanic context lost before recipe randomization: " .. node_key .. " @ " .. context)
                        end
                    end
                end
            end
            state.num_lost_before = num_lost
            -- Same for recipes, which must all stay reachable
            local num_recipes_lost = 0
            for node_key, context_inds in pairs(params.pool_sort_info.node_to_context_inds) do
                local node = graph.nodes[node_key]
                if node ~= nil and node.type == "recipe" and next(context_inds) ~= nil and next(nci[node_key] or {}) == nil then
                    num_recipes_lost = num_recipes_lost + 1
                    log("Promotion: recipe lost before recipe randomization: " .. node_key)
                end
            end
            state.num_recipes_lost_before = num_recipes_lost
        end
        local function is_promised_mechanic(pebble)
            local node = graph.nodes[pebble.node_key]
            return node ~= nil and node.mechanic and node.type ~= "orand" and protection.is_hard_mechanic_pebble(node, pebble.context)
        end
        -- First promise everything that doesn't need derived recycling, so pins only come from pebbles that do
        allow_derived = false
        clear_cache()
        for ind, pebble in pairs(sorted) do
            if is_promised_mechanic(pebble) and establish(ind) then
                commit(ind)
            end
        end
        allow_derived = true
        clear_cache()
        log("Promotion: " .. num_pins .. " pins after promising mechanics without derived recycling")
        local failed = {}
        for ind, pebble in pairs(sorted) do
            if is_promised_mechanic(pebble) then
                if establish(ind) then
                    commit(ind)
                else
                    table.insert(failed, ind)
                end
            end
        end
        if #failed > 0 then
            state.explain(failed[1])
        end
        clear_cache()
        return failed
    end

    -- Debugging: follow a failed pebble down to where its backing search actually fails, logging each step
    state.explain = function(ind, max_depth)
        max_depth = max_depth or 40
        local curr = ind
        for depth = 1, max_depth do
            local pebble = sorted[curr]
            local node = graph.nodes[pebble.node_key]
            local strs = {}
            local next_ind
            for _, pre in pairs(get_pres(node)) do
                local pre_key = pre.key
                local i = pre_ind(pre, pebble.context)
                local status
                if i == nil then
                    status = "no-pebble"
                elseif i >= curr then
                    status = "later(" .. i .. ")"
                elseif establish(i) then
                    status = "ok(" .. i .. ")"
                else
                    status = "FAIL(" .. i .. ")"
                    if next_ind == nil then
                        next_ind = i
                    end
                end
                table.insert(strs, pre_key .. "=" .. status)
            end
            log("EXPLAIN " .. depth .. ": [" .. curr .. "] " .. pebble.node_key .. " @ " .. pebble.context .. " op=" .. tostring(node.op) .. " ctxtype=" .. tostring(logic.type_info[node.type].context) .. " pres={" .. table.concat(strs, "; ") .. "}")
            if next_ind == nil then
                return
            end
            curr = next_ind
        end
    end

    -- Logs, per context, which of the recipe's prereqs can't be established before it
    local function log_recipe_prereqs(recipe_key)
        for context, recipe_ind in pairs(nci[recipe_key] or {}) do
            local strs = {}
            for _, pre in pairs(get_pres(graph.nodes[recipe_key])) do
                local pre_key = pre.key
                local i = pre_ind(pre, context)
                local status
                if i == nil then
                    status = "none"
                elseif i >= recipe_ind then
                    status = "later"
                elseif establish(i) then
                    status = "ok"
                else
                    status = "FAIL"
                end
                table.insert(strs, pre_key .. "=" .. status)
            end
            log("Promotion: " .. recipe_key .. " @ " .. context .. " (rank " .. recipe_ind .. "): " .. table.concat(strs, "; "))
        end
    end

    -- Whether context asks for no abilities (always true for plain room contexts), and isn't a home context, which asks for the home set's rooms only
    -- Anything reachable with abilities is also reachable without them, so these are the most useful contexts to keep something reachable in
    local function is_weakest_context(context)
        if top.context_home(context) ~= nil then
            return false
        end
        local abilities = top.context_abilities(context)
        return abilities == nil or string.find(abilities, "1", 1, true) == nil
    end

    -- Earliest context in which the recipe can currently be established with its current ingredients, or nil
    -- Contexts that ask for no abilities come first, so anchoring a recipe keeps it (and its products) usable by as much as possible
    local function earliest_establishable_context(recipe_key)
        local entries = {}
        for context, ind in pairs(nci[recipe_key] or {}) do
            table.insert(entries, {
                context = context,
                ind = ind,
                weakest = is_weakest_context(context),
            })
        end
        table.sort(entries, function(a, b)
            if a.weakest ~= b.weakest then
                return a.weakest
            end
            return a.ind < b.ind
        end)
        for _, entry in pairs(entries) do
            if establish(entry.ind) then
                return entry.context
            end
        end
        return nil
    end

    -- Whether the recipe was reachable when promotion started (i.e. not already lost by earlier randomization steps)
    state.initially_reachable = function(recipe_key)
        return next(nci[recipe_key] or {}) ~= nil
    end

    -- Promise every recipe that is reachable in exactly one room (in its earliest context there asking for no abilities), returning how many were promised
    -- Anchoring recipes lazily keeps flexibility in which context they end up in, but with only one option there's nothing to choose
    -- Waiting would only let earlier choices (e.g. another handler changing something only that context has) cut the recipe off before its turn
    state.promise_single_context_recipes = function()
        local num_promised_recipes = 0
        for node_key, node in pairs(graph.nodes) do
            if node.type == "recipe" then
                local only_ind
                local rooms = {}
                local num_rooms = 0
                for context, ind in pairs(nci[node_key] or {}) do
                    local room = top.context_room(context)
                    if rooms[room] == nil then
                        rooms[room] = true
                        num_rooms = num_rooms + 1
                    end
                    if is_weakest_context(context) and (only_ind == nil or ind < only_ind) then
                        only_ind = ind
                    end
                end
                if num_rooms == 1 and only_ind ~= nil and not state.is_promised[only_ind] and establish(only_ind) then
                    commit(only_ind)
                    num_promised_recipes = num_promised_recipes + 1
                end
            end
        end
        clear_cache()
        return num_promised_recipes
    end

    -- Contexts in which all of the recipe's new ingredients must be established
    -- These are its promised contexts; a recipe with none gets one anchor context chosen now, the earliest it can currently be established in with its vanilla ingredients, so they remain a valid fallback there
    -- Ingredients are always checked against these explicit contexts, since ingredients checked separately against "some context" could share none, and every recipe must stay reachable
    -- Returns an empty list only if the recipe can't be reached anywhere anymore
    -- Contexts a node is promised in; unlike required_contexts, there's no anchor context when there are none
    state.promised_contexts = function(node_key)
        local contexts = {}
        for context, ind in pairs(nci[node_key] or {}) do
            if state.is_promised[ind] then
                table.insert(contexts, context)
            end
        end
        table.sort(contexts)
        return contexts
    end

    state.required_contexts = function(recipe_key)
        local contexts = {}
        for context, ind in pairs(nci[recipe_key] or {}) do
            if state.is_promised[ind] then
                table.insert(contexts, context)
            end
        end
        if #contexts == 0 then
            local anchor = earliest_establishable_context(recipe_key)
            if anchor ~= nil then
                table.insert(contexts, anchor)
            else
                log_recipe_prereqs(recipe_key)
            end
        end
        return contexts
    end

    -- Whether ingredient owner could be promoted in each required context before the recipe
    state.candidate_ok = function(recipe_key, owner_key, required_contexts)
        assert(#required_contexts > 0, "candidate_ok needs required contexts (from required_contexts) for " .. recipe_key)
        for _, context in pairs(required_contexts) do
            local i = node_ind(owner_key, context)
            if i == nil or i >= nci[recipe_key][context] or not establish(i) then
                return false
            end
        end
        return true
    end

    state.vanilla_owners = function(recipe_key)
        return get_recipe_info(recipe_key).vanilla_owners
    end

    -- Owner key of the vanilla ingredient edge for this material, or nil if the ingredient isn't a randomized edge
    state.vanilla_owner = function(recipe_key, material)
        return get_recipe_info(recipe_key).vanilla_owner_by_material[key(material.type, material.name)]
    end

    -- Record the recipe's new ingredient owners, then promise them and the recipe itself in each required context
    -- Candidates must have passed candidate_ok (or be the vanilla fallback) since the last resolve
    state.resolve = function(recipe_key, owner_keys, required_contexts)
        assert(#required_contexts > 0, "resolve needs required contexts (from required_contexts) for " .. recipe_key)
        log("Promotion: resolving " .. recipe_key .. " in " .. table.concat(required_contexts, ", "))
        for _, context in pairs(required_contexts) do
            for _, owner_key in pairs(owner_keys) do
                local i = node_ind(owner_key, context)
                if i == nil or i >= nci[recipe_key][context] or not establish(i) then
                    error("Resolving recipe " .. recipe_key .. " with unestablished ingredient " .. owner_key .. " in " .. context)
                end
                commit(i)
            end
        end
        state.resolved[recipe_key] = owner_keys
        note_new_ingredients(recipe_key, owner_keys)
        clear_cache()

        -- Already promised for mechanic contexts; this is what anchors the rest
        for _, context in pairs(required_contexts) do
            local ind = nci[recipe_key][context]
            if not establish(ind) then
                log_recipe_prereqs(recipe_key)
                error("Recipe " .. recipe_key .. " can't be established in required context " .. context .. " after resolving")
            end
            commit(ind)
        end
        clear_cache()
    end

    -- Ingredients the recipe must keep because promised recycling relies on them, as material key --> true
    state.pins_for = function(recipe_key)
        return pins[recipe_key] or {}
    end

    -- Record new ingredients of a recipe randomized without required contexts, which still changes what its recycling returns
    state.record_ingredients = function(recipe_key, owner_keys)
        if state.resolved[recipe_key] == nil then
            state.resolved[recipe_key] = owner_keys
            note_new_ingredients(recipe_key, owner_keys)
            clear_cache()
        end
    end

    -- Logs every pin
    state.log_pins = function()
        local lines = {}
        local num_recipes = 0
        for recipe_key, materials in pairs(pins) do
            local list = {}
            for material_key, _ in pairs(materials) do
                table.insert(list, material_key)
            end
            table.sort(list)
            table.insert(lines, recipe_key .. " keeps " .. table.concat(list, ", "))
            num_recipes = num_recipes + 1
        end
        table.sort(lines)
        log("Promotion: " .. num_pins .. " pinned ingredients on " .. num_recipes .. " recipes (" .. num_derived_edges .. " derived recycling edges)")
        for _, line in pairs(lines) do
            log("Promotion: pin " .. line)
        end
    end

    -- Earliest established pebble of base_key before the head's pebble in context that gets context to the head through their connection (so its abilities count), or nil
    local function base_backing(base_key, head_key, context)
        local head_ind = node_ind(head_key, context)
        if head_ind == nil then
            return nil
        end
        for _, i in pairs(pre_inds(base_pre(base_key, head_key), context)) do
            if i < head_ind and establish(i) then
                return i
            end
        end
        return nil
    end

    -- Checks a candidate base for a generic handler head (e.g. energy source --> entity-operate)
    -- The base must be establishable before the head in each required context of the head's dependent (from required_contexts(dep))
    state.head_candidate_ok = function(head_key, base_key, required_contexts)
        assert(#required_contexts > 0, "head_candidate_ok needs required contexts (from required_contexts) for " .. head_key)
        for _, context in pairs(required_contexts) do
            if base_backing(base_key, head_key, context) == nil then
                return false
            end
        end
        return true
    end

    -- Point head at its chosen base, then promise the base, the head and the head's dependent in each required context
    -- The base must have passed head_candidate_ok (or be the head's vanilla base) since the last resolve
    -- With no required contexts (dependent not reachable anyway), this only repoints the head
    state.resolve_head = function(head_key, base_key, required_contexts)
        for _, context in pairs(required_contexts) do
            local i = base_backing(base_key, head_key, context)
            if i == nil then
                error("Resolving head " .. head_key .. " with unestablished base " .. base_key .. " in " .. context)
            end
            commit(i)
        end
        local head = graph.nodes[head_key]
        for pre, _ in pairs(table.deepcopy(head.pre)) do
            gutils.remove_edge(graph, pre)
        end
        gutils.connect_base_head(graph, base_key, head_key, connection_abilities(base_key, head_key))
        detached[head_key] = nil
        clear_cache()

        local dep_key = key(gutils.unique_depnode(graph, head))
        for _, context in pairs(required_contexts) do
            for _, node_key in pairs({ head_key, dep_key }) do
                local ind = nci[node_key][context]
                if not establish(ind) then
                    error("Can't establish " .. node_key .. " in " .. context .. " after resolving head " .. head_key)
                end
                commit(ind)
            end
        end
        clear_cache()
    end

    -- Keys of the nodes currently feeding node_key in promotion's graph
    state.pre_keys_of = function(node_key)
        local pre_keys = {}
        for pre, _ in pairs(graph.nodes[node_key].pre) do
            table.insert(pre_keys, graph.edges[pre].start)
        end
        return pre_keys
    end

    -- Try rewiring edges and check that every promised pebble of each rewired node can still be established
    -- changes is a list of { node_key, remove = list of prereq keys whose edges to node_key are removed, add = prereq key or nil, detach = whether a head is left without a base }
    -- A detached head is unreachable, like an entity no longer found in the wild; only a head that's detached can have no base
    -- With should_commit, a successful rewire is kept and the new backings are promised; otherwise (or on failure) everything is reverted
    -- This is for choices that aren't recipe ingredients or generic handler heads, like first pass's slot/trav assignments
    state.try_rewires = function(changes, should_commit)
        local removed_edges = {}
        local added_edges = {}
        -- Detached state of each rewired head before this rewire, to restore on revert
        local was_detached = {}
        for _, change in pairs(changes) do
            if was_detached[change.node_key] == nil then
                was_detached[change.node_key] = detached[change.node_key] or false
            end
            if change.detach then
                detached[change.node_key] = true
            elseif change.add ~= nil then
                detached[change.node_key] = nil
            end
            for _, pre_key in pairs(change.remove or {}) do
                local edge_key = gutils.ekey({
                    start = pre_key,
                    stop = change.node_key,
                })
                if graph.edges[edge_key] ~= nil then
                    table.insert(removed_edges, table.deepcopy(graph.edges[edge_key]))
                    gutils.remove_edge(graph, edge_key)
                end
            end
            if change.add ~= nil and graph.edges[gutils.ekey({
                start = change.add,
                stop = change.node_key,
            })] == nil then
                -- A base connecting to a head carries the connection's abilities
                table.insert(added_edges, gutils.ekey(gutils.connect_base_head(graph, change.add, change.node_key, connection_abilities(change.add, change.node_key))))
            end
        end
        -- Only pebbles of rewired nodes can have lost their backing (removed edges end at them), so they must find new backings: un-promise them while checking
        local unpromised = {}
        for _, change in pairs(changes) do
            for _, ind in pairs(nci[change.node_key] or {}) do
                if state.is_promised[ind] then
                    state.is_promised[ind] = nil
                    state.num_promised = state.num_promised - 1
                    table.insert(unpromised, ind)
                end
            end
        end
        clear_cache()

        local ok = true
        for _, ind in pairs(unpromised) do
            if not establish(ind) then
                ok = false
                break
            end
        end

        if ok and should_commit then
            for _, ind in pairs(unpromised) do
                commit(ind)
            end
        else
            for _, ind in pairs(unpromised) do
                if not state.is_promised[ind] then
                    state.is_promised[ind] = true
                    state.num_promised = state.num_promised + 1
                end
            end
        end
        if not (ok and should_commit) then
            for node_key, value in pairs(was_detached) do
                if value then
                    detached[node_key] = true
                else
                    detached[node_key] = nil
                end
            end
            for _, edge_key in pairs(added_edges) do
                gutils.remove_edge(graph, edge_key)
            end
            for _, edge in pairs(removed_edges) do
                gutils.add_edge(graph, edge.start, edge.stop, edge)
            end
        end
        clear_cache()
        return ok
    end

    -- Every promised pebble with its rank, in rank order (for checking the model against the final game)
    state.promised_pebbles = function()
        local pebbles = {}
        for ind, _ in pairs(state.is_promised) do
            table.insert(pebbles, {
                node_key = sorted[ind].node_key,
                context = sorted[ind].context,
                rank = ind,
            })
        end
        table.sort(pebbles, function(a, b) return a.rank < b.rank end)
        return pebbles
    end

    -- Anchor every initially reachable recipe that has no promised pebble yet (e.g. recipes the handler never randomizes)
    -- Returns keys of recipes that can't be reached anywhere anymore
    state.anchor_remaining_recipes = function()
        local unreachable = {}
        for node_key, node in pairs(graph.nodes) do
            if node.type == "recipe" and state.initially_reachable(node_key) then
                local has_promise = false
                for _, ind in pairs(nci[node_key]) do
                    if state.is_promised[ind] then
                        has_promise = true
                        break
                    end
                end
                if not has_promise then
                    local context = earliest_establishable_context(node_key)
                    if context ~= nil then
                        commit(nci[node_key][context])
                    else
                        log_recipe_prereqs(node_key)
                        table.insert(unreachable, node_key)
                    end
                end
            end
        end
        clear_cache()
        table.sort(unreachable)
        return unreachable
    end

    return state
end

return promotion

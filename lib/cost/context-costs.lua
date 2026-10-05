-- Recipe costs per context (room), so a route that only exists elsewhere doesn't set a room's costs (like space crushing making Nauvis iron ore cheap)
-- Each room prices with its own raw sources (the logic graph's prices there, lib/cost/graph-cost.lua) and the recipes available there, as the context sort finds them
-- Two tiers per room: local (nothing brought in) and full (with imports: what the room has but doesn't make, at their home room's cost)
-- A material's home is the room the sort first reaches it in. There its cost is the local one when there is one, so imports never undercut it (like scrap shipped to Nauvis cheapening circuits)
-- Elsewhere it costs the lesser of the local cost and the home's, so an odd local route can't make it dearer than bringing it in (like Aquilo making iron plates the long way)
-- lib/cost/flow-cost.lua does the pricing: it treats a recipe missing from its ingredient overrides as unavailable, so each room gets a view of the overrides with only its recipes

local gutils = require("lib/graph/graph-utils")
local constants = require("helper-tables/constants")
local graph_cost = require("lib/cost/graph-cost-core")
local flow_cost = require("lib/cost/flow-cost")
local cutils = require("lib/cost/cost-utils")
local dutils = require("lib/data-utils")

local context_costs = {}

-- Rounds of pricing imports from the previous round's costs (the room an import comes from may make it with imports of its own)
-- Staged sets' refreshes stop there too: quotes between rooms that import from each other's full tiers can keep changing
local IMPORT_ROUNDS = 3

local function sorted_keys(tbl)
    local keys = {}
    for k, _ in pairs(tbl) do
        table.insert(keys, k)
    end
    table.sort(keys)
    return keys
end

-- The context a node is first reached in by a sort, or nil
local function first_context(sort_info, node_key)
    local best_context
    local best_ind
    for context, ind in pairs(sort_info.node_to_context_inds[node_key] or {}) do
        if best_ind == nil or ind < best_ind or (ind == best_ind and context < best_context) then
            best_context = context
            best_ind = ind
        end
    end
    return best_context
end

-- A view of ing_overrides with only the recipes available in a room (flow_cost treats the rest as unavailable)
local function overrides_view(available, ing_overrides)
    return setmetatable({}, {
        __index = function(_, recipe_name)
            if available[recipe_name] ~= nil then
                return ing_overrides[recipe_name]
            end
            return nil
        end,
    })
end

-- Every recipe's ingredients as the game has them (with use_data, flow_cost only reads these for availability)
function context_costs.data_overrides()
    local overrides = {}
    for recipe_name, recipe in pairs(data.raw.recipe) do
        overrides[recipe_name] = recipe.ingredients or {}
    end
    return overrides
end

-- A room's raw costs (a fresh table, since flow_cost's updates write raw costs back in).
-- Prices include manual sources. Automation eligibility is separate metadata for callers.
local function room_seeds(info, context)
    local seeds = {}
    for id, cost in pairs(info.local_raw[context]) do
        seeds[id] = cost
    end
    return seeds
end

-- What each room has and makes, from the logic graph, its prices (graph_cost.compute_for_sort) and the sort they follow (the game before randomization)
-- contexts: context key --> true for every room (lib/logic/init.lua's logic.contexts); slot: whether prices charged slot costs (graph_cost.compute)
-- Returns info with:
--   contexts: sorted room keys; starting_context: the starting planet's
--   recipe_available[context][recipe name], material_available[context][material id]: whether the sort reaches them there
--   local_raw[context][material id]: cost without recipes there (graph_cost.price_without_recipes, scaled)
--   graph_costs[context][material id]: the graph's full price there, scaled, for what recipe costs can't price
--   material_home[material id]: the room the sort first reaches it in
--   import_from[context][material id]: the room an import is priced like (its home, or the cheapest room making it if the home can't)
--   raw_costs[material id]: cost without recipes in the room the sort first reaches it in, or its cheapest raw cost elsewhere if that room only has recipes for it (for callers pricing the whole game at once)
--   automatable[context][material id]: whether the room can have it automatably (the automatable argument, optional)
-- The game's own costs are priced here too, tracking track_resources (optional, a list of raw resource ids), and kept for context_costs.game_set
-- automatable (optional): room --> material id --> true for what a sort with complex contexts reaches automatably there (graph_cost.automatable_by_room), for callers checking ingredient eligibility independently of price
context_costs.build = function(graph, sort_info, prices, starting_context, contexts, slot, track_resources, automatable)
    local info = {
        contexts = sorted_keys(contexts),
        starting_context = starting_context,
        automatable = automatable,
        recipe_available = {},
        material_available = {},
        local_raw = {},
        graph_costs = {},
        import_from = {},
        raw_costs = {},
        recipe_first_context = {},
        material_home = {},
    }
    for _, context in pairs(info.contexts) do
        info.recipe_available[context] = {}
        info.material_available[context] = {}
        info.local_raw[context] = {}
        info.graph_costs[context] = {}
        info.import_from[context] = {}
    end
    for recipe_name, _ in pairs(data.raw.recipe) do
        local node_key = gutils.key("recipe", recipe_name)
        for context, _ in pairs(sort_info.node_to_context_inds[node_key] or {}) do
            if info.recipe_available[context] ~= nil then
                info.recipe_available[context][recipe_name] = true
            end
        end
        info.recipe_first_context[recipe_name] = first_context(sort_info, node_key)
    end
    for node_key, node in pairs(graph.nodes) do
        if node.type == "item" or node.type == "fluid" then
            local id = node.type .. "-" .. node.name
            for context, _ in pairs(sort_info.node_to_context_inds[node_key] or {}) do
                if info.material_available[context] ~= nil then
                    info.material_available[context][id] = true
                    local raw = graph_cost.price_without_recipes(graph, prices, node_key, context, slot)
                    if raw ~= nil then
                        info.local_raw[context][id] = raw * graph_cost.RAW_COST_SCALE
                    end
                    if prices[node_key][context] ~= nil then
                        info.graph_costs[context][id] = prices[node_key][context] * graph_cost.RAW_COST_SCALE
                    end
                end
            end
            -- The whole-game raw cost: at the first room, else the cheapest room with a raw source
            local first = first_context(sort_info, node_key)
            info.material_home[id] = first
            local cost = first ~= nil and info.local_raw[first] ~= nil and info.local_raw[first][id] or nil
            if cost == nil then
                for _, context in pairs(info.contexts) do
                    local other = info.local_raw[context][id]
                    if other ~= nil and (cost == nil or other < cost) then
                        cost = other
                    end
                end
            end
            info.raw_costs[id] = cost
        end
    end

    -- Pricing the game's own costs finds where imports come from (info.import_from)
    context_costs.game_set(info, track_resources or {})
    return info
end

-- A view of ing_overrides with only the recipes available in a room
context_costs.overrides_view = function(info, context, ing_overrides)
    return overrides_view(info.recipe_available[context], ing_overrides)
end

-- The room a recipe's ingredients are judged in: the starting planet if the recipe is available there, else the room the sort first reaches it in
context_costs.judging_context = function(info, recipe_name)
    if info.recipe_available[info.starting_context] ~= nil and info.recipe_available[info.starting_context][recipe_name] ~= nil then
        return info.starting_context
    end
    return info.recipe_first_context[recipe_name]
end

-- Costs in every room, kept as recipes change: aggregate costs, and each material's bill of the tracked raw resources along its cheapest recipes
-- params: ing_overrides (recipe name --> ingredients, or {"blacklisted"} for not yet available; shared, so later edits show), use_data, item_recipe_maps (shared too), track_resources (list of raw resource ids)
-- params.imports_from (optional): a set to price imports from, which saves pricing rounds (staged sets take them from the game's, see context_costs.game_set)
-- params.find_sources (optional): whether its rounds also find where each room's imports come from, into info.import_from (the game's set does, in build)
-- params.updated_contexts (optional): context --> true for the rooms updates keep up to date (the ones costs are read in); the rest stay as first priced, as import sources
-- params.dynamic_imports (optional): update every source room, and refresh a room's changed import quotes before its full tier is next read (see Set:cost_and_tier).
-- params.batch_imports (optional): the caller starts each batch with invalidate_imports(); updates still price recipes immediately, but don't invalidate import quotes within the batch.
-- params.recipe_prototypes (optional): a staged recipe table, including regenerated reverse outputs, without changing data.raw.
local Set = {}
Set.__index = Set

-- Where each room's imports come from, from a set's costs so far: each material's home, or if the home can't make it, the room making it for least
-- A room's cost here is its local one, else last round's full one unless the room brought it in itself; so it takes rounds to find sources that make something with imports of their own (like quantum processors)
local function find_sources(info, set)
    local function room_cost(context, id)
        local tiers = set.tiers[context]
        local cost = tiers["local"].material_to_cost[id]
        if cost == nil and tiers.full ~= nil and tiers.imported[id] == nil then
            cost = tiers.full.material_to_cost[id]
        end
        return cost
    end
    local sources = {}
    for _, context in pairs(info.contexts) do
        sources[context] = {}
        for _, id in pairs(sorted_keys(info.material_available[context])) do
            local home = info.material_home[id]
            if set.tiers[context]["local"].material_to_cost[id] == nil and home ~= context then
                if home ~= nil and room_cost(home, id) ~= nil then
                    sources[context][id] = home
                else
                    local best
                    local best_source
                    for _, other in pairs(info.contexts) do
                        local other_cost = other ~= context and room_cost(other, id) or nil
                        if other_cost ~= nil and (best == nil or other_cost < best) then
                            best = other_cost
                            best_source = other
                        end
                    end
                    sources[context][id] = best_source
                end
            end
        end
    end
    return sources
end

context_costs.new_set = function(info, params)
    local set = setmetatable({
        info = info,
        params = params,
        tiers = {},
        views = {},
        resource_views = {},
    }, Set)
    for _, context in pairs(info.contexts) do
        set.tiers[context] = {
            ["local"] = flow_cost.determine_recipe_item_cost(room_seeds(info, context), constants.cost_params.time, constants.cost_params.complexity, set:extra(context)),
            local_seeds = room_seeds(info, context),
        }
    end
    -- Imports come in at the cost and bill they have in their source room: from params.imports_from (another set, like the game's) if given, else in rounds like in build (a source room may price them with imports of its own)
    local function source_cost(source, id)
        if params.imports_from ~= nil then
            local cost, tier = params.imports_from:cost_and_tier(source, id)
            return cost, tier and tier.material_to_resources[id]
        end
        local tier = set.tiers[source]["local"]
        if tier.material_to_cost[id] == nil and set.tiers[source].full ~= nil then
            tier = set.tiers[source].full
        end
        return tier.material_to_cost[id], tier.material_to_resources[id]
    end
    local rounds = params.imports_from ~= nil and 1 or IMPORT_ROUNDS
    for round = 1, rounds do
        local sources = info.import_from
        if params.find_sources == true then
            sources = find_sources(info, set)
        end
        local next_tiers = {}
        for _, context in pairs(info.contexts) do
            local seeds = room_seeds(info, context)
            local bills = {}
            local imported = {}
            for id, source in pairs(sources[context]) do
                local cost, bill = source_cost(source, id)
                if seeds[id] == nil and cost ~= nil then
                    seeds[id] = cost
                    bills[id] = bill
                    imported[id] = true
                end
            end
            local extra = set:extra(context)
            extra.raw_bills = bills
            next_tiers[context] = {
                seeds = seeds,
                bills = bills,
                imported = imported,
                full = flow_cost.determine_recipe_item_cost(seeds, constants.cost_params.time, constants.cost_params.complexity, extra),
            }
        end
        for _, context in pairs(info.contexts) do
            set.tiers[context].full_seeds = next_tiers[context].seeds
            set.tiers[context].bills = next_tiers[context].bills
            set.tiers[context].imported = next_tiers[context].imported
            set.tiers[context].full = next_tiers[context].full
        end
        if params.find_sources == true then
            info.import_from = sources
        end
    end
    return set
end

-- The game's own costs (every recipe as it is), priced once per load for info and kept, since unified randomization's retries start from the same game
-- The first one priced (in build) finds where imports come from
context_costs.game_set = function(info, track_resources)
    local cache_key = table.concat(track_resources, ",")
    info.game_sets = info.game_sets or {}
    if info.game_sets[cache_key] == nil then
        info.game_sets[cache_key] = context_costs.new_set(info, {
            ing_overrides = context_costs.data_overrides(),
            use_data = true,
            item_recipe_maps = flow_cost.construct_item_recipe_maps(),
            track_resources = track_resources,
            find_sources = info.sources_found == nil,
        })
        info.sources_found = true
    end
    return info.game_sets[cache_key]
end

-- flow_cost's extra params for a room
function Set:extra(context)
    return {
        ing_overrides = overrides_view(self.info.recipe_available[context], self.params.ing_overrides),
        use_data = self.params.use_data,
        item_recipe_maps = self.params.item_recipe_maps,
        recipe_prototypes = self.params.recipe_prototypes,
        track_resources = self.params.track_resources,
    }
end

-- An explicit tier keeps ingredient prices and their resulting product in the same production network.
-- Without one, preserve the home-price view used by other callers (see the top of this file).
function Set:cost_and_tier(context, id, tier_name)
    -- Full tiers use imports, so a room whose quotes may be stale since the last updates is refreshed first, and home prices (which can use any room's) refresh every stale room
    -- Local tiers don't use imports, and most updates are followed only by reads of those (mostly in one room), so this skips most refreshes
    local stale = self.stale_rooms
    if stale ~= nil and tier_name ~= "local" then
        if tier_name == nil then
            if next(stale) ~= nil then
                self:refresh_imports()
            end
        elseif stale[context] ~= nil then
            self:refresh_imports(context)
        end
    end
    local tiers = self.tiers[context]
    if tier_name ~= nil then
        local tier = tiers[tier_name]
        return tier.material_to_cost[id], tier
    end
    local local_cost = tiers["local"].material_to_cost[id]
    local home = self.info.material_home[id]
    if home ~= nil and home ~= context then
        local home_cost, home_tier = self:cost_and_tier(home, id)
        if home_cost ~= nil and (local_cost == nil or home_cost < local_cost) then
            return home_cost, home_tier
        end
    end
    if local_cost ~= nil then
        return local_cost, tiers["local"]
    end
    local full_cost = tiers.full.material_to_cost[id]
    if full_cost ~= nil then
        return full_cost, tiers.full
    end
    return nil
end

-- A room's material costs as a flow_cost-style material_to_cost table; tier_name is optionally "local" or "full".
function Set:view(context, tier_name)
    local view_key = context .. " " .. (tier_name or "home")
    if self.views[view_key] == nil then
        self.views[view_key] = {
            material_to_cost = setmetatable({}, {
                __index = function(_, id)
                    return (self:cost_and_tier(context, id, tier_name))
                end,
            }),
        }
    end
    return self.views[view_key]
end

-- How much of a tracked raw resource each material takes in a room (from the same tier as its cost), as a material_to_cost-style table
function Set:resource_view(context, resource_id, tier_name)
    local view_key = context .. " " .. (tier_name or "home")
    self.resource_views[view_key] = self.resource_views[view_key] or {}
    if self.resource_views[view_key][resource_id] == nil then
        self.resource_views[view_key][resource_id] = {
            material_to_cost = setmetatable({}, {
                __index = function(_, id)
                    local _, tier = self:cost_and_tier(context, id, tier_name)
                    if tier == nil then
                        return nil
                    end
                    local bill = tier.material_to_resources[id]
                    if bill == nil then
                        return nil
                    end
                    return bill[resource_id] or 0
                end,
            }),
        }
    end
    return self.resource_views[view_key][resource_id]
end

-- Adds a recipe whose ingredients (in the shared overrides) are now set: every room it's available in prices it, in each tier where all its ingredients have costs
-- Where they don't yet, cost updates price it once they do (it's no longer marked unavailable)
function Set:update(recipe_name)
    for _, context in pairs(self.info.contexts) do
        local updated = self.params.dynamic_imports == true or self.params.updated_contexts == nil or self.params.updated_contexts[context] ~= nil
        if updated and self.info.recipe_available[context][recipe_name] ~= nil then
            local ings = self.params.ing_overrides[recipe_name]
            if self.params.use_data then
                ings = data.raw.recipe[recipe_name].ingredients or {}
            end
            local tiers = self.tiers[context]
            for _, tier_name in pairs({"local", "full"}) do
                local tier = tiers[tier_name]
                local ready = tier.recipe_to_cost[recipe_name] == nil
                for _, ing in pairs(ings) do
                    if tier.material_to_cost[flow_cost.get_prot_id(ing)] == nil then
                        ready = false
                    end
                end
                if ready then
                    local extra = self:extra(context)
                    local seeds = tiers.local_seeds
                    if tier_name == "full" then
                        extra.raw_bills = tiers.bills
                        seeds = tiers.full_seeds
                    end
                    flow_cost.update_recipe_item_costs(tier, {recipe_name}, constants.max_flow_iterations, seeds, constants.cost_params.time, constants.cost_params.complexity, extra)
                end
            end
        end
    end
    if self.params.dynamic_imports == true and self.params.batch_imports ~= true then
        self:invalidate_imports()
    end
end

-- Make each room refresh on its next full-tier read. Batch callers allow older quotes between these boundaries; unread rooms stay pending.
function Set:invalidate_imports()
    self.stale_rooms = self.stale_rooms or {}
    for _, context in pairs(self.info.contexts) do
        self.stale_rooms[context] = true
    end
end

-- Import prices follow the supplying world's current recipes; original prices only fill unprocessed gaps.
-- Rebuild affected full tiers because a changed source can raise a price, which the incremental solver cannot undo.
-- Runs for all updates since a full tier was last read at once (see Set:cost_and_tier), in rounds until the quotes stop changing (at most IMPORT_ROUNDS)
-- With a target room, only that room and the stale rooms whose full tiers its quotes read (a source that brings the material in itself, and so on) are brought up to date; the others don't change what it gets
function Set:refresh_imports(target)
    local stale = self.stale_rooms or {}
    local needed = {}
    for _, context in pairs(self.info.contexts) do
        if target == nil or context == target then
            needed[context] = true
        end
    end
    local function same_bill(a, b)
        a = a or {}
        b = b or {}
        for key, value in pairs(a) do
            if value ~= b[key] then
                return false
            end
        end
        for key, value in pairs(b) do
            if value ~= a[key] then
                return false
            end
        end
        return true
    end
    for round = 1, IMPORT_ROUNDS do
        local changed = false
        -- Whether a stale room joined, which next round brings up to date and so rechecks the quotes read from it
        local joined = false
        local next_tiers = {}
        for _, context in pairs(self.info.contexts) do
            if needed[context] ~= nil then
                local tiers = self.tiers[context]
                local seeds = room_seeds(self.info, context)
                local bills = {}
                local different = false
                for id, source in pairs(self.info.import_from[context]) do
                    if seeds[id] == nil then
                        local source_tiers = self.tiers[source]
                        local source_tier = source_tiers["local"]
                        if source_tier.material_to_cost[id] == nil then
                            source_tier = source_tiers.full
                            if stale[source] ~= nil and needed[source] == nil then
                                needed[source] = true
                                joined = true
                            end
                        end
                        local cost = source_tier.material_to_cost[id]
                        local bill = source_tier.material_to_resources and source_tier.material_to_resources[id]
                        if cost == nil and self.params.imports_from ~= nil then
                            cost, source_tier = self.params.imports_from:cost_and_tier(source, id)
                            bill = source_tier and source_tier.material_to_resources and source_tier.material_to_resources[id]
                        end
                        if cost ~= nil then
                            seeds[id] = cost
                            bills[id] = bill
                        end
                        if cost ~= tiers.full_seeds[id] or not same_bill(bill, tiers.bills[id]) then
                            different = true
                        end
                    end
                end
                if different then
                    local extra = self:extra(context)
                    extra.raw_bills = bills
                    next_tiers[context] = {
                        seeds = seeds,
                        bills = bills,
                        full = flow_cost.determine_recipe_item_cost(seeds, constants.cost_params.time, constants.cost_params.complexity, extra),
                    }
                    changed = true
                end
            end
        end
        for context, update in pairs(next_tiers) do
            self.tiers[context].full = update.full
            self.tiers[context].full_seeds = update.seeds
            self.tiers[context].bills = update.bills
        end
        if not changed and not joined then
            break
        end
    end
    for context, _ in pairs(needed) do
        stale[context] = nil
    end
end

----------------------------------------------------------------------
-- Helpers for unified recipe randomization
----------------------------------------------------------------------

-- Complexity costs that are always 0: the ingredient search doesn't score complexity (get_costs_from_ings in randomizations/graph/recipe-cost.lua leaves it at 0), so it isn't priced
context_costs.NO_COMPLEXITY = {
    material_to_cost = setmetatable({}, {
        __index = function()
            return 0
        end,
    }),
}

-- A recipe's cost from material costs (a flow_cost-style table with material_to_cost), priced like flow_cost does (ingredients, then time and complexity), or nil if some ingredient has none
context_costs.recipe_cost_in = function(material_costs, recipe)
    local total = 0
    for _, ing in pairs(recipe.ingredients or {}) do
        local cost = material_costs.material_to_cost[flow_cost.get_prot_id(ing)]
        if cost == nil then
            return nil
        end
        total = total + cutils.find_amount_in_entry(ing) * cost
    end
    return total + constants.cost_params.time * (recipe.energy_required or 0.5) + constants.cost_params.complexity
end

-- A material id --> cost table reading first, then second where first has none, then default(id) (optional)
context_costs.fallback_view = function(first, second, default)
    return setmetatable({}, {
        __index = function(_, id)
            local cost = first[id]
            if cost == nil then
                cost = second[id]
            end
            if cost == nil and default ~= nil then
                cost = default(id)
            end
            return cost
        end,
    })
end

-- A set's costs in the shapes recipe randomization reads them in, tracking track_resources (the set's tracked resources)
-- in_room(context, tier_name) gives {aggregate, complexity, resources[resource id]} (flow_cost-style tables with material_to_cost)
context_costs.set_views = function(set, track_resources)
    local views = {
        set = set,
    }
    -- Prices a recipe whose ingredients (in the overrides) are now set, in every room it's available in; where its ingredients have no costs yet, cost updates price it once they do
    views.update = function(recipe_name)
        set:update(recipe_name)
    end
    -- Whether a room has a cost (and so a resource bill) for a material
    views.is_costed = function(context, material, tier_name)
        return set:view(context, tier_name).material_to_cost[flow_cost.get_prot_id(material)] ~= nil
    end
    views.aggregate = function(context, tier_name)
        return set:view(context, tier_name)
    end
    views.resource = function(context, resource_id, tier_name)
        return set:resource_view(context, resource_id, tier_name)
    end
    views.in_room = function(context, tier_name)
        local costs = {
            aggregate = set:view(context, tier_name),
            complexity = context_costs.NO_COMPLEXITY,
            resources = {},
        }
        for _, resource_id in pairs(track_resources) do
            costs.resources[resource_id] = set:resource_view(context, resource_id, tier_name)
        end
        return costs
    end
    return views
end

-- Raw resources outside the major ones (whatever resource entities give that major_raw_resources leaves out), as material id --> true
context_costs.newer_resources = function(major_raw_resources)
    local is_major = {}
    for _, id in pairs(major_raw_resources) do
        is_major[id] = true
    end
    local newer = {}
    for _, resource in pairs(dutils.prots("resource")) do
        for _, result in pairs(dutils.minable_results(resource)) do
            local id = result.type .. "-" .. result.name
            if is_major[id] == nil then
                newer[id] = true
            end
        end
    end
    return newer
end

-- How much of each material's cost in a room comes from newer resources (material id --> share from 0 to 1), for the ingredient search's bonus that gets them used (constants.new_resource_bonus)
-- Newer resources include imports only in the full tier; their cost is carried as one combined "newer" amount through flow_cost's resource bills.
-- Priced once per room and tier and kept on the set (the game's sets are kept for the load, since retries start from the same game).
context_costs.novelty = function(info, context, set, newer_resources, item_recipe_maps, tier_name)
    set.novelty = set.novelty or {}
    tier_name = tier_name or "full"
    local view_key = context .. " " .. tier_name
    if set.novelty[view_key] == nil then
        local seeds = tier_name == "local" and set.tiers[context].local_seeds or set.tiers[context].full_seeds
        local bills = {}
        for id, cost in pairs(seeds) do
            if newer_resources[id] ~= nil or (tier_name == "full" and info.import_from[context][id] ~= nil) then
                bills[id] = {
                    newer = cost,
                }
            end
        end
        local costs = flow_cost.determine_recipe_item_cost(seeds, constants.cost_params.time, constants.cost_params.complexity, {
            track_resources = {},
            raw_bills = bills,
            ing_overrides = context_costs.overrides_view(info, context, context_costs.data_overrides()),
            use_data = true,
            item_recipe_maps = item_recipe_maps,
        })
        local novelty = {}
        for id, cost in pairs(costs.material_to_cost) do
            local bill = costs.material_to_resources[id]
            if bill ~= nil and bill.newer ~= nil and cost > 0 then
                novelty[id] = math.min(1, bill.newer / cost)
            end
        end
        set.novelty[view_key] = novelty
    end
    return set.novelty[view_key]
end

-- The costs derived for this game (set by graph_cost.derive_cost_options), for recipe randomization to price with
context_costs.current = nil

return context_costs

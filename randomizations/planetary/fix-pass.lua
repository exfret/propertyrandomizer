-- Fix pass (prototype, 2026-09-30): repairs what planetary moves broke, before unified randomization, by changing what unified's handlers change, chosen for repair rather than at random
-- Where: a staged sort (lib/graph/staged-sort.lua) of the game the moves left, in which every slot a handler claims (and every technology's research trigger) can be emptied behind a gate
-- The gates open from the least to the most invasive kind of change (STAGES), so the failing goals' earliest-provider witnesses empty a slot only where nothing reached before its gate works
-- What: each slot a witness empties gets a filler the handler accepts (its validate), had without any repair both where the witness needed it and wherever the slot's dependent is had now (a filler that breaks the dependent elsewhere isn't a repair)
-- The filler that took the old one's place on that planet in the swaps comes first (like the fluid now in lava's ocean slot), then one most like the old filler, and nothing is random
-- Then the fixes are applied (the handlers' own reflect, or directly for ingredients, science packs, triggers and prerequisites), the game is checked again, fixes that broke other goals are undone, and what still fails gets another round, with the slots no filler fits closed
-- The slots of handlers without a fix yet (entity slots, spoiling, first pass's identity moves) and the planetary stages' own repairs open last, so the log says which goals only they could fix
-- Runs with the startup setting propertyrandomizer-planetary-fix-pass (config.planetary_fix_pass, off by default) for each planetary stage it can repair: the stage moves without its own repairs, this repairs it, and if it can't repair everything the stage is undone and runs the old way (run_fix_first in randomizations/planetary/execute.lua)

local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")
local staged = require("lib/graph/staged-sort")
local planetary_check = require("randomizations/planetary/check")
local lu = require("lib/lookup/init")
local surface_sets = require("lib/surface-sets")
local flow_cost = require("lib/cost/flow-cost")
local graph_cost = require("lib/cost/graph-cost")
local constants = require("helper-tables/constants")
local scaffolds = require("randomizations/planetary/scaffolds")
local locks = require("randomizations/planetary/locks")

local fix_pass = {}

local MAX_ROUNDS = 6

-- Stages of the staged sort, from the least to the most invasive kind of change:
--   * root: slots whose old filler the swaps replaced on a planet the dependent was on (like a recipe taking lava on Vulcanus), which get the replacement
--   * local_*: slots of dependents only one planet family had before the moves (a planet's science pack, its locked recipes, a variant), which change nothing elsewhere
--   * shared_*: slots of dependents several planets have, whose change reaches every planet
--   * entity and spoiling: the entity and spoiling handlers' slots, which have no fix yet
--   * planetary_revert: what the planetary stages' own repairs give back (a lock accepting its old planet, a climate edge the game had), which is theirs to decide
--   * identity: any item or fluid had at all, as first pass could put it at some position; no fix yet
local STAGES = {
    "root",
    "local_recipe_category",
    "local_tech_trigger",
    "local_recipe_ingredients",
    "local_other",
    "shared_recipe_category",
    "shared_tech_trigger",
    "shared_recipe_ingredients",
    "shared_other",
    "entity",
    "spoiling",
    "planetary_revert",
    "identity",
}
-- Handler keys (unified's available_handlers) the fix pass claims slots with
local HANDLER_KEYS = {
    "recipe-category",
    "recipe-ingredients",
    "mining-fluid-required",
    "tech-science-packs",
    "entity-energy-source",
    "tech-prereqs",
    "entity",
    "spoiling",
}
-- Handler ids with their own local and shared stages; the rest share local_other and shared_other
local OWN_STAGE = {
    recipe_category = "recipe_category",
    recipe_ingredients = "recipe_ingredients",
    tech_trigger = "tech_trigger",
}
-- Handlers without a fix yet, which open in their own stage
local NO_FIX = {
    entity = true,
    spoiling = true,
}
-- Node types whose old edges from rooms the planetary stages give back themselves (locks and climate)
local PLANETARY_NODE_TYPES = {
    ["recipe-surface-condition"] = true,
    ["entity-build-surface-condition"] = true,
    ["warmth"] = true,
    ["lightning-safe"] = true,
    ["energy-source-electric-production-lightning-existence"] = true,
}

-- Energy sources a machine takes, most like an ordinary machine first, when it can't keep the kind it had
local ENERGY_ORDER = {
    ["energy-source-electric"] = 1,
    ["energy-source-burner"] = 2,
    ["energy-source-fluid"] = 3,
    ["energy-source-heat"] = 4,
    ["energy-source-void"] = 5,
}

-- Trigger sources a technology's research can ask for, with the trigger they make
local TRIGGER_TYPES = {
    ["item-craft"] = "craft-item",
    ["entity-mine"] = "mine-entity",
    ["fluid-craft"] = "craft-fluid",
}

local function sorted_keys(tbl)
    local keys = {}
    for k, _ in pairs(tbl) do
        table.insert(keys, k)
    end
    table.sort(keys)
    return keys
end

local function planet_of_room(room_key)
    local room = gutils.deconstruct(room_key)
    if room.type == "planet" then
        return room.name
    end
    return nil
end

local function joined(tbl, limit)
    local keys = sorted_keys(tbl)
    local parts = {}
    for i = 1, math.min(#keys, limit or #keys) do
        table.insert(parts, keys[i])
    end
    if limit ~= nil and #keys > limit then
        table.insert(parts, "... (" .. #keys .. " in all)")
    end
    return table.concat(parts, ", ")
end

------------------------------------------------------------------------
-- Contexts and closeness
------------------------------------------------------------------------

-- A node's contexts reached before the first gate opened (the game without any repair), as context --> rank
local function unrepaired_contexts(st, node_key)
    local limit = st.stage_starts[STAGES[1]]
    local contexts = {}
    for context, ind in pairs(st.sort_info.node_to_context_inds[node_key] or {}) do
        if ind < limit and top.context_home(context) == nil then
            contexts[context] = ind
        end
    end
    return contexts
end

-- Whether contexts (context --> rank) provide every needed context
local function provides_all(contexts, needed)
    for context, _ in pairs(needed) do
        if not top.provides_context(contexts, context) then
            return false
        end
    end
    return true
end

-- Rooms of the needed contexts, as room key --> true
local function rooms_of(needed)
    local rooms = {}
    for context, _ in pairs(needed) do
        rooms[top.context_room(context)] = true
    end
    return rooms
end

-- How far into the game a node first comes in the given rooms (or anywhere if it's in none of them), as a fraction of the pebbles before limit
local function depth(sort_info, node_key, rooms, limit)
    local best
    local anywhere
    for context, ind in pairs(sort_info.node_to_context_inds[node_key] or {}) do
        if ind < limit then
            if anywhere == nil or ind < anywhere then
                anywhere = ind
            end
            if rooms[top.context_room(context)] ~= nil and (best == nil or ind < best) then
                best = ind
            end
        end
    end
    local ind = best or anywhere
    if ind == nil then
        return nil
    end
    return ind / limit
end

-- Whether a node's unrepaired contexts are all in the given rooms (it's specific to them, like an entity only one planet has)
local function specific_to(contexts, rooms)
    if next(contexts) == nil then
        return false
    end
    for context, _ in pairs(contexts) do
        if rooms[top.context_room(context)] == nil then
            return false
        end
    end
    return true
end

-- Whether the swaps put new_key where old_key was on one of the rooms' planets (params.replacements: planet --> old node key --> new node key)
local function is_replacement(replacements, rooms, old_key, new_key)
    for room_key, _ in pairs(rooms) do
        local planet = planet_of_room(room_key)
        if planet ~= nil and ((replacements or {})[planet] or {})[old_key] == new_key then
            return true
        end
    end
    return false
end

-- The best candidate: a replacement first, then the kind score (lower is closer to the old filler), then the closest (cost or depth), then the name
local function best_of(candidates)
    table.sort(candidates, function(a, b)
        if a.replacement ~= b.replacement then
            return a.replacement
        end
        if a.kind ~= b.kind then
            return a.kind < b.kind
        end
        if a.gap ~= b.gap then
            return a.gap < b.gap
        end
        return a.key < b.key
    end)
    return candidates[1]
end

-- The edge out of a head (its dependent's edge), or nil
local function out_edge(graph, head_key)
    for dep, _ in pairs(graph.nodes[head_key].dep) do
        return dep
    end
    return nil
end

-- The current filler of a head: its vanilla base's owner (the base link may be cut for heads that start detached)
local function owner_of_head(graph, head_key)
    local head = graph.nodes[head_key]
    local base = graph.nodes[head.old_base]
    if base == nil then
        return nil
    end
    return gutils.get_owner(graph, base)
end

-- The planet families (and other rooms) a node was had in before the moves, as room key --> true; a node the game before didn't have (a variant, a technology copy) has none
local function families_before(params, node_key)
    local families = {}
    for context, _ in pairs(params.before.sort_info.node_to_context_inds[node_key] or {}) do
        local room = top.context_room(context)
        if gutils.deconstruct(room).type == "planet" then
            families[surface_sets.family_of(room)] = true
        else
            families[room] = true
        end
    end
    return families
end

-- The material an ingredient slot's old filler stands for (the fluid of a fluid temperature range)
local function material_of(owner)
    if owner.type == "fluid-temperature-range" then
        return "fluid", owner.fluid or owner.name
    end
    return owner.type, owner.name
end

------------------------------------------------------------------------
-- Candidates, per kind of slot
------------------------------------------------------------------------

-- What every candidate search shares: the needed contexts (where the witness needed the slot, and where its dependent is had now), their rooms, and where the old filler came in the game before the moves
local function slot_context(params, st, dep_key, needed, old_key)
    local all = {}
    for context, _ in pairs(needed) do
        all[context] = true
    end
    for context, _ in pairs(unrepaired_contexts(st, dep_key)) do
        all[context] = true
    end
    local rooms = rooms_of(needed)
    local before_limit = #params.before.sort_info.sorted + 1
    return {
        all = all,
        rooms = rooms,
        old_depth = old_key ~= nil and depth(params.before.sort_info, old_key, rooms, before_limit) or nil,
        limit = st.stage_starts[STAGES[1]],
    }
end

local function depth_distance(st, sc, node_key)
    local d = depth(st.sort_info, node_key, sc.rooms, sc.limit)
    if d == nil or sc.old_depth == nil then
        return 1
    end
    return math.abs(d - sc.old_depth)
end

-- Crafting machines (anything with crafting categories, the character included) by crafting category, as "type/name" --> true
local crafters_of
local function crafters_by_category()
    if crafters_of == nil then
        crafters_of = {}
        for _, prots in pairs(data.raw) do
            if type(prots) == "table" then
                for _, prot in pairs(prots) do
                    if type(prot) == "table" and prot.crafting_categories ~= nil and prot.name ~= nil then
                        for _, category in pairs(prot.crafting_categories) do
                            crafters_of[category] = crafters_of[category] or {}
                            crafters_of[category][prot.type .. "/" .. prot.name] = true
                        end
                    end
                end
            end
        end
    end
    return crafters_of
end

-- The crafters of any of a category node's crafting categories
local function crafters_of_node(name)
    local crafters = {}
    for _, category in pairs((lu.rcats[name] or { cats = {} }).cats) do
        for crafter, _ in pairs(crafters_by_category()[category] or {}) do
            crafters[crafter] = true
        end
    end
    return crafters
end

-- Whether a category node lets a character craft (its crafting categories include one a character has)
local function hand_craftable(name)
    for crafter, _ in pairs(crafters_of_node(name)) do
        if string.sub(crafter, 1, 10) == "character/" then
            return true
        end
    end
    return false
end

-- Generic handlers: the bases their validate accepts, whose owners are had without repairs wherever needed
local function handler_candidate(params, st, claims, head_key, sc, old_owner)
    local graph = claims.graph
    local handler = claims.head_to_handler[head_key]
    local head = graph.nodes[head_key]
    local old_crafters
    local old_hand
    if handler.id == "recipe_category" then
        old_crafters = crafters_of_node(old_owner.name)
        old_hand = hand_craftable(old_owner.name)
    end
    local seen = {}
    local candidates = {}
    for _, base_key in pairs(claims.handler_to_bases[handler.id] or {}) do
        local base = graph.nodes[base_key]
        local owner = gutils.get_owner(graph, base)
        local owner_key = gutils.key(owner)
        if seen[owner_key] == nil and owner_key ~= gutils.key(old_owner) then
            seen[owner_key] = true
            local ok, valid = pcall(handler.validate, graph, base, head, {
                init_sort = st.sort_info,
            })
            if ok and valid and provides_all(unrepaired_contexts(st, owner_key), sc.all) then
                local kind = 1
                local allowed = true
                if handler.id == "recipe_category" then
                    -- Same crafting categories (only the fluid counts differ) is the closest, then one a machine of the old category crafts too; a recipe that wasn't hand-craftable never becomes so
                    local old_cats = table.concat((lu.rcats[old_owner.name] or { cats = {} }).cats, "+")
                    local new_cats = table.concat((lu.rcats[owner.name] or { cats = {} }).cats, "+")
                    if not old_hand and hand_craftable(owner.name) then
                        allowed = false
                    end
                    local shares_machine = false
                    for crafter, _ in pairs(crafters_of_node(owner.name)) do
                        if old_crafters[crafter] ~= nil and string.sub(crafter, 1, 10) ~= "character/" then
                            shares_machine = true
                        end
                    end
                    kind = (old_cats == new_cats) and 0 or (shares_machine and 1 or 2)
                elseif handler.id == "entity_energy_source" then
                    kind = (owner.type == old_owner.type) and 0 or (ENERGY_ORDER[owner.type] or 9)
                end
                -- A shared recipe only moves to a category one of its machines crafts too
                if sc.shared and handler.id == "recipe_category" and kind > 1 then
                    allowed = false
                end
                if allowed then
                    table.insert(candidates, {
                        key = owner_key,
                        base_key = base_key,
                        gap = depth_distance(st, sc, owner_key),
                        kind = kind,
                        replacement = is_replacement(params.replacements, sc.rooms, gutils.key(old_owner), owner_key),
                    })
                end
            end
        end
    end
    return best_of(candidates)
end

-- The prototype of a material (the item of whatever item class, or the fluid)
local function material_prototype(material_type, name)
    if material_type == "fluid" then
        return (data.raw.fluid or {})[name]
    end
    for class, _ in pairs(defines.prototypes.item) do
        local prots = data.raw[class] or {}
        if prots[name] ~= nil then
            return prots[name]
        end
    end
    return nil
end

-- Material costs of the game the moves left (flow costs, as item ingredients randomization uses them), found once a run from its first sort
-- The fix pass runs before prepare_world derives the game's raw costs (data-final-fixes.lua), so it prices raw materials the same way (graph_cost.build_costs) without setting the game's cost options; costs a compat file set come first, as there
local function material_costs(params, game)
    local raw_costs = table.deepcopy(randomization_info.options.cost.default_cost_table)
    local built = graph_cost.build_costs(game.graph, top.sort(game.graph), gutils.key("planet", constants.starting_planet), game.sort_info, params.logic.contexts)
    for id, cost in pairs(built.raw_costs) do
        if raw_costs[id] == nil then
            raw_costs[id] = cost
        end
    end
    return flow_cost.determine_recipe_item_cost(raw_costs, constants.cost_params.time, constants.cost_params.complexity).material_to_cost
end

-- Recipe ingredients: a material of the same form and the same kind of prototype (a plate for a plate, a science pack for a science pack, a building only for a building), had without repairs wherever needed, closest in cost
-- A blacklisted ingredient or recipe (like lava, which randomization never replaces so its few recipes keep it) only takes what replaced it on that planet
local function ingredient_candidate(params, st, claims, dep_key, sc, old_owner, old_type, old_name)
    local old_key = gutils.key(old_type, old_name)
    local blacklisted = claims.blacklisted["recipe_ingredients"] or {
        pre = {},
        dep = {},
    }
    local only_replacements = blacklisted.pre[gutils.key(old_owner)] ~= nil or blacklisted.pre[old_key] ~= nil or blacklisted.dep[dep_key] ~= nil
    local recipe = data.raw.recipe[gutils.deconstruct(dep_key).name]
    if recipe == nil then
        return nil, only_replacements
    end
    local results = {}
    for _, result in pairs(recipe.results or {}) do
        results[gutils.key(result.type, result.name)] = true
    end
    local costs = params.material_to_cost
    local old_cost = costs[old_type .. "-" .. old_name]
    local old_prot = material_prototype(old_type, old_name)
    local candidates = {}
    for _, node_key in pairs(params.nodes_of_type[old_type] or {}) do
        local node = claims.graph.nodes[node_key]
        if node_key ~= old_key and results[node_key] == nil and not node.spoof then
            local replacement = is_replacement(params.replacements, sc.rooms, old_key, node_key)
            local prot = material_prototype(old_type, node.name)
            local same_kind = prot ~= nil and old_prot ~= nil and prot.type == old_prot.type and (prot.place_result ~= nil) == (old_prot.place_result ~= nil) and (prot.place_as_tile ~= nil) == (old_prot.place_as_tile ~= nil) and not prot.hidden
            -- A shared recipe (made on several planets) changes everywhere, so it only takes what's close to the old ingredient: the same subgroup, within twice or half its cost
            -- A planet variant (sc.variant) is new to one planet only, but still takes something like the old ingredient: the same subgroup, within eight times or an eighth of its cost
            local close = true
            if (sc.shared or sc.variant) and not replacement then
                local cost = costs[old_type .. "-" .. node.name]
                local limit = sc.shared and math.log(2) or math.log(8)
                local same_subgroup = prot ~= nil and old_prot ~= nil and (prot.subgroup == old_prot.subgroup or sc.power)
                close = same_subgroup and cost ~= nil and old_cost ~= nil and cost > 0 and old_cost > 0 and math.abs(math.log(cost) - math.log(old_cost)) <= limit
            end
            if close and (replacement or (not only_replacements and same_kind)) then
                local contexts = unrepaired_contexts(st, node_key)
                if provides_all(contexts, sc.all) then
                    local cost = costs[old_type .. "-" .. node.name]
                    local gap
                    if cost ~= nil and old_cost ~= nil and cost > 0 and old_cost > 0 then
                        gap = math.abs(math.log(cost) - math.log(old_cost))
                    else
                        gap = 10 + depth_distance(st, sc, node_key)
                    end
                    table.insert(candidates, {
                        key = node_key,
                        name = node.name,
                        type = old_type,
                        gap = gap,
                        kind = specific_to(contexts, sc.rooms) and 0 or 1,
                        replacement = replacement,
                    })
                end
            end
        end
    end
    return best_of(candidates), only_replacements
end

-- Research triggers: a trigger source had without repairs wherever needed, preferring one of the old trigger's kind that only the needed planets have
-- Mining something a player builds isn't a trigger in the old one's spirit, so only entities no item places are mined
local function trigger_candidate(params, st, graph, tech_name, sc)
    local tech = data.raw.technology[tech_name]
    local old = tech.research_trigger or {}
    local old_keys = {}
    for _, entity_name in pairs(old.entities or {}) do
        old_keys[gutils.key("entity-mine", entity_name)] = true
    end
    if old.item ~= nil then
        old_keys[gutils.key("item-craft", type(old.item) == "table" and old.item.name or old.item)] = true
    end
    if old.fluid ~= nil then
        old_keys[gutils.key("fluid-craft", old.fluid)] = true
    end
    local before_limit = #params.before.sort_info.sorted + 1
    for old_key, _ in pairs(old_keys) do
        local d = depth(params.before.sort_info, old_key, sc.rooms, before_limit)
        if d ~= nil and (sc.old_depth == nil or d < sc.old_depth) then
            sc.old_depth = d
        end
    end
    local candidates = {}
    for _, node_key in pairs(params.trigger_nodes or {}) do
        local node = graph.nodes[node_key]
        local is_built = node.type == "entity-mine" and lu.buildables ~= nil and lu.buildables[gutils.key("entity", node.name)] ~= nil
        if old_keys[node_key] == nil and not node.spoof and not is_built then
            local contexts = unrepaired_contexts(st, node_key)
            if provides_all(contexts, sc.all) then
                local replacement = false
                for old_key, _ in pairs(old_keys) do
                    if is_replacement(params.replacements, sc.rooms, old_key, node_key) then
                        replacement = true
                    end
                end
                local same_type = TRIGGER_TYPES[node.type] == old.type
                local specific = specific_to(contexts, sc.rooms)
                table.insert(candidates, {
                    key = node_key,
                    name = node.name,
                    type = node.type,
                    gap = depth_distance(st, sc, node_key),
                    kind = (specific and 0 or 2) + (same_type and 0 or 1),
                    replacement = replacement,
                })
            end
        end
    end
    return best_of(candidates)
end

-- Science packs: the set had without repairs wherever needed that shares the most packs with the old one
local function packs_candidate(params, st, claims, sc, old_owner)
    local graph = claims.graph
    -- A pack's name, through the orand in between if there is one
    local function pack_name(pre)
        local start_key = graph.edges[pre].start
        return gutils.deconstruct(graph.orand_to_parent[start_key] or start_key).name
    end
    local old_packs = {}
    for pre, _ in pairs(old_owner.pre) do
        old_packs[pack_name(pre)] = true
    end
    local seen = {}
    local candidates = {}
    for _, base_key in pairs(claims.handler_to_bases["tech_science_packs"] or {}) do
        local owner = gutils.get_owner(graph, graph.nodes[base_key])
        local owner_key = gutils.key(owner)
        if seen[owner_key] == nil and owner_key ~= gutils.key(old_owner) then
            seen[owner_key] = true
            if provides_all(unrepaired_contexts(st, owner_key), sc.all) then
                local shared = 0
                local packs = {}
                for pre, _ in pairs(owner.pre) do
                    local name = pack_name(pre)
                    packs[name] = true
                    if old_packs[name] ~= nil then
                        shared = shared + 1
                    end
                end
                table.insert(candidates, {
                    key = owner_key,
                    packs = packs,
                    gap = depth_distance(st, sc, owner_key),
                    kind = -shared,
                    replacement = false,
                })
            end
        end
    end
    return best_of(candidates)
end

------------------------------------------------------------------------
-- Applying and undoing fixes (each apply returns its undo)
------------------------------------------------------------------------

local function set_ingredient(recipe_name, old_type, old_name, new_type, new_name)
    local recipe = data.raw.recipe[recipe_name]
    local old_ingredients = table.deepcopy(recipe.ingredients)
    local amount
    local kept = {}
    for _, ingredient in pairs(recipe.ingredients or {}) do
        if ingredient.type == old_type and ingredient.name == old_name then
            amount = ingredient.amount
        else
            table.insert(kept, ingredient)
        end
    end
    local merged = false
    for _, ingredient in pairs(kept) do
        if ingredient.type == new_type and ingredient.name == new_name then
            ingredient.amount = ingredient.amount + (amount or 1)
            merged = true
        end
    end
    if not merged then
        table.insert(kept, {
            type = new_type,
            name = new_name,
            amount = amount or 1,
        })
    end
    recipe.ingredients = kept
    return function()
        recipe.ingredients = old_ingredients
    end
end

local function set_trigger(tech_name, candidate)
    local tech = data.raw.technology[tech_name]
    local old = table.deepcopy(tech.research_trigger)
    local trigger_type = TRIGGER_TYPES[candidate.type]
    if trigger_type == "craft-item" then
        tech.research_trigger = {
            type = "craft-item",
            item = candidate.name,
            count = (old ~= nil and old.type == "craft-item" and old.count) or 1,
        }
    elseif trigger_type == "mine-entity" then
        tech.research_trigger = {
            type = "mine-entity",
            entities = {
                candidate.name,
            },
        }
    elseif trigger_type == "craft-fluid" then
        tech.research_trigger = {
            type = "craft-fluid",
            fluid = candidate.name,
            amount = (old ~= nil and old.type == "craft-fluid" and old.amount) or 100,
        }
    end
    return function()
        tech.research_trigger = old
    end
end

local function set_packs(tech_name, packs)
    local tech = data.raw.technology[tech_name]
    local old = table.deepcopy(tech.unit.ingredients)
    local amounts = {}
    local largest = 1
    for _, ingredient in pairs(old) do
        local name = ingredient.name or ingredient[1]
        local amount = ingredient.amount or ingredient[2] or 1
        amounts[name] = amount
        largest = math.max(largest, amount)
    end
    local new = {}
    for _, name in pairs(sorted_keys(packs)) do
        table.insert(new, {
            name,
            amounts[name] or largest,
        })
    end
    tech.unit.ingredients = new
    return function()
        tech.unit.ingredients = old
    end
end

local function drop_prerequisite(tech_name, prereq_name)
    local tech = data.raw.technology[tech_name]
    local old = table.deepcopy(tech.prerequisites)
    local kept = {}
    for _, name in pairs(tech.prerequisites or {}) do
        if name ~= prereq_name then
            table.insert(kept, name)
        end
    end
    tech.prerequisites = kept
    return function()
        tech.prerequisites = old
    end
end

-- The prototype an energy-source slot's entity is, found by name
local function entity_prototype(name)
    for _, prots in pairs(data.raw) do
        if type(prots) == "table" and prots[name] ~= nil and prots[name].energy_source ~= nil then
            return prots[name]
        end
    end
    return nil
end

-- A snapshot of what a generic handler's reflect changes for one head, so it can be undone
local function generic_undo(handler_id, owner)
    if handler_id == "recipe_category" then
        local recipe = data.raw.recipe[owner.name]
        local old_categories = table.deepcopy(recipe.categories)
        local old_category = recipe.category
        return function()
            recipe.categories = old_categories
            recipe.category = old_category
        end
    elseif handler_id == "mining_fluid_required" then
        local resource = data.raw.resource[owner.name]
        if resource == nil then
            return function()
            end
        end
        local old_fluid = resource.minable.required_fluid
        local old_amount = resource.minable.fluid_amount
        return function()
            resource.minable.required_fluid = old_fluid
            resource.minable.fluid_amount = old_amount
        end
    elseif handler_id == "entity_energy_source" then
        local entity = entity_prototype(owner.name)
        if entity == nil then
            return function()
            end
        end
        local old = table.deepcopy(entity.energy_source)
        return function()
            entity.energy_source = old
        end
    end
    return function()
    end
end

-- Technologies unlocking a recipe, sorted
local function unlocking_technologies(recipe_name)
    local technologies = {}
    for _, technology in pairs(data.raw.technology) do
        for _, effect in pairs(technology.effects or {}) do
            if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
                table.insert(technologies, technology.name)
            end
        end
    end
    table.sort(technologies)
    return technologies
end

-- Recipes making an item that places a power producer (an entity whose operation feeds energy-source-electric-production in the logic graph), as recipe name --> true
-- A planet that loses its power may get one of these as a planet copy made from what it has (the user, 2026-09-30: "adding a solar panel or other generator of sorts as a copy to the planet"), so their copies' fillers needn't share the old ingredient's subgroup
local function power_recipes(graph)
    local producers = {}
    local production = graph.nodes[gutils.key("energy-source-electric-production", "")]
    for pre, _ in pairs((production or { pre = {} }).pre) do
        local start = graph.nodes[graph.edges[pre].start]
        if start ~= nil and start.type == "entity-operate" then
            producers[start.name] = true
        end
    end
    local items = {}
    for class, _ in pairs(defines.prototypes.item) do
        for _, item in pairs(data.raw[class] or {}) do
            if item.place_result ~= nil and producers[item.place_result] ~= nil then
                items[item.name] = true
            end
        end
    end
    local recipes = {}
    for _, recipe in pairs(data.raw.recipe) do
        for _, result in pairs(recipe.results or {}) do
            if result.type == "item" and items[result.name] ~= nil then
                recipes[recipe.name] = true
            end
        end
    end
    return recipes
end

-- A planned planet variant of a shared recipe, for a planet that can't make it as it is while other planets need it unchanged (a context conflict): like scaffolds' variants, "Recipe (Planet)" with the planet's icon, locked to that planet alone, unlocked with the original
-- subs: list of { old_type, old_name, new_type, new_name }; returns the undo
local function add_variant(params, recipe_name, planet, subs)
    local recipe = data.raw.recipe[recipe_name]
    local name = "propertyrandomizer-" .. recipe_name .. "-fixed-on-" .. planet
    if data.raw.recipe[name] ~= nil then
        error("variant " .. name .. " exists already")
    end
    local variant = table.deepcopy(recipe)
    variant.name = name
    variant.localised_name = scaffolds.variant_name(recipe, planet)
    local icons = scaffolds.badged_icons(recipe, planet)
    if icons ~= nil then
        variant.icons = icons
        variant.icon = nil
    end
    for _, sub in pairs(subs) do
        local amount
        local kept = {}
        for _, ingredient in pairs(variant.ingredients or {}) do
            if ingredient.type == sub.old_type and ingredient.name == sub.old_name then
                amount = ingredient.amount
            else
                table.insert(kept, ingredient)
            end
        end
        local merged = false
        for _, ingredient in pairs(kept) do
            if ingredient.type == sub.new_type and ingredient.name == sub.new_name then
                ingredient.amount = ingredient.amount + (amount or 1)
                merged = true
            end
        end
        if not merged then
            table.insert(kept, {
                type = sub.new_type,
                name = sub.new_name,
                amount = amount or 1,
            })
        end
        variant.ingredients = kept
    end
    data:extend({
        variant,
    })
    local technologies = unlocking_technologies(recipe_name)
    for _, technology_name in pairs(technologies) do
        table.insert(data.raw.technology[technology_name].effects, {
            type = "unlock-recipe",
            recipe = name,
        })
    end
    locks.fix("recipe", name, {
        [gutils.key("planet", planet)] = true,
    })
    locks.realize()
    params.variants_of[recipe_name] = params.variants_of[recipe_name] or {}
    table.insert(params.variants_of[recipe_name], name)
    return function()
        data.raw.recipe[name] = nil
        for _, technology_name in pairs(technologies) do
            local effects = data.raw.technology[technology_name].effects or {}
            for i = #effects, 1, -1 do
                if effects[i].type == "unlock-recipe" and effects[i].recipe == name then
                    table.remove(effects, i)
                end
            end
        end
        locks.unfix("recipe", name)
        locks.realize()
        local variants = params.variants_of[recipe_name] or {}
        for i = #variants, 1, -1 do
            if variants[i] == name then
                table.remove(variants, i)
            end
        end
    end
end

------------------------------------------------------------------------
-- One round
------------------------------------------------------------------------

-- The staged sort of the game as it is, with every slot behind its stage's gate, except slots closed in earlier rounds (no filler fit, or their fix broke something)
local function where(params, claims)
    local graph = table.deepcopy(claims.graph)
    local relax = {}
    local add = {}
    local slot_of_edge = {}
    -- The stage of a slot: root if its old filler was replaced on a planet the dependent was on, else local or shared by where the dependent was
    local function stage_of_slot(handler_id, dep_owner_key, old_key)
        if NO_FIX[handler_id] then
            return handler_id
        end
        local families = families_before(params, dep_owner_key)
        if old_key ~= nil then
            for family, _ in pairs(families) do
                for room, _ in pairs(surface_sets.family_rooms(family)) do
                    local planet = planet_of_room(room)
                    if planet ~= nil and ((params.replacements or {})[planet] or {})[old_key] ~= nil then
                        return "root"
                    end
                end
            end
        end
        local scope = (#sorted_keys(families) <= 1) and "local_" or "shared_"
        return scope .. (OWN_STAGE[handler_id] or "other")
    end
    -- Handler slots: the edge from each head to its dependent
    for head_key, handler in pairs(claims.head_to_handler) do
        local edge_key = out_edge(graph, head_key)
        if edge_key ~= nil then
            local dep_key = graph.edges[edge_key].stop
            local dep = graph.nodes[dep_key]
            local dep_owner_key = graph.orand_to_parent[dep_key] or dep_key
            local owner = owner_of_head(graph, head_key)
            local slot_id = handler.id .. " | " .. dep_owner_key .. " | " .. (owner ~= nil and gutils.key(owner) or "none")
            if dep.op == "AND" and not dep.spoof and params.closed[slot_id] == nil then
                local old_key
                if owner ~= nil then
                    local material_type, material_name = material_of(owner)
                    old_key = gutils.key(material_type, material_name)
                end
                local stage = stage_of_slot(handler.id, dep_owner_key, old_key)
                table.insert(relax, {
                    edge_key = edge_key,
                    stage = stage,
                })
                slot_of_edge[edge_key] = {
                    stage = stage,
                    head_key = head_key,
                    id = slot_id,
                }
            end
        end
    end
    -- Research triggers: the edge from each technology's trigger node into it
    for node_key, node in pairs(graph.nodes) do
        if node.type == "technology" and node.op == "AND" then
            for pre, _ in pairs(node.pre) do
                local start = graph.nodes[graph.edges[pre].start]
                local slot_id = "tech_trigger | " .. node_key
                if start.type == "technology-trigger" and slot_of_edge[pre] == nil and params.closed[slot_id] == nil then
                    -- Root when a mined entity of the old trigger was replaced on a planet the technology was researched on
                    local old_key
                    local trigger = (data.raw.technology[node.name] or {}).research_trigger or {}
                    for _, entity_name in pairs(trigger.entities or {}) do
                        old_key = gutils.key("entity-mine", entity_name)
                    end
                    local stage = stage_of_slot("tech_trigger", node_key, old_key)
                    table.insert(relax, {
                        edge_key = pre,
                        stage = stage,
                    })
                    slot_of_edge[pre] = {
                        stage = stage,
                        tech_name = node.name,
                        id = slot_id,
                    }
                end
            end
        end
    end
    -- The planetary stages' own repairs: edges from rooms into lock and climate nodes the game before had and this one lacks
    for edge_key, edge in pairs(params.before.graph.edges) do
        local stop = params.before.graph.nodes[edge.stop]
        if stop ~= nil and PLANETARY_NODE_TYPES[stop.type] and graph.nodes[edge.start] ~= nil and graph.nodes[edge.stop] ~= nil and graph.edges[edge_key] == nil then
            table.insert(add, {
                start = edge.start,
                stop = edge.stop,
                stage = "planetary_revert",
            })
        end
    end
    -- Identity: any item or fluid had at all, as first pass could give some position its identity
    local free = gutils.add_node(graph, "base", "fixpass-free")
    free.op = "AND"
    for node_key, node in pairs(graph.nodes) do
        if (node.type == "item" or node.type == "fluid") and node.op == "OR" then
            table.insert(add, {
                start = gutils.key(free),
                stop = node_key,
                stage = "identity",
            })
        end
    end
    local st = staged.sort({
        graph = graph,
        stages = STAGES,
        relax = relax,
        add = add,
        extra = {
            complex_contexts = true,
            home_contexts = true,
            home_sets = planetary_check.home_sets,
        },
    })
    return st, slot_of_edge
end

-- Chooses the fix of one slot a witness empties, or closes the slot when no filler fits; returns the fix or nil
local function choose_fix(params, st, claims, slot, gate_edge_key, needed)
    if slot.tech_name ~= nil then
        local tech_key = gutils.key("technology", slot.tech_name)
        local sc = slot_context(params, st, tech_key, needed, nil)
        local candidate = trigger_candidate(params, st, claims.graph, slot.tech_name, sc)
        if candidate == nil then
            params.closed[slot.id] = true
            log("FIXPASS no filler: tech_trigger " .. slot.tech_name .. " in " .. joined(needed, 6))
            return nil
        end
        return {
            slot_id = slot.id,
            target = "technology trigger: " .. slot.tech_name,
            text = slot.stage .. ": tech_trigger " .. slot.tech_name .. ": " .. candidate.key .. (candidate.replacement and " (replacement)" or ""),
            dep_key = tech_key,
            apply = function()
                return set_trigger(slot.tech_name, candidate)
            end,
        }
    end
    local graph = claims.graph
    local head_key = slot.head_key
    local handler = claims.head_to_handler[head_key]
    local dep_key = graph.edges[gate_edge_key].stop
    local dep_owner_key = graph.orand_to_parent[dep_key] or dep_key
    local old_owner = owner_of_head(graph, head_key)
    if old_owner == nil then
        params.closed[slot.id] = true
        return nil
    end
    local candidate
    local fix = {
        slot_id = slot.id,
        dep_key = dep_owner_key,
    }
    local shared = string.find(slot.stage, "shared_", 1, true) == 1
    if handler.id == "recipe_ingredients" then
        local old_type, old_name = material_of(old_owner)
        local sc = slot_context(params, st, dep_owner_key, needed, gutils.key(old_type, old_name))
        sc.shared = shared
        local only_replacements
        candidate, only_replacements = ingredient_candidate(params, st, claims, dep_owner_key, sc, old_owner, old_type, old_name)
        local recipe_name = gutils.deconstruct(dep_owner_key).name
        -- A shared recipe with nothing that fits everywhere gets a planet variant where the witness needed it, with a filler that planet has (a context conflict), unless it's a furnace's (furnaces pick recipes by ingredient) or a machine's fixed recipe
        local is_fixed = lu.fixed_recipes[recipe_name] ~= nil and next(lu.fixed_recipes[recipe_name]) ~= nil
        if candidate == nil and shared and not only_replacements and not is_fixed and config.fixpass_variants then
            local furnace_made = false
            for _, category in pairs((data.raw.recipe[recipe_name] or {}).categories or { (data.raw.recipe[recipe_name] or {}).category or "crafting" }) do
                for crafter, _ in pairs(crafters_by_category()[category] or {}) do
                    if string.sub(crafter, 1, 8) == "furnace/" then
                        furnace_made = true
                    end
                end
            end
            local requested = false
            if not furnace_made then
                for room, _ in pairs(rooms_of(needed)) do
                    local planet = planet_of_room(room)
                    if planet ~= nil then
                        local room_needed = {}
                        for context, _ in pairs(needed) do
                            if top.context_room(context) == room then
                                room_needed[context] = true
                            end
                        end
                        local vsc = {
                            all = room_needed,
                            rooms = {
                                [room] = true,
                            },
                            old_depth = sc.old_depth,
                            limit = sc.limit,
                            variant = true,
                            power = params.power_recipes[recipe_name] ~= nil,
                        }
                        local variant_candidate = ingredient_candidate(params, st, claims, dep_owner_key, vsc, old_owner, old_type, old_name)
                        if variant_candidate ~= nil then
                            local request_key = recipe_name .. " | " .. planet
                            params.variant_requests[request_key] = params.variant_requests[request_key] or {
                                recipe_name = recipe_name,
                                planet = planet,
                                subs = {},
                                slot_ids = {},
                            }
                            table.insert(params.variant_requests[request_key].subs, {
                                old_type = old_type,
                                old_name = old_name,
                                new_type = variant_candidate.type,
                                new_name = variant_candidate.name,
                            })
                            table.insert(params.variant_requests[request_key].slot_ids, slot.id)
                            requested = true
                        end
                    end
                end
            end
            if requested then
                return nil
            end
        end
        if candidate == nil then
            params.closed[slot.id] = true
            log("FIXPASS no filler: recipe_ingredients " .. recipe_name .. " (" .. old_type .. ": " .. old_name .. (only_replacements and ", blacklisted: replacements only" or "") .. ") in " .. joined(needed, 6))
            return nil
        end
        fix.target = "recipe ingredients: " .. recipe_name
        fix.text = slot.stage .. ": recipe_ingredients " .. recipe_name .. ": " .. old_type .. ": " .. old_name .. " --> " .. candidate.key .. (candidate.replacement and " (replacement)" or "")
        fix.apply = function()
            return set_ingredient(recipe_name, old_type, old_name, candidate.type, candidate.name)
        end
        return fix
    end
    if handler.id == "tech_prereqs" then
        local tech_name = gutils.deconstruct(dep_owner_key).name
        fix.target = "technology prerequisites: " .. tech_name
        fix.text = slot.stage .. ": tech_prereqs " .. tech_name .. ": drops " .. old_owner.name
        fix.apply = function()
            return drop_prerequisite(tech_name, old_owner.name)
        end
        return fix
    end
    local sc = slot_context(params, st, dep_owner_key, needed, gutils.key(old_owner))
    sc.shared = shared
    if handler.id == "tech_science_packs" then
        local tech_name = gutils.deconstruct(dep_owner_key).name
        candidate = packs_candidate(params, st, claims, sc, old_owner)
        if candidate == nil then
            params.closed[slot.id] = true
            log("FIXPASS no filler: tech_science_packs " .. tech_name .. " in " .. joined(needed, 6))
            return nil
        end
        fix.target = "technology packs: " .. tech_name
        fix.text = slot.stage .. ": tech_science_packs " .. tech_name .. ": " .. gutils.key(old_owner) .. " --> " .. candidate.key
        fix.apply = function()
            return set_packs(tech_name, candidate.packs)
        end
        return fix
    end
    candidate = handler_candidate(params, st, claims, head_key, sc, old_owner)
    if candidate == nil then
        params.closed[slot.id] = true
        log("FIXPASS no filler: " .. handler.id .. " " .. dep_owner_key .. " (" .. gutils.key(old_owner) .. ") in " .. joined(needed, 6))
        return nil
    end
    local owner = gutils.get_owner(graph, graph.nodes[head_key])
    fix.target = handler.id .. ": " .. owner.name
    fix.text = slot.stage .. ": " .. handler.id .. " " .. dep_owner_key .. ": " .. gutils.key(old_owner) .. " --> " .. candidate.key .. (candidate.replacement and " (replacement)" or "")
    fix.apply = function()
        local undo = generic_undo(handler.id, owner)
        handler.reflect(graph, {
            [head_key] = candidate.base_key,
        }, claims.head_to_handler)
        return undo
    end
    return fix
end

-- The planetary check's failures the fix pass works on: recipe category contexts aren't among them, since a category is had wherever a machine of it runs, which follows from the recipes and machines that are goals themselves (the user, 2026-09-30: categories needn't be mechanics)
local function goals_of(params, current)
    local goals = {}
    for _, failure in pairs(planetary_check.required_failures(params.before, current, params.variants_of)) do
        if string.find(failure.text, "mechanic recipe-category:", 1, true) ~= 1 then
            table.insert(goals, failure)
        end
    end
    return goals
end

-- Runs rounds of fixes until the planetary goals pass, nothing more can be fixed, or MAX_ROUNDS
-- params: logic, unified (its module, for claim_slots), before (planetary check sort of the game before the moves), variants_of, replacements (planet --> old node key --> new node key)
fix_pass.run = function(params)
    params.closed = {}
    local current = planetary_check.sort(params.logic)
    local failures = goals_of(params, current)
    local start_count = #failures
    if start_count == 0 then
        log("FIXPASS start: nothing to repair")
        return failures
    end
    params.material_to_cost = material_costs(params, current)
    log("FIXPASS priced " .. #sorted_keys(params.material_to_cost) .. " materials")
    log("FIXPASS start: " .. #failures .. " failing goals")
    local applied = {}
    for round = 1, MAX_ROUNDS do
        if #failures == 0 then
            break
        end
        local claims = params.unified.claim_slots(HANDLER_KEYS, {
            ignore_blacklists = true,
        })
        params.power_recipes = power_recipes(current.graph)
        -- Candidate nodes by type (ingredients take nodes of the old ingredient's type), and the nodes a research trigger can ask for, found once a round
        params.nodes_of_type = {}
        params.trigger_nodes = {}
        for _, node_key in pairs(sorted_keys(claims.graph.nodes)) do
            local node = claims.graph.nodes[node_key]
            params.nodes_of_type[node.type] = params.nodes_of_type[node.type] or {}
            table.insert(params.nodes_of_type[node.type], node_key)
            if TRIGGER_TYPES[node.type] ~= nil then
                table.insert(params.trigger_nodes, node_key)
            end
        end
        local st, slot_of_edge = where(params, claims)
        local per_stage = {}
        for _, slot in pairs(slot_of_edge) do
            per_stage[slot.stage] = (per_stage[slot.stage] or 0) + 1
        end
        local slot_parts = {}
        for _, stage in pairs(STAGES) do
            if per_stage[stage] ~= nil then
                table.insert(slot_parts, stage .. " " .. per_stage[stage])
            end
        end
        log("FIXPASS round " .. round .. ": slots by stage " .. table.concat(slot_parts, ", ") .. "; closed " .. #sorted_keys(params.closed))
        -- Which stage made each goal reachable (the most invasive kind of change it needs), with a few examples of each
        local by_stage = {}
        local examples = {}
        for _, failure in pairs(failures) do
            local inds = planetary_check.goal_inds({ failure }, {
                graph = st.graph,
                sort_info = st.sort_info,
            })
            local stage = "not even with every change"
            if #inds > 0 then
                stage = st.stage_of(inds[1]) or "no repair"
            end
            by_stage[stage] = (by_stage[stage] or 0) + 1
            examples[stage] = examples[stage] or {}
            if #examples[stage] < 4 then
                table.insert(examples[stage], failure.text)
            end
        end
        local stage_parts = {}
        local order = { "no repair" }
        for _, stage in pairs(STAGES) do
            table.insert(order, stage)
        end
        table.insert(order, "not even with every change")
        for _, stage in pairs(order) do
            if by_stage[stage] ~= nil then
                table.insert(stage_parts, stage .. " " .. by_stage[stage])
            end
        end
        log("FIXPASS round " .. round .. ": " .. #failures .. " failing goals; the most invasive change each needs: " .. table.concat(stage_parts, ", "))
        for _, stage in pairs(sorted_keys(examples)) do
            log("FIXPASS round " .. round .. " examples needing " .. stage .. ": " .. table.concat(examples[stage], "; "))
        end
        -- Traces of a few goals only identity reaches: every change their witness makes
        if round == 1 then
            local num_traced = 0
            for _, failure in pairs(failures) do
                local inds = planetary_check.goal_inds({ failure }, {
                    graph = st.graph,
                    sort_info = st.sort_info,
                })
                local stage = #inds > 0 and st.stage_of(inds[1]) or nil
                if num_traced < 6 and (stage == "identity" or stage == "planetary_revert") then
                    num_traced = num_traced + 1
                    local parts = {}
                    for _, gate in pairs(st.gates_on_witness(inds)) do
                        if gate.kind == "add" then
                            table.insert(parts, gate.stage .. ": " .. gate.start .. " --> " .. gate.stop)
                        else
                            local edge = claims.graph.edges[gate.edge_key]
                            table.insert(parts, gate.stage .. ": " .. (edge ~= nil and (edge.start .. " --> " .. edge.stop) or gate.edge_key))
                        end
                    end
                    table.sort(parts)
                    log("FIXPASS trace " .. failure.text .. ": " .. table.concat(parts, " | "))
                end
            end
        end
        local goal_inds = planetary_check.goal_inds(failures, {
            graph = st.graph,
            sort_info = st.sort_info,
        })
        -- What: a filler for each slot the witnesses empty
        local used = st.gates_on_witness(goal_inds)
        local fixes = {}
        local needs = {}
        params.variant_requests = {}
        for _, gate_id in pairs(sorted_keys(used)) do
            local gate = used[gate_id]
            local needed = {}
            for context, _ in pairs(gate.contexts) do
                if top.context_home(context) == nil then
                    needed[context] = true
                end
            end
            local slot = gate.kind == "relax" and slot_of_edge[gate.edge_key] or nil
            if gate.kind == "add" then
                needs[gate.stage] = needs[gate.stage] or {}
                needs[gate.stage][gate.stop] = true
            elseif slot ~= nil and NO_FIX[slot.stage] then
                needs[slot.stage] = needs[slot.stage] or {}
                needs[slot.stage][claims.graph.edges[gate.edge_key].stop] = true
            elseif slot ~= nil then
                local fix = choose_fix(params, st, claims, slot, gate.edge_key, needed)
                if fix ~= nil then
                    table.insert(fixes, fix)
                end
            end
        end
        -- One planet variant per recipe and planet, with every substitution its slots asked for
        for _, request_key in pairs(sorted_keys(params.variant_requests)) do
            local request = params.variant_requests[request_key]
            local parts = {}
            for _, sub in pairs(request.subs) do
                table.insert(parts, sub.old_type .. ": " .. sub.old_name .. " --> " .. sub.new_type .. ": " .. sub.new_name)
            end
            table.insert(fixes, {
                slot_id = request.slot_ids[1],
                slot_ids = request.slot_ids,
                target = "variant: " .. request_key,
                text = "variant: " .. request.recipe_name .. " on " .. request.planet .. ": " .. table.concat(parts, ", "),
                dep_key = gutils.key("recipe", request.recipe_name),
                apply = function()
                    return add_variant(params, request.recipe_name, request.planet, request.subs)
                end,
            })
        end
        local need_parts = {}
        for _, stage in pairs(sorted_keys(needs)) do
            table.insert(need_parts, stage .. " " .. #sorted_keys(needs[stage]) .. " (" .. joined(needs[stage], 10) .. ")")
        end
        log("FIXPASS round " .. round .. ": " .. #fixes .. " fixes chosen" .. (#need_parts > 0 and ("; changes on the witnesses the fix pass doesn't make: " .. table.concat(need_parts, "; ")) or ""))
        if #fixes == 0 then
            break
        end
        -- Apply them all, then check the game again
        local round_applied = {}
        for _, fix in pairs(fixes) do
            local ok, undo = pcall(fix.apply)
            if ok then
                fix.undo = undo
                table.insert(round_applied, fix)
                log("FIXPASS fix: " .. fix.text)
            else
                log("FIXPASS fix failed to apply: " .. fix.text .. ": " .. tostring(undo))
            end
        end
        local previous = current
        local previous_failures = failures
        current = planetary_check.sort(params.logic)
        failures = goals_of(params, current)
        -- Fixes that broke goals which passed before the round are undone, with every fix of the same target, newest first
        local was_failing = {}
        for _, failure in pairs(previous_failures) do
            was_failing[failure.text] = true
        end
        local broken = {}
        for _, failure in pairs(failures) do
            if was_failing[failure.text] == nil then
                table.insert(broken, failure)
            end
        end
        if #broken > 0 then
            local path = top.path(previous.graph, planetary_check.goal_inds(broken, previous), previous.sort_info).in_path
            local on_path = {}
            for ind, _ in pairs(path) do
                on_path[previous.sort_info.sorted[ind].node_key] = true
            end
            local bad_targets = {}
            for _, fix in pairs(round_applied) do
                if on_path[fix.dep_key] ~= nil then
                    bad_targets[fix.target] = true
                end
            end
            local num_undone = 0
            for i = #round_applied, 1, -1 do
                local fix = round_applied[i]
                if bad_targets[fix.target] ~= nil then
                    fix.undo()
                    fix.undone = true
                    params.closed[fix.slot_id] = true
                    for _, slot_id in pairs(fix.slot_ids or {}) do
                        params.closed[slot_id] = true
                    end
                    num_undone = num_undone + 1
                    log("FIXPASS undone (it or a fix of the same target broke other goals): " .. fix.text)
                end
            end
            local texts = {}
            for i = 1, math.min(#broken, 5) do
                table.insert(texts, broken[i].text)
            end
            log("FIXPASS round " .. round .. ": " .. #broken .. " goals broke (" .. table.concat(texts, "; ") .. "), " .. num_undone .. " fixes undone")
            if num_undone > 0 then
                current = planetary_check.sort(params.logic)
                failures = goals_of(params, current)
            end
        end
        -- A round that made things worse is undone whole, newest first
        if #failures > #previous_failures then
            for i = #round_applied, 1, -1 do
                local fix = round_applied[i]
                if not fix.undone then
                    fix.undo()
                    fix.undone = true
                    params.closed[fix.slot_id] = true
                end
            end
            current = planetary_check.sort(params.logic)
            failures = goals_of(params, current)
            log("FIXPASS round " .. round .. " undone whole (it made things worse): back to " .. #failures .. " failing goals")
        end
        for _, fix in pairs(round_applied) do
            if not fix.undone then
                table.insert(applied, fix)
            end
        end
        local num_kept = 0
        for _, fix in pairs(round_applied) do
            if not fix.undone then
                num_kept = num_kept + 1
            end
        end
        log("FIXPASS round " .. round .. " done: " .. #previous_failures .. " --> " .. #failures .. " failing goals, " .. num_kept .. " fixes kept")
        if num_kept == 0 and #round_applied == 0 then
            break
        end
    end
    local texts = {}
    for _, failure in pairs(failures) do
        table.insert(texts, failure.text)
    end
    table.sort(texts)
    for i = 1, math.min(#texts, 40) do
        log("FIXPASS still failing: " .. texts[i])
    end
    -- Planet variants (copies) kept, counted apart (the user, 2026-09-30: copies are fine for now, but keep track of how many)
    local variants = {}
    for _, fix in pairs(applied) do
        if string.find(fix.target, "variant: ", 1, true) == 1 then
            table.insert(variants, string.sub(fix.target, 10))
        end
    end
    table.sort(variants)
    log("FIXPASS copies: " .. #variants .. " planet variants kept" .. (#variants > 0 and (" (" .. table.concat(variants, ", ") .. ")") or ""))
    log("FIXPASS result: " .. start_count .. " --> " .. #failures .. " failing goals, " .. #applied .. " fixes kept, " .. #variants .. " of them copies")
    return failures
end

return fix_pass

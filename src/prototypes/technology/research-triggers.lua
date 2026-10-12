-- New research triggers for the research trigger randomization (src/randomizations/unified/handlers/tech-triggers.lua): what can be one, the trigger it makes, and how many a craft trigger asks for
-- An option is { kind = a trigger type (TechnologyTrigger in the 2.1 prototype docs), target = the name it asks for, or nil when it names nothing }
-- Prices are material id ("type-name") --> price, like graph_cost.material_costs_anywhere's

local research_triggers = {}

-- The name an ItemIDFilter or EntityIDFilter asks for (a name, or a table with one)
local function filter_name(filter)
    if type(filter) == "table" then
        return filter.name
    end
    return filter
end
research_triggers.filter_name = filter_name

local function has_flag(prot, flag)
    for _, prot_flag in pairs(prot.flags or {}) do
        if prot_flag == flag then
            return true
        end
    end
    return false
end

-- Whether a new craft trigger can ask for this item: one players hold, not one that's hidden or only in the cursor (blueprints, planners, remotes)
research_triggers.item_ok = function(item)
    return item.hidden ~= true and not has_flag(item, "only-in-cursor") and not has_flag(item, "spawnable")
end

-- Whether a new craft trigger can ask for this fluid
research_triggers.fluid_ok = function(fluid)
    return fluid.hidden ~= true
end

-- Whether a new mine trigger can ask for this entity: one map generation places (it has an autoplace), like ores, rocks, trees and plants
-- Not buildings, since mining one would only be picking up what was just built
research_triggers.mine_ok = function(entity)
    return entity.hidden ~= true and entity.minable ~= nil and entity.autoplace ~= nil
end

-- Whether a new build trigger can ask for this entity: one an item places (placers, from the item's place_result or the entity's placeable_by), not one only planted
research_triggers.build_ok = function(entity, placers)
    return entity.hidden ~= true and placers ~= nil and #placers > 0
end

-- Entity name --> sorted names of the items that place it (an item's place_result, or the entity's placeable_by)
-- items: item name --> item prototype; entities: entity name --> entity prototype
research_triggers.placers = function(items, entities)
    local placer_sets = {}
    local function add(entity_name, item_name)
        if entity_name ~= nil and item_name ~= nil then
            placer_sets[entity_name] = placer_sets[entity_name] or {}
            placer_sets[entity_name][item_name] = true
        end
    end
    for item_name, item in pairs(items) do
        add(item.place_result, item_name)
    end
    for entity_name, entity in pairs(entities) do
        local placeable_by = entity.placeable_by
        -- ItemToPlace or an array of them
        if placeable_by ~= nil and placeable_by.item ~= nil then
            placeable_by = { placeable_by }
        end
        for _, to_place in pairs(placeable_by or {}) do
            if items[to_place.item] ~= nil then
                add(entity_name, to_place.item)
            end
        end
    end
    local placers = {}
    for entity_name, item_set in pairs(placer_sets) do
        local names = {}
        for item_name, _ in pairs(item_set) do
            table.insert(names, item_name)
        end
        table.sort(names)
        placers[entity_name] = names
    end
    return placers
end

-- What meeting a trigger uses up in raw materials, or nil when it uses up nothing priced (mining, capturing a spawner, creating a platform) or a price is missing
-- Building an entity costs its cheapest placing item (placers, from research_triggers.placers)
research_triggers.cost = function(trigger, prices, placers)
    if trigger == nil then
        return nil
    end
    if trigger.type == "craft-item" then
        local price = prices["item-" .. tostring(filter_name(trigger.item))]
        -- CraftItemTechnologyTrigger::count defaults to 1
        return price ~= nil and price * (trigger.count or 1) or nil
    elseif trigger.type == "craft-fluid" then
        local price = prices["fluid-" .. tostring(trigger.fluid)]
        -- CraftFluidTechnologyTrigger::amount defaults to 0, any amount
        return price ~= nil and price * (trigger.amount or 0) or nil
    elseif trigger.type == "build-entity" then
        local cheapest
        for _, item_name in pairs(placers[filter_name(trigger.entity)] or {}) do
            local price = prices["item-" .. item_name]
            if price ~= nil and (cheapest == nil or price < cheapest) then
                cheapest = price
            end
        end
        return cheapest
    elseif trigger.type == "send-item-to-orbit" then
        return prices["item-" .. tostring(filter_name(trigger.item))]
    end
    return nil
end

-- A positive amount with two significant digits, at least 1, like the round counts the game's own triggers ask for (10 copper plates, 50 iron plates, 500 nutrients)
research_triggers.round_amount = function(amount)
    if amount == nil or amount ~= amount or amount < 1.5 then
        return 1
    end
    local unit = 1
    while amount >= 100 * unit do
        unit = 10 * unit
    end
    return math.floor(amount / unit + 0.5) * unit
end

-- How many times the old trigger's count a new craft trigger asks for at most (user, 2026-10-08: cost-matched fluids asked for 260,000 water in place of 50 holmium plates)
local MAX_AMOUNT_FACTOR = 10

-- How many of a material a new craft trigger asks for: about as costly as the old trigger (user, 2026-10-07), but at most MAX_AMOUNT_FACTOR times the old trigger's count, or than one for a trigger that counts nothing
-- Without both costs, a trigger that counted keeps its count, and otherwise it asks for one
research_triggers.matched_amount = function(old_cost, price, old_amount)
    local counted = old_amount ~= nil and old_amount >= 1
    if old_cost == nil or price == nil or price <= 0 then
        if counted then
            return research_triggers.round_amount(old_amount)
        end
        return 1
    end
    return research_triggers.round_amount(math.min(old_cost / price, MAX_AMOUNT_FACTOR * (counted and old_amount or 1)))
end

-- The trigger an option makes for a technology whose trigger was old_trigger
research_triggers.make = function(option, old_trigger, prices, placers)
    local old_cost = research_triggers.cost(old_trigger, prices, placers)
    local old_amount = old_trigger ~= nil and (old_trigger.count or old_trigger.amount) or nil
    if option.kind == "craft-item" then
        return {
            type = "craft-item",
            item = option.target,
            count = research_triggers.matched_amount(old_cost, prices["item-" .. option.target], old_amount),
        }
    elseif option.kind == "craft-fluid" then
        return {
            type = "craft-fluid",
            fluid = option.target,
            amount = research_triggers.matched_amount(old_cost, prices["fluid-" .. option.target], old_amount),
        }
    elseif option.kind == "mine-entity" then
        return {
            type = "mine-entity",
            entities = {
                option.target,
            },
        }
    elseif option.kind == "build-entity" then
        return {
            type = "build-entity",
            entity = option.target,
        }
    elseif option.kind == "capture-spawner" then
        -- Without an entity, capturing any spawner meets it (CaptureSpawnerTechnologyTrigger::entity is optional)
        return {
            type = "capture-spawner",
            entity = option.target,
        }
    elseif option.kind == "create-space-platform" then
        return {
            type = "create-space-platform",
        }
    end
    error("No research trigger for option kind " .. tostring(option.kind))
end

-- Whether an option asks for what a trigger asks for already (for a mine trigger, any one of its entities), so a technology taking it would keep its trigger
research_triggers.matches = function(option, trigger)
    if trigger == nil or option.kind ~= trigger.type then
        return false
    end
    if option.kind == "craft-item" then
        return option.target == filter_name(trigger.item)
    elseif option.kind == "craft-fluid" then
        return option.target == trigger.fluid
    elseif option.kind == "mine-entity" then
        for _, entity_name in pairs(trigger.entities or {}) do
            if entity_name == option.target then
                return true
            end
        end
        return false
    elseif option.kind == "build-entity" then
        return option.target == filter_name(trigger.entity)
    elseif option.kind == "capture-spawner" then
        return option.target == trigger.entity
    end
    return true
end

-- How likely each kind of new trigger is (kind --> weight) for the kinds options have (kind --> true): one more than how many of the game's own triggers are of it, so new triggers look like the game's and a kind it never uses still comes up now and then
research_triggers.kind_weights = function(old_triggers, kinds)
    local weights = {}
    for kind, _ in pairs(kinds) do
        weights[kind] = 1
    end
    for _, trigger in pairs(old_triggers) do
        if weights[trigger.type] ~= nil then
            weights[trigger.type] = weights[trigger.type] + 1
        end
    end
    return weights
end

-- Picks a kind from weights (kind --> weight) among the kinds has_options says still have options, with value a random number in [0, 1); nil if none do
-- Kinds are taken in sorted order, so the same value always picks the same kind
research_triggers.pick_kind = function(weights, has_options, value)
    local kinds = {}
    local total = 0
    for kind, weight in pairs(weights) do
        if has_options(kind) then
            table.insert(kinds, kind)
            total = total + weight
        end
    end
    if #kinds == 0 then
        return nil
    end
    table.sort(kinds)
    local point = value * total
    for _, kind in pairs(kinds) do
        point = point - weights[kind]
        if point < 0 then
            return kind
        end
    end
    return kinds[#kinds]
end

-- Short text for a trigger, for log lines
research_triggers.describe = function(trigger)
    if trigger == nil then
        return "nothing"
    end
    local target
    if trigger.type == "mine-entity" then
        target = table.concat(trigger.entities or {}, "/")
    else
        target = filter_name(trigger.item) or filter_name(trigger.entity) or trigger.fluid
    end
    local amount = trigger.count or trigger.amount
    return trigger.type .. (target ~= nil and (" " .. target) or "") .. (amount ~= nil and (" x" .. tostring(amount)) or "")
end

-- How much each candidate counts by when it first becomes doable (indices: candidate --> its first rank in a sort), relative to when the old trigger did (anchor), favoring what's newly available (user, 2026-10-08)
-- The one just before the anchor counts 1 and each one further back NEARNESS_DECAY times as much; ones at or after it count AFTER_WEIGHT as much, falling off the same way, since they make the technology come later
local NEARNESS_DECAY = 0.85
local AFTER_WEIGHT = 0.5
research_triggers.nearness_weights = function(indices, anchor)
    local before = {}
    local after = {}
    for candidate, index in pairs(indices) do
        if index < anchor then
            table.insert(before, candidate)
        else
            table.insert(after, candidate)
        end
    end
    -- Ties go by candidate, so the weights don't depend on table order
    table.sort(before, function(a, b)
        if indices[a] ~= indices[b] then
            return indices[a] > indices[b]
        end
        return a < b
    end)
    table.sort(after, function(a, b)
        if indices[a] ~= indices[b] then
            return indices[a] < indices[b]
        end
        return a < b
    end)
    local weights = {}
    for k, candidate in pairs(before) do
        weights[candidate] = NEARNESS_DECAY ^ (k - 1)
    end
    for k, candidate in pairs(after) do
        weights[candidate] = AFTER_WEIGHT * NEARNESS_DECAY ^ (k - 1)
    end
    return weights
end

-- Picks a candidate from weights (candidate --> weight), with value a random number in [0, 1); nil if no candidate has weight
-- Candidates are taken in sorted order, so the same value always picks the same one
research_triggers.pick_weighted = function(weights, value)
    local candidates = {}
    local total = 0
    for candidate, weight in pairs(weights) do
        if weight > 0 then
            table.insert(candidates, candidate)
            total = total + weight
        end
    end
    if #candidates == 0 then
        return nil
    end
    table.sort(candidates)
    local point = value * total
    for _, candidate in pairs(candidates) do
        point = point - weights[candidate]
        if point < 0 then
            return candidate
        end
    end
    return candidates[#candidates]
end

-- The name the tech tree rebuild (src/randomizations/rebuild/init.lua) gives the technology unlocking a recipe; a technology already named that is the recipe's research source there
research_triggers.split_name = function(recipe_name)
    return "exfret-rebuilt-" .. recipe_name .. "-suffix"
end

-- Splits each trigger technology unlocking several recipes into one technology per recipe, all with its trigger, so research trigger randomization can give each its own (user, 2026-10-08)
-- With the tech tree rebuild, which gives every recipe its own technology anyway, a whole technology's trigger was copied onto every recipe it unlocked (a technology unlocking 25 versions of a recipe made 25 technologies asking for one stone furnace)
-- A technology keeps its first recipe and its other effects; each other recipe goes to a copy named the way the rebuild names its per-recipe technologies (split_name), which the rebuild then keeps as that recipe's source; a recipe that already has such a technology stays with its technology
-- Changes technologies (name --> technology prototype, like data.raw.technology) in place and returns the new technologies' names, sorted
research_triggers.split_technologies = function(technologies)
    local names = {}
    for name, tech in pairs(technologies) do
        if tech.research_trigger ~= nil then
            table.insert(names, name)
        end
    end
    table.sort(names)
    local created = {}
    for _, name in pairs(names) do
        local tech = technologies[name]
        local kept = {}
        local has_recipe = false
        local changed = false
        for _, effect in pairs(tech.effects or {}) do
            local split_name = effect.type == "unlock-recipe" and research_triggers.split_name(effect.recipe) or nil
            if split_name ~= nil and has_recipe and technologies[split_name] == nil then
                local copy = table.deepcopy(tech)
                copy.name = split_name
                copy.effects = {
                    table.deepcopy(effect),
                }
                -- The copy's name has no locale entry of its own, so it shows as its technology until the rebuild names it after its recipe
                copy.localised_name = table.deepcopy(tech.localised_name) or {"technology-name." .. name}
                copy.localised_description = table.deepcopy(tech.localised_description) or {"technology-description." .. name}
                technologies[split_name] = copy
                table.insert(created, split_name)
                changed = true
            else
                if effect.type == "unlock-recipe" then
                    has_recipe = true
                end
                table.insert(kept, effect)
            end
        end
        if changed then
            tech.effects = kept
        end
    end
    table.sort(created)
    return created
end

return research_triggers

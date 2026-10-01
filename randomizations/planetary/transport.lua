-- Items made shippable where planet goals need it (user, 2026-09-30: "Make it transportable. This can be done by lowering weight or increasing spoil time fairly easily. But only when needed.")
-- A planet goal an attempt of the rest of randomization lost (planetary.check_attempt) may need only an item that's automatable on another planet but can't come to its own: in the logic an item reaches another room only by rocket (lib/logic/concrete.lua: an item-launch node for items no heavier than the rocket lift weight, an item-deliver node for those that last the trip, dutils.survives_trip)
-- transport.blockers finds those items for the lost goals, walking back from each goal's nodes; transport.apply makes them shippable (a weight that fits a full stack in a rocket where it's heavier, a spoil time of twice the trip where it spoils sooner), so the attempt is checked again instead of retried
-- transport.reapply puts those values back after later randomization, which changes weights and spoil times again (randomizations/numerical/item.lua)

local constants = require("helper-tables/constants")
local dutils = require("lib/data-utils")
local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")

local transport = {}

-- How many times the trip an item made to last it lasts (constants.spoil_trip_ticks is the trip the logic assumes)
local SPOIL_TRIPS = 2

-- Item name --> { weight = the weight apply gave it, or nil, spoil_ticks = the spoil time it gave it, or nil }, for reapply
transport.applied = {}

local function sorted_keys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

-- Whether a context's abilities include the ability (top.ISOLATABILITY, top.AUTOMATABILITY)
local function has_ability(context, ability)
    local abilities = top.context_abilities(context)
    return abilities ~= nil and string.sub(abilities, ability, ability) == "1"
end

-- Whether a context counts for a goal that needs automatability or not (home contexts never count)
local function serves(context, needs_automatable)
    return top.context_home(context) == nil and (not needs_automatable or has_ability(context, top.AUTOMATABILITY))
end

-- The items the lost goals need that can't be shipped: walking back from each failure's nodes (its keys) through what lacks the goal's kind of context in its room, every item that is_unshippable(item name) says can't be shipped and that has that kind of context in another room
-- A goal that needs isolatability is skipped, since imports can't help it; the walk stops at what has the goal's kind of context in the room, and at the items it finds, so only what the goals need is changed
-- The failures come from planetary_check.required (each with keys and a context), and sort_info is the sort that found them
-- Returns a sorted list of item names
transport.blockers = function(graph, sort_info, failures, is_unshippable)
    local contexts_of = sort_info.node_to_context_inds
    local found = {}
    for _, failure in pairs(failures) do
        local room = failure.context ~= nil and top.context_room(failure.context) or nil
        if room ~= nil and not has_ability(failure.context, top.ISOLATABILITY) then
            local needs_automatable = has_ability(failure.context, top.AUTOMATABILITY)
            local seen = {}
            local queue = {}
            for _, key in pairs(failure.keys or {}) do
                if graph.nodes[key] ~= nil and seen[key] == nil then
                    seen[key] = true
                    table.insert(queue, key)
                end
            end
            local index = 1
            while index <= #queue do
                local node_key = queue[index]
                index = index + 1
                local node = graph.nodes[node_key]
                local is_here = false
                local is_elsewhere = false
                for context, _ in pairs(contexts_of[node_key] or {}) do
                    if serves(context, needs_automatable) then
                        if top.context_room(context) == room then
                            is_here = true
                        else
                            is_elsewhere = true
                        end
                    end
                end
                local is_blocker = not is_here and is_elsewhere and node.type == "item" and is_unshippable(node.name)
                if is_blocker then
                    found[node.name] = true
                end
                if not is_here and not is_blocker then
                    for pre, _ in pairs(node.pre) do
                        local start = graph.edges[pre].start
                        if seen[start] == nil then
                            seen[start] = true
                            table.insert(queue, start)
                        end
                    end
                end
            end
        end
    end
    return sorted_keys(found)
end

-- Whether the logic lets an item travel between rooms, from its graph: the logic makes an item-deliver node only for items no heavier than the rocket lift weight that last the trip (lib/logic/concrete.lua)
-- Returns a function of an item name, for blockers
transport.unshippable_in = function(graph)
    return function(item_name)
        return graph.nodes[gutils.key("item-deliver", item_name)] == nil
    end
end

-- Makes the items shippable: an item heavier than the rocket lift weight gets the weight that fits a full stack in one rocket, and one that spoils before the trip is over lasts SPOIL_TRIPS trips
-- Returns a line per item for the log
transport.apply = function(item_names, weight_of)
    local rocket_lift_weight = data.raw["utility-constants"].default.default_rocket_lift_weight
    local lines = {}
    for _, item_name in pairs(item_names) do
        local item = dutils.get_prot("item", item_name)
        if item ~= nil then
            local applied = transport.applied[item_name] or {}
            local changes = {}
            local weight = weight_of(item_name)
            if weight ~= nil and weight > rocket_lift_weight then
                applied.weight = math.max(1, math.floor(rocket_lift_weight / (item.stack_size or 1)))
                item.weight = applied.weight
                table.insert(changes, "weight " .. tostring(weight) .. " --> " .. tostring(applied.weight))
            end
            if not dutils.survives_trip(item) then
                applied.spoil_ticks = SPOIL_TRIPS * constants.spoil_trip_ticks
                table.insert(changes, "spoil ticks " .. tostring(item.spoil_ticks) .. " --> " .. tostring(applied.spoil_ticks))
                item.spoil_ticks = applied.spoil_ticks
            end
            if #changes > 0 then
                transport.applied[item_name] = applied
                table.insert(lines, item_name .. " (" .. table.concat(changes, ", ") .. ")")
            end
        end
    end
    return lines
end

-- Puts back what apply gave the items, where later randomization made them heavier or spoil sooner again
-- Returns how many items it changed
transport.reapply = function()
    local num_changed = 0
    for _, item_name in pairs(sorted_keys(transport.applied)) do
        local applied = transport.applied[item_name]
        local item = dutils.get_prot("item", item_name)
        if item ~= nil then
            local is_changed = false
            if applied.weight ~= nil and (item.weight == nil or item.weight > applied.weight) then
                item.weight = applied.weight
                is_changed = true
            end
            if applied.spoil_ticks ~= nil and not dutils.survives_trip(item) then
                item.spoil_ticks = applied.spoil_ticks
                is_changed = true
            end
            if is_changed then
                num_changed = num_changed + 1
            end
        end
    end
    return num_changed
end

return transport

-- Contract an item's placing corridor into research requirements on its acquisition routes.
-- Acquisition OR nodes stay intact. Only real unlocks change; the ordinary graph remains the audit.
local gutils = require("src/lib/graph/graph-utils")
local top = require("src/lib/sort/context-sort")
local logic = require("src/logic/init")
local operation = require("src/logic/builders/operation-requirements")
local bundles = require("src/logic/builders/operation-bundles")
local sources = require("src/logic/builders/operation-sources")

local unlocks = {}
local key = gutils.key

local function ordered(set)
    local result = {}
    for value, _ in pairs(set) do
        table.insert(result, value)
    end
    table.sort(result)
    return result
end

-- Plan and reflect against one finished graph. Callers rebuild and audit after applying it.
-- fixed_recipes excludes recipe unlocks that a fixed machine could bypass.
unlocks.apply = function(graph, sort_info, technologies, recipes, fixed_recipes)
    local items = operation.items(graph)
    local levels = operation.levels(graph, sort_info, true)
    local recipe_gates = {}
    local prerequisites = {}
    local recipe_unlockers = {}
    for name, technology in pairs(technologies) do
        prerequisites[name] = {}
        for _, pre in pairs(technology.prerequisites or {}) do
            prerequisites[name][pre] = true
        end
        for _, effect in pairs(technology.effects or {}) do
            if effect.type == "unlock-recipe" then
                recipe_unlockers[effect.recipe] = true
            end
        end
    end
    local frontier_cache = {}
    local function technology_frontier(ind)
        if frontier_cache[ind] == nil then
            local result = {}
            local node = graph.nodes[sort_info.pebble_keys[ind]]
            if node.type == "technology" then
                result[node.name] = true
            else
                local path = top.path(graph, { ind }, sort_info, {
                    stop_if = function(node_key)
                        return graph.nodes[node_key].type == "technology"
                    end,
                })
                for pre, _ in pairs(path.in_path) do
                    local source = graph.nodes[sort_info.pebble_keys[pre]]
                    if source.type == "technology" then
                        result[source.name] = true
                    end
                end
            end
            frontier_cache[ind] = result
        end
        return frontier_cache[ind]
    end
    local support_cache = {}
    local function support(name)
        if support_cache[name] == nil then
            local inds = {}
            for _, ind in pairs(sort_info.node_to_context_inds[key("technology", name)] or {}) do
                table.insert(inds, ind)
            end
            local result = {}
            if #inds > 0 then
                for pre, _ in pairs(top.path(graph, inds, sort_info).in_path) do
                    result[sort_info.pebble_keys[pre]] = true
                end
            end
            support_cache[name] = result
        end
        return support_cache[name]
    end
    local function reaches(start, target, seen)
        if start == target then
            return true
        end
        if seen[start] then
            return false
        end
        seen[start] = true
        for pre, _ in pairs(prerequisites[start] or {}) do
            if reaches(pre, target, seen) then
                return true
            end
        end
        -- Research can require a newly gated recipe without an explicit technology edge.
        for node_key, _ in pairs(support(start)) do
            local node = graph.nodes[node_key]
            local gate = node.type == "recipe" and recipe_gates[node.name] or nil
            if gate ~= nil and reaches(gate, target, seen) then
                return true
            end
        end
        return false
    end
    local function needs(start, node_key, seen)
        if seen[start] then
            return false
        end
        seen[start] = true
        if support(start)[node_key] ~= nil then
            return true
        end
        for pre, _ in pairs(prerequisites[start] or {}) do
            if needs(pre, node_key, seen) then
                return true
            end
        end
        for pre_key, _ in pairs(support(start)) do
            local node = graph.nodes[pre_key]
            local gate = node.type == "recipe" and recipe_gates[node.name] or nil
            if gate ~= nil and needs(gate, node_key, seen) then
                return true
            end
        end
        return false
    end
    local function covers(name, node_key)
        local contexts = sort_info.node_to_context_inds[key("technology", name)] or {}
        for context, _ in pairs(sort_info.node_to_context_inds[node_key] or {}) do
            if contexts[context] == nil then
                return false
            end
        end
        return true
    end
    local result = {
        checked = 0,
        covered = 0,
        changed = 0,
        new_technologies = {},
        unresolved = {},
    }
    local function can_gate(node)
        if node.type == "technology" then
            return technologies[node.name] ~= nil
        end
        return node.type == "recipe" and recipes[node.name] ~= nil
            and (recipe_gates[node.name] ~= nil or (recipes[node.name].enabled ~= false and not recipe_unlockers[node.name]))
            and next((fixed_recipes or {})[node.name] or {}) == nil
    end
    for _, item_key in pairs(ordered(items)) do
        local arrival, context = operation.first(sort_info, item_key)
        if context ~= nil then
            result.checked = result.checked + 1
            local compiled = bundles.compile(graph, item_key, items[item_key])
            local proof = bundles.prove(compiled, sort_info, context, levels)
            local requirements = {}
            if proof ~= nil then
                for ind, _ in pairs(proof.leaves) do
                    for name, _ in pairs(technology_frontier(ind)) do
                        requirements[name] = true
                    end
                end
            end
            local plan
            if proof ~= nil and proof.rank > levels[arrival] and next(requirements) ~= nil then
                plan = sources.plan(graph, item_key, can_gate, function(node)
                    local node_key = key(node)
                    local gate_name = node.type == "technology" and node.name or recipe_gates[node.name]
                    if node.type == "recipe" and gate_name == nil
                        and technologies["propertyrandomizer-operation-" .. node.name .. "-unlock"] ~= nil then
                        return false
                    end
                    for name, _ in pairs(requirements) do
                        -- One research can unlock both the item and its operating supplies.
                        if name ~= gate_name then
                            if not covers(name, node_key) or needs(name, node_key, {})
                                or (gate_name ~= nil and reaches(name, gate_name, {})) then
                                return false
                            end
                        end
                    end
                    return true
                end)
            end
            -- Each gate can be safe on its own while two gates create a cycle together.
            -- Check the whole proposed set before changing any prototype.
            if plan ~= nil and not plan.ungated then
                local added = {}
                for gate_key, _ in pairs(plan.gates) do
                    local node = graph.nodes[gate_key]
                    local name = node.type == "technology" and node.name or recipe_gates[node.name]
                    if name ~= nil then
                        for pre, _ in pairs(requirements) do
                            if pre ~= name and prerequisites[name][pre] == nil then
                                if reaches(pre, name, {}) then
                                    plan.ungated = true
                                    plan.reason = "acquisition gates would form a research cycle"
                                    break
                                end
                                prerequisites[name][pre] = true
                                table.insert(added, {
                                    name = name,
                                    pre = pre,
                                })
                            end
                        end
                    end
                    if plan.ungated then
                        break
                    end
                end
                for _, edge in pairs(added) do
                    prerequisites[edge.name][edge.pre] = nil
                end
            end
            if proof == nil or (plan ~= nil and plan.ungated) then
                table.insert(result.unresolved, {
                    item = item_key,
                    reason = proof == nil and "no operation proof" or plan.reason,
                })
            else
                result.covered = result.covered + 1
                for _, gate_key in pairs(ordered(plan ~= nil and plan.gates or {})) do
                    local node = graph.nodes[gate_key]
                    local name = node.name
                    if node.type == "recipe" then
                        name = recipe_gates[node.name]
                        if name == nil then
                            name = "propertyrandomizer-operation-" .. node.name .. "-unlock"
                            -- Never replace a prototype belonging to another producer.
                            if technologies[name] ~= nil then
                                table.insert(result.unresolved, {
                                    item = item_key,
                                    reason = "unlock name already exists: " .. name,
                                })
                                name = nil
                            else
                                local source = technologies[ordered(requirements)[1]]
                                local technology = {
                                    type = "technology",
                                    name = name,
                                    localised_name = recipes[node.name].localised_name or { "recipe-name." .. node.name },
                                    icon = source.icon,
                                    icon_size = source.icon_size,
                                    icons = table.deepcopy(source.icons),
                                    unit = table.deepcopy(source.unit),
                                    research_trigger = table.deepcopy(source.research_trigger),
                                }
                                technology.effects = {
                                    {
                                        type = "unlock-recipe",
                                        recipe = node.name,
                                    },
                                }
                                technologies[name] = technology
                                prerequisites[name] = {}
                                recipe_gates[node.name] = name
                                recipes[node.name].enabled = false
                                table.insert(result.new_technologies, technology)
                                result.changed = result.changed + 1
                            end
                        end
                    end
                    if name ~= nil then
                        for pre, _ in pairs(requirements) do
                            if pre ~= name and prerequisites[name][pre] == nil then
                                prerequisites[name][pre] = true
                                result.changed = result.changed + 1
                            end
                        end
                    end
                end
            end
        end
    end
    for name, pres in pairs(prerequisites) do
        technologies[name].prerequisites = ordered(pres)
    end
    return result
end

-- The graph is rebuilt from prototypes after each caller's changes, never from ready-item wrappers.
unlocks.run = function()
    logic.build()
    local sorted = top.sort(logic.graph, nil, nil, {
        complex_contexts = true,
        home_contexts = true,
    })
    local result = unlocks.apply(logic.graph, sorted, data.raw.technology, data.raw.recipe, (lookups or {}).fixed_recipes)
    result.graph = logic.graph
    result.sorted = sorted
    if #result.new_technologies > 0 then
        data:extend(result.new_technologies)
    end
    log("Operation bundles: " .. result.checked .. " items; " .. result.covered .. " covered, " .. #result.unresolved .. " unresolved; " .. result.changed .. " unlock changes")
    for i = 1, math.min(10, #result.unresolved) do
        local failure = result.unresolved[i]
        log("Operation bundles: " .. failure.item .. "; " .. failure.reason)
    end
    return result
end

return unlocks

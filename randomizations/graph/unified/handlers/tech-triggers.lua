-- Research triggers (prototype, 2026-09-30): technologies researched by a trigger trade triggers
-- A technology's trigger is one slot, the edge from its technology-trigger node (an OR over what meets the trigger, lib/logic/concrete.lua) into the technology, and its bases are the trigger technologies' trigger nodes
-- So a technology takes another's trigger as it is (craft this item, mine these entities, launch this item...)
-- A technology forgets its room once researched (context-sort.lua), so the generic shuffle's per-context check doesn't fit it: the technology is had on the platform while no trigger can be met there
-- The search is custom instead, committing each choice through promotion's try_rewires like the spoiling and entity handlers, which re-establishes the trigger slot's own promised pebbles (where the old trigger was met) with the new trigger
-- Half the time a technology tries its own trigger first (stay_chance), like recipe categories, so triggers stay recognizable

local gutils = require("lib/graph/graph-utils")
local rng = require("lib/random/rng")

local tech_triggers = {}

tech_triggers.id = "tech_triggers"

tech_triggers.with_replacement = true

tech_triggers.stay_chance = 0.5

-- Technology name --> its research trigger before any change, since reflect copies triggers between technologies in any order
local old_triggers

tech_triggers.initialize = function()
    old_triggers = {}
    for _, tech in pairs(data.raw.technology) do
        if tech.research_trigger ~= nil then
            old_triggers[tech.name] = table.deepcopy(tech.research_trigger)
        end
    end
end

tech_triggers.claim = function(graph, prereq, dep, edge)
    if prereq.type == "technology-trigger" and dep ~= nil and dep.type == "technology" and old_triggers[dep.name] ~= nil then
        return 1
    end
end

tech_triggers.validate = function(graph, base, head, extra)
    return gutils.get_owner(graph, base).type == "technology-trigger"
end

-- Taking its own trigger keeps a technology's old connection
tech_triggers.stays = function(graph, base, head)
    return gutils.get_owner(graph, base).name == gutils.get_owner(graph, head).name
end

tech_triggers.custom_prereq_search = function(params)
    local graph = params.random_graph
    local prom = params.promotion
    local head_to_base = params.head_to_base
    local key = rng.key({
        id = "tech-triggers",
    })
    -- This handler's heads (a technology's trigger slot) and the trigger nodes' bases they can take, sorted
    local heads = {}
    local bases = {}
    for node_key, node in pairs(graph.nodes) do
        if node.type == "head" and node.old_base ~= nil and graph.nodes[node.old_base] ~= nil then
            local owner = gutils.get_owner(graph, graph.nodes[node.old_base])
            local dep = gutils.unique_depnode(graph, node)
            if owner.type == "technology-trigger" and dep ~= nil and dep.type == "technology" then
                table.insert(heads, node_key)
                bases[node.old_base] = true
            end
        end
    end
    table.sort(heads)
    local base_list = {}
    for base_key, _ in pairs(bases) do
        table.insert(base_list, base_key)
    end
    table.sort(base_list)
    local function rewire(head_key, base_key, should_commit)
        if prom == nil then
            return true
        end
        return prom.try_rewires({
            {
                node_key = head_key,
                remove = prom.pre_keys_of(head_key),
                add = base_key,
            },
        }, should_commit)
    end
    local num_kept = 0
    local num_tried = 0
    local num_moved = 0
    for _, head_key in pairs(heads) do
        local head = graph.nodes[head_key]
        local order = table.deepcopy(base_list)
        rng.shuffle(key, order)
        if rng.value(key) < tech_triggers.stay_chance then
            num_tried = num_tried + 1
            for i, base_key in pairs(order) do
                if base_key == head.old_base then
                    table.remove(order, i)
                    table.insert(order, 1, base_key)
                    break
                end
            end
        end
        local chosen
        for _, base_key in pairs(order) do
            if tech_triggers.validate(graph, graph.nodes[base_key], head) and rewire(head_key, base_key, true) then
                chosen = base_key
                break
            end
        end
        if chosen == nil then
            -- The old trigger always works where it did
            chosen = head.old_base
            rewire(head_key, chosen, true)
        end
        head_to_base[head_key] = chosen
        if chosen == head.old_base then
            num_kept = num_kept + 1
        else
            num_moved = num_moved + 1
            log("Research trigger: " .. gutils.get_owner(graph, head).name .. " takes the trigger of " .. gutils.get_owner(graph, graph.nodes[chosen]).name)
        end
    end
    log("Research triggers: " .. num_moved .. " of " .. #heads .. " technologies took another's trigger, " .. num_kept .. " kept their own (" .. num_tried .. " tried to first)")
    return true
end

tech_triggers.reflect = function(graph, head_to_base, head_to_handler)
    for head_key, base_key in pairs(head_to_base) do
        if head_to_handler[head_key].id == "tech_triggers" then
            local tech = data.raw.technology[gutils.get_owner(graph, graph.nodes[head_key]).name]
            local source = gutils.get_owner(graph, graph.nodes[base_key]).name
            if tech ~= nil and old_triggers[source] ~= nil then
                tech.research_trigger = table.deepcopy(old_triggers[source])
            end
        end
    end
end

return tech_triggers

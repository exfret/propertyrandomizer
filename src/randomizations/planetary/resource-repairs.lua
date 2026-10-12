-- Choose repairs from the world and goals as they are now, so reverting recipe or trigger edits doesn't keep stale witnesses.

local gutils = require("src/lib/graph/graph-utils")
local staged = require("src/lib/sort/staged-sort")
local planetary_check = require("src/randomizations/planetary/check")
local resources = require("src/randomizations/planetary/resources")

local repairs = {}

-- without is a sort with none of the candidates placed. The caller checks the rebuilt game after selecting them.
repairs.select = function(logic, state, candidates, without)
    local failures = planetary_check.required_failures(state.before, without, state.variants_of)
    if #failures == 0 then
        for _, repair in pairs(candidates) do
            resources.remove_repair(repair)
        end
        return {}
    end
    for _, repair in pairs(candidates) do
        resources.add_repair(repair)
    end
    logic.build({
        home_sets = planetary_check.home_sets,
    })
    local repair_of_edge = {}
    local add = {}
    for _, repair in pairs(candidates) do
        local start = gutils.key("room-autoplace", gutils.key("planet", repair.planet_name))
        local stop = gutils.key("entity", repair.resource_name)
        for edge_key, edge in pairs(logic.graph.edges) do
            if edge.start == start and edge.stop == stop and without.graph.edges[edge_key] == nil then
                local extra = {}
                for field, value in pairs(edge) do
                    if field ~= "start" and field ~= "stop" and field ~= "object_type" then
                        extra[field] = table.deepcopy(value)
                    end
                end
                table.insert(add, {
                    start = start,
                    stop = stop,
                    extra = extra,
                    stage = "patch",
                })
                repair_of_edge[start .. " --> " .. stop] = repair
            end
        end
    end
    for _, repair in pairs(candidates) do
        resources.remove_repair(repair)
    end
    local staged_sort = staged.sort({
        graph = without.graph,
        stages = {
            "patch",
        },
        add = add,
        extra = {
            complex_contexts = true,
            home_contexts = true,
            home_sets = planetary_check.home_sets,
        },
    })
    planetary_check.num_sorts = planetary_check.num_sorts + 1
    local with_all = {
        graph = staged_sort.graph,
        sort_info = staged_sort.sort_info,
    }
    local used = {}
    for _, gate in pairs(staged_sort.gates_on_witness(planetary_check.goal_inds(failures, with_all))) do
        if gate.kind == "add" then
            local repair = repair_of_edge[gate.start .. " --> " .. gate.stop]
            if repair ~= nil then
                used[repair] = true
            end
        end
    end
    local kept = {}
    for _, repair in pairs(candidates) do
        if used[repair] ~= nil then
            resources.add_repair(repair)
            table.insert(kept, repair)
        end
    end
    return kept
end

return repairs

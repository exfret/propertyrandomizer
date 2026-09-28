# Adds FPRANK log lines to a copy of monotone-matching.lua: each identity's first-pebble percentile among identities in the vanilla sort, a second vanilla sort (noise baseline) and the final sort, overall and on the starting planet, plus how many early slots its type and cost allow
import sys
f = sys.argv[1]
src = open(f).read()
def ins_after(anchor, text):
    global src
    assert src.count(anchor) == 1, anchor
    src = src.replace(anchor, anchor + text)
def ins_before(anchor, text):
    global src
    assert src.count(anchor) == 1, anchor
    src = src.replace(anchor, text + anchor)

ins_after("""    local exact, recipes = hard_pebbles(graph, sort_info)
""", """    local fprank_vanilla_sort = sort_info
    local fprank_vanilla_sort2 = complex_sort(connect(table.deepcopy(params.unconnected_graph), params, assignment))
""")

ins_before("""    return assignment, debt_goals
end""", """    do
        local start_room = key("planet", require("helper-tables/constants").starting_planet)
        local function first_ranks(si, node_keys, room)
            local ranks = {}
            for _, node_key in pairs(node_keys) do
                local best
                for context, ind in pairs(si.node_to_context_inds[node_key] or {}) do
                    if (room == nil or top.context_room(context) == room) and top.context_home(context) == nil and (best == nil or ind < best) then
                        best = ind
                    end
                end
                ranks[node_key] = best
            end
            return ranks
        end
        local function percentiles(ranks)
            local list = {}
            for k, r in pairs(ranks) do
                table.insert(list, { k = k, r = r })
            end
            table.sort(list, function(a, b) return a.r < b.r end)
            local pct = {}
            for i = 1, #list do
                pct[list[i].k] = (i - 1) / math.max(1, #list - 1)
            end
            return pct
        end
        local function fmt(x)
            if x == nil then
                return "-"
            end
            return string.format("%.3f", x)
        end
        local van = percentiles(first_ranks(fprank_vanilla_sort, travs))
        local van2 = percentiles(first_ranks(fprank_vanilla_sort2, travs))
        local fin = percentiles(first_ranks(sort_info, travs))
        local vanN = percentiles(first_ranks(fprank_vanilla_sort, travs, start_room))
        local van2N = percentiles(first_ranks(fprank_vanilla_sort2, travs, start_room))
        local finN = percentiles(first_ranks(sort_info, travs, start_room))
        local slot_pct = percentiles(first_ranks(fprank_vanilla_sort, params.slot_keys))
        local slot_of = {}
        for slot_key, trav_key in pairs(assignment) do
            slot_of[trav_key] = slot_key
        end
        for _, trav_key in pairs(travs) do
            local trav = params.unconnected_graph.nodes[trav_key]
            local early_ok = 0
            local early_type = 0
            for _, slot_key in pairs(params.slot_keys) do
                local slot = params.unconnected_graph.nodes[slot_key]
                if slot_pct[slot_key] ~= nil and slot_pct[slot_key] <= 1 / 3 and slot.type == trav.type then
                    early_type = early_type + 1
                    if params.pair_ok(slot, trav) then
                        early_ok = early_ok + 1
                    end
                end
            end
            log("FPRANK trav=" .. trav_key .. " old=" .. trav.old_slot .. " new=" .. tostring(slot_of[trav_key]) .. " van=" .. fmt(van[trav_key]) .. " van2=" .. fmt(van2[trav_key]) .. " fin=" .. fmt(fin[trav_key]) .. " vanN=" .. fmt(vanN[trav_key]) .. " van2N=" .. fmt(van2N[trav_key]) .. " finN=" .. fmt(finN[trav_key]) .. " newslot_van=" .. fmt(slot_pct[slot_of[trav_key]]) .. " early_ok=" .. early_ok .. " early_type=" .. early_type)
        end
    end
""")
open(f, "w").write(src)

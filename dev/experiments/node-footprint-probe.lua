-- Read-only headless footprint probe. Install only in an isolated test snapshot.
local top = require("src/lib/sort/context-sort")
local forwarding_audit = require("dev/experiments/forwarding-node-audit")

local probe = {}
probe.install = function(stop_after_matching)
    local original = top.sort
    local seen = {}
    top.sort = function(graph, state, new_conn, extra)
        local result = original(graph, state, new_conn, extra)
        if result.complex == true and result.home_sets ~= nil and state == nil then
            local kind = graph.node_to_orands ~= nil and "or-expanded" or "logic"
            for _, node in pairs(graph.nodes) do
                if node.trav == true then
                    kind = "split-matching"
                    break
                end
            end
            if not seen[kind] then
                local families = {}
                local function family_of(node)
                    return node.pool_only == true and "base-pool-only" or node.type
                end
                local nodes, edges, represented = 0, 0, 0
                for k, node in pairs(graph.nodes) do
                    nodes = nodes + 1
                    local family = family_of(node)
                    local f = families[family] or {
                        nodes = 0,
                        stored = 0,
                        represented = 0,
                    }
                    families[family] = f
                    f.nodes = f.nodes + 1
                    for _, _ in pairs(result.node_to_context_inds[k] or {}) do
                        f.represented = f.represented + 1
                        represented = represented + 1
                    end
                end
                for _, _ in pairs(graph.edges) do edges = edges + 1 end
                for _, k in pairs(result.pebble_keys) do
                    local f = families[family_of(graph.nodes[k])]
                    f.stored = f.stored + 1
                end
                if families["item-deliver"] ~= nil then
                    seen[kind] = true
                    forwarding_audit.report(graph, result, kind)
                    log("NODEPROBE " .. kind .. " nodes=" .. nodes .. " edges=" .. edges
                        .. " stored=" .. #result.pebble_keys .. " represented=" .. represented)
                    local names = {}
                    for family, _ in pairs(families) do
                        table.insert(names, family)
                    end
                    table.sort(names)
                    for _, family in pairs(names) do
                        local f = families[family]
                        log("NODEPROBE " .. kind .. " " .. family .. " nodes=" .. f.nodes
                            .. " stored=" .. f.stored .. " represented=" .. f.represented)
                    end
                end
                if kind == "split-matching" and stop_after_matching == true then
                    error("NODEPROBE_STOP: completed footprint collection")
                end
            end
        end
        return result
    end
end
return probe

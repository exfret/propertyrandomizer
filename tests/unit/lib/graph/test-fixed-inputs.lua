-- Fixed combat alternatives keep the same reachability without one connector per weapon/target pair.
function table.deepcopy(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for k, v in pairs(value) do copy[k] = table.deepcopy(v) end
    return copy
end
function log(_) end
serpent = { block = tostring }

local random_seed = 1
package.loaded["src/lib/random/rng"] = {
    int = function(_, maximum)
        random_seed = (random_seed * 1103515245 + 12345) % 2147483648
        return math.floor(random_seed / 65536) % maximum + 1
    end,
}
local logic = {
    contexts = {},
    type_info = {
        start = {},
        room = { context = "room" },
        item = {},
        ["combat-weapon"] = {},
        ["combat-target"] = {},
        ["combat-encounter"] = {},
        ["entity-kill"] = {},
        ["technology-trigger"] = { research_input = true },
        technology = { context = true, home_carrier = true },
        orand = { relay = true },
        base = { relay = true },
        head = { relay = true },
        ["false"] = {},
    },
}
package.loaded["src/logic/state"] = logic
data = {
    raw = {
        planet = {
            home = { type = "planet", name = "home" },
            away = { type = "planet", name = "away" },
        },
        technology = {
            discovery = {
                effects = {{ type = "unlock-space-location", space_location = "away" }},
            },
        },
    },
}
package.loaded["src/prototypes/data-utils"] = {
    get_prot = function(_, name) return data.raw.planet[name] end,
}

local gutils = require("src/lib/graph/graph-utils")
local top = require("src/lib/sort/context-sort")
local ctx = require("src/logic/contexts/contexts")
local invariants = require("tests/graph-invariants")
local key = gutils.key
local HOME = "planet: home"
local AWAY = "planet: away"

local function node(graph, kind, name, op, extra)
    extra = extra or {}
    extra.op = op
    local node_key = key(gutils.add_node(graph, kind, name, extra))
    if op == "AND" then graph.sources[node_key] = true end
    return node_key
end

local function fixture()
    local graph = { nodes = {}, edges = {}, sources = {} }
    logic.contexts = { [HOME] = true, [AWAY] = true }
    local start = node(graph, "start", "", "AND")
    local home = node(graph, "room", HOME, "OR")
    local away = node(graph, "room", AWAY, "OR")
    gutils.add_edge(graph, start, home)
    local ammo = node(graph, "item", "ammo", "OR")
    gutils.add_edge(graph, home, ammo, { amount = 2 })
    gutils.add_edge(graph, away, ammo, { amount = 2 })
    local never = node(graph, "false", "", "OR")
    local manual = node(graph, "combat-weapon", "manual", "AND")
    local automatic = node(graph, "combat-weapon", "automatic", "AND")
    local unavailable = node(graph, "combat-weapon", "unavailable", "AND")
    gutils.add_edge(graph, ammo, manual)
    gutils.add_edge(graph, ammo, automatic)
    gutils.add_edge(graph, away, automatic)
    gutils.add_edge(graph, never, unavailable)
    local targets = {}
    for _, name in pairs({ "mixed", "manual", "segment", "blocked", "empty", "cycle" }) do
        targets[name] = node(graph, "combat-target", name, "OR", { fixed_inputs = true })
    end
    gutils.add_edge(graph, manual, targets.mixed, { abilities = ctx.LOSES_AUTOMATABILITY })
    gutils.add_edge(graph, automatic, targets.mixed)
    gutils.add_edge(graph, manual, targets.manual, { abilities = ctx.LOSES_AUTOMATABILITY })
    gutils.add_edge(graph, targets.mixed, targets.segment)
    gutils.add_edge(graph, unavailable, targets.blocked)
    gutils.add_edge(graph, targets.cycle, targets.cycle)
    gutils.add_edge(graph, manual, targets.cycle, { abilities = ctx.LOSES_AUTOMATABILITY })
    local kill = node(graph, "entity-kill", "manual", "AND")
    gutils.add_edge(graph, targets.manual, kill)
    gutils.add_edge(graph, home, kill)
    local encounter = node(graph, "combat-encounter", "mixed", "AND", { mechanic = true })
    gutils.add_edge(graph, targets.mixed, encounter)
    gutils.add_edge(graph, targets.segment, encounter)
    local trigger = node(graph, "technology-trigger", "discovery", "OR")
    gutils.add_edge(graph, kill, trigger)
    local discovery = node(graph, "technology", "discovery", "AND")
    gutils.add_edge(graph, trigger, discovery, { abilities = ctx.GAINS_AUTOMATABILITY })
    gutils.add_edge(graph, discovery, away)
    return graph
end

local function count(values)
    local total = 0
    for _, _ in pairs(values) do total = total + 1 end
    return total
end

local function variants()
    local original = fixture()
    local full = table.deepcopy(original)
    local compact = table.deepcopy(original)
    local fixed_edges = 0
    for _, node in pairs(full.nodes) do
        if node.fixed_inputs == true then
            fixed_edges = fixed_edges + node.num_pre
            node.fixed_inputs = nil
        end
    end
    gutils.make_orands(full)
    gutils.make_orands(compact)
    invariants.test(full)
    invariants.test(compact)
    assert(count(full.nodes) - count(compact.nodes) == fixed_edges)
    assert(count(full.edges) - count(compact.edges) == fixed_edges)
    for _, node in pairs(original.nodes) do
        if node.fixed_inputs == true then
            assert(next(compact.node_to_orands[key(node)]) == nil)
            assert(compact.orand_to_parent[key(node)] == nil)
            assert(compact.orand_to_child[key(node)] == nil)
            for edge_key, _ in pairs(node.pre) do
                local before, after = original.edges[edge_key], compact.edges[edge_key]
                assert(after ~= nil, "missing fixed input " .. edge_key)
                for field, value in pairs(before) do assert(after[field] == value) end
                for field, value in pairs(after) do assert(before[field] == value) end
            end
        end
    end
    -- Ordinary OR inputs still get claimable connectors and normal inverse maps.
    local ammo = key("item", "ammo")
    local connector = key("orand", key("room", HOME) .. " --> " .. ammo)
    assert(compact.node_to_orands[ammo][connector])
    assert(compact.orand_to_parent[connector] == ammo)
    assert(compact.orand_to_child[connector] == key("room", HOME))
    local branch = gutils.unique_pre(compact, compact.nodes[connector])
    assert(branch.amount == 2)
    local claimable = table.deepcopy(compact)
    local split = gutils.subdivide_base_head(claimable, gutils.ekey(branch))
    assert(split.base.amount == 2 and split.head.amount == 2)
    invariants.test(claimable)
    return full, compact
end

local comparisons = 0
for seed = 1, 12 do
    local full, compact = variants()
    local homes = top.home_sets(full)
    assert(#homes.ids > 0, "fixture must exercise actual research home contexts")
    for _, options in pairs({
        { complex_contexts = false },
        { complex_contexts = true },
        { complex_contexts = true, home_contexts = true, home_sets = homes },
    }) do
        options.choose_randomly = true
        random_seed = seed
        local expanded_sort = top.sort(full, nil, nil, options)
        random_seed = seed
        local compact_sort = top.sort(compact, nil, nil, options)
        -- Compare represented contexts in both directions, including every surviving noncombat connector.
        for node_key, _ in pairs(compact.nodes) do
            local before = expanded_sort.node_to_context_inds[node_key] or {}
            local after = compact_sort.node_to_context_inds[node_key] or {}
            for context, _ in pairs(before) do assert(after[context] ~= nil, "lost " .. node_key .. " " .. ctx.name(context)) end
            for context, _ in pairs(after) do assert(before[context] ~= nil, "gained " .. node_key .. " " .. ctx.name(context)) end
        end
        local contexts = compact_sort.node_to_context_inds
        assert(next(contexts[key("combat-target", "empty")] or {}) == nil)
        assert(next(contexts[key("combat-target", "blocked")] or {}) == nil)
        if options.complex_contexts then
            assert(contexts[key("combat-target", "manual")][ctx.complex(HOME, ctx.ISOLATED)] ~= nil)
            for context, _ in pairs(contexts[key("combat-target", "manual")]) do
                assert(not ctx.has_ability(ctx.mask(context), ctx.AUTOMATABILITY), "manual attack gained automation")
            end
            assert(contexts[key("combat-target", "mixed")][ctx.complex(AWAY, ctx.ALL_ABILITIES)] ~= nil)
        end
        if options.home_contexts then
            local found_home = false
            for context, _ in pairs(contexts[key("technology", "discovery")]) do
                found_home = found_home or ctx.home_of(context) ~= nil
            end
            assert(found_home, "home comparison must not be vacuous")
        end
        comparisons = comparisons + 1
    end
end
print("fixed inputs: " .. comparisons .. " bidirectional context comparisons passed")

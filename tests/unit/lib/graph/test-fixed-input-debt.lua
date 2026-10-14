-- Fixed OR inputs must preserve late debt reachability and the distinction between a promise and its solvent backing.
function table.deepcopy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for k, v in pairs(value) do result[k] = table.deepcopy(v) end
    return result
end
function log(_) end
serpent = { block = tostring, line = tostring }
local seed = 1
package.loaded["src/lib/random/rng"] = {
    int = function(_, maximum)
        seed = (seed * 1103515245 + 12345) % 2147483648
        return math.floor(seed / 65536) % maximum + 1
    end,
}
local logic = {
    contexts = {},
    type_info = {
        start = {},
        room = { context = "room" },
        ["combat-weapon"] = {},
        ["combat-target"] = {},
        ["combat-encounter"] = {},
        base = { relay = true },
        head = { relay = true },
        orand = { relay = true },
    },
}
package.loaded["src/logic/state"] = logic
package.loaded["src/logic/init"] = logic
package.loaded["src/prototypes/data-utils"] = { get_prot = function() return nil end }
package.loaded["src/logic/builders/recycling-sources"] = { get = function() return {} end }
data = { raw = { technology = {}, planet = {} } }

local gutils = require("src/lib/graph/graph-utils")
local top = require("src/lib/sort/context-sort")
local ctx = require("src/logic/contexts/contexts")
local superpose = require("src/lib/graph/superpose")
local promotion = require("src/randomizations/unified/skeleton/promotion")
local invariants = require("tests/graph-invariants")
local key = gutils.key
local HOME = "planet: home"

local function node(graph, kind, name, op, extra)
    extra = extra or {}
    extra.op = op
    local node_key = key(gutils.add_node(graph, kind, name, extra))
    if op == "AND" then graph.sources[node_key] = true end
    return node_key
end

local function fixture()
    logic.contexts = { [HOME] = true }
    local graph = { nodes = {}, edges = {}, sources = {} }
    local start = node(graph, "start", "", "AND")
    local room = node(graph, "room", HOME, "OR")
    local weapon = node(graph, "combat-weapon", "source", "AND")
    local target = node(graph, "combat-target", "target", "OR", { fixed_inputs = true })
    local encounter = node(graph, "combat-encounter", "encounter", "AND", { mechanic = true })
    gutils.add_edge(graph, start, room)
    gutils.add_edge(graph, room, weapon)
    gutils.add_edge(graph, target, encounter)
    return graph, weapon, target, encounter
end

local function same_contexts(first, second)
    for node_key, contexts in pairs(first.node_to_context_inds) do
        for context, _ in pairs(contexts) do
            assert((second.node_to_context_inds[node_key] or {})[context] ~= nil, "lost " .. node_key .. " " .. ctx.name(context))
        end
    end
    for node_key, contexts in pairs(second.node_to_context_inds) do
        for context, _ in pairs(contexts) do
            assert((first.node_to_context_inds[node_key] or {})[context] ~= nil, "gained " .. node_key .. " " .. ctx.name(context))
        end
    end
end

local checks = 0
for _, changed_abilities in pairs({ false, true }) do
    for run_seed = 1, 6 do
        seed = run_seed
        local current, weapon, target, encounter = fixture()
        local old = table.deepcopy(current)
        gutils.add_edge(old, weapon, target)
        if changed_abilities then
            gutils.add_edge(current, weapon, target, { abilities = ctx.LOSES_AUTOMATABILITY })
        end
        local debt = superpose.union(current, old)
        assert(#debt.not_into_or == 0)
        local compact = table.deepcopy(current)
        gutils.make_orands(compact)
        assert(next(compact.node_to_orands[target]) == nil)
        for _, complex in pairs({ false, true }) do
            local graph = table.deepcopy(compact)
            local before = top.sort(graph, nil, nil, {
                complex_contexts = complex,
                home_contexts = complex,
                choose_randomly = true,
            })
            if not changed_abilities then
                assert(next(before.node_to_context_inds[target]) == nil)
            elseif complex then
                assert(before.node_to_context_inds[target][ctx.complex(HOME, ctx.ISOLATED)] ~= nil)
                assert(before.node_to_context_inds[target][ctx.complex(HOME, ctx.ALL_ABILITIES)] == nil)
            end
            local added, skipped = superpose.add_debt(graph, debt)
            assert(#skipped == 0)
            assert(#added == (changed_abilities and 2 or 1))
            local continued = superpose.continue_through_debt(graph, before, added)
            local fresh = top.sort(graph, nil, nil, {
                complex_contexts = complex,
                home_contexts = complex,
                choose_randomly = true,
            })
            same_contexts(continued, fresh)
            local context = complex and ctx.complex(HOME, ctx.ALL_ABILITIES) or ctx.simple(HOME)
            assert(continued.node_to_context_inds[target][context] ~= nil)
            assert(continued.node_to_context_inds[encounter][context] ~= nil)
            local witness = top.path(graph, { continued.node_to_context_inds[encounter][context] }, continued)
            local has_weapon = false
            for _, rank in pairs(witness.path) do
                has_weapon = has_weapon or continued.pebble_keys[rank] == weapon
            end
            assert(has_weapon, "debt witness must retain its weapon prerequisite")
            invariants.test(graph)
            -- Promotion must recognize the new route without treating debt as a real combat capability.
            local prom = promotion.new({ graph = compact, debt = debt, complex = complex })
            assert(prom.rank(target, context) ~= nil)
            assert(prom.is_solvent(target, context) == (changed_abilities and not complex), "debt-only combat capability became solvent")
            assert(prom.is_solvent(encounter, context) == (changed_abilities and not complex), "encounter forgot its debt")
            if changed_abilities and complex then
                assert(prom.is_solvent(target, ctx.complex(HOME, ctx.ISOLATED)) == true, "existing manual capability became insolvent")
            end
            checks = checks + 1
        end
    end
end
print("fixed input debt: " .. checks .. " cached continuation, witness and solvency comparisons passed")

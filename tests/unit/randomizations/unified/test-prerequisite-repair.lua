-- Run from the mod root: lua tests/unit/randomizations/unified/test-prerequisite-repair.lua
-- Exercise the actual unified chooser with small graphs and a handler that records its choices.
function table.deepcopy(value)
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for k, v in pairs(value) do
        copy[k] = table.deepcopy(v)
    end
    return copy
end
function log(message) end
serpent = { block = tostring }
config = {
    dev_unified = false,
    unified = {},
}
randomization_info = { options = { unified = {} } }
data = { raw = {} }
-- Recipe amounts are checked against the final item prototypes after reflection (src/prototypes/recipes/recipe-item-amounts.lua), which reads the item classes
defines = {
    prototypes = {
        item = {
            item = 0,
        },
    },
}
local logic = {
    contexts = {
        A = true,
        B = true,
    },
    type_info = {},
}
logic.type_info.base = {}
logic.type_info.head = {}
logic.type_info.orand = {}
logic.type_info["false"] = {}
package.loaded["src/logic/init"] = logic
package.loaded["src/logic/state"] = logic
package.loaded["src/lib/random/rng"] = {
    int = function(_, max) return 1 end,
    key = function(value) return value.id end,
    shuffle = function(_, values)
        -- Descending names put the cyclic candidate first.
        table.sort(values, function(a, b) return a > b end)
    end,
}
-- Unused data-stage modules; the graph, subdivision, sorts and promotion are real.
package.loaded["src/randomizations/unified/item-fluid"] = {}
package.loaded["src/randomizations/unified/first-pass"] = {
    execute = function() error("Repair must run before first pass") end,
}
package.loaded["src/randomizations/unified/first-pass-balance"] = {}
package.loaded["src/randomizations/planetary/execute"] = {}
package.loaded["src/randomizations/unified/skeleton/stats"] = {}
package.loaded["tests/consistent-sort"] = {}
-- Derive unused handler module names from the execution module, avoiding another handler catalogue.
local source = assert(io.open("src/randomizations/unified/execute.lua"))
local text = source:read("*a")
source:close()
for path in string.gmatch(text, [[require%("(src/randomizations/unified/handlers/[^"]+)"%)]]) do
    if path ~= "src/randomizations/unified/handlers/default" then
        package.loaded[path] = {}
    end
end

local gutils = require("src/lib/graph/graph-utils")
local superpose = require("src/lib/graph/superpose")
local top = require("src/lib/sort/context-sort")
-- Contexts are numbers (src/logic/contexts/contexts.lua); fixtures write them as their names, a room's name for its simple context (tests/unit/logic/contexts/contexts-for-tests.lua)
local C = require("tests/unit/logic/contexts/contexts-for-tests").C
local default = require("src/randomizations/unified/handlers/default")
local handler = table.deepcopy(default)
local reflected
handler.id = "recipe_category"
handler.claim = function(graph, pre, dep)
    if pre.type == "item" and dep.type == "recipe" then
        return 1
    end
end
handler.validate = function(graph, base, head)
    return gutils.get_owner(graph, base).type == "item"
end
handler.reflect = function(graph, choices)
    reflected = {}
    for head_key, base_key in pairs(choices) do
        local dep = gutils.get_owner(graph, graph.nodes[head_key])
        local pre = gutils.get_owner(graph, graph.nodes[base_key])
        reflected[dep.name] = pre.name
    end
end
handler.preprocess = function() error("Repairs must preserve preprocessing") end
handler.before_heads = function() error("Repairs must preserve recipe shapes") end
package.loaded["src/randomizations/unified/handlers/recipe-category"] = handler
local handler_key = string.gsub(handler.id, "_", "-")
config.unified[handler_key] = true
local unified = require("src/randomizations/unified/execute")

local function world(has_replacement)
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local function node(kind, name, op, extra)
        logic.type_info[kind] = logic.type_info[kind] or {}
        if kind == "room" then
            logic.type_info[kind].context = "room"
        end
        extra = extra or {}
        extra.op = op
        gutils.add_node(graph, kind, name, extra)
        return gutils.key(kind, name)
    end
    local start = node("start", "", "AND")
    graph.sources[start] = true
    local a = node("room", "A", "OR")
    local b = node("room", "B", "OR")
    gutils.add_edge(graph, start, a)
    gutils.add_edge(graph, start, b)
    local old_material = node("item", "old-material", "OR")
    gutils.add_edge(graph, b, old_material)
    local replacement = node("item", "replacement", "OR")
    if has_replacement then
        gutils.add_edge(graph, start, replacement)
    end
    local target = node("recipe", "target", "AND")
    gutils.add_edge(graph, old_material, target)
    local product = node("item", "product", "OR", { mechanic = true })
    gutils.add_edge(graph, target, product)
    local healthy = node("recipe", "healthy", "AND")
    gutils.add_edge(graph, replacement, healthy)
    local later = node("recipe", "later", "AND")
    gutils.add_edge(graph, product, later)
    local cyclic = node("item", "zz-cycle", "OR")
    gutils.add_edge(graph, later, cyclic)
    local sink = node("recipe", "sink", "AND")
    gutils.add_edge(graph, cyclic, sink)
    local old = table.deepcopy(graph)
    gutils.add_edge(old, a, old_material)
    local union = superpose.union(graph, old)
    logic.build = function() logic.graph = table.deepcopy(graph) end
    return graph, {
        graph = union.graph,
        debt_edges = union.debt_edges,
        old_nodes = union.old_nodes,
        is_goal = function(node_key) return node_key == product end,
    }
end

local graph, debt = world(true)
-- Ordinary shuffle exclusions must not block a prerequisite needed by repair mode.
randomization_info.options.unified[handler_key].blacklisted_pre[gutils.key("item", "replacement")] = true
randomization_info.options.unified[handler_key].blacklisted_dep[gutils.key("recipe", "target")] = true
local result = unified.execute({
    repair_only = true,
    handler_keys = { handler_key },
    debt = debt,
})
assert(result ~= false)
assert(reflected.target == "replacement", "The unpaid prerequisite should take an actually reachable earlier material")
assert(reflected.healthy == nil, "A satisfied prerequisite must not be reflected or changed")
assert(reflected.target ~= "zz-cycle", "A product needing the dependent itself must never be selected")
-- Applying the one choice must restore the mechanic in the actual graph without borrowed edges.
gutils.remove_edge(graph, gutils.ekey({
    start = gutils.key("item", "old-material"),
    stop = gutils.key("recipe", "target"),
}))
gutils.add_edge(graph, gutils.key("item", "replacement"), gutils.key("recipe", "target"))
local actual = top.sort(graph)
assert(actual.node_to_context_inds[gutils.key("item", "product")][C("A")] ~= nil)
assert(actual.node_to_context_inds[gutils.key("item", "product")][C("B")] ~= nil)
print("ok - repairs pay an unpaid requirement without changing satisfied prerequisites or choosing a cycle")

graph, debt = world(false)
result = unified.execute({
    repair_only = true,
    handler_keys = { handler_key },
    debt = debt,
})
assert(result ~= false)
assert(reflected.target == nil, "When only borrowed or circular replacements exist, keep the original prerequisite")
print("ok - an unrepairable requirement preserves its original prerequisite")

-- A custom search can leave an earlier handler's snapshot behind, like recipe search before research triggers choose their new backings.
local completed_promises
handler.custom_prereq_search = function(params)
    UNIFIED_PROMISED_PEBBLES = {}
    completed_promises = params.promotion.promised_pebbles()
    return true
end
graph, debt = world(true)
result = unified.execute({
    repair_only = true,
    handler_keys = { handler_key },
    debt = debt,
})
assert(result ~= false and #completed_promises > 0)
assert(#UNIFIED_PROMISED_PEBBLES == #completed_promises, "Audit must snapshot promises after custom searches finish")
for ind, pebble in pairs(completed_promises) do
    local actual_pebble = UNIFIED_PROMISED_PEBBLES[ind]
    assert(actual_pebble.node_key == pebble.node_key and actual_pebble.context == pebble.context and actual_pebble.rank == pebble.rank)
end
print("ok - the built-game audit receives promises from the completed custom searches")

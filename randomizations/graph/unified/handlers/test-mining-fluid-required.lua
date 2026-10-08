-- Plain-Lua regression tests for choosing mining fluids up front (not loaded by the mod)
-- Run from the mod root: lua randomizations/graph/unified/handlers/test-mining-fluid-required.lua
--
-- Resources a, b and c need no fluid in vanilla, and resource u needs fluid y; any of them could take fluid x or y
-- The sort of the game with resources cut off is a stand-in that says which fluids (or other resources' mining) need them

-- Stand-ins for the Factorio environment
function table.deepcopy(tbl)
    if type(tbl) ~= "table" then
        return tbl
    end
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = table.deepcopy(v)
    end
    return copy
end
function log(msg) end
serpent = {
    block = tostring,
    line = tostring,
}
defines = {
    prototypes = {
        item = {
            item = 0,
        },
    },
}
data = {
    raw = {
        resource = {},
    },
}
mods = {}
package.loaded["lib/logic/init"] = {
    type_info = {},
    contexts = {},
}
-- The first of everything: each resource's first working fluid, the resources in the order given, and the smaller goal (2, so 10 tries); every coin flip tries the resource unless a test sets next_values
local next_values = {}
package.loaded["lib/random/rng"] = {
    key = function(params)
        return "unified"
    end,
    int = function(_, max)
        return 1
    end,
    value = function(_)
        return table.remove(next_values, 1) or 0
    end,
    shuffle = function(_, list)
    end,
}

local gutils = require("lib/graph/graph-utils")
local lutils = require("lib/logic/logic-utils")
local mining_fluid_required = require("randomizations/graph/unified/handlers/mining-fluid-required")

local key = gutils.key

local NO_FLUID = "no-fluid-spoof"
local ROOM = "room"
-- The resources' category, set on each so the handler never falls back to a default one
local CATEGORY = "test-rock"

-- The handler's graph after claiming: each resource's head (a, b, c and u unless names says otherwise), fed by its vanilla base (no fluid, or fluid y for u), and a base for each fluid whose own head is a spoofed resource nothing randomizes
local function build(names)
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local function node(node_type, name, op, extra)
        extra = extra or {}
        extra.op = op
        gutils.add_node(graph, node_type, name, extra)
        return key(node_type, name)
    end
    local mcat = lutils.mcat_key(CATEGORY, {
        input = 1,
        output = 0,
    })
    local no_fluid = node("mining-fluid", NO_FLUID, "OR")
    local fluid_x = node("mining-fluid", "x-mining", "AND", {
        fluid = "x",
        mcat = mcat,
    })
    local fluid_y = node("mining-fluid", "y-mining", "AND", {
        fluid = "y",
        mcat = mcat,
    })
    local world = {
        graph = graph,
        heads = {},
        pool = {},
        baseline = {
            node_to_context_inds = {},
        },
    }
    world.names = names or {
        "a",
        "b",
        "c",
        "u",
    }
    for _, name in pairs(world.names) do
        local resource = {
            type = "resource",
            name = name,
            category = CATEGORY,
            minable = {
                mining_time = 1,
                results = {
                    {
                        type = "item",
                        name = name,
                        amount = 1,
                    },
                },
            },
        }
        local vanilla_owner = no_fluid
        if name == "u" then
            resource.minable.required_fluid = "y"
            vanilla_owner = fluid_y
        end
        data.raw.resource[name] = resource
        local mine = node("entity-mine", name, "AND")
        local base = node("base", name, "AND")
        gutils.add_edge(graph, vanilla_owner, base)
        local head = node("head", name, "OR", {
            old_base = base,
        })
        graph.nodes[base].old_head = head
        gutils.add_edge(graph, head, mine)
        world.heads[name] = head
        table.insert(world.pool, base)
        world.baseline.node_to_context_inds[mine] = {
            [ROOM] = 1,
        }
    end
    local option_bases = {}
    for _, fluid_node in pairs({
        fluid_x,
        fluid_y,
    }) do
        local base = node("base", graph.nodes[fluid_node].name, "AND")
        gutils.add_edge(graph, fluid_node, base)
        table.insert(option_bases, base)
    end
    -- The fluids' own bases come first, so each resource's first fluid is x
    for i = #option_bases, 1, -1 do
        table.insert(world.pool, 1, option_bases[i])
    end
    world.fluids = {
        x = fluid_x,
        y = fluid_y,
    }
    for _, fluid_node in pairs({
        no_fluid,
        fluid_x,
        fluid_y,
    }) do
        world.baseline.node_to_context_inds[fluid_node] = {
            [ROOM] = 1,
        }
    end
    return world
end

-- Runs the choice with a stand-in for sort_without: first pass's sort, minus the cut-off mines and whatever unreachable(cut) says needs one of them (cut: mine key --> true)
-- Returns the choice, how many sorts it took, and each sort's cut-off mines and connections
local function choose(world, unreachable)
    local calls = {}
    local heads = {}
    for _, name in pairs(world.names) do
        table.insert(heads, world.heads[name])
    end
    local chosen = mining_fluid_required.choose_up_front({
        heads = heads,
        pool = world.pool,
        random_graph = world.graph,
        baseline_sort = world.baseline,
        sort_without = function(node_keys, connections)
            local cut = {}
            for _, node_key in pairs(node_keys) do
                cut[node_key] = true
            end
            table.insert(calls, {
                cut = cut,
                connections = table.deepcopy(connections or {}),
            })
            local sort_info = table.deepcopy(world.baseline)
            for node_key, _ in pairs(cut) do
                sort_info.node_to_context_inds[node_key] = nil
            end
            for _, node_key in pairs(unreachable(cut)) do
                sort_info.node_to_context_inds[node_key] = nil
            end
            return sort_info
        end,
    })
    return chosen, #calls, calls
end

-- Whether the resource needs a fluid in the choice
local function has_fluid(world, chosen, name)
    local base_key = chosen[world.heads[name]]
    return gutils.get_owner(world.graph, world.graph.nodes[base_key]).name ~= NO_FLUID
end

-- The fluid the resource needs in the choice, or nil
local function fluid_of(world, chosen, name)
    return gutils.get_owner(world.graph, world.graph.nodes[chosen[world.heads[name]]]).fluid
end

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

test("with few resources that could take a fluid, every one is tried, all in one sort, and each keeps a fluid that works", function()
    local world = build()
    local chosen, num_sorts = choose(world, function()
        return {}
    end)
    assert(num_sorts == 1)
    for _, name in pairs(world.names) do
        assert(fluid_of(world, chosen, name) == "x", name)
    end
end)

test("a resource whose first fluid needs it takes another fluid that works", function()
    local world = build()
    -- Fluid x can only be had by mining a
    local chosen, num_sorts = choose(world, function(cut)
        if cut[key("entity-mine", "a")] ~= nil then
            return { world.fluids.x }
        end
        return {}
    end)
    assert(num_sorts == 1)
    assert(fluid_of(world, chosen, "a") == "y")
end)

test("a resource no fluid works for gets none, and the ones that only failed because it was cut off with them get one on their own", function()
    local world = build()
    -- Every fluid needs a's mining, like pumps made of iron
    local chosen, num_sorts, calls = choose(world, function(cut)
        if cut[key("entity-mine", "a")] ~= nil then
            return {
                world.fluids.x,
                world.fluids.y,
            }
        end
        return {}
    end)
    -- One sort for all four, then one for each alone
    assert(num_sorts == 5)
    assert(not has_fluid(world, chosen, "a"))
    for _, name in pairs({
        "b",
        "c",
        "u",
    }) do
        assert(fluid_of(world, chosen, name) == "x", name)
    end
    -- Alone, each has the ones kept before it fed by their fluids rather than cut off: c's sort has b's
    assert(next(calls[2].connections) == nil)
    assert(calls[4].cut[key("entity-mine", "c")] ~= nil and calls[4].connections[world.heads.b] ~= nil)
    assert(calls[4].cut[key("entity-mine", "b")] == nil)
end)

test("a resource that a kept resource's mining needs is dropped", function()
    local world = build()
    -- Every fluid needs c's mining, and a can only be mined while b is
    local chosen, num_sorts = choose(world, function(cut)
        if cut[key("entity-mine", "c")] ~= nil then
            return {
                world.fluids.x,
                world.fluids.y,
            }
        elseif cut[key("entity-mine", "b")] ~= nil then
            return { key("entity-mine", "a") }
        end
        return {}
    end)
    assert(num_sorts == 5)
    assert(has_fluid(world, chosen, "a") and has_fluid(world, chosen, "u"))
    assert(not has_fluid(world, chosen, "b") and not has_fluid(world, chosen, "c"))
end)

test("a fluid only automatable after a resource's own mining is never chosen for it, so the resource never waits on hand work (like stone from rocks until sulfuric acid)", function()
    local world = build()
    local plain = "room | 00"
    local automatable = "room | 01"
    for name, _ in pairs(world.heads) do
        world.baseline.node_to_context_inds[key("entity-mine", name)] = {
            [plain] = 1,
            [automatable] = 5,
        }
    end
    -- Mining with x is automatable only after every resource's own mining is, with y before
    world.baseline.node_to_context_inds[world.fluids.x] = {
        [plain] = 1,
        [automatable] = 9,
    }
    world.baseline.node_to_context_inds[world.fluids.y] = {
        [plain] = 1,
        [automatable] = 2,
    }
    local chosen = choose(world, function()
        return {}
    end)
    -- Without the check, each would have taken x, its first fluid
    for _, name in pairs(world.names) do
        assert(fluid_of(world, chosen, name) == "y", name)
    end
end)

test("each resource that could take a fluid is tried on a coin flip weighted to try 6 + 2 * goal of them, and an untried one needs none, even one that needs one in vanilla", function()
    local world = build({
        "a",
        "b",
        "c",
        "d",
        "e",
        "f",
        "g",
        "h",
        "i",
        "j",
        "k",
        "u",
    })
    -- Twelve could, aiming to try ten, so the chance is 10/12: flips alternate under and over it
    next_values = {
        0.8,
        0.9,
        0.8,
        0.9,
        0.8,
        0.9,
        0.8,
        0.9,
        0.8,
        0.9,
        0.8,
        0.9,
    }
    local chosen, num_sorts = choose(world, function()
        return {}
    end)
    assert(num_sorts == 1)
    for i, name in pairs(world.names) do
        assert(has_fluid(world, chosen, name) == (i % 2 == 1), name)
    end
    assert(not has_fluid(world, chosen, "u"))
    -- A resource that needs none in vanilla keeps its own base
    assert(chosen[world.heads.b] == world.graph.nodes[world.heads.b].old_base)
end)

test("when no fluid works for any resource, none needs one, and the checks stop at the limit", function()
    local world = build({
        "a",
        "b",
        "c",
        "d",
        "e",
        "f",
        "g",
        "h",
        "i",
        "u",
    })
    local chosen, num_sorts = choose(world, function()
        return {
            world.fluids.x,
            world.fluids.y,
        }
    end)
    -- The first sort and seven alone
    assert(num_sorts == 8)
    for _, name in pairs(world.names) do
        assert(not has_fluid(world, chosen, name), name)
    end
end)

test("with one resource tried, a failure isn't sorted again on its own", function()
    local world = build()
    -- Only a is tried
    next_values = {
        0,
        1,
        1,
        1,
    }
    local chosen, num_sorts = choose(world, function()
        return {
            world.fluids.x,
            world.fluids.y,
        }
    end)
    assert(num_sorts == 1)
    assert(not has_fluid(world, chosen, "a"))
end)

print(num_passed .. " tests passed")

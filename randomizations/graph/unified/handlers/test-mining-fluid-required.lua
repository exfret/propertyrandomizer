-- Plain-Lua regression tests for choosing mining fluids up front (not loaded by the mod)
-- Run from the mod root: lua randomizations/graph/unified/handlers/test-mining-fluid-required.lua
--
-- Resources a, b and c need no fluid in vanilla, and resource u needs fluid y; any of them could take fluid x or y
-- The sort of the game with resources cut off is a stand-in that says which fluids need them

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
-- The first of everything: each resource's first fluid, the resources in the order given, and the fewest resources with a fluid (2)
package.loaded["lib/random/rng"] = {
    key = function(params)
        return "unified"
    end,
    int = function(_, max)
        return 1
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

-- The handler's graph after claiming: each resource's head, fed by its vanilla base (no fluid, or fluid y for u), and a base for each fluid whose own head is a spoofed resource nothing randomizes
local function build()
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
    for _, name in pairs({
        "a",
        "b",
        "c",
        "u",
    }) do
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

-- Runs the choice with a stand-in for sort_without: first pass's sort, minus the cut-off mines and the fluids unreachable(cut) says need one of them (cut: mine key --> true)
local function choose(world, unreachable)
    local num_sorts = 0
    local chosen = mining_fluid_required.choose_up_front({
        heads = {
            world.heads.a,
            world.heads.b,
            world.heads.c,
            world.heads.u,
        },
        pool = world.pool,
        random_graph = world.graph,
        baseline_sort = world.baseline,
        sort_without = function(node_keys)
            num_sorts = num_sorts + 1
            local cut = {}
            for _, node_key in pairs(node_keys) do
                cut[node_key] = true
            end
            local sort_info = table.deepcopy(world.baseline)
            for node_key, _ in pairs(cut) do
                sort_info.node_to_context_inds[node_key] = nil
            end
            for _, fluid_key in pairs(unreachable(cut)) do
                sort_info.node_to_context_inds[fluid_key] = nil
            end
            return sort_info
        end,
    })
    return chosen, num_sorts
end

-- Whether the resource needs a fluid in the choice
local function has_fluid(world, chosen, name)
    local base_key = chosen[world.heads[name]]
    return gutils.get_owner(world.graph, world.graph.nodes[base_key]).name ~= NO_FLUID
end

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

test("a few resources get a fluid, the rest need none, and u loses its vanilla fluid unless chosen", function()
    local world = build()
    local chosen, num_sorts = choose(world, function()
        return {}
    end)
    -- One sort per resource tried
    assert(num_sorts == 2)
    assert(has_fluid(world, chosen, "a") and has_fluid(world, chosen, "b"))
    assert(not has_fluid(world, chosen, "c") and not has_fluid(world, chosen, "u"))
    -- A resource that needs no fluid in vanilla keeps its own base
    assert(chosen[world.heads.c] == world.graph.nodes[world.heads.c].old_base)
end)

test("a resource whose fluid needs it (like water needing iron) gives way to the next, while the others keep theirs", function()
    local world = build()
    -- Fluid x, which every resource gets first, can only be had by mining a
    local chosen, num_sorts = choose(world, function(cut)
        if cut[key("entity-mine", "a")] then
            return { world.fluids.x }
        end
        return {}
    end)
    assert(num_sorts == 3)
    assert(not has_fluid(world, chosen, "a"))
    assert(has_fluid(world, chosen, "b") and has_fluid(world, chosen, "c"))
    assert(not has_fluid(world, chosen, "u"))
end)

test("a resource that needs a fluid in vanilla keeps it when too few others could take one", function()
    local world = build()
    -- Fluid x needs every resource, while fluid y needs none
    local chosen = choose(world, function(cut)
        if next(cut) ~= nil then
            return { world.fluids.x }
        end
        return {}
    end)
    assert(not has_fluid(world, chosen, "a") and not has_fluid(world, chosen, "b") and not has_fluid(world, chosen, "c"))
    assert(chosen[world.heads.u] == world.graph.nodes[world.heads.u].old_base)
end)

test("when nothing passes, no resource needs a fluid", function()
    local world = build()
    local chosen = choose(world, function(cut)
        return {
            world.fluids.x,
            world.fluids.y,
        }
    end)
    for name, _ in pairs(world.heads) do
        assert(not has_fluid(world, chosen, name))
    end
end)

print(num_passed .. " tests passed")

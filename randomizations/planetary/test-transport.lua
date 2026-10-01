-- Plain-Lua tests for making items shippable where planet goals need it (randomizations/planetary/transport.lua), not loaded by the mod
-- Run from the mod root: lua randomizations/planetary/test-transport.lua

-- Stand-ins for what transport.lua loads: contexts are written "room | abilities" (isolatability, then automatability) and home contexts end in " @ home id", as in lib/graph/context-sort.lua
local TRIP_TICKS = 1000
package.loaded["helper-tables/constants"] = {
    spoil_trip_ticks = TRIP_TICKS,
}
package.loaded["lib/data-utils"] = {
    survives_trip = function(item)
        local spoil_ticks = item.spoil_ticks or 0
        return spoil_ticks <= 0 or spoil_ticks >= TRIP_TICKS
    end,
    get_prot = function(_, name)
        return data.raw.item[name]
    end,
}
package.loaded["lib/graph/graph-utils"] = {
    key = function(node_type, name)
        return node_type .. ": " .. name
    end,
}
package.loaded["lib/graph/context-sort"] = {
    ISOLATABILITY = 1,
    AUTOMATABILITY = 2,
    context_room = function(context)
        return string.match(context, "^(.-) | ")
    end,
    context_abilities = function(context)
        return string.match(context, " | (%d%d)")
    end,
    context_home = function(context)
        return string.match(context, " @ (.*)$")
    end,
}

local transport = require("randomizations/planetary/transport")

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local LIFT = 1000000
local HOT = "planet: hot"
local COLD = "planet: cold"

-- The game: items with weights (as the logic computes them) and spoil times
local function fresh_data()
    data = {
        raw = {
            ["utility-constants"] = {
                default = {
                    default_rocket_lift_weight = LIFT,
                },
            },
            item = {},
        },
    }
end

-- A toy graph: the belt recipe on the cold planet lost its automatable context; it needs a heavy plate (made automatably on the hot planet only), a gear (fine on the cold planet), goo (spoils, but also made on the cold planet), a scarce item (automatable nowhere), and a part made on the cold planet from fruit (spoils, made automatably on the hot planet only)
-- The heavy plate is made from ore, which spoils and is made automatably on the hot planet only: the plate is what has to travel, not the ore
local function toy()
    local graph = {
        nodes = {},
        edges = {},
    }
    local contexts = {}
    local function node(key, node_type, name, node_contexts)
        graph.nodes[key] = {
            type = node_type,
            name = name,
            pre = {},
        }
        local set = {}
        for _, context in pairs(node_contexts) do
            set[context] = true
        end
        contexts[key] = set
    end
    local function edge(start, stop)
        local edge_key = start .. " --> " .. stop
        graph.edges[edge_key] = {
            start = start,
            stop = stop,
        }
        graph.nodes[stop].pre[edge_key] = true
    end
    node("recipe: belt", "recipe", "belt", {
        HOT .. " | 01",
    })
    node("item: heavy-plate", "item", "heavy-plate", {
        HOT .. " | 01",
        HOT .. " | 11",
    })
    node("item: ore", "item", "ore", {
        HOT .. " | 01",
    })
    node("item: gear", "item", "gear", {
        COLD .. " | 01",
        HOT .. " | 01",
    })
    node("item: goo", "item", "goo", {
        COLD .. " | 01",
        HOT .. " | 01",
    })
    node("item: scarce", "item", "scarce", {
        HOT .. " | 00",
    })
    node("item: part", "item", "part", {})
    node("recipe: part", "recipe", "part", {})
    node("item: fruit", "item", "fruit", {
        HOT .. " | 01",
        -- A home context doesn't count
        COLD .. " | 01 @ home1",
    })
    edge("item: heavy-plate", "recipe: belt")
    edge("item: ore", "item: heavy-plate")
    edge("item: gear", "recipe: belt")
    edge("item: goo", "recipe: belt")
    edge("item: scarce", "recipe: belt")
    edge("item: part", "recipe: belt")
    edge("recipe: part", "item: part")
    edge("item: fruit", "recipe: part")
    local unshippable = {
        ["heavy-plate"] = true,
        ore = true,
        goo = true,
        scarce = true,
        fruit = true,
    }
    return graph, {
        node_to_context_inds = contexts,
    }, function(name)
        return unshippable[name] ~= nil
    end
end

test("only the unshippable items a lost goal needs from another planet are blockers", function()
    local graph, sort_info, is_unshippable = toy()
    local blockers = transport.blockers(graph, sort_info, {
        {
            keys = {
                "recipe: belt",
            },
            context = COLD .. " | 01",
        },
    }, is_unshippable)
    -- The heavy plate and the fruit behind the part; not the ore behind the plate (shipping the plate is enough), the goo (made on the cold planet too) or the scarce item (automatable nowhere)
    assert(#blockers == 2 and blockers[1] == "fruit" and blockers[2] == "heavy-plate")
end)

test("a goal that needs isolatability can't be helped by shipping", function()
    local graph, sort_info, is_unshippable = toy()
    local blockers = transport.blockers(graph, sort_info, {
        {
            keys = {
                "recipe: belt",
            },
            context = COLD .. " | 11",
        },
    }, is_unshippable)
    assert(#blockers == 0)
end)

test("apply lightens heavy items to a stack per rocket and makes spoiling items last two trips, and reapply puts that back", function()
    fresh_data()
    transport.applied = {}
    data.raw.item["heavy-plate"] = {
        name = "heavy-plate",
        stack_size = 100,
    }
    data.raw.item["fruit"] = {
        name = "fruit",
        stack_size = 50,
        spoil_ticks = 600,
    }
    local weights = {
        ["heavy-plate"] = 2 * LIFT,
        fruit = 1000,
    }
    local lines = transport.apply({
        "fruit",
        "heavy-plate",
    }, function(name)
        return weights[name]
    end)
    assert(#lines == 2)
    assert(data.raw.item["heavy-plate"].weight == LIFT / 100 and data.raw.item["heavy-plate"].spoil_ticks == nil)
    assert(data.raw.item["fruit"].spoil_ticks == 2 * TRIP_TICKS and data.raw.item["fruit"].weight == nil)
    -- Later randomization makes them heavy and quick to spoil again
    data.raw.item["heavy-plate"].weight = 3 * LIFT
    data.raw.item["fruit"].spoil_ticks = 10
    assert(transport.reapply() == 2)
    assert(data.raw.item["heavy-plate"].weight == LIFT / 100 and data.raw.item["fruit"].spoil_ticks == 2 * TRIP_TICKS)
    -- Lighter or longer lasting is left alone
    data.raw.item["heavy-plate"].weight = 5
    assert(transport.reapply() == 0 and data.raw.item["heavy-plate"].weight == 5)
end)

test("an item is unshippable when the logic gave it no delivery", function()
    local is_unshippable = transport.unshippable_in({
        nodes = {
            ["item-deliver: gear"] = {},
        },
    })
    assert(not is_unshippable("gear") and is_unshippable("heavy-plate"))
end)

print(num_passed .. " tests passed")

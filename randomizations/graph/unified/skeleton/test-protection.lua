-- Plain-Lua regression tests for which mechanics keep their isolatability (not loaded by the mod)
-- Run from the mod root: lua randomizations/graph/unified/skeleton/test-protection.lua
-- Protection is declared on nodes with keep_isolatability = true where they're built in lib/logic, never matched from node names

-- Stand-ins for the Factorio environment and the context sort
local constants = { keep_isolatability = false }
package.loaded["helper-tables/constants"] = constants
package.loaded["lib/graph/context-sort"] = {
    ISOLATABILITY = 1,
    context_abilities = function(context)
        return string.match(context, " | (.*)$")
    end,
    context_room = function(context)
        return string.match(context, "^(.-) | ") or context
    end,
    -- Home contexts are written like "nauvis | 00 @ home1"
    context_home = function(context)
        return string.match(context, " @ (.*)$")
    end,
    context_without_home = function(context)
        return string.match(context, "^(.-) @ ") or context
    end,
    context_key = function(room, ability_str)
        return room .. " | " .. ability_str
    end,
}
data = {
    raw = {
        lab = {
            lab = {
                inputs = {
                    "automation-science-pack",
                    "alien-goo",
                },
            },
            biolab = {
                inputs = {
                    "automation-science-pack",
                    "agricultural-science-pack",
                },
            },
        },
    },
}

local protection = require("randomizations/graph/unified/skeleton/protection")
local dutils = require("lib/data-utils")

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

-- The node types (and how) lib/logic declares keep_isolatability on, found by scanning each add_node call
-- A toy mechanic node, flagged or not
local function make_node(node_type, name, flagged)
    return {
        type = node_type,
        name = name,
        keep_isolatability = flagged,
    }
end

local function declared_protection()
    local declared = {}
    local files = {
        "abstract",
        "balance",
        "concrete",
        "groups",
        "balance-mechanics",
    }
    for _, file in pairs(files) do
        local handle = assert(io.open("lib/logic/" .. file .. ".lua"))
        local source = handle:read("*a")
        handle:close()
        local pos = 1
        while true do
            local start, stop, node_type = string.find(source, "add_node%(\"([^\"]+)\"", pos)
            if start == nil then
                break
            end
            -- The rest of the call, up to its matching closing parenthesis
            local depth = 1
            local i = stop + 1
            while depth > 0 do
                local char = string.sub(source, i, i)
                if char == "(" then
                    depth = depth + 1
                elseif char == ")" then
                    depth = depth - 1
                end
                i = i + 1
            end
            local value = string.match(string.sub(source, start, i), "keep_isolatability = ([^,\n]+)")
            if value ~= nil then
                declared[node_type] = value
            end
            pos = i
        end
    end
    return declared
end

test("science packs are exactly the lab inputs, whatever their names", function()
    local lab_inputs = dutils.lab_inputs()
    assert(lab_inputs["automation-science-pack"])
    assert(lab_inputs["agricultural-science-pack"])
    assert(lab_inputs["alien-goo"])
    assert(lab_inputs["fake-science-pack"] == nil)
end)

test("lib/logic declares protection on exactly the intended node types", function()
    local declared = declared_protection()
    assert(declared["group-starter-ammo"] == "true")
    assert(declared["balance-gun-turret"] == "true")
    assert(declared["science-pack-set-science"] == "true")
    assert(declared["science-pack-set-lab"] == "true")
    -- Items are protected exactly when they're lab inputs
    assert(declared["item"] == "is_science_pack or nil")
    -- Rocket building (logic node types from lib/logic/abstract.lua and concrete.lua): a planet that could build and launch rockets from its own resources still can
    assert(declared["room-launch"] == "true")
    assert(declared["room-create-platform"] == "true")
    assert(declared["room-create-platform-starter-pack"] == "true")
    assert(declared["create-platform"] == "true")
    assert(declared["rocket-silo"] == "true")
    assert(declared["cargo-landing-pad"] == "true")
    assert(declared["launch"] == "true")
    assert(declared["entity-rocket-silo"] == "true")
    -- Crafting categories are protected exactly when a rocket silo crafts in them
    assert(declared["recipe-category"] == "is_rocket_building or nil")
    local num_declared = 0
    for _, _ in pairs(declared) do
        num_declared = num_declared + 1
    end
    assert(num_declared == 14, "unexpected keep_isolatability declarations")
end)

test("balance starter ammo isn't protected (the unified pipeline doesn't build balance.lua; group-starter-ammo is the starter ammo mechanic)", function()
    assert(declared_protection()["balance-starter-ammo"] == nil)
end)

test("the protected set is exactly the flagged nodes", function()
    local nodes = {
        make_node("item", "automation-science-pack", true),
        make_node("item", "alien-goo", true),
        -- Named like a science pack, but not a lab input, so never flagged
        make_node("item", "fake-science-pack", nil),
        make_node("group-starter-ammo", "", true),
        make_node("balance-starter-ammo", "", nil),
        make_node("science-pack-set-lab", "set", true),
    }
    for _, node in pairs(nodes) do
        local flagged = node.keep_isolatability == true
        assert(protection.protects_isolatability(node) == flagged, node.type .. ": " .. node.name)
        assert(protection.is_hard_mechanic_pebble(node, "nauvis | 11") == flagged, node.type .. ": " .. node.name)
        -- Non-isolatable contexts are always kept
        assert(protection.is_hard_mechanic_pebble(node, "nauvis | 01"))
        assert(protection.kept_part(node, "nauvis | 11") == (flagged and "nauvis | 11" or "nauvis | ?1"))
    end
end)

test("the global switch protects everything", function()
    constants.keep_isolatability = true
    assert(protection.protects_isolatability(make_node("balance-starter-ammo", "", nil)))
    assert(protection.kept_part(make_node("item", "fake-science-pack", nil), "nauvis | 11") == "nauvis | 11")
    constants.keep_isolatability = false
end)

test("home contexts aren't mechanic contexts of their own, even on protected nodes", function()
    for _, is_flagged in pairs({ true, false }) do
        local node = make_node("item", "automation-science-pack", is_flagged)
        assert(not protection.is_hard_mechanic_pebble(node, "nauvis | 00 @ home1"))
        assert(protection.kept_part(node, "nauvis | 00 @ home1") == protection.kept_part(node, "nauvis | 00"))
    end
end)

test("a recipe locked to one planet by surface conditions keeps every context it has there, and no other recipe is locked", function()
    local condition = {
        {
            property = "toy-property",
            min = 1,
        },
    }
    data.raw.recipe = {
        ["locked"] = {
            surface_conditions = condition,
        },
        ["unconditioned"] = {},
        ["empty-conditions"] = {
            surface_conditions = {},
        },
        ["two-planets"] = {
            surface_conditions = condition,
        },
        ["platform-only"] = {
            surface_conditions = condition,
        },
    }
    local graph = {
        nodes = {},
    }
    local nci = {}
    local function add_node(node_type, name, contexts)
        local node_key = node_type .. ": " .. name
        graph.nodes[node_key] = {
            type = node_type,
            name = name,
        }
        nci[node_key] = {}
        for i, context in pairs(contexts) do
            nci[node_key][context] = i
        end
    end
    add_node("recipe", "locked", {
        "planet: rock | 00",
        "planet: rock | 11",
        "planet: rock | 00 @ home1",
    })
    add_node("recipe", "unconditioned", {
        "planet: rock | 00",
    })
    add_node("recipe", "empty-conditions", {
        "planet: rock | 00",
    })
    add_node("recipe", "two-planets", {
        "planet: rock | 00",
        "planet: home | 00",
    })
    add_node("recipe", "platform-only", {
        "surface: platform | 00",
    })
    -- Only recipes are locked, whatever other nodes' contexts
    add_node("item", "locked", {
        "planet: rock | 00",
    })
    local locked = protection.planet_locked_recipe_contexts(graph, {
        node_to_context_inds = nci,
    })
    assert(locked["recipe: locked"]["planet: rock | 00"] and locked["recipe: locked"]["planet: rock | 11"])
    assert(locked["recipe: locked"]["planet: rock | 00 @ home1"] == nil, "home contexts aren't kept for their own sake")
    for node_key, _ in pairs(locked) do
        assert(node_key == "recipe: locked", node_key .. " isn't locked")
    end
    data.raw.recipe = nil
end)

test("recipe contexts a planetary change carried over are kept too, but only where the sort has them", function()
    data.raw.recipe = {
        moved = {
            name = "moved",
        },
    }
    local graph = {
        nodes = {
            ["recipe: moved"] = {
                type = "recipe",
                name = "moved",
            },
        },
    }
    local nci = {
        ["recipe: moved"] = {
            ["planet: rock | 01"] = 1,
            ["planet: sand | 01"] = 2,
        },
    }
    protection.transported_recipe_contexts = {
        ["recipe: moved"] = {
            ["planet: sand | 01"] = true,
            ["planet: ice | 01"] = true,
        },
    }
    local locked = protection.planet_locked_recipe_contexts(graph, {
        node_to_context_inds = nci,
    })
    protection.transported_recipe_contexts = {}
    assert(locked["recipe: moved"]["planet: sand | 01"], "a carried-over context the sort has isn't kept")
    assert(locked["recipe: moved"]["planet: ice | 01"] == nil, "a carried-over context the sort doesn't have is kept")
    assert(locked["recipe: moved"]["planet: rock | 01"] == nil, "a recipe on two planets without surface conditions is locked")
    data.raw.recipe = nil
end)

test("a context without isolatability keeps its other abilities, in its own room or a new one (goal transport)", function()
    assert(protection.without_isolatability("planet: rock | 11") == "planet: rock | 01")
    assert(protection.without_isolatability("planet: rock | 10") == "planet: rock | 00")
    assert(protection.without_isolatability("planet: rock | 11", "planet: sand") == "planet: sand | 01")
    assert(protection.without_isolatability("planet: rock") == "planet: rock", "a simple context is just its room")
    assert(protection.without_isolatability("planet: rock", "planet: sand") == "planet: sand")
    -- An unprotected mechanic's isolatable context is kept the same way
    assert(protection.planetary_kept_context({}, "planet: rock | 11", {}) == "planet: rock | 01")
end)

print(num_passed .. " tests passed")

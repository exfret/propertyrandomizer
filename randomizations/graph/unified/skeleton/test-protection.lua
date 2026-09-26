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
    local num_declared = 0
    for _, _ in pairs(declared) do
        num_declared = num_declared + 1
    end
    assert(num_declared == 5, "unexpected keep_isolatability declarations")
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

print(num_passed .. " tests passed")

-- Plain-Lua regression test for shared recipe-category nodes (lutils.group_rcats, not loaded by the mod)
-- Run from the mod root: lua tests/unit/logic/builders/test-rcat-groups.lua
--
-- Spoofed categories (a category list with fluid counts) whose crafters are the same share one node, named after the one with the fewest fluids, which takes any recipe every one of those crafters has the fluid boxes for

-- Stand-ins for the Factorio environment
function log(msg) end
data = {
    raw = {},
}
package.loaded["src/lib/random/rng"] = {}
package.loaded["__core__/lualib/collision-mask-util"] = {}
package.loaded["src/prototypes/entities/trigger"] = {}

local logic = {}
package.loaded["src/logic/state"] = logic
local lutils = require("src/logic/logic-utils")

-- Crafters with their fluid boxes: a character crafting by hand, two machines with two inputs and an output, and one with four inputs and two outputs
local CRAFTER_FLUIDS = {
    character = {
        input = 0,
        output = 0,
    },
    ["machine-a"] = {
        input = 2,
        output = 1,
    },
    ["machine-b"] = {
        input = 2,
        output = 1,
    },
    ["machine-big"] = {
        input = 4,
        output = 2,
    },
}
-- Category --> its crafters
local CRAFTERS_OF = {
    crafting = { "character", "machine-a", "machine-b" },
    chemistry = { "machine-big" },
    -- No crafter at all
    orphan = {},
}

-- Every spoofed category of these counts, with its crafters as src/prototypes/lookup/3-compound.lua finds them (the crafters with at least those fluid boxes); order picks the order rcats are filled in
local function fixture(order)
    local rcats = {}
    local rcat_to_crafters = {}
    local entries = {}
    for cat, _ in pairs(CRAFTERS_OF) do
        for input = 0, 3 do
            for output = 0, 2 do
                table.insert(entries, {
                    cat = cat,
                    input = input,
                    output = output,
                })
            end
        end
    end
    table.sort(entries, function(a, b)
        local ka = a.cat .. a.input .. a.output
        local kb = b.cat .. b.input .. b.output
        if order == "reversed" then
            return ka > kb
        end
        return ka < kb
    end)
    for _, entry in pairs(entries) do
        local name = lutils.rcat_key({ entry.cat }, {
            input = entry.input,
            output = entry.output,
        })
        rcats[name] = {
            cats = { entry.cat },
            input = entry.input,
            output = entry.output,
        }
        rcat_to_crafters[name] = {}
        for _, crafter in pairs(CRAFTERS_OF[entry.cat]) do
            local fluids = CRAFTER_FLUIDS[crafter]
            if fluids.input >= entry.input and fluids.output >= entry.output then
                rcat_to_crafters[name][crafter] = true
            end
        end
    end
    return rcats, rcat_to_crafters
end

local function name(cat, input, output)
    return lutils.rcat_key({ cat }, {
        input = input,
        output = output,
    })
end

local rcats, rcat_to_crafters = fixture("sorted")
local canonical, capability = lutils.group_rcats(rcats, rcat_to_crafters, CRAFTER_FLUIDS)

-- Hand crafting only does recipes without fluids, so no fluids is a group of its own
assert(canonical[name("crafting", 0, 0)] == name("crafting", 0, 0), "crafting with no fluids keeps its node, the character crafting it too")
-- Every count both machines can do shares one node, named after the one with the fewest fluids (one output before one input)
for _, counts in pairs({ { 1, 0 }, { 0, 1 }, { 1, 1 }, { 2, 0 }, { 2, 1 } }) do
    assert(canonical[name("crafting", counts[1], counts[2])] == name("crafting", 0, 1), "crafting with " .. counts[1] .. " in and " .. counts[2] .. " out is the machines' group")
end
-- No crafter has these: each keeps its own node
for _, counts in pairs({ { 3, 0 }, { 0, 2 } }) do
    assert(canonical[name("crafting", counts[1], counts[2])] == name("crafting", counts[1], counts[2]), "crafting with " .. counts[1] .. " in and " .. counts[2] .. " out has no crafter and keeps its node")
end
-- The machines' group takes what every machine in it has the boxes for
assert(capability[name("crafting", 0, 1)].input == 2 and capability[name("crafting", 0, 1)].output == 1, "the machines' group takes two fluids in and one out")
assert(capability[name("crafting", 0, 0)].input == 0 and capability[name("crafting", 0, 0)].output == 0, "the group with the character takes no fluids")
-- A crafter-less node is bounded by its own counts
assert(capability[name("crafting", 3, 0)].input == 3 and capability[name("crafting", 3, 0)].output == 0, "a node without crafters keeps its own counts")
assert(capability[name("crafting", 1, 0)] == nil, "only group nodes have a capability")
-- One machine with everything: one node for every count it does, including none
for input = 0, 3 do
    for output = 0, 2 do
        local expected = name("chemistry", 0, 0)
        assert(canonical[name("chemistry", input, output)] == expected, "chemistry with " .. input .. " in and " .. output .. " out is the big machine's group")
    end
end
assert(capability[name("chemistry", 0, 0)].input == 4 and capability[name("chemistry", 0, 0)].output == 2, "the big machine's group takes four in and two out")
-- Categories nobody crafts keep a node each
assert(canonical[name("orphan", 1, 1)] == name("orphan", 1, 1), "crafter-less categories aren't merged")
print("ok - spoofed categories with the same crafters share one node, named after the one with the fewest fluids, taking what every crafter can")

-- The same however the lookups were filled in
local rcats_2, rcat_to_crafters_2 = fixture("reversed")
local canonical_2, capability_2 = lutils.group_rcats(rcats_2, rcat_to_crafters_2, CRAFTER_FLUIDS)
for rcat_name, node_name in pairs(canonical) do
    assert(canonical_2[rcat_name] == node_name, rcat_name .. " gets the same node in either order")
end
for node_name, fluids in pairs(capability) do
    assert(capability_2[node_name].input == fluids.input and capability_2[node_name].output == fluids.output, node_name .. " has the same capability in either order")
end
print("ok - the groups don't depend on the order the lookups were filled in")

-- Looking a spoofed category's node up in the current build (logic.rcat_canonical), and without groups (the full graph of the both-ways check)
logic.rcat_canonical = canonical
assert(lutils.rcat_node_name(name("crafting", 2, 1)) == name("crafting", 0, 1), "a grouped category's node is its group's")
assert(lutils.rcat_node_name(name("crafting", 9, 9)) == name("crafting", 9, 9), "a category the lookups don't know keeps its name")
logic.rcat_canonical = nil
assert(lutils.rcat_node_name(name("crafting", 2, 1)) == name("crafting", 2, 1), "without groups every category keeps its node")
print("ok - node names come through the current build's groups, and stay their own without groups")

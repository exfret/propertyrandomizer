-- Run from the mod root: lua tests/unit/logic/builders/test-operation-unlocks.lua
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
local rng_state = 1
package.loaded["src/lib/random/rng"] = {
    int = function(_, maximum)
        rng_state = (rng_state * 1103515245 + 12345) % 2147483648
        return math.floor(rng_state / 65536) % maximum + 1
    end,
}
package.loaded["src/prototypes/data-utils"] = { get_prot = function() return nil end }
local logic = {
    contexts = {},
    type_info = {},
}
package.loaded["src/logic/state"] = logic
package.loaded["src/logic/init"] = logic

local gutils = require("src/lib/graph/graph-utils")
local top = require("src/lib/sort/context-sort")
local unlocks = require("src/logic/builders/operation-unlocks")
-- Contexts are numbers (src/logic/contexts/contexts.lua); fixtures write them as their names, like a room's simple context "room: test-home" (tests/unit/logic/contexts/contexts-for-tests.lua)
local C = require("tests/unit/logic/contexts/contexts-for-tests").C
local key = gutils.key
local passed = 0

local function test(name, run)
    run()
    passed = passed + 1
    print("ok - " .. name)
end

local function equal(left, right)
    if type(left) ~= "table" or type(right) ~= "table" then
        return left == right
    end
    for k, value in pairs(left) do
        if not equal(value, right[k]) then
            return false
        end
    end
    for k, _ in pairs(right) do
        if left[k] == nil then
            return false
        end
    end
    return true
end

local function fixture()
    logic.contexts = { ["room: test-home"] = true }
    logic.type_info = { room = { context = "room" } }
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local technologies = {}
    local recipes = {}
    data = { raw = { technology = technologies } }
    local function add(kind, name, op, pres)
        logic.type_info[kind] = logic.type_info[kind] or {}
        local node = gutils.add_node(graph, kind, name, { op = op })
        local node_key = key(node)
        for _, pre in pairs(pres or {}) do
            gutils.add_edge(graph, pre, node_key)
        end
        return node_key
    end
    local root = add("start", "test-start", "AND")
    local function technology(name, pres)
        technologies[name] = {
            type = "technology",
            name = name,
            prerequisites = {},
            unit = {
                count = 3,
                time = 4,
                ingredients = {},
            },
        }
        technologies[name].effects = {}
        for _, pre in pairs(pres or {}) do
            if graph.nodes[pre].type == "technology" then
                table.insert(technologies[name].prerequisites, graph.nodes[pre].name)
            end
        end
        return add("technology", name, "AND", pres or { root })
    end
    local function recipe(name, unlockers, enabled)
        recipes[name] = {
            type = "recipe",
            name = name,
            enabled = enabled == true,
            results = {},
        }
        local pres = { root }
        if unlockers ~= nil then
            pres = { add("recipe-tech-unlock", name, "OR", unlockers) }
            for _, tech_key in pairs(unlockers) do
                table.insert(technologies[graph.nodes[tech_key].name].effects, {
                    type = "unlock-recipe",
                    recipe = name,
                })
            end
        end
        return add("recipe", name, "AND", pres)
    end
    local function power(unlocker)
        if unlocker == nil then
            local precursor = technology("test-power-precursor")
            unlocker = technology("test-power-tech", { precursor })
        end
        local production = recipe("test-power-recipe", { unlocker })
        return add("item", "test-power-supply", "OR", { production })
    end
    local function device(item, supply, own, name)
        name = name or "test-device"
        local build_item = add("entity-build-item", name, "OR", { item })
        local build = add("entity-build", name, "AND", { build_item })
        if own ~= nil then
            gutils.add_edge(graph, build, own)
        else
            own = add("entity-own", name, "OR", { build })
        end
        return add("entity-operate", name, "AND", {
            own,
            supply,
        })
    end
    local function apply(fixed_recipes, sorted)
        return unlocks.apply(graph, sorted or top.sort(graph), technologies, recipes, fixed_recipes or {})
    end
    return {
        graph = graph,
        technologies = technologies,
        recipes = recipes,
        root = root,
        add = add,
        tech = technology,
        make_recipe = recipe,
        power = power,
        device = device,
        apply = apply,
    }
end

local function has_pre(technology, name)
    for _, pre in pairs(technology.prerequisites or {}) do
        if pre == name then
            return true
        end
    end
    return false
end

test("alternative unlock technologies both require power and remain independent", function()
    local f = fixture()
    local first = f.tech("test-first-unlock")
    local second = f.tech("test-second-unlock")
    local producer = f.make_recipe("test-device-recipe", {
        first,
        second,
    })
    local item = f.add("item", "test-device-kit", "OR", { producer })
    f.device(item, f.power())
    local before = table.deepcopy(f.graph)
    local result = f.apply()
    assert(#result.unresolved == 0 and result.changed == 2)
    assert(has_pre(f.technologies["test-first-unlock"], "test-power-tech"))
    assert(has_pre(f.technologies["test-second-unlock"], "test-power-tech"))
    assert(not has_pre(f.technologies["test-first-unlock"], "test-second-unlock"))
    assert(not has_pre(f.technologies["test-second-unlock"], "test-first-unlock"))
    assert(equal(f.graph, before), "research reflection must preserve the acquisition graph")
end)

test("one technology unlocking device and power does not acquire a self prerequisite", function()
    local f = fixture()
    local shared = f.tech("test-shared-unlock")
    local producer = f.make_recipe("test-device-recipe", { shared })
    local item = f.add("item", "test-device-kit", "OR", { producer })
    f.device(item, f.power(shared))
    local result = f.apply()
    assert(#result.unresolved == 0 and result.changed == 0)
    assert(next(f.technologies["test-shared-unlock"].prerequisites) == nil)
    assert(#result.new_technologies == 0)
end)

test("independent technologies at the same research layer need no extra gate", function()
    local f = fixture()
    local gate = f.tech("test-device-tech")
    local producer = f.make_recipe("test-device-recipe", { gate })
    local item = f.add("item", "test-device-kit", "OR", { producer })
    local same_layer = f.tech("test-power-tech")
    f.device(item, f.power(same_layer))
    local before = table.deepcopy(f.technologies)
    local result = f.apply()
    assert(#result.unresolved == 0 and result.changed == 0)
    assert(equal(f.technologies, before))
end)

test("trigger salvage gates the capsule technology without requiring itself", function()
    local f = fixture()
    local trigger = f.tech("test-capsule-tech")
    local producer = f.make_recipe("test-capsule-recipe", { trigger })
    local capsule = f.add("item", "test-capsule", "OR", { producer })
    local use = f.add("item-capsule", "test-capsule", "AND", { capsule })
    local own = f.add("entity-own", "test-device", "OR", { use })
    local entity = f.add("entity", "test-device", "OR", { own })
    local mine = f.add("entity-mine", "test-device", "AND", { entity })
    local item = f.add("item", "test-salvage", "OR", { mine })
    f.device(item, f.power(), own)
    local result = f.apply()
    assert(#result.unresolved == 0 and result.changed == 1)
    assert(has_pre(f.technologies["test-capsule-tech"], "test-power-tech"))
    assert(not has_pre(f.technologies["test-capsule-tech"], "test-capsule-tech"))
    assert(#result.new_technologies == 0)
end)

test("an enabled producer gets a technology copying an actual research descriptor", function()
    local f = fixture()
    local producer = f.make_recipe("test-device-recipe", nil, true)
    local item = f.add("item", "test-device-kit", "OR", { producer })
    f.device(item, f.power())
    local expected_unit = table.deepcopy(f.technologies["test-power-tech"].unit)
    local result = f.apply()
    assert(#result.unresolved == 0 and #result.new_technologies == 1)
    assert(f.recipes["test-device-recipe"].enabled == false)
    local technology = result.new_technologies[1]
    assert(f.technologies[technology.name] == technology)
    assert(equal(technology.unit, expected_unit))
    assert(technology.unit ~= f.technologies["test-power-tech"].unit)
    assert(has_pre(technology, "test-power-tech"))
    assert(#technology.effects == 1 and technology.effects[1].recipe == "test-device-recipe")
end)

test("an enabled producer can copy an operation prerequisite's research trigger", function()
    local f = fixture()
    local producer = f.make_recipe("test-device-recipe", nil, true)
    local item = f.add("item", "test-device-kit", "OR", { producer })
    f.device(item, f.power())
    f.technologies["test-power-tech"].unit = nil
    f.technologies["test-power-tech"].research_trigger = {
        type = "craft-item",
        item = "test-trigger-material",
        count = 7,
    }
    local result = f.apply()
    assert(#result.unresolved == 0 and #result.new_technologies == 1)
    local technology = result.new_technologies[1]
    assert(technology.unit == nil)
    assert(equal(technology.research_trigger, f.technologies["test-power-tech"].research_trigger))
    assert(technology.research_trigger ~= f.technologies["test-power-tech"].research_trigger)
end)

test("an ungated wild route is reported without partially changing another route", function()
    local f = fixture()
    local gate = f.tech("test-device-tech")
    local producer = f.make_recipe("test-device-recipe", { gate })
    local wild = f.add("entity-mine", "test-wild-device", "AND", { f.root })
    local item = f.add("item", "test-device-kit", "OR", {
        producer,
        wild,
    })
    f.device(item, f.power())
    local before_techs = table.deepcopy(f.technologies)
    local before_recipes = table.deepcopy(f.recipes)
    local result = f.apply()
    assert(#result.unresolved == 1 and result.changed == 0)
    assert(#result.new_technologies == 0)
    assert(equal(f.technologies, before_techs) and equal(f.recipes, before_recipes))
end)

test("a research method needing the device cannot gate the device's acquisition", function()
    local f = fixture()
    local gate = f.tech("test-device-tech")
    local producer = f.make_recipe("test-device-recipe", { gate })
    local item = f.add("item", "test-device-kit", "OR", { producer })
    local research = f.add("technology-trigger", "test-power-tech", "OR", { item })
    local power_tech = f.tech("test-power-tech", { research })
    f.device(item, f.power(power_tech))
    local before = table.deepcopy(f.technologies)
    local result = f.apply()
    assert(#result.unresolved == 1 and result.changed == 0)
    assert(equal(f.technologies, before), "a research cycle must not leak a partial edit")
end)

test("an operation prerequisite cannot remove another acquisition context", function()
    local f = fixture()
    logic.contexts["room: test-away"] = true
    local home = f.add("room", "room: test-home", "OR", { f.root })
    local gate = f.tech("test-device-tech")
    local producer = f.make_recipe("test-device-recipe", { gate })
    local item = f.add("item", "test-device-kit", "OR", { producer })
    local precursor = f.tech("test-power-precursor", { home })
    local local_power = f.tech("test-power-tech", { precursor })
    f.device(item, f.power(local_power))
    local before = table.deepcopy(f.technologies)
    local result = f.apply()
    assert(#result.unresolved == 1 and result.changed == 0)
    assert(equal(f.technologies, before))
end)

test("a fixed recipe does not receive a bypassable research gate", function()
    local f = fixture()
    local producer = f.make_recipe("test-device-recipe", nil, true)
    local item = f.add("item", "test-device-kit", "OR", { producer })
    f.device(item, f.power())
    local result = f.apply({ ["test-device-recipe"] = { ["test-fixed-machine"] = true } })
    assert(#result.unresolved == 1 and result.changed == 0)
    assert(f.recipes["test-device-recipe"].enabled == true and #result.new_technologies == 0)
end)

test("two individually safe alternative gates cannot create a joint research cycle", function()
    local f = fixture()
    local first = f.tech("test-first-tech")
    local precursor = f.tech("test-second-precursor")
    local second = f.tech("test-second-tech", { precursor })
    local producer = f.make_recipe("test-device-recipe", {
        first,
        second,
    })
    local item = f.add("item", "test-device-kit", "OR", { producer })
    local first_supply = f.make_recipe("test-first-supply", { first })
    local second_supply = f.make_recipe("test-second-supply", { second })
    local power = f.add("energy-source-electric", "test-supply", "AND", {
        first_supply,
        second_supply,
    })
    f.device(item, power)
    local before = table.deepcopy(f.technologies)
    -- Exercise the early acquisition witness; the other valid sort can first find the later unlock and need no readiness adjustment.
    local sorted
    for _ = 1, 64 do
        local candidate = top.sort(f.graph, nil, nil, { choose_randomly = true })
        local contexts = candidate.node_to_context_inds
        if contexts[first][C("room: test-home")] < contexts[second][C("room: test-home")] then
            sorted = candidate
            break
        end
    end
    assert(sorted ~= nil, "the real sorter must find a witness using the early alternative")
    local result = f.apply(nil, sorted)
    assert(#result.unresolved == 1 and result.changed == 0, "expected cycle rejection, got " .. #result.unresolved .. " unresolved and " .. result.changed .. " changes")
    assert(equal(f.technologies, before), "a rejected group of gates must leave no partial prerequisite")
end)

test("a later enabled-recipe gate respects physical research dependencies of an earlier gate", function()
    local f = fixture()
    local first_recipe = f.make_recipe("test-a-recipe", nil, true)
    local second_recipe = f.make_recipe("test-b-recipe", nil, true)
    local first_item = f.add("item", "test-a-kit", "OR", { first_recipe })
    local second_item = f.add("item", "test-b-kit", "OR", { second_recipe })
    local first_research = f.tech("test-a-operation-tech", { second_item })
    local second_research = f.tech("test-b-operation-tech", { first_item })
    local first_supply_recipe = f.make_recipe("test-a-supply", { first_research })
    local second_supply_recipe = f.make_recipe("test-b-supply", { second_research })
    local first_supply = f.add("item", "test-a-supply", "OR", { first_supply_recipe })
    local second_supply = f.add("item", "test-b-supply", "OR", { second_supply_recipe })
    f.device(first_item, first_supply, nil, "test-a-device")
    f.device(second_item, second_supply, nil, "test-b-device")
    local result = f.apply()
    assert(#result.new_technologies == 1 and #result.unresolved == 1)
    assert(f.recipes["test-a-recipe"].enabled == false)
    assert(f.recipes["test-b-recipe"].enabled == true, "the second gate would make both research methods wait on each other")
    assert(result.unresolved[1].item == second_item)
end)

print("passed " .. passed .. " operation-unlock tests")

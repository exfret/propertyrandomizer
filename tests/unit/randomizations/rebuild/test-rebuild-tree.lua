-- Run from the mod root: lua tests/unit/randomizations/rebuild/test-rebuild-tree.lua
-- The redesigned tech tree rebuild (src/randomizations/rebuild/tree.lua) against the problems the user found in it (user, 2026-10-12; notes/logs/2026-10-12-rebuild-redesign/)
-- Each game runs with recipes' unlocks both full and contracted (src/logic/analysis/unlock-contraction.lua)

local fixture = require("tests/unit/randomizations/rebuild/rebuild-world-for-tests")
local gutils = fixture.gutils
local needs_of = require("src/randomizations/rebuild/needs")
local ROOM_A = fixture.ROOM_A
local ROOM_B = fixture.ROOM_B
local ROOM_C = fixture.ROOM_C

local num_passed = 0
-- Runs check(label) once with full unlocks and once contracted
local function test(name, check)
    for _, contract in pairs({
        false,
        true,
    }) do
        fixture.reductions.enabled = contract
        check(contract and "contracted" or "full")
    end
    fixture.reductions.enabled = true
    num_passed = num_passed + 1
    print("ok - " .. name)
end

-- Rooms A (the start), B and C, the latter two discovered with a pack room A makes; reaching_b and reaching_c add what each needs besides its discovery
local function rooms(node, extra_b, extra_c)
    local start = node("start", "", "AND")
    local a = node("room", ROOM_A, "OR", { start })
    node("item", "test-pack", "OR", { a })
    node("item", "test-a-item", "OR", { a })
    local b_pres = { node("technology", "test-discover-b", "AND") }
    for _, pre in pairs(extra_b or {}) do
        table.insert(b_pres, pre)
    end
    local b = node("room", ROOM_B, "OR", { node("test-reach", "b", "AND", b_pres) })
    local c_pres = { node("technology", "test-discover-c", "AND") }
    for _, pre in pairs(extra_c or {}) do
        table.insert(c_pres, pre)
    end
    local c = node("room", ROOM_C, "OR", { node("test-reach", "c", "AND", c_pres) })
    return a, b, c
end

-- Issue 1: a recipe only one planet makes comes after that planet's discovery, even when its research (a trigger room A meets) could be done before
test("a recipe made only on a planet needs the planet's discovery, though its trigger is met before", function(label)
    fixture.world(function(node, recipe_node)
        local _, b = rooms(node)
        recipe_node("test-b-pack", { node("item", "test-b-input", "OR", { b }) })
    end)
    fixture.recipe_with_tech("test-b-pack", { trigger = "test-a-item" })
    fixture.discovery("test-discover-b", "test-b", "test-pack")
    fixture.discovery("test-discover-c", "test-c", "test-pack")
    local before = fixture.sort()
    fixture.rebuild()
    local tech = fixture.rebuilt("test-b-pack")
    assert(tech ~= nil and tech.research_trigger ~= nil, label .. ": the recipe keeps a trigger tech of its own")
    assert(fixture.needs(tech.name, "test-discover-b"), label .. ": its tech needs room B's discovery")
    fixture.assert_kept(before, fixture.sort(), label)
    fixture.assert_checks_pass(label)
end)

-- Issue 3: a merged recipe two planets make, each with its own unlock before the merge, gets an unlock after each planet's discovery, neither waiting for the other planet
test("a recipe two planets make gets a tech after each discovery, with packs or a trigger", function(label)
    for _, research in pairs({
        "test-pack",
        { trigger = "test-a-item" },
    }) do
        local kind = type(research) == "table" and "trigger" or "packs"
        fixture.world(function(node, recipe_node)
            local _, b, c = rooms(node)
            local input = node("item", "test-bc-input", "OR", {
                b,
                c,
            })
            recipe_node("test-merged", { input })
        end)
        fixture.recipe_with_tech("test-merged", research, "test-merged-from-b")
        fixture.recipe_with_tech("test-merged", research, "test-merged-from-c")
        fixture.discovery("test-discover-b", "test-b", "test-pack")
        fixture.discovery("test-discover-c", "test-c", "test-pack")
        local before = fixture.sort()
        fixture.rebuild()
        local techs = fixture.unlockers("test-merged")
        assert(#techs == 2, label .. ", " .. kind .. ": two techs unlock the recipe, not " .. #techs)
        local after_b
        local after_c
        for _, tech_name in pairs(techs) do
            local needs_b = fixture.needs(tech_name, "test-discover-b")
            local needs_c = fixture.needs(tech_name, "test-discover-c")
            assert(needs_b ~= needs_c, label .. ", " .. kind .. ": " .. tech_name .. " comes after exactly one of the discoveries")
            after_b = after_b or needs_b
            after_c = after_c or needs_c
        end
        assert(after_b and after_c, label .. ", " .. kind .. ": one after each discovery")
        fixture.assert_kept(before, fixture.sort(), label .. ", " .. kind)
        fixture.assert_checks_pass(label .. ", " .. kind)
    end
end)

-- Issue 2: no unlock another one makes pointless
-- Room C comes after room B (its discovery is researched by crafting something only room B has), so the recipe's unlock after room B serves room C too, and the one after room C would only repeat it
test("an unlock another one covers is left out", function(label)
    fixture.world(function(node, recipe_node)
        local _, b, c = rooms(node)
        node("item", "test-b-thing", "OR", { b })
        local input = node("item", "test-bc-input", "OR", {
            b,
            c,
        })
        recipe_node("test-shared", { input })
    end)
    fixture.recipe_with_tech("test-shared", "test-pack")
    fixture.discovery("test-discover-b", "test-b", "test-pack")
    fixture.discovery("test-discover-c", "test-c", {
        trigger = "test-b-thing",
    })
    local before = fixture.sort()
    fixture.rebuild()
    local techs = fixture.unlockers("test-shared")
    assert(#techs == 1, label .. ": one tech unlocks the recipe, not " .. #techs .. " (" .. table.concat(techs, ", ") .. ")")
    assert(fixture.needs(techs[1], "test-discover-b") and not fixture.needs(techs[1], "test-discover-c"), label .. ": it's the one after room B's discovery")
    assert(fixture.needs("test-discover-c", "test-discover-b"), label .. ": room C's discovery comes after room B's")
    fixture.assert_kept(before, fixture.sort(), label)
    fixture.assert_checks_pass(label)
end)

-- Issue 4 of the second list: a recipe only planets needing discovery make isn't enabled from the start, but comes with their discoveries
test("a recipe enabled from the start that only a planet makes comes with its discovery instead", function(label)
    fixture.world(function(node, _, enabled_recipe_node)
        local _, b = rooms(node)
        enabled_recipe_node("test-brick", { node("item", "test-b-input", "OR", { b }) })
    end)
    fixture.discovery("test-discover-b", "test-b", "test-pack")
    fixture.discovery("test-discover-c", "test-c", "test-pack")
    local before = fixture.sort()
    fixture.rebuild()
    assert(data.raw.recipe["test-brick"].enabled == false, label .. ": the recipe isn't enabled from the start")
    assert(fixture.unlocks(data.raw.technology["test-discover-b"], "test-brick"), label .. ": room B's discovery unlocks it")
    fixture.assert_kept(before, fixture.sort(), label)
    fixture.assert_checks_pass(label)
end)

-- Issue 5: what a recipe needs doesn't go through its own old unlock, whose research needed something unrelated (here the tool researching the old drill tech)
test("a recipe's needs don't take in its old tech's research", function(label)
    fixture.world(function(node, recipe_node)
        local a = rooms(node)
        recipe_node("test-ingredient", { a })
        recipe_node("test-tool", { a })
        recipe_node("test-drill", { gutils.key("item", "test-ingredient-product") })
    end)
    fixture.recipe_with_tech("test-ingredient", "test-pack")
    fixture.recipe_with_tech("test-tool", "test-pack")
    fixture.recipe_with_tech("test-drill", { trigger = "test-tool-product" })
    fixture.discovery("test-discover-b", "test-b", "test-pack")
    fixture.discovery("test-discover-c", "test-c", "test-pack")
    local sort_info = fixture.sort()
    local rank
    for _, other in pairs(sort_info.node_to_context_inds[gutils.key("recipe", "test-drill")]) do
        rank = math.min(rank or other, other)
    end
    local found = needs_of.of(fixture.logic.graph, sort_info, rank, {
        has_tech = function(recipe_name)
            return data.raw.recipe[recipe_name] ~= nil
        end,
        own_recipe = "test-drill",
    })
    local names = {}
    for _, entry in pairs(found.recipes) do
        table.insert(names, entry.name)
    end
    assert(#names == 1 and names[1] == "test-ingredient", label .. ": the drill itself needs only its ingredient, not " .. table.concat(names, ", "))
    -- The rebuilt drill tech still needs the tool, since it copies the trigger: there the research needs it
    fixture.rebuild()
    local tech = fixture.rebuilt("test-drill")
    assert(fixture.needs(tech.name, "exfret-rebuilt-test-ingredient-suffix") and fixture.needs(tech.name, "exfret-rebuilt-test-tool-suffix"), label .. ": the drill's tech needs its ingredient's and its trigger's techs")
    fixture.assert_checks_pass(label)
end)

-- Issue 6: the route to a planet (like thrusters) is its discovery's prerequisite, not every recipe's made there
test("a discovery takes the route to its planet, so recipes made there need only the discovery", function(label)
    fixture.world(function(node, recipe_node)
        local start = node("start", "", "AND")
        local a = node("room", ROOM_A, "OR", { start })
        node("item", "test-pack", "OR", { a })
        local thruster = recipe_node("test-thruster", { a })
        local reach = node("test-reach", "b", "AND", {
            node("technology", "test-discover-b", "AND"),
            thruster,
        })
        local b = node("room", ROOM_B, "OR", { reach })
        recipe_node("test-b-thing", { node("item", "test-b-input", "OR", { b }) })
        recipe_node("test-b-other", { node("item", "test-b-input", "OR", { b }) })
    end, {
        ROOM_A,
        ROOM_B,
    })
    fixture.recipe_with_tech("test-thruster", "test-pack")
    fixture.recipe_with_tech("test-b-thing", "test-pack")
    fixture.recipe_with_tech("test-b-other", "test-pack")
    fixture.discovery("test-discover-b", "test-b", "test-pack")
    local before = fixture.sort()
    fixture.rebuild()
    local discovery = data.raw.technology["test-discover-b"]
    assert(fixture.needs(discovery.name, "exfret-rebuilt-test-thruster-suffix"), label .. ": room B's discovery needs the thruster's tech")
    for _, recipe_name in pairs({
        "test-b-thing",
        "test-b-other",
    }) do
        local tech = fixture.rebuilt(recipe_name)
        assert(#tech.prerequisites == 1 and tech.prerequisites[1] == discovery.name, label .. ": " .. recipe_name .. "'s tech needs just the discovery, not " .. table.concat(tech.prerequisites, ", "))
    end
    fixture.assert_kept(before, fixture.sort(), label)
    fixture.assert_checks_pass(label)
end)

-- Issue 7: a tech after a discovery takes the discovery's packs too ("Also consume later science"), where a lab takes them all
test("a tech researched with packs after a discovery takes the discovery's packs too, where a lab takes them", function(label)
    for _, lab_takes_all in pairs({
        true,
        false,
    }) do
        fixture.world(function(node, recipe_node)
            local a, b = rooms(node)
            node("item", "test-space", "OR", { a })
            recipe_node("test-b-thing", { node("item", "test-b-input", "OR", { b }) })
        end)
        fixture.recipe_with_tech("test-b-thing", "test-pack")
        fixture.discovery("test-discover-b", "test-b", {
            "test-pack",
            "test-space",
        })
        fixture.discovery("test-discover-c", "test-c", "test-pack")
        data.raw.lab["test-lab"] = {
            type = "lab",
            name = "test-lab",
            inputs = lab_takes_all == true and {
                "test-pack",
                "test-space",
            } or { "test-pack" },
        }
        if lab_takes_all == false then
            data.raw.lab["test-space-lab"] = {
                type = "lab",
                name = "test-space-lab",
                inputs = { "test-space" },
            }
        end
        fixture.rebuild()
        local packs = {}
        for _, ingredient in pairs(fixture.rebuilt("test-b-thing").unit.ingredients) do
            packs[ingredient[1]] = true
        end
        if lab_takes_all == true then
            assert(packs["test-pack"] and packs["test-space"], label .. ": the tech takes the discovery's packs")
            fixture.assert_checks_pass(label)
        else
            assert(packs["test-space"] == nil, label .. ": no lab takes both, so the tech keeps its own packs")
        end
    end
end)

-- Copies (user, 2026-10-12: "the duplicated items belong to the duplicated planets"): a tech the game has after a discovery (as unified randomization keeps a planet copy's technologies, dupe.copy_gates) passes that discovery on to the recipe's rebuilt tech, though nothing the recipe needs comes from there
test("a recipe whose tech came after a discovery keeps that discovery as a prerequisite", function(label)
    fixture.world(function(node, recipe_node)
        local a = rooms(node)
        recipe_node("test-copy", { a })
    end)
    local tech = fixture.recipe_with_tech("test-copy", "test-pack")
    tech.prerequisites = { "test-discover-b" }
    fixture.discovery("test-discover-b", "test-b", "test-pack")
    fixture.discovery("test-discover-c", "test-c", "test-pack")
    local before = fixture.sort()
    fixture.rebuild()
    assert(fixture.needs(fixture.rebuilt("test-copy").name, "test-discover-b"), label .. ": the copy's tech needs the discovery its old tech came after")
    fixture.assert_kept(before, fixture.sort(), label)
    fixture.assert_checks_pass(label)
end)

-- A recipe only room B makes, unlocked both by another planet's tech and by room B's own (after its discovery, researched by crafting something room B makes), keeps every context it had and comes after room B's discovery; one only the other planet's tech unlocks takes that one's research, after room B's discovery (from test-rebuild-research-planet.lua, before the redesign)
-- The old rebuild took room B's research for the first so the recipe didn't lose its contexts there (cca5100); the timeline planner keeps them by placing a technology for each context the recipe had, so room B's research, which here comes only after the recipe could first be made there, isn't needed for that
test("a recipe only one planet makes keeps its contexts there, after the planet's discovery, when another planet's tech unlocks it too", function(label)
    fixture.world(function(node, recipe_node)
        local _, b = rooms(node)
        node("item", "test-b-thing", "OR", { b })
        recipe_node("test-planet-recipe", { node("item", "test-b-input", "OR", { b }) })
        recipe_node("test-unowned-recipe", { node("item", "test-b-input", "OR", { b }) })
    end)
    fixture.recipe_with_tech("test-planet-recipe", { trigger = "test-a-item" }, "test-other-planet-tech")
    table.insert(data.raw.technology["test-other-planet-tech"].effects, {
        type = "unlock-recipe",
        recipe = "test-unowned-recipe",
    })
    data.raw.recipe["test-unowned-recipe"] = {
        type = "recipe",
        name = "test-unowned-recipe",
        enabled = false,
        results = {},
    }
    local own = fixture.recipe_with_tech("test-planet-recipe", { trigger = "test-b-thing" }, "test-b-tech")
    own.prerequisites = { "test-discover-b" }
    fixture.discovery("test-discover-b", "test-b", "test-pack")
    fixture.discovery("test-discover-c", "test-c", "test-pack")
    local before = fixture.sort()
    fixture.rebuild()
    local planet = fixture.unlockers("test-planet-recipe")
    assert(#planet >= 1, label .. ": the recipe room B makes has a tech")
    for _, tech_name in pairs(planet) do
        assert(fixture.needs(tech_name, "test-discover-b"), label .. ": " .. tech_name .. " comes after room B's discovery")
    end
    local unowned = fixture.rebuilt("test-unowned-recipe")
    assert(unowned.research_trigger.item == "test-a-item" and fixture.needs(unowned.name, "test-discover-b"), label .. ": one only the other tech unlocks takes that research, after room B's discovery")
    fixture.assert_kept(before, fixture.sort(), label)
    fixture.assert_checks_pass(label)
end)

print(num_passed .. " tests passed")

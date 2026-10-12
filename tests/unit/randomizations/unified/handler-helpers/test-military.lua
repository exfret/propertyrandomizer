-- Run from the mod root: lua tests/unit/randomizations/unified/handler-helpers/test-military.lua
-- Test the actual reflection helper, including death chains and shared spawners.
package.loaded["__core__/lualib/collision-mask-util"] = {}
package.loaded["src/logic/logic-utils"] = {
    starting_planet_name = "test-start",
    check_in_room = function(room, entity)
        return entity.test_planets ~= nil and entity.test_planets[room.name] == true
    end,
}

table.deepcopy = function(object)
    if type(object) ~= "table" then
        return object
    end
    local copy = {}
    for k, v in pairs(object) do
        copy[k] = table.deepcopy(v)
    end
    return copy
end
log = function() end
defines = {
    prototypes = {
        entity = {},
        item = {},
    },
}
data = { raw = {} }
data.extend = function(self, prototypes)
    for _, prototype in pairs(prototypes) do
        self.raw[prototype.type] = self.raw[prototype.type] or {}
        assert(self.raw[prototype.type][prototype.name] == nil, "duplicate copy name")
        self.raw[prototype.type][prototype.name] = prototype
    end
end

local dutils = require("src/prototypes/data-utils")
local acquisition = require("src/logic/builders/acquisition")
local military = require("src/randomizations/unified/handler-helpers/military")
local variants = require("src/randomizations/unified/military-variants")
local wild = require("src/prototypes/entities/wild-entities")

local function damage(amount)
    return {
        type = "damage",
        damage = {
            amount = amount,
            type = "test-damage",
        },
    }
end

local function created(name)
    return {
        type = "create-entity",
        entity_name = name,
        offsets = {
            {
                0,
                1,
            },
            {
                1,
                0,
            },
        },
    }
end

local function unit(name, health, hit)
    return {
        type = "unit",
        name = name,
        max_health = health,
        healing_per_tick = health / 1000,
        absorptions_to_join_attack = { ["test-spores"] = 20 },
        attack_parameters = {
            cooldown = 60,
            ammo_type = {
                action = {
                    type = "direct",
                    action_delivery = {
                        type = "instant",
                        target_effects = { damage(hit) },
                    },
                },
            },
        },
    }
end

local function definition(name)
    return {
        unit = name,
        spawn_points = {
            {
                evolution_factor = 0,
                spawn_weight = 1,
            },
        },
    }
end

local function spawner(name, spawn, planet, pollutant)
    return {
        type = "unit-spawner",
        name = name,
        result_units = { definition(spawn) },
        max_count_of_owned_units = 5,
        max_friends_around_to_spawn = 5,
        absorptions_per_second = { [pollutant] = { absolute = 1 } },
        autoplace = {
            control = "test-enemy-control",
            force = "enemy",
        },
        test_planets = { [planet] = true },
    }
end

local function reset(shared)
    data.raw = {}
    defines.prototypes.entity = {}
    local native = unit("test-native", 10, 10)
    native.absorptions_to_join_attack = { ["test-pollution"] = 4 }
    local parent = unit("test-parent", 1000, 100)
    parent.dying_trigger_effect = {
        created("test-child"),
        created("test-shell"),
    }
    parent.spider_engine = {
        legs = {
            leg = "test-leg",
            leg_hit_the_ground_when_attacking_trigger = { damage(20) },
        },
    }
    local child = unit("test-child", 100, 20)
    child.healing_per_tick = -1
    child.ai_settings = { join_attacks = false }
    child.absorptions_to_join_attack["test-spores"] = 0
    child.dying_trigger_effect = {
        type = "nested-result",
        action = {
            type = "direct",
            action_delivery = {
                type = "instant",
                target_effects = { created("test-grandchild") },
            },
        },
    }
    local grandchild = unit("test-grandchild", 50, 10)
    grandchild.dying_trigger_effect = created("test-child") -- A death cycle.
    local home = spawner("test-home", parent.name, "test-home-planet", "test-spores")
    local away = spawner("test-away", native.name, "test-start", "test-pollution")
    if shared == true then
        away.test_planets["test-other-planet"] = true
    end
    local entities = {
        native,
        parent,
        child,
        grandchild,
        home,
        away,
        {
            type = "simple-entity",
            name = "test-shell",
            max_health = 1000,
        },
    }
    for _, entity in pairs(entities) do
        defines.prototypes.entity[entity.type] = 0
    end
    data:extend(entities)
    for _, name in pairs({
        "test-start",
        "test-home-planet",
        "test-other-planet",
    }) do
        data:extend({
            {
                type = "planet",
                name = name,
                map_gen_settings = {
                    autoplace_controls = { ["test-enemy-control"] = {} },
                    autoplace_settings = { entity = { settings = { [away.name] = { frequency = 2 } } } },
                    property_expression_names = { ["entity:" .. away.name .. ":richness"] = "test-richness" },
                },
            },
        })
    end
    unified_starting_data_raw = table.deepcopy(data.raw)
    away.result_units = { definition(parent.name) }
    lookups = { rooms = {} }
    for name, planet in pairs(data.raw.planet) do
        lookups.rooms[name] = planet
    end
    return parent, child, grandchild, home, away
end

local function spawn_of(spawner)
    local name = acquisition.read_spawn_definition(spawner.result_units[1])
    return assert(dutils.get_prot("entity", name))
end

local count = 0
local function test(name, fn)
    fn()
    count = count + 1
    print("ok - " .. name)
end

local function near(a, b)
    return math.abs(a - b) < 1e-9
end

test("starting slots get copies; originals and home spawns keep their stats", function()
    local parent, child, grandchild, home, away = reset(false)
    local before = table.deepcopy(parent)
    military.apply()
    local copy = spawn_of(away)
    assert(copy.name ~= parent.name and copy.max_health == 10)
    assert(near(copy.healing_per_tick, 0.01))
    assert(near(copy.attack_parameters.damage_modifier, 10 / 120))
    assert(near(copy.spider_engine.legs.leg_hit_the_ground_when_attacking_trigger[1].damage.amount, 20 * 10 / 120))
    assert(copy.absorptions_to_join_attack["test-pollution"] == 4)
    assert(copy.absorptions_to_join_attack["test-spores"] == 0.2)
    assert(parent.max_health == before.max_health and parent.attack_parameters.damage_modifier == nil)
    assert(parent.absorptions_to_join_attack["test-pollution"] == nil)
    assert(parent.dying_trigger_effect[1].entity_name == child.name)
    assert(spawn_of(home) == parent)
    local offspring = assert(dutils.get_prot("entity", copy.dying_trigger_effect[1].entity_name))
    assert(offspring.name ~= child.name and offspring.max_health == 1)
    assert(near(offspring.healing_per_tick, -0.01))
    assert(near(offspring.attack_parameters.damage_modifier, 10 / 120))
    assert(offspring.absorptions_to_join_attack["test-spores"] == 0)
    local next_name = offspring.dying_trigger_effect.action.action_delivery.target_effects[1].entity_name
    local next_copy = assert(dutils.get_prot("entity", next_name))
    assert(next_copy.name ~= grandchild.name and next_copy.max_health == 1)
    assert(next_copy.dying_trigger_effect.entity_name == offspring.name)
    assert(copy.dying_trigger_effect[2].entity_name == "test-shell")
    assert(#copy.dying_trigger_effect[1].offsets == 2)
    assert(child.max_health == 100 and grandchild.max_health == 50)
    assert(variants.originals[copy.name] == parent.name)
    assert(copy.localised_name[1] == "entity-name." .. parent.name)
end)

test("a spawner shared by planets uses full-strength units away from start", function()
    local parent, _, _, _, away = reset(true)
    military.apply()
    local away_copy
    for copy_name, original in pairs(variants.originals) do
        if original == away.name then
            away_copy = assert(dutils.get_prot("entity", copy_name))
        end
    end
    assert(away_copy ~= nil and spawn_of(away_copy) == parent)
    assert(parent.max_health == 1000 and parent.absorptions_to_join_attack["test-pollution"] == 4)
    assert(spawn_of(away).max_health == 10)
    assert(wild.never_placed(data.raw.planet["test-start"], away_copy.name))
    assert(wild.never_placed(data.raw.planet["test-other-planet"], away.name))
    local map = data.raw.planet["test-other-planet"].map_gen_settings
    assert(map.autoplace_settings.entity.settings[away_copy.name].frequency == 2)
    assert(map.property_expression_names["entity:" .. away_copy.name .. ":richness"] == "test-richness")
end)

test("a shared spawner measures starting strength without averaging in other planets", function()
    local parent, _, _, _, away = reset(true)
    local strong = spawner("test-strong", parent.name, "test-other-planet", "test-pollution")
    data:extend({ strong })
    unified_starting_data_raw[strong.type][strong.name] = table.deepcopy(strong)
    military.apply()
    assert(spawn_of(away).max_health == 10)
end)

test("projectile-created offspring use copies while shared projectiles stay unchanged", function()
    local parent, child, _, _, away = reset(false)
    local projectile = {
        type = "projectile",
        name = "test-projectile",
        action = {
            type = "direct",
            action_delivery = {
                type = "instant",
                target_effects = {
                    created(child.name),
                    damage(100),
                },
            },
        },
    }
    defines.prototypes.entity[projectile.type] = 0
    data:extend({ projectile })
    parent.attack_parameters.ammo_type.action.action_delivery = {
        type = projectile.type,
        projectile = projectile.name,
    }
    unified_starting_data_raw = table.deepcopy(data.raw)
    -- Keep the original starting spawn table for the baseline.
    unified_starting_data_raw[away.type][away.name].result_units = { definition("test-native") }
    military.apply()
    local copy = spawn_of(away)
    local sent = copy.attack_parameters.ammo_type.action.action_delivery.projectile
    local sent_copy = assert(dutils.get_prot("entity", sent))
    assert(sent ~= projectile.name)
    local made = sent_copy.action.action_delivery.target_effects[1].entity_name
    assert(made ~= child.name and dutils.get_prot("entity", made).max_health == 1)
    assert(projectile.action.action_delivery.target_effects[1].entity_name == child.name)
    assert(sent_copy.action.action_delivery.target_effects[2].damage.amount == 100)
end)

test("direct and death-spawned copies of one unit scale independently, exactly once", function()
    local parent, child, _, home, away = reset(false)
    table.insert(home.result_units, definition(child.name))
    table.insert(away.result_units, {
        child.name,
        {
            {
                0,
                1,
            },
        },
    })
    unified_starting_data_raw[home.type][home.name] = table.deepcopy(home)
    military.apply()
    local parent_copy = spawn_of(away)
    local child_name = acquisition.read_spawn_definition(away.result_units[2])
    local direct_child = assert(dutils.get_prot("entity", child_name))
    local dying_child = assert(dutils.get_prot("entity", parent_copy.dying_trigger_effect[1].entity_name))
    assert(direct_child.name ~= dying_child.name)
    assert(direct_child.max_health == 2 and dying_child.max_health == 2)
    assert(near(direct_child.attack_parameters.damage_modifier, 1 / 7))
    assert(near(dying_child.attack_parameters.damage_modifier, 1 / 7))
    assert(child.max_health == 100 and child.attack_parameters.damage_modifier == nil)
    assert(parent.max_health == 1000)
end)

test("restoring data between attempts clears the previous copy registry", function()
    reset(false)
    military.apply()
    variants.originals["test-stale"] = "test-parent"
    reset(false)
    military.apply()
    assert(variants.originals["test-stale"] == nil)
end)

print(count .. " tests passed")

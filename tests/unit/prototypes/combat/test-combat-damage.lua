-- Run from the mod root: lua tests/unit/prototypes/combat/test-combat-damage.lua
local damage = require("src/prototypes/combat/combat-damage")
local targets = require("src/prototypes/combat/combat-targets")

local count = 0

local function test(name, check)
    local ok, reason = pcall(check)
    assert(ok, name .. ": " .. tostring(reason))
    count = count + 1
end

local function close(actual, expected)
    assert(type(actual) == "number" and math.abs(actual - expected) < 1e-9, tostring(actual) .. " ~= " .. expected)
end

local function hit(amount)
    return {
        type = "damage",
        damage = {
            type = "test-damage",
            amount = amount,
        },
    }
end

local function ammo(effects)
    return {
        action = {
            type = "direct",
            action_delivery = {
                type = "instant",
                target_effects = effects,
            },
        },
    }
end

local function weapon()
    return {
        type = "projectile",
        cooldown = 6,
        range = 20,
    }
end

local function profile(ammo_type, options, attack_parameters)
    local resolver = damage.new(options)
    local effects, reason = resolver.ammo(ammo_type)
    assert(effects, reason)
    local result
    result, reason = damage.attack(effects, attack_parameters or weapon(), ammo_type)
    assert(result, reason)
    return result, resolver
end

local function target(health)
    return { max_health = health }
end

-- Seconds for a team of deployment weapons (one by default) to kill the entity on its own
local function clear(attack, entity, deployment)
    local resolver = targets.new({ ["test-target"] = entity }, attack.target_options)
    local subject, reason = resolver.target("test-target")
    if subject == nil then
        return nil, reason
    end
    local evaluator
    evaluator, reason = targets.prepare(attack, { subject }, attack.target_options)
    if evaluator == nil then
        return nil, reason
    end
    return evaluator.seconds("test-target", deployment or 1)
end

test("gun bonus and ammo cooldown apply before resistance", function()
    local ammunition = ammo(hit(10))
    ammunition.cooldown_modifier = 2
    local gun = weapon()
    gun.damage_modifier = 3
    local attack = profile(ammunition, nil, gun)
    local entity = target(25)
    entity.resistances = {
        {
            type = "test-damage",
            decrease = 5,
        },
    }
    close(clear(attack, entity), 0.2)
end)

test("flat resistance applies to every hit before adding packets", function()
    local attack = profile(ammo({
        hit(6),
        hit(6),
    }))
    local entity = target(10)
    entity.resistances = {
        {
            type = "test-damage",
            decrease = 5,
        },
    }
    close(clear(attack, entity), 0.5)
end)

test("low damage uses conservative zero instead of assuming a favorable fallback", function()
    close(damage.packet_damage(5, { decrease = 10 }), 0)
    close(damage.packet_damage(20, {
        decrease = 10,
        percent = 50,
    }), 5)
    assert(damage.packet_damage(5, { percent = 101 }) == nil)
end)

test("immunity cannot certify a clear", function()
    local entity = target(1)
    entity.resistances = {
        {
            type = "test-damage",
            percent = 100,
        },
    }
    assert(clear(profile(ammo(hit(100))), entity) == nil)
end)

test("a team's volley adds up on one target", function()
    local attack = profile(ammo(hit(10)))
    close(clear(attack, target(100), 10), 0.1)
    close(clear(attack, target(100), 5), 0.2)
    close(clear(attack, target(100)), 1)
end)

test("healing and slow-heal batching increase clear time", function()
    local attack = profile(ammo(hit(10)))
    local entity = target(100)
    entity.healing_per_tick = 0.01
    close(clear(attack, entity), 1.1)
    entity.healing_per_tick = 2
    assert(clear(attack, entity) == nil)
end)

test("warmup is charged before the first volley", function()
    local gun = weapon()
    gun.warmup = 60
    close(clear(profile(ammo(hit(10)), nil, gun), target(1)), 1.1)
end)

test("deterministic repeated nested effects preserve per-hit counts", function()
    local nested = {
        type = "nested-result",
        repeat_count = 3,
        action = ammo(hit(5)).action,
    }
    local attack = profile(ammo(nested))
    assert(attack.packets[1].count == 3)
    close(clear(attack, target(15)), 0.1)
end)

test("source damage is never target damage", function()
    local ammunition = ammo(hit(1))
    ammunition.action.action_delivery.source_effects = hit(100)
    assert(damage.new().ammo(ammunition) == nil)
end)

test("probabilistic damage is unscored", function()
    local effect = hit(100)
    effect.probability = 0.9
    local result, reason = damage.new().ammo(ammo(effect))
    assert(result == nil and reason == "probabilistic-effect")
end)

test("area damage and filters are not guaranteed single-target hits", function()
    local ammunition = ammo(hit(100))
    ammunition.action.type = "area"
    assert(damage.new().ammo(ammunition) == nil)
    ammunition.action.type = "direct"
    ammunition.action.force = "enemy"
    assert(damage.new().ammo(ammunition) == nil)
    ammunition.action.force = nil
    ammunition.target_type = "position"
    assert(damage.new().ammo(ammunition) == nil)
end)

test("distance-dependent damage fails closed", function()
    local effect = hit(100)
    effect.lower_damage_modifier = 0.5
    assert(damage.new().ammo(ammo(effect)) == nil)
end)

test("damage sparing trees still counts, since trees are never combat targets", function()
    local effect = hit(100)
    effect.apply_damage_to_trees = false
    local result = damage.new().ammo(ammo(effect))
    assert(result ~= nil and result.packets[1].amount == 100)
end)

test("ammo-modified maximum range must exceed the unmodified minimum", function()
    local ammunition = ammo(hit(10))
    local effects = damage.new().ammo(ammunition)
    local gun = weapon()
    gun.min_range = 5
    ammunition.range_modifier = 0.25
    local result, reason = damage.attack(effects, gun, ammunition)
    assert(result == nil and reason == "unusable-attack-range")
    ammunition.range_modifier = 0.2
    assert(damage.attack(effects, gun, ammunition) == nil)
    ammunition.range_modifier = 0.5
    assert(damage.attack(effects, gun, ammunition) ~= nil)
end)

test("invalid ranges and modifiers cannot certify an attack", function()
    local ammunition = ammo(hit(10))
    local effects = damage.new().ammo(ammunition)
    for _, invalid in pairs({
        0,
        -1,
        math.huge,
        0 / 0,
        "unknown",
    }) do
        local gun = weapon()
        gun.range = invalid
        assert(damage.attack(effects, gun, ammunition) == nil)
        gun = weapon()
        ammunition.range_modifier = invalid
        assert(damage.attack(effects, gun, ammunition) == nil)
        ammunition.range_modifier = nil
    end
    local gun = weapon()
    gun.range = nil
    assert(damage.attack(effects, gun, ammunition) == nil)
    gun = weapon()
    gun.min_range = -1
    assert(damage.attack(effects, gun, ammunition) == nil)
    gun.min_range = math.huge
    assert(damage.attack(effects, gun, ammunition) == nil)
    gun.min_range = 0 / 0
    assert(damage.attack(effects, gun, ammunition) == nil)
    gun.min_range = 0
    gun.range = 1e300
    ammunition.range_modifier = 1e300
    assert(damage.attack(effects, gun, ammunition) == nil)
end)

test("visual explosions and impact sounds do not hide direct bullet damage", function()
    local ammunition = ammo({
        {
            type = "create-entity",
            entity_name = "test-flash",
            probability = 0.5,
        },
        {
            type = "activate-impact",
            deliver_category = "test-delivery",
        },
        hit(5),
    })
    local attack = profile(ammunition, {
        entity_of = function()
            return { type = "explosion" }
        end,
        impact_effects = {
            {
                deliver_category = "test-delivery",
                trigger_effect_item = { type = "play-sound" },
            },
        },
    })
    close(clear(attack, target(5)), 0.1)
end)

test("damage hidden in impact combinations is unscored", function()
    local result = damage.new({
        impact_effects = {
            {
                deliver_category = "test-delivery",
                trigger_effect_item = hit(200),
            },
        },
    }).ammo(ammo({
        {
            type = "activate-impact",
            deliver_category = "test-delivery",
        },
        hit(5),
    }))
    assert(result == nil)
end)

test("created damaging explosions need their own target-binding model", function()
    local resolver = damage.new({
        entity_of = function()
            return {
                type = "explosion",
                explosion_effect = ammo(hit(500)).action,
            }
        end,
    })
    assert(resolver.ammo(ammo({
        type = "create-entity",
        entity_name = "test-explosion",
    })) == nil)
end)

test("default projectile flight uses outer range and final action is not killing damage", function()
    local ammunition = {
        action = {
            type = "direct",
            action_delivery = {
                type = "projectile",
                projectile = "test-projectile",
                starting_speed = 1,
            },
        },
    }
    local options = {
        entity_of = function()
            return {
                type = "projectile",
                acceleration = 0,
                action = ammo(hit(10)).action,
                final_action = ammo(hit(1000)).action,
            }
        end,
    }
    local ordinary = profile(ammunition, options)
    assert(not ordinary.unsynchronized_hits)
    close(clear(ordinary, target(20)), 0.2 + 21 / 60)
    options.projectile_time = function()
        return 0.5
    end
    local bounded = profile(ammunition, options)
    assert(bounded.unsynchronized_hits)
    close(clear(bounded, target(20)), 0.7)
end)

-- Shape and numbers follow base/prototypes/entity/projectiles.lua's rocket and explosive-rocket.
-- Names are synthetic so this also exercises the absence of prototype-name dispatch.
test("rocket impact and centered blast retain separate damage packets and gun bonus", function()
    local blast = {
        type = "nested-result",
        action = {
            type = "area",
            radius = 6.5,
            action_delivery = ammo(hit(100)).action.action_delivery,
        },
    }
    local missile = {
        type = "projectile",
        acceleration = 0.01,
        action = ammo({
            hit(50),
            blast,
        }).action,
    }
    local ammunition = {
        action = {
            type = "direct",
            action_delivery = {
                type = "projectile",
                projectile = "test-missile",
                starting_speed = 0.1,
                inherit_speed = true,
            },
        },
    }
    local gun = weapon()
    gun.damage_modifier = 2
    local attack = profile(ammunition, {
        entity_of = function()
            return missile
        end,
    }, gun)
    assert(#attack.packets == 2)
    close(attack.packets[1].amount + attack.packets[2].amount, 300)
    close(attack.delay_seconds, 55 / 60)
    close(clear(attack, target(300)), 0.1 + 55 / 60)
end)

-- Cannon ammo uses position targeting in base/prototypes/item.lua.
test("position-targeted cannon flight respects ammo range and delivery maximum", function()
    local projectile = {
        type = "projectile",
        acceleration = 0,
        action = ammo(hit(1000)).action,
    }
    local ammunition = {
        target_type = "position",
        range_modifier = 1.25,
        action = {
            type = "direct",
            action_delivery = {
                type = "projectile",
                projectile = "test-cannon",
                starting_speed = 1,
                max_range = 15,
            },
        },
    }
    local attack = profile(ammunition, {
        entity_of = function()
            return projectile
        end,
    })
    close(attack.benchmark_range, 15)
    close(attack.delay_seconds, 16 / 60)
end)

-- Railgun ammo's line structure is from space-age/prototypes/item.lua.
test("aimed line damage credits one primary target and honors line range", function()
    local ammunition = {
        target_type = "direction",
        clamp_position = true,
        action = {
            type = "line",
            range = 15,
            width = 1,
            action_delivery = ammo(hit(10000)).action.action_delivery,
        },
    }
    local attack = profile(ammunition)
    close(attack.benchmark_range, 15)
    close(attack.packets[1].line.range, 15)
    close(attack.packets[1].line.width, 1)
    close(clear(attack, target(1)), 0.1)
    local gun = weapon()
    gun.min_range = 15
    assert(damage.attack(damage.new().ammo(ammunition), gun, ammunition) == nil)
end)

test("created explosion area retargets the primary enemy and keeps inherited damage modifier", function()
    local explosion = {
        type = "explosion",
        delay = 30,
        delay_deviation = 30,
        explosion_effect = {
            type = "area",
            radius = 2,
            action_delivery = ammo(hit(25)).action.action_delivery,
        },
    }
    local ammunition = ammo({
        type = "create-explosion",
        entity_name = "test-damaging-flash",
    })
    local gun = weapon()
    gun.damage_modifier = 4
    local options = {
        entity_of = function()
            return explosion
        end,
    }
    local attack = profile(ammunition, options, gun)
    close(attack.packets[1].amount, 100)
    close(attack.delay_seconds, 1)
    assert(attack.unsynchronized_hits)
    close(clear(attack, target(100)), 1.1)
    explosion.explosion_effect = ammo(hit(25)).action
    assert(damage.new(options).ammo(ammunition) == nil)
end)

test("conditional damaging creation remains unscored", function()
    local effect = {
        type = "create-explosion",
        entity_name = "test-flash",
        only_when_visible = true,
    }
    local explosion = {
        type = "explosion",
        explosion_effect = {
            type = "area",
            radius = 1,
            action_delivery = ammo(hit(10)).action.action_delivery,
        },
    }
    assert(damage.new({ entity_of = function() return explosion end }).ammo(ammo(effect)) == nil)
end)

test("projectile deviations and empty flight ranges cannot certify an impact", function()
    local projectile = {
        type = "projectile",
        acceleration = 0,
        action = ammo(hit(10)).action,
    }
    local ammunition = {
        action = {
            type = "direct",
            action_delivery = {
                type = "projectile",
                projectile = "test-projectile",
                starting_speed = 1,
                direction_deviation = 0.1,
            },
        },
    }
    local options = { entity_of = function() return projectile end }
    assert(damage.new(options).ammo(ammunition) == nil)
    ammunition.action.action_delivery.direction_deviation = nil
    ammunition.action.action_delivery.max_range = 1
    ammunition.action.action_delivery.min_range = 1
    assert(damage.new(options).ammo(ammunition) == nil)
end)

test("tile and decorative indirections are validated before ignoring them", function()
    local ammunition = ammo({
        { type = "invoke-tile-trigger" },
        { type = "destroy-decoratives" },
        hit(10),
    })
    assert(damage.new().ammo(ammunition) == nil)
    local options = {
        tile_effects = {
            test_tile = { trigger_effect = { type = "play-sound" } },
        },
        decorative_effects = {
            test_decorative = { trigger_effect = { type = "create-trivial-smoke" } },
        },
    }
    assert(damage.new(options).ammo(ammunition) ~= nil)
    options.tile_effects.test_tile.trigger_effect = hit(100)
    local attack = profile(ammunition, options)
    assert(#attack.packets == 1)
    close(attack.packets[1].amount, 10)
    ammunition.action.action_delivery.source_effects = { type = "invoke-tile-trigger" }
    assert(damage.new(options).ammo(ammunition) == nil)
    ammunition.action.action_delivery.source_effects = nil
    options.tile_effects.test_tile.trigger_effect.damage.amount = -1
    assert(damage.new(options).ammo(ammunition) == nil)
    options.tile_effects.test_tile.trigger_effect = {
        type = "create-entity",
        entity_name = "test-child",
    }
    options.entity_of = function()
        return { type = "unit" }
    end
    assert(damage.new(options).ammo(ammunition) == nil)
end)

test("uncalibrated radial scatter cannot add damage or hide harmful secondary effects", function()
    local scatter = {
        type = "area",
        target_entities = false,
        trigger_from_target = true,
        repeat_count = 1000,
        radius = 7,
        action_delivery = {
            type = "projectile",
            projectile = "test-scatter",
            starting_speed = 0.48,
            starting_speed_deviation = 0.075,
        },
    }
    local scatter_projectile = {
        type = "projectile",
        acceleration = 0,
        action = {
            type = "area",
            radius = 3,
            action_delivery = ammo(hit(100)).action.action_delivery,
        },
    }
    local ammunition = ammo({
        hit(400),
        {
            type = "nested-result",
            action = scatter,
        },
    })
    local options = { entity_of = function() return scatter_projectile end }
    local attack = profile(ammunition, options)
    assert(#attack.packets == 1)
    close(attack.packets[1].amount, 400)
    scatter_projectile.action.action_delivery.target_effects.damage.amount = -100
    assert(damage.new(options).ammo(ammunition) == nil)
end)

test("cyclic effect graphs return a diagnostic", function()
    local ammunition = ammo(nil)
    ammunition.action.action_delivery.target_effects = {
        type = "nested-result",
        action = ammunition.action,
    }
    local result, reason = damage.new().ammo(ammunition)
    assert(result == nil and reason == "effect-cycle")
end)

test("shared DAG results are reused and bounded", function()
    local effect = hit(1)
    local ammunition = ammo({
        effect,
        effect,
        effect,
    })
    local resolver = damage.new({ max_nodes = 5 })
    local first = resolver.ammo(ammunition)
    assert(first ~= nil)
    assert(resolver.ammo(ammunition) == first)
    assert(damage.new({ max_packets = 2 }).ammo(ammunition) == nil)
    assert(damage.new({ max_depth = 2 }).ammo(ammunition) == nil)
    assert(damage.new({ max_nodes = 2 }).ammo(ammunition) == nil)
end)

test("visual target hit/death particles are checked recursively", function()
    local entity = target(10)
    entity.damaged_trigger_effect = {
        type = "create-particle",
        particle_name = "test-particle",
        probability = 0.2,
    }
    entity.dying_explosion = "test-death"
    local options = {
        entity_of = function()
            return {
                type = "explosion",
                created_effect = ammo({ type = "play-sound" }).action,
            }
        end,
        particle_of = function()
            return {
                type = "optimized-particle",
                ended_on_ground_trigger_effect = { type = "create-trivial-smoke" },
            }
        end,
    }
    close(clear(profile(ammo(hit(10)), options), entity), 0.1)
    options.particle_of = function()
        return {
            type = "optimized-particle",
            ended_on_ground_trigger_effect = hit(100),
        }
    end
    assert(clear(profile(ammo(hit(10)), options), entity) == nil)
end)

test("death spawns are targets of their own, and invalid bodies fail closed", function()
    local entity = target(10)
    entity.dying_trigger_effect = {
        type = "create-entity",
        entity_name = "test-child",
    }
    local attack = profile(ammo(hit(10)), {
        entity_of = function()
            return { type = "unit" }
        end,
    })
    close(clear(attack, entity), 0.1)
    local spawned = targets.new({ ["test-target"] = entity }, attack.target_options).spawned("test-target")
    assert(spawned["test-child"] == true)
    entity.dying_trigger_effect = nil
    entity.corpse = "test-corpse"
    close(clear(attack, entity), 0.1)
    spawned = targets.new({ ["test-target"] = entity }, attack.target_options).spawned("test-target")
    assert(spawned["test-corpse"] == true and spawned["test-child"] == nil)
    entity.corpse = nil
    entity.segment_engine = {}
    assert(clear(attack, entity) == nil)
end)

test("visual particle-source entities validate their particles and creation effects", function()
    local entity = target(10)
    entity.damaged_trigger_effect = {
        type = "create-entity",
        entity_name = "test-fountain",
    }
    local source = {
        type = "particle-source",
        particle = "test-particle",
        created_effect = ammo({ type = "play-sound" }).action,
    }
    local particle = {
        type = "optimized-particle",
        ended_on_ground_trigger_effect = { type = "create-trivial-smoke" },
    }
    local options = {
        entity_of = function()
            return source
        end,
        particle_of = function()
            return particle
        end,
    }
    close(clear(profile(ammo(hit(10)), options), entity), 0.1)
    particle.ended_on_ground_trigger_effect = hit(100)
    assert(clear(profile(ammo(hit(10)), options), entity) == nil)
    particle.ended_on_ground_trigger_effect = nil
    source.created_effect = ammo(hit(100)).action
    assert(clear(profile(ammo(hit(10)), options), entity) == nil)
end)

test("candidate properties are read live rather than captured reference stats", function()
    local attack = profile(ammo(hit(10)))
    local entity = target(10)
    close(clear(attack, entity), 0.1)
    entity.max_health = 100
    close(clear(attack, entity), 1)
end)

test("invalid numeric inputs cannot produce a successful score", function()
    local attack = profile(ammo(hit(10)))
    assert(clear(attack, target(10), 0) == nil)
    assert(clear(attack, target(math.huge)) == nil)
    assert(clear(attack, target(10), 0.5) == nil)
    local entity = target(10)
    entity.healing_per_tick = 0 / 0
    assert(clear(attack, entity) == nil)
end)

-- The beam fixtures follow the laser turret (base/prototypes/entity/turrets.lua, base/prototypes/entity/beams.lua) and the tesla turret (space-age/prototypes/entity/turrets.lua)
local function beam_ammo(duration)
    return {
        action = {
            type = "direct",
            action_delivery = {
                type = "beam",
                beam = "test-beam",
                duration = duration,
                max_length = 24,
            },
        },
    }
end

local function beam_options(beam, extra)
    local prototypes = {
        ["test-beam"] = beam,
    }
    for name, prototype in pairs(extra or {}) do
        prototypes[name] = prototype
    end
    return {
        entity_of = function(name)
            return prototypes[name]
        end,
    }
end

test("a beam waiting for its shooter hits once per shot, one triggering by itself every whole damage interval", function()
    local beam = {
        type = "beam",
        damage_interval = 20,
        action = ammo(hit(10)).action,
    }
    local laser = {
        type = "beam",
        cooldown = 40,
        range = 30,
        damage_modifier = 2,
    }
    local attack = profile(beam_ammo(40), beam_options(beam), laser)
    assert(#attack.packets == 1 and attack.packets[1].count == 1)
    close(attack.packets[1].amount, 20)
    close(attack.interval_seconds, 40 / 60)
    close(attack.benchmark_range, 24)
    close(clear(attack, target(100), 5), 40 / 60)
    beam.action_triggered_automatically = true
    attack = profile(beam_ammo(40), beam_options(beam), laser)
    assert(attack.packets[1].count == 2)
    attack = profile(beam_ammo(30), beam_options(beam), laser)
    assert(attack.packets[1].count == 1)
    assert(damage.new(beam_options(beam)).ammo(beam_ammo(10)) == nil)
end)

test("a chain adds nothing to the aimed target and only has to be harmless", function()
    local bounce = {
        type = "beam",
        damage_interval = 20,
        action = ammo({
            hit(120),
            {
                type = "push-back",
                distance = 0.25,
            },
            {
                type = "create-sticker",
                sticker = "test-stun",
            },
        }).action,
    }
    local start = {
        type = "beam",
        damage_interval = 20,
        action = bounce.action,
    }
    local chain = {
        type = "chain-active-trigger",
        action = {
            type = "direct",
            action_delivery = {
                type = "beam",
                beam = "test-bounce",
                duration = 30,
            },
        },
    }
    local tesla = ammo({
        {
            type = "nested-result",
            action = {
                type = "direct",
                action_delivery = {
                    type = "chain",
                    chain = "test-chain",
                },
            },
        },
        {
            type = "nested-result",
            action = {
                type = "direct",
                action_delivery = {
                    type = "beam",
                    beam = "test-beam",
                    duration = 30,
                    max_length = 40,
                },
            },
        },
    })
    local options = beam_options(start, {
        ["test-bounce"] = bounce,
        ["test-stun"] = {
            type = "sticker",
            name = "test-stun",
            duration_in_ticks = 30,
        },
    })
    options.chain_of = function(name)
        return name == "test-chain" and chain or nil
    end
    local attack = profile(tesla, options, {
        type = "beam",
        cooldown = 120,
        range = 30,
    })
    assert(#attack.packets == 1 and #attack.dots == 0)
    close(attack.packets[1].amount, 120)
    bounce.action = ammo(hit(-5)).action
    assert(damage.new(options).ammo(tesla) == nil)
end)

-- The stream fixtures follow the flamethrower turret (base/prototypes/entity/turrets.lua) and its fire stream and sticker (base/prototypes/entity/fire.lua)
local function stream_setup()
    local sticker = {
        type = "sticker",
        name = "test-fire",
        damage_per_tick = {
            type = "fire",
            amount = 10,
        },
        damage_interval = 10,
        duration_in_ticks = 1800,
    }
    local stream = {
        type = "stream",
        particle_spawn_interval = 2,
        particle_spawn_timeout = 8,
        particle_horizontal_speed = 0.25,
        particle_horizontal_speed_deviation = 0.025,
        action = {
            {
                type = "area",
                radius = 2.5,
                action_delivery = {
                    type = "instant",
                    target_effects = {
                        {
                            type = "create-sticker",
                            sticker = "test-fire",
                        },
                        {
                            type = "damage",
                            apply_damage_to_trees = false,
                            damage = {
                                type = "fire",
                                amount = 3,
                            },
                        },
                    },
                },
            },
            {
                type = "direct",
                action_delivery = {
                    type = "instant",
                    target_effects = {
                        type = "create-fire",
                        entity_name = "test-flame",
                    },
                },
            },
        },
    }
    local ammo_type = {
        action = {
            type = "direct",
            action_delivery = {
                type = "stream",
                stream = "test-stream",
            },
        },
    }
    local turret = {
        type = "stream",
        cooldown = 4,
        range = 30,
        min_range = 6,
    }
    local options = {
        entity_of = function(name)
            return ({
                ["test-stream"] = stream,
                ["test-fire"] = sticker,
            })[name]
        end,
    }
    return ammo_type, turret, options, stream, sticker
end

test("stream particles land on the aimed target: their area damage counts, the ground fire doesn't", function()
    local ammo_type, turret, options = stream_setup()
    local summary = assert(damage.new(options).ammo(ammo_type))
    local attack = assert(damage.attack(summary, turret, ammo_type, 1.1))
    assert(#attack.packets == 1 and #attack.dots == 1)
    close(attack.packets[1].amount, 3.3)
    -- One particle per shot or per spawn interval, whichever is longer
    close(attack.interval_seconds, 4 / 60)
    -- 30 tiles at the slowest horizontal speed, 0.225 tiles a tick
    close(attack.delay_seconds, math.ceil(30 / 0.225) / 60)
    -- A target without stickers takes only the direct hits: 3.3 a volley
    close(clear(attack, target(100)), attack.delay_seconds + (1 + math.ceil(96.7 / 3.3)) * 4 / 60)
end)

test("a sticker damages over time only targets it can stick to, and only once however often it's applied", function()
    local ammo_type, turret, options = stream_setup()
    local attack = assert(damage.attack(assert(damage.new(options).ammo(ammo_type)), turret, ammo_type))
    local unit = target(100)
    unit.type = "unit"
    -- 60 a second from the sticker, one application held back as lag
    local net = 3 + 60 * 4 / 60
    close(clear(attack, unit), attack.delay_seconds + (1 + math.ceil((100 - 3 + 10) / net)) * 4 / 60)
    close(clear(attack, unit, 10), attack.delay_seconds + (1 + math.ceil((100 - 30 + 10) / (30 + 4))) * 4 / 60)
    unit.resistances = {
        {
            type = "fire",
            percent = 100,
        },
    }
    assert(clear(attack, unit) == nil)
end)

test("streams that can't be modeled leave the ammo unscored", function()
    local ammo_type, turret, options, stream, sticker = stream_setup()
    local summary = assert(damage.new(options).ammo(ammo_type))
    local reason
    summary, reason = damage.attack(summary, weapon(), ammo_type)
    assert(summary == nil and reason == "unsupported-attack-delivery")
    stream.initial_action = stream.action
    summary, reason = damage.new(options).ammo(ammo_type)
    assert(summary == nil and reason == "unsupported-initial-stream-action")
    stream.initial_action = nil
    stream.target_position_deviation = 1
    summary, reason = damage.new(options).ammo(ammo_type)
    assert(summary == nil and reason == "variable-stream-landing")
    stream.target_position_deviation = nil
    sticker.damage_per_tick.amount = -1
    assert(damage.new(options).ammo(ammo_type) == nil)
    sticker.damage_per_tick.amount = 10
    stream.action[1].action_delivery.target_effects[1].probability = 0.5
    assert(damage.new(options).ammo(ammo_type) == nil)
    -- A fluid's damage modifier has to be positive
    local fresh_ammo, fresh_turret, fresh_options = stream_setup()
    local fresh = assert(damage.new(fresh_options).ammo(fresh_ammo))
    assert(damage.attack(fresh, fresh_turret, fresh_ammo, 0) == nil)
end)

test("push-back is harmless", function()
    local result = damage.new().ammo(ammo({
        hit(10),
        {
            type = "push-back",
            distance = 0.5,
        },
    }))
    assert(result ~= nil and #result.packets == 1)
end)

print("combat-damage: " .. count .. " tests passed")

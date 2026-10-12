-- Run from the mod root: lua tests/unit/prototypes/combat/test-combat-targets.lua
local targets = require("src/prototypes/combat/combat-targets")

local count = 0

local function test(name, check)
    local okay, reason = pcall(check)
    assert(okay, name .. ": " .. tostring(reason))
    count = count + 1
end

local function close(actual, expected)
    assert(type(actual) == "number" and math.abs(actual - expected) < 1e-9, tostring(actual) .. " ~= " .. expected)
end

local function profile(amount)
    return {
        packets = {
            {
                type = "test-damage",
                amount = amount,
                count = 1,
            },
        },
        interval_seconds = 1,
    }
end

local function roster(name, amount)
    return {
        {
            entity = name,
            amount = amount or 1,
        },
    }
end

local function spawn(name, extra)
    local result = {
        type = "create-entity",
        entity_name = name,
    }
    for key, value in pairs(extra or {}) do
        result[key] = value
    end
    return result
end

local function indexed(workload)
    local result = {}
    for _, target in pairs(workload) do
        result[target.entity] = target.amount
    end
    return result
end

local function options(entities)
    return {
        entity_of = function(name) return entities[name] end,
        visual_effect = function(effect)
            if effect.type == "play-sound" or effect.type == "create-trivial-smoke" then
                return true
            end
            return nil, "test-nonvisual-effect"
        end,
        visual_entity = function(entity)
            return entity.type == "explosion" and entity.created_effect == nil and entity.explosion_effect == nil
        end,
    }
end

test("ordinary targets retain whole volleys and deployment limits", function()
    local entities = { ["test-unit"] = { max_health = 11 } }
    close(targets.clear_seconds(profile(10), roster("test-unit", 3), entities, 1), 6)
    close(targets.clear_seconds(profile(10), roster("test-unit", 3), entities, 10), 1)
end)

test("ten independent shooters clear tiny targets in parallel", function()
    local entities = { ["test-fragment"] = { max_health = 1 } }
    close(targets.clear_seconds(profile(10), roster("test-fragment", 27), entities, 10), 3)
    close(targets.clear_seconds(profile(10), roster("test-fragment", 27), entities, 1), 27)
end)

test("a firing team can focus multiple shooters without sharing overkill", function()
    local entities = { ["test-target"] = { max_health = 11 } }
    local seconds, reason, _, schedule = targets.clear_seconds(profile(10), roster("test-target", 3), entities, 10)
    assert(seconds, reason)
    close(seconds, 1)
    assert(schedule.team_size == 2 and schedule.teams == 5)
end)

test("regeneration can require the full team", function()
    local entities = {
        ["test-target"] = {
            max_health = 150,
            healing_per_tick = 1.5,
        },
    }
    local seconds, reason, _, schedule = targets.clear_seconds(profile(10), roster("test-target"), entities, 10)
    assert(seconds, reason)
    close(seconds, 7)
    assert(schedule.team_size == 10 and schedule.teams == 1)
end)

test("fragments wait for their parents even when other shooters are idle", function()
    local entities = {
        ["test-parent"] = {
            max_health = 10,
            dying_trigger_effect = spawn("test-child"),
        },
        ["test-child"] = {
            max_health = 10,
            dying_trigger_effect = spawn("test-grandchild"),
        },
        ["test-grandchild"] = { max_health = 10 },
    }
    local seconds, reason, workload, schedule = targets.clear_seconds(profile(10), roster("test-parent"), entities, 10)
    assert(seconds, reason)
    close(seconds, 3)
    assert(schedule.phase_times[0] == 1 and schedule.phase_times[1] == 1 and schedule.phase_times[2] == 1)
    assert(#workload == 3)
end)

test("repeated jobs balance occupied teams without expanding target instances", function()
    local entities = {
        ["test-heavy"] = { max_health = 600 },
        ["test-light"] = { max_health = 100 },
    }
    local group = {
        {
            entity = "test-heavy",
            amount = 1,
        },
        {
            entity = "test-light",
            amount = 100,
        },
    }
    close(targets.clear_seconds(profile(100), group, entities, 3), 36)
    close(targets.clear_seconds(profile(100), roster("test-light", 100000000), entities, 10), 10000000)
end)

test("prepared phase evaluation does not spawn descendants a second time", function()
    local entities = {
        ["test-parent"] = {
            max_health = 10,
            dying_trigger_effect = spawn("test-child", { repeat_count = 3 }),
        },
        ["test-child"] = { max_health = 10 },
    }
    local resolver = targets.new(entities)
    local workload = resolver.workload(roster("test-parent"))
    local evaluator = targets.prepare(profile(10), workload)
    close(evaluator.seconds("test-parent", 1), 1)
    close(evaluator.schedule({ ["test-parent"] = 1 }, 10), 1)
    close(evaluator.schedule({ ["test-child"] = 3 }, 10), 1)
    close(evaluator.schedule({}, 10), 0)
    close(evaluator.schedule({ ["test-child"] = 0 }, 10), 0)
end)

test("an entity present initially and spawned later keeps separate generations", function()
    local entities = {
        ["test-parent"] = {
            max_health = 10,
            dying_trigger_effect = spawn("test-child"),
        },
        ["test-child"] = { max_health = 10 },
    }
    local group = {
        {
            entity = "test-parent",
            amount = 1,
        },
        {
            entity = "test-child",
            amount = 1,
        },
    }
    local seconds, reason, workload = targets.clear_seconds(profile(10), group, entities, 10)
    assert(seconds, reason)
    close(seconds, 2)
    for _, target in pairs(workload) do
        if target.entity == "test-child" then
            assert(target.amount == 2 and target.phases[0] == 1 and target.phases[1] == 1)
        end
    end
end)

test("segment count does not multiply the shared health pool", function()
    local entities = {
        ["test-head"] = {
            max_health = 100,
            segment_engine = {
                segments = {
                    { segment = "test-body" },
                    { segment = "test-body" },
                },
            },
        },
        ["test-body"] = { max_health = 900 },
    }
    close(targets.clear_seconds(profile(100), roster("test-head"), entities, 1), 1)
end)

test("segment resistance uses the least damaging complete hit", function()
    local entities = {
        ["test-head"] = {
            max_health = 100,
            segment_engine = { segments = { { segment = "test-body" } } },
            resistances = {
                {
                    type = "test-damage",
                    percent = 25,
                },
            },
        },
        ["test-body"] = {
            resistances = {
                {
                    type = "test-damage",
                    decrease = 20,
                    percent = 50,
                },
            },
        },
    }
    close(targets.clear_seconds(profile(100), roster("test-head"), entities, 1), 3)
    close(targets.clear_seconds(profile(100), roster("test-head"), entities, 1, { segment_aim = "head" }), 2)
    entities["test-body"].resistances[1].percent = 100
    local seconds, reason = targets.clear_seconds(profile(100), roster("test-head"), entities, 1)
    assert(seconds == nil and reason == "insufficient-damage")
end)

test("head regeneration is charged once and can defeat a counter", function()
    local entities = {
        ["test-head"] = {
            max_health = 100,
            healing_per_tick = 1,
            segment_engine = { segments = { { segment = "test-body" } } },
        },
        ["test-body"] = { max_health = 100 },
    }
    close(targets.clear_seconds(profile(100), roster("test-head"), entities, 1), 1)
    close(targets.clear_seconds(profile(99), roster("test-head"), entities, 1), 2)
    local seconds, reason = targets.clear_seconds(profile(60), roster("test-head"), entities, 1)
    assert(seconds == nil and reason == "insufficient-damage")
end)

test("a lethal volley does not assume separated packets beat regeneration", function()
    local entities = {
        ["test-unit"] = {
            max_health = 100,
            healing_per_tick = 2,
        },
    }
    close(targets.clear_seconds(profile(100), roster("test-unit"), entities, 1), 1)
    local delayed = profile(100)
    delayed.delay_seconds = 1
    close(targets.clear_seconds(delayed, roster("test-unit"), entities, 1), 2)
    delayed.packets[1].amount = 50
    table.insert(delayed.packets, {
        type = "test-damage",
        amount = 50,
        count = 1,
    })
    local seconds, reason = targets.clear_seconds(delayed, roster("test-unit"), entities, 1)
    assert(seconds == nil and reason == "insufficient-damage")
end)

test("successive projectile volleys share the initial flight delay", function()
    local entities = { ["test-unit"] = { max_health = 100 } }
    local attack = profile(10)
    attack.delay_seconds = 3
    close(targets.clear_seconds(attack, roster("test-unit"), entities, 1), 13)
    close(targets.clear_seconds(attack, roster("test-unit", 2), entities, 1), 26)
    entities["test-unit"].healing_per_tick = 0.1
    -- Ten damage per second exceeds six healing per second despite the three-second flight.
    close(targets.clear_seconds(attack, roster("test-unit"), entities, 1), 27)
end)

test("warmup and fixed flight do not heal an undamaged full-health target", function()
    local entities = {
        ["test-target"] = {
            max_health = 100,
            healing_per_tick = 1,
        },
    }
    local attack = profile(99)
    close(targets.clear_seconds(attack, roster("test-target"), entities, 1), 2)
    attack.warmup_seconds = 30
    attack.delay_seconds = 10
    close(targets.clear_seconds(attack, roster("test-target"), entities, 1), 42)
end)

test("fast regeneration uses tick cadence and a three-volley shared-health benchmark", function()
    -- Data shape verified in space-age/prototypes/entity/enemies.lua and turrets.lua.
    local entities = {
        ["test-head"] = {
            max_health = 100000,
            healing_per_tick = 130,
            resistances = {
                {
                    type = "test-damage",
                    percent = 50,
                },
            },
            segment_engine = { segments = { { segment = "test-body" } } },
        },
        ["test-body"] = {
            max_health = 100000,
            resistances = {
                {
                    type = "test-damage",
                    percent = 50,
                    decrease = 5,
                },
            },
        },
    }
    local attack = profile(10000)
    attack.interval_seconds = 170 / 60
    close(targets.clear_seconds(attack, roster("test-head"), entities, 10), 8.5)
    -- More health/regeneration can remain impossible under the single-primary-hit benchmark.
    entities["test-head"].max_health = 300000
    entities["test-head"].healing_per_tick = 400
    local seconds, reason = targets.clear_seconds(attack, roster("test-head"), entities, 10)
    assert(seconds == nil and reason == "insufficient-damage")
end)

local function straight_body(scale)
    local head = {
        max_health = 100,
        collision_box = {
            {
                -5 * scale,
                -2 * scale,
            },
            {
                5 * scale,
                3 * scale,
            },
        },
        backward_padding = scale,
        segment_engine = {
            segments = {
                {segment = "test-body"},
                {segment = "test-body"},
            },
        },
    }
    local body = {
        collision_box = {
            {
                -7 * scale,
                -scale,
            },
            {
                7 * scale,
                2 * scale,
            },
        },
        forward_padding = 2 * scale,
        backward_padding = 3 * scale,
    }
    return {
        ["test-head"] = head,
        ["test-body"] = body,
    }
end

local function line_profile(amount, distance, range)
    local result = profile(amount)
    result.benchmark_range = distance
    result.packets[1].line = {
        range = range,
        width = 1,
    }
    return result
end

local function prepared_line(attack, entities)
    local workload = assert(targets.new(entities).workload(roster("test-head")))
    return targets.prepare(attack, workload, {segment_line_geometry = "head-on"})
end

test("line intersections use independently measured asymmetric-box spacing and scale", function()
    -- SEGMENTPROBE on Factorio 2.1.20 observed centers 0, 6.5, 13 and 0, 13, 26.
    local entities = straight_body(1)
    local prepared = assert(prepared_line(line_profile(10, 40, 50), entities))
    local amount, hits = prepared.shot_damage("test-head")
    close(amount, 20)
    assert(hits[1] == 2)
    prepared = assert(prepared_line(line_profile(10, 40, 54), entities))
    close(prepared.shot_damage("test-head"), 30)
    prepared = assert(prepared_line(line_profile(10, 40, 50), straight_body(2)))
    close(prepared.shot_damage("test-head"), 10)
end)

test("line endpoint margins do not credit an uncertain body boundary", function()
    local entities = straight_body(1)
    local prepared = assert(prepared_line(line_profile(10, 40, 46.5), entities))
    close(prepared.shot_damage("test-head"), 10)
    prepared = assert(prepared_line(line_profile(10, 40, 46.6), entities))
    close(prepared.shot_damage("test-head"), 20)
end)

test("line damage applies each part's resistance before shared health and regeneration", function()
    local entities = straight_body(1)
    entities["test-head"].resistances = {
        {
            type = "test-damage",
            percent = 50,
        },
    }
    entities["test-body"].resistances = {
        {
            type = "test-damage",
            decrease = 8,
        },
    }
    entities["test-head"].max_health = 9
    entities["test-head"].healing_per_tick = 1
    local attack = line_profile(10, 40, 54)
    local prepared = assert(prepared_line(attack, entities))
    close(prepared.shot_damage("test-head"), 9)
    close(prepared.seconds("test-head", 1), 1)
    entities["test-head"].max_health = 10
    prepared = assert(prepared_line(attack, entities))
    assert(prepared.seconds("test-head", 1) == nil)
end)

test("ordinary packets do not inherit a neighboring line's body hits", function()
    local entities = straight_body(1)
    local attack = line_profile(10, 40, 54)
    table.insert(attack.packets, {
        type = "test-damage",
        amount = 5,
        count = 1,
    })
    local prepared = assert(prepared_line(attack, entities))
    close(prepared.shot_damage("test-head"), 35)
    local workload = assert(targets.new(entities).workload(roster("test-head")))
    prepared = assert(targets.prepare(attack, workload))
    close(prepared.shot_damage("test-head"), 15)
end)

test("invalid or rotated geometry fails closed only when line body hits are requested", function()
    local entities = straight_body(1)
    entities["test-body"].collision_box[3] = 0.25
    local prepared, reason = prepared_line(line_profile(10, 40, 54), entities)
    assert(prepared == nil and reason == "unsupported-segment-geometry")
    assert(prepared_line(profile(10), entities))
    local attack = line_profile(10, 40, 54)
    attack.packets[1].line.width = 0
    prepared, reason = prepared_line(attack, entities)
    assert(prepared == nil and reason == "invalid-line-geometry")
end)

test("installed-data-shaped line benchmark clears the large shared-health target", function()
    -- Geometry/stats are from space-age/prototypes/entity/enemies.lua; source timing/range from turrets.lua/item.lua.
    local entities = straight_body(1)
    local head = entities["test-head"]
    head.collision_box = {
        {
            -3,
            -3,
        },
        {
            3,
            3,
        },
    }
    head.backward_padding = -2.5
    head.max_health = 300000
    head.healing_per_tick = 400
    head.resistances = {
        {
            type = "test-damage",
            percent = 50,
        },
    }
    head.segment_engine.segments = {}
    local scales = {
        1.09,
        1.27,
        1.36,
        1.36,
    }
    for index, scale in pairs(scales) do
        local name = "test-body-" .. index
        entities[name] = {
            collision_box = {
                {
                    -3 * scale,
                    -scale,
                },
                {
                    3 * scale,
                    scale,
                },
            },
            forward_padding = -0.5 * scale,
            backward_padding = 1.5 * scale,
            resistances = {
                {
                    type = "test-damage",
                    decrease = 5,
                    percent = 50,
                },
            },
        }
        table.insert(head.segment_engine.segments, {segment = name})
    end
    local attack = line_profile(10000, 40, 50)
    attack.interval_seconds = 170 / 60
    local prepared = assert(prepared_line(attack, entities))
    local amount, hits = prepared.shot_damage("test-head")
    close(amount, 19992.5)
    assert(hits[1] == 4)
    close(prepared.seconds("test-head", 10), 340 / 60)
end)

test("slow regeneration retains its once-per-second phase margin between hits", function()
    local entities = {
        ["test-target"] = {
            max_health = 10.7,
            healing_per_tick = 0.01,
        },
    }
    local attack = profile(5.6)
    attack.interval_seconds = 0.5
    -- A slow-heal batch may occur between the two volleys, so 11.2 damage is insufficient.
    close(targets.clear_seconds(attack, roster("test-target"), entities, 1), 1.5)
end)

test("variable delivery delays cannot combine shooters into an atomic lethal volley", function()
    local entities = {
        ["test-target"] = {
            max_health = 100,
            healing_per_tick = 100,
        },
    }
    local attack = profile(10)
    attack.delay_seconds = 1
    close(targets.clear_seconds(attack, roster("test-target"), entities, 10), 2)
    attack.unsynchronized_hits = true
    local seconds, reason = targets.clear_seconds(attack, roster("test-target"), entities, 10)
    assert(seconds == nil and reason == "insufficient-damage")
end)

test("missing segments fail instead of silently using head stats", function()
    local entities = {
        ["test-head"] = {
            max_health = 100,
            segment_engine = { segments = { { segment = "test-missing" } } },
        },
    }
    local seconds, reason = targets.clear_seconds(profile(100), roster("test-head"), entities, 1)
    assert(seconds == nil and reason == "missing-segment")
end)

test("asteroid fragments recurse with offset multiplicity and terminal chunks", function()
    local entities = {
        ["test-large"] = {
            max_health = 100,
            dying_trigger_effect = spawn("test-medium", {
                offsets = {
                    {
                        0,
                        0,
                    },
                    {
                        1,
                        0,
                    },
                    {
                        2,
                        0,
                    },
                },
            }),
        },
        ["test-medium"] = {
            max_health = 100,
            dying_trigger_effect = spawn("test-small", { repeat_count = 3 }),
        },
        ["test-small"] = {
            max_health = 100,
            dying_trigger_effect = {
                type = "create-asteroid-chunk",
                asteroid_name = "test-chunk",
            },
        },
    }
    local seconds, reason, workload = targets.clear_seconds(profile(100), roster("test-large", 2), entities, 1)
    assert(seconds, reason)
    close(seconds, 26)
    local counts = indexed(workload)
    assert(counts["test-large"] == 2 and counts["test-medium"] == 6 and counts["test-small"] == 18)
    assert(counts["test-chunk"] == nil)
end)

test("rare death spawns use maximum counts instead of expected counts", function()
    local entities = {
        ["test-parent"] = {
            max_health = 10,
            dying_trigger_effect = spawn("test-child", {
                repeat_count = 2,
                repeat_count_deviation = 3,
                probability = 0.01,
            }),
        },
        ["test-child"] = { max_health = 10 },
    }
    close(targets.clear_seconds(profile(10), roster("test-parent"), entities, 1), 6)
end)

test("body death effects contribute once per physical segment", function()
    local entities = {
        ["test-head"] = {
            max_health = 10,
            segment_engine = {
                segments = {
                    { segment = "test-body" },
                    { segment = "test-body" },
                },
            },
        },
        ["test-body"] = { dying_trigger_effect = spawn("test-child", { repeat_count = 2 }) },
        ["test-child"] = { max_health = 10 },
    }
    close(targets.clear_seconds(profile(10), roster("test-head"), entities, 1), 5)
end)

test("passive remains are omitted but their created children are retained", function()
    local entities = {
        ["test-head"] = {
            max_health = 10,
            dying_trigger_effect = spawn("test-remains"),
        },
        ["test-remains"] = {
            type = "simple-entity",
            max_health = 2000,
        },
        ["test-child"] = { max_health = 10 },
    }
    close(targets.clear_seconds(profile(10), roster("test-head"), entities, 1), 1)
    entities["test-remains"].created_effect = {
        type = "direct",
        action_delivery = {
            type = "instant",
            target_effects = spawn("test-child"),
        },
    }
    close(targets.clear_seconds(profile(10), roster("test-head"), entities, 1), 2)
end)

test("visual fragments need visual validation and cannot hide damaging effects", function()
    local entities = {
        ["test-parent"] = {
            max_health = 10,
            dying_trigger_effect = spawn("test-explosion"),
        },
        ["test-explosion"] = { type = "explosion" },
    }
    close(targets.clear_seconds(profile(10), roster("test-parent"), entities, 1, options(entities)), 1)
    entities["test-explosion"].created_effect = { type = "unknown-damage" }
    local seconds, reason = targets.clear_seconds(profile(10), roster("test-parent"), entities, 1, options(entities))
    assert(seconds == nil and reason == "unsupported-created-target")
end)

test("spawn cycles and effect cycles fail closed", function()
    local entities = {
        ["test-first"] = {
            max_health = 10,
            dying_trigger_effect = spawn("test-second"),
        },
        ["test-second"] = {
            max_health = 10,
            dying_trigger_effect = spawn("test-first"),
        },
    }
    local seconds, reason = targets.clear_seconds(profile(10), roster("test-first"), entities, 1)
    assert(seconds == nil and reason == "target-spawn-cycle")
    local cycle = {}
    cycle[1] = cycle
    entities["test-first"].dying_trigger_effect = cycle
    seconds, reason = targets.clear_seconds(profile(10), roster("test-first"), entities, 1)
    assert(seconds == nil and reason == "target-effect-cycle")
end)

test("large repeated trees remain compact and bounded", function()
    local entities = { ["test-leaf"] = { max_health = 10 } }
    local previous = "test-leaf"
    for i = 1, 12 do
        local name = "test-level-" .. i
        entities[name] = {
            max_health = 10,
            dying_trigger_effect = spawn(previous, { repeat_count = 2 }),
        }
        previous = name
    end
    local resolver = targets.new(entities)
    local workload, reason = resolver.workload(roster(previous))
    assert(workload, reason)
    assert(#workload == 13 and indexed(workload)["test-leaf"] == 4096)
    resolver = targets.new(entities, { max_count = 1000 })
    workload, reason = resolver.workload(roster(previous))
    assert(workload == nil and reason == "target-count-budget")
    resolver = targets.new(entities, { max_depth = 3 })
    workload, reason = resolver.workload(roster(previous))
    assert(workload == nil and reason == "target-depth-budget")
end)

test("fresh candidates use changed fragment health and resistance", function()
    local entities = {
        ["test-parent"] = {
            max_health = 10,
            dying_trigger_effect = spawn("test-child"),
        },
        ["test-child"] = { max_health = 10 },
    }
    close(targets.clear_seconds(profile(10), roster("test-parent"), entities, 1), 2)
    entities["test-child"].max_health = 30
    entities["test-child"].resistances = {
        {
            type = "test-damage",
            percent = 50,
        },
    }
    close(targets.clear_seconds(profile(10), roster("test-parent"), entities, 1), 7)
end)

test("shared death effects do not accumulate another target's creation effects", function()
    local death = spawn("test-child")
    local entities = {
        ["test-first"] = {
            max_health = 10,
            dying_trigger_effect = death,
            created_effect = {
                type = "direct",
                action_delivery = {
                    type = "instant",
                    target_effects = spawn("test-child"),
                },
            },
        },
        ["test-second"] = {
            max_health = 10,
            dying_trigger_effect = death,
        },
        ["test-child"] = { max_health = 10 },
    }
    local workload = {
        {
            entity = "test-first",
            amount = 1,
        },
        {
            entity = "test-second",
            amount = 1,
        },
    }
    close(targets.clear_seconds(profile(10), workload, entities, 1), 5)
end)

test("negative regeneration is not credited as extra weapon damage", function()
    local entities = {
        ["test-unit"] = {
            max_health = 100,
            healing_per_tick = -100,
        },
    }
    close(targets.clear_seconds(profile(10), roster("test-unit"), entities, 1), 10)
end)

print("combat targets: " .. count .. " tests passed")

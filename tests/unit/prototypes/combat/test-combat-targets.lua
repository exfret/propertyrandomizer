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

-- Seconds for a team of identical weapons to kill the named target on its own
local function seconds(attack, entities, name, team, extra)
    local subject, reason = targets.new(entities, extra).target(name)
    if subject == nil then
        return nil, reason
    end
    local evaluator
    evaluator, reason = targets.prepare(attack, { subject }, extra)
    if evaluator == nil then
        return nil, reason
    end
    return evaluator.seconds(name, team or 1)
end

local function names(set)
    local result = {}
    for name, _ in pairs(set) do
        table.insert(result, name)
    end
    table.sort(result)
    return table.concat(result, ",")
end

test("volleys stay whole and a team's add up on one target", function()
    local entities = { ["test-unit"] = { max_health = 11 } }
    close(seconds(profile(10), entities, "test-unit"), 2)
    close(seconds(profile(10), entities, "test-unit", 10), 1)
    local result, reason = seconds(profile(10), entities, "test-unit", 0)
    assert(result == nil and reason == "invalid-deployment-count")
end)

test("regeneration can require the full team", function()
    local entities = {
        ["test-target"] = {
            max_health = 150,
            healing_per_tick = 1.5,
        },
    }
    close(seconds(profile(10), entities, "test-target", 10), 7)
    local result, reason = seconds(profile(10), entities, "test-target", 9)
    assert(result == nil and reason == "insufficient-damage")
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
    close(seconds(profile(100), entities, "test-head"), 1)
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
    close(seconds(profile(100), entities, "test-head"), 3)
    close(seconds(profile(100), entities, "test-head", 1, { segment_aim = "head" }), 2)
    entities["test-body"].resistances[1].percent = 100
    local result, reason = seconds(profile(100), entities, "test-head")
    assert(result == nil and reason == "insufficient-damage")
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
    close(seconds(profile(100), entities, "test-head"), 1)
    close(seconds(profile(99), entities, "test-head"), 2)
    local result, reason = seconds(profile(60), entities, "test-head")
    assert(result == nil and reason == "insufficient-damage")
end)

test("a lethal volley does not assume separated packets beat regeneration", function()
    local entities = {
        ["test-unit"] = {
            max_health = 100,
            healing_per_tick = 2,
        },
    }
    close(seconds(profile(100), entities, "test-unit"), 1)
    local delayed = profile(100)
    delayed.delay_seconds = 1
    close(seconds(delayed, entities, "test-unit"), 2)
    delayed.packets[1].amount = 50
    table.insert(delayed.packets, {
        type = "test-damage",
        amount = 50,
        count = 1,
    })
    local result, reason = seconds(delayed, entities, "test-unit")
    assert(result == nil and reason == "insufficient-damage")
end)

test("successive projectile volleys share the initial flight delay", function()
    local entities = { ["test-unit"] = { max_health = 100 } }
    local attack = profile(10)
    attack.delay_seconds = 3
    close(seconds(attack, entities, "test-unit"), 13)
    entities["test-unit"].healing_per_tick = 0.1
    -- Ten damage per second exceeds six healing per second despite the three-second flight.
    close(seconds(attack, entities, "test-unit"), 27)
end)

test("warmup and fixed flight do not heal an undamaged full-health target", function()
    local entities = {
        ["test-target"] = {
            max_health = 100,
            healing_per_tick = 1,
        },
    }
    local attack = profile(99)
    close(seconds(attack, entities, "test-target"), 2)
    attack.warmup_seconds = 30
    attack.delay_seconds = 10
    close(seconds(attack, entities, "test-target"), 42)
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
    close(seconds(attack, entities, "test-head", 10), 8.5)
    -- More health/regeneration can remain impossible under the single-primary-hit benchmark.
    entities["test-head"].max_health = 300000
    entities["test-head"].healing_per_tick = 400
    local result, reason = seconds(attack, entities, "test-head", 10)
    assert(result == nil and reason == "insufficient-damage")
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
    local subject = assert(targets.new(entities).target("test-head"))
    return assert(targets.prepare(attack, { subject }, {segment_line_geometry = "head-on"}))
end

test("line intersections use independently measured asymmetric-box spacing and scale", function()
    -- SEGMENTPROBE on Factorio 2.1.20 observed centers 0, 6.5, 13 and 0, 13, 26.
    local entities = straight_body(1)
    local prepared = prepared_line(line_profile(10, 40, 50), entities)
    local amount, hits = prepared.shot_damage("test-head")
    close(amount, 20)
    assert(hits[1] == 2)
    prepared = prepared_line(line_profile(10, 40, 54), entities)
    close(prepared.shot_damage("test-head"), 30)
    prepared = prepared_line(line_profile(10, 40, 50), straight_body(2))
    close(prepared.shot_damage("test-head"), 10)
end)

test("line endpoint margins do not credit an uncertain body boundary", function()
    local entities = straight_body(1)
    local prepared = prepared_line(line_profile(10, 40, 46.5), entities)
    close(prepared.shot_damage("test-head"), 10)
    prepared = prepared_line(line_profile(10, 40, 46.6), entities)
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
    local prepared = prepared_line(attack, entities)
    close(prepared.shot_damage("test-head"), 9)
    close(prepared.seconds("test-head", 1), 1)
    entities["test-head"].max_health = 10
    prepared = prepared_line(attack, entities)
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
    local prepared = prepared_line(attack, entities)
    close(prepared.shot_damage("test-head"), 35)
    prepared = assert(targets.prepare(attack, { assert(targets.new(entities).target("test-head")) }))
    close(prepared.shot_damage("test-head"), 15)
end)

test("invalid or rotated geometry fails that target only when line body hits are requested", function()
    local entities = straight_body(1)
    entities["test-body"].collision_box[3] = 0.25
    local amount, reason = prepared_line(line_profile(10, 40, 54), entities).shot_damage("test-head")
    assert(amount == nil and reason == "unsupported-segment-geometry")
    assert(prepared_line(profile(10), entities).shot_damage("test-head"))
    local attack = line_profile(10, 40, 54)
    attack.packets[1].line.width = 0
    amount, reason = prepared_line(attack, entities).shot_damage("test-head")
    assert(amount == nil and reason == "invalid-line-geometry")
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
    local prepared = prepared_line(attack, entities)
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
    close(seconds(attack, entities, "test-target"), 1.5)
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
    close(seconds(attack, entities, "test-target", 10), 2)
    attack.unsynchronized_hits = true
    local result, reason = seconds(attack, entities, "test-target", 10)
    assert(result == nil and reason == "insufficient-damage")
end)

test("missing segments fail instead of silently using head stats", function()
    local entities = {
        ["test-head"] = {
            max_health = 100,
            segment_engine = { segments = { { segment = "test-missing" } } },
        },
    }
    local result, reason = seconds(profile(100), entities, "test-head")
    assert(result == nil and reason == "missing-segment")
end)

test("a target that reacts to damage, or whose hits aren't visual, can't be scored", function()
    local entities = {
        ["test-unit"] = {
            max_health = 10,
            attack_reaction = { { range = 1 } },
        },
    }
    local result, reason = seconds(profile(10), entities, "test-unit", 1, options(entities))
    assert(result == nil and reason == "unsupported-target-reaction")
    entities["test-unit"].attack_reaction = nil
    entities["test-unit"].damaged_trigger_effect = { type = "unknown-damage" }
    result, reason = seconds(profile(10), entities, "test-unit", 1, options(entities))
    assert(result == nil and reason == "test-nonvisual-effect")
end)

test("one target that can't be scored doesn't keep the others from it", function()
    local entities = {
        ["test-good"] = { max_health = 10 },
        ["test-bad"] = {
            max_health = 10,
            resistances = {
                { type = "test-damage" },
                { type = "test-damage" },
            },
        },
    }
    local resolver = targets.new(entities)
    local evaluator = assert(targets.prepare(profile(10), {
        assert(resolver.target("test-good")),
        assert(resolver.target("test-bad")),
    }))
    close(evaluator.seconds("test-good", 1), 1)
    local result, reason = evaluator.seconds("test-bad", 1)
    assert(result == nil and reason == "duplicate-resistance")
end)

test("stickers add damage over time to targets they stick to, once for the team", function()
    local attack = profile(10)
    attack.dots = {
        {
            name = "test-sticker",
            type = "test-fire",
            amount = 5,
            interval_ticks = 30,
            duration_ticks = 600,
        },
    }
    local entities = { ["test-unit"] = { max_health = 100 } }
    -- Not a type a sticker sticks to: the direct hits alone
    close(seconds(attack, entities, "test-unit"), 10)
    entities["test-unit"].type = "unit"
    -- 10 a second from the sticker, one application held back
    close(seconds(attack, entities, "test-unit"), 1 + math.ceil((100 - 10 + 5) / 20))
    -- Ten weapons' first volley is lethal on its own
    close(seconds(attack, entities, "test-unit", 10), 1)
    close(seconds(attack, entities, "test-unit", 5), 1 + math.ceil((100 - 50 + 5) / 60))
    -- A sticker gone before the next hit only damages for its duration
    attack.dots[1].duration_ticks = 45
    close(seconds(attack, entities, "test-unit"), 1 + math.ceil((100 - 10 + 5) / 15))
    entities["test-unit"].resistances = {
        {
            type = "test-fire",
            decrease = 5,
        },
    }
    close(seconds(attack, entities, "test-unit"), 10)
end)

test("negative regeneration is not credited as extra weapon damage", function()
    local entities = {
        ["test-unit"] = {
            max_health = 100,
            healing_per_tick = -100,
        },
    }
    close(seconds(profile(10), entities, "test-unit"), 10)
end)

test("what a target leaves behind recurses through fragments, without terminal chunks", function()
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
    local resolver = targets.new(entities)
    assert(names(resolver.spawned("test-large")) == "test-medium,test-small")
    assert(names(resolver.spawned("test-small")) == "")
end)

test("rare and segment death spawns count, and a spawn that can't happen doesn't", function()
    local entities = {
        ["test-parent"] = {
            max_health = 10,
            dying_trigger_effect = spawn("test-child", {
                repeat_count = 2,
                repeat_count_deviation = 3,
                probability = 0.01,
            }),
        },
        ["test-head"] = {
            max_health = 10,
            segment_engine = { segments = { { segment = "test-body" } } },
        },
        ["test-body"] = { dying_trigger_effect = spawn("test-child") },
        ["test-never"] = {
            max_health = 10,
            dying_trigger_effect = spawn("test-child", { probability = 0 }),
        },
        ["test-child"] = { max_health = 10 },
    }
    local resolver = targets.new(entities)
    assert(names(resolver.spawned("test-parent")) == "test-child")
    assert(names(resolver.spawned("test-head")) == "test-child")
    assert(names(resolver.spawned("test-never")) == "")
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
    assert(names(targets.new(entities).spawned("test-head")) == "")
    entities["test-remains"].created_effect = {
        type = "direct",
        action_delivery = {
            type = "instant",
            target_effects = spawn("test-child"),
        },
    }
    assert(names(targets.new(entities).spawned("test-head")) == "test-child")
end)

test("visual fragments need visual validation and cannot hide damaging effects", function()
    local entities = {
        ["test-parent"] = {
            max_health = 10,
            dying_trigger_effect = spawn("test-explosion"),
        },
        ["test-explosion"] = { type = "explosion" },
    }
    assert(names(targets.new(entities, options(entities)).spawned("test-parent")) == "")
    entities["test-explosion"].created_effect = { type = "unknown-damage" }
    local result, reason = targets.new(entities, options(entities)).spawned("test-parent")
    assert(result == nil and reason == "unsupported-created-target")
end)

test("spawn cycles, effect cycles and deep trees fail closed", function()
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
    local result, reason = targets.new(entities).spawned("test-first")
    assert(result == nil and reason == "target-spawn-cycle")
    local cycle = {}
    cycle[1] = cycle
    entities["test-first"].dying_trigger_effect = cycle
    result, reason = targets.new(entities).spawned("test-first")
    assert(result == nil and reason == "target-effect-cycle")
    entities = { ["test-leaf"] = { max_health = 10 } }
    local previous = "test-leaf"
    for i = 1, 12 do
        local name = "test-level-" .. i
        entities[name] = {
            max_health = 10,
            dying_trigger_effect = spawn(previous, { repeat_count = 2 }),
        }
        previous = name
    end
    local spawned = assert(targets.new(entities).spawned(previous))
    assert(spawned["test-leaf"] == true and spawned[previous] == nil)
    result, reason = targets.new(entities, { max_depth = 3 }).spawned(previous)
    assert(result == nil and reason == "target-depth-budget")
end)

test("a fresh resolver reads changed health and resistances", function()
    local entities = { ["test-unit"] = { max_health = 10 } }
    close(seconds(profile(10), entities, "test-unit"), 1)
    entities["test-unit"].max_health = 30
    entities["test-unit"].resistances = {
        {
            type = "test-damage",
            percent = 50,
        },
    }
    close(seconds(profile(10), entities, "test-unit"), 6)
end)

print("combat targets: " .. count .. " tests passed")

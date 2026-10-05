package.loaded["helper-tables/experimental-flags"] = {military_resistances = true}
-- Run from the mod root: lua randomizations/graph/unified/handlers/test-damage-types.lua
-- Exercise the handler with the real trigger walker and transaction helper; isolate lookup/scoring state.

data = { raw = {} }
defines = {
    prototypes = {
        item = { ammo = true },
        entity = { projectile = true },
        equipment = {},
        ["active-trigger"] = {},
    },
}

local gutils = require("lib/graph/graph-utils")
local trigger = require("lib/trigger")

local state
local lu = {}

local function copy(value)
    if type(value) ~= "table" then
        return value
    end
    local result = {}
    for key, child in pairs(value) do
        result[key] = copy(child)
    end
    return result
end

local function rebuild_sources()
    local sources = {}
    for _, prototype in pairs(state.sources) do
        local structs = {}
        trigger.type_to_gather_struct_func[prototype.type](structs, prototype)
        for _, packet in pairs(structs["damage-parameters"] or {}) do
            sources[packet.type] = sources[packet.type] or {}
            sources[packet.type][gutils.key("item", prototype.name)] = { source_type = "ammo" }
        end
    end
    lu.damage_type_sources = sources
end

lu.load_lookups = function()
    state.loads = state.loads + 1
    table.insert(state.events, "load")
    rebuild_sources()
end

package.loaded["lib/lookup/init"] = lu
package.loaded["lib/lookup/2-simple/combat"] = {
    link = function(value)
        assert(value == lu)
        table.insert(state.events, "link")
    end,
    damage_type_sources = function()
        state.refreshes = state.refreshes + 1
        table.insert(state.events, "refresh")
        rebuild_sources()
    end,
}
package.loaded["lib/logic/combat-encounters"] = {
    prepare = function(value, options)
        assert(value == lu and options.scorer.retain_dominated == true)
        state.prepares = state.prepares + 1
        table.insert(state.events, "prepare")
        local packets = {}
        for _, packet in pairs(state.packets) do
            table.insert(packets, packet.type)
        end
        table.insert(state.evaluations, packets)
        return {
            definitions = state.definitions,
            counter_provider = function(definition)
                state.provider_calls = state.provider_calls + 1
                if type(state.counters[definition.name]) == "function" then
                    return state.counters[definition.name](definition)
                end
                return state.counters[definition.name] or {}
            end,
        }
    end,
}
package.loaded["lib/combat-encounters"] = {
    copy = copy,
    positive_finite = function(value)
        return type(value) == "number" and value > 0 and value < math.huge
    end,
}
package.loaded["lib/data-utils"] = {
    get_prot = function(class, name)
        for kind, _ in pairs(defines.prototypes[class]) do
            local prototype = (data.raw[kind] or {})[name]
            if prototype ~= nil then
                return prototype
            end
        end
    end,
    prots = function(class)
        return data.raw[class] or {}
    end,
}
package.loaded["lib/graph-customization"] = {
    selected = function(id, prototype)
        assert(id == "damage-types")
        return not state.unselected[prototype.name]
    end,
    excluded = function(id, prototype)
        assert(id == "damage-types")
        return state.excluded[prototype.name] == true
    end,
}
package.loaded["lib/random/rng"] = {
    key = function() return "test-rng" end,
    shuffle = function(_, values)
        if state.shuffle_types and type(values[1]) == "string" then
            values[1], values[#values] = values[#values], values[1]
        end
    end,
}

function log(message)
    table.insert(state.logs, message)
end

local handler = require("randomizations/graph/unified/handlers/damage-types")

local count = 0
local function test(name, run)
    state = {
        sources = {},
        packets = {},
        unselected = {},
        excluded = {},
        definitions = {},
        counters = {},
        loads = 0,
        refreshes = 0,
        prepares = 0,
        provider_calls = 0,
        commits = 0,
        events = {},
        evaluations = {},
        logs = {},
    }
    data.raw = {
        ammo = {},
        projectile = {},
        ["damage-type"] = {
            ["test-new"] = {},
            ["test-old"] = {},
        },
    }
    lu.damage_type_sources = {}
    lu.entities = {}
    run()
    count = count + 1
    print("ok - " .. name)
end

local function action(packet)
    return {
        type = "direct",
        action_delivery = {
            type = "instant",
            target_effects = {
                type = "damage",
                damage = packet,
            },
        },
    }
end

local function ammo(name, packet, player)
    local prototype = {
        type = "ammo",
        name = name,
        ammo_type = { action = action(packet) },
    }
    data.raw.ammo[name] = prototype
    if player ~= false then
        table.insert(state.sources, prototype)
    end
    return prototype
end

local function packet(amount)
    local result = {
        type = "test-old",
        amount = amount or 10,
    }
    table.insert(state.packets, result)
    return result
end

local function sole_packet(groups, expected)
    assert(#groups == 1 and #groups[1].packets == 1)
    assert(groups[1].packets[1] == expected)
end

local function params(accept)
    local graph = {
        nodes = {},
        edges = {},
    }
    return {
        random_graph = graph,
        promotion = {
            pre_keys_of = function() return {} end,
            try_rewires = function(changes, commit)
                state.commits = state.commits + 1
                assert(commit == true)
                return accept == nil or accept(changes, state.commits)
            end,
        },
    }
end

test("a shared player packet is emitted once and unrelated enemy packets stay unchanged", function()
    local shared = packet()
    ammo("test-first", shared)
    ammo("test-alias", shared)
    ammo("test-enemy", packet(), false)
    rebuild_sources()
    sole_packet(handler.collect_groups(), shared)
end)

test("an excluded local owner protects its shared packet regardless of owner order", function()
    local shared, independent = packet(), packet()
    ammo("test-first", shared)
    ammo("test-z-last-alias", shared, false)
    ammo("test-independent", independent)
    state.excluded["test-z-last-alias"] = true
    rebuild_sources()
    sole_packet(handler.collect_groups(), independent)
end)

test("an unselected local owner protects a shared player packet", function()
    local shared = packet()
    ammo("test-first", shared)
    ammo("test-z-last-alias", shared, false)
    state.unselected["test-z-last-alias"] = true
    rebuild_sources()
    assert(#handler.collect_groups() == 0)
end)

local function indirect_sources()
    local shared = packet()
    local projectile = {
        type = "projectile",
        name = "test-projectile",
        action = action(shared),
    }
    data.raw.projectile[projectile.name] = projectile
    local first = ammo("test-first", shared)
    first.ammo_type.action = {
        type = "direct",
        action_delivery = {
            type = "projectile",
            projectile = projectile.name,
        },
    }
    local second = ammo("test-second", shared)
    second.ammo_type = first.ammo_type
    rebuild_sources()
    return shared
end

test("an excluded root source protects a selected transitive projectile", function()
    indirect_sources()
    state.excluded["test-second"] = true
    assert(#handler.collect_groups() == 0)
end)

test("an unselected root source protects a selected transitive projectile", function()
    indirect_sources()
    state.unselected["test-second"] = true
    assert(#handler.collect_groups() == 0)
end)

test("a selected transitive projectile is grouped by its physical owner", function()
    local shared = indirect_sources()
    local groups = handler.collect_groups()
    sole_packet(groups, shared)
    assert(groups[1].prototype.name == "test-projectile")
end)

test("zero negative infinite and nonnumeric damage do not become mutation candidates", function()
    local values = {
        0,
        -1,
        math.huge,
        0 / 0,
        "10",
    }
    for index, amount in pairs(values) do
        ammo("test-source-" .. index, packet(amount))
    end
    rebuild_sources()
    assert(#handler.collect_groups() == 0)
end)

test("reflection reload precedes fresh baseline and trial scoring", function()
    local original = packet()
    ammo("test-source", original)
    assert(handler.after_reflection(params()))
    assert(state.loads == 1 and state.prepares == 2 and state.commits == 2)
    assert(state.events[1] == "load" and state.events[2] == "link" and state.events[3] == "prepare")
    assert(state.evaluations[1][1] == "test-old" and state.evaluations[2][1] == "test-new")
    assert(original.type == "test-new" and lu.damage_type_sources["test-old"] == nil)
    assert(state.refreshes == 3)
end)

test("a failed reflected baseline aborts without proposing or mutating packets", function()
    local original = packet()
    ammo("test-source", original)
    assert(not handler.after_reflection(params(function() return false end)))
    assert(original.type == "test-old")
    assert(state.prepares == 1 and state.commits == 1 and state.refreshes == 1)
end)

test("rejected proposals restore packet types and refresh the final coarse lookup", function()
    local original = packet()
    ammo("test-source", original)
    assert(handler.after_reflection(params(function(_, calls) return calls == 1 end)))
    assert(state.prepares == 2 and state.commits == 2 and original.type == "test-old")
    assert(state.evaluations[2][1] == "test-new")
    assert(lu.damage_type_sources["test-new"] == nil and lu.damage_type_sources["test-old"] ~= nil)
    assert(state.events[#state.events] == "refresh")
end)

test("each proposal starts from the current accepted packet state", function()
    ammo("test-a", packet())
    ammo("test-b", packet())
    assert(handler.after_reflection(params()))
    assert(state.prepares == 3 and state.commits == 3)
    assert(state.evaluations[3][1] == "test-new" and state.evaluations[3][2] == "test-new")
end)

test("the wrapper preserves coarse source endpoints when assigning a new damage type", function()
    ammo("test-source", packet())
    local old_key = gutils.key("damage-type", "test-old")
    local new_key = gutils.key("damage-type", "test-new")
    local source_key = gutils.key("item-ammo", "test-source")
    local carrier = "test-manual-carrier"
    local edge = "test-old-link"
    local current = {
        [old_key] = { carrier },
        [new_key] = {},
    }
    local configured = params(function(changes, calls)
        if calls == 1 then
            assert(#changes == 0)
        else
            local added, removed = false, false
            for _, change in pairs(changes) do
                if change.node_key == old_key then
                    assert(change.remove[1] == carrier)
                    removed = true
                elseif change.node_key == new_key then
                    assert(change.add == carrier)
                    added = true
                end
            end
            assert(added and removed and #changes == 2)
        end
        return true
    end)
    configured.random_graph = {
        nodes = {
            [old_key] = {
                type = "damage-type",
                name = "test-old",
                pre = { [edge] = true },
            },
            [new_key] = {
                type = "damage-type",
                name = "test-new",
                pre = {},
            },
            [source_key] = {
                type = "item-ammo",
                name = "test-source",
            },
        },
        edges = {
            [edge] = {
                start = carrier,
                stop = old_key,
            },
        },
        orand_to_child = { [carrier] = source_key },
    }
    configured.promotion.pre_keys_of = function(key) return current[key] end
    assert(handler.after_reflection(configured))
end)

test("uncalibrated or incomplete definitions never invoke counter scoring", function()
    state.definitions = {
        {
            name = "test-incomplete",
            targets_complete = false,
            workload_calibrated = true,
        },
        {
            name = "test-uncalibrated",
            targets_complete = true,
            workload_calibrated = false,
        },
        {
            name = "test-complete",
            targets_complete = true,
            workload_calibrated = true,
        },
    }
    assert(handler.after_reflection(params()))
    assert(state.prepares == 1 and state.provider_calls == 1)
end)

local function unscored_target()
    local target = { max_health = 100 }
    lu.entities["test-target"] = target
    state.definitions = {
        {
            name = "test-unscored",
            targets_complete = true,
            workload_calibrated = true,
            targets = {
                {
                    entity = "test-target",
                    amount = 1,
                },
            },
        },
    }
    return target
end

test("safety refusal never mutates a packet or rescores the unsafe candidate", function()
    local original = packet()
    ammo("test-source", original)
    local target = unscored_target()
    target.resistances = {
        {
            type = "test-new",
            percent = 25,
        },
    }
    assert(handler.after_reflection(params()))
    assert(original.type == "test-old" and state.prepares == 1 and state.commits == 1)
    assert(state.refreshes == 2 and #state.evaluations == 1)
end)

test("an unknown target lifecycle blocks categorical changes before mutation", function()
    local original = packet()
    ammo("test-source", original)
    local target = unscored_target()
    target.dying_trigger_effect = { type = "test-unknown-effect" }
    assert(handler.after_reflection(params()))
    assert(original.type == "test-old" and state.prepares == 1 and state.commits == 1)
    assert(lu.damage_type_sources["test-new"] == nil)
end)

test("a reflection-only successful counter cannot bypass the unscored target fallback", function()
    local original = packet()
    ammo("test-source", original)
    local target = unscored_target()
    target.resistances = {
        {
            type = "test-new",
            percent = 25,
        },
    }
    state.definitions[1].policy = {
        turret_count = 10,
        manual_count = 1,
        clear_seconds = 10,
    }
    state.counters["test-unscored"] = {
        {
            name = "test-reflection-only-counter",
            mode = "turret",
            count = 10,
            clear_seconds = 9,
            prerequisites = {gutils.key("item-ammo", "test-source")},
        },
    }
    local configured = params()
    local key = gutils.key("combat-encounter-counters", "test-unscored")
    configured.random_graph.nodes[key] = {
        type = "combat-encounter-counters",
        name = "test-unscored",
        pre = {},
    }
    assert(handler.after_reflection(configured))
    assert(state.provider_calls == 1 and state.prepares == 1 and state.commits == 1)
    assert(original.type == "test-old" and lu.damage_type_sources["test-new"] == nil)
    local reported = false
    for _, line in pairs(state.logs) do
        reported = reported or string.find(line, "unscored benchmarks 1", 1, true) ~= nil
    end
    assert(reported)
end)

test("at most 64 proposals are rescored even with more eligible groups", function()
    for index = 1, 70 do
        ammo(string.format("test-source-%03d", index), packet())
    end
    assert(handler.after_reflection(params()))
    local changed = 0
    for _, original in pairs(state.packets) do
        if original.type == "test-new" then
            changed = changed + 1
        end
    end
    assert(changed == 64 and state.prepares == 65 and state.commits == 65)
    assert(state.refreshes == 66)
end)

test("a handler invocation without promotion is inert", function()
    local original = packet()
    ammo("test-source", original)
    assert(handler.after_reflection({}))
    assert(original.type == "test-old" and state.loads == 0 and state.prepares == 0)
end)

local function resistance_target()
    local target = {
        type = "test-entity",
        name = "test-resistance-target",
        resistances = {
            {
                type = "test-old",
                percent = 25,
            },
        },
    }
    lu.entities[target.name] = target
    state.shuffle_types = true
    return target
end

test("resistance assignments use fresh scoring and the normal promotion transaction", function()
    local target = resistance_target()
    local original_array, original_row = target.resistances, target.resistances[1]
    local configured = params(function(_, calls)
        assert(target.resistances[1].type == (calls == 1 and "test-old" or "test-new"))
        return true
    end)
    assert(handler.after_reflection(configured))
    assert(state.prepares == 2 and state.commits == 2)
    assert(target.resistances == original_array and target.resistances[1] == original_row)
    assert(original_row.type == "test-new" and original_row.percent == 25)
end)

test("promotion refusal restores categorical resistance rows", function()
    local target = resistance_target()
    assert(handler.after_reflection(params(function(_, calls) return calls == 1 end)))
    assert(target.resistances[1].type == "test-old" and state.prepares == 2 and state.commits == 2)
end)

test("unscored benchmarks freeze resistance permutations before scoring", function()
    local target = resistance_target()
    unscored_target()
    assert(handler.after_reflection(params()))
    assert(target.resistances[1].type == "test-old" and state.prepares == 1 and state.commits == 1)
end)

test("excluded aliases block resistance changes through every shared owner", function()
    local target = resistance_target()
    lu.entities["test-excluded-alias"] = {
        type = "test-entity",
        name = "test-excluded-alias",
        resistances = target.resistances,
    }
    state.excluded["test-excluded-alias"] = true
    assert(handler.after_reflection(params()))
    assert(target.resistances[1].type == "test-old" and state.prepares == 1)
end)

test("out-of-scope resistance owners in the registry block shared entity rows", function()
    local target = resistance_target()
    data.raw["test-other-kind"] = {
        ["test-outside"] = {
            type = "test-other-kind",
            name = "test-outside",
            resistances = {target.resistances[1]},
        },
    }
    assert(handler.after_reflection(params()))
    assert(target.resistances[1].type == "test-old" and state.prepares == 1)
end)

test("a resistance proposal losing a retained counter reaches ordinary promotion rejection", function()
    local target = resistance_target()
    local definition = {
        name = "test-encounter",
        targets_complete = true,
        workload_calibrated = true,
        targets = {
            {
                entity = target.name,
                amount = 1,
            },
        },
        policy = {
            turret_count = 10,
            manual_count = 1,
            clear_seconds = 10,
        },
    }
    state.definitions = {definition}
    local name, carrier, prerequisite = "test-counter", "test-carrier", "test-prerequisite"
    state.counters[definition.name] = function()
        return {
            {
                name = name,
                mode = "turret",
                count = 10,
                clear_seconds = target.resistances[1].type == "test-old" and 5 or 20,
                prerequisites = {prerequisite},
            },
        }
    end
    local configured = params(function(changes, calls)
        if calls == 1 then assert(#changes == 0); return true end
        assert(#changes == 1 and changes[1].remove[1] == carrier)
        return false
    end)
    local key = gutils.key("combat-encounter-counters", definition.name)
    configured.random_graph.nodes[key] = {
        type = "combat-encounter-counters",
        name = definition.name,
        pre = {["test-edge"] = true},
    }
    configured.random_graph.nodes[carrier] = {
        counter_name = name,
        encounter_name = definition.name,
        deployment_mode = "turret",
        counter_prerequisites = {prerequisite},
    }
    configured.random_graph.edges["test-edge"] = {
        start = carrier,
        stop = key,
    }
    configured.promotion.pre_keys_of = function() return {carrier} end
    assert(handler.after_reflection(configured))
    assert(target.resistances[1].type == "test-old" and state.commits == 2)
end)

local function ordinary_resistance(name, percent)
    local target = {
        type = "test-entity",
        name = name,
        resistances = {
            {
                type = "test-old",
                percent = percent,
            },
        },
    }
    lu.entities[name] = target
    state.shuffle_types = true
    return target
end

test("ordinary entities share one permutation without replacing their different profiles", function()
    local first = ordinary_resistance("test-first-ordinary", 10)
    local second = ordinary_resistance("test-second-ordinary", 60)
    local first_array, second_row = first.resistances, second.resistances[1]
    assert(handler.after_reflection(params()))
    assert(state.prepares == 2 and state.commits == 2)
    assert(first.resistances[1].type == "test-new" and second.resistances[1].type == "test-new")
    assert(first.resistances[1].percent == 10 and second.resistances[1].percent == 60)
    assert(first.resistances == first_array and second.resistances[1] == second_row)
end)

test("ordinary batches roll back together when their shared promotion is refused", function()
    local first = ordinary_resistance("test-first-ordinary", 10)
    local second = ordinary_resistance("test-second-ordinary", 60)
    assert(handler.after_reflection(params(function(_, calls)
        if calls == 2 then
            assert(first.resistances[1].type == "test-new" and second.resistances[1].type == "test-new")
        end
        return calls == 1
    end)))
    assert(first.resistances[1].type == "test-old" and second.resistances[1].type == "test-old")
    assert(state.prepares == 2 and state.commits == 2)
end)

test("barriers and armed entities receive independent categorical proposals", function()
    local barrier = ordinary_resistance("test-barrier", 10)
    local turret = ordinary_resistance("test-armed", 60)
    data.raw.wall = {[barrier.name] = barrier}
    turret.attack_parameters = {}
    assert(handler.after_reflection(params()))
    assert(state.prepares == 3 and state.commits == 3)
    assert(barrier.resistances[1].type == "test-new" and turret.resistances[1].type == "test-new")
end)

test("sensitive groups have priority while one ordinary batch retains its reserved proposal", function()
    local sensitive, ordinary = {}, {}
    for index = 1, 35 do
        sensitive[index] = ordinary_resistance("test-sensitive-" .. index, 20)
        sensitive[index].attack_parameters = {}
    end
    for index = 1, 70 do ordinary[index] = ordinary_resistance("test-ordinary-" .. index, 30) end
    assert(handler.after_reflection(params()))
    local changed = 0
    for _, target in pairs(sensitive) do
        if target.resistances[1].type == "test-new" then changed = changed + 1 end
    end
    assert(changed == 31)
    for _, target in pairs(ordinary) do assert(target.resistances[1].type == "test-new") end
    assert(state.prepares == 33 and state.commits == 33)
end)

print("passed " .. count .. " damage handler tests")

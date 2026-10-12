-- Exercises the real reflection with a displaced capsule effect and free placement slots.
-- Run from the mod root: lua randomizations/graph/unified/handlers/test-entity-effects.lua

table.deepcopy = function(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for k, v in pairs(value) do result[k] = table.deepcopy(v) end
    return result
end
local function key(kind, name)
    if type(kind) == "table" then return kind.key or kind.type .. ":" .. kind.name end
    return kind .. ":" .. name
end
local categories = {
    without_health = {
        projectile = true,
        explosion = true,
    },
}
local costs = {current = {anywhere_costs = {}}}
local selected = {}
package.loaded["__core__/lualib/collision-mask-util"] = {}
package.loaded["helper-tables/categories"] = categories
package.loaded["helper-tables/constants"] = {entity_cost_tolerance = 4}
package.loaded["lib/cost/context-costs"] = costs
package.loaded["lib/graph-customization"] = {selected = function(_, item) return selected[item.name] ~= false end}
package.loaded["lib/graph/graph-utils"] = {
    key = key,
    get_owner = function(graph, node) return graph.nodes[node.owner] end,
}
package.loaded["lib/logic/acquisition"] = {
    bulk_entity_types = {},
    pairing = function(base, head)
        if head.acq_kind == "build" and (base.acq_kind == "capsule" or base.acq_kind == "ammo") then return nil end
        return {}
    end,
}
package.loaded["lib/locale"] = {find_localised_name = function(prot) return prot.localised_name or prot.name end}
package.loaded["lib/localised-text"] = {}
package.loaded["lib/random/rng"] = {
    key = function() return "test" end,
    shuffle = function() end,
    value = function() return 1 end,
}
package.loaded["lib/wild-entities"] = {}
package.loaded["randomizations/graph/unified/handler-helpers/military"] = {}
local entity = require("randomizations/graph/unified/handlers/entity")

defines = {
    prototypes = {
        item = {
            item = true,
            capsule = true,
        },
        entity = {
            projectile = true,
            explosion = true,
            ["combat-robot"] = true,
            ["assembling-machine"] = true,
        },
    },
}
util = {
    empty_animation = function() return {
        filename = "test-empty.png",
        width = 1,
        height = 1,
    } end,
}
log = function() end
config = {}

local function throw(name)
    return {
        type = "throw",
        attack_parameters = {
            range = 20,
            ammo_type = {
                action = {
                    type = "direct",
                    action_delivery = {
                        type = "projectile",
                        projectile = name,
                        starting_speed = 0.3,
                    },
                },
            },
        },
    }
end

local function setup(options)
    options = options or {}
    selected = {candidate = options.selected}
    changes = {}
    data = {
        raw = {
            item = {},
            capsule = {},
            projectile = {},
            explosion = {},
            ["combat-robot"] = {},
            ["assembling-machine"] = {},
        },
    }
    function data:extend(entries)
        for _, entry in pairs(entries) do self.raw[entry.type][entry.name] = entry end
    end
    data:extend({
        {
            type = "item",
            name = "candidate",
            icon = "candidate.png",
            icon_size = 64,
            stack_size = 50,
            place_result = options.occupied and "machine" or nil,
            hidden = options.hidden,
            deposit_copy_of = options.copy and "original" or nil,
        },
        {
            type = "capsule",
            name = "effect",
            capsule_action = throw("outer"),
        },
        {
            type = "capsule",
            name = "robots",
            capsule_action = throw("robot-projectile"),
        },
        {
            type = "combat-robot",
            name = "robot",
        },
        {
            type = "assembling-machine",
            name = "machine",
        },
        {
            type = "explosion",
            name = "blast",
        },
        {
            type = "projectile",
            name = "outer",
            action = {
                {
                    type = "direct",
                    action_delivery = {
                        type = "instant",
                        target_effects = {
                            type = "create-entity",
                            entity_name = "blast",
                        },
                    },
                },
                {
                    type = "area",
                    radius = 6,
                    action_delivery = {
                        type = "instant",
                        target_effects = {
                            type = "damage",
                            damage = {
                                amount = 35,
                                type = "explosion",
                            },
                        },
                    },
                },
            },
        },
        {
            type = "projectile",
            name = "robot-projectile",
            action = {
                type = "direct",
                action_delivery = {
                    type = "instant",
                    target_effects = {
                        type = "create-entity",
                        entity_name = "robot",
                    },
                },
            },
        },
    })
    if options.conditional == true then data.raw.projectile.outer.final_action = data.raw.projectile.outer.action end
    unified_starting_data_raw = table.deepcopy(data.raw)
    lookups = {
        buildables = {},
        capsule_spawns = {robots = {robot = true}},
    }
    costs.current.anywhere_costs = {
        ["item-candidate"] = options.cost or 10,
        ["item-effect"] = 10,
    }
    if options.unknown_cost == true then costs.current.anywhere_costs["item-candidate"] = nil end
    local graph = {
        nodes = {
            ["item:candidate"] = {
                type = "item",
                name = "candidate",
            },
            effect = {
                type = "item-capsule",
                name = "effect",
            },
            robots = {
                type = "item-capsule",
                name = "robots",
            },
            target = {
                type = "entity-own",
                name = "robot",
            },
            dep = {key = "dep"},
            head = {
                key = "head",
                type = "head",
                acq_kind = "capsule",
                owner = "dep",
                old_base = "old",
                ours = true,
            },
            old = {
                key = "old",
                type = "base",
                acq_kind = "capsule",
                owner = "robots",
                old_head = "head",
                ours = true,
            },
            maker = {
                key = "maker",
                type = "base",
                acq_kind = "capsule",
                owner = "effect",
                trigger_spoof = true,
                ours = true,
                old_head = "dummy",
            },
            dummy = {
                key = "dummy",
                owner = "dummydep",
            },
            dummydep = {key = "dummydep"},
            dummytarget = {
                name = "dummy",
                spoof = true,
            },
        },
        orand_to_parent = {
            dep = "target",
            dummydep = "dummytarget",
        },
    }
    if options.vestige == true then
        data.raw.item.candidate.place_result = "machine"
        data.raw.item.candidate.subgroup = "test"
        data.raw.item.candidate.order = "test"
        data:extend({
            {
                type = "item",
                name = "other-placer",
                icon = "other.png",
                icon_size = 64,
                stack_size = 50,
            },
        })
        unified_starting_data_raw = table.deepcopy(data.raw)
        graph.nodes["item:other-placer"] = {
            type = "item",
            name = "other-placer",
        }
        graph.nodes.buildtarget = {
            type = "entity-build-item",
            name = "machine",
        }
        graph.nodes.builddep = {key = "builddep"}
        graph.nodes.buildhead = {
            key = "buildhead",
            type = "head",
            acq_kind = "build",
            owner = "builddep",
            old_base = "buildold",
        }
        graph.nodes.buildold = {
            key = "buildold",
            type = "base",
            acq_kind = "build",
            owner = "item:candidate",
        }
        graph.nodes.buildnew = {
            key = "buildnew",
            type = "base",
            acq_kind = "build",
            owner = "item:other-placer",
            build_spoof = true,
        }
        graph.orand_to_parent.builddep = "buildtarget"
    end
    entity.initialize()
    return graph
end

local function reflect(options)
    local graph = setup(options)
    local matches = {head = "maker"}
    local handlers = {head = entity}
    if graph.nodes.buildhead ~= nil then
        matches.buildhead = "buildnew"
        handlers.buildhead = entity
    end
    entity.reflect(graph, matches, handlers)
    for _, change in pairs(changes) do change.tbl[change.prop] = change.new_val end
    return data.raw.item.candidate, graph
end

local item = reflect()
assert(item.place_result == "propertyrandomizer-effect-effect", "an ordinary item with no Vestige must accept the effect")
assert(item.localised_name == "candidate", "ordinary items retain their identity")
assert(data.raw.explosion[item.place_result].created_effect[2].action_delivery.target_effects.damage.amount == 35)
assert(data.raw.explosion[item.place_result].created_effect[1].action_delivery.type == "instant", "placement must not throw the outer projectile")
assert(data.raw.capsule.effect.capsule_action.attack_parameters.ammo_type.action.action_delivery.projectile ~= "outer", "the original throw must now make the robot")
assert(data.raw.projectile.outer.action[2].action_delivery.target_effects.damage.amount == 35, "donor stays unchanged")

for _, options in pairs({
    {selected = false},
    {occupied = true},
    {hidden = true},
    {copy = true},
    {cost = 1000},
    {unknown_cost = true},
    {conditional = true},
}) do
    local candidate = reflect(options)
    assert(candidate.place_result == (options.occupied and "machine" or nil), "an ineligible slot must retain its placement")
    assert(data.raw.explosion["propertyrandomizer-effect-effect"] == nil)
    assert(data.raw.capsule.robots.capsule_action.attack_parameters.ammo_type.action.action_delivery.projectile == "outer", "an unplaceable effect must fall back to the available capsule")
end

local placed_vestige = reflect({vestige = true})
assert(placed_vestige.place_result == "propertyrandomizer-effect-effect")
assert(placed_vestige.localised_name[1] == "propertyrandomizer-entity.placed-effect-name", "a placed effect must stop being labelled a Vestige")
local empty_vestige = reflect({
    vestige = true,
    cost = 1000,
})
assert(empty_vestige.place_result == nil, "being a Vestige is not sufficient to receive an effect")
assert(empty_vestige.localised_name[1] == "propertyrandomizer-entity.vestige-name")
assert(data.raw.item["other-placer"].place_result == "machine", "effect assignment must preserve the building's new item")

local graph = setup()
assert(entity.validate(graph, graph.nodes.maker, graph.nodes.head), "combat robots can still take throw slots")
lookups.buildables["combat-robot:robot"] = {candidate = "place_result"}
assert(not entity.validate(graph, graph.nodes.maker, graph.nodes.head), "a building's trigger head cannot bypass the placement rule")
assert(entity.validate(graph, graph.nodes.old, graph.nodes.head), "an existing acquisition stays valid")
print("Entity effect reflection passed: direct placement without Vestiges, donor preservation, exclusions, occupied slots, costs, capsule fallback, and building acquisition guards")

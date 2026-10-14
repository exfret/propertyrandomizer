table.deepcopy = function(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for k, v in pairs(value) do result[k] = table.deepcopy(v) end
    return result
end
package.loaded["__core__/lualib/collision-mask-util"] = {}
package.loaded["src/prototypes/categories"] = {
    without_health = {
        projectile = true,
        stream = true,
        explosion = true,
    },
}
package.loaded["src/config/graph-customization"] = {selected = function() return true end}
package.loaded["src/localisation/locale"] = {find_localised_name = function(p) return p.localised_name or p.name end}
local packages = require("src/randomizations/unified/handler-helpers/projectile-packages")
local gutils = require("src/lib/graph/graph-utils")
local ctx = require("src/logic/contexts/contexts")
local key = gutils.key
local function send(name)
    return {
        type = "direct",
        action_delivery = {
            type = "projectile",
            projectile = name,
            starting_speed = 0.1,
        },
    }
end
local function damage(amount)
    return {
        type = "direct",
        action_delivery = {
            type = "instant",
            target_effects = {
                type = "damage",
                damage = {
                    amount = amount,
                    type = "explosion",
                },
            },
        },
    }
end
defines = {
    prototypes = {
        item = {
            item = true,
            ammo = true,
            capsule = true,
        },
        entity = {
            projectile = true,
            stream = true,
            explosion = true,
            turret = true,
        },
    },
}
data = {
    raw = {
        item = {},
        ammo = {},
        capsule = {},
        projectile = {},
        stream = {},
        explosion = {},
        turret = {},
    },
}
function data:extend(entries)
    for _, entry in pairs(entries) do self.raw[entry.type][entry.name] = entry end
end
util = {empty_animation = function() return {} end}
config = {entity_biters = true}
changes = {}
log = function() end
data:extend({
    {
        type = "turret",
        name = "test-machine",
        max_health = 100,
    },
    {
        type = "ammo",
        name = "rocket-item",
        icon = "package-donor.png",
        icon_size = 128,
        ammo_type = {action = send("rocket")},
    },
    {
        type = "capsule",
        name = "throw-item",
        capsule_action = {
            type = "throw",
            attack_parameters = {ammo_type = {action = send("outer")}},
        },
    },
    {
        type = "item",
        name = "placer",
        icon = "item.png",
        icon_size = 64,
    },
    {
        type = "projectile",
        name = "rocket",
        action = damage(200),
    },
    {
        type = "projectile",
        name = "outer",
        action = send("child"),
    },
    {
        type = "projectile",
        name = "child",
        action = damage(10),
    },
    {
        type = "projectile",
        name = "conditional",
        action = damage(20),
        final_action = damage(30),
    },
    {
        type = "stream",
        name = "acid",
        initial_action = damage(5),
    },
    {
        type = "turret",
        name = "worm",
        autoplace = {force = "enemy"},
        attack_parameters = {
            type = "stream",
            cooldown = 40,
            range = 30,
            ammo_type = {
                action = {
                    type = "direct",
                    action_delivery = {
                        type = "stream",
                        stream = "acid",
                    },
                },
            },
        },
    },
})
local launch = data.raw.ammo["rocket-item"].ammo_type.action
launch.action_delivery.source_effects = {type = "play-sound"}
assert(packages.delivery(launch), "source visuals don't disqualify rockets")
local repeated = table.deepcopy(launch)
repeated.repeat_count = 2
assert(packages.delivery(repeated) == nil, "repeated launches cannot accidentally multiply buildings")
assert(packages.delivery({
    launch,
    launch,
}) == nil)
unified_starting_data_raw = table.deepcopy(data.raw)
local function lookup(name)
    return data.raw.projectile[name] or data.raw.stream[name] or data.raw.explosion[name]
end
local copied, copies = packages.copy_action(send("outer"), lookup, "first")
assert(copied.action_delivery.projectile == "first-outer" and #copies == 2)
assert(copies[1].action.action_delivery.projectile == "first-child")
local second = packages.copy_action(send("outer"), lookup, "second")
assert(second.action_delivery.projectile == "second-outer")
assert(data.raw.projectile.outer.action.action_delivery.projectile == "child")
-- A cyclic family must close on its private root, rather than point back to the original or recurse forever.
data.raw.projectile.child.action = send("outer")
local _, cyclic = packages.copy_action(send("outer"), lookup, "cycle")
assert(#cyclic == 2 and cyclic[2].action.action_delivery.projectile == "cycle-outer")
data.raw.projectile.child.action = damage(10)
local graph = {
    nodes = {},
    edges = {},
    sources = {},
}
gutils.add_node(graph, "item-ammo", "rocket-item", {op = "AND"})
gutils.add_node(graph, "item-capsule", "throw-item", {op = "AND"})
gutils.add_node(graph, "damage-type", "explosion", {op = "OR"})
gutils.add_edge(graph, key("item-ammo", "rocket-item"), key("damage-type", "explosion"), {damage_amount = 200})
local records = packages.prepare(graph, function() end)
local rocket = records["item-rocket-item"]
local thrown = records["item-throw-item"]
local worm = records["entity-worm"]
assert(rocket and thrown and worm)
assert(rocket.impact == nil, "a direct hit cannot be replayed faithfully without its target")
assert(worm.impact == nil and not worm.building, "stream repetition is not flattened or used to emit buildings")
local damage_edge = graph.edges[gutils.ekey({
    start = key("projectile-package", rocket.id),
    stop = key("damage-type", "explosion"),
})]
assert(damage_edge and damage_edge.damage_amount == 200 and damage_edge.abilities == nil)
local throw_edge = graph.edges[gutils.ekey({
    start = key("item-capsule", "throw-item"),
    stop = key("projectile-package", thrown.id),
})]
assert(throw_edge.abilities == ctx.LOSES_AUTOMATABILITY, "manual firing belongs to the slot")
-- Snapshot inline launch edits before a destination can overwrite another donor's source action.
launch.action_delivery.source_effects = damage(3).action_delivery.target_effects
launch.action_delivery.source_effects.damage.type = "fire"
packages.refresh(records)
launch.action_delivery.source_effects.damage.type = "physical"
packages.install(worm, rocket, "worm-copy")
assert(data.raw.turret.worm.attack_parameters.ammo_type.action.action_delivery.source_effects.damage.type == "fire")
assert(data.raw.turret.worm.attack_parameters.ammo_type.action.action_delivery.projectile == "worm-copy-rocket")
assert(data.raw.turret.worm.attack_parameters.cooldown == 40 and data.raw.turret.worm.attack_parameters.range == 30)
assert(data.raw.projectile["worm-copy-rocket"].action.action_delivery.target_effects.damage.amount == 200)
packages.replace_with_building(rocket, "test-machine", "building-copy")
local made = data.raw.projectile["building-copy-rocket"].action.action_delivery.target_effects[1]
assert(made.type == "create-entity" and made.entity_name == "test-machine")
assert(data.raw.projectile["building-copy-rocket"].final_action == nil)
assert(data.raw.projectile.rocket.action.action_delivery.target_effects.damage.amount == 200)
-- Other military mutations made before reflection must carry into the private placement payload too.
data.raw.projectile.rocket.action.type = "area"
data.raw.projectile.rocket.action.radius = 4
rocket.impact = table.deepcopy(data.raw.projectile.rocket.action)
data.raw.projectile.rocket.action.action_delivery.target_effects.damage.type = "fire"
packages.place("placer", rocket, false)
for _, change in pairs(changes) do change.tbl[change.prop] = change.new_val end
local placed = data.raw.explosion[data.raw.item.placer.place_result]
-- The generated placeable entity needs its own icon; changing the placing item's icon does not provide it.
-- EntityPrototype::icon/icons in the installed 2.1 documentation requires either field for placeable-player entities.
assert(placed.icons ~= nil and #placed.icons == 1, "placed package must copy the donor icon onto the entity")
assert(placed.icons[1].icon == "package-donor.png" and placed.icons[1].icon_size == 128)
assert(placed.icons[1].icon ~= "item.png", "the package's donor determines its icon, not the placing item")
assert(rocket.look.icon == "package-donor.png" and rocket.look.icons == nil)
local impact = placed.created_effect
assert(impact.action_delivery.type == "instant" and impact.action_delivery.target_effects.damage.type == "fire")
assert(data.raw.item.placer.localised_name == "placer")
-- Multi-layer donors retain sizes, tints and offsets without sharing mutable layer tables.
local layered = table.deepcopy(rocket)
layered.id = "item-layered-package"
layered.look.icon = nil
layered.look.icons = {
    {
        icon = "package-base.png",
        icon_size = 64,
    },
    {
        icon = "package-overlay.png",
        icon_size = 32,
        tint = { r = 0.25 },
        shift = {
            2,
            -3,
        },
        scale = 0.5,
    },
}
packages.place("placer", layered, false)
for _, change in pairs(changes) do change.tbl[change.prop] = change.new_val end
local layered_entity = data.raw.explosion[data.raw.item.placer.place_result]
assert(layered_entity.icons ~= layered.look.icons and #layered_entity.icons == 2)
assert(layered_entity.icons[1].icon == "package-base.png" and layered_entity.icons[1].icon_size == 64)
local overlay = layered_entity.icons[2]
assert(overlay.icon == "package-overlay.png" and overlay.icon_size == 32)
assert(overlay.tint.r == 0.25 and overlay.shift[1] == 2 and overlay.shift[2] == -3 and overlay.scale == 0.5)
overlay.tint.r = 0.9
overlay.shift[1] = 10
assert(layered.look.icons[2].tint.r == 0.25 and layered.look.icons[2].shift[1] == 2)
print("Projectile packages passed: full payloads, independent nested/cyclic copies, slot-specific automation, worm delivery, placement with independent single/layered donor icons, building replacement and repetition rejection")

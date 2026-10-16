-- Exercise the real trigger walker: hosts do not need a type-specific gather function.
package.loaded["__core__/lualib/collision-mask-util"] = {}
package.loaded["src/logic/logic-utils"] = {}
defines = {prototypes = {entity = {["simple-entity"] = true, fish = true, unit = true, tree = true}, item = {}, equipment = {}, ["active-trigger"] = {}}}
data = {raw = {}}
local function create(name) return {type = "create-entity", entity_name = name} end
local tree = {type = "tree", name = "tree", dying_trigger_effect = create("offspring")}
local child = {type = "unit", name = "offspring"}
local rock = {type = "simple-entity", name = "rock", dying_trigger_effect = create("tree"), created_effect = {type = "direct", action_delivery = {type = "instant", target_effects = create("offspring")}}}
local fish = {type = "fish", name = "fish", dying_trigger_effect = {type = "nested-result", action = {type = "direct", action_delivery = {type = "instant", target_effects = {type = "create-asteroid-chunk", asteroid_name = "salvage"}}}}}
for _, prototype in pairs({tree, child, rock, fish}) do
    data.raw[prototype.type] = data.raw[prototype.type] or {}
    data.raw[prototype.type][prototype.name] = prototype
end
data.raw["asteroid-chunk"] = {salvage = {type = "asteroid-chunk", name = "salvage"}}
data.raw["damage-type"] = {physical = {name = "physical"}}
fish.propertyrandomizer_death_payload = {type = "area", radius = 1, action_delivery = {type = "instant", target_effects = {type = "damage", damage = {amount = 3, type = "physical"}}}}
local lookup = require("src/prototypes/lookup/2-simple/entity-create")
local combat = require("src/prototypes/lookup/2-simple/combat")
local gutils = require("src/lib/graph/graph-utils")
local lu = {entities = {rock = rock, fish = fish, tree = tree, offspring = child}, items = {}, equipment = {}}
lookup.link(lu)
lookup.dying_spawns()
local rock_outputs = lu.dying_spawns[gutils.key("entity", "rock")]
assert(rock_outputs[gutils.key("entity", "tree")])
assert(not rock_outputs[gutils.key("entity", "offspring")], "the child's later death and host's creation action are separate sources")
assert(lu.dying_spawns[gutils.key("entity", "tree")][gutils.key("entity", "offspring")])
assert(lu.dying_spawns[gutils.key("entity", "fish")][gutils.key("asteroid-chunk", "salvage")])
assert(lu.dying_spawns_reverse[gutils.key("entity", "tree")][gutils.key("entity", "rock")])
combat.link(lu)
combat.damage_type_sources()
local source = lu.damage_type_sources.physical[gutils.key("entity-kill", "fish")]
assert(source and source.source_type == "death-effect" and source.amount == 3)
print("Death lookup includes rock/fish hosts and salvage, excludes unrelated creation, and preserves payload damage")

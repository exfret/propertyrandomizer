-- Bounds use an upper per-target estimate, so repeated branches and unknown hazards cannot pass as harmless.
local death = require("src/prototypes/entities/death-slots")
local function packet(amount, repeats)
    return {type = "damage", damage = {type = "physical", amount = amount}, repeat_count = repeats}
end
local prototypes = {
    bullet = {type = "projectile", action = packet(4)},
    blast = {type = "explosion", explosion_effect = packet(100)},
    loop = {type = "projectile", action = {type = "projectile", projectile = "loop"}},
}
local function lookup(name) return prototypes[name] end
local hit = packet(3)
assert(death.measure({hit, hit}, lookup) == 6, "shared tables represent separate executions")
assert(death.measure(packet(5, 3), lookup) == 15)
local probabilistic = packet(100)
probabilistic.probability = 0.01
assert(death.measure(probabilistic, lookup) == 100, "rare lethal outcomes must not be averaged away")
assert(death.measure({type = "projectile", projectile = "bullet", repeat_count = 2}, lookup) == 8)
assert(death.measure({type = "projectile", projectile = "loop"}, lookup) == nil)
assert(death.measure({type = "create-fire", entity_name = "unknown"}, lookup) == nil)
assert(death.measure({type = "create-sticker", sticker = "unknown"}, lookup) == nil)
assert(death.measure({type = "create-smoke", entity_name = "poison"}, lookup) == nil, "persistent smoke cannot pass as zero damage")
local clustered, reach = death.measure({type = "cluster", cluster_count = 7, distance = 4, distance_deviation = 3, action_delivery = {type = "projectile", projectile = "bullet"}}, lookup)
assert(clustered == 28 and reach == 7, "all cluster children and their reach count")
assert(death.measure({type = "create-entity", entity_name = "unknown"}, lookup) == nil)
local host = {attack_parameters = {ammo_type = packet(10)}}
assert(death.payload_fits(host, packet(20), lookup))
assert(not death.payload_fits(host, packet(21), lookup))
assert(not death.payload_fits(host, {type = "area", radius = 20, action_delivery = packet(10)}, lookup))
assert(not death.payload_fits(host, packet(1000), lookup))
assert(not death.payload_fits(host, {type = "create-entity", entity_name = "blast"}, lookup), "created explosions spend the payload budget too")
print("ok - death payload bounds, multiplicity, areas, cycles and unknown hazards")

assert(death.acyclic({rock = {creature = true}, creature = {tree = true}}))
assert(not death.acyclic({rock = {creature = true}, creature = {rock = true}}))
assert(death.payload_fits({}, packet(10), lookup, {damage = 5, health = 10}))
assert(not death.payload_fits({}, packet(11), lookup, {damage = 5, health = 10}))
print("ok - passive-host damage budget and death-chain cycles")

assert(not death.payload_fits(host, packet(10), lookup, nil, 3), "creature damage modifiers count toward the death budget")

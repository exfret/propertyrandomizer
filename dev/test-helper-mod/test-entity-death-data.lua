-- Runtime fixtures are added after the randomizer has finished, so they never enter matching.
local death = require("__propertyrandomizer__/src/prototypes/entities/death-slots")
local packages = require("__propertyrandomizer__/src/randomizations/unified/handler-helpers/projectile-packages")
local common = require("__propertyrandomizer__/src/randomizations/unified/handler-helpers/entity")
local dutils = require("__propertyrandomizer__/src/prototypes/data-utils")
local test = {}
test.run = function()
    local setting = settings.startup["propertyrandomizer-unified-entity"]
    if setting == nil or not setting.value then return end
    local host = table.deepcopy(data.raw.unit["small-biter"])
    host.name = "propertyrandomizer-test-death-tree"
    host.autoplace = nil
    host.corpse = nil
    host.dying_explosion = nil
    host.loot = nil
    host.dying_trigger_effect = {type = "create-entity", entity_name = "tree-01", find_non_colliding_position = true}
    local empty = table.deepcopy(data.raw["unit-spawner"]["biter-spawner"])
    empty.name = "propertyrandomizer-test-empty-spawner"
    empty.autoplace = nil
    empty.result_units = {{"small-biter", {{0, 0}, {1, 0}}}}
    local payload = table.deepcopy(host)
    payload.name = "propertyrandomizer-test-death-payload"
    local lookup = function(name) return dutils.get_prot("entity", name) end
    -- The live grenade item may have traded away its package; use the unchanged donor projectile.
    local source = {
        capsule_action = {
            type = "throw",
            attack_parameters = {
                ammo_type = {
                    action = {
                        type = "direct",
                        action_delivery = {type = "projectile", projectile = "grenade"},
                    },
                },
            },
        },
    }
    local action = assert(common.capsule_impact_action(source, lookup))
    local copied, copies = packages.copy_action(action, lookup, "propertyrandomizer-test-death-package")
    if #copies > 0 then data:extend(copies) end
    payload.dying_trigger_effect = nil
    death.append(payload, {type = "nested-result", action = copied})
    data:extend({host, empty, payload})
    if data.raw["asteroid-chunk"] ~= nil and data.raw["asteroid-chunk"]["metallic-asteroid-chunk"] ~= nil then
        local item = table.deepcopy(data.raw.item["steel-chest"])
        item.name = "propertyrandomizer-test-salvage-item"
        item.place_result = "steel-chest"
        local template = assert(death.salvage_template(data.raw["asteroid-chunk"]))
        local chunk = death.salvage_chunk(template, "propertyrandomizer-test-salvage-chunk", item.name, common.icon_layers(item, ""))
        assert(not chunk.hidden and chunk.graphics_set ~= nil, "salvage must be visible, not an engine placeholder")
        assert(chunk.graphics_set.sprite.layers[1].filename == common.icon_layers(item, "")[1].icon)
        assert(chunk.graphics_set.variations == nil, "salvage must show its icon instead of asteroid textures")
        local asteroid = table.deepcopy(data.raw.asteroid["big-oxide-asteroid"])
        asteroid.name = "propertyrandomizer-test-salvage-asteroid"
        death.append(asteroid, {type = "create-asteroid-chunk", asteroid_name = chunk.name})
        local collector = table.deepcopy(data.raw["asteroid-collector"]["asteroid-collector"])
        collector.name = "propertyrandomizer-test-salvage-collector"
        collector.energy_source = {type = "void"}
        data:extend({item, chunk, asteroid, collector})
    end
end
return test

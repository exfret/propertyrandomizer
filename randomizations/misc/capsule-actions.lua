-- We use the dependency graph to double check that an item is actually reachable
-- Properties of some objects are modified, but none in ways that would modify the dependency graph
local build_graph = require("lib/graph/build-graph")
local top_sort = require("lib/graph/top-sort")
local rng = require("lib/random/rng")
local locale_utils = require("lib/locale")

randomizations.capsule_actions = function(id)
    -- Don't permute around equipment activation or artillery remote actions, that's too confusing
    -- Also make sure cliff explosives always explode cliffs so that there is always something to get rid of them
    local blacklisted_action_types = {
        ["equipment-remote"] = true,
        ["artillery-remote"] = true,
        ["destroy-cliffs"] = true
    }
    
    local capsule_prototype_list = {}
    local capsule_action_list = {}
    for _, capsule in pairs(data.raw.capsule) do
        if not blacklisted_action_types[capsule.capsule_action.type] then
            table.insert(capsule_prototype_list, capsule)
            table.insert(capsule_action_list, capsule.capsule_action)
        end
    end

    -- Gather all reachable item prototypes
    local item_prototypes = {}
    for _, item_node in pairs(top_sort.sort(build_graph.graph).sorted) do
        if item_node.type == "item" then
            local item = data.raw.item[item_node.name]
            if item ~= nil then
                if item.place_result == nil and item.place_as_equipment_result == nil and item.plant_result == nil and item.place_as_tile == nil then
                    table.insert(item_prototypes, item)
                end
            end
        end
    end

    -- Create an empty slot item for each "real" capsule
    local old_num_capsules = #capsule_prototype_list
    local already_added = {}
    for i = 1, old_num_capsules do
        -- Randomly choose an item as having an empty capsule action
        -- If we come across a duplicate, just don't add it; this could lead to fewer than expected slots but it's not a big deal
        local proposed_new_capsule = item_prototypes[rng.int(rng.key({id = id}), #item_prototypes)]
        if not already_added[proposed_new_capsule.name] then
            table.insert(capsule_prototype_list, proposed_new_capsule)
            table.insert(capsule_action_list, "none")
        end
    end

    --[[ Custom capsule actions are cool, but let's leave custom content to base game and other mods.
    -- Also that atomic capsule is ridiculous.
    
    -- Create new capsule actions

    local atomic_capsule_action = table.deepcopy(data.raw.capsule.grenade.capsule_action)
    atomic_capsule_action.attack_parameters.ammo_type.action[1].action_delivery.projectile = "atomic-rocket"
    atomic_capsule_action.attack_parameters.cooldown = 120
    atomic_capsule_action.attack_parameters.range = 30
    table.insert(capsule_prototype_list, "dummy-atomic")
    table.insert(capsule_action_list, atomic_capsule_action)

    local flame_capsule_action = table.deepcopy(data.raw.capsule.grenade.capsule_action)
    flame_capsule_action.attack_parameters = data.raw["fluid-turret"]["flamethrower-turret"].attack_parameters
    flame_capsule_action.attack_parameters.min_range = 0
    flame_capsule_action.attack_parameters.damage_modifier = 5
    flame_capsule_action.attack_parameters.range = 10
    table.insert(capsule_prototype_list, "dummy-flame")
    table.insert(capsule_action_list, flame_capsule_action)

    local biter_capsule_action = {
        type = "throw",
        attack_parameters = {
            type = "projectile",
            range = 22,
            cooldown = 10,
            ammo_category = "capsule",
            ammo_type = {
                action = {
                    type = "direct",
                    action_delivery = {
                        type = "instant",
                        target_effects = {
                            type = "create-entity",
                            entity_name = "small-biter",
                            check_buildability = true,
                            as_enemy = true,
                            find_non_colliding_position = true
                        }
                    }
                }
            }
        }
    }
    table.insert(capsule_prototype_list, "dummy-biter")
    table.insert(capsule_action_list, biter_capsule_action)

    local teleport_capsule_action = {
        type = "throw",
        attack_parameters = {
            type = "projectile",
            range = 29,
            cooldown = 200,
            ammo_category = "capsule",
            ammo_type = {
                action = {
                    type = "direct",
                    action_delivery = {
                        type = "instant",
                        target_effects = {
                            type = "script",
                            effect_id = "teleport-player"
                        }
                    }
                }
            }
        }
    }
    table.insert(capsule_prototype_list, "dummy-teleport")
    table.insert(capsule_action_list, teleport_capsule_action)
]]
    -- Now shuffle capsule actions and reassign
    
    rng.shuffle(rng.key({id = id}), capsule_action_list)

    for ind, action in pairs(capsule_action_list) do
        next_prototype = capsule_prototype_list[ind]
        if type(next_prototype) == "table" then
            if action == "none" then
                next_prototype.capsule_action = nil

                if next_prototype.type == "capsule" then
                    next_prototype.type = "item"
                    data.raw.capsule[next_prototype.name] = nil
                    data.raw.item[next_prototype.name] = next_prototype
                    -- next_prototype.localised_name = {"", "Broken ", locale_utils.find_localised_name(next_prototype)}
                    next_prototype.localised_description = {"", locale_utils.find_localised_description(next_prototype), "\n[color=red](Dysfunctional)[/color]"}
                end
            else
                next_prototype.capsule_action = action

                if next_prototype.type == "item" then
                    next_prototype.type = "capsule"
                    data.raw.item[next_prototype.name] = nil
                    data.raw.capsule[next_prototype.name] = next_prototype
                    -- next_prototype.localised_name = {"", locale_utils.find_localised_name(next_prototype), " (Capsule)"}
                    next_prototype.localised_description = {"", locale_utils.find_localised_description(next_prototype), "\n[color=green](Single-use)[/color]"}
                end
            end
        end
    end
end
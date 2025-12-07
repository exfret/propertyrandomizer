

local export = {}

local prototype_projectile = "projectile"
local prototype_artillery_projectile = "artillery-projectile"
local prototype_beam = "beam"
local prototype_stream = "stream"
local prototype_chain_active_trigger = "chain-active-trigger"
local prototype_delayed_active_trigger = "delayed-active-trigger"
local prototype_ammo = "ammo"
local prototype_capsule = "capsule"
local prototype_combat_robot = "combat-robot"
local prototype_smoke_with_trigger = "smoke-with-trigger"
local prototype_sticker = "sticker"
local prototype_spider_unit = "spider-unit"
local prototype_spider_leg = "spider-leg"
local prototype_unit = "unit"
local prototype_tree = "tree"
local prototype_explosion = "explosion"
local prototype_capture_robot = "capture-robot"
local prototype_land_mine = "land-mine"
local prototype_fire = "fire"
local prototype_segmented_unit = "segmented-unit"
local prototype_segment = "segment"
local prototype_asteroid = "asteroid"

local struct_trigger_effect = "trigger-effect"
local struct_trigger_delivery = "trigger-delivery"
local struct_trigger = "trigger"
local struct_ammo_type = "ammo-type"
local struct_capsule_action = "capsule-action"
local struct_attack_parameters = "attack-parameters"
local struct_trigger_effect_with_cooldown = "trigger-effect-with-cooldown"
local struct_spider_engine_specification = "spider-engine-specification"
local struct_spider_leg_specification = "spider-leg-specification"
local struct_attack_reaction_item = "attack-reaction-item"
local struct_spider_leg_trigger_effect = "spider-leg-trigger-effect"
local struct_explosion_definition = "explosion-definition"
local struct_damage_parameters = "damage-parameters"
local struct_spoil_to_trigger_result = "spoil-to-trigger-result"
local struct_segment_engine_specification = "segment-engine-specification"
local struct_segment_specification = "segment-specification"

local data_raw_table = function (class)
    return data.raw[class] or {}
end

local items = {}
for class, _ in pairs(defines.prototypes.item) do
    for _, item in pairs(data_raw_table(class)) do
        items[item.name] = item
    end
end

local entities = {}
for class, _ in pairs(defines.prototypes.entity) do
    for _, entity in pairs(data_raw_table(class)) do
        entities[entity.name] = entity
    end
end

local mtm_insert = function (mtm_table, key, value)
    if mtm_table[key] == nil then
        mtm_table[key] = {}
    end
    table.insert(mtm_table[key], value)
end

local mtm_set_insert = function (mtm_table, key, name, value)
    if mtm_table[key] == nil then
        mtm_table[key] = {}
    end
    mtm_table[key][name] = value
end

local find_item_class = function (item_name)
    for class, _ in pairs(defines.prototypes.item) do
        if data_raw_table(class)[item_name] ~= nil then
            return class
        end
    end
    error()
end
local gather_item_name_structs = function (structs, item_name, stop_prototype)
    local class = find_item_class(item_name)
    if structs[class] ~= nil and structs[class][item_name] ~= nil then
        return
    end
    if stop_prototype ~= true and class ~= nil and class ~= stop_prototype then
        local item = data_raw_table(class)[item_name]
        mtm_set_insert(structs, class, item_name, item)
        local gather_structs = export.item_class_to_gather_struct_func[class]
        if gather_structs ~= nil then
            gather_structs(structs, item, stop_prototype)
        end
    end
end

local find_entity_class = function (entity_name)
    for class, _ in pairs(defines.prototypes.entity) do
        if data_raw_table(class)[entity_name] ~= nil then
            return class
        end
    end
    error()
end
local gather_entity_name_structs = function (structs, entity_name, stop_prototype)
    local class = find_entity_class(entity_name)
    if structs[class] ~= nil and structs[class][entity_name] ~= nil then
        return
    end
    if stop_prototype ~= true and class ~= nil and class ~= stop_prototype then
        local entity = data_raw_table(class)[entity_name]
        mtm_set_insert(structs, class, entity_name, entity)
        local gather_structs = export.entity_class_to_gather_struct_func[class]
        if gather_structs ~= nil then
            gather_structs(structs, entity, stop_prototype)
        end
    end
end

local find_active_trigger_name_class = function (active_trigger_name)
    for class, _ in pairs(defines.prototypes["active-trigger"]) do
        if data_raw_table(class)[active_trigger_name] ~= nil then
            return class
        end
    end
    error()
end
local gather_active_trigger_structs = function (structs, active_trigger_name, stop_prototype)
    local class = find_active_trigger_name_class(active_trigger_name)
    if structs[class] ~= nil and structs[class][active_trigger_name] ~= nil then
        return
    end
    if stop_prototype ~= true and class ~= nil and class ~= stop_prototype then
        local active_trigger = data_raw_table(class)[active_trigger_name]
        mtm_set_insert(structs, class, active_trigger_name, active_trigger)
        local gather_structs = export.active_trigger_class_to_gather_struct_func[class]
        if gather_structs ~= nil then
            gather_structs(structs, active_trigger, stop_prototype)
        end
    end
end

local to_array = function (single_or_array)
    if type(single_or_array) ~= "table" or single_or_array[1] == nil then
        return { single_or_array }
    end
    return single_or_array
end

local gather_damage_parameters_structs = function (structs, damage_parameters, stop_prototype)
    mtm_insert(structs, struct_damage_parameters, damage_parameters)
end

local gather_trigger_effect_structs = function (structs, trigger_effect, stop_prototype)
    local trigger_effects = to_array(trigger_effect)
    for _, te in pairs(trigger_effects) do
        mtm_insert(structs, struct_trigger_effect, te)
        if te.action ~= nil then
            export.gather_trigger_structs(structs, te.action, stop_prototype)
        end
        if te.damage ~= nil then
            gather_damage_parameters_structs(structs, te.damage, stop_prototype)
        end
        if te.entity_name ~= nil then
            gather_entity_name_structs(structs, te.entity_name, stop_prototype)
        end
        if te.non_colliding_fail_result ~= nil then
            export.gather_trigger_structs(structs, te.non_colliding_fail_result, stop_prototype)
        end
        if te.sticker ~= nil then
            gather_entity_name_structs(structs, te.sticker, stop_prototype)
        end
    end
end

local gather_trigger_delivery_structs = function (structs, trigger_delivery, stop_prototype)
    mtm_insert(structs, struct_trigger_delivery, trigger_delivery)
    if trigger_delivery.source_effects ~= nil then
        to_array(trigger_delivery.source_effects)
        gather_trigger_effect_structs(structs, trigger_delivery.source_effects, stop_prototype)
    end
    if trigger_delivery.target_effects ~= nil then
        to_array(trigger_delivery.target_effects)
        gather_trigger_effect_structs(structs, trigger_delivery.target_effects, stop_prototype)
    end
    if trigger_delivery.projectile ~= nil then
        gather_entity_name_structs(structs, trigger_delivery.projectile, stop_prototype)
    end
    if trigger_delivery.beam ~= nil then
        gather_entity_name_structs(structs, trigger_delivery.beam, stop_prototype)
    end
    if trigger_delivery.stream ~= nil then
        gather_entity_name_structs(structs, trigger_delivery.stream, stop_prototype)
    end
    if trigger_delivery.chain ~= nil then
        gather_active_trigger_structs(structs, trigger_delivery.chain, stop_prototype)
    end
    if trigger_delivery.delayed_trigger ~= nil then
        gather_active_trigger_structs(structs, trigger_delivery.delayed_trigger, stop_prototype)
    end
end

local gather_ammo_type_structs = function (structs, ammo_type, stop_prototype)
    mtm_insert(structs, struct_ammo_type, ammo_type)
    if ammo_type.action ~= nil then
        export.gather_trigger_structs(structs, ammo_type.action, stop_prototype)
    end
end

local gather_attack_parameters_structs = function (structs, attack_parameters, stop_prototype)
    mtm_insert(structs, struct_attack_parameters, attack_parameters)
    if attack_parameters.ammo_type ~= nil then
        gather_ammo_type_structs(structs, attack_parameters.ammo_type, stop_prototype)
    end
end

local gather_capsule_action_structs = function (structs, capsule_action, stop_prototype)
    mtm_insert(structs, struct_capsule_action, capsule_action)
    if capsule_action.attack_parameters ~= nil then
        gather_attack_parameters_structs(structs, capsule_action.attack_parameters, stop_prototype)
    end
end

local gather_trigger_effect_with_cooldown_structs = function (structs, trigger_effect_with_cooldown, stop_prototype)
    mtm_insert(structs, struct_trigger_effect_with_cooldown, trigger_effect_with_cooldown)
    gather_trigger_effect_structs(structs, trigger_effect_with_cooldown.effect, stop_prototype)
end

local gather_spider_leg_specification_structs = function (structs, spider_leg_specification, stop_prototype)
    mtm_insert(structs, struct_spider_leg_specification, spider_leg_specification)
    gather_entity_name_structs(structs, spider_leg_specification.leg, stop_prototype)
    if spider_leg_specification.leg_hit_the_ground_trigger ~= nil then
        gather_trigger_effect_structs(structs, spider_leg_specification.leg_hit_the_ground_trigger, stop_prototype)
    end
    if spider_leg_specification.leg_hit_the_ground_when_attacking_trigger ~= nil then
        gather_trigger_effect_structs(structs, spider_leg_specification.leg_hit_the_ground_when_attacking_trigger, stop_prototype)
    end
end

local gather_spider_engine_specification_structs = function (structs, spider_engine_specification, stop_prototype)
    mtm_insert(structs, struct_spider_engine_specification, spider_engine_specification)
    local spider_leg_specifications = to_array(spider_engine_specification.legs)
    for _, spider_leg_specification in pairs(spider_leg_specifications) do
        gather_spider_leg_specification_structs(structs, spider_leg_specification, stop_prototype)
    end
end

local gather_attack_reaction_item_structs = function (structs, attack_reaction_item, stop_prototype)
    mtm_insert(structs, struct_attack_reaction_item, attack_reaction_item)
    if attack_reaction_item.action ~= nil then
        export.gather_trigger_structs(structs, attack_reaction_item.action, stop_prototype)
    end
end

local gather_entity_structs = function (structs, entity, stop_prototype)
    if entity.created_effect ~= nil then
        export.gather_trigger_structs(structs, entity.created_effect, stop_prototype)
    end
end

local gather_explosion_definition_structs = function (structs, explosion_definition, stop_prototype)
    if type(explosion_definition) == "string" then
        gather_entity_name_structs(structs, explosion_definition, stop_prototype)
    else
        mtm_insert(structs, struct_explosion_definition, explosion_definition)
        gather_entity_name_structs(structs, explosion_definition.name, stop_prototype)
    end
end

local gather_entity_with_health_structs = function (structs, entity_with_health, stop_prototype)
    gather_entity_structs(structs, entity_with_health, stop_prototype)
    if entity_with_health.dying_explosion ~= nil then
        local explosion_definitions = to_array(entity_with_health.dying_explosion)
        for _, explosion_definition in pairs(explosion_definitions) do
            gather_explosion_definition_structs(structs, explosion_definition, stop_prototype)
        end
    end
    if entity_with_health.dying_trigger_effect ~= nil then
        gather_trigger_effect_structs(structs, entity_with_health.dying_trigger_effect, stop_prototype)
    end
    if entity_with_health.damaged_trigger_effect ~= nil then
        gather_trigger_effect_structs(structs, entity_with_health.damaged_trigger_effect, stop_prototype)
    end
    if entity_with_health.attack_reaction ~= nil then
        local attack_reaction_items = to_array(entity_with_health.attack_reaction)
        for _, attack_reaction_item in pairs(attack_reaction_items) do
            gather_attack_reaction_item_structs(structs, attack_reaction_item, stop_prototype)
        end
    end
end

local gather_spider_leg_trigger_effect_structs = function (structs, spider_leg_trigger_effect, stop_prototype)
    mtm_insert(structs, struct_spider_leg_trigger_effect, spider_leg_trigger_effect)
    gather_trigger_effect_structs(structs, spider_leg_trigger_effect.effect, stop_prototype)
end

local gather_spoil_to_trigger_result_structs = function (structs, spoil_to_trigger_result, stop_prototype)
    mtm_insert(structs, struct_spoil_to_trigger_result, spoil_to_trigger_result)
    export.gather_trigger_structs(structs, spoil_to_trigger_result.trigger, stop_prototype)
end

local gather_segment_specification_structs = function (structs, segment_specification, stop_prototype)
    mtm_insert(structs, struct_segment_specification, segment_specification)
    gather_entity_name_structs(structs, segment_specification.segment, stop_prototype)
end

local gather_segment_engine_specification_structs = function (structs, segment_engine_specification, stop_prototype)
    mtm_insert(structs, struct_segment_engine_specification, segment_engine_specification)
    for _, segment_specification in pairs(segment_engine_specification.segments) do
        gather_segment_specification_structs(structs, segment_specification, stop_prototype)
    end
end

export.gather_trigger_structs = function (structs, trigger, stop_prototype)
    local triggers = to_array(trigger)
    for _, t in pairs(triggers) do
        mtm_insert(structs, struct_trigger, t)
        if t.action_delivery ~= nil then
            local trigger_deliveries = t.action_delivery
            if trigger_deliveries.type ~= nil then
                trigger_deliveries = { t.action_delivery }
            end
            for _, trigger_delivery in pairs(trigger_deliveries) do
                gather_trigger_delivery_structs(structs, trigger_delivery, stop_prototype)
            end
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------
--- The functions below all return a table that maps struct names (like "trigger-effect") to a list of matching structs,
--- found by recursively searching contained structs and optionally following prototype references.
-------------------------------------------------------------------------------------------------------------------------------

export.gather_projectile_structs = function (structs, projectile, stop_prototype)
    gather_entity_structs(structs, projectile, stop_prototype)
    if projectile.action ~= nil then
        export.gather_trigger_structs(structs, projectile.action, stop_prototype)
    end
    if projectile.final_action ~= nil then
        export.gather_trigger_structs(structs, projectile.final_action, stop_prototype)
    end
end

export.gather_beam_structs = function (structs, beam, stop_prototype)
    gather_entity_structs(structs, beam, stop_prototype)
    if beam.action ~= nil then
        export.gather_trigger_structs(structs, beam.action, stop_prototype)
    end
end

export.gather_stream_structs = function (structs, stream, stop_prototype)
    gather_entity_structs(structs, stream, stop_prototype)
    if stream.initial_action ~= nil then
        export.gather_trigger_structs(structs, stream.initial_action, stop_prototype)
    end
    if stream.action ~= nil then
        export.gather_trigger_structs(structs, stream.action, stop_prototype)
    end
    if stream.special_neutral_target_damage ~= nil then
        gather_damage_parameters_structs(structs, stream.special_neutral_target_damage, stop_prototype)
    end
end

export.gather_artillery_projectile_structs = function (structs, artillery_projectile, stop_prototype)
    gather_entity_structs(structs, artillery_projectile, stop_prototype)
    if artillery_projectile.action ~= nil then
        export.gather_trigger_structs(structs, artillery_projectile.action, stop_prototype)
    end
    if artillery_projectile.final_action ~= nil then
        export.gather_trigger_structs(structs, artillery_projectile.final_action, stop_prototype)
    end
end

export.gather_chain_active_trigger_structs = function (structs, chain_active_trigger, stop_prototype)
    if chain_active_trigger.action ~= nil then
        export.gather_trigger_structs(structs, chain_active_trigger.action, stop_prototype)
    end
end

export.gather_delayed_active_trigger_structs = function (structs, delayed_active_trigger, stop_prototype)
    if delayed_active_trigger.action ~= nil then
        export.gather_trigger_structs(structs, delayed_active_trigger.action, stop_prototype)
    end
end

export.gather_ammo_structs = function (structs, ammo, stop_prototype)
    export.gather_item_structs(structs, ammo, stop_prototype)
    local ammo_types = to_array(ammo.ammo_type)
    for _, ammo_type in pairs(ammo_types) do
        gather_ammo_type_structs(structs, ammo_type, stop_prototype)
    end
end

export.gather_capsule_structs = function (structs, capsule, stop_prototype)
    export.gather_item_structs(structs, capsule, stop_prototype)
    gather_capsule_action_structs(structs, capsule.capsule_action, stop_prototype)
end

export.gather_combat_robot_structs = function (structs, combat_robot, stop_prototype)
    gather_entity_structs(structs, combat_robot, stop_prototype)
    gather_attack_parameters_structs(structs, combat_robot.attack_parameters, stop_prototype)
    if combat_robot.destroy_action ~= nil then
        export.gather_trigger_structs(structs, combat_robot.destroy_action, stop_prototype)
    end
end

export.gather_smoke_with_trigger_structs = function (structs, smoke_with_trigger, stop_prototype)
    gather_entity_structs(structs, smoke_with_trigger, stop_prototype)
    if smoke_with_trigger.action ~= nil then
        export.gather_trigger_structs(structs, smoke_with_trigger.action, stop_prototype)
    end
end

export.gather_sticker_structs = function (structs, sticker, stop_prototype)
    gather_entity_structs(structs, sticker, stop_prototype)
    if sticker.update_effects ~= nil then
        gather_trigger_effect_with_cooldown_structs(structs, sticker.update_effects, stop_prototype)
    end
    if sticker.damage_per_tick ~= nil then
        gather_damage_parameters_structs(structs, sticker.damage_per_tick, stop_prototype)
    end
end

export.gather_spider_unit_structs = function (structs, spider_unit, stop_prototype)
    gather_entity_with_health_structs(structs, spider_unit, stop_prototype)
    gather_spider_engine_specification_structs(structs, spider_unit.spider_engine, stop_prototype)
    gather_attack_parameters_structs(structs, spider_unit.attack_parameters, stop_prototype)
end

export.gather_spider_leg_structs = function (structs, spider_leg, stop_prototype)
    gather_entity_with_health_structs(structs, spider_leg, stop_prototype)
    if spider_leg.upper_leg_dying_trigger_effects ~= nil then
        for _, spider_leg_trigger_effect in pairs(spider_leg.upper_leg_dying_trigger_effects) do
            gather_spider_leg_trigger_effect_structs(structs, spider_leg_trigger_effect, stop_prototype)
        end
    end
    if spider_leg.lower_leg_dying_trigger_effects ~= nil then
        for _, spider_leg_trigger_effect in pairs(spider_leg.lower_leg_dying_trigger_effects) do
            gather_spider_leg_trigger_effect_structs(structs, spider_leg_trigger_effect, stop_prototype)
        end
    end
end

export.gather_unit_structs = function (structs, unit, stop_prototype)
    gather_entity_with_health_structs(structs, unit, stop_prototype)
    gather_attack_parameters_structs(structs, unit.attack_parameters, stop_prototype)
end

export.gather_tree_structs = function (structs, tree, stop_prototype)
    gather_entity_with_health_structs(structs, tree, stop_prototype)
end

export.gather_explosion_structs = function (structs, explosion, stop_prototype)
    gather_entity_structs(structs, explosion, stop_prototype)
    if explosion.explosion_effect ~= nil then
        export.gather_trigger_structs(structs, explosion.explosion_effect, stop_prototype)
    end
end

export.gather_capture_robot_structs = function (structs, capture_robot, stop_prototype)
    gather_entity_with_health_structs(structs, capture_robot, stop_prototype)
    if capture_robot.destroy_action ~= nil then
        export.gather_trigger_structs(structs, capture_robot.destroy_action, stop_prototype)
    end
end

export.gather_item_structs = function (structs, item, stop_prototype)
    if item.spoil_to_trigger_result ~= nil then
        gather_spoil_to_trigger_result_structs(structs, item.spoil_to_trigger_result, stop_prototype)
    end
    if item.destroyed_by_dropping_trigger ~= nil then
        export.gather_trigger_structs(structs, item.destroyed_by_dropping_trigger, stop_prototype)
    end
end

export.gather_land_mine_structs = function (structs, land_mine, stop_prototype)
    gather_entity_with_health_structs(structs, land_mine, stop_prototype)
    if land_mine.action ~= nil then
        export.gather_trigger_structs(structs, land_mine.action, stop_prototype)
    end
end

export.gather_fire_structs = function (structs, fire, stop_prototype)
    gather_entity_structs(structs, fire, stop_prototype)
    gather_damage_parameters_structs(structs, fire.damage_per_tick, stop_prototype)
    if fire.spawn_entity ~= nil then
        gather_entity_name_structs(structs, fire.spawn_entity, stop_prototype)
    end
    if fire.on_fuel_added_action ~= nil then
        export.gather_trigger_structs(structs, fire.on_fuel_added_action, stop_prototype)
    end
    if fire.on_damage_tick_effect ~= nil then
        export.gather_trigger_structs(structs, fire.on_damage_tick_effect, stop_prototype)
    end
end

export.gather_segment_structs = function (structs, segmented_unit, stop_prototype)
    gather_entity_with_health_structs(structs, segmented_unit, stop_prototype)
    if segmented_unit.update_effects ~= nil then
        gather_trigger_effect_with_cooldown_structs(structs, segmented_unit.update_effects, stop_prototype)
    end
    if segmented_unit.update_effects_while_enraged ~= nil then
        gather_trigger_effect_with_cooldown_structs(structs, segmented_unit.update_effects_while_enraged, stop_prototype)
    end
end

export.gather_segmented_unit_structs = function (structs, segmented_unit, stop_prototype)
    export.gather_segment_structs(structs, segmented_unit, stop_prototype)
    gather_segment_engine_specification_structs(structs, segmented_unit.segment_engine, stop_prototype)
    if segmented_unit.attack_parameters then
        gather_attack_parameters_structs(structs, segmented_unit.attack_parameters, stop_prototype)
    end
    if segmented_unit.revenge_attack_parameters then
        gather_attack_parameters_structs(structs, segmented_unit.revenge_attack_parameters, stop_prototype)
    end
end

export.gather_asteroid_structs = function (structs, asteroid, stop_prototype)
    gather_entity_with_health_structs(structs, asteroid, stop_prototype)
end

-------------------------------------------------------------------------------------------------------------------------------
--- This returns a table that maps prototypes of a certain type to prototypes that may (directly or undirectly) create it
-------------------------------------------------------------------------------------------------------------------------------

local prototype_to_creators = {}

export.get_creator_table = function (prototype_type)
    if prototype_to_creators[prototype_type] ~= nil then
        return prototype_to_creators[prototype_type]
    end

    prototype_to_creators[prototype_type] = {}

    for item_name, item in pairs(items) do
        local structs = {}
        gather_item_name_structs(structs, item_name)
        for _, prototype in pairs(structs[prototype_type] or {}) do
            mtm_insert(prototype_to_creators[prototype_type], prototype.name, item)
        end
    end

    for entity_name, entity in pairs(entities) do
        local structs = {}
        gather_entity_name_structs(structs, entity_name)
        for _, prototype in pairs(structs[prototype_type] or {}) do
            mtm_insert(prototype_to_creators[prototype_type], prototype.name, entity)
        end
    end

    return prototype_to_creators[prototype_type]
end

export.item_class_to_gather_struct_func = {
    [prototype_ammo] = export.gather_ammo_structs,
    [prototype_capsule] = export.gather_capsule_structs,
}

export.entity_class_to_gather_struct_func = {
    [prototype_projectile] = export.gather_projectile_structs,
    [prototype_beam] = export.gather_beam_structs,
    [prototype_stream] = export.gather_stream_structs,
    [prototype_artillery_projectile] = export.gather_artillery_projectile_structs,
    [prototype_combat_robot] = export.gather_combat_robot_structs,
    [prototype_smoke_with_trigger] = export.gather_smoke_with_trigger_structs,
    [prototype_sticker] = export.gather_sticker_structs,
    [prototype_spider_unit] = export.gather_spider_unit_structs,
    [prototype_spider_leg] = export.gather_spider_leg_structs,
    [prototype_unit] = export.gather_unit_structs,
    [prototype_tree] = export.gather_tree_structs,
    [prototype_explosion] = export.gather_explosion_structs,
    [prototype_capture_robot] = export.gather_capture_robot_structs,
    [prototype_land_mine] = export.gather_land_mine_structs,
    [prototype_fire] = export.gather_fire_structs,
    [prototype_segmented_unit] = export.gather_segmented_unit_structs,
    [prototype_segment] = export.gather_segment_structs,
    [prototype_asteroid] = export.gather_asteroid_structs,
}

export.active_trigger_class_to_gather_struct_func = {
    [prototype_chain_active_trigger] = export.gather_chain_active_trigger_structs,
    [prototype_delayed_active_trigger] = export.gather_delayed_active_trigger_structs,
}

return export
local categories = {}

categories.belts = {
    ["transport-belt"] = true,
    ["underground-belt"] = true,
    ["splitter"] = true,
    ["linked-belt"] = true,
    ["loader-1x1"] = true,
    ["loader"] = true,
    ["lane-splitter"] = true
}

categories.bot_classes = {
    ["capture-robot"] = true,
    ["combat-robot"] = true,
    ["construction-robot"] = true,
    ["logistic-robot"] = true
}

categories.crafting_machines = {
    ["assembling-machine"] = true,
    ["furnace"] = true,
    ["rocket-silo"] = true
}

categories.effect_receivers = {
    ["assembling-machine"] = true,
    ["rocket-silo"] = true,
    ["furnace"] = true,
    ["lab"] = true,
    ["mining-drill"] = true
}

categories.enemy_health_classes = {
    ["asteroid"] = true,
    ["segment"] = true,
    ["segmented-unit"] = true,
    ["simple-entity"] = true,
    ["spider-unit"] = true,
    ["tree"] = true, -- They're standing in the way of my factory!
    ["turret"] = true,
    ["unit"] = true,
    ["unit-spawner"] = true
}

-- Excludes some entities like linked-container
categories.entities_with_inventory = {
    ["car"] = true,
    ["cargo-landing-pad"] = true,
    -- These are randomized separately
    --["cargo-wagon"] = true,
    --["container"] = true,
    --["logistic-container"] = true,
    ["space-platform-hub"] = true,
    ["spider-vehicle"] = true,
}

categories.entities_with_module_slots = {
    ["beacon"] = true,
    ["assembling-machine"] = true,
    ["rocket-silo"] = true,
    ["furnace"] = true,
    ["lab"] = true,
    ["mining-drill"] = true
}

categories.equipment_energy_usage_keys = {
    ["belt-immunity-equipment"] = {["energy_consumption"] = "power"},
    ["movement-bonus-equipment"] = {["energy_consumption"] = "power"},
    ["night-vision-equipment"] = {["energy_input"] = "power"}
}

categories.machine_energy_usage_keys = {
    ["agricultural-tower"] = {["energy_usage"] = "power", ["crane_energy_usage"] = "power"},
    ["ammo-turret"] = {["energy_per_shot"] = "energy"},
    ["assembling-machine"] = {["energy_usage"] = "power"},
    ["asteroid-collector"] = {["passive_energy_usage"] = "energy", ["arm_energy_usage"] = "energy", ["arm_slow_energy_usage"] = "energy"},
    ["beacon"] = {["energy_usage"] = "power"},
    ["furnace"] = {["energy_usage"] = "power"},
    ["inserter"] = {["energy_per_movement"] = "energy", ["energy_per_rotation"] = "energy"},
    ["lab"] = {["energy_usage"] = "power"},
    ["lamp"] = {["energy_usage_per_tick"] = "energy"},
    ["loader"] = {["energy_per_item"] = "energy"},
    ["loader-1x1"] = {["energy_per_item"] = "energy"},
    ["mining-drill"] = {["energy_usage"] = "power"},
    ["offshore-pump"] = {["energy_usage"] = "power"},
    ["programmable-speaker"] = {["energy_usage_per_tick"] = "energy"},
    ["pump"] = {["energy_usage"] = "power"},
    ["radar"] = {["energy_usage"] = "power"},
    ["roboport"] = {["energy_usage"] = "power"},
    ["rocket-silo"] = {["active_energy_usage"] = "power", ["lamp_energy_usage"] = "power", ["energy_usage"] = "power"},
    ["arithmetic-combinator"] = {["active_energy_usage"] = "power"},
    ["decider-combinator"] = {["active_energy_usage"] = "power"},
    ["selector-combinator"] = {["active_energy_usage"] = "power"},
    ["spidertron"] = {["movement_energy_consumption"] = "power"}
}

-- This doesn't include stuff like blueprint books and selection tool
-- Still includes stuff like red wire since those are classified as items
categories.normal_item_classes = {
    ["ammo"] = true,
    ["armor"] = true,
    ["capsule"] = true,
    ["gun"] = true,
    ["item"] = true,
    ["item-with-entity-data"] = true,
    ["item-with-inventory"] = true,
    ["item-with-label"] = true,
    ["item-with-tags"] = true,
    ["module"] = true,
    ["repair-tool"] = true,
    ["space-platform-starter-pack"] = true,
    ["tool"] = true,
}

categories.special_item_subgroups = {
    ["spawnables"] = true
}

-- Note: Artillery turrets not included
-- Also note that normal turrets aren't included since they correspond to worms
categories.turrets = {
    ["ammo-turret"] = true,
    ["electric-turret"] = true,
    ["fluid-turret"] = true
}

categories.vehicles = {
    ["car"] = true,
    ["artillery-wagon"] = true,
    ["cargo-wagon"] = true,
    ["fluid-wagon"] = true,
    ["locomotive"] = true,
    ["spider-vehicle"] = true
}

return categories
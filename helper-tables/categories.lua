local categories = {}

categories.ammo_required = {
    ["ammo-turret"] = true,
    ["artillery-turret"] = true,
}

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

categories.corpse = {
    ["corpse"] = true,
    ["character-corpse"] = true,
    ["rail-remnants"] = true,
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

-- The following only consider powering the machine, not power that the machine provides
categories.energy_sources_input = {
    ["agricultural-tower"] = "energy_source",
    ["ammo-turret"] = "energy_source",
    ["arithmetic-combinator"] = "energy_source",
    ["assembling-machine"] = "energy_source",
    ["asteroid-collector"] = "energy_source",
    beacon = "energy_source",
    boiler = "energy_source",
    ["burner-generator"] = "burner",
    car = "energy_source",
    ["decider-combinator"] = "energy_source",
    ["electric-turret"] = "energy_source",
    furnace = "energy_source",
    ["fusion-reactor"] = {"burner", "energy_source"}, -- Has two operability energy sources
    inserter = "energy_source",
    lab = "energy_source",
    lamp = "energy_source",
    loader = "energy_source",
    ["loader-1x1"] = "energy_source",
    locomotive = "energy_source",
    ["mining-drill"] = "energy_source",
    ["offshore-pump"] = "energy_source",
    ["programmable-speaker"] = "energy_source",
    pump = "energy_source",
    radar = "energy_source",
    reactor = "energy_source",
    roboport = "energy_source",
    ["rocket-silo"] = "energy_source",
    ["selector-combinator"] = "energy_source",
    ["spider-vehicle"] = "energy_source"
}

-- For which entities is their energy source forced to be electric?
categories.energy_sources_input_electric = {
    ["ammo-turret"] = true,
    -- CRITICAL TODO
}
-- For which entities is their energy source forced to be burner or void?

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

-- Equipment types that consume power from the grid
-- Note: battery-equipment is tertiary (stores power), treated as consumer
categories.equipment_power_consumers = {
    ["active-defense-equipment"] = true,
    ["battery-equipment"] = true,
    ["belt-immunity-equipment"] = true,
    ["energy-shield-equipment"] = true,
    ["inventory-bonus-equipment"] = true,  -- Optional power, but can consume
    ["movement-bonus-equipment"] = true,
    ["night-vision-equipment"] = true,
    ["roboport-equipment"] = true,
}

-- Equipment types that produce power into the grid (don't need external power)
categories.equipment_power_producers = {
    ["solar-panel-equipment"] = true,
    ["generator-equipment"] = true,
}

-- Note: Doesn't include thruster; that requires two fluids and so is treated specially
categories.fluid_required = {
    ["boiler"] = true,
    ["fusion-generator"] = true,
    ["fusion-reactor"] = true,
    ["generator"] = true,
    ["fluid-turret"] = true,
}

-- The heating tower is a reactor prototype, so this is all we need
categories.heat_producers = {
    ["reactor"] = true
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
    ["spider-vehicle"] = {["movement_energy_consumption"] = "power"}
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

categories.rail = {
    ["curved-rail-a"] = true,
    ["elevated-curved-rail-a"] = true,
    ["curved-rail-b"] = true,
    ["elevated-curved-rail-b"] = true,
    ["half-diagonal-rail"] = true,
    ["elevated-half-diagonal-rail"] = true,
    ["legacy-curved-rail"] = true,
    ["legacy-straight-rail"] = true,
    ["rail-ramp"] = true,
    ["straight-rail"] = true,
    ["elevated-straight-rail"] = true,
}

categories.rolling_stock = {
    ["artillery-wagon"] = true,
    ["cargo-wagon"] = true,
    ["infinity-cargo-wagon"] = true,
    ["fluid-wagon"] = true,
    ["locomotive"] = true,
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

-- Vehicle types that can have equipment grids (which should be all of them; but including as a separate category in case I learn otherwise)
categories.vehicles_with_grids = {
    ["car"] = true,
    ["spider-vehicle"] = true,
    ["locomotive"] = true,
    ["cargo-wagon"] = true,
    ["fluid-wagon"] = true,
    ["artillery-wagon"] = true,
}

-- It's easier to write down which entities *don't* have health
categories.without_health = {
    ["arrow"] = true,
    ["artillery-flare"] = true,
    ["artillery-projectile"] = true,
    ["beam"] = true,
    ["character-corpse"] = true,
    ["cliff"] = true,
    ["corpse"] = true,
    ["rail-remnants"] = true,
    ["deconstructible-tile-proxy"] = true,
    ["entity-ghost"] = true,
    ["explosion"] = true,
    ["fire"] = true,
    ["stream"] = true,
    ["highlight-box"] = true,
    ["item-entity"] = true,
    ["item-request-proxy"] = true,
    ["lightning"] = true,
    ["particle-source"] = true,
    ["projectile"] = true,
    ["resource"] = true,
    ["rocket-silo-rocket"] = true,
    ["rocket-silo-rocket-shadow"] = true,
    ["smoke-with-trigger"] = true,
    ["speech-bubble"] = true,
    ["sticker"] = true,
    ["tile-ghost"] = true,
}

return categories


local export = {}

local any_type = function ()
    return { electric = true, burner = true, heat = true, fluid = true, void = true }
end

local not_heat_type = function ()
    return { electric = true, burner = true, fluid = true, void = true }
end

local electric_type = function ()
    return { electric = true }
end

local electric_void_type = function ()
    return { electric = true, void = true }
end

local not_burner_type = function ()
    return { electric = true, heat = true, fluid = true, void = true }
end

local burner_type = function ()
    return { burner = true }
end

local burner_void_type = function ()
    return { burner = true, void = true }
end

local energy_source_properties = {
    { prototype_type = "accumulator", property = "energy_source", types = electric_type(), optional = false, output = true },
    { prototype_type = "active-defense-equipment", property = "energy_source", types = electric_type(), optional = false, output = false },
    { prototype_type = "agricultural-tower", property = "energy_source", types = any_type(), optional = false, output = false },
    { prototype_type = "ammo-turret", property = "energy_source", types = electric_type(), optional = true, output = false },
    { prototype_type = "arithmetic-combinator", property = "energy_source", types = electric_void_type(), optional = false, output = false },
    { prototype_type = "assembling-machine", property = "energy_source", types = any_type(), optional = false, output = false },
    { prototype_type = "asteroid-collector", property = "energy_source", types = electric_void_type(), optional = false, output = false },
    { prototype_type = "battery-equipment", property = "energy_source", types = electric_type(), optional = false, output = true },
    { prototype_type = "beacon", property = "energy_source", types = electric_void_type(), optional = false, output = false },
    { prototype_type = "belt-immunity-equipment", property = "energy_source", types = electric_type(), optional = false, output = false },
    { prototype_type = "boiler", property = "energy_source", types = any_type(), optional = false, output = false },
    { prototype_type = "burner-generator", property = "burner", types = burner_type(), optional = false, output = false },
    { prototype_type = "burner-generator", property = "energy_source", types = electric_type(), optional = false, output = true },
    { prototype_type = "car", property = "energy_source", types = burner_void_type(), optional = false, output = false },
    { prototype_type = "decider-combinator", property = "energy_source", types = electric_void_type(), optional = false, output = false },
    { prototype_type = "electric-energy-interface", property = "energy_source", types = electric_type(), optional = false, output = false },
    { prototype_type = "electric-turret", property = "energy_source", types = electric_void_type(), optional = false, output = false },
    { prototype_type = "energy-shield-equipment", property = "energy_source", types = electric_type(), optional = false, output = false },
    { prototype_type = "furnace", property = "energy_source", types = any_type(), optional = false, output = false },
    { prototype_type = "fusion-generator", property = "energy_source", types = electric_type(), optional = false, output = true },
    { prototype_type = "fusion-reactor", property = "burner", types = burner_type(), optional = false, output = false },
    { prototype_type = "fusion-reactor", property = "energy_source", types = electric_type(), optional = false, output = false },
    { prototype_type = "generator", property = "energy_source", types = electric_type(), optional = false, output = true },
    { prototype_type = "generator-equipment", property = "burner", types = burner_type(), optional = true, output = false },
    { prototype_type = "generator-equipment", property = "energy_source", types = electric_type(), optional = false, output = true },
    { prototype_type = "inserter", property = "energy_source", types = any_type(), optional = false, output = false },
    { prototype_type = "inventory-bonus-equipment", property = "energy_source", types = electric_type(), optional = true, output = false },
    { prototype_type = "lab", property = "energy_source", types = any_type(), optional = false, output = false },
    { prototype_type = "lamp", property = "energy_source", types = electric_void_type(), optional = false, output = false },
    { prototype_type = "lightning-attractor", property = "energy_source", types = electric_type(), optional = true, output = true },
    { prototype_type = "locomotive", property = "energy_source", types = burner_void_type(), optional = false, output = false },
    { prototype_type = "loader", property = "energy_source", types = not_burner_type(), optional = true, output = false },
    { prototype_type = "loader-1x1", property = "energy_source", types = not_burner_type(), optional = true, output = false },
    { prototype_type = "mining-drill", property = "energy_source", types = any_type(), optional = false, output = false },
    { prototype_type = "movement-bonus-equipment", property = "energy_source", types = electric_type(), optional = false, output = false },
    { prototype_type = "night-vision-equipment", property = "energy_source", types = electric_type(), optional = false, output = false },
    { prototype_type = "offshore-pump", property = "energy_source", types = any_type(), optional = false, output = false },
    { prototype_type = "programmable-speaker", property = "energy_source", types = electric_void_type(), optional = false, output = false },
    { prototype_type = "radar", property = "energy_source", types = any_type(), optional = false, output = false },
    { prototype_type = "reactor", property = "energy_source", types = not_heat_type(), optional = false, output = false },
    { prototype_type = "roboport", property = "energy_source", types = electric_void_type(), optional = false, output = false },
    { prototype_type = "roboport-equipment", property = "burner", types = burner_type(), optional = true, output = false },
    { prototype_type = "roboport-equipment", property = "energy_source", types = electric_type(), optional = false, output = false },
    { prototype_type = "rocket-silo", property = "energy_source", types = any_type(), optional = false, output = false },
    { prototype_type = "selector-combinator", property = "energy_source", types = electric_void_type(), optional = false, output = false },
    { prototype_type = "solar-panel", property = "energy_source", types = electric_type(), optional = false, output = true },
    { prototype_type = "solar-panel-equipment", property = "energy_source", types = electric_type(), optional = false, output = true },
    { prototype_type = "spider-vehicle", property = "energy_source", types = burner_void_type(), optional = false, output = false },
}

export.iter_burner_properties = function ()
    local i = 0
    return function ()
        i = i + 1
        while energy_source_properties[i] do
            local energy_source_info = energy_source_properties[i]
            if energy_source_info.types.burner then
                return energy_source_info.prototype_type, energy_source_info.property
            end
            i = i + 1
        end
    end
end

return export
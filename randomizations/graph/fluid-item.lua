-- Attempt to randomize fluids to items and vice versa in a future version

local function okay_item_to_switch_with_fluid(item)
    --[[local disallowed_types = {
        ["tool"] = true
    }]]
    
    return true
end

local function okay_fluid_to_switch_with_item(fluid)
    -- Check that it's not the required fluid for any entities
    for entity_class, _ in pairs(defines.prototypes.entity) do
        if data.raw[entity_class] ~= nil then
            for _, entity in pairs(data.raw[entity_class]) do
                if entity.minable and entity.minable.required_fluid == fluid.name then
                    return false
                end
            end
        end
    end

    -- Check if there's a barrel for this
    if data.raw.item[fluid.name .. "-" .. "barrel"] ~= nil then
        return true
    end

    return false
end

-- Kept properties:
-- Build results
-- Plant results
-- Ability to repair things
-- Ammo-ness
-- Burn results & fuel properties

local function switch_item_to_fluid(outgoing_item, incoming_fluid)

end

-- Need to check barrel reachability when switching things
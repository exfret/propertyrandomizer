local locale = require("lib/locale")
local common = require("randomizations/graph/entity/common")

local capsule = {}

local valid_capsule_types = {
    ["capsule"] = true,
    ["item"] = true,
    ["ammo"] = true,
    ["gun"] = true,
    ["module"] = true,
    ["space-platform-starter-pack"] = true,
    ["tool"] = true,
    ["armor"] = true,
    ["repair-tool"] = true,
}

-- TODO: Figure out what's going on with slowdown capsule
local blacklisted_capsule_names = {
    ["slowdown-capsule"] = true,
}

local function is_valid_capsule(item)
    if item.hidden then
        return false
    end

    if not valid_capsule_types[item.type] then
        return false
    end

    if item.plant_result ~= nil then
        return false
    end
    if item.place_as_tile ~= nil then
        return false
    end
    if item.place_result ~= nil then
        return false
    end

    if item.flags ~= nil then
        for _, flag in pairs(item.flags) do
            if flag == "not-stackable" or flag == "spawnable" then
                return false
            end
        end
    end
    if item.equipment_grid ~= nil then
        return false
    end

    if item.parameter then
        return false
    end

    return true
end

capsule.claim = function(entity)
    if entity.type ~= "capsule_trigger" then
        return false
    end

    if blacklisted_capsule_names[entity.name] then
        return false
    end

    if not is_valid_capsule(data.raw.capsule[entity.name]) then
        return false
    end

    return true
end

capsule.validate = function(slot, trav)
    -- The game freezes if we attempt to put a grid-y thing somewhere off grid, so don't allow those
    if common.grid_like_entity_classes[trav.type] then
        return false
    end

    return true
end

capsule.reflect = function(slot, trav)
    local capsule = data.raw.capsule[slot.name]

    -- Check for dummy trav
    if trav.type == "dummy" then
        -- Lose capsule powers
        capsule.type = "item"
        capsule.capsule_action = nil
        capsule.radius_color = nil
        -- Apply gray tint
        if capsule.icons ~= nil then
            for _, layer in pair(capsule.icons) do
                layer.tint = {r = 0.5, g = 0.5, b = 0.5, a = 1}
            end
        else
            capsule.icons = {
                {
                    icon = capsule.icon,
                    icon_size = capsule.icon_size or 64,
                    tint = {r = 0.5, g = 0.5, b = 0.5, a = 1},
                }
            }
            capsule.icon = nil
        end
        -- Adjust name
        capsule.localised_name = {"", locale.find_localised_name(capsule), " (Vestige)"}
        data.raw.capsule[capsule.name] = nil
        data.raw.item[capsule.name] = capsule

        return true
    end
    
    -- Check for other trigger entities
    -- TODO: No wait, we should be just changing the projectile's action, that way capsules can still have distinct mix n' match flavors; I'll do this later
    if trav.type == "capsule_trigger" then
        local trav_capsule = old_data_raw.capsule[trav.name]

        data.raw.projectile[slot.projectile.name].action = table.deepcopy(old_data_raw.projectile[trav.projectile.name].action)

        return true
    end

    -- Everything else: just make the capsule action's projectiles create the entity
    -- Slots are old_data_raw, so we need to get the new data.raw version
    data.raw.projectile[slot.projectile.name].action = {
        type = "direct",
        action_delivery = {
            type = "instant",
            target_effects = {
                type = "create-entity",
                entity_name = trav.name,
                find_non_colliding_position = true,
                non_colliding_search_radius = 3,
            }
        }
    }
    -- Change icon to be a smaller version of the capsule in top left over the entity icon
    -- TODO: Really, they should be old_data_raw icons
    local new_icons = table.deepcopy(capsule.icons) or {
        {
            icon = capsule.icon,
            icon_size = capsule.icon_size or 64,
        }
    }
    if trav.icons ~= nil then
        for _, icon_data in pairs(trav.icons) do
            local new_icon_data = table.deepcopy(icon_data)
            new_icon_data.scale = (new_icon_data.scale or 1 / 2) / 1.5
            new_icon_data.shift = {-0.2 * (new_icon_data.icon_size or 64), -0.2 * (new_icon_data.icon_size or 64)}
            table.insert(new_icons, table.deepcopy(new_icon_data))
        end
    elseif trav.icon ~= nil then
        table.insert(new_icons, {
            icon = trav.icon,
            icon_size = trav.icon_size or 64,
            scale = 1 / 3,
            shift = {-0.2 * (trav.icon_size or 64), -0.2 * (trav.icon_size or 64)},
        })
    end
    capsule.icons = new_icons
    capsule.localised_name = {"", locale.find_localised_name(trav), " (Throwable)"}

    if common.entity_to_place_item[trav.name] ~= nil then
        data.raw[trav.type][trav.name].minable.result = capsule.name
    end
end

return capsule
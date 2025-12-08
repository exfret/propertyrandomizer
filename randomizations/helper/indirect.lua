local trigger_utils = require("lib/trigger")

local export = {}

local parent_types = {
    ["active-defense-equipment"] = true,
    ["ammo"] = true,
    ["capsule"] = true,
    ["combat-robot"] = true,
    ["electric-turret"] = true,
    ["fluid-turret"] = true,
    ["unit"] = true,
}

local enemy_types = {
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

---Iterates over all entities that have parents that can create them.
---Make changes to entity or structs, and add descriptions to parents.
---@param child_type string
---@param func fun(entity:table, parents:table, structs:table, is_enemy:boolean)
export.iterate_child_prototypes = function (child_type, func)
    local prototypes = trigger_utils.get_creator_table(child_type)

    for prototype_name, parents in pairs(prototypes) do
        local affected_parents = {}

        local friendly = 0
        local enemy = 0

        for _, parent in pairs(parents) do
            if parent_types[parent.type] ~= nil then
                affected_parents[#affected_parents+1] = parent
                if enemy_types[parent.type] then
                    enemy = enemy + 1
                else
                    friendly = friendly + 1
                end
            end
        end

        if #affected_parents > 0 then
            local entity = data.raw[child_type][prototype_name]
            local structs = {}
            local gather_func = trigger_utils.type_to_gather_struct_func[child_type]
            gather_func(structs, entity, true)
            func(entity, affected_parents, structs, enemy > friendly)
        end
    end
end

return export
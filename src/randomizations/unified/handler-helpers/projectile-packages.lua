-- A package owns its complete delivery and payload; the source retains its attack rate and range.
-- Package acquisition is distinct from building acquisition, so automatic damage needn't imply automatic construction.
local dutils = require("src/prototypes/data-utils")
local gutils = require("src/lib/graph/graph-utils")
local acquisition = require("src/logic/builders/acquisition")
local customization = require("src/config/graph-customization")
local ctx = require("src/logic/contexts/contexts")
local categories = require("src/prototypes/categories")
local common = require("src/randomizations/unified/handler-helpers/entity")
local locale = require("src/localisation/locale")

local impact = require("src/prototypes/entities/projectile-impact")

local packages = {}
local key = gutils.key

-- Only one unconditional delivery per use is admitted. This also bounds a replacement building to one per use.
-- Stream packages can travel intact, but aren't flattened into placement or turned into building emitters.
packages.delivery = function(action)
    if action == nil then return nil end
    local found
    for _, entry in pairs(action.type and {action} or action) do
        if entry.type ~= "direct" or (entry.repeat_count or 1) ~= 1 or (entry.probability or 1) ~= 1 then return nil end
        local sent = entry.action_delivery
        for _, delivery in pairs(sent and (sent.type and {sent} or sent) or {}) do
            if delivery.type == "projectile" or delivery.type == "stream" then
                if found ~= nil then return nil end
                found = delivery
            elseif delivery.type ~= "instant" then
                return nil
            end
        end
    end
    return found
end

-- Copies the entire referenced delivery family, reserving names before recursion (shared children and cycles are safe).
packages.copy_action = function(action, lookup, prefix)
    local copies, names = {}, {}
    local walk
    local function copy(name)
        if names[name] ~= nil then return names[name] end
        local prototype = lookup(name)
        if prototype == nil then error("Missing projectile package entity " .. name) end
        local clone = table.deepcopy(prototype)
        clone.name = prefix .. "-" .. name
        names[name] = clone.name
        table.insert(copies, clone)
        walk(clone)
        return clone.name
    end
    walk = function(value)
        for field, child in pairs(value) do
            if type(child) == "table" then
                walk(child)
            elseif type(child) == "string" and (field == "projectile" or field == "stream" or field == "beam") then
                value[field] = copy(child)
            end
        end
    end
    local result = table.deepcopy(action)
    walk(result)
    return result, copies
end

local function action_of(prototype, is_entity)
    local ammo
    if is_entity then
        ammo = prototype.attack_parameters and prototype.attack_parameters.ammo_type
    elseif prototype.type == "capsule" then
        local use = prototype.capsule_action
        if use == nil or use.type ~= "throw" then return nil end
        ammo = use.attack_parameters and use.attack_parameters.ammo_type
    elseif prototype.type == "ammo" then
        ammo = prototype.ammo_type
    end
    -- Source-specific ammo variants need independent source positions, rather than picking an arbitrary variant.
    return ammo and ammo.action, ammo
end

local function current_entity(name)
    return dutils.get_prot("entity", name)
end

-- Existing entity-producing triggers also need one creation, including the outer launch and impact multiplicity.
packages.single_creation = function(holder, made_name)
    local action = action_of(holder, false)
    local delivery = packages.delivery(action)
    if delivery == nil or delivery.type ~= "projectile" then return false end
    local root = current_entity(delivery.projectile)
    if root == nil or (root.piercing_damage or 0) ~= 0 then return false end
    if made_name == nil then return true end
    if root.final_action ~= nil then return false end
    local count = 0
    local function inspect(value)
        if (value.repeat_count or 1) ~= 1 or (value.probability or 1) ~= 1 then return false end
        if value.type == "area" or value.type == "projectile" or value.type == "stream" then return false end
        if value.type == "create-entity" and value.entity_name == made_name then
            if value.offsets ~= nil and #value.offsets ~= 1 then return false end
            count = count + 1
        end
        for _, child in pairs(value) do
            if type(child) == "table" and not inspect(child) then return false end
        end
        return true
    end
    return root.action ~= nil and inspect(root.action) and count == 1
end

local function starting_entity(name)
    for class, _ in pairs(defines.prototypes.entity) do
        local prototype = (unified_starting_data_raw[class] or {})[name]
        if prototype ~= nil then return prototype end
    end
end

packages.prepare = function(graph, keep)
    local records = {}
    -- Counter scores belong to a specific weapon/ammo combination; pin their ammo's package until those scores can be rematched.
    local scored = {}
    for _, node in pairs(graph.nodes) do
        for _, prerequisite in pairs(node.counter_prerequisites or {}) do scored[prerequisite] = true end
    end
    local function add(prototype, is_entity)
        if prototype.hidden or prototype.parameter or not customization.selected("entity", {
            type = is_entity and "entity" or "item",
            name = prototype.name,
        }) then return end
        local action = action_of(prototype, is_entity)
        local delivery = packages.delivery(action)
        if delivery == nil then return end
        local root = dutils.get_prot("entity", delivery.projectile or delivery.stream)
        if root == nil then return end
        -- Creation of living entities already has acquisition heads. Don't split one use into independently rewritten slots.
        local living = false
        local seen = {}
        local function inspect(value)
            if seen[value] then return end
            seen[value] = true
            for field, child in pairs(value) do
                if type(child) == "table" then
                    inspect(child)
                elseif type(child) == "string" and (field == "entity_name" or field == "projectile" or field == "stream" or field == "beam") then
                    local entity = dutils.get_prot("entity", child)
                    if entity ~= nil then
                        if categories.without_health[entity.type] == nil then living = true else inspect(entity) end
                    end
                end
            end
        end
        inspect(action)
        if living then return end
        local id = (is_entity and "entity-" or "item-") .. prototype.name
        local kind = prototype.type == "capsule" and "capsule" or "ammo"
        local source = key("item-" .. kind, prototype.name)
        local node
        if not is_entity then
            if graph.nodes[source] == nil then return end
            node = gutils.add_node(graph, "projectile-package", id, {op = "OR"})
            local edge = gutils.add_edge(graph, source, key(node), acquisition.tag(kind, {
                projectile_package = id,
                ours = true,
                abilities = kind == "capsule" and ctx.LOSES_AUTOMATABILITY or nil,
                amount = 1,
            }))
            keep(gutils.ekey(edge))
        end
        local record = {
            id = id,
            owner = prototype.name,
            is_entity = is_entity,
            kind = kind,
            action = table.deepcopy(action),
            look = table.deepcopy(prototype),
            locked = scored[key("item", prototype.name)] == true and not is_entity,
            building = delivery.type == "projectile" and (root.piercing_damage or 0) == 0,
        }
        if delivery.type == "projectile" and (root.piercing_damage or 0) == 0 then
            record.impact = common.capsule_impact_action({
                capsule_action = {
                    type = "throw",
                    attack_parameters = {ammo_type = {action = action}},
                },
            }, starting_entity)
        end
        if not impact.at_position(record.impact) then record.impact = nil end
        records[id] = record
        -- Damage follows the package, not its former ammo item. Preserve the original edge's abilities.
        local move = {}
        for edge_key, outgoing in pairs(graph.edges) do
            if node ~= nil and outgoing.start == source and graph.nodes[outgoing.stop].type == "damage-type" then table.insert(move, edge_key) end
        end
        for _, edge_key in pairs(move) do
            local outgoing = table.deepcopy(graph.edges[edge_key])
            gutils.remove_edge(graph, edge_key)
            local stop = outgoing.stop
            outgoing.start, outgoing.stop = nil, nil
            -- Manual firing belongs to the capsule slot, not to a payload moved into automatic ammunition.
            if kind == "capsule" then outgoing.abilities = nil end
            gutils.add_edge(graph, key(node), stop, outgoing)
        end
    end
    for _, prototype in pairs(dutils.get_all_prots("item")) do add(prototype, false) end
    if config.entity_biters then
        for _, prototype in pairs(dutils.get_all_prots("entity")) do
            if prototype.autoplace ~= nil and prototype.autoplace.force == "enemy" then add(prototype, true) end
        end
    end
    return records
end

-- Freeze current launch effects before any slots are rewritten. Earlier military edits can change inline effects as well as referenced prototypes.
packages.refresh = function(records)
    for _, record in pairs(records) do
        local holder = dutils.get_prot(record.is_entity and "entity" or "item", record.owner)
        local action = action_of(holder, record.is_entity)
        record.action = table.deepcopy(action)
    end
end

packages.clear = function(destination)
    local holder = dutils.get_prot(destination.is_entity and "entity" or "item", destination.owner)
    local _, ammo = action_of(holder, destination.is_entity)
    ammo.action = nil
    holder.localised_description = {
        "",
        {"propertyrandomizer-entity.empty-package"},
        "\n",
        holder.localised_description or "",
    }
end

packages.install = function(destination, donor, prefix)
    local holder = dutils.get_prot(destination.is_entity and "entity" or "item", destination.owner)
    local _, ammo = action_of(holder, destination.is_entity)
    local action, copies = packages.copy_action(donor.action, current_entity, prefix)
    ammo.action = action
    if #copies > 0 then data:extend(copies) end
    holder.localised_description = {
        "",
        {
            "propertyrandomizer-entity.package-effect",
            locale.find_localised_name(donor.look),
        },
        "\n",
        holder.localised_description or "",
    }
end

packages.replace_with_building = function(destination, entity_name, prefix)
    local holder = dutils.get_prot(destination.is_entity and "entity" or "item", destination.owner)
    local _, ammo = action_of(holder, destination.is_entity)
    local effect = {
        type = "create-entity",
        entity_name = entity_name,
        show_in_tooltip = true,
    }
    common.create_as_building(effect, entity_name)
    local action, copies = common.replace_thrown_effect(table.deepcopy(destination.action), effect, function(name) return prefix .. "-" .. name end)
    ammo.action = action
    if #copies > 0 then data:extend(copies) end
    holder.localised_description = {
        "propertyrandomizer-entity.makes",
        locale.find_localised_name(dutils.get_prot("entity", entity_name)),
    }
end

packages.place = function(item_name, record, was_vestige)
    assert(record.impact ~= nil, "Cannot flatten this projectile package")
    local name = "propertyrandomizer-package-impact-" .. record.id
    local impact_action = common.capsule_impact_action({
        capsule_action = {
            type = "throw",
            attack_parameters = {ammo_type = {action = record.action}},
        },
    }, current_entity)
    assert(impact.at_position(impact_action), "Placement impact requires a hit target")
    local action, copies = packages.copy_action(impact_action, current_entity, name)
    table.insert(copies, {
        type = "explosion",
        name = name,
        localised_name = {
            "propertyrandomizer-entity.set-off-name",
            locale.find_localised_name(record.look),
        },
        hidden_in_factoriopedia = true,
        flags = {
            "placeable-player",
            "not-on-map",
        },
        animations = util.empty_animation(1),
        collision_box = {
            {
                -0.4,
                -0.4,
            },
            {
                0.4,
                0.4,
            },
        },
        selection_box = {
            {
                -0.5,
                -0.5,
            },
            {
                0.5,
                0.5,
            },
        },
        created_effect = action,
    })
    common.set_icon_layers(copies[#copies], "", common.icon_layers(record.look, ""))
    data:extend(copies)
    local item = dutils.get_prot("item", item_name)
    table.insert(changes, {
        tbl = item,
        prop = "place_result",
        new_val = name,
    })
    if was_vestige then
        item.localised_name = {
            "propertyrandomizer-entity.placed-effect-name",
            locale.find_localised_name(record.look),
        }
    else
        item.localised_name = table.deepcopy(locale.find_localised_name(item))
    end
    item.localised_description = {
        "propertyrandomizer-entity.package-effect",
        locale.find_localised_name(record.look),
    }
    for _, prefix in pairs(common.item_icon_prefixes) do
        local icon = common.icon_layers(record.look, prefix)
        if not was_vestige then
            local original = common.icon_layers(item, prefix)
            local badge = common.icon_layers(record.look, "")
            icon = original ~= nil and badge ~= nil and common.with_icon_badge(original, badge) or original
        end
        common.set_icon_layers(item, prefix, icon)
    end
    if was_vestige then item.pictures = nil end
    log("Entity randomization: placing " .. item_name .. " directly activates projectile package " .. record.id)
end

return packages

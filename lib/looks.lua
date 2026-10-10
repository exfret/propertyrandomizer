-- How things look to the player when the randomizer makes them: a copy's Factoriopedia page, and a resource that item randomization makes mine another item
-- Nothing here requires another module, so plain-Lua tests of the modules using it load it as it is (lib/test-looks.lua)

local looks = {}

-- Text matched as written by a pattern (names have hyphens, which patterns read as quantifiers), and as a gsub replacement
local function pattern_text(text)
    return (string.gsub(text, "%p", "%%%0"))
end
local function replacement_text(text)
    return (string.gsub(text, "%%", "%%%%"))
end

-- A blueprint string (a version character, then the blueprint's JSON deflated and base64 encoded) with every entity or item the original named named the copy, and how many it renamed
-- LuaHelpers decodes and encodes them, in every stage (classes/LuaHelpers.html); nil if it can't
local function retarget_blueprint(blueprint, original_name, copy_name)
    if helpers == nil or helpers.decode_string == nil or helpers.encode_string == nil then
        return nil
    end
    local is_decoded, json = pcall(helpers.decode_string, string.sub(blueprint, 2))
    if not is_decoded or type(json) ~= "string" then
        return nil
    end
    local num
    json, num = string.gsub(json, "(\"name\"%s*:%s*\")" .. pattern_text(original_name) .. "\"", "%1" .. replacement_text(copy_name) .. "\"")
    if num == 0 then
        return blueprint, 0
    end
    local is_encoded, encoded = pcall(helpers.encode_string, json)
    if not is_encoded or type(encoded) ~= "string" then
        return nil
    end
    return string.sub(blueprint, 1, 1) .. encoded, num
end

-- A copy of a prototype under a name of its own keeps the original's Factoriopedia simulation (PrototypeBase::factoriopedia_simulation), a script that makes what it shows by name, so the copy's page shows the original
-- (The game's ore pages run make_resource from base/prototypes/factoriopedia-util.lua: create_entity{name = "<resource>", ...}; deposit clones and planet copies showed their originals, 2026-10-09)
-- Makes the script make the copy instead: the entities it creates by the original's name, the items it inserts by it when the copy is an item (like armor put on a character), and what the blueprints it builds name it
-- A copy whose simulation would still only show the original (through a script file, SimulationDefinition::init_file or update_file, a blueprint that can't be read, or other mentions of its name) shows none
looks.retarget_simulation = function(copy, original_name)
    local simulation = copy.factoriopedia_simulation
    if type(simulation) ~= "table" then
        return
    end
    if simulation.init_file ~= nil or simulation.update_file ~= nil then
        copy.factoriopedia_simulation = nil
        return
    end
    local name_pattern = pattern_text(original_name)
    local copy_name = replacement_text(copy.name)
    local calls = {
        "create_entity",
    }
    if defines.prototypes.item[copy.type] ~= nil then
        table.insert(calls, "insert")
    end
    local num_retargeted = 0
    local may_show_original = false
    for _, field in pairs({
        "init",
        "update",
    }) do
        local script = simulation[field]
        if type(script) == "string" then
            for _, quote in pairs({
                "\"",
                "'",
            }) do
                for _, call in pairs(calls) do
                    local num
                    script, num = string.gsub(script, "(" .. call .. "%s*%(?%s*{%s*name%s*=%s*" .. quote .. ")" .. name_pattern .. quote, "%1" .. copy_name .. quote)
                    num_retargeted = num_retargeted + num
                end
                if string.find(script, quote .. original_name .. quote, 1, true) ~= nil then
                    may_show_original = true
                end
                script = string.gsub(script, "(create_entities_from_blueprint_string%s*%(?%s*{%s*string%s*=%s*" .. quote .. ")([^" .. quote .. "]+)" .. quote, function(prefix, blueprint)
                    local retargeted, num = retarget_blueprint(blueprint, original_name, copy.name)
                    if retargeted == nil then
                        may_show_original = true
                        return nil
                    end
                    num_retargeted = num_retargeted + num
                    return prefix .. retargeted .. quote
                end)
            end
            simulation[field] = script
        end
    end
    if num_retargeted == 0 and may_show_original then
        copy.factoriopedia_simulation = nil
    end
end

-- A prototype's first icon layer, as filename and size
looks.primary_icon = function(prot)
    if prot.icon ~= nil then
        return prot.icon, prot.icon_size or 64
    end

    if prot.icons ~= nil and prot.icons[1] ~= nil then
        local icon = prot.icons[1]
        return icon.icon, icon.icon_size or prot.icon_size or 64
    end

    error("Prototype has no usable icon: " .. tostring(prot.name))
end

-- A planet's icon as a badge on a recipe made for that planet (randomizations/planetary/scaffolds.lua), or nil if there's no icon
-- Half size, in the top right corner, where a recipe's number badge goes too (lib/dupe.lua); it's always added after any number badge, so where they meet the planet is drawn over it (user, 2026-10-10: the planet takes priority)
looks.planet_badge = function(planet)
    if planet == nil then
        return nil
    end
    local badge
    if planet.icons ~= nil and planet.icons[1] ~= nil then
        badge = table.deepcopy(planet.icons[1])
    elseif planet.icon ~= nil then
        badge = {
            icon = planet.icon,
            icon_size = planet.icon_size,
        }
    else
        return nil
    end
    -- A recipe icon is 32 units across at full size (types/IconData.html), so this is half size, centered in the top right quarter
    badge.scale = 16 / (badge.icon_size or 64)
    badge.shift = {
        8,
        -8,
    }
    return badge
end

-- A resource item randomization makes mine another item looks like it: its patches show a few of the item's icon (ResourceEntityPrototype::stages, one stage), and it has the item's icon (EntityPrototype::icons, what Factoriopedia and tooltips show)
-- Both item randomizations name the resource after the item too (randomizations/graph/unified/handlers/item.lua and randomizations/graph/item.lua); the scrap mining boilers had boilers on its patches but scrap's icon (2026-10-09)
looks.like_item = function(resource, item)
    if item.icons ~= nil then
        resource.icons = table.deepcopy(item.icons)
        resource.icon = nil
    else
        resource.icons = nil
        resource.icon = item.icon
    end
    resource.icon_size = item.icon_size
    local icon_filename, icon_size = looks.primary_icon(item)
    resource.stages = {
        -- Note: This is technically botched with icons, TODO: Fix
        sheets = {
            {
                variation_count = 1,
                filename = icon_filename,
                size = icon_size,
                scale = 0.35,
                shift = {0.2, 0.6},
            },
            {
                variation_count = 1,
                filename = icon_filename,
                size = icon_size,
                scale = 0.25,
                shift = {-0.5, 0.2},
            },
            {
                variation_count = 1,
                filename = icon_filename,
                size = icon_size,
                scale = 0.45,
                shift = {0, 0},
            },
            {
                variation_count = 1,
                filename = icon_filename,
                size = icon_size,
                scale = 0.4,
                shift = {-0.2, -0.6},
            },
        },
    }
    resource.stage_counts = {resource.stage_counts[1]}
    resource.stages_effect = nil
end

return looks

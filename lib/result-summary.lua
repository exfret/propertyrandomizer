-- What the randomization did, in the log: every line starts with RESULT and says what differs in the finished game from the game before randomization
-- Recipes come first, each with what crafts it and what unlocks it, then technologies, then other prototypes by the properties that decide how things are gotten (PROPERTIES)
-- Values are compared as they're shown, so numerical randomization only shows up where it changes something shown, like an ingredient's amount or a research count
-- Things are listed by prototype name, with the name they show in game in quotes when it's their own (an item placing another entity shows that entity's name, for one)
-- Shown names are what the data stage has: literal text stays, and a locale key like item-name.iron-plate becomes iron-plate, so a recipe renamed to "Cook up Long-handed inserter" shows as "Cook up long-handed-inserter"

local categories = require("helper-tables/categories")
local crafter_slots = require("lib/crafter-slots")
local dutils = require("lib/data-utils")
local furnace_selection = require("lib/furnace-selection")
local lutils = require("lib/logic/logic-utils")
local recycling_sources = require("lib/logic/recycling-sources")

local result_summary = {}

local PREFIX = "RESULT "

-- A number with at most two decimals and no trailing zeros
local function number_text(num)
    if type(num) ~= "number" then
        return tostring(num)
    end
    local text = string.format("%.2f", num)
    text = string.gsub(text, "%.?0+$", "")
    return text
end

-- A localised string as text, as far as the data stage can tell (see the top of this file)
result_summary.text_of = function(localised)
    if type(localised) ~= "table" then
        return tostring(localised)
    end
    local key = localised[1]
    local parts = {}
    for i = 2, #localised do
        table.insert(parts, result_summary.text_of(localised[i]))
    end
    if key == "" then
        return table.concat(parts)
    end
    -- The first of the alternatives that exists; the data stage can't tell which, so the first
    if key == "?" then
        return parts[1] or ""
    end
    local name = string.match(tostring(key), "^[%w-]+%-name%.(.+)$")
    if name ~= nil then
        return name
    end
    if #parts > 0 then
        return tostring(key) .. "(" .. table.concat(parts, ", ") .. ")"
    end
    return tostring(key)
end

-- Names sorted and joined, or nil for no list or an empty one
local function sorted_text(list)
    if list == nil or next(list) == nil then
        return nil
    end
    local names = {}
    for _, name in pairs(list) do
        table.insert(names, tostring(name))
    end
    table.sort(names)
    return table.concat(names, ", ")
end

-- An item or fluid prototype by type and name
local function material_prot(raw, material_type, name)
    if material_type == "fluid" then
        return (raw.fluid or {})[name]
    end
    for item_class, _ in pairs(defines.prototypes.item) do
        local item = (raw[item_class] or {})[name]
        if item ~= nil then
            return item
        end
    end
    return nil
end

-- The name a prototype shows in game, or nil if that's just its own name
-- A recipe without a name of its own shows its main product's (RecipePrototype::main_product)
local function shown_name(raw, prot)
    if prot.localised_name ~= nil then
        return result_summary.text_of(prot.localised_name)
    end
    if prot.type == "recipe" then
        local main_product = dutils.recipe_main_product(prot)
        if main_product ~= nil then
            local material = material_prot(raw, main_product.type, main_product.name)
            if material ~= nil and material.localised_name ~= nil then
                return result_summary.text_of(material.localised_name)
            end
            if main_product.name ~= prot.name then
                return main_product.name
            end
        end
    end
    return nil
end

-- A prototype's name, with the name it shows in quotes when that's its own
local function quoted_name(raw, prot, name)
    if prot ~= nil and prot.localised_name ~= nil then
        local shown = result_summary.text_of(prot.localised_name)
        if shown ~= name then
            return name .. " \"" .. shown .. "\""
        end
    end
    return name
end

-- An ingredient or product: amount, name and the name it shows, whether it's a fluid, and its chance (ProductPrototypeBase::independent_probability and shared_probability)
local function material_text(raw, material)
    local amount
    if material.amount ~= nil then
        amount = number_text(material.amount)
    elseif material.amount_min ~= nil or material.amount_max ~= nil then
        amount = number_text(material.amount_min or 0) .. "-" .. number_text(material.amount_max or 0)
    end
    local text = quoted_name(raw, material_prot(raw, material.type, material.name), material.name)
    if amount ~= nil then
        text = amount .. " " .. text
    end
    if material.type == "fluid" then
        text = text .. " (fluid)"
    end
    if material.independent_probability ~= nil and material.independent_probability < 1 then
        text = text .. " at " .. number_text(100 * material.independent_probability) .. "%"
    end
    if material.shared_probability ~= nil then
        text = text .. " at shared " .. number_text(material.shared_probability.min or 0) .. "-" .. number_text(material.shared_probability.max or 1)
    end
    return text
end

local function materials_text(raw, list)
    if list == nil or next(list) == nil then
        return "nothing"
    end
    local parts = {}
    for _, material in pairs(list) do
        table.insert(parts, material_text(raw, material))
    end
    return table.concat(parts, ", ")
end

-- The crafters that can craft a recipe: crafting machines and characters with one of its categories, the fluid boxes it needs (the logic's rule, lutils.is_compatible_rcat) and item slots for it (crafter_slots.fits_items)
result_summary.made_in = function(raw, recipe)
    local fluids = lutils.find_recipe_fluids(recipe)
    local rcat = {
        cats = furnace_selection.recipe_categories(recipe),
        input = fluids.input,
        output = fluids.output,
    }
    local crafters = {}
    local function add_crafters(class)
        for name, crafter in pairs(raw[class] or {}) do
            if crafter.crafting_categories ~= nil and lutils.is_compatible_rcat(crafter, rcat) and crafter_slots.fits_items(crafter, recipe) then
                table.insert(crafters, name)
            end
        end
    end
    for machine_class, _ in pairs(categories.crafting_machines) do
        add_crafters(machine_class)
    end
    add_crafters("character")
    table.sort(crafters)
    return crafters
end

-- Recipe name --> names of the technologies that unlock it
local function unlockers(raw)
    local unlocked_by = {}
    for tech_name, tech in pairs(raw.technology or {}) do
        for _, effect in pairs(tech.effects or {}) do
            if effect.type == "unlock-recipe" then
                unlocked_by[effect.recipe] = unlocked_by[effect.recipe] or {}
                table.insert(unlocked_by[effect.recipe], tech_name)
            end
        end
    end
    return unlocked_by
end

-- Fields are { label, value } in a fixed order, so two prototypes' fields compare by index; value is nil when a prototype doesn't have it
local function add_field(fields, label, value)
    table.insert(fields, {
        label = label,
        value = value,
    })
end

-- A recipe's shown fields, compared between the two games
local function recipe_fields(raw, recipe, unlocked_by)
    local enabled = recipe.enabled
    if enabled == nil then
        enabled = true
    end
    local unlock_text = "at start"
    if not enabled then
        local techs = {}
        for _, tech_name in pairs(unlocked_by[recipe.name] or {}) do
            table.insert(techs, quoted_name(raw, raw.technology[tech_name], tech_name))
        end
        unlock_text = sorted_text(techs) or "nothing"
    end
    local fields = {}
    add_field(fields, "shown as", shown_name(raw, recipe))
    add_field(fields, "categories", sorted_text(furnace_selection.recipe_categories(recipe)))
    add_field(fields, "ingredients", materials_text(raw, recipe.ingredients))
    add_field(fields, "products", materials_text(raw, recipe.results))
    add_field(fields, "unlocked by", unlock_text)
    return fields
end

-- A technology's research cost: its count (or formula), what one unit takes, or its trigger; nil without either
local function research_text(tech)
    local parts = {}
    if tech.unit ~= nil then
        local count = tech.unit.count_formula or number_text(tech.unit.count)
        local packs = {}
        for _, ing in pairs(tech.unit.ingredients or {}) do
            local name = ing.name or ing[1]
            local amount = ing.amount or ing[2] or 1
            if amount ~= 1 then
                name = number_text(amount) .. " " .. name
            end
            table.insert(packs, name)
        end
        table.insert(parts, count .. " x (" .. table.concat(packs, ", ") .. ")")
    end
    if tech.research_trigger ~= nil then
        local trigger = tech.research_trigger
        local target = trigger.item or trigger.entity or trigger.fluid or trigger.tile or trigger.space_location or trigger.recipe or ""
        if type(target) == "table" then
            target = target.name or ""
        end
        table.insert(parts, "trigger " .. tostring(trigger.type) .. " " .. tostring(target) .. (trigger.count ~= nil and (" x" .. number_text(trigger.count)) or ""))
    end
    if #parts == 0 then
        return nil
    end
    return table.concat(parts, "; ")
end

local function tech_fields(raw, tech)
    local unlocks = {}
    local other_effects = {}
    for _, effect in pairs(tech.effects or {}) do
        if effect.type == "unlock-recipe" then
            table.insert(unlocks, effect.recipe)
        else
            table.insert(other_effects, effect.type)
        end
    end
    local fields = {}
    add_field(fields, "shown as", shown_name(raw, tech))
    add_field(fields, "prerequisites", sorted_text(tech.prerequisites or {}))
    add_field(fields, "unlocks", sorted_text(unlocks))
    add_field(fields, "other effects", sorted_text(other_effects))
    add_field(fields, "research", research_text(tech))
    return fields
end

-- Other prototypes: properties that decide how things are gotten, each shown as text or nil when a prototype doesn't have it
-- A property naming one prototype, as its name (a name, or a table with one), or nil
local function name_text(value)
    if type(value) == "string" then
        return value
    end
    if type(value) == "table" and type(value.name) == "string" then
        return value.name
    end
    return nil
end

local function placeable_by_text(prot)
    local placeable_by = prot.placeable_by
    if placeable_by == nil then
        return nil
    end
    if placeable_by.item ~= nil then
        placeable_by = {
            placeable_by,
        }
    end
    local names = {}
    for _, entry in pairs(placeable_by) do
        table.insert(names, entry.item)
    end
    return sorted_text(names)
end

local function loot_text(prot)
    if prot.loot == nil then
        return nil
    end
    local parts = {}
    for _, loot in pairs(prot.loot) do
        local text = loot.item
        if loot.probability ~= nil and loot.probability < 1 then
            text = text .. " at " .. number_text(100 * loot.probability) .. "%"
        end
        table.insert(parts, text)
    end
    return sorted_text(parts)
end

local function mined_text(prot, raw)
    if prot.minable == nil then
        return nil
    end
    local text
    if prot.minable.results ~= nil then
        text = materials_text(raw, prot.minable.results)
    elseif prot.minable.result ~= nil then
        text = number_text(prot.minable.count or 1) .. " " .. prot.minable.result
    else
        text = "nothing"
    end
    if prot.minable.required_fluid ~= nil then
        text = text .. ", needs " .. number_text(prot.minable.fluid_amount or 0) .. " " .. prot.minable.required_fluid
    end
    return text
end

local function spoil_text(prot)
    if (prot.spoil_ticks or 0) <= 0 then
        return nil
    end
    local into = prot.spoil_result
    if into == nil then
        into = prot.spoil_to_trigger_result ~= nil and "a trigger" or "nothing"
    end
    return "into " .. into .. " after " .. number_text(prot.spoil_ticks / 3600) .. " min"
end

local function energy_text(prot)
    local source = prot.energy_source
    if source == nil then
        return nil
    end
    local parts = {
        tostring(source.type),
    }
    local fuel_categories = sorted_text(source.fuel_categories)
    if fuel_categories ~= nil then
        table.insert(parts, fuel_categories)
    end
    if source.fluid_box ~= nil and source.fluid_box.filter ~= nil then
        table.insert(parts, source.fluid_box.filter)
    end
    return table.concat(parts, " ")
end

local function filters_text(prot)
    local parts = {}
    local function add(label, box)
        if type(box) == "table" and box.filter ~= nil then
            table.insert(parts, label .. " " .. box.filter)
        end
    end
    add("fluid box", prot.fluid_box)
    add("output", prot.output_fluid_box)
    for ind, box in pairs(prot.fluid_boxes or {}) do
        add("fluid box " .. tostring(ind), box)
    end
    if #parts == 0 then
        return nil
    end
    return table.concat(parts, ", ")
end

local function conditions_text(conditions)
    if conditions == nil then
        return nil
    end
    local parts = {}
    for _, condition in pairs(conditions) do
        table.insert(parts, condition.property .. " " .. number_text(condition.min or 0) .. "-" .. (condition.max ~= nil and number_text(condition.max) or "any"))
    end
    return sorted_text(parts)
end

local function surface_text(prot)
    if prot.surface_properties == nil then
        return nil
    end
    local parts = {}
    for property, value in pairs(prot.surface_properties) do
        table.insert(parts, property .. " " .. number_text(value))
    end
    return sorted_text(parts)
end

local function autoplaced_text(prot)
    local settings = ((((prot.map_gen_settings or {}).autoplace_settings or {}).entity or {}).settings)
    if settings == nil then
        return nil
    end
    local names = {}
    for name, _ in pairs(settings) do
        table.insert(names, name)
    end
    return sorted_text(names)
end

local function route_text(prot)
    if prot.from == nil or prot.to == nil then
        return nil
    end
    return tostring(prot.from) .. " to " .. tostring(prot.to)
end

local PROPERTIES = {
    {
        label = "places",
        show = function(prot)
            return name_text(prot.place_result)
        end,
    },
    {
        label = "places tile",
        show = function(prot)
            return prot.place_as_tile ~= nil and name_text(prot.place_as_tile.result) or nil
        end,
    },
    {
        label = "plants",
        show = function(prot)
            return name_text(prot.plant_result)
        end,
    },
    {
        label = "spoils",
        show = spoil_text,
    },
    {
        label = "burns into",
        show = function(prot)
            return name_text(prot.burnt_result)
        end,
    },
    {
        label = "fuel category",
        show = function(prot)
            return name_text(prot.fuel_category)
        end,
    },
    {
        label = "mined into",
        show = mined_text,
    },
    {
        label = "loot",
        show = loot_text,
    },
    {
        label = "placeable by",
        show = placeable_by_text,
    },
    {
        label = "found in the wild",
        show = function(prot)
            return prot.autoplace ~= nil and "yes" or nil
        end,
    },
    {
        label = "crafts",
        show = function(prot)
            return sorted_text(prot.crafting_categories)
        end,
    },
    {
        label = "output slots",
        show = function(prot)
            return prot.result_inventory_size ~= nil and number_text(prot.result_inventory_size) or nil
        end,
    },
    {
        label = "mines",
        show = function(prot)
            return sorted_text(prot.resource_categories)
        end,
    },
    {
        label = "category",
        show = function(prot)
            return name_text(prot.category)
        end,
    },
    {
        label = "researches with",
        show = function(prot)
            return sorted_text(prot.inputs)
        end,
    },
    {
        label = "pumped fluid",
        show = function(prot)
            return name_text(prot.fluid)
        end,
    },
    {
        label = "energy source",
        show = energy_text,
    },
    {
        label = "fluid filters",
        show = filters_text,
    },
    {
        label = "surface conditions",
        show = function(prot)
            return conditions_text(prot.surface_conditions)
        end,
    },
    {
        label = "surface properties",
        show = surface_text,
    },
    {
        label = "autoplaces",
        show = autoplaced_text,
    },
    {
        label = "route",
        show = route_text,
    },
}

local function other_fields(raw, prot)
    local fields = {}
    for _, property in pairs(PROPERTIES) do
        add_field(fields, property.label, property.show(prot, raw))
    end
    return fields
end

-- The changed fields as "label: old -> new" (only the new value for a new prototype), or nil if nothing changed
local function changes_text(old_fields, new_fields)
    local parts = {}
    for ind, field in pairs(new_fields) do
        local new_value = field.value
        if old_fields == nil then
            if new_value ~= nil then
                table.insert(parts, field.label .. ": " .. new_value)
            end
        else
            local old_value = old_fields[ind].value
            if old_value ~= new_value then
                table.insert(parts, field.label .. ": " .. tostring(old_value or "none") .. " -> " .. tostring(new_value or "none"))
            end
        end
    end
    if #parts == 0 then
        return nil
    end
    return table.concat(parts, "; ")
end

local function sorted_names(tbl)
    local names = {}
    for name, _ in pairs(tbl or {}) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

-- Prototype names by type, to tell later which prototypes a step added (added_since)
result_summary.prototype_names = function(raw)
    local names = {}
    for class, prots in pairs(raw) do
        names[class] = {}
        for name, _ in pairs(prots) do
            names[class][name] = true
        end
    end
    return names
end

-- The prototypes in raw whose names weren't in names (from prototype_names), by type
result_summary.added_since = function(names, raw)
    local added = {}
    for class, prots in pairs(raw) do
        for name, _ in pairs(prots) do
            if names[class] == nil or names[class][name] == nil then
                added[class] = added[class] or {}
                added[class][name] = true
            end
        end
    end
    return added
end

-- Logs the summary of how raw differs from before_raw, the game before randomization
-- unlisted (optional) is prototypes that are only counted, as { prototypes = by type (like added_since gives), what = what they are }
result_summary.log = function(before_raw, raw, unlisted)
    raw = raw or data.raw
    local unlisted_prototypes = (unlisted or {}).prototypes or {}
    local num_unlisted = 0
    local function is_listed(class, name)
        if (unlisted_prototypes[class] or {})[name] ~= nil then
            num_unlisted = num_unlisted + 1
            return false
        end
        return true
    end
    log(PREFIX .. "What the randomization did: how the finished game differs from the game before randomization, compared as shown (numerical changes only show where they change something shown)")
    log(PREFIX .. "Names are prototype names, with the name something shows in game in quotes when it's its own; locale keys show as the prototype names they point at, not the English text")
    local unlocked_before = unlockers(before_raw)
    local unlocked_now = unlockers(raw)
    local num_recipes = 0
    local num_recycling = 0
    local num_uncraftable = 0
    for _, name in pairs(sorted_names(raw.recipe)) do
        local recipe = raw.recipe[name]
        local before = (before_raw.recipe or {})[name]
        -- Recycling recipes follow the recipes they recycle (lib/recycling.lua), so they'd repeat those
        if recycling_sources.named_after_ingredient(before_raw.recipe or {}, name) ~= nil then
            num_recycling = num_recycling + 1
        elseif is_listed("recipe", name) then
            local made_in = result_summary.made_in(raw, recipe)
            local lost_crafters = #made_in == 0 and (before == nil or #result_summary.made_in(before_raw, before) > 0)
            local changes = changes_text(before ~= nil and recipe_fields(before_raw, before, unlocked_before) or nil, recipe_fields(raw, recipe, unlocked_now))
            if changes ~= nil or lost_crafters then
                num_recipes = num_recipes + 1
                local made_in_text = #made_in > 0 and table.concat(made_in, ", ") or "NOTHING"
                if #made_in == 0 then
                    num_uncraftable = num_uncraftable + 1
                end
                log(PREFIX .. "recipe " .. name .. (before == nil and " (new)" or "") .. ": " .. (changes or "unchanged") .. "; made in: " .. made_in_text)
            end
        end
    end
    local num_techs = 0
    for _, name in pairs(sorted_names(raw.technology)) do
        local before = (before_raw.technology or {})[name]
        local changes = changes_text(before ~= nil and tech_fields(before_raw, before) or nil, tech_fields(raw, raw.technology[name]))
        if changes ~= nil and is_listed("technology", name) then
            num_techs = num_techs + 1
            log(PREFIX .. "technology " .. name .. (before == nil and " (new)" or "") .. ": " .. changes)
        end
    end
    local num_others = 0
    for _, class in pairs(sorted_names(raw)) do
        if class ~= "recipe" and class ~= "technology" then
            for _, name in pairs(sorted_names(raw[class])) do
                local prot = raw[class][name]
                local before = (before_raw[class] or {})[name]
                local changes = changes_text(before ~= nil and other_fields(before_raw, before) or nil, other_fields(raw, prot))
                if changes ~= nil and is_listed(class, name) then
                    num_others = num_others + 1
                    local shown = prot.localised_name ~= nil and (" \"" .. result_summary.text_of(prot.localised_name) .. "\"") or ""
                    log(PREFIX .. class .. " " .. name .. shown .. (before == nil and " (new)" or "") .. ": " .. changes)
                end
            end
        end
    end
    local removed = {}
    for _, class in pairs(sorted_names(before_raw)) do
        for _, name in pairs(sorted_names(before_raw[class])) do
            if (raw[class] or {})[name] == nil then
                table.insert(removed, class .. " " .. name)
            end
        end
    end
    if #removed > 0 then
        log(PREFIX .. "removed: " .. table.concat(removed, ", "))
    end
    if num_unlisted > 0 then
        log(PREFIX .. num_unlisted .. " changed or new prototypes aren't listed: " .. tostring(unlisted.what))
    end
    log(PREFIX .. "Listed " .. num_recipes .. " recipes (" .. num_uncraftable .. " made in nothing), " .. num_techs .. " technologies and " .. num_others .. " other prototypes; " .. num_recycling .. " recycling recipes follow what they recycle and aren't listed")
end

return result_summary

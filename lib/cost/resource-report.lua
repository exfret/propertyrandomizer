-- Diagnostic: logs how much of each major raw resource one unit of an all-science-pack research costs
-- Used to measure what recipe randomization does to resource costs (compare "before" and "after" stages)
-- Log lines look like: RESOURCEREPORT <stage> <metric> <pack or total> <resource>=<amount> ...
--   metric "bom": bill of raw resources along the aggregate-cheapest recipes (what the recipe randomizer checks)
-- Recycling recipes are left out, since they aren't a real source of materials

local constants = require("helper-tables/constants")
local flow_cost = require("lib/cost/flow-cost")
local cutils = require("lib/cost/cost-utils")

local resource_report = {}

-- One research unit that uses every lab input, as {pack name -> count}
local function find_unit()
    local is_pack = {}
    for _, lab in pairs(data.raw.lab) do
        for _, input in pairs(lab.inputs) do
            is_pack[input] = true
        end
    end
    local best_name
    local best_unit
    for _, tech in pairs(data.raw.technology) do
        if tech.unit ~= nil and tech.unit.ingredients ~= nil then
            local unit = {}
            for _, ing in pairs(tech.unit.ingredients) do
                unit[ing[1] or ing.name] = ing[2] or ing.amount
            end
            local covers_all = true
            for pack, _ in pairs(is_pack) do
                if unit[pack] == nil then
                    covers_all = false
                end
            end
            if covers_all and (best_name == nil or tech.name < best_name) then
                best_name = tech.name
                best_unit = unit
            end
        end
    end
    return best_name, best_unit
end

local function sorted_keys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

local function format_vector(vector, resources)
    local parts = {}
    for _, resource_id in pairs(resources) do
        table.insert(parts, resource_id .. "=" .. string.format("%.3f", vector[resource_id] or 0))
    end
    return table.concat(parts, " ")
end

local function add_scaled(into, vector, scale)
    for resource_id, amount in pairs(vector) do
        into[resource_id] = (into[resource_id] or 0) + scale * amount
    end
end

-- Materials that come from launching a rocket rather than a recipe, as {material id -> {launched item, amount}}
local function rocket_sources()
    local sources = {}
    for item_class, _ in pairs(defines.prototypes.item) do
        for _, item in pairs(data.raw[item_class] or {}) do
            for _, product in pairs(item.rocket_launch_products or {}) do
                sources[flow_cost.get_prot_id(product)] = {
                    launched = flow_cost.get_prot_id(item),
                    amount = cutils.find_amount_in_entry(product),
                }
            end
        end
    end
    return sources
end

local function compute(stage)
    local resources = randomization_info.options.cost.major_raw_resources
    local tech_name, unit = find_unit()
    if tech_name == nil then
        log("RESOURCEREPORT " .. stage .. " no research uses every science pack")
        return
    end
    local packs = sorted_keys(unit)
    log("RESOURCEREPORT " .. stage .. " tech " .. tech_name)

    local costs = flow_cost.determine_recipe_item_cost(flow_cost.get_default_raw_resource_table(), constants.cost_params.time, constants.cost_params.complexity, {track_resources = resources})
    local function bill(material_id)
        return costs.material_to_resources[material_id] or {}
    end

    -- Launch cost of a rocket: its parts plus the launched item, spread over the products
    local silo
    for _, candidate in pairs(data.raw["rocket-silo"]) do
        silo = silo or candidate
    end
    local sources = rocket_sources()
    local function pack_bill(pack_id)
        if costs.material_to_resources[pack_id] == nil and sources[pack_id] ~= nil and silo ~= nil then
            local source = sources[pack_id]
            local part_id = flow_cost.get_prot_id(data.raw.recipe[silo.fixed_recipe].results[1])
            local vector = {}
            add_scaled(vector, bill(source.launched), 1 / source.amount)
            add_scaled(vector, bill(part_id), silo.rocket_parts_required / source.amount)
            return vector
        end
        return bill(pack_id)
    end

    local totals = {
        bom = {},
    }
    for _, pack in pairs(packs) do
        local scaled = {}
        add_scaled(scaled, pack_bill("item-" .. pack), unit[pack])
        add_scaled(totals.bom, scaled, 1)
        log("RESOURCEREPORT " .. stage .. " bom " .. pack .. " " .. format_vector(scaled, resources))
    end
    for metric, total in pairs(totals) do
        log("RESOURCEREPORT " .. stage .. " " .. metric .. " total " .. format_vector(total, resources))
    end
end

resource_report.run = function(stage)
    -- Hide recycling recipes while computing costs
    local hidden = {}
    for name, recipe in pairs(data.raw.recipe) do
        for _, category in pairs(recipe.categories or {recipe.category}) do
            if category == "recycling" then
                hidden[name] = recipe
            end
        end
    end
    for name, _ in pairs(hidden) do
        data.raw.recipe[name] = nil
    end
    compute(stage)
    for name, recipe in pairs(hidden) do
        data.raw.recipe[name] = recipe
    end
end

return resource_report

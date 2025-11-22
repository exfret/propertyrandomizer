-- Config

mod_setup = "sa"

-- Setup

offline = true

require("offline/utils/master")
require("offline/settings")
constants = require("helper-tables/constants")
bit32 = {
    bxor = function(a,b) return a ~ b & 0xffffffff end,
    lshift = function(a,b) return a << b & 0xffffffff end,
    rshift = function(a,b) return a >> b & 0xffffffff end
}
math.pow = function(a,b) return a ^ b end

if mod_setup == "base" then
    mods = {
        ["space-age"] = false
    }
elseif mod_setup == "sa" then
    mods = {
        ["space-age"] = true
    }
end

local data_file
if mod_setup == "base" then
    data_file = io.open("offline/data-raw/base.json", "rb")
elseif mod_setup == "sa" then
    data_file = io.open("offline/data-raw/sa.json", "rb")
elseif mod_setup == "short" then
    data_file = io.open("offline/data-raw/short-py.json", "rb")
elseif mod_setup == "long" then
    data_file = io.open("offline/data-raw/long-py.json", "rb")
end
data = {}
data.raw = json.parse(data_file:read("*all"))
data.raw.recipe["blueprint-book-recycling"] = nil
data.raw.recipe["blueprint-recycling"] = nil
data.raw.recipe["copy-paste-tool-recycling"] = nil
data.raw.recipe["cut-paste-tool-recycling"] = nil
data.raw.recipe["construction-planner-recycling"] = nil
data.raw.recipe["deconstruction-planner-recycling"] = nil
data.raw.recipe["selection-tool-recycling"] = nil
data.raw.recipe["upgrade-planner-recycling"] = nil

local log_file_overwrite = io.open("offline/output/current.log", "wb")
log_file_overwrite:write("")
log_file_overwrite:close()
local log_file = io.open("offline/output/current.log", "ab")
log = function(text) log_file:write(tostring(os.clock()) .. ": " .. text .. "\n") end

data.raw["utility-constants"] = {
    default = {
        rocket_lift_weight = 1000000
    }
}

-- Tracking

--[[
counter = 0
per_entity_class = {}
for entity_class, _ in pairs(defines.prototypes.entity) do
    per_entity_class[entity_class] = 0
    if data.raw[entity_class] ~= nil then
        for _, entity in pairs(data.raw[entity_class]) do
            counter = counter + 1
            per_entity_class[entity_class] = per_entity_class[entity_class] + 1
        end
    end
end
print(counter)
for class, amount in pairs(per_entity_class) do
    if amount > 50 then
        print(class .. ": " .. tostring(amount))
    end
end]]

global_seed = 767614037

local build_graph = require("lib/graph/build-graph")
local min_rec_req = require("lib/graph/min-rec-req")
local set_utils = require("lib/graph/set-utils")
local graph = build_graph.graph

-- adjust graph to make rocket building on certain planets never rely on import

local independent_planets = { "nauvis", "vulcanus", "gleba", "fulgora" }

for item_class, _ in pairs(defines.prototypes.item) do
    if data.raw[item_class] ~= nil then
        for _, item in pairs(data.raw[item_class]) do
            for _, planet_name in pairs(independent_planets) do
                local import_node = graph[build_graph.key("transport-item-to-planet", build_graph.compound_key({item.name, planet_name}))]
                local export_node = graph[build_graph.key("rocket-launch-planet", planet_name)]

                table.insert(import_node.prereqs, {
                    type = export_node.type,
                    name = export_node.name
                })
            end
        end
    end
end

build_graph.add_dependents(graph)

min_rec_req.init(graph)
local end_game_node = graph[build_graph.key("technology", "promethium-science-pack")]
local end_game_min_rec_req = min_rec_req.minimum_recursive_requirements(end_game_node, "technology")
local planet_node = graph[build_graph.key("planet", "vulcanus")]
local planet_min_rec_req = min_rec_req.minimum_recursive_requirements(planet_node, "technology").nodes
local rocket_node = graph[build_graph.key("rocket-launch-planet", "vulcanus")]
local rocket_min_rec_req = min_rec_req.minimum_recursive_requirements(rocket_node, "technology").nodes
local from_planet_to_rocket = table.deepcopy(rocket_min_rec_req)
set_utils.merge_difference(from_planet_to_rocket, planet_min_rec_req)
--[[dep_graph_file = io.open("offline/output/dep-graph.json", "wb")
dep_graph_file:write(json.stringify(build_graph.graph))]]

local cost_params = constants.cost_params

local flow_cost = require("lib/graph/flow-cost")
local old_costs = flow_cost.determine_recipe_item_cost(flow_cost.get_default_raw_resource_table(), cost_params.time, cost_params.complexity).material_to_cost
local old_recipe_costs = flow_cost.determine_recipe_item_cost(flow_cost.get_default_raw_resource_table(), cost_params.time, cost_params.complexity).recipe_to_cost
local old_iron_costs = flow_cost.determine_recipe_item_cost(flow_cost.get_single_resource_table("item-iron-ore"), 0, 0).material_to_cost
local old_copper_costs = flow_cost.determine_recipe_item_cost(flow_cost.get_single_resource_table("item-copper-ore"), 0, 0).material_to_cost
local old_stone_costs = flow_cost.determine_recipe_item_cost(flow_cost.get_single_resource_table("item-stone"), 0, 0).material_to_cost
local old_coal_costs = flow_cost.determine_recipe_item_cost(flow_cost.get_single_resource_table("item-coal"), 0, 0).material_to_cost
local old_oil_costs = flow_cost.determine_recipe_item_cost(flow_cost.get_single_resource_table("fluid-crude-oil"), 0, 0).material_to_cost

-- Now run the actual program

-- Skip data.lua as it's not needed and uses the undefined :extend method for data
--require("data")
require("data-updates")
require("data-final-fixes")

-- Reporting

print("\n")

local new_costs = flow_cost.determine_recipe_item_cost(flow_cost.get_default_raw_resource_table(), cost_params.time, cost_params.complexity).material_to_cost

-- Only do sciences
--[[local science_names = {
    ["item-automation-science-pack"] = true,
    ["item-logistic-science-pack"] = true,
    ["item-military-science-pack"] = true,
    ["item-chemical-science-pack"] = true,
    --["item-production-science-pack"] = true,
    ["item-utility-science-pack"] = true,
    ["item-space-science-pack"] = true,
}
for _, tbl in pairs({old_costs, old_recipe_costs, old_iron_costs, old_copper_costs, old_stone_costs, old_coal_costs, old_oil_costs}) do
    for material_name, _ in pairs(tbl) do
        if not science_names[material_name] then
            tbl[material_name] = nil
        end
    end
end]]

-- Find biggest additive/multiplicative difference
local largest_cost_diff
local largest_cost_diff_mat
for material_name, old_cost in pairs(old_costs) do
    local curr_diff = math.abs(old_cost - new_costs[material_name])
    if largest_cost_diff == nil or curr_diff > largest_cost_diff then
        largest_cost_diff = curr_diff
        largest_cost_diff_mat = material_name
    end
end
print(largest_cost_diff_mat)
print(old_costs[largest_cost_diff_mat])
print(new_costs[largest_cost_diff_mat])
local largest_cost_factor
local largest_cost_factor_mat
for material_name, old_cost in pairs(old_costs) do
    local curr_factor = math.abs(math.log(old_cost) - math.log(new_costs[material_name]))
    if largest_cost_factor == nil or curr_factor > largest_cost_factor then
        largest_cost_factor = curr_factor
        largest_cost_factor_mat = material_name
    end
end
print(largest_cost_factor_mat)
print(old_costs[largest_cost_factor_mat])
print(new_costs[largest_cost_factor_mat])

local acc_cost_factor = 0
local num_mats = 0
for material_name, old_cost in pairs(old_costs) do
    acc_cost_factor = acc_cost_factor + math.log(new_costs[material_name]) - math.log(old_cost)
    num_mats = num_mats + 1
end
print(math.exp(acc_cost_factor / num_mats))

-- TODO: Switch to better cost measurements
print("")
print("IRON")
local new_iron_costs = flow_cost.determine_recipe_item_cost(flow_cost.get_single_resource_table("item-iron-ore"), 0, 0).material_to_cost
local acc_cost_factor_iron = 0
local num_mats_iron = 0
for material_name, old_cost in pairs(old_iron_costs) do
    if old_cost > 0 or new_iron_costs[material_name] > 0 then
        acc_cost_factor_iron = acc_cost_factor_iron + math.log(1 + new_iron_costs[material_name]) - math.log(1 + old_cost)
        num_mats_iron = num_mats_iron + 1
    end
end
print(math.exp(acc_cost_factor_iron / num_mats_iron))

print("")
print("COPPER")
local new_copper_costs = flow_cost.determine_recipe_item_cost(flow_cost.get_single_resource_table("item-copper-ore"), 0, 0).material_to_cost
local acc_cost_factor_copper = 0
local num_mats_copper = 0
for material_name, old_cost in pairs(old_copper_costs) do
    if old_cost > 0 or new_copper_costs[material_name] > 0 then
        acc_cost_factor_copper = acc_cost_factor_copper + math.log(1 + new_copper_costs[material_name]) - math.log(1 + old_cost)
        num_mats_copper = num_mats_copper + 1
    end
end
print(math.exp(acc_cost_factor_copper / num_mats_copper))

print("")
print("STONE")
local new_stone_costs = flow_cost.determine_recipe_item_cost(flow_cost.get_single_resource_table("item-stone"), 0, 0).material_to_cost
local acc_cost_factor_stone = 0
local num_mats_stone = 0
for material_name, old_cost in pairs(old_stone_costs) do
    if old_cost > 0 or new_stone_costs[material_name] > 0 then
        acc_cost_factor_stone = acc_cost_factor_stone + math.log(1 + new_stone_costs[material_name]) - math.log(1 + old_cost)
        num_mats_stone = num_mats_stone + 1
    end
end
print(math.exp(acc_cost_factor_stone / num_mats_stone))

print("")
print("COAL")
local new_coal_costs = flow_cost.determine_recipe_item_cost(flow_cost.get_single_resource_table("item-coal"), 0, 0).material_to_cost
local acc_cost_factor_coal = 0
local num_mats_coal = 0
for material_name, old_cost in pairs(old_coal_costs) do
    if old_cost > 0 or new_coal_costs[material_name] > 0 then
        acc_cost_factor_coal = acc_cost_factor_coal + math.log(1 + new_coal_costs[material_name]) - math.log(1 + old_cost)
        num_mats_coal = num_mats_coal + 1
    end
end
print(math.exp(acc_cost_factor_coal / num_mats_coal))

print("")
print("OIL")
local new_oil_costs = flow_cost.determine_recipe_item_cost(flow_cost.get_single_resource_table("fluid-crude-oil"), 0, 0).material_to_cost
local acc_cost_factor_oil = 0
local num_mats_oil = 0
for material_name, old_cost in pairs(old_oil_costs) do
    if old_cost > 0 or new_oil_costs[material_name] > 0 then
        acc_cost_factor_oil = acc_cost_factor_oil + math.log(1 + new_oil_costs[material_name]) - math.log(1 + old_cost)
        num_mats_oil = num_mats_oil + 1
    end
end
print(math.exp(acc_cost_factor_oil / num_mats_oil))

-- Output

output = io.open("offline/output/data-raw-randomized.json", "wb")
output:write(json.stringify(data.raw))
output_recipe = io.open("offline/output/recipes-randomized.json", "wb")
output_recipe:write(json.stringify(data.raw.recipe))
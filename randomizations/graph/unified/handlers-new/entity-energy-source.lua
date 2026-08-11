-- TODO: Need to actual check collisons with pre-existing pipe conns

local categories = require("helper-tables/categories")
local pipe_conns = require("lib/pipe-conns")
local gutils = require("lib/graph/graph-utils")
local dutils = require("lib/data-utils")
local rng = require("lib/random/rng")

local entity_energy_source = {}

entity_energy_source.id = "entity_energy_source"

entity_energy_source.with_replacement = true
entity_energy_source.uniform_copies = true

entity_energy_source.initialize = function()
end

local is_energy_source_node = {
    ["energy-source-void"] = true,
    ["energy-source-burner"] = true,
    ["energy-source-electric"] = true,
    ["energy-source-fluid"] = true,
    ["energy-source-heat"] = true,
}
-- Include novel energy sources more than just boring electric all the time
local num_times_to_include = {
    ["energy-source-void"] = 5,
    ["energy-source-burner"] = 3,
    ["energy-source-electric"] = 1,
    ["energy-source-fluid"] = 5,
    ["energy-source-heat"] = 5,
}
entity_energy_source.claim = function(graph, prereq, dep, edge)
    local entity = dutils.get_prot("entity", dep.name)

    if is_energy_source_node[prereq.type] and dep.type == "entity-operate" and categories.energy_sources_any[entity.type] then
        if entity.energy_source ~= nil and entity.energy_source.type == "burner" then
            if entity.energy_source.fuel_categories ~= nil then
                -- Exclude things without the chemical category at all
                local has_chemical = false
                for _, cat in pairs(entity.energy_source.fuel_categories) do
                    if cat == "chemical" then
                        has_chemical = true
                    end
                end
                if not has_chemical then
                    return false
                end
            end
        end

        return num_times_to_include[prereq.type]
    end
end

-- Calculating fluid/heat box connections for the following would be a pain, so don't add that energy source to them
local dont_add_fluid_or_heat_types = {
    ["offshore-pump"] = true,
    ["mining-drill"] = true,
}
entity_energy_source.validate = function(graph, base, head, extra)
    local base_owner = gutils.get_owner(graph, base)
    local head_owner = gutils.get_owner(graph, head)

    if is_energy_source_node[base_owner.type] then
        local entity = dutils.get_prot("entity", head_owner.name)

        local dont_add_fluid_or_heat = dont_add_fluid_or_heat_types[entity.type]
        local possible_conns = pipe_conns.get_available_pipe_connections(entity, true)
        if #possible_conns < 2 then
            dont_add_fluid_or_heat = true
        end

        if dont_add_fluid_or_heat and (base_owner.type == "energy-source-fluid" or base_owner.type == "energy-source-heat") and (entity.energy_source == nil or (entity.energy_source.type ~= "fluid" and entity.energy_source.type ~= "heat")) then
            return false
        end

        return true
    end
end

entity_energy_source.reflect = function(graph, head_to_base, head_to_handler)
    for head_key, base_key in pairs(head_to_base) do
        if head_to_handler[head_key].id == "entity_energy_source" then
            local base = graph.nodes[base_key]
            local head = graph.nodes[head_key]
            local base_owner = gutils.get_owner(graph, base)
            local head_owner = gutils.get_owner(graph, head)
            local entity = dutils.get_prot("entity", head_owner.name)

            local possible_conns = pipe_conns.get_available_pipe_connections(entity, true)
            rng.shuffle(rng.key({id = "entity-energy-source"}), possible_conns)

            local random_conn1 = possible_conns[1]
            local random_conn2 = possible_conns[2]

            if base_owner.type == "energy-source-void" then
                entity.energy_source.type = "void"
            elseif base_owner.type == "energy-source-burner" then
                entity.energy_source.type = "burner"
                local fcat_combo = lu.fcat_combos[base_owner.name]
                entity.energy_source.fuel_inventory_size = entity.energy_source.fuel_inventory_size or 1
                entity.energy_source.burnt_inventory_size = fcat_combo.burnt
                entity.energy_source.fuel_categories = fcat_combo.fuel
            elseif base_owner.type == "energy-source-electric" then
                entity.energy_source.type = "electric"
                entity.energy_source.usage_priority = entity.energy_source.usage_priority or "secondary-input"
            elseif base_owner.type == "energy-source-fluid" then
                entity.energy_source.type = "fluid"
                entity.energy_source.burns_fluid = true
                entity.energy_source.scale_fluid_usage = true
                entity.energy_source.fluid_box = entity.energy_source.fluid_box or {
                    volume = 1000,
                    pipe_connections = {table.deepcopy(random_conn1), table.deepcopy(random_conn2)},
                    production_type = "input",
                }
            elseif base_owner.type == "energy-source-heat" then
                entity.energy_source.type = "heat"
                entity.energy_source.max_temperature = entity.energy_source.max_temperature or 500
                entity.energy_source.specific_heat = entity.energy_source.specific_heat or "1MJ"
                entity.energy_source.max_transfer = entity.energy_source.max_transfer or "2GW"
                entity.energy_source.connections = entity.energy_source.connections or {random_conn1, random_conn2}
            end
        end
    end
end

return entity_energy_source
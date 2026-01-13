-- For now, blockification works best when we assume all missing prereqs can be fulfilled all at once
-- This is the case mostly when the blocks depend on ALL incoming connections, so they are set up like this
-- In the future, I can relax this so that blocks can have more complex boolean formulas on their inputs

-- Also, keep some dependencies between blocks (a very light amount), like most things shouldn't even be available until after power
-- Basically just coding in the very basic game mechanics that I can't change anyways

local gutils = require("new-lib/graph/graph-utils")
local lu = require("new-lib/lookup/init")
local logic = require("new-lib/logic/init")

local blockify = {}

local function merge_blocks(name1, name2)
    -- Error on merging nonexistent groups
    if blockify.group_node_set[name1] == nil or blockify.group_node_set[name2] == nil then
        error("Attempted to merge nonexistent block group")
    end

    -- Update group_node_set of first group to include second, and update node_to_group
    for node_key, _ in pairs(blockify.group_node_set[name2]) do
        blockify.group_node_set[name1][node_key] = true
        blockify.node_to_group[node_key] = name1
    end
    -- Remove second group from group_node_set
    blockify.group_node_set[name2] = nil
end

-- Get the blocks of node1 and node2 then merge
-- node1 and node2 are given as keys
local function merge_nodes(node1, node2)
    merge_blocks(blockify.node_to_group[node1], blockify.node_to_group[node2])
end

-- Segment a logic graph into "blocks", sections of nodes that serve a common game mechanic, with special emphasis on vanilla feature units
-- For example: Steam power block has boiler, steam engine, offshore pump, with in-edges for the items to build these and fuel for boiler
blockify.get = function(graph)
    blockify.group_node_set = {}
    blockify.node_to_group = {}

    local group_node_set = blockify.group_node_set
    local node_to_group = blockify.node_to_group

    -- First, group by canonical
    for _, node in pairs(graph.nodes) do
        local group_name = gutils.key(logic.type_info[node.type].canonical, node.name)
        group_node_set[group_name] = group_node_set[group_name] or {}
        group_node_set[group_name][gutils.key(node)] = true
        node_to_group[gutils.key(node)] = group_name
    end

    -- Link recipes to unique item produced
    ----------------------------------------------------------------------
    -- Automatic Identity Merging
    ----------------------------------------------------------------------

    -- Link recipes to unique item produced
    -- This may seem inflexible, but as long as we don't also link the ingredients/surface condition/etc, the whole unit can still go anywhere
    -- And it gives less degrees of freedom to worry about
    for _, recipe in pairs(lu.recipes) do
        if recipe.results ~= nil and #recipe.results == 1 and recipe.name == recipe.results[1].name then
            merge_nodes(gutils.key("recipe", recipe.name), gutils.key(recipe.results[1].type .. "-craft", recipe.results[1].name))
        end
    end

    -- Link items to entities they place (same name)
    for _, item in pairs(lu.items) do
        if item.place_result ~= nil and item.place_result ~= "" and item.place_result == item.name then
            merge_nodes(gutils.key("item", item.name), gutils.key("entity-build-item", item.place_result))
        end
    end

    -- Link items to tiles they place
    for tile_name, placing_items in pairs(lu.place_as_tile_items) do
        for item_name, _ in pairs(placing_items) do
            local item_key = gutils.key("item", item_name)
            local tile_key = gutils.key("tile-build-item", tile_name)
            if node_to_group[item_key] ~= nil and node_to_group[tile_key] ~= nil then
                merge_nodes(item_key, tile_key)
            end
        end
    end

    -- Link items to equipment they place
    for equip_name, placing_items in pairs(lu.equipment_to_items) do
        for item_name, _ in pairs(placing_items) do
            local item_key = gutils.key("item", item_name)
            local equip_key = gutils.key("equipment-place", equip_name)
            if node_to_group[item_key] ~= nil and node_to_group[equip_key] ~= nil then
                merge_nodes(item_key, equip_key)
            end
        end
    end

    -- Link fluids to their barrels and barreling recipes
    for _, fluid in pairs(lu.fluids) do
        local barrel_name = fluid.name .. "-barrel"
        local barrel = lu.items[barrel_name]
        if barrel ~= nil then
            local fluid_key = gutils.key("fluid", fluid.name)
            local barrel_key = gutils.key("item", barrel_name)
            if node_to_group[fluid_key] ~= nil and node_to_group[barrel_key] ~= nil then
                merge_nodes(fluid_key, barrel_key)
            end
            -- Also merge fill/empty recipes
            local fill_name = "fill-" .. barrel_name
            local empty_name = "empty-" .. barrel_name
            if lu.recipes[fill_name] ~= nil then
                local fill_key = gutils.key("recipe", fill_name)
                if node_to_group[fluid_key] ~= nil and node_to_group[fill_key] ~= nil then
                    merge_nodes(fluid_key, fill_key)
                end
            end
            if lu.recipes[empty_name] ~= nil then
                local empty_key = gutils.key("recipe", empty_name)
                if node_to_group[fluid_key] ~= nil and node_to_group[empty_key] ~= nil then
                    merge_nodes(fluid_key, empty_key)
                end
            end
        end
    end

    -- Link fluoroketone-hot and fluoroketone-cold (same fluid at different temperatures)
    if lu.fluids["fluoroketone-hot"] ~= nil and lu.fluids["fluoroketone-cold"] ~= nil then
        local hot_key = gutils.key("fluid", "fluoroketone-hot")
        local cold_key = gutils.key("fluid", "fluoroketone-cold")
        if node_to_group[hot_key] ~= nil and node_to_group[cold_key] ~= nil then
            merge_nodes(hot_key, cold_key)
        end
    end

    -- Link rail shapes (straight-rail + curved-rail-a + curved-rail-b + half-diagonal-rail)
    local rail_shapes = {"straight-rail", "curved-rail-a", "curved-rail-b", "half-diagonal-rail"}
    local first_rail = nil
    for _, rail_name in pairs(rail_shapes) do
        local rail_key = gutils.key("entity-build-item", rail_name)
        if node_to_group[rail_key] ~= nil then
            if first_rail == nil then
                first_rail = rail_key
            else
                merge_nodes(first_rail, rail_key)
            end
        end
    end

    -- Link elevated rail shapes
    local elevated_shapes = {"elevated-straight-rail", "elevated-curved-rail-a", "elevated-curved-rail-b", "elevated-half-diagonal-rail"}
    local first_elevated = nil
    for _, rail_name in pairs(elevated_shapes) do
        local rail_key = gutils.key("entity-build-item", rail_name)
        if node_to_group[rail_key] ~= nil then
            if first_elevated == nil then
                first_elevated = rail_key
            else
                merge_nodes(first_elevated, rail_key)
            end
        end
    end

    -- Link seed pairs (jellynut + jellynut-seed, yumako + yumako-seed)
    local seed_pairs = {
        {"jellynut", "jellynut-seed"},
        {"yumako", "yumako-seed"},
    }
    for _, pair in pairs(seed_pairs) do
        local item_key = gutils.key("item", pair[1])
        local seed_key = gutils.key("item", pair[2])
        if node_to_group[item_key] ~= nil and node_to_group[seed_key] ~= nil then
            merge_nodes(item_key, seed_key)
        end
    end

    -- Link solid-fuel item with all solid-fuel-from-* recipes
    local solid_fuel_key = gutils.key("item", "solid-fuel")
    if node_to_group[solid_fuel_key] ~= nil then
        for recipe_name, _ in pairs(lu.recipes) do
            if recipe_name:match("^solid%-fuel%-from%-") then
                local recipe_key = gutils.key("recipe", recipe_name)
                if node_to_group[recipe_key] ~= nil then
                    merge_nodes(solid_fuel_key, recipe_key)
                end
            end
        end
    end

    ----------------------------------------------------------------------
    -- System Blocks: Merge entities that must unlock together
    ----------------------------------------------------------------------

    -- Helper to merge a list of node keys if they exist
    local function merge_block(keys)
        local first = nil
        for _, node_key in pairs(keys) do
            if node_to_group[node_key] ~= nil then
                if first == nil then
                    first = node_key
                else
                    merge_nodes(first, node_key)
                end
            end
        end
        return first
    end

    -- Steam power: boiler + steam-engine + offshore-pump
    merge_block({
        gutils.key("entity-build-item", "boiler"),
        gutils.key("entity-build-item", "steam-engine"),
        gutils.key("entity-build-item", "offshore-pump"),
    })

    -- Solar power: solar-panel + accumulator
    merge_block({
        gutils.key("entity-build-item", "solar-panel"),
        gutils.key("entity-build-item", "accumulator"),
    })

    -- Nuclear power: nuclear-reactor + heat-exchanger + steam-turbine
    merge_block({
        gutils.key("entity-build-item", "nuclear-reactor"),
        gutils.key("entity-build-item", "heat-exchanger"),
        gutils.key("entity-build-item", "steam-turbine"),
    })

    -- Fusion power: fusion-reactor + fusion-generator
    merge_block({
        gutils.key("entity-build-item", "fusion-reactor"),
        gutils.key("entity-build-item", "fusion-generator"),
    })

    -- Lightning power: lightning-collector + lightning-rod
    merge_block({
        gutils.key("entity-build-item", "lightning-collector"),
        gutils.key("entity-build-item", "lightning-rod"),
    })

    -- Space launch: rocket-silo + cargo-landing-pad + cargo-bay
    merge_block({
        gutils.key("entity-build-item", "rocket-silo"),
        gutils.key("entity-build-item", "cargo-landing-pad"),
        gutils.key("entity-build-item", "cargo-bay"),
    })

    -- Space platform: thruster + asteroid-collector + space-platform-foundation + crusher
    merge_block({
        gutils.key("entity-build-item", "thruster"),
        gutils.key("entity-build-item", "asteroid-collector"),
        gutils.key("entity-build-item", "space-platform-foundation"),
        gutils.key("entity-build-item", "crusher"),
    })

    -- Robot logistics: roboport + construction-robot + logistic-robot
    merge_block({
        gutils.key("entity-build-item", "roboport"),
        gutils.key("entity-build-item", "construction-robot"),
        gutils.key("entity-build-item", "logistic-robot"),
    })

    -- Train system: locomotive + cargo-wagon + fluid-wagon + train-stop + rail-signal + rail-chain-signal + rails
    local train_block = merge_block({
        gutils.key("entity-build-item", "locomotive"),
        gutils.key("entity-build-item", "cargo-wagon"),
        gutils.key("entity-build-item", "fluid-wagon"),
        gutils.key("entity-build-item", "train-stop"),
        gutils.key("entity-build-item", "rail-signal"),
        gutils.key("entity-build-item", "rail-chain-signal"),
    })
    -- Merge rails into train system
    if first_rail ~= nil and train_block ~= nil then
        merge_nodes(first_rail, train_block)
    end

    -- Elevated rails: rail-ramp + rail-support + elevated shapes
    local elevated_infra = merge_block({
        gutils.key("entity-build-item", "rail-ramp"),
        gutils.key("entity-build-item", "rail-support"),
    })
    if first_elevated ~= nil and elevated_infra ~= nil then
        merge_nodes(first_elevated, elevated_infra)
    end

    -- Circuit network: all combinators
    merge_block({
        gutils.key("entity-build-item", "arithmetic-combinator"),
        gutils.key("entity-build-item", "decider-combinator"),
        gutils.key("entity-build-item", "constant-combinator"),
        gutils.key("entity-build-item", "selector-combinator"),
    })

    -- TODO: Postprocessing step where we break up blocks that can't be done all at once
end

return blockify
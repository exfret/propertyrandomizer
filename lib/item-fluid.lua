-- Items and fluids in first pass (config.item_fluids): they trade positions, and an identity keeps its form
-- User, 2026-09-29: an item in a fluid slot stays an item, and a fluid in an item slot stays a fluid (the earlier rule, that an identity took its new position's form, is withdrawn)
-- A position (slot) keeps what it does in the game: the recipes taking and making it and the resources mined into it, which take or give the identity's form now (recipes change shape, and a drill drops items or fills its output box; see position_takes)
-- An identity (trav) keeps what it is: what it places, burns, fuels and launches into, and for a fluid the entities taking it (boilers, generators, thrusters, turrets, fluid energy sources), pumping it from tiles and barreling it, which only make sense for a fluid (see move_identity_sources)
-- So nothing ever asks what an item is as a fluid; a pair of different forms only asks whether the position's roles suit the identity's form
-- Shared by first pass (the model) and item reflection (the game), which must agree

local gutils = require("lib/graph/graph-utils")
local dutils = require("lib/data-utils")
local fluid_ports = require("lib/fluid-ports")
local furnace_selection = require("lib/furnace-selection")
local lutils = require("lib/logic/logic-utils")

local item_fluid = {}

-- The node an edge really comes from, looking through the orand gutils.make_orands puts on an edge into an OR node, and through the head and base a randomized edge is cut into (gutils.subdivide_base_head; first pass's graphs keep them on their vanilla owners, so a head's base is fed by the edge's original start)
local function real_prenode(graph, prenode)
    while true do
        if prenode.type == "orand" then
            prenode = gutils.unique_prenode(graph, prenode)
        elseif prenode.type == "head" and prenode.old_base ~= nil and graph.nodes[prenode.old_base] ~= nil then
            prenode = gutils.unique_prenode(graph, graph.nodes[prenode.old_base])
        else
            return prenode
        end
    end
end
-- The node an edge really goes to, likewise (a base's head leads to the edge's original stop, through an orand when that's an OR node)
local function real_depnode(graph, depnode)
    while true do
        if depnode.type == "orand" then
            depnode = gutils.unique_depnode(graph, depnode)
        elseif depnode.type == "base" and depnode.old_head ~= nil and graph.nodes[depnode.old_head] ~= nil then
            depnode = gutils.unique_depnode(graph, graph.nodes[depnode.old_head])
        else
            return depnode
        end
    end
end
local function real_prenodes(graph, node)
    local prenodes = {}
    for _, prenode in pairs(gutils.prenodes(graph, node)) do
        table.insert(prenodes, real_prenode(graph, prenode))
    end
    return prenodes
end
local function real_deps(graph, node)
    local deps = {}
    for dep, _ in pairs(node.dep) do
        table.insert(deps, { edge_key = dep, node = real_depnode(graph, gutils.depnode(graph, dep)) })
    end
    return deps
end

----------------------------------------------------------------------------------------------------
-- Materials
----------------------------------------------------------------------------------------------------

-- The material a first pass slot or trav stands for, as {type = "item" or "fluid", name}, or nil for other slots (like entity positions)
-- Item slots are item nodes, fluid slots are fluid-temperature nodes (a fluid at its only temperature), and a trav is named after its slot (old_slot)
item_fluid.material_of_node = function(graph, node)
    if node.old_slot ~= nil then
        node = graph.nodes[node.old_slot]
    end
    if node.type == "item" then
        return { type = "item", name = node.name }
    elseif node.type == "fluid-temperature" then
        return { type = "fluid", name = gutils.deconstruct(node.name).type }
    end
    return nil
end

-- "item: name" or "fluid: name", as the material cost tables key them
item_fluid.material_key = function(material)
    return gutils.key(material.type, material.name)
end

-- The prototype of a material, or nil
item_fluid.prot = function(material)
    if material.type == "fluid" then
        return (data.raw.fluid or {})[material.name]
    end
    return dutils.get_prot("item", material.name)
end

-- Fields of a recipe ingredient or result that only its form has, dropped when the entry takes the other form (types/ItemProductPrototype.html, FluidProductPrototype.html, ItemIngredientPrototype.html and FluidIngredientPrototype.html in the API docs)
item_fluid.FORM_ONLY_FIELDS = {
    item = {
        "extra_count_fraction",
        "percent_spoiled",
        "always_fresh",
        "reset_freshness_on_craft",
        "quality_min",
        "quality_max",
        "quality_change",
        "affected_by_quality",
        "spoil_weight",
    },
    fluid = {
        "temperature",
        "minimum_temperature",
        "maximum_temperature",
        "fluidbox_index",
        "fluidbox_multiplier",
        "optional_fluidbox_indexes",
    },
}

-- An amount in a form: items come whole (at least one), fluids to two decimals (user, 2026-09-29: fluids can be fractional, with only a couple of decimal places)
item_fluid.round_amount = function(form, amount)
    if form == "fluid" then
        -- A fluid ingredient's amount can't be 0 (types/FluidIngredientPrototype.html: "Can not be <= 0"), which a small multiplier rounds a small amount to
        return math.max(0.01, math.floor(amount * 100 + 0.5) / 100)
    end
    return math.max(1, math.floor(amount + 0.5))
end

----------------------------------------------------------------------------------------------------
-- Useless materials
----------------------------------------------------------------------------------------------------

-- Fluids entities take by name, as fluid name --> true: the filters of fluid boxes fluids flow into (FluidBox.filter, on boilers, generators, thrusters, fusion reactors, fluid energy sources and the like; a box that only puts a fluid out, like an offshore pump's, is a maker, which is the fluid's position) and the fluids fluid turrets fire (StreamAttackParameters.fluids)
-- Computed once per load, at first pass (see recalculate_entity_fluids), so first pass's model and item reflection agree on which fluids are useless
local entity_fluids

-- Looks through an entity's tables a few levels deep, where its fluid boxes and attack parameters are (its graphics go deeper, and have neither)
local ENTITY_FLUIDS_DEPTH = 4
local function collect_entity_fluids(tbl, found, depth)
    if type(tbl.filter) == "string" and type(tbl.pipe_connections) == "table" and tbl.production_type ~= "output" then
        found[tbl.filter] = true
    end
    if tbl.type == "stream" and type(tbl.fluids) == "table" then
        for _, entry in pairs(tbl.fluids) do
            if type(entry) == "table" and type(entry.type) == "string" then
                found[entry.type] = true
            end
        end
    end
    if depth < ENTITY_FLUIDS_DEPTH then
        for _, value in pairs(tbl) do
            if type(value) == "table" then
                collect_entity_fluids(value, found, depth + 1)
            end
        end
    end
end

item_fluid.recalculate_entity_fluids = function()
    entity_fluids = {}
    for _, entity in pairs(dutils.get_all_prots("entity")) do
        collect_entity_fluids(entity, entity_fluids, 0)
    end
    return entity_fluids
end

item_fluid.entity_fluids = function()
    if entity_fluids == nil then
        item_fluid.recalculate_entity_fluids()
    end
    return entity_fluids
end

-- Whether a fluid does nothing on its own, like a useless item (dutils.is_useless_item): it isn't a fuel (fluid energy sources burn fluids with a fuel value), and no entity takes it by name (see entity_fluids)
-- What its position does (recipes taking and making it, resources mined into it) isn't the fluid's
item_fluid.is_useless_fluid = function(fluid)
    if fluid == nil or fluid.type ~= "fluid" then
        return false
    end
    if fluid.fuel_value ~= nil and util.parse_energy(fluid.fuel_value) ~= 0 then
        return false
    end
    return item_fluid.entity_fluids()[fluid.name] == nil
end

-- Whether a material is a useless item (dutils.is_useless_item) or a useless fluid (is_useless_fluid): swapping two of them of the same form only changes names
item_fluid.is_useless_material = function(material_key)
    local material = gutils.deconstruct(material_key)
    if material.type == "fluid" then
        return item_fluid.is_useless_fluid((data.raw.fluid or {})[material.name])
    end
    if material.type ~= "item" then
        return false
    end
    local item = dutils.get_prot("item", material.name)
    return item ~= nil and dutils.is_useless_item(item)
end

-- Where item reflection puts each identity, given a matching as identity_at: position material key --> identity material key (a permutation of the same keys)
-- Item reflection doesn't swap two useless materials of the same form, since that would only change names (dutils.reflected_item_position is the rule for items alone, which this matches with only items)
-- A useless identity assigned to a position of its own form instead goes to the first position along its cycle whose assigned identity is useless and of that form (its own position, if that one is)
-- So non-useless identities and identities at positions of the other form land where they were assigned (only pairs first pass allowed change form), useless items only detour among item positions and useless fluids among fluid positions, and it's still a permutation
-- Applying the rule to its own result can move a useless item again (its cycle changed where useless fluids detoured), so first pass gates what this returns and item reflection applies that as it is (see reflected_positions): the model and the game agree by construction
-- Returns position material key --> identity material key
item_fluid.realized_assignment = function(identity_at)
    -- The form of each useless identity assigned to a position of its own form
    local useless_form = {}
    for position_key, identity_key in pairs(identity_at) do
        local form = gutils.deconstruct(position_key).type
        if gutils.deconstruct(identity_key).type == form and item_fluid.is_useless_material(identity_key) then
            useless_form[identity_key] = form
        end
    end
    local realized = {}
    for position_key, identity_key in pairs(identity_at) do
        local form = useless_form[identity_key]
        if form == nil then
            realized[position_key] = identity_key
        elseif useless_form[identity_at[identity_key]] ~= form then
            -- Along the cycle from the identity's own position (a position's key is its own material's) to the first position holding a useless identity of the form
            local curr = identity_at[identity_key]
            while useless_form[identity_at[curr]] ~= form do
                curr = identity_at[curr]
            end
            realized[curr] = identity_key
        end
    end
    -- Positions reflection doesn't rename keep their own materials
    for position_key, _ in pairs(identity_at) do
        if realized[position_key] == nil then
            realized[position_key] = position_key
        end
    end
    return realized
end

-- The positions item reflection switches identities to, given the assignment first pass realized (position material key --> identity material key), as identity material key --> position material key
-- Every identity not at its own position is switched; one at its own position only if it isn't useless (its recipes and drills still get named after it, as before), since a useless identity there is one the useless rule kept home
item_fluid.reflected_positions = function(identity_at)
    local positions = {}
    for position_key, identity_key in pairs(identity_at) do
        if position_key ~= identity_key or not item_fluid.is_useless_material(identity_key) then
            positions[identity_key] = position_key
        end
    end
    return positions
end

----------------------------------------------------------------------------------------------------
-- Positions
----------------------------------------------------------------------------------------------------

-- Whether first pass takes a fluid's position (its fluid-temperature node): a fluid at a single temperature that only recipes and mining a resource make
-- Pumping from tiles belongs to a fluid's identity (user, 2026-09-29; see move_identity_sources), so a fluid pumped from tiles (water, lava, ammoniacal solution) keeps its position too: whatever else landed there could only be made by the position's other recipes, which come late or not at all (water's are ice melting and steam condensation), and every user of the position would lose it (seen on SA seeds 1 and 2: monotone matching then moved nothing at all)
-- Other fluids (like steam, which boilers heat to several temperatures) keep their positions and identities too
-- A fluid carried around a round trip (dutils.round_trips, like cooled fluoroketone) is fine: the recipes at its position make something else then, and the fluid is made at its identity's new position (user, 2026-09-27: "Made by round trips is okay")
item_fluid.fluid_slot_ok = function(graph, node)
    if node.type ~= "fluid-temperature" then
        return false
    end
    local fluid_name = gutils.deconstruct(node.name).type
    local fluid = (data.raw.fluid or {})[fluid_name]
    if fluid == nil or fluid.hidden or fluid.parameter then
        return false
    end
    if randomization_info.options.first_pass.blacklist[gutils.key("fluid", fluid_name)] ~= nil then
        return false
    end
    local fluid_node = graph.nodes[gutils.key("fluid", fluid_name)]
    if fluid_node == nil then
        return false
    end
    -- A single temperature: this is the fluid's only way in
    local prenodes = real_prenodes(graph, fluid_node)
    if #prenodes ~= 1 or gutils.key(prenodes[1]) ~= gutils.key(node) then
        return false
    end
    local has_position_maker = false
    for _, prenode in pairs(real_prenodes(graph, node)) do
        if prenode.type == "fluid-create-temperature" then
            for _, maker in pairs(real_prenodes(graph, prenode)) do
                local is_resource = maker.type == "entity-mine" and (data.raw.resource or {})[maker.name] ~= nil
                if maker.type == "fluid-craft-temperature" then
                    -- The logic makes this node for every fluid; only one some recipe feeds counts
                    if next(maker.pre) ~= nil then
                        has_position_maker = true
                    end
                elseif is_resource then
                    has_position_maker = true
                else
                    return false
                end
            end
        elseif prenode.type ~= "fluid-hold" then
            return false
        end
    end
    return has_position_maker
end

-- Whether a position's roles suit an identity of a form, checked on a slot of first pass's split graph (the identity's edges are on the trav, so what's left on the slot is the position)
-- Recipes take and make either form (their crafters need fluid boxes for a fluid, see recipe_category_key), and resources are mined into either (a drill drops items or fills its output box, see fluid_ports.fit_mining_drills)
-- Everything else at an item position gives items only: loot (entity-kill), what spoils into it (item), burnt results (item-burn), asteroid chunks (asteroid-chunk-mine), mining anything but a resource (rocks, plants), and whatever replaces coal fuels burners (its fuel edge, see dutils.replacement_gets_fuel); tiles and buildings are mined by name and belong to the identity already (dutils.mining_keeps_item_names)
-- A fluid position's makers are recipes and resources (fluid_slot_ok, once pumping moved to the identity), and pipes hold it (fluid-hold), which an item doesn't need and doesn't mind
-- Starting items are given by position too (control.lua), which the data stage can't see, so control.lua keeps the item when a fluid is there
item_fluid.position_takes = function(graph, slot, form)
    local position = item_fluid.material_of_node(graph, slot)
    if position == nil then
        return false
    end
    if position.type == form then
        return true
    end
    if position.type == "item" then
        for _, prenode in pairs(real_prenodes(graph, slot)) do
            if prenode.type == "entity-mine" then
                if (data.raw.resource or {})[prenode.name] == nil then
                    return false
                end
            elseif prenode.type ~= "item-craft" and prenode.type ~= "recipe" then
                return false
            end
        end
        for _, dep in pairs(real_deps(graph, slot)) do
            if dep.node.type ~= "recipe" and dep.node.trav == nil then
                return false
            end
        end
        return true
    end
    for _, prenode in pairs(real_prenodes(graph, slot)) do
        if prenode.type == "fluid-create-temperature" then
            for _, maker in pairs(real_prenodes(graph, prenode)) do
                local is_resource = maker.type == "entity-mine" and (data.raw.resource or {})[maker.name] ~= nil
                if maker.type ~= "fluid-craft-temperature" and maker.type ~= "recipe" and not is_resource then
                    return false
                end
            end
        elseif prenode.type ~= "fluid-hold" then
            return false
        end
    end
    for _, dep in pairs(real_deps(graph, slot)) do
        if dep.node.type ~= "fluid-temperature-range" and dep.node.trav == nil then
            return false
        end
    end
    return true
end

----------------------------------------------------------------------------------------------------
-- Containers
----------------------------------------------------------------------------------------------------

-- Items that hold a fluid, like the barrels base makes for every fluid (base/data-updates.lua): an item that a recipe fills (one fluid and one item in, only the item out) and another empties again (the item in, that fluid and that item out)
-- recipes: a recipe table to look in (old_data_raw.recipe: the game before unified randomization, whose round trips recipe randomization leaves alone)
-- Returns a list of { filled, held, vessel, fill, empty } (the filled item, the fluid, the empty container item, and the filling and emptying recipes, all by name), in a fixed order
item_fluid.fluid_containers = function(recipes)
    -- Entry type ("item" or "fluid") --> the names of a list's entries of that type
    local function names_by_type(list)
        local by_type = {}
        for _, entry in pairs(list or {}) do
            local entry_type = entry.type or "item"
            by_type[entry_type] = by_type[entry_type] or {}
            table.insert(by_type[entry_type], entry.name)
        end
        return by_type
    end
    local function names(by_type, entry_type)
        return by_type[entry_type] or {}
    end
    -- Filled item name --> its filling recipes, as { fill, held, vessel }
    local fills = {}
    for recipe_name, recipe in pairs(recipes) do
        local ins = names_by_type(recipe.ingredients)
        local outs = names_by_type(recipe.results)
        local fluids_in = names(ins, "fluid")
        local items_in = names(ins, "item")
        local items_out = names(outs, "item")
        if #fluids_in == 1 and #items_in == 1 and #items_out == 1 and #names(outs, "fluid") == 0 and items_out[1] ~= items_in[1] then
            fills[items_out[1]] = fills[items_out[1]] or {}
            table.insert(fills[items_out[1]], {
                fill = recipe_name,
                held = fluids_in[1],
                vessel = items_in[1],
            })
        end
    end
    local containers = {}
    for recipe_name, recipe in pairs(recipes) do
        local ins = names_by_type(recipe.ingredients)
        local outs = names_by_type(recipe.results)
        local items_in = names(ins, "item")
        local fluids_out = names(outs, "fluid")
        local items_out = names(outs, "item")
        if #items_in == 1 and #names(ins, "fluid") == 0 and #fluids_out == 1 and #items_out == 1 then
            for _, fill in pairs(fills[items_in[1]] or {}) do
                if fill.held == fluids_out[1] and fill.vessel == items_out[1] then
                    table.insert(containers, {
                        filled = items_in[1],
                        held = fill.held,
                        vessel = fill.vessel,
                        fill = fill.fill,
                        empty = recipe_name,
                    })
                end
            end
        end
    end
    table.sort(containers, function(a, b)
        if a.filled ~= b.filled then
            return a.filled < b.filled
        end
        if a.fill ~= b.fill then
            return a.fill < b.fill
        end
        return a.empty < b.empty
    end)
    return containers
end

-- The filled items of the containers, as item name --> true: first pass leaves their positions alone, so a barrel is always for its fluid (user, 2026-09-29)
item_fluid.container_items = function(containers)
    local items = {}
    for _, container in pairs(containers) do
        items[container.filled] = true
    end
    return items
end

-- The containers' recipes by the fluid they hold, as fluid name --> { fill = { recipe name --> true }, empty = { recipe name --> true } }: they follow the fluid's identity (see move_identity_sources)
item_fluid.container_recipes = function(containers)
    local recipes = {}
    for _, container in pairs(containers) do
        recipes[container.held] = recipes[container.held] or {
            fill = {},
            empty = {},
        }
        recipes[container.held].fill[container.fill] = true
        recipes[container.held].empty[container.empty] = true
    end
    return recipes
end

----------------------------------------------------------------------------------------------------
-- The split graph
----------------------------------------------------------------------------------------------------

-- Moves the makers and users of a fluid that belong to its identity off its position, once first pass split the slot (the fluid-temperature node) from its trav
-- Pumping it from tiles or filtered offshore pumps (fluid-create-offshore-temperature; not on a slot since fluid_slot_ok keeps pumped fluids in place, but handled the same for the sake of the rule) and emptying its barrels (its containers' emptying recipes) are ways to the identity: they feed a fluid-identity-source node the trav needs (OR, next to the head from the position), instead of the position's fluid-create-temperature and fluid-craft-temperature nodes
-- Filling its barrels takes the identity: the filling recipes take the trav instead of the position's fluid-temperature-range nodes
-- User, 2026-09-29: offshore pumps only reasonably output fluids, and barrels are always for their fluid
-- container_recipes: item_fluid.container_recipes of the game's containers
-- Returns the key of the source node, or nil if the identity has no makers of its own
item_fluid.move_identity_sources = function(graph, slot_key, trav_key, container_recipes)
    local slot = graph.nodes[slot_key]
    local material = item_fluid.material_of_node(graph, slot)
    if material == nil or material.type ~= "fluid" then
        return nil
    end
    local recipes = container_recipes[material.name] or {
        fill = {},
        empty = {},
    }
    local source_key
    local function source()
        if source_key == nil then
            local node = gutils.add_node(graph, "fluid-identity-source", graph.nodes[trav_key].name)
            node.op = "OR"
            source_key = gutils.key(node)
            if graph.node_to_orands ~= nil then
                graph.node_to_orands[source_key] = {}
            end
            -- The source is another way to the identity, next to the head from the position: the trav (an AND node as a fluid-temperature node, needing its position's makers and pipes, which stayed on the slot) becomes an OR node like an item trav, with the head and the source as direct prerequisites
            graph.nodes[trav_key].op = "OR"
            gutils.add_edge(graph, source_key, trav_key)
        end
        return source_key
    end
    -- An orand from a maker into one of the position's OR nodes feeds the source instead (gutils.make_orand's bookkeeping follows it)
    local function move_orand(orand_key, from_key)
        local edge_key = gutils.ekey({
            start = orand_key,
            stop = from_key,
        })
        gutils.redirect_edge_stop(graph, edge_key, source())
        if graph.node_to_orands ~= nil then
            graph.node_to_orands[from_key][orand_key] = nil
            graph.node_to_orands[source_key][orand_key] = true
            graph.orand_to_parent[orand_key] = source_key
        end
    end
    for pre, _ in pairs(table.deepcopy(slot.pre)) do
        local create = gutils.prenode(graph, pre)
        if create.type == "fluid-create-temperature" then
            for create_pre, _ in pairs(table.deepcopy(create.pre)) do
                local orand = gutils.prenode(graph, create_pre)
                if orand.type == "orand" then
                    local maker = gutils.unique_prenode(graph, orand)
                    if maker.type == "fluid-create-offshore-temperature" or (maker.type == "recipe" and recipes.empty[maker.name] ~= nil) then
                        move_orand(gutils.key(orand), gutils.key(create))
                    elseif maker.type == "fluid-craft-temperature" then
                        for craft_pre, _ in pairs(table.deepcopy(maker.pre)) do
                            local craft_orand = gutils.prenode(graph, craft_pre)
                            if craft_orand.type == "orand" then
                                local recipe = gutils.unique_prenode(graph, craft_orand)
                                if recipe.type == "recipe" and recipes.empty[recipe.name] ~= nil then
                                    move_orand(gutils.key(craft_orand), gutils.key(maker))
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    for _, dep in pairs(real_deps(graph, slot)) do
        if dep.node.type == "fluid-temperature-range" then
            for range_dep, _ in pairs(table.deepcopy(dep.node.dep)) do
                local recipe = gutils.depnode(graph, range_dep)
                if recipe.type == "recipe" and recipes.fill[recipe.name] ~= nil then
                    gutils.redirect_edge_start(graph, range_dep, trav_key)
                end
            end
        end
    end
    return source_key
end

-- The recipes and resources at a position of the split graph, as node key --> { node, makes, takes }: how many of the recipe's results (or the resource's) and ingredients the position is
-- Makers come through the position's craft node (item-craft, or fluid-create-temperature and fluid-craft-temperature) and direct recipe edges (recipes hidden from stats); users are the recipes the position or its temperature ranges feed
local function position_users(graph, slot)
    local users = {}
    local function add(node, field)
        local node_key = gutils.key(node)
        users[node_key] = users[node_key] or {
            node = node,
            makes = 0,
            takes = 0,
        }
        users[node_key][field] = users[node_key][field] + 1
    end
    local function add_makers(craft)
        for _, maker in pairs(real_prenodes(graph, craft)) do
            if maker.type == "recipe" or maker.type == "entity-mine" then
                add(maker, "makes")
            elseif maker.type == "fluid-craft-temperature" then
                add_makers(maker)
            end
        end
    end
    for _, prenode in pairs(real_prenodes(graph, slot)) do
        if prenode.type == "recipe" or prenode.type == "entity-mine" then
            add(prenode, "makes")
        elseif prenode.type == "item-craft" or prenode.type == "fluid-create-temperature" then
            add_makers(prenode)
        end
    end
    for _, dep in pairs(real_deps(graph, slot)) do
        if dep.node.type == "recipe" then
            add(dep.node, "takes")
        elseif dep.node.type == "fluid-temperature-range" then
            for _, range_dep in pairs(real_deps(graph, dep.node)) do
                if range_dep.node.type == "recipe" then
                    add(range_dep.node, "takes")
                end
            end
        end
    end
    return users
end

-- Fluid counts as { input, output }, plus what first pass accumulated on a node (fluid_delta, see rewire_form_change)
local function with_delta(fluids, delta)
    return {
        input = fluids.input + (delta ~= nil and delta.input or 0),
        output = fluids.output + (delta ~= nil and delta.output or 0),
    }
end

-- The recipe-category node a recipe needs with these fluid counts, keyed like the logic's (lutils.rcat_name): its categories, with hand crafting's traded for the fluid one when it has any fluid (the rule fix_fluid_crafting_categories applies to the game), then the counts
item_fluid.recipe_category_key = function(recipe, fluids)
    local cats = furnace_selection.recipe_categories(recipe)
    if fluids.input + fluids.output > 0 and fluid_ports.fluid_category_exists() then
        cats = fluid_ports.trade_hand_category(cats) or cats
    end
    return gutils.key("recipe-category", lutils.rcat_key(cats, fluids))
end

-- The resource-category node a resource needs with these fluid counts (a required fluid in, fluid results out), keyed like the logic's (lutils.mcat_name)
item_fluid.resource_category_key = function(resource, fluids)
    return gutils.key("resource-category", lutils.mcat_key(resource.category or "basic-solid", fluids))
end

-- The recycler's crafting category (lib/recycling.lua regenerates its recipes), whose recipes take and give items only
item_fluid.RECYCLING_CATEGORY = "recycling"

item_fluid.is_recycling_recipe = function(recipe)
    for _, cat in pairs(furnace_selection.recipe_categories(recipe)) do
        if cat == item_fluid.RECYCLING_CATEGORY then
            return true
        end
    end
    return false
end
local is_recycling_recipe = item_fluid.is_recycling_recipe

-- The category node a recipe or resource at a position needs once the position holds an identity of the other form, or nil for a recycling recipe (see rewire_form_change)
-- user: an entry of position_users; delta: 1 for a fluid identity at an item position, -1 for an item identity at a fluid position
local function category_key_after(user, delta)
    local node = user.node
    if node.type == "entity-mine" then
        local resource = data.raw.resource[node.name]
        local fluids = with_delta(lutils.find_mining_fluids(resource), node.fluid_delta)
        fluids.output = fluids.output + delta * user.makes
        return item_fluid.resource_category_key(resource, fluids)
    end
    local recipe = data.raw.recipe[node.name]
    if is_recycling_recipe(recipe) then
        return nil
    end
    local fluids = with_delta(lutils.find_recipe_fluids(recipe), node.fluid_delta)
    fluids.input = fluids.input + delta * user.takes
    fluids.output = fluids.output + delta * user.makes
    return item_fluid.recipe_category_key(recipe, fluids)
end

-- How many recipes take a position, recycling ones aside (with a fluid there they lead nowhere, see rewire_form_change)
-- A fluid at an item position is used through those recipes only, since an item's own roles (placing, equipping, fueling) go with the item identity, so a fluid at a position none takes is made and never used; first pass prefers positions some recipe takes for fluids (form_swaps candidates)
item_fluid.position_takers = function(graph, slot)
    local takers = 0
    for _, user in pairs(position_users(graph, slot)) do
        if user.takes > 0 and user.node.type == "recipe" then
            local recipe = data.raw.recipe[user.node.name]
            if recipe == nil or not is_recycling_recipe(recipe) then
                takers = takers + 1
            end
        end
    end
    return takers
end

-- Whether an identity may go to a position of the other form (first pass's cross_type_ok, on the split graph with no slot/trav connections): the position's roles suit the identity's form (position_takes), and every recipe and resource there still has a crafter or drill with its new fluid counts, that is, the logic has a category node for them (lib/lookup/2-simple/recipe.lua and mining.lua make one for each count a machine can serve, so a furnace with one fluid input can't take a recipe with two)
item_fluid.form_change_ok = function(graph, slot, trav)
    local position = item_fluid.material_of_node(graph, slot)
    local identity = item_fluid.material_of_node(graph, trav)
    if position == nil or identity == nil then
        return false
    end
    if position.type == identity.type then
        return true
    end
    if not item_fluid.position_takes(graph, slot, identity.type) then
        return false
    end
    local delta = identity.type == "fluid" and 1 or -1
    for _, user in pairs(position_users(graph, slot)) do
        local target = category_key_after(user, delta)
        if target ~= nil and graph.nodes[target] == nil then
            return false
        end
    end
    return true
end

-- The logic's false node (an OR node with no prerequisites, lib/logic/abstract.lua), made if the graph has none
local function false_key(graph)
    local node_key = gutils.key("false", "")
    if graph.nodes[node_key] == nil then
        local node = gutils.add_node(graph, "false", "")
        node.op = "OR"
    end
    return node_key
end

-- An AND node (a recipe) that needs the false node can't be reached
local function make_unreachable(graph, node_key)
    local edge_key = gutils.ekey({
        start = false_key(graph),
        stop = node_key,
    })
    if graph.edges[edge_key] == nil then
        gutils.add_edge(graph, false_key(graph), node_key)
    end
end

-- Takes an orand out of the graph with its two edges and gutils.make_orand's bookkeeping, so its maker no longer feeds the OR node (an orand keeps exactly one prerequisite, so it can't just need the false node)
local function remove_orand(graph, orand_key)
    local orand = graph.nodes[orand_key]
    for pre, _ in pairs(table.deepcopy(orand.pre)) do
        gutils.remove_edge(graph, pre)
    end
    for dep, _ in pairs(table.deepcopy(orand.dep)) do
        local parent_key = graph.edges[dep].stop
        gutils.remove_edge(graph, dep)
        if graph.node_to_orands ~= nil and graph.node_to_orands[parent_key] ~= nil then
            graph.node_to_orands[parent_key][orand_key] = nil
        end
    end
    if graph.orand_to_parent ~= nil then
        graph.orand_to_parent[orand_key] = nil
        graph.orand_to_child[orand_key] = nil
    end
    graph.nodes[orand_key] = nil
    graph.sources[orand_key] = nil
end

-- Rewires the split graph for a pair of different forms, once monotone matching connected it (first pass's connect_extra, on a copy of the graph per matching)
-- The recipes at the position take or make the identity's form now, so each needs the recipe-category of its new fluid counts (see recipe_category_key; several positions of one recipe can change, so the node carries the counts it gained as fluid_delta), and a resource mined into the position needs the resource-category of its counts
-- A recycler takes and gives items only (lib/recycling.lua drops fluid ingredients when it regenerates recycling recipes), so with a fluid at the position its recycling recipes lead nowhere: the recycling recipe taking it needs the false node, and a recycling recipe making it loses its orand into the position's item-craft node
-- A recipe left without a category node (two fluids on one furnace, which form_change_ok keeps from happening one pair at a time) leads nowhere too, so the matching's gate sees it
item_fluid.rewire_form_change = function(graph, slot_key, trav_key)
    local slot = graph.nodes[slot_key]
    local position = item_fluid.material_of_node(graph, slot)
    local identity = item_fluid.material_of_node(graph, graph.nodes[trav_key])
    if position == nil or identity == nil or position.type == identity.type then
        return
    end
    local delta = identity.type == "fluid" and 1 or -1
    for node_key, user in pairs(position_users(graph, slot)) do
        local node = user.node
        local target = category_key_after(user, delta)
        if target == nil then
            -- A recycling recipe: taking the position leads nowhere, and so does making it
            if user.takes > 0 then
                make_unreachable(graph, node_key)
            end
            if user.makes > 0 then
                for _, prenode in pairs(real_prenodes(graph, slot)) do
                    if prenode.type == "item-craft" then
                        for pre, _ in pairs(table.deepcopy(prenode.pre)) do
                            local orand = gutils.prenode(graph, pre)
                            if orand.type == "orand" and gutils.key(real_prenode(graph, orand)) == node_key then
                                remove_orand(graph, gutils.key(orand))
                            end
                        end
                    end
                end
            end
        else
            node.fluid_delta = node.fluid_delta or {
                input = 0,
                output = 0,
            }
            node.fluid_delta.input = node.fluid_delta.input + delta * user.takes
            node.fluid_delta.output = node.fluid_delta.output + delta * user.makes
            local category_type = node.type == "entity-mine" and "resource-category" or "recipe-category"
            -- The category edge, or the edge into the vanilla base of its head when another handler randomizes it (the fallback the head keeps, see promotion.new; the recipe-category handler's validate counts fluid_delta itself)
            local category_edge
            for pre, _ in pairs(node.pre) do
                local prenode = gutils.prenode(graph, pre)
                if prenode.type == category_type then
                    category_edge = pre
                elseif prenode.type == "head" and prenode.old_base ~= nil and graph.nodes[prenode.old_base] ~= nil then
                    for base_pre, _ in pairs(graph.nodes[prenode.old_base].pre) do
                        if gutils.prenode(graph, base_pre).type == category_type then
                            category_edge = base_pre
                        end
                    end
                end
            end
            if category_edge == nil then
                error("First pass: " .. node_key .. " has no " .. category_type .. " to change for " .. identity.name .. " at " .. position.name .. "'s position")
            end
            if graph.nodes[target] ~= nil then
                gutils.redirect_edge_start(graph, category_edge, target)
            else
                log("First pass: no " .. target .. " for " .. node_key .. " with " .. identity.name .. " at " .. position.name .. "'s position, so it leads nowhere")
                make_unreachable(graph, node_key)
            end
        end
    end
end

----------------------------------------------------------------------------------------------------
-- The final game
----------------------------------------------------------------------------------------------------

-- The key a node of the original game's logic has in the final game's, given renames: position material key --> the identity reflection put there, as {type, name} (UNIFIED_MATERIAL_RENAMES, set by item reflection)
-- A node named after a material is named after the identity at its position in the final game, which is how checks compare the two games (see skeleton/check.lua)
-- Which nodes those are comes from where logic builds them: a node type built for items or fluids has that class as its canonical type (type_info, see lib/logic/builder.lua), and its name is the material's name, maybe followed by a temperature or temperature range
-- A fluid is made at its own default temperature wherever it goes (reflection drops the position's fixed temperatures)
-- A position holding an identity of the other form has no node of its own type in the final game (the identity's chain replaces it), so its key stays as it is; the checks skip item and fluid chain nodes, and no mechanic node is named after such a position
item_fluid.final_node_key = function(node_key, renames, type_info)
    if renames == nil then
        return node_key
    end
    local node = gutils.deconstruct(node_key)
    local material_type = (type_info[node.type] or {}).canonical
    if material_type ~= "item" and material_type ~= "fluid" then
        return node_key
    end
    local material_name = node.name
    local suffix
    if string.find(node.name, ": ", 1, true) ~= nil then
        local parts = gutils.deconstruct(node.name)
        material_name = parts.type
        suffix = parts.name
    end
    local identity = renames[gutils.key(material_type, material_name)]
    if identity == nil or identity.type ~= material_type then
        return node_key
    end
    if suffix == nil then
        return gutils.key(node.type, identity.name)
    end
    -- A single temperature (a number, unlike a range) is the identity's own
    if tonumber(suffix) ~= nil and identity.name ~= material_name then
        local fluid = (data.raw.fluid or {})[identity.name]
        if fluid ~= nil and fluid.default_temperature ~= nil then
            suffix = tostring(fluid.default_temperature)
        end
    end
    return gutils.key(node.type, gutils.key(identity.name, suffix))
end

return item_fluid

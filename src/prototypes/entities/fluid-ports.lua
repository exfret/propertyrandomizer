-- Machines taking whatever fluids randomization gives them: extra fluid boxes on crafting machines, mining drills fit for what their resources give, and hand crafting categories leaving recipes with fluids

local categories = require("src/prototypes/categories")
local dutils = require("src/prototypes/data-utils")
local furnace_selection = require("src/prototypes/entities/furnace-selection")
local pipe_conns = require("src/prototypes/entities/pipe-conns")

local fluid_ports = {}

-- Pipe connection points each crafting machine keeps free: one, for a fluid energy source's input (user, 2026-09-29)
fluid_ports.RESERVED_POINTS = 1

-- A recipe with a fluid can't be crafted by hand (CharacterPrototype has no fluid boxes), so it trades this category for the one below, as pypostprocessing's add_ingredient does (lib/metas/recipe.lua) (user's rule, 2026-09-26)
fluid_ports.HAND_CATEGORY = "crafting"
fluid_ports.HAND_CATEGORY_WITH_FLUID = "crafting-with-fluid"

local function sorted_names(tbl)
    local names = {}
    for name, _ in pairs(tbl) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

-- The most ingredients and results of any recipe a machine can craft (only its fixed recipe, if it has one), which bound how many fluids a recipe there can have
local function recipe_sizes(machine)
    local most_ingredients = 0
    local most_results = 0
    local function count(recipe)
        most_ingredients = math.max(most_ingredients, #(recipe.ingredients or {}))
        most_results = math.max(most_results, #(recipe.results or {}))
    end
    if machine.fixed_recipe ~= nil and data.raw.recipe[machine.fixed_recipe] ~= nil then
        count(data.raw.recipe[machine.fixed_recipe])
        return most_ingredients, most_results
    end
    local crafts = {}
    for _, cat in pairs(machine.crafting_categories or {}) do
        crafts[cat] = true
    end
    for _, recipe in pairs(data.raw.recipe) do
        for _, cat in pairs(furnace_selection.recipe_categories(recipe)) do
            if crafts[cat] ~= nil then
                count(recipe)
                break
            end
        end
    end
    return most_ingredients, most_results
end

-- A fluid box to copy pipe pictures, covers and draw orders from: the machine's own first one, or else the first crafting machine box with pipe pictures (by type and name, so the same one every time)
local function template_box(machine)
    for _, box in pairs(machine.fluid_boxes or {}) do
        return box
    end
    for _, class in pairs(sorted_names(categories.crafting_machines)) do
        for _, name in pairs(sorted_names(dutils.prots(class))) do
            for _, box in pairs(dutils.prots(class)[name].fluid_boxes or {}) do
                if box.pipe_picture ~= nil then
                    return box
                end
            end
        end
    end
    return nil
end

-- Free points in an order that goes around the machine's sides in turn, so boxes spread out and the points left over are spread too
local function spread_points(points)
    local by_direction = {}
    local directions = {}
    for _, point in pairs(points) do
        if by_direction[point.direction] == nil then
            by_direction[point.direction] = {}
            table.insert(directions, point.direction)
        end
        table.insert(by_direction[point.direction], point)
    end
    table.sort(directions)
    local ordered = {}
    local i = 1
    while #ordered < #points do
        for _, direction in pairs(directions) do
            local point = by_direction[direction][i]
            if point ~= nil then
                table.insert(ordered, point)
            end
        end
        i = i + 1
    end
    return ordered
end

-- Which way each new box goes: inputs and outputs up to the most ingredients and results a recipe there has (the one with the bigger shortfall first), then alternating from input
-- Furnaces pick their recipe by one ingredient, so they only ever use one fluid input (auxiliary/furnace-recipe-selection.html in the API docs: only recipes with a single item ingredient, a single fluid ingredient, or one of each)
-- Returns a list of "input"/"output", one per new box
fluid_ports.box_directions = function(num_new, num_in, num_out, want_in, want_out, is_furnace)
    local directions = {}
    local next_extra = "input"
    for _ = 1, num_new do
        local in_short = want_in - num_in
        local out_short = want_out - num_out
        local direction
        if is_furnace and num_in >= 1 then
            direction = "output"
        elseif in_short > 0 and in_short >= out_short then
            direction = "input"
        elseif out_short > 0 then
            direction = "output"
        else
            direction = next_extra
            if next_extra == "input" then
                next_extra = "output"
            else
                next_extra = "input"
            end
        end
        if direction == "input" then
            num_in = num_in + 1
        else
            num_out = num_out + 1
        end
        table.insert(directions, direction)
    end
    return directions
end

-- The pipe connection a fluid box keeps when it keeps one: its first adjacent one (connection_type "normal", the default; types/PipeConnectionDefinition.html), or else its first
local function kept_connection(box)
    for _, connection in pairs(box.pipe_connections or {}) do
        if connection.connection_type == nil or connection.connection_type == "normal" then
            return connection
        end
    end
    return (box.pipe_connections or {})[1]
end

-- Makes a crafting machine's ports go unseen until used, as py-randomized-preview's prefixes.lua does for its assembling machines:
--   - every fluid box keeps one pipe connection, so the tiles the others took are free for more boxes
--   - every fluid box is only drawn when something connects to it (FluidBox::draw_only_when_connected)
--   - an assembling machine's boxes are off while its recipe has no fluid (AssemblingMachinePrototype::fluid_boxes_off_when_no_fluid_recipe; furnaces don't have it, so theirs stay on)
-- Returns how many pipe connections were dropped
fluid_ports.hide_unused_ports = function(machine)
    local num_dropped = 0
    for _, box in pairs(machine.fluid_boxes or {}) do
        local kept = kept_connection(box)
        if kept ~= nil then
            num_dropped = num_dropped + #box.pipe_connections - 1
            box.pipe_connections = { kept }
        end
        box.draw_only_when_connected = true
    end
    if machine.type == "assembling-machine" or machine.type == "rocket-silo" then
        machine.fluid_boxes_off_when_no_fluid_recipe = true
    end
    return num_dropped
end

-- Gives every crafting machine as many input and output fluid boxes as its free pipe connection points allow, keeping RESERVED_POINTS points free
-- A point is one side of a free edge tile, one per tile (see pipe_conns.get_possible_pipe_connections)
-- Ports go unseen until used (see hide_unused_ports), the machine's own included: they keep one connection each first, so what they gave up counts as free
fluid_ports.add_crafting_machine_ports = function()
    for _, class in pairs(sorted_names(categories.crafting_machines)) do
        for _, name in pairs(sorted_names(dutils.prots(class))) do
            local machine = dutils.prots(class)[name]
            if machine.crafting_categories ~= nil then
                local num_dropped = fluid_ports.hide_unused_ports(machine)
                local template = template_box(machine)
                local free = pipe_conns.get_available_pipe_connections(machine)
                local num_new = #free - fluid_ports.RESERVED_POINTS
                if template ~= nil and num_new > 0 then
                    local num_in = 0
                    local num_out = 0
                    for _, box in pairs(machine.fluid_boxes or {}) do
                        if box.production_type == "input" then
                            num_in = num_in + 1
                        elseif box.production_type == "output" then
                            num_out = num_out + 1
                        end
                    end
                    local want_in, want_out = recipe_sizes(machine)
                    local points = spread_points(free)
                    local template_connection = (template.pipe_connections or {})[1] or {}
                    machine.fluid_boxes = machine.fluid_boxes or {}
                    for i, direction in pairs(fluid_ports.box_directions(num_new, num_in, num_out, want_in, want_out, machine.type == "furnace")) do
                        local box = table.deepcopy(template)
                        box.production_type = direction
                        box.filter = nil
                        box.volume = template.volume or 1000
                        box.draw_only_when_connected = true
                        box.pipe_connections = {
                            {
                                flow_direction = direction,
                                direction = points[i].direction,
                                position = points[i].position,
                                connection_category = template_connection.connection_category,
                            },
                        }
                        table.insert(machine.fluid_boxes, box)
                    end
                    local num_all_in = 0
                    for _, box in pairs(machine.fluid_boxes) do
                        if box.production_type == "input" then
                            num_all_in = num_all_in + 1
                        end
                    end
                    log("Fluid ports: " .. name .. " has " .. num_all_in .. " inputs and " .. (#machine.fluid_boxes - num_all_in) .. " other boxes (" .. num_new .. " new, " .. num_dropped .. " connections dropped), for recipes of up to " .. want_in .. " ingredients and " .. want_out .. " results")
                elseif num_dropped > 0 then
                    log("Fluid ports: " .. name .. " keeps one connection per fluid box (" .. num_dropped .. " dropped) and has no room for new boxes")
                end
            end
        end
    end
end

-- Numbers a recipe's fluids so each uses exactly one of its machine's fluid boxes and the boxes left over stay closed, as vanilla basic oil processing does on the refinery (base/prototypes/recipe.lua): ingredients count the input boxes from 1, results the output boxes (FluidIngredientPrototype::fluidbox_index, which is separate for inputs and outputs)
-- Without a number, a fluid is offered on every box of its kind, so a machine with many ports shows them all; py-randomized-preview's recipes carry these numbers
-- Returns how many recipes changed
fluid_ports.index_recipe_fluids = function()
    local num_changed = 0
    for _, recipe in pairs(data.raw.recipe) do
        local changed = false
        for _, list in pairs({ recipe.ingredients or {}, recipe.results or {} }) do
            local index = 0
            for _, entry in pairs(list) do
                if entry.type == "fluid" then
                    index = index + 1
                    if entry.fluidbox_index ~= index then
                        entry.fluidbox_index = index
                        changed = true
                    end
                end
            end
        end
        if changed then
            num_changed = num_changed + 1
        end
    end
    return num_changed
end

-- The results a resource gives and whether it needs a fluid, as { item = bool, fluid = bool, required_fluid = bool }
local function resource_needs(resource)
    local needs = {}
    for _, result in pairs(dutils.minable_results(resource)) do
        needs[result.type] = true
    end
    if resource.minable ~= nil and resource.minable.required_fluid ~= nil then
        needs.required_fluid = true
    end
    return needs
end

-- A fluid box for a mining drill at a free pipe connection point, or nil if there's none
local function drill_box(drill, production_type)
    local free = pipe_conns.get_available_pipe_connections(drill)
    if #free == 0 then
        return nil
    end
    return {
        volume = 200,
        production_type = production_type,
        pipe_connections = {
            {
                flow_direction = production_type,
                direction = free[1].direction,
                position = free[1].position,
            },
        },
    }
end

-- Makes every mining drill able to put out what the resources of its categories give: an output fluid box for fluid results, a place for item results (vector_to_place_result, which is {0, 0} on drills like pumpjacks that only put out fluids), and an input fluid box for a required fluid
-- With both_forms, every drill gets the output box (where a pipe connection point is free) and the place for items whatever its resources give: with items and fluids trading positions a pumpjack drops items and an electric mining drill fills a pipe (user, 2026-09-29), and prefixes.lua does this before the logic looks at drills (src/prototypes/lookup/2-simple/mining.lua)
-- A drill without vector_to_place_result halts on an item result (prototypes/MiningDrillPrototype.html)
-- prefixes.lua already gives every drill an input fluid box
-- Returns how many drills changed
fluid_ports.fit_mining_drills = function(both_forms)
    local num_changed = 0
    for _, name in pairs(sorted_names(dutils.prots("mining-drill"))) do
        local drill = data.raw["mining-drill"][name]
        local mines = {}
        for _, cat in pairs(drill.resource_categories or {}) do
            mines[cat] = true
        end
        local needs = {}
        if both_forms then
            needs.item = true
            needs.fluid = true
        end
        for _, resource in pairs(dutils.prots("resource")) do
            if mines[resource.category or "basic-solid"] ~= nil then
                for need, _ in pairs(resource_needs(resource)) do
                    needs[need] = true
                end
            end
        end
        local changed = false
        if needs.fluid ~= nil and drill.output_fluid_box == nil then
            drill.output_fluid_box = drill_box(drill, "output")
            changed = drill.output_fluid_box ~= nil
        end
        if needs.required_fluid ~= nil and drill.input_fluid_box == nil then
            drill.input_fluid_box = drill_box(drill, "input")
            changed = changed or drill.input_fluid_box ~= nil
        end
        local vector = drill.vector_to_place_result
        if needs.item ~= nil and (vector == nil or ((vector.x or vector[1] or 0) == 0 and (vector.y or vector[2] or 0) == 0)) then
            -- Just past the drill's north edge, as for drills that make items
            local top = drill.collision_box[1].y or drill.collision_box[1][2]
            drill.vector_to_place_result = { 0, top - 0.35 }
            changed = true
        end
        if changed then
            num_changed = num_changed + 1
        end
    end
    return num_changed
end

-- Whether a recipe takes or makes a fluid
fluid_ports.has_fluid = function(recipe)
    for _, list in pairs({ recipe.ingredients or {}, recipe.results or {} }) do
        for _, entry in pairs(list) do
            if entry.type == "fluid" then
                return true
            end
        end
    end
    return false
end

-- Whether the game has the fluid crafting category to trade hand crafting's for (fix_fluid_crafting_categories and first pass's model only trade when it does)
fluid_ports.fluid_category_exists = function()
    return data.raw["recipe-category"] ~= nil and data.raw["recipe-category"][fluid_ports.HAND_CATEGORY_WITH_FLUID] ~= nil
end

-- A category list with hand crafting's category traded for the fluid one (see HAND_CATEGORY), or nil if it has no hand crafting category
-- Other categories stay, like vanilla Space Age's {"crafting-with-fluid", "electromagnetics"} recipes
-- First pass's model uses the same rule for a recipe that gets a fluid (item_fluid.recipe_category_key), and fix_fluid_crafting_categories applies it to the game
fluid_ports.trade_hand_category = function(cats)
    local has_hand = false
    for _, cat in pairs(cats) do
        if cat == fluid_ports.HAND_CATEGORY then
            has_hand = true
        end
    end
    if not has_hand then
        return nil
    end
    local new_cats = {}
    local seen = {}
    for _, cat in pairs(cats) do
        local new_cat = cat
        if cat == fluid_ports.HAND_CATEGORY then
            new_cat = fluid_ports.HAND_CATEGORY_WITH_FLUID
        end
        if not seen[new_cat] then
            seen[new_cat] = true
            table.insert(new_cats, new_cat)
        end
    end
    return new_cats
end

-- The categories a recipe has once hand crafting's category is traded for the fluid one (see trade_hand_category), or nil if nothing changes
fluid_ports.categories_with_fluid = function(recipe)
    if not fluid_ports.has_fluid(recipe) then
        return nil
    end
    return fluid_ports.trade_hand_category(furnace_selection.recipe_categories(recipe))
end

-- Applies categories_with_fluid to every recipe, if the fluid category exists; returns how many recipes changed
fluid_ports.fix_fluid_crafting_categories = function()
    if not fluid_ports.fluid_category_exists() then
        return 0
    end
    local num_changed = 0
    for _, recipe in pairs(data.raw.recipe) do
        local new_cats = fluid_ports.categories_with_fluid(recipe)
        if new_cats ~= nil then
            recipe.categories = new_cats
            num_changed = num_changed + 1
        end
    end
    return num_changed
end

-- The categories a pipe connection joins (types/PipeConnectionDefinition.html: connection_category, one name or a list, "default" when not given); a linked connection only joins its linked partner, so none
local function connection_categories(connection)
    if connection.connection_type == "linked" then
        return {}
    end
    local category = connection.connection_category or "default"
    if type(category) ~= "table" then
        return { category }
    end
    return category
end

-- Adds the categories of a fluid box's pipe connections to a set
local function add_categories(set, box)
    for _, connection in pairs(box.pipe_connections) do
        for _, category in pairs(connection_categories(connection)) do
            set[category] = true
        end
    end
end

-- Every fluid box of a prototype (a table with pipe_connections, types/FluidBox.html): its fields, and the tables in them, like a crafting machine's fluid_boxes or an energy source's fluid_box
local function fluid_boxes_of(prototype)
    local boxes = {}
    local function visit(value, depth)
        if type(value) ~= "table" then
            return
        end
        if type(value.pipe_connections) == "table" then
            table.insert(boxes, value)
        elseif depth > 0 then
            for _, sub in pairs(value) do
                visit(sub, depth - 1)
            end
        end
    end
    for _, value in pairs(prototype) do
        visit(value, 1)
    end
    return boxes
end

-- Fluids no crafting machine can ever take in, by name (sorted)
-- Pipe connections only join when they share a category (types/PipeConnectionDefinition.html, connection_category), and fluid gets from what makes it to a crafting machine's input box directly or through boxes that pass it on (pipes, and boxes like a boiler's water input, input-output); a filtered box only passes on its fluid
-- What makes a fluid: crafting machines' output boxes (recipe results), offshore pumps (tile fluids), the drills mining a resource that gives it (their output_fluid_box), and output boxes filtered to it (a boiler's steam)
-- Fusion plasma is one: only the fusion reactor makes it, into connections of a category only fusion generators share
-- Hidden entities don't count, since players can't build them (the editor's infinity pipe joins every category); a fluid nothing makes counts as one, since nothing could deliver it
fluid_ports.fluids_crafters_cannot_take = function()
    local function visible_prots(class)
        local prots = {}
        for _, name in pairs(sorted_names(dutils.prots(class))) do
            local prot = dutils.prots(class)[name]
            if prot.hidden ~= true then
                table.insert(prots, prot)
            end
        end
        return prots
    end

    -- Categories crafting machines take fluids in through and put them out through
    local crafter_in = {}
    local crafter_out = {}
    for _, class in pairs(sorted_names(categories.crafting_machines)) do
        for _, machine in pairs(visible_prots(class)) do
            for _, box in pairs(machine.fluid_boxes or {}) do
                if box.production_type == "input" or box.production_type == "input-output" then
                    add_categories(crafter_in, box)
                end
                if box.production_type == "output" or box.production_type == "input-output" then
                    add_categories(crafter_out, box)
                end
            end
        end
    end

    -- Boxes of every other entity that pass fluid on, with their filters, and the categories each fluid comes out of entities' boxes filtered to it
    local bridges = {}
    local filtered_out = {}
    for _, class in pairs(sorted_names(defines.prototypes.entity)) do
        if categories.crafting_machines[class] == nil then
            for _, entity in pairs(visible_prots(class)) do
                for _, box in pairs(fluid_boxes_of(entity)) do
                    if box.production_type == nil or box.production_type == "none" or box.production_type == "input-output" then
                        local bridge = {
                            categories = {},
                            filter = box.filter,
                        }
                        add_categories(bridge.categories, box)
                        table.insert(bridges, bridge)
                    elseif box.production_type == "output" and box.filter ~= nil then
                        filtered_out[box.filter] = filtered_out[box.filter] or {}
                        add_categories(filtered_out[box.filter], box)
                    end
                end
            end
        end
    end

    -- fluid name --> the categories it comes out of whatever makes it
    local sources = {}
    local function add_source(fluid_name, source_categories)
        sources[fluid_name] = sources[fluid_name] or {}
        for category, _ in pairs(source_categories) do
            sources[fluid_name][category] = true
        end
    end
    for _, recipe in pairs(data.raw.recipe or {}) do
        for _, result in pairs(recipe.results or {}) do
            if result.type == "fluid" then
                add_source(result.name, crafter_out)
            end
        end
    end
    local pumped = {}
    for _, pump in pairs(visible_prots("offshore-pump")) do
        for _, box in pairs(fluid_boxes_of(pump)) do
            add_categories(pumped, box)
        end
    end
    for _, tile in pairs(dutils.prots("tile")) do
        if tile.fluid ~= nil then
            add_source(tile.fluid, pumped)
        end
    end
    local drills = visible_prots("mining-drill")
    for _, resource in pairs(dutils.prots("resource")) do
        local category = resource.category or "basic-solid"
        for _, result in pairs(dutils.minable_results(resource)) do
            if result.type == "fluid" then
                local drilled = {}
                for _, drill in pairs(drills) do
                    if drill.output_fluid_box ~= nil then
                        for _, drill_category in pairs(drill.resource_categories or {}) do
                            if drill_category == category then
                                add_categories(drilled, drill.output_fluid_box)
                            end
                        end
                    end
                end
                add_source(result.name, drilled)
            end
        end
    end
    for fluid_name, out_categories in pairs(filtered_out) do
        add_source(fluid_name, out_categories)
    end

    local fluid_names = {}
    for _, fluid_name in pairs(sorted_names(dutils.prots("fluid"))) do
        local fluid = dutils.prots("fluid")[fluid_name]
        -- Hidden and parameter fluids (like the editor's placeholder) are never offered anyway, so they're left out
        if fluid.hidden ~= true and fluid.parameter ~= true then
            -- Categories that lead into a crafting machine, growing through the boxes that pass this fluid on
            local reach = table.deepcopy(crafter_in)
            local grew = true
            while grew do
                grew = false
                for _, bridge in pairs(bridges) do
                    if bridge.filter == nil or bridge.filter == fluid_name then
                        local joins = false
                        for category, _ in pairs(bridge.categories) do
                            if reach[category] ~= nil then
                                joins = true
                            end
                        end
                        if joins then
                            for category, _ in pairs(bridge.categories) do
                                if reach[category] == nil then
                                    reach[category] = true
                                    grew = true
                                end
                            end
                        end
                    end
                end
            end
            local delivered = false
            for category, _ in pairs(sources[fluid_name] or {}) do
                if reach[category] ~= nil then
                    delivered = true
                end
            end
            if not delivered then
                table.insert(fluid_names, fluid_name)
            end
        end
    end
    return fluid_names
end

return fluid_ports

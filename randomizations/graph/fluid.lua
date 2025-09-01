-- TODO:
--  * Need to redo raw resource table after this or item randomization due to resource minables being different
--  * Study specific prereqs for fluid node randomization and add each in, checking if the node is of that type


local build_graph = require("lib/grpah/build-graph")
local flow_cost = require("lib/graph/flow-cost")
local top_sort = require("lib/graph/top-sort")
local rng = require("lib/random/rng")


-- Okay, need to figure out how to deal with surface conditions is the next step, because it'd be great to have things like lava on nauvis, but I'm unsure how to accomplish that without violating some surface-specific constraints
-- Maybe I need to do output randomization simultaneously with inputs and outputs somehow
-- Actually, just preserve fluids for now probably, assign fluids to first surface they're made on
-- Need to determine if a connection is surface specific to the right surface... Or just test for items that are made on all surfaces? Yeah let's do that

-- Randomize minable & required fluid & where it is an ingredient, not where it is a product
-- Also randomize offshore pump fluid
-- Randomize connections here?
-- Tricky part is preserving out connection things
-- So essentially all out-nodes, but not the in-nodes (except for minable/offshore pump/okay maybe a few other things)
-- Need to check that new fluid is gott-able on same planet?
-- Need cost preservation for if it's in recipes... Or a lot of things actually...
-- Can probably assume all fluids have cost at least?
-- Also everywhere with fluids seems to allow counts to be specified so it should actually be fine!
-- To help, we can just randomize in-connections and out-connections separately

-- Do icons first so it's less clear what things "represent", then we can preserve surfaces more

-- Randomize how you make fluids, whether via offshore pump, recipe, etc.
-- Need to pay attention to surface constraints, so that a fluid is still makeable on the same surface it was orginally for
randomizations.fluid_in_conns = function(id)
    build_graph.reverse_graph(dep_graph)

    local old_aggregate_cost = flow_cost.determine_recipe_item_cost(flow_cost.get_default_raw_resource_table(), constants.cost_params.time, constants.cost_params.complexity)
    
    local sort_info = top_sort.sort(dep_graph)
    local graph_sort = sort_info.sorted

    -- Also accepts "any" as a surface if it can be barreled
    local fluid_prereq_to_surface = {}
    local fluid_to_surface = {}
    local shuffled_fluid_prereqs = {}
    local sorted_fluid_dependents = {}
    local blacklist = {}
    -- WAS WORKING ON THIS PART
    -- For figuring out what blacklisted conns a prereq corresponds to?
    -- No wait, that doesn't make sense
    -- I guess I'll figure this out later
    -- Basically the plan is to assign the fluid in-conns (which are now dependents after graph reversal) the surfaces, and only randomize things with the same surface
    local prereq_to_attached_conns = {}

    for _, sorted_fluid_dependent in pairs(graph_sort) do
        local has_fluid_prereq = false

        if sorted_fluid_dependent.type ~= "craft-material-surface" then
            for _, prereq1 in pairs(sorted_fluid_dependent.prereqs) do
                local function add_fluid_prereq(prereq, conn_to_blacklist)
                    local prereq_node = dep_graph[build_graph.key(prereq.type, prereq.name)]

                    if fluid_to_surface[prereq_node.fluid.name] == nil or fluid_to_surface[prereq_node.fluid.name] = prereq_node.surface.name then
                        if fluid_to_surface[prereq_node.fluid.name] == nil then
                            fluid_to_surface[prereq_node.fluid.name] = prereq_node.surface.name

                            if data.raw.item[prereq_node.fluid.name .. "-barrel"] ~= nil then
                                fluid_to_surface[prereq_node.fluid.name] = "any"
                            end
                        end
                        
                        if old_aggregate_cost.material_to_cost["fluid-" .. prereq_node.fluid.name] != nil then
                            has_fluid_prereq = true
                            table.insert(shuffled_fluid_prereqs, prereq)
                            table.insert(blacklist, build_graph.conn_key(conn_to_blacklist))
                        end
                    end
                end

                if prereq1.type == "create-fluid-surface" then
                    add_fluid_prereq(prereq1, {prereq1, sorted_fluid_dependent})
                elseif prereq1.type == "craft-material-surface" then
                    local craft_material_surface_node = dep_graph[build_graph.key(prereq1.type, prereq1.name)]

                    for _, prereq2 in pairs(craft_material_surface_node.prereqs) do
                        if prereq2.type == "create-fluid-surface" then
                            add_fluid_prereq(prereq2, {prereq1, sorted_fluid_dependent})
                        end
                    end
                end
            end
        end

        -- We could technically add everything as a dependent here, but just in case I'm only adding those that actually have prereqs
        if has_fluid_prereq then
            table.insert(sorted_fluid_dependents, sorted_fluid_dependent)
        end
    end

    rng.shuffle(rng.key({id = id}), shuffled_prereqs)

    -- CRITICAL TODO: USE THIS?
    local fluid_to_surface_satisfied = {}
    for _, prereq in pairs(shuffled_prereqs) do
        fluid_to_surface_satisfied[build_graph.key(prereq.type, prereq.name)] = true
    end

    -- See what prereqs are reachable and use those for new dependent "prereqs"
    -- Dependents are treated as ANDs

    local ind_to_used = {}
    local sort_state = top_sort.sort(dep_graph, blacklist)
    local dependent_to_new_prereqs = {}
    for _, dependent in pairs(sorted_fluid_dependents) do
        local reachable = sort_state.reachable
        dependent_to_new_prereqs[build_graph.key(dependent.type, dependent.name)] = {}

        -- Find matching prereqs
        for i = 1, #dependent.prereqs do
            for prereq_ind, prereq in pairs(shuffled_prereqs) do
                if not ind_to_used[prereq_ind] and reachable[build_graph.key(prereq.type, prereq.name)] then
                    -- CRITICAL TODO: How to preserve surface requirements? We'd need at least one dependent to be from this surface
                    -- Probably make sure the last dependent at least has the right surface?
                    -- This could lead to need for backtracking...
                    -- We could potentially need a fluid on multiple surfaces, maybe ignore this for now?
                    -- Or we could keep track of dependent surfaces? No that sounds complex
                    -- Or just preserve surface of fluid prereq? That could also lead to backtracking
                    -- Count number of "any"s on a surface and not do more than that? So that the surface specific fluids have something at least?
                    -- Maybe let's hold off until we get this going

                    ind_to_used[prereq_ind] = true
                    table.insert(dependent_to_new_prereqs[build_graph.key(dependent.type, dependent.name)], prereq)

                    break
                end
            end
        end

        for _, prereq in pairs(dependent.prereqs) do
            blacklist[build_graph.conn_key({prereq, dependent})] = false
            sort_state = top_sort.sort(dep_graph, blacklist, sort_state, {prereq, dependent})
        end
    end

    -- Fix data.raw

    for _, dependent in pairs(sorted_fluid_dependents) do
        -- CRITICAL TODO: Cost preservation as well! Don't pay attention to this for now

        
    end



    --[[
    for _, fluid_node in pairs(graph_sort) do
        if fluid_node.type == "create-fluid-surface" and fluid_to_surface[fluid_node.fluid.name] == nil then
            fluid_to_surface[fluid_node.fluid.name] = fluid_node.surface
            -- If it can be barreled, it's any surface
            if data.raw.item[fluid_node.fluid.name .. "-barrel"] ~= nil then
                fluid_to_surface[fluid_node.fluid.name] = "any"
            end

            local cost_calculable = true
            if old_aggregate_cost.material_to_cost["fluid-" .. fluid_node.fluid.name] == nil then
                cost_calculable = flase
            end

            if cost_calculable then
                table.insert(fluid_dependents, dependent_node)

                -- TODO: Study specific prereqs
                for _, prereq in pairs(fluid_node.prereqs) do
                    table.insert(shuffled_prereqs, prereq)
                    blacklist[build_graph.conn_key({prereq, dependent_node})] = true
                end
            end
        end
    end

    rng.shuffle(rng.key({id = id}), shuffled_prereqs)

    -- Don't worry about progressive cost preservation, just modify numbers in post
    for _, ]]
end
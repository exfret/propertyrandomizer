-- Planet rewards (setting propertyrandomizer-planetary-rewards): what a planet gives you to build elsewhere moves to another planet (see notes/planet-features-plan.md)
-- A bundle is one technology's planet-locked recipes and buildings that belong to one planet family: their surface conditions accept that family's planets and no other planet (rooms that aren't planets, like space platforms, are fixed members of the lock)
-- The bundle also carries the technology's own ties to the family: a research trigger only that family can meet, science packs only it makes, and prerequisites that discover it or belong to it
-- Every bundle is logged first (PLANETFEATURES lines, rewards.log), then the reward bundles move (rewards.execute): each member's lock goes to a random other planet (locks.move, so the lock stage's repairs and settlers cover them), and the technology follows: its trigger asks for something the new planet has, its research takes the new planet's science pack, and its prerequisites trade the family's discovery for the new planet's (user, 2026-09-29)
-- A reward is a member whose results place entities, or a locked building itself: not lightning attractors (the lightning stage moves them with lightning) and not a machine that only crafts the recycler's generated recipes (the recycler, which every production chain uses)
-- A planet and its copies are one family (surface_sets.family_of): a lock accepts all of them or none, and what's specific to one is specific to the family

local constants = require("helper-tables/constants")
local dutils = require("lib/data-utils")
local fluid_ports = require("lib/fluid-ports")
local furnace_selection = require("lib/furnace-selection")
local gutils = require("lib/graph/graph-utils")
local locale_utils = require("lib/locale")
local lutils = require("lib/logic/logic-utils")
local recycling = require("lib/recycling")
local rng = require("lib/random/rng")
local top = require("lib/graph/context-sort")
local surface_sets = require("lib/surface-sets")
local locks = require("randomizations/planetary/locks")
local scaffolds = require("randomizations/planetary/scaffolds")

local rewards = {}

local function sorted_keys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

-- The family a planet room belongs to, as a key (surface_sets.family_of)
local function family_of(room_key)
    return surface_sets.family_of(room_key)
end

-- Family --> set of its planet room keys
local function families()
    local result = {}
    for _, room_key in pairs(surface_sets.room_keys()) do
        if gutils.deconstruct(room_key).type == "planet" then
            local family = family_of(room_key)
            result[family] = result[family] or {}
            result[family][room_key] = true
        end
    end
    return result
end

local function room_names(rooms)
    local names = {}
    for _, room_key in pairs(sorted_keys(rooms)) do
        table.insert(names, gutils.deconstruct(room_key).name)
    end
    return "{" .. table.concat(names, ", ") .. "}"
end

-- Whether a node belongs to a set of rooms in a sort, like check.node_specific_to for one planet: it's only reachable there, or every isolatable context it has is there
local function specific_to_rooms(sort, node_key, rooms)
    local contexts = sort.sort_info.node_to_context_inds[node_key] or {}
    if next(contexts) == nil then
        return false
    end
    local is_only_there = true
    local is_isolatable_there = false
    local is_isolatable_elsewhere = false
    for context, _ in pairs(contexts) do
        local is_there = rooms[top.context_room(context)] ~= nil
        if not is_there then
            is_only_there = false
        end
        local abilities = top.context_abilities(context)
        if abilities ~= nil and string.sub(abilities, top.ISOLATABILITY, top.ISOLATABILITY) == "1" then
            if is_there then
                is_isolatable_there = true
            else
                is_isolatable_elsewhere = true
            end
        end
    end
    return is_only_there or (is_isolatable_there and not is_isolatable_elsewhere)
end

-- The family a lock belongs to: the one family whose planets are the planets the prototype accepts, or nil when the accepted planets span several families or none
-- Also returns the accepted planets and the other accepted rooms (fixed members, like space platforms)
local function lock_home(prototype)
    local family
    local is_one = true
    local planets = {}
    local fixed = {}
    for room_key, _ in pairs(surface_sets.accepted(prototype)) do
        if gutils.deconstruct(room_key).type == "planet" then
            planets[room_key] = true
            local room_family = family_of(room_key)
            if family == nil then
                family = room_family
            elseif family ~= room_family then
                is_one = false
            end
        else
            fixed[room_key] = true
        end
    end
    if family == nil or not is_one then
        return nil
    end
    return family, planets, fixed
end

-- Materials (as "item:name" or "fluid:name" --> true) that only a family makes: by the sort (specific_to_rooms, for the family's rooms), or by their recipes' locks (every recipe making the material, the recycler's generated ones aside, is locked to the family, and one is).
-- Then, transitively, materials every making recipe of which takes one of those (lithium is made anywhere, but only from Aquilo's brine; lithium plate only from lithium), as long as nothing else gives them (no entity drops them when mined and nothing spoils into them).
-- The sort alone can't tell what's Aquilo's, since nothing there is isolatable (lithium plate needs holmium) and its products are delivered elsewhere, so the locks and the transitive step stand in for it there.
local function lock_specific_materials(before, family, rooms)
    local families_of = {}
    local is_open = {}
    local makers = {}
    for _, recipe in pairs(data.raw.recipe) do
        if not recycling.looks_generated(recipe) then
            local recipe_family = lock_home(recipe)
            for _, result in pairs(recipe.results or {}) do
                local material_key = result.type .. ":" .. result.name
                makers[material_key] = makers[material_key] or {}
                table.insert(makers[material_key], recipe)
                if recipe_family == nil then
                    is_open[material_key] = true
                else
                    families_of[material_key] = families_of[material_key] or {}
                    families_of[material_key][recipe_family] = true
                end
            end
        end
    end
    local has_other_source = {}
    for _, entity in pairs(dutils.get_all_prots("entity")) do
        local minable = entity.minable
        if minable ~= nil then
            if minable.result ~= nil then
                has_other_source["item:" .. minable.result] = true
            end
            for _, result in pairs(minable.results or {}) do
                has_other_source[result.type .. ":" .. result.name] = true
            end
        end
    end
    for _, item in pairs(dutils.get_all_prots("item")) do
        if item.spoil_result ~= nil then
            has_other_source["item:" .. item.spoil_result] = true
        end
    end
    local specific = {}
    for material_key, its_families in pairs(families_of) do
        if is_open[material_key] == nil and its_families[family] ~= nil and #sorted_keys(its_families) == 1 then
            specific[material_key] = true
        end
    end
    for material_key, _ in pairs(makers) do
        if specific[material_key] == nil and specific_to_rooms(before, gutils.key(string.match(material_key, "^[^:]+"), string.match(material_key, ":(.*)$")), rooms) then
            specific[material_key] = true
        end
    end
    local grew = true
    while grew do
        grew = false
        for material_key, recipes in pairs(makers) do
            if specific[material_key] == nil and has_other_source[material_key] == nil then
                local is_made_from_specific = true
                for _, recipe in pairs(recipes) do
                    local takes_specific = false
                    for _, ingredient in pairs(recipe.ingredients or {}) do
                        if specific[ingredient.type .. ":" .. ingredient.name] ~= nil then
                            takes_specific = true
                        end
                    end
                    if not takes_specific then
                        is_made_from_specific = false
                    end
                end
                if is_made_from_specific then
                    specific[material_key] = true
                    grew = true
                end
            end
        end
    end
    return specific
end

-- Planet-locked recipes and buildings that belong to one family, sorted by kind and name
-- Each is { kind ("recipe" or "entity"), name, prototype, family, planets, fixed, recipe_names (the recipe itself, or the recipes making the items that place the building) }
local function members()
    local lab_inputs = dutils.lab_inputs()
    local list = {}
    local function consider(kind, prototype, recipe_names)
        if prototype.hidden == true or prototype.surface_conditions == nil or next(prototype.surface_conditions) == nil then
            return
        end
        local family, planets, fixed = lock_home(prototype)
        if family == nil then
            return
        end
        table.insert(list, {
            kind = kind,
            name = prototype.name,
            prototype = prototype,
            family = family,
            planets = planets,
            fixed = fixed,
            recipe_names = recipe_names,
        })
    end
    -- Recipes, science packs aside (they stay with their planets); the recycler's generated recipes don't make anything, whatever they give back
    local item_recipes = {}
    for _, recipe_name in pairs(sorted_keys(data.raw.recipe)) do
        local recipe = data.raw.recipe[recipe_name]
        if not recycling.looks_generated(recipe) then
            local makes_science = false
            for _, result in pairs(recipe.results or {}) do
                if result.type == "item" then
                    if lab_inputs[result.name] ~= nil then
                        makes_science = true
                    end
                    item_recipes[result.name] = item_recipes[result.name] or {}
                    table.insert(item_recipes[result.name], recipe_name)
                end
            end
            if not makes_science then
                consider("recipe", recipe, {
                    recipe_name,
                })
            end
        end
    end
    -- Buildings, with the recipes making the items that place them
    local entities = dutils.get_all_prots("entity")
    for _, entity_name in pairs(sorted_keys(entities)) do
        local entity = entities[entity_name]
        local placers = lookups.buildables[gutils.key(entity)]
        if placers ~= nil then
            local recipe_names = {}
            local is_listed = {}
            for _, item_name in pairs(sorted_keys(placers)) do
                for _, recipe_name in pairs(item_recipes[item_name] or {}) do
                    if is_listed[recipe_name] == nil then
                        is_listed[recipe_name] = true
                        table.insert(recipe_names, recipe_name)
                    end
                end
            end
            consider("entity", entity, recipe_names)
        end
    end
    return list
end

-- Names of technologies that discover a planet of the family (an unlock-space-location effect for it), as a set
local function discoverers(planets)
    local names = {}
    for _, tech in pairs(data.raw.technology) do
        for _, effect in pairs(tech.effects or {}) do
            if effect.type == "unlock-space-location" and planets[gutils.key("planet", effect.space_location)] ~= nil then
                names[tech.name] = true
            end
        end
    end
    return names
end

local function product_key(product)
    return product.type .. ":" .. product.name
end

-- The nodes of what a research trigger asks for (the entities to mine, the item or fluid to craft or launch, the entity to build or capture), empty when anything will do
local function trigger_sources(trigger)
    local sources = {}
    if trigger.type == "mine-entity" then
        for _, entity_name in pairs(trigger.entities or {}) do
            table.insert(sources, gutils.key("entity", entity_name))
        end
    elseif trigger.type == "craft-item" or trigger.type == "send-item-to-orbit" then
        table.insert(sources, gutils.key("item", trigger.item))
    elseif trigger.type == "craft-fluid" then
        table.insert(sources, gutils.key("fluid", trigger.fluid))
    elseif (trigger.type == "build-entity" or trigger.type == "capture-spawner") and trigger.entity ~= nil then
        table.insert(sources, gutils.key("entity", trigger.entity))
    end
    return sources
end

-- A family's own science pack: a lab input made by a recipe locked to the family, or nil (the starting planet's packs aren't locked)
-- By the lock rather than the sort, since nothing on a planet like Aquilo is isolatable (its pack needs holmium), so the sort can't tell whose it is
local function family_pack(family)
    local lab_inputs = dutils.lab_inputs()
    for _, recipe_name in pairs(sorted_keys(data.raw.recipe)) do
        local recipe = data.raw.recipe[recipe_name]
        if not recycling.looks_generated(recipe) then
            for _, result in pairs(recipe.results or {}) do
                if result.type == "item" and lab_inputs[result.name] ~= nil and lock_home(recipe) == family then
                    return result.name
                end
            end
        end
    end
    return nil
end

local function pack_name(ingredient)
    return ingredient[1] or ingredient.name
end

-- Whether a technology's trigger asks only for things the family has in the sort before (every entity a mine-entity trigger lists counts, since any one of them fulfils it)
local function trigger_tied(before, trigger, planets)
    local sources = trigger_sources(trigger)
    if #sources == 0 then
        return false
    end
    -- By the sort, or by the recipes' locks for a material (Aquilo's lithium plate is delivered elsewhere, so the sort doesn't see it as Aquilo's)
    local lock_specific = lock_specific_materials(before, family_of(next(planets)), planets)
    for _, source in pairs(sources) do
        local node = gutils.deconstruct(source)
        if not specific_to_rooms(before, source, planets) and lock_specific[node.type .. ":" .. node.name] == nil then
            return false
        end
    end
    return true
end

-- How a technology is tied to a family in the sort before, or nil: it discovers one of its planets, only the family can meet its trigger, or its research needs the family's own science pack (family_pack, or a pack only the family makes)
local function tech_tie(before, tech, planets, discovery, family)
    if discovery[tech.name] ~= nil then
        return "discovers the family"
    end
    if tech.research_trigger ~= nil then
        if trigger_tied(before, tech.research_trigger, planets) then
            return "family-specific trigger"
        end
    elseif tech.unit ~= nil then
        local own_pack = family ~= nil and family_pack(family) or nil
        for _, ingredient in pairs(tech.unit.ingredients or {}) do
            if pack_name(ingredient) == own_pack or specific_to_rooms(before, gutils.key("item", pack_name(ingredient)), planets) then
                return "family-specific science"
            end
        end
    end
    return nil
end

-- What a research trigger asks for, for the log
local function trigger_text(trigger)
    if trigger.type == "mine-entity" then
        return "mine " .. table.concat(trigger.entities or {}, " or ")
    elseif trigger.type == "craft-item" then
        return "craft " .. tostring(trigger.item)
    elseif trigger.type == "craft-fluid" then
        return "craft " .. tostring(trigger.fluid)
    elseif trigger.type == "send-item-to-orbit" then
        return "launch " .. tostring(trigger.item)
    elseif trigger.type == "capture-spawner" then
        return "capture " .. tostring(trigger.entity or "any spawner")
    elseif trigger.type == "build-entity" then
        return "build " .. tostring(trigger.entity)
    end
    return trigger.type
end

-- The logic nodes that feed a technology's trigger node for this trigger (the edges lib/logic/concrete.lua builds into technology-trigger), as a sorted list of node keys
rewards.trigger_source_keys = function(trigger)
    local keys = {}
    if trigger.type == "mine-entity" then
        for _, entity_name in pairs(trigger.entities or {}) do
            table.insert(keys, gutils.key("entity-mine", entity_name))
        end
    elseif trigger.type == "craft-item" then
        table.insert(keys, gutils.key("item-craft", trigger.item))
    elseif trigger.type == "craft-fluid" then
        table.insert(keys, gutils.key("fluid-craft", trigger.fluid))
    elseif trigger.type == "send-item-to-orbit" then
        table.insert(keys, gutils.key("item-launch", trigger.item))
    elseif trigger.type == "capture-spawner" then
        table.insert(keys, trigger.entity ~= nil and gutils.key("entity-capture-spawner", trigger.entity) or gutils.key("capture-spawner", ""))
    elseif trigger.type == "build-entity" then
        table.insert(keys, gutils.key("entity-build", trigger.entity))
    elseif trigger.type == "create-space-platform" then
        table.insert(keys, gutils.key("create-platform", ""))
    end
    table.sort(keys)
    return keys
end

-- The edges that would tie every moved bundle's technology to its old planet again, for the lock stage's staged sort (see run_locks in execute.lua, where a gate on a witness sends the whole bundle back): list of { start, stop, bundle_id }
-- A split bundle's original technology unlocking it again (technology --> recipe-tech-unlock), or an edited technology asking for its old trigger again (trigger source --> technology-trigger), its own or one the move retied (retie_dependent_triggers)
rewards.tie_edges = function()
    local edges = {}
    for _, bundle_id in pairs(sorted_keys(rewards.moved)) do
        local bundle = rewards.moved[bundle_id]
        local tech = data.raw.technology[bundle.tech]
        if tech ~= nil and not bundle.tech_restored then
            if bundle.tech_edit.split ~= nil then
                -- A variant is the target's; the old planet's unlock of the original isn't an edge of this graph (the original is gone), see run_locks for how the original comes back instead
                local is_variant = {}
                for _, variant in pairs(bundle.variants) do
                    is_variant[variant.name] = true
                end
                for _, recipe_name in pairs(sorted_keys(bundle.member_recipes)) do
                    if is_variant[recipe_name] == nil then
                        table.insert(edges, {
                            start = gutils.key("technology", bundle.tech_edit.split.source),
                            stop = gutils.key("recipe-tech-unlock", recipe_name),
                            bundle_id = bundle_id,
                        })
                    end
                end
            else
                local old_trigger = bundle.tech_edit.old.research_trigger
                if old_trigger ~= nil and trigger_text(tech.research_trigger or {}) ~= trigger_text(old_trigger) then
                    for _, source_key in pairs(rewards.trigger_source_keys(old_trigger)) do
                        table.insert(edges, {
                            start = source_key,
                            stop = gutils.key("technology-trigger", bundle.tech),
                            bundle_id = bundle_id,
                        })
                    end
                end
            end
        end
        -- Other technologies the bundle's move retied asking for their old trigger again (retie_dependent_triggers)
        for _, edit in pairs(bundle.trigger_edits or {}) do
            for _, source_key in pairs(rewards.trigger_source_keys(edit.old)) do
                table.insert(edges, {
                    start = source_key,
                    stop = gutils.key("technology-trigger", edit.tech),
                    bundle_id = bundle_id,
                })
            end
        end
    end
    return edges
end

-- Bundles of the game in the sort before (from check.sort): technology name (or "" for members no technology unlocks) and family --> { tech, family, planets, members }
-- A member unlocked by several technologies goes with the first by name; the others are listed with it
rewards.bundles = function(before)
    local family_planets = families()
    local bundles = {}
    for _, member in pairs(members()) do
        local techs = {}
        for _, recipe_name in pairs(member.recipe_names) do
            for tech_name, _ in pairs(lookups.recipe_to_techs[recipe_name] or {}) do
                techs[tech_name] = true
            end
        end
        member.techs = sorted_keys(techs)
        local tech_name = member.techs[1] or ""
        local id = tech_name .. " @ " .. member.family
        bundles[id] = bundles[id] or {
            tech = tech_name,
            family = member.family,
            planets = family_planets[member.family] or {},
            members = {},
        }
        table.insert(bundles[id].members, member)
    end
    return bundles
end

-- The dry run: logs every bundle with what a move would carry, from the sort of the game before planetary changes (before, from check.sort)
-- Returns the bundles
rewards.log = function(before)
    local bundles = rewards.bundles(before)
    local ids = sorted_keys(bundles)
    local num_families = 0
    for _, _ in pairs(families()) do
        num_families = num_families + 1
    end
    log("PLANETFEATURES " .. #ids .. " reward bundles on " .. num_families .. " planet families (dry run: nothing moves)")
    local function specific(node_key, planets)
        return specific_to_rooms(before, node_key, planets)
    end
    local function material_key(material)
        return gutils.key(material.type, material.name)
    end
    for _, id in pairs(ids) do
        local bundle = bundles[id]
        local planets = bundle.planets
        local in_bundle = {}
        for _, member in pairs(bundle.members) do
            for _, recipe_name in pairs(member.recipe_names) do
                in_bundle[recipe_name] = true
            end
        end
        local stays = ""
        if bundle.family == family_of(gutils.key("planet", constants.starting_planet)) then
            stays = " (the starting planet's family: stays)"
        end
        log("PLANETFEATURES bundle " .. (bundle.tech ~= "" and bundle.tech or "(no technology)") .. " @ " .. room_names(planets) .. stays .. ": " .. #bundle.members .. " members")
        for _, member in pairs(bundle.members) do
            local parts = {}
            local accepts = "accepts " .. room_names(member.planets)
            if next(member.fixed) ~= nil then
                accepts = accepts .. " + fixed " .. room_names(member.fixed)
            end
            table.insert(parts, accepts)
            -- Results, ingredients and consumers over the member's recipes
            local results = {}
            local result_keys = {}
            local ingredients = {}
            for _, recipe_name in pairs(member.recipe_names) do
                local recipe = data.raw.recipe[recipe_name]
                for _, result in pairs(recipe.results or {}) do
                    local text = result.name
                    if result.type == "item" then
                        local item = dutils.get_prot("item", result.name)
                        if item ~= nil and item.place_result ~= nil then
                            text = text .. " (places " .. item.place_result .. ")"
                        end
                    end
                    if result_keys[product_key(result)] == nil then
                        result_keys[product_key(result)] = true
                        table.insert(results, text)
                    end
                end
                for _, ingredient in pairs(recipe.ingredients or {}) do
                    if specific(material_key(ingredient), planets) then
                        ingredients[ingredient.name] = true
                    end
                end
            end
            if member.kind == "entity" then
                table.insert(parts, "made by " .. (#member.recipe_names > 0 and table.concat(member.recipe_names, ", ") or "no recipe"))
            end
            table.insert(parts, "results: " .. (#results > 0 and table.concat(results, ", ") or "none"))
            table.insert(parts, "family-specific ingredients: " .. (next(ingredients) ~= nil and table.concat(sorted_keys(ingredients), ", ") or "none"))
            local consumers = {}
            for _, recipe_name in pairs(sorted_keys(data.raw.recipe)) do
                if in_bundle[recipe_name] == nil and not recycling.looks_generated(data.raw.recipe[recipe_name]) then
                    local is_consumer = false
                    for _, ingredient in pairs(data.raw.recipe[recipe_name].ingredients or {}) do
                        if result_keys[product_key(ingredient)] ~= nil then
                            is_consumer = true
                        end
                    end
                    if is_consumer and specific(gutils.key("recipe", recipe_name), planets) then
                        table.insert(consumers, recipe_name)
                    end
                end
            end
            table.insert(parts, "consumed by family-specific recipes: " .. (#consumers > 0 and table.concat(consumers, ", ") or "none"))
            if #member.techs > 1 then
                table.insert(parts, "also unlocked by " .. table.concat(member.techs, ", ", 2))
            end
            log("PLANETFEATURES   " .. member.kind .. "/" .. member.name .. ": " .. table.concat(parts, "; "))
        end
        local tech = data.raw.technology[bundle.tech]
        if tech ~= nil then
            local parts = {}
            local discovery = discoverers(planets)
            table.insert(parts, "tie " .. (tech_tie(before, tech, planets, discovery, bundle.family) or "none"))
            if tech.research_trigger ~= nil then
                table.insert(parts, "trigger " .. trigger_text(tech.research_trigger))
            elseif tech.unit ~= nil then
                local packs = {}
                for _, ingredient in pairs(tech.unit.ingredients or {}) do
                    local pack_name = ingredient[1] or ingredient.name
                    table.insert(packs, pack_name .. (specific(gutils.key("item", pack_name), planets) and " (family-specific)" or ""))
                end
                table.insert(parts, "science packs " .. table.concat(packs, ", "))
            end
            local prerequisites = {}
            for _, prerequisite in pairs(tech.prerequisites or {}) do
                local text = prerequisite
                local prerequisite_tech = data.raw.technology[prerequisite]
                local tie = prerequisite_tech ~= nil and tech_tie(before, prerequisite_tech, planets, discovery, bundle.family) or nil
                if tie ~= nil then
                    text = text .. " (" .. tie .. ")"
                end
                table.insert(prerequisites, text)
            end
            table.insert(parts, "prerequisites " .. (#prerequisites > 0 and table.concat(prerequisites, ", ") or "none"))
            local others = {}
            for _, effect in pairs(tech.effects or {}) do
                if effect.type == "unlock-recipe" and in_bundle[effect.recipe] == nil and data.raw.recipe[effect.recipe] ~= nil and not recycling.looks_generated(data.raw.recipe[effect.recipe]) then
                    table.insert(others, effect.recipe)
                end
            end
            table.sort(others)
            if #others > 0 then
                table.insert(parts, "also unlocks " .. table.concat(others, ", "))
            end
            log("PLANETFEATURES   technology " .. tech.name .. ": " .. table.concat(parts, "; "))
        end
    end
    return bundles
end

----------------------------------------------------------------------
-- Reward moves
----------------------------------------------------------------------

-- Whether a machine crafts the recycler's generated recipes (the recycler, whose category also has hand-written recipes like scrap recycling)
local function crafts_recycling(entity)
    local categories = {}
    for _, category in pairs(entity.crafting_categories or {}) do
        categories[category] = true
    end
    if next(categories) == nil then
        return false
    end
    for _, recipe in pairs(data.raw.recipe) do
        if recycling.looks_generated(recipe) then
            for _, category in pairs(furnace_selection.recipe_categories(recipe)) do
                if categories[category] ~= nil then
                    return true
                end
            end
        end
    end
    return false
end

-- A reward is what a planet gives you to build elsewhere: a member whose results place entities, or a locked building itself (see the top of this file for what's left out)
local function is_reward(member)
    local placed = {}
    if member.kind == "entity" then
        placed[member.name] = true
    else
        for _, result in pairs(member.prototype.results or {}) do
            if result.type == "item" then
                local item = dutils.get_prot("item", result.name)
                if item ~= nil and item.place_result ~= nil then
                    placed[item.place_result] = true
                end
            end
        end
    end
    if next(placed) == nil then
        return false
    end
    for entity_name, _ in pairs(placed) do
        if (data.raw["lightning-attractor"] or {})[entity_name] ~= nil then
            return false
        end
        local entity = dutils.get_prot("entity", entity_name)
        if entity ~= nil and crafts_recycling(entity) then
            return false
        end
        -- Belts, undergrounds and splitters (belt connectables, with a belt animation set) aren't rewards: item randomization already trades them around (user, 2026-09-30)
        if entity ~= nil and entity.belt_animation_set ~= nil then
            return false
        end
        -- Mining drills (with resource categories) aren't rewards either: a drill belongs with the ore only it mines (the big mining drill with tungsten ore), which is a chain, not a reward (user, 2026-09-30); as a reward it always went home for its planet's science
        if entity ~= nil and entity.resource_categories ~= nil then
            return false
        end
    end
    return true
end

-- The bundles a move takes, from rewards.bundles: reward members of technologies, the starting planet's family left out (its memberships stay)
rewards.reward_bundles = function(before)
    local start_family = family_of(gutils.key("planet", constants.starting_planet))
    local result = {}
    for id, bundle in pairs(rewards.bundles(before)) do
        if bundle.family ~= start_family and bundle.tech ~= "" and data.raw.technology[bundle.tech] ~= nil then
            local members = {}
            for _, member in pairs(bundle.members) do
                if is_reward(member) then
                    table.insert(members, member)
                end
            end
            if #members > 0 then
                result[id] = {
                    tech = bundle.tech,
                    family = bundle.family,
                    planets = bundle.planets,
                    members = members,
                }
            end
        end
    end
    return result
end

-- Planets a reward can go to: every planet outside the starting planet's family, as room keys, sorted
local function movable_planets()
    local start_family = family_of(gutils.key("planet", constants.starting_planet))
    local keys = {}
    for family, rooms in pairs(families()) do
        if family ~= start_family then
            for room_key, _ in pairs(rooms) do
                table.insert(keys, room_key)
            end
        end
    end
    table.sort(keys)
    return keys
end

-- The earliest rank of a node in the sort before, or nil if it's unreachable
local function rank_of(before, node_key)
    local rank
    for _, ind in pairs(before.sort_info.node_to_context_inds[node_key] or {}) do
        if rank == nil or ind < rank then
            rank = ind
        end
    end
    return rank
end

-- The recipes on the witness (earliest-provider path, top.path) of discovering a planet in the sort before, as recipe node key --> true, or nil if nothing discovers it
-- A reward can't go to a planet whose discovery needs it: the electromagnetic plant on Aquilo would be researched by crafting something on Aquilo, whose discovery needs electromagnetic science, which needs the plant
local function discovery_witness(before, room_key)
    local inds = {}
    for tech_name, _ in pairs(discoverers({
        [room_key] = true,
    })) do
        local rank = rank_of(before, gutils.key("technology", tech_name))
        if rank ~= nil then
            table.insert(inds, rank)
        end
    end
    if #inds == 0 then
        return nil
    end
    local recipes = {}
    for ind, _ in pairs(top.path(before.graph, inds, before.sort_info).in_path) do
        local node_key = before.sort_info.sorted[ind].node_key
        if gutils.deconstruct(node_key).type == "recipe" then
            recipes[node_key] = true
        end
    end
    return recipes
end

-- Whether a bundle is a family's special machine: one of its members places a machine that crafts the family's own science pack (the foundry for metallurgic science, the biochamber for agricultural science, ...)
local function is_special_machine(bundle)
    local pack = family_pack(bundle.family)
    if pack == nil then
        return false
    end
    local pack_categories = {}
    for _, recipe in pairs(data.raw.recipe) do
        if not recycling.looks_generated(recipe) then
            for _, result in pairs(recipe.results or {}) do
                if result.type == "item" and result.name == pack then
                    for _, category in pairs(furnace_selection.recipe_categories(recipe)) do
                        pack_categories[category] = true
                    end
                end
            end
        end
    end
    for _, member in pairs(bundle.members) do
        local placed = {}
        if member.kind == "entity" then
            placed[member.name] = true
        else
            for _, result in pairs(member.prototype.results or {}) do
                if result.type == "item" then
                    local item = dutils.get_prot("item", result.name)
                    if item ~= nil and item.place_result ~= nil then
                        placed[item.place_result] = true
                    end
                end
            end
        end
        for entity_name, _ in pairs(placed) do
            local entity = dutils.get_prot("entity", entity_name)
            for _, category in pairs((entity or {}).crafting_categories or {}) do
                if pack_categories[category] ~= nil then
                    return true
                end
            end
        end
    end
    return false
end

-- What a trigger of this kind could ask for instead, as a sorted list of { name, node_key }: items to craft, fluids to craft, entities to mine
local function trigger_candidates(trigger_type)
    local candidates = {}
    if trigger_type == "craft-item" then
        -- Crafting counts, mining doesn't, so only items a recipe makes (the recycler's generated recipes aside)
        local is_crafted = {}
        for _, recipe in pairs(data.raw.recipe) do
            if not recycling.looks_generated(recipe) then
                for _, result in pairs(recipe.results or {}) do
                    if result.type == "item" then
                        is_crafted[result.name] = true
                    end
                end
            end
        end
        local items = dutils.get_all_prots("item")
        for _, name in pairs(sorted_keys(items)) do
            if items[name].hidden ~= true and is_crafted[name] ~= nil then
                table.insert(candidates, {
                    name = name,
                    node_key = gutils.key("item", name),
                })
            end
        end
    elseif trigger_type == "craft-fluid" then
        for _, name in pairs(sorted_keys(data.raw.fluid or {})) do
            if data.raw.fluid[name].hidden ~= true then
                table.insert(candidates, {
                    name = name,
                    node_key = gutils.key("fluid", name),
                })
            end
        end
    elseif trigger_type == "mine-entity" then
        local entities = dutils.get_all_prots("entity")
        for _, name in pairs(sorted_keys(entities)) do
            if entities[name].minable ~= nil and entities[name].hidden ~= true then
                table.insert(candidates, {
                    name = name,
                    node_key = gutils.key("entity", name),
                })
            end
        end
    end
    return candidates
end

-- trigger_candidates for a research trigger, each with source_key: the node a trigger asking for it starts from (rewards.trigger_source_keys: crafting an item or fluid, mining an entity)
-- A craft-item trigger is met by crafting, so where and how deep a candidate is has to be read from its crafting node: calcite is mined on Vulcanus, but only asteroid crushing in space makes it (space-age/prototypes/recipe.lua), so "craft calcite" is nothing Vulcanus alone can do
local function trigger_options(trigger_type)
    local options = {}
    for _, candidate in pairs(trigger_candidates(trigger_type)) do
        local trigger = {
            type = trigger_type,
        }
        if trigger_type == "mine-entity" then
            trigger.entities = {
                candidate.name,
            }
        elseif trigger_type == "craft-fluid" then
            trigger.fluid = candidate.name
        else
            trigger.item = candidate.name
        end
        table.insert(options, {
            name = candidate.name,
            node_key = candidate.node_key,
            source_key = rewards.trigger_source_keys(trigger)[1],
        })
    end
    return options
end

-- Whether the path (top.path) to a context of the sort before goes through none of the excluded recipes (recipe node keys)
-- The walk stops at rooms and at reaching them (reachable-room), so what discovering the planet takes doesn't count as a route through the bundle: Aquilo's discovery is researched with the three inner planets' science, so every material there would otherwise seem to need their machines
local function path_avoids(before, ind, excluded)
    local path = top.path(before.graph, { ind }, before.sort_info, {
        stop_if = function(pebble)
            local node_type = gutils.deconstruct(pebble.node_key).type
            return node_type == "room" or node_type == "reachable-room"
        end,
    })
    for path_ind, _ in pairs(path.in_path) do
        if excluded[before.sort_info.sorted[path_ind].node_key] ~= nil then
            return false
        end
    end
    return true
end

-- How deep into its rooms' progression a node is in the sort before: its earliest context in the rooms (home contexts aside) counted from the room's own node, or nil when it has none
-- Ranks (sort indices) of different planets aren't comparable, since the sort places one planet's nodes after another's, so depths from the room are what's compared.
-- With excluded recipes (recipe node keys), only contexts reached without them count: what's reached only through the reward can't be what its research asks for, which would make it a cycle
local function depth_of(before, node_key, rooms, excluded)
    -- Earliest first, so the path walk (path_avoids) stops at the first context that counts
    local contexts = {}
    for context, ind in pairs(before.sort_info.node_to_context_inds[node_key] or {}) do
        local room_key = top.context_room(context)
        if top.context_home(context) == nil and rooms[room_key] ~= nil then
            table.insert(contexts, {
                ind = ind,
                room_key = room_key,
            })
        end
    end
    table.sort(contexts, function(a, b)
        return a.ind < b.ind
    end)
    for _, context in pairs(contexts) do
        if excluded == nil or path_avoids(before, context.ind, excluded) then
            return context.ind - (rank_of(before, gutils.key("room", context.room_key)) or 0)
        end
    end
    return nil
end

-- Whether a research trigger's candidate (trigger_options) can be met in the rooms by a recipe of its own, reached there without the excluded recipes
-- The logic's crafting node also counts the recycler's generated recipes (an item recycles into itself wherever a recycler runs), whose products are ignored_by_stats (lib/recycling.lua, like the game's recycler/recycling.lua), and the 2.1 docs don't say a craft-item trigger counts them, so a counterpart mustn't rely on them: Vulcanus only mines calcite, and only asteroid crushing in space makes it
-- Only the crafting step is checked: what the recipe's own proof takes can come from recycling like anything else (Aquilo's lithium plate is proven through tungsten carbide's recycling)
-- Other kinds of candidates (fluids to craft, entities to mine) always pass
local function met_by_own_recipe(before, candidate, rooms, excluded)
    if candidate.source_key == nil or gutils.deconstruct(candidate.source_key).type ~= "item-craft" then
        return true
    end
    local node = before.graph.nodes[candidate.source_key]
    if node == nil then
        return false
    end
    local nci = before.sort_info.node_to_context_inds
    for pre, _ in pairs(node.pre) do
        local prekey = before.graph.edges[pre].start
        local prenode = before.graph.nodes[prekey]
        if prenode ~= nil and prenode.type == "orand" and next(prenode.pre) ~= nil then
            prekey = before.graph.edges[next(prenode.pre)].start
        end
        local provider = gutils.deconstruct(prekey)
        local recipe = provider.type == "recipe" and data.raw.recipe[provider.name] or nil
        if recipe ~= nil and not recycling.looks_generated(recipe) then
            for context, ind in pairs(nci[prekey] or {}) do
                if top.context_home(context) == nil and rooms[top.context_room(context)] ~= nil and path_avoids(before, ind, excluded) then
                    return true
                end
            end
        end
    end
    return false
end

-- The candidate specific to the target's rooms (by the sort, or by its recipes' locks for a material) reached there without the excluded recipes (the bundle's own, see own_recipes) whose depth in the target's progression is closest to old_depth (the old source's depth at home), or nil.
-- Candidates in avoid (optional, material key --> true) are never picked: the products only reward machines make (avoided_materials).
-- A candidate with a source_key (trigger_options) is read at that node: a trigger asking to craft it needs it crafted there, not mined.
-- The optional accept function is a last check a candidate must pass, like met_by_own_recipe for triggers.
local function closest_specific(before, candidates, target_rooms, old_depth, excluded, avoid, accept)
    local best
    local best_distance
    local lock_specific = lock_specific_materials(before, family_of(next(target_rooms)), target_rooms)
    for _, candidate in pairs(candidates) do
        local node = gutils.deconstruct(candidate.node_key)
        local material_key = node.type .. ":" .. node.name
        -- A trigger candidate (trigger_options) counts where what the trigger asks can be done, an ingredient wherever it can be had
        local sort_key = candidate.source_key or candidate.node_key
        if (avoid or {})[material_key] == nil and (specific_to_rooms(before, sort_key, target_rooms) or lock_specific[material_key] ~= nil) and (accept == nil or accept(candidate)) then
            local depth = depth_of(before, sort_key, target_rooms, excluded)
            if depth ~= nil then
                local distance = math.abs(depth - (old_depth or depth))
                if best == nil or distance < best_distance then
                    best = candidate
                    best_distance = distance
                end
            end
        end
    end
    return best
end

-- Whether a material (an ingredient) can be had on any of the rooms in the sort before, imports included, some way that doesn't go through the bundle's own recipes (excluded, as recipe node keys)
-- Home contexts aside: those say what a room's discovery needs, not what's on it
-- The sort before has the bundle at home, so a route through it is no route once the bundle moves: pentapod eggs are had on Vulcanus by recycling a biochamber there, which needs a biochamber first
-- Each way into the material's node is tried (delivery, crafting, recycling, ...), since the sort's first provider can be the wrong one (quantum processors reached Fulgora by recycling delivered fusion generators before their own delivery)
local function obtainable_on(before, ingredient, rooms, excluded)
    local node = before.graph.nodes[gutils.key(ingredient.type, ingredient.name)]
    if node == nil then
        return false
    end
    local nci = before.sort_info.node_to_context_inds
    for pre, _ in pairs(node.pre) do
        local prekey = before.graph.edges[pre].start
        local prenode = before.graph.nodes[prekey]
        if prenode ~= nil and prenode.type == "orand" then
            prekey = before.graph.edges[next(prenode.pre)].start
        end
        for context, ind in pairs(nci[prekey] or {}) do
            if top.context_home(context) == nil and rooms[top.context_room(context)] ~= nil and path_avoids(before, ind, excluded) then
                return true
            end
        end
    end
    return false
end

-- The recipes a bundle must not be had through: its own members' recipes and the generated recycling of what they make (excluded for obtainable_on), as recipe node keys
local function own_recipes(bundle)
    local excluded = {}
    local made = {}
    for _, member in pairs(bundle.members) do
        for _, recipe_name in pairs(member.recipe_names) do
            excluded[gutils.key("recipe", recipe_name)] = true
            for _, result in pairs((data.raw.recipe[recipe_name] or {}).results or {}) do
                made[result.type .. ":" .. result.name] = true
            end
        end
    end
    for recipe_name, recipe in pairs(data.raw.recipe) do
        if recycling.looks_generated(recipe) then
            for _, ingredient in pairs(recipe.ingredients or {}) do
                if made[ingredient.type .. ":" .. ingredient.name] ~= nil then
                    excluded[gutils.key("recipe", recipe_name)] = true
                end
            end
        end
    end
    return excluded
end

-- What could stand in for an ingredient on the target: a material of the same form specific to the target's rooms, had there without the bundle's own recipes (excluded) and closest in depth to the ingredient's at home (home_rooms), or nil
-- (Pentapod eggs spoil before a trip ends, so a biochamber crafted on Vulcanus needs something Vulcanus has instead)
-- Only intermediates stand in for an item: not buildings (a recycler for a pentapod egg) and not science packs
local function ingredient_substitute(before, ingredient, target_rooms, home_rooms, excluded, avoid)
    local candidates
    if ingredient.type == "fluid" then
        candidates = trigger_candidates("craft-fluid")
    else
        local lab_inputs = dutils.lab_inputs()
        candidates = {}
        for _, candidate in pairs(trigger_candidates("craft-item")) do
            local item = dutils.get_prot("item", candidate.name)
            if item ~= nil and item.place_result == nil and lab_inputs[candidate.name] == nil then
                table.insert(candidates, candidate)
            end
        end
    end
    return closest_specific(before, candidates, target_rooms, depth_of(before, gutils.key(ingredient.type, ingredient.name), home_rooms), excluded, avoid)
end

-- The ingredients a member recipe would take on the target: the ones it can't get there swapped for substitutes (ingredient_substitute), or nil when one has no substitute or the recipe's machine picks recipes by ingredient (furnaces, where a swap could collide)
-- Returns the new ingredient list and the swaps as { from, to } for the log, or nil
local function target_ingredients(before, recipe_name, target_rooms, home_rooms, excluded, avoid)
    local recipe = data.raw.recipe[recipe_name]
    if recipe == nil then
        return nil
    end
    if #furnace_selection.pools_for(furnace_selection.pools(), furnace_selection.recipe_categories(recipe)) > 0 then
        for _, ingredient in pairs(recipe.ingredients or {}) do
            if not obtainable_on(before, ingredient, target_rooms, excluded) then
                return nil
            end
        end
        return table.deepcopy(recipe.ingredients or {}), {}
    end
    local ingredients = {}
    local swaps = {}
    local is_listed = {}
    for _, ingredient in pairs(recipe.ingredients or {}) do
        local new_ingredient = table.deepcopy(ingredient)
        if not obtainable_on(before, ingredient, target_rooms, excluded) then
            local substitute = ingredient_substitute(before, ingredient, target_rooms, home_rooms, excluded, avoid)
            if substitute == nil then
                return nil
            end
            new_ingredient.name = substitute.name
            new_ingredient.temperature = nil
            new_ingredient.minimum_temperature = nil
            new_ingredient.maximum_temperature = nil
            table.insert(swaps, {
                from = ingredient.name,
                to = substitute.name,
            })
        end
        local key_name = new_ingredient.type .. ":" .. new_ingredient.name
        if is_listed[key_name] ~= nil then
            is_listed[key_name].amount = (is_listed[key_name].amount or 1) + (new_ingredient.amount or 1)
        else
            is_listed[key_name] = new_ingredient
            table.insert(ingredients, new_ingredient)
        end
    end
    return ingredients, swaps
end

-- The crafting machines of a bundle: the entities its members' recipes place (and its entity members), for companions_of
local function bundle_machines(bundle)
    local machines = {}
    for _, member in pairs(bundle.members) do
        if member.kind == "entity" then
            machines[member.name] = true
        end
        for _, recipe_name in pairs(member.recipe_names) do
            for _, result in pairs((data.raw.recipe[recipe_name] or {}).results or {}) do
                if result.type == "item" then
                    local item = dutils.get_prot("item", result.name)
                    if item ~= nil and item.place_result ~= nil then
                        machines[item.place_result] = true
                    end
                end
            end
        end
    end
    return machines
end

-- Which entities (with crafting categories, the character included) craft each category: category --> entity name --> true
local function crafters_by_category()
    local crafters_of = {}
    for name, entity in pairs(dutils.get_all_prots("entity")) do
        for _, category in pairs(entity.crafting_categories or {}) do
            crafters_of[category] = crafters_of[category] or {}
            crafters_of[category][name] = true
        end
    end
    return crafters_of
end

-- Whether only the given machines (entity name --> true) craft a recipe: every crafter of each of its categories is one of them
local function only_machines_craft(recipe, machines, crafters_of)
    for _, category in pairs(furnace_selection.recipe_categories(recipe)) do
        for crafter, _ in pairs(crafters_of[category] or {}) do
            if machines[crafter] == nil then
                return false
            end
        end
    end
    return true
end

-- The materials (as "item:name" or "fluid:name" --> true) no substitute or trigger counterpart of any bundle may be: every recipe making them (the recycler's generated ones aside) is a reward bundle's own or one only its machines craft
-- One set for all bundles, since several move at once and each other's machines are gone or newly researched where they went: a biochamber variant on Fulgora that took supercapacitors needed the electromagnetic plant, whose new research on Gleba asked for pentapod eggs from a biochamber
local function avoided_materials(bundles)
    local excluded = {}
    local crafters_of = crafters_by_category()
    for _, bundle in pairs(bundles) do
        for recipe_key, _ in pairs(own_recipes(bundle)) do
            excluded[gutils.deconstruct(recipe_key).name] = true
        end
        local machines = bundle_machines(bundle)
        if next(machines) ~= nil then
            for recipe_name, recipe in pairs(data.raw.recipe) do
                if not recycling.looks_generated(recipe) and only_machines_craft(recipe, machines, crafters_of) then
                    excluded[recipe_name] = true
                end
            end
        end
    end
    local is_open = {}
    local is_made = {}
    for recipe_name, recipe in pairs(data.raw.recipe) do
        if not recycling.looks_generated(recipe) then
            for _, result in pairs(recipe.results or {}) do
                local material_key = result.type .. ":" .. result.name
                is_made[material_key] = true
                if excluded[recipe_name] == nil then
                    is_open[material_key] = true
                end
            end
        end
    end
    local avoid = {}
    for material_key, _ in pairs(is_made) do
        if is_open[material_key] == nil then
            avoid[material_key] = true
        end
    end
    return avoid
end

-- The machine's other recipes, which the new planet gets as well (user, 2026-09-30: a foundry should take the recipes that can go with it, made from the new planet's fluid): the recipes the bundle's technology unlocks next to its members that only the bundle's machines craft (every entity with crafting categories that has one of the recipe's categories is one of them, the character included)
-- They come as additions, so the old planet keeps them and is owed nothing: the technology copy unlocks them too where the target has their ingredients as they are (shared), and unlocks a planet variant with the target's own fluid or intermediate where it doesn't (variants, like a member's substitutes; routes through the machines count, since they go too)
-- Returns shared (recipe name --> true) and variants (recipe name --> { ingredients, swaps })
local function companions_of(before, bundle, target_rooms, avoid)
    local shared = {}
    local variants = {}
    local tech = data.raw.technology[bundle.tech]
    if tech == nil then
        return shared, variants
    end
    local is_member = {}
    for _, member in pairs(bundle.members) do
        for _, recipe_name in pairs(member.recipe_names) do
            is_member[recipe_name] = true
        end
    end
    local machines = bundle_machines(bundle)
    local crafters_of = crafters_by_category()
    for _, effect in pairs(tech.effects or {}) do
        local recipe = effect.type == "unlock-recipe" and data.raw.recipe[effect.recipe] or nil
        if recipe ~= nil and is_member[recipe.name] == nil and shared[recipe.name] == nil and variants[recipe.name] == nil and not recycling.looks_generated(recipe) then
            if only_machines_craft(recipe, machines, crafters_of) then
                local ingredients, swaps = target_ingredients(before, recipe.name, target_rooms, bundle.planets, {}, avoid)
                if ingredients ~= nil and #swaps == 0 then
                    shared[recipe.name] = true
                elseif ingredients ~= nil then
                    variants[recipe.name] = {
                        ingredients = ingredients,
                        swaps = swaps,
                    }
                end
            end
        end
    end
    return shared, variants
end

-- Whether a material is the target's own in the sort before: isolatable on its rooms (ability 1 in some context there, home contexts aside), or specific to them by the sort or by locks (lock_specific_materials)
local function is_local_to(before, material, target_rooms, lock_specific)
    local node_key = gutils.key(material.type, material.name)
    if lock_specific[material.type .. ":" .. material.name] ~= nil or specific_to_rooms(before, node_key, target_rooms) then
        return true
    end
    for context, _ in pairs(before.sort_info.node_to_context_inds[node_key] or {}) do
        local abilities = top.context_abilities(context)
        if top.context_home(context) == nil and target_rooms[top.context_room(context)] ~= nil and abilities ~= nil and string.sub(abilities, top.ISOLATABILITY, top.ISOLATABILITY) == "1" then
            return true
        end
    end
    return false
end

-- The fuel a bundle's machines burn has to be made on the target from the target's own materials, so the machine runs there (user, 2026-09-30: nutrients go with the biochamber): the fuel categories of the machines' burner energy sources (BurnerEnergySource::fuel_categories) name the fuel items (ItemPrototype::fuel_category), and the recipe making one that needs the fewest substitutes gets a variant for the target, its ingredients that aren't the target's own (is_local_to) swapped like a member's (ingredient_substitute)
-- Returns recipe name --> { ingredients, swaps } (at most one), or nothing when a companion already makes such a fuel from the target's own materials
local function fuel_variants_for(before, bundle, target_rooms, companions, excluded, avoid)
    local categories = {}
    for name, _ in pairs(bundle_machines(bundle)) do
        local entity = dutils.get_prot("entity", name)
        local source = entity ~= nil and entity.energy_source or nil
        if source ~= nil and source.type == "burner" then
            for _, category in pairs(source.fuel_categories or {}) do
                categories[category] = true
            end
            if source.fuel_category ~= nil then
                categories[source.fuel_category] = true
            end
        end
    end
    if next(categories) == nil then
        return {}
    end
    local is_fuel = {}
    for name, item in pairs(dutils.get_all_prots("item")) do
        local item_categories = {}
        if item.fuel_category ~= nil then
            table.insert(item_categories, item.fuel_category)
        end
        for _, category in pairs(item.fuel_categories or {}) do
            table.insert(item_categories, category)
        end
        for _, category in pairs(item_categories) do
            if categories[category] ~= nil then
                is_fuel[name] = true
            end
        end
    end
    local makers = {}
    for recipe_name, recipe in pairs(data.raw.recipe) do
        if not recycling.looks_generated(recipe) then
            for _, result in pairs(recipe.results or {}) do
                if result.type == "item" and is_fuel[result.name] ~= nil then
                    table.insert(makers, recipe_name)
                    break
                end
            end
        end
    end
    table.sort(makers)
    local lock_specific = lock_specific_materials(before, family_of(next(target_rooms)), target_rooms)
    local function local_ingredients(recipe_name)
        local recipe = data.raw.recipe[recipe_name]
        local ingredients = {}
        local swaps = {}
        for _, ingredient in pairs(recipe.ingredients or {}) do
            local new_ingredient = table.deepcopy(ingredient)
            if not is_local_to(before, ingredient, target_rooms, lock_specific) then
                local substitute = ingredient_substitute(before, ingredient, target_rooms, bundle.planets, excluded, avoid)
                if substitute == nil then
                    return nil
                end
                new_ingredient.name = substitute.name
                new_ingredient.temperature = nil
                new_ingredient.minimum_temperature = nil
                new_ingredient.maximum_temperature = nil
                table.insert(swaps, {
                    from = ingredient.name,
                    to = substitute.name,
                })
            end
            table.insert(ingredients, new_ingredient)
        end
        return ingredients, swaps
    end
    -- A companion making fuel from the target's own materials as it is already goes along
    for _, recipe_name in pairs(makers) do
        if companions[recipe_name] ~= nil then
            local _, swaps = local_ingredients(recipe_name)
            if swaps ~= nil and #swaps == 0 then
                return {}
            end
        end
    end
    local best
    local best_ingredients
    local best_swaps
    for _, recipe_name in pairs(makers) do
        local ingredients, swaps = local_ingredients(recipe_name)
        if ingredients ~= nil and (best == nil or #swaps < #best_swaps or (#swaps == #best_swaps and companions[recipe_name] ~= nil and companions[best] == nil)) then
            best = recipe_name
            best_ingredients = ingredients
            best_swaps = swaps
        end
    end
    if best == nil then
        return {}
    end
    return {
        [best] = {
            ingredients = best_ingredients,
            swaps = best_swaps,
        },
    }
end

-- Whether a bundle may go to a planet: something discovers the planet (witness), it isn't the one planet the bundle is on already, and every member recipe can take its ingredients there or swap the ones it can't (target_ingredients)
-- A planet whose discovery needs the bundle may receive it too (user, 2026-09-30; Aquilo's discovery is researched with the three inner planets' science, technology.lua:467-510): the reward's own planet then needs it back until recipe category randomization re-homes its science pack, which the settlement and the lock stage give it (its lock accepts the old planet again and its old technology unlocks it again), so the reward is shared rather than stuck in a research cycle
local function may_go(before, bundle, room_key, witness, avoid)
    local num_planets = 0
    for _, _ in pairs(bundle.planets) do
        num_planets = num_planets + 1
    end
    if bundle.planets[room_key] ~= nil and num_planets == 1 then
        return false
    end
    if witness == nil then
        return false
    end
    local target_rooms = families()[family_of(room_key)] or {
        [room_key] = true,
    }
    local excluded = own_recipes(bundle)
    for _, member in pairs(bundle.members) do
        for _, recipe_name in pairs(member.recipe_names) do
            local ingredients, swaps = target_ingredients(before, recipe_name, target_rooms, bundle.planets, excluded, avoid)
            -- A locked recipe with a substitute becomes a variant on the target (see rewards.execute); a locked building's recipe isn't locked itself, so it has to work as it is
            if ingredients == nil or (member.kind ~= "recipe" and #swaps > 0) then
                return false
            end
        end
    end
    return true
end

-- Draws a target for each bundle (user, 2026-09-30): the special machines (is_special_machine) trade places among their families, so every planet that gave one gets another; the other rewards go to random movable planets
-- A target is a planet something discovers (discovery_witness), a copy in the bundle's own family included, but not the one planet it's on already (see may_go)
-- Returns bundle id --> target room key (bundles with no possible target are left out)
-- The optional fits (outside superposed mode) is function(leaving bundle id, arriving bundle id or nil), saying whether the leaving special machine's planet can have its science re-homed into the arriving one's machines; the permutation must suit it everywhere, and a special machine no permutation fits stays
rewards.draw = function(bundles, before, id, fits)
    local key = rng.key({ id = id })
    local planets = movable_planets()
    local avoid = avoided_materials(bundles)
    local witnesses = {}
    for _, room_key in pairs(planets) do
        witnesses[room_key] = discovery_witness(before, room_key)
    end
    local targets = {}

    -- The special machines: one bundle per family (the first by id), permuted among the families that have one
    -- Only the bundles whose technology the development setting names, if it names any (config.planetary_rewards_only)
    if next(config.planetary_rewards_only) ~= nil then
        for _, bundle_id in pairs(sorted_keys(bundles)) do
            if config.planetary_rewards_only[bundles[bundle_id].tech] == nil then
                bundles[bundle_id] = nil
            end
        end
    end
    local special = {}
    for _, bundle_id in pairs(sorted_keys(bundles)) do
        local bundle = bundles[bundle_id]
        if rewards.pinned[bundle_id] ~= nil then
            log("Planet reward: " .. bundle.tech .. " stays, since an earlier attempt needed it home")
        elseif special[bundle.family] == nil and is_special_machine(bundle) then
            special[bundle.family] = bundle_id
        end
    end
    -- A family's home room for arriving machines: its first planet
    local home_room = {}
    for family, bundle_id in pairs(special) do
        home_room[family] = sorted_keys(bundles[bundle_id].planets)[1]
    end
    -- Only families that can receive some other family's machine take part in the permutation; the others' machines draw targets like the other rewards
    local families = {}
    for _, family in pairs(sorted_keys(special)) do
        local can_receive = false
        for _, other in pairs(sorted_keys(special)) do
            if other ~= family and may_go(before, bundles[special[other]], home_room[family], witnesses[home_room[family]], avoid) then
                can_receive = true
            end
        end
        if can_receive then
            table.insert(families, family)
        else
            log("Planet rewards: " .. gutils.deconstruct(home_room[family]).name .. " can't receive another planet's special machine")
        end
    end
    if #families > 1 then
        -- A few tries for a derangement every family allows (may_go); without one the machines draw targets like the other rewards
        local order
        for _ = 1, 30 do
            local shuffled = table.deepcopy(families)
            rng.shuffle(key, shuffled)
            local is_ok = true
            for i, family in pairs(families) do
                if shuffled[i] == family or not may_go(before, bundles[special[family]], home_room[shuffled[i]], witnesses[home_room[shuffled[i]]], avoid) then
                    is_ok = false
                end
                -- The planet family's machine arrives at must be able to take that planet's science (fits)
                if is_ok and fits ~= nil and not fits(special[shuffled[i]], special[family]) then
                    is_ok = false
                end
            end
            if is_ok then
                order = shuffled
                break
            end
        end
        if order ~= nil then
            for i, family in pairs(families) do
                targets[special[family]] = home_room[order[i]]
            end
            log("Planet rewards: the special machines trade places among " .. #families .. " planets")
        else
            log("Planet rewards: no order of the special machines suits every planet, so they draw targets like the other rewards")
        end
    end

    -- The other rewards, and special machines left without an order (outside superposed mode only those whose planet's science needs no re-homing, since no machine arrives to take it)
    local is_special = {}
    for _, bundle_id in pairs(special) do
        is_special[bundle_id] = true
    end
    for _, bundle_id in pairs(sorted_keys(bundles)) do
        if targets[bundle_id] == nil and rewards.pinned[bundle_id] == nil and is_special[bundle_id] ~= nil and fits ~= nil and not fits(bundle_id, nil) then
            log("Planet reward: " .. bundles[bundle_id].tech .. " stays, since no other planet's machine arrives to take its planet's science")
        elseif targets[bundle_id] == nil and rewards.pinned[bundle_id] == nil then
            local bundle = bundles[bundle_id]
            local candidates = {}
            for _, room_key in pairs(planets) do
                if may_go(before, bundle, room_key, witnesses[room_key], avoid) then
                    table.insert(candidates, room_key)
                end
            end
            if #candidates > 0 then
                targets[bundle_id] = candidates[rng.int(key, #candidates)]
            else
                log("Planet reward: " .. bundle.tech .. " stays, since no other planet can take it")
            end
        end
    end
    return targets
end

-- A copy of a research trigger that asks for name instead (a candidate of trigger_candidates for its type): the one entity to mine, the fluid or the item to craft
local function retargeted_trigger(trigger, name)
    local new_trigger = table.deepcopy(trigger)
    if trigger.type == "mine-entity" then
        new_trigger.entities = {
            name,
        }
    elseif trigger.type == "craft-fluid" then
        new_trigger.fluid = name
    else
        new_trigger.item = name
    end
    return new_trigger
end

-- The name of the copy of a technology that a split bundle takes along (edit_tech)
local function reward_copy_name(tech_name)
    return tech_name .. "-propertyrandomizer-reward"
end

-- Moves a bundle's technology to the target: a trigger only the family could meet asks for the target's counterpart, the family's science pack in its research becomes the target's, and its prerequisites trade the family's discovery and other family-tied technologies for the target's discovery
-- Returns the edit: { tech, old = the fields before, notes = what changed, for the log }
-- renamed: original recipe name --> its variant's name for the member recipes that got a variant on the target (the technology unlocks the variant instead); excluded: the bundle's own recipes (own_recipes), for what the technology may ask for; avoid: the products only reward machines make (avoided_materials), no trigger counterpart
-- extra_unlocks (optional): recipe names the technology unlocks as well on the target, the machine's other recipes and variants (companions_of) and a fuel variant (fuel_variants_for)
local function edit_tech(before, bundle, target_room, renamed, excluded, avoid, extra_unlocks)
    renamed = renamed or {}
    local source = data.raw.technology[bundle.tech]
    local target_family = family_of(target_room)
    local target_rooms = families()[target_family] or {
        [target_room] = true,
    }
    local target_name = gutils.deconstruct(target_room).name
    -- A technology that unlocks more than the bundle keeps those unlocks and its own ties, and the bundle's unlocks go to a copy of it that follows the bundle (else its other unlocks, like the foundry's casting recipes, would only be researchable from the new planet, and nothing they make would be isolatable at home)
    local own = {}
    for _, member in pairs(bundle.members) do
        for _, recipe_name in pairs(member.recipe_names) do
            own[recipe_name] = true
        end
    end
    local own_effects = {}
    local other_effects = {}
    for _, effect in pairs(source.effects or {}) do
        if effect.type == "unlock-recipe" and own[effect.recipe] ~= nil then
            local own_effect = table.deepcopy(effect)
            own_effect.recipe = renamed[effect.recipe] or effect.recipe
            table.insert(own_effects, own_effect)
        else
            table.insert(other_effects, effect)
        end
    end
    for _, recipe_name in pairs(extra_unlocks or {}) do
        local unlock = table.deepcopy(own_effects[1] or {})
        unlock.type = "unlock-recipe"
        unlock.recipe = recipe_name
        table.insert(own_effects, unlock)
    end
    local tech = source
    local split
    local old_effects = table.deepcopy(source.effects)
    if #other_effects > 0 and #own_effects > 0 then
        local copy = table.deepcopy(source)
        copy.name = reward_copy_name(source.name)
        copy.effects = own_effects
        copy.localised_name = {
            "",
            locale_utils.find_localised_name(source),
            " (",
            {
                "?",
                {
                    "space-location-name." .. target_name,
                },
                target_name,
            },
            ")",
        }
        copy.prerequisites = table.deepcopy(source.prerequisites)
        split = {
            source = source.name,
            source_effects = table.deepcopy(source.effects),
            other_effects = other_effects,
            copy_name = copy.name,
        }
        source.effects = other_effects
        data:extend({
            copy,
        })
        tech = copy
    elseif #own_effects > 0 then
        -- Every unlock is the bundle's, so the technology follows it as it is, unlocking the variants of the recipes that got one
        source.effects = own_effects
    end
    local edit = {
        tech = tech.name,
        split = split,
        old = {
            unlock_effects = old_effects,
            research_trigger = table.deepcopy(tech.research_trigger),
            unit = table.deepcopy(tech.unit),
            prerequisites = table.deepcopy(tech.prerequisites),
        },
        notes = {},
    }
    if split ~= nil then
        table.insert(edit.notes, "its own technology " .. tech.name .. " (the original keeps its other unlocks)")
    end
    local discovery = discoverers(bundle.planets)
    -- What its technology asks for has to be had on the target without the bundle (else its research would be a cycle)
    excluded = excluded or own_recipes(bundle)
    if tech.research_trigger ~= nil then
        local trigger = tech.research_trigger
        if trigger_tied(before, trigger, bundle.planets) then
            local pick = closest_specific(before, trigger_options(trigger.type), target_rooms, depth_of(before, rewards.trigger_source_keys(trigger)[1], bundle.planets), excluded, avoid, function(candidate)
                return met_by_own_recipe(before, candidate, target_rooms, excluded)
            end)
            if pick ~= nil then
                local new_trigger = retargeted_trigger(trigger, pick.name)
                tech.research_trigger = new_trigger
                table.insert(edit.notes, "trigger " .. trigger_text(trigger) .. " --> " .. trigger_text(new_trigger))
            else
                table.insert(edit.notes, "trigger " .. trigger_text(trigger) .. " kept, since nothing on the target is its counterpart")
            end
        end
    elseif tech.unit ~= nil then
        -- Every family's pack in the research (the home family's and any other planet's) becomes the target's pack, so the target researches its new machine with its own science (user, 2026-09-30); the starting planet's packs are no family's and stay
        local target_pack = family_pack(target_family)
        if target_pack ~= nil and depth_of(before, gutils.key("item", target_pack), target_rooms, excluded) == nil then
            table.insert(edit.notes, "science kept, since the target's pack " .. target_pack .. " needs the reward")
            target_pack = nil
        end
        if target_pack ~= nil then
            local is_family_pack = {}
            for family, _ in pairs(families()) do
                local pack = family_pack(family)
                if pack ~= nil and pack ~= target_pack then
                    is_family_pack[pack] = true
                end
            end
            -- A unit lists each pack once (the game refuses a technology otherwise), so after the first swap the other families' packs just go
            local has_target_pack = false
            for _, ingredient in pairs(tech.unit.ingredients or {}) do
                if pack_name(ingredient) == target_pack then
                    has_target_pack = true
                end
            end
            local ingredients = {}
            local changes = {}
            for _, ingredient in pairs(tech.unit.ingredients or {}) do
                local name = pack_name(ingredient)
                if is_family_pack[name] == nil then
                    table.insert(ingredients, ingredient)
                elseif has_target_pack then
                    table.insert(changes, name .. " dropped")
                else
                    -- A copy, since the tech tree rebuild shares unit ingredient tables between technologies (randomizations/fixes.lua)
                    local swapped = table.deepcopy(ingredient)
                    if swapped[1] ~= nil then
                        swapped[1] = target_pack
                    else
                        swapped.name = target_pack
                    end
                    table.insert(ingredients, swapped)
                    has_target_pack = true
                    table.insert(changes, name .. " --> " .. target_pack)
                end
            end
            if #changes > 0 then
                tech.unit.ingredients = ingredients
                table.insert(edit.notes, "science " .. table.concat(changes, ", "))
            end
        end
    end
    local prerequisites = {}
    local is_listed = {}
    for _, name in pairs(tech.prerequisites or {}) do
        local prerequisite = data.raw.technology[name]
        local tie = prerequisite ~= nil and tech_tie(before, prerequisite, bundle.planets, discovery, bundle.family) or nil
        if tie == nil then
            if is_listed[name] == nil then
                is_listed[name] = true
                table.insert(prerequisites, name)
            end
        else
            table.insert(edit.notes, "prerequisite " .. name .. " dropped (" .. tie .. ")")
        end
    end
    for _, name in pairs(sorted_keys(discoverers(target_rooms))) do
        if is_listed[name] == nil then
            is_listed[name] = true
            table.insert(prerequisites, name)
            table.insert(edit.notes, "prerequisite " .. name .. " added")
        end
    end
    tech.prerequisites = prerequisites
    edit.new = {
        unlock_effects = table.deepcopy(tech.effects),
        research_trigger = table.deepcopy(tech.research_trigger),
        unit = table.deepcopy(tech.unit),
        prerequisites = table.deepcopy(tech.prerequisites),
    }
    if split ~= nil then
        edit.copy = table.deepcopy(tech)
    end
    return edit
end

-- What a bundle's members make, as node keys (like trigger_sources gives): the items and fluids their recipes give, the buildings those items place, and the buildings that are members themselves
local function member_products(bundle)
    local items = dutils.get_all_prots("item")
    local products = {}
    for _, member in pairs(bundle.members) do
        if member.kind == "entity" then
            products[gutils.key("entity", member.name)] = true
        end
        for _, recipe_name in pairs(member.recipe_names) do
            for _, result in pairs((data.raw.recipe[recipe_name] or {}).results or {}) do
                products[gutils.key(result.type, result.name)] = true
                local place_result = result.type == "item" and items[result.name] ~= nil and items[result.name].place_result or nil
                if place_result ~= nil then
                    products[gutils.key("entity", place_result)] = true
                end
            end
        end
    end
    return products
end

-- Other technologies whose research triggers ask for what the bundle's members make, which only its family could meet in the sort before (trigger_tied): once the members move, only the new planet could, so the family's own progression would wait on the reward (Vulcanus researches its big mining drill by crafting a foundry, and its tungsten steel and metallurgic science come after that)
-- Found before any lock moves: trigger_tied reads the recipes' locks too (Aquilo's cryogenic plant is Aquilo's only by its lock, since nothing on Aquilo is isolatable), and a member's moved lock would make its product look like the new planet's
-- skip: names of technologies whose triggers are edited elsewhere (every moving bundle's own technology and its copy)
-- Returns the technology names, sorted
local function dependent_trigger_techs(before, bundle, skip)
    local products = member_products(bundle)
    local names = {}
    for _, tech_name in pairs(sorted_keys(data.raw.technology)) do
        local trigger = data.raw.technology[tech_name].research_trigger
        if skip[tech_name] == nil and trigger ~= nil then
            local asks_for_member = false
            for _, source in pairs(trigger_sources(trigger)) do
                if products[source] ~= nil then
                    asks_for_member = true
                end
            end
            if asks_for_member and trigger_tied(before, trigger, bundle.planets) then
                table.insert(names, tech_name)
            end
        end
    end
    return names
end

-- The technologies dependent_trigger_techs found ask for the family's closest counterpart instead, as the bundle's own technology asks for the target's (edit_tech): closest_specific on the family's planets, had there without the bundle's recipes (excluded) and without researching the technology itself (else its research would be a cycle), and crafted there by a recipe of its own (met_by_own_recipe)
-- skip: technologies an earlier bundle retied already; avoid: the products only reward machines make (avoided_materials)
-- Returns the edits as a list of { tech, old, new } (research triggers, for revert_bundle and redo_bundle), and notes for the log
local function retie_dependent_triggers(before, bundle, tech_names, skip, excluded, avoid)
    local edits = {}
    local notes = {}
    for _, tech_name in pairs(tech_names) do
        local tech = data.raw.technology[tech_name]
        local trigger = tech ~= nil and tech.research_trigger or nil
        if skip[tech_name] == nil and trigger ~= nil then
            local tech_excluded = table.deepcopy(excluded)
            tech_excluded[gutils.key("technology", tech_name)] = true
            local pick = closest_specific(before, trigger_options(trigger.type), bundle.planets, depth_of(before, rewards.trigger_source_keys(trigger)[1], bundle.planets), tech_excluded, avoid, function(candidate)
                return met_by_own_recipe(before, candidate, bundle.planets, tech_excluded)
            end)
            if pick ~= nil then
                local new_trigger = retargeted_trigger(trigger, pick.name)
                table.insert(edits, {
                    tech = tech_name,
                    old = table.deepcopy(trigger),
                    new = table.deepcopy(new_trigger),
                })
                tech.research_trigger = new_trigger
                table.insert(notes, tech_name .. " " .. trigger_text(trigger) .. " --> " .. trigger_text(new_trigger))
            else
                table.insert(notes, tech_name .. " " .. trigger_text(trigger) .. " kept, since nothing at home is its counterpart")
            end
        end
    end
    return edits, notes
end

-- Sets the research triggers of retie_dependent_triggers' edits to their old ones (in reverse order) or their new ones
local function set_dependent_triggers(edits, use_old)
    local first, last, step = 1, #edits, 1
    if use_old then
        first, last, step = #edits, 1, -1
    end
    for i = first, last, step do
        local edit = edits[i]
        local tech = data.raw.technology[edit.tech]
        if tech ~= nil then
            tech.research_trigger = table.deepcopy(use_old and edit.old or edit.new)
        end
    end
end

-- Puts a technology edit back: the copy goes and the original unlocks the bundle again, or the technology's trigger, research and prerequisites are as they were
local function restore_tech(edit)
    if edit.split ~= nil then
        data.raw.technology[edit.split.copy_name] = nil
        local source = data.raw.technology[edit.split.source]
        if source ~= nil then
            source.effects = table.deepcopy(edit.split.source_effects)
        end
        return
    end
    local tech = data.raw.technology[edit.tech]
    if tech == nil then
        return
    end
    tech.effects = table.deepcopy(edit.old.unlock_effects)
    tech.research_trigger = table.deepcopy(edit.old.research_trigger)
    tech.unit = table.deepcopy(edit.old.unit)
    tech.prerequisites = table.deepcopy(edit.old.prerequisites)
end

-- Applies a technology edit again after restore_tech
local function apply_tech(edit)
    if edit.split ~= nil then
        if data.raw.technology[edit.split.copy_name] == nil then
            data:extend({
                table.deepcopy(edit.copy),
            })
        end
        local source = data.raw.technology[edit.split.source]
        if source ~= nil then
            source.effects = table.deepcopy(edit.split.other_effects)
        end
        return
    end
    local tech = data.raw.technology[edit.tech]
    if tech == nil then
        return
    end
    tech.effects = table.deepcopy(edit.new.unlock_effects)
    tech.research_trigger = table.deepcopy(edit.new.research_trigger)
    tech.unit = table.deepcopy(edit.new.unit)
    tech.prerequisites = table.deepcopy(edit.new.prerequisites)
end

-- Takes a recipe out of every technology's unlocks
local function remove_unlocks(recipe_name)
    for _, technology in pairs(data.raw.technology) do
        local effects = technology.effects or {}
        for i = #effects, 1, -1 do
            if effects[i].type == "unlock-recipe" and effects[i].recipe == recipe_name then
                table.remove(effects, i)
            end
        end
    end
end

-- The surface conditions of a retired recipe (one that left for a variant on the new planet): a surface property of the mod's own that no surface has a value for, asked for above its default, so no surface meets them
-- The recipe stays in the game, locked to nowhere and unlocked by nothing, so a superposition holds its old planet's lock and unlock as debt edges into OR nodes, and item randomization trades its results like every other recipe's (a recipe taken out of the game left a node only the old world had, whose results didn't follow the trades)
-- Not one of the lock stage's pool properties, which come and go with each plan (surface_sets.apply_properties); the prototype is a copy of any surface property, since data.raw has one by then
local RETIRED_PROPERTY = "propertyrandomizer-retired"
local function retired_conditions()
    if data.raw["surface-property"][RETIRED_PROPERTY] == nil then
        local template_name = sorted_keys(data.raw["surface-property"])[1]
        local property = table.deepcopy(data.raw["surface-property"][template_name])
        property.name = RETIRED_PROPERTY
        property.default_value = 0
        property.order = "z[propertyrandomizer]-retired"
        property.localised_name = nil
        property.localised_description = nil
        property.localised_unit_key = nil
        property.is_time = nil
        data:extend({
            property,
        })
    end
    return {
        {
            property = RETIRED_PROPERTY,
            min = 1,
        },
    }
end

-- A member recipe remade for the target with the target's own ingredients (target_ingredients): a planet variant named after the target, with the target's icon as a badge, that the caller locks to the target's rooms (locks.fix) and unlocks with the bundle's technology (edit_tech's renamed)
local function variant_recipe(recipe, ingredients, target_name)
    local variant = table.deepcopy(recipe)
    variant.name = "propertyrandomizer-" .. recipe.name .. "-on-" .. target_name
    variant.localised_name = scaffolds.variant_name(recipe, target_name)
    local icons = scaffolds.badged_icons(recipe, target_name)
    if icons ~= nil then
        variant.icons = icons
        variant.icon = nil
    end
    variant.ingredients = ingredients
    variant.surface_conditions = nil
    return variant
end

-- Re-homing (outside superposed mode, where nothing later pays for what a machine's old planet loses): the special machines trade places (rewards.draw), so each planet's science moves into the machine that arrived there (user, 2026-09-30: machines "permuted like fluids... so that each planet still gets a special machine"; "Recipe category randomization should allow fixes for the home science thing")
-- Only what the science needs moves, and the machine keeps its other recipes (user: "keep the machine's original recipes where possible, only fixing for things like the science recipes or things science depends on"); unified recipe-category randomization can change the new categories afterward
-- A planet whose science doesn't fit the arriving machine keeps its own machine instead of getting copies of recipes (user: "I prefer reversion over extra copies")

-- Whether a context has isolatability (no imports), which is what a planet loses when its machine leaves: anything else can use the machine delivered from its new planet
local function context_is_isolatable(context)
    local abilities = top.context_abilities(context)
    return abilities ~= nil and string.sub(abilities, top.ISOLATABILITY, top.ISOLATABILITY) == "1"
end

-- The recipes a special machine's planet needs re-homed once it leaves: every recipe on the proof (top.path, stopping at rooms like path_avoids) of its science pack's recipes in their isolatable contexts on the family's planets, in ref (the game as the earlier planetary stages left it, or the sort before), that only the bundle's machines craft (only_machines_craft), its own recipes aside (excluded)
-- The proof goes through the pack's technologies too, so a trigger's item (the big mining drill for tungsten steel) counts
-- Returns sorted recipe names, empty when the family has no science pack of its own
local function science_needs(ref, bundle, excluded, crafters_of)
    local pack = family_pack(bundle.family)
    if pack == nil then
        return {}
    end
    local nci = ref.sort_info.node_to_context_inds
    local inds = {}
    for _, recipe_name in pairs(sorted_keys(data.raw.recipe)) do
        local recipe = data.raw.recipe[recipe_name]
        local makes_pack = false
        for _, result in pairs(recipe.results or {}) do
            if result.type == "item" and result.name == pack then
                makes_pack = true
            end
        end
        if makes_pack and not recycling.looks_generated(recipe) then
            for context, ind in pairs(nci[gutils.key("recipe", recipe_name)] or {}) do
                if top.context_home(context) == nil and bundle.planets[top.context_room(context)] ~= nil and context_is_isolatable(context) then
                    table.insert(inds, ind)
                end
            end
        end
    end
    if #inds == 0 then
        return {}
    end
    table.sort(inds)
    local path = top.path(ref.graph, inds, ref.sort_info, {
        stop_if = function(pebble)
            local node_type = gutils.deconstruct(pebble.node_key).type
            return node_type == "room" or node_type == "reachable-room"
        end,
    })
    local machines = bundle_machines(bundle)
    local needs = {}
    for path_ind, _ in pairs(path.in_path) do
        local pebble = ref.sort_info.sorted[path_ind]
        local node = gutils.deconstruct(pebble.node_key)
        if node.type == "recipe" and bundle.planets[top.context_room(pebble.context)] ~= nil and excluded[pebble.node_key] == nil then
            local recipe = data.raw.recipe[node.name]
            if recipe ~= nil and not recycling.looks_generated(recipe) and only_machines_craft(recipe, machines, crafters_of) then
                needs[node.name] = true
            end
        end
    end
    return sorted_keys(needs)
end

-- The category a recipe takes in the machines that arrived (machines: entity name --> true), or nil when none fits
-- One of their crafting categories whose machine has fluid boxes for the recipe's fluids (counted by production type, as lib/lookup/2-simple/recipe.lua sizes categories), preferring one only they craft, then by name
-- Never a furnace's (furnaces pick recipes by ingredient, see lib/furnace-selection.lua), a machine's with a fixed recipe (it makes only that one, prototypes/AssemblingMachinePrototype.html), or the base crafting category for a recipe with a fluid (prototypes/RecipePrototype.html: it can't contain those)
local function arriving_category(recipe, machines, crafters_of)
    local fluids = lutils.find_recipe_fluids(recipe)
    local fitting = {}
    for _, name in pairs(sorted_keys(machines)) do
        local machine = dutils.get_prot("entity", name)
        if machine ~= nil and machine.type ~= "furnace" and machine.fixed_recipe == nil then
            local inputs = 0
            local outputs = 0
            for _, box in pairs(machine.fluid_boxes or {}) do
                if box.production_type == "input" then
                    inputs = inputs + 1
                elseif box.production_type == "output" then
                    outputs = outputs + 1
                end
            end
            if fluids.input <= inputs and fluids.output <= outputs then
                for _, category in pairs(machine.crafting_categories or {}) do
                    if not (category == fluid_ports.HAND_CATEGORY and fluids.input + fluids.output > 0) then
                        fitting[category] = true
                    end
                end
            end
        end
    end
    local best
    local best_is_own = false
    for _, category in pairs(sorted_keys(fitting)) do
        local is_own = true
        for crafter, _ in pairs(crafters_of[category] or {}) do
            if machines[crafter] == nil then
                is_own = false
            end
        end
        if best == nil or (is_own and not best_is_own) then
            best = category
            best_is_own = is_own
        end
    end
    return best
end

-- The in-place edits that move needs (recipe names) into the arriving machines' categories, as a list of { recipe, old = { categories, category }, new = categories }
-- Returns nil and the first recipe that fits none of them
local function rehome_plan(needs, machines, crafters_of)
    local edits = {}
    for _, recipe_name in pairs(needs) do
        local recipe = data.raw.recipe[recipe_name]
        local category = recipe ~= nil and arriving_category(recipe, machines, crafters_of) or nil
        if category == nil then
            return nil, recipe_name
        end
        table.insert(edits, {
            recipe = recipe_name,
            old = {
                categories = table.deepcopy(recipe.categories),
                category = recipe.category,
            },
            new = {
                category,
            },
        })
    end
    return edits
end

-- Applies re-homing edits (use_old false) or puts them back (use_old true, in reverse order)
local function set_rehomed(edits, use_old)
    local first, last, step = 1, #edits, 1
    if use_old then
        first, last, step = #edits, 1, -1
    end
    for i = first, last, step do
        local edit = edits[i]
        local recipe = data.raw.recipe[edit.recipe]
        if recipe ~= nil then
            if use_old then
                recipe.categories = table.deepcopy(edit.old.categories)
                recipe.category = edit.old.category
            else
                recipe.categories = table.deepcopy(edit.new)
                recipe.category = nil
            end
        end
    end
end

-- Bundle id --> moved bundle: tech (the edited technology, a copy for a split), source_tech, member_recipes (after-world names), variants (original recipe name --> { name, prototype, original, swaps }), family, planets (its old rooms), target (room key), target_rooms, lock_ids (the members' moved locks, see locks.moved), tech_edit (see edit_tech), and the repair flags tech_restored and variants_reverted
rewards.moved = {}

-- Bundles (by id) an earlier attempt of the rest of randomization needed home (the settlement sent them back, see execute.lua): they stay in every later roll, since a reward can't go back after the attempt without breaking what the attempt promised on its new planet (user, 2026-09-30: a revert rather than a share)
-- Kept across planetary.reset, for the whole load
rewards.pinned = {}

-- Moves the reward bundles of the game in the sort before: each member's lock through locks.move (the lock stage's repairs and settlers then cover them), and the technology through edit_tech
-- Returns rewards.moved
-- Moves every bundle rewards.draw gives a target: the members' locks move there (locks.move), a member recipe the target can't make as it is gets a variant there with the target's own ingredients and retires (retired_conditions; an in-place swap would take the old planet's ingredient from it too, and an ingredient edge isn't an OR node the superposition could hold as debt), and the technology follows (edit_tech)
-- variants_of (original recipe name --> variant names, the check's, see check.required_failures) gets the variants, so the originals' goals count as met by them where they went (rewards.transport)
-- options.rehome (outside superposed mode): each special machine's planet has its science re-homed into the machine that arrives there (science_needs, rehome_plan), and the draw only permutes the machines where that fits; options.current is the game as the earlier stages left it, in which the needs are found
rewards.execute = function(id, before, variants_of, options)
    local bundles = rewards.reward_bundles(before)
    local rehome = options ~= nil and options.rehome == true
    local crafters_of = crafters_by_category()
    -- Special machine bundle id --> the recipes its planet needs re-homed once it leaves
    local needs
    if rehome then
        needs = {}
        local ref = options.current or before
        for _, bundle_id in pairs(sorted_keys(bundles)) do
            if is_special_machine(bundles[bundle_id]) then
                needs[bundle_id] = science_needs(ref, bundles[bundle_id], own_recipes(bundles[bundle_id]), crafters_of)
            end
        end
    end
    local fits
    if rehome then
        fits = function(leaving_id, arriving_id)
            local own = needs[leaving_id] or {}
            if #own == 0 then
                return true
            end
            return arriving_id ~= nil and rehome_plan(own, bundle_machines(bundles[arriving_id]), crafters_of) ~= nil
        end
    end
    local targets = rewards.draw(bundles, before, id, fits)
    -- Family --> the special machine bundle arriving there, whose categories the family's science moves into
    local arriving = {}
    if rehome then
        for bundle_id, room_key in pairs(targets) do
            if needs[bundle_id] ~= nil then
                arriving[family_of(room_key)] = bundle_id
            end
        end
    end
    -- Arriving bundle id --> the recipes (node keys) its target's science is re-homed into it: nothing about its own move may need them, or it would wait on itself (the cryogenic plant's new trigger on Vulcanus can't be something Vulcanus now makes in cryogenic plants)
    local rehomed_into = {}
    if rehome then
        for family, arriving_id in pairs(arriving) do
            for leaving_id, recipe_names in pairs(needs) do
                if targets[leaving_id] ~= nil and bundles[leaving_id].family == family then
                    rehomed_into[arriving_id] = rehomed_into[arriving_id] or {}
                    for _, recipe_name in pairs(recipe_names) do
                        rehomed_into[arriving_id][gutils.key("recipe", recipe_name)] = true
                    end
                    -- The machine leaving the target is gone from it too
                    for recipe_key, _ in pairs(own_recipes(bundles[leaving_id])) do
                        rehomed_into[arriving_id][recipe_key] = true
                    end
                end
            end
        end
    end
    local avoid = avoided_materials(bundles)
    -- Every moving bundle's technology (and the copy a split one takes) has its trigger edited by edit_tech, so no bundle's retie_dependent_triggers touches it
    local retie_skip = {}
    for bundle_id, _ in pairs(targets) do
        retie_skip[bundles[bundle_id].tech] = true
        retie_skip[reward_copy_name(bundles[bundle_id].tech)] = true
    end
    -- Which other technologies' triggers each bundle's move would strand, found while every lock is still home
    local dependent_techs = {}
    for _, bundle_id in pairs(sorted_keys(targets)) do
        dependent_techs[bundle_id] = dependent_trigger_techs(before, bundles[bundle_id], retie_skip)
    end
    for _, bundle_id in pairs(sorted_keys(targets)) do
        local bundle = bundles[bundle_id]
        local target = targets[bundle_id]
        local target_rooms = families()[family_of(target)] or {
            [target] = true,
        }
        local target_name = gutils.deconstruct(target).name
        local map = {}
        for room_key, _ in pairs(bundle.planets) do
            map[room_key] = target
        end
        local excluded = own_recipes(bundle)
        -- Nothing about the move (its variants' substitutes, its companions, its research) may rely on what its target now makes in this machine (rehomed_into)
        for recipe_key, _ in pairs(rehomed_into[bundle_id] or {}) do
            excluded[recipe_key] = true
        end
        local variants = {}
        local renamed = {}
        for _, member in pairs(bundle.members) do
            if member.kind == "recipe" then
                for _, recipe_name in pairs(member.recipe_names) do
                    local recipe = data.raw.recipe[recipe_name]
                    if recipe ~= nil and variants[recipe_name] == nil then
                        local ingredients, swaps = target_ingredients(before, recipe_name, target_rooms, bundle.planets, excluded, avoid)
                        if ingredients ~= nil and #swaps > 0 then
                            local variant = variant_recipe(recipe, ingredients, target_name)
                            variants[recipe_name] = {
                                name = variant.name,
                                prototype = variant,
                                original = table.deepcopy(recipe),
                                swaps = swaps,
                            }
                            renamed[recipe_name] = variant.name
                        end
                    end
                end
            end
        end
        local lock_ids = {}
        for _, member in pairs(bundle.members) do
            if not (member.kind == "recipe" and variants[member.name] ~= nil) then
                local lock_id = locks.move(member.kind, member.name, map)
                if lock_id ~= nil then
                    table.insert(lock_ids, lock_id)
                end
            end
        end
        if #lock_ids > 0 or next(variants) ~= nil then
            for _, recipe_name in pairs(sorted_keys(variants)) do
                local variant = variants[recipe_name]
                data:extend({
                    table.deepcopy(variant.prototype),
                })
                data.raw.recipe[recipe_name].surface_conditions = retired_conditions()
                -- The recycler makes no recycling recipe from a retired recipe (lib/recycling.lua's can_recycle), else recycling the machine could give the old planet's ingredients anywhere
                data.raw.recipe[recipe_name].auto_recycle = false
                if variants_of ~= nil then
                    variants_of[recipe_name] = variants_of[recipe_name] or {}
                    table.insert(variants_of[recipe_name], variant.name)
                end
                locks.fix("recipe", variant.name, target_rooms)
            end
            -- The machine's other recipes come along as additions (companions_of): unlocked on the new planet too as they are, or as a planet variant with the target's own fluid or intermediate; and the fuel its burners take, as a variant (fuel_variants_for); the originals stay, so the old planet is owed nothing for them
            local shared, companion_variants = companions_of(before, bundle, target_rooms, avoid)
            local extra_variants = {}
            local variant_unlocks = {}
            local function add_variant(recipe_name, spec, kind)
                local variant = variant_recipe(data.raw.recipe[recipe_name], spec.ingredients, target_name)
                data:extend({
                    table.deepcopy(variant),
                })
                locks.fix("recipe", variant.name, target_rooms)
                extra_variants[recipe_name] = {
                    name = variant.name,
                    prototype = variant,
                    swaps = spec.swaps,
                    kind = kind,
                }
                table.insert(variant_unlocks, variant.name)
            end
            for _, recipe_name in pairs(sorted_keys(companion_variants)) do
                add_variant(recipe_name, companion_variants[recipe_name], "companion")
            end
            local fuels = fuel_variants_for(before, bundle, target_rooms, shared, excluded, avoid)
            for _, recipe_name in pairs(sorted_keys(fuels)) do
                if extra_variants[recipe_name] == nil then
                    add_variant(recipe_name, fuels[recipe_name], "fuel")
                end
            end
            -- The old planet's science moves into the machine arriving there, after the target's copies above were made from the originals
            -- A recipe that moves is no longer the machine's, so the target doesn't unlock it as a companion
            local rehome_edits = {}
            local rehome_notes = {}
            local arriving_id = nil
            if rehome and #(needs[bundle_id] or {}) > 0 then
                arriving_id = arriving[bundle.family]
                local plan = arriving_id ~= nil and rehome_plan(needs[bundle_id], bundle_machines(bundles[arriving_id]), crafters_of) or nil
                -- The draw only permutes the machines where the needs fit, so this is a guard
                assert(plan ~= nil, "Planet rewards: no arriving machine takes " .. bundle.tech .. "'s planet's science")
                set_rehomed(plan, false)
                rehome_edits = plan
                for _, edit in pairs(plan) do
                    shared[edit.recipe] = nil
                    table.insert(rehome_notes, edit.recipe .. " " .. table.concat(furnace_selection.recipe_categories({
                        categories = edit.old.categories,
                        category = edit.old.category,
                    }), "+") .. " --> " .. edit.new[1])
                end
            end
            local extra_unlocks = sorted_keys(shared)
            for _, name in pairs(variant_unlocks) do
                table.insert(extra_unlocks, name)
            end
            local tech_edit = edit_tech(before, bundle, target, renamed, excluded, avoid, extra_unlocks)
            -- Other technologies whose triggers asked for the members ask for something the old planet still has
            local trigger_edits, trigger_notes = retie_dependent_triggers(before, bundle, dependent_techs[bundle_id], retie_skip, excluded, avoid)
            for _, edit in pairs(trigger_edits) do
                retie_skip[edit.tech] = true
            end
            for _, recipe_name in pairs(sorted_keys(variants)) do
                remove_unlocks(recipe_name)
            end
            if next(variants) ~= nil or next(extra_variants) ~= nil then
                locks.realize()
            end
            local member_recipes = {}
            for _, member in pairs(bundle.members) do
                for _, recipe_name in pairs(member.recipe_names) do
                    member_recipes[renamed[recipe_name] or recipe_name] = true
                end
            end
            rewards.moved[bundle_id] = {
                tech = tech_edit.tech,
                source_tech = bundle.tech,
                member_recipes = member_recipes,
                shared = shared,
                variants = variants,
                extra_variants = extra_variants,
                family = bundle.family,
                planets = bundle.planets,
                target = target,
                target_rooms = target_rooms,
                lock_ids = lock_ids,
                tech_edit = tech_edit,
                trigger_edits = trigger_edits,
                trigger_notes = trigger_notes,
                rehome_edits = rehome_edits,
                rehome_notes = rehome_notes,
                arriving = arriving_id,
            }
        end
    end
    return rewards.moved
end

-- Where the goals of the recipes that got variants go, as check.transport entries like locks.transport's: their old planets' goals are met by the variant on the target (variants_of tells the check)
rewards.transport = function()
    local transport = {}
    for _, bundle_id in pairs(sorted_keys(rewards.moved)) do
        local bundle = rewards.moved[bundle_id]
        if not bundle.variants_reverted then
            for recipe_name, _ in pairs(bundle.variants) do
                local map = {}
                for room_key, _ in pairs(bundle.planets) do
                    map[room_key] = bundle.target
                end
                transport[gutils.key("recipe", recipe_name)] = {
                    map = map,
                }
            end
        end
    end
    return transport
end

-- The moved bundle (and its id) that retired this recipe for a variant on the new planet and hasn't given it back, or nil
rewards.bundle_of_retired = function(recipe_name)
    for bundle_id, bundle in pairs(rewards.moved) do
        if bundle.variants[recipe_name] ~= nil and not bundle.variants_reverted then
            return bundle, bundle_id
        end
    end
    return nil
end

-- Puts a retired recipe back as it was (its own surface conditions) or retires it again
local function set_retired(variant, is_retired)
    local recipe = data.raw.recipe[variant.original.name]
    if recipe == nil then
        recipe = table.deepcopy(variant.original)
        data:extend({
            recipe,
        })
    end
    if is_retired then
        recipe.surface_conditions = retired_conditions()
        recipe.auto_recycle = false
    else
        recipe.surface_conditions = table.deepcopy(variant.original.surface_conditions)
        recipe.auto_recycle = variant.original.auto_recycle
    end
end

-- The revert of a bundle with variants: the variants leave, the retired originals come back and the technology is as it was (rewards.revert_bundle puts the bundle's locks back as well)
rewards.revert_variants = function(bundle_id)
    local bundle = rewards.moved[bundle_id]
    if next(bundle.variants) == nil or bundle.variants_reverted then
        return
    end
    for _, recipe_name in pairs(sorted_keys(bundle.variants)) do
        local variant = bundle.variants[recipe_name]
        data.raw.recipe[variant.name] = nil
        locks.unfix("recipe", variant.name)
        set_retired(variant, false)
    end
    restore_tech(bundle.tech_edit)
    bundle.tech_restored = true
    bundle.variants_reverted = true
    locks.realize()
end

rewards.redo_variants = function(bundle_id)
    local bundle = rewards.moved[bundle_id]
    if not bundle.variants_reverted then
        return
    end
    for _, recipe_name in pairs(sorted_keys(bundle.variants)) do
        local variant = bundle.variants[recipe_name]
        set_retired(variant, true)
        if data.raw.recipe[variant.name] == nil then
            data:extend({
                table.deepcopy(variant.prototype),
            })
        end
        locks.fix("recipe", variant.name, bundle.target_rooms)
    end
    apply_tech(bundle.tech_edit)
    bundle.tech_restored = false
    bundle.variants_reverted = false
    locks.realize()
end

-- The moved bundle (and its id) one of whose members' locks this is (a locks.moved target id), or nil
rewards.bundle_of_lock = function(lock_id)
    for bundle_id, bundle in pairs(rewards.moved) do
        for _, id in pairs(bundle.lock_ids) do
            if id == lock_id then
                return bundle, bundle_id
            end
        end
    end
    return nil
end

-- Puts a whole bundle back (user, 2026-09-30: a reward its old planet needs goes back rather than being shared with it): its members' locks, its variants (their retired originals as they were) and its technology as it was; the bundle is forgotten
-- Returns what it put back, for rewards.redo_bundle, or nil if the bundle wasn't moved
rewards.revert_bundle = function(bundle_id)
    local bundle = rewards.moved[bundle_id]
    if bundle == nil then
        return nil
    end
    local reverted = locks.revert(bundle.lock_ids)
    if next(bundle.variants) ~= nil then
        rewards.revert_variants(bundle_id)
    else
        restore_tech(bundle.tech_edit)
    end
    set_dependent_triggers(bundle.trigger_edits or {}, true)
    set_rehomed(bundle.rehome_edits or {}, true)
    for _, extra in pairs(bundle.extra_variants or {}) do
        data.raw.recipe[extra.name] = nil
        locks.unfix("recipe", extra.name)
    end
    if next(bundle.extra_variants or {}) ~= nil then
        locks.realize()
    end
    rewards.moved[bundle_id] = nil
    return {
        bundle = bundle,
        reverted = reverted,
    }
end

-- Moves a bundle rewards.revert_bundle put back again (its undo, given what it returned)
rewards.redo_bundle = function(bundle_id, undo)
    local bundle = undo.bundle
    rewards.moved[bundle_id] = bundle
    locks.restore(undo.reverted)
    if next(bundle.variants) ~= nil then
        rewards.redo_variants(bundle_id)
    else
        apply_tech(bundle.tech_edit)
    end
    set_dependent_triggers(bundle.trigger_edits or {}, false)
    set_rehomed(bundle.rehome_edits or {}, false)
    for _, extra in pairs(bundle.extra_variants or {}) do
        if data.raw.recipe[extra.name] == nil then
            data:extend({
                table.deepcopy(extra.prototype),
            })
        end
        locks.fix("recipe", extra.name, bundle.target_rooms)
    end
    if next(bundle.extra_variants or {}) ~= nil then
        locks.realize()
    end
end

-- A bundle any of whose locks the lock stage or settlement put back on its own goes back entirely (its other locks, its variants and its technology), since a reward is moved or not
-- A planet whose science moved into the machine that arrived there (re-homing) needs that machine to stay, so when it goes back, the planet's own machine comes back too, re-homing and all
-- Returns what revert_bundle returned for each bundle it put back, so the caller can forget their goal transport
rewards.sync = function()
    local undos = {}
    for _, bundle_id in pairs(sorted_keys(rewards.moved)) do
        local bundle = rewards.moved[bundle_id]
        local is_back = false
        for _, lock_id in pairs(bundle.lock_ids) do
            if locks.moved[lock_id] == nil then
                is_back = true
            end
        end
        if is_back or (next(bundle.variants) ~= nil and bundle.variants_reverted) then
            table.insert(undos, rewards.revert_bundle(bundle_id))
            log("Planet reward: " .. bundle.source_tech .. " stays, since part of it went back")
        end
    end
    local is_changed = true
    while is_changed do
        is_changed = false
        for _, bundle_id in pairs(sorted_keys(rewards.moved)) do
            local bundle = rewards.moved[bundle_id]
            if bundle ~= nil and bundle.arriving ~= nil and rewards.moved[bundle.arriving] == nil then
                table.insert(undos, rewards.revert_bundle(bundle_id))
                log("Planet reward: " .. bundle.source_tech .. " stays, since the machine that was to take over its planet's science went back")
                is_changed = true
            end
        end
    end
    return undos
end

-- The moved bundle (and its id) one of whose members this recipe is, or nil
rewards.bundle_of_recipe = function(recipe_name)
    for bundle_id, bundle in pairs(rewards.moved) do
        if bundle.member_recipes[recipe_name] ~= nil then
            return bundle, bundle_id
        end
    end
    return nil
end

-- One line per moved bundle for the log, after the repairs (a bundle its old planet needed went back and is gone from here)
rewards.log_state = function()
    for _, bundle_id in pairs(sorted_keys(rewards.moved)) do
        local bundle = rewards.moved[bundle_id]
        log("Planet reward: " .. bundle.source_tech .. " --> " .. gutils.deconstruct(bundle.target).name .. ": moved")
    end
end

-- The moved bundle (and its id) whose technology this is, or nil
rewards.bundle_of_tech = function(tech_name)
    for bundle_id, bundle in pairs(rewards.moved) do
        if bundle.tech == tech_name then
            return bundle, bundle_id
        end
    end
    return nil
end

-- The moved bundle (and its id) that edited this technology's research trigger, or nil: its own technology (edit_tech) or another one its move retied (retie_dependent_triggers)
rewards.bundle_of_trigger = function(tech_name)
    for bundle_id, bundle in pairs(rewards.moved) do
        if bundle.tech == tech_name then
            return bundle, bundle_id
        end
        for _, edit in pairs(bundle.trigger_edits or {}) do
            if edit.tech == tech_name then
                return bundle, bundle_id
            end
        end
    end
    return nil
end

-- One line per moved bundle for the log
rewards.log_moves = function()
    local ids = sorted_keys(rewards.moved)
    log("Planet rewards: " .. #ids .. " bundles moved")
    for _, bundle_id in pairs(ids) do
        local bundle = rewards.moved[bundle_id]
        local swaps = {}
        for _, recipe_name in pairs(sorted_keys(bundle.variants)) do
            local variant = bundle.variants[recipe_name]
            for _, swap in pairs(variant.swaps) do
                table.insert(swaps, variant.name .. " takes " .. swap.to .. " for " .. swap.from)
            end
        end
        local shared = sorted_keys(bundle.shared or {})
        local extras = {}
        for _, recipe_name in pairs(sorted_keys(bundle.extra_variants or {})) do
            local extra = bundle.extra_variants[recipe_name]
            local parts = {}
            for _, swap in pairs(extra.swaps) do
                table.insert(parts, swap.to .. " for " .. swap.from)
            end
            table.insert(extras, extra.name .. " (" .. extra.kind .. ")" .. (#parts > 0 and " takes " .. table.concat(parts, ", ") or " as it is"))
        end
        log("Planet reward: " .. bundle.source_tech .. ": " .. room_names(bundle.planets) .. " --> " .. gutils.deconstruct(bundle.target).name .. "; locks " .. table.concat(bundle.lock_ids, ", ") .. "; technology: " .. (#bundle.tech_edit.notes > 0 and table.concat(bundle.tech_edit.notes, ", ") or "unchanged") .. (#swaps > 0 and "; variants (the originals retire): " .. table.concat(swaps, ", ") or "") .. (#shared > 0 and "; unlocked there too: " .. table.concat(shared, ", ") or "") .. (#extras > 0 and "; variants there: " .. table.concat(extras, ", ") or "") .. (#(bundle.trigger_notes or {}) > 0 and "; triggers at home: " .. table.concat(bundle.trigger_notes, ", ") or "") .. (#(bundle.rehome_notes or {}) > 0 and "; re-homed at home: " .. table.concat(bundle.rehome_notes, ", ") or ""))
    end
end

return rewards

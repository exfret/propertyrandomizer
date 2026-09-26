-- Entity randomization: changes how entities are acquired (the acquisition kinds in lib/logic/acquisition.lua)
-- So far build slots (which item places which entity) and autoplace slots (which entity map generation puts where)
-- An item's ability to place something, or a room's autoplace spot, is a base, and an entity's need for one is a head
-- Autoplaced entities can trade autoplace slots or stop being autoplaced, and built entities can be found in the wild instead and salvaged (mined for an item that places them)
-- Each item places only one entity (planting counts, see common.set_placed_entity), so bases are matched to heads one to one, with promotion keeping mechanic contexts and recipe reachability
-- With first pass (and item randomization), a build base belongs to the item's identity, so an item keeps placing its (new) entity wherever item randomization moves it
-- Reflects before item randomization (see execute-new.lua), which copies items' names and icons into recipes
-- Spoofs let items that place nothing in vanilla (like modules) also place an entity, on top of everything they already do; that entity's own item then places nothing (a Vestige)

local categories = require("helper-tables/categories")
local acquisition = require("lib/logic/acquisition")
local dutils = require("lib/data-utils")
local gutils = require("lib/graph/graph-utils")
local locale = require("lib/locale")
local rng = require("lib/random/rng")
local material_costs = require("lib/cost/material-costs/sa")
local common = require("randomizations/graph/entity/common")

local key = gutils.key

local entity = {}

entity.id = "entity"

-- Each item places one entity, so each base can only be used once
entity.with_replacement = false

-- An item only takes over an entity if it costs within this factor of the entity's own item
local COST_TOLERANCE = 4
-- Chance that an entity may be placed by an item that places nothing in vanilla (a spoof base), whose own item then places nothing (a Vestige) unless another entity takes it
local SPOOF_CHANCE = 0.25
-- The spoofed entity-build-item node that items placing nothing in vanilla get an edge to, so their placing enters the pool of bases
local SPOOF_SINK_NAME = "propertyrandomizer-spoof-placer"
-- Chance that an entity built from an item may instead be found in the wild in another entity's autoplace slot, and salvaged (mined for an item that places it)
local SALVAGE_CHANCE = 0.25
-- An entity only takes an autoplace slot if its collision box is at most this many times the size of the slot's own entity's (see common.fits_autoplace_of)
local AUTOPLACE_AREA_TOLERANCE = 2
-- Chance that an entity built from an item may instead be carried by a unit a spawner spawns, which drops an item that places it when killed (loot)
local CARRIER_CHANCE = 0.25
-- Chance that a unit a spawner spawns may also be placed by an item, as a friendly biter
local FRIENDLY_CHANCE = 0.25
-- A unit in a spawn slot whose unit stopped spawning at some evolution (transient, see acquisition.spawn_class) spawns at least this share of its highest weight at every evolution, since logic counts on it
local TRANSIENT_WEIGHT_FLOOR = 0.1

-- Item types that can place an entity without it getting in the way of what they already do, since their other uses go through the GUI
-- Capsules and repair packs and the like are used by clicking, which placing would take over
local spoofable_item_types = {
    ["item"] = true,
    ["module"] = true,
    ["ammo"] = true,
    ["tool"] = true,
    ["gun"] = true,
    ["item-with-entity-data"] = true,
    ["item-with-label"] = true,
    ["item-with-inventory"] = true,
    ["item-with-tags"] = true,
    ["space-platform-starter-pack"] = true,
    ["armor"] = true,
}

-- Entity types that keep their own items for now because of special placement rules
local excluded_entity_types = {
    ["space-platform-hub"] = true,
    ["cargo-landing-pad"] = true,
}

-- Items whose placing can move to another entity; other item types that place entities (like rail planners) place in special ways
local function claimable_item(item)
    if item == nil or spoofable_item_types[item.type] == nil or item.hidden or item.parameter then
        return false
    end
    for _, flag in pairs(item.flags or {}) do
        if flag == "spawnable" or flag == "only-in-cursor" or flag == "not-stackable" then
            return false
        end
    end
    return true
end

-- An autoplaced entity's build slot moves like any other, since it's still found in the world through its autoplace slot
local function claimable_entity(prototype)
    if prototype == nil or prototype.hidden then
        return false
    end
    -- Rails and rolling stock are placed with rail planners and items with entity data
    if excluded_entity_types[prototype.type] ~= nil or categories.rail[prototype.type] ~= nil or categories.rolling_stock[prototype.type] ~= nil then
        return false
    end
    return true
end

-- Items that place nothing in vanilla and could also place an entity
-- Items that already place something (entities, plants or tiles) are left out, since placing that and an entity would both be left clicks
local function spoofable_item(item)
    return claimable_item(item) and not common.places_something(item)
end

-- Entity name --> number of rooms logic finds it autoplaced in (counted in spoof)
local autoplace_room_counts
-- Autoplaced entities whose autoplace stays put, found from data in spoof: resources and cliffs, which are placed their own ways, and planted entities, whose autoplace tile_restriction is what agricultural tower plots use (space-age/prototypes/entity/plants.lua)
local fixed_autoplace

-- Autoplaced entities whose slot can go to another entity, and that can take another's
-- An entity has one autoplace, so only ones found in the wild in exactly one room can move (their spec goes where they go)
-- Only ones placed for the neutral force (the default, AutoplaceSpecification.force): the player's are ours (see entity-own in lib/logic/concrete.lua), and enemies (like spawners and worms) wait for spawn slots
-- Ones mining which unlocks a technology might not show up anymore once moved
local function claimable_autoplace(prototype)
    if prototype == nil or prototype.hidden or prototype.autoplace == nil then
        return false
    end
    if fixed_autoplace[prototype.name] ~= nil or excluded_entity_types[prototype.type] ~= nil or (prototype.autoplace.force or "neutral") ~= "neutral" then
        return false
    end
    if lookups.entities_with_mine_tech_unlocks[prototype.name] ~= nil then
        return false
    end
    return autoplace_room_counts[prototype.name] == 1
end

entity.initialize = function()
    autoplace_room_counts = {}
    fixed_autoplace = {}
end

entity.spoof = function(graph)
    for _, item in pairs(dutils.get_all_prots("item")) do
        local placed_name = common.placed_entity_name(item)
        if placed_name ~= nil and claimable_item(item) and claimable_entity(dutils.get_prot("entity", placed_name)) then
            -- Mining a claimed entity gives back whichever item now places it (see reflect), but logic has an edge from mining it to its vanilla item
            -- Left in, promotion could use that edge as a conversion the game doesn't have (place the entity with its new item, mine it, get the vanilla item)
            -- Mining a building normally just gives back the item that placed it, so dropping these edges only makes the model more pessimistic (e.g. a captured spawner can still be mined for an item in the game)
            local mine_edge_key = gutils.ekey({
                start = key("entity-mine", placed_name),
                stop = key("item", item.name),
            })
            if graph.edges[mine_edge_key] ~= nil then
                gutils.remove_edge(graph, mine_edge_key)
            end

            local build_edge_key = gutils.ekey({
                start = key("item", item.name),
                stop = key("entity-build-item", placed_name),
            })
            local build_edge = graph.edges[build_edge_key]
            if build_edge ~= nil then
                -- Which entity an item places is part of what the item is, so with first pass this base moves with the item's identity (trav), not its position (slot)
                build_edge.identity_base = true
                -- This handler matches build slots itself, so first pass shouldn't split them too (make_orands names each orand after the edge it splits)
                randomization_info.options.first_pass.blacklist[key("orand", build_edge_key)] = true
            end
        end
    end

    -- Every item that places nothing in vanilla gets an edge to a spoofed entity-build-item node, so its placing becomes a base that can go to an entity
    -- The sink is a spoof, so its own build slots are never randomized
    local sink = gutils.add_node(graph, "entity-build-item", SPOOF_SINK_NAME, {
        op = "OR",
        spoof = true,
    })
    for _, item in pairs(dutils.get_all_prots("item")) do
        if spoofable_item(item) and graph.nodes[key("item", item.name)] ~= nil then
            gutils.add_edge(graph, key("item", item.name), key(sink), acquisition.tag("build", {
                identity_base = true,
                build_spoof = true,
                amount = 1,
            }))
        end
    end

    -- Resources are what logic mines with a resource category, cliffs are named in planets' cliff_settings, and planted entities are some item's plant_result
    for _, edge in pairs(graph.edges) do
        if graph.nodes[edge.start].type == "resource-category" and graph.nodes[edge.stop].type == "entity-mine" then
            fixed_autoplace[graph.nodes[edge.stop].name] = true
        end
    end
    for _, planet in pairs(data.raw.planet or {}) do
        if planet.map_gen_settings ~= nil and planet.map_gen_settings.cliff_settings ~= nil and planet.map_gen_settings.cliff_settings.name ~= nil then
            fixed_autoplace[planet.map_gen_settings.cliff_settings.name] = true
        end
    end
    for _, item in pairs(dutils.get_all_prots("item")) do
        if item.plant_result ~= nil then
            fixed_autoplace[item.plant_result] = true
        end
    end

    -- Count each entity's autoplace rooms, and keep first pass from splitting the autoplace slots this handler matches
    local autoplace_edge_keys = {}
    for edge_key, edge in pairs(graph.edges) do
        if edge.acq_kind == "autoplace" and graph.nodes[edge.stop].type == "entity" then
            local entity_name = graph.nodes[edge.stop].name
            autoplace_room_counts[entity_name] = (autoplace_room_counts[entity_name] or 0) + 1
            table.insert(autoplace_edge_keys, edge_key)
        end
    end
    for _, edge_key in pairs(autoplace_edge_keys) do
        if claimable_autoplace(dutils.get_prot("entity", graph.nodes[graph.edges[edge_key].stop].name)) then
            randomization_info.options.first_pass.blacklist[key("orand", edge_key)] = true
        end
    end

    -- With biters on, spawn slots are claimed too, so first pass shouldn't split them either
    -- Every unit a spawner spawns also gets a placing slot that no item fills in vanilla, which an item can take (a friendly biter)
    -- Its edge comes from a source so it gets claimed, but promotion starts its head detached (starts_detached), so logic never counts on friendly biters
    if config.entity_biters then
        for edge_key, edge in pairs(graph.edges) do
            if edge.acq_kind == "spawn" and graph.nodes[edge.stop].type == "entity" then
                randomization_info.options.first_pass.blacklist[key("orand", edge_key)] = true
            end
        end
        local source_keys = {}
        for _, source in pairs(gutils.sources(graph)) do
            table.insert(source_keys, key(source))
        end
        table.sort(source_keys)
        for node_key, node in pairs(graph.nodes) do
            if node.type == "entity-build-item" and lookups.unit_spawns_reverse[node.name] ~= nil and next(node.pre) == nil then
                local edge = gutils.add_edge(graph, source_keys[1], node_key, acquisition.tag("build", {
                    friendly = true,
                    starts_detached = true,
                    amount = 1,
                }))
                randomization_info.options.first_pass.blacklist[key("orand", gutils.ekey(edge))] = true
            end
        end
    end
end

-- Claims each item --> entity-build-item edge (acq_kind build) between a claimable item and entity, and the spoofed edges from items that place nothing and into units' placing slots
-- Also claims each room-autoplace --> entity edge (acq_kind autoplace) of a claimable autoplaced entity, and with biters on each entity-spawn --> entity edge (acq_kind spawn)
entity.claim = function(graph, prereq, dep, edge)
    if edge == nil or dep == nil then
        return false
    end
    if edge.acq_kind == "build" then
        if edge.friendly ~= nil then
            return 1
        end
        if dep.type ~= "entity-build-item" or prereq.type ~= "item" then
            return false
        end
        if edge.build_spoof ~= nil then
            return 1
        end
        if not claimable_item(dutils.get_prot("item", prereq.name)) or not claimable_entity(dutils.get_prot("entity", dep.name)) then
            return false
        end
        return 1
    end
    if edge.acq_kind == "autoplace" then
        if dep.type ~= "entity" or prereq.type ~= "room-autoplace" or not claimable_autoplace(dutils.get_prot("entity", dep.name)) then
            return false
        end
        return 1
    end
    if edge.acq_kind == "spawn" then
        if not config.entity_biters or dep.type ~= "entity" or prereq.type ~= "entity-spawn" then
            return false
        end
        return 1
    end
    return false
end

-- Build bases are items, autoplace bases rooms and spawn bases spawners; claim already makes sure of that, but this is the hard check the search uses
-- The pairing of the base's and head's acquisition kinds must also be one logic can model (acquisition.pairing)
entity.validate = function(graph, base, head, extra)
    -- A unit's placing slot's own base is only there so its edge could be claimed
    if base.friendly ~= nil or acquisition.pairing(base, head) == nil then
        return false
    end
    local owner_type = gutils.get_owner(graph, base).type
    if base.acq_kind == "build" then
        return owner_type == "item"
    end
    if base.acq_kind == "spawn" then
        return owner_type == "entity-spawn"
    end
    return owner_type == "room-autoplace"
end

-- What getting an entity through another kind of slot gains or loses, like salvaging an autoplaced entity not being automatable (acquisition.pairing)
entity.connection_abilities = function(base, head)
    local pairing = acquisition.pairing(base, head)
    if pairing == nil then
        error("Randomization assertion failed! Entity randomization connected " .. key(base) .. " to " .. key(head) .. ", which logic can't model")
    end
    return pairing.abilities
end

-- The entity whose slot this head is (heads feed an orand of the entity's entity-build-item node, or of its entity node for autoplace slots)
local function head_entity_name(graph, head)
    return graph.nodes[graph.orand_to_parent[key(gutils.get_owner(graph, head))]].name
end

-- The item whose placing this base is
local function base_item_name(graph, base)
    return gutils.get_owner(graph, base).name
end

-- Cost of the item in the base game (lib/cost/material-costs), or nil if unknown
local function item_cost(item_name)
    local cost = material_costs.costs[key("item", item_name)]
    if type(cost) == "number" and cost > 0 then
        return cost
    end
    return nil
end

-- Whether the base's item costs about as much as the item that placed the head's entity in vanilla
local function costs_close(graph, base, head)
    local cost = item_cost(base_item_name(graph, base))
    local vanilla_cost = item_cost(base_item_name(graph, graph.nodes[head.old_base]))
    if cost == nil or vanilla_cost == nil then
        return true
    end
    return cost <= COST_TOLERANCE * vanilla_cost and vanilla_cost <= COST_TOLERANCE * cost
end

-- This handler's heads feeding this dep: build heads (into an orand of an entity-build-item node), and autoplace and spawn heads (into an orand of an entity node)
local function acquisition_heads_of(graph, dep_key)
    local heads = {}
    for pre, _ in pairs(graph.nodes[dep_key].pre) do
        local prenode = gutils.prenode(graph, pre)
        if prenode.type == "head" and (prenode.acq_kind == "build" or prenode.acq_kind == "autoplace" or prenode.acq_kind == "spawn") then
            table.insert(heads, prenode)
        end
    end
    return heads
end

-- The item as it was when unified randomization started, whatever its item class
local function starting_item(item_name)
    for item_class, _ in pairs(defines.prototypes.item) do
        local items = unified_starting_data_raw[item_class]
        if items ~= nil and items[item_name] ~= nil then
            return items[item_name]
        end
    end
    return nil
end

-- The entity as it was when unified randomization started
local function starting_entity(entity_name)
    for entity_class, _ in pairs(defines.prototypes.entity) do
        local entities = unified_starting_data_raw[entity_class]
        if entities ~= nil and entities[entity_name] ~= nil then
            return entities[entity_name]
        end
    end
    return nil
end

-- Cost of what mining an entity gave (lib/cost/material-costs), or nil if nothing it gives has a known cost
local function mining_yield_cost(prototype)
    if prototype == nil or prototype.minable == nil then
        return nil
    end
    local results = prototype.minable.results
    if results == nil and prototype.minable.result ~= nil then
        results = {
            {
                type = "item",
                name = prototype.minable.result,
                amount = prototype.minable.count or 1,
            },
        }
    end
    local total
    for _, product in pairs(results or {}) do
        local cost = item_cost(product.name)
        if product.type == "item" and cost ~= nil then
            local amount = product.amount or ((product.amount_min or 1) + (product.amount_max or product.amount_min or 1)) / 2
            total = (total or 0) + cost * amount * (product.probability or 1)
        end
    end
    return total
end

-- What a matched head takes instead of a base when its entity stops being acquired that way (a detached head, see promotion's try_rewires)
-- Units' placing slots start this way, since no item places them in vanilla
local DETACHED = "detached"

-- Matches bases to heads one to one, which the generic search can't guarantee (its fallback can reuse a base).
-- Taking bases greedily strands heads, since many (like assembling machines, needed isolated and automated on every planet) can only use their own base, and it's hard to tell ahead of time which.
-- Instead this starts from every head keeping its own base (always valid, since promotion guarantees vanilla bases), takes a random matching of heads to admissible bases, and applies it a group at a time.
-- A group is a cycle of heads taking each other's bases, or a chain of them ending at a head that takes a spoof placer, salvages from the wild, is carried by a biter, or is detached.
-- Each group is committed as a whole only if promotion can still establish everything promised (try_rewires), so the matching stays valid and one to one throughout and this can't fail.
entity.custom_prereq_search = function(params)
    local graph = params.random_graph
    local prom = params.promotion
    if prom == nil then
        error("Entity randomization needs promotion (USE_PROMOTION in randomizations/graph/unified/execute-new.lua)")
    end
    -- With first pass, promotion reasons over its split graph; this handler's slots aren't split (see spoof), and their heads and bases keep the same keys there

    -- Every head, with its dep
    -- A unit's placing slot (friendly) has no base of its own, so it starts and stays detached unless it takes an item
    local slots = {}
    local num_build_heads = {}
    for _, dep_key in pairs(params.sorted_deps) do
        for _, head in pairs(acquisition_heads_of(graph, dep_key)) do
            -- First pass must leave this handler's slots alone (see spoof), or it would move them without this handler (and its reflection) knowing
            if randomization_info.options.first_pass.blacklist[dep_key] == nil then
                error("Randomization assertion failed! Entity randomization slot " .. dep_key .. " isn't on first pass's blacklist")
            end
            local friendly = head.friendly ~= nil
            local own_base_key = head.old_base
            if friendly then
                own_base_key = DETACHED
            end
            local slot = {
                head = head,
                head_key = key(head),
                dep_key = dep_key,
                own_base_key = own_base_key,
                base_key = own_base_key,
                kind = head.acq_kind,
                friendly = friendly,
                entity_name = head_entity_name(graph, head),
            }
            table.insert(slots, slot)
            if slot.kind == "build" and not friendly then
                num_build_heads[slot.entity_name] = (num_build_heads[slot.entity_name] or 0) + 1
            end
        end
    end

    -- Anchor every build head at its own base, which promises each entity stays buildable where it's needed (or in its earliest context)
    -- Autoplace and spawn heads aren't anchored, so an entity found in the wild or spawned can move elsewhere unless something promised needs it where it was
    for _, slot in pairs(slots) do
        if slot.kind == "build" and not slot.friendly then
            prom.resolve_head(slot.head_key, slot.own_base_key, prom.required_contexts(slot.dep_key))
        end
    end

    -- Contexts a slot's head must be established in, whatever base it gets
    -- Nothing is promised through a unit's placing slot, since it starts detached
    local function slot_contexts(slot)
        if slot.friendly then
            return {}
        end
        if slot.kind == "build" then
            return prom.required_contexts(slot.dep_key)
        end
        return prom.promised_contexts(slot.head_key)
    end

    local rng_key = rng.key({id = "unified-entity"})
    rng.shuffle(rng_key, slots)

    -- Items that place nothing in vanilla (spoof bases, see spoof) can also be taken
    local spoof_base_keys = {}
    for _, base_key in pairs(params.shuffled_prereqs) do
        if graph.nodes[base_key].build_spoof ~= nil then
            table.insert(spoof_base_keys, base_key)
        end
    end
    local slot_of_own_base = {}
    for ind, slot in pairs(slots) do
        if not slot.friendly then
            slot_of_own_base[slot.own_base_key] = ind
        end
    end

    -- A built entity's own item, its cost, and how many of it a base needs (acquisition.demand_tier)
    local function own_item_of(slot)
        return starting_item(base_item_name(graph, graph.nodes[slot.own_base_key]))
    end
    local function tier_of(slot)
        return acquisition.demand_tier(dutils.get_prot("entity", slot.entity_name).type, own_item_of(slot).stack_size)
    end

    -- Whether a built entity can instead be acquired some other way that gives the entity itself, found in the wild (salvage) or carried by a biter (loot), for an item that places it
    -- It needs one item placing it, and a demand tier that kind of slot can supply (acquisition.can_supply)
    local function movable_building(slot, slot_kind)
        return not slot.friendly and num_build_heads[slot.entity_name] == 1 and acquisition.can_supply(tier_of(slot), slot_kind)
    end
    -- Salvaging also needs it to be minable, and to have no autoplace of its own (an entity has one autoplace, and one this handler didn't claim has to stay)
    local function salvageable(slot)
        return movable_building(slot, "autoplace") and dutils.get_prot("entity", slot.entity_name).minable ~= nil and starting_entity(slot.entity_name).autoplace == nil
    end

    -- Whether a slot could take a base: a valid pairing, an item of similar cost or an entity that fits where the autoplace slot's entity was, that promotion can establish before the head wherever the head is promised
    local function admissible(slot, base_key, contexts)
        local base = graph.nodes[base_key]
        if not entity.validate(graph, base, slot.head) then
            return false
        end
        if base.acq_kind == "build" and not slot.friendly and not costs_close(graph, base, slot.head) then
            return false
        end
        if base.acq_kind == "autoplace" and not common.fits_autoplace_of(dutils.get_prot("entity", slot.entity_name), dutils.get_prot("entity", base.entity), AUTOPLACE_AREA_TOLERANCE) then
            return false
        end
        -- A carrier is its slot's unit with the entity's look as its run_animation, so the unit needs one, and has to be worth killing for the entity's item (acquisition.worth_carrying)
        if base.acq_kind == "spawn" and slot.kind == "build" then
            local unit = starting_entity(base.entity)
            if unit.run_animation == nil or not acquisition.worth_carrying(unit.max_health or 1, item_cost(own_item_of(slot).name)) then
                return false
            end
        end
        -- Salvage is never worth more than SALVAGE_COST_FACTOR times what mining the slot's entity gave, and needs both costs known to check that (acquisition.worth_salvaging)
        if base.acq_kind == "autoplace" and slot.kind == "build" and not acquisition.worth_salvaging(item_cost(own_item_of(slot).name), mining_yield_cost(starting_entity(base.entity))) then
            return false
        end
        return #contexts == 0 or prom.head_candidate_ok(slot.head_key, base_key, contexts)
    end

    -- The bases each slot could take besides its own
    -- Autoplace and spawn slots trade among their own kind; build slots take other items, and some take items that placed nothing, autoplace slots (salvage) or spawn slots (carried by a biter)
    -- A unit's placing slot, if it takes anything, takes an item (a friendly biter)
    -- This is worked out once, from the anchored state, to keep the matching cheap; try_rewires checks each change exactly before it's committed
    local can_take = {}
    local can_detach = {}
    local num_pairs = 0
    for ind, slot in pairs(slots) do
        can_take[ind] = {}
        local contexts = slot_contexts(slot)
        local candidates = {}
        if slot.friendly then
            if rng.value(rng_key) < FRIENDLY_CHANCE then
                for _, other in pairs(slots) do
                    if other.kind == "build" and not other.friendly then
                        table.insert(candidates, other.own_base_key)
                    end
                end
                for _, base_key in pairs(spoof_base_keys) do
                    table.insert(candidates, base_key)
                end
            end
        else
            for _, other in pairs(slots) do
                if other ~= slot and other.kind == slot.kind and not other.friendly then
                    table.insert(candidates, other.own_base_key)
                end
            end
        end
        if slot.kind == "build" and not slot.friendly then
            -- Only some slots can take spoof bases, since each one taken leaves an item placing nothing
            if rng.value(rng_key) < SPOOF_CHANCE then
                for _, base_key in pairs(spoof_base_keys) do
                    table.insert(candidates, base_key)
                end
            end
            -- Only some entities are salvaged, since each one takes the place of something found in the wild
            if salvageable(slot) and rng.value(rng_key) < SALVAGE_CHANCE then
                for _, other in pairs(slots) do
                    if other.kind == "autoplace" then
                        table.insert(candidates, other.own_base_key)
                    end
                end
            end
            -- Only some entities are carried by biters, since each one takes the place of a unit a spawner spawned
            if movable_building(slot, "spawn") and rng.value(rng_key) < CARRIER_CHANCE then
                for _, other in pairs(slots) do
                    if other.kind == "spawn" then
                        table.insert(candidates, other.own_base_key)
                    end
                end
            end
        end
        for _, base_key in pairs(candidates) do
            if admissible(slot, base_key, contexts) then
                table.insert(can_take[ind], base_key)
                num_pairs = num_pairs + 1
            end
        end
        -- An entity found in the wild or spawned that nothing promised needs there can stop being acquired there, when another entity takes its slot
        can_detach[ind] = slot.friendly or (slot.kind ~= "build" and #contexts == 0)
    end

    -- Random matching of slots to bases (Kuhn's algorithm with shuffled candidates and each slot's own base tried last, like monotone matching)
    -- Every slot can keep its own base (or stay detached, for units' placing slots), so every slot always gets one, and a slot is only detached when its own base went to another slot
    local taker_of = {}
    local takes = {}
    local function try(ind, visited)
        local candidates = table.deepcopy(can_take[ind])
        rng.shuffle(rng_key, candidates)
        if not slots[ind].friendly then
            table.insert(candidates, slots[ind].own_base_key)
        end
        if can_detach[ind] then
            table.insert(candidates, DETACHED)
        end
        for _, base_key in pairs(candidates) do
            if base_key == DETACHED then
                takes[ind] = DETACHED
                return true
            end
            if visited[base_key] == nil then
                visited[base_key] = true
                if taker_of[base_key] == nil or try(taker_of[base_key], visited) then
                    taker_of[base_key] = ind
                    takes[ind] = base_key
                    return true
                end
            end
        end
        return false
    end
    local order = {}
    for ind, _ in pairs(slots) do
        table.insert(order, ind)
    end
    rng.shuffle(rng_key, order)
    for _, ind in pairs(order) do
        if not try(ind, {}) then
            error("Randomization assertion failed! Entity slot matching failed although every slot can keep its own base")
        end
    end

    -- A slot taking another slot's own base only works if that slot takes something else, so the matching splits into cycles, and chains that end at a slot taking a spoof base, an autoplace or spawn base, or nothing (detached)
    -- A chain starts at a slot whose own base nobody took: an item that places nothing now (a Vestige), a slot nothing is autoplaced or spawned in anymore, or a unit's placing slot (friendly)
    local function next_slot(ind)
        if takes[ind] == DETACHED then
            return nil
        end
        local other = slot_of_own_base[takes[ind]]
        if other == ind then
            return nil
        end
        return other
    end
    local components = {}
    local in_component = {}
    for ind, slot in pairs(slots) do
        if takes[ind] ~= slot.own_base_key and (slot.friendly or taker_of[slot.own_base_key] == nil) then
            local chain = {}
            local curr = ind
            while curr ~= nil do
                in_component[curr] = true
                table.insert(chain, curr)
                curr = next_slot(curr)
            end
            table.insert(components, chain)
        end
    end
    for ind, slot in pairs(slots) do
        if in_component[ind] == nil and takes[ind] ~= slot.own_base_key then
            local cycle = {}
            local curr = ind
            while in_component[curr] == nil do
                in_component[curr] = true
                table.insert(cycle, curr)
                curr = next_slot(curr)
            end
            table.insert(components, cycle)
        end
    end

    -- Commit each as a whole, only if promotion can still establish everything promised (the admissibility above was worked out once, so isn't exact)
    local counts = {
        moved = 0,
        spoofs = 0,
        salvaged = 0,
        carried = 0,
        friendly = 0,
        detached = 0,
    }
    for _, component in pairs(components) do
        local changes = {}
        for _, ind in pairs(component) do
            local remove = {}
            if slots[ind].base_key ~= DETACHED then
                table.insert(remove, slots[ind].base_key)
            end
            if takes[ind] == DETACHED then
                table.insert(changes, {
                    node_key = slots[ind].head_key,
                    remove = remove,
                    detach = true,
                })
            else
                table.insert(changes, {
                    node_key = slots[ind].head_key,
                    remove = remove,
                    add = takes[ind],
                })
            end
        end
        if prom.try_rewires(changes, true) then
            for _, ind in pairs(component) do
                local slot = slots[ind]
                slot.base_key = takes[ind]
                counts.moved = counts.moved + 1
                if takes[ind] == DETACHED then
                    counts.detached = counts.detached + 1
                elseif slot.friendly then
                    counts.friendly = counts.friendly + 1
                elseif graph.nodes[takes[ind]].build_spoof ~= nil then
                    counts.spoofs = counts.spoofs + 1
                elseif slot.kind == "build" and graph.nodes[takes[ind]].acq_kind == "autoplace" then
                    counts.salvaged = counts.salvaged + 1
                elseif slot.kind == "build" and graph.nodes[takes[ind]].acq_kind == "spawn" then
                    counts.carried = counts.carried + 1
                end
            end
        else
            log("Entity randomization: promotion rejected a group of " .. #component .. " slots; they keep their own bases")
        end
    end

    -- Detached heads get no base
    for _, slot in pairs(slots) do
        if slot.base_key ~= DETACHED then
            params.head_to_base[slot.head_key] = slot.base_key
        end
        if slot.base_key ~= slot.own_base_key then
            local base = graph.nodes[slot.base_key]
            if slot.base_key == DETACHED and slot.kind == "spawn" then
                log("Entity randomization: " .. slot.entity_name .. " isn't spawned by " .. graph.nodes[slot.own_base_key].spawner .. " anymore")
            elseif slot.base_key == DETACHED then
                log("Entity randomization: " .. slot.entity_name .. " isn't found in the wild there anymore")
            elseif slot.friendly then
                log("Entity randomization: " .. base_item_name(graph, base) .. " now places a friendly " .. slot.entity_name)
            elseif base.acq_kind == "autoplace" and slot.kind == "build" then
                log("Entity randomization: " .. slot.entity_name .. " is now salvaged from the wild where " .. base.entity .. " was")
            elseif base.acq_kind == "spawn" and slot.kind == "build" then
                log("Entity randomization: " .. slot.entity_name .. " is now carried by biters " .. base.spawner .. " spawns in place of " .. base.entity)
            elseif base.acq_kind == "autoplace" then
                log("Entity randomization: " .. slot.entity_name .. " is now found in the wild where " .. base.entity .. " was")
            elseif base.acq_kind == "spawn" then
                log("Entity randomization: " .. slot.entity_name .. " is now spawned by " .. base.spawner .. " in place of " .. base.entity)
            else
                log("Entity randomization: " .. base_item_name(graph, base) .. " now places " .. slot.entity_name)
            end
        end
    end
    log("Entity randomization: " .. counts.moved .. " of " .. #slots .. " slots changed; " .. counts.spoofs .. " to an item that placed nothing, " .. counts.salvaged .. " to salvage from the wild, " .. counts.carried .. " to biter carriers, " .. counts.friendly .. " friendly biters, " .. counts.detached .. " detached (" .. num_pairs .. " possible pairs)")

    return true
end

-- Item names that mining the entity can give
local function mined_item_names(prototype)
    local item_names = {}
    if prototype.minable == nil then
        return item_names
    end
    if prototype.minable.results ~= nil then
        for _, product in pairs(prototype.minable.results) do
            if product.type == "item" then
                table.insert(item_names, product.name)
            end
        end
    elseif prototype.minable.result ~= nil then
        table.insert(item_names, prototype.minable.result)
    end
    return item_names
end

-- A spoof placer's description: the entity it now places (rich text shows its icon), then the item's own description
-- randomizations.fixes later puts the entity's own description (with any stat changes) in front
local function places_description(old_item, entity_prot)
    local places = {"", "Places [entity=" .. entity_prot.name .. "] ", locale.find_localised_name(entity_prot)}
    if old_item.localised_description ~= nil then
        return {"", places, "\n", table.deepcopy(old_item.localised_description)}
    end
    -- Not every item has a description, so leave it out rather than show a missing key
    return {"", places, {"?", {"", "\n", {"item-description." .. old_item.name}}, ""}}
end

-- The planet an autoplace base's room is (see lookups.rooms)
-- Logic only finds entities autoplaced in planet rooms (lutils.check_in_room), so every autoplace slot is on one
local function base_planet_name(graph, base)
    local room = lookups.rooms[gutils.get_owner(graph, base).name]
    if room == nil or room.type ~= "planet" then
        error("Randomization assertion failed! Autoplace slot " .. key(base) .. " isn't on a planet")
    end
    return room.name
end

-- A planet's map generation entity settings (entity name --> settings), in data.raw or the starting copy of it, or nil if it has none
local function planet_entity_settings(raw, planet_name)
    local planet = raw.planet[planet_name]
    if planet == nil or planet.map_gen_settings == nil or planet.map_gen_settings.autoplace_settings == nil or planet.map_gen_settings.autoplace_settings.entity == nil then
        return nil
    end
    return planet.map_gen_settings.autoplace_settings.entity.settings
end

-- A salvaged entity's description: where to find it
local function salvage_description(entity_prot)
    return {"", "Mined from [entity=" .. entity_prot.name .. "] ", locale.find_localised_name(entity_prot), " found in the wild."}
end

entity.reflect = function(graph, head_to_base, head_to_handler)
    -- item --> entity it now places, entity --> items that now place it, entity --> items that placed it in vanilla (only claimed ones)
    local item_to_entity = {}
    local entity_to_items = {}
    local entity_to_old_items = {}
    -- item that placed it in vanilla --> build slot (head key), and the items that placed nothing in vanilla (spoof placers)
    local old_item_to_head = {}
    local is_spoof_placer = {}
    local num_heads = 0
    -- Salvaged entity --> autoplace base it's found in the wild through, and autoplaced entity --> autoplace base it's moved to (false if it isn't found in the wild anymore)
    local salvaged = {}
    local autoplace_moves = {}
    -- Entity carried by biters --> spawn base, items placing a unit (friendly biters), and spawner --> unit it spawned in vanilla --> what it spawns there now
    local carried = {}
    local is_friendly_placer = {}
    local spawn_occupants = {}
    -- Detached heads have no base, so this goes over every head of this handler
    for head_key, handler in pairs(head_to_handler) do
        local head = graph.nodes[head_key]
        -- Heads into spoofed nodes (like the one items placing nothing in vanilla feed) are never matched
        local parent = graph.nodes[graph.orand_to_parent[key(gutils.get_owner(graph, head))]]
        if handler.id == entity.id and parent.spoof == nil then
            local entity_name = parent.name
            local base_key = head_to_base[head_key]
            if head.friendly ~= nil then
                -- A unit's placing slot, which an item may have taken (a friendly biter)
                if base_key ~= nil then
                    local item_name = base_item_name(graph, graph.nodes[base_key])
                    if item_to_entity[item_name] ~= nil then
                        error("Randomization assertion failed! Item " .. item_name .. " was matched to two build slots")
                    end
                    item_to_entity[item_name] = entity_name
                    entity_to_items[entity_name] = {
                        item_name,
                    }
                    is_friendly_placer[item_name] = true
                    if graph.nodes[base_key].build_spoof ~= nil then
                        is_spoof_placer[item_name] = true
                    end
                end
            elseif head.acq_kind == "spawn" then
                if base_key ~= nil then
                    local base = graph.nodes[base_key]
                    spawn_occupants[base.spawner] = spawn_occupants[base.spawner] or {}
                    spawn_occupants[base.spawner][base.entity] = entity_name
                end
            elseif head.acq_kind == "build" then
                local old_item_name = base_item_name(graph, graph.nodes[head.old_base])
                entity_to_old_items[entity_name] = entity_to_old_items[entity_name] or {}
                table.insert(entity_to_old_items[entity_name], old_item_name)
                old_item_to_head[old_item_name] = head_key
                num_heads = num_heads + 1
                if graph.nodes[base_key].acq_kind == "autoplace" then
                    salvaged[entity_name] = base_key
                elseif graph.nodes[base_key].acq_kind == "spawn" then
                    carried[entity_name] = base_key
                else
                    local item_name = base_item_name(graph, graph.nodes[base_key])
                    if item_to_entity[item_name] ~= nil then
                        error("Randomization assertion failed! Item " .. item_name .. " was matched to two build slots")
                    end
                    item_to_entity[item_name] = entity_name
                    entity_to_items[entity_name] = entity_to_items[entity_name] or {}
                    table.insert(entity_to_items[entity_name], item_name)
                    if graph.nodes[base_key].build_spoof ~= nil then
                        is_spoof_placer[item_name] = true
                    end
                end
            elseif base_key ~= head.old_base then
                autoplace_moves[entity_name] = base_key or false
            end
        end
    end
    for _, item_names in pairs(entity_to_items) do
        table.sort(item_names)
    end
    for _, item_names in pairs(entity_to_old_items) do
        table.sort(item_names)
    end

    -- The item that now places a build slot's entity (or the room it's salvaged in)
    local function placer_of(head_key)
        return base_item_name(graph, graph.nodes[head_to_base[head_key]])
    end

    -- Whether a build slot ends a chain of slots taking each other's vanilla items: it took a spoof placer, or is salvaged or carried by biters
    local function ends_chain(head_key)
        local base = graph.nodes[head_to_base[head_key]]
        return base.build_spoof ~= nil or base.acq_kind == "autoplace" or base.acq_kind == "spawn"
    end

    -- Weight always stays the item's own, since logic decides what can be launched from it (lu.weight)
    for item_name, entity_name in pairs(item_to_entity) do
        local old_item = starting_item(item_name)
        local item = dutils.get_prot("item", item_name)
        local entity_prot = dutils.get_prot("entity", entity_name)
        -- Units have no item of their own, so their look is their own icon
        local look = entity_prot
        if entity_to_old_items[entity_name] ~= nil then
            look = starting_item(entity_to_old_items[entity_name][1])
        end
        if is_spoof_placer[item_name] then
            -- Spoof placers still do everything they did, so they keep their own look, with the entity's item as a badge on their icon
            common.set_placed_entity(item, entity_prot)
            -- An item that places an entity is named after it unless it has a name of its own (see ItemPrototype), so the item's own name is pinned down
            item.localised_name = table.deepcopy(locale.find_localised_name(old_item))
            item.localised_description = places_description(old_item, entity_prot)
            for _, prefix in pairs(common.item_icon_prefixes) do
                local layers = common.icon_layers(old_item, prefix)
                if layers ~= nil then
                    common.set_icon_layers(item, prefix, common.with_icon_badge(layers, common.icon_layers(look, "")))
                end
            end
        elseif is_friendly_placer[item_name] then
            -- An item that placed an entity now places a unit, for the player's force, so it looks like the unit
            common.set_placed_entity(item, entity_prot)
            common.set_icon_layers(item, "", common.icon_layers(entity_prot, ""))
            common.set_icon_layers(item, "dark_background_", nil)
            item.localised_name = {"", locale.find_localised_name(entity_prot), " (Friendly)"}
            item.localised_description = {"", "Places a friendly [entity=" .. entity_name .. "] ", locale.find_localised_name(entity_prot), "."}
        elseif common.placed_entity_name(old_item) ~= entity_name then
            -- Other items take on the look of their new entity's own item (icons, name, stack size, place in menus); items that still place their own entity are left alone
            common.set_placed_entity(item, entity_prot)
            for _, prefix in pairs(common.item_icon_prefixes) do
                common.set_icon_layers(item, prefix, common.icon_layers(look, prefix))
            end
            -- Like that item, it's named after the entity unless the item has a name of its own (as seeds do)
            item.localised_name = table.deepcopy(look.localised_name) or locale.find_localised_name(entity_prot)
            -- Only the description the entity's own item had, since randomizations.fixes puts the entity's description (with any stat changes) in front of every placing item's description
            -- Most items that place something have no description of their own, and a missing key would show as one
            item.localised_description = table.deepcopy(look.localised_description) or {"?", {"item-description." .. look.name}, ""}
            item.subgroup = look.subgroup
            item.order = look.order
            item.stack_size = look.stack_size
        end
    end

    -- Vanilla items that no build slot took place nothing now (Vestiges)
    -- Each starts a chain of build slots, each taking the next one's vanilla item, that ends at one taking a spoof placer or salvaging from the wild (see custom_prereq_search)
    -- No item took the look of that last entity's vanilla item, so the Vestige takes it: if a productivity module places the assembling machine, some item becomes "Assembling machine 1 (Vestige)"
    for old_item_name, head_key in pairs(old_item_to_head) do
        if item_to_entity[old_item_name] == nil then
            local last_head_key = head_key
            local num_steps = 0
            while not ends_chain(last_head_key) do
                last_head_key = old_item_to_head[placer_of(last_head_key)]
                num_steps = num_steps + 1
                if last_head_key == nil or num_steps > num_heads then
                    error("Randomization assertion failed! The build slots from Vestige " .. old_item_name .. " don't end at a spoof placer or salvage")
                end
            end
            local last_entity = dutils.get_prot("entity", head_entity_name(graph, graph.nodes[last_head_key]))
            local look = starting_item(base_item_name(graph, graph.nodes[graph.nodes[last_head_key].old_base]))
            local vestige = dutils.get_prot("item", old_item_name)
            local last_entity_name = locale.find_localised_name(last_entity)
            local now_from
            if carried[last_entity.name] ~= nil then
                log("Entity randomization: " .. old_item_name .. " places nothing now, and looks like a darkened " .. look.name .. " (" .. last_entity.name .. " is now carried by biters)")
                now_from = {"", " is now carried by biters; kill one for an item that places it."}
            elseif salvaged[last_entity.name] ~= nil then
                log("Entity randomization: " .. old_item_name .. " places nothing now, and looks like a darkened " .. look.name .. " (" .. last_entity.name .. " is now salvaged from the wild)")
                now_from = {"", " is now found in the wild; mine one for an item that places it."}
            else
                local spoof_placer = dutils.get_prot("item", placer_of(last_head_key))
                log("Entity randomization: " .. old_item_name .. " places nothing now, and looks like a darkened " .. look.name .. " (" .. last_entity.name .. " is now placed by " .. spoof_placer.name .. ")")
                now_from = {"", " is now placed with [item=" .. spoof_placer.name .. "] ", locale.find_localised_name(spoof_placer), "."}
            end
            for _, prefix in pairs(common.item_icon_prefixes) do
                local layers = common.icon_layers(look, prefix)
                if layers ~= nil then
                    layers = common.darken_icon_layers(layers)
                end
                common.set_icon_layers(vestige, prefix, layers)
            end
            vestige.localised_name = {"", table.deepcopy(look.localised_name) or last_entity_name, " (Vestige)"}
            vestige.localised_description = {"", "No longer places anything. [entity=" .. last_entity.name .. "] ", last_entity_name, now_from}
            vestige.subgroup = look.subgroup
            vestige.order = look.order
            vestige.stack_size = look.stack_size
            -- Item randomization (reflected after this) routes items it finds useless differently (dutils.is_useless_item), and it planned with this item still placing, so it only stops placing once every handler has reflected
            table.insert(changes, {
                tbl = vestige,
                prop = "place_result",
                new_val = nil,
            })
            table.insert(changes, {
                tbl = vestige,
                prop = "plant_result",
                new_val = nil,
            })
        end
    end

    -- Entities that move to another autoplace slot (autoplaced ones, and salvaged ones found in the wild now) take that slot's entity's autoplace, and are listed where it was in map generation
    -- Everything that moves is taken out of the wild first, so an entity that gives up its own slot and takes another ends up in just the new one
    local moved = {}
    for entity_name, base_key in pairs(autoplace_moves) do
        moved[entity_name] = base_key
    end
    for entity_name, base_key in pairs(salvaged) do
        moved[entity_name] = base_key
    end
    for entity_name, _ in pairs(moved) do
        dutils.get_prot("entity", entity_name).autoplace = nil
        for planet_name, _ in pairs(data.raw.planet) do
            local settings = planet_entity_settings(data.raw, planet_name)
            if settings ~= nil then
                settings[entity_name] = nil
            end
        end
    end
    for entity_name, base_key in pairs(moved) do
        if base_key == false then
            log("Entity randomization: " .. entity_name .. " isn't autoplaced anymore")
        else
            local base = graph.nodes[base_key]
            local planet_name = base_planet_name(graph, base)
            -- The whole spec moves (its control, order, tile restriction and all), so the entity shows up where the slot's entity did
            dutils.get_prot("entity", entity_name).autoplace = table.deepcopy(starting_entity(base.entity).autoplace)
            local starting_settings = planet_entity_settings(unified_starting_data_raw, planet_name)
            if starting_settings ~= nil and starting_settings[base.entity] ~= nil then
                planet_entity_settings(data.raw, planet_name)[entity_name] = table.deepcopy(starting_settings[base.entity])
            end
        end
    end

    -- A salvaged entity is found in the wild for the neutral force (its slot's autoplace force), which can't be used where it stands, so mining it gives a new item that places it
    -- The item looks like the entity's own item did, whose placing went elsewhere (to another entity, or nothing as a Vestige)
    for entity_name, base_key in pairs(salvaged) do
        local entity_prot = dutils.get_prot("entity", entity_name)
        local old_item_name = entity_to_old_items[entity_name][1]
        local salvage = table.deepcopy(starting_item(old_item_name))
        salvage.name = "propertyrandomizer-salvaged-" .. entity_name
        common.set_placed_entity(salvage, entity_prot)
        salvage.localised_name = salvage.localised_name or locale.find_localised_name(entity_prot)
        salvage.localised_description = salvage_description(entity_prot)
        data:extend({
            salvage,
        })
        -- Mining is how it's gotten, so it always gives the salvage item, but everything else mining gave stays, since logic still counts on it
        common.swap_mining_items(entity_prot, entity_to_old_items[entity_name], salvage.name, true)
        common.replace_placeable_by_item(entity_prot, old_item_name, salvage.name)
        log("Entity randomization: " .. entity_name .. " is found in the wild where " .. graph.nodes[base_key].entity .. " was, and mined for " .. salvage.name)
    end

    -- What this seed only gets by hand, and from where (logged as FARMREPORT lines at the end)
    local farm_report = {}
    for entity_name, base_key in pairs(salvaged) do
        local base = graph.nodes[base_key]
        local tier = acquisition.demand_tier(dutils.get_prot("entity", entity_name).type, starting_item(entity_to_old_items[entity_name][1]).stack_size)
        table.insert(farm_report, "salvage: " .. entity_name .. " (" .. tier .. "), found in the wild on " .. base_planet_name(graph, base) .. " in place of " .. base.entity)
    end
    for item_name, entity_name in pairs(item_to_entity) do
        if is_friendly_placer[item_name] then
            table.insert(farm_report, "friendly: " .. item_name .. " places a friendly " .. entity_name)
        end
    end

    -- An entity carried by biters: its spawn slot's unit is replaced by a carrier, a copy of that unit that looks like the entity and drops a new item placing it when killed (loot)
    -- The item looks like the entity's own item did, whose placing went elsewhere
    for entity_name, base_key in pairs(carried) do
        local base = graph.nodes[base_key]
        local entity_prot = dutils.get_prot("entity", entity_name)
        local old_item_name = entity_to_old_items[entity_name][1]
        local carrier = table.deepcopy(starting_entity(base.entity))
        carrier.name = "propertyrandomizer-carrier-" .. entity_name
        local looted = table.deepcopy(starting_item(old_item_name))
        looted.name = "propertyrandomizer-looted-" .. entity_name
        common.set_placed_entity(looted, entity_prot)
        looted.localised_name = looted.localised_name or locale.find_localised_name(entity_prot)
        looted.localised_description = {"", "Dropped by [entity=" .. carrier.name .. "] ", locale.find_localised_name(entity_prot), " carriers."}
        -- It keeps the unit's size, stats and behavior, and looks like the entity shrunk to the unit's size
        local sprite = common.entity_sprite(entity_prot, common.box_size(carrier))
        carrier.run_animation = {
            layers = {
                sprite,
            },
        }
        carrier.attack_parameters.animation = {
            layers = {
                table.deepcopy(sprite),
            },
        }
        carrier.alternative_attacking_frame_sequence = nil
        common.set_icon_layers(carrier, "", common.icon_layers(entity_prot, ""))
        carrier.localised_name = {"", locale.find_localised_name(entity_prot), " (Carrier)"}
        carrier.localised_description = {"", "Drops [item=" .. looted.name .. "] when killed."}
        -- Tougher carriers drop more, cheap and bulk items more (acquisition.loot_amount)
        local tier = acquisition.demand_tier(entity_prot.type, starting_item(old_item_name).stack_size)
        local amount = acquisition.loot_amount(carrier.max_health or 1, item_cost(old_item_name), tier, looted.stack_size)
        carrier.loot = {
            {
                type = "item",
                name = looted.name,
                amount = amount,
            },
        }
        table.insert(farm_report, "carrier: " .. entity_name .. " (" .. tier .. "), " .. amount .. " per kill of " .. carrier.name .. " from " .. base.spawner .. ", in place of " .. base.entity)
        data:extend({
            looted,
            carrier,
        })
        -- Picking a placed one back up gives the looted item where it gave the entity's own item, and everything else mining gave stays (like a plant's fruit), since logic still counts on it
        common.swap_mining_items(entity_prot, entity_to_old_items[entity_name], looted.name, false)
        common.replace_placeable_by_item(entity_prot, old_item_name, looted.name)
        spawn_occupants[base.spawner] = spawn_occupants[base.spawner] or {}
        spawn_occupants[base.spawner][base.entity] = carrier.name
        log("Entity randomization: " .. base.spawner .. " spawns " .. carrier.name .. " in place of " .. base.entity .. ", which drops " .. looted.name)
    end

    -- Spawners spawn whatever took their spawn slots, at those slots' spawn points
    -- A slot whose unit stopped spawning at some evolution (transient) spawns its new unit at every evolution, since logic counts on it (TRANSIENT_WEIGHT_FLOOR)
    -- A slot nothing took keeps its vanilla unit, and a unit taking two slots of one spawner gets one entry spawning at least as much as both
    for spawner_name, occupants in pairs(spawn_occupants) do
        local entries = {}
        local entry_of = {}
        for _, definition in pairs(starting_entity(spawner_name).result_units) do
            local unit_name, points = acquisition.read_spawn_definition(definition)
            local occupant = occupants[unit_name] or unit_name
            if occupant ~= unit_name and lookups.unit_spawns[spawner_name][unit_name].class == "transient" then
                points = acquisition.floor_spawn_points(points, TRANSIENT_WEIGHT_FLOOR)
            end
            if entry_of[occupant] ~= nil then
                entry_of[occupant].points = acquisition.merge_spawn_points(entry_of[occupant].points, points)
            else
                entry_of[occupant] = {
                    unit = occupant,
                    points = points,
                }
                table.insert(entries, entry_of[occupant])
            end
        end
        local result_units = {}
        for _, entry in pairs(entries) do
            table.insert(result_units, acquisition.spawn_definition(entry.unit, entry.points))
        end
        dutils.get_prot("entity", spawner_name).result_units = result_units
    end

    -- Bulk classes with members only gotten by hand, next to the members still placed by items (group-supply keeps at least one of those wherever vanilla had one)
    local class_members = {}
    local has_hand_member = {}
    for entity_name, _ in pairs(entity_to_old_items) do
        local class = dutils.get_prot("entity", entity_name).type
        if acquisition.bulk_entity_types[class] ~= nil then
            class_members[class] = class_members[class] or {}
            if salvaged[entity_name] ~= nil or carried[entity_name] ~= nil then
                has_hand_member[class] = true
                table.insert(class_members[class], entity_name .. " (by hand)")
            else
                table.insert(class_members[class], entity_name)
            end
        end
    end
    for class, members in pairs(class_members) do
        if has_hand_member[class] then
            table.sort(members)
            table.insert(farm_report, "bulk class " .. class .. ": " .. table.concat(members, ", "))
        end
    end
    table.sort(farm_report)
    for _, line in pairs(farm_report) do
        log("FARMREPORT " .. line)
    end

    -- Picking an entity back up gives an item that places it, and blueprints use that item too
    for entity_name, item_names in pairs(entity_to_items) do
        local entity_prot = dutils.get_prot("entity", entity_name)
        local canonical_item_name = item_names[1]
        local vanilla_mined = mined_item_names(unified_starting_data_raw[entity_prot.type][entity_name])
        for _, old_item_name in pairs(entity_to_old_items[entity_name] or {}) do
            -- Old items that still place this entity can stay
            if item_to_entity[old_item_name] ~= entity_name then
                common.replace_mining_item(entity_prot, old_item_name, canonical_item_name)
                common.replace_placeable_by_item(entity_prot, old_item_name, canonical_item_name)
            end
        end

        -- If mining gave back one of the entity's own items in vanilla, it should still give back an item that places it
        local gave_placer = false
        for _, mined_name in pairs(vanilla_mined) do
            for _, old_item_name in pairs(entity_to_old_items[entity_name] or {}) do
                if mined_name == old_item_name then
                    gave_placer = true
                end
            end
        end
        if gave_placer then
            local gives_placer = false
            for _, mined_name in pairs(mined_item_names(entity_prot)) do
                local mined_item = dutils.get_prot("item", mined_name)
                if mined_item ~= nil and common.placed_entity_name(mined_item) == entity_name then
                    gives_placer = true
                end
            end
            if not gives_placer then
                error("Randomization assertion failed! Mining " .. entity_name .. " no longer gives an item that places it")
            end
        end
    end

    -- Changing what items place can break upgrade targets (e.g. a target no longer built by any item), which is a load error, so drop only the broken ones
    for _, prot in pairs(dutils.get_all_prots("entity")) do
        local problem = common.next_upgrade_problem(prot)
        if problem ~= nil then
            log("Entity randomization: removing next_upgrade " .. prot.next_upgrade .. " from " .. prot.name .. " (" .. problem .. ")")
            prot.next_upgrade = nil
        end
    end
end

return entity

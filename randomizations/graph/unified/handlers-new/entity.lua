-- Entity randomization: changes how entities are acquired (the acquisition kinds in lib/logic/acquisition.lua)
-- So far build slots (which item places which entity), autoplace slots (which entity map generation puts where), spawn slots (what spawners spawn), and trigger slots (what using a capsule, firing ammo or capturing a spawner makes for us)
-- An item's ability to place something, or a room's autoplace spot, is a base, and an entity's need for one is a head
-- Autoplaced entities can trade autoplace slots or stop being autoplaced, and built entities can be found in the wild instead and salvaged (mined for an item that places them)
-- Entities made by trigger slots (like combat robots, the capture robot and the captive spawner) trade those slots or stop being made, and built entities can be made by one instead and then mined for an item that places them
-- Spoil slots (what eggs hatch into) and dying slots (what an enemy leaves behind when killed) trade among their own kind, and built entities can take one as a carrier hatching from the egg, or as a wreck left behind, mined for an item that places it
-- Capsules thrown for an effect (like grenades) can make an entity instead, and their effects move: to the item at the start of the chain that ends there (a Vestige, which sets the effect off where it's placed, or a capsule), and among each other
-- Each item places only one entity (planting counts, see common.set_placed_entity), so bases are matched to heads one to one, with promotion keeping mechanic contexts and recipe reachability
-- With constants.entity_first_pass on, first pass does the matching instead: every claimed acquisition edge is a first pass position like an item's (see first_pass_rules), and this handler only reflects the result
-- With first pass (and item randomization), a build base belongs to the item's identity, so an item keeps placing its (new) entity wherever item randomization moves it
-- Reflects before item randomization (see execute-new.lua), which copies items' names and icons into recipes
-- Spoofs let items that place nothing in vanilla (like modules) also place an entity, on top of everything they already do; that entity's own item then places nothing (a Vestige)

local categories = require("helper-tables/categories")
local constants = require("helper-tables/constants")
local acquisition = require("lib/logic/acquisition")
local dutils = require("lib/data-utils")
local gutils = require("lib/graph/graph-utils")
local locale = require("lib/locale")
local rng = require("lib/random/rng")
local material_costs = require("lib/cost/material-costs/sa")
local common = require("randomizations/graph/unified/handler-helpers/entity")

local key = gutils.key

local entity = {}

entity.id = "entity"

-- Each item places one entity, so each base can only be used once
entity.with_replacement = false

-- An item only takes over an entity if it costs within this factor of the entity's own item (first pass uses the same factor for its entity slots)
local COST_TOLERANCE = constants.entity_cost_tolerance
-- Chance that an entity may be placed by an item that places nothing in vanilla (a spoof base), whose own item then places nothing (a Vestige) unless another entity takes it
local SPOOF_CHANCE = 0.25
-- The spoofed entity-build-item node that items placing nothing in vanilla get an edge to, so their placing enters the pool of bases
local SPOOF_SINK_NAME = "propertyrandomizer-spoof-placer"
-- With first pass entity positions (constants.entity_first_pass): the chance that an item placing nothing in vanilla gets a build position at all (each is a first pass position)
local SPOOF_POSITION_CHANCE = 0.25
-- With first pass entity positions: how many positions nothing reaches (see spoof), so that many identities can stop being acquired (detached) in one first pass
local NUM_NOWHERE_POSITIONS = 16
-- The spoofed entity-own nodes the nowhere positions feed (numbered, one per position)
local SPOOF_NOWHERE_NAME = "propertyrandomizer-spoof-nowhere"
-- With first pass entity positions: the chance that an entity found in the wild, spawned, or made by a trigger, spoiling item or dying entity may stop being acquired (detached) where first pass needs its position
local DETACH_CHANCE = 0.25
-- Chance that an entity built from an item may instead be found in the wild in another entity's autoplace slot, and salvaged (mined for an item that places it)
local SALVAGE_CHANCE = 0.25
-- An entity only takes an autoplace slot if its collision box is at most this many times the size of the slot's own entity's (see common.fits_autoplace_of)
local AUTOPLACE_AREA_TOLERANCE = 2
-- Chance that an entity built from an item may instead be carried by a unit a spawner spawns, which drops an item that places it when killed (loot)
local CARRIER_CHANCE = 0.25
-- The spoofed entity-own node that each spawn and spoil slot's carrier base feeds (see spoof), so killing that slot's unit is a base a built entity can take
local SPOOF_CARRIER_NAME = "propertyrandomizer-spoof-carrier"
-- Chance that a unit a spawner spawns may also be placed by an item, as a friendly biter
local FRIENDLY_CHANCE = 0.25
-- A unit in a spawn slot whose unit stopped spawning at some evolution (transient, see acquisition.spawn_class) spawns at least this share of its highest weight at every evolution, since logic counts on it
local TRANSIENT_WEIGHT_FLOOR = 0.1
-- Chance that an entity built from an item may instead be made by a trigger slot (using a capsule, firing ammo or capturing a spawner), then mined for an item that places it
local TRIGGER_CHANCE = 0.25
-- A building a captured spawner turns into is at most this many times the spawner's size, since it takes the spawner's place (see common.fits_autoplace_of)
local CAPTURE_AREA_TOLERANCE = 1
-- Chance that an entity built from an item may instead be left behind by a dying enemy as a wreck, mined for an item that places it
local WRECK_CHANCE = 0.25
-- The spoofed entity-own node that capsules thrown for an effect (like grenades) get an edge to, so their use becomes a trigger base an entity can take
local SPOOF_MAKER_NAME = "propertyrandomizer-spoof-maker"
-- Chance that a capsule thrown for an effect trades its effect with others (see effect_capsule)
local EFFECT_SWAP_CHANCE = 0.25

-- Item types that can place an entity without it getting in the way of what they already do, since their other uses go through the GUI
-- Capsules and repair packs and the like are used by clicking, which placing would take over (players can bind using capsules to left click, which also places buildings), so they never place anything
-- A capsule's slot can still make a building, by throwing it (trigger slots)
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
-- Entities that spawn in space (asteroids) and whatever they break into when they die (found in spoof), whose dying slots stay put
local from_space
-- Build position (the entity an entity-build-item node was for) --> the entity first pass put there, whose identity is what gets built (set in custom_prereq_search)
-- Stays empty while first pass has no entity positions (none are declared now, see spoof), so every build slot builds its own entity
local identity_of_position

-- The entity built at a build position: what first pass put there, or the position's own entity
local function identity_at(position)
    return identity_of_position[position] or position
end
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

-- Trigger slots: using an item (a capsule, or firing ammo) or capturing a spawner, which makes the entity ours (its edge is tagged ours, see lib/logic/acquisition.lua)
local function is_trigger_kind(kind)
    return kind == "capsule" or kind == "ammo" or kind == "capture"
end

-- Slots where a trigger makes the entity: trigger slots, an item spoiling (like an egg hatching), or an entity dying
local function is_made_kind(kind)
    return is_trigger_kind(kind) or kind == "spoil" or kind == "dying"
end

-- The prototype and property holding the trigger that makes a slot's entity, from the name of what owns its base (see is_made_kind)
-- These are what lib/lookup/2-simple/entity-create.lua reads: a capsule's action, what ammo does when fired, what an item does when it spoils, or what an entity does when it dies
local function trigger_holder(kind, owner_name)
    if kind == "dying" then
        return dutils.get_prot("entity", owner_name), "dying_trigger_effect"
    end
    local property = "ammo_type"
    if kind == "capsule" then
        property = "capsule_action"
    elseif kind == "spoil" then
        property = "spoil_to_trigger_result"
    end
    return dutils.get_prot("item", owner_name), property
end

-- Whether this handler can give what an edge from start to stop where a trigger makes an entity (see is_made_kind) makes to another entity
-- The entity has to have health, since ones without (like smoke and particles) are only there for looks
-- Trigger slots make it ours, and spoil and dying slots don't; spoil slots hatch enemies, so they go with spawn slots (the biters setting)
-- What dies into spawners, and what space rocks break into, stays put (spawners are what spawn slots belong to, and asteroids stay in space)
-- A captured spawner has to turn into it, and anything else has to make it through create-entity effects that common.retarget_created_entities finds
local function claimable_made_edge(start, stop, edge)
    local kind = edge.acq_kind
    if is_trigger_kind(kind) then
        if edge.ours == nil or stop.type ~= "entity-own" then
            return false
        end
    elseif kind == "spoil" or kind == "dying" then
        if edge.ours ~= nil or stop.type ~= "entity" or (kind == "spoil" and not config.entity_biters) then
            return false
        end
    else
        return false
    end
    local made = dutils.get_prot("entity", stop.name)
    if made == nil or categories.without_health[made.type] ~= nil or excluded_entity_types[made.type] ~= nil then
        return false
    end
    if kind == "capture" then
        local spawner = dutils.get_prot("entity", start.name)
        return spawner ~= nil and spawner.captured_spawner_entity == made.name
    end
    if kind == "dying" then
        if lookups.unit_spawns[made.name] ~= nil or from_space[start.name] ~= nil then
            return false
        end
    else
        local item = dutils.get_prot("item", start.name)
        if item == nil or item.hidden or item.parameter then
            return false
        end
    end
    local holder, property = trigger_holder(kind, start.name)
    if holder == nil or holder[property] == nil then
        return false
    end
    local num_made = common.retarget_created_entities(table.deepcopy(holder[property]), {
        [made.name] = function(_) end,
    }, function(name)
        return name
    end)
    return num_made > 0
end

-- Whether a capsule is thrown for an effect: its use is aimed at a spot (its attack has a range), where it does something other than make an entity with health, like a grenade exploding or a poison cloud
-- Capsules used on yourself (like fish) have no range, and ones making entities with health (like combat robots) are trigger slots
local function effect_capsule(item)
    if item == nil or item.hidden or item.parameter or item.capsule_action == nil then
        return false
    end
    local attack = item.capsule_action.attack_parameters
    if attack == nil or attack.ammo_type == nil or attack.ammo_type.action == nil or (attack.range or 0) <= 0 then
        return false
    end
    for entity_name, _ in pairs(lookups.capsule_spawns[item.name] or {}) do
        local made = dutils.get_prot("entity", entity_name)
        if made ~= nil and categories.without_health[made.type] == nil then
            return false
        end
    end
    return true
end

entity.initialize = function()
    autoplace_room_counts = {}
    fixed_autoplace = {}
    from_space = {}
    identity_of_position = {}
end

entity.spoof = function(graph)
    -- This handler matches its acquisition slots itself, so first pass mustn't split them (make_orands names each orand after the edge it splits), unless first pass matches them as its own positions (constants.entity_first_pass)
    local function keep_from_first_pass(edge_key)
        if not constants.entity_first_pass then
            randomization_info.options.first_pass.blacklist[key("orand", edge_key)] = true
        end
    end

    -- Claimed entity --> how many claimable items place it in vanilla
    local num_claimed_placers = {}
    for _, item in pairs(dutils.get_all_prots("item")) do
        local placed_name = common.placed_entity_name(item)
        if placed_name ~= nil and claimable_item(item) and claimable_entity(dutils.get_prot("entity", placed_name)) then
            num_claimed_placers[placed_name] = (num_claimed_placers[placed_name] or 0) + 1
        end
    end

    for _, item in pairs(dutils.get_all_prots("item")) do
        local placed_name = common.placed_entity_name(item)
        if placed_name ~= nil and claimable_item(item) and claimable_entity(dutils.get_prot("entity", placed_name)) then
            local build_edge_key = gutils.ekey({
                start = key("item", item.name),
                stop = key("entity-build-item", placed_name),
            })

            -- Mining a claimed entity gives back whichever item places it now (see reflect), while logic's edge from mining it goes to its vanilla item
            -- That edge is claimed too (a mine-back edge), and custom_prereq_search moves it along with the build slot, so it goes to the item placing the entity now, and an item placing nothing anymore (a Vestige) loses it
            -- Kept in the graph, the original game still counts what mining buildings back gave (like an item on a space platform that places something built there)
            -- An entity several items place is mined back into just one of them, so its edge is dropped instead, which only makes the model more pessimistic
            local mine_edge_key = gutils.ekey({
                start = key("entity-mine", placed_name),
                stop = key("item", item.name),
            })
            local mine_edge = graph.edges[mine_edge_key]
            if mine_edge ~= nil and num_claimed_placers[placed_name] == 1 then
                mine_edge.mine_back = true
                mine_edge.mine_back_item = item.name
                mine_edge.mine_back_entity = placed_name
                -- Mining gives an item by its name, so with first pass this head moves with the item's identity (trav), like the build base
                mine_edge.identity_head = true
                -- With first pass entity positions, mining whatever first pass puts in this item's build position gives this item, so first pass connects this head to that identity's mine base (coupled_slot, see first-pass-new.lua)
                if constants.entity_first_pass then
                    mine_edge.coupled_slot = key("orand", build_edge_key)
                end
                randomization_info.options.first_pass.blacklist[key("orand", mine_edge_key)] = true
            elseif mine_edge ~= nil then
                gutils.remove_edge(graph, mine_edge_key)
            end

            local build_edge = graph.edges[build_edge_key]
            if build_edge ~= nil then
                -- Which entity an item places is part of what the item is, so with first pass this base moves with the item's identity (trav), not its position (slot)
                build_edge.identity_base = true
                keep_from_first_pass(build_edge_key)
            end
        end
    end

    -- Every item that places nothing in vanilla gets an edge to a spoofed entity-build-item node, so its placing becomes a base that can go to an entity
    -- The sink is a spoof, so its own build slots are never randomized
    -- With first pass entity positions, each is a first pass position whose vanilla identity is nothing (see entity_positions), so only some items get one each attempt (SPOOF_POSITION_CHANCE)
    local sink = gutils.add_node(graph, "entity-build-item", SPOOF_SINK_NAME, {
        op = "OR",
        spoof = true,
    })
    local spoofable_names = {}
    for _, item in pairs(dutils.get_all_prots("item")) do
        if spoofable_item(item) and graph.nodes[key("item", item.name)] ~= nil then
            table.insert(spoofable_names, item.name)
        end
    end
    table.sort(spoofable_names)
    local spoof_rng_key = rng.key({id = "unified-entity-spoof-positions"})
    for _, item_name in pairs(spoofable_names) do
        if not constants.entity_first_pass or rng.value(spoof_rng_key) < SPOOF_POSITION_CHANCE then
            gutils.add_edge(graph, key("item", item_name), key(sink), acquisition.tag("build", {
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
            keep_from_first_pass(edge_key)
        end
    end

    -- Every capsule thrown for an effect gets an edge to a spoofed entity-own node, so its use becomes a trigger base an entity can take (made where it's thrown, instead of the effect)
    -- Only capsules with a plain throw action, since others (like cliff explosives) work on something at the spot; the sink is a spoof, so its own heads are never matched
    local maker = gutils.add_node(graph, "entity-own", SPOOF_MAKER_NAME, {
        op = "OR",
        spoof = true,
    })
    for _, item in pairs(dutils.get_all_prots("item")) do
        if effect_capsule(item) and item.capsule_action.type == "throw" and graph.nodes[key("item-capsule", item.name)] ~= nil then
            local edge = gutils.add_edge(graph, key("item-capsule", item.name), key(maker), acquisition.tag("capsule", {
                trigger_spoof = true,
                ours = true,
                amount = 1,
            }))
            keep_from_first_pass(gutils.ekey(edge))
        end
    end

    -- Entities that spawn in space, and what they break into when they die, over and over (like asteroids breaking into smaller ones)
    for _, edge in pairs(graph.edges) do
        if edge.acq_kind == "asteroid" and graph.nodes[edge.stop].type == "entity" then
            from_space[graph.nodes[edge.stop].name] = true
        end
    end
    local found_more = true
    while found_more do
        found_more = false
        for _, edge in pairs(graph.edges) do
            if edge.acq_kind == "dying" and from_space[graph.nodes[edge.start].name] ~= nil and from_space[graph.nodes[edge.stop].name] == nil then
                from_space[graph.nodes[edge.stop].name] = true
                found_more = true
            end
        end
    end

    -- Slots where a trigger makes the entity aren't split by first pass either
    -- What an item spoils into is part of what the item is, like what it places, so with first pass spoil bases move with the item's identity (trav)
    for edge_key, edge in pairs(graph.edges) do
        if claimable_made_edge(graph.nodes[edge.start], graph.nodes[edge.stop], edge) then
            keep_from_first_pass(edge_key)
            if edge.acq_kind == "spoil" then
                edge.identity_base = true
            end
        end
    end

    -- With biters on, spawn slots are claimed too, so first pass shouldn't split them either
    -- Every unit a spawner spawns also gets a placing slot that no item fills in vanilla, which an item can take (a friendly biter)
    -- Its edge comes from a source so it gets claimed, but promotion starts its head detached (starts_detached), so logic never counts on friendly biters
    local source_keys = {}
    for _, source in pairs(gutils.sources(graph)) do
        table.insert(source_keys, key(source))
    end
    table.sort(source_keys)
    if config.entity_biters then
        for edge_key, edge in pairs(graph.edges) do
            if edge.acq_kind == "spawn" and graph.nodes[edge.stop].type == "entity" then
                keep_from_first_pass(edge_key)
            end
        end
        for node_key, node in pairs(graph.nodes) do
            if node.type == "entity-build-item" and lookups.unit_spawns_reverse[node.name] ~= nil and next(node.pre) == nil then
                local edge = gutils.add_edge(graph, source_keys[1], node_key, acquisition.tag("build", {
                    friendly = true,
                    starts_detached = true,
                    amount = 1,
                }))
                keep_from_first_pass(gutils.ekey(edge))
            end
        end

        -- A built entity carried by biters (a carrier, see reflect) is gotten by killing a unit from its slot, which takes damage the unit's resistances let through (the carrier keeps them)
        -- So each spawn and spoil slot also gets a carrier base: a spoofed edge from an AND of the slot's source and the unit's resistance group, which a build head takes in place of the slot's own base (see custom_prereq_search)
        -- The sink is a spoof and its heads start detached, so nothing is carried in vanilla
        local carrier_sink = gutils.add_node(graph, "entity-own", SPOOF_CARRIER_NAME, {
            op = "OR",
            spoof = true,
        })
        local slot_edge_keys = {}
        for edge_key, edge in pairs(graph.edges) do
            local start = graph.nodes[edge.start]
            local stop = graph.nodes[edge.stop]
            local is_slot = (edge.acq_kind == "spawn" and start.type == "entity-spawn" and stop.type == "entity") or (edge.acq_kind == "spoil" and claimable_made_edge(start, stop, edge))
            local group = lookups.entity_resistance_groups.to_resistance[stop.name]
            if is_slot and group ~= nil and graph.nodes[key("resistance-group", group)] ~= nil then
                table.insert(slot_edge_keys, edge_key)
            end
        end
        table.sort(slot_edge_keys)
        for _, edge_key in pairs(slot_edge_keys) do
            local edge = graph.edges[edge_key]
            local unit_name = graph.nodes[edge.stop].name
            local kill_node = gutils.add_node(graph, "entity-kill", gutils.concat({
                SPOOF_CARRIER_NAME,
                edge.start,
                unit_name,
            }), {
                op = "AND",
                spoof = true,
            })
            gutils.add_edge(graph, edge.start, key(kill_node), {
                amount = edge.amount,
            })
            gutils.add_edge(graph, key("resistance-group", lookups.entity_resistance_groups.to_resistance[unit_name]), key(kill_node))
            -- The carrier base keeps the slot's own abilities and says which slot it's for (carrier_source and carrier_unit, see carrier_bases), and a spawn slot's spawner and unit like the slot's base
            local carrier_edge = gutils.add_edge(graph, key(kill_node), key(carrier_sink), acquisition.tag(edge.acq_kind, {
                carrier_spoof = true,
                carrier_source = edge.start,
                carrier_unit = unit_name,
                spawner = edge.spawner,
                entity = edge.entity,
                abilities = table.deepcopy(edge.abilities),
                starts_detached = true,
                amount = 1,
            }))
            randomization_info.options.first_pass.blacklist[key("orand", gutils.ekey(carrier_edge))] = true
        end
    end

    -- With first pass entity positions: nowhere positions, never reached, so an identity first pass puts there stops being acquired (detached), like an entity no longer found in the wild
    -- Their vanilla identity is nothing, which takes the place the detached identity left; each needs its own edge, so each has its own sink
    if constants.entity_first_pass then
        for i = 1, NUM_NOWHERE_POSITIONS do
            local nowhere_sink = gutils.add_node(graph, "entity-own", SPOOF_NOWHERE_NAME .. "-" .. i, {
                op = "OR",
                spoof = true,
            })
            gutils.add_edge(graph, source_keys[1], key(nowhere_sink), {
                nowhere = true,
                starts_detached = true,
                amount = 1,
            })
        end
    end
end

-- Claims each item --> entity-build-item edge (acq_kind build) between a claimable item and entity, and the spoofed edges from items that place nothing and into units' placing slots
-- Also claims each room-autoplace --> entity edge (acq_kind autoplace) of a claimable autoplaced entity, with biters on each entity-spawn --> entity edge (acq_kind spawn), and the slots where a trigger makes the entity that claimable_made_edge allows
entity.claim = function(graph, prereq, dep, edge)
    if edge == nil or dep == nil then
        return false
    end
    -- Mine-back edges follow the build slots, carrier bases stand in for spawn and spoil slots, and nowhere positions are where first pass's detached identities go (see spoof)
    if edge.mine_back ~= nil or edge.carrier_spoof ~= nil or edge.nowhere ~= nil then
        return 1
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
    if edge.trigger_spoof ~= nil then
        return 1
    end
    if is_made_kind(edge.acq_kind) then
        if not claimable_made_edge(prereq, dep, edge) then
            return false
        end
        return 1
    end
    return false
end

-- The entity whose slot this head is (heads feed an orand of the entity's entity-build-item node, of its entity node for autoplace and similar slots, or of its entity-own node for trigger slots)
local function head_entity_name(graph, head)
    return graph.nodes[graph.orand_to_parent[key(gutils.get_owner(graph, head))]].name
end

-- Each spawn or spoil slot's base --> its carrier base (see spoof), and each carrier base --> its slot's base
local function carrier_bases(graph)
    local carrier_of_slot = {}
    for node_key, node in pairs(graph.nodes) do
        if node.type == "base" and node.carrier_spoof ~= nil then
            carrier_of_slot[node.carrier_source] = carrier_of_slot[node.carrier_source] or {}
            carrier_of_slot[node.carrier_source][node.carrier_unit] = node_key
        end
    end
    local carrier_base_of = {}
    local slot_base_of = {}
    for node_key, node in pairs(graph.nodes) do
        if node.type == "base" and node.carrier_spoof == nil and (node.acq_kind == "spawn" or node.acq_kind == "spoil") then
            local carrier_key = (carrier_of_slot[key(gutils.get_owner(graph, node))] or {})[head_entity_name(graph, graph.nodes[node.old_head])]
            if carrier_key ~= nil then
                carrier_base_of[node_key] = carrier_key
                slot_base_of[carrier_key] = node_key
            end
        end
    end
    return carrier_base_of, slot_base_of
end

-- Build bases are items, autoplace bases rooms, spawn bases spawners, trigger bases the capsule, ammo or spawner capture making the entity, spoil bases the spoiling item, dying bases killing the dying entity, and carrier bases killing a spawn or spoil slot's unit; claim already makes sure of that, but this is the hard check the search uses
-- The pairing of the base's and head's acquisition kinds must also be one logic can model (acquisition.pairing)
entity.validate = function(graph, base, head, extra)
    -- A mine-back base only goes to a mine-back head (see spoof)
    if base.mine_back ~= nil or head.mine_back ~= nil then
        return base.mine_back ~= nil and head.mine_back ~= nil
    end
    -- A unit's placing slot's own base is only there so its edge could be claimed
    local pairing = acquisition.pairing(base, head)
    if base.friendly ~= nil or pairing == nil then
        return false
    end
    -- A pairing that takes killing a carrier (a built entity carried by a slot's unit) needs a base that includes the kill, the slot's carrier base (see spoof), and only such pairings take a carrier base
    if (pairing.needs_kill ~= nil) ~= (base.carrier_spoof ~= nil) then
        return false
    end
    if base.carrier_spoof ~= nil then
        return head.friendly == nil
    end
    local owner_type = gutils.get_owner(graph, base).type
    if base.acq_kind == "build" then
        return owner_type == "item"
    end
    if base.acq_kind == "spawn" then
        return owner_type == "entity-spawn"
    end
    if base.acq_kind == "capsule" then
        return owner_type == "item-capsule"
    end
    if base.acq_kind == "ammo" then
        return owner_type == "item-ammo"
    end
    if base.acq_kind == "capture" then
        return owner_type == "entity-capture-spawner"
    end
    if base.acq_kind == "spoil" then
        return owner_type == "item"
    end
    if base.acq_kind == "dying" then
        return owner_type == "entity-kill"
    end
    return owner_type == "room-autoplace"
end

-- What getting an entity through another kind of slot gains or loses, like salvaging an autoplaced entity not being automatable (acquisition.pairing)
entity.connection_abilities = function(base, head)
    -- Mining an entity back gives its item however the entity was gotten, so a mine-back connection keeps the mining edge's own abilities
    if base.mine_back ~= nil then
        return base.abilities
    end
    local pairing = acquisition.pairing(base, head)
    if pairing == nil then
        error("Randomization assertion failed! Entity randomization connected " .. key(base) .. " to " .. key(head) .. ", which logic can't model")
    end
    return pairing.abilities
end

-- The item whose placing this base is
local function base_item_name(graph, base)
    return gutils.get_owner(graph, base).name
end

-- How a base where a trigger makes the entity (see is_made_kind) makes it, for the log
local function trigger_action(graph, base)
    local owner_name = gutils.get_owner(graph, base).name
    if base.acq_kind == "capsule" then
        return "using " .. owner_name
    end
    if base.acq_kind == "ammo" then
        return "firing " .. owner_name
    end
    if base.acq_kind == "spoil" then
        return owner_name .. " spoiling"
    end
    if base.acq_kind == "dying" then
        return "killing " .. owner_name
    end
    return "capturing " .. owner_name
end

-- Cost of the item in the base game (lib/cost/material-costs), or nil if unknown
local function item_cost(item_name)
    local cost = material_costs.costs[key("item", item_name)]
    if type(cost) == "number" and cost > 0 then
        return cost
    end
    return nil
end

-- Whether two costs are within COST_TOLERANCE of each other
local function costs_within(cost1, cost2)
    return cost1 <= COST_TOLERANCE * cost2 and cost2 <= COST_TOLERANCE * cost1
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

-- This handler's heads feeding this dep: build heads (into an orand of an entity-build-item node), autoplace, spawn, spoil and dying heads (into an orand of an entity node), and trigger heads (into an orand of an entity-own node)
local function acquisition_heads_of(graph, dep_key)
    local heads = {}
    for pre, _ in pairs(graph.nodes[dep_key].pre) do
        local prenode = gutils.prenode(graph, pre)
        if prenode.type == "head" and (prenode.acq_kind == "build" or prenode.acq_kind == "autoplace" or prenode.acq_kind == "spawn" or is_made_kind(prenode.acq_kind)) then
            table.insert(heads, prenode)
        end
    end
    return heads
end

-- What a matched head takes instead of a base when its entity stops being acquired that way (a detached head, see promotion's try_rewires)
-- Units' placing slots start this way, since no item places them in vanilla
local DETACHED = "detached"

-- Matches bases to heads one to one, which the generic search can't guarantee (its fallback can reuse a base).
-- Taking bases greedily strands heads, since many (like assembling machines, needed isolated and automated on every planet) can only use their own base, and it's hard to tell ahead of time which.
-- Instead this starts from every head keeping its own base (always valid, since promotion guarantees vanilla bases), takes a random matching of heads to admissible bases, and applies it a group at a time.
-- A group is a cycle of heads taking each other's bases, or a chain of them ending at a head that takes a spoof placer, salvages from the wild, is carried by a biter, is made by a trigger slot, or is detached.
-- Each group is committed as a whole only if promotion can still establish everything promised (try_rewires), so the matching stays valid and one to one throughout and this can't fail.
local function matched_search(params)
    local graph = params.random_graph
    local prom = params.promotion
    if prom == nil then
        error("Entity randomization needs promotion (USE_PROMOTION in randomizations/graph/unified/execute-new.lua)")
    end
    -- With first pass, promotion reasons over its split graph; this handler's slots aren't split (see spoof), and their heads and bases keep the same keys there

    -- First pass matches entity identities to build positions (see spoof and first-pass-new.lua), so a build slot's head is a position whose built entity is the identity first pass put there
    -- Everything about what's built (its cost, demand tier, look, mining) is then the identity's, and build slots don't trade items among each other here, since first pass did that
    identity_of_position = {}
    local first_pass_entities = false
    if params.slot_to_trav ~= nil and params.split_graph ~= nil then
        for slot_key, trav_key in pairs(params.slot_to_trav) do
            local slot_node = params.split_graph.nodes[slot_key]
            if slot_node ~= nil and slot_node.type == "entity-build-item" then
                identity_of_position[slot_node.name] = params.split_graph.nodes[params.split_graph.nodes[trav_key].old_slot].name
                first_pass_entities = true
            end
        end
    end

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
            -- The entity built through this slot (only build positions can hold another identity)
            slot.identity = slot.entity_name
            if slot.kind == "build" then
                slot.identity = identity_at(slot.entity_name)
            end
            table.insert(slots, slot)
            if slot.kind == "build" and not friendly then
                num_build_heads[slot.entity_name] = (num_build_heads[slot.entity_name] or 0) + 1
            end
        end
    end

    -- Anchor every build head at its own base, which promises each entity stays buildable where it's needed (or in its earliest context)
    -- Autoplace, spawn and trigger heads aren't anchored, so an entity found in the wild, spawned or made by a trigger slot can move elsewhere unless something promised needs it where it was
    for _, slot in pairs(slots) do
        if slot.kind == "build" and not slot.friendly then
            prom.resolve_head(slot.head_key, slot.own_base_key, prom.required_contexts(slot.dep_key))
        end
    end

    -- Mine-back pairs follow the build slots (see spoof): an item's mine-back head is fed by the mine base of the entity it places now
    -- item name --> its mine-back head, entity name --> its mine-back base, and each mine-back head's base now (DETACHED once it's mined back from nothing)
    -- A mine-back head starts where first pass left it: fed by the mine base of the identity first pass put at its item's position (its vanilla base without first pass)
    local mine_head_of_item = {}
    local mine_base_of_entity = {}
    local mine_base_now = {}
    for node_key, node in pairs(graph.nodes) do
        if node.mine_back ~= nil and node.type == "base" then
            mine_base_of_entity[node.mine_back_entity] = node_key
        end
    end
    for node_key, node in pairs(graph.nodes) do
        if node.mine_back ~= nil and node.type == "head" then
            mine_head_of_item[node.mine_back_item] = node_key
            mine_base_now[node_key] = mine_base_of_entity[identity_at(node.mine_back_entity)] or DETACHED
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

    -- Items that place nothing in vanilla (spoof bases, see spoof) can also be taken, and so can capsules thrown for an effect (maker bases)
    local spoof_base_keys = {}
    local maker_base_keys = {}
    for _, base_key in pairs(params.shuffled_prereqs) do
        if graph.nodes[base_key].build_spoof ~= nil then
            table.insert(spoof_base_keys, base_key)
        elseif graph.nodes[base_key].trigger_spoof ~= nil then
            table.insert(maker_base_keys, base_key)
        end
    end
    -- A built entity carried by biters takes a spawn or spoil slot like a unit would (so the slot's unit moves elsewhere or stops), but connects to the slot's carrier base, which also needs killing the unit (see spoof)
    local carrier_base_of, slot_base_of = carrier_bases(graph)
    -- The base a slot's head connects to when it takes base_key, or nil if it can't (a spawn or spoil slot without a carrier base)
    local function connection_base(slot, base_key)
        local base = graph.nodes[base_key]
        if base ~= nil and slot.kind == "build" and base.carrier_spoof == nil and (base.acq_kind == "spawn" or base.acq_kind == "spoil") then
            return carrier_base_of[base_key]
        end
        return base_key
    end
    local slot_of_own_base = {}
    for ind, slot in pairs(slots) do
        if not slot.friendly then
            slot_of_own_base[slot.own_base_key] = ind
        end
    end

    -- The own item of the entity a build slot builds (its identity's item in vanilla), its cost, and how many of it a base needs (acquisition.demand_tier)
    local own_item_name_of = {}
    for _, slot in pairs(slots) do
        if slot.kind == "build" and not slot.friendly then
            own_item_name_of[slot.entity_name] = base_item_name(graph, graph.nodes[slot.own_base_key])
        end
    end
    local function own_item_of(slot)
        return starting_item(own_item_name_of[slot.identity])
    end
    local function tier_of(slot)
        return acquisition.demand_tier(dutils.get_prot("entity", slot.identity).type, own_item_of(slot).stack_size)
    end
    -- Whether an item costs about as much as the own item of what a build slot builds (unknown costs pass, as items without costs are rare)
    local function costs_close_to_own(slot, item_name)
        local cost = item_cost(item_name)
        local own_cost = item_cost(own_item_of(slot).name)
        if cost == nil or own_cost == nil then
            return true
        end
        return costs_within(cost, own_cost)
    end

    -- Whether a built entity can instead be acquired some other way that gives the entity itself, found in the wild (salvage) or carried by a biter (loot), for an item that places it
    -- It needs one item placing it, and a demand tier that kind of slot can supply (acquisition.can_supply)
    local function movable_building(slot, slot_kind)
        return not slot.friendly and num_build_heads[slot.entity_name] == 1 and acquisition.can_supply(tier_of(slot), slot_kind)
    end
    -- Salvaging also needs it to be minable, and to have no autoplace of its own (an entity has one autoplace, and one this handler didn't claim has to stay)
    local function salvageable(slot)
        return movable_building(slot, "autoplace") and dutils.get_prot("entity", slot.identity).minable ~= nil and starting_entity(slot.identity).autoplace == nil
    end
    -- Being made by a trigger slot, or left behind as a wreck, also needs it to be minable, since placing its item somewhere else has to be undoable like it was
    local function triggerable(slot, slot_kind)
        return movable_building(slot, slot_kind) and dutils.get_prot("entity", slot.identity).minable ~= nil
    end

    -- Whether a slot could take a base: a valid pairing, an item of similar cost or an entity that fits where the autoplace slot's entity was, that promotion can establish before the head wherever the head is promised
    local function admissible(slot, base_key, contexts)
        local base = graph.nodes[base_key]
        local connect_key = connection_base(slot, base_key)
        if connect_key == nil or not entity.validate(graph, graph.nodes[connect_key], slot.head) then
            return false
        end
        if base.acq_kind == "build" and not slot.friendly and not costs_close_to_own(slot, base_item_name(graph, base)) then
            return false
        end
        if base.acq_kind == "autoplace" and not common.fits_autoplace_of(dutils.get_prot("entity", slot.identity), dutils.get_prot("entity", base.entity), AUTOPLACE_AREA_TOLERANCE) then
            return false
        end
        -- A carrier is its slot's unit (spawned, or hatched from an egg) with the entity's look as its run_animation, so the unit needs one, and has to be worth killing for the entity's item (acquisition.worth_carrying)
        if (base.acq_kind == "spawn" or base.acq_kind == "spoil") and slot.kind == "build" then
            local unit = starting_entity(head_entity_name(graph, graph.nodes[base.old_head]))
            if unit.run_animation == nil or not acquisition.worth_carrying(unit.max_health or 1, item_cost(own_item_of(slot).name)) then
                return false
            end
        end
        -- A wreck is left by killing an enemy, which has to be worth killing for the entity's item like a carrier, and it looks like the entity (common.wreck_of)
        if base.acq_kind == "dying" and slot.kind == "build" then
            local dying = starting_entity(gutils.get_owner(graph, base).name)
            if not acquisition.worth_carrying(dying.max_health or 1, item_cost(own_item_of(slot).name)) or common.entity_sprite(dutils.get_prot("entity", slot.identity), 1) == nil then
                return false
            end
        end
        -- Salvage is never worth more than SALVAGE_COST_FACTOR times what mining the slot's entity gave, and needs both costs known to check that (acquisition.worth_salvaging)
        if base.acq_kind == "autoplace" and slot.kind == "build" and not acquisition.worth_salvaging(item_cost(own_item_of(slot).name), mining_yield_cost(starting_entity(base.entity))) then
            return false
        end
        -- A built entity made by using an item costs about as much as that item, with both costs known, like loot and salvage
        if slot.kind == "build" and (base.acq_kind == "capsule" or base.acq_kind == "ammo") then
            local cost = item_cost(base_item_name(graph, base))
            local own_cost = item_cost(own_item_of(slot).name)
            if cost == nil or own_cost == nil or not costs_within(cost, own_cost) then
                return false
            end
        end
        -- A built entity a captured spawner turns into takes the spawner's place, so it has to fit there
        if slot.kind == "build" and base.acq_kind == "capture" then
            local spawner = dutils.get_prot("entity", gutils.get_owner(graph, base).name)
            if not common.fits_autoplace_of(dutils.get_prot("entity", slot.identity), spawner, CAPTURE_AREA_TOLERANCE) then
                return false
            end
        end
        return #contexts == 0 or prom.head_candidate_ok(slot.head_key, connect_key, contexts)
    end

    -- The bases each slot could take besides its own
    -- Autoplace, spawn, spoil and dying slots trade among their own kind, and trigger slots among each other; build slots take other items, and some take items that placed nothing, autoplace slots (salvage), spawn or spoil slots (carried by a biter), trigger slots, or dying slots (a wreck)
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
                local same_kind = other.kind == slot.kind or (is_trigger_kind(other.kind) and is_trigger_kind(slot.kind))
                if other ~= slot and same_kind and not other.friendly and not (slot.kind == "build" and first_pass_entities) then
                    table.insert(candidates, other.own_base_key)
                end
            end
            -- What a trigger slot makes can also be made by a capsule thrown for an effect
            if is_trigger_kind(slot.kind) then
                for _, base_key in pairs(maker_base_keys) do
                    table.insert(candidates, base_key)
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
            -- Only some entities are carried by biters, since each one takes the place of a unit a spawner spawned or an egg hatched
            if rng.value(rng_key) < CARRIER_CHANCE then
                for _, other in pairs(slots) do
                    if (other.kind == "spawn" or other.kind == "spoil") and movable_building(slot, other.kind) then
                        table.insert(candidates, other.own_base_key)
                    end
                end
            end
            -- Only some entities are made by trigger slots, since each one takes the place of what the slot made (or a capsule's effect)
            if rng.value(rng_key) < TRIGGER_CHANCE then
                for _, other in pairs(slots) do
                    if is_trigger_kind(other.kind) and triggerable(slot, other.kind) then
                        table.insert(candidates, other.own_base_key)
                    end
                end
                if triggerable(slot, "capsule") then
                    for _, base_key in pairs(maker_base_keys) do
                        table.insert(candidates, base_key)
                    end
                end
            end
            -- Only some entities are left behind as wrecks, since each one takes the place of what a dying enemy left
            if rng.value(rng_key) < WRECK_CHANCE then
                for _, other in pairs(slots) do
                    if other.kind == "dying" and triggerable(slot, "dying") then
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
        -- An entity found in the wild, spawned, or made by a trigger, spoiling item or dying entity that nothing promised needs there can stop being acquired there, when another entity takes its slot
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

    -- The mine-back changes that go with a group's build slot changes: an item a build slot takes is mined back from that slot's entity now (from nothing if the entity isn't mined back into it, like a unit)
    -- An item whose placing nothing takes anymore (a Vestige) is mined back from nothing
    -- Items that placed nothing in vanilla (spoof placers) have no mine-back head, since nothing was mined into them; the model just doesn't count that mining gives them now
    local function mine_back_changes(component)
        local changes = {}
        local function set_mine_base(item_name, base_key)
            local head_key = mine_head_of_item[item_name]
            if head_key == nil or mine_base_now[head_key] == base_key then
                return
            end
            local remove = {}
            if mine_base_now[head_key] ~= DETACHED then
                table.insert(remove, mine_base_now[head_key])
            end
            if base_key == DETACHED then
                table.insert(changes, {
                    node_key = head_key,
                    remove = remove,
                    detach = true,
                })
            else
                table.insert(changes, {
                    node_key = head_key,
                    remove = remove,
                    add = base_key,
                })
            end
        end
        for _, ind in pairs(component) do
            local slot = slots[ind]
            if slot.kind == "build" then
                local taken = takes[ind]
                if taken ~= DETACHED and graph.nodes[taken].acq_kind == "build" and graph.nodes[taken].build_spoof == nil then
                    set_mine_base(base_item_name(graph, graph.nodes[taken]), mine_base_of_entity[slot.identity] or DETACHED)
                end
                if not slot.friendly and taker_of[slot.own_base_key] == nil then
                    set_mine_base(base_item_name(graph, graph.nodes[slot.own_base_key]), DETACHED)
                end
            end
        end
        return changes
    end

    -- Commit each as a whole, only if promotion can still establish everything promised (the admissibility above was worked out once, so isn't exact)
    local counts = {
        moved = 0,
        spoofs = 0,
        salvaged = 0,
        carried = 0,
        hatched = 0,
        triggered = 0,
        wrecked = 0,
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
                    add = connection_base(slots[ind], takes[ind]),
                })
            end
        end
        local mine_changes = mine_back_changes(component)
        for _, change in pairs(mine_changes) do
            table.insert(changes, change)
        end
        if prom.try_rewires(changes, true) then
            for _, change in pairs(mine_changes) do
                if change.detach then
                    mine_base_now[change.node_key] = DETACHED
                else
                    mine_base_now[change.node_key] = change.add
                end
            end
            for _, ind in pairs(component) do
                local slot = slots[ind]
                slot.base_key = connection_base(slot, takes[ind])
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
                elseif slot.kind == "build" and graph.nodes[takes[ind]].acq_kind == "spoil" then
                    counts.hatched = counts.hatched + 1
                elseif slot.kind == "build" and graph.nodes[takes[ind]].acq_kind == "dying" then
                    counts.wrecked = counts.wrecked + 1
                elseif slot.kind == "build" and is_trigger_kind(graph.nodes[takes[ind]].acq_kind) then
                    counts.triggered = counts.triggered + 1
                end
            end
        else
            log("Entity randomization: promotion rejected a group of " .. #component .. " slots; they keep their own bases")
        end
    end

    -- Mine-back heads get the base they follow now, and ones mined back from nothing get none (detached)
    for head_key, base_key in pairs(mine_base_now) do
        if base_key ~= DETACHED then
            params.head_to_base[head_key] = base_key
        end
    end

    -- Detached heads get no base
    for _, slot in pairs(slots) do
        if slot.base_key ~= DETACHED then
            params.head_to_base[slot.head_key] = slot.base_key
        end
        if slot.base_key ~= slot.own_base_key then
            -- A carried entity's carrier base stands in for its slot's base, which says where it's carried
            local base = graph.nodes[slot_base_of[slot.base_key] or slot.base_key]
            if slot.base_key == DETACHED and slot.kind == "spawn" then
                log("Entity randomization: " .. slot.entity_name .. " isn't spawned by " .. graph.nodes[slot.own_base_key].spawner .. " anymore")
            elseif slot.base_key == DETACHED and is_made_kind(slot.kind) then
                log("Entity randomization: " .. slot.entity_name .. " isn't made by " .. trigger_action(graph, graph.nodes[slot.own_base_key]) .. " anymore")
            elseif slot.base_key == DETACHED then
                log("Entity randomization: " .. slot.entity_name .. " isn't found in the wild there anymore")
            elseif slot.friendly then
                log("Entity randomization: " .. base_item_name(graph, base) .. " now places a friendly " .. slot.identity)
            elseif base.acq_kind == "autoplace" and slot.kind == "build" then
                log("Entity randomization: " .. slot.identity .. " is now salvaged from the wild where " .. base.entity .. " was")
            elseif base.acq_kind == "spawn" and slot.kind == "build" then
                log("Entity randomization: " .. slot.identity .. " is now carried by biters " .. base.spawner .. " spawns in place of " .. base.entity)
            elseif base.acq_kind == "spoil" and slot.kind == "build" then
                log("Entity randomization: " .. slot.identity .. " is now carried by biters hatching from " .. gutils.get_owner(graph, base).name .. " in place of " .. head_entity_name(graph, graph.nodes[base.old_head]))
            elseif base.acq_kind == "dying" and slot.kind == "build" then
                log("Entity randomization: " .. slot.identity .. " is now left as a wreck by " .. trigger_action(graph, base) .. " in place of " .. head_entity_name(graph, graph.nodes[base.old_head]))
            elseif base.acq_kind == "autoplace" then
                log("Entity randomization: " .. slot.entity_name .. " is now found in the wild where " .. base.entity .. " was")
            elseif base.acq_kind == "spawn" then
                log("Entity randomization: " .. slot.entity_name .. " is now spawned by " .. base.spawner .. " in place of " .. base.entity)
            elseif base.trigger_spoof ~= nil then
                log("Entity randomization: " .. slot.identity .. " is now made by " .. trigger_action(graph, base) .. " in place of its effect")
            elseif is_made_kind(base.acq_kind) then
                log("Entity randomization: " .. slot.identity .. " is now made by " .. trigger_action(graph, base) .. " in place of " .. head_entity_name(graph, graph.nodes[base.old_head]))
            else
                log("Entity randomization: " .. base_item_name(graph, base) .. " now places " .. slot.identity)
            end
        end
    end
    log("Entity randomization: " .. counts.moved .. " of " .. #slots .. " slots changed; " .. counts.spoofs .. " to an item that placed nothing, " .. counts.salvaged .. " to salvage from the wild, " .. counts.carried .. " to biter carriers, " .. counts.hatched .. " to carriers hatching from eggs, " .. counts.triggered .. " to trigger slots, " .. counts.wrecked .. " to wrecks, " .. counts.friendly .. " friendly biters, " .. counts.detached .. " detached (" .. num_pairs .. " possible pairs)")

    return true
end

-- Entity positions: first pass matches entity identities to them like it matches item identities to item positions (see first-pass-new.lua), and this handler reflects the result
-- A position is an orand fed by one of this handler's heads (except mine-back and carrier edges): a way an entity is acquired (an item placing it, a spot in the wild, a spawner's slot, a trigger, an egg, a death), an item or capsule that makes nothing in vanilla (see spoof), or a nowhere position
-- Its vanilla identity is the entity acquired that way (the head's), or nothing
-- graph is one of unified's graphs from before first pass's split, where heads still feed their orands and bases come from their sources
-- Returns orand key --> { key, head, base, kind (the acquisition kind, or "nowhere"), entity (the vanilla identity's, nil for nothing), nothing (the vanilla identity is nothing), nowhere (never reached, so an identity there is detached), friendly (a unit's placing position) }
local function entity_positions(graph)
    local positions = {}
    for node_key, node in pairs(graph.nodes) do
        if node.type == "orand" then
            local head
            for pre, _ in pairs(node.pre) do
                local prenode = gutils.prenode(graph, pre)
                if prenode.type == "head" then
                    head = prenode
                end
            end
            if head ~= nil and head.mine_back == nil and head.carrier_spoof == nil and (head.acq_kind ~= nil or head.nowhere ~= nil) then
                local position = {
                    key = node_key,
                    head = head,
                    base = graph.nodes[head.old_base],
                    kind = head.acq_kind or "nowhere",
                    nothing = head.build_spoof ~= nil or head.trigger_spoof ~= nil or head.nowhere ~= nil,
                    nowhere = head.friendly ~= nil or head.nowhere ~= nil,
                    friendly = head.friendly ~= nil,
                }
                if not position.nothing then
                    position.entity = head_entity_name(graph, head)
                end
                positions[node_key] = position
            end
        end
    end
    return positions
end

-- The base an identity's head connects to at a position: the position's base, or its carrier base for a built entity carried by the position's unit, which also takes killing the unit (see spoof)
-- Returns nil for an identity that's nothing or detached (at a nowhere position), and false if the position has no carrier base
local function connected_base_key(position, identity, carrier_base_of)
    if identity.nothing or position.nowhere then
        return nil
    end
    local pairing = acquisition.pairing(position.base, identity.head)
    if pairing ~= nil and pairing.needs_kill ~= nil then
        return carrier_base_of[key(position.base)] or false
    end
    return key(position.base)
end

-- First pass's rules for entity positions (see first-pass-new.lua), from unified's subdivided graph (before first pass's split)
-- Returns { positions = orand key --> position (see entity_positions), pair_ok(slot, trav) (nil when neither is an entity position), connection(slot_key, trav_key) (see monotone matching's connection_of) }
-- A position takes an identity only if logic can model the pairing (acquisition.pairing, and validate on the base it connects to) and it passes the same balance checks entity randomization always made, from each identity's vanilla item and entity
-- Each identity draws once whether it may make each kind of change (the *_CHANCE constants), so only some entities change how they're acquired
entity.first_pass_rules = function(graph)
    local positions = entity_positions(graph)
    local carrier_base_of = carrier_bases(graph)
    local position_keys = {}
    for position_key, _ in pairs(positions) do
        table.insert(position_keys, position_key)
    end
    table.sort(position_keys)

    -- Each built entity's own item (its vanilla placer), and how many build identities it has (only entities one item places can change how they're acquired)
    local own_item_name_of = {}
    local num_build_identities = {}
    for _, position_key in pairs(position_keys) do
        local position = positions[position_key]
        if position.kind == "build" and not position.nothing and not position.friendly then
            own_item_name_of[position_key] = base_item_name(graph, position.base)
            num_build_identities[position.entity] = (num_build_identities[position.entity] or 0) + 1
        end
    end
    local may = {}
    local rng_key = rng.key({id = "unified-entity"})
    for _, position_key in pairs(position_keys) do
        if not positions[position_key].nothing then
            may[position_key] = {
                spoof = rng.value(rng_key) < SPOOF_CHANCE,
                salvage = rng.value(rng_key) < SALVAGE_CHANCE,
                carry = rng.value(rng_key) < CARRIER_CHANCE,
                trigger = rng.value(rng_key) < TRIGGER_CHANCE,
                wreck = rng.value(rng_key) < WRECK_CHANCE,
                friendly = rng.value(rng_key) < FRIENDLY_CHANCE,
                detach = rng.value(rng_key) < DETACH_CHANCE,
            }
        end
    end

    local function own_item(identity)
        return starting_item(own_item_name_of[identity.key])
    end
    local function own_cost(identity)
        return item_cost(own_item_name_of[identity.key])
    end
    -- Whether an item costs about as much as a built identity's own item (unknown costs pass, as items without costs are rare)
    local function costs_close_to_own(identity, item_name)
        local cost = item_cost(item_name)
        if cost == nil or own_cost(identity) == nil then
            return true
        end
        return costs_within(cost, own_cost(identity))
    end
    -- Whether a built identity can be acquired some other way that gives the entity itself, for an item that places it: one item places it, and that kind of slot can supply its demand tier (acquisition.can_supply)
    local function movable_building(identity, slot_kind)
        local tier = acquisition.demand_tier(dutils.get_prot("entity", identity.entity).type, own_item(identity).stack_size)
        return num_build_identities[identity.entity] == 1 and acquisition.can_supply(tier, slot_kind)
    end
    -- Salvaging also needs it to be minable, and to have no autoplace of its own (an entity has one autoplace, and one this handler didn't claim has to stay)
    local function salvageable(identity)
        return movable_building(identity, "autoplace") and dutils.get_prot("entity", identity.entity).minable ~= nil and starting_entity(identity.entity).autoplace == nil
    end
    -- Being made by a trigger slot, or left behind as a wreck, also needs it to be minable, since placing its item somewhere else has to be undoable like it was
    local function triggerable(identity, slot_kind)
        return movable_building(identity, slot_kind) and dutils.get_prot("entity", identity.entity).minable ~= nil
    end

    -- Whether a position can take an identity
    local function pair_allowed(position, identity)
        -- A position can end up with nothing (an item placing nothing, a spot in the wild or slot where nothing comes from anymore)
        if identity.nothing then
            return true
        end
        -- An identity at a nowhere position (or a unit's placing position) stops being acquired, which is fine for a unit's placing position's own identity and some entities that aren't built
        if position.nowhere then
            return identity.friendly or (identity.kind ~= "build" and may[identity.key].detach)
        end
        -- A unit's placing identity only goes to an item (a friendly biter), and only for some
        if identity.friendly then
            return position.kind == "build" and may[identity.key].friendly
        end
        -- Nothing and nowhere were handled above, so no base means the position has no carrier base for a carried entity
        local base_key = connected_base_key(position, identity, carrier_base_of)
        if base_key == nil or base_key == false or not entity.validate(graph, graph.nodes[base_key], identity.head) then
            return false
        end
        if position.kind == "build" then
            -- An item's build position takes a built entity whose own item costs about as much, and only some take an item that placed nothing (a spoof placer)
            if position.nothing and not may[identity.key].spoof then
                return false
            end
            return costs_close_to_own(identity, base_item_name(graph, position.base))
        end
        if identity.kind ~= "build" then
            -- Entities found in the wild, spawned, or made by a trigger, spoiling item or dying entity trade among their own kind (trigger slots among each other), and one found in the wild fits where the slot's entity was
            if position.kind ~= identity.kind and not (is_trigger_kind(position.kind) and is_trigger_kind(identity.kind)) then
                return false
            end
            if position.kind == "autoplace" then
                return common.fits_autoplace_of(dutils.get_prot("entity", identity.entity), dutils.get_prot("entity", position.base.entity), AUTOPLACE_AREA_TOLERANCE)
            end
            return true
        end
        -- A built entity in a slot giving the entity itself is mined or looted for an item that places it
        if position.kind == "autoplace" then
            -- Salvage fits where the slot's entity was, and is never worth more than SALVAGE_COST_FACTOR times what mining that entity gave (acquisition.worth_salvaging)
            return may[identity.key].salvage and salvageable(identity) and common.fits_autoplace_of(dutils.get_prot("entity", identity.entity), dutils.get_prot("entity", position.base.entity), AUTOPLACE_AREA_TOLERANCE) and acquisition.worth_salvaging(own_cost(identity), mining_yield_cost(starting_entity(position.base.entity)))
        end
        if position.kind == "spawn" or position.kind == "spoil" then
            -- A carrier is the slot's unit (spawned, or hatched from an egg) with the entity's look as its run_animation, so the unit needs one, and has to be worth killing for the entity's item (acquisition.worth_carrying)
            local unit = starting_entity(position.entity)
            return may[identity.key].carry and movable_building(identity, position.kind) and unit.run_animation ~= nil and acquisition.worth_carrying(unit.max_health or 1, own_cost(identity))
        end
        if position.kind == "dying" then
            -- A wreck is left by killing an enemy, which has to be worth killing for the entity's item like a carrier, and it looks like the entity (common.wreck_of)
            local dying = starting_entity(gutils.get_owner(graph, position.base).name)
            return may[identity.key].wreck and triggerable(identity, "dying") and acquisition.worth_carrying(dying.max_health or 1, own_cost(identity)) and common.entity_sprite(dutils.get_prot("entity", identity.entity), 1) ~= nil
        end
        if is_trigger_kind(position.kind) then
            if not may[identity.key].trigger or not triggerable(identity, position.kind) then
                return false
            end
            -- A built entity made by using an item costs about as much as that item, with both costs known, like loot and salvage
            if position.kind == "capsule" or position.kind == "ammo" then
                local cost = item_cost(base_item_name(graph, position.base))
                return cost ~= nil and own_cost(identity) ~= nil and costs_within(cost, own_cost(identity))
            end
            -- A built entity a captured spawner turns into takes the spawner's place, so it has to fit there
            local spawner = dutils.get_prot("entity", gutils.get_owner(graph, position.base).name)
            return common.fits_autoplace_of(dutils.get_prot("entity", identity.entity), spawner, CAPTURE_AREA_TOLERANCE)
        end
        return false
    end

    -- A slot's or trav's pairing never changes during first pass, but monotone matching asks for every pair again in each refinement, so both are memoized (position key --> identity key --> answer)
    local pair_memo = {}
    local connection_memo = {}
    local function memoized(memo, position_key, identity_key, compute)
        memo[position_key] = memo[position_key] or {}
        local answer = memo[position_key][identity_key]
        if answer == nil then
            answer = compute()
            if answer == nil then
                answer = false
            end
            memo[position_key][identity_key] = answer
        end
        return answer
    end

    -- A pairing gains or loses what acquisition.pairing says (like a built entity found in the wild or looted not being automatable), and a carried entity's connection starts at the position's carrier base
    local function connection_of(position, identity)
        if identity.nothing or position.nowhere then
            return nil
        end
        local pairing = acquisition.pairing(position.base, identity.head)
        if pairing == nil then
            return nil
        end
        local connection = {
            abilities = pairing.abilities,
        }
        local base_key = connected_base_key(position, identity, carrier_base_of)
        if base_key ~= key(position.base) then
            connection.base = base_key or nil
        end
        if connection.abilities == nil and connection.base == nil then
            return nil
        end
        return connection
    end

    return {
        positions = positions,
        -- Entity positions are all orands, and first pass only pairs a slot with a trav of the same node type
        pair_ok = function(slot, trav)
            if slot.type ~= "orand" then
                return nil
            end
            local position = positions[key(slot)]
            local identity = positions[trav.old_slot]
            if position == nil and identity == nil then
                return nil
            end
            if position == nil or identity == nil then
                return false
            end
            return memoized(pair_memo, position.key, identity.key, function()
                return pair_allowed(position, identity)
            end)
        end,
        connection = function(slot_key, identity_key)
            local position = positions[slot_key]
            local identity = positions[identity_key]
            if position == nil or identity == nil then
                return nil
            end
            return memoized(connection_memo, position.key, identity.key, function()
                return connection_of(position, identity)
            end) or nil
        end,
    }
end

-- Reflects first pass's entity positions (see first_pass_rules): each identity's head gets the base of the position first pass put it at (params.head_to_base, which reflect reads), and heads at nowhere positions get none (detached)
-- Mine-back heads get the mine base of the identity built at their item's position, as first pass connected them (see spoof)
-- Promotion needs nothing from this handler: first pass's split graph, its model, already has the positions connected
local function first_pass_search(params)
    local graph = params.random_graph
    if params.slot_to_trav == nil or params.split_graph == nil then
        error("Entity randomization needs first pass (DO_FIRST_PASS in randomizations/graph/unified/execute-new.lua)")
    end
    local positions = entity_positions(graph)
    local carrier_base_of = carrier_bases(graph)
    local position_keys = {}
    for position_key, _ in pairs(positions) do
        table.insert(position_keys, position_key)
    end
    table.sort(position_keys)

    -- Position key --> the identity first pass put there
    local identity_at = {}
    for _, position_key in pairs(position_keys) do
        local trav_key = params.slot_to_trav[position_key]
        if trav_key == nil then
            error("Randomization assertion failed! Entity position " .. position_key .. " isn't one of first pass's slots")
        end
        identity_at[position_key] = positions[params.split_graph.nodes[trav_key].old_slot]
    end

    local counts = {
        moved = 0,
        spoofs = 0,
        salvaged = 0,
        carried = 0,
        hatched = 0,
        triggered = 0,
        wrecked = 0,
        friendly = 0,
        detached = 0,
    }
    for _, position_key in pairs(position_keys) do
        local position = positions[position_key]
        local identity = identity_at[position_key]
        local base_key = connected_base_key(position, identity, carrier_base_of)
        if base_key == false then
            error("Randomization assertion failed! First pass carries " .. identity.key .. " at " .. position_key .. ", which has no carrier base")
        end
        -- Every built entity stays buildable somewhere, so first pass never puts one where nothing reaches (see first_pass_rules)
        if position.nowhere and not identity.nothing and not identity.friendly and identity.kind == "build" then
            error("Randomization assertion failed! First pass detached built entity " .. identity.key .. " at " .. position_key)
        end
        if base_key ~= nil then
            params.head_to_base[key(identity.head)] = base_key
        end
        if identity.key ~= position_key and not identity.nothing then
            counts.moved = counts.moved + 1
            local base = position.base
            if position.nowhere then
                if not identity.friendly then
                    counts.detached = counts.detached + 1
                    if identity.kind == "spawn" then
                        log("Entity randomization: " .. identity.entity .. " isn't spawned by " .. identity.base.spawner .. " anymore")
                    elseif is_made_kind(identity.kind) then
                        log("Entity randomization: " .. identity.entity .. " isn't made by " .. trigger_action(graph, identity.base) .. " anymore")
                    else
                        log("Entity randomization: " .. identity.entity .. " isn't found in the wild there anymore")
                    end
                end
            elseif identity.friendly then
                counts.friendly = counts.friendly + 1
                log("Entity randomization: " .. base_item_name(graph, base) .. " now places a friendly " .. identity.entity)
            elseif identity.kind == "build" and position.kind == "build" then
                if position.nothing then
                    counts.spoofs = counts.spoofs + 1
                end
                log("Entity randomization: " .. base_item_name(graph, base) .. " now places " .. identity.entity)
            elseif identity.kind == "build" and position.kind == "autoplace" then
                counts.salvaged = counts.salvaged + 1
                log("Entity randomization: " .. identity.entity .. " is now salvaged from the wild where " .. base.entity .. " was")
            elseif identity.kind == "build" and position.kind == "spawn" then
                counts.carried = counts.carried + 1
                log("Entity randomization: " .. identity.entity .. " is now carried by biters " .. base.spawner .. " spawns in place of " .. base.entity)
            elseif identity.kind == "build" and position.kind == "spoil" then
                counts.hatched = counts.hatched + 1
                log("Entity randomization: " .. identity.entity .. " is now carried by biters hatching from " .. gutils.get_owner(graph, base).name .. " in place of " .. position.entity)
            elseif identity.kind == "build" and position.kind == "dying" then
                counts.wrecked = counts.wrecked + 1
                log("Entity randomization: " .. identity.entity .. " is now left as a wreck by " .. trigger_action(graph, base) .. " in place of " .. position.entity)
            elseif identity.kind == "build" then
                counts.triggered = counts.triggered + 1
                log("Entity randomization: " .. identity.entity .. " is now made by " .. trigger_action(graph, base) .. " in place of " .. (position.entity or "its effect"))
            elseif position.kind == "autoplace" then
                log("Entity randomization: " .. identity.entity .. " is now found in the wild where " .. base.entity .. " was")
            elseif position.kind == "spawn" then
                log("Entity randomization: " .. identity.entity .. " is now spawned by " .. base.spawner .. " in place of " .. base.entity)
            else
                log("Entity randomization: " .. identity.entity .. " is now made by " .. trigger_action(graph, base) .. " in place of " .. (position.entity or "its effect"))
            end
        end
    end

    -- Mine-back heads: the item placing a build position is mined back from the identity built there, if that entity is mined back into its item at all (only entities one item places are)
    local mine_base_of_entity = {}
    for node_key, node in pairs(graph.nodes) do
        if node.mine_back ~= nil and node.type == "base" then
            mine_base_of_entity[node.mine_back_entity] = node_key
        end
    end
    for node_key, node in pairs(graph.nodes) do
        if node.mine_back ~= nil and node.type == "head" then
            local identity = identity_at[node.coupled_slot]
            if identity ~= nil and not identity.nothing and not identity.friendly and identity.kind == "build" then
                params.head_to_base[node_key] = mine_base_of_entity[identity.entity]
            end
        end
    end

    log("Entity randomization: " .. counts.moved .. " of " .. #position_keys .. " slots changed; " .. counts.spoofs .. " to an item that placed nothing, " .. counts.salvaged .. " to salvage from the wild, " .. counts.carried .. " to biter carriers, " .. counts.hatched .. " to carriers hatching from eggs, " .. counts.triggered .. " to trigger slots, " .. counts.wrecked .. " to wrecks, " .. counts.friendly .. " friendly biters, " .. counts.detached .. " detached")

    return true
end

-- The search: with first pass entity positions (constants.entity_first_pass), reflecting first pass's matching, and otherwise matching this handler's slots itself
entity.custom_prereq_search = function(params)
    if constants.entity_first_pass then
        return first_pass_search(params)
    end
    return matched_search(params)
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

-- How a trigger slot's base makes its entity, as rich text: using a capsule, firing ammo, or capturing a spawner
local function made_by_description(graph, base)
    local owner_name = gutils.get_owner(graph, base).name
    if base.acq_kind == "capture" then
        return {"", "capturing [entity=" .. owner_name .. "] ", locale.find_localised_name(dutils.get_prot("entity", owner_name))}
    end
    local verb = "using "
    if base.acq_kind == "ammo" then
        verb = "firing "
    end
    return {"", verb .. "[item=" .. owner_name .. "] ", locale.find_localised_name(dutils.get_prot("item", owner_name))}
end

-- A prototype's description with a line in front, leaving out its own description if it has none rather than show a missing key
local function with_description_line(prototype, description_key, line)
    if prototype.localised_description ~= nil then
        return {"", line, "\n", table.deepcopy(prototype.localised_description)}
    end
    return {"", line, {"?", {"", "\n", {description_key .. "." .. prototype.name}}, ""}}
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
    -- Built entity made by a trigger slot --> its trigger base, built entity a carrier hatches from an egg --> its spoil base, and built entity left as a wreck --> its dying base
    local triggered = {}
    local hatched = {}
    local wrecked = {}
    -- Base where a trigger makes an entity (see is_made_kind) --> the entity it makes now, only ones that changed (carriers and wrecks are added once they're made)
    local made_occupants = {}
    -- Carrier base --> the spawn or spoil slot's base it stands in for (see spoof)
    local _, slot_base_of = carrier_bases(graph)
    -- Built entity --> the item that placed it in vanilla, its own item (so its look and what mining it gave)
    local own_item_of_entity = {}
    for head_key, handler in pairs(head_to_handler) do
        local head = graph.nodes[head_key]
        if handler.id == entity.id and head.acq_kind == "build" and head.friendly == nil and head.mine_back == nil and head.build_spoof == nil then
            own_item_of_entity[head_entity_name(graph, head)] = base_item_name(graph, graph.nodes[head.old_base])
        end
    end

    -- Detached heads have no base, so this goes over every head of this handler
    for head_key, handler in pairs(head_to_handler) do
        local head = graph.nodes[head_key]
        -- Heads into spoofed nodes (like the one items placing nothing in vanilla feed) are never matched
        -- Mine-back heads need no reflection of their own: mining an entity gives the item placing it now, which the build slots' reflection sets up
        local parent = graph.nodes[graph.orand_to_parent[key(gutils.get_owner(graph, head))]]
        if handler.id == entity.id and parent.spoof == nil and head.mine_back == nil then
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
                -- The item that placed this entity in vanilla (its own item), and where first pass put it (its base)
                local position_item_name = base_item_name(graph, graph.nodes[head.old_base])
                entity_to_old_items[entity_name] = entity_to_old_items[entity_name] or {}
                table.insert(entity_to_old_items[entity_name], own_item_of_entity[entity_name])
                old_item_to_head[position_item_name] = head_key
                num_heads = num_heads + 1
                if graph.nodes[base_key].acq_kind == "autoplace" then
                    salvaged[entity_name] = base_key
                elseif graph.nodes[base_key].acq_kind == "spawn" or graph.nodes[base_key].acq_kind == "spoil" then
                    -- A carried entity connects to its slot's carrier base, which also needs killing the slot's unit (see spoof); the slot's own base says where it's carried
                    local slot_base_key = slot_base_of[base_key]
                    if slot_base_key == nil then
                        error("Randomization assertion failed! Entity randomization carries " .. entity_name .. " through " .. base_key .. ", which isn't a carrier base")
                    end
                    if graph.nodes[base_key].acq_kind == "spawn" then
                        carried[entity_name] = slot_base_key
                    else
                        hatched[entity_name] = slot_base_key
                    end
                elseif graph.nodes[base_key].acq_kind == "dying" then
                    wrecked[entity_name] = base_key
                elseif is_trigger_kind(graph.nodes[base_key].acq_kind) then
                    triggered[entity_name] = base_key
                    made_occupants[base_key] = entity_name
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
            elseif is_made_kind(head.acq_kind) then
                -- What a trigger makes that took another such slot is made there now; a detached one isn't made by anything
                if base_key ~= nil and base_key ~= head.old_base then
                    made_occupants[base_key] = entity_name
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

    -- An item used by clicking (a capsule) never places anything, since placing would take over its click (see spoofable_item_types)
    for item_name, _ in pairs(item_to_entity) do
        if dutils.get_prot("item", item_name).capsule_action ~= nil then
            error("Randomization assertion failed! Entity randomization made capsule " .. item_name .. " place something")
        end
    end

    -- The model's mine-back edges (see spoof) have to match what mining gives in the game: an item is mined back from the entity it places now, if that entity is mined back into its item at all
    local mine_base_of_entity = {}
    for node_key, node in pairs(graph.nodes) do
        if node.type == "base" and node.mine_back ~= nil then
            mine_base_of_entity[node.mine_back_entity] = node_key
        end
    end
    for head_key, handler in pairs(head_to_handler) do
        local head = graph.nodes[head_key]
        if handler.id == entity.id and head.mine_back ~= nil then
            local placed = item_to_entity[head.mine_back_item]
            local expected
            if placed ~= nil then
                expected = mine_base_of_entity[placed]
            end
            if head_to_base[head_key] ~= expected then
                error("Randomization assertion failed! Entity randomization's model mines " .. head.mine_back_item .. " back from " .. tostring(head_to_base[head_key]) .. ", but it places " .. tostring(placed))
            end
        end
    end

    -- The item that now places a build slot's entity (or the room it's salvaged in)
    local function placer_of(head_key)
        return base_item_name(graph, graph.nodes[head_to_base[head_key]])
    end

    -- Whether a build slot ends a chain of slots taking each other's vanilla items: it took a spoof placer, or a slot giving the entity itself (salvaged, carried by biters, or made by a trigger slot)
    local function ends_chain(head_key)
        local base = graph.nodes[head_to_base[head_key]]
        return base.build_spoof ~= nil or not acquisition.gives_item(base.acq_kind)
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

    -- Vestige --> its place_result change, which one that gets a capsule's effect points at the effect instead (see below), and the entity it placed with where that's from now, for its description
    local vestige_place_changes = {}
    local vestige_was = {}

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
            local look = starting_item(own_item_of_entity[last_entity.name])
            local vestige = dutils.get_prot("item", old_item_name)
            local last_entity_name = locale.find_localised_name(last_entity)
            local now_from
            if carried[last_entity.name] ~= nil then
                log("Entity randomization: " .. old_item_name .. " places nothing now, and looks like a darkened " .. look.name .. " (" .. last_entity.name .. " is now carried by biters)")
                now_from = {"", " is now carried by biters; kill one for an item that places it."}
            elseif salvaged[last_entity.name] ~= nil then
                log("Entity randomization: " .. old_item_name .. " places nothing now, and looks like a darkened " .. look.name .. " (" .. last_entity.name .. " is now salvaged from the wild)")
                now_from = {"", " is now found in the wild; mine one for an item that places it."}
            elseif triggered[last_entity.name] ~= nil then
                local base = graph.nodes[triggered[last_entity.name]]
                log("Entity randomization: " .. old_item_name .. " places nothing now, and looks like a darkened " .. look.name .. " (" .. last_entity.name .. " is now made by " .. trigger_action(graph, base) .. ")")
                now_from = {"", " is now made by ", made_by_description(graph, base), "; mine one for an item that places it."}
            elseif hatched[last_entity.name] ~= nil then
                local egg = dutils.get_prot("item", gutils.get_owner(graph, graph.nodes[hatched[last_entity.name]]).name)
                log("Entity randomization: " .. old_item_name .. " places nothing now, and looks like a darkened " .. look.name .. " (" .. last_entity.name .. " is now carried by biters hatching from " .. egg.name .. ")")
                now_from = {"", " is now carried by biters hatching from [item=" .. egg.name .. "] ", locale.find_localised_name(egg), "; kill one for an item that places it."}
            elseif wrecked[last_entity.name] ~= nil then
                local dying = dutils.get_prot("entity", gutils.get_owner(graph, graph.nodes[wrecked[last_entity.name]]).name)
                log("Entity randomization: " .. old_item_name .. " places nothing now, and looks like a darkened " .. look.name .. " (" .. last_entity.name .. " is now left as a wreck by " .. dying.name .. ")")
                now_from = {"", " is now left as a wreck by [entity=" .. dying.name .. "] ", locale.find_localised_name(dying), " when it dies; mine it for an item that places it."}
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
            vestige_was[old_item_name] = {
                entity = last_entity.name,
                entity_name = last_entity_name,
                now_from = now_from,
            }
            vestige.subgroup = look.subgroup
            vestige.order = look.order
            vestige.stack_size = look.stack_size
            -- Item randomization (reflected after this) routes items it finds useless differently (dutils.is_useless_item), and it planned with this item still placing, so it only stops placing once every handler has reflected
            local place_change = {
                tbl = vestige,
                prop = "place_result",
                new_val = nil,
            }
            table.insert(changes, place_change)
            vestige_place_changes[old_item_name] = place_change
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

    -- A built entity gotten as itself rather than from an item (found in the wild, or made by a trigger slot) is mined for a new item that places it
    -- The item looks like the entity's own item did, whose placing went elsewhere (to another entity, or nothing as a Vestige)
    local function add_salvage_item(entity_name, description)
        local entity_prot = dutils.get_prot("entity", entity_name)
        local old_item_name = entity_to_old_items[entity_name][1]
        local salvage = table.deepcopy(starting_item(old_item_name))
        salvage.name = "propertyrandomizer-salvaged-" .. entity_name
        common.set_placed_entity(salvage, entity_prot)
        salvage.localised_name = salvage.localised_name or locale.find_localised_name(entity_prot)
        salvage.localised_description = description
        data:extend({
            salvage,
        })
        -- Mining is how it's gotten, so it always gives the salvage item, but everything else mining gave stays, since logic still counts on it
        common.swap_mining_items(entity_prot, entity_to_old_items[entity_name], salvage.name, true)
        common.replace_placeable_by_item(entity_prot, old_item_name, salvage.name)
        return salvage
    end

    -- A salvaged entity is found in the wild for the neutral force (its slot's autoplace force), which can't be used where it stands, so it's mined for a salvage item
    for entity_name, base_key in pairs(salvaged) do
        local salvage = add_salvage_item(entity_name, salvage_description(dutils.get_prot("entity", entity_name)))
        log("Entity randomization: " .. entity_name .. " is found in the wild where " .. graph.nodes[base_key].entity .. " was, and mined for " .. salvage.name)
    end

    -- A built entity made by a trigger slot is ours where it's made, and is mined for a salvage item to place it anywhere else
    for entity_name, base_key in pairs(triggered) do
        local entity_prot = dutils.get_prot("entity", entity_name)
        local salvage = add_salvage_item(entity_name, {"", "Mined from [entity=" .. entity_name .. "] ", locale.find_localised_name(entity_prot), " made by ", made_by_description(graph, graph.nodes[base_key]), "."})
        log("Entity randomization: " .. entity_name .. " is made by " .. trigger_action(graph, graph.nodes[base_key]) .. ", and mined for " .. salvage.name)
    end

    -- What this seed only gets by hand, and from where (logged as FARMREPORT lines at the end)
    local farm_report = {}
    local function demand_tier_of(entity_name)
        return acquisition.demand_tier(dutils.get_prot("entity", entity_name).type, starting_item(entity_to_old_items[entity_name][1]).stack_size)
    end
    for entity_name, base_key in pairs(salvaged) do
        local base = graph.nodes[base_key]
        table.insert(farm_report, "salvage: " .. entity_name .. " (" .. demand_tier_of(entity_name) .. "), found in the wild on " .. base_planet_name(graph, base) .. " in place of " .. base.entity)
    end
    for item_name, entity_name in pairs(item_to_entity) do
        if is_friendly_placer[item_name] then
            table.insert(farm_report, "friendly: " .. item_name .. " places a friendly " .. entity_name)
        end
    end
    for entity_name, base_key in pairs(triggered) do
        table.insert(farm_report, "trigger: " .. entity_name .. " (" .. demand_tier_of(entity_name) .. "), made by " .. trigger_action(graph, graph.nodes[base_key]))
    end

    -- A carrier: a copy of a unit (one a spawner spawned, or an egg hatched) that looks like a built entity and drops a new item placing it when killed (loot)
    -- It keeps the unit's size, stats and behavior, and the item looks like the entity's own item did, whose placing went elsewhere; from says where it comes from, for the farm report
    local function add_carrier(entity_name, unit_name, from)
        local entity_prot = dutils.get_prot("entity", entity_name)
        local old_item_name = entity_to_old_items[entity_name][1]
        local carrier = table.deepcopy(starting_entity(unit_name))
        carrier.name = "propertyrandomizer-carrier-" .. entity_name
        local looted = table.deepcopy(starting_item(old_item_name))
        looted.name = "propertyrandomizer-looted-" .. entity_name
        common.set_placed_entity(looted, entity_prot)
        looted.localised_name = looted.localised_name or locale.find_localised_name(entity_prot)
        looted.localised_description = {"", "Dropped by [entity=" .. carrier.name .. "] ", locale.find_localised_name(entity_prot), " carriers."}
        -- It looks like the entity shrunk to the unit's size
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
        local tier = demand_tier_of(entity_name)
        local amount = acquisition.loot_amount(carrier.max_health or 1, item_cost(old_item_name), tier, looted.stack_size)
        carrier.loot = {
            {
                type = "item",
                name = looted.name,
                amount = amount,
            },
        }
        table.insert(farm_report, "carrier: " .. entity_name .. " (" .. tier .. "), " .. amount .. " per kill of " .. carrier.name .. " " .. from .. ", in place of " .. unit_name)
        data:extend({
            looted,
            carrier,
        })
        -- Picking a placed one back up gives the looted item where it gave the entity's own item, and everything else mining gave stays (like a plant's fruit), since logic still counts on it
        common.swap_mining_items(entity_prot, entity_to_old_items[entity_name], looted.name, false)
        common.replace_placeable_by_item(entity_prot, old_item_name, looted.name)
        log("Entity randomization: " .. carrier.name .. " " .. from .. " in place of " .. unit_name .. " drops " .. looted.name)
        return carrier
    end
    for entity_name, base_key in pairs(carried) do
        local base = graph.nodes[base_key]
        local carrier = add_carrier(entity_name, base.entity, "from " .. base.spawner)
        spawn_occupants[base.spawner] = spawn_occupants[base.spawner] or {}
        spawn_occupants[base.spawner][base.entity] = carrier.name
    end
    -- An egg hatches its carrier in place of what it hatched (made_occupants rewrites what it spoils into)
    local is_carrier = {}
    for entity_name, base_key in pairs(hatched) do
        local base = graph.nodes[base_key]
        local carrier = add_carrier(entity_name, head_entity_name(graph, graph.nodes[base.old_head]), "hatching from " .. gutils.get_owner(graph, base).name)
        made_occupants[base_key] = carrier.name
        is_carrier[carrier.name] = true
    end

    -- A dying enemy leaves a wreck of a built entity in place of what it left behind (made_occupants rewrites what it leaves), which is mined for a salvage item
    local is_wreck = {}
    for entity_name, base_key in pairs(wrecked) do
        local base = graph.nodes[base_key]
        local dying_name = gutils.get_owner(graph, base).name
        local entity_prot = dutils.get_prot("entity", entity_name)
        local wreck_name = "propertyrandomizer-wreck-" .. entity_name
        local salvage = add_salvage_item(entity_name, {"", "Mined from [entity=" .. wreck_name .. "] wrecks, which [entity=" .. dying_name .. "] ", locale.find_localised_name(dutils.get_prot("entity", dying_name)), " leaves behind when it dies."})
        local wreck = common.wreck_of(entity_prot, wreck_name, salvage.name, starting_item(entity_to_old_items[entity_name][1]))
        wreck.localised_name = {"", locale.find_localised_name(entity_prot), " (Wreck)"}
        wreck.localised_description = {"", "Mine it for [item=" .. salvage.name .. "] ", locale.find_localised_name(salvage), "."}
        data:extend({
            wreck,
        })
        made_occupants[base_key] = wreck.name
        is_wreck[wreck.name] = true
        table.insert(farm_report, "wreck: " .. entity_name .. " (" .. demand_tier_of(entity_name) .. "), left by killing " .. dying_name .. ", in place of " .. head_entity_name(graph, graph.nodes[base.old_head]))
        log("Entity randomization: killing " .. dying_name .. " leaves " .. wreck.name .. ", mined for " .. salvage.name)
    end

    -- Slots where a trigger makes the entity make whatever took them now, and one nothing took keeps making what it did
    -- Each holder of a trigger (a capsule, ammo, spoiling item or dying entity) is rewritten once for all its slots, so entities trading places within one holder aren't rewritten twice
    -- Two slots making the same entity can trade places too (like two spawners capturing into it), which changes nothing
    local holder_retargets = {}
    local retargeted_holders = {}
    -- Capsule thrown for an effect that an entity took --> what it makes now, and those capsules in the order found
    local maker_occupants = {}
    local maker_names = {}
    for base_key, occupant in pairs(made_occupants) do
        local base = graph.nodes[base_key]
        local owner_name = gutils.get_owner(graph, base).name
        local made_before = head_entity_name(graph, graph.nodes[base.old_head])
        if occupant ~= made_before then
            local occupant_prot = dutils.get_prot("entity", occupant)
            local occupant_line = {"", "[entity=" .. occupant .. "] ", locale.find_localised_name(occupant_prot), "."}
            if base.trigger_spoof ~= nil then
                -- A capsule thrown for an effect makes this where it's thrown instead (below)
                maker_occupants[owner_name] = {
                    base_key = base_key,
                    occupant = occupant,
                    line = occupant_line,
                    as_building = triggered[occupant] == base_key or entity_to_old_items[occupant] ~= nil,
                }
                table.insert(maker_names, owner_name)
            elseif base.acq_kind == "capture" then
                local spawner = dutils.get_prot("entity", owner_name)
                spawner.captured_spawner_entity = occupant
                spawner.localised_description = with_description_line(spawner, "entity-description", {"", "Capturing it makes ", occupant_line})
            else
                local holder_key = base.acq_kind .. ":" .. owner_name
                if holder_retargets[holder_key] == nil then
                    holder_retargets[holder_key] = {
                        kind = base.acq_kind,
                        owner_name = owner_name,
                        retargets = {},
                        lines = {},
                        badge = nil,
                    }
                    table.insert(retargeted_holders, holder_key)
                end
                local retarget = holder_retargets[holder_key]
                -- A building (anything an item placed in vanilla, like the captive spawner, and wrecks) is made once, where there's room for it, and never as an enemy (common.create_as_building)
                -- Anything else (like combat robots, which come in swarms) is made as often as what it replaces, where there's room
                local as_building = triggered[occupant] == base_key or entity_to_old_items[occupant] ~= nil or is_wreck[occupant] ~= nil
                local as_carrier = is_carrier[occupant] ~= nil
                retarget.retargets[made_before] = function(effect)
                    if as_building then
                        common.create_as_building(effect, occupant)
                    else
                        common.create_at_free_spot(effect, occupant)
                        -- A carrier is an enemy, and hatches even with enemies turned off (no_enemies_mode), since logic counts on its loot
                        if as_carrier then
                            effect.as_enemy = true
                            effect.ignore_no_enemies_mode = true
                        end
                    end
                end
                table.insert(retarget.lines, occupant_line)
                -- An item used by clicking (a capsule or ammo) gets a badge of what it makes, which looks like its own item if it's a building
                if is_trigger_kind(base.acq_kind) then
                    local look = occupant_prot
                    if entity_to_old_items[occupant] ~= nil then
                        look = starting_item(entity_to_old_items[occupant][1])
                    end
                    retarget.badge = retarget.badge or common.icon_layers(look, "")
                end
            end
            if base.trigger_spoof == nil then
                log("Entity randomization: " .. trigger_action(graph, base) .. " makes " .. occupant .. " in place of " .. made_before)
            end
        end
    end
    -- How a holder's description says what it makes now
    local function makes_lead(kind)
        if kind == "spoil" then
            return "Spoils into "
        end
        if kind == "dying" then
            return "Leaves behind when it dies: "
        end
        return "Makes "
    end
    for _, holder_key in pairs(retargeted_holders) do
        local retarget = holder_retargets[holder_key]
        local holder, property = trigger_holder(retarget.kind, retarget.owner_name)
        local trigger = table.deepcopy(holder[property])
        local num_rewritten, copies = common.retarget_created_entities(trigger, retarget.retargets, function(name)
            return "propertyrandomizer-" .. retarget.kind .. "-" .. retarget.owner_name .. "-" .. name
        end)
        if num_rewritten == 0 then
            error("Randomization assertion failed! Entity randomization found nothing to retarget in " .. holder_key)
        end
        holder[property] = trigger
        -- Triggers holding their effects directly (like a spoil or dying trigger) send nothing that needs copying, and data:extend refuses an empty list
        if #copies > 0 then
            data:extend(copies)
        end
        local lines = {""}
        for ind, line in pairs(retarget.lines) do
            if ind > 1 then
                table.insert(lines, "\n")
            end
            table.insert(lines, {"", makes_lead(retarget.kind), line})
        end
        local description_key = "item-description"
        if retarget.kind == "dying" then
            description_key = "entity-description"
        end
        holder.localised_description = with_description_line(holder, description_key, lines)
        -- It keeps its own look, with what it makes now as a badge, like a spoof placer
        if retarget.badge ~= nil then
            for _, prefix in pairs(common.item_icon_prefixes) do
                local layers = common.icon_layers(holder, prefix)
                if layers ~= nil then
                    common.set_icon_layers(holder, prefix, common.with_icon_badge(layers, retarget.badge))
                end
            end
        end
    end

    -- The look of what a capsule makes, for its badge: a building's own item, or the entity itself
    local function look_of(entity_name)
        if entity_to_old_items[entity_name] ~= nil then
            return starting_item(entity_to_old_items[entity_name][1])
        end
        return dutils.get_prot("entity", entity_name)
    end
    -- Puts a line in front of an item's description, and a badge on its icons (it keeps its own look, like a spoof placer)
    local function mark_item(item, line, badge_look)
        item.localised_description = with_description_line(item, "item-description", line)
        local badge = common.icon_layers(badge_look, "")
        if badge ~= nil then
            for _, prefix in pairs(common.item_icon_prefixes) do
                local layers = common.icon_layers(item, prefix)
                if layers ~= nil then
                    common.set_icon_layers(item, prefix, common.with_icon_badge(layers, badge))
                end
            end
        end
    end

    -- A capsule thrown for an effect that an entity took makes the entity where it's thrown, instead of its effect (which moves on, below)
    for _, capsule_name in pairs(maker_names) do
        local maker = maker_occupants[capsule_name]
        local capsule = dutils.get_prot("item", capsule_name)
        local effect = {
            type = "create-entity",
            entity_name = maker.occupant,
            show_in_tooltip = true,
        }
        if maker.as_building then
            common.create_as_building(effect, maker.occupant)
        else
            common.create_at_free_spot(effect, maker.occupant)
        end
        capsule.capsule_action = table.deepcopy(capsule.capsule_action)
        capsule.capsule_action.attack_parameters.ammo_type.action = {
            type = "direct",
            action_delivery = {
                type = "instant",
                target_effects = {
                    effect,
                },
            },
        }
        mark_item(capsule, {"", "Makes ", maker.line}, look_of(maker.occupant))
        log("Entity randomization: using " .. capsule_name .. " makes " .. maker.occupant .. " in place of its effect")
    end

    -- Where each displaced effect goes: the start of the chain of slots ending at its capsule, the base nobody took
    -- A chain of build slots starts at a Vestige, which sets the effect off where it's placed; a chain of trigger slots can start at a capsule, which throws the effect instead of what it made
    -- Anything else (like a spawner capture) can't hold an effect, so a Vestige that got none takes it, and without one it's lost
    local effect_rng_key = rng.key({id = "unified-entity-effects"})
    local head_of_base = {}
    local num_entity_heads = 0
    for head_key, handler in pairs(head_to_handler) do
        if handler.id == entity.id and head_to_base[head_key] ~= nil and graph.nodes[head_key].mine_back == nil then
            head_of_base[head_to_base[head_key]] = head_key
            num_entity_heads = num_entity_heads + 1
        end
    end
    local function chain_start(base_key)
        local num_steps = 0
        while head_of_base[base_key] ~= nil do
            base_key = graph.nodes[head_of_base[base_key]].old_base
            num_steps = num_steps + 1
            if num_steps > num_entity_heads then
                error("Randomization assertion failed! The chain of slots ending at " .. base_key .. " doesn't start anywhere")
            end
        end
        return base_key
    end
    -- Capsule --> the capsule whose (vanilla) effect it has now, and Vestige --> the capsule whose effect it sets off
    local capsule_effect = {}
    local vestige_effect = {}
    local displaced = {}
    for _, capsule_name in pairs(maker_names) do
        local start = graph.nodes[chain_start(maker_occupants[capsule_name].base_key)]
        local start_name = gutils.get_owner(graph, start).name
        if start.acq_kind == "build" and vestige_place_changes[start_name] ~= nil and vestige_effect[start_name] == nil then
            vestige_effect[start_name] = capsule_name
        elseif start.acq_kind == "capsule" and effect_capsule(dutils.get_prot("item", start_name)) == false and holder_retargets["capsule:" .. start_name] == nil and maker_occupants[start_name] == nil and capsule_effect[start_name] == nil then
            capsule_effect[start_name] = capsule_name
        else
            table.insert(displaced, capsule_name)
        end
    end
    local plain_vestiges = {}
    for vestige_name, _ in pairs(vestige_place_changes) do
        if vestige_effect[vestige_name] == nil then
            table.insert(plain_vestiges, vestige_name)
        end
    end
    table.sort(plain_vestiges)
    rng.shuffle(effect_rng_key, plain_vestiges)
    for _, capsule_name in pairs(displaced) do
        if #plain_vestiges > 0 then
            vestige_effect[table.remove(plain_vestiges)] = capsule_name
        else
            log("Entity randomization: the effect of " .. capsule_name .. " is lost, since no Vestige or capsule is left to take it")
        end
    end

    -- Capsules thrown for an effect that nothing else changed trade effects among each other, some of them (a rotation, so every effect stays somewhere)
    local swapped = {}
    local effect_capsule_names = {}
    for _, item in pairs(dutils.get_all_prots("item")) do
        if effect_capsule(item) and maker_occupants[item.name] == nil and capsule_effect[item.name] == nil and holder_retargets["capsule:" .. item.name] == nil then
            table.insert(effect_capsule_names, item.name)
        end
    end
    table.sort(effect_capsule_names)
    for _, capsule_name in pairs(effect_capsule_names) do
        if rng.value(effect_rng_key) < EFFECT_SWAP_CHANCE then
            table.insert(swapped, capsule_name)
        end
    end
    if #swapped >= 2 then
        rng.shuffle(effect_rng_key, swapped)
        for ind, capsule_name in pairs(swapped) do
            capsule_effect[capsule_name] = swapped[ind % #swapped + 1]
        end
    end

    -- A capsule with another's effect throws just like that one did, keeping its own look with that one's as a badge
    for capsule_name, from_name in pairs(capsule_effect) do
        local capsule = dutils.get_prot("item", capsule_name)
        local from = starting_item(from_name)
        capsule.capsule_action = table.deepcopy(from.capsule_action)
        mark_item(capsule, {"", "Does what [item=" .. from_name .. "] ", locale.find_localised_name(from), " did."}, from)
        log("Entity randomization: using " .. capsule_name .. " does what " .. from_name .. " did")
    end

    -- A Vestige with a capsule's effect places an invisible explosion that sets the effect off where it's placed, then goes away by itself
    -- It can't be a ghost (so no blueprints or robots), which is fine for an item that places nothing lasting
    for vestige_name, from_name in pairs(vestige_effect) do
        local from = starting_item(from_name)
        local effect_name = "propertyrandomizer-effect-" .. from_name
        if dutils.get_prot("entity", effect_name) == nil then
            local set_off = {
                type = "explosion",
                name = effect_name,
                localised_name = {"", locale.find_localised_name(from), " (Set off)"},
                flags = {
                    "placeable-player",
                    "not-on-map",
                },
                animations = util.empty_animation(1),
                collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
                selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
                created_effect = table.deepcopy(from.capsule_action.attack_parameters.ammo_type.action),
            }
            common.set_icon_layers(set_off, "", common.icon_layers(from, ""))
            data:extend({
                set_off,
            })
        end
        vestige_place_changes[vestige_name].new_val = effect_name
        local was = vestige_was[vestige_name]
        dutils.get_prot("item", vestige_name).localised_description = {"", "No longer places [entity=" .. was.entity .. "] ", was.entity_name, was.now_from, "\nPlacing it does what [item=" .. from_name .. "] ", locale.find_localised_name(from), " did where it was thrown."}
        log("Entity randomization: placing " .. vestige_name .. " does what " .. from_name .. " did")
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
            if salvaged[entity_name] ~= nil or carried[entity_name] ~= nil or hatched[entity_name] ~= nil or triggered[entity_name] ~= nil or wrecked[entity_name] ~= nil then
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

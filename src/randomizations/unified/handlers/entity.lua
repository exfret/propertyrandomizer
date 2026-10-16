-- Entity randomization: changes how entities are acquired (the acquisition kinds in src/logic/builders/acquisition.lua)
-- So far build slots (which item places which entity), autoplace slots (which entity map generation puts where), spawn slots (what spawners spawn), and trigger slots (what using a capsule, firing ammo or capturing a spawner makes for us)
-- An item's ability to place something, or a room's autoplace spot, is a base, and an entity's need for one is a head
-- Autoplaced entities can trade autoplace slots or stop being autoplaced, and built entities can be found in the wild instead and salvaged (mined for an item that places them)
-- Entities made by trigger slots (like combat robots, the capture robot and the captive spawner) trade those slots or stop being made, and built entities can be made by one instead and then mined for an item that places them
-- Spoil slots can hatch building carriers. Death slots accept natural entities, bounded creatures or in-place payloads; asteroid deaths can yield collectible building salvage.
-- Projectile packages keep their payloads while moving between firing slots or become directly placed impacts; building outputs lose only construction automation
-- Each item places only one entity (planting counts, see common.set_placed_entity), so bases are matched to heads one to one, with promotion keeping mechanic contexts and recipe reachability
-- With constants.entity_first_pass on, first pass does the matching instead: every claimed acquisition edge is a first pass position like an item's (see first_pass_rules), and this handler only reflects the result
-- With first pass (and item randomization), a build base belongs to the item's identity, so an item keeps placing its (new) entity wherever item randomization moves it
-- Reflects before item randomization (see execute.lua), which copies items' names and icons into recipes
-- Spoofs let items that place nothing in vanilla (like modules) also place an entity, on top of everything they already do; that entity's own item then places nothing (a Vestige)

local categories = require("src/prototypes/categories")
local constants = require("src/config/constants")
local graph_customization = require("src/config/graph-customization")
local build_supply = require("src/logic/analysis/entity-build-item")
local acquisition = require("src/logic/builders/acquisition")
local dutils = require("src/prototypes/data-utils")
local deposit_copies = require("src/prototypes/duplicates/deposit-copies")
local gutils = require("src/lib/graph/graph-utils")
local locale = require("src/localisation/locale")
local localised_text = require("src/localisation/localised-text")
local rng = require("src/lib/random/rng")
local wild = require("src/prototypes/entities/wild-entities")
local context_costs = require("src/cost/context-costs")
local common = require("src/randomizations/unified/handler-helpers/entity")
local packages = require("src/randomizations/unified/handler-helpers/projectile-packages")
local death_slots = require("src/prototypes/entities/death-slots")
local lutils = require("src/logic/logic-utils")
local military = require("src/randomizations/unified/military")
local military_rebalance = require("src/randomizations/unified/handler-helpers/military")

local augmenting_search = require("src/lib/graph/augmenting-search")

local key = gutils.key

local entity = {}
local projectile_packages = {}
local fixed_effects = {}
local death_budgets = {}

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
-- Chance that an entity built from an item may instead be deployed by a trigger, with construction automation protected by progression
local TRIGGER_CHANCE = 0.25
-- A building a captured spawner turns into is at most this many times the spawner's size, since it takes the spawner's place (see common.fits_autoplace_of)
local CAPTURE_AREA_TOLERANCE = 1
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
-- So are deposit copies (src/prototypes/duplicates/deposit-copies.lua), which are renamed back to their materials after each attempt, so what they placed would be lost
local function spoofable_item(item)
    return claimable_item(item) and not common.places_something(item) and not deposit_copies.is_copy(item)
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
-- Autoplaced entities whose autoplace stays put (wild.kept_in_place, found in spoof): resources, cliffs, planted entities, and ones a research trigger has you mine
local kept_in_place

-- Autoplaced entities whose slot can go to another entity, and that can take another's: movable wild entities (src/prototypes/entities/wild-entities.lua)
-- An entity has one autoplace, so only ones found in the wild in exactly one room can move (their spec goes where they go); planet copies have clones of their original's (src/prototypes/duplicates/dupe-planets.lua), so those are too
local function claimable_autoplace(prototype)
    if not wild.movable(prototype, kept_in_place) or excluded_entity_types[prototype.type] ~= nil then
        return false
    end
    return autoplace_room_counts[prototype.name] == 1
end

-- Trigger slots: using an item (a capsule, or firing ammo) or capturing a spawner, which makes the entity ours (its edge is tagged ours, see src/logic/builders/acquisition.lua)
local function is_trigger_kind(kind)
    return kind == "capsule" or kind == "ammo" or kind == "capture"
end

-- Slots where a trigger makes the entity: trigger slots, an item spoiling (like an egg hatching), or an entity dying
local function is_made_kind(kind)
    return is_trigger_kind(kind) or kind == "spoil" or kind == "dying"
end

-- The prototype and property holding the trigger that makes a slot's entity, from the name of what owns its base (see is_made_kind)
-- These are what src/prototypes/lookup/2-simple/entity-create.lua reads: a capsule's action, what ammo does when fired, what an item does when it spoils, or what an entity does when it dies
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
    if item ~= nil and not graph_customization.selected("entity", {
        type = "item",
        name = item.name,
    }) then
        return false
    end
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
    from_space = {}
    identity_of_position = {}
    projectile_packages = {}
    fixed_effects = {}
    death_budgets = {}
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
                stop = build_supply.key(graph, placed_name),
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
                -- With first pass entity positions, mining whatever first pass puts in this item's build position gives this item, so first pass connects this head to that identity's mine base (coupled_slot, see first-pass.lua)
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

    kept_in_place = wild.kept_in_place()

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

    projectile_packages = packages.prepare(graph, keep_from_first_pass)
    -- Unsupported payload shapes with modeled damage must not fall through to unmodeled effect swapping.
    for _, edge in pairs(graph.edges) do
        local source = graph.nodes[edge.start]
        if source.type == "item-capsule" and graph.nodes[edge.stop].type == "damage-type" then fixed_effects[source.name] = true end
    end

    -- Every capsule thrown for an effect gets an edge to a spoofed entity-own node, so its use becomes a trigger base an entity can take (made where it's thrown, instead of the effect)
    -- Only capsules with a plain throw action, since others (like cliff explosives) work on something at the spot; the sink is a spoof, so its own heads are never matched
    local maker = gutils.add_node(graph, "entity-own", SPOOF_MAKER_NAME, {
        op = "OR",
        spoof = true,
    })
    for _, item in pairs(dutils.get_all_prots("item")) do
        if fixed_effects[item.name] == nil and projectile_packages["item-" .. item.name] == nil and effect_capsule(item) and item.capsule_action.type == "throw" and graph.nodes[key("item-capsule", item.name)] ~= nil then
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

    -- Empty death positions join the same matching pool. No runtime dummy entity is needed.
    local death_sink = gutils.add_node(graph, "entity", "propertyrandomizer-empty-death", {op = "OR", spoof = true})
    local death_names = {}
    for _, prototype in pairs(dutils.get_all_prots("entity")) do
        if graph.nodes[key("entity-kill", prototype.name)] ~= nil and death_slots.host(prototype, lookups, kept_in_place) then
            table.insert(death_names, prototype.name)
        end
    end
    table.sort(death_names)
    -- Passive hosts use the weakest positive early-game attack available locally, not their own zero damage.
    local room_budgets = {}
    local function current_prototype(name) return dutils.get_prot("entity", name) end
    for room_name, room in pairs(lookups.rooms) do
        local budget
        local function consider(prototype)
            local damage = death_slots.attack_damage(prototype, current_prototype)
            if damage ~= nil and damage > 0 and (budget == nil or damage < budget.damage) then
                budget = {damage = damage, health = prototype.max_health or 1}
            end
        end
        for _, spawner in pairs(dutils.get_all_prots("entity")) do
            if spawner.result_units ~= nil and lutils.check_in_room(room, spawner) then
                for _, definition in pairs(spawner.result_units) do
                    local name, points = acquisition.read_spawn_definition(definition)
                    if acquisition.spawn_weight_at(points, 0) > 0 then consider(current_prototype(name)) end
                end
            elseif spawner.autoplace ~= nil and spawner.autoplace.force == "enemy" and lutils.check_in_room(room, spawner) then
                consider(spawner)
            end
        end
        room_budgets[room_name] = budget
    end
    for _, name in pairs(death_names) do
        local prototype = current_prototype(name)
        if prototype.attack_parameters == nil then
            for room_name, room in pairs(lookups.rooms) do
                local budget = room_budgets[room_name]
                if budget ~= nil and lutils.check_in_room(room, prototype) and (death_budgets[name] == nil or budget.damage < death_budgets[name].damage) then
                    death_budgets[name] = budget
                end
            end
        end
    end
    local death_rng = rng.key({id = "unified-entity-death-slots"})
    for _, name in pairs(death_names) do
        if rng.value(death_rng) < 0.25 then
            local edge = gutils.add_edge(graph, key("entity-kill", name), key(death_sink), acquisition.tag("dying", {
                death_spoof = true, death_host = name, amount = 1,
            }))
            keep_from_first_pass(gutils.ekey(edge))
            if from_space[name] and death_slots.salvage_template(data.raw["asteroid-chunk"]) ~= nil then
                local available = death_slots.salvage_source(graph, name, constants.cost.asteroid_chunk_collection_time)
                local salvage = gutils.add_edge(graph, key(available), key(death_sink), acquisition.tag("dying", {
                    death_spoof = true, death_host = name, salvage_source = edge.start, amount = 1,
                }))
                keep_from_first_pass(gutils.ekey(salvage))
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
            if build_supply.is_node(node) and lookups.unit_spawns_reverse[node.name] ~= nil and next(node.pre) == nil then
                local edge = gutils.add_edge(graph, source_keys[1], node_key, acquisition.tag("build", {
                    friendly = true,
                    starts_detached = true,
                    amount = 1,
                }))
                keep_from_first_pass(gutils.ekey(edge))
            end
        end

        -- A built entity carried by biters (a carrier, see reflect) is gotten by killing a unit from its slot, which takes a weapon that kills the unit (the carrier keeps its resistances)
        -- So each spawn and spoil slot also gets a carrier base: a spoofed edge from an AND of the slot's source and the unit's combat-target (src/logic/builders/combat-encounters.lua), which a build head takes in place of the slot's own base (see custom_prereq_search)
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
            if is_slot and graph.nodes[key("combat-target", stop.name)] ~= nil then
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
            gutils.add_edge(graph, key("combat-target", unit_name), key(kill_node))
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
        if not build_supply.is_node(dep) or prereq.type ~= "item" then
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
    if edge.death_spoof ~= nil or edge.trigger_spoof ~= nil or edge.projectile_package ~= nil then
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
entity.validate = function(graph, base, head, extra, owner_of)
    -- A mine-back base only goes to a mine-back head (see spoof)
    if base.mine_back ~= nil or head.mine_back ~= nil then
        return base.mine_back ~= nil and head.mine_back ~= nil
    end
    -- A unit's placing slot's own base is only there so its edge could be claimed
    local pairing = acquisition.pairing(base, head)
    if base.friendly ~= nil or pairing == nil then
        return false
    end
    local source_package = projectile_packages[base.projectile_package]
    local traveler_package = projectile_packages[head.projectile_package]
    if (source_package and source_package.locked) or (traveler_package and traveler_package.locked) then
        return key(base) == head.old_base
    end
    if traveler_package ~= nil then
        if base.death_spoof and base.salvage_source == nil then
            return traveler_package.impact ~= nil and not traveler_package.is_entity
        end
        if source_package ~= nil then return true end
        return base.acq_kind == "build" and traveler_package.impact ~= nil and not traveler_package.is_entity
    end
    if source_package ~= nil then
        return head.acq_kind == "build" and source_package.building and not source_package.is_entity
    end
    -- A building's separate trigger identity must not bypass acquisition's loss of construction automation.
    if (base.acq_kind == "capsule" or base.acq_kind == "ammo") and key(base) ~= head.old_base and head.acq_kind ~= "build" then
        local prototype = dutils.get_prot("entity", head_entity_name(graph, head))
        if prototype ~= nil and lookups.buildables[key(prototype)] ~= nil then return false end
    end
    if head.acq_kind == "build" and (base.acq_kind == "capsule" or base.acq_kind == "ammo") then
        local owner = owner_of and owner_of(base) or gutils.get_owner(graph, base)
        local made = base.trigger_spoof == nil and head_entity_name(graph, graph.nodes[base.old_head]) or nil
        if not packages.single_creation(dutils.get_prot("item", owner.name), made) then return false end
    end
    -- A pairing that takes killing a carrier (a built entity carried by a slot's unit) needs a base that includes the kill, the slot's carrier base (see spoof), and only such pairings take a carrier base
    if (pairing.needs_kill ~= nil) ~= (base.carrier_spoof ~= nil) then
        return false
    end
    if base.carrier_spoof ~= nil then
        return head.friendly == nil
    end
    local owner_type = (owner_of and owner_of(base) or gutils.get_owner(graph, base)).type
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
        if head.acq_kind == "build" then return base.salvage_source ~= nil end
        return base.salvage_source == nil and owner_type == "entity-kill"
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

-- Cost of the item before randomization, from the logic graph's prices with every surface as one place (graph_cost.material_costs_anywhere), or nil if nothing makes it
-- Items this mod makes, like planet copies, get theirs the same way as vanilla ones
local function item_cost(item_name)
    assert(context_costs.current ~= nil, "Entity randomization prices items with the costs derived for this game (graph_cost.derive_cost_options), which aren't there yet")
    local cost = context_costs.current.anywhere_costs["item-" .. item_name]
    if cost ~= nil and cost > 0 then
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

-- Cost of what mining an entity gave (item_cost), or nil if nothing it gives has a known cost
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

-- Search each head's shuffled prerequisite pool in dependency order, like the generic handlers.
-- The coin chooses a same-category or general search for each head. Occupied candidates
-- start augmenting paths, whose displaced heads search their own pools recursively.
local function prerequisite_search(params)
    local graph = params.random_graph
    -- Promotion rewires its private graph; owners in this source graph stay fixed.
    local owners = {}
    local function owner_of(base)
        if owners[base] == nil then owners[base] = gutils.get_owner(graph, base) end
        return owners[base]
    end
    local function base_item_name(_, base)
        return owner_of(base).name
    end
    local prom = params.promotion
    if prom == nil then
        error("Entity randomization needs promotion (USE_PROMOTION in src/randomizations/unified/execute.lua)")
    end
    -- With first pass, promotion reasons over its split graph; this handler's slots aren't split (see spoof), and their heads and bases keep the same keys there

    -- First pass matches entity identities to build positions (see spoof and first-pass.lua), so a build slot's head is a position whose built entity is the identity first pass put there
    -- Everything about what's built (its cost, demand tier, look, mining) is then the identity's, and build slots don't trade items among each other here, since first pass did that
    identity_of_position = {}
    local first_pass_entities = false
    if params.slot_to_trav ~= nil and params.split_graph ~= nil then
        for slot_key, trav_key in pairs(params.slot_to_trav) do
            local slot_node = params.split_graph.nodes[slot_key]
            if build_supply.is_node(slot_node) then
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

    -- A built entity carried by biters takes a spawn or spoil slot like a unit would (so the slot's unit moves elsewhere or stops), but connects to the slot's carrier base, which also needs killing the unit (see spoof)
    local carrier_base_of, slot_base_of = carrier_bases(graph)
    local salvage_base_of, death_base_of = {}, {}
    for node_key, node in pairs(graph.nodes) do
        if node.type == "base" and node.death_spoof and not node.salvage_source then
            death_base_of[node.death_host] = node_key
        end
    end
    for node_key, node in pairs(graph.nodes) do
        if node.type == "base" and node.salvage_source then
            local physical = death_base_of[node.death_host]
            assert(physical ~= nil, "Salvage requires a physical death slot")
            salvage_base_of[physical] = node_key
            slot_base_of[node_key] = physical
        end
    end
    -- The base a slot's head connects to when it takes base_key, or nil if it can't (a spawn or spoil slot without a carrier base)
    local function connection_base(slot, base_key)
        local base = graph.nodes[base_key]
        if base ~= nil and slot.kind == "build" and base.death_spoof then return salvage_base_of[base_key] end
        if base ~= nil and slot.kind == "build" and base.carrier_spoof == nil and (base.acq_kind == "spawn" or base.acq_kind == "spoil") then
            return carrier_base_of[base_key]
        end
        return base_key
    end
    -- The own item of the entity a build slot builds (its identity's item in vanilla), its cost, and how many of it a base needs (acquisition.demand_tier)
    local own_item_name_of = {}
    for _, slot in pairs(slots) do
        if slot.kind == "build" and not slot.friendly then
            own_item_name_of[slot.entity_name] = base_item_name(graph, graph.nodes[slot.own_base_key])
        end
    end
    local function own_item_of(slot)
        if slot.own_item == nil then slot.own_item = starting_item(own_item_name_of[slot.identity]) end
        return slot.own_item
    end
    local entity_prototypes, original_entities = {}, {}
    local function entity_prototype(name)
        if entity_prototypes[name] == nil then entity_prototypes[name] = dutils.get_prot("entity", name) end
        return entity_prototypes[name]
    end
    local function original_entity(name)
        if original_entities[name] == nil then original_entities[name] = starting_entity(name) end
        return original_entities[name]
    end
    local function tier_of(slot)
        return acquisition.demand_tier(entity_prototype(slot.identity).type, own_item_of(slot).stack_size)
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
        return movable_building(slot, "autoplace") and entity_prototype(slot.identity).minable ~= nil and original_entity(slot.identity).autoplace == nil
    end
    -- Trigger-created buildings must remain mineable so their placement can be undone.
    local function triggerable(slot, slot_kind)
        return movable_building(slot, slot_kind) and entity_prototype(slot.identity).minable ~= nil
    end

    -- Physical compatibility and costs stay fixed for this entire search. Only
    -- progression requirements/backings change when an assignment is committed.
    local autoplace_layers
    local function fits_autoplace_of(prototype, other, tolerance)
        if autoplace_layers == nil then autoplace_layers = common.tile_layers() end
        return common.fits_autoplace_of(prototype, other, tolerance, autoplace_layers)
    end
    local function physically_admissible(slot, base_key)
        local base = graph.nodes[base_key]
        local connect_key = connection_base(slot, base_key)
        if connect_key == nil or not entity.validate(graph, graph.nodes[connect_key], slot.head, nil, owner_of) then
            return false
        end
        local package = projectile_packages[slot.head.projectile_package]
        if package ~= nil then
            if base.death_spoof then
                return death_slots.payload_fits(original_entity(base.death_host), package.impact, original_entity, death_budgets[base.death_host]) and connect_key or false
            end
            local destination = projectile_packages[base.projectile_package]
            if destination ~= nil and destination.id ~= package.id then
                local cost, own_cost = item_cost(destination.owner), item_cost(package.owner)
                if cost == nil or own_cost == nil or not costs_within(cost, own_cost) then return false end
            end
            if base.acq_kind == "build" then
                local cost = item_cost(base_item_name(graph, base))
                local own_cost = item_cost(package.owner)
                if cost == nil or own_cost == nil or not costs_within(cost, own_cost) then return false end
            end
            return connect_key
        end
        if base.acq_kind == "build" and not slot.friendly and not costs_close_to_own(slot, base_item_name(graph, base)) then
            return false
        end
        if base.acq_kind == "autoplace" and not fits_autoplace_of(entity_prototype(slot.identity), entity_prototype(base.entity), AUTOPLACE_AREA_TOLERANCE) then
            return false
        end
        -- A carrier is its slot's unit (spawned, or hatched from an egg) with the entity's look as its run_animation, so the unit needs one, and has to be worth killing for the entity's item (acquisition.worth_carrying)
        if (base.acq_kind == "spawn" or base.acq_kind == "spoil") and slot.kind == "build" then
            local unit = original_entity(head_entity_name(graph, graph.nodes[base.old_head]))
            if unit.run_animation == nil or not acquisition.worth_carrying(unit.max_health or 1, item_cost(own_item_of(slot).name)) then
                return false
            end
        end
        -- Death outputs must fit the host's terrain and combat strength; buildings use collectible asteroid salvage.
        if base.acq_kind == "dying" and base_key ~= slot.own_base_key then
            local host_name = base.death_host or owner_of(base).name
            local host = original_entity(host_name)
            if slot.kind == "build" then
                if not base.death_spoof or not from_space[host_name] then return false end
                local item = own_item_of(slot)
                local weight = lookups.weight[item.name]
                if weight == nil or weight > data.raw["utility-constants"].default.default_rocket_lift_weight or not dutils.survives_trip(item) then return false end
            else
                if from_space[host_name] then return false end
                if slot.identity == host.name or not fits_autoplace_of(entity_prototype(slot.identity), host, 4) then return false end
                local child = entity_prototype(slot.identity)
                if death_slots.creature(child) then
                    local budget = death_budgets[host_name]
                    local health = budget and budget.health or host.max_health or 1
                    local attack = child.attack_parameters
                    if (child.max_health or 1) > health or not death_slots.payload_fits(host, attack and attack.ammo_type, original_entity, budget, attack and attack.damage_modifier) then return false end
                end
            end
        end
        -- Salvage is never worth more than SALVAGE_COST_FACTOR times what mining the slot's entity gave, and needs both costs known to check that (acquisition.worth_salvaging)
        if base.acq_kind == "autoplace" and slot.kind == "build" and not acquisition.worth_salvaging(item_cost(own_item_of(slot).name), mining_yield_cost(original_entity(base.entity))) then
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
            local spawner = entity_prototype(gutils.get_owner(graph, base).name)
            if not fits_autoplace_of(entity_prototype(slot.identity), spawner, CAPTURE_AREA_TOLERANCE) then
                return false
            end
        end
        return connect_key
    end

    -- Physical compatibility is independent of the category preference. These are the
    -- acquisition conversions reflection supports; no per-conversion random gates.
    local function compatible(slot, base_key)
        local base = graph.nodes[base_key]
        if slot.friendly then return base.acq_kind == "build" end
        if slot.head.projectile_package ~= nil then return true end
        if slot.kind == "build" then
            if base.acq_kind == "build" then
                return not first_pass_entities or base_key == slot.own_base_key or base.build_spoof ~= nil
            elseif base.acq_kind == "autoplace" then
                return salvageable(slot)
            elseif base.acq_kind == "spawn" or base.acq_kind == "spoil" then
                return movable_building(slot, base.acq_kind)
            elseif base.acq_kind == "dying" then
                return not slot.friendly and num_build_heads[slot.entity_name] == 1 and base.death_spoof and salvage_base_of[base_key] ~= nil and entity_prototype(slot.identity).minable ~= nil
            elseif is_trigger_kind(base.acq_kind) then
                return triggerable(slot, base.acq_kind)
            end
            return false
        end
        return base.acq_kind == "dying" or base.acq_kind == slot.kind or (is_trigger_kind(base.acq_kind) and is_trigger_kind(slot.kind))
    end

    local pool, in_pool = {}, {}
    local function add_base(base_key)
        local base = graph.nodes[base_key]
        if base ~= nil and base.mine_back == nil and base.salvage_source == nil and base.carrier_spoof == nil and base.friendly == nil and in_pool[base_key] == nil then
            in_pool[base_key] = true
            table.insert(pool, base_key)
        end
    end
    for _, base_key in pairs(params.shuffled_prereqs) do add_base(base_key) end
    for _, slot in pairs(slots) do
        if not slot.friendly then add_base(slot.own_base_key) end
    end
    rng.shuffle(rng_key, pool)
    local pools_by_kind = {}
    for _, base_key in pairs(pool) do
        local kind = graph.nodes[base_key].acq_kind or false
        pools_by_kind[kind] = pools_by_kind[kind] or {}
        table.insert(pools_by_kind[kind], base_key)
    end
    local counts = {
        moved = 0,
        spoofs = 0,
        salvaged = 0,
        carried = 0,
        hatched = 0,
        triggered = 0,
        asteroid_salvaged = 0,
        friendly = 0,
        detached = 0,
    }
    local checked, refused, same_category = 0, 0, 0

    -- Mining returns for every affected item position move with the augmenting path.
    local function mine_change(item_name, new_base)
        local head_key = mine_head_of_item[item_name]
        if head_key == nil or mine_base_now[head_key] == new_base then return nil end
        local remove = {}
        if mine_base_now[head_key] ~= DETACHED then table.insert(remove, mine_base_now[head_key]) end
        return {
            node_key = head_key,
            remove = remove,
            add = new_base ~= DETACHED and new_base or nil,
            detach = new_base == DETACHED,
        }
    end
    local function keep_mine(change)
        if change ~= nil then mine_base_now[change.node_key] = change.add or DETACHED end
    end
    local candidate_pools, own_pair_allowed, physical_pairs = {}, {}, {}
    for _, slot in pairs(slots) do
        local within_category = rng.value(rng_key) < 0.5
        if within_category then same_category = same_category + 1 end
        local candidates = {}
        local category_pool = within_category and (pools_by_kind[slot.kind or false] or {}) or pool
        for _, base_key in pairs(category_pool) do
            table.insert(candidates, base_key)
        end
        rng.shuffle(rng_key, candidates)
        -- Filter only after shuffling so the random stream and surviving order
        -- stay identical. Static failures can never become useful during an
        -- augmentation; keeping them in every repeated search wastes work.
        local possible = {}
        for _, base_key in pairs(candidates) do
            local allowed = compatible(slot, base_key)
            if base_key == slot.own_base_key then own_pair_allowed[slot] = allowed end
            if base_key == slot.own_base_key or allowed then
                table.insert(possible, base_key)
            end
        end
        candidate_pools[slot] = possible
        physical_pairs[slot] = {}
    end
    -- Context requirements are stable until a path commits. A refused trial can
    -- expose a mine-back obligation that wasn't part of the entity head's needs;
    -- learn that obligation, rather than treating the whole path as a bad edge.
    local contexts_now, mine_needs = {}, {}
    local has_mine_needs = false
    local slot_of_head = {}
    for _, slot in pairs(slots) do slot_of_head[slot.head_key] = slot end
    local function contexts_of(slot)
        if contexts_now[slot] == nil then contexts_now[slot] = slot_contexts(slot) end
        return contexts_now[slot]
    end
    local function mine_head_at(base_key)
        local base = graph.nodes[base_key]
        if base == nil or base.acq_kind ~= "build" then return nil end
        return mine_head_of_item[base_item_name(graph, base)]
    end
    local function mine_pair_ok(slot, base_key)
        local mine_head = mine_head_at(base_key)
        local needs = mine_needs[mine_head]
        if needs == nil then return true end
        local mine_base
        if slot.kind == "build" and not slot.friendly then mine_base = mine_base_of_entity[slot.identity] end
        return mine_base ~= nil and prom.head_candidate_ok(mine_head, mine_base, needs)
    end
    local function add_context(contexts, context)
        for _, existing in pairs(contexts) do
            if existing == context then return 0 end
        end
        table.insert(contexts, context)
        return 1
    end
    local longest_path, refinements = 0, 0
    local matcher = augmenting_search.new({
        heads = slots,
        detached = DETACHED,
        initial = function(slot) return slot.own_base_key end,
        candidates = function(slot) return candidate_pools[slot] end,
        begin = function()
            contexts_now, mine_needs = {}, {}
            has_mine_needs = false
        end,
        allowed = function(slot, base_key)
            if base_key == slot.own_base_key and own_pair_allowed[slot] == false then return false end
            local physical = physical_pairs[slot]
            if physical[base_key] == nil then physical[base_key] = physically_admissible(slot, base_key) end
            if not physical[base_key] then return false end
            local contexts = contexts_of(slot)
            return (#contexts == 0 or prom.head_candidate_ok(slot.head_key, physical[base_key], contexts)) and (not has_mine_needs or mine_pair_ok(slot, base_key))
        end,
        can_end = function(_, freed)
            -- An open path empties the root's old physical position. Once a
            -- promised mining return needs that position, the path must close.
            return mine_needs[mine_head_at(freed)] == nil
        end,
        refine = function(_, failure)
            if failure == nil then return 0 end
            local slot = slot_of_head[failure.node_key]
            if slot ~= nil then return add_context(contexts_of(slot), failure.context) end
            if mine_base_now[failure.node_key] ~= nil then
                has_mine_needs = true
                mine_needs[failure.node_key] = mine_needs[failure.node_key] or {}
                return add_context(mine_needs[failure.node_key], failure.context)
            end
            return 0
        end,
        can_detach = function(slot)
            return slot.friendly or (slot.kind ~= "build" and slot.head.projectile_package == nil and #contexts_of(slot) == 0)
        end,
        commit = function(path)
            local changes, mining = {}, {}
            local affected, new_occupants = {}, {}
            for _, move in pairs(path) do
                local slot = move.head
                local previous = slot_base_of[slot.base_key] or slot.base_key
                if previous ~= DETACHED then affected[previous] = true end
                if move.base ~= DETACHED then
                    affected[move.base] = true
                    new_occupants[move.base] = slot
                end
                table.insert(changes, {
                    node_key = slot.head_key,
                    remove = slot.base_key ~= DETACHED and {slot.base_key} or {},
                    add = move.base ~= DETACHED and connection_base(slot, move.base) or nil,
                    detach = move.base == DETACHED,
                })
            end
            -- Traverse the stable pool order, rather than iterating table-keyed heads.
            for _, physical_base in pairs(pool) do
                if affected[physical_base] ~= nil and graph.nodes[physical_base].acq_kind == "build" then
                    local target = new_occupants[physical_base]
                    local mine_base = target ~= nil and target.kind == "build" and not target.friendly and mine_base_of_entity[target.identity] or DETACHED
                    local change = mine_change(base_item_name(graph, graph.nodes[physical_base]), mine_base or DETACHED)
                    if change ~= nil then
                        table.insert(changes, change)
                        table.insert(mining, change)
                    end
                end
            end
            -- Keep multi-step death rewards, but do not introduce a chain that reproduces its own host.
            local proposed, changed_death = {}, false
            for _, move in pairs(path) do
                proposed[move.head] = move.base
                local base = graph.nodes[move.base]
                if base ~= nil and base.acq_kind == "dying" then changed_death = true end
            end
            if changed_death then
                local death_edges = {}
                for source, children in pairs(lookups.dying_spawns or {}) do
                    local host = gutils.deconstruct(source)
                    if host.type == "entity" then
                        death_edges[host.name] = death_edges[host.name] or {}
                        for child, _ in pairs(children) do
                            local output = gutils.deconstruct(child)
                            if output.type == "entity" then death_edges[host.name][output.name] = true end
                        end
                    end
                end
                -- Remove claimed native death outputs before inserting their proposed destinations.
                for _, slot in pairs(slots) do
                    if slot.kind == "dying" and slot.head.death_spoof == nil then
                        local host = owner_of(graph.nodes[slot.own_base_key]).name
                        if death_edges[host] ~= nil then death_edges[host][slot.identity] = nil end
                    end
                end
                for _, slot in pairs(slots) do
                    local base = graph.nodes[proposed[slot] or slot.base_key]
                    if base ~= nil and base.acq_kind == "dying" and slot.kind ~= "build" and slot.head.projectile_package == nil then
                        local host = base.death_host or owner_of(base).name
                        death_edges[host] = death_edges[host] or {}
                        death_edges[host][slot.identity] = true
                    end
                end
                if not death_slots.acyclic(death_edges) then return false end
            end
            checked = checked + 1
            local ok, failure = prom.try_rewires(changes, true)
            if not ok then
                refused = refused + 1
                return false, failure
            end
            longest_path = math.max(longest_path, #path)
            for _, change in pairs(mining) do keep_mine(change) end
            for _, move in pairs(path) do
                move.head.base_key = move.base ~= DETACHED and connection_base(move.head, move.base) or DETACHED
            end
            return true
        end,
    })
    prom.cache_rewires(true)
    for _, slot in pairs(slots) do
        local _, stats = matcher.try(slot)
        refinements = refinements + stats.refinements
    end
    prom.cache_rewires(false)
    -- Later augmentations can reroute earlier heads, so summarize only the final assignment.
    for _, slot in pairs(slots) do
        local chosen = matcher.assigned[slot]
        if slot.base_key ~= slot.own_base_key then
            counts.moved = counts.moved + 1
            local base = graph.nodes[chosen]
            if chosen == DETACHED then counts.detached = counts.detached + 1
            elseif slot.friendly then counts.friendly = counts.friendly + 1
            elseif base.build_spoof ~= nil then counts.spoofs = counts.spoofs + 1
            elseif slot.kind == "build" then
                if base.acq_kind == "autoplace" then counts.salvaged = counts.salvaged + 1
                elseif base.acq_kind == "spawn" then counts.carried = counts.carried + 1
                elseif base.acq_kind == "spoil" then counts.hatched = counts.hatched + 1
                elseif base.acq_kind == "dying" then counts.asteroid_salvaged = counts.asteroid_salvaged + 1
                elseif is_trigger_kind(base.acq_kind) then counts.triggered = counts.triggered + 1 end
            end
        end
    end
    log("Entity prerequisite search: " .. same_category .. " same-category searches, " .. (#slots - same_category) .. " general searches; " .. checked .. " augmenting paths checked, " .. refused .. " refused; " .. refinements .. " refinements; longest accepted path " .. longest_path)

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
                log("Entity randomization: " .. slot.identity .. " is now collected as asteroid salvage from " .. trigger_action(graph, base) .. " in place of " .. head_entity_name(graph, graph.nodes[base.old_head]))
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
    log("Entity randomization: " .. counts.moved .. " of " .. #slots .. " slots changed; " .. counts.spoofs .. " to an item that placed nothing, " .. counts.salvaged .. " to salvage from the wild, " .. counts.carried .. " to biter carriers, " .. counts.hatched .. " to carriers hatching from eggs, " .. counts.triggered .. " to trigger slots, " .. counts.asteroid_salvaged .. " to asteroid salvage, " .. counts.friendly .. " friendly biters, " .. counts.detached .. " detached")

    local wild_counts = {
        total = 0,
        moved = 0,
        cross_planet = 0,
        cross_original = 0,
        kinds = 0,
        equivalents = 0,
    }
    for _, slot in pairs(slots) do
        if slot.kind == "autoplace" then
            wild_counts.total = wild_counts.total + 1
            if slot.base_key ~= slot.own_base_key and slot.base_key ~= DETACHED and graph.nodes[slot.base_key].acq_kind == "autoplace" then
                wild_counts.moved = wild_counts.moved + 1
                local base = graph.nodes[slot.base_key]
                local own_base = graph.nodes[slot.own_base_key]
                local prototype = dutils.get_prot("entity", slot.identity)
                local other = dutils.get_prot("entity", base.entity)
                if gutils.get_owner(graph, own_base).name ~= gutils.get_owner(graph, base).name then
                    wild_counts.cross_planet = wild_counts.cross_planet + 1
                end
                local own_room = lookups.rooms[gutils.get_owner(graph, own_base).name]
                local other_room = lookups.rooms[gutils.get_owner(graph, base).name]
                local own_planet = data.raw.planet[own_room.name]
                local other_planet = data.raw.planet[other_room.name]
                if (own_planet.orig_name or own_planet.name) ~= (other_planet.orig_name or other_planet.name) then
                    wild_counts.cross_original = wild_counts.cross_original + 1
                end
                if prototype.type ~= other.type then
                    wild_counts.kinds = wild_counts.kinds + 1
                end
                if (prototype.deconstruction_alternative or prototype.name) == (other.deconstruction_alternative or other.name) then
                    wild_counts.equivalents = wild_counts.equivalents + 1
                end
            end
        end
    end
    log("Entity autoplace: " .. wild_counts.moved .. " of " .. wild_counts.total .. " wild slots moved; " .. wild_counts.cross_planet .. " across planets (" .. wild_counts.cross_original .. " between different originals), " .. wild_counts.kinds .. " across entity types, " .. wild_counts.equivalents .. " equivalent entries; " .. counts.salvaged .. " buildings salvaged")

    return true
end

-- Entity positions: first pass matches entity identities to them like it matches item identities to item positions (see first-pass.lua), and this handler reflects the result
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

-- First pass's rules for entity positions (see first-pass.lua), from unified's subdivided graph (before first pass's split)
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
    -- Trigger-created buildings must remain mineable so their placement can be undone.
    local function triggerable(identity, slot_kind)
        return movable_building(identity, slot_kind) and dutils.get_prot("entity", identity.entity).minable ~= nil
    end

    -- Whether a position can take an identity
    local function pair_allowed(position, identity)
        local source_package = projectile_packages[position.head.projectile_package]
        local traveler_package = projectile_packages[identity.head.projectile_package]
        if (source_package and source_package.locked) or (traveler_package and traveler_package.locked) then return position.key == identity.key end
        if traveler_package ~= nil then
            if source_package ~= nil then
                if source_package.id == traveler_package.id then return true end
                local cost, own_cost = item_cost(source_package.owner), item_cost(traveler_package.owner)
                return cost ~= nil and own_cost ~= nil and costs_within(cost, own_cost)
            end
            if position.kind ~= "build" or traveler_package.impact == nil or traveler_package.is_entity or not may[identity.key].spoof then return false end
            local cost, own_cost = item_cost(base_item_name(graph, position.base)), item_cost(traveler_package.owner)
            return cost ~= nil and own_cost ~= nil and costs_within(cost, own_cost)
        end
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
            -- The experimental first pass has no collector-backed alternate death positions.
            return false
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
        error("Entity randomization needs first pass (DO_FIRST_PASS in src/randomizations/unified/execute.lua)")
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
        asteroid_salvaged = 0,
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
                counts.asteroid_salvaged = counts.asteroid_salvaged + 1
                log("Entity randomization: " .. identity.entity .. " is now collected as asteroid salvage from " .. trigger_action(graph, base) .. " in place of " .. position.entity)
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

    log("Entity randomization: " .. counts.moved .. " of " .. #position_keys .. " slots changed; " .. counts.spoofs .. " to an item that placed nothing, " .. counts.salvaged .. " to salvage from the wild, " .. counts.carried .. " to biter carriers, " .. counts.hatched .. " to carriers hatching from eggs, " .. counts.triggered .. " to trigger slots, " .. counts.asteroid_salvaged .. " to asteroid salvage, " .. counts.friendly .. " friendly biters, " .. counts.detached .. " detached")

    return true
end

-- With experimental first pass entity positions, reflect those positions; otherwise search prerequisites sequentially.
entity.custom_prereq_search = function(params)
    if constants.entity_first_pass then
        return first_pass_search(params)
    end
    return prerequisite_search(params)
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
    local places = {"propertyrandomizer-entity.places", "[entity=" .. entity_prot.name .. "]", locale.find_localised_name(entity_prot)}
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
    return {"propertyrandomizer-entity.wild-salvage", "[entity=" .. entity_prot.name .. "]", locale.find_localised_name(entity_prot)}
end

-- How a trigger slot's base makes its entity, as rich text: using a capsule, firing ammo, or capturing a spawner
local function made_by_description(graph, base)
    local owner_name = gutils.get_owner(graph, base).name
    if base.acq_kind == "capture" then
        return {"propertyrandomizer-entity.capturing", "[entity=" .. owner_name .. "]", locale.find_localised_name(dutils.get_prot("entity", owner_name))}
    end
    local verb = "using"
    if base.acq_kind == "ammo" then
        verb = "firing"
    end
    return {"propertyrandomizer-entity." .. verb, "[item=" .. owner_name .. "]", locale.find_localised_name(dutils.get_prot("item", owner_name))}
end

-- A prototype's description with a line in front, leaving out its own description if it has none rather than show a missing key
local function with_description_line(prototype, description_key, line)
    if prototype.localised_description ~= nil then
        return {"", line, "\n", table.deepcopy(prototype.localised_description)}
    end
    return {"", line, {"?", {"", "\n", {description_key .. "." .. prototype.name}}, ""}}
end

entity.reflect = function(graph, head_to_base, head_to_handler)
    packages.refresh(projectile_packages)
    -- item --> entity it now places, entity --> items that now place it, entity --> items that placed it in vanilla (only claimed ones)
    local item_to_entity = {}
    local package_places = {}
    local package_assignments = {}
    local package_claimed = {}
    local death_packages = {}
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
    -- Built entity made by a trigger --> its trigger base; egg carrier --> spoil base; asteroid salvage --> collector-backed death base
    local triggered = {}
    local hatched = {}
    local asteroid_salvaged = {}
    -- Base where a trigger makes an entity (see is_made_kind) --> the entity it makes now, only ones that changed (carriers are added once they're made)
    local made_occupants = {}
    -- A native creation output moved to a death slot must disappear from its old trigger.
    for head_key, handler in pairs(head_to_handler) do
        local head = graph.nodes[head_key]
        local destination = graph.nodes[head_to_base[head_key]]
        if handler.id == entity.id and is_made_kind(head.acq_kind) and head.projectile_package == nil and destination ~= nil and destination.acq_kind == "dying" and head_to_base[head_key] ~= head.old_base then
            local base = graph.nodes[head.old_base]
            if base.death_spoof == nil and base.trigger_spoof == nil then made_occupants[head.old_base] = false end
        end
    end
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
            if head.projectile_package ~= nil then
                package_claimed[head.projectile_package] = true
                if base_key ~= nil then
                    local base = graph.nodes[base_key]
                    if base.death_spoof then
                        death_packages[base.death_host] = projectile_packages[head.projectile_package]
                    elseif base.acq_kind == "build" then
                        package_places[base_item_name(graph, base)] = projectile_packages[head.projectile_package]
                    elseif base.projectile_package ~= nil then
                        package_assignments[base.projectile_package] = projectile_packages[head.projectile_package]
                    end
                end
            elseif head.friendly ~= nil then
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
                local original = graph.nodes[head.old_base]
                spawn_occupants[original.spawner] = spawn_occupants[original.spawner] or {}
                if spawn_occupants[original.spawner][original.entity] == nil then spawn_occupants[original.spawner][original.entity] = false end
                if base_key ~= nil then
                    local base = graph.nodes[base_key]
                    if base.acq_kind == "dying" then
                        made_occupants[base_key] = entity_name
                    else
                        spawn_occupants[base.spawner] = spawn_occupants[base.spawner] or {}
                        spawn_occupants[base.spawner][base.entity] = entity_name
                    end
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
                    asteroid_salvaged[entity_name] = base_key
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
                if base_key ~= nil and graph.nodes[base_key].acq_kind == "dying" then
                    made_occupants[base_key] = entity_name
                    autoplace_moves[entity_name] = false
                else
                    autoplace_moves[entity_name] = base_key or false
                end
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
            -- Belts show an item's pictures, and its icon when it has none (ItemPrototype::pictures), so its own pictures go
            item.pictures = nil
            item.localised_name = {"propertyrandomizer-entity.friendly-name", locale.find_localised_name(entity_prot)}
            item.localised_description = {"propertyrandomizer-entity.friendly-places", "[entity=" .. entity_name .. "]", locale.find_localised_name(entity_prot)}
        elseif common.placed_entity_name(old_item) ~= entity_name then
            -- Other items take on the look of their new entity's own item (icons, name, stack size, place in menus); items that still place their own entity are left alone
            common.set_placed_entity(item, entity_prot)
            for _, prefix in pairs(common.item_icon_prefixes) do
                common.set_icon_layers(item, prefix, common.icon_layers(look, prefix))
            end
            -- Belts show an item's pictures, and its icon when it has none (ItemPrototype::pictures), so it takes that item's pictures too; a unit's look is its icon
            item.pictures = defines.prototypes.item[look.type] ~= nil and table.deepcopy(look.pictures) or nil
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
                now_from = {"propertyrandomizer-entity.source-carried"}
            elseif salvaged[last_entity.name] ~= nil then
                log("Entity randomization: " .. old_item_name .. " places nothing now, and looks like a darkened " .. look.name .. " (" .. last_entity.name .. " is now salvaged from the wild)")
                now_from = {"propertyrandomizer-entity.source-wild"}
            elseif triggered[last_entity.name] ~= nil then
                local base = graph.nodes[triggered[last_entity.name]]
                log("Entity randomization: " .. old_item_name .. " places nothing now, and looks like a darkened " .. look.name .. " (" .. last_entity.name .. " is now made by " .. trigger_action(graph, base) .. ")")
                now_from = {"propertyrandomizer-entity.source-made", made_by_description(graph, base)}
            elseif hatched[last_entity.name] ~= nil then
                local egg = dutils.get_prot("item", gutils.get_owner(graph, graph.nodes[hatched[last_entity.name]]).name)
                log("Entity randomization: " .. old_item_name .. " places nothing now, and looks like a darkened " .. look.name .. " (" .. last_entity.name .. " is now carried by biters hatching from " .. egg.name .. ")")
                now_from = {"propertyrandomizer-entity.source-hatched", "[item=" .. egg.name .. "]", locale.find_localised_name(egg)}
            elseif asteroid_salvaged[last_entity.name] ~= nil then
                local death_base = graph.nodes[asteroid_salvaged[last_entity.name]]
                local dying = dutils.get_prot("entity", death_base.death_host or gutils.get_owner(graph, death_base).name)
                log("Entity randomization: " .. old_item_name .. " places nothing now, and looks like a darkened " .. look.name .. " (" .. last_entity.name .. " is now collected as asteroid salvage from " .. dying.name .. ")")
                now_from = {"propertyrandomizer-entity.source-asteroid-salvage", "[entity=" .. dying.name .. "]", locale.find_localised_name(dying)}
            else
                local spoof_placer = dutils.get_prot("item", placer_of(last_head_key))
                log("Entity randomization: " .. old_item_name .. " places nothing now, and looks like a darkened " .. look.name .. " (" .. last_entity.name .. " is now placed by " .. spoof_placer.name .. ")")
                now_from = {"propertyrandomizer-entity.source-placed", "[item=" .. spoof_placer.name .. "]", locale.find_localised_name(spoof_placer)}
            end
            for _, prefix in pairs(common.item_icon_prefixes) do
                local layers = common.icon_layers(look, prefix)
                if layers ~= nil then
                    layers = common.darken_icon_layers(layers)
                end
                common.set_icon_layers(vestige, prefix, layers)
            end
            -- With no pictures, belts show that darkened icon (ItemPrototype::pictures)
            vestige.pictures = nil
            vestige.localised_name = {"propertyrandomizer-entity.vestige-name", table.deepcopy(look.localised_name) or last_entity_name}
            vestige.localised_description = {"propertyrandomizer-entity.vestige", "[entity=" .. last_entity.name .. "]", last_entity_name, now_from}
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
        for planet_name, planet in pairs(data.raw.planet) do
            local settings = planet_entity_settings(data.raw, planet_name)
            if settings ~= nil then
                settings[entity_name] = nil
            end
            -- Its placement overrides go with it (like the ones keeping an original off planet copies, src/prototypes/entities/wild-entities.lua)
            wild.set_overrides(planet, entity_name, {})
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
            -- And the slot's entity's placement overrides on every planet, so it's kept off wherever that entity was (a planet copy's clone off the other planets with its slider, see src/prototypes/duplicates/dupe-planets.lua)
            for other_name, other in pairs(data.raw.planet) do
                local starting_planet = unified_starting_data_raw.planet[other_name]
                if starting_planet ~= nil then
                    wild.set_overrides(other, entity_name, wild.overrides(starting_planet, base.entity))
                end
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
        local entity_prot = dutils.get_prot("entity", entity_name)
        local salvage = add_salvage_item(entity_name, salvage_description(entity_prot))
        entity_prot.localised_description = with_description_line(entity_prot, "entity-description", {
            "propertyrandomizer-entity.found-in-wild", "[item=" .. salvage.name .. "]", locale.find_localised_name(salvage),
        })
        log("Entity randomization: " .. entity_name .. " is found in the wild where " .. graph.nodes[base_key].entity .. " was, and mined for " .. salvage.name)
    end

    -- A built entity made by a trigger slot is ours where it's made, and is mined for a salvage item to place it anywhere else
    for entity_name, base_key in pairs(triggered) do
        local entity_prot = dutils.get_prot("entity", entity_name)
        local salvage = add_salvage_item(entity_name, {"propertyrandomizer-entity.made-salvage", "[entity=" .. entity_name .. "]", locale.find_localised_name(entity_prot), made_by_description(graph, graph.nodes[base_key])})
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
        looted.localised_description = {"propertyrandomizer-entity.carrier-drop", "[entity=" .. carrier.name .. "]", locale.find_localised_name(entity_prot)}
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
        carrier.localised_name = {"propertyrandomizer-entity.carrier-name", locale.find_localised_name(entity_prot)}
        carrier.localised_description = {"propertyrandomizer-entity.carrier-loot", "[item=" .. looted.name .. "]"}
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

    -- Asteroid rewards are collectible chunks whose mining product places the building.
    for entity_name, base_key in pairs(asteroid_salvaged) do
        local base = graph.nodes[base_key]
        assert(base.salvage_source ~= nil, "Building death rewards require a collectible asteroid slot")
        local template = assert(death_slots.salvage_template(data.raw["asteroid-chunk"]), "Asteroid salvage requires a visible chunk template")
        local salvage = add_salvage_item(entity_name, {"propertyrandomizer-entity.asteroid-salvage", locale.find_localised_name(dutils.get_prot("entity", base.death_host))})
        local icons = common.icon_layers(dutils.get_prot("entity", entity_name), "") or common.icon_layers(salvage, "")
        local chunk = death_slots.salvage_chunk(template, "propertyrandomizer-salvage-chunk-" .. entity_name, salvage.name, icons)
        chunk.localised_name = {"propertyrandomizer-entity.salvage-chunk", locale.find_localised_name(dutils.get_prot("entity", entity_name))}
        common.set_icon_layers(chunk, "", icons)
        data:extend({chunk})
        local host = dutils.get_prot("entity", base.death_host)
        death_slots.append(host, {type = "create-asteroid-chunk", asteroid_name = chunk.name})
        host.localised_description = with_description_line(host, "entity-description", {
            "propertyrandomizer-entity.asteroid-reward",
            "[item=" .. salvage.name .. "]",
            locale.find_localised_name(salvage),
        })
        table.insert(farm_report, "asteroid salvage: " .. entity_name .. ", from " .. base.death_host)
    end
    for host_name, package in pairs(death_packages) do
        local host = dutils.get_prot("entity", host_name)
        local action, copies = packages.copy_action(package.impact, function(name) return dutils.get_prot("entity", name) end, "propertyrandomizer-death-" .. host_name)
        if #copies > 0 then data:extend(copies) end
        death_slots.append(host, {type = "nested-result", action = action})
        host.propertyrandomizer_death_payload = action
        host.propertyrandomizer_death_budget = death_budgets[host_name]
        host.localised_description = with_description_line(host, "entity-description", {"propertyrandomizer-entity.death-payload", locale.find_localised_name(package.look)})
        log("Entity randomization: killing " .. host_name .. " activates payload " .. package.id)
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
            local occupant_prot = occupant ~= false and dutils.get_prot("entity", occupant) or nil
            local occupant_line = occupant ~= false and {"propertyrandomizer-entity.occupant", "[entity=" .. occupant .. "]", locale.find_localised_name(occupant_prot)} or {"propertyrandomizer-entity.empty-death"}
            if base.death_spoof then
                local host = dutils.get_prot("entity", base.death_host)
                death_slots.append(host, death_slots.create(occupant))
                host.localised_description = with_description_line(host, "entity-description", {"propertyrandomizer-entity.dying", occupant_line})
            elseif base.projectile_package ~= nil then
                packages.replace_with_building(projectile_packages[base.projectile_package], occupant, "propertyrandomizer-package-building-" .. base.projectile_package)
                package_assignments[base.projectile_package] = false
            elseif base.trigger_spoof ~= nil then
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
                spawner.localised_description = with_description_line(spawner, "entity-description", {"propertyrandomizer-entity.capture-makes", occupant_line})
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
                -- A building (anything an item placed in vanilla, like the captive spawner) is made once, where there's room for it, and never as an enemy (common.create_as_building)
                -- Anything else (like combat robots, which come in swarms) is made as often as what it replaces, where there's room
                local as_building = triggered[occupant] == base_key or entity_to_old_items[occupant] ~= nil
                local as_carrier = is_carrier[occupant] ~= nil
                retarget.retargets[made_before] = function(effect)
                    if occupant == false then
                        for field, _ in pairs(effect) do effect[field] = nil end
                        effect.type = "nested-result"
                        effect.action = {type = "direct", action_delivery = {type = "instant"}}
                    elseif as_building then
                        common.create_as_building(effect, occupant)
                    else
                        common.create_at_free_spot(effect, occupant)
                        if base.acq_kind == "dying" then
                            effect.offsets, effect.repeat_count, effect.repeat_count_deviation = nil, nil, nil
                            effect.as_enemy = death_slots.creature(occupant_prot) or nil
                            effect.ignore_no_enemies_mode = effect.as_enemy
                        end
                        -- A carrier is an enemy, and hatches even with enemies turned off (no_enemies_mode), since logic counts on its loot
                        if as_carrier then
                            effect.as_enemy = true
                            effect.ignore_no_enemies_mode = true
                        end
                    end
                end
                table.insert(retarget.lines, occupant_line)
                -- An item used by clicking (a capsule or ammo) gets a badge of what it makes, which looks like its own item if it's a building
                if occupant ~= false and is_trigger_kind(base.acq_kind) then
                    local look = occupant_prot
                    if entity_to_old_items[occupant] ~= nil then
                        look = starting_item(entity_to_old_items[occupant][1])
                    end
                    retarget.badge = retarget.badge or common.icon_layers(look, "")
                end
            end
            if base.trigger_spoof == nil then
                log("Entity randomization: " .. trigger_action(graph, base) .. " makes " .. tostring(occupant) .. " in place of " .. made_before)
            end
        end
    end
    -- How a holder's description says what it makes now
    local function makes_lead(kind)
        if kind == "spoil" then
            return "spoils"
        end
        if kind == "dying" then
            return "dying"
        end
        return "makes"
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
        local parts = {}
        for _, line in pairs(retarget.lines) do
            table.insert(parts, {"propertyrandomizer-entity." .. makes_lead(retarget.kind), line})
        end
        local lines = localised_text.join(parts, "\n")
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
        local ammo_type = capsule.capsule_action.attack_parameters.ammo_type
        local action, copies = common.replace_thrown_effect(ammo_type.action, effect, function(name)
            return "propertyrandomizer-maker-" .. capsule_name .. "-" .. name
        end)
        ammo_type.action = action
        if #copies > 0 then
            data:extend(copies)
        end
        mark_item(capsule, {
            "propertyrandomizer-entity.makes",
            maker.line,
        }, look_of(maker.occupant))
        log("Entity randomization: using " .. capsule_name .. " makes " .. maker.occupant .. " in place of its effect")
    end

    -- Displaced effects take compatible unused placement slots, or the unused capsule at the start of their acquisition chain.
    -- A Vestige is neither required nor enough: placing must be available, selected and affordable, and the impact action must be extractable.
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
    -- Capsule/item --> the capsule supplying its effect. Placement consumes the impact action, not the launch action.
    local capsule_effect = {}
    local placed_effect = {}
    local impact_actions = {}
    local placement_names = {}
    for item_name, item in pairs(dutils.get_all_prots("item")) do
        local unused = package_places[item_name] == nil and item_to_entity[item_name] == nil and (vestige_place_changes[item_name] ~= nil or not common.places_something(item))
        if unused and claimable_item(item) and not deposit_copies.is_copy(item) and graph.nodes[key("item", item_name)] ~= nil and graph_customization.selected("entity", {
            type = "item",
            name = item_name,
        }) then
            table.insert(placement_names, item_name)
        end
    end
    table.sort(placement_names)
    rng.shuffle(effect_rng_key, placement_names)
    local function place_effect(item_name, capsule_name)
        if placed_effect[item_name] ~= nil or impact_actions[capsule_name] == nil then
            return false
        end
        local cost = item_cost(item_name)
        local effect_cost = item_cost(capsule_name)
        if cost == nil or effect_cost == nil or not costs_within(cost, effect_cost) then
            return false
        end
        placed_effect[item_name] = capsule_name
        return true
    end
    for _, capsule_name in pairs(maker_names) do
        impact_actions[capsule_name] = common.capsule_impact_action(starting_item(capsule_name), starting_entity)
        local start = graph.nodes[chain_start(maker_occupants[capsule_name].base_key)]
        local start_name = gutils.get_owner(graph, start).name
        local placed = false
        -- Prefer the chain's own placement slot, provided it passes the same eligibility checks as every other item.
        for _, item_name in pairs(placement_names) do
            if item_name == start_name and place_effect(item_name, capsule_name) then
                placed = true
                break
            end
        end
        if not placed then
            for _, item_name in pairs(placement_names) do
                if place_effect(item_name, capsule_name) then
                    placed = true
                    break
                end
            end
        end
        if not placed then
            if start.acq_kind == "capsule" and effect_capsule(dutils.get_prot("item", start_name)) == false and holder_retargets["capsule:" .. start_name] == nil and maker_occupants[start_name] == nil and capsule_effect[start_name] == nil then
                capsule_effect[start_name] = capsule_name
            else
                log("Entity randomization: the effect of " .. capsule_name .. " has no compatible placement or capsule destination")
            end
        end
    end

    -- Capsules thrown for an effect that nothing else changed trade effects among each other, some of them (a rotation, so every effect stays somewhere)
    local swapped = {}
    local effect_capsule_names = {}
    for _, item in pairs(dutils.get_all_prots("item")) do
        if fixed_effects[item.name] == nil and projectile_packages["item-" .. item.name] == nil and effect_capsule(item) and maker_occupants[item.name] == nil and capsule_effect[item.name] == nil and holder_retargets["capsule:" .. item.name] == nil then
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
        mark_item(capsule, {"propertyrandomizer-entity.effect", "[item=" .. from_name .. "]", locale.find_localised_name(from)}, from)
        log("Entity randomization: using " .. capsule_name .. " does what " .. from_name .. " did")
    end
    -- Cliffs name the capsule that explodes them, and the game won't load a cliff whose capsule no longer does, so they follow the effect (or forget it, when a Vestige took it)
    for _, change in pairs(common.cliffs_follow_explosives(capsule_effect)) do
        if change.to ~= nil then
            log("Entity randomization: " .. change.cliff .. " is exploded by " .. change.to .. " now, since " .. change.from .. " lost that effect")
        else
            log("Entity randomization: " .. change.cliff .. " can't be exploded by a capsule now, since " .. change.from .. " lost that effect and no capsule has it")
        end
    end

    -- Place the impact itself. Unlike throwing, this never launches the capsule's outer projectile.
    for item_name, from_name in pairs(placed_effect) do
        local from = starting_item(from_name)
        local effect_name = "propertyrandomizer-effect-" .. from_name
        if dutils.get_prot("entity", effect_name) == nil then
            local set_off = {
                type = "explosion",
                name = effect_name,
                localised_name = {"propertyrandomizer-entity.set-off-name", locale.find_localised_name(from)},
                hidden_in_factoriopedia = true,
                flags = {
                    "placeable-player",
                    "not-on-map",
                },
                animations = util.empty_animation(1),
                collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
                selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
                created_effect = impact_actions[from_name],
            }
            common.set_icon_layers(set_off, "", common.icon_layers(from, ""))
            data:extend({set_off})
        end
        local item = dutils.get_prot("item", item_name)
        local place_change = vestige_place_changes[item_name]
        if place_change ~= nil then
            place_change.new_val = effect_name
            -- Receiving an effect is a different outcome from becoming a Vestige.
            item.localised_name = {
                "propertyrandomizer-entity.placed-effect-name",
                locale.find_localised_name(from),
            }
            for _, prefix in pairs(common.item_icon_prefixes) do
                common.set_icon_layers(item, prefix, common.icon_layers(from, prefix))
            end
            item.pictures = nil
            local was = vestige_was[item_name]
            item.localised_description = {
                "propertyrandomizer-entity.vestige-effect",
                "[entity=" .. was.entity .. "]",
                was.entity_name,
                was.now_from,
                "[item=" .. from_name .. "]",
                locale.find_localised_name(from),
            }
        else
            -- Keep the item's existing uses, name and appearance, with a badge for its new placement effect.
            item.localised_name = table.deepcopy(locale.find_localised_name(starting_item(item_name)))
            mark_item(item, {
                "propertyrandomizer-entity.placed-effect",
                "[item=" .. from_name .. "]",
                locale.find_localised_name(from),
            }, from)
            table.insert(changes, {
                tbl = item,
                prop = "place_result",
                new_val = effect_name,
            })
        end
        log("Entity randomization: placing " .. item_name .. " directly runs the impact of " .. from_name)
    end

    -- Package placements override any deferred Vestige clearing of the slot they took.
    for item_name, package in pairs(package_places) do packages.place(item_name, package, vestige_place_changes[item_name] ~= nil) end
    local package_ids = {}
    for id, _ in pairs(projectile_packages) do table.insert(package_ids, id) end
    table.sort(package_ids)
    for _, id in pairs(package_ids) do
        local destination = projectile_packages[id]
        local donor = package_assignments[id]
        -- Enemy attacks borrow a private package copy, without removing a player's damage source.
        if destination.is_entity and rng.value(effect_rng_key) < EFFECT_SWAP_CHANCE then
            donor = projectile_packages[package_ids[rng.int(effect_rng_key, #package_ids)]]
        end
        if donor ~= nil and donor ~= false and donor.id ~= id then
            packages.install(destination, donor, "propertyrandomizer-package-" .. id)
            log("Entity randomization: projectile package " .. donor.id .. " now fires from " .. id)
        elseif donor == nil and package_claimed[id] ~= nil then
            packages.clear(destination)
        end
    end

    -- Spawners spawn whatever took their spawn slots, at those slots' spawn points
    -- A slot whose unit stopped spawning at some evolution (transient) spawns its new unit at every evolution, since logic counts on it (TRANSIENT_WEIGHT_FLOOR)
    -- A slot nothing took keeps its vanilla unit, and a unit taking two slots of one spawner gets one entry spawning at least as much as both
    for spawner_name, occupants in pairs(spawn_occupants) do
        local entries = {}
        local entry_of = {}
        for _, definition in pairs(starting_entity(spawner_name).result_units) do
            local unit_name, points = acquisition.read_spawn_definition(definition)
            local occupant = occupants[unit_name]
            if occupant == false then
                occupant = unit_name
                points = table.deepcopy(points)
                for _, point in pairs(points) do point.weight = 0 end
            elseif occupant == nil then
                occupant = unit_name
            end
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

    -- Units spawned away from their home planet come in their home spawners' numbers and at their new planet's strength (handler-helpers/military.lua)
    if config.military_rebalance then
        military_rebalance.apply()
    end

    -- Bulk classes with members only gotten by hand, next to the members still placed by items (group-supply keeps at least one of those wherever vanilla had one)
    local class_members = {}
    local has_hand_member = {}
    for entity_name, _ in pairs(entity_to_old_items) do
        local class = dutils.get_prot("entity", entity_name).type
        if acquisition.bulk_entity_types[class] ~= nil then
            class_members[class] = class_members[class] or {}
            if salvaged[entity_name] ~= nil or carried[entity_name] ~= nil or hatched[entity_name] ~= nil or triggered[entity_name] ~= nil or asteroid_salvaged[entity_name] ~= nil then
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

-- Other reflection steps can change a host's attack strength after matching, including military copies.
-- Reject that attempt if its final death payload exceeds the same bound used during candidate search.
entity.after_reflection = function()
    local function lookup(name) return dutils.get_prot("entity", name) end
    for _, host in pairs(dutils.get_all_prots("entity")) do
        if host.propertyrandomizer_death_payload ~= nil and not death_slots.payload_fits(host, host.propertyrandomizer_death_payload, lookup, host.propertyrandomizer_death_budget) then
            log("Entity randomization: final death payload exceeds the combat budget of " .. host.name)
            return false
        end
    end
    return true
end

-- Conservative pure preflight: false proves claim has no effect; true still needs ordinary claiming.
entity.may_claim = function(graph, prereq, dep, edge)
    return edge.acq_kind ~= nil or edge.mine_back ~= nil or edge.carrier_spoof ~= nil or edge.nowhere ~= nil or edge.death_spoof ~= nil or edge.trigger_spoof ~= nil or edge.projectile_package ~= nil
end

return entity

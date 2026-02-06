-- Abstract node definitions for the dependency graph
-- These represent "abstract" types of things (like electricity) with usually no specific prototype

local collision_mask_util
if not offline then
    collision_mask_util = require("__core__/lualib/collision-mask-util")
else
    collision_mask_util = require("offline/lualib/collision-mask-util")
end

local lib_name = "new-lib"
local categories = require("helper-tables/categories")
local dutils = require(lib_name .. "/data-utils")
local gutils = require(lib_name .. "/graph/graph-utils")
local lutils = require(lib_name .. "/logic/logic-utils")
local builder = require(lib_name .. "/logic/builder")

local prots = dutils.prots
local key = gutils.key
local concat = gutils.concat
local add_node = builder.add_node
local add_edge = builder.add_edge
local set_class = builder.set_class
local set_prot = builder.set_prot

local abstract = {}

function abstract.build(lu)
    ----------------------------------------------------------------------
    -- Room
    ----------------------------------------------------------------------

    -- Rooms are abstract locations where the player can be (planets, space surfaces)
    -- This replaces the old -surface node variants with a simpler model

    set_class("room")

    for room_key, room in pairs(lu.rooms) do
        set_prot(data.raw[room.type][room.name])

        ----------------------------------------
        add_node("room", "OR", room_key, room_key)
        ----------------------------------------
        -- Can we access this room/location?
        -- This node ADDS context: outputs the room's own context.
        -- For planets: depends on space-location (being in orbit allows descent)
        -- For space surfaces: depends on room-create-platform

        if room.type == "planet" then
            -- If this is the starting planet, fulfill it with the starting planet node
            if room.name == lutils.starting_planet_name then
                add_edge("starting-planet", "")
            end
            -- Planet rooms depend on being able to reach orbit (space-location)
            -- Planets ARE space-locations (they inherit), so use room.name directly
            -- For starting planets, this creates a cycle broken by starting conditions (added elsewhere)
            add_edge("space-location", room.name)

            ----------------------------------------
            add_node("room-launch", "AND")
            ----------------------------------------
            -- Can we launch from this specific planet?
            -- Requires: room + launch capability

            add_edge("room", room_key)
            add_edge("launch", "")

        elseif room.type == "surface" then
            add_edge("room-create-platform", room_key)

            ----------------------------------------
            add_node("room-create-platform", "AND", nil, room_key)
            ----------------------------------------
            -- Can we create an instance of this space surface room via launch?
            -- Requires: starter pack + launch capability + tech unlock

            add_edge("room-create-platform-starter-pack", room_key)
            add_edge("space-platform-unlock", "")
            add_edge("launch", "")

            ----------------------------------------
            add_node("room-create-platform-starter-pack", "OR", nil, room_key)
            ----------------------------------------
            -- Can we get a starter pack that creates this space surface?
            -- OR over all starter packs for this surface (with weight check)

            local starter_packs = lu.surface_to_starter_packs[room.name]
            local rocket_lift_weight = data.raw["utility-constants"].default.rocket_lift_weight
            if starter_packs ~= nil then
                for pack_name, _ in pairs(starter_packs) do
                    if lu.weight[pack_name] <= rocket_lift_weight then
                        add_edge("item", pack_name)
                    end
                end
            end
        end
    end

    set_prot(nil)

    ----------------------------------------------------------------------
    -- Combat
    ----------------------------------------------------------------------

    -- Nodes for use in evaluating combat abilities, like overcoming resistances
    -- These are virtual, meaning that they don't correspond to real prototypes; for some of the physical combat nodes, see things like item-ammo and damage-type

    set_class("combat")

    for group_key, is_immune in pairs(lu.entity_resistance_groups.groups) do
        ----------------------------------------
        add_node("resistance-group", "OR", nil, group_key)
        ----------------------------------------
        -- Can we deal damage that bypasses this immunity group?

        for _, damage_type in pairs(prots("damage-type")) do
            if not is_immune[damage_type.name] then
                add_edge("damage-type", damage_type.name)
            end
        end
    end

    ----------------------------------------------------------------------
    -- Energy Sources
    ----------------------------------------------------------------------

    -- Note that void and electric are AND's, while the others are OR's

    set_class("energy-source")

    ----------------------------------------
    add_node("energy-source-void", "AND", nil, "", { canonical = "energy-source-void" })
    ----------------------------------------
    -- Can we power an entity that requires no power?
    -- Trivially satisfied (AND with no inputs).

    for fcat_combo, combo_info in pairs(lu.fcat_combos) do
        ----------------------------------------
        add_node("energy-source-burner", "OR", nil, fcat_combo, { canonical = "energy-source-burner" })
        ----------------------------------------
        -- Can we power an entity with this burner energy source?

        for _, fuel_category in pairs(combo_info.fuel) do
            -- Check fuels with burnt results only if curr.burnt == 1
            for burnable = 0, combo_info.burnt do
                local items_for_fuel = lu.fcat_to_items[concat({fuel_category, burnable})]
                -- If items_for_fuel is nil, then there are no items that satisfy this fuel category and so we just don't have any prereqs
                if items_for_fuel ~= nil then
                    for item_name, _ in pairs(items_for_fuel) do
                        add_edge("item", item_name)
                    end
                end
            end
        end
    end

    ----------------------------------------
    add_node("energy-source-electric", "AND", nil, "", { canonical = "energy-source-electric" })
    ----------------------------------------
    -- Can we power an entity with an electric energy source?
    -- Requires: distribution + production

    add_edge("energy-source-electric-distribution", "")
    add_edge("energy-source-electric-production", "")

    ----------------------------------------
    add_node("energy-source-electric-distribution", "OR", nil, "", { canonical = "energy-source-electric" })
    ----------------------------------------
    -- Can we distribute power?
    -- OR over: electric poles, space surfaces (don't need poles)
    -- Grouped with energy-source-electric via canonical name

    add_edge("electric-pole", "")
    for room_key, room in pairs(lu.rooms) do
        -- Space surfaces don't need electric poles
        if room.type == "surface" then
            add_edge("room", room_key)
        end
    end

    ----------------------------------------
    add_node("electric-pole", "OR", nil, "", { canonical = "energy-source-electric" })
    ----------------------------------------
    -- Can we operate an electric pole?
    -- Note that this grouping isn't necessarily accurate in case we start on a space platform (then electric poles are separate from distribution)
    -- But starting on a space-platform sounds a bit crazy

    for _, pole in pairs(prots("electric-pole")) do
        add_edge("entity-operate", pole.name)
    end

    ----------------------------------------
    add_node("energy-source-electric-production", "OR", nil, "", { canonical = "energy-source-electric" })
    ----------------------------------------
    -- Can we produce power?
    -- Grouped with energy-source-electric via canonical name

    for _, generator in pairs(prots("burner-generator")) do
        add_edge("entity-operate", generator.name)
    end
    for _, generator in pairs(prots("generator")) do
        add_edge("entity-operate", generator.name)
    end
    add_edge("energy-source-electric-production-lightning", "")
    for _, solar_panel in pairs(prots("solar-panel")) do
        add_edge("entity-operate", solar_panel.name)
    end
    for _, generator in pairs(prots("fusion-generator")) do
        add_edge("entity-operate", generator.name)
    end

    ----------------------------------------
    add_node("energy-source-electric-production-lightning", "AND", nil, "", { canonical = "energy-source-electric-production-lightning" })
    ----------------------------------------
    -- Can we produce power from lightning?
    -- Requires: lightning existence + capture

    add_edge("energy-source-electric-production-lightning-existence", "")
    add_edge("energy-source-electric-production-lightning-capture", "")

    ----------------------------------------
    add_node("energy-source-electric-production-lightning-existence", "OR", nil, "", { canonical = "energy-source-electric-production-lightning" })
    ----------------------------------------
    -- Can we see lightning in the air?
    -- Note that this has the same canonical and name as just production-lightning, so it will be blocked with that

    for room_key, room in pairs(lu.rooms) do
        if room.type == "planet" and data.raw.planet[room.name].lightning_properties ~= nil then
            -- Technically we should also check if at least one of the lightnings carries energy, but who makes lightning that doesn't give energy?
            add_edge("room", room_key, {
                abilities = { [1] = true },
            })
        end
    end

    ----------------------------------------
    add_node("energy-source-electric-production-lightning-capture", "OR", nil, "", { canonical = "energy-source-electric-production-lightning" })
    ----------------------------------------
    -- Can we capture lightning?
    -- Also has the same canonical and name as production-lightning, so will be blocked with that

    for _, attractor in pairs(prots("lightning-attractor")) do
        if attractor.efficiency > 0 then
            add_edge("entity-operate", attractor.name)
        end
    end

    ----------------------------------------
    add_node("energy-source-fluid", "OR", nil, "", { canonical = "energy-source-fluid" })
    ----------------------------------------
    -- Can we provide fluid fuel?

    for _, fluid in pairs(lu.fluids) do
        if fluid.fuel_value ~= nil and util.parse_energy(fluid.fuel_value) > 0 then
            add_edge("fluid", fluid.name)
        end
    end

    ----------------------------------------
    add_node("energy-source-heat", "AND", nil, "", { canonical = "energy-source-heat" })
    ----------------------------------------
    -- Can we deliver heat to entities?

    -- Technically, you can just attach entities to heat connections directly, but that sounds awful on aquilo
    add_edge("energy-source-heat-distribution", "")
    add_edge("energy-source-heat-production", "")

    ----------------------------------------
    add_node("energy-source-heat-distribution", "OR", nil, "", { canonical = "energy-source-heat" })
    ----------------------------------------
    -- Can we distribute produced heat to entities?
    -- Same canonical name as heat

    for _, pipe in pairs(prots("heat-pipe")) do
        add_edge("entity-operate", pipe.name)
    end

    ----------------------------------------
    add_node("energy-source-heat-production", "OR", nil, "", { canonical = "energy-source-heat" })
    ----------------------------------------
    -- Can we produce heat?
    -- Same canonical name as heat

    for class_name, _ in pairs(categories.heat_producers) do
        for _, heater in pairs(prots(class_name)) do
            add_edge("entity-operate", heater.name)
        end
    end

    ----------------------------------------------------------------------
    -- Science Pack Set
    ----------------------------------------------------------------------
    -- Virtual nodes for each unique combination of science packs.
    -- Labs must accept ALL packs in a set simultaneously for research.

    -- TODO: Ability to support mods with techs which take different amounts of each science pack (like in py)

    set_class("science-pack-set")

    for set_name, set_packs in pairs(lu.science_sets) do
        ----------------------------------------
        add_node("science-pack-set-science", "AND", nil, set_name)
        ----------------------------------------
        -- Can we create all these science packs?

        for _, pack in pairs(set_packs) do
            add_edge("item", pack)
        end

        ----------------------------------------
        add_node("science-pack-set-lab", "OR", nil, set_name)
        ----------------------------------------
        -- Can we research with this combination of science packs?
        -- OR over labs that can hold all packs in the set.
        -- Note that this and the sciences themselves are grouped together by canonical

        -- Need a lab that accepts all packs
        local labs = lu.science_set_to_labs[set_name]
        if labs ~= nil then
            for lab_name, _ in pairs(labs) do
                add_edge("entity-operate", lab_name)
            end
        end
    end

    ----------------------------------------------------------------------
    -- Tile Collision Group
    ----------------------------------------------------------------------

    -- These group tiles by their collision layers for efficient entity placement checks.
    -- entity-build-tile depends on entity collision group, which then depends on these groups rather than individual tiles.

    set_class("tile-collision-group")

    for layers_key, tiles_in_group in pairs(lu.tile_collision_groups) do
        ----------------------------------------
        add_node("tile-collision-group", "OR", nil, layers_key)
        ----------------------------------------
        -- Can we access a tile in this collision group?
        -- OR over all tiles that share these collision layers.

        for tile_name, _ in pairs(tiles_in_group) do
            add_edge("tile", tile_name)
        end
    end

    ----------------------------------------------------------------------
    -- Entity Collision Group
    ----------------------------------------------------------------------

    set_class("entity-collision-group")

    for layers_key, layers in pairs(lu.entity_collision_group_to_layers) do
        ----------------------------------------
        add_node("entity-collision-group", "OR", nil, layers_key)
        ----------------------------------------

        for tile_layers_key, tile_layers in pairs(lu.tile_collision_group_to_layers) do
            if not collision_mask_util.masks_collide({layers = layers}, {layers = tile_layers}) then
                add_edge("tile-collision-group", tile_layers_key)
            end
        end
    end

    ----------------------------------------------------------------------
    -- Universal
    ----------------------------------------------------------------------

    -- These encapsulate universal abilities not tied to specific prototypes
    -- Many were previously called only by their relevant room/"surface", or simply labeled "canonical"
    -- Most of these should be their own canonical categories

    set_class("universal")

    ----------------------------------------
    add_node("agricultural-tower", "OR", nil, "", { canonical = "agricultural-tower" })
    ----------------------------------------
    -- Can we use an agricultural tower?

    for _, ag_tower in pairs(prots("agricultural-tower")) do
        add_edge("entity-operate", ag_tower.name)
    end

    ----------------------------------------
    add_node("asteroid-collector", "OR", nil, "", { canonical = "asteroid-collector" })
    ----------------------------------------
    -- Can we use an asteroid collector?

    for _, collector in pairs(prots("asteroid-collector")) do
        add_edge("entity-operate", collector.name)
    end

    ----------------------------------------
    add_node("capture-robot", "OR", nil, "", { canonical = "capture-robot" })
    ----------------------------------------
    -- Can we use a capture robot?

    for _, robot in pairs(prots("capture-robot")) do
        add_edge("entity-operate", robot.name)
    end

    ----------------------------------------
    add_node("capture-spawner", "OR", nil, "", { canonical = "capture-spawner" })
    ----------------------------------------
    -- Can we capture any spawner?

    for _, entity in pairs(lu.entities) do
        if entity.type == "unit-spawner" then
            add_edge("entity-capture-spawner", entity.name)
        end
    end

    ----------------------------------------
    add_node("mining-with-fluid-unlock", "OR", nil, "", { canonical = "mining-with-fluid-unlock" })
    ----------------------------------------
    -- Have we unlocked the ability to mine resources that require fluid?

    for _, tech in pairs(lu.techs) do
        if tech.effects ~= nil then
            for _, effect in pairs(tech.effects) do
                if effect.type == "mining-with-fluid" and effect.modifier then
                    add_edge("technology", tech.name)
                end
            end
        end
    end

    ----------------------------------------
    add_node("warmth", "OR", nil, "", { canonical = "warmth" })
    ----------------------------------------
    -- Can we keep entities warm?

    for room_key, room in pairs(lu.rooms) do
        if not data.raw[room.type][room.name].entities_require_heating then
            add_edge("room", room_key)
        end
    end
    add_edge("energy-source-heat", "")

    ----------------------------------------
    add_node("thruster", "OR", nil, "", { canonical = "spaceship" })
    ----------------------------------------
    -- Can we operate a thruster (needed for space travel)?
    -- Tied to spaceship

    for _, thruster in pairs(prots("thruster")) do
        add_edge("entity-operate", thruster.name)
    end

    ----------------------------------------
    add_node("spaceship", "AND", nil, "", { canonical = "spaceship" })
    ----------------------------------------
    -- Can we make a space surface into a spaceship?
    -- Requires: space-surface (for context) + flight components

    add_edge("space-surface", "")
    add_edge("thruster", "")
    -- TODO: Add other spaceship requirements (fuel, oxidizer, etc.) as needed

    ----------------------------------------
    add_node("planet", "OR", nil, "", { canonical = "planet" })
    ----------------------------------------
    -- Can we be on any planet? (Needed for launching)

    for room_key, room in pairs(lu.rooms) do
        if room.type == "planet" then
            add_edge("room", room_key)
        end
    end

    ----------------------------------------
    add_node("space-surface", "OR", nil, "", { canonical = "space-surface" })
    ----------------------------------------
    -- Can we be on any space surface? (Needed for item delivery)

    for room_key, room in pairs(lu.rooms) do
        if room.type == "surface" then
            add_edge("room", room_key)
        end
    end

    ----------------------------------------
    add_node("reachable-room", "OR", nil, "", { canonical = "room" })
    ----------------------------------------
    -- Can we reach some room?
    -- Needed for item-launch to know what rooms can be delivered to.

    for room_key, room in pairs(lu.rooms) do
        add_edge("room", room_key)
    end

    ----------------------------------------
    add_node("space-platform-unlock", "OR", nil, "", { canonical = "space-platform-unlock" })
    ----------------------------------------
    -- Have we researched the ability to send starter packs to space?
    -- OR over technologies with unlock-space-platforms effect

    for tech_name, _ in pairs(lu.space_platform_unlock_techs) do
        add_edge("technology", tech_name)
    end

    ----------------------------------------
    add_node("create-platform", "OR", nil, "", { canonical = "create-platform" })
    ----------------------------------------
    -- Can we create any space platform?

    for room_key, room in pairs(lu.rooms) do
        if room.type == "surface" then
            add_edge("room-create-platform", room_key)
        end
    end

    ----------------------------------------
    add_node("rocket-silo", "OR", nil, "", { canonical = "launch" })
    ----------------------------------------
    -- Can we use any rocket silo for launching?

    for _, silo in pairs(prots("rocket-silo")) do
        if lu.entities[silo.name] ~= nil then
            add_edge("entity-rocket-silo", silo.name)
        end
    end

    ----------------------------------------
    add_node("cargo-landing-pad", "OR", nil, "", { canonical = "launch" })
    ----------------------------------------
    -- Can we operate some cargo landing pad?

    for _, cargo_pad in pairs(prots("cargo-landing-pad")) do
        add_edge("entity-operate", cargo_pad.name)
    end

    ----------------------------------------
    add_node("launch", "AND", nil, "", { canonical = "launch" })
    ----------------------------------------
    -- Can we launch something into space?
    -- Requires: planet + rocket silo + cargo landing pad

    add_edge("planet", "")
    add_edge("rocket-silo", "")
    add_edge("cargo-landing-pad", "")

    ----------------------------------------
    add_node("deliver", "OR", nil, "", { canonical = "launch" })
    ----------------------------------------
    -- Can we deliver items FROM this location?
    -- Space surfaces can deliver anywhere, planets can deliver anywhere if their rocket silo was unlocked

    add_edge("launch", "", {
        abilities = { [1] = false }, -- Make sure deliverability doesn't carry isolatability with it
    })
    add_edge("space-surface", "", {
        abilities = { [1] = false },
    })

    ----------------------------------------------------------------------
    -- Starting
    ----------------------------------------------------------------------

    -- SOURCE nodes that bootstrap the game. These have no prerequisites
    -- and break the circular dependencies that would otherwise make
    -- the starting planet unreachable.
    -- These are group together canonically.

    set_class("starting")

    ----------------------------------------
    add_node("starting-character", "AND", nil, "")
    ----------------------------------------
    -- Do we have the starting character?
    -- SOURCE: AND with no inputs = trivially satisfied.

    ----------------------------------------
    add_node("starting-planet", "AND", nil, "")
    ----------------------------------------
    -- Do we have access to the starting planet?
    -- SOURCE: AND with no inputs = trivially satisfied.

    ----------------------------------------------------------------------
    -- Logic
    ----------------------------------------------------------------------

    -- These virtual nodes are used mostly for internal logic by randomizers outside this file.
    -- They're usually constructed temporarily to make the randomizations work better.
    -- I include sections for all types, though most will just have the single canonical example here for type initialization.

    set_class("logic")

    ----------------------------------------
    add_node("true", "AND", nil, "", { canonical = "true" })
    ----------------------------------------
    -- Can we? Yes, we can.
    -- Used for satisfying arbitrary logical connections when necessary.

    ----------------------------------------
    add_node("false", "OR", nil, "", { canonical = "false" })
    ----------------------------------------
    -- Can we? No, we can't.
    -- OR with no inputs = never satisfied.

    ----------------------------------------
    add_node("logic-and", "AND", nil, "", { canonical = "logic-and" })
    ----------------------------------------
    -- Can we satisfy some AND condition that needed to be created ad-hoc?

    ----------------------------------------
    add_node("logic-or", "OR", nil, "", { canonical = "logic-or" })
    ----------------------------------------
    -- Can we satisfy some OR condition that needed to be created ad-hoc?

    ----------------------------------------
    add_node("slot", "AND", nil, "", { canonical = "slot" })
    ----------------------------------------
    -- Can we satisfy a slot that comes at the beginning of an edge?
    -- In some places, edges are broken by two additional nodes (i.e.- subdivided), the one near the start of the edge is the slot, and the other is the traveler.
    -- Rewiring edges then becomes a matter of connecting slots to travelers, which can be simpler to work out sometimes since there is only one edge that could be randomized.

    ----------------------------------------
    add_node("traveler", "OR", nil, "", { canonical = "traveler" })
    ----------------------------------------
    -- Can we satisfy a traveler that comes at the end of an edge?

    ----------------------------------------------------------------------
    -- Meta
    ----------------------------------------------------------------------

    -- Nodes that help with the creation of this graph, like satisfying connections that are WIP.

    set_class("meta")

    ----------------------------------------
    add_node("satisfied", "AND", nil, "", { canonical = "satisfied" })
    ----------------------------------------
    -- Can we ignore that this edge hasn't been created yet and pretend we can?
    -- Used to satisfy nodes for connections that haven't been coded yet.

    ----------------------------------------
    add_node("unsatisfied", "OR", nil, "", { canonical = "unsatisfied" })
    ----------------------------------------
    -- Can we ignore that this edge hasn't been created yet and pretend we can't?
    -- OR with no inputs = never satisfied.

end

return abstract

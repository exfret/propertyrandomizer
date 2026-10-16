-- The engine probe checks the actual death hook, including the force and mineability of a natural output.
local test = {}
test.run = function()
    if prototypes.entity["propertyrandomizer-test-death-tree"] == nil then return end
    local surface = game.create_surface("propertyrandomizer-test-deaths", {width = 32, height = 32})
    local tiles = {}
    for x = -10, 10 do
        for y = -10, 10 do table.insert(tiles, {name = "grass-1", position = {x, y}}) end
    end
    surface.set_tiles(tiles)
    local host = surface.create_entity({name = "propertyrandomizer-test-death-tree", position = {0, 0}, force = "enemy"})
    assert(host ~= nil and host.die("player"))
    local trees = surface.find_entities_filtered({name = "tree-01", position = {0, 0}, radius = 5})
    assert(#trees == 1, "a death must create exactly one tree")
    local force_name = trees[1].force.name
    local inventory = game.create_inventory(100)
    assert(trees[1].mine({inventory = inventory}), "death-created tree must be mineable")
    assert(not inventory.is_empty(), "mining the tree must yield its products")
    inventory.destroy()
    log("PRTEST death tree: one mineable tree; force=" .. force_name)
    local chest = surface.create_entity({name = "wooden-chest", position = {1, 0}, force = "player"})
    local before = chest.health
    local explosive = surface.create_entity({name = "propertyrandomizer-test-death-payload", position = {0, 0}, force = "enemy"})
    assert(explosive.die("player"))
    assert(chest.health < before, "the payload must damage entities near the death position")
    log("PRTEST death payload: copied grenade impact damaged a nearby chest")
    game.delete_surface(surface)
    if prototypes.asteroid_chunk["propertyrandomizer-test-salvage-chunk"] ~= nil then
        local platform = game.forces.player.create_space_platform({name = "Death salvage probe", planet = "nauvis", starter_pack = "space-platform-starter-pack"})
        assert(platform ~= nil and platform.apply_starter_pack(true) ~= nil)
        local tiles = {}
        for x = -2, 2 do for y = -10, -5 do table.insert(tiles, {name = "space-platform-foundation", position = {x, y}}) end end
        platform.surface.set_tiles(tiles)
        local collector = platform.surface.create_entity({name = "propertyrandomizer-test-salvage-collector", position = {0, -10}, force = "player", direction = defines.direction.north})
        assert(collector ~= nil)
        collector.set_filter(1, "propertyrandomizer-test-salvage-chunk")
        storage.death_collector = collector
        local asteroid = platform.surface.create_entity({name = "propertyrandomizer-test-salvage-asteroid", position = {0, -15}, force = "enemy"})
        assert(asteroid ~= nil and asteroid.die("player"))
        local chunks = platform.find_asteroid_chunks_filtered({name = "propertyrandomizer-test-salvage-chunk"})
        assert(#chunks == 1, "one asteroid death must create one salvage chunk")
        local fragments = platform.surface.find_entities_filtered({name = "medium-oxide-asteroid", position = {0, -15}, radius = 5})
        assert(#fragments == 3, "salvage must coexist with the normal big-asteroid fragments")
        -- Keep those fragments from destroying the collector before its collection probe completes.
        for _, fragment in pairs(fragments) do fragment.destroy() end
        log("PRTEST death salvage: chunk created; waiting for collection")
    end
end
test.check = function(tick)
    if tick ~= 480 or storage.death_collector == nil then return end
    local inventory = storage.death_collector.get_inventory(defines.inventory.asteroid_collector_output)
    local status = tostring(storage.death_collector.status)
    for name, value in pairs(defines.entity_status) do if value == storage.death_collector.status then status = name end end
    log("PRTEST collector status=" .. status .. " contents=" .. serpent.line(inventory.get_contents()) .. " chunks=" .. serpent.line(storage.death_collector.surface.platform.find_asteroid_chunks_filtered({name = "propertyrandomizer-test-salvage-chunk"})))
    assert(inventory.get_item_count("propertyrandomizer-test-salvage-item") == 1, "collector must return the salvage placement item")
    assert(prototypes.item["propertyrandomizer-test-salvage-item"].place_result.name == "steel-chest")
    log("PRTEST death salvage: collector returned one building placement item")
end
return test

local patching = require("lib/patching")
local rng = require("lib/random/rng")

local planetary_mechanics_spec = {
}

randomizations.planetary_tiles = function(id)
    local planets_list = {
        "aquilo",
        "fulgora",
        "gleba",
        -- Exclude nauvis
        --"nauvis",
        "vulcanus",
        "extras"
    }

    local fluid_mechanic_to_tiles = {
        ["ammonia-ocean"] = {
            shallow = {
                "brash-ice"
            },
            deep = {
                "ammoniacal-ocean",
                "ammoniacal-ocean-2"
            }
        },
        ["oilsands"] = {
            shallow = {
                "oil-ocean-shallow"
            },
            deep = {
                "oil-ocean-deep"
            }
        },
        ["shallow-water"] = {
            shallow = {
                "wetland-dead-skin",
                "wetland-green-slime",
                "wetland-light-dead-skin",
                "wetland-pink-tentacle",
                "wetland-red-tentacle",
                "wetland-light-green-slime",
                "wetland-yumako",
                "wetland-jellynut"
            },
            deep = {
                "wetland-blue-slime",
                "gleba-deep-lake"
            }
        },
        --[[["water-nauvis"] = {
            shallow = {
                "water"
            },
            deep = {
                "deepwater"
            }
        },]]
        ["lava"] = {
            -- For some reason the hotter lava is closer to the edges
            shallow = {
                "lava"
            },
            deep = {
                "lava-hot"
            }
        }
    }

    local tile_to_autoplace = {}
    for tile_name, tile in pairs(data.raw.tile) do
        tile_to_autoplace[tile_name] = table.deepcopy(tile.autoplace)
    end

    local planet_to_fluid_mechanic = {
        aquilo = "ammonia-ocean",
        fulgora = "oilsands",
        gleba = "shallow-water",
        -- I think I like the idea of the tile changes being a surprise actually, and balancing water-less nauvis would be so hard
        --nauvis = "water-nauvis",
        vulcanus = "lava"
    }
    local fluid_mechanic_to_planet = {}
    for planet, mechanic_id in pairs(planet_to_fluid_mechanic) do
        fluid_mechanic_to_planet[mechanic_id] = planet
    end

    for _, tile_spec in pairs(fluid_mechanic_to_tiles) do
        for _, tile_list in pairs(tile_spec) do
            for _, tile_name in pairs(tile_list) do
                -- Set the autoplace to nil
                data.raw.tile[tile_name].autoplace = nil

                -- Remove it from spawning on this planet
                for _, planet in pairs(data.raw.planet) do
                    planet.map_gen_settings.autoplace_settings.tile.settings[tile_name] = nil
                end
            end
        end
    end
    -- Account for special water controls
    --data.raw.planet.nauvis.map_gen_settings.autoplace_controls.water = nil
    data.raw.planet.gleba.map_gen_settings.autoplace_controls.gleba_water = nil

    local mechanics_to_planet = {}
    local old_fluid_mechanics_list = {}
    for _, mechanic_id in pairs(planet_to_fluid_mechanic) do
        table.insert(old_fluid_mechanics_list, mechanic_id)
    end
    local new_fluid_mechanics_list = table.deepcopy(old_fluid_mechanics_list)





    -- Shuffle
    --[=[rng.shuffle(rng.key({id = id}), new_fluid_mechanics_list)
    for i = 1, #old_fluid_mechanics_list do
        local old_mechanic = old_fluid_mechanics_list[i]
        local new_planet = fluid_mechanic_to_planet[new_fluid_mechanics_list[i]]
        mechanics_to_planet[old_mechanic] = new_planet
    end]=]

    -- Custom "shuffle" for testing
    mechanics_to_planet["ammonia-ocean"] = "fulgora"
    mechanics_to_planet["oilsands"] = "aquilo"
    mechanics_to_planet["shallow-water"] = "gleba"
    mechanics_to_planet["lava"] = "vulcanus"








    -- Keep track of whether a tile's autoplace has been modified
    -- Used to see if we already raised fulgora tiles
    local already_modified_tile_autoplace = {}
    local noise_layer_to_use = 12345
    for mechanic_id, tile_spec in pairs(fluid_mechanic_to_tiles) do
        local new_planet = mechanics_to_planet[mechanic_id]

        for tile_type, tile_list in pairs(tile_spec) do
            -- Transfer so this tile's autoplace is same as the new planet for its old mechanic
            local tile_list_to_replace = fluid_mechanic_to_tiles[planet_to_fluid_mechanic[new_planet]][tile_type]
            for ind = 1, #tile_list do
                local curr_tile_name = tile_list[((ind - 1) % (#tile_list)) + 1]
                local curr_tile = data.raw.tile[curr_tile_name]
                curr_tile.autoplace = table.deepcopy(tile_to_autoplace[tile_list_to_replace[((ind - 1) % (#tile_list_to_replace)) + 1]])
                -- If it's lava, make it a little lower on aquilo or fulgora or gleba
                local offset = 0
                if (curr_tile_name == "lava" or curr_tile_name == "lava-hot") and (new_planet == "aquilo") then
                    offset = -98.5
                elseif (curr_tile_name == "lava" or curr_tile_name == "lava-hot") and (new_planet == "fulgora") then
                    offset = -98.5

                    -- Raise the old fulgora tiles a little
                    for old_tile_name, _ in pairs(data.raw.planet[new_planet].map_gen_settings.autoplace_settings.tile.settings) do
                        if old_tile_name ~= "lava" and old_tile_name ~= "lava-hot" and not already_modified_tile_autoplace[old_tile_name] then
                            data.raw.tile[old_tile_name].autoplace.probability_expression = "clamp(" .. data.raw.tile[old_tile_name].autoplace.probability_expression .. ", -100, 100)"
                            already_modified_tile_autoplace[old_tile_name] = true
                        end
                    end

                    -- Also disable island autoplace control
                    data.raw.planet.fulgora.map_gen_settings.autoplace_controls.fulgora_islands = nil
                elseif (curr_tile_name == "lava" or curr_tile_name == "lava-hot") and (new_planet == "gleba") then
                    offset = -1
                end
                -- A little higher on vulcanus
                if new_planet == "vulcanus" then
                    offset = 0.3
                end
                if curr_tile_name == "oil-ocean-deep" or curr_tile_name == "oil-ocean-shallow" then
                    offset = 0.3
                end
                curr_tile.autoplace.probability_expression = offset .. " + basis_noise{x = x, y = y, seed0 = map_seed, seed1 = " .. noise_layer_to_use .. ", input_scale = 1 / 5, output_scale = 1 / 50} + (" .. curr_tile.autoplace.probability_expression .. ")"
                noise_layer_to_use = noise_layer_to_use + 1

                data.raw.planet[new_planet].map_gen_settings.autoplace_settings.tile.settings[curr_tile_name] = {}
            end
        end
    end

    -- Implications of Planet X having Fluid Y

    -- Aquilo - Oilsands

    -- ...

    -- Fulgora - Ammoniacal ocean

    -- Turn ammonia and solid fuel into crude oil instead
    patching.replace_ing_or_result(data.raw.recipe["solid-fuel-from-ammonia"].ingredients, "fluid", "crude-oil", {
        type = "item",
        name = "solid-fuel",
        amount = 1
    })
    patching.replace_ing_or_result(data.raw.recipe["solid-fuel-from-ammonia"].results, "item", "solid-fuel", {
        type = "fluid",
        name = "crude-oil",
        amount = 6
    })
    data.raw.recipe["solid-fuel-from-ammonia"].localised_name = "Solid fuel recycling"
    -- Turn rocket fuel into ammonia
    -- TODO: Should I change productivity bonus tech that now also applies to this ammonia recipe?
    data.raw.recipe["ammonia-rocket-fuel"].ingredients = {
        {
            type = "item",
            name = "rocket-fuel",
            amount = 1
        }
    }
    data.raw.recipe["ammonia-rocket-fuel"].results = {
        {
            type = "fluid",
            name = "ammonia",
            amount = 1000
        }
    }
    data.raw.recipe["ammonia-rocket-fuel"].localised_name = "Ammonia unpacking"
    -- Change recipe unlocks
    patching.remove_recipe_unlock(data.raw.technology["planet-discovery-aquilo"], "ammoniacal-solution-separation")
    table.insert(data.raw.technology["planet-discovery-fulgora"], {
        type = "unlock-recipe",
        recipe = "ammoniacal-solution-separation"
    })
    patching.remove_recipe_unlock(data.raw.technology["planet-discovery-aquilo"], "solid-fuel-from-ammonia")
    table.insert(data.raw.technology["planet-discovery-fulgora"], {
        type = "unlock-recipe",
        recipe = "solid-fuel-from-ammonia"
    })
    patching.remove_recipe_unlock(data.raw.technology["planet-discovery-aquilo"], "ice-platform")
    table.insert(data.raw.technology["planet-discovery-fulgora"], {
        type = "unlock-recipe",
        recipe = "ice-platform"
    })






    log(serpent.block(mechanics_to_planet))
end
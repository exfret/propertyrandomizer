-- Reachability-primed Givens recipe proof of concept.
-- Every transformed one-result recipe uses only ingredients whose
-- original production-reachability rank is strictly earlier than its result.
-- Multi-result recipes are unchanged in this POC.
-- NOTE: fractional item ingredient amounts are intentionally NOT repaired yet.

return {
    metadata = {
        format = "propertyrandomizer-givens-recipe-poc-topology-primed-v1",
        source = "factorio-current(20260818-034039).log",
        seed = 20260817,
        transformed_recipes = 186,
        unchanged_recipes = 16,
        production_reachable_materials = 195,
    },
    recipes = {
        ["accumulator"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "battery", amount = 2.53476513755},
                {type = "item", name = "steel-plate", amount = 1.2357446539},
                {type = "item", name = "iron-plate", amount = 8.25227498906},
            },
            results = {
                {type = "item", name = "accumulator", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: battery"] = 4,
                    ["item: iron-plate"] = 1,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["active-provider-chest"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-chest", amount = 0.381944803241},
                {type = "item", name = "steam-turbine", amount = 0.103987151055},
                {type = "item", name = "stone-furnace", amount = 9.38842837466},
                {type = "item", name = "rocket", amount = 4.74789924802},
            },
            results = {
                {type = "item", name = "active-provider-chest", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: rocket"] = 4,
                    ["item: steam-turbine"] = 3,
                    ["item: steel-chest"] = 3,
                    ["item: stone-furnace"] = 1,
                },
            },
        },
        ["advanced-circuit"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "plastic-bar", amount = 4.37143691515},
                {type = "item", name = "iron-gear-wheel", amount = 1.62840734579},
                {type = "item", name = "electronic-circuit", amount = 0.973810169035},
            },
            results = {
                {type = "item", name = "advanced-circuit", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: electronic-circuit"] = 3,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: plastic-bar"] = 2,
                },
            },
        },
        ["advanced-oil-processing"] = {
            mode = "unchanged",
            reason = "multi-result or unsupported/unranked recipe",
            ingredients = {
                {type = "fluid", name = "crude-oil", amount = 100},
                {type = "fluid", name = "water", amount = 50},
            },
            results = {
                {type = "fluid", name = "heavy-oil", amount = 25},
                {type = "fluid", name = "light-oil", amount = 45},
                {type = "fluid", name = "petroleum-gas", amount = 55},
            },
        },
        ["arithmetic-combinator"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "electronic-circuit", amount = 3.18738913931},
                {type = "item", name = "iron-gear-wheel", amount = 3.31487471441},
                {type = "item", name = "iron-plate", amount = 1.81572158491},
            },
            results = {
                {type = "item", name = "arithmetic-combinator", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: electronic-circuit"] = 3,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: iron-plate"] = 1,
                },
            },
        },
        ["artillery-shell"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "electric-engine-unit", amount = 1.59209507299},
                {type = "item", name = "explosive-cannon-shell", amount = 1.87737564098},
                {type = "item", name = "steel-plate", amount = 4.81210812967},
                {type = "item", name = "radar", amount = 0.469343910246},
            },
            results = {
                {type = "item", name = "artillery-shell", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: electric-engine-unit"] = 4,
                    ["item: explosive-cannon-shell"] = 4,
                    ["item: radar"] = 4,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["artillery-turret"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 35.3509003024},
                {type = "item", name = "iron-plate", amount = 150.725591625},
                {type = "item", name = "advanced-circuit", amount = 11.7836334341},
                {type = "item", name = "barrel", amount = 18.7344463516},
                {type = "item", name = "solid-fuel", amount = 142.604048604},
            },
            results = {
                {type = "item", name = "artillery-turret", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: advanced-circuit"] = 4,
                    ["item: barrel"] = 3,
                    ["item: iron-plate"] = 1,
                    ["item: solid-fuel"] = 2,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["artillery-wagon"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "iron-plate", amount = 632.256901795},
                {type = "item", name = "engine-unit", amount = 23.9728061679},
                {type = "item", name = "electronic-circuit", amount = 54.5689666114},
                {type = "item", name = "copper-ore", amount = 324.806664279},
                {type = "item", name = "steel-plate", amount = 14.9830038549},
                {type = "item", name = "advanced-circuit", amount = 7.49150192747},
            },
            results = {
                {type = "item", name = "artillery-wagon", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: advanced-circuit"] = 4,
                    ["item: copper-ore"] = 0,
                    ["item: electronic-circuit"] = 3,
                    ["item: engine-unit"] = 3,
                    ["item: iron-plate"] = 1,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["assembling-machine-1"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "iron-gear-wheel", amount = 8.92784950211},
                {type = "item", name = "iron-plate", amount = 8.75205268898},
                {type = "item", name = "steel-plate", amount = 0.177095556388},
            },
            results = {
                {type = "item", name = "assembling-machine-1", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: iron-gear-wheel"] = 2,
                    ["item: iron-plate"] = 1,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["assembling-machine-2"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steam-turbine", amount = 0.124503328199},
                {type = "item", name = "assembling-machine-1", amount = 0.765538158674},
                {type = "item", name = "steel-plate", amount = 1.53107631735},
                {type = "item", name = "electronic-circuit", amount = 2.29661447602},
                {type = "item", name = "advanced-circuit", amount = 0.0392303764186},
            },
            results = {
                {type = "item", name = "assembling-machine-2", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: advanced-circuit"] = 4,
                    ["item: assembling-machine-1"] = 4,
                    ["item: electronic-circuit"] = 3,
                    ["item: steam-turbine"] = 3,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["assembling-machine-3"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "speed-module", amount = 2.73186786},
                {type = "fluid", name = "petroleum-gas", amount = 1954.34932666},
                {type = "item", name = "copper-cable", amount = 168.107293578},
            },
            results = {
                {type = "item", name = "assembling-machine-3", amount = 1},
            },
            topology = {
                output_rank = 6,
                ingredient_ranks = {
                    ["fluid: petroleum-gas"] = 1,
                    ["item: copper-cable"] = 2,
                    ["item: speed-module"] = 5,
                },
            },
        },
        ["atomic-bomb"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "processing-unit", amount = 5.91116888368},
                {type = "item", name = "fluid-wagon", amount = 2.73891602491},
                {type = "item", name = "uranium-235", amount = 14.9410356624},
                {type = "fluid", name = "heavy-oil", amount = 2193.29657533},
            },
            results = {
                {type = "item", name = "atomic-bomb", amount = 1},
            },
            topology = {
                output_rank = 6,
                ingredient_ranks = {
                    ["fluid: heavy-oil"] = 1,
                    ["item: fluid-wagon"] = 4,
                    ["item: processing-unit"] = 5,
                    ["item: uranium-235"] = 5,
                },
            },
        },
        ["automation-science-pack"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 0.282510603997},
                {type = "item", name = "iron-gear-wheel", amount = 0.425581877387},
                {type = "item", name = "copper-plate", amount = 0.371366046239},
            },
            results = {
                {type = "item", name = "automation-science-pack", amount = 1},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["item: copper-plate"] = 1,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["barrel"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 0.976539756776},
                {type = "item", name = "iron-plate", amount = 0.165751718433},
            },
            results = {
                {type = "item", name = "barrel", amount = 1},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["item: iron-plate"] = 1,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["basic-oil-processing"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "fluid", name = "crude-oil", amount = 100},
            },
            results = {
                {type = "fluid", name = "petroleum-gas", amount = 45},
            },
            topology = {
                output_rank = 1,
                ingredient_ranks = {
                    ["fluid: crude-oil"] = 0,
                },
            },
        },
        ["battery"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 0.468007560284},
                {type = "fluid", name = "sulfuric-acid", amount = 7.56197137636},
                {type = "item", name = "iron-plate", amount = 0.378098568818},
                {type = "item", name = "copper-plate", amount = 0.378098568818},
            },
            results = {
                {type = "item", name = "battery", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["fluid: sulfuric-acid"] = 3,
                    ["item: copper-plate"] = 1,
                    ["item: iron-plate"] = 1,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["battery-equipment"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 6.37536567383},
                {type = "item", name = "iron-gear-wheel", amount = 14.5900629108},
                {type = "item", name = "battery", amount = 3.4991378858},
            },
            results = {
                {type = "item", name = "battery-equipment", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: battery"] = 4,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["battery-mk2-equipment"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "processing-unit", amount = 9.28472813728},
                {type = "item", name = "iron-gear-wheel", amount = 270.487801215},
                {type = "item", name = "battery-equipment", amount = 5.65035719032},
                {type = "item", name = "electronic-circuit", amount = 162.292680729},
            },
            results = {
                {type = "item", name = "battery-mk2-equipment", amount = 1},
            },
            topology = {
                output_rank = 6,
                ingredient_ranks = {
                    ["item: battery-equipment"] = 5,
                    ["item: electronic-circuit"] = 3,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: processing-unit"] = 5,
                },
            },
        },
        ["beacon"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "fluid", name = "heavy-oil", amount = 1410.38366894},
                {type = "item", name = "advanced-circuit", amount = 6.68008824684},
                {type = "item", name = "steel-plate", amount = 8.95935202215},
                {type = "item", name = "firearm-magazine", amount = 11.2386157975},
                {type = "item", name = "copper-plate", amount = 47.9479273064},
            },
            results = {
                {type = "item", name = "beacon", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["fluid: heavy-oil"] = 1,
                    ["item: advanced-circuit"] = 4,
                    ["item: copper-plate"] = 1,
                    ["item: firearm-magazine"] = 2,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["belt-immunity-equipment"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "pump", amount = 2.60824594572},
                {type = "item", name = "advanced-circuit", amount = 3.14213295268},
                {type = "item", name = "flamethrower", amount = 0.582300973486},
            },
            results = {
                {type = "item", name = "belt-immunity-equipment", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: advanced-circuit"] = 4,
                    ["item: flamethrower"] = 3,
                    ["item: pump"] = 4,
                },
            },
        },
        ["big-electric-pole"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "iron-stick", amount = 29.5997529187},
                {type = "item", name = "steel-plate", amount = 1.83480543768},
                {type = "item", name = "copper-cable", amount = 14.7998764593},
            },
            results = {
                {type = "item", name = "big-electric-pole", amount = 1},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["item: copper-cable"] = 2,
                    ["item: iron-stick"] = 2,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["boiler"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "pipe", amount = 4},
                {type = "item", name = "stone-furnace", amount = 1},
            },
            results = {
                {type = "item", name = "boiler", amount = 1},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["item: pipe"] = 2,
                    ["item: stone-furnace"] = 1,
                },
            },
        },
        ["buffer-chest"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-chest", amount = 1.18864408794},
                {type = "item", name = "electronic-circuit", amount = 3.56593226381},
            },
            results = {
                {type = "item", name = "buffer-chest", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: electronic-circuit"] = 3,
                    ["item: steel-chest"] = 3,
                },
            },
        },
        ["bulk-inserter"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "oil-refinery", amount = 0.235142633836},
                {type = "item", name = "electronic-circuit", amount = 9.77869068896},
                {type = "item", name = "iron-gear-wheel", amount = 6.96251322062},
                {type = "item", name = "steel-plate", amount = 1.53061327373},
                {type = "item", name = "fast-inserter", amount = 0.620929303932},
            },
            results = {
                {type = "item", name = "bulk-inserter", amount = 1},
            },
            topology = {
                output_rank = 6,
                ingredient_ranks = {
                    ["item: electronic-circuit"] = 3,
                    ["item: fast-inserter"] = 5,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: oil-refinery"] = 4,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["burner-inserter"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "fluid", name = "petroleum-gas", amount = 32.8193558672},
                {type = "item", name = "iron-plate", amount = 1.27151837298},
            },
            results = {
                {type = "item", name = "burner-inserter", amount = 1},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["fluid: petroleum-gas"] = 1,
                    ["item: iron-plate"] = 1,
                },
            },
        },
        ["burner-mining-drill"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "copper-plate", amount = 3.96490076692},
                {type = "item", name = "iron-gear-wheel", amount = 1.59328160641},
                {type = "item", name = "steel-plate", amount = 0.396490076692},
                {type = "item", name = "iron-plate", amount = 1.59328160641},
            },
            results = {
                {type = "item", name = "burner-mining-drill", amount = 1},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["item: copper-plate"] = 1,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: iron-plate"] = 1,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["cannon-shell"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "medium-electric-pole", amount = 0.442150740096},
                {type = "item", name = "steel-plate", amount = 0.526575951481},
                {type = "item", name = "engine-unit", amount = 0.247382191437},
                {type = "item", name = "piercing-rounds-magazine", amount = 0.215917936865},
            },
            results = {
                {type = "item", name = "cannon-shell", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: engine-unit"] = 3,
                    ["item: medium-electric-pole"] = 3,
                    ["item: piercing-rounds-magazine"] = 3,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["car"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "engine-unit", amount = 4.4926573856},
                {type = "item", name = "steel-plate", amount = 6.91260073828},
                {type = "item", name = "iron-plate", amount = 40.2219869501},
                {type = "item", name = "grenade", amount = 1.484008065},
            },
            results = {
                {type = "item", name = "car", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: engine-unit"] = 3,
                    ["item: grenade"] = 2,
                    ["item: iron-plate"] = 1,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["cargo-landing-pad"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "processing-unit", amount = 6.48881726547},
                {type = "item", name = "steel-plate", amount = 44.6345777624},
                {type = "item", name = "engine-unit", amount = 17.4638524485},
                {type = "item", name = "iron-gear-wheel", amount = 59.2346859111},
            },
            results = {
                {type = "item", name = "cargo-landing-pad", amount = 1},
            },
            topology = {
                output_rank = 6,
                ingredient_ranks = {
                    ["item: engine-unit"] = 3,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: processing-unit"] = 5,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["cargo-wagon"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "plastic-bar", amount = 77.3477105626},
                {type = "item", name = "copper-cable", amount = 69.9317856114},
                {type = "item", name = "iron-plate", amount = 32.8079871041},
                {type = "item", name = "steel-plate", amount = 3.52494196394},
            },
            results = {
                {type = "item", name = "cargo-wagon", amount = 1},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["item: copper-cable"] = 2,
                    ["item: iron-plate"] = 1,
                    ["item: plastic-bar"] = 2,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["centrifuge"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "advanced-circuit", amount = 68.2676276955},
                {type = "item", name = "steel-chest", amount = 10.6478584662},
                {type = "item", name = "steel-plate", amount = 31.0252947246},
                {type = "item", name = "iron-gear-wheel", amount = 62.0505894492},
                {type = "item", name = "electronic-circuit", amount = 31.9435753986},
            },
            results = {
                {type = "item", name = "centrifuge", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: advanced-circuit"] = 4,
                    ["item: electronic-circuit"] = 3,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: steel-chest"] = 3,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["chemical-plant"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 4.49518325764},
                {type = "fluid", name = "crude-oil", amount = 610.952926882},
                {type = "item", name = "iron-gear-wheel", amount = 3.99666784398},
                {type = "item", name = "pipe", amount = 3.99666784398},
                {type = "item", name = "electronic-circuit", amount = 1.35409457597},
            },
            results = {
                {type = "item", name = "chemical-plant", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["fluid: crude-oil"] = 0,
                    ["item: electronic-circuit"] = 3,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: pipe"] = 2,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["chemical-science-pack"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "advanced-circuit", amount = 1.44480893045},
                {type = "fluid", name = "petroleum-gas", amount = 276.163406347},
                {type = "item", name = "underground-belt", amount = 1.54261527064},
                {type = "item", name = "engine-unit", amount = 1.11508448755},
            },
            results = {
                {type = "item", name = "chemical-science-pack", amount = 2},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["fluid: petroleum-gas"] = 1,
                    ["item: advanced-circuit"] = 4,
                    ["item: engine-unit"] = 3,
                    ["item: underground-belt"] = 4,
                },
            },
        },
        ["cliff-explosives"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "barrel", amount = 1.23288331914},
                {type = "item", name = "explosives", amount = 6.77333245379},
                {type = "item", name = "grenade", amount = 0.677333245379},
                {type = "item", name = "pipe", amount = 3.75481933963},
            },
            results = {
                {type = "item", name = "cliff-explosives", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: barrel"] = 3,
                    ["item: explosives"] = 3,
                    ["item: grenade"] = 2,
                    ["item: pipe"] = 2,
                },
            },
        },
        ["cluster-grenade"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "grenade", amount = 3.80709395867},
                {type = "item", name = "light-armor", amount = 0.855343267986},
                {type = "item", name = "steel-plate", amount = 2.71935282762},
                {type = "item", name = "barrel", amount = 2.33942938001},
            },
            results = {
                {type = "item", name = "cluster-grenade", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: barrel"] = 3,
                    ["item: grenade"] = 2,
                    ["item: light-armor"] = 2,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["coal-liquefaction"] = {
            mode = "unchanged",
            reason = "multi-result or unsupported/unranked recipe",
            ingredients = {
                {type = "fluid", name = "heavy-oil", amount = 25},
                {type = "fluid", name = "steam", amount = 50},
                {type = "item", name = "coal", amount = 10},
            },
            results = {
                {type = "fluid", name = "heavy-oil", amount = 90},
                {type = "fluid", name = "light-oil", amount = 20},
                {type = "fluid", name = "petroleum-gas", amount = 10},
            },
        },
        ["combat-shotgun"] = {
            mode = "unchanged",
            reason = "multi-result or unsupported/unranked recipe",
            ingredients = {
                {type = "item", name = "copper-plate", amount = 10},
                {type = "item", name = "iron-gear-wheel", amount = 5},
                {type = "item", name = "steel-plate", amount = 15},
                {type = "item", name = "wood", amount = 10},
            },
            results = {
                {type = "item", name = "combat-shotgun", amount = 1},
            },
        },
        ["concrete"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "stone", amount = 12.7300442727},
                {type = "item", name = "stone-brick", amount = 1.49462549013},
                {type = "fluid", name = "water", amount = 157.192952529},
                {type = "item", name = "iron-ore", amount = 1.57192952529},
            },
            results = {
                {type = "item", name = "concrete", amount = 10},
            },
            topology = {
                output_rank = 2,
                ingredient_ranks = {
                    ["fluid: water"] = 0,
                    ["item: iron-ore"] = 0,
                    ["item: stone"] = 0,
                    ["item: stone-brick"] = 1,
                },
            },
        },
        ["constant-combinator"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "electronic-circuit", amount = 1.3575273559},
                {type = "item", name = "steel-furnace", amount = 0.059069034122},
                {type = "item", name = "copper-cable", amount = 3.39381838975},
            },
            results = {
                {type = "item", name = "constant-combinator", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: copper-cable"] = 2,
                    ["item: electronic-circuit"] = 3,
                    ["item: steel-furnace"] = 3,
                },
            },
        },
        ["construction-robot"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "flying-robot-frame", amount = 0.4960419968},
                {type = "fluid", name = "lubricant", amount = 113.689267722},
                {type = "item", name = "barrel", amount = 2.27378535443},
            },
            results = {
                {type = "item", name = "construction-robot", amount = 1},
            },
            topology = {
                output_rank = 6,
                ingredient_ranks = {
                    ["fluid: lubricant"] = 2,
                    ["item: barrel"] = 3,
                    ["item: flying-robot-frame"] = 5,
                },
            },
        },
        ["copper-cable"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "copper-plate", amount = 1},
            },
            results = {
                {type = "item", name = "copper-cable", amount = 2},
            },
            topology = {
                output_rank = 2,
                ingredient_ranks = {
                    ["item: copper-plate"] = 1,
                },
            },
        },
        ["copper-plate"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "copper-ore", amount = 1},
            },
            results = {
                {type = "item", name = "copper-plate", amount = 1},
            },
            topology = {
                output_rank = 1,
                ingredient_ranks = {
                    ["item: copper-ore"] = 0,
                },
            },
        },
        ["crude-oil-barrel"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "barrel", amount = 0.618325125969},
                {type = "item", name = "pipe", amount = 1.70265918575},
                {type = "item", name = "copper-plate", amount = 2.14258637491},
            },
            results = {
                {type = "item", name = "crude-oil-barrel", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: barrel"] = 3,
                    ["item: copper-plate"] = 1,
                    ["item: pipe"] = 2,
                },
            },
        },
        ["decider-combinator"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "electronic-circuit", amount = 2.81161407886},
                {type = "item", name = "transport-belt", amount = 3.87331615167},
                {type = "item", name = "iron-plate", amount = 3.71987864918},
            },
            results = {
                {type = "item", name = "decider-combinator", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: electronic-circuit"] = 3,
                    ["item: iron-plate"] = 1,
                    ["item: transport-belt"] = 3,
                },
            },
        },
        ["defender-capsule"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "electronic-circuit", amount = 5.53201169708},
                {type = "item", name = "piercing-rounds-magazine", amount = 1.10355748335},
                {type = "item", name = "iron-gear-wheel", amount = 4.10068980003},
                {type = "item", name = "iron-plate", amount = 6.5754370593},
            },
            results = {
                {type = "item", name = "defender-capsule", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: electronic-circuit"] = 3,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: iron-plate"] = 1,
                    ["item: piercing-rounds-magazine"] = 3,
                },
            },
        },
        ["destroyer-capsule"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "distractor-capsule", amount = 1.79226574711},
                {type = "item", name = "barrel", amount = 48.364178316},
                {type = "item", name = "electronic-circuit", amount = 64.863506802},
            },
            results = {
                {type = "item", name = "destroyer-capsule", amount = 1},
            },
            topology = {
                output_rank = 6,
                ingredient_ranks = {
                    ["item: barrel"] = 3,
                    ["item: distractor-capsule"] = 5,
                    ["item: electronic-circuit"] = 3,
                },
            },
        },
        ["discharge-defense-equipment"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 197.211130005},
                {type = "item", name = "laser-turret", amount = 3.57732340972},
                {type = "item", name = "advanced-circuit", amount = 43.7678953705},
                {type = "item", name = "accumulator", amount = 15.1234069271},
            },
            results = {
                {type = "item", name = "discharge-defense-equipment", amount = 1},
            },
            topology = {
                output_rank = 6,
                ingredient_ranks = {
                    ["item: accumulator"] = 5,
                    ["item: advanced-circuit"] = 4,
                    ["item: laser-turret"] = 5,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["display-panel"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "electronic-circuit", amount = 0.827686086651},
                {type = "item", name = "iron-plate", amount = 1.08474454755},
                {type = "item", name = "iron-gear-wheel", amount = 0.214215384082},
            },
            results = {
                {type = "item", name = "display-panel", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: electronic-circuit"] = 3,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: iron-plate"] = 1,
                },
            },
        },
        ["distractor-capsule"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "electric-mining-drill", amount = 2.92378613192},
                {type = "item", name = "stone-furnace", amount = 34.3951723382},
                {type = "item", name = "defender-capsule", amount = 1.30132217271},
            },
            results = {
                {type = "item", name = "distractor-capsule", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: defender-capsule"] = 4,
                    ["item: electric-mining-drill"] = 4,
                    ["item: stone-furnace"] = 1,
                },
            },
        },
        ["efficiency-module"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "advanced-circuit", amount = 3.73795623656},
                {type = "item", name = "steel-plate", amount = 2.88277064353},
                {type = "item", name = "electronic-circuit", amount = 3.73795623656},
            },
            results = {
                {type = "item", name = "efficiency-module", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: advanced-circuit"] = 4,
                    ["item: electronic-circuit"] = 3,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["efficiency-module-2"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "processing-unit", amount = 3.49328079573},
                {type = "item", name = "efficiency-module", amount = 2.30069560906},
                {type = "item", name = "splitter", amount = 6.0296809828},
                {type = "item", name = "energy-shield-equipment", amount = 1.2348225688},
            },
            results = {
                {type = "item", name = "efficiency-module-2", amount = 1},
            },
            topology = {
                output_rank = 6,
                ingredient_ranks = {
                    ["item: efficiency-module"] = 5,
                    ["item: energy-shield-equipment"] = 5,
                    ["item: processing-unit"] = 5,
                    ["item: splitter"] = 4,
                },
            },
        },
        ["efficiency-module-3"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "rail-signal", amount = 182.841147131},
                {type = "item", name = "efficiency-module-2", amount = 1.25988262723},
                {type = "item", name = "steel-plate", amount = 100.018313103},
                {type = "item", name = "iron-gear-wheel", amount = 268.329496901},
            },
            results = {
                {type = "item", name = "efficiency-module-3", amount = 1},
            },
            topology = {
                output_rank = 7,
                ingredient_ranks = {
                    ["item: efficiency-module-2"] = 6,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: rail-signal"] = 4,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["electric-engine-unit"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "engine-unit", amount = 0.824440048133},
                {type = "item", name = "electronic-circuit", amount = 1.64888009627},
                {type = "item", name = "steel-plate", amount = 0.566965151064},
                {type = "fluid", name = "lubricant", amount = 12.366600722},
            },
            results = {
                {type = "item", name = "electric-engine-unit", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["fluid: lubricant"] = 2,
                    ["item: electronic-circuit"] = 3,
                    ["item: engine-unit"] = 3,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["electric-furnace"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 9.11073205129},
                {type = "item", name = "advanced-circuit", amount = 4.04534270972},
                {type = "item", name = "solar-panel", amount = 0.181979262478},
                {type = "item", name = "assembling-machine-1", amount = 0.462758029275},
            },
            results = {
                {type = "item", name = "electric-furnace", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: advanced-circuit"] = 4,
                    ["item: assembling-machine-1"] = 4,
                    ["item: solar-panel"] = 4,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["electric-mining-drill"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "iron-gear-wheel", amount = 5.39491507605},
                {type = "item", name = "iron-plate", amount = 10.7898301521},
                {type = "item", name = "electronic-circuit", amount = 2.4987377145},
            },
            results = {
                {type = "item", name = "electric-mining-drill", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: electronic-circuit"] = 3,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: iron-plate"] = 1,
                },
            },
        },
        ["electronic-circuit"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "fluid", name = "petroleum-gas", amount = 20.1617217019},
                {type = "item", name = "copper-cable", amount = 1.73425109982},
                {type = "item", name = "iron-plate", amount = 0.578083699939},
            },
            results = {
                {type = "item", name = "electronic-circuit", amount = 1},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["fluid: petroleum-gas"] = 1,
                    ["item: copper-cable"] = 2,
                    ["item: iron-plate"] = 1,
                },
            },
        },
        ["empty-crude-oil-barrel"] = {
            mode = "unchanged",
            reason = "multi-result or unsupported/unranked recipe",
            ingredients = {
                {type = "item", name = "crude-oil-barrel", amount = 1},
            },
            results = {
                {type = "fluid", name = "crude-oil", amount = 50},
                {type = "item", name = "barrel", amount = 1},
            },
        },
        ["empty-heavy-oil-barrel"] = {
            mode = "unchanged",
            reason = "multi-result or unsupported/unranked recipe",
            ingredients = {
                {type = "item", name = "heavy-oil-barrel", amount = 1},
            },
            results = {
                {type = "fluid", name = "heavy-oil", amount = 50},
                {type = "item", name = "barrel", amount = 1},
            },
        },
        ["empty-light-oil-barrel"] = {
            mode = "unchanged",
            reason = "multi-result or unsupported/unranked recipe",
            ingredients = {
                {type = "item", name = "light-oil-barrel", amount = 1},
            },
            results = {
                {type = "fluid", name = "light-oil", amount = 50},
                {type = "item", name = "barrel", amount = 1},
            },
        },
        ["empty-lubricant-barrel"] = {
            mode = "unchanged",
            reason = "multi-result or unsupported/unranked recipe",
            ingredients = {
                {type = "item", name = "lubricant-barrel", amount = 1},
            },
            results = {
                {type = "fluid", name = "lubricant", amount = 50},
                {type = "item", name = "barrel", amount = 1},
            },
        },
        ["empty-petroleum-gas-barrel"] = {
            mode = "unchanged",
            reason = "multi-result or unsupported/unranked recipe",
            ingredients = {
                {type = "item", name = "petroleum-gas-barrel", amount = 1},
            },
            results = {
                {type = "fluid", name = "petroleum-gas", amount = 50},
                {type = "item", name = "barrel", amount = 1},
            },
        },
        ["empty-sulfuric-acid-barrel"] = {
            mode = "unchanged",
            reason = "multi-result or unsupported/unranked recipe",
            ingredients = {
                {type = "item", name = "sulfuric-acid-barrel", amount = 1},
            },
            results = {
                {type = "fluid", name = "sulfuric-acid", amount = 50},
                {type = "item", name = "barrel", amount = 1},
            },
        },
        ["empty-water-barrel"] = {
            mode = "unchanged",
            reason = "multi-result or unsupported/unranked recipe",
            ingredients = {
                {type = "item", name = "water-barrel", amount = 1},
            },
            results = {
                {type = "fluid", name = "water", amount = 50},
                {type = "item", name = "barrel", amount = 1},
            },
        },
        ["energy-shield-equipment"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "transport-belt", amount = 26.4507175583},
                {type = "item", name = "explosive-cannon-shell", amount = 2.22903106043},
                {type = "item", name = "steel-plate", amount = 5.69950307349},
            },
            results = {
                {type = "item", name = "energy-shield-equipment", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: explosive-cannon-shell"] = 4,
                    ["item: steel-plate"] = 2,
                    ["item: transport-belt"] = 3,
                },
            },
        },
        ["energy-shield-mk2-equipment"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "energy-shield-equipment", amount = 6.7342645413},
                {type = "item", name = "processing-unit", amount = 4.28601904496},
                {type = "item", name = "iron-gear-wheel", amount = 158.721022199},
                {type = "item", name = "battery-equipment", amount = 3.31560412341},
            },
            results = {
                {type = "item", name = "energy-shield-mk2-equipment", amount = 1},
            },
            topology = {
                output_rank = 6,
                ingredient_ranks = {
                    ["item: battery-equipment"] = 5,
                    ["item: energy-shield-equipment"] = 5,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: processing-unit"] = 5,
                },
            },
        },
        ["engine-unit"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "pipe", amount = 8.84251968504},
            },
            results = {
                {type = "item", name = "engine-unit", amount = 1},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["item: pipe"] = 2,
                },
            },
        },
        ["exoskeleton-equipment"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "processing-unit", amount = 6.00217637931},
                {type = "item", name = "iron-gear-wheel", amount = 185.483930953},
                {type = "item", name = "electric-engine-unit", amount = 18.0065291379},
                {type = "item", name = "requester-chest", amount = 4.6900186642},
            },
            results = {
                {type = "item", name = "exoskeleton-equipment", amount = 1},
            },
            topology = {
                output_rank = 6,
                ingredient_ranks = {
                    ["item: electric-engine-unit"] = 4,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: processing-unit"] = 5,
                    ["item: requester-chest"] = 5,
                },
            },
        },
        ["explosive-cannon-shell"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 1.33368690424},
                {type = "item", name = "automation-science-pack", amount = 1.5142827662},
                {type = "item", name = "plastic-bar", amount = 1.33368690424},
                {type = "item", name = "explosives", amount = 1.12948038},
            },
            results = {
                {type = "item", name = "explosive-cannon-shell", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: automation-science-pack"] = 3,
                    ["item: explosives"] = 3,
                    ["item: plastic-bar"] = 2,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["explosive-rocket"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steam-turbine", amount = 0.0115787773672},
                {type = "item", name = "rocket", amount = 0.528669819271},
                {type = "item", name = "stone", amount = 6.09543667354},
            },
            results = {
                {type = "item", name = "explosive-rocket", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: rocket"] = 4,
                    ["item: steam-turbine"] = 3,
                    ["item: stone"] = 0,
                },
            },
        },
        ["explosive-uranium-cannon-shell"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "energy-shield-equipment", amount = 0.0953184193842},
                {type = "item", name = "explosive-cannon-shell", amount = 0.414196482059},
                {type = "item", name = "iron-gear-wheel", amount = 2.21180737752},
            },
            results = {
                {type = "item", name = "explosive-uranium-cannon-shell", amount = 1},
            },
            topology = {
                output_rank = 6,
                ingredient_ranks = {
                    ["item: energy-shield-equipment"] = 5,
                    ["item: explosive-cannon-shell"] = 4,
                    ["item: iron-gear-wheel"] = 2,
                },
            },
        },
        ["explosives"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "sulfur", amount = 0.532026149042},
                {type = "item", name = "iron-gear-wheel", amount = 0.180540505721},
                {type = "item", name = "iron-plate", amount = 0.361081011442},
                {type = "item", name = "copper-plate", amount = 0.180540505721},
            },
            results = {
                {type = "item", name = "explosives", amount = 2},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["item: copper-plate"] = 1,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: iron-plate"] = 1,
                    ["item: sulfur"] = 2,
                },
            },
        },
        ["express-splitter"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "advanced-circuit", amount = 4.3923824318},
                {type = "fluid", name = "sulfuric-acid", amount = 328.773552631},
                {type = "item", name = "electronic-circuit", amount = 15.4435885018},
                {type = "item", name = "barrel", amount = 6.57547105261},
                {type = "item", name = "fast-splitter", amount = 0.43923824318},
            },
            results = {
                {type = "item", name = "express-splitter", amount = 1},
            },
            topology = {
                output_rank = 6,
                ingredient_ranks = {
                    ["fluid: sulfuric-acid"] = 3,
                    ["item: advanced-circuit"] = 4,
                    ["item: barrel"] = 3,
                    ["item: electronic-circuit"] = 3,
                    ["item: fast-splitter"] = 5,
                },
            },
        },
        ["express-transport-belt"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "iron-gear-wheel", amount = 7.22106576818},
                {type = "item", name = "fast-transport-belt", amount = 0.722106576818},
                {type = "item", name = "barrel", amount = 1.27053077936},
                {type = "fluid", name = "petroleum-gas", amount = 63.5265389678},
            },
            results = {
                {type = "item", name = "express-transport-belt", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["fluid: petroleum-gas"] = 1,
                    ["item: barrel"] = 3,
                    ["item: fast-transport-belt"] = 4,
                    ["item: iron-gear-wheel"] = 2,
                },
            },
        },
        ["express-underground-belt"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "long-handed-inserter", amount = 10.1437884618},
                {type = "item", name = "iron-gear-wheel", amount = 37.429485118},
                {type = "item", name = "storage-chest", amount = 0.796195709503},
                {type = "item", name = "fast-underground-belt", amount = 0.826928010246},
            },
            results = {
                {type = "item", name = "express-underground-belt", amount = 2},
            },
            topology = {
                output_rank = 6,
                ingredient_ranks = {
                    ["item: fast-underground-belt"] = 5,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: long-handed-inserter"] = 5,
                    ["item: storage-chest"] = 5,
                },
            },
        },
        ["fast-inserter"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "inserter", amount = 0.709814256126},
                {type = "item", name = "electronic-circuit", amount = 1.41962851225},
                {type = "item", name = "shotgun-shell", amount = 0.674284574982},
                {type = "item", name = "cliff-explosives", amount = 0.09806337435},
            },
            results = {
                {type = "item", name = "fast-inserter", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: cliff-explosives"] = 4,
                    ["item: electronic-circuit"] = 3,
                    ["item: inserter"] = 4,
                    ["item: shotgun-shell"] = 2,
                },
            },
        },
        ["fast-splitter"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "copper-plate", amount = 30.1801440371},
                {type = "item", name = "electronic-circuit", amount = 6.03798538609},
                {type = "item", name = "steel-plate", amount = 2.72708976991},
                {type = "item", name = "splitter", amount = 0.603798538609},
            },
            results = {
                {type = "item", name = "fast-splitter", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: copper-plate"] = 1,
                    ["item: electronic-circuit"] = 3,
                    ["item: splitter"] = 4,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["fast-transport-belt"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "gun-turret", amount = 0.108368888903},
                {type = "item", name = "iron-gear-wheel", amount = 2.2194698908},
                {type = "item", name = "sulfur", amount = 2.01064393574},
            },
            results = {
                {type = "item", name = "fast-transport-belt", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: gun-turret"] = 3,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: sulfur"] = 2,
                },
            },
        },
        ["fast-underground-belt"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "iron-gear-wheel", amount = 19.5995732958},
                {type = "item", name = "underground-belt", amount = 3.83055339706},
                {type = "item", name = "electronic-circuit", amount = 8.81043613674},
            },
            results = {
                {type = "item", name = "fast-underground-belt", amount = 2},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: electronic-circuit"] = 3,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: underground-belt"] = 4,
                },
            },
        },
        ["firearm-magazine"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "fluid", name = "petroleum-gas", amount = 34.3576708359},
                {type = "item", name = "iron-plate", amount = 1.79223406713},
            },
            results = {
                {type = "item", name = "firearm-magazine", amount = 1},
            },
            topology = {
                output_rank = 2,
                ingredient_ranks = {
                    ["fluid: petroleum-gas"] = 1,
                    ["item: iron-plate"] = 1,
                },
            },
        },
        ["fission-reactor-equipment"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "processing-unit", amount = 89.444896911},
                {type = "item", name = "defender-capsule", amount = 130.142366478},
                {type = "item", name = "steel-chest", amount = 64.5614965297},
                {type = "item", name = "electronic-circuit", amount = 872.064719201},
            },
            results = {
                {type = "item", name = "fission-reactor-equipment", amount = 1},
            },
            topology = {
                output_rank = 7,
                ingredient_ranks = {
                    ["item: defender-capsule"] = 4,
                    ["item: electronic-circuit"] = 3,
                    ["item: processing-unit"] = 5,
                    ["item: steel-chest"] = 3,
                },
            },
        },
        ["flamethrower"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 5.38514686754},
                {type = "item", name = "iron-gear-wheel", amount = 8.85687002786},
            },
            results = {
                {type = "item", name = "flamethrower", amount = 1},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["item: iron-gear-wheel"] = 2,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["flamethrower-ammo"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 4.63195136279},
                {type = "fluid", name = "crude-oil", amount = 179.743871395},
            },
            results = {
                {type = "item", name = "flamethrower-ammo", amount = 1},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["fluid: crude-oil"] = 0,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["flamethrower-turret"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 22.4441742445},
                {type = "item", name = "engine-unit", amount = 3.74069570742},
                {type = "fluid", name = "lubricant", amount = 308.016703143},
                {type = "item", name = "barrel", amount = 6.16033406285},
                {type = "item", name = "iron-gear-wheel", amount = 11.2220871222},
            },
            results = {
                {type = "item", name = "flamethrower-turret", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["fluid: lubricant"] = 2,
                    ["item: barrel"] = 3,
                    ["item: engine-unit"] = 3,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["fluid-wagon"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "electronic-circuit", amount = 21.9294898066},
                {type = "item", name = "steel-plate", amount = 8.78067034335},
                {type = "item", name = "storage-tank", amount = 0.548791896459},
                {type = "item", name = "copper-cable", amount = 32.4065943815},
                {type = "item", name = "iron-gear-wheel", amount = 5.48791896459},
            },
            results = {
                {type = "item", name = "fluid-wagon", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: copper-cable"] = 2,
                    ["item: electronic-circuit"] = 3,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: steel-plate"] = 2,
                    ["item: storage-tank"] = 3,
                },
            },
        },
        ["flying-robot-frame"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "electric-engine-unit", amount = 0.61872753625},
                {type = "item", name = "steel-plate", amount = 1.94688025445},
                {type = "item", name = "electronic-circuit", amount = 3.21560515702},
                {type = "item", name = "battery", amount = 1.26872490257},
                {type = "item", name = "iron-gear-wheel", amount = 2.62503560634},
            },
            results = {
                {type = "item", name = "flying-robot-frame", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: battery"] = 4,
                    ["item: electric-engine-unit"] = 4,
                    ["item: electronic-circuit"] = 3,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["gate"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 2.18302948138},
                {type = "fluid", name = "light-oil", amount = 67.1804686609},
                {type = "item", name = "concrete", amount = 4.91097191425},
                {type = "item", name = "stone-wall", amount = 0.447637971401},
            },
            results = {
                {type = "item", name = "gate", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["fluid: light-oil"] = 1,
                    ["item: concrete"] = 2,
                    ["item: steel-plate"] = 2,
                    ["item: stone-wall"] = 2,
                },
            },
        },
        ["grenade"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "iron-plate", amount = 3.78315653229},
                {type = "item", name = "coal", amount = 7.56631306459},
                {type = "item", name = "stone-brick", amount = 1.51606727124},
            },
            results = {
                {type = "item", name = "grenade", amount = 1},
            },
            topology = {
                output_rank = 2,
                ingredient_ranks = {
                    ["item: coal"] = 0,
                    ["item: iron-plate"] = 1,
                    ["item: stone-brick"] = 1,
                },
            },
        },
        ["gun-turret"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "iron-gear-wheel", amount = 13.9887034866},
                {type = "item", name = "iron-plate", amount = 13.6701009887},
                {type = "item", name = "copper-plate", amount = 6.83505049434},
            },
            results = {
                {type = "item", name = "gun-turret", amount = 1},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["item: copper-plate"] = 1,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: iron-plate"] = 1,
                },
            },
        },
        ["hazard-concrete"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "concrete", amount = 7.47589998381},
                {type = "item", name = "steel-plate", amount = 0.318424925119},
            },
            results = {
                {type = "item", name = "hazard-concrete", amount = 10},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["item: concrete"] = 2,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["heat-exchanger"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "copper-plate", amount = 100},
                {type = "item", name = "steel-plate", amount = 10},
                {type = "item", name = "pipe", amount = 10},
            },
            results = {
                {type = "item", name = "heat-exchanger", amount = 1},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["item: copper-plate"] = 1,
                    ["item: pipe"] = 2,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["heat-pipe"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "solid-fuel", amount = 38.3053323952},
                {type = "item", name = "steel-plate", amount = 5.01575020591},
                {type = "item", name = "concrete", amount = 21.0050322495},
            },
            results = {
                {type = "item", name = "heat-pipe", amount = 1},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["item: concrete"] = 2,
                    ["item: solid-fuel"] = 2,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["heavy-armor"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 46.0126300679},
                {type = "item", name = "copper-plate", amount = 128.17163539},
            },
            results = {
                {type = "item", name = "heavy-armor", amount = 1},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["item: copper-plate"] = 1,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["heavy-oil-barrel"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "barrel", amount = 0.766896421728},
                {type = "fluid", name = "heavy-oil", amount = 38.3448210864},
                {type = "item", name = "stone-wall", amount = 0.431457070337},
            },
            results = {
                {type = "item", name = "heavy-oil-barrel", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["fluid: heavy-oil"] = 1,
                    ["item: barrel"] = 3,
                    ["item: stone-wall"] = 2,
                },
            },
        },
        ["heavy-oil-cracking"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "fluid", name = "water", amount = 836.153846154},
            },
            results = {
                {type = "fluid", name = "light-oil", amount = 30},
            },
            topology = {
                output_rank = 1,
                ingredient_ranks = {
                    ["fluid: water"] = 0,
                },
            },
        },
        ["inserter"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "electronic-circuit", amount = 0.906138100722},
                {type = "item", name = "iron-plate", amount = 1.80461415734},
                {type = "item", name = "iron-gear-wheel", amount = 0.513314971882},
                {type = "item", name = "copper-cable", amount = 0.9820578221},
            },
            results = {
                {type = "item", name = "inserter", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: copper-cable"] = 2,
                    ["item: electronic-circuit"] = 3,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: iron-plate"] = 1,
                },
            },
        },
        ["iron-chest"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "iron-plate", amount = 7.81241147602},
                {type = "item", name = "stone", amount = 0.575271473542},
            },
            results = {
                {type = "item", name = "iron-chest", amount = 1},
            },
            topology = {
                output_rank = 2,
                ingredient_ranks = {
                    ["item: iron-plate"] = 1,
                    ["item: stone"] = 0,
                },
            },
        },
        ["iron-gear-wheel"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "iron-plate", amount = 2},
            },
            results = {
                {type = "item", name = "iron-gear-wheel", amount = 1},
            },
            topology = {
                output_rank = 2,
                ingredient_ranks = {
                    ["item: iron-plate"] = 1,
                },
            },
        },
        ["iron-plate"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "iron-ore", amount = 0.647709379782},
                {type = "item", name = "copper-ore", amount = 0.352290620218},
            },
            results = {
                {type = "item", name = "iron-plate", amount = 1},
            },
            topology = {
                output_rank = 1,
                ingredient_ranks = {
                    ["item: copper-ore"] = 0,
                    ["item: iron-ore"] = 0,
                },
            },
        },
        ["iron-stick"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "stone-brick", amount = 0.433511245336},
                {type = "item", name = "iron-plate", amount = 0.425126392055},
            },
            results = {
                {type = "item", name = "iron-stick", amount = 2},
            },
            topology = {
                output_rank = 2,
                ingredient_ranks = {
                    ["item: iron-plate"] = 1,
                    ["item: stone-brick"] = 1,
                },
            },
        },
        ["kovarex-enrichment-process"] = {
            mode = "unchanged",
            reason = "multi-result or unsupported/unranked recipe",
            ingredients = {
                {type = "item", name = "uranium-235", amount = 40},
                {type = "item", name = "uranium-238", amount = 5},
            },
            results = {
                {type = "item", name = "uranium-235", amount = 41},
                {type = "item", name = "uranium-238", amount = 2},
            },
        },
        ["lab"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "electronic-circuit", amount = 8.09016060909},
                {type = "item", name = "iron-gear-wheel", amount = 8.09016060909},
                {type = "item", name = "steel-plate", amount = 1.62882313813},
                {type = "item", name = "low-density-structure", amount = 0.173559815152},
            },
            results = {
                {type = "item", name = "lab", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: electronic-circuit"] = 3,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: low-density-structure"] = 3,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["land-mine"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-chest", amount = 0.0898114680237},
                {type = "item", name = "explosives", amount = 1.96166857702},
                {type = "item", name = "steel-plate", amount = 0.283193798952},
            },
            results = {
                {type = "item", name = "land-mine", amount = 4},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: explosives"] = 3,
                    ["item: steel-chest"] = 3,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["landfill"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "stone", amount = 50},
            },
            results = {
                {type = "item", name = "landfill", amount = 1},
            },
            topology = {
                output_rank = 1,
                ingredient_ranks = {
                    ["item: stone"] = 0,
                },
            },
        },
        ["laser-turret"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "concrete", amount = 138.812071397},
                {type = "item", name = "steel-plate", amount = 9.67187386209},
                {type = "item", name = "stone", amount = 171.523113306},
                {type = "item", name = "battery", amount = 5.80312431725},
            },
            results = {
                {type = "item", name = "laser-turret", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: battery"] = 4,
                    ["item: concrete"] = 2,
                    ["item: steel-plate"] = 2,
                    ["item: stone"] = 0,
                },
            },
        },
        ["light-armor"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "iron-plate", amount = 40},
            },
            results = {
                {type = "item", name = "light-armor", amount = 1},
            },
            topology = {
                output_rank = 2,
                ingredient_ranks = {
                    ["item: iron-plate"] = 1,
                },
            },
        },
        ["light-oil-barrel"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "barrel", amount = 0.688635687829},
                {type = "fluid", name = "light-oil", amount = 44.9840842224},
                {type = "item", name = "piercing-shotgun-shell", amount = 0.277670677996},
            },
            results = {
                {type = "item", name = "light-oil-barrel", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["fluid: light-oil"] = 1,
                    ["item: barrel"] = 3,
                    ["item: piercing-shotgun-shell"] = 3,
                },
            },
        },
        ["light-oil-cracking"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "fluid", name = "water", amount = 449.411764706},
            },
            results = {
                {type = "fluid", name = "petroleum-gas", amount = 20},
            },
            topology = {
                output_rank = 1,
                ingredient_ranks = {
                    ["fluid: water"] = 0,
                },
            },
        },
        ["locomotive"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "engine-unit", amount = 15.4523939201},
                {type = "item", name = "steel-plate", amount = 28.1488918461},
                {type = "item", name = "copper-cable", amount = 139.628964718},
                {type = "item", name = "electronic-circuit", amount = 3.81080774323},
            },
            results = {
                {type = "item", name = "locomotive", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: copper-cable"] = 2,
                    ["item: electronic-circuit"] = 3,
                    ["item: engine-unit"] = 3,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["logistic-robot"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "flying-robot-frame", amount = 0.592355926178},
                {type = "item", name = "steel-chest", amount = 0.468835629941},
                {type = "item", name = "advanced-circuit", amount = 1.6535474823},
            },
            results = {
                {type = "item", name = "logistic-robot", amount = 1},
            },
            topology = {
                output_rank = 6,
                ingredient_ranks = {
                    ["item: advanced-circuit"] = 4,
                    ["item: flying-robot-frame"] = 5,
                    ["item: steel-chest"] = 3,
                },
            },
        },
        ["logistic-science-pack"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "inserter", amount = 0.589156488799},
                {type = "item", name = "advanced-circuit", amount = 0.217046462816},
                {type = "item", name = "sulfur", amount = 1.6548133787},
            },
            results = {
                {type = "item", name = "logistic-science-pack", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: advanced-circuit"] = 4,
                    ["item: inserter"] = 4,
                    ["item: sulfur"] = 2,
                },
            },
        },
        ["long-handed-inserter"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "inserter", amount = 0.527205196797},
                {type = "item", name = "radar", amount = 0.0885602127792},
                {type = "item", name = "iron-gear-wheel", amount = 1.34116845036},
                {type = "fluid", name = "lubricant", amount = 0.628382158731},
            },
            results = {
                {type = "item", name = "long-handed-inserter", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["fluid: lubricant"] = 2,
                    ["item: inserter"] = 4,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: radar"] = 4,
                },
            },
        },
        ["low-density-structure"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "fluid", name = "lubricant", amount = 111.276171289},
                {type = "item", name = "iron-plate", amount = 9.09195090838},
                {type = "item", name = "copper-plate", amount = 7.69237355536},
                {type = "item", name = "steel-plate", amount = 0.769237355536},
            },
            results = {
                {type = "item", name = "low-density-structure", amount = 1},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["fluid: lubricant"] = 2,
                    ["item: copper-plate"] = 1,
                    ["item: iron-plate"] = 1,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["lubricant"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "iron-plate", amount = 0.561357168222},
                {type = "fluid", name = "heavy-oil", amount = 4.87493760921},
            },
            results = {
                {type = "fluid", name = "lubricant", amount = 10},
            },
            topology = {
                output_rank = 2,
                ingredient_ranks = {
                    ["fluid: heavy-oil"] = 1,
                    ["item: iron-plate"] = 1,
                },
            },
        },
        ["lubricant-barrel"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "flamethrower", amount = 0.0905122705136},
                {type = "fluid", name = "lubricant", amount = 31.9150289517},
                {type = "item", name = "barrel", amount = 0.638300579035},
            },
            results = {
                {type = "item", name = "lubricant-barrel", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["fluid: lubricant"] = 2,
                    ["item: barrel"] = 3,
                    ["item: flamethrower"] = 3,
                },
            },
        },
        ["medium-electric-pole"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 2.0538007773},
                {type = "item", name = "iron-stick", amount = 2.22118271552},
                {type = "item", name = "plastic-bar", amount = 1.42865706173},
                {type = "item", name = "copper-cable", amount = 1.11059135776},
            },
            results = {
                {type = "item", name = "medium-electric-pole", amount = 1},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["item: copper-cable"] = 2,
                    ["item: iron-stick"] = 2,
                    ["item: plastic-bar"] = 2,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["military-science-pack"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "stone-wall", amount = 1.45843877227},
                {type = "item", name = "concrete", amount = 10.0056739025},
                {type = "item", name = "piercing-rounds-magazine", amount = 0.729219386136},
                {type = "item", name = "grenade", amount = 0.729219386136},
            },
            results = {
                {type = "item", name = "military-science-pack", amount = 2},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: concrete"] = 2,
                    ["item: grenade"] = 2,
                    ["item: piercing-rounds-magazine"] = 3,
                    ["item: stone-wall"] = 2,
                },
            },
        },
        ["modular-armor"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "barrel", amount = 42.3028745751},
                {type = "item", name = "advanced-circuit", amount = 21.2531592845},
                {type = "item", name = "battery", amount = 24.1805716158},
            },
            results = {
                {type = "item", name = "modular-armor", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: advanced-circuit"] = 4,
                    ["item: barrel"] = 3,
                    ["item: battery"] = 4,
                },
            },
        },
        ["night-vision-equipment"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 6.95098027772},
                {type = "item", name = "advanced-circuit", amount = 3.47549013886},
                {type = "item", name = "lab", amount = 0.615903804755},
            },
            results = {
                {type = "item", name = "night-vision-equipment", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: advanced-circuit"] = 4,
                    ["item: lab"] = 4,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["nuclear-fuel"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "fluid", name = "heavy-oil", amount = 143.677474017},
                {type = "item", name = "uranium-235", amount = 0.572497921392},
                {type = "item", name = "steel-plate", amount = 1.049503825},
            },
            results = {
                {type = "item", name = "nuclear-fuel", amount = 1},
            },
            topology = {
                output_rank = 6,
                ingredient_ranks = {
                    ["fluid: heavy-oil"] = 1,
                    ["item: steel-plate"] = 2,
                    ["item: uranium-235"] = 5,
                },
            },
        },
        ["nuclear-fuel-reprocessing"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "engine-unit", amount = 3.31387243596},
                {type = "item", name = "steel-plate", amount = 5.65646649058},
            },
            results = {
                {type = "item", name = "uranium-238", amount = 3},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: engine-unit"] = 3,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["nuclear-reactor"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 657.555599698},
                {type = "item", name = "battery", amount = 500.321777481},
                {type = "item", name = "advanced-circuit", amount = 209.375536609},
                {type = "fluid", name = "crude-oil", amount = 8963.60126179},
                {type = "item", name = "concrete", amount = 209.375536609},
            },
            results = {
                {type = "item", name = "nuclear-reactor", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["fluid: crude-oil"] = 0,
                    ["item: advanced-circuit"] = 4,
                    ["item: battery"] = 4,
                    ["item: concrete"] = 2,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["offshore-pump"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "iron-gear-wheel", amount = 1.30362631508},
                {type = "item", name = "landfill", amount = 0.185775259919},
                {type = "item", name = "pipe", amount = 1.95543947262},
            },
            results = {
                {type = "item", name = "offshore-pump", amount = 1},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["item: iron-gear-wheel"] = 2,
                    ["item: landfill"] = 1,
                    ["item: pipe"] = 2,
                },
            },
        },
        ["oil-refinery"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 13.0625569236},
                {type = "item", name = "iron-gear-wheel", amount = 18.2774558292},
                {type = "item", name = "electronic-circuit", amount = 9.221605368},
                {type = "item", name = "pipe", amount = 7.56137194123},
                {type = "item", name = "stone-brick", amount = 7.56137194123},
                {type = "item", name = "iron-stick", amount = 4.73911583217},
            },
            results = {
                {type = "item", name = "oil-refinery", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: electronic-circuit"] = 3,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: iron-stick"] = 2,
                    ["item: pipe"] = 2,
                    ["item: steel-plate"] = 2,
                    ["item: stone-brick"] = 1,
                },
            },
        },
        ["passive-provider-chest"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-chest", amount = 0.558493654478},
                {type = "item", name = "advanced-circuit", amount = 1.67175869108},
                {type = "item", name = "land-mine", amount = 8.19078318183},
                {type = "item", name = "electronic-circuit", amount = 1.67548096343},
            },
            results = {
                {type = "item", name = "passive-provider-chest", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: advanced-circuit"] = 4,
                    ["item: electronic-circuit"] = 3,
                    ["item: land-mine"] = 4,
                    ["item: steel-chest"] = 3,
                },
            },
        },
        ["personal-laser-defense-equipment"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "crude-oil-barrel", amount = 154.185666837},
                {type = "item", name = "processing-unit", amount = 8.16246797729},
                {type = "item", name = "boiler", amount = 92.7869584363},
                {type = "item", name = "copper-plate", amount = 583.129920687},
            },
            results = {
                {type = "item", name = "personal-laser-defense-equipment", amount = 1},
            },
            topology = {
                output_rank = 6,
                ingredient_ranks = {
                    ["item: boiler"] = 3,
                    ["item: copper-plate"] = 1,
                    ["item: crude-oil-barrel"] = 4,
                    ["item: processing-unit"] = 5,
                },
            },
        },
        ["personal-roboport-equipment"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "advanced-circuit", amount = 13.834061881},
                {type = "item", name = "battery", amount = 26.4984626485},
                {type = "item", name = "steel-plate", amount = 21.7478649506},
                {type = "item", name = "iron-gear-wheel", amount = 33.524959461},
                {type = "item", name = "electronic-circuit", amount = 19.375931777},
            },
            results = {
                {type = "item", name = "personal-roboport-equipment", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: advanced-circuit"] = 4,
                    ["item: battery"] = 4,
                    ["item: electronic-circuit"] = 3,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["personal-roboport-mk2-equipment"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "processing-unit", amount = 62.9203160793},
                {type = "item", name = "hazard-concrete", amount = 3196.361042},
                {type = "item", name = "steel-plate", amount = 372.152134435},
                {type = "item", name = "electronic-circuit", amount = 581.766305371},
            },
            results = {
                {type = "item", name = "personal-roboport-mk2-equipment", amount = 1},
            },
            topology = {
                output_rank = 6,
                ingredient_ranks = {
                    ["item: electronic-circuit"] = 3,
                    ["item: hazard-concrete"] = 3,
                    ["item: processing-unit"] = 5,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["petroleum-gas-barrel"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "barrel", amount = 0.677817773901},
                {type = "item", name = "iron-plate", amount = 3.45151099635},
                {type = "fluid", name = "petroleum-gas", amount = 33.890888695},
            },
            results = {
                {type = "item", name = "petroleum-gas-barrel", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["fluid: petroleum-gas"] = 1,
                    ["item: barrel"] = 3,
                    ["item: iron-plate"] = 1,
                },
            },
        },
        ["piercing-rounds-magazine"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "firearm-magazine", amount = 1.69995068879},
                {type = "item", name = "iron-plate", amount = 3.92778996642},
                {type = "item", name = "steel-plate", amount = 0.552916990889},
                {type = "item", name = "coal", amount = 7.85557993284},
            },
            results = {
                {type = "item", name = "piercing-rounds-magazine", amount = 2},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["item: coal"] = 0,
                    ["item: firearm-magazine"] = 2,
                    ["item: iron-plate"] = 1,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["piercing-shotgun-shell"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "shotgun-shell", amount = 1.5525752614},
                {type = "fluid", name = "crude-oil", amount = 197.467208444},
                {type = "item", name = "steel-plate", amount = 0.446552674981},
                {type = "item", name = "copper-plate", amount = 1.5525752614},
            },
            results = {
                {type = "item", name = "piercing-shotgun-shell", amount = 2},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["fluid: crude-oil"] = 0,
                    ["item: copper-plate"] = 1,
                    ["item: shotgun-shell"] = 2,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["pipe"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "iron-plate", amount = 1},
            },
            results = {
                {type = "item", name = "pipe", amount = 1},
            },
            topology = {
                output_rank = 2,
                ingredient_ranks = {
                    ["item: iron-plate"] = 1,
                },
            },
        },
        ["pipe-to-ground"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "iron-plate", amount = 8.58783900672},
                {type = "item", name = "steel-plate", amount = 1.12700097288},
                {type = "item", name = "copper-plate", amount = 2.25400194576},
            },
            results = {
                {type = "item", name = "pipe-to-ground", amount = 2},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["item: copper-plate"] = 1,
                    ["item: iron-plate"] = 1,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["plastic-bar"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "fluid", name = "petroleum-gas", amount = 20},
                {type = "item", name = "coal", amount = 1},
            },
            results = {
                {type = "item", name = "plastic-bar", amount = 2},
            },
            topology = {
                output_rank = 2,
                ingredient_ranks = {
                    ["fluid: petroleum-gas"] = 1,
                    ["item: coal"] = 0,
                },
            },
        },
        ["poison-capsule"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "shotgun-shell", amount = 2.96588571107},
                {type = "fluid", name = "heavy-oil", amount = 80.1995913164},
                {type = "item", name = "steel-plate", amount = 1.16272434436},
                {type = "item", name = "electronic-circuit", amount = 1.16272434436},
            },
            results = {
                {type = "item", name = "poison-capsule", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["fluid: heavy-oil"] = 1,
                    ["item: electronic-circuit"] = 3,
                    ["item: shotgun-shell"] = 2,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["power-armor"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 261.294551485},
                {type = "item", name = "processing-unit", amount = 15.3058010062},
                {type = "item", name = "iron-plate", amount = 915.865925531},
                {type = "item", name = "electric-engine-unit", amount = 16.1640350511},
            },
            results = {
                {type = "item", name = "power-armor", amount = 1},
            },
            topology = {
                output_rank = 6,
                ingredient_ranks = {
                    ["item: electric-engine-unit"] = 4,
                    ["item: iron-plate"] = 1,
                    ["item: processing-unit"] = 5,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["power-armor-mk2"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 2805.76158507},
                {type = "item", name = "speed-module-2", amount = 10.1063089383},
                {type = "item", name = "efficiency-module-2", amount = 10.1063089383},
                {type = "item", name = "fast-splitter", amount = 89.8653783214},
                {type = "item", name = "copper-plate", amount = 3504.86034167},
                {type = "item", name = "pipe", amount = 2106.66282846},
            },
            results = {
                {type = "item", name = "power-armor-mk2", amount = 1},
            },
            topology = {
                output_rank = 7,
                ingredient_ranks = {
                    ["item: copper-plate"] = 1,
                    ["item: efficiency-module-2"] = 6,
                    ["item: fast-splitter"] = 5,
                    ["item: pipe"] = 2,
                    ["item: speed-module-2"] = 6,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["power-switch"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "electronic-circuit", amount = 1.70049138281},
                {type = "item", name = "copper-cable", amount = 7.0138388756},
                {type = "item", name = "iron-plate", amount = 2.74109362875},
                {type = "item", name = "plastic-bar", amount = 1.85974266232},
            },
            results = {
                {type = "item", name = "power-switch", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: copper-cable"] = 2,
                    ["item: electronic-circuit"] = 3,
                    ["item: iron-plate"] = 1,
                    ["item: plastic-bar"] = 2,
                },
            },
        },
        ["processing-unit"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "burner-inserter", amount = 10.2276564744},
                {type = "item", name = "electronic-circuit", amount = 7.4486820733},
                {type = "item", name = "underground-belt", amount = 2.17818812497},
                {type = "item", name = "advanced-circuit", amount = 0.74486820733},
            },
            results = {
                {type = "item", name = "processing-unit", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: advanced-circuit"] = 4,
                    ["item: burner-inserter"] = 3,
                    ["item: electronic-circuit"] = 3,
                    ["item: underground-belt"] = 4,
                },
            },
        },
        ["production-science-pack"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "battery-equipment", amount = 1.20266436041},
                {type = "item", name = "iron-gear-wheel", amount = 38.0037848558},
                {type = "item", name = "electric-furnace", amount = 0.519721999284},
                {type = "item", name = "petroleum-gas-barrel", amount = 6.06480270154},
            },
            results = {
                {type = "item", name = "production-science-pack", amount = 3},
            },
            topology = {
                output_rank = 6,
                ingredient_ranks = {
                    ["item: battery-equipment"] = 5,
                    ["item: electric-furnace"] = 5,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: petroleum-gas-barrel"] = 4,
                },
            },
        },
        ["productivity-module"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "advanced-circuit", amount = 3.01640124495},
                {type = "item", name = "electronic-circuit", amount = 7.00964929976},
                {type = "item", name = "steel-plate", amount = 2.58040434399},
            },
            results = {
                {type = "item", name = "productivity-module", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: advanced-circuit"] = 4,
                    ["item: electronic-circuit"] = 3,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["productivity-module-2"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "solid-fuel", amount = 281.829762516},
                {type = "item", name = "processing-unit", amount = 2.45381929699},
                {type = "item", name = "advanced-circuit", amount = 16.5008484466},
                {type = "item", name = "productivity-module", amount = 1.96305543759},
            },
            results = {
                {type = "item", name = "productivity-module-2", amount = 1},
            },
            topology = {
                output_rank = 6,
                ingredient_ranks = {
                    ["item: advanced-circuit"] = 4,
                    ["item: processing-unit"] = 5,
                    ["item: productivity-module"] = 5,
                    ["item: solid-fuel"] = 2,
                },
            },
        },
        ["productivity-module-3"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "productivity-module-2", amount = 1.88812926536},
                {type = "item", name = "assembling-machine-2", amount = 23.107523507},
                {type = "item", name = "advanced-circuit", amount = 35.8119290955},
                {type = "item", name = "processing-unit", amount = 3.84760625907},
            },
            results = {
                {type = "item", name = "productivity-module-3", amount = 1},
            },
            topology = {
                output_rank = 7,
                ingredient_ranks = {
                    ["item: advanced-circuit"] = 4,
                    ["item: assembling-machine-2"] = 5,
                    ["item: processing-unit"] = 5,
                    ["item: productivity-module-2"] = 6,
                },
            },
        },
        ["programmable-speaker"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "electronic-circuit", amount = 3.97890309662},
                {type = "item", name = "copper-cable", amount = 5.8798768176},
                {type = "item", name = "iron-plate", amount = 2.07792937564},
                {type = "item", name = "iron-stick", amount = 2.77057250085},
                {type = "item", name = "plastic-bar", amount = 1.20833059577},
            },
            results = {
                {type = "item", name = "programmable-speaker", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: copper-cable"] = 2,
                    ["item: electronic-circuit"] = 3,
                    ["item: iron-plate"] = 1,
                    ["item: iron-stick"] = 2,
                    ["item: plastic-bar"] = 2,
                },
            },
        },
        ["pump"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "copper-plate", amount = 11.6319308773},
                {type = "item", name = "steel-plate", amount = 1.01787464486},
                {type = "item", name = "pipe", amount = 1.36910811164},
                {type = "item", name = "engine-unit", amount = 0.0992554748218},
            },
            results = {
                {type = "item", name = "pump", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: copper-plate"] = 1,
                    ["item: engine-unit"] = 3,
                    ["item: pipe"] = 2,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["pumpjack"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "iron-gear-wheel", amount = 14.9189382141},
                {type = "item", name = "steel-plate", amount = 4.82391904296},
                {type = "item", name = "pipe", amount = 14.9189382141},
            },
            results = {
                {type = "item", name = "pumpjack", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: iron-gear-wheel"] = 2,
                    ["item: pipe"] = 2,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["radar"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "iron-plate", amount = 39.1576086957},
            },
            results = {
                {type = "item", name = "radar", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: iron-plate"] = 1,
                },
            },
        },
        ["rail"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 0.717810175695},
                {type = "item", name = "iron-chest", amount = 0.289587931739},
                {type = "item", name = "iron-stick", amount = 0.573808453775},
                {type = "item", name = "stone", amount = 0.573808453775},
            },
            results = {
                {type = "item", name = "rail", amount = 2},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["item: iron-chest"] = 2,
                    ["item: iron-stick"] = 2,
                    ["item: steel-plate"] = 2,
                    ["item: stone"] = 0,
                },
            },
        },
        ["rail-chain-signal"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "iron-plate", amount = 5.01144557585},
                {type = "item", name = "electronic-circuit", amount = 0.810691998747},
                {type = "item", name = "copper-cable", amount = 0.929957439684},
            },
            results = {
                {type = "item", name = "rail-chain-signal", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: copper-cable"] = 2,
                    ["item: electronic-circuit"] = 3,
                    ["item: iron-plate"] = 1,
                },
            },
        },
        ["rail-signal"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "iron-plate", amount = 3.11802272854},
                {type = "item", name = "submachine-gun", amount = 0.0758533632803},
                {type = "item", name = "steel-plate", amount = 0.323053022826},
            },
            results = {
                {type = "item", name = "rail-signal", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: iron-plate"] = 1,
                    ["item: steel-plate"] = 2,
                    ["item: submachine-gun"] = 3,
                },
            },
        },
        ["refined-concrete"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "solid-fuel", amount = 13.4144910408},
                {type = "item", name = "pipe", amount = 5.09960176832},
                {type = "item", name = "concrete", amount = 7.35594235328},
                {type = "item", name = "iron-plate", amount = 2.54980088416},
                {type = "item", name = "iron-stick", amount = 2.94237694131},
            },
            results = {
                {type = "item", name = "refined-concrete", amount = 10},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["item: concrete"] = 2,
                    ["item: iron-plate"] = 1,
                    ["item: iron-stick"] = 2,
                    ["item: pipe"] = 2,
                    ["item: solid-fuel"] = 2,
                },
            },
        },
        ["refined-hazard-concrete"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "refined-concrete", amount = 6.34018845191},
                {type = "item", name = "stone-brick", amount = 9.08353226854},
            },
            results = {
                {type = "item", name = "refined-hazard-concrete", amount = 10},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: refined-concrete"] = 3,
                    ["item: stone-brick"] = 1,
                },
            },
        },
        ["repair-pack"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "electronic-circuit", amount = 1.35739435604},
                {type = "item", name = "rocket-fuel", amount = 0.312247457419},
                {type = "item", name = "iron-gear-wheel", amount = 1.35739435604},
            },
            results = {
                {type = "item", name = "repair-pack", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: electronic-circuit"] = 3,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: rocket-fuel"] = 3,
                },
            },
        },
        ["requester-chest"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-chest", amount = 0.805664082165},
                {type = "item", name = "iron-gear-wheel", amount = 7.09487660395},
                {type = "item", name = "iron-plate", amount = 8.86859575494},
                {type = "item", name = "electronic-circuit", amount = 2.4169922465},
            },
            results = {
                {type = "item", name = "requester-chest", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: electronic-circuit"] = 3,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: iron-plate"] = 1,
                    ["item: steel-chest"] = 3,
                },
            },
        },
        ["roboport"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "automation-science-pack", amount = 94.7129396204},
                {type = "item", name = "explosive-cannon-shell", amount = 12.7614484122},
                {type = "item", name = "advanced-circuit", amount = 14.3000740233},
                {type = "item", name = "steel-plate", amount = 22.5968436298},
            },
            results = {
                {type = "item", name = "roboport", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: advanced-circuit"] = 4,
                    ["item: automation-science-pack"] = 3,
                    ["item: explosive-cannon-shell"] = 4,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["rocket"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "iron-plate", amount = 2},
                {type = "item", name = "explosives", amount = 1},
            },
            results = {
                {type = "item", name = "rocket", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: explosives"] = 3,
                    ["item: iron-plate"] = 1,
                },
            },
        },
        ["rocket-fuel"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "solid-fuel", amount = 8.67753626602},
                {type = "item", name = "iron-gear-wheel", amount = 0.57148099311},
                {type = "fluid", name = "light-oil", amount = 8.67753626602},
            },
            results = {
                {type = "item", name = "rocket-fuel", amount = 1},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["fluid: light-oil"] = 1,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: solid-fuel"] = 2,
                },
            },
        },
        ["rocket-launcher"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "barrel", amount = 2.05002072323},
                {type = "item", name = "electronic-circuit", amount = 2.74938059025},
                {type = "item", name = "iron-gear-wheel", amount = 2.74938059025},
                {type = "item", name = "iron-plate", amount = 2.74938059025},
            },
            results = {
                {type = "item", name = "rocket-launcher", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: barrel"] = 3,
                    ["item: electronic-circuit"] = 3,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: iron-plate"] = 1,
                },
            },
        },
        ["rocket-part"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "copper-cable", amount = 866.119840408},
                {type = "item", name = "processing-unit", amount = 4.30730189096},
                {type = "item", name = "locomotive", amount = 0.59060029341},
                {type = "item", name = "low-density-structure", amount = 4.30730189096},
            },
            results = {
                {type = "item", name = "rocket-part", amount = 1},
            },
            topology = {
                output_rank = 6,
                ingredient_ranks = {
                    ["item: copper-cable"] = 2,
                    ["item: locomotive"] = 4,
                    ["item: low-density-structure"] = 3,
                    ["item: processing-unit"] = 5,
                },
            },
        },
        ["rocket-silo"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "processing-unit", amount = 89.6028504709},
                {type = "item", name = "advanced-circuit", amount = 605.086508857},
                {type = "item", name = "steel-chest", amount = 121.012832893},
                {type = "item", name = "steel-plate", amount = 448.014252355},
                {type = "item", name = "stone-wall", amount = 421.856297196},
                {type = "item", name = "electronic-circuit", amount = 847.112174643},
            },
            results = {
                {type = "item", name = "rocket-silo", amount = 1},
            },
            topology = {
                output_rank = 6,
                ingredient_ranks = {
                    ["item: advanced-circuit"] = 4,
                    ["item: electronic-circuit"] = 3,
                    ["item: processing-unit"] = 5,
                    ["item: steel-chest"] = 3,
                    ["item: steel-plate"] = 2,
                    ["item: stone-wall"] = 2,
                },
            },
        },
        ["satellite"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "repair-pack", amount = 825.826119737},
                {type = "item", name = "electric-furnace", amount = 28.2920167649},
                {type = "item", name = "processing-unit", amount = 42.0977782961},
                {type = "item", name = "solar-panel", amount = 42.0977782961},
                {type = "item", name = "solid-fuel", amount = 3604.70293368},
                {type = "item", name = "low-density-structure", amount = 42.0977782961},
            },
            results = {
                {type = "item", name = "satellite", amount = 1},
            },
            topology = {
                output_rank = 6,
                ingredient_ranks = {
                    ["item: electric-furnace"] = 5,
                    ["item: low-density-structure"] = 3,
                    ["item: processing-unit"] = 5,
                    ["item: repair-pack"] = 4,
                    ["item: solar-panel"] = 4,
                    ["item: solid-fuel"] = 2,
                },
            },
        },
        ["selector-combinator"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "iron-gear-wheel", amount = 25.5928429014},
                {type = "item", name = "decider-combinator", amount = 1.90078808383},
                {type = "item", name = "piercing-rounds-magazine", amount = 3.15184955194},
            },
            results = {
                {type = "item", name = "selector-combinator", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: decider-combinator"] = 4,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: piercing-rounds-magazine"] = 3,
                },
            },
        },
        ["shotgun"] = {
            mode = "unchanged",
            reason = "multi-result or unsupported/unranked recipe",
            ingredients = {
                {type = "item", name = "copper-plate", amount = 10},
                {type = "item", name = "iron-gear-wheel", amount = 5},
                {type = "item", name = "iron-plate", amount = 15},
                {type = "item", name = "wood", amount = 5},
            },
            results = {
                {type = "item", name = "shotgun", amount = 1},
            },
        },
        ["shotgun-shell"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "iron-plate", amount = 2.34239250576},
                {type = "item", name = "copper-plate", amount = 1.34872411925},
                {type = "item", name = "coal", amount = 0.947242349952},
            },
            results = {
                {type = "item", name = "shotgun-shell", amount = 1},
            },
            topology = {
                output_rank = 2,
                ingredient_ranks = {
                    ["item: coal"] = 0,
                    ["item: copper-plate"] = 1,
                    ["item: iron-plate"] = 1,
                },
            },
        },
        ["slowdown-capsule"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 1.32612841781},
                {type = "item", name = "iron-plate", amount = 7.50201827595},
                {type = "item", name = "electronic-circuit", amount = 1.35753082047},
                {type = "item", name = "coal", amount = 3.39382705117},
            },
            results = {
                {type = "item", name = "slowdown-capsule", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: coal"] = 0,
                    ["item: electronic-circuit"] = 3,
                    ["item: iron-plate"] = 1,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["small-electric-pole"] = {
            mode = "unchanged",
            reason = "multi-result or unsupported/unranked recipe",
            ingredients = {
                {type = "item", name = "copper-cable", amount = 2},
                {type = "item", name = "wood", amount = 1},
            },
            results = {
                {type = "item", name = "small-electric-pole", amount = 2},
            },
        },
        ["small-lamp"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "pipe", amount = 1.94476266035},
                {type = "item", name = "copper-cable", amount = 2.91542170005},
                {type = "item", name = "electronic-circuit", amount = 0.528774375377},
            },
            results = {
                {type = "item", name = "small-lamp", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: copper-cable"] = 2,
                    ["item: electronic-circuit"] = 3,
                    ["item: pipe"] = 2,
                },
            },
        },
        ["solar-panel"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 7.63849848031},
                {type = "item", name = "electronic-circuit", amount = 7.45110008273},
                {type = "fluid", name = "petroleum-gas", amount = 159.047595098},
                {type = "item", name = "copper-plate", amount = 2.19021469864},
            },
            results = {
                {type = "item", name = "solar-panel", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["fluid: petroleum-gas"] = 1,
                    ["item: copper-plate"] = 1,
                    ["item: electronic-circuit"] = 3,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["solar-panel-equipment"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "solar-panel", amount = 0.481396844859},
                {type = "fluid", name = "petroleum-gas", amount = 648.657963868},
                {type = "item", name = "steel-plate", amount = 5.49231040461},
                {type = "item", name = "shotgun-shell", amount = 6.17065236063},
            },
            results = {
                {type = "item", name = "solar-panel-equipment", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["fluid: petroleum-gas"] = 1,
                    ["item: shotgun-shell"] = 2,
                    ["item: solar-panel"] = 4,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["solid-fuel-from-heavy-oil"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "fluid", name = "heavy-oil", amount = 16.1599358096},
                {type = "item", name = "iron-plate", amount = 0.420609037573},
            },
            results = {
                {type = "item", name = "solid-fuel", amount = 1},
            },
            topology = {
                output_rank = 2,
                ingredient_ranks = {
                    ["fluid: heavy-oil"] = 1,
                    ["item: iron-plate"] = 1,
                },
            },
        },
        ["solid-fuel-from-light-oil"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "fluid", name = "light-oil", amount = 9.74521920742},
                {type = "fluid", name = "water", amount = 3.56193539431},
            },
            results = {
                {type = "item", name = "solid-fuel", amount = 1},
            },
            topology = {
                output_rank = 2,
                ingredient_ranks = {
                    ["fluid: light-oil"] = 1,
                    ["fluid: water"] = 0,
                },
            },
        },
        ["solid-fuel-from-petroleum-gas"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "fluid", name = "petroleum-gas", amount = 17.5980272464},
                {type = "fluid", name = "heavy-oil", amount = 1.40915015831},
            },
            results = {
                {type = "item", name = "solid-fuel", amount = 1},
            },
            topology = {
                output_rank = 2,
                ingredient_ranks = {
                    ["fluid: heavy-oil"] = 1,
                    ["fluid: petroleum-gas"] = 1,
                },
            },
        },
        ["speed-module"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "advanced-circuit", amount = 3.35715483682},
                {type = "item", name = "stone-wall", amount = 3.24545079373},
                {type = "item", name = "piercing-rounds-magazine", amount = 1.62272539687},
            },
            results = {
                {type = "item", name = "speed-module", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: advanced-circuit"] = 4,
                    ["item: piercing-rounds-magazine"] = 3,
                    ["item: stone-wall"] = 2,
                },
            },
        },
        ["speed-module-2"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "modular-armor", amount = 0.455349672579},
                {type = "item", name = "steel-plate", amount = 29.2698209013},
                {type = "item", name = "processing-unit", amount = 2.06051004861},
                {type = "item", name = "speed-module", amount = 1.64840803889},
            },
            results = {
                {type = "item", name = "speed-module-2", amount = 1},
            },
            topology = {
                output_rank = 6,
                ingredient_ranks = {
                    ["item: modular-armor"] = 5,
                    ["item: processing-unit"] = 5,
                    ["item: speed-module"] = 5,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["speed-module-3"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "speed-module-2", amount = 1.28962229983},
                {type = "item", name = "radar", amount = 27.1907595085},
                {type = "item", name = "long-handed-inserter", amount = 91.6139930991},
                {type = "item", name = "express-underground-belt", amount = 5.459790524},
            },
            results = {
                {type = "item", name = "speed-module-3", amount = 1},
            },
            topology = {
                output_rank = 7,
                ingredient_ranks = {
                    ["item: express-underground-belt"] = 6,
                    ["item: long-handed-inserter"] = 5,
                    ["item: radar"] = 4,
                    ["item: speed-module-2"] = 6,
                },
            },
        },
        ["spidertron"] = {
            mode = "unchanged",
            reason = "multi-result or unsupported/unranked recipe",
            ingredients = {
                {type = "item", name = "efficiency-module-3", amount = 2},
                {type = "item", name = "exoskeleton-equipment", amount = 4},
                {type = "item", name = "fission-reactor-equipment", amount = 2},
                {type = "item", name = "low-density-structure", amount = 150},
                {type = "item", name = "processing-unit", amount = 16},
                {type = "item", name = "radar", amount = 2},
                {type = "item", name = "raw-fish", amount = 1},
                {type = "item", name = "rocket-launcher", amount = 4},
            },
            results = {
                {type = "item", name = "spidertron", amount = 1},
            },
        },
        ["splitter"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "sulfur", amount = 8.70292210077},
                {type = "item", name = "electronic-circuit", amount = 2.86236805964},
                {type = "item", name = "iron-plate", amount = 4.60295247979},
                {type = "item", name = "transport-belt", amount = 2.28989444771},
            },
            results = {
                {type = "item", name = "splitter", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: electronic-circuit"] = 3,
                    ["item: iron-plate"] = 1,
                    ["item: sulfur"] = 2,
                    ["item: transport-belt"] = 3,
                },
            },
        },
        ["steam-engine"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "iron-gear-wheel", amount = 8.57669133013},
                {type = "item", name = "iron-plate", amount = 8.12967091708},
                {type = "item", name = "pipe", amount = 5.36043208133},
            },
            results = {
                {type = "item", name = "steam-engine", amount = 1},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["item: iron-gear-wheel"] = 2,
                    ["item: iron-plate"] = 1,
                    ["item: pipe"] = 2,
                },
            },
        },
        ["steam-turbine"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "iron-gear-wheel", amount = 48.1590919566},
                {type = "item", name = "copper-plate", amount = 42.47615228},
                {type = "item", name = "pipe", amount = 16.990460912},
                {type = "item", name = "steel-plate", amount = 2.27317587063},
            },
            results = {
                {type = "item", name = "steam-turbine", amount = 1},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["item: copper-plate"] = 1,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: pipe"] = 2,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["steel-chest"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 4.02011743036},
                {type = "fluid", name = "petroleum-gas", amount = 437.589078552},
            },
            results = {
                {type = "item", name = "steel-chest", amount = 1},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["fluid: petroleum-gas"] = 1,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["steel-furnace"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 5.93474874654},
                {type = "item", name = "stone-brick", amount = 5.99786207615},
                {type = "item", name = "copper-cable", amount = 8.35707309381},
            },
            results = {
                {type = "item", name = "steel-furnace", amount = 1},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["item: copper-cable"] = 2,
                    ["item: steel-plate"] = 2,
                    ["item: stone-brick"] = 1,
                },
            },
        },
        ["steel-plate"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "landfill", amount = 0.159041273224},
                {type = "item", name = "iron-plate", amount = 2.34643093046},
            },
            results = {
                {type = "item", name = "steel-plate", amount = 1},
            },
            topology = {
                output_rank = 2,
                ingredient_ranks = {
                    ["item: iron-plate"] = 1,
                    ["item: landfill"] = 1,
                },
            },
        },
        ["stone-brick"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "stone", amount = 2},
            },
            results = {
                {type = "item", name = "stone-brick", amount = 1},
            },
            topology = {
                output_rank = 1,
                ingredient_ranks = {
                    ["item: stone"] = 0,
                },
            },
        },
        ["stone-furnace"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "stone", amount = 5},
            },
            results = {
                {type = "item", name = "stone-furnace", amount = 1},
            },
            topology = {
                output_rank = 1,
                ingredient_ranks = {
                    ["item: stone"] = 0,
                },
            },
        },
        ["stone-wall"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "stone-brick", amount = 2.62152521397},
                {type = "fluid", name = "petroleum-gas", amount = 49.0841463306},
            },
            results = {
                {type = "item", name = "stone-wall", amount = 1},
            },
            topology = {
                output_rank = 2,
                ingredient_ranks = {
                    ["fluid: petroleum-gas"] = 1,
                    ["item: stone-brick"] = 1,
                },
            },
        },
        ["storage-chest"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "burner-mining-drill", amount = 3.09039614277},
                {type = "item", name = "steel-chest", amount = 0.509216504686},
                {type = "item", name = "advanced-circuit", amount = 0.509216504686},
                {type = "item", name = "electronic-circuit", amount = 1.52764951406},
            },
            results = {
                {type = "item", name = "storage-chest", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: advanced-circuit"] = 4,
                    ["item: burner-mining-drill"] = 3,
                    ["item: electronic-circuit"] = 3,
                    ["item: steel-chest"] = 3,
                },
            },
        },
        ["storage-tank"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 4.85134259093},
                {type = "item", name = "iron-plate", amount = 21.0502969119},
            },
            results = {
                {type = "item", name = "storage-tank", amount = 1},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["item: iron-plate"] = 1,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["submachine-gun"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "iron-gear-wheel", amount = 7.29828392919},
                {type = "item", name = "iron-plate", amount = 14.8416020555},
                {type = "item", name = "pipe", amount = 2.60122470822},
                {type = "item", name = "copper-plate", amount = 2.99883578754},
            },
            results = {
                {type = "item", name = "submachine-gun", amount = 1},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["item: copper-plate"] = 1,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: iron-plate"] = 1,
                    ["item: pipe"] = 2,
                },
            },
        },
        ["substation"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 11.3446384539},
                {type = "item", name = "advanced-circuit", amount = 2.24038743084},
                {type = "item", name = "car", amount = 0.168648422024},
                {type = "item", name = "copper-cable", amount = 2.68846491701},
            },
            results = {
                {type = "item", name = "substation", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["item: advanced-circuit"] = 4,
                    ["item: car"] = 4,
                    ["item: copper-cable"] = 2,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["sulfur"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "fluid", name = "petroleum-gas", amount = 30},
                {type = "fluid", name = "water", amount = 30},
            },
            results = {
                {type = "item", name = "sulfur", amount = 2},
            },
            topology = {
                output_rank = 2,
                ingredient_ranks = {
                    ["fluid: petroleum-gas"] = 1,
                    ["fluid: water"] = 0,
                },
            },
        },
        ["sulfuric-acid"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "firearm-magazine", amount = 0.628406294941},
                {type = "item", name = "sulfur", amount = 2.08964716494},
                {type = "item", name = "solid-fuel", amount = 2.31414816745},
                {type = "fluid", name = "water", amount = 41.7929432987},
            },
            results = {
                {type = "fluid", name = "sulfuric-acid", amount = 50},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["fluid: water"] = 0,
                    ["item: firearm-magazine"] = 2,
                    ["item: solid-fuel"] = 2,
                    ["item: sulfur"] = 2,
                },
            },
        },
        ["sulfuric-acid-barrel"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "fluid", name = "sulfuric-acid", amount = 50},
                {type = "item", name = "barrel", amount = 1},
            },
            results = {
                {type = "item", name = "sulfuric-acid-barrel", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["fluid: sulfuric-acid"] = 3,
                    ["item: barrel"] = 3,
                },
            },
        },
        ["tank"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 62.0012984884},
                {type = "item", name = "engine-unit", amount = 15.5248314655},
                {type = "fluid", name = "light-oil", amount = 2481.13003297},
                {type = "item", name = "advanced-circuit", amount = 4.85150983297},
                {type = "item", name = "iron-stick", amount = 75.4874986471},
            },
            results = {
                {type = "item", name = "tank", amount = 1},
            },
            topology = {
                output_rank = 5,
                ingredient_ranks = {
                    ["fluid: light-oil"] = 1,
                    ["item: advanced-circuit"] = 4,
                    ["item: engine-unit"] = 3,
                    ["item: iron-stick"] = 2,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["train-stop"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "hazard-concrete", amount = 18.3863514049},
                {type = "item", name = "steel-plate", amount = 1.87092730739},
                {type = "item", name = "electronic-circuit", amount = 3.34648044621},
                {type = "item", name = "iron-plate", amount = 4.01577653545},
                {type = "item", name = "iron-stick", amount = 4.01577653545},
            },
            results = {
                {type = "item", name = "train-stop", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: electronic-circuit"] = 3,
                    ["item: hazard-concrete"] = 3,
                    ["item: iron-plate"] = 1,
                    ["item: iron-stick"] = 2,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["transport-belt"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "iron-gear-wheel", amount = 0.624305002977},
                {type = "item", name = "iron-plate", amount = 1.11628753269},
                {type = "item", name = "steel-plate", amount = 0.110121155908},
            },
            results = {
                {type = "item", name = "transport-belt", amount = 2},
            },
            topology = {
                output_rank = 3,
                ingredient_ranks = {
                    ["item: iron-gear-wheel"] = 2,
                    ["item: iron-plate"] = 1,
                    ["item: steel-plate"] = 2,
                },
            },
        },
        ["underground-belt"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "electronic-circuit", amount = 1.93635389334},
                {type = "item", name = "iron-plate", amount = 6.55578509167},
                {type = "item", name = "transport-belt", amount = 3.27789254583},
            },
            results = {
                {type = "item", name = "underground-belt", amount = 2},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["item: electronic-circuit"] = 3,
                    ["item: iron-plate"] = 1,
                    ["item: transport-belt"] = 3,
                },
            },
        },
        ["uranium-cannon-shell"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "cannon-shell", amount = 0.642544373369},
                {type = "item", name = "sulfuric-acid-barrel", amount = 0.433234221375},
                {type = "item", name = "iron-gear-wheel", amount = 2.62260719529},
            },
            results = {
                {type = "item", name = "uranium-cannon-shell", amount = 1},
            },
            topology = {
                output_rank = 6,
                ingredient_ranks = {
                    ["item: cannon-shell"] = 4,
                    ["item: iron-gear-wheel"] = 2,
                    ["item: sulfuric-acid-barrel"] = 4,
                },
            },
        },
        ["uranium-fuel-cell"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "uranium-238", amount = 11.4544694128},
                {type = "item", name = "uranium-235", amount = 1.34296386589},
                {type = "fluid", name = "light-oil", amount = 355.133245183},
                {type = "item", name = "processing-unit", amount = 0.24669901823},
            },
            results = {
                {type = "item", name = "uranium-fuel-cell", amount = 10},
            },
            topology = {
                output_rank = 6,
                ingredient_ranks = {
                    ["fluid: light-oil"] = 1,
                    ["item: processing-unit"] = 5,
                    ["item: uranium-235"] = 5,
                    ["item: uranium-238"] = 5,
                },
            },
        },
        ["uranium-processing"] = {
            mode = "unchanged",
            reason = "multi-result or unsupported/unranked recipe",
            ingredients = {
                {type = "item", name = "uranium-ore", amount = 10},
            },
            results = {
                {type = "item", name = "uranium-235", amount = 0.007},
                {type = "item", name = "uranium-238", amount = 0.993},
            },
        },
        ["uranium-rounds-magazine"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "automation-science-pack", amount = 1.499489117},
                {type = "item", name = "piercing-rounds-magazine", amount = 0.602999308408},
                {type = "item", name = "uranium-238", amount = 0.602999308408},
            },
            results = {
                {type = "item", name = "uranium-rounds-magazine", amount = 1},
            },
            topology = {
                output_rank = 6,
                ingredient_ranks = {
                    ["item: automation-science-pack"] = 3,
                    ["item: piercing-rounds-magazine"] = 3,
                    ["item: uranium-238"] = 5,
                },
            },
        },
        ["utility-science-pack"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "lab", amount = 1.68125831165},
                {type = "item", name = "explosive-cannon-shell", amount = 5.56568533847},
                {type = "item", name = "processing-unit", amount = 0.945922327077},
                {type = "item", name = "low-density-structure", amount = 1.41888349061},
            },
            results = {
                {type = "item", name = "utility-science-pack", amount = 3},
            },
            topology = {
                output_rank = 6,
                ingredient_ranks = {
                    ["item: explosive-cannon-shell"] = 4,
                    ["item: lab"] = 4,
                    ["item: low-density-structure"] = 3,
                    ["item: processing-unit"] = 5,
                },
            },
        },
        ["water-barrel"] = {
            mode = "givens-transformed-topology-primed",
            ingredients = {
                {type = "item", name = "barrel", amount = 0.861359651451},
                {type = "item", name = "iron-plate", amount = 1.07747662188},
                {type = "fluid", name = "water", amount = 43.0679825725},
            },
            results = {
                {type = "item", name = "water-barrel", amount = 1},
            },
            topology = {
                output_rank = 4,
                ingredient_ranks = {
                    ["fluid: water"] = 0,
                    ["item: barrel"] = 3,
                    ["item: iron-plate"] = 1,
                },
            },
        },
        ["wooden-chest"] = {
            mode = "unchanged",
            reason = "multi-result or unsupported/unranked recipe",
            ingredients = {
                {type = "item", name = "wood", amount = 2},
            },
            results = {
                {type = "item", name = "wooden-chest", amount = 1},
            },
        },
    },
}

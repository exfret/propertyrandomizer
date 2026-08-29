-- Generated Givens-rotation recipe proof of concept.
-- NOTE: item ingredient amounts are still fractional in this POC.
-- This file is intended as input data for the randomizer / a later repair pass,
-- not as a guaranteed directly-valid Factorio recipe prototype set.

return {
    metadata = {
        format = "propertyrandomizer-givens-recipe-poc-v1",
        source = "factorio-current(20260818-034039).log",
        seed = 20260817,
        transformed_recipes = 186,
        unchanged_recipes = 16,
        givens_rounds = 2,
    },
    recipes = {
        ["accumulator"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "battery", amount = 2.53476513755},
                {type = "item", name = "steel-plate", amount = 1.2357446539},
                {type = "item", name = "iron-plate", amount = 8.25227498906},
            },
            results = {
                {type = "item", name = "accumulator", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 29.7976470588,
                dense_negative_support = 7,
                dense_positive_support = 4,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.932753521142,
            },
        },
        ["active-provider-chest"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "steel-chest", amount = 0.381944803241},
                {type = "item", name = "steam-turbine", amount = 0.103987151055},
                {type = "item", name = "stone-furnace", amount = 9.38842837466},
                {type = "item", name = "rocket", amount = 4.74789924802},
            },
            results = {
                {type = "item", name = "active-provider-chest", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 73.5473529412,
                dense_negative_support = 7,
                dense_positive_support = 6,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.951027865732,
            },
        },
        ["advanced-circuit"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "power-switch", amount = 0.381338947067},
                {type = "item", name = "programmable-speaker", amount = 0.145021239279},
                {type = "item", name = "plastic-bar", amount = 1.16787968185},
                {type = "item", name = "iron-gear-wheel", amount = 0.435047763435},
            },
            results = {
                {type = "item", name = "advanced-circuit", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 10.7723529412,
                dense_negative_support = 5,
                dense_positive_support = 5,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.992177352685,
            },
        },
        ["advanced-oil-processing"] = {
            mode = "unchanged",
            reason = "multi-result recipe",
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
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "electronic-circuit", amount = 2.89898231354},
                {type = "item", name = "iron-gear-wheel", amount = 3.01493251958},
                {type = "item", name = "speed-module-2", amount = 0.00400202614222},
            },
            results = {
                {type = "item", name = "arithmetic-combinator", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 19.05,
                dense_negative_support = 8,
                dense_positive_support = 4,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.983091990142,
            },
        },
        ["artillery-shell"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "electric-engine-unit", amount = 1.59209507299},
                {type = "item", name = "explosive-cannon-shell", amount = 1.87737564098},
                {type = "item", name = "steel-plate", amount = 4.81210812967},
                {type = "item", name = "radar", amount = 0.469343910246},
            },
            results = {
                {type = "item", name = "artillery-shell", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 117.998529412,
                dense_negative_support = 9,
                dense_positive_support = 6,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.976721818557,
            },
        },
        ["artillery-turret"] = {
            mode = "givens-transformed",
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
            diagnostics = {
                pre_randomization_input_cost_budget = 760.247058824,
                dense_negative_support = 8,
                dense_positive_support = 4,
                kept_ingredient_count = 5,
                retained_negative_l2_fraction = 0.953159321129,
            },
        },
        ["artillery-wagon"] = {
            mode = "givens-transformed",
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
            diagnostics = {
                pre_randomization_input_cost_budget = 1337.58705882,
                dense_negative_support = 9,
                dense_positive_support = 4,
                kept_ingredient_count = 6,
                retained_negative_l2_fraction = 0.99222942322,
            },
        },
        ["assembling-machine-1"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "battery-mk2-equipment", amount = 0.0055171604688},
                {type = "item", name = "display-panel", amount = 1.84301236056},
                {type = "item", name = "iron-gear-wheel", amount = 2.24842377326},
                {type = "item", name = "iron-plate", amount = 2.20415043131},
            },
            results = {
                {type = "item", name = "assembling-machine-1", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 28.755,
                dense_negative_support = 6,
                dense_positive_support = 6,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.995914306417,
            },
        },
        ["assembling-machine-2"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "productivity-module-2", amount = 0.020927236743},
                {type = "item", name = "steam-turbine", amount = 0.0830195521422},
                {type = "item", name = "assembling-machine-1", amount = 0.510465350608},
                {type = "item", name = "explosive-rocket", amount = 1.30223465394},
                {type = "item", name = "steel-plate", amount = 1.02093070122},
            },
            results = {
                {type = "item", name = "assembling-machine-2", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 62.58,
                dense_negative_support = 8,
                dense_positive_support = 7,
                kept_ingredient_count = 5,
                retained_negative_l2_fraction = 0.9835030982,
            },
        },
        ["assembling-machine-3"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "speed-module", amount = 2.73186786},
                {type = "fluid", name = "petroleum-gas", amount = 1954.34932666},
                {type = "item", name = "copper-cable", amount = 168.107293578},
            },
            results = {
                {type = "item", name = "assembling-machine-3", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 430.007058824,
                dense_negative_support = 9,
                dense_positive_support = 4,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.90679992169,
            },
        },
        ["atomic-bomb"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "processing-unit", amount = 5.29564271851},
                {type = "item", name = "fluid-wagon", amount = 2.45371448344},
                {type = "item", name = "uranium-fuel-cell", amount = 25.0169280371},
                {type = "item", name = "uranium-235", amount = 13.3852353518},
            },
            results = {
                {type = "item", name = "atomic-bomb", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 1620.05169161,
                dense_negative_support = 7,
                dense_positive_support = 8,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.971991802612,
            },
        },
        ["automation-science-pack"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 0.258325250941},
                {type = "item", name = "iron-gear-wheel", amount = 0.389148384933},
                {type = "item", name = "advanced-circuit", amount = 0.0495744867205},
            },
            results = {
                {type = "item", name = "automation-science-pack", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 3.11,
                dense_negative_support = 6,
                dense_positive_support = 4,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.97103203932,
            },
        },
        ["barrel"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 0.502568990849},
                {type = "item", name = "discharge-defense-equipment", amount = 0.0010088866382},
            },
            results = {
                {type = "item", name = "barrel", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 6.5,
                dense_negative_support = 5,
                dense_positive_support = 5,
                kept_ingredient_count = 2,
                retained_negative_l2_fraction = 0.928052336554,
            },
        },
        ["basic-oil-processing"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "fluid", name = "crude-oil", amount = 68.1219706456},
                {type = "item", name = "solar-panel", amount = 0.0111170111088},
            },
            results = {
                {type = "fluid", name = "petroleum-gas", amount = 45},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 3,
                dense_negative_support = 4,
                dense_positive_support = 7,
                kept_ingredient_count = 2,
                retained_negative_l2_fraction = 0.897347546351,
            },
        },
        ["battery"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 0.368360188504},
                {type = "item", name = "artillery-shell", amount = 0.0109791248493},
                {type = "fluid", name = "sulfuric-acid", amount = 5.95188932411},
                {type = "item", name = "iron-plate", amount = 0.297594466206},
            },
            results = {
                {type = "item", name = "battery", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 4.89152941176,
                dense_negative_support = 8,
                dense_positive_support = 6,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.991381943642,
            },
        },
        ["battery-equipment"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 5.71151592692},
                {type = "item", name = "iron-gear-wheel", amount = 13.0708387492},
                {type = "item", name = "cargo-landing-pad", amount = 0.0223219255274},
            },
            results = {
                {type = "item", name = "battery-equipment", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 92.9576470588,
                dense_negative_support = 7,
                dense_positive_support = 6,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.888640032595,
            },
        },
        ["battery-mk2-equipment"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "energy-shield-mk2-equipment", amount = 0.567836186398},
                {type = "item", name = "processing-unit", amount = 6.65046049545},
                {type = "item", name = "iron-gear-wheel", amount = 193.744868981},
                {type = "item", name = "battery-equipment", amount = 4.04723506427},
            },
            results = {
                {type = "item", name = "battery-mk2-equipment", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 2465.71970588,
                dense_negative_support = 8,
                dense_positive_support = 5,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.929966591263,
            },
        },
        ["beacon"] = {
            mode = "givens-transformed",
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
            diagnostics = {
                pre_randomization_input_cost_budget = 368.297058824,
                dense_negative_support = 8,
                dense_positive_support = 4,
                kept_ingredient_count = 5,
                retained_negative_l2_fraction = 0.977156798088,
            },
        },
        ["belt-immunity-equipment"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "pump", amount = 2.60824594572},
                {type = "item", name = "advanced-circuit", amount = 3.14213295268},
                {type = "item", name = "flamethrower", amount = 0.582300973486},
            },
            results = {
                {type = "item", name = "belt-immunity-equipment", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 123.361764706,
                dense_negative_support = 6,
                dense_positive_support = 5,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.968984983587,
            },
        },
        ["big-electric-pole"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "battery", amount = 3.08736547469},
                {type = "item", name = "flamethrower-ammo", amount = 0.304753984893},
                {type = "item", name = "artillery-shell", amount = 0.0838512792748},
                {type = "item", name = "iron-stick", amount = 2.70645692418},
            },
            results = {
                {type = "item", name = "big-electric-pole", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 40.12,
                dense_negative_support = 6,
                dense_positive_support = 8,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.998169050596,
            },
        },
        ["boiler"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "pipe", amount = 2.42665766898},
                {type = "item", name = "crude-oil-barrel", amount = 0.238444482532},
                {type = "item", name = "cliff-explosives", amount = 0.0637242018144},
            },
            results = {
                {type = "item", name = "boiler", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 6.93,
                dense_negative_support = 5,
                dense_positive_support = 6,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.942575698265,
            },
        },
        ["buffer-chest"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "steel-chest", amount = 0.502349547481},
                {type = "item", name = "centrifuge", amount = 0.0135719215198},
                {type = "item", name = "fission-reactor-equipment", amount = 0.000861696250321},
                {type = "item", name = "productivity-module", amount = 0.0775299571872},
            },
            results = {
                {type = "item", name = "buffer-chest", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 73.5473529412,
                dense_negative_support = 5,
                dense_positive_support = 9,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.992957584672,
            },
        },
        ["bulk-inserter"] = {
            mode = "givens-transformed",
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
            diagnostics = {
                pre_randomization_input_cost_budget = 107.322352941,
                dense_negative_support = 9,
                dense_positive_support = 5,
                kept_ingredient_count = 5,
                retained_negative_l2_fraction = 0.990263386503,
            },
        },
        ["burner-inserter"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "fast-underground-belt", amount = 0.0322938921886},
                {type = "fluid", name = "petroleum-gas", amount = 13.6239503494},
                {type = "item", name = "steel-chest", amount = 0.0112197974129},
            },
            results = {
                {type = "item", name = "burner-inserter", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 3.11,
                dense_negative_support = 4,
                dense_positive_support = 6,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.971371941531,
            },
        },
        ["burner-mining-drill"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "personal-laser-defense-equipment", amount = 0.00106075664767},
                {type = "item", name = "steel-chest", amount = 0.0512277993246},
                {type = "item", name = "copper-plate", amount = 2.78618702954},
                {type = "item", name = "iron-gear-wheel", amount = 1.11961958373},
            },
            results = {
                {type = "item", name = "burner-mining-drill", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 11.18,
                dense_negative_support = 10,
                dense_positive_support = 6,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.923087081874,
            },
        },
        ["cannon-shell"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "medium-electric-pole", amount = 0.442150740096},
                {type = "item", name = "steel-plate", amount = 0.526575951481},
                {type = "item", name = "engine-unit", amount = 0.247382191437},
                {type = "item", name = "piercing-rounds-magazine", amount = 0.215917936865},
            },
            results = {
                {type = "item", name = "cannon-shell", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 15.9882352941,
                dense_negative_support = 9,
                dense_positive_support = 5,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.977455575844,
            },
        },
        ["car"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "engine-unit", amount = 4.35273725532},
                {type = "item", name = "steel-plate", amount = 6.69731345665},
                {type = "item", name = "iron-plate", amount = 38.9693061487},
                {type = "item", name = "advanced-circuit", amount = 1.47492996078},
            },
            results = {
                {type = "item", name = "car", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 151.14,
                dense_negative_support = 7,
                dense_positive_support = 4,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.98789863467,
            },
        },
        ["cargo-landing-pad"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "processing-unit", amount = 6.48881726547},
                {type = "item", name = "steel-plate", amount = 44.6345777624},
                {type = "item", name = "engine-unit", amount = 17.4638524485},
                {type = "item", name = "iron-gear-wheel", amount = 59.2346859111},
            },
            results = {
                {type = "item", name = "cargo-landing-pad", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 1215.57588235,
                dense_negative_support = 9,
                dense_positive_support = 4,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.962046162175,
            },
        },
        ["cargo-wagon"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "plastic-bar", amount = 66.2091642708},
                {type = "item", name = "steel-furnace", amount = 0.85206339886},
                {type = "item", name = "copper-cable", amount = 59.8611781475},
                {type = "item", name = "iron-plate", amount = 28.0834350722},
            },
            results = {
                {type = "item", name = "cargo-wagon", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 170.3,
                dense_negative_support = 6,
                dense_positive_support = 5,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.972020008044,
            },
        },
        ["centrifuge"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "advanced-circuit", amount = 46.4678525517},
                {type = "item", name = "productivity-module-2", amount = 0.603186920688},
                {type = "item", name = "steel-chest", amount = 7.24769753836},
                {type = "item", name = "fission-reactor-equipment", amount = 0.0124322074611},
                {type = "item", name = "steel-plate", amount = 21.1180448084},
            },
            results = {
                {type = "item", name = "centrifuge", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 1793.23529412,
                dense_negative_support = 8,
                dense_positive_support = 6,
                kept_ingredient_count = 5,
                retained_negative_l2_fraction = 0.990533728707,
            },
        },
        ["chemical-plant"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "productivity-module", amount = 0.330373586354},
                {type = "item", name = "steel-plate", amount = 2.80993119873},
                {type = "fluid", name = "crude-oil", amount = 381.905606914},
                {type = "item", name = "iron-gear-wheel", amount = 2.49831008484},
                {type = "item", name = "solar-panel", amount = 0.0623242227775},
            },
            results = {
                {type = "item", name = "chemical-plant", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 65.675,
                dense_negative_support = 7,
                dense_positive_support = 4,
                kept_ingredient_count = 5,
                retained_negative_l2_fraction = 0.992595752665,
            },
        },
        ["chemical-science-pack"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "advanced-circuit", amount = 1.44480893045},
                {type = "fluid", name = "petroleum-gas", amount = 276.163406347},
                {type = "item", name = "underground-belt", amount = 1.54261527064},
                {type = "item", name = "engine-unit", amount = 1.11508448755},
            },
            results = {
                {type = "item", name = "chemical-science-pack", amount = 2},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 61.2388235294,
                dense_negative_support = 6,
                dense_positive_support = 6,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.948888167547,
            },
        },
        ["cliff-explosives"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "barrel", amount = 1.23288331914},
                {type = "item", name = "explosives", amount = 6.77333245379},
                {type = "item", name = "grenade", amount = 0.677333245379},
                {type = "item", name = "pipe", amount = 3.75481933963},
            },
            results = {
                {type = "item", name = "cliff-explosives", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 26.6588235294,
                dense_negative_support = 7,
                dense_positive_support = 4,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.941538874802,
            },
        },
        ["cluster-grenade"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "grenade", amount = 3.65804636591},
                {type = "item", name = "light-armor", amount = 0.821856609538},
                {type = "item", name = "rocket-launcher", amount = 0.592305102694},
                {type = "item", name = "steel-plate", amount = 2.61289026137},
            },
            results = {
                {type = "item", name = "cluster-grenade", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 98.9294117647,
                dense_negative_support = 7,
                dense_positive_support = 5,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.955610392919,
            },
        },
        ["coal-liquefaction"] = {
            mode = "unchanged",
            reason = "multi-result recipe",
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
            reason = "one or more materials had an unbounded/unsupported LP price",
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
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "grenade", amount = 0.263687954153},
                {type = "item", name = "steel-plate", amount = 0.303516263577},
                {type = "item", name = "stone", amount = 5.38262338924},
                {type = "item", name = "battery", amount = 0.182109758146},
            },
            results = {
                {type = "item", name = "concrete", amount = 10},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 6.9,
                dense_negative_support = 8,
                dense_positive_support = 4,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.940416174108,
            },
        },
        ["constant-combinator"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "electronic-circuit", amount = 1.3575273559},
                {type = "item", name = "steel-furnace", amount = 0.059069034122},
                {type = "item", name = "copper-cable", amount = 3.39381838975},
            },
            results = {
                {type = "item", name = "constant-combinator", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 9.525,
                dense_negative_support = 5,
                dense_positive_support = 5,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.921565901316,
            },
        },
        ["construction-robot"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "flying-robot-frame", amount = 0.4960419968},
                {type = "fluid", name = "lubricant", amount = 113.689267722},
                {type = "item", name = "barrel", amount = 2.27378535443},
            },
            results = {
                {type = "item", name = "construction-robot", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 56.6380588235,
                dense_negative_support = 7,
                dense_positive_support = 5,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.909565476039,
            },
        },
        ["copper-cable"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "copper-plate", amount = 0.557002907687},
                {type = "item", name = "processing-unit", amount = 0.00458405556845},
            },
            results = {
                {type = "item", name = "copper-cable", amount = 2},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 0.92,
                dense_negative_support = 8,
                dense_positive_support = 5,
                kept_ingredient_count = 2,
                retained_negative_l2_fraction = 0.809113106458,
            },
        },
        ["copper-plate"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "artillery-wagon", amount = 0.000131403800228},
                {type = "item", name = "copper-ore", amount = 0.413813315581},
            },
            results = {
                {type = "item", name = "copper-plate", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 0.3,
                dense_negative_support = 6,
                dense_positive_support = 6,
                kept_ingredient_count = 2,
                retained_negative_l2_fraction = 0.920485969335,
            },
        },
        ["crude-oil-barrel"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "barrel", amount = 0.571058489034},
                {type = "item", name = "processing-unit", amount = 0.0276986243691},
                {type = "item", name = "pipe", amount = 1.57250278392},
            },
            results = {
                {type = "item", name = "crude-oil-barrel", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 8.4,
                dense_negative_support = 9,
                dense_positive_support = 4,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.854048202029,
            },
        },
        ["decider-combinator"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "electronic-circuit", amount = 2.69338153995},
                {type = "item", name = "transport-belt", amount = 3.71043746713},
                {type = "item", name = "energy-shield-equipment", amount = 0.0327242021813},
            },
            results = {
                {type = "item", name = "decider-combinator", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 19.05,
                dense_negative_support = 6,
                dense_positive_support = 5,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.923342629844,
            },
        },
        ["defender-capsule"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "electronic-circuit", amount = 4.70576847732},
                {type = "item", name = "selector-combinator", amount = 0.0948508105198},
                {type = "item", name = "piercing-rounds-magazine", amount = 0.938733737819},
                {type = "item", name = "iron-gear-wheel", amount = 3.48822414935},
            },
            results = {
                {type = "item", name = "defender-capsule", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 42.195,
                dense_negative_support = 6,
                dense_positive_support = 5,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.969897649372,
            },
        },
        ["destroyer-capsule"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "distractor-capsule", amount = 1.79226574711},
                {type = "item", name = "barrel", amount = 48.364178316},
                {type = "item", name = "electronic-circuit", amount = 64.863506802},
            },
            results = {
                {type = "item", name = "destroyer-capsule", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 916.025,
                dense_negative_support = 11,
                dense_positive_support = 4,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.940888967128,
            },
        },
        ["discharge-defense-equipment"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 197.211130005},
                {type = "item", name = "laser-turret", amount = 3.57732340972},
                {type = "item", name = "advanced-circuit", amount = 43.7678953705},
                {type = "item", name = "accumulator", amount = 15.1234069271},
            },
            results = {
                {type = "item", name = "discharge-defense-equipment", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 3203.52147059,
                dense_negative_support = 5,
                dense_positive_support = 5,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.995825242599,
            },
        },
        ["display-panel"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "electronic-circuit", amount = 0.634698741782},
                {type = "item", name = "exoskeleton-equipment", amount = 0.00064872006648},
                {type = "item", name = "battery-mk2-equipment", amount = 0.000403078920379},
            },
            results = {
                {type = "item", name = "display-panel", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 4.095,
                dense_negative_support = 5,
                dense_positive_support = 7,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.94710555115,
            },
        },
        ["distractor-capsule"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "electric-mining-drill", amount = 2.92378613192},
                {type = "item", name = "stone-furnace", amount = 34.3951723382},
                {type = "item", name = "defender-capsule", amount = 1.30132217271},
            },
            results = {
                {type = "item", name = "distractor-capsule", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 208.197058824,
                dense_negative_support = 5,
                dense_positive_support = 6,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.945197092029,
            },
        },
        ["efficiency-module"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "advanced-circuit", amount = 2.81349472959},
                {type = "item", name = "logistic-science-pack", amount = 2.94580541802},
                {type = "item", name = "steel-plate", amount = 2.16981138861},
            },
            results = {
                {type = "item", name = "efficiency-module", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 74.2367647059,
                dense_negative_support = 9,
                dense_positive_support = 5,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.966800238597,
            },
        },
        ["efficiency-module-2"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "processing-unit", amount = 3.49328079573},
                {type = "item", name = "efficiency-module", amount = 2.30069560906},
                {type = "item", name = "splitter", amount = 6.0296809828},
                {type = "item", name = "energy-shield-equipment", amount = 1.2348225688},
            },
            results = {
                {type = "item", name = "efficiency-module-2", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 807.046764706,
                dense_negative_support = 7,
                dense_positive_support = 7,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.945445659857,
            },
        },
        ["efficiency-module-3"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "rail-signal", amount = 182.841147131},
                {type = "item", name = "efficiency-module-2", amount = 1.25988262723},
                {type = "item", name = "steel-plate", amount = 100.018313103},
                {type = "item", name = "iron-gear-wheel", amount = 268.329496901},
            },
            results = {
                {type = "item", name = "efficiency-module-3", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 3744.28676471,
                dense_negative_support = 7,
                dense_positive_support = 5,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.995650207805,
            },
        },
        ["electric-engine-unit"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "engine-unit", amount = 0.591557586936},
                {type = "item", name = "cargo-landing-pad", amount = 0.00477542260889},
                {type = "item", name = "explosive-cannon-shell", amount = 0.219976799744},
                {type = "item", name = "electronic-circuit", amount = 1.18311517387},
            },
            results = {
                {type = "item", name = "electric-engine-unit", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 20.9915384615,
                dense_negative_support = 10,
                dense_positive_support = 5,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.948929295929,
            },
        },
        ["electric-furnace"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 7.83932030427},
                {type = "item", name = "advanced-circuit", amount = 3.48081109877},
                {type = "item", name = "productivity-module-3", amount = 0.00813387374876},
                {type = "item", name = "solar-panel", amount = 0.156583874848},
            },
            results = {
                {type = "item", name = "electric-furnace", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 135.561764706,
                dense_negative_support = 13,
                dense_positive_support = 4,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.964020874792,
            },
        },
        ["electric-mining-drill"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "fission-reactor-equipment", amount = 0.000558759730956},
                {type = "item", name = "defender-capsule", amount = 0.203561219396},
                {type = "item", name = "buffer-chest", amount = 0.0806627670821},
                {type = "item", name = "iron-gear-wheel", amount = 1.76847235956},
            },
            results = {
                {type = "item", name = "electric-mining-drill", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 29.675,
                dense_negative_support = 7,
                dense_positive_support = 6,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.965706264402,
            },
        },
        ["electronic-circuit"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "assembling-machine-3", amount = 0.00291119930088},
                {type = "fluid", name = "petroleum-gas", amount = 13.8224568497},
                {type = "item", name = "copper-cable", amount = 1.18896646567},
            },
            results = {
                {type = "item", name = "electronic-circuit", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 2.825,
                dense_negative_support = 6,
                dense_positive_support = 7,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.930285559519,
            },
        },
        ["empty-crude-oil-barrel"] = {
            mode = "unchanged",
            reason = "multi-result recipe",
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
            reason = "multi-result recipe",
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
            reason = "multi-result recipe",
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
            reason = "multi-result recipe",
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
            reason = "multi-result recipe",
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
            reason = "multi-result recipe",
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
            reason = "multi-result recipe",
            ingredients = {
                {type = "item", name = "water-barrel", amount = 1},
            },
            results = {
                {type = "fluid", name = "water", amount = 50},
                {type = "item", name = "barrel", amount = 1},
            },
        },
        ["energy-shield-equipment"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "utility-science-pack", amount = 0.424227341893},
                {type = "item", name = "transport-belt", amount = 22.8870182764},
                {type = "item", name = "explosive-cannon-shell", amount = 1.92871420241},
            },
            results = {
                {type = "item", name = "energy-shield-equipment", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 123.361764706,
                dense_negative_support = 6,
                dense_positive_support = 7,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.849536962917,
            },
        },
        ["energy-shield-mk2-equipment"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "energy-shield-equipment", amount = 5.69143914881},
                {type = "item", name = "efficiency-module-2", amount = 0.685332462445},
                {type = "item", name = "processing-unit", amount = 3.62231338485},
                {type = "item", name = "iron-gear-wheel", amount = 134.142493801},
            },
            results = {
                {type = "item", name = "energy-shield-mk2-equipment", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 1880.685,
                dense_negative_support = 8,
                dense_positive_support = 5,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.909113971733,
            },
        },
        ["engine-unit"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "gate", amount = 0.153657953134},
                {type = "item", name = "submachine-gun", amount = 0.106090411077},
                {type = "item", name = "rail-signal", amount = 0.312873490473},
                {type = "item", name = "pipe", amount = 0.586143468983},
            },
            results = {
                {type = "item", name = "engine-unit", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 11.23,
                dense_negative_support = 4,
                dense_positive_support = 7,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 1,
            },
        },
        ["exoskeleton-equipment"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "processing-unit", amount = 6.00217637931},
                {type = "item", name = "iron-gear-wheel", amount = 185.483930953},
                {type = "item", name = "electric-engine-unit", amount = 18.0065291379},
                {type = "item", name = "requester-chest", amount = 4.6900186642},
            },
            results = {
                {type = "item", name = "exoskeleton-equipment", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 1687.8220362,
                dense_negative_support = 8,
                dense_positive_support = 5,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.892693210794,
            },
        },
        ["explosive-cannon-shell"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "uranium-rounds-magazine", amount = 0.406010933465},
                {type = "item", name = "steel-plate", amount = 0.889703028676},
                {type = "item", name = "automation-science-pack", amount = 1.01017859519},
                {type = "item", name = "plastic-bar", amount = 0.889703028676},
            },
            results = {
                {type = "item", name = "explosive-cannon-shell", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 17.0941176471,
                dense_negative_support = 5,
                dense_positive_support = 6,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.996260175245,
            },
        },
        ["explosive-rocket"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "active-provider-chest", amount = 0.0377584244089},
                {type = "item", name = "steam-turbine", amount = 0.00881523795275},
                {type = "item", name = "rocket", amount = 0.402490704114},
            },
            results = {
                {type = "item", name = "explosive-rocket", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 5.85764705882,
                dense_negative_support = 5,
                dense_positive_support = 8,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.905923702186,
            },
        },
        ["explosive-uranium-cannon-shell"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "energy-shield-equipment", amount = 0.0774191769994},
                {type = "item", name = "utility-science-pack", amount = 0.0739961120672},
                {type = "item", name = "explosive-cannon-shell", amount = 0.336417147538},
            },
            results = {
                {type = "item", name = "explosive-uranium-cannon-shell", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 24.2623600498,
                dense_negative_support = 6,
                dense_positive_support = 7,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.948987220282,
            },
        },
        ["explosives"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "logistic-science-pack", amount = 0.0560666575125},
                {type = "item", name = "sulfur", amount = 0.356022493177},
                {type = "item", name = "efficiency-module", amount = 0.00413101439986},
                {type = "item", name = "iron-gear-wheel", amount = 0.120814514629},
            },
            results = {
                {type = "item", name = "explosives", amount = 2},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 1.51176470588,
                dense_negative_support = 8,
                dense_positive_support = 6,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.944672108991,
            },
        },
        ["express-splitter"] = {
            mode = "givens-transformed",
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
            diagnostics = {
                pre_randomization_input_cost_budget = 231.830067873,
                dense_negative_support = 11,
                dense_positive_support = 4,
                kept_ingredient_count = 5,
                retained_negative_l2_fraction = 0.920359170086,
            },
        },
        ["express-transport-belt"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "production-science-pack", amount = 0.148785437157},
                {type = "item", name = "battery-equipment", amount = 0.104092262372},
                {type = "item", name = "iron-gear-wheel", amount = 3.2892800972},
                {type = "item", name = "fast-transport-belt", amount = 0.32892800972},
            },
            results = {
                {type = "item", name = "express-transport-belt", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 37.7453846154,
                dense_negative_support = 7,
                dense_positive_support = 7,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.978159015592,
            },
        },
        ["express-underground-belt"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "long-handed-inserter", amount = 10.1437884618},
                {type = "item", name = "iron-gear-wheel", amount = 37.429485118},
                {type = "item", name = "storage-chest", amount = 0.796195709503},
                {type = "item", name = "fast-underground-belt", amount = 0.826928010246},
            },
            results = {
                {type = "item", name = "express-underground-belt", amount = 2},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 287.180769231,
                dense_negative_support = 7,
                dense_positive_support = 6,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.997764990553,
            },
        },
        ["fast-inserter"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "inserter", amount = 0.709814256126},
                {type = "item", name = "electronic-circuit", amount = 1.41962851225},
                {type = "item", name = "shotgun-shell", amount = 0.674284574982},
                {type = "item", name = "cliff-explosives", amount = 0.09806337435},
            },
            results = {
                {type = "item", name = "fast-inserter", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 14.825,
                dense_negative_support = 9,
                dense_positive_support = 5,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.898487529201,
            },
        },
        ["fast-splitter"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "copper-plate", amount = 30.1801440371},
                {type = "item", name = "electronic-circuit", amount = 6.03798538609},
                {type = "item", name = "steel-plate", amount = 2.72708976991},
                {type = "item", name = "splitter", amount = 0.603798538609},
            },
            results = {
                {type = "item", name = "fast-splitter", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 81.445,
                dense_negative_support = 8,
                dense_positive_support = 4,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.940867336788,
            },
        },
        ["fast-transport-belt"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "arithmetic-combinator", amount = 0.245035030044},
                {type = "item", name = "gun-turret", amount = 0.0830392334608},
                {type = "item", name = "iron-gear-wheel", amount = 1.70070100641},
            },
            results = {
                {type = "item", name = "fast-transport-belt", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 12.68,
                dense_negative_support = 7,
                dense_positive_support = 6,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.963402011851,
            },
        },
        ["fast-underground-belt"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "iron-gear-wheel", amount = 19.5995732958},
                {type = "item", name = "underground-belt", amount = 3.83055339706},
                {type = "item", name = "electronic-circuit", amount = 8.81043613674},
            },
            results = {
                {type = "item", name = "fast-underground-belt", amount = 2},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 105.85,
                dense_negative_support = 5,
                dense_positive_support = 5,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.986516318844,
            },
        },
        ["firearm-magazine"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "fluid", name = "petroleum-gas", amount = 32.9398989726},
                {type = "item", name = "splitter", amount = 0.0623374951748},
            },
            results = {
                {type = "item", name = "firearm-magazine", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 3.68,
                dense_negative_support = 5,
                dense_positive_support = 5,
                kept_ingredient_count = 2,
                retained_negative_l2_fraction = 0.776525645452,
            },
        },
        ["fission-reactor-equipment"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "processing-unit", amount = 89.444896911},
                {type = "item", name = "defender-capsule", amount = 130.142366478},
                {type = "item", name = "steel-chest", amount = 64.5614965297},
                {type = "item", name = "electronic-circuit", amount = 872.064719201},
            },
            results = {
                {type = "item", name = "fission-reactor-equipment", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 19735.4436478,
                dense_negative_support = 9,
                dense_positive_support = 4,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.940972221103,
            },
        },
        ["flamethrower"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 3.44176325717},
                {type = "item", name = "construction-robot", amount = 0.34448952393},
                {type = "item", name = "iron-gear-wheel", amount = 5.66061624412},
            },
            results = {
                {type = "item", name = "flamethrower", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 54.4,
                dense_negative_support = 5,
                dense_positive_support = 6,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.947395806733,
            },
        },
        ["flamethrower-ammo"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "nuclear-reactor", amount = 0.0017880427466},
                {type = "item", name = "battery", amount = 2.05947516136},
                {type = "item", name = "steel-plate", amount = 0.950822783592},
            },
            results = {
                {type = "item", name = "flamethrower-ammo", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 35.5,
                dense_negative_support = 6,
                dense_positive_support = 7,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.970681213794,
            },
        },
        ["flamethrower-turret"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 18.5767098332},
                {type = "item", name = "efficiency-module", amount = 0.954635019288},
                {type = "item", name = "engine-unit", amount = 3.09611830553},
                {type = "fluid", name = "lubricant", amount = 254.940852612},
                {type = "item", name = "barrel", amount = 5.09881705224},
            },
            results = {
                {type = "item", name = "flamethrower-turret", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 303.2,
                dense_negative_support = 9,
                dense_positive_support = 5,
                kept_ingredient_count = 5,
                retained_negative_l2_fraction = 0.967146744082,
            },
        },
        ["fluid-wagon"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "electronic-circuit", amount = 19.9546838425},
                {type = "item", name = "steel-plate", amount = 7.98994879372},
                {type = "item", name = "processing-unit", amount = 0.289321133018},
                {type = "item", name = "storage-tank", amount = 0.499371799607},
                {type = "item", name = "uranium-235", amount = 0.867963399053},
            },
            results = {
                {type = "item", name = "fluid-wagon", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 187.56,
                dense_negative_support = 12,
                dense_positive_support = 4,
                kept_ingredient_count = 5,
                retained_negative_l2_fraction = 0.961151736467,
            },
        },
        ["flying-robot-frame"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "power-armor-mk2", amount = 0.000293159468798},
                {type = "item", name = "electric-engine-unit", amount = 0.464053269115},
                {type = "item", name = "steel-plate", amount = 1.46018415817},
                {type = "item", name = "assembling-machine-3", amount = 0.0185587684665},
                {type = "item", name = "electronic-circuit", amount = 2.4117434539},
            },
            results = {
                {type = "item", name = "flying-robot-frame", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 49.4995972851,
                dense_negative_support = 8,
                dense_positive_support = 8,
                kept_ingredient_count = 5,
                retained_negative_l2_fraction = 0.952167505809,
            },
        },
        ["gate"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 2.18302948138},
                {type = "fluid", name = "light-oil", amount = 67.1804686609},
                {type = "item", name = "concrete", amount = 4.91097191425},
                {type = "item", name = "stone-wall", amount = 0.447637971401},
            },
            results = {
                {type = "item", name = "gate", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 25.8,
                dense_negative_support = 9,
                dense_positive_support = 4,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.958620726032,
            },
        },
        ["grenade"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "iron-plate", amount = 3.58702128961},
                {type = "item", name = "coal", amount = 7.17404257922},
                {type = "item", name = "piercing-rounds-magazine", amount = 0.246865245953},
            },
            results = {
                {type = "item", name = "grenade", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 7.6,
                dense_negative_support = 9,
                dense_positive_support = 6,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.909741374023,
            },
        },
        ["gun-turret"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "iron-gear-wheel", amount = 8.17562909891},
                {type = "item", name = "explosives", amount = 14.8233371565},
                {type = "item", name = "arithmetic-combinator", amount = 0.404754419703},
                {type = "item", name = "iron-plate", amount = 7.98942343265},
            },
            results = {
                {type = "item", name = "gun-turret", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 49.5,
                dense_negative_support = 6,
                dense_positive_support = 7,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.989116754404,
            },
        },
        ["hazard-concrete"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "concrete", amount = 6.80234386612},
                {type = "item", name = "military-science-pack", amount = 0.165954305683},
            },
            results = {
                {type = "item", name = "hazard-concrete", amount = 10},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 8.2,
                dense_negative_support = 7,
                dense_positive_support = 6,
                kept_ingredient_count = 2,
                retained_negative_l2_fraction = 0.890945477493,
            },
        },
        ["heat-exchanger"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "burner-mining-drill", amount = 4.52026885062},
                {type = "item", name = "storage-chest", amount = 0.620469922833},
                {type = "item", name = "personal-laser-defense-equipment", amount = 0.0124654073956},
                {type = "item", name = "copper-plate", amount = 32.7416815909},
            },
            results = {
                {type = "item", name = "heat-exchanger", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 169.7,
                dense_negative_support = 6,
                dense_positive_support = 10,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.969947567858,
            },
        },
        ["heat-pipe"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "solid-fuel", amount = 37.4497124759},
                {type = "item", name = "steel-plate", amount = 4.90371421723},
                {type = "item", name = "pipe-to-ground", amount = 2.11923921416},
            },
            results = {
                {type = "item", name = "heat-pipe", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 83.4,
                dense_negative_support = 7,
                dense_positive_support = 5,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.933259908511,
            },
        },
        ["heavy-armor"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "power-armor-mk2", amount = 0.00309808632463},
                {type = "item", name = "pumpjack", amount = 1.61449232834},
                {type = "item", name = "steel-plate", amount = 20.5517255128},
            },
            results = {
                {type = "item", name = "heavy-armor", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 417,
                dense_negative_support = 5,
                dense_positive_support = 10,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.878133692684,
            },
        },
        ["heavy-oil-barrel"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "barrel", amount = 0.606523853364},
                {type = "item", name = "artillery-turret", amount = 0.00537412840309},
                {type = "item", name = "refined-hazard-concrete", amount = 1.19087498315},
            },
            results = {
                {type = "item", name = "heavy-oil-barrel", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 11.9384615385,
                dense_negative_support = 5,
                dense_positive_support = 7,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.87791567348,
            },
        },
        ["heavy-oil-cracking"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "fluid", name = "heavy-oil", amount = 22.6450712265},
                {type = "item", name = "steel-plate", amount = 0.177139228975},
                {type = "item", name = "uranium-238", amount = 0.123172046306},
            },
            results = {
                {type = "fluid", name = "light-oil", amount = 30},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 4.18076923077,
                dense_negative_support = 11,
                dense_positive_support = 4,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.973227012519,
            },
        },
        ["inserter"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "defender-capsule", amount = 0.0538493842381},
                {type = "item", name = "decider-combinator", amount = 0.0816151194189},
                {type = "item", name = "electronic-circuit", amount = 0.473367904878},
                {type = "item", name = "iron-plate", amount = 0.942733146409},
            },
            results = {
                {type = "item", name = "inserter", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 6.285,
                dense_negative_support = 7,
                dense_positive_support = 4,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.973847404373,
            },
        },
        ["iron-chest"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "iron-plate", amount = 4.59372848359},
                {type = "item", name = "slowdown-capsule", amount = 0.142768555585},
            },
            results = {
                {type = "item", name = "iron-chest", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 7.36,
                dense_negative_support = 6,
                dense_positive_support = 7,
                kept_ingredient_count = 2,
                retained_negative_l2_fraction = 0.952419151459,
            },
        },
        ["iron-gear-wheel"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "low-density-structure", amount = 0.0244277186998},
                {type = "item", name = "iron-plate", amount = 0.993528009582},
            },
            results = {
                {type = "item", name = "iron-gear-wheel", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 1.84,
                dense_negative_support = 6,
                dense_positive_support = 6,
                kept_ingredient_count = 2,
                retained_negative_l2_fraction = 0.77532089677,
            },
        },
        ["iron-plate"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "engine-unit", amount = 0.0129614284762},
                {type = "item", name = "constant-combinator", amount = 0.013933498855},
            },
            results = {
                {type = "item", name = "iron-plate", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 0.3,
                dense_negative_support = 8,
                dense_positive_support = 5,
                kept_ingredient_count = 2,
                retained_negative_l2_fraction = 0.85135450155,
            },
        },
        ["iron-stick"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "stone-brick", amount = 0.433511245336},
                {type = "item", name = "iron-plate", amount = 0.425126392055},
            },
            results = {
                {type = "item", name = "iron-stick", amount = 2},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 0.92,
                dense_negative_support = 6,
                dense_positive_support = 4,
                kept_ingredient_count = 2,
                retained_negative_l2_fraction = 0.929938527595,
            },
        },
        ["kovarex-enrichment-process"] = {
            mode = "unchanged",
            reason = "multi-result recipe",
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
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "electronic-circuit", amount = 7.38231834951},
                {type = "item", name = "iron-gear-wheel", amount = 7.38231834951},
                {type = "item", name = "explosive-cannon-shell", amount = 0.62123614888},
                {type = "item", name = "steel-plate", amount = 1.4863105347},
            },
            results = {
                {type = "item", name = "lab", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 60.57,
                dense_negative_support = 10,
                dense_positive_support = 4,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.898337179436,
            },
        },
        ["land-mine"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "roboport", amount = 0.00505961817469},
                {type = "item", name = "rocket-silo", amount = 7.01915714315e-05},
                {type = "item", name = "steel-chest", amount = 0.0383471667562},
            },
            results = {
                {type = "item", name = "land-mine", amount = 4},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 8.71176470588,
                dense_negative_support = 6,
                dense_positive_support = 8,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.974066229521,
            },
        },
        ["landfill"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "stone", amount = 26.8844888482},
                {type = "item", name = "depleted-uranium-fuel-cell", amount = 0.44288327337},
            },
            results = {
                {type = "item", name = "landfill", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 15,
                dense_negative_support = 5,
                dense_positive_support = 4,
                kept_ingredient_count = 2,
                retained_negative_l2_fraction = 0.884346068446,
            },
        },
        ["laser-turret"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "concrete", amount = 138.812071397},
                {type = "item", name = "steel-plate", amount = 9.67187386209},
                {type = "item", name = "stone", amount = 171.523113306},
                {type = "item", name = "battery", amount = 5.80312431725},
            },
            results = {
                {type = "item", name = "laser-turret", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 260.598352941,
                dense_negative_support = 7,
                dense_positive_support = 5,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.957765743394,
            },
        },
        ["light-armor"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "iron-plate", amount = 25.8080416397},
                {type = "item", name = "car", amount = 0.0861026226027},
            },
            results = {
                {type = "item", name = "light-armor", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 36.8,
                dense_negative_support = 6,
                dense_positive_support = 5,
                kept_ingredient_count = 2,
                retained_negative_l2_fraction = 0.892510548089,
            },
        },
        ["light-oil-barrel"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "cliff-explosives", amount = 0.145812451709},
                {type = "item", name = "barrel", amount = 0.475780917833},
                {type = "item", name = "fast-inserter", amount = 0.20195239478},
            },
            results = {
                {type = "item", name = "light-oil-barrel", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 10.3950980392,
                dense_negative_support = 5,
                dense_positive_support = 9,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.908833637868,
            },
        },
        ["light-oil-cracking"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "fluid", name = "light-oil", amount = 17.6854064532},
                {type = "item", name = "fast-underground-belt", amount = 0.00951405562166},
                {type = "item", name = "steel-plate", amount = 0.0776775888463},
            },
            results = {
                {type = "fluid", name = "petroleum-gas", amount = 20},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 2.24705882353,
                dense_negative_support = 5,
                dense_positive_support = 5,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.993135559679,
            },
        },
        ["locomotive"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "engine-unit", amount = 14.264300604},
                {type = "item", name = "steel-plate", amount = 25.9845986995},
                {type = "item", name = "copper-cable", amount = 128.89326638},
                {type = "item", name = "advanced-circuit", amount = 4.1012465931},
            },
            results = {
                {type = "item", name = "locomotive", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 477.35,
                dense_negative_support = 6,
                dense_positive_support = 4,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.998498785885,
            },
        },
        ["logistic-robot"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "flying-robot-frame", amount = 0.592355926178},
                {type = "item", name = "steel-chest", amount = 0.468835629941},
                {type = "item", name = "advanced-circuit", amount = 1.6535474823},
            },
            results = {
                {type = "item", name = "logistic-robot", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 73.6327647059,
                dense_negative_support = 10,
                dense_positive_support = 4,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.886165260491,
            },
        },
        ["logistic-science-pack"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "inserter", amount = 0.589156488799},
                {type = "item", name = "advanced-circuit", amount = 0.217046462816},
                {type = "item", name = "sulfur", amount = 1.6548133787},
            },
            results = {
                {type = "item", name = "logistic-science-pack", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 8.365,
                dense_negative_support = 10,
                dense_positive_support = 4,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.919916810749,
            },
        },
        ["long-handed-inserter"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "inserter", amount = 0.393378301789},
                {type = "item", name = "speed-module-2", amount = 0.00313408351753},
                {type = "item", name = "radar", amount = 0.0660798989099},
                {type = "item", name = "iron-gear-wheel", amount = 1.00072338175},
            },
            results = {
                {type = "item", name = "long-handed-inserter", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 9.745,
                dense_negative_support = 8,
                dense_positive_support = 5,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.966494175701,
            },
        },
        ["low-density-structure"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "fluid", name = "lubricant", amount = 102.878062804},
                {type = "item", name = "iron-plate", amount = 8.40577354274},
                {type = "item", name = "uranium-235", amount = 0.306186440544},
                {type = "item", name = "copper-plate", amount = 7.11182349797},
            },
            results = {
                {type = "item", name = "low-density-structure", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 36.1058823529,
                dense_negative_support = 7,
                dense_positive_support = 4,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.954689280972,
            },
        },
        ["lubricant"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "nuclear-fuel", amount = 0.0128585349828},
                {type = "item", name = "iron-plate", amount = 0.497506232141},
            },
            results = {
                {type = "fluid", name = "lubricant", amount = 10},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 1.00769230769,
                dense_negative_support = 6,
                dense_positive_support = 5,
                kept_ingredient_count = 2,
                retained_negative_l2_fraction = 0.739525668761,
            },
        },
        ["lubricant-barrel"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "construction-robot", amount = 0.101459122849},
                {type = "item", name = "flamethrower", amount = 0.0774333009127},
                {type = "fluid", name = "lubricant", amount = 27.3033261284},
            },
            results = {
                {type = "item", name = "lubricant-barrel", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 13.9384615385,
                dense_negative_support = 5,
                dense_positive_support = 7,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.860881741994,
            },
        },
        ["medium-electric-pole"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 1.3124487626},
                {type = "item", name = "tank", amount = 0.00620435209059},
                {type = "item", name = "piercing-rounds-magazine", amount = 0.192440048066},
                {type = "item", name = "uranium-238", amount = 0.192440048066},
            },
            results = {
                {type = "item", name = "medium-electric-pole", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 16.81,
                dense_negative_support = 8,
                dense_positive_support = 6,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.990701512653,
            },
        },
        ["military-science-pack"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "speed-module", amount = 0.16452482485},
                {type = "item", name = "stone-wall", amount = 1.08306670448},
                {type = "item", name = "concrete", amount = 7.43041975145},
                {type = "item", name = "piercing-rounds-magazine", amount = 0.541533352242},
            },
            results = {
                {type = "item", name = "military-science-pack", amount = 2},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 30.3,
                dense_negative_support = 8,
                dense_positive_support = 5,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.952698141142,
            },
        },
        ["modular-armor"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "barrel", amount = 37.2716605693},
                {type = "item", name = "advanced-circuit", amount = 18.7254541644},
                {type = "item", name = "processing-unit", amount = 2.24307085902},
            },
            results = {
                {type = "item", name = "modular-armor", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 675.170588235,
                dense_negative_support = 6,
                dense_positive_support = 4,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.903628824192,
            },
        },
        ["night-vision-equipment"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 6.95098027772},
                {type = "item", name = "advanced-circuit", amount = 3.47549013886},
                {type = "item", name = "lab", amount = 0.615903804755},
            },
            results = {
                {type = "item", name = "night-vision-equipment", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 123.361764706,
                dense_negative_support = 5,
                dense_positive_support = 7,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.85290489278,
            },
        },
        ["nuclear-fuel"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "fluid", name = "heavy-oil", amount = 143.677474017},
                {type = "item", name = "uranium-235", amount = 0.572497921392},
                {type = "item", name = "steel-plate", amount = 1.049503825},
            },
            results = {
                {type = "item", name = "nuclear-fuel", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 35.0384093282,
                dense_negative_support = 6,
                dense_positive_support = 6,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.895636220054,
            },
        },
        ["nuclear-fuel-reprocessing"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "substation", amount = 0.340578329072},
                {type = "item", name = "depleted-uranium-fuel-cell", amount = 2.22625937912},
            },
            results = {
                {type = "item", name = "uranium-238", amount = 3},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 78.2898538113,
                dense_negative_support = 4,
                dense_positive_support = 5,
                kept_ingredient_count = 2,
                retained_negative_l2_fraction = 0.955646434586,
            },
        },
        ["nuclear-reactor"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 587.178659552},
                {type = "item", name = "battery", amount = 446.773277851},
                {type = "item", name = "advanced-circuit", amount = 186.966466388},
                {type = "item", name = "destroyer-capsule", amount = 1.32803460384},
                {type = "fluid", name = "crude-oil", amount = 8004.24386329},
            },
            results = {
                {type = "item", name = "nuclear-reactor", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 9956.17647059,
                dense_negative_support = 6,
                dense_positive_support = 7,
                kept_ingredient_count = 5,
                retained_negative_l2_fraction = 0.999566833048,
            },
        },
        ["offshore-pump"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "uranium-cannon-shell", amount = 0.143753978633},
                {type = "item", name = "iron-gear-wheel", amount = 1.06123576156},
                {type = "item", name = "landfill", amount = 0.151233023726},
            },
            results = {
                {type = "item", name = "offshore-pump", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 8.19,
                dense_negative_support = 6,
                dense_positive_support = 5,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.906259706698,
            },
        },
        ["oil-refinery"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 10.1489071458},
                {type = "item", name = "solar-panel", amount = 0.469060720623},
                {type = "item", name = "iron-gear-wheel", amount = 14.200604304},
                {type = "item", name = "electronic-circuit", amount = 7.16469349471},
                {type = "item", name = "fast-inserter", amount = 0.555054884384},
                {type = "item", name = "pipe", amount = 5.87478103828},
            },
            results = {
                {type = "item", name = "oil-refinery", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 176.05,
                dense_negative_support = 10,
                dense_positive_support = 4,
                kept_ingredient_count = 6,
                retained_negative_l2_fraction = 0.993475807742,
            },
        },
        ["passive-provider-chest"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "rocket-silo", amount = 0.000764945676649},
                {type = "item", name = "steel-chest", amount = 0.417906293074},
                {type = "item", name = "advanced-circuit", amount = 1.25093359952},
                {type = "item", name = "land-mine", amount = 6.12895027445},
            },
            results = {
                {type = "item", name = "passive-provider-chest", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 73.5473529412,
                dense_negative_support = 6,
                dense_positive_support = 8,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.993270679967,
            },
        },
        ["personal-laser-defense-equipment"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "crude-oil-barrel", amount = 154.185666837},
                {type = "item", name = "processing-unit", amount = 8.16246797729},
                {type = "item", name = "boiler", amount = 92.7869584363},
                {type = "item", name = "copper-plate", amount = 583.129920687},
            },
            results = {
                {type = "item", name = "personal-laser-defense-equipment", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 3282.17294118,
                dense_negative_support = 7,
                dense_positive_support = 6,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.935722772784,
            },
        },
        ["personal-roboport-equipment"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "speed-module-2", amount = 0.224778600866},
                {type = "item", name = "advanced-circuit", amount = 10.6518962791},
                {type = "item", name = "battery", amount = 20.4031815178},
                {type = "item", name = "steel-plate", amount = 16.7453350822},
                {type = "item", name = "iron-gear-wheel", amount = 25.8134157568},
            },
            results = {
                {type = "item", name = "personal-roboport-equipment", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 585.942352941,
                dense_negative_support = 7,
                dense_positive_support = 5,
                kept_ingredient_count = 5,
                retained_negative_l2_fraction = 0.98509284636,
            },
        },
        ["personal-roboport-mk2-equipment"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "processing-unit", amount = 62.9203160793},
                {type = "item", name = "hazard-concrete", amount = 3196.361042},
                {type = "item", name = "steel-plate", amount = 372.152134435},
                {type = "item", name = "electronic-circuit", amount = 581.766305371},
            },
            results = {
                {type = "item", name = "personal-roboport-mk2-equipment", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 12585.0882353,
                dense_negative_support = 9,
                dense_positive_support = 4,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.97847770847,
            },
        },
        ["petroleum-gas-barrel"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "decider-combinator", amount = 0.190763554797},
                {type = "item", name = "barrel", amount = 0.531309046802},
                {type = "item", name = "iron-plate", amount = 2.70547496408},
            },
            results = {
                {type = "item", name = "petroleum-gas-barrel", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 9.85588235294,
                dense_negative_support = 8,
                dense_positive_support = 5,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.915797833,
            },
        },
        ["piercing-rounds-magazine"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "beacon", amount = 0.019498711129},
                {type = "item", name = "firearm-magazine", amount = 1.11583623295},
                {type = "item", name = "iron-plate", amount = 2.57817499581},
                {type = "item", name = "steel-plate", amount = 0.362931005186},
            },
            results = {
                {type = "item", name = "piercing-rounds-magazine", amount = 2},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 16.5,
                dense_negative_support = 9,
                dense_positive_support = 6,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.971228886672,
            },
        },
        ["piercing-shotgun-shell"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "solar-panel-equipment", amount = 0.0373951930453},
                {type = "item", name = "fast-inserter", amount = 0.291194543905},
                {type = "item", name = "shotgun-shell", amount = 0.880386665264},
                {type = "fluid", name = "crude-oil", amount = 111.973635973},
            },
            results = {
                {type = "item", name = "piercing-shotgun-shell", amount = 2},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 16.9,
                dense_negative_support = 6,
                dense_positive_support = 7,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.977915861366,
            },
        },
        ["pipe"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "rail-chain-signal", amount = 0.057825009948},
                {type = "item", name = "pipe-to-ground", amount = 0.0510109681781},
            },
            results = {
                {type = "item", name = "pipe", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 0.92,
                dense_negative_support = 4,
                dense_positive_support = 4,
                kept_ingredient_count = 2,
                retained_negative_l2_fraction = 0.925189983182,
            },
        },
        ["pipe-to-ground"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "iron-plate", amount = 6.50744117334},
                {type = "item", name = "rail-chain-signal", amount = 0.709199562347},
                {type = "item", name = "steel-plate", amount = 0.853985796378},
            },
            results = {
                {type = "item", name = "pipe-to-ground", amount = 2},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 17.3,
                dense_negative_support = 5,
                dense_positive_support = 3,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.981062179049,
            },
        },
        ["plastic-bar"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "electronic-circuit", amount = 0.19947992715},
                {type = "item", name = "steel-furnace", amount = 0.00883597755251},
                {type = "fluid", name = "petroleum-gas", amount = 6.61901402919},
            },
            results = {
                {type = "item", name = "plastic-bar", amount = 2},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 1.48235294118,
                dense_negative_support = 6,
                dense_positive_support = 5,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.963041291753,
            },
        },
        ["poison-capsule"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "shotgun-shell", amount = 2.96588571107},
                {type = "fluid", name = "heavy-oil", amount = 80.1995913164},
                {type = "item", name = "steel-plate", amount = 1.16272434436},
                {type = "item", name = "electronic-circuit", amount = 1.16272434436},
            },
            results = {
                {type = "item", name = "poison-capsule", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 32.025,
                dense_negative_support = 5,
                dense_positive_support = 5,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.997733271713,
            },
        },
        ["power-armor"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "personal-roboport-mk2-equipment", amount = 0.0933869682318},
                {type = "item", name = "efficiency-module-3", amount = 0.302913644559},
                {type = "item", name = "steel-plate", amount = 166.599353256},
                {type = "item", name = "processing-unit", amount = 9.75885847676},
            },
            results = {
                {type = "item", name = "power-armor", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 4262.13429864,
                dense_negative_support = 6,
                dense_positive_support = 6,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.964822414516,
            },
        },
        ["power-armor-mk2"] = {
            mode = "givens-transformed",
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
            diagnostics = {
                pre_randomization_input_cost_budget = 47880.6315385,
                dense_negative_support = 11,
                dense_positive_support = 4,
                kept_ingredient_count = 6,
                retained_negative_l2_fraction = 0.988833298324,
            },
        },
        ["power-switch"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "inserter", amount = 0.664020857259},
                {type = "item", name = "electronic-circuit", amount = 1.11233620238},
                {type = "item", name = "programmable-speaker", amount = 0.151059484971},
                {type = "item", name = "copper-cable", amount = 4.58793674455},
            },
            results = {
                {type = "item", name = "power-switch", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 14.125,
                dense_negative_support = 6,
                dense_positive_support = 4,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.962733068473,
            },
        },
        ["processing-unit"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "burner-inserter", amount = 8.04796845495},
                {type = "item", name = "fast-underground-belt", amount = 0.479776556073},
                {type = "item", name = "electronic-circuit", amount = 5.86124089195},
                {type = "item", name = "underground-belt", amount = 1.71397908822},
            },
            results = {
                {type = "item", name = "processing-unit", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 87.6075882353,
                dense_negative_support = 6,
                dense_positive_support = 4,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.988584460562,
            },
        },
        ["production-science-pack"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "battery-equipment", amount = 1.20266436041},
                {type = "item", name = "iron-gear-wheel", amount = 38.0037848558},
                {type = "item", name = "electric-furnace", amount = 0.519721999284},
                {type = "item", name = "petroleum-gas-barrel", amount = 6.06480270154},
            },
            results = {
                {type = "item", name = "production-science-pack", amount = 3},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 329.173529412,
                dense_negative_support = 8,
                dense_positive_support = 6,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.886293103876,
            },
        },
        ["productivity-module"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "advanced-circuit", amount = 2.55592958074},
                {type = "item", name = "personal-roboport-equipment", amount = 0.0434997096517},
                {type = "item", name = "electronic-circuit", amount = 5.93958447201},
            },
            results = {
                {type = "item", name = "productivity-module", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 74.2367647059,
                dense_negative_support = 8,
                dense_positive_support = 4,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.91677394562,
            },
        },
        ["productivity-module-2"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "solid-fuel", amount = 281.829762516},
                {type = "item", name = "processing-unit", amount = 2.45381929699},
                {type = "item", name = "advanced-circuit", amount = 16.5008484466},
                {type = "item", name = "productivity-module", amount = 1.96305543759},
            },
            results = {
                {type = "item", name = "productivity-module-2", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 807.046764706,
                dense_negative_support = 9,
                dense_positive_support = 4,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.950552426101,
            },
        },
        ["productivity-module-3"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "productivity-module-2", amount = 1.88812926536},
                {type = "item", name = "assembling-machine-2", amount = 23.107523507},
                {type = "item", name = "advanced-circuit", amount = 35.8119290955},
                {type = "item", name = "processing-unit", amount = 3.84760625907},
            },
            results = {
                {type = "item", name = "productivity-module-3", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 3744.28676471,
                dense_negative_support = 11,
                dense_positive_support = 6,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.995136936343,
            },
        },
        ["programmable-speaker"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "electronic-circuit", amount = 2.36829880789},
                {type = "item", name = "fluid-wagon", amount = 0.0364855483067},
                {type = "item", name = "atomic-bomb", amount = 0.00211386389523},
                {type = "item", name = "copper-cable", amount = 3.49978497077},
                {type = "item", name = "iron-plate", amount = 1.23681264502},
            },
            results = {
                {type = "item", name = "programmable-speaker", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 21.175,
                dense_negative_support = 7,
                dense_positive_support = 9,
                kept_ingredient_count = 5,
                retained_negative_l2_fraction = 0.993669436376,
            },
        },
        ["pump"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "locomotive", amount = 0.0227171137623},
                {type = "item", name = "copper-plate", amount = 4.16180412361},
                {type = "item", name = "advanced-circuit", amount = 0.277922560246},
                {type = "item", name = "steel-plate", amount = 0.364186732109},
            },
            results = {
                {type = "item", name = "pump", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 20.3,
                dense_negative_support = 6,
                dense_positive_support = 4,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.998038966628,
            },
        },
        ["pumpjack"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "flying-robot-frame", amount = 0.654609063851},
                {type = "item", name = "power-armor-mk2", amount = 0.000551758452458},
                {type = "item", name = "iron-gear-wheel", amount = 3.70551571417},
                {type = "item", name = "steel-plate", amount = 1.19814879324},
                {type = "item", name = "speed-module", amount = 0.102137517706},
            },
            results = {
                {type = "item", name = "pumpjack", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 82.975,
                dense_negative_support = 7,
                dense_positive_support = 9,
                kept_ingredient_count = 5,
                retained_negative_l2_fraction = 0.991844887602,
            },
        },
        ["radar"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "arithmetic-combinator", amount = 0.609172624969},
                {type = "item", name = "speed-module-2", amount = 0.0132990269078},
                {type = "item", name = "fast-transport-belt", amount = 0.643241392981},
                {type = "item", name = "iron-plate", amount = 5.48781771367},
            },
            results = {
                {type = "item", name = "radar", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 36.025,
                dense_negative_support = 6,
                dense_positive_support = 6,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.996854437611,
            },
        },
        ["rail"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 0.532093318582},
                {type = "item", name = "bulk-inserter", amount = 0.0190507557335},
                {type = "item", name = "iron-chest", amount = 0.214663721465},
                {type = "item", name = "iron-stick", amount = 0.425348726916},
            },
            results = {
                {type = "item", name = "rail", amount = 2},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 7.435,
                dense_negative_support = 6,
                dense_positive_support = 7,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.999402794413,
            },
        },
        ["rail-chain-signal"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "iron-plate", amount = 4.30032109148},
                {type = "item", name = "electronic-circuit", amount = 0.695654746348},
                {type = "item", name = "express-splitter", amount = 0.00711807050061},
            },
            results = {
                {type = "item", name = "rail-chain-signal", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 7.775,
                dense_negative_support = 4,
                dense_positive_support = 7,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.994493430785,
            },
        },
        ["rail-signal"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "efficiency-module-2", amount = 0.00352614311317},
                {type = "item", name = "iron-plate", amount = 2.70181022132},
                {type = "item", name = "submachine-gun", amount = 0.0657279981819},
            },
            results = {
                {type = "item", name = "rail-signal", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 7.775,
                dense_negative_support = 7,
                dense_positive_support = 5,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.887020467228,
            },
        },
        ["refined-concrete"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "heat-pipe", amount = 0.12578082679},
                {type = "item", name = "solid-fuel", amount = 9.04305797458},
                {type = "item", name = "pipe", amount = 3.43777444094},
                {type = "item", name = "concrete", amount = 4.95883242653},
                {type = "item", name = "iron-plate", amount = 1.71888722047},
            },
            results = {
                {type = "item", name = "refined-concrete", amount = 10},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 28.48,
                dense_negative_support = 7,
                dense_positive_support = 5,
                kept_ingredient_count = 5,
                retained_negative_l2_fraction = 0.996243728766,
            },
        },
        ["refined-hazard-concrete"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "refined-concrete", amount = 6.34018845191},
                {type = "item", name = "stone-brick", amount = 9.08353226854},
            },
            results = {
                {type = "item", name = "refined-hazard-concrete", amount = 10},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 30.28,
                dense_negative_support = 5,
                dense_positive_support = 7,
                kept_ingredient_count = 2,
                retained_negative_l2_fraction = 0.881717856288,
            },
        },
        ["repair-pack"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "electronic-circuit", amount = 1.35739435604},
                {type = "item", name = "rocket-fuel", amount = 0.312247457419},
                {type = "item", name = "iron-gear-wheel", amount = 1.35739435604},
            },
            results = {
                {type = "item", name = "repair-pack", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 10.73,
                dense_negative_support = 9,
                dense_positive_support = 7,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.771456454497,
            },
        },
        ["requester-chest"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "steel-chest", amount = 0.474425145234},
                {type = "item", name = "logistic-robot", amount = 0.332102431377},
                {type = "item", name = "rocket-part", amount = 0.0111484658631},
                {type = "item", name = "iron-gear-wheel", amount = 4.17790483374},
            },
            results = {
                {type = "item", name = "requester-chest", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 73.5473529412,
                dense_negative_support = 7,
                dense_positive_support = 7,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.982639827677,
            },
        },
        ["roboport"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "automation-science-pack", amount = 94.7129396204},
                {type = "item", name = "explosive-cannon-shell", amount = 12.7614484122},
                {type = "item", name = "advanced-circuit", amount = 14.3000740233},
                {type = "item", name = "steel-plate", amount = 22.5968436298},
            },
            results = {
                {type = "item", name = "roboport", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 916.305882353,
                dense_negative_support = 5,
                dense_positive_support = 5,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.995520028678,
            },
        },
        ["rocket"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "petroleum-gas-barrel", amount = 0.140616503539},
                {type = "item", name = "decider-combinator", amount = 0.0466899836429},
                {type = "item", name = "iron-plate", amount = 0.662173558014},
            },
            results = {
                {type = "item", name = "rocket", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 2.94588235294,
                dense_negative_support = 5,
                dense_positive_support = 8,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.93326390971,
            },
        },
        ["rocket-fuel"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "solid-fuel", amount = 4.21832228842},
                {type = "item", name = "productivity-module-2", amount = 0.00435594383851},
                {type = "item", name = "centrifuge", amount = 0.0012467925032},
            },
            results = {
                {type = "item", name = "rocket-fuel", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 9.4637254902,
                dense_negative_support = 6,
                dense_positive_support = 7,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.96803215299,
            },
        },
        ["rocket-launcher"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "destroyer-capsule", amount = 0.0144628164412},
                {type = "item", name = "barrel", amount = 1.13260687371},
                {type = "item", name = "nuclear-reactor", amount = 0.000553652895115},
                {type = "item", name = "electronic-circuit", amount = 1.5189931105},
            },
            results = {
                {type = "item", name = "rocket-launcher", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 31.425,
                dense_negative_support = 7,
                dense_positive_support = 8,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.978220156427,
            },
        },
        ["rocket-part"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "copper-cable", amount = 765.359895743},
                {type = "item", name = "processing-unit", amount = 3.80621245744},
                {type = "item", name = "logistic-robot", amount = 4.1178628054},
                {type = "item", name = "locomotive", amount = 0.521892881217},
            },
            results = {
                {type = "item", name = "rocket-part", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 1378.54647059,
                dense_negative_support = 6,
                dense_positive_support = 7,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.97839634262,
            },
        },
        ["rocket-silo"] = {
            mode = "givens-transformed",
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
            diagnostics = {
                pre_randomization_input_cost_budget = 29686.8253394,
                dense_negative_support = 11,
                dense_positive_support = 4,
                kept_ingredient_count = 6,
                retained_negative_l2_fraction = 0.970593994608,
            },
        },
        ["satellite"] = {
            mode = "givens-transformed",
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
            diagnostics = {
                pre_randomization_input_cost_budget = 25127.5455882,
                dense_negative_support = 9,
                dense_positive_support = 7,
                kept_ingredient_count = 6,
                retained_negative_l2_fraction = 0.993613021092,
            },
        },
        ["selector-combinator"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "iron-gear-wheel", amount = 25.5928429014},
                {type = "item", name = "decider-combinator", amount = 1.90078808383},
                {type = "item", name = "piercing-rounds-magazine", amount = 3.15184955194},
            },
            results = {
                {type = "item", name = "selector-combinator", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 120.344705882,
                dense_negative_support = 8,
                dense_positive_support = 4,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.929740917406,
            },
        },
        ["shotgun"] = {
            mode = "unchanged",
            reason = "one or more materials had an unbounded/unsupported LP price",
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
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "iron-plate", amount = 1.64411345192},
                {type = "item", name = "steel-plate", amount = 0.199459384277},
                {type = "item", name = "copper-plate", amount = 0.946662637427},
            },
            results = {
                {type = "item", name = "shotgun-shell", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 3.68,
                dense_negative_support = 6,
                dense_positive_support = 4,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.928554665712,
            },
        },
        ["slowdown-capsule"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "accumulator", amount = 0.24011703041},
                {type = "item", name = "steel-plate", amount = 0.863471006122},
                {type = "item", name = "iron-plate", amount = 4.88472698547},
                {type = "item", name = "discharge-defense-equipment", amount = 0.00102233930943},
            },
            results = {
                {type = "item", name = "slowdown-capsule", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 20.85,
                dense_negative_support = 6,
                dense_positive_support = 5,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.966574502689,
            },
        },
        ["small-electric-pole"] = {
            mode = "unchanged",
            reason = "one or more materials had an unbounded/unsupported LP price",
            ingredients = {
                {type = "item", name = "copper-cable", amount = 2},
                {type = "item", name = "wood", amount = 1},
            },
            results = {
                {type = "item", name = "small-electric-pole", amount = 2},
            },
        },
        ["small-lamp"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "express-splitter", amount = 0.0113043778421},
                {type = "item", name = "rail-chain-signal", amount = 0.192583854328},
                {type = "item", name = "pipe", amount = 0.845377226867},
                {type = "item", name = "copper-cable", amount = 1.26731717046},
            },
            results = {
                {type = "item", name = "small-lamp", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 6,
                dense_negative_support = 5,
                dense_positive_support = 6,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.976189899075,
            },
        },
        ["solar-panel"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 7.63849848031},
                {type = "item", name = "electronic-circuit", amount = 7.45110008273},
                {type = "fluid", name = "petroleum-gas", amount = 159.047595098},
                {type = "item", name = "copper-plate", amount = 2.19021469864},
            },
            results = {
                {type = "item", name = "solar-panel", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 84.725,
                dense_negative_support = 7,
                dense_positive_support = 5,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.999019484094,
            },
        },
        ["solar-panel-equipment"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "solar-panel", amount = 0.46640036773},
                {type = "fluid", name = "petroleum-gas", amount = 628.450967451},
                {type = "item", name = "steel-plate", amount = 5.32121392102},
                {type = "item", name = "fast-inserter", amount = 1.97740898018},
            },
            results = {
                {type = "item", name = "solar-panel-equipment", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 141.869705882,
                dense_negative_support = 7,
                dense_positive_support = 6,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.929293435426,
            },
        },
        ["solid-fuel-from-heavy-oil"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "fluid", name = "heavy-oil", amount = 11.1231135199},
                {type = "item", name = "beacon", amount = 0.00241697954875},
            },
            results = {
                {type = "item", name = "solid-fuel", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 2.01538461538,
                dense_negative_support = 5,
                dense_positive_support = 7,
                kept_ingredient_count = 2,
                retained_negative_l2_fraction = 0.878489940729,
            },
        },
        ["solid-fuel-from-light-oil"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "fluid", name = "light-oil", amount = 5.30569559375},
                {type = "item", name = "engine-unit", amount = 0.0261884343588},
            },
            results = {
                {type = "item", name = "solid-fuel", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 0.699019607843,
                dense_negative_support = 6,
                dense_positive_support = 7,
                kept_ingredient_count = 2,
                retained_negative_l2_fraction = 0.744273610629,
            },
        },
        ["solid-fuel-from-petroleum-gas"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "fluid", name = "petroleum-gas", amount = 10.4612466487},
                {type = "item", name = "firearm-magazine", amount = 0.138212905392},
            },
            results = {
                {type = "item", name = "solid-fuel", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 1.18235294118,
                dense_negative_support = 8,
                dense_positive_support = 4,
                kept_ingredient_count = 2,
                retained_negative_l2_fraction = 0.94697278051,
            },
        },
        ["speed-module"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "rocket-silo", amount = 0.000949182820852},
                {type = "item", name = "advanced-circuit", amount = 2.34559664895},
                {type = "item", name = "passive-provider-chest", amount = 0.256383142905},
            },
            results = {
                {type = "item", name = "speed-module", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 74.2367647059,
                dense_negative_support = 7,
                dense_positive_support = 8,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.900079402809,
            },
        },
        ["speed-module-2"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "modular-armor", amount = 0.455349672579},
                {type = "item", name = "steel-plate", amount = 29.2698209013},
                {type = "item", name = "processing-unit", amount = 2.06051004861},
                {type = "item", name = "speed-module", amount = 1.64840803889},
            },
            results = {
                {type = "item", name = "speed-module-2", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 807.046764706,
                dense_negative_support = 6,
                dense_positive_support = 4,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.964759967146,
            },
        },
        ["speed-module-3"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "speed-module-2", amount = 1.28962229983},
                {type = "item", name = "radar", amount = 27.1907595085},
                {type = "item", name = "long-handed-inserter", amount = 91.6139930991},
                {type = "item", name = "express-underground-belt", amount = 5.459790524},
            },
            results = {
                {type = "item", name = "speed-module-3", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 3744.28676471,
                dense_negative_support = 6,
                dense_positive_support = 7,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.997063738641,
            },
        },
        ["spidertron"] = {
            mode = "unchanged",
            reason = "one or more materials had an unbounded/unsupported LP price",
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
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "sulfur", amount = 8.29914020728},
                {type = "item", name = "electronic-circuit", amount = 2.72956526287},
                {type = "item", name = "processing-unit", amount = 0.0567863820021},
                {type = "item", name = "iron-plate", amount = 4.38939330433},
            },
            results = {
                {type = "item", name = "splitter", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 27.395,
                dense_negative_support = 10,
                dense_positive_support = 4,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.935862135857,
            },
        },
        ["steam-engine"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "exoskeleton-equipment", amount = 0.00729812151915},
                {type = "item", name = "iron-gear-wheel", amount = 3.86172798479},
                {type = "item", name = "requester-chest", amount = 0.0976449886076},
                {type = "item", name = "display-panel", amount = 1.16670672703},
            },
            results = {
                {type = "item", name = "steam-engine", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 33.07,
                dense_negative_support = 6,
                dense_positive_support = 7,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.967091240332,
            },
        },
        ["steam-turbine"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "iron-gear-wheel", amount = 37.7323856278},
                {type = "item", name = "rocket", amount = 10.4404688376},
                {type = "item", name = "copper-plate", amount = 33.2798334167},
                {type = "item", name = "productivity-module-2", amount = 0.0365077136466},
            },
            results = {
                {type = "item", name = "steam-turbine", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 180.9,
                dense_negative_support = 11,
                dense_positive_support = 4,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.924569505631,
            },
        },
        ["steel-chest"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "solar-panel", amount = 0.427520013929},
                {type = "item", name = "oil-refinery", amount = 0.0859305153923},
            },
            results = {
                {type = "item", name = "steel-chest", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 52,
                dense_negative_support = 4,
                dense_positive_support = 8,
                kept_ingredient_count = 2,
                retained_negative_l2_fraction = 0.918174814743,
            },
        },
        ["steel-furnace"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 5.37739618701},
                {type = "item", name = "electronic-circuit", amount = 3.0288927069},
                {type = "item", name = "stone-brick", amount = 5.4345823279},
            },
            results = {
                {type = "item", name = "steel-furnace", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 51.2,
                dense_negative_support = 6,
                dense_positive_support = 4,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.98626751699,
            },
        },
        ["steel-plate"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "depleted-uranium-fuel-cell", amount = 0.176168978008},
                {type = "item", name = "landfill", amount = 0.119970768282},
            },
            results = {
                {type = "item", name = "steel-plate", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 4.6,
                dense_negative_support = 4,
                dense_positive_support = 5,
                kept_ingredient_count = 2,
                retained_negative_l2_fraction = 0.849503917152,
            },
        },
        ["stone-brick"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "iron-plate", amount = 0.33654834608},
                {type = "item", name = "laser-turret", amount = 0.00110451632107},
            },
            results = {
                {type = "item", name = "stone-brick", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 0.6,
                dense_negative_support = 4,
                dense_positive_support = 6,
                kept_ingredient_count = 2,
                retained_negative_l2_fraction = 0.849008485971,
            },
        },
        ["stone-furnace"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "stone", amount = 2.65522422923},
                {type = "item", name = "electric-mining-drill", amount = 0.0233117723688},
            },
            results = {
                {type = "item", name = "stone-furnace", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 1.5,
                dense_negative_support = 5,
                dense_positive_support = 6,
                kept_ingredient_count = 2,
                retained_negative_l2_fraction = 0.845429589127,
            },
        },
        ["stone-wall"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "stone-brick", amount = 2.62152521397},
                {type = "fluid", name = "petroleum-gas", amount = 49.0841463306},
            },
            results = {
                {type = "item", name = "stone-wall", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 6.1,
                dense_negative_support = 5,
                dense_positive_support = 5,
                kept_ingredient_count = 2,
                retained_negative_l2_fraction = 0.805691863564,
            },
        },
        ["storage-chest"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "burner-mining-drill", amount = 2.59525055549},
                {type = "item", name = "steel-chest", amount = 0.427629454477},
                {type = "item", name = "long-handed-inserter", amount = 1.4448113393},
                {type = "item", name = "fast-underground-belt", amount = 0.117781928368},
            },
            results = {
                {type = "item", name = "storage-chest", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 73.5473529412,
                dense_negative_support = 7,
                dense_positive_support = 6,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.987782570048,
            },
        },
        ["storage-tank"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "power-armor", amount = 0.00451039483492},
                {type = "item", name = "efficiency-module-3", amount = 0.00479060360931},
                {type = "item", name = "steel-plate", amount = 2.12838396599},
            },
            results = {
                {type = "item", name = "storage-tank", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 50.9,
                dense_negative_support = 6,
                dense_positive_support = 6,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.958213070358,
            },
        },
        ["submachine-gun"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "gate", amount = 0.479472329188},
                {type = "item", name = "iron-gear-wheel", amount = 5.13162981392},
                {type = "item", name = "iron-plate", amount = 10.435550101},
                {type = "item", name = "pipe", amount = 1.82899465065},
            },
            results = {
                {type = "item", name = "submachine-gun", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 35.7,
                dense_negative_support = 6,
                dense_positive_support = 5,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.9940437404,
            },
        },
        ["substation"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 7.79996091356},
                {type = "item", name = "depleted-uranium-fuel-cell", amount = 2.61266848201},
                {type = "item", name = "advanced-circuit", amount = 1.54036944085},
                {type = "item", name = "car", amount = 0.1159535498},
            },
            results = {
                {type = "item", name = "substation", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 127.171764706,
                dense_negative_support = 5,
                dense_positive_support = 4,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.999858767939,
            },
        },
        ["sulfur"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "stone-wall", amount = 0.121290683003},
                {type = "fluid", name = "petroleum-gas", amount = 10.3900741248},
                {type = "item", name = "chemical-science-pack", amount = 0.0164834991413},
            },
            results = {
                {type = "item", name = "sulfur", amount = 2},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 1.92352941176,
                dense_negative_support = 5,
                dense_positive_support = 5,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.928413354123,
            },
        },
        ["sulfuric-acid"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "splitter", amount = 0.077953638032},
                {type = "item", name = "firearm-magazine", amount = 0.453151117131},
                {type = "item", name = "sulfur", amount = 1.50686897128},
                {type = "item", name = "solid-fuel", amount = 1.66875926567},
            },
            results = {
                {type = "fluid", name = "sulfuric-acid", amount = 50},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 7.22882352941,
                dense_negative_support = 5,
                dense_positive_support = 5,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.999148542671,
            },
        },
        ["sulfuric-acid-barrel"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "express-splitter", amount = 0.0227675124289},
                {type = "item", name = "small-lamp", amount = 0.800504278988},
                {type = "fluid", name = "sulfuric-acid", amount = 28.1560554032},
            },
            results = {
                {type = "item", name = "sulfuric-acid-barrel", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 14.5288235294,
                dense_negative_support = 6,
                dense_positive_support = 9,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.878946731874,
            },
        },
        ["tank"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "steel-plate", amount = 56.1705723819},
                {type = "item", name = "engine-unit", amount = 14.0648452663},
                {type = "fluid", name = "light-oil", amount = 2247.79960265},
                {type = "item", name = "uranium-fuel-cell", amount = 8.57987955684},
                {type = "item", name = "advanced-circuit", amount = 4.39526414572},
            },
            results = {
                {type = "item", name = "tank", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 875.533529412,
                dense_negative_support = 8,
                dense_positive_support = 7,
                kept_ingredient_count = 5,
                retained_negative_l2_fraction = 0.993874041093,
            },
        },
        ["train-stop"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "personal-roboport-mk2-equipment", amount = 0.00127704784678},
                {type = "item", name = "hazard-concrete", amount = 9.93999055181},
                {type = "item", name = "power-armor", amount = 0.00185108864418},
                {type = "item", name = "steel-plate", amount = 1.0114567784},
                {type = "item", name = "electronic-circuit", amount = 1.80916720695},
            },
            results = {
                {type = "item", name = "train-stop", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 44.705,
                dense_negative_support = 7,
                dense_positive_support = 6,
                kept_ingredient_count = 5,
                retained_negative_l2_fraction = 0.993764325725,
            },
        },
        ["transport-belt"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "iron-gear-wheel", amount = 0.612365703753},
                {type = "item", name = "iron-plate", amount = 1.09493948837},
                {type = "item", name = "electronic-circuit", amount = 0.239866072277},
            },
            results = {
                {type = "item", name = "transport-belt", amount = 2},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 3.11,
                dense_negative_support = 7,
                dense_positive_support = 4,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.880380178963,
            },
        },
        ["underground-belt"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "electronic-circuit", amount = 1.93635389334},
                {type = "item", name = "iron-plate", amount = 6.55578509167},
                {type = "item", name = "transport-belt", amount = 3.27789254583},
            },
            results = {
                {type = "item", name = "underground-belt", amount = 2},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 17.85,
                dense_negative_support = 8,
                dense_positive_support = 4,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.859962656151,
            },
        },
        ["uranium-cannon-shell"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "cannon-shell", amount = 0.642544373369},
                {type = "item", name = "sulfuric-acid-barrel", amount = 0.433234221375},
                {type = "item", name = "iron-gear-wheel", amount = 2.62260719529},
            },
            results = {
                {type = "item", name = "uranium-cannon-shell", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 23.1564776968,
                dense_negative_support = 6,
                dense_positive_support = 5,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.85284013983,
            },
        },
        ["uranium-fuel-cell"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "uranium-238", amount = 11.4544694128},
                {type = "item", name = "uranium-235", amount = 1.34296386589},
                {type = "fluid", name = "light-oil", amount = 355.133245183},
                {type = "item", name = "processing-unit", amount = 0.24669901823},
            },
            results = {
                {type = "item", name = "uranium-fuel-cell", amount = 10},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 148.493838509,
                dense_negative_support = 7,
                dense_positive_support = 8,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.966413902321,
            },
        },
        ["uranium-processing"] = {
            mode = "unchanged",
            reason = "multi-result recipe",
            ingredients = {
                {type = "item", name = "uranium-ore", amount = 10},
            },
            results = {
                {type = "item", name = "uranium-235", amount = 0.007},
                {type = "item", name = "uranium-238", amount = 0.993},
            },
        },
        ["uranium-rounds-magazine"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "automation-science-pack", amount = 1.499489117},
                {type = "item", name = "piercing-rounds-magazine", amount = 0.602999308408},
                {type = "item", name = "uranium-238", amount = 0.602999308408},
            },
            results = {
                {type = "item", name = "uranium-rounds-magazine", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 14.7682424027,
                dense_negative_support = 7,
                dense_positive_support = 4,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.871376684019,
            },
        },
        ["utility-science-pack"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "lab", amount = 1.68125831165},
                {type = "item", name = "explosive-cannon-shell", amount = 5.56568533847},
                {type = "item", name = "processing-unit", amount = 0.945922327077},
                {type = "item", name = "low-density-structure", amount = 1.41888349061},
            },
            results = {
                {type = "item", name = "utility-science-pack", amount = 3},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 341.820882353,
                dense_negative_support = 7,
                dense_positive_support = 7,
                kept_ingredient_count = 4,
                retained_negative_l2_fraction = 0.947726897783,
            },
        },
        ["water-barrel"] = {
            mode = "givens-transformed",
            ingredients = {
                {type = "item", name = "rocket-launcher", amount = 0.0960891475087},
                {type = "item", name = "barrel", amount = 0.364665280665},
                {type = "item", name = "cluster-grenade", amount = 0.0148885431286},
            },
            results = {
                {type = "item", name = "water-barrel", amount = 1},
            },
            diagnostics = {
                pre_randomization_input_cost_budget = 7.15,
                dense_negative_support = 5,
                dense_positive_support = 7,
                kept_ingredient_count = 3,
                retained_negative_l2_fraction = 0.995035577779,
            },
        },
        ["wooden-chest"] = {
            mode = "unchanged",
            reason = "one or more materials had an unbounded/unsupported LP price",
            ingredients = {
                {type = "item", name = "wood", amount = 2},
            },
            results = {
                {type = "item", name = "wooden-chest", amount = 1},
            },
        },
    },
}

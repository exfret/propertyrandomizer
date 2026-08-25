-- Givens multi-result recipe proof of concept v2
-- Generated from the Factorio LP export in factorio-current(20260818-034039).log.
--
-- IMPORTANT:
-- * Fractional item ingredient/result amounts are intentionally left unrepaired.
-- * All original results are retained.
-- * Some originally single-result recipes receive up to two local same-rank byproducts.
-- * Reachability was repaired after generation until every originally production-reachable
--   material in the exported graph was reachable again.

return {
    metadata = {
        format = "propertyrandomizer-givens-multi-poc-v2",
        source = "factorio-current(20260818-034039).log",
        seed = 20260818,
        transformed = 197,
        unchanged = 5,
        reachability_repairs = 18,
        reachable_after_transform = 195,
    },
    recipes = {
        ["accumulator"] = {
            mode = "givens-multi-topology-balanced",
            repairs = {
                "reachability bootstrap: ingredients forced to already-reachable strictly earlier materials",
            },
            ingredients = {
                {type = "item", name = "petroleum-gas-barrel", amount = 1.17268486749},
                {type = "item", name = "flamethrower-turret", amount = 0.0315961192967},
                {type = "item", name = "battery", amount = 0.831902793497},
                {type = "item", name = "transport-belt", amount = 0.754048061108},
                {type = "item", name = "iron-gear-wheel", amount = 1.03005355331},
            },
            results = {
                {type = "item", name = "accumulator", amount = 1},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["active-provider-chest"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "fast-splitter", amount = 0.382816756483},
                {type = "item", name = "steel-chest", amount = 0.243690623247},
                {type = "item", name = "advanced-circuit", amount = 1.25144840391},
                {type = "item", name = "plastic-bar", amount = 9.00520313719},
                {type = "fluid", name = "sulfuric-acid", amount = 41.5358732316},
            },
            results = {
                {type = "item", name = "active-provider-chest", amount = 1},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["advanced-circuit"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "crude-oil-barrel", amount = 0.0859396039712},
                {type = "item", name = "electronic-circuit", amount = 1.0161066582},
                {type = "fluid", name = "petroleum-gas", amount = 45.7261169964},
                {type = "item", name = "steel-plate", amount = 0.421125573821},
                {type = "item", name = "copper-cable", amount = 2.13588075426},
            },
            results = {
                {type = "item", name = "advanced-circuit", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["advanced-oil-processing"] = {
            mode = "givens-multi-topology-balanced",
            repairs = {
                "reachability bootstrap: ingredients forced to already-reachable strictly earlier materials",
            },
            ingredients = {
                {type = "fluid", name = "crude-oil", amount = 45.9084630164},
                {type = "item", name = "stone", amount = 4.83036027863},
                {type = "fluid", name = "water", amount = 84.7276051836},
            },
            results = {
                {type = "fluid", name = "heavy-oil", amount = 25},
                {type = "fluid", name = "light-oil", amount = 45},
                {type = "fluid", name = "petroleum-gas", amount = 55},
            },
            topology = {
                output_rank = 1,
            },
        },
        ["arithmetic-combinator"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "decider-combinator", amount = 0.281857492906},
                {type = "item", name = "cargo-wagon", amount = 0.0175194117905},
                {type = "item", name = "sulfur", amount = 4.56020129047},
                {type = "item", name = "explosives", amount = 2.36848855939},
                {type = "item", name = "iron-plate", amount = 2.90679394894},
            },
            results = {
                {type = "item", name = "arithmetic-combinator", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["artillery-shell"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "explosive-cannon-shell", amount = 1.043023421},
                {type = "item", name = "processing-unit", amount = 0.403928884201},
                {type = "item", name = "stone-wall", amount = 4.19564164386},
                {type = "item", name = "radar", amount = 0.231810875595},
                {type = "item", name = "grenade", amount = 2.21262358108},
                {type = "item", name = "electric-engine-unit", amount = 0.375275189062},
            },
            results = {
                {type = "item", name = "artillery-shell", amount = 1},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["artillery-turret"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "explosive-rocket", amount = 38.5114959474},
                {type = "item", name = "petroleum-gas-barrel", amount = 10.6265121527},
                {type = "item", name = "steel-chest", amount = 1.04754934205},
                {type = "item", name = "solar-panel", amount = 0.726776757627},
                {type = "item", name = "accumulator", amount = 1.20545513143},
                {type = "item", name = "steel-plate", amount = 13.3921473884},
                {type = "item", name = "electronic-circuit", amount = 44.8086834485},
            },
            results = {
                {type = "item", name = "artillery-turret", amount = 1},
                {type = "item", name = "buffer-chest", amount = 1.03460682744},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["artillery-wagon"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "flying-robot-frame", amount = 7.30405631497},
                {type = "item", name = "solar-panel", amount = 3.46461158952},
                {type = "item", name = "processing-unit", amount = 4.90441037273},
                {type = "item", name = "engine-unit", amount = 7.13914797558},
                {type = "item", name = "fast-inserter", amount = 2.36386465791},
                {type = "item", name = "advanced-circuit", amount = 9.49873307485},
            },
            results = {
                {type = "item", name = "artillery-wagon", amount = 1},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["assembling-machine-1"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "refined-concrete", amount = 3.62193503005},
                {type = "item", name = "flamethrower", amount = 0.0632913231096},
                {type = "item", name = "burner-inserter", amount = 0.540138671924},
                {type = "item", name = "explosive-cannon-shell", amount = 0.485888153097},
                {type = "item", name = "flamethrower-ammo", amount = 0.0976172529172},
            },
            results = {
                {type = "item", name = "assembling-machine-1", amount = 1},
                {type = "item", name = "refined-hazard-concrete", amount = 0.540378515302},
                {type = "item", name = "battery", amount = 0.224745585935},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["assembling-machine-2"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "assembling-machine-1", amount = 0.272575462831},
                {type = "item", name = "fast-underground-belt", amount = 0.143833615566},
                {type = "item", name = "flying-robot-frame", amount = 0.311958105967},
                {type = "item", name = "engine-unit", amount = 0.356056624281},
                {type = "item", name = "steel-plate", amount = 0.900212673826},
                {type = "item", name = "advanced-circuit", amount = 1.79893456675},
            },
            results = {
                {type = "item", name = "assembling-machine-2", amount = 1},
                {type = "item", name = "uranium-235", amount = 0.262238568811},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["assembling-machine-3"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "uranium-cannon-shell", amount = 8.90086277954},
                {type = "item", name = "personal-roboport-mk2-equipment", amount = 0.0103761752679},
                {type = "item", name = "night-vision-equipment", amount = 0.641208536649},
            },
            results = {
                {type = "item", name = "assembling-machine-3", amount = 1},
            },
            topology = {
                output_rank = 6,
            },
        },
        ["atomic-bomb"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "explosive-cannon-shell", amount = 14.4234972272},
                {type = "item", name = "stone-wall", amount = 60.6900869246},
                {type = "item", name = "processing-unit", amount = 4.62595372778},
                {type = "item", name = "radar", amount = 3.20422601591},
                {type = "item", name = "piercing-rounds-magazine", amount = 18.1011684395},
                {type = "item", name = "grenade", amount = 32.2829367283},
            },
            results = {
                {type = "item", name = "atomic-bomb", amount = 1},
            },
            topology = {
                output_rank = 6,
            },
        },
        ["automation-science-pack"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "electronic-circuit", amount = 0.541160021574},
                {type = "item", name = "stone-wall", amount = 0.0897134707062},
                {type = "item", name = "solid-fuel", amount = 0.927772199503},
            },
            results = {
                {type = "item", name = "automation-science-pack", amount = 1},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["barrel"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "heat-exchanger", amount = 0.011282397645},
                {type = "item", name = "hazard-concrete", amount = 1.82795049138},
                {type = "item", name = "grenade", amount = 0.218732614769},
                {type = "item", name = "burner-mining-drill", amount = 0.0956597721461},
            },
            results = {
                {type = "item", name = "barrel", amount = 1},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["basic-oil-processing"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "iron-plate", amount = 1.68101379835},
                {type = "item", name = "coal", amount = 4.84489101839},
            },
            results = {
                {type = "fluid", name = "petroleum-gas", amount = 45},
            },
            topology = {
                output_rank = 1,
            },
        },
        ["battery"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "fluid", name = "sulfuric-acid", amount = 10.6529926734},
                {type = "item", name = "copper-plate", amount = 1.34860475786},
                {type = "item", name = "steel-plate", amount = 0.167103717141},
                {type = "item", name = "plastic-bar", amount = 0.434805592972},
                {type = "item", name = "iron-plate", amount = 0.576102235242},
            },
            results = {
                {type = "item", name = "battery", amount = 1},
                {type = "item", name = "explosive-cannon-shell", amount = 0.0307326220498},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["battery-equipment"] = {
            mode = "givens-multi-topology-balanced",
            repairs = {
                "reachability bootstrap: ingredients forced to already-reachable strictly earlier materials",
            },
            ingredients = {
                {type = "item", name = "pumpjack", amount = 0.373573294642},
                {type = "item", name = "low-density-structure", amount = 0.550246558921},
                {type = "item", name = "piercing-rounds-magazine", amount = 2.78905958422},
                {type = "item", name = "steel-chest", amount = 0.315933994076},
            },
            results = {
                {type = "item", name = "battery-equipment", amount = 1},
                {type = "item", name = "storage-chest", amount = 0.127552129146},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["battery-mk2-equipment"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "personal-laser-defense-equipment", amount = 0.303821854061},
                {type = "item", name = "explosive-uranium-cannon-shell", amount = 26.5273356358},
                {type = "item", name = "long-handed-inserter", amount = 26.3656317615},
                {type = "item", name = "decider-combinator", amount = 20.4895450044},
                {type = "item", name = "battery-equipment", amount = 1.28439310107},
            },
            results = {
                {type = "item", name = "battery-mk2-equipment", amount = 1},
            },
            topology = {
                output_rank = 6,
            },
        },
        ["beacon"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "explosives", amount = 141.725969189},
                {type = "item", name = "inserter", amount = 8.295901247},
                {type = "item", name = "barrel", amount = 5.32270653815},
                {type = "item", name = "steel-plate", amount = 6.29204227853},
                {type = "item", name = "advanced-circuit", amount = 3.54246095004},
                {type = "item", name = "battery", amount = 2.43803476261},
                {type = "fluid", name = "water", amount = 4783.07165513},
            },
            results = {
                {type = "item", name = "beacon", amount = 1},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["belt-immunity-equipment"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "rocket", amount = 8.70467454801},
                {type = "item", name = "military-science-pack", amount = 1.80550681656},
                {type = "item", name = "efficiency-module", amount = 0.19729751846},
                {type = "item", name = "advanced-circuit", amount = 4.12056360323},
            },
            results = {
                {type = "item", name = "belt-immunity-equipment", amount = 1},
                {type = "item", name = "substation", amount = 0.0977572455913},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["big-electric-pole"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "boiler", amount = 0.886761463377},
                {type = "item", name = "copper-plate", amount = 8.99511023174},
                {type = "item", name = "steel-plate", amount = 1.58131787167},
                {type = "fluid", name = "heavy-oil", amount = 74.2859120112},
                {type = "fluid", name = "light-oil", amount = 109.075263006},
            },
            results = {
                {type = "item", name = "big-electric-pole", amount = 1},
                {type = "item", name = "heavy-armor", amount = 0.00967950251136},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["boiler"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "gun-turret", amount = 0.0519876706333},
                {type = "item", name = "concrete", amount = 2.71690674935},
                {type = "fluid", name = "heavy-oil", amount = 20.5574689384},
            },
            results = {
                {type = "item", name = "boiler", amount = 1},
                {type = "item", name = "low-density-structure", amount = 0.0192054624457},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["buffer-chest"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "selector-combinator", amount = 0.318845191847},
                {type = "item", name = "pump", amount = 0.823688169214},
                {type = "item", name = "transport-belt", amount = 4.69480881317},
                {type = "item", name = "steel-chest", amount = 0.187386688113},
            },
            results = {
                {type = "item", name = "buffer-chest", amount = 1},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["bulk-inserter"] = {
            mode = "givens-multi-topology-balanced",
            repairs = {
                "reachability bootstrap: ingredients forced to already-reachable strictly earlier materials",
            },
            ingredients = {
                {type = "item", name = "explosive-cannon-shell", amount = 2.42581162405},
                {type = "item", name = "artillery-wagon", amount = 0.0103347964593},
                {type = "item", name = "uranium-238", amount = 3.02155628306},
                {type = "item", name = "fast-inserter", amount = 0.363553291205},
                {type = "item", name = "electronic-circuit", amount = 8.03258877274},
            },
            results = {
                {type = "item", name = "bulk-inserter", amount = 1},
                {type = "item", name = "explosive-uranium-cannon-shell", amount = 0.417944445824},
            },
            topology = {
                output_rank = 6,
            },
        },
        ["burner-inserter"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "flamethrower", amount = 0.015071365582},
                {type = "fluid", name = "sulfuric-acid", amount = 9.86905648776},
                {type = "item", name = "iron-gear-wheel", amount = 0.349195949838},
            },
            results = {
                {type = "item", name = "burner-inserter", amount = 1},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["burner-mining-drill"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "firearm-magazine", amount = 0.674323296423},
                {type = "fluid", name = "petroleum-gas", amount = 55.0813203468},
                {type = "item", name = "iron-gear-wheel", amount = 0.801282886553},
                {type = "fluid", name = "light-oil", amount = 16.9886671144},
                {type = "item", name = "stone-furnace", amount = 1.20547688153},
            },
            results = {
                {type = "item", name = "burner-mining-drill", amount = 1},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["cannon-shell"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "repair-pack", amount = 0.439645647379},
                {type = "fluid", name = "sulfuric-acid", amount = 29.0269137738},
                {type = "item", name = "barrel", amount = 0.165113475037},
                {type = "item", name = "copper-plate", amount = 3.39613626477},
                {type = "item", name = "steel-plate", amount = 0.372986019097},
            },
            results = {
                {type = "item", name = "cannon-shell", amount = 1},
                {type = "item", name = "display-panel", amount = 0.384437239463},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["car"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "locomotive", amount = 0.0427133622171},
                {type = "fluid", name = "sulfuric-acid", amount = 324.447996249},
                {type = "item", name = "barrel", amount = 2.54199795526},
                {type = "item", name = "electronic-circuit", amount = 11.1633725394},
                {type = "item", name = "copper-cable", amount = 29.4618524888},
                {type = "item", name = "iron-gear-wheel", amount = 4.3497611876},
            },
            results = {
                {type = "item", name = "car", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["cargo-landing-pad"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "rocket-silo", amount = 0.00679887366171},
                {type = "item", name = "logistic-science-pack", amount = 12.9800386063},
                {type = "item", name = "explosive-cannon-shell", amount = 12.3628986421},
                {type = "item", name = "refined-concrete", amount = 75.5993858009},
                {type = "item", name = "advanced-circuit", amount = 37.8276870091},
            },
            results = {
                {type = "item", name = "cargo-landing-pad", amount = 1},
            },
            topology = {
                output_rank = 6,
            },
        },
        ["cargo-wagon"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "solid-fuel", amount = 74.14081529},
                {type = "item", name = "steel-chest", amount = 0.908873412489},
                {type = "item", name = "barrel", amount = 3.18853270715},
                {type = "fluid", name = "crude-oil", amount = 294.478618225},
                {type = "item", name = "electronic-circuit", amount = 8.47338539861},
            },
            results = {
                {type = "item", name = "cargo-wagon", amount = 1},
                {type = "item", name = "rail", amount = 4.38535645472},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["centrifuge"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "substation", amount = 3.36745140536},
                {type = "item", name = "military-science-pack", amount = 38.4213937449},
                {type = "item", name = "electric-furnace", amount = 1.97110019067},
                {type = "item", name = "shotgun-shell", amount = 78.8467444611},
                {type = "item", name = "rail", amount = 38.6659371789},
            },
            results = {
                {type = "item", name = "centrifuge", amount = 1},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["chemical-plant"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "burner-mining-drill", amount = 1.50830269259},
                {type = "item", name = "submachine-gun", amount = 0.175059807411},
                {type = "item", name = "slowdown-capsule", amount = 0.352814727062},
                {type = "item", name = "electric-engine-unit", amount = 0.593381576637},
                {type = "item", name = "rocket", amount = 1.93138555439},
                {type = "item", name = "explosives", amount = 12.2685162972},
            },
            results = {
                {type = "item", name = "chemical-plant", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["chemical-science-pack"] = {
            mode = "givens-multi-topology-balanced",
            repairs = {
                "reachability bootstrap: ingredients forced to already-reachable strictly earlier materials",
            },
            ingredients = {
                {type = "item", name = "pumpjack", amount = 0.314204423503},
                {type = "item", name = "pump", amount = 0.647944092722},
                {type = "item", name = "radar", amount = 0.22083858478},
                {type = "item", name = "battery", amount = 0.973864258031},
                {type = "item", name = "advanced-circuit", amount = 0.682014731628},
            },
            results = {
                {type = "item", name = "chemical-science-pack", amount = 2},
                {type = "item", name = "battery-equipment", amount = 0.067834096781},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["cliff-explosives"] = {
            mode = "givens-multi-topology-balanced",
            repairs = {
                "reachability bootstrap: ingredients forced to already-reachable strictly earlier materials",
            },
            ingredients = {
                {type = "item", name = "burner-inserter", amount = 2.13413795102},
                {type = "item", name = "concrete", amount = 8.69026940097},
                {type = "item", name = "explosives", amount = 4.63593856733},
                {type = "item", name = "grenade", amount = 0.486379886865},
                {type = "item", name = "iron-stick", amount = 4.39429550147},
            },
            results = {
                {type = "item", name = "cliff-explosives", amount = 1},
                {type = "item", name = "advanced-circuit", amount = 0.23781686237},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["cluster-grenade"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "chemical-plant", amount = 0.343420958809},
                {type = "item", name = "hazard-concrete", amount = 41.7238514644},
                {type = "item", name = "rocket", amount = 5.93156078628},
                {type = "item", name = "solar-panel", amount = 0.219763410152},
            },
            results = {
                {type = "item", name = "cluster-grenade", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["coal-liquefaction"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "fluid", name = "steam", amount = 67.3703555974},
                {type = "item", name = "stone-brick", amount = 0.678622229452},
                {type = "item", name = "stone-furnace", amount = 0.299872428781},
                {type = "item", name = "coal", amount = 4.75094999755},
                {type = "item", name = "stone", amount = 1.56358910414},
                {type = "item", name = "copper-plate", amount = 1.39871344315},
            },
            results = {
                {type = "fluid", name = "heavy-oil", amount = 90},
                {type = "fluid", name = "light-oil", amount = 20},
                {type = "fluid", name = "petroleum-gas", amount = 10},
            },
            topology = {
                output_rank = 1,
            },
        },
        ["combat-shotgun"] = {
            mode = "unchanged",
            reason = "unsupported/unpriced material in original LP",
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
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "fluid", name = "steam", amount = 56.6014331958},
                {type = "item", name = "stone-brick", amount = 0.789929463913},
                {type = "item", name = "coal", amount = 4.10298680595},
                {type = "item", name = "stone", amount = 1.65167481724},
                {type = "item", name = "copper-plate", amount = 1.19218341445},
            },
            results = {
                {type = "item", name = "concrete", amount = 10},
                {type = "item", name = "iron-chest", amount = 0.10635538262},
            },
            topology = {
                output_rank = 2,
            },
        },
        ["constant-combinator"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "rail-chain-signal", amount = 0.218123420477},
                {type = "item", name = "refined-concrete", amount = 1.0331163379},
                {type = "item", name = "lubricant-barrel", amount = 0.156577214927},
                {type = "item", name = "sulfur", amount = 2.05886848561},
            },
            results = {
                {type = "item", name = "constant-combinator", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["construction-robot"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "nuclear-reactor", amount = 0.00228860401981},
                {type = "item", name = "flying-robot-frame", amount = 0.439825062222},
                {type = "item", name = "speed-module", amount = 0.15429177334},
            },
            results = {
                {type = "item", name = "construction-robot", amount = 1},
                {type = "item", name = "speed-module-2", amount = 0.00703255214997},
            },
            topology = {
                output_rank = 6,
            },
        },
        ["copper-cable"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "pipe", amount = 0.272561714675},
                {type = "item", name = "solid-fuel", amount = 0.30631878474},
                {type = "item", name = "copper-plate", amount = 0.33192088795},
            },
            results = {
                {type = "item", name = "copper-cable", amount = 2},
            },
            topology = {
                output_rank = 2,
            },
        },
        ["copper-plate"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "copper-ore", amount = 0.32456426871},
                {type = "item", name = "iron-ore", amount = 0.317752121936},
                {type = "item", name = "stone-brick", amount = 0.0879549859065},
            },
            results = {
                {type = "item", name = "copper-plate", amount = 1},
                {type = "fluid", name = "light-oil", amount = 1.31612903226},
            },
            topology = {
                output_rank = 1,
            },
        },
        ["crude-oil-barrel"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "programmable-speaker", amount = 0.17661572841},
                {type = "item", name = "car", amount = 0.0113682184226},
                {type = "item", name = "electric-mining-drill", amount = 0.0639325860517},
                {type = "item", name = "barrel", amount = 0.133161110292},
            },
            results = {
                {type = "item", name = "crude-oil-barrel", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["decider-combinator"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "rail", amount = 1.30137407178},
                {type = "item", name = "sulfur", amount = 4.49827678421},
                {type = "item", name = "electronic-circuit", amount = 2.17237917776},
                {type = "item", name = "copper-cable", amount = 2.93095800164},
            },
            results = {
                {type = "item", name = "decider-combinator", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["defender-capsule"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "poison-capsule", amount = 0.434178954134},
                {type = "item", name = "steam-engine", amount = 0.217147330697},
                {type = "item", name = "uranium-ore", amount = 23.3679172976},
                {type = "fluid", name = "sulfuric-acid", amount = 65.4097501297},
            },
            results = {
                {type = "item", name = "defender-capsule", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["destroyer-capsule"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "energy-shield-mk2-equipment", amount = 0.0824236971637},
                {type = "item", name = "requester-chest", amount = 2.03100274857},
                {type = "item", name = "uranium-235", amount = 13.3709827088},
                {type = "item", name = "night-vision-equipment", amount = 1.13293806451},
                {type = "item", name = "distractor-capsule", amount = 0.70819309646},
            },
            results = {
                {type = "item", name = "destroyer-capsule", amount = 1},
                {type = "item", name = "atomic-bomb", amount = 0.0564693170553},
            },
            topology = {
                output_rank = 6,
            },
        },
        ["discharge-defense-equipment"] = {
            mode = "givens-multi-topology-balanced",
            repairs = {
                "reachability bootstrap: ingredients forced to already-reachable strictly earlier materials",
            },
            ingredients = {
                {type = "item", name = "laser-turret", amount = 2.71572904486},
                {type = "item", name = "advanced-circuit", amount = 130.766320654},
                {type = "item", name = "fast-underground-belt", amount = 9.85778354546},
                {type = "item", name = "inserter", amount = 66.167669952},
            },
            results = {
                {type = "item", name = "discharge-defense-equipment", amount = 1},
                {type = "item", name = "express-underground-belt", amount = 2.22804011485},
            },
            topology = {
                output_rank = 6,
            },
        },
        ["display-panel"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "automation-science-pack", amount = 0.330355600511},
                {type = "item", name = "train-stop", amount = 0.017919336905},
                {type = "item", name = "repair-pack", amount = 0.087344624756},
                {type = "item", name = "cannon-shell", amount = 0.0601686141229},
            },
            results = {
                {type = "item", name = "display-panel", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["distractor-capsule"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "flamethrower-turret", amount = 0.131474389207},
                {type = "item", name = "defender-capsule", amount = 2.13389741587},
                {type = "item", name = "barrel", amount = 10.9629774349},
            },
            results = {
                {type = "item", name = "distractor-capsule", amount = 1},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["efficiency-module"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "speed-module", amount = 0.553027984721},
                {type = "item", name = "inserter", amount = 2.73229794859},
                {type = "item", name = "engine-unit", amount = 0.747998269037},
                {type = "item", name = "transport-belt", amount = 2.70814494562},
            },
            results = {
                {type = "item", name = "efficiency-module", amount = 1},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["efficiency-module-2"] = {
            mode = "givens-multi-topology-balanced",
            repairs = {
                "reachability bootstrap: ingredients forced to already-reachable strictly earlier materials",
            },
            ingredients = {
                {type = "item", name = "tank", amount = 0.262583272716},
                {type = "item", name = "logistic-science-pack", amount = 18.2163046238},
                {type = "item", name = "nuclear-reactor", amount = 0.01545756693},
                {type = "item", name = "fast-underground-belt", amount = 3.94620869471},
                {type = "item", name = "efficiency-module", amount = 0.584023551872},
            },
            results = {
                {type = "item", name = "efficiency-module-2", amount = 1},
            },
            topology = {
                output_rank = 6,
            },
        },
        ["efficiency-module-3"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "efficiency-module-2", amount = 1.37357025301},
                {type = "item", name = "flying-robot-frame", amount = 18.1913917211},
                {type = "item", name = "speed-module-2", amount = 0.87389158657},
                {type = "item", name = "uranium-238", amount = 115.104531471},
                {type = "item", name = "advanced-circuit", amount = 26.538895816},
            },
            results = {
                {type = "item", name = "efficiency-module-3", amount = 1},
                {type = "item", name = "power-armor-mk2", amount = 0.00784264708927},
            },
            topology = {
                output_rank = 7,
            },
        },
        ["electric-engine-unit"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "slowdown-capsule", amount = 0.172291461375},
                {type = "item", name = "submachine-gun", amount = 0.0938860389544},
                {type = "item", name = "splitter", amount = 0.0892893800957},
                {type = "item", name = "rocket", amount = 0.915055387873},
                {type = "item", name = "explosives", amount = 4.46779591625},
                {type = "item", name = "stone-furnace", amount = 1.60925306613},
            },
            results = {
                {type = "item", name = "electric-engine-unit", amount = 1},
                {type = "item", name = "chemical-plant", amount = 0.0335337171291},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["electric-furnace"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "buffer-chest", amount = 0.339967476507},
                {type = "item", name = "pump", amount = 0.733554035926},
                {type = "item", name = "selector-combinator", amount = 0.162383712457},
                {type = "item", name = "flying-robot-frame", amount = 0.564634051907},
                {type = "item", name = "uranium-235", amount = 1.50108242895},
                {type = "item", name = "accumulator", amount = 0.359066225181},
            },
            results = {
                {type = "item", name = "electric-furnace", amount = 1},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["electric-mining-drill"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "barrel", amount = 1.10770317887},
                {type = "fluid", name = "crude-oil", amount = 202.927537555},
                {type = "item", name = "plastic-bar", amount = 4.59065117803},
                {type = "item", name = "copper-cable", amount = 12.4965761692},
                {type = "item", name = "iron-gear-wheel", amount = 1.68405625493},
            },
            results = {
                {type = "item", name = "electric-mining-drill", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["electronic-circuit"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "fluid", name = "petroleum-gas", amount = 18.4181553923},
                {type = "item", name = "barrel", amount = 0.144572582623},
                {type = "item", name = "copper-cable", amount = 1.16316719677},
            },
            results = {
                {type = "item", name = "electronic-circuit", amount = 1},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["empty-crude-oil-barrel"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "copper-ore", amount = 9.24540366446},
                {type = "item", name = "stone", amount = 9.57644340262},
                {type = "fluid", name = "water", amount = 614.689175975},
            },
            results = {
                {type = "fluid", name = "crude-oil", amount = 50},
                {type = "item", name = "barrel", amount = 1},
            },
            topology = {
                output_rank = 0,
            },
        },
        ["empty-heavy-oil-barrel"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "stone-brick", amount = 3.52624931919},
                {type = "item", name = "iron-plate", amount = 4.92626958168},
                {type = "fluid", name = "crude-oil", amount = 114.142311797},
            },
            results = {
                {type = "fluid", name = "heavy-oil", amount = 50},
                {type = "item", name = "barrel", amount = 1},
            },
            topology = {
                output_rank = 1,
            },
        },
        ["empty-light-oil-barrel"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "landfill", amount = 0.0945312654096},
                {type = "fluid", name = "steam", amount = 95.6301850546},
                {type = "item", name = "stone", amount = 4.74841753355},
                {type = "fluid", name = "heavy-oil", amount = 25.6016410705},
            },
            results = {
                {type = "fluid", name = "light-oil", amount = 50},
                {type = "item", name = "barrel", amount = 1},
            },
            topology = {
                output_rank = 1,
            },
        },
        ["empty-lubricant-barrel"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "grenade", amount = 0.685545556759},
                {type = "item", name = "stone-brick", amount = 3.42301530211},
                {type = "item", name = "copper-plate", amount = 4.47623535444},
            },
            results = {
                {type = "fluid", name = "lubricant", amount = 50},
                {type = "item", name = "barrel", amount = 1},
            },
            topology = {
                output_rank = 2,
            },
        },
        ["empty-petroleum-gas-barrel"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "fluid", name = "heavy-oil", amount = 14.0656425367},
                {type = "fluid", name = "water", amount = 1751.69967485},
            },
            results = {
                {type = "fluid", name = "petroleum-gas", amount = 50},
                {type = "item", name = "barrel", amount = 1},
            },
            topology = {
                output_rank = 1,
            },
        },
        ["empty-sulfuric-acid-barrel"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "shotgun-shell", amount = 2.29268668265},
                {type = "item", name = "stone-brick", amount = 4.12797092431},
            },
            results = {
                {type = "fluid", name = "sulfuric-acid", amount = 50},
                {type = "item", name = "barrel", amount = 1},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["empty-water-barrel"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "fluid", name = "crude-oil", amount = 102.871259984},
                {type = "item", name = "iron-ore", amount = 8.869274285},
                {type = "item", name = "copper-ore", amount = 5.7435997166},
            },
            results = {
                {type = "fluid", name = "water", amount = 50},
                {type = "item", name = "barrel", amount = 1},
            },
            topology = {
                output_rank = 0,
            },
        },
        ["energy-shield-equipment"] = {
            mode = "givens-multi-topology-balanced",
            repairs = {
                "reachability bootstrap: ingredients forced to already-reachable strictly earlier materials",
            },
            ingredients = {
                {type = "item", name = "sulfuric-acid-barrel", amount = 2.61954150798},
                {type = "item", name = "repair-pack", amount = 2.16990623023},
                {type = "item", name = "engine-unit", amount = 3.41288446229},
                {type = "item", name = "copper-cable", amount = 27.8089004447},
            },
            results = {
                {type = "item", name = "energy-shield-equipment", amount = 1},
                {type = "item", name = "uranium-235", amount = 0.519483914856},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["energy-shield-mk2-equipment"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "night-vision-equipment", amount = 4.5724449645},
                {type = "item", name = "uranium-ore", amount = 1394.5781911},
                {type = "item", name = "defender-capsule", amount = 6.24006667227},
                {type = "item", name = "energy-shield-equipment", amount = 3.28375729644},
            },
            results = {
                {type = "item", name = "energy-shield-mk2-equipment", amount = 1},
            },
            topology = {
                output_rank = 6,
            },
        },
        ["engine-unit"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "grenade", amount = 0.484116803685},
                {type = "item", name = "solid-fuel", amount = 4.39335714727},
                {type = "item", name = "pipe", amount = 1.13863870967},
                {type = "item", name = "iron-gear-wheel", amount = 0.786056768704},
            },
            results = {
                {type = "item", name = "engine-unit", amount = 1},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["exoskeleton-equipment"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "electric-furnace", amount = 2.35242015972},
                {type = "item", name = "centrifuge", amount = 0.232325980066},
                {type = "item", name = "rail", amount = 54.8996980742},
                {type = "item", name = "efficiency-module-2", amount = 0.564623053303},
                {type = "item", name = "electronic-circuit", amount = 87.8823802309},
            },
            results = {
                {type = "item", name = "exoskeleton-equipment", amount = 1},
            },
            topology = {
                output_rank = 6,
            },
        },
        ["explosive-cannon-shell"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "flamethrower", amount = 0.0548050462408},
                {type = "item", name = "battery", amount = 1.17392000987},
                {type = "item", name = "concrete", amount = 6.23858011787},
                {type = "item", name = "barrel", amount = 0.342294581524},
            },
            results = {
                {type = "item", name = "explosive-cannon-shell", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["explosive-rocket"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "battery-equipment", amount = 0.0241163882336},
                {type = "item", name = "cluster-grenade", amount = 0.0239624811956},
                {type = "item", name = "chemical-plant", amount = 0.0178644625792},
            },
            results = {
                {type = "item", name = "explosive-rocket", amount = 1},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["explosive-uranium-cannon-shell"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "selector-combinator", amount = 0.0678552773867},
                {type = "item", name = "underground-belt", amount = 0.398511702046},
                {type = "item", name = "battery-mk2-equipment", amount = 0.0020360723256},
                {type = "item", name = "personal-laser-defense-equipment", amount = 0.00225771236882},
            },
            results = {
                {type = "item", name = "explosive-uranium-cannon-shell", amount = 1},
            },
            topology = {
                output_rank = 6,
            },
        },
        ["explosives"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "barrel", amount = 0.0709347601505},
                {type = "item", name = "sulfur", amount = 0.363852704146},
                {type = "fluid", name = "water", amount = 65.1886630137},
                {type = "item", name = "coal", amount = 0.912201053198},
            },
            results = {
                {type = "item", name = "explosives", amount = 2},
                {type = "item", name = "electronic-circuit", amount = 0.0696618805002},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["express-splitter"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "discharge-defense-equipment", amount = 0.0289518382391},
                {type = "item", name = "express-underground-belt", amount = 0.269524605282},
                {type = "item", name = "modular-armor", amount = 0.0808325373992},
                {type = "item", name = "car", amount = 0.11183016776},
                {type = "item", name = "fast-splitter", amount = 0.348976693561},
            },
            results = {
                {type = "item", name = "express-splitter", amount = 1},
            },
            topology = {
                output_rank = 6,
            },
        },
        ["express-transport-belt"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "efficiency-module", amount = 0.184105847388},
                {type = "item", name = "refined-concrete", amount = 2.68867661492},
                {type = "item", name = "fast-transport-belt", amount = 0.180364829552},
                {type = "item", name = "explosive-cannon-shell", amount = 0.431456585841},
                {type = "item", name = "electric-engine-unit", amount = 0.24247466026},
            },
            results = {
                {type = "item", name = "express-transport-belt", amount = 1},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["express-underground-belt"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "discharge-defense-equipment", amount = 0.0162882898527},
                {type = "item", name = "artillery-turret", amount = 0.0883455189671},
                {type = "item", name = "speed-module", amount = 1.51498189273},
                {type = "item", name = "express-splitter", amount = 0.230966155112},
            },
            results = {
                {type = "item", name = "express-underground-belt", amount = 2},
            },
            topology = {
                output_rank = 6,
            },
        },
        ["fast-inserter"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "power-switch", amount = 0.299515940244},
                {type = "item", name = "distractor-capsule", amount = 0.016456248759},
                {type = "item", name = "automation-science-pack", amount = 0.614396308987},
                {type = "item", name = "solid-fuel", amount = 5.23294909002},
            },
            results = {
                {type = "item", name = "fast-inserter", amount = 1},
                {type = "item", name = "personal-roboport-equipment", amount = 0.00258411198102},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["fast-splitter"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "lab", amount = 0.313793358326},
                {type = "item", name = "splitter", amount = 0.45986294686},
                {type = "item", name = "productivity-module", amount = 0.419477096802},
                {type = "item", name = "petroleum-gas-barrel", amount = 1.7299794828},
            },
            results = {
                {type = "item", name = "fast-splitter", amount = 1},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["fast-transport-belt"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "constant-combinator", amount = 0.523309433362},
                {type = "item", name = "steel-plate", amount = 0.726892765543},
                {type = "item", name = "solar-panel", amount = 0.032403561401},
            },
            results = {
                {type = "item", name = "fast-transport-belt", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["fast-underground-belt"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "electric-engine-unit", amount = 0.669711749055},
                {type = "item", name = "uranium-235", amount = 1.52599220295},
                {type = "item", name = "flying-robot-frame", amount = 0.759353578699},
                {type = "item", name = "steel-chest", amount = 0.307833564875},
            },
            results = {
                {type = "item", name = "fast-underground-belt", amount = 2},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["firearm-magazine"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "solid-fuel", amount = 2.14247755137},
                {type = "item", name = "stone-brick", amount = 1.47719790186},
            },
            results = {
                {type = "item", name = "firearm-magazine", amount = 1},
                {type = "fluid", name = "lubricant", amount = 2.89836065574},
            },
            topology = {
                output_rank = 2,
            },
        },
        ["fission-reactor-equipment"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "exoskeleton-equipment", amount = 3.18011224464},
                {type = "item", name = "belt-immunity-equipment", amount = 44.9928162408},
                {type = "item", name = "storage-chest", amount = 60.3887128438},
                {type = "item", name = "centrifuge", amount = 2.42098013368},
            },
            results = {
                {type = "item", name = "fission-reactor-equipment", amount = 1},
            },
            topology = {
                output_rank = 7,
            },
        },
        ["flamethrower"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "shotgun-shell", amount = 8.34377250806},
                {type = "item", name = "engine-unit", amount = 1.06179812129},
                {type = "item", name = "iron-stick", amount = 8.4792491429},
            },
            results = {
                {type = "item", name = "flamethrower", amount = 1},
                {type = "item", name = "medium-electric-pole", amount = 0.324592074592},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["flamethrower-ammo"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "big-electric-pole", amount = 0.153342057313},
                {type = "item", name = "burner-inserter", amount = 2.02990221906},
                {type = "item", name = "shotgun-shell", amount = 2.13802599129},
                {type = "fluid", name = "light-oil", amount = 187.69193128},
            },
            results = {
                {type = "item", name = "flamethrower-ammo", amount = 1},
                {type = "item", name = "engine-unit", amount = 0.290502793296},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["flamethrower-turret"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "small-lamp", amount = 11.7336352563},
                {type = "item", name = "water-barrel", amount = 5.45307549206},
                {type = "item", name = "battery", amount = 15.6133023393},
                {type = "item", name = "explosives", amount = 64.3544590368},
                {type = "item", name = "steel-plate", amount = 4.53634497994},
            },
            results = {
                {type = "item", name = "flamethrower-turret", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["fluid-wagon"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "offshore-pump", amount = 4.61969947798},
                {type = "item", name = "piercing-shotgun-shell", amount = 3.16336125347},
                {type = "item", name = "heat-exchanger", amount = 0.299252442092},
                {type = "item", name = "storage-tank", amount = 0.234355739235},
                {type = "item", name = "advanced-circuit", amount = 4.84953667896},
            },
            results = {
                {type = "item", name = "fluid-wagon", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["flying-robot-frame"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "slowdown-capsule", amount = 0.330196570545},
                {type = "item", name = "rail-chain-signal", amount = 0.719767101195},
                {type = "item", name = "electric-engine-unit", amount = 0.446757552436},
                {type = "item", name = "fast-transport-belt", amount = 0.253775440144},
                {type = "item", name = "battery", amount = 1.96438154086},
                {type = "item", name = "processing-unit", amount = 0.114396115779},
                {type = "item", name = "copper-plate", amount = 2.15596499697},
            },
            results = {
                {type = "item", name = "flying-robot-frame", amount = 1},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["gate"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "automation-science-pack", amount = 1.71303553894},
                {type = "item", name = "solid-fuel", amount = 8.6826331713},
                {type = "item", name = "defender-capsule", amount = 0.131457585816},
                {type = "item", name = "stone-wall", amount = 0.899302676236},
            },
            results = {
                {type = "item", name = "gate", amount = 1},
                {type = "item", name = "cannon-shell", amount = 0.153029259897},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["grenade"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "light-armor", amount = 0.0749557286985},
                {type = "fluid", name = "petroleum-gas", amount = 45.7479970878},
                {type = "item", name = "coal", amount = 6.97380600397},
            },
            results = {
                {type = "item", name = "grenade", amount = 1},
            },
            topology = {
                output_rank = 2,
            },
        },
        ["gun-turret"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "steam-turbine", amount = 0.0826966813504},
                {type = "fluid", name = "petroleum-gas", amount = 231.065462403},
                {type = "item", name = "steel-chest", amount = 0.247555515285},
                {type = "item", name = "sulfur", amount = 6.77501615954},
            },
            results = {
                {type = "item", name = "gun-turret", amount = 1},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["hazard-concrete"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "burner-mining-drill", amount = 0.174708072175},
                {type = "item", name = "stone-wall", amount = 0.264750733307},
                {type = "item", name = "grenade", amount = 0.376720809783},
                {type = "item", name = "concrete", amount = 1.43206883177},
            },
            results = {
                {type = "item", name = "hazard-concrete", amount = 10},
                {type = "item", name = "storage-tank", amount = 0.0165533980583},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["heat-exchanger"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "heat-pipe", amount = 0.323914006413},
                {type = "item", name = "offshore-pump", amount = 1.63095387313},
                {type = "fluid", name = "heavy-oil", amount = 557.771964672},
                {type = "item", name = "electronic-circuit", amount = 16.4811775182},
                {type = "item", name = "iron-plate", amount = 21.8409453709},
            },
            results = {
                {type = "item", name = "heat-exchanger", amount = 1},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["heat-pipe"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "iron-gear-wheel", amount = 9.50969146746},
                {type = "fluid", name = "heavy-oil", amount = 238.36537767},
                {type = "item", name = "copper-plate", amount = 25.9314798519},
                {type = "item", name = "steel-plate", amount = 2.26106438042},
            },
            results = {
                {type = "item", name = "heat-pipe", amount = 1},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["heavy-armor"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "iron-stick", amount = 238.088473737},
                {type = "fluid", name = "lubricant", amount = 940.643914779},
                {type = "item", name = "stone", amount = 314.554620622},
                {type = "item", name = "stone-furnace", amount = 21.0993041509},
            },
            results = {
                {type = "item", name = "heavy-armor", amount = 1},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["heavy-oil-barrel"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "rocket-launcher", amount = 0.09998267691},
                {type = "item", name = "offshore-pump", amount = 0.153982908304},
                {type = "item", name = "heat-exchanger", amount = 0.0274439566393},
                {type = "item", name = "barrel", amount = 0.388088200579},
            },
            results = {
                {type = "item", name = "heavy-oil-barrel", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["heavy-oil-cracking"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "fluid", name = "petroleum-gas", amount = 25.8834064653},
                {type = "item", name = "coal", amount = 3.67695012542},
                {type = "item", name = "stone-furnace", amount = 0.836496273},
            },
            results = {
                {type = "fluid", name = "light-oil", amount = 30},
            },
            topology = {
                output_rank = 1,
            },
        },
        ["inserter"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "fluid", name = "sulfuric-acid", amount = 10.0029736797},
                {type = "fluid", name = "lubricant", amount = 11.2922561684},
                {type = "item", name = "electronic-circuit", amount = 0.675000652226},
                {type = "item", name = "barrel", amount = 0.1487032312},
            },
            results = {
                {type = "item", name = "inserter", amount = 1},
                {type = "item", name = "lubricant-barrel", amount = 0.0465337721191},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["iron-chest"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "stone", amount = 7.84338914702},
                {type = "fluid", name = "heavy-oil", amount = 23.5607399373},
                {type = "item", name = "iron-plate", amount = 2.86172349571},
            },
            results = {
                {type = "item", name = "iron-chest", amount = 1},
                {type = "item", name = "firearm-magazine", amount = 0.188970588235},
            },
            topology = {
                output_rank = 2,
            },
        },
        ["iron-gear-wheel"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "fluid", name = "petroleum-gas", amount = 11.2945327362},
                {type = "item", name = "copper-plate", amount = 0.614866557487},
                {type = "item", name = "iron-plate", amount = 0.659365833828},
            },
            results = {
                {type = "item", name = "iron-gear-wheel", amount = 1},
            },
            topology = {
                output_rank = 2,
            },
        },
        ["iron-plate"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "copper-plate", amount = 0.175449407042},
                {type = "item", name = "iron-ore", amount = 0.461955151736},
            },
            results = {
                {type = "item", name = "iron-plate", amount = 1},
            },
            topology = {
                output_rank = 1,
            },
        },
        ["iron-stick"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "landfill", amount = 0.0172782280029},
                {type = "fluid", name = "lubricant", amount = 2.3765749472},
                {type = "item", name = "iron-plate", amount = 0.348076709753},
            },
            results = {
                {type = "item", name = "iron-stick", amount = 2},
            },
            topology = {
                output_rank = 2,
            },
        },
        ["kovarex-enrichment-process"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "small-lamp", amount = 66.8235279377},
                {type = "item", name = "accumulator", amount = 13.6154482741},
                {type = "item", name = "flamethrower-turret", amount = 0.466424611908},
            },
            results = {
                {type = "item", name = "uranium-235", amount = 41},
                {type = "item", name = "uranium-238", amount = 2},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["lab"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "petroleum-gas-barrel", amount = 2.52518302681},
                {type = "item", name = "defender-capsule", amount = 0.184063325028},
                {type = "item", name = "inserter", amount = 0.863129721535},
                {type = "item", name = "electronic-circuit", amount = 5.27206899936},
                {type = "item", name = "engine-unit", amount = 0.354295943101},
            },
            results = {
                {type = "item", name = "lab", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["land-mine"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "constant-combinator", amount = 0.322217116148},
                {type = "item", name = "fast-transport-belt", amount = 0.102235966918},
                {type = "item", name = "refined-concrete", amount = 0.531888013897},
                {type = "fluid", name = "lubricant", amount = 13.3139246522},
                {type = "item", name = "barrel", amount = 0.103331622767},
            },
            results = {
                {type = "item", name = "land-mine", amount = 4},
                {type = "item", name = "rail-chain-signal", amount = 0.117067873303},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["landfill"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "fluid", name = "steam", amount = 145.388205302},
                {type = "item", name = "stone", amount = 11.5904171594},
                {type = "fluid", name = "heavy-oil", amount = 22.792312152},
                {type = "item", name = "coal", amount = 4.0991993251},
            },
            results = {
                {type = "item", name = "landfill", amount = 1},
            },
            topology = {
                output_rank = 1,
            },
        },
        ["laser-turret"] = {
            mode = "givens-multi-topology-balanced",
            repairs = {
                "reachability bootstrap: ingredients forced to already-reachable strictly earlier materials",
            },
            ingredients = {
                {type = "item", name = "battery", amount = 16.017811211},
                {type = "item", name = "steel-plate", amount = 17.4653525944},
                {type = "item", name = "electronic-circuit", amount = 18.1132278989},
            },
            results = {
                {type = "item", name = "laser-turret", amount = 1},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["light-armor"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "firearm-magazine", amount = 4.42493441341},
                {type = "fluid", name = "petroleum-gas", amount = 232.360751992},
                {type = "fluid", name = "light-oil", amount = 71.6667545584},
            },
            results = {
                {type = "item", name = "light-armor", amount = 1},
                {type = "item", name = "iron-gear-wheel", amount = 1.70776255708},
            },
            topology = {
                output_rank = 2,
            },
        },
        ["light-oil-barrel"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "piercing-rounds-magazine", amount = 0.282056760024},
                {type = "item", name = "refined-concrete", amount = 0.853873373597},
                {type = "item", name = "transport-belt", amount = 0.593135089765},
                {type = "fluid", name = "light-oil", amount = 45.6872850017},
                {type = "item", name = "barrel", amount = 0.164626252454},
            },
            results = {
                {type = "item", name = "light-oil-barrel", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["light-oil-cracking"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "fluid", name = "light-oil", amount = 8.87794011925},
                {type = "item", name = "iron-ore", amount = 1.82212690572},
                {type = "fluid", name = "water", amount = 215.96706595},
            },
            results = {
                {type = "fluid", name = "petroleum-gas", amount = 20},
            },
            topology = {
                output_rank = 1,
            },
        },
        ["locomotive"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "cluster-grenade", amount = 1.29427153581},
                {type = "item", name = "hazard-concrete", amount = 77.6303858123},
                {type = "item", name = "stone-wall", amount = 13.7675969035},
                {type = "item", name = "transport-belt", amount = 16.8883539648},
                {type = "item", name = "iron-plate", amount = 53.2269333675},
                {type = "item", name = "electronic-circuit", amount = 36.131730589},
            },
            results = {
                {type = "item", name = "locomotive", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["logistic-robot"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "production-science-pack", amount = 0.303750298243},
                {type = "item", name = "nuclear-fuel", amount = 0.622009013334},
                {type = "item", name = "assembling-machine-2", amount = 0.21382931384},
            },
            results = {
                {type = "item", name = "logistic-robot", amount = 1},
            },
            topology = {
                output_rank = 6,
            },
        },
        ["logistic-science-pack"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "tank", amount = 0.00164626627068},
                {type = "item", name = "fast-underground-belt", amount = 0.0200408831633},
                {type = "item", name = "processing-unit", amount = 0.0485570196253},
                {type = "item", name = "inserter", amount = 0.232036201912},
            },
            results = {
                {type = "item", name = "logistic-science-pack", amount = 1},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["long-handed-inserter"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "cluster-grenade", amount = 0.0263953661391},
                {type = "item", name = "concrete", amount = 3.47383916918},
                {type = "item", name = "inserter", amount = 0.188227475022},
                {type = "item", name = "battery", amount = 0.321666851948},
                {type = "item", name = "steel-plate", amount = 0.185944611206},
            },
            results = {
                {type = "item", name = "long-handed-inserter", amount = 1},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["low-density-structure"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "boiler", amount = 1.26567141613},
                {type = "item", name = "gun-turret", amount = 0.193295025708},
                {type = "fluid", name = "lubricant", amount = 70.014911481},
                {type = "item", name = "concrete", amount = 8.84770842815},
            },
            results = {
                {type = "item", name = "low-density-structure", amount = 1},
                {type = "item", name = "barrel", amount = 0.549360613811},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["lubricant"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "shotgun-shell", amount = 0.101633992171},
                {type = "fluid", name = "heavy-oil", amount = 2.8460793792},
                {type = "item", name = "solid-fuel", amount = 0.32619644662},
            },
            results = {
                {type = "fluid", name = "lubricant", amount = 10},
            },
            topology = {
                output_rank = 2,
            },
        },
        ["lubricant-barrel"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "inserter", amount = 0.753432440991},
                {type = "item", name = "sulfur", amount = 2.93854493431},
                {type = "fluid", name = "lubricant", amount = 19.428037366},
                {type = "item", name = "barrel", amount = 0.146778396528},
                {type = "fluid", name = "water", amount = 355.579737948},
            },
            results = {
                {type = "item", name = "lubricant-barrel", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["medium-electric-pole"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "transport-belt", amount = 2.67381334522},
                {type = "fluid", name = "heavy-oil", amount = 77.2896411684},
                {type = "item", name = "firearm-magazine", amount = 0.367912663407},
                {type = "item", name = "steel-plate", amount = 0.266050792451},
                {type = "item", name = "pipe", amount = 0.612084575248},
                {type = "item", name = "iron-stick", amount = 0.611218893845},
            },
            results = {
                {type = "item", name = "medium-electric-pole", amount = 1},
                {type = "item", name = "steam-engine", amount = 0.0513464991023},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["military-science-pack"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "rail-signal", amount = 0.852683002366},
                {type = "item", name = "steel-chest", amount = 0.1098522584},
                {type = "item", name = "stone-wall", amount = 1.0313654282},
                {type = "item", name = "explosives", amount = 8.73156532805},
                {type = "item", name = "piercing-rounds-magazine", amount = 0.150895845609},
            },
            results = {
                {type = "item", name = "military-science-pack", amount = 2},
                {type = "item", name = "rocket", amount = 0.866731203614},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["modular-armor"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "speed-module", amount = 3.61272807281},
                {type = "item", name = "laser-turret", amount = 0.819500301298},
                {type = "item", name = "fast-splitter", amount = 0.57233257185},
                {type = "item", name = "engine-unit", amount = 3.46489321566},
                {type = "item", name = "steel-plate", amount = 14.5708076581},
            },
            results = {
                {type = "item", name = "modular-armor", amount = 1},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["night-vision-equipment"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "decider-combinator", amount = 2.58555345335},
                {type = "item", name = "requester-chest", amount = 0.504201845066},
                {type = "item", name = "distractor-capsule", amount = 0.171158806765},
            },
            results = {
                {type = "item", name = "night-vision-equipment", amount = 1},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["nuclear-fuel"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "exoskeleton-equipment", amount = 0.00722585895301},
                {type = "item", name = "satellite", amount = 0.000228376678285},
                {type = "item", name = "tank", amount = 0.00489904061358},
                {type = "item", name = "efficiency-module-2", amount = 0.0118804017937},
                {type = "item", name = "fast-underground-belt", amount = 0.0628497456896},
            },
            results = {
                {type = "item", name = "nuclear-fuel", amount = 1},
            },
            topology = {
                output_rank = 6,
            },
        },
        ["nuclear-fuel-reprocessing"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "lubricant-barrel", amount = 3.22699459418},
                {type = "item", name = "constant-combinator", amount = 3.26864562081},
            },
            results = {
                {type = "item", name = "uranium-238", amount = 3},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["nuclear-reactor"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "logistic-science-pack", amount = 262.61555745},
                {type = "item", name = "speed-module", amount = 44.9737478352},
                {type = "item", name = "advanced-circuit", amount = 222.038350627},
                {type = "item", name = "assembling-machine-2", amount = 11.2024069573},
                {type = "item", name = "battery-equipment", amount = 8.55853725485},
            },
            results = {
                {type = "item", name = "nuclear-reactor", amount = 1},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["offshore-pump"] = {
            mode = "givens-multi-topology-balanced",
            repairs = {
                "reachability bootstrap: ingredients forced to already-reachable strictly earlier materials",
            },
            ingredients = {
                {type = "item", name = "pipe", amount = 2.72487173689},
                {type = "item", name = "iron-gear-wheel", amount = 1.57505221659},
                {type = "fluid", name = "heavy-oil", amount = 12.7027717691},
            },
            results = {
                {type = "item", name = "offshore-pump", amount = 1},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["oil-refinery"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "medium-electric-pole", amount = 1.55868404675},
                {type = "item", name = "underground-belt", amount = 2.29088310596},
                {type = "item", name = "engine-unit", amount = 2.04631459294},
                {type = "item", name = "electronic-circuit", amount = 20.0027085736},
                {type = "item", name = "low-density-structure", amount = 0.635521531171},
                {type = "item", name = "steel-plate", amount = 2.33226883876},
            },
            results = {
                {type = "item", name = "oil-refinery", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["passive-provider-chest"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "night-vision-equipment", amount = 0.0957743287993},
                {type = "item", name = "uranium-238", amount = 4.26633646951},
                {type = "item", name = "energy-shield-equipment", amount = 0.0687815060538},
                {type = "item", name = "steel-chest", amount = 0.159465279436},
                {type = "item", name = "piercing-rounds-magazine", amount = 0.587750384571},
                {type = "item", name = "electronic-circuit", amount = 4.30958506552},
            },
            results = {
                {type = "item", name = "passive-provider-chest", amount = 1},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["personal-laser-defense-equipment"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "bulk-inserter", amount = 5.91520394768},
                {type = "item", name = "solar-panel", amount = 6.87171179064},
                {type = "item", name = "explosive-cannon-shell", amount = 34.1653991144},
                {type = "item", name = "processing-unit", amount = 7.34004545347},
                {type = "item", name = "engine-unit", amount = 12.0899644506},
                {type = "item", name = "uranium-238", amount = 103.563384781},
            },
            results = {
                {type = "item", name = "personal-laser-defense-equipment", amount = 1},
                {type = "item", name = "explosive-uranium-cannon-shell", amount = 12.7452334912},
            },
            topology = {
                output_rank = 6,
            },
        },
        ["personal-roboport-equipment"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "power-switch", amount = 6.81926270791},
                {type = "item", name = "fast-inserter", amount = 8.12032630062},
                {type = "item", name = "defender-capsule", amount = 1.91375320773},
                {type = "item", name = "battery", amount = 17.0416779575},
                {type = "item", name = "rocket", amount = 20.521261975},
                {type = "item", name = "explosives", amount = 99.4876067827},
            },
            results = {
                {type = "item", name = "personal-roboport-equipment", amount = 1},
                {type = "item", name = "explosive-rocket", amount = 8.44024349002},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["personal-roboport-mk2-equipment"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "inserter", amount = 386.083281667},
                {type = "item", name = "nuclear-reactor", amount = 0.276792279761},
                {type = "item", name = "speed-module", amount = 39.7885194559},
                {type = "item", name = "assembling-machine-2", amount = 18.1876002732},
                {type = "item", name = "processing-unit", amount = 34.8383359774},
            },
            results = {
                {type = "item", name = "personal-roboport-mk2-equipment", amount = 1},
                {type = "item", name = "assembling-machine-3", amount = 1.6953979274},
                {type = "item", name = "battery-mk2-equipment", amount = 0.214474313561},
            },
            topology = {
                output_rank = 6,
            },
        },
        ["petroleum-gas-barrel"] = {
            mode = "givens-multi-topology-balanced",
            repairs = {
                "reachability bootstrap: ingredients forced to already-reachable strictly earlier materials",
            },
            ingredients = {
                {type = "item", name = "plastic-bar", amount = 3.00615438504},
                {type = "item", name = "electronic-circuit", amount = 1.19187109577},
                {type = "item", name = "steel-chest", amount = 0.0274529514816},
                {type = "item", name = "iron-gear-wheel", amount = 0.824295817192},
            },
            results = {
                {type = "item", name = "petroleum-gas-barrel", amount = 1},
                {type = "item", name = "lab", amount = 0.0166626532716},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["piercing-rounds-magazine"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "steam-engine", amount = 0.112283089127},
                {type = "item", name = "rocket-fuel", amount = 0.426434446862},
                {type = "item", name = "transport-belt", amount = 1.43779646111},
                {type = "item", name = "stone-wall", amount = 0.513029303272},
                {type = "item", name = "firearm-magazine", amount = 0.197838613675},
                {type = "item", name = "solid-fuel", amount = 1.63787897973},
            },
            results = {
                {type = "item", name = "piercing-rounds-magazine", amount = 2},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["piercing-shotgun-shell"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "heat-exchanger", amount = 0.0459800518316},
                {type = "item", name = "storage-tank", amount = 0.0210589418136},
                {type = "item", name = "pipe", amount = 2.14851691328},
                {type = "item", name = "shotgun-shell", amount = 0.395920136352},
                {type = "item", name = "steel-plate", amount = 0.359154289159},
                {type = "item", name = "iron-gear-wheel", amount = 0.560458505342},
            },
            results = {
                {type = "item", name = "piercing-shotgun-shell", amount = 2},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["pipe"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "fluid", name = "heavy-oil", amount = 3.07733316124},
                {type = "item", name = "iron-plate", amount = 0.353587606835},
                {type = "fluid", name = "light-oil", amount = 4.07140090264},
            },
            results = {
                {type = "item", name = "pipe", amount = 1},
            },
            topology = {
                output_rank = 2,
            },
        },
        ["pipe-to-ground"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "gun-turret", amount = 0.0921673033796},
                {type = "item", name = "low-density-structure", amount = 0.120034430744},
                {type = "item", name = "steel-furnace", amount = 0.0867040671307},
                {type = "item", name = "copper-cable", amount = 5.66150041188},
            },
            results = {
                {type = "item", name = "pipe-to-ground", amount = 2},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["plastic-bar"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "solid-fuel", amount = 0.479739829822},
                {type = "item", name = "coal", amount = 2.1712545893},
                {type = "item", name = "sulfur", amount = 0.353340664821},
            },
            results = {
                {type = "item", name = "plastic-bar", amount = 2},
            },
            topology = {
                output_rank = 2,
            },
        },
        ["poison-capsule"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "sulfuric-acid-barrel", amount = 0.704843986611},
                {type = "item", name = "heavy-armor", amount = 0.0139226444941},
                {type = "item", name = "light-oil-barrel", amount = 0.553208309492},
                {type = "item", name = "piercing-rounds-magazine", amount = 0.736247689305},
                {type = "item", name = "steel-chest", amount = 0.0650392014289},
            },
            results = {
                {type = "item", name = "poison-capsule", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["power-armor"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "bulk-inserter", amount = 7.7613053761},
                {type = "item", name = "artillery-wagon", amount = 0.535728730086},
                {type = "item", name = "processing-unit", amount = 20.3823311979},
                {type = "item", name = "flying-robot-frame", amount = 13.9858766668},
                {type = "item", name = "low-density-structure", amount = 5.1187559926},
            },
            results = {
                {type = "item", name = "power-armor", amount = 1},
            },
            topology = {
                output_rank = 6,
            },
        },
        ["power-armor-mk2"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "uranium-rounds-magazine", amount = 458.273418497},
                {type = "item", name = "express-transport-belt", amount = 196.491070712},
                {type = "item", name = "uranium-fuel-cell", amount = 853.170504365},
                {type = "item", name = "refined-hazard-concrete", amount = 2682.79457197},
                {type = "item", name = "rocket-silo", amount = 0.207941574449},
                {type = "item", name = "speed-module-2", amount = 7.65143505649},
            },
            results = {
                {type = "item", name = "power-armor-mk2", amount = 1},
            },
            topology = {
                output_rank = 7,
            },
        },
        ["power-switch"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "rocket-fuel", amount = 0.366092744545},
                {type = "fluid", name = "heavy-oil", amount = 34.8216065816},
                {type = "item", name = "piercing-rounds-magazine", amount = 0.141280880365},
                {type = "item", name = "stone-wall", amount = 0.38995460899},
                {type = "item", name = "iron-gear-wheel", amount = 1.29205845039},
            },
            results = {
                {type = "item", name = "power-switch", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["processing-unit"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "cliff-explosives", amount = 0.876147120937},
                {type = "item", name = "heavy-oil-barrel", amount = 1.74257466015},
                {type = "item", name = "flamethrower", amount = 0.292356386935},
                {type = "item", name = "refined-concrete", amount = 8.46804482092},
            },
            results = {
                {type = "item", name = "processing-unit", amount = 1},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["production-science-pack"] = {
            mode = "givens-multi-topology-balanced",
            repairs = {
                "reachability bootstrap: ingredients forced to already-reachable strictly earlier materials",
            },
            ingredients = {
                {type = "item", name = "assembling-machine-2", amount = 2.75902784424},
                {type = "item", name = "centrifuge", amount = 0.0355375370499},
                {type = "item", name = "electric-furnace", amount = 0.357439673514},
                {type = "item", name = "rail", amount = 11.060953253},
            },
            results = {
                {type = "item", name = "production-science-pack", amount = 3},
                {type = "item", name = "logistic-robot", amount = 0.41205809873},
                {type = "item", name = "uranium-fuel-cell", amount = 0.182300512194},
            },
            topology = {
                output_rank = 6,
            },
        },
        ["productivity-module"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "advanced-circuit", amount = 4.37771258322},
                {type = "item", name = "fluid-wagon", amount = 0.0787181101007},
                {type = "item", name = "steel-chest", amount = 0.159288757965},
            },
            results = {
                {type = "item", name = "productivity-module", amount = 1},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["productivity-module-2"] = {
            mode = "givens-multi-topology-balanced",
            repairs = {
                "reachability bootstrap: ingredients forced to already-reachable strictly earlier materials",
            },
            ingredients = {
                {type = "item", name = "tank", amount = 0.316557593887},
                {type = "item", name = "productivity-module", amount = 2.29115909152},
                {type = "item", name = "assembling-machine-1", amount = 4.71471169463},
                {type = "item", name = "cannon-shell", amount = 9.13431313104},
                {type = "item", name = "underground-belt", amount = 6.80695129225},
            },
            results = {
                {type = "item", name = "productivity-module-2", amount = 1},
            },
            topology = {
                output_rank = 6,
            },
        },
        ["productivity-module-3"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "destroyer-capsule", amount = 0.888874639837},
                {type = "item", name = "uranium-235", amount = 44.3254324027},
                {type = "item", name = "energy-shield-equipment", amount = 4.03669890867},
                {type = "item", name = "processing-unit", amount = 10.4310553688},
                {type = "item", name = "steel-chest", amount = 8.29313639709},
            },
            results = {
                {type = "item", name = "productivity-module-3", amount = 1},
            },
            topology = {
                output_rank = 7,
            },
        },
        ["programmable-speaker"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "cliff-explosives", amount = 0.202056107965},
                {type = "item", name = "electric-mining-drill", amount = 0.141849781508},
                {type = "item", name = "concrete", amount = 4.12524649037},
                {type = "item", name = "stone-furnace", amount = 1.13316394326},
                {type = "item", name = "pipe", amount = 1.77077105658},
                {type = "fluid", name = "heavy-oil", amount = 35.307487343},
            },
            results = {
                {type = "item", name = "programmable-speaker", amount = 1},
                {type = "item", name = "land-mine", amount = 0.911502782931},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["pump"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "pumpjack", amount = 0.035565453726},
                {type = "item", name = "engine-unit", amount = 0.240998592237},
                {type = "item", name = "advanced-circuit", amount = 0.697511424794},
                {type = "item", name = "steel-plate", amount = 0.374598611951},
                {type = "item", name = "stone-brick", amount = 3.05270593852},
            },
            results = {
                {type = "item", name = "pump", amount = 1},
                {type = "item", name = "radar", amount = 0.0571821305842},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["pumpjack"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "cluster-grenade", amount = 0.251975878761},
                {type = "item", name = "concrete", amount = 31.091930054},
                {type = "item", name = "battery", amount = 3.12392676324},
                {type = "item", name = "steel-plate", amount = 1.90276716514},
                {type = "item", name = "pipe", amount = 1.92055391662},
            },
            results = {
                {type = "item", name = "pumpjack", amount = 1},
                {type = "item", name = "inserter", amount = 1.26262245667},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["radar"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "flamethrower-ammo", amount = 0.219172480711},
                {type = "item", name = "heavy-oil-barrel", amount = 0.419367071999},
                {type = "item", name = "concrete", amount = 9.07368766138},
                {type = "item", name = "advanced-circuit", amount = 1.01477870539},
                {type = "item", name = "grenade", amount = 0.416212355259},
            },
            results = {
                {type = "item", name = "radar", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["rail"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "cargo-wagon", amount = 0.00895923921857},
                {type = "item", name = "rocket-fuel", amount = 0.245013001294},
                {type = "item", name = "stone-wall", amount = 0.273891319062},
                {type = "item", name = "iron-stick", amount = 0.46887975209},
                {type = "item", name = "steel-plate", amount = 0.174782835382},
            },
            results = {
                {type = "item", name = "rail", amount = 2},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["rail-chain-signal"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "submachine-gun", amount = 0.0428500266199},
                {type = "item", name = "electric-engine-unit", amount = 0.0691361546776},
                {type = "item", name = "electronic-circuit", amount = 0.922368415161},
                {type = "item", name = "battery", amount = 0.307586336259},
            },
            results = {
                {type = "item", name = "rail-chain-signal", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["rail-signal"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "storage-tank", amount = 0.0305121140671},
                {type = "item", name = "stone-brick", amount = 2.30350245188},
                {type = "item", name = "piercing-rounds-magazine", amount = 0.139448331583},
                {type = "item", name = "grenade", amount = 0.25059225856},
            },
            results = {
                {type = "item", name = "rail-signal", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["refined-concrete"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "boiler", amount = 0.749179709117},
                {type = "fluid", name = "lubricant", amount = 49.9307537468},
                {type = "item", name = "concrete", amount = 6.51671606439},
                {type = "item", name = "sulfur", amount = 4.22321422261},
                {type = "item", name = "steel-plate", amount = 0.884179925992},
            },
            results = {
                {type = "item", name = "refined-concrete", amount = 10},
                {type = "item", name = "explosives", amount = 2.73808510638},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["refined-hazard-concrete"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "heavy-armor", amount = 0.0228386594422},
                {type = "item", name = "light-oil-barrel", amount = 0.904142057842},
                {type = "item", name = "refined-concrete", amount = 3.64702301719},
            },
            results = {
                {type = "item", name = "refined-hazard-concrete", amount = 10},
                {type = "item", name = "fast-transport-belt", amount = 0.234881043745},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["repair-pack"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "battery", amount = 0.645053363861},
                {type = "item", name = "electronic-circuit", amount = 1.28062725542},
                {type = "fluid", name = "sulfuric-acid", amount = 10.5347801667},
                {type = "item", name = "engine-unit", amount = 0.115707424708},
            },
            results = {
                {type = "item", name = "repair-pack", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["requester-chest"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "poison-capsule", amount = 0.46034087677},
                {type = "item", name = "defender-capsule", amount = 0.32748367675},
                {type = "item", name = "distractor-capsule", amount = 0.0466968116611},
                {type = "item", name = "uranium-238", amount = 2.7135965428},
                {type = "item", name = "solid-fuel", amount = 10.7006786424},
                {type = "fluid", name = "sulfuric-acid", amount = 55.5024688038},
            },
            results = {
                {type = "item", name = "requester-chest", amount = 1},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["roboport"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "train-stop", amount = 3.43446537155},
                {type = "item", name = "radar", amount = 5.32033808681},
                {type = "item", name = "solar-panel", amount = 1.02635974469},
                {type = "item", name = "advanced-circuit", amount = 30.7042710742},
                {type = "item", name = "engine-unit", amount = 3.65362287885},
                {type = "item", name = "steel-plate", amount = 11.6269487141},
            },
            results = {
                {type = "item", name = "roboport", amount = 1},
                {type = "item", name = "solar-panel-equipment", amount = 0.640572582517},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["rocket"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "arithmetic-combinator", amount = 0.0563143005761},
                {type = "item", name = "transport-belt", amount = 0.401985631248},
                {type = "item", name = "explosives", amount = 1.04708224761},
            },
            results = {
                {type = "item", name = "rocket", amount = 1},
                {type = "item", name = "underground-belt", amount = 0.0399548751007},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["rocket-fuel"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "cargo-wagon", amount = 0.020542268529},
                {type = "item", name = "solid-fuel", amount = 3.6238213005},
                {type = "item", name = "copper-cable", amount = 4.37950781951},
            },
            results = {
                {type = "item", name = "rocket-fuel", amount = 1},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["rocket-launcher"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "low-density-structure", amount = 0.169174375649},
                {type = "fluid", name = "sulfuric-acid", amount = 47.7077055131},
                {type = "item", name = "shotgun-shell", amount = 1.07057975324},
                {type = "item", name = "concrete", amount = 10.4470665816},
                {type = "item", name = "barrel", amount = 0.664427065463},
            },
            results = {
                {type = "item", name = "rocket-launcher", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["rocket-part"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "utility-science-pack", amount = 3.34131828886},
                {type = "item", name = "belt-immunity-equipment", amount = 1.88455990958},
                {type = "item", name = "battery-equipment", amount = 1.42420007202},
                {type = "item", name = "uranium-238", amount = 61.7297667931},
                {type = "item", name = "piercing-rounds-magazine", amount = 18.2475632769},
                {type = "item", name = "steel-chest", amount = 1.76969105558},
            },
            results = {
                {type = "item", name = "rocket-part", amount = 1},
                {type = "item", name = "uranium-rounds-magazine", amount = 8.368897308},
            },
            topology = {
                output_rank = 6,
            },
        },
        ["rocket-silo"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "artillery-shell", amount = 45.3563867434},
                {type = "item", name = "uranium-rounds-magazine", amount = 208.963440492},
                {type = "item", name = "uranium-fuel-cell", amount = 421.519855602},
                {type = "item", name = "refined-concrete", amount = 1656.67976404},
                {type = "item", name = "fast-transport-belt", amount = 134.208581728},
                {type = "item", name = "processing-unit", amount = 64.6115335328},
                {type = "item", name = "efficiency-module-2", amount = 2.72386625814},
            },
            results = {
                {type = "item", name = "rocket-silo", amount = 1},
                {type = "item", name = "rocket-part", amount = 2.1867844915},
            },
            topology = {
                output_rank = 6,
            },
        },
        ["satellite"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "explosive-rocket", amount = 1278.97315276},
                {type = "item", name = "artillery-turret", amount = 7.63591975595},
                {type = "item", name = "lab", amount = 39.1224146053},
                {type = "item", name = "fast-splitter", amount = 39.1154147929},
                {type = "item", name = "barrel", amount = 251.736824248},
                {type = "item", name = "solar-panel", amount = 20.6719321131},
                {type = "item", name = "accumulator", amount = 41.1952784685},
            },
            results = {
                {type = "item", name = "satellite", amount = 1},
                {type = "item", name = "express-splitter", amount = 11.0070740528},
            },
            topology = {
                output_rank = 6,
            },
        },
        ["selector-combinator"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "medium-electric-pole", amount = 1.85870503081},
                {type = "item", name = "decider-combinator", amount = 2.67772802102},
                {type = "item", name = "inserter", amount = 5.50134196623},
            },
            results = {
                {type = "item", name = "selector-combinator", amount = 1},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["shotgun"] = {
            mode = "unchanged",
            reason = "unsupported/unpriced material in original LP",
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
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "stone-brick", amount = 1.03796060237},
                {type = "item", name = "steel-plate", amount = 0.205464484142},
                {type = "fluid", name = "petroleum-gas", amount = 18.2376831933},
            },
            results = {
                {type = "item", name = "shotgun-shell", amount = 1},
            },
            topology = {
                output_rank = 2,
            },
        },
        ["slowdown-capsule"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "rocket", amount = 0.87269270264},
                {type = "item", name = "inserter", amount = 0.383861703203},
                {type = "item", name = "electronic-circuit", amount = 2.33240513457},
                {type = "item", name = "explosives", amount = 4.68805084344},
                {type = "item", name = "iron-plate", amount = 2.75165616896},
            },
            results = {
                {type = "item", name = "slowdown-capsule", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["small-electric-pole"] = {
            mode = "unchanged",
            reason = "unsupported/unpriced material in original LP",
            ingredients = {
                {type = "item", name = "copper-cable", amount = 2},
                {type = "item", name = "wood", amount = 1},
            },
            results = {
                {type = "item", name = "small-electric-pole", amount = 2},
            },
        },
        ["small-lamp"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "steam-turbine", amount = 0.00416083946976},
                {type = "item", name = "car", amount = 0.00393602331882},
                {type = "item", name = "copper-cable", amount = 2.29759695111},
                {type = "fluid", name = "petroleum-gas", amount = 23.9340240743},
                {type = "item", name = "stone-brick", amount = 0.759205023276},
                {type = "item", name = "steel-plate", amount = 0.1304341046},
            },
            results = {
                {type = "item", name = "small-lamp", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["solar-panel"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "oil-refinery", amount = 0.101858312811},
                {type = "item", name = "assembling-machine-1", amount = 0.688706065367},
                {type = "item", name = "big-electric-pole", amount = 0.186283532032},
                {type = "item", name = "flamethrower", amount = 0.207471939482},
                {type = "item", name = "copper-plate", amount = 29.9357916114},
            },
            results = {
                {type = "item", name = "solar-panel", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["solar-panel-equipment"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "train-stop", amount = 1.00572835428},
                {type = "item", name = "roboport", amount = 0.0586692094936},
                {type = "item", name = "pump", amount = 0.733230092461},
                {type = "item", name = "solar-panel", amount = 0.319669303313},
            },
            results = {
                {type = "item", name = "solar-panel-equipment", amount = 1},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["solid-fuel-from-heavy-oil"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "fluid", name = "heavy-oil", amount = 9.9297550137},
                {type = "item", name = "firearm-magazine", amount = 0.136984477613},
                {type = "item", name = "steel-plate", amount = 0.0476039441124},
                {type = "item", name = "pipe", amount = 0.115313807509},
            },
            results = {
                {type = "item", name = "solid-fuel", amount = 1},
            },
            topology = {
                output_rank = 2,
            },
        },
        ["solid-fuel-from-light-oil"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "shotgun-shell", amount = 0.0781960072837},
                {type = "fluid", name = "light-oil", amount = 3.68694895583},
                {type = "item", name = "pipe", amount = 0.0839493979094},
            },
            results = {
                {type = "item", name = "solid-fuel", amount = 1},
                {type = "item", name = "steel-plate", amount = 0.0134841628959},
            },
            topology = {
                output_rank = 2,
            },
        },
        ["solid-fuel-from-petroleum-gas"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "fluid", name = "light-oil", amount = 6.12754184272},
                {type = "fluid", name = "lubricant", amount = 2.66829780648},
                {type = "item", name = "stone-brick", amount = 0.310173378607},
            },
            results = {
                {type = "item", name = "solid-fuel", amount = 1},
                {type = "item", name = "firearm-magazine", amount = 0.0214821222607},
            },
            topology = {
                output_rank = 2,
            },
        },
        ["speed-module"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "programmable-speaker", amount = 1.69970181673},
                {type = "item", name = "electric-mining-drill", amount = 0.671474044191},
                {type = "item", name = "barrel", amount = 1.46208398983},
                {type = "item", name = "engine-unit", amount = 0.562300001193},
            },
            results = {
                {type = "item", name = "speed-module", amount = 1},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["speed-module-2"] = {
            mode = "givens-multi-topology-balanced",
            repairs = {
                "reachability bootstrap: ingredients forced to already-reachable strictly earlier materials",
            },
            ingredients = {
                {type = "item", name = "nuclear-reactor", amount = 0.0242800577834},
                {type = "item", name = "storage-chest", amount = 2.74713051412},
                {type = "item", name = "processing-unit", amount = 2.74968640729},
                {type = "item", name = "speed-module", amount = 1.5493801852},
            },
            results = {
                {type = "item", name = "speed-module-2", amount = 1},
                {type = "item", name = "uranium-rounds-magazine", amount = 2.87567172943},
                {type = "item", name = "rocket-part", amount = 0.0258992988722},
            },
            topology = {
                output_rank = 6,
            },
        },
        ["speed-module-3"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "artillery-turret", amount = 1.37681246125},
                {type = "item", name = "express-underground-belt", amount = 5.42061925153},
                {type = "item", name = "express-splitter", amount = 5.03530737902},
                {type = "item", name = "laser-turret", amount = 1.66683613088},
                {type = "item", name = "speed-module-2", amount = 0.413187823462},
            },
            results = {
                {type = "item", name = "speed-module-3", amount = 1},
            },
            topology = {
                output_rank = 7,
            },
        },
        ["spidertron"] = {
            mode = "unchanged",
            reason = "unsupported/unpriced material in original LP",
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
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "heat-exchanger", amount = 0.0536012550244},
                {type = "item", name = "fluid-wagon", amount = 0.0222486513044},
                {type = "item", name = "grenade", amount = 0.570961351843},
                {type = "item", name = "concrete", amount = 7.43195284365},
                {type = "item", name = "transport-belt", amount = 0.529722237307},
                {type = "item", name = "electronic-circuit", amount = 0.663229220231},
            },
            results = {
                {type = "item", name = "splitter", amount = 1},
                {type = "item", name = "cluster-grenade", amount = 0.0277868274037},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["steam-engine"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "pipe-to-ground", amount = 0.811909689653},
                {type = "item", name = "steel-furnace", amount = 0.14345288482},
                {type = "item", name = "copper-cable", amount = 19.0545708327},
                {type = "item", name = "piercing-rounds-magazine", amount = 0.732687939813},
            },
            results = {
                {type = "item", name = "steam-engine", amount = 1},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["steam-turbine"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "fluid", name = "petroleum-gas", amount = 634.009001486},
                {type = "item", name = "stone-brick", amount = 29.9908066146},
                {type = "item", name = "firearm-magazine", amount = 3.17965538097},
                {type = "fluid", name = "heavy-oil", amount = 366.219919125},
                {type = "item", name = "iron-gear-wheel", amount = 9.28713116387},
                {type = "item", name = "electronic-circuit", amount = 11.5321526937},
            },
            results = {
                {type = "item", name = "steam-turbine", amount = 1},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["steel-chest"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "plastic-bar", amount = 26.509360059},
                {type = "item", name = "barrel", amount = 1.02845821318},
                {type = "item", name = "steel-plate", amount = 2.24367601182},
                {type = "fluid", name = "crude-oil", amount = 178.99194381},
            },
            results = {
                {type = "item", name = "steel-chest", amount = 1},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["steel-furnace"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "steam-turbine", amount = 0.0537891282601},
                {type = "item", name = "engine-unit", amount = 1.04045124216},
                {type = "fluid", name = "petroleum-gas", amount = 270.547718351},
                {type = "item", name = "copper-cable", amount = 19.5374403631},
            },
            results = {
                {type = "item", name = "steel-furnace", amount = 1},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["steel-plate"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "iron-chest", amount = 0.146291500008},
                {type = "fluid", name = "light-oil", amount = 13.1245429988},
                {type = "fluid", name = "heavy-oil", amount = 16.0029701494},
                {type = "fluid", name = "petroleum-gas", amount = 15.9352460697},
            },
            results = {
                {type = "item", name = "steel-plate", amount = 1},
            },
            topology = {
                output_rank = 2,
            },
        },
        ["stone-brick"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "iron-ore", amount = 0.671574678429},
                {type = "fluid", name = "petroleum-gas", amount = 2.32753562021},
                {type = "item", name = "stone", amount = 0.606450931591},
                {type = "fluid", name = "crude-oil", amount = 2.6331295894},
            },
            results = {
                {type = "item", name = "stone-brick", amount = 1},
            },
            topology = {
                output_rank = 1,
            },
        },
        ["stone-furnace"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "stone", amount = 2.65198094672},
                {type = "fluid", name = "crude-oil", amount = 23.4801905328},
            },
            results = {
                {type = "item", name = "stone-furnace", amount = 1},
            },
            topology = {
                output_rank = 1,
            },
        },
        ["stone-wall"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "plastic-bar", amount = 3.92802319232},
                {type = "item", name = "stone-brick", amount = 1.9697024553},
            },
            results = {
                {type = "item", name = "stone-wall", amount = 1},
            },
            topology = {
                output_rank = 2,
            },
        },
        ["storage-chest"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "belt-immunity-equipment", amount = 0.198211994376},
                {type = "item", name = "nuclear-reactor", amount = 0.00197897482367},
                {type = "item", name = "steel-chest", amount = 0.188243747906},
                {type = "item", name = "speed-module", amount = 0.149488333828},
                {type = "item", name = "processing-unit", amount = 0.0501197775553},
                {type = "item", name = "electronic-circuit", amount = 1.0883459764},
            },
            results = {
                {type = "item", name = "storage-chest", amount = 1},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["storage-tank"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "stone-wall", amount = 3.01054419251},
                {type = "item", name = "piercing-rounds-magazine", amount = 1.65056656126},
                {type = "item", name = "grenade", amount = 1.96805297418},
            },
            results = {
                {type = "item", name = "storage-tank", amount = 1},
                {type = "item", name = "engine-unit", amount = 0.411013567438},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["submachine-gun"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "pipe-to-ground", amount = 0.347263815829},
                {type = "fluid", name = "light-oil", amount = 236.361778318},
                {type = "item", name = "engine-unit", amount = 0.497568633867},
                {type = "item", name = "iron-gear-wheel", amount = 4.5108265224},
            },
            results = {
                {type = "item", name = "submachine-gun", amount = 1},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["substation"] = {
            mode = "givens-multi-topology-balanced",
            repairs = {
                "reachability bootstrap: ingredients forced to already-reachable strictly earlier materials",
            },
            ingredients = {
                {type = "item", name = "rail-signal", amount = 5.76451242356},
                {type = "item", name = "rocket", amount = 4.72312166826},
                {type = "item", name = "shotgun-shell", amount = 3.9009407149},
                {type = "item", name = "rail", amount = 2.72455608284},
                {type = "item", name = "advanced-circuit", amount = 3.06825836158},
            },
            results = {
                {type = "item", name = "substation", amount = 1},
                {type = "item", name = "centrifuge", amount = 0.00710849299437},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["sulfur"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "fluid", name = "light-oil", amount = 12.0936754932},
                {type = "item", name = "iron-gear-wheel", amount = 0.287280230652},
                {type = "item", name = "iron-ore", amount = 1.05713619601},
                {type = "fluid", name = "petroleum-gas", amount = 2.23069124594},
            },
            results = {
                {type = "item", name = "sulfur", amount = 2},
                {type = "item", name = "steel-plate", amount = 0.0357466063348},
            },
            topology = {
                output_rank = 2,
            },
        },
        ["sulfuric-acid"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "sulfur", amount = 2.21815442864},
                {type = "item", name = "steel-plate", amount = 0.241443574128},
                {type = "item", name = "iron-gear-wheel", amount = 0.409137100527},
                {type = "fluid", name = "water", amount = 394.80573885},
                {type = "item", name = "iron-stick", amount = 0.334532009107},
            },
            results = {
                {type = "fluid", name = "sulfuric-acid", amount = 50},
                {type = "item", name = "cargo-wagon", amount = 0.00446914090768},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["sulfuric-acid-barrel"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "display-panel", amount = 0.807023289374},
                {type = "item", name = "repair-pack", amount = 0.301080572847},
                {type = "item", name = "cannon-shell", amount = 0.206540394991},
                {type = "item", name = "solid-fuel", amount = 2.85918763367},
                {type = "fluid", name = "sulfuric-acid", amount = 10.2914133513},
            },
            results = {
                {type = "item", name = "sulfuric-acid-barrel", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["tank"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "productivity-module", amount = 3.14311407964},
                {type = "item", name = "fast-underground-belt", amount = 3.21440268806},
                {type = "fluid", name = "lubricant", amount = 1927.09691276},
                {type = "item", name = "cannon-shell", amount = 6.78354628609},
                {type = "item", name = "assembling-machine-1", amount = 2.69440493607},
            },
            results = {
                {type = "item", name = "tank", amount = 1},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["train-stop"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "fast-transport-belt", amount = 0.55262888065},
                {type = "item", name = "lubricant-barrel", amount = 0.748692569031},
                {type = "item", name = "electronic-circuit", amount = 4.00799774586},
                {type = "item", name = "solar-panel", amount = 0.0368685274795},
                {type = "item", name = "copper-cable", amount = 11.1159785858},
                {type = "item", name = "iron-plate", amount = 4.21020343907},
            },
            results = {
                {type = "item", name = "train-stop", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["transport-belt"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "firearm-magazine", amount = 0.201165027412},
                {type = "item", name = "steel-plate", amount = 0.250947739716},
                {type = "item", name = "steel-chest", amount = 0.0125708955111},
            },
            results = {
                {type = "item", name = "transport-belt", amount = 2},
            },
            topology = {
                output_rank = 3,
            },
        },
        ["underground-belt"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "rocket", amount = 3.47137887801},
                {type = "item", name = "cargo-wagon", amount = 0.0168549620998},
                {type = "item", name = "transport-belt", amount = 1.33908611436},
            },
            results = {
                {type = "item", name = "underground-belt", amount = 2},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["uranium-cannon-shell"] = {
            mode = "givens-multi-topology-balanced",
            repairs = {
                "reachability bootstrap: ingredients forced to already-reachable strictly earlier materials",
            },
            ingredients = {
                {type = "item", name = "chemical-science-pack", amount = 0.275012007769},
                {type = "item", name = "laser-turret", amount = 0.0243612798499},
                {type = "item", name = "cannon-shell", amount = 0.23292761402},
                {type = "item", name = "speed-module", amount = 0.0523384098816},
            },
            results = {
                {type = "item", name = "uranium-cannon-shell", amount = 1},
            },
            topology = {
                output_rank = 6,
            },
        },
        ["uranium-fuel-cell"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "beacon", amount = 0.11506667662},
                {type = "item", name = "construction-robot", amount = 0.48448491062},
                {type = "item", name = "utility-science-pack", amount = 0.241888981669},
                {type = "item", name = "chemical-science-pack", amount = 0.721852356976},
                {type = "item", name = "speed-module-2", amount = 0.0338947946732},
            },
            results = {
                {type = "item", name = "uranium-fuel-cell", amount = 10},
            },
            topology = {
                output_rank = 6,
            },
        },
        ["uranium-processing"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "uranium-ore", amount = 4.96184203273},
                {type = "item", name = "defender-capsule", amount = 0.0526654752533},
            },
            results = {
                {type = "item", name = "uranium-235", amount = 0.007},
                {type = "item", name = "uranium-238", amount = 0.993},
            },
            topology = {
                output_rank = 5,
            },
        },
        ["uranium-rounds-magazine"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "rocket-part", amount = 0.00521769880064},
                {type = "item", name = "uranium-fuel-cell", amount = 0.361359617046},
                {type = "item", name = "active-provider-chest", amount = 0.0332220700958},
            },
            results = {
                {type = "item", name = "uranium-rounds-magazine", amount = 1},
            },
            topology = {
                output_rank = 6,
            },
        },
        ["utility-science-pack"] = {
            mode = "givens-multi-topology-balanced",
            repairs = {
                "reachability bootstrap: ingredients forced to already-reachable strictly earlier materials",
            },
            ingredients = {
                {type = "item", name = "beacon", amount = 0.214004628677},
                {type = "item", name = "cannon-shell", amount = 6.16356533188},
                {type = "item", name = "speed-module", amount = 1.38494188432},
                {type = "item", name = "assembling-machine-2", amount = 0.826115427832},
            },
            results = {
                {type = "item", name = "utility-science-pack", amount = 3},
            },
            topology = {
                output_rank = 6,
            },
        },
        ["water-barrel"] = {
            mode = "givens-multi-topology-balanced",
            ingredients = {
                {type = "item", name = "explosives", amount = 2.6885493446},
                {type = "fluid", name = "sulfuric-acid", amount = 10.238023172},
                {type = "item", name = "barrel", amount = 0.176479325604},
                {type = "item", name = "iron-gear-wheel", amount = 0.637895861528},
            },
            results = {
                {type = "item", name = "water-barrel", amount = 1},
            },
            topology = {
                output_rank = 4,
            },
        },
        ["wooden-chest"] = {
            mode = "unchanged",
            reason = "unsupported/unpriced material in original LP",
            ingredients = {
                {type = "item", name = "wood", amount = 2},
            },
            results = {
                {type = "item", name = "wooden-chest", amount = 1},
            },
        },
    },
}

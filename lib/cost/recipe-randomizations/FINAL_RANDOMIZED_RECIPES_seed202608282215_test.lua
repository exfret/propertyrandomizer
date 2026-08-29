-- 15/40/65 degree-4 semantic-slot follow-up with final integerization
-- energy_required_multiplier includes the prior rotation result scaling and the final rounded net-result batch scale.
return {
  metadata = {
    format = "semantic-slots-v22-followup-degree4-angles-15-40-65-integerized-v1",
    low_flow_threshold = 0.2,
    multiplier_min = 0.1,
    multiplier_max = 10,
  },
  recipes = {
    ["copper-plate"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="kerogen", amount=8},
      },
      results = {
        {type="item", name="copper-plate", amount=1},
      },
    },
    ["iron-plate"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-ore", amount=8},
      },
      results = {
        {type="item", name="iron-plate", amount=1},
      },
    },
    ["copper-cable"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="copper-ore", amount=8},
        {type="item", name="copper-plate", amount=1},
      },
      results = {
        {type="item", name="copper-cable", amount=3},
      },
    },
    ["iron-stick"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="iron-plate", amount=1},
        {type="item", name="kerogen", amount=11},
      },
      results = {
        {type="item", name="iron-stick", amount=4},
      },
    },
    ["iron-gear-wheel"] = {
      mode = "kept-pruned-transformed",
      science_level = 0,
      energy_required_multiplier = 0.0425820617310194,
      ingredients = {
        {type="item", name="copper-ore", amount=1},
      },
      results = {
        {type="item", name="iron-gear-wheel", amount=0.0425820617310194},
      },
    },
    ["bolts"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="iron-gear-wheel", amount=1},
      },
      results = {
        {type="item", name="bolts", amount=4},
      },
    },
    ["small-parts-01"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bolts", amount=3},
        {type="item", name="copper-cable", amount=2},
        {type="item", name="iron-gear-wheel", amount=3},
        {type="item", name="iron-stick", amount=4},
      },
      results = {
        {type="item", name="small-parts-01", amount=4},
      },
    },
    ["burner-inserter"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="copper-plate", amount=3},
        {type="item", name="iron-plate", amount=3},
        {type="item", name="small-parts-01", amount=5},
      },
      results = {
        {type="item", name="burner-inserter", amount=2},
      },
    },
    ["inductor1-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=9},
      },
      results = {
        {type="item", name="inductor1", amount=1},
      },
    },
    ["soil"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 0.9375,
      ingredients = {
        {type="fluid", name="steam", amount=70},
      },
      results = {
        {type="item", name="soil", amount=15},
      },
    },
    ["stone-brick"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 0.476489906869532,
      ingredients = {
        {type="item", name="kerogen", amount=1},
      },
      results = {
        {type="item", name="stone-brick", amount=0.476489906869532},
      },
    },
    ["stone-furnace"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="kerogen", amount=5},
      },
      results = {
        {type="item", name="stone-furnace", amount=1},
      },
    },
    ["transport-belt"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-plate", amount=1},
        {type="item", name="small-parts-01", amount=1},
      },
      results = {
        {type="item", name="transport-belt", amount=2},
      },
    },
    ["underground-belt"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="copper-plate", amount=6},
        {type="item", name="inductor1", amount=4},
        {type="item", name="iron-plate", amount=10},
        {type="item", name="pipe", amount=5},
      },
      results = {
        {type="item", name="underground-belt", amount=3},
      },
    },
    ["lab"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="inductor1", amount=8},
        {type="item", name="iron-stick", amount=21},
        {type="item", name="small-parts-01", amount=12},
        {type="item", name="stone-furnace", amount=4},
        {type="item", name="underground-belt", amount=1},
      },
      results = {
        {type="item", name="lab", amount=3},
      },
    },
    ["pipe"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="iron-stick", amount=4},
      },
      results = {
        {type="item", name="pipe", amount=2},
      },
    },
    ["pipe-to-ground"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=4},
        {type="item", name="pipe", amount=10},
      },
      results = {
        {type="item", name="pipe-to-ground", amount=2},
      },
    },
    ["small-electric-pole"] = {
      mode = "input-preserved-untransformed",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-stick", amount=2},
        {type="item", name="log", amount=1},
      },
      results = {
        {type="item", name="small-electric-pole", amount=1},
      },
    },
    ["boiler"] = {
      mode = "kept-pruned-transformed",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=7},
        {type="item", name="stone-furnace", amount=1},
      },
      results = {
        {type="item", name="boiler", amount=1},
      },
    },
    ["steam-engine"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boiler", amount=4},
        {type="item", name="bolts", amount=8},
        {type="item", name="small-parts-01", amount=6},
      },
      results = {
        {type="item", name="steam-engine", amount=1},
      },
    },
    ["burner-mining-drill"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-stick", amount=5},
        {type="item", name="small-parts-01", amount=3},
        {type="item", name="stone-furnace", amount=1},
      },
      results = {
        {type="item", name="burner-mining-drill", amount=1},
      },
    },
    ["offshore-pump"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bolts", amount=21},
        {type="item", name="small-parts-01", amount=1},
        {type="item", name="stone-furnace", amount=2},
      },
      results = {
        {type="item", name="offshore-pump", amount=2},
      },
    },
    ["soil-extractor-mk01"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="boiler", amount=2},
        {type="item", name="bolts", amount=36},
        {type="item", name="burner-inserter", amount=3},
        {type="item", name="inductor1", amount=12},
        {type="item", name="offshore-pump", amount=3},
        {type="item", name="small-parts-01", amount=31},
        {type="item", name="transport-belt", amount=19},
      },
      results = {
        {type="item", name="soil-extractor-mk01", amount=2},
      },
    },
    ["wpu-mk01"] = {
      mode = "input-preserved-untransformed",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="lab", amount=1},
        {type="item", name="log", amount=5},
        {type="item", name="offshore-pump", amount=3},
        {type="item", name="pipe", amount=36},
        {type="item", name="stone", amount=319},
        {type="item", name="underground-belt", amount=1},
      },
      results = {
        {type="item", name="wpu-mk01", amount=1},
      },
    },
    ["flora-collector-mk01"] = {
      mode = "input-preserved-untransformed",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boiler", amount=4},
        {type="item", name="burner-inserter", amount=2},
        {type="item", name="lab", amount=1},
        {type="item", name="offshore-pump", amount=17},
        {type="item", name="stone-furnace", amount=77},
        {type="item", name="transport-belt", amount=15},
      },
      results = {
        {type="item", name="flora-collector-mk01", amount=1},
      },
    },
    ["automation-science-pack"] = {
      mode = "input-preserved-untransformed",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="kerogen", amount=10},
        {type="item", name="planter-box", amount=2},
        {type="item", name="small-parts-01", amount=2},
      },
      results = {
        {type="item", name="automation-science-pack", amount=1},
      },
    },
    ["empty-planter-box"] = {
      mode = "input-preserved-untransformed",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-stick", amount=2},
        {type="item", name="stone-brick", amount=4},
        {type="item", name="wood", amount=2},
      },
      results = {
        {type="item", name="empty-planter-box", amount=1},
      },
    },
    ["planter-box"] = {
      mode = "input-preserved-untransformed",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="empty-planter-box", amount=1},
        {type="item", name="native-flora", amount=13},
        {type="item", name="soil", amount=5},
      },
      results = {
        {type="item", name="planter-box", amount=1},
      },
    },
    ["log-wood"] = {
      mode = "input-preserved-untransformed",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="log", amount=4},
      },
      results = {
        {type="item", name="wood", amount=20},
      },
    },
    ["wooden-chest"] = {
      mode = "input-preserved-untransformed",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="wood", amount=2},
      },
      results = {
        {type="item", name="wooden-chest", amount=1},
      },
    },
    ["assembling-machine-1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=12},
        {type="item", name="inductor1", amount=4},
        {type="item", name="pipe", amount=8},
      },
      results = {
        {type="item", name="assembling-machine-1", amount=1},
      },
    },
    ["bricks-to-stone"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.125,
      ingredients = {
        {type="item", name="stone-furnace", amount=3},
      },
      results = {
        {type="item", name="stone", amount=9},
      },
    },
    ["grade-2-copper"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-ore", amount=5},
      },
      results = {
        {type="item", name="grade-1-copper", amount=1},
        {type="item", name="grade-2-copper", amount=2},
      },
    },
    ["copper-plate-4"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="copper-ore", amount=10},
        {type="item", name="grade-1-copper", amount=2},
      },
      results = {
        {type="item", name="copper-plate", amount=3},
      },
    },
    ["grade-1-copper-crush"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-ore", amount=13},
      },
      results = {
        {type="item", name="grade-2-copper", amount=1},
        {type="item", name="stone", amount=2},
      },
    },
    ["fiber-01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="seaweed", amount=14},
        {type="item", name="wood", amount=7},
      },
      results = {
        {type="item", name="raw-fiber", amount=3},
      },
    },
    ["glass-1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="pressured-water", amount=228},
        {type="item", name="ore-nickel", amount=3},
      },
      results = {
        {type="fluid", name="molten-glass", amount=15},
      },
    },
    ["molten-glass"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=228},
      },
      results = {
        {type="item", name="glass", amount=5},
      },
    },
    ["grade-1-iron-crush"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-ore", amount=5},
      },
      results = {
        {type="item", name="processed-iron-ore", amount=3},
        {type="item", name="stone", amount=1},
      },
    },
    ["low-grade-smelting-iron"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-ore", amount=6},
      },
      results = {
        {type="item", name="iron-plate", amount=1},
      },
    },
    ["gravel-to-sand"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.666666666666667,
      ingredients = {
        {type="item", name="stone", amount=5},
      },
      results = {
        {type="item", name="sand", amount=2},
      },
    },
    ["stone-to-gravel"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="item", name="iron-ore", amount=4},
        {type="item", name="stone", amount=2},
      },
      results = {
        {type="item", name="gravel", amount=5},
      },
    },
    ["gun-turret"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=2},
        {type="item", name="bolts", amount=108},
        {type="item", name="pipe", amount=36},
      },
      results = {
        {type="item", name="gun-turret", amount=3},
      },
    },
    ["muddy-sludge"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.87,
      ingredients = {
        {type="fluid", name="water", amount=112},
        {type="item", name="iron-ore", amount=4},
        {type="item", name="limestone", amount=3},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=87},
      },
    },
    ["soil-washing"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.81367680484901,
      ingredients = {
        {type="fluid", name="water", amount=254},
        {type="item", name="pipe", amount=3},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=84},
        {type="item", name="sand", amount=8},
      },
    },
    ["pressured-water"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.606,
      ingredients = {
        {type="fluid", name="water", amount=803},
      },
      results = {
        {type="fluid", name="pressured-water", amount=803},
      },
    },
    ["repair-pack"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="empty-planter-box", amount=3},
        {type="item", name="pipe", amount=11},
      },
      results = {
        {type="item", name="repair-pack", amount=2},
      },
    },
    ["seaweed-1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.6,
      ingredients = {
        {type="fluid", name="water", amount=113},
      },
      results = {
        {type="item", name="seaweed", amount=6},
      },
    },
    ["shotgun"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="copper-ore", amount=603},
        {type="item", name="iron-chest", amount=4},
        {type="item", name="log", amount=3},
        {type="item", name="offshore-pump", amount=3},
      },
      results = {
        {type="item", name="shotgun", amount=3},
      },
    },
    ["submachine-gun"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="burner-inserter", amount=2},
        {type="item", name="copper-plate", amount=25},
        {type="item", name="inductor1", amount=8},
        {type="item", name="log", amount=6},
        {type="item", name="pipe", amount=44},
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="submachine-gun", amount=4},
      },
    },
    ["small-lamp"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="fluid", name="water", amount=1551},
        {type="item", name="copper-cable", amount=3},
        {type="item", name="glass", amount=4},
        {type="item", name="iron-stick", amount=4},
        {type="item", name="pipe", amount=2},
        {type="item", name="saps", amount=3},
      },
      results = {
        {type="item", name="small-lamp", amount=3},
      },
    },
    ["tailings-pond"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=15},
        {type="item", name="stone", amount=444},
      },
      results = {
        {type="item", name="tailings-pond", amount=1},
      },
    },
    ["tin-plate-1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="ore-tin", amount=64},
      },
      results = {
        {type="item", name="tin-plate", amount=6},
      },
    },
    ["acetylene"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.430224748948416,
      ingredients = {
        {type="fluid", name="pressured-water", amount=106},
        {type="item", name="coke", amount=5},
      },
      results = {
        {type="fluid", name="acetylene", amount=42},
        {type="fluid", name="slacked-lime", amount=11},
      },
    },
    ["coal-gas"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.472701221921767,
      ingredients = {
        {type="item", name="limestone", amount=1},
        {type="item", name="wood", amount=4},
      },
      results = {
        {type="fluid", name="coal-gas", amount=18},
        {type="fluid", name="tar", amount=23},
        {type="item", name="coke", amount=3},
        {type="item", name="iron-oxide", amount=0.137570751768751},
      },
    },
    ["coal-gas-from-wood"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2.91016268073662,
      ingredients = {
        {type="item", name="limestone", amount=53},
      },
      results = {
        {type="fluid", name="coal-gas", amount=28},
        {type="fluid", name="tar", amount=83},
        {type="item", name="coal", amount=28},
        {type="item", name="iron-oxide", amount=1},
      },
    },
    ["syngas"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.863027200327536,
      ingredients = {
        {type="fluid", name="pressured-water", amount=259},
        {type="fluid", name="water", amount=140},
        {type="item", name="iron-ore", amount=1},
      },
      results = {
        {type="fluid", name="syngas", amount=58},
        {type="fluid", name="tar", amount=25},
        {type="item", name="ash", amount=1},
      },
    },
    ["coal-gas-from-coke"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.84293108966751,
      ingredients = {
        {type="item", name="limestone", amount=53},
      },
      results = {
        {type="fluid", name="coal-gas", amount=35},
        {type="fluid", name="tar", amount=35},
        {type="item", name="ash", amount=2},
      },
    },
    ["distilled-raw-coal"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.380356020786962,
      ingredients = {
        {type="item", name="seaweed", amount=2},
      },
      results = {
        {type="fluid", name="coal-gas", amount=24},
        {type="fluid", name="tar", amount=12},
        {type="item", name="coal", amount=1},
        {type="item", name="iron-oxide", amount=0.0808207734220721},
      },
    },
    ["aluminium-plate-1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ore-aluminium", amount=2},
        {type="item", name="ore-lead", amount=4},
      },
      results = {
        {type="item", name="aluminium-plate", amount=1},
      },
    },
    ["graphite"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.190957310629481,
      ingredients = {
        {type="item", name="coke", amount=1},
      },
      results = {
        {type="item", name="graphite", amount=0.381914621258962},
      },
    },
    ["clay"] = {
      mode = "repaired-to-input",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=1100},
      },
      results = {
        {type="item", name="clay", amount=3},
      },
    },
    ["ceramic"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="item", name="limestone", amount=1},
        {type="item", name="sand", amount=11},
        {type="item", name="soot", amount=1},
      },
      results = {
        {type="item", name="ceramic", amount=6},
      },
    },
    ["duralumin-1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="calcium-carbide", amount=13},
        {type="item", name="glass", amount=7},
        {type="item", name="limestone", amount=75},
        {type="item", name="poorman-wood-fence", amount=2},
      },
      results = {
        {type="item", name="duralumin", amount=2},
      },
    },
    ["tinned-cable"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=2},
        {type="item", name="tin-plate", amount=1},
      },
      results = {
        {type="item", name="tinned-cable", amount=1},
      },
    },
    ["engine-unit"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="boiler", amount=2},
        {type="item", name="bolts", amount=4},
        {type="item", name="burner-inserter", amount=4},
        {type="item", name="cellulose", amount=4},
        {type="item", name="copper-cable", amount=25},
        {type="item", name="iron-plate", amount=17},
        {type="item", name="iron-stick", amount=19},
        {type="item", name="offshore-pump", amount=3},
        {type="item", name="steam-engine", amount=3},
      },
      results = {
        {type="item", name="engine-unit", amount=2},
      },
    },
    ["iron-oxide-smelting"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="planter-box", amount=12},
      },
      results = {
        {type="item", name="iron-plate", amount=8},
      },
    },
    ["lead-plate-1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ore-aluminium", amount=11},
      },
      results = {
        {type="item", name="lead-plate", amount=1},
      },
    },
    ["moondrop-codex"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="capacitor1", amount=45},
        {type="item", name="tin-plate", amount=25},
      },
      results = {
        {type="item", name="moondrop-codex", amount=1},
      },
    },
    ["solder-0"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="iron-plate", amount=5},
        {type="item", name="tin-plate", amount=4},
        {type="item", name="zinc-plate", amount=6},
      },
      results = {
        {type="item", name="solder", amount=2},
      },
    },
    ["tar-quenching"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.10228339797645,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=188},
        {type="fluid", name="syngas", amount=548},
      },
      results = {
        {type="fluid", name="flue-gas", amount=172},
        {type="fluid", name="tailings", amount=574},
        {type="fluid", name="water-saline", amount=287},
        {type="item", name="soot", amount=2},
      },
    },
    ["chlorine"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.976984834968778,
      ingredients = {
        {type="fluid", name="water-saline", amount=97},
      },
      results = {
        {type="fluid", name="chlorine", amount=19},
        {type="fluid", name="hydrogen", amount=19},
        {type="item", name="sodium-hydroxide", amount=2},
      },
    },
    ["hydrogen"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.99,
      ingredients = {
        {type="fluid", name="pressured-water", amount=185},
        {type="item", name="copper-ore", amount=1},
      },
      results = {
        {type="fluid", name="hydrogen", amount=198},
        {type="fluid", name="oxygen", amount=99},
      },
    },
    ["muddy-sludge-void-electrolyzer"] = {
      mode = "input-preserved-untransformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=313},
      },
      results = {
        {type="fluid", name="oxygen", amount=10},
        {type="fluid", name="water", amount=100},
        {type="item", name="soil", amount=5},
      },
    },
    ["tailings-dust"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.707007691027958,
      ingredients = {
        {type="fluid", name="tailings", amount=42},
        {type="fluid", name="water-saline", amount=14},
      },
      results = {
        {type="fluid", name="acidgas", amount=10},
        {type="item", name="tailings-dust", amount=3},
      },
    },
    ["ash-separation"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 0.0969058399486468,
      ingredients = {
        {type="item", name="ash", amount=1},
      },
      results = {
        {type="item", name="coal-dust", amount=0.0484529199743234},
        {type="item", name="iron-oxide", amount=0.00484529199743234},
        {type="item", name="soot", amount=0.0193811679897294},
      },
    },
    ["soot-separation"] = {
      mode = "repaired-to-input",
      science_level = 1,
      energy_required_multiplier = 9.65640888256403,
      ingredients = {
        {type="item", name="soot", amount=18},
      },
      results = {
        {type="item", name="ash", amount=3},
        {type="item", name="copper-ore", amount=2},
        {type="item", name="iron-ore", amount=2},
        {type="item", name="ore-aluminium", amount=0.911964148331833},
        {type="item", name="ore-lead", amount=0.911964148331833},
        {type="item", name="ore-zinc", amount=0.911964148331833},
      },
    },
    ["tailings-classification"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1.18770726110282,
      ingredients = {
        {type="item", name="iron-plate", amount=1},
        {type="item", name="limestone", amount=48},
      },
      results = {
        {type="item", name="coal-dust", amount=6},
        {type="item", name="ore-tin", amount=1},
        {type="item", name="ore-titanium", amount=1},
      },
    },
    ["extract-sulfur"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="fluid", name="water", amount=4000},
      },
      results = {
        {type="item", name="sulfur", amount=1},
      },
    },
    ["titanium-plate-1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="ore-tin", amount=19},
      },
      results = {
        {type="item", name="titanium-plate", amount=2},
      },
    },
    ["water-from-oxygen-and-hydrogen"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.02,
      ingredients = {
        {type="fluid", name="oxygen", amount=48},
        {type="fluid", name="pressured-water", amount=406},
        {type="item", name="copper-ore", amount=1},
        {type="item", name="stone-furnace", amount=1},
      },
      results = {
        {type="fluid", name="water", amount=306},
      },
    },
    ["zinc-plate-1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ore-aluminium", amount=45},
      },
      results = {
        {type="item", name="zinc-plate", amount=4},
      },
    },
    ["py-tank-1000"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="acetylene-barrel", amount=7},
        {type="item", name="methane-barrel", amount=2},
        {type="item", name="soot", amount=11},
      },
      results = {
        {type="item", name="py-tank-1000", amount=1},
      },
    },
    ["py-tank-3000"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=66},
        {type="item", name="iron-stick", amount=50},
        {type="item", name="stone-wall", amount=3},
        {type="item", name="titanium-plate", amount=6},
      },
      results = {
        {type="item", name="py-tank-3000", amount=1},
      },
    },
    ["py-tank-4000"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bolts", amount=36},
        {type="item", name="iron-gear-wheel", amount=3},
        {type="item", name="lead-plate", amount=37},
        {type="item", name="solder", amount=3},
        {type="item", name="tin-plate", amount=6},
        {type="item", name="transport-belt", amount=4},
      },
      results = {
        {type="item", name="py-tank-4000", amount=2},
      },
    },
    ["py-tank-8000"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="clay-pit-mk01", amount=1},
        {type="item", name="coke", amount=77},
        {type="item", name="glass", amount=147},
        {type="item", name="pipe", amount=15},
        {type="item", name="planter-box", amount=49},
      },
      results = {
        {type="item", name="py-tank-8000", amount=2},
      },
    },
    ["py-tank-10000"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=23},
        {type="item", name="ceramic", amount=12},
        {type="item", name="log", amount=178},
        {type="item", name="py-tank-6500", amount=1},
        {type="item", name="water-barrel", amount=129},
      },
      results = {
        {type="item", name="py-tank-10000", amount=2},
      },
    },
    ["py-tank-1500"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.0684279104239972,
      ingredients = {
        {type="item", name="iron-stick", amount=20},
        {type="item", name="small-parts-01", amount=3},
        {type="item", name="titanium-plate", amount=1},
      },
      results = {
        {type="item", name="py-tank-1500", amount=0.0684279104239972},
      },
    },
    ["py-tank-6500"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 5,
      ingredients = {
        {type="item", name="iron-gear-wheel", amount=9},
        {type="item", name="py-tank-3000", amount=2},
        {type="item", name="py-tank-4000", amount=3},
        {type="item", name="sodium-hydroxide", amount=16},
        {type="item", name="titanium-plate", amount=125},
      },
      results = {
        {type="item", name="py-tank-6500", amount=5},
      },
    },
    ["py-tank-7000"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="log", amount=136},
        {type="item", name="pipe", amount=18},
        {type="item", name="pressured-air-barrel", amount=130},
        {type="item", name="pump", amount=3},
        {type="item", name="py-tank-6500", amount=2},
        {type="item", name="small-parts-01", amount=12},
      },
      results = {
        {type="item", name="py-tank-7000", amount=3},
      },
    },
    ["py-tank-5000"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="bolts", amount=44},
        {type="item", name="pipe", amount=15},
        {type="item", name="py-tank-3000", amount=4},
        {type="item", name="sodium-hydroxide", amount=32},
        {type="item", name="titanium-plate", amount=79},
      },
      results = {
        {type="item", name="py-tank-5000", amount=3},
      },
    },
    ["py-tank-9000"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 5,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=5},
        {type="item", name="copper-plate", amount=133},
        {type="item", name="lime", amount=1000},
        {type="item", name="py-tank-7000", amount=2},
        {type="item", name="py-tank-8000", amount=4},
      },
      results = {
        {type="item", name="py-tank-9000", amount=5},
      },
    },
    ["chloride-void-iron-oxide"] = {
      mode = "input-preserved-untransformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water-saline", amount=260},
        {type="item", name="iron-plate", amount=1},
      },
      results = {
        {type="item", name="iron-oxide", amount=1},
      },
    },
    ["extract-limestone-01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.625,
      ingredients = {
        {type="fluid", name="water", amount=288},
        {type="item", name="seaweed", amount=3},
      },
      results = {
        {type="item", name="limestone", amount=13},
      },
    },
    ["gun-powder"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="hydrogen", amount=769},
        {type="item", name="coal", amount=3},
        {type="item", name="coal-dust", amount=2},
        {type="item", name="ore-aluminium", amount=1},
        {type="item", name="sodium-hydroxide", amount=1},
        {type="item", name="stone-furnace", amount=1},
      },
      results = {
        {type="item", name="gunpowder", amount=4},
      },
    },
    ["tar-distilation"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.978948142586831,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=455},
      },
      results = {
        {type="fluid", name="aromatics", amount=97},
        {type="fluid", name="carbon-dioxide", amount=97},
        {type="fluid", name="flue-gas", amount=483},
        {type="item", name="rich-clay", amount=1},
      },
    },
    ["treated-wood"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="fluid", name="flue-gas", amount=182},
        {type="item", name="limestone", amount=2},
      },
      results = {
        {type="item", name="treated-wood", amount=1},
      },
    },
    ["calcium-carbide"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 3.8,
      ingredients = {
        {type="item", name="coke", amount=23},
        {type="item", name="limestone", amount=25},
        {type="item", name="log", amount=1},
      },
      results = {
        {type="item", name="calcium-carbide", amount=38},
      },
    },
    ["sand-brick"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="item", name="rich-clay", amount=27},
        {type="item", name="sand", amount=29},
      },
      results = {
        {type="item", name="stone-brick", amount=15},
      },
    },
    ["tar-to-carbolic"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 3.05207676752155,
      ingredients = {
        {type="fluid", name="steam", amount=294},
        {type="fluid", name="tar", amount=114},
        {type="fluid", name="water", amount=2164},
      },
      results = {
        {type="fluid", name="carbolic-oil", amount=29},
        {type="fluid", name="coal-gas", amount=101},
        {type="item", name="ash", amount=3},
        {type="item", name="rich-clay", amount=1},
      },
    },
    ["Moss-2"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.9375,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=48},
        {type="fluid", name="hydrogen", amount=150},
        {type="fluid", name="water", amount=192},
        {type="item", name="stone", amount=18},
        {type="item", name="wood", amount=1},
        {type="item", name="wooden-chest", amount=1},
      },
      results = {
        {type="item", name="moss", amount=15},
      },
    },
    ["Moss-1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=45},
        {type="fluid", name="hydrogen", amount=136},
        {type="item", name="iron-ore", amount=1},
      },
      results = {
        {type="item", name="moss", amount=4},
      },
    },
    ["aromatics-to-plastic"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="aromatics", amount=18},
        {type="fluid", name="water", amount=671},
        {type="item", name="coke", amount=4},
        {type="item", name="iron-ore", amount=16},
      },
      results = {
        {type="item", name="plastic-bar", amount=1},
      },
    },
    ["log1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="tar", amount=17},
        {type="item", name="seaweed", amount=3},
        {type="item", name="wood-seedling", amount=3},
      },
      results = {
        {type="item", name="log", amount=4},
      },
    },
    ["wood-seeds"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="limestone", amount=9},
      },
      results = {
        {type="item", name="wood-seeds", amount=4},
      },
    },
    ["wood-seedling"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="fluid", name="water", amount=140},
        {type="item", name="moss", amount=9},
        {type="item", name="wood-seeds", amount=1},
      },
      results = {
        {type="item", name="wood-seedling", amount=5},
      },
    },
    ["log2"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.75,
      ingredients = {
        {type="fluid", name="hydrogen", amount=229},
        {type="fluid", name="water", amount=132},
        {type="item", name="moss", amount=3},
        {type="item", name="wood-seedling", amount=4},
        {type="item", name="wood-seeds", amount=2},
      },
      results = {
        {type="item", name="log", amount=7},
      },
    },
    ["log3"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.16666666666667,
      ingredients = {
        {type="fluid", name="hydrogen", amount=185},
        {type="item", name="ash", amount=39},
        {type="item", name="gravel", amount=16},
      },
      results = {
        {type="item", name="log", amount=7},
      },
    },
    ["steel-plate"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="coke", amount=7},
        {type="item", name="iron-ore", amount=27},
        {type="item", name="seaweed", amount=13},
        {type="item", name="wood", amount=2},
      },
      results = {
        {type="item", name="steel-plate", amount=2},
      },
    },
    ["bio-container"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="calcium-carbide", amount=2},
        {type="item", name="glass", amount=3},
        {type="item", name="iron-plate", amount=7},
        {type="item", name="tin-plate", amount=2},
      },
      results = {
        {type="item", name="bio-container", amount=1},
      },
    },
    ["cage"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-gear-wheel", amount=5},
        {type="item", name="solder", amount=2},
        {type="item", name="tin-plate", amount=4},
      },
      results = {
        {type="item", name="cage", amount=1},
      },
    },
    ["empty-jerry-can"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="iron-plate", amount=10},
        {type="item", name="pipe", amount=5},
        {type="item", name="plastic-bar", amount=4},
        {type="item", name="transport-belt", amount=3},
      },
      results = {
        {type="item", name="empty-fuel-canister", amount=3},
      },
    },
    ["shotgun-shell"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="item", name="calcium-carbide", amount=17},
        {type="item", name="glass", amount=4},
        {type="item", name="poorman-wood-fence", amount=1},
      },
      results = {
        {type="item", name="shotgun-shell", amount=4},
      },
    },
    ["firearm-magazine"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.6,
      ingredients = {
        {type="item", name="ash", amount=14},
        {type="item", name="cellulose", amount=1},
        {type="item", name="gravel", amount=37},
      },
      results = {
        {type="item", name="firearm-magazine", amount=3},
      },
    },
    ["fwf-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="agar", amount=12},
        {type="item", name="assembling-machine-1", amount=1},
        {type="item", name="automation-science-pack", amount=16},
        {type="item", name="sand", amount=128},
        {type="item", name="tin-plate", amount=66},
        {type="item", name="transport-belt", amount=22},
      },
      results = {
        {type="item", name="fwf-mk01", amount=2},
      },
    },
    ["moss-farm-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=3},
        {type="item", name="boiler", amount=5},
        {type="item", name="bolts", amount=52},
        {type="item", name="coke", amount=20},
        {type="item", name="copper-cable", amount=76},
        {type="item", name="iron-chest", amount=2},
        {type="item", name="iron-gear-wheel", amount=18},
        {type="item", name="pipe", amount=86},
        {type="item", name="poorman-wood-fence", amount=18},
        {type="item", name="titanium-plate", amount=9},
        {type="item", name="wood", amount=40},
      },
      results = {
        {type="item", name="moss-farm-mk01", amount=2},
      },
    },
    ["sap-extractor-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="boiler", amount=12},
        {type="item", name="bolts", amount=10},
        {type="item", name="burner-mining-drill", amount=1},
        {type="item", name="copper-plate", amount=10},
        {type="item", name="iron-gear-wheel", amount=9},
        {type="item", name="iron-stick", amount=39},
        {type="item", name="small-parts-01", amount=12},
        {type="item", name="stone", amount=908},
        {type="item", name="wood", amount=46},
      },
      results = {
        {type="item", name="sap-extractor-mk01", amount=2},
      },
    },
    ["seaweed-crop-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="agar", amount=10},
        {type="item", name="glass", amount=19},
        {type="item", name="inductor1", amount=19},
        {type="item", name="lime", amount=14},
        {type="item", name="offshore-pump", amount=3},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="soot", amount=13},
        {type="item", name="treated-wood", amount=104},
      },
      results = {
        {type="item", name="seaweed-crop-mk01", amount=2},
      },
    },
    ["moondrop-greenhouse-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boiler", amount=3},
        {type="item", name="copper-cable", amount=32},
        {type="item", name="landfill", amount=2},
        {type="item", name="limestone", amount=54},
        {type="item", name="soil", amount=574},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="steel-plate", amount=6},
        {type="item", name="titanium-plate", amount=28},
        {type="item", name="transport-belt", amount=15},
      },
      results = {
        {type="item", name="moondrop-greenhouse-mk01", amount=1},
      },
    },
    ["iron-chest"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="pipe", amount=7},
      },
      results = {
        {type="item", name="iron-chest", amount=1},
      },
    },
    ["storage-tank"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=94},
        {type="item", name="lead-plate", amount=7},
        {type="item", name="small-parts-01", amount=19},
      },
      results = {
        {type="item", name="storage-tank", amount=1},
      },
    },
    ["light-armor"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="burner-inserter", amount=3},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="stone-wall", amount=2},
      },
      results = {
        {type="item", name="light-armor", amount=1},
      },
    },
    ["car"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=1},
        {type="item", name="py-sinkhole", amount=3},
        {type="item", name="steam-engine", amount=16},
        {type="item", name="steel-chest", amount=2},
      },
      results = {
        {type="item", name="car", amount=1},
      },
    },
    ["pump"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="iron-plate", amount=13},
        {type="item", name="steam-engine", amount=7},
      },
      results = {
        {type="item", name="pump", amount=2},
      },
    },
    ["small-electric-pole-2"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="item", name="iron-stick", amount=6},
        {type="item", name="tin-plate", amount=5},
      },
      results = {
        {type="item", name="small-electric-pole", amount=5},
      },
    },
    ["py-gas-vent"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="water", amount=4000},
        {type="item", name="bolts", amount=29},
        {type="item", name="small-parts-01", amount=6},
      },
      results = {
        {type="item", name="py-gas-vent", amount=2},
      },
    },
    ["py-sinkhole"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=2},
        {type="item", name="iron-chest", amount=6},
        {type="item", name="iron-gear-wheel", amount=20},
        {type="item", name="planter-box", amount=4},
        {type="item", name="sap-extractor-mk01", amount=1},
        {type="item", name="small-parts-01", amount=27},
      },
      results = {
        {type="item", name="py-sinkhole", amount=2},
      },
    },
    ["retorter"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=1},
        {type="item", name="copper-plate", amount=90},
        {type="item", name="iron-stick", amount=17},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="stone-brick", amount=25},
        {type="item", name="underground-belt", amount=9},
      },
      results = {
        {type="item", name="retorter", amount=1},
      },
    },
    ["steel-chest"] = {
      mode = "repaired-to-input",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="small-parts-01", amount=14},
      },
      results = {
        {type="item", name="steel-chest", amount=1},
      },
    },
    ["tree"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="coke", amount=3},
        {type="item", name="empty-planter-box", amount=2},
        {type="item", name="glass", amount=5},
        {type="item", name="native-flora", amount=9},
        {type="item", name="seaweed", amount=27},
        {type="item", name="wood-seeds", amount=12},
      },
      results = {
        {type="item", name="tree-mk01", amount=3},
      },
    },
    ["advanced-foundry-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ash", amount=19},
        {type="item", name="copper-ore", amount=60},
        {type="item", name="iron-chest", amount=1},
        {type="item", name="limestone", amount=48},
        {type="item", name="log", amount=1},
        {type="item", name="offshore-pump", amount=2},
        {type="item", name="pipe", amount=17},
        {type="item", name="saps", amount=6},
        {type="item", name="stone-brick", amount=11},
      },
      results = {
        {type="item", name="advanced-foundry-mk01", amount=1},
      },
    },
    ["borax-mine"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="aluminium-plate", amount=34},
        {type="item", name="hpf", amount=2},
        {type="item", name="inductor1", amount=20},
        {type="item", name="jaw-crusher", amount=2},
        {type="item", name="lead-plate", amount=31},
        {type="item", name="repair-pack", amount=3},
        {type="item", name="small-lamp", amount=4},
        {type="item", name="stone-brick", amount=169},
        {type="item", name="underground-belt", amount=4},
      },
      results = {
        {type="item", name="borax-mine", amount=3},
      },
    },
    ["distilator"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=6},
        {type="item", name="bolts", amount=206},
        {type="item", name="inductor1", amount=4},
        {type="item", name="limestone", amount=275},
        {type="item", name="pipe", amount=39},
        {type="item", name="small-parts-01", amount=22},
        {type="item", name="soil", amount=58},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="stone-brick", amount=65},
      },
      results = {
        {type="item", name="distilator", amount=4},
      },
    },
    ["fluid-drill-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boiler", amount=5},
        {type="item", name="burner-inserter", amount=9},
        {type="item", name="copper-cable", amount=57},
        {type="item", name="iron-plate", amount=15},
        {type="item", name="iron-stick", amount=43},
        {type="item", name="offshore-pump", amount=3},
      },
      results = {
        {type="item", name="fluid-drill-mk01", amount=1},
      },
    },
    ["gasifier"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=9},
        {type="item", name="calcium-carbide", amount=32},
        {type="item", name="copper-cable", amount=21},
        {type="item", name="inductor1", amount=4},
        {type="item", name="iron-stick", amount=32},
        {type="item", name="pipe", amount=5},
        {type="item", name="repair-pack", amount=2},
        {type="item", name="steam-engine", amount=2},
        {type="item", name="steel-plate", amount=22},
        {type="item", name="stone-wall", amount=40},
      },
      results = {
        {type="item", name="gasifier", amount=2},
      },
    },
    ["glassworks-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boiler", amount=3},
        {type="item", name="distilator", amount=1},
        {type="item", name="iron-chest", amount=3},
        {type="item", name="iron-gear-wheel", amount=8},
        {type="item", name="pipe", amount=4},
        {type="item", name="wood", amount=10},
      },
      results = {
        {type="item", name="glassworks-mk01", amount=1},
      },
    },
    ["hpf"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=1},
        {type="item", name="copper-cable", amount=45},
        {type="item", name="lab", amount=1},
        {type="item", name="limestone", amount=60},
        {type="item", name="pipe", amount=8},
        {type="item", name="saps", amount=8},
        {type="item", name="stone", amount=37},
      },
      results = {
        {type="item", name="hpf", amount=1},
      },
    },
    ["jaw-crusher"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=11},
        {type="item", name="iron-stick", amount=39},
        {type="item", name="pipe", amount=49},
        {type="item", name="steel-plate", amount=26},
      },
      results = {
        {type="item", name="jaw-crusher", amount=1},
      },
    },
    ["solid-separator"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="burner-inserter", amount=19},
        {type="item", name="burner-mining-drill", amount=10},
        {type="item", name="moss", amount=46},
        {type="item", name="pipe", amount=79},
        {type="item", name="steam-engine", amount=7},
        {type="item", name="stone-brick", amount=734},
        {type="item", name="transport-belt", amount=77},
      },
      results = {
        {type="item", name="solid-separator", amount=2},
      },
    },
    ["tar-processing-unit"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=3},
        {type="item", name="bolts", amount=47},
        {type="item", name="copper-plate", amount=28},
        {type="item", name="inductor1", amount=9},
        {type="item", name="submachine-gun", amount=3},
      },
      results = {
        {type="item", name="tar-processing-unit", amount=1},
      },
    },
    ["washer"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="copper-cable", amount=17},
        {type="item", name="copper-plate", amount=15},
        {type="item", name="iron-stick", amount=54},
        {type="item", name="lab", amount=1},
        {type="item", name="limestone", amount=53},
        {type="item", name="offshore-pump", amount=5},
        {type="item", name="pipe", amount=21},
        {type="item", name="saps", amount=23},
        {type="item", name="stone-furnace", amount=12},
        {type="item", name="transport-belt", amount=16},
      },
      results = {
        {type="item", name="washer", amount=2},
      },
    },
    ["evaporator"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=14},
        {type="item", name="bolts", amount=96},
        {type="item", name="concrete", amount=117},
        {type="item", name="copper-plate", amount=58},
        {type="item", name="glassworks-mk01", amount=2},
        {type="item", name="inductor1", amount=18},
        {type="item", name="lab", amount=1},
        {type="item", name="pipe", amount=45},
        {type="item", name="submachine-gun", amount=6},
        {type="item", name="titanium-plate", amount=39},
      },
      results = {
        {type="item", name="evaporator", amount=2},
      },
    },
    ["quenching-tower"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=7},
        {type="item", name="copper-cable", amount=57},
        {type="item", name="empty-planter-box", amount=11},
        {type="item", name="hpf", amount=2},
        {type="item", name="inductor1", amount=92},
        {type="item", name="iron-stick", amount=18},
        {type="item", name="lab", amount=3},
        {type="item", name="small-parts-01", amount=14},
        {type="item", name="steel-chest", amount=7},
        {type="item", name="stone-brick", amount=26},
        {type="item", name="stone-furnace", amount=124},
      },
      results = {
        {type="item", name="quenching-tower", amount=2},
      },
    },
    ["clay-pit-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 5,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=6},
        {type="item", name="iron-gear-wheel", amount=20},
        {type="item", name="iron-stick", amount=77},
        {type="item", name="limestone", amount=77},
        {type="item", name="raw-fiber", amount=78},
        {type="item", name="small-parts-01", amount=28},
        {type="item", name="soil-extractor-mk01", amount=2},
      },
      results = {
        {type="item", name="clay-pit-mk01", amount=5},
      },
    },
    ["electronics-factory-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="agar", amount=3},
        {type="item", name="burner-inserter", amount=2},
        {type="item", name="burner-mining-drill", amount=16},
        {type="item", name="glassworks-mk01", amount=2},
        {type="item", name="iron-chest", amount=5},
        {type="item", name="ore-chromium", amount=93},
        {type="item", name="stone-brick", amount=20},
        {type="item", name="transport-belt", amount=6},
        {type="item", name="washer", amount=1},
      },
      results = {
        {type="item", name="electronics-factory-mk01", amount=1},
      },
    },
    ["pulp-mill-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="copper-cable", amount=39},
        {type="item", name="empty-planter-box", amount=3},
        {type="item", name="hpf", amount=3},
        {type="item", name="iron-stick", amount=36},
        {type="item", name="lab", amount=6},
        {type="item", name="small-parts-01", amount=29},
      },
      results = {
        {type="item", name="pulp-mill-mk01", amount=2},
      },
    },
    ["chipshooter-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="copper-cable", amount=159},
        {type="item", name="copper-plate", amount=194},
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="formica", amount=61},
        {type="item", name="lab", amount=2},
        {type="item", name="landfill", amount=9},
        {type="item", name="petri-dish-bacteria", amount=11},
        {type="item", name="resistor1", amount=254},
        {type="item", name="shotgun", amount=2},
        {type="item", name="soil-extractor-mk01", amount=3},
        {type="item", name="stone-furnace", amount=65},
        {type="item", name="tar-processing-unit", amount=1},
      },
      results = {
        {type="item", name="chipshooter-mk01", amount=2},
      },
    },
    ["pcb-factory-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boiler", amount=13},
        {type="item", name="native-flora", amount=631},
        {type="item", name="pulp-mill-mk01", amount=5},
        {type="item", name="submachine-gun", amount=7},
        {type="item", name="tin-plate", amount=16},
        {type="item", name="washer", amount=1},
      },
      results = {
        {type="item", name="pcb-factory-mk01", amount=1},
      },
    },
    ["anthracene-oil-creosote"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.95,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=179},
      },
      results = {
        {type="fluid", name="creosote", amount=19},
      },
    },
    ["gravel-saline-water"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="fluid", name="water", amount=80},
        {type="item", name="limestone", amount=1},
        {type="item", name="sand", amount=4},
        {type="item", name="stone", amount=26},
      },
      results = {
        {type="fluid", name="water-saline", amount=70},
      },
    },
    ["sulfur-void-tar"] = {
      mode = "input-preserved-untransformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=50},
        {type="item", name="kerogen", amount=1},
        {type="item", name="sulfur", amount=1},
      },
      results = {
        {type="fluid", name="tar", amount=50},
      },
    },
    ["saline-water"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.78,
      ingredients = {
        {type="fluid", name="water", amount=89},
        {type="item", name="stone", amount=8},
      },
      results = {
        {type="fluid", name="water-saline", amount=39},
      },
    },
    ["biofactory-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boiler", amount=69},
        {type="item", name="concrete", amount=496},
        {type="item", name="copper-cable", amount=70},
        {type="item", name="iron-plate", amount=133},
        {type="item", name="lead-plate", amount=157},
        {type="item", name="refined-concrete", amount=44},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="tin-plate", amount=21},
      },
      results = {
        {type="item", name="biofactory-mk01", amount=1},
      },
    },
    ["botanical-nursery"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="burner-inserter", amount=5},
        {type="item", name="burner-mining-drill", amount=2},
        {type="item", name="capacitor1", amount=13},
        {type="item", name="concrete", amount=27},
        {type="item", name="empty-planter-box", amount=15},
        {type="item", name="glass", amount=13},
        {type="item", name="glassworks-mk01", amount=1},
        {type="item", name="hpf", amount=1},
        {type="item", name="iron-chest", amount=2},
        {type="item", name="ore-chromium", amount=45},
        {type="item", name="tar-processing-unit", amount=1},
        {type="item", name="tin-plate", amount=5},
        {type="item", name="washer", amount=1},
      },
      results = {
        {type="item", name="botanical-nursery", amount=2},
      },
    },
    ["creature-chamber-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=67},
        {type="item", name="botanical-nursery", amount=7},
        {type="item", name="cellulose", amount=63},
        {type="item", name="concrete", amount=875},
        {type="item", name="pcb1", amount=37},
        {type="item", name="pump", amount=2},
        {type="item", name="py-tank-1500", amount=2},
        {type="item", name="py-tank-6500", amount=3},
        {type="item", name="rc-mk01", amount=1},
        {type="item", name="sodium-alginate", amount=53},
      },
      results = {
        {type="item", name="creature-chamber-mk01", amount=2},
      },
    },
    ["incubator-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=26},
        {type="item", name="lab", amount=1},
        {type="item", name="pipe", amount=217},
        {type="item", name="soil-extractor-mk01", amount=2},
        {type="item", name="tin-plate", amount=25},
        {type="item", name="tinned-cable", amount=12},
      },
      results = {
        {type="item", name="incubator-mk01", amount=1},
      },
    },
    ["micro-mine-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 0.160812363254232,
      ingredients = {
        {type="item", name="aluminium-plate", amount=7},
        {type="item", name="inductor1", amount=4},
        {type="item", name="lead-plate", amount=7},
        {type="item", name="small-lamp", amount=1},
      },
      results = {
        {type="item", name="micro-mine-mk01", amount=0.160812363254232},
      },
    },
    ["rc-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="battery-mk00", amount=1},
        {type="item", name="copper-cable", amount=935},
        {type="item", name="copper-plate", amount=143},
        {type="item", name="lab", amount=4},
        {type="item", name="landfill", amount=16},
        {type="item", name="pcb1", amount=14},
        {type="item", name="resistor1", amount=187},
        {type="item", name="soil-extractor-mk01", amount=5},
        {type="item", name="solder", amount=2},
        {type="item", name="stone-furnace", amount=383},
        {type="item", name="tin-plate", amount=21},
      },
      results = {
        {type="item", name="rc-mk01", amount=1},
      },
    },
    ["genlab-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=8},
        {type="item", name="botanical-nursery", amount=3},
        {type="item", name="concrete", amount=801},
        {type="item", name="copper-plate", amount=27},
        {type="item", name="lead-plate", amount=30},
        {type="item", name="pump", amount=1},
        {type="item", name="py-tank-6500", amount=1},
        {type="item", name="resistor1", amount=35},
        {type="item", name="small-parts-01", amount=42},
        {type="item", name="sodium-alginate", amount=163},
        {type="item", name="sodium-hydroxide", amount=8},
      },
      results = {
        {type="item", name="genlab-mk01", amount=1},
      },
    },
    ["research-center-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="gasifier", amount=1},
        {type="item", name="iron-stick", amount=248},
        {type="item", name="micro-mine-mk01", amount=1},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="steam-engine", amount=137},
        {type="item", name="tinned-cable", amount=259},
        {type="item", name="washer", amount=6},
      },
      results = {
        {type="item", name="research-center-mk01", amount=2},
      },
    },
    ["slaughterhouse-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=57},
        {type="item", name="boiler", amount=24},
        {type="item", name="concrete", amount=1000},
        {type="item", name="copper-cable", amount=192},
        {type="item", name="iron-plate", amount=45},
        {type="item", name="lab", amount=10},
        {type="item", name="lead-plate", amount=428},
        {type="item", name="pcb1", amount=48},
        {type="item", name="py-check-valve", amount=7},
        {type="item", name="refined-concrete", amount=47},
        {type="item", name="steam-engine", amount=2},
        {type="item", name="tin-plate", amount=24},
        {type="item", name="tinned-cable", amount=15},
      },
      results = {
        {type="item", name="slaughterhouse-mk01", amount=2},
      },
    },
    ["gate"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ceramic", amount=9},
        {type="item", name="steam-engine", amount=4},
      },
      results = {
        {type="item", name="gate", amount=1},
      },
    },
    ["poorman-wood-fence"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="seaweed", amount=5},
      },
      results = {
        {type="item", name="poorman-wood-fence", amount=1},
      },
    },
    ["stone-wall"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="stone-brick", amount=5},
      },
      results = {
        {type="item", name="stone-wall", amount=1},
      },
    },
    ["automated-screener-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=9},
        {type="item", name="burner-mining-drill", amount=10},
        {type="item", name="concrete", amount=140},
        {type="item", name="distilator", amount=1},
        {type="item", name="iron-stick", amount=187},
        {type="item", name="pipe", amount=67},
        {type="item", name="quenching-tower", amount=2},
        {type="item", name="steam-engine", amount=67},
        {type="item", name="tar-processing-unit", amount=1},
        {type="item", name="tinned-cable", amount=204},
        {type="item", name="titanium-plate", amount=76},
      },
      results = {
        {type="item", name="automated-screener-mk01", amount=3},
      },
    },
    ["vacuum-pump-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="copper-cable", amount=37},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="steel-plate", amount=22},
        {type="item", name="transport-belt", amount=17},
      },
      results = {
        {type="item", name="vacuum-pump-mk01", amount=2},
      },
    },
    ["bio-sample"] = {
      mode = "repaired-to-input",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="barrel", amount=3},
        {type="item", name="saps", amount=2},
      },
      results = {
        {type="item", name="bio-sample", amount=1},
      },
    },
    ["moss-gen"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="empty-petri-dish", amount=6},
        {type="item", name="moss", amount=33},
        {type="item", name="petri-dish-bacteria", amount=1},
      },
      results = {
        {type="item", name="moss-gen", amount=2},
      },
    },
    ["earth-generic-sample"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="automation-science-pack", amount=8},
        {type="item", name="bio-sample", amount=12},
        {type="item", name="coal", amount=17},
        {type="item", name="copper-cable", amount=24},
        {type="item", name="inductor1", amount=2},
        {type="item", name="iron-chest", amount=1},
        {type="item", name="pipe", amount=20},
        {type="item", name="steam-engine", amount=11},
        {type="item", name="stone-furnace", amount=8},
      },
      results = {
        {type="item", name="earth-generic-sample", amount=2},
      },
    },
    ["vrauks-cocoon-1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.76589680652558,
      ingredients = {
        {type="item", name="limestone", amount=6},
        {type="item", name="moss", amount=5},
        {type="item", name="oxygen-barrel", amount=2},
        {type="item", name="raw-fiber", amount=6},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="barrel", amount=7},
        {type="item", name="cocoon", amount=9},
      },
    },
    ["vrauks-codex"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="pipe", amount=10},
        {type="item", name="small-lamp", amount=4},
        {type="item", name="steam-engine", amount=10},
        {type="item", name="tin-plate", amount=2},
        {type="item", name="tinned-cable", amount=73},
      },
      results = {
        {type="item", name="vrauks-codex", amount=2},
      },
    },
    ["vrauks"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="boiler", amount=18},
        {type="item", name="earth-generic-sample", amount=5},
        {type="item", name="native-flora", amount=891},
        {type="item", name="petri-dish-bacteria", amount=28},
        {type="item", name="pulp-mill-mk01", amount=2},
        {type="item", name="sodium-hydroxide", amount=92},
        {type="item", name="submachine-gun", amount=3},
        {type="item", name="vrauks-codex", amount=3},
        {type="item", name="washer", amount=4},
      },
      results = {
        {type="item", name="vrauks", amount=4},
      },
    },
    ["vrauks-paddock-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="aluminium-plate", amount=26},
        {type="item", name="ceramic", amount=122},
        {type="item", name="lab", amount=3},
        {type="item", name="micro-mine-mk01", amount=2},
        {type="item", name="pipe", amount=87},
        {type="item", name="small-lamp", amount=6},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="soil-extractor-mk01", amount=2},
        {type="item", name="tin-plate", amount=26},
        {type="item", name="tinned-cable", amount=4},
        {type="item", name="transport-belt", amount=8},
      },
      results = {
        {type="item", name="vrauks-paddock-mk01", amount=3},
      },
    },
    ["uncaged-vrauks"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="caged-vrauks", amount=1},
      },
      results = {
        {type="item", name="cage", amount=1},
        {type="item", name="vrauks", amount=1},
      },
    },
    ["vrauks-1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.44245238649357,
      ingredients = {
        {type="item", name="ore-tin", amount=9},
        {type="item", name="oxygen-barrel", amount=4},
        {type="item", name="raw-fiber", amount=13},
        {type="item", name="sodium-hydroxide", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=4},
        {type="item", name="vrauks", amount=3},
      },
    },
    ["fluidavan"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="cage", amount=5},
        {type="item", name="coal-dust", amount=231},
        {type="item", name="flora-collector-mk01", amount=3},
        {type="item", name="methanal-barrel", amount=7},
        {type="item", name="moss-gen", amount=9},
        {type="item", name="petri-dish-bacteria", amount=58},
        {type="item", name="py-local-radar", amount=2},
        {type="item", name="rich-clay", amount=6},
        {type="item", name="tailings-barrel", amount=40},
      },
      results = {
        {type="item", name="fluidavan", amount=2},
      },
    },
    ["caravan"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coal-dust", amount=61},
        {type="item", name="flora-collector-mk01", amount=2},
        {type="item", name="moss-gen", amount=20},
      },
      results = {
        {type="item", name="caravan", amount=1},
      },
    },
    ["concrete"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="fluid", name="water", amount=97},
        {type="item", name="calcium-carbide", amount=7},
        {type="item", name="limestone", amount=8},
        {type="item", name="ore-aluminium", amount=7},
        {type="item", name="poorman-wood-fence", amount=3},
        {type="item", name="sand", amount=11},
      },
      results = {
        {type="item", name="concrete", amount=8},
      },
    },
    ["stone-brick-2"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="fluid", name="pitch", amount=50},
        {type="item", name="stone", amount=8},
      },
      results = {
        {type="item", name="stone-brick", amount=5},
      },
    },
    ["hazard-concrete"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="ore-quartz", amount=122},
      },
      results = {
        {type="item", name="hazard-concrete", amount=8},
      },
    },
    ["refined-concrete"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="fluid", name="water", amount=663},
        {type="item", name="ash", amount=2},
        {type="item", name="gravel", amount=52},
        {type="item", name="iron-gear-wheel", amount=1},
        {type="item", name="iron-plate", amount=4},
        {type="item", name="stone-brick", amount=19},
      },
      results = {
        {type="item", name="refined-concrete", amount=14},
      },
    },
    ["landfill"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="water", amount=903},
        {type="item", name="empty-planter-box", amount=3},
        {type="item", name="ore-aluminium", amount=14},
        {type="item", name="poorman-wood-fence", amount=6},
      },
      results = {
        {type="item", name="landfill", amount=2},
      },
    },
    ["refined-hazard-concrete"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.1,
      ingredients = {
        {type="item", name="hazard-concrete", amount=5},
        {type="item", name="ore-quartz", amount=111},
      },
      results = {
        {type="item", name="refined-hazard-concrete", amount=11},
      },
    },
    ["outpost"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="graphite", amount=175},
        {type="item", name="inductor1", amount=2},
        {type="item", name="ore-titanium", amount=18},
        {type="item", name="repair-pack", amount=1},
        {type="item", name="submachine-gun", amount=1},
      },
      results = {
        {type="item", name="outpost", amount=1},
      },
    },
    ["outpost-fluid"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 5,
      ingredients = {
        {type="item", name="burner-inserter", amount=2},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="graphite", amount=614},
        {type="item", name="moss", amount=180},
        {type="item", name="ore-titanium", amount=81},
        {type="item", name="py-check-valve", amount=4},
        {type="item", name="py-sinkhole", amount=2},
        {type="item", name="repair-pack", amount=11},
        {type="item", name="submachine-gun", amount=3},
      },
      results = {
        {type="item", name="outpost-fluid", amount=5},
      },
    },
    ["data-array"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=147},
        {type="item", name="distilator", amount=5},
        {type="item", name="engine-unit", amount=16},
        {type="item", name="gasifier", amount=5},
        {type="item", name="iron-plate", amount=299},
        {type="item", name="lead-plate", amount=32},
        {type="item", name="pipe", amount=290},
        {type="item", name="poorman-wood-fence", amount=385},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="tin-plate", amount=13},
        {type="item", name="treated-wood", amount=322},
      },
      results = {
        {type="item", name="data-array", amount=2},
      },
    },
    ["creamy-latex"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2.04,
      ingredients = {
        {type="fluid", name="water", amount=89},
        {type="item", name="copper-ore", amount=1},
        {type="item", name="saps", amount=2},
        {type="item", name="seaweed", amount=2},
        {type="item", name="stone-brick", amount=5},
      },
      results = {
        {type="fluid", name="creamy-latex", amount=204},
      },
    },
    ["sodium-alginate"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="sand", amount=4},
        {type="item", name="wood", amount=5},
        {type="item", name="wooden-chest", amount=3},
      },
      results = {
        {type="item", name="sodium-alginate", amount=2},
      },
    },
    ["latex-slab"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="tar", amount=123},
        {type="item", name="native-flora", amount=87},
        {type="item", name="sodium-hydroxide", amount=1},
      },
      results = {
        {type="item", name="latex-slab", amount=1},
      },
    },
    ["sap-seeds"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="native-flora", amount=16},
      },
      results = {
        {type="item", name="sap-seeds", amount=1},
      },
    },
    ["latex"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=173},
        {type="fluid", name="pressured-water", amount=690},
        {type="item", name="cellulose", amount=1},
        {type="item", name="coke", amount=34},
      },
      results = {
        {type="item", name="latex", amount=1},
      },
    },
    ["sap-tree"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="glass", amount=3},
        {type="item", name="wood-seeds", amount=21},
      },
      results = {
        {type="item", name="sap-tree", amount=1},
      },
    },
    ["py-check-valve"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="iron-plate", amount=10},
        {type="item", name="iron-stick", amount=5},
        {type="item", name="transport-belt", amount=3},
      },
      results = {
        {type="item", name="py-check-valve", amount=2},
      },
    },
    ["py-underflow-valve"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="cellulose", amount=4},
        {type="item", name="empty-planter-box", amount=31},
        {type="item", name="iron-gear-wheel", amount=2},
        {type="item", name="iron-stick", amount=8},
        {type="item", name="pipe", amount=39},
        {type="item", name="shotgun", amount=3},
      },
      results = {
        {type="item", name="py-underflow-valve", amount=4},
      },
    },
    ["py-overflow-valve"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="capacitor1", amount=1},
        {type="item", name="iron-plate", amount=5},
        {type="item", name="py-underflow-valve", amount=1},
      },
      results = {
        {type="item", name="py-overflow-valve", amount=1},
      },
    },
    ["py-local-radar"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coal", amount=32},
        {type="item", name="copper-cable", amount=44},
        {type="item", name="pipe", amount=12},
        {type="item", name="steam-engine", amount=3},
      },
      results = {
        {type="item", name="py-local-radar", amount=1},
      },
    },
    ["radar"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="copper-cable", amount=111},
        {type="item", name="copper-plate", amount=37},
        {type="item", name="hpf", amount=7},
        {type="item", name="soot", amount=4},
      },
      results = {
        {type="item", name="radar", amount=2},
      },
    },
    ["battery-mk00"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="syngas", amount=909},
        {type="item", name="copper-cable", amount=29},
        {type="item", name="tin-plate", amount=8},
        {type="item", name="wooden-chest", amount=16},
      },
      results = {
        {type="item", name="battery-mk00", amount=1},
      },
    },
    ["electrolyzer-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=4},
        {type="item", name="burner-mining-drill", amount=42},
        {type="item", name="lead-plate", amount=25},
        {type="item", name="pipe", amount=83},
        {type="item", name="quenching-tower", amount=1},
        {type="item", name="tinned-cable", amount=217},
        {type="item", name="titanium-plate", amount=98},
      },
      results = {
        {type="item", name="electrolyzer-mk01", amount=3},
      },
    },
    ["smelter-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=42},
        {type="item", name="distilator", amount=3},
        {type="item", name="gasifier", amount=1},
        {type="item", name="lead-plate", amount=18},
        {type="item", name="poorman-wood-fence", amount=220},
      },
      results = {
        {type="item", name="smelter-mk01", amount=1},
      },
    },
    ["inserter"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=8},
        {type="item", name="pipe", amount=12},
        {type="item", name="tin-plate", amount=5},
        {type="item", name="tinned-cable", amount=24},
      },
      results = {
        {type="item", name="inserter", amount=1},
      },
    },
    ["methane-co2"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.75,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=148},
        {type="fluid", name="hydrogen", amount=225},
        {type="fluid", name="water", amount=76},
        {type="item", name="moondrop-seeds", amount=1},
      },
      results = {
        {type="fluid", name="methane", amount=70},
      },
    },
    ["methanal"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.02,
      ingredients = {
        {type="fluid", name="hydrogen", amount=798},
        {type="item", name="coke", amount=2},
        {type="item", name="iron-plate", amount=4},
      },
      results = {
        {type="fluid", name="methanal", amount=51},
      },
    },
    ["capacitor1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2.66666666666667,
      ingredients = {
        {type="item", name="graphite", amount=5},
        {type="item", name="lead-plate", amount=3},
        {type="item", name="zinc-plate", amount=2},
      },
      results = {
        {type="item", name="capacitor1", amount=8},
      },
    },
    ["inductor1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="copper-cable", amount=8},
        {type="item", name="graphite", amount=4},
        {type="item", name="ore-aluminium", amount=12},
      },
      results = {
        {type="item", name="inductor1", amount=4},
      },
    },
    ["resistor1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="glass", amount=2},
        {type="item", name="graphite", amount=1},
        {type="item", name="zinc-plate", amount=2},
      },
      results = {
        {type="item", name="resistor1", amount=6},
      },
    },
    ["formica"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="methanal", amount=23},
        {type="item", name="lime", amount=11},
        {type="item", name="moondrop", amount=5},
        {type="item", name="ore-quartz", amount=16},
        {type="item", name="stone", amount=73},
      },
      results = {
        {type="item", name="formica", amount=1},
      },
    },
    ["vacuum-tube"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="coke", amount=4},
        {type="item", name="copper-ore", amount=7},
        {type="item", name="pipe", amount=13},
      },
      results = {
        {type="item", name="vacuum-tube", amount=3},
      },
    },
    ["pcb1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="formica", amount=5},
        {type="item", name="iron-plate", amount=35},
      },
      results = {
        {type="item", name="pcb1", amount=3},
      },
    },
    ["electronic-circuit"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="battery-mk00", amount=1},
        {type="item", name="formica", amount=10},
        {type="item", name="hazard-concrete", amount=4},
        {type="item", name="solder", amount=2},
        {type="item", name="tin-plate", amount=3},
        {type="item", name="vacuum-tube", amount=3},
      },
      results = {
        {type="item", name="electronic-circuit", amount=6},
      },
    },
    ["olefin-plant"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="engine-unit", amount=2},
        {type="item", name="lime", amount=562},
        {type="item", name="py-tank-8000", amount=5},
        {type="item", name="reformer-mk01", amount=1},
        {type="item", name="small-parts-01", amount=23},
        {type="item", name="steam-engine", amount=8},
        {type="item", name="storage-tank", amount=6},
        {type="item", name="titanium-plate", amount=81},
      },
      results = {
        {type="item", name="olefin-plant", amount=2},
      },
    },
    ["reformer-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="concrete", amount=104},
        {type="item", name="gasifier", amount=1},
        {type="item", name="iron-stick", amount=152},
        {type="item", name="tinned-cable", amount=495},
        {type="item", name="washer", amount=2},
      },
      results = {
        {type="item", name="reformer-mk01", amount=1},
      },
    },
    ["splitter"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="capacitor1", amount=25},
        {type="item", name="tinned-cable", amount=1},
      },
      results = {
        {type="item", name="splitter", amount=1},
      },
    },
    ["moondrop-1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="fluid", name="water", amount=77},
        {type="item", name="soil", amount=23},
      },
      results = {
        {type="item", name="moondrop", amount=3},
      },
    },
    ["moondrop-sample"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="item", name="empty-petri-dish", amount=4},
        {type="item", name="moondrop-codex", amount=1},
        {type="item", name="planter-box", amount=1},
        {type="item", name="stopper", amount=5},
      },
      results = {
        {type="item", name="moondrop", amount=5},
      },
    },
    ["moondrop-seeds"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="item", name="moondrop", amount=3},
      },
      results = {
        {type="item", name="moondrop", amount=2},
        {type="item", name="moondrop-seeds", amount=3},
      },
    },
    ["multiblade-turbine-mk01"] = {
      mode = "input-preserved-untransformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cellulose", amount=4},
        {type="item", name="fish", amount=5},
        {type="item", name="iron-oxide", amount=3},
        {type="item", name="pipe-to-ground", amount=6},
        {type="item", name="steel-plate", amount=10},
        {type="item", name="stone-wall", amount=4},
      },
      results = {
        {type="item", name="multiblade-turbine-mk01", amount=1},
      },
    },
    ["py-science-pack-1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="moss-gen", amount=2},
        {type="item", name="stopper", amount=8},
      },
      results = {
        {type="item", name="py-science-pack-1", amount=3},
      },
    },
    ["agar"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="steam", amount=74},
        {type="fluid", name="water", amount=1324},
        {type="item", name="ash", amount=3},
        {type="item", name="limestone", amount=3},
      },
      results = {
        {type="item", name="agar", amount=2},
      },
    },
    ["cellulose-00"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="limestone", amount=4},
        {type="item", name="sand", amount=7},
        {type="item", name="seaweed", amount=2},
      },
      results = {
        {type="item", name="cellulose", amount=1},
      },
    },
    ["cellulose-02"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coal", amount=9},
        {type="item", name="sodium-hydroxide", amount=3},
      },
      results = {
        {type="item", name="cellulose", amount=2},
      },
    },
    ["coke-co2"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.475,
      ingredients = {
        {type="item", name="coke", amount=1},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=38},
      },
    },
    ["lime"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.30283715017649,
      ingredients = {
        {type="item", name="graphite", amount=2},
        {type="item", name="soil", amount=7},
        {type="item", name="wood", amount=15},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=132},
        {type="item", name="lime", amount=13},
      },
    },
    ["dried-meat-01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="brain", amount=4},
      },
      results = {
        {type="item", name="dried-meat", amount=4},
      },
    },
    ["petri-dish-bacteria"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="empty-petri-dish", amount=5},
      },
      results = {
        {type="item", name="petri-dish-bacteria", amount=3},
      },
    },
    ["fawogae-substrate"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="moss", amount=6},
        {type="item", name="petri-dish", amount=1},
        {type="item", name="wooden-chest", amount=6},
      },
      results = {
        {type="item", name="fawogae-substrate", amount=5},
      },
    },
    ["empty-petri-dish"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="fluid", name="molten-glass", amount=85},
        {type="item", name="copper-cable", amount=2},
        {type="item", name="tin-plate", amount=1},
      },
      results = {
        {type="item", name="empty-petri-dish", amount=3},
      },
    },
    ["sand-void-glass"] = {
      mode = "input-preserved-untransformed",
      science_level = 1,
      energy_required_multiplier = 1.3,
      ingredients = {
        {type="item", name="gravel", amount=10},
        {type="item", name="stone-furnace", amount=1},
      },
      results = {
        {type="fluid", name="molten-glass", amount=13},
      },
    },
    ["stopper"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="item", name="pipe", amount=22},
        {type="item", name="stone", amount=18},
        {type="item", name="wood", amount=4},
      },
      results = {
        {type="item", name="stopper", amount=3},
      },
    },
    ["flask"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="steam", amount=413},
        {type="fluid", name="water", amount=1846},
        {type="item", name="stopper", amount=2},
        {type="item", name="tin-plate", amount=7},
        {type="item", name="wooden-chest", amount=13},
      },
      results = {
        {type="item", name="flask", amount=3},
      },
    },
    ["petri-dish"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="cellulose", amount=2},
        {type="item", name="empty-planter-box", amount=3},
      },
      results = {
        {type="item", name="petri-dish", amount=2},
      },
    },
    ["scrude-refining"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.586888888888889,
      ingredients = {
        {type="fluid", name="steam", amount=107},
        {type="fluid", name="water", amount=1400},
      },
      results = {
        {type="fluid", name="condensates", amount=146},
        {type="fluid", name="heavy-oil", amount=59},
        {type="fluid", name="light-oil", amount=88},
      },
    },
    ["tar-refining"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.401719171230599,
      ingredients = {
        {type="fluid", name="tar", amount=77},
      },
      results = {
        {type="fluid", name="anthracene-oil", amount=30},
        {type="fluid", name="creosote", amount=10},
        {type="fluid", name="middle-oil", amount=12},
        {type="fluid", name="pitch", amount=56},
      },
    },
    ["heavy-oil-to-kerosene"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.575,
      ingredients = {
        {type="fluid", name="hydrogen", amount=1570},
        {type="item", name="soil", amount=43},
      },
      results = {
        {type="fluid", name="kerosene", amount=63},
      },
    },
    ["pitch-refining"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.62931137655043,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=175},
        {type="fluid", name="pitch", amount=97},
        {type="fluid", name="water", amount=1893},
      },
      results = {
        {type="fluid", name="anthracene-oil", amount=49},
        {type="fluid", name="hydrogen", amount=16},
        {type="fluid", name="light-oil", amount=33},
        {type="fluid", name="naphthalene-oil", amount=33},
        {type="item", name="coke", amount=16},
      },
    },
    ["tar-refining-tops"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.64,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=184},
        {type="fluid", name="pitch", amount=474},
        {type="item", name="ash", amount=2},
        {type="item", name="tin-plate", amount=3},
      },
      results = {
        {type="fluid", name="carbolic-oil", amount=82},
        {type="fluid", name="light-oil", amount=82},
        {type="fluid", name="naphthalene-oil", amount=164},
      },
    },
    ["anthracene-gasoline-cracking"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=48},
        {type="fluid", name="syngas", amount=151},
      },
      results = {
        {type="fluid", name="gasoline", amount=24},
        {type="item", name="coke", amount=6},
      },
    },
    ["carbolic-oil-creosote"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1.28,
      ingredients = {
        {type="fluid", name="flue-gas", amount=941},
        {type="fluid", name="pitch", amount=227},
      },
      results = {
        {type="fluid", name="creosote", amount=64},
      },
    },
    ["kerogen-extraction"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.6,
      ingredients = {
        {type="fluid", name="steam", amount=40},
        {type="item", name="ash", amount=4},
      },
      results = {
        {type="fluid", name="scrude", amount=150},
      },
    },
    ["light-oil-aromatics"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.45,
      ingredients = {
        {type="fluid", name="light-oil", amount=21},
        {type="fluid", name="steam", amount=4},
      },
      results = {
        {type="fluid", name="aromatics", amount=23},
        {type="fluid", name="gasoline", amount=11},
      },
    },
    ["naphthalene-oil-creosote"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.466666666666667,
      ingredients = {
        {type="fluid", name="flue-gas", amount=28},
        {type="fluid", name="syngas", amount=157},
      },
      results = {
        {type="fluid", name="creosote", amount=14},
      },
    },
    ["barrel"] = {
      mode = "input-preserved-untransformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="steel-plate", amount=1},
      },
      results = {
        {type="item", name="barrel", amount=1},
      },
    },
    ["barrel-machine-mk01"] = {
      mode = "input-preserved-untransformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=6},
        {type="item", name="iron-oxide", amount=5},
        {type="item", name="lab", amount=3},
        {type="item", name="lead-plate", amount=13},
        {type="item", name="pcb1", amount=4},
        {type="item", name="transport-belt", amount=19},
      },
      results = {
        {type="item", name="barrel-machine-mk01", amount=2},
      },
    },
    ["coal-gas-void"] = {
      mode = "input-preserved-untransformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=508},
      },
      results = {
        {type="item", name="ash", amount=1},
      },
    },
    ["slacked-lime-void"] = {
      mode = "input-preserved-untransformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=692},
      },
      results = {
        {type="item", name="gravel", amount=1},
        {type="item", name="lime", amount=1},
      },
    },
    ["sodium-hydroxide-void"] = {
      mode = "input-preserved-untransformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="stone-brick", amount=50},
      },
      results = {
        {type="fluid", name="water-saline", amount=100},
      },
    },
    ["steel-from-barrels"] = {
      mode = "input-preserved-untransformed",
      science_level = 1,
      energy_required_multiplier = 3.07692307692308,
      ingredients = {
        {type="item", name="barrel", amount=3},
      },
      results = {
        {type="item", name="steel-plate", amount=2},
      },
    },
    ["chitin-void"] = {
      mode = "input-preserved-untransformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pitch", amount=467},
        {type="fluid", name="water", amount=77},
        {type="item", name="brain", amount=5},
      },
      results = {
        {type="fluid", name="carbolic-oil", amount=100},
        {type="fluid", name="naphthalene-oil", amount=50},
      },
    },
    ["limestone-void"] = {
      mode = "input-preserved-untransformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="limestone", amount=3},
        {type="item", name="soil", amount=2},
      },
      results = {
        {type="item", name="limestone", amount=2},
        {type="item", name="soil", amount=3},
      },
    },
    ["assembling-machine-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boiler", amount=5},
        {type="item", name="capacitor1", amount=44},
        {type="item", name="offshore-pump", amount=5},
        {type="item", name="pipe", amount=17},
        {type="item", name="resistor1", amount=2},
        {type="item", name="transport-belt", amount=8},
      },
      results = {
        {type="item", name="assembling-machine-2", amount=1},
      },
    },
    ["crushed-coal"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3.09417350624166,
      ingredients = {
        {type="item", name="raw-coal", amount=9},
      },
      results = {
        {type="item", name="coal", amount=6},
        {type="item", name="coal-dust", amount=1},
        {type="item", name="crushed-coal", amount=3},
      },
    },
    ["biomass-cooking"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="biomass", amount=51},
      },
      results = {
        {type="item", name="raw-coal", amount=4},
      },
    },
    ["biomass-molten-salt-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.325,
      ingredients = {
        {type="fluid", name="chlorine", amount=1700},
        {type="fluid", name="fish-oil", amount=136},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=530},
      },
    },
    ["chitin-to-geothermal-water"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.58,
      ingredients = {
        {type="fluid", name="steam", amount=252},
        {type="item", name="brain", amount=2},
      },
      results = {
        {type="fluid", name="geothermal-water", amount=29},
      },
    },
    ["he-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.964949077021006,
      ingredients = {
        {type="fluid", name="hot-molten-salt", amount=193},
      },
      results = {
        {type="fluid", name="molten-salt", amount=193},
        {type="fluid", name="pressured-steam", amount=72},
      },
    },
    ["molten-salt"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.44,
      ingredients = {
        {type="item", name="sodium-hydroxide", amount=17},
        {type="item", name="soil", amount=7},
      },
      results = {
        {type="fluid", name="molten-salt", amount=44},
      },
    },
    ["coal-molten-salt-01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 0.428,
      ingredients = {
        {type="fluid", name="chlorine", amount=996},
        {type="item", name="sand", amount=6},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=214},
      },
    },
    ["geo-he-00"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.966666666666667,
      ingredients = {
        {type="fluid", name="water", amount=417},
      },
      results = {
        {type="fluid", name="steam", amount=290},
      },
    },
    ["oil-molten-salt-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.766,
      ingredients = {
        {type="fluid", name="carbolic-oil", amount=678},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=383},
      },
    },
    ["borax-washing"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.00615464972209,
      ingredients = {
        {type="fluid", name="steam", amount=60},
        {type="item", name="gunpowder", amount=1},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=104},
        {type="item", name="borax", amount=10},
      },
    },
    ["diborane"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.64,
      ingredients = {
        {type="fluid", name="oxygen", amount=53},
        {type="item", name="raw-borax", amount=11},
      },
      results = {
        {type="fluid", name="diborane", amount=96},
      },
    },
    ["boric-acid"] = {
      mode = "repaired-to-input",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=179},
        {type="fluid", name="steam", amount=917},
      },
      results = {
        {type="fluid", name="boric-acid", amount=500},
      },
    },
    ["clean-nexelit"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.985,
      ingredients = {
        {type="fluid", name="steam", amount=63},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=97},
        {type="item", name="clean-nexelit", amount=1},
      },
    },
    ["nexelit-ore-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2.49992703663908,
      ingredients = {
        {type="fluid", name="tailings", amount=846},
        {type="item", name="raw-fiber", amount=2},
        {type="item", name="treated-wood", amount=3},
      },
      results = {
        {type="item", name="nexelit-ore", amount=2},
        {type="item", name="tailings-dust", amount=1},
      },
    },
    ["nexelit-plate-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.944444444444444,
      ingredients = {
        {type="item", name="clean-nexelit", amount=17},
      },
      results = {
        {type="item", name="nexelit-plate", amount=17},
      },
    },
    ["soil-separation-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.25999375127694,
      ingredients = {
        {type="fluid", name="hydrogen", amount=62},
        {type="item", name="iron-ore", amount=8},
        {type="item", name="lime", amount=2},
        {type="item", name="limestone", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=4},
        {type="item", name="coarse", amount=4},
        {type="item", name="limestone", amount=3},
        {type="item", name="sand", amount=16},
      },
    },
    ["coarse-classification"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.50703614598304,
      ingredients = {
        {type="fluid", name="water", amount=789},
        {type="item", name="chromite-sand", amount=14},
        {type="item", name="lime", amount=1},
        {type="item", name="sand-casting", amount=1},
        {type="item", name="soil", amount=140},
      },
      results = {
        {type="item", name="gravel", amount=6},
        {type="item", name="iron-oxide", amount=3},
        {type="item", name="stone", amount=8},
      },
    },
    ["concrete-wall"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=2},
        {type="item", name="glass", amount=5},
      },
      results = {
        {type="item", name="concrete-wall", amount=1},
      },
    },
    ["wood-fence"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ore-aluminium", amount=12},
      },
      results = {
        {type="item", name="wood-fence", amount=1},
      },
    },
    ["cool-pressured-steam-2000-to-1000"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.54,
      ingredients = {
        {type="fluid", name="pressured-steam", amount=200},
        {type="fluid", name="steam", amount=159},
        {type="fluid", name="water", amount=145},
      },
      results = {
        {type="fluid", name="pressured-steam", amount=508},
      },
    },
    ["jerky-to-phytoplankton"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.9,
      ingredients = {
        {type="fluid", name="water", amount=211},
        {type="item", name="dried-meat", amount=3},
      },
      results = {
        {type="fluid", name="phytoplankton", amount=9},
      },
    },
    ["cool-steam-250-to-150"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.764285714285714,
      ingredients = {
        {type="fluid", name="steam", amount=200},
        {type="fluid", name="water", amount=115},
      },
      results = {
        {type="fluid", name="steam", amount=307},
      },
    },
    ["electric-boiler-water-to-steam"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.516666666666667,
      ingredients = {
        {type="fluid", name="steam", amount=54},
        {type="fluid", name="water", amount=127},
      },
      results = {
        {type="fluid", name="steam", amount=209},
      },
    },
    ["digosaurus"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bio-sample", amount=262},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="tailings-dust", amount=116},
        {type="item", name="vacuum-tube", amount=69},
      },
      results = {
        {type="item", name="digosaurus", amount=1},
      },
    },
    ["electric-mining-drill"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="small-lamp", amount=2},
        {type="item", name="tinned-cable", amount=21},
      },
      results = {
        {type="item", name="electric-mining-drill", amount=1},
      },
    },
    ["fawogae-codex"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="electric-mining-drill", amount=11},
        {type="item", name="py-science-pack-1", amount=1},
        {type="item", name="small-parts-01", amount=28},
        {type="item", name="tin-plate", amount=60},
      },
      results = {
        {type="item", name="fawogae-codex", amount=1},
      },
    },
    ["ralesia-codex"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=44},
        {type="item", name="graphite", amount=361},
        {type="item", name="seaweed", amount=114},
        {type="item", name="small-parts-01", amount=632},
        {type="item", name="tin-plate", amount=35},
        {type="item", name="titanium-plate", amount=241},
      },
      results = {
        {type="item", name="ralesia-codex", amount=2},
      },
    },
    ["fbreactor-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=1},
        {type="item", name="clay", amount=340},
        {type="item", name="concrete", amount=12},
        {type="item", name="copper-plate", amount=16},
        {type="item", name="lab", amount=1},
        {type="item", name="lead-plate", amount=22},
        {type="item", name="seaweed", amount=37},
        {type="item", name="stone-furnace", amount=2},
      },
      results = {
        {type="item", name="fbreactor-mk01", amount=2},
      },
    },
    ["geothermal-plant-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="agar", amount=28},
        {type="item", name="carbolic-oil-barrel", amount=52},
        {type="item", name="duralumin", amount=21},
        {type="item", name="py-tank-3000", amount=2},
        {type="item", name="steam-engine", amount=5},
      },
      results = {
        {type="item", name="geothermal-plant-mk01", amount=1},
      },
    },
    ["grade-1-lead"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="iron-gear-wheel", amount=1},
        {type="item", name="ore-aluminium", amount=3},
        {type="item", name="ore-lead", amount=5},
      },
      results = {
        {type="item", name="grade-1-lead", amount=2},
      },
    },
    ["lead-plate-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-2-tin", amount=5},
      },
      results = {
        {type="item", name="lead-plate", amount=10},
      },
    },
    ["grade-1-nickel"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.04558476625233,
      ingredients = {
        {type="item", name="ore-nickel", amount=5},
      },
      results = {
        {type="item", name="grade-1-nickel", amount=1},
        {type="item", name="stone", amount=1},
      },
    },
    ["nickel-plate-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="coal", amount=5},
        {type="item", name="ore-nickel", amount=6},
      },
      results = {
        {type="item", name="nickel-plate", amount=2},
      },
    },
    ["grade-1-ti"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.0239232185299194,
      ingredients = {
        {type="fluid", name="steam", amount=1},
      },
      results = {
        {type="item", name="grade-1-ti", amount=0.0239232185299194},
        {type="item", name="grade-2-ti", amount=0.0119616092649597},
      },
    },
    ["grade-2-ti-crush"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 0.960061056294135,
      ingredients = {
        {type="item", name="grade-2-ti", amount=1},
      },
      results = {
        {type="item", name="grade-1-ti", amount=0.476337711275988},
        {type="item", name="stone", amount=1},
      },
    },
    ["grade-3-ti"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="grade-2-ti", amount=5},
      },
      results = {
        {type="item", name="grade-3-ti", amount=4},
        {type="item", name="ti-rejects", amount=2},
      },
    },
    ["ti-rejects-recrush"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3.27958118991277,
      ingredients = {
        {type="item", name="grade-1-ti", amount=20},
      },
      results = {
        {type="item", name="grade-3-ti", amount=1},
        {type="item", name="gravel", amount=3},
      },
    },
    ["titanium-plate-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.7,
      ingredients = {
        {type="item", name="chromite-sand", amount=1},
        {type="item", name="clay", amount=4},
        {type="item", name="grade-1-ti", amount=11},
        {type="item", name="sodium-hydroxide", amount=19},
      },
      results = {
        {type="item", name="titanium-plate", amount=17},
      },
    },
    ["grade-1-tin"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="ore-nickel", amount=5},
        {type="item", name="ore-tin", amount=3},
      },
      results = {
        {type="item", name="grade-1-tin", amount=2},
        {type="item", name="grade-2-tin", amount=1},
      },
    },
    ["tin-plate-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-2-tin", amount=7},
      },
      results = {
        {type="item", name="tin-plate", amount=10},
      },
    },
    ["grade-2-crush-tin"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="pressured-water", amount=408},
        {type="item", name="grade-2-ti", amount=1},
      },
      results = {
        {type="item", name="grade-1-tin", amount=1},
        {type="item", name="stone", amount=2},
      },
    },
    ["grade-1-zinc"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.98509769394661,
      ingredients = {
        {type="item", name="iron-gear-wheel", amount=1},
        {type="item", name="ore-aluminium", amount=10},
      },
      results = {
        {type="item", name="grade-1-zinc", amount=2},
        {type="item", name="soil", amount=1},
        {type="item", name="stone", amount=1},
      },
    },
    ["grade-2-zinc"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="grade-1-zinc", amount=2},
        {type="item", name="wood-seeds", amount=8},
      },
      results = {
        {type="item", name="grade-2-zinc", amount=4},
        {type="item", name="sand", amount=1},
      },
    },
    ["zinc-plate-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.7,
      ingredients = {
        {type="item", name="brain", amount=5},
        {type="item", name="grade-1-zinc", amount=16},
        {type="item", name="sb-grade-01", amount=3},
      },
      results = {
        {type="item", name="zinc-plate", amount=51},
      },
    },
    ["grenade"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ceramic", amount=3},
        {type="item", name="limestone", amount=90},
      },
      results = {
        {type="item", name="grenade", amount=1},
      },
    },
    ["guts-to-chlorine"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 0.42,
      ingredients = {
        {type="item", name="bones", amount=2},
      },
      results = {
        {type="fluid", name="chlorine", amount=42},
      },
    },
    ["phytoplankton"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.9,
      ingredients = {
        {type="fluid", name="pressured-water", amount=319},
        {type="item", name="grade-1-tin", amount=1},
      },
      results = {
        {type="fluid", name="phytoplankton", amount=9},
      },
    },
    ["piercing-rounds-magazine"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=5},
        {type="item", name="shotgun-shell", amount=6},
      },
      results = {
        {type="item", name="piercing-rounds-magazine", amount=2},
      },
    },
    ["py-asphalt"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="capacitor1", amount=5},
        {type="item", name="stone-furnace", amount=3},
      },
      results = {
        {type="item", name="py-asphalt", amount=3},
      },
    },
    ["py-iron-oxide"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coal-dust", amount=9},
        {type="item", name="ore-aluminium", amount=2},
      },
      results = {
        {type="item", name="py-iron-oxide", amount=2},
      },
    },
    ["py-limestone"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="pressured-air", amount=1725},
        {type="fluid", name="steam", amount=168},
        {type="item", name="coal", amount=3},
        {type="item", name="gunpowder", amount=2},
        {type="item", name="seaweed", amount=5},
      },
      results = {
        {type="item", name="py-limestone", amount=3},
      },
    },
    ["py-burner"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="concrete", amount=43},
        {type="item", name="pipe", amount=20},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="stone-furnace", amount=7},
      },
      results = {
        {type="item", name="py-burner", amount=1},
      },
    },
    ["py-deposit-basic"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="anthracene-oil-barrel", amount=11},
        {type="item", name="empty-petri-dish", amount=10},
        {type="item", name="iron-chest", amount=3},
        {type="item", name="landfill", amount=32},
        {type="item", name="ore-tin", amount=69},
        {type="item", name="poorman-wood-fence", amount=12},
        {type="item", name="seaweed", amount=1000},
        {type="item", name="stone-furnace", amount=17},
        {type="item", name="vacuum-tube", amount=9},
      },
      results = {
        {type="item", name="py-deposit-basic", amount=2},
      },
    },
    ["py-shed-basic"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="concrete", amount=147},
        {type="item", name="landfill", amount=1},
        {type="item", name="moss", amount=19},
        {type="item", name="pipe", amount=14},
        {type="item", name="small-parts-01", amount=15},
      },
      results = {
        {type="item", name="py-shed-basic", amount=2},
      },
    },
    ["py-storehouse-basic"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="empty-petri-dish", amount=4},
        {type="item", name="landfill", amount=13},
        {type="item", name="ore-tin", amount=69},
        {type="item", name="poorman-wood-fence", amount=37},
      },
      results = {
        {type="item", name="py-storehouse-basic", amount=1},
      },
    },
    ["py-warehouse-basic"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="concrete", amount=82},
        {type="item", name="iron-chest", amount=3},
        {type="item", name="moss", amount=10},
        {type="item", name="pipe", amount=10},
        {type="item", name="refined-concrete", amount=4},
        {type="item", name="small-parts-01", amount=8},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="underground-belt", amount=3},
        {type="item", name="vacuum-tube", amount=48},
      },
      results = {
        {type="item", name="py-warehouse-basic", amount=1},
      },
    },
    ["rail"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="heavy-oil-canister", amount=3},
        {type="item", name="inductor1", amount=4},
        {type="item", name="kerogen", amount=17},
        {type="item", name="light-oil-barrel", amount=1},
        {type="item", name="limestone", amount=8},
        {type="item", name="poorman-wood-fence", amount=6},
        {type="item", name="solder", amount=4},
      },
      results = {
        {type="item", name="rail", amount=6},
      },
    },
    ["rail-signal"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="gun-turret", amount=1},
        {type="item", name="tin-plate", amount=20},
      },
      results = {
        {type="item", name="rail-signal", amount=3},
      },
    },
    ["rail-chain-signal"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-1-tin", amount=2},
        {type="item", name="inductor1", amount=7},
      },
      results = {
        {type="item", name="rail-chain-signal", amount=1},
      },
    },
    ["train-stop"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=18},
        {type="item", name="gun-turret", amount=3},
        {type="item", name="guts", amount=12},
        {type="item", name="small-lamp", amount=6},
        {type="item", name="tinned-cable", amount=22},
      },
      results = {
        {type="item", name="train-stop", amount=2},
      },
    },
    ["sb-grade-01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1.59392782475891,
      ingredients = {
        {type="item", name="grade-2-tin", amount=1},
      },
      results = {
        {type="item", name="iron-oxide", amount=0.473210039488112},
        {type="item", name="sb-grade-01", amount=8},
        {type="item", name="sb-grade-02", amount=5},
        {type="item", name="stone", amount=3},
      },
    },
    ["sb-grade-03"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.24199258260283,
      ingredients = {
        {type="fluid", name="water", amount=209},
        {type="item", name="sb-grade-01", amount=4},
      },
      results = {
        {type="item", name="gravel", amount=4},
        {type="item", name="sb-grade-03", amount=1},
        {type="item", name="sb-grade-04", amount=6},
      },
    },
    ["sb-grade-02"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 5.48359966358284,
      ingredients = {
        {type="item", name="grade-2-tin", amount=3},
        {type="item", name="sb-grade-03", amount=1},
      },
      results = {
        {type="item", name="sb-grade-02", amount=55},
        {type="item", name="stone", amount=2},
      },
    },
    ["sb-grade-04"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="sb-grade-01", amount=38},
      },
      results = {
        {type="item", name="sb-grade-04", amount=4},
      },
    },
    ["steel-furnace"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ceramic", amount=58},
        {type="item", name="copper-plate", amount=3},
        {type="item", name="hazard-concrete", amount=5},
        {type="item", name="lead-plate", amount=2},
        {type="item", name="shotgun-shell", amount=4},
      },
      results = {
        {type="item", name="steel-furnace", amount=1},
      },
    },
    ["storage-chest"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="capacitor1", amount=5},
        {type="item", name="distilator", amount=2},
        {type="item", name="oxygen-barrel", amount=39},
      },
      results = {
        {type="item", name="storage-chest", amount=4},
      },
    },
    ["anemometer-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="inductor1", amount=9},
        {type="item", name="titanium-plate", amount=17},
      },
      results = {
        {type="item", name="anemometer-mk01", amount=1},
      },
    },
    ["blade-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="ceramic", amount=7},
        {type="item", name="ore-aluminium", amount=59},
        {type="item", name="soot", amount=4},
      },
      results = {
        {type="item", name="blade-mk01", amount=2},
      },
    },
    ["brake-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=16},
        {type="item", name="copper-cable", amount=154},
        {type="item", name="fenxsb-alloy", amount=9},
        {type="item", name="lens", amount=1},
        {type="item", name="pbsb-alloy", amount=2},
        {type="item", name="pipe", amount=37},
        {type="item", name="small-lamp", amount=1},
        {type="item", name="sodium-hydroxide", amount=7},
        {type="item", name="steel-plate", amount=5},
        {type="item", name="storage-tank", amount=1},
        {type="item", name="tin-plate", amount=20},
      },
      results = {
        {type="item", name="brake-mk01", amount=2},
      },
    },
    ["electronics-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="electronic-circuit", amount=3},
        {type="item", name="inductor1", amount=6},
        {type="item", name="lime", amount=46},
        {type="item", name="py-tank-4000", amount=1},
        {type="item", name="small-parts-01", amount=11},
      },
      results = {
        {type="item", name="electronics-mk01", amount=1},
      },
    },
    ["shaft-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boron-trioxide", amount=1},
        {type="item", name="fenxsb-alloy", amount=5},
        {type="item", name="inductor1", amount=2},
        {type="item", name="solder", amount=5},
      },
      results = {
        {type="item", name="shaft-mk01", amount=1},
      },
    },
    ["utility-box-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=30},
        {type="item", name="electronic-circuit", amount=3},
        {type="item", name="fiberboard", amount=28},
        {type="item", name="inductor1", amount=6},
        {type="item", name="pipe", amount=7},
        {type="item", name="plastic-bar", amount=6},
        {type="item", name="small-parts-01", amount=91},
        {type="item", name="stone-furnace", amount=32},
      },
      results = {
        {type="item", name="utility-box-mk01", amount=2},
      },
    },
    ["vane-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="clay", amount=69},
        {type="item", name="copper-plate", amount=8},
      },
      results = {
        {type="item", name="vane-mk01", amount=1},
      },
    },
    ["controler-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="distilator", amount=5},
        {type="item", name="nexelit-plate", amount=24},
      },
      results = {
        {type="item", name="controler-mk01", amount=3},
      },
    },
    ["gearbox-mk01"] = {
      mode = "repaired-to-input",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="fish-oil", amount=38},
        {type="item", name="aluminium-plate", amount=51},
        {type="item", name="anemometer-mk01", amount=5},
        {type="item", name="lead-plate", amount=13},
        {type="item", name="nexelit-plate", amount=82},
      },
      results = {
        {type="item", name="gearbox-mk01", amount=2},
      },
    },
    ["nacelle-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=4},
        {type="item", name="arithmetic-combinator", amount=1},
        {type="item", name="belt", amount=16},
        {type="item", name="blade-mk01", amount=8},
        {type="item", name="brake-mk01", amount=4},
        {type="item", name="controler-mk01", amount=3},
        {type="item", name="data-array", amount=1},
        {type="item", name="electronics-mk01", amount=6},
        {type="item", name="gearbox-mk01", amount=7},
        {type="item", name="melamine", amount=44},
        {type="item", name="middle-oil-canister", amount=8},
        {type="item", name="pipe", amount=357},
        {type="item", name="py-science-pack-1", amount=1},
        {type="item", name="rotor-mk01", amount=1},
        {type="item", name="steel-plate", amount=58},
        {type="item", name="storage-tank", amount=2},
        {type="item", name="tower-mk01", amount=2},
        {type="item", name="vitreloy", amount=6},
      },
      results = {
        {type="item", name="nacelle-mk01", amount=2},
      },
    },
    ["tower-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=11},
        {type="item", name="electronic-circuit", amount=6},
        {type="item", name="engine-unit", amount=4},
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="tower-mk01", amount=1},
      },
    },
    ["yaw-drive-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=1},
        {type="item", name="concrete", amount=61},
        {type="item", name="duralumin", amount=8},
        {type="item", name="electric-mining-drill", amount=3},
        {type="item", name="electronic-circuit", amount=3},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="inductor1", amount=6},
        {type="item", name="nexelit-plate", amount=248},
        {type="item", name="seaweed", amount=109},
      },
      results = {
        {type="item", name="yaw-drive-mk01", amount=1},
      },
    },
    ["rotor-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="gearbox-mk01", amount=2},
        {type="item", name="melamine-resin", amount=11},
        {type="item", name="pipe", amount=115},
        {type="item", name="titanium-plate", amount=58},
      },
      results = {
        {type="item", name="rotor-mk01", amount=3},
      },
    },
    ["animal-sample-01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="syngas", amount=266},
        {type="item", name="boron-trioxide", amount=1},
        {type="item", name="chitin", amount=2},
        {type="item", name="nexelit-plate", amount=25},
        {type="item", name="petri-dish-bacteria", amount=3},
        {type="item", name="pressured-air-barrel", amount=2},
        {type="item", name="retrovirus", amount=1},
        {type="item", name="seaweed", amount=17},
      },
      results = {
        {type="item", name="animal-sample-01", amount=1},
      },
    },
    ["bio-sample01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="cyanic-acid", amount=74},
        {type="item", name="aluminium-plate", amount=15},
        {type="item", name="coke", amount=24},
        {type="item", name="iron-stick", amount=3},
        {type="item", name="melamine", amount=4},
        {type="item", name="mukmoux-fat", amount=13},
        {type="item", name="native-flora", amount=12},
        {type="item", name="petri-dish", amount=2},
        {type="item", name="ralesia", amount=9},
        {type="item", name="sb-oxide", amount=1},
        {type="item", name="urea", amount=5},
      },
      results = {
        {type="item", name="bio-sample01", amount=6},
      },
    },
    ["equipment-chassi"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="duralumin", amount=6},
        {type="item", name="fenxsb-alloy", amount=2},
        {type="item", name="inductor1", amount=2},
        {type="item", name="tin-plate", amount=9},
      },
      results = {
        {type="item", name="equipment-chassi", amount=3},
      },
    },
    ["ground-sample01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=930},
        {type="item", name="coal-dust", amount=2},
        {type="item", name="soil", amount=8},
      },
      results = {
        {type="item", name="ground-sample01", amount=11},
      },
    },
    ["rich-clay"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="pressured-water", amount=327},
        {type="item", name="capacitor1", amount=2},
        {type="item", name="coal-dust", amount=8},
        {type="item", name="stone-furnace", amount=6},
      },
      results = {
        {type="item", name="rich-clay", amount=15},
      },
    },
    ["sand-casting"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="creosote", amount=25},
        {type="item", name="limestone", amount=3},
      },
      results = {
        {type="item", name="sand-casting", amount=2},
      },
    },
    ["alien-sample01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="fluid", name="black-liquor", amount=13},
        {type="item", name="bio-sample01", amount=4},
        {type="item", name="fish", amount=1},
        {type="item", name="limestone", amount=57},
      },
      results = {
        {type="item", name="alien-sample01", amount=5},
      },
    },
    ["lab-instrument"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="belt", amount=20},
        {type="item", name="carbolic-oil-barrel", amount=1},
        {type="item", name="distilator", amount=1},
        {type="item", name="equipment-chassi", amount=1},
        {type="item", name="lens", amount=2},
        {type="item", name="offshore-pump", amount=3},
        {type="item", name="pipe", amount=18},
        {type="item", name="pressured-water-barrel", amount=2},
      },
      results = {
        {type="item", name="lab-instrument", amount=3},
      },
    },
    ["grade-1-chromite"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="resistor1", amount=2},
      },
      results = {
        {type="item", name="grade-1-chromite", amount=2},
        {type="item", name="stone", amount=1},
      },
    },
    ["chromium-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=425},
        {type="item", name="chromite-sand", amount=19},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="chromium", amount=5},
      },
    },
    ["tier-0-chromite-sand"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.666666666666667,
      ingredients = {
        {type="item", name="grade-1-copper", amount=1},
      },
      results = {
        {type="item", name="chromite-sand", amount=2},
      },
    },
    ["medium-electric-pole"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="syngas", amount=180},
        {type="item", name="lime", amount=3},
        {type="item", name="nexelit-plate", amount=3},
        {type="item", name="stone", amount=5},
        {type="item", name="tin-plate", amount=3},
      },
      results = {
        {type="item", name="medium-electric-pole", amount=2},
      },
    },
    ["powdered-aluminium"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="ore-zinc", amount=11},
      },
      results = {
        {type="item", name="gravel", amount=1},
        {type="item", name="powdered-aluminium", amount=2},
      },
    },
    ["molten-aluminium-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2.4,
      ingredients = {
        {type="fluid", name="oxygen", amount=322},
        {type="item", name="lime", amount=2},
        {type="item", name="raw-borax", amount=22},
        {type="item", name="refined-hazard-concrete", amount=1},
        {type="item", name="sb-grade-03", amount=2},
      },
      results = {
        {type="fluid", name="molten-aluminium", amount=24},
      },
    },
    ["aluminium-plate-3"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.82,
      ingredients = {
        {type="fluid", name="molten-aluminium", amount=186},
      },
      results = {
        {type="item", name="aluminium-plate", amount=91},
      },
    },
    ["hotair-aluminium-plate-3"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.238095238095238,
      ingredients = {
        {type="fluid", name="molten-aluminium", amount=16},
        {type="fluid", name="molten-iron", amount=11},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="aluminium-plate", amount=15},
      },
    },
    ["crushing-quartz"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 4.92682926829268,
      ingredients = {
        {type="item", name="ore-nickel", amount=6},
        {type="item", name="resistor1", amount=2},
      },
      results = {
        {type="item", name="crushed-quartz", amount=5},
        {type="item", name="stone", amount=2},
      },
    },
    ["sand-classification"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.99838650407978,
      ingredients = {
        {type="item", name="ceramic", amount=8},
        {type="item", name="limestone", amount=11},
      },
      results = {
        {type="item", name="crushed-quartz", amount=0.0943530850900939},
        {type="item", name="gravel", amount=8},
        {type="item", name="iron-oxide", amount=1},
      },
    },
    ["glass-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3.23333333333333,
      ingredients = {
        {type="fluid", name="creosote", amount=33},
        {type="item", name="empty-petri-dish", amount=1},
        {type="item", name="limestone", amount=9},
      },
      results = {
        {type="fluid", name="molten-glass", amount=97},
      },
    },
    ["hotair-molten-glass"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.857142857142857,
      ingredients = {
        {type="fluid", name="molten-glass", amount=48},
        {type="fluid", name="pressured-water", amount=122},
      },
      results = {
        {type="item", name="glass", amount=6},
      },
    },
    ["antimony-drill-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="duralumin", amount=28},
        {type="item", name="lead-plate", amount=12},
        {type="item", name="pipe", amount=114},
        {type="item", name="py-tank-3000", amount=1},
        {type="item", name="steam-engine", amount=16},
      },
      results = {
        {type="item", name="antimony-drill-mk01", amount=1},
      },
    },
    ["centrifuge-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=19},
        {type="item", name="concrete", amount=278},
        {type="item", name="fiberboard", amount=7},
        {type="item", name="gasifier", amount=1},
        {type="item", name="inductor1", amount=53},
        {type="item", name="lab", amount=2},
        {type="item", name="nexelit-plate", amount=419},
        {type="item", name="pipe", amount=97},
        {type="item", name="plastic-bar", amount=42},
        {type="item", name="pump", amount=2},
        {type="item", name="sodium-hydroxide", amount=16},
        {type="item", name="steam-engine", amount=27},
        {type="item", name="tin-plate", amount=7},
        {type="item", name="vane-mk01", amount=7},
      },
      results = {
        {type="item", name="centrifuge-mk01", amount=2},
      },
    },
    ["hawt-turbine-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="py-science-pack-1", amount=36},
        {type="item", name="py-tank-1500", amount=1},
        {type="item", name="ralesia-codex", amount=4},
        {type="item", name="steam-turbine-mk01", amount=1},
        {type="item", name="vrauks-codex", amount=5},
        {type="item", name="yaw-drive-mk01", amount=1},
      },
      results = {
        {type="item", name="hawt-turbine-mk01", amount=2},
      },
    },
    ["py-biomass-powerplant-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=179},
        {type="item", name="bolts", amount=287},
        {type="item", name="capacitor1", amount=1000},
        {type="item", name="copper-cable", amount=68},
        {type="item", name="cottongut-codex", amount=1},
        {type="item", name="duralumin", amount=13},
        {type="item", name="engine-unit", amount=18},
        {type="item", name="inductor1", amount=140},
        {type="item", name="py-science-pack-1", amount=2},
        {type="item", name="small-parts-01", amount=13},
        {type="item", name="titanium-plate", amount=64},
        {type="item", name="washer", amount=6},
      },
      results = {
        {type="item", name="py-biomass-powerplant-mk01", amount=1},
      },
    },
    ["py-oil-powerplant-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=355},
        {type="item", name="automated-factory-mk01", amount=1},
        {type="item", name="bolts", amount=572},
        {type="item", name="capacitor1", amount=1000},
        {type="item", name="controler-mk01", amount=5},
        {type="item", name="cottongut-codex", amount=2},
        {type="item", name="electrolyzer-mk01", amount=3},
        {type="item", name="electronics-mk01", amount=10},
        {type="item", name="engine-unit", amount=13},
        {type="item", name="fiberboard", amount=27},
        {type="item", name="grenade", amount=11},
        {type="item", name="heavy-oil-barrel", amount=6},
        {type="item", name="lab-instrument", amount=1},
        {type="item", name="nexelit-plate", amount=1000},
        {type="item", name="py-gas-vent", amount=6},
        {type="item", name="py-science-pack-1", amount=3},
        {type="item", name="rail", amount=9},
        {type="item", name="sodium-alginate", amount=80},
        {type="item", name="storage-tank", amount=2},
        {type="item", name="titanium-plate", amount=128},
        {type="item", name="washer", amount=1},
      },
      results = {
        {type="item", name="py-oil-powerplant-mk01", amount=2},
      },
    },
    ["steam-turbine-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=1},
        {type="item", name="copper-plate", amount=46},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="fiberboard", amount=94},
        {type="item", name="inserter", amount=1},
        {type="item", name="py-science-pack-1", amount=16},
        {type="item", name="py-tank-7000", amount=3},
        {type="item", name="stone-brick", amount=1000},
        {type="item", name="tower-mk01", amount=2},
        {type="item", name="yaw-drive-mk01", amount=1},
      },
      results = {
        {type="item", name="steam-turbine-mk01", amount=1},
      },
    },
    ["tidal-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="capacitor1", amount=138},
        {type="item", name="concrete", amount=26},
        {type="item", name="controler-mk01", amount=4},
        {type="item", name="flora-collector-mk01", amount=24},
        {type="item", name="fluid-drill-mk01", amount=2},
        {type="item", name="iron-plate", amount=133},
        {type="item", name="lead-plate", amount=133},
        {type="item", name="pbsb-alloy", amount=5},
        {type="item", name="retorter", amount=1},
        {type="item", name="rotor-mk01", amount=1},
        {type="item", name="steam-engine", amount=12},
        {type="item", name="storage-tank", amount=2},
        {type="item", name="tar-canister", amount=36},
        {type="item", name="transport-belt", amount=129},
      },
      results = {
        {type="item", name="tidal-mk01", amount=1},
      },
    },
    ["vawt-turbine-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=1},
        {type="item", name="bones", amount=11},
        {type="item", name="brake-mk01", amount=1},
        {type="item", name="carbon-dioxide-barrel", amount=48},
        {type="item", name="dried-meat", amount=67},
        {type="item", name="duralumin", amount=14},
        {type="item", name="eaf-mk01", amount=2},
        {type="item", name="flask", amount=4},
        {type="item", name="gasoline-canister", amount=2},
        {type="item", name="gearbox-mk01", amount=10},
        {type="item", name="kerosene-canister", amount=61},
        {type="item", name="petri-dish-bacteria", amount=45},
        {type="item", name="pipe", amount=404},
        {type="item", name="pitch-barrel", amount=6},
        {type="item", name="pressured-air-barrel", amount=7},
        {type="item", name="py-tank-3000", amount=2},
        {type="item", name="rail", amount=36},
        {type="item", name="shotgun", amount=6},
        {type="item", name="stopper", amount=67},
        {type="item", name="tower-mk01", amount=4},
        {type="item", name="train-stop", amount=3},
        {type="item", name="vrauks-codex", amount=1},
      },
      results = {
        {type="item", name="vawt-turbine-mk01", amount=2},
      },
    },
    ["py-coal-powerplant-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=3},
        {type="item", name="automated-factory-mk01", amount=1},
        {type="item", name="burner-mining-drill", amount=103},
        {type="item", name="duralumin", amount=184},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="fiberboard", amount=220},
        {type="item", name="inductor1", amount=805},
        {type="item", name="pbsb-alloy", amount=112},
        {type="item", name="py-science-pack-1", amount=37},
        {type="item", name="py-tank-7000", amount=7},
        {type="item", name="soil-extractor-mk01", amount=6},
        {type="item", name="steam-engine", amount=22},
        {type="item", name="stone-brick", amount=1000},
        {type="item", name="stopper", amount=78},
        {type="item", name="tower-mk01", amount=2},
        {type="item", name="yaw-drive-mk01", amount=2},
      },
      results = {
        {type="item", name="py-coal-powerplant-mk01", amount=2},
      },
    },
    ["arithmetic-combinator"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-stick", amount=9},
        {type="item", name="naphthalene-oil-barrel", amount=4},
        {type="item", name="py-overflow-valve", amount=4},
      },
      results = {
        {type="item", name="arithmetic-combinator", amount=1},
      },
    },
    ["constant-combinator"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="acetylene-canister", amount=1},
        {type="item", name="chromite-sand", amount=28},
        {type="item", name="hydrogen-barrel", amount=3},
        {type="item", name="ore-lead", amount=9},
        {type="item", name="stopper", amount=4},
        {type="item", name="syngas-canister", amount=6},
      },
      results = {
        {type="item", name="constant-combinator", amount=2},
      },
    },
    ["decider-combinator"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="hpf", amount=2},
        {type="item", name="steam-engine", amount=5},
      },
      results = {
        {type="item", name="decider-combinator", amount=2},
      },
    },
    ["display-panel"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="duralumin", amount=1},
        {type="item", name="grade-1-tin", amount=2},
        {type="item", name="inductor1", amount=5},
      },
      results = {
        {type="item", name="display-panel", amount=1},
      },
    },
    ["power-switch"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="carbolic-oil-barrel", amount=21},
        {type="item", name="electric-mining-drill", amount=1},
      },
      results = {
        {type="item", name="power-switch", amount=1},
      },
    },
    ["programmable-speaker"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="inductor1", amount=48},
        {type="item", name="iron-stick", amount=7},
        {type="item", name="py-overflow-valve", amount=1},
        {type="item", name="small-lamp", amount=1},
      },
      results = {
        {type="item", name="programmable-speaker", amount=2},
      },
    },
    ["selector-combinator"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="duralumin", amount=27},
        {type="item", name="fawogae-substrate", amount=24},
        {type="item", name="flora-collector-mk01", amount=4},
        {type="item", name="lead-plate", amount=31},
      },
      results = {
        {type="item", name="selector-combinator", amount=1},
      },
    },
    ["fiberboard"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.944444444444444,
      ingredients = {
        {type="fluid", name="hydrogen", amount=264},
        {type="item", name="raw-fiber", amount=5},
        {type="item", name="sodium-hydroxide", amount=3},
        {type="item", name="treated-wood", amount=2},
      },
      results = {
        {type="fluid", name="black-liquor", amount=9},
        {type="fluid", name="tall-oil", amount=14},
        {type="item", name="fiberboard", amount=4},
      },
    },
    ["urea-decomposition"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.3,
      ingredients = {
        {type="fluid", name="water", amount=1115},
        {type="item", name="dried-meat", amount=2},
        {type="item", name="urea", amount=19},
      },
      results = {
        {type="fluid", name="ammonia", amount=39},
        {type="fluid", name="cyanic-acid", amount=39},
      },
    },
    ["black-liquor"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.96,
      ingredients = {
        {type="fluid", name="black-liquor", amount=77},
      },
      results = {
        {type="fluid", name="acetone", amount=48},
        {type="fluid", name="aromatics", amount=96},
      },
    },
    ["cyanic-acid-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.834357674513786,
      ingredients = {
        {type="fluid", name="ammonia", amount=123},
        {type="fluid", name="cyanic-acid", amount=66},
        {type="fluid", name="oxygen", amount=458},
        {type="item", name="coal-dust", amount=3},
      },
      results = {
        {type="fluid", name="cyanic-acid", amount=149},
        {type="fluid", name="hydrogen", amount=74},
      },
    },
    ["melamine"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 0.19970630326876,
      ingredients = {
        {type="fluid", name="cyanic-acid", amount=10},
        {type="fluid", name="steam", amount=100},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=6},
        {type="fluid", name="muddy-sludge", amount=9},
        {type="item", name="melamine", amount=4},
      },
    },
    ["cooling-water"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.175,
      ingredients = {
        {type="fluid", name="hydrogen", amount=91},
        {type="item", name="limestone", amount=4},
      },
      results = {
        {type="fluid", name="water", amount=470},
      },
    },
    ["flue-gas-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 0.313333333333333,
      ingredients = {
        {type="item", name="biomass", amount=3},
      },
      results = {
        {type="fluid", name="flue-gas", amount=47},
      },
    },
    ["flue-gas-3"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.01,
      ingredients = {
        {type="fluid", name="hot-air", amount=20},
        {type="item", name="limestone", amount=1},
        {type="item", name="raw-coal", amount=7},
      },
      results = {
        {type="fluid", name="flue-gas", amount=202},
      },
    },
    ["cracker-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=1},
        {type="item", name="burner-mining-drill", amount=2},
        {type="item", name="concrete", amount=8},
        {type="item", name="condensates-canister", amount=1},
        {type="item", name="fish", amount=1},
        {type="item", name="pcb1", amount=15},
        {type="item", name="pipe", amount=21},
        {type="item", name="resistor1", amount=128},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="tailings-dust", amount=22},
        {type="item", name="titanium-plate", amount=7},
        {type="item", name="washer", amount=1},
      },
      results = {
        {type="item", name="cracker-mk01", amount=1},
      },
    },
    ["heavy-oil-refinery-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ceramic", amount=16},
        {type="item", name="inductor1", amount=174},
        {type="item", name="pipe", amount=17},
        {type="item", name="plastic-bar", amount=69},
        {type="item", name="small-parts-01", amount=11},
        {type="item", name="steam-engine", amount=11},
        {type="item", name="tar-barrel", amount=7},
        {type="item", name="tin-plate", amount=10},
      },
      results = {
        {type="item", name="heavy-oil-refinery-mk01", amount=1},
      },
    },
    ["gas-refinery-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bolts", amount=56},
        {type="item", name="concrete", amount=111},
        {type="item", name="distilator", amount=2},
        {type="item", name="electronic-circuit", amount=11},
        {type="item", name="glassworks-mk01", amount=1},
        {type="item", name="lead-plate", amount=15},
        {type="item", name="pbsb-alloy", amount=91},
        {type="item", name="pipe", amount=23},
        {type="item", name="soil-extractor-mk01", amount=3},
        {type="item", name="steam-engine", amount=2},
        {type="item", name="stone-brick", amount=50},
        {type="item", name="titanium-plate", amount=31},
      },
      results = {
        {type="item", name="gas-refinery-mk01", amount=2},
      },
    },
    ["upgrader-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="copper-plate", amount=196},
        {type="item", name="distilator", amount=1},
        {type="item", name="duralumin", amount=43},
        {type="item", name="evaporator", amount=2},
        {type="item", name="fiberboard", amount=212},
        {type="item", name="nexelit-plate", amount=97},
        {type="item", name="pbsb-alloy", amount=15},
        {type="item", name="plastic-bar", amount=10},
        {type="item", name="rail", amount=3},
        {type="item", name="soil-extractor-mk01", amount=10},
        {type="item", name="stopper", amount=4},
        {type="item", name="vane-mk01", amount=2},
      },
      results = {
        {type="item", name="upgrader-mk01", amount=2},
      },
    },
    ["earth-bear-sample"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="py-science-pack-1", amount=209},
        {type="item", name="ralesia-codex", amount=2},
        {type="item", name="vrauks-codex", amount=8},
      },
      results = {
        {type="item", name="earth-bear-sample", amount=3},
      },
    },
    ["earth-flower-sample"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="automation-science-pack", amount=106},
        {type="item", name="cottongut-codex", amount=1},
        {type="item", name="earth-generic-sample", amount=1},
        {type="item", name="py-science-pack-1", amount=3},
      },
      results = {
        {type="item", name="earth-flower-sample", amount=1},
      },
    },
    ["earth-shroom-sample"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="fawogae-codex", amount=2},
        {type="item", name="py-science-pack-1", amount=124},
        {type="item", name="ralesia-codex", amount=2},
      },
      results = {
        {type="item", name="earth-shroom-sample", amount=3},
      },
    },
    ["earth-mouse-sample"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="fawogae-codex", amount=2},
        {type="item", name="py-science-pack-1", amount=63},
        {type="item", name="py-tank-9000", amount=3},
      },
      results = {
        {type="item", name="earth-mouse-sample", amount=2},
      },
    },
    ["molten-iron-05"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.7,
      ingredients = {
        {type="fluid", name="hydrogen", amount=93},
        {type="item", name="iron-ore", amount=5},
        {type="item", name="limestone", amount=3},
      },
      results = {
        {type="fluid", name="molten-iron", amount=7},
      },
    },
    ["hotair-iron-plate-1"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.64,
      ingredients = {
        {type="fluid", name="molten-iron", amount=169},
        {type="item", name="graphite", amount=1},
        {type="item", name="limestone", amount=4},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="iron-plate", amount=123},
      },
    },
    ["iron-plate-1"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.116666666666667,
      ingredients = {
        {type="item", name="ceramic", amount=5},
        {type="item", name="graphite", amount=1},
        {type="item", name="limestone", amount=3},
      },
      results = {
        {type="item", name="iron-plate", amount=7},
      },
    },
    ["mechanical-parts-01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=5},
        {type="item", name="belt", amount=21},
        {type="item", name="brake-mk01", amount=2},
        {type="item", name="controler-mk01", amount=4},
        {type="item", name="electronics-mk01", amount=3},
        {type="item", name="pipe", amount=171},
        {type="item", name="steel-plate", amount=29},
      },
      results = {
        {type="item", name="mechanical-parts-01", amount=6},
      },
    },
    ["sb-oxide-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="steam", amount=536},
        {type="item", name="sb-grade-03", amount=5},
      },
      results = {
        {type="item", name="sb-oxide", amount=2},
      },
    },
    ["pbsb-alloy"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="lead-plate", amount=12},
        {type="item", name="lime", amount=7},
        {type="item", name="pipe", amount=16},
        {type="item", name="sb-oxide", amount=2},
      },
      results = {
        {type="item", name="pbsb-alloy", amount=3},
      },
    },
    ["battery-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="cyanic-acid", amount=17},
        {type="item", name="aluminium-plate", amount=4},
        {type="item", name="coke", amount=7},
        {type="item", name="iron-stick", amount=6},
        {type="item", name="melamine", amount=2},
        {type="item", name="sb-oxide", amount=3},
      },
      results = {
        {type="item", name="battery-mk01", amount=1},
      },
    },
    ["accumulator"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="steam-engine", amount=44},
      },
      results = {
        {type="item", name="accumulator", amount=1},
      },
    },
    ["fenxsb-alloy-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="pbsb-alloy", amount=1},
        {type="item", name="pipe", amount=9},
      },
      results = {
        {type="item", name="fenxsb-alloy", amount=3},
      },
    },
    ["vitreloy"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=4},
        {type="item", name="clay", amount=17},
        {type="item", name="copper-cable", amount=16},
        {type="item", name="pbsb-alloy", amount=2},
        {type="item", name="small-lamp", amount=1},
        {type="item", name="tin-plate", amount=2},
      },
      results = {
        {type="item", name="vitreloy", amount=2},
      },
    },
    ["intermetallics"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="boron-trioxide", amount=5},
        {type="item", name="ceramic", amount=13},
        {type="item", name="limestone", amount=137},
        {type="item", name="vitreloy", amount=3},
      },
      results = {
        {type="item", name="intermetallics", amount=4},
      },
    },
    ["ball-mill-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aromatics-barrel", amount=2},
        {type="item", name="ceramic", amount=12},
        {type="item", name="condensates-barrel", amount=2},
        {type="item", name="electronics-mk01", amount=2},
        {type="item", name="grade-1-copper", amount=37},
        {type="item", name="inductor1", amount=97},
        {type="item", name="iron-plate", amount=66},
        {type="item", name="light-oil-canister", amount=2},
        {type="item", name="pressured-air-barrel", amount=33},
        {type="item", name="py-underflow-valve", amount=3},
        {type="item", name="repair-pack", amount=1},
        {type="item", name="sb-oxide", amount=2},
        {type="item", name="titanium-plate", amount=66},
        {type="item", name="vitreloy", amount=4},
      },
      results = {
        {type="item", name="ball-mill-mk01", amount=2},
      },
    },
    ["chemical-plant-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="distilator", amount=3},
        {type="item", name="electronic-circuit", amount=12},
        {type="item", name="lens", amount=39},
        {type="item", name="nexelit-plate", amount=20},
        {type="item", name="pbsb-alloy", amount=16},
      },
      results = {
        {type="item", name="chemical-plant-mk01", amount=2},
      },
    },
    ["classifier"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="duralumin", amount=25},
        {type="item", name="inductor1", amount=212},
        {type="item", name="naphthalene-oil-barrel", amount=3},
        {type="item", name="stone-brick", amount=222},
        {type="item", name="washer", amount=1},
      },
      results = {
        {type="item", name="classifier", amount=2},
      },
    },
    ["rectisol"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ash", amount=27},
        {type="item", name="burner-mining-drill", amount=7},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="fenxsb-alloy", amount=29},
        {type="item", name="graphite", amount=237},
        {type="item", name="inductor1", amount=9},
        {type="item", name="petri-dish-bacteria", amount=3},
        {type="item", name="pipe", amount=8},
        {type="item", name="py-tank-7000", amount=1},
        {type="item", name="sap-extractor-mk01", amount=1},
        {type="item", name="vitreloy", amount=1},
      },
      results = {
        {type="item", name="rectisol", amount=1},
      },
    },
    ["automated-factory-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="brake-mk01", amount=1},
        {type="item", name="copper-plate", amount=101},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="gearbox-mk01", amount=5},
        {type="item", name="inserter", amount=6},
        {type="item", name="intermetallics", amount=5},
      },
      results = {
        {type="item", name="automated-factory-mk01", amount=2},
      },
    },
    ["fluid-drill-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="ceramic", amount=167},
        {type="item", name="diborane-barrel", amount=4},
        {type="item", name="duralumin", amount=34},
        {type="item", name="lead-plate", amount=15},
        {type="item", name="pipe", amount=141},
        {type="item", name="py-iron-oxide", amount=43},
        {type="item", name="py-science-pack-1", amount=4},
        {type="item", name="repair-pack", amount=8},
        {type="item", name="soil-extractor-mk01", amount=3},
        {type="item", name="splitter", amount=3},
        {type="item", name="steam-engine", amount=6},
      },
      results = {
        {type="item", name="fluid-drill-mk02", amount=2},
      },
    },
    ["bof-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=1},
        {type="item", name="concrete", amount=17},
        {type="item", name="fish", amount=1},
        {type="item", name="resistor1", amount=215},
        {type="item", name="steam-engine", amount=2},
      },
      results = {
        {type="item", name="bof-mk01", amount=1},
      },
    },
    ["casting-unit-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="anthracene-oil-barrel", amount=5},
        {type="item", name="burner-mining-drill", amount=3},
        {type="item", name="creamy-latex-barrel", amount=2},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="lab", amount=2},
        {type="item", name="light-oil-barrel", amount=5},
        {type="item", name="log", amount=229},
        {type="item", name="petri-dish-bacteria", amount=39},
        {type="item", name="pump", amount=2},
        {type="item", name="steel-plate", amount=30},
        {type="item", name="syngas-barrel", amount=9},
        {type="item", name="tar-processing-unit", amount=1},
        {type="item", name="zinc-plate", amount=19},
      },
      results = {
        {type="item", name="casting-unit-mk01", amount=3},
      },
    },
    ["eaf-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=2},
        {type="item", name="engine-unit", amount=8},
        {type="item", name="inductor1", amount=163},
        {type="item", name="pipe", amount=143},
        {type="item", name="quenching-tower", amount=1},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="stone-brick", amount=127},
        {type="item", name="titanium-plate", amount=12},
        {type="item", name="transport-belt", amount=23},
        {type="item", name="washer", amount=1},
      },
      results = {
        {type="item", name="eaf-mk01", amount=2},
      },
    },
    ["hydroclassifier-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=50},
        {type="item", name="distilator", amount=2},
        {type="item", name="duralumin", amount=36},
        {type="item", name="fiberboard", amount=66},
        {type="item", name="inductor1", amount=20},
        {type="item", name="soil-extractor-mk01", amount=7},
        {type="item", name="stopper", amount=2},
      },
      results = {
        {type="item", name="hydroclassifier-mk01", amount=1},
      },
    },
    ["impact-crusher-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="acidgas-barrel", amount=2},
        {type="item", name="distilator", amount=1},
        {type="item", name="duralumin", amount=31},
        {type="item", name="fiberboard", amount=103},
        {type="item", name="gun-turret", amount=1},
        {type="item", name="inductor1", amount=4},
        {type="item", name="lab", amount=5},
        {type="item", name="nexelit-plate", amount=123},
        {type="item", name="plastic-bar", amount=79},
        {type="item", name="pump", amount=3},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="washer", amount=3},
      },
      results = {
        {type="item", name="impact-crusher-mk01", amount=2},
      },
    },
    ["scrubber-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="acidgas-barrel", amount=2},
        {type="item", name="ash", amount=9},
        {type="item", name="distilator", amount=1},
        {type="item", name="fiberboard", amount=34},
        {type="item", name="inductor1", amount=2},
        {type="item", name="lab", amount=2},
        {type="item", name="landfill", amount=1},
        {type="item", name="pipe", amount=24},
        {type="item", name="poorman-wood-fence", amount=6},
        {type="item", name="tin-plate", amount=3},
        {type="item", name="vitreloy", amount=14},
      },
      results = {
        {type="item", name="scrubber-mk01", amount=1},
      },
    },
    ["flotation-cell-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="duralumin", amount=38},
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="inductor1", amount=34},
        {type="item", name="nexelit-plate", amount=58},
        {type="item", name="offshore-pump", amount=7},
        {type="item", name="transport-belt", amount=17},
      },
      results = {
        {type="item", name="flotation-cell-mk01", amount=1},
      },
    },
    ["cargo-wagon"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="advanced-foundry-mk01", amount=2},
        {type="item", name="agar", amount=19},
        {type="item", name="aluminium-plate", amount=502},
        {type="item", name="auog-codex", amount=1},
        {type="item", name="fenxsb-alloy", amount=61},
        {type="item", name="glass", amount=23},
        {type="item", name="lab-instrument", amount=1},
        {type="item", name="pitch-barrel", amount=10},
        {type="item", name="polybutadiene-barrel", amount=1},
        {type="item", name="py-burner", amount=1},
        {type="item", name="scrude-canister", amount=33},
        {type="item", name="shotgun", amount=10},
        {type="item", name="tin-plate", amount=11},
        {type="item", name="wooden-chest", amount=31},
      },
      results = {
        {type="item", name="cargo-wagon", amount=2},
      },
    },
    ["fluid-wagon"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="carbon-dioxide-barrel", amount=31},
        {type="item", name="duralumin", amount=27},
        {type="item", name="gasoline-canister", amount=5},
        {type="item", name="gearbox-mk01", amount=3},
        {type="item", name="petri-dish-bacteria", amount=89},
        {type="item", name="py-tank-3000", amount=4},
        {type="item", name="stopper", amount=43},
        {type="item", name="train-stop", amount=2},
      },
      results = {
        {type="item", name="fluid-wagon", amount=2},
      },
    },
    ["locomotive"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="aromatics-barrel", amount=4},
        {type="item", name="brake-mk01", amount=2},
        {type="item", name="carbon-dioxide-barrel", amount=77},
        {type="item", name="copper-plate", amount=405},
        {type="item", name="duralumin", amount=31},
        {type="item", name="electronic-circuit", amount=13},
        {type="item", name="equipment-chassi", amount=4},
        {type="item", name="fenxsb-alloy", amount=47},
        {type="item", name="flotation-cell-mk01", amount=3},
        {type="item", name="gasifier", amount=3},
        {type="item", name="gearbox-mk01", amount=2},
        {type="item", name="inductor1", amount=9},
        {type="item", name="inserter", amount=9},
        {type="item", name="intermetallics", amount=2},
        {type="item", name="lab", amount=3},
        {type="item", name="middle-oil-canister", amount=11},
        {type="item", name="storage-tank", amount=2},
        {type="item", name="utility-box-mk01", amount=1},
      },
      results = {
        {type="item", name="locomotive", amount=3},
      },
    },
    ["cooling-tower-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="concrete", amount=69},
        {type="item", name="inductor1", amount=40},
        {type="item", name="lab", amount=1},
        {type="item", name="pipe", amount=9},
        {type="item", name="steam-engine", amount=7},
      },
      results = {
        {type="item", name="cooling-tower-mk01", amount=1},
      },
    },
    ["fawogae-plantation-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="copper-cable", amount=65},
        {type="item", name="electric-mining-drill", amount=3},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="glass", amount=166},
        {type="item", name="hpf", amount=5},
        {type="item", name="inductor1", amount=3},
        {type="item", name="lime", amount=25},
        {type="item", name="nexelit-plate", amount=19},
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="fawogae-plantation-mk01", amount=2},
      },
    },
    ["prandium-lab-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="ash", amount=121},
        {type="item", name="concrete", amount=33},
        {type="item", name="copper-plate", amount=174},
        {type="item", name="duralumin", amount=5},
        {type="item", name="electronics-mk01", amount=3},
        {type="item", name="inductor1", amount=13},
        {type="item", name="lead-plate", amount=26},
        {type="item", name="lens", amount=4},
        {type="item", name="nexelit-plate", amount=39},
        {type="item", name="pbsb-alloy", amount=2},
        {type="item", name="pipe", amount=36},
        {type="item", name="poorman-wood-fence", amount=80},
        {type="item", name="rail-chain-signal", amount=2},
        {type="item", name="steam-engine", amount=12},
        {type="item", name="tin-plate", amount=36},
        {type="item", name="vitreloy", amount=15},
      },
      results = {
        {type="item", name="prandium-lab-mk01", amount=2},
      },
    },
    ["ralesia-plantation-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=29},
        {type="item", name="ash", amount=278},
        {type="item", name="burner-mining-drill", amount=6},
        {type="item", name="concrete", amount=73},
        {type="item", name="electronics-mk01", amount=3},
        {type="item", name="fenxsb-alloy", amount=6},
        {type="item", name="gravel", amount=35},
        {type="item", name="lens", amount=26},
        {type="item", name="pipe", amount=84},
        {type="item", name="poorman-wood-fence", amount=72},
        {type="item", name="tin-plate", amount=33},
      },
      results = {
        {type="item", name="ralesia-plantation-mk01", amount=1},
      },
    },
    ["fish-farm-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=210},
        {type="item", name="empty-planter-box", amount=11},
        {type="item", name="engine-unit", amount=4},
        {type="item", name="fiberboard", amount=30},
        {type="item", name="grade-2-tin", amount=52},
        {type="item", name="heavy-oil-barrel", amount=16},
        {type="item", name="inductor1", amount=148},
        {type="item", name="pipe", amount=33},
        {type="item", name="py-science-pack-1", amount=7},
        {type="item", name="rail", amount=25},
        {type="item", name="rich-clay", amount=49},
        {type="item", name="small-parts-01", amount=16},
        {type="item", name="vitreloy", amount=2},
        {type="item", name="vrauks-codex", amount=1},
      },
      results = {
        {type="item", name="fish-farm-mk01", amount=1},
      },
    },
    ["heavy-armor"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=127},
        {type="item", name="anemometer-mk01", amount=1},
        {type="item", name="duralumin", amount=44},
        {type="item", name="fiberboard", amount=98},
        {type="item", name="hpf", amount=2},
        {type="item", name="intermetallics", amount=7},
        {type="item", name="pbsb-alloy", amount=2},
        {type="item", name="py-tank-6500", amount=1},
        {type="item", name="steam-engine", amount=2},
        {type="item", name="tin-plate", amount=29},
        {type="item", name="tinned-cable", amount=74},
        {type="item", name="titanium-plate", amount=22},
        {type="item", name="transport-belt", amount=50},
      },
      results = {
        {type="item", name="heavy-armor", amount=2},
      },
    },
    ["mixer-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="duralumin", amount=16},
        {type="item", name="hpf", amount=2},
        {type="item", name="inductor1", amount=2},
        {type="item", name="py-tank-6500", amount=1},
        {type="item", name="tinned-cable", amount=71},
        {type="item", name="titanium-plate", amount=65},
        {type="item", name="transport-belt", amount=48},
      },
      results = {
        {type="item", name="mixer-mk01", amount=1},
      },
    },
    ["py-heat-exchanger"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="concrete", amount=82},
        {type="item", name="engine-unit", amount=6},
        {type="item", name="gasifier", amount=13},
        {type="item", name="inductor1", amount=69},
        {type="item", name="nexelit-plate", amount=45},
        {type="item", name="py-tank-9000", amount=1},
        {type="item", name="steam-engine", amount=13},
      },
      results = {
        {type="item", name="py-heat-exchanger", amount=2},
      },
    },
    ["secondary-crusher-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=126},
        {type="item", name="burner-mining-drill", amount=3},
        {type="item", name="duralumin", amount=22},
        {type="item", name="graphite", amount=338},
        {type="item", name="titanium-plate", amount=226},
      },
      results = {
        {type="item", name="secondary-crusher-mk01", amount=1},
      },
    },
    ["atomizer-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="aluminium-plate", amount=32},
        {type="item", name="aromatics-canister", amount=3},
        {type="item", name="distilator", amount=1},
        {type="item", name="duralumin", amount=15},
        {type="item", name="electronic-circuit", amount=14},
        {type="item", name="empty-petri-dish", amount=30},
        {type="item", name="fenxsb-alloy", amount=87},
        {type="item", name="glassworks-mk01", amount=1},
        {type="item", name="gravel", amount=532},
        {type="item", name="lead-plate", amount=83},
        {type="item", name="lens", amount=13},
        {type="item", name="nexelit-plate", amount=73},
        {type="item", name="pbsb-alloy", amount=44},
        {type="item", name="steel-plate", amount=11},
        {type="item", name="stopper", amount=29},
        {type="item", name="tall-oil-barrel", amount=2},
      },
      results = {
        {type="item", name="atomizer-mk01", amount=3},
      },
    },
    ["bio-reactor-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="chemical-plant-mk01", amount=4},
        {type="item", name="concrete", amount=102},
        {type="item", name="engine-unit", amount=9},
        {type="item", name="gasifier", amount=2},
        {type="item", name="inductor1", amount=34},
        {type="item", name="iron-plate", amount=815},
        {type="item", name="lead-plate", amount=39},
        {type="item", name="pbsb-alloy", amount=11},
        {type="item", name="pipe", amount=302},
        {type="item", name="steam-engine", amount=6},
        {type="item", name="titanium-plate", amount=61},
      },
      results = {
        {type="item", name="bio-reactor-mk01", amount=3},
      },
    },
    ["plankton-farm"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=6},
        {type="item", name="bolts", amount=23},
        {type="item", name="capacitor1", amount=55},
        {type="item", name="concrete", amount=166},
        {type="item", name="copper-plate", amount=4},
        {type="item", name="duralumin", amount=4},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="lab", amount=2},
        {type="item", name="lead-plate", amount=10},
        {type="item", name="nexelit-plate", amount=6},
        {type="item", name="pbsb-alloy", amount=5},
        {type="item", name="pump", amount=1},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="titanium-plate", amount=5},
        {type="item", name="transport-belt", amount=23},
        {type="item", name="vitreloy", amount=5},
      },
      results = {
        {type="item", name="plankton-farm", amount=1},
      },
    },
    ["spore-collector-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="aluminium-plate", amount=81},
        {type="item", name="crushed-quartz", amount=25},
        {type="item", name="engine-unit", amount=7},
        {type="item", name="graphite", amount=38},
        {type="item", name="inductor1", amount=424},
        {type="item", name="intermetallics", amount=11},
        {type="item", name="nexelit-plate", amount=85},
        {type="item", name="pipe", amount=59},
        {type="item", name="plastic-bar", amount=30},
        {type="item", name="steam-engine", amount=5},
        {type="item", name="tar-barrel", amount=3},
        {type="item", name="tar-processing-unit", amount=1},
        {type="item", name="titanium-plate", amount=25},
        {type="item", name="washer", amount=2},
      },
      results = {
        {type="item", name="spore-collector-mk01", amount=3},
      },
    },
    ["compost-plant-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="empty-planter-box", amount=64},
        {type="item", name="fiberboard", amount=57},
        {type="item", name="grade-2-tin", amount=310},
        {type="item", name="heavy-oil-barrel", amount=12},
        {type="item", name="rail", amount=48},
        {type="item", name="rich-clay", amount=37},
        {type="item", name="vrauks-codex", amount=1},
      },
      results = {
        {type="item", name="compost-plant-mk01", amount=1},
      },
    },
    ["oil-boiler-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=6},
        {type="item", name="creamy-latex-barrel", amount=14},
        {type="item", name="engine-unit", amount=15},
        {type="item", name="petri-dish-bacteria", amount=80},
        {type="item", name="syngas-barrel", amount=7},
        {type="item", name="tar-processing-unit", amount=1},
      },
      results = {
        {type="item", name="oil-boiler-mk01", amount=2},
      },
    },
    ["py-electric-boiler"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="agar", amount=12},
        {type="item", name="distilator", amount=4},
        {type="item", name="offshore-pump", amount=18},
        {type="item", name="pressured-water-barrel", amount=32},
        {type="item", name="py-tank-10000", amount=5},
        {type="item", name="steam-engine", amount=5},
      },
      results = {
        {type="item", name="py-electric-boiler", amount=4},
      },
    },
    ["rhe"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ash", amount=3},
        {type="item", name="ceramic", amount=5},
        {type="item", name="fiberboard", amount=10},
        {type="item", name="inductor1", amount=19},
        {type="item", name="py-gas-vent", amount=1},
        {type="item", name="stone-furnace", amount=31},
        {type="item", name="stopper", amount=1},
        {type="item", name="titanium-plate", amount=11},
      },
      results = {
        {type="item", name="rhe", amount=1},
      },
    },
    ["personal-roboport-equipment"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="duralumin", amount=75},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="inductor1", amount=8},
        {type="item", name="nexelit-plate", amount=114},
        {type="item", name="pipe", amount=91},
        {type="item", name="soil-extractor-mk01", amount=3},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="transport-belt", amount=15},
        {type="item", name="vitreloy", amount=9},
      },
      results = {
        {type="item", name="personal-roboport-equipment", amount=1},
      },
    },
    ["portable-gasoline-generator"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=1},
        {type="item", name="duralumin", amount=6},
        {type="item", name="graphite", amount=50},
        {type="item", name="inductor1", amount=3},
        {type="item", name="light-oil-barrel", amount=27},
        {type="item", name="methane-canister", amount=13},
        {type="item", name="moondrop-greenhouse-mk01", amount=1},
        {type="item", name="vane-mk01", amount=1},
      },
      results = {
        {type="item", name="portable-gasoline-generator", amount=1},
      },
    },
    ["py-recharge-station-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="condensates-barrel", amount=2},
        {type="item", name="electronics-mk01", amount=1},
        {type="item", name="iron-plate", amount=27},
        {type="item", name="pressured-air-barrel", amount=13},
        {type="item", name="py-underflow-valve", amount=10},
      },
      results = {
        {type="item", name="py-recharge-station-mk01", amount=1},
      },
    },
    ["py-roboport-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="brake-mk01", amount=1},
        {type="item", name="crushed-quartz", amount=247},
        {type="item", name="equipment-chassi", amount=11},
        {type="item", name="pressured-air-barrel", amount=3},
        {type="item", name="py-science-pack-1", amount=6},
        {type="item", name="titanium-plate", amount=12},
        {type="item", name="transport-belt", amount=58},
      },
      results = {
        {type="item", name="py-roboport-mk01", amount=2},
      },
    },
    ["py-ze"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boiler", amount=10},
        {type="item", name="capacitor1", amount=25},
        {type="item", name="glass", amount=60},
        {type="item", name="offshore-pump", amount=3},
        {type="item", name="pipe", amount=9},
        {type="item", name="seaweed", amount=12},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="titanium-plate", amount=24},
        {type="item", name="transport-belt", amount=4},
      },
      results = {
        {type="item", name="py-ze", amount=1},
      },
    },
    ["salt-mine"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="capacitor1", amount=338},
        {type="item", name="concrete", amount=86},
        {type="item", name="controler-mk01", amount=1},
        {type="item", name="engine-unit", amount=15},
        {type="item", name="fiberboard", amount=93},
        {type="item", name="flora-collector-mk01", amount=7},
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="lead-plate", amount=119},
        {type="item", name="retorter", amount=1},
        {type="item", name="rotor-mk01", amount=3},
        {type="item", name="soil-extractor-mk01", amount=13},
        {type="item", name="steam-engine", amount=13},
        {type="item", name="storage-tank", amount=5},
        {type="item", name="tar-canister", amount=34},
        {type="item", name="tar-processing-unit", amount=2},
        {type="item", name="transport-belt", amount=124},
        {type="item", name="yaw-drive-mk01", amount=6},
      },
      results = {
        {type="item", name="salt-mine", amount=2},
      },
    },
    ["dino-dig-site"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=5},
        {type="item", name="ash", amount=168},
        {type="item", name="ceramic", amount=271},
        {type="item", name="concrete", amount=41},
        {type="item", name="distilator", amount=1},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="glass", amount=236},
        {type="item", name="inductor1", amount=63},
        {type="item", name="iron-chest", amount=4},
        {type="item", name="pipe", amount=26},
        {type="item", name="py-gas-vent", amount=3},
        {type="item", name="small-parts-01", amount=5},
        {type="item", name="stone-brick", amount=355},
        {type="item", name="stone-wall", amount=12},
        {type="item", name="tin-plate", amount=41},
      },
      results = {
        {type="item", name="dino-dig-site", amount=1},
      },
    },
    ["generator-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=18},
        {type="item", name="ash", amount=68},
        {type="item", name="carbon-dioxide-barrel", amount=3},
        {type="item", name="ceramic", amount=282},
        {type="item", name="distilator", amount=2},
        {type="item", name="iron-chest", amount=4},
        {type="item", name="nexelit-plate", amount=67},
        {type="item", name="pipe", amount=11},
        {type="item", name="py-gas-vent", amount=9},
        {type="item", name="scrude-canister", amount=1},
        {type="item", name="stone-wall", amount=40},
      },
      results = {
        {type="item", name="generator-1", amount=2},
      },
    },
    ["pyphoon-bay"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="advanced-foundry-mk01", amount=1},
        {type="item", name="aluminium-plate", amount=281},
        {type="item", name="auog-codex", amount=1},
        {type="item", name="fenxsb-alloy", amount=1},
        {type="item", name="pipe", amount=68},
        {type="item", name="pipe-to-ground", amount=8},
        {type="item", name="scrude-canister", amount=18},
        {type="item", name="stopper", amount=1},
        {type="item", name="wooden-chest", amount=18},
      },
      results = {
        {type="item", name="pyphoon-bay", amount=1},
      },
    },
    ["belt"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="agar", amount=10},
      },
      results = {
        {type="item", name="belt", amount=2},
      },
    },
    ["polybutadiene"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.82951110032992,
      ingredients = {
        {type="fluid", name="hydrogen", amount=283},
        {type="fluid", name="scrude", amount=223},
        {type="item", name="clean-nexelit", amount=7},
        {type="item", name="titanium-plate", amount=1},
      },
      results = {
        {type="fluid", name="polybutadiene", amount=83},
        {type="fluid", name="steam", amount=828},
      },
    },
    ["long-handed-inserter"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="acetylene-canister", amount=1},
        {type="item", name="chromite-sand", amount=67},
        {type="item", name="display-panel", amount=5},
        {type="item", name="hydrogen-barrel", amount=6},
        {type="item", name="sb-oxide", amount=2},
      },
      results = {
        {type="item", name="long-handed-inserter", amount=3},
      },
    },
    ["carbon-black"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=1983},
      },
      results = {
        {type="item", name="carbon-black", amount=4},
      },
    },
    ["engine-unit-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="belt", amount=3},
        {type="item", name="bolts", amount=16},
        {type="item", name="inductor1", amount=20},
        {type="item", name="nexelit-plate", amount=39},
        {type="item", name="steam-engine", amount=2},
        {type="item", name="titanium-plate", amount=12},
      },
      results = {
        {type="item", name="engine-unit", amount=3},
      },
    },
    ["transport-belt-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.933333333333333,
      ingredients = {
        {type="item", name="agar", amount=1},
        {type="item", name="petri-dish", amount=3},
        {type="item", name="pipe", amount=7},
        {type="item", name="rubber", amount=2},
      },
      results = {
        {type="item", name="transport-belt", amount=14},
      },
    },
    ["rubber-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 4,
      ingredients = {
        {type="fluid", name="steam", amount=4000},
        {type="item", name="carbon-black", amount=4},
        {type="item", name="latex", amount=5},
      },
      results = {
        {type="item", name="rubber", amount=4},
      },
    },
    ["depolymerized-organics"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.64,
      ingredients = {
        {type="fluid", name="acetylene", amount=1471},
        {type="fluid", name="hydrogen", amount=2799},
        {type="fluid", name="liquid-manure", amount=97},
        {type="fluid", name="oxygen", amount=4000},
        {type="item", name="manure", amount=2},
      },
      results = {
        {type="fluid", name="depolymerized-organics", amount=164},
      },
    },
    ["subcritical-water-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.04,
      ingredients = {
        {type="fluid", name="water", amount=298},
        {type="item", name="manure", amount=1},
      },
      results = {
        {type="fluid", name="subcritical-water", amount=52},
      },
    },
    ["electronic-circuit-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="battery-mk01", amount=1},
        {type="item", name="fiberboard", amount=1},
        {type="item", name="formica", amount=3},
        {type="item", name="graphite", amount=12},
        {type="item", name="inductor1", amount=3},
        {type="item", name="lead-plate", amount=14},
        {type="item", name="lime", amount=6},
        {type="item", name="pipe", amount=2},
        {type="item", name="small-parts-01", amount=4},
      },
      results = {
        {type="item", name="electronic-circuit", amount=5},
      },
    },
    ["formica-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="ceramic", amount=24},
        {type="item", name="coal-dust", amount=6},
        {type="item", name="inductor1", amount=4},
      },
      results = {
        {type="item", name="formica", amount=4},
      },
    },
    ["hotair-empty-petri-dish"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=108},
        {type="fluid", name="steam", amount=54},
        {type="item", name="bolts", amount=3},
        {type="item", name="glass", amount=3},
      },
      results = {
        {type="item", name="empty-petri-dish", amount=2},
      },
    },
    ["hotair-flask"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="molten-glass", amount=97},
        {type="item", name="petri-dish", amount=8},
      },
      results = {
        {type="item", name="flask", amount=3},
      },
    },
    ["stopper-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="agar", amount=4},
        {type="item", name="belt", amount=2},
      },
      results = {
        {type="item", name="stopper", amount=3},
      },
    },
    ["meat-to-tin"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 0.533333333333333,
      ingredients = {
        {type="item", name="guts", amount=1},
      },
      results = {
        {type="item", name="ore-tin", amount=8},
      },
    },
    ["skin-to-lead"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="item", name="bones", amount=10},
        {type="item", name="cellulose", amount=1},
        {type="item", name="sb-grade-03", amount=1},
      },
      results = {
        {type="item", name="ore-lead", amount=6},
      },
    },
    ["powdered-ralesia-seeds"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="coarse", amount=3},
        {type="item", name="ralesia", amount=11},
        {type="item", name="ralesia-seeds", amount=9},
      },
      results = {
        {type="item", name="powdered-ralesia-seeds", amount=2},
      },
    },
    ["water-saline"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 0.46,
      ingredients = {
        {type="fluid", name="steam", amount=58},
        {type="item", name="limestone", amount=2},
      },
      results = {
        {type="fluid", name="water-saline", amount=46},
      },
    },
    ["starch"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="cellulose", amount=5},
        {type="item", name="fiberboard", amount=1},
        {type="item", name="powdered-ralesia-seeds", amount=1},
        {type="item", name="raw-fiber", amount=1},
        {type="item", name="wood", amount=3},
      },
      results = {
        {type="item", name="biomass", amount=10},
        {type="item", name="starch", amount=6},
      },
    },
    ["aerial-blimp-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="creamy-latex", amount=3017},
        {type="item", name="anemometer-mk01", amount=3},
        {type="item", name="distilator", amount=11},
        {type="item", name="duralumin", amount=62},
        {type="item", name="fluid-drill-mk01", amount=41},
        {type="item", name="gearbox-mk01", amount=1},
        {type="item", name="phytoplankton-barrel", amount=6},
        {type="item", name="resistor1", amount=399},
        {type="item", name="rhe", amount=1},
        {type="item", name="storage-tank", amount=1},
        {type="item", name="titanium-plate", amount=72},
        {type="item", name="yaw-drive-mk01", amount=1},
      },
      results = {
        {type="item", name="aerial-blimp-mk01", amount=2},
      },
    },
    ["blood-to-iron"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="hydrogen", amount=653},
      },
      results = {
        {type="item", name="iron-ore", amount=8},
      },
    },
    ["fawogae-to-iron"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="fawogae-spore", amount=12},
        {type="item", name="moondrop", amount=2},
      },
      results = {
        {type="item", name="iron-ore", amount=10},
      },
    },
    ["bone-to-bonemeal-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="item", name="guts", amount=17},
      },
      results = {
        {type="item", name="bonemeal", amount=8},
      },
    },
    ["bones-to-kerogen"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="guts", amount=5},
      },
      results = {
        {type="item", name="kerogen", amount=8},
      },
    },
    ["breed-fish-1"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.3,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=378},
        {type="fluid", name="steam", amount=3063},
        {type="item", name="carbon-black", amount=5},
        {type="item", name="fish-egg", amount=6},
        {type="item", name="latex", amount=1},
        {type="item", name="tinned-cable", amount=5},
      },
      results = {
        {type="fluid", name="waste-water", amount=130},
        {type="item", name="fish", amount=13},
      },
    },
    ["breed-fish-egg-1"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.5161770659338,
      ingredients = {
        {type="fluid", name="boric-acid", amount=691},
        {type="item", name="fish", amount=21},
      },
      results = {
        {type="fluid", name="waste-water", amount=150},
        {type="item", name="fish-egg", amount=38},
      },
    },
    ["py-construction-robot-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="fluid", name="chlorine", amount=698},
        {type="item", name="bio-container", amount=7},
        {type="item", name="brake-mk01", amount=4},
        {type="item", name="ceramic", amount=387},
        {type="item", name="crushed-quartz", amount=324},
        {type="item", name="decider-combinator", amount=1},
        {type="item", name="equipment-chassi", amount=5},
        {type="item", name="lab", amount=2},
        {type="item", name="lead-plate", amount=83},
        {type="item", name="py-science-pack-1", amount=3},
        {type="item", name="scrude-barrel", amount=7},
        {type="item", name="soil-extractor-mk01", amount=2},
        {type="item", name="transport-belt", amount=76},
        {type="item", name="vitreloy", amount=3},
      },
      results = {
        {type="item", name="py-construction-robot-mk01", amount=3},
      },
    },
    ["liquid-manure"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.29,
      ingredients = {
        {type="fluid", name="acetylene", amount=24},
        {type="fluid", name="hydrogen", amount=45},
        {type="fluid", name="oxygen", amount=86},
        {type="item", name="manure", amount=2},
      },
      results = {
        {type="fluid", name="liquid-manure", amount=29},
      },
    },
    ["zogna-bacteria"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.05,
      ingredients = {
        {type="item", name="petri-dish-bacteria", amount=2},
        {type="item", name="small-lamp", amount=1},
        {type="item", name="wood", amount=5},
      },
      results = {
        {type="fluid", name="zogna-bacteria", amount=21},
      },
    },
    ["plasmids"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="empty-petri-dish", amount=3},
        {type="item", name="lab-instrument", amount=1},
        {type="item", name="petri-dish", amount=2},
        {type="item", name="stopper", amount=3},
      },
      results = {
        {type="item", name="plasmids", amount=1},
      },
    },
    ["retrovirus"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="hot-air", amount=94},
        {type="item", name="empty-petri-dish", amount=4},
        {type="item", name="lab-instrument", amount=2},
        {type="item", name="steel-plate", amount=2},
        {type="item", name="stopper", amount=3},
        {type="item", name="vrauks", amount=1},
      },
      results = {
        {type="item", name="retrovirus", amount=2},
      },
    },
    ["cdna"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 4,
      ingredients = {
        {type="fluid", name="syngas", amount=539},
        {type="item", name="barrel-machine-mk01", amount=2},
        {type="item", name="bio-sample", amount=13},
        {type="item", name="boron-trioxide", amount=20},
        {type="item", name="cellulose", amount=4},
        {type="item", name="chitin", amount=10},
        {type="item", name="lab-instrument", amount=1},
        {type="item", name="nexelit-plate", amount=160},
        {type="item", name="petri-dish", amount=24},
        {type="item", name="petri-dish-bacteria", amount=7},
        {type="item", name="plasmids", amount=3},
        {type="item", name="pressured-air-barrel", amount=4},
        {type="item", name="py-shed-basic", amount=2},
        {type="item", name="retrovirus", amount=6},
        {type="item", name="seaweed", amount=273},
        {type="item", name="stopper", amount=8},
      },
      results = {
        {type="item", name="cdna", amount=4},
      },
    },
    ["ralesia-sample"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2.5,
      ingredients = {
        {type="item", name="automation-science-pack", amount=137},
        {type="item", name="cdna", amount=6},
        {type="item", name="cottongut-codex", amount=3},
        {type="item", name="earth-mouse-sample", amount=1},
        {type="item", name="fawogae-codex", amount=3},
        {type="item", name="py-science-pack-1", amount=5},
      },
      results = {
        {type="item", name="ralesia", amount=5},
      },
    },
    ["ralesia-seeds"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.625,
      ingredients = {
        {type="item", name="raw-fiber", amount=2},
      },
      results = {
        {type="item", name="ralesia-seeds", amount=5},
      },
    },
    ["ralesia-1"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.7,
      ingredients = {
        {type="fluid", name="hydrogen", amount=97},
        {type="fluid", name="steam", amount=68},
        {type="item", name="coarse", amount=1},
        {type="item", name="ralesia-seeds", amount=6},
      },
      results = {
        {type="item", name="ralesia", amount=7},
      },
    },
    ["cottongut-codex"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=58},
        {type="item", name="electric-mining-drill", amount=9},
        {type="item", name="graphite", amount=15},
        {type="item", name="inductor1", amount=122},
        {type="item", name="seaweed", amount=55},
        {type="item", name="small-parts-01", amount=8},
        {type="item", name="tin-plate", amount=18},
        {type="item", name="titanium-plate", amount=10},
      },
      results = {
        {type="item", name="cottongut-codex", amount=1},
      },
    },
    ["cottongut-cub-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1.22502890388046,
      ingredients = {
        {type="item", name="cottongut", amount=6},
        {type="item", name="moondrop", amount=2},
        {type="item", name="ralesia", amount=9},
        {type="item", name="seaweed", amount=6},
        {type="item", name="water-barrel", amount=1},
      },
      results = {
        {type="item", name="barrel", amount=4},
        {type="item", name="cottongut-pup", amount=12},
      },
    },
    ["caged-cottongut-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1.64480649758843,
      ingredients = {
        {type="item", name="carbon-dioxide-barrel", amount=3},
        {type="item", name="cocoon", amount=15},
        {type="item", name="cottongut-mk01", amount=2},
        {type="item", name="moondrop", amount=2},
        {type="item", name="ralesia", amount=2},
        {type="item", name="vrauks-food-01", amount=2},
        {type="item", name="water-barrel", amount=1},
        {type="item", name="wood-seeds", amount=4},
      },
      results = {
        {type="item", name="barrel", amount=3},
        {type="item", name="cottongut", amount=10},
      },
    },
    ["cottongut"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bio-sample", amount=27},
        {type="item", name="cdna", amount=11},
        {type="item", name="earth-bear-sample", amount=2},
        {type="item", name="ralesia-codex", amount=2},
        {type="item", name="treated-wood", amount=111},
        {type="item", name="vacuum-tube", amount=69},
      },
      results = {
        {type="item", name="cottongut-mk01", amount=2},
      },
    },
    ["cottongut-food-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="item", name="cellulose", amount=5},
        {type="item", name="ceramic", amount=2},
        {type="item", name="soil", amount=14},
        {type="item", name="tin-plate", amount=3},
        {type="item", name="wood", amount=8},
      },
      results = {
        {type="item", name="cottongut-food-01", amount=3},
      },
    },
    ["cottongut-science-red-seeds"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="depolymerized-organics", amount=58},
        {type="item", name="cottongut", amount=23},
        {type="item", name="fawogae-substrate", amount=9},
        {type="item", name="retrovirus", amount=1},
      },
      results = {
        {type="item", name="solidified-sarcorus", amount=3},
      },
    },
    ["cottongut-pup-mk01-raising"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1.83495120910117,
      ingredients = {
        {type="item", name="clay", amount=8},
        {type="item", name="cottongut-food-01", amount=3},
        {type="item", name="cottongut-mk01", amount=3},
        {type="item", name="seaweed", amount=52},
      },
      results = {
        {type="item", name="cottongut-mk01", amount=2},
        {type="item", name="cottongut-pup", amount=1},
        {type="item", name="cottongut-pup-mk01", amount=8},
      },
    },
    ["cottongut-mature-basic-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="coke", amount=7},
        {type="item", name="cottongut-food-01", amount=2},
        {type="item", name="cottongut-pup-mk01", amount=3},
        {type="item", name="seaweed", amount=38},
      },
      results = {
        {type="item", name="cottongut-mk01", amount=2},
      },
    },
    ["logistic-science-pack"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="alien-sample01", amount=2},
        {type="item", name="animal-sample-01", amount=2},
        {type="item", name="battery-mk01", amount=3},
        {type="item", name="carbolic-oil-barrel", amount=3},
        {type="item", name="solidified-sarcorus", amount=1},
      },
      results = {
        {type="item", name="logistic-science-pack", amount=12},
      },
    },
    ["workers-food"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="tailings", amount=378},
        {type="item", name="bonemeal", amount=4},
        {type="item", name="cellulose", amount=2},
        {type="item", name="dried-meat", amount=4},
        {type="item", name="guts", amount=2},
        {type="item", name="limestone", amount=12},
        {type="item", name="native-flora", amount=10},
        {type="item", name="sb-grade-03", amount=11},
      },
      results = {
        {type="item", name="workers-food", amount=4},
      },
    },
    ["auog-codex"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=24},
        {type="item", name="copper-cable", amount=144},
        {type="item", name="distilator", amount=3},
        {type="item", name="steam-engine", amount=6},
      },
      results = {
        {type="item", name="auog-codex", amount=2},
      },
    },
    ["auog-paddock-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="carbolic-oil", amount=1128},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="iron-stick", amount=59},
        {type="item", name="sand", amount=195},
        {type="item", name="vane-mk01", amount=1},
      },
      results = {
        {type="item", name="auog-paddock-mk01", amount=2},
      },
    },
    ["auog-pooping-1"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.22306881280283,
      ingredients = {
        {type="item", name="moss", amount=18},
        {type="item", name="saps", amount=3},
        {type="item", name="tailings-dust", amount=4},
        {type="item", name="vacuum-barrel", amount=4},
        {type="item", name="water-barrel", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=6},
        {type="item", name="manure", amount=7},
      },
    },
    ["auog-pup-breeding-1"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.814278191747207,
      ingredients = {
        {type="item", name="moss", amount=6},
        {type="item", name="saps", amount=1},
        {type="item", name="vacuum-barrel", amount=4},
      },
      results = {
        {type="item", name="auog-pup", amount=3},
        {type="item", name="barrel", amount=4},
      },
    },
    ["auog"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="auog-codex", amount=2},
        {type="item", name="bio-sample", amount=15},
        {type="item", name="cdna", amount=2},
        {type="item", name="earth-generic-sample", amount=6},
        {type="item", name="earth-mouse-sample", amount=3},
        {type="item", name="ralesia-codex", amount=2},
        {type="item", name="retrovirus", amount=16},
      },
      results = {
        {type="item", name="auog", amount=3},
      },
    },
    ["auog-food-01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="steam", amount=202},
        {type="item", name="borax", amount=3},
        {type="item", name="gravel", amount=8},
        {type="item", name="ore-tin", amount=4},
        {type="item", name="plastic-bar", amount=4},
        {type="item", name="ralesia-seeds", amount=6},
      },
      results = {
        {type="item", name="auog-food-01", amount=4},
      },
    },
    ["auog-maturing-1"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-pup", amount=1},
        {type="item", name="vacuum-tube", amount=1},
        {type="item", name="water-barrel", amount=7},
      },
      results = {
        {type="item", name="auog", amount=3},
        {type="item", name="barrel", amount=5},
      },
    },
    ["auog-recharge-00"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="auog-food-01", amount=3},
        {type="item", name="brain", amount=2},
        {type="item", name="guts", amount=14},
        {type="item", name="moss", amount=8},
      },
      results = {
        {type="item", name="auog", amount=4},
      },
    },
    ["auog-maturing-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1.24598643888691,
      ingredients = {
        {type="item", name="auog-food-01", amount=3},
        {type="item", name="auog-pup", amount=14},
        {type="item", name="clean-nexelit", amount=2},
        {type="item", name="seaweed", amount=7},
        {type="item", name="sodium-alginate", amount=1},
        {type="item", name="vacuum-barrel", amount=1},
        {type="item", name="water-barrel", amount=6},
      },
      results = {
        {type="item", name="auog", amount=7},
        {type="item", name="barrel", amount=6},
      },
    },
    ["auog-pooping-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.380333762783755,
      ingredients = {
        {type="item", name="auog-food-01", amount=3},
        {type="item", name="lime", amount=7},
      },
      results = {
        {type="item", name="barrel", amount=2},
        {type="item", name="manure", amount=3},
      },
    },
    ["auog-pup-breeding-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="agar", amount=1},
        {type="item", name="auog-food-01", amount=5},
        {type="item", name="lime", amount=3},
        {type="item", name="moss", amount=7},
        {type="item", name="water-barrel", amount=4},
      },
      results = {
        {type="item", name="auog-pup", amount=6},
        {type="item", name="barrel", amount=5},
      },
    },
    ["auog-recharge-0"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="auog-food-01", amount=3},
        {type="item", name="limestone", amount=17},
        {type="item", name="used-auog", amount=4},
      },
      results = {
        {type="item", name="auog", amount=3},
      },
    },
    ["uncaged-auog"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="caged-vrauks", amount=3},
      },
      results = {
        {type="item", name="auog", amount=4},
        {type="item", name="cage", amount=4},
      },
    },
    ["fertilizer-4"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="zogna-bacteria", amount=8},
        {type="item", name="limestone", amount=2},
        {type="item", name="manure", amount=15},
      },
      results = {
        {type="item", name="fertilizer", amount=5},
      },
    },
    ["urea-from-liquid-manure"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.766666666666667,
      ingredients = {
        {type="fluid", name="acetylene", amount=537},
        {type="fluid", name="hydrogen", amount=1021},
      },
      results = {
        {type="item", name="urea", amount=23},
      },
    },
    ["melamine-resin"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.3,
      ingredients = {
        {type="fluid", name="oxygen", amount=656},
        {type="item", name="ceramic", amount=23},
        {type="item", name="raw-fiber", amount=10},
      },
      results = {
        {type="item", name="melamine-resin", amount=13},
      },
    },
    ["fawogae-1"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.857142857142857,
      ingredients = {
        {type="item", name="wood-seeds", amount=2},
      },
      results = {
        {type="item", name="fawogae", amount=6},
      },
    },
    ["fawogae-sample"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2.5,
      ingredients = {
        {type="item", name="bio-sample", amount=138},
        {type="item", name="earth-shroom-sample", amount=2},
        {type="item", name="ralesia-codex", amount=1},
        {type="item", name="tailings-dust", amount=191},
        {type="item", name="vacuum-tube", amount=292},
      },
      results = {
        {type="item", name="fawogae", amount=5},
      },
    },
    ["boron-trioxide"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="fluid", name="pressured-air", amount=102},
        {type="fluid", name="steam", amount=845},
        {type="item", name="calcium-carbide", amount=3},
        {type="item", name="grade-1-copper", amount=2},
      },
      results = {
        {type="item", name="boron-trioxide", amount=3},
      },
    },
    ["coke-coal"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="coal", amount=2},
      },
      results = {
        {type="fluid", name="coke-oven-gas", amount=10},
        {type="item", name="coke", amount=2},
      },
    },
    ["coal-fawogae"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="item", name="fawogae-spore", amount=5},
      },
      results = {
        {type="item", name="raw-coal", amount=4},
      },
    },
    ["hotair-lens"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="fluid", name="syngas", amount=251},
        {type="item", name="lime", amount=2},
      },
      results = {
        {type="item", name="lens", amount=3},
      },
    },
    ["lens"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="molten-glass", amount=29},
        {type="fluid", name="oxygen", amount=242},
        {type="fluid", name="pressured-water", amount=596},
        {type="item", name="nexelit-plate", amount=3},
      },
      results = {
        {type="item", name="lens", amount=3},
      },
    },
    ["vrauks-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.733460760302766,
      ingredients = {
        {type="item", name="carbon-dioxide-barrel", amount=6},
        {type="item", name="chromium", amount=3},
        {type="item", name="soil", amount=71},
        {type="item", name="vrauks-food-01", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=2},
        {type="item", name="vrauks", amount=3},
      },
    },
    ["vrauks-food-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2.5,
      ingredients = {
        {type="item", name="dried-meat", amount=6},
        {type="item", name="fawogae-substrate", amount=9},
        {type="item", name="hazard-concrete", amount=1},
        {type="item", name="moss", amount=15},
        {type="item", name="petri-dish-bacteria", amount=2},
        {type="item", name="raw-fiber", amount=3},
        {type="item", name="small-lamp", amount=3},
        {type="item", name="wood", amount=13},
        {type="item", name="wood-seeds", amount=9},
      },
      results = {
        {type="item", name="vrauks-food-01", amount=10},
      },
    },
    ["vrauks-cocoon-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="gasoline-barrel", amount=1},
        {type="item", name="gravel", amount=103},
        {type="item", name="sb-grade-04", amount=4},
        {type="item", name="vrauks-food-01", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=4},
        {type="item", name="cocoon", amount=10},
      },
    },
    ["vrauks-mk02"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.793787350840598,
      ingredients = {
        {type="item", name="carbon-dioxide-barrel", amount=1},
        {type="item", name="chromium", amount=2},
        {type="item", name="cocoon", amount=39},
        {type="item", name="native-flora", amount=13},
        {type="item", name="scrude-barrel", amount=1},
        {type="item", name="soil", amount=123},
        {type="item", name="vacuum-barrel", amount=2},
        {type="item", name="vrauks-food-01", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=4},
        {type="item", name="vrauks", amount=1},
        {type="item", name="vrauks-mk02", amount=0.0042135477614285},
      },
    },
    ["vrauks-mk02-breeder"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2.08536257873279,
      ingredients = {
        {type="item", name="aromatics-barrel", amount=1},
        {type="item", name="carbon-dioxide-barrel", amount=6},
        {type="item", name="cocoon", amount=74},
        {type="item", name="vrauks-food-01", amount=9},
        {type="item", name="vrauks-mk02", amount=3},
      },
      results = {
        {type="item", name="barrel", amount=10},
        {type="item", name="vrauks-mk02", amount=5},
      },
    },
    ["vrauks-mk02-cocoon"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.50678558230626,
      ingredients = {
        {type="item", name="gasoline-barrel", amount=1},
        {type="item", name="gravel", amount=17},
        {type="item", name="moss-gen", amount=2},
        {type="item", name="sb-grade-04", amount=5},
        {type="item", name="syngas-canister", amount=1},
        {type="item", name="vrauks-food-01", amount=1},
        {type="item", name="vrauks-mk02", amount=2},
        {type="item", name="water-barrel", amount=10},
      },
      results = {
        {type="item", name="barrel", amount=8},
        {type="item", name="cocoon-mk02", amount=8},
        {type="item", name="vrauks-mk02", amount=2},
      },
    },
    ["warm-stone-brick-1"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=100},
        {type="item", name="ceramic", amount=4},
      },
      results = {
        {type="fluid", name="coke-oven-gas", amount=100},
        {type="item", name="warm-stone-brick", amount=4},
      },
    },
    ["warm-air-1"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.20242959268799,
      ingredients = {
        {type="item", name="grade-1-ti", amount=2},
        {type="item", name="warm-stone-brick", amount=19},
      },
      results = {
        {type="fluid", name="hot-air", amount=182},
        {type="item", name="stone-brick", amount=24},
      },
    },
    ["waste-water-void"] = {
      mode = "input-preserved-untransformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=141},
        {type="fluid", name="waste-water", amount=50},
      },
      results = {
        {type="fluid", name="water", amount=50},
      },
    },
    ["barrel-milk"] = {
      mode = "input-preserved-untransformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="steel-plate", amount=1},
      },
      results = {
        {type="item", name="empty-barrel-milk", amount=1},
      },
    },
    ["empty-gas-canister"] = {
      mode = "input-preserved-untransformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="chromium", amount=5},
        {type="item", name="nickel-plate", amount=5},
      },
      results = {
        {type="item", name="empty-gas-canister", amount=3},
      },
    },
    ["active-provider-chest"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="polybutadiene-barrel", amount=2},
        {type="item", name="steam-engine", amount=5},
      },
      results = {
        {type="item", name="active-provider-chest", amount=2},
      },
    },
    ["buffer-chest"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="inductor1", amount=18},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="steel-furnace", amount=1},
      },
      results = {
        {type="item", name="buffer-chest", amount=2},
      },
    },
    ["passive-provider-chest"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="chromite-sand", amount=121},
        {type="item", name="py-burner", amount=3},
      },
      results = {
        {type="item", name="passive-provider-chest", amount=4},
      },
    },
    ["requester-chest"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="steam-engine", amount=3},
      },
      results = {
        {type="item", name="requester-chest", amount=1},
      },
    },
    ["aromatic-organic"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.55,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=2},
        {type="item", name="ralesia-seeds", amount=6},
        {type="item", name="urea", amount=3},
      },
      results = {
        {type="fluid", name="aromatics", amount=310},
      },
    },
    ["ash-bone"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="meat", amount=4},
      },
      results = {
        {type="item", name="ash", amount=4},
      },
    },
    ["ash3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.26666666666667,
      ingredients = {
        {type="item", name="raw-fiber", amount=3},
        {type="item", name="urea", amount=1},
      },
      results = {
        {type="item", name="ash", amount=19},
      },
    },
    ["coal-dust3"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="item", name="urea", amount=2},
      },
      results = {
        {type="item", name="coal-dust", amount=15},
      },
    },
    ["fluegas-filtration"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=94},
      },
      results = {
        {type="item", name="ash", amount=2},
      },
    },
    ["grade-3-tin"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 6,
      ingredients = {
        {type="item", name="aluminium-plate", amount=10},
        {type="item", name="grade-2-tin", amount=2},
        {type="item", name="lime", amount=6},
      },
      results = {
        {type="item", name="grade-3-tin", amount=6},
        {type="item", name="tin-ore-rejects", amount=3},
      },
    },
    ["tin-ore-rejects"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="copper-ore", amount=3},
        {type="item", name="grade-3-tin", amount=4},
      },
      results = {
        {type="item", name="grade-1-tin", amount=1},
      },
    },
    ["wash-grade-3-tin"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.971439131877343,
      ingredients = {
        {type="fluid", name="water", amount=201},
        {type="item", name="grade-2-tin", amount=1},
      },
      results = {
        {type="fluid", name="tailings", amount=92},
        {type="item", name="grade-4-tin", amount=1},
      },
    },
    ["ball-grade-4-tin"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 6,
      ingredients = {
        {type="item", name="grade-2-tin", amount=4},
        {type="item", name="grade-4-tin", amount=3},
      },
      results = {
        {type="item", name="tin-dust", amount=6},
      },
    },
    ["tin-plate-4"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="py-quartz", amount=8},
      },
      results = {
        {type="item", name="tin-plate", amount=8},
      },
    },
    ["molten-tin-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.7,
      ingredients = {
        {type="fluid", name="creosote", amount=530},
        {type="item", name="lime", amount=2},
        {type="item", name="melamine-resin", amount=4},
        {type="item", name="scrude-barrel", amount=6},
      },
      results = {
        {type="fluid", name="molten-tin", amount=51},
      },
    },
    ["hotair-tin-plate-3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.952380952380952,
      ingredients = {
        {type="fluid", name="purest-nitrogen-gas", amount=2196},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="tin-plate", amount=60},
      },
    },
    ["tin-plate-3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.68,
      ingredients = {
        {type="fluid", name="purest-nitrogen-gas", amount=582},
        {type="fluid", name="refined-natural-gas", amount=321},
        {type="item", name="coke", amount=2},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="tin-plate", amount=34},
      },
    },
    ["carbon-filter"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="ammonia-barrel", amount=2},
        {type="item", name="condensates-barrel", amount=13},
        {type="item", name="duralumin", amount=28},
        {type="item", name="engine-unit", amount=4},
        {type="item", name="inductor1", amount=5},
        {type="item", name="lab", amount=6},
        {type="item", name="scrude-barrel", amount=6},
        {type="item", name="sodium-alginate", amount=3},
        {type="item", name="soil-extractor-mk01", amount=1},
      },
      results = {
        {type="item", name="carbon-filter", amount=3},
      },
    },
    ["fts-reactor"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="barrel", amount=15},
        {type="item", name="engine-unit", amount=10},
        {type="item", name="inductor1", amount=120},
        {type="item", name="lab", amount=2},
        {type="item", name="lead-plate", amount=19},
        {type="item", name="ore-lead", amount=11},
        {type="item", name="pipe", amount=9},
        {type="item", name="repair-pack", amount=1},
        {type="item", name="stone-brick", amount=5},
        {type="item", name="tinned-cable", amount=20},
      },
      results = {
        {type="item", name="fts-reactor", amount=1},
      },
    },
    ["methanol-reactor"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=65},
        {type="item", name="assembling-machine-1", amount=1},
        {type="item", name="copper-cable", amount=60},
        {type="item", name="duralumin", amount=12},
        {type="item", name="fiberboard", amount=84},
        {type="item", name="inductor1", amount=14},
        {type="item", name="iron-plate", amount=65},
        {type="item", name="nexelit-plate", amount=15},
        {type="item", name="steam-engine", amount=23},
        {type="item", name="tinned-cable", amount=37},
      },
      results = {
        {type="item", name="methanol-reactor", amount=2},
      },
    },
    ["fluid-separator"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="duralumin", amount=32},
        {type="item", name="fiberboard", amount=62},
        {type="item", name="jaw-crusher", amount=7},
        {type="item", name="lead-plate", amount=32},
        {type="item", name="nexelit-plate", amount=36},
        {type="item", name="solid-separator", amount=1},
      },
      results = {
        {type="item", name="fluid-separator", amount=1},
      },
    },
    ["chromite-rejects-processing"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="item", name="fish-oil-barrel", amount=1},
      },
      results = {
        {type="item", name="grade-3-chromite", amount=1},
      },
    },
    ["grade-4-chromite"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=196},
        {type="item", name="grade-2-chromite", amount=1},
      },
      results = {
        {type="item", name="chromite-rejects", amount=5},
        {type="item", name="grade-4-chromite", amount=5},
      },
    },
    ["grade-3-chromite"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 5,
      ingredients = {
        {type="item", name="grade-1-nickel", amount=9},
      },
      results = {
        {type="item", name="grade-2-chromite", amount=2},
        {type="item", name="grade-3-chromite", amount=5},
      },
    },
    ["tier-2-chromite-sand"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.83333333333333,
      ingredients = {
        {type="item", name="hydrogen-chloride-barrel", amount=1},
      },
      results = {
        {type="item", name="chromite-sand", amount=22},
      },
    },
    ["grade-2-chromite-beneficiation"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 4.57238386995871,
      ingredients = {
        {type="item", name="grade-2-chromite", amount=5},
      },
      results = {
        {type="item", name="grade-1-chromite", amount=3},
        {type="item", name="gravel", amount=2},
      },
    },
    ["classify-iron-ore-dust"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.98,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=226},
        {type="item", name="coal-slurry-barrel", amount=2},
      },
      results = {
        {type="fluid", name="iron-pulp-01", amount=49},
        {type="fluid", name="iron-slime", amount=49},
      },
    },
    ["grade-2-iron"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="oxygen", amount=25},
        {type="item", name="iron-ore", amount=22},
      },
      results = {
        {type="item", name="grade-1-iron", amount=2},
        {type="item", name="grade-2-iron", amount=1},
        {type="item", name="grade-3-iron", amount=1},
      },
    },
    ["iron-slime"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.9,
      ingredients = {
        {type="item", name="chromium", amount=205},
      },
      results = {
        {type="fluid", name="iron-slime", amount=45},
      },
    },
    ["unslimed-iron"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.01125273367996,
      ingredients = {
        {type="fluid", name="iron-slime", amount=71},
        {type="fluid", name="steam", amount=66},
        {type="fluid", name="tar", amount=166},
        {type="item", name="coke", amount=2},
        {type="item", name="ground-sample01", amount=2},
      },
      results = {
        {type="fluid", name="tailings", amount=107},
        {type="item", name="unslimed-iron", amount=1},
      },
    },
    ["grade-2-crush"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="grade-3-iron", amount=1},
      },
      results = {
        {type="item", name="grade-1-iron", amount=2},
        {type="item", name="gravel", amount=1},
      },
    },
    ["grade-3-iron-processing"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-1-iron", amount=3},
      },
      results = {
        {type="item", name="grade-2-iron", amount=1},
      },
    },
    ["iron-ore-dust"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 5,
      ingredients = {
        {type="item", name="grade-2-iron", amount=3},
      },
      results = {
        {type="item", name="iron-ore-dust", amount=5},
      },
    },
    ["molten-iron-06"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.35,
      ingredients = {
        {type="item", name="organic-solvent-barrel", amount=1},
      },
      results = {
        {type="fluid", name="molten-iron", amount=14},
      },
    },
    ["unslimed-iron-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.993569866468595,
      ingredients = {
        {type="fluid", name="crude-oil", amount=737},
      },
      results = {
        {type="fluid", name="tailings", amount=96},
        {type="item", name="unslimed-iron", amount=1},
      },
    },
    ["classify-low-grade"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 3.03846153846154,
      ingredients = {
        {type="item", name="water-saline-barrel", amount=9},
      },
      results = {
        {type="item", name="copper-low-dust", amount=3},
        {type="item", name="grade-4-copper", amount=1},
      },
    },
    ["copper-rejects-recrush"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="coke", amount=2},
        {type="item", name="copper-plate", amount=5},
      },
      results = {
        {type="item", name="grade-3-copper", amount=1},
        {type="item", name="gravel", amount=2},
      },
    },
    ["grade-3-copper"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="fluid", name="oxygen", amount=164},
        {type="item", name="grade-1-copper", amount=1},
        {type="item", name="gravel", amount=4},
      },
      results = {
        {type="item", name="copper-rejects", amount=3},
        {type="item", name="grade-3-copper", amount=3},
      },
    },
    ["grade-4-copper"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-1-copper", amount=2},
      },
      results = {
        {type="item", name="grade-4-copper", amount=1},
        {type="item", name="low-grade-rejects", amount=2},
      },
    },
    ["hotair-copper-plate-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.29333333333333,
      ingredients = {
        {type="fluid", name="btx", amount=711},
        {type="fluid", name="sulfuric-acid", amount=246},
        {type="item", name="sand", amount=9},
      },
      results = {
        {type="item", name="copper-plate", amount=97},
      },
    },
    ["wash-coper-low-dust"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.99669288483276,
      ingredients = {
        {type="item", name="copper-rejects", amount=4},
      },
      results = {
        {type="fluid", name="tailings", amount=198},
        {type="item", name="low-grade-copper", amount=1},
      },
    },
    ["copper-plate-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.483333333333333,
      ingredients = {
        {type="fluid", name="btx", amount=332},
        {type="fluid", name="coal-gas", amount=118},
        {type="item", name="coke", amount=4},
      },
      results = {
        {type="item", name="copper-plate", amount=29},
      },
    },
    ["low-grade-smelting-copper"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 5,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=297},
        {type="item", name="copper-rejects", amount=9},
        {type="item", name="hydrofluoric-acid-barrel", amount=2},
      },
      results = {
        {type="item", name="copper-plate", amount=3},
      },
    },
    ["molten-copper-04"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.38095238095238,
      ingredients = {
        {type="item", name="chromium", amount=3},
        {type="item", name="warmer-stone-brick", amount=13},
        {type="item", name="water-saline-barrel", amount=3},
      },
      results = {
        {type="fluid", name="molten-copper", amount=29},
      },
    },
    ["coalbed-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="auog-pup", amount=16},
        {type="item", name="caged-vrauks", amount=1},
        {type="item", name="duralumin", amount=17},
        {type="item", name="empty-gas-canister", amount=250},
        {type="item", name="fts-reactor", amount=2},
        {type="item", name="py-check-valve", amount=61},
        {type="item", name="steam-engine", amount=2},
        {type="item", name="titanium-plate", amount=182},
      },
      results = {
        {type="item", name="coalbed-mk01", amount=3},
      },
    },
    ["lor-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boiler", amount=26},
        {type="item", name="burner-inserter", amount=4},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="inductor1", amount=243},
        {type="item", name="liquid-manure-barrel", amount=1},
        {type="item", name="mechanical-parts-01", amount=2},
        {type="item", name="pbsb-alloy", amount=3},
        {type="item", name="repair-pack", amount=1},
        {type="item", name="small-parts-01", amount=11},
        {type="item", name="steel-plate", amount=14},
        {type="item", name="tin-plate", amount=13},
        {type="item", name="vacuum-pump-mk01", amount=1},
      },
      results = {
        {type="item", name="lor-mk01", amount=1},
      },
    },
    ["natural-gas-derrick-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="boiler", amount=6},
        {type="item", name="bolts", amount=69},
        {type="item", name="burner-inserter", amount=4},
        {type="item", name="copper-plate", amount=10},
        {type="item", name="empty-petri-dish", amount=8},
        {type="item", name="fiberboard", amount=31},
        {type="item", name="iron-stick", amount=89},
        {type="item", name="nexelit-plate", amount=12},
        {type="item", name="py-tank-4000", amount=3},
        {type="item", name="storage-tank", amount=1},
      },
      results = {
        {type="item", name="natural-gas-derrick-mk01", amount=2},
      },
    },
    ["oil-derrick-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=12},
        {type="item", name="boiler", amount=5},
        {type="item", name="condensates-barrel", amount=1},
        {type="item", name="electronics-mk01", amount=1},
        {type="item", name="hydrogen-barrel", amount=3},
        {type="item", name="inductor1", amount=53},
        {type="item", name="iron-stick", amount=74},
        {type="item", name="repair-pack", amount=2},
        {type="item", name="steel-chest", amount=4},
        {type="item", name="stone-brick", amount=15},
      },
      results = {
        {type="item", name="oil-derrick-mk01", amount=1},
      },
    },
    ["oil-sand-extractor-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="advanced-foundry-mk01", amount=8},
        {type="item", name="barrel", amount=46},
        {type="item", name="boiler", amount=12},
        {type="item", name="burner-inserter", amount=5},
        {type="item", name="chromite-sand", amount=69},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="fluid-drill-mk01", amount=2},
        {type="item", name="gate", amount=8},
        {type="item", name="inductor1", amount=109},
        {type="item", name="limestone", amount=29},
        {type="item", name="mechanical-parts-01", amount=3},
        {type="item", name="medium-electric-pole", amount=131},
        {type="item", name="molten-iron-barrel", amount=1},
        {type="item", name="steel-plate", amount=52},
      },
      results = {
        {type="item", name="oil-sand-extractor-mk01", amount=3},
      },
    },
    ["pumpjack-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="duralumin", amount=29},
        {type="item", name="inductor1", amount=19},
        {type="item", name="offshore-pump", amount=2},
        {type="item", name="scrude-barrel", amount=6},
        {type="item", name="sodium-alginate", amount=3},
      },
      results = {
        {type="item", name="pumpjack-mk01", amount=1},
      },
    },
    ["tar-extractor-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="anthracene-oil-barrel", amount=7},
        {type="item", name="barrel", amount=123},
        {type="item", name="blood-barrel", amount=4},
        {type="item", name="brake-mk01", amount=1},
        {type="item", name="creamy-latex-barrel", amount=16},
        {type="item", name="inductor1", amount=53},
        {type="item", name="methanol-reactor", amount=5},
        {type="item", name="tar-processing-unit", amount=2},
      },
      results = {
        {type="item", name="tar-extractor-mk01", amount=3},
      },
    },
    ["coarse-coal"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.03744022845524,
      ingredients = {
        {type="item", name="raw-coal", amount=13},
      },
      results = {
        {type="item", name="coal", amount=4},
        {type="item", name="coal-dust", amount=1},
        {type="item", name="coarse-coal", amount=1},
      },
    },
    ["coarse-coal-to-coal"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="crushed-coal", amount=6},
        {type="item", name="raw-coal", amount=30},
      },
      results = {
        {type="item", name="coal", amount=6},
      },
    },
    ["cog-void-soot"] = {
      mode = "input-preserved-untransformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=30},
        {type="fluid", name="water", amount=10},
      },
      results = {
        {type="item", name="soot", amount=1},
      },
    },
    ["ez-ranch-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 5,
      ingredients = {
        {type="item", name="carbon-dioxide-barrel", amount=189},
        {type="item", name="engine-unit", amount=15},
        {type="item", name="fluid-drill-mk01", amount=2},
        {type="item", name="intermetallics", amount=3},
        {type="item", name="lead-plate", amount=418},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="offshore-pump", amount=116},
        {type="item", name="pipe", amount=114},
        {type="item", name="plastic-bar", amount=50},
        {type="item", name="quenching-tower", amount=4},
        {type="item", name="small-lamp", amount=15},
        {type="item", name="steel-chest", amount=4},
        {type="item", name="storage-tank", amount=4},
        {type="item", name="vane-mk01", amount=2},
      },
      results = {
        {type="item", name="ez-ranch-mk01", amount=5},
      },
    },
    ["kicalk-plantation-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="intermetallics", amount=15},
        {type="item", name="micro-mine-mk01", amount=2},
        {type="item", name="nexelit-plate", amount=86},
        {type="item", name="pipe", amount=131},
        {type="item", name="small-parts-01", amount=725},
      },
      results = {
        {type="item", name="kicalk-plantation-mk01", amount=3},
      },
    },
    ["tuuphra-plantation-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=12},
        {type="item", name="concrete", amount=7},
        {type="item", name="fiberboard", amount=21},
        {type="item", name="glass", amount=10},
        {type="item", name="heavy-oil-canister", amount=2},
        {type="item", name="intermetallics", amount=3},
        {type="item", name="lab", amount=1},
        {type="item", name="lead-plate", amount=6},
        {type="item", name="micro-mine-mk01", amount=1},
        {type="item", name="nexelit-plate", amount=19},
        {type="item", name="pbsb-alloy", amount=8},
        {type="item", name="pipe", amount=10},
        {type="item", name="pump", amount=9},
        {type="item", name="small-parts-01", amount=50},
      },
      results = {
        {type="item", name="tuuphra-plantation-mk01", amount=1},
      },
    },
    ["yaedols-culture-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="assembling-machine-2", amount=2},
        {type="item", name="ball-mill-mk01", amount=5},
        {type="item", name="concrete", amount=280},
        {type="item", name="engine-unit", amount=21},
        {type="item", name="glass", amount=64},
        {type="item", name="iron-plate", amount=106},
        {type="item", name="light-oil-barrel", amount=5},
        {type="item", name="liquid-manure-barrel", amount=6},
        {type="item", name="mechanical-parts-01", amount=2},
        {type="item", name="nexelit-plate", amount=174},
        {type="item", name="repair-pack", amount=8},
        {type="item", name="steam-engine", amount=17},
        {type="item", name="tinned-cable", amount=47},
        {type="item", name="vitreloy", amount=3},
      },
      results = {
        {type="item", name="yaedols-culture-mk01", amount=2},
      },
    },
    ["crawdad"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=1712},
        {type="item", name="animal-sample-01", amount=33},
        {type="item", name="earth-bear-sample", amount=5},
        {type="item", name="earth-generic-sample", amount=12},
        {type="item", name="light-armor", amount=12},
        {type="item", name="plasmids", amount=16},
        {type="item", name="py-science-pack-1", amount=38},
        {type="item", name="retrovirus", amount=62},
        {type="item", name="treated-wood", amount=90},
      },
      results = {
        {type="item", name="crawdad", amount=2},
      },
    },
    ["sponge-culture-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="concrete", amount=50},
        {type="item", name="electric-mining-drill", amount=1},
        {type="item", name="fiberboard", amount=61},
        {type="item", name="grade-2-chromite", amount=1},
        {type="item", name="heavy-oil-barrel", amount=2},
        {type="item", name="inductor1", amount=7},
        {type="item", name="iron-chest", amount=2},
        {type="item", name="pump", amount=10},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="storage-tank", amount=2},
      },
      results = {
        {type="item", name="sponge-culture-mk01", amount=1},
      },
    },
    ["crushing-molybdenite"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.4095179201491,
      ingredients = {
        {type="item", name="fish", amount=2},
      },
      results = {
        {type="item", name="crushed-molybdenite", amount=7},
        {type="item", name="stone", amount=3},
      },
    },
    ["duralumin-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.3,
      ingredients = {
        {type="fluid", name="drilling-fluid-0", amount=286},
        {type="fluid", name="gasoline", amount=833},
        {type="fluid", name="molten-aluminium", amount=97},
        {type="fluid", name="syngas", amount=230},
        {type="item", name="sand-casting", amount=2},
      },
      results = {
        {type="item", name="duralumin", amount=26},
      },
    },
    ["sncr-alloy"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=3},
        {type="item", name="lime", amount=2},
      },
      results = {
        {type="item", name="sncr-alloy", amount=2},
      },
    },
    ["empty-comb"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.428571428571428,
      ingredients = {
        {type="fluid", name="water-saline", amount=93},
        {type="item", name="coarse", amount=1},
        {type="item", name="gravel", amount=18},
        {type="item", name="ground-sample01", amount=1},
      },
      results = {
        {type="item", name="empty-comb", amount=3},
      },
    },
    ["fish-food-01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.666666666666667,
      ingredients = {
        {type="fluid", name="water", amount=557},
        {type="item", name="brain", amount=2},
        {type="item", name="fertilizer", amount=4},
        {type="item", name="iron-stick", amount=12},
        {type="item", name="meat", amount=7},
        {type="item", name="moss", amount=11},
        {type="item", name="plastic-bar", amount=5},
        {type="item", name="soil", amount=19},
      },
      results = {
        {type="item", name="fish-food-01", amount=2},
      },
    },
    ["flask-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="fluid", name="scrude", amount=43},
        {type="item", name="lime", amount=17},
        {type="item", name="stopper", amount=1},
      },
      results = {
        {type="item", name="flask", amount=2},
      },
    },
    ["hotair-flask-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="fluid", name="molten-glass", amount=85},
        {type="item", name="lens", amount=2},
        {type="item", name="lime", amount=14},
        {type="item", name="stopper", amount=8},
      },
      results = {
        {type="item", name="flask", amount=6},
      },
    },
    ["grade-2-lead-crusher"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="grade-1-lead", amount=4},
        {type="item", name="grade-2-copper", amount=3},
        {type="item", name="ore-chromium", amount=7},
      },
      results = {
        {type="item", name="grade-2-lead", amount=3},
        {type="item", name="stone", amount=3},
      },
    },
    ["grade-2-lead"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="grade-2-lead", amount=4},
      },
      results = {
        {type="item", name="grade-1-lead", amount=1},
        {type="item", name="grade-3-lead", amount=2},
      },
    },
    ["grade-2-crush-lead"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="water-saline", amount=77},
        {type="item", name="grade-3-iron", amount=3},
      },
      results = {
        {type="item", name="lead-dust", amount=2},
      },
    },
    ["molten-lead-01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.777777777777778,
      ingredients = {
        {type="item", name="chromium", amount=2},
        {type="item", name="coke", amount=7},
        {type="item", name="subcritical-water-barrel", amount=13},
      },
      results = {
        {type="fluid", name="molten-lead", amount=70},
      },
    },
    ["hotair-lead-plate-3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.952380952380952,
      ingredients = {
        {type="fluid", name="molten-lead", amount=97},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="lead-plate", amount=60},
      },
    },
    ["lead-plate-3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.44,
      ingredients = {
        {type="fluid", name="creosote", amount=311},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="lead-plate", amount=22},
      },
    },
    ["grade-3-zinc"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.99916186718261,
      ingredients = {
        {type="item", name="grade-1-zinc", amount=5},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=48},
        {type="item", name="grade-3-zinc", amount=5},
      },
    },
    ["molten-zinc-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.05,
      ingredients = {
        {type="fluid", name="nitrogen", amount=112},
        {type="item", name="grade-1-zinc", amount=2},
        {type="item", name="grade-2-zinc", amount=4},
        {type="item", name="sand", amount=3},
      },
      results = {
        {type="fluid", name="molten-zinc", amount=21},
      },
    },
    ["zinc-plate-3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.76,
      ingredients = {
        {type="fluid", name="light-oil", amount=671},
        {type="item", name="limestone", amount=2},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="zinc-plate", amount=38},
      },
    },
    ["hotair-zinc-plate-3"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.38095238095238,
      ingredients = {
        {type="fluid", name="benzene", amount=779},
        {type="fluid", name="light-oil", amount=564},
        {type="item", name="coke", amount=3},
        {type="item", name="pure-sand", amount=2},
      },
      results = {
        {type="item", name="zinc-plate", amount=87},
      },
    },
    ["molten-solder-0"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.45,
      ingredients = {
        {type="fluid", name="molten-lead", amount=10},
        {type="fluid", name="molten-tin", amount=12},
        {type="item", name="cellulose", amount=2},
        {type="item", name="rich-clay", amount=3},
        {type="item", name="zinc-chloride", amount=2},
      },
      results = {
        {type="fluid", name="molten-solder", amount=29},
      },
    },
    ["molten-solder-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="hot-air", amount=152},
        {type="fluid", name="molten-lead", amount=8},
        {type="fluid", name="molten-tin", amount=10},
        {type="item", name="grade-3-iron", amount=2},
      },
      results = {
        {type="fluid", name="molten-solder", amount=60},
      },
    },
    ["solder"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="molten-glass", amount=184},
      },
      results = {
        {type="item", name="solder", amount=5},
      },
    },
    ["hotair-solder"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.428571428571429,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=71},
      },
      results = {
        {type="item", name="solder", amount=3},
      },
    },
    ["molten-steel"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.11915411719446,
      ingredients = {
        {type="fluid", name="hot-air", amount=243},
        {type="fluid", name="molten-iron", amount=38},
        {type="item", name="fish", amount=1},
        {type="item", name="gravel", amount=11},
        {type="item", name="ralesia", amount=7},
      },
      results = {
        {type="fluid", name="flue-gas", amount=556},
        {type="fluid", name="molten-steel", amount=56},
      },
    },
    ["hotair-steel-20"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.65625,
      ingredients = {
        {type="fluid", name="molten-steel", amount=167},
        {type="item", name="coke", amount=9},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="steel-plate", amount=53},
      },
    },
    ["steel-20"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.12,
      ingredients = {
        {type="item", name="sand-casting", amount=4},
      },
      results = {
        {type="item", name="steel-plate", amount=3},
      },
    },
    ["kicalk-codex"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=19},
        {type="item", name="bio-sample", amount=1},
        {type="item", name="copper-cable", amount=40},
        {type="item", name="electronic-circuit", amount=21},
        {type="item", name="shaft-mk01", amount=7},
      },
      results = {
        {type="item", name="kicalk-codex", amount=1},
      },
    },
    ["tuuphra-codex"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=99},
        {type="item", name="iron-stick", amount=37},
        {type="item", name="small-parts-01", amount=13},
        {type="item", name="steam-engine", amount=35},
        {type="item", name="tinned-cable", amount=38},
      },
      results = {
        {type="item", name="tuuphra-codex", amount=1},
      },
    },
    ["yaedols-codex"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=11},
        {type="item", name="burner-mining-drill", amount=2},
        {type="item", name="shaft-mk01", amount=10},
      },
      results = {
        {type="item", name="yaedols-codex", amount=1},
      },
    },
    ["sea-sponge-codex"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.097606606608567,
      ingredients = {
        {type="item", name="acetone-barrel", amount=1},
        {type="item", name="acetylene-barrel", amount=1},
        {type="item", name="copper-cable", amount=12},
        {type="item", name="electronic-circuit", amount=3},
        {type="item", name="iron-stick", amount=48},
        {type="item", name="tin-plate", amount=2},
      },
      results = {
        {type="item", name="sea-sponge-codex", amount=0.097606606608567},
      },
    },
    ["lard-from-brains"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.1,
      ingredients = {
        {type="item", name="fertilizer", amount=7},
        {type="item", name="guts", amount=41},
        {type="item", name="iron-stick", amount=23},
        {type="item", name="meat", amount=12},
        {type="item", name="mukmoux-fat", amount=3},
        {type="item", name="plastic-bar", amount=9},
        {type="item", name="soil", amount=14},
      },
      results = {
        {type="item", name="mukmoux-fat", amount=14},
      },
    },
    ["leaching-station-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=32},
        {type="item", name="carbon-dioxide-barrel", amount=5},
        {type="item", name="duralumin", amount=13},
        {type="item", name="lead-plate", amount=16},
        {type="item", name="nexelit-plate", amount=74},
        {type="item", name="py-tank-1500", amount=4},
        {type="item", name="steam-engine", amount=5},
      },
      results = {
        {type="item", name="leaching-station-mk01", amount=1},
      },
    },
    ["wet-scrubber-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=37},
        {type="item", name="inductor1", amount=56},
        {type="item", name="pbsb-alloy", amount=12},
        {type="item", name="pitch-canister", amount=2},
        {type="item", name="py-tank-6500", amount=3},
        {type="item", name="tar-processing-unit", amount=1},
      },
      results = {
        {type="item", name="wet-scrubber-mk01", amount=1},
      },
    },
    ["methanol-from-syngas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.493333333333333,
      ingredients = {
        {type="fluid", name="flue-gas", amount=261},
        {type="item", name="bolts", amount=3},
        {type="item", name="copper-ore", amount=4},
      },
      results = {
        {type="fluid", name="methanol", amount=74},
      },
    },
    ["formamide"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.31,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=786},
        {type="fluid", name="methanol", amount=100},
        {type="item", name="warm-stone-brick", amount=8},
      },
      results = {
        {type="fluid", name="formamide", amount=131},
        {type="fluid", name="methanol", amount=100},
      },
    },
    ["military-science-pack"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="firearm-magazine", amount=2},
        {type="item", name="lead-plate", amount=27},
        {type="item", name="soot", amount=2},
        {type="item", name="stone-wall", amount=2},
      },
      results = {
        {type="item", name="military-science-pack", amount=3},
      },
    },
    ["niobium-mine"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=38},
        {type="item", name="lead-plate", amount=56},
        {type="item", name="py-tank-3000", amount=4},
        {type="item", name="py-underflow-valve", amount=4},
        {type="item", name="steam-engine", amount=52},
        {type="item", name="tar-processing-unit", amount=1},
      },
      results = {
        {type="item", name="niobium-mine", amount=2},
      },
    },
    ["nxsb-alloy"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.333333333333333,
      ingredients = {
        {type="item", name="sb-oxide", amount=3},
        {type="item", name="small-parts-01", amount=5},
      },
      results = {
        {type="item", name="nxsb-alloy", amount=1},
      },
    },
    ["pbsb-alloy-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="fluid", name="ammonia", amount=341},
        {type="fluid", name="carbon-dioxide", amount=476},
        {type="fluid", name="molten-glass", amount=190},
        {type="item", name="cellulose", amount=29},
      },
      results = {
        {type="item", name="pbsb-alloy", amount=7},
      },
    },
    ["powdered-phosphate-rock"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="warm-stone-brick", amount=4},
      },
      results = {
        {type="item", name="powdered-phosphate-rock", amount=5},
        {type="item", name="stone", amount=5},
      },
    },
    ["stone-wool"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="fluid", name="oxygen", amount=202},
        {type="fluid", name="pressured-water", amount=394},
        {type="item", name="cellulose", amount=4},
        {type="item", name="coal-dust", amount=4},
      },
      results = {
        {type="item", name="stone-wool", amount=3},
      },
    },
    ["stone-wool2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="creosote", amount=59},
        {type="fluid", name="flue-gas", amount=593},
        {type="item", name="boron-trioxide", amount=1},
        {type="item", name="coal-dust", amount=11},
        {type="item", name="sodium-hydroxide", amount=2},
      },
      results = {
        {type="item", name="stone-wool", amount=2},
      },
    },
    ["zipir-codex"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="aluminium-plate", amount=6},
        {type="item", name="electronic-circuit", amount=2},
        {type="item", name="lead-plate", amount=2},
        {type="item", name="sncr-alloy", amount=2},
      },
      results = {
        {type="item", name="zipir-codex", amount=1},
      },
    },
    ["zipir-eggs-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.484872796672098,
      ingredients = {
        {type="fluid", name="methanal", amount=255},
        {type="item", name="pressured-air-barrel", amount=4},
      },
      results = {
        {type="fluid", name="waste-water", amount=92},
        {type="item", name="zipir-eggs", amount=2},
      },
    },
    ["zipir-reef-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="acetone-barrel", amount=48},
        {type="item", name="concrete", amount=215},
        {type="item", name="duralumin", amount=30},
        {type="item", name="engine-unit", amount=6},
        {type="item", name="evaporator", amount=7},
        {type="item", name="fiberboard", amount=244},
        {type="item", name="lead-plate", amount=64},
        {type="item", name="offshore-pump", amount=18},
        {type="item", name="pbsb-alloy", amount=5},
        {type="item", name="py-sinkhole", amount=2},
        {type="item", name="spore-collector-mk01", amount=2},
        {type="item", name="steam-engine", amount=47},
      },
      results = {
        {type="item", name="zipir-reef-mk01", amount=2},
      },
    },
    ["zipir-a-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.23866730524923,
      ingredients = {
        {type="item", name="cellulose", amount=27},
        {type="item", name="fish", amount=5},
        {type="item", name="nickel-rejects", amount=4},
        {type="item", name="zinc-chloride", amount=7},
      },
      results = {
        {type="fluid", name="waste-water", amount=117},
        {type="item", name="zipir1", amount=1},
      },
    },
    ["zipir-a-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2.84648833641704,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=705},
        {type="fluid", name="vacuum", amount=611},
        {type="item", name="aluminium-plate", amount=7},
        {type="item", name="cellulose", amount=19},
        {type="item", name="fawogae-substrate", amount=4},
        {type="item", name="py-science-pack-1", amount=3},
        {type="item", name="zinc-chloride", amount=12},
      },
      results = {
        {type="fluid", name="waste-water", amount=279},
        {type="item", name="zipir1", amount=2},
      },
    },
    ["arthropod-blood-to-blood"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.79000433630682,
      ingredients = {
        {type="fluid", name="molten-glass", amount=482},
        {type="item", name="grade-2-iron", amount=1},
      },
      results = {
        {type="fluid", name="blood", amount=51},
        {type="item", name="grade-1-copper", amount=2},
      },
    },
    ["py-gas-powerplant-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="chromium", amount=80},
        {type="item", name="controler-mk01", amount=6},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="gasifier", amount=3},
        {type="item", name="grade-3-copper", amount=205},
        {type="item", name="iron-stick", amount=462},
        {type="item", name="lab", amount=63},
        {type="item", name="light-armor", amount=34},
        {type="item", name="logistic-science-pack", amount=11},
        {type="item", name="py-sinkhole", amount=4},
        {type="item", name="raw-borax", amount=1000},
        {type="item", name="resistor1", amount=34},
      },
      results = {
        {type="item", name="py-gas-powerplant-mk01", amount=1},
      },
    },
    ["ree-mining-drill-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="duralumin", amount=4},
        {type="item", name="lab", amount=2},
        {type="item", name="pipe", amount=17},
        {type="item", name="steam-engine", amount=9},
      },
      results = {
        {type="item", name="ree-mining-drill-mk01", amount=1},
      },
    },
    ["pyrite-make"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coke", amount=8},
        {type="item", name="lime", amount=1},
      },
      results = {
        {type="item", name="pyrite", amount=1},
      },
    },
    ["rich-clay-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="water", amount=421},
        {type="item", name="ceramic", amount=10},
      },
      results = {
        {type="item", name="rich-clay", amount=8},
      },
    },
    ["soot-to-aluminium"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.2374216562133,
      ingredients = {
        {type="item", name="aluminium-plate", amount=4},
        {type="item", name="soot", amount=10},
        {type="item", name="stone", amount=16},
      },
      results = {
        {type="item", name="ash", amount=1},
        {type="item", name="ore-aluminium", amount=12},
      },
    },
    ["soot-to-copper"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.0509390350894,
      ingredients = {
        {type="item", name="soot", amount=10},
      },
      results = {
        {type="item", name="ash", amount=1},
        {type="item", name="copper-ore", amount=8},
      },
    },
    ["soot-to-gold"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.99928554584594,
      ingredients = {
        {type="item", name="calcium-carbide", amount=15},
        {type="item", name="powdered-aluminium", amount=4},
        {type="item", name="soot", amount=14},
      },
      results = {
        {type="item", name="ash", amount=0.566931943849986},
        {type="item", name="gold-plate", amount=1},
      },
    },
    ["soot-to-iron"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.16036124874583,
      ingredients = {
        {type="item", name="soot", amount=10},
        {type="item", name="tailings-dust", amount=4},
      },
      results = {
        {type="item", name="ash", amount=1},
        {type="item", name="iron-ore", amount=11},
      },
    },
    ["soot-to-silver"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 3.33333333333333,
      ingredients = {
        {type="item", name="soot", amount=31},
      },
      results = {
        {type="item", name="ash", amount=1},
        {type="item", name="silver-plate", amount=1},
      },
    },
    ["soot-to-zinc"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.375147910244432,
      ingredients = {
        {type="item", name="soot", amount=4},
      },
      results = {
        {type="item", name="ash", amount=0.114532570324914},
        {type="item", name="ore-zinc", amount=3},
      },
    },
    ["tailings-separation"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.85952251065536,
      ingredients = {
        {type="item", name="gravel", amount=48},
        {type="item", name="tailings-dust", amount=14},
      },
      results = {
        {type="item", name="coal-dust", amount=9},
        {type="item", name="rich-dust", amount=4},
      },
    },
    ["richdust-separation"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="tailings-dust", amount=9},
      },
      results = {
        {type="item", name="chromite-sand", amount=3},
        {type="item", name="iron-oxide", amount=2},
      },
    },
    ["soot-to-lead"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.41775240445003,
      ingredients = {
        {type="item", name="tailings-dust", amount=54},
      },
      results = {
        {type="item", name="ash", amount=1},
        {type="item", name="ore-lead", amount=11},
      },
    },
    ["fetal-serum-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.72,
      ingredients = {
        {type="item", name="nickel-plate", amount=5},
        {type="item", name="skin", amount=16},
      },
      results = {
        {type="fluid", name="fetal-serum", amount=86},
      },
    },
    ["salt-ex"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.43478260869565,
      ingredients = {
        {type="fluid", name="hot-air", amount=464},
        {type="fluid", name="oxygen", amount=201},
        {type="fluid", name="water", amount=455},
      },
      results = {
        {type="item", name="salt", amount=33},
      },
    },
    ["sand-washing"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.505079327645752,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=118},
        {type="item", name="biomass", amount=2},
        {type="item", name="ground-sample01", amount=1},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=42},
        {type="item", name="pure-sand", amount=4},
      },
    },
    ["acetic-acid"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.96,
      ingredients = {
        {type="fluid", name="methanol", amount=52},
        {type="fluid", name="purest-nitrogen-gas", amount=17},
        {type="item", name="chromite-sand", amount=1},
      },
      results = {
        {type="fluid", name="acetic-acid", amount=48},
      },
    },
    ["ammonia-urea"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.08,
      ingredients = {
        {type="item", name="empty-petri-dish", amount=5},
        {type="item", name="guts", amount=1},
        {type="item", name="raw-fiber", amount=5},
        {type="item", name="urea", amount=9},
        {type="item", name="wooden-chest", amount=1},
      },
      results = {
        {type="fluid", name="ammonia", amount=108},
      },
    },
    ["organic-solvent2"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.08709924017101,
      ingredients = {
        {type="fluid", name="flue-gas", amount=337},
        {type="fluid", name="hot-air", amount=998},
        {type="item", name="coal", amount=3},
      },
      results = {
        {type="fluid", name="ammonia", amount=54},
        {type="fluid", name="organic-solvent", amount=109},
      },
    },
    ["phosphorous-acid"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.48,
      ingredients = {
        {type="item", name="empty-comb", amount=5},
        {type="item", name="kerosene-canister", amount=1},
        {type="item", name="log", amount=1},
        {type="item", name="powdered-phosphate-rock", amount=5},
      },
      results = {
        {type="fluid", name="phosphorous-acid", amount=74},
      },
    },
    ["tall-oil-separation"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.7,
      ingredients = {
        {type="fluid", name="hot-air", amount=148},
        {type="fluid", name="light-oil", amount=23},
        {type="fluid", name="tar", amount=16},
        {type="item", name="capacitor1", amount=1},
      },
      results = {
        {type="fluid", name="aromatics", amount=17},
        {type="fluid", name="benzene", amount=17},
      },
    },
    ["tar-talloil"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.44102565109518,
      ingredients = {
        {type="fluid", name="hot-air", amount=505},
        {type="item", name="coke", amount=6},
        {type="item", name="lime", amount=1},
      },
      results = {
        {type="fluid", name="aromatics", amount=29},
        {type="fluid", name="light-oil", amount=72},
        {type="fluid", name="tall-oil", amount=72},
      },
    },
    ["fluidize-coke"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.74626109509253,
      ingredients = {
        {type="fluid", name="flue-gas", amount=391},
        {type="item", name="coke", amount=4},
        {type="item", name="copper-ore", amount=6},
        {type="item", name="copper-rejects", amount=1},
      },
      results = {
        {type="fluid", name="ammonia", amount=35},
        {type="fluid", name="tall-oil", amount=35},
        {type="fluid", name="tar", amount=52},
      },
    },
    ["methane-py-fertilizer"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.5875,
      ingredients = {
        {type="fluid", name="organic-solvent", amount=3},
        {type="fluid", name="pressured-air", amount=146},
        {type="item", name="moondrop-seeds", amount=1},
      },
      results = {
        {type="fluid", name="methane", amount=47},
      },
    },
    ["phosphoric-acid"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.9,
      ingredients = {
        {type="fluid", name="phosphorous-acid", amount=39},
        {type="item", name="coal", amount=7},
      },
      results = {
        {type="fluid", name="hydrofluoric-acid", amount=9},
        {type="fluid", name="phosphine-gas", amount=9},
        {type="fluid", name="phosphoric-acid", amount=18},
      },
    },
    ["propene"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.833412138367491,
      ingredients = {
        {type="fluid", name="pressured-water", amount=145},
        {type="fluid", name="syngas", amount=45},
        {type="item", name="lead-plate", amount=4},
      },
      results = {
        {type="fluid", name="propene", amount=50},
        {type="fluid", name="water", amount=42},
      },
    },
    ["phosphoric-acid2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.775,
      ingredients = {
        {type="fluid", name="crude-oil", amount=808},
      },
      results = {
        {type="fluid", name="phosphoric-acid", amount=31},
      },
    },
    ["al-pulp-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.89,
      ingredients = {
        {type="fluid", name="phosphoric-acid", amount=23},
        {type="item", name="calcium-carbide", amount=19},
        {type="item", name="powdered-aluminium", amount=5},
      },
      results = {
        {type="fluid", name="al-pulp-01", amount=89},
      },
    },
    ["al-pulp-02"] = {
      mode = "repaired-to-input",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="coal-gas", amount=852},
        {type="fluid", name="water", amount=900},
      },
      results = {
        {type="fluid", name="al-pulp-02", amount=100},
      },
    },
    ["molten-aluminium-02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.7,
      ingredients = {
        {type="fluid", name="al-pulp-02", amount=77},
        {type="item", name="graphite", amount=1},
      },
      results = {
        {type="fluid", name="molten-aluminium", amount=35},
      },
    },
    ["fluorine-gas"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.28,
      ingredients = {
        {type="fluid", name="ammonia", amount=283},
        {type="fluid", name="flue-gas", amount=3351},
        {type="item", name="sodium-hydroxide", amount=8},
      },
      results = {
        {type="fluid", name="fluorine-gas", amount=64},
        {type="fluid", name="hydrogen", amount=64},
      },
    },
    ["syngas-distilation"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.968874507577201,
      ingredients = {
        {type="fluid", name="flue-gas", amount=570},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=48},
        {type="fluid", name="hydrogen", amount=97},
      },
    },
    ["gas-molten-salt-01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.27,
      ingredients = {
        {type="fluid", name="hydrofluoric-acid", amount=1474},
        {type="fluid", name="tar", amount=796},
        {type="item", name="chromium", amount=168},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=635},
      },
    },
    ["wastewater-recovery"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.16,
      ingredients = {
        {type="fluid", name="ammonia", amount=183},
        {type="fluid", name="waste-water", amount=30},
        {type="item", name="lime", amount=3},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=174},
      },
    },
    ["glass-3"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.42,
      ingredients = {
        {type="item", name="scrude-barrel", amount=1},
        {type="item", name="ti-rejects", amount=1},
      },
      results = {
        {type="fluid", name="molten-glass", amount=71},
      },
    },
    ["powdered-quartz"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.60371389147875,
      ingredients = {
        {type="fluid", name="ammonia", amount=134},
        {type="item", name="copper-plate", amount=8},
      },
      results = {
        {type="item", name="gravel", amount=1},
        {type="item", name="powdered-quartz", amount=8},
      },
    },
    ["seaweed-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="fluid", name="oxygen", amount=48},
        {type="item", name="gravel", amount=3},
      },
      results = {
        {type="item", name="seaweed", amount=10},
      },
    },
    ["silver-plate-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="crude-oil-canister", amount=24},
      },
      results = {
        {type="item", name="silver-plate", amount=9},
      },
    },
    ["sulfur-mine"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="barrel", amount=31},
        {type="item", name="electronics-mk01", amount=4},
        {type="item", name="light-oil-barrel", amount=7},
        {type="item", name="liquid-manure-barrel", amount=8},
        {type="item", name="long-handed-inserter", amount=9},
        {type="item", name="pump", amount=9},
        {type="item", name="repair-pack", amount=27},
        {type="item", name="tar-processing-unit", amount=1},
        {type="item", name="vitreloy", amount=10},
        {type="item", name="washer", amount=1},
        {type="item", name="wpu-mk01", amount=2},
      },
      results = {
        {type="item", name="sulfur-mine", amount=1},
      },
    },
    ["albumin-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="fluid", name="acetone", amount=1498},
        {type="fluid", name="methanal", amount=683},
        {type="item", name="ash", amount=22},
        {type="item", name="chitin", amount=3},
      },
      results = {
        {type="item", name="albumin", amount=8},
      },
    },
    ["formaldehyde-from-refined-natural-gas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.498684996142314,
      ingredients = {
        {type="fluid", name="hot-molten-salt", amount=13},
        {type="fluid", name="refined-natural-gas", amount=77},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=49},
        {type="fluid", name="methanal", amount=24},
        {type="fluid", name="molten-salt", amount=15},
      },
    },
    ["powedered-biomass"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="item", name="biomass", amount=32},
      },
      results = {
        {type="item", name="powdered-biomass", amount=32},
      },
    },
    ["sugar"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="polybutadiene", amount=954},
        {type="item", name="geothermal-water-barrel", amount=1},
        {type="item", name="graphite", amount=2},
        {type="item", name="skin", amount=1},
      },
      results = {
        {type="item", name="sugar", amount=8},
      },
    },
    ["waste-water-urea"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="waste-water", amount=193},
      },
      results = {
        {type="item", name="urea", amount=10},
      },
    },
    ["fine-powdered-biomass"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.781073942394208,
      ingredients = {
        {type="item", name="powdered-biomass", amount=23},
      },
      results = {
        {type="item", name="biomass", amount=1},
        {type="item", name="fine-powdered-biomass", amount=14},
        {type="item", name="powdered-biomass", amount=1},
      },
    },
    ["fungal-substrate"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.9,
      ingredients = {
        {type="item", name="biomass", amount=5},
        {type="item", name="coal-dust", amount=10},
      },
      results = {
        {type="item", name="fungal-substrate", amount=9},
      },
    },
    ["dried-biomass"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="item", name="dried-meat", amount=2},
        {type="item", name="ore-aluminium", amount=3},
      },
      results = {
        {type="item", name="dried-biomass", amount=42},
      },
    },
    ["fungal-substrate-02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.9,
      ingredients = {
        {type="item", name="empty-petri-dish", amount=2},
        {type="item", name="guts", amount=2},
        {type="item", name="ore-quartz", amount=2},
        {type="item", name="raw-fiber", amount=14},
        {type="item", name="wooden-chest", amount=1},
      },
      results = {
        {type="item", name="fungal-substrate-02", amount=9},
      },
    },
    ["fiber"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.398874369349666,
      ingredients = {
        {type="item", name="raw-fiber", amount=4},
      },
      results = {
        {type="item", name="biomass", amount=2},
        {type="item", name="fiber", amount=2},
      },
    },
    ["micro-fiber"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="coke", amount=20},
        {type="item", name="sb-grade-03", amount=1},
      },
      results = {
        {type="item", name="micro-fiber", amount=4},
      },
    },
    ["bitumen-to-nickel"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="fluid", name="propene", amount=39},
      },
      results = {
        {type="item", name="ore-nickel", amount=4},
      },
    },
    ["grade-3-nickel"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="acidgas", amount=81},
        {type="item", name="grade-1-tin", amount=3},
      },
      results = {
        {type="item", name="grade-2-nickel", amount=2},
        {type="item", name="grade-3-nickel", amount=1},
        {type="item", name="gravel", amount=2},
        {type="item", name="nickel-rejects", amount=2},
      },
    },
    ["grade-2-nickel-recrush"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="propene-canister", amount=2},
      },
      results = {
        {type="item", name="grade-1-nickel", amount=1},
        {type="item", name="sand", amount=2},
      },
    },
    ["grade-4-nickel"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="fluid", name="water", amount=675},
        {type="item", name="ceramic", amount=16},
        {type="item", name="grade-3-nickel", amount=2},
      },
      results = {
        {type="item", name="grade-4-nickel", amount=3},
      },
    },
    ["nickel-rejects-recrush"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="lubricant-barrel", amount=5},
      },
      results = {
        {type="item", name="grade-1-nickel", amount=1},
      },
    },
    ["molten-nickel-01"] = {
      mode = "repaired-to-input",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=139},
        {type="item", name="lime", amount=2},
        {type="item", name="polybutadiene-barrel", amount=4},
      },
      results = {
        {type="fluid", name="molten-nickel", amount=50},
      },
    },
    ["hotair-nickel-plate-3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.984126984126984,
      ingredients = {
        {type="fluid", name="blood", amount=338},
        {type="item", name="subcritical-water-barrel", amount=1},
      },
      results = {
        {type="item", name="nickel-plate", amount=62},
      },
    },
    ["nickel-plate-3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.02,
      ingredients = {
        {type="fluid", name="blood", amount=90},
        {type="fluid", name="oleochemicals", amount=267},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="nickel-plate", amount=51},
      },
    },
    ["tar-to-nickel"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="fluid", name="ammonia", amount=92},
        {type="fluid", name="carbon-dioxide", amount=290},
      },
      results = {
        {type="item", name="ore-nickel", amount=4},
      },
    },
    ["soda-ash"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.22,
      ingredients = {
        {type="fluid", name="water-saline", amount=248},
        {type="item", name="coal-dust", amount=46},
        {type="item", name="seaweed", amount=4},
        {type="item", name="urea", amount=1},
      },
      results = {
        {type="fluid", name="soda-ash", amount=244},
      },
    },
    ["industrial-solvent"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.63,
      ingredients = {
        {type="fluid", name="coal-gas", amount=339},
        {type="fluid", name="flue-gas", amount=760},
        {type="fluid", name="molten-glass", amount=288},
        {type="fluid", name="olefin", amount=349},
        {type="item", name="sulfur", amount=3},
      },
      results = {
        {type="fluid", name="industrial-solvent", amount=163},
      },
    },
    ["vanabins"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.01,
      ingredients = {
        {type="fluid", name="fish-oil", amount=181},
        {type="fluid", name="geothermal-water", amount=1163},
        {type="fluid", name="phytoplankton", amount=691},
        {type="item", name="nickel-plate", amount=3},
      },
      results = {
        {type="fluid", name="vanabins", amount=101},
      },
    },
    ["blue-liquor"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.05,
      ingredients = {
        {type="fluid", name="gasoline", amount=757},
        {type="fluid", name="molten-glass", amount=261},
        {type="item", name="grade-2-iron", amount=1},
        {type="item", name="skin", amount=1},
        {type="item", name="tailings-dust", amount=13},
      },
      results = {
        {type="fluid", name="blue-liquor", amount=210},
      },
    },
    ["vpulp1"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.96,
      ingredients = {
        {type="fluid", name="blue-liquor", amount=97},
        {type="fluid", name="hot-air", amount=177},
      },
      results = {
        {type="fluid", name="vpulp1", amount=96},
      },
    },
    ["molybdenum-pulp"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.85,
      ingredients = {
        {type="item", name="vitreloy", amount=2},
      },
      results = {
        {type="fluid", name="molybdenum-pulp", amount=85},
        {type="fluid", name="muddy-sludge", amount=170},
      },
    },
    ["vpulp2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.29,
      ingredients = {
        {type="fluid", name="vpulp1", amount=85},
        {type="item", name="chromium", amount=10},
        {type="item", name="sb-oxide", amount=11},
        {type="item", name="small-parts-01", amount=7},
      },
      results = {
        {type="fluid", name="vpulp2", amount=129},
      },
    },
    ["molybdenite-pulp"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.73,
      ingredients = {
        {type="item", name="glass", amount=8},
      },
      results = {
        {type="fluid", name="molybdenite-pulp", amount=73},
      },
    },
    ["vpulp3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.08353492143184,
      ingredients = {
        {type="fluid", name="manure-bacteria", amount=397},
        {type="fluid", name="methanal", amount=477},
        {type="fluid", name="molybdenum-pulp", amount=12},
        {type="item", name="phytoplankton-barrel", amount=3},
      },
      results = {
        {type="fluid", name="vpulp3", amount=56},
        {type="item", name="vanadium-oxide", amount=2},
      },
    },
    ["bitumen-to-asphalt"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="bitumen", amount=9},
        {type="fluid", name="flue-gas", amount=185},
        {type="fluid", name="hot-air", amount=83},
        {type="item", name="biomass", amount=4},
        {type="item", name="gravel", amount=1},
      },
      results = {
        {type="item", name="py-asphalt", amount=3},
      },
    },
    ["py-aluminium"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="acetone-barrel", amount=2},
        {type="item", name="boric-acid-barrel", amount=2},
        {type="item", name="ore-aluminium", amount=4},
      },
      results = {
        {type="item", name="py-aluminium", amount=3},
      },
    },
    ["py-coal-tile"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="fluid", name="medium-distillate", amount=32},
        {type="item", name="acetic-acid-barrel", amount=2},
        {type="item", name="ash", amount=5},
        {type="item", name="coarse", amount=3},
        {type="item", name="gravel", amount=53},
        {type="item", name="ground-sample01", amount=1},
      },
      results = {
        {type="item", name="py-coal-tile", amount=3},
      },
    },
    ["py-iron"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 3.5,
      ingredients = {
        {type="item", name="iron-gear-wheel", amount=2},
        {type="item", name="iron-ore", amount=29},
        {type="item", name="mukmoux-fat", amount=1},
      },
      results = {
        {type="item", name="py-iron", amount=7},
      },
    },
    ["py-nexelit"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="tar", amount=18},
        {type="item", name="capacitor1", amount=1},
        {type="item", name="clean-nexelit", amount=3},
      },
      results = {
        {type="item", name="py-nexelit", amount=3},
      },
    },
    ["py-quartz"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="fluid", name="hot-air", amount=809},
        {type="item", name="coke", amount=7},
        {type="item", name="iron-ore", amount=4},
        {type="item", name="methanol-barrel", amount=1},
      },
      results = {
        {type="item", name="py-quartz", amount=6},
      },
    },
    ["py-steel"] = {
      mode = "repaired-to-input",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=5},
        {type="fluid", name="molten-steel", amount=10},
        {type="item", name="small-parts-01", amount=1},
      },
      results = {
        {type="item", name="py-steel", amount=2},
      },
    },
    ["hydrogen-chloride"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2.43,
      ingredients = {
        {type="fluid", name="steam", amount=141},
        {type="fluid", name="water-saline", amount=643},
        {type="item", name="grade-2-lead", amount=4},
        {type="item", name="small-lamp", amount=1},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=243},
        {type="item", name="small-lamp", amount=1},
      },
    },
    ["methanol-void-denitrification"] = {
      mode = "input-preserved-untransformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ammonia", amount=189},
        {type="fluid", name="methanol", amount=100},
      },
      results = {
        {type="fluid", name="nitrogen", amount=100},
        {type="fluid", name="water", amount=100},
      },
    },
    ["purest-nitrogen-gas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.790350662960054,
      ingredients = {
        {type="fluid", name="water", amount=116},
      },
      results = {
        {type="fluid", name="nitrogen", amount=16},
        {type="fluid", name="oxygen", amount=16},
        {type="fluid", name="purest-nitrogen-gas", amount=47},
      },
    },
    ["hcl-from-guts"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.2,
      ingredients = {
        {type="item", name="skin", amount=1},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=10},
      },
    },
    ["nitrogen"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.665,
      ingredients = {
        {type="fluid", name="purest-nitrogen-gas", amount=166},
        {type="item", name="refsyngas-canister", amount=1},
      },
      results = {
        {type="fluid", name="nitrogen", amount=333},
      },
    },
    ["sulfuric-acid-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.74,
      ingredients = {
        {type="fluid", name="acidgas", amount=77},
      },
      results = {
        {type="fluid", name="sulfuric-acid", amount=37},
      },
    },
    ["zinc-chloride"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.997338001879981,
      ingredients = {
        {type="fluid", name="oxygen", amount=92},
        {type="item", name="zinc-plate", amount=1},
      },
      results = {
        {type="fluid", name="hydrogen", amount=19},
        {type="item", name="zinc-chloride", amount=1},
      },
    },
    ["active-carbon"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="nitrogen", amount=54},
        {type="item", name="cellulose", amount=1},
        {type="item", name="rich-clay", amount=12},
        {type="item", name="zinc-chloride", amount=1},
      },
      results = {
        {type="item", name="active-carbon", amount=4},
      },
    },
    ["co2-organics"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.51,
      ingredients = {
        {type="item", name="biomass", amount=5},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=153},
      },
    },
    ["drill-head"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="item", name="bolts", amount=4},
        {type="item", name="chromite-sand", amount=2},
        {type="item", name="coke", amount=2},
        {type="item", name="lead-plate", amount=5},
        {type="item", name="small-parts-01", amount=4},
        {type="item", name="steel-plate", amount=6},
      },
      results = {
        {type="item", name="drill-head", amount=4},
      },
    },
    ["drill-head-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="item", name="chromite-sand", amount=4},
        {type="item", name="lead-plate", amount=2},
        {type="item", name="small-parts-01", amount=7},
      },
      results = {
        {type="item", name="drill-head", amount=3},
      },
    },
    ["drill-head-3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2.83333333333333,
      ingredients = {
        {type="item", name="firearm-magazine", amount=2},
        {type="item", name="lead-plate", amount=22},
        {type="item", name="pipe", amount=5},
        {type="item", name="steel-chest", amount=1},
        {type="item", name="stone-wall", amount=2},
        {type="item", name="tin-plate", amount=15},
      },
      results = {
        {type="item", name="drill-head", amount=17},
      },
    },
    ["nichrome"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=72},
        {type="item", name="lime", amount=3},
        {type="item", name="nickel-plate", amount=11},
      },
      results = {
        {type="item", name="nichrome", amount=1},
      },
    },
    ["evaporate-nitrogen"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.76,
      ingredients = {
        {type="fluid", name="liquid-nitrogen", amount=4},
      },
      results = {
        {type="fluid", name="nitrogen", amount=38},
      },
    },
    ["liquid-nitrogen"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.39262665246072,
      ingredients = {
        {type="fluid", name="gasoline", amount=5},
        {type="fluid", name="nitrogen", amount=21},
        {type="fluid", name="pressured-air", amount=28},
        {type="item", name="biomass", amount=5},
        {type="item", name="ground-sample01", amount=2},
      },
      results = {
        {type="fluid", name="liquid-nitrogen", amount=7},
        {type="fluid", name="steam", amount=136},
      },
    },
    ["coalbed-gas-to-hydrogen"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.62,
      ingredients = {
        {type="fluid", name="tailings", amount=238},
        {type="item", name="coke", amount=10},
      },
      results = {
        {type="fluid", name="hydrogen", amount=186},
      },
    },
    ["drilling-fluid-0"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.34,
      ingredients = {
        {type="fluid", name="water", amount=469},
        {type="item", name="clay", amount=6},
        {type="item", name="coarse", amount=4},
        {type="item", name="limestone", amount=1},
        {type="item", name="warm-stone-brick", amount=2},
      },
      results = {
        {type="fluid", name="drilling-fluid-0", amount=67},
      },
    },
    ["minor-extract-gas-from-coalbed-3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2.53240668330792,
      ingredients = {
        {type="fluid", name="steam", amount=2777},
        {type="fluid", name="tar", amount=245},
        {type="item", name="lime", amount=3},
        {type="item", name="nickel-rejects", amount=1},
        {type="item", name="organic-solvent-barrel", amount=4},
      },
      results = {
        {type="fluid", name="coalbed-gas", amount=380},
        {type="fluid", name="water", amount=6327},
      },
    },
    ["pressured-hydrogen"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.00288684845743,
      ingredients = {
        {type="fluid", name="hot-air", amount=144},
        {type="fluid", name="hydrogen", amount=98},
        {type="fluid", name="muddy-sludge", amount=464},
        {type="item", name="lead-plate", amount=1},
      },
      results = {
        {type="fluid", name="pressured-hydrogen", amount=50},
        {type="fluid", name="steam", amount=606},
      },
    },
    ["aromatics-2-diesel2"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.02,
      ingredients = {
        {type="fluid", name="aromatics", amount=447},
        {type="fluid", name="naphtha", amount=47},
        {type="fluid", name="steam", amount=163},
      },
      results = {
        {type="fluid", name="diesel", amount=306},
      },
    },
    ["coalbed-gas-to-acidgas"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.0258494914036,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=2465},
        {type="fluid", name="hot-air", amount=241},
      },
      results = {
        {type="fluid", name="acidgas", amount=154},
        {type="fluid", name="flue-gas", amount=922},
      },
    },
    ["coalbed-gas-to-co2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.626666666666667,
      ingredients = {
        {type="fluid", name="coalbed-gas", amount=109},
        {type="fluid", name="water", amount=197},
        {type="item", name="oil-sand-slurry-barrel", amount=1},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=188},
      },
    },
    ["coalbed-gas-to-coalgas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.3625,
      ingredients = {
        {type="fluid", name="aromatics", amount=294},
        {type="fluid", name="coalbed-gas", amount=306},
        {type="item", name="lime", amount=1},
      },
      results = {
        {type="fluid", name="coal-gas", amount=545},
      },
    },
    ["coalbed-gas-to-syngas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.39,
      ingredients = {
        {type="fluid", name="coalbed-gas", amount=148},
        {type="fluid", name="geothermal-water", amount=1026},
        {type="fluid", name="tailings", amount=192},
        {type="item", name="coke", amount=8},
        {type="item", name="saps", amount=1},
      },
      results = {
        {type="fluid", name="syngas", amount=278},
      },
    },
    ["natural-gas-to-syngas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.762521364754888,
      ingredients = {
        {type="fluid", name="aromatics", amount=169},
      },
      results = {
        {type="fluid", name="flue-gas", amount=153},
        {type="fluid", name="syngas", amount=38},
      },
    },
    ["quench-ovengas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.429282238891202,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=42},
        {type="fluid", name="pressured-air", amount=64},
      },
      results = {
        {type="fluid", name="flue-gas", amount=429},
        {type="fluid", name="syngas", amount=43},
      },
    },
    ["light-oil_from_syngas"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.869149584407922,
      ingredients = {
        {type="fluid", name="flue-gas", amount=855},
        {type="fluid", name="water", amount=1828},
        {type="item", name="heavy-oil-canister", amount=3},
      },
      results = {
        {type="fluid", name="light-oil", amount=261},
        {type="fluid", name="olefin", amount=130},
        {type="fluid", name="steam", amount=1738},
      },
    },
    ["petgas-from-refsyngas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.07097069950406,
      ingredients = {
        {type="fluid", name="aromatics", amount=251},
        {type="fluid", name="refsyngas", amount=241},
        {type="fluid", name="steam", amount=129},
        {type="fluid", name="subcritical-water", amount=516},
        {type="item", name="zinc-chloride", amount=3},
      },
      results = {
        {type="fluid", name="olefin", amount=161},
        {type="fluid", name="petroleum-gas", amount=428},
      },
    },
    ["bone-solvent"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.94,
      ingredients = {
        {type="fluid", name="olefin", amount=77},
        {type="item", name="bones", amount=8},
      },
      results = {
        {type="fluid", name="organic-solvent", amount=47},
      },
    },
    ["dedicated-oleochemicals"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.216,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=278},
        {type="item", name="mukmoux-fat", amount=4},
      },
      results = {
        {type="fluid", name="oleochemicals", amount=54},
        {type="fluid", name="steam", amount=432},
      },
    },
    ["oleochemicals"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.80004019169813,
      ingredients = {
        {type="fluid", name="oxygen", amount=152},
        {type="item", name="mukmoux-fat", amount=39},
        {type="item", name="zinc-chloride", amount=2},
      },
      results = {
        {type="fluid", name="glycerol", amount=270},
        {type="fluid", name="oleochemicals", amount=540},
        {type="fluid", name="steam", amount=3601},
      },
    },
    ["petgas-methanol"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.05,
      ingredients = {
        {type="fluid", name="organic-solvent", amount=118},
        {type="fluid", name="syngas", amount=147},
      },
      results = {
        {type="fluid", name="methanol", amount=105},
        {type="fluid", name="petroleum-gas", amount=105},
      },
    },
    ["fish-oil-to-lube"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.97,
      ingredients = {
        {type="fluid", name="ammonia", amount=299},
        {type="item", name="coal-dust", amount=4},
      },
      results = {
        {type="fluid", name="lubricant", amount=97},
      },
    },
    ["olefin-lube"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.624,
      ingredients = {
        {type="fluid", name="aromatics", amount=246},
        {type="fluid", name="methanol", amount=196},
      },
      results = {
        {type="fluid", name="lubricant", amount=156},
      },
    },
    ["coal-slurry"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.56,
      ingredients = {
        {type="fluid", name="tar", amount=173},
        {type="item", name="coarse", amount=9},
        {type="item", name="moondrop-seeds", amount=5},
      },
      results = {
        {type="fluid", name="coal-slurry", amount=234},
        {type="fluid", name="water", amount=156},
      },
    },
    ["refsyngas-from-filtered-syngas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.814285714285714,
      ingredients = {
        {type="fluid", name="flue-gas", amount=197},
        {type="item", name="boron-trioxide", amount=1},
      },
      results = {
        {type="fluid", name="refsyngas", amount=57},
      },
    },
    ["fluegas-to-syngas"] = {
      mode = "repaired-to-input",
      science_level = 3,
      energy_required_multiplier = 1.06,
      ingredients = {
        {type="fluid", name="coal-gas", amount=412},
        {type="item", name="geothermal-water-barrel", amount=2},
      },
      results = {
        {type="fluid", name="syngas", amount=318},
      },
    },
    ["hydrogen-peroxide"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.58,
      ingredients = {
        {type="fluid", name="anthraquinone", amount=77},
        {type="fluid", name="oxygen", amount=94},
        {type="item", name="lime", amount=4},
        {type="item", name="nickel-plate", amount=6},
        {type="item", name="titanium-plate", amount=8},
      },
      results = {
        {type="fluid", name="hydrogen-peroxide", amount=79},
      },
    },
    ["syngas2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.871307082085209,
      ingredients = {
        {type="fluid", name="coal-gas", amount=38},
        {type="fluid", name="flue-gas", amount=168},
        {type="fluid", name="hot-air", amount=84},
      },
      results = {
        {type="fluid", name="syngas", amount=86},
        {type="fluid", name="tar", amount=26},
        {type="item", name="ash", amount=1},
      },
    },
    ["coal-slurry-fuel"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.76,
      ingredients = {
        {type="fluid", name="boric-acid", amount=528},
      },
      results = {
        {type="fluid", name="aromatics", amount=38},
        {type="fluid", name="benzene", amount=38},
      },
    },
    ["acidgas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.99333333333333,
      ingredients = {
        {type="fluid", name="syngas", amount=189},
        {type="item", name="grade-3-tin", amount=2},
        {type="item", name="sulfur", amount=11},
      },
      results = {
        {type="fluid", name="acidgas", amount=299},
      },
    },
    ["acidgas-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.442973020072298,
      ingredients = {
        {type="fluid", name="hot-air", amount=149},
        {type="fluid", name="syngas", amount=215},
      },
      results = {
        {type="fluid", name="acidgas", amount=13},
        {type="fluid", name="steam", amount=269},
      },
    },
    ["pyrite-burn"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2.0866840822603,
      ingredients = {
        {type="item", name="pitch-canister", amount=2},
        {type="item", name="purest-nitrogen-gas-barrel", amount=3},
      },
      results = {
        {type="fluid", name="acidgas", amount=105},
        {type="item", name="iron-oxide", amount=25},
      },
    },
    ["log4"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.2,
      ingredients = {
        {type="fluid", name="hot-air", amount=130},
        {type="fluid", name="water", amount=437},
      },
      results = {
        {type="item", name="log", amount=1},
      },
    },
    ["log5"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.57142857142857,
      ingredients = {
        {type="fluid", name="hot-air", amount=167},
        {type="fluid", name="pressured-water", amount=1204},
        {type="fluid", name="water", amount=653},
        {type="item", name="wood-seedling", amount=6},
      },
      results = {
        {type="item", name="log", amount=11},
      },
    },
    ["log6"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.625,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=983},
        {type="fluid", name="hot-air", amount=100},
        {type="item", name="ash", amount=12},
        {type="item", name="boron-trioxide", amount=1},
        {type="item", name="gravel", amount=3},
      },
      results = {
        {type="item", name="log", amount=5},
      },
    },
    ["wood-seedling-mk02"] = {
      mode = "repaired-to-input",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=67},
        {type="item", name="gravel", amount=13},
        {type="item", name="lime", amount=3},
        {type="item", name="navens-spore", amount=8},
      },
      results = {
        {type="item", name="wood-seedling-mk02", amount=1},
      },
    },
    ["wood-seeds-mk02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.831512384176891,
      ingredients = {
        {type="item", name="plasmids", amount=1},
        {type="item", name="tree-mk01", amount=1},
      },
      results = {
        {type="item", name="wood-seeds", amount=0.415756192088445},
        {type="item", name="wood-seeds-mk02", amount=0.00415756192088445},
      },
    },
    ["wood-seeds-mk02-breeder"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="tailings-pond", amount=1},
      },
      results = {
        {type="item", name="wood-seeds-mk02", amount=5},
      },
    },
    ["tree-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=548},
        {type="fluid", name="oxygen", amount=186},
        {type="item", name="depolymerized-organics-barrel", amount=3},
        {type="item", name="empty-planter-box", amount=2},
      },
      results = {
        {type="item", name="tree-mk02", amount=1},
      },
    },
    ["ulric"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="bio-sample01", amount=10},
        {type="item", name="earth-crustacean-sample", amount=4},
        {type="item", name="earth-generic-sample", amount=7},
        {type="item", name="planter-box", amount=31},
        {type="item", name="retrovirus", amount=15},
        {type="item", name="sea-sponge-codex", amount=2},
        {type="item", name="zipir-codex", amount=12},
      },
      results = {
        {type="item", name="ulric", amount=3},
      },
    },
    ["ulric-codex"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=17},
        {type="item", name="copper-cable", amount=109},
        {type="item", name="steam-engine", amount=6},
      },
      results = {
        {type="item", name="ulric-codex", amount=1},
      },
    },
    ["ulric-corral-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="burner-inserter", amount=14},
        {type="item", name="copper-plate", amount=102},
        {type="item", name="fiberboard", amount=106},
        {type="item", name="mechanical-parts-01", amount=2},
        {type="item", name="nexelit-plate", amount=17},
      },
      results = {
        {type="item", name="ulric-corral-mk01", amount=3},
      },
    },
    ["ulric-food-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2.16666666666667,
      ingredients = {
        {type="fluid", name="hot-air", amount=176},
        {type="fluid", name="water", amount=494},
        {type="item", name="anthracene-oil-canister", amount=1},
        {type="item", name="ash", amount=51},
        {type="item", name="bolts", amount=7},
        {type="item", name="boron-trioxide", amount=2},
        {type="item", name="coal-dust", amount=12},
        {type="item", name="fertilizer", amount=3},
        {type="item", name="ralesia", amount=4},
        {type="item", name="scrude-barrel", amount=2},
      },
      results = {
        {type="item", name="ulric-food-01", amount=13},
      },
    },
    ["ulric-cub-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.7491429351026,
      ingredients = {
        {type="item", name="creosote-barrel", amount=1},
        {type="item", name="flask", amount=2},
        {type="item", name="kerosene-barrel", amount=5},
        {type="item", name="ralesia", amount=22},
        {type="item", name="ralesia-seeds", amount=3},
        {type="item", name="tall-oil-barrel", amount=5},
      },
      results = {
        {type="item", name="barrel", amount=27},
        {type="item", name="ulric-cub", amount=5},
      },
    },
    ["ulric-manure-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.63843369623264,
      ingredients = {
        {type="item", name="creosote-barrel", amount=1},
        {type="item", name="kerosene-barrel", amount=8},
        {type="item", name="ralesia", amount=15},
      },
      results = {
        {type="item", name="barrel", amount=8},
        {type="item", name="manure", amount=5},
      },
    },
    ["ulric-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.34811594078388,
      ingredients = {
        {type="item", name="fawogae-spore", amount=13},
        {type="item", name="lead-plate", amount=3},
        {type="item", name="niobium-dust", amount=9},
        {type="item", name="pipe", amount=7},
        {type="item", name="purest-nitrogen-gas-barrel", amount=1},
        {type="item", name="ralesia", amount=8},
        {type="item", name="starch", amount=5},
        {type="item", name="tall-oil-barrel", amount=1},
      },
      results = {
        {type="item", name="barrel", amount=7},
        {type="item", name="ulric", amount=4},
      },
    },
    ["uncaged-ulric"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="outlet-gas-01-barrel", amount=5},
        {type="item", name="ralesia", amount=2},
      },
      results = {
        {type="item", name="cage", amount=2},
        {type="item", name="ulric", amount=2},
      },
    },
    ["earth-cow-sample"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="flask", amount=9},
        {type="item", name="py-science-pack-1", amount=17},
        {type="item", name="steam-engine", amount=9},
        {type="item", name="zipir-codex", amount=3},
      },
      results = {
        {type="item", name="earth-cow-sample", amount=1},
      },
    },
    ["earth-crustacean-sample"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="cdna", amount=3},
        {type="item", name="flask", amount=17},
        {type="item", name="py-science-pack-1", amount=30},
      },
      results = {
        {type="item", name="earth-crustacean-sample", amount=2},
      },
    },
    ["earth-palmtree-sample"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="earth-generic-sample", amount=3},
        {type="item", name="fawogae-codex", amount=4},
      },
      results = {
        {type="item", name="earth-palmtree-sample", amount=2},
      },
    },
    ["earth-potato-sample"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="automation-science-pack", amount=34},
        {type="item", name="controler-mk01", amount=9},
        {type="item", name="gasifier", amount=4},
        {type="item", name="grade-3-copper", amount=115},
        {type="item", name="jaw-crusher", amount=1},
        {type="item", name="kicalk-codex", amount=1},
        {type="item", name="lab", amount=36},
        {type="item", name="light-armor", amount=19},
        {type="item", name="py-science-pack-1", amount=106},
        {type="item", name="py-sinkhole", amount=6},
        {type="item", name="raw-borax", amount=1000},
      },
      results = {
        {type="item", name="earth-potato-sample", amount=2},
      },
    },
    ["earth-sea-sponge-sample"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="earth-generic-sample", amount=1},
        {type="item", name="logistic-science-pack", amount=51},
        {type="item", name="sea-sponge-codex", amount=1},
      },
      results = {
        {type="item", name="earth-sea-sponge-sample", amount=1},
      },
    },
    ["earth-bee-sample"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="battery-mk00", amount=51},
        {type="item", name="cdna", amount=2},
        {type="item", name="earth-generic-sample", amount=1},
        {type="item", name="logistic-science-pack", amount=99},
        {type="item", name="py-science-pack-1", amount=20},
      },
      results = {
        {type="item", name="earth-bee-sample", amount=2},
      },
    },
    ["earth-horse-sample"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="earth-generic-sample", amount=1},
        {type="item", name="py-science-pack-1", amount=15},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="zipir-codex", amount=20},
      },
      results = {
        {type="item", name="earth-horse-sample", amount=1},
      },
    },
    ["kicalk-sample"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="bio-sample01", amount=25},
        {type="item", name="cdna", amount=16},
        {type="item", name="earth-bear-sample", amount=2},
        {type="item", name="ralesia-codex", amount=3},
        {type="item", name="retrovirus", amount=17},
      },
      results = {
        {type="item", name="kicalk", amount=4},
      },
    },
    ["kicalk-fiber"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="item", name="poorman-wood-fence", amount=1},
      },
      results = {
        {type="item", name="raw-fiber", amount=6},
      },
    },
    ["kicalk-seeds"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 6,
      ingredients = {
        {type="item", name="poorman-wood-fence", amount=4},
        {type="item", name="ticl4", amount=3},
      },
      results = {
        {type="item", name="kicalk-seeds", amount=30},
      },
    },
    ["kicalk-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="fluid", name="water", amount=313},
        {type="item", name="coarse", amount=3},
        {type="item", name="fiber", amount=5},
        {type="item", name="subcritical-water-barrel", amount=3},
        {type="item", name="tinned-cable", amount=2},
      },
      results = {
        {type="item", name="kicalk", amount=16},
      },
    },
    ["kicalk-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.583333333333333,
      ingredients = {
        {type="fluid", name="water", amount=257},
        {type="item", name="coarse", amount=6},
        {type="item", name="fiber", amount=4},
        {type="item", name="rich-clay", amount=2},
        {type="item", name="tinned-cable", amount=2},
      },
      results = {
        {type="item", name="kicalk", amount=7},
      },
    },
    ["sea-sponge"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="aluminium-plate", amount=618},
        {type="item", name="cottongut-codex", amount=3},
        {type="item", name="creature-chamber-mk01", amount=4},
        {type="item", name="earth-generic-sample", amount=13},
      },
      results = {
        {type="item", name="sea-sponge", amount=3},
      },
    },
    ["sea-sponge-sprouts"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="offshore-pump", amount=4},
      },
      results = {
        {type="item", name="sea-sponge-sprouts", amount=2},
      },
    },
    ["sea-sponge-processing-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.9,
      ingredients = {
        {type="item", name="latex-slab", amount=1},
        {type="item", name="offshore-pump", amount=3},
      },
      results = {
        {type="item", name="ore-quartz", amount=19},
      },
    },
    ["sea-sponge-sprouts-processing-01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.714285714285714,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=1},
      },
      results = {
        {type="item", name="ore-quartz", amount=5},
      },
    },
    ["arthropod-blood-to-organic-solvent"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.907692307692308,
      ingredients = {
        {type="fluid", name="fish-oil", amount=226},
      },
      results = {
        {type="fluid", name="organic-solvent", amount=118},
      },
    },
    ["chloride-void-muddy-sludge"] = {
      mode = "input-preserved-untransformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="fluid", name="water-saline", amount=267},
        {type="item", name="gravel", amount=1},
      },
      results = {
        {type="fluid", name="tailings", amount=50},
      },
    },
    ["coarse-tar"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.742857142857143,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=2},
        {type="item", name="coal", amount=7},
      },
      results = {
        {type="fluid", name="tar", amount=52},
      },
    },
    ["cobalt-extract"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.00175019353874,
      ingredients = {
        {type="fluid", name="aromatics", amount=99},
        {type="fluid", name="methanal", amount=310},
        {type="fluid", name="methanol", amount=638},
        {type="fluid", name="pressured-air", amount=422},
        {type="item", name="sic", amount=2},
      },
      results = {
        {type="fluid", name="tailings", amount=53},
        {type="item", name="cobalt-extract", amount=3},
      },
    },
    ["flue-gas-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.40666666666667,
      ingredients = {
        {type="fluid", name="pressured-air", amount=38},
        {type="fluid", name="water", amount=905},
        {type="item", name="coal-dust", amount=6},
      },
      results = {
        {type="fluid", name="flue-gas", amount=211},
      },
    },
    ["gasoline"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.82,
      ingredients = {
        {type="fluid", name="aromatics", amount=166},
        {type="fluid", name="subcritical-water", amount=1440},
        {type="item", name="nexelit-plate", amount=2},
        {type="item", name="py-iron", amount=1},
      },
      results = {
        {type="fluid", name="gasoline", amount=123},
      },
    },
    ["olefin"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.895,
      ingredients = {
        {type="fluid", name="hydrogen", amount=386},
        {type="item", name="lead-plate", amount=3},
      },
      results = {
        {type="fluid", name="olefin", amount=179},
      },
    },
    ["sea-sponge-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2.98577910105997,
      ingredients = {
        {type="fluid", name="slacked-lime", amount=625},
        {type="item", name="cottongut-pup", amount=3},
        {type="item", name="plasmids", amount=1},
      },
      results = {
        {type="fluid", name="water-saline", amount=285},
        {type="item", name="sea-sponge", amount=3},
      },
    },
    ["sulfuric-acid"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.48,
      ingredients = {
        {type="fluid", name="molten-glass", amount=64},
        {type="item", name="sulfur", amount=5},
      },
      results = {
        {type="fluid", name="sulfuric-acid", amount=24},
      },
    },
    ["wastewater-filtration"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.89,
      ingredients = {
        {type="fluid", name="waste-water", amount=97},
        {type="item", name="lime", amount=1},
      },
      results = {
        {type="fluid", name="methanol", amount=89},
      },
    },
    ["agitator-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="duralumin", amount=7},
        {type="item", name="flue-gas-barrel", amount=14},
        {type="item", name="intermetallics", amount=2},
        {type="item", name="lab", amount=7},
        {type="item", name="pipe", amount=92},
        {type="item", name="steam-engine", amount=5},
        {type="item", name="stone-brick", amount=30},
        {type="item", name="stone-furnace", amount=38},
        {type="item", name="tinned-cable", amount=111},
        {type="item", name="titanium-plate", amount=52},
      },
      results = {
        {type="item", name="agitator-mk01", amount=1},
      },
    },
    ["centrifugal-pan-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="chromium", amount=43},
        {type="item", name="concrete", amount=108},
        {type="item", name="duralumin", amount=35},
        {type="item", name="electric-mining-drill", amount=4},
        {type="item", name="fiberboard", amount=119},
        {type="item", name="gasoline-canister", amount=3},
        {type="item", name="grade-4-tin", amount=16},
        {type="item", name="offshore-pump", amount=72},
        {type="item", name="pbsb-alloy", amount=22},
        {type="item", name="resistor1", amount=18},
        {type="item", name="steam-engine", amount=24},
        {type="item", name="thickener-mk01", amount=3},
      },
      results = {
        {type="item", name="centrifugal-pan-mk01", amount=2},
      },
    },
    ["compressor-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="dirty-syngas-canister", amount=15},
        {type="item", name="engine-unit", amount=11},
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="quenching-tower", amount=3},
        {type="item", name="steel-chest", amount=9},
        {type="item", name="vane-mk01", amount=4},
      },
      results = {
        {type="item", name="compressor-mk01", amount=2},
      },
    },
    ["gas-separator-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="ball-mill-mk01", amount=2},
        {type="item", name="chromium", amount=392},
        {type="item", name="duralumin", amount=28},
        {type="item", name="engine-unit", amount=12},
        {type="item", name="fiberboard", amount=45},
        {type="item", name="jaw-crusher", amount=6},
        {type="item", name="ore-aluminium", amount=239},
        {type="item", name="quenching-tower", amount=1},
        {type="item", name="resistor1", amount=523},
        {type="item", name="solid-separator", amount=3},
        {type="item", name="titanium-plate", amount=118},
      },
      results = {
        {type="item", name="gas-separator-mk01", amount=2},
      },
    },
    ["hydrocyclone-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="black-liquor-barrel", amount=1},
        {type="item", name="bolts", amount=29},
        {type="item", name="inductor1", amount=14},
        {type="item", name="intermetallics", amount=7},
        {type="item", name="lab", amount=2},
        {type="item", name="lead-plate", amount=51},
        {type="item", name="medium-electric-pole", amount=3},
        {type="item", name="nexelit-plate", amount=53},
        {type="item", name="pbsb-alloy", amount=24},
        {type="item", name="pipe", amount=12},
        {type="item", name="pitch-canister", amount=4},
        {type="item", name="py-tank-6500", amount=2},
      },
      results = {
        {type="item", name="hydrocyclone-mk01", amount=2},
      },
    },
    ["thickener-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=14},
        {type="item", name="assembling-machine-1", amount=1},
        {type="item", name="inductor1", amount=62},
        {type="item", name="steel-chest", amount=3},
        {type="item", name="stone-brick", amount=99},
        {type="item", name="storage-tank", amount=2},
      },
      results = {
        {type="item", name="thickener-mk01", amount=1},
      },
    },
    ["casein"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=153},
      },
      results = {
        {type="item", name="casein", amount=5},
      },
    },
    ["green-sic"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="item", name="ceramic", amount=4},
        {type="item", name="py-iron", amount=9},
        {type="item", name="tailings-dust", amount=2},
      },
      results = {
        {type="item", name="green-sic", amount=3},
      },
    },
    ["mixed-ores"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.60554301288766,
      ingredients = {
        {type="item", name="grade-1-copper", amount=1},
        {type="item", name="grade-2-copper", amount=3},
        {type="item", name="ore-chromium", amount=18},
      },
      results = {
        {type="item", name="mixed-ores", amount=8},
        {type="item", name="stone", amount=1},
      },
    },
    ["cobalt-fluoride"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=3953},
        {type="item", name="iron-pulp-01-barrel", amount=4},
        {type="item", name="oxygen-barrel", amount=7},
      },
      results = {
        {type="item", name="cobalt-fluoride", amount=3},
      },
    },
    ["quartz-tube"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="molten-glass", amount=93},
        {type="item", name="ceramic", amount=7},
        {type="item", name="empty-petri-dish", amount=8},
        {type="item", name="lime", amount=22},
        {type="item", name="tailings-dust", amount=12},
      },
      results = {
        {type="item", name="quartz-tube", amount=4},
      },
    },
    ["sic"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="condensates-canister", amount=4},
        {type="item", name="steel-furnace", amount=1},
      },
      results = {
        {type="item", name="sic", amount=8},
      },
    },
    ["artificial-blood"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.77,
      ingredients = {
        {type="fluid", name="carbolic-oil", amount=179},
        {type="item", name="chitin", amount=1},
        {type="item", name="sugar", amount=44},
      },
      results = {
        {type="fluid", name="artificial-blood", amount=77},
      },
    },
    ["decalin"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.14,
      ingredients = {
        {type="fluid", name="aromatics", amount=77},
        {type="fluid", name="pressured-water", amount=331},
        {type="fluid", name="syngas", amount=170},
        {type="item", name="bolts", amount=9},
        {type="item", name="chromium", amount=3},
        {type="item", name="titanium-plate", amount=2},
      },
      results = {
        {type="fluid", name="decalin", amount=57},
      },
    },
    ["flutec-pp6"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.95,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=1088},
        {type="item", name="copper-rejects", amount=39},
        {type="item", name="oxygen-barrel", amount=6},
      },
      results = {
        {type="fluid", name="flutec-pp6", amount=95},
      },
    },
    ["bio-oil"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.38333333333333,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=193},
        {type="fluid", name="heavy-oil", amount=376},
        {type="fluid", name="nitrogen", amount=230},
        {type="item", name="crushed-oil-sand", amount=2},
        {type="item", name="oil-sand-slurry-barrel", amount=1},
        {type="item", name="quartz-tube", amount=1},
      },
      results = {
        {type="fluid", name="bio-oil", amount=415},
        {type="item", name="quartz-tube", amount=1},
      },
    },
    ["bio-oil-3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.733333333333333,
      ingredients = {
        {type="fluid", name="bio-oil", amount=77},
      },
      results = {
        {type="item", name="raw-coal", amount=11},
      },
    },
    ["moondrop-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="fluid", name="pressured-water", amount=309},
        {type="item", name="coarse", amount=6},
        {type="item", name="moondrop-seeds", amount=3},
      },
      results = {
        {type="item", name="moondrop", amount=4},
      },
    },
    ["moondrop-mk02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.30114532096015,
      ingredients = {
        {type="fluid", name="hydrogen", amount=127},
        {type="fluid", name="steam", amount=322},
        {type="item", name="fertilizer", amount=4},
        {type="item", name="moondrop", amount=1},
        {type="item", name="moondrop-seeds", amount=10},
        {type="item", name="soil", amount=77},
        {type="item", name="soot", amount=10},
      },
      results = {
        {type="item", name="moondrop", amount=1},
        {type="item", name="moondrop-mk02", amount=0.00650572660480073},
      },
    },
    ["moondrop-seeds-mk02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="moondrop-mk02", amount=7},
      },
      results = {
        {type="item", name="moondrop", amount=1},
        {type="item", name="moondrop-mk02", amount=5},
        {type="item", name="moondrop-seeds", amount=1},
        {type="item", name="moondrop-seeds-mk02", amount=3},
      },
    },
    ["moondrop-mk02-breeder"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=515},
        {type="fluid", name="subcritical-water", amount=2358},
        {type="item", name="coal-dust", amount=9},
        {type="item", name="distilator", amount=1},
        {type="item", name="urea", amount=4},
      },
      results = {
        {type="item", name="moondrop-mk02", amount=7},
      },
    },
    ["oleochemicals-bioplastic"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="fluid", name="drilling-fluid-0", amount=308},
        {type="fluid", name="sulfuric-acid", amount=417},
        {type="item", name="belt", amount=5},
        {type="item", name="mukmoux-fat", amount=1},
      },
      results = {
        {type="item", name="plastic-bar", amount=14},
      },
    },
    ["plastic-from-casein"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.7,
      ingredients = {
        {type="fluid", name="hot-air", amount=88},
        {type="fluid", name="methanal", amount=70},
        {type="item", name="steel-furnace", amount=1},
      },
      results = {
        {type="item", name="plastic-bar", amount=14},
      },
    },
    ["plastic-from-melamine"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="melamine-resin", amount=2},
      },
      results = {
        {type="item", name="plastic-bar", amount=5},
      },
    },
    ["zipir1"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="fish-oil", amount=3504},
        {type="fluid", name="molten-glass", amount=3521},
        {type="item", name="aluminium-plate", amount=65},
        {type="item", name="cottongut-mk01", amount=4},
        {type="item", name="earth-cow-sample", amount=3},
        {type="item", name="korlex-codex", amount=1},
        {type="item", name="nichrome", amount=23},
      },
      results = {
        {type="item", name="zipir1", amount=1},
      },
    },
    ["alien-sample-02"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbolic-oil", amount=723},
        {type="fluid", name="liquid-nitrogen", amount=439},
        {type="item", name="alien-sample01", amount=1},
        {type="item", name="aluminium-plate", amount=90},
        {type="item", name="empty-petri-dish", amount=1},
        {type="item", name="outlet-gas-01-canister", amount=2},
        {type="item", name="plastic-bar", amount=6},
        {type="item", name="py-tank-6500", amount=2},
        {type="item", name="sugar", amount=22},
        {type="item", name="waste-water-barrel", amount=7},
      },
      results = {
        {type="item", name="alien-sample-02", amount=1},
      },
    },
    ["cytostatics"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="olefin-barrel", amount=3},
        {type="item", name="retrovirus", amount=20},
      },
      results = {
        {type="item", name="cytostatics", amount=1},
      },
    },
    ["dna-polymerase"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=2120},
        {type="item", name="aluminium-plate", amount=38},
        {type="item", name="stopper", amount=4},
        {type="item", name="vrauks", amount=2},
      },
      results = {
        {type="item", name="dna-polymerase", amount=1},
      },
    },
    ["manure-bacteria"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.02,
      ingredients = {
        {type="fluid", name="water", amount=508},
        {type="item", name="cellulose", amount=2},
        {type="item", name="dried-meat", amount=3},
        {type="item", name="empty-petri-dish", amount=4},
      },
      results = {
        {type="fluid", name="manure-bacteria", amount=102},
      },
    },
    ["primers"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.42857142857143,
      ingredients = {
        {type="fluid", name="water-saline", amount=436},
        {type="item", name="moss", amount=28},
        {type="item", name="petri-dish", amount=23},
        {type="item", name="ralesia-seeds", amount=9},
        {type="item", name="stopper", amount=14},
      },
      results = {
        {type="item", name="primers", amount=1},
      },
    },
    ["retrovirus-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="fluid", name="steam", amount=1002},
        {type="item", name="aluminium-plate", amount=6},
        {type="item", name="cocoon", amount=4},
        {type="item", name="lab-instrument", amount=2},
        {type="item", name="petri-dish-bacteria", amount=1},
        {type="item", name="stopper", amount=2},
      },
      results = {
        {type="item", name="retrovirus", amount=5},
      },
    },
    ["cottongut-science-green-seeds"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.62926160915115,
      ingredients = {
        {type="fluid", name="naphthalene-oil", amount=510},
        {type="item", name="cottongut-mk01", amount=22},
        {type="item", name="flask", amount=6},
        {type="item", name="olefin-barrel", amount=12},
        {type="item", name="plasmids", amount=6},
        {type="item", name="plastic-bar", amount=21},
        {type="item", name="retrovirus", amount=30},
      },
      results = {
        {type="item", name="paragen", amount=5},
        {type="item", name="solidified-sarcorus", amount=8},
      },
    },
    ["gasoline-cellulose"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.7,
      ingredients = {
        {type="fluid", name="ammonia", amount=137},
        {type="fluid", name="carbon-dioxide", amount=593},
        {type="item", name="cellulose", amount=3},
      },
      results = {
        {type="fluid", name="gasoline", amount=70},
      },
    },
    ["tuuphra-sample"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2.5,
      ingredients = {
        {type="item", name="alien-sample01", amount=13},
        {type="item", name="aluminium-plate", amount=162},
        {type="item", name="cdna", amount=5},
        {type="item", name="cottongut-codex", amount=2},
        {type="item", name="creature-chamber-mk01", amount=3},
        {type="item", name="earth-bee-sample", amount=1},
        {type="item", name="earth-generic-sample", amount=4},
        {type="item", name="ralesia-codex", amount=1},
      },
      results = {
        {type="item", name="tuuphra", amount=5},
      },
    },
    ["tuuphra-seeds"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.625,
      ingredients = {
        {type="item", name="cyanic-acid-barrel", amount=1},
        {type="item", name="fish", amount=5},
      },
      results = {
        {type="item", name="tuuphra-seeds", amount=13},
      },
    },
    ["tuuphra-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.666666666666667,
      ingredients = {
        {type="fluid", name="steam", amount=105},
        {type="fluid", name="tar", amount=313},
        {type="item", name="coke", amount=10},
        {type="item", name="ground-sample01", amount=3},
        {type="item", name="kicalk-seeds", amount=6},
      },
      results = {
        {type="item", name="tuuphra", amount=2},
      },
    },
    ["sweet-syrup"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.78,
      ingredients = {
        {type="fluid", name="oleochemicals", amount=257},
        {type="item", name="graphite", amount=4},
      },
      results = {
        {type="fluid", name="sweet-syrup", amount=39},
      },
    },
    ["a-molasse"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.769957464589459,
      ingredients = {
        {type="item", name="benzene-barrel", amount=10},
      },
      results = {
        {type="fluid", name="a-molasse", amount=77},
        {type="item", name="biomass", amount=6},
      },
    },
    ["korlex-codex"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="chromite-sand", amount=44},
        {type="item", name="copper-cable", amount=22},
        {type="item", name="inductor1", amount=109},
        {type="item", name="pipe", amount=4},
        {type="item", name="py-burner", amount=1},
        {type="item", name="small-parts-01", amount=10},
      },
      results = {
        {type="item", name="korlex-codex", amount=2},
      },
    },
    ["korlex-food-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="fish-oil", amount=45},
        {type="item", name="limestone", amount=10},
        {type="item", name="meat", amount=10},
        {type="item", name="pipe", amount=20},
        {type="item", name="ralesia-seeds", amount=11},
        {type="item", name="salt", amount=10},
        {type="item", name="stone-furnace", amount=5},
        {type="item", name="tin-plate", amount=2},
        {type="item", name="wood-seedling", amount=2},
      },
      results = {
        {type="item", name="korlex-food-01", amount=3},
      },
    },
    ["korlex"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 5,
      ingredients = {
        {type="fluid", name="fish-oil", amount=1651},
        {type="fluid", name="wax", amount=2552},
        {type="item", name="bio-sample", amount=53},
        {type="item", name="bio-sample01", amount=10},
        {type="item", name="cdna", amount=7},
        {type="item", name="earth-bear-sample", amount=2},
        {type="item", name="earth-crustacean-sample", amount=6},
        {type="item", name="earth-generic-sample", amount=11},
        {type="item", name="ralesia-codex", amount=3},
        {type="item", name="ree-solution-barrel", amount=16},
      },
      results = {
        {type="item", name="korlex", amount=5},
      },
    },
    ["korlex-milk-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.64812193329468,
      ingredients = {
        {type="item", name="benzene-barrel", amount=14},
        {type="item", name="empty-barrel-milk", amount=3},
        {type="item", name="fish", amount=4},
        {type="item", name="geothermal-water-barrel", amount=5},
        {type="item", name="glycerol-barrel", amount=2},
        {type="item", name="low-distillate-barrel", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=16},
        {type="item", name="barrel-milk", amount=5},
      },
    },
    ["korlex-pup-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.35767119136548,
      ingredients = {
        {type="item", name="artificial-blood-barrel", amount=1},
        {type="item", name="drilling-fluid-0-barrel", amount=4},
        {type="item", name="fertilizer", amount=5},
        {type="item", name="fiberboard", amount=1},
        {type="item", name="pitch-barrel", amount=37},
        {type="item", name="water-barrel", amount=19},
      },
      results = {
        {type="item", name="barrel", amount=36},
        {type="item", name="korlex-pup", amount=4},
      },
    },
    ["korlex-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.98854171987883,
      ingredients = {
        {type="fluid", name="polybutadiene", amount=1530},
        {type="item", name="condensates-barrel", amount=2},
        {type="item", name="flue-gas-barrel", amount=7},
        {type="item", name="grade-3-chromite", amount=6},
        {type="item", name="raw-gas-barrel", amount=15},
      },
      results = {
        {type="item", name="barrel", amount=15},
        {type="item", name="korlex", amount=4},
      },
    },
    ["uncaged-korlex"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bio-sample01", amount=6},
      },
      results = {
        {type="item", name="cage", amount=1},
        {type="item", name="korlex", amount=1},
      },
    },
    ["outlet-gas-02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.41492240292518,
      ingredients = {
        {type="fluid", name="coalbed-gas", amount=169},
        {type="fluid", name="organic-solvent", amount=34},
        {type="fluid", name="pressured-air", amount=193},
        {type="fluid", name="water", amount=257},
        {type="item", name="green-sic", amount=3},
      },
      results = {
        {type="fluid", name="outlet-gas-02", amount=142},
        {type="item", name="sulfur", amount=28},
      },
    },
    ["quench-redcoke"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.734805610741045,
      ingredients = {
        {type="fluid", name="molten-glass", amount=9},
        {type="fluid", name="pressured-air", amount=168},
        {type="fluid", name="water", amount=223},
        {type="item", name="green-sic", amount=1},
      },
      results = {
        {type="fluid", name="steam", amount=73},
        {type="item", name="coal-dust", amount=3},
        {type="item", name="coke", amount=22},
      },
    },
    ["redhot-coke"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.21707024631884,
      ingredients = {
        {type="fluid", name="pressured-water", amount=331},
        {type="item", name="coal", amount=25},
        {type="item", name="coarse", amount=1},
      },
      results = {
        {type="fluid", name="coke-oven-gas", amount=62},
        {type="item", name="redhot-coke", amount=6},
      },
    },
    ["outlet-gas-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.53,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=115},
        {type="fluid", name="tailings", amount=346},
        {type="item", name="ore-nickel", amount=2},
      },
      results = {
        {type="fluid", name="outlet-gas-01", amount=153},
      },
    },
    ["molybdenum-filtration"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.9,
      ingredients = {
        {type="fluid", name="molybdenum-pulp", amount=55},
        {type="item", name="filtration-media", amount=1},
        {type="item", name="vitreloy", amount=1},
      },
      results = {
        {type="item", name="molybdenum-sulfide", amount=9},
      },
    },
    ["calcinate-bone"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="chitin", amount=1},
        {type="item", name="meat", amount=6},
      },
      results = {
        {type="item", name="calcinates", amount=6},
      },
    },
    ["molybdenum-concentrate"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.49781063286463,
      ingredients = {
        {type="fluid", name="hot-air", amount=144},
        {type="fluid", name="nitrogen", amount=193},
        {type="fluid", name="scrude", amount=317},
        {type="item", name="glass", amount=14},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=219},
        {type="item", name="molybdenum-concentrate", amount=15},
      },
    },
    ["molybdenum-oxide"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.90048183364819,
      ingredients = {
        {type="fluid", name="pressured-water", amount=989},
        {type="item", name="calcinates", amount=13},
        {type="item", name="tailings-pond", amount=1},
      },
      results = {
        {type="item", name="molybdenum-oxide", amount=19},
        {type="item", name="sulfur", amount=2},
      },
    },
    ["calcinate-separation"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 6.95317016551079,
      ingredients = {
        {type="item", name="moss", amount=955},
      },
      results = {
        {type="item", name="copper-ore", amount=3},
        {type="item", name="iron-ore", amount=3},
        {type="item", name="limestone", amount=2},
        {type="item", name="ore-quartz", amount=4},
        {type="item", name="sulfur", amount=2},
      },
    },
    ["molybdenum-plate"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.66667971021735,
      ingredients = {
        {type="item", name="calcinates", amount=2},
        {type="item", name="py-local-radar", amount=2},
        {type="item", name="sand", amount=30},
        {type="item", name="urea", amount=2},
      },
      results = {
        {type="fluid", name="water", amount=17},
        {type="item", name="molybdenum-plate", amount=5},
      },
    },
    ["seaweed-mk02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="molybdenum-oxide", amount=5},
        {type="item", name="sand", amount=13},
      },
      results = {
        {type="item", name="seaweed-mk02", amount=1},
      },
    },
    ["fertilizer-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="methanal", amount=237},
        {type="item", name="ash", amount=8},
        {type="item", name="chitin", amount=1},
        {type="item", name="urea", amount=9},
      },
      results = {
        {type="item", name="fertilizer", amount=10},
      },
    },
    ["fertilizer-3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="ash", amount=1},
        {type="item", name="coal-dust", amount=8},
        {type="item", name="powdered-biomass", amount=5},
        {type="item", name="seaweed", amount=10},
        {type="item", name="urea", amount=2},
      },
      results = {
        {type="item", name="fertilizer", amount=8},
      },
    },
    ["fertilizer-fish-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.666666666666667,
      ingredients = {
        {type="fluid", name="polybutadiene", amount=423},
        {type="item", name="benzene-barrel", amount=1},
      },
      results = {
        {type="item", name="fertilizer", amount=2},
      },
    },
    ["formic-acid"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.57,
      ingredients = {
        {type="fluid", name="flue-gas", amount=689},
        {type="fluid", name="pressured-air", amount=64},
        {type="fluid", name="sulfuric-acid", amount=38},
      },
      results = {
        {type="fluid", name="formic-acid", amount=57},
      },
    },
    ["sap-seeds-mk02-gen"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=438},
        {type="item", name="automation-science-pack", amount=11},
        {type="item", name="native-flora", amount=10},
        {type="item", name="seaweed", amount=7},
        {type="item", name="urea", amount=1},
      },
      results = {
        {type="item", name="sap-seeds-mk02", amount=1},
      },
    },
    ["sap-seeds-mk02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="purest-nitrogen-gas-barrel", amount=4},
      },
      results = {
        {type="item", name="sap-seeds-mk02", amount=2},
      },
    },
    ["sap-tree-mk02-gen"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bones", amount=6},
        {type="item", name="guts", amount=1},
        {type="item", name="meat", amount=19},
        {type="item", name="sap-seeds-mk02", amount=3},
        {type="item", name="urea", amount=2},
      },
      results = {
        {type="item", name="sap-tree-mk02", amount=1},
      },
    },
    ["casein-pulp-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.730214952305784,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=104},
      },
      results = {
        {type="fluid", name="casein-pulp-01", amount=73},
        {type="fluid", name="muddy-sludge", amount=37},
      },
    },
    ["fish-hydrolysate"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.62,
      ingredients = {
        {type="fluid", name="methanal", amount=360},
        {type="item", name="fish", amount=13},
        {type="item", name="graphite", amount=2},
        {type="item", name="pressured-air-barrel", amount=1},
      },
      results = {
        {type="fluid", name="fish-hydrolysate", amount=81},
      },
    },
    ["casein-mixture-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="acetic-acid", amount=48},
        {type="fluid", name="methanal", amount=370},
      },
      results = {
        {type="fluid", name="casein-mixture", amount=40},
        {type="fluid", name="waste-water", amount=40},
      },
    },
    ["casein-pulp-02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.12,
      ingredients = {
        {type="fluid", name="casein-pulp-01", amount=21},
        {type="fluid", name="hot-air", amount=75},
        {type="fluid", name="steam", amount=255},
        {type="fluid", name="sulfuric-acid", amount=56},
      },
      results = {
        {type="fluid", name="casein-pulp-02", amount=56},
      },
    },
    ["casein-mixture-02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.46500834369633,
      ingredients = {
        {type="fluid", name="methanal", amount=335},
        {type="fluid", name="milk", amount=48},
        {type="fluid", name="oxygen", amount=201},
        {type="item", name="ore-titanium", amount=2},
      },
      results = {
        {type="fluid", name="casein-mixture", amount=88},
        {type="fluid", name="waste-water", amount=73},
      },
    },
    ["honey-wax"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="naphtha-barrel", amount=2},
        {type="item", name="raw-fiber", amount=30},
      },
      results = {
        {type="item", name="wax-barrel", amount=3},
      },
    },
    ["sugar-wax"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="cellulose", amount=4},
        {type="item", name="dried-meat", amount=7},
        {type="item", name="empty-petri-dish", amount=1},
        {type="item", name="kerosene-barrel", amount=5},
      },
      results = {
        {type="item", name="wax-barrel", amount=2},
      },
    },
    ["phosphate-mine"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="assembling-machine-2", amount=1},
        {type="item", name="ball-mill-mk01", amount=3},
        {type="item", name="burner-mining-drill", amount=5},
        {type="item", name="concrete", amount=177},
        {type="item", name="engine-unit", amount=5},
        {type="item", name="inductor1", amount=399},
        {type="item", name="long-handed-inserter", amount=1},
        {type="item", name="nexelit-plate", amount=14},
        {type="item", name="programmable-speaker", amount=5},
        {type="item", name="pump", amount=1},
        {type="item", name="py-tank-1500", amount=3},
        {type="item", name="quenching-tower", amount=1},
        {type="item", name="steam-engine", amount=8},
        {type="item", name="sulfuric-acid-barrel", amount=4},
        {type="item", name="washer", amount=1},
      },
      results = {
        {type="item", name="phosphate-mine", amount=2},
      },
    },
    ["rare-earth-mine"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="barrel", amount=106},
        {type="item", name="borax-mine", amount=1},
        {type="item", name="long-handed-inserter", amount=33},
        {type="item", name="pump", amount=13},
        {type="item", name="sulfuric-acid-barrel", amount=62},
        {type="item", name="tar-processing-unit", amount=1},
        {type="item", name="wpu-mk01", amount=8},
      },
      results = {
        {type="item", name="rare-earth-mine", amount=2},
      },
    },
    ["subcritical-water-03"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.945,
      ingredients = {
        {type="fluid", name="hot-air", amount=282},
        {type="fluid", name="vacuum", amount=180},
      },
      results = {
        {type="fluid", name="subcritical-water", amount=189},
      },
    },
    ["wax"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.96,
      ingredients = {
        {type="item", name="empty-comb", amount=13},
      },
      results = {
        {type="fluid", name="wax", amount=48},
      },
    },
    ["wax-honeycomb"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.28,
      ingredients = {
        {type="item", name="concrete-wall", amount=2},
        {type="item", name="geothermal-water-barrel", amount=3},
        {type="item", name="repair-pack", amount=1},
      },
      results = {
        {type="fluid", name="wax", amount=64},
      },
    },
    ["empty-comb-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.375,
      ingredients = {
        {type="fluid", name="wax", amount=40},
      },
      results = {
        {type="item", name="empty-comb", amount=3},
      },
    },
    ["empty-honeycomb-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="benzene", amount=429},
        {type="fluid", name="phytoplankton", amount=45},
      },
      results = {
        {type="item", name="empty-honeycomb", amount=8},
      },
    },
    ["big-electric-pole"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="niobium-dust", amount=7},
        {type="item", name="pipe", amount=12},
        {type="item", name="starch", amount=10},
      },
      results = {
        {type="item", name="big-electric-pole", amount=1},
      },
    },
    ["breed-fish-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=255},
        {type="fluid", name="water", amount=1452},
        {type="item", name="biomass", amount=10},
        {type="item", name="capacitor1", amount=3},
        {type="item", name="fertilizer", amount=15},
        {type="item", name="fish-food-01", amount=1},
        {type="item", name="tinned-cable", amount=11},
      },
      results = {
        {type="fluid", name="waste-water", amount=100},
        {type="item", name="fish", amount=20},
      },
    },
    ["breed-fish-egg-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.26542340193079,
      ingredients = {
        {type="fluid", name="hot-air", amount=589},
        {type="item", name="cellulose", amount=1},
        {type="item", name="fish", amount=9},
        {type="item", name="fish-food-01", amount=2},
        {type="item", name="limestone", amount=12},
        {type="item", name="small-parts-01", amount=9},
      },
      results = {
        {type="fluid", name="waste-water", amount=126},
        {type="item", name="fish-egg", amount=38},
      },
    },
    ["fish-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.398145764425416,
      ingredients = {
        {type="fluid", name="methanal", amount=250},
        {type="item", name="fish", amount=12},
        {type="item", name="moss", amount=7},
        {type="item", name="offshore-pump", amount=2},
      },
      results = {
        {type="item", name="fish", amount=5},
        {type="item", name="fish-mk02", amount=0.00199072882212708},
      },
    },
    ["fish-egg-mk02-breeder"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.26912439483401,
      ingredients = {
        {type="fluid", name="ammonia", amount=109},
        {type="fluid", name="hot-air", amount=589},
        {type="fluid", name="water", amount=711},
        {type="item", name="clean-nexelit", amount=6},
        {type="item", name="kerosene-canister", amount=9},
        {type="item", name="nitrogen-barrel", amount=17},
        {type="item", name="tinned-cable", amount=11},
      },
      results = {
        {type="fluid", name="waste-water", amount=128},
        {type="item", name="fish-egg", amount=1},
        {type="item", name="fish-egg-mk02", amount=14},
      },
    },
    ["fish-mk02-breeder"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.438548478111954,
      ingredients = {
        {type="fluid", name="ammonia", amount=75},
        {type="fluid", name="water", amount=1067},
        {type="item", name="agar", amount=1},
        {type="item", name="clean-nexelit", amount=11},
        {type="item", name="nitrogen-barrel", amount=12},
        {type="item", name="tinned-cable", amount=7},
      },
      results = {
        {type="fluid", name="waste-water", amount=45},
        {type="item", name="fish", amount=1},
        {type="item", name="fish-mk02", amount=3},
      },
    },
    ["cliff-explosives"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="pcb1", amount=1},
        {type="item", name="pitch-barrel", amount=23},
        {type="item", name="ralesia-seeds", amount=4},
        {type="item", name="stopper", amount=1},
      },
      results = {
        {type="item", name="cliff-explosives", amount=1},
      },
    },
    ["fast-inserter"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="burner-inserter", amount=6},
        {type="item", name="duralumin", amount=7},
        {type="item", name="fenxsb-alloy", amount=1},
        {type="item", name="niobium-oxide", amount=4},
        {type="item", name="pipe", amount=17},
        {type="item", name="polybutadiene-barrel", amount=4},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="transport-belt", amount=1},
      },
      results = {
        {type="item", name="fast-inserter", amount=1},
      },
    },
    ["py-stack-inserter"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=159},
        {type="item", name="acetone-barrel", amount=7},
        {type="item", name="acetylene-barrel", amount=14},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="residual-oil-barrel", amount=18},
        {type="item", name="small-lamp", amount=7},
        {type="item", name="tinned-cable", amount=453},
      },
      results = {
        {type="item", name="py-stack-inserter", amount=2},
      },
    },
    ["flavonoids"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.933333333333333,
      ingredients = {
        {type="item", name="fish", amount=3},
        {type="item", name="ralesia", amount=40},
      },
      results = {
        {type="fluid", name="flavonoids", amount=28},
      },
    },
    ["mo-mine"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="btx-canister", amount=15},
        {type="item", name="burner-mining-drill", amount=41},
        {type="item", name="duralumin", amount=10},
        {type="item", name="electronic-circuit", amount=6},
        {type="item", name="inductor1", amount=90},
        {type="item", name="intermetallics", amount=3},
        {type="item", name="iron-plate", amount=114},
        {type="item", name="jaw-crusher", amount=1},
        {type="item", name="py-tank-3000", amount=2},
        {type="item", name="py-underflow-valve", amount=2},
        {type="item", name="steam-engine", amount=7},
        {type="item", name="tinned-cable", amount=128},
      },
      results = {
        {type="item", name="mo-mine", amount=1},
      },
    },
    ["niobium-pipe"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="coal-dust", amount=5},
        {type="item", name="niobium-dust", amount=6},
      },
      results = {
        {type="item", name="niobium-pipe", amount=3},
      },
    },
    ["niobium-pipe-to-ground"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="pipe", amount=29},
        {type="item", name="stone-furnace", amount=2},
      },
      results = {
        {type="item", name="niobium-pipe-to-ground", amount=2},
      },
    },
    ["py-logistic-robot-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="barrel", amount=11},
        {type="item", name="botanical-nursery", amount=1},
        {type="item", name="condensates-canister", amount=3},
        {type="item", name="engine-unit", amount=7},
        {type="item", name="gold-plate", amount=2},
        {type="item", name="inductor1", amount=275},
        {type="item", name="lab", amount=6},
        {type="item", name="lead-plate", amount=14},
        {type="item", name="molten-nickel-barrel", amount=17},
        {type="item", name="petri-dish", amount=7},
        {type="item", name="pipe", amount=39},
        {type="item", name="plastic-bar", amount=12},
        {type="item", name="repair-pack", amount=2},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="steel-plate", amount=92},
        {type="item", name="tuuphra-seeds", amount=11},
        {type="item", name="wood-fence", amount=43},
        {type="item", name="zinc-chloride", amount=6},
      },
      results = {
        {type="item", name="py-logistic-robot-mk01", amount=4},
      },
    },
    ["yaedols-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="fluid", name="pressured-air", amount=126},
        {type="item", name="auog-pup", amount=1},
        {type="item", name="fungal-substrate", amount=2},
        {type="item", name="moondrop-seeds", amount=7},
        {type="item", name="sodium-hydroxide", amount=4},
        {type="item", name="urea", amount=6},
      },
      results = {
        {type="item", name="yaedols", amount=5},
      },
    },
    ["yaedols-sample"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="bio-sample", amount=33},
        {type="item", name="bio-sample01", amount=17},
        {type="item", name="cdna", amount=20},
        {type="item", name="earth-bear-sample", amount=2},
        {type="item", name="primers", amount=5},
        {type="item", name="sea-sponge-codex", amount=3},
        {type="item", name="wood", amount=907},
      },
      results = {
        {type="item", name="yaedols", amount=4},
      },
    },
    ["anthracene-gasoline-hydrogenation"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.64,
      ingredients = {
        {type="fluid", name="hot-air", amount=352},
      },
      results = {
        {type="fluid", name="gasoline", amount=16},
      },
    },
    ["anthraquinone-from-naphthalene"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.92,
      ingredients = {
        {type="fluid", name="methanal", amount=290},
        {type="item", name="phytoplankton-barrel", amount=5},
      },
      results = {
        {type="fluid", name="anthraquinone", amount=92},
      },
    },
    ["aromatics-from-naphthalene"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.311103871373892,
      ingredients = {
        {type="fluid", name="hot-air", amount=432},
      },
      results = {
        {type="fluid", name="aromatics", amount=12},
        {type="item", name="coke", amount=1},
      },
    },
    ["bitumen-to-heavy-oil"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.39,
      ingredients = {
        {type="fluid", name="bitumen", amount=70},
        {type="fluid", name="muddy-sludge", amount=120},
        {type="fluid", name="steam", amount=64},
        {type="fluid", name="water-saline", amount=144},
        {type="item", name="gravel", amount=3},
      },
      results = {
        {type="fluid", name="heavy-oil", amount=139},
      },
    },
    ["hot-residual-mixture-to-coke"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.543377094461457,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=151},
        {type="fluid", name="heavy-oil", amount=109},
        {type="fluid", name="hydrogen", amount=136},
        {type="fluid", name="water-saline", amount=47},
      },
      results = {
        {type="fluid", name="coke-oven-gas", amount=32},
        {type="item", name="coke", amount=22},
      },
    },
    ["naphthalene-solvent"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="fluid", name="hot-air", amount=3216},
        {type="fluid", name="methanal", amount=369},
      },
      results = {
        {type="fluid", name="organic-solvent", amount=50},
      },
    },
    ["natural-gas-01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.975,
      ingredients = {
        {type="fluid", name="drilling-fluid-0", amount=46},
        {type="fluid", name="hot-air", amount=85},
        {type="item", name="pipe", amount=3},
      },
      results = {
        {type="fluid", name="raw-gas", amount=39},
      },
    },
    ["oil-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.275,
      ingredients = {
        {type="fluid", name="drilling-fluid-0", amount=18},
        {type="fluid", name="molten-steel", amount=1},
      },
      results = {
        {type="fluid", name="crude-oil", amount=11},
      },
    },
    ["rubber-02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="boric-acid", amount=357},
        {type="item", name="auog-food-01", amount=1},
        {type="item", name="bio-container", amount=4},
        {type="item", name="carbon-black", amount=1},
        {type="item", name="latex", amount=2},
        {type="item", name="soil", amount=94},
        {type="item", name="tall-oil-barrel", amount=1},
      },
      results = {
        {type="item", name="rubber", amount=6},
      },
    },
    ["rubber-from-oleochemicals"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="fluid", name="drilling-fluid-0", amount=309},
        {type="item", name="belt", amount=14},
        {type="item", name="latex-slab", amount=1},
        {type="item", name="mukmoux-fat", amount=1},
        {type="item", name="sic", amount=1},
      },
      results = {
        {type="item", name="rubber", amount=3},
      },
    },
    ["tar-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.06,
      ingredients = {
        {type="fluid", name="drilling-fluid-0", amount=52},
        {type="item", name="pipe", amount=4},
      },
      results = {
        {type="fluid", name="tar", amount=106},
      },
    },
    ["ticl4"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="fluid", name="water-saline", amount=136},
        {type="item", name="rich-clay", amount=4},
        {type="item", name="scrude-barrel", amount=1},
        {type="item", name="titanium-plate", amount=2},
      },
      results = {
        {type="item", name="ticl4", amount=5},
      },
    },
    ["methane-to-methanol5"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.94,
      ingredients = {
        {type="fluid", name="hot-air", amount=119},
        {type="fluid", name="methane", amount=92},
        {type="item", name="sncr-alloy", amount=1},
      },
      results = {
        {type="fluid", name="methanol", amount=141},
      },
    },
    ["methane-to-methanol6"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.55,
      ingredients = {
        {type="fluid", name="hot-air", amount=295},
        {type="fluid", name="methane", amount=587},
        {type="item", name="bolts", amount=14},
        {type="item", name="sncr-alloy", amount=3},
      },
      results = {
        {type="fluid", name="methanol", amount=465},
      },
    },
    ["naphtha-to-syngas"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.2175,
      ingredients = {
        {type="fluid", name="pitch", amount=56},
        {type="fluid", name="water", amount=1014},
      },
      results = {
        {type="fluid", name="syngas", amount=87},
      },
    },
    ["reheat-coke-gas"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.42,
      ingredients = {
        {type="fluid", name="chlorine", amount=140},
        {type="fluid", name="coke-oven-gas", amount=95},
      },
      results = {
        {type="fluid", name="coke-oven-gas", amount=95},
        {type="fluid", name="molten-salt", amount=21},
      },
    },
    ["warmer-stone-brick-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=100},
        {type="item", name="warm-stone-brick", amount=5},
      },
      results = {
        {type="fluid", name="coke-oven-gas", amount=100},
        {type="item", name="warmer-stone-brick", amount=5},
      },
    },
    ["warmer-air-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="item", name="kerogen", amount=37},
      },
      results = {
        {type="fluid", name="hot-air", amount=225},
        {type="item", name="stone-brick", amount=15},
      },
    },
    ["aromatics-2-diesel"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.34,
      ingredients = {
        {type="fluid", name="boric-acid", amount=99},
        {type="fluid", name="naphtha", amount=77},
        {type="fluid", name="scrude", amount=32},
        {type="item", name="sncr-alloy", amount=1},
      },
      results = {
        {type="fluid", name="diesel", amount=119},
      },
    },
    ["aromatics-2-petgas2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.736666666666667,
      ingredients = {
        {type="fluid", name="pressured-water", amount=1039},
        {type="fluid", name="syngas", amount=173},
        {type="item", name="bolts", amount=4},
      },
      results = {
        {type="fluid", name="petroleum-gas", amount=221},
      },
    },
    ["bio-oil-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.40229722627551,
      ingredients = {
        {type="fluid", name="bio-oil", amount=192},
        {type="fluid", name="muddy-sludge", amount=2577},
      },
      results = {
        {type="fluid", name="condensates", amount=211},
        {type="fluid", name="low-distillate", amount=70},
        {type="fluid", name="medium-distillate", amount=70},
      },
    },
    ["low-distillate-to-btx"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.41,
      ingredients = {
        {type="fluid", name="methanal", amount=188},
        {type="item", name="bolts", amount=3},
      },
      results = {
        {type="fluid", name="btx", amount=41},
      },
    },
    ["medium-distillate-to-high-distillate"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.99,
      ingredients = {
        {type="fluid", name="tailings", amount=638},
        {type="item", name="carbon-black", amount=1},
      },
      results = {
        {type="fluid", name="high-distillate", amount=99},
      },
    },
    ["medium-distillate-to-stripped-distillate"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.83,
      ingredients = {
        {type="fluid", name="methanal", amount=665},
        {type="fluid", name="tailings", amount=408},
        {type="item", name="light-oil-canister", amount=1},
      },
      results = {
        {type="fluid", name="stripped-distillate", amount=183},
      },
    },
    ["low-distillate-to-coal-gas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.685,
      ingredients = {
        {type="fluid", name="low-distillate", amount=97},
        {type="fluid", name="methanal", amount=372},
        {type="item", name="bolts", amount=9},
      },
      results = {
        {type="fluid", name="coal-gas", amount=337},
      },
    },
    ["stripped-distillate-to-benzene"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.766666666666667,
      ingredients = {
        {type="fluid", name="coalbed-gas", amount=329},
        {type="item", name="bolts", amount=7},
      },
      results = {
        {type="fluid", name="benzene", amount=115},
      },
    },
    ["stripped-distillate-to-cumene"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.635,
      ingredients = {
        {type="fluid", name="heavy-oil", amount=309},
        {type="fluid", name="water-saline", amount=548},
        {type="item", name="bolts", amount=8},
        {type="item", name="sncr-alloy", amount=1},
      },
      results = {
        {type="fluid", name="cumene", amount=327},
      },
    },
    ["stripped-distillate-to-gasoline"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.73,
      ingredients = {
        {type="fluid", name="water-saline", amount=655},
        {type="item", name="bolts", amount=4},
      },
      results = {
        {type="fluid", name="gasoline", amount=146},
      },
    },
    ["stripped-distillate-to-methanol"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.853333333333333,
      ingredients = {
        {type="fluid", name="purest-nitrogen-gas", amount=761},
        {type="item", name="bolts", amount=5},
        {type="item", name="oxygen-barrel", amount=1},
      },
      results = {
        {type="fluid", name="methanol", amount=128},
      },
    },
    ["fluorine-to-olefins"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.795032192708237,
      ingredients = {
        {type="fluid", name="btx", amount=48},
        {type="fluid", name="gasoline", amount=517},
        {type="item", name="zinc-plate", amount=1},
      },
      results = {
        {type="fluid", name="naphtha", amount=40},
        {type="fluid", name="olefin", amount=79},
      },
    },
    ["high-distillate-condensing"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.1377325228516,
      ingredients = {
        {type="fluid", name="pitch", amount=639},
        {type="fluid", name="water", amount=3219},
        {type="item", name="graphite", amount=1},
      },
      results = {
        {type="fluid", name="condensed-distillate", amount=57},
        {type="fluid", name="naphtha", amount=170},
      },
    },
    ["natural-gas-refining"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.56,
      ingredients = {
        {type="fluid", name="coal-slurry", amount=454},
        {type="fluid", name="gasoline", amount=40},
        {type="fluid", name="muddy-sludge", amount=201},
        {type="item", name="coal-dust", amount=4},
        {type="item", name="urea", amount=2},
      },
      results = {
        {type="fluid", name="condensates", amount=56},
        {type="fluid", name="naphtha", amount=28},
        {type="fluid", name="natural-gas", amount=140},
      },
    },
    ["refined-natural-gas-to-condensates"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.7,
      ingredients = {
        {type="fluid", name="water-saline", amount=296},
      },
      results = {
        {type="fluid", name="condensates", amount=70},
        {type="fluid", name="naphtha", amount=35},
        {type="fluid", name="steam", amount=140},
      },
    },
    ["condensed-distillate-separation"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.04830045885616,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=633},
        {type="fluid", name="heavy-oil", amount=569},
        {type="fluid", name="phytoplankton", amount=62},
      },
      results = {
        {type="fluid", name="gasoline", amount=26},
        {type="fluid", name="petroleum-gas", amount=53},
      },
    },
    ["low-distillate-to-heavy-oil"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.996228565071113,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=358},
        {type="fluid", name="low-distillate", amount=97},
        {type="fluid", name="methanal", amount=29},
      },
      results = {
        {type="fluid", name="heavy-oil", amount=199},
        {type="fluid", name="residual-oil", amount=50},
        {type="fluid", name="steam", amount=597},
      },
    },
    ["naphtha-2-tall-oil"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="fluid", name="naphtha", amount=113},
      },
      results = {
        {type="fluid", name="tall-oil", amount=75},
      },
    },
    ["bitumen-comb"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2.92325397080949,
      ingredients = {
        {type="item", name="raw-gas-barrel", amount=2},
      },
      results = {
        {type="fluid", name="bitumen", amount=138},
        {type="item", name="used-comb", amount=3},
      },
    },
    ["raw-gas"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="condensates", amount=97},
        {type="fluid", name="pressured-air", amount=72},
      },
      results = {
        {type="fluid", name="btx", amount=30},
        {type="fluid", name="refined-natural-gas", amount=100},
        {type="fluid", name="tailings", amount=50},
      },
    },
    ["residual-mixture"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.15,
      ingredients = {
        {type="fluid", name="ammonia", amount=67},
        {type="fluid", name="molten-glass", amount=172},
        {type="fluid", name="water", amount=254},
        {type="item", name="biomass", amount=118},
      },
      results = {
        {type="fluid", name="residual-mixture", amount=115},
      },
    },
    ["bio-oil-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.963929782331477,
      ingredients = {
        {type="fluid", name="acidgas", amount=357},
      },
      results = {
        {type="fluid", name="condensates", amount=155},
        {type="item", name="ash", amount=2},
        {type="item", name="raw-coal", amount=19},
      },
    },
    ["bitumen-refining"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.30924281450122,
      ingredients = {
        {type="fluid", name="bitumen", amount=435},
      },
      results = {
        {type="fluid", name="condensates", amount=33},
        {type="fluid", name="high-distillate", amount=33},
        {type="fluid", name="low-distillate", amount=131},
        {type="fluid", name="medium-distillate", amount=98},
        {type="fluid", name="residual-mixture", amount=327},
      },
    },
    ["crude-from-manure"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.00870634025116,
      ingredients = {
        {type="fluid", name="acidgas", amount=268},
        {type="fluid", name="blood", amount=217},
      },
      results = {
        {type="fluid", name="scrude", amount=72},
        {type="fluid", name="steam", amount=51},
        {type="fluid", name="tailings", amount=51},
        {type="item", name="soot", amount=3},
      },
    },
    ["hot-residual-mixture"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.28,
      ingredients = {
        {type="item", name="iron-oxide", amount=3},
      },
      results = {
        {type="fluid", name="hot-residual-mixture", amount=28},
      },
    },
    ["oil-refining"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.889887497306303,
      ingredients = {
        {type="fluid", name="gasoline", amount=219},
      },
      results = {
        {type="fluid", name="condensates", amount=111},
        {type="fluid", name="high-distillate", amount=111},
        {type="fluid", name="low-distillate", amount=89},
        {type="fluid", name="medium-distillate", amount=89},
        {type="fluid", name="residual-mixture", amount=45},
      },
    },
    ["residual-mixture-distillation"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.702677636109083,
      ingredients = {
        {type="fluid", name="vacuum", amount=193},
        {type="fluid", name="water-saline", amount=371},
        {type="item", name="iron-oxide", amount=1},
      },
      results = {
        {type="fluid", name="hot-residual-mixture", amount=18},
        {type="fluid", name="residual-oil", amount=35},
        {type="item", name="coke", amount=28},
      },
    },
    ["used-comb-oil-recycling"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.855422786043443,
      ingredients = {
        {type="item", name="acetone-barrel", amount=1},
      },
      results = {
        {type="fluid", name="bitumen", amount=21},
        {type="fluid", name="residual-oil", amount=43},
      },
    },
    ["used-comb-to-residual-mixture"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.16666666666667,
      ingredients = {
        {type="item", name="barrel", amount=9},
        {type="item", name="empty-comb", amount=2},
      },
      results = {
        {type="fluid", name="residual-mixture", amount=70},
      },
    },
    ["arqad-codex"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=23},
        {type="item", name="copper-cable", amount=42},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="lead-plate", amount=8},
        {type="item", name="sncr-alloy", amount=3},
        {type="item", name="tinned-cable", amount=4},
      },
      results = {
        {type="item", name="arqad-codex", amount=1},
      },
    },
    ["arqad-egg-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.79723573834882,
      ingredients = {
        {type="item", name="arqad-queen", amount=1},
        {type="item", name="automation-science-pack", amount=14},
        {type="item", name="condensed-distillate-canister", amount=2},
        {type="item", name="fiberboard", amount=7},
      },
      results = {
        {type="item", name="arqad-egg", amount=8},
        {type="item", name="arqad-queen", amount=1},
        {type="item", name="barrel", amount=10},
      },
    },
    ["arqad-filled-comb-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-food-01", amount=1},
        {type="item", name="bio-container", amount=2},
        {type="item", name="soil", amount=53},
        {type="item", name="tall-oil-barrel", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=2},
        {type="item", name="filled-comb", amount=5},
      },
    },
    ["arqad-filled-honeycomb-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.666666666666667,
      ingredients = {
        {type="item", name="concrete-wall", amount=3},
        {type="item", name="geothermal-water-barrel", amount=2},
      },
      results = {
        {type="item", name="honeycomb", amount=2},
      },
    },
    ["arqad"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.91909449545666,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=1863},
        {type="item", name="aluminium-plate", amount=109},
        {type="item", name="earth-generic-sample", amount=5},
        {type="item", name="earth-palmtree-sample", amount=3},
        {type="item", name="korlex-codex", amount=2},
        {type="item", name="py-science-pack-1", amount=7},
        {type="item", name="steam-engine", amount=16},
      },
      results = {
        {type="item", name="arqad", amount=2},
        {type="item", name="arqad-egg", amount=19},
      },
    },
    ["arqad-egg-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.13459982050465,
      ingredients = {
        {type="item", name="arqad", amount=2},
        {type="item", name="arqad-queen", amount=1},
        {type="item", name="honeycomb", amount=37},
        {type="item", name="mukmoux-fat", amount=5},
        {type="item", name="py-tank-3000", amount=1},
      },
      results = {
        {type="item", name="arqad-egg", amount=17},
        {type="item", name="arqad-queen", amount=1},
        {type="item", name="barrel", amount=15},
      },
    },
    ["arqad-hive-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=15},
        {type="item", name="anthracene-oil-barrel", amount=2},
        {type="item", name="barrel", amount=12},
        {type="item", name="blood-barrel", amount=1},
        {type="item", name="brake-mk01", amount=1},
        {type="item", name="duralumin", amount=6},
        {type="item", name="electric-mining-drill", amount=8},
        {type="item", name="gasifier", amount=1},
        {type="item", name="gasoline-canister", amount=7},
        {type="item", name="inductor1", amount=40},
        {type="item", name="nexelit-plate", amount=51},
        {type="item", name="pbsb-alloy", amount=17},
        {type="item", name="phosphate-rock", amount=43},
      },
      results = {
        {type="item", name="arqad-hive-mk01", amount=1},
      },
    },
    ["arqad-egg-nests-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="btx-barrel", amount=1},
        {type="item", name="cocoon", amount=10},
        {type="item", name="concrete-wall", amount=2},
        {type="item", name="geothermal-water-barrel", amount=3},
        {type="item", name="offshore-pump", amount=34},
        {type="item", name="shaft-mk01", amount=2},
        {type="item", name="vrauks-food-01", amount=1},
      },
      results = {
        {type="item", name="arqad-egg-nest", amount=2},
        {type="item", name="barrel", amount=2},
      },
    },
    ["arqad-maggots-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.29744287165373,
      ingredients = {
        {type="item", name="caged-vrauks", amount=8},
        {type="item", name="carbon-dioxide-barrel", amount=10},
        {type="item", name="duralumin", amount=26},
        {type="item", name="empty-comb", amount=23},
        {type="item", name="fenxsb-alloy", amount=36},
        {type="item", name="fiberboard", amount=5},
        {type="item", name="lead-plate", amount=12},
        {type="item", name="nexelit-plate", amount=21},
        {type="item", name="py-tank-1500", amount=3},
        {type="item", name="raw-fiber", amount=146},
        {type="item", name="steam-engine", amount=4},
      },
      results = {
        {type="item", name="arqad-maggot", amount=39},
        {type="item", name="cage", amount=13},
        {type="item", name="used-comb", amount=6},
      },
    },
    ["arqad-queen-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2.57669992124481,
      ingredients = {
        {type="item", name="automation-science-pack", amount=6},
        {type="item", name="classifier", amount=1},
        {type="item", name="cobalt-fluoride", amount=4},
        {type="item", name="condensed-distillate-canister", amount=2},
        {type="item", name="fiberboard", amount=24},
        {type="item", name="low-grade-copper", amount=4},
      },
      results = {
        {type="item", name="arqad-queen", amount=0.0256532011966201},
        {type="item", name="barrel", amount=21},
        {type="item", name="used-comb", amount=3},
      },
    },
    ["caged-arqad-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.672388343325003,
      ingredients = {
        {type="item", name="chromite-sand", amount=148},
        {type="item", name="fiberboard", amount=1},
        {type="item", name="offshore-pump", amount=1},
        {type="item", name="ralesia-seeds", amount=9},
        {type="item", name="solid-separator", amount=1},
        {type="item", name="tall-oil-barrel", amount=4},
        {type="item", name="vrauks-food-01", amount=1},
      },
      results = {
        {type="item", name="arqad", amount=5},
        {type="item", name="barrel", amount=7},
        {type="item", name="used-comb", amount=1},
      },
    },
    ["caged-arqad-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.99060848373524,
      ingredients = {
        {type="item", name="py-stack-inserter", amount=1},
        {type="item", name="tall-oil-barrel", amount=19},
      },
      results = {
        {type="item", name="arqad", amount=6},
        {type="item", name="barrel", amount=19},
        {type="item", name="used-comb", amount=2},
      },
    },
    ["honey-comb"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.24297116288825,
      ingredients = {
        {type="item", name="shaft-mk01", amount=1},
      },
      results = {
        {type="fluid", name="arqad-honey", amount=315},
        {type="item", name="empty-honeycomb", amount=6},
      },
    },
    ["hotair-empty-honeycomb-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.7,
      ingredients = {
        {type="fluid", name="hydrogen-chloride", amount=216},
        {type="fluid", name="wax", amount=91},
      },
      results = {
        {type="item", name="empty-honeycomb", amount=17},
      },
    },
    ["bitumen-to-nitrogen"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.135,
      ingredients = {
        {type="fluid", name="bitumen", amount=82},
        {type="fluid", name="propene", amount=16},
      },
      results = {
        {type="fluid", name="nitrogen", amount=227},
      },
    },
    ["bitumen-to-sulfur"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.1,
      ingredients = {
        {type="fluid", name="steam", amount=123},
      },
      results = {
        {type="item", name="sulfur", amount=1},
      },
    },
    ["crush-oil-sand"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="belt", amount=1},
      },
      results = {
        {type="item", name="crushed-oil-sand", amount=2},
        {type="item", name="stone", amount=1},
      },
    },
    ["bitumen-gasification"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.67,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=69},
        {type="fluid", name="oxygen", amount=21},
        {type="fluid", name="water-saline", amount=195},
      },
      results = {
        {type="fluid", name="dirty-syngas", amount=67},
      },
    },
    ["hot-syngas-cooldown"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.766082661059125,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=142},
        {type="fluid", name="hot-syngas", amount=77},
      },
      results = {
        {type="fluid", name="steam", amount=230},
        {type="fluid", name="syngas", amount=383},
      },
    },
    ["quenching-dirty-syngas"] = {
      mode = "repaired-to-input",
      science_level = 3,
      energy_required_multiplier = 1.20496264682692,
      ingredients = {
        {type="fluid", name="acidgas", amount=757},
        {type="fluid", name="steam", amount=634},
        {type="item", name="refsyngas-barrel", amount=1},
      },
      results = {
        {type="fluid", name="flue-gas", amount=4754},
        {type="fluid", name="purified-syngas", amount=475},
        {type="item", name="soot", amount=10},
      },
    },
    ["scrubbing-purified-syngas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.513348496753414,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=238},
        {type="fluid", name="hot-air", amount=113},
        {type="fluid", name="purified-syngas", amount=42},
      },
      results = {
        {type="fluid", name="hot-syngas", amount=52},
        {type="item", name="soot", amount=1},
      },
    },
    ["oil-sand-slurry"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.31,
      ingredients = {
        {type="fluid", name="hot-air", amount=76},
        {type="fluid", name="hydrogen", amount=162},
        {type="fluid", name="pressured-water", amount=292},
        {type="fluid", name="syngas", amount=36},
        {type="item", name="lead-plate", amount=1},
        {type="item", name="plastic-bar", amount=3},
      },
      results = {
        {type="fluid", name="oil-sand-slurry", amount=131},
      },
    },
    ["bitumen-froth"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="fluid", name="oil-sand-slurry", amount=173},
        {type="fluid", name="pressured-air", amount=275},
        {type="item", name="empty-honeycomb", amount=1},
      },
      results = {
        {type="fluid", name="bitumen-froth", amount=140},
        {type="fluid", name="tailings", amount=140},
      },
    },
    ["btx-to-benzene"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.09,
      ingredients = {
        {type="fluid", name="btx", amount=42},
        {type="fluid", name="hot-air", amount=149},
        {type="fluid", name="pressured-air", amount=143},
        {type="fluid", name="water-saline", amount=277},
        {type="item", name="nexelit-plate", amount=1},
      },
      results = {
        {type="fluid", name="benzene", amount=218},
      },
    },
    ["btx-to-methane"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.993333333333333,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=135},
        {type="fluid", name="low-distillate", amount=36},
        {type="fluid", name="oxygen", amount=81},
        {type="fluid", name="pitch", amount=426},
        {type="item", name="chromium", amount=1},
      },
      results = {
        {type="fluid", name="methane", amount=298},
      },
    },
    ["aromatics-to-petgas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.8625,
      ingredients = {
        {type="fluid", name="aromatics", amount=97},
        {type="fluid", name="pressured-water", amount=352},
        {type="item", name="propene-canister", amount=1},
      },
      results = {
        {type="fluid", name="petroleum-gas", amount=149},
      },
    },
    ["bitumen"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.06363415695782,
      ingredients = {
        {type="fluid", name="methanal", amount=26},
        {type="fluid", name="naphtha", amount=107},
        {type="fluid", name="nitrogen", amount=350},
      },
      results = {
        {type="fluid", name="bitumen", amount=266},
        {type="fluid", name="tailings", amount=53},
      },
    },
    ["explosive-glycerol"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="acetic-acid", amount=350},
        {type="fluid", name="flue-gas", amount=1559},
        {type="fluid", name="lubricant", amount=103},
        {type="fluid", name="water", amount=1064},
        {type="item", name="heavy-oil-canister", amount=2},
      },
      results = {
        {type="item", name="explosives", amount=5},
      },
    },
    ["filtration-media"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boron-trioxide", amount=4},
        {type="item", name="btx-barrel", amount=2},
        {type="item", name="purest-nitrogen-gas-barrel", amount=3},
        {type="item", name="stone", amount=16},
        {type="item", name="subcritical-water-barrel", amount=1},
      },
      results = {
        {type="item", name="filtration-media", amount=5},
      },
    },
    ["niobium-dust"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.90529661538798,
      ingredients = {
        {type="item", name="lubricant-barrel", amount=1},
        {type="item", name="niobium-powder", amount=6},
      },
      results = {
        {type="item", name="gravel", amount=4},
        {type="item", name="niobium-dust", amount=19},
      },
    },
    ["stone-distilation"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.78444041787303,
      ingredients = {
        {type="item", name="coke", amount=7},
        {type="item", name="sb-grade-03", amount=1},
        {type="item", name="stone", amount=49},
      },
      results = {
        {type="fluid", name="tailings", amount=176},
        {type="fluid", name="tar", amount=176},
        {type="item", name="coarse", amount=18},
        {type="item", name="tailings-dust", amount=18},
      },
    },
    ["milling-ree"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="empty-comb", amount=2},
      },
      results = {
        {type="item", name="gravel", amount=2},
        {type="item", name="rare-earth-dust", amount=3},
      },
    },
    ["rare-earth-beneficiation"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.485937037343079,
      ingredients = {
        {type="fluid", name="olefin", amount=275},
        {type="fluid", name="pressured-air", amount=1021},
        {type="item", name="rare-earth-dust", amount=4},
        {type="item", name="subcritical-water-barrel", amount=1},
      },
      results = {
        {type="fluid", name="rare-earth-mud", amount=122},
        {type="fluid", name="steam", amount=975},
        {type="item", name="rich-dust", amount=2},
        {type="item", name="sand", amount=5},
      },
    },
    ["milling-molybdenite"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="molybdenum-ore", amount=11},
      },
      results = {
        {type="item", name="gravel", amount=1},
        {type="item", name="molybdenite-dust", amount=10},
      },
    },
    ["ree-float"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.392279196815575,
      ingredients = {
        {type="item", name="naphtha-barrel", amount=1},
      },
      results = {
        {type="fluid", name="rare-earth-mud", amount=39},
        {type="item", name="zinc-plate", amount=2},
      },
    },
    ["ree-slurry"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.27,
      ingredients = {
        {type="fluid", name="hot-molten-salt", amount=36},
        {type="fluid", name="rare-earth-mud", amount=42},
        {type="fluid", name="refined-natural-gas", amount=85},
        {type="fluid", name="scrude", amount=257},
      },
      results = {
        {type="fluid", name="ree-slurry", amount=127},
        {type="fluid", name="tailings", amount=127},
      },
    },
    ["ree-solution"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.94999932947494,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=713},
        {type="fluid", name="phytoplankton", amount=220},
      },
      results = {
        {type="fluid", name="ree-solution", amount=95},
        {type="item", name="uranium-ore", amount=0.0949231763489932},
      },
    },
    ["crusher-ree"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 3.4,
      ingredients = {
        {type="item", name="belt", amount=4},
        {type="item", name="coalbed-gas-barrel", amount=1},
      },
      results = {
        {type="item", name="rare-earth-powder", amount=17},
        {type="item", name="stone", amount=17},
      },
    },
    ["ree-concentrate2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.546432794778632,
      ingredients = {
        {type="fluid", name="hot-air", amount=990},
        {type="fluid", name="organic-solvent", amount=197},
        {type="item", name="rare-earth-dust", amount=2},
      },
      results = {
        {type="item", name="chromite-sand", amount=5},
        {type="item", name="ree-concentrate", amount=11},
      },
    },
    ["ree-concentrate1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.61183622993308,
      ingredients = {
        {type="fluid", name="hot-air", amount=691},
        {type="fluid", name="organic-solvent", amount=352},
        {type="fluid", name="sulfuric-acid", amount=249},
      },
      results = {
        {type="item", name="iron-oxide", amount=10},
        {type="item", name="ree-concentrate", amount=16},
      },
    },
    ["reo"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.406488315727831,
      ingredients = {
        {type="item", name="rare-earth-dust", amount=5},
      },
      results = {
        {type="item", name="iron-oxide", amount=1},
        {type="item", name="reo", amount=2},
      },
    },
    ["ree-concentrate3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.84823310120067,
      ingredients = {
        {type="fluid", name="olefin", amount=728},
        {type="fluid", name="pressured-air", amount=1058},
        {type="fluid", name="purest-nitrogen-gas", amount=918},
        {type="fluid", name="refined-natural-gas", amount=664},
        {type="item", name="rare-earth-dust", amount=11},
      },
      results = {
        {type="item", name="copper-ore", amount=9},
        {type="item", name="ree-concentrate", amount=37},
      },
    },
    ["xyhiphoe-codex"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="small-lamp", amount=5},
        {type="item", name="tinned-cable", amount=311},
      },
      results = {
        {type="item", name="xyhiphoe-codex", amount=1},
      },
    },
    ["xyhiphoe-cub-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.4559040222005,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=829},
        {type="fluid", name="hot-air", amount=422},
        {type="fluid", name="hydrogen", amount=874},
        {type="fluid", name="sulfuric-acid", amount=158},
        {type="item", name="fish", amount=1},
        {type="item", name="fish-food-01", amount=3},
        {type="item", name="lime", amount=7},
        {type="item", name="naphtha-canister", amount=2},
        {type="item", name="offshore-pump", amount=2},
        {type="item", name="ralesia", amount=2},
      },
      results = {
        {type="fluid", name="waste-water", amount=923},
        {type="item", name="xyhiphoe-cub", amount=6},
      },
    },
    ["xyhiphoe-pool-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-food-01", amount=6},
        {type="item", name="concrete", amount=129},
        {type="item", name="duralumin", amount=19},
        {type="item", name="fiberboard", amount=22},
        {type="item", name="fwf-mk01", amount=3},
        {type="item", name="grade-2-chromite", amount=2},
        {type="item", name="inductor1", amount=20},
        {type="item", name="iron-chest", amount=2},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="pbsb-alloy", amount=11},
        {type="item", name="pump", amount=4},
        {type="item", name="rail-signal", amount=2},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="storage-tank", amount=2},
        {type="item", name="titanium-plate", amount=79},
      },
      results = {
        {type="item", name="xyhiphoe-pool-mk01", amount=1},
      },
    },
    ["xyhiphoe"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="fish-oil", amount=425},
        {type="fluid", name="molten-glass", amount=430},
        {type="item", name="arqad-codex", amount=3},
        {type="item", name="bio-sample01", amount=4},
        {type="item", name="earth-crustacean-sample", amount=1},
        {type="item", name="earth-generic-sample", amount=9},
        {type="item", name="nichrome", amount=9},
        {type="item", name="retrovirus", amount=9},
        {type="item", name="tower-mk01", amount=1},
      },
      results = {
        {type="item", name="xyhiphoe", amount=2},
      },
    },
    ["xyhiphoe-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.935912140856651,
      ingredients = {
        {type="fluid", name="hot-air", amount=1990},
        {type="fluid", name="hydrogen", amount=496},
        {type="item", name="naphtha-canister", amount=10},
      },
      results = {
        {type="fluid", name="waste-water", amount=177},
        {type="item", name="xyhiphoe", amount=1},
      },
    },
    ["niobium-concentrate"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.597547642749255,
      ingredients = {
        {type="fluid", name="water", amount=1884},
        {type="item", name="aromatics-barrel", amount=1},
      },
      results = {
        {type="item", name="niobium-concentrate", amount=6},
        {type="item", name="sand", amount=1},
      },
    },
    ["nbfe-alloy"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="btx-canister", amount=4},
        {type="item", name="steel-plate", amount=6},
      },
      results = {
        {type="item", name="nbfe-alloy", amount=2},
      },
    },
    ["niobium-oxide"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.7,
      ingredients = {
        {type="fluid", name="niobium-complex", amount=38},
        {type="fluid", name="water", amount=1536},
      },
      results = {
        {type="item", name="niobium-oxide", amount=7},
      },
    },
    ["niobium-plate"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="btx-canister", amount=1},
        {type="item", name="py-iron", amount=9},
        {type="item", name="sodium-hydroxide", amount=9},
      },
      results = {
        {type="item", name="niobium-plate", amount=6},
      },
    },
    ["niobium-complex"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.89,
      ingredients = {
        {type="fluid", name="hydrogen-chloride", amount=57},
        {type="item", name="grade-2-chromite", amount=1},
        {type="item", name="ore-titanium", amount=27},
      },
      results = {
        {type="fluid", name="niobium-complex", amount=89},
      },
    },
    ["niobium-powder"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="lubricant-barrel", amount=1},
      },
      results = {
        {type="item", name="niobium-powder", amount=5},
        {type="item", name="stone", amount=2},
      },
    },
    ["hydrogen-chloride-void"] = {
      mode = "input-preserved-untransformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen-chloride", amount=100},
        {type="item", name="small-lamp", amount=1},
      },
      results = {
        {type="fluid", name="chlorine", amount=100},
        {type="fluid", name="hydrogen", amount=100},
        {type="item", name="small-lamp", amount=1},
      },
    },
    ["purest-nitrogen-void"] = {
      mode = "input-preserved-untransformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="purest-nitrogen-gas", amount=240},
      },
      results = {
        {type="fluid", name="pressured-air", amount=240},
      },
    },
    ["refsyngas-from-meth-canister"] = {
      mode = "input-preserved-untransformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=393},
        {type="item", name="methanol-gas-canister", amount=1},
      },
      results = {
        {type="fluid", name="acidgas", amount=60},
        {type="fluid", name="carbon-dioxide", amount=20},
        {type="fluid", name="refsyngas", amount=100},
        {type="fluid", name="water", amount=30},
        {type="item", name="empty-gas-canister", amount=1},
      },
    },
    ["vanadium-pulp-3-void"] = {
      mode = "input-preserved-untransformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="coalbed-gas", amount=50},
        {type="fluid", name="industrial-solvent", amount=722},
      },
      results = {
        {type="fluid", name="flue-gas", amount=50},
        {type="fluid", name="vpulp1", amount=50},
      },
    },
    ["defender-capsule"] = {
      mode = "kept-pruned-transformed",
      science_level = 4,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="petri-dish-bacteria", amount=7},
        {type="item", name="shotgun-shell", amount=5},
        {type="item", name="transport-belt", amount=3},
        {type="item", name="vacuum-tube", amount=1},
      },
      results = {
        {type="item", name="defender-capsule", amount=1},
      },
    },
    ["flamethrower"] = {
      mode = "kept-pruned-transformed",
      science_level = 4,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-2-tin", amount=2},
        {type="item", name="vacuum-tube", amount=5},
      },
      results = {
        {type="item", name="flamethrower", amount=1},
      },
    },
    ["rocket-launcher"] = {
      mode = "kept-transformed",
      science_level = 4,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="ground-sample01", amount=9},
        {type="item", name="military-science-pack", amount=1},
        {type="item", name="petri-dish-bacteria", amount=7},
        {type="item", name="shotgun-shell", amount=14},
        {type="item", name="transport-belt", amount=7},
        {type="item", name="ulric-food-01", amount=17},
      },
      results = {
        {type="item", name="rocket-launcher", amount=2},
      },
    },
    ["flamethrower-ammo"] = {
      mode = "kept-transformed",
      science_level = 4,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="tailings", amount=245},
        {type="item", name="ground-sample01", amount=13},
      },
      results = {
        {type="item", name="flamethrower-ammo", amount=1},
      },
    },
    ["rocket"] = {
      mode = "kept-transformed",
      science_level = 4,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="explosives", amount=2},
        {type="item", name="ground-sample01", amount=7},
        {type="item", name="iron-plate", amount=7},
      },
      results = {
        {type="item", name="rocket", amount=2},
      },
    },
    ["flamethrower-turret"] = {
      mode = "kept-pruned-transformed",
      science_level = 4,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="grade-2-tin", amount=40},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="sodium-alginate", amount=21},
        {type="item", name="sulfuric-acid-barrel", amount=9},
        {type="item", name="transport-belt", amount=12},
        {type="item", name="ulric-food-01", amount=2},
        {type="item", name="vacuum-tube", amount=110},
      },
      results = {
        {type="item", name="flamethrower-turret", amount=3},
      },
    },
    ["land-mine"] = {
      mode = "repaired-to-input",
      science_level = 4,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="gasoline-canister", amount=10},
        {type="item", name="steel-plate", amount=1},
      },
      results = {
        {type="item", name="land-mine", amount=4},
      },
    },
    ["py-science-pack-2"] = {
      mode = "kept-transformed",
      science_level = 4,
      energy_required_multiplier = 2.61111111111111,
      ingredients = {
        {type="fluid", name="tailings", amount=4000},
        {type="fluid", name="water-saline", amount=4000},
        {type="item", name="alien-sample-02", amount=1},
        {type="item", name="casein", amount=38},
        {type="item", name="cytostatics", amount=1},
        {type="item", name="engine-unit", amount=15},
        {type="item", name="flask", amount=23},
        {type="item", name="gasoline-canister", amount=123},
        {type="item", name="ground-sample01", amount=1000},
        {type="item", name="incubator-mk01", amount=1},
        {type="item", name="stone-brick", amount=338},
        {type="item", name="zipir1", amount=3},
      },
      results = {
        {type="item", name="py-science-pack-2", amount=47},
      },
    },
    ["arthropod-blood-to-copper"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="fluid", name="arthropod-blood", amount=38},
      },
      results = {
        {type="item", name="copper-ore", amount=15},
      },
    },
    ["guts-to-copper"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.46666666666667,
      ingredients = {
        {type="item", name="brain", amount=2},
        {type="item", name="guts", amount=3},
      },
      results = {
        {type="item", name="copper-ore", amount=22},
      },
    },
    ["meat-and-gut-to-copper"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="fluid", name="glycerol", amount=24},
        {type="fluid", name="water-saline", amount=334},
        {type="item", name="guts", amount=4},
        {type="item", name="meat", amount=4},
      },
      results = {
        {type="item", name="copper-ore", amount=49},
      },
    },
    ["tuuphra-to-copper"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.65,
      ingredients = {
        {type="item", name="tuuphra", amount=3},
        {type="item", name="tuuphra-seeds", amount=15},
      },
      results = {
        {type="item", name="copper-ore", amount=33},
      },
    },
    ["yaedols-to-copper"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="yaedols", amount=3},
      },
      results = {
        {type="item", name="copper-ore", amount=8},
      },
    },
    ["blood-to-urea"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.9,
      ingredients = {
        {type="fluid", name="blood", amount=173},
        {type="item", name="fiberboard", amount=1},
      },
      results = {
        {type="item", name="urea", amount=19},
      },
    },
    ["btx-to-ethylene"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.62,
      ingredients = {
        {type="fluid", name="btx", amount=42},
        {type="fluid", name="steam", amount=193},
        {type="item", name="pipe", amount=2},
      },
      results = {
        {type="fluid", name="ethylene", amount=62},
      },
    },
    ["ceramic-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.7,
      ingredients = {
        {type="item", name="coke", amount=1},
        {type="item", name="graphite", amount=3},
        {type="item", name="salt", amount=2},
      },
      results = {
        {type="item", name="ceramic", amount=7},
      },
    },
    ["crude-cermet"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="ceramic", amount=6},
        {type="item", name="coke", amount=1},
        {type="item", name="crushed-molybdenite", amount=1},
        {type="item", name="graphite", amount=4},
        {type="item", name="ore-nickel", amount=3},
        {type="item", name="salt", amount=8},
      },
      results = {
        {type="item", name="crude-cermet", amount=10},
      },
    },
    ["cermet"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="lubricant", amount=195},
        {type="item", name="ash", amount=8},
        {type="item", name="crude-cermet", amount=2},
      },
      results = {
        {type="item", name="cermet", amount=5},
      },
    },
    ["concrete-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.6,
      ingredients = {
        {type="fluid", name="boric-acid", amount=323},
        {type="item", name="cellulose", amount=2},
        {type="item", name="stone-brick", amount=4},
      },
      results = {
        {type="item", name="concrete", amount=12},
      },
    },
    ["cool-steam-500-to-250"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.966666666666667,
      ingredients = {
        {type="fluid", name="steam", amount=200},
        {type="fluid", name="water", amount=213},
      },
      results = {
        {type="fluid", name="steam", amount=403},
      },
    },
    ["sodium-sulfate-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.99944653652839,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=144},
        {type="item", name="salt", amount=22},
      },
      results = {
        {type="fluid", name="water", amount=94},
        {type="item", name="sodium-sulfate", amount=2},
      },
    },
    ["fawogae-to-sulfur"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="item", name="fawogae", amount=4},
        {type="item", name="fungal-substrate", amount=1},
        {type="item", name="melamine", amount=4},
      },
      results = {
        {type="item", name="sulfur", amount=7},
      },
    },
    ["fish-to-iron"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="fluid", name="fish-oil", amount=61},
      },
      results = {
        {type="item", name="iron-ore", amount=24},
      },
    },
    ["meat-to-iron"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="meat", amount=5},
      },
      results = {
        {type="item", name="iron-ore", amount=10},
      },
    },
    ["p2s5"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="phosphate-rock", amount=9},
        {type="item", name="pyrite", amount=4},
      },
      results = {
        {type="item", name="iron-ore", amount=1},
        {type="item", name="p2s5", amount=1},
      },
    },
    ["tuupha-to-iron"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="vpulp3", amount=4},
        {type="item", name="refined-hazard-concrete", amount=4},
        {type="item", name="tuuphra", amount=6},
      },
      results = {
        {type="item", name="iron-ore", amount=6},
      },
    },
    ["trits-codex"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.181878849306483,
      ingredients = {
        {type="item", name="filtration-media", amount=2},
        {type="item", name="lead-plate", amount=2},
      },
      results = {
        {type="item", name="trits-codex", amount=0.181878849306483},
      },
    },
    ["trits-reef-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="chromium", amount=18},
        {type="item", name="duralumin", amount=12},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="formamide-barrel", amount=12},
        {type="item", name="hazard-concrete", amount=25},
        {type="item", name="industrial-solvent-barrel", amount=1},
        {type="item", name="iron-slime-barrel", amount=16},
        {type="item", name="lab", amount=3},
        {type="item", name="log", amount=196},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="pump", amount=1},
        {type="item", name="pure-sand", amount=51},
        {type="item", name="py-steel", amount=4},
        {type="item", name="small-parts-01", amount=217},
        {type="item", name="soda-ash-barrel", amount=6},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="stopper", amount=2},
        {type="item", name="titanium-plate", amount=35},
      },
      results = {
        {type="item", name="trits-reef-mk01", amount=1},
      },
    },
    ["trits"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="fetal-serum", amount=100},
        {type="fluid", name="steam", amount=333},
        {type="item", name="alien-sample-02", amount=2},
        {type="item", name="cytostatics", amount=2},
        {type="item", name="earth-cow-sample", amount=1},
        {type="item", name="earth-crustacean-sample", amount=1},
        {type="item", name="titanium-plate", amount=136},
        {type="item", name="vrauks", amount=1},
        {type="item", name="zipir-codex", amount=2},
      },
      results = {
        {type="item", name="trits", amount=1},
      },
    },
    ["trits-cub-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2.0046495955208,
      ingredients = {
        {type="fluid", name="oxygen", amount=537},
        {type="item", name="filtration-media", amount=2},
        {type="item", name="log", amount=5},
        {type="item", name="moondrop-mk02", amount=1},
        {type="item", name="niobium-oxide", amount=3},
        {type="item", name="photophore", amount=2},
        {type="item", name="sea-sponge-sprouts", amount=4},
        {type="item", name="trits", amount=2},
      },
      results = {
        {type="fluid", name="waste-water", amount=607},
        {type="item", name="trits-pup", amount=4},
      },
    },
    ["trits-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.48388126765216,
      ingredients = {
        {type="fluid", name="anthraquinone", amount=12},
        {type="fluid", name="water-saline", amount=489},
        {type="item", name="bio-sample", amount=3},
        {type="item", name="filtration-media", amount=2},
        {type="item", name="gunpowder", amount=5},
        {type="item", name="moondrop-mk02", amount=1},
        {type="item", name="pipe", amount=11},
        {type="item", name="sodium-silicate", amount=2},
        {type="item", name="trits-pup", amount=1},
        {type="item", name="wood-seeds", amount=23},
      },
      results = {
        {type="fluid", name="waste-water", amount=351},
        {type="item", name="trits", amount=3},
      },
    },
    ["glass-core"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.4765855540546,
      ingredients = {
        {type="fluid", name="molten-glass", amount=201},
        {type="item", name="gold-plate", amount=1},
      },
      results = {
        {type="item", name="glass-core", amount=0.4765855540546},
      },
    },
    ["hotair-glass-core"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="silver-plate", amount=3},
      },
      results = {
        {type="item", name="glass-core", amount=2},
      },
    },
    ["guar-sample"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="cytostatics", amount=6},
        {type="item", name="earth-crustacean-sample", amount=9},
        {type="item", name="earth-sea-sponge-sample", amount=1},
        {type="item", name="kicalk-codex", amount=2},
        {type="item", name="korlex-codex", amount=4},
        {type="item", name="ralesia-codex", amount=3},
      },
      results = {
        {type="item", name="guar", amount=2},
      },
    },
    ["guar-seeds"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="soil", amount=32},
      },
      results = {
        {type="item", name="guar-seeds", amount=8},
      },
    },
    ["guar-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2.3,
      ingredients = {
        {type="fluid", name="steam", amount=144},
        {type="fluid", name="water", amount=166},
        {type="item", name="gravel", amount=5},
        {type="item", name="guar-seeds", amount=10},
        {type="item", name="lime", amount=5},
        {type="item", name="pressured-water-barrel", amount=1},
      },
      results = {
        {type="item", name="guar", amount=23},
      },
    },
    ["acid-refined-concrete"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="acetic-acid", amount=5},
        {type="item", name="refined-hazard-concrete", amount=2},
        {type="item", name="sb-grade-02", amount=6},
      },
      results = {
        {type="item", name="acid-refined-concrete", amount=4},
      },
    },
    ["black-refined-concrete"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.666666666666667,
      ingredients = {
        {type="fluid", name="blood", amount=1},
        {type="item", name="carbon-black", amount=1},
        {type="item", name="sb-grade-02", amount=3},
      },
      results = {
        {type="item", name="black-refined-concrete", amount=2},
      },
    },
    ["blue-refined-concrete"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2.33333333333333,
      ingredients = {
        {type="item", name="hazard-concrete", amount=3},
        {type="item", name="refined-hazard-concrete", amount=4},
        {type="item", name="rich-clay", amount=5},
      },
      results = {
        {type="item", name="blue-refined-concrete", amount=7},
      },
    },
    ["cyan-refined-concrete"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="oxygen", amount=214},
        {type="item", name="hazard-concrete", amount=3},
      },
      results = {
        {type="item", name="cyan-refined-concrete", amount=4},
      },
    },
    ["orange-refined-concrete"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 6.66666666666667,
      ingredients = {
        {type="item", name="coal-slurry-barrel", amount=3},
        {type="item", name="condensates-barrel", amount=2},
        {type="item", name="pipe", amount=20},
      },
      results = {
        {type="item", name="orange-refined-concrete", amount=20},
      },
    },
    ["purple-refined-concrete"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="vpulp3", amount=5},
        {type="item", name="refined-hazard-concrete", amount=2},
      },
      results = {
        {type="item", name="purple-refined-concrete", amount=3},
      },
    },
    ["brown-refined-concrete"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="filled-comb", amount=1},
        {type="item", name="phosphate-rock", amount=1},
        {type="item", name="pyrite", amount=5},
        {type="item", name="rail", amount=1},
      },
      results = {
        {type="item", name="brown-refined-concrete", amount=6},
      },
    },
    ["green-refined-concrete"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.666666666666667,
      ingredients = {
        {type="item", name="orange-refined-concrete", amount=1},
        {type="item", name="refined-hazard-concrete", amount=1},
      },
      results = {
        {type="item", name="green-refined-concrete", amount=2},
      },
    },
    ["pink-refined-concrete"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="arqad-honey-barrel", amount=1},
        {type="item", name="hazard-concrete", amount=2},
      },
      results = {
        {type="item", name="pink-refined-concrete", amount=3},
      },
    },
    ["red-refined-concrete"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 3.33333333333333,
      ingredients = {
        {type="fluid", name="blood", amount=19},
        {type="item", name="nexelit-plate", amount=10},
        {type="item", name="stone-wall", amount=1},
      },
      results = {
        {type="item", name="red-refined-concrete", amount=10},
      },
    },
    ["yellow-refined-concrete"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="item", name="fertilizer", amount=2},
        {type="item", name="pipe", amount=4},
      },
      results = {
        {type="item", name="yellow-refined-concrete", amount=5},
      },
    },
    ["ipod"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="boiler", amount=18},
        {type="item", name="bonemeal", amount=9},
        {type="item", name="carbolic-oil-barrel", amount=26},
        {type="item", name="formamide-barrel", amount=2},
        {type="item", name="inductor1", amount=63},
        {type="item", name="lab", amount=7},
        {type="item", name="log", amount=26},
        {type="item", name="low-grade-rejects", amount=120},
        {type="item", name="niobium-pipe", amount=27},
        {type="item", name="nxsb-alloy", amount=2},
        {type="item", name="rail-signal", amount=1},
        {type="item", name="residual-oil-canister", amount=8},
        {type="item", name="splitter", amount=24},
        {type="item", name="tuuphra-seeds", amount=55},
        {type="item", name="used-auog", amount=10},
        {type="item", name="vane-mk01", amount=4},
      },
      results = {
        {type="item", name="ipod", amount=2},
      },
    },
    ["kicalk-3"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="item", name="ash", amount=9},
        {type="item", name="biomass", amount=5},
        {type="item", name="coke", amount=6},
        {type="item", name="fertilizer", amount=2},
        {type="item", name="lime", amount=2},
        {type="item", name="raw-fiber", amount=8},
      },
      results = {
        {type="item", name="kicalk", amount=8},
      },
    },
    ["kicalk-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.76845381577563,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=343},
        {type="fluid", name="steam", amount=349},
        {type="item", name="ash", amount=9},
        {type="item", name="fertilizer", amount=7},
        {type="item", name="graphite", amount=2},
        {type="item", name="kicalk", amount=2},
        {type="item", name="lime", amount=4},
        {type="item", name="raw-fiber", amount=43},
        {type="item", name="small-lamp", amount=6},
      },
      results = {
        {type="item", name="kicalk", amount=1},
        {type="item", name="kicalk-mk02", amount=0.00884226907887814},
        {type="item", name="kicalk-seeds-mk02", amount=0.0353690763155125},
      },
    },
    ["kicalk-mk02-breeder"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.998822784135654,
      ingredients = {
        {type="fluid", name="flutec-pp6", amount=48},
        {type="item", name="glass", amount=24},
        {type="item", name="kicalk-seeds-mk02", amount=5},
      },
      results = {
        {type="item", name="kicalk-mk02", amount=5},
        {type="item", name="kicalk-seeds", amount=1},
        {type="item", name="kicalk-seeds-mk02", amount=1},
      },
    },
    ["meat-to-phosphate"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="water", amount=1328},
        {type="item", name="bones", amount=4},
        {type="item", name="brain", amount=2},
      },
      results = {
        {type="item", name="phosphate-rock", amount=6},
      },
    },
    ["wood-seeds-to-phosphate"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="wood-seeds", amount=9},
      },
      results = {
        {type="item", name="phosphate-rock", amount=1},
      },
    },
    ["ocula"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="bio-oil", amount=4000},
        {type="item", name="earth-mouse-sample", amount=1},
        {type="item", name="fts-reactor", amount=16},
        {type="item", name="niobium-complex-barrel", amount=109},
        {type="item", name="reformer-mk01", amount=19},
      },
      results = {
        {type="item", name="ocula", amount=1},
      },
    },
    ["py-logo-15tiles"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="hydrogen-chloride", amount=1449},
        {type="item", name="lubricant-barrel", amount=12},
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="py-logo-15tiles", amount=2},
      },
    },
    ["rail-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2.91666666666667,
      ingredients = {
        {type="item", name="grade-2-ti", amount=4},
        {type="item", name="pipe", amount=8},
        {type="item", name="raw-gas-canister", amount=1},
        {type="item", name="refined-concrete", amount=20},
        {type="item", name="tailings-barrel", amount=3},
      },
      results = {
        {type="item", name="rail", amount=35},
      },
    },
    ["resorcinol"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coke", amount=25},
        {type="item", name="graphite", amount=4},
      },
      results = {
        {type="item", name="resorcinol", amount=2},
      },
    },
    ["sample-cup"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="item", name="nexelit-plate", amount=2},
      },
      results = {
        {type="item", name="sample-cup", amount=3},
      },
    },
    ["sea-sponge-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.54100381505564,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=131},
        {type="fluid", name="zogna-bacteria", amount=131},
        {type="item", name="kicalk-seeds", amount=30},
        {type="item", name="sea-sponge", amount=2},
      },
      results = {
        {type="fluid", name="water-saline", amount=77},
        {type="item", name="sea-sponge", amount=1},
        {type="item", name="sea-sponge-mk02", amount=0.00771533923157072},
      },
    },
    ["sea-sponge-sprouts-mk02-breeder"] = {
      mode = "repaired-to-input",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="sea-sponge-mk02", amount=1},
      },
      results = {
        {type="item", name="sea-sponge-sprouts-mk02", amount=3},
      },
    },
    ["sea-sponge-mk02-breeder"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.24911183227094,
      ingredients = {
        {type="fluid", name="chlorine", amount=559},
        {type="item", name="sea-sponge-sprouts", amount=5},
      },
      results = {
        {type="fluid", name="water-saline", amount=59},
        {type="item", name="sea-sponge-mk02", amount=1},
      },
    },
    ["sea-sponge-sprouts-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="item", name="sea-sponge-sprouts-mk02", amount=2},
      },
      results = {
        {type="item", name="sea-sponge-sprouts", amount=3},
      },
    },
    ["seaweed-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.23333333333333,
      ingredients = {
        {type="fluid", name="slacked-lime", amount=80},
        {type="fluid", name="water-saline", amount=97},
        {type="item", name="fertilizer", amount=1},
        {type="item", name="seaweed", amount=2},
      },
      results = {
        {type="item", name="seaweed", amount=39},
      },
    },
    ["seaweed-mk03"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="al-pulp-02-barrel", amount=8},
        {type="item", name="molybdenum-sulfide", amount=12},
      },
      results = {
        {type="item", name="seaweed-mk03", amount=1},
      },
    },
    ["tuuphra-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.875,
      ingredients = {
        {type="fluid", name="manure-bacteria", amount=29},
        {type="item", name="coal-gas-barrel", amount=1},
        {type="item", name="fawogae", amount=4},
        {type="item", name="gravel", amount=3},
        {type="item", name="rich-clay", amount=7},
        {type="item", name="tuuphra-seeds", amount=13},
      },
      results = {
        {type="item", name="tuuphra", amount=7},
      },
    },
    ["tuuphra-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.55507873359486,
      ingredients = {
        {type="fluid", name="manure-bacteria", amount=115},
        {type="fluid", name="steam", amount=322},
        {type="item", name="coal-gas-barrel", amount=1},
        {type="item", name="fawogae", amount=17},
        {type="item", name="fertilizer", amount=11},
        {type="item", name="gravel", amount=4},
        {type="item", name="manure", amount=14},
        {type="item", name="pure-sand", amount=31},
        {type="item", name="rich-clay", amount=28},
        {type="item", name="sand", amount=59},
        {type="item", name="tuuphra", amount=2},
        {type="item", name="tuuphra-seeds", amount=7},
      },
      results = {
        {type="item", name="tuuphra", amount=1},
        {type="item", name="tuuphra-mk02", amount=0.00777539366797431},
      },
    },
    ["tuuphra-mk02-breeder"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.727272727272727,
      ingredients = {
        {type="fluid", name="ammonia", amount=321},
        {type="fluid", name="cyanic-acid", amount=455},
        {type="item", name="cellulose", amount=1},
        {type="item", name="fawogae", amount=43},
        {type="item", name="pure-sand", amount=43},
        {type="item", name="tuuphra-mk02", amount=1},
      },
      results = {
        {type="item", name="tuuphra-mk02", amount=5},
      },
    },
    ["xenogenic-from-bonemeal"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.12941176470588,
      ingredients = {
        {type="fluid", name="hydrogen", amount=225},
        {type="item", name="brain", amount=1},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=96},
      },
    },
    ["xenogenic-from-bones"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.55555555555556,
      ingredients = {
        {type="fluid", name="water", amount=1845},
        {type="item", name="albumin", amount=1},
        {type="item", name="bones", amount=5},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=70},
      },
    },
    ["xenogenic-from-brains"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.85,
      ingredients = {
        {type="fluid", name="industrial-solvent", amount=12},
        {type="item", name="meat", amount=26},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=17},
      },
    },
    ["xenogenic-from-chitin"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.957142857142857,
      ingredients = {
        {type="item", name="guts", amount=23},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=67},
      },
    },
    ["xenogenic-from-fat"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="fluid", name="hydrogen", amount=150},
        {type="item", name="chitin", amount=1},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=25},
      },
    },
    ["xenogenic-from-guts"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.625,
      ingredients = {
        {type="fluid", name="steam", amount=303},
        {type="item", name="brain", amount=1},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=25},
      },
    },
    ["xenogenic-from-skin"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.28333333333333,
      ingredients = {
        {type="item", name="brain", amount=2},
        {type="item", name="guts", amount=3},
        {type="item", name="starch", amount=1},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=77},
      },
    },
    ["xenogenic-from-meat"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=646},
        {type="item", name="bones", amount=2},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=30},
      },
    },
    ["Moss-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.58333333333333,
      ingredients = {
        {type="fluid", name="pressured-water", amount=241},
        {type="item", name="coke", amount=19},
        {type="item", name="graphite", amount=3},
        {type="item", name="lime", amount=6},
        {type="item", name="stone", amount=19},
      },
      results = {
        {type="item", name="moss", amount=38},
      },
    },
    ["moss-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.14979831253263,
      ingredients = {
        {type="item", name="chromium", amount=2},
        {type="item", name="moondrop", amount=1},
        {type="item", name="saps", amount=6},
      },
      results = {
        {type="item", name="moss-mk02", amount=0.0229959662506527},
      },
    },
    ["moss-mk02r"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="item", name="cytostatics", amount=1},
        {type="item", name="moss-mk02", amount=3},
        {type="item", name="retrovirus", amount=3},
        {type="item", name="sea-sponge", amount=7},
      },
      results = {
        {type="item", name="moss-mk02", amount=7},
      },
    },
    ["biomass-molten-salt-02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.4875,
      ingredients = {
        {type="fluid", name="low-distillate", amount=856},
        {type="item", name="grade-3-ti", amount=3},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=195},
      },
    },
    ["coal-molten-salt-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.648,
      ingredients = {
        {type="fluid", name="chloroethanol", amount=210},
        {type="fluid", name="hydrogen-chloride", amount=3495},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=824},
      },
    },
    ["fatty-acids-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.68,
      ingredients = {
        {type="fluid", name="flue-gas", amount=375},
        {type="fluid", name="organic-solvent", amount=30},
        {type="item", name="seaweed", amount=77},
      },
      results = {
        {type="fluid", name="fatty-acids", amount=34},
      },
    },
    ["oleochemicals-to-fatty-acids"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.74,
      ingredients = {
        {type="fluid", name="oleochemicals", amount=74},
      },
      results = {
        {type="fluid", name="fatty-acids", amount=37},
      },
    },
    ["perylene"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="tar", amount=471},
        {type="item", name="navens", amount=6},
        {type="item", name="pyrite", amount=4},
      },
      results = {
        {type="fluid", name="perylene", amount=50},
      },
    },
    ["geo-he-01"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="blood", amount=1},
        {type="fluid", name="muddy-sludge", amount=276},
      },
      results = {
        {type="fluid", name="pressured-steam", amount=75},
      },
    },
    ["oil-molten-salt-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.324,
      ingredients = {
        {type="fluid", name="fatty-acids", amount=291},
        {type="fluid", name="pressured-water", amount=4000},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=662},
      },
    },
    ["organic-acid-anhydride"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.3,
      ingredients = {
        {type="fluid", name="acetic-acid", amount=214},
        {type="fluid", name="fatty-acids", amount=184},
        {type="fluid", name="phosphoric-acid", amount=42},
        {type="item", name="meat", amount=3},
        {type="item", name="pyrite", amount=7},
      },
      results = {
        {type="fluid", name="organic-acid-anhydride", amount=130},
      },
    },
    ["processed-fatty-acids"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.48,
      ingredients = {
        {type="fluid", name="acetic-acid", amount=77},
        {type="fluid", name="fatty-acids", amount=19},
      },
      results = {
        {type="fluid", name="processed-fatty-acids", amount=24},
      },
    },
    ["middle-processed-lard"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.702990131833076,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=168},
        {type="item", name="bones", amount=2},
        {type="item", name="calcium-carbide", amount=2},
      },
      results = {
        {type="fluid", name="middle-processed-lard", amount=14},
        {type="fluid", name="steam", amount=362},
        {type="fluid", name="tar", amount=36},
      },
    },
    ["he-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.420031734602717,
      ingredients = {
        {type="fluid", name="hydrogen-chloride", amount=388},
      },
      results = {
        {type="fluid", name="molten-salt", amount=42},
        {type="fluid", name="pressured-steam", amount=32},
      },
    },
    ["pure-trichlorosilane"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.420054142920873,
      ingredients = {
        {type="fluid", name="trichlorosilane", amount=21},
      },
      results = {
        {type="fluid", name="pure-trichlorosilane", amount=21},
        {type="item", name="copper-ore", amount=0.12678547852221},
        {type="item", name="iron-ore", amount=0.12678547852221},
        {type="item", name="ore-aluminium", amount=0.12678547852221},
      },
    },
    ["skin-fatty-acids"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.92,
      ingredients = {
        {type="item", name="albumin", amount=7},
        {type="item", name="brain", amount=11},
        {type="item", name="casein", amount=2},
        {type="item", name="chromium", amount=4},
        {type="item", name="guts", amount=8},
        {type="item", name="moss", amount=6},
        {type="item", name="p2s5", amount=5},
      },
      results = {
        {type="fluid", name="fatty-acids", amount=46},
      },
    },
    ["fatty-acids"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.942857142857143,
      ingredients = {
        {type="fluid", name="industrial-solvent", amount=48},
        {type="fluid", name="middle-processed-lard", amount=48},
      },
      results = {
        {type="fluid", name="fatty-acids", amount=66},
      },
    },
    ["carbon-sulfide"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="fluid", name="propene", amount=23},
        {type="item", name="sulfur", amount=8},
        {type="item", name="wood", amount=3},
      },
      results = {
        {type="fluid", name="carbon-sulfide", amount=45},
      },
    },
    ["ech"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.7,
      ingredients = {
        {type="fluid", name="glycerol", amount=23},
        {type="fluid", name="water-saline", amount=323},
      },
      results = {
        {type="fluid", name="ech", amount=21},
      },
    },
    ["etching"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.653333333333333,
      ingredients = {
        {type="fluid", name="hydrogen-peroxide", amount=21},
        {type="fluid", name="phosphoric-acid", amount=42},
        {type="item", name="bones", amount=2},
        {type="item", name="sap-tree", amount=2},
      },
      results = {
        {type="fluid", name="etching", amount=98},
      },
    },
    ["ethylene"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.7,
      ingredients = {
        {type="fluid", name="methane", amount=21},
        {type="fluid", name="pressured-air", amount=193},
        {type="item", name="iron-oxide", amount=2},
      },
      results = {
        {type="fluid", name="ethylene", amount=42},
        {type="fluid", name="water", amount=35},
      },
    },
    ["guts-to-acetic-acid"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.55,
      ingredients = {
        {type="item", name="brain", amount=7},
        {type="item", name="fertilizer", amount=3},
        {type="item", name="guts", amount=8},
        {type="item", name="piercing-rounds-magazine", amount=2},
      },
      results = {
        {type="fluid", name="acetic-acid", amount=93},
      },
    },
    ["meat-to-cyanic"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.32,
      ingredients = {
        {type="item", name="meat", amount=3},
      },
      results = {
        {type="fluid", name="cyanic-acid", amount=16},
      },
    },
    ["methane-methanal"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.48,
      ingredients = {
        {type="fluid", name="methane", amount=23},
        {type="fluid", name="muddy-sludge", amount=248},
        {type="fluid", name="pressured-water", amount=451},
        {type="item", name="crushed-molybdenite", amount=1},
      },
      results = {
        {type="fluid", name="methanal", amount=148},
      },
    },
    ["nitrobenzene"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.38,
      ingredients = {
        {type="fluid", name="ammonia", amount=23},
        {type="fluid", name="propene", amount=49},
        {type="fluid", name="sulfuric-acid", amount=77},
        {type="item", name="sulfur", amount=16},
        {type="item", name="wood", amount=11},
      },
      results = {
        {type="fluid", name="nitrobenzene", amount=138},
      },
    },
    ["propene-to-acetone"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.76,
      ingredients = {
        {type="fluid", name="btx", amount=6},
        {type="fluid", name="pressured-air", amount=42},
        {type="fluid", name="propene", amount=38},
        {type="item", name="chromite-sand", amount=4},
        {type="item", name="copper-plate", amount=1},
      },
      results = {
        {type="fluid", name="acetone", amount=38},
      },
    },
    ["ethylene-from-fruit"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.28,
      ingredients = {
        {type="item", name="yotoi-fruit", amount=13},
      },
      results = {
        {type="fluid", name="ethylene", amount=64},
      },
    },
    ["fuelrod-mk01-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="molybdenum-concentrate", amount=14},
        {type="item", name="nexelit-matrix", amount=11},
        {type="item", name="phenol", amount=3},
        {type="item", name="u-238", amount=3},
      },
      results = {
        {type="item", name="fuelrod-mk01", amount=1},
      },
    },
    ["grade-1-u"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 5,
      ingredients = {
        {type="fluid", name="water", amount=1337},
        {type="item", name="uranium-ore", amount=18},
      },
      results = {
        {type="item", name="grade-1-u", amount=5},
        {type="item", name="grade-2-u", amount=1},
        {type="item", name="stone", amount=5},
      },
    },
    ["grade-2-u-crush"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="grade-1-u", amount=2},
        {type="item", name="uranium-ore", amount=3},
      },
      results = {
        {type="item", name="powdered-u", amount=2},
        {type="item", name="sand", amount=1},
      },
    },
    ["u-pulp-01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.84,
      ingredients = {
        {type="fluid", name="pressured-water", amount=394},
        {type="fluid", name="sulfuric-acid", amount=15},
        {type="item", name="grade-2-u", amount=12},
      },
      results = {
        {type="fluid", name="u-pulp-01", amount=84},
      },
    },
    ["grade-1-u-recrush"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="uranium-ore", amount=14},
      },
      results = {
        {type="item", name="grade-2-u", amount=2},
        {type="item", name="gravel", amount=1},
      },
    },
    ["u-pulp-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.95,
      ingredients = {
        {type="fluid", name="u-pulp-01", amount=145},
      },
      results = {
        {type="fluid", name="u-pulp-02", amount=95},
      },
    },
    ["u-pulp-03"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="fluid", name="pressured-water", amount=899},
        {type="fluid", name="sulfuric-acid", amount=123},
        {type="fluid", name="u-pulp-02", amount=63},
        {type="item", name="grade-2-u", amount=9},
      },
      results = {
        {type="fluid", name="u-pulp-03", amount=75},
      },
    },
    ["u-rich-pulp"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=459},
        {type="item", name="grade-1-iron", amount=3},
      },
      results = {
        {type="item", name="yellow-cake", amount=2},
      },
    },
    ["cladded-core"] = {
      mode = "repaired-to-input",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="glass-core", amount=1},
        {type="item", name="p2s5", amount=8},
        {type="item", name="ppd", amount=2},
      },
      results = {
        {type="item", name="cladded-core", amount=1},
      },
    },
    ["cladding"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="niobium-complex", amount=63},
        {type="fluid", name="nitrobenzene", amount=41},
        {type="item", name="sic", amount=1},
      },
      results = {
        {type="item", name="cladding", amount=1},
      },
    },
    ["copper-coating"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.0971138312650865,
      ingredients = {
        {type="fluid", name="organic-solvent", amount=3},
        {type="fluid", name="water-saline", amount=77},
        {type="item", name="copper-low-dust", amount=1},
        {type="item", name="nylon-parts", amount=1},
      },
      results = {
        {type="item", name="copper-coating", amount=0.194227662530173},
      },
    },
    ["filtration-media-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="boric-acid", amount=642},
        {type="item", name="active-carbon", amount=1},
        {type="item", name="cellulose", amount=8},
        {type="item", name="coke", amount=35},
        {type="item", name="p2s5", amount=2},
        {type="item", name="stone", amount=43},
        {type="item", name="stone-brick", amount=8},
      },
      results = {
        {type="item", name="filtration-media", amount=4},
      },
    },
    ["iron-oxide"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="nitrobenzene", amount=48},
        {type="item", name="pipe", amount=1},
      },
      results = {
        {type="item", name="iron-oxide", amount=8},
      },
    },
    ["kevlar"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="fluid", name="tpa", amount=48},
        {type="item", name="blood-meal", amount=5},
        {type="item", name="cellulose", amount=8},
        {type="item", name="chromium", amount=2},
        {type="item", name="cladding", amount=1},
        {type="item", name="nylon-parts", amount=10},
      },
      results = {
        {type="item", name="kevlar", amount=6},
      },
    },
    ["kevlar-coating"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="cladded-core", amount=2},
        {type="item", name="kevlar", amount=2},
      },
      results = {
        {type="item", name="kevlar-coating", amount=3},
      },
    },
    ["lab-instrument-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=201},
        {type="item", name="boron-trioxide", amount=4},
        {type="item", name="carbon-black", amount=28},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="equipment-chassi", amount=2},
        {type="item", name="nexelit-plate", amount=3},
        {type="item", name="pipe", amount=12},
      },
      results = {
        {type="item", name="lab-instrument", amount=3},
      },
    },
    ["optical-fiber"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="nbfe-coating", amount=1},
        {type="item", name="niobium-oxide", amount=44},
        {type="item", name="nxsb-alloy", amount=1},
        {type="item", name="photophore", amount=1},
        {type="item", name="sodium-bisulfate", amount=3},
      },
      results = {
        {type="item", name="optical-fiber", amount=6},
      },
    },
    ["slacked-lime"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.7,
      ingredients = {
        {type="fluid", name="steam", amount=51},
        {type="item", name="calcium-carbide", amount=4},
        {type="item", name="soil", amount=9},
      },
      results = {
        {type="fluid", name="slacked-lime", amount=35},
      },
    },
    ["ppd"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.3,
      ingredients = {
        {type="fluid", name="flue-gas", amount=868},
        {type="fluid", name="hydrogen-chloride", amount=505},
        {type="fluid", name="organic-solvent", amount=175},
        {type="fluid", name="tall-oil", amount=604},
        {type="item", name="pyrite", amount=2},
        {type="item", name="seaweed", amount=177},
      },
      results = {
        {type="item", name="ppd", amount=13},
      },
    },
    ["lime-from-shell"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.9,
      ingredients = {
        {type="item", name="xyhiphoe", amount=1},
      },
      results = {
        {type="item", name="lime", amount=19},
      },
    },
    ["nbfe-coating"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="kevlar-coating", amount=1},
        {type="item", name="nbfe-alloy", amount=1},
      },
      results = {
        {type="item", name="nbfe-coating", amount=1},
      },
    },
    ["py-sodium-hydroxide"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.6,
      ingredients = {
        {type="fluid", name="slacked-lime", amount=14},
        {type="item", name="coke", amount=1},
        {type="item", name="seaweed", amount=7},
      },
      results = {
        {type="item", name="limestone", amount=3},
        {type="item", name="sodium-hydroxide", amount=6},
      },
    },
    ["sodium-bisulfate"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.0605325100568431,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=5},
        {type="item", name="coke", amount=1},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=2},
        {type="item", name="sodium-bisulfate", amount=0.0594583642354522},
      },
    },
    ["starch-4"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.700525952303655,
      ingredients = {
        {type="item", name="fiberboard", amount=1},
        {type="item", name="guar", amount=9},
        {type="item", name="silicon", amount=2},
        {type="item", name="sodium-bisulfate", amount=2},
      },
      results = {
        {type="item", name="biomass", amount=4},
        {type="item", name="starch", amount=7},
      },
    },
    ["aramid"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=77},
        {type="fluid", name="tpa", amount=21},
        {type="item", name="molybdenum-plate", amount=2},
        {type="item", name="salt", amount=18},
        {type="item", name="titanium-plate", amount=11},
      },
      results = {
        {type="item", name="aramid", amount=4},
      },
    },
    ["sodium-sulfate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="chromium", amount=1},
        {type="item", name="sodium-bisulfate", amount=1},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=40},
        {type="item", name="sodium-sulfate", amount=1},
      },
    },
    ["starch-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2.29947404769634,
      ingredients = {
        {type="item", name="coarse", amount=5},
        {type="item", name="coke", amount=23},
        {type="item", name="fiberboard", amount=1},
        {type="item", name="powdered-ralesia-seeds", amount=2},
        {type="item", name="sodium-bisulfate", amount=2},
      },
      results = {
        {type="item", name="biomass", amount=11},
        {type="item", name="starch", amount=23},
      },
    },
    ["casein-melamine"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="coal-gas", amount=315},
        {type="item", name="casein", amount=4},
      },
      results = {
        {type="item", name="melamine", amount=8},
      },
    },
    ["fecr-alloy"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="methane", amount=71},
        {type="fluid", name="pressured-air", amount=81},
        {type="item", name="chromite-sand", amount=4},
        {type="item", name="coke", amount=7},
        {type="item", name="pipe", amount=1},
      },
      results = {
        {type="item", name="fecr-alloy", amount=2},
      },
    },
    ["phenol-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.833333333333333,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=1193},
        {type="item", name="sugar", amount=9},
      },
      results = {
        {type="item", name="phenol", amount=5},
      },
    },
    ["silicon"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="fluid", name="syngas", amount=312},
        {type="item", name="coal-dust", amount=11},
        {type="item", name="coke", amount=38},
        {type="item", name="zinc-chloride", amount=1},
      },
      results = {
        {type="item", name="silicon", amount=16},
      },
    },
    ["sodium-silicate"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="syngas", amount=283},
        {type="item", name="tinned-cable", amount=4},
        {type="item", name="zinc-chloride", amount=2},
      },
      results = {
        {type="item", name="sodium-silicate", amount=1},
      },
    },
    ["bisphenol-a"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="acetone", amount=19},
        {type="fluid", name="water-saline", amount=136},
        {type="item", name="phenol", amount=1},
        {type="item", name="silicon", amount=13},
      },
      results = {
        {type="item", name="bisphenol-a", amount=3},
      },
    },
    ["melamine-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.3,
      ingredients = {
        {type="fluid", name="methanal", amount=29},
        {type="item", name="phenol", amount=3},
      },
      results = {
        {type="item", name="melamine", amount=6},
      },
    },
    ["phenol-02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.6,
      ingredients = {
        {type="item", name="cellulose", amount=2},
      },
      results = {
        {type="item", name="phenol", amount=3},
      },
    },
    ["silica-powder"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.9,
      ingredients = {
        {type="item", name="phenol", amount=13},
      },
      results = {
        {type="item", name="silica-powder", amount=9},
      },
    },
    ["bakelite"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.8,
      ingredients = {
        {type="item", name="phenol", amount=37},
        {type="item", name="zinc-chloride", amount=4},
      },
      results = {
        {type="item", name="bakelite", amount=9},
      },
    },
    ["epoxy"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="ech", amount=29},
        {type="item", name="bakelite", amount=10},
        {type="item", name="p2s5", amount=1},
      },
      results = {
        {type="item", name="epoxy", amount=6},
      },
    },
    ["nylon2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="ammonia", amount=300},
        {type="fluid", name="nitrogen", amount=359},
        {type="item", name="nichrome", amount=2},
        {type="item", name="ore-nickel", amount=11},
      },
      results = {
        {type="item", name="nylon", amount=9},
      },
    },
    ["blood-meal"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.239001439267052,
      ingredients = {
        {type="fluid", name="blood", amount=5},
        {type="fluid", name="fish-oil", amount=2},
        {type="item", name="fiberboard", amount=1},
      },
      results = {
        {type="item", name="blood-meal", amount=0.239001439267052},
      },
    },
    ["nylon-parts"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="nylon", amount=1},
      },
      results = {
        {type="item", name="nylon-parts", amount=5},
      },
    },
    ["nylon"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.6,
      ingredients = {
        {type="fluid", name="hydrogen", amount=122},
        {type="item", name="blood-meal", amount=2},
        {type="item", name="cellulose", amount=1},
        {type="item", name="chromium", amount=1},
      },
      results = {
        {type="item", name="nylon", amount=3},
      },
    },
    ["boric-acid-hcl"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.614018594394041,
      ingredients = {
        {type="fluid", name="boric-acid", amount=230},
        {type="item", name="salt", amount=4},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=46},
        {type="fluid", name="tailings", amount=123},
      },
    },
    ["manure-to-nitrogen"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="item", name="dried-meat", amount=8},
        {type="item", name="wood", amount=8},
        {type="item", name="yaedols", amount=1},
      },
      results = {
        {type="fluid", name="nitrogen", amount=70},
      },
    },
    ["mibc"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.41,
      ingredients = {
        {type="fluid", name="acetone", amount=38},
        {type="fluid", name="pressured-air", amount=204},
        {type="fluid", name="propene", amount=72},
        {type="fluid", name="syngas", amount=164},
        {type="item", name="chromite-sand", amount=7},
        {type="item", name="copper-plate", amount=4},
        {type="item", name="low-grade-rejects", amount=2},
      },
      results = {
        {type="fluid", name="mibc", amount=282},
      },
    },
    ["trichlorosilane"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.660427488583463,
      ingredients = {
        {type="fluid", name="water-saline", amount=119},
        {type="item", name="silicon", amount=5},
      },
      results = {
        {type="fluid", name="hydrogen", amount=67},
        {type="fluid", name="trichlorosilane", amount=33},
      },
    },
    ["eg-si"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.986146247051135,
      ingredients = {
        {type="fluid", name="pressured-water", amount=352},
        {type="fluid", name="pure-trichlorosilane", amount=48},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=97},
        {type="item", name="eg-si", amount=2},
      },
    },
    ["grade-4-ti"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="arqad-honey-barrel", amount=1},
        {type="item", name="grade-1-ti", amount=7},
        {type="item", name="hazard-concrete", amount=2},
      },
      results = {
        {type="item", name="grade-4-ti", amount=2},
      },
    },
    ["concentrated-ti"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.00245346728754,
      ingredients = {
        {type="item", name="ti-enriched-dust", amount=9},
      },
      results = {
        {type="item", name="concentrated-ti", amount=1},
        {type="item", name="iron-oxide", amount=1},
        {type="item", name="nexelit-ore", amount=1},
      },
    },
    ["high-grade-ti-powder"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="mibc", amount=893},
        {type="item", name="ti-enriched-dust", amount=4},
      },
      results = {
        {type="item", name="high-grade-ti-powder", amount=1},
      },
    },
    ["hotair-titanium-plate-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.64,
      ingredients = {
        {type="fluid", name="molten-titanium", amount=170},
        {type="item", name="sand", amount=4},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="titanium-plate", amount=41},
      },
    },
    ["molten-titanium-01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.225,
      ingredients = {
        {type="fluid", name="heavy-oil", amount=97},
        {type="item", name="powdered-ti", amount=2},
        {type="item", name="pure-sand", amount=2},
        {type="item", name="yotoi", amount=2},
      },
      results = {
        {type="fluid", name="molten-titanium", amount=49},
      },
    },
    ["molten-titanium-02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.886274509803922,
      ingredients = {
        {type="fluid", name="organic-acid-anhydride", amount=62},
        {type="item", name="filtration-media", amount=1},
        {type="item", name="powdered-ti", amount=4},
      },
      results = {
        {type="fluid", name="molten-titanium", amount=452},
      },
    },
    ["powdered-ti"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.982451991534504,
      ingredients = {
        {type="fluid", name="mibc", amount=50},
        {type="item", name="grade-3-ti", amount=5},
      },
      results = {
        {type="fluid", name="tailings", amount=39},
        {type="fluid", name="ti-pulp-03", amount=58},
        {type="item", name="powdered-ti", amount=2},
      },
    },
    ["titanium-plate-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.25,
      ingredients = {
        {type="item", name="sand-casting", amount=3},
      },
      results = {
        {type="item", name="titanium-plate", amount=5},
      },
    },
    ["titanium-plate-4"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.07482993197279,
      ingredients = {
        {type="fluid", name="molten-glass", amount=221},
        {type="item", name="grade-3-ti", amount=25},
        {type="item", name="silver-plate", amount=5},
      },
      results = {
        {type="item", name="titanium-plate", amount=158},
      },
    },
    ["purified-ti-pulp"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.02550917859984,
      ingredients = {
        {type="fluid", name="mibc", amount=188},
        {type="fluid", name="ti-pulp-03", amount=77},
        {type="item", name="grade-3-ti", amount=2},
      },
      results = {
        {type="fluid", name="purified-ti-pulp", amount=51},
        {type="fluid", name="ti-overflow-waste", amount=26},
      },
    },
    ["ti-enriched-dust"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="grade-2-ti", amount=6},
      },
      results = {
        {type="item", name="ti-enriched-dust", amount=2},
        {type="item", name="ti-rejects", amount=1},
      },
    },
    ["molten-stainless-steel"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.96,
      ingredients = {
        {type="fluid", name="molten-steel", amount=64},
        {type="item", name="cobalt-fluoride", amount=1},
        {type="item", name="fecr-alloy", amount=7},
        {type="item", name="nickel-plate", amount=3},
        {type="item", name="niobium-plate", amount=3},
        {type="item", name="phosphate-rock", amount=6},
      },
      results = {
        {type="fluid", name="molten-stainless-steel", amount=48},
      },
    },
    ["hotair-stainless-steel"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.46153846153846,
      ingredients = {
        {type="fluid", name="molten-stainless-steel", amount=132},
        {type="item", name="anemometer-mk01", amount=1},
        {type="item", name="aramid", amount=1},
      },
      results = {
        {type="item", name="stainless-steel", amount=19},
      },
    },
    ["stainless-steel"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="fluid", name="molten-stainless-steel", amount=93},
        {type="fluid", name="molten-steel", amount=196},
        {type="item", name="cobalt-fluoride", amount=1},
        {type="item", name="copper-plate", amount=4},
        {type="item", name="fecr-alloy", amount=3},
        {type="item", name="nickel-plate", amount=10},
        {type="item", name="niobium-plate", amount=1},
        {type="item", name="sodium-bisulfate", amount=2},
      },
      results = {
        {type="item", name="stainless-steel", amount=16},
      },
    },
    ["guar-gum"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="fiberboard", amount=1},
        {type="item", name="guar", amount=84},
        {type="item", name="sodium-bisulfate", amount=1},
      },
      results = {
        {type="item", name="guar-gum", amount=6},
      },
    },
    ["long-handed-inserter-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2.33333333333333,
      ingredients = {
        {type="item", name="electronics-mk01", amount=1},
        {type="item", name="fast-inserter", amount=5},
        {type="item", name="filtration-media", amount=1},
        {type="item", name="firearm-magazine", amount=31},
        {type="item", name="gasoline-barrel", amount=6},
        {type="item", name="soda-ash-barrel", amount=4},
        {type="item", name="transport-belt", amount=90},
        {type="item", name="used-comb", amount=3},
        {type="item", name="vitreloy", amount=1},
        {type="item", name="zipir-codex", amount=2},
      },
      results = {
        {type="item", name="long-handed-inserter", amount=35},
      },
    },
    ["small-parts-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="item", name="belt", amount=1},
        {type="item", name="coke", amount=4},
        {type="item", name="condensates-canister", amount=5},
        {type="item", name="duralumin", amount=1},
        {type="item", name="kerogen", amount=10},
        {type="item", name="limestone", amount=6},
        {type="item", name="nylon-parts", amount=4},
        {type="item", name="pipe", amount=2},
        {type="item", name="stainless-steel", amount=1},
        {type="item", name="stone-brick", amount=20},
      },
      results = {
        {type="item", name="small-parts-02", amount=4},
      },
    },
    ["fast-inserter-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.53333333333333,
      ingredients = {
        {type="item", name="cottongut-food-01", amount=64},
        {type="item", name="guar-gum", amount=2},
        {type="item", name="korlex-pup", amount=2},
        {type="item", name="nichrome", amount=17},
        {type="item", name="rotor-mk01", amount=2},
        {type="item", name="shaft-mk02", amount=1},
        {type="item", name="stainless-steel", amount=20},
        {type="item", name="utility-box-mk01", amount=2},
      },
      results = {
        {type="item", name="fast-inserter", amount=23},
      },
    },
    ["fast-transport-belt-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2.26666666666667,
      ingredients = {
        {type="item", name="bitumen-canister", amount=11},
        {type="item", name="duralumin", amount=12},
        {type="item", name="nexelit-power-pole", amount=7},
        {type="item", name="rare-earth-mud-barrel", amount=22},
        {type="item", name="rubber", amount=8},
        {type="item", name="shaft-mk02", amount=3},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="utility-box-mk01", amount=1},
      },
      results = {
        {type="item", name="fast-transport-belt", amount=34},
      },
    },
    ["rotor"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="engine-unit", amount=1},
        {type="item", name="kerogen", amount=9},
        {type="item", name="nxsb-alloy", amount=8},
      },
      results = {
        {type="item", name="rotor", amount=3},
      },
    },
    ["stator"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=6},
        {type="item", name="duralumin", amount=8},
        {type="item", name="pipe", amount=5},
      },
      results = {
        {type="item", name="stator", amount=1},
      },
    },
    ["electric-engine-unit"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="item", name="glass", amount=26},
        {type="item", name="iron-stick", amount=56},
        {type="item", name="rotor", amount=2},
        {type="item", name="shaft-mk02", amount=3},
        {type="item", name="stator", amount=2},
      },
      results = {
        {type="item", name="electric-engine-unit", amount=5},
      },
    },
    ["nexelit-power-pole"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="condensates-canister", amount=3},
        {type="item", name="limestone", amount=12},
        {type="item", name="stone-brick", amount=5},
      },
      results = {
        {type="item", name="nexelit-power-pole", amount=1},
      },
    },
    ["anemometer-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cermet", amount=11},
        {type="item", name="copper-plate", amount=7},
        {type="item", name="engine-unit", amount=5},
        {type="item", name="melamine", amount=17},
        {type="item", name="rare-earth-mud-barrel", amount=1},
        {type="item", name="vane-mk01", amount=1},
        {type="item", name="zinc-acetate", amount=8},
      },
      results = {
        {type="item", name="anemometer-mk02", amount=1},
      },
    },
    ["blade-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=8},
        {type="item", name="duralumin", amount=8},
        {type="item", name="nxsb-alloy", amount=4},
        {type="item", name="salt", amount=229},
        {type="item", name="shaft-mk01", amount=1},
      },
      results = {
        {type="item", name="blade-mk02", amount=1},
      },
    },
    ["brake-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="dried-meat", amount=20},
        {type="item", name="duralumin", amount=15},
        {type="item", name="engine-unit", amount=4},
        {type="item", name="gearbox-mk01", amount=3},
        {type="item", name="melamine-resin", amount=12},
        {type="item", name="niobium-pipe", amount=77},
        {type="item", name="phenol", amount=60},
        {type="item", name="sodium-bisulfate", amount=74},
      },
      results = {
        {type="item", name="brake-mk02", amount=2},
      },
    },
    ["controler-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="aluminium-plate", amount=151},
        {type="item", name="controler-mk01", amount=5},
        {type="item", name="electronics-mk02", amount=3},
        {type="item", name="epoxy", amount=14},
        {type="item", name="eva", amount=41},
        {type="item", name="pump", amount=14},
        {type="item", name="used-nexelit-battery", amount=11},
      },
      results = {
        {type="item", name="controler-mk02", amount=4},
      },
    },
    ["electronics-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="item", name="crucible", amount=55},
        {type="item", name="diode", amount=3},
        {type="item", name="electronic-circuit", amount=2},
        {type="item", name="heavy-n", amount=2},
        {type="item", name="inductor2", amount=10},
        {type="item", name="light-n", amount=6},
        {type="item", name="microchip", amount=4},
        {type="item", name="pcb1", amount=44},
        {type="item", name="pcb2", amount=2},
        {type="item", name="phenolicboard", amount=16},
        {type="item", name="reo", amount=7},
        {type="item", name="resistor1", amount=173},
        {type="item", name="rotor", amount=1},
        {type="item", name="transistor", amount=46},
        {type="item", name="used-nexelit-battery", amount=5},
        {type="item", name="zinc-acetate", amount=3},
      },
      results = {
        {type="item", name="electronics-mk02", amount=5},
      },
    },
    ["gearbox-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=17},
        {type="item", name="concrete", amount=1000},
        {type="item", name="dried-meat", amount=41},
        {type="item", name="engine-unit", amount=7},
        {type="item", name="gearbox-mk01", amount=2},
        {type="item", name="melamine-resin", amount=24},
        {type="item", name="nbfe-alloy", amount=4},
        {type="item", name="nexelit-power-pole", amount=2},
        {type="item", name="niobium-pipe", amount=155},
        {type="item", name="phenol", amount=121},
        {type="item", name="rare-earth-mud-barrel", amount=6},
        {type="item", name="sb-oxide", amount=27},
        {type="item", name="shaft-mk02", amount=1},
        {type="item", name="sodium-bisulfate", amount=58},
        {type="item", name="stainless-steel", amount=47},
        {type="item", name="titanium-plate", amount=23},
      },
      results = {
        {type="item", name="gearbox-mk02", amount=2},
      },
    },
    ["hotair-shaft-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=3},
      },
      results = {
        {type="item", name="shaft-mk02", amount=1},
      },
    },
    ["hotair-vane-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="boron-trioxide", amount=111},
      },
      results = {
        {type="item", name="vane-mk02", amount=1},
      },
    },
    ["shaft-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="molten-stainless-steel", amount=82},
        {type="item", name="anemometer-mk01", amount=3},
        {type="item", name="duralumin", amount=20},
        {type="item", name="methanal-barrel", amount=3},
        {type="item", name="niobium-oxide", amount=28},
      },
      results = {
        {type="item", name="shaft-mk02", amount=2},
      },
    },
    ["utility-box-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="bisphenol-a", amount=53},
        {type="item", name="display-panel", amount=3},
        {type="item", name="electronics-mk02", amount=1},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="fast-transport-belt", amount=10},
        {type="item", name="gunpowder", amount=51},
        {type="item", name="natural-gas-canister", amount=1},
        {type="item", name="neuroprocessor", amount=8},
        {type="item", name="niobium-pipe", amount=108},
        {type="item", name="utility-box-mk01", amount=1},
      },
      results = {
        {type="item", name="utility-box-mk02", amount=3},
      },
    },
    ["vane-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="boron-trioxide", amount=214},
        {type="item", name="zinc-chloride", amount=161},
      },
      results = {
        {type="item", name="vane-mk02", amount=2},
      },
    },
    ["nacelle-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="blade-mk02", amount=10},
        {type="item", name="controler-mk01", amount=31},
        {type="item", name="duralumin", amount=476},
        {type="item", name="eva", amount=15},
        {type="item", name="gearbox-mk01", amount=4},
        {type="item", name="low-distillate-barrel", amount=82},
        {type="item", name="mechanical-parts-01", amount=7},
        {type="item", name="multiblade-turbine-mk01", amount=2},
        {type="item", name="organic-acid-anhydride-barrel", amount=6},
        {type="item", name="sb-pulp-01-barrel", amount=5},
        {type="item", name="stator", amount=3},
        {type="item", name="utility-box-mk01", amount=5},
      },
      results = {
        {type="item", name="nacelle-mk02", amount=1},
      },
    },
    ["rotor-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="belt", amount=4},
        {type="item", name="electronics-mk01", amount=4},
        {type="item", name="sb-oxide", amount=45},
        {type="item", name="shaft-mk02", amount=2},
        {type="item", name="sodium-bisulfate", amount=23},
      },
      results = {
        {type="item", name="rotor-mk02", amount=1},
      },
    },
    ["tower-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="blade-mk02", amount=1},
        {type="item", name="duralumin", amount=97},
        {type="item", name="engine-unit", amount=22},
        {type="item", name="eva", amount=33},
        {type="item", name="sea-sponge-mk02", amount=7},
        {type="item", name="silver-plate", amount=9},
      },
      results = {
        {type="item", name="tower-mk02", amount=2},
      },
    },
    ["yaw-drive-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="blade-mk02", amount=2},
        {type="item", name="concrete", amount=111},
        {type="item", name="duralumin", amount=126},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="electronics-factory-mk01", amount=1},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="eva", amount=85},
        {type="item", name="niobium-oxide", amount=209},
        {type="item", name="rubber", amount=11},
        {type="item", name="sea-sponge-mk02", amount=7},
        {type="item", name="shaft-mk01", amount=2},
        {type="item", name="silver-plate", amount=1},
        {type="item", name="small-parts-01", amount=443},
        {type="item", name="tower-mk01", amount=2},
      },
      results = {
        {type="item", name="yaw-drive-mk02", amount=2},
      },
    },
    ["efficiency-module"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="advanced-circuit", amount=12},
        {type="item", name="py-science-pack-1", amount=7},
        {type="item", name="sweet-syrup-barrel", amount=20},
        {type="item", name="yaedols-codex", amount=1},
      },
      results = {
        {type="item", name="efficiency-module", amount=1},
      },
    },
    ["productivity-module"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="brake-mk02", amount=3},
        {type="item", name="gearbox-mk02", amount=1},
        {type="item", name="py-science-pack-1", amount=26},
        {type="item", name="sweet-syrup-barrel", amount=76},
        {type="item", name="xyhiphoe-pool-mk01", amount=3},
        {type="item", name="yaedols-codex", amount=5},
      },
      results = {
        {type="item", name="productivity-module", amount=3},
      },
    },
    ["speed-module"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="anemometer-mk02", amount=7},
        {type="item", name="earth-jute-sample", amount=3},
        {type="item", name="yaw-drive-mk02", amount=1},
      },
      results = {
        {type="item", name="speed-module", amount=2},
      },
    },
    ["bhoddos-codex"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.227122067472575,
      ingredients = {
        {type="item", name="chromium", amount=23},
        {type="item", name="electronic-circuit", amount=3},
        {type="item", name="filtration-media", amount=2},
        {type="item", name="lead-plate", amount=2},
      },
      results = {
        {type="item", name="bhoddos-codex", amount=0.227122067472575},
      },
    },
    ["cadaveric-arum-codex"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="electronic-circuit", amount=49},
        {type="item", name="filtration-media", amount=2},
        {type="item", name="sodium-sulfate", amount=3},
      },
      results = {
        {type="item", name="cadaveric-arum-codex", amount=1},
      },
    },
    ["navens-codex"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="blade-mk01", amount=29},
        {type="item", name="electronics-mk02", amount=6},
        {type="item", name="engine-unit", amount=7},
        {type="item", name="neuroprocessor", amount=19},
        {type="item", name="stator", amount=12},
        {type="item", name="transport-belt", amount=162},
      },
      results = {
        {type="item", name="navens-codex", amount=1},
      },
    },
    ["rennea-codex"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=20},
        {type="item", name="electronic-circuit", amount=30},
        {type="item", name="filtration-media", amount=1},
        {type="item", name="pipe", amount=5},
        {type="item", name="sodium-sulfate", amount=2},
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="rennea-codex", amount=1},
      },
    },
    ["grod-codex"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="burner-inserter", amount=3},
        {type="item", name="chromium", amount=97},
        {type="item", name="copper-cable", amount=96},
        {type="item", name="electronic-circuit", amount=89},
        {type="item", name="filtration-media", amount=6},
      },
      results = {
        {type="item", name="grod-codex", amount=2},
      },
    },
    ["yotoi-codex"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="electronic-circuit", amount=46},
        {type="item", name="filtration-media", amount=15},
        {type="item", name="pipe", amount=14},
      },
      results = {
        {type="item", name="yotoi-codex", amount=1},
      },
    },
    ["earth-jute-sample"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="chitin", amount=195},
        {type="item", name="py-roboport-mk01", amount=2},
        {type="item", name="py-science-pack-1", amount=93},
        {type="item", name="ralesia-codex", amount=2},
        {type="item", name="utility-box-mk01", amount=3},
      },
      results = {
        {type="item", name="earth-jute-sample", amount=3},
      },
    },
    ["earth-sunflower-sample"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="automation-science-pack", amount=32},
        {type="item", name="cdna", amount=1},
        {type="item", name="cottongut-codex", amount=1},
        {type="item", name="korlex-codex", amount=4},
        {type="item", name="py-science-pack-1", amount=446},
      },
      results = {
        {type="item", name="earth-sunflower-sample", amount=3},
      },
    },
    ["earth-tropical-tree-sample"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="automation-science-pack", amount=17},
        {type="item", name="korlex-codex", amount=6},
        {type="item", name="py-science-pack-1", amount=137},
      },
      results = {
        {type="item", name="earth-tropical-tree-sample", amount=1},
      },
    },
    ["cadaveric-arum-sample"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="alien-sample-02", amount=6},
        {type="item", name="cottongut-codex", amount=4},
        {type="item", name="cytostatics", amount=12},
        {type="item", name="earth-bear-sample", amount=2},
        {type="item", name="earth-potato-sample", amount=1},
        {type="item", name="earth-sunflower-sample", amount=2},
        {type="item", name="retrovirus", amount=15},
        {type="item", name="xyhiphoe-codex", amount=1},
        {type="item", name="yaedols-spores", amount=167},
      },
      results = {
        {type="item", name="cadaveric-arum", amount=6},
      },
    },
    ["cadaveric-arum-seeds"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="item", name="cadaveric-arum", amount=3},
      },
      results = {
        {type="item", name="cadaveric-arum-seeds", amount=6},
      },
    },
    ["cadaveric-arum-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="flue-gas", amount=833},
        {type="fluid", name="tar", amount=433},
        {type="item", name="cadaveric-arum-seeds", amount=7},
        {type="item", name="stone-wool", amount=1},
      },
      results = {
        {type="item", name="cadaveric-arum", amount=6},
      },
    },
    ["cadaveric-acidgas-01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.01357274496172,
      ingredients = {
        {type="item", name="cadaveric-arum", amount=2},
      },
      results = {
        {type="fluid", name="acidgas", amount=105},
        {type="item", name="cadaveric-arum-seeds", amount=2},
      },
    },
    ["grod-sample"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bio-sample01", amount=16},
        {type="item", name="cytostatics", amount=5},
        {type="item", name="earth-tropical-tree-sample", amount=1},
        {type="item", name="moss-gen", amount=8},
        {type="item", name="ralesia-codex", amount=3},
      },
      results = {
        {type="item", name="grod", amount=2},
      },
    },
    ["dried-grods"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="grod", amount=3},
        {type="item", name="rennea", amount=1},
      },
      results = {
        {type="item", name="dried-grods", amount=4},
      },
    },
    ["dried-grods-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.833333333333333,
      ingredients = {
        {type="item", name="rennea", amount=1},
      },
      results = {
        {type="item", name="dried-grods", amount=5},
      },
    },
    ["grod-seeds"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="grod", amount=1},
      },
      results = {
        {type="item", name="grod-seeds", amount=2},
      },
    },
    ["grod-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.7,
      ingredients = {
        {type="fluid", name="steam", amount=176},
        {type="item", name="clean-nexelit", amount=1},
        {type="item", name="grod-seeds", amount=5},
        {type="item", name="meat", amount=1},
        {type="item", name="urea", amount=4},
      },
      results = {
        {type="item", name="grod", amount=7},
      },
    },
    ["rennea-sample"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="alien-sample-02", amount=2},
        {type="item", name="cdna", amount=12},
        {type="item", name="cytostatics", amount=16},
        {type="item", name="earth-crustacean-sample", amount=5},
        {type="item", name="earth-sunflower-sample", amount=2},
        {type="item", name="retrovirus", amount=7},
        {type="item", name="tuuphra-codex", amount=1},
        {type="item", name="xyhiphoe-codex", amount=5},
      },
      results = {
        {type="item", name="rennea", amount=3},
      },
    },
    ["rennea-seeds"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.714285714285714,
      ingredients = {
        {type="item", name="rennea", amount=3},
      },
      results = {
        {type="item", name="rennea-seeds", amount=5},
      },
    },
    ["rennea-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="manure-bacteria", amount=29},
        {type="item", name="filtration-media", amount=1},
        {type="item", name="guar", amount=1},
        {type="item", name="rennea-seeds", amount=4},
        {type="item", name="yaedols", amount=1},
      },
      results = {
        {type="item", name="rennea", amount=4},
      },
    },
    ["bhoddos-to-ti"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="yaedols", amount=1},
      },
      results = {
        {type="item", name="ore-titanium", amount=8},
      },
    },
    ["blood-to-zinc"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="fluid", name="blood", amount=73},
      },
      results = {
        {type="item", name="ore-zinc", amount=15},
      },
    },
    ["fish-oil-to-tin"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.7,
      ingredients = {
        {type="fluid", name="fish-oil", amount=35},
      },
      results = {
        {type="item", name="ore-tin", amount=7},
      },
    },
    ["fish-to-tin"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="stone-wool", amount=7},
      },
      results = {
        {type="item", name="ore-tin", amount=20},
      },
    },
    ["grod-to-zinc"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.8,
      ingredients = {
        {type="item", name="grod", amount=10},
      },
      results = {
        {type="item", name="ore-zinc", amount=9},
      },
    },
    ["meat-to-chromium"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2.13333333333333,
      ingredients = {
        {type="fluid", name="blood", amount=56},
        {type="item", name="brain", amount=1},
      },
      results = {
        {type="item", name="ore-chromium", amount=32},
      },
    },
    ["navens-to-tin"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.17647058823529,
      ingredients = {
        {type="item", name="yaedols", amount=1},
      },
      results = {
        {type="item", name="ore-tin", amount=20},
      },
    },
    ["yotoi-leaves-to-chromium"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.35294117647059,
      ingredients = {
        {type="item", name="yotoi-fruit", amount=5},
      },
      results = {
        {type="item", name="ore-chromium", amount=23},
      },
    },
    ["yotoi-seed-to-chromium"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.04,
      ingredients = {
        {type="item", name="yotoi-fruit", amount=3},
      },
      results = {
        {type="item", name="ore-chromium", amount=26},
      },
    },
    ["cadaveric-pb"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="tar", amount=357},
        {type="item", name="cadaveric-arum-seeds", amount=1},
      },
      results = {
        {type="fluid", name="waste-water", amount=40},
        {type="item", name="s-biomass", amount=8},
      },
    },
    ["cool-pressured-steam-3000-to-2000"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.42,
      ingredients = {
        {type="fluid", name="pressured-steam", amount=200},
        {type="fluid", name="pressured-water", amount=46},
      },
      results = {
        {type="fluid", name="pressured-steam", amount=242},
      },
    },
    ["rennea-cu"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.905073071592178,
      ingredients = {
        {type="item", name="rennea-seeds", amount=5},
      },
      results = {
        {type="fluid", name="waste-water", amount=47},
        {type="item", name="cu-biomass", amount=9},
      },
    },
    ["tuuphra-nacl"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.686846799618282,
      ingredients = {
        {type="fluid", name="tar", amount=47},
        {type="item", name="tuuphra", amount=1},
      },
      results = {
        {type="fluid", name="waste-water", amount=33},
        {type="item", name="nacl-biomass", amount=7},
      },
    },
    ["grod-sn"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 4.31487093021827,
      ingredients = {
        {type="fluid", name="tar", amount=644},
        {type="item", name="grod", amount=3},
        {type="item", name="tuuphra", amount=2},
      },
      results = {
        {type="fluid", name="waste-water", amount=217},
        {type="item", name="sn-biomass", amount=43},
      },
    },
    ["navens-fe"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.10327355729489,
      ingredients = {
        {type="fluid", name="tar", amount=480},
        {type="item", name="navens", amount=1},
        {type="item", name="seaweed", amount=5},
      },
      results = {
        {type="fluid", name="waste-water", amount=54},
        {type="item", name="fe-biomass", amount=9},
      },
    },
    ["yotoi-fe"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="btx", amount=7},
        {type="fluid", name="tar", amount=93},
        {type="item", name="yotoi", amount=1},
      },
      results = {
        {type="fluid", name="waste-water", amount=40},
        {type="item", name="fe-biomass", amount=12},
      },
    },
    ["moondrop-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="fluid", name="hydrogen", amount=301},
        {type="item", name="cottongut-pup", amount=2},
        {type="item", name="drill-head", amount=1},
        {type="item", name="fertilizer", amount=7},
        {type="item", name="raw-fiber", amount=4},
        {type="item", name="sand", amount=17},
      },
      results = {
        {type="item", name="moondrop", amount=20},
      },
    },
    ["moonshine-fueloil-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 3.13333333333333,
      ingredients = {
        {type="fluid", name="methane", amount=186},
        {type="item", name="cu-biomass", amount=1},
        {type="item", name="moondrop", amount=8},
        {type="item", name="moondrop-mk02", amount=2},
      },
      results = {
        {type="item", name="moondrop-fueloil", amount=47},
      },
    },
    ["ethylene-chlorohydrin"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.32,
      ingredients = {
        {type="fluid", name="water-saline", amount=157},
        {type="item", name="gold-plate", amount=4},
      },
      results = {
        {type="fluid", name="ethylene-chlorohydrin", amount=132},
      },
    },
    ["moonshine-fueloil-pressing-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.7882521601367,
      ingredients = {
        {type="item", name="moondrop-mk02", amount=1},
      },
      results = {
        {type="fluid", name="fuel-oil", amount=714},
        {type="item", name="ash", amount=18},
      },
    },
    ["chloroethanol"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.65,
      ingredients = {
        {type="fluid", name="ethylene-chlorohydrin", amount=77},
        {type="fluid", name="low-distillate", amount=962},
      },
      results = {
        {type="fluid", name="chloroethanol", amount=165},
      },
    },
    ["ethylene-glycol"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.426666666666667,
      ingredients = {
        {type="fluid", name="chloroethanol", amount=42},
        {type="item", name="coke", amount=7},
      },
      results = {
        {type="fluid", name="ethylene-glycol", amount=64},
      },
    },
    ["ferrite"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="aluminium-plate", amount=13},
        {type="item", name="duralumin", amount=7},
        {type="item", name="iron-oxide", amount=15},
        {type="item", name="nichrome", amount=3},
        {type="item", name="zinc-plate", amount=8},
      },
      results = {
        {type="item", name="ferrite", amount=6},
      },
    },
    ["lead-container"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="niobium-oxide", amount=41},
        {type="item", name="nxsb-alloy", amount=2},
        {type="item", name="sodium-bisulfate", amount=6},
      },
      results = {
        {type="item", name="lead-container", amount=1},
      },
    },
    ["nexelit-matrix"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=640},
        {type="fluid", name="vacuum", amount=135},
        {type="item", name="bakelite", amount=3},
        {type="item", name="lead-plate", amount=4},
      },
      results = {
        {type="item", name="nexelit-matrix", amount=2},
      },
    },
    ["nuclear-sample"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="industrial-solvent", amount=79},
        {type="item", name="cermet", amount=6},
        {type="item", name="military-science-pack", amount=1},
        {type="item", name="nylon-parts", amount=6},
        {type="item", name="pu-242", amount=4},
        {type="item", name="ree-concentrate", amount=4},
        {type="item", name="silicon-wafer", amount=4},
        {type="item", name="tin-plate", amount=5},
      },
      results = {
        {type="item", name="nuclear-sample", amount=1},
      },
    },
    ["sodium-chlorate"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="fluid", name="boric-acid", amount=105},
        {type="fluid", name="steam", amount=64},
        {type="item", name="salt", amount=5},
        {type="item", name="sodium-hydroxide", amount=2},
      },
      results = {
        {type="item", name="sodium-chlorate", amount=6},
      },
    },
    ["steam-heating"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=1000},
        {type="item", name="fuelrod-mk01", amount=1},
      },
      results = {
        {type="fluid", name="steam", amount=1000},
      },
    },
    ["tuuphra-to-mo"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="tuuphra", amount=4},
      },
      results = {
        {type="item", name="molybdenum-ore", amount=4},
      },
    },
    ["plutonium-fuel-cell"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="al-pulp-01-barrel", amount=2},
        {type="item", name="empty-planter-box", amount=9},
        {type="item", name="mibc-barrel", amount=74},
        {type="item", name="tall-oil-canister", amount=6},
      },
      results = {
        {type="item", name="mox-fuel-cell", amount=1},
      },
    },
    ["crmoni"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="chromium", amount=3},
        {type="item", name="molybdenum-plate", amount=3},
        {type="item", name="molybdenum-sulfide", amount=17},
        {type="item", name="nickel-plate", amount=4},
        {type="item", name="salt", amount=9},
        {type="item", name="titanium-plate", amount=6},
      },
      results = {
        {type="item", name="crmoni", amount=3},
      },
    },
    ["nbalti"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="niobium-complex", amount=15},
        {type="fluid", name="nitrobenzene", amount=30},
        {type="item", name="coal-dust", amount=3},
        {type="item", name="nickel-plate", amount=8},
        {type="item", name="niobium-oxide", amount=3},
        {type="item", name="sic", amount=1},
        {type="item", name="titanium-plate", amount=6},
      },
      results = {
        {type="item", name="nbalti", amount=3},
      },
    },
    ["ptcda"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="mibc", amount=218},
        {type="fluid", name="organic-acid-anhydride", amount=86},
        {type="fluid", name="perylene", amount=86},
        {type="item", name="filtration-media", amount=1},
      },
      results = {
        {type="item", name="ptcda", amount=1},
      },
    },
    ["self-assembly-monolayer"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="crmoni", amount=1},
        {type="item", name="empty-planter-box", amount=2},
        {type="item", name="lead-acetate", amount=4},
        {type="item", name="nbalti", amount=2},
        {type="item", name="ptcda", amount=2},
        {type="item", name="rayon", amount=3},
        {type="item", name="sb-crushed", amount=12},
      },
      results = {
        {type="item", name="self-assembly-monolayer", amount=3},
      },
    },
    ["brain-cartridge-01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="fish-oil", amount=449},
        {type="item", name="brain", amount=11},
        {type="item", name="dried-meat", amount=5},
        {type="item", name="fenxsb-alloy", amount=1},
        {type="item", name="guts", amount=22},
      },
      results = {
        {type="item", name="brain-cartridge-01", amount=1},
      },
    },
    ["vat-brain"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="accumulator", amount=8},
        {type="item", name="diesel-barrel", amount=78},
        {type="item", name="generator-1", amount=1},
        {type="item", name="jaw-crusher", amount=1},
        {type="item", name="organic-acid-anhydride-barrel", amount=1},
        {type="item", name="powdered-quartz", amount=69},
        {type="item", name="py-coal-tile", amount=28},
        {type="item", name="stripped-distillate-barrel", amount=3},
      },
      results = {
        {type="item", name="vat-brain", amount=2},
      },
    },
    ["mk02-locomotive"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="brake-mk02", amount=2},
        {type="item", name="coal-slurry-barrel", amount=155},
        {type="item", name="controler-mk01", amount=5},
        {type="item", name="crushed-oil-sand", amount=774},
        {type="item", name="depolymerized-organics-barrel", amount=42},
        {type="item", name="diesel-barrel", amount=604},
        {type="item", name="drilling-fluid-0-barrel", amount=207},
        {type="item", name="duralumin", amount=51},
        {type="item", name="fluid-drill-mk01", amount=2},
        {type="item", name="formic-acid-barrel", amount=25},
        {type="item", name="green-refined-concrete", amount=813},
        {type="item", name="korlex-codex-mk02", amount=2},
        {type="item", name="liquid-nitrogen-barrel", amount=8},
        {type="item", name="middle-oil-canister", amount=105},
        {type="item", name="mixed-ores", amount=323},
        {type="item", name="molten-aluminium-barrel", amount=2},
        {type="item", name="molten-steel-barrel", amount=22},
        {type="item", name="natural-gas-barrel", amount=9},
        {type="item", name="niobium-pipe", amount=462},
        {type="item", name="nxsb-alloy", amount=38},
        {type="item", name="redhot-coke", amount=492},
        {type="item", name="sic", amount=101},
        {type="item", name="stripped-distillate-barrel", amount=166},
        {type="item", name="sweet-syrup-barrel", amount=2},
        {type="item", name="titanium-plate", amount=662},
        {type="item", name="tower-mk02", amount=2},
        {type="item", name="utility-box-mk02", amount=4},
        {type="item", name="yaw-drive-mk01", amount=1},
      },
      results = {
        {type="item", name="mk02-locomotive", amount=3},
      },
    },
    ["mk02-wagon"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="chlorine", amount=703},
        {type="item", name="al-pulp-02-barrel", amount=1},
        {type="item", name="anemometer-mk01", amount=2},
        {type="item", name="anemometer-mk02", amount=3},
        {type="item", name="btx-barrel", amount=32},
        {type="item", name="concentrated-ti", amount=5},
        {type="item", name="cottongut-food-01", amount=41},
        {type="item", name="depolymerized-organics-barrel", amount=1},
        {type="item", name="empty-petri-dish", amount=85},
        {type="item", name="guar-gum", amount=4},
        {type="item", name="kerosene-barrel", amount=70},
        {type="item", name="middle-oil-canister", amount=3},
        {type="item", name="nichrome", amount=34},
        {type="item", name="niobium-dust", amount=44},
        {type="item", name="py-steel", amount=27},
        {type="item", name="py-tank-9000", amount=1},
        {type="item", name="rotor-mk01", amount=1},
        {type="item", name="shaft-mk02", amount=6},
        {type="item", name="stainless-steel", amount=13},
        {type="item", name="storage-tank", amount=1},
        {type="item", name="titanium-plate", amount=30},
        {type="item", name="utility-box-mk01", amount=4},
      },
      results = {
        {type="item", name="mk02-wagon", amount=2},
      },
    },
    ["mk02-fluid-wagon"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="brake-mk02", amount=1},
        {type="item", name="crushed-oil-sand", amount=52},
        {type="item", name="diesel-barrel", amount=40},
        {type="item", name="drilling-fluid-0-barrel", amount=36},
        {type="item", name="formic-acid-barrel", amount=4},
        {type="item", name="methanol-canister", amount=4},
        {type="item", name="mixed-ores", amount=56},
        {type="item", name="molten-aluminium-barrel", amount=1},
        {type="item", name="nichrome", amount=2},
        {type="item", name="niobium-pipe", amount=31},
        {type="item", name="nxsb-alloy", amount=7},
        {type="item", name="redhot-coke", amount=85},
        {type="item", name="stripped-distillate-barrel", amount=89},
        {type="item", name="titanium-plate", amount=45},
      },
      results = {
        {type="item", name="mk02-fluid-wagon", amount=1},
      },
    },
    ["glycerol2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.84,
      ingredients = {
        {type="fluid", name="water", amount=1838},
        {type="fluid", name="water-saline", amount=60},
        {type="item", name="brain", amount=2},
        {type="item", name="starch", amount=1},
      },
      results = {
        {type="fluid", name="glycerol", amount=42},
      },
    },
    ["oleochemicals-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.635,
      ingredients = {
        {type="item", name="agar", amount=2},
        {type="item", name="rennea", amount=1},
        {type="item", name="sporopollenin", amount=5},
        {type="item", name="sugar", amount=7},
      },
      results = {
        {type="fluid", name="oleochemicals", amount=327},
      },
    },
    ["sea-sponge-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.333074125223354,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=20},
        {type="fluid", name="zogna-bacteria", amount=5},
        {type="item", name="kicalk-seeds", amount=11},
      },
      results = {
        {type="fluid", name="water-saline", amount=16},
        {type="item", name="sea-sponge", amount=1},
      },
    },
    ["silicon-wafer"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.999301556971,
      ingredients = {
        {type="item", name="chromium", amount=2},
        {type="item", name="coke", amount=11},
        {type="item", name="crucible", amount=1},
        {type="item", name="crushed-quartz", amount=1},
        {type="item", name="sodium-bisulfate", amount=5},
      },
      results = {
        {type="fluid", name="flue-gas", amount=192},
        {type="item", name="silicon-wafer", amount=4},
      },
    },
    ["heat-exchanger"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="al-pulp-02-barrel", amount=7},
        {type="item", name="niobium-pipe-to-ground", amount=1},
        {type="item", name="unslimed-iron", amount=1},
      },
      results = {
        {type="item", name="heat-exchanger", amount=1},
      },
    },
    ["heat-pipe"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="condensates-canister", amount=1},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="methanal-barrel", amount=53},
        {type="item", name="niobium-oxide", amount=4},
        {type="item", name="nxsb-alloy", amount=1},
      },
      results = {
        {type="item", name="heat-pipe", amount=2},
      },
    },
    ["nuclear-reactor"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="accumulator", amount=1},
        {type="item", name="aluminium-plate", amount=1000},
        {type="item", name="lab-instrument", amount=71},
        {type="item", name="mechanical-parts-01", amount=610},
        {type="item", name="petri-dish-bacteria", amount=386},
        {type="item", name="py-oil-powerplant-mk01", amount=1},
        {type="item", name="thickener-mk01", amount=4},
      },
      results = {
        {type="item", name="nuclear-reactor", amount=1},
      },
    },
    ["steam-turbine"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="etching", amount=77},
        {type="item", name="copper-low-dust", amount=2},
        {type="item", name="copper-plate", amount=58},
        {type="item", name="fish-hydrolysate-barrel", amount=1},
        {type="item", name="nylon", amount=3},
        {type="item", name="petroleum-gas-canister", amount=5},
        {type="item", name="phenolicboard", amount=22},
        {type="item", name="stainless-steel", amount=13},
        {type="item", name="stator", amount=1},
        {type="item", name="tin-plate", amount=15},
      },
      results = {
        {type="item", name="steam-turbine", amount=2},
      },
    },
    ["zinc-acetate"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="acetic-acid", amount=60},
        {type="item", name="coke", amount=2},
        {type="item", name="zinc-plate", amount=11},
      },
      results = {
        {type="item", name="zinc-acetate", amount=1},
      },
    },
    ["heavy-n"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="sb-pulp-02", amount=193},
        {type="item", name="ree-concentrate", amount=40},
        {type="item", name="silicon-wafer", amount=2},
      },
      results = {
        {type="item", name="heavy-n", amount=8},
      },
    },
    ["light-n"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="etching", amount=20},
        {type="item", name="silicon-wafer", amount=9},
        {type="item", name="zinc-acetate", amount=1},
      },
      results = {
        {type="item", name="light-n", amount=15},
      },
    },
    ["p-dope"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="silicon-wafer", amount=1},
        {type="item", name="zinc-acetate", amount=3},
      },
      results = {
        {type="item", name="p-dope", amount=5},
      },
    },
    ["ammonium-chloride"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ammonia", amount=17},
        {type="fluid", name="carbon-dioxide", amount=520},
        {type="fluid", name="nitrogen", amount=412},
        {type="item", name="ore-nickel", amount=39},
      },
      results = {
        {type="item", name="ammonium-chloride", amount=2},
        {type="item", name="sodium-carbonate", amount=1},
      },
    },
    ["p2s5-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=76},
        {type="item", name="sulfur", amount=2},
        {type="item", name="wood", amount=4},
      },
      results = {
        {type="item", name="p2s5", amount=1},
        {type="item", name="pyrite", amount=2},
      },
    },
    ["uranium-fuel-cell"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="al-pulp-01-barrel", amount=7},
        {type="item", name="crucible", amount=28},
        {type="item", name="empty-planter-box", amount=38},
        {type="item", name="mibc-barrel", amount=125},
        {type="item", name="nxsb-alloy", amount=13},
        {type="item", name="sb-oxide", amount=2},
      },
      results = {
        {type="item", name="uranium-fuel-cell", amount=2},
      },
    },
    ["fuel-cell-dissolve"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.96,
      ingredients = {
        {type="item", name="kicalk-plantation-mk01", amount=9},
      },
      results = {
        {type="fluid", name="sb-phosphate-1", amount=96},
      },
    },
    ["plutonium-fuel-reprocessing"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.13438967952742,
      ingredients = {
        {type="item", name="electronics-mk01", amount=7},
        {type="item", name="kicalk-plantation-mk01", amount=1},
        {type="item", name="sb-oxide", amount=29},
        {type="item", name="sodium-bisulfate", amount=15},
      },
      results = {
        {type="item", name="plutonium-oxide", amount=16},
        {type="item", name="u-238", amount=11},
      },
    },
    ["antimony-phosphate"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.195,
      ingredients = {
        {type="fluid", name="ammonia", amount=519},
        {type="fluid", name="cyanic-acid", amount=736},
        {type="fluid", name="ethylene", amount=1406},
        {type="fluid", name="molten-salt", amount=234},
        {type="item", name="fawogae", amount=70},
        {type="item", name="nxsb-alloy", amount=1},
        {type="item", name="pure-sand", amount=177},
      },
      results = {
        {type="fluid", name="purex-concentrate-1", amount=119},
        {type="item", name="sb-hpo-pu", amount=12},
      },
    },
    ["plutonium-seperation"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.843794234522029,
      ingredients = {
        {type="fluid", name="cyanic-acid", amount=115},
        {type="item", name="fawogae", amount=11},
        {type="item", name="plutonium-oxide", amount=4},
        {type="item", name="pure-sand", amount=28},
      },
      results = {
        {type="item", name="pu-238", amount=0.258848391890692},
        {type="item", name="pu-239", amount=7},
        {type="item", name="pu-240", amount=3},
        {type="item", name="pu-241", amount=2},
        {type="item", name="pu-242", amount=6},
      },
    },
    ["plutonium-oxidation"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.54,
      ingredients = {
        {type="fluid", name="hydrogen-peroxide", amount=494},
        {type="item", name="brain", amount=2},
        {type="item", name="sb-hpo-pu", amount=2},
      },
      results = {
        {type="fluid", name="plutonium-peroxide", amount=154},
        {type="fluid", name="sb-phosphate-2", amount=154},
      },
    },
    ["plutonium-shuffle-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="plutonium-peroxide", amount=32},
        {type="item", name="plutonium-oxide", amount=7},
        {type="item", name="pu-239", amount=1},
      },
      results = {
        {type="item", name="pu-238", amount=2},
        {type="item", name="pu-242", amount=2},
      },
    },
    ["plutonium-shuffle-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="plutonium-peroxide", amount=43},
        {type="item", name="nxsb-alloy", amount=1},
        {type="item", name="plutonium-oxide", amount=1},
        {type="item", name="sb-hpo-pu", amount=1},
      },
      results = {
        {type="item", name="pu-240", amount=1},
        {type="item", name="pu-242", amount=1},
      },
    },
    ["plutonium-shuffle-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="plutonium-peroxide", amount=62},
        {type="item", name="pu-240", amount=3},
      },
      results = {
        {type="item", name="pu-239", amount=2},
        {type="item", name="pu-241", amount=2},
      },
    },
    ["plutonium-shuffle-4"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="plutonium-oxide", amount=6},
      },
      results = {
        {type="item", name="pu-239", amount=1},
        {type="item", name="pu-240", amount=1},
      },
    },
    ["rayon"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="fluid", name="carbon-sulfide", amount=48},
        {type="fluid", name="sulfuric-acid", amount=114},
        {type="item", name="aluminium-plate", amount=10},
        {type="item", name="capacitor1", amount=7},
        {type="item", name="copper-cable", amount=113},
        {type="item", name="raw-fiber", amount=32},
        {type="item", name="sodium-bisulfate", amount=2},
        {type="item", name="urea", amount=10},
      },
      results = {
        {type="item", name="rayon", amount=6},
      },
    },
    ["battery-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.666666666666667,
      ingredients = {
        {type="item", name="pbsb-alloy", amount=6},
        {type="item", name="salt", amount=10},
      },
      results = {
        {type="item", name="battery-mk01", amount=2},
      },
    },
    ["battery-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="item", name="p2s5", amount=3},
        {type="item", name="pbsb-alloy", amount=6},
        {type="item", name="rayon", amount=3},
      },
      results = {
        {type="item", name="battery-mk01", amount=5},
      },
    },
    ["nas-battery"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-oxide", amount=12},
        {type="item", name="kicalk", amount=3},
        {type="item", name="nxsb-alloy", amount=2},
        {type="item", name="rayon", amount=3},
        {type="item", name="salt", amount=116},
      },
      results = {
        {type="item", name="battery-mk01", amount=6},
      },
    },
    ["nexelit-battery"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="anthraquinone", amount=52},
        {type="item", name="aluminium-plate", amount=11},
        {type="item", name="bio-sample", amount=4},
        {type="item", name="pipe", amount=6},
        {type="item", name="sodium-silicate", amount=1},
      },
      results = {
        {type="item", name="used-nexelit-battery", amount=2},
      },
    },
    ["nexelit-battery-recharge"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="fish-hydrolysate", amount=75},
        {type="item", name="fawogae-spore", amount=14},
        {type="item", name="pure-sand", amount=9},
        {type="item", name="soil-extractor-mk01", amount=1},
      },
      results = {
        {type="item", name="nexelit-battery", amount=2},
      },
    },
    ["casein-mixture-03"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33813284309806,
      ingredients = {
        {type="fluid", name="acetic-acid", amount=85},
        {type="fluid", name="milk", amount=38},
        {type="fluid", name="sulfuric-acid", amount=41},
        {type="item", name="zinc-plate", amount=6},
      },
      results = {
        {type="fluid", name="casein-mixture", amount=107},
        {type="fluid", name="waste-water", amount=67},
      },
    },
    ["fish-emulsion"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="fish-hydrolysate", amount=97},
        {type="item", name="dried-meat", amount=1},
      },
      results = {
        {type="fluid", name="fish-emulsion", amount=40},
        {type="fluid", name="fish-oil", amount=15},
        {type="item", name="fishmeal", amount=10},
      },
    },
    ["b-molasse"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.31,
      ingredients = {
        {type="fluid", name="a-molasse", amount=48},
        {type="fluid", name="zogna-bacteria", amount=17},
        {type="item", name="stone-wool", amount=1},
      },
      results = {
        {type="fluid", name="b-molasse", amount=131},
      },
    },
    ["ethanol"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.64,
      ingredients = {
        {type="fluid", name="b-molasse", amount=38},
        {type="fluid", name="zogna-bacteria", amount=10},
        {type="item", name="fertilizer", amount=3},
      },
      results = {
        {type="fluid", name="ethanol", amount=64},
      },
    },
    ["syrup-01"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=199},
        {type="fluid", name="xenogenic-cells", amount=140},
        {type="item", name="agar", amount=20},
        {type="item", name="lignin", amount=1},
        {type="item", name="sporopollenin", amount=1},
        {type="item", name="sugar", amount=1},
      },
      results = {
        {type="fluid", name="syrup-01", amount=55},
      },
    },
    ["fertilizer-5"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="fluid", name="zogna-bacteria", amount=12},
        {type="item", name="bones", amount=7},
        {type="item", name="clean-nexelit", amount=8},
        {type="item", name="pure-sand", amount=11},
        {type="item", name="sodium-bisulfate", amount=1},
        {type="item", name="urea", amount=32},
      },
      results = {
        {type="item", name="fertilizer", amount=25},
      },
    },
    ["fertilizer-fish-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="fish-emulsion", amount=97},
        {type="item", name="nickel-plate", amount=8},
      },
      results = {
        {type="item", name="fertilizer", amount=3},
      },
    },
    ["fertilizer-fish-3"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="albumin", amount=1},
        {type="item", name="fishmeal", amount=9},
        {type="item", name="ralesia-seeds", amount=26},
        {type="item", name="wood", amount=18},
        {type="item", name="yaedols-spores", amount=5},
      },
      results = {
        {type="item", name="fertilizer", amount=3},
      },
    },
    ["split-yellowcake"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.94444444444444,
      ingredients = {
        {type="item", name="boron-trioxide", amount=2},
        {type="item", name="carbon-black", amount=50},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="pipe", amount=8},
        {type="item", name="yellow-cake", amount=11},
      },
      results = {
        {type="item", name="u-235", amount=2},
        {type="item", name="u-238", amount=17},
      },
    },
    ["plutonium"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="fluid", name="plutonium-peroxide", amount=151},
        {type="item", name="pu-240", amount=1},
      },
      results = {
        {type="item", name="plutonium-oxide", amount=16},
      },
    },
    ["night-vision-equipment"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="electronics-mk01", amount=2},
        {type="item", name="gasoline-barrel", amount=4},
        {type="item", name="soda-ash-barrel", amount=2},
        {type="item", name="transport-belt", amount=22},
      },
      results = {
        {type="item", name="night-vision-equipment", amount=3},
      },
    },
    ["personal-roboport-mk2-equipment"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=138},
        {type="item", name="buffer-chest", amount=4},
        {type="item", name="cadaveric-arum-codex", amount=4},
        {type="item", name="controler-mk01", amount=1},
        {type="item", name="epoxy", amount=33},
        {type="item", name="geothermal-plant-mk01", amount=1},
        {type="item", name="pump", amount=4},
        {type="item", name="py-construction-robot-mk01", amount=13},
        {type="item", name="used-nexelit-battery", amount=25},
      },
      results = {
        {type="item", name="personal-roboport-mk2-equipment", amount=2},
      },
    },
    ["belt-immunity-equipment"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="acetylene-barrel", amount=43},
        {type="item", name="refined-natural-gas-barrel", amount=101},
        {type="item", name="storage-tank", amount=3},
      },
      results = {
        {type="item", name="belt-immunity-equipment", amount=2},
      },
    },
    ["bio-scafold"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="chitin", amount=20},
      },
      results = {
        {type="item", name="bio-scafold", amount=1},
      },
    },
    ["bone-fat"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=320},
        {type="item", name="bones", amount=2},
      },
      results = {
        {type="item", name="mukmoux-fat", amount=2},
      },
    },
    ["print-bonemeal"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="psc", amount=46},
        {type="item", name="bio-scafold", amount=1},
      },
      results = {
        {type="item", name="bonemeal", amount=4},
      },
    },
    ["print-bones"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="item", name="bio-scafold", amount=1},
        {type="item", name="chitin", amount=21},
      },
      results = {
        {type="item", name="bones", amount=5},
      },
    },
    ["print-brain"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="psc", amount=55},
        {type="item", name="bio-scafold", amount=1},
      },
      results = {
        {type="item", name="brain", amount=2},
      },
    },
    ["print-fat"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="item", name="bio-scafold", amount=1},
        {type="item", name="brain", amount=3},
        {type="item", name="chitin", amount=6},
      },
      results = {
        {type="item", name="mukmoux-fat", amount=6},
      },
    },
    ["print-guts"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="psc", amount=41},
        {type="item", name="bio-scafold", amount=1},
      },
      results = {
        {type="item", name="guts", amount=6},
      },
    },
    ["print-meat"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.75,
      ingredients = {
        {type="item", name="bio-scafold", amount=2},
      },
      results = {
        {type="item", name="meat", amount=7},
      },
    },
    ["print-skin"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.2,
      ingredients = {
        {type="fluid", name="psc", amount=51},
      },
      results = {
        {type="item", name="skin", amount=1},
      },
    },
    ["cellulose-gasification"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="pressured-air", amount=153},
        {type="item", name="cellulose", amount=4},
        {type="item", name="coke", amount=1},
      },
      results = {
        {type="fluid", name="syngas", amount=80},
      },
    },
    ["lignin-to-aromatics"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="item", name="cellulose", amount=4},
      },
      results = {
        {type="fluid", name="aromatics", amount=210},
      },
    },
    ["tpa"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2.86,
      ingredients = {
        {type="fluid", name="aromatics", amount=250},
        {type="fluid", name="liquid-nitrogen", amount=125},
        {type="fluid", name="vacuum", amount=2679},
        {type="item", name="cobalt-extract", amount=3},
        {type="item", name="cobalt-fluoride", amount=2},
        {type="item", name="nickel-plate", amount=6},
        {type="item", name="silicon", amount=13},
        {type="item", name="yotoi-leaves", amount=4},
      },
      results = {
        {type="fluid", name="tpa", amount=143},
      },
    },
    ["oleo-gasification"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.14564205816555,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=444},
        {type="fluid", name="oleochemicals", amount=252},
      },
      results = {
        {type="fluid", name="aromatics", amount=229},
        {type="fluid", name="tar", amount=344},
      },
    },
    ["crucible"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="clay", amount=10},
        {type="item", name="empty-planter-box", amount=17},
        {type="item", name="sodium-silicate", amount=1},
      },
      results = {
        {type="item", name="crucible", amount=3},
      },
    },
    ["eva"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="fluid", name="processed-fatty-acids", amount=27},
        {type="fluid", name="vinyl-acetate", amount=48},
      },
      results = {
        {type="item", name="eva", amount=6},
      },
    },
    ["mechanical-parts-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=5},
        {type="item", name="anemometer-mk01", amount=21},
        {type="item", name="blade-mk02", amount=4},
        {type="item", name="brake-mk01", amount=9},
        {type="item", name="controler-mk01", amount=4},
        {type="item", name="duralumin", amount=190},
        {type="item", name="engine-unit", amount=6},
        {type="item", name="gearbox-mk01", amount=4},
        {type="item", name="kevlar", amount=3},
        {type="item", name="low-distillate-barrel", amount=33},
        {type="item", name="mechanical-parts-01", amount=7},
        {type="item", name="micro-fiber", amount=35},
        {type="item", name="py-ze", amount=10},
        {type="item", name="rotor-mk02", amount=2},
        {type="item", name="tower-mk02", amount=1},
        {type="item", name="utility-box-mk01", amount=7},
      },
      results = {
        {type="item", name="mechanical-parts-02", amount=9},
      },
    },
    ["sb-oxide-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="sb-pulp-02", amount=97},
      },
      results = {
        {type="item", name="sb-oxide", amount=3},
      },
    },
    ["sb-oxide-02a"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.1,
      ingredients = {
        {type="fluid", name="sb-58-conc", amount=38},
        {type="fluid", name="sb-pulp-02", amount=43},
        {type="item", name="ree-concentrate", amount=9},
        {type="item", name="silicon-wafer", amount=4},
        {type="item", name="zinc-chloride", amount=3},
      },
      results = {
        {type="item", name="sb-oxide", amount=11},
      },
    },
    ["lead-acetate"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.048515840824384,
      ingredients = {
        {type="fluid", name="flue-gas", amount=946},
        {type="item", name="lead-plate", amount=2},
      },
      results = {
        {type="item", name="lead-acetate", amount=0.048515840824384},
      },
    },
    ["dowfroth-250"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.42,
      ingredients = {
        {type="fluid", name="ethylene-glycol", amount=42},
        {type="item", name="chromium", amount=2},
      },
      results = {
        {type="fluid", name="dowfroth-250", amount=42},
      },
    },
    ["sb-crushed"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="calcium-carbide", amount=6},
        {type="item", name="sb-grade-02", amount=12},
      },
      results = {
        {type="item", name="sb-crushed", amount=1},
      },
    },
    ["sb-dust"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2.97498879334369,
      ingredients = {
        {type="item", name="calcium-carbide", amount=28},
        {type="item", name="sb-crushed", amount=2},
        {type="item", name="sb-grade-02", amount=48},
      },
      results = {
        {type="item", name="sb-dust", amount=3},
        {type="item", name="sb-grade-04", amount=1},
      },
    },
    ["sb-pulp-01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.015,
      ingredients = {
        {type="item", name="lead-acetate", amount=1},
        {type="item", name="sb-crushed", amount=7},
      },
      results = {
        {type="fluid", name="sb-pulp-01", amount=203},
      },
    },
    ["sb-pulp-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.78,
      ingredients = {
        {type="fluid", name="dowfroth-250", amount=38},
        {type="fluid", name="sb-pulp-01", amount=77},
      },
      results = {
        {type="fluid", name="sb-58-conc", amount=8},
        {type="fluid", name="sb-pulp-02", amount=38},
      },
    },
    ["fast-splitter"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="display-panel", amount=5},
        {type="item", name="fast-transport-belt", amount=6},
        {type="item", name="gunpowder", amount=27},
        {type="item", name="natural-gas-canister", amount=5},
        {type="item", name="neuroprocessor", amount=4},
      },
      results = {
        {type="item", name="fast-splitter", amount=2},
      },
    },
    ["fast-transport-belt"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="duralumin", amount=6},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="lead-plate", amount=5},
        {type="item", name="niobium-oxide", amount=8},
      },
      results = {
        {type="item", name="fast-transport-belt", amount=3},
      },
    },
    ["fast-underground-belt"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="bitumen-canister", amount=28},
        {type="item", name="nexelit-power-pole", amount=7},
        {type="item", name="rare-earth-mud-barrel", amount=56},
        {type="item", name="utility-box-mk01", amount=1},
      },
      results = {
        {type="item", name="fast-underground-belt", amount=3},
      },
    },
    ["neutron-absorber-mk01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="automated-factory-mk01", amount=1},
        {type="item", name="blue-liquor-barrel", amount=2},
        {type="item", name="cocoon", amount=61},
        {type="item", name="engine-unit", amount=7},
        {type="item", name="stone-wall", amount=18},
        {type="item", name="stopper", amount=60},
        {type="item", name="vane-mk01", amount=6},
        {type="item", name="vrauks-food-01", amount=52},
        {type="item", name="warmer-stone-brick", amount=27},
      },
      results = {
        {type="item", name="neutron-absorber-mk01", amount=1},
      },
    },
    ["py-biomass-powerplant-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="lab-instrument", amount=33},
        {type="item", name="nacelle-mk02", amount=1},
        {type="item", name="petri-dish-bacteria", amount=179},
        {type="item", name="py-oil-powerplant-mk01", amount=1},
        {type="item", name="sb-58-conc-barrel", amount=40},
        {type="item", name="tall-oil-barrel", amount=323},
        {type="item", name="thickener-mk01", amount=2},
        {type="item", name="utility-box-mk02", amount=48},
      },
      results = {
        {type="item", name="py-biomass-powerplant-mk02", amount=2},
      },
    },
    ["py-coal-powerplant-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="advanced-circuit", amount=55},
        {type="item", name="bio-scafold", amount=6},
        {type="item", name="carbon-sulfide-barrel", amount=231},
        {type="item", name="electric-engine-unit", amount=12},
        {type="item", name="intermetallics", amount=161},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="methanal-barrel", amount=112},
        {type="item", name="nacelle-mk02", amount=1},
        {type="item", name="py-biomass-powerplant-mk01", amount=1},
        {type="item", name="sb-58-conc-barrel", amount=1},
      },
      results = {
        {type="item", name="py-coal-powerplant-mk02", amount=1},
      },
    },
    ["py-oil-powerplant-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anemometer-mk02", amount=11},
        {type="item", name="caged-mukmoux", amount=3},
        {type="item", name="coalbed-mk01", amount=12},
        {type="item", name="coarse-coal", amount=61},
        {type="item", name="diode", amount=22},
        {type="item", name="hot-syngas-canister", amount=88},
        {type="item", name="hydrocyclone-mk01", amount=1},
        {type="item", name="lab", amount=23},
        {type="item", name="mechanical-parts-01", amount=8},
        {type="item", name="neuroprocessor", amount=47},
        {type="item", name="ppd", amount=199},
        {type="item", name="py-biomass-powerplant-mk01", amount=1},
        {type="item", name="py-heat-exchanger", amount=1},
        {type="item", name="rotor", amount=2},
        {type="item", name="sodium-chlorate", amount=540},
        {type="item", name="tall-oil-canister", amount=106},
      },
      results = {
        {type="item", name="py-oil-powerplant-mk02", amount=1},
      },
    },
    ["tidal-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anemometer-mk02", amount=4},
        {type="item", name="electronics-mk02", amount=13},
        {type="item", name="engine-unit", amount=35},
        {type="item", name="fast-transport-belt", amount=101},
        {type="item", name="fatty-acids-barrel", amount=68},
        {type="item", name="mechanical-parts-01", amount=77},
        {type="item", name="py-oil-powerplant-mk01", amount=1},
        {type="item", name="rotor-mk02", amount=5},
        {type="item", name="yaw-drive-mk01", amount=1},
      },
      results = {
        {type="item", name="tidal-mk02", amount=1},
      },
    },
    ["vawt-turbine-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="big-electric-pole", amount=6},
        {type="item", name="engine-unit", amount=130},
        {type="item", name="fluid-wagon", amount=2},
        {type="item", name="microchip", amount=5},
        {type="item", name="moondrop-mk02", amount=24},
        {type="item", name="nacelle-mk01", amount=1},
        {type="item", name="organic-acid-anhydride-barrel", amount=69},
        {type="item", name="phosphate-mine", amount=3},
        {type="item", name="sb-pulp-01-barrel", amount=63},
        {type="item", name="stator", amount=3},
        {type="item", name="tower-mk02", amount=1},
        {type="item", name="vinyl-acetate-barrel", amount=12},
      },
      results = {
        {type="item", name="vawt-turbine-mk02", amount=1},
      },
    },
    ["hawt-turbine-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="aerial-base", amount=2},
        {type="item", name="anemometer-mk02", amount=22},
        {type="item", name="arthropod-blood-barrel", amount=42},
        {type="item", name="controler-mk02", amount=6},
        {type="item", name="earth-jute-sample", amount=3},
        {type="item", name="gearbox-mk02", amount=2},
        {type="item", name="kevlar-coating", amount=7},
        {type="item", name="mechanical-parts-01", amount=3},
        {type="item", name="utility-box-mk01", amount=3},
        {type="item", name="yaw-drive-mk01", amount=3},
        {type="item", name="yaw-drive-mk02", amount=6},
      },
      results = {
        {type="item", name="hawt-turbine-mk02", amount=4},
      },
    },
    ["steam-turbine-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="accumulator", amount=6},
        {type="item", name="advanced-circuit", amount=81},
        {type="item", name="anemometer-mk02", amount=19},
        {type="item", name="antimony-drill-mk01", amount=1},
        {type="item", name="bio-scafold", amount=3},
        {type="item", name="carbon-sulfide-barrel", amount=157},
        {type="item", name="cargo-wagon", amount=10},
        {type="item", name="copper-coating", amount=443},
        {type="item", name="electric-engine-unit", amount=6},
        {type="item", name="engine-unit", amount=7},
        {type="item", name="intermetallics", amount=601},
        {type="item", name="latex", amount=23},
        {type="item", name="methanal-barrel", amount=163},
        {type="item", name="neuroprocessor", amount=43},
        {type="item", name="py-biomass-powerplant-mk01", amount=4},
        {type="item", name="sb-pulp-01-barrel", amount=81},
        {type="item", name="stainless-steel", amount=188},
        {type="item", name="utility-box-mk02", amount=4},
        {type="item", name="vawt-turbine-mk01", amount=1},
      },
      results = {
        {type="item", name="steam-turbine-mk02", amount=1},
      },
    },
    ["jig-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="agitator-mk01", amount=1},
        {type="item", name="blue-liquor-barrel", amount=3},
        {type="item", name="brain-cartridge-01", amount=1},
        {type="item", name="cocoon", amount=73},
        {type="item", name="engine-unit", amount=22},
        {type="item", name="fiberboard", amount=8},
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="glycerol-barrel", amount=2},
        {type="item", name="grade-3-zinc", amount=20},
        {type="item", name="green-refined-concrete", amount=139},
        {type="item", name="heat-pipe", amount=3},
        {type="item", name="inductor1", amount=263},
        {type="item", name="medium-electric-pole", amount=11},
        {type="item", name="middle-oil-canister", amount=37},
        {type="item", name="ree-slurry-barrel", amount=14},
        {type="item", name="stone-wall", amount=7},
        {type="item", name="stopper", amount=71},
        {type="item", name="vane-mk01", amount=18},
        {type="item", name="vrauks-food-01", amount=20},
        {type="item", name="warmer-stone-brick", amount=81},
      },
      results = {
        {type="item", name="jig-mk01", amount=3},
      },
    },
    ["nmf-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="agitator-mk01", amount=2},
        {type="item", name="aromatics-barrel", amount=10},
        {type="item", name="duralumin", amount=119},
        {type="item", name="electronics-factory-mk01", amount=2},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="fatty-acids-barrel", amount=5},
        {type="item", name="fluid-drill-mk01", amount=7},
        {type="item", name="inductor1", amount=1000},
        {type="item", name="micro-mine-mk01", amount=3},
        {type="item", name="molten-steel-barrel", amount=6},
        {type="item", name="niobium-pipe-to-ground", amount=5},
        {type="item", name="nxsb-alloy", amount=2},
        {type="item", name="pipe", amount=177},
        {type="item", name="small-parts-01", amount=138},
        {type="item", name="steam-engine", amount=2},
      },
      results = {
        {type="item", name="nmf-mk01", amount=4},
      },
    },
    ["py-heat-exchanger-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coalbed-mk01", amount=10},
        {type="item", name="hot-syngas-canister", amount=216},
        {type="item", name="hydrocyclone-mk01", amount=4},
        {type="item", name="mechanical-parts-01", amount=14},
        {type="item", name="ppd", amount=61},
      },
      results = {
        {type="item", name="py-heat-exchanger-mk02", amount=1},
      },
    },
    ["bio-printer-mk01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=11},
        {type="item", name="boiler", amount=15},
        {type="item", name="bonemeal", amount=21},
        {type="item", name="burner-mining-drill", amount=2},
        {type="item", name="inductor1", amount=401},
        {type="item", name="lab", amount=14},
        {type="item", name="low-grade-rejects", amount=102},
        {type="item", name="nexelit-plate", amount=20},
        {type="item", name="niobium-pipe", amount=60},
        {type="item", name="nxsb-alloy", amount=5},
        {type="item", name="pipe", amount=68},
      },
      results = {
        {type="item", name="bio-printer-mk01", amount=1},
      },
    },
    ["botanical-nursery-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="advanced-circuit", amount=5},
        {type="item", name="anthraquinone-barrel", amount=3},
        {type="item", name="crucible", amount=8},
        {type="item", name="data-array", amount=4},
        {type="item", name="electronics-mk02", amount=1},
        {type="item", name="gate", amount=2},
        {type="item", name="inductor2", amount=1},
        {type="item", name="intermetallics", amount=8},
        {type="item", name="micro-mine-mk01", amount=2},
        {type="item", name="nuclear-sample", amount=3},
        {type="item", name="optical-fiber", amount=24},
        {type="item", name="organic-solvent-barrel", amount=10},
        {type="item", name="pcb1", amount=6},
        {type="item", name="petri-dish-bacteria", amount=14},
        {type="item", name="power-switch", amount=2},
        {type="item", name="rubber", amount=10},
        {type="item", name="shaft-mk02", amount=8},
      },
      results = {
        {type="item", name="botanical-nursery-mk02", amount=3},
      },
    },
    ["spore-collector-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="condensed-distillate-barrel", amount=8},
        {type="item", name="energy-drink", amount=28},
        {type="item", name="korlex-codex-mk02", amount=16},
        {type="item", name="molten-lead-barrel", amount=17},
        {type="item", name="shaft-mk02", amount=3},
        {type="item", name="tower-mk01", amount=1},
        {type="item", name="used-auog-mk02", amount=11},
        {type="item", name="utility-box-mk02", amount=5},
      },
      results = {
        {type="item", name="spore-collector-mk02", amount=1},
      },
    },
    ["breed-fish-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.36567928956837,
      ingredients = {
        {type="fluid", name="water-saline", amount=199},
        {type="item", name="filtration-media", amount=1},
        {type="item", name="fish-egg", amount=16},
        {type="item", name="fish-food-01", amount=2},
        {type="item", name="fish-food-02", amount=1},
        {type="item", name="small-lamp", amount=5},
        {type="item", name="wood", amount=4},
      },
      results = {
        {type="fluid", name="waste-water", amount=136},
        {type="item", name="fish", amount=41},
      },
    },
    ["breed-fish-egg-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.31359991188384,
      ingredients = {
        {type="fluid", name="oxygen", amount=286},
        {type="item", name="albumin", amount=1},
        {type="item", name="gunpowder", amount=3},
        {type="item", name="stone-wool", amount=15},
        {type="item", name="zipir-codex", amount=1},
      },
      results = {
        {type="fluid", name="waste-water", amount=131},
        {type="item", name="fish-egg", amount=46},
      },
    },
    ["fish-egg-mk03-breeder"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.727750434890609,
      ingredients = {
        {type="item", name="fish-mk03", amount=4},
        {type="item", name="sweet-syrup-barrel", amount=1},
      },
      results = {
        {type="fluid", name="waste-water", amount=77},
        {type="item", name="fish-egg-mk02", amount=1},
        {type="item", name="fish-egg-mk03", amount=8},
      },
    },
    ["fish-mk03"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2.68890190749436,
      ingredients = {
        {type="fluid", name="olefin", amount=3439},
        {type="item", name="alien-sample-02", amount=2},
        {type="item", name="cytostatics", amount=1},
        {type="item", name="fish-egg-mk02", amount=105},
        {type="item", name="fish-food-02", amount=5},
        {type="item", name="retrovirus", amount=4},
        {type="item", name="sea-sponge", amount=32},
        {type="item", name="stone-wool", amount=11},
      },
      results = {
        {type="item", name="fish", amount=16},
        {type="item", name="fish-mk03", amount=0.0109819286832177},
      },
    },
    ["fish-mk03-breeder"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.92199505650828,
      ingredients = {
        {type="item", name="alien-sample-02", amount=2},
        {type="item", name="fish-egg-mk02", amount=541},
      },
      results = {
        {type="fluid", name="waste-water", amount=87},
        {type="item", name="fish-mk02", amount=1},
        {type="item", name="fish-mk03", amount=6},
      },
    },
    ["energy-drink"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="syrup-01", amount=24},
        {type="item", name="nickel-plate", amount=11},
      },
      results = {
        {type="item", name="energy-drink", amount=7},
      },
    },
    ["neuroprocessor"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="alien-sample01", amount=1},
        {type="item", name="brain", amount=4},
        {type="item", name="electronic-circuit", amount=27},
        {type="item", name="epoxy", amount=4},
        {type="item", name="fecr-alloy", amount=8},
        {type="item", name="filtration-media", amount=2},
        {type="item", name="kevlar-coating", amount=5},
        {type="item", name="pcb1", amount=2},
        {type="item", name="pcb2", amount=1},
        {type="item", name="sodium-sulfate", amount=4},
      },
      results = {
        {type="item", name="neuroprocessor", amount=3},
      },
    },
    ["nisi"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="cobalt-extract", amount=7},
        {type="item", name="silicon", amount=5},
      },
      results = {
        {type="item", name="cobalt-extract", amount=3},
        {type="item", name="nisi", amount=3},
      },
    },
    ["capacitor2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.6,
      ingredients = {
        {type="item", name="aluminium-plate", amount=7},
        {type="item", name="capacitor1", amount=2},
        {type="item", name="copper-cable", amount=84},
      },
      results = {
        {type="item", name="capacitor2", amount=3},
      },
    },
    ["microchip"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.333333333333333,
      ingredients = {
        {type="item", name="bakelite", amount=14},
        {type="item", name="plastic-bar", amount=4},
        {type="item", name="tin-plate", amount=4},
        {type="item", name="tinned-cable", amount=8},
      },
      results = {
        {type="item", name="microchip", amount=1},
      },
    },
    ["mosfet"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="fluid", name="hot-air", amount=381},
        {type="item", name="bakelite", amount=14},
        {type="item", name="cermet", amount=8},
        {type="item", name="cobalt-extract", amount=1},
        {type="item", name="green-sic", amount=2},
        {type="item", name="heavy-n", amount=6},
        {type="item", name="plastic-bar", amount=5},
        {type="item", name="ree-concentrate", amount=4},
        {type="item", name="silicon-wafer", amount=1},
        {type="item", name="tinned-cable", amount=3},
      },
      results = {
        {type="item", name="mosfet", amount=5},
      },
    },
    ["phenolicboard"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ammonia", amount=31},
        {type="fluid", name="water-saline", amount=134},
        {type="item", name="bisphenol-a", amount=4},
        {type="item", name="guar", amount=1},
        {type="item", name="silicon", amount=13},
        {type="item", name="starch", amount=1},
        {type="item", name="vacuum-tube", amount=4},
      },
      results = {
        {type="item", name="phenolicboard", amount=5},
      },
    },
    ["resistor2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="item", name="fecr-alloy", amount=3},
        {type="item", name="phenol", amount=6},
        {type="item", name="resistor1", amount=3},
        {type="item", name="silicon", amount=15},
      },
      results = {
        {type="item", name="resistor2", amount=5},
      },
    },
    ["inductor2"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.6,
      ingredients = {
        {type="item", name="inductor1", amount=5},
        {type="item", name="melamine-resin", amount=5},
        {type="item", name="molybdenum-concentrate", amount=64},
        {type="item", name="tinned-cable", amount=17},
      },
      results = {
        {type="item", name="inductor2", amount=3},
      },
    },
    ["pcb2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="etching", amount=40},
        {type="item", name="copper-low-dust", amount=1},
        {type="item", name="nylon", amount=4},
        {type="item", name="phenolicboard", amount=4},
        {type="item", name="tin-plate", amount=8},
      },
      results = {
        {type="item", name="pcb2", amount=4},
      },
    },
    ["transistor"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="cermet", amount=16},
        {type="item", name="heavy-n", amount=3},
        {type="item", name="melamine", amount=11},
        {type="item", name="nylon-parts", amount=8},
        {type="item", name="p-dope", amount=4},
      },
      results = {
        {type="item", name="transistor", amount=4},
      },
    },
    ["diode"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="item", name="cermet", amount=3},
        {type="item", name="heavy-n", amount=1},
        {type="item", name="nylon-parts", amount=28},
        {type="item", name="ree-concentrate", amount=16},
        {type="item", name="silicon-wafer", amount=3},
      },
      results = {
        {type="item", name="diode", amount=5},
      },
    },
    ["advanced-circuit"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.6,
      ingredients = {
        {type="item", name="crucible", amount=10},
        {type="item", name="inductor2", amount=2},
        {type="item", name="light-n", amount=9},
        {type="item", name="microchip", amount=2},
        {type="item", name="optical-fiber", amount=2},
        {type="item", name="pcb1", amount=21},
        {type="item", name="pcb2", amount=1},
        {type="item", name="reo", amount=3},
        {type="item", name="resistor1", amount=81},
        {type="item", name="used-nexelit-battery", amount=1},
      },
      results = {
        {type="item", name="advanced-circuit", amount=3},
      },
    },
    ["uranium-mining-drill"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anemometer-mk02", amount=3},
        {type="item", name="arithmetic-combinator", amount=5},
        {type="item", name="belt-immunity-equipment", amount=8},
        {type="item", name="burner-mining-drill", amount=39},
        {type="item", name="electronic-circuit", amount=551},
        {type="item", name="formica", amount=313},
        {type="item", name="methanol-reactor", amount=1},
        {type="item", name="raw-gas-barrel", amount=35},
        {type="item", name="rich-dust", amount=54},
        {type="item", name="rotor", amount=12},
        {type="item", name="sb-pulp-01-barrel", amount=8},
      },
      results = {
        {type="item", name="uranium-mining-drill", amount=1},
      },
    },
    ["aerial-base"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=4},
        {type="item", name="big-electric-pole", amount=4},
        {type="item", name="brake-mk02", amount=1},
        {type="item", name="electric-mining-drill", amount=20},
        {type="item", name="electronics-mk02", amount=1},
        {type="item", name="engine-unit", amount=30},
        {type="item", name="fast-splitter", amount=2},
        {type="item", name="flavonoids-barrel", amount=243},
        {type="item", name="fluid-wagon", amount=1},
        {type="item", name="microchip", amount=3},
        {type="item", name="moondrop-mk02", amount=42},
        {type="item", name="nacelle-mk01", amount=2},
        {type="item", name="organic-acid-anhydride-barrel", amount=133},
        {type="item", name="py-ze", amount=2},
        {type="item", name="sb-pulp-01-barrel", amount=113},
        {type="item", name="tower-mk02", amount=1},
        {type="item", name="vinyl-acetate-barrel", amount=9},
        {type="item", name="wet-scrubber-mk01", amount=1},
        {type="item", name="yaw-drive-mk02", amount=3},
      },
      results = {
        {type="item", name="aerial-base", amount=2},
      },
    },
    ["aerial-blimp-mk02"] = {
      mode = "input-preserved-untransformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="creamy-latex", amount=558},
        {type="item", name="atomizer-mk01", amount=4},
        {type="item", name="battery-mk01", amount=285},
        {type="item", name="earth-mouse-sample", amount=1},
        {type="item", name="gearbox-mk01", amount=1},
        {type="item", name="gearbox-mk02", amount=1},
        {type="item", name="lead-container", amount=9},
        {type="item", name="mechanical-parts-01", amount=5},
        {type="item", name="nxsb-alloy", amount=32},
        {type="item", name="py-roboport-mk01", amount=11},
        {type="item", name="py-tank-3000", amount=2},
        {type="item", name="py-tank-5000", amount=64},
        {type="item", name="utility-box-mk02", amount=2},
        {type="item", name="yaw-drive-mk02", amount=1},
        {type="item", name="zogna-bacteria-barrel", amount=14},
      },
      results = {
        {type="item", name="aerial-blimp-mk02", amount=1},
      },
    },
    ["bhoddos-culture-mk01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="navens-codex", amount=10},
      },
      results = {
        {type="item", name="bhoddos-culture-mk01", amount=1},
      },
    },
    ["cadaveric-arum-mk01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="agitator-mk01", amount=4},
        {type="item", name="electronics-factory-mk01", amount=3},
        {type="item", name="fiberboard", amount=17},
        {type="item", name="medium-electric-pole", amount=23},
        {type="item", name="nxsb-alloy", amount=15},
        {type="item", name="small-parts-01", amount=107},
      },
      results = {
        {type="item", name="cadaveric-arum-mk01", amount=4},
      },
    },
    ["grods-swamp-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=40},
        {type="item", name="big-electric-pole", amount=4},
        {type="item", name="burner-mining-drill", amount=6},
        {type="item", name="carbon-dioxide-barrel", amount=14},
        {type="item", name="concrete", amount=26},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="glass", amount=10},
        {type="item", name="inductor1", amount=188},
        {type="item", name="iron-plate", amount=26},
        {type="item", name="nexelit-plate", amount=70},
        {type="item", name="nickel-plate", amount=49},
        {type="item", name="rotor", amount=2},
        {type="item", name="stator", amount=1},
      },
      results = {
        {type="item", name="grods-swamp-mk01", amount=1},
      },
    },
    ["guar-gum-plantation"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="aromatics-barrel", amount=86},
        {type="item", name="condensates-canister", amount=16},
        {type="item", name="controler-mk01", amount=3},
        {type="item", name="fiberboard", amount=109},
        {type="item", name="incubator-mk01", amount=2},
        {type="item", name="limestone", amount=363},
        {type="item", name="mechanical-parts-01", amount=3},
        {type="item", name="medium-electric-pole", amount=58},
        {type="item", name="powdered-quartz", amount=44},
        {type="item", name="py-gas-vent", amount=6},
        {type="item", name="py-tank-7000", amount=5},
        {type="item", name="residual-oil-barrel", amount=17},
      },
      results = {
        {type="item", name="guar-gum-plantation", amount=4},
      },
    },
    ["navens-culture-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="duralumin", amount=27},
        {type="item", name="engine-unit", amount=102},
        {type="item", name="evaporator", amount=1},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="iron-plate", amount=105},
        {type="item", name="molten-nickel-barrel", amount=10},
        {type="item", name="nickel-plate", amount=84},
        {type="item", name="transport-belt", amount=43},
      },
      results = {
        {type="item", name="navens-culture-mk01", amount=1},
      },
    },
    ["ralesia-plantation-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="caged-vrauks", amount=13},
        {type="item", name="chitin", amount=36},
        {type="item", name="crude-oil-canister", amount=6},
        {type="item", name="depolymerized-organics-barrel", amount=7},
        {type="item", name="flamethrower-turret", amount=20},
        {type="item", name="grenade", amount=148},
        {type="item", name="korlex-codex-mk02", amount=16},
        {type="item", name="organic-acid-anhydride-barrel", amount=25},
        {type="item", name="portable-gasoline-generator", amount=1},
        {type="item", name="residual-oil-barrel", amount=17},
        {type="item", name="selector-combinator", amount=2},
        {type="item", name="shaft-mk02", amount=2},
        {type="item", name="ti-pulp-03-barrel", amount=175},
        {type="item", name="trits-reef-mk01", amount=1},
        {type="item", name="u-pulp-02-barrel", amount=9},
      },
      results = {
        {type="item", name="ralesia-plantation-mk02", amount=2},
      },
    },
    ["rennea-plantation-mk01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boiler", amount=3},
        {type="item", name="chromium", amount=147},
        {type="item", name="duralumin", amount=31},
        {type="item", name="inductor1", amount=21},
        {type="item", name="iron-chest", amount=8},
        {type="item", name="low-grade-rejects", amount=21},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="middle-oil-canister", amount=4},
        {type="item", name="pump", amount=7},
        {type="item", name="pure-sand", amount=418},
        {type="item", name="py-steel", amount=29},
        {type="item", name="small-parts-01", amount=221},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="titanium-plate", amount=91},
      },
      results = {
        {type="item", name="rennea-plantation-mk01", amount=1},
      },
    },
    ["yotoi-aloe-orchard-mk01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="acetylene-barrel", amount=15},
        {type="item", name="aluminium-plate", amount=8},
        {type="item", name="electronic-circuit", amount=4},
        {type="item", name="engine-unit", amount=6},
        {type="item", name="inductor1", amount=183},
        {type="item", name="intermetallics", amount=7},
        {type="item", name="lab", amount=1},
        {type="item", name="nexelit-plate", amount=48},
        {type="item", name="refined-natural-gas-barrel", amount=36},
        {type="item", name="steel-chest", amount=4},
        {type="item", name="storage-tank", amount=3},
        {type="item", name="titanium-plate", amount=42},
      },
      results = {
        {type="item", name="yotoi-aloe-orchard-mk01", amount=2},
      },
    },
    ["sponge-culture-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="chitin", amount=46},
        {type="item", name="depolymerized-organics-barrel", amount=22},
        {type="item", name="electronic-circuit", amount=48},
        {type="item", name="flamethrower-turret", amount=26},
        {type="item", name="flutec-pp6-barrel", amount=31},
        {type="item", name="navens-codex", amount=2},
        {type="item", name="organic-solvent-barrel", amount=68},
        {type="item", name="ptcda", amount=59},
        {type="item", name="residual-oil-barrel", amount=173},
        {type="item", name="selector-combinator", amount=3},
        {type="item", name="shaft-mk02", amount=15},
      },
      results = {
        {type="item", name="sponge-culture-mk02", amount=3},
      },
    },
    ["cadaveric-arum-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="blade-mk01", amount=303},
        {type="item", name="chipshooter-mk01", amount=10},
        {type="item", name="constant-combinator", amount=3},
        {type="item", name="crude-oil-barrel", amount=37},
        {type="item", name="engine-unit", amount=13},
        {type="item", name="fast-inserter", amount=2},
        {type="item", name="fish-hydrolysate-barrel", amount=110},
        {type="item", name="flotation-cell-mk01", amount=1},
        {type="item", name="lor-mk01", amount=2},
        {type="item", name="molten-solder-barrel", amount=10},
        {type="item", name="organic-acid-anhydride-barrel", amount=6},
        {type="item", name="py-logo-15tiles", amount=3},
      },
      results = {
        {type="item", name="cadaveric-arum-mk02", amount=2},
      },
    },
    ["grods-swamp-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="auog-paddock-mk01", amount=3},
        {type="item", name="botanical-nursery", amount=25},
        {type="item", name="duralumin", amount=47},
        {type="item", name="electronics-mk02", amount=4},
        {type="item", name="fuel-oil-canister", amount=256},
        {type="item", name="outlet-gas-01-canister", amount=49},
        {type="item", name="py-science-pack-2", amount=3},
        {type="item", name="rennea-plantation-mk01", amount=1},
        {type="item", name="sap-tree-mk02", amount=6},
        {type="item", name="self-assembly-monolayer", amount=5},
        {type="item", name="shaft-mk02", amount=1},
        {type="item", name="steam-engine", amount=58},
      },
      results = {
        {type="item", name="grods-swamp-mk02", amount=2},
      },
    },
    ["guar-gum-plantation-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="accumulator", amount=7},
        {type="item", name="cadaveric-arum-mk01", amount=1},
        {type="item", name="casting-unit-mk01", amount=3},
        {type="item", name="diesel-barrel", amount=58},
        {type="item", name="dowfroth-250-barrel", amount=14},
        {type="item", name="generator-1", amount=6},
        {type="item", name="jaw-crusher", amount=3},
        {type="item", name="korlex-codex-mk02", amount=10},
        {type="item", name="mechanical-parts-01", amount=9},
        {type="item", name="organic-acid-anhydride-barrel", amount=3},
        {type="item", name="py-coal-tile", amount=77},
        {type="item", name="resistor1", amount=426},
        {type="item", name="sweet-syrup-barrel", amount=95},
      },
      results = {
        {type="item", name="guar-gum-plantation-mk02", amount=2},
      },
    },
    ["kicalk-plantation-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="artificial-blood-barrel", amount=1},
        {type="item", name="battery-mk00", amount=356},
        {type="item", name="chitin", amount=17},
        {type="item", name="fast-underground-belt", amount=3},
        {type="item", name="intermetallics", amount=42},
        {type="item", name="py-tank-1000", amount=7},
      },
      results = {
        {type="item", name="kicalk-plantation-mk02", amount=1},
      },
    },
    ["moondrop-greenhouse-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="arithmetic-combinator", amount=13},
        {type="item", name="carbon-sulfide-barrel", amount=8},
        {type="item", name="crucible", amount=6},
        {type="item", name="electronic-circuit", amount=170},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="ethylene-glycol-barrel", amount=10},
        {type="item", name="fish-food-02", amount=2},
        {type="item", name="inductor2", amount=1},
        {type="item", name="pcb1", amount=5},
        {type="item", name="sb-pulp-01-barrel", amount=7},
      },
      results = {
        {type="item", name="moondrop-greenhouse-mk02", amount=1},
      },
    },
    ["moss-farm-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="defender-capsule", amount=5},
        {type="item", name="depleted-uranium-fuel-cell", amount=5},
        {type="item", name="distilator", amount=8},
        {type="item", name="electric-mining-drill", amount=3},
        {type="item", name="fawogae-plantation-mk01", amount=10},
        {type="item", name="fuel-oil-barrel", amount=119},
        {type="item", name="fuel-oil-canister", amount=21},
        {type="item", name="grenade", amount=6},
        {type="item", name="intermetallics", amount=18},
        {type="item", name="latex", amount=14},
        {type="item", name="low-grade-copper", amount=141},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="moss-farm-mk01", amount=3},
        {type="item", name="niobium-pipe-to-ground", amount=17},
        {type="item", name="organic-acid-anhydride-barrel", amount=3},
        {type="item", name="sap-tree", amount=21},
        {type="item", name="shaft-mk02", amount=2},
        {type="item", name="storage-tank", amount=2},
        {type="item", name="ti-pulp-03-barrel", amount=18},
        {type="item", name="utility-box-mk02", amount=3},
      },
      results = {
        {type="item", name="moss-farm-mk02", amount=2},
      },
    },
    ["navens-culture-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="belt-immunity-equipment", amount=1},
        {type="item", name="brain-cartridge-01", amount=33},
        {type="item", name="chitin", amount=11},
        {type="item", name="depleted-uranium-fuel-cell", amount=9},
        {type="item", name="electric-engine-unit", amount=1},
        {type="item", name="flavonoids-barrel", amount=9},
        {type="item", name="power-switch", amount=1},
        {type="item", name="rotor", amount=4},
        {type="item", name="shaft-mk02", amount=4},
        {type="item", name="utility-box-mk02", amount=2},
        {type="item", name="zogna-bacteria-barrel", amount=13},
      },
      results = {
        {type="item", name="navens-culture-mk02", amount=1},
      },
    },
    ["rennea-plantation-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="arqad-hive-mk01", amount=1},
        {type="item", name="auog-paddock-mk01", amount=2},
        {type="item", name="empty-petri-dish", amount=112},
        {type="item", name="eva", amount=79},
        {type="item", name="heat-pipe", amount=3},
        {type="item", name="lab-instrument", amount=17},
        {type="item", name="naphthalene-oil-barrel", amount=52},
        {type="item", name="polybutadiene-barrel", amount=92},
        {type="item", name="portable-gasoline-generator", amount=5},
        {type="item", name="shaft-mk02", amount=9},
        {type="item", name="uranium-fuel-cell", amount=18},
      },
      results = {
        {type="item", name="rennea-plantation-mk02", amount=1},
      },
    },
    ["sap-extractor-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="botanical-nursery", amount=1},
        {type="item", name="crmoni", amount=1},
        {type="item", name="duralumin", amount=6},
        {type="item", name="electric-engine-unit", amount=1},
        {type="item", name="fenxsb-alloy", amount=24},
        {type="item", name="kevlar", amount=7},
        {type="item", name="long-handed-inserter", amount=12},
        {type="item", name="molten-tin-barrel", amount=38},
        {type="item", name="pipe", amount=122},
        {type="item", name="requester-chest", amount=77},
        {type="item", name="storage-tank", amount=1},
      },
      results = {
        {type="item", name="sap-extractor-mk02", amount=1},
      },
    },
    ["seaweed-crop-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="belt-immunity-equipment", amount=1},
        {type="item", name="crmoni", amount=3},
        {type="item", name="distilator", amount=1},
        {type="item", name="electric-engine-unit", amount=1},
        {type="item", name="ethylene-glycol-barrel", amount=10},
        {type="item", name="fenxsb-alloy", amount=47},
        {type="item", name="flavonoids-barrel", amount=4},
        {type="item", name="kevlar", amount=13},
        {type="item", name="lab-instrument", amount=94},
        {type="item", name="long-handed-inserter", amount=3},
        {type="item", name="medium-electric-pole", amount=36},
        {type="item", name="molten-tin-barrel", amount=9},
        {type="item", name="requester-chest", amount=148},
        {type="item", name="sap-extractor-mk01", amount=18},
      },
      results = {
        {type="item", name="seaweed-crop-mk02", amount=2},
      },
    },
    ["tuuphra-plantation-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="arqad-hive-mk01", amount=1},
        {type="item", name="blade-mk01", amount=267},
        {type="item", name="btx-canister", amount=94},
        {type="item", name="constant-combinator", amount=6},
        {type="item", name="fast-inserter", amount=4},
        {type="item", name="korlex-codex-mk02", amount=1},
        {type="item", name="lor-mk01", amount=6},
        {type="item", name="molten-solder-barrel", amount=22},
        {type="item", name="organic-acid-anhydride-barrel", amount=43},
      },
      results = {
        {type="item", name="tuuphra-plantation-mk02", amount=1},
      },
    },
    ["bhoddos-culture-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="animal-sample-01", amount=85},
        {type="item", name="fts-reactor", amount=17},
        {type="item", name="kicalk-plantation-mk01", amount=11},
        {type="item", name="mechanical-parts-01", amount=24},
        {type="item", name="navens-codex", amount=14},
        {type="item", name="nuclear-reactor", amount=2},
        {type="item", name="reformer-mk01", amount=8},
      },
      results = {
        {type="item", name="bhoddos-culture-mk02", amount=3},
      },
    },
    ["fawogae-plantation-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-paddock-mk01", amount=2},
        {type="item", name="battery-mk00", amount=8},
        {type="item", name="fast-splitter", amount=6},
        {type="item", name="portable-gasoline-generator", amount=1},
        {type="item", name="shaft-mk02", amount=3},
      },
      results = {
        {type="item", name="fawogae-plantation-mk02", amount=1},
      },
    },
    ["fwf-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="botanical-nursery", amount=1},
        {type="item", name="defender-capsule", amount=3},
        {type="item", name="depleted-uranium-fuel-cell", amount=10},
        {type="item", name="fuel-oil-barrel", amount=30},
        {type="item", name="latex", amount=29},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="moss-farm-mk01", amount=1},
        {type="item", name="sap-tree", amount=42},
        {type="item", name="shaft-mk02", amount=4},
      },
      results = {
        {type="item", name="fwf-mk02", amount=1},
      },
    },
    ["bulk-inserter"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="burner-inserter", amount=29},
        {type="item", name="gearbox-mk01", amount=1},
        {type="item", name="mechanical-parts-01", amount=3},
        {type="item", name="titanium-plate", amount=37},
        {type="item", name="vitreloy", amount=4},
      },
      results = {
        {type="item", name="bulk-inserter", amount=2},
      },
    },
    ["assembling-machine-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="phosphoric-acid-barrel", amount=8},
        {type="item", name="py-stack-inserter", amount=4},
        {type="item", name="speed-module", amount=1},
        {type="item", name="steam-engine", amount=12},
      },
      results = {
        {type="item", name="assembling-machine-3", amount=1},
      },
    },
    ["chemical-science-pack"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="item", name="advanced-circuit", amount=3},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="epoxy", amount=1},
        {type="item", name="intermetallics", amount=16},
        {type="item", name="lead-plate", amount=27},
        {type="item", name="nuclear-sample", amount=1},
        {type="item", name="optical-fiber", amount=14},
        {type="item", name="rubber", amount=18},
        {type="item", name="self-assembly-monolayer", amount=3},
        {type="item", name="shaft-mk02", amount=2},
      },
      results = {
        {type="item", name="chemical-science-pack", amount=16},
      },
    },
    ["electric-furnace"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="electronics-mk02", amount=1},
        {type="item", name="molten-nickel-barrel", amount=25},
      },
      results = {
        {type="item", name="electric-furnace", amount=1},
      },
    },
    ["megadar"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="neuroprocessor", amount=24},
        {type="item", name="stator", amount=5},
      },
      results = {
        {type="item", name="megadar", amount=1},
      },
    },
    ["modular-armor"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anemometer-mk02", amount=2},
        {type="item", name="bio-oil-barrel", amount=400},
        {type="item", name="controler-mk02", amount=4},
        {type="item", name="efficiency-module", amount=1},
        {type="item", name="electronics-mk02", amount=3},
        {type="item", name="engine-unit", amount=95},
        {type="item", name="fast-transport-belt", amount=21},
        {type="item", name="fatty-acids-barrel", amount=14},
        {type="item", name="mechanical-parts-01", amount=15},
        {type="item", name="neuroprocessor", amount=53},
        {type="item", name="py-oil-powerplant-mk01", amount=1},
        {type="item", name="rotor-mk02", amount=3},
        {type="item", name="yotoi-aloe-orchard-mk01", amount=1},
      },
      results = {
        {type="item", name="modular-armor", amount=1},
      },
    },
    ["particle-accelerator-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="arqad-honey-barrel", amount=34},
        {type="item", name="artificial-blood-barrel", amount=4},
        {type="item", name="battery-mk00", amount=394},
        {type="item", name="chitin", amount=47},
        {type="item", name="fast-underground-belt", amount=1},
        {type="item", name="intermetallics", amount=46},
        {type="item", name="mechanical-parts-01", amount=76},
        {type="item", name="melamine", amount=1000},
        {type="item", name="rotor", amount=13},
        {type="item", name="steam-engine", amount=33},
        {type="item", name="thickener-mk01", amount=1},
      },
      results = {
        {type="item", name="particle-accelerator-mk01", amount=2},
      },
    },
    ["yaedols-culture-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="arqad-hive-mk01", amount=2},
        {type="item", name="chipshooter-mk01", amount=1},
        {type="item", name="condensed-distillate-barrel", amount=10},
        {type="item", name="electronic-circuit", amount=1000},
        {type="item", name="energy-drink", amount=92},
        {type="item", name="engine-unit", amount=4},
        {type="item", name="flutec-pp6-barrel", amount=92},
        {type="item", name="heavy-n", amount=17},
        {type="item", name="korlex-codex-mk02", amount=21},
        {type="item", name="molten-lead-barrel", amount=22},
        {type="item", name="moondrop-mk02", amount=28},
        {type="item", name="shaft-mk02", amount=4},
        {type="item", name="tower-mk01", amount=3},
        {type="item", name="used-auog-mk02", amount=14},
      },
      results = {
        {type="item", name="yaedols-culture-mk02", amount=1},
      },
    },
    ["yotoi-aloe-orchard-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-paddock-mk01", amount=3},
        {type="item", name="electronics-mk02", amount=4},
        {type="item", name="fuel-oil-canister", amount=94},
        {type="item", name="methane-canister", amount=20},
        {type="item", name="py-science-pack-2", amount=9},
        {type="item", name="sap-tree-mk02", amount=6},
        {type="item", name="vpulp2-barrel", amount=2},
      },
      results = {
        {type="item", name="yotoi-aloe-orchard-mk02", amount=1},
      },
    },
    ["kicalk-seeds-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="kicalk", amount=153},
        {type="item", name="kicalk-seeds-mk02", amount=1},
      },
      results = {
        {type="item", name="kicalk-seeds-mk02", amount=6},
      },
    },
    ["yotoi-fiber"] = {
      mode = "input-preserved-untransformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="yotoi-fruit", amount=4},
      },
      results = {
        {type="item", name="raw-fiber", amount=3},
      },
    },
    ["bedding"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="grod", amount=1},
        {type="item", name="log", amount=1},
        {type="item", name="raw-fiber", amount=5},
        {type="item", name="yotoi-fruit", amount=8},
      },
      results = {
        {type="item", name="bedding", amount=3},
      },
    },
    ["cu-biomass-extraction"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.35145261152407,
      ingredients = {
        {type="item", name="auog-food-01", amount=2},
        {type="item", name="cu-biomass", amount=10},
        {type="item", name="ralesia", amount=2},
        {type="item", name="subcritical-water-barrel", amount=3},
      },
      results = {
        {type="item", name="biomass", amount=7},
        {type="item", name="copper-ore", amount=27},
      },
    },
    ["fe-biomass-extraction"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.751452611524068,
      ingredients = {
        {type="item", name="fe-biomass", amount=8},
      },
      results = {
        {type="item", name="biomass", amount=4},
        {type="item", name="iron-ore", amount=15},
      },
    },
    ["fungal-substrate-03"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.3,
      ingredients = {
        {type="fluid", name="water-saline", amount=548},
        {type="item", name="agar", amount=1},
        {type="item", name="fiber", amount=2},
        {type="item", name="flask", amount=1},
        {type="item", name="mukmoux-fat", amount=3},
        {type="item", name="sand", amount=22},
        {type="item", name="tuuphra-seeds", amount=24},
      },
      results = {
        {type="item", name="fungal-substrate-03", amount=13},
      },
    },
    ["nacl-biomass-extraction"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.967318585015853,
      ingredients = {
        {type="item", name="nacl-biomass", amount=14},
      },
      results = {
        {type="item", name="biomass", amount=5},
        {type="item", name="salt", amount=29},
      },
    },
    ["psc"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.9,
      ingredients = {
        {type="fluid", name="xenogenic-cells", amount=63},
        {type="item", name="retrovirus", amount=1},
        {type="item", name="sugar", amount=3},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=45},
        {type="fluid", name="psc", amount=45},
      },
    },
    ["s-biomass-extraction"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="s-biomass", amount=10},
      },
      results = {
        {type="item", name="biomass", amount=5},
        {type="item", name="sulfur", amount=10},
      },
    },
    ["sn-biomass-extraction"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="item", name="fe-biomass", amount=8},
        {type="item", name="sn-biomass", amount=10},
      },
      results = {
        {type="item", name="biomass", amount=8},
        {type="item", name="ore-tin", amount=24},
      },
    },
    ["sodium-carbonate-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.00049033468752,
      ingredients = {
        {type="item", name="coke", amount=4},
        {type="item", name="sodium-bisulfate", amount=1},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=53},
        {type="item", name="sodium-carbonate", amount=1},
      },
    },
    ["sporopollenin"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="item", name="rennea", amount=8},
        {type="item", name="rennea-seeds", amount=10},
      },
      results = {
        {type="item", name="sporopollenin", amount=8},
      },
    },
    ["vinyl-acetate"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.960290862938007,
      ingredients = {
        {type="fluid", name="processed-fatty-acids", amount=97},
        {type="item", name="chromium", amount=2},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=48},
        {type="fluid", name="tailings", amount=97},
        {type="fluid", name="vinyl-acetate", amount=48},
      },
    },
    ["lignin"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="cellulose", amount=3},
        {type="item", name="dried-biomass", amount=66},
        {type="item", name="gunpowder", amount=1},
      },
      results = {
        {type="item", name="lignin", amount=12},
      },
    },
    ["seeds-extract-01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="tar", amount=415},
        {type="item", name="grod-seeds", amount=8},
        {type="item", name="guar", amount=23},
        {type="item", name="methanal-barrel", amount=1},
        {type="item", name="rennea", amount=3},
        {type="item", name="rennea-seeds", amount=4},
      },
      results = {
        {type="item", name="seeds-extract-01", amount=5},
      },
    },
    ["yotoi-cellulose"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="lubricant", amount=39},
        {type="item", name="ash", amount=5},
        {type="item", name="crude-cermet", amount=1},
        {type="item", name="salt", amount=7},
        {type="item", name="yotoi-fruit", amount=8},
      },
      results = {
        {type="item", name="cellulose", amount=4},
      },
    },
    ["ulric-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.51099870917305,
      ingredients = {
        {type="item", name="bedding", amount=1},
        {type="item", name="caged-ulric", amount=2},
        {type="item", name="dried-meat", amount=2},
        {type="item", name="refined-natural-gas-barrel", amount=3},
        {type="item", name="sodium-hydroxide", amount=4},
        {type="item", name="ulric-food-01", amount=3},
      },
      results = {
        {type="item", name="barrel", amount=8},
        {type="item", name="ulric", amount=9},
      },
    },
    ["ulric-cub-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.818262200864419,
      ingredients = {
        {type="item", name="bedding", amount=1},
        {type="item", name="fertilizer", amount=2},
        {type="item", name="refined-natural-gas-barrel", amount=8},
        {type="item", name="ulric-food-01", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=12},
        {type="item", name="ulric-cub", amount=5},
      },
    },
    ["ulric-manure-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="albumin", amount=1},
        {type="item", name="ralesia", amount=33},
        {type="item", name="refined-natural-gas-barrel", amount=10},
        {type="item", name="sodium-hydroxide", amount=7},
        {type="item", name="ulric-food-01", amount=4},
      },
      results = {
        {type="item", name="barrel", amount=15},
        {type="item", name="manure", amount=18},
      },
    },
    ["ulric-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 3.00538176598541,
      ingredients = {
        {type="item", name="bedding", amount=7},
        {type="item", name="bhoddos", amount=1},
        {type="item", name="cottongut-food-01", amount=7},
        {type="item", name="kicalk", amount=3},
        {type="item", name="petroleum-gas-canister", amount=2},
        {type="item", name="ralesia", amount=2},
        {type="item", name="raw-fiber", amount=3},
        {type="item", name="refined-natural-gas-barrel", amount=7},
        {type="item", name="salt", amount=9},
        {type="item", name="ulric", amount=3},
        {type="item", name="ulric-food-01", amount=4},
        {type="item", name="vrauks-food-02", amount=3},
        {type="item", name="water-barrel", amount=3},
      },
      results = {
        {type="item", name="barrel", amount=21},
        {type="item", name="ulric", amount=1},
        {type="item", name="ulric-mk02", amount=0.0150893949164211},
      },
    },
    ["ulric-mk02-dna-sample"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="carbon-dioxide-barrel", amount=5},
        {type="item", name="stone-furnace", amount=20},
        {type="item", name="ulric", amount=96},
      },
      results = {
        {type="item", name="ulric-mk02-dna-sample", amount=1},
        {type="item", name="used-ulric-mk02", amount=1},
      },
    },
    ["ulric-mk02-dna-sample-02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="caged-ulric", amount=31},
        {type="item", name="latex-slab", amount=2},
      },
      results = {
        {type="item", name="ulric-mk02-dna-sample", amount=6},
        {type="item", name="used-ulric-mk02", amount=1},
      },
    },
    ["ulric-mk02-breeding"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.186995138915886,
      ingredients = {
        {type="item", name="bedding", amount=4},
        {type="item", name="caged-ulric", amount=1},
        {type="item", name="carbon-dioxide-barrel", amount=3},
        {type="item", name="ulric-food-01", amount=4},
        {type="item", name="ulric-mk02-dna-sample", amount=5},
        {type="item", name="yaedols", amount=12},
      },
      results = {
        {type="item", name="barrel", amount=1},
        {type="item", name="ulric-cub-mk02", amount=0.187419784758919},
        {type="item", name="used-ulric-mk02", amount=0.187419784758919},
      },
    },
    ["ulric-recharge-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bedding", amount=2},
        {type="item", name="used-auog", amount=80},
        {type="item", name="used-ulric-mk02", amount=1},
      },
      results = {
        {type="item", name="ulric-mk02", amount=2},
      },
    },
    ["ulric-mk02-raising"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-food-02", amount=2},
        {type="item", name="barrel-milk", amount=2},
        {type="item", name="ulric-cub-mk02", amount=4},
      },
      results = {
        {type="item", name="empty-barrel-milk", amount=2},
        {type="item", name="ulric-mk02", amount=1},
      },
    },
    ["compile-korlex-codex"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="burner-inserter", amount=7},
        {type="item", name="latex", amount=43},
        {type="item", name="ulric-codex", amount=2},
        {type="item", name="vitreloy", amount=3},
      },
      results = {
        {type="item", name="korlex-codex-mk02", amount=3},
      },
    },
    ["korlex-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="bhoddos", amount=1},
        {type="item", name="fertilizer", amount=11},
        {type="item", name="korlex-pup", amount=2},
        {type="item", name="lignin", amount=10},
        {type="item", name="phenolicboard", amount=1},
        {type="item", name="pressured-water-barrel", amount=4},
        {type="item", name="sand", amount=9},
        {type="item", name="seaweed", amount=39},
      },
      results = {
        {type="item", name="barrel", amount=4},
        {type="item", name="korlex", amount=2},
      },
    },
    ["korlex-milk-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.65631066963562,
      ingredients = {
        {type="fluid", name="water-saline", amount=1052},
        {type="item", name="agar", amount=1},
        {type="item", name="arqad-honey-barrel", amount=2},
        {type="item", name="bhoddos", amount=2},
        {type="item", name="fiber", amount=4},
        {type="item", name="fish", amount=5},
        {type="item", name="flask", amount=1},
        {type="item", name="korlex-food-01", amount=1},
        {type="item", name="mukmoux-fat", amount=6},
        {type="item", name="powdered-biomass", amount=45},
        {type="item", name="sic", amount=3},
        {type="item", name="stone-wool", amount=1},
        {type="item", name="tuuphra", amount=3},
        {type="item", name="tuuphra-seeds", amount=5},
      },
      results = {
        {type="item", name="barrel", amount=16},
        {type="item", name="barrel-milk", amount=10},
      },
    },
    ["korlex-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.17996180277363,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=267},
        {type="item", name="bedding", amount=2},
        {type="item", name="dried-meat", amount=7},
        {type="item", name="filtration-media", amount=1},
        {type="item", name="fish-food-01", amount=1},
        {type="item", name="korlex", amount=1},
        {type="item", name="korlex-food-01", amount=2},
        {type="item", name="refined-natural-gas-barrel", amount=2},
        {type="item", name="rennea-seeds", amount=17},
        {type="item", name="saps", amount=8},
        {type="item", name="wood-fence", amount=7},
      },
      results = {
        {type="item", name="barrel", amount=7},
        {type="item", name="korlex", amount=1},
        {type="item", name="korlex-mk02", amount=0.0059372741687381},
      },
    },
    ["korlex-pup-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bedding", amount=1},
        {type="item", name="fish-hydrolysate-barrel", amount=12},
        {type="item", name="iron-oxide", amount=6},
        {type="item", name="korlex-food-01", amount=2},
        {type="item", name="refined-natural-gas-barrel", amount=10},
        {type="item", name="tuuphra", amount=3},
      },
      results = {
        {type="item", name="barrel", amount=25},
        {type="item", name="korlex-pup", amount=6},
      },
    },
    ["korlex-mk02r"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="alien-sample-02", amount=1},
        {type="item", name="chitin", amount=87},
        {type="item", name="cladded-core", amount=2},
        {type="item", name="korlex-mk02", amount=8},
        {type="item", name="utility-box-mk01", amount=4},
      },
      results = {
        {type="item", name="korlex-mk02", amount=9},
      },
    },
    ["sap-seeds-mk03-gen"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="kicalk", amount=3},
        {type="item", name="sap-tree", amount=9},
        {type="item", name="sodium-alginate", amount=1},
      },
      results = {
        {type="item", name="sap-seeds-mk03", amount=1},
      },
    },
    ["sap-seeds-mk03"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="oxygen", amount=60},
        {type="item", name="chromium", amount=1},
        {type="item", name="saps-mk03", amount=6},
      },
      results = {
        {type="item", name="sap-seeds-mk03", amount=3},
      },
    },
    ["sap-tree-mk03-gen"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="hydrogen", amount=625},
        {type="fluid", name="steam", amount=383},
        {type="item", name="brain", amount=5},
        {type="item", name="raw-fiber", amount=7},
        {type="item", name="saps-mk03", amount=14},
      },
      results = {
        {type="item", name="sap-tree-mk03", amount=2},
      },
    },
    ["xyhiphoe-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.63918672221313,
      ingredients = {
        {type="fluid", name="pressured-water", amount=3738},
        {type="fluid", name="sulfuric-acid", amount=205},
        {type="item", name="albumin", amount=11},
        {type="item", name="filtration-media", amount=4},
        {type="item", name="fishmeal", amount=3},
        {type="item", name="poorman-wood-fence", amount=3},
        {type="item", name="xyhiphoe-cub", amount=2},
      },
      results = {
        {type="fluid", name="waste-water", amount=310},
        {type="item", name="xyhiphoe", amount=2},
      },
    },
    ["xyhiphoe-cub-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.738221836278873,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=63},
        {type="fluid", name="water", amount=1360},
        {type="item", name="dried-meat", amount=2},
        {type="item", name="filtration-media", amount=2},
        {type="item", name="fish-food-01", amount=2},
        {type="item", name="saps", amount=5},
        {type="item", name="wood-fence", amount=13},
      },
      results = {
        {type="fluid", name="waste-water", amount=503},
        {type="item", name="xyhiphoe-cub", amount=5},
      },
    },
    ["xyhiphoe-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.674821854943756,
      ingredients = {
        {type="fluid", name="tar", amount=204},
        {type="item", name="albumin", amount=3},
        {type="item", name="filtration-media", amount=1},
        {type="item", name="fish-food-02", amount=2},
        {type="item", name="nylon-parts", amount=3},
        {type="item", name="xyhiphoe", amount=2},
      },
      results = {
        {type="item", name="xyhiphoe", amount=1},
        {type="item", name="xyhiphoe-mk02", amount=0.00337410927471878},
      },
    },
    ["xyhiphoe-pool-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="arithmetic-combinator", amount=1},
        {type="item", name="arqad-hive-mk01", amount=2},
        {type="item", name="brain-cartridge-01", amount=12},
        {type="item", name="chitin", amount=34},
        {type="item", name="constant-combinator", amount=3},
        {type="item", name="depleted-uranium-fuel-cell", amount=3},
        {type="item", name="electric-engine-unit", amount=1},
        {type="item", name="electronic-circuit", amount=107},
        {type="item", name="electronics-mk02", amount=3},
        {type="item", name="engine-unit", amount=6},
        {type="item", name="mechanical-parts-02", amount=4},
        {type="item", name="mibc-barrel", amount=111},
        {type="item", name="organic-acid-anhydride-barrel", amount=36},
        {type="item", name="retorter", amount=2},
        {type="item", name="sb-pulp-01-barrel", amount=9},
        {type="item", name="scrude-barrel", amount=357},
        {type="item", name="shaft-mk02", amount=2},
        {type="item", name="titanium-plate", amount=130},
        {type="item", name="utility-box-mk02", amount=3},
        {type="item", name="zogna-bacteria-barrel", amount=39},
      },
      results = {
        {type="item", name="xyhiphoe-pool-mk02", amount=2},
      },
    },
    ["xyhiphoe-cub-mk02-breeder"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.442329042758564,
      ingredients = {
        {type="item", name="albumin", amount=3},
        {type="item", name="fish-egg-mk02", amount=2},
        {type="item", name="tailings-pond", amount=1},
        {type="item", name="xyhiphoe", amount=9},
      },
      results = {
        {type="item", name="xyhiphoe-cub", amount=1},
        {type="item", name="xyhiphoe-cub-mk02", amount=1},
      },
    },
    ["xyhiphoe-mk02-breeder"] = {
      mode = "repaired-to-input",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="fetal-serum", amount=50},
        {type="item", name="xyhiphoe-cub-mk02", amount=2},
      },
      results = {
        {type="item", name="xyhiphoe", amount=1},
        {type="item", name="xyhiphoe-mk02", amount=1},
      },
    },
    ["bhoddos-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 5.4,
      ingredients = {
        {type="item", name="biomass", amount=34},
        {type="item", name="dried-meat", amount=1},
        {type="item", name="naphthalene-oil-canister", amount=5},
        {type="item", name="yaedols", amount=4},
      },
      results = {
        {type="item", name="bhoddos", amount=27},
      },
    },
    ["bhoddos-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="steam", amount=646},
        {type="item", name="alien-sample-02", amount=2},
        {type="item", name="aluminium-plate", amount=78},
        {type="item", name="cytostatics", amount=4},
        {type="item", name="earth-sunflower-sample", amount=1},
        {type="item", name="moondrop-seeds", amount=37},
        {type="item", name="retrovirus", amount=6},
        {type="item", name="xyhiphoe-codex", amount=2},
        {type="item", name="yaedols-spores", amount=97},
      },
      results = {
        {type="item", name="bhoddos", amount=2},
      },
    },
    ["fish-food-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.6,
      ingredients = {
        {type="item", name="albumin", amount=4},
        {type="item", name="casein", amount=1},
        {type="item", name="chromium", amount=8},
        {type="item", name="filtration-media", amount=1},
        {type="item", name="guts", amount=5},
        {type="item", name="p2s5", amount=1},
        {type="item", name="rich-clay", amount=3},
        {type="item", name="sodium-chlorate", amount=2},
        {type="item", name="titanium-plate", amount=5},
        {type="item", name="yaedols", amount=1},
      },
      results = {
        {type="item", name="fish-food-02", amount=3},
      },
    },
    ["naven-coal"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 3.1,
      ingredients = {
        {type="item", name="navens", amount=2},
        {type="item", name="yaedols", amount=1},
      },
      results = {
        {type="item", name="raw-coal", amount=31},
      },
    },
    ["navens-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.71428571428571,
      ingredients = {
        {type="item", name="fertilizer", amount=11},
        {type="item", name="fungal-substrate-03", amount=1},
        {type="item", name="guts", amount=10},
        {type="item", name="piercing-rounds-magazine", amount=1},
      },
      results = {
        {type="item", name="navens", amount=12},
      },
    },
    ["navens-sample"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="alien-sample-02", amount=3},
        {type="item", name="earth-mouse-sample", amount=2},
        {type="item", name="fts-reactor", amount=20},
        {type="item", name="navens-codex", amount=1},
        {type="item", name="reformer-mk01", amount=9},
      },
      results = {
        {type="item", name="navens", amount=4},
      },
    },
    ["mukmoux-codex"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="electronic-circuit", amount=6},
        {type="item", name="filtration-media", amount=3},
        {type="item", name="pipe", amount=5},
        {type="item", name="sodium-sulfate", amount=6},
      },
      results = {
        {type="item", name="mukmoux-codex", amount=1},
      },
    },
    ["mukmoux-food-01"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="water-saline", amount=940},
        {type="item", name="copper-rejects", amount=1},
        {type="item", name="crushed-molybdenite", amount=24},
        {type="item", name="gunpowder", amount=2},
        {type="item", name="moss", amount=2},
        {type="item", name="nickel-plate", amount=4},
        {type="item", name="silicon", amount=5},
        {type="item", name="sodium-hydroxide", amount=3},
        {type="item", name="stopper", amount=1},
      },
      results = {
        {type="item", name="mukmoux-food-01", amount=4},
      },
    },
    ["mukmoux-manure-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.96836141439634,
      ingredients = {
        {type="item", name="bedding", amount=2},
        {type="item", name="crushed-coal", amount=24},
        {type="item", name="mukmoux-food-01", amount=4},
        {type="item", name="refined-natural-gas-barrel", amount=3},
      },
      results = {
        {type="item", name="barrel", amount=13},
        {type="item", name="manure", amount=5},
        {type="item", name="manure-bacteria-barrel", amount=1},
      },
    },
    ["mukmoux"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="blood", amount=1468},
        {type="fluid", name="molten-salt", amount=559},
        {type="item", name="alien-sample-02", amount=5},
        {type="item", name="cytostatics", amount=5},
        {type="item", name="earth-crustacean-sample", amount=1},
        {type="item", name="titanium-plate", amount=164},
        {type="item", name="ulric-codex", amount=1},
        {type="item", name="zipir-codex", amount=2},
      },
      results = {
        {type="item", name="mukmoux", amount=2},
      },
    },
    ["mukmoux-calf-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.47949682058144,
      ingredients = {
        {type="item", name="bedding", amount=3},
        {type="item", name="crushed-coal", amount=11},
        {type="item", name="mukmoux-food-01", amount=1},
        {type="item", name="ralesia", amount=29},
        {type="item", name="raw-fiber", amount=14},
        {type="item", name="refined-natural-gas-barrel", amount=15},
        {type="item", name="salt", amount=113},
      },
      results = {
        {type="item", name="barrel", amount=21},
        {type="item", name="mukmoux-calf", amount=3},
      },
    },
    ["mukmoux-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 3.10814615805343,
      ingredients = {
        {type="item", name="caged-mukmoux", amount=4},
        {type="item", name="fish-egg", amount=3},
        {type="item", name="mukmoux", amount=5},
        {type="item", name="mukmoux-food-01", amount=3},
        {type="item", name="ralesia", amount=26},
        {type="item", name="refined-natural-gas-barrel", amount=4},
      },
      results = {
        {type="item", name="barrel", amount=32},
        {type="item", name="mukmoux", amount=11},
      },
    },
    ["mukmoux-pasture-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aromatics-barrel", amount=21},
        {type="item", name="controler-mk01", amount=1},
        {type="item", name="limestone", amount=231},
        {type="item", name="py-tank-7000", amount=3},
        {type="item", name="residual-oil-barrel", amount=35},
        {type="item", name="stopper", amount=2},
      },
      results = {
        {type="item", name="mukmoux-pasture-mk01", amount=1},
      },
    },
    ["uncaged-mukmoux"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="caged-mukmoux", amount=1},
      },
      results = {
        {type="item", name="cage", amount=1},
        {type="item", name="mukmoux", amount=1},
      },
    },
    ["cottongut-food-02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.16666666666667,
      ingredients = {
        {type="fluid", name="manure-bacteria", amount=108},
        {type="item", name="fawogae", amount=6},
        {type="item", name="grade-3-zinc", amount=2},
        {type="item", name="gravel", amount=4},
        {type="item", name="guar", amount=5},
        {type="item", name="moondrop-mk02", amount=1},
        {type="item", name="nexelit-plate", amount=3},
        {type="item", name="salt", amount=14},
        {type="item", name="saps", amount=2},
        {type="item", name="soil", amount=22},
        {type="item", name="wood-seeds-mk02", amount=6},
      },
      results = {
        {type="item", name="cottongut-food-02", amount=7},
      },
    },
    ["cottongut-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.99935872725787,
      ingredients = {
        {type="fluid", name="chlorine", amount=2239},
        {type="fluid", name="fetal-serum", amount=39},
        {type="item", name="cottongut-food-01", amount=2},
        {type="item", name="dna-polymerase", amount=2},
        {type="item", name="sea-sponge-sprouts", amount=7},
      },
      results = {
        {type="item", name="cottongut-mk01", amount=1},
        {type="item", name="cottongut-mk02", amount=0.00990143121380533},
      },
    },
    ["cottongut-pup-mk02-raising"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2.07792207792208,
      ingredients = {
        {type="item", name="barrel-milk", amount=1},
        {type="item", name="cottongut-mk02", amount=3},
        {type="item", name="filtration-media", amount=1},
        {type="item", name="fish-egg", amount=9},
        {type="item", name="fish-food-02", amount=1},
        {type="item", name="residual-mixture-canister", amount=3},
        {type="item", name="small-lamp", amount=3},
        {type="item", name="tuuphra", amount=2},
      },
      results = {
        {type="item", name="cottongut-mk02", amount=3},
        {type="item", name="cottongut-pup-mk02", amount=8},
      },
    },
    ["caged-cottongut-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.55387853347193,
      ingredients = {
        {type="item", name="albumin", amount=1},
        {type="item", name="cottongut-food-01", amount=2},
        {type="item", name="cottongut-pup", amount=18},
        {type="item", name="moondrop-mk02", amount=1},
        {type="item", name="naphtha-barrel", amount=1},
        {type="item", name="tuuphra", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=3},
        {type="item", name="cottongut", amount=14},
      },
    },
    ["cottongut-cub-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.884109964084073,
      ingredients = {
        {type="item", name="barrel-milk", amount=2},
        {type="item", name="bedding", amount=1},
        {type="item", name="bhoddos", amount=1},
        {type="item", name="cottongut-mk01", amount=2},
        {type="item", name="moondrop-fueloil", amount=1},
        {type="item", name="olefin-barrel", amount=2},
        {type="item", name="yotoi-fruit", amount=26},
      },
      results = {
        {type="item", name="barrel", amount=3},
        {type="item", name="cottongut-pup", amount=14},
        {type="item", name="empty-barrel-milk", amount=2},
      },
    },
    ["cottongut-mature-basic-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="cottongut", amount=3},
        {type="item", name="cottongut-food-01", amount=7},
        {type="item", name="cottongut-mk01", amount=3},
        {type="item", name="cottongut-pup", amount=11},
        {type="item", name="land-mine", amount=5},
        {type="item", name="sea-sponge", amount=1},
      },
      results = {
        {type="item", name="cottongut-mk02", amount=4},
      },
    },
    ["auog-food-02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.8,
      ingredients = {
        {type="item", name="clay", amount=3},
        {type="item", name="empty-planter-box", amount=18},
        {type="item", name="fertilizer", amount=2},
        {type="item", name="grenade", amount=1},
        {type="item", name="methane-barrel", amount=1},
        {type="item", name="planter-box", amount=6},
        {type="item", name="ralesia-seeds", amount=10},
        {type="item", name="raw-fiber", amount=5},
        {type="item", name="salt", amount=10},
        {type="item", name="sodium-hydroxide", amount=32},
      },
      results = {
        {type="item", name="auog-food-02", amount=9},
      },
    },
    ["auog-maturing-3"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.26116982892071,
      ingredients = {
        {type="item", name="auog-food-02", amount=3},
        {type="item", name="bedding", amount=2},
        {type="item", name="cocoon-mk02", amount=2},
        {type="item", name="cottongut-food-01", amount=1},
        {type="item", name="kicalk", amount=5},
        {type="item", name="moondrop-seeds", amount=48},
        {type="item", name="refined-natural-gas-barrel", amount=3},
        {type="item", name="sb-grade-03", amount=1},
        {type="item", name="stone-wool", amount=1},
        {type="item", name="tailings-barrel", amount=7},
      },
      results = {
        {type="item", name="auog", amount=10},
        {type="item", name="barrel", amount=7},
      },
    },
    ["auog-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.41346634742589,
      ingredients = {
        {type="fluid", name="arthropod-blood", amount=124},
        {type="item", name="auog-food-01", amount=1},
        {type="item", name="auog-food-02", amount=1},
        {type="item", name="dried-meat", amount=20},
        {type="item", name="quartz-tube", amount=1},
      },
      results = {
        {type="item", name="auog", amount=1},
        {type="item", name="auog-mk02", amount=0.00682537276246361},
        {type="item", name="charged-auog", amount=0.136507455249272},
      },
    },
    ["charged-auog"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 5,
      ingredients = {
        {type="item", name="pitch-canister", amount=7},
        {type="item", name="rail-chain-signal", amount=3},
        {type="item", name="wood-seeds", amount=13},
      },
      results = {
        {type="item", name="charged-auog", amount=5},
      },
    },
    ["auog-mk02-breeder"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.39906806069103,
      ingredients = {
        {type="item", name="albumin", amount=2},
        {type="item", name="auog-food-01", amount=7},
        {type="item", name="auog-mk02", amount=2},
        {type="item", name="bedding", amount=4},
        {type="item", name="cottongut-food-01", amount=1},
        {type="item", name="cottongut-pup", amount=12},
        {type="item", name="geothermal-water-barrel", amount=3},
        {type="item", name="moondrop-mk02", amount=1},
        {type="item", name="moss", amount=10},
        {type="item", name="naphtha-barrel", amount=3},
        {type="item", name="vrauks-food-02", amount=2},
      },
      results = {
        {type="item", name="auog-pup-mk02", amount=7},
        {type="item", name="barrel", amount=4},
      },
    },
    ["auog-mk02-recharge"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.75,
      ingredients = {
        {type="item", name="auog-food-02", amount=3},
        {type="item", name="used-ulric-mk02", amount=1},
      },
      results = {
        {type="item", name="auog-mk02", amount=7},
      },
    },
    ["auog-pooping-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.03888244883662,
      ingredients = {
        {type="item", name="auog-food-02", amount=1},
        {type="item", name="bedding", amount=3},
        {type="item", name="btx-canister", amount=4},
        {type="item", name="dirty-syngas-barrel", amount=1},
        {type="item", name="kicalk", amount=5},
        {type="item", name="moss", amount=10},
        {type="item", name="naphtha-barrel", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="manure", amount=11},
      },
    },
    ["auog-pup-breeding-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="auog-food-02", amount=2},
        {type="item", name="bedding", amount=6},
        {type="item", name="btx-canister", amount=5},
        {type="item", name="crushed-molybdenite", amount=38},
        {type="item", name="dirty-syngas-barrel", amount=1},
        {type="item", name="kicalk", amount=4},
        {type="item", name="moss", amount=26},
        {type="item", name="naphtha-barrel", amount=2},
        {type="item", name="refined-natural-gas-barrel", amount=4},
        {type="item", name="tar-canister", amount=1},
      },
      results = {
        {type="item", name="auog-pup", amount=24},
        {type="item", name="barrel", amount=10},
      },
    },
    ["auog-recharge"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="item", name="albumin", amount=1},
        {type="item", name="auog-food-01", amount=2},
        {type="item", name="subcritical-water-barrel", amount=20},
      },
      results = {
        {type="item", name="auog", amount=5},
      },
    },
    ["auog-pup-mk02-breeder"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33470890611315,
      ingredients = {
        {type="fluid", name="water-saline", amount=310},
        {type="item", name="al-pulp-02-barrel", amount=10},
        {type="item", name="auog-food-01", amount=5},
        {type="item", name="auog-pup-mk02", amount=3},
        {type="item", name="barrel-milk", amount=1},
        {type="item", name="bedding", amount=3},
        {type="item", name="molybdenum-sulfide", amount=5},
        {type="item", name="petri-dish", amount=2},
      },
      results = {
        {type="item", name="auog-mk02", amount=4},
        {type="item", name="barrel", amount=4},
        {type="item", name="empty-barrel-milk", amount=3},
      },
    },
    ["ralesia-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.24,
      ingredients = {
        {type="fluid", name="pressured-water", amount=352},
        {type="fluid", name="water", amount=148},
        {type="item", name="cottongut-pup", amount=1},
        {type="item", name="fertilizer", amount=7},
        {type="item", name="limestone", amount=2},
        {type="item", name="powdered-biomass", amount=4},
        {type="item", name="ralesia-seeds", amount=10},
        {type="item", name="sand", amount=8},
      },
      results = {
        {type="item", name="ralesia", amount=31},
      },
    },
    ["ralesia-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.562873559835205,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=147},
        {type="fluid", name="water", amount=966},
        {type="item", name="limestone", amount=37},
        {type="item", name="ralesia", amount=2},
        {type="item", name="ralesia-seeds", amount=8},
      },
      results = {
        {type="item", name="ralesia", amount=1},
        {type="item", name="ralesia-mk02", amount=0.00281436779917603},
      },
    },
    ["ralesia-seeds-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="item", name="caged-ulric", amount=1},
        {type="item", name="ralesia", amount=63},
        {type="item", name="refined-natural-gas-barrel", amount=3},
      },
      results = {
        {type="item", name="ralesia-seeds-mk02", amount=10},
      },
    },
    ["ralesia-mk02-breeder"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="fawogae-mk02", amount=1},
        {type="item", name="ralesia-seeds-mk02", amount=4},
        {type="item", name="yaedols", amount=3},
      },
      results = {
        {type="item", name="fawogae-spore-mk02", amount=1},
        {type="item", name="ralesia-mk02", amount=4},
        {type="item", name="ralesia-seeds-mk02", amount=1},
      },
    },
    ["vrauks-cocoon-3"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.08759161709509,
      ingredients = {
        {type="item", name="bhoddos", amount=1},
        {type="item", name="cottongut-food-01", amount=5},
        {type="item", name="petroleum-gas-canister", amount=1},
        {type="item", name="vrauks-food-02", amount=1},
        {type="item", name="water-barrel", amount=8},
      },
      results = {
        {type="item", name="barrel", amount=4},
        {type="item", name="cocoon", amount=22},
      },
    },
    ["vrauks-food-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="coal-gas", amount=227},
        {type="fluid", name="fish-oil", amount=32},
        {type="item", name="casein", amount=9},
        {type="item", name="formica", amount=1},
        {type="item", name="grod-seeds", amount=1},
        {type="item", name="lignin", amount=8},
        {type="item", name="mixed-ores", amount=4},
        {type="item", name="mukmoux-fat", amount=1},
        {type="item", name="salt", amount=26},
        {type="item", name="saps-mk03", amount=1},
        {type="item", name="sodium-hydroxide", amount=9},
        {type="item", name="sodium-sulfate", amount=1},
        {type="item", name="yaedols", amount=1},
      },
      results = {
        {type="item", name="vrauks-food-02", amount=8},
      },
    },
    ["vrauks-mk03"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.95490899925983,
      ingredients = {
        {type="item", name="alien-sample-02", amount=2},
        {type="item", name="auog-food-02", amount=3},
        {type="item", name="bedding", amount=5},
        {type="item", name="cocoon-mk02", amount=56},
        {type="item", name="sea-sponge", amount=4},
        {type="item", name="vrauks-food-02", amount=3},
      },
      results = {
        {type="item", name="barrel", amount=9},
        {type="item", name="vrauks-mk02", amount=5},
        {type="item", name="vrauks-mk03", amount=0.00738845200277071},
      },
    },
    ["vrauks-3"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-food-01", amount=1},
        {type="item", name="auog-food-02", amount=1},
        {type="item", name="cocoon-mk02", amount=9},
        {type="item", name="cottongut-food-01", amount=3},
        {type="item", name="cottongut-food-02", amount=1},
        {type="item", name="refined-natural-gas-barrel", amount=1},
      },
      results = {
        {type="item", name="barrel", amount=3},
        {type="item", name="vrauks", amount=8},
      },
    },
    ["vrauks-mk03-breeder"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.05241200641898,
      ingredients = {
        {type="item", name="bedding", amount=17},
        {type="item", name="cocoon-mk03", amount=8},
        {type="item", name="fishmeal", amount=39},
        {type="item", name="moss", amount=195},
        {type="item", name="sea-sponge", amount=46},
        {type="item", name="vrauks-mk03", amount=10},
        {type="item", name="water-barrel", amount=48},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="vrauks-mk03", amount=11},
      },
    },
    ["vrauks-mk03-cocoon"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.27011887420448,
      ingredients = {
        {type="item", name="bedding", amount=2},
        {type="item", name="kerosene-canister", amount=1},
        {type="item", name="kevlar-coating", amount=1},
        {type="item", name="naphtha-barrel", amount=1},
        {type="item", name="sea-sponge", amount=4},
        {type="item", name="vrauks-food-01", amount=2},
        {type="item", name="vrauks-mk03", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=6},
        {type="item", name="cocoon-mk03", amount=7},
        {type="item", name="vrauks-mk03", amount=2},
      },
    },
    ["yotoi-sample"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2.5,
      ingredients = {
        {type="item", name="alien-sample-02", amount=7},
        {type="item", name="earth-sunflower-sample", amount=3},
        {type="item", name="xyhiphoe-codex", amount=3},
      },
      results = {
        {type="item", name="yotoi", amount=5},
      },
    },
    ["yotoi-leaves"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="yotoi", amount=2},
      },
      results = {
        {type="item", name="yotoi-leaves", amount=5},
      },
    },
    ["yotoi-seeds"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.666666666666667,
      ingredients = {
        {type="item", name="yotoi-fruit", amount=5},
      },
      results = {
        {type="item", name="yotoi-seeds", amount=2},
      },
    },
    ["yotoi-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="fluid", name="tar", amount=219},
        {type="item", name="coke", amount=3},
        {type="item", name="pure-sand", amount=5},
        {type="item", name="yotoi-fruit", amount=2},
      },
      results = {
        {type="item", name="yotoi", amount=5},
      },
    },
    ["yotoi-fruit-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="gravel", amount=10},
        {type="item", name="sand", amount=2},
      },
      results = {
        {type="item", name="yotoi-fruit", amount=4},
      },
    },
    ["fawogae-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="fluid", name="water", amount=160},
        {type="item", name="fungal-substrate", amount=1},
        {type="item", name="melamine", amount=7},
      },
      results = {
        {type="item", name="fawogae", amount=18},
      },
    },
    ["fawogae-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.14688240270504,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=303},
        {type="fluid", name="oxygen", amount=74},
        {type="fluid", name="steam", amount=263},
        {type="item", name="coalbed-gas-barrel", amount=1},
        {type="item", name="coke", amount=37},
        {type="item", name="fawogae", amount=2},
        {type="item", name="fertilizer", amount=10},
        {type="item", name="limestone", amount=10},
        {type="item", name="ralesia-seeds", amount=6},
      },
      results = {
        {type="item", name="fawogae", amount=1},
        {type="item", name="fawogae-mk02", amount=0.00573441201352521},
      },
    },
    ["fawogae-mk02-breeder"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="fluid", name="steam", amount=261},
        {type="fluid", name="water", amount=702},
        {type="item", name="fawogae", amount=2},
        {type="item", name="fawogae-spore", amount=19},
        {type="item", name="limestone", amount=2},
      },
      results = {
        {type="item", name="fawogae-mk02", amount=1},
      },
    },
    ["fawogae-spore-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="fawogae-mk02", amount=1},
      },
      results = {
        {type="item", name="fawogae-spore-mk02", amount=5},
      },
    },
    ["yaedols-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="albumin", amount=1},
        {type="item", name="fungal-substrate", amount=3},
        {type="item", name="ralesia-seeds", amount=10},
        {type="item", name="wood", amount=7},
        {type="item", name="yaedols-spores", amount=5},
      },
      results = {
        {type="item", name="yaedols", amount=6},
      },
    },
    ["yaedols-spore-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.2,
      ingredients = {
        {type="item", name="yaedols", amount=16},
      },
      results = {
        {type="item", name="yaedols-spores-mk02", amount=1},
      },
    },
    ["yaedols-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.92291220574978,
      ingredients = {
        {type="fluid", name="steam", amount=756},
        {type="item", name="albumin", amount=4},
        {type="item", name="wax-barrel", amount=1},
        {type="item", name="wood", amount=27},
        {type="item", name="yaedols", amount=4},
      },
      results = {
        {type="item", name="yaedols", amount=1},
        {type="item", name="yaedols-mk02", amount=0.00961456102874892},
      },
    },
    ["yaedols-mk02-breeder"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.77777777777778,
      ingredients = {
        {type="item", name="nisi", amount=2},
        {type="item", name="ulric", amount=7},
        {type="item", name="yaedols", amount=327},
      },
      results = {
        {type="item", name="yaedols-mk02", amount=4},
      },
    },
    ["brain-food-01"] = {
      mode = "input-preserved-untransformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="animal-sample-01", amount=2},
      },
      results = {
      },
    },
    ["purex-antimony-void"] = {
      mode = "input-preserved-untransformed",
      science_level = 5,
      energy_required_multiplier = 1.71043583894469,
      ingredients = {
        {type="fluid", name="purex-concentrate-1", amount=50},
        {type="fluid", name="sb-phosphate-2", amount=100},
        {type="item", name="plastic-bar", amount=5},
      },
      results = {
        {type="fluid", name="phosphorous-acid", amount=200},
        {type="item", name="plastic-bar", amount=3},
        {type="item", name="sb-oxide", amount=1},
      },
    },
    ["titanium-overflow-waste-void"] = {
      mode = "input-preserved-untransformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ti-overflow-waste", amount=25},
      },
      results = {
        {type="item", name="ti-rejects", amount=1},
      },
    },
    ["titanium-pulp-stage-3-void"] = {
      mode = "input-preserved-untransformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ti-pulp-03", amount=60},
      },
      results = {
        {type="fluid", name="mibc", amount=30},
        {type="fluid", name="ti-overflow-waste", amount=30},
      },
    },
  },
}

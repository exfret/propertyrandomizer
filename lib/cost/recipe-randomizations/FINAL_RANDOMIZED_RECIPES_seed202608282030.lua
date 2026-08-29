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
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="stone-furnace", amount=4},
      },
      results = {
        {type="item", name="copper-plate", amount=3},
      },
    },
    ["iron-plate"] = {
      mode = "kept-pruned-transformed",
      science_level = 0,
      energy_required_multiplier = 0.126470771480871,
      ingredients = {
        {type="item", name="copper-ore", amount=1},
      },
      results = {
        {type="item", name="iron-plate", amount=0.126470771480871},
      },
    },
    ["copper-cable"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="copper-ore", amount=17},
      },
      results = {
        {type="item", name="copper-cable", amount=3},
      },
    },
    ["iron-stick"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 5,
      ingredients = {
        {type="item", name="iron-plate", amount=3},
        {type="item", name="stone-furnace", amount=4},
      },
      results = {
        {type="item", name="iron-stick", amount=10},
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
        {type="item", name="bolts", amount=5},
        {type="item", name="copper-cable", amount=2},
        {type="item", name="iron-gear-wheel", amount=3},
      },
      results = {
        {type="item", name="small-parts-01", amount=4},
      },
    },
    ["burner-inserter"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-ore", amount=24},
        {type="item", name="iron-stick", amount=7},
        {type="item", name="small-parts-01", amount=2},
      },
      results = {
        {type="item", name="burner-inserter", amount=1},
      },
    },
    ["inductor1-2"] = {
      mode = "repaired-to-input",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=8},
        {type="item", name="iron-stick", amount=1},
      },
      results = {
        {type="item", name="inductor1", amount=1},
      },
    },
    ["soil"] = {
      mode = "kept-pruned-transformed",
      science_level = 0,
      energy_required_multiplier = 0.4375,
      ingredients = {
        {type="fluid", name="steam", amount=31},
      },
      results = {
        {type="item", name="soil", amount=7},
      },
    },
    ["stone-brick"] = {
      mode = "kept-pruned-transformed",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="kerogen", amount=2},
      },
      results = {
        {type="item", name="stone-brick", amount=1},
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
      mode = "softmax-semantic-substitution",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-ore", amount=12},
        {type="item", name="small-parts-01", amount=1},
      },
      results = {
        {type="item", name="transport-belt", amount=2},
      },
    },
    ["underground-belt"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=2},
        {type="item", name="copper-plate", amount=2},
        {type="item", name="stone-brick", amount=20},
      },
      results = {
        {type="item", name="underground-belt", amount=2},
      },
    },
    ["lab"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="copper-plate", amount=12},
        {type="item", name="small-parts-01", amount=15},
        {type="item", name="stone", amount=26},
        {type="item", name="transport-belt", amount=17},
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
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="copper-plate", amount=8},
      },
      results = {
        {type="item", name="pipe-to-ground", amount=1},
      },
    },
    ["small-electric-pole"] = {
      mode = "input-preserved-untransformed",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="log", amount=1},
        {type="item", name="stone-furnace", amount=2},
      },
      results = {
        {type="item", name="small-electric-pole", amount=1},
      },
    },
    ["boiler"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="pipe", amount=9},
      },
      results = {
        {type="item", name="boiler", amount=2},
      },
    },
    ["steam-engine"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=5},
        {type="item", name="iron-stick", amount=18},
        {type="item", name="small-parts-01", amount=8},
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
        {type="item", name="copper-plate", amount=3},
        {type="item", name="stone", amount=6},
        {type="item", name="transport-belt", amount=4},
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
        {type="item", name="boiler", amount=1},
        {type="item", name="pipe", amount=3},
        {type="item", name="stone-furnace", amount=17},
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
        {type="item", name="bolts", amount=40},
        {type="item", name="burner-mining-drill", amount=1},
        {type="item", name="copper-cable", amount=109},
        {type="item", name="iron-stick", amount=56},
        {type="item", name="offshore-pump", amount=3},
        {type="item", name="pipe", amount=14},
        {type="item", name="small-parts-01", amount=25},
        {type="item", name="steam-engine", amount=1},
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
        {type="item", name="boiler", amount=5},
        {type="item", name="copper-ore", amount=247},
        {type="item", name="iron-stick", amount=50},
        {type="item", name="lab", amount=1},
        {type="item", name="log", amount=5},
        {type="item", name="pipe", amount=38},
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
        {type="item", name="burner-inserter", amount=14},
        {type="item", name="copper-cable", amount=46},
        {type="item", name="raw-coal", amount=345},
        {type="item", name="stone", amount=247},
        {type="item", name="stone-furnace", amount=74},
        {type="item", name="transport-belt", amount=12},
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
        {type="item", name="ash", amount=2},
        {type="item", name="pipe", amount=5},
        {type="item", name="planter-box", amount=2},
      },
      results = {
        {type="item", name="automation-science-pack", amount=1},
      },
    },
    ["empty-planter-box"] = {
      mode = "input-preserved-untransformed",
      science_level = 0,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="iron-stick", amount=4},
        {type="item", name="stone-furnace", amount=5},
        {type="item", name="wood", amount=4},
      },
      results = {
        {type="item", name="empty-planter-box", amount=2},
      },
    },
    ["planter-box"] = {
      mode = "input-preserved-untransformed",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-ore", amount=13},
        {type="item", name="empty-planter-box", amount=1},
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
        {type="item", name="inductor1", amount=4},
        {type="item", name="pipe", amount=10},
        {type="item", name="transport-belt", amount=4},
      },
      results = {
        {type="item", name="assembling-machine-1", amount=1},
      },
    },
    ["bricks-to-stone"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="stone-brick", amount=2},
      },
      results = {
        {type="item", name="stone", amount=4},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-ore", amount=4},
        {type="item", name="grade-2-copper", amount=4},
      },
      results = {
        {type="item", name="copper-plate", amount=2},
      },
    },
    ["grade-1-copper-crush"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-ore", amount=14},
      },
      results = {
        {type="item", name="grade-2-copper", amount=1},
        {type="item", name="stone", amount=2},
      },
    },
    ["fiber-01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-ore", amount=12},
        {type="item", name="wood", amount=6},
      },
      results = {
        {type="item", name="raw-fiber", amount=2},
      },
    },
    ["glass-1"] = {
      mode = "repaired-to-input",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ore-quartz", amount=6},
      },
      results = {
        {type="fluid", name="molten-glass", amount=10},
      },
    },
    ["molten-glass"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=2483},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="stone", amount=7},
      },
      results = {
        {type="item", name="sand", amount=3},
      },
    },
    ["stone-to-gravel"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="item", name="iron-ore", amount=3},
        {type="item", name="stone", amount=4},
      },
      results = {
        {type="item", name="gravel", amount=5},
      },
    },
    ["gun-turret"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="log", amount=11},
        {type="item", name="offshore-pump", amount=1},
        {type="item", name="pipe", amount=25},
      },
      results = {
        {type="item", name="gun-turret", amount=1},
      },
    },
    ["muddy-sludge"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.29,
      ingredients = {
        {type="fluid", name="water", amount=99},
        {type="item", name="iron-ore", amount=4},
        {type="item", name="wood", amount=3},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=129},
      },
    },
    ["soil-washing"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.506838402424505,
      ingredients = {
        {type="fluid", name="water", amount=505},
        {type="item", name="native-flora", amount=13},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=52},
        {type="item", name="sand", amount=5},
      },
    },
    ["pressured-water"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.668,
      ingredients = {
        {type="fluid", name="water", amount=834},
      },
      results = {
        {type="fluid", name="pressured-water", amount=834},
      },
    },
    ["repair-pack"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="pipe", amount=3},
        {type="item", name="wooden-chest", amount=8},
      },
      results = {
        {type="item", name="repair-pack", amount=1},
      },
    },
    ["seaweed-1"] = {
      mode = "input-preserved-untransformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=200},
      },
      results = {
        {type="item", name="seaweed", amount=10},
      },
    },
    ["shotgun"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ash", amount=40},
        {type="item", name="copper-cable", amount=14},
        {type="item", name="empty-planter-box", amount=3},
        {type="item", name="soil", amount=15},
      },
      results = {
        {type="item", name="shotgun", amount=1},
      },
    },
    ["submachine-gun"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="copper-cable", amount=12},
        {type="item", name="inductor1", amount=1},
        {type="item", name="iron-gear-wheel", amount=3},
        {type="item", name="pipe", amount=3},
        {type="item", name="raw-fiber", amount=19},
        {type="item", name="transport-belt", amount=12},
      },
      results = {
        {type="item", name="submachine-gun", amount=2},
      },
    },
    ["small-lamp"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="water", amount=555},
        {type="item", name="copper-cable", amount=3},
        {type="item", name="copper-ore", amount=4},
        {type="item", name="glass", amount=2},
        {type="item", name="iron-stick", amount=1},
        {type="item", name="native-flora", amount=42},
      },
      results = {
        {type="item", name="small-lamp", amount=2},
      },
    },
    ["tailings-pond"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=8},
        {type="item", name="small-parts-01", amount=3},
        {type="item", name="stone-brick", amount=109},
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
        {type="item", name="ore-tin", amount=25},
        {type="item", name="ore-zinc", amount=34},
      },
      results = {
        {type="item", name="tin-plate", amount=6},
      },
    },
    ["acetylene"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.795112374474208,
      ingredients = {
        {type="fluid", name="pressured-water", amount=241},
        {type="item", name="lime", amount=4},
      },
      results = {
        {type="fluid", name="acetylene", amount=79},
        {type="fluid", name="slacked-lime", amount=20},
      },
    },
    ["coal-gas"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2.94376152213681,
      ingredients = {
        {type="item", name="coal", amount=28},
      },
      results = {
        {type="fluid", name="coal-gas", amount=111},
        {type="fluid", name="tar", amount=139},
        {type="item", name="coke", amount=17},
        {type="item", name="iron-oxide", amount=1},
      },
    },
    ["coal-gas-from-wood"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 0.392549049640172,
      ingredients = {
        {type="item", name="wood", amount=4},
      },
      results = {
        {type="fluid", name="coal-gas", amount=4},
        {type="fluid", name="tar", amount=11},
        {type="item", name="coal", amount=4},
        {type="item", name="iron-oxide", amount=0.114572807887118},
      },
    },
    ["syngas"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 0.863027200327536,
      ingredients = {
        {type="fluid", name="pressured-water", amount=311},
        {type="fluid", name="water", amount=133},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="limestone", amount=31},
      },
      results = {
        {type="fluid", name="coal-gas", amount=20},
        {type="fluid", name="tar", amount=20},
        {type="item", name="ash", amount=1},
      },
    },
    ["distilled-raw-coal"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.380356020786962,
      ingredients = {
        {type="item", name="iron-ore", amount=4},
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
        {type="item", name="ore-zinc", amount=9},
      },
      results = {
        {type="item", name="aluminium-plate", amount=1},
      },
    },
    ["graphite"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="limestone", amount=4},
      },
      results = {
        {type="item", name="graphite", amount=1},
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
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="item", name="bolts", amount=8},
        {type="item", name="raw-coal", amount=53},
      },
      results = {
        {type="item", name="ceramic", amount=7},
      },
    },
    ["duralumin-1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-ore", amount=11},
        {type="item", name="copper-plate", amount=4},
        {type="item", name="kerogen", amount=9},
        {type="item", name="lead-plate", amount=2},
        {type="item", name="limestone", amount=7},
      },
      results = {
        {type="item", name="duralumin", amount=1},
      },
    },
    ["tinned-cable"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="copper-cable", amount=13},
        {type="item", name="tin-plate", amount=3},
      },
      results = {
        {type="item", name="tinned-cable", amount=4},
      },
    },
    ["engine-unit"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 5,
      ingredients = {
        {type="item", name="boiler", amount=3},
        {type="item", name="fluid-drill-mk01", amount=2},
        {type="item", name="inductor1", amount=22},
        {type="item", name="iron-plate", amount=39},
        {type="item", name="limestone", amount=266},
      },
      results = {
        {type="item", name="engine-unit", amount=5},
      },
    },
    ["iron-oxide-smelting"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="tailings-pond", amount=1},
      },
      results = {
        {type="item", name="iron-plate", amount=8},
      },
    },
    ["lead-plate-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ore-zinc", amount=9},
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
        {type="item", name="titanium-plate", amount=27},
      },
      results = {
        {type="item", name="moondrop-codex", amount=1},
      },
    },
    ["solder-0"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="tin-plate", amount=2},
        {type="item", name="titanium-plate", amount=3},
        {type="item", name="zinc-plate", amount=1},
      },
      results = {
        {type="item", name="solder", amount=1},
      },
    },
    ["tar-quenching"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.92059969709434,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=658},
        {type="fluid", name="pressured-water", amount=319},
        {type="fluid", name="syngas", amount=548},
        {type="fluid", name="water", amount=212},
      },
      results = {
        {type="fluid", name="flue-gas", amount=283},
        {type="fluid", name="tailings", amount=943},
        {type="fluid", name="water-saline", amount=471},
        {type="item", name="soot", amount=4},
      },
    },
    ["chlorine"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.953969669937556,
      ingredients = {
        {type="fluid", name="water-saline", amount=90},
      },
      results = {
        {type="fluid", name="chlorine", amount=18},
        {type="fluid", name="hydrogen", amount=18},
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
      energy_required_multiplier = 1.44840922923355,
      ingredients = {
        {type="fluid", name="tailings", amount=77},
        {type="fluid", name="water-saline", amount=36},
      },
      results = {
        {type="fluid", name="acidgas", amount=21},
        {type="item", name="tailings-dust", amount=6},
      },
    },
    ["ash-separation"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.84876283032416,
      ingredients = {
        {type="item", name="coke", amount=28},
      },
      results = {
        {type="item", name="coal-dust", amount=1},
        {type="item", name="iron-oxide", amount=0.0872117770660937},
        {type="item", name="soot", amount=0.348847108264375},
      },
    },
    ["soot-separation"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 3.13188329738642,
      ingredients = {
        {type="item", name="bolts", amount=50},
      },
      results = {
        {type="item", name="ash", amount=1},
        {type="item", name="copper-ore", amount=0.591181549692265},
        {type="item", name="iron-ore", amount=0.591181549692265},
        {type="item", name="ore-aluminium", amount=0.295590774846132},
        {type="item", name="ore-lead", amount=0.295590774846132},
        {type="item", name="ore-zinc", amount=0.295590774846132},
      },
    },
    ["tailings-classification"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-ore", amount=13},
        {type="item", name="limestone", amount=38},
      },
      results = {
        {type="item", name="coal-dust", amount=5},
        {type="item", name="ore-tin", amount=1},
        {type="item", name="ore-titanium", amount=1},
      },
    },
    ["extract-sulfur"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="acidgas", amount=94},
      },
      results = {
        {type="item", name="sulfur", amount=2},
      },
    },
    ["titanium-plate-1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="item", name="ore-tin", amount=28},
      },
      results = {
        {type="item", name="titanium-plate", amount=3},
      },
    },
    ["water-from-oxygen-and-hydrogen"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.86666666666667,
      ingredients = {
        {type="fluid", name="hydrogen", amount=193},
        {type="fluid", name="pressured-water", amount=451},
        {type="item", name="stone-brick", amount=4},
      },
      results = {
        {type="fluid", name="water", amount=560},
      },
    },
    ["zinc-plate-1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="ore-lead", amount=11},
        {type="item", name="ore-tin", amount=2},
      },
      results = {
        {type="item", name="zinc-plate", amount=2},
      },
    },
    ["py-tank-1000"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="light-oil-barrel", amount=4},
        {type="item", name="pressured-air-barrel", amount=2},
        {type="item", name="water-barrel", amount=13},
      },
      results = {
        {type="item", name="py-tank-1000", amount=1},
      },
    },
    ["py-tank-3000"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="concrete", amount=40},
        {type="item", name="copper-cable", amount=341},
        {type="item", name="small-parts-01", amount=6},
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
        {type="item", name="aluminium-plate", amount=40},
        {type="item", name="iron-chest", amount=1},
        {type="item", name="iron-gear-wheel", amount=6},
        {type="item", name="iron-plate", amount=101},
        {type="item", name="tin-plate", amount=3},
      },
      results = {
        {type="item", name="py-tank-4000", amount=2},
      },
    },
    ["py-tank-8000"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=17},
        {type="item", name="bolts", amount=151},
        {type="item", name="iron-plate", amount=8},
        {type="item", name="limestone", amount=18},
        {type="item", name="tailings-pond", amount=3},
      },
      results = {
        {type="item", name="py-tank-8000", amount=1},
      },
    },
    ["py-tank-10000"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=4},
        {type="item", name="hazard-concrete", amount=176},
        {type="item", name="limestone", amount=917},
        {type="item", name="tin-plate", amount=2},
        {type="item", name="titanium-plate", amount=63},
      },
      results = {
        {type="item", name="py-tank-10000", amount=1},
      },
    },
    ["py-tank-1500"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=91},
        {type="item", name="concrete", amount=22},
      },
      results = {
        {type="item", name="py-tank-1500", amount=1},
      },
    },
    ["py-tank-6500"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cellulose", amount=1},
        {type="item", name="py-check-valve", amount=17},
        {type="item", name="repair-pack", amount=1},
        {type="item", name="soot", amount=2},
        {type="item", name="titanium-plate", amount=21},
      },
      results = {
        {type="item", name="py-tank-6500", amount=1},
      },
    },
    ["py-tank-7000"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="hazard-concrete", amount=34},
        {type="item", name="limestone", amount=175},
        {type="item", name="py-tank-3000", amount=1},
        {type="item", name="steam-engine", amount=5},
        {type="item", name="titanium-plate", amount=49},
      },
      results = {
        {type="item", name="py-tank-7000", amount=1},
      },
    },
    ["py-tank-5000"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="cellulose", amount=14},
        {type="item", name="glass", amount=22},
        {type="item", name="py-tank-3000", amount=3},
        {type="item", name="py-tank-4000", amount=1},
      },
      results = {
        {type="item", name="py-tank-5000", amount=2},
      },
    },
    ["py-tank-9000"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="agar", amount=129},
        {type="item", name="empty-petri-dish", amount=239},
        {type="item", name="ore-aluminium", amount=150},
        {type="item", name="py-tank-1500", amount=2},
        {type="item", name="soil", amount=322},
      },
      results = {
        {type="item", name="py-tank-9000", amount=3},
      },
    },
    ["chloride-void-iron-oxide"] = {
      mode = "input-preserved-untransformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water-saline", amount=260},
        {type="item", name="iron-stick", amount=2},
      },
      results = {
        {type="item", name="iron-oxide", amount=1},
      },
    },
    ["extract-limestone-01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.75,
      ingredients = {
        {type="fluid", name="water", amount=361},
        {type="item", name="iron-ore", amount=6},
      },
      results = {
        {type="item", name="limestone", amount=14},
      },
    },
    ["gun-powder"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="water-saline", amount=83},
        {type="item", name="calcium-carbide", amount=4},
        {type="item", name="gravel", amount=23},
        {type="item", name="ore-lead", amount=3},
        {type="item", name="sulfur", amount=1},
        {type="item", name="wood", amount=24},
      },
      results = {
        {type="item", name="gunpowder", amount=10},
      },
    },
    ["tar-distilation"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 0.906805668915732,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=403},
      },
      results = {
        {type="fluid", name="aromatics", amount=86},
        {type="fluid", name="carbon-dioxide", amount=86},
        {type="fluid", name="flue-gas", amount=428},
        {type="item", name="rich-clay", amount=1},
      },
    },
    ["treated-wood"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="tar", amount=297},
      },
      results = {
        {type="item", name="treated-wood", amount=2},
      },
    },
    ["calcium-carbide"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="item", name="limestone", amount=16},
        {type="item", name="sand", amount=3},
        {type="item", name="soil", amount=5},
      },
      results = {
        {type="item", name="calcium-carbide", amount=14},
      },
    },
    ["sand-brick"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 0.95,
      ingredients = {
        {type="item", name="rich-clay", amount=34},
        {type="item", name="sand", amount=29},
      },
      results = {
        {type="item", name="stone-brick", amount=19},
      },
    },
    ["tar-to-carbolic"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 3.05207676752155,
      ingredients = {
        {type="fluid", name="tar", amount=189},
        {type="fluid", name="water", amount=4513},
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
      energy_required_multiplier = 1.3125,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=77},
        {type="fluid", name="pressured-water", amount=706},
        {type="fluid", name="water", amount=133},
        {type="item", name="moss", amount=3},
        {type="item", name="stone", amount=30},
      },
      results = {
        {type="item", name="moss", amount=24},
      },
    },
    ["Moss-1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.625,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=10},
        {type="fluid", name="water", amount=815},
      },
      results = {
        {type="item", name="moss", amount=5},
      },
    },
    ["aromatics-to-plastic"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="aromatics", amount=19},
        {type="fluid", name="water", amount=397},
        {type="item", name="coke", amount=3},
        {type="item", name="iron-ore", amount=17},
        {type="item", name="seaweed", amount=3},
      },
      results = {
        {type="item", name="plastic-bar", amount=1},
      },
    },
    ["log1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-ore", amount=1},
        {type="item", name="wood-seedling", amount=3},
      },
      results = {
        {type="item", name="log", amount=3},
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
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="moss", amount=4},
        {type="item", name="wood-seeds", amount=2},
      },
      results = {
        {type="item", name="wood-seedling", amount=3},
      },
    },
    ["log2"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="fluid", name="hydrogen", amount=170},
        {type="fluid", name="water", amount=139},
        {type="item", name="moss", amount=7},
        {type="item", name="wood-seedling", amount=1},
      },
      results = {
        {type="item", name="log", amount=5},
      },
    },
    ["log3"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="fluid", name="hydrogen", amount=129},
        {type="item", name="ash", amount=29},
        {type="item", name="coke", amount=41},
        {type="item", name="wood-seedling", amount=3},
      },
      results = {
        {type="item", name="log", amount=10},
      },
    },
    ["steel-plate"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coke", amount=6},
        {type="item", name="iron-ore", amount=13},
        {type="item", name="seaweed", amount=5},
      },
      results = {
        {type="item", name="steel-plate", amount=1},
      },
    },
    ["bio-container"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="coke", amount=8},
        {type="item", name="iron-plate", amount=12},
        {type="item", name="tin-plate", amount=4},
        {type="item", name="zinc-plate", amount=1},
      },
      results = {
        {type="item", name="bio-container", amount=2},
      },
    },
    ["cage"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-gear-wheel", amount=5},
        {type="item", name="iron-plate", amount=25},
        {type="item", name="tin-plate", amount=8},
      },
      results = {
        {type="item", name="cage", amount=1},
      },
    },
    ["empty-jerry-can"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="iron-plate", amount=24},
        {type="item", name="pipe", amount=2},
        {type="item", name="plastic-bar", amount=2},
      },
      results = {
        {type="item", name="empty-fuel-canister", amount=3},
      },
    },
    ["shotgun-shell"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=3},
        {type="item", name="kerogen", amount=8},
        {type="item", name="limestone", amount=21},
      },
      results = {
        {type="item", name="shotgun-shell", amount=3},
      },
    },
    ["firearm-magazine"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="gravel", amount=91},
        {type="item", name="iron-plate", amount=4},
        {type="item", name="ore-nickel", amount=17},
      },
      results = {
        {type="item", name="firearm-magazine", amount=4},
      },
    },
    ["fwf-mk01"] = {
      mode = "repaired-to-input",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=82},
        {type="item", name="copper-plate", amount=30},
        {type="item", name="iron-plate", amount=56},
        {type="item", name="lab", amount=5},
        {type="item", name="stone", amount=203},
      },
      results = {
        {type="item", name="fwf-mk01", amount=1},
      },
    },
    ["moss-farm-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="ash", amount=80},
        {type="item", name="assembling-machine-1", amount=1},
        {type="item", name="boiler", amount=9},
        {type="item", name="cellulose", amount=58},
        {type="item", name="coal-dust", amount=9},
        {type="item", name="copper-plate", amount=16},
        {type="item", name="inductor1", amount=13},
        {type="item", name="iron-stick", amount=135},
        {type="item", name="lab", amount=1},
        {type="item", name="limestone", amount=215},
        {type="item", name="native-flora", amount=97},
        {type="item", name="seaweed", amount=26},
        {type="item", name="soil-extractor-mk01", amount=2},
        {type="item", name="stone-furnace", amount=9},
        {type="item", name="treated-wood", amount=8},
      },
      results = {
        {type="item", name="moss-farm-mk01", amount=4},
      },
    },
    ["sap-extractor-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=34},
        {type="item", name="copper-plate", amount=13},
        {type="item", name="empty-planter-box", amount=3},
        {type="item", name="lab", amount=1},
        {type="item", name="seaweed", amount=94},
        {type="item", name="small-electric-pole", amount=1},
        {type="item", name="small-parts-01", amount=5},
        {type="item", name="soil", amount=36},
        {type="item", name="stone-brick", amount=51},
        {type="item", name="stone-furnace", amount=13},
        {type="item", name="wooden-chest", amount=13},
      },
      results = {
        {type="item", name="sap-extractor-mk01", amount=1},
      },
    },
    ["seaweed-crop-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=4},
        {type="item", name="bolts", amount=15},
        {type="item", name="iron-plate", amount=17},
        {type="item", name="lead-plate", amount=4},
        {type="item", name="tinned-cable", amount=38},
      },
      results = {
        {type="item", name="seaweed-crop-mk01", amount=1},
      },
    },
    ["moondrop-greenhouse-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=1},
        {type="item", name="copper-plate", amount=66},
        {type="item", name="iron-plate", amount=7},
        {type="item", name="ore-lead", amount=41},
        {type="item", name="ore-titanium", amount=475},
        {type="item", name="ore-zinc", amount=258},
        {type="item", name="stone-brick", amount=189},
        {type="item", name="stone-furnace", amount=75},
        {type="item", name="titanium-plate", amount=20},
        {type="item", name="transport-belt", amount=24},
      },
      results = {
        {type="item", name="moondrop-greenhouse-mk01", amount=2},
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
        {type="item", name="aluminium-plate", amount=34},
        {type="item", name="copper-cable", amount=323},
        {type="item", name="iron-plate", amount=37},
        {type="item", name="tin-plate", amount=6},
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
        {type="item", name="burner-mining-drill", amount=2},
        {type="item", name="iron-plate", amount=71},
        {type="item", name="wood", amount=192},
      },
      results = {
        {type="item", name="light-armor", amount=1},
      },
    },
    ["car"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="capacitor1", amount=138},
        {type="item", name="cellulose", amount=40},
        {type="item", name="iron-plate", amount=38},
        {type="item", name="lime", amount=35},
        {type="item", name="sodium-hydroxide", amount=6},
        {type="item", name="steam-engine", amount=18},
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
        {type="item", name="steam-engine", amount=7},
      },
      results = {
        {type="item", name="pump", amount=2},
      },
    },
    ["small-electric-pole-2"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coke", amount=35},
        {type="item", name="iron-stick", amount=1},
      },
      results = {
        {type="item", name="small-electric-pole", amount=3},
      },
    },
    ["py-gas-vent"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-ore", amount=213},
        {type="item", name="empty-planter-box", amount=4},
      },
      results = {
        {type="item", name="py-gas-vent", amount=1},
      },
    },
    ["py-sinkhole"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=3},
        {type="item", name="limestone", amount=42},
        {type="item", name="moss", amount=72},
        {type="item", name="native-flora", amount=1097},
      },
      results = {
        {type="item", name="py-sinkhole", amount=1},
      },
    },
    ["retorter"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="agar", amount=24},
        {type="item", name="bolts", amount=14},
        {type="item", name="copper-cable", amount=531},
        {type="item", name="iron-plate", amount=27},
        {type="item", name="small-parts-01", amount=9},
        {type="item", name="transport-belt", amount=66},
      },
      results = {
        {type="item", name="retorter", amount=2},
      },
    },
    ["steel-chest"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-plate", amount=38},
      },
      results = {
        {type="item", name="steel-chest", amount=1},
      },
    },
    ["tree"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="iron-stick", amount=16},
        {type="item", name="ore-nickel", amount=20},
        {type="item", name="sodium-alginate", amount=1},
        {type="item", name="stone-furnace", amount=2},
      },
      results = {
        {type="item", name="tree-mk01", amount=2},
      },
    },
    ["advanced-foundry-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="ash", amount=26},
        {type="item", name="boiler", amount=1},
        {type="item", name="copper-cable", amount=74},
        {type="item", name="empty-planter-box", amount=2},
        {type="item", name="iron-gear-wheel", amount=10},
        {type="item", name="iron-ore", amount=109},
        {type="item", name="pipe", amount=27},
        {type="item", name="soil", amount=26},
        {type="item", name="underground-belt", amount=3},
      },
      results = {
        {type="item", name="advanced-foundry-mk01", amount=2},
      },
    },
    ["borax-mine"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="advanced-foundry-mk01", amount=3},
        {type="item", name="pipe", amount=36},
        {type="item", name="py-check-valve", amount=30},
        {type="item", name="py-gas-vent", amount=1},
        {type="item", name="soil", amount=843},
        {type="item", name="submachine-gun", amount=3},
        {type="item", name="titanium-plate", amount=41},
      },
      results = {
        {type="item", name="borax-mine", amount=2},
      },
    },
    ["distilator"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="boiler", amount=20},
        {type="item", name="copper-cable", amount=14},
        {type="item", name="copper-ore", amount=285},
        {type="item", name="inductor1", amount=5},
        {type="item", name="lab", amount=1},
        {type="item", name="log", amount=13},
        {type="item", name="offshore-pump", amount=3},
        {type="item", name="pipe", amount=29},
        {type="item", name="stone-brick", amount=14},
        {type="item", name="wood", amount=20},
      },
      results = {
        {type="item", name="distilator", amount=2},
      },
    },
    ["fluid-drill-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=1},
        {type="item", name="boiler", amount=22},
        {type="item", name="distilator", amount=1},
        {type="item", name="inductor1", amount=19},
        {type="item", name="iron-plate", amount=88},
        {type="item", name="lab", amount=5},
      },
      results = {
        {type="item", name="fluid-drill-mk01", amount=3},
      },
    },
    ["gasifier"] = {
      mode = "repaired-to-input",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="bolts", amount=46},
        {type="item", name="burner-mining-drill", amount=18},
        {type="item", name="distilator", amount=2},
        {type="item", name="inductor1", amount=11},
        {type="item", name="iron-stick", amount=113},
        {type="item", name="offshore-pump", amount=9},
      },
      results = {
        {type="item", name="gasifier", amount=3},
      },
    },
    ["glassworks-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ash", amount=45},
        {type="item", name="burner-inserter", amount=1},
        {type="item", name="copper-plate", amount=25},
        {type="item", name="inductor1", amount=3},
        {type="item", name="iron-stick", amount=76},
        {type="item", name="soil-extractor-mk01", amount=1},
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
        {type="item", name="copper-cable", amount=31},
        {type="item", name="iron-gear-wheel", amount=3},
        {type="item", name="soil", amount=43},
        {type="item", name="stone-brick", amount=30},
        {type="item", name="stone-furnace", amount=3},
        {type="item", name="transport-belt", amount=26},
      },
      results = {
        {type="item", name="hpf", amount=1},
      },
    },
    ["jaw-crusher"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bolts", amount=58},
        {type="item", name="burner-inserter", amount=4},
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="steel-plate", amount=76},
      },
      results = {
        {type="item", name="jaw-crusher", amount=2},
      },
    },
    ["solid-separator"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=4},
        {type="item", name="copper-plate", amount=371},
        {type="item", name="iron-plate", amount=230},
        {type="item", name="pipe", amount=138},
        {type="item", name="small-parts-01", amount=85},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="transport-belt", amount=14},
        {type="item", name="wood", amount=1634},
      },
      results = {
        {type="item", name="solid-separator", amount=3},
      },
    },
    ["tar-processing-unit"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bolts", amount=70},
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="inductor1", amount=12},
        {type="item", name="iron-stick", amount=68},
        {type="item", name="ore-zinc", amount=22},
        {type="item", name="soil", amount=1957},
      },
      results = {
        {type="item", name="tar-processing-unit", amount=2},
      },
    },
    ["washer"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=1},
        {type="item", name="copper-cable", amount=46},
        {type="item", name="inductor1", amount=3},
        {type="item", name="iron-gear-wheel", amount=9},
        {type="item", name="lab", amount=1},
        {type="item", name="seaweed", amount=24},
        {type="item", name="small-electric-pole", amount=7},
        {type="item", name="soil", amount=139},
        {type="item", name="stone-brick", amount=11},
        {type="item", name="stone-furnace", amount=76},
        {type="item", name="transport-belt", amount=11},
      },
      results = {
        {type="item", name="washer", amount=2},
      },
    },
    ["evaporator"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="advanced-foundry-mk01", amount=4},
        {type="item", name="bolts", amount=26},
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="inductor1", amount=14},
        {type="item", name="iron-plate", amount=78},
        {type="item", name="iron-stick", amount=78},
        {type="item", name="lab", amount=1},
        {type="item", name="soil", amount=720},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="submachine-gun", amount=1},
        {type="item", name="titanium-plate", amount=16},
      },
      results = {
        {type="item", name="evaporator", amount=1},
      },
    },
    ["quenching-tower"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bolts", amount=39},
        {type="item", name="coal", amount=58},
        {type="item", name="iron-ore", amount=62},
        {type="item", name="lab", amount=6},
        {type="item", name="limestone", amount=453},
        {type="item", name="offshore-pump", amount=7},
        {type="item", name="small-electric-pole", amount=134},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="stone-brick", amount=266},
        {type="item", name="transport-belt", amount=13},
      },
      results = {
        {type="item", name="quenching-tower", amount=2},
      },
    },
    ["clay-pit-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=6},
        {type="item", name="iron-chest", amount=3},
        {type="item", name="limestone", amount=429},
        {type="item", name="moss", amount=49},
        {type="item", name="native-flora", amount=747},
        {type="item", name="washer", amount=1},
        {type="item", name="wood", amount=47},
        {type="item", name="wooden-chest", amount=56},
      },
      results = {
        {type="item", name="clay-pit-mk01", amount=3},
      },
    },
    ["electronics-factory-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="coal-dust", amount=71},
        {type="item", name="distilator", amount=3},
        {type="item", name="iron-plate", amount=19},
        {type="item", name="offshore-pump", amount=5},
        {type="item", name="ore-titanium", amount=187},
        {type="item", name="soil-extractor-mk01", amount=5},
        {type="item", name="stone", amount=95},
        {type="item", name="stone-wall", amount=157},
      },
      results = {
        {type="item", name="electronics-factory-mk01", amount=2},
      },
    },
    ["pulp-mill-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bolts", amount=168},
        {type="item", name="coal", amount=38},
        {type="item", name="iron-ore", amount=265},
        {type="item", name="lab", amount=3},
        {type="item", name="soil-extractor-mk01", amount=3},
        {type="item", name="transport-belt", amount=4},
      },
      results = {
        {type="item", name="pulp-mill-mk01", amount=2},
      },
    },
    ["chipshooter-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=1},
        {type="item", name="boiler", amount=13},
        {type="item", name="bolts", amount=237},
        {type="item", name="copper-cable", amount=104},
        {type="item", name="formica", amount=29},
        {type="item", name="hpf", amount=2},
        {type="item", name="iron-gear-wheel", amount=30},
        {type="item", name="landfill", amount=13},
        {type="item", name="lead-plate", amount=21},
        {type="item", name="pipe", amount=163},
        {type="item", name="small-parts-01", amount=81},
        {type="item", name="soil", amount=352},
        {type="item", name="tin-plate", amount=21},
      },
      results = {
        {type="item", name="chipshooter-mk01", amount=1},
      },
    },
    ["pcb-factory-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=106},
        {type="item", name="iron-gear-wheel", amount=29},
        {type="item", name="log", amount=129},
        {type="item", name="retorter", amount=1},
        {type="item", name="soil-extractor-mk01", amount=14},
        {type="item", name="vacuum-pump-mk01", amount=1},
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
      energy_required_multiplier = 1.04,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="sand", amount=7},
        {type="item", name="stone", amount=7},
      },
      results = {
        {type="fluid", name="water-saline", amount=52},
      },
    },
    ["sulfur-void-tar"] = {
      mode = "input-preserved-untransformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=50},
        {type="item", name="ore-quartz", amount=1},
        {type="item", name="sulfur", amount=1},
      },
      results = {
        {type="fluid", name="tar", amount=50},
      },
    },
    ["saline-water"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.26,
      ingredients = {
        {type="fluid", name="water", amount=72},
        {type="item", name="stone", amount=2},
      },
      results = {
        {type="fluid", name="water-saline", amount=13},
      },
    },
    ["biofactory-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="concrete", amount=29},
        {type="item", name="py-tank-3000", amount=3},
        {type="item", name="sodium-hydroxide", amount=496},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="steel-plate", amount=15},
        {type="item", name="stone-brick", amount=163},
        {type="item", name="tin-plate", amount=16},
      },
      results = {
        {type="item", name="biofactory-mk01", amount=1},
      },
    },
    ["botanical-nursery"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="burner-inserter", amount=3},
        {type="item", name="capacitor1", amount=15},
        {type="item", name="coal-dust", amount=5},
        {type="item", name="concrete", amount=46},
        {type="item", name="glass", amount=12},
        {type="item", name="lab", amount=5},
        {type="item", name="ore-titanium", amount=113},
        {type="item", name="soil-extractor-mk01", amount=3},
        {type="item", name="stone-wall", amount=37},
        {type="item", name="titanium-plate", amount=20},
        {type="item", name="washer", amount=1},
      },
      results = {
        {type="item", name="botanical-nursery", amount=2},
      },
    },
    ["creature-chamber-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=38},
        {type="item", name="concrete", amount=775},
        {type="item", name="flora-collector-mk01", amount=13},
        {type="item", name="graphite", amount=267},
        {type="item", name="iron-plate", amount=147},
        {type="item", name="micro-mine-mk01", amount=11},
        {type="item", name="py-tank-1500", amount=2},
        {type="item", name="resistor1", amount=1310},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="stone-brick", amount=517},
        {type="item", name="tin-plate", amount=174},
        {type="item", name="treated-wood", amount=35},
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
        {type="item", name="aromatics-barrel", amount=15},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="fawogae-substrate", amount=23},
        {type="item", name="lead-plate", amount=33},
        {type="item", name="pipe", amount=82},
      },
      results = {
        {type="item", name="incubator-mk01", amount=1},
      },
    },
    ["micro-mine-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="capacitor1", amount=32},
        {type="item", name="concrete", amount=42},
        {type="item", name="fawogae-substrate", amount=13},
        {type="item", name="pipe", amount=173},
        {type="item", name="small-lamp", amount=6},
        {type="item", name="tar-processing-unit", amount=2},
        {type="item", name="titanium-plate", amount=24},
      },
      results = {
        {type="item", name="micro-mine-mk01", amount=3},
      },
    },
    ["rc-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=15},
        {type="item", name="assembling-machine-1", amount=3},
        {type="item", name="battery-mk00", amount=1},
        {type="item", name="bolts", amount=244},
        {type="item", name="copper-cable", amount=295},
        {type="item", name="iron-gear-wheel", amount=79},
        {type="item", name="landfill", amount=35},
        {type="item", name="lead-plate", amount=34},
        {type="item", name="pipe", amount=1347},
        {type="item", name="tin-plate", amount=170},
      },
      results = {
        {type="item", name="rc-mk01", amount=1},
      },
    },
    ["genlab-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=62},
        {type="item", name="concrete", amount=782},
        {type="item", name="flora-collector-mk01", amount=5},
        {type="item", name="iron-gear-wheel", amount=8},
        {type="item", name="iron-plate", amount=50},
        {type="item", name="landfill", amount=3},
        {type="item", name="lead-plate", amount=5},
        {type="item", name="pipe", amount=43},
        {type="item", name="py-tank-1500", amount=2},
        {type="item", name="sodium-hydroxide", amount=11},
        {type="item", name="stone-brick", amount=204},
        {type="item", name="tin-plate", amount=101},
        {type="item", name="treated-wood", amount=14},
      },
      results = {
        {type="item", name="genlab-mk01", amount=1},
      },
    },
    ["research-center-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="advanced-foundry-mk01", amount=2},
        {type="item", name="calcium-carbide", amount=533},
        {type="item", name="fluid-drill-mk01", amount=2},
        {type="item", name="poorman-wood-fence", amount=110},
        {type="item", name="soil-extractor-mk01", amount=4},
        {type="item", name="steam-engine", amount=72},
      },
      results = {
        {type="item", name="research-center-mk01", amount=1},
      },
    },
    ["slaughterhouse-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boiler", amount=139},
        {type="item", name="copper-cable", amount=121},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="glass", amount=149},
        {type="item", name="gun-turret", amount=1},
        {type="item", name="inductor1", amount=1058},
        {type="item", name="lead-plate", amount=25},
        {type="item", name="steel-plate", amount=23},
      },
      results = {
        {type="item", name="slaughterhouse-mk01", amount=1},
      },
    },
    ["gate"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cellulose", amount=1},
        {type="item", name="gravel", amount=8},
        {type="item", name="moss", amount=5},
        {type="item", name="pipe", amount=7},
        {type="item", name="planter-box", amount=1},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="titanium-plate", amount=9},
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
        {type="item", name="copper-ore", amount=10},
      },
      results = {
        {type="item", name="poorman-wood-fence", amount=1},
      },
    },
    ["stone-wall"] = {
      mode = "kept-pruned-transformed",
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
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=2},
        {type="item", name="copper-cable", amount=171},
        {type="item", name="fluid-drill-mk01", amount=2},
        {type="item", name="glass", amount=1738},
        {type="item", name="glassworks-mk01", amount=1},
        {type="item", name="pipe", amount=77},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="steel-plate", amount=87},
        {type="item", name="titanium-plate", amount=340},
        {type="item", name="wpu-mk01", amount=2},
        {type="item", name="zinc-plate", amount=21},
      },
      results = {
        {type="item", name="automated-screener-mk01", amount=2},
      },
    },
    ["vacuum-pump-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=1},
        {type="item", name="copper-plate", amount=62},
        {type="item", name="ore-zinc", amount=30},
        {type="item", name="transport-belt", amount=3},
      },
      results = {
        {type="item", name="vacuum-pump-mk01", amount=1},
      },
    },
    ["bio-sample"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="syngas", amount=1184},
        {type="item", name="barrel", amount=2},
        {type="item", name="iron-ore", amount=15},
        {type="item", name="saps", amount=2},
      },
      results = {
        {type="item", name="bio-sample", amount=2},
      },
    },
    ["moss-gen"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="moss", amount=38},
        {type="item", name="petri-dish", amount=4},
        {type="item", name="petri-dish-bacteria", amount=3},
      },
      results = {
        {type="item", name="moss-gen", amount=3},
      },
    },
    ["earth-generic-sample"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bio-sample", amount=4},
        {type="item", name="coal", amount=45},
        {type="item", name="iron-chest", amount=1},
        {type="item", name="limestone", amount=38},
        {type="item", name="pipe", amount=21},
        {type="item", name="small-electric-pole", amount=1},
        {type="item", name="sodium-hydroxide", amount=111},
        {type="item", name="steam-engine", amount=2},
        {type="item", name="stone-brick", amount=42},
      },
      results = {
        {type="item", name="earth-generic-sample", amount=1},
      },
    },
    ["vrauks-cocoon-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="moss", amount=11},
        {type="item", name="stone-wall", amount=1},
        {type="item", name="water-barrel", amount=4},
      },
      results = {
        {type="item", name="barrel", amount=4},
        {type="item", name="cocoon", amount=5},
      },
    },
    ["vrauks-codex"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="lead-plate", amount=3},
        {type="item", name="pipe", amount=17},
        {type="item", name="steam-engine", amount=8},
        {type="item", name="steel-plate", amount=14},
        {type="item", name="titanium-plate", amount=13},
      },
      results = {
        {type="item", name="vrauks-codex", amount=1},
      },
    },
    ["vrauks"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="earth-generic-sample", amount=3},
        {type="item", name="iron-gear-wheel", amount=25},
        {type="item", name="log", amount=113},
        {type="item", name="petri-dish-bacteria", amount=17},
        {type="item", name="sodium-hydroxide", amount=30},
        {type="item", name="soil-extractor-mk01", amount=4},
        {type="item", name="vrauks-codex", amount=2},
      },
      results = {
        {type="item", name="vrauks", amount=2},
      },
    },
    ["vrauks-paddock-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="fawogae-substrate", amount=6},
        {type="item", name="lead-plate", amount=26},
        {type="item", name="pipe", amount=105},
        {type="item", name="py-check-valve", amount=3},
        {type="item", name="refined-concrete", amount=9},
        {type="item", name="small-lamp", amount=5},
        {type="item", name="soil-extractor-mk01", amount=5},
        {type="item", name="tin-plate", amount=55},
        {type="item", name="transport-belt", amount=9},
      },
      results = {
        {type="item", name="vrauks-paddock-mk01", amount=2},
      },
    },
    ["vrauks-1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cocoon", amount=9},
        {type="item", name="resistor1", amount=1},
        {type="item", name="scrude-barrel", amount=3},
      },
      results = {
        {type="item", name="barrel", amount=3},
        {type="item", name="vrauks", amount=2},
      },
    },
    ["fluidavan"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="advanced-foundry-mk01", amount=4},
        {type="item", name="bio-container", amount=5},
        {type="item", name="brain", amount=13},
        {type="item", name="burner-inserter", amount=1},
        {type="item", name="cage", amount=2},
        {type="item", name="capacitor1", amount=25},
        {type="item", name="carbolic-oil-barrel", amount=25},
        {type="item", name="meat", amount=17},
        {type="item", name="tar-canister", amount=5},
        {type="item", name="vrauks", amount=1},
      },
      results = {
        {type="item", name="fluidavan", amount=1},
      },
    },
    ["caravan"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cage", amount=6},
        {type="item", name="carbolic-oil-barrel", amount=16},
        {type="item", name="tar-canister", amount=16},
        {type="item", name="vrauks", amount=1},
      },
      results = {
        {type="item", name="caravan", amount=1},
      },
    },
    ["concrete"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="item", name="calcium-carbide", amount=8},
        {type="item", name="gravel", amount=6},
        {type="item", name="raw-coal", amount=4},
        {type="item", name="stone", amount=32},
        {type="item", name="stone-wall", amount=1},
      },
      results = {
        {type="item", name="concrete", amount=6},
      },
    },
    ["stone-brick-2"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="pitch", amount=38},
        {type="fluid", name="water", amount=103},
        {type="item", name="stone", amount=17},
      },
      results = {
        {type="item", name="stone-brick", amount=6},
      },
    },
    ["hazard-concrete"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="stone-brick", amount=38},
      },
      results = {
        {type="item", name="hazard-concrete", amount=10},
      },
    },
    ["refined-concrete"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="graphite", amount=3},
        {type="item", name="iron-gear-wheel", amount=2},
        {type="item", name="iron-plate", amount=2},
        {type="item", name="stone-brick", amount=15},
      },
      results = {
        {type="item", name="refined-concrete", amount=8},
      },
    },
    ["landfill"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="gravel", amount=65},
        {type="item", name="inductor1", amount=2},
        {type="item", name="sodium-alginate", amount=3},
      },
      results = {
        {type="item", name="landfill", amount=2},
      },
    },
    ["refined-hazard-concrete"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.7,
      ingredients = {
        {type="item", name="iron-ore", amount=74},
        {type="item", name="stone-brick", amount=11},
      },
      results = {
        {type="item", name="refined-hazard-concrete", amount=7},
      },
    },
    ["outpost"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="log", amount=3},
        {type="item", name="steam-engine", amount=4},
        {type="item", name="stone-brick", amount=71},
      },
      results = {
        {type="item", name="outpost", amount=1},
      },
    },
    ["outpost-fluid"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="empty-petri-dish", amount=1},
        {type="item", name="inductor1", amount=2},
        {type="item", name="log", amount=5},
        {type="item", name="offshore-pump", amount=20},
        {type="item", name="ore-quartz", amount=1628},
        {type="item", name="small-lamp", amount=2},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="stone-brick", amount=139},
        {type="item", name="stone-furnace", amount=84},
        {type="item", name="underground-belt", amount=3},
      },
      results = {
        {type="item", name="outpost-fluid", amount=2},
      },
    },
    ["data-array"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=126},
        {type="item", name="coal-dust", amount=233},
        {type="item", name="fluid-drill-mk01", amount=4},
        {type="item", name="hazard-concrete", amount=403},
        {type="item", name="inductor1", amount=968},
        {type="item", name="iron-plate", amount=135},
        {type="item", name="lead-plate", amount=236},
        {type="item", name="pipe", amount=105},
        {type="item", name="raw-coal", amount=1283},
        {type="item", name="sand", amount=1138},
        {type="item", name="steam-engine", amount=2},
        {type="item", name="transport-belt", amount=70},
        {type="item", name="treated-wood", amount=11},
      },
      results = {
        {type="item", name="data-array", amount=2},
      },
    },
    ["creamy-latex"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.49,
      ingredients = {
        {type="item", name="limestone", amount=2},
        {type="item", name="saps", amount=2},
        {type="item", name="stone-brick", amount=3},
      },
      results = {
        {type="fluid", name="creamy-latex", amount=149},
      },
    },
    ["sodium-alginate"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=125},
        {type="item", name="moss", amount=3},
        {type="item", name="wood", amount=3},
      },
      results = {
        {type="item", name="sodium-alginate", amount=1},
      },
    },
    ["latex-slab"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="flue-gas", amount=521},
        {type="fluid", name="oxygen", amount=244},
        {type="item", name="stone-furnace", amount=18},
        {type="item", name="wood-seeds", amount=4},
      },
      results = {
        {type="item", name="latex-slab", amount=2},
      },
    },
    ["sap-seeds"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="stone-furnace", amount=3},
      },
      results = {
        {type="item", name="sap-seeds", amount=1},
      },
    },
    ["latex"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="oxygen", amount=336},
        {type="fluid", name="pressured-water", amount=303},
        {type="item", name="cellulose", amount=4},
        {type="item", name="lime", amount=16},
        {type="item", name="limestone", amount=5},
      },
      results = {
        {type="item", name="latex", amount=2},
      },
    },
    ["sap-tree"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="planter-box", amount=2},
        {type="item", name="sodium-alginate", amount=7},
      },
      results = {
        {type="item", name="sap-tree", amount=2},
      },
    },
    ["py-check-valve"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="iron-plate", amount=8},
        {type="item", name="pipe", amount=2},
        {type="item", name="small-parts-01", amount=3},
      },
      results = {
        {type="item", name="py-check-valve", amount=2},
      },
    },
    ["py-underflow-valve"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="iron-plate", amount=4},
        {type="item", name="moss", amount=161},
        {type="item", name="pipe", amount=36},
        {type="item", name="soil", amount=38},
        {type="item", name="wooden-chest", amount=33},
      },
      results = {
        {type="item", name="py-underflow-valve", amount=2},
      },
    },
    ["py-overflow-valve"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cellulose", amount=1},
        {type="item", name="planter-box", amount=1},
        {type="item", name="titanium-plate", amount=21},
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
        {type="item", name="coal", amount=8},
        {type="item", name="pipe", amount=10},
        {type="item", name="steam-engine", amount=4},
        {type="item", name="stone-brick", amount=20},
      },
      results = {
        {type="item", name="py-local-radar", amount=1},
      },
    },
    ["radar"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="firearm-magazine", amount=5},
        {type="item", name="iron-stick", amount=12},
        {type="item", name="ore-chromium", amount=74},
        {type="item", name="pipe", amount=11},
        {type="item", name="small-parts-01", amount=88},
        {type="item", name="titanium-plate", amount=127},
      },
      results = {
        {type="item", name="radar", amount=2},
      },
    },
    ["battery-mk00"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=551},
        {type="item", name="coal-dust", amount=18},
        {type="item", name="copper-ore", amount=7},
        {type="item", name="lead-plate", amount=3},
        {type="item", name="wooden-chest", amount=23},
      },
      results = {
        {type="item", name="battery-mk00", amount=1},
      },
    },
    ["electrolyzer-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=9},
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="pipe", amount=31},
        {type="item", name="titanium-plate", amount=194},
        {type="item", name="wpu-mk01", amount=7},
        {type="item", name="zinc-plate", amount=99},
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
        {type="item", name="agar", amount=6},
        {type="item", name="fluid-drill-mk01", amount=2},
        {type="item", name="hazard-concrete", amount=71},
        {type="item", name="lead-plate", amount=105},
        {type="item", name="lime", amount=71},
        {type="item", name="pipe", amount=46},
        {type="item", name="raw-coal", amount=225},
        {type="item", name="sand", amount=511},
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
        {type="item", name="aluminium-plate", amount=5},
        {type="item", name="lead-plate", amount=2},
        {type="item", name="pipe", amount=4},
        {type="item", name="steel-plate", amount=28},
      },
      results = {
        {type="item", name="inserter", amount=1},
      },
    },
    ["methane-co2"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.475,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=179},
        {type="fluid", name="water", amount=263},
        {type="item", name="moondrop-seeds", amount=1},
      },
      results = {
        {type="fluid", name="methane", amount=59},
      },
    },
    ["methanal"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.72,
      ingredients = {
        {type="fluid", name="hydrogen", amount=349},
        {type="item", name="copper-ore", amount=43},
      },
      results = {
        {type="fluid", name="methanal", amount=36},
      },
    },
    ["capacitor1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="calcium-carbide", amount=1},
        {type="item", name="glass", amount=2},
        {type="item", name="graphite", amount=2},
        {type="item", name="lead-plate", amount=2},
        {type="item", name="soil", amount=58},
      },
      results = {
        {type="item", name="capacitor1", amount=6},
      },
    },
    ["inductor1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.8,
      ingredients = {
        {type="item", name="aluminium-plate", amount=3},
        {type="item", name="graphite", amount=3},
        {type="item", name="ore-lead", amount=24},
      },
      results = {
        {type="item", name="inductor1", amount=9},
      },
    },
    ["resistor1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="calcium-carbide", amount=3},
        {type="item", name="glass", amount=1},
        {type="item", name="soil", amount=26},
      },
      results = {
        {type="item", name="resistor1", amount=3},
      },
    },
    ["formica"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="methanal", amount=28},
        {type="item", name="ash", amount=21},
        {type="item", name="raw-fiber", amount=6},
        {type="item", name="tailings-dust", amount=6},
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
        {type="fluid", name="water", amount=115},
        {type="item", name="copper-ore", amount=8},
        {type="item", name="lime", amount=3},
        {type="item", name="pipe", amount=11},
      },
      results = {
        {type="item", name="vacuum-tube", amount=3},
      },
    },
    ["pcb1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="formica", amount=2},
        {type="item", name="iron-plate", amount=5},
      },
      results = {
        {type="item", name="pcb1", amount=1},
      },
    },
    ["electronic-circuit"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="battery-mk00", amount=1},
        {type="item", name="capacitor1", amount=2},
        {type="item", name="formica", amount=4},
        {type="item", name="inductor1", amount=1},
        {type="item", name="iron-plate", amount=4},
        {type="item", name="lead-plate", amount=5},
        {type="item", name="vacuum-tube", amount=3},
      },
      results = {
        {type="item", name="electronic-circuit", amount=3},
      },
    },
    ["olefin-plant"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="agar", amount=150},
        {type="item", name="aluminium-plate", amount=12},
        {type="item", name="empty-planter-box", amount=36},
        {type="item", name="inductor1", amount=12},
        {type="item", name="ore-aluminium", amount=175},
        {type="item", name="py-tank-1500", amount=3},
        {type="item", name="steam-engine", amount=28},
        {type="item", name="storage-tank", amount=3},
        {type="item", name="tinned-cable", amount=59},
      },
      results = {
        {type="item", name="olefin-plant", amount=1},
      },
    },
    ["reformer-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="advanced-foundry-mk01", amount=3},
        {type="item", name="calcium-carbide", amount=845},
        {type="item", name="concrete", amount=1049},
        {type="item", name="hazard-concrete", amount=35},
        {type="item", name="poorman-wood-fence", amount=68},
        {type="item", name="sand", amount=100},
        {type="item", name="soil-extractor-mk01", amount=3},
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
        {type="item", name="firearm-magazine", amount=1},
        {type="item", name="iron-stick", amount=10},
        {type="item", name="small-parts-01", amount=24},
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
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="empty-petri-dish", amount=2},
        {type="item", name="fawogae-substrate", amount=42},
        {type="item", name="moondrop-codex", amount=1},
        {type="item", name="planter-box", amount=1},
      },
      results = {
        {type="item", name="moondrop", amount=6},
      },
    },
    ["moondrop-seeds"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="anthracene-oil", amount=7},
        {type="item", name="moondrop", amount=4},
      },
      results = {
        {type="item", name="moondrop", amount=2},
        {type="item", name="moondrop-seeds", amount=6},
      },
    },
    ["multiblade-turbine-mk01"] = {
      mode = "input-preserved-untransformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="coal", amount=95},
        {type="item", name="fish", amount=11},
        {type="item", name="limestone", amount=564},
        {type="item", name="poorman-wood-fence", amount=20},
        {type="item", name="shotgun", amount=3},
        {type="item", name="stone-brick", amount=42},
      },
      results = {
        {type="item", name="multiblade-turbine-mk01", amount=2},
      },
    },
    ["py-science-pack-1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.666666666666667,
      ingredients = {
        {type="item", name="fawogae-substrate", amount=8},
        {type="item", name="stopper", amount=7},
      },
      results = {
        {type="item", name="py-science-pack-1", amount=2},
      },
    },
    ["agar"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=1043},
        {type="item", name="limestone", amount=5},
      },
      results = {
        {type="item", name="agar", amount=1},
      },
    },
    ["cellulose-00"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="limestone", amount=8},
        {type="item", name="seaweed", amount=3},
        {type="item", name="wood", amount=11},
      },
      results = {
        {type="item", name="cellulose", amount=2},
      },
    },
    ["cellulose-02"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="gravel", amount=40},
        {type="item", name="wood", amount=5},
      },
      results = {
        {type="item", name="cellulose", amount=2},
      },
    },
    ["coke-co2"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.35,
      ingredients = {
        {type="item", name="limestone", amount=1},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=28},
      },
    },
    ["lime"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.29290712455877,
      ingredients = {
        {type="fluid", name="water", amount=91},
        {type="item", name="ceramic", amount=1},
        {type="item", name="coal", amount=11},
        {type="item", name="soil", amount=16},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=125},
        {type="item", name="lime", amount=13},
      },
    },
    ["dried-meat-01"] = {
      mode = "kept-pruned-transformed",
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="petri-dish", amount=1},
      },
      results = {
        {type="item", name="petri-dish-bacteria", amount=1},
      },
    },
    ["fawogae-substrate"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.9,
      ingredients = {
        {type="item", name="cellulose", amount=3},
        {type="item", name="moss", amount=3},
        {type="item", name="petri-dish", amount=2},
      },
      results = {
        {type="item", name="fawogae-substrate", amount=9},
      },
    },
    ["empty-petri-dish"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="fluid", name="syngas", amount=386},
        {type="item", name="tin-plate", amount=2},
      },
      results = {
        {type="item", name="empty-petri-dish", amount=3},
      },
    },
    ["sand-void-glass"] = {
      mode = "input-preserved-untransformed",
      science_level = 1,
      energy_required_multiplier = 1.1,
      ingredients = {
        {type="item", name="coke", amount=2},
        {type="item", name="gravel", amount=9},
      },
      results = {
        {type="fluid", name="molten-glass", amount=11},
      },
    },
    ["stopper"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.75,
      ingredients = {
        {type="fluid", name="methanal", amount=61},
        {type="item", name="ash", amount=6},
        {type="item", name="coal", amount=3},
        {type="item", name="latex", amount=2},
        {type="item", name="raw-fiber", amount=2},
        {type="item", name="tailings-dust", amount=13},
      },
      results = {
        {type="item", name="stopper", amount=7},
      },
    },
    ["flask"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="acidgas", amount=13},
        {type="fluid", name="steam", amount=85},
        {type="fluid", name="water", amount=2382},
        {type="item", name="coal-dust", amount=9},
        {type="item", name="stopper", amount=2},
        {type="item", name="wooden-chest", amount=4},
      },
      results = {
        {type="item", name="flask", amount=2},
      },
    },
    ["petri-dish"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="cellulose", amount=2},
        {type="item", name="empty-planter-box", amount=5},
      },
      results = {
        {type="item", name="petri-dish", amount=3},
      },
    },
    ["scrude-refining"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.971777777777778,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=181},
        {type="fluid", name="water", amount=3199},
      },
      results = {
        {type="fluid", name="condensates", amount=243},
        {type="fluid", name="heavy-oil", amount=97},
        {type="fluid", name="light-oil", amount=146},
      },
    },
    ["tar-refining"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.565681053008835,
      ingredients = {
        {type="fluid", name="steam", amount=97},
        {type="fluid", name="water", amount=223},
      },
      results = {
        {type="fluid", name="anthracene-oil", amount=42},
        {type="fluid", name="creosote", amount=14},
        {type="fluid", name="middle-oil", amount=17},
        {type="fluid", name="pitch", amount=79},
      },
    },
    ["heavy-oil-to-kerosene"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.575,
      ingredients = {
        {type="fluid", name="oxygen", amount=785},
        {type="item", name="soil", amount=43},
      },
      results = {
        {type="fluid", name="kerosene", amount=63},
      },
    },
    ["pitch-refining"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.929311376550432,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=152},
        {type="fluid", name="pressured-air", amount=2107},
        {type="fluid", name="water", amount=472},
      },
      results = {
        {type="fluid", name="anthracene-oil", amount=28},
        {type="fluid", name="hydrogen", amount=9},
        {type="fluid", name="light-oil", amount=19},
        {type="fluid", name="naphthalene-oil", amount=19},
        {type="item", name="coke", amount=9},
      },
    },
    ["tar-refining-tops"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.12,
      ingredients = {
        {type="fluid", name="hydrogen", amount=308},
        {type="fluid", name="pitch", amount=357},
        {type="item", name="coke", amount=13},
        {type="item", name="iron-stick", amount=4},
      },
      results = {
        {type="fluid", name="carbolic-oil", amount=56},
        {type="fluid", name="light-oil", amount=56},
        {type="fluid", name="naphthalene-oil", amount=112},
      },
    },
    ["anthracene-gasoline-cracking"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.661410896095453,
      ingredients = {
        {type="fluid", name="anthracene-oil", amount=21},
        {type="fluid", name="muddy-sludge", amount=48},
      },
      results = {
        {type="fluid", name="gasoline", amount=14},
        {type="item", name="coke", amount=3},
      },
    },
    ["carbolic-oil-creosote"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="anthracene-oil", amount=221},
        {type="fluid", name="tar", amount=193},
      },
      results = {
        {type="fluid", name="creosote", amount=50},
      },
    },
    ["kerogen-extraction"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.848,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=173},
        {type="item", name="processed-iron-ore", amount=9},
      },
      results = {
        {type="fluid", name="scrude", amount=212},
      },
    },
    ["light-oil-aromatics"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.43,
      ingredients = {
        {type="fluid", name="light-oil", amount=21},
      },
      results = {
        {type="fluid", name="aromatics", amount=21},
        {type="fluid", name="gasoline", amount=11},
      },
    },
    ["naphthalene-oil-creosote"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.433333333333333,
      ingredients = {
        {type="fluid", name="syngas", amount=157},
      },
      results = {
        {type="fluid", name="creosote", amount=13},
      },
    },
    ["barrel"] = {
      mode = "input-preserved-untransformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-plate", amount=5},
      },
      results = {
        {type="item", name="barrel", amount=1},
      },
    },
    ["barrel-machine-mk01"] = {
      mode = "input-preserved-untransformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=18},
        {type="item", name="burner-mining-drill", amount=3},
        {type="item", name="copper-plate", amount=27},
        {type="item", name="empty-petri-dish", amount=4},
        {type="item", name="hazard-concrete", amount=7},
        {type="item", name="iron-oxide", amount=35},
      },
      results = {
        {type="item", name="barrel-machine-mk01", amount=1},
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
        {type="fluid", name="hydrogen", amount=2168},
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
        {type="item", name="sodium-hydroxide", amount=10},
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
        {type="fluid", name="anthracene-oil", amount=316},
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
        {type="item", name="capacitor1", amount=24},
        {type="item", name="concrete", amount=10},
        {type="item", name="inductor1", amount=3},
        {type="item", name="iron-plate", amount=28},
        {type="item", name="lab", amount=1},
        {type="item", name="lead-plate", amount=30},
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
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="item", name="biomass", amount=63},
      },
      results = {
        {type="item", name="raw-coal", amount=5},
      },
    },
    ["biomass-molten-salt-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.2225,
      ingredients = {
        {type="fluid", name="fish-oil", amount=83},
        {type="fluid", name="hot-air", amount=10399},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=489},
      },
    },
    ["chitin-to-geothermal-water"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.48,
      ingredients = {
        {type="fluid", name="water", amount=1005},
        {type="item", name="guts", amount=4},
      },
      results = {
        {type="fluid", name="geothermal-water", amount=24},
      },
    },
    ["he-01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 0.420067897305326,
      ingredients = {
        {type="fluid", name="hot-molten-salt", amount=85},
      },
      results = {
        {type="fluid", name="molten-salt", amount=84},
        {type="fluid", name="pressured-steam", amount=32},
      },
    },
    ["molten-salt"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.01,
      ingredients = {
        {type="item", name="moondrop", amount=14},
        {type="item", name="sand", amount=10},
      },
      results = {
        {type="fluid", name="molten-salt", amount=101},
      },
    },
    ["coal-molten-salt-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.974,
      ingredients = {
        {type="fluid", name="fish-oil", amount=387},
        {type="fluid", name="hot-molten-salt", amount=32},
        {type="item", name="iron-plate", amount=4},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=519},
      },
    },
    ["geo-he-00"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.423333333333333,
      ingredients = {
        {type="fluid", name="water", amount=183},
      },
      results = {
        {type="fluid", name="steam", amount=127},
      },
    },
    ["oil-molten-salt-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.766,
      ingredients = {
        {type="fluid", name="condensates", amount=7236},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=383},
      },
    },
    ["borax-washing"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 0.403077324861045,
      ingredients = {
        {type="fluid", name="steam", amount=41},
        {type="item", name="calcium-carbide", amount=3},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=42},
        {type="item", name="borax", amount=4},
      },
    },
    ["diborane"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.406666666666667,
      ingredients = {
        {type="fluid", name="steam", amount=184},
        {type="item", name="ore-lead", amount=2},
      },
      results = {
        {type="fluid", name="diborane", amount=61},
      },
    },
    ["boric-acid"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 0.634,
      ingredients = {
        {type="fluid", name="oxygen", amount=106},
        {type="fluid", name="steam", amount=401},
      },
      results = {
        {type="fluid", name="boric-acid", amount=317},
      },
    },
    ["clean-nexelit"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.95,
      ingredients = {
        {type="fluid", name="steam", amount=59},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=90},
        {type="item", name="clean-nexelit", amount=1},
      },
    },
    ["nexelit-ore-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2.49992703663908,
      ingredients = {
        {type="fluid", name="creosote", amount=368},
        {type="fluid", name="muddy-sludge", amount=487},
        {type="item", name="raw-fiber", amount=2},
        {type="item", name="sodium-hydroxide", amount=4},
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coke", amount=12},
      },
      results = {
        {type="item", name="biomass", amount=3},
        {type="item", name="coarse", amount=3},
        {type="item", name="limestone", amount=2},
        {type="item", name="sand", amount=13},
      },
    },
    ["coarse-classification"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.49296385401696,
      ingredients = {
        {type="fluid", name="hydrogen", amount=208},
        {type="item", name="chromite-sand", amount=14},
        {type="item", name="lime", amount=2},
        {type="item", name="sand", amount=75},
      },
      results = {
        {type="item", name="gravel", amount=6},
        {type="item", name="iron-oxide", amount=3},
        {type="item", name="stone", amount=7},
      },
    },
    ["concrete-wall"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bolts", amount=4},
        {type="item", name="lead-plate", amount=5},
      },
      results = {
        {type="item", name="concrete-wall", amount=2},
      },
    },
    ["wood-fence"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="lime", amount=8},
      },
      results = {
        {type="item", name="wood-fence", amount=1},
      },
    },
    ["cool-pressured-steam-2000-to-1000"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.16,
      ingredients = {
        {type="fluid", name="pressured-steam", amount=200},
        {type="fluid", name="steam", amount=159},
        {type="fluid", name="water", amount=49},
      },
      results = {
        {type="fluid", name="pressured-steam", amount=432},
      },
    },
    ["jerky-to-phytoplankton"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=219},
        {type="item", name="dried-meat", amount=3},
      },
      results = {
        {type="fluid", name="phytoplankton", amount=10},
      },
    },
    ["cool-steam-250-to-150"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.964285714285714,
      ingredients = {
        {type="fluid", name="steam", amount=200},
        {type="fluid", name="water", amount=145},
      },
      results = {
        {type="fluid", name="steam", amount=335},
      },
    },
    ["electric-boiler-water-to-steam"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.65,
      ingredients = {
        {type="fluid", name="steam", amount=129},
        {type="fluid", name="water", amount=127},
      },
      results = {
        {type="fluid", name="steam", amount=324},
      },
    },
    ["digosaurus"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="formic-acid-barrel", amount=353},
        {type="item", name="fwf-mk01", amount=2},
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
        {type="item", name="electronic-circuit", amount=3},
        {type="item", name="pipe", amount=13},
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
        {type="item", name="bio-container", amount=1},
        {type="item", name="concrete", amount=695},
        {type="item", name="duralumin", amount=13},
        {type="item", name="petri-dish", amount=6},
        {type="item", name="scrude-barrel", amount=4},
        {type="item", name="tin-plate", amount=22},
      },
      results = {
        {type="item", name="fawogae-codex", amount=1},
      },
    },
    ["ralesia-codex"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="automation-science-pack", amount=8},
        {type="item", name="ceramic", amount=299},
        {type="item", name="duralumin", amount=72},
        {type="item", name="inductor1", amount=133},
        {type="item", name="pipe", amount=112},
        {type="item", name="tin-plate", amount=13},
      },
      results = {
        {type="item", name="ralesia-codex", amount=1},
      },
    },
    ["fbreactor-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=1},
        {type="item", name="ceramic", amount=35},
        {type="item", name="chlorine-barrel", amount=1},
        {type="item", name="copper-plate", amount=19},
        {type="item", name="ore-tin", amount=195},
        {type="item", name="pipe", amount=97},
        {type="item", name="stone-furnace", amount=4},
        {type="item", name="titanium-plate", amount=15},
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
        {type="item", name="concrete", amount=394},
        {type="item", name="hazard-concrete", amount=74},
        {type="item", name="offshore-pump", amount=44},
        {type="item", name="pipe", amount=227},
        {type="item", name="tinned-cable", amount=26},
        {type="item", name="tree-mk01", amount=25},
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
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="item", name="grade-1-lead", amount=2},
        {type="item", name="grade-2-tin", amount=5},
      },
      results = {
        {type="item", name="lead-plate", amount=14},
      },
    },
    ["grade-1-nickel"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.04558476625233,
      ingredients = {
        {type="item", name="processed-iron-ore", amount=4},
      },
      results = {
        {type="item", name="grade-1-nickel", amount=1},
        {type="item", name="stone", amount=1},
      },
    },
    ["nickel-plate-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="grade-2-tin", amount=1},
        {type="item", name="raw-coal", amount=13},
      },
      results = {
        {type="item", name="nickel-plate", amount=3},
      },
    },
    ["grade-1-ti"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="ore-zinc", amount=9},
      },
      results = {
        {type="item", name="grade-1-ti", amount=2},
        {type="item", name="grade-2-ti", amount=1},
      },
    },
    ["grade-2-ti-crush"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="grade-2-ti", amount=2},
      },
      results = {
        {type="item", name="grade-1-ti", amount=1},
        {type="item", name="stone", amount=2},
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
      energy_required_multiplier = 0.86475706653563,
      ingredients = {
        {type="fluid", name="molten-glass", amount=13},
        {type="item", name="grade-1-ti", amount=5},
      },
      results = {
        {type="item", name="grade-3-ti", amount=0.251626597802747},
        {type="item", name="gravel", amount=1},
      },
    },
    ["titanium-plate-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.3,
      ingredients = {
        {type="item", name="chromite-sand", amount=1},
        {type="item", name="grade-1-ti", amount=14},
        {type="item", name="moondrop", amount=2},
      },
      results = {
        {type="item", name="titanium-plate", amount=13},
      },
    },
    ["grade-1-tin"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="ore-tin", amount=6},
        {type="item", name="processed-iron-ore", amount=2},
      },
      results = {
        {type="item", name="grade-1-tin", amount=2},
        {type="item", name="grade-2-tin", amount=1},
      },
    },
    ["tin-plate-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="item", name="grade-2-tin", amount=3},
      },
      results = {
        {type="item", name="tin-plate", amount=4},
      },
    },
    ["grade-2-crush-tin"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 4,
      ingredients = {
        {type="fluid", name="pressured-water", amount=808},
        {type="item", name="grade-2-tin", amount=3},
      },
      results = {
        {type="item", name="grade-1-tin", amount=2},
        {type="item", name="stone", amount=4},
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
      energy_required_multiplier = 2.49213429650658,
      ingredients = {
        {type="item", name="grade-1-zinc", amount=3},
        {type="item", name="moondrop-seeds", amount=5},
      },
      results = {
        {type="item", name="grade-2-zinc", amount=5},
        {type="item", name="sand", amount=1},
      },
    },
    ["zinc-plate-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="item", name="grade-1-zinc", amount=9},
        {type="item", name="guts", amount=14},
        {type="item", name="sb-grade-02", amount=7},
      },
      results = {
        {type="item", name="zinc-plate", amount=40},
      },
    },
    ["grenade"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="pipe", amount=4},
        {type="item", name="seaweed", amount=75},
      },
      results = {
        {type="item", name="grenade", amount=1},
      },
    },
    ["guts-to-chlorine"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.63,
      ingredients = {
        {type="item", name="brain", amount=1},
      },
      results = {
        {type="fluid", name="chlorine", amount=63},
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
        {type="item", name="lead-plate", amount=1},
        {type="item", name="shotgun-shell", amount=6},
        {type="item", name="steel-plate", amount=1},
      },
      results = {
        {type="item", name="piercing-rounds-magazine", amount=2},
      },
    },
    ["py-asphalt"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-air", amount=470},
        {type="item", name="calcium-carbide", amount=1},
        {type="item", name="grade-1-nickel", amount=1},
        {type="item", name="moss", amount=2},
      },
      results = {
        {type="item", name="py-asphalt", amount=1},
      },
    },
    ["py-iron-oxide"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="soil", amount=145},
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
        {type="fluid", name="steam", amount=221},
        {type="item", name="calcium-carbide", amount=16},
        {type="item", name="clay", amount=11},
        {type="item", name="iron-ore", amount=10},
      },
      results = {
        {type="item", name="py-limestone", amount=3},
      },
    },
    ["py-burner"] = {
      mode = "repaired-to-input",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=45},
        {type="item", name="boiler", amount=1},
        {type="item", name="copper-plate", amount=95},
        {type="item", name="iron-plate", amount=20},
      },
      results = {
        {type="item", name="py-burner", amount=1},
      },
    },
    ["py-deposit-basic"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="formica", amount=1},
        {type="item", name="pipe", amount=21},
        {type="item", name="pitch-canister", amount=4},
        {type="item", name="pressured-water-barrel", amount=2},
        {type="item", name="small-electric-pole", amount=4},
        {type="item", name="steel-chest", amount=8},
        {type="item", name="stopper", amount=11},
        {type="item", name="vacuum-tube", amount=2},
      },
      results = {
        {type="item", name="py-deposit-basic", amount=1},
      },
    },
    ["py-shed-basic"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="small-parts-01", amount=16},
        {type="item", name="sodium-hydroxide", amount=10},
        {type="item", name="steam-engine", amount=4},
      },
      results = {
        {type="item", name="py-shed-basic", amount=1},
      },
    },
    ["py-storehouse-basic"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=9},
        {type="item", name="pipe", amount=44},
        {type="item", name="small-electric-pole", amount=3},
        {type="item", name="stopper", amount=24},
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
        {type="item", name="aluminium-plate", amount=15},
        {type="item", name="copper-plate", amount=39},
        {type="item", name="dried-meat", amount=41},
        {type="item", name="iron-chest", amount=3},
        {type="item", name="small-parts-01", amount=9},
        {type="item", name="steam-engine", amount=9},
      },
      results = {
        {type="item", name="py-warehouse-basic", amount=1},
      },
    },
    ["rail"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="item", name="bio-container", amount=4},
        {type="item", name="glass", amount=7},
        {type="item", name="ore-aluminium", amount=17},
        {type="item", name="seaweed", amount=10},
        {type="item", name="solder", amount=1},
      },
      results = {
        {type="item", name="rail", amount=4},
      },
    },
    ["rail-signal"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coal", amount=3},
        {type="item", name="grade-1-copper", amount=17},
        {type="item", name="small-parts-01", amount=4},
      },
      results = {
        {type="item", name="rail-signal", amount=1},
      },
    },
    ["rail-chain-signal"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-2-ti", amount=7},
      },
      results = {
        {type="item", name="rail-chain-signal", amount=1},
      },
    },
    ["train-stop"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=10},
        {type="item", name="moondrop-seeds", amount=11},
        {type="item", name="pipe", amount=36},
        {type="item", name="tailings-barrel", amount=11},
      },
      results = {
        {type="item", name="train-stop", amount=1},
      },
    },
    ["sb-grade-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3.10897508012054,
      ingredients = {
        {type="item", name="grade-1-ti", amount=3},
      },
      results = {
        {type="item", name="iron-oxide", amount=1},
        {type="item", name="sb-grade-01", amount=15},
        {type="item", name="sb-grade-02", amount=9},
        {type="item", name="stone", amount=6},
      },
    },
    ["sb-grade-03"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2.3535667917996,
      ingredients = {
        {type="fluid", name="water", amount=782},
        {type="item", name="sb-grade-01", amount=6},
      },
      results = {
        {type="item", name="gravel", amount=7},
        {type="item", name="sb-grade-03", amount=2},
        {type="item", name="sb-grade-04", amount=11},
      },
    },
    ["sb-grade-02"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 0.952481076534903,
      ingredients = {
        {type="item", name="sb-grade-04", amount=4},
      },
      results = {
        {type="item", name="sb-grade-02", amount=9},
        {type="item", name="stone", amount=1},
      },
    },
    ["sb-grade-04"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="sb-grade-02", amount=83},
      },
      results = {
        {type="item", name="sb-grade-04", amount=4},
      },
    },
    ["steel-furnace"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="ceramic", amount=53},
        {type="item", name="hazard-concrete", amount=10},
        {type="item", name="lead-plate", amount=3},
        {type="item", name="shotgun-shell", amount=15},
        {type="item", name="steel-plate", amount=3},
      },
      results = {
        {type="item", name="steel-furnace", amount=2},
      },
    },
    ["storage-chest"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="acetylene-canister", amount=2},
        {type="item", name="capacitor1", amount=3},
        {type="item", name="moondrop-seeds", amount=1},
        {type="item", name="tailings-barrel", amount=1},
        {type="item", name="wood-fence", amount=14},
      },
      results = {
        {type="item", name="storage-chest", amount=1},
      },
    },
    ["anemometer-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="duralumin", amount=4},
        {type="item", name="pipe", amount=65},
      },
      results = {
        {type="item", name="anemometer-mk01", amount=1},
      },
    },
    ["blade-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ceramic", amount=2},
        {type="item", name="graphite", amount=6},
        {type="item", name="lime", amount=13},
        {type="item", name="titanium-plate", amount=8},
      },
      results = {
        {type="item", name="blade-mk01", amount=1},
      },
    },
    ["brake-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=194},
        {type="item", name="copper-ore", amount=79},
        {type="item", name="fenxsb-alloy", amount=10},
        {type="item", name="graphite", amount=11},
        {type="item", name="lens", amount=3},
        {type="item", name="nexelit-plate", amount=82},
        {type="item", name="pbsb-alloy", amount=8},
        {type="item", name="pipe", amount=32},
        {type="item", name="titanium-plate", amount=12},
      },
      results = {
        {type="item", name="brake-mk01", amount=2},
      },
    },
    ["electronics-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="bolts", amount=138},
        {type="item", name="coarse", amount=8},
        {type="item", name="formica", amount=5},
        {type="item", name="inductor1", amount=45},
        {type="item", name="kerosene-barrel", amount=4},
        {type="item", name="py-tank-4000", amount=2},
        {type="item", name="small-electric-pole", amount=30},
        {type="item", name="stone-brick", amount=14},
      },
      results = {
        {type="item", name="electronics-mk01", amount=3},
      },
    },
    ["shaft-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="fenxsb-alloy", amount=5},
        {type="item", name="inductor1", amount=4},
        {type="item", name="seaweed", amount=5},
        {type="item", name="solder", amount=5},
      },
      results = {
        {type="item", name="shaft-mk01", amount=1},
      },
    },
    ["utility-box-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="chromite-sand", amount=4},
        {type="item", name="concrete", amount=7},
        {type="item", name="duralumin", amount=4},
        {type="item", name="electronic-circuit", amount=1},
        {type="item", name="glass", amount=38},
        {type="item", name="inductor1", amount=34},
        {type="item", name="plastic-bar", amount=4},
        {type="item", name="small-lamp", amount=19},
      },
      results = {
        {type="item", name="utility-box-mk01", amount=1},
      },
    },
    ["vane-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=6},
        {type="item", name="pipe", amount=29},
      },
      results = {
        {type="item", name="vane-mk01", amount=1},
      },
    },
    ["controler-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ceramic", amount=245},
        {type="item", name="lens", amount=1},
        {type="item", name="nexelit-plate", amount=6},
        {type="item", name="small-parts-01", amount=26},
      },
      results = {
        {type="item", name="controler-mk01", amount=1},
      },
    },
    ["gearbox-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="aluminium-plate", amount=21},
        {type="item", name="anemometer-mk01", amount=5},
        {type="item", name="bolts", amount=43},
        {type="item", name="electronics-mk01", amount=2},
        {type="item", name="empty-petri-dish", amount=3},
        {type="item", name="lead-plate", amount=5},
        {type="item", name="lime", amount=53},
        {type="item", name="nexelit-plate", amount=79},
      },
      results = {
        {type="item", name="gearbox-mk01", amount=3},
      },
    },
    ["nacelle-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=2},
        {type="item", name="belt", amount=24},
        {type="item", name="concrete", amount=248},
        {type="item", name="controler-mk01", amount=1},
        {type="item", name="copper-plate", amount=82},
        {type="item", name="electronics-mk01", amount=4},
        {type="item", name="gearbox-mk01", amount=4},
        {type="item", name="grade-1-zinc", amount=38},
        {type="item", name="hydrogen-barrel", amount=21},
        {type="item", name="lab", amount=2},
        {type="item", name="landfill", amount=3},
        {type="item", name="melamine", amount=36},
        {type="item", name="pbsb-alloy", amount=23},
        {type="item", name="plasmids", amount=5},
        {type="item", name="rotor-mk01", amount=6},
        {type="item", name="tower-mk01", amount=3},
        {type="item", name="transport-belt", amount=71},
        {type="item", name="vrauks-mk02", amount=12},
        {type="item", name="water-saline-barrel", amount=11},
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
        {type="item", name="aluminium-plate", amount=192},
        {type="item", name="coke", amount=104},
        {type="item", name="copper-plate", amount=169},
      },
      results = {
        {type="item", name="tower-mk01", amount=1},
      },
    },
    ["yaw-drive-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=240},
        {type="item", name="cellulose", amount=51},
        {type="item", name="concrete", amount=100},
        {type="item", name="copper-plate", amount=568},
        {type="item", name="duralumin", amount=6},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="pipe", amount=39},
        {type="item", name="shaft-mk01", amount=1},
        {type="item", name="transport-belt", amount=45},
      },
      results = {
        {type="item", name="yaw-drive-mk01", amount=2},
      },
    },
    ["rotor-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=54},
        {type="item", name="ceramic", amount=29},
        {type="item", name="electronics-mk01", amount=1},
        {type="item", name="lime", amount=67},
      },
      results = {
        {type="item", name="rotor-mk01", amount=1},
      },
    },
    ["animal-sample-01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="steam", amount=1422},
        {type="item", name="agar", amount=6},
        {type="item", name="cottongut-mk01", amount=1},
        {type="item", name="ralesia-seeds", amount=55},
        {type="item", name="retrovirus", amount=2},
        {type="item", name="seaweed", amount=73},
        {type="item", name="tar-canister", amount=2},
      },
      results = {
        {type="item", name="animal-sample-01", amount=2},
      },
    },
    ["bio-sample01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="cyanic-acid", amount=76},
        {type="item", name="bones", amount=9},
        {type="item", name="ceramic", amount=2},
        {type="item", name="iron-stick", amount=7},
        {type="item", name="lime", amount=2},
        {type="item", name="meat", amount=1},
        {type="item", name="petri-dish", amount=2},
        {type="item", name="ralesia", amount=12},
        {type="item", name="sb-oxide", amount=5},
        {type="item", name="urea", amount=5},
        {type="item", name="zinc-plate", amount=5},
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
        {type="item", name="fenxsb-alloy", amount=1},
        {type="item", name="grade-2-ti", amount=2},
        {type="item", name="small-parts-01", amount=9},
        {type="item", name="tin-plate", amount=20},
      },
      results = {
        {type="item", name="equipment-chassi", amount=3},
      },
    },
    ["ground-sample01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="fluid", name="boric-acid", amount=252},
        {type="item", name="coal-dust", amount=4},
        {type="item", name="sand", amount=4},
      },
      results = {
        {type="item", name="ground-sample01", amount=12},
      },
    },
    ["rich-clay"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="fluid", name="pressured-water", amount=402},
        {type="item", name="ash", amount=19},
        {type="item", name="grade-1-nickel", amount=6},
        {type="item", name="moss", amount=11},
      },
      results = {
        {type="item", name="rich-clay", amount=16},
      },
    },
    ["sand-casting"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=218},
        {type="item", name="limestone", amount=5},
      },
      results = {
        {type="item", name="sand-casting", amount=2},
      },
    },
    ["alien-sample01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="black-liquor", amount=13},
        {type="item", name="bio-sample01", amount=3},
        {type="item", name="empty-petri-dish", amount=1},
        {type="item", name="fish", amount=1},
        {type="item", name="limestone", amount=44},
      },
      results = {
        {type="item", name="alien-sample01", amount=4},
      },
    },
    ["lab-instrument"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="belt", amount=19},
        {type="item", name="clay", amount=70},
        {type="item", name="equipment-chassi", amount=1},
        {type="item", name="glass", amount=5},
        {type="item", name="light-oil-barrel", amount=4},
        {type="item", name="pipe", amount=9},
        {type="item", name="scrude-barrel", amount=14},
        {type="item", name="stopper", amount=1},
        {type="item", name="transport-belt", amount=6},
      },
      results = {
        {type="item", name="lab-instrument", amount=3},
      },
    },
    ["grade-1-chromite"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.04853468955712,
      ingredients = {
        {type="fluid", name="water", amount=66},
        {type="item", name="kerogen", amount=7},
      },
      results = {
        {type="item", name="grade-1-chromite", amount=1},
        {type="item", name="stone", amount=1},
      },
    },
    ["chromium-01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 0.6,
      ingredients = {
        {type="fluid", name="hydrogen", amount=162},
        {type="item", name="chromite-sand", amount=11},
      },
      results = {
        {type="item", name="chromium", amount=3},
      },
    },
    ["tier-0-chromite-sand"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.333333333333333,
      ingredients = {
        {type="item", name="grade-2-copper", amount=1},
      },
      results = {
        {type="item", name="chromite-sand", amount=1},
      },
    },
    ["medium-electric-pole"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=600},
        {type="item", name="iron-stick", amount=2},
        {type="item", name="lime", amount=2},
        {type="item", name="nexelit-plate", amount=3},
        {type="item", name="nickel-plate", amount=2},
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
      energy_required_multiplier = 1.7,
      ingredients = {
        {type="fluid", name="steam", amount=632},
        {type="item", name="nexelit-plate", amount=2},
        {type="item", name="ore-lead", amount=7},
        {type="item", name="sand-casting", amount=1},
        {type="item", name="sb-grade-04", amount=8},
      },
      results = {
        {type="fluid", name="molten-aluminium", amount=17},
      },
    },
    ["aluminium-plate-3"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.24,
      ingredients = {
        {type="fluid", name="molten-aluminium", amount=122},
        {type="fluid", name="oxygen", amount=169},
      },
      results = {
        {type="item", name="aluminium-plate", amount=62},
      },
    },
    ["hotair-aluminium-plate-3"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.682539682539683,
      ingredients = {
        {type="fluid", name="molten-aluminium", amount=71},
      },
      results = {
        {type="item", name="aluminium-plate", amount=43},
      },
    },
    ["crushing-quartz"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="kerogen", amount=13},
        {type="item", name="processed-iron-ore", amount=3},
      },
      results = {
        {type="item", name="crushed-quartz", amount=4},
        {type="item", name="stone", amount=2},
      },
    },
    ["sand-classification"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.99841668488807,
      ingredients = {
        {type="item", name="refined-concrete", amount=2},
        {type="item", name="soil", amount=35},
      },
      results = {
        {type="item", name="crushed-quartz", amount=0.0944587119182504},
        {type="item", name="gravel", amount=8},
        {type="item", name="iron-oxide", amount=1},
      },
    },
    ["glass-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.36666666666667,
      ingredients = {
        {type="fluid", name="water", amount=337},
        {type="item", name="iron-plate", amount=3},
        {type="item", name="limestone", amount=1},
      },
      results = {
        {type="fluid", name="molten-glass", amount=41},
      },
    },
    ["hotair-molten-glass"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.428571428571429,
      ingredients = {
        {type="fluid", name="hot-air", amount=36},
        {type="fluid", name="molten-glass", amount=20},
      },
      results = {
        {type="item", name="glass", amount=3},
      },
    },
    ["antimony-drill-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="distilator", amount=7},
        {type="item", name="glass", amount=58},
        {type="item", name="hpf", amount=7},
        {type="item", name="lead-plate", amount=99},
        {type="item", name="steam-engine", amount=6},
      },
      results = {
        {type="item", name="antimony-drill-mk01", amount=2},
      },
    },
    ["centrifuge-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="concrete", amount=67},
        {type="item", name="fiberboard", amount=36},
        {type="item", name="glass", amount=72},
        {type="item", name="inductor1", amount=31},
        {type="item", name="iron-chest", amount=32},
        {type="item", name="lead-plate", amount=106},
        {type="item", name="nexelit-plate", amount=248},
        {type="item", name="plastic-bar", amount=15},
        {type="item", name="tin-plate", amount=9},
        {type="item", name="titanium-plate", amount=116},
      },
      results = {
        {type="item", name="centrifuge-mk01", amount=1},
      },
    },
    ["hawt-turbine-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bio-sample", amount=17},
        {type="item", name="cooling-tower-mk01", amount=16},
        {type="item", name="fawogae-codex", amount=1},
        {type="item", name="hpf", amount=2},
        {type="item", name="landfill", amount=71},
        {type="item", name="tower-mk01", amount=2},
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
        {type="item", name="aluminium-plate", amount=1827},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="gearbox-mk01", amount=1},
        {type="item", name="grade-1-zinc", amount=10},
        {type="item", name="inductor1", amount=641},
        {type="item", name="iron-plate", amount=153},
        {type="item", name="nexelit-plate", amount=808},
        {type="item", name="small-electric-pole", amount=15},
        {type="item", name="tin-plate", amount=359},
        {type="item", name="titanium-plate", amount=33},
        {type="item", name="wood-fence", amount=13},
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
        {type="item", name="aluminium-plate", amount=895},
        {type="item", name="anemometer-mk01", amount=2},
        {type="item", name="concrete", amount=149},
        {type="item", name="empty-fuel-canister", amount=10},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="fiberboard", amount=403},
        {type="item", name="fish-egg", amount=44},
        {type="item", name="fluid-drill-mk01", amount=2},
        {type="item", name="gearbox-mk01", amount=1},
        {type="item", name="glass", amount=177},
        {type="item", name="heavy-oil-refinery-mk01", amount=1},
        {type="item", name="inductor1", amount=952},
        {type="item", name="lab", amount=17},
        {type="item", name="lead-plate", amount=586},
        {type="item", name="mechanical-parts-01", amount=4},
        {type="item", name="moondrop", amount=19},
        {type="item", name="nexelit-plate", amount=1101},
        {type="item", name="pressured-air-barrel", amount=13},
        {type="item", name="py-limestone", amount=29},
        {type="item", name="rail-signal", amount=5},
        {type="item", name="stopper", amount=61},
        {type="item", name="tin-plate", amount=536},
        {type="item", name="vitreloy", amount=54},
        {type="item", name="wood-fence", amount=52},
        {type="item", name="wpu-mk01", amount=1},
      },
      results = {
        {type="item", name="py-oil-powerplant-mk01", amount=2},
      },
    },
    ["steam-turbine-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=18},
        {type="item", name="concrete", amount=327},
        {type="item", name="engine-unit", amount=10},
        {type="item", name="glass", amount=1738},
        {type="item", name="inserter", amount=2},
        {type="item", name="py-tank-4000", amount=9},
        {type="item", name="rail", amount=117},
        {type="item", name="tower-mk01", amount=4},
        {type="item", name="yaw-drive-mk01", amount=1},
      },
      results = {
        {type="item", name="steam-turbine-mk01", amount=2},
      },
    },
    ["tidal-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=4},
        {type="item", name="concrete", amount=525},
        {type="item", name="electronics-mk01", amount=3},
        {type="item", name="fiberboard", amount=90},
        {type="item", name="formica", amount=30},
        {type="item", name="gasifier", amount=1},
        {type="item", name="hazard-concrete", amount=29},
        {type="item", name="lead-plate", amount=145},
        {type="item", name="retrovirus", amount=23},
        {type="item", name="tower-mk01", amount=1},
        {type="item", name="washer", amount=9},
      },
      results = {
        {type="item", name="tidal-mk01", amount=1},
      },
    },
    ["vawt-turbine-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="acetone-barrel", amount=1},
        {type="item", name="auog-paddock-mk01", amount=2},
        {type="item", name="bio-sample", amount=45},
        {type="item", name="boric-acid-barrel", amount=68},
        {type="item", name="coarse", amount=102},
        {type="item", name="copper-ore", amount=547},
        {type="item", name="fish-oil-barrel", amount=3},
        {type="item", name="fwf-mk01", amount=8},
        {type="item", name="grade-1-lead", amount=222},
        {type="item", name="kerosene-canister", amount=35},
        {type="item", name="lens", amount=19},
        {type="item", name="molten-glass-barrel", amount=28},
        {type="item", name="moondrop-codex", amount=1},
        {type="item", name="nexelit-plate", amount=545},
        {type="item", name="programmable-speaker", amount=3},
        {type="item", name="rhe", amount=3},
        {type="item", name="seaweed-crop-mk01", amount=2},
        {type="item", name="splitter", amount=1},
        {type="item", name="water-barrel", amount=31},
        {type="item", name="water-saline-barrel", amount=194},
      },
      results = {
        {type="item", name="vawt-turbine-mk01", amount=2},
      },
    },
    ["py-coal-powerplant-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=14},
        {type="item", name="arithmetic-combinator", amount=1},
        {type="item", name="copper-plate", amount=689},
        {type="item", name="engine-unit", amount=8},
        {type="item", name="glass", amount=1422},
        {type="item", name="glassworks-mk01", amount=1},
        {type="item", name="iron-plate", amount=2709},
        {type="item", name="jaw-crusher", amount=2},
        {type="item", name="nexelit-plate", amount=577},
        {type="item", name="rail", amount=12},
        {type="item", name="titanium-plate", amount=564},
        {type="item", name="tower-mk01", amount=3},
        {type="item", name="workers-food", amount=27},
        {type="item", name="yaw-drive-mk01", amount=1},
      },
      results = {
        {type="item", name="py-coal-powerplant-mk01", amount=1},
      },
    },
    ["arithmetic-combinator"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-ore", amount=20},
        {type="item", name="grade-1-copper", amount=18},
        {type="item", name="inductor1", amount=38},
        {type="item", name="moondrop-seeds", amount=1},
        {type="item", name="tailings-barrel", amount=1},
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
        {type="item", name="chromite-sand", amount=39},
        {type="item", name="copper-ore", amount=58},
        {type="item", name="fish-egg", amount=15},
        {type="item", name="gasoline-barrel", amount=7},
        {type="item", name="tar-canister", amount=1},
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
        {type="item", name="nexelit-plate", amount=114},
        {type="item", name="steel-chest", amount=5},
      },
      results = {
        {type="item", name="decider-combinator", amount=2},
      },
    },
    ["display-panel"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="electronic-circuit", amount=1},
        {type="item", name="grade-1-copper", amount=1},
        {type="item", name="grade-2-ti", amount=5},
        {type="item", name="pipe", amount=3},
      },
      results = {
        {type="item", name="display-panel", amount=2},
      },
    },
    ["power-switch"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="hazard-concrete", amount=14},
        {type="item", name="tree-mk01", amount=39},
      },
      results = {
        {type="item", name="power-switch", amount=1},
      },
    },
    ["programmable-speaker"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=3},
        {type="item", name="copper-ore", amount=9},
        {type="item", name="grade-1-copper", amount=21},
        {type="item", name="inductor1", amount=5},
        {type="item", name="inserter", amount=1},
        {type="item", name="pipe", amount=3},
      },
      results = {
        {type="item", name="programmable-speaker", amount=1},
      },
    },
    ["selector-combinator"] = {
      mode = "repaired-to-input",
      science_level = 2,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="concrete", amount=308},
        {type="item", name="oil-boiler-mk01", amount=3},
        {type="item", name="tar-canister", amount=13},
      },
      results = {
        {type="item", name="selector-combinator", amount=4},
      },
    },
    ["fiberboard"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.727777777777778,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=130},
        {type="item", name="raw-fiber", amount=4},
        {type="item", name="sodium-hydroxide", amount=1},
        {type="item", name="treated-wood", amount=2},
      },
      results = {
        {type="fluid", name="black-liquor", amount=7},
        {type="fluid", name="tall-oil", amount=11},
        {type="item", name="fiberboard", amount=3},
      },
    },
    ["urea-decomposition"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.06666666666667,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=229},
        {type="item", name="dried-meat", amount=3},
        {type="item", name="fertilizer", amount=2},
      },
      results = {
        {type="fluid", name="ammonia", amount=32},
        {type="fluid", name="cyanic-acid", amount=32},
      },
    },
    ["black-liquor"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.979791157107328,
      ingredients = {
        {type="fluid", name="black-liquor", amount=77},
        {type="item", name="seaweed", amount=10},
      },
      results = {
        {type="fluid", name="acetone", amount=49},
        {type="fluid", name="aromatics", amount=97},
      },
    },
    ["cyanic-acid-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.08442471566015,
      ingredients = {
        {type="fluid", name="ammonia", amount=143},
        {type="fluid", name="cyanic-acid", amount=66},
        {type="fluid", name="water", amount=2565},
        {type="item", name="coal-dust", amount=4},
        {type="item", name="fertilizer", amount=1},
      },
      results = {
        {type="fluid", name="cyanic-acid", amount=174},
        {type="fluid", name="hydrogen", amount=87},
      },
    },
    ["melamine"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.449583213954406,
      ingredients = {
        {type="fluid", name="ammonia", amount=8},
        {type="fluid", name="cyanic-acid", amount=10},
        {type="fluid", name="steam", amount=100},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=13},
        {type="fluid", name="muddy-sludge", amount=22},
        {type="item", name="melamine", amount=9},
      },
    },
    ["cooling-water"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2.5,
      ingredients = {
        {type="fluid", name="oxygen", amount=145},
        {type="fluid", name="steam", amount=89},
        {type="item", name="capacitor1", amount=1},
      },
      results = {
        {type="fluid", name="water", amount=1000},
      },
    },
    ["flue-gas-1"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.72,
      ingredients = {
        {type="item", name="biomass", amount=7},
      },
      results = {
        {type="fluid", name="flue-gas", amount=108},
      },
    },
    ["flue-gas-3"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.835,
      ingredients = {
        {type="fluid", name="hot-air", amount=38},
        {type="item", name="biomass", amount=4},
        {type="item", name="raw-coal", amount=3},
      },
      results = {
        {type="fluid", name="flue-gas", amount=167},
      },
    },
    ["cracker-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=1},
        {type="item", name="barrel", amount=24},
        {type="item", name="carbon-dioxide-barrel", amount=6},
        {type="item", name="concrete", amount=17},
        {type="item", name="duralumin", amount=8},
        {type="item", name="inductor1", amount=174},
        {type="item", name="soot", amount=4},
        {type="item", name="steel-plate", amount=89},
      },
      results = {
        {type="item", name="cracker-mk01", amount=2},
      },
    },
    ["heavy-oil-refinery-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=18},
        {type="item", name="boiler", amount=33},
        {type="item", name="ceramic", amount=87},
        {type="item", name="duralumin", amount=11},
        {type="item", name="geothermal-water-barrel", amount=2},
        {type="item", name="grade-1-lead", amount=3},
        {type="item", name="inductor1", amount=228},
        {type="item", name="log", amount=12},
        {type="item", name="pipe", amount=282},
        {type="item", name="tin-plate", amount=8},
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
        {type="item", name="concrete", amount=44},
        {type="item", name="electronic-circuit", amount=15},
        {type="item", name="graphite", amount=426},
        {type="item", name="hot-air-barrel", amount=7},
        {type="item", name="hydrogen-barrel", amount=5},
        {type="item", name="jaw-crusher", amount=3},
        {type="item", name="lime", amount=29},
        {type="item", name="nexelit-plate", amount=265},
        {type="item", name="pbsb-alloy", amount=52},
        {type="item", name="pitch-canister", amount=2},
        {type="item", name="radar", amount=3},
        {type="item", name="stone-brick", amount=62},
        {type="item", name="transport-belt", amount=36},
      },
      results = {
        {type="item", name="gas-refinery-mk01", amount=2},
      },
    },
    ["upgrader-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=18},
        {type="item", name="concrete", amount=99},
        {type="item", name="inductor1", amount=123},
        {type="item", name="nexelit-plate", amount=54},
        {type="item", name="quenching-tower", amount=4},
        {type="item", name="rail-signal", amount=1},
        {type="item", name="resistor1", amount=533},
        {type="item", name="steam-engine", amount=9},
        {type="item", name="titanium-plate", amount=54},
      },
      results = {
        {type="item", name="upgrader-mk01", amount=1},
      },
    },
    ["earth-bear-sample"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bio-sample", amount=51},
        {type="item", name="fawogae-codex", amount=3},
        {type="item", name="landfill", amount=220},
      },
      results = {
        {type="item", name="earth-bear-sample", amount=2},
      },
    },
    ["earth-flower-sample"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="automation-science-pack", amount=91},
        {type="item", name="earth-generic-sample", amount=1},
        {type="item", name="vrauks-codex", amount=7},
      },
      results = {
        {type="item", name="earth-flower-sample", amount=1},
      },
    },
    ["earth-shroom-sample"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="ceramic", amount=2028},
        {type="item", name="cottongut-codex", amount=3},
        {type="item", name="earth-generic-sample", amount=10},
        {type="item", name="fawogae-codex", amount=2},
        {type="item", name="seaweed", amount=922},
      },
      results = {
        {type="item", name="earth-shroom-sample", amount=4},
      },
    },
    ["earth-mouse-sample"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ceramic", amount=3303},
        {type="item", name="fawogae-codex", amount=1},
        {type="item", name="seaweed", amount=1501},
      },
      results = {
        {type="item", name="earth-mouse-sample", amount=1},
      },
    },
    ["molten-iron-05"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.7,
      ingredients = {
        {type="fluid", name="steam", amount=219},
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
      energy_required_multiplier = 0.986666666666667,
      ingredients = {
        {type="fluid", name="molten-iron", amount=103},
        {type="item", name="sand-casting", amount=1},
        {type="item", name="seaweed", amount=2},
      },
      results = {
        {type="item", name="iron-plate", amount=74},
      },
    },
    ["iron-plate-1"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.383333333333333,
      ingredients = {
        {type="fluid", name="molten-iron", amount=34},
        {type="item", name="ceramic", amount=3},
        {type="item", name="lime", amount=1},
      },
      results = {
        {type="item", name="iron-plate", amount=23},
      },
    },
    ["mechanical-parts-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="belt", amount=12},
        {type="item", name="controler-mk01", amount=5},
        {type="item", name="copper-plate", amount=329},
        {type="item", name="electronics-mk01", amount=6},
        {type="item", name="gearbox-mk01", amount=2},
        {type="item", name="lab", amount=9},
        {type="item", name="pbsb-alloy", amount=11},
        {type="item", name="rotor-mk01", amount=2},
      },
      results = {
        {type="item", name="mechanical-parts-01", amount=9},
      },
    },
    ["sb-oxide-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="water", amount=302},
        {type="item", name="plastic-bar", amount=2},
        {type="item", name="sb-grade-03", amount=3},
      },
      results = {
        {type="item", name="sb-oxide", amount=2},
      },
    },
    ["pbsb-alloy"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="pipe", amount=56},
        {type="item", name="sb-oxide", amount=3},
      },
      results = {
        {type="item", name="pbsb-alloy", amount=4},
      },
    },
    ["battery-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="cyanic-acid", amount=40},
        {type="item", name="ceramic", amount=11},
        {type="item", name="iron-stick", amount=11},
        {type="item", name="lime", amount=12},
        {type="item", name="sb-oxide", amount=3},
        {type="item", name="zinc-plate", amount=9},
      },
      results = {
        {type="item", name="battery-mk01", amount=2},
      },
    },
    ["accumulator"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="dino-dig-site", amount=3},
        {type="item", name="fish-egg", amount=36},
        {type="item", name="moondrop", amount=272},
      },
      results = {
        {type="item", name="accumulator", amount=4},
      },
    },
    ["fenxsb-alloy-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="ceramic", amount=4},
        {type="item", name="pbsb-alloy", amount=1},
        {type="item", name="pipe", amount=4},
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
        {type="item", name="copper-ore", amount=28},
        {type="item", name="pbsb-alloy", amount=3},
        {type="item", name="titanium-plate", amount=5},
      },
      results = {
        {type="item", name="vitreloy", amount=2},
      },
    },
    ["intermetallics"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="fenxsb-alloy", amount=2},
        {type="item", name="pipe", amount=9},
        {type="item", name="seaweed", amount=184},
        {type="item", name="vitreloy", amount=1},
      },
      results = {
        {type="item", name="intermetallics", amount=3},
      },
    },
    ["ball-mill-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="boiler", amount=9},
        {type="item", name="brain", amount=3},
        {type="item", name="chitin", amount=1},
        {type="item", name="concrete", amount=148},
        {type="item", name="geothermal-water-barrel", amount=1},
        {type="item", name="inductor1", amount=69},
        {type="item", name="iron-plate", amount=51},
        {type="item", name="lime", amount=276},
        {type="item", name="log", amount=8},
        {type="item", name="middle-oil-barrel", amount=2},
        {type="item", name="nexelit-plate", amount=113},
        {type="item", name="pipe", amount=17},
        {type="item", name="tinned-cable", amount=92},
        {type="item", name="vitreloy", amount=8},
        {type="item", name="vrauks", amount=2},
      },
      results = {
        {type="item", name="ball-mill-mk01", amount=2},
      },
    },
    ["chemical-plant-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="bolts", amount=58},
        {type="item", name="gasifier", amount=2},
        {type="item", name="grade-1-copper", amount=101},
        {type="item", name="intermetallics", amount=11},
        {type="item", name="lead-plate", amount=102},
        {type="item", name="lens", amount=28},
        {type="item", name="tinned-cable", amount=75},
        {type="item", name="wood-fence", amount=8},
      },
      results = {
        {type="item", name="chemical-plant-mk01", amount=3},
      },
    },
    ["classifier"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="chromite-sand", amount=262},
        {type="item", name="duralumin", amount=23},
        {type="item", name="moondrop-seeds", amount=53},
        {type="item", name="pipe", amount=193},
        {type="item", name="sap-tree", amount=2},
        {type="item", name="ti-rejects", amount=1},
      },
      results = {
        {type="item", name="classifier", amount=1},
      },
    },
    ["rectisol"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="coal", amount=177},
        {type="item", name="cocoon", amount=13},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="fiberboard", amount=5},
        {type="item", name="grade-1-tin", amount=15},
        {type="item", name="grade-3-ti", amount=7},
        {type="item", name="light-oil-canister", amount=5},
        {type="item", name="nexelit-plate", amount=83},
        {type="item", name="pipe", amount=16},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="storage-tank", amount=5},
        {type="item", name="syngas-canister", amount=21},
        {type="item", name="titanium-plate", amount=218},
      },
      results = {
        {type="item", name="rectisol", amount=2},
      },
    },
    ["automated-factory-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="copper-plate", amount=317},
        {type="item", name="electronic-circuit", amount=7},
        {type="item", name="gearbox-mk01", amount=3},
        {type="item", name="inserter", amount=8},
        {type="item", name="intermetallics", amount=3},
        {type="item", name="py-tank-4000", amount=5},
        {type="item", name="titanium-plate", amount=64},
      },
      results = {
        {type="item", name="automated-factory-mk01", amount=2},
      },
    },
    ["fluid-drill-mk02"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="bio-container", amount=17},
        {type="item", name="caged-vrauks", amount=6},
        {type="item", name="distilator", amount=5},
        {type="item", name="glass", amount=45},
        {type="item", name="hpf", amount=2},
        {type="item", name="iron-plate", amount=224},
        {type="item", name="lead-plate", amount=198},
        {type="item", name="middle-oil-barrel", amount=3},
        {type="item", name="scrude-barrel", amount=34},
        {type="item", name="soil-extractor-mk01", amount=2},
        {type="item", name="steam-engine", amount=5},
        {type="item", name="syngas-canister", amount=5},
      },
      results = {
        {type="item", name="fluid-drill-mk02", amount=3},
      },
    },
    ["bof-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=13},
        {type="item", name="duralumin", amount=6},
        {type="item", name="inductor1", amount=70},
        {type="item", name="scrude-barrel", amount=2},
        {type="item", name="stone-furnace", amount=26},
      },
      results = {
        {type="item", name="bof-mk01", amount=1},
      },
    },
    ["casting-unit-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="condensates", amount=2248},
        {type="item", name="acetylene-barrel", amount=2},
        {type="item", name="coal", amount=816},
        {type="item", name="distilator", amount=1},
        {type="item", name="duralumin", amount=9},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="gun-turret", amount=4},
        {type="item", name="nexelit-plate", amount=171},
        {type="item", name="pipe", amount=73},
        {type="item", name="stone-furnace", amount=43},
        {type="item", name="vacuum-tube", amount=3},
        {type="item", name="vane-mk01", amount=1},
        {type="item", name="wood-fence", amount=8},
      },
      results = {
        {type="item", name="casting-unit-mk01", amount=2},
      },
    },
    ["eaf-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=1},
        {type="item", name="boric-acid-barrel", amount=7},
        {type="item", name="chromite-sand", amount=1250},
        {type="item", name="concrete", amount=18},
        {type="item", name="duralumin", amount=7},
        {type="item", name="glass", amount=298},
        {type="item", name="inductor1", amount=8},
        {type="item", name="intermetallics", amount=12},
        {type="item", name="jaw-crusher", amount=1},
        {type="item", name="middle-oil-canister", amount=14},
        {type="item", name="moondrop-seeds", amount=99},
        {type="item", name="nexelit-plate", amount=35},
        {type="item", name="pipe", amount=364},
        {type="item", name="py-iron-oxide", amount=14},
        {type="item", name="sap-tree", amount=4},
        {type="item", name="ti-rejects", amount=3},
      },
      results = {
        {type="item", name="eaf-mk01", amount=3},
      },
    },
    ["hydroclassifier-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="classifier", amount=3},
        {type="item", name="fenxsb-alloy", amount=48},
        {type="item", name="inductor1", amount=315},
        {type="item", name="titanium-plate", amount=109},
      },
      results = {
        {type="item", name="hydroclassifier-mk01", amount=2},
      },
    },
    ["impact-crusher-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=12},
        {type="item", name="boiler", amount=25},
        {type="item", name="chromite-sand", amount=79},
        {type="item", name="duralumin", amount=124},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="glass", amount=240},
        {type="item", name="middle-oil-barrel", amount=1},
        {type="item", name="molten-glass-barrel", amount=1},
        {type="item", name="resistor1", amount=37},
        {type="item", name="seaweed-crop-mk01", amount=1},
        {type="item", name="solid-separator", amount=1},
        {type="item", name="sulfur", amount=33},
        {type="item", name="transport-belt", amount=17},
      },
      results = {
        {type="item", name="impact-crusher-mk01", amount=2},
      },
    },
    ["scrubber-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=13},
        {type="item", name="boiler", amount=27},
        {type="item", name="cellulose", amount=2},
        {type="item", name="distilator", amount=1},
        {type="item", name="duralumin", amount=28},
        {type="item", name="pipe", amount=8},
        {type="item", name="sulfur", amount=36},
        {type="item", name="transport-belt", amount=18},
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
        {type="item", name="aluminium-plate", amount=18},
        {type="item", name="assembling-machine-1", amount=2},
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="graphite", amount=138},
        {type="item", name="intermetallics", amount=8},
        {type="item", name="tinned-cable", amount=30},
      },
      results = {
        {type="item", name="flotation-cell-mk01", amount=1},
      },
    },
    ["cargo-wagon"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="biomass", amount=1068},
        {type="item", name="bolts", amount=47},
        {type="item", name="ceramic", amount=21},
        {type="item", name="concrete", amount=8},
        {type="item", name="copper-ore", amount=429},
        {type="item", name="duralumin", amount=3},
        {type="item", name="formica", amount=24},
        {type="item", name="gravel", amount=42},
        {type="item", name="lens", amount=155},
        {type="item", name="pipe", amount=15},
        {type="item", name="py-tank-1500", amount=1},
        {type="item", name="rail-signal", amount=3},
        {type="item", name="rich-clay", amount=5},
        {type="item", name="small-parts-01", amount=6},
        {type="item", name="splitter", amount=4},
        {type="item", name="tailings-dust", amount=84},
      },
      results = {
        {type="item", name="cargo-wagon", amount=1},
      },
    },
    ["fluid-wagon"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bio-sample", amount=17},
        {type="item", name="boric-acid-barrel", amount=25},
        {type="item", name="fwf-mk01", amount=3},
        {type="item", name="moondrop-codex", amount=3},
        {type="item", name="nexelit-plate", amount=200},
        {type="item", name="programmable-speaker", amount=1},
        {type="item", name="seaweed-crop-mk01", amount=2},
        {type="item", name="slacked-lime-barrel", amount=5},
      },
      results = {
        {type="item", name="fluid-wagon", amount=2},
      },
    },
    ["locomotive"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="copper-plate", amount=112},
        {type="item", name="duralumin", amount=49},
        {type="item", name="electronic-circuit", amount=17},
        {type="item", name="fish-oil-barrel", amount=15},
        {type="item", name="hot-air-barrel", amount=46},
        {type="item", name="hydrogen-barrel", amount=31},
        {type="item", name="inductor1", amount=29},
        {type="item", name="inserter", amount=8},
        {type="item", name="iron-plate", amount=119},
        {type="item", name="lime", amount=477},
        {type="item", name="moondrop-seeds", amount=23},
        {type="item", name="nexelit-plate", amount=62},
        {type="item", name="pitch-barrel", amount=12},
        {type="item", name="pitch-canister", amount=12},
        {type="item", name="py-tank-4000", amount=12},
        {type="item", name="py-tank-7000", amount=3},
        {type="item", name="titanium-plate", amount=43},
      },
      results = {
        {type="item", name="locomotive", amount=2},
      },
    },
    ["cooling-tower-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="glass", amount=9},
        {type="item", name="inductor1", amount=41},
        {type="item", name="intermetallics", amount=3},
        {type="item", name="lead-plate", amount=153},
      },
      results = {
        {type="item", name="cooling-tower-mk01", amount=1},
      },
    },
    ["fawogae-plantation-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=11},
        {type="item", name="coke", amount=26},
        {type="item", name="duralumin", amount=27},
        {type="item", name="glass", amount=98},
        {type="item", name="pipe", amount=10},
        {type="item", name="small-parts-01", amount=8},
        {type="item", name="steel-chest", amount=2},
        {type="item", name="tin-plate", amount=37},
      },
      results = {
        {type="item", name="fawogae-plantation-mk01", amount=1},
      },
    },
    ["prandium-lab-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=82},
        {type="item", name="burner-mining-drill", amount=1},
        {type="item", name="cellulose", amount=15},
        {type="item", name="concrete", amount=23},
        {type="item", name="copper-plate", amount=121},
        {type="item", name="creosote-barrel", amount=3},
        {type="item", name="lab", amount=1},
        {type="item", name="lead-plate", amount=25},
        {type="item", name="limestone", amount=26},
        {type="item", name="nexelit-plate", amount=15},
        {type="item", name="pipe", amount=108},
        {type="item", name="rail-chain-signal", amount=1},
        {type="item", name="skin", amount=35},
        {type="item", name="steam-engine", amount=8},
        {type="item", name="steel-plate", amount=48},
        {type="item", name="tinned-cable", amount=4},
        {type="item", name="titanium-plate", amount=5},
      },
      results = {
        {type="item", name="prandium-lab-mk01", amount=1},
      },
    },
    ["ralesia-plantation-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bio-container", amount=1},
        {type="item", name="bones", amount=4},
        {type="item", name="burner-mining-drill", amount=3},
        {type="item", name="cellulose", amount=31},
        {type="item", name="creosote-barrel", amount=18},
        {type="item", name="fenxsb-alloy", amount=15},
        {type="item", name="grade-1-nickel", amount=18},
        {type="item", name="lab", amount=1},
        {type="item", name="lead-plate", amount=48},
        {type="item", name="limestone", amount=168},
        {type="item", name="nexelit-plate", amount=12},
        {type="item", name="pressured-air-barrel", amount=1},
        {type="item", name="steel-plate", amount=99},
      },
      results = {
        {type="item", name="ralesia-plantation-mk01", amount=1},
      },
    },
    ["fish-farm-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="classifier", amount=1},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="inductor1", amount=662},
        {type="item", name="moondrop", amount=96},
        {type="item", name="plastic-bar", amount=38},
        {type="item", name="pressured-air-barrel", amount=64},
        {type="item", name="py-limestone", amount=143},
        {type="item", name="rail-signal", amount=22},
        {type="item", name="raw-borax", amount=1080},
        {type="item", name="small-electric-pole", amount=166},
        {type="item", name="tin-plate", amount=28},
        {type="item", name="titanium-plate", amount=161},
        {type="item", name="transport-belt", amount=33},
        {type="item", name="wpu-mk01", amount=7},
      },
      results = {
        {type="item", name="fish-farm-mk01", amount=3},
      },
    },
    ["heavy-armor"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=30},
        {type="item", name="boric-acid-barrel", amount=4},
        {type="item", name="concrete", amount=14},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="glass", amount=107},
        {type="item", name="inductor1", amount=156},
        {type="item", name="lead-plate", amount=50},
        {type="item", name="py-tank-6500", amount=1},
        {type="item", name="stone-brick", amount=61},
        {type="item", name="tin-plate", amount=59},
        {type="item", name="tinned-cable", amount=50},
      },
      results = {
        {type="item", name="heavy-armor", amount=1},
      },
    },
    ["mixer-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bones", amount=6},
        {type="item", name="distilator", amount=3},
        {type="item", name="duralumin", amount=10},
        {type="item", name="grade-1-nickel", amount=25},
        {type="item", name="intermetallics", amount=12},
        {type="item", name="lead-plate", amount=64},
        {type="item", name="nexelit-plate", amount=15},
        {type="item", name="pressured-air-barrel", amount=2},
        {type="item", name="py-tank-6500", amount=1},
        {type="item", name="tin-plate", amount=64},
        {type="item", name="tinned-cable", amount=126},
      },
      results = {
        {type="item", name="mixer-mk01", amount=2},
      },
    },
    ["py-heat-exchanger"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="duralumin", amount=19},
        {type="item", name="fenxsb-alloy", amount=30},
        {type="item", name="gasoline-barrel", amount=14},
        {type="item", name="jaw-crusher", amount=4},
        {type="item", name="py-tank-1000", amount=7},
        {type="item", name="titanium-plate", amount=174},
      },
      results = {
        {type="item", name="py-heat-exchanger", amount=1},
      },
    },
    ["secondary-crusher-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=4},
        {type="item", name="ceramic", amount=442},
        {type="item", name="inductor1", amount=201},
        {type="item", name="pipe", amount=189},
      },
      results = {
        {type="item", name="secondary-crusher-mk01", amount=1},
      },
    },
    ["atomizer-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bio-container", amount=13},
        {type="item", name="bolts", amount=92},
        {type="item", name="bones", amount=77},
        {type="item", name="gasifier", amount=1},
        {type="item", name="grade-1-copper", amount=51},
        {type="item", name="grade-1-nickel", amount=323},
        {type="item", name="lead-plate", amount=42},
        {type="item", name="naphthalene-oil-barrel", amount=4},
        {type="item", name="pressured-air-barrel", amount=9},
        {type="item", name="scrude-barrel", amount=14},
        {type="item", name="scrude-canister", amount=8},
        {type="item", name="tar-canister", amount=6},
        {type="item", name="tinned-cable", amount=91},
        {type="item", name="wood-fence", amount=4},
      },
      results = {
        {type="item", name="atomizer-mk01", amount=2},
      },
    },
    ["bio-reactor-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="concrete", amount=35},
        {type="item", name="electronic-circuit", amount=16},
        {type="item", name="fenxsb-alloy", amount=9},
        {type="item", name="gasoline-barrel", amount=4},
        {type="item", name="jaw-crusher", amount=3},
        {type="item", name="lime", amount=789},
        {type="item", name="mixer-mk01", amount=2},
        {type="item", name="py-tank-1000", amount=2},
        {type="item", name="steam-engine", amount=7},
        {type="item", name="titanium-plate", amount=155},
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
        {type="item", name="electronic-circuit", amount=7},
        {type="item", name="engine-unit", amount=4},
        {type="item", name="fiberboard", amount=16},
        {type="item", name="graphite", amount=204},
        {type="item", name="lens", amount=4},
        {type="item", name="nexelit-plate", amount=25},
        {type="item", name="pipe", amount=22},
        {type="item", name="pump", amount=1},
        {type="item", name="soil-extractor-mk01", amount=2},
        {type="item", name="stone-furnace", amount=43},
        {type="item", name="transport-belt", amount=7},
        {type="item", name="water-barrel", amount=8},
      },
      results = {
        {type="item", name="plankton-farm", amount=1},
      },
    },
    ["spore-collector-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=22},
        {type="item", name="boiler", amount=105},
        {type="item", name="brain", amount=2},
        {type="item", name="ceramic", amount=68},
        {type="item", name="concrete", amount=281},
        {type="item", name="inductor1", amount=103},
        {type="item", name="intermetallics", amount=4},
        {type="item", name="lab", amount=1},
        {type="item", name="light-oil-canister", amount=1},
        {type="item", name="pipe", amount=364},
        {type="item", name="tar-processing-unit", amount=1},
        {type="item", name="tin-plate", amount=10},
        {type="item", name="tinned-cable", amount=118},
        {type="item", name="titanium-plate", amount=9},
        {type="item", name="washer", amount=1},
      },
      results = {
        {type="item", name="spore-collector-mk01", amount=2},
      },
    },
    ["compost-plant-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="moondrop", amount=39},
        {type="item", name="pressured-air-barrel", amount=26},
        {type="item", name="py-limestone", amount=463},
        {type="item", name="rail-signal", amount=9},
        {type="item", name="raw-borax", amount=1118},
        {type="item", name="transport-belt", amount=107},
        {type="item", name="wpu-mk01", amount=3},
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
        {type="item", name="coal", amount=1973},
        {type="item", name="fluid-drill-mk01", amount=3},
        {type="item", name="gun-turret", amount=10},
        {type="item", name="iron-oxide", amount=27},
        {type="item", name="iron-plate", amount=39},
        {type="item", name="pipe", amount=69},
        {type="item", name="steam-engine", amount=2},
      },
      results = {
        {type="item", name="oil-boiler-mk01", amount=2},
      },
    },
    ["py-electric-boiler"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="clay", amount=212},
        {type="item", name="light-oil-barrel", amount=41},
        {type="item", name="pipe", amount=89},
        {type="item", name="scrude-barrel", amount=17},
        {type="item", name="stopper", amount=2},
        {type="item", name="tinned-cable", amount=2},
      },
      results = {
        {type="item", name="py-electric-boiler", amount=1},
      },
    },
    ["rhe"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="concrete", amount=17},
        {type="item", name="duralumin", amount=8},
        {type="item", name="glass", amount=29},
        {type="item", name="inductor1", amount=26},
        {type="item", name="lime", amount=6},
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="rhe", amount=1},
      },
    },
    ["personal-roboport-equipment"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=68},
        {type="item", name="assembling-machine-1", amount=2},
        {type="item", name="fiberboard", amount=48},
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="graphite", amount=174},
        {type="item", name="iron-plate", amount=387},
        {type="item", name="nexelit-plate", amount=884},
        {type="item", name="skin", amount=24},
        {type="item", name="steam-engine", amount=24},
        {type="item", name="tinned-cable", amount=43},
      },
      results = {
        {type="item", name="personal-roboport-equipment", amount=2},
      },
    },
    ["portable-gasoline-generator"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="acetylene-barrel", amount=30},
        {type="item", name="cocoon", amount=3},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="grade-1-tin", amount=8},
        {type="item", name="grade-3-ti", amount=4},
        {type="item", name="light-oil-canister", amount=3},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="storage-tank", amount=1},
        {type="item", name="syngas-canister", amount=4},
        {type="item", name="titanium-plate", amount=119},
        {type="item", name="vacuum-tube", amount=16},
        {type="item", name="vitreloy", amount=12},
        {type="item", name="water-barrel", amount=6},
      },
      results = {
        {type="item", name="portable-gasoline-generator", amount=2},
      },
    },
    ["py-recharge-station-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=20},
        {type="item", name="chromite-sand", amount=59},
        {type="item", name="iron-plate", amount=32},
        {type="item", name="lime", amount=176},
        {type="item", name="moondrop-seeds", amount=5},
        {type="item", name="tinned-cable", amount=59},
        {type="item", name="vitreloy", amount=5},
        {type="item", name="vrauks", amount=1},
      },
      results = {
        {type="item", name="py-recharge-station-mk01", amount=1},
      },
    },
    ["py-roboport-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="brain", amount=27},
        {type="item", name="electronics-mk01", amount=2},
        {type="item", name="gasifier", amount=2},
        {type="item", name="gasoline-barrel", amount=16},
        {type="item", name="light-oil-canister", amount=15},
        {type="item", name="lime", amount=42},
        {type="item", name="medium-electric-pole", amount=3},
        {type="item", name="tinned-cable", amount=12},
      },
      results = {
        {type="item", name="py-roboport-mk01", amount=3},
      },
    },
    ["py-ze"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="capacitor1", amount=100},
        {type="item", name="concrete", amount=17},
        {type="item", name="duralumin", amount=17},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="glass", amount=88},
        {type="item", name="iron-plate", amount=15},
        {type="item", name="lead-plate", amount=16},
        {type="item", name="seaweed", amount=38},
        {type="item", name="tin-plate", amount=3},
      },
      results = {
        {type="item", name="py-ze", amount=2},
      },
    },
    ["salt-mine"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="advanced-foundry-mk01", amount=9},
        {type="item", name="anemometer-mk01", amount=10},
        {type="item", name="automated-factory-mk01", amount=2},
        {type="item", name="ceramic", amount=520},
        {type="item", name="concrete", amount=142},
        {type="item", name="electronics-mk01", amount=5},
        {type="item", name="fiberboard", amount=26},
        {type="item", name="formica", amount=9},
        {type="item", name="hazard-concrete", amount=67},
        {type="item", name="jaw-crusher", amount=1},
        {type="item", name="lead-plate", amount=129},
        {type="item", name="retrovirus", amount=21},
        {type="item", name="rhe", amount=1},
        {type="item", name="small-parts-01", amount=137},
        {type="item", name="steam-engine", amount=43},
        {type="item", name="titanium-plate", amount=42},
        {type="item", name="vitreloy", amount=35},
        {type="item", name="washer", amount=8},
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
        {type="item", name="agar", amount=9},
        {type="item", name="aluminium-plate", amount=52},
        {type="item", name="boric-acid-barrel", amount=33},
        {type="item", name="concrete", amount=68},
        {type="item", name="inductor1", amount=72},
        {type="item", name="lime", amount=308},
        {type="item", name="oxygen-barrel", amount=3},
        {type="item", name="pipe", amount=134},
        {type="item", name="rich-clay", amount=105},
        {type="item", name="small-lamp", amount=6},
        {type="item", name="steel-plate", amount=22},
        {type="item", name="wood-seedling", amount=9},
      },
      results = {
        {type="item", name="dino-dig-site", amount=1},
      },
    },
    ["generator-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="agar", amount=14},
        {type="item", name="boric-acid-barrel", amount=6},
        {type="item", name="formica", amount=1},
        {type="item", name="lime", amount=147},
        {type="item", name="methane-barrel", amount=9},
        {type="item", name="molten-aluminium-barrel", amount=1},
        {type="item", name="oxygen-barrel", amount=1},
        {type="item", name="pbsb-alloy", amount=3},
        {type="item", name="sb-grade-02", amount=57},
        {type="item", name="wood-seedling", amount=4},
      },
      results = {
        {type="item", name="generator-1", amount=1},
      },
    },
    ["pyphoon-bay"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bolts", amount=73},
        {type="item", name="ceramic", amount=84},
        {type="item", name="formica", amount=38},
        {type="item", name="gravel", amount=164},
        {type="item", name="pbsb-alloy", amount=10},
        {type="item", name="py-tank-1500", amount=5},
        {type="item", name="rail-signal", amount=5},
        {type="item", name="train-stop", amount=5},
      },
      results = {
        {type="item", name="pyphoon-bay", amount=2},
      },
    },
    ["belt"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=56},
      },
      results = {
        {type="item", name="belt", amount=2},
      },
    },
    ["polybutadiene"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.05951110032992,
      ingredients = {
        {type="fluid", name="pressured-water", amount=638},
        {type="fluid", name="scrude", amount=390},
        {type="item", name="clean-nexelit", amount=7},
        {type="item", name="titanium-plate", amount=1},
      },
      results = {
        {type="fluid", name="polybutadiene", amount=106},
        {type="fluid", name="steam", amount=1058},
      },
    },
    ["long-handed-inserter"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2.5,
      ingredients = {
        {type="item", name="chromite-sand", amount=48},
        {type="item", name="copper-ore", amount=183},
        {type="item", name="dried-meat", amount=23},
        {type="item", name="inserter", amount=3},
        {type="item", name="naphthalene-oil-canister", amount=1},
        {type="item", name="tar-canister", amount=1},
      },
      results = {
        {type="item", name="long-handed-inserter", amount=5},
      },
    },
    ["carbon-black"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="fluid", name="water", amount=1510},
      },
      results = {
        {type="item", name="carbon-black", amount=2},
      },
    },
    ["engine-unit-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="item", name="aluminium-plate", amount=7},
        {type="item", name="belt", amount=4},
        {type="item", name="duralumin", amount=14},
        {type="item", name="iron-plate", amount=13},
        {type="item", name="pipe", amount=94},
        {type="item", name="steam-engine", amount=4},
      },
      results = {
        {type="item", name="engine-unit", amount=5},
      },
    },
    ["transport-belt-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="fluid", name="molten-glass", amount=88},
        {type="item", name="bolts", amount=7},
        {type="item", name="petri-dish-bacteria", amount=8},
        {type="item", name="rubber", amount=2},
      },
      results = {
        {type="item", name="transport-belt", amount=24},
      },
    },
    ["rubber-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="polybutadiene", amount=47},
        {type="item", name="bolts", amount=4},
        {type="item", name="carbon-black", amount=1},
        {type="item", name="latex", amount=1},
      },
      results = {
        {type="item", name="rubber", amount=1},
      },
    },
    ["depolymerized-organics"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1.23,
      ingredients = {
        {type="fluid", name="oxygen", amount=5311},
        {type="fluid", name="steam", amount=6418},
        {type="fluid", name="water", amount=22296},
      },
      results = {
        {type="fluid", name="depolymerized-organics", amount=123},
      },
    },
    ["subcritical-water-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.76,
      ingredients = {
        {type="item", name="biomass", amount=28},
      },
      results = {
        {type="fluid", name="subcritical-water", amount=38},
      },
    },
    ["electronic-circuit-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="item", name="battery-mk01", amount=1},
        {type="item", name="bolts", amount=10},
        {type="item", name="coarse", amount=2},
        {type="item", name="fiberboard", amount=1},
        {type="item", name="formica", amount=4},
        {type="item", name="inductor1", amount=11},
        {type="item", name="kerosene-barrel", amount=1},
        {type="item", name="small-electric-pole", amount=5},
        {type="item", name="small-parts-01", amount=5},
        {type="item", name="sodium-hydroxide", amount=7},
        {type="item", name="solder", amount=1},
        {type="item", name="vacuum-tube", amount=4},
      },
      results = {
        {type="item", name="electronic-circuit", amount=8},
      },
    },
    ["formica-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="ceramic", amount=27},
        {type="item", name="fiberboard", amount=2},
        {type="item", name="soil", amount=111},
      },
      results = {
        {type="item", name="formica", amount=4},
      },
    },
    ["hotair-empty-petri-dish"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="molten-glass", amount=61},
        {type="item", name="bolts", amount=4},
        {type="item", name="lead-plate", amount=2},
      },
      results = {
        {type="item", name="empty-petri-dish", amount=4},
      },
    },
    ["hotair-flask"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 0.333333333333333,
      ingredients = {
        {type="fluid", name="molten-glass", amount=58},
        {type="item", name="petri-dish-bacteria", amount=2},
      },
      results = {
        {type="item", name="flask", amount=1},
      },
    },
    ["stopper-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="belt", amount=1},
        {type="item", name="bolts", amount=50},
      },
      results = {
        {type="item", name="stopper", amount=3},
      },
    },
    ["meat-to-tin"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bones", amount=2},
      },
      results = {
        {type="item", name="ore-tin", amount=15},
      },
    },
    ["skin-to-lead"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2.6,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=5832},
        {type="item", name="brain", amount=4},
        {type="item", name="meat", amount=13},
        {type="item", name="tinned-cable", amount=3},
        {type="item", name="water-saline-barrel", amount=3},
      },
      results = {
        {type="item", name="ore-lead", amount=13},
      },
    },
    ["powdered-ralesia-seeds"] = {
      mode = "repaired-to-input",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ralesia", amount=10},
      },
      results = {
        {type="item", name="powdered-ralesia-seeds", amount=1},
      },
    },
    ["water-saline"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.97,
      ingredients = {
        {type="fluid", name="steam", amount=37},
        {type="item", name="capacitor1", amount=1},
      },
      results = {
        {type="fluid", name="water-saline", amount=97},
      },
    },
    ["starch"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.66885454166865,
      ingredients = {
        {type="item", name="fiberboard", amount=1},
        {type="item", name="powdered-ralesia-seeds", amount=2},
        {type="item", name="wood", amount=4},
      },
      results = {
        {type="item", name="biomass", amount=9},
        {type="item", name="starch", amount=5},
      },
    },
    ["aerial-blimp-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="brake-mk01", amount=1},
        {type="item", name="ceramic", amount=5165},
        {type="item", name="electronics-mk01", amount=1},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="gasifier", amount=18},
        {type="item", name="generator-1", amount=1},
        {type="item", name="iron-plate", amount=235},
        {type="item", name="scrude-barrel", amount=52},
        {type="item", name="small-parts-01", amount=1364},
        {type="item", name="storage-tank", amount=2},
        {type="item", name="titanium-plate", amount=86},
      },
      results = {
        {type="item", name="aerial-blimp-mk01", amount=2},
      },
    },
    ["blood-to-iron"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="boric-acid", amount=574},
      },
      results = {
        {type="item", name="iron-ore", amount=10},
      },
    },
    ["fawogae-to-iron"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2.4,
      ingredients = {
        {type="item", name="meat", amount=4},
        {type="item", name="raw-fiber", amount=3},
      },
      results = {
        {type="item", name="iron-ore", amount=12},
      },
    },
    ["bone-to-bonemeal-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="item", name="brain", amount=2},
        {type="item", name="guts", amount=8},
      },
      results = {
        {type="item", name="bonemeal", amount=7},
      },
    },
    ["bones-to-kerogen"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="item", name="guts", amount=4},
      },
      results = {
        {type="item", name="kerogen", amount=6},
      },
    },
    ["breed-fish-1"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.49472838681025,
      ingredients = {
        {type="fluid", name="polybutadiene", amount=92},
        {type="fluid", name="pressured-water", amount=371},
        {type="fluid", name="steam", amount=221},
        {type="item", name="biomass", amount=10},
        {type="item", name="carbon-black", amount=5},
        {type="item", name="fish-egg", amount=6},
        {type="item", name="latex", amount=2},
        {type="item", name="tinned-cable", amount=3},
      },
      results = {
        {type="fluid", name="waste-water", amount=148},
        {type="item", name="fish", amount=15},
      },
    },
    ["breed-fish-egg-1"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.8038229340662,
      ingredients = {
        {type="fluid", name="pressured-water", amount=4192},
        {type="item", name="fish", amount=13},
        {type="item", name="seaweed", amount=264},
      },
      results = {
        {type="fluid", name="waste-water", amount=182},
        {type="item", name="fish-egg", amount=45},
      },
    },
    ["py-construction-robot-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="creamy-latex", amount=1563},
        {type="item", name="brain", amount=20},
        {type="item", name="carbon-black", amount=27},
        {type="item", name="cyanic-acid-barrel", amount=5},
        {type="item", name="empty-fuel-canister", amount=3},
        {type="item", name="gasifier", amount=2},
        {type="item", name="gasoline-barrel", amount=4},
        {type="item", name="geothermal-water-barrel", amount=15},
        {type="item", name="grade-1-lead", amount=58},
        {type="item", name="inductor1", amount=16},
        {type="item", name="iron-chest", amount=5},
        {type="item", name="lab", amount=2},
        {type="item", name="light-oil-canister", amount=11},
        {type="item", name="log", amount=96},
        {type="item", name="medium-electric-pole", amount=5},
        {type="item", name="tin-plate", amount=37},
      },
      results = {
        {type="item", name="py-construction-robot-mk01", amount=2},
      },
    },
    ["liquid-manure"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.99,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=174},
        {type="fluid", name="steam", amount=103},
        {type="fluid", name="water", amount=179},
        {type="item", name="dried-meat", amount=9},
      },
      results = {
        {type="fluid", name="liquid-manure", amount=99},
      },
    },
    ["zogna-bacteria"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="item", name="petri-dish-bacteria", amount=3},
        {type="item", name="small-lamp", amount=1},
      },
      results = {
        {type="fluid", name="zogna-bacteria", amount=25},
      },
    },
    ["plasmids"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="fluid", name="water", amount=8980},
        {type="item", name="empty-petri-dish", amount=47},
        {type="item", name="lab-instrument", amount=2},
        {type="item", name="nexelit-plate", amount=22},
        {type="item", name="petri-dish", amount=1},
        {type="item", name="petri-dish-bacteria", amount=1},
        {type="item", name="stopper", amount=6},
      },
      results = {
        {type="item", name="plasmids", amount=3},
      },
    },
    ["retrovirus"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="empty-petri-dish", amount=79},
        {type="item", name="petri-dish-bacteria", amount=1},
        {type="item", name="vrauks", amount=1},
      },
      results = {
        {type="item", name="retrovirus", amount=1},
      },
    },
    ["cdna"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="fluid", name="tailings", amount=1112},
        {type="item", name="agar", amount=4},
        {type="item", name="bio-sample", amount=5},
        {type="item", name="cellulose", amount=5},
        {type="item", name="chitin", amount=5},
        {type="item", name="copper-cable", amount=151},
        {type="item", name="empty-petri-dish", amount=21},
        {type="item", name="inductor1", amount=10},
        {type="item", name="lab-instrument", amount=1},
        {type="item", name="petri-dish", amount=15},
        {type="item", name="plasmids", amount=2},
        {type="item", name="retrovirus", amount=4},
        {type="item", name="seaweed", amount=163},
        {type="item", name="small-electric-pole", amount=5},
        {type="item", name="steel-chest", amount=7},
      },
      results = {
        {type="item", name="cdna", amount=3},
      },
    },
    ["ralesia-sample"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="automation-science-pack", amount=174},
        {type="item", name="cdna", amount=3},
        {type="item", name="ceramic", amount=147},
        {type="item", name="cottongut-codex", amount=1},
        {type="item", name="earth-generic-sample", amount=2},
        {type="item", name="earth-mouse-sample", amount=1},
        {type="item", name="vrauks-codex", amount=14},
      },
      results = {
        {type="item", name="ralesia", amount=4},
      },
    },
    ["ralesia-seeds"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ralesia", amount=5},
      },
      results = {
        {type="item", name="ralesia-seeds", amount=8},
      },
    },
    ["ralesia-1"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="pressured-water", amount=179},
        {type="item", name="coarse", amount=2},
        {type="item", name="ralesia-seeds", amount=6},
      },
      results = {
        {type="item", name="ralesia", amount=8},
      },
    },
    ["cottongut-codex"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ceramic", amount=18},
        {type="item", name="concrete", amount=826},
        {type="item", name="inductor1", amount=8},
        {type="item", name="lead-plate", amount=7},
        {type="item", name="tin-plate", amount=28},
        {type="item", name="tinned-cable", amount=16},
        {type="item", name="wood", amount=21},
      },
      results = {
        {type="item", name="cottongut-codex", amount=1},
      },
    },
    ["cottongut-cub-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1.46871387014942,
      ingredients = {
        {type="item", name="cottongut", amount=8},
        {type="item", name="moondrop-seeds", amount=6},
        {type="item", name="ralesia", amount=8},
        {type="item", name="water-barrel", amount=3},
      },
      results = {
        {type="item", name="barrel", amount=4},
        {type="item", name="cottongut-pup", amount=15},
      },
    },
    ["cottongut"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="cdna", amount=5},
        {type="item", name="earth-bear-sample", amount=1},
        {type="item", name="earth-flower-sample", amount=4},
        {type="item", name="formic-acid-barrel", amount=49},
        {type="item", name="ralesia-codex", amount=4},
      },
      results = {
        {type="item", name="cottongut-mk01", amount=3},
      },
    },
    ["cottongut-food-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="fluid", name="methanal", amount=11},
        {type="fluid", name="steam", amount=203},
        {type="item", name="ralesia", amount=3},
        {type="item", name="soil", amount=34},
        {type="item", name="tin-plate", amount=2},
        {type="item", name="wood", amount=8},
      },
      results = {
        {type="item", name="cottongut-food-01", amount=2},
      },
    },
    ["cottongut-science-red-seeds"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=17364},
        {type="item", name="cellulose", amount=7},
        {type="item", name="cottongut", amount=21},
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
        {type="item", name="cottongut-food-01", amount=3},
        {type="item", name="cottongut-mk01", amount=3},
        {type="item", name="limestone", amount=13},
        {type="item", name="moondrop-seeds", amount=9},
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
        {type="item", name="cottongut-food-01", amount=1},
        {type="item", name="cottongut-pup", amount=2},
        {type="item", name="moondrop-seeds", amount=24},
        {type="item", name="stone-furnace", amount=2},
      },
      results = {
        {type="item", name="cottongut-mk01", amount=2},
      },
    },
    ["logistic-science-pack"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.833333333333333,
      ingredients = {
        {type="item", name="alien-sample01", amount=1},
        {type="item", name="animal-sample-01", amount=2},
        {type="item", name="melamine-resin", amount=15},
        {type="item", name="moondrop", amount=48},
        {type="item", name="tree-mk01", amount=1},
      },
      results = {
        {type="item", name="logistic-science-pack", amount=10},
      },
    },
    ["workers-food"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=3617},
        {type="item", name="clean-nexelit", amount=3},
        {type="item", name="guts", amount=2},
        {type="item", name="lead-plate", amount=5},
        {type="item", name="meat", amount=21},
        {type="item", name="soil", amount=33},
        {type="item", name="tar-barrel", amount=1},
        {type="item", name="tinned-cable", amount=5},
        {type="item", name="water-saline-barrel", amount=5},
      },
      results = {
        {type="item", name="workers-food", amount=4},
      },
    },
    ["auog-codex"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="acetylene-canister", amount=8},
        {type="item", name="concrete", amount=63},
        {type="item", name="seaweed", amount=34},
        {type="item", name="tin-plate", amount=14},
        {type="item", name="wood-fence", amount=22},
      },
      results = {
        {type="item", name="auog-codex", amount=1},
      },
    },
    ["auog-paddock-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="fluid", name="condensates", amount=22934},
        {type="item", name="brake-mk01", amount=1},
        {type="item", name="iron-gear-wheel", amount=14},
        {type="item", name="iron-plate", amount=93},
        {type="item", name="iron-stick", amount=129},
        {type="item", name="sand", amount=372},
      },
      results = {
        {type="item", name="auog-paddock-mk01", amount=3},
      },
    },
    ["auog-pooping-1"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.61153440640141,
      ingredients = {
        {type="item", name="copper-ore", amount=18},
        {type="item", name="moss", amount=13},
        {type="item", name="seaweed", amount=8},
        {type="item", name="water-barrel", amount=8},
      },
      results = {
        {type="item", name="barrel", amount=8},
        {type="item", name="manure", amount=9},
      },
    },
    ["auog-pup-breeding-1"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.814278191747207,
      ingredients = {
        {type="item", name="copper-ore", amount=15},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="auog-pup", amount=3},
        {type="item", name="barrel", amount=4},
      },
    },
    ["auog"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="automation-science-pack", amount=113},
        {type="item", name="bio-sample", amount=10},
        {type="item", name="earth-mouse-sample", amount=3},
        {type="item", name="grade-2-ti", amount=39},
        {type="item", name="retrovirus", amount=13},
      },
      results = {
        {type="item", name="auog", amount=2},
      },
    },
    ["auog-food-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="fluid", name="water", amount=745},
        {type="item", name="native-flora", amount=6},
        {type="item", name="pipe", amount=11},
        {type="item", name="plastic-bar", amount=2},
        {type="item", name="ralesia", amount=1},
        {type="item", name="ralesia-seeds", amount=4},
        {type="item", name="sb-grade-03", amount=3},
        {type="item", name="seaweed", amount=3},
        {type="item", name="stone-brick", amount=5},
      },
      results = {
        {type="item", name="auog-food-01", amount=5},
      },
    },
    ["auog-maturing-1"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-pup", amount=2},
        {type="item", name="ralesia", amount=2},
        {type="item", name="water-barrel", amount=6},
      },
      results = {
        {type="item", name="auog", amount=3},
        {type="item", name="barrel", amount=5},
      },
    },
    ["auog-recharge-00"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bonemeal", amount=1},
        {type="item", name="bones", amount=8},
        {type="item", name="guts", amount=3},
        {type="item", name="moss", amount=8},
      },
      results = {
        {type="item", name="auog", amount=2},
      },
    },
    ["auog-maturing-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.3195237319479,
      ingredients = {
        {type="item", name="auog-food-01", amount=4},
        {type="item", name="auog-pup", amount=13},
        {type="item", name="moss", amount=12},
        {type="item", name="petri-dish", amount=1},
        {type="item", name="ralesia", amount=1},
        {type="item", name="ti-rejects", amount=1},
        {type="item", name="vacuum-barrel", amount=4},
        {type="item", name="water-barrel", amount=3},
      },
      results = {
        {type="item", name="auog", amount=7},
        {type="item", name="barrel", amount=7},
      },
    },
    ["auog-pooping-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1.02458279652031,
      ingredients = {
        {type="item", name="auog-food-01", amount=3},
        {type="item", name="capacitor1", amount=2},
        {type="item", name="soil", amount=45},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="manure", amount=9},
      },
    },
    ["auog-pup-breeding-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-food-01", amount=2},
        {type="item", name="saps", amount=2},
        {type="item", name="seaweed", amount=7},
        {type="item", name="soil", amount=22},
        {type="item", name="water-barrel", amount=7},
      },
      results = {
        {type="item", name="auog-pup", amount=6},
        {type="item", name="barrel", amount=5},
      },
    },
    ["auog-recharge-0"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="auog-food-01", amount=2},
        {type="item", name="hydrogen-barrel", amount=3},
        {type="item", name="moss", amount=10},
        {type="item", name="used-auog", amount=4},
      },
      results = {
        {type="item", name="auog", amount=4},
      },
    },
    ["fertilizer-4"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=238},
        {type="fluid", name="zogna-bacteria", amount=15},
        {type="item", name="biomass", amount=8},
        {type="item", name="dried-meat", amount=4},
        {type="item", name="manure", amount=4},
      },
      results = {
        {type="item", name="fertilizer", amount=4},
      },
    },
    ["urea-from-liquid-manure"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.766666666666667,
      ingredients = {
        {type="fluid", name="steam", amount=7335},
        {type="fluid", name="water", amount=664},
      },
      results = {
        {type="item", name="urea", amount=23},
      },
    },
    ["melamine-resin"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.9,
      ingredients = {
        {type="fluid", name="methanal", amount=21},
        {type="item", name="ceramic", amount=29},
        {type="item", name="ralesia", amount=4},
        {type="item", name="urea", amount=4},
      },
      results = {
        {type="item", name="melamine-resin", amount=9},
      },
    },
    ["fawogae-1"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.714285714285714,
      ingredients = {
        {type="item", name="moondrop-seeds", amount=1},
      },
      results = {
        {type="item", name="fawogae", amount=5},
      },
    },
    ["fawogae-sample"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2.5,
      ingredients = {
        {type="item", name="earth-bear-sample", amount=2},
        {type="item", name="empty-petri-dish", amount=42},
        {type="item", name="moondrop", amount=39},
        {type="item", name="vacuum-tube", amount=58},
        {type="item", name="vrauks-codex", amount=16},
      },
      results = {
        {type="item", name="fawogae", amount=5},
      },
    },
    ["boron-trioxide"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="oxygen", amount=140},
        {type="item", name="grade-2-copper", amount=4},
        {type="item", name="limestone", amount=1},
      },
      results = {
        {type="item", name="boron-trioxide", amount=2},
      },
    },
    ["coke-coal"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="item", name="raw-coal", amount=8},
      },
      results = {
        {type="fluid", name="coke-oven-gas", amount=15},
        {type="item", name="coke", amount=3},
      },
    },
    ["coal-fawogae"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="item", name="meat", amount=2},
      },
      results = {
        {type="item", name="raw-coal", amount=5},
      },
    },
    ["hotair-lens"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=307},
        {type="fluid", name="hot-air", amount=47},
        {type="item", name="lime", amount=3},
      },
      results = {
        {type="item", name="lens", amount=2},
      },
    },
    ["lens"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="hydrogen", amount=1000},
        {type="fluid", name="molten-glass", amount=93},
      },
      results = {
        {type="item", name="lens", amount=4},
      },
    },
    ["vrauks-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.733460760302766,
      ingredients = {
        {type="item", name="cocoon", amount=15},
        {type="item", name="methane-barrel", amount=1},
        {type="item", name="seaweed", amount=16},
        {type="item", name="vrauks-food-01", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=2},
        {type="item", name="vrauks", amount=3},
      },
    },
    ["vrauks-food-01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="item", name="ash", amount=3},
        {type="item", name="ceramic", amount=2},
        {type="item", name="fawogae-substrate", amount=4},
        {type="item", name="lime", amount=12},
        {type="item", name="moss", amount=4},
        {type="item", name="petri-dish-bacteria", amount=1},
        {type="item", name="pipe", amount=3},
        {type="item", name="small-lamp", amount=2},
        {type="item", name="wood", amount=17},
      },
      results = {
        {type="item", name="vrauks-food-01", amount=5},
      },
    },
    ["vrauks-cocoon-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1.7253285457687,
      ingredients = {
        {type="item", name="middle-oil-barrel", amount=1},
        {type="item", name="sand", amount=13},
        {type="item", name="soil", amount=156},
        {type="item", name="vrauks-food-01", amount=2},
        {type="item", name="water-barrel", amount=7},
      },
      results = {
        {type="item", name="barrel", amount=7},
        {type="item", name="cocoon", amount=17},
      },
    },
    ["vrauks-mk02"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.58679143388309,
      ingredients = {
        {type="item", name="caged-vrauks", amount=2},
        {type="item", name="cocoon", amount=33},
        {type="item", name="empty-petri-dish", amount=1},
        {type="item", name="methane-barrel", amount=1},
        {type="item", name="seaweed", amount=16},
        {type="item", name="vrauks-food-01", amount=4},
        {type="item", name="water-barrel", amount=6},
      },
      results = {
        {type="item", name="barrel", amount=8},
        {type="item", name="vrauks", amount=2},
        {type="item", name="vrauks-mk02", amount=0.00811572115920832},
      },
    },
    ["vrauks-mk02-breeder"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2.08536257873279,
      ingredients = {
        {type="item", name="cocoon", amount=56},
        {type="item", name="moss", amount=19},
        {type="item", name="soil", amount=134},
        {type="item", name="vrauks-food-01", amount=13},
        {type="item", name="vrauks-mk02", amount=5},
        {type="item", name="water-barrel", amount=6},
      },
      results = {
        {type="item", name="barrel", amount=10},
        {type="item", name="vrauks-mk02", amount=7},
      },
    },
    ["vrauks-mk02-cocoon"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.43495540663515,
      ingredients = {
        {type="item", name="middle-oil-barrel", amount=1},
        {type="item", name="native-flora", amount=14},
        {type="item", name="sand", amount=10},
        {type="item", name="soil", amount=184},
        {type="item", name="vrauks-food-01", amount=5},
        {type="item", name="vrauks-mk02", amount=2},
        {type="item", name="water-barrel", amount=6},
      },
      results = {
        {type="item", name="barrel", amount=7},
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
        {type="item", name="refined-concrete", amount=1},
      },
      results = {
        {type="fluid", name="coke-oven-gas", amount=100},
        {type="item", name="warm-stone-brick", amount=4},
      },
    },
    ["warm-air-1"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.35303699085999,
      ingredients = {
        {type="item", name="carbon-black", amount=3},
        {type="item", name="grade-1-ti", amount=8},
        {type="item", name="sand", amount=3},
      },
      results = {
        {type="fluid", name="hot-air", amount=205},
        {type="item", name="stone-brick", amount=27},
      },
    },
    ["waste-water-void"] = {
      mode = "input-preserved-untransformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="chlorine", amount=10},
        {type="fluid", name="flue-gas", amount=1723},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=2},
        {type="item", name="grade-2-copper", amount=1},
      },
      results = {
        {type="item", name="empty-gas-canister", amount=1},
      },
    },
    ["active-provider-chest"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="manure", amount=8},
        {type="item", name="phytoplankton-barrel", amount=2},
      },
      results = {
        {type="item", name="active-provider-chest", amount=1},
      },
    },
    ["buffer-chest"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="lime", amount=5},
        {type="item", name="processed-iron-ore", amount=5},
        {type="item", name="small-parts-01", amount=8},
        {type="item", name="stone-brick", amount=43},
      },
      results = {
        {type="item", name="buffer-chest", amount=1},
      },
    },
    ["passive-provider-chest"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="electronic-circuit", amount=1},
        {type="item", name="empty-barrel-milk", amount=22},
      },
      results = {
        {type="item", name="passive-provider-chest", amount=1},
      },
    },
    ["requester-chest"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="processed-iron-ore", amount=20},
        {type="item", name="small-parts-01", amount=31},
      },
      results = {
        {type="item", name="requester-chest", amount=1},
      },
    },
    ["aromatic-organic"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.48,
      ingredients = {
        {type="item", name="fertilizer", amount=5},
        {type="item", name="planter-box", amount=2},
        {type="item", name="ralesia-seeds", amount=6},
      },
      results = {
        {type="fluid", name="aromatics", amount=296},
      },
    },
    ["ash-bone"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="mukmoux-fat", amount=1},
      },
      results = {
        {type="item", name="ash", amount=2},
      },
    },
    ["ash3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="item", name="ralesia-seeds", amount=2},
        {type="item", name="raw-fiber", amount=5},
      },
      results = {
        {type="item", name="ash", amount=21},
      },
    },
    ["coal-dust3"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="item", name="raw-fiber", amount=4},
      },
      results = {
        {type="item", name="coal-dust", amount=8},
      },
    },
    ["fluegas-filtration"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="fluid", name="flue-gas", amount=41},
        {type="fluid", name="pressured-air", amount=13},
        {type="item", name="biomass", amount=2},
      },
      results = {
        {type="item", name="ash", amount=1},
      },
    },
    ["grade-3-tin"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 6,
      ingredients = {
        {type="item", name="grade-2-tin", amount=2},
        {type="item", name="lime", amount=5},
        {type="item", name="pipe", amount=10},
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
        {type="item", name="grade-3-tin", amount=4},
      },
      results = {
        {type="item", name="grade-1-tin", amount=1},
      },
    },
    ["wash-grade-3-tin"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.971439131877343,
      ingredients = {
        {type="fluid", name="water", amount=115},
        {type="item", name="grade-1-tin", amount=2},
      },
      results = {
        {type="fluid", name="tailings", amount=92},
        {type="item", name="grade-4-tin", amount=1},
      },
    },
    ["ball-grade-4-tin"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 5,
      ingredients = {
        {type="item", name="grade-1-tin", amount=5},
        {type="item", name="propene-barrel", amount=2},
      },
      results = {
        {type="item", name="tin-dust", amount=5},
      },
    },
    ["tin-plate-4"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="acidgas-barrel", amount=2},
      },
      results = {
        {type="item", name="tin-plate", amount=4},
      },
    },
    ["molten-tin-01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.466666666666667,
      ingredients = {
        {type="item", name="coke", amount=9},
        {type="item", name="limestone", amount=5},
        {type="item", name="rail", amount=10},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="fluid", name="molten-tin", amount=14},
      },
    },
    ["hotair-tin-plate-3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.0793650793650794,
      ingredients = {
        {type="fluid", name="molten-steel", amount=2},
        {type="fluid", name="pressured-water", amount=1077},
      },
      results = {
        {type="item", name="tin-plate", amount=5},
      },
    },
    ["tin-plate-3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.06,
      ingredients = {
        {type="fluid", name="molten-tin", amount=106},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="tin-plate", amount=53},
      },
    },
    ["carbon-filter"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="diborane-barrel", amount=14},
        {type="item", name="engine-unit", amount=5},
        {type="item", name="lab", amount=6},
        {type="item", name="long-handed-inserter", amount=2},
        {type="item", name="methane-barrel", amount=24},
        {type="item", name="offshore-pump", amount=3},
        {type="item", name="pressured-water-barrel", amount=12},
        {type="item", name="storage-tank", amount=2},
        {type="item", name="tall-oil-canister", amount=3},
        {type="item", name="tinned-cable", amount=54},
      },
      results = {
        {type="item", name="carbon-filter", amount=4},
      },
    },
    ["fts-reactor"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boiler", amount=7},
        {type="item", name="carbon-black", amount=6},
        {type="item", name="empty-gas-canister", amount=9},
        {type="item", name="iron-plate", amount=7},
        {type="item", name="nexelit-plate", amount=190},
        {type="item", name="resistor1", amount=342},
        {type="item", name="sb-grade-04", amount=3},
        {type="item", name="stone-brick", amount=31},
        {type="item", name="tinned-cable", amount=21},
        {type="item", name="titanium-plate", amount=19},
      },
      results = {
        {type="item", name="fts-reactor", amount=1},
      },
    },
    ["methanol-reactor"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coke", amount=118},
        {type="item", name="copper-cable", amount=104},
        {type="item", name="electronic-circuit", amount=8},
        {type="item", name="flora-collector-mk01", amount=2},
        {type="item", name="nexelit-plate", amount=84},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="tinned-cable", amount=8},
        {type="item", name="titanium-plate", amount=37},
      },
      results = {
        {type="item", name="methanol-reactor", amount=1},
      },
    },
    ["fluid-separator"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="concrete", amount=100},
        {type="item", name="constant-combinator", amount=10},
        {type="item", name="evaporator", amount=6},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="storage-tank", amount=8},
      },
      results = {
        {type="item", name="fluid-separator", amount=2},
      },
    },
    ["chromite-rejects-processing"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="item", name="pitch-canister", amount=2},
      },
      results = {
        {type="item", name="grade-3-chromite", amount=1},
      },
    },
    ["grade-4-chromite"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 5,
      ingredients = {
        {type="item", name="grade-2-chromite", amount=2},
        {type="item", name="pitch-canister", amount=3},
      },
      results = {
        {type="item", name="chromite-rejects", amount=20},
        {type="item", name="grade-4-chromite", amount=20},
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
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="item", name="acetylene-barrel", amount=1},
      },
      results = {
        {type="item", name="chromite-sand", amount=16},
      },
    },
    ["grade-2-chromite-beneficiation"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 4.57238386995871,
      ingredients = {
        {type="item", name="grade-3-chromite", amount=11},
      },
      results = {
        {type="item", name="grade-1-chromite", amount=3},
        {type="item", name="gravel", amount=2},
      },
    },
    ["classify-iron-ore-dust"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.92,
      ingredients = {
        {type="item", name="chromite-sand", amount=22},
      },
      results = {
        {type="fluid", name="iron-pulp-01", amount=46},
        {type="fluid", name="iron-slime", amount=46},
      },
    },
    ["grade-2-iron"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="iron-ore", amount=24},
      },
      results = {
        {type="item", name="grade-1-iron", amount=2},
        {type="item", name="grade-2-iron", amount=1},
        {type="item", name="grade-3-iron", amount=1},
      },
    },
    ["iron-slime"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=38},
        {type="fluid", name="tar", amount=208},
        {type="item", name="gravel", amount=235},
      },
      results = {
        {type="fluid", name="iron-slime", amount=25},
      },
    },
    ["unslimed-iron"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.97910206602293,
      ingredients = {
        {type="fluid", name="iron-slime", amount=102},
        {type="fluid", name="nitrogen", amount=476},
        {type="fluid", name="steam", amount=103},
        {type="item", name="calcinates", amount=1},
      },
      results = {
        {type="fluid", name="tailings", amount=187},
        {type="item", name="unslimed-iron", amount=2},
      },
    },
    ["grade-2-crush"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.0470526519640557,
      ingredients = {
        {type="item", name="powdered-biomass", amount=3},
      },
      results = {
        {type="item", name="grade-1-iron", amount=0.0470526519640557},
        {type="item", name="gravel", amount=0.0235263259820279},
      },
    },
    ["grade-3-iron-processing"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-3-iron", amount=1},
      },
      results = {
        {type="item", name="grade-2-iron", amount=1},
      },
    },
    ["iron-ore-dust"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-ore", amount=9},
      },
      results = {
        {type="item", name="iron-ore-dust", amount=1},
      },
    },
    ["molten-iron-06"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.9,
      ingredients = {
        {type="fluid", name="steam", amount=194},
        {type="item", name="chromium", amount=1},
        {type="item", name="grade-1-iron", amount=7},
      },
      results = {
        {type="fluid", name="molten-iron", amount=36},
      },
    },
    ["unslimed-iron-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.990354799702893,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=429},
      },
      results = {
        {type="fluid", name="tailings", amount=94},
        {type="item", name="unslimed-iron", amount=1},
      },
    },
    ["classify-low-grade"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.993135787353671,
      ingredients = {
        {type="item", name="grade-2-copper", amount=9},
      },
      results = {
        {type="item", name="copper-low-dust", amount=1},
        {type="item", name="grade-4-copper", amount=0.282153047119545},
      },
    },
    ["copper-rejects-recrush"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="hot-air", amount=99},
        {type="item", name="grade-2-copper", amount=3},
        {type="item", name="ore-titanium", amount=5},
      },
      results = {
        {type="item", name="grade-3-copper", amount=1},
        {type="item", name="gravel", amount=2},
      },
    },
    ["grade-3-copper"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=234},
        {type="item", name="copper-ore", amount=6},
      },
      results = {
        {type="item", name="copper-rejects", amount=1},
        {type="item", name="grade-3-copper", amount=1},
      },
    },
    ["grade-4-copper"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-2-copper", amount=4},
      },
      results = {
        {type="item", name="grade-4-copper", amount=1},
        {type="item", name="low-grade-rejects", amount=2},
      },
    },
    ["hotair-copper-plate-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.746666666666667,
      ingredients = {
        {type="fluid", name="ammonia", amount=264},
        {type="fluid", name="petroleum-gas", amount=73},
        {type="fluid", name="pressured-water", amount=11115},
        {type="item", name="coke", amount=4},
        {type="item", name="pure-sand", amount=5},
        {type="item", name="sand-casting", amount=2},
      },
      results = {
        {type="item", name="copper-plate", amount=56},
      },
    },
    ["wash-coper-low-dust"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.98677153933104,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=304},
        {type="item", name="iron-chest", amount=5},
      },
      results = {
        {type="fluid", name="tailings", amount=392},
        {type="item", name="low-grade-copper", amount=2},
      },
    },
    ["copper-plate-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.933333333333333,
      ingredients = {
        {type="fluid", name="ammonia", amount=985},
      },
      results = {
        {type="item", name="copper-plate", amount=56},
      },
    },
    ["low-grade-smelting-copper"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="item", name="iron-chest", amount=2},
        {type="item", name="low-grade-copper", amount=1},
      },
      results = {
        {type="item", name="copper-plate", amount=1},
      },
    },
    ["molten-copper-04"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.76190476190476,
      ingredients = {
        {type="fluid", name="hydrogen", amount=126},
        {type="item", name="grade-2-copper", amount=15},
        {type="item", name="light-oil-canister", amount=3},
      },
      results = {
        {type="fluid", name="molten-copper", amount=37},
      },
    },
    ["coalbed-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 4,
      ingredients = {
        {type="fluid", name="fish-oil", amount=818},
        {type="item", name="auog-codex", amount=2},
        {type="item", name="car", amount=5},
        {type="item", name="chemical-plant-mk01", amount=2},
        {type="item", name="chlorine-barrel", amount=4},
        {type="item", name="medium-electric-pole", amount=138},
        {type="item", name="methanal-barrel", amount=26},
        {type="item", name="titanium-plate", amount=73},
        {type="item", name="vitreloy", amount=1},
      },
      results = {
        {type="item", name="coalbed-mk01", amount=4},
      },
    },
    ["lor-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="distilator", amount=1},
        {type="item", name="dried-meat", amount=196},
        {type="item", name="duralumin", amount=5},
        {type="item", name="fawogae-spore", amount=24},
        {type="item", name="formic-acid-barrel", amount=6},
        {type="item", name="grade-1-tin", amount=6},
        {type="item", name="grade-2-tin", amount=9},
        {type="item", name="nexelit-plate", amount=54},
        {type="item", name="plastic-bar", amount=341},
        {type="item", name="py-limestone", amount=3},
        {type="item", name="resistor1", amount=9},
        {type="item", name="steel-chest", amount=5},
        {type="item", name="titanium-plate", amount=16},
      },
      results = {
        {type="item", name="lor-mk01", amount=1},
      },
    },
    ["natural-gas-derrick-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="acidgas-barrel", amount=1},
        {type="item", name="burner-inserter", amount=2},
        {type="item", name="carbon-dioxide-barrel", amount=6},
        {type="item", name="duralumin", amount=10},
        {type="item", name="electronic-circuit", amount=3},
        {type="item", name="inductor1", amount=12},
        {type="item", name="iron-stick", amount=34},
        {type="item", name="muddy-sludge-barrel", amount=4},
        {type="item", name="shotgun-shell", amount=87},
      },
      results = {
        {type="item", name="natural-gas-derrick-mk01", amount=1},
      },
    },
    ["oil-derrick-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aromatics-canister", amount=3},
        {type="item", name="boiler", amount=2},
        {type="item", name="bolts", amount=26},
        {type="item", name="carbon-dioxide-barrel", amount=2},
        {type="item", name="diborane-barrel", amount=1},
        {type="item", name="empty-gas-canister", amount=74},
        {type="item", name="iron-stick", amount=33},
        {type="item", name="methane-barrel", amount=3},
        {type="item", name="py-sinkhole", amount=1},
        {type="item", name="raw-borax", amount=25},
        {type="item", name="sb-grade-04", amount=25},
        {type="item", name="steel-plate", amount=17},
        {type="item", name="stone-brick", amount=198},
      },
      results = {
        {type="item", name="oil-derrick-mk01", amount=2},
      },
    },
    ["oil-sand-extractor-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anthracene-oil-barrel", amount=2},
        {type="item", name="chitin", amount=12},
        {type="item", name="distilator", amount=1},
        {type="item", name="dried-meat", amount=25},
        {type="item", name="engine-unit", amount=6},
        {type="item", name="fawogae-spore", amount=3},
        {type="item", name="formic-acid-barrel", amount=2},
        {type="item", name="grade-1-zinc", amount=3},
        {type="item", name="liquid-manure-barrel", amount=3},
        {type="item", name="nexelit-plate", amount=21},
        {type="item", name="ore-lead", amount=30},
        {type="item", name="plastic-bar", amount=347},
        {type="item", name="py-limestone", amount=1},
        {type="item", name="steel-chest", amount=1},
        {type="item", name="tar-canister", amount=6},
        {type="item", name="vitreloy", amount=2},
      },
      results = {
        {type="item", name="oil-sand-extractor-mk01", amount=1},
      },
    },
    ["pumpjack-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="long-handed-inserter", amount=3},
        {type="item", name="offshore-pump", amount=2},
        {type="item", name="pressured-water-barrel", amount=19},
        {type="item", name="stone-brick", amount=22},
        {type="item", name="storage-tank", amount=3},
        {type="item", name="tinned-cable", amount=32},
      },
      results = {
        {type="item", name="pumpjack-mk01", amount=2},
      },
    },
    ["tar-extractor-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="anthracene-oil-barrel", amount=10},
        {type="item", name="auog-pup", amount=73},
        {type="item", name="creamy-latex-barrel", amount=13},
        {type="item", name="grade-2-chromite", amount=22},
        {type="item", name="moondrop-seeds", amount=166},
        {type="item", name="oil-sand", amount=2016},
        {type="item", name="py-shed-basic", amount=7},
        {type="item", name="ralesia-codex", amount=2},
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
        {type="item", name="crushed-coal", amount=2},
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
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="item", name="crushed-coal", amount=2},
        {type="item", name="raw-coal", amount=21},
      },
      results = {
        {type="item", name="coal", amount=3},
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
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="burner-inserter", amount=8},
        {type="item", name="coal", amount=28},
        {type="item", name="duralumin", amount=17},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="glass", amount=15},
        {type="item", name="intermetallics", amount=9},
        {type="item", name="iron-plate", amount=275},
        {type="item", name="lead-plate", amount=35},
        {type="item", name="low-grade-rejects", amount=8},
        {type="item", name="navens-spore", amount=53},
        {type="item", name="pbsb-alloy", amount=8},
        {type="item", name="soil-extractor-mk01", amount=4},
        {type="item", name="steel-chest", amount=4},
        {type="item", name="stone-brick", amount=13},
        {type="item", name="washer", amount=6},
      },
      results = {
        {type="item", name="ez-ranch-mk01", amount=2},
      },
    },
    ["kicalk-plantation-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="concrete", amount=165},
        {type="item", name="fiberboard", amount=2},
        {type="item", name="incubator-mk01", amount=1},
        {type="item", name="iron-plate", amount=75},
        {type="item", name="lens", amount=4},
        {type="item", name="nexelit-plate", amount=198},
      },
      results = {
        {type="item", name="kicalk-plantation-mk01", amount=1},
      },
    },
    ["tuuphra-plantation-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="boiler", amount=5},
        {type="item", name="concrete", amount=626},
        {type="item", name="fenxsb-alloy", amount=2},
        {type="item", name="incubator-mk01", amount=1},
        {type="item", name="iron-plate", amount=113},
        {type="item", name="lens", amount=13},
        {type="item", name="nexelit-plate", amount=80},
        {type="item", name="nickel-plate", amount=22},
        {type="item", name="pbsb-alloy", amount=2},
        {type="item", name="resistor1", amount=173},
        {type="item", name="seaweed", amount=29},
        {type="item", name="small-parts-01", amount=302},
        {type="item", name="yaedols-spores", amount=104},
      },
      results = {
        {type="item", name="tuuphra-plantation-mk01", amount=2},
      },
    },
    ["yaedols-culture-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=331},
        {type="item", name="bio-sample", amount=2},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="grade-1-tin", amount=11},
        {type="item", name="grade-2-tin", amount=17},
        {type="item", name="landfill", amount=10},
        {type="item", name="lead-plate", amount=232},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="nexelit-plate", amount=161},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="zogna-bacteria-barrel", amount=26},
      },
      results = {
        {type="item", name="yaedols-culture-mk01", amount=1},
      },
    },
    ["crawdad"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=861},
        {type="item", name="alien-sample01", amount=150},
        {type="item", name="aluminium-plate", amount=638},
        {type="item", name="earth-bear-sample", amount=1},
        {type="item", name="glass", amount=4253},
        {type="item", name="limestone", amount=355},
        {type="item", name="moss-gen", amount=14},
        {type="item", name="powdered-ralesia-seeds", amount=218},
        {type="item", name="pump", amount=9},
        {type="item", name="py-science-pack-1", amount=27},
        {type="item", name="py-tank-4000", amount=13},
      },
      results = {
        {type="item", name="crawdad", amount=1},
      },
    },
    ["sponge-culture-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="barrel", amount=14},
        {type="item", name="copper-plate", amount=9},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="fawogae", amount=25},
        {type="item", name="fiberboard", amount=53},
        {type="item", name="gun-turret", amount=1},
        {type="item", name="lead-plate", amount=14},
        {type="item", name="pbsb-alloy", amount=35},
        {type="item", name="pump", amount=4},
        {type="item", name="tinned-cable", amount=43},
        {type="item", name="vane-mk01", amount=1},
      },
      results = {
        {type="item", name="sponge-culture-mk01", amount=1},
      },
    },
    ["crushing-molybdenite"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.590482079850901,
      ingredients = {
        {type="item", name="empty-comb", amount=1},
      },
      results = {
        {type="item", name="crushed-molybdenite", amount=3},
        {type="item", name="stone", amount=1},
      },
    },
    ["duralumin-2"] = {
      mode = "repaired-to-input",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="molten-aluminium", amount=100},
        {type="fluid", name="petroleum-gas", amount=2070},
        {type="item", name="sand-casting", amount=4},
      },
      results = {
        {type="item", name="duralumin", amount=20},
      },
    },
    ["sncr-alloy"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="lime", amount=2},
        {type="item", name="pipe", amount=4},
      },
      results = {
        {type="item", name="sncr-alloy", amount=2},
      },
    },
    ["empty-comb"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.571428571428571,
      ingredients = {
        {type="fluid", name="hot-air", amount=269},
        {type="item", name="coal-dust", amount=2},
        {type="item", name="coarse", amount=3},
        {type="item", name="gravel", amount=21},
        {type="item", name="log", amount=1},
      },
      results = {
        {type="item", name="empty-comb", amount=4},
      },
    },
    ["fish-food-01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bones", amount=3},
        {type="item", name="brain", amount=1},
        {type="item", name="chromium", amount=20},
        {type="item", name="fertilizer", amount=5},
        {type="item", name="mukmoux-fat", amount=9},
        {type="item", name="saps", amount=3},
        {type="item", name="tar-barrel", amount=1},
      },
      results = {
        {type="item", name="fish-food-01", amount=3},
      },
    },
    ["flask-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="fluid", name="molten-glass", amount=93},
        {type="fluid", name="water", amount=803},
        {type="item", name="calcium-carbide", amount=35},
        {type="item", name="stopper", amount=1},
      },
      results = {
        {type="item", name="flask", amount=3},
      },
    },
    ["hotair-flask-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="fluid", name="molten-glass", amount=152},
        {type="fluid", name="water-saline", amount=93},
        {type="item", name="boron-trioxide", amount=5},
        {type="item", name="calcium-carbide", amount=29},
        {type="item", name="stopper", amount=7},
      },
      results = {
        {type="item", name="flask", amount=8},
      },
    },
    ["grade-2-lead-crusher"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="grade-1-copper", amount=2},
        {type="item", name="grade-1-lead", amount=5},
        {type="item", name="ore-tin", amount=6},
        {type="item", name="refined-hazard-concrete", amount=2},
      },
      results = {
        {type="item", name="grade-2-lead", amount=4},
        {type="item", name="stone", amount=4},
      },
    },
    ["grade-2-lead"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="grade-2-copper", amount=19},
      },
      results = {
        {type="item", name="grade-1-lead", amount=1},
        {type="item", name="grade-3-lead", amount=2},
      },
    },
    ["grade-2-crush-lead"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 5,
      ingredients = {
        {type="item", name="carbolic-oil-barrel", amount=3},
      },
      results = {
        {type="item", name="lead-dust", amount=5},
      },
    },
    ["molten-lead-01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.644444444444444,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=1},
        {type="item", name="melamine", amount=5},
      },
      results = {
        {type="fluid", name="molten-lead", amount=58},
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
      energy_required_multiplier = 0.94,
      ingredients = {
        {type="fluid", name="benzene", amount=994},
      },
      results = {
        {type="item", name="lead-plate", amount=47},
      },
    },
    ["grade-3-zinc"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.399580933591305,
      ingredients = {
        {type="item", name="grade-1-zinc", amount=2},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=19},
        {type="item", name="grade-3-zinc", amount=2},
      },
    },
    ["molten-zinc-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.45,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=1222},
        {type="fluid", name="pressured-water", amount=245},
        {type="fluid", name="water", amount=219},
        {type="item", name="grade-1-zinc", amount=6},
        {type="item", name="grade-2-zinc", amount=2},
        {type="item", name="pure-sand", amount=3},
      },
      results = {
        {type="fluid", name="molten-zinc", amount=29},
      },
    },
    ["zinc-plate-3"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.48,
      ingredients = {
        {type="fluid", name="molten-glass", amount=224},
        {type="item", name="grade-2-zinc", amount=1},
      },
      results = {
        {type="item", name="zinc-plate", amount=24},
      },
    },
    ["hotair-zinc-plate-3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.71428571428571,
      ingredients = {
        {type="fluid", name="methanol", amount=997},
        {type="fluid", name="molten-glass", amount=444},
        {type="item", name="coke", amount=5},
        {type="item", name="grade-1-zinc", amount=1},
        {type="item", name="graphite", amount=1},
      },
      results = {
        {type="item", name="zinc-plate", amount=108},
      },
    },
    ["molten-solder-0"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.65,
      ingredients = {
        {type="fluid", name="hot-air", amount=1632},
        {type="fluid", name="molten-tin", amount=9},
        {type="item", name="pure-sand", amount=13},
        {type="item", name="rich-clay", amount=7},
        {type="item", name="starch", amount=1},
      },
      results = {
        {type="fluid", name="molten-solder", amount=33},
      },
    },
    ["molten-solder-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2.325,
      ingredients = {
        {type="fluid", name="molten-tin", amount=15},
        {type="fluid", name="water-saline", amount=583},
        {type="item", name="carbolic-oil-barrel", amount=1},
        {type="item", name="grade-2-copper", amount=1},
      },
      results = {
        {type="fluid", name="molten-solder", amount=93},
      },
    },
    ["solder"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.6,
      ingredients = {
        {type="fluid", name="pressured-water", amount=3020},
        {type="fluid", name="water-saline", amount=219},
      },
      results = {
        {type="item", name="solder", amount=3},
      },
    },
    ["hotair-solder"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water-saline", amount=883},
      },
      results = {
        {type="item", name="solder", amount=7},
      },
    },
    ["molten-steel"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.41936558789584,
      ingredients = {
        {type="fluid", name="hot-air", amount=289},
        {type="fluid", name="molten-iron", amount=21},
        {type="item", name="moss", amount=8},
        {type="item", name="ralesia", amount=24},
        {type="item", name="tailings-dust", amount=3},
      },
      results = {
        {type="fluid", name="flue-gas", amount=707},
        {type="fluid", name="molten-steel", amount=71},
      },
    },
    ["hotair-steel-20"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.03125,
      ingredients = {
        {type="fluid", name="molten-steel", amount=26},
        {type="fluid", name="oxygen", amount=1643},
        {type="item", name="sand-casting", amount=2},
        {type="item", name="stopper", amount=1},
      },
      results = {
        {type="item", name="steel-plate", amount=33},
      },
    },
    ["steel-20"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.92,
      ingredients = {
        {type="fluid", name="molten-steel", amount=97},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="steel-plate", amount=23},
      },
    },
    ["kicalk-codex"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=55},
        {type="item", name="electronic-circuit", amount=37},
        {type="item", name="small-parts-01", amount=141},
      },
      results = {
        {type="item", name="kicalk-codex", amount=1},
      },
    },
    ["tuuphra-codex"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=21},
        {type="item", name="copper-cable", amount=51},
        {type="item", name="electronic-circuit", amount=17},
        {type="item", name="small-parts-01", amount=25},
        {type="item", name="steel-plate", amount=283},
        {type="item", name="tinned-cable", amount=15},
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
        {type="item", name="aluminium-plate", amount=19},
        {type="item", name="small-parts-01", amount=517},
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="yaedols-codex", amount=1},
      },
    },
    ["sea-sponge-codex"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="electronic-circuit", amount=51},
        {type="item", name="small-parts-01", amount=11},
      },
      results = {
        {type="item", name="sea-sponge-codex", amount=1},
      },
    },
    ["lard-from-brains"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="brain", amount=2},
        {type="item", name="chromium", amount=4},
        {type="item", name="fertilizer", amount=7},
        {type="item", name="guts", amount=41},
        {type="item", name="mukmoux-fat", amount=7},
        {type="item", name="plastic-bar", amount=9},
      },
      results = {
        {type="item", name="mukmoux-fat", amount=15},
      },
    },
    ["leaching-station-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="btx-barrel", amount=9},
        {type="item", name="glass", amount=21},
        {type="item", name="grade-3-zinc", amount=3},
        {type="item", name="gun-turret", amount=1},
        {type="item", name="inductor1", amount=12},
        {type="item", name="nexelit-plate", amount=84},
        {type="item", name="py-tank-9000", amount=1},
        {type="item", name="steam-engine", amount=5},
        {type="item", name="vitreloy", amount=6},
      },
      results = {
        {type="item", name="leaching-station-mk01", amount=1},
      },
    },
    ["wet-scrubber-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="duralumin", amount=85},
        {type="item", name="iron-stick", amount=75},
        {type="item", name="nexelit-plate", amount=13},
        {type="item", name="py-tank-10000", amount=2},
        {type="item", name="resistor1", amount=215},
        {type="item", name="tar-processing-unit", amount=3},
        {type="item", name="yaedols-spores", amount=29},
      },
      results = {
        {type="item", name="wet-scrubber-mk01", amount=3},
      },
    },
    ["methanol-from-syngas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.853333333333333,
      ingredients = {
        {type="fluid", name="flue-gas", amount=570},
        {type="item", name="bolts", amount=3},
        {type="item", name="copper-ore", amount=7},
      },
      results = {
        {type="fluid", name="methanol", amount=128},
      },
    },
    ["formamide"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.16,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=698},
        {type="fluid", name="methanol", amount=89},
        {type="item", name="acetylene-barrel", amount=1},
      },
      results = {
        {type="fluid", name="formamide", amount=116},
        {type="fluid", name="methanol", amount=89},
      },
    },
    ["military-science-pack"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="firearm-magazine", amount=5},
        {type="item", name="lead-plate", amount=23},
        {type="item", name="soot", amount=2},
        {type="item", name="stone-wall", amount=3},
      },
      results = {
        {type="item", name="military-science-pack", amount=3},
      },
    },
    ["niobium-mine"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="distilator", amount=4},
        {type="item", name="hpf", amount=1},
        {type="item", name="lead-plate", amount=296},
        {type="item", name="processed-iron-ore", amount=74},
        {type="item", name="steam-engine", amount=17},
      },
      results = {
        {type="item", name="niobium-mine", amount=1},
      },
    },
    ["nxsb-alloy"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="limestone", amount=14},
        {type="item", name="sb-oxide", amount=10},
      },
      results = {
        {type="item", name="nxsb-alloy", amount=3},
      },
    },
    ["pbsb-alloy-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="fluid", name="nitrogen", amount=1103},
        {type="fluid", name="pressured-air", amount=1798},
        {type="fluid", name="refsyngas", amount=266},
        {type="item", name="cellulose", amount=24},
      },
      results = {
        {type="item", name="pbsb-alloy", amount=6},
      },
    },
    ["powdered-phosphate-rock"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="item", name="acetylene-barrel", amount=1},
      },
      results = {
        {type="item", name="powdered-phosphate-rock", amount=7},
        {type="item", name="stone", amount=7},
      },
    },
    ["stone-wool"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=373},
        {type="item", name="coal-dust", amount=5},
        {type="item", name="stone", amount=17},
        {type="item", name="zinc-plate", amount=1},
      },
      results = {
        {type="item", name="stone-wool", amount=2},
      },
    },
    ["stone-wool2"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=465},
        {type="fluid", name="geothermal-water", amount=893},
        {type="item", name="calcium-carbide", amount=2},
        {type="item", name="coal-dust", amount=4},
      },
      results = {
        {type="item", name="stone-wool", amount=1},
      },
    },
    ["zipir-codex"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-stick", amount=20},
        {type="item", name="manure", amount=1},
        {type="item", name="steel-plate", amount=52},
      },
      results = {
        {type="item", name="zipir-codex", amount=2},
      },
    },
    ["zipir-eggs-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.259454502079939,
      ingredients = {
        {type="fluid", name="hot-air", amount=1116},
        {type="item", name="urea", amount=2},
      },
      results = {
        {type="fluid", name="waste-water", amount=55},
        {type="item", name="zipir-eggs", amount=1},
      },
    },
    ["zipir-reef-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=6},
        {type="item", name="boiler", amount=20},
        {type="item", name="fiberboard", amount=104},
        {type="item", name="gasifier", amount=12},
        {type="item", name="inductor1", amount=67},
        {type="item", name="iron-plate", amount=233},
        {type="item", name="lead-plate", amount=17},
        {type="item", name="micro-mine-mk01", amount=1},
        {type="item", name="oil-sand", amount=60},
        {type="item", name="outpost", amount=2},
        {type="item", name="steam-engine", amount=9},
        {type="item", name="stone-wall", amount=32},
      },
      results = {
        {type="item", name="zipir-reef-mk01", amount=1},
      },
    },
    ["zipir-a-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.23866730524923,
      ingredients = {
        {type="item", name="anthraquinone-barrel", amount=5},
        {type="item", name="fawogae-substrate", amount=13},
        {type="item", name="fish", amount=4},
        {type="item", name="organic-solvent-barrel", amount=2},
      },
      results = {
        {type="fluid", name="waste-water", amount=117},
        {type="item", name="zipir1", amount=1},
      },
    },
    ["zipir-a-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.41292968537821,
      ingredients = {
        {type="item", name="aluminium-plate", amount=3},
        {type="item", name="anthraquinone-barrel", amount=2},
        {type="item", name="fawogae-substrate", amount=2},
        {type="item", name="organic-solvent-barrel", amount=1},
        {type="item", name="stone-wool", amount=3},
        {type="item", name="zipir-eggs", amount=3},
      },
      results = {
        {type="fluid", name="waste-water", amount=133},
        {type="item", name="zipir1", amount=1},
      },
    },
    ["arthropod-blood-to-blood"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.79000433630682,
      ingredients = {
        {type="fluid", name="methanal", amount=1658},
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
        {type="item", name="carbolic-oil-barrel", amount=2},
        {type="item", name="carbon-black", amount=68},
        {type="item", name="empty-fuel-canister", amount=286},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="evaporator", amount=2},
        {type="item", name="grade-1-lead", amount=600},
        {type="item", name="oil-derrick-mk01", amount=1},
        {type="item", name="petri-dish", amount=136},
        {type="item", name="rich-clay", amount=1441},
        {type="item", name="small-parts-01", amount=498},
        {type="item", name="steel-chest", amount=5},
        {type="item", name="vitreloy", amount=2},
      },
      results = {
        {type="item", name="py-gas-powerplant-mk01", amount=1},
      },
    },
    ["ree-mining-drill-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="electric-mining-drill", amount=1},
        {type="item", name="inductor1", amount=172},
        {type="item", name="iron-plate", amount=55},
        {type="item", name="pipe", amount=79},
      },
      results = {
        {type="item", name="ree-mining-drill-mk01", amount=2},
      },
    },
    ["pyrite-make"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coarse", amount=10},
        {type="item", name="coke", amount=3},
      },
      results = {
        {type="item", name="pyrite", amount=1},
      },
    },
    ["rich-clay-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="fluid", name="tar", amount=19},
        {type="fluid", name="water", amount=421},
        {type="item", name="sand", amount=23},
      },
      results = {
        {type="item", name="rich-clay", amount=5},
      },
    },
    ["soot-to-aluminium"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.2374216562133,
      ingredients = {
        {type="item", name="chromium", amount=9},
        {type="item", name="glass", amount=4},
        {type="item", name="gravel", amount=12},
        {type="item", name="soot", amount=8},
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
        {type="item", name="soot", amount=9},
        {type="item", name="tailings-dust", amount=2},
      },
      results = {
        {type="item", name="ash", amount=1},
        {type="item", name="copper-ore", amount=8},
      },
    },
    ["soot-to-gold"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2.00864222742116,
      ingredients = {
        {type="fluid", name="water-saline", amount=186},
        {type="item", name="graphite", amount=7},
        {type="item", name="powdered-aluminium", amount=6},
        {type="item", name="soot", amount=10},
      },
      results = {
        {type="item", name="ash", amount=1},
        {type="item", name="gold-plate", amount=1},
      },
    },
    ["soot-to-iron"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.16036124874583,
      ingredients = {
        {type="item", name="tailings-dust", amount=44},
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
        {type="item", name="soot", amount=17},
        {type="item", name="tailings-dust", amount=61},
      },
      results = {
        {type="item", name="ash", amount=1},
        {type="item", name="silver-plate", amount=1},
      },
    },
    ["soot-to-zinc"] = {
      mode = "input-preserved-untransformed",
      science_level = 3,
      energy_required_multiplier = 1.0509390350894,
      ingredients = {
        {type="item", name="soot", amount=10},
      },
      results = {
        {type="item", name="ash", amount=1},
        {type="item", name="ore-zinc", amount=8},
      },
    },
    ["tailings-separation"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.570238744672319,
      ingredients = {
        {type="item", name="calcium-carbide", amount=5},
        {type="item", name="coke", amount=14},
      },
      results = {
        {type="item", name="coal-dust", amount=3},
        {type="item", name="rich-dust", amount=1},
      },
    },
    ["richdust-separation"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="calcium-carbide", amount=14},
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
        {type="item", name="soot", amount=14},
      },
      results = {
        {type="item", name="ash", amount=1},
        {type="item", name="ore-lead", amount=11},
      },
    },
    ["fetal-serum-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.78,
      ingredients = {
        {type="item", name="nickel-plate", amount=10},
        {type="item", name="skin", amount=16},
      },
      results = {
        {type="fluid", name="fetal-serum", amount=89},
      },
    },
    ["salt-ex"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.30434782608696,
      ingredients = {
        {type="fluid", name="hot-air", amount=184},
        {type="fluid", name="hydrogen", amount=71},
        {type="fluid", name="oxygen", amount=253},
      },
      results = {
        {type="item", name="salt", amount=30},
      },
    },
    ["sand-washing"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.864841344708497,
      ingredients = {
        {type="fluid", name="steam", amount=51},
        {type="item", name="biomass", amount=7},
        {type="item", name="coarse", amount=5},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=66},
        {type="item", name="pure-sand", amount=7},
      },
    },
    ["acetic-acid"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.04,
      ingredients = {
        {type="fluid", name="flue-gas", amount=156},
        {type="fluid", name="pressured-water", amount=576},
        {type="item", name="chromium", amount=1},
      },
      results = {
        {type="fluid", name="acetic-acid", amount=52},
      },
    },
    ["ammonia-urea"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.16,
      ingredients = {
        {type="item", name="coke", amount=2},
        {type="item", name="fertilizer", amount=4},
        {type="item", name="flask", amount=4},
        {type="item", name="meat", amount=5},
        {type="item", name="urea", amount=8},
      },
      results = {
        {type="fluid", name="ammonia", amount=116},
      },
    },
    ["organic-solvent2"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.987099240171005,
      ingredients = {
        {type="fluid", name="flue-gas", amount=416},
        {type="fluid", name="hot-air", amount=798},
        {type="item", name="coal", amount=3},
      },
      results = {
        {type="fluid", name="ammonia", amount=49},
        {type="fluid", name="organic-solvent", amount=99},
      },
    },
    ["phosphorous-acid"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.86,
      ingredients = {
        {type="item", name="auog-food-01", amount=1},
        {type="item", name="log", amount=1},
        {type="item", name="melamine-resin", amount=4},
      },
      results = {
        {type="fluid", name="phosphorous-acid", amount=43},
      },
    },
    ["tall-oil-separation"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.9,
      ingredients = {
        {type="fluid", name="light-oil", amount=8},
        {type="fluid", name="tall-oil", amount=8},
        {type="fluid", name="tar", amount=13},
        {type="item", name="biomass", amount=11},
      },
      results = {
        {type="fluid", name="aromatics", amount=9},
        {type="fluid", name="benzene", amount=9},
      },
    },
    ["tar-talloil"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.65897434890482,
      ingredients = {
        {type="fluid", name="hot-air", amount=480},
        {type="item", name="coarse", amount=10},
        {type="item", name="coke", amount=3},
      },
      results = {
        {type="fluid", name="aromatics", amount=33},
        {type="fluid", name="light-oil", amount=83},
        {type="fluid", name="tall-oil", amount=83},
      },
    },
    ["fluidize-coke"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.35373890490747,
      ingredients = {
        {type="fluid", name="flue-gas", amount=111},
        {type="item", name="copper-ore", amount=4},
        {type="item", name="copper-rejects", amount=1},
        {type="item", name="gravel", amount=7},
      },
      results = {
        {type="fluid", name="ammonia", amount=27},
        {type="fluid", name="tall-oil", amount=27},
        {type="fluid", name="tar", amount=41},
      },
    },
    ["methane-py-fertilizer"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.6375,
      ingredients = {
        {type="item", name="raw-fiber", amount=3},
      },
      results = {
        {type="fluid", name="methane", amount=51},
      },
    },
    ["phosphoric-acid"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.784204726928386,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=107},
        {type="fluid", name="phosphorous-acid", amount=31},
        {type="item", name="coal", amount=7},
      },
      results = {
        {type="fluid", name="hydrofluoric-acid", amount=8},
        {type="fluid", name="phosphine-gas", amount=8},
        {type="fluid", name="phosphoric-acid", amount=15},
      },
    },
    ["propene"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.466587861632509,
      ingredients = {
        {type="fluid", name="syngas", amount=50},
        {type="item", name="lead-plate", amount=2},
      },
      results = {
        {type="fluid", name="propene", amount=28},
        {type="fluid", name="water", amount=23},
      },
    },
    ["phosphoric-acid2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.975,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=575},
      },
      results = {
        {type="fluid", name="phosphoric-acid", amount=39},
      },
    },
    ["al-pulp-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.72,
      ingredients = {
        {type="fluid", name="water-saline", amount=537},
        {type="item", name="graphite", amount=7},
        {type="item", name="powdered-aluminium", amount=2},
      },
      results = {
        {type="fluid", name="al-pulp-01", amount=72},
      },
    },
    ["al-pulp-02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.23,
      ingredients = {
        {type="fluid", name="gasoline", amount=80},
        {type="fluid", name="water-saline", amount=1415},
        {type="item", name="coke", amount=6},
        {type="item", name="sand", amount=6},
      },
      results = {
        {type="fluid", name="al-pulp-02", amount=123},
      },
    },
    ["molten-aluminium-02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.94,
      ingredients = {
        {type="fluid", name="gasoline", amount=349},
        {type="item", name="coke", amount=8},
        {type="item", name="sand", amount=8},
      },
      results = {
        {type="fluid", name="molten-aluminium", amount=47},
      },
    },
    ["fluorine-gas"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.02,
      ingredients = {
        {type="fluid", name="kerosene", amount=1343},
        {type="item", name="ralesia", amount=3},
        {type="item", name="sodium-hydroxide", amount=10},
      },
      results = {
        {type="fluid", name="fluorine-gas", amount=51},
        {type="fluid", name="hydrogen", amount=51},
      },
    },
    ["syngas-distilation"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.811125492422799,
      ingredients = {
        {type="fluid", name="flue-gas", amount=480},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=41},
        {type="fluid", name="hydrogen", amount=81},
      },
    },
    ["gas-molten-salt-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.31,
      ingredients = {
        {type="fluid", name="fish-oil", amount=770},
        {type="fluid", name="tar", amount=565},
        {type="item", name="gravel", amount=1539},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=655},
      },
    },
    ["wastewater-recovery"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.14666666666667,
      ingredients = {
        {type="fluid", name="waste-water", amount=124},
        {type="item", name="crushed-coal", amount=2},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=172},
      },
    },
    ["glass-3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.96,
      ingredients = {
        {type="item", name="carbon-dioxide-barrel", amount=2},
        {type="item", name="purest-nitrogen-gas-barrel", amount=1},
      },
      results = {
        {type="fluid", name="molten-glass", amount=48},
      },
    },
    ["powdered-quartz"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.60371389147875,
      ingredients = {
        {type="fluid", name="ammonia", amount=153},
        {type="item", name="waste-water-barrel", amount=1},
      },
      results = {
        {type="item", name="gravel", amount=1},
        {type="item", name="powdered-quartz", amount=8},
      },
    },
    ["seaweed-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.9,
      ingredients = {
        {type="fluid", name="water", amount=1403},
        {type="item", name="coke", amount=3},
      },
      results = {
        {type="item", name="seaweed", amount=18},
      },
    },
    ["silver-plate-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.22222222222222,
      ingredients = {
        {type="item", name="car", amount=1},
        {type="item", name="diborane-barrel", amount=1},
        {type="item", name="methane-barrel", amount=3},
      },
      results = {
        {type="item", name="silver-plate", amount=11},
      },
    },
    ["sulfur-mine"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="cottongut-codex", amount=1},
        {type="item", name="cottongut-pup", amount=14},
        {type="item", name="grade-1-tin", amount=299},
        {type="item", name="grade-1-zinc", amount=219},
        {type="item", name="grade-2-tin", amount=168},
        {type="item", name="moondrop", amount=107},
        {type="item", name="shaft-mk01", amount=6},
        {type="item", name="storage-chest", amount=3},
        {type="item", name="subcritical-water-barrel", amount=89},
      },
      results = {
        {type="item", name="sulfur-mine", amount=2},
      },
    },
    ["albumin-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ammonia", amount=597},
        {type="fluid", name="methanal", amount=504},
        {type="item", name="ash", amount=16},
        {type="item", name="mukmoux-fat", amount=10},
        {type="item", name="sand", amount=4},
      },
      results = {
        {type="item", name="albumin", amount=5},
      },
    },
    ["formaldehyde-from-refined-natural-gas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.498684996142314,
      ingredients = {
        {type="fluid", name="refined-natural-gas", amount=77},
        {type="fluid", name="water-saline", amount=448},
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
      energy_required_multiplier = 0.7,
      ingredients = {
        {type="item", name="biomass", amount=14},
      },
      results = {
        {type="item", name="powdered-biomass", amount=14},
      },
    },
    ["sugar"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="fluid", name="hot-residual-mixture", amount=1032},
        {type="fluid", name="lubricant", amount=1635},
        {type="item", name="calcium-carbide", amount=6},
        {type="item", name="powdered-aluminium", amount=2},
        {type="item", name="syngas-barrel", amount=1},
      },
      results = {
        {type="item", name="sugar", amount=16},
      },
    },
    ["waste-water-urea"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="waste-water", amount=152},
      },
      results = {
        {type="item", name="urea", amount=8},
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
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="fluid", name="pressured-air", amount=27},
        {type="item", name="biomass", amount=5},
        {type="item", name="coal-dust", amount=5},
      },
      results = {
        {type="item", name="fungal-substrate", amount=5},
      },
    },
    ["dried-biomass"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.36666666666667,
      ingredients = {
        {type="item", name="coke", amount=1},
        {type="item", name="oil-sand", amount=1},
        {type="item", name="soot", amount=2},
      },
      results = {
        {type="item", name="dried-biomass", amount=41},
      },
    },
    ["fungal-substrate-02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="coke", amount=6},
        {type="item", name="fertilizer", amount=5},
        {type="item", name="flask", amount=2},
        {type="item", name="meat", amount=3},
        {type="item", name="powdered-biomass", amount=8},
      },
      results = {
        {type="item", name="fungal-substrate-02", amount=8},
      },
    },
    ["fiber"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="raw-fiber", amount=10},
      },
      results = {
        {type="item", name="biomass", amount=6},
        {type="item", name="fiber", amount=5},
      },
    },
    ["micro-fiber"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bonemeal", amount=2},
        {type="item", name="ceramic", amount=3},
      },
      results = {
        {type="item", name="micro-fiber", amount=2},
      },
    },
    ["bitumen-to-nickel"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="propene", amount=48},
        {type="fluid", name="subcritical-water", amount=727},
      },
      results = {
        {type="item", name="ore-nickel", amount=10},
      },
    },
    ["grade-3-nickel"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 4,
      ingredients = {
        {type="fluid", name="acidgas", amount=73},
        {type="item", name="grade-1-chromite", amount=7},
      },
      results = {
        {type="item", name="grade-2-nickel", amount=4},
        {type="item", name="grade-3-nickel", amount=2},
        {type="item", name="gravel", amount=4},
        {type="item", name="nickel-rejects", amount=4},
      },
    },
    ["grade-2-nickel-recrush"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 6,
      ingredients = {
        {type="item", name="condensates-canister", amount=5},
      },
      results = {
        {type="item", name="grade-1-nickel", amount=3},
        {type="item", name="sand", amount=6},
      },
    },
    ["grade-4-nickel"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="water", amount=439},
        {type="item", name="nickel-rejects", amount=2},
        {type="item", name="sand", amount=61},
      },
      results = {
        {type="item", name="grade-4-nickel", amount=2},
      },
    },
    ["nickel-rejects-recrush"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="stopper", amount=13},
      },
      results = {
        {type="item", name="grade-1-nickel", amount=1},
      },
    },
    ["molten-nickel-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.14,
      ingredients = {
        {type="item", name="nickel-rejects", amount=6},
        {type="item", name="stopper", amount=4},
      },
      results = {
        {type="fluid", name="molten-nickel", amount=57},
      },
    },
    ["hotair-nickel-plate-3"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.428571428571429,
      ingredients = {
        {type="fluid", name="pressured-air", amount=12077},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="nickel-plate", amount=27},
      },
    },
    ["nickel-plate-3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.86,
      ingredients = {
        {type="fluid", name="acidgas", amount=1241},
        {type="fluid", name="pressured-air", amount=25655},
        {type="item", name="sand-casting", amount=2},
      },
      results = {
        {type="item", name="nickel-plate", amount=93},
      },
    },
    ["tar-to-nickel"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="ammonia", amount=174},
        {type="fluid", name="carbon-dioxide", amount=381},
      },
      results = {
        {type="item", name="ore-nickel", amount=8},
      },
    },
    ["soda-ash"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.285,
      ingredients = {
        {type="fluid", name="steam", amount=1163},
        {type="fluid", name="water", amount=241},
        {type="item", name="ash", amount=65},
        {type="item", name="biomass", amount=17},
        {type="item", name="moss", amount=3},
      },
      results = {
        {type="fluid", name="soda-ash", amount=257},
      },
    },
    ["industrial-solvent"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.33,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=5804},
        {type="fluid", name="pressured-water", amount=3400},
        {type="fluid", name="purest-nitrogen-gas", amount=853},
        {type="item", name="sulfur", amount=9},
      },
      results = {
        {type="fluid", name="industrial-solvent", amount=133},
      },
    },
    ["vanabins"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.22,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=1129},
        {type="fluid", name="diborane", amount=654},
        {type="fluid", name="hot-air", amount=741},
        {type="fluid", name="muddy-sludge", amount=854},
      },
      results = {
        {type="fluid", name="vanabins", amount=122},
      },
    },
    ["blue-liquor"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.605,
      ingredients = {
        {type="fluid", name="coal-slurry", amount=1828},
        {type="fluid", name="methanal", amount=2261},
        {type="item", name="calcium-carbide", amount=44},
        {type="item", name="grade-2-iron", amount=1},
      },
      results = {
        {type="fluid", name="blue-liquor", amount=321},
      },
    },
    ["vpulp1"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.94,
      ingredients = {
        {type="fluid", name="pressured-steam", amount=15416},
      },
      results = {
        {type="fluid", name="vpulp1", amount=94},
      },
    },
    ["molybdenum-pulp"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.76,
      ingredients = {
        {type="item", name="grade-1-copper", amount=21},
      },
      results = {
        {type="fluid", name="molybdenum-pulp", amount=76},
        {type="fluid", name="muddy-sludge", amount=152},
      },
    },
    ["vpulp2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.11,
      ingredients = {
        {type="fluid", name="pressured-steam", amount=25546},
        {type="item", name="drill-head", amount=2},
        {type="item", name="limestone", amount=35},
        {type="item", name="sand", amount=35},
        {type="item", name="sb-oxide", amount=3},
      },
      results = {
        {type="fluid", name="vpulp2", amount=111},
      },
    },
    ["molybdenite-pulp"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=139},
        {type="item", name="low-distillate-canister", amount=1},
      },
      results = {
        {type="fluid", name="molybdenite-pulp", amount=75},
      },
    },
    ["vpulp3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.888620104757543,
      ingredients = {
        {type="fluid", name="acidgas", amount=1109},
        {type="fluid", name="geothermal-water", amount=1808},
        {type="fluid", name="pitch", amount=642},
        {type="item", name="redhot-coke", amount=17},
      },
      results = {
        {type="fluid", name="vpulp3", amount=42},
        {type="item", name="vanadium-oxide", amount=2},
      },
    },
    ["bitumen-to-asphalt"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="bitumen", amount=4},
        {type="fluid", name="flue-gas", amount=279},
        {type="fluid", name="hot-air", amount=70},
        {type="item", name="stone", amount=2},
      },
      results = {
        {type="item", name="py-asphalt", amount=3},
      },
    },
    ["py-aluminium"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="coke", amount=7},
        {type="item", name="grade-2-lead", amount=1},
        {type="item", name="oil-sand", amount=10},
      },
      results = {
        {type="item", name="py-aluminium", amount=2},
      },
    },
    ["py-coal-tile"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="hot-air", amount=185},
        {type="fluid", name="medium-distillate", amount=18},
        {type="item", name="coal-dust", amount=4},
        {type="item", name="gravel", amount=36},
        {type="item", name="moondrop-seeds", amount=10},
      },
      results = {
        {type="item", name="py-coal-tile", amount=2},
      },
    },
    ["py-iron"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2.5,
      ingredients = {
        {type="fluid", name="organic-solvent", amount=7},
        {type="item", name="iron-gear-wheel", amount=1},
        {type="item", name="iron-ore", amount=12},
        {type="item", name="tailings-barrel", amount=1},
      },
      results = {
        {type="item", name="py-iron", amount=5},
      },
    },
    ["py-nexelit"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="tar", amount=11},
        {type="item", name="biomass", amount=70},
        {type="item", name="nexelit-plate", amount=1},
      },
      results = {
        {type="item", name="py-nexelit", amount=2},
      },
    },
    ["py-quartz"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="hot-air", amount=324},
        {type="item", name="ore-titanium", amount=2},
        {type="item", name="tailings-barrel", amount=1},
      },
      results = {
        {type="item", name="py-quartz", amount=3},
      },
    },
    ["py-steel"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="molten-steel", amount=14},
        {type="item", name="crushed-quartz", amount=1},
      },
      results = {
        {type="item", name="py-steel", amount=3},
      },
    },
    ["hydrogen-chloride"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.13,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=302},
        {type="fluid", name="water-saline", amount=226},
        {type="item", name="grade-2-copper", amount=9},
        {type="item", name="small-lamp", amount=1},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=113},
        {type="item", name="small-lamp", amount=1},
      },
    },
    ["methanol-void-denitrification"] = {
      mode = "input-preserved-untransformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="methanol", amount=100},
        {type="fluid", name="waste-water", amount=100},
      },
      results = {
        {type="fluid", name="nitrogen", amount=100},
        {type="fluid", name="water", amount=100},
      },
    },
    ["purest-nitrogen-gas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.409649337039945,
      ingredients = {
        {type="fluid", name="pressured-air", amount=42},
      },
      results = {
        {type="fluid", name="nitrogen", amount=8},
        {type="fluid", name="oxygen", amount=8},
        {type="fluid", name="purest-nitrogen-gas", amount=25},
      },
    },
    ["hcl-from-guts"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.24,
      ingredients = {
        {type="fluid", name="pressured-water", amount=301},
        {type="item", name="skin", amount=1},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=12},
      },
    },
    ["nitrogen"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.35,
      ingredients = {
        {type="fluid", name="flue-gas", amount=431},
        {type="fluid", name="molten-steel", amount=1},
        {type="item", name="lime", amount=4},
      },
      results = {
        {type="fluid", name="nitrogen", amount=270},
      },
    },
    ["sulfuric-acid-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.94,
      ingredients = {
        {type="fluid", name="acidgas", amount=97},
      },
      results = {
        {type="fluid", name="sulfuric-acid", amount=47},
      },
    },
    ["zinc-chloride"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.997338001879981,
      ingredients = {
        {type="fluid", name="hydrogen-chloride", amount=19},
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
        {type="item", name="pure-sand", amount=17},
        {type="item", name="rich-clay", amount=9},
        {type="item", name="starch", amount=1},
      },
      results = {
        {type="item", name="active-carbon", amount=4},
      },
    },
    ["co2-organics"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.0966666666666667,
      ingredients = {
        {type="item", name="biomass", amount=1},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=29},
      },
    },
    ["drill-head"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="item", name="carbon-dioxide-barrel", amount=4},
        {type="item", name="coke", amount=2},
        {type="item", name="copper-plate", amount=2},
        {type="item", name="iron-plate", amount=16},
      },
      results = {
        {type="item", name="drill-head", amount=4},
      },
    },
    ["drill-head-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="coal-dust", amount=6},
        {type="item", name="iron-plate", amount=8},
        {type="item", name="lead-plate", amount=5},
      },
      results = {
        {type="item", name="drill-head", amount=2},
      },
    },
    ["drill-head-3"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 3.33333333333333,
      ingredients = {
        {type="item", name="lead-plate", amount=31},
        {type="item", name="pipe", amount=12},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="stone-wall", amount=2},
      },
      results = {
        {type="item", name="drill-head", amount=20},
      },
    },
    ["nichrome"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=415},
        {type="item", name="lime", amount=6},
        {type="item", name="nickel-plate", amount=7},
      },
      results = {
        {type="item", name="nichrome", amount=1},
      },
    },
    ["evaporate-nitrogen"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.96,
      ingredients = {
        {type="fluid", name="liquid-nitrogen", amount=5},
      },
      results = {
        {type="fluid", name="nitrogen", amount=48},
      },
    },
    ["liquid-nitrogen"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="gasoline", amount=5},
        {type="fluid", name="hydrogen", amount=114},
        {type="fluid", name="pressured-air", amount=67},
      },
      results = {
        {type="fluid", name="liquid-nitrogen", amount=5},
        {type="fluid", name="steam", amount=100},
      },
    },
    ["coalbed-gas-to-hydrogen"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.733333333333333,
      ingredients = {
        {type="fluid", name="pressured-steam", amount=2454},
        {type="item", name="chromium", amount=5},
      },
      results = {
        {type="fluid", name="hydrogen", amount=220},
      },
    },
    ["drilling-fluid-0"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.9,
      ingredients = {
        {type="fluid", name="hot-air", amount=106},
        {type="item", name="limestone", amount=2},
        {type="item", name="melamine", amount=7},
        {type="item", name="sand", amount=5},
        {type="item", name="warm-stone-brick", amount=5},
      },
      results = {
        {type="fluid", name="drilling-fluid-0", amount=95},
      },
    },
    ["minor-extract-gas-from-coalbed-3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.952406683307917,
      ingredients = {
        {type="fluid", name="flue-gas", amount=581},
        {type="fluid", name="steam", amount=184},
        {type="fluid", name="tailings", amount=267},
        {type="item", name="chromium", amount=3},
        {type="item", name="grade-1-iron", amount=2},
        {type="item", name="sb-grade-01", amount=2},
      },
      results = {
        {type="fluid", name="coalbed-gas", amount=143},
        {type="fluid", name="water", amount=2377},
      },
    },
    ["pressured-hydrogen"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="gasoline", amount=5},
        {type="fluid", name="hot-air", amount=154},
        {type="fluid", name="oxygen", amount=250},
      },
      results = {
        {type="fluid", name="pressured-hydrogen", amount=50},
        {type="fluid", name="steam", amount=600},
      },
    },
    ["aromatics-2-diesel2"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.22666666666667,
      ingredients = {
        {type="fluid", name="light-oil", amount=453},
        {type="fluid", name="water", amount=488},
        {type="item", name="chromite-sand", amount=1},
        {type="item", name="chromium", amount=1},
      },
      results = {
        {type="fluid", name="diesel", amount=368},
      },
    },
    ["coalbed-gas-to-acidgas"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.787075254298202,
      ingredients = {
        {type="fluid", name="hot-air", amount=106},
        {type="fluid", name="oxygen", amount=194},
        {type="fluid", name="water-saline", amount=168},
      },
      results = {
        {type="fluid", name="acidgas", amount=118},
        {type="fluid", name="flue-gas", amount=709},
      },
    },
    ["coalbed-gas-to-co2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.57,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=1626},
        {type="fluid", name="oxygen", amount=763},
        {type="item", name="scrude-canister", amount=1},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=471},
      },
    },
    ["coalbed-gas-to-coalgas"] = {
      mode = "repaired-to-input",
      science_level = 3,
      energy_required_multiplier = 1.03,
      ingredients = {
        {type="fluid", name="pitch", amount=565},
        {type="item", name="diesel-barrel", amount=1},
      },
      results = {
        {type="fluid", name="coal-gas", amount=412},
      },
    },
    ["coalbed-gas-to-syngas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.17,
      ingredients = {
        {type="fluid", name="coalbed-gas", amount=153},
        {type="fluid", name="geothermal-water", amount=854},
        {type="fluid", name="pressured-steam", amount=654},
        {type="item", name="chromium", amount=4},
        {type="item", name="vacuum-tube", amount=1},
      },
      results = {
        {type="fluid", name="syngas", amount=234},
      },
    },
    ["natural-gas-to-syngas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.822521364754888,
      ingredients = {
        {type="fluid", name="heavy-oil", amount=9},
        {type="fluid", name="natural-gas", amount=77},
      },
      results = {
        {type="fluid", name="flue-gas", amount=165},
        {type="fluid", name="syngas", amount=41},
      },
    },
    ["quench-ovengas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.95358880554399,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=97},
      },
      results = {
        {type="fluid", name="flue-gas", amount=955},
        {type="fluid", name="syngas", amount=95},
      },
    },
    ["light-oil_from_syngas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.566339205730417,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=523},
        {type="fluid", name="flue-gas", amount=904},
        {type="item", name="clean-nexelit", amount=8},
        {type="item", name="coke", amount=1},
        {type="item", name="rail", amount=1},
      },
      results = {
        {type="fluid", name="light-oil", amount=170},
        {type="fluid", name="olefin", amount=85},
        {type="fluid", name="steam", amount=1131},
      },
    },
    ["petgas-from-refsyngas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.36725732512399,
      ingredients = {
        {type="fluid", name="aromatics", amount=377},
        {type="fluid", name="boric-acid", amount=268},
        {type="fluid", name="subcritical-water", amount=1575},
        {type="item", name="lead-dust", amount=1},
        {type="item", name="pipe", amount=3},
      },
      results = {
        {type="fluid", name="olefin", amount=205},
        {type="fluid", name="petroleum-gas", amount=547},
      },
    },
    ["bone-solvent"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.84,
      ingredients = {
        {type="fluid", name="olefin", amount=97},
        {type="item", name="bones", amount=7},
        {type="item", name="lime", amount=1},
      },
      results = {
        {type="fluid", name="organic-solvent", amount=42},
      },
    },
    ["dedicated-oleochemicals"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.516,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=154},
        {type="item", name="mukmoux-fat", amount=11},
      },
      results = {
        {type="fluid", name="oleochemicals", amount=129},
        {type="fluid", name="steam", amount=1032},
      },
    },
    ["oleochemicals"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.53338692226417,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=363},
        {type="fluid", name="oxygen", amount=152},
        {type="item", name="barrel", amount=2},
        {type="item", name="mukmoux-fat", amount=33},
      },
      results = {
        {type="fluid", name="glycerol", amount=230},
        {type="fluid", name="oleochemicals", amount=460},
        {type="fluid", name="steam", amount=3068},
      },
    },
    ["petgas-methanol"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.98,
      ingredients = {
        {type="fluid", name="flue-gas", amount=728},
        {type="fluid", name="tailings", amount=66},
        {type="fluid", name="tar", amount=206},
      },
      results = {
        {type="fluid", name="methanol", amount=98},
        {type="fluid", name="petroleum-gas", amount=98},
      },
    },
    ["fish-oil-to-lube"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.48,
      ingredients = {
        {type="fluid", name="heavy-oil", amount=17},
        {type="fluid", name="methanal", amount=295},
        {type="fluid", name="sulfuric-acid", amount=5},
      },
      results = {
        {type="fluid", name="lubricant", amount=48},
      },
    },
    ["olefin-lube"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.42,
      ingredients = {
        {type="fluid", name="methanol", amount=197},
        {type="fluid", name="pressured-water", amount=1765},
      },
      results = {
        {type="fluid", name="lubricant", amount=105},
      },
    },
    ["coal-slurry"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.18,
      ingredients = {
        {type="fluid", name="tar", amount=100},
        {type="item", name="lime", amount=2},
        {type="item", name="moondrop-seeds", amount=5},
      },
      results = {
        {type="fluid", name="coal-slurry", amount=177},
        {type="fluid", name="water", amount=118},
      },
    },
    ["refsyngas-from-filtered-syngas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.771428571428571,
      ingredients = {
        {type="fluid", name="flue-gas", amount=161},
        {type="item", name="grade-2-zinc", amount=1},
      },
      results = {
        {type="fluid", name="refsyngas", amount=54},
      },
    },
    ["fluegas-to-syngas"] = {
      mode = "repaired-to-input",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="coal-gas", amount=389},
        {type="item", name="capacitor1", amount=4},
      },
      results = {
        {type="fluid", name="syngas", amount=300},
      },
    },
    ["hydrogen-peroxide"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="fluid", name="hot-air", amount=86},
        {type="fluid", name="water-saline", amount=365},
        {type="item", name="lime", amount=3},
        {type="item", name="nickel-plate", amount=8},
        {type="item", name="titanium-plate", amount=3},
      },
      results = {
        {type="fluid", name="hydrogen-peroxide", amount=70},
      },
    },
    ["syngas2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.02273272970029,
      ingredients = {
        {type="fluid", name="flue-gas", amount=541},
        {type="fluid", name="steam", amount=108},
        {type="fluid", name="water", amount=77},
      },
      results = {
        {type="fluid", name="syngas", amount=102},
        {type="fluid", name="tar", amount=31},
        {type="item", name="ash", amount=1},
      },
    },
    ["coal-slurry-fuel"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.06,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=195},
        {type="fluid", name="flue-gas", amount=1551},
        {type="item", name="chromite-sand", amount=7},
      },
      results = {
        {type="fluid", name="aromatics", amount=53},
        {type="fluid", name="benzene", amount=53},
      },
    },
    ["acidgas"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.853333333333333,
      ingredients = {
        {type="fluid", name="pressured-water", amount=1210},
        {type="item", name="sulfur", amount=10},
      },
      results = {
        {type="fluid", name="acidgas", amount=128},
      },
    },
    ["acidgas-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.433333333333333,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=284},
        {type="fluid", name="syngas", amount=215},
      },
      results = {
        {type="fluid", name="acidgas", amount=13},
        {type="fluid", name="steam", amount=260},
      },
    },
    ["pyrite-burn"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 4.3266318354794,
      ingredients = {
        {type="item", name="naphthalene-oil-barrel", amount=3},
        {type="item", name="sodium-alginate", amount=4},
      },
      results = {
        {type="fluid", name="acidgas", amount=215},
        {type="item", name="iron-oxide", amount=52},
      },
    },
    ["log4"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="steam", amount=69},
        {type="item", name="cellulose", amount=4},
      },
      results = {
        {type="item", name="log", amount=4},
      },
    },
    ["log5"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.14285714285714,
      ingredients = {
        {type="fluid", name="hot-air", amount=199},
        {type="fluid", name="steam", amount=258},
        {type="fluid", name="vacuum", amount=735},
        {type="item", name="cellulose", amount=2},
        {type="item", name="wood-seedling", amount=3},
      },
      results = {
        {type="item", name="log", amount=8},
      },
    },
    ["log6"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.625,
      ingredients = {
        {type="fluid", name="hot-air", amount=80},
        {type="fluid", name="pressured-water", amount=664},
        {type="item", name="ash", amount=28},
        {type="item", name="gravel", amount=4},
        {type="item", name="lime", amount=3},
      },
      results = {
        {type="item", name="log", amount=5},
      },
    },
    ["wood-seedling-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="scrude", amount=54},
        {type="item", name="hydrogen-barrel", amount=8},
        {type="item", name="rich-clay", amount=4},
      },
      results = {
        {type="item", name="wood-seedling-mk02", amount=1},
      },
    },
    ["wood-seeds-mk02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 4.01461047716582,
      ingredients = {
        {type="item", name="plasmids", amount=5},
        {type="item", name="tree-mk01", amount=4},
      },
      results = {
        {type="item", name="wood-seeds", amount=2},
        {type="item", name="wood-seeds-mk02", amount=0.0202947382758099},
      },
    },
    ["wood-seeds-mk02-breeder"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="tree-mk02", amount=1},
      },
      results = {
        {type="item", name="wood-seeds-mk02", amount=5},
      },
    },
    ["tree-mk02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=439},
        {type="fluid", name="pressured-steam", amount=8694},
        {type="fluid", name="steam", amount=450},
        {type="item", name="aluminium-plate", amount=8},
        {type="item", name="empty-planter-box", amount=10},
      },
      results = {
        {type="item", name="tree-mk02", amount=1},
      },
    },
    ["ulric"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="aluminium-plate", amount=520},
        {type="item", name="coal-dust", amount=807},
        {type="item", name="earth-generic-sample", amount=5},
        {type="item", name="earth-mouse-sample", amount=2},
        {type="item", name="methanol-reactor", amount=5},
        {type="item", name="yaedols-spores", amount=44},
        {type="item", name="zipir-codex", amount=7},
      },
      results = {
        {type="item", name="ulric", amount=4},
      },
    },
    ["ulric-codex"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coke", amount=55},
        {type="item", name="copper-cable", amount=48},
        {type="item", name="electronic-circuit", amount=10},
      },
      results = {
        {type="item", name="ulric-codex", amount=1},
      },
    },
    ["ulric-corral-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=22},
        {type="item", name="burner-inserter", amount=2},
        {type="item", name="duralumin", amount=28},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="muddy-sludge-barrel", amount=10},
        {type="item", name="pipe", amount=21},
      },
      results = {
        {type="item", name="ulric-corral-mk01", amount=1},
      },
    },
    ["ulric-food-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="hot-air", amount=210},
        {type="fluid", name="pressured-water", amount=2271},
        {type="fluid", name="steam", amount=99},
        {type="item", name="ash", amount=14},
        {type="item", name="drill-head", amount=1},
        {type="item", name="fertilizer", amount=1},
        {type="item", name="light-oil-barrel", amount=1},
        {type="item", name="lime", amount=10},
        {type="item", name="ore-quartz", amount=20},
        {type="item", name="urea", amount=2},
        {type="item", name="zinc-plate", amount=2},
      },
      results = {
        {type="item", name="ulric-food-01", amount=12},
      },
    },
    ["ulric-cub-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.3745714675513,
      ingredients = {
        {type="item", name="ralesia", amount=6},
        {type="item", name="raw-fiber", amount=3},
        {type="item", name="tall-oil-barrel", amount=2},
        {type="item", name="tar-barrel", amount=1},
        {type="item", name="water-barrel", amount=14},
        {type="item", name="wood-seedling", amount=3},
      },
      results = {
        {type="item", name="barrel", amount=21},
        {type="item", name="ulric-cub", amount=4},
      },
    },
    ["ulric-manure-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.27686739246527,
      ingredients = {
        {type="item", name="ralesia", amount=19},
        {type="item", name="tall-oil-barrel", amount=2},
        {type="item", name="wood-seedling", amount=1},
      },
      results = {
        {type="item", name="barrel", amount=6},
        {type="item", name="manure", amount=4},
      },
    },
    ["ulric-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.34811594078388,
      ingredients = {
        {type="item", name="creamy-latex-barrel", amount=3},
        {type="item", name="dried-meat", amount=2},
        {type="item", name="ralesia", amount=12},
        {type="item", name="sodium-hydroxide", amount=8},
        {type="item", name="steel-plate", amount=5},
        {type="item", name="ulric-food-01", amount=1},
        {type="item", name="water-barrel", amount=4},
      },
      results = {
        {type="item", name="barrel", amount=7},
        {type="item", name="ulric", amount=4},
      },
    },
    ["earth-cow-sample"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=329},
        {type="item", name="bio-sample", amount=40},
        {type="item", name="display-panel", amount=12},
        {type="item", name="py-science-pack-1", amount=24},
      },
      results = {
        {type="item", name="earth-cow-sample", amount=2},
      },
    },
    ["earth-crustacean-sample"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=767},
        {type="item", name="boiler", amount=29},
        {type="item", name="py-science-pack-1", amount=3},
      },
      results = {
        {type="item", name="earth-crustacean-sample", amount=1},
      },
    },
    ["earth-palmtree-sample"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cdna", amount=1},
        {type="item", name="logistic-science-pack", amount=26},
        {type="item", name="sea-sponge-codex", amount=1},
      },
      results = {
        {type="item", name="earth-palmtree-sample", amount=1},
      },
    },
    ["earth-potato-sample"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="automation-science-pack", amount=11},
        {type="item", name="empty-fuel-canister", amount=50},
        {type="item", name="evaporator", amount=1},
        {type="item", name="grade-1-lead", amount=327},
        {type="item", name="kicalk-codex", amount=1},
        {type="item", name="oil-derrick-mk01", amount=1},
        {type="item", name="petri-dish", amount=190},
        {type="item", name="py-science-pack-1", amount=206},
        {type="item", name="rich-clay", amount=785},
        {type="item", name="small-parts-01", amount=271},
        {type="item", name="vitreloy", amount=3},
      },
      results = {
        {type="item", name="earth-potato-sample", amount=2},
      },
    },
    ["earth-sea-sponge-sample"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="cdna", amount=3},
        {type="item", name="cottongut-codex", amount=2},
        {type="item", name="logistic-science-pack", amount=82},
        {type="item", name="py-science-pack-1", amount=166},
        {type="item", name="sea-sponge-codex", amount=3},
        {type="item", name="steel-chest", amount=62},
      },
      results = {
        {type="item", name="earth-sea-sponge-sample", amount=4},
      },
    },
    ["earth-bee-sample"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="aluminium-plate", amount=159},
        {type="item", name="coke", amount=11293},
        {type="item", name="fbreactor-mk01", amount=3},
        {type="item", name="grade-2-iron", amount=773},
        {type="item", name="kicalk-codex", amount=1},
        {type="item", name="pipe", amount=2320},
        {type="item", name="py-science-pack-1", amount=10},
      },
      results = {
        {type="item", name="earth-bee-sample", amount=3},
      },
    },
    ["earth-horse-sample"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bio-sample", amount=3},
        {type="item", name="fbreactor-mk01", amount=6},
        {type="item", name="grade-2-iron", amount=195},
        {type="item", name="pipe", amount=103},
        {type="item", name="py-science-pack-1", amount=7},
        {type="item", name="steel-chest", amount=2},
      },
      results = {
        {type="item", name="earth-horse-sample", amount=1},
      },
    },
    ["kicalk-sample"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="lab-instrument", amount=109},
        {type="item", name="moss-gen", amount=109},
        {type="item", name="sea-sponge-codex", amount=1},
      },
      results = {
        {type="item", name="kicalk", amount=2},
      },
    },
    ["kicalk-fiber"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="kicalk", amount=1},
      },
      results = {
        {type="item", name="raw-fiber", amount=5},
      },
    },
    ["kicalk-seeds"] = {
      mode = "repaired-to-input",
      science_level = 3,
      energy_required_multiplier = 1.8,
      ingredients = {
        {type="item", name="grade-2-tin", amount=1},
      },
      results = {
        {type="item", name="kicalk-seeds", amount=9},
      },
    },
    ["kicalk-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="item", name="coke", amount=4},
        {type="item", name="grade-3-iron", amount=1},
        {type="item", name="refined-hazard-concrete", amount=7},
      },
      results = {
        {type="item", name="kicalk", amount=14},
      },
    },
    ["kicalk-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2.08333333333333,
      ingredients = {
        {type="fluid", name="hot-air", amount=364},
        {type="item", name="coke", amount=12},
        {type="item", name="grade-3-iron", amount=3},
        {type="item", name="small-lamp", amount=2},
      },
      results = {
        {type="item", name="kicalk", amount=25},
      },
    },
    ["sea-sponge"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=167},
        {type="item", name="earth-bear-sample", amount=1},
        {type="item", name="lab-instrument", amount=7},
        {type="item", name="moondrop-codex", amount=14},
      },
      results = {
        {type="item", name="sea-sponge", amount=1},
      },
    },
    ["sea-sponge-sprouts"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=492},
        {type="item", name="tar-barrel", amount=5},
      },
      results = {
        {type="item", name="sea-sponge-sprouts", amount=2},
      },
    },
    ["sea-sponge-processing-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="item", name="fertilizer", amount=1},
        {type="item", name="sea-sponge-sprouts", amount=2},
        {type="item", name="tar-barrel", amount=2},
      },
      results = {
        {type="item", name="ore-quartz", amount=14},
      },
    },
    ["sea-sponge-sprouts-processing-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.571428571428571,
      ingredients = {
        {type="item", name="planter-box", amount=1},
      },
      results = {
        {type="item", name="ore-quartz", amount=4},
      },
    },
    ["arthropod-blood-to-organic-solvent"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.907692307692308,
      ingredients = {
        {type="fluid", name="diborane", amount=815},
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
      energy_required_multiplier = 0.142857142857143,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=1},
        {type="item", name="sand", amount=3},
      },
      results = {
        {type="fluid", name="tar", amount=10},
      },
    },
    ["cobalt-extract"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.33119420789709,
      ingredients = {
        {type="fluid", name="methanal", amount=902},
        {type="fluid", name="pressured-water", amount=7236},
        {type="item", name="fish-oil-barrel", amount=1},
      },
      results = {
        {type="fluid", name="tailings", amount=63},
        {type="item", name="cobalt-extract", amount=4},
      },
    },
    ["flue-gas-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="fluid", name="pressured-air", amount=850},
        {type="fluid", name="vacuum", amount=31},
        {type="item", name="ash", amount=8},
      },
      results = {
        {type="fluid", name="flue-gas", amount=250},
      },
    },
    ["gasoline"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.553333333333333,
      ingredients = {
        {type="fluid", name="aromatics", amount=170},
        {type="fluid", name="subcritical-water", amount=630},
        {type="item", name="coal-dust", amount=5},
        {type="item", name="pipe", amount=1},
      },
      results = {
        {type="fluid", name="gasoline", amount=83},
      },
    },
    ["olefin"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.825,
      ingredients = {
        {type="fluid", name="steam", amount=753},
        {type="item", name="nexelit-plate", amount=2},
      },
      results = {
        {type="fluid", name="olefin", amount=165},
      },
    },
    ["sea-sponge-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2.99620776028266,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=278},
        {type="item", name="outlet-gas-02-barrel", amount=2},
        {type="item", name="plasmids", amount=1},
        {type="item", name="tree-mk01", amount=1},
      },
      results = {
        {type="fluid", name="water-saline", amount=296},
        {type="item", name="sea-sponge", amount=3},
      },
    },
    ["sulfuric-acid"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.74,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=3360},
        {type="item", name="sulfur", amount=2},
      },
      results = {
        {type="fluid", name="sulfuric-acid", amount=37},
      },
    },
    ["wastewater-filtration"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.71,
      ingredients = {
        {type="fluid", name="waste-water", amount=184},
        {type="item", name="flask", amount=1},
      },
      results = {
        {type="fluid", name="methanol", amount=171},
      },
    },
    ["agitator-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="duralumin", amount=4},
        {type="item", name="electric-mining-drill", amount=2},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="inductor1", amount=46},
        {type="item", name="iron-plate", amount=146},
        {type="item", name="pipe", amount=21},
        {type="item", name="storage-tank", amount=1},
        {type="item", name="tin-plate", amount=35},
        {type="item", name="tinned-cable", amount=181},
      },
      results = {
        {type="item", name="agitator-mk01", amount=1},
      },
    },
    ["centrifugal-pan-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="agitator-mk01", amount=1},
        {type="item", name="assembling-machine-1", amount=2},
        {type="item", name="boiler", amount=14},
        {type="item", name="condensed-distillate-barrel", amount=2},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="fiberboard", amount=75},
        {type="item", name="gun-turret", amount=2},
        {type="item", name="lead-plate", amount=12},
        {type="item", name="outpost", amount=1},
        {type="item", name="steam-engine", amount=19},
        {type="item", name="syngas-canister", amount=7},
      },
      results = {
        {type="item", name="centrifugal-pan-mk01", amount=1},
      },
    },
    ["compressor-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="burner-inserter", amount=10},
        {type="item", name="concrete", amount=35},
        {type="item", name="gasifier", amount=1},
        {type="item", name="glass", amount=21},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="low-grade-rejects", amount=33},
        {type="item", name="steel-chest", amount=5},
        {type="item", name="washer", amount=3},
      },
      results = {
        {type="item", name="compressor-mk01", amount=1},
      },
    },
    ["gas-separator-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="barrel", amount=39},
        {type="item", name="borax-mine", amount=4},
        {type="item", name="carbolic-oil-barrel", amount=13},
        {type="item", name="constant-combinator", amount=2},
        {type="item", name="controler-mk01", amount=4},
        {type="item", name="distilator", amount=4},
        {type="item", name="engine-unit", amount=10},
        {type="item", name="evaporator", amount=3},
        {type="item", name="inductor1", amount=20},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="storage-tank", amount=4},
      },
      results = {
        {type="item", name="gas-separator-mk01", amount=2},
      },
    },
    ["hydrocyclone-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="duralumin", amount=23},
        {type="item", name="engine-unit", amount=7},
        {type="item", name="iron-stick", amount=15},
        {type="item", name="lead-plate", amount=33},
        {type="item", name="nexelit-plate", amount=9},
        {type="item", name="pipe", amount=7},
        {type="item", name="resistor1", amount=42},
        {type="item", name="stone-furnace", amount=19},
        {type="item", name="sulfuric-acid-barrel", amount=8},
        {type="item", name="yaedols-spores", amount=2},
      },
      results = {
        {type="item", name="hydrocyclone-mk01", amount=1},
      },
    },
    ["thickener-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aromatics-canister", amount=16},
        {type="item", name="boiler", amount=3},
        {type="item", name="bolts", amount=39},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="glass", amount=19},
        {type="item", name="stone-brick", amount=300},
        {type="item", name="tower-mk01", amount=1},
      },
      results = {
        {type="item", name="thickener-mk01", amount=1},
      },
    },
    ["casein"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="gasoline", amount=12},
        {type="fluid", name="molten-glass", amount=189},
      },
      results = {
        {type="item", name="casein", amount=4},
      },
    },
    ["green-sic"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="ceramic", amount=4},
        {type="item", name="coal-dust", amount=28},
        {type="item", name="lime", amount=4},
      },
      results = {
        {type="item", name="green-sic", amount=2},
      },
    },
    ["mixed-ores"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.01385753221916,
      ingredients = {
        {type="item", name="grade-1-copper", amount=1},
        {type="item", name="ore-tin", amount=12},
        {type="item", name="refined-hazard-concrete", amount=1},
      },
      results = {
        {type="item", name="mixed-ores", amount=5},
        {type="item", name="stone", amount=1},
      },
    },
    ["cobalt-fluoride"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.666666666666667,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=1054},
        {type="item", name="ash", amount=30},
        {type="item", name="condensates-canister", amount=6},
      },
      results = {
        {type="item", name="cobalt-fluoride", amount=2},
      },
    },
    ["quartz-tube"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="item", name="calcium-carbide", amount=18},
        {type="item", name="ceramic", amount=3},
        {type="item", name="coal-dust", amount=146},
        {type="item", name="fiberboard", amount=5},
        {type="item", name="lime", amount=3},
      },
      results = {
        {type="item", name="quartz-tube", amount=4},
      },
    },
    ["sic"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="cobalt-extract", amount=1},
        {type="item", name="ore-zinc", amount=45},
      },
      results = {
        {type="item", name="sic", amount=6},
      },
    },
    ["artificial-blood"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.79,
      ingredients = {
        {type="fluid", name="raw-gas", amount=1014},
        {type="item", name="dried-meat", amount=51},
        {type="item", name="mukmoux-fat", amount=2},
      },
      results = {
        {type="fluid", name="artificial-blood", amount=79},
      },
    },
    ["decalin"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.44,
      ingredients = {
        {type="fluid", name="aromatics", amount=77},
        {type="fluid", name="carbon-dioxide", amount=1261},
        {type="fluid", name="steam", amount=291},
        {type="fluid", name="water", amount=982},
        {type="item", name="aluminium-plate", amount=4},
        {type="item", name="bolts", amount=9},
        {type="item", name="titanium-plate", amount=2},
      },
      results = {
        {type="fluid", name="decalin", amount=72},
      },
    },
    ["flutec-pp6"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.52,
      ingredients = {
        {type="fluid", name="decalin", amount=77},
        {type="fluid", name="geothermal-water", amount=1804},
        {type="item", name="ash", amount=132},
        {type="item", name="condensates-canister", amount=10},
        {type="item", name="drill-head", amount=28},
        {type="item", name="empty-planter-box", amount=2},
      },
      results = {
        {type="fluid", name="flutec-pp6", amount=152},
      },
    },
    ["bio-oil"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.03333333333333,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=610},
        {type="fluid", name="hot-air", amount=119},
        {type="fluid", name="hot-residual-mixture", amount=66},
        {type="fluid", name="nitrogen", amount=134},
        {type="item", name="dried-meat", amount=2},
        {type="item", name="mixed-ores", amount=6},
        {type="item", name="quartz-tube", amount=1},
      },
      results = {
        {type="fluid", name="bio-oil", amount=310},
        {type="item", name="quartz-tube", amount=1},
      },
    },
    ["bio-oil-3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.933333333333333,
      ingredients = {
        {type="fluid", name="bio-oil", amount=97},
      },
      results = {
        {type="item", name="raw-coal", amount=14},
      },
    },
    ["moondrop-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.625,
      ingredients = {
        {type="fluid", name="hydrogen", amount=81},
        {type="item", name="lime", amount=3},
        {type="item", name="moondrop-seeds", amount=3},
      },
      results = {
        {type="item", name="moondrop", amount=5},
      },
    },
    ["moondrop-mk02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.5268821369012,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=266},
        {type="item", name="coarse", amount=63},
        {type="item", name="cottongut-pup", amount=1},
        {type="item", name="moondrop", amount=2},
        {type="item", name="soot", amount=10},
        {type="item", name="urea", amount=7},
      },
      results = {
        {type="item", name="moondrop", amount=1},
        {type="item", name="moondrop-mk02", amount=0.00763441068450602},
      },
    },
    ["moondrop-seeds-mk02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.687853057685782,
      ingredients = {
        {type="item", name="moondrop-mk02", amount=3},
      },
      results = {
        {type="item", name="moondrop", amount=1},
        {type="item", name="moondrop-mk02", amount=2},
        {type="item", name="moondrop-seeds", amount=1},
        {type="item", name="moondrop-seeds-mk02", amount=2},
      },
    },
    ["moondrop-mk02-breeder"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="coal-gas", amount=318},
        {type="fluid", name="nitrogen", amount=216},
        {type="fluid", name="water-saline", amount=169},
        {type="item", name="coal-dust", amount=3},
        {type="item", name="refined-natural-gas-canister", amount=8},
        {type="item", name="yaedols", amount=1},
      },
      results = {
        {type="item", name="moondrop-mk02", amount=4},
      },
    },
    ["oleochemicals-bioplastic"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.3,
      ingredients = {
        {type="fluid", name="coalbed-gas", amount=514},
        {type="fluid", name="methanol", amount=106},
        {type="fluid", name="pressured-water", amount=604},
        {type="fluid", name="purest-nitrogen-gas", amount=2641},
        {type="item", name="carbon-black", amount=1},
        {type="item", name="mukmoux-fat", amount=1},
      },
      results = {
        {type="item", name="plastic-bar", amount=13},
      },
    },
    ["plastic-from-casein"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.55,
      ingredients = {
        {type="fluid", name="hot-air", amount=97},
        {type="fluid", name="methanal", amount=54},
        {type="item", name="cobalt-extract", amount=1},
      },
      results = {
        {type="item", name="plastic-bar", amount=11},
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
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="al-pulp-01", amount=1988},
        {type="item", name="aluminium-plate", amount=130},
        {type="item", name="cdna", amount=12},
        {type="item", name="copper-low-dust", amount=9},
        {type="item", name="cottongut-mk01", amount=3},
        {type="item", name="earth-cow-sample", amount=1},
        {type="item", name="nichrome", amount=11},
        {type="item", name="powdered-ralesia-seeds", amount=21},
      },
      results = {
        {type="item", name="zipir1", amount=2},
      },
    },
    ["alien-sample-02"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="lubricant", amount=300},
        {type="fluid", name="water-saline", amount=10060},
        {type="item", name="aluminium-plate", amount=50},
        {type="item", name="copper-rejects", amount=50},
        {type="item", name="dried-meat", amount=102},
        {type="item", name="empty-petri-dish", amount=2},
        {type="item", name="refined-natural-gas-barrel", amount=19},
        {type="item", name="sodium-hydroxide", amount=12},
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
        {type="item", name="acetic-acid-barrel", amount=6},
        {type="item", name="dried-meat", amount=9},
        {type="item", name="empty-petri-dish", amount=5},
        {type="item", name="plastic-bar", amount=19},
        {type="item", name="retrovirus", amount=17},
      },
      results = {
        {type="item", name="cytostatics", amount=1},
      },
    },
    ["dna-polymerase"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="arqad-honey", amount=125},
        {type="item", name="cocoon-mk02", amount=5},
        {type="item", name="steel-chest", amount=6},
        {type="item", name="stopper", amount=18},
      },
      results = {
        {type="item", name="dna-polymerase", amount=2},
      },
    },
    ["manure-bacteria"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.73,
      ingredients = {
        {type="item", name="dried-meat", amount=5},
        {type="item", name="fawogae-substrate", amount=3},
        {type="item", name="petri-dish-bacteria", amount=2},
      },
      results = {
        {type="fluid", name="manure-bacteria", amount=173},
      },
    },
    ["primers"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.42857142857143,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=445},
        {type="item", name="coal-gas-barrel", amount=3},
        {type="item", name="empty-petri-dish", amount=41},
        {type="item", name="raw-fiber", amount=7},
        {type="item", name="stopper", amount=11},
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
        {type="fluid", name="liquid-nitrogen", amount=18},
        {type="item", name="cocoon", amount=4},
        {type="item", name="cocoon-mk02", amount=1},
        {type="item", name="empty-petri-dish", amount=13},
        {type="item", name="petri-dish-bacteria", amount=1},
        {type="item", name="stopper", amount=13},
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
        {type="fluid", name="hot-syngas", amount=1184},
        {type="item", name="acetic-acid-barrel", amount=6},
        {type="item", name="cottongut-mk01", amount=22},
        {type="item", name="primers", amount=1},
        {type="item", name="retrovirus", amount=42},
      },
      results = {
        {type="item", name="paragen", amount=5},
        {type="item", name="solidified-sarcorus", amount=8},
      },
    },
    ["gasoline-cellulose"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.53,
      ingredients = {
        {type="fluid", name="nitrogen", amount=425},
        {type="fluid", name="phytoplankton", amount=6},
        {type="fluid", name="pressured-air", amount=282},
      },
      results = {
        {type="fluid", name="gasoline", amount=53},
      },
    },
    ["tuuphra-sample"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2.5,
      ingredients = {
        {type="item", name="aluminium-plate", amount=114},
        {type="item", name="bio-sample01", amount=23},
        {type="item", name="cdna", amount=7},
        {type="item", name="cottongut-codex", amount=1},
        {type="item", name="earth-bear-sample", amount=2},
        {type="item", name="earth-cow-sample", amount=8},
        {type="item", name="moondrop-codex", amount=4},
      },
      results = {
        {type="item", name="tuuphra", amount=5},
      },
    },
    ["tuuphra-seeds"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2.25,
      ingredients = {
        {type="item", name="empty-comb", amount=7},
        {type="item", name="yaedols", amount=2},
      },
      results = {
        {type="item", name="tuuphra-seeds", amount=18},
      },
    },
    ["tuuphra-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="nitrogen", amount=460},
        {type="item", name="calcinates", amount=3},
        {type="item", name="lime", amount=5},
        {type="item", name="soil", amount=38},
      },
      results = {
        {type="item", name="tuuphra", amount=4},
      },
    },
    ["sweet-syrup"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.52,
      ingredients = {
        {type="fluid", name="lubricant", amount=357},
        {type="fluid", name="water-saline", amount=195},
        {type="item", name="calcium-carbide", amount=10},
      },
      results = {
        {type="fluid", name="sweet-syrup", amount=26},
      },
    },
    ["a-molasse"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.769957464589459,
      ingredients = {
        {type="item", name="acetylene-canister", amount=11},
      },
      results = {
        {type="fluid", name="a-molasse", amount=77},
        {type="item", name="biomass", amount=6},
      },
    },
    ["korlex-codex"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=21},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="empty-barrel-milk", amount=4},
        {type="item", name="lime", amount=2},
        {type="item", name="seaweed", amount=11},
        {type="item", name="stone-brick", amount=6},
      },
      results = {
        {type="item", name="korlex-codex", amount=1},
      },
    },
    ["korlex-food-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="fluid", name="fish-oil", amount=106},
        {type="item", name="fawogae-substrate", amount=5},
        {type="item", name="filtration-media", amount=1},
        {type="item", name="kicalk", amount=6},
        {type="item", name="meat", amount=5},
        {type="item", name="niobium-complex-barrel", amount=3},
        {type="item", name="refined-natural-gas-barrel", amount=2},
        {type="item", name="sodium-hydroxide", amount=4},
        {type="item", name="tin-plate", amount=2},
        {type="item", name="yaedols", amount=1},
      },
      results = {
        {type="item", name="korlex-food-01", amount=5},
      },
    },
    ["korlex"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="bitumen-froth", amount=967},
        {type="item", name="aluminium-plate", amount=52},
        {type="item", name="auog-food-01", amount=16},
        {type="item", name="bio-sample01", amount=5},
        {type="item", name="cdna", amount=2},
        {type="item", name="coal-dust", amount=300},
        {type="item", name="lab-instrument", amount=39},
        {type="item", name="moss-gen", amount=12},
        {type="item", name="powdered-ralesia-seeds", amount=189},
        {type="item", name="retrovirus", amount=7},
        {type="item", name="sea-sponge-codex", amount=1},
      },
      results = {
        {type="item", name="korlex", amount=1},
      },
    },
    ["korlex-milk-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.35187806670532,
      ingredients = {
        {type="item", name="acetylene-canister", amount=13},
        {type="item", name="empty-barrel-milk", amount=2},
        {type="item", name="fish", amount=5},
        {type="item", name="py-asphalt", amount=17},
        {type="item", name="syngas-barrel", amount=4},
        {type="item", name="tall-oil-barrel", amount=3},
      },
      results = {
        {type="item", name="barrel", amount=14},
        {type="item", name="barrel-milk", amount=4},
      },
    },
    ["korlex-pup-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.35767119136548,
      ingredients = {
        {type="item", name="anthracene-oil-canister", amount=1},
        {type="item", name="bonemeal", amount=56},
        {type="item", name="gasoline-barrel", amount=21},
        {type="item", name="iron-stick", amount=21},
        {type="item", name="naphthalene-oil-barrel", amount=4},
        {type="item", name="water-barrel", amount=19},
      },
      results = {
        {type="item", name="barrel", amount=36},
        {type="item", name="korlex-pup", amount=4},
      },
    },
    ["korlex-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.51145828012117,
      ingredients = {
        {type="fluid", name="fish-hydrolysate", amount=278},
        {type="item", name="molten-iron-barrel", amount=1},
        {type="item", name="py-aluminium", amount=4},
        {type="item", name="salt", amount=73},
        {type="item", name="wood-fence", amount=9},
      },
      results = {
        {type="item", name="barrel", amount=13},
        {type="item", name="korlex", amount=3},
      },
    },
    ["outlet-gas-02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.38507759707482,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=1100},
        {type="fluid", name="pressured-air", amount=259},
        {type="fluid", name="pressured-water", amount=2435},
        {type="item", name="ralesia-seeds", amount=35},
      },
      results = {
        {type="fluid", name="outlet-gas-02", amount=138},
        {type="item", name="sulfur", amount=28},
      },
    },
    ["quench-redcoke"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.440121439461438,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=119},
        {type="fluid", name="pressured-air", amount=63},
        {type="item", name="ralesia-seeds", amount=9},
      },
      results = {
        {type="fluid", name="steam", amount=44},
        {type="item", name="coal-dust", amount=2},
        {type="item", name="coke", amount=13},
      },
    },
    ["redhot-coke"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.59146487684058,
      ingredients = {
        {type="item", name="coal", amount=34},
        {type="item", name="raw-coal", amount=3},
      },
      results = {
        {type="fluid", name="coke-oven-gas", amount=79},
        {type="item", name="redhot-coke", amount=8},
      },
    },
    ["outlet-gas-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.79,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=32},
        {type="fluid", name="syngas", amount=270},
        {type="fluid", name="tar", amount=47},
        {type="item", name="chromium", amount=1},
        {type="item", name="coal", amount=2},
        {type="item", name="stone", amount=4},
      },
      results = {
        {type="fluid", name="outlet-gas-01", amount=79},
      },
    },
    ["molybdenum-filtration"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="fluid", name="acidgas", amount=1192},
        {type="item", name="gasoline-barrel", amount=1},
        {type="item", name="grade-1-copper", amount=18},
      },
      results = {
        {type="item", name="molybdenum-sulfide", amount=16},
      },
    },
    ["calcinate-bone"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="item", name="meat", amount=7},
        {type="item", name="mukmoux-fat", amount=4},
      },
      results = {
        {type="item", name="calcinates", amount=5},
      },
    },
    ["molybdenum-concentrate"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.19781063286463,
      ingredients = {
        {type="fluid", name="hot-air", amount=2329},
        {type="fluid", name="pressured-air", amount=2053},
        {type="item", name="low-distillate-canister", amount=1},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=174},
        {type="item", name="molybdenum-concentrate", amount=12},
      },
    },
    ["molybdenum-oxide"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.40289100188916,
      ingredients = {
        {type="fluid", name="steam", amount=397},
        {type="item", name="crushed-molybdenite", amount=36},
      },
      results = {
        {type="item", name="molybdenum-oxide", amount=4},
        {type="item", name="sulfur", amount=1},
      },
    },
    ["calcinate-separation"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 6.95317016551079,
      ingredients = {
        {type="item", name="lime", amount=580},
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
      energy_required_multiplier = 0.666679710217351,
      ingredients = {
        {type="fluid", name="pressured-water", amount=280},
        {type="item", name="creamy-latex-barrel", amount=3},
        {type="item", name="gasoline-barrel", amount=5},
        {type="item", name="limestone", amount=2},
        {type="item", name="ralesia-seeds", amount=3},
      },
      results = {
        {type="fluid", name="water", amount=7},
        {type="item", name="molybdenum-plate", amount=2},
      },
    },
    ["seaweed-mk02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="creamy-latex-barrel", amount=6},
        {type="item", name="grade-1-copper", amount=1},
        {type="item", name="limestone", amount=5},
        {type="item", name="ralesia-seeds", amount=2},
      },
      results = {
        {type="item", name="seaweed-mk02", amount=1},
      },
    },
    ["fertilizer-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="methanal", amount=235},
        {type="item", name="ash", amount=8},
        {type="item", name="mukmoux-fat", amount=5},
        {type="item", name="urea", amount=5},
      },
      results = {
        {type="item", name="fertilizer", amount=8},
      },
    },
    ["fertilizer-3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.7,
      ingredients = {
        {type="item", name="ash", amount=6},
        {type="item", name="biomass", amount=15},
        {type="item", name="moss", amount=7},
        {type="item", name="urea", amount=2},
      },
      results = {
        {type="item", name="fertilizer", amount=7},
      },
    },
    ["fertilizer-fish-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.666666666666667,
      ingredients = {
        {type="fluid", name="fish-hydrolysate", amount=85},
        {type="item", name="acetylene-canister", amount=1},
      },
      results = {
        {type="item", name="fertilizer", amount=2},
      },
    },
    ["formic-acid"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.61,
      ingredients = {
        {type="fluid", name="formamide", amount=77},
        {type="fluid", name="sulfuric-acid", amount=21},
      },
      results = {
        {type="fluid", name="formic-acid", amount=61},
      },
    },
    ["sap-seeds-mk02-gen"] = {
      mode = "repaired-to-input",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=681},
        {type="item", name="bonemeal", amount=89},
        {type="item", name="moondrop", amount=1},
        {type="item", name="seaweed", amount=14},
        {type="item", name="sodium-hydroxide", amount=4},
      },
      results = {
        {type="item", name="sap-seeds-mk02", amount=1},
      },
    },
    ["sap-seeds-mk02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="sodium-alginate", amount=1},
      },
      results = {
        {type="item", name="sap-seeds-mk02", amount=1},
      },
    },
    ["sap-tree-mk02-gen"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bones", amount=11},
        {type="item", name="fish-oil-barrel", amount=1},
        {type="item", name="guts", amount=1},
        {type="item", name="ralesia", amount=5},
        {type="item", name="skin", amount=2},
      },
      results = {
        {type="item", name="sap-tree-mk02", amount=1},
      },
    },
    ["casein-pulp-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.42,
      ingredients = {
        {type="fluid", name="pressured-water", amount=2595},
        {type="fluid", name="steam", amount=70},
      },
      results = {
        {type="fluid", name="casein-pulp-01", amount=42},
        {type="fluid", name="muddy-sludge", amount=21},
      },
    },
    ["fish-hydrolysate"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.12,
      ingredients = {
        {type="fluid", name="hot-air", amount=1803},
        {type="fluid", name="pressured-water", amount=358},
        {type="item", name="fish", amount=5},
        {type="item", name="starch", amount=1},
        {type="item", name="urea", amount=3},
      },
      results = {
        {type="fluid", name="fish-hydrolysate", amount=56},
      },
    },
    ["casein-mixture-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.34,
      ingredients = {
        {type="fluid", name="acetic-acid", amount=38},
        {type="fluid", name="casein-pulp-01", amount=4},
        {type="fluid", name="milk", amount=9},
      },
      results = {
        {type="fluid", name="casein-mixture", amount=17},
        {type="fluid", name="waste-water", amount=17},
      },
    },
    ["casein-pulp-02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.66,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=597},
        {type="fluid", name="casein-pulp-01", amount=38},
        {type="fluid", name="pressured-water", amount=3576},
      },
      results = {
        {type="fluid", name="casein-pulp-02", amount=83},
      },
    },
    ["casein-mixture-02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.46500834369633,
      ingredients = {
        {type="fluid", name="acetic-acid", amount=35},
        {type="fluid", name="hydrogen", amount=402},
        {type="fluid", name="milk", amount=73},
        {type="fluid", name="pressured-water", amount=454},
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
        {type="item", name="btx-barrel", amount=4},
        {type="item", name="raw-fiber", amount=12},
      },
      results = {
        {type="item", name="wax-barrel", amount=3},
      },
    },
    ["sugar-wax"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bonemeal", amount=5},
        {type="item", name="dried-meat", amount=3},
        {type="item", name="empty-barrel-milk", amount=1},
      },
      results = {
        {type="item", name="wax-barrel", amount=1},
      },
    },
    ["phosphate-mine"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=241},
        {type="item", name="carbon-filter", amount=1},
        {type="item", name="concrete", amount=564},
        {type="item", name="distilator", amount=3},
        {type="item", name="duralumin", amount=62},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="grade-1-zinc", amount=9},
        {type="item", name="landfill", amount=2},
        {type="item", name="latex", amount=13},
        {type="item", name="lead-plate", amount=89},
        {type="item", name="nexelit-plate", amount=116},
        {type="item", name="pipe", amount=46},
        {type="item", name="small-lamp", amount=5},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="ticl4", amount=17},
        {type="item", name="zogna-bacteria-barrel", amount=19},
      },
      results = {
        {type="item", name="phosphate-mine", amount=2},
      },
    },
    ["rare-earth-mine"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coal-slurry-barrel", amount=45},
        {type="item", name="grade-1-zinc", amount=120},
        {type="item", name="petroleum-gas-barrel", amount=14},
        {type="item", name="rare-earth-mud-barrel", amount=18},
        {type="item", name="storage-chest", amount=2},
        {type="item", name="subcritical-water-barrel", amount=154},
        {type="item", name="ticl4", amount=92},
      },
      results = {
        {type="item", name="rare-earth-mine", amount=1},
      },
    },
    ["subcritical-water-03"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.405,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=166},
        {type="fluid", name="hot-air", amount=127},
        {type="item", name="iron-ore", amount=9},
      },
      results = {
        {type="fluid", name="subcritical-water", amount=281},
      },
    },
    ["wax"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="ore-chromium", amount=4},
        {type="item", name="sb-grade-04", amount=23},
      },
      results = {
        {type="fluid", name="wax", amount=40},
      },
    },
    ["wax-honeycomb"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.88,
      ingredients = {
        {type="item", name="ore-tin", amount=7},
        {type="item", name="rich-clay", amount=17},
      },
      results = {
        {type="fluid", name="wax", amount=44},
      },
    },
    ["empty-comb-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="fluid", name="gasoline", amount=231},
      },
      results = {
        {type="item", name="empty-comb", amount=6},
      },
    },
    ["empty-honeycomb-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.625,
      ingredients = {
        {type="fluid", name="molten-glass", amount=173},
        {type="fluid", name="pressured-water", amount=659},
        {type="fluid", name="purest-nitrogen-gas", amount=1458},
      },
      results = {
        {type="item", name="empty-honeycomb", amount=13},
      },
    },
    ["big-electric-pole"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="dried-meat", amount=3},
        {type="item", name="sodium-hydroxide", amount=37},
        {type="item", name="steel-plate", amount=3},
      },
      results = {
        {type="item", name="big-electric-pole", amount=1},
      },
    },
    ["breed-fish-2"] = {
      mode = "repaired-to-input",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=120},
        {type="fluid", name="water-saline", amount=100},
        {type="item", name="biomass", amount=10},
        {type="item", name="fertilizer", amount=15},
        {type="item", name="fish-food-01", amount=1},
        {type="item", name="heavy-oil-canister", amount=1},
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
      energy_required_multiplier = 1.4327117009654,
      ingredients = {
        {type="fluid", name="hot-air", amount=2316},
        {type="fluid", name="water", amount=1112},
        {type="item", name="fish", amount=9},
        {type="item", name="fish-food-01", amount=2},
        {type="item", name="sand", amount=11},
        {type="item", name="small-parts-01", amount=9},
        {type="item", name="vacuum-tube", amount=1},
      },
      results = {
        {type="fluid", name="waste-water", amount=143},
        {type="item", name="fish-egg", amount=43},
      },
    },
    ["fish-mk02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.385207170429319,
      ingredients = {
        {type="item", name="fish", amount=15},
        {type="item", name="naphthalene-oil-barrel", amount=2},
        {type="item", name="sand", amount=22},
      },
      results = {
        {type="item", name="fish", amount=5},
        {type="item", name="fish-mk02", amount=0.00192603585214659},
      },
    },
    ["fish-egg-mk02-breeder"] = {
      mode = "repaired-to-input",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=1393},
        {type="fluid", name="water-saline", amount=100},
        {type="item", name="green-sic", amount=12},
      },
      results = {
        {type="fluid", name="waste-water", amount=100},
        {type="item", name="fish-egg", amount=1},
        {type="item", name="fish-egg-mk02", amount=11},
      },
    },
    ["fish-mk02-breeder"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.716420751780974,
      ingredients = {
        {type="fluid", name="pressured-air", amount=409},
        {type="item", name="fish-egg", amount=38},
        {type="item", name="lime", amount=2},
        {type="item", name="meat", amount=1},
        {type="item", name="methanol-canister", amount=1},
        {type="item", name="tinned-cable", amount=17},
      },
      results = {
        {type="fluid", name="waste-water", amount=69},
        {type="item", name="fish", amount=1},
        {type="item", name="fish-mk02", amount=5},
      },
    },
    ["cliff-explosives"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="empty-gas-canister", amount=1},
        {type="item", name="gasoline-barrel", amount=13},
        {type="item", name="iron-stick", amount=41},
        {type="item", name="shotgun-shell", amount=1},
        {type="item", name="stopper", amount=1},
      },
      results = {
        {type="item", name="cliff-explosives", amount=1},
      },
    },
    ["fast-inserter"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="burner-inserter", amount=7},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="fenxsb-alloy", amount=3},
        {type="item", name="lead-plate", amount=8},
        {type="item", name="manure", amount=30},
        {type="item", name="phytoplankton-barrel", amount=1},
        {type="item", name="residual-oil-barrel", amount=1},
      },
      results = {
        {type="item", name="fast-inserter", amount=2},
      },
    },
    ["py-stack-inserter"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=192},
        {type="item", name="engine-unit", amount=5},
        {type="item", name="niobium-plate", amount=12},
        {type="item", name="outlet-gas-01-canister", amount=47},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="tinned-cable", amount=157},
      },
      results = {
        {type="item", name="py-stack-inserter", amount=2},
      },
    },
    ["flavonoids"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.433333333333333,
      ingredients = {
        {type="item", name="moss", amount=6},
        {type="item", name="ralesia", amount=18},
      },
      results = {
        {type="fluid", name="flavonoids", amount=13},
      },
    },
    ["mo-mine"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bio-sample", amount=21},
        {type="item", name="distilator", amount=2},
        {type="item", name="duralumin", amount=28},
        {type="item", name="electronic-circuit", amount=7},
        {type="item", name="hpf", amount=1},
        {type="item", name="jaw-crusher", amount=2},
        {type="item", name="lead-plate", amount=400},
        {type="item", name="moondrop-seeds-mk02", amount=43},
        {type="item", name="nbfe-alloy", amount=46},
        {type="item", name="processed-iron-ore", amount=100},
        {type="item", name="py-tank-3000", amount=2},
        {type="item", name="small-parts-01", amount=20},
        {type="item", name="steam-engine", amount=38},
      },
      results = {
        {type="item", name="mo-mine", amount=2},
      },
    },
    ["niobium-pipe"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="coal-dust", amount=16},
        {type="item", name="oil-sand-slurry-barrel", amount=1},
      },
      results = {
        {type="item", name="niobium-pipe", amount=4},
      },
    },
    ["niobium-pipe-to-ground"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2.5,
      ingredients = {
        {type="item", name="niobium-complex-barrel", amount=4},
        {type="item", name="refined-natural-gas-barrel", amount=1},
      },
      results = {
        {type="item", name="niobium-pipe-to-ground", amount=5},
      },
    },
    ["py-logistic-robot-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aromatics-barrel", amount=1},
        {type="item", name="boiler", amount=12},
        {type="item", name="burner-inserter", amount=4},
        {type="item", name="carbon-black", amount=10},
        {type="item", name="electronic-circuit", amount=6},
        {type="item", name="fwf-mk01", amount=1},
        {type="item", name="inductor1", amount=5},
        {type="item", name="lead-plate", amount=10},
        {type="item", name="molten-lead-barrel", amount=4},
        {type="item", name="nexelit-plate", amount=328},
        {type="item", name="resistor1", amount=231},
        {type="item", name="steel-plate", amount=39},
        {type="item", name="stone-brick", amount=31},
        {type="item", name="vrauks-food-01", amount=4},
        {type="item", name="zinc-chloride", amount=3},
      },
      results = {
        {type="item", name="py-logistic-robot-mk01", amount=2},
      },
    },
    ["yaedols-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="water", amount=694},
        {type="item", name="fertilizer", amount=5},
        {type="item", name="moondrop-seeds", amount=12},
        {type="item", name="raw-fiber", amount=5},
        {type="item", name="redhot-coke", amount=1},
        {type="item", name="wood", amount=4},
      },
      results = {
        {type="item", name="yaedols", amount=4},
      },
    },
    ["yaedols-sample"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="alien-sample01", amount=6},
        {type="item", name="cdna", amount=9},
        {type="item", name="earth-mouse-sample", amount=1},
        {type="item", name="plasmids", amount=5},
        {type="item", name="sea-sponge-codex", amount=3},
      },
      results = {
        {type="item", name="yaedols", amount=2},
      },
    },
    ["anthracene-gasoline-hydrogenation"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.84,
      ingredients = {
        {type="fluid", name="hot-air", amount=445},
      },
      results = {
        {type="fluid", name="gasoline", amount=21},
      },
    },
    ["anthraquinone-from-naphthalene"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.86,
      ingredients = {
        {type="item", name="empty-planter-box", amount=1},
        {type="item", name="redhot-coke", amount=32},
      },
      results = {
        {type="fluid", name="anthraquinone", amount=86},
      },
    },
    ["aromatics-from-naphthalene"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.605535646278202,
      ingredients = {
        {type="fluid", name="hot-air", amount=841},
      },
      results = {
        {type="fluid", name="aromatics", amount=23},
        {type="item", name="coke", amount=2},
      },
    },
    ["bitumen-to-heavy-oil"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.11,
      ingredients = {
        {type="fluid", name="bitumen", amount=90},
        {type="fluid", name="geothermal-water", amount=319},
        {type="fluid", name="pressured-air", amount=118},
        {type="fluid", name="water", amount=468},
      },
      results = {
        {type="fluid", name="heavy-oil", amount=111},
      },
    },
    ["hot-residual-mixture-to-coke"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.921688547230729,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=426},
        {type="fluid", name="hot-residual-mixture", amount=145},
      },
      results = {
        {type="fluid", name="coke-oven-gas", amount=55},
        {type="item", name="coke", amount=37},
      },
    },
    ["naphthalene-solvent"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.833333333333333,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=462},
        {type="fluid", name="hot-air", amount=2288},
      },
      results = {
        {type="fluid", name="organic-solvent", amount=25},
      },
    },
    ["natural-gas-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.75,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=1850},
        {type="fluid", name="tailings", amount=177},
        {type="item", name="pipe", amount=2},
      },
      results = {
        {type="fluid", name="raw-gas", amount=70},
      },
    },
    ["oil-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.7,
      ingredients = {
        {type="fluid", name="molten-steel", amount=2},
        {type="fluid", name="pressured-air", amount=1800},
        {type="item", name="pipe", amount=1},
      },
      results = {
        {type="fluid", name="crude-oil", amount=28},
      },
    },
    ["rubber-02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="item", name="ammonia-barrel", amount=1},
        {type="item", name="belt", amount=3},
        {type="item", name="bonemeal", amount=2},
        {type="item", name="empty-comb", amount=9},
        {type="item", name="latex", amount=1},
        {type="item", name="methanal-barrel", amount=2},
        {type="item", name="py-iron-oxide", amount=7},
      },
      results = {
        {type="item", name="rubber", amount=5},
      },
    },
    ["rubber-from-oleochemicals"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="fluid", name="coalbed-gas", amount=1065},
        {type="item", name="carbon-black", amount=9},
        {type="item", name="latex", amount=1},
        {type="item", name="mukmoux-fat", amount=1},
      },
      results = {
        {type="item", name="rubber", amount=3},
      },
    },
    ["tar-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.37,
      ingredients = {
        {type="fluid", name="drilling-fluid-0", amount=21},
        {type="fluid", name="pressured-air", amount=2043},
        {type="item", name="pipe", amount=5},
      },
      results = {
        {type="fluid", name="tar", amount=137},
      },
    },
    ["ticl4"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.75,
      ingredients = {
        {type="fluid", name="flue-gas", amount=874},
        {type="item", name="carbon-dioxide-barrel", amount=2},
        {type="item", name="purest-nitrogen-gas-barrel", amount=1},
        {type="item", name="rich-clay", amount=4},
        {type="item", name="titanium-plate", amount=3},
      },
      results = {
        {type="item", name="ticl4", amount=7},
      },
    },
    ["methane-to-methanol5"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.513333333333333,
      ingredients = {
        {type="fluid", name="methane", amount=18},
        {type="item", name="sncr-alloy", amount=1},
      },
      results = {
        {type="fluid", name="methanol", amount=77},
      },
    },
    ["methane-to-methanol6"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.29333333333333,
      ingredients = {
        {type="fluid", name="hot-air", amount=362},
        {type="fluid", name="methane", amount=433},
        {type="item", name="grade-1-copper", amount=1},
        {type="item", name="kerogen", amount=7},
        {type="item", name="sncr-alloy", amount=2},
      },
      results = {
        {type="fluid", name="methanol", amount=388},
      },
    },
    ["naphtha-to-syngas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.1625,
      ingredients = {
        {type="fluid", name="hydrogen", amount=159},
        {type="fluid", name="pressured-water", amount=371},
      },
      results = {
        {type="fluid", name="syngas", amount=65},
      },
    },
    ["reheat-coke-gas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.66,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=95},
        {type="fluid", name="hot-molten-salt", amount=38},
        {type="fluid", name="sulfuric-acid", amount=295},
      },
      results = {
        {type="fluid", name="coke-oven-gas", amount=95},
        {type="fluid", name="molten-salt", amount=83},
      },
    },
    ["warmer-stone-brick-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=100},
        {type="item", name="warm-stone-brick", amount=2},
      },
      results = {
        {type="fluid", name="coke-oven-gas", amount=100},
        {type="item", name="warmer-stone-brick", amount=2},
      },
    },
    ["warmer-air-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.70104441649661,
      ingredients = {
        {type="item", name="acidgas-barrel", amount=3},
        {type="item", name="grade-2-copper", amount=1},
        {type="item", name="py-asphalt", amount=12},
      },
      results = {
        {type="fluid", name="hot-air", amount=513},
        {type="item", name="stone-brick", amount=34},
      },
    },
    ["aromatics-2-diesel"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.834285714285714,
      ingredients = {
        {type="fluid", name="flue-gas", amount=795},
        {type="fluid", name="geothermal-water", amount=5355},
        {type="item", name="grade-3-zinc", amount=1},
      },
      results = {
        {type="fluid", name="diesel", amount=292},
      },
    },
    ["aromatics-2-petgas2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.67,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=500},
        {type="fluid", name="steam", amount=926},
        {type="item", name="bolts", amount=4},
      },
      results = {
        {type="fluid", name="petroleum-gas", amount=201},
      },
    },
    ["bio-oil-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.02229722627551,
      ingredients = {
        {type="fluid", name="bio-oil", amount=77},
        {type="fluid", name="heavy-oil", amount=366},
      },
      results = {
        {type="fluid", name="condensates", amount=154},
        {type="fluid", name="low-distillate", amount=51},
        {type="fluid", name="medium-distillate", amount=51},
      },
    },
    ["low-distillate-to-btx"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.87,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=3543},
        {type="item", name="bolts", amount=3},
      },
      results = {
        {type="fluid", name="btx", amount=87},
      },
    },
    ["medium-distillate-to-high-distillate"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.97,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=1907},
        {type="fluid", name="steam", amount=290},
        {type="item", name="ticl4", amount=1},
      },
      results = {
        {type="fluid", name="high-distillate", amount=97},
      },
    },
    ["medium-distillate-to-stripped-distillate"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.72,
      ingredients = {
        {type="fluid", name="flue-gas", amount=1419},
        {type="fluid", name="muddy-sludge", amount=475},
        {type="fluid", name="steam", amount=72},
        {type="item", name="carbon-dioxide-barrel", amount=1},
      },
      results = {
        {type="fluid", name="stripped-distillate", amount=72},
      },
    },
    ["low-distillate-to-coal-gas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.025,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=944},
        {type="fluid", name="tailings", amount=367},
        {type="item", name="bolts", amount=9},
      },
      results = {
        {type="fluid", name="coal-gas", amount=205},
      },
    },
    ["stripped-distillate-to-benzene"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.486666666666667,
      ingredients = {
        {type="fluid", name="stripped-distillate", amount=42},
        {type="item", name="bolts", amount=9},
      },
      results = {
        {type="fluid", name="benzene", amount=73},
      },
    },
    ["stripped-distillate-to-cumene"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.62,
      ingredients = {
        {type="fluid", name="acidgas", amount=285},
        {type="fluid", name="heavy-oil", amount=290},
        {type="item", name="bolts", amount=2},
        {type="item", name="capacitor1", amount=2},
      },
      results = {
        {type="fluid", name="cumene", amount=324},
      },
    },
    ["stripped-distillate-to-gasoline"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.54,
      ingredients = {
        {type="fluid", name="heavy-oil", amount=136},
        {type="fluid", name="pressured-air", amount=526},
        {type="item", name="bolts", amount=9},
      },
      results = {
        {type="fluid", name="gasoline", amount=108},
      },
    },
    ["stripped-distillate-to-methanol"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.98,
      ingredients = {
        {type="fluid", name="pressured-air", amount=5666},
        {type="fluid", name="stripped-distillate", amount=146},
        {type="item", name="grade-2-tin", amount=1},
      },
      results = {
        {type="fluid", name="methanol", amount=297},
      },
    },
    ["fluorine-to-olefins"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.46,
      ingredients = {
        {type="fluid", name="boric-acid", amount=241},
        {type="fluid", name="oleochemicals", amount=145},
        {type="item", name="sodium-hydroxide", amount=1},
      },
      results = {
        {type="fluid", name="naphtha", amount=23},
        {type="fluid", name="olefin", amount=46},
      },
    },
    ["high-distillate-condensing"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.18,
      ingredients = {
        {type="fluid", name="hydrogen", amount=505},
        {type="fluid", name="methanal", amount=645},
        {type="fluid", name="steam", amount=404},
        {type="item", name="gravel", amount=4},
      },
      results = {
        {type="fluid", name="condensed-distillate", amount=59},
        {type="fluid", name="naphtha", amount=177},
      },
    },
    ["natural-gas-refining"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.972590096681605,
      ingredients = {
        {type="fluid", name="gasoline", amount=38},
        {type="fluid", name="residual-mixture", amount=327},
        {type="fluid", name="vacuum", amount=848},
        {type="item", name="coal-dust", amount=5},
        {type="item", name="refined-natural-gas-canister", amount=5},
      },
      results = {
        {type="fluid", name="condensates", amount=97},
        {type="fluid", name="naphtha", amount=49},
        {type="fluid", name="natural-gas", amount=243},
      },
    },
    ["refined-natural-gas-to-condensates"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.7,
      ingredients = {
        {type="fluid", name="pressured-air", amount=2868},
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
      energy_required_multiplier = 1.12830045885616,
      ingredients = {
        {type="fluid", name="hot-air", amount=500},
        {type="fluid", name="pressured-air", amount=1085},
        {type="fluid", name="sulfuric-acid", amount=153},
        {type="fluid", name="water-saline", amount=1159},
      },
      results = {
        {type="fluid", name="gasoline", amount=28},
        {type="fluid", name="petroleum-gas", amount=57},
      },
    },
    ["low-distillate-to-heavy-oil"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.547542869857774,
      ingredients = {
        {type="fluid", name="btx", amount=9},
        {type="fluid", name="carbon-dioxide", amount=358},
        {type="fluid", name="flue-gas", amount=169},
        {type="fluid", name="nitrogen", amount=259},
      },
      results = {
        {type="fluid", name="heavy-oil", amount=110},
        {type="fluid", name="residual-oil", amount=27},
        {type="fluid", name="steam", amount=330},
      },
    },
    ["naphtha-2-tall-oil"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.42,
      ingredients = {
        {type="fluid", name="pressured-water", amount=1788},
      },
      results = {
        {type="fluid", name="tall-oil", amount=42},
      },
    },
    ["bitumen-comb"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 3.02558200973017,
      ingredients = {
        {type="item", name="grade-4-copper", amount=2},
        {type="item", name="ore-chromium", amount=21},
      },
      results = {
        {type="fluid", name="bitumen", amount=154},
        {type="item", name="used-comb", amount=3},
      },
    },
    ["raw-gas"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.25599897546998,
      ingredients = {
        {type="fluid", name="condensates", amount=77},
        {type="fluid", name="pressured-air", amount=102},
        {type="fluid", name="vacuum", amount=734},
        {type="item", name="ore-chromium", amount=1},
      },
      results = {
        {type="fluid", name="btx", amount=38},
        {type="fluid", name="refined-natural-gas", amount=125},
        {type="fluid", name="tailings", amount=63},
      },
    },
    ["residual-mixture"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.64,
      ingredients = {
        {type="fluid", name="methanal", amount=618},
        {type="fluid", name="molten-glass", amount=136},
        {type="item", name="coal-dust", amount=11},
      },
      results = {
        {type="fluid", name="residual-mixture", amount=164},
      },
    },
    ["bio-oil-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.419633634268296,
      ingredients = {
        {type="fluid", name="water-saline", amount=359},
      },
      results = {
        {type="fluid", name="condensates", amount=68},
        {type="item", name="ash", amount=1},
        {type="item", name="raw-coal", amount=8},
      },
    },
    ["bitumen-refining"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.729318774265585,
      ingredients = {
        {type="fluid", name="bitumen", amount=213},
        {type="fluid", name="hot-air", amount=130},
        {type="fluid", name="water", amount=569},
      },
      results = {
        {type="fluid", name="condensates", amount=18},
        {type="fluid", name="high-distillate", amount=18},
        {type="fluid", name="low-distillate", amount=73},
        {type="fluid", name="medium-distillate", amount=55},
        {type="fluid", name="residual-mixture", amount=182},
      },
    },
    ["crude-from-manure"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.95445792371634,
      ingredients = {
        {type="fluid", name="blood", amount=274},
        {type="fluid", name="water-saline", amount=2159},
      },
      results = {
        {type="fluid", name="scrude", amount=131},
        {type="fluid", name="steam", amount=93},
        {type="fluid", name="tailings", amount=93},
        {type="item", name="soot", amount=6},
      },
    },
    ["hot-residual-mixture"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.74,
      ingredients = {
        {type="fluid", name="tailings", amount=140},
        {type="item", name="zinc-chloride", amount=1},
      },
      results = {
        {type="fluid", name="hot-residual-mixture", amount=74},
      },
    },
    ["oil-refining"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.969887497306303,
      ingredients = {
        {type="fluid", name="crude-oil", amount=290},
        {type="fluid", name="water", amount=547},
        {type="item", name="rich-clay", amount=2},
      },
      results = {
        {type="fluid", name="condensates", amount=121},
        {type="fluid", name="high-distillate", amount=121},
        {type="fluid", name="low-distillate", amount=97},
        {type="fluid", name="medium-distillate", amount=97},
        {type="fluid", name="residual-mixture", amount=49},
      },
    },
    ["residual-mixture-distillation"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.5538446374636,
      ingredients = {
        {type="fluid", name="kerosene", amount=710},
        {type="fluid", name="tailings", amount=312},
      },
      results = {
        {type="fluid", name="hot-residual-mixture", amount=39},
        {type="fluid", name="residual-oil", amount=78},
        {type="item", name="coke", amount=62},
      },
    },
    ["used-comb-oil-recycling"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.775422786043443,
      ingredients = {
        {type="fluid", name="vacuum", amount=102},
        {type="item", name="grade-4-copper", amount=1},
      },
      results = {
        {type="fluid", name="bitumen", amount=19},
        {type="fluid", name="residual-oil", amount=39},
      },
    },
    ["used-comb-to-residual-mixture"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.58333333333333,
      ingredients = {
        {type="item", name="bio-container", amount=4},
        {type="item", name="melamine", amount=1},
        {type="item", name="sb-grade-04", amount=12},
      },
      results = {
        {type="fluid", name="residual-mixture", amount=95},
      },
    },
    ["arqad-codex"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=22},
        {type="item", name="copper-cable", amount=58},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="iron-stick", amount=38},
        {type="item", name="steel-plate", amount=31},
        {type="item", name="tin-plate", amount=11},
        {type="item", name="tinned-cable", amount=4},
      },
      results = {
        {type="item", name="arqad-codex", amount=1},
      },
    },
    ["arqad-egg-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.895162542110435,
      ingredients = {
        {type="item", name="arqad-queen", amount=1},
        {type="item", name="hydrofluoric-acid-barrel", amount=19},
        {type="item", name="sb-grade-04", amount=65},
        {type="item", name="used-comb", amount=4},
      },
      results = {
        {type="item", name="arqad-egg", amount=9},
        {type="item", name="arqad-queen", amount=1},
        {type="item", name="barrel", amount=11},
      },
    },
    ["arqad-filled-comb-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.17454586344939,
      ingredients = {
        {type="item", name="ammonia-barrel", amount=1},
        {type="item", name="empty-comb", amount=4},
        {type="item", name="methanal-barrel", amount=6},
        {type="item", name="py-iron-oxide", amount=3},
      },
      results = {
        {type="item", name="barrel", amount=2},
        {type="item", name="filled-comb", amount=6},
      },
    },
    ["arqad-filled-honeycomb-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ore-tin", amount=50},
        {type="item", name="purified-syngas-barrel", amount=1},
      },
      results = {
        {type="item", name="honeycomb", amount=3},
      },
    },
    ["arqad"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.919094495456663,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=966},
        {type="item", name="alien-sample01", amount=53},
        {type="item", name="arqad-codex", amount=1},
        {type="item", name="bio-sample", amount=4},
        {type="item", name="earth-bear-sample", amount=1},
        {type="item", name="py-science-pack-1", amount=4},
      },
      results = {
        {type="item", name="arqad", amount=1},
        {type="item", name="arqad-egg", amount=9},
      },
    },
    ["arqad-egg-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.13459982050465,
      ingredients = {
        {type="item", name="arqad", amount=2},
        {type="item", name="arqad-honey-barrel", amount=1},
        {type="item", name="arqad-queen", amount=1},
        {type="item", name="formic-acid-barrel", amount=49},
        {type="item", name="mixed-ores", amount=5},
        {type="item", name="rare-earth-powder", amount=78},
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
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="auog-pup", amount=8},
        {type="item", name="engine-unit", amount=4},
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="grade-2-chromite", amount=8},
        {type="item", name="gun-turret", amount=37},
        {type="item", name="iron-slime-barrel", amount=3},
        {type="item", name="nickel-plate", amount=23},
        {type="item", name="oil-sand", amount=721},
        {type="item", name="rail-chain-signal", amount=6},
        {type="item", name="ralesia-codex", amount=2},
        {type="item", name="steam-engine", amount=2},
        {type="item", name="stone-brick", amount=116},
      },
      results = {
        {type="item", name="arqad-hive-mk01", amount=3},
      },
    },
    ["arqad-egg-nests-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="arqad-egg", amount=2},
        {type="item", name="boiler", amount=1},
        {type="item", name="cocoon", amount=7},
        {type="item", name="empty-comb", amount=1},
        {type="item", name="purified-syngas-barrel", amount=1},
        {type="item", name="ree-slurry-barrel", amount=6},
        {type="item", name="vrauks-food-01", amount=1},
      },
      results = {
        {type="item", name="arqad-egg-nest", amount=1},
        {type="item", name="barrel", amount=1},
      },
    },
    ["arqad-maggots-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.57155200634683,
      ingredients = {
        {type="item", name="caged-vrauks", amount=4},
        {type="item", name="duralumin", amount=4},
        {type="item", name="nexelit-plate", amount=19},
        {type="item", name="py-tank-9000", amount=2},
        {type="item", name="raw-fiber", amount=31},
        {type="item", name="shell", amount=35},
        {type="item", name="shotgun-shell", amount=32},
        {type="item", name="steam-engine", amount=4},
        {type="item", name="vitreloy", amount=4},
      },
      results = {
        {type="item", name="arqad-maggot", amount=47},
        {type="item", name="cage", amount=16},
        {type="item", name="used-comb", amount=8},
      },
    },
    ["arqad-queen-1"] = {
      mode = "repaired-to-input",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="equipment-chassi", amount=1},
        {type="item", name="grade-3-nickel", amount=5},
        {type="item", name="mixed-ores", amount=144},
      },
      results = {
        {type="item", name="arqad-queen", amount=0.01},
        {type="item", name="barrel", amount=8},
        {type="item", name="used-comb", amount=1},
      },
    },
    ["honey-comb"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.00859423257765,
      ingredients = {
        {type="item", name="arqad-egg", amount=2},
        {type="item", name="rich-clay", amount=3},
      },
      results = {
        {type="fluid", name="arqad-honey", amount=253},
        {type="item", name="empty-honeycomb", amount=5},
      },
    },
    ["hotair-empty-honeycomb-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="fluid", name="gasoline", amount=195},
        {type="fluid", name="muddy-sludge", amount=2628},
      },
      results = {
        {type="item", name="empty-honeycomb", amount=14},
      },
    },
    ["bitumen-to-nitrogen"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.68,
      ingredients = {
        {type="fluid", name="propene", amount=7},
        {type="fluid", name="subcritical-water", amount=100},
        {type="fluid", name="water-saline", amount=107},
      },
      results = {
        {type="fluid", name="nitrogen", amount=136},
      },
    },
    ["bitumen-to-sulfur"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.2,
      ingredients = {
        {type="fluid", name="bitumen", amount=12},
        {type="fluid", name="water-saline", amount=19},
      },
      results = {
        {type="item", name="sulfur", amount=2},
      },
    },
    ["crush-oil-sand"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="oil-sand", amount=6},
      },
      results = {
        {type="item", name="crushed-oil-sand", amount=2},
        {type="item", name="stone", amount=1},
      },
    },
    ["bitumen-gasification"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.93,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=1469},
        {type="fluid", name="oxygen", amount=48},
        {type="fluid", name="water", amount=707},
      },
      results = {
        {type="fluid", name="dirty-syngas", amount=93},
      },
    },
    ["hot-syngas-cooldown"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=142},
        {type="fluid", name="geothermal-water", amount=1371},
        {type="fluid", name="pressured-air", amount=217},
      },
      results = {
        {type="fluid", name="steam", amount=150},
        {type="fluid", name="syngas", amount=250},
      },
    },
    ["quenching-dirty-syngas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.01454881434583,
      ingredients = {
        {type="fluid", name="nitrogen", amount=618},
        {type="fluid", name="vacuum", amount=7863},
        {type="item", name="seaweed", amount=5},
      },
      results = {
        {type="fluid", name="flue-gas", amount=4081},
        {type="fluid", name="purified-syngas", amount=408},
        {type="item", name="soot", amount=8},
      },
    },
    ["scrubbing-purified-syngas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.899886274349393,
      ingredients = {
        {type="fluid", name="hot-air", amount=120},
        {type="fluid", name="vacuum", amount=2889},
      },
      results = {
        {type="fluid", name="hot-syngas", amount=85},
        {type="item", name="soot", amount=2},
      },
    },
    ["oil-sand-slurry"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.64,
      ingredients = {
        {type="fluid", name="pressured-air", amount=208},
        {type="fluid", name="pressured-water", amount=582},
        {type="fluid", name="syngas", amount=38},
        {type="item", name="lead-plate", amount=4},
        {type="item", name="meat", amount=2},
      },
      results = {
        {type="fluid", name="oil-sand-slurry", amount=164},
      },
    },
    ["bitumen-froth"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.15,
      ingredients = {
        {type="fluid", name="pressured-air", amount=129},
        {type="fluid", name="vacuum", amount=2393},
        {type="item", name="benzene-canister", amount=1},
      },
      results = {
        {type="fluid", name="bitumen-froth", amount=115},
        {type="fluid", name="tailings", amount=115},
      },
    },
    ["btx-to-benzene"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.115,
      ingredients = {
        {type="fluid", name="btx", amount=42},
        {type="fluid", name="pressured-air", amount=2841},
        {type="fluid", name="pressured-water", amount=331},
        {type="item", name="chromium", amount=2},
      },
      results = {
        {type="fluid", name="benzene", amount=223},
      },
    },
    ["btx-to-methane"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.77,
      ingredients = {
        {type="fluid", name="nitrogen", amount=782},
        {type="fluid", name="pressured-air", amount=384},
        {type="fluid", name="pressured-water", amount=745},
        {type="fluid", name="scrude", amount=434},
      },
      results = {
        {type="fluid", name="methane", amount=531},
      },
    },
    ["aromatics-to-petgas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.9875,
      ingredients = {
        {type="fluid", name="aromatics", amount=91},
        {type="fluid", name="steam", amount=193},
        {type="item", name="condensates-canister", amount=1},
      },
      results = {
        {type="fluid", name="petroleum-gas", amount=159},
      },
    },
    ["bitumen"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.43636584304218,
      ingredients = {
        {type="fluid", name="bitumen-froth", amount=42},
        {type="fluid", name="naphtha", amount=54},
        {type="fluid", name="pressured-water", amount=5273},
      },
      results = {
        {type="fluid", name="bitumen", amount=359},
        {type="fluid", name="tailings", amount=72},
      },
    },
    ["explosive-glycerol"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=2303},
        {type="fluid", name="flue-gas", amount=1559},
        {type="fluid", name="methanol", amount=776},
        {type="fluid", name="water", amount=5022},
        {type="item", name="clean-nexelit", amount=34},
      },
      results = {
        {type="item", name="explosives", amount=8},
      },
    },
    ["filtration-media"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 3.2,
      ingredients = {
        {type="item", name="chromium", amount=27},
        {type="item", name="grade-3-lead", amount=4},
        {type="item", name="gravel", amount=86},
        {type="item", name="pcb1", amount=3},
        {type="item", name="refined-hazard-concrete", amount=9},
      },
      results = {
        {type="item", name="filtration-media", amount=16},
      },
    },
    ["niobium-dust"] = {
      mode = "repaired-to-input",
      science_level = 3,
      energy_required_multiplier = 1.09470338461202,
      ingredients = {
        {type="item", name="bonemeal", amount=3},
      },
      results = {
        {type="item", name="gravel", amount=2},
        {type="item", name="niobium-dust", amount=11},
      },
    },
    ["stone-distilation"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.61166968659522,
      ingredients = {
        {type="fluid", name="vacuum", amount=92},
        {type="fluid", name="water", amount=153},
        {type="item", name="bonemeal", amount=2},
        {type="item", name="ceramic", amount=3},
        {type="item", name="stone", amount=49},
      },
      results = {
        {type="fluid", name="tailings", amount=163},
        {type="fluid", name="tar", amount=163},
        {type="item", name="coarse", amount=16},
        {type="item", name="tailings-dust", amount=16},
      },
    },
    ["milling-ree"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="rare-earth-ore", amount=12},
      },
      results = {
        {type="item", name="gravel", amount=2},
        {type="item", name="rare-earth-dust", amount=3},
      },
    },
    ["rare-earth-beneficiation"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.27132272079366,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=2304},
        {type="fluid", name="sulfuric-acid", amount=163},
        {type="item", name="caged-auog", amount=1},
        {type="item", name="coke", amount=3},
        {type="item", name="rail", amount=3},
      },
      results = {
        {type="fluid", name="rare-earth-mud", amount=318},
        {type="fluid", name="steam", amount=2548},
        {type="item", name="rich-dust", amount=6},
        {type="item", name="sand", amount=13},
      },
    },
    ["milling-molybdenite"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-3-tin", amount=1},
      },
      results = {
        {type="item", name="gravel", amount=1},
        {type="item", name="molybdenite-dust", amount=10},
      },
    },
    ["ree-float"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.06948722865982,
      ingredients = {
        {type="fluid", name="tailings", amount=305},
        {type="item", name="btx-barrel", amount=1},
        {type="item", name="ralesia-seeds", amount=2},
      },
      results = {
        {type="fluid", name="rare-earth-mud", amount=109},
        {type="item", name="zinc-plate", amount=5},
      },
    },
    ["ree-slurry"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.49,
      ingredients = {
        {type="fluid", name="olefin", amount=308},
        {type="fluid", name="water", amount=12138},
        {type="fluid", name="water-saline", amount=1270},
      },
      results = {
        {type="fluid", name="ree-slurry", amount=149},
        {type="fluid", name="tailings", amount=149},
      },
    },
    ["ree-solution"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.739997697124315,
      ingredients = {
        {type="fluid", name="hot-air", amount=244},
        {type="fluid", name="water-saline", amount=1306},
      },
      results = {
        {type="fluid", name="ree-solution", amount=74},
        {type="item", name="uranium-ore", amount=0.0737361540550119},
      },
    },
    ["crusher-ree"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.8,
      ingredients = {
        {type="item", name="methanal-barrel", amount=1},
        {type="item", name="oil-sand", amount=9},
      },
      results = {
        {type="item", name="rare-earth-powder", amount=9},
        {type="item", name="stone", amount=9},
      },
    },
    ["ree-concentrate2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.546432794778632,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=6732},
        {type="fluid", name="hot-air", amount=990},
        {type="fluid", name="sulfuric-acid", amount=25},
      },
      results = {
        {type="item", name="chromite-sand", amount=5},
        {type="item", name="ree-concentrate", amount=11},
      },
    },
    ["ree-concentrate1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.30591811496654,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=12002},
        {type="fluid", name="hot-air", amount=726},
        {type="fluid", name="scrude", amount=417},
      },
      results = {
        {type="item", name="iron-oxide", amount=8},
        {type="item", name="ree-concentrate", amount=13},
      },
    },
    ["reo"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ulric", amount=2},
      },
      results = {
        {type="item", name="iron-oxide", amount=2},
        {type="item", name="reo", amount=5},
      },
    },
    ["ree-concentrate3"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.24823310120067,
      ingredients = {
        {type="fluid", name="coal-gas", amount=997},
        {type="fluid", name="purest-nitrogen-gas", amount=402},
        {type="fluid", name="sulfuric-acid", amount=224},
      },
      results = {
        {type="item", name="copper-ore", amount=6},
        {type="item", name="ree-concentrate", amount=25},
      },
    },
    ["xyhiphoe-codex"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-stick", amount=61},
        {type="item", name="tinned-cable", amount=316},
      },
      results = {
        {type="item", name="xyhiphoe-codex", amount=1},
      },
    },
    ["xyhiphoe-cub-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.28179998399002,
      ingredients = {
        {type="fluid", name="hot-air", amount=1888},
        {type="fluid", name="steam", amount=2304},
        {type="fluid", name="water-saline", amount=1084},
        {type="item", name="diesel-barrel", amount=1},
        {type="item", name="fish", amount=14},
        {type="item", name="moondrop", amount=1},
        {type="item", name="moss", amount=2},
        {type="item", name="outlet-gas-02-barrel", amount=1},
        {type="item", name="ralesia", amount=7},
        {type="item", name="syngas-canister", amount=2},
        {type="item", name="urea", amount=1},
      },
      results = {
        {type="fluid", name="waste-water", amount=850},
        {type="item", name="xyhiphoe-cub", amount=5},
      },
    },
    ["xyhiphoe-pool-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="aluminium-plate", amount=167},
        {type="item", name="barrel", amount=12},
        {type="item", name="duralumin", amount=19},
        {type="item", name="empty-comb", amount=64},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="fiberboard", amount=146},
        {type="item", name="iron-plate", amount=200},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="oil-sand", amount=87},
        {type="item", name="pbsb-alloy", amount=31},
        {type="item", name="pump", amount=29},
        {type="item", name="ralesia-plantation-mk01", amount=1},
        {type="item", name="resistor1", amount=28},
        {type="item", name="small-parts-01", amount=127},
        {type="item", name="tinned-cable", amount=303},
        {type="item", name="titanium-plate", amount=952},
        {type="item", name="vane-mk01", amount=1},
        {type="item", name="vitreloy", amount=19},
      },
      results = {
        {type="item", name="xyhiphoe-pool-mk01", amount=3},
      },
    },
    ["xyhiphoe"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 4,
      ingredients = {
        {type="fluid", name="fish-oil", amount=2553},
        {type="item", name="aluminium-plate", amount=333},
        {type="item", name="bio-sample01", amount=10},
        {type="item", name="cdna", amount=4},
        {type="item", name="chromium", amount=118},
        {type="item", name="copper-low-dust", amount=24},
        {type="item", name="earth-cow-sample", amount=4},
        {type="item", name="earth-crustacean-sample", amount=2},
        {type="item", name="earth-generic-sample", amount=5},
        {type="item", name="lab-instrument", amount=7},
        {type="item", name="nichrome", amount=31},
        {type="item", name="retrovirus", amount=59},
        {type="item", name="unslimed-iron", amount=44},
      },
      results = {
        {type="item", name="xyhiphoe", amount=4},
      },
    },
    ["xyhiphoe-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.935912140856651,
      ingredients = {
        {type="fluid", name="hot-air", amount=882},
        {type="fluid", name="molten-iron", amount=16},
        {type="fluid", name="steam", amount=612},
        {type="item", name="moondrop", amount=2},
        {type="item", name="syngas-canister", amount=11},
      },
      results = {
        {type="fluid", name="waste-water", amount=177},
        {type="item", name="xyhiphoe", amount=1},
      },
    },
    ["niobium-concentrate"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.69509528549851,
      ingredients = {
        {type="fluid", name="nitrogen", amount=147},
        {type="fluid", name="pressured-steam", amount=2088},
        {type="item", name="aromatics-canister", amount=2},
      },
      results = {
        {type="item", name="niobium-concentrate", amount=17},
        {type="item", name="sand", amount=3},
      },
    },
    ["nbfe-alloy"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="niobium-concentrate", amount=13},
        {type="item", name="steel-plate", amount=5},
      },
      results = {
        {type="item", name="nbfe-alloy", amount=2},
      },
    },
    ["niobium-oxide"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="fluid", name="nitrogen", amount=106},
        {type="fluid", name="pressured-steam", amount=1503},
      },
      results = {
        {type="item", name="niobium-oxide", amount=4},
      },
    },
    ["niobium-plate"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="item", name="ceramic", amount=12},
        {type="item", name="iron-ore-dust", amount=1},
        {type="item", name="niobium-concentrate", amount=5},
        {type="item", name="steel-plate", amount=2},
      },
      results = {
        {type="item", name="niobium-plate", amount=5},
      },
    },
    ["niobium-complex"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.92,
      ingredients = {
        {type="fluid", name="hydrogen-chloride", amount=54},
        {type="item", name="grade-3-chromite", amount=7},
        {type="item", name="sulfuric-acid-barrel", amount=2},
      },
      results = {
        {type="fluid", name="niobium-complex", amount=192},
      },
    },
    ["niobium-powder"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.18817154717025,
      ingredients = {
        {type="item", name="outlet-gas-01-canister", amount=1},
      },
      results = {
        {type="item", name="niobium-powder", amount=6},
        {type="item", name="stone", amount=2},
      },
    },
    ["fill-methanol-gas-canister"] = {
      mode = "input-preserved-untransformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="methanol", amount=100},
        {type="item", name="empty-fuel-canister", amount=1},
      },
      results = {
        {type="item", name="methanol-gas-canister", amount=1},
      },
    },
    ["empty-methanol-gas-canister"] = {
      mode = "input-preserved-untransformed",
      science_level = 3,
      energy_required_multiplier = 1.04430974370916,
      ingredients = {
        {type="item", name="copper-rejects", amount=3},
      },
      results = {
        {type="fluid", name="methanol", amount=108},
        {type="item", name="empty-gas-canister", amount=1},
      },
    },
    ["hydrogen-chloride-void"] = {
      mode = "input-preserved-untransformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="nitrogen", amount=461},
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
        {type="fluid", name="pressured-water", amount=1714},
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
        {type="item", name="fiber", amount=6},
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
        {type="fluid", name="vpulp3", amount=100},
      },
      results = {
        {type="fluid", name="flue-gas", amount=50},
        {type="fluid", name="vpulp1", amount=50},
      },
    },
    ["defender-capsule"] = {
      mode = "kept-transformed",
      science_level = 4,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="firearm-magazine", amount=4},
        {type="item", name="petroleum-gas-canister", amount=11},
        {type="item", name="pipe", amount=10},
        {type="item", name="transport-belt", amount=2},
      },
      results = {
        {type="item", name="defender-capsule", amount=1},
      },
    },
    ["flamethrower"] = {
      mode = "kept-transformed",
      science_level = 4,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boric-acid-barrel", amount=1},
        {type="item", name="iron-plate", amount=7},
        {type="item", name="transport-belt", amount=15},
      },
      results = {
        {type="item", name="flamethrower", amount=1},
      },
    },
    ["rocket-launcher"] = {
      mode = "kept-transformed",
      science_level = 4,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="fine-powdered-biomass", amount=66},
        {type="item", name="firearm-magazine", amount=4},
        {type="item", name="grade-1-zinc", amount=1},
        {type="item", name="petroleum-gas-canister", amount=11},
        {type="item", name="pipe", amount=3},
        {type="item", name="pitch-canister", amount=6},
        {type="item", name="sb-grade-02", amount=13},
      },
      results = {
        {type="item", name="rocket-launcher", amount=1},
      },
    },
    ["flamethrower-ammo"] = {
      mode = "kept-transformed",
      science_level = 4,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="tailings", amount=353},
        {type="item", name="sb-grade-02", amount=15},
      },
      results = {
        {type="item", name="flamethrower-ammo", amount=1},
      },
    },
    ["rocket"] = {
      mode = "kept-transformed",
      science_level = 4,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-pup", amount=5},
        {type="item", name="moondrop-seeds", amount=2},
        {type="item", name="sb-grade-02", amount=6},
      },
      results = {
        {type="item", name="rocket", amount=1},
      },
    },
    ["flamethrower-turret"] = {
      mode = "kept-transformed",
      science_level = 4,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="auog-pup", amount=7},
        {type="item", name="crushed-quartz", amount=190},
        {type="item", name="duralumin", amount=6},
        {type="item", name="iron-plate", amount=189},
        {type="item", name="pitch-canister", amount=4},
        {type="item", name="soda-ash-barrel", amount=6},
        {type="item", name="transport-belt", amount=146},
      },
      results = {
        {type="item", name="flamethrower-turret", amount=2},
      },
    },
    ["land-mine"] = {
      mode = "kept-transformed",
      science_level = 4,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="auog-pup", amount=9},
        {type="item", name="boric-acid-barrel", amount=14},
      },
      results = {
        {type="item", name="land-mine", amount=6},
      },
    },
    ["py-science-pack-2"] = {
      mode = "kept-transformed",
      science_level = 4,
      energy_required_multiplier = 1.55555555555556,
      ingredients = {
        {type="fluid", name="tailings", amount=31020},
        {type="fluid", name="water-saline", amount=5647},
        {type="item", name="alien-sample-02", amount=1},
        {type="item", name="barrel-milk", amount=6},
        {type="item", name="boric-acid-barrel", amount=113},
        {type="item", name="cottongut", amount=25},
        {type="item", name="intermetallics", amount=15},
        {type="item", name="melamine", amount=94},
        {type="item", name="paragen", amount=1},
        {type="item", name="petri-dish-bacteria", amount=21},
        {type="item", name="sb-grade-02", amount=10794},
        {type="item", name="stone-wool", amount=67},
        {type="item", name="zipir1", amount=1},
      },
      results = {
        {type="item", name="py-science-pack-2", amount=28},
      },
    },
    ["arthropod-blood-to-copper"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.95,
      ingredients = {
        {type="fluid", name="subcritical-water", amount=1499},
      },
      results = {
        {type="item", name="copper-ore", amount=19},
      },
    },
    ["guts-to-copper"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="item", name="brain", amount=3},
      },
      results = {
        {type="item", name="copper-ore", amount=24},
      },
    },
    ["meat-and-gut-to-copper"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.914285714285714,
      ingredients = {
        {type="fluid", name="flue-gas", amount=652},
        {type="fluid", name="tailings", amount=356},
        {type="item", name="brain", amount=1},
        {type="item", name="meat", amount=2},
      },
      results = {
        {type="item", name="copper-ore", amount=32},
      },
    },
    ["tuuphra-to-copper"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="tuuphra", amount=2},
      },
      results = {
        {type="item", name="copper-ore", amount=10},
      },
    },
    ["yaedols-to-copper"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.875,
      ingredients = {
        {type="item", name="unslimed-iron", amount=1},
        {type="item", name="workers-food", amount=1},
        {type="item", name="yaedols", amount=2},
      },
      results = {
        {type="item", name="copper-ore", amount=15},
      },
    },
    ["blood-to-urea"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.7,
      ingredients = {
        {type="fluid", name="blood", amount=155},
        {type="item", name="fiberboard", amount=1},
      },
      results = {
        {type="item", name="urea", amount=17},
      },
    },
    ["btx-to-ethylene"] = {
      mode = "repaired-to-input",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="btx", amount=100},
        {type="fluid", name="pressured-water", amount=343},
        {type="item", name="nexelit-plate", amount=1},
      },
      results = {
        {type="fluid", name="ethylene", amount=100},
      },
    },
    ["ceramic-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.7,
      ingredients = {
        {type="item", name="powdered-phosphate-rock", amount=3},
        {type="item", name="salt", amount=2},
      },
      results = {
        {type="item", name="ceramic", amount=7},
      },
    },
    ["crude-cermet"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2.2,
      ingredients = {
        {type="item", name="calcium-carbide", amount=1},
        {type="item", name="crushed-molybdenite", amount=1},
        {type="item", name="graphite", amount=4},
        {type="item", name="ore-lead", amount=2},
        {type="item", name="powdered-phosphate-rock", amount=4},
        {type="item", name="salt", amount=8},
      },
      results = {
        {type="item", name="crude-cermet", amount=11},
      },
    },
    ["cermet"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="lubricant", amount=188},
        {type="item", name="ash", amount=4},
        {type="item", name="crude-cermet", amount=1},
      },
      results = {
        {type="item", name="cermet", amount=4},
      },
    },
    ["concrete-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="fluid", name="boric-acid", amount=306},
        {type="item", name="cellulose", amount=4},
      },
      results = {
        {type="item", name="concrete", amount=15},
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
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.999815512176131,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=43},
        {type="item", name="salt", amount=25},
      },
      results = {
        {type="fluid", name="water", amount=48},
        {type="item", name="sodium-sulfate", amount=1},
      },
    },
    ["fawogae-to-sulfur"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.8,
      ingredients = {
        {type="item", name="fawogae", amount=5},
        {type="item", name="fungal-substrate", amount=1},
        {type="item", name="ore-aluminium", amount=4},
      },
      results = {
        {type="item", name="sulfur", amount=9},
      },
    },
    ["fish-to-iron"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.3,
      ingredients = {
        {type="fluid", name="coal-gas", amount=316},
        {type="fluid", name="fish-oil", amount=21},
      },
      results = {
        {type="item", name="iron-ore", amount=26},
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
        {type="item", name="iron-oxide", amount=11},
        {type="item", name="phosphate-rock", amount=4},
      },
      results = {
        {type="item", name="iron-ore", amount=1},
        {type="item", name="p2s5", amount=1},
      },
    },
    ["tuupha-to-iron"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=96},
        {type="item", name="pipe", amount=7},
        {type="item", name="tuuphra", amount=8},
      },
      results = {
        {type="item", name="iron-ore", amount=8},
      },
    },
    ["trits-codex"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="seaweed", amount=303},
      },
      results = {
        {type="item", name="trits-codex", amount=1},
      },
    },
    ["trits-reef-mk01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="arthropod-blood-barrel", amount=1},
        {type="item", name="carbon-dioxide-barrel", amount=10},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="fenxsb-alloy", amount=10},
        {type="item", name="fiber", amount=231},
        {type="item", name="fiberboard", amount=96},
        {type="item", name="kicalk-seeds", amount=103},
        {type="item", name="lens", amount=21},
        {type="item", name="limestone", amount=203},
        {type="item", name="middle-oil-canister", amount=17},
        {type="item", name="molybdenite-pulp-barrel", amount=53},
        {type="item", name="oil-sand-slurry-barrel", amount=16},
        {type="item", name="olefin-barrel", amount=13},
        {type="item", name="pipe", amount=13},
        {type="item", name="py-tank-5000", amount=1},
        {type="item", name="sic", amount=20},
        {type="item", name="steel-plate", amount=30},
        {type="item", name="titanium-plate", amount=33},
        {type="item", name="transport-belt", amount=15},
      },
      results = {
        {type="item", name="trits-reef-mk01", amount=1},
      },
    },
    ["trits"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="alien-sample-02", amount=5},
        {type="item", name="aluminium-plate", amount=138},
        {type="item", name="cocoon-mk02", amount=19},
        {type="item", name="cytostatics", amount=4},
        {type="item", name="earth-crustacean-sample", amount=2},
        {type="item", name="earth-generic-sample", amount=4},
        {type="item", name="mukmoux-codex", amount=1},
      },
      results = {
        {type="item", name="trits", amount=2},
      },
    },
    ["trits-cub-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.48405852964296,
      ingredients = {
        {type="fluid", name="water", amount=7416},
        {type="item", name="albumin", amount=1},
        {type="item", name="fertilizer", amount=4},
        {type="item", name="fish", amount=1},
        {type="item", name="niobium-plate", amount=1},
        {type="item", name="sea-sponge-sprouts-mk02", amount=1},
        {type="item", name="trits", amount=2},
        {type="item", name="wood", amount=10},
      },
      results = {
        {type="fluid", name="waste-water", amount=426},
        {type="item", name="trits-pup", amount=3},
      },
    },
    ["trits-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.4899257922826,
      ingredients = {
        {type="fluid", name="anthraquinone", amount=49},
        {type="item", name="ferrite", amount=2},
        {type="item", name="filtration-media", amount=2},
        {type="item", name="fish", amount=1},
        {type="item", name="moondrop-mk02", amount=1},
        {type="item", name="nylon-parts", amount=7},
        {type="item", name="pipe", amount=9},
        {type="item", name="trits-pup", amount=1},
        {type="item", name="wood-seeds", amount=27},
      },
      results = {
        {type="fluid", name="waste-water", amount=360},
        {type="item", name="trits", amount=3},
      },
    },
    ["glass-core"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="gold-plate", amount=3},
      },
      results = {
        {type="item", name="glass-core", amount=1},
      },
    },
    ["hotair-glass-core"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="molten-glass", amount=95},
        {type="item", name="silver-plate", amount=3},
      },
      results = {
        {type="item", name="glass-core", amount=2},
      },
    },
    ["guar-sample"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bio-sample01", amount=12},
        {type="item", name="cytostatics", amount=6},
        {type="item", name="earth-cow-sample", amount=2},
        {type="item", name="earth-crustacean-sample", amount=7},
        {type="item", name="earth-potato-sample", amount=1},
        {type="item", name="korlex-codex", amount=3},
        {type="item", name="ulric-codex", amount=4},
        {type="item", name="zipir-codex", amount=10},
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
        {type="item", name="guar", amount=2},
      },
      results = {
        {type="item", name="guar-seeds", amount=8},
      },
    },
    ["guar-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2.1,
      ingredients = {
        {type="fluid", name="water", amount=179},
        {type="item", name="coal-dust", amount=4},
        {type="item", name="guar-seeds", amount=6},
        {type="item", name="kicalk", amount=1},
        {type="item", name="limestone", amount=3},
        {type="item", name="stone", amount=18},
      },
      results = {
        {type="item", name="guar", amount=21},
      },
    },
    ["acid-refined-concrete"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="acetic-acid", amount=6},
        {type="item", name="rare-earth-ore", amount=2},
        {type="item", name="refined-hazard-concrete", amount=3},
      },
      results = {
        {type="item", name="acid-refined-concrete", amount=4},
      },
    },
    ["black-refined-concrete"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.666666666666667,
      ingredients = {
        {type="fluid", name="blood", amount=1},
        {type="item", name="rare-earth-ore", amount=10},
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
        {type="item", name="fertilizer", amount=4},
        {type="item", name="pure-sand", amount=8},
        {type="item", name="refined-hazard-concrete", amount=2},
      },
      results = {
        {type="item", name="blue-refined-concrete", amount=7},
      },
    },
    ["cyan-refined-concrete"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="cyanic-acid", amount=10},
        {type="item", name="pipe", amount=2},
      },
      results = {
        {type="item", name="cyan-refined-concrete", amount=3},
      },
    },
    ["orange-refined-concrete"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 4.66666666666667,
      ingredients = {
        {type="item", name="cellulose", amount=3},
        {type="item", name="fertilizer", amount=5},
        {type="item", name="methane-barrel", amount=2},
        {type="item", name="refined-hazard-concrete", amount=2},
      },
      results = {
        {type="item", name="orange-refined-concrete", amount=14},
      },
    },
    ["purple-refined-concrete"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=137},
      },
      results = {
        {type="item", name="purple-refined-concrete", amount=3},
      },
    },
    ["brown-refined-concrete"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="geothermal-water-barrel", amount=4},
        {type="item", name="iron-oxide", amount=7},
        {type="item", name="phosphate-rock", amount=8},
        {type="item", name="py-limestone", amount=1},
      },
      results = {
        {type="item", name="brown-refined-concrete", amount=6},
      },
    },
    ["green-refined-concrete"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="item", name="hot-air-barrel", amount=1},
        {type="item", name="pure-sand", amount=6},
      },
      results = {
        {type="item", name="green-refined-concrete", amount=4},
      },
    },
    ["pink-refined-concrete"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="formica", amount=2},
        {type="item", name="moondrop-seeds", amount=4},
      },
      results = {
        {type="item", name="pink-refined-concrete", amount=3},
      },
    },
    ["red-refined-concrete"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="fluid", name="blood", amount=18},
        {type="item", name="melamine", amount=4},
        {type="item", name="powdered-aluminium", amount=1},
      },
      results = {
        {type="item", name="red-refined-concrete", amount=5},
      },
    },
    ["yellow-refined-concrete"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="item", name="fertilizer", amount=1},
        {type="item", name="refined-hazard-concrete", amount=4},
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
        {type="item", name="boric-acid-barrel", amount=169},
        {type="item", name="creamy-latex-barrel", amount=2},
        {type="item", name="distilator", amount=1},
        {type="item", name="empty-fuel-canister", amount=84},
        {type="item", name="fiber", amount=38},
        {type="item", name="gasoline-barrel", amount=3},
        {type="item", name="grade-2-nickel", amount=40},
        {type="item", name="lead-plate", amount=134},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="molybdenite-dust", amount=82},
        {type="item", name="niobium-plate", amount=10},
        {type="item", name="nxsb-alloy", amount=3},
        {type="item", name="ree-solution-barrel", amount=3},
        {type="item", name="sic", amount=3},
        {type="item", name="tin-plate", amount=13},
        {type="item", name="transport-belt", amount=214},
      },
      results = {
        {type="item", name="ipod", amount=2},
      },
    },
    ["kicalk-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.45,
      ingredients = {
        {type="item", name="ash", amount=8},
        {type="item", name="biomass", amount=4},
        {type="item", name="fertilizer", amount=5},
        {type="item", name="glass", amount=5},
        {type="item", name="ground-sample01", amount=4},
      },
      results = {
        {type="item", name="kicalk", amount=9},
      },
    },
    ["kicalk-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.281571573617,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=180},
        {type="fluid", name="steam", amount=200},
        {type="item", name="ash", amount=9},
        {type="item", name="biomass", amount=12},
        {type="item", name="fertilizer", amount=2},
        {type="item", name="ground-sample01", amount=1},
        {type="item", name="kicalk", amount=2},
        {type="item", name="powdered-phosphate-rock", amount=4},
        {type="item", name="raw-fiber", amount=36},
        {type="item", name="refined-hazard-concrete", amount=1},
        {type="item", name="small-lamp", amount=4},
      },
      results = {
        {type="item", name="kicalk", amount=1},
        {type="item", name="kicalk-mk02", amount=0.00640785786808502},
        {type="item", name="kicalk-seeds-mk02", amount=0.0256314314723401},
      },
    },
    ["kicalk-mk02-breeder"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.998822784135654,
      ingredients = {
        {type="fluid", name="flutec-pp6", amount=49},
        {type="item", name="kicalk-seeds-mk02", amount=5},
        {type="item", name="small-lamp", amount=4},
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
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="oxygen", amount=121},
        {type="item", name="guts", amount=2},
        {type="item", name="meat", amount=14},
      },
      results = {
        {type="item", name="phosphate-rock", amount=4},
      },
    },
    ["wood-seeds-to-phosphate"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="wood-seeds", amount=19},
      },
      results = {
        {type="item", name="phosphate-rock", amount=2},
      },
    },
    ["ocula"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="molten-iron", amount=1383},
        {type="item", name="condensates-barrel", amount=4101},
        {type="item", name="kicalk-mk02", amount=100},
        {type="item", name="low-grade-copper", amount=113},
        {type="item", name="natural-gas-barrel", amount=477},
      },
      results = {
        {type="item", name="ocula", amount=1},
      },
    },
    ["py-logo-15tiles"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water-saline", amount=2166},
        {type="item", name="geothermal-water-barrel", amount=7},
        {type="item", name="p2s5", amount=19},
      },
      results = {
        {type="item", name="py-logo-15tiles", amount=1},
      },
    },
    ["rail-2"] = {
      mode = "repaired-to-input",
      science_level = 5,
      energy_required_multiplier = 1.41666666666667,
      ingredients = {
        {type="item", name="formica", amount=3},
        {type="item", name="hazard-concrete", amount=15},
        {type="item", name="light-oil-canister", amount=1},
        {type="item", name="pipe", amount=4},
      },
      results = {
        {type="item", name="rail", amount=17},
      },
    },
    ["resorcinol"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="crushed-molybdenite", amount=4},
        {type="item", name="gunpowder", amount=3},
      },
      results = {
        {type="item", name="resorcinol", amount=1},
      },
    },
    ["sample-cup"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="melamine", amount=5},
      },
      results = {
        {type="item", name="sample-cup", amount=4},
      },
    },
    ["sea-sponge-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.16287771178896,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=104},
        {type="fluid", name="zogna-bacteria", amount=93},
        {type="item", name="sea-sponge", amount=2},
        {type="item", name="sea-sponge-sprouts", amount=1},
      },
      results = {
        {type="fluid", name="water-saline", amount=58},
        {type="item", name="sea-sponge", amount=1},
        {type="item", name="sea-sponge-mk02", amount=0.00584397412379548},
      },
    },
    ["sea-sponge-sprouts-mk02-breeder"] = {
      mode = "repaired-to-input",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="sea-sponge-sprouts", amount=11},
      },
      results = {
        {type="item", name="sea-sponge-sprouts-mk02", amount=3},
      },
    },
    ["sea-sponge-mk02-breeder"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 3.74733549681281,
      ingredients = {
        {type="fluid", name="zogna-bacteria", amount=252},
        {type="item", name="sea-sponge-sprouts-mk02", amount=2},
      },
      results = {
        {type="fluid", name="water-saline", amount=177},
        {type="item", name="sea-sponge-mk02", amount=3},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="slacked-lime", amount=63},
        {type="fluid", name="water-saline", amount=42},
        {type="item", name="fertilizer", amount=1},
        {type="item", name="salt", amount=3},
      },
      results = {
        {type="item", name="seaweed", amount=30},
      },
    },
    ["seaweed-mk03"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water-saline", amount=215},
        {type="item", name="ethylene-canister", amount=8},
        {type="item", name="workers-food", amount=13},
      },
      results = {
        {type="item", name="seaweed-mk03", amount=1},
      },
    },
    ["tuuphra-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.625,
      ingredients = {
        {type="fluid", name="manure-bacteria", amount=38},
        {type="item", name="coal-dust", amount=3},
        {type="item", name="ground-sample01", amount=7},
        {type="item", name="limestone", amount=1},
        {type="item", name="ralesia", amount=4},
        {type="item", name="ralesia-seeds", amount=8},
        {type="item", name="sand", amount=10},
      },
      results = {
        {type="item", name="tuuphra", amount=5},
      },
    },
    ["tuuphra-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.45105674648147,
      ingredients = {
        {type="fluid", name="manure-bacteria", amount=82},
        {type="item", name="coke", amount=73},
        {type="item", name="ground-sample01", amount=37},
        {type="item", name="manure", amount=11},
        {type="item", name="ralesia", amount=3},
        {type="item", name="ralesia-seeds", amount=44},
        {type="item", name="sand", amount=7},
        {type="item", name="soil", amount=42},
        {type="item", name="tuuphra", amount=2},
        {type="item", name="tuuphra-seeds", amount=8},
      },
      results = {
        {type="item", name="tuuphra", amount=1},
        {type="item", name="tuuphra-mk02", amount=0.00725528373240737},
      },
    },
    ["tuuphra-mk02-breeder"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.727272727272727,
      ingredients = {
        {type="fluid", name="manure-bacteria", amount=155},
        {type="fluid", name="propene", amount=1279},
        {type="item", name="cellulose", amount=1},
        {type="item", name="nichrome", amount=1},
        {type="item", name="tuuphra", amount=5},
        {type="item", name="tuuphra-mk02", amount=1},
      },
      results = {
        {type="item", name="tuuphra-mk02", amount=5},
      },
    },
    ["xenogenic-from-bonemeal"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.21176470588235,
      ingredients = {
        {type="fluid", name="steam", amount=865},
        {type="item", name="brain", amount=1},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=103},
      },
    },
    ["xenogenic-from-bones"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=491},
        {type="item", name="brain", amount=2},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=45},
      },
    },
    ["xenogenic-from-brains"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.85,
      ingredients = {
        {type="fluid", name="industrial-solvent", amount=12},
        {type="item", name="brain", amount=4},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=17},
      },
    },
    ["xenogenic-from-chitin"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.757142857142857,
      ingredients = {
        {type="item", name="brain", amount=6},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=53},
      },
    },
    ["xenogenic-from-fat"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.6,
      ingredients = {
        {type="fluid", name="oleochemicals", amount=5},
        {type="fluid", name="oxygen", amount=40},
        {type="item", name="guts", amount=2},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=12},
      },
    },
    ["xenogenic-from-guts"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.575,
      ingredients = {
        {type="item", name="brain", amount=1},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=23},
      },
    },
    ["xenogenic-from-skin"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.1,
      ingredients = {
        {type="fluid", name="water", amount=2341},
        {type="item", name="brain", amount=1},
        {type="item", name="meat", amount=12},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=66},
      },
    },
    ["xenogenic-from-meat"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.866666666666667,
      ingredients = {
        {type="item", name="guts", amount=2},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=26},
      },
    },
    ["Moss-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.75,
      ingredients = {
        {type="fluid", name="water", amount=421},
        {type="item", name="crushed-molybdenite", amount=4},
        {type="item", name="gunpowder", amount=7},
        {type="item", name="rich-clay", amount=6},
        {type="item", name="stone", amount=19},
      },
      results = {
        {type="item", name="moss", amount=42},
      },
    },
    ["moss-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.46603662122321,
      ingredients = {
        {type="fluid", name="hydrogen", amount=216},
        {type="item", name="chromium", amount=2},
        {type="item", name="methanol-gas-canister", amount=1},
        {type="item", name="moondrop", amount=1},
        {type="item", name="native-flora", amount=16},
      },
      results = {
        {type="item", name="moss-mk02", amount=0.0293207324244642},
      },
    },
    ["moss-mk02r"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=9408},
        {type="item", name="clay-pit-mk01", amount=5},
        {type="item", name="moss-mk02", amount=3},
        {type="item", name="plasmids", amount=1},
        {type="item", name="urea", amount=55},
      },
      results = {
        {type="item", name="moss-mk02", amount=6},
      },
    },
    ["biomass-molten-salt-02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.985,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=49137},
        {type="item", name="grade-3-ti", amount=1},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=394},
      },
    },
    ["coal-molten-salt-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.592,
      ingredients = {
        {type="fluid", name="residual-mixture", amount=4282},
        {type="fluid", name="trichlorosilane", amount=1184},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=796},
      },
    },
    ["fatty-acids-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.76,
      ingredients = {
        {type="fluid", name="flue-gas", amount=375},
        {type="fluid", name="organic-solvent", amount=54},
        {type="item", name="salt", amount=114},
      },
      results = {
        {type="fluid", name="fatty-acids", amount=38},
      },
    },
    ["oleochemicals-to-fatty-acids"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.18,
      ingredients = {
        {type="fluid", name="oleochemicals", amount=18},
      },
      results = {
        {type="fluid", name="fatty-acids", amount=9},
      },
    },
    ["perylene"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.44,
      ingredients = {
        {type="fluid", name="tar", amount=269},
        {type="item", name="navens", amount=10},
        {type="item", name="pyrite", amount=9},
      },
      results = {
        {type="fluid", name="perylene", amount=72},
      },
    },
    ["geo-he-01"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.706666666666667,
      ingredients = {
        {type="fluid", name="steam", amount=334},
        {type="fluid", name="water", amount=127},
      },
      results = {
        {type="fluid", name="pressured-steam", amount=53},
      },
    },
    ["oil-molten-salt-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.886,
      ingredients = {
        {type="fluid", name="crude-oil", amount=1479},
        {type="fluid", name="water", amount=321907},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=943},
      },
    },
    ["organic-acid-anhydride"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.01,
      ingredients = {
        {type="fluid", name="fatty-acids", amount=149},
        {type="fluid", name="flue-gas", amount=1688},
        {type="fluid", name="methanal", amount=709},
        {type="item", name="pyrite", amount=7},
      },
      results = {
        {type="fluid", name="organic-acid-anhydride", amount=101},
      },
    },
    ["processed-fatty-acids"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.42,
      ingredients = {
        {type="fluid", name="fatty-acids", amount=11},
        {type="fluid", name="flue-gas", amount=1892},
      },
      results = {
        {type="fluid", name="processed-fatty-acids", amount=21},
      },
    },
    ["middle-processed-lard"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.20015876806193,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=165},
        {type="item", name="bones", amount=1},
        {type="item", name="calcium-carbide", amount=2},
        {type="item", name="guts", amount=3},
      },
      results = {
        {type="fluid", name="middle-processed-lard", amount=24},
        {type="fluid", name="steam", amount=601},
        {type="fluid", name="tar", amount=60},
      },
    },
    ["he-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.76,
      ingredients = {
        {type="fluid", name="water-saline", amount=1977},
      },
      results = {
        {type="fluid", name="molten-salt", amount=76},
        {type="fluid", name="pressured-steam", amount=57},
      },
    },
    ["pure-trichlorosilane"] = {
      mode = "repaired-to-input",
      science_level = 5,
      energy_required_multiplier = 1.04825089870657,
      ingredients = {
        {type="fluid", name="trichlorosilane", amount=50},
      },
      results = {
        {type="fluid", name="pure-trichlorosilane", amount=50},
        {type="item", name="copper-ore", amount=1},
        {type="item", name="iron-ore", amount=1},
        {type="item", name="ore-aluminium", amount=1},
      },
    },
    ["skin-fatty-acids"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="item", name="bones", amount=5},
        {type="item", name="brain", amount=25},
        {type="item", name="fish", amount=2},
        {type="item", name="meat", amount=3},
        {type="item", name="pipe", amount=13},
        {type="item", name="pyrite", amount=10},
        {type="item", name="red-refined-concrete", amount=97},
        {type="item", name="sodium-hydroxide", amount=16},
        {type="item", name="yaedols", amount=1},
      },
      results = {
        {type="fluid", name="fatty-acids", amount=80},
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
      energy_required_multiplier = 0.95,
      ingredients = {
        {type="fluid", name="propene", amount=29},
        {type="item", name="coal", amount=5},
        {type="item", name="phosphate-rock", amount=1},
        {type="item", name="sulfur", amount=8},
      },
      results = {
        {type="fluid", name="carbon-sulfide", amount=57},
      },
    },
    ["ech"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.766666666666667,
      ingredients = {
        {type="fluid", name="flue-gas", amount=2515},
        {type="fluid", name="tailings", amount=439},
      },
      results = {
        {type="fluid", name="ech", amount=23},
      },
    },
    ["etching"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.66,
      ingredients = {
        {type="fluid", name="ethylene", amount=562},
        {type="fluid", name="hydrogen-peroxide", amount=38},
        {type="fluid", name="scrude", amount=445},
        {type="item", name="bones", amount=4},
        {type="item", name="sap-tree", amount=6},
        {type="item", name="saps", amount=1},
      },
      results = {
        {type="fluid", name="etching", amount=249},
      },
    },
    ["ethylene"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.866582383214473,
      ingredients = {
        {type="fluid", name="flue-gas", amount=353},
        {type="fluid", name="pressured-air", amount=99},
        {type="item", name="iron-oxide", amount=2},
      },
      results = {
        {type="fluid", name="ethylene", amount=52},
        {type="fluid", name="water", amount=43},
      },
    },
    ["guts-to-acetic-acid"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.916666666666667,
      ingredients = {
        {type="item", name="fertilizer", amount=8},
        {type="item", name="guts", amount=16},
      },
      results = {
        {type="fluid", name="acetic-acid", amount=55},
      },
    },
    ["meat-to-cyanic"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.3,
      ingredients = {
        {type="item", name="meat", amount=3},
      },
      results = {
        {type="fluid", name="cyanic-acid", amount=15},
      },
    },
    ["methane-methanal"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.41,
      ingredients = {
        {type="fluid", name="methane", amount=23},
        {type="fluid", name="steam", amount=661},
        {type="item", name="molybdenite-dust", amount=2},
      },
      results = {
        {type="fluid", name="methanal", amount=141},
      },
    },
    ["nitrobenzene"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.02,
      ingredients = {
        {type="fluid", name="ammonia", amount=29},
        {type="fluid", name="benzene", amount=46},
        {type="fluid", name="propene", amount=20},
        {type="fluid", name="sulfuric-acid", amount=42},
        {type="item", name="coal", amount=3},
        {type="item", name="sulfur", amount=16},
      },
      results = {
        {type="fluid", name="nitrobenzene", amount=102},
      },
    },
    ["propene-to-acetone"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.98,
      ingredients = {
        {type="fluid", name="btx", amount=6},
        {type="fluid", name="propene", amount=49},
        {type="item", name="copper-plate", amount=2},
        {type="item", name="gravel", amount=3},
      },
      results = {
        {type="fluid", name="acetone", amount=49},
      },
    },
    ["ethylene-from-fruit"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.62,
      ingredients = {
        {type="item", name="yotoi", amount=1},
        {type="item", name="yotoi-fruit", amount=4},
      },
      results = {
        {type="fluid", name="ethylene", amount=31},
      },
    },
    ["fuelrod-mk01-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="molybdenum-sulfide", amount=41},
        {type="item", name="phenol", amount=5},
        {type="item", name="plutonium-oxide", amount=1},
      },
      results = {
        {type="item", name="fuelrod-mk01", amount=1},
      },
    },
    ["grade-1-u"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.989322390331823,
      ingredients = {
        {type="fluid", name="water", amount=330},
        {type="item", name="uranium-ore", amount=3},
      },
      results = {
        {type="item", name="grade-1-u", amount=1},
        {type="item", name="grade-2-u", amount=0.186818674961354},
        {type="item", name="stone", amount=1},
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
      energy_required_multiplier = 0.71,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=29},
        {type="item", name="grade-2-u", amount=10},
      },
      results = {
        {type="fluid", name="u-pulp-01", amount=71},
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
      energy_required_multiplier = 0.79,
      ingredients = {
        {type="fluid", name="u-pulp-01", amount=115},
        {type="item", name="grade-2-u", amount=1},
      },
      results = {
        {type="fluid", name="u-pulp-02", amount=79},
      },
    },
    ["u-pulp-03"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.14,
      ingredients = {
        {type="fluid", name="naphtha", amount=461},
        {type="fluid", name="pressured-water", amount=1268},
        {type="fluid", name="sulfuric-acid", amount=183},
        {type="item", name="grade-2-u", amount=22},
      },
      results = {
        {type="fluid", name="u-pulp-03", amount=114},
      },
    },
    ["u-rich-pulp"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="fluid", name="u-pulp-01", amount=266},
        {type="fluid", name="u-pulp-03", amount=145},
        {type="item", name="grade-1-iron", amount=3},
      },
      results = {
        {type="item", name="yellow-cake", amount=8},
      },
    },
    ["cladded-core"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="fluid", name="ethylene-glycol", amount=176},
        {type="item", name="aramid", amount=1},
        {type="item", name="glass-core", amount=2},
        {type="item", name="ppd", amount=4},
      },
      results = {
        {type="item", name="cladded-core", amount=3},
      },
    },
    ["cladding"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="niobium-complex", amount=65},
        {type="fluid", name="nitrobenzene", amount=30},
        {type="item", name="sic", amount=2},
      },
      results = {
        {type="item", name="cladding", amount=1},
      },
    },
    ["copper-coating"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="tpa", amount=13},
        {type="fluid", name="water-saline", amount=267},
        {type="item", name="cladded-core", amount=2},
        {type="item", name="copper-low-dust", amount=3},
      },
      results = {
        {type="item", name="copper-coating", amount=4},
      },
    },
    ["filtration-media-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="boric-acid", amount=667},
        {type="item", name="cellulose", amount=3},
        {type="item", name="chromium", amount=7},
        {type="item", name="stone", amount=45},
        {type="item", name="stone-brick", amount=12},
        {type="item", name="ticl4", amount=2},
        {type="item", name="wood", amount=33},
      },
      results = {
        {type="item", name="filtration-media", amount=4},
      },
    },
    ["iron-oxide"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="fluid", name="nitrobenzene", amount=22},
        {type="item", name="pipe", amount=3},
      },
      results = {
        {type="item", name="iron-oxide", amount=5},
      },
    },
    ["kevlar"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="syngas", amount=883},
        {type="fluid", name="tpa", amount=19},
        {type="item", name="albumin", amount=2},
        {type="item", name="bisphenol-a", amount=2},
        {type="item", name="chromium", amount=2},
        {type="item", name="cladding", amount=2},
        {type="item", name="nylon-parts", amount=21},
      },
      results = {
        {type="item", name="kevlar", amount=5},
      },
    },
    ["kevlar-coating"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="cladded-core", amount=1},
        {type="item", name="copper-low-dust", amount=2},
        {type="item", name="kevlar", amount=2},
      },
      results = {
        {type="item", name="kevlar-coating", amount=2},
      },
    },
    ["lab-instrument-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="item", name="electronic-circuit", amount=1},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="equipment-chassi", amount=3},
        {type="item", name="fiberboard", amount=3},
        {type="item", name="lens", amount=4},
        {type="item", name="pipe", amount=11},
        {type="item", name="rubber", amount=17},
      },
      results = {
        {type="item", name="lab-instrument", amount=5},
      },
    },
    ["optical-fiber"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 4.66666666666667,
      ingredients = {
        {type="item", name="nbfe-coating", amount=2},
        {type="item", name="niobium-plate", amount=47},
        {type="item", name="nxsb-alloy", amount=3},
        {type="item", name="photophore", amount=3},
        {type="item", name="plastic-bar", amount=14},
        {type="item", name="sodium-bisulfate", amount=6},
      },
      results = {
        {type="item", name="optical-fiber", amount=14},
      },
    },
    ["slacked-lime"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.84,
      ingredients = {
        {type="fluid", name="water", amount=293},
        {type="item", name="calcium-carbide", amount=14},
        {type="item", name="guar", amount=1},
      },
      results = {
        {type="fluid", name="slacked-lime", amount=92},
      },
    },
    ["ppd"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="fluid", name="flue-gas", amount=868},
        {type="fluid", name="hydrogen-chloride", amount=400},
        {type="fluid", name="organic-solvent", amount=124},
        {type="fluid", name="tall-oil", amount=1095},
        {type="item", name="nexelit-plate", amount=8},
        {type="item", name="salt", amount=264},
      },
      results = {
        {type="item", name="ppd", amount=14},
      },
    },
    ["lime-from-shell"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="fertilizer", amount=6},
        {type="item", name="xyhiphoe", amount=1},
      },
      results = {
        {type="item", name="lime", amount=20},
      },
    },
    ["nbfe-coating"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="copper-coating", amount=3},
        {type="item", name="nbfe-alloy", amount=3},
      },
      results = {
        {type="item", name="nbfe-coating", amount=2},
      },
    },
    ["py-sodium-hydroxide"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="fluid", name="slacked-lime", amount=4},
        {type="item", name="salt", amount=10},
      },
      results = {
        {type="item", name="limestone", amount=2},
        {type="item", name="sodium-hydroxide", amount=4},
      },
    },
    ["sodium-bisulfate"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.990065660797477,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=96},
        {type="item", name="coke", amount=3},
        {type="item", name="salt", amount=5},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=28},
        {type="item", name="sodium-bisulfate", amount=1},
      },
    },
    ["starch-4"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.29947404769634,
      ingredients = {
        {type="item", name="crude-cermet", amount=4},
        {type="item", name="fiberboard", amount=1},
        {type="item", name="guar", amount=38},
        {type="item", name="sodium-bisulfate", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=6},
        {type="item", name="starch", amount=13},
      },
    },
    ["aramid"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.375,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=77},
        {type="fluid", name="tpa", amount=38},
        {type="item", name="geothermal-water-barrel", amount=1},
        {type="item", name="p2s5", amount=2},
        {type="item", name="salt", amount=23},
        {type="item", name="titanium-plate", amount=6},
      },
      results = {
        {type="item", name="aramid", amount=3},
      },
    },
    ["sodium-sulfate"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.98340054790816,
      ingredients = {
        {type="item", name="ore-nickel", amount=2},
        {type="item", name="sodium-bisulfate", amount=1},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=37},
        {type="item", name="sodium-sulfate", amount=1},
      },
    },
    ["starch-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.69947404769634,
      ingredients = {
        {type="item", name="coke", amount=12},
        {type="item", name="fiberboard", amount=1},
        {type="item", name="gravel", amount=5},
        {type="item", name="powdered-ralesia-seeds", amount=1},
        {type="item", name="sodium-bisulfate", amount=2},
      },
      results = {
        {type="item", name="biomass", amount=8},
        {type="item", name="starch", amount=17},
      },
    },
    ["casein-melamine"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="fluid", name="coal-gas", amount=244},
        {type="item", name="casein", amount=2},
      },
      results = {
        {type="item", name="melamine", amount=5},
      },
    },
    ["fecr-alloy"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="flue-gas", amount=450},
        {type="fluid", name="pressured-air", amount=321},
        {type="item", name="chromium", amount=1},
        {type="item", name="coke", amount=5},
        {type="item", name="iron-oxide", amount=2},
        {type="item", name="pipe", amount=3},
      },
      results = {
        {type="item", name="fecr-alloy", amount=3},
      },
    },
    ["phenol-3"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="fluid", name="water", amount=2446},
        {type="item", name="fine-powdered-biomass", amount=547},
      },
      results = {
        {type="item", name="phenol", amount=3},
      },
    },
    ["silicon"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.9,
      ingredients = {
        {type="item", name="chromium", amount=2},
        {type="item", name="coal-dust", amount=19},
        {type="item", name="coke", amount=14},
      },
      results = {
        {type="item", name="silicon", amount=9},
      },
    },
    ["sodium-silicate"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="refsyngas", amount=423},
        {type="item", name="coke", amount=38},
        {type="item", name="sodium-sulfate", amount=1},
      },
      results = {
        {type="item", name="sodium-silicate", amount=2},
      },
    },
    ["bisphenol-a"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="acetone", amount=22},
        {type="fluid", name="oxygen", amount=332},
        {type="item", name="crude-cermet", amount=15},
      },
      results = {
        {type="item", name="bisphenol-a", amount=3},
      },
    },
    ["melamine-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.9,
      ingredients = {
        {type="item", name="bisphenol-a", amount=2},
      },
      results = {
        {type="item", name="melamine", amount=18},
      },
    },
    ["phenol-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cellulose", amount=3},
      },
      results = {
        {type="item", name="phenol", amount=5},
      },
    },
    ["silica-powder"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="item", name="phenol", amount=6},
      },
      results = {
        {type="item", name="silica-powder", amount=4},
      },
    },
    ["bakelite"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.6,
      ingredients = {
        {type="item", name="capacitor1", amount=1},
        {type="item", name="cellulose", amount=7},
        {type="item", name="powdered-biomass", amount=14},
        {type="item", name="zinc-chloride", amount=2},
      },
      results = {
        {type="item", name="bakelite", amount=3},
      },
    },
    ["epoxy"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="ech", amount=29},
        {type="item", name="bakelite", amount=10},
        {type="item", name="chromium", amount=2},
        {type="item", name="phenol", amount=3},
      },
      results = {
        {type="item", name="epoxy", amount=6},
      },
    },
    ["nylon2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ammonia", amount=202},
        {type="fluid", name="nitrogen", amount=319},
        {type="item", name="chromium", amount=14},
        {type="item", name="seaweed", amount=9},
      },
      results = {
        {type="item", name="nylon", amount=6},
      },
    },
    ["blood-meal"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="fish-oil", amount=23},
        {type="item", name="fiberboard", amount=4},
      },
      results = {
        {type="item", name="blood-meal", amount=1},
      },
    },
    ["nylon-parts"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.6,
      ingredients = {
        {type="item", name="cermet", amount=1},
      },
      results = {
        {type="item", name="nylon-parts", amount=3},
      },
    },
    ["nylon"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="fluid", name="water", amount=1165},
        {type="item", name="albumin", amount=6},
        {type="item", name="bisphenol-a", amount=1},
      },
      results = {
        {type="item", name="nylon", amount=7},
      },
    },
    ["boric-acid-hcl"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.762055783182122,
      ingredients = {
        {type="fluid", name="boric-acid", amount=230},
        {type="item", name="sodium-hydroxide", amount=3},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=57},
        {type="fluid", name="tailings", amount=153},
      },
    },
    ["manure-to-nitrogen"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2.02,
      ingredients = {
        {type="item", name="albumin", amount=1},
        {type="item", name="manure", amount=10},
        {type="item", name="wood", amount=7},
        {type="item", name="yaedols", amount=1},
      },
      results = {
        {type="fluid", name="nitrogen", amount=101},
      },
    },
    ["mibc"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.03,
      ingredients = {
        {type="fluid", name="pitch", amount=405},
        {type="fluid", name="pressured-air", amount=1899},
        {type="fluid", name="propene", amount=29},
        {type="item", name="coke", amount=2},
        {type="item", name="copper-ore", amount=7},
        {type="item", name="copper-plate", amount=3},
        {type="item", name="gravel", amount=2},
      },
      results = {
        {type="fluid", name="mibc", amount=206},
      },
    },
    ["trichlorosilane"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.72,
      ingredients = {
        {type="fluid", name="water-saline", amount=272},
        {type="item", name="silicon", amount=2},
      },
      results = {
        {type="fluid", name="hydrogen", amount=72},
        {type="fluid", name="trichlorosilane", amount=36},
      },
    },
    ["eg-si"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.953820823503783,
      ingredients = {
        {type="fluid", name="pure-trichlorosilane", amount=47},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=90},
        {type="item", name="eg-si", amount=2},
      },
    },
    ["grade-4-ti"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="formica", amount=3},
        {type="item", name="grade-1-ti", amount=6},
        {type="item", name="moondrop-seeds", amount=2},
      },
      results = {
        {type="item", name="grade-4-ti", amount=2},
      },
    },
    ["concentrated-ti"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.999884179251567,
      ingredients = {
        {type="item", name="high-grade-ti-powder", amount=1},
      },
      results = {
        {type="item", name="concentrated-ti", amount=1},
        {type="item", name="iron-oxide", amount=0.476396516672345},
        {type="item", name="nexelit-ore", amount=0.476396516672345},
      },
    },
    ["high-grade-ti-powder"] = {
      mode = "repaired-to-input",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="mibc", amount=1543},
      },
      results = {
        {type="item", name="high-grade-ti-powder", amount=1},
      },
    },
    ["hotair-titanium-plate-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="molten-titanium", amount=103},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="titanium-plate", amount=25},
      },
    },
    ["molten-titanium-01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.225,
      ingredients = {
        {type="fluid", name="heavy-oil", amount=81},
        {type="item", name="powdered-ti", amount=1},
        {type="item", name="yotoi", amount=5},
        {type="item", name="yotoi-fruit", amount=1},
      },
      results = {
        {type="fluid", name="molten-titanium", amount=49},
      },
    },
    ["molten-titanium-02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.7,
      ingredients = {
        {type="fluid", name="organic-acid-anhydride", amount=115},
        {type="item", name="high-grade-ti-powder", amount=1},
      },
      results = {
        {type="fluid", name="molten-titanium", amount=867},
      },
    },
    ["powdered-ti"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.964597492052042,
      ingredients = {
        {type="fluid", name="mibc", amount=94},
        {type="item", name="grade-4-ti", amount=2},
      },
      results = {
        {type="fluid", name="tailings", amount=37},
        {type="fluid", name="ti-pulp-03", amount=56},
        {type="item", name="powdered-ti", amount=2},
      },
    },
    ["titanium-plate-3"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="fluid", name="molten-titanium", amount=41},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="titanium-plate", amount=8},
      },
    },
    ["titanium-plate-4"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.85714285714286,
      ingredients = {
        {type="fluid", name="molten-glass", amount=221},
        {type="item", name="grade-3-ti", amount=56},
        {type="item", name="silver-plate", amount=7},
      },
      results = {
        {type="item", name="titanium-plate", amount=273},
      },
    },
    ["purified-ti-pulp"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="fluid", name="mibc", amount=133},
        {type="fluid", name="sulfuric-acid", amount=115},
        {type="fluid", name="ti-pulp-03", amount=97},
        {type="item", name="grade-4-ti", amount=3},
        {type="item", name="p2s5", amount=1},
      },
      results = {
        {type="fluid", name="purified-ti-pulp", amount=80},
        {type="fluid", name="ti-overflow-waste", amount=40},
      },
    },
    ["ti-enriched-dust"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="grade-4-ti", amount=5},
      },
      results = {
        {type="item", name="ti-enriched-dust", amount=4},
        {type="item", name="ti-rejects", amount=2},
      },
    },
    ["molten-stainless-steel"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.04,
      ingredients = {
        {type="fluid", name="molten-steel", amount=129},
        {type="item", name="cobalt-fluoride", amount=1},
        {type="item", name="copper-rejects", amount=1},
        {type="item", name="fecr-alloy", amount=4},
        {type="item", name="nickel-plate", amount=6},
        {type="item", name="phosphate-rock", amount=5},
      },
      results = {
        {type="fluid", name="molten-stainless-steel", amount=52},
      },
    },
    ["hotair-stainless-steel"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.923076923076923,
      ingredients = {
        {type="fluid", name="hot-air", amount=83},
        {type="fluid", name="molten-stainless-steel", amount=97},
        {type="item", name="fecr-alloy", amount=1},
        {type="item", name="sand", amount=19},
        {type="item", name="sodium-bisulfate", amount=1},
      },
      results = {
        {type="item", name="stainless-steel", amount=12},
      },
    },
    ["stainless-steel"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="fluid", name="molten-stainless-steel", amount=75},
        {type="fluid", name="molten-steel", amount=138},
        {type="item", name="aramid", amount=1},
        {type="item", name="cobalt-fluoride", amount=1},
        {type="item", name="fecr-alloy", amount=10},
        {type="item", name="nickel-plate", amount=7},
        {type="item", name="niobium-pipe", amount=7},
      },
      results = {
        {type="item", name="stainless-steel", amount=14},
      },
    },
    ["guar-gum"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="item", name="fiberboard", amount=1},
        {type="item", name="guar", amount=52},
        {type="item", name="sodium-bisulfate", amount=1},
      },
      results = {
        {type="item", name="guar-gum", amount=4},
      },
    },
    ["long-handed-inserter-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="item", name="al-pulp-02-barrel", amount=2},
        {type="item", name="bitumen-canister", amount=2},
        {type="item", name="btx-barrel", amount=5},
        {type="item", name="fiber", amount=34},
        {type="item", name="grade-3-copper", amount=9},
        {type="item", name="inductor1", amount=6},
        {type="item", name="melamine", amount=40},
        {type="item", name="molten-stainless-steel-barrel", amount=3},
        {type="item", name="rail", amount=7},
        {type="item", name="tin-dust", amount=17},
        {type="item", name="transport-belt", amount=50},
      },
      results = {
        {type="item", name="long-handed-inserter", amount=21},
      },
    },
    ["small-parts-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="item", name="belt", amount=2},
        {type="item", name="coke", amount=5},
        {type="item", name="fawogae-spore-mk02", amount=1},
        {type="item", name="nylon-parts", amount=3},
        {type="item", name="pipe", amount=2},
        {type="item", name="refined-hazard-concrete", amount=11},
        {type="item", name="sncr-alloy", amount=1},
        {type="item", name="stainless-steel", amount=3},
      },
      results = {
        {type="item", name="small-parts-02", amount=4},
      },
    },
    ["fast-inserter-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2.13333333333333,
      ingredients = {
        {type="item", name="blade-mk02", amount=3},
        {type="item", name="long-handed-inserter", amount=12},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="nexelit-plate", amount=615},
        {type="item", name="niobium-plate", amount=123},
        {type="item", name="shaft-mk01", amount=9},
        {type="item", name="ticl4", amount=28},
      },
      results = {
        {type="item", name="fast-inserter", amount=32},
      },
    },
    ["fast-transport-belt-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="item", name="copper-rejects", amount=67},
        {type="item", name="duralumin", amount=34},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="kerogen", amount=221},
        {type="item", name="mixed-ores", amount=39},
        {type="item", name="organic-solvent-barrel", amount=10},
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="fast-transport-belt", amount=21},
      },
    },
    ["rotor"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=7},
        {type="item", name="engine-unit", amount=2},
      },
      results = {
        {type="item", name="rotor", amount=4},
      },
    },
    ["stator"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=9},
        {type="item", name="melamine", amount=7},
        {type="item", name="nexelit-plate", amount=60},
      },
      results = {
        {type="item", name="stator", amount=1},
      },
    },
    ["electric-engine-unit"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="electronic-circuit", amount=8},
        {type="item", name="engine-unit", amount=4},
        {type="item", name="glass", amount=15},
        {type="item", name="iron-stick", amount=56},
        {type="item", name="rotor", amount=2},
        {type="item", name="stator", amount=3},
      },
      results = {
        {type="item", name="electric-engine-unit", amount=6},
      },
    },
    ["nexelit-power-pole"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="fawogae-spore-mk02", amount=1},
        {type="item", name="refined-hazard-concrete", amount=9},
        {type="item", name="stainless-steel", amount=2},
      },
      results = {
        {type="item", name="nexelit-power-pole", amount=2},
      },
    },
    ["anemometer-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-rejects", amount=6},
        {type="item", name="engine-unit", amount=4},
        {type="item", name="iron-plate", amount=14},
        {type="item", name="lab", amount=1},
        {type="item", name="organic-solvent-barrel", amount=1},
        {type="item", name="phenol", amount=151},
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
        {type="item", name="micro-fiber", amount=29},
        {type="item", name="nxsb-alloy", amount=1},
        {type="item", name="pipe", amount=14},
        {type="item", name="salt", amount=183},
        {type="item", name="small-parts-01", amount=36},
        {type="item", name="sulfur", amount=25},
      },
      results = {
        {type="item", name="blade-mk02", amount=1},
      },
    },
    ["brake-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bisphenol-a", amount=9},
        {type="item", name="duralumin", amount=10},
        {type="item", name="eg-si", amount=9},
        {type="item", name="gearbox-mk01", amount=1},
        {type="item", name="kerogen", amount=65},
        {type="item", name="melamine-resin", amount=16},
        {type="item", name="niobium-oxide", amount=5},
        {type="item", name="pipe", amount=10},
        {type="item", name="sodium-bisulfate", amount=30},
        {type="item", name="stainless-steel", amount=9},
        {type="item", name="wood", amount=344},
      },
      results = {
        {type="item", name="brake-mk02", amount=1},
      },
    },
    ["controler-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="bisphenol-a", amount=56},
        {type="item", name="blade-mk02", amount=2},
        {type="item", name="chromium", amount=335},
        {type="item", name="electronics-mk02", amount=2},
        {type="item", name="engine-unit", amount=11},
        {type="item", name="seaweed", amount=441},
        {type="item", name="used-nexelit-battery", amount=19},
      },
      results = {
        {type="item", name="controler-mk02", amount=3},
      },
    },
    ["electronics-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="item", name="bakelite", amount=19},
        {type="item", name="cobalt-fluoride", amount=4},
        {type="item", name="epoxy", amount=55},
        {type="item", name="gate", amount=1},
        {type="item", name="heavy-n", amount=12},
        {type="item", name="inductor2", amount=11},
        {type="item", name="melamine", amount=352},
        {type="item", name="microchip", amount=2},
        {type="item", name="mosfet", amount=9},
        {type="item", name="nxsb-alloy", amount=7},
        {type="item", name="optical-fiber", amount=2},
        {type="item", name="pcb2", amount=2},
        {type="item", name="phenolicboard", amount=2},
        {type="item", name="resistor1", amount=184},
        {type="item", name="resistor2", amount=7},
        {type="item", name="resorcinol", amount=6},
        {type="item", name="transistor", amount=22},
        {type="item", name="zinc-acetate", amount=5},
      },
      results = {
        {type="item", name="electronics-mk02", amount=4},
      },
    },
    ["gearbox-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="water", amount=28482},
        {type="item", name="bisphenol-a", amount=24},
        {type="item", name="copper-rejects", amount=28},
        {type="item", name="engine-unit", amount=34},
        {type="item", name="gearbox-mk01", amount=3},
        {type="item", name="melamine-resin", amount=16},
        {type="item", name="mixed-ores", amount=16},
        {type="item", name="organic-solvent-barrel", amount=4},
        {type="item", name="sb-oxide", amount=14},
        {type="item", name="shaft-mk01", amount=2},
        {type="item", name="shaft-mk02", amount=5},
        {type="item", name="sodium-bisulfate", amount=78},
        {type="item", name="wood", amount=347},
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
        {type="fluid", name="molten-stainless-steel", amount=23},
        {type="item", name="anemometer-mk01", amount=2},
      },
      results = {
        {type="item", name="shaft-mk02", amount=1},
      },
    },
    ["hotair-vane-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="kevlar", amount=18},
        {type="item", name="molybdenum-sulfide", amount=4},
        {type="item", name="ree-concentrate", amount=3},
      },
      results = {
        {type="item", name="vane-mk02", amount=2},
      },
    },
    ["shaft-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="molten-steel", amount=205},
        {type="item", name="aluminium-plate", amount=76},
        {type="item", name="anemometer-mk01", amount=1},
        {type="item", name="lead-plate", amount=6},
        {type="item", name="niobium-plate", amount=3},
      },
      results = {
        {type="item", name="shaft-mk02", amount=1},
      },
    },
    ["utility-box-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="advanced-circuit", amount=9},
        {type="item", name="bisphenol-a", amount=48},
        {type="item", name="electronic-circuit", amount=12},
        {type="item", name="electronics-mk02", amount=1},
        {type="item", name="engine-unit", amount=5},
        {type="item", name="pcb2", amount=4},
        {type="item", name="pressured-hydrogen-barrel", amount=13},
        {type="item", name="sb-crushed", amount=19},
        {type="item", name="shaft-mk02", amount=3},
        {type="item", name="utility-box-mk01", amount=2},
      },
      results = {
        {type="item", name="utility-box-mk02", amount=4},
      },
    },
    ["vane-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="gunpowder", amount=715},
      },
      results = {
        {type="item", name="vane-mk02", amount=1},
      },
    },
    ["nacelle-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="blade-mk02", amount=11},
        {type="item", name="brake-mk01", amount=8},
        {type="item", name="engine-unit", amount=4},
        {type="item", name="gold-plate", amount=4},
        {type="item", name="intermetallics", amount=6},
        {type="item", name="mechanical-parts-01", amount=6},
        {type="item", name="nacelle-mk01", amount=1},
        {type="item", name="nickel-plate", amount=4181},
        {type="item", name="shaft-mk01", amount=20},
        {type="item", name="utility-box-mk01", amount=1},
        {type="item", name="xyhiphoe-cub-mk02", amount=1},
        {type="item", name="zipir-eggs", amount=18},
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
        {type="item", name="belt", amount=28},
        {type="item", name="controler-mk01", amount=5},
        {type="item", name="iron-plate", amount=43},
        {type="item", name="resorcinol", amount=82},
        {type="item", name="shaft-mk02", amount=2},
      },
      results = {
        {type="item", name="rotor-mk02", amount=1},
      },
    },
    ["tower-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="blade-mk01", amount=6},
        {type="item", name="eg-si", amount=58},
        {type="item", name="niobium-oxide", amount=282},
        {type="item", name="pipe", amount=469},
        {type="item", name="shaft-mk02", amount=4},
        {type="item", name="steel-plate", amount=35},
      },
      results = {
        {type="item", name="tower-mk02", amount=1},
      },
    },
    ["yaw-drive-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="belt", amount=31},
        {type="item", name="blade-mk01", amount=2},
        {type="item", name="duralumin", amount=58},
        {type="item", name="electronic-circuit", amount=13},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="gearbox-mk01", amount=1},
        {type="item", name="glass", amount=466},
        {type="item", name="hydrogen-peroxide-barrel", amount=4},
        {type="item", name="nexelit-plate", amount=200},
        {type="item", name="niobium-dust", amount=411},
        {type="item", name="niobium-oxide", amount=110},
        {type="item", name="pipe", amount=579},
        {type="item", name="sb-oxide", amount=3},
        {type="item", name="shaft-mk02", amount=2},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="steel-plate", amount=110},
      },
      results = {
        {type="item", name="yaw-drive-mk02", amount=1},
      },
    },
    ["efficiency-module"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="carbon-filter", amount=6},
        {type="item", name="electronics-mk02", amount=2},
        {type="item", name="navens-spore", amount=1102},
        {type="item", name="py-science-pack-1", amount=5},
        {type="item", name="syngas-barrel", amount=88},
        {type="item", name="tower-mk01", amount=1},
      },
      results = {
        {type="item", name="efficiency-module", amount=1},
      },
    },
    ["productivity-module"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anemometer-mk02", amount=3},
        {type="item", name="brake-mk02", amount=3},
        {type="item", name="carbon-filter", amount=5},
        {type="item", name="navens-spore", amount=296},
        {type="item", name="py-science-pack-2", amount=2},
        {type="item", name="ulric", amount=135},
      },
      results = {
        {type="item", name="productivity-module", amount=1},
      },
    },
    ["speed-module"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="gearbox-mk02", amount=1},
        {type="item", name="syngas-barrel", amount=1193},
        {type="item", name="tower-mk01", amount=12},
      },
      results = {
        {type="item", name="speed-module", amount=1},
      },
    },
    ["bhoddos-codex"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="electronic-circuit", amount=19},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="tinned-cable", amount=21},
      },
      results = {
        {type="item", name="bhoddos-codex", amount=1},
      },
    },
    ["cadaveric-arum-codex"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=214},
        {type="item", name="electronic-circuit", amount=43},
        {type="item", name="pipe", amount=45},
      },
      results = {
        {type="item", name="cadaveric-arum-codex", amount=1},
      },
    },
    ["navens-codex"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="electronics-mk02", amount=6},
        {type="item", name="intermetallics", amount=177},
        {type="item", name="iron-plate", amount=242},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="molten-titanium-barrel", amount=8},
        {type="item", name="niobium-pipe", amount=146},
        {type="item", name="small-parts-02", amount=19},
        {type="item", name="titanium-plate", amount=162},
      },
      results = {
        {type="item", name="navens-codex", amount=1},
      },
    },
    ["rennea-codex"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=83},
        {type="item", name="electronic-circuit", amount=28},
        {type="item", name="nickel-plate", amount=6},
        {type="item", name="nxsb-alloy", amount=2},
        {type="item", name="pipe", amount=55},
      },
      results = {
        {type="item", name="rennea-codex", amount=1},
      },
    },
    ["grod-codex"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=17},
        {type="item", name="electronic-circuit", amount=22},
        {type="item", name="inductor1", amount=192},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="tinned-cable", amount=22},
        {type="item", name="transport-belt", amount=10},
      },
      results = {
        {type="item", name="grod-codex", amount=1},
      },
    },
    ["yotoi-codex"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="inductor1", amount=327},
        {type="item", name="nexelit-plate", amount=12},
        {type="item", name="pipe", amount=26},
        {type="item", name="seaweed", amount=151},
      },
      results = {
        {type="item", name="yotoi-codex", amount=1},
      },
    },
    ["earth-jute-sample"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bio-sample", amount=32},
        {type="item", name="guts", amount=724},
        {type="item", name="nichrome", amount=11},
        {type="item", name="py-science-pack-1", amount=65},
        {type="item", name="py-science-pack-2", amount=2},
        {type="item", name="rennea-codex", amount=1},
      },
      results = {
        {type="item", name="earth-jute-sample", amount=2},
      },
    },
    ["earth-sunflower-sample"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="alien-sample01", amount=25},
        {type="item", name="bio-sample", amount=35},
        {type="item", name="kicalk-codex", amount=1},
        {type="item", name="py-science-pack-1", amount=176},
        {type="item", name="py-science-pack-2", amount=20},
        {type="item", name="ralesia-codex", amount=1},
      },
      results = {
        {type="item", name="earth-sunflower-sample", amount=2},
      },
    },
    ["earth-tropical-tree-sample"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bio-sample", amount=26},
        {type="item", name="py-science-pack-2", amount=20},
        {type="item", name="ralesia-codex", amount=1},
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
        {type="item", name="alien-sample-02", amount=5},
        {type="item", name="alien-sample01", amount=17},
        {type="item", name="cottongut-codex", amount=5},
        {type="item", name="cytostatics", amount=11},
        {type="item", name="earth-jute-sample", amount=2},
        {type="item", name="earth-palmtree-sample", amount=2},
        {type="item", name="earth-sunflower-sample", amount=1},
        {type="item", name="mukmoux-codex", amount=3},
        {type="item", name="primers", amount=13},
        {type="item", name="zipir-codex", amount=4},
      },
      results = {
        {type="item", name="cadaveric-arum", amount=6},
      },
    },
    ["cadaveric-arum-seeds"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.875,
      ingredients = {
        {type="item", name="rennea", amount=2},
        {type="item", name="sulfur", amount=39},
      },
      results = {
        {type="item", name="cadaveric-arum-seeds", amount=7},
      },
    },
    ["cadaveric-arum-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=225},
        {type="fluid", name="tar", amount=124},
        {type="item", name="cadaveric-arum-seeds", amount=1},
        {type="item", name="gravel", amount=2},
        {type="item", name="stone-wool", amount=1},
        {type="item", name="sulfur", amount=105},
      },
      results = {
        {type="item", name="cadaveric-arum", amount=4},
      },
    },
    ["cadaveric-acidgas-01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.47556905906891,
      ingredients = {
        {type="item", name="rennea", amount=2},
      },
      results = {
        {type="fluid", name="acidgas", amount=141},
        {type="item", name="cadaveric-arum-seeds", amount=3},
      },
    },
    ["grod-sample"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="earth-potato-sample", amount=3},
        {type="item", name="korlex-codex", amount=27},
        {type="item", name="retrovirus", amount=8},
      },
      results = {
        {type="item", name="grod", amount=4},
      },
    },
    ["dried-grods"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grod", amount=8},
      },
      results = {
        {type="item", name="dried-grods", amount=5},
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
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="item", name="dried-grods", amount=3},
      },
      results = {
        {type="item", name="grod-seeds", amount=5},
      },
    },
    ["grod-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.6,
      ingredients = {
        {type="fluid", name="water", amount=229},
        {type="item", name="chromium", amount=1},
        {type="item", name="coarse", amount=2},
        {type="item", name="grod-seeds", amount=4},
        {type="item", name="urea", amount=4},
      },
      results = {
        {type="item", name="grod", amount=6},
      },
    },
    ["rennea-sample"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="alien-sample-02", amount=9},
        {type="item", name="arqad-codex", amount=3},
        {type="item", name="cytostatics", amount=10},
        {type="item", name="earth-potato-sample", amount=1},
        {type="item", name="earth-sunflower-sample", amount=2},
        {type="item", name="grod-codex", amount=1},
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
        {type="item", name="yaedols", amount=7},
      },
      results = {
        {type="item", name="rennea-seeds", amount=5},
      },
    },
    ["rennea-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="fluid", name="manure-bacteria", amount=48},
        {type="item", name="fertilizer", amount=2},
        {type="item", name="guar", amount=1},
        {type="item", name="lime", amount=2},
        {type="item", name="rennea-seeds", amount=3},
        {type="item", name="sand-casting", amount=4},
      },
      results = {
        {type="item", name="rennea", amount=3},
      },
    },
    ["bhoddos-to-ti"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bhoddos", amount=2},
      },
      results = {
        {type="item", name="ore-titanium", amount=10},
      },
    },
    ["blood-to-zinc"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.9,
      ingredients = {
        {type="fluid", name="blood", amount=91},
      },
      results = {
        {type="item", name="ore-zinc", amount=18},
      },
    },
    ["fish-oil-to-tin"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="fluid", name="coal-gas", amount=148},
      },
      results = {
        {type="item", name="ore-tin", amount=4},
      },
    },
    ["fish-to-tin"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.32,
      ingredients = {
        {type="item", name="fish", amount=3},
      },
      results = {
        {type="item", name="ore-tin", amount=8},
      },
    },
    ["grod-to-zinc"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.8,
      ingredients = {
        {type="item", name="dried-grods", amount=6},
        {type="item", name="geothermal-water-barrel", amount=1},
        {type="item", name="grod", amount=4},
      },
      results = {
        {type="item", name="ore-zinc", amount=9},
      },
    },
    ["meat-to-chromium"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2.2,
      ingredients = {
        {type="fluid", name="blood", amount=60},
        {type="item", name="brain", amount=1},
      },
      results = {
        {type="item", name="ore-chromium", amount=33},
      },
    },
    ["navens-to-tin"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="navens", amount=1},
      },
      results = {
        {type="item", name="ore-tin", amount=17},
      },
    },
    ["yotoi-leaves-to-chromium"] = {
      mode = "repaired-to-input",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="yotoi", amount=2},
      },
      results = {
        {type="item", name="ore-chromium", amount=17},
      },
    },
    ["yotoi-seed-to-chromium"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.36,
      ingredients = {
        {type="item", name="yotoi-fruit", amount=1},
      },
      results = {
        {type="item", name="ore-chromium", amount=9},
      },
    },
    ["cadaveric-pb"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.989471722899947,
      ingredients = {
        {type="fluid", name="tar", amount=189},
        {type="item", name="cadaveric-arum-seeds", amount=2},
      },
      results = {
        {type="fluid", name="waste-water", amount=48},
        {type="item", name="s-biomass", amount=10},
      },
    },
    ["cool-pressured-steam-3000-to-2000"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.42,
      ingredients = {
        {type="fluid", name="pressured-steam", amount=200},
        {type="fluid", name="water", amount=81},
      },
      results = {
        {type="fluid", name="pressured-steam", amount=242},
      },
    },
    ["rennea-cu"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.09746346420391,
      ingredients = {
        {type="fluid", name="tar", amount=195},
        {type="item", name="rennea-seeds", amount=6},
      },
      results = {
        {type="fluid", name="waste-water", amount=54},
        {type="item", name="cu-biomass", amount=11},
      },
    },
    ["tuuphra-nacl"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.586846799618282,
      ingredients = {
        {type="item", name="tuuphra", amount=1},
      },
      results = {
        {type="fluid", name="waste-water", amount=28},
        {type="item", name="nacl-biomass", amount=6},
      },
    },
    ["grod-sn"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 3.38512906978173,
      ingredients = {
        {type="fluid", name="tar", amount=299},
        {type="item", name="grod-seeds", amount=5},
        {type="item", name="tuuphra", amount=2},
      },
      results = {
        {type="fluid", name="waste-water", amount=168},
        {type="item", name="sn-biomass", amount=34},
      },
    },
    ["navens-fe"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.264484295136738,
      ingredients = {
        {type="fluid", name="tar", amount=182},
        {type="item", name="salt", amount=2},
      },
      results = {
        {type="fluid", name="waste-water", amount=14},
        {type="item", name="fe-biomass", amount=2},
      },
    },
    ["yotoi-fe"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.38670441088696,
      ingredients = {
        {type="fluid", name="btx", amount=14},
        {type="fluid", name="tar", amount=340},
        {type="item", name="yotoi", amount=1},
      },
      results = {
        {type="fluid", name="waste-water", amount=68},
        {type="item", name="fe-biomass", amount=21},
      },
    },
    ["moondrop-3"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.5625,
      ingredients = {
        {type="item", name="coarse", amount=1},
        {type="item", name="fertilizer", amount=5},
        {type="item", name="log", amount=2},
        {type="item", name="moondrop-seeds", amount=6},
      },
      results = {
        {type="item", name="moondrop", amount=9},
      },
    },
    ["moonshine-fueloil-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 3.53333333333333,
      ingredients = {
        {type="item", name="cu-biomass", amount=2},
        {type="item", name="moondrop", amount=5},
        {type="item", name="moondrop-mk02", amount=3},
      },
      results = {
        {type="item", name="moondrop-fueloil", amount=53},
      },
    },
    ["ethylene-chlorohydrin"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.66,
      ingredients = {
        {type="fluid", name="molten-glass", amount=145},
        {type="item", name="gold-plate", amount=3},
        {type="item", name="silver-plate", amount=2},
      },
      results = {
        {type="fluid", name="ethylene-chlorohydrin", amount=166},
      },
    },
    ["moonshine-fueloil-pressing-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.78629418682615,
      ingredients = {
        {type="item", name="moondrop-mk02", amount=1},
      },
      results = {
        {type="fluid", name="fuel-oil", amount=713},
        {type="item", name="ash", amount=18},
      },
    },
    ["chloroethanol"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.67,
      ingredients = {
        {type="fluid", name="ethylene-chlorohydrin", amount=42},
        {type="fluid", name="muddy-sludge", amount=6896},
      },
      results = {
        {type="fluid", name="chloroethanol", amount=67},
      },
    },
    ["ethylene-glycol"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.746666666666667,
      ingredients = {
        {type="fluid", name="residual-mixture", amount=2201},
      },
      results = {
        {type="fluid", name="ethylene-glycol", amount=112},
      },
    },
    ["ferrite"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.75,
      ingredients = {
        {type="item", name="aluminium-plate", amount=13},
        {type="item", name="chromium", amount=43},
        {type="item", name="melamine", amount=9},
        {type="item", name="nexelit-plate", amount=80},
        {type="item", name="pyrite", amount=8},
        {type="item", name="zinc-plate", amount=8},
      },
      results = {
        {type="item", name="ferrite", amount=7},
      },
    },
    ["lead-container"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="niobium-plate", amount=23},
        {type="item", name="nxsb-alloy", amount=1},
        {type="item", name="sodium-bisulfate", amount=8},
      },
      results = {
        {type="item", name="lead-container", amount=1},
      },
    },
    ["nexelit-matrix"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.25,
      ingredients = {
        {type="fluid", name="anthraquinone", amount=3},
        {type="fluid", name="muddy-sludge", amount=550},
        {type="fluid", name="water", amount=391},
        {type="item", name="lead-plate", amount=8},
      },
      results = {
        {type="item", name="nexelit-matrix", amount=1},
      },
    },
    ["nuclear-sample"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="industrial-solvent", amount=72},
        {type="item", name="cermet", amount=5},
        {type="item", name="nylon-parts", amount=17},
        {type="item", name="pu-241", amount=2},
        {type="item", name="ree-concentrate", amount=14},
      },
      results = {
        {type="item", name="nuclear-sample", amount=1},
      },
    },
    ["sodium-chlorate"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="fluid", name="boric-acid", amount=117},
        {type="fluid", name="steam", amount=74},
        {type="item", name="seaweed", amount=6},
        {type="item", name="sodium-hydroxide", amount=2},
      },
      results = {
        {type="item", name="sodium-chlorate", amount=8},
      },
    },
    ["steam-heating"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=1000},
        {type="item", name="sodium-bisulfate", amount=20},
      },
      results = {
        {type="fluid", name="steam", amount=1000},
      },
    },
    ["tuuphra-to-mo"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="item", name="tuuphra-mk02", amount=1},
      },
      results = {
        {type="item", name="molybdenum-ore", amount=8},
      },
    },
    ["plutonium-fuel-cell"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="cliff-explosives", amount=1},
        {type="item", name="ore-nickel", amount=72},
        {type="item", name="petri-dish", amount=169},
        {type="item", name="powdered-aluminium", amount=20},
        {type="item", name="vinyl-acetate-barrel", amount=2},
      },
      results = {
        {type="item", name="mox-fuel-cell", amount=3},
      },
    },
    ["crmoni"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water-saline", amount=194},
        {type="item", name="chromium", amount=3},
        {type="item", name="molybdenum-sulfide", amount=17},
        {type="item", name="nickel-plate", amount=8},
        {type="item", name="titanium-plate", amount=8},
      },
      results = {
        {type="item", name="crmoni", amount=2},
      },
    },
    ["nbalti"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="niobium-complex", amount=32},
        {type="fluid", name="nitrobenzene", amount=38},
        {type="item", name="aluminium-plate", amount=2},
        {type="item", name="niobium-oxide", amount=2},
        {type="item", name="sic", amount=1},
        {type="item", name="titanium-plate", amount=5},
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
        {type="fluid", name="mibc", amount=191},
        {type="fluid", name="organic-acid-anhydride", amount=53},
        {type="fluid", name="perylene", amount=122},
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
        {type="item", name="lead-acetate", amount=5},
        {type="item", name="nbalti", amount=1},
        {type="item", name="ptcda", amount=1},
        {type="item", name="rayon", amount=3},
        {type="item", name="sb-crushed", amount=14},
        {type="item", name="vitreloy", amount=5},
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
        {type="fluid", name="oxygen", amount=7914},
        {type="item", name="brain", amount=15},
        {type="item", name="dried-meat", amount=3},
        {type="item", name="fenxsb-alloy", amount=1},
        {type="item", name="skin", amount=11},
      },
      results = {
        {type="item", name="brain-cartridge-01", amount=1},
      },
    },
    ["vat-brain"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="distilator", amount=1},
        {type="item", name="electronic-circuit", amount=24},
        {type="item", name="ethylene-chlorohydrin-barrel", amount=2},
        {type="item", name="intermetallics", amount=22},
        {type="item", name="iron-ore-dust", amount=45},
        {type="item", name="neutron-absorber-mk01", amount=4},
        {type="item", name="nickel-plate", amount=77},
        {type="item", name="shotgun-shell", amount=494},
        {type="item", name="stripped-distillate-barrel", amount=6},
      },
      results = {
        {type="item", name="vat-brain", amount=3},
      },
    },
    ["mk02-locomotive"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="arqad-honey-barrel", amount=29},
        {type="item", name="bitumen-froth-barrel", amount=44},
        {type="item", name="black-liquor-barrel", amount=25},
        {type="item", name="casting-unit-mk01", amount=1},
        {type="item", name="chitin", amount=6},
        {type="item", name="cocoon-mk03", amount=3},
        {type="item", name="cottongut-mk01", amount=4},
        {type="item", name="eg-si", amount=260},
        {type="item", name="ethylene-barrel", amount=18},
        {type="item", name="ethylene-chlorohydrin-barrel", amount=27},
        {type="item", name="grade-2-chromite", amount=8},
        {type="item", name="grade-3-iron", amount=51},
        {type="item", name="hydrofluoric-acid-barrel", amount=6},
        {type="item", name="hydrogen-chloride-barrel", amount=20},
        {type="item", name="methanal-barrel", amount=25},
        {type="item", name="molten-solder-barrel", amount=14},
        {type="item", name="molten-steel-barrel", amount=9},
        {type="item", name="pipe", amount=107},
        {type="item", name="propene-canister", amount=32},
        {type="item", name="py-steel", amount=152},
        {type="item", name="residual-oil-barrel", amount=65},
        {type="item", name="rotor", amount=8},
        {type="item", name="sap-seeds-mk03", amount=8},
        {type="item", name="shell", amount=2},
        {type="item", name="small-parts-02", amount=11},
        {type="item", name="tower-mk02", amount=1},
        {type="item", name="u-pulp-02-barrel", amount=14},
        {type="item", name="unslimed-iron", amount=24},
        {type="item", name="zogna-bacteria-barrel", amount=4},
      },
      results = {
        {type="item", name="mk02-locomotive", amount=1},
      },
    },
    ["mk02-wagon"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 4,
      ingredients = {
        {type="fluid", name="lubricant", amount=1043},
        {type="item", name="al-pulp-02-barrel", amount=3},
        {type="item", name="ash", amount=1052},
        {type="item", name="benzene-canister", amount=76},
        {type="item", name="black-liquor-barrel", amount=4},
        {type="item", name="blade-mk02", amount=2},
        {type="item", name="chromite-rejects", amount=667},
        {type="item", name="concentrated-ti", amount=10},
        {type="item", name="cottongut-mk01", amount=2},
        {type="item", name="crmoni", amount=14},
        {type="item", name="eg-si", amount=16},
        {type="item", name="etching-barrel", amount=2},
        {type="item", name="graphite", amount=203},
        {type="item", name="kerogen", amount=202},
        {type="item", name="long-handed-inserter", amount=73},
        {type="item", name="mechanical-parts-01", amount=4},
        {type="item", name="nexelit-plate", amount=453},
        {type="item", name="niobium-plate", amount=91},
        {type="item", name="shaft-mk01", amount=21},
        {type="item", name="ticl4", amount=65},
        {type="item", name="tin-dust", amount=76},
        {type="item", name="u-pulp-02-barrel", amount=2},
        {type="item", name="used-comb", amount=39},
        {type="item", name="utility-box-mk02", amount=1},
      },
      results = {
        {type="item", name="mk02-wagon", amount=4},
      },
    },
    ["mk02-fluid-wagon"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="chitin", amount=8},
        {type="item", name="cottongut-mk01", amount=2},
        {type="item", name="ethylene-chlorohydrin-barrel", amount=11},
        {type="item", name="long-handed-inserter", amount=2},
        {type="item", name="methanal-barrel", amount=32},
        {type="item", name="molten-steel-barrel", amount=1},
        {type="item", name="py-steel", amount=62},
        {type="item", name="residual-oil-barrel", amount=83},
        {type="item", name="rotor", amount=11},
        {type="item", name="small-parts-02", amount=14},
        {type="item", name="unslimed-iron", amount=10},
        {type="item", name="zogna-bacteria-barrel", amount=2},
      },
      results = {
        {type="item", name="mk02-fluid-wagon", amount=1},
      },
    },
    ["glycerol2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.82,
      ingredients = {
        {type="item", name="brain", amount=2},
        {type="item", name="p2s5", amount=1},
      },
      results = {
        {type="fluid", name="glycerol", amount=41},
      },
    },
    ["oleochemicals-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.355,
      ingredients = {
        {type="item", name="fine-powdered-biomass", amount=1140},
        {type="item", name="sugar", amount=5},
        {type="item", name="yaedols", amount=1},
      },
      results = {
        {type="fluid", name="oleochemicals", amount=271},
      },
    },
    ["sea-sponge-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.665759438281738,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=37},
        {type="fluid", name="zogna-bacteria", amount=15},
        {type="item", name="sea-sponge-sprouts", amount=1},
      },
      results = {
        {type="fluid", name="water-saline", amount=31},
        {type="item", name="sea-sponge", amount=2},
      },
    },
    ["silicon-wafer"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.99903964083513,
      ingredients = {
        {type="item", name="aramid", amount=1},
        {type="item", name="coke", amount=13},
        {type="item", name="eg-si", amount=5},
        {type="item", name="ore-nickel", amount=15},
        {type="item", name="powdered-quartz", amount=2},
        {type="item", name="sodium-bisulfate", amount=3},
      },
      results = {
        {type="fluid", name="flue-gas", amount=189},
        {type="item", name="silicon-wafer", amount=4},
      },
    },
    ["heat-exchanger"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="grade-2-lead", amount=2},
        {type="item", name="grade-4-ti", amount=4},
        {type="item", name="natural-gas-canister", amount=5},
      },
      results = {
        {type="item", name="heat-exchanger", amount=2},
      },
    },
    ["heat-pipe"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="acetylene-canister", amount=9},
        {type="item", name="anemometer-mk01", amount=3},
        {type="item", name="py-tank-3000", amount=3},
        {type="item", name="refined-hazard-concrete", amount=13},
      },
      results = {
        {type="item", name="heat-pipe", amount=4},
      },
    },
    ["nuclear-reactor"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="black-liquor-barrel", amount=16},
        {type="item", name="engine-unit", amount=1248},
        {type="item", name="grade-1-ti", amount=1091},
        {type="item", name="intermetallics", amount=68},
        {type="item", name="latex", amount=615},
        {type="item", name="lubricant-barrel", amount=265},
        {type="item", name="mechanical-parts-01", amount=57},
        {type="item", name="middle-processed-lard-barrel", amount=335},
        {type="item", name="py-biomass-powerplant-mk01", amount=2},
        {type="item", name="residual-mixture-barrel", amount=350},
        {type="item", name="rotor", amount=745},
        {type="item", name="small-parts-02", amount=344},
        {type="item", name="sugar", amount=114},
        {type="item", name="xyhiphoe-codex", amount=2},
      },
      results = {
        {type="item", name="nuclear-reactor", amount=1},
      },
    },
    ["steam-turbine"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="etching", amount=122},
        {type="item", name="condensates-canister", amount=5},
        {type="item", name="copper-low-dust", amount=2},
        {type="item", name="copper-rejects", amount=27},
        {type="item", name="fish-hydrolysate-barrel", amount=1},
        {type="item", name="nylon", amount=7},
        {type="item", name="shaft-mk02", amount=3},
        {type="item", name="tin-plate", amount=24},
        {type="item", name="transport-belt", amount=54},
      },
      results = {
        {type="item", name="steam-turbine", amount=2},
      },
    },
    ["zinc-acetate"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=1919},
        {type="item", name="grade-1-ti", amount=1},
        {type="item", name="zinc-plate", amount=10},
      },
      results = {
        {type="item", name="zinc-acetate", amount=1},
      },
    },
    ["heavy-n"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="fluid", name="sb-pulp-02", amount=84},
        {type="item", name="ree-concentrate", amount=17},
        {type="item", name="refined-natural-gas-canister", amount=9},
        {type="item", name="silicon-wafer", amount=4},
      },
      results = {
        {type="item", name="heavy-n", amount=5},
      },
    },
    ["light-n"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="etching", amount=35},
        {type="fluid", name="flue-gas", amount=2610},
        {type="item", name="silicon-wafer", amount=3},
      },
      results = {
        {type="item", name="light-n", amount=8},
      },
    },
    ["p-dope"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="item", name="zinc-acetate", amount=3},
      },
      results = {
        {type="item", name="p-dope", amount=4},
      },
    },
    ["ammonium-chloride"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ammonia", amount=67},
        {type="fluid", name="carbon-dioxide", amount=319},
        {type="fluid", name="nitrogen", amount=253},
        {type="item", name="seaweed", amount=21},
      },
      results = {
        {type="item", name="ammonium-chloride", amount=2},
        {type="item", name="sodium-carbonate", amount=1},
      },
    },
    ["p2s5-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="cyanic-acid", amount=3},
        {type="item", name="phosphate-rock", amount=4},
        {type="item", name="pipe", amount=2},
        {type="item", name="sulfur", amount=7},
      },
      results = {
        {type="item", name="p2s5", amount=2},
        {type="item", name="pyrite", amount=4},
      },
    },
    ["uranium-fuel-cell"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boron-trioxide", amount=135},
        {type="item", name="electronic-circuit", amount=2},
        {type="item", name="ore-nickel", amount=128},
        {type="item", name="petri-dish", amount=37},
        {type="item", name="powdered-aluminium", amount=35},
        {type="item", name="resorcinol", amount=2},
        {type="item", name="sodium-bisulfate", amount=26},
      },
      results = {
        {type="item", name="uranium-fuel-cell", amount=1},
      },
    },
    ["fuel-cell-dissolve"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="fish-hydrolysate-barrel", amount=4},
        {type="item", name="guar-gum-plantation", amount=4},
        {type="item", name="long-handed-inserter", amount=9},
        {type="item", name="yaedols-spores-mk02", amount=15},
      },
      results = {
        {type="fluid", name="sb-phosphate-1", amount=100},
      },
    },
    ["plutonium-fuel-reprocessing"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.21146322650914,
      ingredients = {
        {type="item", name="belt", amount=15},
        {type="item", name="cliff-explosives", amount=7},
        {type="item", name="controler-mk01", amount=6},
        {type="item", name="resorcinol", amount=45},
        {type="item", name="shaft-mk02", amount=3},
      },
      results = {
        {type="item", name="plutonium-oxide", amount=17},
        {type="item", name="u-238", amount=12},
      },
    },
    ["antimony-phosphate"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.075,
      ingredients = {
        {type="fluid", name="ethylene", amount=1406},
        {type="fluid", name="hot-molten-salt", amount=233},
        {type="fluid", name="manure-bacteria", amount=646},
        {type="fluid", name="propene", amount=665},
        {type="item", name="nichrome", amount=2},
        {type="item", name="nxsb-alloy", amount=1},
        {type="item", name="tuuphra", amount=8},
      },
      results = {
        {type="fluid", name="purex-concentrate-1", amount=105},
        {type="item", name="sb-hpo-pu", amount=11},
      },
    },
    ["plutonium-seperation"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2.76422289320167,
      ingredients = {
        {type="item", name="plutonium-oxide", amount=14},
      },
      results = {
        {type="item", name="pu-238", amount=1},
        {type="item", name="pu-239", amount=22},
        {type="item", name="pu-240", amount=10},
        {type="item", name="pu-241", amount=6},
        {type="item", name="pu-242", amount=21},
      },
    },
    ["plutonium-oxidation"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.49,
      ingredients = {
        {type="fluid", name="flue-gas", amount=5932},
        {type="fluid", name="hydrogen-peroxide", amount=456},
        {type="fluid", name="oxygen", amount=1362},
        {type="item", name="sb-hpo-pu", amount=2},
        {type="item", name="skin", amount=5},
      },
      results = {
        {type="fluid", name="plutonium-peroxide", amount=149},
        {type="fluid", name="sb-phosphate-2", amount=149},
      },
    },
    ["plutonium-shuffle-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 4,
      ingredients = {
        {type="fluid", name="plutonium-peroxide", amount=100},
        {type="item", name="plutonium-oxide", amount=11},
        {type="item", name="pu-241", amount=1},
      },
      results = {
        {type="item", name="pu-238", amount=4},
        {type="item", name="pu-242", amount=4},
      },
    },
    ["plutonium-shuffle-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="plutonium-peroxide", amount=73},
        {type="item", name="cellulose", amount=84},
        {type="item", name="plutonium-oxide", amount=1},
        {type="item", name="u-238", amount=3},
      },
      results = {
        {type="item", name="pu-240", amount=2},
        {type="item", name="pu-242", amount=2},
      },
    },
    ["plutonium-shuffle-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="cellulose", amount=20},
        {type="item", name="pu-240", amount=7},
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
        {type="item", name="plutonium-oxide", amount=5},
        {type="item", name="sb-hpo-pu", amount=2},
      },
      results = {
        {type="item", name="pu-239", amount=1},
        {type="item", name="pu-240", amount=1},
      },
    },
    ["rayon"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="fluid", name="ammonia", amount=38},
        {type="fluid", name="vacuum", amount=1394},
        {type="item", name="aluminium-plate", amount=10},
        {type="item", name="ammonium-chloride", amount=5},
        {type="item", name="copper-cable", amount=113},
        {type="item", name="raw-fiber", amount=32},
        {type="item", name="resistor1", amount=2},
        {type="item", name="urea", amount=10},
      },
      results = {
        {type="item", name="rayon", amount=7},
      },
    },
    ["battery-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.666666666666667,
      ingredients = {
        {type="item", name="nxsb-alloy", amount=2},
        {type="item", name="phenol", amount=12},
        {type="item", name="salt", amount=5},
      },
      results = {
        {type="item", name="battery-mk01", amount=2},
      },
    },
    ["battery-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2.25,
      ingredients = {
        {type="item", name="nxsb-alloy", amount=2},
        {type="item", name="p2s5", amount=2},
        {type="item", name="pbsb-alloy", amount=6},
        {type="item", name="phenol", amount=31},
        {type="item", name="rayon", amount=3},
      },
      results = {
        {type="item", name="battery-mk01", amount=9},
      },
    },
    ["nas-battery"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.833333333333333,
      ingredients = {
        {type="item", name="nxsb-alloy", amount=2},
        {type="item", name="rayon", amount=2},
        {type="item", name="salt", amount=101},
        {type="item", name="sulfur", amount=14},
      },
      results = {
        {type="item", name="battery-mk01", amount=5},
      },
    },
    ["nexelit-battery"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="anthraquinone", amount=23},
        {type="item", name="ferrite", amount=2},
        {type="item", name="nylon-parts", amount=24},
        {type="item", name="pipe", amount=11},
        {type="item", name="titanium-plate", amount=13},
      },
      results = {
        {type="item", name="used-nexelit-battery", amount=2},
      },
    },
    ["nexelit-battery-recharge"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="fluid", name="subcritical-water", amount=1499},
        {type="item", name="limestone", amount=11},
        {type="item", name="used-nexelit-battery", amount=2},
      },
      results = {
        {type="item", name="nexelit-battery", amount=3},
      },
    },
    ["casein-mixture-03"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.914398529294166,
      ingredients = {
        {type="fluid", name="flue-gas", amount=473},
        {type="fluid", name="milk", amount=21},
        {type="fluid", name="sulfuric-acid", amount=96},
        {type="item", name="zinc-plate", amount=2},
      },
      results = {
        {type="fluid", name="casein-mixture", amount=73},
        {type="fluid", name="waste-water", amount=46},
      },
    },
    ["fish-emulsion"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.973860844378433,
      ingredients = {
        {type="fluid", name="subcritical-water", amount=1856},
      },
      results = {
        {type="fluid", name="fish-emulsion", amount=38},
        {type="fluid", name="fish-oil", amount=14},
        {type="item", name="fishmeal", amount=10},
      },
    },
    ["b-molasse"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.21,
      ingredients = {
        {type="fluid", name="a-molasse", amount=38},
        {type="fluid", name="zogna-bacteria", amount=17},
        {type="item", name="fawogae-spore", amount=3},
        {type="item", name="stone-wool", amount=1},
      },
      results = {
        {type="fluid", name="b-molasse", amount=121},
      },
    },
    ["ethanol"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.67,
      ingredients = {
        {type="fluid", name="b-molasse", amount=38},
        {type="fluid", name="fish-oil", amount=10},
        {type="fluid", name="zogna-bacteria", amount=10},
        {type="item", name="fawogae-spore", amount=2},
      },
      results = {
        {type="fluid", name="ethanol", amount=67},
      },
    },
    ["syrup-01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="steam", amount=376},
        {type="fluid", name="xenogenic-cells", amount=114},
        {type="item", name="dried-meat", amount=3},
        {type="item", name="fine-powdered-biomass", amount=467},
        {type="item", name="manure", amount=10},
        {type="item", name="retrovirus", amount=1},
      },
      results = {
        {type="fluid", name="syrup-01", amount=75},
      },
    },
    ["fertilizer-5"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.06666666666667,
      ingredients = {
        {type="fluid", name="water", amount=1101},
        {type="item", name="bones", amount=6},
        {type="item", name="coarse", amount=1},
        {type="item", name="sodium-bisulfate", amount=1},
        {type="item", name="urea", amount=20},
      },
      results = {
        {type="item", name="fertilizer", amount=16},
      },
    },
    ["fertilizer-fish-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="fluid", name="fish-emulsion", amount=77},
        {type="fluid", name="scrude", amount=5147},
        {type="item", name="titanium-plate", amount=6},
      },
      results = {
        {type="item", name="fertilizer", amount=5},
      },
    },
    ["fertilizer-fish-3"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coke", amount=28},
        {type="item", name="cottongut-food-01", amount=10},
        {type="item", name="fawogae", amount=10},
        {type="item", name="fawogae-spore", amount=15},
      },
      results = {
        {type="item", name="fertilizer", amount=2},
      },
    },
    ["split-yellowcake"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.94444444444444,
      ingredients = {
        {type="item", name="engine-unit", amount=2},
        {type="item", name="equipment-chassi", amount=1},
        {type="item", name="lens", amount=2},
        {type="item", name="pipe", amount=12},
        {type="item", name="rubber", amount=2},
        {type="item", name="yellow-cake", amount=11},
      },
      results = {
        {type="item", name="u-235", amount=2},
        {type="item", name="u-238", amount=17},
      },
    },
    ["plutonium"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="plutonium-peroxide", amount=64},
        {type="item", name="pu-240", amount=1},
      },
      results = {
        {type="item", name="plutonium-oxide", amount=8},
      },
    },
    ["night-vision-equipment"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="btx-barrel", amount=1},
        {type="item", name="inductor1", amount=3},
        {type="item", name="melamine", amount=6},
        {type="item", name="tin-dust", amount=19},
        {type="item", name="transport-belt", amount=7},
      },
      results = {
        {type="item", name="night-vision-equipment", amount=1},
      },
    },
    ["personal-roboport-mk2-equipment"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="animal-sample-01", amount=32},
        {type="item", name="chromium", amount=740},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="iron-plate", amount=97},
        {type="item", name="moondrop-mk02", amount=10},
        {type="item", name="portable-gasoline-generator", amount=2},
        {type="item", name="seaweed", amount=381},
        {type="item", name="ulric-corral-mk01", amount=1},
      },
      results = {
        {type="item", name="personal-roboport-mk2-equipment", amount=1},
      },
    },
    ["belt-immunity-equipment"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="hot-syngas-canister", amount=41},
        {type="item", name="pressured-water-barrel", amount=42},
        {type="item", name="shotgun", amount=7},
      },
      results = {
        {type="item", name="belt-immunity-equipment", amount=1},
      },
    },
    ["bio-scafold"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bonemeal", amount=5},
        {type="item", name="chitin", amount=19},
      },
      results = {
        {type="item", name="bio-scafold", amount=1},
      },
    },
    ["bone-fat"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="pressured-water", amount=1177},
        {type="item", name="brain", amount=1},
      },
      results = {
        {type="item", name="mukmoux-fat", amount=3},
      },
    },
    ["print-bonemeal"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="psc", amount=71},
        {type="item", name="bio-scafold", amount=2},
      },
      results = {
        {type="item", name="bonemeal", amount=8},
      },
    },
    ["print-bones"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="psc", amount=57},
        {type="item", name="bio-scafold", amount=2},
      },
      results = {
        {type="item", name="bones", amount=6},
      },
    },
    ["print-brain"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="psc", amount=50},
        {type="item", name="bio-scafold", amount=1},
      },
      results = {
        {type="item", name="brain", amount=2},
      },
    },
    ["print-fat"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="fluid", name="psc", amount=44},
        {type="item", name="bio-scafold", amount=1},
        {type="item", name="chitin", amount=18},
      },
      results = {
        {type="item", name="mukmoux-fat", amount=8},
      },
    },
    ["print-guts"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="psc", amount=49},
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
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.73,
      ingredients = {
        {type="item", name="powdered-biomass", amount=180},
      },
      results = {
        {type="fluid", name="syngas", amount=73},
      },
    },
    ["lignin-to-aromatics"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="item", name="cellulose", amount=5},
      },
      results = {
        {type="fluid", name="aromatics", amount=250},
      },
    },
    ["tpa"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.84,
      ingredients = {
        {type="fluid", name="liquid-nitrogen", amount=19},
        {type="fluid", name="manure-bacteria", amount=14},
        {type="fluid", name="vacuum", amount=537},
        {type="item", name="cobalt-extract", amount=2},
        {type="item", name="silicon", amount=4},
        {type="item", name="sodium-hydroxide", amount=4},
      },
      results = {
        {type="fluid", name="tpa", amount=42},
      },
    },
    ["oleo-gasification"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.7,
      ingredients = {
        {type="fluid", name="fatty-acids", amount=3},
        {type="fluid", name="hot-air", amount=116},
        {type="fluid", name="oleochemicals", amount=143},
      },
      results = {
        {type="fluid", name="aromatics", amount=140},
        {type="fluid", name="tar", amount=210},
      },
    },
    ["crucible"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="molten-stainless-steel", amount=6},
        {type="item", name="coke", amount=23},
        {type="item", name="quartz-tube", amount=5},
        {type="item", name="sodium-silicate", amount=1},
      },
      results = {
        {type="item", name="crucible", amount=4},
      },
    },
    ["eva"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="processed-fatty-acids", amount=67},
        {type="fluid", name="vinyl-acetate", amount=21},
      },
      results = {
        {type="item", name="eva", amount=5},
      },
    },
    ["mechanical-parts-02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="item", name="aluminium-plate", amount=94},
        {type="item", name="blade-mk02", amount=5},
        {type="item", name="brake-mk01", amount=4},
        {type="item", name="electronics-mk02", amount=1},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="fast-splitter", amount=2},
        {type="item", name="gearbox-mk01", amount=3},
        {type="item", name="mechanical-parts-01", amount=6},
        {type="item", name="neuroprocessor", amount=3},
        {type="item", name="nichrome", amount=4},
        {type="item", name="nickel-plate", amount=593},
        {type="item", name="pbsb-alloy", amount=6},
        {type="item", name="sb-oxide", amount=11},
        {type="item", name="shaft-mk01", amount=37},
        {type="item", name="small-parts-01", amount=82},
        {type="item", name="utility-box-mk01", amount=11},
      },
      results = {
        {type="item", name="mechanical-parts-02", amount=8},
      },
    },
    ["sb-oxide-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.666666666666667,
      ingredients = {
        {type="fluid", name="sb-pulp-02", amount=72},
      },
      results = {
        {type="item", name="sb-oxide", amount=2},
      },
    },
    ["sb-oxide-02a"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="fluid", name="sb-58-conc", amount=21},
        {type="fluid", name="sb-pulp-02", amount=151},
        {type="item", name="gunpowder", amount=35},
        {type="item", name="plastic-bar", amount=8},
        {type="item", name="ree-concentrate", amount=31},
      },
      results = {
        {type="item", name="sb-oxide", amount=12},
      },
    },
    ["lead-acetate"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=676},
        {type="fluid", name="hydrogen-peroxide", amount=47},
        {type="item", name="lead-plate", amount=5},
      },
      results = {
        {type="item", name="lead-acetate", amount=1},
      },
    },
    ["dowfroth-250"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="fluid", name="ethylene-glycol", amount=77},
        {type="item", name="chromium", amount=2},
      },
      results = {
        {type="fluid", name="dowfroth-250", amount=75},
      },
    },
    ["sb-crushed"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="calcium-carbide", amount=16},
        {type="item", name="sb-grade-03", amount=1},
      },
      results = {
        {type="item", name="sb-crushed", amount=2},
      },
    },
    ["sb-dust"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2.97498879334369,
      ingredients = {
        {type="item", name="calcium-carbide", amount=22},
        {type="item", name="sb-crushed", amount=2},
        {type="item", name="sb-grade-03", amount=4},
      },
      results = {
        {type="item", name="sb-dust", amount=3},
        {type="item", name="sb-grade-04", amount=1},
      },
    },
    ["sb-pulp-01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.08,
      ingredients = {
        {type="fluid", name="fish-oil", amount=42},
        {type="item", name="lead-acetate", amount=1},
        {type="item", name="sb-crushed", amount=7},
      },
      results = {
        {type="fluid", name="sb-pulp-01", amount=216},
      },
    },
    ["sb-pulp-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.41,
      ingredients = {
        {type="fluid", name="dowfroth-250", amount=21},
        {type="fluid", name="sb-pulp-01", amount=42},
      },
      results = {
        {type="fluid", name="sb-58-conc", amount=4},
        {type="fluid", name="sb-pulp-02", amount=21},
      },
    },
    ["fast-splitter"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="advanced-circuit", amount=2},
        {type="item", name="grade-4-tin", amount=3},
        {type="item", name="pcb2", amount=3},
        {type="item", name="sb-crushed", amount=4},
      },
      results = {
        {type="item", name="fast-splitter", amount=1},
      },
    },
    ["fast-transport-belt"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-air", amount=1159},
        {type="item", name="aluminium-plate", amount=14},
        {type="item", name="lead-plate", amount=3},
        {type="item", name="niobium-plate", amount=4},
        {type="item", name="small-parts-02", amount=2},
      },
      results = {
        {type="item", name="fast-transport-belt", amount=2},
      },
    },
    ["fast-underground-belt"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="copper-rejects", amount=87},
        {type="item", name="mixed-ores", amount=20},
        {type="item", name="nacl-biomass", amount=70},
        {type="item", name="organic-solvent-barrel", amount=5},
      },
      results = {
        {type="item", name="fast-underground-belt", amount=1},
      },
    },
    ["neutron-absorber-mk01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="carbon-dioxide-barrel", amount=302},
        {type="item", name="casein-mixture-barrel", amount=21},
        {type="item", name="electronics-mk01", amount=2},
        {type="item", name="grade-3-iron", amount=4},
        {type="item", name="gunpowder", amount=499},
        {type="item", name="mechanical-parts-01", amount=2},
        {type="item", name="medium-electric-pole", amount=7},
        {type="item", name="middle-oil-canister", amount=4},
        {type="item", name="rotor", amount=1},
        {type="item", name="sic", amount=8},
      },
      results = {
        {type="item", name="neutron-absorber-mk01", amount=1},
      },
    },
    ["py-biomass-powerplant-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-1-ti", amount=403},
        {type="item", name="latex", amount=226},
        {type="item", name="lubricant-barrel", amount=251},
        {type="item", name="mechanical-parts-01", amount=52},
        {type="item", name="middle-processed-lard-barrel", amount=316},
        {type="item", name="py-biomass-powerplant-mk01", amount=1},
        {type="item", name="rotor", amount=275},
        {type="item", name="sugar", amount=337},
        {type="item", name="vinyl-acetate-barrel", amount=17},
      },
      results = {
        {type="item", name="py-biomass-powerplant-mk02", amount=1},
      },
    },
    ["py-coal-powerplant-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="efficiency-module", amount=1},
        {type="item", name="electronic-circuit", amount=824},
        {type="item", name="mechanical-parts-01", amount=2},
        {type="item", name="middle-processed-lard-barrel", amount=10},
        {type="item", name="organic-acid-anhydride-barrel", amount=253},
        {type="item", name="ppd", amount=13},
        {type="item", name="py-construction-robot-mk01", amount=2},
        {type="item", name="ree-concentrate", amount=371},
        {type="item", name="ree-mining-drill-mk01", amount=26},
        {type="item", name="residual-oil-canister", amount=25},
        {type="item", name="rotor", amount=23},
        {type="item", name="small-parts-02", amount=62},
        {type="item", name="steam-engine", amount=27},
      },
      results = {
        {type="item", name="py-coal-powerplant-mk02", amount=1},
      },
    },
    ["py-oil-powerplant-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="hydrogen-chloride-barrel", amount=2238},
        {type="item", name="intermetallics", amount=273},
        {type="item", name="kicalk-plantation-mk01", amount=5},
        {type="item", name="lab", amount=20},
        {type="item", name="molten-solder-barrel", amount=116},
        {type="item", name="molten-zinc-barrel", amount=5},
        {type="item", name="p-dope", amount=17},
        {type="item", name="powdered-ralesia-seeds", amount=97},
        {type="item", name="py-coal-powerplant-mk01", amount=1},
        {type="item", name="py-heat-exchanger", amount=3},
        {type="item", name="ralesia-seeds-mk02", amount=130},
        {type="item", name="sb-dust", amount=36},
        {type="item", name="shaft-mk02", amount=9},
        {type="item", name="vawt-turbine-mk01", amount=4},
        {type="item", name="wax-barrel", amount=2416},
        {type="item", name="wet-scrubber-mk01", amount=5},
        {type="item", name="yaedols-spores-mk02", amount=13},
      },
      results = {
        {type="item", name="py-oil-powerplant-mk02", amount=2},
      },
    },
    ["tidal-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="belt-immunity-equipment", amount=9},
        {type="item", name="engine-unit", amount=88},
        {type="item", name="flotation-cell-mk01", amount=4},
        {type="item", name="grade-3-nickel", amount=225},
        {type="item", name="green-refined-concrete", amount=305},
        {type="item", name="primers", amount=10},
        {type="item", name="py-coal-powerplant-mk01", amount=1},
        {type="item", name="used-ulric-mk02", amount=27},
        {type="item", name="yaedols-spores-mk02", amount=109},
        {type="item", name="yotoi-codex", amount=5},
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
        {type="item", name="bitumen-barrel", amount=52},
        {type="item", name="blade-mk02", amount=9},
        {type="item", name="engine-unit", amount=112},
        {type="item", name="gold-plate", amount=60},
        {type="item", name="intermetallics", amount=219},
        {type="item", name="latex", amount=22},
        {type="item", name="neuroprocessor", amount=4},
        {type="item", name="nexelit-matrix", amount=161},
        {type="item", name="phenolicboard", amount=55},
        {type="item", name="processed-fatty-acids-barrel", amount=20},
        {type="item", name="rotor", amount=1},
        {type="item", name="yotoi-leaves", amount=434},
        {type="item", name="zipir-eggs", amount=271},
      },
      results = {
        {type="item", name="vawt-turbine-mk02", amount=1},
      },
    },
    ["hawt-turbine-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="anemometer-mk02", amount=2},
        {type="item", name="blade-mk02", amount=6},
        {type="item", name="earth-sea-sponge-sample", amount=2},
        {type="item", name="gearbox-mk02", amount=2},
        {type="item", name="grade-3-iron", amount=2873},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="syngas-barrel", amount=4383},
        {type="item", name="tower-mk01", amount=44},
        {type="item", name="ulric", amount=28},
      },
      results = {
        {type="item", name="hawt-turbine-mk02", amount=2},
      },
    },
    ["steam-turbine-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bio-oil-canister", amount=159},
        {type="item", name="bio-scafold", amount=8},
        {type="item", name="black-liquor-barrel", amount=276},
        {type="item", name="efficiency-module", amount=4},
        {type="item", name="electronic-circuit", amount=4146},
        {type="item", name="electronics-mk02", amount=13},
        {type="item", name="flotation-cell-mk01", amount=1},
        {type="item", name="intermetallics", amount=471},
        {type="item", name="latex", amount=58},
        {type="item", name="light-oil-barrel", amount=849},
        {type="item", name="mechanical-parts-01", amount=3},
        {type="item", name="organic-acid-anhydride-barrel", amount=164},
        {type="item", name="pcb-factory-mk01", amount=9},
        {type="item", name="plutonium-peroxide-barrel", amount=31},
        {type="item", name="powdered-phosphate-rock", amount=1852},
        {type="item", name="ree-concentrate", amount=1933},
        {type="item", name="ree-mining-drill-mk01", amount=53},
        {type="item", name="residual-mixture-barrel", amount=6193},
        {type="item", name="small-parts-02", amount=318},
        {type="item", name="steam-engine", amount=139},
        {type="item", name="used-ulric-mk02", amount=1},
        {type="item", name="xyhiphoe-codex", amount=11},
        {type="item", name="yaedols-spores-mk02", amount=31},
        {type="item", name="yotoi-codex", amount=2},
      },
      results = {
        {type="item", name="steam-turbine-mk02", amount=2},
      },
    },
    ["jig-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-food-01", amount=23},
        {type="item", name="carbon-dioxide-barrel", amount=171},
        {type="item", name="casein-mixture-barrel", amount=4},
        {type="item", name="coal-gas-canister", amount=30},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="glass", amount=9},
        {type="item", name="grade-4-ti", amount=23},
        {type="item", name="gunpowder", amount=90},
        {type="item", name="kerosene-barrel", amount=28},
        {type="item", name="korlex", amount=5},
        {type="item", name="medium-electric-pole", amount=4},
        {type="item", name="middle-oil-canister", amount=1},
        {type="item", name="nexelit-plate", amount=30},
        {type="item", name="niobium-ore", amount=108},
        {type="item", name="ore-aluminium", amount=90},
        {type="item", name="pcb1", amount=1},
        {type="item", name="rotor", amount=1},
        {type="item", name="sic", amount=2},
        {type="item", name="stripped-distillate-barrel", amount=1},
      },
      results = {
        {type="item", name="jig-mk01", amount=1},
      },
    },
    ["nmf-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="acetone-barrel", amount=12},
        {type="item", name="anthracene-oil-canister", amount=5},
        {type="item", name="brake-mk01", amount=1},
        {type="item", name="concrete", amount=27},
        {type="item", name="duralumin", amount=7},
        {type="item", name="electronic-circuit", amount=39},
        {type="item", name="electronics-factory-mk01", amount=1},
        {type="item", name="formamide-barrel", amount=4},
        {type="item", name="grade-4-chromite", amount=48},
        {type="item", name="micro-mine-mk01", amount=3},
        {type="item", name="nexelit-plate", amount=81},
        {type="item", name="niobium-plate", amount=59},
        {type="item", name="pipe", amount=473},
        {type="item", name="py-local-radar", amount=1},
        {type="item", name="residual-mixture-barrel", amount=25},
        {type="item", name="salt", amount=347},
        {type="item", name="small-parts-01", amount=42},
        {type="item", name="soil-extractor-mk01", amount=10},
        {type="item", name="tin-plate", amount=19},
      },
      results = {
        {type="item", name="nmf-mk01", amount=2},
      },
    },
    ["py-heat-exchanger-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="electronic-circuit", amount=19},
        {type="item", name="fwf-mk01", amount=1},
        {type="item", name="molten-solder-barrel", amount=291},
        {type="item", name="perylene-barrel", amount=34},
        {type="item", name="py-construction-robot-mk01", amount=2},
        {type="item", name="py-heat-exchanger", amount=1},
        {type="item", name="wax-barrel", amount=1945},
        {type="item", name="wet-scrubber-mk01", amount=1},
      },
      results = {
        {type="item", name="py-heat-exchanger-mk02", amount=2},
      },
    },
    ["bio-printer-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="creamy-latex-barrel", amount=17},
        {type="item", name="creosote-barrel", amount=3},
        {type="item", name="distilator", amount=1},
        {type="item", name="duralumin", amount=7},
        {type="item", name="mechanical-parts-01", amount=3},
        {type="item", name="nxsb-alloy", amount=6},
        {type="item", name="ree-solution-barrel", amount=20},
        {type="item", name="tin-plate", amount=28},
        {type="item", name="transport-belt", amount=182},
      },
      results = {
        {type="item", name="bio-printer-mk01", amount=1},
      },
    },
    ["botanical-nursery-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="advanced-circuit", amount=13},
        {type="item", name="auog-food-02", amount=50},
        {type="item", name="distilator", amount=2},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="epoxy", amount=7},
        {type="item", name="grade-3-zinc", amount=41},
        {type="item", name="heavy-n", amount=1},
        {type="item", name="inductor2", amount=1},
        {type="item", name="intermetallics", amount=20},
        {type="item", name="iron-gear-wheel", amount=69},
        {type="item", name="nuclear-sample", amount=2},
        {type="item", name="nxsb-alloy", amount=2},
        {type="item", name="optical-fiber", amount=32},
        {type="item", name="ralesia-plantation-mk01", amount=2},
        {type="item", name="rhe", amount=4},
        {type="item", name="rotor", amount=1},
        {type="item", name="rubber", amount=32},
        {type="item", name="shaft-mk02", amount=8},
        {type="item", name="small-parts-01", amount=23},
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
        {type="item", name="decalin-barrel", amount=525},
        {type="item", name="duralumin", amount=63},
        {type="item", name="eg-si", amount=172},
        {type="item", name="grade-4-chromite", amount=784},
        {type="item", name="hot-air-barrel", amount=138},
        {type="item", name="powdered-u", amount=130},
        {type="item", name="ulric-mk02-dna-sample", amount=48},
        {type="item", name="utility-box-mk02", amount=5},
      },
      results = {
        {type="item", name="spore-collector-mk02", amount=1},
      },
    },
    ["breed-fish-3"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2.09851893435255,
      ingredients = {
        {type="fluid", name="water", amount=7418},
        {type="item", name="albumin", amount=3},
        {type="item", name="coke", amount=8},
        {type="item", name="fawogae", amount=3},
        {type="item", name="fawogae-spore", amount=4},
        {type="item", name="filtration-media", amount=1},
        {type="item", name="fish-egg", amount=27},
        {type="item", name="fish-food-02", amount=1},
        {type="item", name="seaweed", amount=27},
        {type="item", name="small-lamp", amount=8},
      },
      results = {
        {type="fluid", name="waste-water", amount=209},
        {type="item", name="fish", amount=63},
      },
    },
    ["breed-fish-egg-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.63040023497644,
      ingredients = {
        {type="fluid", name="oxygen", amount=570},
        {type="item", name="albumin", amount=1},
        {type="item", name="fish", amount=39},
        {type="item", name="silicon", amount=13},
        {type="item", name="sodium-hydroxide", amount=6},
      },
      results = {
        {type="fluid", name="waste-water", amount=164},
        {type="item", name="fish-egg", amount=57},
      },
    },
    ["fish-egg-mk03-breeder"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.45534252263475,
      ingredients = {
        {type="item", name="arqad-honey-barrel", amount=22},
        {type="item", name="fish-mk02", amount=123},
        {type="item", name="shell", amount=2},
      },
      results = {
        {type="fluid", name="waste-water", amount=45},
        {type="item", name="fish-egg-mk02", amount=1},
        {type="item", name="fish-egg-mk03", amount=5},
      },
    },
    ["fish-mk03"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2.15092738512077,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=32982},
        {type="fluid", name="oxygen", amount=4934},
        {type="item", name="alien-sample-02", amount=1},
        {type="item", name="clay-pit-mk01", amount=17},
        {type="item", name="cocoon-mk02", amount=4},
        {type="item", name="fish-food-02", amount=2},
        {type="item", name="fish-mk02", amount=26},
        {type="item", name="plasmids", amount=1},
        {type="item", name="stone-wool", amount=19},
        {type="item", name="urea", amount=492},
      },
      results = {
        {type="item", name="fish", amount=13},
        {type="item", name="fish-mk03", amount=0.00844350750784868},
      },
    },
    ["fish-mk03-breeder"] = {
      mode = "repaired-to-input",
      science_level = 5,
      energy_required_multiplier = 1.07785600167193,
      ingredients = {
        {type="fluid", name="fish-hydrolysate", amount=51},
        {type="fluid", name="water-saline", amount=102},
        {type="item", name="alien-sample-02", amount=2},
        {type="item", name="fish-egg-mk02", amount=626},
        {type="item", name="limestone", amount=163},
        {type="item", name="transport-belt", amount=17},
      },
      results = {
        {type="fluid", name="waste-water", amount=102},
        {type="item", name="fish-mk02", amount=2},
        {type="item", name="fish-mk03", amount=7},
      },
    },
    ["energy-drink"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.571428571428571,
      ingredients = {
        {type="fluid", name="scrude", amount=801},
        {type="item", name="ground-sample01", amount=1},
        {type="item", name="ralesia-seeds", amount=2},
        {type="item", name="titanium-plate", amount=8},
      },
      results = {
        {type="item", name="energy-drink", amount=4},
      },
    },
    ["neuroprocessor"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="brain", amount=4},
        {type="item", name="copper-cable", amount=26},
        {type="item", name="electronic-circuit", amount=39},
        {type="item", name="formica", amount=4},
        {type="item", name="light-n", amount=1},
        {type="item", name="nexelit-matrix", amount=4},
        {type="item", name="optical-fiber", amount=8},
        {type="item", name="pcb2", amount=1},
        {type="item", name="pipe", amount=15},
        {type="item", name="planter-box", amount=2},
      },
      results = {
        {type="item", name="neuroprocessor", amount=3},
      },
    },
    ["nisi"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="vacuum", amount=425},
        {type="item", name="cobalt-extract", amount=3},
        {type="item", name="silicon", amount=3},
      },
      results = {
        {type="item", name="cobalt-extract", amount=2},
        {type="item", name="nisi", amount=1},
      },
    },
    ["capacitor2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="aluminium-plate", amount=8},
        {type="item", name="copper-cable", amount=90},
        {type="item", name="phenol", amount=1},
        {type="item", name="resistor1", amount=6},
      },
      results = {
        {type="item", name="capacitor2", amount=4},
      },
    },
    ["microchip"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.666666666666667,
      ingredients = {
        {type="fluid", name="flue-gas", amount=1172},
        {type="item", name="cermet", amount=6},
        {type="item", name="p-dope", amount=9},
        {type="item", name="silicon-wafer", amount=1},
        {type="item", name="tin-plate", amount=5},
        {type="item", name="tinned-cable", amount=12},
      },
      results = {
        {type="item", name="microchip", amount=2},
      },
    },
    ["mosfet"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="cermet", amount=2},
        {type="item", name="cobalt-extract", amount=1},
        {type="item", name="green-sic", amount=1},
        {type="item", name="heavy-n", amount=6},
        {type="item", name="melamine-resin", amount=44},
        {type="item", name="p-dope", amount=11},
        {type="item", name="plastic-bar", amount=9},
        {type="item", name="ree-concentrate", amount=4},
        {type="item", name="tin-plate", amount=4},
        {type="item", name="tinned-cable", amount=3},
      },
      results = {
        {type="item", name="mosfet", amount=6},
      },
    },
    ["phenolicboard"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="fluid", name="oxygen", amount=265},
        {type="item", name="capacitor1", amount=17},
        {type="item", name="crude-cermet", amount=37},
        {type="item", name="guar", amount=1},
        {type="item", name="phenol", amount=19},
        {type="item", name="salt", amount=7},
      },
      results = {
        {type="item", name="phenolicboard", amount=6},
      },
    },
    ["resistor2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.75,
      ingredients = {
        {type="item", name="cermet", amount=2},
        {type="item", name="fecr-alloy", amount=3},
        {type="item", name="phenol", amount=19},
        {type="item", name="resistor1", amount=3},
      },
      results = {
        {type="item", name="resistor2", amount=7},
      },
    },
    ["inductor2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="item", name="ferrite", amount=10},
        {type="item", name="inductor1", amount=2},
        {type="item", name="melamine-resin", amount=5},
        {type="item", name="sodium-bisulfate", amount=6},
        {type="item", name="tinned-cable", amount=15},
      },
      results = {
        {type="item", name="inductor2", amount=6},
      },
    },
    ["pcb2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="etching", amount=17},
        {type="item", name="copper-low-dust", amount=1},
        {type="item", name="inductor2", amount=2},
        {type="item", name="nylon", amount=3},
        {type="item", name="tin-plate", amount=3},
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
        {type="item", name="heavy-n", amount=4},
        {type="item", name="light-n", amount=5},
        {type="item", name="melamine", amount=16},
        {type="item", name="nylon-parts", amount=4},
        {type="item", name="p-dope", amount=3},
      },
      results = {
        {type="item", name="transistor", amount=4},
      },
    },
    ["diode"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cermet", amount=4},
        {type="item", name="heavy-n", amount=1},
        {type="item", name="light-n", amount=4},
        {type="item", name="nylon-parts", amount=14},
        {type="item", name="ree-concentrate", amount=4},
        {type="item", name="tin-plate", amount=4},
      },
      results = {
        {type="item", name="diode", amount=4},
      },
    },
    ["advanced-circuit"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.6,
      ingredients = {
        {type="item", name="bakelite", amount=8},
        {type="item", name="cobalt-fluoride", amount=6},
        {type="item", name="epoxy", amount=9},
        {type="item", name="heavy-n", amount=2},
        {type="item", name="inductor2", amount=2},
        {type="item", name="mosfet", amount=4},
        {type="item", name="nxsb-alloy", amount=3},
        {type="item", name="optical-fiber", amount=2},
        {type="item", name="phenolicboard", amount=3},
        {type="item", name="resistor1", amount=76},
        {type="item", name="steel-plate", amount=14},
      },
      results = {
        {type="item", name="advanced-circuit", amount=3},
      },
    },
    ["uranium-mining-drill"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=41},
        {type="item", name="diesel-barrel", amount=95},
        {type="item", name="gate", amount=46},
        {type="item", name="high-grade-ti-powder", amount=11},
        {type="item", name="hot-residual-mixture-barrel", amount=87},
        {type="item", name="light-armor", amount=62},
        {type="item", name="naphthalene-oil-canister", amount=444},
        {type="item", name="propene-barrel", amount=70},
        {type="item", name="resorcinol", amount=740},
        {type="item", name="scrude-canister", amount=172},
        {type="item", name="small-parts-02", amount=79},
        {type="item", name="ti-overflow-waste-barrel", amount=10},
        {type="item", name="xyhiphoe-cub", amount=6},
      },
      results = {
        {type="item", name="uranium-mining-drill", amount=1},
      },
    },
    ["aerial-base"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bisphenol-a", amount=48},
        {type="item", name="blade-mk02", amount=4},
        {type="item", name="coal-gas-barrel", amount=1280},
        {type="item", name="electronics-mk02", amount=1},
        {type="item", name="engine-unit", amount=42},
        {type="item", name="fluorine-gas-barrel", amount=3},
        {type="item", name="gearbox-mk01", amount=1},
        {type="item", name="gold-plate", amount=57},
        {type="item", name="intermetallics", amount=81},
        {type="item", name="latex", amount=8},
        {type="item", name="low-distillate-canister", amount=200},
        {type="item", name="mechanical-parts-01", amount=2},
        {type="item", name="natural-gas-canister", amount=30},
        {type="item", name="neuroprocessor", amount=9},
        {type="item", name="nexelit-matrix", amount=60},
        {type="item", name="phenolicboard", amount=6},
        {type="item", name="processed-fatty-acids-barrel", amount=8},
        {type="item", name="shaft-mk01", amount=1},
        {type="item", name="yotoi-leaves", amount=162},
        {type="item", name="zipir-eggs", amount=258},
      },
      results = {
        {type="item", name="aerial-base", amount=1},
      },
    },
    ["aerial-blimp-mk02"] = {
      mode = "input-preserved-untransformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="slacked-lime", amount=334},
        {type="item", name="ammonia-barrel", amount=24},
        {type="item", name="arqad", amount=9},
        {type="item", name="bulk-inserter", amount=6},
        {type="item", name="caged-auog", amount=69},
        {type="item", name="clean-nexelit", amount=2000},
        {type="item", name="dino-dig-site", amount=5},
        {type="item", name="diode", amount=16},
        {type="item", name="drilling-fluid-0-barrel", amount=44},
        {type="item", name="fast-transport-belt", amount=54},
        {type="item", name="mukmoux-pasture-mk01", amount=3},
        {type="item", name="neuroprocessor", amount=6},
        {type="item", name="nexelit-battery", amount=100},
        {type="item", name="ptcda", amount=71},
        {type="item", name="utility-box-mk01", amount=17},
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
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="compressor-mk01", amount=2},
        {type="item", name="micro-mine-mk01", amount=3},
        {type="item", name="nexelit-plate", amount=344},
        {type="item", name="niobium-plate", amount=25},
        {type="item", name="pcb1", amount=3},
        {type="item", name="pipe", amount=1573},
        {type="item", name="small-parts-01", amount=141},
      },
      results = {
        {type="item", name="cadaveric-arum-mk01", amount=3},
      },
    },
    ["grods-swamp-mk01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=31},
        {type="item", name="blade-mk01", amount=2},
        {type="item", name="creosote-barrel", amount=25},
        {type="item", name="diesel-barrel", amount=2},
        {type="item", name="duralumin", amount=19},
        {type="item", name="electronic-circuit", amount=2},
        {type="item", name="engine-unit", amount=7},
        {type="item", name="fiberboard", amount=39},
        {type="item", name="glass", amount=36},
        {type="item", name="iron-stick", amount=55},
        {type="item", name="nexelit-plate", amount=52},
        {type="item", name="rotor", amount=2},
        {type="item", name="stator", amount=1},
        {type="item", name="stone-brick", amount=153},
        {type="item", name="vanabins-barrel", amount=1},
      },
      results = {
        {type="item", name="grods-swamp-mk01", amount=1},
      },
    },
    ["guar-gum-plantation"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="acetone-barrel", amount=59},
        {type="item", name="anthracene-oil-canister", amount=24},
        {type="item", name="cottongut", amount=6},
        {type="item", name="flora-collector-mk01", amount=3},
        {type="item", name="formamide-barrel", amount=17},
        {type="item", name="glass", amount=437},
        {type="item", name="korlex-pup", amount=1},
        {type="item", name="molten-aluminium-barrel", amount=2},
        {type="item", name="nexelit-plate", amount=479},
        {type="item", name="pcb1", amount=8},
        {type="item", name="steel-chest", amount=3},
      },
      results = {
        {type="item", name="guar-gum-plantation", amount=2},
      },
    },
    ["navens-culture-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=54},
        {type="item", name="b-molasse-barrel", amount=3},
        {type="item", name="bisphenol-a", amount=7},
        {type="item", name="concrete", amount=157},
        {type="item", name="grade-4-tin", amount=218},
        {type="item", name="jaw-crusher", amount=1},
        {type="item", name="mechanical-parts-01", amount=18},
        {type="item", name="naphtha-barrel", amount=10},
        {type="item", name="stainless-steel", amount=7},
      },
      results = {
        {type="item", name="navens-culture-mk01", amount=1},
      },
    },
    ["ralesia-plantation-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="brain-cartridge-01", amount=15},
        {type="item", name="chlorine-barrel", amount=18},
        {type="item", name="cottongut-mk02", amount=24},
        {type="item", name="decalin-barrel", amount=33},
        {type="item", name="eg-si", amount=16},
        {type="item", name="fast-transport-belt", amount=7},
        {type="item", name="flamethrower-turret", amount=1},
        {type="item", name="grade-1-nickel", amount=26},
        {type="item", name="micro-fiber", amount=68},
        {type="item", name="military-science-pack", amount=39},
        {type="item", name="natural-gas-canister", amount=44},
        {type="item", name="pressured-hydrogen-barrel", amount=70},
        {type="item", name="processed-fatty-acids-barrel", amount=1},
        {type="item", name="py-limestone", amount=90},
        {type="item", name="shaft-mk02", amount=2},
        {type="item", name="stripped-distillate-barrel", amount=368},
        {type="item", name="yaedols-mk02", amount=1},
      },
      results = {
        {type="item", name="ralesia-plantation-mk02", amount=1},
      },
    },
    ["rennea-plantation-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coal-gas-canister", amount=3},
        {type="item", name="engine-unit", amount=5},
        {type="item", name="fenxsb-alloy", amount=22},
        {type="item", name="fiberboard", amount=216},
        {type="item", name="lead-plate", amount=9},
        {type="item", name="lens", amount=18},
        {type="item", name="limestone", amount=180},
        {type="item", name="ore-aluminium", amount=20},
        {type="item", name="pipe", amount=28},
        {type="item", name="py-tank-5000", amount=3},
        {type="item", name="steel-plate", amount=26},
        {type="item", name="titanium-plate", amount=75},
        {type="item", name="transport-belt", amount=133},
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
        {type="item", name="concrete", amount=52},
        {type="item", name="controler-mk01", amount=3},
        {type="item", name="hot-syngas-canister", amount=33},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="niobium-pipe", amount=18},
        {type="item", name="pressured-water-barrel", amount=34},
        {type="item", name="shotgun", amount=17},
        {type="item", name="tin-plate", amount=287},
        {type="item", name="titanium-plate", amount=47},
        {type="item", name="transport-belt", amount=12},
      },
      results = {
        {type="item", name="yotoi-aloe-orchard-mk01", amount=2},
      },
    },
    ["sponge-culture-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="arqad-hive-mk01", amount=1},
        {type="item", name="chlorine-barrel", amount=16},
        {type="item", name="cottongut-mk02", amount=21},
        {type="item", name="electronic-circuit", amount=55},
        {type="item", name="grade-1-nickel", amount=180},
        {type="item", name="hawt-turbine-mk01", amount=3},
        {type="item", name="natural-gas-canister", amount=98},
        {type="item", name="processed-fatty-acids-barrel", amount=10},
        {type="item", name="py-limestone", amount=200},
        {type="item", name="shaft-mk02", amount=4},
        {type="item", name="used-comb", amount=91},
      },
      results = {
        {type="item", name="sponge-culture-mk02", amount=1},
      },
    },
    ["cadaveric-arum-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="barrel", amount=217},
        {type="item", name="data-array", amount=1},
        {type="item", name="fiber", amount=5160},
        {type="item", name="korlex-codex-mk02", amount=5},
        {type="item", name="methanal-barrel", amount=57},
        {type="item", name="molten-titanium-barrel", amount=63},
        {type="item", name="niobium-pipe", amount=1115},
        {type="item", name="programmable-speaker", amount=21},
        {type="item", name="py-tank-3000", amount=2},
        {type="item", name="silica-powder", amount=186},
        {type="item", name="ti-overflow-waste-barrel", amount=3},
      },
      results = {
        {type="item", name="cadaveric-arum-mk02", amount=1},
      },
    },
    ["grods-swamp-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boric-acid-barrel", amount=194},
        {type="item", name="condensates-barrel", amount=305},
        {type="item", name="copper-rejects", amount=3974},
        {type="item", name="duralumin", amount=31},
        {type="item", name="latex-slab", amount=14},
        {type="item", name="methanal-barrel", amount=58},
        {type="item", name="molten-stainless-steel-barrel", amount=3},
        {type="item", name="py-underflow-valve", amount=10},
        {type="item", name="quartz-tube", amount=187},
        {type="item", name="stone-furnace", amount=56},
        {type="item", name="u-235", amount=2},
        {type="item", name="wood-fence", amount=151},
      },
      results = {
        {type="item", name="grods-swamp-mk02", amount=1},
      },
    },
    ["guar-gum-plantation-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="arqad-honey-barrel", amount=1032},
        {type="item", name="compost-plant-mk01", amount=1},
        {type="item", name="distilator", amount=5},
        {type="item", name="electronic-circuit", amount=39},
        {type="item", name="high-grade-ti-powder", amount=4},
        {type="item", name="intermetallics", amount=35},
        {type="item", name="iron-ore-dust", amount=72},
        {type="item", name="neutron-absorber-mk01", amount=2},
        {type="item", name="powdered-u", amount=1404},
        {type="item", name="purified-ti-pulp-barrel", amount=3},
        {type="item", name="sap-seeds-mk03", amount=270},
        {type="item", name="shell", amount=234},
        {type="item", name="shotgun-shell", amount=254},
        {type="item", name="stripped-distillate-barrel", amount=23},
        {type="item", name="vrauks-mk02", amount=2},
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
        {type="item", name="fawogae-plantation-mk01", amount=4},
        {type="item", name="guar-gum-plantation", amount=1},
        {type="item", name="latex", amount=45},
        {type="item", name="molten-solder-barrel", amount=4},
        {type="item", name="refsyngas-barrel", amount=2613},
        {type="item", name="stopper", amount=93},
        {type="item", name="tuuphra-mk02", amount=11},
        {type="item", name="wax-barrel", amount=86},
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
        {type="item", name="epoxy", amount=4},
        {type="item", name="high-grade-ti-powder", amount=6},
        {type="item", name="inductor2", amount=1},
        {type="item", name="naphthalene-oil-canister", amount=702},
        {type="item", name="propene-barrel", amount=14},
        {type="item", name="scrude-canister", amount=34},
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
        {type="item", name="arthropod-blood-barrel", amount=4},
        {type="item", name="chitin", amount=10},
        {type="item", name="copper-rejects", amount=346},
        {type="item", name="cottongut-food-02", amount=18},
        {type="item", name="electronic-circuit", amount=413},
        {type="item", name="glass-core", amount=92},
        {type="item", name="heavy-n", amount=9},
        {type="item", name="medium-electric-pole", amount=30},
        {type="item", name="military-science-pack", amount=6},
        {type="item", name="molybdenite-pulp-barrel", amount=13},
        {type="item", name="pressured-hydrogen-barrel", amount=10},
        {type="item", name="refined-natural-gas-canister", amount=51},
        {type="item", name="sap-extractor-mk01", amount=2},
        {type="item", name="sb-grade-03", amount=299},
        {type="item", name="sea-sponge-mk02", amount=3},
        {type="item", name="shotgun-shell", amount=335},
        {type="item", name="stripped-distillate-barrel", amount=21},
        {type="item", name="ulric-codex", amount=1},
        {type="item", name="vinyl-acetate-barrel", amount=5},
        {type="item", name="xyhiphoe-cub-mk02", amount=1},
      },
      results = {
        {type="item", name="moss-farm-mk02", amount=2},
      },
    },
    ["navens-culture-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bisphenol-a", amount=13},
        {type="item", name="chromium", amount=299},
        {type="item", name="coal-gas-barrel", amount=333},
        {type="item", name="flora-collector-mk01", amount=6},
        {type="item", name="gate", amount=8},
        {type="item", name="glycerol-barrel", amount=13},
        {type="item", name="light-armor", amount=3},
        {type="item", name="low-distillate-canister", amount=52},
        {type="item", name="molten-copper-barrel", amount=140},
        {type="item", name="plutonium-peroxide-barrel", amount=15},
        {type="item", name="resorcinol", amount=39},
        {type="item", name="shaft-mk02", amount=6},
        {type="item", name="ti-overflow-waste-barrel", amount=2},
        {type="item", name="ulric-mk02-dna-sample", amount=53},
        {type="item", name="uranium-fuel-cell", amount=11},
      },
      results = {
        {type="item", name="navens-culture-mk02", amount=1},
      },
    },
    ["rennea-plantation-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="acetylene-barrel", amount=153},
        {type="item", name="auog-paddock-mk01", amount=4},
        {type="item", name="diborane-barrel", amount=167},
        {type="item", name="electronics-mk02", amount=22},
        {type="item", name="fluorine-gas-barrel", amount=6},
        {type="item", name="glycerol-barrel", amount=9},
        {type="item", name="grods-swamp-mk01", amount=2},
        {type="item", name="lab", amount=7},
        {type="item", name="organic-solvent-barrel", amount=116},
        {type="item", name="petri-dish", amount=39},
        {type="item", name="soda-ash-barrel", amount=30},
        {type="item", name="stator", amount=5},
      },
      results = {
        {type="item", name="rennea-plantation-mk02", amount=2},
      },
    },
    ["sap-extractor-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boric-acid-barrel", amount=26},
        {type="item", name="condensates-barrel", amount=16},
        {type="item", name="diode", amount=6},
        {type="item", name="distilator", amount=1},
        {type="item", name="grade-1-lead", amount=67},
        {type="item", name="grade-3-ti", amount=926},
        {type="item", name="inserter", amount=3},
        {type="item", name="olefin-barrel", amount=21},
        {type="item", name="ptcda", amount=4},
        {type="item", name="py-underflow-valve", amount=1},
        {type="item", name="quartz-tube", amount=25},
        {type="item", name="rubber", amount=8},
        {type="item", name="sea-sponge-sprouts-mk02", amount=2},
        {type="item", name="syrup-01-barrel", amount=4},
        {type="item", name="wood-fence", amount=8},
      },
      results = {
        {type="item", name="sap-extractor-mk02", amount=1},
      },
    },
    ["seaweed-crop-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anthracene-oil-barrel", amount=52},
        {type="item", name="copper-low-dust", amount=29},
        {type="item", name="copper-rejects", amount=218},
        {type="item", name="distilator", amount=2},
        {type="item", name="fluorine-gas-barrel", amount=37},
        {type="item", name="glycerol-barrel", amount=50},
        {type="item", name="grade-1-lead", amount=50},
        {type="item", name="grade-3-ti", amount=684},
        {type="item", name="inserter", amount=2},
        {type="item", name="moss-farm-mk01", amount=1},
        {type="item", name="rubber", amount=6},
        {type="item", name="syrup-01-barrel", amount=1},
        {type="item", name="titanium-plate", amount=164},
      },
      results = {
        {type="item", name="seaweed-crop-mk02", amount=1},
      },
    },
    ["tuuphra-plantation-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="arthropod-blood-barrel", amount=19},
        {type="item", name="barrel", amount=565},
        {type="item", name="decalin-barrel", amount=179},
        {type="item", name="eg-si", amount=85},
        {type="item", name="grade-1-copper", amount=624},
        {type="item", name="methanal-barrel", amount=149},
        {type="item", name="molten-titanium-barrel", amount=165},
        {type="item", name="navens-codex", amount=1},
        {type="item", name="niobium-pipe", amount=7420},
        {type="item", name="silica-powder", amount=1240},
      },
      results = {
        {type="item", name="tuuphra-plantation-mk02", amount=2},
      },
    },
    ["bhoddos-culture-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="animal-sample-01", amount=44},
        {type="item", name="clean-nexelit", amount=13400},
        {type="item", name="condensates-barrel", amount=2373},
        {type="item", name="engine-unit", amount=300},
        {type="item", name="natural-gas-barrel", amount=276},
        {type="item", name="navens-codex", amount=9},
        {type="item", name="salt-mine", amount=36},
      },
      results = {
        {type="item", name="bhoddos-culture-mk02", amount=2},
      },
    },
    ["fawogae-plantation-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="acetylene-barrel", amount=860},
        {type="item", name="auog-paddock-mk01", amount=3},
        {type="item", name="electronics-mk02", amount=3},
        {type="item", name="lab", amount=5},
        {type="item", name="refsyngas-barrel", amount=420},
        {type="item", name="soda-ash-barrel", amount=53},
        {type="item", name="stator", amount=26},
      },
      results = {
        {type="item", name="fawogae-plantation-mk02", amount=2},
      },
    },
    ["fwf-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="arthropod-blood-barrel", amount=4},
        {type="item", name="boric-acid-barrel", amount=32},
        {type="item", name="chitin", amount=34},
        {type="item", name="condensates-barrel", amount=20},
        {type="item", name="cottongut-food-02", amount=20},
        {type="item", name="electronic-circuit", amount=441},
        {type="item", name="medium-electric-pole", amount=13},
        {type="item", name="quartz-tube", amount=31},
        {type="item", name="refined-natural-gas-canister", amount=55},
        {type="item", name="sap-extractor-mk01", amount=2},
        {type="item", name="shotgun-shell", amount=1121},
      },
      results = {
        {type="item", name="fwf-mk02", amount=1},
      },
    },
    ["bulk-inserter"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="duralumin", amount=13},
        {type="item", name="electronic-circuit", amount=24},
        {type="item", name="nbalti", amount=5},
        {type="item", name="stator", amount=2},
        {type="item", name="titanium-plate", amount=15},
      },
      results = {
        {type="item", name="bulk-inserter", amount=1},
      },
    },
    ["assembling-machine-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="fish-hydrolysate-barrel", amount=3},
        {type="item", name="long-handed-inserter", amount=51},
        {type="item", name="yaedols-spores-mk02", amount=89},
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
        {type="item", name="chromium", amount=44},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="intermetallics", amount=16},
        {type="item", name="nuclear-sample", amount=2},
        {type="item", name="optical-fiber", amount=10},
        {type="item", name="rubber", amount=10},
        {type="item", name="self-assembly-monolayer", amount=5},
        {type="item", name="shaft-mk02", amount=2},
        {type="item", name="transistor", amount=4},
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
        {type="item", name="grade-4-tin", amount=74},
        {type="item", name="intermetallics", amount=2},
        {type="item", name="neuroprocessor", amount=6},
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
        {type="item", name="fiber", amount=183},
        {type="item", name="intermetallics", amount=215},
        {type="item", name="small-parts-02", amount=23},
        {type="item", name="titanium-plate", amount=63},
      },
      results = {
        {type="item", name="megadar", amount=1},
      },
    },
    ["modular-armor"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="belt-immunity-equipment", amount=1},
        {type="item", name="electronic-circuit", amount=1013},
        {type="item", name="engine-unit", amount=42},
        {type="item", name="flotation-cell-mk01", amount=5},
        {type="item", name="grade-2-u", amount=853},
        {type="item", name="grade-3-nickel", amount=108},
        {type="item", name="heavy-armor", amount=18},
        {type="item", name="ppd", amount=62},
        {type="item", name="primers", amount=5},
        {type="item", name="py-construction-robot-mk01", amount=11},
        {type="item", name="self-assembly-monolayer", amount=3},
        {type="item", name="used-ulric-mk02", amount=4},
        {type="item", name="yaedols-spores-mk02", amount=134},
        {type="item", name="yotoi-codex", amount=7},
      },
      results = {
        {type="item", name="modular-armor", amount=1},
      },
    },
    ["particle-accelerator-mk01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anemometer-mk02", amount=4},
        {type="item", name="compressor-mk01", amount=1},
        {type="item", name="fawogae-plantation-mk01", amount=4},
        {type="item", name="fenxsb-alloy", amount=30},
        {type="item", name="guar-gum-plantation", amount=1},
        {type="item", name="iron-stick", amount=1019},
        {type="item", name="kicalk-plantation-mk01", amount=8},
        {type="item", name="latex", amount=20},
        {type="item", name="refsyngas-barrel", amount=2891},
        {type="item", name="small-parts-01", amount=69},
        {type="item", name="stopper", amount=13},
        {type="item", name="xyhiphoe", amount=3},
      },
      results = {
        {type="item", name="particle-accelerator-mk01", amount=1},
      },
    },
    ["yaedols-culture-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="decalin-barrel", amount=1157},
        {type="item", name="duralumin", amount=54},
        {type="item", name="eg-si", amount=850},
        {type="item", name="fiber", amount=776},
        {type="item", name="fish-farm-mk01", amount=1},
        {type="item", name="grade-4-chromite", amount=216},
        {type="item", name="hot-air-barrel", amount=119},
        {type="item", name="korlex-codex-mk02", amount=1},
        {type="item", name="neuroprocessor", amount=18},
        {type="item", name="niobium-dust", amount=370},
        {type="item", name="offshore-pump", amount=31},
        {type="item", name="powdered-u", amount=287},
        {type="item", name="titanium-plate", amount=793},
        {type="item", name="ulric-mk02-dna-sample", amount=42},
        {type="item", name="used-comb", amount=2052},
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
        {type="item", name="copper-rejects", amount=3041},
        {type="item", name="duralumin", amount=61},
        {type="item", name="grade-3-chromite", amount=41},
        {type="item", name="methanal-barrel", amount=357},
        {type="item", name="prandium-lab-mk01", amount=2},
        {type="item", name="u-235", amount=10},
      },
      results = {
        {type="item", name="yotoi-aloe-orchard-mk02", amount=1},
      },
    },
    ["kicalk-seeds-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.6,
      ingredients = {
        {type="item", name="boron-trioxide", amount=2},
        {type="item", name="kicalk-mk02", amount=2},
        {type="item", name="kicalk-seeds-mk02", amount=1},
        {type="item", name="small-lamp", amount=3},
      },
      results = {
        {type="item", name="kicalk-seeds-mk02", amount=4},
      },
    },
    ["yotoi-fiber"] = {
      mode = "repaired-to-input",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="yotoi", amount=2},
      },
      results = {
        {type="item", name="raw-fiber", amount=3},
      },
    },
    ["bedding"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="grod", amount=1},
        {type="item", name="kicalk", amount=2},
        {type="item", name="wood", amount=5},
        {type="item", name="yotoi", amount=5},
      },
      results = {
        {type="item", name="bedding", amount=4},
      },
    },
    ["cu-biomass-extraction"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.95145261152407,
      ingredients = {
        {type="item", name="auog-food-01", amount=1},
        {type="item", name="bedding", amount=1},
        {type="item", name="condensed-distillate-barrel", amount=1},
        {type="item", name="cu-biomass", amount=11},
      },
      results = {
        {type="item", name="biomass", amount=10},
        {type="item", name="copper-ore", amount=39},
      },
    },
    ["fe-biomass-extraction"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="fluid", name="water", amount=217},
        {type="item", name="sn-biomass", amount=3},
      },
      results = {
        {type="item", name="biomass", amount=2},
        {type="item", name="iron-ore", amount=8},
      },
    },
    ["fungal-substrate-03"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.1,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=55},
        {type="item", name="agar", amount=1},
        {type="item", name="empty-petri-dish", amount=3},
        {type="item", name="fine-powdered-biomass", amount=4},
        {type="item", name="gravel", amount=3},
        {type="item", name="meat", amount=3},
        {type="item", name="raw-fiber", amount=3},
        {type="item", name="tuuphra", amount=1},
        {type="item", name="yaedols", amount=3},
      },
      results = {
        {type="item", name="fungal-substrate-03", amount=11},
      },
    },
    ["nacl-biomass-extraction"] = {
      mode = "repaired-to-input",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=100},
        {type="item", name="nacl-biomass", amount=15},
      },
      results = {
        {type="item", name="biomass", amount=5},
        {type="item", name="salt", amount=30},
      },
    },
    ["psc"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.98,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=389},
        {type="fluid", name="xenogenic-cells", amount=133},
        {type="item", name="dried-meat", amount=11},
        {type="item", name="retrovirus", amount=1},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=49},
        {type="fluid", name="psc", amount=49},
      },
    },
    ["s-biomass-extraction"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="s-biomass", amount=8},
      },
      results = {
        {type="item", name="biomass", amount=4},
        {type="item", name="sulfur", amount=8},
      },
    },
    ["sn-biomass-extraction"] = {
      mode = "repaired-to-input",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=140},
        {type="item", name="nacl-biomass", amount=8},
      },
      results = {
        {type="item", name="biomass", amount=5},
        {type="item", name="ore-tin", amount=15},
      },
    },
    ["sodium-carbonate-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 3.99820210614576,
      ingredients = {
        {type="item", name="coke", amount=19},
        {type="item", name="gravel", amount=8},
        {type="item", name="sodium-bisulfate", amount=3},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=189},
        {type="item", name="sodium-carbonate", amount=4},
      },
    },
    ["sporopollenin"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="item", name="cu-biomass", amount=1},
        {type="item", name="grade-3-lead", amount=1},
        {type="item", name="rennea-seeds", amount=7},
        {type="item", name="yaedols", amount=17},
      },
      results = {
        {type="item", name="sporopollenin", amount=7},
      },
    },
    ["vinyl-acetate"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.760290862938007,
      ingredients = {
        {type="fluid", name="processed-fatty-acids", amount=77},
        {type="item", name="chromium", amount=2},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=38},
        {type="fluid", name="tailings", amount=77},
        {type="fluid", name="vinyl-acetate", amount=38},
      },
    },
    ["lignin"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.125,
      ingredients = {
        {type="fluid", name="pressured-air", amount=129},
        {type="item", name="dried-biomass", amount=29},
        {type="item", name="powdered-biomass", amount=129},
        {type="item", name="sodium-hydroxide", amount=2},
      },
      results = {
        {type="item", name="lignin", amount=9},
      },
    },
    ["seeds-extract-01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="item", name="grod", amount=5},
        {type="item", name="guar", amount=29},
        {type="item", name="rennea", amount=4},
        {type="item", name="rennea-seeds", amount=4},
        {type="item", name="seaweed", amount=16},
        {type="item", name="yaedols", amount=1},
      },
      results = {
        {type="item", name="seeds-extract-01", amount=6},
      },
    },
    ["yotoi-cellulose"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="lubricant", amount=41},
        {type="item", name="ash", amount=7},
        {type="item", name="crude-cermet", amount=2},
        {type="item", name="salt", amount=10},
        {type="item", name="yotoi", amount=4},
      },
      results = {
        {type="item", name="cellulose", amount=4},
      },
    },
    ["ulric-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.829667096942316,
      ingredients = {
        {type="item", name="auog-pup", amount=9},
        {type="item", name="bedding", amount=1},
        {type="item", name="ralesia", amount=5},
        {type="item", name="ulric-food-01", amount=1},
        {type="item", name="water-barrel", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=4},
        {type="item", name="ulric", amount=5},
      },
    },
    ["ulric-cub-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="albumin", amount=2},
        {type="item", name="fawogae-spore", amount=13},
        {type="item", name="refined-natural-gas-barrel", amount=3},
        {type="item", name="ulric-food-01", amount=3},
      },
      results = {
        {type="item", name="barrel", amount=15},
        {type="item", name="ulric-cub", amount=6},
      },
    },
    ["ulric-manure-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.35214894523131,
      ingredients = {
        {type="item", name="ralesia", amount=10},
        {type="item", name="refined-natural-gas-barrel", amount=6},
        {type="item", name="salt", amount=6},
        {type="item", name="stone-wool", amount=3},
        {type="item", name="ulric-food-01", amount=1},
      },
      results = {
        {type="item", name="barrel", amount=7},
        {type="item", name="manure", amount=8},
      },
    },
    ["ulric-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2.15083400877649,
      ingredients = {
        {type="item", name="bedding", amount=7},
        {type="item", name="bio-oil-canister", amount=1},
        {type="item", name="cottongut-food-01", amount=4},
        {type="item", name="kicalk", amount=3},
        {type="item", name="naphtha-barrel", amount=3},
        {type="item", name="ulric", amount=3},
        {type="item", name="ulric-food-01", amount=2},
        {type="item", name="vrauks-food-02", amount=2},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="barrel", amount=15},
        {type="item", name="ulric", amount=1},
        {type="item", name="ulric-mk02", amount=0.0108467870649754},
      },
    },
    ["ulric-mk02-dna-sample"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="refined-natural-gas-barrel", amount=3},
        {type="item", name="sample-cup", amount=177},
        {type="item", name="treated-wood", amount=12},
        {type="item", name="ulric", amount=85},
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
        {type="item", name="lignin", amount=16},
        {type="item", name="ulric-mk02", amount=1},
      },
      results = {
        {type="item", name="ulric-mk02-dna-sample", amount=6},
        {type="item", name="used-ulric-mk02", amount=1},
      },
    },
    ["ulric-mk02-breeding"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-food-02", amount=2},
        {type="item", name="sample-cup", amount=98},
        {type="item", name="ulric-food-01", amount=4},
        {type="item", name="ulric-mk02", amount=1},
        {type="item", name="yaedols", amount=8},
      },
      results = {
        {type="item", name="barrel", amount=7},
        {type="item", name="ulric-cub-mk02", amount=1},
        {type="item", name="used-ulric-mk02", amount=1},
      },
    },
    ["ulric-recharge-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="albumin", amount=2},
        {type="item", name="refined-natural-gas-canister", amount=367},
        {type="item", name="used-ulric-mk02", amount=1},
      },
      results = {
        {type="item", name="ulric-mk02", amount=3},
      },
    },
    ["ulric-mk02-raising"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="barrel-milk", amount=4},
        {type="item", name="lignin", amount=40},
        {type="item", name="py-check-valve", amount=5},
        {type="item", name="ulric-cub-mk02", amount=4},
        {type="item", name="yaedols", amount=3},
      },
      results = {
        {type="item", name="empty-barrel-milk", amount=2},
        {type="item", name="ulric-mk02", amount=1},
      },
    },
    ["compile-korlex-codex"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="arqad-codex", amount=1},
        {type="item", name="duralumin", amount=8},
        {type="item", name="electronic-circuit", amount=16},
        {type="item", name="nbalti", amount=3},
        {type="item", name="stainless-steel", amount=22},
        {type="item", name="stator", amount=1},
      },
      results = {
        {type="item", name="korlex-codex-mk02", amount=2},
      },
    },
    ["korlex-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.75,
      ingredients = {
        {type="item", name="arqad-honey-barrel", amount=3},
        {type="item", name="caged-korlex", amount=5},
        {type="item", name="korlex-food-01", amount=1},
        {type="item", name="lignin", amount=23},
        {type="item", name="seaweed", amount=71},
        {type="item", name="tuuphra-mk02", amount=1},
      },
      results = {
        {type="item", name="barrel", amount=14},
        {type="item", name="korlex", amount=7},
      },
    },
    ["korlex-milk-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2.65631066963562,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=100},
        {type="item", name="bhoddos", amount=1},
        {type="item", name="casein", amount=3},
        {type="item", name="empty-petri-dish", amount=5},
        {type="item", name="fish", amount=8},
        {type="item", name="fish-hydrolysate-barrel", amount=1},
        {type="item", name="gravel", amount=15},
        {type="item", name="korlex-food-01", amount=2},
        {type="item", name="meat", amount=15},
        {type="item", name="raw-fiber", amount=14},
        {type="item", name="tuuphra-seeds", amount=25},
        {type="item", name="yaedols", amount=5},
      },
      results = {
        {type="item", name="barrel", amount=26},
        {type="item", name="barrel-milk", amount=16},
      },
    },
    ["korlex-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.6261807832514,
      ingredients = {
        {type="fluid", name="vacuum", amount=52202},
        {type="fluid", name="water", amount=3320},
        {type="item", name="albumin", amount=1},
        {type="item", name="fawogae-substrate", amount=3},
        {type="item", name="filtration-media", amount=4},
        {type="item", name="fish-food-01", amount=4},
        {type="item", name="korlex", amount=2},
        {type="item", name="lignin", amount=19},
        {type="item", name="nylon", amount=11},
        {type="item", name="refined-natural-gas-barrel", amount=3},
        {type="item", name="rennea-seeds", amount=18},
      },
      results = {
        {type="item", name="barrel", amount=10},
        {type="item", name="korlex", amount=1},
        {type="item", name="korlex-mk02", amount=0.00801681633716068},
      },
    },
    ["korlex-pup-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.996704001793883,
      ingredients = {
        {type="item", name="arqad-honey-barrel", amount=2},
        {type="item", name="benzene-canister", amount=1},
        {type="item", name="caged-korlex", amount=1},
        {type="item", name="chromite-rejects", amount=2},
        {type="item", name="coal-dust", amount=9},
        {type="item", name="fish-hydrolysate-barrel", amount=6},
        {type="item", name="korlex-food-01", amount=3},
        {type="item", name="lignin", amount=5},
        {type="item", name="log", amount=1},
        {type="item", name="olefin-barrel", amount=11},
        {type="item", name="salt", amount=20},
        {type="item", name="seaweed", amount=44},
        {type="item", name="tuuphra", amount=1},
        {type="item", name="tuuphra-mk02", amount=1},
      },
      results = {
        {type="item", name="barrel", amount=24},
        {type="item", name="korlex-pup", amount=6},
      },
    },
    ["korlex-mk02r"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="alien-sample-02", amount=1},
        {type="item", name="guts", amount=345},
        {type="item", name="kevlar-coating", amount=3},
        {type="item", name="korlex-mk02", amount=7},
        {type="item", name="nichrome", amount=41},
      },
      results = {
        {type="item", name="korlex-mk02", amount=8},
      },
    },
    ["sap-seeds-mk03-gen"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="fish-emulsion", amount=15},
        {type="item", name="sap-tree", amount=8},
        {type="item", name="saps", amount=4},
        {type="item", name="stone", amount=20},
      },
      results = {
        {type="item", name="sap-seeds-mk03", amount=1},
      },
    },
    ["sap-seeds-mk03"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="hydrogen", amount=141},
        {type="item", name="diborane-barrel", amount=3},
        {type="item", name="native-flora", amount=10},
      },
      results = {
        {type="item", name="sap-seeds-mk03", amount=4},
      },
    },
    ["sap-tree-mk03-gen"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="oxygen", amount=102},
        {type="fluid", name="steam", amount=1413},
        {type="item", name="brain", amount=4},
        {type="item", name="kicalk", amount=3},
        {type="item", name="sap-seeds-mk03", amount=3},
        {type="item", name="skin", amount=3},
      },
      results = {
        {type="item", name="sap-tree-mk03", amount=2},
      },
    },
    ["xyhiphoe-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.63800901030798,
      ingredients = {
        {type="fluid", name="oxygen", amount=1581},
        {type="fluid", name="steam", amount=2051},
        {type="item", name="albumin", amount=10},
        {type="item", name="filtration-media", amount=4},
        {type="item", name="fish-food-01", amount=1},
        {type="item", name="fishmeal", amount=5},
        {type="item", name="tar-canister", amount=1},
        {type="item", name="xyhiphoe-cub", amount=1},
      },
      results = {
        {type="fluid", name="waste-water", amount=309},
        {type="item", name="xyhiphoe", amount=2},
      },
    },
    ["xyhiphoe-cub-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.702361815875838,
      ingredients = {
        {type="fluid", name="vacuum", amount=12607},
        {type="item", name="fawogae-substrate", amount=6},
        {type="item", name="filtration-media", amount=1},
        {type="item", name="fish-food-01", amount=1},
        {type="item", name="medium-distillate-barrel", amount=1},
        {type="item", name="nylon", amount=7},
        {type="item", name="red-refined-concrete", amount=4},
      },
      results = {
        {type="fluid", name="waste-water", amount=445},
        {type="item", name="xyhiphoe-cub", amount=5},
      },
    },
    ["xyhiphoe-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.521872642857683,
      ingredients = {
        {type="fluid", name="hydrogen", amount=795},
        {type="fluid", name="vacuum", amount=2923},
        {type="item", name="filtration-media", amount=2},
        {type="item", name="fishmeal", amount=3},
        {type="item", name="nylon", amount=1},
        {type="item", name="xyhiphoe", amount=2},
      },
      results = {
        {type="item", name="xyhiphoe", amount=1},
        {type="item", name="xyhiphoe-mk02", amount=0.00260936321428841},
      },
    },
    ["xyhiphoe-pool-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="chromium", amount=158},
        {type="item", name="cobalt-fluoride", amount=13},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="fast-transport-belt", amount=15},
        {type="item", name="flora-collector-mk01", amount=8},
        {type="item", name="gold-plate", amount=4},
        {type="item", name="high-grade-ti-powder", amount=1},
        {type="item", name="intermetallics", amount=6},
        {type="item", name="molten-copper-barrel", amount=190},
        {type="item", name="naphthalene-oil-canister", amount=56},
        {type="item", name="neuroprocessor", amount=17},
        {type="item", name="outpost-fluid", amount=27},
        {type="item", name="plutonium-peroxide-barrel", amount=21},
        {type="item", name="selector-combinator", amount=3},
        {type="item", name="shaft-mk02", amount=1},
        {type="item", name="u-pulp-01-barrel", amount=8},
        {type="item", name="ulric-mk02-dna-sample", amount=28},
        {type="item", name="uranium-fuel-cell", amount=6},
        {type="item", name="vpulp2-barrel", amount=2},
        {type="item", name="waste-water-barrel", amount=194},
        {type="item", name="wet-scrubber-mk01", amount=1},
        {type="item", name="zipir-eggs", amount=20},
      },
      results = {
        {type="item", name="xyhiphoe-pool-mk02", amount=2},
      },
    },
    ["xyhiphoe-cub-mk02-breeder"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.30529113034482,
      ingredients = {
        {type="item", name="cliff-explosives", amount=3},
        {type="item", name="fish-egg-mk02", amount=4},
        {type="item", name="nylon-parts", amount=103},
        {type="item", name="stone-wall", amount=30},
        {type="item", name="xyhiphoe-mk02", amount=1},
      },
      results = {
        {type="item", name="xyhiphoe-cub", amount=1},
        {type="item", name="xyhiphoe-cub-mk02", amount=3},
      },
    },
    ["xyhiphoe-mk02-breeder"] = {
      mode = "repaired-to-input",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="fetal-serum", amount=50},
        {type="item", name="xyhiphoe-cub", amount=80},
      },
      results = {
        {type="item", name="xyhiphoe", amount=1},
        {type="item", name="xyhiphoe-mk02", amount=1},
      },
    },
    ["bhoddos-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2.4,
      ingredients = {
        {type="item", name="bhoddos", amount=4},
        {type="item", name="burner-inserter", amount=2},
        {type="item", name="dried-meat", amount=1},
      },
      results = {
        {type="item", name="bhoddos", amount=16},
      },
    },
    ["bhoddos-sample"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="alien-sample-02", amount=2},
        {type="item", name="cytostatics", amount=3},
        {type="item", name="dna-polymerase", amount=1},
        {type="item", name="earth-palmtree-sample", amount=5},
        {type="item", name="moondrop-seeds", amount=397},
        {type="item", name="mukmoux-codex", amount=8},
      },
      results = {
        {type="item", name="bhoddos", amount=3},
      },
    },
    ["fish-food-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="item", name="bones", amount=3},
        {type="item", name="fish", amount=1},
        {type="item", name="meat", amount=5},
        {type="item", name="moss", amount=3},
        {type="item", name="pipe", amount=3},
        {type="item", name="pyrite", amount=2},
        {type="item", name="red-refined-concrete", amount=23},
        {type="item", name="rich-clay", amount=3},
        {type="item", name="sodium-chlorate", amount=2},
        {type="item", name="sodium-hydroxide", amount=10},
        {type="item", name="yaedols", amount=1},
      },
      results = {
        {type="item", name="fish-food-02", amount=2},
      },
    },
    ["naven-coal"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.1,
      ingredients = {
        {type="item", name="navens", amount=1},
      },
      results = {
        {type="item", name="raw-coal", amount=11},
      },
    },
    ["navens-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.571428571428571,
      ingredients = {
        {type="item", name="fertilizer", amount=7},
        {type="item", name="fungal-substrate-03", amount=1},
        {type="item", name="navens-spore", amount=3},
      },
      results = {
        {type="item", name="navens", amount=4},
      },
    },
    ["navens-sample"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="alien-sample-02", amount=2},
        {type="item", name="condensates-barrel", amount=4290},
        {type="item", name="cytostatics", amount=2},
        {type="item", name="earth-bear-sample", amount=1},
        {type="item", name="kicalk-mk02", amount=13},
        {type="item", name="low-grade-copper", amount=119},
        {type="item", name="natural-gas-barrel", amount=499},
        {type="item", name="navens-codex", amount=1},
      },
      results = {
        {type="item", name="navens", amount=4},
      },
    },
    ["mukmoux-codex"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="electronic-circuit", amount=19},
        {type="item", name="nxsb-alloy", amount=3},
      },
      results = {
        {type="item", name="mukmoux-codex", amount=2},
      },
    },
    ["mukmoux-food-01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="fluid", name="water-saline", amount=345},
        {type="item", name="grade-1-tin", amount=1},
        {type="item", name="gunpowder", amount=3},
        {type="item", name="moondrop-mk02", amount=1},
        {type="item", name="ralesia", amount=26},
        {type="item", name="salt", amount=6},
        {type="item", name="silicon", amount=21},
        {type="item", name="sodium-hydroxide", amount=6},
      },
      results = {
        {type="item", name="mukmoux-food-01", amount=5},
      },
    },
    ["mukmoux-manure-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.96836141439634,
      ingredients = {
        {type="item", name="bedding", amount=1},
        {type="item", name="fertilizer", amount=30},
        {type="item", name="mukmoux-food-01", amount=3},
        {type="item", name="refined-natural-gas-barrel", amount=7},
      },
      results = {
        {type="item", name="barrel", amount=13},
        {type="item", name="manure", amount=5},
        {type="item", name="manure-bacteria-barrel", amount=1},
      },
    },
    ["mukmoux"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 4,
      ingredients = {
        {type="fluid", name="bio-oil", amount=8960},
        {type="fluid", name="blood", amount=2649},
        {type="item", name="alien-sample-02", amount=3},
        {type="item", name="alien-sample01", amount=344},
        {type="item", name="aluminium-plate", amount=262},
        {type="item", name="cytostatics", amount=4},
        {type="item", name="dna-polymerase", amount=48},
        {type="item", name="earth-cow-sample", amount=1},
        {type="item", name="earth-crustacean-sample", amount=2},
        {type="item", name="earth-generic-sample", amount=3},
        {type="item", name="mukmoux-codex", amount=1},
        {type="item", name="ulric-codex", amount=2},
      },
      results = {
        {type="item", name="mukmoux", amount=4},
      },
    },
    ["mukmoux-calf-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.97266242744193,
      ingredients = {
        {type="item", name="bedding", amount=3},
        {type="item", name="bhoddos", amount=4},
        {type="item", name="fertilizer", amount=16},
        {type="item", name="mukmoux-food-01", amount=3},
        {type="item", name="naphtha-barrel", amount=7},
        {type="item", name="ralesia", amount=38},
        {type="item", name="refined-natural-gas-barrel", amount=10},
      },
      results = {
        {type="item", name="barrel", amount=28},
        {type="item", name="mukmoux-calf", amount=4},
      },
    },
    ["mukmoux-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 3.5849719813277,
      ingredients = {
        {type="item", name="cage", amount=4},
        {type="item", name="caged-mukmoux", amount=5},
        {type="item", name="mukmoux", amount=4},
        {type="item", name="mukmoux-food-01", amount=3},
        {type="item", name="naphtha-barrel", amount=4},
        {type="item", name="ralesia", amount=29},
      },
      results = {
        {type="item", name="barrel", amount=32},
        {type="item", name="mukmoux", amount=11},
      },
    },
    ["mukmoux-pasture-mk01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="acetone-barrel", amount=68},
        {type="item", name="anthracene-oil-canister", amount=27},
        {type="item", name="carbon-dioxide-barrel", amount=11},
        {type="item", name="etching-barrel", amount=1},
        {type="item", name="formamide-barrel", amount=8},
        {type="item", name="limestone", amount=235},
        {type="item", name="molten-aluminium-barrel", amount=6},
      },
      results = {
        {type="item", name="mukmoux-pasture-mk01", amount=1},
      },
    },
    ["cottongut-food-02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="fertilizer", amount=3},
        {type="item", name="guar", amount=2},
        {type="item", name="moondrop-fueloil", amount=13},
        {type="item", name="native-flora", amount=14},
        {type="item", name="rennea", amount=6},
        {type="item", name="rennea-seeds", amount=6},
        {type="item", name="sand-casting", amount=9},
        {type="item", name="wood-seedling", amount=5},
      },
      results = {
        {type="item", name="cottongut-food-02", amount=9},
      },
    },
    ["cottongut-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 3.99249741606388,
      ingredients = {
        {type="fluid", name="artificial-blood", amount=43},
        {type="fluid", name="fetal-serum", amount=107},
        {type="fluid", name="zogna-bacteria", amount=101},
        {type="item", name="dna-polymerase", amount=3},
        {type="item", name="sea-sponge-sprouts-mk02", amount=9},
      },
      results = {
        {type="item", name="cottongut-mk01", amount=2},
        {type="item", name="cottongut-mk02", amount=0.0188467924124568},
      },
    },
    ["cottongut-pup-mk02-raising"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.03896103896104,
      ingredients = {
        {type="item", name="cottongut-mk02", amount=2},
        {type="item", name="filtration-media", amount=1},
        {type="item", name="fish-egg", amount=2},
        {type="item", name="fish-food-02", amount=1},
        {type="item", name="mukmoux-fat", amount=2},
        {type="item", name="seaweed", amount=2},
        {type="item", name="small-lamp", amount=1},
        {type="item", name="tuuphra-seeds", amount=4},
        {type="item", name="wood-seeds", amount=3},
      },
      results = {
        {type="item", name="cottongut-mk02", amount=2},
        {type="item", name="cottongut-pup-mk02", amount=4},
      },
    },
    ["cottongut-cub-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.11589003591593,
      ingredients = {
        {type="item", name="bedding", amount=1},
        {type="item", name="cobalt-fluoride", amount=2},
        {type="item", name="cottongut", amount=3},
        {type="item", name="cottongut-food-01", amount=1},
        {type="item", name="moondrop-seeds", amount=8},
        {type="item", name="pressured-water-barrel", amount=2},
        {type="item", name="transport-belt", amount=3},
        {type="item", name="yotoi-fruit", amount=37},
      },
      results = {
        {type="item", name="barrel", amount=3},
        {type="item", name="cottongut-pup", amount=18},
        {type="item", name="empty-barrel-milk", amount=2},
      },
    },
    ["cottongut-mature-basic-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 3.5,
      ingredients = {
        {type="item", name="bedding", amount=2},
        {type="item", name="cadaveric-arum-seeds", amount=4},
        {type="item", name="cobalt-fluoride", amount=2},
        {type="item", name="cottongut", amount=7},
        {type="item", name="cottongut-food-01", amount=2},
        {type="item", name="cottongut-pup-mk01", amount=11},
        {type="item", name="fish-food-02", amount=1},
        {type="item", name="grod", amount=6},
        {type="item", name="pressured-water-barrel", amount=5},
        {type="item", name="yaedols", amount=12},
        {type="item", name="yotoi-fruit", amount=34},
      },
      results = {
        {type="item", name="cottongut-mk02", amount=7},
      },
    },
    ["auog-food-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2.6,
      ingredients = {
        {type="item", name="auog-food-01", amount=1},
        {type="item", name="boiler", amount=1},
        {type="item", name="cobalt-fluoride", amount=3},
        {type="item", name="coke", amount=9},
        {type="item", name="fertilizer", amount=3},
        {type="item", name="kicalk", amount=1},
        {type="item", name="powdered-ralesia-seeds", amount=1},
        {type="item", name="quartz-tube", amount=5},
        {type="item", name="raw-fiber", amount=2},
        {type="item", name="sodium-chlorate", amount=2},
        {type="item", name="sodium-silicate", amount=1},
      },
      results = {
        {type="item", name="auog-food-02", amount=13},
      },
    },
    ["auog-maturing-3"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="auog-food-02", amount=4},
        {type="item", name="bedding", amount=1},
        {type="item", name="caged-auog", amount=2},
        {type="item", name="casein", amount=1},
        {type="item", name="cocoon-mk02", amount=6},
        {type="item", name="kicalk", amount=6},
        {type="item", name="lignin", amount=9},
        {type="item", name="native-flora", amount=24},
        {type="item", name="raw-coal", amount=13},
        {type="item", name="refined-natural-gas-barrel", amount=2},
        {type="item", name="vrauks-food-01", amount=5},
      },
      results = {
        {type="item", name="auog", amount=16},
        {type="item", name="barrel", amount=10},
      },
    },
    ["auog-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.4038417662614,
      ingredients = {
        {type="fluid", name="subcritical-water", amount=1557},
        {type="item", name="auog-food-02", amount=1},
        {type="item", name="casein", amount=2},
        {type="item", name="dried-meat", amount=37},
        {type="item", name="guts", amount=3},
      },
      results = {
        {type="item", name="auog", amount=1},
        {type="item", name="auog-mk02", amount=0.00662307962956906},
        {type="item", name="charged-auog", amount=0.132461592591381},
      },
    },
    ["charged-auog"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="unslimed-iron", amount=1},
        {type="item", name="workers-food", amount=2},
      },
      results = {
        {type="item", name="charged-auog", amount=2},
      },
    },
    ["auog-mk02-breeder"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.20186387861795,
      ingredients = {
        {type="item", name="auog-food-01", amount=7},
        {type="item", name="bedding", amount=5},
        {type="item", name="charged-auog", amount=9},
        {type="item", name="cottongut-food-01", amount=2},
        {type="item", name="cottongut-pup", amount=9},
        {type="item", name="empty-planter-box", amount=3},
        {type="item", name="moondrop", amount=9},
        {type="item", name="moss", amount=10},
        {type="item", name="refined-natural-gas-barrel", amount=1},
        {type="item", name="tuuphra-seeds", amount=15},
        {type="item", name="water-barrel", amount=4},
      },
      results = {
        {type="item", name="auog-pup-mk02", amount=6},
        {type="item", name="barrel", amount=4},
      },
    },
    ["auog-mk02-recharge"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="auog-food-02", amount=1},
        {type="item", name="moss", amount=7},
        {type="item", name="refined-natural-gas-canister", amount=49},
      },
      results = {
        {type="item", name="auog-mk02", amount=2},
      },
    },
    ["auog-pooping-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.846658938603941,
      ingredients = {
        {type="item", name="auog-food-02", amount=1},
        {type="item", name="light-oil-canister", amount=2},
        {type="item", name="lignin", amount=13},
        {type="item", name="moss", amount=11},
        {type="item", name="naphtha-barrel", amount=1},
        {type="item", name="purified-syngas-canister", amount=5},
      },
      results = {
        {type="item", name="barrel", amount=4},
        {type="item", name="manure", amount=9},
      },
    },
    ["auog-pup-breeding-3"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.82809838289324,
      ingredients = {
        {type="item", name="auog-food-02", amount=2},
        {type="item", name="bedding", amount=2},
        {type="item", name="guar-seeds", amount=13},
        {type="item", name="kicalk", amount=7},
        {type="item", name="lignin", amount=24},
        {type="item", name="moss", amount=18},
        {type="item", name="naphtha-barrel", amount=3},
        {type="item", name="pink-refined-concrete", amount=3},
        {type="item", name="purified-syngas-canister", amount=4},
        {type="item", name="refined-natural-gas-barrel", amount=2},
      },
      results = {
        {type="item", name="auog-pup", amount=22},
        {type="item", name="barrel", amount=9},
      },
    },
    ["auog-recharge"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.75,
      ingredients = {
        {type="fluid", name="vinyl-acetate", amount=11},
        {type="item", name="auog-food-01", amount=10},
        {type="item", name="bedding", amount=1},
        {type="item", name="condensed-distillate-barrel", amount=2},
      },
      results = {
        {type="item", name="auog", amount=7},
      },
    },
    ["auog-pup-mk02-breeder"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33470890611315,
      ingredients = {
        {type="fluid", name="water-saline", amount=228},
        {type="item", name="auog-food-01", amount=3},
        {type="item", name="auog-pup-mk02", amount=2},
        {type="item", name="bedding", amount=4},
        {type="item", name="energy-drink", amount=4},
        {type="item", name="ethylene-canister", amount=21},
        {type="item", name="grade-3-lead", amount=1},
        {type="item", name="workers-food", amount=13},
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
      energy_required_multiplier = 1.16,
      ingredients = {
        {type="fluid", name="pressured-water", amount=413},
        {type="fluid", name="water", amount=129},
        {type="item", name="coarse", amount=4},
        {type="item", name="fertilizer", amount=4},
        {type="item", name="gravel", amount=2},
        {type="item", name="limestone", amount=1},
        {type="item", name="moondrop-seeds", amount=8},
        {type="item", name="raw-fiber", amount=14},
      },
      results = {
        {type="item", name="ralesia", amount=29},
      },
    },
    ["ralesia-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.494927287045691,
      ingredients = {
        {type="fluid", name="pressured-water", amount=1073},
        {type="fluid", name="steam", amount=327},
        {type="item", name="coarse", amount=6},
        {type="item", name="fertilizer", amount=2},
        {type="item", name="ralesia", amount=2},
        {type="item", name="ralesia-seeds", amount=8},
      },
      results = {
        {type="item", name="ralesia", amount=1},
        {type="item", name="ralesia-mk02", amount=0.00247463643522845},
      },
    },
    ["ralesia-seeds-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.875,
      ingredients = {
        {type="item", name="auog-pup", amount=3},
        {type="item", name="ralesia", amount=12},
        {type="item", name="ralesia-mk02", amount=2},
        {type="item", name="salt", amount=6},
        {type="item", name="ulric-food-01", amount=1},
        {type="item", name="water-barrel", amount=6},
      },
      results = {
        {type="item", name="ralesia-seeds-mk02", amount=7},
      },
    },
    ["ralesia-mk02-breeder"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.76280626215328,
      ingredients = {
        {type="item", name="cottongut-food-01", amount=1},
        {type="item", name="fawogae-mk02", amount=4},
        {type="item", name="fertilizer", amount=21},
        {type="item", name="ralesia-seeds-mk02", amount=4},
      },
      results = {
        {type="item", name="fawogae-spore-mk02", amount=2},
        {type="item", name="ralesia-mk02", amount=7},
        {type="item", name="ralesia-seeds-mk02", amount=2},
      },
    },
    ["vrauks-cocoon-3"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.08759161709509,
      ingredients = {
        {type="item", name="bio-oil-canister", amount=1},
        {type="item", name="cottongut-food-01", amount=5},
        {type="item", name="kicalk", amount=3},
        {type="item", name="lignin", amount=1},
        {type="item", name="vrauks-food-02", amount=1},
        {type="item", name="water-barrel", amount=6},
      },
      results = {
        {type="item", name="barrel", amount=4},
        {type="item", name="cocoon", amount=22},
      },
    },
    ["vrauks-food-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.83333333333333,
      ingredients = {
        {type="fluid", name="coal-gas", amount=647},
        {type="item", name="auog-food-01", amount=1},
        {type="item", name="biomass", amount=198},
        {type="item", name="bones", amount=1},
        {type="item", name="casein", amount=14},
        {type="item", name="cellulose", amount=4},
        {type="item", name="dried-grods", amount=1},
        {type="item", name="lignin", amount=12},
        {type="item", name="niobium-plate", amount=1},
        {type="item", name="pcb1", amount=1},
        {type="item", name="ralesia-seeds-mk02", amount=1},
        {type="item", name="tuuphra", amount=1},
      },
      results = {
        {type="item", name="vrauks-food-02", amount=11},
      },
    },
    ["vrauks-mk03"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 3.13850140336788,
      ingredients = {
        {type="item", name="alien-sample-02", amount=1},
        {type="item", name="auog-food-02", amount=5},
        {type="item", name="cocoon-mk02", amount=107},
        {type="item", name="cottongut-food-01", amount=13},
        {type="item", name="cytostatics", amount=6},
        {type="item", name="vrauks-food-02", amount=6},
      },
      results = {
        {type="item", name="barrel", amount=16},
        {type="item", name="vrauks-mk02", amount=8},
        {type="item", name="vrauks-mk03", amount=0.0125315281257299},
      },
    },
    ["vrauks-3"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-food-02", amount=1},
        {type="item", name="bedding", amount=1},
        {type="item", name="cocoon-mk02", amount=9},
        {type="item", name="naphtha-barrel", amount=2},
        {type="item", name="native-flora", amount=15},
        {type="item", name="vrauks-food-02", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=3},
        {type="item", name="vrauks", amount=8},
      },
    },
    ["vrauks-mk03-breeder"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.05241200641898,
      ingredients = {
        {type="item", name="auog-food-02", amount=4},
        {type="item", name="clay-pit-mk01", amount=1},
        {type="item", name="cottongut-food-01", amount=11},
        {type="item", name="cytostatics", amount=2},
        {type="item", name="ethanol-barrel", amount=1},
        {type="item", name="sea-sponge-mk02", amount=2},
        {type="item", name="urea", amount=32},
        {type="item", name="vrauks-mk03", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="vrauks-mk03", amount=3},
      },
    },
    ["vrauks-mk03-cocoon"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.27011887420448,
      ingredients = {
        {type="item", name="auog-food-02", amount=1},
        {type="item", name="bedding", amount=1},
        {type="item", name="copper-coating", amount=2},
        {type="item", name="mibc-barrel", amount=1},
        {type="item", name="refined-natural-gas-barrel", amount=1},
        {type="item", name="sea-sponge", amount=5},
        {type="item", name="sea-sponge-sprouts", amount=1},
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
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="arqad-codex", amount=12},
        {type="item", name="cytostatics", amount=4},
        {type="item", name="earth-sunflower-sample", amount=3},
        {type="item", name="glass", amount=353},
      },
      results = {
        {type="item", name="yotoi", amount=4},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="yotoi", amount=4},
      },
      results = {
        {type="item", name="yotoi-seeds", amount=3},
      },
    },
    ["yotoi-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2.25,
      ingredients = {
        {type="fluid", name="tar", amount=267},
        {type="item", name="pitch-barrel", amount=1},
        {type="item", name="pure-sand", amount=8},
        {type="item", name="yotoi", amount=2},
        {type="item", name="yotoi-fruit", amount=4},
      },
      results = {
        {type="item", name="yotoi", amount=11},
      },
    },
    ["yotoi-fruit-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.6,
      ingredients = {
        {type="item", name="coal-dust", amount=2},
        {type="item", name="sand", amount=2},
        {type="item", name="stone", amount=10},
      },
      results = {
        {type="item", name="yotoi-fruit", amount=3},
      },
    },
    ["fawogae-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.533333333333333,
      ingredients = {
        {type="fluid", name="water", amount=104},
        {type="item", name="fungal-substrate", amount=1},
        {type="item", name="ore-aluminium", amount=2},
      },
      results = {
        {type="item", name="fawogae", amount=8},
      },
    },
    ["fawogae-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.67754447991506,
      ingredients = {
        {type="fluid", name="oxygen", amount=115},
        {type="fluid", name="pressured-water", amount=278},
        {type="fluid", name="water", amount=766},
        {type="item", name="coarse", amount=12},
        {type="item", name="fawogae", amount=2},
        {type="item", name="fertilizer", amount=19},
        {type="item", name="offshore-pump", amount=1},
        {type="item", name="pure-sand", amount=31},
        {type="item", name="ralesia-seeds", amount=6},
      },
      results = {
        {type="item", name="fawogae", amount=1},
        {type="item", name="fawogae-mk02", amount=0.00838772239957532},
      },
    },
    ["fawogae-mk02-breeder"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 3.6,
      ingredients = {
        {type="item", name="fawogae-spore-mk02", amount=20},
        {type="item", name="ralesia", amount=4},
        {type="item", name="xyhiphoe", amount=1},
      },
      results = {
        {type="item", name="fawogae-mk02", amount=9},
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
      energy_required_multiplier = 0.666666666666667,
      ingredients = {
        {type="item", name="coke", amount=7},
        {type="item", name="fawogae", amount=20},
        {type="item", name="fawogae-spore", amount=4},
        {type="item", name="fungal-substrate-03", amount=1},
        {type="item", name="pyrite", amount=1},
      },
      results = {
        {type="item", name="yaedols", amount=4},
      },
    },
    ["yaedols-spore-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="yaedols", amount=63},
      },
      results = {
        {type="item", name="yaedols-spores-mk02", amount=4},
      },
    },
    ["yaedols-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.57013755009276,
      ingredients = {
        {type="fluid", name="steam", amount=573},
        {type="item", name="albumin", amount=3},
        {type="item", name="flamethrower-ammo", amount=1},
        {type="item", name="wood", amount=26},
        {type="item", name="yaedols", amount=3},
      },
      results = {
        {type="item", name="yaedols", amount=1},
        {type="item", name="yaedols-mk02", amount=0.00785068775046382},
      },
    },
    ["yaedols-mk02-breeder"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="item", name="cobalt-extract", amount=6},
        {type="item", name="ulric", amount=2},
        {type="item", name="yaedols", amount=135},
        {type="item", name="yaedols-spores", amount=305},
      },
      results = {
        {type="item", name="yaedols-mk02", amount=3},
      },
    },
    ["brain-food-01"] = {
      mode = "input-preserved-untransformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="processed-iron-ore", amount=585},
      },
      results = {
      },
    },
    ["purex-antimony-void"] = {
      mode = "input-preserved-untransformed",
      science_level = 5,
      energy_required_multiplier = 1.71043583894469,
      ingredients = {
        {type="fluid", name="methanal", amount=9525},
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

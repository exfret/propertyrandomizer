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
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-ore", amount=12},
      },
      results = {
        {type="item", name="copper-cable", amount=2},
      },
    },
    ["iron-stick"] = {
      mode = "input-preserved-unmodified",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-plate", amount=1},
      },
      results = {
        {type="item", name="iron-stick", amount=2},
      },
    },
    ["iron-gear-wheel"] = {
      mode = "softmax-semantic-substitution",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-stick", amount=4},
      },
      results = {
        {type="item", name="iron-gear-wheel", amount=1},
      },
    },
    ["bolts"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=3},
        {type="item", name="copper-cable", amount=3},
        {type="item", name="iron-stick", amount=4},
      },
      results = {
        {type="item", name="small-parts-01", amount=2},
      },
    },
    ["burner-inserter"] = {
      mode = "softmax-semantic-substitution",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-stick", amount=9},
        {type="item", name="small-parts-01", amount=2},
      },
      results = {
        {type="item", name="burner-inserter", amount=1},
      },
    },
    ["inductor1-2"] = {
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=73},
      },
      results = {
        {type="item", name="soil", amount=16},
      },
    },
    ["stone-brick"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 0,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=3},
        {type="item", name="stone-brick", amount=57},
      },
      results = {
        {type="item", name="underground-belt", amount=4},
      },
    },
    ["lab"] = {
      mode = "softmax-semantic-substitution",
      science_level = 0,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="small-parts-01", amount=19},
        {type="item", name="underground-belt", amount=1},
      },
      results = {
        {type="item", name="lab", amount=2},
      },
    },
    ["pipe"] = {
      mode = "softmax-semantic-substitution",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-stick", amount=2},
      },
      results = {
        {type="item", name="pipe", amount=1},
      },
    },
    ["pipe-to-ground"] = {
      mode = "softmax-semantic-substitution",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=1},
        {type="item", name="copper-plate", amount=5},
      },
      results = {
        {type="item", name="pipe-to-ground", amount=2},
      },
    },
    ["small-electric-pole"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "input-preserved-unmodified",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="pipe", amount=4},
        {type="item", name="stone-furnace", amount=1},
      },
      results = {
        {type="item", name="boiler", amount=1},
      },
    },
    ["steam-engine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=9},
        {type="item", name="iron-stick", amount=18},
        {type="item", name="small-parts-01", amount=8},
      },
      results = {
        {type="item", name="steam-engine", amount=1},
      },
    },
    ["burner-mining-drill"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 0,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="boiler", amount=2},
        {type="item", name="stone-furnace", amount=31},
      },
      results = {
        {type="item", name="offshore-pump", amount=3},
      },
    },
    ["soil-extractor-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=92},
        {type="item", name="offshore-pump", amount=3},
        {type="item", name="pipe", amount=27},
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="soil-extractor-mk01", amount=1},
      },
    },
    ["wpu-mk01"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
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
      mode = "input-preserved-unmodified",
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
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="inductor1", amount=3},
        {type="item", name="pipe", amount=8},
        {type="item", name="transport-belt", amount=7},
      },
      results = {
        {type="item", name="assembling-machine-1", amount=1},
      },
    },
    ["bricks-to-stone"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="stone-brick", amount=4},
      },
      results = {
        {type="item", name="stone", amount=8},
      },
    },
    ["grade-2-copper"] = {
      mode = "input-preserved-unmodified",
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
      mode = "input-preserved-unmodified",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-2-copper", amount=5},
      },
      results = {
        {type="item", name="copper-plate", amount=2},
      },
    },
    ["grade-1-copper-crush"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "input-preserved-unmodified",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="wood", amount=10},
      },
      results = {
        {type="item", name="raw-fiber", amount=2},
      },
    },
    ["glass-1"] = {
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=2600},
      },
      results = {
        {type="item", name="glass", amount=5},
      },
    },
    ["grade-1-iron-crush"] = {
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-ore", amount=7},
      },
      results = {
        {type="item", name="iron-plate", amount=1},
      },
    },
    ["gravel-to-sand"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "input-preserved-unmodified",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="stone", amount=4},
      },
      results = {
        {type="item", name="gravel", amount=3},
      },
    },
    ["gun-turret"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="log", amount=12},
        {type="item", name="offshore-pump", amount=1},
        {type="item", name="pipe", amount=25},
      },
      results = {
        {type="item", name="gun-turret", amount=1},
      },
    },
    ["muddy-sludge"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="wood", amount=3},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=100},
      },
    },
    ["soil-washing"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=600},
        {type="item", name="native-flora", amount=32},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=100},
        {type="item", name="sand", amount=10},
      },
    },
    ["pressured-water"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=500},
      },
      results = {
        {type="fluid", name="pressured-water", amount=500},
      },
    },
    ["repair-pack"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="pipe", amount=5},
        {type="item", name="wooden-chest", amount=7},
      },
      results = {
        {type="item", name="repair-pack", amount=1},
      },
    },
    ["seaweed-1"] = {
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ash", amount=33},
        {type="item", name="copper-cable", amount=27},
        {type="item", name="empty-planter-box", amount=3},
        {type="item", name="soil", amount=16},
      },
      results = {
        {type="item", name="shotgun", amount=1},
      },
    },
    ["submachine-gun"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=9},
        {type="item", name="iron-gear-wheel", amount=5},
        {type="item", name="raw-fiber", amount=14},
      },
      results = {
        {type="item", name="submachine-gun", amount=1},
      },
    },
    ["small-lamp"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=3},
        {type="item", name="copper-ore", amount=9},
        {type="item", name="glass", amount=2},
        {type="item", name="iron-stick", amount=2},
      },
      results = {
        {type="item", name="small-lamp", amount=1},
      },
    },
    ["tailings-pond"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=19},
        {type="item", name="small-parts-01", amount=4},
        {type="item", name="stone-brick", amount=100},
      },
      results = {
        {type="item", name="tailings-pond", amount=1},
      },
    },
    ["tin-plate-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ore-zinc", amount=36},
      },
      results = {
        {type="item", name="tin-plate", amount=4},
      },
    },
    ["acetylene"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 0.964887625525792,
      ingredients = {
        {type="fluid", name="pressured-water", amount=242},
        {type="item", name="lime", amount=5},
      },
      results = {
        {type="fluid", name="acetylene", amount=97},
        {type="fluid", name="slacked-lime", amount=24},
      },
    },
    ["coal-gas"] = {
      mode = "input-preserved-unmodified",
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
      mode = "input-preserved-unmodified",
      science_level = 1,
      energy_required_multiplier = 2.91016268073662,
      ingredients = {
        {type="item", name="wood", amount=28},
      },
      results = {
        {type="fluid", name="coal-gas", amount=28},
        {type="fluid", name="tar", amount=83},
        {type="item", name="coal", amount=28},
        {type="item", name="iron-oxide", amount=1},
      },
    },
    ["syngas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=424},
        {type="fluid", name="water", amount=100},
      },
      results = {
        {type="fluid", name="syngas", amount=70},
        {type="fluid", name="tar", amount=30},
        {type="item", name="ash", amount=1},
      },
    },
    ["coal-gas-from-coke"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="limestone", amount=30},
      },
      results = {
        {type="fluid", name="coal-gas", amount=20},
        {type="fluid", name="tar", amount=20},
        {type="item", name="ash", amount=1},
      },
    },
    ["distilled-raw-coal"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 4.40616995472867,
      ingredients = {
        {type="item", name="iron-ore", amount=42},
      },
      results = {
        {type="fluid", name="coal-gas", amount=250},
        {type="fluid", name="tar", amount=125},
        {type="item", name="coal", amount=13},
        {type="item", name="iron-oxide", amount=1},
      },
    },
    ["aluminium-plate-1"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="limestone", amount=8},
      },
      results = {
        {type="item", name="graphite", amount=2},
      },
    },
    ["clay"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coke", amount=1},
        {type="item", name="raw-coal", amount=69},
      },
      results = {
        {type="item", name="ceramic", amount=5},
      },
    },
    ["duralumin-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="copper-ore", amount=34},
        {type="item", name="lead-plate", amount=7},
      },
      results = {
        {type="item", name="duralumin", amount=2},
      },
    },
    ["tinned-cable"] = {
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="iron-stick", amount=8},
        {type="item", name="limestone", amount=158},
      },
      results = {
        {type="item", name="engine-unit", amount=2},
      },
    },
    ["iron-oxide-smelting"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ore-zinc", amount=10},
      },
      results = {
        {type="item", name="lead-plate", amount=1},
      },
    },
    ["moondrop-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="capacitor1", amount=47},
        {type="item", name="glass", amount=2},
        {type="item", name="titanium-plate", amount=29},
      },
      results = {
        {type="item", name="moondrop-codex", amount=1},
      },
    },
    ["solder-0"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="tin-plate", amount=2},
        {type="item", name="titanium-plate", amount=4},
      },
      results = {
        {type="item", name="solder", amount=1},
      },
    },
    ["tar-quenching"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=417},
        {type="fluid", name="syngas", amount=567},
      },
      results = {
        {type="fluid", name="flue-gas", amount=150},
        {type="fluid", name="tailings", amount=500},
        {type="fluid", name="water-saline", amount=250},
        {type="item", name="soot", amount=2},
      },
    },
    ["chlorine"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water-saline", amount=100},
      },
      results = {
        {type="fluid", name="chlorine", amount=20},
        {type="fluid", name="hydrogen", amount=20},
        {type="item", name="sodium-hydroxide", amount=2},
      },
    },
    ["hydrogen"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=250},
      },
      results = {
        {type="fluid", name="hydrogen", amount=200},
        {type="fluid", name="oxygen", amount=100},
      },
    },
    ["muddy-sludge-void-electrolyzer"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "input-preserved-unmodified",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="tailings", amount=100},
      },
      results = {
        {type="fluid", name="acidgas", amount=15},
        {type="item", name="tailings-dust", amount=4},
      },
    },
    ["ash-separation"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 9.94068558470902,
      ingredients = {
        {type="item", name="coke", amount=150},
      },
      results = {
        {type="item", name="coal-dust", amount=5},
        {type="item", name="iron-oxide", amount=0.469004258293482},
        {type="item", name="soot", amount=2},
      },
    },
    ["soot-separation"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 9.65640888256403,
      ingredients = {
        {type="item", name="bolts", amount=155},
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="limestone", amount=48},
      },
      results = {
        {type="item", name="coal-dust", amount=5},
        {type="item", name="ore-tin", amount=1},
        {type="item", name="ore-titanium", amount=1},
      },
    },
    ["extract-sulfur"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="acidgas", amount=100},
      },
      results = {
        {type="item", name="sulfur", amount=2},
      },
    },
    ["titanium-plate-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ore-tin", amount=37},
      },
      results = {
        {type="item", name="titanium-plate", amount=4},
      },
    },
    ["water-from-oxygen-and-hydrogen"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=200},
        {type="fluid", name="pressured-water", amount=467},
      },
      results = {
        {type="fluid", name="water", amount=300},
      },
    },
    ["zinc-plate-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ore-lead", amount=25},
      },
      results = {
        {type="item", name="zinc-plate", amount=4},
      },
    },
    ["py-tank-1000"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="light-oil-barrel", amount=5},
        {type="item", name="pressured-air-barrel", amount=2},
        {type="item", name="water-barrel", amount=14},
      },
      results = {
        {type="item", name="py-tank-1000", amount=1},
      },
    },
    ["py-tank-3000"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="concrete", amount=22},
        {type="item", name="copper-cable", amount=419},
        {type="item", name="small-parts-01", amount=8},
      },
      results = {
        {type="item", name="py-tank-3000", amount=1},
      },
    },
    ["py-tank-4000"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=35},
        {type="item", name="iron-chest", amount=3},
        {type="item", name="iron-plate", amount=9},
      },
      results = {
        {type="item", name="py-tank-4000", amount=1},
      },
    },
    ["py-tank-8000"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=46},
        {type="item", name="bolts", amount=223},
        {type="item", name="iron-plate", amount=22},
        {type="item", name="small-parts-01", amount=5},
      },
      results = {
        {type="item", name="py-tank-8000", amount=1},
      },
    },
    ["py-tank-10000"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="hazard-concrete", amount=166},
        {type="item", name="limestone", amount=867},
        {type="item", name="titanium-plate", amount=89},
      },
      results = {
        {type="item", name="py-tank-10000", amount=1},
      },
    },
    ["py-tank-1500"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=93},
        {type="item", name="concrete", amount=22},
        {type="item", name="iron-plate", amount=11},
      },
      results = {
        {type="item", name="py-tank-1500", amount=1},
      },
    },
    ["py-tank-6500"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="py-check-valve", amount=16},
        {type="item", name="repair-pack", amount=2},
        {type="item", name="soot", amount=2},
        {type="item", name="titanium-plate", amount=34},
      },
      results = {
        {type="item", name="py-tank-6500", amount=1},
      },
    },
    ["py-tank-7000"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="py-tank-3000", amount=3},
        {type="item", name="small-parts-01", amount=8},
        {type="item", name="steam-engine", amount=16},
        {type="item", name="titanium-plate", amount=23},
      },
      results = {
        {type="item", name="py-tank-7000", amount=2},
      },
    },
    ["py-tank-5000"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="cellulose", amount=19},
        {type="item", name="glass", amount=30},
        {type="item", name="py-tank-3000", amount=4},
        {type="item", name="py-tank-4000", amount=2},
      },
      results = {
        {type="item", name="py-tank-5000", amount=3},
      },
    },
    ["py-tank-9000"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="agar", amount=131},
        {type="item", name="empty-petri-dish", amount=243},
        {type="item", name="ore-aluminium", amount=152},
        {type="item", name="py-tank-1500", amount=2},
      },
      results = {
        {type="item", name="py-tank-9000", amount=3},
      },
    },
    ["chloride-void-iron-oxide"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "input-preserved-unmodified",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=400},
      },
      results = {
        {type="item", name="limestone", amount=8},
      },
    },
    ["gun-powder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water-saline", amount=100},
        {type="item", name="calcium-carbide", amount=2},
        {type="item", name="sulfur", amount=1},
      },
      results = {
        {type="item", name="gunpowder", amount=5},
      },
    },
    ["tar-distilation"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=471},
      },
      results = {
        {type="fluid", name="aromatics", amount=100},
        {type="fluid", name="carbon-dioxide", amount=100},
        {type="fluid", name="flue-gas", amount=500},
        {type="item", name="rich-clay", amount=1},
      },
    },
    ["treated-wood"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="tar", amount=297},
        {type="item", name="wood", amount=1},
      },
      results = {
        {type="item", name="treated-wood", amount=2},
      },
    },
    ["calcium-carbide"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="sand", amount=7},
        {type="item", name="soil", amount=12},
      },
      results = {
        {type="item", name="calcium-carbide", amount=10},
      },
    },
    ["sand-brick"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="rich-clay", amount=35},
        {type="item", name="sand", amount=30},
      },
      results = {
        {type="item", name="stone-brick", amount=20},
      },
    },
    ["tar-to-carbolic"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 3.05207676752155,
      ingredients = {
        {type="fluid", name="tar", amount=288},
        {type="fluid", name="water", amount=3170},
        {type="item", name="raw-coal", amount=3},
      },
      results = {
        {type="fluid", name="carbolic-oil", amount=29},
        {type="fluid", name="coal-gas", amount=101},
        {type="item", name="ash", amount=3},
        {type="item", name="rich-clay", amount=1},
      },
    },
    ["Moss-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=100},
        {type="fluid", name="pressured-water", amount=731},
        {type="item", name="stone", amount=20},
      },
      results = {
        {type="item", name="moss", amount=16},
      },
    },
    ["Moss-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=100},
        {type="fluid", name="water", amount=878},
      },
      results = {
        {type="item", name="moss", amount=8},
      },
    },
    ["aromatics-to-plastic"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="aromatics", amount=50},
        {type="fluid", name="water", amount=1041},
      },
      results = {
        {type="item", name="plastic-bar", amount=1},
      },
    },
    ["log1"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="wood-seedling", amount=3},
      },
      results = {
        {type="item", name="log", amount=3},
      },
    },
    ["wood-seeds"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="limestone", amount=10},
      },
      results = {
        {type="item", name="wood-seeds", amount=4},
      },
    },
    ["wood-seedling"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="moss", amount=5},
        {type="item", name="wood-seeds", amount=1},
      },
      results = {
        {type="item", name="wood-seedling", amount=3},
      },
    },
    ["log2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=179},
        {type="item", name="wood-seedling", amount=3},
      },
      results = {
        {type="item", name="log", amount=4},
      },
    },
    ["log3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=179},
        {type="item", name="ash", amount=30},
        {type="item", name="wood-seedling", amount=3},
      },
      results = {
        {type="item", name="log", amount=6},
      },
    },
    ["steel-plate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coke", amount=5},
        {type="item", name="iron-ore", amount=20},
        {type="item", name="seaweed", amount=4},
      },
      results = {
        {type="item", name="steel-plate", amount=1},
      },
    },
    ["bio-container"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coke", amount=3},
        {type="item", name="iron-plate", amount=5},
        {type="item", name="tin-plate", amount=2},
        {type="item", name="zinc-plate", amount=1},
      },
      results = {
        {type="item", name="bio-container", amount=1},
      },
    },
    ["cage"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-gear-wheel", amount=4},
        {type="item", name="iron-plate", amount=43},
        {type="item", name="tin-plate", amount=5},
      },
      results = {
        {type="item", name="cage", amount=1},
      },
    },
    ["empty-jerry-can"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-plate", amount=5},
        {type="item", name="plastic-bar", amount=2},
      },
      results = {
        {type="item", name="empty-fuel-canister", amount=1},
      },
    },
    ["shotgun-shell"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=4},
        {type="item", name="kerogen", amount=10},
        {type="item", name="limestone", amount=19},
      },
      results = {
        {type="item", name="shotgun-shell", amount=3},
      },
    },
    ["firearm-magazine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="gravel", amount=94},
        {type="item", name="iron-plate", amount=5},
        {type="item", name="ore-nickel", amount=41},
      },
      results = {
        {type="item", name="firearm-magazine", amount=5},
      },
    },
    ["fwf-mk01"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=1},
        {type="item", name="boiler", amount=4},
        {type="item", name="cellulose", amount=21},
        {type="item", name="coal-dust", amount=3},
        {type="item", name="lab", amount=1},
        {type="item", name="limestone", amount=170},
        {type="item", name="treated-wood", amount=7},
      },
      results = {
        {type="item", name="moss-farm-mk01", amount=1},
      },
    },
    ["sap-extractor-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=15},
        {type="item", name="empty-planter-box", amount=5},
        {type="item", name="lab", amount=1},
        {type="item", name="seaweed", amount=138},
        {type="item", name="soil", amount=100},
        {type="item", name="stone-furnace", amount=33},
        {type="item", name="wooden-chest", amount=15},
      },
      results = {
        {type="item", name="sap-extractor-mk01", amount=1},
      },
    },
    ["seaweed-crop-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=4},
        {type="item", name="iron-plate", amount=17},
        {type="item", name="kerogen", amount=45},
        {type="item", name="lead-plate", amount=8},
        {type="item", name="small-parts-01", amount=4},
        {type="item", name="tinned-cable", amount=38},
      },
      results = {
        {type="item", name="seaweed-crop-mk01", amount=1},
      },
    },
    ["moondrop-greenhouse-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ore-lead", amount=32},
        {type="item", name="ore-titanium", amount=370},
        {type="item", name="stone-brick", amount=268},
        {type="item", name="stone-furnace", amount=58},
        {type="item", name="titanium-plate", amount=12},
      },
      results = {
        {type="item", name="moondrop-greenhouse-mk01", amount=1},
      },
    },
    ["iron-chest"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=559},
        {type="item", name="iron-plate", amount=25},
        {type="item", name="tin-plate", amount=10},
      },
      results = {
        {type="item", name="storage-tank", amount=1},
      },
    },
    ["light-armor"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=1},
        {type="item", name="iron-plate", amount=56},
        {type="item", name="wood", amount=283},
      },
      results = {
        {type="item", name="light-armor", amount=1},
      },
    },
    ["car"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="capacitor1", amount=356},
        {type="item", name="cellulose", amount=46},
        {type="item", name="lime", amount=40},
        {type="item", name="titanium-plate", amount=6},
      },
      results = {
        {type="item", name="car", amount=1},
      },
    },
    ["pump"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="iron-plate", amount=10},
        {type="item", name="iron-stick", amount=4},
        {type="item", name="steam-engine", amount=7},
      },
      results = {
        {type="item", name="pump", amount=2},
      },
    },
    ["small-electric-pole-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coke", amount=34},
        {type="item", name="iron-stick", amount=3},
      },
      results = {
        {type="item", name="small-electric-pole", amount=3},
      },
    },
    ["py-gas-vent"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-ore", amount=193},
        {type="item", name="empty-planter-box", amount=5},
        {type="item", name="stone-brick", amount=5},
      },
      results = {
        {type="item", name="py-gas-vent", amount=1},
      },
    },
    ["py-sinkhole"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=4},
        {type="item", name="limestone", amount=216},
        {type="item", name="moss", amount=48},
        {type="item", name="native-flora", amount=728},
        {type="item", name="rich-clay", amount=3},
      },
      results = {
        {type="item", name="py-sinkhole", amount=1},
      },
    },
    ["retorter"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="agar", amount=46},
        {type="item", name="bolts", amount=14},
        {type="item", name="iron-plate", amount=22},
        {type="item", name="transport-belt", amount=55},
      },
      results = {
        {type="item", name="retorter", amount=1},
      },
    },
    ["steel-chest"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-plate", amount=40},
      },
      results = {
        {type="item", name="steel-chest", amount=1},
      },
    },
    ["tree"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-stick", amount=9},
        {type="item", name="ore-nickel", amount=22},
      },
      results = {
        {type="item", name="tree-mk01", amount=1},
      },
    },
    ["advanced-foundry-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boiler", amount=1},
        {type="item", name="iron-gear-wheel", amount=7},
        {type="item", name="iron-ore", amount=81},
        {type="item", name="pipe", amount=25},
        {type="item", name="underground-belt", amount=2},
      },
      results = {
        {type="item", name="advanced-foundry-mk01", amount=1},
      },
    },
    ["borax-mine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="advanced-foundry-mk01", amount=5},
        {type="item", name="py-check-valve", amount=26},
        {type="item", name="py-gas-vent", amount=2},
        {type="item", name="soil", amount=726},
        {type="item", name="submachine-gun", amount=2},
      },
      results = {
        {type="item", name="borax-mine", amount=2},
      },
    },
    ["distilator"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boiler", amount=16},
        {type="item", name="copper-cable", amount=22},
        {type="item", name="copper-ore", amount=179},
        {type="item", name="inductor1", amount=3},
        {type="item", name="lab", amount=1},
        {type="item", name="wood", amount=29},
      },
      results = {
        {type="item", name="distilator", amount=1},
      },
    },
    ["fluid-drill-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=1},
        {type="item", name="boiler", amount=9},
        {type="item", name="distilator", amount=1},
        {type="item", name="inductor1", amount=19},
        {type="item", name="iron-plate", amount=47},
        {type="item", name="lab", amount=2},
      },
      results = {
        {type="item", name="fluid-drill-mk01", amount=2},
      },
    },
    ["gasifier"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ash", amount=45},
        {type="item", name="burner-inserter", amount=1},
        {type="item", name="copper-plate", amount=20},
        {type="item", name="inductor1", amount=5},
        {type="item", name="iron-stick", amount=76},
        {type="item", name="soil-extractor-mk01", amount=1},
      },
      results = {
        {type="item", name="glassworks-mk01", amount=1},
      },
    },
    ["hpf"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=27},
        {type="item", name="iron-gear-wheel", amount=5},
        {type="item", name="soil", amount=75},
        {type="item", name="stone-brick", amount=20},
        {type="item", name="stone-furnace", amount=28},
        {type="item", name="transport-belt", amount=19},
      },
      results = {
        {type="item", name="hpf", amount=1},
      },
    },
    ["jaw-crusher"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="bolts", amount=115},
        {type="item", name="burner-inserter", amount=7},
        {type="item", name="fluid-drill-mk01", amount=2},
        {type="item", name="steel-plate", amount=85},
      },
      results = {
        {type="item", name="jaw-crusher", amount=3},
      },
    },
    ["solid-separator"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="copper-plate", amount=519},
        {type="item", name="pipe", amount=193},
        {type="item", name="small-parts-01", amount=94},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="transport-belt", amount=19},
      },
      results = {
        {type="item", name="solid-separator", amount=2},
      },
    },
    ["tar-processing-unit"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bolts", amount=61},
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="inductor1", amount=13},
        {type="item", name="iron-stick", amount=76},
        {type="item", name="soil", amount=1725},
        {type="item", name="stone-brick", amount=9},
      },
      results = {
        {type="item", name="tar-processing-unit", amount=2},
      },
    },
    ["washer"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=4},
        {type="item", name="inductor1", amount=6},
        {type="item", name="lab", amount=2},
        {type="item", name="seaweed", amount=144},
        {type="item", name="small-electric-pole", amount=32},
        {type="item", name="stone-furnace", amount=60},
      },
      results = {
        {type="item", name="washer", amount=3},
      },
    },
    ["evaporator"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="advanced-foundry-mk01", amount=6},
        {type="item", name="iron-plate", amount=201},
        {type="item", name="lab", amount=1},
        {type="item", name="submachine-gun", amount=1},
        {type="item", name="titanium-plate", amount=43},
      },
      results = {
        {type="item", name="evaporator", amount=1},
      },
    },
    ["quenching-tower"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="limestone", amount=759},
        {type="item", name="offshore-pump", amount=4},
        {type="item", name="small-electric-pole", amount=98},
        {type="item", name="stone-brick", amount=195},
        {type="item", name="transport-belt", amount=6},
      },
      results = {
        {type="item", name="quenching-tower", amount=1},
      },
    },
    ["clay-pit-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="iron-chest", amount=4},
        {type="item", name="limestone", amount=611},
        {type="item", name="washer", amount=2},
        {type="item", name="wood", amount=67},
        {type="item", name="wooden-chest", amount=80},
      },
      results = {
        {type="item", name="clay-pit-mk01", amount=3},
      },
    },
    ["electronics-factory-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coal-dust", amount=25},
        {type="item", name="distilator", amount=1},
        {type="item", name="offshore-pump", amount=2},
        {type="item", name="ore-titanium", amount=151},
        {type="item", name="soil-extractor-mk01", amount=4},
        {type="item", name="stone-wall", amount=70},
      },
      results = {
        {type="item", name="electronics-factory-mk01", amount=1},
      },
    },
    ["pulp-mill-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="bolts", amount=198},
        {type="item", name="coal", amount=84},
        {type="item", name="iron-ore", amount=313},
        {type="item", name="lab", amount=9},
        {type="item", name="soil-extractor-mk01", amount=4},
        {type="item", name="transport-belt", amount=19},
      },
      results = {
        {type="item", name="pulp-mill-mk01", amount=3},
      },
    },
    ["chipshooter-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boiler", amount=16},
        {type="item", name="formica", amount=43},
        {type="item", name="hpf", amount=3},
        {type="item", name="small-parts-01", amount=100},
        {type="item", name="soil", amount=546},
        {type="item", name="stone", amount=208},
      },
      results = {
        {type="item", name="chipshooter-mk01", amount=1},
      },
    },
    ["pcb-factory-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=106},
        {type="item", name="iron-gear-wheel", amount=36},
        {type="item", name="log", amount=164},
        {type="item", name="retorter", amount=1},
        {type="item", name="soil-extractor-mk01", amount=14},
        {type="item", name="vacuum-pump-mk01", amount=1},
      },
      results = {
        {type="item", name="pcb-factory-mk01", amount=1},
      },
    },
    ["anthracene-oil-creosote"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=185},
      },
      results = {
        {type="fluid", name="creosote", amount=20},
      },
    },
    ["gravel-saline-water"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="sand", amount=9},
      },
      results = {
        {type="fluid", name="water-saline", amount=50},
      },
    },
    ["sulfur-void-tar"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "input-preserved-unmodified",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="stone", amount=10},
      },
      results = {
        {type="fluid", name="water-saline", amount=50},
      },
    },
    ["biofactory-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boiler", amount=39},
        {type="item", name="concrete", amount=30},
        {type="item", name="py-tank-3000", amount=3},
        {type="item", name="sodium-hydroxide", amount=513},
        {type="item", name="steel-plate", amount=15},
        {type="item", name="stone-brick", amount=134},
        {type="item", name="tin-plate", amount=13},
      },
      results = {
        {type="item", name="biofactory-mk01", amount=1},
      },
    },
    ["botanical-nursery"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="burner-inserter", amount=3},
        {type="item", name="capacitor1", amount=5},
        {type="item", name="concrete", amount=32},
        {type="item", name="glass", amount=10},
        {type="item", name="lab", amount=3},
        {type="item", name="titanium-plate", amount=11},
        {type="item", name="washer", amount=2},
      },
      results = {
        {type="item", name="botanical-nursery", amount=1},
      },
    },
    ["creature-chamber-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=42},
        {type="item", name="coal-gas-barrel", amount=10},
        {type="item", name="graphite", amount=250},
        {type="item", name="iron-plate", amount=68},
        {type="item", name="micro-mine-mk01", amount=10},
        {type="item", name="resistor1", amount=1223},
        {type="item", name="small-lamp", amount=9},
        {type="item", name="tin-plate", amount=125},
      },
      results = {
        {type="item", name="creature-chamber-mk01", amount=1},
      },
    },
    ["incubator-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aromatics-barrel", amount=10},
        {type="item", name="electronic-circuit", amount=3},
        {type="item", name="fawogae-substrate", amount=15},
        {type="item", name="lead-plate", amount=27},
        {type="item", name="pipe", amount=75},
        {type="item", name="soil-extractor-mk01", amount=2},
      },
      results = {
        {type="item", name="incubator-mk01", amount=1},
      },
    },
    ["micro-mine-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="capacitor1", amount=35},
        {type="item", name="concrete", amount=48},
        {type="item", name="pipe", amount=190},
        {type="item", name="small-lamp", amount=8},
        {type="item", name="tar-processing-unit", amount=3},
        {type="item", name="titanium-plate", amount=63},
      },
      results = {
        {type="item", name="micro-mine-mk01", amount=4},
      },
    },
    ["rc-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=15},
        {type="item", name="assembling-machine-1", amount=4},
        {type="item", name="bolts", amount=527},
        {type="item", name="copper-cable", amount=325},
        {type="item", name="iron-gear-wheel", amount=94},
        {type="item", name="landfill", amount=42},
        {type="item", name="lead-plate", amount=46},
        {type="item", name="pipe", amount=1272},
        {type="item", name="tin-plate", amount=162},
      },
      results = {
        {type="item", name="rc-mk01", amount=1},
      },
    },
    ["genlab-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=15},
        {type="item", name="concrete", amount=652},
        {type="item", name="flora-collector-mk01", amount=8},
        {type="item", name="iron-plate", amount=75},
        {type="item", name="py-tank-1500", amount=2},
        {type="item", name="stone-brick", amount=309},
        {type="item", name="tin-plate", amount=83},
        {type="item", name="treated-wood", amount=21},
      },
      results = {
        {type="item", name="genlab-mk01", amount=1},
      },
    },
    ["research-center-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="fluid-drill-mk01", amount=2},
        {type="item", name="lead-plate", amount=11},
        {type="item", name="pipe", amount=46},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="steam-engine", amount=93},
        {type="item", name="steel-plate", amount=20},
      },
      results = {
        {type="item", name="research-center-mk01", amount=1},
      },
    },
    ["slaughterhouse-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boiler", amount=79},
        {type="item", name="copper-cable", amount=81},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="gun-turret", amount=1},
        {type="item", name="inductor1", amount=1302},
        {type="item", name="lead-plate", amount=55},
        {type="item", name="petri-dish", amount=3},
      },
      results = {
        {type="item", name="slaughterhouse-mk01", amount=1},
      },
    },
    ["gate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="gravel", amount=12},
        {type="item", name="pipe", amount=9},
        {type="item", name="steam-engine", amount=4},
      },
      results = {
        {type="item", name="gate", amount=1},
      },
    },
    ["poorman-wood-fence"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=272},
        {type="item", name="glass", amount=1520},
        {type="item", name="glassworks-mk01", amount=1},
        {type="item", name="steam-engine", amount=2},
        {type="item", name="steel-plate", amount=60},
      },
      results = {
        {type="item", name="automated-screener-mk01", amount=1},
      },
    },
    ["vacuum-pump-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=1},
        {type="item", name="copper-plate", amount=55},
        {type="item", name="ore-zinc", amount=61},
        {type="item", name="transport-belt", amount=6},
      },
      results = {
        {type="item", name="vacuum-pump-mk01", amount=1},
      },
    },
    ["bio-sample"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="moss", amount=20},
        {type="item", name="petri-dish-bacteria", amount=2},
      },
      results = {
        {type="item", name="moss-gen", amount=1},
      },
    },
    ["earth-generic-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bio-sample", amount=10},
        {type="item", name="iron-chest", amount=1},
        {type="item", name="sodium-hydroxide", amount=121},
      },
      results = {
        {type="item", name="earth-generic-sample", amount=1},
      },
    },
    ["vrauks-cocoon-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="moss", amount=10},
        {type="item", name="native-flora", amount=5},
        {type="item", name="stone-wall", amount=1},
        {type="item", name="water-barrel", amount=4},
      },
      results = {
        {type="item", name="barrel", amount=4},
        {type="item", name="cocoon", amount=5},
      },
    },
    ["vrauks-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="small-lamp", amount=1},
        {type="item", name="steam-engine", amount=9},
        {type="item", name="titanium-plate", amount=14},
      },
      results = {
        {type="item", name="vrauks-codex", amount=1},
      },
    },
    ["vrauks"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="earth-generic-sample", amount=2},
        {type="item", name="petri-dish-bacteria", amount=9},
        {type="item", name="saps", amount=1},
        {type="item", name="sodium-hydroxide", amount=38},
        {type="item", name="vrauks-codex", amount=1},
      },
      results = {
        {type="item", name="vrauks", amount=1},
      },
    },
    ["vrauks-paddock-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="pipe", amount=17},
        {type="item", name="refined-concrete", amount=5},
        {type="item", name="small-lamp", amount=3},
        {type="item", name="soil-extractor-mk01", amount=3},
        {type="item", name="tin-plate", amount=36},
        {type="item", name="transport-belt", amount=10},
      },
      results = {
        {type="item", name="vrauks-paddock-mk01", amount=1},
      },
    },
    ["vrauks-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1.44245238649357,
      ingredients = {
        {type="item", name="cocoon", amount=14},
        {type="item", name="moss", amount=7},
        {type="item", name="resistor1", amount=1},
        {type="item", name="scrude-barrel", amount=4},
      },
      results = {
        {type="item", name="barrel", amount=4},
        {type="item", name="vrauks", amount=3},
      },
    },
    ["fluidavan"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=414},
        {type="item", name="advanced-foundry-mk01", amount=5},
        {type="item", name="bio-container", amount=11},
        {type="item", name="brain", amount=18},
        {type="item", name="burner-inserter", amount=2},
        {type="item", name="carbolic-oil-barrel", amount=20},
        {type="item", name="meat", amount=18},
      },
      results = {
        {type="item", name="fluidavan", amount=1},
      },
    },
    ["caravan"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=2320},
        {type="item", name="cage", amount=6},
        {type="item", name="carbolic-oil-barrel", amount=20},
        {type="item", name="tar-canister", amount=16},
        {type="item", name="vrauks", amount=1},
      },
      results = {
        {type="item", name="caravan", amount=1},
      },
    },
    ["concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="calcium-carbide", amount=9},
        {type="item", name="stone", amount=28},
        {type="item", name="stone-wall", amount=1},
      },
      results = {
        {type="item", name="concrete", amount=5},
      },
    },
    ["stone-brick-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pitch", amount=50},
        {type="item", name="stone", amount=5},
      },
      results = {
        {type="item", name="stone-brick", amount=4},
      },
    },
    ["hazard-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="stone-brick", amount=39},
      },
      results = {
        {type="item", name="hazard-concrete", amount=10},
      },
    },
    ["refined-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="graphite", amount=6},
        {type="item", name="iron-gear-wheel", amount=2},
        {type="item", name="stone-brick", amount=20},
      },
      results = {
        {type="item", name="refined-concrete", amount=10},
      },
    },
    ["landfill"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="gravel", amount=29},
        {type="item", name="inductor1", amount=1},
        {type="item", name="sodium-alginate", amount=1},
      },
      results = {
        {type="item", name="landfill", amount=1},
      },
    },
    ["refined-hazard-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-ore", amount=174},
      },
      results = {
        {type="item", name="refined-hazard-concrete", amount=10},
      },
    },
    ["outpost"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="log", amount=3},
        {type="item", name="ore-quartz", amount=247},
        {type="item", name="small-lamp", amount=1},
        {type="item", name="steam-engine", amount=4},
        {type="item", name="stone-brick", amount=79},
      },
      results = {
        {type="item", name="outpost", amount=1},
      },
    },
    ["outpost-fluid"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="empty-petri-dish", amount=1},
        {type="item", name="offshore-pump", amount=15},
        {type="item", name="ore-quartz", amount=1360},
        {type="item", name="stone-furnace", amount=50},
        {type="item", name="underground-belt", amount=2},
      },
      results = {
        {type="item", name="outpost-fluid", amount=1},
      },
    },
    ["data-array"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=233},
        {type="item", name="coal-dust", amount=189},
        {type="item", name="inductor1", amount=781},
        {type="item", name="iron-plate", amount=251},
        {type="item", name="transport-belt", amount=72},
        {type="item", name="treated-wood", amount=12},
      },
      results = {
        {type="item", name="data-array", amount=1},
      },
    },
    ["creamy-latex"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="limestone", amount=2},
        {type="item", name="saps", amount=2},
      },
      results = {
        {type="fluid", name="creamy-latex", amount=100},
      },
    },
    ["sodium-alginate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=97},
        {type="item", name="moss", amount=2},
        {type="item", name="stone", amount=5},
        {type="item", name="wood", amount=2},
      },
      results = {
        {type="item", name="sodium-alginate", amount=1},
      },
    },
    ["latex-slab"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=521},
        {type="fluid", name="oxygen", amount=244},
        {type="item", name="wood-seeds", amount=5},
      },
      results = {
        {type="item", name="latex-slab", amount=1},
      },
    },
    ["sap-seeds"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="stone-furnace", amount=5},
      },
      results = {
        {type="item", name="sap-seeds", amount=2},
      },
    },
    ["latex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=313},
        {type="item", name="cellulose", amount=4},
      },
      results = {
        {type="item", name="latex", amount=1},
      },
    },
    ["sap-tree"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-plate", amount=5},
        {type="item", name="pipe", amount=1},
        {type="item", name="small-parts-01", amount=1},
      },
      results = {
        {type="item", name="py-check-valve", amount=1},
      },
    },
    ["py-underflow-valve"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="moss", amount=152},
        {type="item", name="pipe", amount=1},
        {type="item", name="soil", amount=46},
        {type="item", name="transport-belt", amount=1},
      },
      results = {
        {type="item", name="py-underflow-valve", amount=1},
      },
    },
    ["py-overflow-valve"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cellulose", amount=1},
        {type="item", name="planter-box", amount=1},
        {type="item", name="sap-seeds", amount=1},
        {type="item", name="titanium-plate", amount=22},
      },
      results = {
        {type="item", name="py-overflow-valve", amount=1},
      },
    },
    ["py-local-radar"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="coal", amount=37},
        {type="item", name="pipe", amount=24},
        {type="item", name="steam-engine", amount=7},
        {type="item", name="stone-brick", amount=46},
      },
      results = {
        {type="item", name="py-local-radar", amount=2},
      },
    },
    ["radar"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ore-chromium", amount=80},
        {type="item", name="pipe", amount=9},
        {type="item", name="titanium-plate", amount=110},
      },
      results = {
        {type="item", name="radar", amount=1},
      },
    },
    ["battery-mk00"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=527},
        {type="item", name="coal-dust", amount=22},
        {type="item", name="lead-plate", amount=3},
        {type="item", name="wooden-chest", amount=22},
      },
      results = {
        {type="item", name="battery-mk00", amount=1},
      },
    },
    ["electrolyzer-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=4},
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="pipe", amount=47},
        {type="item", name="titanium-plate", amount=207},
        {type="item", name="wpu-mk01", amount=3},
        {type="item", name="zinc-plate", amount=46},
      },
      results = {
        {type="item", name="electrolyzer-mk01", amount=2},
      },
    },
    ["smelter-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="fluid-drill-mk01", amount=2},
        {type="item", name="hazard-concrete", amount=121},
        {type="item", name="lead-plate", amount=100},
        {type="item", name="lime", amount=121},
        {type="item", name="pipe", amount=43},
        {type="item", name="raw-coal", amount=387},
        {type="item", name="sand", amount=483},
        {type="item", name="soot", amount=2},
      },
      results = {
        {type="item", name="smelter-mk01", amount=1},
      },
    },
    ["inserter"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=5},
        {type="item", name="lead-plate", amount=2},
        {type="item", name="pipe", amount=10},
        {type="item", name="steel-plate", amount=28},
      },
      results = {
        {type="item", name="inserter", amount=1},
      },
    },
    ["methane-co2"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=100},
        {type="fluid", name="water", amount=100},
        {type="item", name="moondrop-seeds", amount=1},
      },
      results = {
        {type="fluid", name="methane", amount=40},
      },
    },
    ["methanal"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=826},
        {type="item", name="copper-ore", amount=44},
      },
      results = {
        {type="fluid", name="methanal", amount=50},
      },
    },
    ["capacitor1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="graphite", amount=2},
        {type="item", name="lead-plate", amount=2},
      },
      results = {
        {type="item", name="capacitor1", amount=3},
      },
    },
    ["inductor1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=4},
        {type="item", name="graphite", amount=4},
      },
      results = {
        {type="item", name="inductor1", amount=6},
      },
    },
    ["resistor1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="calcium-carbide", amount=2},
        {type="item", name="glass", amount=1},
        {type="item", name="soil", amount=32},
      },
      results = {
        {type="item", name="resistor1", amount=3},
      },
    },
    ["formica"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="methanal", amount=50},
        {type="item", name="ash", amount=16},
        {type="item", name="raw-fiber", amount=5},
        {type="item", name="tailings-dust", amount=11},
      },
      results = {
        {type="item", name="formica", amount=1},
      },
    },
    ["vacuum-tube"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="pressured-air", amount=89},
        {type="item", name="copper-ore", amount=25},
        {type="item", name="lime", amount=4},
        {type="item", name="pipe", amount=6},
        {type="item", name="stone-brick", amount=6},
      },
      results = {
        {type="item", name="vacuum-tube", amount=3},
      },
    },
    ["pcb1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-air", amount=63},
        {type="item", name="formica", amount=2},
        {type="item", name="iron-plate", amount=5},
      },
      results = {
        {type="item", name="pcb1", amount=1},
      },
    },
    ["electronic-circuit"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="battery-mk00", amount=1},
        {type="item", name="capacitor1", amount=5},
        {type="item", name="copper-cable", amount=20},
        {type="item", name="formica", amount=2},
        {type="item", name="inductor1", amount=3},
        {type="item", name="lead-plate", amount=12},
        {type="item", name="vacuum-tube", amount=3},
      },
      results = {
        {type="item", name="electronic-circuit", amount=3},
      },
    },
    ["olefin-plant"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="empty-planter-box", amount=59},
        {type="item", name="glass", amount=45},
        {type="item", name="steam-engine", amount=46},
        {type="item", name="storage-tank", amount=4},
        {type="item", name="tinned-cable", amount=77},
      },
      results = {
        {type="item", name="olefin-plant", amount=1},
      },
    },
    ["reformer-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="advanced-foundry-mk01", amount=2},
        {type="item", name="calcium-carbide", amount=579},
        {type="item", name="concrete", amount=1303},
        {type="item", name="ore-tin", amount=96},
        {type="item", name="poorman-wood-fence", amount=84},
        {type="item", name="soil-extractor-mk01", amount=3},
      },
      results = {
        {type="item", name="reformer-mk01", amount=1},
      },
    },
    ["splitter"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="firearm-magazine", amount=1},
        {type="item", name="iron-stick", amount=9},
        {type="item", name="small-parts-01", amount=25},
      },
      results = {
        {type="item", name="splitter", amount=1},
      },
    },
    ["moondrop-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="soil", amount=30},
      },
      results = {
        {type="item", name="moondrop", amount=4},
      },
    },
    ["moondrop-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=357},
        {type="item", name="empty-petri-dish", amount=4},
        {type="item", name="moondrop-codex", amount=1},
        {type="item", name="planter-box", amount=1},
      },
      results = {
        {type="item", name="moondrop", amount=4},
      },
    },
    ["moondrop-seeds"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      energy_required_multiplier = 1.06666666666667,
      ingredients = {
        {type="item", name="moondrop", amount=5},
      },
      results = {
        {type="item", name="moondrop", amount=2},
        {type="item", name="moondrop-seeds", amount=8},
      },
    },
    ["multiblade-turbine-mk01"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="fawogae-substrate", amount=18},
        {type="item", name="stopper", amount=8},
      },
      results = {
        {type="item", name="py-science-pack-1", amount=3},
      },
    },
    ["agar"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=1100},
        {type="item", name="limestone", amount=6},
      },
      results = {
        {type="item", name="agar", amount=1},
      },
    },
    ["cellulose-00"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="seaweed", amount=3},
        {type="item", name="wood", amount=7},
      },
      results = {
        {type="item", name="cellulose", amount=1},
      },
    },
    ["cellulose-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="gravel", amount=34},
        {type="item", name="wood", amount=10},
      },
      results = {
        {type="item", name="cellulose", amount=2},
      },
    },
    ["coke-co2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="limestone", amount=3},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=80},
      },
    },
    ["lime"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1.00283715017649,
      ingredients = {
        {type="item", name="ceramic", amount=3},
        {type="item", name="soil", amount=17},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=102},
        {type="item", name="lime", amount=10},
      },
    },
    ["dried-meat-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="brain", amount=5},
      },
      results = {
        {type="item", name="dried-meat", amount=5},
      },
    },
    ["petri-dish-bacteria"] = {
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cellulose", amount=3},
        {type="item", name="moss", amount=5},
        {type="item", name="petri-dish", amount=2},
      },
      results = {
        {type="item", name="fawogae-substrate", amount=10},
      },
    },
    ["empty-petri-dish"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="syngas", amount=250},
      },
      results = {
        {type="item", name="empty-petri-dish", amount=1},
      },
    },
    ["sand-void-glass"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "input-preserved-unmodified",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coal", amount=5},
        {type="item", name="latex", amount=2},
      },
      results = {
        {type="item", name="stopper", amount=4},
      },
    },
    ["flask"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=5200},
        {type="item", name="stopper", amount=4},
      },
      results = {
        {type="item", name="flask", amount=2},
      },
    },
    ["petri-dish"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=181},
        {type="fluid", name="water", amount=3312},
      },
      results = {
        {type="fluid", name="condensates", amount=250},
        {type="fluid", name="heavy-oil", amount=100},
        {type="fluid", name="light-oil", amount=150},
      },
    },
    ["tar-refining"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=100},
        {type="fluid", name="water", amount=1180},
      },
      results = {
        {type="fluid", name="anthracene-oil", amount=75},
        {type="fluid", name="creosote", amount=24},
        {type="fluid", name="middle-oil", amount=30},
        {type="fluid", name="pitch", amount=140},
      },
    },
    ["heavy-oil-to-kerosene"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=813},
      },
      results = {
        {type="fluid", name="kerosene", amount=40},
      },
    },
    ["pitch-refining"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=199},
        {type="fluid", name="pressured-air", amount=2750},
      },
      results = {
        {type="fluid", name="anthracene-oil", amount=30},
        {type="fluid", name="hydrogen", amount=10},
        {type="fluid", name="light-oil", amount=20},
        {type="fluid", name="naphthalene-oil", amount=20},
        {type="item", name="coke", amount=10},
      },
    },
    ["tar-refining-tops"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=393},
        {type="fluid", name="pitch", amount=467},
      },
      results = {
        {type="fluid", name="carbolic-oil", amount=50},
        {type="fluid", name="light-oil", amount=50},
        {type="fluid", name="naphthalene-oil", amount=100},
      },
    },
    ["anthracene-gasoline-cracking"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="anthracene-oil", amount=50},
      },
      results = {
        {type="fluid", name="gasoline", amount=20},
        {type="item", name="coke", amount=5},
      },
    },
    ["carbolic-oil-creosote"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="anthracene-oil", amount=288},
      },
      results = {
        {type="fluid", name="creosote", amount=50},
      },
    },
    ["kerogen-extraction"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=181},
        {type="item", name="processed-iron-ore", amount=11},
      },
      results = {
        {type="fluid", name="scrude", amount=250},
      },
    },
    ["light-oil-aromatics"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="light-oil", amount=50},
      },
      results = {
        {type="fluid", name="aromatics", amount=50},
        {type="fluid", name="gasoline", amount=25},
      },
    },
    ["naphthalene-oil-creosote"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="syngas", amount=372},
      },
      results = {
        {type="fluid", name="creosote", amount=30},
      },
    },
    ["barrel"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
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
      mode = "input-preserved-unmodified",
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
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
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
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="capacitor1", amount=45},
        {type="item", name="concrete", amount=8},
        {type="item", name="iron-plate", amount=24},
        {type="item", name="lab", amount=1},
        {type="item", name="lead-plate", amount=25},
      },
      results = {
        {type="item", name="assembling-machine-2", amount=1},
      },
    },
    ["crushed-coal"] = {
      mode = "input-preserved-unmodified",
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
      mode = "input-preserved-unmodified",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="biomass", amount=50},
      },
      results = {
        {type="item", name="raw-coal", amount=4},
      },
    },
    ["biomass-molten-salt-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=10765},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=400},
      },
    },
    ["chitin-to-geothermal-water"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="guts", amount=10},
      },
      results = {
        {type="fluid", name="geothermal-water", amount=50},
      },
    },
    ["he-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-molten-salt", amount=200},
        {type="fluid", name="steam", amount=59},
      },
      results = {
        {type="fluid", name="molten-salt", amount=200},
        {type="fluid", name="pressured-steam", amount=75},
      },
    },
    ["molten-salt"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="moondrop", amount=15},
      },
      results = {
        {type="fluid", name="molten-salt", amount=100},
      },
    },
    ["coal-molten-salt-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="fish-oil", amount=401},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=500},
      },
    },
    ["geo-he-00"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=432},
      },
      results = {
        {type="fluid", name="steam", amount=300},
      },
    },
    ["oil-molten-salt-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="condensates", amount=9446},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=500},
      },
    },
    ["borax-washing"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=98},
        {type="item", name="calcium-carbide", amount=7},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=100},
        {type="item", name="borax", amount=10},
      },
    },
    ["diborane"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=457},
        {type="item", name="ore-lead", amount=5},
      },
      results = {
        {type="fluid", name="diborane", amount=150},
      },
    },
    ["boric-acid"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=251},
        {type="fluid", name="steam", amount=326},
      },
      results = {
        {type="fluid", name="boric-acid", amount=500},
      },
    },
    ["clean-nexelit"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=65},
        {type="item", name="nexelit-ore", amount=3},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=100},
        {type="item", name="clean-nexelit", amount=1},
      },
    },
    ["nexelit-ore-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2.49992703663908,
      ingredients = {
        {type="fluid", name="creosote", amount=801},
      },
      results = {
        {type="item", name="nexelit-ore", amount=2},
        {type="item", name="tailings-dust", amount=1},
      },
    },
    ["nexelit-plate-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="clean-nexelit", amount=18},
      },
      results = {
        {type="item", name="nexelit-plate", amount=18},
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="sand", amount=88},
      },
      results = {
        {type="item", name="gravel", amount=4},
        {type="item", name="iron-oxide", amount=2},
        {type="item", name="stone", amount=5},
      },
    },
    ["concrete-wall"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=3},
        {type="item", name="lead-plate", amount=2},
      },
      results = {
        {type="item", name="concrete-wall", amount=1},
      },
    },
    ["wood-fence"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="lime", amount=9},
      },
      results = {
        {type="item", name="wood-fence", amount=1},
      },
    },
    ["cool-pressured-steam-2000-to-1000"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-steam", amount=200},
        {type="fluid", name="steam", amount=164},
      },
      results = {
        {type="fluid", name="pressured-steam", amount=400},
      },
    },
    ["jerky-to-phytoplankton"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=227},
        {type="item", name="dried-meat", amount=3},
      },
      results = {
        {type="fluid", name="phytoplankton", amount=10},
      },
    },
    ["cool-steam-250-to-150"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=200},
        {type="fluid", name="water", amount=150},
      },
      results = {
        {type="fluid", name="steam", amount=340},
      },
    },
    ["electric-boiler-water-to-steam"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=300},
      },
      results = {
        {type="fluid", name="steam", amount=300},
      },
    },
    ["digosaurus"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="condensates", amount=810},
        {type="item", name="empty-petri-dish", amount=21},
        {type="item", name="formic-acid-barrel", amount=359},
        {type="item", name="fwf-mk01", amount=2},
        {type="item", name="vacuum-tube", amount=29},
      },
      results = {
        {type="item", name="digosaurus", amount=1},
      },
    },
    ["electric-mining-drill"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=4},
        {type="item", name="electronic-circuit", amount=3},
        {type="item", name="pipe", amount=18},
      },
      results = {
        {type="item", name="electric-mining-drill", amount=1},
      },
    },
    ["fawogae-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="concrete", amount=815},
        {type="item", name="glass", amount=2},
        {type="item", name="petri-dish", amount=5},
        {type="item", name="tin-plate", amount=37},
      },
      results = {
        {type="item", name="fawogae-codex", amount=1},
      },
    },
    ["ralesia-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="clay", amount=116},
        {type="item", name="duralumin", amount=170},
        {type="item", name="glass", amount=2},
        {type="item", name="tin-plate", amount=37},
      },
      results = {
        {type="item", name="ralesia-codex", amount=1},
      },
    },
    ["fbreactor-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=1},
        {type="item", name="ceramic", amount=35},
        {type="item", name="chlorine-barrel", amount=1},
        {type="item", name="ore-tin", amount=153},
        {type="item", name="stone-furnace", amount=4},
        {type="item", name="titanium-plate", amount=15},
      },
      results = {
        {type="item", name="fbreactor-mk01", amount=1},
      },
    },
    ["geothermal-plant-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="concrete", amount=458},
        {type="item", name="offshore-pump", amount=51},
        {type="item", name="pipe", amount=267},
        {type="item", name="tinned-cable", amount=68},
      },
      results = {
        {type="item", name="geothermal-plant-mk01", amount=1},
      },
    },
    ["grade-1-lead"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ore-lead", amount=5},
      },
      results = {
        {type="item", name="grade-1-lead", amount=1},
      },
    },
    ["lead-plate-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-1-lead", amount=4},
      },
      results = {
        {type="item", name="lead-plate", amount=10},
      },
    },
    ["grade-1-nickel"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="grade-2-tin", amount=2},
      },
      results = {
        {type="item", name="nickel-plate", amount=3},
      },
    },
    ["grade-1-ti"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-1-ti", amount=14},
      },
      results = {
        {type="item", name="titanium-plate", amount=10},
      },
    },
    ["grade-1-tin"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="ore-tin", amount=9},
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
      mode = "input-preserved-unmodified",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="grade-2-tin", amount=2},
      },
      results = {
        {type="item", name="grade-1-tin", amount=1},
        {type="item", name="stone", amount=2},
      },
    },
    ["grade-1-zinc"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 3.01955345693671,
      ingredients = {
        {type="item", name="iron-gear-wheel", amount=3},
        {type="item", name="ore-aluminium", amount=13},
      },
      results = {
        {type="item", name="grade-1-zinc", amount=3},
        {type="item", name="soil", amount=2},
        {type="item", name="stone", amount=2},
      },
    },
    ["grade-2-zinc"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      energy_required_multiplier = 1.01573140698684,
      ingredients = {
        {type="item", name="grade-1-zinc", amount=2},
      },
      results = {
        {type="item", name="grade-2-zinc", amount=2},
        {type="item", name="sand", amount=1},
      },
    },
    ["zinc-plate-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-1-zinc", amount=21},
      },
      results = {
        {type="item", name="zinc-plate", amount=30},
      },
    },
    ["grenade"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="pipe", amount=4},
        {type="item", name="seaweed", amount=80},
      },
      results = {
        {type="item", name="grenade", amount=1},
      },
    },
    ["guts-to-chlorine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1.14,
      ingredients = {
        {type="item", name="brain", amount=2},
      },
      results = {
        {type="fluid", name="chlorine", amount=114},
      },
    },
    ["phytoplankton"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=417},
        {type="item", name="grade-1-tin", amount=1},
      },
      results = {
        {type="fluid", name="phytoplankton", amount=10},
      },
    },
    ["piercing-rounds-magazine"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="fluid", name="pressured-air", amount=795},
        {type="item", name="grade-1-nickel", amount=4},
        {type="item", name="moss", amount=7},
      },
      results = {
        {type="item", name="py-asphalt", amount=3},
      },
    },
    ["py-iron-oxide"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=20},
        {type="item", name="pipe", amount=1},
        {type="item", name="soil", amount=147},
      },
      results = {
        {type="item", name="py-iron-oxide", amount=2},
      },
    },
    ["py-limestone"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=239},
        {type="item", name="clay", amount=11},
        {type="item", name="iron-ore", amount=13},
      },
      results = {
        {type="item", name="py-limestone", amount=2},
      },
    },
    ["py-burner"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="pitch-canister", amount=5},
        {type="item", name="pressured-water-barrel", amount=3},
        {type="item", name="steel-chest", amount=10},
        {type="item", name="vacuum-tube", amount=3},
      },
      results = {
        {type="item", name="py-deposit-basic", amount=1},
      },
    },
    ["py-shed-basic"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=5},
        {type="item", name="small-parts-01", amount=8},
        {type="item", name="sodium-hydroxide", amount=5},
        {type="item", name="steam-engine", amount=4},
      },
      results = {
        {type="item", name="py-shed-basic", amount=1},
      },
    },
    ["py-storehouse-basic"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="formica", amount=1},
        {type="item", name="pipe", amount=45},
        {type="item", name="small-electric-pole", amount=3},
        {type="item", name="stopper", amount=25},
      },
      results = {
        {type="item", name="py-storehouse-basic", amount=1},
      },
    },
    ["py-warehouse-basic"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=40},
        {type="item", name="dried-meat", amount=123},
        {type="item", name="iron-chest", amount=4},
        {type="item", name="small-parts-01", amount=5},
      },
      results = {
        {type="item", name="py-warehouse-basic", amount=1},
      },
    },
    ["rail"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bio-container", amount=4},
        {type="item", name="glass", amount=8},
        {type="item", name="grade-1-lead", amount=1},
        {type="item", name="iron-ore", amount=1},
        {type="item", name="ore-aluminium", amount=16},
      },
      results = {
        {type="item", name="rail", amount=3},
      },
    },
    ["rail-signal"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coal", amount=7},
        {type="item", name="grade-1-copper", amount=24},
      },
      results = {
        {type="item", name="rail-signal", amount=1},
      },
    },
    ["rail-chain-signal"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-2-ti", amount=7},
        {type="item", name="pipe", amount=4},
      },
      results = {
        {type="item", name="rail-chain-signal", amount=1},
      },
    },
    ["train-stop"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="moondrop-seeds", amount=16},
        {type="item", name="pipe", amount=5},
        {type="item", name="sap-seeds", amount=1},
        {type="item", name="tailings-barrel", amount=15},
      },
      results = {
        {type="item", name="train-stop", amount=1},
      },
    },
    ["sb-grade-01"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1.24199258260283,
      ingredients = {
        {type="item", name="sb-grade-01", amount=6},
      },
      results = {
        {type="item", name="gravel", amount=4},
        {type="item", name="sb-grade-03", amount=1},
        {type="item", name="sb-grade-04", amount=6},
      },
    },
    ["sb-grade-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1.14592094196804,
      ingredients = {
        {type="item", name="sb-grade-04", amount=5},
      },
      results = {
        {type="item", name="sb-grade-02", amount=11},
        {type="item", name="stone", amount=1},
      },
    },
    ["sb-grade-04"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="sb-grade-02", amount=85},
      },
      results = {
        {type="item", name="sb-grade-04", amount=4},
      },
    },
    ["steel-furnace"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ceramic", amount=62},
        {type="item", name="hazard-concrete", amount=11},
      },
      results = {
        {type="item", name="steel-furnace", amount=1},
      },
    },
    ["storage-chest"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="acetylene-canister", amount=4},
        {type="item", name="wood-fence", amount=14},
      },
      results = {
        {type="item", name="storage-chest", amount=1},
      },
    },
    ["anemometer-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="duralumin", amount=6},
        {type="item", name="pipe", amount=53},
      },
      results = {
        {type="item", name="anemometer-mk01", amount=1},
      },
    },
    ["blade-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="graphite", amount=7},
        {type="item", name="titanium-plate", amount=11},
      },
      results = {
        {type="item", name="blade-mk01", amount=1},
      },
    },
    ["brake-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=135},
        {type="item", name="copper-ore", amount=88},
        {type="item", name="fenxsb-alloy", amount=8},
        {type="item", name="graphite", amount=9},
        {type="item", name="lens", amount=3},
        {type="item", name="nexelit-plate", amount=43},
        {type="item", name="pipe", amount=35},
      },
      results = {
        {type="item", name="brake-mk01", amount=1},
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="fenxsb-alloy", amount=5},
        {type="item", name="inductor1", amount=4},
        {type="item", name="solder", amount=5},
      },
      results = {
        {type="item", name="shaft-mk01", amount=1},
      },
    },
    ["utility-box-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="electronic-circuit", amount=3},
        {type="item", name="pipe", amount=8},
        {type="item", name="plastic-bar", amount=5},
        {type="item", name="small-lamp", amount=32},
        {type="item", name="steel-plate", amount=5},
      },
      results = {
        {type="item", name="utility-box-mk01", amount=1},
      },
    },
    ["vane-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=6},
        {type="item", name="pipe", amount=31},
      },
      results = {
        {type="item", name="vane-mk01", amount=1},
      },
    },
    ["controler-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ceramic", amount=211},
        {type="item", name="lens", amount=1},
        {type="item", name="nexelit-plate", amount=4},
        {type="item", name="ore-chromium", amount=3},
        {type="item", name="small-parts-01", amount=40},
      },
      results = {
        {type="item", name="controler-mk01", amount=1},
      },
    },
    ["gearbox-mk01"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=3},
        {type="item", name="concrete", amount=280},
        {type="item", name="grade-1-zinc", amount=34},
        {type="item", name="hydrogen-barrel", amount=43},
        {type="item", name="melamine", amount=41},
        {type="item", name="methane-barrel", amount=2},
        {type="item", name="plasmids", amount=5},
        {type="item", name="rotor-mk01", amount=2},
        {type="item", name="tower-mk01", amount=3},
        {type="item", name="transport-belt", amount=80},
        {type="item", name="vrauks-mk02", amount=11},
      },
      results = {
        {type="item", name="nacelle-mk01", amount=1},
      },
    },
    ["tower-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=142},
        {type="item", name="coke", amount=63},
        {type="item", name="copper-plate", amount=236},
      },
      results = {
        {type="item", name="tower-mk01", amount=1},
      },
    },
    ["yaw-drive-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cellulose", amount=89},
        {type="item", name="concrete", amount=96},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="shaft-mk01", amount=1},
        {type="item", name="transport-belt", amount=78},
      },
      results = {
        {type="item", name="yaw-drive-mk01", amount=1},
      },
    },
    ["rotor-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=34},
        {type="item", name="ceramic", amount=15},
        {type="item", name="electronics-mk01", amount=1},
        {type="item", name="lime", amount=42},
      },
      results = {
        {type="item", name="rotor-mk01", amount=1},
      },
    },
    ["animal-sample-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="tailings", amount=347},
        {type="item", name="agar", amount=5},
        {type="item", name="chitin", amount=2},
        {type="item", name="cottongut-mk01", amount=1},
        {type="item", name="ralesia-seeds", amount=54},
        {type="item", name="retrovirus", amount=2},
        {type="item", name="seaweed", amount=72},
        {type="item", name="tar-canister", amount=1},
      },
      results = {
        {type="item", name="animal-sample-01", amount=2},
      },
    },
    ["bio-sample01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bones", amount=21},
        {type="item", name="grade-2-tin", amount=1},
        {type="item", name="petri-dish", amount=2},
        {type="item", name="ralesia", amount=12},
        {type="item", name="urea", amount=5},
      },
      results = {
        {type="item", name="bio-sample01", amount=4},
      },
    },
    ["equipment-chassi"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="fenxsb-alloy", amount=1},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="tin-plate", amount=10},
      },
      results = {
        {type="item", name="equipment-chassi", amount=2},
      },
    },
    ["ground-sample01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coal-dust", amount=5},
        {type="item", name="sand", amount=6},
      },
      results = {
        {type="item", name="ground-sample01", amount=10},
      },
    },
    ["rich-clay"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=417},
        {type="item", name="ash", amount=25},
      },
      results = {
        {type="item", name="rich-clay", amount=10},
      },
    },
    ["sand-casting"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=383},
        {type="item", name="limestone", amount=4},
      },
      results = {
        {type="item", name="sand-casting", amount=2},
      },
    },
    ["alien-sample01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bio-sample01", amount=4},
        {type="item", name="limestone", amount=59},
      },
      results = {
        {type="item", name="alien-sample01", amount=4},
      },
    },
    ["lab-instrument"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="belt", amount=20},
        {type="item", name="equipment-chassi", amount=2},
        {type="item", name="glass", amount=12},
        {type="item", name="transport-belt", amount=8},
      },
      results = {
        {type="item", name="lab-instrument", amount=2},
      },
    },
    ["grade-1-chromite"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1.04853468955712,
      ingredients = {
        {type="item", name="kerogen", amount=8},
      },
      results = {
        {type="item", name="grade-1-chromite", amount=1},
        {type="item", name="stone", amount=1},
      },
    },
    ["chromium-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=217},
        {type="item", name="chromite-sand", amount=15},
        {type="item", name="lime", amount=1},
        {type="item", name="sand", amount=5},
      },
      results = {
        {type="item", name="chromium", amount=5},
      },
    },
    ["tier-0-chromite-sand"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-2-copper", amount=3},
      },
      results = {
        {type="item", name="chromite-sand", amount=3},
      },
    },
    ["medium-electric-pole"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-stick", amount=4},
        {type="item", name="nexelit-plate", amount=3},
        {type="item", name="nickel-plate", amount=2},
      },
      results = {
        {type="item", name="medium-electric-pole", amount=1},
      },
    },
    ["powdered-aluminium"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="nexelit-plate", amount=3},
        {type="item", name="sand-casting", amount=1},
        {type="item", name="sb-grade-04", amount=10},
      },
      results = {
        {type="fluid", name="molten-aluminium", amount=10},
      },
    },
    ["aluminium-plate-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="molten-aluminium", amount=100},
        {type="item", name="limestone", amount=4},
      },
      results = {
        {type="item", name="aluminium-plate", amount=50},
      },
    },
    ["hotair-aluminium-plate-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="molten-aluminium", amount=100},
        {type="item", name="lime", amount=2},
      },
      results = {
        {type="item", name="aluminium-plate", amount=63},
      },
    },
    ["crushing-quartz"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="processed-iron-ore", amount=5},
      },
      results = {
        {type="item", name="crushed-quartz", amount=2},
        {type="item", name="stone", amount=1},
      },
    },
    ["sand-classification"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1.99836057575502,
      ingredients = {
        {type="item", name="soil", amount=64},
      },
      results = {
        {type="item", name="crushed-quartz", amount=0.0942623411087228},
        {type="item", name="gravel", amount=8},
        {type="item", name="iron-oxide", amount=1},
      },
    },
    ["glass-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1.06666666666667,
      ingredients = {
        {type="item", name="iron-plate", amount=4},
      },
      results = {
        {type="fluid", name="molten-glass", amount=32},
      },
    },
    ["hotair-molten-glass"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="molten-glass", amount=50},
      },
      results = {
        {type="item", name="glass", amount=7},
      },
    },
    ["antimony-drill-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="distilator", amount=4},
        {type="item", name="glass", amount=33},
        {type="item", name="hpf", amount=3},
        {type="item", name="lead-plate", amount=101},
        {type="item", name="steam-engine", amount=4},
      },
      results = {
        {type="item", name="antimony-drill-mk01", amount=1},
      },
    },
    ["centrifuge-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="concrete", amount=162},
        {type="item", name="fiberboard", amount=37},
        {type="item", name="iron-chest", amount=42},
        {type="item", name="nexelit-plate", amount=285},
        {type="item", name="plastic-bar", amount=35},
        {type="item", name="tin-plate", amount=11},
        {type="item", name="titanium-plate", amount=149},
      },
      results = {
        {type="item", name="centrifuge-mk01", amount=1},
      },
    },
    ["hawt-turbine-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cooling-tower-mk01", amount=11},
        {type="item", name="hpf", amount=3},
        {type="item", name="iron-chest", amount=7},
        {type="item", name="tower-mk01", amount=1},
        {type="item", name="tree-mk01", amount=6},
      },
      results = {
        {type="item", name="hawt-turbine-mk01", amount=1},
      },
    },
    ["py-biomass-powerplant-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=1745},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="gearbox-mk01", amount=1},
        {type="item", name="grade-1-zinc", amount=12},
        {type="item", name="inductor1", amount=748},
        {type="item", name="nexelit-plate", amount=864},
        {type="item", name="tin-plate", amount=421},
        {type="item", name="wood-fence", amount=29},
      },
      results = {
        {type="item", name="py-biomass-powerplant-mk01", amount=1},
      },
    },
    ["py-oil-powerplant-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="concrete", amount=240},
        {type="item", name="empty-fuel-canister", amount=10},
        {type="item", name="fiberboard", amount=371},
        {type="item", name="fish-egg", amount=32},
        {type="item", name="heavy-oil-refinery-mk01", amount=1},
        {type="item", name="lab", amount=16},
        {type="item", name="lead-plate", amount=427},
        {type="item", name="mechanical-parts-01", amount=3},
        {type="item", name="stopper", amount=56},
        {type="item", name="vitreloy", amount=50},
      },
      results = {
        {type="item", name="py-oil-powerplant-mk01", amount=1},
      },
    },
    ["steam-turbine-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=20},
        {type="item", name="concrete", amount=182},
        {type="item", name="engine-unit", amount=11},
        {type="item", name="glass", amount=2005},
        {type="item", name="py-tank-4000", amount=3},
        {type="item", name="rail", amount=59},
        {type="item", name="titanium-plate", amount=381},
        {type="item", name="tower-mk01", amount=5},
        {type="item", name="transport-belt", amount=17},
        {type="item", name="yaw-drive-mk01", amount=1},
      },
      results = {
        {type="item", name="steam-turbine-mk01", amount=2},
      },
    },
    ["tidal-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=8},
        {type="item", name="concrete", amount=411},
        {type="item", name="cottongut-pup-mk01", amount=2},
        {type="item", name="electronics-mk01", amount=4},
        {type="item", name="fiberboard", amount=74},
        {type="item", name="formica", amount=25},
        {type="item", name="hazard-concrete", amount=55},
        {type="item", name="lead-plate", amount=150},
        {type="item", name="retrovirus", amount=24},
        {type="item", name="tower-mk01", amount=1},
        {type="item", name="vitreloy", amount=12},
        {type="item", name="washer", amount=9},
      },
      results = {
        {type="item", name="tidal-mk01", amount=1},
      },
    },
    ["vawt-turbine-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="acetone-barrel", amount=1},
        {type="item", name="auog-paddock-mk01", amount=5},
        {type="item", name="coarse", amount=86},
        {type="item", name="copper-ore", amount=250},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="fish-oil-barrel", amount=3},
        {type="item", name="grade-1-lead", amount=187},
        {type="item", name="kerosene-canister", amount=30},
        {type="item", name="molten-glass-barrel", amount=24},
        {type="item", name="rhe", amount=2},
        {type="item", name="vacuum-tube", amount=5},
        {type="item", name="water-barrel", amount=27},
        {type="item", name="water-saline-barrel", amount=206},
      },
      results = {
        {type="item", name="vawt-turbine-mk01", amount=1},
      },
    },
    ["py-coal-powerplant-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="arithmetic-combinator", amount=3},
        {type="item", name="copper-plate", amount=946},
        {type="item", name="glassworks-mk01", amount=4},
        {type="item", name="iron-plate", amount=4693},
        {type="item", name="jaw-crusher", amount=3},
        {type="item", name="nexelit-plate", amount=1951},
        {type="item", name="titanium-plate", amount=844},
        {type="item", name="workers-food", amount=47},
      },
      results = {
        {type="item", name="py-coal-powerplant-mk01", amount=1},
      },
    },
    ["arithmetic-combinator"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-ore", amount=25},
        {type="item", name="grade-1-copper", amount=41},
        {type="item", name="inductor1", amount=37},
      },
      results = {
        {type="item", name="arithmetic-combinator", amount=1},
      },
    },
    ["constant-combinator"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="fish-egg", amount=11},
        {type="item", name="gasoline-barrel", amount=4},
        {type="item", name="inductor1", amount=1},
      },
      results = {
        {type="item", name="constant-combinator", amount=1},
      },
    },
    ["decider-combinator"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="glass", amount=10},
        {type="item", name="nexelit-plate", amount=112},
        {type="item", name="steel-chest", amount=5},
      },
      results = {
        {type="item", name="decider-combinator", amount=2},
      },
    },
    ["display-panel"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="calcium-carbide", amount=2},
        {type="item", name="electronic-circuit", amount=1},
      },
      results = {
        {type="item", name="display-panel", amount=1},
      },
    },
    ["power-switch"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-2-tin", amount=1},
        {type="item", name="hazard-concrete", amount=32},
        {type="item", name="iron-stick", amount=11},
        {type="item", name="tree-mk01", amount=39},
      },
      results = {
        {type="item", name="power-switch", amount=1},
      },
    },
    ["programmable-speaker"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bolts", amount=7},
        {type="item", name="copper-plate", amount=6},
        {type="item", name="inserter", amount=3},
        {type="item", name="pipe", amount=5},
      },
      results = {
        {type="item", name="programmable-speaker", amount=2},
      },
    },
    ["selector-combinator"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=348},
        {type="item", name="raw-fiber", amount=5},
        {type="item", name="sodium-hydroxide", amount=3},
        {type="item", name="treated-wood", amount=3},
      },
      results = {
        {type="fluid", name="black-liquor", amount=10},
        {type="fluid", name="tall-oil", amount=15},
        {type="item", name="fiberboard", amount=4},
      },
    },
    ["urea-decomposition"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1.03333333333333,
      ingredients = {
        {type="item", name="fertilizer", amount=3},
      },
      results = {
        {type="fluid", name="ammonia", amount=31},
        {type="fluid", name="cyanic-acid", amount=31},
      },
    },
    ["black-liquor"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="black-liquor", amount=80},
        {type="fluid", name="oxygen", amount=100},
      },
      results = {
        {type="fluid", name="acetone", amount=50},
        {type="fluid", name="aromatics", amount=100},
      },
    },
    ["cyanic-acid-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ammonia", amount=100},
        {type="fluid", name="water", amount=3349},
        {type="item", name="coal-dust", amount=4},
      },
      results = {
        {type="fluid", name="cyanic-acid", amount=100},
        {type="fluid", name="hydrogen", amount=50},
      },
    },
    ["melamine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ammonia", amount=20},
        {type="fluid", name="cyanic-acid", amount=20},
        {type="fluid", name="steam", amount=130},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=30},
        {type="fluid", name="muddy-sludge", amount=50},
        {type="item", name="melamine", amount=20},
      },
    },
    ["cooling-water"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=110},
      },
      results = {
        {type="fluid", name="water", amount=400},
      },
    },
    ["flue-gas-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="biomass", amount=10},
      },
      results = {
        {type="fluid", name="flue-gas", amount=150},
      },
    },
    ["flue-gas-3"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="item", name="biomass", amount=10},
      },
      results = {
        {type="fluid", name="flue-gas", amount=200},
      },
    },
    ["cracker-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=1},
        {type="item", name="barrel", amount=22},
        {type="item", name="carbon-dioxide-barrel", amount=7},
        {type="item", name="concrete", amount=16},
        {type="item", name="copper-cable", amount=20},
        {type="item", name="soot", amount=4},
        {type="item", name="steel-plate", amount=79},
      },
      results = {
        {type="item", name="cracker-mk01", amount=1},
      },
    },
    ["heavy-oil-refinery-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=23},
        {type="item", name="boiler", amount=76},
        {type="item", name="ceramic", amount=87},
        {type="item", name="inductor1", amount=224},
        {type="item", name="pipe", amount=356},
        {type="item", name="stone-wall", amount=1},
        {type="item", name="tin-plate", amount=7},
      },
      results = {
        {type="item", name="heavy-oil-refinery-mk01", amount=1},
      },
    },
    ["gas-refinery-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="concrete", amount=16},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="graphite", amount=287},
        {type="item", name="jaw-crusher", amount=1},
        {type="item", name="nexelit-plate", amount=51},
        {type="item", name="pbsb-alloy", amount=35},
        {type="item", name="radar", amount=1},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="stone-brick", amount=18},
        {type="item", name="transport-belt", amount=13},
      },
      results = {
        {type="item", name="gas-refinery-mk01", amount=1},
      },
    },
    ["upgrader-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=23},
        {type="item", name="concrete", amount=123},
        {type="item", name="nexelit-plate", amount=29},
        {type="item", name="quenching-tower", amount=4},
        {type="item", name="resistor1", amount=644},
        {type="item", name="steam-engine", amount=14},
      },
      results = {
        {type="item", name="upgrader-mk01", amount=1},
      },
    },
    ["earth-bear-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bio-sample", amount=53},
        {type="item", name="fawogae-codex", amount=3},
        {type="item", name="landfill", amount=228},
      },
      results = {
        {type="item", name="earth-bear-sample", amount=2},
      },
    },
    ["earth-flower-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="automation-science-pack", amount=100},
        {type="item", name="earth-generic-sample", amount=1},
        {type="item", name="vrauks-codex", amount=8},
      },
      results = {
        {type="item", name="earth-flower-sample", amount=1},
      },
    },
    ["earth-shroom-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cottongut-codex", amount=1},
        {type="item", name="earth-generic-sample", amount=4},
        {type="item", name="wooden-chest", amount=1},
      },
      results = {
        {type="item", name="earth-shroom-sample", amount=1},
      },
    },
    ["earth-mouse-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ceramic", amount=2944},
        {type="item", name="fawogae-codex", amount=1},
        {type="item", name="seaweed", amount=1338},
      },
      results = {
        {type="item", name="earth-mouse-sample", amount=1},
      },
    },
    ["molten-iron-05"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=219},
        {type="item", name="iron-ore", amount=11},
        {type="item", name="limestone", amount=3},
      },
      results = {
        {type="fluid", name="molten-iron", amount=10},
      },
    },
    ["hotair-iron-plate-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="molten-iron", amount=100},
        {type="item", name="sand-casting", amount=1},
        {type="item", name="seaweed", amount=3},
      },
      results = {
        {type="item", name="iron-plate", amount=75},
      },
    },
    ["iron-plate-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="molten-iron", amount=100},
        {type="item", name="lime", amount=1},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="iron-plate", amount=60},
      },
    },
    ["mechanical-parts-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="belt", amount=11},
        {type="item", name="controler-mk01", amount=2},
        {type="item", name="copper-plate", amount=134},
        {type="item", name="electronics-mk01", amount=3},
        {type="item", name="gearbox-mk01", amount=2},
        {type="item", name="lab", amount=4},
        {type="item", name="pbsb-alloy", amount=11},
        {type="item", name="rotor-mk01", amount=2},
      },
      results = {
        {type="item", name="mechanical-parts-01", amount=6},
      },
    },
    ["sb-oxide-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="water", amount=540},
        {type="item", name="plastic-bar", amount=2},
        {type="item", name="sb-grade-03", amount=3},
      },
      results = {
        {type="item", name="sb-oxide", amount=2},
      },
    },
    ["pbsb-alloy"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="pipe", amount=12},
        {type="item", name="sb-oxide", amount=1},
      },
      results = {
        {type="item", name="pbsb-alloy", amount=1},
      },
    },
    ["battery-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="cyanic-acid", amount=30},
        {type="item", name="ceramic", amount=3},
        {type="item", name="glass", amount=1},
        {type="item", name="iron-stick", amount=4},
        {type="item", name="lime", amount=3},
        {type="item", name="sb-oxide", amount=2},
        {type="item", name="zinc-plate", amount=3},
      },
      results = {
        {type="item", name="battery-mk01", amount=1},
      },
    },
    ["accumulator"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="calcium-carbide", amount=4},
        {type="item", name="dino-dig-site", amount=1},
        {type="item", name="fish-egg", amount=11},
      },
      results = {
        {type="item", name="accumulator", amount=1},
      },
    },
    ["fenxsb-alloy-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="ceramic", amount=4},
        {type="item", name="pbsb-alloy", amount=1},
        {type="item", name="pipe", amount=10},
      },
      results = {
        {type="item", name="fenxsb-alloy", amount=4},
      },
    },
    ["vitreloy"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=38},
        {type="item", name="copper-ore", amount=50},
        {type="item", name="nexelit-plate", amount=17},
        {type="item", name="pbsb-alloy", amount=3},
        {type="item", name="titanium-plate", amount=6},
      },
      results = {
        {type="item", name="vitreloy", amount=4},
      },
    },
    ["intermetallics"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="fenxsb-alloy", amount=1},
        {type="item", name="vitreloy", amount=1},
      },
      results = {
        {type="item", name="intermetallics", amount=1},
      },
    },
    ["ball-mill-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boiler", amount=8},
        {type="item", name="brain", amount=2},
        {type="item", name="chitin", amount=2},
        {type="item", name="concrete", amount=164},
        {type="item", name="inductor1", amount=75},
        {type="item", name="middle-oil-barrel", amount=2},
        {type="item", name="nexelit-plate", amount=228},
        {type="item", name="pipe", amount=35},
      },
      results = {
        {type="item", name="ball-mill-mk01", amount=1},
      },
    },
    ["chemical-plant-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bolts", amount=62},
        {type="item", name="gasifier", amount=1},
        {type="item", name="grade-1-copper", amount=48},
        {type="item", name="intermetallics", amount=9},
        {type="item", name="lead-plate", amount=48},
        {type="item", name="lens", amount=24},
        {type="item", name="tinned-cable", amount=64},
        {type="item", name="wood-fence", amount=4},
      },
      results = {
        {type="item", name="chemical-plant-mk01", amount=2},
      },
    },
    ["classifier"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="chromite-sand", amount=433},
        {type="item", name="duralumin", amount=17},
        {type="item", name="moondrop-seeds", amount=48},
        {type="item", name="pipe", amount=175},
        {type="item", name="sap-tree", amount=2},
        {type="item", name="ti-rejects", amount=1},
      },
      results = {
        {type="item", name="classifier", amount=1},
      },
    },
    ["rectisol"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cocoon", amount=6},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="grade-1-tin", amount=12},
        {type="item", name="grade-3-ti", amount=5},
        {type="item", name="light-oil-canister", amount=4},
        {type="item", name="steam-engine", amount=2},
        {type="item", name="storage-tank", amount=2},
        {type="item", name="syngas-canister", amount=9},
        {type="item", name="titanium-plate", amount=169},
      },
      results = {
        {type="item", name="rectisol", amount=1},
      },
    },
    ["automated-factory-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=95},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="gearbox-mk01", amount=2},
        {type="item", name="inserter", amount=3},
        {type="item", name="intermetallics", amount=2},
        {type="item", name="py-tank-4000", amount=3},
        {type="item", name="titanium-plate", amount=20},
      },
      results = {
        {type="item", name="automated-factory-mk01", amount=1},
      },
    },
    ["fluid-drill-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bio-container", amount=9},
        {type="item", name="caged-vrauks", amount=3},
        {type="item", name="iron-plate", amount=118},
        {type="item", name="middle-oil-barrel", amount=2},
        {type="item", name="scrude-barrel", amount=33},
        {type="item", name="soil-extractor-mk01", amount=2},
        {type="item", name="syngas-canister", amount=5},
      },
      results = {
        {type="item", name="fluid-drill-mk02", amount=1},
      },
    },
    ["bof-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=6},
        {type="item", name="duralumin", amount=3},
        {type="item", name="inductor1", amount=75},
        {type="item", name="steel-plate", amount=9},
        {type="item", name="stone-furnace", amount=12},
      },
      results = {
        {type="item", name="bof-mk01", amount=1},
      },
    },
    ["casting-unit-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="distilator", amount=1},
        {type="item", name="duralumin", amount=13},
        {type="item", name="electronic-circuit", amount=13},
        {type="item", name="nexelit-plate", amount=130},
        {type="item", name="stone-furnace", amount=33},
        {type="item", name="vane-mk01", amount=1},
        {type="item", name="wood-fence", amount=5},
      },
      results = {
        {type="item", name="casting-unit-mk01", amount=1},
      },
    },
    ["eaf-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=1},
        {type="item", name="boric-acid-barrel", amount=7},
        {type="item", name="glass", amount=668},
        {type="item", name="intermetallics", amount=11},
        {type="item", name="jaw-crusher", amount=1},
        {type="item", name="middle-oil-canister", amount=18},
        {type="item", name="py-iron-oxide", amount=17},
      },
      results = {
        {type="item", name="eaf-mk01", amount=2},
      },
    },
    ["hydroclassifier-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="classifier", amount=2},
        {type="item", name="fenxsb-alloy", amount=80},
        {type="item", name="inductor1", amount=282},
        {type="item", name="nexelit-plate", amount=21},
        {type="item", name="quenching-tower", amount=1},
        {type="item", name="titanium-plate", amount=97},
        {type="item", name="vrauks", amount=2},
      },
      results = {
        {type="item", name="hydroclassifier-mk01", amount=2},
      },
    },
    ["impact-crusher-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="duralumin", amount=74},
        {type="item", name="engine-unit", amount=10},
        {type="item", name="glass", amount=501},
        {type="item", name="middle-oil-barrel", amount=4},
        {type="item", name="molten-glass-barrel", amount=7},
        {type="item", name="resistor1", amount=178},
        {type="item", name="seaweed-crop-mk01", amount=2},
        {type="item", name="solid-separator", amount=2},
      },
      results = {
        {type="item", name="impact-crusher-mk01", amount=3},
      },
    },
    ["scrubber-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=11},
        {type="item", name="boiler", amount=23},
        {type="item", name="distilator", amount=1},
        {type="item", name="duralumin", amount=56},
        {type="item", name="sulfur", amount=30},
        {type="item", name="transport-belt", amount=16},
      },
      results = {
        {type="item", name="scrubber-mk01", amount=1},
      },
    },
    ["flotation-cell-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=43},
        {type="item", name="assembling-machine-1", amount=2},
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="graphite", amount=179},
        {type="item", name="intermetallics", amount=19},
        {type="item", name="tinned-cable", amount=39},
      },
      results = {
        {type="item", name="flotation-cell-mk01", amount=2},
      },
    },
    ["cargo-wagon"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="biomass", amount=1444},
        {type="item", name="copper-ore", amount=1336},
        {type="item", name="duralumin", amount=10},
        {type="item", name="lens", amount=210},
        {type="item", name="py-limestone", amount=4},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="splitter", amount=6},
        {type="item", name="tailings-dust", amount=143},
      },
      results = {
        {type="item", name="cargo-wagon", amount=1},
      },
    },
    ["fluid-wagon"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bio-sample", amount=12},
        {type="item", name="boric-acid-barrel", amount=18},
        {type="item", name="coal-gas-barrel", amount=1},
        {type="item", name="fwf-mk01", amount=2},
        {type="item", name="moondrop-codex", amount=1},
        {type="item", name="nexelit-plate", amount=145},
        {type="item", name="programmable-speaker", amount=1},
        {type="item", name="seaweed-crop-mk01", amount=1},
        {type="item", name="slacked-lime-barrel", amount=2},
      },
      results = {
        {type="item", name="fluid-wagon", amount=1},
      },
    },
    ["locomotive"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="duralumin", amount=25},
        {type="item", name="fish-oil-barrel", amount=8},
        {type="item", name="hot-air-barrel", amount=53},
        {type="item", name="hydrogen-barrel", amount=36},
        {type="item", name="inductor1", amount=15},
        {type="item", name="lime", amount=306},
        {type="item", name="moondrop-seeds", amount=12},
        {type="item", name="pitch-barrel", amount=8},
        {type="item", name="pitch-canister", amount=14},
        {type="item", name="py-tank-7000", amount=3},
      },
      results = {
        {type="item", name="locomotive", amount=1},
      },
    },
    ["cooling-tower-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="glass", amount=20},
        {type="item", name="inductor1", amount=37},
        {type="item", name="intermetallics", amount=3},
        {type="item", name="lead-plate", amount=150},
        {type="item", name="nexelit-plate", amount=51},
      },
      results = {
        {type="item", name="cooling-tower-mk01", amount=1},
      },
    },
    ["fawogae-plantation-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=24},
        {type="item", name="coke", amount=59},
        {type="item", name="duralumin", amount=34},
        {type="item", name="glass", amount=118},
        {type="item", name="pipe", amount=10},
        {type="item", name="small-parts-01", amount=19},
        {type="item", name="tin-plate", amount=46},
      },
      results = {
        {type="item", name="fawogae-plantation-mk01", amount=1},
      },
    },
    ["prandium-lab-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=122},
        {type="item", name="concrete", amount=28},
        {type="item", name="copper-plate", amount=189},
        {type="item", name="pipe", amount=105},
        {type="item", name="rail-chain-signal", amount=2},
        {type="item", name="skin", amount=55},
        {type="item", name="steam-engine", amount=13},
        {type="item", name="titanium-plate", amount=14},
      },
      results = {
        {type="item", name="prandium-lab-mk01", amount=1},
      },
    },
    ["ralesia-plantation-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=3},
        {type="item", name="cellulose", amount=31},
        {type="item", name="creosote-barrel", amount=14},
        {type="item", name="fenxsb-alloy", amount=26},
        {type="item", name="lab", amount=1},
        {type="item", name="lead-plate", amount=48},
        {type="item", name="limestone", amount=134},
        {type="item", name="nexelit-plate", amount=22},
        {type="item", name="pipe", amount=104},
        {type="item", name="steel-plate", amount=99},
      },
      results = {
        {type="item", name="ralesia-plantation-mk01", amount=1},
      },
    },
    ["fish-farm-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="classifier", amount=1},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="inductor1", amount=706},
        {type="item", name="offshore-pump", amount=8},
        {type="item", name="plastic-bar", amount=39},
        {type="item", name="small-electric-pole", amount=210},
        {type="item", name="tin-plate", amount=95},
        {type="item", name="titanium-plate", amount=169},
      },
      results = {
        {type="item", name="fish-farm-mk01", amount=2},
      },
    },
    ["heavy-armor"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=46},
        {type="item", name="boric-acid-barrel", amount=10},
        {type="item", name="concrete", amount=27},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="glass", amount=295},
        {type="item", name="inductor1", amount=187},
        {type="item", name="stone-brick", amount=168},
      },
      results = {
        {type="item", name="heavy-armor", amount=1},
      },
    },
    ["mixer-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="distilator", amount=3},
        {type="item", name="duralumin", amount=8},
        {type="item", name="intermetallics", amount=9},
        {type="item", name="lead-plate", amount=96},
        {type="item", name="py-tank-6500", amount=2},
        {type="item", name="tin-plate", amount=118},
        {type="item", name="tinned-cable", amount=129},
      },
      results = {
        {type="item", name="mixer-mk01", amount=2},
      },
    },
    ["py-heat-exchanger"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=33},
        {type="item", name="duralumin", amount=17},
        {type="item", name="fenxsb-alloy", amount=26},
        {type="item", name="gasoline-barrel", amount=13},
        {type="item", name="jaw-crusher", amount=4},
        {type="item", name="py-tank-1000", amount=6},
        {type="item", name="titanium-plate", amount=192},
      },
      results = {
        {type="item", name="py-heat-exchanger", amount=1},
      },
    },
    ["secondary-crusher-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="automation-science-pack", amount=8},
        {type="item", name="burner-mining-drill", amount=3},
        {type="item", name="ceramic", amount=411},
        {type="item", name="inductor1", amount=187},
        {type="item", name="pipe", amount=175},
        {type="item", name="seaweed", amount=18},
      },
      results = {
        {type="item", name="secondary-crusher-mk01", amount=1},
      },
    },
    ["atomizer-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bio-container", amount=11},
        {type="item", name="bones", amount=62},
        {type="item", name="grade-1-nickel", amount=264},
        {type="item", name="naphthalene-oil-barrel", amount=4},
        {type="item", name="pressured-air-barrel", amount=14},
        {type="item", name="scrude-barrel", amount=11},
        {type="item", name="scrude-canister", amount=5},
        {type="item", name="tar-canister", amount=4},
      },
      results = {
        {type="item", name="atomizer-mk01", amount=1},
      },
    },
    ["bio-reactor-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=32},
        {type="item", name="concrete", amount=45},
        {type="item", name="electronic-circuit", amount=8},
        {type="item", name="lime", amount=408},
        {type="item", name="mixer-mk01", amount=1},
        {type="item", name="steam-engine", amount=4},
      },
      results = {
        {type="item", name="bio-reactor-mk01", amount=1},
      },
    },
    ["plankton-farm"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="engine-unit", amount=4},
        {type="item", name="fiberboard", amount=19},
        {type="item", name="gravel", amount=44},
        {type="item", name="lens", amount=8},
        {type="item", name="pipe", amount=20},
        {type="item", name="pump", amount=2},
        {type="item", name="soil-extractor-mk01", amount=3},
        {type="item", name="stone-furnace", amount=91},
        {type="item", name="water-barrel", amount=9},
      },
      results = {
        {type="item", name="plankton-farm", amount=1},
      },
    },
    ["spore-collector-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="concrete", amount=205},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="iron-plate", amount=20},
        {type="item", name="lab", amount=2},
        {type="item", name="tar-processing-unit", amount=1},
        {type="item", name="tinned-cable", amount=68},
        {type="item", name="titanium-plate", amount=12},
        {type="item", name="washer", amount=1},
      },
      results = {
        {type="item", name="spore-collector-mk01", amount=1},
      },
    },
    ["compost-plant-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="moondrop", amount=65},
        {type="item", name="pressured-air-barrel", amount=43},
        {type="item", name="py-limestone", amount=336},
        {type="item", name="rail-signal", amount=15},
        {type="item", name="raw-borax", amount=1022},
        {type="item", name="transport-belt", amount=78},
        {type="item", name="wpu-mk01", amount=4},
      },
      results = {
        {type="item", name="compost-plant-mk01", amount=1},
      },
    },
    ["oil-boiler-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coal", amount=1104},
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="gun-turret", amount=6},
        {type="item", name="iron-oxide", amount=12},
        {type="item", name="pipe", amount=70},
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="oil-boiler-mk01", amount=1},
      },
    },
    ["py-electric-boiler"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="clay", amount=217},
        {type="item", name="light-oil-barrel", amount=33},
        {type="item", name="pipe", amount=70},
        {type="item", name="scrude-barrel", amount=31},
        {type="item", name="stopper", amount=3},
      },
      results = {
        {type="item", name="py-electric-boiler", amount=1},
      },
    },
    ["rhe"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="concrete", amount=15},
        {type="item", name="duralumin", amount=7},
        {type="item", name="glass", amount=44},
        {type="item", name="inductor1", amount=40},
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="rhe", amount=1},
      },
    },
    ["personal-roboport-equipment"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="fiberboard", amount=37},
        {type="item", name="iron-plate", amount=237},
        {type="item", name="nexelit-plate", amount=685},
        {type="item", name="skin", amount=19},
        {type="item", name="steam-engine", amount=15},
      },
      results = {
        {type="item", name="personal-roboport-equipment", amount=1},
      },
    },
    ["portable-gasoline-generator"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="acetylene-barrel", amount=32},
        {type="item", name="grade-2-copper", amount=8},
        {type="item", name="small-electric-pole", amount=1},
        {type="item", name="vacuum-tube", amount=30},
        {type="item", name="vitreloy", amount=10},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="portable-gasoline-generator", amount=1},
      },
    },
    ["py-recharge-station-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=10},
        {type="item", name="iron-plate", amount=38},
        {type="item", name="lime", amount=204},
        {type="item", name="tinned-cable", amount=68},
        {type="item", name="vitreloy", amount=6},
        {type="item", name="vrauks", amount=1},
      },
      results = {
        {type="item", name="py-recharge-station-mk01", amount=1},
      },
    },
    ["py-roboport-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="brain", amount=32},
        {type="item", name="electronics-mk01", amount=2},
        {type="item", name="gasifier", amount=3},
        {type="item", name="gasoline-barrel", amount=15},
        {type="item", name="light-oil-canister", amount=18},
        {type="item", name="medium-electric-pole", amount=6},
      },
      results = {
        {type="item", name="py-roboport-mk01", amount=3},
      },
    },
    ["py-ze"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="duralumin", amount=17},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="glass", amount=70},
        {type="item", name="seaweed", amount=25},
      },
      results = {
        {type="item", name="py-ze", amount=1},
      },
    },
    ["salt-mine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="advanced-foundry-mk01", amount=13},
        {type="item", name="automated-factory-mk01", amount=4},
        {type="item", name="iron-plate", amount=63},
        {type="item", name="rhe", amount=2},
        {type="item", name="steam-engine", amount=37},
        {type="item", name="vitreloy", amount=26},
      },
      results = {
        {type="item", name="salt-mine", amount=1},
      },
    },
    ["dino-dig-site"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=68},
        {type="item", name="concrete", amount=161},
        {type="item", name="inductor1", amount=75},
        {type="item", name="pipe", amount=312},
        {type="item", name="rich-clay", amount=138},
        {type="item", name="steel-plate", amount=50},
      },
      results = {
        {type="item", name="dino-dig-site", amount=1},
      },
    },
    ["generator-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="agar", amount=21},
        {type="item", name="boric-acid-barrel", amount=22},
        {type="item", name="lime", amount=289},
        {type="item", name="methane-barrel", amount=17},
        {type="item", name="molten-aluminium-barrel", amount=3},
        {type="item", name="oxygen-barrel", amount=3},
        {type="item", name="pbsb-alloy", amount=5},
        {type="item", name="sb-grade-02", amount=113},
        {type="item", name="wood-seedling", amount=8},
      },
      results = {
        {type="item", name="generator-1", amount=2},
      },
    },
    ["pyphoon-bay"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bolts", amount=116},
        {type="item", name="ceramic", amount=74},
        {type="item", name="formica", amount=60},
        {type="item", name="gravel", amount=144},
        {type="item", name="pbsb-alloy", amount=9},
        {type="item", name="py-tank-1500", amount=4},
        {type="item", name="rail-signal", amount=8},
        {type="item", name="train-stop", amount=3},
      },
      results = {
        {type="item", name="pyphoon-bay", amount=2},
      },
    },
    ["belt"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=59},
      },
      results = {
        {type="item", name="belt", amount=2},
      },
    },
    ["polybutadiene"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=833},
        {type="fluid", name="scrude", amount=509},
        {type="item", name="titanium-plate", amount=1},
      },
      results = {
        {type="fluid", name="polybutadiene", amount=100},
        {type="fluid", name="steam", amount=1000},
      },
    },
    ["long-handed-inserter"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="chromite-sand", amount=74},
        {type="item", name="copper-ore", amount=156},
        {type="item", name="dried-meat", amount=15},
        {type="item", name="inserter", amount=2},
        {type="item", name="naphthalene-oil-canister", amount=1},
        {type="item", name="tar-canister", amount=2},
      },
      results = {
        {type="item", name="long-handed-inserter", amount=4},
      },
    },
    ["carbon-black"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="vacuum", amount=100},
        {type="fluid", name="water", amount=3148},
      },
      results = {
        {type="item", name="carbon-black", amount=4},
      },
    },
    ["engine-unit-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=34},
        {type="item", name="belt", amount=4},
        {type="item", name="iron-plate", amount=13},
        {type="item", name="steam-engine", amount=4},
      },
      results = {
        {type="item", name="engine-unit", amount=3},
      },
    },
    ["transport-belt-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1.13333333333333,
      ingredients = {
        {type="item", name="iron-plate", amount=6},
        {type="item", name="rubber", amount=3},
        {type="item", name="small-parts-01", amount=3},
      },
      results = {
        {type="item", name="transport-belt", amount=17},
      },
    },
    ["rubber-01"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="polybutadiene", amount=50},
        {type="item", name="carbon-black", amount=2},
        {type="item", name="latex", amount=1},
      },
      results = {
        {type="item", name="rubber", amount=1},
      },
    },
    ["depolymerized-organics"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=6933},
        {type="fluid", name="water", amount=11643},
      },
      results = {
        {type="fluid", name="depolymerized-organics", amount=100},
      },
    },
    ["subcritical-water-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=157},
        {type="item", name="biomass", amount=30},
      },
      results = {
        {type="fluid", name="subcritical-water", amount=50},
      },
    },
    ["electronic-circuit-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="battery-mk01", amount=1},
        {type="item", name="fiberboard", amount=1},
        {type="item", name="formica", amount=3},
        {type="item", name="small-parts-01", amount=4},
        {type="item", name="sodium-hydroxide", amount=7},
        {type="item", name="solder", amount=2},
        {type="item", name="vacuum-tube", amount=3},
      },
      results = {
        {type="item", name="electronic-circuit", amount=5},
      },
    },
    ["formica-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ceramic", amount=59},
        {type="item", name="fiberboard", amount=2},
      },
      results = {
        {type="item", name="formica", amount=5},
      },
    },
    ["hotair-empty-petri-dish"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="molten-glass", amount=50},
      },
      results = {
        {type="item", name="empty-petri-dish", amount=2},
      },
    },
    ["hotair-flask"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="molten-glass", amount=100},
        {type="item", name="petri-dish-bacteria", amount=6},
      },
      results = {
        {type="item", name="flask", amount=3},
      },
    },
    ["stopper-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="belt", amount=2},
      },
      results = {
        {type="item", name="stopper", amount=2},
      },
    },
    ["meat-to-tin"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="item", name="brain", amount=4},
      },
      results = {
        {type="item", name="ore-lead", amount=6},
      },
    },
    ["powdered-ralesia-seeds"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1.04,
      ingredients = {
        {type="fluid", name="steam", amount=68},
        {type="item", name="capacitor1", amount=1},
      },
      results = {
        {type="fluid", name="water-saline", amount=104},
      },
    },
    ["starch"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="fiberboard", amount=1},
        {type="item", name="powdered-ralesia-seeds", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
        {type="item", name="starch", amount=3},
      },
    },
    ["aerial-blimp-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="gasoline", amount=835},
        {type="item", name="brake-mk01", amount=1},
        {type="item", name="electronics-mk01", amount=3},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="gasifier", amount=18},
        {type="item", name="generator-1", amount=1},
        {type="item", name="inductor1", amount=23},
        {type="item", name="iron-plate", amount=235},
        {type="item", name="iron-stick", amount=49},
        {type="item", name="scrude-barrel", amount=41},
        {type="item", name="storage-tank", amount=2},
        {type="item", name="titanium-plate", amount=88},
      },
      results = {
        {type="item", name="aerial-blimp-mk01", amount=1},
      },
    },
    ["blood-to-iron"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="boric-acid", amount=595},
      },
      results = {
        {type="item", name="iron-ore", amount=10},
      },
    },
    ["fawogae-to-iron"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="raw-fiber", amount=2},
      },
      results = {
        {type="item", name="iron-ore", amount=5},
      },
    },
    ["bone-to-bonemeal-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=290},
        {type="item", name="brain", amount=3},
      },
      results = {
        {type="item", name="bonemeal", amount=5},
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=667},
        {type="fluid", name="steam", amount=219},
        {type="item", name="biomass", amount=10},
        {type="item", name="fish-egg", amount=10},
        {type="item", name="tinned-cable", amount=5},
      },
      results = {
        {type="fluid", name="waste-water", amount=100},
        {type="item", name="fish", amount=10},
      },
    },
    ["breed-fish-egg-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=143},
        {type="fluid", name="pressured-water", amount=5472},
        {type="item", name="seaweed", amount=273},
      },
      results = {
        {type="fluid", name="waste-water", amount=100},
        {type="item", name="fish-egg", amount=25},
      },
    },
    ["py-construction-robot-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="creamy-latex", amount=852},
        {type="item", name="carbon-black", amount=19},
        {type="item", name="cyanic-acid-barrel", amount=3},
        {type="item", name="empty-fuel-canister", amount=4},
        {type="item", name="geothermal-water-barrel", amount=19},
        {type="item", name="grade-1-lead", amount=40},
        {type="item", name="inductor1", amount=37},
        {type="item", name="iron-chest", amount=4},
        {type="item", name="lab", amount=1},
        {type="item", name="log", amount=120},
        {type="item", name="tin-plate", amount=26},
      },
      results = {
        {type="item", name="py-construction-robot-mk01", amount=1},
      },
    },
    ["liquid-manure"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=227},
        {type="item", name="dried-meat", amount=9},
      },
      results = {
        {type="fluid", name="liquid-manure", amount=100},
      },
    },
    ["zogna-bacteria"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="fluid", name="pressured-air", amount=60},
        {type="item", name="petri-dish-bacteria", amount=2},
        {type="item", name="small-lamp", amount=1},
        {type="item", name="wood", amount=6},
      },
      results = {
        {type="fluid", name="zogna-bacteria", amount=24},
      },
    },
    ["plasmids"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=7467},
        {type="item", name="lab-instrument", amount=1},
        {type="item", name="petri-dish", amount=1},
        {type="item", name="stopper", amount=2},
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
        {type="fluid", name="water", amount=655},
        {type="item", name="empty-petri-dish", amount=123},
        {type="item", name="nexelit-plate", amount=16},
        {type="item", name="petri-dish-bacteria", amount=2},
        {type="item", name="stopper", amount=3},
        {type="item", name="vrauks", amount=1},
      },
      results = {
        {type="item", name="retrovirus", amount=2},
      },
    },
    ["cdna"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bio-sample", amount=5},
        {type="item", name="cellulose", amount=3},
        {type="item", name="copper-cable", amount=145},
        {type="item", name="empty-petri-dish", amount=20},
        {type="item", name="lab-instrument", amount=1},
        {type="item", name="petri-dish", amount=6},
        {type="item", name="plasmids", amount=1},
        {type="item", name="steel-chest", amount=4},
      },
      results = {
        {type="item", name="cdna", amount=1},
      },
    },
    ["ralesia-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=833},
        {type="item", name="bio-sample", amount=5},
        {type="item", name="cdna", amount=3},
        {type="item", name="cottongut-codex", amount=1},
        {type="item", name="earth-mouse-sample", amount=1},
        {type="item", name="empty-planter-box", amount=2},
      },
      results = {
        {type="item", name="ralesia", amount=2},
      },
    },
    ["ralesia-seeds"] = {
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=233},
        {type="fluid", name="steam", amount=65},
        {type="item", name="coarse", amount=2},
        {type="item", name="ralesia-seeds", amount=8},
      },
      results = {
        {type="item", name="ralesia", amount=10},
      },
    },
    ["cottongut-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="concrete", amount=815},
        {type="item", name="glass", amount=2},
        {type="item", name="tinned-cable", amount=20},
        {type="item", name="wood", amount=59},
      },
      results = {
        {type="item", name="cottongut-codex", amount=1},
      },
    },
    ["cottongut-cub-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cottongut", amount=4},
        {type="item", name="moondrop-seeds", amount=5},
        {type="item", name="ralesia", amount=10},
        {type="item", name="water-barrel", amount=3},
      },
      results = {
        {type="item", name="barrel", amount=3},
        {type="item", name="cottongut-pup", amount=10},
      },
    },
    ["cottongut"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="vacuum", amount=3778},
        {type="item", name="cdna", amount=6},
        {type="item", name="earth-bear-sample", amount=1},
        {type="item", name="earth-flower-sample", amount=2},
        {type="item", name="grade-2-ti", amount=41},
        {type="item", name="ralesia-codex", amount=2},
      },
      results = {
        {type="item", name="cottongut-mk01", amount=2},
      },
    },
    ["cottongut-food-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=105},
        {type="item", name="powdered-ralesia-seeds", amount=2},
        {type="item", name="ralesia", amount=1},
        {type="item", name="soil", amount=14},
        {type="item", name="tin-plate", amount=2},
        {type="item", name="wood", amount=8},
      },
      results = {
        {type="item", name="cottongut-food-01", amount=4},
      },
    },
    ["cottongut-science-red-seeds"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=16537},
        {type="item", name="cellulose", amount=7},
        {type="item", name="cottongut", amount=20},
        {type="item", name="grade-2-copper", amount=2},
        {type="item", name="retrovirus", amount=1},
      },
      results = {
        {type="item", name="solidified-sarcorus", amount=3},
      },
    },
    ["cottongut-pup-mk01-raising"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1.83495120910117,
      ingredients = {
        {type="item", name="cottongut-food-01", amount=2},
        {type="item", name="cottongut-mk01", amount=4},
        {type="item", name="fish-egg", amount=4},
        {type="item", name="limestone", amount=22},
      },
      results = {
        {type="item", name="cottongut-mk01", amount=3},
        {type="item", name="cottongut-pup", amount=1},
        {type="item", name="cottongut-pup-mk01", amount=8},
      },
    },
    ["cottongut-mature-basic-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cottongut-food-01", amount=1},
        {type="item", name="cottongut-pup", amount=1},
        {type="item", name="moondrop-seeds", amount=8},
        {type="item", name="stone-furnace", amount=1},
      },
      results = {
        {type="item", name="cottongut-mk01", amount=1},
      },
    },
    ["logistic-science-pack"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="alien-sample01", amount=2},
        {type="item", name="animal-sample-01", amount=2},
        {type="item", name="melamine-resin", amount=36},
        {type="item", name="moondrop", amount=63},
      },
      results = {
        {type="item", name="logistic-science-pack", amount=12},
      },
    },
    ["workers-food"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=4702},
        {type="fluid", name="water", amount=142},
        {type="item", name="clean-nexelit", amount=2},
        {type="item", name="lead-plate", amount=4},
        {type="item", name="meat", amount=15},
        {type="item", name="soil", amount=19},
        {type="item", name="tar-barrel", amount=1},
        {type="item", name="tinned-cable", amount=3},
        {type="item", name="water-saline-barrel", amount=3},
      },
      results = {
        {type="item", name="workers-food", amount=3},
      },
    },
    ["auog-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="concrete", amount=163},
        {type="item", name="gravel", amount=5},
        {type="item", name="seaweed", amount=90},
        {type="item", name="tin-plate", amount=37},
      },
      results = {
        {type="item", name="auog-codex", amount=1},
      },
    },
    ["auog-paddock-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="brake-mk01", amount=2},
        {type="item", name="iron-gear-wheel", amount=34},
        {type="item", name="iron-plate", amount=226},
        {type="item", name="iron-stick", amount=174},
        {type="item", name="sand", amount=500},
      },
      results = {
        {type="item", name="auog-paddock-mk01", amount=3},
      },
    },
    ["auog-pooping-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1.02883601600353,
      ingredients = {
        {type="item", name="moss", amount=10},
        {type="item", name="seaweed", amount=10},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="manure", amount=6},
      },
    },
    ["auog-pup-breeding-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1.03569547936802,
      ingredients = {
        {type="item", name="copper-ore", amount=20},
        {type="item", name="moss", amount=10},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="auog-pup", amount=4},
        {type="item", name="barrel", amount=5},
      },
    },
    ["auog"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=175},
        {type="item", name="automation-science-pack", amount=46},
        {type="item", name="bio-sample", amount=5},
        {type="item", name="earth-mouse-sample", amount=1},
        {type="item", name="retrovirus", amount=12},
        {type="item", name="vrauks-codex", amount=2},
      },
      results = {
        {type="item", name="auog", amount=1},
      },
    },
    ["auog-food-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=100},
        {type="item", name="native-flora", amount=5},
        {type="item", name="pipe", amount=11},
        {type="item", name="ralesia-seeds", amount=8},
        {type="item", name="seaweed", amount=3},
        {type="item", name="stone-brick", amount=5},
      },
      results = {
        {type="item", name="auog-food-01", amount=3},
      },
    },
    ["auog-maturing-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-food-01", amount=1},
        {type="item", name="auog-pup", amount=4},
        {type="item", name="ralesia", amount=2},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="auog", amount=3},
        {type="item", name="barrel", amount=5},
      },
    },
    ["auog-recharge-00"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bonemeal", amount=3},
        {type="item", name="guts", amount=8},
        {type="item", name="moss", amount=10},
      },
      results = {
        {type="item", name="auog", amount=2},
      },
    },
    ["auog-maturing-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1.05748304860864,
      ingredients = {
        {type="item", name="auog-food-01", amount=3},
        {type="item", name="auog-pup", amount=8},
        {type="item", name="moss", amount=10},
        {type="item", name="petri-dish", amount=1},
        {type="item", name="ti-rejects", amount=1},
        {type="item", name="vacuum-barrel", amount=5},
      },
      results = {
        {type="item", name="auog", amount=6},
        {type="item", name="barrel", amount=5},
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-food-01", amount=3},
        {type="item", name="saps", amount=3},
        {type="item", name="seaweed", amount=17},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="auog-pup", amount=6},
        {type="item", name="barrel", amount=5},
      },
    },
    ["auog-recharge-0"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="auog-food-01", amount=2},
        {type="item", name="hydrogen-barrel", amount=3},
        {type="item", name="moss", amount=9},
      },
      results = {
        {type="item", name="auog", amount=2},
      },
    },
    ["fertilizer-4"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="zogna-bacteria", amount=20},
        {type="item", name="biomass", amount=10},
        {type="item", name="manure", amount=10},
      },
      results = {
        {type="item", name="fertilizer", amount=5},
      },
    },
    ["urea-from-liquid-manure"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=7594},
        {type="fluid", name="water", amount=3733},
      },
      results = {
        {type="item", name="urea", amount=30},
      },
    },
    ["melamine-resin"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="methanal", amount=50},
        {type="item", name="ceramic", amount=30},
        {type="item", name="urea", amount=5},
      },
      results = {
        {type="item", name="melamine-resin", amount=10},
      },
    },
    ["fawogae-1"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2.5,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=895},
        {type="item", name="earth-bear-sample", amount=2},
        {type="item", name="ground-sample01", amount=5},
        {type="item", name="moondrop-seeds", amount=11},
        {type="item", name="vrauks-codex", amount=19},
        {type="item", name="wooden-chest", amount=50},
      },
      results = {
        {type="item", name="fawogae", amount=5},
      },
    },
    ["boron-trioxide"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=143},
        {type="item", name="limestone", amount=1},
      },
      results = {
        {type="item", name="boron-trioxide", amount=1},
      },
    },
    ["coke-coal"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="raw-coal", amount=10},
      },
      results = {
        {type="fluid", name="coke-oven-gas", amount=20},
        {type="item", name="coke", amount=4},
      },
    },
    ["coal-fawogae"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=742},
        {type="fluid", name="hot-air", amount=50},
        {type="item", name="lime", amount=4},
      },
      results = {
        {type="item", name="lens", amount=4},
      },
    },
    ["lens"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=1071},
        {type="item", name="gunpowder", amount=1},
      },
      results = {
        {type="item", name="lens", amount=3},
      },
    },
    ["vrauks-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cocoon", amount=20},
        {type="item", name="methane-barrel", amount=1},
        {type="item", name="seaweed", amount=14},
        {type="item", name="vrauks-food-01", amount=2},
        {type="item", name="water-barrel", amount=3},
      },
      results = {
        {type="item", name="barrel", amount=3},
        {type="item", name="vrauks", amount=4},
      },
    },
    ["vrauks-food-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=153},
        {type="item", name="ash", amount=7},
        {type="item", name="fawogae-substrate", amount=5},
        {type="item", name="lime", amount=15},
        {type="item", name="moss", amount=10},
        {type="item", name="pipe", amount=3},
        {type="item", name="wood", amount=9},
      },
      results = {
        {type="item", name="vrauks-food-01", amount=4},
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1.4724285767718,
      ingredients = {
        {type="item", name="caged-vrauks", amount=3},
        {type="item", name="empty-petri-dish", amount=5},
        {type="item", name="log", amount=1},
        {type="item", name="vrauks-food-01", amount=3},
        {type="item", name="water-barrel", amount=7},
      },
      results = {
        {type="item", name="barrel", amount=7},
        {type="item", name="vrauks", amount=2},
        {type="item", name="vrauks-mk02", amount=0.00694747747186569},
      },
    },
    ["vrauks-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1.04268128936639,
      ingredients = {
        {type="item", name="cocoon", amount=33},
        {type="item", name="moss", amount=4},
        {type="item", name="soil", amount=69},
        {type="item", name="vrauks-food-01", amount=4},
        {type="item", name="vrauks-mk02", amount=1},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="vrauks-mk02", amount=2},
      },
    },
    ["vrauks-mk02-cocoon"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1.05825901105859,
      ingredients = {
        {type="item", name="native-flora", amount=15},
        {type="item", name="soil", amount=69},
        {type="item", name="vrauks-food-01", amount=4},
        {type="item", name="vrauks-mk02", amount=2},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="cocoon-mk02", amount=6},
        {type="item", name="vrauks-mk02", amount=2},
      },
    },
    ["warm-stone-brick-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=100},
        {type="item", name="refined-concrete", amount=2},
      },
      results = {
        {type="fluid", name="coke-oven-gas", amount=100},
        {type="item", name="warm-stone-brick", amount=5},
      },
    },
    ["warm-air-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="vacuum", amount=120},
        {type="item", name="carbon-black", amount=7},
      },
      results = {
        {type="fluid", name="hot-air", amount=150},
        {type="item", name="stone-brick", amount=20},
      },
    },
    ["waste-water-void"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="manure", amount=10},
        {type="item", name="phytoplankton-barrel", amount=1},
      },
      results = {
        {type="item", name="active-provider-chest", amount=1},
      },
    },
    ["buffer-chest"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="lime", amount=13},
        {type="item", name="stone-brick", amount=57},
      },
      results = {
        {type="item", name="buffer-chest", amount=1},
      },
    },
    ["passive-provider-chest"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="electronic-circuit", amount=3},
        {type="item", name="empty-barrel-milk", amount=6},
      },
      results = {
        {type="item", name="passive-provider-chest", amount=1},
      },
    },
    ["requester-chest"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="processed-iron-ore", amount=21},
        {type="item", name="small-parts-01", amount=32},
      },
      results = {
        {type="item", name="requester-chest", amount=1},
      },
    },
    ["aromatic-organic"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="fertilizer", amount=9},
        {type="item", name="ralesia-seeds", amount=6},
      },
      results = {
        {type="fluid", name="aromatics", amount=200},
      },
    },
    ["ash-bone"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="mukmoux-fat", amount=2},
      },
      results = {
        {type="item", name="ash", amount=4},
      },
    },
    ["ash3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ralesia-seeds", amount=5},
      },
      results = {
        {type="item", name="ash", amount=15},
      },
    },
    ["coal-dust3"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="raw-fiber", amount=10},
      },
      results = {
        {type="item", name="coal-dust", amount=20},
      },
    },
    ["fluegas-filtration"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=100},
      },
      results = {
        {type="item", name="ash", amount=2},
      },
    },
    ["grade-3-tin"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="grade-2-tin", amount=2},
      },
      results = {
        {type="item", name="grade-3-tin", amount=2},
        {type="item", name="tin-ore-rejects", amount=1},
      },
    },
    ["tin-ore-rejects"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2.02142065109199,
      ingredients = {
        {type="fluid", name="water", amount=206},
        {type="item", name="grade-1-tin", amount=5},
      },
      results = {
        {type="fluid", name="tailings", amount=206},
        {type="item", name="grade-4-tin", amount=2},
      },
    },
    ["ball-grade-4-tin"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="propene-barrel", amount=2},
      },
      results = {
        {type="item", name="tin-dust", amount=3},
      },
    },
    ["tin-plate-4"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="acidgas-barrel", amount=4},
      },
      results = {
        {type="item", name="tin-plate", amount=8},
      },
    },
    ["molten-tin-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coke", amount=22},
        {type="item", name="limestone", amount=5},
        {type="item", name="rail", amount=23},
      },
      results = {
        {type="fluid", name="molten-tin", amount=30},
      },
    },
    ["hotair-tin-plate-3"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="molten-tin", amount=100},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="tin-plate", amount=63},
      },
    },
    ["tin-plate-3"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="molten-tin", amount=100},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="tin-plate", amount=50},
      },
    },
    ["carbon-filter"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="diborane-barrel", amount=8},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="hot-air-barrel", amount=1},
        {type="item", name="lab", amount=2},
        {type="item", name="methane-barrel", amount=19},
        {type="item", name="tall-oil-canister", amount=2},
      },
      results = {
        {type="item", name="carbon-filter", amount=1},
      },
    },
    ["fts-reactor"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aromatics-barrel", amount=1},
        {type="item", name="boiler", amount=8},
        {type="item", name="burner-inserter", amount=1},
        {type="item", name="carbon-black", amount=9},
        {type="item", name="nexelit-plate", amount=299},
        {type="item", name="resistor1", amount=296},
        {type="item", name="stone-brick", amount=21},
        {type="item", name="titanium-plate", amount=13},
      },
      results = {
        {type="item", name="fts-reactor", amount=1},
      },
    },
    ["methanol-reactor"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="duralumin", amount=3},
        {type="item", name="flora-collector-mk01", amount=3},
        {type="item", name="nexelit-plate", amount=127},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="titanium-plate", amount=44},
      },
      results = {
        {type="item", name="methanol-reactor", amount=1},
      },
    },
    ["fluid-separator"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="burner-inserter", amount=4},
        {type="item", name="concrete", amount=40},
        {type="item", name="constant-combinator", amount=4},
        {type="item", name="evaporator", amount=3},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="storage-tank", amount=4},
      },
      results = {
        {type="item", name="fluid-separator", amount=1},
      },
    },
    ["chromite-rejects-processing"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="fluid", name="steam", amount=84},
        {type="item", name="grade-2-chromite", amount=1},
      },
      results = {
        {type="item", name="chromite-rejects", amount=5},
        {type="item", name="grade-4-chromite", amount=5},
      },
    },
    ["grade-3-chromite"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=186},
        {type="item", name="chromite-sand", amount=23},
      },
      results = {
        {type="fluid", name="iron-pulp-01", amount=50},
        {type="fluid", name="iron-slime", amount=50},
      },
    },
    ["grade-2-iron"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="tar", amount=272},
        {type="item", name="gravel", amount=556},
      },
      results = {
        {type="fluid", name="iron-slime", amount=50},
      },
    },
    ["unslimed-iron"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="iron-slime", amount=100},
        {type="fluid", name="steam", amount=67},
      },
      results = {
        {type="fluid", name="tailings", amount=100},
        {type="item", name="unslimed-iron", amount=1},
      },
    },
    ["grade-2-crush"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-ore", amount=10},
      },
      results = {
        {type="item", name="iron-ore-dust", amount=1},
      },
    },
    ["molten-iron-06"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=255},
        {type="item", name="chromium", amount=3},
        {type="item", name="grade-1-iron", amount=7},
      },
      results = {
        {type="fluid", name="molten-iron", amount=40},
      },
    },
    ["unslimed-iron-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=67},
        {type="fluid", name="sulfuric-acid", amount=456},
      },
      results = {
        {type="fluid", name="tailings", amount=100},
        {type="item", name="unslimed-iron", amount=1},
      },
    },
    ["classify-low-grade"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 3.03846153846154,
      ingredients = {
        {type="item", name="grade-2-copper", amount=26},
      },
      results = {
        {type="item", name="copper-low-dust", amount=3},
        {type="item", name="grade-4-copper", amount=1},
      },
    },
    ["copper-rejects-recrush"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="grade-2-copper", amount=5},
      },
      results = {
        {type="item", name="grade-3-copper", amount=1},
        {type="item", name="gravel", amount=2},
      },
    },
    ["grade-3-copper"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-ore", amount=6},
      },
      results = {
        {type="item", name="copper-rejects", amount=1},
        {type="item", name="grade-3-copper", amount=1},
      },
    },
    ["grade-4-copper"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="pressured-water", amount=26300},
        {type="item", name="pure-sand", amount=5},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="copper-plate", amount=75},
      },
    },
    ["wash-coper-low-dust"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.9834644241638,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=241},
        {type="item", name="iron-chest", amount=5},
      },
      results = {
        {type="fluid", name="tailings", amount=390},
        {type="item", name="low-grade-copper", amount=2},
      },
    },
    ["copper-plate-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ammonia", amount=1020},
        {type="item", name="coke", amount=5},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="copper-plate", amount=60},
      },
    },
    ["low-grade-smelting-copper"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 3.33333333333333,
      ingredients = {
        {type="item", name="low-grade-copper", amount=3},
      },
      results = {
        {type="item", name="copper-plate", amount=2},
      },
    },
    ["molten-copper-04"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 0.952380952380952,
      ingredients = {
        {type="fluid", name="hydrogen", amount=117},
        {type="item", name="light-oil-canister", amount=3},
        {type="item", name="raw-borax", amount=4},
      },
      results = {
        {type="fluid", name="molten-copper", amount=20},
      },
    },
    ["coalbed-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-codex", amount=1},
        {type="item", name="chemical-plant-mk01", amount=1},
        {type="item", name="chlorine-barrel", amount=3},
        {type="item", name="grade-3-copper", amount=3},
        {type="item", name="medium-electric-pole", amount=55},
        {type="item", name="methanal-barrel", amount=13},
        {type="item", name="titanium-plate", amount=67},
        {type="item", name="vitreloy", amount=1},
      },
      results = {
        {type="item", name="coalbed-mk01", amount=1},
      },
    },
    ["lor-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="distilator", amount=1},
        {type="item", name="dried-meat", amount=154},
        {type="item", name="fawogae-spore", amount=19},
        {type="item", name="formic-acid-barrel", amount=6},
        {type="item", name="nexelit-plate", amount=51},
        {type="item", name="plastic-bar", amount=613},
        {type="item", name="py-limestone", amount=3},
        {type="item", name="steel-chest", amount=4},
        {type="item", name="titanium-plate", amount=13},
      },
      results = {
        {type="item", name="lor-mk01", amount=1},
      },
    },
    ["natural-gas-derrick-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="acidgas-barrel", amount=3},
        {type="item", name="burner-inserter", amount=1},
        {type="item", name="carbon-dioxide-barrel", amount=9},
        {type="item", name="inductor1", amount=37},
        {type="item", name="iron-stick", amount=48},
        {type="item", name="shotgun-shell", amount=118},
      },
      results = {
        {type="item", name="natural-gas-derrick-mk01", amount=1},
      },
    },
    ["oil-derrick-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="carbon-dioxide-barrel", amount=6},
        {type="item", name="empty-gas-canister", amount=108},
        {type="item", name="iron-stick", amount=49},
        {type="item", name="py-sinkhole", amount=1},
        {type="item", name="raw-borax", amount=65},
        {type="item", name="sb-grade-04", amount=37},
        {type="item", name="steel-plate", amount=20},
      },
      results = {
        {type="item", name="oil-derrick-mk01", amount=2},
      },
    },
    ["oil-sand-extractor-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anthracene-oil-barrel", amount=3},
        {type="item", name="chitin", amount=15},
        {type="item", name="engine-unit", amount=10},
        {type="item", name="liquid-manure-barrel", amount=8},
        {type="item", name="ore-lead", amount=38},
        {type="item", name="syngas-canister", amount=1},
        {type="item", name="tar-canister", amount=8},
        {type="item", name="vitreloy", amount=5},
      },
      results = {
        {type="item", name="oil-sand-extractor-mk01", amount=1},
      },
    },
    ["pumpjack-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="diborane-barrel", amount=16},
        {type="item", name="long-handed-inserter", amount=3},
        {type="item", name="offshore-pump", amount=4},
        {type="item", name="pressured-water-barrel", amount=24},
        {type="item", name="storage-tank", amount=4},
        {type="item", name="tinned-cable", amount=75},
      },
      results = {
        {type="item", name="pumpjack-mk01", amount=3},
      },
    },
    ["tar-extractor-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anthracene-oil-barrel", amount=3},
        {type="item", name="auog-pup", amount=15},
        {type="item", name="coke", amount=9},
        {type="item", name="creamy-latex-barrel", amount=3},
        {type="item", name="grade-2-chromite", amount=6},
        {type="item", name="moondrop-seeds", amount=35},
        {type="item", name="oil-sand", amount=537},
        {type="item", name="py-shed-basic", amount=2},
        {type="item", name="ralesia-codex", amount=1},
      },
      results = {
        {type="item", name="tar-extractor-mk01", amount=1},
      },
    },
    ["coarse-coal"] = {
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="raw-coal", amount=47},
      },
      results = {
        {type="item", name="coal", amount=4},
      },
    },
    ["cog-void-soot"] = {
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coal", amount=51},
        {type="item", name="duralumin", amount=30},
        {type="item", name="iron-plate", amount=275},
        {type="item", name="lead-plate", amount=31},
        {type="item", name="navens-spore", amount=53},
        {type="item", name="pbsb-alloy", amount=15},
        {type="item", name="soil-extractor-mk01", amount=3},
        {type="item", name="stone-brick", amount=24},
      },
      results = {
        {type="item", name="ez-ranch-mk01", amount=1},
      },
    },
    ["kicalk-plantation-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="concrete", amount=324},
        {type="item", name="incubator-mk01", amount=1},
        {type="item", name="iron-plate", amount=73},
        {type="item", name="lens", amount=7},
        {type="item", name="nexelit-plate", amount=153},
      },
      results = {
        {type="item", name="kicalk-plantation-mk01", amount=1},
      },
    },
    ["tuuphra-plantation-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boiler", amount=8},
        {type="item", name="concrete", amount=28},
        {type="item", name="fenxsb-alloy", amount=1},
        {type="item", name="nickel-plate", amount=34},
        {type="item", name="resistor1", amount=148},
        {type="item", name="seaweed", amount=25},
        {type="item", name="small-parts-01", amount=469},
        {type="item", name="yaedols-spores", amount=70},
      },
      results = {
        {type="item", name="tuuphra-plantation-mk01", amount=1},
      },
    },
    ["yaedols-culture-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=334},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="landfill", amount=8},
        {type="item", name="lead-plate", amount=186},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="nexelit-plate", amount=162},
        {type="item", name="small-lamp", amount=5},
        {type="item", name="zogna-bacteria-barrel", amount=27},
      },
      results = {
        {type="item", name="yaedols-culture-mk01", amount=1},
      },
    },
    ["crawdad"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="fish-oil", amount=263},
        {type="fluid", name="methanal", amount=363},
        {type="item", name="caged-vrauks", amount=1},
        {type="item", name="glass", amount=9096},
        {type="item", name="limestone", amount=419},
        {type="item", name="moss-gen", amount=30},
        {type="item", name="powdered-ralesia-seeds", amount=467},
        {type="item", name="pump", amount=20},
        {type="item", name="py-tank-4000", amount=12},
        {type="item", name="titanium-plate", amount=86},
      },
      results = {
        {type="item", name="crawdad", amount=1},
      },
    },
    ["sponge-culture-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="barrel", amount=11},
        {type="item", name="copper-plate", amount=7},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="fawogae", amount=21},
        {type="item", name="fiberboard", amount=56},
        {type="item", name="lead-plate", amount=12},
        {type="item", name="pbsb-alloy", amount=29},
        {type="item", name="pump", amount=8},
        {type="item", name="tinned-cable", amount=82},
        {type="item", name="vane-mk01", amount=1},
      },
      results = {
        {type="item", name="sponge-culture-mk01", amount=1},
      },
    },
    ["crushing-molybdenite"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.1809641597018,
      ingredients = {
        {type="item", name="empty-comb", amount=2},
      },
      results = {
        {type="item", name="crushed-molybdenite", amount=6},
        {type="item", name="stone", amount=2},
      },
    },
    ["duralumin-2"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=362},
        {type="item", name="coal-dust", amount=4},
        {type="item", name="coarse", amount=3},
        {type="item", name="gravel", amount=49},
        {type="item", name="log", amount=1},
      },
      results = {
        {type="item", name="empty-comb", amount=7},
      },
    },
    ["fish-food-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=300},
        {type="item", name="brain", amount=1},
        {type="item", name="chromium", amount=8},
        {type="item", name="fertilizer", amount=4},
        {type="item", name="guts", amount=10},
        {type="item", name="mukmoux-fat", amount=4},
        {type="item", name="plastic-bar", amount=6},
        {type="item", name="saps", amount=1},
        {type="item", name="tar-barrel", amount=1},
      },
      results = {
        {type="item", name="fish-food-01", amount=3},
      },
    },
    ["flask-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="molten-glass", amount=120},
        {type="item", name="calcium-carbide", amount=42},
        {type="item", name="stopper", amount=4},
      },
      results = {
        {type="item", name="flask", amount=4},
      },
    },
    ["hotair-flask-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="molten-glass", amount=120},
        {type="item", name="boron-trioxide", amount=5},
        {type="item", name="stopper", amount=4},
      },
      results = {
        {type="item", name="flask", amount=5},
      },
    },
    ["grade-2-lead-crusher"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-1-lead", amount=2},
      },
      results = {
        {type="item", name="grade-2-lead", amount=1},
        {type="item", name="stone", amount=1},
      },
    },
    ["grade-2-lead"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.31111111111111,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=2},
        {type="item", name="lime", amount=2},
        {type="item", name="melamine", amount=9},
      },
      results = {
        {type="fluid", name="molten-lead", amount=118},
      },
    },
    ["hotair-lead-plate-3"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="molten-lead", amount=100},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="lead-plate", amount=63},
      },
    },
    ["lead-plate-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="benzene", amount=1029},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="lead-plate", amount=50},
      },
    },
    ["grade-3-zinc"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 0.999580933591305,
      ingredients = {
        {type="fluid", name="water", amount=194},
        {type="item", name="grade-1-zinc", amount=5},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=49},
        {type="item", name="grade-3-zinc", amount=5},
      },
    },
    ["molten-zinc-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=1596},
        {type="item", name="grade-2-zinc", amount=4},
        {type="item", name="pure-sand", amount=4},
      },
      results = {
        {type="fluid", name="molten-zinc", amount=20},
      },
    },
    ["zinc-plate-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="molten-glass", amount=490},
        {type="item", name="coke", amount=5},
        {type="item", name="graphite", amount=1},
      },
      results = {
        {type="item", name="zinc-plate", amount=50},
      },
    },
    ["hotair-zinc-plate-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="methanol", amount=1302},
        {type="item", name="coke", amount=5},
        {type="item", name="graphite", amount=1},
      },
      results = {
        {type="item", name="zinc-plate", amount=63},
      },
    },
    ["molten-solder-0"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=1778},
        {type="fluid", name="molten-tin", amount=10},
      },
      results = {
        {type="fluid", name="molten-solder", amount=20},
      },
    },
    ["molten-solder-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=158},
        {type="fluid", name="molten-tin", amount=10},
        {type="fluid", name="water-saline", amount=478},
      },
      results = {
        {type="fluid", name="molten-solder", amount=40},
      },
    },
    ["solder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=7588},
      },
      results = {
        {type="item", name="solder", amount=5},
      },
    },
    ["hotair-solder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="water-saline", amount=915},
      },
      results = {
        {type="item", name="solder", amount=7},
      },
    },
    ["molten-steel"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=327},
        {type="fluid", name="molten-iron", amount=50},
        {type="item", name="tailings-dust", amount=4},
      },
      results = {
        {type="fluid", name="flue-gas", amount=500},
        {type="fluid", name="molten-steel", amount=50},
      },
    },
    ["hotair-steel-20"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="oxygen", amount=2145},
        {type="item", name="sand-casting", amount=2},
      },
      results = {
        {type="item", name="steel-plate", amount=32},
      },
    },
    ["steel-20"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="molten-steel", amount=100},
        {type="item", name="sand-casting", amount=2},
      },
      results = {
        {type="item", name="steel-plate", amount=25},
      },
    },
    ["kicalk-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=72},
        {type="item", name="copper-cable", amount=58},
        {type="item", name="electronic-circuit", amount=50},
        {type="item", name="pipe", amount=2},
      },
      results = {
        {type="item", name="kicalk-codex", amount=1},
      },
    },
    ["tuuphra-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=20},
        {type="item", name="copper-cable", amount=58},
        {type="item", name="pipe", amount=2},
        {type="item", name="steel-plate", amount=518},
      },
      results = {
        {type="item", name="tuuphra-codex", amount=1},
      },
    },
    ["yaedols-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=20},
        {type="item", name="pipe", amount=2},
        {type="item", name="small-parts-01", amount=535},
      },
      results = {
        {type="item", name="yaedols-codex", amount=1},
      },
    },
    ["sea-sponge-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=58},
        {type="item", name="electronic-circuit", amount=50},
        {type="item", name="lead-plate", amount=2},
        {type="item", name="small-parts-01", amount=14},
      },
      results = {
        {type="item", name="sea-sponge-codex", amount=1},
      },
    },
    ["lard-from-brains"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="guts", amount=39},
      },
      results = {
        {type="item", name="mukmoux-fat", amount=10},
      },
    },
    ["leaching-station-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="glass", amount=28},
        {type="item", name="grade-3-zinc", amount=4},
        {type="item", name="gun-turret", amount=1},
        {type="item", name="nexelit-plate", amount=110},
        {type="item", name="py-tank-9000", amount=3},
        {type="item", name="steam-engine", amount=9},
        {type="item", name="vitreloy", amount=11},
      },
      results = {
        {type="item", name="leaching-station-mk01", amount=2},
      },
    },
    ["wet-scrubber-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="duralumin", amount=99},
        {type="item", name="iron-stick", amount=73},
        {type="item", name="nexelit-plate", amount=31},
        {type="item", name="py-tank-10000", amount=2},
        {type="item", name="resistor1", amount=209},
        {type="item", name="tar-processing-unit", amount=2},
        {type="item", name="yaedols-spores", amount=23},
      },
      results = {
        {type="item", name="wet-scrubber-mk01", amount=3},
      },
    },
    ["methanol-from-syngas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=590},
        {type="item", name="bolts", amount=3},
        {type="item", name="copper-ore", amount=9},
      },
      results = {
        {type="fluid", name="methanol", amount=150},
      },
    },
    ["formamide"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=100},
        {type="fluid", name="geothermal-water", amount=1861},
        {type="fluid", name="methanol", amount=100},
      },
      results = {
        {type="fluid", name="formamide", amount=100},
        {type="fluid", name="methanol", amount=100},
      },
    },
    ["military-science-pack"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=1},
        {type="item", name="firearm-magazine", amount=2},
        {type="item", name="lead-plate", amount=20},
        {type="item", name="stone-wall", amount=2},
      },
      results = {
        {type="item", name="military-science-pack", amount=2},
      },
    },
    ["niobium-mine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="distilator", amount=3},
        {type="item", name="hpf", amount=1},
        {type="item", name="lead-plate", amount=301},
        {type="item", name="processed-iron-ore", amount=75},
        {type="item", name="small-parts-01", amount=15},
        {type="item", name="steam-engine", amount=22},
      },
      results = {
        {type="item", name="niobium-mine", amount=1},
      },
    },
    ["nxsb-alloy"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="limestone", amount=31},
        {type="item", name="sb-oxide", amount=10},
      },
      results = {
        {type="item", name="nxsb-alloy", amount=3},
      },
    },
    ["pbsb-alloy-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="refsyngas", amount=628},
        {type="item", name="cellulose", amount=26},
      },
      results = {
        {type="item", name="pbsb-alloy", amount=5},
      },
    },
    ["powdered-phosphate-rock"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=223},
        {type="item", name="coal-dust", amount=4},
        {type="item", name="stone", amount=10},
      },
      results = {
        {type="item", name="stone-wool", amount=1},
      },
    },
    ["stone-wool2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=1165},
        {type="item", name="calcium-carbide", amount=2},
        {type="item", name="coal-dust", amount=9},
      },
      results = {
        {type="item", name="stone-wool", amount=1},
      },
    },
    ["zipir-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=14},
        {type="item", name="iron-stick", amount=25},
        {type="item", name="steel-plate", amount=52},
        {type="item", name="tin-plate", amount=5},
      },
      results = {
        {type="item", name="zipir-codex", amount=2},
      },
    },
    ["zipir-eggs-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=2786},
        {type="fluid", name="pressured-water", amount=60},
        {type="item", name="fish", amount=5},
        {type="item", name="urea", amount=5},
      },
      results = {
        {type="fluid", name="waste-water", amount=200},
        {type="item", name="zipir-eggs", amount=4},
      },
    },
    ["zipir-reef-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="gasifier", amount=15},
        {type="item", name="inductor1", amount=148},
        {type="item", name="iron-plate", amount=284},
        {type="item", name="micro-mine-mk01", amount=3},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="stone-wall", amount=70},
      },
      results = {
        {type="item", name="zipir-reef-mk01", amount=1},
      },
    },
    ["zipir-a-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.25283317368769,
      ingredients = {
        {type="fluid", name="pressured-air", amount=170},
        {type="fluid", name="steam", amount=223},
        {type="item", name="anthraquinone-barrel", amount=6},
        {type="item", name="fawogae-substrate", amount=13},
        {type="item", name="fish", amount=4},
        {type="item", name="organic-solvent-barrel", amount=3},
      },
      results = {
        {type="fluid", name="waste-water", amount=127},
        {type="item", name="zipir1", amount=1},
      },
    },
    ["zipir-a-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.41451652889057,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=165},
        {type="fluid", name="steam", amount=234},
        {type="item", name="aluminium-plate", amount=10},
        {type="item", name="stone-wool", amount=4},
        {type="item", name="zipir-eggs", amount=4},
      },
      results = {
        {type="fluid", name="waste-water", amount=134},
        {type="item", name="zipir1", amount=1},
      },
    },
    ["arthropod-blood-to-blood"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.79000433630682,
      ingredients = {
        {type="fluid", name="methanal", amount=1659},
        {type="item", name="grade-2-iron", amount=1},
      },
      results = {
        {type="fluid", name="blood", amount=51},
        {type="item", name="grade-1-copper", amount=2},
      },
    },
    ["py-gas-powerplant-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="carbon-black", amount=54},
        {type="item", name="empty-fuel-canister", amount=228},
        {type="item", name="evaporator", amount=1},
        {type="item", name="grade-1-lead", amount=602},
        {type="item", name="oil-derrick-mk01", amount=1},
        {type="item", name="petri-dish", amount=248},
        {type="item", name="rich-clay", amount=1447},
        {type="item", name="small-parts-01", amount=500},
        {type="item", name="vitreloy", amount=4},
      },
      results = {
        {type="item", name="py-gas-powerplant-mk01", amount=1},
      },
    },
    ["ree-mining-drill-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="electric-mining-drill", amount=1},
        {type="item", name="inductor1", amount=74},
        {type="item", name="iron-plate", amount=57},
        {type="item", name="pipe", amount=34},
      },
      results = {
        {type="item", name="ree-mining-drill-mk01", amount=1},
      },
    },
    ["pyrite-make"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coarse", amount=11},
        {type="item", name="coke", amount=4},
      },
      results = {
        {type="item", name="pyrite", amount=1},
      },
    },
    ["rich-clay-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=550},
        {type="item", name="sand", amount=55},
      },
      results = {
        {type="item", name="rich-clay", amount=10},
      },
    },
    ["soot-to-aluminium"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1.0409299364833,
      ingredients = {
        {type="item", name="soot", amount=10},
      },
      results = {
        {type="item", name="ash", amount=1},
        {type="item", name="ore-aluminium", amount=10},
      },
    },
    ["soot-to-copper"] = {
      mode = "input-preserved-unmodified",
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
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 2.00864222742116,
      ingredients = {
        {type="item", name="soot", amount=19},
      },
      results = {
        {type="item", name="ash", amount=1},
        {type="item", name="gold-plate", amount=1},
      },
    },
    ["soot-to-iron"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 3.33333333333333,
      ingredients = {
        {type="item", name="soot", amount=32},
      },
      results = {
        {type="item", name="ash", amount=1},
        {type="item", name="silver-plate", amount=1},
      },
    },
    ["soot-to-zinc"] = {
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coke", amount=36},
      },
      results = {
        {type="item", name="coal-dust", amount=5},
        {type="item", name="rich-dust", amount=2},
      },
    },
    ["richdust-separation"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1.0509390350894,
      ingredients = {
        {type="item", name="soot", amount=10},
      },
      results = {
        {type="item", name="ash", amount=1},
        {type="item", name="ore-lead", amount=8},
      },
    },
    ["fetal-serum-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="empty-petri-dish", amount=1},
        {type="item", name="nickel-plate", amount=13},
        {type="item", name="skin", amount=8},
      },
      results = {
        {type="fluid", name="fetal-serum", amount=50},
      },
    },
    ["salt-ex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=262},
      },
      results = {
        {type="item", name="salt", amount=23},
      },
    },
    ["sand-washing"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 0.997460336177124,
      ingredients = {
        {type="fluid", name="steam", amount=66},
        {type="item", name="coarse", amount=6},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=79},
        {type="item", name="pure-sand", amount=8},
      },
    },
    ["acetic-acid"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=80},
        {type="fluid", name="pressured-water", amount=751},
        {type="item", name="chromium", amount=1},
      },
      results = {
        {type="fluid", name="acetic-acid", amount=50},
      },
    },
    ["ammonia-urea"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="urea", amount=20},
      },
      results = {
        {type="fluid", name="ammonia", amount=100},
      },
    },
    ["organic-solvent2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=393},
        {type="fluid", name="hot-air", amount=1012},
      },
      results = {
        {type="fluid", name="ammonia", amount=50},
        {type="fluid", name="organic-solvent", amount=100},
      },
    },
    ["phosphorous-acid"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.18,
      ingredients = {
        {type="fluid", name="syngas", amount=94},
        {type="item", name="auog-food-01", amount=2},
        {type="item", name="log", amount=1},
        {type="item", name="melamine-resin", amount=3},
      },
      results = {
        {type="fluid", name="phosphorous-acid", amount=59},
      },
    },
    ["tall-oil-separation"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="light-oil", amount=20},
        {type="fluid", name="tall-oil", amount=10},
      },
      results = {
        {type="fluid", name="aromatics", amount=10},
        {type="fluid", name="benzene", amount=10},
      },
    },
    ["tar-talloil"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=631},
      },
      results = {
        {type="fluid", name="aromatics", amount=20},
        {type="fluid", name="light-oil", amount=50},
        {type="fluid", name="tall-oil", amount=50},
      },
    },
    ["fluidize-coke"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-rejects", amount=1},
        {type="item", name="gravel", amount=7},
      },
      results = {
        {type="fluid", name="ammonia", amount=20},
        {type="fluid", name="tall-oil", amount=20},
        {type="fluid", name="tar", amount=30},
      },
    },
    ["methane-py-fertilizer"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.1,
      ingredients = {
        {type="fluid", name="water", amount=110},
        {type="item", name="moondrop-seeds", amount=1},
        {type="item", name="raw-fiber", amount=3},
      },
      results = {
        {type="fluid", name="methane", amount=88},
      },
    },
    ["phosphoric-acid"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=92},
        {type="fluid", name="phosphorous-acid", amount=40},
        {type="item", name="coal", amount=9},
      },
      results = {
        {type="fluid", name="hydrofluoric-acid", amount=10},
        {type="fluid", name="phosphine-gas", amount=10},
        {type="fluid", name="phosphoric-acid", amount=20},
      },
    },
    ["propene"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=343},
        {type="fluid", name="syngas", amount=60},
        {type="item", name="lead-plate", amount=4},
      },
      results = {
        {type="fluid", name="propene", amount=60},
        {type="fluid", name="water", amount=50},
      },
    },
    ["phosphoric-acid2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=595},
      },
      results = {
        {type="fluid", name="phosphoric-acid", amount=40},
      },
    },
    ["al-pulp-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="fluid", name="water-saline", amount=556},
        {type="item", name="graphite", amount=8},
        {type="item", name="powdered-aluminium", amount=5},
      },
      results = {
        {type="fluid", name="al-pulp-01", amount=100},
      },
    },
    ["al-pulp-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=900},
        {type="fluid", name="water-saline", amount=1464},
      },
      results = {
        {type="fluid", name="al-pulp-02", amount=100},
      },
    },
    ["molten-aluminium-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="gasoline", amount=361},
        {type="item", name="coke", amount=11},
        {type="item", name="sand", amount=10},
      },
      results = {
        {type="fluid", name="molten-aluminium", amount=50},
      },
    },
    ["fluorine-gas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="kerosene", amount=1390},
        {type="item", name="sodium-hydroxide", amount=10},
      },
      results = {
        {type="fluid", name="fluorine-gas", amount=50},
        {type="fluid", name="hydrogen", amount=50},
      },
    },
    ["syngas-distilation"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=590},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=50},
        {type="fluid", name="hydrogen", amount=100},
      },
    },
    ["gas-molten-salt-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="fish-oil", amount=1821},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=500},
      },
    },
    ["wastewater-recovery"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="waste-water", amount=100},
        {type="item", name="crushed-coal", amount=3},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=150},
      },
    },
    ["glass-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="carbon-dioxide-barrel", amount=2},
        {type="item", name="purest-nitrogen-gas-barrel", amount=1},
      },
      results = {
        {type="fluid", name="molten-glass", amount=50},
      },
    },
    ["powdered-quartz"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 0.811141674436246,
      ingredients = {
        {type="item", name="waste-water-barrel", amount=1},
      },
      results = {
        {type="item", name="gravel", amount=1},
        {type="item", name="powdered-quartz", amount=4},
      },
    },
    ["seaweed-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=100},
        {type="fluid", name="water", amount=1452},
        {type="item", name="coke", amount=3},
      },
      results = {
        {type="item", name="seaweed", amount=20},
      },
    },
    ["silver-plate-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.22222222222222,
      ingredients = {
        {type="item", name="car", amount=1},
      },
      results = {
        {type="item", name="silver-plate", amount=11},
      },
    },
    ["sulfur-mine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="cottongut-codex", amount=2},
        {type="item", name="cottongut-pup", amount=37},
        {type="item", name="grade-1-tin", amount=419},
        {type="item", name="grade-2-tin", amount=428},
        {type="item", name="moondrop", amount=150},
        {type="item", name="shaft-mk01", amount=15},
      },
      results = {
        {type="item", name="sulfur-mine", amount=3},
      },
    },
    ["albumin-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ammonia", amount=1357},
      },
      results = {
        {type="item", name="albumin", amount=5},
      },
    },
    ["formaldehyde-from-refined-natural-gas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-air", amount=100},
        {type="fluid", name="refined-natural-gas", amount=100},
        {type="fluid", name="water-saline", amount=1059},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=100},
        {type="fluid", name="methanal", amount=50},
        {type="fluid", name="molten-salt", amount=30},
      },
    },
    ["powedered-biomass"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="biomass", amount=20},
      },
      results = {
        {type="item", name="powdered-biomass", amount=20},
      },
    },
    ["sugar"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-residual-mixture", amount=1348},
        {type="item", name="powdered-aluminium", amount=4},
      },
      results = {
        {type="item", name="sugar", amount=10},
      },
    },
    ["waste-water-urea"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="waste-water", amount=200},
      },
      results = {
        {type="item", name="urea", amount=10},
      },
    },
    ["fine-powdered-biomass"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1.00247212346232,
      ingredients = {
        {type="item", name="powdered-biomass", amount=30},
      },
      results = {
        {type="item", name="biomass", amount=1},
        {type="item", name="fine-powdered-biomass", amount=18},
        {type="item", name="powdered-biomass", amount=1},
      },
    },
    ["fungal-substrate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-air", amount=33},
        {type="item", name="biomass", amount=5},
        {type="item", name="coal-dust", amount=11},
      },
      results = {
        {type="item", name="fungal-substrate", amount=10},
      },
    },
    ["dried-biomass"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="item", name="soot", amount=2},
      },
      results = {
        {type="item", name="dried-biomass", amount=36},
      },
    },
    ["fungal-substrate-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-air", amount=33},
        {type="item", name="biomass", amount=10},
        {type="item", name="coke", amount=4},
        {type="item", name="fertilizer", amount=4},
        {type="item", name="flask", amount=3},
        {type="item", name="meat", amount=4},
        {type="item", name="powdered-biomass", amount=7},
      },
      results = {
        {type="item", name="fungal-substrate-02", amount=10},
      },
    },
    ["fiber"] = {
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="propene", amount=50},
        {type="fluid", name="subcritical-water", amount=753},
      },
      results = {
        {type="item", name="ore-nickel", amount=10},
      },
    },
    ["grade-3-nickel"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="grade-1-chromite", amount=4},
      },
      results = {
        {type="item", name="grade-2-nickel", amount=2},
        {type="item", name="grade-3-nickel", amount=1},
        {type="item", name="gravel", amount=2},
        {type="item", name="nickel-rejects", amount=2},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="nickel-rejects", amount=2},
      },
      results = {
        {type="item", name="grade-4-nickel", amount=1},
      },
    },
    ["nickel-rejects-recrush"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=437},
        {type="item", name="nickel-rejects", amount=6},
        {type="item", name="sand", amount=10},
      },
      results = {
        {type="fluid", name="molten-nickel", amount=50},
      },
    },
    ["hotair-nickel-plate-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="pressured-air", amount=28576},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="nickel-plate", amount=63},
      },
    },
    ["nickel-plate-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="acidgas", amount=1285},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="nickel-plate", amount=50},
      },
    },
    ["tar-to-nickel"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ammonia", amount=227},
        {type="fluid", name="carbon-dioxide", amount=394},
      },
      results = {
        {type="item", name="ore-nickel", amount=10},
      },
    },
    ["soda-ash"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=1210},
        {type="fluid", name="water", amount=250},
        {type="item", name="ash", amount=50},
      },
      results = {
        {type="fluid", name="soda-ash", amount=200},
      },
    },
    ["industrial-solvent"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=786},
        {type="fluid", name="pressured-water", amount=6338},
        {type="fluid", name="purest-nitrogen-gas", amount=883},
      },
      results = {
        {type="fluid", name="industrial-solvent", amount=100},
      },
    },
    ["vanabins"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=1169},
        {type="fluid", name="hot-air", amount=1711},
      },
      results = {
        {type="fluid", name="vanabins", amount=100},
      },
    },
    ["blue-liquor"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="coal-slurry", amount=1892},
        {type="fluid", name="water", amount=100},
        {type="item", name="calcium-carbide", amount=46},
      },
      results = {
        {type="fluid", name="blue-liquor", amount=200},
      },
    },
    ["vpulp1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=231},
        {type="fluid", name="pressured-steam", amount=16009},
      },
      results = {
        {type="fluid", name="vpulp1", amount=100},
      },
    },
    ["molybdenum-pulp"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=300},
        {type="item", name="grade-1-copper", amount=27},
      },
      results = {
        {type="fluid", name="molybdenum-pulp", amount=100},
        {type="fluid", name="muddy-sludge", amount=200},
      },
    },
    ["vpulp2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-steam", amount=33288},
        {type="item", name="sand", amount=83},
      },
      results = {
        {type="fluid", name="vpulp2", amount=100},
      },
    },
    ["molybdenite-pulp"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="acidgas", amount=2500},
        {type="fluid", name="geothermal-water", amount=1861},
      },
      results = {
        {type="fluid", name="vpulp3", amount=50},
        {type="item", name="vanadium-oxide", amount=2},
      },
    },
    ["bitumen-to-asphalt"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="bitumen", amount=10},
        {type="fluid", name="hot-air", amount=92},
        {type="item", name="stone", amount=2},
      },
      results = {
        {type="item", name="py-asphalt", amount=2},
      },
    },
    ["py-aluminium"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="medium-distillate", amount=20},
        {type="item", name="coal-dust", amount=2},
        {type="item", name="moondrop-seeds", amount=9},
      },
      results = {
        {type="item", name="py-coal-tile", amount=1},
      },
    },
    ["py-iron"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="organic-solvent", amount=8},
        {type="item", name="iron-gear-wheel", amount=1},
        {type="item", name="tailings-barrel", amount=1},
      },
      results = {
        {type="item", name="py-iron", amount=3},
      },
    },
    ["py-nexelit"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="tar", amount=20},
        {type="item", name="biomass", amount=58},
        {type="item", name="nexelit-plate", amount=1},
      },
      results = {
        {type="item", name="py-nexelit", amount=2},
      },
    },
    ["py-quartz"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="hot-air", amount=264},
        {type="item", name="ore-titanium", amount=4},
        {type="item", name="tailings-barrel", amount=1},
      },
      results = {
        {type="item", name="py-quartz", amount=3},
      },
    },
    ["py-steel"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="hot-air", amount=7},
        {type="fluid", name="molten-steel", amount=14},
        {type="item", name="crushed-quartz", amount=1},
      },
      results = {
        {type="item", name="py-steel", amount=3},
      },
    },
    ["hydrogen-chloride"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=394},
        {type="fluid", name="water-saline", amount=534},
        {type="item", name="small-lamp", amount=1},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=100},
        {type="item", name="small-lamp", amount=1},
      },
    },
    ["methanol-void-denitrification"] = {
      mode = "input-preserved-unmodified",
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
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-air", amount=100},
      },
      results = {
        {type="fluid", name="nitrogen", amount=20},
        {type="fluid", name="oxygen", amount=20},
        {type="fluid", name="purest-nitrogen-gas", amount=60},
      },
    },
    ["hcl-from-guts"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="skin", amount=5},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=50},
      },
    },
    ["nitrogen"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.015,
      ingredients = {
        {type="fluid", name="flue-gas", amount=393},
        {type="item", name="lime", amount=3},
      },
      results = {
        {type="fluid", name="nitrogen", amount=203},
      },
    },
    ["sulfuric-acid-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="acidgas", amount=100},
        {type="fluid", name="pressured-air", amount=67},
      },
      results = {
        {type="fluid", name="sulfuric-acid", amount=50},
      },
    },
    ["zinc-chloride"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen-chloride", amount=20},
        {type="item", name="zinc-plate", amount=1},
      },
      results = {
        {type="fluid", name="hydrogen", amount=20},
        {type="item", name="zinc-chloride", amount=1},
      },
    },
    ["active-carbon"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=114},
        {type="item", name="pure-sand", amount=21},
        {type="item", name="rich-clay", amount=11},
        {type="item", name="starch", amount=1},
      },
      results = {
        {type="item", name="active-carbon", amount=5},
      },
    },
    ["co2-organics"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="biomass", amount=10},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=300},
      },
    },
    ["drill-head"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="carbon-dioxide-barrel", amount=5},
        {type="item", name="coke", amount=6},
        {type="item", name="copper-plate", amount=3},
      },
      results = {
        {type="item", name="drill-head", amount=3},
      },
    },
    ["drill-head-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coal-dust", amount=7},
        {type="item", name="iron-plate", amount=23},
        {type="item", name="lead-plate", amount=7},
      },
      results = {
        {type="item", name="drill-head", amount=4},
      },
    },
    ["drill-head-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="item", name="lead-plate", amount=5},
        {type="item", name="pipe", amount=12},
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="drill-head", amount=10},
      },
    },
    ["nichrome"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=264},
        {type="item", name="lime", amount=5},
        {type="item", name="nickel-plate", amount=10},
      },
      results = {
        {type="item", name="nichrome", amount=1},
      },
    },
    ["evaporate-nitrogen"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="liquid-nitrogen", amount=5},
      },
      results = {
        {type="fluid", name="nitrogen", amount=50},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=804},
        {type="fluid", name="pressured-steam", amount=2540},
        {type="item", name="chromium", amount=7},
      },
      results = {
        {type="fluid", name="hydrogen", amount=300},
      },
    },
    ["drilling-fluid-0"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=128},
        {type="item", name="limestone", amount=2},
        {type="item", name="melamine", amount=7},
        {type="item", name="sand", amount=5},
      },
      results = {
        {type="fluid", name="drilling-fluid-0", amount=50},
      },
    },
    ["minor-extract-gas-from-coalbed-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=1353},
        {type="fluid", name="tailings", amount=343},
        {type="item", name="sb-grade-01", amount=4},
      },
      results = {
        {type="fluid", name="coalbed-gas", amount=150},
        {type="fluid", name="water", amount=2500},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="light-oil", amount=367},
        {type="fluid", name="water", amount=638},
        {type="item", name="chromium", amount=1},
      },
      results = {
        {type="fluid", name="diesel", amount=300},
      },
    },
    ["coalbed-gas-to-acidgas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=250},
        {type="fluid", name="water-saline", amount=398},
      },
      results = {
        {type="fluid", name="acidgas", amount=150},
        {type="fluid", name="flue-gas", amount=900},
      },
    },
    ["coalbed-gas-to-co2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.03666666666667,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=835},
        {type="fluid", name="oxygen", amount=470},
        {type="item", name="scrude-canister", amount=1},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=311},
      },
    },
    ["coalbed-gas-to-coalgas"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.015,
      ingredients = {
        {type="fluid", name="coalbed-gas", amount=203},
        {type="fluid", name="geothermal-water", amount=818},
        {type="item", name="vacuum-tube", amount=1},
      },
      results = {
        {type="fluid", name="syngas", amount=203},
      },
    },
    ["natural-gas-to-syngas"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="natural-gas", amount=100},
      },
      results = {
        {type="fluid", name="flue-gas", amount=200},
        {type="fluid", name="syngas", amount=50},
      },
    },
    ["quench-ovengas"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=100},
        {type="fluid", name="water", amount=100},
      },
      results = {
        {type="fluid", name="flue-gas", amount=1000},
        {type="fluid", name="syngas", amount=100},
      },
    },
    ["light-oil_from_syngas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=1237},
        {type="fluid", name="flue-gas", amount=1180},
        {type="item", name="clean-nexelit", amount=18},
      },
      results = {
        {type="fluid", name="light-oil", amount=300},
        {type="fluid", name="olefin", amount=150},
        {type="fluid", name="steam", amount=2000},
      },
    },
    ["petgas-from-refsyngas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 0.794514650247972,
      ingredients = {
        {type="fluid", name="aromatics", amount=163},
        {type="fluid", name="boric-acid", amount=578},
        {type="item", name="lead-dust", amount=1},
      },
      results = {
        {type="fluid", name="olefin", amount=119},
        {type="fluid", name="petroleum-gas", amount=318},
      },
    },
    ["bone-solvent"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="olefin", amount=100},
        {type="item", name="bones", amount=9},
      },
      results = {
        {type="fluid", name="organic-solvent", amount=50},
      },
    },
    ["dedicated-oleochemicals"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=363},
        {type="item", name="mukmoux-fat", amount=20},
        {type="item", name="titanium-plate", amount=2},
      },
      results = {
        {type="fluid", name="oleochemicals", amount=250},
        {type="fluid", name="steam", amount=2000},
      },
    },
    ["oleochemicals"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=157},
        {type="item", name="barrel", amount=4},
        {type="item", name="mukmoux-fat", amount=20},
      },
      results = {
        {type="fluid", name="glycerol", amount=150},
        {type="fluid", name="oleochemicals", amount=300},
        {type="fluid", name="steam", amount=2000},
      },
    },
    ["petgas-methanol"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=753},
        {type="fluid", name="tar", amount=269},
      },
      results = {
        {type="fluid", name="methanol", amount=100},
        {type="fluid", name="petroleum-gas", amount=100},
      },
    },
    ["fish-oil-to-lube"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="methanal", amount=699},
        {type="item", name="coal-dust", amount=4},
      },
      results = {
        {type="fluid", name="lubricant", amount=100},
      },
    },
    ["olefin-lube"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="methanol", amount=468},
        {type="fluid", name="pressured-water", amount=4176},
      },
      results = {
        {type="fluid", name="lubricant", amount=250},
      },
    },
    ["coal-slurry"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="tar", amount=226},
      },
      results = {
        {type="fluid", name="coal-slurry", amount=150},
        {type="fluid", name="water", amount=100},
      },
    },
    ["refsyngas-from-filtered-syngas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=393},
        {type="item", name="grade-2-zinc", amount=1},
      },
      results = {
        {type="fluid", name="refsyngas", amount=70},
      },
    },
    ["fluegas-to-syngas"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water-saline", amount=475},
        {type="item", name="titanium-plate", amount=8},
      },
      results = {
        {type="fluid", name="hydrogen-peroxide", amount=50},
      },
    },
    ["syngas2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=386},
        {type="fluid", name="steam", amount=255},
        {type="fluid", name="water", amount=100},
      },
      results = {
        {type="fluid", name="syngas", amount=100},
        {type="fluid", name="tar", amount=30},
        {type="item", name="ash", amount=1},
      },
    },
    ["coal-slurry-fuel"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=2025},
      },
      results = {
        {type="fluid", name="aromatics", amount=50},
        {type="fluid", name="benzene", amount=50},
      },
    },
    ["acidgas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=1577},
        {type="item", name="sulfur", amount=10},
      },
      results = {
        {type="fluid", name="acidgas", amount=150},
      },
    },
    ["acidgas-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=371},
        {type="fluid", name="gasoline", amount=5},
        {type="fluid", name="syngas", amount=509},
      },
      results = {
        {type="fluid", name="acidgas", amount=30},
        {type="fluid", name="steam", amount=600},
      },
    },
    ["pyrite-burn"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 0.826631835479402,
      ingredients = {
        {type="item", name="naphthalene-oil-barrel", amount=1},
      },
      results = {
        {type="fluid", name="acidgas", amount=40},
        {type="item", name="iron-oxide", amount=10},
      },
    },
    ["log4"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=120},
        {type="fluid", name="steam", amount=160},
        {type="item", name="cellulose", amount=4},
      },
      results = {
        {type="item", name="log", amount=5},
      },
    },
    ["log5"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=124},
        {type="fluid", name="vacuum", amount=1467},
        {type="item", name="wood-seedling", amount=3},
      },
      results = {
        {type="item", name="log", amount=7},
      },
    },
    ["log6"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=145},
        {type="fluid", name="pressured-water", amount=1572},
        {type="item", name="ash", amount=30},
        {type="item", name="lime", amount=7},
      },
      results = {
        {type="item", name="log", amount=8},
      },
    },
    ["wood-seedling-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=124},
        {type="item", name="hydrogen-barrel", amount=8},
        {type="item", name="rich-clay", amount=4},
        {type="item", name="saps", amount=1},
      },
      results = {
        {type="item", name="wood-seedling-mk02", amount=1},
      },
    },
    ["wood-seeds-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.96420773894801,
      ingredients = {
        {type="fluid", name="tar", amount=336},
        {type="item", name="plasmids", amount=2},
        {type="item", name="tree-mk01", amount=2},
      },
      results = {
        {type="item", name="wood-seeds", amount=1},
        {type="item", name="wood-seeds-mk02", amount=0.00927795997419715},
      },
    },
    ["wood-seeds-mk02-breeder"] = {
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=367},
        {type="item", name="aluminium-plate", amount=7},
        {type="item", name="empty-planter-box", amount=19},
      },
      results = {
        {type="item", name="tree-mk02", amount=1},
      },
    },
    ["ulric"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=78},
        {type="item", name="aluminium-plate", amount=117},
        {type="item", name="coal-dust", amount=274},
        {type="item", name="earth-generic-sample", amount=3},
        {type="item", name="methanol-reactor", amount=3},
        {type="item", name="zipir-codex", amount=4},
      },
      results = {
        {type="item", name="ulric", amount=1},
      },
    },
    ["ulric-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coke", amount=67},
        {type="item", name="copper-cable", amount=58},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="pipe", amount=2},
      },
      results = {
        {type="item", name="ulric-codex", amount=1},
      },
    },
    ["ulric-corral-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=18},
        {type="item", name="burner-inserter", amount=5},
        {type="item", name="duralumin", amount=29},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="muddy-sludge-barrel", amount=11},
        {type="item", name="pipe", amount=17},
      },
      results = {
        {type="item", name="ulric-corral-mk01", amount=1},
      },
    },
    ["ulric-food-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="steam", amount=129},
        {type="item", name="drill-head", amount=1},
        {type="item", name="fertilizer", amount=3},
        {type="item", name="light-oil-barrel", amount=1},
        {type="item", name="ore-quartz", amount=23},
        {type="item", name="urea", amount=2},
        {type="item", name="zinc-plate", amount=2},
      },
      results = {
        {type="item", name="ulric-food-01", amount=8},
      },
    },
    ["ulric-cub-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="raw-fiber", amount=3},
        {type="item", name="tar-barrel", amount=2},
        {type="item", name="water-barrel", amount=15},
      },
      results = {
        {type="item", name="barrel", amount=15},
        {type="item", name="ulric-cub", amount=3},
      },
    },
    ["ulric-manure-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.27686739246527,
      ingredients = {
        {type="item", name="ralesia", amount=15},
        {type="item", name="tall-oil-barrel", amount=2},
        {type="item", name="wood-seedling", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=6},
        {type="item", name="manure", amount=4},
      },
    },
    ["ulric-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="creamy-latex-barrel", amount=3},
        {type="item", name="ralesia", amount=12},
        {type="item", name="ulric-food-01", amount=1},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="ulric", amount=3},
      },
    },
    ["earth-cow-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bio-sample", amount=37},
        {type="item", name="display-panel", amount=11},
        {type="item", name="py-science-pack-1", amount=9},
      },
      results = {
        {type="item", name="earth-cow-sample", amount=1},
      },
    },
    ["earth-crustacean-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=432},
        {type="item", name="boiler", amount=9},
        {type="item", name="py-science-pack-1", amount=26},
      },
      results = {
        {type="item", name="earth-crustacean-sample", amount=1},
      },
    },
    ["earth-palmtree-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cdna", amount=1},
        {type="item", name="logistic-science-pack", amount=28},
        {type="item", name="sea-sponge-codex", amount=1},
      },
      results = {
        {type="item", name="earth-palmtree-sample", amount=1},
      },
    },
    ["earth-potato-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="automation-science-pack", amount=21},
        {type="item", name="kicalk-codex", amount=1},
        {type="item", name="py-science-pack-1", amount=174},
      },
      results = {
        {type="item", name="earth-potato-sample", amount=1},
      },
    },
    ["earth-sea-sponge-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cottongut-codex", amount=1},
        {type="item", name="py-science-pack-1", amount=96},
        {type="item", name="steel-chest", amount=35},
      },
      results = {
        {type="item", name="earth-sea-sponge-sample", amount=1},
      },
    },
    ["earth-bee-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coke", amount=6731},
        {type="item", name="kicalk-codex", amount=1},
        {type="item", name="pipe", amount=516},
      },
      results = {
        {type="item", name="earth-bee-sample", amount=1},
      },
    },
    ["earth-horse-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="fbreactor-mk01", amount=3},
        {type="item", name="grade-2-iron", amount=245},
        {type="item", name="pipe", amount=518},
      },
      results = {
        {type="item", name="earth-horse-sample", amount=1},
      },
    },
    ["kicalk-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=618},
        {type="item", name="aluminium-plate", amount=58},
        {type="item", name="bio-sample01", amount=5},
        {type="item", name="empty-planter-box", amount=1},
        {type="item", name="lab-instrument", amount=56},
        {type="item", name="moss-gen", amount=44},
        {type="item", name="sea-sponge-codex", amount=1},
      },
      results = {
        {type="item", name="kicalk", amount=1},
      },
    },
    ["kicalk-fiber"] = {
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ceramic", amount=3},
        {type="item", name="refined-hazard-concrete", amount=9},
      },
      results = {
        {type="item", name="kicalk", amount=10},
      },
    },
    ["kicalk-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 0.833333333333333,
      ingredients = {
        {type="fluid", name="hot-air", amount=102},
        {type="item", name="ceramic", amount=2},
        {type="item", name="coke", amount=4},
        {type="item", name="grade-3-iron", amount=1},
        {type="item", name="small-lamp", amount=1},
      },
      results = {
        {type="item", name="kicalk", amount=10},
      },
    },
    ["sea-sponge"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=1000},
        {type="item", name="aluminium-plate", amount=117},
        {type="item", name="bio-sample01", amount=2},
        {type="item", name="cdna", amount=3},
        {type="item", name="earth-bear-sample", amount=1},
        {type="item", name="moondrop-codex", amount=6},
      },
      results = {
        {type="item", name="sea-sponge", amount=1},
      },
    },
    ["sea-sponge-sprouts"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="tar-barrel", amount=6},
      },
      results = {
        {type="item", name="sea-sponge-sprouts", amount=2},
      },
    },
    ["sea-sponge-processing-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="sea-sponge-sprouts", amount=2},
      },
      results = {
        {type="item", name="ore-quartz", amount=10},
      },
    },
    ["sea-sponge-sprouts-processing-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.14285714285714,
      ingredients = {
        {type="item", name="planter-box", amount=2},
      },
      results = {
        {type="item", name="ore-quartz", amount=8},
      },
    },
    ["arthropod-blood-to-organic-solvent"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="cumene", amount=20},
        {type="fluid", name="diborane", amount=843},
        {type="item", name="nickel-plate", amount=1},
      },
      results = {
        {type="fluid", name="organic-solvent", amount=130},
      },
    },
    ["chloride-void-muddy-sludge"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coal", amount=10},
        {type="item", name="sand", amount=2},
      },
      results = {
        {type="fluid", name="tar", amount=70},
      },
    },
    ["cobalt-extract"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.00058339784625,
      ingredients = {
        {type="fluid", name="methanal", amount=774},
        {type="fluid", name="pressured-air", amount=461},
        {type="item", name="fish-oil-barrel", amount=2},
      },
      results = {
        {type="fluid", name="tailings", amount=51},
        {type="item", name="cobalt-extract", amount=3},
      },
    },
    ["flue-gas-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="vacuum", amount=40},
        {type="item", name="ash", amount=10},
      },
      results = {
        {type="fluid", name="flue-gas", amount=150},
      },
    },
    ["gasoline"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="aromatics", amount=273},
        {type="fluid", name="hydrogen", amount=50},
        {type="fluid", name="subcritical-water", amount=1491},
        {type="item", name="pipe", amount=3},
      },
      results = {
        {type="fluid", name="gasoline", amount=150},
      },
    },
    ["olefin"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=83},
        {type="fluid", name="steam", amount=850},
        {type="item", name="nexelit-plate", amount=2},
      },
      results = {
        {type="fluid", name="olefin", amount=200},
      },
    },
    ["sea-sponge-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=253},
        {type="fluid", name="water", amount=550},
        {type="item", name="outlet-gas-02-barrel", amount=1},
      },
      results = {
        {type="fluid", name="water-saline", amount=100},
        {type="item", name="sea-sponge", amount=1},
      },
    },
    ["sulfuric-acid"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=4387},
        {type="item", name="sulfur", amount=5},
      },
      results = {
        {type="fluid", name="sulfuric-acid", amount=50},
      },
    },
    ["wastewater-filtration"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.06,
      ingredients = {
        {type="fluid", name="waste-water", amount=106},
        {type="item", name="flask", amount=1},
      },
      results = {
        {type="fluid", name="methanol", amount=106},
      },
    },
    ["agitator-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=19},
        {type="item", name="duralumin", amount=19},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="iron-plate", amount=169},
        {type="item", name="storage-tank", amount=3},
        {type="item", name="tin-plate", amount=100},
        {type="item", name="tinned-cable", amount=519},
      },
      results = {
        {type="item", name="agitator-mk01", amount=2},
      },
    },
    ["centrifugal-pan-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="agitator-mk01", amount=1},
        {type="item", name="assembling-machine-1", amount=4},
        {type="item", name="boiler", amount=18},
        {type="item", name="condensed-distillate-barrel", amount=4},
        {type="item", name="fiberboard", amount=93},
        {type="item", name="lead-plate", amount=16},
        {type="item", name="outpost", amount=1},
        {type="item", name="steam-engine", amount=19},
        {type="item", name="syngas-canister", amount=7},
      },
      results = {
        {type="item", name="centrifugal-pan-mk01", amount=1},
      },
    },
    ["compressor-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="burner-inserter", amount=14},
        {type="item", name="gasifier", amount=1},
        {type="item", name="glass", amount=28},
        {type="item", name="intermetallics", amount=11},
        {type="item", name="low-grade-rejects", amount=35},
        {type="item", name="steel-chest", amount=7},
        {type="item", name="washer", amount=7},
      },
      results = {
        {type="item", name="compressor-mk01", amount=2},
      },
    },
    ["gas-separator-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="barrel", amount=36},
        {type="item", name="borax-mine", amount=3},
        {type="item", name="carbolic-oil-barrel", amount=12},
        {type="item", name="clean-nexelit", amount=27},
        {type="item", name="controler-mk01", amount=3},
        {type="item", name="distilator", amount=3},
        {type="item", name="engine-unit", amount=9},
        {type="item", name="inductor1", amount=33},
      },
      results = {
        {type="item", name="gas-separator-mk01", amount=1},
      },
    },
    ["hydrocyclone-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="duralumin", amount=7},
        {type="item", name="engine-unit", amount=10},
        {type="item", name="lead-plate", amount=47},
        {type="item", name="pipe", amount=19},
        {type="item", name="stone-furnace", amount=26},
        {type="item", name="sulfuric-acid-barrel", amount=9},
      },
      results = {
        {type="item", name="hydrocyclone-mk01", amount=1},
      },
    },
    ["thickener-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aromatics-canister", amount=14},
        {type="item", name="boiler", amount=4},
        {type="item", name="bolts", amount=44},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="glass", amount=17},
        {type="item", name="stone-brick", amount=339},
        {type="item", name="tower-mk01", amount=1},
      },
      results = {
        {type="item", name="thickener-mk01", amount=1},
      },
    },
    ["casein"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="molten-glass", amount=247},
      },
      results = {
        {type="item", name="casein", amount=5},
      },
    },
    ["green-sic"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ceramic", amount=5},
        {type="item", name="coal-dust", amount=73},
        {type="item", name="lime", amount=4},
      },
      results = {
        {type="item", name="green-sic", amount=4},
      },
    },
    ["mixed-ores"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 0.81662903866299,
      ingredients = {
        {type="item", name="grade-1-copper", amount=1},
        {type="item", name="ore-tin", amount=9},
        {type="item", name="refined-hazard-concrete", amount=1},
      },
      results = {
        {type="item", name="mixed-ores", amount=4},
        {type="item", name="stone", amount=1},
      },
    },
    ["cobalt-fluoride"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=1376},
        {type="fluid", name="steam", amount=130},
        {type="item", name="ash", amount=71},
        {type="item", name="condensates-canister", amount=8},
      },
      results = {
        {type="item", name="cobalt-fluoride", amount=3},
      },
    },
    ["quartz-tube"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="molten-glass", amount=100},
        {type="item", name="calcium-carbide", amount=42},
        {type="item", name="fiberboard", amount=6},
      },
      results = {
        {type="item", name="quartz-tube", amount=3},
      },
    },
    ["sic"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ore-zinc", amount=59},
      },
      results = {
        {type="item", name="sic", amount=4},
      },
    },
    ["artificial-blood"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="raw-gas", amount=1324},
        {type="item", name="dried-meat", amount=67},
      },
      results = {
        {type="fluid", name="artificial-blood", amount=100},
      },
    },
    ["decalin"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="aromatics", amount=100},
        {type="fluid", name="water", amount=1275},
        {type="item", name="aluminium-plate", amount=4},
        {type="item", name="titanium-plate", amount=2},
      },
      results = {
        {type="fluid", name="decalin", amount=50},
      },
    },
    ["flutec-pp6"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="decalin", amount=100},
        {type="item", name="drill-head", amount=36},
      },
      results = {
        {type="fluid", name="flutec-pp6", amount=100},
      },
    },
    ["bio-oil"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="nitrogen", amount=300},
        {type="item", name="dried-meat", amount=2},
        {type="item", name="mixed-ores", amount=7},
        {type="item", name="quartz-tube", amount=1},
      },
      results = {
        {type="fluid", name="bio-oil", amount=300},
        {type="item", name="quartz-tube", amount=1},
      },
    },
    ["bio-oil-3"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="bio-oil", amount=100},
      },
      results = {
        {type="item", name="raw-coal", amount=15},
      },
    },
    ["moondrop-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=100},
        {type="fluid", name="water", amount=100},
        {type="item", name="lime", amount=3},
        {type="item", name="moondrop-seeds", amount=7},
      },
      results = {
        {type="item", name="moondrop", amount=8},
      },
    },
    ["moondrop-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=348},
        {type="fluid", name="pressured-water", amount=571},
        {type="item", name="coarse", amount=66},
        {type="item", name="cottongut-pup", amount=1},
        {type="item", name="moondrop", amount=2},
        {type="item", name="urea", amount=7},
      },
      results = {
        {type="item", name="moondrop", amount=1},
        {type="item", name="moondrop-mk02", amount=0.005},
      },
    },
    ["moondrop-seeds-mk02"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="moondrop-mk02", amount=4},
      },
      results = {
        {type="item", name="moondrop", amount=1},
        {type="item", name="moondrop-mk02", amount=2},
        {type="item", name="moondrop-seeds", amount=1},
        {type="item", name="moondrop-seeds-mk02", amount=3},
      },
    },
    ["moondrop-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="coal-gas", amount=330},
        {type="fluid", name="water-saline", amount=176},
        {type="item", name="coal-dust", amount=8},
        {type="item", name="refined-natural-gas-canister", amount=11},
        {type="item", name="yaedols", amount=1},
      },
      results = {
        {type="item", name="moondrop-mk02", amount=5},
      },
    },
    ["oleochemicals-bioplastic"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="methanol", amount=50},
        {type="fluid", name="purest-nitrogen-gas", amount=3448},
      },
      results = {
        {type="item", name="plastic-bar", amount=10},
      },
    },
    ["plastic-from-casein"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.05,
      ingredients = {
        {type="fluid", name="hot-air", amount=107},
        {type="fluid", name="methanal", amount=107},
        {type="item", name="cobalt-extract", amount=2},
      },
      results = {
        {type="item", name="plastic-bar", amount=21},
      },
    },
    ["plastic-from-melamine"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="al-pulp-01", amount=1702},
        {type="fluid", name="fish-oil", amount=1308},
        {type="item", name="aluminium-plate", amount=231},
        {type="item", name="cdna", amount=10},
        {type="item", name="chromium", amount=82},
        {type="item", name="copper-low-dust", amount=17},
        {type="item", name="earth-cow-sample", amount=3},
        {type="item", name="nichrome", amount=22},
      },
      results = {
        {type="item", name="zipir1", amount=2},
      },
    },
    ["alien-sample-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="lubricant", amount=395},
        {type="fluid", name="subcritical-water", amount=1076},
        {type="fluid", name="water-saline", amount=13251},
        {type="item", name="alien-sample01", amount=1},
        {type="item", name="aluminium-plate", amount=117},
        {type="item", name="copper-rejects", amount=66},
        {type="item", name="empty-petri-dish", amount=2},
        {type="item", name="plastic-bar", amount=10},
        {type="item", name="refined-natural-gas-barrel", amount=20},
        {type="item", name="sodium-hydroxide", amount=29},
      },
      results = {
        {type="item", name="alien-sample-02", amount=1},
      },
    },
    ["cytostatics"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="decalin", amount=30},
        {type="item", name="acetic-acid-barrel", amount=4},
        {type="item", name="empty-petri-dish", amount=3},
        {type="item", name="plastic-bar", amount=10},
        {type="item", name="retrovirus", amount=20},
      },
      results = {
        {type="item", name="cytostatics", amount=1},
      },
    },
    ["dna-polymerase"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="arqad-honey", amount=50},
        {type="item", name="cocoon-mk02", amount=2},
        {type="item", name="petri-dish-bacteria", amount=1},
        {type="item", name="steel-chest", amount=2},
        {type="item", name="stopper", amount=19},
      },
      results = {
        {type="item", name="dna-polymerase", amount=1},
      },
    },
    ["manure-bacteria"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.32,
      ingredients = {
        {type="item", name="dried-meat", amount=6},
        {type="item", name="fawogae-substrate", amount=2},
        {type="item", name="petri-dish-bacteria", amount=1},
      },
      results = {
        {type="fluid", name="manure-bacteria", amount=132},
      },
    },
    ["primers"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.42857142857143,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=148},
        {type="item", name="coal-gas-barrel", amount=4},
        {type="item", name="empty-petri-dish", amount=43},
        {type="item", name="raw-fiber", amount=8},
        {type="item", name="stopper", amount=25},
      },
      results = {
        {type="item", name="primers", amount=1},
      },
    },
    ["retrovirus-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="liquid-nitrogen", amount=20},
        {type="item", name="cocoon", amount=4},
        {type="item", name="empty-barrel-milk", amount=1},
        {type="item", name="empty-petri-dish", amount=12},
        {type="item", name="petri-dish-bacteria", amount=1},
        {type="item", name="stopper", amount=2},
      },
      results = {
        {type="item", name="retrovirus", amount=3},
      },
    },
    ["cottongut-science-green-seeds"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-syngas", amount=1259},
        {type="fluid", name="subcritical-water", amount=205},
        {type="item", name="aluminium-plate", amount=24},
        {type="item", name="cottongut-mk01", amount=23},
        {type="item", name="primers", amount=3},
        {type="item", name="stopper", amount=5},
      },
      results = {
        {type="item", name="paragen", amount=3},
        {type="item", name="solidified-sarcorus", amount=5},
      },
    },
    ["gasoline-cellulose"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="nitrogen", amount=554},
        {type="fluid", name="pressured-air", amount=667},
        {type="item", name="cellulose", amount=5},
      },
      results = {
        {type="fluid", name="gasoline", amount=100},
      },
    },
    ["tuuphra-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=256},
        {type="item", name="aluminium-plate", amount=58},
        {type="item", name="bio-sample01", amount=12},
        {type="item", name="cdna", amount=3},
        {type="item", name="cottongut-codex", amount=1},
        {type="item", name="earth-cow-sample", amount=6},
        {type="item", name="empty-planter-box", amount=1},
      },
      results = {
        {type="item", name="tuuphra", amount=2},
      },
    },
    ["tuuphra-seeds"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="yaedols", amount=2},
      },
      results = {
        {type="item", name="tuuphra-seeds", amount=8},
      },
    },
    ["tuuphra-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="nitrogen", amount=554},
        {type="fluid", name="water", amount=100},
        {type="item", name="calcinates", amount=2},
        {type="item", name="lime", amount=3},
        {type="item", name="soil", amount=20},
      },
      results = {
        {type="item", name="tuuphra", amount=3},
      },
    },
    ["sweet-syrup"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="lubricant", amount=845},
        {type="item", name="calcium-carbide", amount=10},
      },
      results = {
        {type="fluid", name="sweet-syrup", amount=50},
      },
    },
    ["a-molasse"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="acetylene-canister", amount=14},
      },
      results = {
        {type="fluid", name="a-molasse", amount=100},
        {type="item", name="biomass", amount=8},
      },
    },
    ["korlex-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=29},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="seaweed", amount=19},
        {type="item", name="tin-plate", amount=3},
      },
      results = {
        {type="item", name="korlex-codex", amount=1},
      },
    },
    ["korlex-food-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="fish-oil", amount=100},
        {type="fluid", name="water", amount=300},
        {type="item", name="dried-meat", amount=1},
        {type="item", name="fawogae-substrate", amount=4},
        {type="item", name="filtration-media", amount=2},
        {type="item", name="kicalk", amount=6},
        {type="item", name="meat", amount=10},
        {type="item", name="sodium-hydroxide", amount=4},
        {type="item", name="tin-plate", amount=2},
        {type="item", name="yaedols", amount=1},
      },
      results = {
        {type="item", name="korlex-food-01", amount=3},
      },
    },
    ["korlex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="bitumen-froth", amount=1392},
        {type="fluid", name="outlet-gas-01", amount=1656},
        {type="item", name="auog-food-01", amount=41},
        {type="item", name="cdna", amount=5},
        {type="item", name="coal-dust", amount=343},
        {type="item", name="lead-plate", amount=13},
        {type="item", name="powdered-ralesia-seeds", amount=272},
        {type="item", name="retrovirus", amount=10},
      },
      results = {
        {type="item", name="korlex", amount=1},
      },
    },
    ["korlex-milk-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="empty-barrel-milk", amount=3},
        {type="item", name="fish", amount=5},
        {type="item", name="py-asphalt", amount=18},
        {type="item", name="syngas-barrel", amount=11},
        {type="item", name="tall-oil-barrel", amount=3},
      },
      results = {
        {type="item", name="barrel", amount=10},
        {type="item", name="barrel-milk", amount=3},
      },
    },
    ["korlex-pup-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anthracene-oil-canister", amount=3},
        {type="item", name="bonemeal", amount=60},
        {type="item", name="naphthalene-oil-barrel", amount=5},
        {type="item", name="water-barrel", amount=20},
      },
      results = {
        {type="item", name="barrel", amount=25},
        {type="item", name="korlex-pup", amount=3},
      },
    },
    ["korlex-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="molten-iron-barrel", amount=1},
        {type="item", name="py-aluminium", amount=5},
        {type="item", name="raw-fiber", amount=2},
        {type="item", name="salt", amount=78},
        {type="item", name="wood-fence", amount=12},
      },
      results = {
        {type="item", name="barrel", amount=8},
        {type="item", name="korlex", amount=2},
      },
    },
    ["outlet-gas-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=1138},
        {type="fluid", name="pressured-water", amount=6297},
      },
      results = {
        {type="fluid", name="outlet-gas-02", amount=100},
        {type="item", name="sulfur", amount=20},
      },
    },
    ["quench-redcoke"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=124},
        {type="fluid", name="pressured-air", amount=150},
        {type="item", name="ralesia-seeds", amount=20},
      },
      results = {
        {type="fluid", name="steam", amount=100},
        {type="item", name="coal-dust", amount=4},
        {type="item", name="coke", amount=30},
      },
    },
    ["redhot-coke"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=154},
        {type="item", name="coal", amount=20},
      },
      results = {
        {type="fluid", name="coke-oven-gas", amount=50},
        {type="item", name="redhot-coke", amount=5},
      },
    },
    ["outlet-gas-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="syngas", amount=660},
        {type="fluid", name="tar", amount=50},
        {type="item", name="chromium", amount=2},
        {type="item", name="stone", amount=5},
      },
      results = {
        {type="fluid", name="outlet-gas-01", amount=100},
      },
    },
    ["molybdenum-filtration"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="acidgas", amount=1320},
        {type="item", name="grade-4-chromite", amount=1},
      },
      results = {
        {type="item", name="molybdenum-sulfide", amount=10},
      },
    },
    ["calcinate-bone"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="meat", amount=9},
      },
      results = {
        {type="item", name="calcinates", amount=3},
      },
    },
    ["molybdenum-concentrate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=2769},
        {type="fluid", name="pressured-air", amount=1936},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=150},
        {type="item", name="molybdenum-concentrate", amount=10},
      },
    },
    ["molybdenum-oxide"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=425},
        {type="item", name="crushed-molybdenite", amount=88},
      },
      results = {
        {type="item", name="molybdenum-oxide", amount=10},
        {type="item", name="sulfur", amount=1},
      },
    },
    ["calcinate-separation"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=364},
        {type="item", name="gasoline-barrel", amount=11},
      },
      results = {
        {type="fluid", name="water", amount=10},
        {type="item", name="molybdenum-plate", amount=3},
      },
    },
    ["seaweed-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=200},
        {type="item", name="creamy-latex-barrel", amount=6},
        {type="item", name="limestone", amount=5},
        {type="item", name="ralesia-seeds", amount=3},
      },
      results = {
        {type="item", name="seaweed-mk02", amount=1},
      },
    },
    ["fertilizer-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="methanal", amount=306},
        {type="item", name="ash", amount=10},
        {type="item", name="mukmoux-fat", amount=6},
        {type="item", name="sand", amount=2},
        {type="item", name="urea", amount=5},
      },
      results = {
        {type="item", name="fertilizer", amount=10},
      },
    },
    ["fertilizer-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ash", amount=20},
        {type="item", name="biomass", amount=20},
        {type="item", name="moss", amount=7},
        {type="item", name="urea", amount=2},
      },
      results = {
        {type="item", name="fertilizer", amount=10},
      },
    },
    ["fertilizer-fish-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="fish-hydrolysate", amount=150},
      },
      results = {
        {type="item", name="fertilizer", amount=3},
      },
    },
    ["formic-acid"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="formamide", amount=100},
        {type="fluid", name="pressured-air", amount=67},
        {type="fluid", name="sulfuric-acid", amount=50},
      },
      results = {
        {type="fluid", name="formic-acid", amount=100},
      },
    },
    ["sap-seeds-mk02-gen"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="sodium-alginate", amount=2},
      },
      results = {
        {type="item", name="sap-seeds-mk02", amount=2},
      },
    },
    ["sap-tree-mk02-gen"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=86},
        {type="item", name="fish-oil-barrel", amount=3},
        {type="item", name="ralesia", amount=8},
        {type="item", name="skin", amount=3},
      },
      results = {
        {type="item", name="sap-tree-mk02", amount=1},
      },
    },
    ["casein-pulp-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=6141},
        {type="fluid", name="steam", amount=167},
      },
      results = {
        {type="fluid", name="casein-pulp-01", amount=100},
        {type="fluid", name="muddy-sludge", amount=50},
      },
    },
    ["fish-hydrolysate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=453},
        {type="fluid", name="water", amount=100},
        {type="item", name="fish", amount=10},
        {type="item", name="starch", amount=1},
      },
      results = {
        {type="fluid", name="fish-hydrolysate", amount=50},
      },
    },
    ["casein-mixture-01"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="acetic-acid", amount=50},
        {type="fluid", name="milk", amount=50},
      },
      results = {
        {type="fluid", name="casein-mixture", amount=50},
        {type="fluid", name="waste-water", amount=50},
      },
    },
    ["casein-pulp-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=618},
        {type="fluid", name="casein-pulp-01", amount=50},
      },
      results = {
        {type="fluid", name="casein-pulp-02", amount=50},
      },
    },
    ["casein-mixture-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=525},
        {type="fluid", name="milk", amount=50},
      },
      results = {
        {type="fluid", name="casein-mixture", amount=60},
        {type="fluid", name="waste-water", amount=50},
      },
    },
    ["honey-wax"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="btx-barrel", amount=3},
      },
      results = {
        {type="item", name="wax-barrel", amount=2},
      },
    },
    ["sugar-wax"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bonemeal", amount=8},
        {type="item", name="empty-barrel-milk", amount=1},
      },
      results = {
        {type="item", name="wax-barrel", amount=1},
      },
    },
    ["phosphate-mine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="carbon-filter", amount=1},
        {type="item", name="concrete", amount=868},
        {type="item", name="distilator", amount=3},
        {type="item", name="duralumin", amount=172},
        {type="item", name="latex", amount=36},
        {type="item", name="pipe", amount=70},
      },
      results = {
        {type="item", name="phosphate-mine", amount=2},
      },
    },
    ["rare-earth-mine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coal-slurry-barrel", amount=33},
        {type="item", name="grade-1-zinc", amount=110},
        {type="item", name="petroleum-gas-barrel", amount=23},
        {type="item", name="rare-earth-mud-barrel", amount=31},
        {type="item", name="storage-chest", amount=2},
        {type="item", name="subcritical-water-barrel", amount=112},
        {type="item", name="ticl4", amount=153},
      },
      results = {
        {type="item", name="rare-earth-mine", amount=1},
      },
    },
    ["subcritical-water-03"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=216},
        {type="fluid", name="hot-air", amount=300},
      },
      results = {
        {type="fluid", name="subcritical-water", amount=200},
      },
    },
    ["wax"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=25},
        {type="item", name="sb-grade-04", amount=30},
      },
      results = {
        {type="fluid", name="wax", amount=50},
      },
    },
    ["wax-honeycomb"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=25},
        {type="item", name="rich-clay", amount=22},
      },
      results = {
        {type="fluid", name="wax", amount=50},
      },
    },
    ["empty-comb-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="gasoline", amount=301},
      },
      results = {
        {type="item", name="empty-comb", amount=8},
      },
    },
    ["empty-honeycomb-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="purest-nitrogen-gas", amount=1510},
      },
      results = {
        {type="item", name="empty-honeycomb", amount=8},
      },
    },
    ["big-electric-pole"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="dried-meat", amount=3},
        {type="item", name="sodium-hydroxide", amount=30},
        {type="item", name="steel-plate", amount=6},
        {type="item", name="stone-brick", amount=4},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=1393},
        {type="fluid", name="water", amount=1452},
        {type="item", name="fish-food-01", amount=1},
        {type="item", name="small-parts-01", amount=20},
        {type="item", name="vacuum-tube", amount=1},
      },
      results = {
        {type="fluid", name="waste-water", amount=100},
        {type="item", name="fish-egg", amount=30},
      },
    },
    ["fish-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=1672},
        {type="item", name="fish", amount=20},
        {type="item", name="fish-food-01", amount=2},
        {type="item", name="naphthalene-oil-barrel", amount=2},
        {type="item", name="sand", amount=27},
      },
      results = {
        {type="item", name="fish", amount=5},
        {type="item", name="fish-mk02", amount=0.005},
      },
    },
    ["fish-egg-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="fish-oil", amount=60},
        {type="fluid", name="pressured-air", amount=968},
        {type="item", name="fish-egg", amount=49},
        {type="item", name="lime", amount=4},
        {type="item", name="methanol-canister", amount=3},
        {type="item", name="tinned-cable", amount=18},
      },
      results = {
        {type="fluid", name="waste-water", amount=100},
        {type="item", name="fish", amount=1},
        {type="item", name="fish-mk02", amount=7},
      },
    },
    ["cliff-explosives"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="empty-gas-canister", amount=1},
        {type="item", name="gasoline-barrel", amount=14},
        {type="item", name="iron-stick", amount=36},
      },
      results = {
        {type="item", name="cliff-explosives", amount=1},
      },
    },
    ["fast-inserter"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="burner-inserter", amount=8},
        {type="item", name="electronic-circuit", amount=4},
        {type="item", name="fenxsb-alloy", amount=3},
        {type="item", name="lead-plate", amount=16},
        {type="item", name="residual-oil-barrel", amount=1},
        {type="item", name="sncr-alloy", amount=1},
      },
      results = {
        {type="item", name="fast-inserter", amount=1},
      },
    },
    ["py-stack-inserter"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=123},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="niobium-plate", amount=8},
        {type="item", name="outlet-gas-01-canister", amount=30},
        {type="item", name="soil-extractor-mk01", amount=1},
      },
      results = {
        {type="item", name="py-stack-inserter", amount=1},
      },
    },
    ["flavonoids"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="moss", amount=15},
        {type="item", name="ralesia", amount=42},
      },
      results = {
        {type="fluid", name="flavonoids", amount=30},
      },
    },
    ["mo-mine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bio-sample", amount=18},
        {type="item", name="duralumin", amount=41},
        {type="item", name="jaw-crusher", amount=1},
        {type="item", name="moondrop-seeds-mk02", amount=35},
        {type="item", name="nbfe-alloy", amount=30},
        {type="item", name="py-tank-3000", amount=1},
        {type="item", name="steam-engine", amount=7},
      },
      results = {
        {type="item", name="mo-mine", amount=1},
      },
    },
    ["niobium-pipe"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2.5,
      ingredients = {
        {type="item", name="oil-sand-slurry-barrel", amount=2},
      },
      results = {
        {type="item", name="niobium-pipe", amount=5},
      },
    },
    ["niobium-pipe-to-ground"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2.5,
      ingredients = {
        {type="item", name="niobium-complex-barrel", amount=4},
        {type="item", name="refined-natural-gas-barrel", amount=2},
      },
      results = {
        {type="item", name="niobium-pipe-to-ground", amount=5},
      },
    },
    ["py-logistic-robot-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boiler", amount=4},
        {type="item", name="burner-inserter", amount=2},
        {type="item", name="dirty-syngas-canister", amount=1},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="fwf-mk01", amount=1},
        {type="item", name="lead-plate", amount=18},
        {type="item", name="molten-lead-barrel", amount=6},
        {type="item", name="powdered-aluminium", amount=2},
        {type="item", name="steel-plate", amount=29},
        {type="item", name="vrauks-food-01", amount=6},
        {type="item", name="zinc-chloride", amount=4},
      },
      results = {
        {type="item", name="py-logistic-robot-mk01", amount=1},
      },
    },
    ["yaedols-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="water", amount=112},
        {type="item", name="fertilizer", amount=7},
        {type="item", name="moondrop-seeds", amount=10},
        {type="item", name="redhot-coke", amount=1},
        {type="item", name="wood", amount=14},
      },
      results = {
        {type="item", name="yaedols", amount=4},
      },
    },
    ["yaedols-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 4,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=2617},
        {type="item", name="alien-sample01", amount=21},
        {type="item", name="aluminium-plate", amount=247},
        {type="item", name="cdna", amount=13},
        {type="item", name="earth-mouse-sample", amount=4},
        {type="item", name="plasmids", amount=8},
        {type="item", name="repair-pack", amount=15},
        {type="item", name="sea-sponge-codex", amount=4},
        {type="item", name="yaedols-spores", amount=85},
      },
      results = {
        {type="item", name="yaedols", amount=4},
      },
    },
    ["anthracene-gasoline-hydrogenation"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=459},
        {type="fluid", name="hydrogen", amount=50},
      },
      results = {
        {type="fluid", name="gasoline", amount=25},
      },
    },
    ["anthraquinone-from-naphthalene"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pitch", amount=363},
        {type="item", name="redhot-coke", amount=33},
      },
      results = {
        {type="fluid", name="anthraquinone", amount=100},
      },
    },
    ["aromatics-from-naphthalene"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=1470},
      },
      results = {
        {type="fluid", name="aromatics", amount=40},
        {type="item", name="coke", amount=3},
      },
    },
    ["bitumen-to-heavy-oil"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="bitumen", amount=100},
        {type="fluid", name="steam", amount=67},
        {type="item", name="gravel", amount=3},
      },
      results = {
        {type="fluid", name="heavy-oil", amount=100},
      },
    },
    ["hot-residual-mixture-to-coke"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=557},
        {type="fluid", name="hot-air", amount=77},
        {type="fluid", name="hot-residual-mixture", amount=150},
      },
      results = {
        {type="fluid", name="coke-oven-gas", amount=60},
        {type="item", name="coke", amount=40},
      },
    },
    ["naphthalene-solvent"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=1758},
        {type="fluid", name="hot-air", amount=1961},
      },
      results = {
        {type="fluid", name="organic-solvent", amount=30},
      },
    },
    ["natural-gas-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="tailings", amount=183},
        {type="item", name="pipe", amount=3},
      },
      results = {
        {type="fluid", name="raw-gas", amount=40},
      },
    },
    ["oil-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-air", amount=2266},
        {type="item", name="pipe", amount=3},
      },
      results = {
        {type="fluid", name="crude-oil", amount=40},
      },
    },
    ["rubber-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="organic-solvent", amount=50},
        {type="fluid", name="polybutadiene", amount=50},
        {type="item", name="belt", amount=3},
        {type="item", name="latex", amount=2},
      },
      results = {
        {type="item", name="rubber", amount=4},
      },
    },
    ["rubber-from-oleochemicals"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="coalbed-gas", amount=1492},
        {type="fluid", name="polybutadiene", amount=20},
        {type="item", name="carbon-black", amount=10},
        {type="item", name="latex", amount=1},
        {type="item", name="sulfur", amount=2},
      },
      results = {
        {type="item", name="rubber", amount=4},
      },
    },
    ["tar-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="drilling-fluid-0", amount=50},
        {type="item", name="pipe", amount=3},
      },
      results = {
        {type="fluid", name="tar", amount=100},
      },
    },
    ["ticl4"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=960},
        {type="item", name="rich-clay", amount=4},
        {type="item", name="titanium-plate", amount=3},
      },
      results = {
        {type="item", name="ticl4", amount=4},
      },
    },
    ["methane-to-methanol5"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=100},
        {type="fluid", name="methane", amount=100},
        {type="item", name="sncr-alloy", amount=1},
      },
      results = {
        {type="fluid", name="methanol", amount=150},
      },
    },
    ["methane-to-methanol6"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=100},
        {type="fluid", name="methane", amount=400},
        {type="item", name="grade-1-copper", amount=1},
        {type="item", name="kerogen", amount=14},
      },
      results = {
        {type="fluid", name="methanol", amount=300},
      },
    },
    ["naphtha-to-syngas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=376},
        {type="fluid", name="methanal", amount=370},
        {type="item", name="gravel", amount=3},
      },
      results = {
        {type="fluid", name="syngas", amount=400},
      },
    },
    ["reheat-coke-gas"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=100},
        {type="fluid", name="hot-molten-salt", amount=50},
      },
      results = {
        {type="fluid", name="coke-oven-gas", amount=95},
        {type="fluid", name="molten-salt", amount=50},
      },
    },
    ["warmer-stone-brick-1"] = {
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-air", amount=150},
        {type="item", name="py-asphalt", amount=16},
      },
      results = {
        {type="fluid", name="hot-air", amount=300},
        {type="item", name="stone-brick", amount=20},
      },
    },
    ["aromatics-2-diesel"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.15142857142857,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=2346},
        {type="fluid", name="light-oil", amount=423},
        {type="item", name="grade-3-zinc", amount=1},
      },
      results = {
        {type="fluid", name="diesel", amount=403},
      },
    },
    ["aromatics-2-petgas2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=1183},
        {type="fluid", name="steam", amount=955},
        {type="item", name="bolts", amount=9},
      },
      results = {
        {type="fluid", name="petroleum-gas", amount=300},
      },
    },
    ["bio-oil-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="heavy-oil", amount=478},
      },
      results = {
        {type="fluid", name="condensates", amount=150},
        {type="fluid", name="low-distillate", amount=50},
        {type="fluid", name="medium-distillate", amount=50},
      },
    },
    ["low-distillate-to-btx"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=3668},
        {type="item", name="bolts", amount=9},
      },
      results = {
        {type="fluid", name="btx", amount=100},
      },
    },
    ["medium-distillate-to-high-distillate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=1974},
        {type="fluid", name="steam", amount=300},
        {type="item", name="ticl4", amount=1},
      },
      results = {
        {type="fluid", name="high-distillate", amount=100},
      },
    },
    ["medium-distillate-to-stripped-distillate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=3358},
        {type="item", name="carbon-dioxide-barrel", amount=1},
      },
      results = {
        {type="fluid", name="stripped-distillate", amount=100},
      },
    },
    ["low-distillate-to-coal-gas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="tailings", amount=479},
        {type="item", name="bolts", amount=9},
      },
      results = {
        {type="fluid", name="coal-gas", amount=200},
      },
    },
    ["stripped-distillate-to-benzene"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="stripped-distillate", amount=100},
        {type="item", name="bolts", amount=9},
      },
      results = {
        {type="fluid", name="benzene", amount=150},
      },
    },
    ["stripped-distillate-to-cumene"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="acidgas", amount=372},
        {type="item", name="capacitor1", amount=3},
      },
      results = {
        {type="fluid", name="cumene", amount=200},
      },
    },
    ["stripped-distillate-to-gasoline"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="heavy-oil", amount=321},
        {type="item", name="bolts", amount=9},
      },
      results = {
        {type="fluid", name="gasoline", amount=200},
      },
    },
    ["stripped-distillate-to-methanol"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.10666666666667,
      ingredients = {
        {type="fluid", name="pressured-air", amount=9180},
        {type="item", name="grade-2-tin", amount=1},
      },
      results = {
        {type="fluid", name="methanol", amount=166},
      },
    },
    ["fluorine-to-olefins"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="boric-acid", amount=249},
        {type="fluid", name="oleochemicals", amount=343},
        {type="item", name="sodium-hydroxide", amount=2},
      },
      results = {
        {type="fluid", name="naphtha", amount=50},
        {type="fluid", name="olefin", amount=100},
      },
    },
    ["high-distillate-condensing"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="methanal", amount=693},
        {type="fluid", name="steam", amount=418},
      },
      results = {
        {type="fluid", name="condensed-distillate", amount=50},
        {type="fluid", name="naphtha", amount=150},
      },
    },
    ["natural-gas-refining"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="gasoline", amount=50},
        {type="fluid", name="residual-mixture", amount=773},
      },
      results = {
        {type="fluid", name="condensates", amount=100},
        {type="fluid", name="naphtha", amount=50},
        {type="fluid", name="natural-gas", amount=250},
      },
    },
    ["refined-natural-gas-to-condensates"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=124},
        {type="fluid", name="gasoline", amount=5},
        {type="fluid", name="pressured-air", amount=3744},
      },
      results = {
        {type="fluid", name="condensates", amount=100},
        {type="fluid", name="naphtha", amount=50},
        {type="fluid", name="steam", amount=200},
      },
    },
    ["condensed-distillate-separation"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=363},
      },
      results = {
        {type="fluid", name="gasoline", amount=25},
        {type="fluid", name="petroleum-gas", amount=50},
      },
    },
    ["low-distillate-to-heavy-oil"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=371},
        {type="fluid", name="gasoline", amount=5},
        {type="fluid", name="nitrogen", amount=612},
      },
      results = {
        {type="fluid", name="heavy-oil", amount=200},
        {type="fluid", name="residual-oil", amount=50},
        {type="fluid", name="steam", amount=600},
      },
    },
    ["naphtha-2-tall-oil"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=4230},
      },
      results = {
        {type="fluid", name="tall-oil", amount=100},
      },
    },
    ["bitumen-comb"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ore-chromium", amount=15},
      },
      results = {
        {type="fluid", name="bitumen", amount=50},
        {type="item", name="used-comb", amount=1},
      },
    },
    ["raw-gas"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="condensates", amount=100},
      },
      results = {
        {type="fluid", name="btx", amount=30},
        {type="fluid", name="refined-natural-gas", amount=100},
        {type="fluid", name="tailings", amount=50},
      },
    },
    ["residual-mixture"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="molten-glass", amount=178},
        {type="fluid", name="pressured-water", amount=343},
        {type="item", name="coal-dust", amount=8},
      },
      results = {
        {type="fluid", name="residual-mixture", amount=100},
      },
    },
    ["bio-oil-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water-saline", amount=850},
      },
      results = {
        {type="fluid", name="condensates", amount=160},
        {type="item", name="ash", amount=2},
        {type="item", name="raw-coal", amount=20},
      },
    },
    ["bitumen-refining"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="bitumen", amount=300},
        {type="fluid", name="hot-air", amount=308},
      },
      results = {
        {type="fluid", name="condensates", amount=25},
        {type="fluid", name="high-distillate", amount=25},
        {type="fluid", name="low-distillate", amount=100},
        {type="fluid", name="medium-distillate", amount=75},
        {type="fluid", name="residual-mixture", amount=250},
      },
    },
    ["crude-from-manure"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="blood", amount=284},
      },
      results = {
        {type="fluid", name="scrude", amount=70},
        {type="fluid", name="steam", amount=50},
        {type="fluid", name="tailings", amount=50},
        {type="item", name="soot", amount=3},
      },
    },
    ["hot-residual-mixture"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.02,
      ingredients = {
        {type="fluid", name="tailings", amount=242},
        {type="item", name="zinc-chloride", amount=1},
      },
      results = {
        {type="fluid", name="hot-residual-mixture", amount=102},
      },
    },
    ["oil-refining"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="crude-oil", amount=300},
        {type="fluid", name="water", amount=1200},
      },
      results = {
        {type="fluid", name="condensates", amount=125},
        {type="fluid", name="high-distillate", amount=125},
        {type="fluid", name="low-distillate", amount=100},
        {type="fluid", name="medium-distillate", amount=100},
        {type="fluid", name="residual-mixture", amount=50},
      },
    },
    ["residual-mixture-distillation"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="kerosene", amount=735},
        {type="fluid", name="vacuum", amount=200},
      },
      results = {
        {type="fluid", name="hot-residual-mixture", amount=25},
        {type="fluid", name="residual-oil", amount=50},
        {type="item", name="coke", amount=40},
      },
    },
    ["used-comb-oil-recycling"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="water", amount=8},
        {type="item", name="grade-4-copper", amount=1},
      },
      results = {
        {type="fluid", name="bitumen", amount=20},
        {type="fluid", name="residual-oil", amount=40},
      },
    },
    ["used-comb-to-residual-mixture"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.01666666666667,
      ingredients = {
        {type="item", name="bio-container", amount=4},
        {type="item", name="melamine", amount=4},
      },
      results = {
        {type="fluid", name="residual-mixture", amount=61},
      },
    },
    ["arqad-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=20},
        {type="item", name="copper-cable", amount=58},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="lead-plate", amount=2},
      },
      results = {
        {type="item", name="arqad-codex", amount=1},
      },
    },
    ["arqad-egg-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="arqad-queen", amount=1},
        {type="item", name="hydrofluoric-acid-barrel", amount=20},
        {type="item", name="sb-grade-04", amount=68},
        {type="item", name="used-comb", amount=5},
        {type="item", name="yaedols", amount=1},
      },
      results = {
        {type="item", name="arqad-egg", amount=10},
        {type="item", name="arqad-queen", amount=1},
        {type="item", name="barrel", amount=13},
      },
    },
    ["arqad-filled-comb-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.41272706827531,
      ingredients = {
        {type="item", name="ammonia-barrel", amount=1},
        {type="item", name="empty-comb", amount=7},
        {type="item", name="methanal-barrel", amount=5},
        {type="item", name="py-iron-oxide", amount=5},
      },
      results = {
        {type="item", name="barrel", amount=3},
        {type="item", name="filled-comb", amount=7},
      },
    },
    ["arqad-filled-honeycomb-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="item", name="ore-tin", amount=46},
        {type="item", name="purified-syngas-barrel", amount=2},
      },
      results = {
        {type="item", name="honeycomb", amount=4},
      },
    },
    ["arqad"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=1000},
        {type="item", name="alien-sample01", amount=70},
        {type="item", name="aluminium-plate", amount=58},
        {type="item", name="arqad-codex", amount=1},
        {type="item", name="earth-bear-sample", amount=1},
      },
      results = {
        {type="item", name="arqad", amount=1},
        {type="item", name="arqad-egg", amount=10},
      },
    },
    ["arqad-egg-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="arqad-honey-barrel", amount=3},
        {type="item", name="arqad-queen", amount=1},
        {type="item", name="formic-acid-barrel", amount=51},
        {type="item", name="naphtha-canister", amount=1},
        {type="item", name="ralesia-seeds", amount=18},
        {type="item", name="rare-earth-powder", amount=81},
      },
      results = {
        {type="item", name="arqad-egg", amount=15},
        {type="item", name="arqad-queen", amount=1},
        {type="item", name="barrel", amount=13},
      },
    },
    ["arqad-hive-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="engine-unit", amount=5},
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="gun-turret", amount=24},
        {type="item", name="iron-slime-barrel", amount=1},
        {type="item", name="nickel-plate", amount=27},
        {type="item", name="rail-chain-signal", amount=3},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="stone-brick", amount=59},
      },
      results = {
        {type="item", name="arqad-hive-mk01", amount=1},
      },
    },
    ["arqad-egg-nests-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boiler", amount=2},
        {type="item", name="cocoon", amount=9},
        {type="item", name="empty-comb", amount=1},
        {type="item", name="ree-slurry-barrel", amount=8},
        {type="item", name="vrauks-food-01", amount=1},
      },
      results = {
        {type="item", name="arqad-egg-nest", amount=1},
        {type="item", name="barrel", amount=1},
      },
    },
    ["arqad-maggots-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="caged-vrauks", amount=10},
        {type="item", name="shell", amount=36},
        {type="item", name="shotgun-shell", amount=42},
      },
      results = {
        {type="item", name="arqad-maggot", amount=30},
        {type="item", name="cage", amount=10},
        {type="item", name="used-comb", amount=5},
      },
    },
    ["arqad-queen-1"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 0.9828115348447,
      ingredients = {
        {type="item", name="arqad-egg", amount=2},
      },
      results = {
        {type="fluid", name="arqad-honey", amount=244},
        {type="item", name="empty-honeycomb", amount=5},
      },
    },
    ["hotair-empty-honeycomb-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="muddy-sludge", amount=3430},
      },
      results = {
        {type="item", name="empty-honeycomb", amount=10},
      },
    },
    ["bitumen-to-nitrogen"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water-saline", amount=254},
      },
      results = {
        {type="fluid", name="nitrogen", amount=200},
      },
    },
    ["bitumen-to-sulfur"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="bitumen", amount=100},
        {type="fluid", name="water", amount=200},
      },
      results = {
        {type="item", name="sulfur", amount=10},
      },
    },
    ["crush-oil-sand"] = {
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=1521},
        {type="fluid", name="oxygen", amount=50},
        {type="fluid", name="water", amount=900},
      },
      results = {
        {type="fluid", name="dirty-syngas", amount=100},
      },
    },
    ["hot-syngas-cooldown"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=186},
        {type="fluid", name="geothermal-water", amount=3072},
      },
      results = {
        {type="fluid", name="steam", amount=300},
        {type="fluid", name="syngas", amount=500},
      },
    },
    ["quenching-dirty-syngas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=660},
        {type="fluid", name="nitrogen", amount=1463},
        {type="item", name="seaweed", amount=6},
      },
      results = {
        {type="fluid", name="flue-gas", amount=4000},
        {type="fluid", name="purified-syngas", amount=400},
        {type="item", name="soot", amount=8},
      },
    },
    ["scrubbing-purified-syngas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=103},
        {type="fluid", name="vacuum", amount=3479},
      },
      results = {
        {type="fluid", name="hot-syngas", amount=100},
        {type="item", name="soot", amount=2},
      },
    },
    ["oil-sand-slurry"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 0.93,
      ingredients = {
        {type="fluid", name="pressured-air", amount=186},
        {type="fluid", name="pressured-water", amount=558},
        {type="item", name="meat", amount=2},
      },
      results = {
        {type="fluid", name="oil-sand-slurry", amount=93},
      },
    },
    ["bitumen-froth"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.17,
      ingredients = {
        {type="fluid", name="pressured-air", amount=234},
        {type="fluid", name="vacuum", amount=2388},
        {type="item", name="benzene-canister", amount=1},
      },
      results = {
        {type="fluid", name="bitumen-froth", amount=117},
        {type="fluid", name="tailings", amount=117},
      },
    },
    ["btx-to-benzene"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="btx", amount=100},
        {type="fluid", name="pressured-water", amount=343},
        {type="item", name="chromium", amount=2},
      },
      results = {
        {type="fluid", name="benzene", amount=200},
      },
    },
    ["btx-to-methane"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=771},
        {type="fluid", name="scrude", amount=449},
        {type="item", name="tin-plate", amount=2},
      },
      results = {
        {type="fluid", name="methane", amount=300},
      },
    },
    ["aromatics-to-petgas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="aromatics", amount=100},
        {type="fluid", name="steam", amount=212},
      },
      results = {
        {type="fluid", name="petroleum-gas", amount=80},
      },
    },
    ["bitumen"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="bitumen-froth", amount=100},
        {type="fluid", name="naphtha", amount=70},
        {type="fluid", name="pressured-air", amount=100},
      },
      results = {
        {type="fluid", name="bitumen", amount=250},
        {type="fluid", name="tailings", amount=50},
      },
    },
    ["explosive-glycerol"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="methanol", amount=803},
        {type="fluid", name="water", amount=11884},
      },
      results = {
        {type="item", name="explosives", amount=5},
      },
    },
    ["filtration-media"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.8,
      ingredients = {
        {type="item", name="chromium", amount=27},
        {type="item", name="glass", amount=11},
        {type="item", name="grade-3-lead", amount=2},
        {type="item", name="gravel", amount=47},
        {type="item", name="pcb1", amount=1},
      },
      results = {
        {type="item", name="filtration-media", amount=9},
      },
    },
    ["niobium-dust"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=200},
        {type="item", name="stone", amount=50},
      },
      results = {
        {type="fluid", name="tailings", amount=100},
        {type="fluid", name="tar", amount=100},
        {type="item", name="coarse", amount=10},
        {type="item", name="tailings-dust", amount=10},
      },
    },
    ["milling-ree"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.45568732557452,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=1800},
        {type="fluid", name="sulfuric-acid", amount=291},
        {type="item", name="caged-auog", amount=1},
      },
      results = {
        {type="fluid", name="rare-earth-mud", amount=364},
        {type="fluid", name="steam", amount=2910},
        {type="item", name="rich-dust", amount=7},
        {type="item", name="sand", amount=15},
      },
    },
    ["milling-molybdenite"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.01544160636885,
      ingredients = {
        {type="fluid", name="tailings", amount=302},
        {type="item", name="btx-barrel", amount=1},
      },
      results = {
        {type="fluid", name="rare-earth-mud", amount=102},
        {type="item", name="zinc-plate", amount=5},
      },
    },
    ["ree-slurry"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="olefin", amount=402},
        {type="fluid", name="water", amount=15846},
      },
      results = {
        {type="fluid", name="ree-slurry", amount=100},
        {type="fluid", name="tailings", amount=100},
      },
    },
    ["ree-solution"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=578},
        {type="fluid", name="water-saline", amount=1705},
      },
      results = {
        {type="fluid", name="ree-solution", amount=100},
        {type="item", name="uranium-ore", amount=0.1},
      },
    },
    ["crusher-ree"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="methanal-barrel", amount=1},
      },
      results = {
        {type="item", name="rare-earth-powder", amount=5},
        {type="item", name="stone", amount=5},
      },
    },
    ["ree-concentrate2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=15928},
        {type="fluid", name="hot-air", amount=1292},
      },
      results = {
        {type="item", name="chromite-sand", amount=10},
        {type="item", name="ree-concentrate", amount=20},
      },
    },
    ["ree-concentrate1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="scrude", amount=987},
      },
      results = {
        {type="item", name="iron-oxide", amount=6},
        {type="item", name="ree-concentrate", amount=10},
      },
    },
    ["reo"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="coal-gas", amount=1032},
        {type="fluid", name="purest-nitrogen-gas", amount=951},
      },
      results = {
        {type="item", name="copper-ore", amount=5},
        {type="item", name="ree-concentrate", amount=20},
      },
    },
    ["xyhiphoe-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-stick", amount=63},
        {type="item", name="tin-plate", amount=3},
        {type="item", name="tinned-cable", amount=327},
      },
      results = {
        {type="item", name="xyhiphoe-codex", amount=1},
      },
    },
    ["xyhiphoe-cub-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=583},
        {type="fluid", name="water-saline", amount=1123},
        {type="item", name="diesel-barrel", amount=1},
        {type="item", name="fish", amount=17},
        {type="item", name="outlet-gas-02-barrel", amount=1},
      },
      results = {
        {type="fluid", name="waste-water", amount=650},
        {type="item", name="xyhiphoe-cub", amount=4},
      },
    },
    ["xyhiphoe-pool-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=179},
        {type="item", name="duralumin", amount=20},
        {type="item", name="empty-comb", amount=68},
        {type="item", name="iron-plate", amount=215},
        {type="item", name="iron-stick", amount=49},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="ralesia-plantation-mk01", amount=2},
        {type="item", name="titanium-plate", amount=811},
        {type="item", name="vitreloy", amount=16},
      },
      results = {
        {type="item", name="xyhiphoe-pool-mk01", amount=2},
      },
    },
    ["xyhiphoe"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=618},
        {type="fluid", name="fish-oil", amount=660},
        {type="item", name="bio-sample01", amount=2},
        {type="item", name="earth-crustacean-sample", amount=1},
        {type="item", name="earth-generic-sample", amount=3},
        {type="item", name="retrovirus", amount=7},
        {type="item", name="unslimed-iron", amount=26},
        {type="item", name="vrauks", amount=1},
      },
      results = {
        {type="item", name="xyhiphoe", amount=1},
      },
    },
    ["xyhiphoe-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 0.96401968844053,
      ingredients = {
        {type="fluid", name="hot-air", amount=1393},
        {type="fluid", name="steam", amount=1750},
        {type="item", name="fish", amount=8},
        {type="item", name="moondrop", amount=1},
        {type="item", name="syngas-canister", amount=8},
      },
      results = {
        {type="fluid", name="waste-water", amount=200},
        {type="item", name="xyhiphoe", amount=1},
      },
    },
    ["niobium-concentrate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 0.902452357250745,
      ingredients = {
        {type="item", name="aromatics-canister", amount=2},
      },
      results = {
        {type="item", name="niobium-concentrate", amount=9},
        {type="item", name="sand", amount=2},
      },
    },
    ["nbfe-alloy"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="nitrogen", amount=250},
        {type="fluid", name="pressured-steam", amount=3557},
      },
      results = {
        {type="item", name="niobium-oxide", amount=10},
      },
    },
    ["niobium-plate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ceramic", amount=17},
        {type="item", name="iron-ore-dust", amount=2},
      },
      results = {
        {type="item", name="niobium-plate", amount=4},
      },
    },
    ["niobium-complex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.19,
      ingredients = {
        {type="fluid", name="hydrogen-chloride", amount=119},
        {type="fluid", name="organic-solvent", amount=60},
        {type="item", name="sulfuric-acid-barrel", amount=2},
      },
      results = {
        {type="fluid", name="niobium-complex", amount=119},
      },
    },
    ["niobium-powder"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
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
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
      science_level = 4,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="firearm-magazine", amount=5},
        {type="item", name="petroleum-gas-canister", amount=13},
        {type="item", name="pipe", amount=9},
      },
      results = {
        {type="item", name="defender-capsule", amount=1},
      },
    },
    ["flamethrower"] = {
      mode = "softmax-semantic-substitution",
      science_level = 4,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-plate", amount=14},
        {type="item", name="transport-belt", amount=15},
      },
      results = {
        {type="item", name="flamethrower", amount=1},
      },
    },
    ["rocket-launcher"] = {
      mode = "softmax-semantic-substitution",
      science_level = 4,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="fine-powdered-biomass", amount=73},
        {type="item", name="grade-1-zinc", amount=1},
        {type="item", name="pitch-canister", amount=16},
      },
      results = {
        {type="item", name="rocket-launcher", amount=1},
      },
    },
    ["flamethrower-ammo"] = {
      mode = "softmax-semantic-substitution",
      science_level = 4,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="tailings", amount=259},
        {type="item", name="sb-grade-02", amount=26},
      },
      results = {
        {type="item", name="flamethrower-ammo", amount=1},
      },
    },
    ["rocket"] = {
      mode = "softmax-semantic-substitution",
      science_level = 4,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-pup", amount=5},
        {type="item", name="moondrop-seeds", amount=1},
      },
      results = {
        {type="item", name="rocket", amount=1},
      },
    },
    ["flamethrower-turret"] = {
      mode = "softmax-semantic-substitution",
      science_level = 4,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="crushed-quartz", amount=211},
        {type="item", name="duralumin", amount=5},
        {type="item", name="scrude-canister", amount=2},
        {type="item", name="soda-ash-barrel", amount=5},
      },
      results = {
        {type="item", name="flamethrower-turret", amount=1},
      },
    },
    ["land-mine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 4,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boric-acid-barrel", amount=19},
        {type="item", name="grade-1-nickel", amount=1},
      },
      results = {
        {type="item", name="land-mine", amount=4},
      },
    },
    ["py-science-pack-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 4,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="arqad-honey", amount=600},
        {type="fluid", name="water-saline", amount=5192},
        {type="item", name="alien-sample-02", amount=1},
        {type="item", name="barrel-milk", amount=6},
        {type="item", name="cottongut", amount=23},
        {type="item", name="intermetallics", amount=17},
        {type="item", name="melamine", amount=86},
        {type="item", name="paragen", amount=1},
        {type="item", name="petri-dish-bacteria", amount=25},
        {type="item", name="stone-wool", amount=78},
        {type="item", name="zipir1", amount=2},
      },
      results = {
        {type="item", name="py-science-pack-2", amount=18},
      },
    },
    ["arthropod-blood-to-copper"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="subcritical-water", amount=1552},
      },
      results = {
        {type="item", name="copper-ore", amount=20},
      },
    },
    ["guts-to-copper"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="brain", amount=2},
      },
      results = {
        {type="item", name="copper-ore", amount=15},
      },
    },
    ["meat-and-gut-to-copper"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.17142857142857,
      ingredients = {
        {type="item", name="brain", amount=2},
        {type="item", name="meat", amount=6},
      },
      results = {
        {type="item", name="copper-ore", amount=41},
      },
    },
    ["tuuphra-to-copper"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="tuuphra", amount=4},
      },
      results = {
        {type="item", name="copper-ore", amount=20},
      },
    },
    ["yaedols-to-copper"] = {
      mode = "input-preserved-unmodified",
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
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="blood", amount=100},
      },
      results = {
        {type="item", name="urea", amount=10},
      },
    },
    ["btx-to-ethylene"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.1,
      ingredients = {
        {type="item", name="calcium-carbide", amount=1},
        {type="item", name="powdered-phosphate-rock", amount=4},
        {type="item", name="salt", amount=6},
      },
      results = {
        {type="item", name="ceramic", amount=11},
      },
    },
    ["crude-cermet"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="item", name="crushed-molybdenite", amount=2},
        {type="item", name="graphite", amount=4},
        {type="item", name="ore-lead", amount=3},
      },
      results = {
        {type="item", name="crude-cermet", amount=6},
      },
    },
    ["cermet"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="lubricant", amount=200},
        {type="item", name="ash", amount=10},
        {type="item", name="crude-cermet", amount=3},
      },
      results = {
        {type="item", name="cermet", amount=5},
      },
    },
    ["concrete-02"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="boric-acid", amount=400},
        {type="fluid", name="water", amount=100},
        {type="item", name="cellulose", amount=4},
        {type="item", name="stone-brick", amount=5},
      },
      results = {
        {type="item", name="concrete", amount=20},
      },
    },
    ["cool-steam-500-to-250"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=200},
        {type="fluid", name="water", amount=220},
      },
      results = {
        {type="fluid", name="steam", amount=410},
      },
    },
    ["sodium-sulfate-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=50},
        {type="item", name="salt", amount=24},
      },
      results = {
        {type="fluid", name="water", amount=50},
        {type="item", name="sodium-sulfate", amount=1},
      },
    },
    ["fawogae-to-sulfur"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="fawogae", amount=5},
      },
      results = {
        {type="item", name="sulfur", amount=5},
      },
    },
    ["fish-to-iron"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="fish-oil", amount=50},
      },
      results = {
        {type="item", name="iron-ore", amount=20},
      },
    },
    ["meat-to-iron"] = {
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-oxide", amount=12},
        {type="item", name="phosphate-rock", amount=5},
      },
      results = {
        {type="item", name="iron-ore", amount=1},
        {type="item", name="p2s5", amount=1},
      },
    },
    ["tuupha-to-iron"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="tuuphra", amount=8},
      },
      results = {
        {type="item", name="iron-ore", amount=6},
      },
    },
    ["trits-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="inductor1", amount=34},
        {type="item", name="nexelit-plate", amount=3},
        {type="item", name="seaweed", amount=76},
      },
      results = {
        {type="item", name="trits-codex", amount=1},
      },
    },
    ["trits-reef-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="arthropod-blood-barrel", amount=2},
        {type="item", name="fiber", amount=668},
        {type="item", name="kicalk-seeds", amount=164},
        {type="item", name="middle-oil-canister", amount=21},
        {type="item", name="molybdenite-pulp-barrel", amount=67},
        {type="item", name="oil-sand-slurry-barrel", amount=20},
        {type="item", name="olefin-barrel", amount=21},
        {type="item", name="sic", amount=58},
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
        {type="fluid", name="water", amount=1000},
        {type="item", name="alien-sample-02", amount=2},
        {type="item", name="aluminium-plate", amount=120},
        {type="item", name="cocoon", amount=5},
        {type="item", name="cytostatics", amount=2},
        {type="item", name="earth-crustacean-sample", amount=1},
        {type="item", name="earth-generic-sample", amount=2},
        {type="item", name="mukmoux-codex", amount=1},
      },
      results = {
        {type="item", name="trits", amount=1},
      },
    },
    ["trits-cub-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=8175},
        {type="item", name="albumin", amount=1},
        {type="item", name="fertilizer", amount=9},
        {type="item", name="fish", amount=2},
        {type="item", name="sea-sponge-sprouts-mk02", amount=1},
        {type="item", name="trits", amount=1},
        {type="item", name="wood", amount=26},
      },
      results = {
        {type="fluid", name="waste-water", amount=300},
        {type="item", name="trits-pup", amount=2},
      },
    },
    ["trits-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="bitumen", amount=305},
        {type="item", name="filtration-media", amount=2},
        {type="item", name="fish", amount=3},
        {type="item", name="moondrop-mk02", amount=2},
        {type="item", name="trits-pup", amount=1},
        {type="item", name="wood-seeds", amount=30},
      },
      results = {
        {type="fluid", name="waste-water", amount=250},
        {type="item", name="trits", amount=2},
      },
    },
    ["glass-core"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="molten-glass", amount=189},
        {type="item", name="gold-plate", amount=5},
        {type="item", name="sulfur", amount=8},
      },
      results = {
        {type="item", name="glass-core", amount=2},
      },
    },
    ["hotair-glass-core"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="molten-glass", amount=100},
        {type="item", name="silver-plate", amount=3},
        {type="item", name="sulfur", amount=4},
      },
      results = {
        {type="item", name="glass-core", amount=2},
      },
    },
    ["guar-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="bio-sample", amount=5},
        {type="item", name="cytostatics", amount=2},
        {type="item", name="earth-cow-sample", amount=4},
        {type="item", name="earth-crustacean-sample", amount=5},
        {type="item", name="empty-planter-box", amount=1},
        {type="item", name="ulric-codex", amount=4},
        {type="item", name="zipir-codex", amount=16},
      },
      results = {
        {type="item", name="guar", amount=1},
      },
    },
    ["guar-seeds"] = {
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="fluid", name="water", amount=279},
        {type="item", name="guar-seeds", amount=7},
        {type="item", name="kicalk", amount=1},
        {type="item", name="limestone", amount=8},
      },
      results = {
        {type="item", name="guar", amount=14},
      },
    },
    ["acid-refined-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="acetic-acid", amount=10},
        {type="item", name="refined-hazard-concrete", amount=2},
      },
      results = {
        {type="item", name="acid-refined-concrete", amount=3},
      },
    },
    ["black-refined-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="rare-earth-ore", amount=9},
        {type="item", name="refined-hazard-concrete", amount=2},
      },
      results = {
        {type="item", name="black-refined-concrete", amount=3},
      },
    },
    ["blue-refined-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="fertilizer", amount=2},
        {type="item", name="refined-hazard-concrete", amount=2},
      },
      results = {
        {type="item", name="blue-refined-concrete", amount=3},
      },
    },
    ["cyan-refined-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="cyanic-acid", amount=13},
        {type="item", name="pipe", amount=3},
      },
      results = {
        {type="item", name="cyan-refined-concrete", amount=4},
      },
    },
    ["orange-refined-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="cellulose", amount=2},
        {type="item", name="methane-barrel", amount=1},
      },
      results = {
        {type="item", name="orange-refined-concrete", amount=6},
      },
    },
    ["purple-refined-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=127},
        {type="item", name="pipe", amount=3},
      },
      results = {
        {type="item", name="purple-refined-concrete", amount=3},
      },
    },
    ["brown-refined-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="item", name="geothermal-water-barrel", amount=4},
        {type="item", name="py-limestone", amount=1},
      },
      results = {
        {type="item", name="brown-refined-concrete", amount=4},
      },
    },
    ["green-refined-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="item", name="hot-air-barrel", amount=1},
        {type="item", name="pure-sand", amount=8},
      },
      results = {
        {type="item", name="green-refined-concrete", amount=5},
      },
    },
    ["pink-refined-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="formica", amount=2},
        {type="item", name="moondrop-seeds", amount=2},
      },
      results = {
        {type="item", name="pink-refined-concrete", amount=3},
      },
    },
    ["red-refined-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="fluid", name="blood", amount=24},
        {type="item", name="powdered-aluminium", amount=1},
      },
      results = {
        {type="item", name="red-refined-concrete", amount=5},
      },
    },
    ["yellow-refined-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="fertilizer", amount=1},
        {type="item", name="refined-hazard-concrete", amount=2},
      },
      results = {
        {type="item", name="yellow-refined-concrete", amount=3},
      },
    },
    ["ipod"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boric-acid-barrel", amount=146},
        {type="item", name="empty-fuel-canister", amount=131},
        {type="item", name="grade-2-nickel", amount=28},
        {type="item", name="iron-plate", amount=1},
        {type="item", name="lead-plate", amount=101},
        {type="item", name="molybdenite-dust", amount=129},
        {type="item", name="niobium-plate", amount=16},
      },
      results = {
        {type="item", name="ipod", amount=1},
      },
    },
    ["kicalk-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=150},
        {type="fluid", name="steam", amount=167},
        {type="item", name="ash", amount=10},
        {type="item", name="biomass", amount=10},
        {type="item", name="fertilizer", amount=5},
        {type="item", name="glass", amount=5},
        {type="item", name="ground-sample01", amount=4},
        {type="item", name="powdered-phosphate-rock", amount=1},
        {type="item", name="raw-fiber", amount=23},
      },
      results = {
        {type="item", name="kicalk", amount=20},
      },
    },
    ["kicalk-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=300},
        {type="fluid", name="steam", amount=333},
        {type="item", name="kicalk", amount=2},
        {type="item", name="powdered-phosphate-rock", amount=4},
        {type="item", name="raw-fiber", amount=15},
        {type="item", name="small-lamp", amount=5},
      },
      results = {
        {type="item", name="kicalk", amount=1},
        {type="item", name="kicalk-mk02", amount=0.005},
        {type="item", name="kicalk-seeds-mk02", amount=0.02},
      },
    },
    ["kicalk-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.00117721586435,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=400},
        {type="fluid", name="flutec-pp6", amount=50},
        {type="item", name="boron-trioxide", amount=3},
        {type="item", name="kicalk-seeds-mk02", amount=5},
        {type="item", name="small-lamp", amount=5},
      },
      results = {
        {type="item", name="kicalk-mk02", amount=5},
        {type="item", name="kicalk-seeds", amount=2},
        {type="item", name="kicalk-seeds-mk02", amount=1},
      },
    },
    ["meat-to-phosphate"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="meat", amount=13},
      },
      results = {
        {type="item", name="phosphate-rock", amount=3},
      },
    },
    ["wood-seeds-to-phosphate"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="wood-seeds", amount=20},
      },
      results = {
        {type="item", name="phosphate-rock", amount=2},
      },
    },
    ["ocula"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="molten-iron", amount=906},
        {type="fluid", name="molten-lead", amount=674},
        {type="item", name="condensates-barrel", amount=4868},
        {type="item", name="kicalk-mk02", amount=52},
        {type="item", name="low-grade-copper", amount=135},
        {type="item", name="natural-gas-barrel", amount=566},
        {type="item", name="ore-titanium", amount=19},
      },
      results = {
        {type="item", name="ocula", amount=1},
      },
    },
    ["py-logo-15tiles"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=491},
        {type="item", name="geothermal-water-barrel", amount=11},
        {type="item", name="p2s5", amount=32},
        {type="item", name="wooden-chest", amount=5},
      },
      results = {
        {type="item", name="py-logo-15tiles", amount=1},
      },
    },
    ["rail-2"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="crushed-molybdenite", amount=5},
        {type="item", name="gunpowder", amount=7},
      },
      results = {
        {type="item", name="resorcinol", amount=2},
      },
    },
    ["sample-cup"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=50},
        {type="fluid", name="zogna-bacteria", amount=100},
        {type="item", name="sea-sponge", amount=2},
      },
      results = {
        {type="fluid", name="water-saline", amount=50},
        {type="item", name="sea-sponge", amount=1},
        {type="item", name="sea-sponge-mk02", amount=0.005},
      },
    },
    ["sea-sponge-sprouts-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 3.74835054564602,
      ingredients = {
        {type="fluid", name="slacked-lime", amount=181},
        {type="fluid", name="zogna-bacteria", amount=181},
        {type="item", name="sea-sponge-sprouts-mk02", amount=4},
      },
      results = {
        {type="fluid", name="water-saline", amount=181},
        {type="item", name="sea-sponge-mk02", amount=3},
      },
    },
    ["sea-sponge-sprouts-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="sea-sponge-sprouts-mk02", amount=3},
      },
      results = {
        {type="item", name="sea-sponge-sprouts", amount=4},
      },
    },
    ["seaweed-3"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=100},
        {type="fluid", name="slacked-lime", amount=50},
        {type="fluid", name="water-saline", amount=100},
        {type="item", name="fertilizer", amount=1},
      },
      results = {
        {type="item", name="seaweed", amount=30},
      },
    },
    ["seaweed-mk03"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="tailings", amount=75},
        {type="fluid", name="water-saline", amount=200},
        {type="item", name="ethylene-canister", amount=13},
        {type="item", name="powdered-biomass", amount=20},
        {type="item", name="workers-food", amount=12},
      },
      results = {
        {type="item", name="seaweed-mk03", amount=1},
      },
    },
    ["tuuphra-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="manure-bacteria", amount=50},
        {type="fluid", name="water", amount=100},
        {type="item", name="coal-dust", amount=3},
        {type="item", name="ground-sample01", amount=16},
        {type="item", name="limestone", amount=1},
        {type="item", name="ralesia", amount=4},
        {type="item", name="ralesia-seeds", amount=19},
        {type="item", name="sand", amount=11},
      },
      results = {
        {type="item", name="tuuphra", amount=8},
      },
    },
    ["tuuphra-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=300},
        {type="fluid", name="steam", amount=333},
        {type="item", name="coke", amount=75},
        {type="item", name="manure", amount=15},
        {type="item", name="soil", amount=100},
        {type="item", name="tuuphra", amount=2},
        {type="item", name="tuuphra-seeds", amount=10},
      },
      results = {
        {type="item", name="tuuphra", amount=1},
        {type="item", name="tuuphra-mk02", amount=0.005},
      },
    },
    ["tuuphra-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.09090909090909,
      ingredients = {
        {type="fluid", name="manure-bacteria", amount=381},
        {type="fluid", name="propene", amount=1372},
        {type="item", name="cellulose", amount=1},
        {type="item", name="nichrome", amount=2},
        {type="item", name="tuuphra", amount=6},
        {type="item", name="tuuphra-mk02", amount=1},
      },
      results = {
        {type="item", name="tuuphra-mk02", amount=7},
      },
    },
    ["xenogenic-from-bonemeal"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.12941176470588,
      ingredients = {
        {type="fluid", name="steam", amount=479},
        {type="item", name="brain", amount=1},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=96},
      },
    },
    ["xenogenic-from-bones"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=638},
        {type="item", name="brain", amount=2},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=45},
      },
    },
    ["xenogenic-from-brains"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=638},
        {type="item", name="brain", amount=5},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=20},
      },
    },
    ["xenogenic-from-chitin"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.01428571428571,
      ingredients = {
        {type="fluid", name="oxygen", amount=51},
        {type="item", name="brain", amount=8},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=71},
      },
    },
    ["xenogenic-from-fat"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.05,
      ingredients = {
        {type="fluid", name="oxygen", amount=80},
        {type="item", name="guts", amount=4},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=21},
      },
    },
    ["xenogenic-from-guts"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="fluid", name="water", amount=762},
        {type="item", name="brain", amount=2},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=48},
      },
    },
    ["xenogenic-from-skin"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=638},
        {type="item", name="meat", amount=17},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=60},
      },
    },
    ["xenogenic-from-meat"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 0.933333333333333,
      ingredients = {
        {type="fluid", name="oxygen", amount=46},
        {type="item", name="guts", amount=2},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=28},
      },
    },
    ["Moss-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=100},
        {type="fluid", name="water", amount=550},
        {type="item", name="rich-clay", amount=6},
        {type="item", name="stone", amount=20},
      },
      results = {
        {type="item", name="moss", amount=24},
      },
    },
    ["moss-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.56313563841647,
      ingredients = {
        {type="fluid", name="hydrogen", amount=270},
        {type="item", name="chromium", amount=2},
        {type="item", name="methanol-gas-canister", amount=1},
        {type="item", name="moondrop", amount=1},
        {type="item", name="native-flora", amount=20},
      },
      results = {
        {type="item", name="moss-mk02", amount=0.0312627127683295},
      },
    },
    ["moss-mk02r"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=11699},
        {type="fluid", name="oxygen", amount=1241},
        {type="item", name="calcium-carbide", amount=10},
        {type="item", name="clay-pit-mk01", amount=6},
        {type="item", name="moss-mk02", amount=3},
        {type="item", name="plasmids", amount=1},
        {type="item", name="urea", amount=124},
      },
      results = {
        {type="item", name="moss-mk02", amount=7},
      },
    },
    ["biomass-molten-salt-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=50870},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=400},
      },
    },
    ["coal-molten-salt-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="trichlorosilane", amount=1225},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=500},
      },
    },
    ["fatty-acids-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=489},
        {type="fluid", name="organic-solvent", amount=70},
        {type="item", name="salt", amount=149},
      },
      results = {
        {type="fluid", name="fatty-acids", amount=50},
      },
    },
    ["oleochemicals-to-fatty-acids"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oleochemicals", amount=100},
      },
      results = {
        {type="fluid", name="fatty-acids", amount=50},
      },
    },
    ["perylene"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="benzene", amount=150},
        {type="fluid", name="tar", amount=100},
        {type="item", name="navens", amount=5},
        {type="item", name="pipe", amount=2},
        {type="item", name="pyrite", amount=9},
      },
      results = {
        {type="fluid", name="perylene", amount=50},
      },
    },
    ["geo-he-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=485},
        {type="fluid", name="water", amount=131},
      },
      results = {
        {type="fluid", name="pressured-steam", amount=75},
      },
    },
    ["oil-molten-salt-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="crude-oil", amount=1531},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=500},
      },
    },
    ["organic-acid-anhydride"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="fatty-acids", amount=100},
        {type="fluid", name="geothermal-water", amount=100},
        {type="fluid", name="methanal", amount=1677},
        {type="item", name="pyrite", amount=9},
      },
      results = {
        {type="fluid", name="organic-acid-anhydride", amount=100},
      },
    },
    ["processed-fatty-acids"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="fatty-acids", amount=50},
        {type="fluid", name="flue-gas", amount=1959},
      },
      results = {
        {type="fluid", name="processed-fatty-acids", amount=50},
      },
    },
    ["middle-processed-lard"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=233},
        {type="item", name="bones", amount=3},
        {type="item", name="calcium-carbide", amount=3},
      },
      results = {
        {type="fluid", name="middle-processed-lard", amount=20},
        {type="fluid", name="steam", amount=500},
        {type="fluid", name="tar", amount=50},
      },
    },
    ["he-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=75},
        {type="fluid", name="water-saline", amount=2581},
      },
      results = {
        {type="fluid", name="molten-salt", amount=100},
        {type="fluid", name="pressured-steam", amount=75},
      },
    },
    ["pure-trichlorosilane"] = {
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="middle-processed-lard", amount=20},
        {type="item", name="brain", amount=25},
      },
      results = {
        {type="fluid", name="fatty-acids", amount=50},
      },
    },
    ["fatty-acids"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="industrial-solvent", amount=50},
        {type="fluid", name="middle-processed-lard", amount=50},
        {type="item", name="chromite-sand", amount=5},
      },
      results = {
        {type="fluid", name="fatty-acids", amount=70},
      },
    },
    ["carbon-sulfide"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="propene", amount=30},
        {type="item", name="coal", amount=5},
        {type="item", name="sulfur", amount=10},
      },
      results = {
        {type="fluid", name="carbon-sulfide", amount=60},
      },
    },
    ["ech"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=2604},
        {type="fluid", name="oleochemicals", amount=10},
        {type="fluid", name="tailings", amount=573},
      },
      results = {
        {type="fluid", name="ech", amount=30},
      },
    },
    ["etching"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ethylene", amount=734},
        {type="fluid", name="hydrogen-peroxide", amount=50},
        {type="fluid", name="sulfuric-acid", amount=100},
        {type="item", name="bones", amount=6},
      },
      results = {
        {type="fluid", name="etching", amount=150},
      },
    },
    ["ethylene"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=395},
        {type="fluid", name="pressured-air", amount=200},
        {type="item", name="iron-oxide", amount=2},
      },
      results = {
        {type="fluid", name="ethylene", amount=60},
        {type="fluid", name="water", amount=50},
      },
    },
    ["guts-to-acetic-acid"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="guts", amount=20},
      },
      results = {
        {type="fluid", name="acetic-acid", amount=60},
      },
    },
    ["meat-to-cyanic"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="meat", amount=10},
      },
      results = {
        {type="fluid", name="cyanic-acid", amount=50},
      },
    },
    ["methane-methanal"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="methane", amount=30},
        {type="fluid", name="steam", amount=212},
        {type="item", name="molybdenite-dust", amount=2},
      },
      results = {
        {type="fluid", name="methanal", amount=100},
      },
    },
    ["nitrobenzene"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ammonia", amount=30},
        {type="fluid", name="benzene", amount=50},
        {type="fluid", name="sulfuric-acid", amount=100},
      },
      results = {
        {type="fluid", name="nitrobenzene", amount=100},
      },
    },
    ["propene-to-acetone"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-air", amount=100},
        {type="fluid", name="propene", amount=50},
        {type="item", name="copper-plate", amount=2},
        {type="item", name="gravel", amount=3},
      },
      results = {
        {type="fluid", name="acetone", amount=50},
      },
    },
    ["ethylene-from-fruit"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="yotoi-fruit", amount=10},
      },
      results = {
        {type="fluid", name="ethylene", amount=50},
      },
    },
    ["fuelrod-mk01-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="molybdenum-sulfide", amount=78},
        {type="item", name="phenol", amount=8},
        {type="item", name="plutonium-oxide", amount=1},
      },
      results = {
        {type="item", name="fuelrod-mk01", amount=2},
      },
    },
    ["grade-1-u"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 5,
      ingredients = {
        {type="item", name="uranium-ore", amount=24},
      },
      results = {
        {type="item", name="grade-1-u", amount=5},
        {type="item", name="grade-2-u", amount=1},
        {type="item", name="stone", amount=5},
      },
    },
    ["grade-2-u-crush"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="grade-1-u", amount=2},
      },
      results = {
        {type="item", name="powdered-u", amount=2},
        {type="item", name="sand", amount=1},
      },
    },
    ["u-pulp-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=514},
        {type="fluid", name="sulfuric-acid", amount=50},
        {type="item", name="grade-2-u", amount=13},
      },
      results = {
        {type="fluid", name="u-pulp-01", amount=100},
      },
    },
    ["grade-1-u-recrush"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=141},
        {type="fluid", name="u-pulp-01", amount=150},
      },
      results = {
        {type="fluid", name="u-pulp-02", amount=100},
      },
    },
    ["u-pulp-03"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="naphtha", amount=1091},
        {type="fluid", name="sulfuric-acid", amount=100},
      },
      results = {
        {type="fluid", name="u-pulp-03", amount=100},
      },
    },
    ["u-rich-pulp"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=343},
        {type="fluid", name="u-pulp-03", amount=150},
        {type="item", name="grade-1-iron", amount=4},
      },
      results = {
        {type="item", name="yellow-cake", amount=5},
      },
    },
    ["cladded-core"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aramid", amount=1},
        {type="item", name="glass-core", amount=1},
        {type="item", name="ppd", amount=2},
      },
      results = {
        {type="item", name="cladded-core", amount=1},
      },
    },
    ["cladding"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="niobium-complex", amount=59},
        {type="fluid", name="nitrobenzene", amount=49},
        {type="item", name="sic", amount=1},
      },
      results = {
        {type="item", name="cladding", amount=1},
      },
    },
    ["copper-coating"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water-saline", amount=100},
        {type="item", name="cladded-core", amount=1},
        {type="item", name="copper-low-dust", amount=1},
      },
      results = {
        {type="item", name="copper-coating", amount=2},
      },
    },
    ["filtration-media-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="chromium", amount=7},
        {type="item", name="stone", amount=44},
        {type="item", name="ticl4", amount=4},
        {type="item", name="wood", amount=42},
      },
      results = {
        {type="item", name="filtration-media", amount=3},
      },
    },
    ["iron-oxide"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="nitrobenzene", amount=50},
        {type="item", name="pipe", amount=3},
      },
      results = {
        {type="item", name="iron-oxide", amount=10},
      },
    },
    ["kevlar"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="syngas", amount=1039},
        {type="fluid", name="tpa", amount=51},
        {type="item", name="cladding", amount=3},
        {type="item", name="nylon-parts", amount=24},
      },
      results = {
        {type="item", name="kevlar", amount=5},
      },
    },
    ["kevlar-coating"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="cladded-core", amount=1},
        {type="item", name="kevlar", amount=2},
      },
      results = {
        {type="item", name="kevlar-coating", amount=2},
      },
    },
    ["lab-instrument-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="item", name="electronic-circuit", amount=1},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="equipment-chassi", amount=2},
        {type="item", name="lens", amount=4},
        {type="item", name="pipe", amount=18},
        {type="item", name="rubber", amount=12},
      },
      results = {
        {type="item", name="lab-instrument", amount=5},
      },
    },
    ["optical-fiber"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="nbfe-coating", amount=1},
        {type="item", name="photophore", amount=1},
        {type="item", name="plastic-bar", amount=5},
      },
      results = {
        {type="item", name="optical-fiber", amount=3},
      },
    },
    ["slacked-lime"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=200},
        {type="item", name="calcium-carbide", amount=10},
      },
      results = {
        {type="fluid", name="slacked-lime", amount=50},
      },
    },
    ["ppd"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen-chloride", amount=523},
        {type="fluid", name="nitrobenzene", amount=50},
        {type="fluid", name="tall-oil", amount=1430},
      },
      results = {
        {type="item", name="ppd", amount=10},
      },
    },
    ["lime-from-shell"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="copper-coating", amount=3},
        {type="item", name="nbfe-alloy", amount=2},
      },
      results = {
        {type="item", name="nbfe-coating", amount=2},
      },
    },
    ["py-sodium-hydroxide"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="slacked-lime", amount=50},
        {type="item", name="salt", amount=10},
      },
      results = {
        {type="item", name="limestone", amount=5},
        {type="item", name="sodium-hydroxide", amount=10},
      },
    },
    ["sodium-bisulfate"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=100},
        {type="item", name="salt", amount=10},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=30},
        {type="item", name="sodium-bisulfate", amount=1},
      },
    },
    ["starch-4"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="fiberboard", amount=1},
        {type="item", name="guar", amount=29},
        {type="item", name="sodium-bisulfate", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
        {type="item", name="starch", amount=10},
      },
    },
    ["aramid"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=100},
        {type="fluid", name="tpa", amount=50},
        {type="item", name="aluminium-plate", amount=3},
        {type="item", name="molybdenum-sulfide", amount=17},
        {type="item", name="salt", amount=24},
        {type="item", name="titanium-plate", amount=15},
      },
      results = {
        {type="item", name="aramid", amount=8},
      },
    },
    ["sodium-sulfate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ore-nickel", amount=4},
        {type="item", name="sodium-bisulfate", amount=1},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=40},
        {type="item", name="sodium-sulfate", amount=1},
      },
    },
    ["starch-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 3.69947404769634,
      ingredients = {
        {type="item", name="fiberboard", amount=4},
        {type="item", name="powdered-ralesia-seeds", amount=4},
        {type="item", name="sodium-bisulfate", amount=3},
      },
      results = {
        {type="item", name="biomass", amount=18},
        {type="item", name="starch", amount=37},
      },
    },
    ["casein-melamine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="coal-gas", amount=326},
        {type="item", name="casein", amount=5},
      },
      results = {
        {type="item", name="melamine", amount=10},
      },
    },
    ["fecr-alloy"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="chromium", amount=1},
        {type="item", name="coke", amount=11},
        {type="item", name="pipe", amount=3},
      },
      results = {
        {type="item", name="fecr-alloy", amount=2},
      },
    },
    ["phenol-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=2901},
        {type="item", name="fine-powdered-biomass", amount=1175},
      },
      results = {
        {type="item", name="phenol", amount=6},
      },
    },
    ["silicon"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="chromium", amount=5},
        {type="item", name="coal-dust", amount=20},
      },
      results = {
        {type="item", name="silicon", amount=10},
      },
    },
    ["sodium-silicate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="fluid", name="refsyngas", amount=425},
        {type="item", name="coke", amount=86},
        {type="item", name="sodium-sulfate", amount=2},
      },
      results = {
        {type="item", name="sodium-silicate", amount=3},
      },
    },
    ["bisphenol-a"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="acetone", amount=20},
        {type="fluid", name="oxygen", amount=301},
        {type="item", name="crude-cermet", amount=17},
      },
      results = {
        {type="item", name="bisphenol-a", amount=3},
      },
    },
    ["melamine-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="methanal", amount=40},
        {type="item", name="bisphenol-a", amount=2},
      },
      results = {
        {type="item", name="melamine", amount=20},
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="phenol", amount=14},
      },
      results = {
        {type="item", name="silica-powder", amount=10},
      },
    },
    ["bakelite"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="methanal", amount=20},
        {type="item", name="cellulose", amount=10},
        {type="item", name="powdered-biomass", amount=14},
        {type="item", name="zinc-chloride", amount=5},
      },
      results = {
        {type="item", name="bakelite", amount=5},
      },
    },
    ["epoxy"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ech", amount=30},
        {type="item", name="bakelite", amount=6},
        {type="item", name="chromium", amount=2},
        {type="item", name="iron-plate", amount=1},
      },
      results = {
        {type="item", name="epoxy", amount=4},
      },
    },
    ["nylon2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ammonia", amount=100},
        {type="fluid", name="benzene", amount=100},
        {type="fluid", name="chlorine", amount=50},
        {type="item", name="chromium", amount=32},
      },
      results = {
        {type="item", name="nylon", amount=6},
      },
    },
    ["blood-meal"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="blood", amount=100},
        {type="item", name="fiberboard", amount=1},
      },
      results = {
        {type="item", name="blood-meal", amount=1},
      },
    },
    ["nylon-parts"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="item", name="cermet", amount=2},
      },
      results = {
        {type="item", name="nylon-parts", amount=6},
      },
    },
    ["nylon"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=307},
        {type="fluid", name="water", amount=920},
        {type="item", name="albumin", amount=4},
        {type="item", name="bisphenol-a", amount=1},
        {type="item", name="chromium", amount=1},
      },
      results = {
        {type="item", name="nylon", amount=5},
      },
    },
    ["boric-acid-hcl"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="boric-acid", amount=300},
        {type="item", name="sodium-hydroxide", amount=4},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=75},
        {type="fluid", name="tailings", amount=200},
      },
    },
    ["manure-to-nitrogen"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="manure", amount=8},
      },
      results = {
        {type="fluid", name="nitrogen", amount=50},
      },
    },
    ["mibc"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pitch", amount=420},
        {type="fluid", name="pressured-air", amount=4151},
        {type="item", name="copper-ore", amount=17},
      },
      results = {
        {type="fluid", name="mibc", amount=200},
      },
    },
    ["trichlorosilane"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water-saline", amount=281},
        {type="item", name="silicon", amount=5},
      },
      results = {
        {type="fluid", name="hydrogen", amount=100},
        {type="fluid", name="trichlorosilane", amount=50},
      },
    },
    ["eg-si"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=100},
        {type="fluid", name="pure-trichlorosilane", amount=50},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=100},
        {type="item", name="eg-si", amount=2},
      },
    },
    ["grade-4-ti"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-1-ti", amount=6},
      },
      results = {
        {type="item", name="grade-4-ti", amount=1},
      },
    },
    ["concentrated-ti"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1.00245346728754,
      ingredients = {
        {type="item", name="high-grade-ti-powder", amount=1},
      },
      results = {
        {type="item", name="concentrated-ti", amount=1},
        {type="item", name="iron-oxide", amount=1},
        {type="item", name="nexelit-ore", amount=1},
      },
    },
    ["high-grade-ti-powder"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="molten-titanium", amount=100},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="titanium-plate", amount=25},
      },
    },
    ["molten-titanium-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="heavy-oil", amount=100},
        {type="item", name="powdered-ti", amount=2},
        {type="item", name="sand", amount=4},
      },
      results = {
        {type="fluid", name="molten-titanium", amount=40},
      },
    },
    ["molten-titanium-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="heavy-oil", amount=100},
        {type="item", name="high-grade-ti-powder", amount=1},
        {type="item", name="lime", amount=1},
      },
      results = {
        {type="fluid", name="molten-titanium", amount=510},
      },
    },
    ["powdered-ti"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="mibc", amount=100},
        {type="fluid", name="water", amount=100},
        {type="item", name="grade-4-ti", amount=2},
      },
      results = {
        {type="fluid", name="tailings", amount=40},
        {type="fluid", name="ti-pulp-03", amount=60},
        {type="item", name="powdered-ti", amount=2},
      },
    },
    ["titanium-plate-3"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="molten-titanium", amount=100},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="titanium-plate", amount=20},
      },
    },
    ["titanium-plate-4"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-3-ti", amount=58},
      },
      results = {
        {type="item", name="titanium-plate", amount=147},
      },
    },
    ["purified-ti-pulp"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=150},
        {type="fluid", name="ti-pulp-03", amount=100},
      },
      results = {
        {type="fluid", name="purified-ti-pulp", amount=50},
        {type="fluid", name="ti-overflow-waste", amount=25},
      },
    },
    ["ti-enriched-dust"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.16,
      ingredients = {
        {type="fluid", name="molten-steel", amount=115},
        {type="item", name="cobalt-fluoride", amount=1},
        {type="item", name="copper-rejects", amount=1},
        {type="item", name="fecr-alloy", amount=6},
        {type="item", name="limestone", amount=1},
        {type="item", name="nickel-plate", amount=6},
        {type="item", name="niobium-pipe", amount=4},
        {type="item", name="phosphate-rock", amount=5},
      },
      results = {
        {type="fluid", name="molten-stainless-steel", amount=58},
      },
    },
    ["hotair-stainless-steel"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="molten-stainless-steel", amount=100},
        {type="item", name="sand", amount=12},
        {type="item", name="sodium-bisulfate", amount=2},
      },
      results = {
        {type="item", name="stainless-steel", amount=13},
      },
    },
    ["stainless-steel"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="molten-stainless-steel", amount=100},
        {type="item", name="aramid", amount=1},
        {type="item", name="sand-casting", amount=2},
      },
      results = {
        {type="item", name="stainless-steel", amount=10},
      },
    },
    ["guar-gum"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="guar", amount=44},
        {type="item", name="melamine", amount=2},
      },
      results = {
        {type="item", name="guar-gum", amount=3},
      },
    },
    ["long-handed-inserter-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="lubricant", amount=200},
        {type="item", name="al-pulp-02-barrel", amount=2},
        {type="item", name="bitumen-canister", amount=4},
        {type="item", name="fiber", amount=35},
        {type="item", name="grade-3-copper", amount=9},
        {type="item", name="molten-stainless-steel-barrel", amount=3},
        {type="item", name="rail", amount=9},
      },
      results = {
        {type="item", name="long-handed-inserter", amount=15},
      },
    },
    ["small-parts-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="belt", amount=2},
        {type="item", name="chromium", amount=1},
        {type="item", name="coke", amount=6},
        {type="item", name="duralumin", amount=1},
        {type="item", name="glass", amount=1},
        {type="item", name="nylon-parts", amount=5},
        {type="item", name="pipe", amount=3},
        {type="item", name="sncr-alloy", amount=1},
        {type="item", name="stainless-steel", amount=1},
        {type="item", name="tin-plate", amount=1},
        {type="item", name="titanium-plate", amount=2},
      },
      results = {
        {type="item", name="small-parts-02", amount=3},
      },
    },
    ["fast-inserter-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.73333333333333,
      ingredients = {
        {type="fluid", name="lubricant", amount=341},
        {type="item", name="blade-mk02", amount=2},
        {type="item", name="long-handed-inserter", amount=17},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="nexelit-plate", amount=368},
        {type="item", name="niobium-plate", amount=74},
        {type="item", name="shaft-mk01", amount=7},
        {type="item", name="ticl4", amount=21},
      },
      results = {
        {type="item", name="fast-inserter", amount=26},
      },
    },
    ["fast-transport-belt-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="duralumin", amount=45},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="kerogen", amount=288},
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="fast-transport-belt", amount=15},
      },
    },
    ["rotor"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=10},
        {type="item", name="melamine", amount=7},
        {type="item", name="nexelit-plate", amount=63},
      },
      results = {
        {type="item", name="stator", amount=1},
      },
    },
    ["electric-engine-unit"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="lubricant", amount=50},
        {type="item", name="electronic-circuit", amount=3},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="glass", amount=12},
        {type="item", name="iron-stick", amount=26},
        {type="item", name="rotor", amount=1},
        {type="item", name="stator", amount=1},
      },
      results = {
        {type="item", name="electric-engine-unit", amount=3},
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="engine-unit", amount=5},
        {type="item", name="iron-plate", amount=14},
        {type="item", name="lab", amount=2},
        {type="item", name="phenol", amount=153},
      },
      results = {
        {type="item", name="anemometer-mk02", amount=1},
      },
    },
    ["blade-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="micro-fiber", amount=34},
        {type="item", name="pipe", amount=17},
        {type="item", name="small-parts-01", amount=75},
      },
      results = {
        {type="item", name="blade-mk02", amount=1},
      },
    },
    ["brake-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bisphenol-a", amount=10},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="gearbox-mk01", amount=1},
        {type="item", name="melamine-resin", amount=10},
        {type="item", name="sodium-bisulfate", amount=33},
        {type="item", name="stainless-steel", amount=10},
        {type="item", name="wood", amount=209},
      },
      results = {
        {type="item", name="brake-mk02", amount=1},
      },
    },
    ["controler-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="bisphenol-a", amount=46},
        {type="item", name="blade-mk02", amount=2},
        {type="item", name="chromium", amount=628},
        {type="item", name="electronics-mk02", amount=2},
        {type="item", name="engine-unit", amount=9},
        {type="item", name="iron-plate", amount=82},
        {type="item", name="seaweed", amount=456},
        {type="item", name="used-nexelit-battery", amount=15},
      },
      results = {
        {type="item", name="controler-mk02", amount=3},
      },
    },
    ["electronics-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=3},
        {type="item", name="melamine", amount=424},
        {type="item", name="microchip", amount=4},
        {type="item", name="pcb2", amount=2},
        {type="item", name="resistor2", amount=15},
        {type="item", name="sic", amount=1},
        {type="item", name="silver-plate", amount=1},
        {type="item", name="titanium-plate", amount=11},
        {type="item", name="transistor", amount=47},
        {type="item", name="zinc-acetate", amount=7},
      },
      results = {
        {type="item", name="electronics-mk02", amount=3},
      },
    },
    ["gearbox-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=25713},
        {type="item", name="aluminium-plate", amount=15},
        {type="item", name="engine-unit", amount=24},
        {type="item", name="nbfe-alloy", amount=3},
        {type="item", name="rubber", amount=5},
        {type="item", name="sb-oxide", amount=29},
        {type="item", name="shaft-mk01", amount=2},
        {type="item", name="shaft-mk02", amount=5},
        {type="item", name="titanium-plate", amount=25},
      },
      results = {
        {type="item", name="gearbox-mk02", amount=1},
      },
    },
    ["hotair-shaft-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="molten-stainless-steel", amount=100},
        {type="item", name="anemometer-mk01", amount=2},
        {type="item", name="sand", amount=12},
      },
      results = {
        {type="item", name="shaft-mk02", amount=2},
      },
    },
    ["hotair-vane-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=1050},
        {type="item", name="empty-fuel-canister", amount=1},
        {type="item", name="kevlar", amount=20},
      },
      results = {
        {type="item", name="vane-mk02", amount=2},
      },
    },
    ["shaft-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="molten-steel", amount=417},
        {type="item", name="anemometer-mk01", amount=2},
        {type="item", name="sand-casting", amount=2},
      },
      results = {
        {type="item", name="shaft-mk02", amount=1},
      },
    },
    ["utility-box-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="bisphenol-a", amount=90},
        {type="item", name="electronics-mk02", amount=2},
        {type="item", name="engine-unit", amount=9},
        {type="item", name="shaft-mk02", amount=3},
        {type="item", name="sic", amount=8},
        {type="item", name="utility-box-mk01", amount=3},
      },
      results = {
        {type="item", name="utility-box-mk02", amount=3},
      },
    },
    ["vane-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="gunpowder", amount=753},
        {type="item", name="limestone", amount=8},
      },
      results = {
        {type="item", name="vane-mk02", amount=1},
      },
    },
    ["nacelle-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="blade-mk02", amount=20},
        {type="item", name="brake-mk01", amount=16},
        {type="item", name="engine-unit", amount=4},
        {type="item", name="gearbox-mk01", amount=1},
        {type="item", name="mechanical-parts-01", amount=19},
        {type="item", name="nacelle-mk01", amount=1},
        {type="item", name="nickel-plate", amount=6146},
        {type="item", name="pbsb-alloy", amount=18},
        {type="item", name="shaft-mk01", amount=53},
        {type="item", name="utility-box-mk01", amount=9},
        {type="item", name="xyhiphoe-cub-mk02", amount=1},
      },
      results = {
        {type="item", name="nacelle-mk02", amount=2},
      },
    },
    ["rotor-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="belt", amount=20},
        {type="item", name="controler-mk01", amount=6},
        {type="item", name="glass", amount=12},
        {type="item", name="iron-plate", amount=30},
        {type="item", name="resorcinol", amount=57},
        {type="item", name="shaft-mk02", amount=3},
      },
      results = {
        {type="item", name="rotor-mk02", amount=1},
      },
    },
    ["tower-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="blade-mk01", amount=5},
        {type="item", name="eg-si", amount=114},
        {type="item", name="niobium-oxide", amount=243},
        {type="item", name="pipe", amount=461},
        {type="item", name="shaft-mk02", amount=4},
        {type="item", name="steel-plate", amount=70},
      },
      results = {
        {type="item", name="tower-mk02", amount=1},
      },
    },
    ["yaw-drive-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=112},
        {type="item", name="belt", amount=39},
        {type="item", name="duralumin", amount=133},
        {type="item", name="gearbox-mk01", amount=1},
        {type="item", name="glass", amount=584},
        {type="item", name="hydrogen-peroxide-barrel", amount=4},
        {type="item", name="nexelit-plate", amount=454},
        {type="item", name="niobium-dust", amount=515},
        {type="item", name="pipe", amount=362},
        {type="item", name="soil-extractor-mk01", amount=1},
      },
      results = {
        {type="item", name="yaw-drive-mk02", amount=1},
      },
    },
    ["efficiency-module"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="carbon-filter", amount=8},
        {type="item", name="electronics-mk02", amount=2},
        {type="item", name="navens-spore", amount=1141},
      },
      results = {
        {type="item", name="efficiency-module", amount=1},
      },
    },
    ["productivity-module"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anemometer-mk02", amount=4},
        {type="item", name="brake-mk02", amount=3},
        {type="item", name="ulric", amount=168},
      },
      results = {
        {type="item", name="productivity-module", amount=1},
      },
    },
    ["speed-module"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="gearbox-mk02", amount=1},
        {type="item", name="syngas-barrel", amount=1429},
        {type="item", name="tower-mk01", amount=14},
      },
      results = {
        {type="item", name="speed-module", amount=1},
      },
    },
    ["bhoddos-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="electronic-circuit", amount=20},
        {type="item", name="lead-plate", amount=2},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="tinned-cable", amount=20},
      },
      results = {
        {type="item", name="bhoddos-codex", amount=1},
      },
    },
    ["cadaveric-arum-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=118},
        {type="item", name="electronic-circuit", amount=50},
        {type="item", name="lead-plate", amount=2},
        {type="item", name="pipe", amount=34},
      },
      results = {
        {type="item", name="cadaveric-arum-codex", amount=1},
      },
    },
    ["navens-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="electronics-mk02", amount=11},
        {type="item", name="pipe", amount=3},
        {type="item", name="transport-belt", amount=17},
      },
      results = {
        {type="item", name="navens-codex", amount=1},
      },
    },
    ["rennea-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=118},
        {type="item", name="electronic-circuit", amount=30},
        {type="item", name="glass", amount=2},
        {type="item", name="pipe", amount=34},
      },
      results = {
        {type="item", name="rennea-codex", amount=1},
      },
    },
    ["grod-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=48},
        {type="item", name="glass", amount=2},
        {type="item", name="inductor1", amount=341},
        {type="item", name="transport-belt", amount=17},
      },
      results = {
        {type="item", name="grod-codex", amount=1},
      },
    },
    ["yotoi-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="inductor1", amount=341},
        {type="item", name="pipe", amount=34},
        {type="item", name="sic", amount=1},
      },
      results = {
        {type="item", name="yotoi-codex", amount=1},
      },
    },
    ["earth-jute-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bio-sample", amount=68},
        {type="item", name="py-science-pack-1", amount=151},
        {type="item", name="rennea-codex", amount=3},
      },
      results = {
        {type="item", name="earth-jute-sample", amount=2},
      },
    },
    ["earth-sunflower-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="alien-sample01", amount=43},
        {type="item", name="kicalk-codex", amount=1},
        {type="item", name="py-science-pack-1", amount=303},
      },
      results = {
        {type="item", name="earth-sunflower-sample", amount=2},
      },
    },
    ["earth-tropical-tree-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bio-sample", amount=36},
        {type="item", name="py-science-pack-2", amount=21},
        {type="item", name="ralesia-codex", amount=1},
      },
      results = {
        {type="item", name="earth-tropical-tree-sample", amount=1},
      },
    },
    ["cadaveric-arum-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=333},
        {type="item", name="aluminium-plate", amount=4},
        {type="item", name="cottongut-codex", amount=2},
        {type="item", name="cytostatics", amount=2},
        {type="item", name="earth-jute-sample", amount=1},
        {type="item", name="earth-sunflower-sample", amount=1},
        {type="item", name="primers", amount=12},
        {type="item", name="titanium-plate", amount=64},
      },
      results = {
        {type="item", name="cadaveric-arum", amount=2},
      },
    },
    ["cadaveric-arum-seeds"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="rennea", amount=3},
      },
      results = {
        {type="item", name="cadaveric-arum-seeds", amount=8},
      },
    },
    ["cadaveric-arum-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=233},
        {type="fluid", name="flue-gas", amount=863},
        {type="item", name="gravel", amount=2},
        {type="item", name="stone-wool", amount=1},
        {type="item", name="sulfur", amount=137},
      },
      results = {
        {type="item", name="cadaveric-arum", amount=4},
      },
    },
    ["cadaveric-acidgas-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.47013996108422,
      ingredients = {
        {type="item", name="rennea", amount=2},
      },
      results = {
        {type="fluid", name="acidgas", amount=139},
        {type="item", name="cadaveric-arum-seeds", amount=3},
      },
    },
    ["grod-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=1431},
        {type="item", name="bio-sample01", amount=14},
        {type="item", name="cytostatics", amount=6},
        {type="item", name="earth-potato-sample", amount=2},
        {type="item", name="korlex-codex", amount=13},
        {type="item", name="retrovirus", amount=4},
        {type="item", name="stone-wool", amount=4},
      },
      results = {
        {type="item", name="grod", amount=3},
      },
    },
    ["dried-grods"] = {
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 0.833333333333333,
      ingredients = {
        {type="fluid", name="hot-air", amount=21},
        {type="item", name="rennea", amount=1},
      },
      results = {
        {type="item", name="dried-grods", amount=5},
      },
    },
    ["grod-seeds"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=500},
        {type="item", name="coarse", amount=2},
        {type="item", name="grod-seeds", amount=5},
        {type="item", name="soil", amount=10},
        {type="item", name="urea", amount=10},
      },
      results = {
        {type="item", name="grod", amount=10},
      },
    },
    ["rennea-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=333},
        {type="item", name="alien-sample-02", amount=10},
        {type="item", name="cottongut", amount=3},
        {type="item", name="cytostatics", amount=6},
        {type="item", name="earth-potato-sample", amount=1},
        {type="item", name="empty-planter-box", amount=1},
        {type="item", name="grod-codex", amount=1},
        {type="item", name="plasmids", amount=2},
      },
      results = {
        {type="item", name="rennea", amount=2},
      },
    },
    ["rennea-seeds"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="yaedols", amount=10},
      },
      results = {
        {type="item", name="rennea-seeds", amount=7},
      },
    },
    ["rennea-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="manure-bacteria", amount=50},
        {type="fluid", name="water", amount=100},
        {type="item", name="fertilizer", amount=3},
        {type="item", name="lime", amount=2},
        {type="item", name="rennea-seeds", amount=4},
        {type="item", name="sand-casting", amount=6},
      },
      results = {
        {type="item", name="rennea", amount=4},
      },
    },
    ["bhoddos-to-ti"] = {
      mode = "input-preserved-unmodified",
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
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="blood", amount=100},
      },
      results = {
        {type="item", name="ore-zinc", amount=20},
      },
    },
    ["fish-oil-to-tin"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="coal-gas", amount=350},
      },
      results = {
        {type="item", name="ore-tin", amount=10},
      },
    },
    ["fish-to-tin"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="fish", amount=10},
      },
      results = {
        {type="item", name="ore-tin", amount=25},
      },
    },
    ["grod-to-zinc"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grod", amount=5},
      },
      results = {
        {type="item", name="ore-zinc", amount=5},
      },
    },
    ["meat-to-chromium"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="item", name="brain", amount=1},
      },
      results = {
        {type="item", name="ore-chromium", amount=20},
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
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="tar", amount=196},
        {type="item", name="cadaveric-arum-seeds", amount=2},
      },
      results = {
        {type="fluid", name="waste-water", amount=50},
        {type="item", name="s-biomass", amount=10},
      },
    },
    ["cool-pressured-steam-3000-to-2000"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-steam", amount=200},
        {type="fluid", name="water", amount=193},
      },
      results = {
        {type="fluid", name="pressured-steam", amount=300},
      },
    },
    ["rennea-cu"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="tar", amount=196},
        {type="item", name="rennea-seeds", amount=5},
      },
      results = {
        {type="fluid", name="waste-water", amount=50},
        {type="item", name="cu-biomass", amount=10},
      },
    },
    ["tuuphra-nacl"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="tar", amount=196},
        {type="item", name="tuuphra", amount=1},
      },
      results = {
        {type="fluid", name="waste-water", amount=50},
        {type="item", name="nacl-biomass", amount=10},
      },
    },
    ["grod-sn"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="tar", amount=196},
        {type="item", name="grod-seeds", amount=2},
      },
      results = {
        {type="fluid", name="waste-water", amount=50},
        {type="item", name="sn-biomass", amount=10},
      },
    },
    ["navens-fe"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="tar", amount=196},
        {type="item", name="navens", amount=2},
      },
      results = {
        {type="fluid", name="waste-water", amount=50},
        {type="item", name="fe-biomass", amount=8},
      },
    },
    ["yotoi-fe"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="tar", amount=196},
        {type="item", name="yotoi", amount=1},
      },
      results = {
        {type="fluid", name="waste-water", amount=50},
        {type="item", name="fe-biomass", amount=15},
      },
    },
    ["moondrop-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=364},
        {type="fluid", name="water", amount=100},
        {type="item", name="coarse", amount=3},
        {type="item", name="fertilizer", amount=10},
        {type="item", name="fine-powdered-biomass", amount=2},
        {type="item", name="log", amount=1},
        {type="item", name="moondrop-seeds", amount=11},
      },
      results = {
        {type="item", name="moondrop", amount=16},
      },
    },
    ["moonshine-fueloil-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="methane", amount=100},
        {type="item", name="cu-biomass", amount=1},
        {type="item", name="moondrop", amount=4},
      },
      results = {
        {type="item", name="moondrop-fueloil", amount=15},
      },
    },
    ["ethylene-chlorohydrin"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="chlorine", amount=100},
        {type="fluid", name="ethylene", amount=50},
        {type="fluid", name="steam", amount=100},
        {type="item", name="silver-plate", amount=3},
      },
      results = {
        {type="fluid", name="ethylene-chlorohydrin", amount=100},
      },
    },
    ["moonshine-fueloil-pressing-1"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ethylene-chlorohydrin", amount=100},
        {type="fluid", name="flue-gas", amount=758},
        {type="fluid", name="steam", amount=100},
      },
      results = {
        {type="fluid", name="chloroethanol", amount=100},
      },
    },
    ["ethylene-glycol"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="residual-mixture", amount=2873},
        {type="fluid", name="slacked-lime", amount=20},
        {type="fluid", name="water", amount=100},
        {type="item", name="lime", amount=2},
      },
      results = {
        {type="fluid", name="ethylene-glycol", amount=150},
      },
    },
    ["ferrite"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="chromium", amount=48},
        {type="item", name="pyrite", amount=9},
        {type="item", name="zinc-plate", amount=10},
      },
      results = {
        {type="item", name="ferrite", amount=4},
      },
    },
    ["lead-container"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="niobium-plate", amount=29},
        {type="item", name="nxsb-alloy", amount=2},
        {type="item", name="sodium-bisulfate", amount=5},
      },
      results = {
        {type="item", name="lead-container", amount=1},
      },
    },
    ["nexelit-matrix"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=265},
        {type="fluid", name="water", amount=189},
        {type="item", name="bakelite", amount=7},
        {type="item", name="lead-plate", amount=3},
      },
      results = {
        {type="item", name="nexelit-matrix", amount=4},
      },
    },
    ["nuclear-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="aromatics", amount=50},
        {type="fluid", name="industrial-solvent", amount=100},
        {type="fluid", name="vacuum", amount=516},
        {type="item", name="automation-science-pack", amount=1},
        {type="item", name="pu-241", amount=2},
      },
      results = {
        {type="item", name="nuclear-sample", amount=1},
      },
    },
    ["sodium-chlorate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=150},
        {type="item", name="seaweed", amount=7},
      },
      results = {
        {type="item", name="sodium-chlorate", amount=5},
      },
    },
    ["steam-heating"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=1000},
        {type="fluid", name="water", amount=100},
        {type="item", name="sodium-bisulfate", amount=21},
      },
      results = {
        {type="fluid", name="steam", amount=1000},
      },
    },
    ["tuuphra-to-mo"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ore-nickel", amount=115},
        {type="item", name="petri-dish", amount=118},
        {type="item", name="powdered-aluminium", amount=32},
        {type="item", name="vinyl-acetate-barrel", amount=1},
      },
      results = {
        {type="item", name="mox-fuel-cell", amount=2},
      },
    },
    ["crmoni"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="chromium", amount=8},
        {type="item", name="molybdenum-sulfide", amount=17},
        {type="item", name="nickel-plate", amount=10},
      },
      results = {
        {type="item", name="crmoni", amount=2},
      },
    },
    ["nbalti"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=5},
        {type="item", name="niobium-oxide", amount=2},
        {type="item", name="titanium-plate", amount=10},
      },
      results = {
        {type="item", name="nbalti", amount=2},
      },
    },
    ["ptcda"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="organic-acid-anhydride", amount=100},
        {type="fluid", name="perylene", amount=100},
        {type="item", name="filtration-media", amount=1},
        {type="item", name="plastic-bar", amount=1},
      },
      results = {
        {type="item", name="ptcda", amount=1},
      },
    },
    ["self-assembly-monolayer"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="chlorine", amount=285},
        {type="item", name="nbalti", amount=1},
        {type="item", name="pipe", amount=5},
        {type="item", name="ptcda", amount=1},
        {type="item", name="rayon", amount=3},
        {type="item", name="vitreloy", amount=2},
      },
      results = {
        {type="item", name="self-assembly-monolayer", amount=1},
      },
    },
    ["brain-cartridge-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=12066},
        {type="fluid", name="scrude", amount=50},
        {type="item", name="fenxsb-alloy", amount=1},
        {type="item", name="skin", amount=30},
      },
      results = {
        {type="item", name="brain-cartridge-01", amount=1},
      },
    },
    ["vat-brain"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="distilator", amount=3},
        {type="item", name="electronic-circuit", amount=31},
        {type="item", name="intermetallics", amount=27},
        {type="item", name="iron-ore-dust", amount=57},
        {type="item", name="neutron-absorber-mk01", amount=4},
        {type="item", name="nickel-plate", amount=77},
        {type="item", name="outlet-gas-01-barrel", amount=5},
        {type="item", name="shotgun-shell", amount=496},
        {type="item", name="stripped-distillate-barrel", amount=13},
      },
      results = {
        {type="item", name="vat-brain", amount=3},
      },
    },
    ["mk02-locomotive"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bitumen-froth-barrel", amount=61},
        {type="item", name="black-liquor-barrel", amount=63},
        {type="item", name="casting-unit-mk01", amount=1},
        {type="item", name="cocoon-mk03", amount=7},
        {type="item", name="eg-si", amount=360},
        {type="item", name="grade-2-chromite", amount=9},
        {type="item", name="grade-3-iron", amount=56},
        {type="item", name="hydrofluoric-acid-barrel", amount=7},
        {type="item", name="hydrogen-chloride-barrel", amount=27},
        {type="item", name="molten-solder-barrel", amount=15},
        {type="item", name="pipe", amount=269},
        {type="item", name="propene-canister", amount=44},
        {type="item", name="saps-mk03", amount=10},
        {type="item", name="tower-mk02", amount=1},
        {type="item", name="u-pulp-02-barrel", amount=35},
      },
      results = {
        {type="item", name="mk02-locomotive", amount=1},
      },
    },
    ["mk02-wagon"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="al-pulp-02-barrel", amount=2},
        {type="item", name="ash", amount=619},
        {type="item", name="benzene-canister", amount=102},
        {type="item", name="chromite-rejects", amount=495},
        {type="item", name="concentrated-ti", amount=13},
        {type="item", name="cottongut-mk01", amount=1},
        {type="item", name="crmoni", amount=8},
        {type="item", name="etching-barrel", amount=1},
        {type="item", name="graphite", amount=273},
        {type="item", name="kerogen", amount=271},
        {type="item", name="tin-dust", amount=56},
        {type="item", name="used-comb", amount=29},
        {type="item", name="utility-box-mk02", amount=1},
      },
      results = {
        {type="item", name="mk02-wagon", amount=2},
      },
    },
    ["mk02-fluid-wagon"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="chitin", amount=7},
        {type="item", name="clean-nexelit", amount=30},
        {type="item", name="cottongut-mk01", amount=2},
        {type="item", name="ethylene-barrel", amount=6},
        {type="item", name="ethylene-chlorohydrin-barrel", amount=13},
        {type="item", name="methanal-barrel", amount=31},
        {type="item", name="molten-steel-barrel", amount=3},
        {type="item", name="py-steel", amount=75},
        {type="item", name="residual-oil-barrel", amount=79},
        {type="item", name="rotor", amount=10},
        {type="item", name="small-parts-02", amount=13},
        {type="item", name="unslimed-iron", amount=12},
        {type="item", name="zogna-bacteria-barrel", amount=2},
      },
      results = {
        {type="item", name="mk02-fluid-wagon", amount=1},
      },
    },
    ["glycerol2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.14,
      ingredients = {
        {type="fluid", name="water", amount=1019},
        {type="item", name="brain", amount=3},
        {type="item", name="p2s5", amount=1},
      },
      results = {
        {type="fluid", name="glycerol", amount=57},
      },
    },
    ["oleochemicals-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="refsyngas", amount=100},
        {type="item", name="lead-plate", amount=2},
        {type="item", name="sugar", amount=11},
      },
      results = {
        {type="fluid", name="oleochemicals", amount=200},
      },
    },
    ["sea-sponge-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=40},
        {type="fluid", name="zogna-bacteria", amount=40},
        {type="item", name="sea-sponge-sprouts", amount=1},
      },
      results = {
        {type="fluid", name="water-saline", amount=50},
        {type="item", name="sea-sponge", amount=3},
      },
    },
    ["silicon-wafer"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aramid", amount=1},
        {type="item", name="coke", amount=11},
        {type="item", name="eg-si", amount=5},
        {type="item", name="powdered-quartz", amount=2},
      },
      results = {
        {type="fluid", name="flue-gas", amount=100},
        {type="item", name="silicon-wafer", amount=2},
      },
    },
    ["heat-exchanger"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="grade-2-lead", amount=3},
        {type="item", name="grade-4-ti", amount=4},
        {type="item", name="natural-gas-canister", amount=5},
      },
      results = {
        {type="item", name="heat-exchanger", amount=2},
      },
    },
    ["heat-pipe"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="acetylene-canister", amount=3},
        {type="item", name="py-tank-3000", amount=1},
      },
      results = {
        {type="item", name="heat-pipe", amount=1},
      },
    },
    ["nuclear-reactor"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="engine-unit", amount=3509},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="nexelit-plate", amount=685},
        {type="item", name="small-parts-02", amount=423},
      },
      results = {
        {type="item", name="nuclear-reactor", amount=1},
      },
    },
    ["steam-turbine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="condensates-canister", amount=5},
        {type="item", name="copper-rejects", amount=40},
        {type="item", name="shaft-mk02", amount=5},
        {type="item", name="transport-belt", amount=146},
      },
      results = {
        {type="item", name="steam-turbine", amount=2},
      },
    },
    ["zinc-acetate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=1959},
        {type="item", name="zinc-plate", amount=10},
      },
      results = {
        {type="item", name="zinc-acetate", amount=1},
      },
    },
    ["heavy-n"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="etching", amount=20},
        {type="fluid", name="sb-pulp-02", amount=200},
        {type="item", name="ree-concentrate", amount=41},
        {type="item", name="silicon-wafer", amount=5},
      },
      results = {
        {type="item", name="heavy-n", amount=10},
      },
    },
    ["light-n"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="etching", amount=20},
        {type="fluid", name="flue-gas", amount=6176},
        {type="item", name="silicon-wafer", amount=5},
      },
      results = {
        {type="item", name="light-n", amount=10},
      },
    },
    ["p-dope"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="etching", amount=20},
        {type="fluid", name="pressured-water", amount=453},
        {type="item", name="silicon-wafer", amount=5},
        {type="item", name="zinc-acetate", amount=2},
      },
      results = {
        {type="item", name="p-dope", amount=10},
      },
    },
    ["ammonium-chloride"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ammonia", amount=100},
        {type="fluid", name="carbon-dioxide", amount=200},
        {type="fluid", name="nitrogen", amount=200},
        {type="item", name="seaweed", amount=13},
      },
      results = {
        {type="item", name="ammonium-chloride", amount=2},
        {type="item", name="sodium-carbonate", amount=1},
      },
    },
    ["p2s5-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="phosphate-rock", amount=5},
        {type="item", name="sulfur", amount=5},
      },
      results = {
        {type="item", name="p2s5", amount=1},
        {type="item", name="pyrite", amount=2},
      },
    },
    ["uranium-fuel-cell"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boron-trioxide", amount=302},
        {type="item", name="lead-plate", amount=6},
        {type="item", name="sodium-bisulfate", amount=32},
      },
      results = {
        {type="item", name="uranium-fuel-cell", amount=1},
      },
    },
    ["fuel-cell-dissolve"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=116},
        {type="fluid", name="sulfuric-acid", amount=250},
        {type="item", name="guar-gum-plantation", amount=6},
        {type="item", name="salt", amount=36},
      },
      results = {
        {type="fluid", name="sb-phosphate-1", amount=100},
      },
    },
    ["plutonium-fuel-reprocessing"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cliff-explosives", amount=17},
      },
      results = {
        {type="item", name="plutonium-oxide", amount=14},
        {type="item", name="u-238", amount=10},
      },
    },
    ["antimony-phosphate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ethylene", amount=1835},
        {type="fluid", name="hot-molten-salt", amount=552},
        {type="item", name="nxsb-alloy", amount=1},
      },
      results = {
        {type="fluid", name="purex-concentrate-1", amount=100},
        {type="item", name="sb-hpo-pu", amount=10},
      },
    },
    ["plutonium-seperation"] = {
      mode = "input-preserved-unmodified",
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
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen-peroxide", amount=250},
        {type="item", name="sb-hpo-pu", amount=5},
      },
      results = {
        {type="fluid", name="plutonium-peroxide", amount=100},
        {type="fluid", name="sb-phosphate-2", amount=100},
      },
    },
    ["plutonium-shuffle-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="plutonium-peroxide", amount=66},
        {type="item", name="plutonium-oxide", amount=1},
        {type="item", name="pu-241", amount=1},
      },
      results = {
        {type="item", name="pu-238", amount=2},
        {type="item", name="pu-242", amount=2},
      },
    },
    ["plutonium-shuffle-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="plutonium-peroxide", amount=35},
        {type="item", name="cellulose", amount=67},
        {type="item", name="u-238", amount=2},
      },
      results = {
        {type="item", name="pu-240", amount=1},
        {type="item", name="pu-242", amount=1},
      },
    },
    ["plutonium-shuffle-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="plutonium-peroxide", amount=35},
        {type="item", name="pu-240", amount=1},
      },
      results = {
        {type="item", name="pu-239", amount=1},
        {type="item", name="pu-241", amount=1},
      },
    },
    ["plutonium-shuffle-4"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="plutonium-peroxide", amount=35},
        {type="item", name="plutonium-oxide", amount=2},
        {type="item", name="sb-hpo-pu", amount=1},
      },
      results = {
        {type="item", name="pu-239", amount=1},
        {type="item", name="pu-240", amount=1},
      },
    },
    ["rayon"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ammonia", amount=50},
        {type="fluid", name="carbon-sulfide", amount=50},
        {type="fluid", name="sulfuric-acid", amount=150},
        {type="item", name="ammonium-chloride", amount=5},
        {type="item", name="raw-fiber", amount=33},
        {type="item", name="urea", amount=10},
      },
      results = {
        {type="item", name="rayon", amount=5},
      },
    },
    ["battery-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=63},
        {type="item", name="glass", amount=3},
        {type="item", name="nxsb-alloy", amount=3},
        {type="item", name="phenol", amount=36},
      },
      results = {
        {type="item", name="battery-mk01", amount=4},
      },
    },
    ["battery-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=50},
        {type="item", name="calcium-carbide", amount=3},
        {type="item", name="p2s5", amount=3},
        {type="item", name="pbsb-alloy", amount=4},
        {type="item", name="rayon", amount=2},
      },
      results = {
        {type="item", name="battery-mk01", amount=4},
      },
    },
    ["nas-battery"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.16666666666667,
      ingredients = {
        {type="item", name="chromium", amount=1},
        {type="item", name="nxsb-alloy", amount=3},
        {type="item", name="rayon", amount=2},
        {type="item", name="salt", amount=168},
        {type="item", name="steel-plate", amount=1},
        {type="item", name="sulfur", amount=23},
      },
      results = {
        {type="item", name="battery-mk01", amount=7},
      },
    },
    ["nexelit-battery"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="anthraquinone", amount=20},
        {type="fluid", name="olefin", amount=50},
        {type="item", name="ferrite", amount=1},
        {type="item", name="nylon-parts", amount=9},
        {type="item", name="pipe", amount=5},
        {type="item", name="titanium-plate", amount=5},
      },
      results = {
        {type="item", name="used-nexelit-battery", amount=1},
      },
    },
    ["nexelit-battery-recharge"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="limestone", amount=9},
        {type="item", name="used-nexelit-battery", amount=1},
      },
      results = {
        {type="item", name="nexelit-battery", amount=1},
      },
    },
    ["casein-mixture-03"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="milk", amount=50},
        {type="fluid", name="sulfuric-acid", amount=100},
      },
      results = {
        {type="fluid", name="casein-mixture", amount=80},
        {type="fluid", name="waste-water", amount=50},
      },
    },
    ["fish-emulsion"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="subcritical-water", amount=1922},
        {type="fluid", name="water", amount=600},
      },
      results = {
        {type="fluid", name="fish-emulsion", amount=40},
        {type="fluid", name="fish-oil", amount=15},
        {type="item", name="fishmeal", amount=10},
      },
    },
    ["b-molasse"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="a-molasse", amount=50},
        {type="fluid", name="pressured-air", amount=188},
        {type="item", name="stone-wool", amount=2},
      },
      results = {
        {type="fluid", name="b-molasse", amount=100},
      },
    },
    ["ethanol"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="b-molasse", amount=50},
        {type="fluid", name="zogna-bacteria", amount=20},
        {type="item", name="fawogae-spore", amount=4},
      },
      results = {
        {type="fluid", name="ethanol", amount=100},
      },
    },
    ["syrup-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=333},
        {type="item", name="fine-powdered-biomass", amount=530},
        {type="item", name="manure", amount=9},
      },
      results = {
        {type="fluid", name="syrup-01", amount=50},
      },
    },
    ["fertilizer-5"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="zogna-bacteria", amount=10},
        {type="item", name="bones", amount=6},
        {type="item", name="powdered-biomass", amount=4},
        {type="item", name="sodium-bisulfate", amount=1},
        {type="item", name="urea", amount=10},
      },
      results = {
        {type="item", name="fertilizer", amount=15},
      },
    },
    ["fertilizer-fish-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="fish-emulsion", amount=100},
      },
      results = {
        {type="item", name="fertilizer", amount=3},
      },
    },
    ["fertilizer-fish-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cottongut-food-01", amount=14},
      },
      results = {
        {type="item", name="fertilizer", amount=2},
      },
    },
    ["split-yellowcake"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="yellow-cake", amount=10},
      },
      results = {
        {type="item", name="u-235", amount=1},
        {type="item", name="u-238", amount=9},
      },
    },
    ["plutonium"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ethanol", amount=50},
        {type="fluid", name="plutonium-peroxide", amount=100},
      },
      results = {
        {type="item", name="plutonium-oxide", amount=10},
      },
    },
    ["night-vision-equipment"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="btx-barrel", amount=1},
        {type="item", name="melamine", amount=12},
        {type="item", name="tin-dust", amount=18},
        {type="item", name="transport-belt", amount=15},
      },
      results = {
        {type="item", name="night-vision-equipment", amount=1},
      },
    },
    ["personal-roboport-mk2-equipment"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="animal-sample-01", amount=36},
        {type="item", name="bonemeal", amount=12},
        {type="item", name="moondrop-mk02", amount=11},
        {type="item", name="phosphoric-acid-barrel", amount=1},
        {type="item", name="portable-gasoline-generator", amount=4},
        {type="item", name="ulric-corral-mk01", amount=2},
      },
      results = {
        {type="item", name="personal-roboport-mk2-equipment", amount=1},
      },
    },
    ["belt-immunity-equipment"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="hot-syngas-canister", amount=39},
        {type="item", name="pressured-water-barrel", amount=40},
        {type="item", name="shotgun", amount=8},
      },
      results = {
        {type="item", name="belt-immunity-equipment", amount=1},
      },
    },
    ["bio-scafold"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="boric-acid", amount=200},
        {type="item", name="bonemeal", amount=5},
        {type="item", name="btx-canister", amount=1},
        {type="item", name="chitin", amount=20},
      },
      results = {
        {type="item", name="bio-scafold", amount=1},
      },
    },
    ["bone-fat"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2.5,
      ingredients = {
        {type="fluid", name="pressured-water", amount=837},
        {type="item", name="brain", amount=2},
      },
      results = {
        {type="item", name="mukmoux-fat", amount=5},
      },
    },
    ["print-bonemeal"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="psc", amount=40},
        {type="item", name="bio-scafold", amount=1},
      },
      results = {
        {type="item", name="bonemeal", amount=4},
      },
    },
    ["print-bones"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="psc", amount=40},
        {type="item", name="bio-scafold", amount=1},
      },
      results = {
        {type="item", name="bones", amount=3},
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
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="psc", amount=40},
        {type="item", name="bio-scafold", amount=1},
      },
      results = {
        {type="item", name="mukmoux-fat", amount=5},
      },
    },
    ["print-guts"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="psc", amount=40},
        {type="item", name="bio-scafold", amount=1},
      },
      results = {
        {type="item", name="guts", amount=6},
      },
    },
    ["print-meat"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="psc", amount=40},
        {type="item", name="bio-scafold", amount=1},
      },
      results = {
        {type="item", name="meat", amount=4},
      },
    },
    ["print-skin"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="psc", amount=40},
        {type="item", name="bio-scafold", amount=1},
      },
      results = {
        {type="item", name="skin", amount=5},
      },
    },
    ["cellulose-gasification"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=30},
        {type="fluid", name="pressured-air", amount=200},
        {type="item", name="powdered-biomass", amount=235},
      },
      results = {
        {type="fluid", name="syngas", amount=100},
      },
    },
    ["lignin-to-aromatics"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cellulose", amount=3},
      },
      results = {
        {type="fluid", name="aromatics", amount=150},
      },
    },
    ["tpa"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="aromatics", amount=100},
        {type="fluid", name="liquid-nitrogen", amount=50},
        {type="fluid", name="manure-bacteria", amount=20},
        {type="item", name="cobalt-extract", amount=2},
        {type="item", name="sodium-hydroxide", amount=5},
      },
      results = {
        {type="fluid", name="tpa", amount=50},
      },
    },
    ["oleo-gasification"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=152},
        {type="fluid", name="oleochemicals", amount=200},
        {type="fluid", name="syngas", amount=200},
      },
      results = {
        {type="fluid", name="aromatics", amount=200},
        {type="fluid", name="tar", amount=300},
      },
    },
    ["crucible"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="coke", amount=11},
        {type="item", name="quartz-tube", amount=4},
        {type="item", name="sodium-silicate", amount=1},
      },
      results = {
        {type="item", name="crucible", amount=3},
      },
    },
    ["eva"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ethylene", amount=50},
        {type="fluid", name="vinyl-acetate", amount=50},
      },
      results = {
        {type="item", name="eva", amount=5},
      },
    },
    ["mechanical-parts-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=3899},
        {type="item", name="aluminium-plate", amount=98},
        {type="item", name="electronics-mk02", amount=1},
        {type="item", name="fast-splitter", amount=2},
        {type="item", name="gearbox-mk01", amount=6},
        {type="item", name="neuroprocessor", amount=6},
        {type="item", name="nichrome", amount=4},
        {type="item", name="pressured-water-barrel", amount=14},
        {type="item", name="sb-oxide", amount=11},
        {type="item", name="shaft-mk01", amount=33},
        {type="item", name="small-parts-01", amount=193},
        {type="item", name="tower-mk01", amount=1},
        {type="item", name="utility-box-mk01", amount=10},
      },
      results = {
        {type="item", name="mechanical-parts-02", amount=6},
      },
    },
    ["sb-oxide-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="sb-pulp-02", amount=100},
        {type="fluid", name="steam", amount=212},
        {type="item", name="plastic-bar", amount=3},
      },
      results = {
        {type="item", name="sb-oxide", amount=3},
      },
    },
    ["sb-oxide-02a"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="sb-58-conc", amount=50},
        {type="fluid", name="steam", amount=425},
        {type="item", name="plastic-bar", amount=10},
      },
      results = {
        {type="item", name="sb-oxide", amount=10},
      },
    },
    ["lead-acetate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=979},
        {type="fluid", name="hydrogen-peroxide", amount=50},
        {type="item", name="lead-plate", amount=3},
      },
      results = {
        {type="item", name="lead-acetate", amount=1},
      },
    },
    ["dowfroth-250"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ethylene-glycol", amount=100},
        {type="fluid", name="methanol", amount=50},
        {type="item", name="chromium", amount=2},
      },
      results = {
        {type="fluid", name="dowfroth-250", amount=100},
      },
    },
    ["sb-crushed"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="calcium-carbide", amount=17},
        {type="item", name="sb-grade-03", amount=2},
      },
      results = {
        {type="item", name="sb-crushed", amount=3},
      },
    },
    ["sb-dust"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1.02501120665631,
      ingredients = {
        {type="item", name="sb-crushed", amount=2},
      },
      results = {
        {type="item", name="sb-dust", amount=1},
        {type="item", name="sb-grade-04", amount=1},
      },
    },
    ["sb-pulp-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="fish-oil", amount=25},
        {type="item", name="lead-acetate", amount=1},
        {type="item", name="sb-crushed", amount=4},
      },
      results = {
        {type="fluid", name="sb-pulp-01", amount=200},
      },
    },
    ["sb-pulp-02"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="dowfroth-250", amount=50},
        {type="fluid", name="pressured-air", amount=50},
        {type="fluid", name="sb-pulp-01", amount=100},
      },
      results = {
        {type="fluid", name="sb-58-conc", amount=10},
        {type="fluid", name="sb-pulp-02", amount=50},
      },
    },
    ["fast-splitter"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="advanced-circuit", amount=4},
        {type="item", name="chromite-sand", amount=9},
        {type="item", name="pcb2", amount=4},
        {type="item", name="pressured-hydrogen-barrel", amount=4},
        {type="item", name="sb-crushed", amount=8},
        {type="item", name="shaft-mk02", amount=1},
      },
      results = {
        {type="item", name="fast-splitter", amount=2},
      },
    },
    ["fast-transport-belt"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-air", amount=857},
        {type="item", name="aluminium-plate", amount=24},
        {type="item", name="lead-plate", amount=3},
        {type="item", name="niobium-plate", amount=3},
        {type="item", name="small-parts-02", amount=2},
      },
      results = {
        {type="item", name="fast-transport-belt", amount=2},
      },
    },
    ["fast-underground-belt"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="lubricant", amount=50},
        {type="item", name="chromite-sand", amount=5},
        {type="item", name="copper-rejects", amount=140},
        {type="item", name="mixed-ores", amount=57},
        {type="item", name="nacl-biomass", amount=89},
        {type="item", name="organic-solvent-barrel", amount=15},
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="fast-underground-belt", amount=2},
      },
    },
    ["neutron-absorber-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="carbon-dioxide-barrel", amount=364},
        {type="item", name="casein-mixture-barrel", amount=20},
        {type="item", name="electronics-mk01", amount=2},
        {type="item", name="grade-3-iron", amount=4},
        {type="item", name="gunpowder", amount=478},
        {type="item", name="mechanical-parts-01", amount=2},
        {type="item", name="medium-electric-pole", amount=8},
        {type="item", name="middle-oil-canister", amount=5},
        {type="item", name="rotor", amount=1},
        {type="item", name="sic", amount=13},
      },
      results = {
        {type="item", name="neutron-absorber-mk01", amount=1},
      },
    },
    ["py-biomass-powerplant-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="diesel-canister", amount=59},
        {type="item", name="grade-1-ti", amount=549},
        {type="item", name="latex", amount=308},
        {type="item", name="lubricant-barrel", amount=188},
        {type="item", name="mechanical-parts-01", amount=40},
        {type="item", name="middle-processed-lard-barrel", amount=238},
        {type="item", name="py-biomass-powerplant-mk01", amount=1},
        {type="item", name="rotor", amount=375},
        {type="item", name="sodium-chlorate", amount=179},
        {type="item", name="storage-tank", amount=1},
        {type="item", name="sugar", amount=201},
        {type="item", name="vinyl-acetate-barrel", amount=10},
      },
      results = {
        {type="item", name="py-biomass-powerplant-mk02", amount=1},
      },
    },
    ["py-coal-powerplant-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="efficiency-module", amount=1},
        {type="item", name="electronic-circuit", amount=1275},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="organic-acid-anhydride-barrel", amount=177},
        {type="item", name="ree-concentrate", amount=594},
        {type="item", name="ree-mining-drill-mk01", amount=23},
        {type="item", name="residual-oil-canister", amount=18},
        {type="item", name="small-parts-02", amount=100},
        {type="item", name="steam-engine", amount=43},
        {type="item", name="stone-brick", amount=119},
      },
      results = {
        {type="item", name="py-coal-powerplant-mk02", amount=1},
      },
    },
    ["py-oil-powerplant-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="hydrogen-chloride-barrel", amount=1817},
        {type="item", name="intermetallics", amount=176},
        {type="item", name="molten-zinc-barrel", amount=4},
        {type="item", name="p-dope", amount=25},
        {type="item", name="powdered-ralesia-seeds", amount=142},
        {type="item", name="py-coal-powerplant-mk01", amount=1},
        {type="item", name="ralesia-seeds-mk02", amount=105},
        {type="item", name="sb-dust", amount=53},
        {type="item", name="shaft-mk02", amount=6},
        {type="item", name="vawt-turbine-mk01", amount=5},
      },
      results = {
        {type="item", name="py-oil-powerplant-mk02", amount=1},
      },
    },
    ["tidal-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="belt-immunity-equipment", amount=7},
        {type="item", name="engine-unit", amount=83},
        {type="item", name="ethylene-glycol-barrel", amount=2},
        {type="item", name="flotation-cell-mk01", amount=7},
        {type="item", name="gasoline-canister", amount=12},
        {type="item", name="grade-1-chromite", amount=148},
        {type="item", name="grade-3-nickel", amount=212},
        {type="item", name="green-refined-concrete", amount=288},
        {type="item", name="primers", amount=9},
        {type="item", name="py-coal-powerplant-mk01", amount=1},
        {type="item", name="used-ulric-mk02", amount=21},
        {type="item", name="yaedols-spores-mk02", amount=186},
        {type="item", name="yotoi-codex", amount=9},
      },
      results = {
        {type="item", name="tidal-mk02", amount=1},
      },
    },
    ["vawt-turbine-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bitumen-barrel", amount=33},
        {type="item", name="blade-mk02", amount=8},
        {type="item", name="engine-unit", amount=90},
        {type="item", name="gold-plate", amount=88},
        {type="item", name="intermetallics", amount=176},
        {type="item", name="latex", amount=18},
        {type="item", name="neuroprocessor", amount=13},
        {type="item", name="nexelit-matrix", amount=129},
        {type="item", name="phenolicboard", amount=35},
        {type="item", name="processed-fatty-acids-barrel", amount=16},
        {type="item", name="rotor", amount=1},
        {type="item", name="yotoi-leaves", amount=349},
        {type="item", name="zipir-eggs", amount=395},
      },
      results = {
        {type="item", name="vawt-turbine-mk02", amount=1},
      },
    },
    ["hawt-turbine-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anemometer-mk02", amount=1},
        {type="item", name="blade-mk02", amount=5},
        {type="item", name="earth-sea-sponge-sample", amount=2},
        {type="item", name="gearbox-mk02", amount=1},
        {type="item", name="grade-3-iron", amount=2866},
        {type="item", name="medium-distillate-barrel", amount=28},
      },
      results = {
        {type="item", name="hawt-turbine-mk02", amount=1},
      },
    },
    ["steam-turbine-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bio-oil-canister", amount=130},
        {type="item", name="bio-scafold", amount=9},
        {type="item", name="black-liquor-barrel", amount=284},
        {type="item", name="cadaveric-arum-seeds", amount=80},
        {type="item", name="electronics-mk02", amount=10},
        {type="item", name="intermetallics", amount=878},
        {type="item", name="latex", amount=60},
        {type="item", name="light-oil-barrel", amount=1581},
        {type="item", name="moss", amount=213},
        {type="item", name="multiblade-turbine-mk01", amount=3},
        {type="item", name="pcb-factory-mk01", amount=7},
        {type="item", name="plutonium-peroxide-barrel", amount=25},
        {type="item", name="powdered-phosphate-rock", amount=1510},
        {type="item", name="residual-mixture-barrel", amount=6368},
        {type="item", name="xyhiphoe-codex", amount=20},
      },
      results = {
        {type="item", name="steam-turbine-mk02", amount=1},
      },
    },
    ["jig-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-food-01", amount=26},
        {type="item", name="coal-gas-canister", amount=42},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="grade-4-ti", amount=25},
        {type="item", name="kerosene-barrel", amount=30},
        {type="item", name="korlex", amount=7},
        {type="item", name="niobium-ore", amount=150},
        {type="item", name="ore-aluminium", amount=229},
        {type="item", name="stripped-distillate-barrel", amount=3},
      },
      results = {
        {type="item", name="jig-mk01", amount=1},
      },
    },
    ["nmf-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="brake-mk01", amount=2},
        {type="item", name="duralumin", amount=15},
        {type="item", name="electronic-circuit", amount=80},
        {type="item", name="electronics-factory-mk01", amount=1},
        {type="item", name="grade-4-chromite", amount=98},
        {type="item", name="py-local-radar", amount=1},
        {type="item", name="residual-mixture-barrel", amount=51},
        {type="item", name="salt", amount=314},
        {type="item", name="soil-extractor-mk01", amount=21},
      },
      results = {
        {type="item", name="nmf-mk01", amount=2},
      },
    },
    ["py-heat-exchanger-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="fwf-mk01", amount=1},
        {type="item", name="lab", amount=6},
        {type="item", name="molten-solder-barrel", amount=120},
        {type="item", name="perylene-barrel", amount=32},
        {type="item", name="py-heat-exchanger", amount=1},
        {type="item", name="stripped-distillate-canister", amount=1},
        {type="item", name="wax-barrel", amount=1009},
        {type="item", name="wet-scrubber-mk01", amount=1},
      },
      results = {
        {type="item", name="py-heat-exchanger-mk02", amount=1},
      },
    },
    ["bio-printer-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="creamy-latex-barrel", amount=23},
        {type="item", name="distilator", amount=2},
        {type="item", name="gasoline-barrel", amount=7},
        {type="item", name="lead-plate", amount=261},
        {type="item", name="mechanical-parts-01", amount=5},
        {type="item", name="nxsb-alloy", amount=10},
        {type="item", name="ree-solution-barrel", amount=28},
        {type="item", name="tin-plate", amount=47},
        {type="item", name="transport-belt", amount=566},
      },
      results = {
        {type="item", name="bio-printer-mk01", amount=2},
      },
    },
    ["botanical-nursery-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="advanced-circuit", amount=5},
        {type="item", name="auog-food-02", amount=23},
        {type="item", name="distilator", amount=1},
        {type="item", name="grade-3-zinc", amount=44},
        {type="item", name="iron-gear-wheel", amount=41},
        {type="item", name="nxsb-alloy", amount=1},
        {type="item", name="ralesia-plantation-mk01", amount=2},
        {type="item", name="rhe", amount=2},
        {type="item", name="rotor", amount=1},
      },
      results = {
        {type="item", name="botanical-nursery-mk02", amount=1},
      },
    },
    ["spore-collector-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="decalin-barrel", amount=757},
        {type="item", name="duralumin", amount=50},
        {type="item", name="eg-si", amount=360},
        {type="item", name="grade-4-chromite", amount=494},
        {type="item", name="hot-air-barrel", amount=110},
        {type="item", name="powdered-u", amount=188},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="ulric-mk02-dna-sample", amount=39},
        {type="item", name="utility-box-mk02", amount=4},
      },
      results = {
        {type="item", name="spore-collector-mk02", amount=1},
      },
    },
    ["breed-fish-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=60},
        {type="fluid", name="water", amount=2725},
        {type="item", name="albumin", amount=1},
        {type="item", name="filtration-media", amount=1},
        {type="item", name="fine-powdered-biomass", amount=2},
        {type="item", name="fish-egg", amount=10},
        {type="item", name="fish-food-02", amount=1},
        {type="item", name="seaweed", amount=10},
        {type="item", name="small-lamp", amount=3},
      },
      results = {
        {type="fluid", name="waste-water", amount=100},
        {type="item", name="fish", amount=30},
      },
    },
    ["breed-fish-egg-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=1349},
        {type="fluid", name="water-saline", amount=100},
        {type="item", name="albumin", amount=1},
        {type="item", name="fish", amount=12},
        {type="item", name="silicon", amount=13},
        {type="item", name="sodium-hydroxide", amount=6},
      },
      results = {
        {type="fluid", name="waste-water", amount=100},
        {type="item", name="fish-egg", amount=35},
      },
    },
    ["fish-egg-mk03-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=9829},
        {type="fluid", name="water-saline", amount=100},
        {type="item", name="fish-mk02", amount=291},
      },
      results = {
        {type="fluid", name="waste-water", amount=100},
        {type="item", name="fish-egg-mk02", amount=1},
        {type="item", name="fish-egg-mk03", amount=11},
      },
    },
    ["fish-mk03"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=60},
        {type="item", name="alien-sample-02", amount=1},
        {type="item", name="fish-food-02", amount=3},
        {type="item", name="fish-mk02", amount=20},
        {type="item", name="sodium-hydroxide", amount=6},
        {type="item", name="stone-wool", amount=11},
      },
      results = {
        {type="item", name="fish", amount=6},
        {type="item", name="fish-mk03", amount=0.004},
      },
    },
    ["fish-mk03-breeder"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="scrude", amount=1878},
        {type="fluid", name="steam", amount=72},
        {type="fluid", name="water", amount=500},
        {type="item", name="titanium-plate", amount=8},
      },
      results = {
        {type="item", name="energy-drink", amount=7},
      },
    },
    ["neuroprocessor"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=3},
        {type="item", name="brain", amount=5},
        {type="item", name="formica", amount=6},
        {type="item", name="light-n", amount=2},
        {type="item", name="nexelit-matrix", amount=5},
        {type="item", name="optical-fiber", amount=10},
        {type="item", name="pcb1", amount=1},
        {type="item", name="pcb2", amount=1},
        {type="item", name="planter-box", amount=6},
        {type="item", name="sugar", amount=1},
        {type="item", name="vacuum-tube", amount=2},
      },
      results = {
        {type="item", name="neuroprocessor", amount=2},
      },
    },
    ["nisi"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="vacuum", amount=300},
        {type="item", name="cobalt-extract", amount=2},
        {type="item", name="nickel-plate", amount=1},
        {type="item", name="silicon", amount=2},
      },
      results = {
        {type="item", name="cobalt-extract", amount=1},
        {type="item", name="nisi", amount=1},
      },
    },
    ["capacitor2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="al-pulp-01", amount=10},
        {type="fluid", name="vacuum", amount=1031},
        {type="item", name="aluminium-plate", amount=10},
        {type="item", name="copper-cable", amount=118},
        {type="item", name="resistor1", amount=6},
      },
      results = {
        {type="item", name="capacitor2", amount=5},
      },
    },
    ["microchip"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="water", amount=118},
        {type="item", name="cermet", amount=6},
        {type="item", name="heavy-n", amount=3},
        {type="item", name="p-dope", amount=13},
        {type="item", name="plastic-bar", amount=8},
        {type="item", name="tin-plate", amount=6},
        {type="item", name="tinned-cable", amount=13},
      },
      results = {
        {type="item", name="microchip", amount=4},
      },
    },
    ["mosfet"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="al-pulp-01", amount=15},
        {type="fluid", name="olefin", amount=420},
        {type="item", name="cobalt-extract", amount=2},
        {type="item", name="green-sic", amount=2},
        {type="item", name="heavy-n", amount=4},
        {type="item", name="melamine-resin", amount=45},
        {type="item", name="nickel-plate", amount=2},
        {type="item", name="p-dope", amount=4},
        {type="item", name="plastic-bar", amount=3},
        {type="item", name="ree-concentrate", amount=10},
      },
      results = {
        {type="item", name="mosfet", amount=4},
      },
    },
    ["phenolicboard"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ammonia", amount=30},
        {type="item", name="capacitor1", amount=23},
        {type="item", name="phenol", amount=25},
        {type="item", name="salt", amount=7},
      },
      results = {
        {type="item", name="phenolicboard", amount=5},
      },
    },
    ["resistor2"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="boric-acid", amount=50},
        {type="item", name="cermet", amount=3},
        {type="item", name="fecr-alloy", amount=4},
        {type="item", name="resistor1", amount=4},
      },
      results = {
        {type="item", name="resistor2", amount=4},
      },
    },
    ["inductor2"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ferrite", amount=10},
        {type="item", name="inductor1", amount=5},
        {type="item", name="melamine-resin", amount=5},
        {type="item", name="tinned-cable", amount=20},
      },
      results = {
        {type="item", name="inductor2", amount=5},
      },
    },
    ["pcb2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="etching", amount=35},
        {type="item", name="copper-low-dust", amount=1},
        {type="item", name="inductor2", amount=2},
        {type="item", name="nylon", amount=3},
        {type="item", name="tin-plate", amount=7},
      },
      results = {
        {type="item", name="pcb2", amount=4},
      },
    },
    ["transistor"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-air", amount=125},
        {type="item", name="heavy-n", amount=5},
        {type="item", name="light-n", amount=5},
        {type="item", name="melamine", amount=16},
        {type="item", name="nylon-parts", amount=5},
        {type="item", name="p-dope", amount=5},
      },
      results = {
        {type="item", name="transistor", amount=5},
      },
    },
    ["diode"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="vacuum", amount=50},
        {type="item", name="cermet", amount=4},
        {type="item", name="heavy-n", amount=1},
        {type="item", name="light-n", amount=4},
        {type="item", name="nylon-parts", amount=14},
        {type="item", name="ree-concentrate", amount=8},
        {type="item", name="tin-plate", amount=3},
      },
      results = {
        {type="item", name="diode", amount=4},
      },
    },
    ["advanced-circuit"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bakelite", amount=10},
        {type="item", name="cobalt-fluoride", amount=6},
        {type="item", name="electronic-circuit", amount=1},
        {type="item", name="epoxy", amount=21},
        {type="item", name="heavy-n", amount=5},
        {type="item", name="inductor2", amount=4},
        {type="item", name="mosfet", amount=5},
        {type="item", name="nxsb-alloy", amount=4},
        {type="item", name="optical-fiber", amount=2},
        {type="item", name="phenolicboard", amount=3},
        {type="item", name="resistor1", amount=98},
        {type="item", name="steel-plate", amount=14},
      },
      results = {
        {type="item", name="advanced-circuit", amount=5},
      },
    },
    ["uranium-mining-drill"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=66},
        {type="item", name="diesel-barrel", amount=120},
        {type="item", name="gate", amount=74},
        {type="item", name="hot-residual-mixture-barrel", amount=111},
        {type="item", name="light-armor", amount=79},
        {type="item", name="resorcinol", amount=941},
        {type="item", name="small-parts-02", amount=100},
        {type="item", name="ti-overflow-waste-barrel", amount=17},
      },
      results = {
        {type="item", name="uranium-mining-drill", amount=1},
      },
    },
    ["aerial-base"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bisphenol-a", amount=134},
        {type="item", name="blood-barrel", amount=7},
        {type="item", name="coal-gas-barrel", amount=3554},
        {type="item", name="electronics-mk02", amount=3},
        {type="item", name="fluorine-gas-barrel", amount=4},
        {type="item", name="low-distillate-canister", amount=555},
        {type="item", name="mechanical-parts-01", amount=3},
        {type="item", name="natural-gas-canister", amount=36},
        {type="item", name="titanium-plate", amount=46},
      },
      results = {
        {type="item", name="aerial-base", amount=1},
      },
    },
    ["aerial-blimp-mk02"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-1-nickel", amount=8},
        {type="item", name="inductor1", amount=102},
        {type="item", name="navens-codex", amount=10},
        {type="item", name="nickel-plate", amount=110},
        {type="item", name="niobium-plate", amount=16},
        {type="item", name="pipe", amount=40},
        {type="item", name="small-parts-02", amount=13},
        {type="item", name="vitreloy", amount=7},
      },
      results = {
        {type="item", name="bhoddos-culture-mk01", amount=1},
      },
    },
    ["cadaveric-arum-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="compressor-mk01", amount=2},
        {type="item", name="micro-mine-mk01", amount=3},
        {type="item", name="nexelit-plate", amount=263},
        {type="item", name="niobium-plate", amount=55},
        {type="item", name="pipe", amount=1535},
        {type="item", name="small-parts-01", amount=137},
      },
      results = {
        {type="item", name="cadaveric-arum-mk01", amount=3},
      },
    },
    ["grods-swamp-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=32},
        {type="item", name="blade-mk01", amount=5},
        {type="item", name="creosote-barrel", amount=33},
        {type="item", name="diesel-barrel", amount=5},
        {type="item", name="duralumin", amount=46},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="fiberboard", amount=91},
        {type="item", name="nexelit-plate", amount=69},
        {type="item", name="stone-brick", amount=200},
        {type="item", name="vanabins-barrel", amount=1},
      },
      results = {
        {type="item", name="grods-swamp-mk01", amount=1},
      },
    },
    ["guar-gum-plantation"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cottongut", amount=6},
        {type="item", name="flora-collector-mk01", amount=2},
        {type="item", name="glass", amount=325},
        {type="item", name="iron-chest", amount=4},
        {type="item", name="korlex-pup", amount=1},
        {type="item", name="nexelit-plate", amount=450},
        {type="item", name="pcb1", amount=13},
        {type="item", name="steel-chest", amount=2},
      },
      results = {
        {type="item", name="guar-gum-plantation", amount=1},
      },
    },
    ["navens-culture-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=70},
        {type="item", name="b-molasse-barrel", amount=3},
        {type="item", name="concrete", amount=206},
        {type="item", name="jaw-crusher", amount=1},
        {type="item", name="mechanical-parts-01", amount=19},
        {type="item", name="naphtha-barrel", amount=13},
        {type="item", name="stainless-steel", amount=16},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="tin-dust", amount=4},
        {type="item", name="titanium-plate", amount=27},
      },
      results = {
        {type="item", name="navens-culture-mk01", amount=1},
      },
    },
    ["ralesia-plantation-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="brain-cartridge-01", amount=17},
        {type="item", name="fast-transport-belt", amount=10},
        {type="item", name="flamethrower-turret", amount=1},
        {type="item", name="micro-fiber", amount=73},
        {type="item", name="military-science-pack", amount=98},
        {type="item", name="molten-aluminium-barrel", amount=3},
        {type="item", name="pressured-hydrogen-barrel", amount=173},
        {type="item", name="purified-ti-pulp-barrel", amount=1},
        {type="item", name="stripped-distillate-barrel", amount=504},
        {type="item", name="ticl4", amount=21},
        {type="item", name="yaedols-mk02", amount=2},
      },
      results = {
        {type="item", name="ralesia-plantation-mk02", amount=1},
      },
    },
    ["rennea-plantation-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="engine-unit", amount=5},
        {type="item", name="fenxsb-alloy", amount=23},
        {type="item", name="fiberboard", amount=228},
        {type="item", name="lens", amount=35},
        {type="item", name="limestone", amount=344},
        {type="item", name="pipe", amount=30},
        {type="item", name="py-tank-5000", amount=3},
        {type="item", name="steel-plate", amount=50},
        {type="item", name="titanium-plate", amount=80},
        {type="item", name="transport-belt", amount=90},
      },
      results = {
        {type="item", name="rennea-plantation-mk01", amount=1},
      },
    },
    ["yotoi-aloe-orchard-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=17},
        {type="item", name="concrete", amount=145},
        {type="item", name="controler-mk01", amount=4},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="niobium-pipe", amount=29},
        {type="item", name="tin-plate", amount=352},
        {type="item", name="titanium-plate", amount=73},
        {type="item", name="transport-belt", amount=34},
      },
      results = {
        {type="item", name="yotoi-aloe-orchard-mk01", amount=2},
      },
    },
    ["sponge-culture-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="arqad-hive-mk01", amount=1},
        {type="item", name="chlorine-barrel", amount=34},
        {type="item", name="cottongut-mk02", amount=45},
        {type="item", name="grade-1-nickel", amount=169},
        {type="item", name="hawt-turbine-mk01", amount=3},
        {type="item", name="natural-gas-canister", amount=116},
        {type="item", name="processed-fatty-acids-barrel", amount=10},
        {type="item", name="py-limestone", amount=237},
        {type="item", name="shaft-mk02", amount=4},
        {type="item", name="wood-seeds-mk02", amount=1},
        {type="item", name="yaedols-spores", amount=10},
      },
      results = {
        {type="item", name="sponge-culture-mk02", amount=1},
      },
    },
    ["cadaveric-arum-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="data-array", amount=1},
        {type="item", name="fiber", amount=6811},
        {type="item", name="korlex-codex-mk02", amount=6},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="plastic-bar", amount=100},
        {type="item", name="programmable-speaker", amount=22},
        {type="item", name="purified-ti-pulp-barrel", amount=1},
        {type="item", name="py-tank-3000", amount=3},
        {type="item", name="ti-overflow-waste-barrel", amount=4},
      },
      results = {
        {type="item", name="cadaveric-arum-mk02", amount=1},
      },
    },
    ["grods-swamp-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boric-acid-barrel", amount=515},
        {type="item", name="condensates-barrel", amount=447},
        {type="item", name="electronic-circuit", amount=8},
        {type="item", name="glass", amount=40},
        {type="item", name="latex-slab", amount=16},
        {type="item", name="melamine", amount=72},
        {type="item", name="molten-stainless-steel-barrel", amount=4},
        {type="item", name="py-underflow-valve", amount=25},
        {type="item", name="quartz-tube", amount=498},
        {type="item", name="wood-fence", amount=222},
        {type="item", name="yotoi-leaves", amount=22},
      },
      results = {
        {type="item", name="grods-swamp-mk02", amount=1},
      },
    },
    ["guar-gum-plantation-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="arqad-honey-barrel", amount=800},
        {type="item", name="compost-plant-mk01", amount=1},
        {type="item", name="empty-fuel-canister", amount=19},
        {type="item", name="high-grade-ti-powder", amount=3},
        {type="item", name="powdered-u", amount=863},
        {type="item", name="purified-ti-pulp-barrel", amount=4},
        {type="item", name="sap-seeds-mk03", amount=209},
        {type="item", name="shell", amount=144},
        {type="item", name="u-pulp-01-barrel", amount=3},
        {type="item", name="vrauks-mk02", amount=1},
      },
      results = {
        {type="item", name="guar-gum-plantation-mk02", amount=1},
      },
    },
    ["kicalk-plantation-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="fawogae-plantation-mk01", amount=4},
        {type="item", name="guar-gum-plantation", amount=1},
        {type="item", name="latex", amount=30},
        {type="item", name="refsyngas-barrel", amount=3140},
        {type="item", name="seaweed", amount=116},
        {type="item", name="stopper", amount=49},
        {type="item", name="tuuphra-mk02", amount=6},
      },
      results = {
        {type="item", name="kicalk-plantation-mk02", amount=1},
      },
    },
    ["moondrop-greenhouse-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="high-grade-ti-powder", amount=7},
        {type="item", name="methanol-canister", amount=7},
        {type="item", name="naphthalene-oil-canister", amount=674},
        {type="item", name="propene-barrel", amount=30},
        {type="item", name="rare-earth-mud-barrel", amount=5},
        {type="item", name="scrude-canister", amount=75},
        {type="item", name="xyhiphoe-cub", amount=3},
      },
      results = {
        {type="item", name="moondrop-greenhouse-mk02", amount=1},
      },
    },
    ["moss-farm-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="glass-core", amount=159},
        {type="item", name="heavy-n", amount=16},
        {type="item", name="melamine", amount=91},
        {type="item", name="molybdenite-pulp-barrel", amount=40},
        {type="item", name="sb-grade-03", amount=937},
        {type="item", name="sea-sponge-mk02", amount=5},
        {type="item", name="ulric-codex", amount=1},
        {type="item", name="vinyl-acetate-barrel", amount=9},
        {type="item", name="xyhiphoe-cub-mk02", amount=1},
      },
      results = {
        {type="item", name="moss-farm-mk02", amount=2},
      },
    },
    ["navens-culture-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="chromium", amount=248},
        {type="item", name="flora-collector-mk01", amount=9},
        {type="item", name="glycerol-barrel", amount=9},
        {type="item", name="molten-copper-barrel", amount=211},
        {type="item", name="oil-sand-slurry-barrel", amount=12},
        {type="item", name="plutonium-peroxide-barrel", amount=23},
        {type="item", name="shaft-mk02", amount=4},
        {type="item", name="small-parts-01", amount=7},
        {type="item", name="ulric-mk02-dna-sample", amount=44},
        {type="item", name="uranium-fuel-cell", amount=9},
      },
      results = {
        {type="item", name="navens-culture-mk02", amount=1},
      },
    },
    ["rennea-plantation-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="diborane-barrel", amount=161},
        {type="item", name="electronics-mk02", amount=11},
        {type="item", name="grade-2-lead", amount=7},
        {type="item", name="grods-swamp-mk01", amount=2},
        {type="item", name="organic-solvent-barrel", amount=141},
        {type="item", name="petri-dish", amount=86},
        {type="item", name="sap-seeds", amount=11},
        {type="item", name="sap-tree-mk03", amount=6},
        {type="item", name="xyhiphoe-cub", amount=1},
      },
      results = {
        {type="item", name="rennea-plantation-mk02", amount=1},
      },
    },
    ["sap-extractor-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="diode", amount=6},
        {type="item", name="distilator", amount=1},
        {type="item", name="grade-1-lead", amount=73},
        {type="item", name="grade-3-ti", amount=1004},
        {type="item", name="inserter", amount=4},
        {type="item", name="olefin-barrel", amount=18},
        {type="item", name="ptcda", amount=7},
        {type="item", name="rubber", amount=8},
        {type="item", name="sea-sponge-sprouts-mk02", amount=2},
        {type="item", name="syrup-01-barrel", amount=3},
      },
      results = {
        {type="item", name="sap-extractor-mk02", amount=1},
      },
    },
    ["seaweed-crop-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anthracene-oil-barrel", amount=149},
        {type="item", name="condensates-canister", amount=9},
        {type="item", name="copper-low-dust", amount=47},
        {type="item", name="distilator", amount=3},
        {type="item", name="fluorine-gas-barrel", amount=59},
        {type="item", name="glycerol-barrel", amount=80},
        {type="item", name="moss-farm-mk01", amount=1},
        {type="item", name="steel-chest", amount=5},
        {type="item", name="titanium-plate", amount=208},
      },
      results = {
        {type="item", name="seaweed-crop-mk02", amount=1},
      },
    },
    ["tuuphra-plantation-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="arthropod-blood-barrel", amount=17},
        {type="item", name="barrel", amount=1167},
        {type="item", name="grade-1-copper", amount=564},
        {type="item", name="methanal-barrel", amount=308},
        {type="item", name="molten-titanium-barrel", amount=341},
        {type="item", name="navens-codex", amount=2},
        {type="item", name="niobium-pipe", amount=8457},
        {type="item", name="nitrogen-barrel", amount=16},
        {type="item", name="silica-powder", amount=1413},
      },
      results = {
        {type="item", name="tuuphra-plantation-mk02", amount=3},
      },
    },
    ["bhoddos-culture-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=70},
        {type="item", name="animal-sample-01", amount=46},
        {type="item", name="ball-mill-mk01", amount=1},
        {type="item", name="clean-nexelit", amount=11128},
        {type="item", name="glass-core", amount=1},
        {type="item", name="moondrop-mk02", amount=58},
        {type="item", name="ptcda", amount=9},
        {type="item", name="rare-earth-mud-barrel", amount=13},
        {type="item", name="salt-mine", amount=38},
        {type="item", name="tuuphra-seeds", amount=30},
      },
      results = {
        {type="item", name="bhoddos-culture-mk02", amount=1},
      },
    },
    ["fawogae-plantation-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="acetylene-barrel", amount=160},
        {type="item", name="auog-paddock-mk01", amount=1},
        {type="item", name="carbolic-oil-canister", amount=2},
        {type="item", name="electronics-mk02", amount=3},
        {type="item", name="lab", amount=2},
        {type="item", name="soda-ash-barrel", amount=13},
        {type="item", name="stator", amount=5},
        {type="item", name="steel-plate", amount=10},
      },
      results = {
        {type="item", name="fawogae-plantation-mk02", amount=1},
      },
    },
    ["fwf-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="arthropod-blood-barrel", amount=5},
        {type="item", name="chitin", amount=32},
        {type="item", name="cottongut-food-02", amount=23},
        {type="item", name="electronic-circuit", amount=510},
        {type="item", name="gasoline-canister", amount=8},
        {type="item", name="medium-electric-pole", amount=26},
        {type="item", name="refined-natural-gas-canister", amount=63},
        {type="item", name="sample-cup", amount=85},
        {type="item", name="sap-extractor-mk01", amount=2},
        {type="item", name="shotgun-shell", amount=1028},
      },
      results = {
        {type="item", name="fwf-mk02", amount=1},
      },
    },
    ["bulk-inserter"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="duralumin", amount=14},
        {type="item", name="electronic-circuit", amount=26},
        {type="item", name="nbalti", amount=5},
        {type="item", name="stator", amount=2},
        {type="item", name="titanium-plate", amount=16},
      },
      results = {
        {type="item", name="bulk-inserter", amount=1},
      },
    },
    ["assembling-machine-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="fish-hydrolysate-barrel", amount=6},
        {type="item", name="long-handed-inserter", amount=53},
        {type="item", name="reo", amount=29},
        {type="item", name="yaedols-spores-mk02", amount=92},
      },
      results = {
        {type="item", name="assembling-machine-3", amount=1},
      },
    },
    ["chemical-science-pack"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="organic-acid-anhydride", amount=50},
        {type="item", name="advanced-circuit", amount=2},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="intermetallics", amount=9},
        {type="item", name="nuclear-sample", amount=1},
        {type="item", name="optical-fiber", amount=10},
        {type="item", name="rubber", amount=10},
        {type="item", name="self-assembly-monolayer", amount=2},
        {type="item", name="shaft-mk02", amount=2},
        {type="item", name="small-parts-01", amount=7},
      },
      results = {
        {type="item", name="chemical-science-pack", amount=12},
      },
    },
    ["electric-furnace"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bio-oil-canister", amount=3},
        {type="item", name="grade-4-tin", amount=81},
        {type="item", name="neuroprocessor", amount=6},
        {type="item", name="py-aluminium", amount=1},
      },
      results = {
        {type="item", name="electric-furnace", amount=1},
      },
    },
    ["megadar"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="intermetallics", amount=223},
        {type="item", name="iron-plate", amount=87},
        {type="item", name="nexelit-plate", amount=20},
        {type="item", name="small-parts-02", amount=23},
        {type="item", name="titanium-plate", amount=82},
      },
      results = {
        {type="item", name="megadar", amount=1},
      },
    },
    ["modular-armor"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=23636},
        {type="item", name="burner-mining-drill", amount=2},
        {type="item", name="electronic-circuit", amount=1403},
        {type="item", name="grade-2-u", amount=1086},
        {type="item", name="heavy-armor", amount=23},
        {type="item", name="nexelit-plate", amount=183},
        {type="item", name="niobium-concentrate", amount=307},
        {type="item", name="ppd", amount=179},
        {type="item", name="py-construction-robot-mk01", amount=33},
        {type="item", name="self-assembly-monolayer", amount=10},
        {type="item", name="small-parts-01", amount=40},
      },
      results = {
        {type="item", name="modular-armor", amount=1},
      },
    },
    ["particle-accelerator-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anemometer-mk02", amount=5},
        {type="item", name="compressor-mk01", amount=1},
        {type="item", name="fenxsb-alloy", amount=92},
        {type="item", name="glass", amount=87},
        {type="item", name="iron-stick", amount=1357},
        {type="item", name="kicalk-plantation-mk01", amount=24},
        {type="item", name="nexelit-plate", amount=131},
        {type="item", name="niobium-powder", amount=48},
        {type="item", name="small-parts-01", amount=116},
        {type="item", name="xyhiphoe", amount=8},
      },
      results = {
        {type="item", name="particle-accelerator-mk01", amount=1},
      },
    },
    ["yaedols-culture-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="eg-si", amount=360},
        {type="item", name="fish-farm-mk01", amount=2},
        {type="item", name="hazard-concrete", amount=49},
        {type="item", name="neuroprocessor", amount=50},
        {type="item", name="niobium-dust", amount=444},
        {type="item", name="offshore-pump", amount=47},
        {type="item", name="powdered-quartz", amount=14},
        {type="item", name="titanium-plate", amount=952},
        {type="item", name="used-comb", amount=3104},
      },
      results = {
        {type="item", name="yaedols-culture-mk02", amount=1},
      },
    },
    ["yotoi-aloe-orchard-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aromatics-canister", amount=7},
        {type="item", name="copper-rejects", amount=4407},
        {type="item", name="duralumin", amount=49},
        {type="item", name="grade-3-chromite", amount=33},
        {type="item", name="methanal-barrel", amount=227},
        {type="item", name="plastic-bar", amount=40},
        {type="item", name="prandium-lab-mk01", amount=1},
        {type="item", name="stone-furnace", amount=62},
        {type="item", name="u-235", amount=6},
      },
      results = {
        {type="item", name="yotoi-aloe-orchard-mk02", amount=1},
      },
    },
    ["kicalk-seeds-mk02"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="kicalk-mk02", amount=4},
      },
      results = {
        {type="item", name="kicalk-seeds-mk02", amount=5},
      },
    },
    ["yotoi-fiber"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="grod", amount=2},
        {type="item", name="kicalk", amount=3},
        {type="item", name="wood", amount=9},
        {type="item", name="yotoi", amount=4},
      },
      results = {
        {type="item", name="bedding", amount=4},
      },
    },
    ["cu-biomass-extraction"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=300},
        {type="item", name="cu-biomass", amount=10},
      },
      results = {
        {type="item", name="biomass", amount=5},
        {type="item", name="copper-ore", amount=20},
      },
    },
    ["fe-biomass-extraction"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=300},
        {type="item", name="sn-biomass", amount=8},
      },
      results = {
        {type="item", name="biomass", amount=5},
        {type="item", name="iron-ore", amount=20},
      },
    },
    ["fungal-substrate-03"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.1,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=55},
        {type="item", name="agar", amount=1},
        {type="item", name="empty-petri-dish", amount=3},
        {type="item", name="fine-powdered-biomass", amount=4},
        {type="item", name="gravel", amount=6},
        {type="item", name="meat", amount=6},
        {type="item", name="raw-fiber", amount=5},
        {type="item", name="yaedols", amount=3},
      },
      results = {
        {type="item", name="fungal-substrate-03", amount=11},
      },
    },
    ["nacl-biomass-extraction"] = {
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=348},
        {type="fluid", name="xenogenic-cells", amount=150},
        {type="item", name="dried-meat", amount=10},
        {type="item", name="retrovirus", amount=1},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=50},
        {type="fluid", name="psc", amount=50},
      },
    },
    ["s-biomass-extraction"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=100},
        {type="item", name="s-biomass", amount=10},
      },
      results = {
        {type="item", name="biomass", amount=5},
        {type="item", name="sulfur", amount=10},
      },
    },
    ["sn-biomass-extraction"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="item", name="cu-biomass", amount=1},
        {type="item", name="grade-3-lead", amount=1},
        {type="item", name="rennea-seeds", amount=16},
      },
      results = {
        {type="item", name="sporopollenin", amount=6},
      },
    },
    ["vinyl-acetate"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="processed-fatty-acids", amount=100},
        {type="item", name="chromium", amount=2},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=50},
        {type="fluid", name="tailings", amount=100},
        {type="fluid", name="vinyl-acetate", amount=50},
      },
    },
    ["lignin"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-air", amount=200},
        {type="item", name="dried-biomass", amount=69},
        {type="item", name="sodium-hydroxide", amount=2},
      },
      results = {
        {type="item", name="lignin", amount=8},
      },
    },
    ["seeds-extract-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grod", amount=5},
        {type="item", name="guar", amount=29},
        {type="item", name="rennea", amount=6},
        {type="item", name="seaweed", amount=16},
      },
      results = {
        {type="item", name="seeds-extract-01", amount=5},
      },
    },
    ["yotoi-cellulose"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="salt", amount=10},
        {type="item", name="yotoi", amount=4},
      },
      results = {
        {type="item", name="cellulose", amount=3},
      },
    },
    ["ulric-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-pup", amount=8},
        {type="item", name="bedding", amount=1},
        {type="item", name="ralesia", amount=10},
        {type="item", name="salt", amount=5},
        {type="item", name="ulric-food-01", amount=1},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="ulric", amount=6},
      },
    },
    ["ulric-cub-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="item", name="albumin", amount=1},
        {type="item", name="fawogae-spore", amount=3},
        {type="item", name="ralesia", amount=14},
        {type="item", name="refined-natural-gas-barrel", amount=10},
        {type="item", name="salt", amount=13},
        {type="item", name="ulric-food-01", amount=3},
      },
      results = {
        {type="item", name="barrel", amount=20},
        {type="item", name="ulric-cub", amount=8},
      },
    },
    ["ulric-manure-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.17607447261566,
      ingredients = {
        {type="item", name="ralesia", amount=12},
        {type="item", name="refined-natural-gas-barrel", amount=3},
        {type="item", name="salt", amount=6},
        {type="item", name="stone-wool", amount=3},
        {type="item", name="ulric-food-01", amount=1},
      },
      results = {
        {type="item", name="barrel", amount=6},
        {type="item", name="manure", amount=7},
      },
    },
    ["ulric-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bedding", amount=4},
        {type="item", name="kicalk", amount=2},
        {type="item", name="naphtha-barrel", amount=3},
        {type="item", name="ulric", amount=2},
        {type="item", name="ulric-food-01", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=7},
        {type="item", name="ulric", amount=1},
        {type="item", name="ulric-mk02", amount=0.005},
      },
    },
    ["ulric-mk02-dna-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="melamine", amount=1},
        {type="item", name="treated-wood", amount=16},
        {type="item", name="ulric", amount=89},
      },
      results = {
        {type="item", name="ulric-mk02-dna-sample", amount=1},
        {type="item", name="used-ulric-mk02", amount=1},
      },
    },
    ["ulric-mk02-dna-sample-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-food-01", amount=2},
        {type="item", name="latex-slab", amount=2},
        {type="item", name="sand-casting", amount=3},
        {type="item", name="ulric-mk02", amount=1},
      },
      results = {
        {type="item", name="ulric-mk02-dna-sample", amount=6},
        {type="item", name="used-ulric-mk02", amount=1},
      },
    },
    ["ulric-mk02-breeding"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-food-02", amount=3},
        {type="item", name="refined-natural-gas-barrel", amount=4},
        {type="item", name="sample-cup", amount=231},
        {type="item", name="ulric-food-01", amount=4},
        {type="item", name="ulric-mk02", amount=1},
      },
      results = {
        {type="item", name="barrel", amount=7},
        {type="item", name="ulric-cub-mk02", amount=1},
        {type="item", name="used-ulric-mk02", amount=1},
      },
    },
    ["ulric-recharge-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="sample-cup", amount=24},
        {type="item", name="used-ulric-mk02", amount=1},
      },
      results = {
        {type="item", name="ulric-mk02", amount=1},
      },
    },
    ["ulric-mk02-raising"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="barrel-milk", amount=2},
        {type="item", name="fiber", amount=4},
        {type="item", name="lignin", amount=24},
        {type="item", name="py-check-valve", amount=2},
        {type="item", name="ulric-cub-mk02", amount=4},
        {type="item", name="yaedols", amount=1},
      },
      results = {
        {type="item", name="empty-barrel-milk", amount=2},
        {type="item", name="ulric-mk02", amount=1},
      },
    },
    ["compile-korlex-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="arqad-codex", amount=1},
        {type="item", name="stainless-steel", amount=23},
      },
      results = {
        {type="item", name="korlex-codex-mk02", amount=1},
      },
    },
    ["korlex-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="arqad-honey-barrel", amount=3},
        {type="item", name="bhoddos", amount=2},
        {type="item", name="caged-korlex", amount=4},
        {type="item", name="coal-dust", amount=11},
        {type="item", name="kicalk-seeds", amount=3},
        {type="item", name="korlex-food-01", amount=2},
        {type="item", name="lignin", amount=18},
        {type="item", name="seaweed", amount=72},
        {type="item", name="tuuphra-mk02", amount=1},
      },
      results = {
        {type="item", name="barrel", amount=12},
        {type="item", name="korlex", amount=6},
      },
    },
    ["korlex-milk-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.82815533481781,
      ingredients = {
        {type="item", name="bhoddos", amount=4},
        {type="item", name="casein", amount=4},
        {type="item", name="coal-dust", amount=12},
        {type="item", name="fish", amount=9},
        {type="item", name="fish-hydrolysate-barrel", amount=1},
        {type="item", name="korlex-food-01", amount=2},
        {type="item", name="tuuphra-seeds", amount=34},
      },
      results = {
        {type="item", name="barrel", amount=18},
        {type="item", name="barrel-milk", amount=11},
      },
    },
    ["korlex-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.45926555774486,
      ingredients = {
        {type="item", name="fish-emulsion-barrel", amount=1},
        {type="item", name="korlex", amount=3},
        {type="item", name="lignin", amount=34},
        {type="item", name="refined-natural-gas-barrel", amount=4},
        {type="item", name="rennea-seeds", amount=25},
        {type="item", name="sodium-hydroxide", amount=6},
      },
      results = {
        {type="item", name="barrel", amount=9},
        {type="item", name="korlex", amount=1},
        {type="item", name="korlex-mk02", amount=0.00718153978088807},
      },
    },
    ["korlex-pup-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="fish-hydrolysate-barrel", amount=12},
        {type="item", name="korlex-food-01", amount=2},
        {type="item", name="log", amount=3},
        {type="item", name="olefin-barrel", amount=13},
        {type="item", name="salt", amount=42},
        {type="item", name="tuuphra", amount=3},
      },
      results = {
        {type="item", name="barrel", amount=25},
        {type="item", name="korlex-pup", amount=6},
      },
    },
    ["korlex-mk02r"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="psc", amount=190},
        {type="fluid", name="xenogenic-cells", amount=190},
        {type="item", name="alien-sample-02", amount=1},
        {type="item", name="guts", amount=917},
        {type="item", name="kevlar-coating", amount=3},
        {type="item", name="korlex-mk02", amount=8},
        {type="item", name="nichrome", amount=48},
      },
      results = {
        {type="item", name="korlex-mk02", amount=10},
      },
    },
    ["sap-seeds-mk03-gen"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=173},
        {type="item", name="py-quartz", amount=1},
        {type="item", name="sap-tree", amount=9},
        {type="item", name="saps", amount=3},
        {type="item", name="stone", amount=13},
      },
      results = {
        {type="item", name="sap-seeds-mk03", amount=1},
      },
    },
    ["sap-seeds-mk03"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="diborane-barrel", amount=2},
      },
      results = {
        {type="item", name="sap-seeds-mk03", amount=2},
      },
    },
    ["sap-tree-mk03-gen"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=86},
        {type="item", name="kicalk", amount=3},
        {type="item", name="sap-seeds-mk03", amount=6},
        {type="item", name="skin", amount=3},
      },
      results = {
        {type="item", name="sap-tree-mk03", amount=1},
      },
    },
    ["xyhiphoe-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.64978612935949,
      ingredients = {
        {type="fluid", name="oxygen", amount=2152},
        {type="fluid", name="steam", amount=2792},
        {type="item", name="albumin", amount=10},
        {type="item", name="filtration-media", amount=2},
        {type="item", name="fish-food-01", amount=2},
        {type="item", name="tar-canister", amount=1},
        {type="item", name="xyhiphoe-cub", amount=3},
      },
      results = {
        {type="fluid", name="waste-water", amount=319},
        {type="item", name="xyhiphoe", amount=2},
      },
    },
    ["xyhiphoe-cub-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="vacuum", amount=27520},
        {type="fluid", name="water", amount=1750},
        {type="item", name="fawogae-substrate", amount=6},
        {type="item", name="filtration-media", amount=2},
        {type="item", name="fish-food-01", amount=2},
        {type="item", name="medium-distillate-barrel", amount=1},
        {type="item", name="nylon", amount=8},
      },
      results = {
        {type="fluid", name="waste-water", amount=650},
        {type="item", name="xyhiphoe-cub", amount=7},
      },
    },
    ["xyhiphoe-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=824},
        {type="item", name="albumin", amount=7},
        {type="item", name="filtration-media", amount=5},
        {type="item", name="fishmeal", amount=8},
        {type="item", name="xyhiphoe", amount=2},
      },
      results = {
        {type="item", name="xyhiphoe", amount=1},
        {type="item", name="xyhiphoe-mk02", amount=0.005},
      },
    },
    ["xyhiphoe-pool-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="al-pulp-01-barrel", amount=1},
        {type="item", name="cobalt-fluoride", amount=13},
        {type="item", name="fast-transport-belt", amount=27},
        {type="item", name="neuroprocessor", amount=30},
        {type="item", name="niobium-pipe", amount=37},
        {type="item", name="outpost-fluid", amount=21},
        {type="item", name="selector-combinator", amount=3},
        {type="item", name="u-pulp-01-barrel", amount=6},
        {type="item", name="vpulp2-barrel", amount=4},
        {type="item", name="waste-water-barrel", amount=198},
        {type="item", name="wet-scrubber-mk01", amount=1},
        {type="item", name="yotoi-seeds", amount=1},
      },
      results = {
        {type="item", name="xyhiphoe-pool-mk02", amount=1},
      },
    },
    ["xyhiphoe-cub-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2.16825321793108,
      ingredients = {
        {type="fluid", name="oxygen", amount=846},
        {type="item", name="fawogae", amount=61},
        {type="item", name="fish-egg-mk02", amount=5},
        {type="item", name="nylon-parts", amount=116},
        {type="item", name="stone-wall", amount=27},
        {type="item", name="xyhiphoe-mk02", amount=2},
      },
      results = {
        {type="item", name="xyhiphoe-cub", amount=1},
        {type="item", name="xyhiphoe-cub-mk02", amount=5},
      },
    },
    ["xyhiphoe-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="fluid", name="water", amount=165},
        {type="item", name="burner-inserter", amount=2},
        {type="item", name="dried-meat", amount=1},
        {type="item", name="powdered-biomass", amount=8},
      },
      results = {
        {type="item", name="bhoddos", amount=8},
      },
    },
    ["bhoddos-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=1374},
        {type="item", name="alien-sample-02", amount=3},
        {type="item", name="alien-sample01", amount=9},
        {type="item", name="cytostatics", amount=5},
        {type="item", name="dna-polymerase", amount=2},
        {type="item", name="earth-palmtree-sample", amount=4},
        {type="item", name="green-sic", amount=11},
        {type="item", name="moondrop-seeds", amount=292},
        {type="item", name="mukmoux-codex", amount=6},
      },
      results = {
        {type="item", name="bhoddos", amount=3},
      },
    },
    ["fish-food-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=300},
        {type="item", name="bones", amount=5},
        {type="item", name="brain", amount=3},
        {type="item", name="fish", amount=2},
        {type="item", name="meat", amount=6},
        {type="item", name="moss", amount=4},
        {type="item", name="pipe", amount=8},
        {type="item", name="pyrite", amount=6},
        {type="item", name="red-refined-concrete", amount=65},
        {type="item", name="rich-clay", amount=3},
        {type="item", name="sodium-chlorate", amount=3},
        {type="item", name="sodium-hydroxide", amount=15},
        {type="item", name="yaedols", amount=1},
      },
      results = {
        {type="item", name="fish-food-02", amount=5},
      },
    },
    ["naven-coal"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="navens", amount=1},
      },
      results = {
        {type="item", name="raw-coal", amount=10},
      },
    },
    ["navens-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="fertilizer", amount=5},
        {type="item", name="fungal-substrate-03", amount=1},
        {type="item", name="guts", amount=5},
        {type="item", name="navens-spore", amount=2},
      },
      results = {
        {type="item", name="navens", amount=7},
      },
    },
    ["navens-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=333},
        {type="item", name="alien-sample-02", amount=2},
        {type="item", name="cytostatics", amount=2},
        {type="item", name="earth-bear-sample", amount=1},
        {type="item", name="glass", amount=99},
        {type="item", name="navens-codex", amount=1},
        {type="item", name="petroleum-gas-barrel", amount=47},
      },
      results = {
        {type="item", name="navens", amount=2},
      },
    },
    ["mukmoux-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="nickel-plate", amount=3},
        {type="item", name="nxsb-alloy", amount=1},
        {type="item", name="pipe", amount=13},
      },
      results = {
        {type="item", name="mukmoux-codex", amount=1},
      },
    },
    ["mukmoux-food-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="steam", amount=139},
        {type="item", name="grade-1-tin", amount=2},
        {type="item", name="gunpowder", amount=3},
        {type="item", name="lead-plate", amount=4},
        {type="item", name="moondrop-mk02", amount=1},
        {type="item", name="ralesia", amount=35},
        {type="item", name="salt", amount=14},
        {type="item", name="sodium-hydroxide", amount=7},
      },
      results = {
        {type="item", name="mukmoux-food-01", amount=4},
      },
    },
    ["mukmoux-manure-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bedding", amount=2},
        {type="item", name="fertilizer", amount=20},
        {type="item", name="mukmoux-food-01", amount=2},
        {type="item", name="ralesia", amount=16},
        {type="item", name="refined-natural-gas-barrel", amount=8},
      },
      results = {
        {type="item", name="barrel", amount=14},
        {type="item", name="manure", amount=5},
        {type="item", name="manure-bacteria-barrel", amount=1},
      },
    },
    ["mukmoux"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="bio-oil", amount=3903},
        {type="fluid", name="blood", amount=1455},
        {type="item", name="alien-sample01", amount=150},
        {type="item", name="dna-polymerase", amount=21},
        {type="item", name="earth-cow-sample", amount=1},
        {type="item", name="glass", amount=50},
        {type="item", name="ulric-codex", amount=1},
      },
      results = {
        {type="item", name="mukmoux", amount=1},
      },
    },
    ["mukmoux-calf-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bedding", amount=2},
        {type="item", name="bhoddos", amount=4},
        {type="item", name="mukmoux-food-01", amount=2},
        {type="item", name="naphtha-barrel", amount=6},
        {type="item", name="ralesia", amount=21},
      },
      results = {
        {type="item", name="barrel", amount=15},
        {type="item", name="mukmoux-calf", amount=2},
      },
    },
    ["mukmoux-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="caged-mukmoux", amount=2},
        {type="item", name="fawogae-mk02", amount=1},
        {type="item", name="mukmoux-food-01", amount=3},
        {type="item", name="naphtha-barrel", amount=4},
        {type="item", name="ralesia", amount=16},
      },
      results = {
        {type="item", name="barrel", amount=9},
        {type="item", name="mukmoux", amount=3},
      },
    },
    ["mukmoux-pasture-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="acetone-barrel", amount=70},
        {type="item", name="anthracene-oil-canister", amount=28},
        {type="item", name="etching-barrel", amount=2},
        {type="item", name="formamide-barrel", amount=15},
        {type="item", name="limestone", amount=191},
        {type="item", name="molten-aluminium-barrel", amount=5},
      },
      results = {
        {type="item", name="mukmoux-pasture-mk01", amount=1},
      },
    },
    ["cottongut-food-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=300},
        {type="item", name="fertilizer", amount=3},
        {type="item", name="log", amount=1},
        {type="item", name="moondrop-fueloil", amount=14},
        {type="item", name="native-flora", amount=15},
        {type="item", name="rennea", amount=6},
        {type="item", name="small-lamp", amount=1},
        {type="item", name="tin-plate", amount=2},
        {type="item", name="wood-seedling", amount=5},
      },
      results = {
        {type="item", name="cottongut-food-02", amount=6},
      },
    },
    ["cottongut-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.99623676885853,
      ingredients = {
        {type="fluid", name="artificial-blood", amount=38},
        {type="fluid", name="fetal-serum", amount=94},
        {type="item", name="cottongut-pup", amount=2},
        {type="item", name="dna-polymerase", amount=2},
      },
      results = {
        {type="item", name="cottongut-mk01", amount=1},
        {type="item", name="cottongut-mk02", amount=0.00942156105910033},
      },
    },
    ["cottongut-pup-mk02-raising"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.03896103896104,
      ingredients = {
        {type="item", name="cottongut-mk02", amount=2},
        {type="item", name="fish-food-02", amount=1},
        {type="item", name="mukmoux-fat", amount=3},
        {type="item", name="tuuphra-seeds", amount=5},
        {type="item", name="wood-seeds", amount=4},
      },
      results = {
        {type="item", name="cottongut-mk02", amount=2},
        {type="item", name="cottongut-pup-mk02", amount=4},
      },
    },
    ["cottongut-cub-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bedding", amount=1},
        {type="item", name="bhoddos-spore", amount=2},
        {type="item", name="cobalt-fluoride", amount=1},
        {type="item", name="cottongut", amount=4},
        {type="item", name="cottongut-food-01", amount=1},
        {type="item", name="moondrop-seeds", amount=5},
        {type="item", name="pressured-water-barrel", amount=3},
        {type="item", name="yotoi-fruit", amount=27},
      },
      results = {
        {type="item", name="barrel", amount=3},
        {type="item", name="cottongut-pup", amount=16},
        {type="item", name="empty-barrel-milk", amount=2},
      },
    },
    ["cottongut-mature-basic-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cadaveric-arum-seeds", amount=2},
        {type="item", name="cottongut-pup-mk01", amount=11},
        {type="item", name="fish-food-02", amount=1},
        {type="item", name="grod", amount=3},
        {type="item", name="yaedols", amount=5},
      },
      results = {
        {type="item", name="cottongut-mk02", amount=2},
      },
    },
    ["auog-food-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="fluid", name="steam", amount=158},
        {type="item", name="auog-food-01", amount=1},
        {type="item", name="boiler", amount=2},
        {type="item", name="cobalt-fluoride", amount=3},
        {type="item", name="fertilizer", amount=8},
        {type="item", name="kicalk", amount=3},
        {type="item", name="plastic-bar", amount=3},
        {type="item", name="powdered-ralesia-seeds", amount=1},
        {type="item", name="raw-fiber", amount=6},
        {type="item", name="sodium-chlorate", amount=4},
        {type="item", name="wood", amount=3},
      },
      results = {
        {type="item", name="auog-food-02", amount=8},
      },
    },
    ["auog-maturing-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.37686163815345,
      ingredients = {
        {type="item", name="auog-food-02", amount=1},
        {type="item", name="caged-auog", amount=2},
        {type="item", name="casein", amount=2},
        {type="item", name="kicalk", amount=7},
        {type="item", name="lignin", amount=25},
        {type="item", name="raw-coal", amount=28},
        {type="item", name="refined-natural-gas-barrel", amount=4},
        {type="item", name="vrauks-food-01", amount=3},
      },
      results = {
        {type="item", name="auog", amount=11},
        {type="item", name="barrel", amount=7},
      },
    },
    ["auog-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.40439080988389,
      ingredients = {
        {type="item", name="auog-food-02", amount=1},
        {type="item", name="auog-pup", amount=1},
        {type="item", name="casein", amount=3},
        {type="item", name="dried-meat", amount=52},
      },
      results = {
        {type="item", name="auog", amount=1},
        {type="item", name="auog-mk02", amount=0.00663461963869674},
        {type="item", name="charged-auog", amount=0.132692392773935},
      },
    },
    ["charged-auog"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="unslimed-iron", amount=3},
        {type="item", name="workers-food", amount=4},
      },
      results = {
        {type="item", name="charged-auog", amount=4},
      },
    },
    ["auog-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-food-01", amount=7},
        {type="item", name="bedding", amount=4},
        {type="item", name="charged-auog", amount=12},
        {type="item", name="empty-planter-box", amount=4},
        {type="item", name="moss", amount=10},
        {type="item", name="refined-natural-gas-barrel", amount=2},
      },
      results = {
        {type="item", name="auog-pup-mk02", amount=5},
        {type="item", name="barrel", amount=3},
      },
    },
    ["auog-mk02-recharge"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="albumin", amount=1},
        {type="item", name="auog-food-02", amount=1},
        {type="item", name="moss", amount=8},
        {type="item", name="refined-natural-gas-canister", amount=103},
      },
      results = {
        {type="item", name="auog-mk02", amount=4},
      },
    },
    ["auog-pooping-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.03888244883662,
      ingredients = {
        {type="item", name="auog-food-02", amount=1},
        {type="item", name="kicalk", amount=5},
        {type="item", name="light-oil-canister", amount=1},
        {type="item", name="lignin", amount=18},
        {type="item", name="moss", amount=10},
        {type="item", name="naphtha-barrel", amount=2},
        {type="item", name="purified-syngas-canister", amount=4},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="manure", amount=11},
      },
    },
    ["auog-pup-breeding-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-food-02", amount=1},
        {type="item", name="bedding", amount=3},
        {type="item", name="guar-seeds", amount=9},
        {type="item", name="kicalk", amount=5},
        {type="item", name="moss", amount=10},
        {type="item", name="pink-refined-concrete", amount=5},
        {type="item", name="refined-natural-gas-barrel", amount=3},
      },
      results = {
        {type="item", name="auog-pup", amount=12},
        {type="item", name="barrel", amount=5},
      },
    },
    ["auog-recharge"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="item", name="auog-food-01", amount=4},
        {type="item", name="bedding", amount=1},
        {type="item", name="condensed-distillate-barrel", amount=2},
      },
      results = {
        {type="item", name="auog", amount=5},
      },
    },
    ["auog-pup-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-food-01", amount=7},
        {type="item", name="auog-pup-mk02", amount=4},
        {type="item", name="bedding", amount=4},
        {type="item", name="energy-drink", amount=4},
        {type="item", name="grade-3-lead", amount=1},
        {type="item", name="refined-natural-gas-barrel", amount=2},
        {type="item", name="sodium-alginate", amount=1},
      },
      results = {
        {type="item", name="auog-mk02", amount=3},
        {type="item", name="barrel", amount=3},
        {type="item", name="empty-barrel-milk", amount=2},
      },
    },
    ["ralesia-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=364},
        {type="fluid", name="water", amount=100},
        {type="item", name="coarse", amount=2},
        {type="item", name="fertilizer", amount=5},
        {type="item", name="gravel", amount=5},
        {type="item", name="limestone", amount=1},
        {type="item", name="raw-fiber", amount=19},
      },
      results = {
        {type="item", name="ralesia", amount=25},
      },
    },
    ["ralesia-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=1093},
        {type="fluid", name="steam", amount=333},
        {type="item", name="coarse", amount=13},
        {type="item", name="fertilizer", amount=10},
        {type="item", name="ralesia", amount=2},
        {type="item", name="ralesia-seeds", amount=10},
      },
      results = {
        {type="item", name="ralesia", amount=1},
        {type="item", name="ralesia-mk02", amount=0.005},
      },
    },
    ["ralesia-seeds-mk02"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ralesia-mk02", amount=5},
      },
      results = {
        {type="item", name="ralesia-seeds-mk02", amount=8},
      },
    },
    ["ralesia-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=400},
        {type="item", name="fertilizer", amount=32},
        {type="item", name="ralesia-seeds-mk02", amount=4},
      },
      results = {
        {type="item", name="fawogae-spore-mk02", amount=1},
        {type="item", name="ralesia-mk02", amount=4},
        {type="item", name="ralesia-seeds-mk02", amount=1},
      },
    },
    ["vrauks-cocoon-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bedding", amount=1},
        {type="item", name="bio-oil-canister", amount=1},
        {type="item", name="cottongut-food-01", amount=3},
        {type="item", name="kicalk", amount=2},
        {type="item", name="vrauks-food-02", amount=1},
        {type="item", name="water-barrel", amount=4},
      },
      results = {
        {type="item", name="barrel", amount=4},
        {type="item", name="cocoon", amount=20},
      },
    },
    ["vrauks-food-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="fluid", name="fish-oil", amount=52},
        {type="fluid", name="steam", amount=174},
        {type="item", name="auog-food-01", amount=2},
        {type="item", name="biomass", amount=356},
        {type="item", name="bones", amount=3},
        {type="item", name="cellulose", amount=7},
        {type="item", name="dried-grods", amount=2},
        {type="item", name="lignin", amount=17},
        {type="item", name="niobium-concentrate", amount=2},
        {type="item", name="niobium-plate", amount=4},
        {type="item", name="pcb1", amount=1},
        {type="item", name="ralesia-seeds-mk02", amount=1},
        {type="item", name="tuuphra", amount=1},
      },
      results = {
        {type="item", name="vrauks-food-02", amount=10},
      },
    },
    ["vrauks-mk03"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.95539818004719,
      ingredients = {
        {type="item", name="alien-sample-02", amount=2},
        {type="item", name="bedding", amount=7},
        {type="item", name="casein", amount=1},
        {type="item", name="cocoon-mk02", amount=93},
        {type="item", name="ore-zinc", amount=55},
        {type="item", name="refined-natural-gas-barrel", amount=5},
        {type="item", name="vrauks-food-02", amount=6},
      },
      results = {
        {type="item", name="barrel", amount=9},
        {type="item", name="vrauks-mk02", amount=5},
        {type="item", name="vrauks-mk03", amount=0.00747958785605891},
      },
    },
    ["vrauks-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-food-02", amount=2},
        {type="item", name="bedding", amount=1},
        {type="item", name="cocoon-mk02", amount=7},
        {type="item", name="naphtha-barrel", amount=1},
        {type="item", name="native-flora", amount=20},
        {type="item", name="vrauks-food-01", amount=2},
        {type="item", name="vrauks-food-02", amount=1},
      },
      results = {
        {type="item", name="barrel", amount=3},
        {type="item", name="vrauks", amount=8},
      },
    },
    ["vrauks-mk03-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.05241200641898,
      ingredients = {
        {type="item", name="auog-food-02", amount=3},
        {type="item", name="carbon-dioxide-barrel", amount=5},
        {type="item", name="cocoon-mk02", amount=4},
        {type="item", name="cottongut-food-01", amount=7},
        {type="item", name="cytostatics", amount=2},
        {type="item", name="ethanol-barrel", amount=1},
        {type="item", name="moss", amount=6},
        {type="item", name="sea-sponge-mk02", amount=1},
        {type="item", name="vrauks-mk03", amount=1},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="vrauks-mk03", amount=2},
      },
    },
    ["vrauks-mk03-cocoon"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.0876485927556,
      ingredients = {
        {type="item", name="auog-food-02", amount=1},
        {type="item", name="bedding", amount=2},
        {type="item", name="mibc-barrel", amount=1},
        {type="item", name="refined-natural-gas-barrel", amount=3},
        {type="item", name="sea-sponge", amount=5},
        {type="item", name="vrauks-food-01", amount=4},
        {type="item", name="vrauks-mk03", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="cocoon-mk03", amount=6},
        {type="item", name="vrauks-mk03", amount=2},
      },
    },
    ["yotoi-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=333},
        {type="item", name="alien-sample-02", amount=2},
        {type="item", name="arqad-codex", amount=3},
        {type="item", name="cellulose", amount=3},
        {type="item", name="cytostatics", amount=2},
        {type="item", name="earth-sunflower-sample", amount=1},
        {type="item", name="glass", amount=99},
        {type="item", name="sic", amount=1},
      },
      results = {
        {type="item", name="yotoi", amount=2},
      },
    },
    ["yotoi-leaves"] = {
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="water", amount=144},
        {type="item", name="pitch-barrel", amount=1},
        {type="item", name="pure-sand", amount=7},
        {type="item", name="yotoi-fruit", amount=4},
      },
      results = {
        {type="item", name="yotoi", amount=6},
      },
    },
    ["yotoi-fruit-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="coal-dust", amount=4},
        {type="item", name="sand", amount=2},
        {type="item", name="stone", amount=18},
      },
      results = {
        {type="item", name="yotoi-fruit", amount=5},
      },
    },
    ["fawogae-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="fungal-substrate", amount=1},
        {type="item", name="ore-aluminium", amount=4},
      },
      results = {
        {type="item", name="fawogae", amount=15},
      },
    },
    ["fawogae-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=150},
        {type="fluid", name="water", amount=1000},
        {type="item", name="fawogae", amount=2},
        {type="item", name="fertilizer", amount=10},
        {type="item", name="offshore-pump", amount=1},
        {type="item", name="pure-sand", amount=32},
      },
      results = {
        {type="item", name="fawogae", amount=1},
        {type="item", name="fawogae-mk02", amount=0.005},
      },
    },
    ["fawogae-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=396},
        {type="fluid", name="oxygen", amount=170},
        {type="item", name="fawogae-spore-mk02", amount=11},
        {type="item", name="powdered-biomass", amount=11},
        {type="item", name="ralesia", amount=2},
      },
      results = {
        {type="item", name="fawogae-mk02", amount=3},
      },
    },
    ["fawogae-spore-mk02"] = {
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=80},
        {type="item", name="coke", amount=16},
        {type="item", name="fawogae", amount=19},
        {type="item", name="fawogae-spore", amount=8},
        {type="item", name="fungal-substrate-03", amount=2},
        {type="item", name="pyrite", amount=1},
      },
      results = {
        {type="item", name="yaedols", amount=6},
      },
    },
    ["yaedols-spore-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="yaedols", amount=82},
      },
      results = {
        {type="item", name="yaedols-spores-mk02", amount=5},
      },
    },
    ["yaedols-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.65369227270274,
      ingredients = {
        {type="fluid", name="steam", amount=551},
        {type="item", name="albumin", amount=3},
        {type="item", name="flamethrower-ammo", amount=1},
        {type="item", name="wood", amount=25},
        {type="item", name="yaedols", amount=3},
      },
      results = {
        {type="item", name="yaedols", amount=1},
        {type="item", name="yaedols-mk02", amount=0.0082684613635137},
      },
    },
    ["yaedols-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 0.888888888888889,
      ingredients = {
        {type="fluid", name="pressured-water", amount=216},
        {type="fluid", name="purest-nitrogen-gas", amount=744},
        {type="item", name="cobalt-extract", amount=7},
        {type="item", name="log", amount=2},
        {type="item", name="powdered-biomass", amount=14},
        {type="item", name="yaedols-spores", amount=599},
      },
      results = {
        {type="item", name="yaedols-mk02", amount=2},
      },
    },
    ["brain-food-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="processed-iron-ore", amount=585},
      },
      results = {
      },
    },
    ["purex-antimony-void"] = {
      mode = "softmax-semantic-substitution",
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
      mode = "input-preserved-unmodified",
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
      mode = "input-preserved-unmodified",
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
